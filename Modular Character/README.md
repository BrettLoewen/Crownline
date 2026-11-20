# Modular Character

Source workspace for the Synty POLYGON Fantasy Hero modular character (plus any custom parts added
later). The game never reads this folder. It reads the exported package at
`Crownline/Packages/Modular Character/`.

```
Modular Character/
  ModularCharacter.blend      working file: one armature + every part mesh
  Source/                     untouched copies from the Synty Unity package
    Models/ModularCharacters.fbx   (the FixedScale version)
    Textures/                 colour atlases (01_A is the default the shader uses)
    Masks/                    recolour masks (01-05 used, 06 unused)
    Weapons/                  weapon FBXs, not exported yet
    UnityReference/           Synty's Unity shader and randomizer script, for reference only
  Godot/
    PolygonCharacter.gdshader recolouring shader; copied into the package on export
  Scripts/
    BuildBlend.py             rebuilds ModularCharacter.blend from Source/ (overwrites it)
    ExportToGodot.py          exports the .blend into the Godot package
    ExportToGodot.ps1         runs the above in background Blender
```

## Exporting
```powershell
& "Modular Character\Scripts\ExportToGodot.ps1"
```
Or open the .blend in Blender and run `Scripts/ExportToGodot.py` from the Scripting tab. Then switch
to the Godot editor and it reimports the package.

Only objects inside the `ModularCharacter` collection are exported, so keep work-in-progress meshes in
another collection.

| Package file | On re-export |
|---|---|
| `ModularCharacter.fbx` | overwritten |
| `PolygonCharacter.gdshader` | overwritten from `Godot/` (edit it here, not in Godot) |
| `Textures/`, `Masks/` | overwritten when the source file changed |
| `PolygonCharacter.tres` | created once; Godot-side edits are kept |
| `*.import` (import settings) | created once; Godot-side edits are kept. Delete one to regenerate it |

## What's in the .blend
- Armature `Armature` with 63 bones, at scale 1, in metres, facing -Y (Blender front). The character is
  about 1.87 m tall with feet at 0.
- Finger bones are renamed `Thumb_01_L` / `Thumb_01_R` etc. In Synty's FBX both hands share the same
  names, which Blender turned into `.001` suffixes.
- 720 skinned meshes, one per part, sorted into collections by slot under `ModularCharacter/Parts`.
  All are exported; viewport visibility doesn't matter. The .blend opens showing one default body.
- One material, `PolygonFantasyHero`, showing the `01_A` atlas in Blender. Godot swaps it for the
  recolouring material on import, matched by that name, so new parts must use this material too.

## In Godot
`res://Packages/Modular Character/ModularCharacter.fbx` imports as:
```
ModularCharacter (Node3D)
  Armature (Node3D, rotated -90 deg on X by the FBX axis conversion; leave it)
    Skeleton3D
      Chr_ArmLowerLeft_Female_00 ... (720 MeshInstance3D, all visible)
```
- Every surface uses `PolygonCharacter.tres`, which is shared. To give a character its own colours,
  duplicate the material for that character and set the duplicate's shader parameters: `ColorPrimary`, `ColorSecondary`, `ColorLeatherPrimary`,
  `ColorLeatherSecondary`, `ColorMetalPrimary`, `ColorMetalSecondary`, `ColorMetalDark`, `ColorHair`,
  `ColorSkin`, `ColorStubble`, `ColorScar`, `ColorBodyArt`, `ColorEyes`, plus `BodyArtAmount`,
  `Metallic`, `Smoothness`, `Emission`.
- Faces +Z (Godot's model front). Scale 1.
- Textures are imported lossless with no mipmaps. VRAM compression and mip blending blur the mask
  edges, so recolour regions bleed into each other.
- No animations are in the FBX, and animation import is off.

## Part naming
`Chr_<Slot>_<Male|Female>_NN` for gendered parts and `Chr_<Slot>_NN` for shared ones. Slots:
Head, Head_No_Elements, Eyebrow, FacialHair, Torso, ArmUpperRight/Left, ArmLowerRight/Left,
HandRight/Left, Hips, LegRight/Left, Hair, HeadCoverings_Base_Hair, HeadCoverings_No_FacialHair,
HeadCoverings_No_Hair, HelmetAttachment, Ear_Ear (elf ears), BackAttachment,
ShoulderAttachRight/Left, ElbowAttachRight/Left, HipsAttachment, KneeAttachRight/Left. FacialHair is
Male only. The collections under `ModularCharacter/Parts` in the .blend match these one to one.

## Adding custom parts
Model in `ModularCharacter.blend` in the rest pose, around the existing meshes. UV onto the Synty atlas
so the masks recolour it, use the `PolygonFantasyHero` material, weight to the existing bones, parent
with an Armature modifier, put it in a collection under `ModularCharacter`, and export.
