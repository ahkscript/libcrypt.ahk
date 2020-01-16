/* from AHK forums
Fast 64- and 128-bit hash functions
Originally created by Laszlo , Jan 01 2007 06:59 PM 

https://autohotkey.com/board/topic/14040-fast-64-and-128-bit-hash-functions/

Here are two of hash functions, which
- are programmed fully in AHK
- are much faster than cryptographic hash functions
- provide long enough hash values (64 or 128 bits), so a collision is very unlikely

They are modeled after Linear Feedback Shift Register (LFSR) based hash functions, like CRC-32.

joedf: modified/updated for inclusion in libcrypt.ahk
The dynamic __LC_LHashTable global array variable is kept global in the interest of speed for successive calls.
*/

LC_L64Hash(x) {                        ; 64-bit generalized LFSR hash of string x
	Local i, R = 0
	__LC_LHash_LHashInit()             ; 1st time set LHASH0..LHAS256 global table
	Loop Parse, x
	{
		i := (R >> 56) & 255           ; dynamic vars are global
		R := (R << 8) + Asc(A_LoopField) ^ __LC_LHashTable%i%
	}
	Return __LC_LHash_Hex8(R>>32) . __LC_LHash_Hex8(R)
}

LC_L128Hash(x) {                       ; 128-bit generalized LFSR hash of string x
	Local i, S = 0, R = -1
	__LC_LHash_LHashInit()             ; 1st time set LHASH0..LHAS256 global table
	Loop Parse, x
	{
		i := (R >> 56) & 255           ; dynamic vars are global
		R := (R << 8) + Asc(A_LoopField) ^ __LC_LHashTable%i%
		i := (S >> 56) & 255
		S := (S << 8) + Asc(A_LoopField) - __LC_LHashTable%i%
	}
	Return __LC_LHash_Hex8(R>>32) . __LC_LHash_Hex8(R) . __LC_LHash_Hex8(S>>32) . __LC_LHash_Hex8(S)
}

__LC_LHash_Hex8(i) {                   ; integer -> LS 8 hex digits
	SetFormat Integer, Hex
	i:= 0x100000000 | i & 0xFFFFFFFF   ; mask LS word, set bit32 for leading 0's --> hex
	SetFormat Integer, D
	Return SubStr(i,-7)                ; 8 LS digits = 32 unsigned bits
}

__LC_LHash_LHashInit() {               ; build pseudorandom substitution table
	Local i, u = 0, v = 0
	If __LC_LHashTable0=
		Loop 256 {
			i := A_Index - 1
			__LC_LHASH_TEA(u,v, 1,22,333,4444, 8) ; <- to be portable, no Random()
			__LC_LHashTable%i% := (u<<32) | v
		}
}
;                                      ; [y,z] = 64-bit I/0 block, [k0,k1,k2,k3] = 128-bit key
__LC_LHASH_TEA(ByRef y,ByRef z, k0,k1,k2,k3, n = 32) { ; n = #Rounds
	s := 0, d := 0x9E3779B9
	Loop %n% {                         ; standard = 32, 8 for speed
		k := "k" . s & 3               ; indexing the key
		y := 0xFFFFFFFF & (y + ((z << 4 ^ z >> 5) + z  ^  s + %k%))
		s := 0xFFFFFFFF & (s + d)      ; simulate 32 bit operations
		k := "k" . s >> 11 & 3
		z := 0xFFFFFFFF & (z + ((y << 4 ^ y >> 5) + y  ^  s + %k%))
	}
}