#Include ..\build\libcrypt.ahk

n:="`n"
MsgBox % LC_Rot5("abcdef1234567890") n "abcdef6789012345" n n
. LC_Rot13("Secret Message!") n "Frperg Zrffntr!" n n
. LC_Rot18("H3ll0 w0rld!") n "U8yy5 j5eyq!" n n
. LC_Rot47("The Quick Brown Fox Jumps Over The Lazy Dog.") n "`%96 ""F:4< qC@H? u@I yF>AD ~G6C `%96 {2KJ s@8]"