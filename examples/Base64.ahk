#Include ..\build\libcrypt.ahk

FileSelectFile, FilePath,, %A_MyDocuments%\..\Pictures, %A_ScriptName% - Pick a (small) PNG, Images (*.png)
if !ErrorLevel
{
	PngFile := FileOpen(FilePath, "r")
	PngFile.RawRead(PngData, PngFile.Length)
	LC_Base64_Encode(Base64, PngData, PngFile.Length)
	Clipboard := "data:image/png;base64," Base64
	MsgBox, Paste into your browsers address bar
}

Loop, 50
{
	Random, Char, 100, 1000
	Unicode .= Chr(Char)
}

Base64 := LC_Base64_EncodeText(Unicode)
MsgBox, % Unicode "`n`n-> LC_Base64_EncodeText ->`n`n"
. Base64 "`n`n-> LC_Base64_DecodeText ->`n`n"
. LC_Base64_DecodeText(Base64)
