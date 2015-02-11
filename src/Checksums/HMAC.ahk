; ===================================================================================
; AHK Version ...: AHK_L 1.1.14.03 x64 Unicode
; Win Version ...: Windows 7 Professional x64 SP1
; Description ...: HMAC Hash
;                  https://en.wikipedia.org/wiki/Hash-based_message_authentication_code
; Version .......: 2014.04.09-1828
; Author ........: just me (HMAC)
; Author ........: Bentschi (Hash)
; Modified ......: jNizM
; ===================================================================================

; GLOBAL SETTINGS ===================================================================

#Warn
#NoEnv
#SingleInstance Force
SetBatchLines, -1

; SCRIPT ============================================================================

message := "The quick brown fox jumps over the lazy dog"
key     := "key"

MsgBox, % "Message:`t`t"      (message) "`nKey:`t`t"             (key)                    "`n`n"
        . "MD2:`t`t"       MD2(message) "`nMD2 + HMAC:`t"    HMAC(key, message, "md2")    "`n`n"
        . "MD4:`t`t"       MD4(message) "`nMD4 + HMAC:`t"    HMAC(key, message, "md4")    "`n`n"
        . "MD5:`t`t"       MD5(message) "`nMD5 + HMAC:`t"    HMAC(key, message, "md5")    "`n`n"
        . "SHA:`t`t"       SHA(message) "`nSHA + HMAC:`t"    HMAC(key, message, "sha")    "`n`n"
        . "SHA256:`t`t" SHA256(message) "`nSHA256 + HMAC:`t" HMAC(key, message, "sha256") "`n`n"
        . "SHA384:`t`t" SHA384(message) "`nSHA384 + HMAC:`t" HMAC(key, message, "sha384") "`n`n"
        . "SHA512:`t`t" SHA512(message) "`nSHA512 + HMAC:`t" HMAC(key, message, "sha512")

ExitApp


; HMAC ==============================================================================
HMAC(Key, Message, Algo := "MD5")
{
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
        CalcAddrHash(&K, KeyLen, AlgID, KeyHash, KeyHashLen)
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
    CalcAddrHash(&ipad, BlockSize + MsgLen, AlgID, InnerHash, InnerHashLen)

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
    return CalcAddrHash(&opad, BlockSize + InnerHashLen, AlgID)
}


; MD2 ===============================================================================
MD2(string, encoding = "UTF-8")
{
    return CalcStringHash(string, 0x8001, encoding)
}
; MD4 ===============================================================================
MD4(string, encoding = "UTF-8")
{
    return CalcStringHash(string, 0x8002, encoding)
}
; MD5 ===============================================================================
MD5(string, encoding = "UTF-8")
{
    return CalcStringHash(string, 0x8003, encoding)
}
; SHA ===============================================================================
SHA(string, encoding = "UTF-8")
{
    return CalcStringHash(string, 0x8004, encoding)
}
; SHA256 ============================================================================
SHA256(string, encoding = "UTF-8")
{
    return CalcStringHash(string, 0x800c, encoding)
}
; SHA384 ============================================================================
SHA384(string, encoding = "UTF-8")
{
    return CalcStringHash(string, 0x800d, encoding)
}
; SHA512 ============================================================================
SHA512(string, encoding = "UTF-8")
{
    return CalcStringHash(string, 0x800e, encoding)
}

; CalcAddrHash ======================================================================
CalcAddrHash(addr, length, algid, byref hash = 0, byref hashlength = 0)
{
    static h := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, "a", "b", "c", "d", "e", "f"]
    static b := h.minIndex()
    hProv := hHash := o := ""
    if (DllCall("advapi32\CryptAcquireContext", "Ptr*", hProv, "Ptr", 0, "Ptr", 0, "UInt", 24, "UInt", 0xf0000000))
    {
        if (DllCall("advapi32\CryptCreateHash", "Ptr", hProv, "UInt", algid, "UInt", 0, "UInt", 0, "Ptr*", hHash))
        {
            if (DllCall("advapi32\CryptHashData", "Ptr", hHash, "Ptr", addr, "UInt", length, "UInt", 0))
            {
                if (DllCall("advapi32\CryptGetHashParam", "Ptr", hHash, "UInt", 2, "Ptr", 0, "UInt*", hashlength, "UInt", 0))
                {
                    VarSetCapacity(hash, hashlength, 0)
                    if (DllCall("advapi32\CryptGetHashParam", "Ptr", hHash, "UInt", 2, "Ptr", &hash, "UInt*", hashlength, "UInt", 0))
                    {
                        loop % hashlength
                        {
                            v := NumGet(hash, A_Index - 1, "UChar")
                            o .= h[(v >> 4) + b] h[(v & 0xf) + b]
                        }
                    }
                }
            }
            DllCall("advapi32\CryptDestroyHash", "Ptr", hHash)
        }
        DllCall("advapi32\CryptReleaseContext", "Ptr", hProv, "UInt", 0)
    }
    return o
}

; CalcStringHash ====================================================================
CalcStringHash(string, algid, encoding = "UTF-8", byref hash = 0, byref hashlength = 0)
{
    chrlength := (encoding = "CP1200" || encoding = "UTF-16") ? 2 : 1
    length := (StrPut(string, encoding) - 1) * chrlength
    VarSetCapacity(data, length, 0)
    StrPut(string, &data, floor(length / chrlength), encoding)
    return CalcAddrHash(&data, length, algid, hash, hashlength)
}