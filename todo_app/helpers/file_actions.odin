package helper

import "core:os"
import "core:fmt"
import "core:encoding/json"

read_file :: proc(filename : string) -> (todos : map[string]json.Value) {
	file_data, success := os.read_entire_file_from_filename(filename)

	if !success {
		fmt.eprintln("Error occurred while reading file.")
		return
		// If there was an issue with reading the file, the program exits.
	}

	json_data, error := json.parse(file_data)
	// This parses the json data in the file so it can be processed.

	if error != .None {
		fmt.println("Failed to parse json file with error: ", error)
		return
	}

	root := json_data.(json.Object)
	for key, value in root {
		todos[key] = value
		// This gathers the data and places it in a map for easy access.
	}

	return todos
}

save_data :: proc(filename : string, data : map[string]json.Value) -> (success : bool = false) {
	value, err := json.marshal(v=data)

	if err != nil {
		fmt.eprintln("Failed to write data with error: %v", err)
		return success
		// If there's an issue in writing the data, it prints the error.
	} else {
		if os.write_entire_file(filename, value) {
			success = true
			return success
			// If the data is successfully written, it returns true.
		}
	}

	return success
}
