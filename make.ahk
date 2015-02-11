#NoEnv
SetBatchLines, -1

Out := "LC_Version := """ FileOpen("VERSION", "r").Read() """`n"

Loop, src\*.ahk
	Out .= "`n" FileOpen(A_LoopFileLongPath, "r").Read() "`n"
FileOpen("build\libcrypt.ahk", "w").Write(Out)

MsgBox,64,,done
ExitApp