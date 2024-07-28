package screen

import "core:encoding/json"
import rl "vendor:raylib"
import hp "../helpers"
import t "core:time"

BUTTON_WIDTH :: 100
BUTTON_HEIGHT :: 30

FRAME_WIDTH :: 500
FRAME_HEIGHT :: 100

FILENAME :: "todos.json"
// Constants that are used throughout the code.

todo_values := hp.read_file(FILENAME)
todo_frame_y_position : i32 = 25
show_message := false
show_text_input := false
text_input : [1024]u8
// Global values defined outside of the main build function so that they aren't constantly refreshed.

todo_frame :: proc(x_pos : i32, y_pos : i32, identifier : string, text : cstring, number : i32) {
	frame_rec := rl.Rectangle{x=cast(f32)x_pos,
				  y=cast(f32)y_pos,
				  width=FRAME_WIDTH,
				  height=FRAME_HEIGHT}

	rl.DrawRectangleRec(rec=frame_rec,
			    color=rl.Color{209, 200, 188, 255})

	rl.DrawRectangleLines(posX=  cast(i32)frame_rec.x,
			      posY=  cast(i32)frame_rec.y,
			      width= cast(i32)frame_rec.width,
			      height=cast(i32)frame_rec.height,
			      color=rl.BLACK)

	rl.DrawText(text=rl.TextFormat("Todo #%i", number),
		    posX=cast(i32)frame_rec.x + 10,
		    posY=cast(i32)frame_rec.y + 10,
		    fontSize=20,
		    color=rl.BLACK)

	rl.DrawText(text=text,
	            posX=cast(i32)frame_rec.x + 20,
		    posY=cast(i32)frame_rec.y + 35,
		    fontSize=18,
		    color=rl.BLACK)

	if rl.GuiButton(bounds=rl.Rectangle{x=frame_rec.x + ((frame_rec.width/2) - (BUTTON_WIDTH/2)),
					    y=frame_rec.y + 60,
					    width=BUTTON_WIDTH,
					    height=BUTTON_HEIGHT},
			text="#143#Delete To-do") {delete_key(&todo_values, identifier)}
	// This button deletes the todo from the todo_values map, causing it to not be re-drawn next frame.
}
// A frame for the todo structure - this makes it easy to create multiple of them.

build_todos :: proc(y_pos : i32) {
	OFFSET :: 10

	frame_number : i32 = 1
	y_pos := y_pos

	for key, value in todo_values {
		if frame_number == 1 do y_pos += OFFSET

		 todo_frame(x_pos=0,
			    y_pos=y_pos,
			    identifier=key,
		            text=rl.TextFormat("%v", value),
			    number=frame_number)

		y_pos += FRAME_HEIGHT + OFFSET
		frame_number += 1
		// This ensures that the todos aren't built over each other all the time.
	}
}
// This builds the todos in the todo_values map.

nav_bar :: proc(choice : ^MenuOpt) {
	container_bar := rl.Rectangle{x=0,
				      y=0,
				      width=500,
				      height=25}

	rl.DrawRectangleRec(container_bar,
	           	    color=rl.Color{169, 176, 184, 255})

	if rl.GuiButton(bounds=rl.Rectangle{x=500 - (BUTTON_WIDTH*1.6),
					    y=     container_bar.y,
		        		    width= BUTTON_WIDTH * 1.6,
		       			    height=container_bar.height},
			text="#185#Return to Home Screen") {choice^ = MenuOpt.DEFAULT}

	if rl.GuiButton(bounds=rl.Rectangle{x=     container_bar.x,
					    y=     container_bar.y,
					    width= BUTTON_WIDTH * 1.6,
					    height=container_bar.height},
			text="#218#New To-do")
		{
			show_text_input = true
			show_message = false
			// This ensures that when this textbox is active, the save message is not visible.
	}

	if rl.GuiButton(bounds=rl.Rectangle{x=(BUTTON_WIDTH * 1.6) + 10,
					    y=container_bar.y,
					    width=BUTTON_WIDTH * 1.6,
					    height=container_bar.height},
			text="#2#Save To-dos")
		{
			show_message = hp.save_data(FILENAME, todo_values)
			show_text_input = false
			// This ensures that when the messagebox is active
			// (in the event of a successful save), the textbox is not visible.
	}
}
// This builds the navigation bar at the top of the screen.
// It allows the user to move back to the home or make/save todos.

scrolling_frames :: proc(y_pos : ^i32) {
	mousewheel_y_movement := rl.GetMouseWheelMoveV()[1]
	// This gets only the y movement of the mouse wheel.

	if mousewheel_y_movement != 0 {
		y_pos^ += cast(i32)mousewheel_y_movement
	}

	build_todos(y_pos=y_pos^)
}
// This allows the todos to be moved by the mouse wheel.
// It allows many to be drawn on screen but still accessible.

main_app_screen :: proc(choice : ^MenuOpt) {
	rl.ClearBackground(rl.Color{227, 223, 218, 255})
	nav_bar(choice)

	rl.BeginScissorMode(0, 25, 500, 475)
		build_todos(y_pos=todo_frame_y_position)
		scrolling_frames(&todo_frame_y_position)
	rl.EndScissorMode()
	// This prevents the todos from being drawn over the navigation bar/notifications.

	if show_message {
		click := rl.GuiMessageBox(bounds=rl.Rectangle{100, 150, 300, 100},
					  title="#218#File Notification",
					  message="The to-dos were saved successfully!",
					  buttons="Ok")

		if click > 0 do show_message = false
		// If the user presses the 'Ok' button, the messagebox will no longer be displayed.
	}

	if show_text_input {
		result := rl.GuiTextInputBox(bounds=rl.Rectangle{100, 120, 300, 130},
					     title="Important",
				     	     message="Enter the task below:",
					     buttons="#112#Enter;#113#Cancel",
					     text=transmute(cstring)&text_input,
					     textMaxSize=1024,
					     secretViewActive=&show_text_input)

		if result == 1 {
			todo := json.Value(string(transmute(cstring)&text_input))
			day_buf : [t.MIN_YY_DATE_LEN]u8

			todo_values[t.to_string_dd_mm_yy(t.now(), day_buf[:])] = json.clone_value(todo)
			// This writes the todo mapped to the current day into the main todo_values variable, so it's drawn next frame.

			show_text_input = false
			text_input = 0
			// This resets the text_input variable and stops the widget from being displayed.
		}
		else if result == 2 {
			show_text_input = false
			text_input = 0
			// This resets the text_input variable and stops the widget from being displayed.
		}
	}
}
