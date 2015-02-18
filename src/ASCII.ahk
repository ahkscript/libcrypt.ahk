LC_ASCII2Bin(s,pretty:=0) {
	r:=""
	Loop, % l:=StrLen(s)
	{
		z:=Asc(SubStr(s,A_Index,1)),y:="",p:=1
		Loop, 8
			b:=!!(z&p),y:=b y,p:=p<<1
		r.=y
		if (pretty && (A_Index<l))
			r.=" "
	}
	return r
}

LC_Ascii2Bin2(Ascii) {
	for each, Char in StrSplit(Ascii)
	Loop, 8
		Out .= !!(Asc(Char) & 1 << 8-A_Index)
	return Out
}
 
LC_Bin2Ascii(Bin) {
	Bin := RegExReplace(Bin, "[^10]")
	Loop, % StrLen(Bin) / 8
	{
		for each, Bit in StrSplit(SubStr(Bin, A_Index*8-7, 8))
			Asc += Asc + Bit
		Out .= Chr(Asc), Asc := 0
	}
	return Out
}