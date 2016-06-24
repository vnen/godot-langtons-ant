# Godot Langton's Ant

A simple [Langton's Ant](https://en.wikipedia.org/wiki/Langton%27s_ant) sample
project made with the [Godot Engine](https://godotengine.org).

## About

This is a proof of concept made with the Godot Engine to run a very simple
procedural generation algorithm. On top of that certain interaction mechanisms
were add to improve the enjoyment of a potential user.

## Running

You need [Godot Engine](https://github.com/godotengine/godot). This was done
with a version compiled from the master branch and have features still not
available in the latest relase. If you're using Godot 2.1-alpha or later you're
good to go.

Then either put the Godot executable in the same folder as this and open it, or
run with `godot -path /path/to/this/project`. You can also use the `data.pck`
file along with your Godot executable.

I may release executables soon, so check out the releases link here to see if
they're available.

## Features

* Ability to start and pause the animationt, and to reset the grid.
* Control to adjust animation speed.
* You can paint the grid with the mouse to test the ant's behavior with different
  patterns.
* The grid is bigger than the screen. Pan with the mouse.
* Controls and labels adjust their position according to window size.
* Save an image with the current pattern. This is done in a separate
  thread so the application is not locked, since this may take a while
  with big images. The image is saved to the user data folder
  (`%APPDATA%\Godot\app_userdata\Langton's Ant`) on Windows,
  `~/.godot/app_userdata/Langton's Ant` on Linux).

All the images in the project were generated with Godot itself (except for the
icon, which was resized from an image saved within the running application).
See the file `gen-images.gd` to see how it was done.

## License

[MIT License](LICENSE). Copyright (c) 2016 George Marques.
