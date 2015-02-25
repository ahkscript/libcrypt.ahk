; Modified by GeekDude from http://goo.gl/0a0iJq
LC_UriEncode(Uri, RE="[0-9A-Za-z]") {
	VarSetCapacity(Var, StrPut(Uri, "UTF-8"), 0), StrPut(Uri, &Var, "UTF-8")
	While Code := NumGet(Var, A_Index - 1, "UChar")
		Res .= (Chr:=Chr(Code)) ~= RE ? Chr : Format("%{:02X}", Code)
	Return, Res
}

LC_UriDecode(Uri) {
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
LC_UrlEncode(url) { ; keep ":/;?@,&=+$#"
	a:=StrLen(url), b:=StrLen(URIs:=RegExReplace(url,"\w+:\/{0,2}[^\/]+.\/")), r:=SubStr(url,1,a-b)
	Loop, Parse, URIs
		if A_LoopField in :,/,;,?,@,`,,&,=,+,$,#
			r .= A_LoopField
		else
			r .= LC_UriEncode(A_LoopField)
	return r
}
LC_UrlDecode(url) {
	return LC_UriDecode(url)
}