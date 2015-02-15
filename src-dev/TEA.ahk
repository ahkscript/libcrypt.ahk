/*
Thanks to Chris Veness for some inspiration
https://github.com/chrisveness/crypto/blob/master/tea-block.js
*/
LC_TEA_Encrypt(Data,Pass:="") {
	return LC_TEA(Data,Pass,1)
}
LC_TEA_Decrypt(Data,Pass:="") {
	return LC_TEA(Data,Pass,-1)
}
LC_TEA(Data,Pass,z) {
	if (VarSetCapacity(Data) == 0) ; // nothing to encrypt
		return ""
	
	; Password must be 16 chars
	Pass := SubStr(Pass "0123456789ABCDEF",1,16)
	
	; Encode block n = +32
	; Decode block n = -32
	; 2 block (32 bits) in v[]
	
	; n > +1 = encoding
	if (z > 0) {
		v		:= LC_Str2Long(Data)
		k		:= LC_Str2Long(Pass)
		n		:= (v.MaxIndex() + 1)
		tData	:= LC_xxTEA_Block(v,n,k)
		sData	:= LC_Long2Str(tData)
		bData	:= LC_Base64_EncodeText(sData)
		return bData
	}
	
	; n < -1 = decoding
	if (z < 0) {
		bData	:= LC_Base64_DecodeText(Data)
		v		:= LC_Str2Long(bData)
		k		:= LC_Str2Long(Pass)
		n		:= (v.MaxIndex() + 1)
		tData	:= LC_xxTEA_Block(v,-n,k)
		sData	:= LC_Long2Str(tData)
		; strip trailing null chars resulting from filling 4-char blocks:
		;plaintext = plaintext.replace(/\0+$/,'')
		return sData
	}
	
	return ""
}
LC_Str2Long(s,len:=0) { ; Converts string to array of longs.
	len := (len>0)?len:StrLen(s)
	l := Object()
	i := 0
	while (i<len) {
		l[i] := Asc(SubStr(s,i*4,1)) + (Asc(SubStr(s,i*4+1,1))<<8) + (Asc(SubStr(s,i*4+2,1))<<16) + (Asc(SubStr(s,i*4+3,1))<<24)
		i++
	}
	return l ; note running off the end of the string generates nulls since bitwise operators
}
LC_Long2Str(l) { ; Converts array of longs to string.
	s := ""
	i := 0
	while (i<l.MaxIndex()) {
		s .= Chr(l[i] & 0xFF) Chr(l[i]>>8 & 0xFF) Chr(l[i]>>16 & 0xFF) Chr(l[i]>>24 & 0xFF)
		i++
	}
	return s
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
		return v ;return 0
	} else if (n < -1) {	; Decoding Part
		n := -n
		q := 6 + (52/n)
		sum := q*DELTA
		while (sum > 0) {	;joedf note: changed (sum != 0) to (sum > 0)
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
		return v ;return 0
	}
	return "" ;return 1
}