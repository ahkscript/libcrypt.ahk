; http://www.cix.co.uk/%7Eklockstone/xtea.pdf
LC_xTEA_Encrypt(Data,Keys:="") {
	
	; Default Keys
	static k := [ 0x11111111		; 128-bit secret key
				, 0x22222222
				, 0x33333333		; choose wisely!
				, 0x44444444 ]
	
	Loop 4
	{
		if StrLen(k[A_Index])
			k[A_Index] := Keys[A_Index]
		else
			break
	}
	
	bkpBL:=A_BatchLines,bkpSCS:=A_StringCaseSense,bkpAT:=A_AutoTrim,bkpFI:=A_FormatInteger
	SetBatchLines -1
	StringCaseSense Off
	AutoTrim Off

	k5:=SubStr(A_NowUTC,1,8)		; current time
	v:=SubStr(A_NowUTC,-5)
	v:=LC_Hex2Dec((v*1000)+A_MSec)	; in MSec

	
	; Implementation
	
	
	SetBatchLines,%bkpBL%
	StringCaseSense,%bkpSCS%
	AutoTrim,%bkpAT%
	SetFormat,Integer,%bkpFI%
	
	Return L
}


LC_xTEA_Decrypt(Data,Keys:="") {
	
	; Default Keys
	static k := [ 0x11111111		; 128-bit secret key
				, 0x22222222
				, 0x33333333		; choose wisely!
				, 0x44444444 ]
	
	Loop 4
	{
		if StrLen(k[A_Index])
			k[A_Index] := Keys[A_Index]
		else
			break
	}
	
	bkpBL:=A_BatchLines,bkpSCS:=A_StringCaseSense,bkpAT:=A_AutoTrim
	SetBatchLines -1
	StringCaseSense Off
	AutoTrim Off
	
	
	; Implementation
	
	
	SetBatchLines,%bkpBL%
	StringCaseSense,%bkpSCS%
	AutoTrim,%bkpAT%
	
	Return L
}