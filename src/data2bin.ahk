data2bin(s,pretty:=0) {
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

MsgBox % data2bin("joedf",true)
; should be : 01101010 01101111 01100101 01100100 01100110