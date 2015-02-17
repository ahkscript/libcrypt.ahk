#NoEnv
SetWorkingDir, %A_ScriptDir%

Gui, Add, Text, w180 Center, Install libcrypt.ahk to:
Gui, Add, Button, w180 gProgFiles, Install Directory
Gui, Add, Button, w180 gMyDocs, My Documents
Gui, Add, Button, w180 gCustom, Custom Path
Gui, Add, Checkbox, w180 vRebuild Checked, Rebuild before instaling
Gui, Show,, libcrypt.ahk
return

GuiClose:
ExitApp
return

ProgFiles:
Gosub, Rebuild
Run, *RunAs make.ahk "%A_AhkPath%\..\lib\libcrypt.ahk"
return

MyDocs:
Gosub, Rebuild
Run, make.ahk install
return

Custom:
Gosub, Rebuild
FileSelectFile, FilePath
Run, make.ahk "%FilePath%"
return

Rebuild:
GuiControlGet, Rebuild
if Rebuild
	Run, make.ahk
return