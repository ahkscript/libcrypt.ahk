#Include ..\build\libcrypt.ahk

#NoEnv
#SingleInstance Force
SetBatchLines, -1

message	:= "The quick brown fox jumps over the lazy dog"
salt	:= "key"

MsgBox, % "Message:`t`t"         (message) "`nSalt:`t`t"                       (salt)                    "`n`n"
		. "MD2:`t`t"       LC_MD2(message) "`nMD2 + Salt:`t"    LC_SecureSalted(salt, message, "md2")    "`n`n"
		. "MD4:`t`t"       LC_MD4(message) "`nMD4 + Salt:`t"    LC_SecureSalted(salt, message, "md4")    "`n`n"
		. "MD5:`t`t"       LC_MD5(message) "`nMD5 + Salt:`t"    LC_SecureSalted(salt, message, "md5")    "`n`n"
		. "SHA:`t`t"       LC_SHA(message) "`nSHA + Salt:`t"    LC_SecureSalted(salt, message, "sha")    "`n`n"
		. "SHA256:`t`t" LC_SHA256(message) "`nSHA256 + Salt:`t" LC_SecureSalted(salt, message, "sha256") "`n`n"
		. "SHA384:`t`t" LC_SHA384(message) "`nSHA384 + Salt:`t" LC_SecureSalted(salt, message, "sha384") "`n`n"
		. "SHA512:`t`t" LC_SHA512(message) "`nSHA512 + Salt:`t" LC_SecureSalted(salt, message, "sha512")

ExitApp