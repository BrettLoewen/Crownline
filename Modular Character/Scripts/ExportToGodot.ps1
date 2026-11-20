# Exports ModularCharacter.blend to Crownline/Packages/Modular Character/ (see ExportToGodot.py).
# Run from anywhere:  & "<repo>\Modular Character\Scripts\ExportToGodot.ps1"
# Set $env:BLENDER to use a different Blender install.

$Blender = if ($env:BLENDER) { $env:BLENDER } else { "C:\Program Files\Blender Foundation\Blender 5.3\blender.exe" }
$ModularDir = Split-Path -Parent $PSScriptRoot
$Blend = Join-Path $ModularDir "ModularCharacter.blend"
$Script = Join-Path $PSScriptRoot "ExportToGodot.py"

& $Blender --background $Blend --python-exit-code 1 --python $Script
if ($LASTEXITCODE -ne 0) { throw "Export failed (Blender exit code $LASTEXITCODE)" }
