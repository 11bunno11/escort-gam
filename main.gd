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
	astronaut_text.text = "operator online.\nawaiting commands.\n"
	input_line.grab_focus()

func _on_input_line_text_submitted(text):
	if text.strip_edges() == "":
		return

	var result = parse_input(text)
	
	astronaut_text.text += "\n> " + text
	astronaut_text.text += "\n" + astronaut_response(result) + "\n"

	debug_label.text = str(result)
	input_line.clear()

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
	
	if "maybe" in words or "think" in words or "not sure" in text:
		certainty = 0.3
	elif "pretty sure" in text or "looks like" in text:
		certainty = 0.6
	elif "definitely" in text or "100%" in text:
		certainty = 0.9
	
	return {
		"verb": verb,
		"object": object,
		"direction": direction,
		"raw": text,
		"certainty": certainty
		}
func astronaut_response(result: Dictionary) -> String:
	if result.verb == null:
		return "what do you want me to do?"
	
	var prefix = ""
	if result.certainty < 0.4:
		prefix = "i think"
	elif result.certainty < 0.7:
		prefix = "pretty sure"
	
	if result.verb == "MOVE" and result.direction == null:
		return "which way?"
	if result.verb == "CHECK" and result.object == null:
		return "check what?"
	return "copy. attempting " + result.verb.to_lower() + "."
