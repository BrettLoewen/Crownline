@abstract class_name RoadGenerator
extends RefCounted

static func GenerateRoadMeshes(data: Dictionary[Vector2i, RoadData], parent: Node3D) -> void:
	var road: Array[Vector3] = GetRoad(data)
	var curve: Curve3D = GetCurve(road)
	GetMesh(curve, parent)

static func GetRoad(data: Dictionary[Vector2i, RoadData]) -> Array[Vector3]:
	# Turn the road connection data into a linear array of world coordinates
	var road: Array[Vector3] = []
	var point: Vector2i = Vector2i(2, -1)
	var nextPoint: Vector2i = Vector2i(0, 0)
	var coords: Vector3 = Vector3(0, 0, 0)
	var index: int
	while point != null:
		coords = HexToWorldPoint(point)
		road.append(coords)
		if point == Vector2i(-1, 2):
			break
		
		index = 1
		if point == Vector2i(2, -1):
			index = 0
		nextPoint = data[point].connections[index]
		point = nextPoint
	
	return road

static func GetCurve(road: Array[Vector3]) -> Curve3D:
	# Generate a smooth curve for the road
	var curve: Curve3D = Curve3D.new()
	
	var inHandle: Vector3
	var outHandle: Vector3
	var index: int = 0
	for tileCoords in road:
		if index == 0:
			var fakeZeroCoords = 2 * tileCoords - road[index + 1]
			outHandle = (road[index + 1] - fakeZeroCoords) / 6.0
		elif index == road.size() - 1:
			var fakePlusOneCoords = 2 * tileCoords - road[index - 1]
			outHandle = (fakePlusOneCoords - road[index - 1]) / 6.0
		else:
			outHandle = (road[index + 1] - road[index - 1]) / 6.0
		
		inHandle = -outHandle
		curve.add_point(tileCoords, inHandle, outHandle)
		
		index += 1
	
	return curve

static func GetMesh(curve: Curve3D, parent: Node3D) -> void:
	for count in curve.get_baked_length() * 10:
		var dist: float = count / 10.0
		var sampledPoint = curve.sample_baked(dist)
		var mesh: MeshInstance3D = MeshInstance3D.new()
		mesh.mesh = SphereMesh.new()
		mesh.translate(sampledPoint)
		mesh.scale = Vector3.ONE * 0.1
		parent.add_child(mesh)

static func HexToWorldPoint(point: Vector2i) -> Vector3:
	var vec = ConvertGridToHexCoords(point)
	return Vector3(vec.x, 0.21, vec.y)

static func ConvertGridToHexCoords(inputCoords: Vector2i) -> Vector2:
	var tileSize = Vector2(1, 0.87)
	var xOffset = 0
	if inputCoords.y % 2 != 0:
		xOffset = (tileSize.x / 2)
	var tileX = inputCoords.x * tileSize.x + xOffset
	var tileZ = inputCoords.y * tileSize.y
	return Vector2(tileX, tileZ)
