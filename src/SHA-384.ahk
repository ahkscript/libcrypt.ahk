LC_SHA384(string, encoding = "UTF-8") {
	return LC_CalcStringHash(string, 0x800d, encoding)
}
LC_HexSHA384(hexstring) {
	return LC_CalcHexHash(hexstring, 0x800d)
}
LC_FileSHA384(filename) {
	return LC_CalcFileHash(filename, 0x800d, 64 * 1024)
}
LC_AddrSHA384(addr, length) {
	return LC_CalcAddrHash(addr, length, 0x800d)
}