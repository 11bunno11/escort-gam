extends Control

@onready var astronaut_text = $VBoxContainer/AstronautText
@onready var input_line = $VBoxContainer/InputLine
@onready var debug_label = $VBoxContainer/DebugLabel

const VERBS = {
	"move": "MOVE",
	"go": "MOVE",
	"walk": "MOVE",
	"run": "MOVE",
	"wait": "WAIT",
	"open": "OPEN",
	"check": "CHECK",
	"look": "CHECK",
	"inspect": "CHECK",
	"hide": "HIDE",
	"follow": "FOLLOW"
}

const OBJECTS = {
	"door": "DOOR",
	"corridor": "CORRIDOR",
	"hallway": "CORRIDOR",
	"light": "LIGHT",
	"tank": "TANK",
	"panel": "PANEL"
}

const DIRECTIONS = {
	"left": "LEFT",
	"right": "RIGHT",
	"forward": "FORWARD",
	"ahead": "FORWARD",
	"back": "BACK",
	"behind": "BACK"
}


func _ready():
	astronaut_text.clear()
	astronaut_text.text = "client online.\nawaiting commands.\n"
	input_line.grab_focus()

var input_buffer := ""
var pending_command := {}

func _on_input_line_text_submitted(text):
	if text.strip_edges() == "":
		return

	input_buffer += " " + text.strip_edges()
	var parsed = parse_input(input_buffer)
	
	
	
	
	if not pending_command.has("verb") and parsed["verb"] != null:
		pending_command["verb"] = parsed["verb"]
	if not pending_command.has("object") and parsed["object"] !=null:
		pending_command["object"] = parsed["object"]
	if not pending_command.has("direction") and parsed["direction"] !=null:
		pending_command["direction"] = parsed["direction"]
	
	if pending_command.has("verb") and not yo_bro_this_usable(pending_command) and not is_incomplete(pending_command):

		astronaut_text.append_text("\n whar??\n")
		input_buffer = " "
		pending_command ={}
		input_line.clear()
		return
		
	pending_command["certainty"] = parsed["certainty"]
	
	astronaut_text.append_text("\n>" + text)
	astronaut_text.append_text("\n" + dude_response(pending_command) + "\n")
	debug_label.text = str(pending_command)
	input_line.clear()

	if yo_bro_this_usable(pending_command) and pending_command.has("verb"):
		input_buffer = ""
		pending_command = {}
#chatgpt help me >.<
func is_incomplete(cmd: Dictionary) -> bool:
	if not cmd.has("verb"):
		return true
	match cmd["verb"]:
		"MOVE":
			return not cmd.has("direction")
		"CHECK", "OPEN":
			return not cmd.has("object")
	return false
func yo_bro_this_usable(cmd: Dictionary) -> bool:
	if not cmd.has("verb") or cmd["verb"] == null:
		return true
	match cmd["verb"]:
		"MOVE":
			return cmd.has("direction")
		"CHECK", "OPEN":
			return cmd.has("object")
		"WAIT", "HIDE", "FOLLOW":
			return true
	return true
#thx chatgpt ^w^

func parse_input(text: String) -> Dictionary:
	var clean = text.to_lower().replace("?", " ").replace("!", "").replace(",","")
	
	var words = clean.split(" ")
	
	var verb = null
	var object = null
	var direction = null
	var certainty = 0.7 #default is medium :3
	
	for w in words:
		if verb == null and VERBS.has(w):
			verb = VERBS[w]
		if object == null and OBJECTS.has(w):
			object = OBJECTS[w]
		if direction == null and DIRECTIONS.has(w):
			direction = DIRECTIONS[w]
	
	if "dont" in words or "maybe" in words or "not" in text:
		certainty = 0.3
	elif "pretty" in text or "should" in text:
		certainty = 0.6
	elif "definitely" in text or "100%" in text:
		certainty = 0.9
	
	return {
		"verb": verb,
		"object": object,
		"direction": direction,
		"certainty": certainty,
		"raw": text
		
		}
func dude_response(result: Dictionary) -> String:
	if not result.has("verb") or result["verb"] == null:
		return "what do you want me to do?"
	
	var prefix = ""
	if result.certainty < 0.4:
		prefix = "maybe? ok, i guess."
	elif result.certainty < 0.8:
		prefix = "copy."
	elif result.certainty < 1:
		prefix = "got it."
	
	if result["verb"] == "MOVE" and not result.has("direction"):
		return prefix + "which way?"
	if result["verb"] == "CHECK" and not result.has("object"):
		return prefix + "check what?"
	return prefix + " attempting" + " " + result["verb"].to_lower() + "."
