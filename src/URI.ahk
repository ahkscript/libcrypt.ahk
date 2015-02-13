; Modified by GeekDude from http://goo.gl/0a0iJq
LC_UriEncode(Uri)
{
	VarSetCapacity(Var, StrPut(Uri, "UTF-8"), 0), StrPut(Uri, &Var, "UTF-8")
	f := A_FormatInteger
	SetFormat, IntegerFast, H
	While Code := NumGet(Var, A_Index - 1, "UChar")
		If (Code >= 0x30 && Code <= 0x39	; 0-9
		|| Code >= 0x41 && Code <= 0x5A		; A-Z
		|| Code >= 0x61 && Code <= 0x7A)	; a-z
			Res .= Chr(Code)
	Else
		Res .= "%" . SubStr(Code + 0x100, -1)
	SetFormat, IntegerFast, %f%
	Return, Res
}

LC_UriDecode(Uri)
{
	Pos := 1
	While Pos := RegExMatch(Uri, "i)(%[\da-f]{2})+", Code, Pos)
	{
		VarSetCapacity(Var, StrLen(Code) // 3, 0), Code := SubStr(Code,2)
		Loop, Parse, Code, `%
			NumPut("0x" A_LoopField, Var, A_Index-1, "UChar")
		StringReplace, Uri, Uri, `%%Code%, % StrGet(&Var, "UTF-8"), All
	}
	Return, Uri
}

;----------------------------------
LC_UrlEncode(url) {
	a:=StrLen(url), b:=StrLen(URIs:=RegExReplace(url,"\w+:\/{0,2}[^\/]+.\/")), r:=SubStr(url,1,a-b)
	for each, uri in StrSplit(URIs,"/")
		r .= LC_UriEncode(uri) "/"
	return SubStr(r,1,-1)
}
LC_UrlDecode(url) {
	a:=StrLen(url), b:=StrLen(URIs:=RegExReplace(url,"\w+:\/{0,2}[^\/]+.\/")), r:=SubStr(url,1,a-b)
	for each, uri in StrSplit(URIs,"/")
		r .= LC_UriDecode(uri) "/"
	return SubStr(r,1,-1)
}