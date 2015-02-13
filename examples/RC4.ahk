#Include ..\build\libcrypt.ahk

Message 	:= "Secret Message!"
Password 	:= "Password"
Encrypted 	:= LC_RC4_Encrypt(Message,Password)
Decrypted 	:= LC_RC4_Decrypt(Encrypted,Password)
Test := LC_RC4(LC_RC4(Message,Password),Password)

MsgBox,
(
Message   : `t%Message%
Password  : `t%Password%
Encrypted : `t%Encrypted%
Decrypted : `t%Decrypted%
Test `t: `t%Test%
)