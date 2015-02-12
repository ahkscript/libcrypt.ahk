LC_XOR_Encrypt(str,key) {
	EncLen:=StrPut(Str,"UTF-16")*2
	VarSetCapacity(EncData,EncLen)
	StrPut(Str,&EncData,"UTF-16")

	PassLen:=StrPut(key,"UTF-8")
	VarSetCapacity(PassData,PassLen)
	StrPut(key,&PassData,"UTF-8")

	LC_XOR(OutData,EncData,EncLen,PassData,PassLen)
	LC_Base64_Encode(OutBase64, OutData, EncLen)
	return OutBase64
}

LC_XOR_Decrypt(OutBase64,key) {
	EncLen:=LC_Base64_Decode(OutData, OutBase64)

	PassLen:=StrPut(key,"UTF-8")
	VarSetCapacity(PassData,PassLen)
	StrPut(key,&PassData,"UTF-8")

	LC_XOR(EncData,OutData,EncLen,PassData,PassLen)
	return StrGet(&EncData,"UTF-16")
}

LC_XOR(byref OutData,byref EncData,EncLen,byref PassData,PassLen)
{
	VarSetCapacity(OutData,EncLen)
	Loop % EncLen
		NumPut(NumGet(EncData,A_Index-1,"UChar")^NumGet(PassData,Mod(A_Index-1,PassLen),"UChar"),OutData,A_Index-1,"UChar")
}