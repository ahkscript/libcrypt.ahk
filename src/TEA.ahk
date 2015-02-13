LC_TEA_Encrypt(Data,Pass:="") {
	key:=""
	Loop, Parse, Pass
	{
		k .= Asc(A_LoopField)
		if (A_Index>=16)
			break
	}
	return LC_TEA(Data,32,Keys)
}
LC_TEA_Decrypt(Data,Pass:="") {
	return LC_TEA(Data,-32,Keys)
}

/*
Thanks to Chris Veness for inspiration
https://github.com/chrisveness/crypto/blob/master/tea-block.js
*/
/*
Tea.encrypt = function(plaintext, password) {
plaintext = String(plaintext);
password = String(password);
if (plaintext.length == 0) return(''); // nothing to encrypt
// v is n-word data vector; converted to array of longs from UTF-8 string
var v = Tea.strToLongs(plaintext.utf8Encode());
// k is 4-word key; simply convert first 16 chars of password as key
var k = Tea.strToLongs(password.utf8Encode().slice(0,16));
var n = v.length;
v = Tea.encode(v, k);
// convert array of longs to string
var ciphertext = Tea.longsToStr(v);
// convert binary string to base64 ascii for safe transport
return ciphertext.base64Encode();
};

Tea.decrypt = function(ciphertext, password) {
ciphertext = String(ciphertext);
password = String(password);
if (ciphertext.length == 0) return('');
// v is n-word data vector; converted to array of longs from base64 string
var v = Tea.strToLongs(ciphertext.base64Decode());
// k is 4-word key; simply convert first 16 chars of password as key
var k = Tea.strToLongs(password.utf8Encode().slice(0,16));
var n = v.length;
v = Tea.decode(v, k);
var plaintext = Tea.longsToStr(v);
// strip trailing null chars resulting from filling 4-char blocks:
plaintext = plaintext.replace(/\0+$/,'');
return plaintext.utf8Decode();
};

Tea.strToLongs = function(s) {
// note chars must be within ISO-8859-1 (Unicode code-point <= U+00FF) to fit 4/long
var l = new Array(Math.ceil(s.length/4));
for (var i=0; i<l.length; i++) {
// note little-endian encoding - endianness is irrelevant as long as it matches longsToStr()
l[i] = s.charCodeAt(i*4) + (s.charCodeAt(i*4+1)<<8) +
(s.charCodeAt(i*4+2)<<16) + (s.charCodeAt(i*4+3)<<24);
}
return l; // note running off the end of the string generates nulls since bitwise operators
}; // treat NaN as 0
;**
;* Converts array of longs to string.
;* @private
;*/
Tea.longsToStr = function(l) {
var a = new Array(l.length);
for (var i=0; i<l.length; i++) {
a[i] = String.fromCharCode(l[i] & 0xFF, l[i]>>>8 & 0xFF, l[i]>>>16 & 0xFF, l[i]>>>24 & 0xFF);
}
return a.join(''); // use Array.join() for better performance than repeated string appends
};

;** Extend String object with method to encode multi-byte string to utf8
;* - monsur.hossa.in/2012/07/20/utf-8-in-javascript.html
;*
if (typeof String.prototype.utf8Encode == 'undefined') {
String.prototype.utf8Encode = function() {
return unescape( encodeURIComponent( this ) );
};
}
;** Extend String object with method to decode utf8 string to multi-byte
if (typeof String.prototype.utf8Decode == 'undefined') {
String.prototype.utf8Decode = function() {
try {
return decodeURIComponent( escape( this ) );
} catch (e) {
return this; // invalid UTF-8? return as-is
}
};
}
*/




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
	; 2 block (32 bits) in v[]
	
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