class_name CityControlUI
extends MarginContainer

signal closeClicked
signal cityUpdated

@export var cityNameLabel: RichTextLabel
@export var currentBuildingParent: Control
@export var newBuildingParent: Control
@export var cityBuildingButtonScene: PackedScene

# For early development, replace later
@export var buildings: Array[Building]

var cityData: CityData

func Setup(newCityData: CityData) -> void:
	cityData = newCityData
	cityNameLabel.text = cityData.name
	
	# Detach as well as free so the old buttons are gone from the layout immediately
	for child: Node in currentBuildingParent.get_children():
		currentBuildingParent.remove_child(child)
		child.queue_free()
	for child: Node in newBuildingParent.get_children():
		newBuildingParent.remove_child(child)
		child.queue_free()
	
	for building: Building in buildings:
		if building.CityMeetsPrerequisites(cityData):
			if cityData.HasBuilding(building):
				var buildingButton: CityBuildingButton = cityBuildingButtonScene.instantiate() as CityBuildingButton
				if buildingButton != null:
					buildingButton.SetupCurrentBuilding(cityData.GetBuildingData(building))
					buildingButton.buttonClicked.connect(_on_building_button_clicked)
					currentBuildingParent.add_child(buildingButton)
			else:
				var buildingButton: CityBuildingButton = cityBuildingButtonScene.instantiate() as CityBuildingButton
				if buildingButton != null:
					buildingButton.SetupNewBuilding(building)
					buildingButton.buttonClicked.connect(_on_building_button_clicked)
					newBuildingParent.add_child(buildingButton)

func Refresh() -> void:
	Setup(cityData)

func _on_building_button_clicked(building: Building, mode: CityBuildingButton.BuildingButtonMode) -> void:
	if mode == CityBuildingButton.BuildingButtonMode.CURRENT_BUILDING:
		print("Current building, doing nothing for now")
	else:
		var buildingData: BuildingData = BuildingData.new(building)
		cityData.buildings.append(buildingData)
		cityData.mapCity.UpdateCityVisuals()
		cityUpdated.emit()

func _on_close_button_pressed() -> void:
	closeClicked.emit()
