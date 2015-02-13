
LC_TEA_Encrypt(Data,Keys:="") {
	
	; Default Keys
	static k := { 0 : 0x11111111		; 128-bit secret key
				, 1 : 0x22222222
				, 2 : 0x33333333		; choose wisely!
				, 3 : 0x44444444 }
	
	Loop 4
	{
		if StrLen(Keys[A_Index])
			k[A_Index-1] := Keys[A_Index]
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


LC_TEA_Decrypt(Data,Keys:="") {
	
	; Default Keys
	static k := { 0 : 0x11111111		; 128-bit secret key
				, 1 : 0x22222222
				, 2 : 0x33333333		; choose wisely!
				, 3 : 0x44444444 }
	
	Loop 4
	{
		if StrLen(Keys[A_Index])
			k[A_Index-1] := Keys[A_Index]
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
/*
xTEA subroutines adapted from : http://en.wikipedia.org/wiki/XXTEA

Coding and Decoding Routine
----------------------------------------------------
    BTEA will encode or decode n words as a single block where n > 1
		- v is the n word data vector
		- k is the 4 word key
		- n is negative for decoding
		- if n is zero result is 1 and no coding or decoding takes place, otherwise the result is zero
		- assumes 32 bit 'long' and same endian coding and decoding
*/
#define MX ((z>>5)^(y<<2)) + (((y>>3)^(z<<4))^(sum^y)) + (k[(p&3)^e]^z);

long btea(long* v, long n, long* k) {
	unsigned long z=v[n-1], y=v[0], sum=0, e, DELTA=0x9e3779b9;
	long p, q ;
	if (n > 1) {          /* Coding Part */
		q = 6 + 52/n;
		while (q-- > 0) {
			sum += DELTA;
			e = (sum >> 2) & 3;
			for (p=0; p<n-1; p++) y = v[p+1], z = v[p] += MX;
			y = v[0];
			z = v[n-1] += MX;
		}
		return 0 ; 
	} else if (n < -1) {  /* Decoding Part */
		n = -n;
		q = 6 + 52/n;
		sum = q*DELTA ;
		while (sum != 0) {
			e = (sum >> 2) & 3;
			for (p=n-1; p>0; p--) z = v[p-1], y = v[p] -= MX;
			z = v[n-1];
			y = v[0] -= MX;
			sum -= DELTA;
		}
		return 0;
	}
	return 1;
}