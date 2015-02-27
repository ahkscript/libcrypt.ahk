#Include ..\build\libcrypt.ahk

#NoEnv
#SingleInstance Force
SetBatchLines, -1

Key  := "VIGENERECIPHER"
Text := "The quick brown fox jumps over the lazy dog"

MsgBox, % "Key:`t`t" Key "`n"
        . "Plaintext:`t`t" Text "`n`n"
        . "Ciphertext:`t" (c := LC_VigenereCipher(Text, Key)) "`n"
        . "Decrypted:`t" LC_VigenereDecipher(c, key)

exitapp
