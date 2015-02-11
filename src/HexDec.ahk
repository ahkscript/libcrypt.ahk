LC_Dec2Hex(x){
	A_FormatInteger_bkp:=A_FormatInteger
	SetFormat,IntegerFast,hex
	x+=0
	x.=""
	SetFormat,IntegerFast,%A_FormatInteger_bkp%
	StringTrimLeft,x,x,2 
	StringUpper,x,x
	return x
}
LC_Hex2Dec(x){
	A_FormatInteger_bkp:=A_FormatInteger
	if !InStr(x,"x")
		x:="0x" x
	SetFormat,IntegerFast,Dec
	x+=0
	x.=""
	SetFormat,IntegerFast,%A_FormatInteger_bkp%
	return x
}