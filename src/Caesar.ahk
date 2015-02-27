; 
; Version: 2014.03.06-1518, jNizM
; see https://en.wikipedia.org/wiki/Caesar_cipher
; ===================================================================================

LC_Caesar(string, num := 2) {
    ret := c := ""
    loop, parse, string
    {
        c := Asc(A_LoopField)
        if (c > 64) && (c < 91)
            ret .= Chr(Mod(c - 65 + num, 26) + 65)
        else if (c > 96) && (c < 123)
            ret .= Chr(Mod(c - 97 + num, 26) + 97)
        else
            ret .= A_LoopField
    }
    return ret
}