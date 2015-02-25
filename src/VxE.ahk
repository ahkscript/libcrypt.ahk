; FUnctions and algorithm by VxE
; intergrated into libcrypt.ahk with "LC_" prefixes

/*
####################################################################################################
####################################################################################################
######                                                                                        ######
######                                [VxE]-251 Encryption                                    ######
######                                          &                                             ######
######                                [VxE]-89  Encryption                                    ######
######                                                                                        ######
####################################################################################################
####################################################################################################

[VxE] 251 encryption is a rotation-based encryption algorithm using a dynamic key and a
dynamic map. The '251' indicates the size of the map, which omits the following byte-values:
0x00 ( null byte: string terminator )
0x09 ( tab character: common text formatting character )
0x0A ( newline character: common text formatting character )
0x0D ( carriage return character: common text formatting character )
0x7F ( wierd character: ascii 'del' )

This encryption function also supports an 89-character map, which incorporates the byte values
between 0x20 and 0x7e, omitting 0x22, 0x27, 0x2C, 0x2F, 0x5C, and 0x60. This mode allows text value
input to be encrypted as text without high-ascii characters or non-printable characters.
*/

; ##################################################################################################
; ## Function shortcuts

LC_VxE_Encrypt89( key, byref message ) { ; ----------------------------------------------------------
   Return LC_VxE_Crypt( key, message, 1, "vxe89 len" StrLen( message ) << !!A_IsUnicode )
} ; VxE_Encrypt89( key, byref message ) ----------------------------------------------------------

LC_VxE_Decrypt89( key, byref message ) { ; ----------------------------------------------------------
   Return LC_VxE_Crypt( key, message, 0, "vxe89 len" StrLen( message ) << !!A_IsUnicode )
} ; VxE_Decrypt89( key, byref message ) ----------------------------------------------------------

LC_VxE_Encrypt251( key, byref message, len ) { ; ----------------------------------------------------
   Return LC_VxE_Crypt( key, message, 1, "len" len )
} ; VxE_Encrypt251( key, byref message, len ) ----------------------------------------------------

LC_VxE_Decrypt251( key, byref message, len ) { ; ----------------------------------------------------
   Return LC_VxE_Crypt( key, message, 0, "len" len )
} ; VxE_Decrypt251( key, byref message, len ) ----------------------------------------------------

; ##################################################################################################
; ## The core function

LC_VxE_Crypt( key, byref message, direction = 1, options="" ) { ; -----------------------------------
; Transorms the message. 'direction' indicates whether or not to decrypt or encrypt the message.
; However, since this algorithm is symmetrical, distinguishing between 'encrypt' and 'decrypt' is
; merely for the benefit of human understanding.

; This agorithm was developed by [VxE] in July 2010. When a key/message are passed to this function,
; it generates the rotation map using the key. Then, it traverses the bytes in the message, rotating
; their values along the map according to the key. Once the character's encoded value is determined,
; the key is augmented by a value based on the byte value.

   If !RegexMatch( options, "i)(?:len|l)\K(?:0x[\da-fA-F]+|\d+)", length ) ; check explicit length
      length := StrLen( message ) << !!A_IsUnicode ; otherwise, find length.
   UseVxE89 := InStr( options, "vxe89" ) ; check 'options' for text-friendly mode.
   direction := 2 * ( direction = 1 ) - 1 ; coerce the 'direction' to either +1 or -1.

   w := StrLen( key ) << !!A_IsUnicode
   ; 'w' holds the derived key, which is a 32-bit integer based on the key.
   ; Although this doesn't seem very entropic, remember that the map is also derived from the key.
   
   If (UseVxE89) ; using the smaller map allows text-friendly encrypting since the small map is
      Loop 126 ; composed only of low-ascii printable characters
         If ( A_Index >= 32 && A_Index != 34 && A_Index != 39 && A_Index != 44
         && A_Index != 47 && A_Index != 92 && A_Index != 96 )
            map .= Chr( A_Index )
   If !UseVxE89 ; the 251 map is more suitable for non-text data
      Loop 255
         If ( A_Index != 9 && A_Index != 10 && A_Index != 13 && A_Index != 127 )
            map .= Chr( A_Index )
   k := StrLen( map ) ; keep the length of the map

   Loop 9 ; pad the key up to 509 characters, mixing in digit-characters
      If StrLen( key ) < 509
         key := SubStr( key Chr( 48 + A_Index ) key, 1, 509 )

   Loop 509 ; rearrange the map, using the padded key as the selector.
   { ; This is how the map becomes dynamic. 509 times, a char is selected from the map and
   ; is extracted from the map string, then appended to it. At the same time, the derived key is
   ; augmented by XORing it with a value based on each byte in the key.
      q := *( &key + A_Index - 1 )
      pos := 1 + Mod( q * A_Index * 3, k )
      StringMid, e, map, %pos%, 1
      StringLeft, i, map, pos - 1
      StringTrimLeft, c, map, %pos%
      map := i c e
      w ^= q * A_Index * 1657
   }
   x := 0
   Loop %length%
   {
      c := NumGet( message, A_Index - 1, "UChar" ) ; for each byte in the message

      If !c || !( i := InStr( map, Chr( c ), 1 ) )
         Continue ; if the character isn't in the map, just skip it.
      i-- ; the map index should be zero based for easier use with Mod() function
      x++ ; this tracks the actual index, not the char position.

      e := Mod( 223390000 + i + w * direction, k ) ; rotate the index along the map

      c := Asc( SubStr( map, e + 1, 1 ) ) ; lookup the character at the rotated index

      NumPut( c, message, A_Index - 1, "UChar" ) ; append the newly-mapped char to the result

      ; Finally, depending on the direction of rotation, use either the original index or
      ; the rotated index to augment the derived key
      If ( direction = 1 )
         c := Mod( e + x, 251 )
      Else c := Mod( i + x, 251 )
      w ^= c | c << 8 | c << 16 | c << 24
   }
   return length
} ; VxE_Crypt( key, byref message, direction = 1, options="" ) -----------------------------------