class_name OverworldDataManager

static func GetWorldData() -> Dictionary[Vector2i, MapTileType]:
	var data: Dictionary[Vector2i, MapTileType] = _HardcodedWorldDataOne()
	
	return data

# Temporary function for testing map generation
static func _HardcodedWorldDataOne() -> Dictionary[Vector2i, MapTileType]:
	var data: Dictionary[Vector2i, MapTileType] = {}
	
	# load map tile type resource files
	const GrassTileType = preload("res://Overworld/Map Tile Types/Grass.tres")
	const HillTileType = preload("res://Overworld/Map Tile Types/Hill.tres")
	const ForestTileType = preload("res://Overworld/Map Tile Types/Forest.tres")
	const MountainTileType = preload("res://Overworld/Map Tile Types/Mountain.tres")
	const WaterTileType = preload("res://Overworld/Map Tile Types/Water.tres")
	const DesertTileType = preload("res://Overworld/Map Tile Types/Desert.tres")
	
	seed(67)
	
	# fill dictionary with pairs of coordinates and tile types
	for x in range(-4, 5):
		for y in range(-4, 5):
			if x == -4 or x == 4 or y == -4 or y == 4:
				data.set(Vector2i(x, y), WaterTileType)
			elif x >= -1 and x <= 1 and y >= -1 and y <= 1:
				data.set(Vector2i(x, y), DesertTileType)
			elif x == y:
				data.set(Vector2i(x, y), MountainTileType)
			elif abs(x - y) <= 1:
				data.set(Vector2i(x, y), HillTileType)
			else:
				var rand = randi_range(0, 4)
				if rand == 0:
					data.set(Vector2i(x, y), ForestTileType)
				else:
					data.set(Vector2i(x, y), GrassTileType)
	
	return data
