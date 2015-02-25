#Include ..\build\libcrypt.ahk
SetBatchLines,-1
#NoEnv

m := "[VxE]-89 is a text-friendly encryption method."
l := StrLen(m)

Encrypted89 := LC_VxE_Encrypt89( "Password0001", m1:=m  )
Decrypted89 := LC_VxE_Decrypt89( "Password0001", m2:=m1 )

Encrypted251 := LC_VxE_Encrypt251( "Password0002", m3:=m , l )
Decrypted251 := LC_VxE_Decrypt251( "Password0002", m4:=m3, l )

MsgBox, 
(
Original:
----------------------------
%m%

VxE89:
----------------------------
Encrypted89 = %m1%
Decrypted89 = %m2%

VxE251:
----------------------------
Encrypted251 = %m3%
Decrypted251 = %m4%
)