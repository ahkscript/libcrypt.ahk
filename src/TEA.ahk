LC_TEA_Encrypt(Data,Keys:="") {
	return LC_TEA(Data,32,Keys)
}
LC_TEA_Decrypt(Data,Keys:="") {
	return LC_TEA(Data,-32,Keys)
}

LC_TEA(d,n,Keys:="") {
	; Default Keys
	static k := { 0 : 0xDEADDEAD		; 128-bit secret key
				, 1 : 0xFEEDFEED
				, 2 : 0xFADEFADE		; choose wisely!
				, 3 : 0x4BAD4BAD }
	
	Loop 4
	{
		if StrLen(Keys[A_Index])
			k[A_Index-1] := Keys[A_Index]
		else
			break
	}
	
	; Encode block n = +32
	; Decode block n = -32
	
	; Implementation [WIP]
	
	return
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
LC_xxTEA_Block(v,n,k) {
	z:=v[n-1], y:=v[0], sum:=0, DELTA:=0x9e3779b9
	if (n > 1) {			; Coding Part
		q = 6 + (52/n)
		while (q-- > 0) {
			sum += DELTA
			e := (sum >> 2) & 3
			p:=0
			while (p<n-1) {
				y := v[p+1], z := ( v[p] += ((z>>5)^(y<<2)) + (((y>>3)^(z<<4))^(sum^y)) + (k[(p&3)^e]^z) )
				p++
			}
			y := v[0]
			z := ( v[n-1] += ((z>>5)^(y<<2)) + (((y>>3)^(z<<4))^(sum^y)) + (k[(p&3)^e]^z) )
		}
		return 0
	} else if (n < -1) {	; Decoding Part
		n := -n
		q := 6 + (52/n)
		sum := q*DELTA
		while (sum != 0) {
			e := (sum >> 2) & 3
			p:=n-1
			while (p>0) {
				z := v[p-1], y := ( v[p] -= ((z>>5)^(y<<2)) + (((y>>3)^(z<<4))^(sum^y)) + (k[(p&3)^e]^z) )
				p--
			}
			z := v[n-1]
			y := ( v[0] -= ((z>>5)^(y<<2)) + (((y>>3)^(z<<4))^(sum^y)) + (k[(p&3)^e]^z) )
			sum -= DELTA
		}
		return 0
	}
	return 1
}