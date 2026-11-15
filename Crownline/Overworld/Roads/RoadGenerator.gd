class_name RoadGenerator
extends Node3D

class RoadSection:
	var roadVectors: Array[Vector3]

@export var roadY: float = 0.21
@export var roadDotY: float = 0.22
@export var intersectionDotY: float = 0.23

@export var roadCurve: float = 6.0
@export var roadDetail: float = 20.0
@export var roadWidth: float = 0.2
@export var roadMaterial: ShaderMaterial

@export var roadDotWidth: float = 0.25
@export var roadDotDetail: int = 20
@export var roadDotMaterial: ShaderMaterial

@export var intersectionDotWidth: float = 0.3
@export var intersectionDotDetail: int = 20
@export var intersectionDotMaterial: ShaderMaterial

func GenerateRoadMeshes(data: Dictionary[Vector2i, RoadData]) -> void:
	var connectionMap: Dictionary[Vector3i, bool] = GetConnections(data)
	var roads: Array[RoadSection] = GetRoadSections(connectionMap, data)
	
	for road in roads:
		var curve: Curve3D = GetCurve(road.roadVectors)
		CreateRoadSectionMesh(curve)
		CreateRoadSectionDotMeshes(road, curve)
	CreateRoadIntersectionDotMeshes(data)

# Grab every road connection (for dead-ends and intersections, not linear paths)
# and key it to a flag to record when a RoadSection is made for it
func GetConnections(data: Dictionary[Vector2i, RoadData]) -> Dictionary[Vector3i, bool]:
	var connectionMap: Dictionary[Vector3i, bool] = {}
	
	for roadCoords in data:
		var numConnections = data[roadCoords].connections.size()
		# Skip road nodes that are just along the path (2 connections)
		if numConnections == 2:
			continue
		for connectionIndex in numConnections:
			var combinedKey = Vector3i(roadCoords.x, roadCoords.y, connectionIndex)
			connectionMap.set(combinedKey, false)
	
	return connectionMap

func GetRoadSections(connectionMap: Dictionary[Vector3i, bool], data: Dictionary[Vector2i, RoadData]) -> Array[RoadSection]:
	var roads: Array[RoadSection] = []
	
	for key in connectionMap:
		# If this connection has already been processed, skip it
		if connectionMap[key]:
			continue
		var section: RoadSection = RoadSection.new()
		var startingCoords: Vector2i = Vector2i(key.x, key.y)
		var currentCoords: Vector2i = startingCoords
		var previousCoords: Vector2i
		while true:
			var coords3d: Vector3 = HexToWorldPoint(currentCoords)
			section.roadVectors.append(coords3d)
			
			# If the current node has non-2 connections (is an intersection) and
			# if more than one node have been added to the road section (isn't the start),
			# then the current coords are the ending node for this road section.
			if data[currentCoords].connections.size() != 2 and section.roadVectors.size() > 1:
				break
			
			var nextIndex = 0
			if currentCoords == startingCoords:
				nextIndex = key.z
			elif data[currentCoords].connections[0] == previousCoords:
				nextIndex = 1
			
			previousCoords = currentCoords
			currentCoords = data[currentCoords].connections[nextIndex]
		
		var backConnectionIndex = 0
		for backConnection in data[currentCoords].connections.size():
			if previousCoords == data[currentCoords].connections[backConnection]:
				backConnectionIndex = backConnection
				break
		
		connectionMap[key] = true
		connectionMap[Vector3i(currentCoords.x, currentCoords.y, backConnectionIndex)] = true
		
		roads.append(section)
	
	return roads

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

func CreateRoadSectionMesh(curve: Curve3D) -> void:
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

func CreateRoadSectionDotMeshes(roadSection: RoadSection, curve: Curve3D) -> void:
	var dotRadius: float = roadDotWidth / 2.0
	
	for point in roadSection.roadVectors:
		var dotPosition: Vector3 = curve.get_closest_point(point)
		
		var st = SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		st.set_uv(Vector2(0, 0))
		st.add_vertex(Vector3(dotPosition.x, roadDotY, dotPosition.z))
		
		for angleStep: int in roadDotDetail + 1:
			var angleRad: float = angleStep * PI * 2.0 / roadDotDetail
			# x = cx + r * cos(a)
			# y = cy + r * sin(a)
			var stepX: float = dotPosition.x + (dotRadius * cos(angleRad))
			var stepZ: float = dotPosition.z + (dotRadius * sin(angleRad))
			
			st.set_uv(Vector2(angleRad, 1))
			st.add_vertex(Vector3(stepX, roadDotY, stepZ))
			
			if angleStep < roadDotDetail:
				st.add_index(0)				# Center
				st.add_index(angleStep + 1)	# This edge coordinate
				st.add_index(angleStep + 2)	# The next edge coordinate
		
		var mesh: ArrayMesh = st.commit()
		var obj: MeshInstance3D = MeshInstance3D.new()
		obj.mesh = mesh
		obj.material_override = roadDotMaterial
		obj.name = "Road Dot - " + str(dotPosition)
		self.add_child(obj)

func CreateRoadIntersectionDotMeshes(data: Dictionary[Vector2i, RoadData]) -> void:
	var dotRadius: float = intersectionDotWidth / 2.0
	
	for road: RoadData in data.values():
		if road.connections.size() == 2:
			continue
		
		var dotPosition: Vector3 = HexToWorldPoint(road.coords)
		
		var st = SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		st.set_uv(Vector2(0, 0))
		st.add_vertex(Vector3(dotPosition.x, intersectionDotY, dotPosition.z))
		
		for angleStep: int in intersectionDotDetail + 1:
			var angleRad: float = angleStep * PI * 2.0 / intersectionDotDetail
			# x = cx + r * cos(a)
			# y = cy + r * sin(a)
			var stepX: float = dotPosition.x + (dotRadius * cos(angleRad))
			var stepZ: float = dotPosition.z + (dotRadius * sin(angleRad))
			
			st.set_uv(Vector2(angleRad, 1))
			st.add_vertex(Vector3(stepX, intersectionDotY, stepZ))
			
			if angleStep < intersectionDotDetail:
				st.add_index(0)				# Center
				st.add_index(angleStep + 1)	# This edge coordinate
				st.add_index(angleStep + 2)	# The next edge coordinate
		
		var mesh: ArrayMesh = st.commit()
		var obj: MeshInstance3D = MeshInstance3D.new()
		obj.mesh = mesh
		obj.material_override = intersectionDotMaterial
		obj.name = "Intersection Dot - " + str(dotPosition)
		self.add_child(obj)

func HexToWorldPoint(point: Vector2i) -> Vector3:
	var vec = ConvertGridToHexCoords(point)
	return Vector3(vec.x, roadY, vec.y)

func ConvertGridToHexCoords(inputCoords: Vector2i) -> Vector2:
	var tileSize = Vector2(1, 0.87)
	var xOffset = 0
	if inputCoords.y % 2 != 0:
		xOffset = (tileSize.x / 2)
	var tileX = inputCoords.x * tileSize.x + xOffset
	var tileZ = inputCoords.y * tileSize.y
	return Vector2(tileX, tileZ)
