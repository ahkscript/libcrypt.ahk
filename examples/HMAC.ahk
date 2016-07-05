#Include ..\build\libcrypt.ahk

#NoEnv
#SingleInstance Force
SetBatchLines, -1

message	:= "The quick brown fox jumps over the lazy dog"
key		:= "key"

MsgBox, % "Message:`t`t"         (message) "`nKey:`t`t"                   (key)                    "`n`n"
		. "MD2:`t`t"       LC_MD2(message) "`nMD2 + LC_HMAC:`t"    LC_HMAC(key, message, "md2")    "`n`n"
		. "MD4:`t`t"       LC_MD4(message) "`nMD4 + LC_HMAC:`t"    LC_HMAC(key, message, "md4")    "`n`n"
		. "MD5:`t`t"       LC_MD5(message) "`nMD5 + LC_HMAC:`t"    LC_HMAC(key, message, "md5")    "`n`n"
		. "SHA:`t`t"       LC_SHA(message) "`nSHA + LC_HMAC:`t"    LC_HMAC(key, message, "sha")    "`n`n"
		. "SHA256:`t`t" LC_SHA256(message) "`nSHA256 + LC_HMAC:`t" LC_HMAC(key, message, "sha256") "`n`n"
		. "SHA384:`t`t" LC_SHA384(message) "`nSHA384 + LC_HMAC:`t" LC_HMAC(key, message, "sha384") "`n`n"
		. "SHA512:`t`t" LC_SHA512(message) "`nSHA512 + LC_HMAC:`t" LC_HMAC(key, message, "sha512")

ExitApp