LC_MD4(string, encoding = "UTF-8") {
	return LC_CalcStringHash(string, 0x8002, encoding)
}
LC_HexMD4(hexstring) {
	return LC_CalcHexHash(hexstring, 0x8002)
}
LC_FileMD4(filename) {
	return LC_CalcFileHash(filename, 0x8002, 64 * 1024)
}
LC_AddrMD4(addr, length) {
	return LC_CalcAddrHash(addr, length, 0x8002)
}