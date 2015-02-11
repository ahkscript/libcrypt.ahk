LC_To_Dec(from, n) {
	h := SubStr("0123456789ABCDEF", 1, from)
	d := 0
	loop % StrLen(n)
	{
		d *= from
		StringGetPos, p, h, % SubStr(n, A_Index, 1)
		if (p = -1)
			return p
		d += p
	}
	return d
}
;from Laszlo : http://www.autohotkey.com/board/topic/15951-base-10-to-base-36-conversion/#entry103624
LC_From_Dec(b,n) { ; 1 < b <= 36, n >= 0
	Loop {
		d := mod(n,b), n //= b
		m := (d < 10 ? d : Chr(d+55)) . m
		IfLess n,1, Break
	}
	Return m
}
LC_Dec2Hex(x) {
	return LC_From_Dec(16,x)
}
LC_Hex2Dec(x) {
	return LC_To_Dec(16,x)
}