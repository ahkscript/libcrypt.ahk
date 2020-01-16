; implemented in ahk by joedf
; based on https://github.com/cryptii/cryptii/blob/4a0a58318d093c4c6e3333b3f296ad7c96309629/src/Encoder/Ascii85.js

/**
 * Performs encode on given content.
 * @param {String} content
 * @param {String} variant 
 * @return {String} Encoded content
 */
LC_ASCII85_Encode(content, variant="") {
	; Check for <~ ~> wrappers often used to wrap ascii85 encoded data
	; Decode wrapped data only
	content:=StrReplace(content,"<~")
	content:=StrReplace(content,"~>")
	
	; get bytes
	bytes := StrSplit(content)
	Loop % bytes.MaxIndex()
		bytes[A_Index] := Asc( bytes[A_Index] )

	; get variant
	variant := __LC_ASCII85_getVariant(variant)

	; get number of bytes
	n := bytes.Length()

	; Encode each tuple of 4 bytes
	string := ""
	i := 1
	while (i <= n)
	{
		; Read 32-bit unsigned integer from bytes following the
		; big-endian convention (most significant byte first)
		/*
		tuple = (
			((bytes[i]) << 24) +
			((bytes[i + 1] || 0) << 16) +
			((bytes[i + 2] || 0) << 8) +
			((bytes[i + 3] || 0))
		) >>> 0
		*/
		if (i-1 + 4 > n) ; handles the js-hack for falsy||0 test
			bytes.Push(0,0,0)
		tuple := ( ((bytes[i]) << 24)
			+ ((bytes[i + 1]) << 16)
			+ ((bytes[i + 2]) << 8)
			+ ((bytes[i + 3]))) >> 0
		
		if ( (variant["zeroTupleChar"] == "null") || (tuple > 0) )
		{
			; Calculate 5 digits by repeatedly dividing
			; by 85 and taking the remainder
			digits := []
			Loop, 5
			{
				digits.Push( mod(tuple,85) )
				tuple := tuple // 85
			}

			; Take most significant digit first
			; >>>> digits = digits.reverse()
			; following is based method by jNizM from https://github.com/jNizM/AHK_Scripts/blob/master/src/arrays/RevArr.ahk
			newarr := []
			for t_idx, t_val in digits
				newarr.InsertAt(1, t_val)
			digits := newarr

			if (n < (i-1 + 4)) {
				; Omit final characters added due to bytes of padding
				; >>>> digits.splice(n - (i + 4), 4)
				digits := __LC_ASCII85_splice(digits,n - (i-1 + 4), 4)
			}

			; Convert digits to characters and glue them together
			for t_k, t_v in digits
				string .= (variant["alphabet"] == "null")
					? chr(t_v + 33)
					: SubStr(variant["alphabet"],t_v+1,1)

		} else {
			; An all-zero tuple is encoded as a single character
			string .= variant["zeroTupleChar"]
		}

		i += 4
	}

	return string
}

; Helper function (not to create global vars), to return the variant associated information
__LC_ASCII85_getVariant(variant="") {
	if InStr(variant, "z")
		return { "name": "Z85"
				,"label": "Z85 (ZeroMQ)"
				,"alphabet": "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.-:+=^!/*?&<>()[]{}@%$#"
				,"zeroTupleChar": "null"}
	return { "name": "original"
			,"label": "Original"
			,"alphabet": "null"
			,"zeroTupleChar": "z"}
}

; AHK minimum (no add-item feature) Polyfill for javascript's Array.prototype.splice()
; uses 0-based index, not ahk's default count starting at 1 instead of 0.
__LC_ASCII85_splice(arr, start, deleteCount="") {
	len := arr.Length()
	newarr := []

	startIndex := start
	if (start > len) {
		startIndex := len
	} else if (start < 0) {
		startIndex := len + start
	}

	if (len + start < 0)
		startIndex := 0
	
	Loop % startIndex
		newarr.push( arr[A_Index] )

	; check if deleteCount is specified
	if (StrLen(deleteCount)) {
		
		; dont omit anything if deleteCount <= 0
		if (deleteCount<0)
			deleteCount:=0
		
		j := 1 + startIndex+deleteCount
		while (j <= len) {
			newarr.push( arr[j] )
			j++
		}
	}

	return newarr
}

/*
 * Performs decode on given content.
 * @param {String} content
 * @return {String} Decoded content
 */
LC_ASCII85_Decode(content, variant="") {
	; Remove whitespaces
	string := Trim(content)
	
	; Get variant
	variant := __LC_ASCII85_getVariant(variant)
	
	; get length
	n := StrLen(string)

	; Decode each tuple of 5 characters
	bytes := []
	i := 1
	while (i <= n) {
		if (SubStr(string,i,1) == variant.zeroTupleChar) {
			; A single character encodes an all-zero tuple
			bytes.Push(0, 0, 0, 0)
			i++
		} else {
			; Retrieve radix-85 digits of tuple
			digits := StrSplit(SubStr(string,i,5))
			newarr := []
			for index, character in digits
			{
				digit := (variant["alphabet"] == "null")
					? digit := Asc(character) - 33
					: digit := InStr(variant["alphabet"],character)-1
				if (digit < 0 || digit > 84) {
					throw Format("Invalid character '{1}' at index {2}", character, index)
				}
				newarr.Push(digit)
			}
			digits := newarr

			; Create 32-bit binary number from digits and handle padding
			; tuple = a * 85^4 + b * 85^3 + c * 85^2 + d * 85 + e
			tuple := 0
				+ digits[1] * 52200625
				+ digits[2] * 614125
				+ (i-1 + 2 < n ? digits[3] : 84) * 7225
				+ (i-1 + 3 < n ? digits[4] : 84) * 85
				+ (i-1 + 4 < n ? digits[5] : 84)

			; Get bytes from tuple
			tupleBytes := [(tuple >> 24) & 0xff
						,  (tuple >> 16) & 0xff
						,  (tuple >> 8) & 0xff
						,   tuple & 0xff ]

			; Remove bytes of padding
			if (n < i-1 + 5) {
				tupleBytes := __LC_ASCII85_splice(tupleBytes, n - (i-1 + 5), 5)
			}

			; Append bytes to result
			for t_k, t_v in tupleBytes
				bytes.Push(t_v)

			i += 5
		}
	}

	; joedf: transform bytes array to string
	decoded := ""
	for k, v in bytes
		decoded .= Chr(v)
	
	return decoded
}