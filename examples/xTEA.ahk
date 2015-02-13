#Include ..\build\libcrypt.ahk

Message 	:= "Secret Message!"
Keys		:= [0x13844741,0x18923748,0x83248432,0x54323454]
Encrypted 	:= LC_TEA_Encrypt(Message,Keys)
Decrypted 	:= LC_TEA_Decrypt(Encrypted,Keys)

MsgBox,
(
Message	: `t%Message%
Keys	: `t[0x13844741,0x18923748,0x83248432,0x54323454]
Encrypted	: `t%Encrypted%
Decrypted	: `t%Decrypted%
)