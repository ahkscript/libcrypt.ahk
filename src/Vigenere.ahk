; 
; Version: 2014.03.06-1518, jNizM
; see https://en.wikipedia.org/wiki/Vigen%C3%A8re_cipher
; ===================================================================================

LC_VigenereCipher(string, key, enc := 1) {
	enc := "", DllCall("user32.dll\CharUpper", "Ptr", &string, "Ptr")
	, string := RegExReplace(StrGet(&string), "[^A-Z]")
	loop, parse, string
	{
		a := Asc(A_LoopField) - 65
		, b := Asc(SubStr(key, 1 + Mod(A_Index - 1, StrLen(key)), 1)) - 65
		, enc .= Chr(Mod(a + b, 26) + 65)
	}
	return enc
}

LC_VigenereDecipher(string, key) {
	dec := ""
	loop, parse, key
		dec .= Chr(26 - (Asc(A_LoopField) - 65) + 65)
	return LC_VigenereCipher(string, dec)
}