package screen

import rl "vendor:raylib"
import hs "../helpers"

MenuOpt :: enum {
	DEFAULT,
	VIEW,
	EXIT,
}
// Establishes different menu types to make changing screens easier.

start_screen :: proc(choice : ^MenuOpt){
	rl.ClearBackground(rl.Color{227, 223, 218, 255})
	rl.DrawText(text="Todo App", posX=125, posY=120, fontSize=50, color=rl.BLACK)
	// Resets the background and makes it white. It also draws the title onto the window.

	open_button := rl.Rectangle{x=150, y=190, width=200, height=50}
	exit_button := rl.Rectangle{x=150, y=280, width=200, height=50}
	// Variables of each button's rectangle are made so the buttons can interact with the user's cursor.

	buttons := [2]rl.Rectangle{open_button, exit_button}

	if rl.GuiButton(bounds=open_button, text="#157#Open App") do choice^ = MenuOpt.VIEW
	if rl.GuiButton(bounds=exit_button, text="#159#Exit") do choice^ = MenuOpt.EXIT
	// Changes the state of the menu variable based on the pressed button.
}
