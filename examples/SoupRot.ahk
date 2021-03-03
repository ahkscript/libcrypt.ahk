#include ..\build\libcrypt.ahk

iterationCnt:=a_tickCount
junk:=0
str:="Hello° µWorld"

encStr:=LC_soupRot.enc(str,iterationCnt,junk)
decStr:=LC_soupRot.dec(encStr,iterationCnt,junk)

msgbox,,LC_soupRot,% "Original String: " str "`n`nEncrypted String: " encStr "`n`nDecrypted String: " decStr
exitApp
