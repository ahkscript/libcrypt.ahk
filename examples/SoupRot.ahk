#include ..\build\libcrypt.ahk

iterationCnt:=a_tickCount
junk:=0
str:="Hello° µWorld"

encStr:=soupRot.enc(str,iterationCnt,junk)
decStr:=soupRot.dec(encStr,iterationCnt,junk)

msgbox,,SoupRot,% "Original String: " str "`n`nEncrypted String: " encStr "`n`nDecrypted String: " decStr
exitApp
