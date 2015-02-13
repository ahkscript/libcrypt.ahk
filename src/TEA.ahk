/*
AutoHotkey Version: 1.0.35+
Language:  English
Platform:  Win2000/XP
Author:    Laszlo Hars <www.Hars.US>

Plus-minus Counter Mode: stream cipher using add/subtract with reduced range
   (32...126). Characters outside remain unchanged (TAB, CR, LF, ...).
   Lines will remain of the same length. If it leaks information, pad!

The underlying cipher is TEA, the Tiny Encryption Algorithm
http://www.simonshepherd.supanet.com/tea.htm It is one of the fastest and most
efficient cryptographic algorithms. It was developed by David Wheeler and Roger
Needham at the Computer Laboratory of Cambridge University. It is a Feistel
cipher, which uses operations from mixed (orthogonal) algebraic groups - XOR,
ADD and SHIFT in this case. It encrypts 64 data bits at a time using a 128-bit
key. It seems highly resistant to differential cryptanalysis, and achieves
complete diffusion (where a one bit difference in the plaintext will cause
approximately 32 bit differences in the ciphertext) after only six rounds.

Version:   1.0  2005.07.08  First created
Version:   2.0  2015.02.12  Updated as functions by joedf for Libcrypt
*/

LC_TEA_Encrypt(Data)				; Text, key-name
{
	static k1 := 0x11111111			; 128-bit secret key
	static k2 := 0x22222222
	static k3 := 0x33333333			; choose wisely!
	static k4 := 0x44444444

	Local p, i, L, u, v, k5, a, c, IV
	bkpBL:=A_BatchLines,bkpSCS:=A_StringCaseSense,bkpAT:=A_AutoTrim,bkpFI:=A_FormatInteger
	SetBatchLines -1
	StringCaseSense Off
	AutoTrim Off

	k5:=SubStr(A_NowUTC,1,8)		; current time
	v:=SubStr(A_NowUTC,-5)
	v:=(v*1000)+A_MSec				; in MSec
	SetFormat,Integer,H
	TEA(k5,v,k1,k2,k3,k4)			; k5 = IV: starting random counter value
	SetFormat,Integer,D
	u:="0000000" . SubStr(k5,3)
	IV:=SubStr(u,-7)				; 8-digit hex w/o 0x

	i := 9							; pad-index, force restart
	p := 0							; counter to be encrypted
	L := IV							; IV prepended to processed text
	Loop % StrLen(Data)
	{
		i++
		IfGreater i,8, {           ; all 9 pad values exhausted
			u := p
			v := k5                 ; IV
			p++                     ; increment counter
			TEA(u,v,k1,k2,k3,k4)
			Stream9(u,v)            ; 9 pads from encrypted counter
			i = 0
		}
		StringMid c, Data, A_Index, 1
		a := Asc(c)
		if a between 32 and 126
		{                          ; chars > 126 or < 31 unchanged
			a += s%i%
			IfGreater a, 126, SetEnv, a, % a-95
			c := Chr(a)
		}
		L = %L%%c%                 ; attach encrypted character
	}
	SetBatchLines,%bkpBL%
	StringCaseSense,%bkpSCS%
	AutoTrim,%bkpAT%
	SetFormat,Integer,%bkpFI%
	Return L
}


decrypt(T,key)                   ; Text, key-name
{
   Local p, i, L, u, v, k5, a, c

   StringLeft p, T, 8
   If p is not xdigit            ; if no IV: Error
   {
      ErrorLevel = 1
      Return
   }
   StringTrimLeft T, T, 8        ; remove IV from text (no separator)
   k5 = 0x%p%                    ; set new IV
   p = 0                         ; counter to be encrypted
   i = 9                         ; pad-index, force restart
   L =                           ; processed text
   k0 := %key%0
   k1 := %key%1
   k2 := %key%2
   k3 := %key%3
   Loop % StrLen(T)
   {
      i++
      IfGreater i,8, {           ; all 9 pad values exhausted
         u := p
         v := k5                 ; IV
         p++                     ; increment counter
         TEA(u,v, k0,k1,k2,k3)
         Stream9(u,v)            ; 9 pads from encrypted counter
         i = 0
      }
      StringMid c, T, A_Index, 1
      a := Asc(c)
      if a between 32 and 126
      {                          ; chars > 126 or < 31 unchanged
         a -= s%i%
         IfLess a, 32, SetEnv, a, % a+95
         c := Chr(a)
      }
      L = %L%%c%                 ; attach encrypted character
   }
   Return L
 }

TEA(ByRef y,ByRef z,k0,k1,k2,k3)	; (y,z) = 64-bit I/0 block
{									; (k0,k1,k2,k3) = 128-bit key
	IntFormat = %A_FormatInteger%
	SetFormat Integer, D			; needed for decimal indices
	s := 0
	d := 0x9E3779B9
	Loop 32
	{
		k := "k" . s & 3			; indexing the key
		y := 0xFFFFFFFF & (y + ((z << 4 ^ z >> 5) + z  ^  s + %k%))
		s := 0xFFFFFFFF & (s + d)	; simulate 32 bit operations
		k := "k" . s >> 11 & 3
		z := 0xFFFFFFFF & (z + ((y << 4 ^ y >> 5) + y  ^  s + %k%))
	}
	SetFormat Integer, %IntFormat%
	y += 0
	z += 0							; Convert to original ineger format
}

Stream9(x,y)	; Convert 2 32-bit words to 9 pad values
{				; 0 <= s0, s1, ... s8 <= 94
	Local z		; makes all s%i% global
		s0 := Floor(x*0.000000022118911147) ; 95/2**32
	Loop 8
	{
		z := (y << 25) + (x >> 7) & 0xFFFFFFFF
		y := (x << 25) + (y >> 7) & 0xFFFFFFFF
		x  = %z%
		s%A_Index% := Floor(x*0.000000022118911147)
	}
}