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

/*
Should print out the following:
-----------------------------------------------------------------------

Message:		The quick brown fox jumps over the lazy dog
Salt:			key

MD2:			03d85a0d629d2c442e987525319fc471
MD2 + Salt:		06ea7bab6cedc90bc56d78b62cff30c3

MD4:			1bee69a46ba811185c194762abaeae90
MD4 + Salt:		d4d8a4d3f4d49227186bbf9ba351217e

MD5:			9e107d9d372bb6826bd81d3542a419d6
MD5 + Salt:		d42cfa517bcc98b425a106c820e3cc50

SHA:			2fd4e1c67a2d28fced849ee1bb76e7391b93eb12
SHA + Salt:		450b4e52be29a1950581722a81e48086ac737dc3

SHA256:			d7a8fbb307d7809469ca9abcb0082e4f8d5651e46d3cdb762d02d0bf37c9e592
SHA256 + Salt:	1d4b38cffa5905ea2d7d2b952bc4bd7496789c06b5d457e74d270391b3a350de

SHA384:			ca737f1014a48f4c0b6dd43cb177b0afd9e5169367544c494011e3317dbf9a509cb1e5dc1e85a941bbee3d7f2afbc9b1
SHA384 + Salt:	4962e37ba4c5c320936540c370f1955ce1fd3ca424aef195fe02f1983dfc1d09940a1dd7d50857f60a9b35a89bd2b178

SHA512:			07e547d9586f6a73f73fbac0435ed76951218fb7d0c8d788a309d785436bbb642e93a252a954f23912547d1e8a3b5ed6e1bfd7097821233fa0538f3db854fee6
SHA512 + Salt:	a657b03c973fc43d5d385125430cb5ce04842c1b2986df233a615b5f33b0fa4852b243889ce774f7947ff0bc550aaf24d03dda5159baada07c40c27fa4dbfb44

*/