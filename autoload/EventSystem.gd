extends Node


const Events = {
	"selected_building" : "selected_building",
}


var _registered_events = {}
var _connected = {}

# EventsSystem.register_to_event(EventSystem.Events.selected_building)
# EventSystem.trigger_event(EventSystem.Events.selected_building, [arg1, arg2, ...])


func _ready():
	pass


func register_to_event(event_name : String, func_ref : FuncRef):
	_registered_events[event_name] = func_ref


func trigger_event(event_name : String, data := []):
	_registered_events[event_name].call_funcv(data)
