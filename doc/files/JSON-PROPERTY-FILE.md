# JSONPropertyFile
## Functions
| Name | Params | Description | Returns |
|-|-|-|-|
| **set_preprocessor** | **processor -> JSONConfigProcessor:** <br> Object that defines the function to execute before the validation process. | Sets the process to execute before the validation process. | Nothing. |
| **set_postprocessor** | **processor -> JSONConfigProcessor:** <br> Object that defines the function to execute after the validation process. | Sets the process to execute after the validation process. | Nothing. |
| **set_mode_flag** | **mode_flag -> int:** <br> The flag that determines how to open the file. <br><br> **NOTE:** Check [File.ModeFlags](https://docs.godotengine.org/en/stable/classes/class_file.html?highlight=File#enum-file-modeflags) for more information. | Determines how to open the file. | Nothing.