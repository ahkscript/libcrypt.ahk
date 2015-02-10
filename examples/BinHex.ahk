#Include ..\build\libcrypt.ahk

; Generate some random binary
Size := 32
VarSetCapacity(Var, Size, 0)
Loop, %Size%
{
	Random, Rand, 0, 255
	NumPut(Rand, Var, A_Index-1, "UChar")
	Hex .= Format("{:02x}", Rand)
}

; Compare Bin2Hex against what we put in
LC_Bin2Hex(Out, Var, Size)
MsgBox, % Hex "`n" Out

; Pull a string from a hat
Hex := "48656c6c6f20576f726c642100"
LC_Hex2Bin(Out, Hex)
MsgBox, % StrGet(&Out, "CP0")

; Put a string in and display it prettily
String := ":) :\ :| :/ :( ^_^ .-. .______. <(^_^)> <(^_^)^"
Size := StrPut(String, "CP0")
VarSetCapacity(Var, Size, 0)
StrPut(String, &Var, "CP0")
LC_Bin2Hex(Out, Var, Size, True)
Gui, Font,, Consolas
Gui, Add, Text,, % Out
Gui, Show
return

Escape::
GuiClose:
ExitApp