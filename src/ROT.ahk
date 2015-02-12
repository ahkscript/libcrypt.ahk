/*
	- ROT5 covers the numbers 0-9.
	- ROT13 covers the 26 upper and lower case letters of the Latin alphabet (A-Z, a-z).
	- ROT18 is a combination of ROT5 and ROT13.
	- ROT47 covers all printable ASCII characters, except empty spaces. Besides numbers and the letters of the Latin alphabet,
			the following characters are included:
			!"#$%&'()*+,-./:;<=>?[\]^_`{|}~
*/

LC_Rot5(string) {
	Loop, Parse, string
		s .= (strlen((c:=A_LoopField)+0)?((c<5)?c+5:c-5):(c))
	Return s
}

; by Raccoon July-2009
; http://rosettacode.org/wiki/Rot-13#AutoHotkey
LC_Rot13(string) {
	Loop, Parse, string
	{
		c := asc(A_LoopField)
		if (c >= 97) && (c <= 109) || (c >= 65) && (c <= 77)
			c += 13
		else if (c >= 110) && (c <= 122) || (c >= 78) && (c <= 90)
			c -= 13
		s .= Chr(c)
	}
	Return s
}

LC_Rot18(string) {
	return LC_Rot13(LC_Rot5(string))
}

; adapted from http://langref.org/fantom+java+scala/strings/reversing-a-string/simple-substitution-cipher
; from decimal 33 '!' through 126 '~', 94 
LC_Rot47(string) {
	Loop Parse, string
	{
		c := Asc(A_LoopField)
		c += (c >= Asc("!") && c <= Asc("O") ? 47 : (c >= Asc("P") && c <= Asc("~") ? -47 : 0))
		s .= Chr(c)
	}
	Return s
}