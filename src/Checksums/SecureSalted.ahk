; ===================================================================================
; AHK Version ...: AHK_L 1.1.14.03 x64 Unicode
; Win Version ...: Windows 7 Professional x64 SP1
; Description ...: SecureSalted Hash
;                  https://en.wikipedia.org/wiki/Salt_(cryptography)
; Version .......: 2014.04.09-1828
; Author ........: IsNull (SecureSalted)
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
salt    := "key"

MsgBox, % "Message:`t`t"      (message) "`nSalt:`t`t"                    (salt)                    "`n`n"
        . "MD2:`t`t"       MD2(message) "`nMD2 + Salt:`t"    SecureSalted(salt, message, "md2")    "`n`n"
        . "MD4:`t`t"       MD4(message) "`nMD4 + Salt:`t"    SecureSalted(salt, message, "md4")    "`n`n"
        . "MD5:`t`t"       MD5(message) "`nMD5 + Salt:`t"    SecureSalted(salt, message, "md5")    "`n`n"
        . "SHA:`t`t"       SHA(message) "`nSHA + Salt:`t"    SecureSalted(salt, message, "sha")    "`n`n"
        . "SHA256:`t`t" SHA256(message) "`nSHA256 + Salt:`t" SecureSalted(salt, message, "sha256") "`n`n"
        . "SHA384:`t`t" SHA384(message) "`nSHA384 + Salt:`t" SecureSalted(salt, message, "sha384") "`n`n"
        . "SHA512:`t`t" SHA512(message) "`nSHA512 + Salt:`t" SecureSalted(salt, message, "sha512")

ExitApp


; SecureSalted ======================================================================
SecureSalted(salt, message, algo := "md5")
{
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