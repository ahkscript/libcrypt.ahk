LC_RC4_Encrypt(Data,Pass) {
	Format:=A_FormatInteger,b:=0,j:=0,Key:=Object(),sBox:=Object()
	SetFormat,Integer,Hex
	VarSetCapacity(Result,StrLen(Data)*2)
	Loop 256
		a:=(A_Index-1),Key[a]:=Asc(SubStr(Pass,Mod(a,StrLen(Pass))+1,1)),sBox[a]:=a
	Loop 256
		a:=(A_Index-1),b:=(b+sBox[a]+Key[a])&255,sBox[a]:=(sBox[b]+0,sBox[b]:=sBox[a]) ; SWAP(a,b)
	Loop Parse, Data
		i:=(A_Index&255),j:=(sBox[i]+j)&255,k:=(sBox[i]+sBox[j])&255,sBox[i]:=(sBox[j]+0,sBox[j]:=sBox[i]) ; SWAP(i,j)
		,Result.=SubStr(Asc(A_LoopField)^sBox[k],-1,2)
	StringReplace,Result,Result,x,0,All
	SetFormat,Integer,%Format%
	Return Result
}

LC_RC4_Decrypt(Data,Pass) {
	b:=0,j:=0,x:="0x",Key:=Object(),sBox:=Object()
	VarSetCapacity(Result,StrLen(Data)//2)
	Loop 256
		a:=(A_Index-1),Key[a]:=Asc(SubStr(Pass,Mod(a,StrLen(Pass))+1,1)),sBox[a]:=a
	Loop 256
		a:=(A_Index-1),b:=(b+sBox[a]+Key[a])&255,sBox[a]:=(sBox[b]+0,sBox[b]:=sBox[a]) ; SWAP(a,b)
	Loop % StrLen(Data)//2
		i:=(A_Index&255),j:=(sBox[i]+j)&255,k:=(sBox[i]+sBox[j])&255,sBox[i]:=(sBox[j]+0,sBox[j]:=sBox[i]) ; SWAP(i,j)
		,Result.=Chr((x . SubStr(Data,(2*A_Index)-1,2))^sBox[k])
	Return Result
}

LC_RC4(RC4Data,RC4Pass) { ; Thanks Rajat for original, Updated Libcrypt version
	; http://www.autohotkey.com/board/topic/570-rc4-encryption/page-2#entry25712
	ATrim:=A_AutoTrim,BLines:=A_BatchLines,RC4PassLen:=StrLen(RC4Pass),Key:=Object(),sBox:=Object(),b:=0,RC4Result:="",i:=0,j:=0
	AutoTrim,Off
	SetBatchlines,-1
	Loop, 256
		a:=(A_Index-1),ModVal:=Mod(a,RC4PassLen),c:=SubStr(RC4Pass,ModVal+=1,1),Key[a]:=Asc(c),sBox[a]:=a
	Loop, 256
		a:=(A_Index-1),b:=Mod(b+sBox[a]+Key[a],256),T:=sBox[a],sBox[a]:=sBox[b],sBox[b]:=T
	Loop, Parse, RC4Data
		i:=Mod(i+1,256),j:=Mod(sBox[i]+j,256),k:=sBox[Mod(sBox[i]+sBox[j],256)],c:=Asc(A_LoopField)^k,c:=((c==0)?k:c),RC4Result.=Chr(c)
	AutoTrim, %ATrim%
	SetBatchlines, %BLines%
	Return RC4Result
}