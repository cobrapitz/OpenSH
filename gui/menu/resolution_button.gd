extends Button

func _ready():
	set_text("Selected resolution: " + String(Settings.resolution_width) + "x" + String(Settings.resolution_height))


func _pressed():
	if Settings.resolution_width < 1025.0: # Strange comparing because resolution is a float (parsed from json)
		set_text("Selected resolution: 1920x1080")
		Settings.resolution_width = 1920
		Settings.resolution_height = 1080
		Settings.save_settings()
	else:
		set_text("Selected resolution: 1024x768")
		Settings.resolution_width = 1024
		Settings.resolution_height = 768
		Settings.save_settings()
