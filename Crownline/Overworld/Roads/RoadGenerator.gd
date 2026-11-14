class_name RoadGenerator
extends Node3D

@export var roadCurve: float = 6.0
@export var roadDetail: float = 20.0
@export var roadWidth: float = 0.2
@export var roadMaterial: ShaderMaterial

func GenerateRoadMeshes(data: Dictionary[Vector2i, RoadData]) -> void:
	var road: Array[Vector3] = GetRoad(data)
	var curve: Curve3D = GetCurve(road)
	GetMesh(curve)

func GetRoad(data: Dictionary[Vector2i, RoadData]) -> Array[Vector3]:
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

func GetCurve(road: Array[Vector3]) -> Curve3D:
	# Generate a smooth curve for the road
	var curve: Curve3D = Curve3D.new()
	
	var inHandle: Vector3
	var outHandle: Vector3
	var index: int = 0
	for tileCoords in road:
		if index == 0:
			var fakeZeroCoords = 2 * tileCoords - road[index + 1]
			outHandle = (road[index + 1] - fakeZeroCoords) / roadCurve
		elif index == road.size() - 1:
			var fakePlusOneCoords = 2 * tileCoords - road[index - 1]
			outHandle = (fakePlusOneCoords - road[index - 1]) / roadCurve
		else:
			outHandle = (road[index + 1] - road[index - 1]) / roadCurve
		
		inHandle = -outHandle
		curve.add_point(tileCoords, inHandle, outHandle)
		
		index += 1
	
	return curve

func GetMesh(curve: Curve3D) -> void:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Loop along the curve sampling a number of points, the number determined by roadDetail.
	# Plus one makes sure the end point is also included (inclusive vs exclusive).
	var numSegments = int(curve.get_baked_length() * roadDetail)
	for step: int in numSegments + 1:
		var dist: float = step / roadDetail
		var sampledPoint: Transform3D = curve.sample_baked_with_rotation(dist)
		
		# Start at the sampled point, add offset by half the width using the point's rotation (basis)
		var rightPoint: Vector3 = sampledPoint.origin + (sampledPoint.basis.x * roadWidth / 2.0)
		var leftPoint: Vector3 = sampledPoint.origin + (-sampledPoint.basis.x * roadWidth / 2.0)
		
		st.set_uv(Vector2(dist, 0))
		st.add_vertex(rightPoint)
		st.set_uv(Vector2(dist, 1))
		st.add_vertex(leftPoint)
		
		# Vertices get added linearly (right, left, right, left, etc.) and need to get combined into
		# clockwise-winding triangles for the mesh
		# L0 ---- L1
		# |       |
		# R0 ---- R1     (road heading → this way)
		# 
		# L(i == 1) ---- L(i == 3)
		# |              |
		# R(i == 0) ---- R(i == 2)
		# 
		# L((2*step)+1) ---- L((2*(step+1))+1)
		# |                  |
		# R(2*step) -------- R(2*(step+1))
		# 
		# Triangle 1: R(2*step), L((2*step)+1), L((2*(step+1))+1)
		# Triangle 2: L((2*(step+1))+1), R(2*(step+1)), R(2*step)
		if step < numSegments:
			st.add_index(2 * step)					# R0
			st.add_index((2 * step) + 1)			# L0
			st.add_index((2 * (step + 1)) + 1)		# L1
			st.add_index((2 * (step + 1)) + 1)		# L1
			st.add_index(2 * (step + 1))			# R1
			st.add_index(2 * step)					# R0
	
	var mesh: ArrayMesh = st.commit()
	var obj: MeshInstance3D = MeshInstance3D.new()
	obj.mesh = mesh
	obj.material_override = roadMaterial
	self.add_child(obj)

func HexToWorldPoint(point: Vector2i) -> Vector3:
	var vec = ConvertGridToHexCoords(point)
	return Vector3(vec.x, 0.21, vec.y)

func ConvertGridToHexCoords(inputCoords: Vector2i) -> Vector2:
	var tileSize = Vector2(1, 0.87)
	var xOffset = 0
	if inputCoords.y % 2 != 0:
		xOffset = (tileSize.x / 2)
	var tileX = inputCoords.x * tileSize.x + xOffset
	var tileZ = inputCoords.y * tileSize.y
	return Vector2(tileX, tileZ)
