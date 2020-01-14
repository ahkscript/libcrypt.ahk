#Include ..\build\libcrypt.ahk
#Include ..\src-dev\ASCII85_2.ahk

#NoEnv
#SingleInstance Force
SetBatchLines, -1

In = 
( Join
Man is distinguished, not only by his reason,
)

example := "ASCII85: -----`n" . (e:=LC_ASCII85_Encode(In))
	. "`n`nInverse: -----`n" . LC_ASCII85_Decode(e)
MsgBox, 64, ASCII85, %example%
ExitApp