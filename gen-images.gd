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

extends SceneTree

# This generates the images needed by the game
# Run with: godot -s gen-images.gd

func _init():

	# Generate ant markers
	ant_marker_white()
	ant_marker_black()

	# Generate black and white tileset
	bw_tileset()

	# Generate control textures
	slider()
	grabber()

	quit()

func ant_marker_black():
	var img = Image(4,4,false,Image.FORMAT_RGBA)
	var black = Color(0, 0, 0, 1)
	var transparent = Color(0, 0, 0, 0)

	for x in range(4):
		for y in range(4):
			img.put_pixel(x, y, black)

	var texture = ImageTexture.new()
	texture.create_from_image(img, 0)

	ResourceSaver.save("ant_b.png", texture)

func ant_marker_white():
	var img = Image(4,4,false,Image.FORMAT_RGBA)
	var black = Color(1, 1, 1, 1)
	var transparent = Color(0, 0, 0, 0)

	for x in range(4):
		for y in range(4):
			img.put_pixel(x, y, black)

	var texture = ImageTexture.new()
	texture.create_from_image(img, 0)

	ResourceSaver.save("ant_w.png", texture)

func bw_tileset():
	var img = Image(20,10,false,Image.FORMAT_RGBA)
	var white = Color(1,1,1,1)
	var black = Color(0,0,0,1)

	for x in range(20):
		for y in range(10):
			if x < 10:
				img.put_pixel(x, y, black)
			else:
				img.put_pixel(x, y, white)

	var texture = ImageTexture.new()
	texture.create_from_image(img, 0)

	ResourceSaver.save("bw-tileset.png", texture)

func slider():
	var img = Image(20,10,false,Image.FORMAT_RGBA)
	var white = Color(1,1,1,1)
	var black = Color(0,0,0,1)

	for x in range(20):
		for y in range(10):
			img.put_pixel(x, y, white)

	for x in range(20):
		img.put_pixel(x, 0, black)
		img.put_pixel(x, 9, black)
	for y in range(10):
		img.put_pixel(0, y, black)
		img.put_pixel(19, y, black)

	var texture = ImageTexture.new()
	texture.create_from_image(img, 0)

	ResourceSaver.save("slider.png", texture)

func grabber():
	var img = Image(10,20,false,Image.FORMAT_RGBA)
	var white = Color(1,1,1,1)
	var black = Color(0,0,0,1)

	for x in range(10):
		for y in range(20):
			img.put_pixel(x, y, black)

	for x in range(10):
		img.put_pixel(x, 0, white)
		img.put_pixel(x, 19, white)
	for y in range(20):
		img.put_pixel(0, y, white)
		img.put_pixel(9, y, white)

	var texture = ImageTexture.new()
	texture.create_from_image(img, 0)

	ResourceSaver.save("grabber.png", texture)
