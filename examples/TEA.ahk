#Include ..\build\libcrypt.ahk

Message 	:= "Secret Message!"
;Keys		:= [0x13844741,0x18923748,0x83248432,0x54323454]
Password	:= "MyPasswordIsCool"
Encrypted 	:= LC_TEA_Encrypt(Message,Password)
Decrypted 	:= LC_TEA_Decrypt(Encrypted,Password)

MsgBox,
(
Message	: `t%Message%
Password	: `t%Password%
Encrypted	: `t%Encrypted%
Decrypted	: `t%Decrypted%
)