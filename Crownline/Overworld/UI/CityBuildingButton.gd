class_name CityBuildingButton
extends PanelContainer

enum BuildingButtonMode {NEW_BUILDING, CURRENT_BUILDING}

signal buttonClicked(building: Building, mode: BuildingButtonMode)

@export var nameLabel: RichTextLabel
@export var turnsToBuildLabel: RichTextLabel

var mode: BuildingButtonMode
var building: Building
var currentBuildingData: BuildingData

func SetupNewBuilding(newBuilding: Building) -> void:
	mode = BuildingButtonMode.NEW_BUILDING
	building = newBuilding
	nameLabel.text = building.name
	turnsToBuildLabel.text = str(building.turnsToBuild) + " Turns"

func SetupCurrentBuilding(newBuildingData: BuildingData) -> void:
	mode = BuildingButtonMode.CURRENT_BUILDING
	currentBuildingData = newBuildingData
	building = currentBuildingData.building
	nameLabel.text = building.name
	if currentBuildingData.turnsToBuild > 0:
		turnsToBuildLabel.text = str(currentBuildingData.turnsToBuild) + " Turns Left"
	else:
		turnsToBuildLabel.text = ""

func _on_button_pressed() -> void:
	buttonClicked.emit(building, mode)
