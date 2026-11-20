"""Builds ModularCharacter.blend from Synty's ModularCharacters.fbx.

You normally run this only once, or again to rebuild the .blend from scratch. It overwrites
ModularCharacter.blend, so anything added by hand in Blender is lost.

    "C:\\Program Files\\Blender Foundation\\Blender 5.3\\blender.exe" -b --factory-startup --python "Modular Character\\Scripts\\BuildBlend.py"

What it does to the raw FBX:
- Applies the FBX's 0.01 scale and 90 degree rotation, so the armature and every mesh sit at scale 1
  in metres (character about 1.8 m tall, facing -Y).
- Renames the finger bones. Synty gives both hands the same names (Thumb_01, ...), so Blender
  renamed the right hand Thumb_01.001. They become Thumb_01_L / Thumb_01_R and so on.
- Deletes the empty grouping nodes, which hold no meshes once imported, and sorts the 720 meshes
  into collections by slot (Chr_Head_Male, Chr_Hair, ...), so the Outliner is browsable.
- Gives everything one material, "PolygonFantasyHero", using the Texture_01_A atlas, so it looks
  right in Blender. Godot replaces this material on import with the recolouring shader.
"""
import os
import re

import bpy

ModularDir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SourceFbx = os.path.join(ModularDir, "Source", "Models", "ModularCharacters.fbx")
BaseTexture = os.path.join(ModularDir, "Source", "Textures", "PolygonFantasyHero_Texture_01_A.png")
BlendPath = os.path.join(ModularDir, "ModularCharacter.blend")

ArmatureName = "Armature"
MaterialName = "PolygonFantasyHero"
FingerBones = ("Thumb_", "IndexFinger_", "Finger_")


def ImportFbx():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.fbx(filepath=SourceFbx, use_custom_normals=True)


def ApplyTransforms(armature):
    bpy.ops.object.select_all(action="DESELECT")
    meshes = [o for o in bpy.data.objects if o.type == "MESH"]
    for obj in [armature] + meshes:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = armature
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)


def RenameFingerBones(armature):
    """Left hand keeps Blender's plain name, right hand got .001. Vertex groups follow bone renames."""
    for bone in armature.data.bones:
        if not bone.name.startswith(FingerBones):
            continue
        if bone.name.endswith(".001"):
            bone.name = bone.name[:-4] + "_R"
        else:
            bone.name = bone.name + "_L"


def RemoveEmpties():
    for obj in [o for o in bpy.data.objects if o.type == "EMPTY"]:
        bpy.data.objects.remove(obj)


def SortIntoCollections(armature):
    """One collection per slot, e.g. Chr_Head_Male_03 -> collection Chr_Head_Male."""
    root = bpy.context.scene.collection
    character = bpy.data.collections.new("ModularCharacter")
    root.children.link(character)
    parts = bpy.data.collections.new("Parts")
    character.children.link(parts)

    for coll in list(armature.users_collection):
        coll.objects.unlink(armature)
    character.objects.link(armature)

    slots = {}
    for obj in sorted((o for o in bpy.data.objects if o.type == "MESH"), key=lambda o: o.name):
        slotName = re.sub(r"_\d+$", "", obj.name)
        if slotName not in slots:
            slots[slotName] = bpy.data.collections.new(slotName)
            parts.children.link(slots[slotName])
        for coll in list(obj.users_collection):
            coll.objects.unlink(obj)
        slots[slotName].objects.link(obj)

    # Clean up the importer's leftover collections.
    for coll in list(bpy.data.collections):
        if coll is not character and coll is not parts and coll not in slots.values() and not coll.objects:
            bpy.data.collections.remove(coll)


def SetUpMaterial():
    material = bpy.data.materials.new(MaterialName)
    material.use_nodes = True
    nodes = material.node_tree.nodes
    bsdf = nodes.get("Principled BSDF")
    bsdf.inputs["Roughness"].default_value = 0.8
    image = bpy.data.images.load(BaseTexture)
    image.filepath = bpy.path.relpath(BaseTexture, start=ModularDir)
    texture = nodes.new("ShaderNodeTexImage")
    texture.image = image
    texture.location = (-400, 300)
    material.node_tree.links.new(texture.outputs["Color"], bsdf.inputs["Base Color"])

    for obj in (o for o in bpy.data.objects if o.type == "MESH"):
        obj.data.materials.clear()
        obj.data.materials.append(material)

    for old in [m for m in bpy.data.materials if m is not material]:
        bpy.data.materials.remove(old)
    for old in [i for i in bpy.data.images if i is not image]:
        bpy.data.images.remove(old)


def HideAllButDefaultLook():
    """Show one body in the viewport so the .blend opens readable instead of 720 overlapping meshes.
    Only viewport visibility changes: the exporter still writes every mesh."""
    shown = {"Chr_Head_Male_01", "Chr_Hair_01", "Chr_Eyebrow_Male_01", "Chr_Torso_Male_01",
             "Chr_ArmUpperRight_Male_01", "Chr_ArmUpperLeft_Male_01", "Chr_ArmLowerRight_Male_01",
             "Chr_ArmLowerLeft_Male_01", "Chr_HandRight_Male_01", "Chr_HandLeft_Male_01",
             "Chr_Hips_Male_01", "Chr_LegRight_Male_01", "Chr_LegLeft_Male_01"}
    for obj in (o for o in bpy.data.objects if o.type == "MESH"):
        obj.hide_set(obj.name not in shown)


def Main():
    ImportFbx()
    armature = next(o for o in bpy.data.objects if o.type == "ARMATURE")
    RemoveEmpties()
    armature.name = ArmatureName
    armature.data.name = ArmatureName
    ApplyTransforms(armature)
    RenameFingerBones(armature)
    SortIntoCollections(armature)
    SetUpMaterial()
    HideAllButDefaultLook()
    bpy.ops.wm.save_as_mainfile(filepath=BlendPath, relative_remap=True)
    print(f"BuildBlend: saved {BlendPath}")


Main()
