;
; Date Updated:
;	Friday, November 23rd, 2012 - Tuesday, February 10th, 2015
;
; Script Function:
;	Function Library to Encrypt / Decrypt in Div2 (by Joe DF)
;	Div2 was invented with a friend for fun, back in ~2010.
;	The string is "divided" in 2 during encryption. It is a 
;	simple reordering of the characters in a string. The was
; 	to have a human-readable/decryptable message.
;
; Notes:
;	AutoTrim should turned off, for the encryption to work properly
;	because, in Div2, <spaces> and <New lines> count as a character.
;

LC_Div2_encode(input, WithAutoTrim:=1, numproc:=1) {
	if (WithAutoTrim)
		StringReplace,input,input,%A_Space%,_,A
	loop, %numproc%
	{
		final:="", inputlen := StrLen(input)
		divmax := ceil((0.5 * inputlen) + 1)
		loop, %inputlen%
		{
			temp := SubStr(input,A_Index,1)
			q := inputlen + 1 - A_Index
			temp2 := SubStr(input,q,1)
			if (A_Index < divmax) {
				final .= temp
				if (A_Index != q)
					final .= temp2
			}
			if (A_Index >= divmax)
				Break
		}
		input := final
	}
	return final
}

LC_Div2_decode(input, WithAutoTrim:=1, numproc:=1) {
	if (WithAutoTrim)
		StringReplace,input,input,%A_Space%,_,A
	loop, %numproc%
	{
		i := 1, final:="", inputlen := StrLen(input)
		loop, % loopc := ceil(inputlen * (1/2))
		{	
			if (i <= inputlen)
				final .= SubStr(input,i,1)
			i += 2
		}
		i := inputlen
		loop, %loopc%
		{		
			if (i <= inputlen) {
				if (mod(SubStr(i,0,1)+0,2)==1) {
					if (i != 1)
						final .= SubStr(input,i-1,1)
				} else {
					final .= SubStr(input,i,1)
				}
			}
			i -= 2
		}
		input := final
	}
	return final
}
