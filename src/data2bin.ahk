Int2bin(z) {
	s:="", p:=1
	Loop, 8
		b := z & p,	b := (b)?1:0, s := b . s, p := p << 1
	return s
}

data2bin(s,pretty:=0) {
	r:=""
	Loop, % q := StrLen(s)
	{
		r .= Int2bin(Asc(SubStr(s,A_Index,1)))
		if ( pretty && (A_Index < q) )
			r .= " "
	}
	return r
}

MsgBox % data2bin("joedf",true)
; should be : 01101010 01101111 01100101 01100100 01100110