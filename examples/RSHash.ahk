#Include ..\build\libcrypt.ahk

s:="21EC2020-3AEA-4069-A2DD-08002B30309D"
MsgBox % "Input: " . "" . s . "" . "`nOutput: " . LC_RSHash(s)
; should output: 1866374240