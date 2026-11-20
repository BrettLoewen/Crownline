"""Exports ModularCharacter.blend to the Godot project as the "Modular Character" package.

Run it either way:
- From PowerShell:  & "Modular Character\\Scripts\\ExportToGodot.ps1"
- Inside Blender, with ModularCharacter.blend open: Scripting tab > Open this file > Run Script.
  (Save the .blend first if you want the changes kept. The export uses what's in the open scene.)

Output: Crownline/Packages/Modular Character/
    ModularCharacter.fbx         armature + every mesh in the "ModularCharacter" collection
    PolygonCharacter.gdshader    the mask-based recolouring shader (copied from Modular Character/Godot/)
    PolygonCharacter.tres        ShaderMaterial with the atlas and masks assigned
    Textures/, Masks/            Synty atlases and recolour masks

Overwritten on every export: the .fbx, the shader, and textures/masks (only when the bytes changed,
so Godot doesn't reimport for nothing).
Written only when missing, so changes made in Godot survive re-exports: PolygonCharacter.tres and
the .import files (import settings). Delete one to have it regenerated with the defaults below.

Only objects inside the "ModularCharacter" collection (and its child collections) are exported.
Keep work-in-progress meshes in another collection to leave them out.
"""
import filecmp
import os
import shutil
import sys

import bpy


def FindModularDir():
    if bpy.data.filepath:
        return os.path.dirname(bpy.data.filepath)
    return os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


ModularDir = FindModularDir()
BlendPath = os.path.join(ModularDir, "ModularCharacter.blend")
GodotProject = os.path.join(os.path.dirname(ModularDir), "Crownline")
PackageName = "Modular Character"
PackageDir = os.path.join(GodotProject, "Packages", PackageName)
PackageRes = f"res://Packages/{PackageName}"

ExportCollection = "ModularCharacter"
MaterialName = "PolygonFantasyHero"     # material name in the .blend, remapped in Godot
FbxName = "ModularCharacter.fbx"
ShaderName = "PolygonCharacter.gdshader"
GodotMaterialName = "PolygonCharacter.tres"
BaseTextureName = "PolygonFantasyHero_Texture_01_A.png"
MaskNames = [f"PolygonFantasyHero_Texture_Mask_0{i}.png" for i in range(1, 6)]


# ---------------------------------------------------------------- files

def CopyIfChanged(source, destination):
    if os.path.exists(destination) and filecmp.cmp(source, destination, shallow=False):
        return False
    os.makedirs(os.path.dirname(destination), exist_ok=True)
    shutil.copy2(source, destination)
    return True


def WriteIfMissing(path, text):
    if os.path.exists(path):
        return False
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8", newline="\n") as file:
        file.write(text)
    return True


def CopyFolder(sourceDir, destinationDir):
    copied = 0
    for name in sorted(os.listdir(sourceDir)):
        if name.lower().endswith(".png"):
            copied += CopyIfChanged(os.path.join(sourceDir, name), os.path.join(destinationDir, name))
            WriteIfMissing(os.path.join(destinationDir, name + ".import"), TextureImport())
    return copied


# ---------------------------------------------------------------- import settings

def TextureImport():
    """Lossless and no mipmaps: VRAM compression and mip blending smear the mask edges, which
    makes recolour regions bleed into each other."""
    return """[remap]

importer="texture"
type="CompressedTexture2D"

[params]

compress/mode=0
compress/high_quality=false
compress/lossy_quality=0.7
compress/uastc_level=0
compress/rdo_quality_loss=0.0
compress/hdr_compression=1
compress/normal_map=0
compress/channel_pack=0
mipmaps/generate=false
mipmaps/limit=-1
roughness/mode=0
roughness/src_normal=""
process/channel_remap/red=0
process/channel_remap/green=1
process/channel_remap/blue=2
process/channel_remap/alpha=3
process/fix_alpha_border=true
process/premult_alpha=false
process/normal_map_invert_y=false
process/hdr_as_srgb=false
process/hdr_clamp_exposure=false
process/size_limit=0
detect_3d/compress_to=0
"""


def FbxImport():
    """Every surface gets PolygonCharacter.tres instead of the FBX's own material."""
    return f"""[remap]

importer="scene"
importer_version=1
type="PackedScene"

[params]

nodes/root_type=""
nodes/root_name="ModularCharacter"
nodes/root_script=null
mesh_library/use_node_names_as_mesh_names=false
array_mesh/deduplicate_surfaces=true
nodes/apply_root_scale=true
nodes/root_scale=1.0
nodes/import_as_skeleton_bones=false
nodes/use_name_suffixes=true
nodes/use_node_type_suffixes=true
meshes/ensure_tangents=false
meshes/generate_lods=true
meshes/create_shadow_meshes=true
meshes/light_baking=1
meshes/lightmap_texel_size=0.2
meshes/force_disable_compression=false
skins/use_named_skins=true
animation/import=false
animation/fps=30
animation/trimming=true
animation/remove_immutable_tracks=true
animation/import_rest_as_RESET=false
import_script/path=""
materials/extract=0
materials/extract_format=0
materials/extract_path=""
_subresources={{
"materials": {{
"{MaterialName}": {{
"use_external/enabled": true,
"use_external/fallback_path": "{PackageRes}/{GodotMaterialName}",
"use_external/path": "{PackageRes}/{GodotMaterialName}"
}}
}}
}}
fbx/importer=0
fbx/allow_geometry_helper_nodes=false
fbx/embedded_image_handling=0
fbx/naming_version=2
"""


def GodotMaterial():
    lines = [
        f'[gd_resource type="ShaderMaterial" format=3]',
        "",
        f'[ext_resource type="Shader" path="{PackageRes}/{ShaderName}" id="Shader"]',
        f'[ext_resource type="Texture2D" path="{PackageRes}/Textures/{BaseTextureName}" id="BaseTexture"]',
    ]
    for index, mask in enumerate(MaskNames, start=1):
        lines.append(f'[ext_resource type="Texture2D" path="{PackageRes}/Masks/{mask}" id="Mask0{index}"]')
    lines += ["", "[resource]", 'resource_name = "PolygonCharacter"', 'shader = ExtResource("Shader")',
              'shader_parameter/BaseTexture = ExtResource("BaseTexture")']
    for index in range(1, len(MaskNames) + 1):
        lines.append(f'shader_parameter/Mask0{index} = ExtResource("Mask0{index}")')
    return "\n".join(lines) + "\n"


# ---------------------------------------------------------------- fbx

def CollectExportObjects():
    collection = bpy.data.collections.get(ExportCollection)
    if collection is None:
        raise RuntimeError(f'No "{ExportCollection}" collection in the .blend')
    return [o for o in collection.all_objects if o.type in {"ARMATURE", "MESH"}]


def UnlinkTextures():
    """Cuts image texture links so the FBX names its materials without referencing image files.
    Godot swaps the material for PolygonCharacter.tres anyway, and a texture reference only makes
    it go looking for the file. Returns the links so they can be restored after the export."""
    removed = []
    for material in bpy.data.materials:
        if not material.node_tree:
            continue
        for link in list(material.node_tree.links):
            if link.from_node.type == "TEX_IMAGE":
                removed.append((material.node_tree, link.from_socket, link.to_socket))
                material.node_tree.links.remove(link)
    return removed


def RestoreTextures(removed):
    for tree, fromSocket, toSocket in removed:
        tree.links.new(fromSocket, toSocket)


def ExportFbx(path):
    objects = CollectExportObjects()
    viewLayer = bpy.context.view_layer
    hidden = {o.name for o in objects if o.hide_get()}
    if bpy.context.object and bpy.context.object.mode != "OBJECT":
        bpy.ops.object.mode_set(mode="OBJECT")
    removedLinks = UnlinkTextures()
    try:
        bpy.ops.object.select_all(action="DESELECT")
        for obj in objects:
            obj.hide_set(False)
            obj.select_set(True)
        viewLayer.objects.active = next(o for o in objects if o.type == "ARMATURE")
        os.makedirs(os.path.dirname(path), exist_ok=True)
        bpy.ops.export_scene.fbx(
            filepath=path,
            use_selection=True,
            object_types={"ARMATURE", "MESH"},
            use_mesh_modifiers=False,       # the Armature modifier would bake the current pose in
            mesh_smooth_type="FACE",
            use_custom_props=False,
            add_leaf_bones=False,
            primary_bone_axis="Y",
            secondary_bone_axis="X",
            armature_nodetype="NULL",
            apply_unit_scale=True,
            apply_scale_options="FBX_SCALE_ALL",
            axis_forward="-Z",
            axis_up="Y",
            bake_anim=False,
            path_mode="STRIP",
            embed_textures=False,
        )
    finally:
        RestoreTextures(removedLinks)
        for obj in objects:
            obj.select_set(False)
            obj.hide_set(obj.name in hidden)
    return len(objects)


# ---------------------------------------------------------------- main

def Main():
    if not bpy.data.filepath:
        bpy.ops.wm.open_mainfile(filepath=BlendPath)
    if not os.path.isfile(os.path.join(GodotProject, "project.godot")):
        raise RuntimeError(f"Godot project not found at {GodotProject}")

    fbxPath = os.path.join(PackageDir, FbxName)
    count = ExportFbx(fbxPath)
    WriteIfMissing(fbxPath + ".import", FbxImport())

    CopyIfChanged(os.path.join(ModularDir, "Godot", ShaderName), os.path.join(PackageDir, ShaderName))
    textures = CopyFolder(os.path.join(ModularDir, "Source", "Textures"), os.path.join(PackageDir, "Textures"))
    masks = CopyFolder(os.path.join(ModularDir, "Source", "Masks"), os.path.join(PackageDir, "Masks"))
    WriteIfMissing(os.path.join(PackageDir, GodotMaterialName), GodotMaterial())

    print(f"ExportToGodot: {count} objects -> {fbxPath}")
    print(f"ExportToGodot: {textures} texture(s) and {masks} mask(s) updated in {PackageDir}")


Main()
