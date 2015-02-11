LC_SHA256(string, encoding = "UTF-8") {
	return LC_CalcStringHash(string, 0x800c, encoding)
}
LC_HexSHA256(hexstring) {
	return LC_CalcHexHash(hexstring, 0x800c)
}
LC_FileSHA256(filename) {
	return LC_CalcFileHash(filename, 0x800c, 64 * 1024)
}
LC_AddrSHA256(addr, length) {
	return LC_CalcAddrHash(addr, length, 0x800c)
}