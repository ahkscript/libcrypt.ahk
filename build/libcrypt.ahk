LC_Version := "0.0.1.0"

LC_ASCII2BinStr(s,pretty:=0) {
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

LC_Base64_EncodeText(Text)
{
	VarSetCapacity(Bin, StrPut(Text, "UTF-8"))
	LC_Base64_Encode(Base64, Bin, StrPut(Text, &Bin, "UTF-8")-1)
	return Base64
}

LC_Base64_DecodeText(Text)
{
	Len := LC_Base64_Decode(Bin, Text)
	return StrGet(&Bin, "UTF-8")
}

LC_Base64_Encode(ByRef Out, ByRef In, InLen)
{
	return LC_Bin2Str(Out, In, InLen, 0x40000001)
}

LC_Base64_Decode(ByRef Out, ByRef In)
{
	return LC_Str2Bin(Out, In, 0x1)
}

LC_Bin2Hex(ByRef Out, ByRef In, InLen, Pretty=False)
{
	return LC_Bin2Str(Out, In, InLen, Pretty ? 0xb : 0x4000000c)
}

LC_Hex2Bin(ByRef Out, ByRef In)
{
	return LC_Str2Bin(Out, In, 0x8)
}

LC_Bin2Str(ByRef Out, ByRef In, InLen, Flags)
{
	DllCall("Crypt32.dll\CryptBinaryToString", "Ptr", &In
	, "UInt", InLen, "UInt", Flags, "Ptr", 0, "UInt*", OutLen)
	VarSetCapacity(Out, OutLen * (1+A_IsUnicode))
	DllCall("Crypt32.dll\CryptBinaryToString", "Ptr", &In
	, "UInt", InLen, "UInt", Flags, "Str", Out, "UInt*", OutLen)
	return OutLen
}

LC_Str2Bin(ByRef Out, ByRef In, Flags)
{
	DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &In, "UInt", StrLen(In)
	, "UInt", Flags, "Ptr", 0, "UInt*", OutLen, "Ptr", 0, "Ptr", 0)
	VarSetCapacity(Out, OutLen)
	DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &In, "UInt", StrLen(In)
	, "UInt", Flags, "Str", Out, "UInt*", OutLen, "Ptr", 0, "Ptr", 0)
	return OutLen
}

;
; Date Updated:
;	Friday, November 23rd, 2012 - Tuesday, February 10th, 2015
;
; Script Function:
;	Function Library to Encrypt / Decrypt in Div2 (by Joe DF)
;	Div2 was invented with a friend for fun, back in ~2010.
;	The string is "divided" in 2 during encryption. It is a 
;	simple reordering of the characters in a string. The was
; 	to have a human-readable/decryptable message.
;
; Notes:
;	AutoTrim should turned off, for the encryption to work properly
;	because, in Div2, <spaces> and <New lines> count as a character.
;

LC_Div2_encode(input, AutoTrimIsOn:=0, numproc:=1) {
	if ( (AutoTrimIsOn) || InStr(A_AutoTrim,"on") )
		StringReplace,input,input,%A_Space%,_,A
	loop, %numproc%
	{
		final:="", inputlen := StrLen(input)
		divmax := ceil((0.5 * inputlen) + 1)
		loop, %inputlen%
		{
			temp := SubStr(input,A_Index,1)
			q := inputlen + 1 - A_Index
			temp2 := SubStr(input,q,1)
			if (A_Index < divmax) {
				final .= temp
				if (A_Index != q)
					final .= temp2
			}
			if (A_Index >= divmax)
				Break
		}
		input := final
	}
	return final
}

LC_Div2_decode(input, AutoTrimIsOn:=0, numproc:=1) {
	if ( (AutoTrimIsOn) || InStr(A_AutoTrim,"on") )
		StringReplace,input,input,%A_Space%,_,A
	loop, %numproc%
	{
		i := 1, final:="", inputlen := StrLen(input)
		loop, % loopc := ceil(inputlen * (1/2))
		{	
			if (i <= inputlen)
				final .= SubStr(input,i,1)
			i += 2
		}
		i := inputlen
		loop, %loopc%
		{		
			if (i <= inputlen) {
				if (mod(SubStr(i,0,1)+0,2)==1) {
					if (i != 1)
						final .= SubStr(input,i-1,1)
				} else {
					final .= SubStr(input,i,1)
				}
			}
			i -= 2
		}
		input := final
	}
	return final
}


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

LC_XOR_Encrypt(str,key,delim:=":") {
	r:="", k:=StrSplit(key), m:=Strlen(key)
	for i, c in StrSplit(str)
		r .= LC_Dec2Hex(Asc(c)^Asc(k[mod(i,m)])) delim
	return SubStr(r,1,-1)
}

LC_XOR_Decrypt(str,key,delim:=":") {
	r:="", k:=StrSplit(key), m:=Strlen(key)
	for i, n in StrSplit(str,delim)
		r .= Chr(LC_Hex2Dec(n)^Asc(k[mod(i,m)]))
	return r
}
