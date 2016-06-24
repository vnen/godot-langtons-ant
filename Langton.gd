# The MIT License (MIT)
#
# Copyright (c) 2016 George Marques
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

extends Node2D

signal image_saved

const BLACK = 0
const WHITE = 1

export (Rect2) var grid_size = Rect2(-200, -200, 700, 400)
export (float) var default_speed = 1.0
export (bool) var show_instructions = true
export (Texture) var black_ant
export (Texture) var white_ant
export (Vector2) var ant_start = Vector2(50, 30)

var ant = null
var mouse_speed = 1.0
var dragging = false
var current_speed
var can_paint = true
var inside_control = false
var screenshot_thread
var screenshot_lock

func _ready():
	screenshot_thread = Thread.new()
	screenshot_lock = Semaphore.new()

	var grid = get_node("Grid")
	var camera = get_node("Camera")

	# Adjust the Camera limits
	camera.set_limit(MARGIN_LEFT, grid_size.pos.x * grid.get_cell_size().x)
	camera.set_limit(MARGIN_TOP, grid_size.pos.y * grid.get_cell_size().y)
	camera.set_limit(MARGIN_RIGHT, (grid_size.size.x + grid_size.pos.x) * grid.get_cell_size().x)
	camera.set_limit(MARGIN_BOTTOM, (grid_size.size.y + grid_size.pos.y) * grid.get_cell_size().y)

	# Adjust speed
	get_node("GUI/Speed").set_value(default_speed)
	get_node("GUI/SpeedShow").set_text(str(default_speed).pad_decimals(1) + "x")
	current_speed = default_speed

	set_process_input(true)
	set_process(true)

	# Reset Ant, grid, GUI
	reset()

	# Start screenshot thread
	screenshot_thread.start(self, "screenshot_thread", grid)

func _input(event):
	if dragging and event.type == InputEvent.MOUSE_MOTION:
		translate_camera(get_node("Camera"), event.relative_pos * (-mouse_speed))

	if event.type == InputEvent.MOUSE_BUTTON and event.button_index == BUTTON_MIDDLE:
		if event.is_pressed():
			dragging = true
		else:
			dragging = false

	if event.is_pressed() and not event.is_echo():
		if event.is_action("reset"):
			reset()
		elif event.is_action("start"):
			if (get_node("Animation").is_playing()):
				stop()
			else:
				play()
		elif event.is_action("full"):
			OS.set_window_fullscreen(not OS.is_window_fullscreen())
		elif event.is_action("help"):
			get_node("GUI/Instructions").set_hidden(not get_node("GUI/Instructions").is_hidden())
		elif event.is_action("control"):
			get_node("GUI").set_layer(-1 * get_node("GUI").get_layer())
		elif event.is_action("marker"):
			get_node("AntMarker").set_hidden(not get_node("AntMarker").is_hidden())
		elif event.is_action("screenshot"):
			get_node("GUI/ImageMessage").set_opacity(1)
			get_node("GUI/ImageMessage").set_text("Saving image...")
			screenshot_lock.post()

	if event.is_action("plus"):
		get_node("GUI/Speed").set_value(get_node("GUI/Speed").get_value() + 0.1)
	if event.is_action("minus"):
		get_node("GUI/Speed").set_value(get_node("GUI/Speed").get_value() - 0.1)

func _process(delta):
	var change = false
	var color

	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		change = true
		color = BLACK
	elif Input.is_mouse_button_pressed(BUTTON_RIGHT):
		change = true
		color = WHITE

	if change and can_paint and not inside_control:
		var grid = get_node("Grid")
		grid.set_cellv(grid.world_to_map((get_global_mouse_pos())), color)

func move_ant():
	ant.move()

func translate_camera(camera, amount, absolute=false):
	if absolute:
		camera.set_pos(amount)
	else:
		camera.translate(amount)

	var pos = camera.get_pos()
	var top_limit = Vector2(camera.get_limit(MARGIN_LEFT), camera.get_limit(MARGIN_TOP))
	var bottom_limit = Vector2(camera.get_limit(MARGIN_RIGHT), camera.get_limit(MARGIN_BOTTOM))

	if pos.x < top_limit.x:
		pos.x = top_limit.x
	elif pos.x > bottom_limit.x:
		pos.x = bottom_limit.x
	if pos.y < top_limit.y:
		pos.y = top_limit.y
	elif pos.y > bottom_limit.y:
		pos.y = bottom_limit.y

	camera.set_pos(pos)
	get_node("GUI/CameraPos").set_text(str(pos))

func _on_speed_value_changed(value):
	current_speed = value
	get_node("Animation").set_speed(value)
	get_node("GUI/SpeedShow").set_text(str(value).pad_decimals(1) + "x")

func _on_speed_mouse_enter():
	inside_control = true

func _on_speed_mouse_exit():
	inside_control = false

func reset():
	stop()
	reset_grid()
	translate_camera(get_node("Camera"), Vector2(), true)
	get_node("AntMarker").set_texture(black_ant)
	# Create the ant
	ant = Ant.new(ant_start, get_node("Grid"), get_node("AntMarker"), [black_ant,white_ant])

func stop():
	get_node("Animation").stop(true)
	can_paint = true

func play():
	can_paint = false
	get_node("Animation").play("Langton")

func reset_grid():
	var grid = get_node("Grid")
	# Empty the grid
	for x in range (grid_size.pos.x, grid_size.size.x - grid_size.pos.x):
		for y in range (grid_size.pos.y, grid_size.size.y - grid_size.pos.y):
			grid.set_cell(x, y, WHITE)

func screenshot(grid):
	var scale = 10
	var colors = [Color(0,0,0,1), Color(1,1,1,1)]
	var boundaries = Rect2(ant_start.x, ant_start.y, 0, 0)
	var img

	for x in range (grid_size.pos.x, grid_size.size.x - grid_size.pos.x + 1):
		for y in range (grid_size.pos.y, grid_size.size.y - grid_size.pos.y + 1):
			if grid.get_cell(x, y) == BLACK:
				boundaries.pos.x = min(x, boundaries.pos.x)
				boundaries.pos.y = min(y, boundaries.pos.y)
				boundaries.size.x = max(x, boundaries.size.x + boundaries.pos.x) - boundaries.pos.x
				boundaries.size.y = max(y, boundaries.size.y + boundaries.pos.y) - boundaries.pos.y
	boundaries.size += Vector2(1,1) # Off by one

	img = Image(boundaries.size.x * scale, boundaries.size.y * scale, false, Image.FORMAT_RGBA)

	for x in range (boundaries.size.x * scale):
		for y in range (boundaries.size.y * scale):
			var normalized = (x / scale) + boundaries.pos.x
			img.put_pixel(x,y,colors[grid.get_cell((x / scale) + boundaries.pos.x, (y / scale) + boundaries.pos.y)])

	img.save_png("user://langton-" + str(OS.get_unix_time()) + "-" + str(int(rand_range(1,20000))) + ".png")
	emit_signal("image_saved")

func screenshot_thread(grid):
	while true:
		screenshot_lock.wait()
		screenshot(grid)

class Ant:
	extends Reference

	var pos
	var grid
	var marker
	var dir = Vector2(0,1)
	var textures

	func _init(p_start, p_grid, p_marker, p_textures):
		pos = p_start
		grid = p_grid
		marker = p_marker
		textures = p_textures
		marker.set_pos((pos * 10) + Vector2(5, 5))

	func move():
		var current = grid.get_cellv(pos)
		_rotate(current)
		grid.set_cellv(pos, (current + 1) % 2)
		pos += dir
		current = grid.get_cellv(pos)
		marker.set_pos((pos * 10) + Vector2(5, 5))
		marker.set_texture(textures[(current + 1) % 2])

	func _rotate(to):
		if (to > 0):
			dir = Vector2(dir.y, -dir.x)
		else:
			dir = Vector2(-dir.y, dir.x)


func _on_image_saved():
	get_node("GUI/GUIAnimation").play("image_saved")
