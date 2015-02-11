;nnnik's custom encryption algorithm
;Version 2.1 of the encryption/decryption functions

LC_nnnik21_encryptStr(str="",pass="")
{
	If !(enclen:=(strput(str,"utf-16")*2))
		return "Error: Nothing to Encrypt"
	If !(passlen:=strput(pass,"utf-8")-1)
		return "Error: No Pass"
	enclen:=Mod(enclen,4) ? (enclen) : (enclen-2)
	Varsetcapacity(encbin,enclen,0)
	StrPut(str,&encbin,enclen/2,"utf-16")
	Varsetcapacity(passbin,passlen+=mod((4-mod(passlen,4)),4),0)
	StrPut(pass,&passbin,strlen(pass),"utf-8")
	LC_nnnik21_encryptbin(&encbin,enclen,&passbin,passlen)
	LC_Base64_Encode(Text, encbin, enclen)
	return Text
}

LC_nnnik21_decryptStr(str="",pass="")
{
	If !((strput(str,"utf-16")*2))
		return "Error: Nothing to Decrypt"
	If !((passlen:=strput(pass,"utf-8")-1))
		return "Error: No Pass"
	Varsetcapacity(passbin,passlen+=mod((4-mod(passlen,4)),4),0)
	StrPut(pass,&passbin,strlen(pass),"utf-8")
	enclen:=LC_Base64_Decode(encbin, str)
	LC_nnnik21__decryptbin(&encbin,enclen,&passbin,passlen)
	return StrGet(&encbin,"utf-16")
}


LC_nnnik21_encryptbin(pBin1,sBin1,pBin2,sBin2)
{
	b:=0
	Loop % sBin1/4
	{
		a:=numget(pBin1+0,sBin1-A_Index*4,"uint")
		numput(a+b,pBin1+0,sBin1-A_Index*4,"uint")
		b:=(a+b)*a
	}
	Loop % sBin2/4
	{
		c:=numget(pBin2+0,(A_Index-1)*4,"uint")
		b:=0
		Loop % sBin1/4
		{
			a:=numget(pBin1+0,(A_Index-1)*4,"uint")
			numput((a+b)^c,pBin1+0,(A_Index-1)*4,"uint")
			b:=(a+b)*a
		}
	}
}

LC_nnnik21__decryptbin(pBin1,sBin1,pBin2,sBin2){
	Loop % sBin2/4
	{
		c:=numget(pBin2+0,sBin2-A_Index*4,"uint")
		b:=0
		Loop % sBin1/4
		{
			a:=numget(pBin1+0,(A_Index-1)*4,"uint")
			numput(a:=(a^c)-b,pBin1+0,(A_Index-1)*4,"uint")
			b:=(a+b)*a
		}
	}
	b:=0
	Loop % sBin1/4
	{
		a:=numget(pBin1+0,sBin1-A_Index*4,"uint")
		numput(a:=a-b,pBin1+0,sBin1-A_Index*4,"uint")
		b:=(a+b)*a
	}
}
