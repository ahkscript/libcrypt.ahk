LC_CRC32(string, encoding = "UTF-8") {
	chrlength := (encoding = "CP1200" || encoding = "UTF-16") ? 2 : 1
	length := (StrPut(string, encoding) - 1) * chrlength
	VarSetCapacity(data, length, 0)
	StrPut(string, &data, floor(length / chrlength), encoding)
	hMod := DllCall("Kernel32.dll\LoadLibrary", "Str", "Ntdll.dll")
	SetFormat, Integer, % SubStr((A_FI := A_FormatInteger) "H", 0)
	CRC32 := DllCall("Ntdll.dll\RtlComputeCrc32", "UInt", 0, "UInt", &data, "UInt", length, "UInt")
	CRC := SubStr(CRC32 | 0x1000000000, -7)
	DllCall("User32.dll\CharLower", "Str", CRC)
	SetFormat, Integer, %A_FI%
	return CRC, DllCall("Kernel32.dll\FreeLibrary", "Ptr", hMod)
}
LC_HexCRC32(hexstring) {
	length := StrLen(hexstring) // 2
	VarSetCapacity(data, length, 0)
	loop % length
	{
		NumPut("0x" SubStr(hexstring, 2 * A_Index -1, 2), data, A_Index - 1, "Char")
	}
	hMod := DllCall("Kernel32.dll\LoadLibrary", "Str", "Ntdll.dll")
	SetFormat, Integer, % SubStr((A_FI := A_FormatInteger) "H", 0)
	CRC32 := DllCall("Ntdll.dll\RtlComputeCrc32", "UInt", 0, "UInt", &data, "UInt", length, "UInt")
	CRC := SubStr(CRC32 | 0x1000000000, -7)
	DllCall("User32.dll\CharLower", "Str", CRC)
	SetFormat, Integer, %A_FI%
	return CRC, DllCall("Kernel32.dll\FreeLibrary", "Ptr", hMod)
}
LC_FileCRC32(sFile := "", cSz := 4) {
	Bytes := ""
	cSz := (cSz < 0 || cSz > 8) ? 2**22 : 2**(18 + cSz)
	VarSetCapacity(Buffer, cSz, 0)
	hFil := DllCall("Kernel32.dll\CreateFile", "Str", sFile, "UInt", 0x80000000, "UInt", 3, "Int", 0, "UInt", 3, "UInt", 0, "Int", 0, "UInt")
	if (hFil < 1)
	{
		return hFil
	}
	hMod := DllCall("Kernel32.dll\LoadLibrary", "Str", "Ntdll.dll")
	CRC32 := 0
	DllCall("Kernel32.dll\GetFileSizeEx", "UInt", hFil, "Int64", &Buffer), fSz := NumGet(Buffer, 0, "Int64")
	loop % (fSz // cSz + !!Mod(fSz, cSz))
	{
		DllCall("Kernel32.dll\ReadFile", "UInt", hFil, "Ptr", &Buffer, "UInt", cSz, "UInt*", Bytes, "UInt", 0)
		CRC32 := DllCall("Ntdll.dll\RtlComputeCrc32", "UInt", CRC32, "UInt", &Buffer, "UInt", Bytes, "UInt")
	}
	DllCall("Kernel32.dll\CloseHandle", "Ptr", hFil)
	SetFormat, Integer, % SubStr((A_FI := A_FormatInteger) "H", 0)
	CRC32 := SubStr(CRC32 + 0x1000000000, -7)
	DllCall("User32.dll\CharLower", "Str", CRC32)
	SetFormat, Integer, %A_FI%
	return CRC32, DllCall("Kernel32.dll\FreeLibrary", "Ptr", hMod)
}