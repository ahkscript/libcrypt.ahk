#NoEnv
SetBatchLines, -1

ProcessedFile := ProcessIncludes("src\libcrypt.ahk")
FileOpen("build\libcrypt.ahk", "w").Write(ProcessedFile)
ExitApp

; Uses SetWorkingDir. Consider using critical for thread safety.
; It may get stuck on #IncludeAgain loops.
; I should probably just figure out however ahk2exe does it and imitate that.
ProcessIncludes(FilePath)
{
	IncludeVars := {"%A_ScriptDir%": FilePath "\.."
	, "%A_AppData%": A_AppData
	, "%A_AppDataCommon%": A_AppDataCommon
	, "%A_LineFile%": FilePath}
	
	FileRead, File, %FilePath%
	WorkingDir := A_WorkingDir
	SetWorkingDir, % FilePath "\.."
	Included := []
	
	; I'm avoiding \s because it matches \R
	while RegExMatch(File, "Oim)^[ \t]*#Include(?P<Again>Again)?[ \t]+(?:\*i[ \t]+)?(?P<Path>.+?)[ \t]*(?:[ \t]`;.*)?$", Match)
	{
		IncludePath := Match.Path
		
		; Resolve #Include variables and ensure existence
		for Reference, Value in IncludeVars
			StringReplace, IncludePath, IncludePath, %Reference%, %Value%, All
		if !(IncludePath := AbsolutePath(IncludePath))
			Continue ; Invalid file path
		
		; Do the thing
		if InStr(FileExist(IncludePath), "D")
		{
			File := SubStr(File, 1, Match.Pos-1) . SubStr(File, Match.Pos+Match.Len)
			SetWorkingDir, % IncludePath
		}
		else if Match.Again || !Included[IncludePath]
		{
			File := SubStr(File, 1, Match.Pos-1) . ProcessIncludes(IncludePath) . SubStr(File, Match.Pos+Match.Len)
			Included[IncludePath] := True
		}
	}
	
	SetWorkingDir, %WorkingDir%
	return file
}

; Consider using actual API calls for this
AbsolutePath(ShortPath)
{
	if (ShortPath == "")
		return
	Loop, %ShortPath%., 1 ; the dot protects against words like "parse"
		return A_LoopFileLongPath
}