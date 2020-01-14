; implemented in ahk by joedf
; based on https://github.com/cryptii/cryptii/blob/4a0a58318d093c4c6e3333b3f296ad7c96309629/src/Encoder/Ascii85.js

LC_ASCII85_Encode(content, variant="") {
	
	; get bytes
	bytes := StrSplit(content)
	Loop % bytes.MaxIndex()
		bytes[A_Index] := Asc( bytes[A_Index] )

	; get variant
	if InStr(variant, "z") {
		variant := { "name": "Z85"
					,"label": "Z85 (ZeroMQ)"
					,"alphabet": StrSplit("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.-:+=^!/*?&<>()[]{}@%$#")
					,"zeroTupleChar": "null"}
	} else {
		variant := { "name": "original"
				,"label": "Original"
				,"alphabet": "null"
				,"zeroTupleChar": "z"}
	}

	; get number of bytes
	n := bytes.Length()

	; Encode each tuple of 4 bytes
	string := ""
	i := 1
	loop_max := ceil(n / 4)
	Loop, % loop_max
	{
		; Read 32-bit unsigned integer from bytes following the
		; big-endian convention (most significant byte first)
		if (i >= loop_max) ; handles the js-hack for falsy||0 test
			bytes.Push(0,0,0)
		tuple := ( ((bytes[i]) << 24)
			+ ((bytes[i + 1] |0) << 16)
			+ ((bytes[i + 2] |0) << 8)
			+ ((bytes[i + 3] |0)) )
			>> 0

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

			if (n < (i + 4)) {
				; Omit final characters added due to bytes of padding
				; >>>> digits.splice(n - (i + 4), 4)
				t_start := n - (i + 4)
				t_delCount := 4
				newarr := []
				Loop % digits.Length()
					if ( (A_Index <= t_start) || (A_Index > t_start + t_delCount) )
						newarr.push( digits[A_Index] )
				digits := newarr
			}

			; Convert digits to characters and glue them together
			/*
			string += digits.map(digit =>
				variant.alphabet === null
				? String.fromCharCode(digit + 33)
				: variant.alphabet[digit]
			).join('')
			*/
			for t_k, t_v in digits
			{
				if (variant["alphabet"] == "null") {
					t_c := chr(t_v + 33)
				} else {
					t_c := variant["alphabet"][t_v+1]
				}
				string .= t_c
			}

		} else {
			; An all-zero tuple is encoded as a single character
			string .= variant["zeroTupleChar"]
		}

		i += 4
	}

	return string
}

LC_ASCII85_Decode(str) {
	return "[WIP]"
}

/*
   * Triggered before performing decode on given content.
   * @protected
   * @param {Chain} content
   * @return {number[]|string|Uint8Array|Chain|Promise} Filtered content

  willDecode (content) {
    // Check for <~ ~> wrappers often used to wrap ascii85 encoded data
    const wrapperMatches = content.getString().match(/<~(.+?)~>/)
    if (wrapperMatches !== null) {
      // Decode wrapped data only
      return wrapperMatches[1]
    }
    return content
  }


   * Performs decode on given content.
   * @protected
   * @param {Chain} content
   * @return {number[]|string|Uint8Array|Chain|Promise} Decoded content

  performDecode (content) {
    const string = StringUtil.removeWhitespaces(content.getString())
    const variant = variantSpecs.find(variant =>
      variant.name === this.getSettingValue('variant'))
    const n = string.length

    // Decode each tuple of 5 characters
    const bytes = []
    let i = 0
    let digits, tuple, tupleBytes
    while (i < n) {
      if (string[i] === variant.zeroTupleChar) {
        // A single character encodes an all-zero tuple
        bytes.push(0, 0, 0, 0)
        i++
      } else {
        // Retrieve radix-85 digits of tuple
        digits = string
          .substr(i, 5)
          .split('')
          .map((character, index) => {
            const digit =
              variant.alphabet === null
                ? character.charCodeAt(0) - 33
                : variant.alphabet.indexOf(character)
            if (digit < 0 || digit > 84) {
              throw new InvalidInputError(
                `Invalid character '${character}' at index ${index}`)
            }
            return digit
          })

        // Create 32-bit binary number from digits and handle padding
        // tuple = a * 85^4 + b * 85^3 + c * 85^2 + d * 85 + e
        tuple =
          digits[0] * 52200625 +
          digits[1] * 614125 +
          (i + 2 < n ? digits[2] : 84) * 7225 +
          (i + 3 < n ? digits[3] : 84) * 85 +
          (i + 4 < n ? digits[4] : 84)

        // Get bytes from tuple
        tupleBytes = [
          (tuple >> 24) & 0xff,
          (tuple >> 16) & 0xff,
          (tuple >> 8) & 0xff,
          tuple & 0xff
        ]

        // Remove bytes of padding
        if (n < i + 5) {
          tupleBytes.splice(n - (i + 5), 5)
        }

        // Append bytes to result
        bytes.push.apply(bytes, tupleBytes)
        i += 5
      }
    }

    return new Uint8Array(bytes)
  }
}
*/