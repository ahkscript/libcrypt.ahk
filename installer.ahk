#NoEnv
SetWorkingDir, %A_ScriptDir%

Gui, Add, Text, w180 Center, Install libcrypt.ahk to:
Gui, Add, Button, w180 gProgFiles, Program Files
Gui, Add, Button, w180 gMyDocs, My Documents
Gui, Add, Button, w180 gCustom, Custom Path
Gui, Add, Checkbox, w180 vRebuild Checked, Rebuild before instaling
Gui, Show,, libcrypt.ahk
return

ProgFiles:
MyDocs:
Custom:
return