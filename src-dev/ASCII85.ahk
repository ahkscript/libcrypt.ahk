 ; by Titan
 ; with a few modifications
LC_ASCII85_Encode(str) {
	x:="",tr:="",i:="", xFI := A_FormatInteger
	SetFormat, Integer, Hex
	Loop, Parse, str
		If !Mod(A_Index, 4) || ((StrLen(str) / A_Index) == 1) {
			x := x . Asc(A_LoopField)
			If ( ((StrLen(str) / A_Index) == 1) && Mod(A_Index, 4) )
				tr := 4 - Mod(A_Index, 4)
			Loop, %tr%
				x := x . 0x00
			StringReplace, x, x, 0x, , 1
			x =0x%x%
			SetFormat, Integer, D
			x += 0
			Loop, 5
				i := i . Chr((Floor(Mod(x / (85 ** (5 - A_Index)), 85))) + 33)
			SetFormat, Integer, Hex
			StringTrimLeft, x, x, 4
			x := ""
		} Else x := x . Asc(A_LoopField)
	StringReplace, i, i, !!!!!, z, 1
	StringTrimRight, i, i, %tr%
	SetFormat, Integer, %xFI%
	Return, "<~" . i . "~>"
}
LC_ASCII85_Decode(str) {
	x:="",tr:="",i:="", xFI := A_FormatInteger
	StringReplace, str, str, <~
	StringReplace, str, str, ~>
	Loop, Parse, str
		If ( !Mod(A_Index, 5) || ((StrLen(str) / A_Index) == 1) ) {
			If ( (StrLen(str) / A_Index) == 1 )
				tr := 5 - Mod(A_Index, 5)
			Loop, %tr%
				x += (Asc("0x00") - 33) * (85 ** 5 - (5 - (5 - Mod(A_Index, 5))))
			x += Asc(A_LoopField) - 33
			SetFormat, Integer, Hex
			x += 0
			Loop, 4 {
				StringMid, a, x, (A_Index * 2) + 1, 2
				i := i . Chr("0x" . a)
			} SetFormat, Integer, D
			x = 0
		} Else x += (Asc(A_LoopField) - 33) * (85 ** (5 - Mod(A_Index, 5)))
	StringTrimRight, i, i, %tr%
	Return, i
}