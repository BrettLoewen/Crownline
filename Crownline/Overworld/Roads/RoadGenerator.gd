class_name RoadGenerator
extends Node3D

class RoadSection:
	var roadVectors: Array[Vector3]
	var roadCoords: Array[Vector2i]

# The curve handle at a road tile pointing towards a connected road tile, keyed by
# Vector4i(fromX, fromY, toX, toY). Lets the walkable path follow the road curves beneath it.
var roadHandles: Dictionary[Vector4i, Vector3] = {}

@export var roadY: float = 0.21
@export var roadDotY: float = 0.22
@export var intersectionDotY: float = 0.23
@export var walkablePathY: float = 0.215

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

@export var walkablePathMaterial: ShaderMaterial
@export var arrowLength: float = 0.5
@export var arrowWidth: float = 0.5

func GenerateRoadMeshes(data: Dictionary[Vector2i, RoadData], _includeDots: bool = true) -> void:
	var connectionMap: Dictionary[Vector3i, bool] = GetConnections(data)
	var roads: Array[RoadSection] = GetRoadSections(connectionMap, data)
	
	# Every dot of the same type is an identical circle, so build each mesh once and reuse it
	var roadDotMesh: ArrayMesh = CreateDotMesh(roadDotWidth / 2.0, roadDotDetail)
	var intersectionDotMesh: ArrayMesh = CreateDotMesh(intersectionDotWidth / 2.0, intersectionDotDetail)

	roadHandles.clear()
	var sectionIndex: int = 0
	for road in roads:
		var curve: Curve3D = GetCurve(road.roadVectors)
		SaveRoadHandles(road, curve)
		CreateRoadSectionMesh(curve)
		if _includeDots:
			CreateRoadSectionDotMeshes(road, curve, roadDotMesh, sectionIndex)
		sectionIndex += 1
	if _includeDots:
		CreateRoadIntersectionDotMeshes(data, intersectionDotMesh)

func GenerateWalkablePathMesh(destination: RoadData, start: RoadData) -> Dictionary:
	if destination == start:
		return {}
	var pathCoords: Array[Vector2i] = []
	var current: RoadData = destination
	while current != null:
		pathCoords.append(current.coords)
		current = current.previous
	
	if pathCoords.size() <= 1:
		return {}
	pathCoords.reverse()
	
	# Build the curve from the saved road handles instead of GetCurve so it matches the roads beneath it
	var curve: Curve3D = Curve3D.new()
	for index: int in pathCoords.size():
		var coords: Vector2i = pathCoords[index]
		var inHandle: Vector3 = Vector3.ZERO
		var outHandle: Vector3 = Vector3.ZERO
		if index > 0:
			var prev: Vector2i = pathCoords[index - 1]
			inHandle = roadHandles.get(Vector4i(coords.x, coords.y, prev.x, prev.y), Vector3.ZERO)
		if index < pathCoords.size() - 1:
			var next: Vector2i = pathCoords[index + 1]
			outHandle = roadHandles.get(Vector4i(coords.x, coords.y, next.x, next.y), Vector3.ZERO)
		
		var pos: Vector3 = HexToWorldPoint(coords)
		curve.add_point(Vector3(pos.x, walkablePathY, pos.z), inHandle, outHandle)
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Stop the strip short of the end to leave room for the arrow head
	var numSegments: int = AddCurveStrip(st, curve, curve.get_baked_length() - arrowLength)
	AddArrowHead(st, curve, numSegments)

	return {"mesh": CreateMeshInstance(st, walkablePathMaterial), "curve": curve}

# The road shader colours by UV.y (0.5 = centre, 0 or 1 = edge), so to keep the outline the same
# width as the path, the arrow is an outer triangle with an inner triangle inset by half the road
# width. The band between them gets the edge-to-centre fade and the inner triangle is all fill.
# The path's last right vertex (SR) and a copy of its last left vertex (SL) become the shoulders
# where the outline turns out to the wings. SL is a copy because the path's left edge uses UV.y = 1,
# and blending that into the arrow's UV.y = 0 edges would pass through 0.5 (fill) along the back edge.
#
#                T
#               / \
#              / IT \
#             / /  \ \
#            / /    \ \
#           / IL-M--IR \
#          /  / /|\  \  \
#        WL--SL--C0--SR--WR
#             |      |
#             | path |
func AddArrowHead(st: SurfaceTool, curve: Curve3D, numSegments: int) -> void:
	var dist: float = numSegments / roadDetail
	var halfRoadWidth: float = roadWidth / 2.0
	
	var sampledPoint: Transform3D = curve.sample_baked_with_rotation(dist)
	var baseCenter: Vector3 = sampledPoint.origin
	var tip: Vector3 = curve.sample_baked(curve.get_baked_length())
	var forward: Vector3 = (tip - baseCenter).normalized()
	# Keep the path's sideways direction (so the shoulders line up), just squared up to the arrow
	var right: Vector3 = (sampledPoint.basis.x - forward * sampledPoint.basis.x.dot(forward)).normalized()
	var wingRight: Vector3 = baseCenter + (right * arrowWidth / 2.0)
	var wingLeft: Vector3 = baseCenter + (-right * arrowWidth / 2.0)
	# Same position as the path's last left vertex (see AddCurveStrip)
	var shoulderLeft: Vector3 = baseCenter + (-sampledPoint.basis.x * halfRoadWidth)
	
	# Shrinking a triangle towards its incenter moves every edge inwards by the same distance,
	# so scale it down until the edges sit half a road width in
	var height: float = baseCenter.distance_to(tip)
	var sideLength: float = Vector2(arrowWidth / 2.0, height).length()
	var inradius: float = (arrowWidth * height) / (arrowWidth + (2.0 * sideLength))
	var incenter: Vector3 = baseCenter + (forward * inradius)
	var innerScale: float = max(inradius - halfRoadWidth, 0.0) / inradius
	var innerRight: Vector3 = incenter + ((wingRight - incenter) * innerScale)
	var innerLeft: Vector3 = incenter + ((wingLeft - incenter) * innerScale)
	var innerTip: Vector3 = incenter + ((tip - incenter) * innerScale)
	var innerBase: Vector3 = baseCenter + (forward * halfRoadWidth)
	
	var arrowPoints: Array[Vector3] = [baseCenter, wingRight, tip, wingLeft, innerBase, innerRight, innerTip, innerLeft, shoulderLeft]
	var arrowUVs: Array[float] = [0.5, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 0.5, 0.0]
	for index: int in arrowPoints.size():
		st.set_uv(Vector2(dist, arrowUVs[index]))
		st.add_vertex(arrowPoints[index])
	
	# Vertex indices, continuing on from the path strip's vertices
	var pathRightIndex: int = 2 * numSegments				# SR
	var baseCenterIndex: int = (numSegments + 1) * 2		# C0
	var wingRightIndex: int = baseCenterIndex + 1			# WR
	var tipIndex: int = baseCenterIndex + 2				# T
	var wingLeftIndex: int = baseCenterIndex + 3			# WL
	var innerBaseIndex: int = baseCenterIndex + 4			# M
	var innerRightIndex: int = baseCenterIndex + 5		# IR
	var innerTipIndex: int = baseCenterIndex + 6			# IT
	var innerLeftIndex: int = baseCenterIndex + 7			# IL
	var shoulderLeftIndex: int = baseCenterIndex + 8		# SL
	
	# Clockwise-winding triangles, same as the path strip
	var arrowIndices: Array[int] = [
		pathRightIndex, baseCenterIndex, innerBaseIndex,	# Right shoulder (turns the outline corner)
		shoulderLeftIndex, innerBaseIndex, baseCenterIndex,	# Left shoulder
		pathRightIndex, innerBaseIndex, innerRightIndex,	# Right back edge
		pathRightIndex, innerRightIndex, wingRightIndex,
		shoulderLeftIndex, innerLeftIndex, innerBaseIndex,	# Left back edge
		shoulderLeftIndex, wingLeftIndex, innerLeftIndex,
		wingRightIndex, innerRightIndex, innerTipIndex,		# Right side
		wingRightIndex, innerTipIndex, tipIndex,
		wingLeftIndex, tipIndex, innerTipIndex,				# Left side
		wingLeftIndex, innerTipIndex, innerLeftIndex,
		innerBaseIndex, innerTipIndex, innerRightIndex,		# Inner fill
		innerBaseIndex, innerLeftIndex, innerTipIndex,
	]
	for index: int in arrowIndices:
		st.add_index(index)

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
			section.roadCoords.append(currentCoords)
			
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

# Record the handles of each step along the section in both directions, so a path travelling
# either way along this road can rebuild the same curve
func SaveRoadHandles(roadSection: RoadSection, curve: Curve3D) -> void:
	for index: int in roadSection.roadCoords.size() - 1:
		var from: Vector2i = roadSection.roadCoords[index]
		var to: Vector2i = roadSection.roadCoords[index + 1]
		roadHandles.set(Vector4i(from.x, from.y, to.x, to.y), curve.get_point_out(index))
		roadHandles.set(Vector4i(to.x, to.y, from.x, from.y), curve.get_point_in(index + 1))

func CreateRoadSectionMesh(curve: Curve3D) -> void:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	AddCurveStrip(st, curve, curve.get_baked_length())
	CreateMeshInstance(st, roadMaterial)

# Adds a road-width strip along the curve, from its start up to the given length.
# Returns the number of segments so extra vertices (like an arrow head) can be indexed after it.
func AddCurveStrip(st: SurfaceTool, curve: Curve3D, length: float) -> int:
	# Loop along the curve sampling a number of points, the number determined by roadDetail.
	# Plus one makes sure the end point is also included (inclusive vs exclusive).
	var numSegments = int(length * roadDetail)
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

	return numSegments

func CreateMeshInstance(st: SurfaceTool, material: ShaderMaterial) -> MeshInstance3D:
	var mesh: ArrayMesh = st.commit()
	var obj: MeshInstance3D = MeshInstance3D.new()
	obj.mesh = mesh
	obj.material_override = material
	self.add_child(obj)
	return obj

# Builds a flat circle centred on the origin. Each dot node is moved into place with its
# position, so one mesh can be shared by every dot of the same size.
func CreateDotMesh(dotRadius: float, dotDetail: int) -> ArrayMesh:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_uv(Vector2(0, 0))
	st.add_vertex(Vector3.ZERO)

	for angleStep: int in dotDetail + 1:
		var angleRad: float = angleStep * PI * 2.0 / dotDetail
		# x = cx + r * cos(a)		(but cx is 0)
		# y = cy + r * sin(a)		(but cx is 0)
		var stepX: float = dotRadius * cos(angleRad)
		var stepZ: float = dotRadius * sin(angleRad)

		st.set_uv(Vector2(angleRad, 1))
		st.add_vertex(Vector3(stepX, 0, stepZ))

		if angleStep < dotDetail:
			st.add_index(0)				# Center
			st.add_index(angleStep + 1)	# This edge coordinate
			st.add_index(angleStep + 2)	# The next edge coordinate

	return st.commit()

func CreateRoadSectionDotMeshes(roadSection: RoadSection, curve: Curve3D, dotMesh: ArrayMesh, sectionIndex: int) -> void:
	var pointIndex: int = 0
	for point in roadSection.roadVectors:
		var dotPosition: Vector3 = curve.get_closest_point(point)

		var obj: MeshInstance3D = MeshInstance3D.new()
		obj.mesh = dotMesh
		obj.material_override = roadDotMaterial
		obj.position = Vector3(dotPosition.x, roadDotY, dotPosition.z)
		obj.name = "Road Dot - Section " + str(sectionIndex) + " Point " + str(pointIndex)
		self.add_child(obj)

		pointIndex += 1

func CreateRoadIntersectionDotMeshes(data: Dictionary[Vector2i, RoadData], dotMesh: ArrayMesh) -> void:
	for road: RoadData in data.values():
		if road.connections.size() == 2:
			continue

		var dotPosition: Vector3 = HexToWorldPoint(road.coords)

		var obj: MeshInstance3D = MeshInstance3D.new()
		obj.mesh = dotMesh
		obj.material_override = intersectionDotMaterial
		obj.position = Vector3(dotPosition.x, intersectionDotY, dotPosition.z)
		obj.name = "Intersection Dot - " + str(road.coords)
		self.add_child(obj)

func HexToWorldPoint(point: Vector2i) -> Vector3:
	var vec: Vector2 = HexMath.GridToWorld(point)
	return Vector3(vec.x, roadY, vec.y)
