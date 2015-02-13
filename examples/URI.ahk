#Include ..\build\libcrypt.ahk

URI		:= "some weird URI !@$%^&*().php?somevar=text"
Encoded	:= LC_UriEncode(URI)
Decoded	:= LC_UriDecode(Encoded)

MsgBox,
(
URI : `n%URI%`n
Encoded : `n%Encoded%`n
Decoded : `n%Decoded%
)