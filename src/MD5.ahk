LC_MD5(string, encoding = "UTF-8") {
	return LC_CalcStringHash(string, 0x8003, encoding)
}
LC_HexMD5(hexstring) {
	return LC_CalcHexHash(hexstring, 0x8003)
}
LC_FileMD5(filename) {
	return LC_CalcFileHash(filename, 0x8003, 64 * 1024)
}
LC_AddrMD5(addr, length) {
	return LC_CalcAddrHash(addr, length, 0x8003)
}