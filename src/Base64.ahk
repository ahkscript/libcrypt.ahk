LC_Base64_EncodeText(Text)
{
	VarSetCapacity(Bin, StrPut(Text, "UTF-8"))
	Base64_Encode(Base64, Bin, StrPut(Text, &Bin, "UTF-8")-1)
	return Base64
}

LC_Base64_DecodeText(Text)
{
	Len := Base64_Decode(Bin, Text)
	return StrGet(&Bin, "UTF-8")
}

LC_Base64_Encode(ByRef Out, ByRef In, InLen)
{
	return LC_Bin2Str(Out, In, InLen, 0x40000001)
}

LC_Base64_Decode(ByRef Out, ByRef In)
{
	return LC_Str2Bin(Out, In, 0x1)
}