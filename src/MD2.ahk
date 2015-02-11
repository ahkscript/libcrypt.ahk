LC_MD2(string, encoding = "UTF-8") {
	return LC_CalcStringHash(string, 0x8001, encoding)
}
LC_HexMD2(hexstring) {
	return LC_CalcHexHash(hexstring, 0x8001)
}
LC_FileMD2(filename) {
	return LC_CalcFileHash(filename, 0x8001, 64 * 1024)
}
LC_AddrMD2(addr, length) {
	return LC_CalcAddrHash(addr, length, 0x8001)
}