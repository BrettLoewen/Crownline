class_name CityBuildingButton
extends PanelContainer

enum BuildingButtonMode {NEW_BUILDING, CURRENT_BUILDING}

signal buttonClicked(Building, BuildingButtonMode)

@export var nameLabel: RichTextLabel
@export var turnsToBuildLabel: RichTextLabel

var mode: BuildingButtonMode
var buildingData: Building
var currentBuildingData: CityData.BuildingData

func SetupNewBuilding(newBuildingData: Building) -> void:
	mode = BuildingButtonMode.NEW_BUILDING
	buildingData = newBuildingData
	nameLabel.text = buildingData.name
	turnsToBuildLabel.text = str(buildingData.turnsToBuild) + " Turns"

func SetupCurrentBuilding(newBuildingData: CityData.BuildingData) -> void:
	mode = BuildingButtonMode.CURRENT_BUILDING
	currentBuildingData = newBuildingData
	buildingData = currentBuildingData.building
	nameLabel.text = buildingData.name
	if currentBuildingData.turnsToBuild > 0:
		turnsToBuildLabel.text = ""
	else:
		turnsToBuildLabel.text = str(currentBuildingData.turnsToBuild) + " Turns Left"

func _on_button_pressed() -> void:
	buttonClicked.emit(buildingData, mode)
