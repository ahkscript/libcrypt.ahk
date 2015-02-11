LC_XOR_Encrypt(str,key,delim:=":") {
	r:="", k:=StrSplit(key), m:=Strlen(key)
	for i, c in StrSplit(str)
		r .= LC_Dec2Hex(Asc(c)^Asc(k[mod(i,m)])) delim
	return SubStr(r,1,-1)
}

LC_XOR_Decrypt(str,key,delim:=":") {
	r:="", k:=StrSplit(key), m:=Strlen(key)
	for i, n in StrSplit(str,delim)
		r .= Chr(LC_Hex2Dec(n)^Asc(k[mod(i,m)]))
	return r
}