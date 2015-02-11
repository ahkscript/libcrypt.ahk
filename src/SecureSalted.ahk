LC_SecureSalted(salt, message, algo := "md5") {
	hash := ""
	saltedHash := %algo%(message . salt) 
	saltedHashR := %algo%(salt . message)
	len := StrLen(saltedHash)
	loop % len / 2
	{
		byte1 := "0x" . SubStr(saltedHash, 2 * A_index - 1, 2)
		byte2 := "0x" . SubStr(saltedHashR, 2 * A_index - 1, 2)
		SetFormat, integer, hex
		hash .= StrLen(ns := SubStr(byte1 ^ byte2, 3)) < 2 ? "0" ns : ns
	}
	SetFormat, integer, dez
	return hash
}