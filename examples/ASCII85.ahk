#Include ..\build\libcrypt.ahk

#Warn
#NoEnv
#SingleInstance Force
SetBatchLines, -1

In = 
( Join
Man is distinguished, not only by his reason, but by this singular passion from other animals
, which is a lust of the mind, that by a perseverance of delight in the continued
, and indefatigable generation of knowledge, exceeds the short vehemence of any carnal pleasure.
)

example := "ASCII85: -----`n" . LC_ASCII85(In)
	. "`n`nInverse: -----`n" . LC_ASCII85(LC_ASCII85(In), 1)
MsgBox, 64, ASCII85, %example%
ExitApp