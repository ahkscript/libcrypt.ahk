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

 ; thanks to Titan
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

LC_Base64_EncodeText(Text,Encoding="UTF-8")
{
	VarSetCapacity(Bin, StrPut(Text, Encoding))
	LC_Base64_Encode(Base64, Bin, StrPut(Text, &Bin, Encoding)-1)
	return Base64
}

LC_Base64_DecodeText(Text,Encoding="UTF-8")
{
	Len := LC_Base64_Decode(Bin, Text)
	return StrGet(&Bin, Encoding)
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

LC_CalcAddrHash(addr, length, algid, byref hash = 0, byref hashlength = 0) {
	static h := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, "a", "b", "c", "d", "e", "f"]
	static b := h.minIndex()
	hProv := hHash := o := ""
	if (DllCall("advapi32\CryptAcquireContext", "Ptr*", hProv, "Ptr", 0, "Ptr", 0, "UInt", 24, "UInt", 0xf0000000))
	{
		if (DllCall("advapi32\CryptCreateHash", "Ptr", hProv, "UInt", algid, "UInt", 0, "UInt", 0, "Ptr*", hHash))
		{
			if (DllCall("advapi32\CryptHashData", "Ptr", hHash, "Ptr", addr, "UInt", length, "UInt", 0))
			{
				if (DllCall("advapi32\CryptGetHashParam", "Ptr", hHash, "UInt", 2, "Ptr", 0, "UInt*", hashlength, "UInt", 0))
				{
					VarSetCapacity(hash, hashlength, 0)
					if (DllCall("advapi32\CryptGetHashParam", "Ptr", hHash, "UInt", 2, "Ptr", &hash, "UInt*", hashlength, "UInt", 0))
					{
						loop % hashlength
						{
							v := NumGet(hash, A_Index - 1, "UChar")
							o .= h[(v >> 4) + b] h[(v & 0xf) + b]
						}
					}
				}
			}
			DllCall("advapi32\CryptDestroyHash", "Ptr", hHash)
		}
		DllCall("advapi32\CryptReleaseContext", "Ptr", hProv, "UInt", 0)
	}
	return o
}
LC_CalcStringHash(string, algid, encoding = "UTF-8", byref hash = 0, byref hashlength = 0) {
	chrlength := (encoding = "CP1200" || encoding = "UTF-16") ? 2 : 1
	length := (StrPut(string, encoding) - 1) * chrlength
	VarSetCapacity(data, length, 0)
	StrPut(string, &data, floor(length / chrlength), encoding)
	return LC_CalcAddrHash(&data, length, algid, hash, hashlength)
}
LC_CalcHexHash(hexstring, algid) {
	length := StrLen(hexstring) // 2
	VarSetCapacity(data, length, 0)
	loop % length
	{
		NumPut("0x" SubStr(hexstring, 2 * A_Index - 1, 2), data, A_Index - 1, "Char")
	}
	return LC_CalcAddrHash(&data, length, algid)
}
LC_CalcFileHash(filename, algid, continue = 0, byref hash = 0, byref hashlength = 0) {
	fpos := ""
	if (!(f := FileOpen(filename, "r")))
	{
		return
	}
	f.pos := 0
	if (!continue && f.length > 0x7fffffff)
	{
		return
	}
	if (!continue)
	{
		VarSetCapacity(data, f.length, 0)
		f.rawRead(&data, f.length)
		f.pos := oldpos
		return LC_CalcAddrHash(&data, f.length, algid, hash, hashlength)
	}
	hashlength := 0
	while (f.pos < f.length)
	{
		readlength := (f.length - fpos > continue) ? continue : f.length - f.pos
		VarSetCapacity(data, hashlength + readlength, 0)
		DllCall("RtlMoveMemory", "Ptr", &data, "Ptr", &hash, "Ptr", hashlength)
		f.rawRead(&data + hashlength, readlength)
		h := LC_CalcAddrHash(&data, hashlength + readlength, algid, hash, hashlength)
	}
	return h
}

LC_CRC32(string, encoding = "UTF-8") {
	chrlength := (encoding = "CP1200" || encoding = "UTF-16") ? 2 : 1
	length := (StrPut(string, encoding) - 1) * chrlength
	VarSetCapacity(data, length, 0)
	StrPut(string, &data, floor(length / chrlength), encoding)
	hMod := DllCall("Kernel32.dll\LoadLibrary", "Str", "Ntdll.dll")
	SetFormat, Integer, % SubStr((A_FI := A_FormatInteger) "H", 0)
	CRC32 := DllCall("Ntdll.dll\RtlComputeCrc32", "UInt", 0, "UInt", &data, "UInt", length, "UInt")
	CRC := SubStr(CRC32 | 0x1000000000, -7)
	DllCall("User32.dll\CharLower", "Str", CRC)
	SetFormat, Integer, %A_FI%
	return CRC, DllCall("Kernel32.dll\FreeLibrary", "Ptr", hMod)
}
LC_HexCRC32(hexstring) {
	length := StrLen(hexstring) // 2
	VarSetCapacity(data, length, 0)
	loop % length
	{
		NumPut("0x" SubStr(hexstring, 2 * A_Index -1, 2), data, A_Index - 1, "Char")
	}
	hMod := DllCall("Kernel32.dll\LoadLibrary", "Str", "Ntdll.dll")
	SetFormat, Integer, % SubStr((A_FI := A_FormatInteger) "H", 0)
	CRC32 := DllCall("Ntdll.dll\RtlComputeCrc32", "UInt", 0, "UInt", &data, "UInt", length, "UInt")
	CRC := SubStr(CRC32 | 0x1000000000, -7)
	DllCall("User32.dll\CharLower", "Str", CRC)
	SetFormat, Integer, %A_FI%
	return CRC, DllCall("Kernel32.dll\FreeLibrary", "Ptr", hMod)
}
LC_FileCRC32(sFile := "", cSz := 4) {
	Bytes := ""
	cSz := (cSz < 0 || cSz > 8) ? 2**22 : 2**(18 + cSz)
	VarSetCapacity(Buffer, cSz, 0)
	hFil := DllCall("Kernel32.dll\CreateFile", "Str", sFile, "UInt", 0x80000000, "UInt", 3, "Int", 0, "UInt", 3, "UInt", 0, "Int", 0, "UInt")
	if (hFil < 1)
	{
		return hFil
	}
	hMod := DllCall("Kernel32.dll\LoadLibrary", "Str", "Ntdll.dll")
	CRC32 := 0
	DllCall("Kernel32.dll\GetFileSizeEx", "UInt", hFil, "Int64", &Buffer), fSz := NumGet(Buffer, 0, "Int64")
	loop % (fSz // cSz + !!Mod(fSz, cSz))
	{
		DllCall("Kernel32.dll\ReadFile", "UInt", hFil, "Ptr", &Buffer, "UInt", cSz, "UInt*", Bytes, "UInt", 0)
		CRC32 := DllCall("Ntdll.dll\RtlComputeCrc32", "UInt", CRC32, "UInt", &Buffer, "UInt", Bytes, "UInt")
	}
	DllCall("Kernel32.dll\CloseHandle", "Ptr", hFil)
	SetFormat, Integer, % SubStr((A_FI := A_FormatInteger) "H", 0)
	CRC32 := SubStr(CRC32 + 0x1000000000, -7)
	DllCall("User32.dll\CharLower", "Str", CRC32)
	SetFormat, Integer, %A_FI%
	return CRC32, DllCall("Kernel32.dll\FreeLibrary", "Ptr", hMod)
}

;from joedf : fork-fusion of jNizM+Laszlo's functions [to_decimal()+ToBase()]
LC_To_Dec(b, n) { ; 1 < b <= 36, n >= 0
	d:=0
	StringUpper,n,n
	loop % StrLen(n)
	{
		d *= b, k:=SubStr(n,A_Index,1)
		if k is not Integer
			k:=Asc(k)-55
		d += k
	}
	return d
}
;from Laszlo : http://www.autohotkey.com/board/topic/15951-base-10-to-base-36-conversion/#entry103624
LC_From_Dec(b,n) { ; 1 < b <= 36, n >= 0
	Loop {
		d := mod(n,b), n //= b
		m := (d < 10 ? d : Chr(d+55)) . m
		IfLess n,1, Break
	}
	Return m
}
LC_Dec2Hex(x) {
	return LC_From_Dec(16,x)
}
LC_Hex2Dec(x) {
	return LC_To_Dec(16,x)
}
LC_Numvert(num,from,to) { ; from joedf : http://ahkscript.org/boards/viewtopic.php?f=6&t=6363
    return LC_From_Dec(to,LC_To_Dec(from,num))
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


LC_HMAC(Key, Message, Algo := "MD5") {
	static Algorithms := {MD2:    {ID: 0x8001, Size:  64}
						, MD4:    {ID: 0x8002, Size:  64}
						, MD5:    {ID: 0x8003, Size:  64}
						, SHA:    {ID: 0x8004, Size:  64}
						, SHA256: {ID: 0x800C, Size:  64}
						, SHA384: {ID: 0x800D, Size: 128}
						, SHA512: {ID: 0x800E, Size: 128}}
	static iconst := 0x36
	static oconst := 0x5C
	if (!(Algorithms.HasKey(Algo)))
	{
		return ""
    }
	Hash := KeyHashLen := InnerHashLen := ""
	HashLen := 0
	AlgID := Algorithms[Algo].ID
	BlockSize := Algorithms[Algo].Size
	MsgLen := StrPut(Message, "UTF-8") - 1
	KeyLen := StrPut(Key, "UTF-8") - 1
	VarSetCapacity(K, KeyLen + 1, 0)
	StrPut(Key, &K, KeyLen, "UTF-8")
	if (KeyLen > BlockSize)
    {
		LC_CalcAddrHash(&K, KeyLen, AlgID, KeyHash, KeyHashLen)
	}

	VarSetCapacity(ipad, BlockSize + MsgLen, iconst)
	Addr := KeyLen > BlockSize ? &KeyHash : &K
	Length := KeyLen > BlockSize ? KeyHashLen : KeyLen
	i := 0
	while (i < Length)
	{
		NumPut(NumGet(Addr + 0, i, "UChar") ^ iconst, ipad, i, "UChar")
		i++
	}
	if (MsgLen)
	{
		StrPut(Message, &ipad + BlockSize, MsgLen, "UTF-8")
	}
	LC_CalcAddrHash(&ipad, BlockSize + MsgLen, AlgID, InnerHash, InnerHashLen)

	VarSetCapacity(opad, BlockSize + InnerHashLen, oconst)
	Addr := KeyLen > BlockSize ? &KeyHash : &K
	Length := KeyLen > BlockSize ? KeyHashLen : KeyLen
	i := 0
	while (i < Length)
	{
		NumPut(NumGet(Addr + 0, i, "UChar") ^ oconst, opad, i, "UChar")
		i++
	}
	Addr := &opad + BlockSize
	i := 0
	while (i < InnerHashLen)
	{
		NumPut(NumGet(InnerHash, i, "UChar"), Addr + i, 0, "UChar")
		i++
	}
	return LC_CalcAddrHash(&opad, BlockSize + InnerHashLen, AlgID)
}

LC_MD2(string, encoding = "UTF-8") {
	return LC_CalcStringHash(string, 0x8001, encoding)
}
LC_HexMD2(hexstring) {
	return LC_CalcHexHash(hexstring, 0x8001)
}
LC_FileMD2(filename) {
	return LC_CalcFileHash(filename, 0x8001, 64 * 1024)
}
LC_AddrMD2(addr, length) {
	return LC_CalcAddrHash(addr, length, 0x8001)
}

LC_MD4(string, encoding = "UTF-8") {
	return LC_CalcStringHash(string, 0x8002, encoding)
}
LC_HexMD4(hexstring) {
	return LC_CalcHexHash(hexstring, 0x8002)
}
LC_FileMD4(filename) {
	return LC_CalcFileHash(filename, 0x8002, 64 * 1024)
}
LC_AddrMD4(addr, length) {
	return LC_CalcAddrHash(addr, length, 0x8002)
}

LC_MD5(string, encoding = "UTF-8") {
	return LC_CalcStringHash(string, 0x8003, encoding)
}
LC_HexMD5(hexstring) {
	return LC_CalcHexHash(hexstring, 0x8003)
}
LC_FileMD5(filename) {
	return LC_CalcFileHash(filename, 0x8003, 64 * 1024)
}
LC_AddrMD5(addr, length) {
	return LC_CalcAddrHash(addr, length, 0x8003)
}

;nnnik's custom encryption algorithm
;Version 2.1 of the encryption/decryption functions

LC_nnnik21_encryptStr(str="",pass="")
{
	If !(enclen:=(strput(str,"utf-16")*2))
		return "Error: Nothing to Encrypt"
	If !(passlen:=strput(pass,"utf-8")-1)
		return "Error: No Pass"
	enclen:=Mod(enclen,4) ? (enclen) : (enclen-2)
	Varsetcapacity(encbin,enclen,0)
	StrPut(str,&encbin,enclen/2,"utf-16")
	Varsetcapacity(passbin,passlen+=mod((4-mod(passlen,4)),4),0)
	StrPut(pass,&passbin,strlen(pass),"utf-8")
	LC_nnnik21_encryptbin(&encbin,enclen,&passbin,passlen)
	LC_Base64_Encode(Text, encbin, enclen)
	return Text
}

LC_nnnik21_decryptStr(str="",pass="")
{
	If !((strput(str,"utf-16")*2))
		return "Error: Nothing to Decrypt"
	If !((passlen:=strput(pass,"utf-8")-1))
		return "Error: No Pass"
	Varsetcapacity(passbin,passlen+=mod((4-mod(passlen,4)),4),0)
	StrPut(pass,&passbin,strlen(pass),"utf-8")
	enclen:=LC_Base64_Decode(encbin, str)
	LC_nnnik21__decryptbin(&encbin,enclen,&passbin,passlen)
	return StrGet(&encbin,"utf-16")
}


LC_nnnik21_encryptbin(pBin1,sBin1,pBin2,sBin2)
{
	b:=0
	Loop % sBin1/4
	{
		a:=numget(pBin1+0,sBin1-A_Index*4,"uint")
		numput(a+b,pBin1+0,sBin1-A_Index*4,"uint")
		b:=(a+b)*a
	}
	Loop % sBin2/4
	{
		c:=numget(pBin2+0,(A_Index-1)*4,"uint")
		b:=0
		Loop % sBin1/4
		{
			a:=numget(pBin1+0,(A_Index-1)*4,"uint")
			numput((a+b)^c,pBin1+0,(A_Index-1)*4,"uint")
			b:=(a+b)*a
		}
	}
}

LC_nnnik21__decryptbin(pBin1,sBin1,pBin2,sBin2){
	Loop % sBin2/4
	{
		c:=numget(pBin2+0,sBin2-A_Index*4,"uint")
		b:=0
		Loop % sBin1/4
		{
			a:=numget(pBin1+0,(A_Index-1)*4,"uint")
			numput(a:=(a^c)-b,pBin1+0,(A_Index-1)*4,"uint")
			b:=(a+b)*a
		}
	}
	b:=0
	Loop % sBin1/4
	{
		a:=numget(pBin1+0,sBin1-A_Index*4,"uint")
		numput(a:=a-b,pBin1+0,sBin1-A_Index*4,"uint")
		b:=(a+b)*a
	}
}


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

LC_SecureSalted(salt, message, algo := "md5") {
	hash := ""
	saltedHash := %algo%(message . salt) 
	saltedHashR := %algo%(salt . message)
	len := StrLen(saltedHash)
	loop % len / 2
	{
		byte1 := "0x" . SubStr(saltedHash, 2 * A_index - 1, 2)
		byte2 := "0x" . SubStr(saltedHashR, 2 * A_index - 1, 2)
		SetFormat, integer, hex
		hash .= StrLen(ns := SubStr(byte1 ^ byte2, 3)) < 2 ? "0" ns : ns
	}
	SetFormat, integer, dez
	return hash
}

LC_SHA(string, encoding = "UTF-8") {
	return LC_CalcStringHash(string, 0x8004, encoding)
}
LC_HexSHA(hexstring) {
	return LC_CalcHexHash(hexstring, 0x8004)
}
LC_FileSHA(filename) {
	return LC_CalcFileHash(filename, 0x8004, 64 * 1024)
}
LC_AddrSHA(addr, length) {
	return LC_CalcAddrHash(addr, length, 0x8004)
}

LC_SHA256(string, encoding = "UTF-8") {
	return LC_CalcStringHash(string, 0x800c, encoding)
}
LC_HexSHA256(hexstring) {
	return LC_CalcHexHash(hexstring, 0x800c)
}
LC_FileSHA256(filename) {
	return LC_CalcFileHash(filename, 0x800c, 64 * 1024)
}
LC_AddrSHA256(addr, length) {
	return LC_CalcAddrHash(addr, length, 0x800c)
}

LC_SHA384(string, encoding = "UTF-8") {
	return LC_CalcStringHash(string, 0x800d, encoding)
}
LC_HexSHA384(hexstring) {
	return LC_CalcHexHash(hexstring, 0x800d)
}
LC_FileSHA384(filename) {
	return LC_CalcFileHash(filename, 0x800d, 64 * 1024)
}
LC_AddrSHA384(addr, length) {
	return LC_CalcAddrHash(addr, length, 0x800d)
}

LC_SHA512(string, encoding = "UTF-8") {
	return LC_CalcStringHash(string, 0x800e, encoding)
}
LC_HexSHA512(hexstring) {
	return LC_CalcHexHash(hexstring, 0x800e)
}
LC_FileSHA512(filename) {
	return LC_CalcFileHash(filename, 0x800e, 64 * 1024)
}
LC_AddrSHA512(addr, length) {
	return LC_CalcAddrHash(addr, length, 0x800e)
}

LC_XOR_Encrypt(str,key) {
	EncLen:=StrPut(Str,"UTF-16")*2
	VarSetCapacity(EncData,EncLen)
	StrPut(Str,&EncData,"UTF-16")

	PassLen:=StrPut(key,"UTF-8")
	VarSetCapacity(PassData,PassLen)
	StrPut(key,&PassData,"UTF-8")

	LC_XOR(OutData,EncData,EncLen,PassData,PassLen)
	LC_Base64_Encode(OutBase64, OutData, EncLen)
	return OutBase64
}

LC_XOR_Decrypt(OutBase64,key) {
	EncLen:=LC_Base64_Decode(OutData, OutBase64)

	PassLen:=StrPut(key,"UTF-8")
	VarSetCapacity(PassData,PassLen)
	StrPut(key,&PassData,"UTF-8")

	LC_XOR(EncData,OutData,EncLen,PassData,PassLen)
	return StrGet(&EncData,"UTF-16")
}

LC_XOR(byref OutData,byref EncData,EncLen,byref PassData,PassLen)
{
	VarSetCapacity(OutData,EncLen)
	Loop % EncLen
		NumPut(NumGet(EncData,A_Index-1,"UChar")^NumGet(PassData,Mod(A_Index-1,PassLen),"UChar"),OutData,A_Index-1,"UChar")
}
