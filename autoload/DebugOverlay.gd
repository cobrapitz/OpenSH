extends CanvasLayer


var f_refs = []
onready var text_label = $Control/Panel/RichTextLabel

func _ready():
	pass


func track_func(obj, f_ref, description: String):
	var ref = FuncRef.new()
	ref.set_function(f_ref)
	ref.set_instance(obj)
	f_refs.append({"ref": ref, "description": description})


func _process(delta):
	text_label.text = ""
	for ref in f_refs:
		text_label.text += ref.description + str(ref.ref.call_func()) + "\n"
