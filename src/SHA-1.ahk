LC_SHA(string, encoding = "UTF-8") {
	return LC_CalcStringHash(string, 0x8004, encoding)
}
LC_HexSHA(hexstring) {
	return LC_CalcHexHash(hexstring, 0x8004)
}
LC_FileSHA(filename) {
	return LC_CalcFileHash(filename, 0x8004, 64 * 1024)
}
LC_AddrSHA(addr, length) {
	return LC_CalcAddrHash(addr, length, 0x8004)
}