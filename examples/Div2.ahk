#Include ..\build\libcrypt.ahk

Original 	:= "Jack was here"
Encoded 	:= LC_Div2_encode(Original)
Decoded 	:= LC_Div2_decode(Encoded)

MsgBox,
(
Original :`t%Original%
Encoded :`t%Encoded%
Decoded :`t%Decoded%
)