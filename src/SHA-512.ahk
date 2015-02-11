LC_SHA512(string, encoding = "UTF-8") {
	return LC_CalcStringHash(string, 0x800e, encoding)
}
LC_HexSHA512(hexstring) {
	return LC_CalcHexHash(hexstring, 0x800e)
}
LC_FileSHA512(filename) {
	return LC_CalcFileHash(filename, 0x800e, 64 * 1024)
}
LC_AddrSHA512(addr, length) {
	return LC_CalcAddrHash(addr, length, 0x800e)
}