#Include ..\build\libcrypt.ahk

Message 	:= "Secret Message!"
Password 	:= "Password"
Encoded 	:= LC_XOR_Encrypt(Message,Password)
Decoded 	:= LC_XOR_Decrypt(Encoded,Password)

MsgBox,
(
Message  : `t%Message%
Password : `t%Password%
Encoded  : `t%Encoded%
Decoded  : `t%Decoded%
)