LC_Bin2Hex(ByRef Out, ByRef In, InLen, Pretty=False)
{
	return LC_Bin2Str(Out, In, InLen, Pretty ? 0xb : 0x4000000c)
}

LC_Hex2Bin(ByRef Out, ByRef In)
{
	return LC_Str2Bin(Out, In, 0x8)
}