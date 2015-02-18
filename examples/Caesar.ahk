#Include ..\build\libcrypt.ahk

#NoEnv
#SingleInstance Force
SetBatchLines, -1

MsgBox % LC_Caesar("Hello", 2) "`n" LC_Caesar("Hello", 20)

ExitApp