#Include ..\build\libcrypt.ahk

URI		:= "some weird URI !@$%^&*().php?somevar=text"
Encoded	:= LC_UriEncode(URI)
Decoded	:= LC_UriDecode(Encoded)

URL			:= "http://example.com/pages/links(stuff)/script(s).php?var=s p a c e s !&var2=3+5#ref"
Encoded2	:= LC_URLEncode(URL)
Decoded2	:= LC_URLDecode(Encoded2)

MsgBox,
(
URI : `n%URI%`n
Encoded : `n%Encoded%`n
Decoded : `n%Decoded%

---------------------------------------

URL : `n%URL%`n
Encoded2 : `n%Encoded2%`n
Decoded2 : `n%Decoded2%
)