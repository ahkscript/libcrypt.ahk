#NoEnv
SetBatchLines, -1

Param = %1%
if (Param = "")
{
	Out := "LC_Version := """ FileOpen("VERSION", "r`r`n").Read() """`n"
	Loop, src\*.ahk
		Out .= "`n" FileOpen(A_LoopFileLongPath, "r`r`n").Read() "`n"
	FileCreateDir, build
	FileOpen("build\libcrypt.ahk", "w`r`n").Write(Out)
}
else if (Param = "install")
	FileCopyCreateDir("build\libcrypt.ahk", A_MyDocuments "\AutoHotkey\Lib\libcrypt.ahk")
else if (Param = "uninstall")
	FileDelete, % A_MyDocuments "\AutoHotkey\Lib\libcrypt.ahk"
else
	FileCopyCreateDir("build\libcrypt.ahk", Param)
ExitApp

FileCopyCreateDir(Source, Dest)
{
	SplitPath, Dest,, OutDir
	FileCreateDir, %OutDir%
	FileCopy, %Source%, %Dest%
	return ErrorLevel
}