package main

import rl "vendor:raylib"
import hp "helpers"
import sc "screens"

main :: proc() {
	WINDOW_WIDTH :: 500
	WINDOW_HEIGHT :: 500
	// Constant values of the window size.

	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Todo App")

	rl.SetTargetFPS(60)
	defer rl.CloseWindow()

	menu_screen : sc.MenuOpt = .DEFAULT
	exit_window : bool = false
	// This ensures that the app begins on the home screen.

	for !(exit_window) {
		rl.BeginDrawing()
			if rl.IsKeyPressed(rl.KeyboardKey.ESCAPE) || rl.WindowShouldClose() {exit_window = true}
			// The option to click escape/the close button to close the app is still allowed.

			#partial switch menu_screen {
				case .DEFAULT:
					sc.start_screen(&menu_screen)
					sc.todo_frame_y_position = 25
					// On screen change, it resets the position of the todos.
				case .VIEW:
					sc.main_app_screen(&menu_screen)
				case .EXIT:
					exit_window = true
			}
			// Decides the screen/action that is carried out.

		rl.EndDrawing()
	}
}
