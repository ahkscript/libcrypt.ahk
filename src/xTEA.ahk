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

; Adapted from : http://www.cix.co.uk/%7Eklockstone/xtea.pdf
/*
Coding and Decoding Routine
----------------------------------------------------
v gives the plain text of 2 words,
k gives the key of 4 words,
N gives the number of cycles, 32 are recommended,
if negative causes decoding, N must b e the same as for coding,
if zero causes no coding or decoding.
assumes 32 bit "long" and same endian coding or decoding
*/
LC_xTEA_n(v,k,N) {
	y:=v[0], z:=v[1], DELTA:=0x9e3779b9
	if (N>0) {
		; coding
		limit:=DELTA*N, sum:=0
		while (sum!=limit)
			y+= (z<<4 ^ z>>5) + z ^ sum + k[sum&3], sum+=DELTA, z+= (y<<4 ^ y>>5) + y ^ sum + k[sum>>11 &3]
	} else {
		; decoding
		sum:=DELTA*(-N)
		while (sum)
			z-= (y<<4 ^ y>>5) + y ^ sum + k[sum>>11 &3], sum-=DELTA, y-= (z<<4 ^ z>>5) + z ^ sum + k[sum&3]
	}
	v[0]:=y, v[1]:=z
	return
}

/*
Coding and Decoding Routine
----------------------------------------------------
tea_b is a block version of tea_n.
It will encode or decode n words as a single block where n > 1.
v is the n word data vector,
k is the 4 word key.
n is negative for decoding,
if n is zero result is 1 and no coding or decoding takes place,
otherwise the result is zero.
assumes 32 bit "long" and same endian coding and decoding.
*/
LC_xTEA_b(v,n,k) {
	z:=v[n-1], sum:=0, DELTA:=0x9e3779b9
	if (n>1) {
		; Coding Part
		q:=6+(52/n)
		while (q-- > 0) {
			sum += DELTA
			e := sum>>2 & 3
			p:=0
			while (p<n) {
				z := (v[p] += (z<<4 ^ z>>5) + z ^ k[p&3^e] + sum)
				p++
			}
		}
		return 0
	}
	else if (n<-1) {
		; Decoding Part
		n := -n
		q:=6+(52/n)
		sum:=q*DELTA
		while (sum != 0) {
			e := sum>>2 & 3
			p:=n-1
			while (p>0) {
				z := v[p-1]
				v[p] -= (z<<4 ^ z>>5) + z ^ k[p&3^e] + sum
				p--
			}
			z := v[n-1]
			v[0] -= (z<<4 ^ z>>5) + z ^ k[p&3^e] + sum
			sum-=DELTA 
		}
		return 0
	}
	return 1 ; Signal n=0
}