@abstract class_name HexMath
extends RefCounted

# Shared conversions between hex grid coordinates and world space.
# Rows are offset: odd rows shift right by half a tile.

const TileSize: Vector2 = Vector2(1, 0.87)

# Returns the world X/Z position of the centre of a grid tile
static func GridToWorld(gridCoords: Vector2i) -> Vector2:
	var xOffset: float = 0.0
	if gridCoords.y % 2 != 0:
		xOffset = TileSize.x / 2.0
	var worldX: float = gridCoords.x * TileSize.x + xOffset
	var worldZ: float = gridCoords.y * TileSize.y
	return Vector2(worldX, worldZ)
