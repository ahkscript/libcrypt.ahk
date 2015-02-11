LC_HMAC(Key, Message, Algo := "MD5") {
	static Algorithms := {MD2:    {ID: 0x8001, Size:  64}
						, MD4:    {ID: 0x8002, Size:  64}
						, MD5:    {ID: 0x8003, Size:  64}
						, SHA:    {ID: 0x8004, Size:  64}
						, SHA256: {ID: 0x800C, Size:  64}
						, SHA384: {ID: 0x800D, Size: 128}
						, SHA512: {ID: 0x800E, Size: 128}}
	static iconst := 0x36
	static oconst := 0x5C
	if (!(Algorithms.HasKey(Algo)))
	{
		return ""
    }
	Hash := KeyHashLen := InnerHashLen := ""
	HashLen := 0
	AlgID := Algorithms[Algo].ID
	BlockSize := Algorithms[Algo].Size
	MsgLen := StrPut(Message, "UTF-8") - 1
	KeyLen := StrPut(Key, "UTF-8") - 1
	VarSetCapacity(K, KeyLen + 1, 0)
	StrPut(Key, &K, KeyLen, "UTF-8")
	if (KeyLen > BlockSize)
    {
		LC_CalcAddrHash(&K, KeyLen, AlgID, KeyHash, KeyHashLen)
	}

	VarSetCapacity(ipad, BlockSize + MsgLen, iconst)
	Addr := KeyLen > BlockSize ? &KeyHash : &K
	Length := KeyLen > BlockSize ? KeyHashLen : KeyLen
	i := 0
	while (i < Length)
	{
		NumPut(NumGet(Addr + 0, i, "UChar") ^ iconst, ipad, i, "UChar")
		i++
	}
	if (MsgLen)
	{
		StrPut(Message, &ipad + BlockSize, MsgLen, "UTF-8")
	}
	LC_CalcAddrHash(&ipad, BlockSize + MsgLen, AlgID, InnerHash, InnerHashLen)

	VarSetCapacity(opad, BlockSize + InnerHashLen, oconst)
	Addr := KeyLen > BlockSize ? &KeyHash : &K
	Length := KeyLen > BlockSize ? KeyHashLen : KeyLen
	i := 0
	while (i < Length)
	{
		NumPut(NumGet(Addr + 0, i, "UChar") ^ oconst, opad, i, "UChar")
		i++
	}
	Addr := &opad + BlockSize
	i := 0
	while (i < InnerHashLen)
	{
		NumPut(NumGet(InnerHash, i, "UChar"), Addr + i, 0, "UChar")
		i++
	}
	return LC_CalcAddrHash(&opad, BlockSize + InnerHashLen, AlgID)
}