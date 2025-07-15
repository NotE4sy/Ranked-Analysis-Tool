extends Node2D

@onready var Ranked_GetUser : HTTPRequest = get_node("Ranked_GetUser")
@onready var GetUserHead : HTTPRequest = get_node("GetUserHead")
@onready var Ranked_GetMatches : HTTPRequest = get_node("Ranked_GetMatches")

@onready var GamemodeOption : OptionButton = get_node("GamemodeOption")
@onready var MatchCountSlider : HSlider = get_node("MatchCountSlider")
@onready var StatsOption : OptionButton = get_node("StatsOption")

@onready var Splits : Node2D = get_node("Splits")
@onready var Timestamps : Node2D = get_node("Timestamps")
@onready var Overworlds : Node2D = get_node("Overworlds")
@onready var Bastions : Node2D = get_node("Bastions")

@onready var Notice : RichTextLabel = get_node("Notice")
@onready var NameCard : Control = get_node("NameCard")
@onready var TemplateHead : Sprite2D = get_node("NameCard/TemplateHead")

@onready var birbs : Array = Notice.get_children()

var matchCount : int = 20
var matchesParsed : int = 0
var currentGamemode : int = 2
var selectedBirb : int = 0

var rng = RandomNumberGenerator.new()

var playerUUID : String = ""

var splits = {
	"enter_nether": [0, 0],
	"enter_bastion": [0, 0],
	"enter_fortress": [0, 0],
	"blind": [0, 0],
	"enter_stronghold": [0, 0],
	"enter_end": [0, 0],
	"completion": [0, 0]
}

var splitsDuration = {
	"overworld": [0, 0],
	"nether_terrain": [0, 0],
	"bastion": [0, 0],
	"fortress": [0, 0],
	"blind": [0, 0],
	"stronghold": [0, 0],
	"end": [0, 0]
}

var overworldSplits = {
	"BURIED_TREASURE": [0, 0],
	"VILLAGE": [0, 0],
	"SHIPWRECK": [0, 0],
	"DESERT_TEMPLE": [0, 0],
	"RUINED_PORTAL": [0, 0]
}

var bastionSplits = {
	"BRIDGE": [0, 0],
	"HOUSING": [0, 0],
	"STABLES": [0, 0],
	"TREASURE": [0, 0]
}

func pickRandomBirb():
	birbs[selectedBirb].visible = false
	var newBirb = rng.randi_range(0, birbs.size()-1)
	if newBirb == selectedBirb:
		newBirb -= 1
		if newBirb < 0:
			newBirb = birbs.size() - 1
	selectedBirb = newBirb
	birbs[selectedBirb].visible = true

func round_to_dec(num, digit : int):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

func reload(noticeText : String):
	matchesParsed = 0
	Notice.visible = true
	Splits.visible = false
	Bastions.visible = false
	Timestamps.visible = false
	Overworlds.visible = false
	Notice.text = noticeText
	MatchCountSlider.visible = false
	GamemodeOption.visible = false
	
	overworldSplits = {
		"BURIED_TREASURE": [0, 0],
		"VILLAGE": [0, 0],
		"SHIPWRECK": [0, 0],
		"DESERT_TEMPLE": [0, 0],
		"RUINED_PORTAL": [0, 0]
	}
	
	splits = {
		"enter_nether": [0, 0],
		"enter_bastion": [0, 0],
		"enter_fortress": [0, 0],
		"blind": [0, 0],
		"enter_stronghold": [0, 0],
		"enter_end": [1, 0],
		"completion": [0, 0]
	}
	
	bastionSplits = {
		"BRIDGE": [0, 0],
		"HOUSING": [0, 0],
		"STABLES": [0, 0],
		"TREASURE": [0, 0]	
	}
	
	splitsDuration = {
		"overworld": [0, 0],
		"nether_terrain": [0, 0],
		"bastion": [0, 0],
		"fortress": [0, 0],
		"blind": [0, 0],
		"stronghold": [0, 0],
		"end": [0, 0]
	}
	
	Overworlds.get_node("Buried Treasure/Time_SampleSize").text = "N/A"
	Overworlds.get_node("Shipwreck/Time_SampleSize").text = "N/A"
	Overworlds.get_node("Village/Time_SampleSize").text = "N/A"
	Overworlds.get_node("Ruined Portal/Time_SampleSize").text = "N/A"
	Overworlds.get_node("Desert Temple/Time_SampleSize").text = "N/A"
	
	Bastions.get_node("Bridge/Time_SampleSize").text = "N/A"
	Bastions.get_node("Housing/Time_SampleSize").text = "N/A"
	Bastions.get_node("Stables/Time_SampleSize").text = "N/A"
	Bastions.get_node("Treasure/Time_SampleSize").text = "N/A"
	
	Splits.get_node("Overworld/Time_SampleSize").text = "N/A"
	Splits.get_node("Nether Terrain/Time_SampleSize").text = "N/A"
	Splits.get_node("Bastion/Time_SampleSize").text = "N/A"
	Splits.get_node("Fortress/Time_SampleSize").text = "N/A"
	Splits.get_node("Blind/Time_SampleSize").text = "N/A"
	Splits.get_node("Stronghold/Time_SampleSize").text = "N/A"
	Splits.get_node("End/Time_SampleSize").text = "N/A"
	Splits.get_node("Completion/Time_SampleSize").text = "N/A"
	
	Timestamps.get_node("Nether Enter/Time_SampleSize").text = "N/A"
	Timestamps.get_node("Bastion/Time_SampleSize").text = "N/A"
	Timestamps.get_node("Fortress/Time_SampleSize").text = "N/A"
	Timestamps.get_node("Blind/Time_SampleSize").text = "N/A"
	Timestamps.get_node("Stronghold/Time_SampleSize").text = "N/A"
	Timestamps.get_node("End/Time_SampleSize").text = "N/A"
	Timestamps.get_node("Completion/Time_SampleSize").text = "N/A"

func _ready() -> void:
	for birb in birbs:
		birb.visible = false
		birb.play()

func _process(_delta: float) -> void:
	if matchesParsed >= matchCount:
		Notice.visible = false
		MatchCountSlider.visible = true
		GamemodeOption.visible = true
		StatsOption.visible = true
		matchesParsed = -1
		
		if StatsOption.selected == 0:
			Splits.visible = true
		elif StatsOption.selected == 1:
			Timestamps.visible = true
		elif StatsOption.selected == 2:
			Overworlds.visible = true
		elif StatsOption.selected == 3:
			Bastions.visible = true
			
		if overworldSplits["BURIED_TREASURE"][0] > 0:
			Overworlds.get_node("Buried Treasure/Time_SampleSize").text = str(msToMinSecs(overworldSplits["BURIED_TREASURE"][1] / overworldSplits["BURIED_TREASURE"][0])) + " (" + str(overworldSplits["BURIED_TREASURE"][0]) + ")"
		
		if overworldSplits["VILLAGE"][0] > 0:
			Overworlds.get_node("Village/Time_SampleSize").text = str(msToMinSecs(overworldSplits["VILLAGE"][1] / overworldSplits["VILLAGE"][0])) + " (" + str(overworldSplits["VILLAGE"][0]) + ")"
			
		if overworldSplits["SHIPWRECK"][0] > 0:
			Overworlds.get_node("Shipwreck/Time_SampleSize").text = str(msToMinSecs(overworldSplits["SHIPWRECK"][1] / overworldSplits["SHIPWRECK"][0])) + " (" + str(overworldSplits["SHIPWRECK"][0]) + ")"
			
		if overworldSplits["DESERT_TEMPLE"][0] > 0:
			Overworlds.get_node("Desert Temple/Time_SampleSize").text = str(msToMinSecs(overworldSplits["DESERT_TEMPLE"][1] / overworldSplits["DESERT_TEMPLE"][0])) + " (" + str(overworldSplits["DESERT_TEMPLE"][0]) + ")"
			
		if overworldSplits["RUINED_PORTAL"][0] > 0:
			Overworlds.get_node("Ruined Portal/Time_SampleSize").text = str(msToMinSecs(overworldSplits["RUINED_PORTAL"][1] / overworldSplits["RUINED_PORTAL"][0])) + " (" + str(overworldSplits["RUINED_PORTAL"][0]) + ")"
		
		if bastionSplits["BRIDGE"][0] > 0:
			Bastions.get_node("Bridge/Time_SampleSize").text = str(msToMinSecs(bastionSplits["BRIDGE"][1] / bastionSplits["BRIDGE"][0])) + " (" + str(bastionSplits["BRIDGE"][0]) + ")"
			
		if bastionSplits["HOUSING"][0] > 0:
			Bastions.get_node("Housing/Time_SampleSize").text = str(msToMinSecs(bastionSplits["HOUSING"][1] / bastionSplits["HOUSING"][0])) + " (" + str(bastionSplits["HOUSING"][0]) + ")"
			
		if bastionSplits["STABLES"][0] > 0:
			Bastions.get_node("Stables/Time_SampleSize").text = str(msToMinSecs(bastionSplits["STABLES"][1] / bastionSplits["STABLES"][0])) + " (" + str(bastionSplits["STABLES"][0]) + ")"	
			
		if bastionSplits["TREASURE"][0] > 0:
			Bastions.get_node("Treasure/Time_SampleSize").text = str(msToMinSecs(bastionSplits["TREASURE"][1] / bastionSplits["TREASURE"][0])) + " (" + str(bastionSplits["TREASURE"][0]) + ")"
		
		if splitsDuration["overworld"][0] == 0:
			Splits.get_node("Overworld/Time_SampleSize").text = "N/A"
			Splits.get_node("Nether Terrain/Time_SampleSize").text = "N/A"
		else:
			Splits.get_node("Overworld/Time_SampleSize").text = str(msToMinSecs(splitsDuration["overworld"][1] / splitsDuration["overworld"][0])) + " (" + str(splitsDuration["overworld"][0]) + ")"
			Splits.get_node("Nether Terrain/Time_SampleSize").text = str(msToMinSecs(splitsDuration["nether_terrain"][1] / splitsDuration["nether_terrain"][0])) + " (" + str(splitsDuration["nether_terrain"][0]) + ")"
			
			if splitsDuration["bastion"][0] == 0:
				Splits.get_node("Bastion/Time_SampleSize").text = "N/A"
			else:
				Splits.get_node("Bastion/Time_SampleSize").text = str(msToMinSecs(splitsDuration["bastion"][1] / splitsDuration["bastion"][0])) + " (" + str(splitsDuration["bastion"][0]) + ")"

				if splitsDuration["fortress"][0] == 0:
					Splits.get_node("Fortress/Time_SampleSize").text = "N/A"
				else:
					Splits.get_node("Fortress/Time_SampleSize").text = str(msToMinSecs(splitsDuration["fortress"][1] / splitsDuration["fortress"][0])) + " (" + str(splitsDuration["fortress"][0]) + ")"

					if splitsDuration["blind"][0] == 0:
						Splits.get_node("Blind/Time_SampleSize").text = "N/A"
					else:
						Splits.get_node("Blind/Time_SampleSize").text = str(msToMinSecs(splitsDuration["blind"][1] / splitsDuration["blind"][0])) + " (" + str(splitsDuration["blind"][0]) + ")"

						if splitsDuration["stronghold"][0] == 0:
							Splits.get_node("Stronghold/Time_SampleSize").text = "N/A"
						else:
							Splits.get_node("Stronghold/Time_SampleSize").text = str(msToMinSecs(splitsDuration["stronghold"][1] / splitsDuration["stronghold"][0])) + " (" + str(splitsDuration["stronghold"][0]) + ")"
	
							if splitsDuration["end"][0] == 0:
								Splits.get_node("End/Time_SampleSize").text = "N/A"
							else:
								Splits.get_node("End/Time_SampleSize").text = str(msToMinSecs(splitsDuration["end"][1] / splitsDuration["end"][0])) + " (" + str(splitsDuration["end"][0]) + ")"

								if splits["completion"][0] == 0:
									Splits.get_node("Completion/Time_SampleSize").text = "N/A"
								else:
									Splits.get_node("Completion/Time_SampleSize").text = str(msToMinSecs(splitsDuration["overworld"][1] / splitsDuration["overworld"][0] + splitsDuration["nether_terrain"][1] / splitsDuration["nether_terrain"][0] + splitsDuration["bastion"][1] / splitsDuration["bastion"][0] + splitsDuration["fortress"][1] / splitsDuration["fortress"][0] + splitsDuration["blind"][1] / splitsDuration["blind"][0] + splitsDuration["stronghold"][1] / splitsDuration["stronghold"][0] + splitsDuration["end"][1] / splitsDuration["end"][0]))
				
		if splits["enter_nether"][0] == 0:
			Timestamps.get_node("Nether Enter/Time_SampleSize").text = "N/A"
		else:
			Timestamps.get_node("Nether Enter/Time_SampleSize").text = str(msToMinSecs(splits["enter_nether"][1] / splits["enter_nether"][0])) + " (" + str(splits["enter_nether"][0]) + ")"
			
			if splits["enter_bastion"][0] == 0:
				Timestamps.get_node("Bastion/Time_SampleSize").text = "N/A"
			else:
				Timestamps.get_node("Bastion/Time_SampleSize").text = str(msToMinSecs(splits["enter_bastion"][1] / splits["enter_bastion"][0])) + " (" + str(splits["enter_bastion"][0]) + ")"

				if splits["enter_fortress"][0] == 0:
					Timestamps.get_node("Fortress/Time_SampleSize").text = "N/A"
				else:
					Timestamps.get_node("Fortress/Time_SampleSize").text = str(msToMinSecs(splits["enter_fortress"][1] / splits["enter_fortress"][0])) + " (" + str(splits["enter_fortress"][0]) + ")"

					if splits["blind"][0] == 0:
						Timestamps.get_node("Blind/Time_SampleSize").text = "N/A"
					else:
						Timestamps.get_node("Blind/Time_SampleSize").text = str(msToMinSecs(splits["blind"][1] / splits["blind"][0])) + " (" + str(splits["blind"][0]) + ")"

						if splits["enter_stronghold"][0] == 0:
							Timestamps.get_node("Stronghold/Time_SampleSize").text = "N/A"
						else:
							Timestamps.get_node("Stronghold/Time_SampleSize").text = str(msToMinSecs(splits["enter_stronghold"][1] / splits["enter_stronghold"][0])) + " (" + str(splits["enter_stronghold"][0]) + ")"
	
							if splits["enter_end"][0] == 0:
								Timestamps.get_node("End/Time_SampleSize").text = "N/A"
							else:
								Timestamps.get_node("End/Time_SampleSize").text = str(msToMinSecs(splits["enter_end"][1] / splits["enter_end"][0])) + " (" + str(splits["enter_end"][0]) + ")"

								if splits["completion"][0] == 0:
									Timestamps.get_node("Completion/Time_SampleSize").text = "N/A"
								else:
									Timestamps.get_node("Completion/Time_SampleSize").text = str(msToMinSecs(splits["completion"][1] / splits["completion"][0])) + " (" + str(splits["completion"][0]) + ")"
		
	else:
		if not Splits.visible and not Timestamps.visible and not Overworlds.visible and not Bastions.visible:
			Notice.visible = true
			GamemodeOption.visible = false
			StatsOption.visible = false
			MatchCountSlider.visible = false
	
	MatchCountSlider.get_node("MatchCount").text = "Matches: " + str(int(MatchCountSlider.value))
		
func msToMinSecs(milliseconds) -> String:
	var minutes = milliseconds / 60000
	var seconds : int = int(60 * (minutes - int(minutes)))
	if seconds < 10:
		return str(int(minutes)) + ":0" + str(seconds)
	
	return str(int(minutes)) + ":" + str(seconds)

func _on_line_edit_text_submitted(new_text: String) -> void:
	var Ranked_GetUser_Request = Ranked_GetUser.request("https://api.mcsrranked.com/users/" + new_text)
	var GetUserHead_Request = GetUserHead.request("https://mc-heads.net/head/" + new_text + "/300.png")
	var Ranked_GetMatches_Request = Ranked_GetMatches.request("https://api.mcsrranked.com/users/" + new_text + "/matches?type=2&count=" + str(matchCount) + "&sort=newest")
	
	pickRandomBirb()
	reload("[center]Loading..")
	currentGamemode = 2
	matchCount = 20
	MatchCountSlider.value = 20
	StatsOption.selected = 0
	GamemodeOption.selected = 0
	NameCard.visible = false
	
	if Ranked_GetMatches_Request != OK:
		push_error("An error has occured with the Ranked_GetMatches API request")
	
	if Ranked_GetUser_Request != OK:
		push_error("An error has occured with the Ranked_GetUser API request")
		
	if GetUserHead_Request != OK:
		push_error("An error has occured with the GetUserHead API request")

func _on_ranked_get_user_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var jsonResponse = JSON.new()
	jsonResponse.parse(body.get_string_from_utf8())
	var response = jsonResponse.get_data()
	
	if response["status"] == "success":
		playerUUID = response["data"]["uuid"]
		NameCard.get_node("Name").text = response["data"]["nickname"]
		NameCard.get_node("PB").text = "PB: " + msToMinSecs(response["data"]["statistics"]["total"]["bestTime"]["ranked"])
		NameCard.get_node("WinRate").text = "W/L Rate: " + str(round_to_dec(response["data"]["statistics"]["total"]["wins"]["ranked"] / response["data"]["statistics"]["total"]["playedMatches"]["ranked"] * 100, 1)) + "%"
		Notice.text = "[center]Loading Splits.."
		NameCard.visible = true
	else:
		Notice.visible = true
		NameCard.visible = false
		Splits.visible = false
		GamemodeOption.visible = false
		birbs[selectedBirb].visible = false
		Notice.text = "[center]ERROR: " + response["data"]

func _on_get_user_head_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("Player head couldn't be downloaded.")
		
	var PlayerHead = Image.new()
	var response = PlayerHead.load_png_from_buffer(body)
	
	if response != OK:
		push_error("Couldn't load player head")
	
	var HeadTexture = ImageTexture.create_from_image(PlayerHead)
	
	TemplateHead.texture = HeadTexture

func _on_ranked_get_matches_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var jsonResponse = JSON.new()
	jsonResponse.parse(body.get_string_from_utf8())
	var response = jsonResponse.get_data()
	
	if response["status"] == "success":
		if matchCount > response["data"].size():
			matchCount = response["data"].size()
		for i in range(0, matchCount):
			var Ranked_GetMatch = HTTPRequest.new()
			add_child(Ranked_GetMatch)
			Ranked_GetMatch.request_completed.connect(_on_ranked_get_match_request_completed)
			var Ranked_GetMatch_Request = Ranked_GetMatch.request("https://api.mcsrranked.com/matches/" + str(response["data"][i]["id"]))
			
			if Ranked_GetMatch_Request != OK:
				push_error("An error has occured with the Ranked_GetMatch_Request API request")

func _on_ranked_get_match_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var jsonResponse = JSON.new()
	jsonResponse.parse(body.get_string_from_utf8())
	var response = jsonResponse.get_data()
	
	if response["status"] == "error":
		push_error("ERROR IN _on_ranked_get_match_request_completed: " + response["data"])
		Notice.text = "ERROR IN _on_ranked_get_match_request_completed: " + response["data"]
		return
	
	var gameResult = response["data"]["result"]["time"]
	var completed = false
	var forfeitedSplit = ""
	
	var latestReset = 0
	var latestSplit = ["", ""]
	
	var currentMatchTimestamps = {
		"enter_nether": 0,
		"enter_bastion": 0,
		"enter_fortress": 0,
		"blind": 0,
		"enter_stronghold": 0,
		"enter_end": 0
	}
	
	for completion in response["data"]["completions"]:
		if "uuid" in completion and "time" in completion and completion["uuid"] == playerUUID:
			splits["completion"][1] += completion["time"]
			splits["completion"][0] += 1
			gameResult = completion["time"]
			completed = true
			print("Completed")
			break
			
	for i in range(response["data"]["timelines"].size()-1, -1, -1):
		var advancement = response["data"]["timelines"][i]
		if advancement["uuid"] == playerUUID:
			match advancement["type"]:
				"projectelo.timeline.reset":
					latestReset = advancement["time"]
					#if latestSplit[0] != "":
					#	splitsDuration[latestSplit[1]][0] -= 1
					#	splitsDuration[latestSplit[1]][1] -= gameResult - currentMatchTimestamps[latestSplit[0]]
				"story.enter_the_nether":
					currentMatchTimestamps["enter_nether"] = advancement["time"]
					splitsDuration["overworld"][1] += advancement["time"] - latestReset
					splitsDuration["overworld"][0] += 1
					splits["enter_nether"][0] += 1
					splits["enter_nether"][1] += advancement["time"] - latestReset
					if response["data"]["seed"]["overworld"] != null:
						overworldSplits[response["data"]["seed"]["overworld"]][0] += 1
						overworldSplits[response["data"]["seed"]["overworld"]][1] += advancement["time"] - latestReset
				"nether.find_bastion":
					latestSplit[0] = "enter_bastion"
					latestSplit[1] = "bastion"
					currentMatchTimestamps["enter_bastion"] = advancement["time"]
					splits["enter_bastion"][1] += advancement["time"] - latestReset
					splits["enter_bastion"][0] += 1
					splitsDuration["nether_terrain"][1] += currentMatchTimestamps["enter_bastion"] - currentMatchTimestamps["enter_nether"]
					splitsDuration["nether_terrain"][0] += 1
				"nether.find_fortress":
					latestSplit[0] = "enter_fortress"
					latestSplit[1] = "fortress"
					currentMatchTimestamps["enter_fortress"] = advancement["time"]
					splits["enter_fortress"][1] += advancement["time"] - latestReset
					splits["enter_fortress"][0] += 1
					splitsDuration["bastion"][1] += currentMatchTimestamps["enter_fortress"] - currentMatchTimestamps["enter_bastion"]
					splitsDuration["bastion"][0] += 1
					if response["data"]["seed"]["nether"] != null:
						bastionSplits[response["data"]["seed"]["nether"]][0] += 1
						bastionSplits[response["data"]["seed"]["nether"]][1] += currentMatchTimestamps["enter_fortress"] - currentMatchTimestamps["enter_bastion"]
				"projectelo.timeline.blind_travel":
					latestSplit[0] = "blind"
					latestSplit[1] = "blind"
					currentMatchTimestamps["blind"] = advancement["time"]
					splits["blind"][1] += advancement["time"] - latestReset
					splits["blind"][0] += 1
					splitsDuration["fortress"][0] += 1
					splitsDuration["fortress"][1] += currentMatchTimestamps["blind"] - currentMatchTimestamps["enter_fortress"]
				"story.follow_ender_eye":
					latestSplit[0] = "enter_stronghold"
					latestSplit[1] = "stronghold"
					currentMatchTimestamps["enter_stronghold"] = advancement["time"]
					splits["enter_stronghold"][1] += advancement["time"] - latestReset
					splits["enter_stronghold"][0] += 1
					splitsDuration["blind"][0] += 1
					splitsDuration["blind"][1] += currentMatchTimestamps["enter_stronghold"] - currentMatchTimestamps["blind"]
				"story.enter_the_end":
					latestSplit[0] = "enter_end"
					latestSplit[1] = "end"
					currentMatchTimestamps["enter_end"] = advancement["time"]
					splits["enter_end"][1] += advancement["time"] - latestReset
					splits["enter_end"][0] += 1
					splitsDuration["stronghold"][0] += 1
					splitsDuration["stronghold"][1] += currentMatchTimestamps["enter_end"] - currentMatchTimestamps["enter_stronghold"]

	if completed:
		print(matchesParsed)
		splitsDuration["end"][0] += 1
		splitsDuration["end"][1] += gameResult - currentMatchTimestamps["enter_end"]
	else:
		pass
		#if latestSplit[0] != "":
		#	splits[latestSplit[0]][1] -= gameResult - currentMatchTimestamps[latestSplit[0]]
		#	splits[latestSplit[0]][0] -= 1

	matchesParsed += 1
	
	print("Matches: " + str(matchesParsed))
	print("CurrentMatchTimestamps: " + str(currentMatchTimestamps))
	print("Splits: " + str(splits))
	print("Split Durations: " + str(splitsDuration))
	print("Latest Reset: " + str(latestReset))
	print("Latest Split: " + str(latestSplit))
	print("")

func _on_gamemode_option_item_selected(index: int) -> void:
	matchCount = 20
	MatchCountSlider.value = 20
	var Ranked_GetMatches_Request = Ranked_GetMatches.request("https://api.mcsrranked.com/users/" + str(playerUUID) + "/matches?count=" + str(matchCount) + "&type=" + str(index + 2) + "&sort=newest")
	currentGamemode = index + 2

	reload("[center]Loading Splits..")

	if Ranked_GetMatches_Request != OK:
		push_error("An error has occured with the Ranked_GetMatches API request")

func _on_match_count_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		matchCount = int(MatchCountSlider.value)
		var Ranked_GetMatches_Request = Ranked_GetMatches.request("https://api.mcsrranked.com/users/" + str(playerUUID) + "/matches?count=" + str(matchCount) + "&type=" + str(currentGamemode) + "&sort=newest")
		
		reload("[center]Loading Splits..")
		
		if Ranked_GetMatches_Request != OK:
			push_error("An error has occured with the Ranked_GetMatches API request")

func _on_stats_option_item_selected(index: int) -> void:
	if index == 0:
		Splits.visible = true
		Timestamps.visible = false
		Overworlds.visible = false
		Bastions.visible = false
	elif index == 1:
		Splits.visible = false
		Timestamps.visible = true
		Overworlds.visible = false
		Bastions.visible = false
	elif index == 2:
		Splits.visible = false
		Timestamps.visible = false
		Overworlds.visible = true
		Bastions.visible = false
	elif index == 3:
		Splits.visible = false
		Timestamps.visible = false
		Overworlds.visible = false
		Bastions.visible = true
