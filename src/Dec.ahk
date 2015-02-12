;from joedf : fork-fusion of jNizM+Laszlo's functions [to_decimal()+ToBase()]
LC_To_Dec(b, n) { ; 1 < b <= 36, n >= 0
	d:=0
	StringUpper,n,n
	loop % StrLen(n)
	{
		d *= b, k:=SubStr(n,A_Index,1)
		if k is not Integer
			k:=Asc(k)-55
		d += k
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
LC_Numvert(num,from,to) { ; from joedf : http://ahkscript.org/boards/viewtopic.php?f=6&t=6363
    return LC_From_Dec(to,LC_To_Dec(from,num))
}