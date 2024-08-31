extends Control


var correct : Array = [0, 0, 0, 0, 1, 1, 1, 1]

func _ready():
	var file = FileAccess.open("user://temp.dat", FileAccess.READ)
	var content = file.get_as_text()
	var results = JSON.parse_string(content)
	
	## TODO: proper formatting
	var table : String
	for x in range(len(results)):
		table += str(results[x]) 
		if results[x][3] == correct[x]:
			table += " O"
		else:
			table += " X"
		table += " " + str(correct[x])
		table += "\n"
	
	$TruthTable/Label2.text = str(table)
