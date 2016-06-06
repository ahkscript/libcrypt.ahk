; RSHash (Robert Sedgewick's string hashing algorithm)
; from jNizM
; https://autohotkey.com/boards/viewtopic.php?p=87929#p87929

LC_RSHash(str) {
	a := 0xF8C9, b := 0x5C6B7, h := 0
	loop, parse, str
		h := h * a + Asc(A_LoopField), a *= b
	return (h & 0x7FFFFFFF)
}