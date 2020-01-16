#Include ..\build\libcrypt.ahk

Lorem = 
( Join
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempo
r incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis n
ostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. D
uis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore e
u fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sun
t in culpa qui officia deserunt mollit anim id est laborum.
)

test("LC_L64Hash", 12345678, "237A41FA8A9E9389")
test("LC_L128Hash", 12345678, "34BB8666266A954A96E5845401C8C06E")
test("LC_L64Hash", Lorem, "F59E44A48ACC191C")
test("LC_L128Hash", Lorem, "F24351FFE2C1174E447E602ED48A010A")

results := test()
MsgBox % results[1] "`n" results[2] "/" results[3] " tests passed."

ExitApp

test(funcname="", inval="", answer="") {
	static tests
	static total
	static pass
	if (StrLen(funcname)) {
		test := %funcname%(inval)
		stat := ?"Pass":"Fail"
		inval := (StrLen(inval)>10) ? SubStr(inval,1,7) "..." : inval ; shorted text if needed
		tests .= "[" stat "] " funcname "(" """" inval """" ") = " test "`n"
		total++
		pass += !!(test==answer)
	}
	Return [tests, pass, total]
}