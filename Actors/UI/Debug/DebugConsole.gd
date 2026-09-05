class_name DebugConsole
extends LineEdit

var player : Player
const debugConsoleTSCN = preload("res://Actors/UI/Debug/DebugConsole.tscn")

func _ready():
	pass
	
static func create():
	var instance = debugConsoleTSCN.instantiate()

	return instance  
	
func registerPlayer(thePlayer : Player):
	player = thePlayer
	
func _on_debugCommandEntered(debugCommand):
	print("DEBUG COMMAND: ", debugCommand)
	
	var argv = debugCommand.split(" ", false)
	print(argv)
	
	if len(argv) == 0:
		return
	
	if argv[0] == 'ss':
		self.visible = false
		self.text = ""
		self.visible = false
		
		await get_tree().create_timer(0.05).timeout
				
		var capture = get_viewport().get_texture().get_image()
		var filename = "user://Screenshot-" + Time.get_datetime_string_from_system().replace(":", "-") + ".png"
		capture.save_png(filename)
		
		return
	
	var res = evaluateDebugCommand(argv)

	if res[0]:
		self.visible = false
		self.text = ""
		self.visible = false
	else:
		self.text = ""
		self.placeholder_text = res[1]
		self.grab_focus()

func evaluateDebugCommand(argv : Array) -> Array:
	
	if argv[0] == "element" and len(argv) == 2:
		var elementName : String = argv[1]
		elementName = elementName.to_upper()
		
		var elementKeys = Enums.Elements.keys()
		if not elementName in elementKeys:
			return [false, "element not valid, choose one of" + str(elementKeys)]
		
		else:
			var element : Enums.Elements = elementKeys.find(elementName)
			player.setElement(element)
			
			return [true, ""]
	
	# Ayo RY sorry Imma needa hijack this for testing
	# Bit of sloppy code, will hopefully have the time to clean this up later
	# If it bothers ya, just delete it
	elif argv[0] == "snapshot":
		get_tree().root.get_node("TestLevel/RoomManager").snapshotCurrRoom()
		return [true, ""]
	
	elif argv[0] == "restore":
		get_tree().root.get_node("TestLevel/RoomManager").restoreCurrRoom()
		return [true, ""]

	else:
		return [false, "command not found"]

	
func screenshot():
	self.visible = false
	
	await get_tree().create_timer(0.05).timeout
	actuallyDoScreenshot()
	
	return true
	
func actuallyDoScreenshot():	
	pass
	
