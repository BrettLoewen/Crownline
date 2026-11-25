@tool
extends EditorScenePostImport

# Runs after an animation FBX is reimported (set as the file's import_script/path).
# Some clips move the hips forward slowly over the loop on top of the root motion,
# so the hips snap back when the loop restarts. This removes that straight-line
# horizontal drift so the last key lines up with the first, keeping the sway and bob.

const HIPS_TRACK: NodePath = NodePath("%GeneralSkeleton:Hips")

func _post_import(scene: Node) -> Object:
	for player: AnimationPlayer in scene.find_children("*", "AnimationPlayer", true, false):
		for animationName: StringName in player.get_animation_list():
			var animation: Animation = player.get_animation(animationName)
			if RemoveDrift(animation):
				# Animations saved to their own .anim file were already written before this script ran
				if animation.resource_path.ends_with(".anim"):
					ResourceSaver.save(animation, animation.resource_path)
	return scene

func RemoveDrift(animation: Animation) -> bool:
	var track: int = animation.find_track(HIPS_TRACK, Animation.TYPE_POSITION_3D)
	if track == -1 or animation.length <= 0.0:
		return false
	var keyCount: int = animation.track_get_key_count(track)
	if keyCount < 2:
		return false
	var first: Vector3 = animation.track_get_key_value(track, 0)
	var last: Vector3 = animation.track_get_key_value(track, keyCount - 1)
	var drift: Vector3 = last - first
	drift.y = 0.0
	for key: int in keyCount:
		var progress: float = animation.track_get_key_time(track, key) / animation.length
		var value: Vector3 = animation.track_get_key_value(track, key)
		animation.track_set_key_value(track, key, value - drift * progress)
	return true
