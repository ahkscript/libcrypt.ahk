#Include ..\build\libcrypt.ahk

#NoEnv
#SingleInstance Force
SetBatchLines, -1

str := "The quick brown fox jumps over the lazy dog"
MsgBox, % "String:`n" (str) "`n`nSHA:`n" LC_SHA(str)

hex := "54686520717569636b2062726f776e20666f78206a756d7073206f76657220746865206c617a7920646f67"
MsgBox, % "Hex:`n" (hex) "`n`nSHA:`n" LC_HexSHA(hex)

file := "C:\Windows\notepad.exe"
MsgBox, % "File:`n" (file) "`n`nSHA:`n" LC_FileSHA(file)

ExitApp