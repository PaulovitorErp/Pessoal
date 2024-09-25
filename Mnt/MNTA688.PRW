#INCLUDE "MNTA688.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#include "ap5mail.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA688()
Especificacao de Material Rodante, chamado atraves do
MNTA080 no click da direita do mouse
@author Evaldo Cevinscki Jr.
@since 24/05/2010
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Function MNTA688(cCodBem)

	// Guarda conteudo e declara variaveis padroes
	Local aNGBEGINPRM := NGBEGINPRM()

	Local nAltura   	:= (GetScreenRes()[2]*0.7)
	Local nLargura  	:= (GetScreenRes()[1]/1.5)
	Local oFont14N		:= TFont():New("Arial",,14,,.T.,,,,.F.,.F.)
	Local nOpca			:= 0
	Local lCarregou		:= .f.
	Private oScrollBox
	Private aSize := MsAdvSize(,.f.,430), aObjects := {}

	//-------Tratativas para alteração via compatibilizador de base-------------
	Inclui := If( Type("Inclui") == "L", Inclui, .F. )
	Altera := If( Type("Altera") == "L", Altera, IsInCallStack("MRMFIM") )
	//--------------------------------------------------------------------------

	If Inclui
		MsgStop(STR0001,STR0002) //"Opção indisponível para inclusão!"###"ATENÇÃO"
		Return
	Endif

	dbSelectArea("STZ")
	dbSetorder(3)
	If !dbSeek(xFilial("STZ")+cCodBem)
		MsgStop("Opção indisponível para bens que não possuem estrutura.",STR0002)
		Return
	EndIf

	//se for alterar o campo padrao para 's' pega dados do Material Rodante da familia padrao
	If Altera .AND. M->T9_PADRAO == 'S' .AND. ST9->T9_PADRAO == 'N'
		dbSelectArea("TV5")
		dbSetOrder(01)
		If !DbSeek(xFilial("TV5")+M->T9_CODBEM)
			DbSelectArea("TVH")
			DbSetOrder(1)
			If DbSeek(xFilial("TVH")+M->T9_CODFAMI+M->T9_TIPMOD)
				M->TV5_LARSAP	:= IIF(TVH->TVH_LARSAP <> 0,TVH->TVH_LARSAP,0)
				M->TV5_NUMSEC	:= IIF(TVH->TVH_NUMSEC <> 0,TVH->TVH_NUMSEC,0)
				M->TV5_ELOESQ	:= IIF(TVH->TVH_ELOESQ <> 0,TVH->TVH_ELOESQ,0)
				M->TV5_BUCESQ	:= IIF(TVH->TVH_BUCESQ <> 0,TVH->TVH_BUCESQ,0)
				M->TV5_SAPESQ	:= IIF(TVH->TVH_SAPESQ <> 0,TVH->TVH_SAPESQ,0)
				M->TV5_RDDESQ	:= IIF(TVH->TVH_RDDESQ <> 0,TVH->TVH_RDDESQ,0)
				M->TV5_RDTESQ	:= IIF(TVH->TVH_RDTESQ <> 0,TVH->TVH_RDTESQ,0)
				M->TV5_ELODIR	:= IIF(TVH->TVH_ELODIR <> 0,TVH->TVH_ELODIR,0)
				M->TV5_BUCDIR	:= IIF(TVH->TVH_BUCDIR <> 0,TVH->TVH_BUCDIR,0)
				M->TV5_SAPDIR	:= IIF(TVH->TVH_SAPDIR <> 0,TVH->TVH_SAPDIR,0)
				M->TV5_RDDDIR	:= IIF(TVH->TVH_RDDDIR <> 0,TVH->TVH_RDDDIR,0)
				M->TV5_RDTDIR	:= IIF(TVH->TVH_RDTDIR <> 0,TVH->TVH_RDTDIR,0)
				M->TV5_RE1ESQ	:= IIF(TVH->TVH_RE1ESQ <> 0,TVH->TVH_RE1ESQ,0)
				M->TV5_RE2ESQ	:= IIF(TVH->TVH_RE2ESQ <> 0,TVH->TVH_RE2ESQ,0)
				M->TV5_RE3ESQ	:= IIF(TVH->TVH_RE3ESQ <> 0,TVH->TVH_RE3ESQ,0)
				M->TV5_RE4ESQ	:= IIF(TVH->TVH_RE4ESQ <> 0,TVH->TVH_RE4ESQ,0)
				M->TV5_RE5ESQ	:= IIF(TVH->TVH_RE5ESQ <> 0,TVH->TVH_RE5ESQ,0)
				M->TV5_RE6ESQ	:= IIF(TVH->TVH_RE6ESQ <> 0,TVH->TVH_RE6ESQ,0)
				M->TV5_RE7ESQ	:= IIF(TVH->TVH_RE7ESQ <> 0,TVH->TVH_RE7ESQ,0)
				M->TV5_RE8ESQ	:= IIF(TVH->TVH_RE8ESQ <> 0,TVH->TVH_RE8ESQ,0)
				M->TV5_RDMESQ	:= IIF(TVH->TVH_RDMESQ <> 0,TVH->TVH_RDMESQ,0)
				M->TV5_RS1ESQ	:= IIF(TVH->TVH_RS1ESQ <> 0,TVH->TVH_RS1ESQ,0)
				M->TV5_RS2ESQ	:= IIF(TVH->TVH_RS2ESQ <> 0,TVH->TVH_RS2ESQ,0)
				M->TV5_RE1DIR	:= IIF(TVH->TVH_RE1DIR <> 0,TVH->TVH_RE1DIR,0)
				M->TV5_RE2DIR	:= IIF(TVH->TVH_RE2DIR <> 0,TVH->TVH_RE2DIR,0)
				M->TV5_RE3DIR	:= IIF(TVH->TVH_RE3DIR <> 0,TVH->TVH_RE3DIR,0)
				M->TV5_RE4DIR	:= IIF(TVH->TVH_RE4DIR <> 0,TVH->TVH_RE4DIR,0)
				M->TV5_RE5DIR	:= IIF(TVH->TVH_RE5DIR <> 0,TVH->TVH_RE5DIR,0)
				M->TV5_RE6DIR	:= IIF(TVH->TVH_RE6DIR <> 0,TVH->TVH_RE6DIR,0)
				M->TV5_RE7DIR	:= IIF(TVH->TVH_RE7DIR <> 0,TVH->TVH_RE7DIR,0)
				M->TV5_RE8DIR	:= IIF(TVH->TVH_RE8DIR <> 0,TVH->TVH_RE8DIR,0)
				M->TV5_RDMDIR	:= IIF(TVH->TVH_RDMDIR <> 0,TVH->TVH_RDMDIR,0)
				M->TV5_RS1DIR	:= IIF(TVH->TVH_RS1DIR <> 0,TVH->TVH_RS1DIR,0)
				M->TV5_RS2DIR	:= IIF(TVH->TVH_RS2DIR <> 0,TVH->TVH_RS2DIR,0)
				M->TV5_NUMPEC	:= IIF(TVH->TVH_NUMPEC <> 0,TVH->TVH_NUMPEC,0)
				M->TV5_UMELO	:= IIF(Empty(TVH->TVH_UMELO),Space(Len(TVH->TVH_UMELO)),TVH->TVH_UMELO)
				M->TV5_UMBUC	:= IIF(Empty(TVH->TVH_UMBUC),Space(Len(TVH->TVH_UMBUC)),TVH->TVH_UMBUC)
				M->TV5_UMSAP	:= IIF(Empty(TVH->TVH_UMSAP),Space(Len(TVH->TVH_UMSAP)),TVH->TVH_UMSAP)
				M->TV5_UMRDD	:= IIF(Empty(TVH->TVH_UMRDD),Space(Len(TVH->TVH_UMRDD)),TVH->TVH_UMRDD)
				M->TV5_UMRDT	:= IIF(Empty(TVH->TVH_UMRDT),Space(Len(TVH->TVH_UMRDT)),TVH->TVH_UMRDT)
				M->TV5_UMRS1	:= IIF(Empty(TVH->TVH_UMRS1),Space(Len(TVH->TVH_UMRS1)),TVH->TVH_UMRS1)
				M->TV5_UMRS2	:= IIF(Empty(TVH->TVH_UMRS2),Space(Len(TVH->TVH_UMRS2)),TVH->TVH_UMRS2)
				M->TV5_UMRE1	:= IIF(Empty(TVH->TVH_UMRE1),Space(Len(TVH->TVH_UMRE1)),TVH->TVH_UMRE1)
				M->TV5_UMRE2	:= IIF(Empty(TVH->TVH_UMRE2),Space(Len(TVH->TVH_UMRE2)),TVH->TVH_UMRE2)
				M->TV5_UMRE3	:= IIF(Empty(TVH->TVH_UMRE3),Space(Len(TVH->TVH_UMRE3)),TVH->TVH_UMRE3)
				M->TV5_UMRE4	:= IIF(Empty(TVH->TVH_UMRE4),Space(Len(TVH->TVH_UMRE4)),TVH->TVH_UMRE4)
				M->TV5_UMRE5	:= IIF(Empty(TVH->TVH_UMRE5),Space(Len(TVH->TVH_UMRE5)),TVH->TVH_UMRE5)
				M->TV5_UMRE6	:= IIF(Empty(TVH->TVH_UMRE6),Space(Len(TVH->TVH_UMRE6)),TVH->TVH_UMRE6)
				M->TV5_UMRE7	:= IIF(Empty(TVH->TVH_UMRE7),Space(Len(TVH->TVH_UMRE7)),TVH->TVH_UMRE7)
				M->TV5_UMRE8	:= IIF(Empty(TVH->TVH_UMRE8),Space(Len(TVH->TVH_UMRE8)),TVH->TVH_UMRE8)
				M->TV5_UMRDM	:= IIF(Empty(TVH->TVH_UMRDM),Space(Len(TVH->TVH_UMRDM)),TVH->TVH_UMRDM)
				M->TV5_TIPEST	:= IIF(Empty(TVH->TVH_TIPEST),STR0003,If(TVH->TVH_TIPEST == "1",STR0003,STR0004))   //"Selada"###"Selada"###"Selada e Lubrificada"
				M->TV5_GIRADA	:= IIF(Empty(TVH->TVH_GIRADA),STR0005,If(TVH->TVH_GIRADA == "1",STR0005,STR0006))   //"Sim"###"Sim"###"Não"
				M->TV5_GARSIM	:= IIF(Empty(TVH->TVH_GARSIM),STR0005,If(TVH->TVH_GARSIM == "1",STR0005,STR0006))   //"Sim"###"Sim"###"Não"
				M->TV5_FLARE1	:= IIF(Empty(TVH->TVH_FLARE1),STR0007,If(TVH->TVH_FLARE1 == "1",STR0007,STR0008))   //"Simples"###"Simples"###"Dupla"
				M->TV5_FLARE2	:= IIF(Empty(TVH->TVH_FLARE2),STR0007,If(TVH->TVH_FLARE2 == "1",STR0007,STR0008))   //"Simples"###"Simples"###"Dupla"
				M->TV5_FLARE3	:= IIF(Empty(TVH->TVH_FLARE3),STR0007,If(TVH->TVH_FLARE3 == "1",STR0007,STR0008))   //"Simples"###"Simples"###"Dupla"
				M->TV5_FLARE4	:= IIF(Empty(TVH->TVH_FLARE4),STR0007,If(TVH->TVH_FLARE4 == "1",STR0007,STR0008))   //"Simples"###"Simples"###"Dupla"
				M->TV5_FLARE5	:= IIF(Empty(TVH->TVH_FLARE5),STR0007,If(TVH->TVH_FLARE5 == "1",STR0007,STR0008))   //"Simples"###"Simples"###"Dupla"
				M->TV5_FLARE6	:= IIF(Empty(TVH->TVH_FLARE6),STR0007,If(TVH->TVH_FLARE6 == "1",STR0007,STR0008))   //"Simples"###"Simples"###"Dupla"
				M->TV5_FLARE7	:= IIF(Empty(TVH->TVH_FLARE7),STR0007,If(TVH->TVH_FLARE7 == "1",STR0007,STR0008))   //"Simples"###"Simples"###"Dupla"
				M->TV5_FLARE8	:= IIF(Empty(TVH->TVH_FLARE8),STR0007,If(TVH->TVH_FLARE8 == "1",STR0007,STR0008))  //"Simples"###"Simples"###"Dupla"
				lCarregou := .t.
			Endif
		Endif
	Endif

	If !lCarregou
		DbSelectArea("TV5")
		DbSetOrder(1)
		DbSeek(xFilial("TV5")+cCodBem)

		M->TV5_LARSAP := IIF(TV5->TV5_LARSAP <> 0,TV5->TV5_LARSAP,0)
		M->TV5_NUMSEC	:= IIF(TV5->TV5_NUMSEC <> 0,TV5->TV5_NUMSEC,0)
		M->TV5_ELOESQ := IIF(TV5->TV5_ELOESQ <> 0,TV5->TV5_ELOESQ,0)
		M->TV5_BUCESQ	:= IIF(TV5->TV5_BUCESQ <> 0,TV5->TV5_BUCESQ,0)
		M->TV5_SAPESQ := IIF(TV5->TV5_SAPESQ <> 0,TV5->TV5_SAPESQ,0)
		M->TV5_RDDESQ	:= IIF(TV5->TV5_RDDESQ <> 0,TV5->TV5_RDDESQ,0)
		M->TV5_RDTESQ := IIF(TV5->TV5_RDTESQ <> 0,TV5->TV5_RDTESQ,0)
		M->TV5_ELODIR	:= IIF(TV5->TV5_ELODIR <> 0,TV5->TV5_ELODIR,0)
		M->TV5_BUCDIR	:= IIF(TV5->TV5_BUCDIR <> 0,TV5->TV5_BUCDIR,0)
		M->TV5_SAPDIR	:= IIF(TV5->TV5_SAPDIR <> 0,TV5->TV5_SAPDIR,0)
		M->TV5_RDDDIR	:= IIF(TV5->TV5_RDDDIR <> 0,TV5->TV5_RDDDIR,0)
		M->TV5_RDTDIR	:= IIF(TV5->TV5_RDTDIR <> 0,TV5->TV5_RDTDIR,0)
		M->TV5_RE1ESQ	:= IIF(TV5->TV5_RE1ESQ <> 0,TV5->TV5_RE1ESQ,0)
		M->TV5_RE2ESQ	:= IIF(TV5->TV5_RE2ESQ <> 0,TV5->TV5_RE2ESQ,0)
		M->TV5_RE3ESQ	:= IIF(TV5->TV5_RE3ESQ <> 0,TV5->TV5_RE3ESQ,0)
		M->TV5_RE4ESQ	:= IIF(TV5->TV5_RE4ESQ <> 0,TV5->TV5_RE4ESQ,0)
		M->TV5_RE5ESQ	:= IIF(TV5->TV5_RE5ESQ <> 0,TV5->TV5_RE5ESQ,0)
		M->TV5_RE6ESQ	:= IIF(TV5->TV5_RE6ESQ <> 0,TV5->TV5_RE6ESQ,0)
		M->TV5_RE7ESQ	:= IIF(TV5->TV5_RE7ESQ <> 0,TV5->TV5_RE7ESQ,0)
		M->TV5_RE8ESQ	:= IIF(TV5->TV5_RE8ESQ <> 0,TV5->TV5_RE8ESQ,0)
		M->TV5_RDMESQ	:= IIF(TV5->TV5_RDMESQ <> 0,TV5->TV5_RDMESQ,0)
		M->TV5_RS1ESQ	:= IIF(TV5->TV5_RS1ESQ <> 0,TV5->TV5_RS1ESQ,0)
		M->TV5_RS2ESQ	:= IIF(TV5->TV5_RS2ESQ <> 0,TV5->TV5_RS2ESQ,0)
		M->TV5_RE1DIR	:= IIF(TV5->TV5_RE1DIR <> 0,TV5->TV5_RE1DIR,0)
		M->TV5_RE2DIR	:= IIF(TV5->TV5_RE2DIR <> 0,TV5->TV5_RE2DIR,0)
		M->TV5_RE3DIR	:= IIF(TV5->TV5_RE3DIR <> 0,TV5->TV5_RE3DIR,0)
		M->TV5_RE4DIR	:= IIF(TV5->TV5_RE4DIR <> 0,TV5->TV5_RE4DIR,0)
		M->TV5_RE5DIR	:= IIF(TV5->TV5_RE5DIR <> 0,TV5->TV5_RE5DIR,0)
		M->TV5_RE6DIR	:= IIF(TV5->TV5_RE6DIR <> 0,TV5->TV5_RE6DIR,0)
		M->TV5_RE7DIR	:= IIF(TV5->TV5_RE7DIR <> 0,TV5->TV5_RE7DIR,0)
		M->TV5_RE8DIR	:= IIF(TV5->TV5_RE8DIR <> 0,TV5->TV5_RE8DIR,0)
		M->TV5_RDMDIR	:= IIF(TV5->TV5_RDMDIR <> 0,TV5->TV5_RDMDIR,0)
		M->TV5_RS1DIR	:= IIF(TV5->TV5_RS1DIR <> 0,TV5->TV5_RS1DIR,0)
		M->TV5_RS2DIR	:= IIF(TV5->TV5_RS2DIR <> 0,TV5->TV5_RS2DIR,0)
		M->TV5_NUMPEC	:= IIF(TV5->TV5_NUMPEC <> 0,TV5->TV5_NUMPEC,0)
		M->TV5_UMELO	:= IIF(Empty(TV5->TV5_UMELO),Space(Len(TV5->TV5_UMELO)),TV5->TV5_UMELO)
		M->TV5_UMBUC	:= IIF(Empty(TV5->TV5_UMBUC),Space(Len(TV5->TV5_UMBUC)),TV5->TV5_UMBUC)
		M->TV5_UMSAP	:= IIF(Empty(TV5->TV5_UMSAP),Space(Len(TV5->TV5_UMSAP)),TV5->TV5_UMSAP)
		M->TV5_UMRDD	:= IIF(Empty(TV5->TV5_UMRDD),Space(Len(TV5->TV5_UMRDD)),TV5->TV5_UMRDD)
		M->TV5_UMRDT	:= IIF(Empty(TV5->TV5_UMRDT),Space(Len(TV5->TV5_UMRDT)),TV5->TV5_UMRDT)
		M->TV5_UMRS1	:= IIF(Empty(TV5->TV5_UMRS1),Space(Len(TV5->TV5_UMRS1)),TV5->TV5_UMRS1)
		M->TV5_UMRS2	:= IIF(Empty(TV5->TV5_UMRS2),Space(Len(TV5->TV5_UMRS2)),TV5->TV5_UMRS2)
		M->TV5_UMRE1	:= IIF(Empty(TV5->TV5_UMRE1),Space(Len(TV5->TV5_UMRE1)),TV5->TV5_UMRE1)
		M->TV5_UMRE2	:= IIF(Empty(TV5->TV5_UMRE2),Space(Len(TV5->TV5_UMRE2)),TV5->TV5_UMRE2)
		M->TV5_UMRE3	:= IIF(Empty(TV5->TV5_UMRE3),Space(Len(TV5->TV5_UMRE3)),TV5->TV5_UMRE3)
		M->TV5_UMRE4	:= IIF(Empty(TV5->TV5_UMRE4),Space(Len(TV5->TV5_UMRE4)),TV5->TV5_UMRE4)
		M->TV5_UMRE5	:= IIF(Empty(TV5->TV5_UMRE5),Space(Len(TV5->TV5_UMRE5)),TV5->TV5_UMRE5)
		M->TV5_UMRE6	:= IIF(Empty(TV5->TV5_UMRE6),Space(Len(TV5->TV5_UMRE6)),TV5->TV5_UMRE6)
		M->TV5_UMRE7	:= IIF(Empty(TV5->TV5_UMRE7),Space(Len(TV5->TV5_UMRE7)),TV5->TV5_UMRE7)
		M->TV5_UMRE8	:= IIF(Empty(TV5->TV5_UMRE8),Space(Len(TV5->TV5_UMRE8)),TV5->TV5_UMRE8)
		M->TV5_UMRDM	:= IIF(Empty(TV5->TV5_UMRDM),Space(Len(TV5->TV5_UMRDM)),TV5->TV5_UMRDM)
		M->TV5_TIPEST	:= IIF(Empty(TV5->TV5_TIPEST),STR0003,If(TV5->TV5_TIPEST == "1",STR0003,STR0004))   //"Selada"###"Selada"###"Selada e Lubrificada"
		M->TV5_GIRADA	:= IIF(Empty(TV5->TV5_GIRADA),STR0005,If(TV5->TV5_GIRADA == "1",STR0005,STR0006))   //"Sim"###"Sim"###"Não"
		M->TV5_GARSIM	:= IIF(Empty(TV5->TV5_GARSIM),STR0005,If(TV5->TV5_GARSIM == "1",STR0005,STR0006))   //"Sim"###"Sim"###"Não"
		M->TV5_FLARE1	:= IIF(Empty(TV5->TV5_FLARE1),STR0007,If(TV5->TV5_FLARE1 == "1",STR0007,STR0008))   //"Simples"###"Simples"###"Dupla"
		M->TV5_FLARE2	:= IIF(Empty(TV5->TV5_FLARE2),STR0007,If(TV5->TV5_FLARE2 == "1",STR0007,STR0008))   //"Simples"###"Simples"###"Dupla"
		M->TV5_FLARE3	:= IIF(Empty(TV5->TV5_FLARE3),STR0007,If(TV5->TV5_FLARE3 == "1",STR0007,STR0008))   //"Simples"###"Simples"###"Dupla"
		M->TV5_FLARE4	:= IIF(Empty(TV5->TV5_FLARE4),STR0007,If(TV5->TV5_FLARE4 == "1",STR0007,STR0008))   //"Simples"###"Simples"###"Dupla"
		M->TV5_FLARE5	:= IIF(Empty(TV5->TV5_FLARE5),STR0007,If(TV5->TV5_FLARE5 == "1",STR0007,STR0008))   //"Simples"###"Simples"###"Dupla"
		M->TV5_FLARE6	:= IIF(Empty(TV5->TV5_FLARE6),STR0007,If(TV5->TV5_FLARE6 == "1",STR0007,STR0008))   //"Simples"###"Simples"###"Dupla"
		M->TV5_FLARE7	:= IIF(Empty(TV5->TV5_FLARE7),STR0007,If(TV5->TV5_FLARE7 == "1",STR0007,STR0008))   //"Simples"###"Simples"###"Dupla"
		M->TV5_FLARE8	:= IIF(Empty(TV5->TV5_FLARE8),STR0007,If(TV5->TV5_FLARE8 == "1",STR0007,STR0008))  //"Simples"###"Simples"###"Dupla"
	Endif

	// Declaração de Variaveis Private dos Objetos
	SetPrvt("oDlg1","oPanel1","oSay1","oSay2","oSay3","oSay4","oSay5","oSay6","oSay7","oSay8","oSay9","oSay10")
	SetPrvt("oSay12","oSay13","oSay14","oSay15","oSay16","oGet1","oGet2","oCBox1","oGet3","oGet4","oGet5")
	SetPrvt("oGet7","oGet8","oGet9","oGet10","oGet11","oGet12","oGet13","oGet14","oGet15","oGet16","oGet17")
	SetPrvt("oGet19","oGet20")

	Define MsDialog oDlg1 Title STR0009 + " - " + cCodBem From 0,0 To nAltura,nLargura Of oMainWnd Pixel COLOR CLR_BLACK,CLR_WHITE  //"Especificação Material Rodante"
	oDlg1:lMaximized := .T.
	Aadd(aObjects,{150,10,.T.,.T.}) // Indica dimensoes x e y e indica que redimensiona x e y
	Aadd(aObjects,{200,30,.T.,.T.}) // Indica dimensoes x e y e indica que redimensiona x e y e assume que retorno sera em linha final coluna final (.F.)

	aSize:=MsAdvSize()
	aInfo:={aSize[1],aSize[2],aSize[3],aSize[4],3,3}
	aPosObj:=MsObjSize(aInfo,aObjects,.T.)

	oPanel1   		:= TScrollBox():new(oDlg1, 003,003, aPosObj[2,3]-aPosObj[2,1] - 20, ((aPosObj[2,4]) / 2) + 10 , .T., .T., .T.)
	oPanel1:Align 	:= CONTROL_ALIGN_ALLCLIENT

	oSay1      := TSay():New( 020,012,{||STR0010},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,044,008) //"Largura Sapatas"
	oSay2      := TSay():New( 020,152,{||STR0011},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,048,008) //"Número de Seções"
	oSay3      := TSay():New( 034,012,{||STR0012},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,040,008) //"Tipo de Esteira"

	oSay4      := TSay():New( 050,012,{||STR0013},oPanel1,,oFont14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,032,008) //"Conjuntos"
	oSay5      := TSay():New( 050,112,{||STR0014},oPanel1,,oFont14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,070,008) //"Dimensões Iniciais"
	oSay6      := TSay():New( 050,250,{||STR0015},oPanel1,,oFont14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,070,008) //"Outras Informações"

	oSay7      := TSay():New( 065,112,{||STR0016},oPanel1,,oFont14N,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,026,008) //"Esquerda"
	oSay8      := TSay():New( 065,156,{||STR0017},oPanel1,,oFont14N,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,024,008) //"Direita"
	oSay9      := TSay():New( 065,198,{||STR0018},oPanel1,,oFont14N,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,024,008) //"Unidade"

	oSay10     := TSay():New( 079,012,{||STR0019},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)           //"Elos"
	oSay26     := TSay():New( 079,250,{||STR0020},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,070,008) //"Número de Peças"

	oSay11     := TSay():New( 092,012,{||STR0021},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008) //"Buchas"
	oSay27     := TSay():New( 092,250,{||STR0022},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008) //"Giradas"

	oSay12     := TSay():New( 105,012,{||STR0023},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008) //"Sapatas"
	oSay28     := TSay():New( 105,250,{||STR0024},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,050,008) //"Garra Simples"

	oSay13     := TSay():New( 118,012,{||STR0025},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,056,008) //"Rodas Guias Dianteira"
	oSay14     := TSay():New( 131,012,{||STR0026},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,052,008) //"Rodas Guias Traseira"
	oSay15     := TSay():New( 144,012,{||STR0027},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,052,008) //"Roletes Superior 1º"
	oSay16     := TSay():New( 157,012,{||STR0028},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,048,008) //"Roletes Superior 2º"
	oSay17     := TSay():New( 170,012,{||STR0029},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008) //"Roletes de Esteira 1º"
	oSay29     := TSay():New( 170,250,{||STR0030},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008) //"Flange"

	oSay18     := TSay():New( 183,012,{||STR0031},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008) //"Roletes de Esteira 2º"
	oSay30     := TSay():New( 183,250,{||STR0030},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008) //"Flange"

	oSay19     := TSay():New( 196,012,{||STR0032},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008) //"Roletes de Esteira 3º"
	oSay31     := TSay():New( 196,250,{||STR0030},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008) //"Flange"

	oSay20     := TSay():New( 209,012,{||STR0033},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008) //"Roletes de Esteira 4º"
	oSay32     := TSay():New( 209,250,{||STR0030},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008) //"Flange"

	oSay21     := TSay():New( 222,012,{||STR0034},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008) //"Roletes de Esteira 5º"
	oSay33     := TSay():New( 222,250,{||STR0030},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008) //"Flange"

	oSay22     := TSay():New( 235,012,{||STR0035},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008) //"Roletes de Esteira 6º"
	oSay34     := TSay():New( 235,250,{||STR0030},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008) //"Flange"

	oSay23     := TSay():New( 248,012,{||STR0036},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008) //"Roletes de Esteira 7º"
	oSay35     := TSay():New( 248,250,{||STR0030},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008) //"Flange"

	oSay24     := TSay():New( 261,012,{||STR0037},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008) //"Roletes de Esteira 8º"
	oSay36     := TSay():New( 261,250,{||STR0030},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008) //"Flange"

	oSay25     := TSay():New( 274,012,{||STR0038},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008) //"Rodas Motrizes"

	oGet1      := TGet():New( 020,056,{|u| If(PCount()>0,M->TV5_LARSAP:=u,M->TV5_LARSAP)},oPanel1,060,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","M->TV5_LARSAP",,,,.t.)
	oGet2      := TGet():New( 020,200,{|u| If(PCount()>0,M->TV5_NUMSEC:=u,M->TV5_NUMSEC)},oPanel1,060,008,'@E 999'   ,{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","M->TV5_NUMSEC",,,,.t.)

	oCBox1     	 := TComboBox():New( 034,056,{|u| If(PCount()>0,M->TV5_TIPEST:=u,M->TV5_TIPEST)},{STR0003,STR0004},068,010,oPanel1,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,,M->TV5_TIPEST ) //"Selada"###"Selada e Lubrificada"
	oCBox1:bHelp := { || ShowHelpCpo( 'TV5_TIPEST',	{ "Indica o tipo da esteira: 1=Selada; 2=Selada e Lubrificada." }, 2,{}, 2 ) } //"Indica o tipo da esteira: 1=Selada; 2=Selada e Lubrificada."

	//Elos
	oGet3      := TGet():New( 077,112,{|u| If(PCount()>0,M->TV5_ELOESQ:=u,M->TV5_ELOESQ)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","M->TV5_ELOESQ",,,,.t.)
	oGet4      := TGet():New( 077,153,{|u| If(PCount()>0,M->TV5_ELODIR:=u,M->TV5_ELODIR)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","M->TV5_ELODIR",,,,.t.)
	oGet5      := TGet():New( 077,195,{|u| If(PCount()>0,M->TV5_UMELO:=u,M->TV5_UMELO)},oPanel1,024,008,'@!',{|| If(!Empty(M->TV5_UMELO),EXISTCPO("SAH",M->TV5_UMELO),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SAH","M->TV5_UMELO",,,,.t.)
	oGet51     := TGet():New( 077,295,{|u| If(PCount()>0,M->TV5_NUMPEC:=u,M->TV5_NUMPEC)},oPanel1,024,008,'@E 9999',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","M->TV5_NUMPEC",,,,.t.)

	//Buchas
	oGet6      := TGet():New( 090,112,{|u| If(PCount()>0,M->TV5_BUCESQ:=u,M->TV5_BUCESQ)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","M->TV5_BUCESQ",,,,.t.)
	oGet7      := TGet():New( 090,153,{|u| If(PCount()>0,M->TV5_BUCDIR:=u,M->TV5_BUCDIR)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","M->TV5_BUCDIR",,,,.t.)
	oGet8      := TGet():New( 090,195,{|u| If(PCount()>0,M->TV5_UMBUC:=u,M->TV5_UMBUC)},oPanel1,024,008,'@!',{|| If(!Empty(M->TV5_UMBUC),EXISTCPO("SAH",M->TV5_UMBUC),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SAH","M->TV5_UMBUC",,,,.t.)
	oCBox2     := TComboBox():New( 090,295,{|u| If(PCount()>0,M->TV5_GIRADA:=u,M->TV5_GIRADA)},{STR0005,STR0006},032,010,oPanel1,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,, ) //"Sim"###"Não"
	oCBox2:bHelp := { || ShowHelpCpo( 'TV5_GIRADA', { "Giradas: 1=Sim; 2=Não." }, 2,{}, 2 ) } //"Giradas: 1=Sim; 2=Não."

	//Sapatas
	oGet9      := TGet():New( 103,112,{|u| If(PCount()>0,M->TV5_SAPESQ:=u,M->TV5_SAPESQ)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","M->TV5_SAPESQ",,,,.t.)
	oGet10     := TGet():New( 103,153,{|u| If(PCount()>0,M->TV5_SAPDIR:=u,M->TV5_SAPDIR)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","M->TV5_SAPDIR",,,,.t.)
	oGet11     := TGet():New( 103,195,{|u| If(PCount()>0,M->TV5_UMSAP:=u,M->TV5_UMSAP)},oPanel1,024,008,'@!',{|| If(!Empty(M->TV5_UMSAP),EXISTCPO("SAH",M->TV5_UMSAP),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SAH","M->TV5_UMSAP",,,,.t.)
	oCBox3     := TComboBox():New( 103,295,{|u| If(PCount()>0,M->TV5_GARSIM:=u,M->TV5_GARSIM)},{STR0005,STR0006},032,010,oPanel1,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,, ) //"Sim"###"Não"
	oCBox3:bHelp := { || ShowHelpCpo( 'TV5_GARSIM',	{ "Garra Simples: 1=Sim; 2=Não." }, 2,{}, 2 ) } //"Garra Simples: 1=Sim; 2=Não."

	//Rodas guia dianteira
	oGet12     := TGet():New( 116,112,{|u| If(PCount()>0,M->TV5_RDDESQ:=u,M->TV5_RDDESQ)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","M->TV5_RDDESQ",,,,.t.)
	oGet13     := TGet():New( 116,153,{|u| If(PCount()>0,M->TV5_RDDDIR:=u,M->TV5_RDDDIR)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","M->TV5_RDDDIR",,,,.t.)
	oGet14     := TGet():New( 116,195,{|u| If(PCount()>0,M->TV5_UMRDD:=u,M->TV5_UMRDD)},oPanel1,024,008,'@!',{|| If(!Empty(M->TV5_UMRDD),EXISTCPO("SAH",M->TV5_UMRDD),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SAH","M->TV5_UMRDD",,,,.t.)

	//Rodas guia traseira
	oGet15     := TGet():New( 129,112,{|u| If(PCount()>0,M->TV5_RDTESQ:=u,M->TV5_RDTESQ)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","M->TV5_RDTESQ",,,,.t.)
	oGet16     := TGet():New( 129,153,{|u| If(PCount()>0,M->TV5_RDTDIR:=u,M->TV5_RDTDIR)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","M->TV5_RDTDIR",,,,.t.)
	oGet17     := TGet():New( 129,195,{|u| If(PCount()>0,M->TV5_UMRDT:=u,M->TV5_UMRDT)},oPanel1,024,008,'@!',{|| If(!Empty(M->TV5_UMRDT),EXISTCPO("SAH",M->TV5_UMRDT),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SAH","M->TV5_UMRDT",,,,.t.)

	//Roletes superior 1o
	oGet18     := TGet():New( 142,112,{|u| If(PCount()>0,M->TV5_RS1ESQ:=u,M->TV5_RS1ESQ)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","M->TV5_RS1ESQ",,,,.t.)
	oGet19     := TGet():New( 142,153,{|u| If(PCount()>0,M->TV5_RS1DIR:=u,M->TV5_RS1DIR)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","M->TV5_RS1DIR",,,,.t.)
	oGet20     := TGet():New( 142,195,{|u| If(PCount()>0,M->TV5_UMRS1:=u,M->TV5_UMRS1)},oPanel1,024,008,'@!',{|| If(!Empty(M->TV5_UMRS1),EXISTCPO("SAH",M->TV5_UMRS1),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SAH","M->TV5_UMRS1",,,,.t.)

	//Roletes superior 2o
	oGet21     := TGet():New( 155,112,{|u| If(PCount()>0,M->TV5_RS2ESQ:=u,M->TV5_RS2ESQ)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","M->TV5_RS2ESQ",,,,.t.)
	oGet22     := TGet():New( 155,153,{|u| If(PCount()>0,M->TV5_RS2DIR:=u,M->TV5_RS2DIR)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","M->TV5_RS2DIR",,,,.t.)
	oGet23     := TGet():New( 155,195,{|u| If(PCount()>0,M->TV5_UMRS2:=u,M->TV5_UMRS2)},oPanel1,024,008,'@!',{|| If(!Empty(M->TV5_UMRS2),EXISTCPO("SAH",M->TV5_UMRS2),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SAH","M->TV5_UMRS2",,,,.t.)

	//Roletes de esteira 1o
	oGet24     := TGet():New( 168,112,{|u| If(PCount()>0,M->TV5_RE1ESQ:=u,M->TV5_RE1ESQ)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","M->TV5_RE1ESQ",,,,.t.)
	oGet25     := TGet():New( 168,153,{|u| If(PCount()>0,M->TV5_RE1DIR:=u,M->TV5_RE1DIR)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","M->TV5_RE1DIR",,,,.t.)
	oGet26     := TGet():New( 168,195,{|u| If(PCount()>0,M->TV5_UMRE1:=u,M->TV5_UMRE1)},oPanel1,024,008,'@!',{|| If(!Empty(M->TV5_UMRE1),EXISTCPO("SAH",M->TV5_UMRE1),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SAH","M->TV5_UMRE1",,,,.t.)
	oCBox4     := TComboBox():New( 168,295,{|u| If(PCount()>0,M->TV5_FLARE1:=u,M->TV5_FLARE1)},{STR0007,STR0008},032,010,oPanel1,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,, ) //"Simples"###"Dupla"
	oCBox4:bHelp := { || ShowHelpCpo( 'TV5_FLARE1',	{ "Flange RE1: 1=Simples; 2=Dupla." }, 2,{}, 2 ) } //"Flange RE1: 1=Simples; 2=Dupla."

	//Roletes de esteira 2o
	oGet27     := TGet():New( 181,112,{|u| If(PCount()>0,M->TV5_RE2ESQ:=u,M->TV5_RE2ESQ)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","M->TV5_RE2ESQ",,,,.t.)
	oGet28     := TGet():New( 181,153,{|u| If(PCount()>0,M->TV5_RE2DIR:=u,M->TV5_RE2DIR)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","M->TV5_RE2DIR",,,,.t.)
	oGet29     := TGet():New( 181,195,{|u| If(PCount()>0,M->TV5_UMRE2:=u,M->TV5_UMRE2)},oPanel1,024,008,'@!',{|| If(!Empty(M->TV5_UMRE2),EXISTCPO("SAH",M->TV5_UMRE2),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SAH","M->TV5_UMRE2",,,,.t.)
	oCBox5     := TComboBox():New( 181,295,{|u| If(PCount()>0,M->TV5_FLARE2:=u,M->TV5_FLARE2)},{STR0007,STR0008},032,010,oPanel1,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,, ) //"Simples"###"Dupla"
	oCBox5:bHelp := { || ShowHelpCpo( 'TV5_FLARE2',	{ "Flange RE2: 1=Simples; 2=Dupla." }, 2,{}, 2 ) } //"Flange RE2: 1=Simples; 2=Dupla."

	//Roletes de esteira 3o
	oGet30     := TGet():New( 194,112,{|u| If(PCount()>0,M->TV5_RE3ESQ:=u,M->TV5_RE3ESQ)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","M->TV5_RE3ESQ",,,,.t.)
	oGet31     := TGet():New( 194,153,{|u| If(PCount()>0,M->TV5_RE3DIR:=u,M->TV5_RE3DIR)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","M->TV5_RE3DIR",,,,.t.)
	oGet32     := TGet():New( 194,195,{|u| If(PCount()>0,M->TV5_UMRE3:=u,M->TV5_UMRE3)},oPanel1,024,008,'@!',{|| If(!Empty(M->TV5_UMRE3),EXISTCPO("SAH",M->TV5_UMRE3),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SAH","M->TV5_UMRE3",,,,.t.)
	oCBox6     := TComboBox():New( 194,295,{|u| If(PCount()>0,M->TV5_FLARE3:=u,M->TV5_FLARE3)},{STR0007,STR0008},032,010,oPanel1,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,, ) //"Simples"###"Dupla"
	oCBox6:bHelp := { || ShowHelpCpo( 'TV5_FLARE3',	{ "Flange RE3: 1=Simples; 2=Dupla." }, 2,{}, 2 ) } //"Flange RE3: 1=Simples; 2=Dupla."

	//Roletes de esteira 4o
	oGet33     := TGet():New( 207,112,{|u| If(PCount()>0,M->TV5_RE4ESQ:=u,M->TV5_RE4ESQ)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","M->TV5_RE4ESQ",,,,.t.)
	oGet34     := TGet():New( 207,153,{|u| If(PCount()>0,M->TV5_RE4DIR:=u,M->TV5_RE4DIR)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","M->TV5_RE4DIR",,,,.t.)
	oGet35     := TGet():New( 207,195,{|u| If(PCount()>0,M->TV5_UMRE4:=u,M->TV5_UMRE4)},oPanel1,024,008,'@!',{|| If(!Empty(M->TV5_UMRE4),EXISTCPO("SAH",M->TV5_UMRE4),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SAH","M->TV5_UMRE4",,,,.t.)
	oCBox7     := TComboBox():New( 207,295,{|u| If(PCount()>0,M->TV5_FLARE4:=u,M->TV5_FLARE4)},{STR0007,STR0008},032,010,oPanel1,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,, ) //"Simples"###"Dupla"
	oCBox7:bHelp := { || ShowHelpCpo( 'TV5_FLARE4',	{ "Flange RE4: 1=Simples; 2=Dupla." }, 2,{}, 2 ) } //"Flange RE4: 1=Simples; 2=Dupla."

	//Roletes de esteira 5o
	oGet36     := TGet():New( 220,112,{|u| If(PCount()>0,M->TV5_RE5ESQ:=u,M->TV5_RE5ESQ)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","M->TV5_RE5ESQ",,,,.t.)
	oGet37     := TGet():New( 220,153,{|u| If(PCount()>0,M->TV5_RE5DIR:=u,M->TV5_RE5DIR)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","M->TV5_RE5DIR",,,,.t.)
	oGet38     := TGet():New( 220,195,{|u| If(PCount()>0,M->TV5_UMRE5:=u,M->TV5_UMRE5)},oPanel1,024,008,'@!',{|| If(!Empty(M->TV5_UMRE5),EXISTCPO("SAH",M->TV5_UMRE5),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SAH","M->TV5_UMRE5",,,,.t.)
	oCBox8     := TComboBox():New( 220,295,{|u| If(PCount()>0,M->TV5_FLARE5:=u,M->TV5_FLARE5)},{STR0007,STR0008},032,010,oPanel1,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,, ) //"Simples"###"Dupla"
	oCBox8:bHelp := { || ShowHelpCpo( 'TV5_FLARE5',	{ "Flange RE5: 1=Simples; 2=Dupla." }, 2,{}, 2 ) } //"Flange RE5: 1=Simples; 2=Dupla."

	//Roletes de esteira 6o
	oGet39     := TGet():New( 233,112,{|u| If(PCount()>0,M->TV5_RE6ESQ:=u,M->TV5_RE6ESQ)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","M->TV5_RE6ESQ",,,,.t.)
	oGet40     := TGet():New( 233,153,{|u| If(PCount()>0,M->TV5_RE6DIR:=u,M->TV5_RE6DIR)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","M->TV5_RE6DIR",,,,.t.)
	oGet41     := TGet():New( 233,195,{|u| If(PCount()>0,M->TV5_UMRE6:=u,M->TV5_UMRE6)},oPanel1,024,008,'@!',{|| If(!Empty(M->TV5_UMRE6),EXISTCPO("SAH",M->TV5_UMRE6),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SAH","M->TV5_UMRE6",,,,.t.)
	oCBox9     := TComboBox():New( 233,295,{|u| If(PCount()>0,M->TV5_FLARE6:=u,M->TV5_FLARE6)},{STR0007,STR0008},032,010,oPanel1,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,, ) //"Simples"###"Dupla"
	oCBox9:bHelp := { || ShowHelpCpo( 'TV5_FLARE6',	{ "Flange RE6: 1=Simples; 2=Dupla." }, 2,{}, 2 ) } //"Flange RE6: 1=Simples; 2=Dupla."

	//Roletes de esteira 7o
	oGet42     := TGet():New( 246,112,{|u| If(PCount()>0,M->TV5_RE7ESQ:=u,M->TV5_RE7ESQ)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","M->TV5_RE7ESQ",,,,.t.)
	oGet43     := TGet():New( 246,153,{|u| If(PCount()>0,M->TV5_RE7DIR:=u,M->TV5_RE7DIR)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","M->TV5_RE7DIR",,,,.t.)
	oGet44     := TGet():New( 246,195,{|u| If(PCount()>0,M->TV5_UMRE7:=u,M->TV5_UMRE7)},oPanel1,024,008,'@!',{|| If(!Empty(M->TV5_UMRE7),EXISTCPO("SAH",M->TV5_UMRE7),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SAH","M->TV5_UMRE7",,,,.t.)
	oCBox10    := TComboBox():New( 246,295,{|u| If(PCount()>0,M->TV5_FLARE7:=u,M->TV5_FLARE7)},{STR0007,STR0008},032,010,oPanel1,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,, ) //"Simples"###"Dupla"
	oCBox10:bHelp := { || ShowHelpCpo( 'TV5_FLARE7',	{ "Flange RE7: 1=Simples; 2=Dupla." }, 2,{}, 2 ) } //"Flange RE7: 1=Simples; 2=Dupla."

	//Roletes de esteira 8o
	oGet45     := TGet():New( 259,112,{|u| If(PCount()>0,M->TV5_RE8ESQ:=u,M->TV5_RE8ESQ)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","M->TV5_RE8ESQ",,,,.t.)
	oGet46     := TGet():New( 259,153,{|u| If(PCount()>0,M->TV5_RE8DIR:=u,M->TV5_RE8DIR)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","M->TV5_RE8DIR",,,,.t.)
	oGet47     := TGet():New( 259,195,{|u| If(PCount()>0,M->TV5_UMRE8:=u,M->TV5_UMRE8)},oPanel1,024,008,'@!',{|| If(!Empty(M->TV5_UMRE8),EXISTCPO("SAH",M->TV5_UMRE8),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SAH","M->TV5_UMRE8",,,,.t.)
	oCBox11    := TComboBox():New( 259,295,{|u| If(PCount()>0,M->TV5_FLARE8:=u,M->TV5_FLARE8)},{STR0007,STR0008},032,010,oPanel1,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,, ) //"Simples"###"Dupla"
	oCBox11:bHelp := { || ShowHelpCpo( 'TV5_FLARE8',	{ "Flange RE8: 1=Simples; 2=Dupla." }, 2,{}, 2 ) } //"Flange RE8: 1=Simples; 2=Dupla."

	//Rodas Motrizes
	oGet48     := TGet():New( 272,112,{|u| If(PCount()>0,M->TV5_RDMESQ:=u,M->TV5_RDMESQ)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","M->TV5_RDMESQ",,,,.t.)
	oGet49     := TGet():New( 272,153,{|u| If(PCount()>0,M->TV5_RDMDIR:=u,M->TV5_RDMDIR)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","M->TV5_RDMDIR",,,,.t.)
	oGet50     := TGet():New( 272,195,{|u| If(PCount()>0,M->TV5_UMRDM:=u,M->TV5_UMRDM)},oPanel1,024,008,'@!',{|| If(!Empty(M->TV5_UMRDM),EXISTCPO("SAH",M->TV5_UMRDM),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SAH","M->TV5_UMRDM",,,,.t.)

	Activate MsDialog oDlg1 Centered On Init EnchoiceBar(oDlg1,{||nOpca:=1,oDlg1:End()},{||nOpca:=0,oDlg1:End()})

	If nOpca == 1
		MNT688GRV(cCodBem)
	EndIf
	//+-------------------------------------------+
	//| Retorna conteudo de variaveis padroes     |
	//+-------------------------------------------+
	NGRETURNPRM(aNGBEGINPRM)

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT688GRV()
Gravacao da especificacao do material rodante
@author Evaldo Cevinscki Jr.
@since 24/05/2010
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Function MNT688GRV(cCodBem)

	DbSelectArea("TV5")
	DbSetOrder(1)
	If !DbSeek(xFilial("TV5")+cCodBem)
		Reclock("TV5",.t.)
	Else
		Reclock("TV5",.f.)
	EndIf
	TV5->TV5_FILIAL	:= xFilial("TV5")
	TV5->TV5_CODBEM	:=	cCodBem
	TV5->TV5_LARSAP	:=	M->TV5_LARSAP
	TV5->TV5_NUMSEC	:=	M->TV5_NUMSEC
	TV5->TV5_ELOESQ	:=	M->TV5_ELOESQ
	TV5->TV5_BUCESQ	:=	M->TV5_BUCESQ
	TV5->TV5_SAPESQ	:=	M->TV5_SAPESQ
	TV5->TV5_RDDESQ	:=	M->TV5_RDDESQ
	TV5->TV5_RDTESQ	:=	M->TV5_RDTESQ
	TV5->TV5_ELODIR	:=	M->TV5_ELODIR
	TV5->TV5_BUCDIR	:=	M->TV5_BUCDIR
	TV5->TV5_SAPDIR	:=	M->TV5_SAPDIR
	TV5->TV5_RDDDIR	:=	M->TV5_RDDDIR
	TV5->TV5_RDTDIR	:=	M->TV5_RDTDIR
	TV5->TV5_RE1ESQ	:=	M->TV5_RE1ESQ
	TV5->TV5_RE2ESQ	:=	M->TV5_RE2ESQ
	TV5->TV5_RE3ESQ	:=	M->TV5_RE3ESQ
	TV5->TV5_RE4ESQ	:=	M->TV5_RE4ESQ
	TV5->TV5_RE5ESQ	:=	M->TV5_RE5ESQ
	TV5->TV5_RE6ESQ	:=	M->TV5_RE6ESQ
	TV5->TV5_RE7ESQ	:=	M->TV5_RE7ESQ
	TV5->TV5_RE8ESQ	:=	M->TV5_RE8ESQ
	TV5->TV5_RDMESQ	:=	M->TV5_RDMESQ
	TV5->TV5_RS1ESQ	:=	M->TV5_RS1ESQ
	TV5->TV5_RS2ESQ	:=	M->TV5_RS2ESQ
	TV5->TV5_RE1DIR	:=	M->TV5_RE1DIR
	TV5->TV5_RE2DIR	:=	M->TV5_RE2DIR
	TV5->TV5_RE3DIR	:=	M->TV5_RE3DIR
	TV5->TV5_RE4DIR	:=	M->TV5_RE4DIR
	TV5->TV5_RE5DIR	:=	M->TV5_RE5DIR
	TV5->TV5_RE6DIR	:=	M->TV5_RE6DIR
	TV5->TV5_RE7DIR	:=	M->TV5_RE7DIR
	TV5->TV5_RE8DIR	:=	M->TV5_RE8DIR
	TV5->TV5_RDMDIR	:=	M->TV5_RDMDIR
	TV5->TV5_RS1DIR	:=	M->TV5_RS1DIR
	TV5->TV5_RS2DIR	:=	M->TV5_RS2DIR
	TV5->TV5_NUMPEC	:=	M->TV5_NUMPEC
	TV5->TV5_UMELO	:=	M->TV5_UMELO
	TV5->TV5_UMBUC	:=	M->TV5_UMBUC
	TV5->TV5_UMSAP	:=	M->TV5_UMSAP
	TV5->TV5_UMRDD	:=	M->TV5_UMRDD
	TV5->TV5_UMRDT	:=	M->TV5_UMRDT
	TV5->TV5_UMRS1	:=	M->TV5_UMRS1
	TV5->TV5_UMRS2	:=	M->TV5_UMRS2
	TV5->TV5_UMRE1	:=	M->TV5_UMRE1
	TV5->TV5_UMRE2	:=	M->TV5_UMRE2
	TV5->TV5_UMRE3	:=	M->TV5_UMRE3
	TV5->TV5_UMRE4	:=	M->TV5_UMRE4
	TV5->TV5_UMRE5	:=	M->TV5_UMRE5
	TV5->TV5_UMRE6	:=	M->TV5_UMRE6
	TV5->TV5_UMRE7	:=	M->TV5_UMRE7
	TV5->TV5_UMRE8	:=	M->TV5_UMRE8
	TV5->TV5_UMRDM	:=	M->TV5_UMRDM
	TV5->TV5_TIPEST	:=	IF(M->TV5_TIPEST == STR0003,"1","2")   //"Selada"
	TV5->TV5_GIRADA	:=	IF(M->TV5_GIRADA == STR0005,"1","2")   //"Sim"
	TV5->TV5_GARSIM	:=	IF(M->TV5_GARSIM == STR0005,"1","2")   //"Sim"
	TV5->TV5_FLARE1	:=	IF(M->TV5_FLARE1 == STR0007,"1","2")   //"Simples"
	TV5->TV5_FLARE2	:=	IF(M->TV5_FLARE2 == STR0007,"1","2")   //"Simples"
	TV5->TV5_FLARE3	:=	IF(M->TV5_FLARE3 == STR0007,"1","2")   //"Simples"
	TV5->TV5_FLARE4	:=	IF(M->TV5_FLARE4 == STR0007,"1","2")   //"Simples"
	TV5->TV5_FLARE5	:=	IF(M->TV5_FLARE5 == STR0007,"1","2")   //"Simples"
	TV5->TV5_FLARE6	:=	IF(M->TV5_FLARE6 == STR0007,"1","2")   //"Simples"
	TV5->TV5_FLARE7	:=	IF(M->TV5_FLARE7== STR0007,"1","2")   //"Simples"
	TV5->TV5_FLARE8	:=	IF(M->TV5_FLARE8== STR0007,"1","2")   //"Simples"
	TV5->(MsUnLock())

Return .T.

//------------------------------------------------------------------------
/*/{Protheus.doc} MNT688G080()
Grava dados nas tabelas da Construção Civil pelo MNTA080
@author  Maria Elisandra de Paula
@since   05/06/2014
@version MP11
@return  Nil
/*/
//-------------------------------------------------------------------------
Function MNT688G080()

	Local aArea := GetArea()
	Local lRet  := .t.
	Local oDlg, oMemo, oPanel
	Local cMotivo
	Local cCodBem := Space(Len(ST9->T9_CODBEM))

	If Inclui .OR. Altera

		MNT691PAD() //Grava Material Rodante a partir do Bem Padrao

		If NGCADICBASE("T9_DTDESMO","A","ST9",.F.)
			If (INCLUI .And. !Empty(M->T9_DTDESMO)) .Or. (ALTERA .And. M->T9_DTDESMO <> ST9->T9_DTDESMO)
				dbSelectArea("TVZ")
				dbSetOrder(1)
				If !dbSeek(xFilial("TVZ")+M->T9_CODBEM+DTOS(dDataBase)+SubStr(Time(),1,5))
					RecLock("TVZ",.T.)
					TVZ->TVZ_FILIAL := xFilial("ST9")
					TVZ->TVZ_CODBEM := M->T9_CODBEM
					TVZ->TVZ_DTALT  := dDataBase
					TVZ->TVZ_HRALT  := SubStr(Time(),1,5)
					TVZ->TVZ_DTDES  := M->T9_DTDESMO
					TVZ->TVZ_CODUSU := RetCodUsr()
					MsUnlock("TVZ")
				EndIf
			EndIf
		Endif

		If (Altera .AND. M->T9_ALUGUEL <> ST9->T9_ALUGUEL) .OR. (Altera .AND. M->T9_VALFAT <> ST9->T9_VALFAT) .OR. Inclui
			cCodBem := M->T9_CODBEM
		Else
			Return
		Endif

		If Inclui

			cMotivo := "Inclusão em: " + DToC(dDataBase)

		Else

			Define MsDialog oDlg Title "Histórico de Alteração - Campos 'Aluguel?' e 'Val. Faturado'" From 50,20 To 60,89.4 Of oMainWnd

			oDlg:lEscClose := .F.

			oPanel := TPanel():New( 01, 01,, oDlg,,,,,,,, .F., .F. )
			oPanel:Align := CONTROL_ALIGN_ALLCLIENT

			@ 09, 5 Say OemToAnsi("Informe o motivo da alteração:") Size 130,07 Of oPanel Pixel COLOR CLR_BLUE

			@ 18, 5 Get oMemo Var cMotivo Memo Size 268,40 Memo Of oPanel Pixel

			Activate MsDialog oDlg Centered Valid fCheckMot(cMotivo);
			On Init (EnchoiceBar(oDlg, {|| },{|| IIf( fCheckMot(cMotivo), oDlg:End(),) },,,,,,, .F., .F.))

		EndIf

		dbSelectArea("TV8")
		dbSetOrder(01)
		If !dbSeek(xFilial("TV8")+cCodBem+DTOS(dDatabase)+Time())
			RecLock("TV8",.t.)
			TV8->TV8_FILIAL := xFilial("TV8")
			TV8->TV8_CODBEM := cCodBem
			TV8->TV8_DATALT := dDatabase
			TV8->TV8_HORALT := Time()
			TV8->TV8_ROTINA := FunName()
		Else
			RecLock("TV8",.f.)
		Endif
		TV8->TV8_USUARI := cUserName

		TV8->TV8_ANTALU := IIF(Inclui,'',ST9->T9_ALUGUEL)
		TV8->TV8_NOVALU := M->T9_ALUGUEL
		TV8->TV8_MOTIVO := cMotivo

		TV8->(MsUnLock())

	Else
		dbSelectArea("TV5")
		dbSetOrder(01)
		If dbSeek(xFilial("TV5")+ST9->T9_CODBEM)
			RecLock("TV5",.f.)
			dbDelete()
			MsUnlock("TV5")
		Endif
	Endif


	RestArea(aArea)

Return lRet

//------------------------------------------------------------------------
/*/{Protheus.doc} fCheckMot()
Valida campo justificativa/motivo para alteração/exclusão obrigatória
@author Marcos Wagner Junior
@since 02/06/2010
/*/
//-------------------------------------------------------------------------
Static Function fCheckMot( cMotivo )

	Local lRet

	If !( lRet := !Empty( cMotivo ) )
		Alert("É obrigatório informar o motivo!", STR0002)
	EndIf

Return lRet

/*
Funções do mnta435
*/
//------------------------------------------------------------------------
/*/{Protheus.doc} MNT435MR()
Tela de retorno de Medicoes do Material Rodante

@author Marcos Wagner Junior
@since   02/06/2010
@version MP11

@param lMNTA435, Lógico, Define se a chamada vem do MNTA435

@return  Nil
/*/
//-------------------------------------------------------------------------
Function MNT435MR( lMNTA435 )

	Local cOrdem
	Local cPlano
	Local aAreaTV5
	Local aArea		:= GetArea()
	Local nAltura	:= (GetScreenRes()[2]*0.85)
	Local nLargura	:= (GetScreenRes()[1]/1.06)
	Local oFont14N	:= TFont():New("Arial",,14,,.T.,,,,.F.,.F.)
	Local nOpca		:= 0
	Local cWhen 	:= "{|| .f.}"
	Local i
	Local bVldGet 	:= {|| Positivo() .And. fVldGet()}
	Local oTempTable
	Local lPerg := .T.

	Private cTRB	:= GetNextAlias()
	Private nLarg,nSecs,nEloEsq,nBucEsq,nSapEsq,nRdDEsq,nRdTEsq,nEloDir,nBucDir,nSapDir,nRdDDir,nRdTDir
	Private nRE1Esq,nRE2Esq,nRE3Esq,nRE4Esq,nRE5Esq,nRE6Esq,nRE7Esq,nRE8Esq,nRdMEsq,nRS1Esq,nRS2Esq,nRE1Dir,nRE2Dir
	Private nRE3Dir,nRE4Dir,nRE5Dir,nRE6Dir,nRE7Dir,nRE8Dir,nRdMDir,nRS1Dir,nRS2Dir,nPcsElo
	Private cUMElo,cUMBuc,cUMSap,cUMDia,cUMTra,cUMRS1,cUMRS2,cUMRE1,cUMRE2,cUMRE3,cUMRE4,cUMRE5,cUMRE6,cUMRE7,cUMRE8
	Private cUMRdM,cBox1,cBox2,cBox3,cBox4,cBox5,cBox6,cBox7,cBox8,cBox9,cBox10,cBox11
	Private oScrollBox, cEsq,cDir
	Private aFlange := {STR0095,STR0096} //"Simples" # "Dupla"
	Private aSize := MsAdvSize(,.f.,430), aObjects := {}
	Private aWhenGet := {}

	Default lMNTA435 := .F.

	// Verifica se a chamada vem do MNTA435 para pegar as informações corretamente
	If lMNTA435
		cOrdem := (cAliOS435)->TJ_ORDEM
		cPlano := (cAliOS435)->TJ_PLANO
		dbSelectArea("STJ")
		dbSetOrder(01)
		If !dbSeek(xFilial("STJ")+cOrdem+cPlano)
			MsgInfo(STR0134) //"Nenhuma ordem de serviço foi selecionada."
			RestArea(aArea)
			Return .f.
		Endif
	EndIf

	Private cCodBem := STJ->TJ_CODBEM

	DbSelectArea("TV5")
	DbSetOrder(1)
	If !DbSeek(xFilial("TV5")+cCodBem)
		MsgInfo(STR0097,STR0076)//"Esse Bem não possui material rodante cadastrado"###"ATENÇÃO"
		RestArea(aArea)
		Return .f.
	Else
		aComp := MNT435MR1( @lPerg )
		If MV_PAR01 == MV_PAR02
			HELP( ' ', 1, "NGATENCAO",, STR0145, 2, 0,,,,,, { STR0146 } ) //'Não é possivel informais locais iguais.' ## 'Informar localizações direfentes.'
			Return .f.
		ElseIf ( Empty(aComp[1]) .Or. Empty(aComp[2]) ) .AND. lPerg
			MsgInfo(STR0098,STR0076)//"Esse Bem não possui material rodante cadastrado na sua Estrutura"###"ATENÇÃO"
			RestArea(aArea)
			Return .f.
		ElseIf !lPerg //Caso a tela de perguntas seja cancelada
			Return .F.
		EndIf
	EndIf

	aAreaTV5 := GetArea()
	dbSelectArea( "TVK" )
	dbSetOrder( 1 )
	If !dbSeek(xFilial( "TVK" ) + STJ->TJ_CODBEM + STJ->TJ_SERVICO + STJ->TJ_SEQRELA )
		If !MsgYesNo( STR0135, STR0076 )
			Return .F.
		EndIf
	EndIf
	RestArea( aAreaTV5 )

	nLarg 	:= IIF(TV5->TV5_LARSAP <> 0,TV5->TV5_LARSAP,0)
	nSecs	:= IIF(TV5->TV5_NUMSEC <> 0,TV5->TV5_NUMSEC,0)

	nEloEsq	:= IIF(TV5->TV5_ELOESQ <> 0,TV5->TV5_ELOESQ,0); aAdd(aWhenGet,{"TV5_ELOESQ",nEloEsq != 0})
	nEloDir	:= IIF(TV5->TV5_ELODIR <> 0,TV5->TV5_ELODIR,0); aAdd(aWhenGet,{"TV5_ELODIR",nEloDir != 0})
	nBucEsq	:= IIF(TV5->TV5_BUCESQ <> 0,TV5->TV5_BUCESQ,0); aAdd(aWhenGet,{"TV5_BUCESQ",nBucEsq != 0})
	nBucDir	:= IIF(TV5->TV5_BUCDIR <> 0,TV5->TV5_BUCDIR,0); aAdd(aWhenGet,{"TV5_BUCDIR",nBucDir != 0})
	nSapEsq	:= IIF(TV5->TV5_SAPESQ <> 0,TV5->TV5_SAPESQ,0); aAdd(aWhenGet,{"TV5_SAPESQ",nSapEsq != 0})
	nSapDir	:= IIF(TV5->TV5_SAPDIR <> 0,TV5->TV5_SAPDIR,0); aAdd(aWhenGet,{"TV5_SAPDIR",nSapDir != 0})
	nRdDEsq	:= IIF(TV5->TV5_RDDESQ <> 0,TV5->TV5_RDDESQ,0); aAdd(aWhenGet,{"TV5_RDDESQ",nRdDEsq != 0})
	nRdDDir	:= IIF(TV5->TV5_RDDDIR <> 0,TV5->TV5_RDDDIR,0); aAdd(aWhenGet,{"TV5_RDDDIR",nRdDDir != 0})
	nRdTEsq	:= IIF(TV5->TV5_RDTESQ <> 0,TV5->TV5_RDTESQ,0); aAdd(aWhenGet,{"TV5_RDTESQ",nRdTEsq != 0})
	nRdTDir	:= IIF(TV5->TV5_RDTDIR <> 0,TV5->TV5_RDTDIR,0); aAdd(aWhenGet,{"TV5_RDTDIR",nRdTDir != 0})

	nRS1Esq	:= IIF(TV5->TV5_RS1ESQ <> 0,TV5->TV5_RS1ESQ,0); aAdd(aWhenGet,{"TV5_RS1ESQ",nRS1Esq != 0})
	nRS1Dir	:= IIF(TV5->TV5_RS1DIR <> 0,TV5->TV5_RS1DIR,0); aAdd(aWhenGet,{"TV5_RS1DIR",nRS1Dir != 0})
	nRS2Esq	:= IIF(TV5->TV5_RS2ESQ <> 0,TV5->TV5_RS2ESQ,0); aAdd(aWhenGet,{"TV5_RS2ESQ",nRS2Esq != 0})
	nRS2Dir	:= IIF(TV5->TV5_RS2DIR <> 0,TV5->TV5_RS2DIR,0); aAdd(aWhenGet,{"TV5_RS2DIR",nRS2Dir != 0})

	nRE1Esq	:= IIF(TV5->TV5_RE1ESQ <> 0,TV5->TV5_RE1ESQ,0); aAdd(aWhenGet,{"TV5_RE1ESQ",nRE1Esq != 0})
	nRE1Dir	:= IIF(TV5->TV5_RE1DIR <> 0,TV5->TV5_RE1DIR,0); aAdd(aWhenGet,{"TV5_RE1DIR",nRE1Dir != 0})
	nRE2Esq	:= IIF(TV5->TV5_RE2ESQ <> 0,TV5->TV5_RE2ESQ,0); aAdd(aWhenGet,{"TV5_RE2ESQ",nRE2Esq != 0})
	nRE2Dir	:= IIF(TV5->TV5_RE2DIR <> 0,TV5->TV5_RE2DIR,0); aAdd(aWhenGet,{"TV5_RE2DIR",nRE2Dir != 0})
	nRE3Esq	:= IIF(TV5->TV5_RE3ESQ <> 0,TV5->TV5_RE3ESQ,0); aAdd(aWhenGet,{"TV5_RE3ESQ",nRE3Esq != 0})
	nRE3Dir	:= IIF(TV5->TV5_RE3DIR <> 0,TV5->TV5_RE3DIR,0); aAdd(aWhenGet,{"TV5_RE3DIR",nRE3Dir != 0})
	nRE4Esq	:= IIF(TV5->TV5_RE4ESQ <> 0,TV5->TV5_RE4ESQ,0); aAdd(aWhenGet,{"TV5_RE4ESQ",nRE4Esq != 0})
	nRE4Dir	:= IIF(TV5->TV5_RE4DIR <> 0,TV5->TV5_RE4DIR,0); aAdd(aWhenGet,{"TV5_RE4DIR",nRE4Dir != 0})
	nRE5Esq	:= IIF(TV5->TV5_RE5ESQ <> 0,TV5->TV5_RE5ESQ,0); aAdd(aWhenGet,{"TV5_RE5ESQ",nRE5Esq != 0})
	nRE5Dir	:= IIF(TV5->TV5_RE5DIR <> 0,TV5->TV5_RE5DIR,0); aAdd(aWhenGet,{"TV5_RE5DIR",nRE5Dir != 0})
	nRE6Esq	:= IIF(TV5->TV5_RE6ESQ <> 0,TV5->TV5_RE6ESQ,0); aAdd(aWhenGet,{"TV5_RE6ESQ",nRE6Esq != 0})
	nRE6Dir	:= IIF(TV5->TV5_RE6DIR <> 0,TV5->TV5_RE6DIR,0); aAdd(aWhenGet,{"TV5_RE6DIR",nRE6Dir != 0})
	nRE7Esq	:= IIF(TV5->TV5_RE7ESQ <> 0,TV5->TV5_RE7ESQ,0); aAdd(aWhenGet,{"TV5_RE7ESQ",nRE7Esq != 0})
	nRE7Dir	:= IIF(TV5->TV5_RE7DIR <> 0,TV5->TV5_RE7DIR,0); aAdd(aWhenGet,{"TV5_RE7DIR",nRE7Dir != 0})
	nRE8Esq	:= IIF(TV5->TV5_RE8ESQ <> 0,TV5->TV5_RE8ESQ,0); aAdd(aWhenGet,{"TV5_RE8ESQ",nRE8Esq != 0})
	nRE8Dir	:= IIF(TV5->TV5_RE8DIR <> 0,TV5->TV5_RE8DIR,0); aAdd(aWhenGet,{"TV5_RE8DIR",nRE8Dir != 0})

	nRdMEsq	:= IIF(TV5->TV5_RDMESQ <> 0,TV5->TV5_RDMESQ,0); aAdd(aWhenGet,{"TV5_RDMESQ",nRdMEsq != 0})
	nRdMDir	:= IIF(TV5->TV5_RDMDIR <> 0,TV5->TV5_RDMDIR,0); aAdd(aWhenGet,{"TV5_RDMDIR",nRdMDir != 0})

	nPcsElo	:= IIF(TV5->TV5_NUMPEC <> 0,TV5->TV5_NUMPEC,0)
	cUMElo	:= IIF(Empty(TV5->TV5_UMELO),Space(Len(TV5->TV5_UMELO)),TV5->TV5_UMELO)
	cUMBuc	:= IIF(Empty(TV5->TV5_UMBUC),Space(Len(TV5->TV5_UMBUC)),TV5->TV5_UMBUC)
	cUMSap	:= IIF(Empty(TV5->TV5_UMSAP),Space(Len(TV5->TV5_UMSAP)),TV5->TV5_UMSAP)
	cUMDia	:= IIF(Empty(TV5->TV5_UMRDD),Space(Len(TV5->TV5_UMRDD)),TV5->TV5_UMRDD)
	cUMTra	:= IIF(Empty(TV5->TV5_UMRDT),Space(Len(TV5->TV5_UMRDT)),TV5->TV5_UMRDT)
	cUMRS1	:= IIF(Empty(TV5->TV5_UMRS1),Space(Len(TV5->TV5_UMRS1)),TV5->TV5_UMRS1)
	cUMRS2	:= IIF(Empty(TV5->TV5_UMRS2),Space(Len(TV5->TV5_UMRS2)),TV5->TV5_UMRS2)
	cUMRE1	:= IIF(Empty(TV5->TV5_UMRE1),Space(Len(TV5->TV5_UMRE1)),TV5->TV5_UMRE1)
	cUMRE2	:= IIF(Empty(TV5->TV5_UMRE2),Space(Len(TV5->TV5_UMRE2)),TV5->TV5_UMRE2)
	cUMRE3	:= IIF(Empty(TV5->TV5_UMRE3),Space(Len(TV5->TV5_UMRE3)),TV5->TV5_UMRE3)
	cUMRE4	:= IIF(Empty(TV5->TV5_UMRE4),Space(Len(TV5->TV5_UMRE4)),TV5->TV5_UMRE4)
	cUMRE5	:= IIF(Empty(TV5->TV5_UMRE5),Space(Len(TV5->TV5_UMRE5)),TV5->TV5_UMRE5)
	cUMRE6	:= IIF(Empty(TV5->TV5_UMRE6),Space(Len(TV5->TV5_UMRE6)),TV5->TV5_UMRE6)
	cUMRE7	:= IIF(Empty(TV5->TV5_UMRE7),Space(Len(TV5->TV5_UMRE7)),TV5->TV5_UMRE7)
	cUMRE8	:= IIF(Empty(TV5->TV5_UMRE8),Space(Len(TV5->TV5_UMRE8)),TV5->TV5_UMRE8)
	cUMRdM	:= IIF(Empty(TV5->TV5_UMRDM),Space(Len(TV5->TV5_UMRDM)),TV5->TV5_UMRDM)
	cBox1	:= IIF(Empty(TV5->TV5_TIPEST),STR0099,If(TV5->TV5_TIPEST == "1",STR0099,STR0100))//"Selada"###"Selada e Lubfificada"

	dbSelectArea("TV9")
	aStruct := TV9->(DbStruct())
		aAdd(aStruct,{"FLARE1", "C", 7, 0})
		aAdd(aStruct,{"FLARE2", "C", 7, 0})
		aAdd(aStruct,{"FLARE3", "C", 7, 0})
		aAdd(aStruct,{"FLARE4", "C", 7, 0})
		aAdd(aStruct,{"FLARE5", "C", 7, 0})
		aAdd(aStruct,{"FLARE6", "C", 7, 0})
		aAdd(aStruct,{"FLARE7", "C", 7, 0})
		aAdd(aStruct,{"FLARE8", "C", 7, 0})

	//Criação Tabela Temporária
	oTempTable := NGFwTmpTbl(cTRB,aStruct,{{"TV9_FILIAL","TV9_CODBEM","TV9_ORDEM"}})

	z := 1
	NGIFDBSEEK("TV9",STJ->TJ_CODBEM+STJ->TJ_ORDEM+STJ->TJ_PLANO,1)
	(cTRB)->(DbAppend())
	For i := 1 TO TV9->(FCount())
		x := "TV9->" + TV9->(FieldName(i))
		y := "(cTRB)->" + TV9->(FieldName(i))
		If "FILIAL" $ x
			Replace &y. With xFilial("TV9")
		ElseIf "CODBEM" $ x
			Replace &y. With STJ->TJ_CODBEM
		ElseIf "ORDEM" $ x
			Replace &y. With STJ->TJ_ORDEM
		ElseIf "PLANO" $ x
			Replace &y. With STJ->TJ_PLANO
		ElseIf "FLARE"+AllTrim(Str(z)) $ x
			cCampo := "(cTRB)->FLARE"+AllTrim(Str(z))
			z++
			If &x == "1"
				Replace &cCampo. With aFlange[1]
			ElseIf &x == "2"
				Replace &cCampo. With aFlange[2]
			EndIf
		ElseIf SubStr(x,At('_',x)+1) $ "MEDELO/MEDBUC/MEDSAP/MEDRDD/MEDRDT/MEDRS1/MEDRS2/"+;
		"MEDRE1/MEDRE2/MEDRE3/MEDRE4/MEDRE5/MEDRE6/MEDRE7/MEDRE8/MEDRDM"
			Replace &y. With &x.
		Else
			Replace &y. with &x.
		EndIf
	Next i

	cBem		:= STJ->TJ_CODBEM
	cOrdem	:= STJ->TJ_ORDEM
	If Empty((cTRB)->TV9_DTMED)
		(cTRB)->TV9_DTMED	:=	dDataBase
	EndIf
	cEsq		:= aComp[1]
	cDir		:= aComp[2]

	// Declaração de Variaveis Private dos Objetos
	SetPrvt("oDlg8","oPanel1","oSay1","oSay2","oSay3","oSay4","oSay5","oSay6","oSay7","oSay8","oSay9","oSay10")
	SetPrvt("oSay12","oSay13","oSay14","oSay15","oSay16","oGet1","oGet2","oCBox1","oGet3","oGet4","oGet5")
	SetPrvt("oGet7","oGet8","oGet9","oGet10","oGet11","oGet12","oGet13","oGet14","oGet15","oGet16","oGet17")
	SetPrvt("oGet19","oGet20")

	Define MsDialog oDlg8 Title STR0094 + " - " + STJ->TJ_CODBEM From 0,0 To nAltura,nLargura Of oMainWnd Pixel COLOR CLR_BLACK,CLR_WHITE //"Medição do Material Rodante"
	oDlg8:lEscClose  := .F.
	oDlg8:lMaximized := .T.
	Aadd(aObjects,{150,10,.T.,.T.}) // Indica dimensoes x e y e indica que redimensiona x e y
	Aadd(aObjects,{200,30,.T.,.T.}) // Indica dimensoes x e y e indica que redimensiona x e y e assume que retorno sera em linha final coluna final (.F.)

	aSize		:= MsAdvSize()
	aInfo		:= {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
	aPosObj	:= MsObjSize(aInfo,aObjects,.T.)

	oPanel1   		:= TScrollBox():new(oDlg8, 003,003, aPosObj[2,3]-aPosObj[2,1] - 20, ((aPosObj[2,4]) / 2) + 10 , .T., .T., .T.)
	oPanel1:Align 	:= CONTROL_ALIGN_ALLCLIENT

	@ 4.5,10.5 To 21,26   LABEL "" OF oPanel1
	@ 4.5,28   To 21,39.5 LABEL "" OF oPanel1
	@ 4.5,40.3 To 21,51.5 LABEL "" OF oPanel1

	oSay1	:= TSay():New( 006,012,{||STR0101},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,044,008)//"Bem Pai"
	oSay2	:= TSay():New( 006,152,{||STR0102},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,048,008)//"Ordem de Serviço"
	oSay3	:= TSay():New( 020,012,{||STR0103},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,044,008)//"Largura Sapatas"
	oSay4	:= TSay():New( 020,152,{||STR0104},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,048,008)//"Número de Seções"
	oSay5	:= TSay():New( 020,290,{||STR0105},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,040,008)//"Tipo de Esteira"
	oSay6 	:= TSay():New( 034,012,{||STR0085},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,048,008)//"Comp. Esquerdo"
	oSay7 	:= TSay():New( 034,152,{||STR0039},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,048,008)//"Comp. Direito"
	oSay8 	:= TSay():New( 034,290,{||STR0040},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,040,008)//"Data Medição"

	oSay9		:= TSay():New( 050,012,{||STR0041},oPanel1,,oFont14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,032,008)//"Conjuntos"
	oSay10	:= TSay():New( 050,124,{||STR0042},oPanel1,,oFont14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,070,008)//"Dimensões Iniciais"
	oSay11	:= TSay():New( 050,230,{||STR0043},oPanel1,,oFont14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,070,008)//"Dimensões Encontradas"
	oSay12	:= TSay():New( 050,330,{||STR0044},oPanel1,,oFont14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,070,008)//"Percentual Desgaste"
	oSay13	:= TSay():New( 050,419,{||STR0045},oPanel1,,oFont14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,070,008)//"Medidor"
	oSay14	:= TSay():New( 050,495,{||STR0046},oPanel1,,oFont14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,070,008)//"Observação"

	oSay15	:= TSay():New( 065,092,{||STR0047},oPanel1,,oFont14N,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,026,008)//"Esquerda"
	oSay16	:= TSay():New( 065,136,{||STR0048},oPanel1,,oFont14N,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,024,008)//"Direita"
	oSay17	:= TSay():New( 065,178,{||STR0049},oPanel1,,oFont14N,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,024,008)//"Unidade"

	oSay18	:= TSay():New( 065,230,{||STR0047},oPanel1,,oFont14N,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,026,008)//"Esquerda"
	oSay19  := TSay():New( 065,274,{||STR0048},oPanel1,,oFont14N,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,024,008)//"Direita"

	oSay20	:= TSay():New( 065,330,{||STR0047},oPanel1,,oFont14N,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,026,008)//"Esquerda"
	oSay21	:= TSay():New( 065,374,{||STR0048},oPanel1,,oFont14N,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,024,008)//"Direita"

	oSay22	:= TSay():New( 079,012,{||STR0050},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)//"Elos"

	oSay23	:= TSay():New( 092,012,{||STR0051},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)//"Buchas"

	oSay24	:= TSay():New( 105,012,{||STR0052},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)//"Sapatas"

	oSay25	:= TSay():New( 118,012,{||STR0053},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,056,008)//"Rodas Guias Dianteira"
	oSay26	:= TSay():New( 131,012,{||STR0054},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,052,008)//"Rodas Guias Traseira"

	oSay27	:= TSay():New( 144,012,{||STR0055},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,052,008)//"Roletes Superior 1º"
	oSay28	:= TSay():New( 157,012,{||STR0056},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,048,008)//"Roletes Superior 2º"

	oSay29	:= TSay():New( 170,012,{||STR0057},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008)//"Roletes de Esteira 1º"
	oSay30   := TSay():New( 170,592,{||STR0058},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008)//"Flange"

	oSay31	:= TSay():New( 183,012,{||STR0059},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008)//"Roletes de Esteira 2º"
	oSay32	:= TSay():New( 183,592,{||STR0058},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008)//"Flange"

	oSay33	:= TSay():New( 196,012,{||STR0060},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008)//"Roletes de Esteira 3º"
	oSay34	:= TSay():New( 196,592,{||STR0058},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008)//"Flange"

	oSay35	:= TSay():New( 209,012,{||STR0061},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008)//"Roletes de Esteira 4º"
	oSay36	:= TSay():New( 209,592,{||STR0058},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008)//"Flange"

	oSay37	:= TSay():New( 222,012,{||STR0062},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008)//"Roletes de Esteira 5º"
	oSay38	:= TSay():New( 222,592,{||STR0058},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008)//"Flange"

	oSay39	:= TSay():New( 235,012,{||STR0063},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008)//"Roletes de Esteira 6º"
	oSay40	:= TSay():New( 235,592,{||STR0058},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008)//"Flange"

	oSay41	:= TSay():New( 248,012,{||STR0064},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008)//"Roletes de Esteira 7º"
	oSay42	:= TSay():New( 248,592,{||STR0058},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008)//"Flange"

	oSay43	:= TSay():New( 261,012,{||STR0065},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008)//"Roletes de Esteira 8º"
	oSay44	:= TSay():New( 261,592,{||STR0058},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008)//"Flange"

	oSay45	:= TSay():New( 274,012,{||STR0066},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008)//"Rodas Motrizes"

	oSay46	:= TSay():New( 294,012,{||STR0067},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008)//"Comentários:"

	oGet1  	:= TGet():New( 006,056,{|u| If(PCount()>0,cBem:=u,cBem)},oPanel1,060,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"","cBem",,,,.t.)
	oGet2 	:= TGet():New( 005,200,{|u| If(PCount()>0,cOrdem:=u,cOrdem)},oPanel1,060,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"","cOrdem",,,,.t.)

	oGet3	:= TGet():New( 020,056,{|u| If(PCount()>0,nLarg:=u,nLarg)},oPanel1,060,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"","nLarg",,,,.t.)
	oGet4	:= TGet():New( 020,200,{|u| If(PCount()>0,nSecs:=u,nSecs)},oPanel1,060,008,'@E 999'   ,{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"","nSecs",,,,.t.)

	oCBox1	:= TComboBox():New( 020,328,{|u| If(PCount()>0,cBox1:=u,cBox1)},{STR0099,STR0100},068,010,oPanel1,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,&(cWhen),,,,,cBox1 )//"Selada"###"Selada e Lubfificada"

	oGet5  	:= TGet():New( 034,056,{|u| If(PCount()>0,cEsq:=u,cEsq)},oPanel1,060,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"","cEsq",,,,.t.)
	oGet6  	:= TGet():New( 034,200,{|u| If(PCount()>0,cDir:=u,cDir)},oPanel1,060,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"","cDir",,,,.t.)
	oGet7  	:= TGet():New( 034,328,{|u| If(PCount()>0,(cTRB)->TV9_DTMED:=u,(cTRB)->TV9_DTMED)},oPanel1,060,008,'99/99/9999',{ || MNT691DMED()},CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| MNT691WhDt() },.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_DTMED",,,,.t.)

	//Elos
	oGet8	:= TGet():New( 077,092,{|u| If(PCount()>0,nEloEsq:=u,nEloEsq)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"","nEloEsq",,,,.t.)
	oGet9	:= TGet():New( 077,133,{|u| If(PCount()>0,nEloDir:=u,nEloDir)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"","nEloDir",,,,.t.)
	oGet10	:= TGet():New( 077,175,{|u| If(PCount()>0,cUMElo:=u,cUMElo)},oPanel1,024,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"SAH","cUMElo",,,,.t.)
	oGet11	:= TGet():New( 077,230,{|u| If(PCount()>0,(cTRB)->TV9_ELOESQ:=u,(cTRB)->TV9_ELOESQ)},oPanel1,024,008,'@E 999.99',{||f688PerDes(TV5->TV5_ELOESQ)},,,,,,.T.,"",,{||fWhenGet({"TV9_ELOESQ"})},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_ELOESQ",,,,.t.)
	oGet12	:= TGet():New( 077,274,{|u| If(PCount()>0,(cTRB)->TV9_ELODIR:=u,(cTRB)->TV9_ELODIR)},oPanel1,024,008,'@E 999.99',{||f688PerDes(TV5->TV5_ELODIR)},,,,,,.T.,"",,{||fWhenGet({"TV9_ELODIR"})},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_ELODIR",,,,.t.)
	oGet13	:= TGet():New( 077,330,{|u| If(PCount()>0,(cTRB)->TV9_ELOEDG:=u,(cTRB)->TV9_ELOEDG)},oPanel1,024,008,'@E 99.99',bVldGet,,,,,,.T.,"",,{||.F.},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_ELOEDG",,,,.t.)
	oGet14	:= TGet():New( 077,374,{|u| If(PCount()>0,(cTRB)->TV9_ELODDG:=u,(cTRB)->TV9_ELODDG)},oPanel1,024,008,'@E 99.99',bVldGet,,,,,,.T.,"",,{||.F.},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_ELODDG",,,,.t.)
	oGet15	:= tComboBox():New( 077,419,{|u| If(PCount()>0,(cTRB)->TV9_MEDELO:=u,(cTRB)->TV9_MEDELO)},StrTokArr(NGRETSX3BOX("TV9_MEDELO")+'; ',';'),050,008,oPanel1,,,,,,.T.,,,,{||fWhenGet({"TV9_ELOESQ","TV9_ELODIR"})},,,,,"(cTRB)->TV9_MEDELO")
	oMemo1	:= tMultiget():New(077,475,{|u| If(Pcount()>0,(cTRB)->TV9_OBSELO:=u,(cTRB)->TV9_OBSELO)},oPanel1,90,010,,,,,,.T.,,,{||fWhenGet({"TV9_ELOESQ","TV9_ELODIR"})})

	//Buchas
	oGet16	:= TGet():New( 090,092,{|u| If(PCount()>0,nBucEsq:=u,nBucEsq)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"","nBucEsq",,,,.t.)
	oGet17	:= TGet():New( 090,133,{|u| If(PCount()>0,nBucDir:=u,nBucDir)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"","nBucDir",,,,.t.)
	oGet18	:= TGet():New( 090,175,{|u| If(PCount()>0,cUMBuc:=u,cUMBuc)},oPanel1,024,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"SAH","cUMBuc",,,,.t.)
	oGet19	:= TGet():New( 090,230,{|u| If(PCount()>0,(cTRB)->TV9_BUCESQ:=u,(cTRB)->TV9_BUCESQ)},oPanel1,024,008,'@E 999.99',{||f688PerDes(TV5->TV5_BUCESQ)},,,,,,.T.,"",,{||fWhenGet({"TV9_BUCESQ"})},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_BUCESQ",,,,.t.)
	oGet20	:= TGet():New( 090,274,{|u| If(PCount()>0,(cTRB)->TV9_BUCDIR:=u,(cTRB)->TV9_BUCDIR)},oPanel1,024,008,'@E 999.99',{||f688PerDes(TV5->TV5_BUCDIR)},,,,,,.T.,"",,{||fWhenGet({"TV9_BUCDIR"})},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_BUCDIR",,,,.t.)
	oGet21	:= TGet():New( 090,330,{|u| If(PCount()>0,(cTRB)->TV9_BUCEDG:=u,(cTRB)->TV9_BUCEDG)},oPanel1,024,008,'@E 99.99',bVldGet,,,,,,.T.,"",,{||.F.},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_BUCEDG",,,,.t.)
	oGet22	:= TGet():New( 090,374,{|u| If(PCount()>0,(cTRB)->TV9_BUCDDG:=u,(cTRB)->TV9_BUCDDG)},oPanel1,024,008,'@E 99.99',bVldGet,,,,,,.T.,"",,{||.F.},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_BUCDDG",,,,.t.)
	oGet23	:= tComboBox():New( 090,419,{|u| If(PCount()>0,(cTRB)->TV9_MEDBUC:=u,(cTRB)->TV9_MEDBUC)},StrTokArr(NGRETSX3BOX("TV9_MEDBUC")+'; ',';'),050,008,oPanel1,,,,,,.T.,,,,{||fWhenGet({"TV9_BUCESQ","TV9_BUCDIR"})},,,,,"(cTRB)->TV9_MEDBUC")
	oMemo2	:= tMultiget():New(090,475,{|u| If(Pcount()>0,(cTRB)->TV9_OBSBUC:=u,(cTRB)->TV9_OBSBUC)},oPanel1,90,010,,,,,,.T.,,,{||fWhenGet({"TV9_BUCESQ","TV9_BUCDIR"})})

	//Sapatas
	oGet24	:= TGet():New( 103,092,{|u| If(PCount()>0,nSapEsq:=u,nSapEsq)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"","nSapEsq",,,,.t.)
	oGet25	:= TGet():New( 103,133,{|u| If(PCount()>0,nSapDir:=u,nSapDir)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"","nSapDir",,,,.t.)
	oGet26	:= TGet():New( 103,175,{|u| If(PCount()>0,cUMSap:=u,cUMSap)},oPanel1,024,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"SAH","cUMSap",,,,.t.)
	oGet27	:= TGet():New( 103,230,{|u| If(PCount()>0,(cTRB)->TV9_SAPESQ:=u,(cTRB)->TV9_SAPESQ)},oPanel1,024,008,'@E 999.99',{||f688PerDes(TV5->TV5_SAPESQ)},,,,,,.T.,"",,{||fWhenGet({"TV9_SAPESQ"})},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_SAPESQ",,,,.t.)
	oGet28	:= TGet():New( 103,274,{|u| If(PCount()>0,(cTRB)->TV9_SAPDIR:=u,(cTRB)->TV9_SAPDIR)},oPanel1,024,008,'@E 999.99',{||f688PerDes(TV5->TV5_SAPDIR)},,,,,,.T.,"",,{||fWhenGet({"TV9_SAPDIR"})},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_SAPDIR",,,,.t.)
	oGet29	:= TGet():New( 103,330,{|u| If(PCount()>0,(cTRB)->TV9_SAPEDG:=u,(cTRB)->TV9_SAPEDG)},oPanel1,024,008,'@E 99.99',bVldGet,,,,,,.T.,"",,{||.F.},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_SAPEDG",,,,.t.)
	oGet30	:= TGet():New( 103,374,{|u| If(PCount()>0,(cTRB)->TV9_SAPDDG:=u,(cTRB)->TV9_SAPDDG)},oPanel1,024,008,'@E 99.99',bVldGet,,,,,,.T.,"",,{||.F.},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_SAPDDG",,,,.t.)
	oGet31	:= tComboBox():New( 103,419,{|u| If(PCount()>0,(cTRB)->TV9_MEDSAP:=u,(cTRB)->TV9_MEDSAP)},StrTokArr(NGRETSX3BOX("TV9_MEDSAP")+'; ',';'),050,008,oPanel1,,,,,,.T.,,,,{||fWhenGet({"TV9_SAPESQ","TV9_SAPDIR"})},,,,,"(cTRB)->TV9_MEDSAP")
	oMemo3	:= tMultiget():New(103,475,{|u| If(Pcount()>0,(cTRB)->TV9_OBSSAP:=u,(cTRB)->TV9_OBSSAP)},oPanel1,90,010,,,,,,.T.,,,{||fWhenGet({"TV9_SAPESQ","TV9_SAPDIR"})})

	//Rodas guia dianteira
	oGet32	:= TGet():New( 116,092,{|u| If(PCount()>0,nRdDEsq:=u,nRdDEsq)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"","nRdDEsq",,,,.t.)
	oGet33	:= TGet():New( 116,133,{|u| If(PCount()>0,nRdDDir:=u,nRdDDir)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"","nRdDDir",,,,.t.)
	oGet34	:= TGet():New( 116,175,{|u| If(PCount()>0,cUMDia:=u,cUMDia)},oPanel1,024,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"SAH","cUMDia",,,,.t.)
	oGet35	:= TGet():New( 116,230,{|u| If(PCount()>0,(cTRB)->TV9_RDDESQ:=u,(cTRB)->TV9_RDDESQ)},oPanel1,024,008,'@E 999.99',{||f688PerDes(TV5->TV5_RDDESQ)},,,,,,.T.,"",,{||fWhenGet({"TV9_RDDESQ"})},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RDDESQ",,,,.t.)
	oGet36	:= TGet():New( 116,274,{|u| If(PCount()>0,(cTRB)->TV9_RDDDIR:=u,(cTRB)->TV9_RDDDIR)},oPanel1,024,008,'@E 999.99',{||f688PerDes(TV5->TV5_RDDDIR)},,,,,,.T.,"",,{||fWhenGet({"TV9_RDDDIR"})},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RDDDIR",,,,.t.)
	oGet37	:= TGet():New( 116,330,{|u| If(PCount()>0,(cTRB)->TV9_RDDEDG:=u,(cTRB)->TV9_RDDEDG)},oPanel1,024,008,'@E 99.99',bVldGet,,,,,,.T.,"",,{||.F.},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RDDEDG",,,,.t.)
	oGet38	:= TGet():New( 116,374,{|u| If(PCount()>0,(cTRB)->TV9_RDDDDG:=u,(cTRB)->TV9_RDDDDG)},oPanel1,024,008,'@E 99.99',bVldGet,,,,,,.T.,"",,{||.F.},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RDDDDG",,,,.t.)
	oGet39	:= tComboBox():New( 116,419,{|u| If(PCount()>0,(cTRB)->TV9_MEDRDD:=u,(cTRB)->TV9_MEDRDD)},StrTokArr(NGRETSX3BOX("TV9_MEDRDD")+'; ',';'),050,008,oPanel1,,,,,,.T.,,,,{||fWhenGet({"TV9_RDDESQ","TV9_RDDDIR"})},,,,,"(cTRB)->TV9_MEDRDD")
	oMemo4	:= tMultiget():New(116,475,{|u| If(Pcount()>0,(cTRB)->TV9_OBSRDD:=u,(cTRB)->TV9_OBSRDD)},oPanel1,90,010,,,,,,.T.,,,{||fWhenGet({"TV9_RDDESQ","TV9_RDDDIR"})})

	//Rodas guia traseira
	oGet40	:= TGet():New( 129,092,{|u| If(PCount()>0,nRdTEsq:=u,nRdTEsq)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"","nRdTEsq",,,,.t.)
	oGet41	:= TGet():New( 129,133,{|u| If(PCount()>0,nRdTDir:=u,nRdTDir)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"","nRdTDir",,,,.t.)
	oGet42	:= TGet():New( 129,175,{|u| If(PCount()>0,cUMTra:=u,cUMTra)},oPanel1,024,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"SAH","cUMTra",,,,.t.)
	oGet43	:= TGet():New( 129,230,{|u| If(PCount()>0,(cTRB)->TV9_RDTESQ:=u,(cTRB)->TV9_RDTESQ)},oPanel1,024,008,'@E 999.99',{||f688PerDes(TV5->TV5_RDTESQ)},,,,,,.T.,"",,{||fWhenGet({"TV9_RDTESQ"})},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RDTESQ",,,,.t.)
	oGet44	:= TGet():New( 129,274,{|u| If(PCount()>0,(cTRB)->TV9_RDTDIR:=u,(cTRB)->TV9_RDTDIR)},oPanel1,024,008,'@E 999.99',{||f688PerDes(TV5->TV5_RDTDIR)},,,,,,.T.,"",,{||fWhenGet({"TV9_RDTDIR"})},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RDTDIR",,,,.t.)
	oGet45	:= TGet():New( 129,330,{|u| If(PCount()>0,(cTRB)->TV9_RDTEDG:=u,(cTRB)->TV9_RDTEDG)},oPanel1,024,008,'@E 99.99',bVldGet,,,,,,.T.,"",,{||.F.},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RDTEDG",,,,.t.)
	oGet46	:= TGet():New( 129,374,{|u| If(PCount()>0,(cTRB)->TV9_RDTDDG:=u,(cTRB)->TV9_RDTDDG)},oPanel1,024,008,'@E 99.99',bVldGet,,,,,,.T.,"",,{||.F.},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RDTDDG",,,,.t.)
	oGet47	:= tComboBox():New( 129,419,{|u| If(PCount()>0,(cTRB)->TV9_MEDRDT:=u,(cTRB)->TV9_MEDRDT)},StrTokArr(NGRETSX3BOX("TV9_MEDRDT")+'; ',';'),050,008,oPanel1,,,,,,.T.,,,,{||fWhenGet({"TV9_RDTESQ","TV9_RDTDIR"})},,,,,"(cTRB)->TV9_MEDRDT")
	oMemo5	:= tMultiget():New(129,475,{|u| If(Pcount()>0,(cTRB)->TV9_OBSRDT:=u,(cTRB)->TV9_OBSRDT)},oPanel1,90,010,,,,,,.T.,,,{||fWhenGet({"TV9_RDTESQ","TV9_RDTDIR"})})

	//Roletes superior 1o
	oGet48	:= TGet():New( 142,092,{|u| If(PCount()>0,nRS1Esq:=u,nRS1Esq)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"","nRS1Esq",,,,.t.)
	oGet49	:= TGet():New( 142,133,{|u| If(PCount()>0,nRS1Dir:=u,nRS1Dir)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"","nRS1Dir",,,,.t.)
	oGet50	:= TGet():New( 142,175,{|u| If(PCount()>0,cUMRS1:=u,cUMRS1)},oPanel1,024,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"SAH","cUMRS1",,,,.t.)
	oGet51	:= TGet():New( 142,230,{|u| If(PCount()>0,(cTRB)->TV9_RS1ESQ:=u,(cTRB)->TV9_RS1ESQ)},oPanel1,024,008,'@E 999.99',{||f688PerDes(TV5->TV5_RS1ESQ)},,,,,,.T.,"",,{||fWhenGet({"TV9_RS1ESQ"})},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RS1ESQ",,,,.t.)
	oGet52	:= TGet():New( 142,274,{|u| If(PCount()>0,(cTRB)->TV9_RS1DIR:=u,(cTRB)->TV9_RS1DIR)},oPanel1,024,008,'@E 999.99',{||f688PerDes(TV5->TV5_RS1DIR)},,,,,,.T.,"",,{||fWhenGet({"TV9_RS1DIR"})},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RS1DIR",,,,.t.)
	oGet53	:= TGet():New( 142,330,{|u| If(PCount()>0,(cTRB)->TV9_RS1EDG:=u,(cTRB)->TV9_RS1EDG)},oPanel1,024,008,'@E 99.99',bVldGet,,,,,,.T.,"",,{||.F.},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RS1EDG",,,,.t.)
	oGet54	:= TGet():New( 142,374,{|u| If(PCount()>0,(cTRB)->TV9_RS1DDG:=u,(cTRB)->TV9_RS1DDG)},oPanel1,024,008,'@E 99.99',bVldGet,,,,,,.T.,"",,{||.F.},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RS1DDG",,,,.t.)
	oGet55	:= tComboBox():New( 142,419,{|u| If(PCount()>0,(cTRB)->TV9_MEDRS1:=u,(cTRB)->TV9_MEDRS1)},StrTokArr(NGRETSX3BOX("TV9_MEDRS1")+'; ',';'),050,008,oPanel1,,,,,,.T.,,,,{||fWhenGet({"TV9_RS1ESQ","TV9_RS1DIR"})},,,,,"(cTRB)->TV9_MEDRS1")
	oMemo6	:= tMultiget():New(142,475,{|u| If(Pcount()>0,(cTRB)->TV9_OBSRS1:=u,(cTRB)->TV9_OBSRS1)},oPanel1,90,010,,,,,,.T.,,,{||fWhenGet({"TV9_RS1ESQ","TV9_RS1DIR"})})

	//Roletes superior 2o
	oGet56	:= TGet():New( 155,092,{|u| If(PCount()>0,nRS2Esq:=u,nRS2Esq)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"","nRS2Esq",,,,.t.)
	oGet57	:= TGet():New( 155,133,{|u| If(PCount()>0,nRS2Dir:=u,nRS2Dir)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"","nRS2Dir",,,,.t.)
	oGet58	:= TGet():New( 155,175,{|u| If(PCount()>0,cUMRS2:=u,cUMRS2)},oPanel1,024,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"SAH","cUMRS2",,,,.t.)
	oGet59	:= TGet():New( 155,230,{|u| If(PCount()>0,(cTRB)->TV9_RS2ESQ:=u,(cTRB)->TV9_RS2ESQ)},oPanel1,024,008,'@E 999.99',{||f688PerDes(TV5->TV5_RS2ESQ)},,,,,,.T.,"",,{||fWhenGet({"TV9_RS2ESQ"})},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RS2ESQ",,,,.t.)
	oGet60	:= TGet():New( 155,274,{|u| If(PCount()>0,(cTRB)->TV9_RS2DIR:=u,(cTRB)->TV9_RS2DIR)},oPanel1,024,008,'@E 999.99',{||f688PerDes(TV5->TV5_RS2DIR)},,,,,,.T.,"",,{||fWhenGet({"TV9_RS2DIR"})},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RS2DIR",,,,.t.)
	oGet61	:= TGet():New( 155,330,{|u| If(PCount()>0,(cTRB)->TV9_RS2EDG:=u,(cTRB)->TV9_RS2EDG)},oPanel1,024,008,'@E 99.99',bVldGet,,,,,,.T.,"",,{||.F.},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RS2EDG",,,,.t.)
	oGet62	:= TGet():New( 155,374,{|u| If(PCount()>0,(cTRB)->TV9_RS2DDG:=u,(cTRB)->TV9_RS2DDG)},oPanel1,024,008,'@E 99.99',bVldGet,,,,,,.T.,"",,{||.F.},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RS2DDG",,,,.t.)
	oGet63	:= tComboBox():New( 155,419,{|u| If(PCount()>0,(cTRB)->TV9_MEDRS2:=u,(cTRB)->TV9_MEDRS2)},StrTokArr(NGRETSX3BOX("TV9_MEDRS2")+'; ',';'),050,008,oPanel1,,,,,,.T.,,,,{||fWhenGet({"TV9_RS2ESQ","TV9_RS2DIR"})},,,,,"(cTRB)->TV9_MEDRS2")
	oMemo7	:= tMultiget():New(155,475,{|u| If(Pcount()>0,(cTRB)->TV9_OBSRS2:=u,(cTRB)->TV9_OBSRS2)},oPanel1,90,010,,,,,,.T.,,,{||fWhenGet({"TV9_RS2ESQ","TV9_RS2DIR"})})

	//Roletes de esteira 1o
	oGet64	:= TGet():New( 168,092,{|u| If(PCount()>0,nRE1Esq:=u,nRE1Esq)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"","nRE1Esq",,,,.t.)
	oGet65	:= TGet():New( 168,133,{|u| If(PCount()>0,nRE1Dir:=u,nRE1Dir)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"","nRE1Dir",,,,.t.)
	oGet66	:= TGet():New( 168,175,{|u| If(PCount()>0,cUMRE1:=u,cUMRE1)},oPanel1,024,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"SAH","cUMRE1",,,,.t.)
	oGet67	:= TGet():New( 168,230,{|u| If(PCount()>0,(cTRB)->TV9_RE1ESQ:=u,(cTRB)->TV9_RE1ESQ)},oPanel1,024,008,'@E 999.99',{||f688PerDes(TV5->TV5_RE1ESQ)},,,,,,.T.,"",,{||fWhenGet({"TV9_RE1ESQ"})},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RE1ESQ",,,,.t.)
	oGet68	:= TGet():New( 168,274,{|u| If(PCount()>0,(cTRB)->TV9_RE1DIR:=u,(cTRB)->TV9_RE1DIR)},oPanel1,024,008,'@E 999.99',{||f688PerDes(TV5->TV5_RE1DIR)},,,,,,.T.,"",,{||fWhenGet({"TV9_RE1DIR"})},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RE1DIR",,,,.t.)
	oGet69	:= TGet():New( 168,330,{|u| If(PCount()>0,(cTRB)->TV9_RE1EDG:=u,(cTRB)->TV9_RE1EDG)},oPanel1,024,008,'@E 99.99',bVldGet,,,,,,.T.,"",,{||.F.},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RE1EDG",,,,.t.)
	oGet70	:= TGet():New( 168,374,{|u| If(PCount()>0,(cTRB)->TV9_RE1DDG:=u,(cTRB)->TV9_RE1DDG)},oPanel1,024,008,'@E 99.99',bVldGet,,,,,,.T.,"",,{||.F.},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RE1DDG",,,,.t.)
	oGet71	:= tComboBox():New( 168,419,{|u| If(PCount()>0,(cTRB)->TV9_MEDRE1:=u,(cTRB)->TV9_MEDRE1)},StrTokArr(NGRETSX3BOX("TV9_MEDRE1")+'; ',';'),050,008,oPanel1,,,,,,.T.,,,,{||fWhenGet({"TV9_RE1ESQ","TV9_RE1DIR"})},,,,,"(cTRB)->TV9_MEDRE1")
	oMemo8	:= tMultiget():New(168,475,{|u| If(Pcount()>0,(cTRB)->TV9_OBSRE1:=u,(cTRB)->TV9_OBSRE1)},oPanel1,90,010,,,,,,.T.,,,{||fWhenGet({"TV9_RE1ESQ","TV9_RE1DIR"})})
	oCBox2	:= TComboBox():New( 168,592,{|u| If(PCount()>0,(cTRB)->FLARE1:=u,(cTRB)->FLARE1)},aFlange,032,010,oPanel1,,,,,,.T.,,"",,{||fWhenGet({"TV9_RE1ESQ","TV9_RE1DIR"})},,,,,(cTRB)->FLARE1 )
	oCBox2:bHelp := { || ShowHelpCpo( 'TV9_FLARE1',	{ "Flange RE1: 1=Simples; 2=Dupla." }, 2,{}, 2 ) } //"Flange RE1: 1=Simples; 2=Dupla."

	//Roletes de esteira 2o
	oGet72	:= TGet():New( 181,092,{|u| If(PCount()>0,nRE2Esq:=u,nRE2Esq)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"","nRE2Esq",,,,.t.)
	oGet73	:= TGet():New( 181,133,{|u| If(PCount()>0,nRE2Dir:=u,nRE2Dir)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"","nRE2Dir",,,,.t.)
	oGet74	:= TGet():New( 181,175,{|u| If(PCount()>0,cUMRE2:=u,cUMRE2)},oPanel1,024,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"SAH","cUMRE2",,,,.t.)
	oGet75	:= TGet():New( 181,230,{|u| If(PCount()>0,(cTRB)->TV9_RE2ESQ:=u,(cTRB)->TV9_RE2ESQ)},oPanel1,024,008,'@E 999.99',{||f688PerDes(TV5->TV5_RE2ESQ)},,,,,,.T.,"",,{||fWhenGet({"TV9_RE2ESQ"})},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RE2ESQ",,,,.t.)
	oGet76	:= TGet():New( 181,274,{|u| If(PCount()>0,(cTRB)->TV9_RE2DIR:=u,(cTRB)->TV9_RE2DIR)},oPanel1,024,008,'@E 999.99',{||f688PerDes(TV5->TV5_RE2DIR)},,,,,,.T.,"",,{||fWhenGet({"TV9_RE2DIR"})},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RE2DIR",,,,.t.)
	oGet77	:= TGet():New( 181,330,{|u| If(PCount()>0,(cTRB)->TV9_RE2EDG:=u,(cTRB)->TV9_RE2EDG)},oPanel1,024,008,'@E 99.99',bVldGet,,,,,,.T.,"",,{||.F.},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RE2EDG",,,,.t.)
	oGet78 	:= TGet():New( 181,374,{|u| If(PCount()>0,(cTRB)->TV9_RE2DDG:=u,(cTRB)->TV9_RE2DDG)},oPanel1,024,008,'@E 99.99',bVldGet,,,,,,.T.,"",,{||.F.},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RE2DDG",,,,.t.)
	oGet79	:= tComboBox():New( 181,419,{|u| If(PCount()>0,(cTRB)->TV9_MEDRE2:=u,(cTRB)->TV9_MEDRE2)},StrTokArr(NGRETSX3BOX("TV9_MEDRE2")+'; ',';'),050,008,oPanel1,,,,,,.T.,,,,{||fWhenGet({"TV9_RE2ESQ","TV9_RE2DIR"})},,,,,"(cTRB)->TV9_MEDRE2")
	oMemo9	:= tMultiget():New(181,475,{|u| If(Pcount()>0,(cTRB)->TV9_OBSRE2:=u,(cTRB)->TV9_OBSRE2)},oPanel1,90,010,,,,,,.T.,,,{||fWhenGet({"TV9_RE2ESQ","TV9_RE2DIR"})})
	oCBox3	:= TComboBox():New( 181,592,{|u| If(PCount()>0,(cTRB)->FLARE2:=u,(cTRB)->FLARE2)},aFlange,032,010,oPanel1,,,,,,.T.,,"",,{||fWhenGet({"TV9_RE2ESQ","TV9_RE2DIR"})},,,,,(cTRB)->FLARE2)
	oCBox3:bHelp := { || ShowHelpCpo( 'TV9_FLARE2',	{ "Flange RE2: 1=Simples; 2=Dupla." }, 2,{}, 2 ) } //"Flange RE2: 1=Simples; 2=Dupla."

	//Roletes de esteira 3o
	oGet80	:= TGet():New( 194,092,{|u| If(PCount()>0,nRE3Esq:=u,nRE3Esq)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"","nRE3Esq",,,,.t.)
	oGet81	:= TGet():New( 194,133,{|u| If(PCount()>0,nRE3Dir:=u,nRE3Dir)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"","nRE3Dir",,,,.t.)
	oGet82	:= TGet():New( 194,175,{|u| If(PCount()>0,cUMRE3:=u,cUMRE3)},oPanel1,024,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"SAH","cUMRE3",,,,.t.)
	oGet83	:= TGet():New( 194,230,{|u| If(PCount()>0,(cTRB)->TV9_RE3ESQ:=u,(cTRB)->TV9_RE3ESQ)},oPanel1,024,008,'@E 999.99',{||f688PerDes(TV5->TV5_RE3ESQ)},,,,,,.T.,"",,{||fWhenGet({"TV9_RE3ESQ"})},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RE3ESQ",,,,.t.)
	oGet84	:= TGet():New( 194,274,{|u| If(PCount()>0,(cTRB)->TV9_RE3DIR:=u,(cTRB)->TV9_RE3DIR)},oPanel1,024,008,'@E 999.99',{||f688PerDes(TV5->TV5_RE3DIR)},,,,,,.T.,"",,{||fWhenGet({"TV9_RE3DIR"})},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RE3DIR",,,,.t.)
	oGet85 	:= TGet():New( 194,330,{|u| If(PCount()>0,(cTRB)->TV9_RE3EDG:=u,(cTRB)->TV9_RE3EDG)},oPanel1,024,008,'@E 99.99',bVldGet,,,,,,.T.,"",,{||.F.},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RE3EDG",,,,.t.)
	oGet86 	:= TGet():New( 194,374,{|u| If(PCount()>0,(cTRB)->TV9_RE3DDG:=u,(cTRB)->TV9_RE3DDG)},oPanel1,024,008,'@E 99.99',bVldGet,,,,,,.T.,"",,{||.F.},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RE3DDG",,,,.t.)
	oGet87 	:= tComboBox():New( 194,419,{|u| If(PCount()>0,(cTRB)->TV9_MEDRE3:=u,(cTRB)->TV9_MEDRE3)},StrTokArr(NGRETSX3BOX("TV9_MEDRE3")+'; ',';'),050,008,oPanel1,,,,,,.T.,,,,{||fWhenGet({"TV9_RE3ESQ","TV9_RE3DIR"})},,,,,"(cTRB)->TV9_MEDRE3")
	oMemo10	:= tMultiget():New( 194,475,{|u| If(Pcount()>0,(cTRB)->TV9_OBSRE3:=u,(cTRB)->TV9_OBSRE3)},oPanel1,90,010,,,,,,.T.,,,{||fWhenGet({"TV9_RE3ESQ","TV9_RE3DIR"})})
	oCBox4	:= TComboBox():New( 194,592,{|u| If(PCount()>0,(cTRB)->FLARE3:=u,(cTRB)->FLARE3)},aFlange,032,010,oPanel1,,,,,,.T.,,"",,{||fWhenGet({"TV9_RE3ESQ","TV9_RE3DIR"})},,,,,(cTRB)->FLARE3)
	oCBox4:bHelp := { || ShowHelpCpo( 'TV9_FLARE3',	{ "Flange RE3: 1=Simples; 2=Dupla." }, 2,{}, 2 ) } //"Flange RE3: 1=Simples; 2=Dupla."

	//Roletes de esteira 4o
	oGet88	:= TGet():New( 207,092,{|u| If(PCount()>0,nRE4Esq:=u,nRE4Esq)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"","nRE4Esq",,,,.t.)
	oGet89	:= TGet():New( 207,133,{|u| If(PCount()>0,nRE4Dir:=u,nRE4Dir)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"","nRE4Dir",,,,.t.)
	oGet90	:= TGet():New( 207,175,{|u| If(PCount()>0,cUMRE4:=u,cUMRE4)},oPanel1,024,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"SAH","cUMRE4",,,,.t.)
	oGet91	:= TGet():New( 207,230,{|u| If(PCount()>0,(cTRB)->TV9_RE4ESQ:=u,(cTRB)->TV9_RE4ESQ)},oPanel1,024,008,'@E 999.99',{||f688PerDes(TV5->TV5_RE4ESQ)},,,,,,.T.,"",,{||fWhenGet({"TV9_RE4ESQ"})},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RE4ESQ",,,,.t.)
	oGet92	:= TGet():New( 207,274,{|u| If(PCount()>0,(cTRB)->TV9_RE4DIR:=u,(cTRB)->TV9_RE4DIR)},oPanel1,024,008,'@E 999.99',{||f688PerDes(TV5->TV5_RE4DIR)},,,,,,.T.,"",,{||fWhenGet({"TV9_RE4DIR"})},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RE4DIR",,,,.t.)
	oGet93 	:= TGet():New( 207,330,{|u| If(PCount()>0,(cTRB)->TV9_RE4EDG:=u,(cTRB)->TV9_RE4EDG)},oPanel1,024,008,'@E 99.99',bVldGet,,,,,,.T.,"",,{||.F.},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RE4EDG",,,,.t.)
	oGet94 	:= TGet():New( 207,374,{|u| If(PCount()>0,(cTRB)->TV9_RE4DDG:=u,(cTRB)->TV9_RE4DDG)},oPanel1,024,008,'@E 99.99',bVldGet,,,,,,.T.,"",,{||.F.},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RE4DDG",,,,.t.)
	oGet95  := tComboBox():New( 207,419,{|u| If(PCount()>0,(cTRB)->TV9_MEDRE4:=u,(cTRB)->TV9_MEDRE4)},StrTokArr(NGRETSX3BOX("TV9_MEDRE4")+'; ',';'),050,008,oPanel1,,,,,,.T.,,,,{||fWhenGet({"TV9_RE4ESQ","TV9_RE4DIR"})},,,,,"(cTRB)->TV9_MEDRE4")
	oMemo11 := tMultiget():New( 207,475,{|u| If(Pcount()>0,(cTRB)->TV9_OBSRE4:=u,(cTRB)->TV9_OBSRE4)},oPanel1,90,010,,,,,,.T.,,,{||fWhenGet({"TV9_RE4ESQ","TV9_RE4DIR"})})
	oCBox5  := TComboBox():New( 207,592,{|u| If(PCount()>0,(cTRB)->FLARE4:=u,(cTRB)->FLARE4)},aFlange,032,010,oPanel1,,,,,,.T.,,"",,{||fWhenGet({"TV9_RE4ESQ","TV9_RE4DIR"})},,,,,(cTRB)->FLARE4)
	oCBox5:bHelp := { || ShowHelpCpo( 'TV9_FLARE4',	{ "Flange RE4: 1=Simples; 2=Dupla." }, 2,{}, 2 ) } //"Flange RE4: 1=Simples; 2=Dupla."

	//Roletes de esteira 5o
	oGet96	:= TGet():New( 220,092,{|u| If(PCount()>0,nRE5Esq:=u,nRE5Esq)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"","nRE5Esq",,,,.t.)
	oGet97	:= TGet():New( 220,133,{|u| If(PCount()>0,nRE5Dir:=u,nRE5Dir)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"","nRE5Dir",,,,.t.)
	oGet98	:= TGet():New( 220,175,{|u| If(PCount()>0,cUMRE5:=u,cUMRE5)},oPanel1,024,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"SAH","cUMRE5",,,,.t.)
	oGet99	:= TGet():New( 220,230,{|u| If(PCount()>0,(cTRB)->TV9_RE5ESQ:=u,(cTRB)->TV9_RE5ESQ)},oPanel1,024,008,'@E 999.99',{||f688PerDes(TV5->TV5_RE5ESQ)},,,,,,.T.,"",,{||fWhenGet({"TV9_RE5ESQ"})},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RE5ESQ",,,,.t.)
	oGet100  := TGet():New( 220,274,{|u| If(PCount()>0,(cTRB)->TV9_RE5DIR:=u,(cTRB)->TV9_RE5DIR)},oPanel1,024,008,'@E 999.99',{||f688PerDes(TV5->TV5_RE5DIR)},,,,,,.T.,"",,{||fWhenGet({"TV9_RE5DIR"})},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RE5DIR",,,,.t.)
	oGet101	:= TGet():New( 220,330,{|u| If(PCount()>0,(cTRB)->TV9_RE5EDG:=u,(cTRB)->TV9_RE5EDG)},oPanel1,024,008,'@E 99.99',bVldGet,,,,,,.T.,"",,{||.F.},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RE5EDG",,,,.t.)
	oGet102	:= TGet():New( 220,374,{|u| If(PCount()>0,(cTRB)->TV9_RE5DDG:=u,(cTRB)->TV9_RE5DDG)},oPanel1,024,008,'@E 99.99',bVldGet,,,,,,.T.,"",,{||.F.},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RE5DDG",,,,.t.)
	oGet103	:= tComboBox():New( 220,419,{|u| If(PCount()>0,(cTRB)->TV9_MEDRE5:=u,(cTRB)->TV9_MEDRE5)},StrTokArr(NGRETSX3BOX("TV9_MEDRE5")+'; ',';'),050,008,oPanel1,,,,,,.T.,,,,{||fWhenGet({"TV9_RE5ESQ","TV9_RE5DIR"})},,,,,"(cTRB)->TV9_MEDRE5")
	oMemo12	:= tMultiget():New( 220,475,{|u| If(Pcount()>0,(cTRB)->TV9_OBSRE5:=u,(cTRB)->TV9_OBSRE5)},oPanel1,90,010,,,,,,.T.,,,{||fWhenGet({"TV9_RE5ESQ","TV9_RE5DIR"})})
	oCBox6	:= TComboBox():New( 220,592,{|u| If(PCount()>0,(cTRB)->FLARE5:=u,(cTRB)->FLARE5)},aFlange,032,010,oPanel1,,,,,,.T.,,"",,{||fWhenGet({"TV9_RE5ESQ","TV9_RE5DIR"})},,,,,(cTRB)->FLARE5)
	oCBox6:bHelp := { || ShowHelpCpo( 'TV9_FLARE5',	{ "Flange RE5: 1=Simples; 2=Dupla." }, 2,{}, 2 ) } //"Flange RE5: 1=Simples; 2=Dupla."

	//Roletes de esteira 6o
	oGet104	:= TGet():New( 233,092,{|u| If(PCount()>0,nRE6Esq:=u,nRE6Esq)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"","nRE6Esq",,,,.t.)
	oGet105	:= TGet():New( 233,133,{|u| If(PCount()>0,nRE6Dir:=u,nRE6Dir)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"","nRE6Dir",,,,.t.)
	oGet106	:= TGet():New( 233,175,{|u| If(PCount()>0,cUMRE6:=u,cUMRE6)},oPanel1,024,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"SAH","cUMRE6",,,,.t.)
	oGet107	:= TGet():New( 233,230,{|u| If(PCount()>0,(cTRB)->TV9_RE6ESQ:=u,(cTRB)->TV9_RE6ESQ)},oPanel1,024,008,'@E 999.99',{||f688PerDes(TV5->TV5_RE6ESQ)},,,,,,.T.,"",,{||fWhenGet({"TV9_RE6ESQ"})},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RE6ESQ",,,,.t.)
	oGet108	:= TGet():New( 233,274,{|u| If(PCount()>0,(cTRB)->TV9_RE6DIR:=u,(cTRB)->TV9_RE6DIR)},oPanel1,024,008,'@E 999.99',{||f688PerDes(TV5->TV5_RE6DIR)},,,,,,.T.,"",,{||fWhenGet({"TV9_RE6ESQ"})},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RE6DIR",,,,.t.)
	oGet109	:= TGet():New( 233,330,{|u| If(PCount()>0,(cTRB)->TV9_RE6EDG:=u,(cTRB)->TV9_RE6EDG)},oPanel1,024,008,'@E 99.99',bVldGet,,,,,,.T.,"",,{||.F.},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RE6EDG",,,,.t.)
	oGet110	:= TGet():New( 233,374,{|u| If(PCount()>0,(cTRB)->TV9_RE6DDG:=u,(cTRB)->TV9_RE6DDG)},oPanel1,024,008,'@E 99.99',bVldGet,,,,,,.T.,"",,{||.F.},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RE6DDG",,,,.t.)
	oGet111	:= tComboBox():New( 233,419,{|u| If(PCount()>0,(cTRB)->TV9_MEDRE6:=u,(cTRB)->TV9_MEDRE6)},StrTokArr(NGRETSX3BOX("TV9_MEDRE6")+'; ',';'),050,008,oPanel1,,,,,,.T.,,,,{||fWhenGet({"TV9_RE6ESQ","TV9_RE6ESQ"})},,,,,"(cTRB)->TV9_MEDRE6")
	oMemo13	:= tMultiget():New(233,475,{|u| If(Pcount()>0,(cTRB)->TV9_OBSRE6:=u,(cTRB)->TV9_OBSRE6)},oPanel1,90,010,,,,,,.T.,,,{||fWhenGet({"TV9_RE6ESQ","TV9_RE6ESQ"})})
	oCBox7	:= TComboBox():New( 233,592,{|u| If(PCount()>0,(cTRB)->FLARE6:=u,(cTRB)->FLARE6)},aFlange,032,010,oPanel1,,,,,,.T.,,"",,{||fWhenGet({"TV9_RE6ESQ","TV9_RE6ESQ"})},,,,,(cTRB)->FLARE6)
	oCBox7:bHelp := { || ShowHelpCpo( 'TV9_FLARE6',	{ "Flange RE6: 1=Simples; 2=Dupla." }, 2,{}, 2 ) } //"Flange RE6: 1=Simples; 2=Dupla."

	//Roletes de esteira 7o
	oGet112	:= TGet():New( 246,092,{|u| If(PCount()>0,nRE7Esq:=u,nRE7Esq)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"","nRE7Esq",,,,.t.)
	oGet113	:= TGet():New( 246,133,{|u| If(PCount()>0,nRE7Dir:=u,nRE7Dir)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"","nRE7Dir",,,,.t.)
	oGet114	:= TGet():New( 246,175,{|u| If(PCount()>0,cUMRE7:=u,cUMRE7)},oPanel1,024,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"SAH","cUMRE7",,,,.t.)
	oGet115	:= TGet():New( 246,230,{|u| If(PCount()>0,(cTRB)->TV9_RE7ESQ:=u,(cTRB)->TV9_RE7ESQ)},oPanel1,024,008,'@E 999.99',{||f688PerDes(TV5->TV5_RE7ESQ)},,,,,,.T.,"",,{||fWhenGet({"TV9_RE7ESQ"})},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RE7ESQ",,,,.t.)
	oGet116	:= TGet():New( 246,274,{|u| If(PCount()>0,(cTRB)->TV9_RE7DIR:=u,(cTRB)->TV9_RE7DIR)},oPanel1,024,008,'@E 999.99',{||f688PerDes(TV5->TV5_RE7DIR)},,,,,,.T.,"",,{||fWhenGet({"TV9_RE7DIR"})},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RE7DIR",,,,.t.)
	oGet117	:= TGet():New( 246,330,{|u| If(PCount()>0,(cTRB)->TV9_RE7EDG:=u,(cTRB)->TV9_RE7EDG)},oPanel1,024,008,'@E 99.99',bVldGet,,,,,,.T.,"",,{||.F.},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RE7EDG",,,,.t.)
	oGet118	:= TGet():New( 246,374,{|u| If(PCount()>0,(cTRB)->TV9_RE7DDG:=u,(cTRB)->TV9_RE7DDG)},oPanel1,024,008,'@E 99.99',bVldGet,,,,,,.T.,"",,{||.F.},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RE7DDG",,,,.t.)
	oGet119	:= tComboBox():New( 246,419,{|u| If(PCount()>0,(cTRB)->TV9_MEDRE7:=u,(cTRB)->TV9_MEDRE7)},StrTokArr(NGRETSX3BOX("TV9_MEDRE7")+'; ',';'),050,008,oPanel1,,,,,,.T.,,,,{||fWhenGet({"TV9_RE7ESQ","TV9_RE7DIR"})},,,,,"(cTRB)->TV9_MEDRE7")
	oMemo14	:= tMultiget():New( 246,475,{|u| If(Pcount()>0,(cTRB)->TV9_OBSRE7:=u,(cTRB)->TV9_OBSRE7)},oPanel1,90,010,,,,,,.T.,,,{||fWhenGet({"TV9_RE7ESQ","TV9_RE7DIR"})})
	oCBox8	:= TComboBox():New( 246,592,{|u| If(PCount()>0,(cTRB)->FLARE7:=u,(cTRB)->FLARE7)},aFlange,032,010,oPanel1,,,,,,.T.,,"",,{||fWhenGet({"TV9_RE7ESQ","TV9_RE7DIR"})},,,,,(cTRB)->FLARE7)
	oCBox8:bHelp := { || ShowHelpCpo( 'TV9_FLARE7',	{ "Flange RE7: 1=Simples; 2=Dupla." }, 2,{}, 2 ) } //"Flange RE7: 1=Simples; 2=Dupla."

	//Roletes de esteira 8o
	oGet120	:= TGet():New( 259,092,{|u| If(PCount()>0,nRE8Esq:=u,nRE8Esq)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"","nRE8Esq",,,,.t.)
	oGet121	:= TGet():New( 259,133,{|u| If(PCount()>0,nRE8Dir:=u,nRE8Dir)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"","nRE8Dir",,,,.t.)
	oGet122	:= TGet():New( 259,175,{|u| If(PCount()>0,cUMRE8:=u,cUMRE8)},oPanel1,024,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"SAH","cUMRE8",,,,.t.)
	oGet123	:= TGet():New( 259,230,{|u| If(PCount()>0,(cTRB)->TV9_RE8ESQ:=u,(cTRB)->TV9_RE8ESQ)},oPanel1,024,008,'@E 999.99',{||f688PerDes(TV5->TV5_RE8ESQ)},,,,,,.T.,"",,{||fWhenGet({"TV9_RE8ESQ"})},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RE8ESQ",,,,.t.)
	oGet124	:= TGet():New( 259,274,{|u| If(PCount()>0,(cTRB)->TV9_RE8DIR:=u,(cTRB)->TV9_RE8DIR)},oPanel1,024,008,'@E 999.99',{||f688PerDes(TV5->TV5_RE8DIR)},,,,,,.T.,"",,{||fWhenGet({"TV9_RE8DIR"})},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RE8DIR",,,,.t.)
	oGet125	:= TGet():New( 259,330,{|u| If(PCount()>0,(cTRB)->TV9_RE8EDG:=u,(cTRB)->TV9_RE8EDG)},oPanel1,024,008,'@E 99.99',bVldGet,,,,,,.T.,"",,{||.F.},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RE8EDG",,,,.t.)
	oGet126	:= TGet():New( 259,374,{|u| If(PCount()>0,(cTRB)->TV9_RE8DDG:=u,(cTRB)->TV9_RE8DDG)},oPanel1,024,008,'@E 99.99',bVldGet,,,,,,.T.,"",,{||.F.},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RE8DDG",,,,.t.)
	oGet127	:= tComboBox():New( 259,419,{|u| If(PCount()>0,(cTRB)->TV9_MEDRE8:=u,(cTRB)->TV9_MEDRE8)},StrTokArr(NGRETSX3BOX("TV9_MEDRE8")+'; ',';'),050,008,oPanel1,,,,,,.T.,,,,{||fWhenGet({"TV9_RE8ESQ","TV9_RE8DIR"})},,,,,"(cTRB)->TV9_MEDRE8")
	oMemo15	:= tMultiget():New( 259,475,{|u| If(Pcount()>0,(cTRB)->TV9_OBSRE8:=u,(cTRB)->TV9_OBSRE8)},oPanel1,90,010,,,,,,.T.,,,{||fWhenGet({"TV9_RE8ESQ","TV9_RE8DIR"})})
	oCBox9	:= TComboBox():New( 259,592,{|u| If(PCount()>0,(cTRB)->FLARE8:=u,(cTRB)->FLARE8)},aFlange,032,010,oPanel1,,,,,,.T.,,"",,{||fWhenGet({"TV9_RE8ESQ","TV9_RE8DIR"})},,,,,(cTRB)->FLARE8)
	oCBox9:bHelp := { || ShowHelpCpo( 'TV9_FLARE8',	{ "Flange RE8: 1=Simples; 2=Dupla." }, 2,{}, 2 ) } //"Flange RE8: 1=Simples; 2=Dupla."
	//Rodas Motrizes
	oGet128	:= TGet():New( 272,092,{|u| If(PCount()>0,nRdMEsq:=u,nRdMEsq)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"","nRdMEsq",,,,.t.)
	oGet129	:= TGet():New( 272,133,{|u| If(PCount()>0,nRdMDir:=u,nRdMDir)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"","nRdMDir",,,,.t.)
	oGet130	:= TGet():New( 272,175,{|u| If(PCount()>0,cUMRdM:=u,cUMRdM)},oPanel1,024,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cWhen),.F.,.F.,,.F.,.F.,"SAH","cUMRdM",,,,.t.)
	oGet131	:= TGet():New( 272,230,{|u| If(PCount()>0,(cTRB)->TV9_RDMESQ:=u,(cTRB)->TV9_RDMESQ)},oPanel1,024,008,'@E 999.99',{||f688PerDes(TV5->TV5_RDMESQ)},,,,,,.T.,"",,{||fWhenGet({"TV9_RDMESQ"})},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RDMESQ",,,,.t.)
	oGet132	:= TGet():New( 272,274,{|u| If(PCount()>0,(cTRB)->TV9_RDMDIR:=u,(cTRB)->TV9_RDMDIR)},oPanel1,024,008,'@E 999.99',{||f688PerDes(TV5->TV5_RDMDIR)},,,,,,.T.,"",,{||fWhenGet({"TV9_RDMDIR"})},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RDMDIR",,,,.t.)
	oGet133	:= TGet():New( 272,330,{|u| If(PCount()>0,(cTRB)->TV9_RDMEDG:=u,(cTRB)->TV9_RDMEDG)},oPanel1,024,008,'@E 99.99',bVldGet,,,,,,.T.,"",,{||.F.},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RDMEDG",,,,.t.)
	oGet134	:= TGet():New( 272,374,{|u| If(PCount()>0,(cTRB)->TV9_RDMDDG:=u,(cTRB)->TV9_RDMDDG)},oPanel1,024,008,'@E 99.99',bVldGet,,,,,,.T.,"",,{||.F.},.F.,.F.,,.F.,.F.,"","(cTRB)->TV9_RDMDDG",,,,.t.)
	oGet135	:= tComboBox():New( 272,419,{|u| If(PCount()>0,(cTRB)->TV9_MEDRDM:=u,(cTRB)->TV9_MEDRDM)},StrTokArr(NGRETSX3BOX("TV9_MEDRDM")+'; ',';'),050,008,oPanel1,,,,,,.T.,,,,{||fWhenGet({"TV9_RDMESQ","TV9_RDMDIR"})},,,,,"(cTRB)->TV9_MEDRDM")
	oMemo16	:= tMultiget():New( 272,475,{|u| If(Pcount()>0,(cTRB)->TV9_OBSRDM:=u,(cTRB)->TV9_OBSRDM)},oPanel1,90,010,,,,,,.T.,,,{||fWhenGet({"TV9_RDMESQ","TV9_RDMDIR"})})

	oMemo17	:= tMultiget():New( 302,012,{|u| If(Pcount()>0,(cTRB)->TV9_OBSCOM:=u,(cTRB)->TV9_OBSCOM)},oPanel1,200,050,,,,,,.T.)

	Activate MsDialog oDlg8 Centered On Init EnchoiceBar(oDlg8,{||nOpca:=1,IIf( fM688TOK(), oDlg8:End(), ) },{||nOpca:=0,oDlg8:End()})

	If nOpca == 1
		MR1A8GRV()
		MR1A8CHK()
	EndIf

	oTempTable:Delete()

	RestArea(aArea)

Return .T.

//------------------------------------------------------------------------
/*/{Protheus.doc} MNT435MR1( lPerg )
Identifica os Componentes correspondentes das localizacoes
Esquerda e Direita do Equipamento
@author Marcos Wagner Junior
@since   02/06/2010
@version MP11
@param lPerg, lógico, verifica se a tela de perguntas foi confirmada
@return  Nil
/*/
//-------------------------------------------------------------------------
Static Function MNT435MR1( lPerg )

	Local aCompLoc  := { '', '' }
	Local cAlsSTC   := GetNextAlias()

	If ( lPerg := Pergunte( PadR( 'MNT435MR1', Len( Posicione( 'SX1', 1, 'MNT435MR1', 'X1_GRUPO' ) ) ), .T. ) )

		BeginSQL Alias cAlsSTC

			SELECT
				STC.TC_COMPONE,
				STC.TC_LOCALIZ
			FROM
				%table:STC% STC
			WHERE
				STC.TC_CODBEM = %exp:cCodBem% AND
				STC.TC_FILIAL = %xFilial:STC% AND
				( STC.TC_LOCALIZ = %exp:MV_PAR01% OR
				  STC.TC_LOCALIZ = %exp:MV_PAR02% ) AND
				STC.%NotDel%

		EndSQL

		Do While (cAlsSTC)->( !EoF() )

			If AllTrim( (cAlsSTC)->TC_LOCALIZ ) == AllTrim(MV_PAR01)
				aCompLoc[1] := (cAlsSTC)->TC_COMPONE
			ElseIf AllTrim( (cAlsSTC)->TC_LOCALIZ ) == AllTrim( MV_PAR02 )
				aCompLoc[2] := (cAlsSTC)->TC_COMPONE
			EndIf

			(cAlsSTC)->( dbSkip() )

		EndDo

		(cAlsSTC)->( dbCloseArea() )

	EndIf

Return aCompLoc

//------------------------------------------------------------------------
/*/{Protheus.doc} MR1A8GRV()
Gravacao das medicoes realizadas
@author Marcos Wagner Junior
@since   02/06/2010
@version MP11
@return  Nil
/*/
//-------------------------------------------------------------------------
Static Function MR1A8GRV()

	Local i
	Local aTV5		:= TV5->(DbStruct())
	Local lSerRef	:= If(AllTrim(GetNewPar("MV_NGMNTMM")) == AllTrim(STJ->TJ_SERVICO),.T.,.F.)

	If NGIFDBSEEK("TV9",STJ->TJ_CODBEM+STJ->TJ_ORDEM+STJ->TJ_PLANO,1)
		RecLock("TV9",.F.)
	Else
		RecLock("TV9",.T.)
	EndIf

	z := 1
	For i := 1 TO TV9->(FCount())
		x := "TV9->" + TV9->(FieldName(i))
		y := "(cTRB)->" + TV9->(FieldName(i))
		If "_FLARE"+AllTrim(Str(z)) $ x
			cCampo := "(cTRB)->FLARE"+AllTrim(Str(z))
			z++
			If "S" $ &cCampo
				Replace &x. with "1"
			ElseIf "D" $ &cCampo
				Replace &x. with "2"
			EndIf
		Else
			Replace &x. with &y.
		EndIf
		// Atualiza tabela de medição inicial do material rodante (TV5)
		If lSerRef //Se for reforma
			nPos := aScan(aTV5, {|x| SubStr(x[1],5,6) == SUBSTR(TV9->(FieldName(i)),5,6)  })
			If nPos > 2
				If NGIFDBSEEK("TV5",STJ->TJ_CODBEM,1)
					RecLock("TV5",.F.)
					&("TV5->" + aTV5[nPos][1]) := &y.
					TV5->(MsUnLock())
				EndIf
			EndIf
		EndIf
	Next i

	TV9->(MsUnLock())

Return .T.
//------------------------------------------------------------------------
/*/{Protheus.doc} MR1A8CHK()
Funcao de checagem das medidas informadas

@author Marcos Wagner Junior
@since   02/06/2010
@version MP11
@return  Nil
/*/
//-------------------------------------------------------------------------
Static Function MR1A8CHK()

	Local i,j
	Local aOSGerada := {}
	Local lProc := .f.

	Private aAviso := {}
	Private aGeraOS:= {}

	If NGIFDBSEEK("TV9",STJ->TJ_CODBEM+STJ->TJ_ORDEM+STJ->TJ_PLANO,1)
		If NGIFDBSEEK("TVK",STJ->TJ_CODBEM+STJ->TJ_SERVICO+STJ->TJ_SEQRELA,1)
			lProc := .t.
		ElseIf NGIFDBSEEK("TVK",STJ->TJ_CODBEM+Space(Len(STJ->TJ_SERVICO))+Space(Len(STJ->TJ_SEQRELA)),1)
			lProc := .t.
		EndIf
		If lProc
			For i := 1 TO TV9->(FCount())
				x := "TV9->"+TV9->(FieldName(i))
				If "DG" $ x //se campo eh de percentual de desgaste
					For j := 1 TO TVK->(FCount())
						y := "TVK->"+TVK->(FieldName(j))    //123456789012345
						If SubStr(x,9,4) == SubStr(y,9,4)   //TV9->TV9_ELOEDG ,TV9_ELODDG   //TVK_ELOPAV  //TVK_ELOPOS
							If SubStr(y,13,3) == "PAV"  //Percentual aviso
								If &(x) >= &(y)
									aAdd(aAviso,{x,&x,&y})
								EndIf
							ElseIf SubStr(y,13,3) == "POS" //Percentual gera O.S.
								If &(x) >= &(y)
									aAdd(aGeraOS,{x,&x,&y,&("TVK->TVK_SER"+SubStr(x,10,3)),If(SubStr(x,13,1) == "E",cEsq,cDir)})
								EndIf
							EndIf
						EndIf
					Next j
				EndIf
			Next i
		EndIf
	EndIf

	//gera O.S. para o componente que teve desgaste acima do limite
	If Len(aGeraOS) > 0
		cVerific := If(NGVERIFY("STJ"),"0",0)
		For i := 1 to Len(aGeraOS)
			If aScan(aOSGerada,{|x| x[1]+x[2] == aGeraOS[i][5]+aGeraOS[i][4] }) == 0 .And. !Empty(aGeraOS[i][4])
				aRetornoOS := NGGERAOS( 'C', dDatabase, aGeraOS[i][5], aGeraOS[i][4], cVerific, 'N', 'N', 'N' )
				If aRetornoOS[1][1] == 'N'
					MsgStop(aRetornoOS[1][2],STR0076)//"ATENÇÃO"
				Else
					aAdd(aOSGerada,{aGeraOS[i][5],aGeraOS[i][4]})
				Endif
			EndIf
		Next i
	EndIf

	//envia e-mail de aviso
	If Len(aAviso) > 0
		MR1A8MAIL(aAviso)
	EndIf

Return .T.

//------------------------------------------------------------------------
/*/{Protheus.doc} MR1A8MAIL(aMail)
Envio de e-mail sobre limite de desgaste superado
@author Marcos Wagner Junior
@since   02/06/2010
@version MP11
@return  Nil
/*/
//-------------------------------------------------------------------------
Static Function MR1A8MAIL(aMail)

	Local i

	Private aUsuario  := "", cTitulo, oDlgMail, cDiretorio:="", x:=1
	Private cServer   := AllTrim(GetNewPar("MV_RELSERV"," "))
	Private cAccount  := AllTrim(GetNewPar("MV_RELACNT"," "))
	Private cPassword := AllTrim(GetNewPar("MV_RELPSW" ," "))
	Private lSmtpAuth := GetMv("MV_RELAUTH",,.F.)
	Private cFrom     := cAccount
	Private cAnexos   := ""
	Private cTo       := W005EMAIL("MNT435MR")
	Private cCC       := space(200)
	Private cSubject  := STR0070//"Desgaste Material Rodante"
	Private lOk       := .T.
	Private lAutOk    := .F.
	Private cBody     := '<B><font color="#000099">'+STR0071+'</font></B><br><br>'//Desgaste de Material Rodante acima do Limite
	cBody     += '<B><font color="#000099">'+STR0072+': '+cCodBem+'</font></B><br>'//Bem
	cBody     += '<B><font color="#000099">'+STR0073+': '+cEsq+'</font></B><br>'//Componente Esquerdo
	cBody     += '<B><font color="#000099">'+STR0074+': '+cDir+'</font></B><br>'//Componente Direito
	cBody     += '<B><font color="#000099">'+STR0075+': '+DtoC((cTRB)->TV9_DTMED)+'</font></B><br><br>'//Data da Medição
	cBody     += '<PRE>'+STR0077+'</PRE><br>'//Conjunto          %Limite    %Informado

	If Empty(cTo) .Or. Empty(cServer) .Or. Empty(cAccount)
		MsgInfo(STR0078)//"Alguma medida superou o limite de desgaste, para receber e-mail com detalhes é necessário cadastrar os dados para o envio de WorkFlow!"
	Else
		For i:= 1 to Len(aMail)
			cTit		:=	NGRETTITULO(SubStr(aMail[i][1],6,10))
			cNmCampo	:= cTit+Space(12- Len(cTit))
			cBody += "<PRE>"+cNmCampo+Space(6)+AllTrim(Str(aMail[i][3]))+Space(5-Len(AllTrim(Str(aMail[i][3]))))+Space(6)+AllTrim(Str(aMail[i][2]))+Space(5-Len(AllTrim(Str(aMail[i][2]))))+"</PRE>"
		Next i

		CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword Result lOk

		If !lAutOk
			If ( lSmtpAuth )
				lAutOk := MailAuth(cAccount,cPassword)
			Else
				lAutOk := .T.
			EndIf
		EndIf
		If lOk .and. lAutOk
			If !Empty(cCC)
				SEND MAIL FROM cFrom TO cTo CC cCC SUBJECT Alltrim(cSubject) BODY cBody ATTACHMENT cAnexos Result lOk
			Else
				SEND MAIL FROM cFrom TO cTo SUBJECT Alltrim(cSubject) BODY cBody ATTACHMENT cAnexos Result lOk
			EndIf
			If lOk
				MsgInfo(STR0079)//"Enviado e-mail de aviso sobre desgaste do Material Rodante!"
			Else
				GET MAIL ERROR cErro
				MsgStop("Erro" +Chr(13)+Chr(10)+ cErro,"Erro")
				Return .f.
			EndIf
		Else
			GET MAIL ERROR cErro
			MsgStop("Erro" +Chr(13)+Chr(10)+ cErro,"Erro")
			Return .f.
		EndIf
		DISCONNECT SMTP SERVER
	EndIf

Return .T.

//------------------------------------------------------------------------
/*/{Protheus.doc} fVldGet()
Valida campos de medicao e desgaste conforme regra:
valores da medida <= ultima medicao
- percentuais desgaste >= ultima medicao
@author Felipe Nathan Welter
@since   11/08/2010
@version MP11
@return  Nil
/*/
//-------------------------------------------------------------------------
Static Function fVldGet()

	Local aArea := GetArea()
	Local lRet := .T.
	Local cField := ReadVar()
	Local cFieldTV9 := "TV9"+SubStr(cField,At("_",cField))
	Local cFieldTV5 := "TV5"+SubStr(cField,At("_",cField))

	Private lMedNew := If(AllTrim(GetNewPar("MV_NGMNTMM" ," ")) == STJ->TJ_SERVICO,.T.,.F.)

	If !lMedNew

		cAlias := GetNextAlias()
		cQuery := " SELECT TV9."+cFieldTV9
		cQuery += " FROM "+RetSqlName("TV9")+" TV9"
		cQuery += " WHERE TV9.TV9_DTMED <= '"+DTOS((cTRB)->TV9_DTMED)+"'"
		cQuery += " AND TV9.TV9_CODBEM = '"+STJ->TJ_CODBEM+"'"
		cQuery += " AND TV9.TV9_FILIAL = '"+xFilial("TV9")+"'"
		cQuery += " AND TV9.D_E_L_E_T_ <> '*'"
		cQuery += " ORDER BY TV9.TV9_FILIAL, TV9.TV9_CODBEM, TV9.TV9_DTMED, (TV9.R_E_C_N_O_) DESC"
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAlias, .F., .F.)

		If (SubStr(cField,Len(cField)-1)) == "DG"  //Valida campos de desgaste

			dbSelectArea(cAlias)
			dbGoTop()
			If !Eof()
				If &(ReadVar()) > 0 .And. &(ReadVar()) < (cAlias)->(&cFieldTV9)
					ShowHelpDlg(STR0080,{STR0081+NGRETTITULO(cFieldTV9)+STR0082,""},2,;//"INVALIDO"###"Valor informado para o desgaste '"###"' é inferior ao da última medição."
					{STR0083+cValToChar((cAlias)->(&cFieldTV9))+").",""},2)//"Informe um valor maior que o da última medição ("
					lRet := .F.
				EndIf
			EndIf

		Else  //Valida campos de medicao

			dbSelectArea(cAlias)
			dbGoTop()
			If !Eof()
				If &(ReadVar()) > (cAlias)->(&cFieldTV9)
					ShowHelpDlg(STR0080,{STR0084+NGRETTITULO(cFieldTV9)+STR0086,""},2,;//"INVALIDO"###"Valor informado para '"###"' é superior ao da última medição."
					{STR0087+cValToChar((cAlias)->(&cFieldTV9))+").",""},2)//"Informe um valor menor ou igual ao da última medição ("
					lRet := .F.
				EndIf
			Else
				dbSelectArea("TV5")
				dbSetOrder(1)
				If dbSeek(xFilial("TV5")+cCodBem)
					If &(ReadVar()) > TV5->(&cFieldTV5)
						ShowHelpDlg(STR0080,{STR0084+NGRETTITULO(cFieldTV5)+STR0088,""},2,;//"INVALIDO"###"Valor informado para '"###"' é superior ao cadastrado para o bem."
						{STR0089+cValToChar(TV5->(&cFieldTV5))+").",""},2)//"Informe um valor menor ou igual ao cadastrado ("
						lRet := .F.
					EndIf
				EndIf
			EndIf

		EndIf

		(cAlias)->(dbCloseArea())

	EndIf
	RestArea(aArea)

Return lRet

//------------------------------------------------------------------------
/*/{Protheus.doc} fWhenGet(aFields)
When dos campos em tela, conforme array aWhenGet

@author Felipe Nathan Welter
@since   11/08/2010
@version MP11
@return  Nil
/*/
//-------------------------------------------------------------------------
Static Function fWhenGet(aFields)

	Local nPos, cFieldTV5, nX
	Local lWhen := .F.

	For nX := 1 To Len(aFields)
		cFieldTV5 := "TV5"+SubStr(aFields[nX],At("_",aFields[nX]))
		nPos := aScan(aWhenGet, {|x| x[1] == cFieldTV5 })
		lWhen := lWhen .Or. If(nPos > 0, aWhenGet[nPos,2], .T.)
	Next nX

Return nil
//------------------------------------------------------------------------
/*/{Protheus.doc} MNT1VSTC(cBemComp)
Valida se o bem e' um componente da estrutura do bem Pai.

@author Wagner S. de Lacerda
@since   11/07/2011
@version MP11
@return  Nil
/*/
//-------------------------------------------------------------------------
Function MNT1VSTC(cBemComp)

	Local aEstrut := {}
	Local cBemPai := STJ->TJ_CODBEM

	Default cBemComp := ""

	dbSelectArea("STC")

	If Empty(cBemComp)
		Return .T.
	ElseIf !Empty(cBemComp) .And. Empty(cBemPai)
		ShowHelpDlg(STR0037,;//"Atenção"
		{STR0090},2,;//"O Bem Pai deste componente não está definido."
		{STR0091},2)//"Preencha o código do Bem Pai primeiro."
		Return Space(Len(STC->TC_COMPONE))
	EndIf

	If !EXISTCPO("ST9",cBemComp,1)
		Return .F.
	EndIf

	aEstrut := NGCOMPEST(cBemPai, "B", .T., .T., .T.)
	If aScan(aEstrut, {|x| AllTrim(x[1]) == AllTrim(cBemComp) }) == 0
		ShowHelpDlg(STR0037,;//"Atenção"
		{STR0092+AllTrim(cBemPai)+"'."},2,;//"Este bem não é um componente do Bem Pai '"
		{STR0093},2)//"Insira um componente válido."
		Return .F.
	EndIf

Return .T.
/*
Funções do mntr675
*/
//---------------------------------------------------------------------
/*/{Protheus.doc} MNTR688MR
Impressao do Medicao do Material Rodante
@author Evaldo Cevinscki Jr
@since 02/06/2010
@version P11
/*/
//---------------------------------------------------------------------
Function MNTR688MR(oPrint,cCodBem)

	Local cPerg    := "MNT435MR1"
	Local cGrupo   := PADR(cPerg,Len(Posicione("SX1", 1, cPerg, "X1_GRUPO")))
	Local cCompEsq := " ", cCompDir := " "

	Local cBARRAS    := If(isSRVunix(),"/","\")
	Local cRootPath  := Alltrim(GetSrvProfString("RootPath",cBARRAS))
	Local cStartPath := AllTrim(GetSrvProfString("StartPath",cBARRAS))
	Local cDirExeTh  := cRootPath+cStartPath

	Private nMaxCarac	:=	56	//	Quantidade maxima de caracteres em cada linha
	Private cEmpresa := SM0->M0_CODIGO
	Private cFilial  := SM0->M0_CODFIL
	Private lin := 0
	Private oFont07,oFont08,oFont09,oFont09B,oFont10,oFont11,oFont11B,oFont12,oFont13,oFont14

	dbSelectArea("SX1")
	dbSetOrder(01)
	If !dbSeek(cGrupo+"01")
		Pergunte(cPerg,.T.)
	Else
		MV_PAR01 := Posicione("SX1", 1, cPerg+"01", "X1_CNT01")
		MV_PAR02 := Posicione("SX1", 1, cPerg+"02", "X1_CNT01")
	EndIf

	oFont07		:= TFont():New("Courier New",07,07,,.F.,,,,.F.,.F.)
	oFont09		:= TFont():New("Courier New",09,09,,.F.,,,,.F.,.F.)
	oFont09B	:= TFont():New("Courier New",09,09,,.T.,,,,.F.,.F.)
	oFont10		:= TFont():New("Courier New",10,10,,.T.,,,,.F.,.F.)
	oFont11		:= TFont():New("Courier New",11,11,,.F.,,,,.F.,.F.)
	oFont11B	:= TFont():New("Courier New",11,11,,.T.,,,,.F.,.F.)
	oFont13		:= TFont():New("Courier New",13,13,,.T.,,,,.F.,.F.)

	DbSelectArea("TV5")
	DbSetOrder(01)
	If DbSeek(xFilial("TV5")+cCodBem)


		DbSelectArea("ST9")
		DbSetOrder(01)
		If DbSeek(xFilial("ST9")+cCodBem)

			DbSelectArea("STC")
			DbSetOrder(01)
			If DbSeek(xFilial("STC")+cCodBem)
				While !Eof() .And. STC->TC_FILIAL == xFilial("STC") .And. STC->TC_CODBEM == cCodBem
					If AllTrim(STC->TC_LOCALIZ) == AllTrim(MV_PAR01)
						cCompEsq := AllTrim(STC->TC_COMPONE)
					ElseIf AllTrim(STC->TC_LOCALIZ) == AllTrim(MV_PAR02)
						cCompDir := AllTrim(STC->TC_COMPONE)
					EndIf
					STC->(DbSkip())
				End
			EndIf

			Somalinha(2900)

			oPrint:StartPage()

			lin := 100
			oPrint:Box(lin,100,2300,2400)

			//logo
			cLogo := cStartPath+"LGRL"+SM0->M0_CODIGO+SM0->M0_CODFIL+".BMP" // Empresa+Filial
			If !File(cLogo)
				If File(cStartPath+"LGRL"+SM0->M0_CODIGO+".BMP")
					cLogo := cStartPath+"LGRL"+SM0->M0_CODIGO+".BMP" // Empresa
				ElseIf File(cDIREXETH+"LGRL"+SM0->M0_CODIGO+SM0->M0_CODFIL+".BMP")
					cLogo := cDIREXETH+"LGRL"+SM0->M0_CODIGO+SM0->M0_CODFIL+".BMP"
				ElseIf File(cDIREXETH+"LGRL"+SM0->M0_CODIGO+".BMP")
					cLogo := cDIREXETH+"LGRL"+SM0->M0_CODIGO+".BMP"
				ElseIf File("LGRL"+SM0->M0_CODIGO+SM0->M0_CODFIL+".BMP")
					cLogo := "LGRL"+SM0->M0_CODIGO+SM0->M0_CODFIL+".BMP"
				ElseIf File("LGRL"+SM0->M0_CODIGO+".BMP")
					cLogo := "LGRL"+SM0->M0_CODIGO+".BMP"
				ElseIf File("\SIGAADV\LGRL"+SM0->M0_CODIGO+SM0->M0_CODFIL+".BMP")
					cLogo := "\SIGAADV\LGRL"+SM0->M0_CODIGO+SM0->M0_CODFIL+".BMP"
				ElseIf File("\SIGAADV\LGRL"+SM0->M0_CODIGO+".BMP")
					cLogo := "\SIGAADV\LGRL"+SM0->M0_CODIGO+".BMP"
				Endif
			Endif

			If File(cLogo)
				oPrint:SayBitMap(lin+40,120,cLogo,250,73)
			EndIf


			oPrint:Say(lin+65,940,STR0120 ,oFont13)//"Componentes do Material Rodante"

			Somalinha(200)
			oPrint:Line(lin,100,lin,2400) //Linha Hizontal

			oPrint:Say(lin+30,120,STR0121+AllTrim(cCodBem)+" - "+ST9->T9_NOME,oFont11)//"Equipamento Pai....: "
			oPrint:Say(lin+30,2000,STR0122+STJ->TJ_ORDEM,oFont11)//"O.S.: "

			Somalinha(40)
			oPrint:Say(lin+60,120,STR0123,oFont11)//"Componenetes Filhos: "
			Somalinha(40)
			oPrint:Say(lin+60,120,STR0124+AllTrim(cCompEsq)+" - "+NGSEEK("ST9",cCompEsq,1,'ST9->T9_NOME'),oFont11)//"Esquerda: "
			Somalinha(40)
			oPrint:Say(lin+60,120,STR0125 +AllTrim(cCompDir)+" - "+NGSEEK("ST9",cCompDir,1,'ST9->T9_NOME'),oFont11)//"Direita.: "

			oPrint:Line(lin+110,100,lin+110,2400) //Linha Hizontal


			Somalinha(140)
			oPrint:Say(lin+20,120,STR0126,oFont09B)//"Conjuntos            Dimensões                          Percentual"
			Somalinha(40)
			oPrint:Say(lin+20,120, STR0127,oFont09B)//"Iniciais           Encontradas     Desgaste"
			Somalinha(40)
			oPrint:Say(lin+20,120,STR0128,oFont09B)//"Esq.   Dir.   UM   Esq.    Dir.    Esq.    Dir.     Medidor       Observação"

			Somalinha(70)
			oPrint:Line(lin,100,lin,2400)   //Linha Horizontal

			oPrint:Say(lin+30,120,STR0130,oFont09)//"Elos"
			oPrint:Say(lin+30,530,AllTrim(Str(TV5->TV5_ELOESQ)),oFont09)
			oPrint:Say(lin+30,670,AllTrim(Str(TV5->TV5_ELODIR)),oFont09)
			oPrint:Say(lin+30,805,TV5->TV5_UMELO,oFont09)
			oPrint:Say(lin+30,905,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1060,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1220,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1370,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1545,Replicate("_",10),oFont09)
			oPrint:Say(lin+30,1820,Replicate("_",25),oFont09)

			Somalinha(80)
			oPrint:Say(lin+30,120,STR0131,oFont09)//"Buchas"
			oPrint:Say(lin+30,530,AllTrim(Str(TV5->TV5_BUCESQ)),oFont09)
			oPrint:Say(lin+30,670,AllTrim(Str(TV5->TV5_BUCDIR)),oFont09)
			oPrint:Say(lin+30,805,TV5->TV5_UMBUC,oFont09)
			oPrint:Say(lin+30,910,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1060,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1220,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1370,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1545,Replicate("_",10),oFont09)
			oPrint:Say(lin+30,1820,Replicate("_",25),oFont09)

			Somalinha(80)
			oPrint:Say(lin+30,120,STR0132,oFont09)//"Sapatas"
			oPrint:Say(lin+30,530,AllTrim(Str(TV5->TV5_SAPESQ)),oFont09)
			oPrint:Say(lin+30,670,AllTrim(Str(TV5->TV5_SAPDIR)),oFont09)
			oPrint:Say(lin+30,805,TV5->TV5_UMSAP,oFont09)
			oPrint:Say(lin+30,910,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1060,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1220,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1370,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1545,Replicate("_",10),oFont09)
			oPrint:Say(lin+30,1820,Replicate("_",25),oFont09)

			Somalinha(80)
			oPrint:Say(lin+30,120,STR0133,oFont09)//"Rodas Guias Diant."
			oPrint:Say(lin+30,530,AllTrim(Str(TV5->TV5_RDDESQ)),oFont09)
			oPrint:Say(lin+30,670,AllTrim(Str(TV5->TV5_RDDDIR)),oFont09)
			oPrint:Say(lin+30,805,TV5->TV5_UMRDD,oFont09)
			oPrint:Say(lin+30,910,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1060,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1220,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1370,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1545,Replicate("_",10),oFont09)
			oPrint:Say(lin+30,1820,Replicate("_",25),oFont09)

			Somalinha(80)
			oPrint:Say(lin+30,120,STR0106,oFont09) //"Rodas Guias Tras."
			oPrint:Say(lin+30,530,AllTrim(Str(TV5->TV5_RDTESQ)),oFont09)
			oPrint:Say(lin+30,670,AllTrim(Str(TV5->TV5_RDTDIR)),oFont09)
			oPrint:Say(lin+30,805,TV5->TV5_UMRDT,oFont09)
			oPrint:Say(lin+30,910,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1060,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1220,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1370,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1545,Replicate("_",10),oFont09)
			oPrint:Say(lin+30,1820,Replicate("_",25),oFont09)

			Somalinha(80)
			oPrint:Say(lin+30,120,STR0107,oFont09)//"Roletes Superior 1º"
			oPrint:Say(lin+30,530,AllTrim(Str(TV5->TV5_RS1ESQ)),oFont09)
			oPrint:Say(lin+30,670,AllTrim(Str(TV5->TV5_RS1DIR)),oFont09)
			oPrint:Say(lin+30,805,TV5->TV5_UMRS1,oFont09)
			oPrint:Say(lin+30,910,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1060,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1220,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1370,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1545,Replicate("_",10),oFont09)
			oPrint:Say(lin+30,1820,Replicate("_",25),oFont09)

			Somalinha(80)
			oPrint:Say(lin+30,120,STR0108,oFont09)//"Roletes Superior 2º"
			oPrint:Say(lin+30,530,AllTrim(Str(TV5->TV5_RS2ESQ)),oFont09)
			oPrint:Say(lin+30,670,AllTrim(Str(TV5->TV5_RS2DIR)),oFont09)
			oPrint:Say(lin+30,805,TV5->TV5_UMRS2,oFont09)
			oPrint:Say(lin+30,910,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1060,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1220,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1370,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1545,Replicate("_",10),oFont09)
			oPrint:Say(lin+30,1820,Replicate("_",25),oFont09)

			Somalinha(80)
			oPrint:Say(lin+30,120,STR0109,oFont09) //"Roletes Esteira 1º"
			oPrint:Say(lin+30,530,AllTrim(Str(TV5->TV5_RE1ESQ)),oFont09)
			oPrint:Say(lin+30,670,AllTrim(Str(TV5->TV5_RE1DIR)),oFont09)
			oPrint:Say(lin+30,805,TV5->TV5_UMRE1,oFont09)
			oPrint:Say(lin+30,910,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1060,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1220,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1370,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1545,Replicate("_",10),oFont09)
			oPrint:Say(lin+30,1820,Replicate("_",25),oFont09)
			oPrint:Say(lin+70,1820,STR0129,oFont07)//"Flange: Simples( )  Dupla( )"

			Somalinha(80)
			oPrint:Say(lin+30,120,STR0111,oFont09)//"Roletes Esteira 2º"
			oPrint:Say(lin+30,530,AllTrim(Str(TV5->TV5_RE2ESQ)),oFont09)
			oPrint:Say(lin+30,670,AllTrim(Str(TV5->TV5_RE2DIR)),oFont09)
			oPrint:Say(lin+30,805,TV5->TV5_UMRE2,oFont09)
			oPrint:Say(lin+30,910,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1060,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1220,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1370,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1545,Replicate("_",10),oFont09)
			oPrint:Say(lin+30,1820,Replicate("_",25),oFont09)
			oPrint:Say(lin+70,1820,STR0129,oFont07)//"Flange: Simples( )  Dupla( )"

			Somalinha(80)
			oPrint:Say(lin+30,120,STR0112,oFont09) //"Roletes Esteira 3º"
			oPrint:Say(lin+30,530,AllTrim(Str(TV5->TV5_RE3ESQ)),oFont09)
			oPrint:Say(lin+30,670,AllTrim(Str(TV5->TV5_RE3DIR)),oFont09)
			oPrint:Say(lin+30,805,TV5->TV5_UMRE3,oFont09)
			oPrint:Say(lin+30,910,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1060,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1220,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1370,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1545,Replicate("_",10),oFont09)
			oPrint:Say(lin+30,1820,Replicate("_",25),oFont09)
			oPrint:Say(lin+70,1820,STR0129,oFont07) //"Flange: Simples( )  Dupla( )"

			Somalinha(80)
			oPrint:Say(lin+30,120,STR0113,oFont09) //"Roletes Esteira 4º"
			oPrint:Say(lin+30,530,AllTrim(Str(TV5->TV5_RE4ESQ)),oFont09)
			oPrint:Say(lin+30,670,AllTrim(Str(TV5->TV5_RE4DIR)),oFont09)
			oPrint:Say(lin+30,805,TV5->TV5_UMRE4,oFont09)
			oPrint:Say(lin+30,910,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1060,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1220,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1370,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1545,Replicate("_",10),oFont09)
			oPrint:Say(lin+30,1820,Replicate("_",25),oFont09)
			oPrint:Say(lin+70,1820,STR0129,oFont07)//"Flange: Simples( )  Dupla( )"

			Somalinha(80)
			oPrint:Say(lin+30,120,STR0114,oFont09) //"Roletes Esteira 5º"
			oPrint:Say(lin+30,530,AllTrim(Str(TV5->TV5_RE5ESQ)),oFont09)
			oPrint:Say(lin+30,670,AllTrim(Str(TV5->TV5_RE5DIR)),oFont09)
			oPrint:Say(lin+30,805,TV5->TV5_UMRE5,oFont09)
			oPrint:Say(lin+30,910,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1060,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1220,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1370,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1545,Replicate("_",10),oFont09)
			oPrint:Say(lin+30,1820,Replicate("_",25),oFont09)
			oPrint:Say(lin+70,1820,STR0129,oFont07)//"Flange: Simples( )  Dupla( )"

			Somalinha(80)
			oPrint:Say(lin+30,120,STR0115,oFont09) //"Roletes Esteira 6º"
			oPrint:Say(lin+30,530,AllTrim(Str(TV5->TV5_RE6ESQ)),oFont09)
			oPrint:Say(lin+30,670,AllTrim(Str(TV5->TV5_RE6DIR)),oFont09)
			oPrint:Say(lin+30,805,TV5->TV5_UMRE6,oFont09)
			oPrint:Say(lin+30,910,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1060,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1220,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1370,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1545,Replicate("_",10),oFont09)
			oPrint:Say(lin+30,1820,Replicate("_",25),oFont09)
			oPrint:Say(lin+70,1820,STR0129,oFont07)//"Flange: Simples( )  Dupla( )"

			Somalinha(80)
			oPrint:Say(lin+30,120,STR0116,oFont09) //"Roletes Esteira 7º"
			oPrint:Say(lin+30,530,AllTrim(Str(TV5->TV5_RE7ESQ)),oFont09)
			oPrint:Say(lin+30,670,AllTrim(Str(TV5->TV5_RE7DIR)),oFont09)
			oPrint:Say(lin+30,805,TV5->TV5_UMRE7,oFont09)
			oPrint:Say(lin+30,910,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1060,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1220,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1370,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1545,Replicate("_",10),oFont09)
			oPrint:Say(lin+30,1820,Replicate("_",25),oFont09)
			oPrint:Say(lin+70,1820,STR0129,oFont07)//"Flange: Simples( )  Dupla( )"

			Somalinha(80)
			oPrint:Say(lin+30,120,STR0117,oFont09) //"Roletes Esteira 8º"
			oPrint:Say(lin+30,530,AllTrim(Str(TV5->TV5_RE8ESQ)),oFont09)
			oPrint:Say(lin+30,670,AllTrim(Str(TV5->TV5_RE8DIR)),oFont09)
			oPrint:Say(lin+30,805,TV5->TV5_UMRE8,oFont09)
			oPrint:Say(lin+30,910,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1060,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1220,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1370,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1545,Replicate("_",10),oFont09)
			oPrint:Say(lin+30,1820,Replicate("_",25),oFont09)
			oPrint:Say(lin+70,1820,STR0129,oFont07)//"Flange: Simples( )  Dupla( )"

			Somalinha(80)
			oPrint:Say(lin+30,120,STR0118,oFont09) //"Rodas Motrizes"
			oPrint:Say(lin+30,530,AllTrim(Str(TV5->TV5_RDMESQ)),oFont09)
			oPrint:Say(lin+30,670,AllTrim(Str(TV5->TV5_RDMDIR)),oFont09)
			oPrint:Say(lin+30,805,TV5->TV5_UMRDM,oFont09)
			oPrint:Say(lin+30,910,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1060,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1220,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1370,Replicate("_",5),oFont09)
			oPrint:Say(lin+30,1545,Replicate("_",10),oFont09)
			oPrint:Say(lin+30,1820,Replicate("_",25),oFont09)

			Somalinha(80)

			oPrint:Say(lin+30,120,STR0119  + Replicate("_",100),oFont09)//"Comentários: "
			Somalinha(90)
			oPrint:Say(lin+30,120,Replicate("_",113),oFont09)
			Somalinha(90)
			oPrint:Say(lin+30,120,Replicate("_",113),oFont09)
			Somalinha(90)

			oPrint:EndPage()
		EndIf
	EndIf

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³SOMALINHA ³ Autor ³Evaldo Cevinscki Jr.   ³ Data ³01/06/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Impressao do Relatorio                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Somalinha(nLinhas)

	If nLinhas == Nil
		Lin += 50
	Else
		Lin += nLinhas
	EndIf

	If lin > 2810
		oPrint:Line(lin,100,lin,2300)
		oPrint:EndPage()
		oPrint:StartPage()
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT691DMED()
Valida data de medição
@author Bruno Lobo de Souza
@since 18/09/2015
@version P11
@return Nil
/*/
//-------------------------------------------------------------------
Function MNT691DMED()
	Local aArea := GetArea()

	dbSelectArea( "ST9" )
	dbSetOrder( 1 )
	If &( ReadVar() ) < ST9->T9_DTCOMPR
		MsgStop( STR0136, STR0076 )
		RestArea( aArea )
		Return .F.
	ElseIf &( ReadVar() ) > dDatabase
		MsgStop( STR0137, STR0076 )
		Return .F.
	EndIf
	RestArea( aArea )

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT691WhDt()
Valida Whem da data de medição
@author Bruno Lobo de Souza
@since 18/09/2015
@version P11
@return Nil
/*/
//-------------------------------------------------------------------
Function MNT691WhDt()

	Local lWhen := .T.

	dbSelectArea( "TV9" )
	dbSetOrder( 1 )
	lWhen := !dbSeek( xFilial( "TV9" ) + STJ->TJ_CODBEM + STJ->TJ_ORDEM + STJ->TJ_PLANO )

Return lWhen

//---------------------------------------------------------------------
/*/{Protheus.doc} f688PerDes()
Calcula percentual de desgaste.

@author Juliani Schlickmann Damasceno
@since 15/04/2016
@version P11
@return Nil

Ajustado:
@author Bruno Lobo de Souza
@since 09/06/2016
/*/
//-------------------------------------------------------------------
Static Function f688PerDes(nCampoTV5,cField,cFieldTV9)

	Local lSerRef	:= AllTrim(GetNewPar("MV_NGMNTMM")) == AllTrim(STJ->TJ_SERVICO)
	Local lRet		:= .T.
	Local cQuery	:= ""
	Local cAliasAnt, cAliasPos

	Default cField	:= ReadVar()
	Default cFieldTV9 := "TV9"+SubStr(cField,At("_",cField))

	//Retorna medição anterior
	cAliasAnt := GetNextAlias()
	cQuery := " SELECT TV9."+cFieldTV9
	cQuery += " FROM "+RetSqlName("TV9")+" TV9"
	cQuery += " WHERE "
	cQuery += " TV9.TV9_DTMED <= '"+DTOS((cTRB)->TV9_DTMED)+"'"
	cQuery += " AND TV9.TV9_CODBEM = '"+STJ->TJ_CODBEM+"'"
	cQuery += " AND TV9.TV9_FILIAL = '"+xFilial("TV9")+"'"
	cQuery += " AND TV9.TV9_ORDEM <> '"+(cTRB)->TV9_ORDEM+"'"
	cQuery += " AND TV9.D_E_L_E_T_ <> '*'"
	cQuery += " ORDER BY TV9.TV9_FILIAL, TV9.TV9_CODBEM, TV9.TV9_DTMED, (TV9.R_E_C_N_O_) DESC"
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasAnt, .F., .F.)

	//Retorna medição posterior
	cAliasPos := GetNextAlias()
	cQuery := " SELECT TV9."+cFieldTV9
	cQuery += " FROM "+RetSqlName("TV9")+" TV9"
	cQuery += " WHERE "
	cQuery += " TV9.TV9_DTMED >= '"+DTOS((cTRB)->TV9_DTMED)+"'"
	cQuery += " AND TV9.TV9_CODBEM = '"+STJ->TJ_CODBEM+"'"
	cQuery += " AND TV9.TV9_FILIAL = '"+xFilial("TV9")+"'"
	cQuery += " AND TV9.TV9_ORDEM <> '"+(cTRB)->TV9_ORDEM+"'"
	cQuery += " AND TV9.D_E_L_E_T_ <> '*'"
	cQuery += " ORDER BY TV9.TV9_FILIAL, TV9.TV9_CODBEM, TV9.TV9_DTMED, (TV9.R_E_C_N_O_)"
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasPos, .F., .F.)

	If lSerRef
		If &cField. < 0
			MsgStop(STR0138,STR0002)
			lRet := .F.
		ElseIf !Empty((cAliasPos)->(&cFieldTV9))
			MsgStop(STR0143+AllTrim(GetNewPar("MV_NGMNTMM"))+STR0144,STR0002)
			lRet := .F.
		Else
			&(SubStr(cField,1,Len(cField)-2)+"DG") := 0
		EndIf
	Else
		If (cTRB)->TV9_DTMED <= fRetDtRef()
			lRet := .F.
			MsgStop(STR0142,STR0002)
		Else

			//Regras a serem aplicadas as medições
			If &cField. >= 0
				If &cField. <= nCampoTV5
					If ( Empty((cAliasAnt)->(&cFieldTV9)) .Or. &cField. <= (cAliasAnt)->(&cFieldTV9) ) .And.;
					( Empty((cAliasPos)->(&cFieldTV9)) .Or. &cField. >= (cAliasPos)->(&cFieldTV9) )
						If &cField. == 0
							If nCampoTV5 == 0
								&(SubStr(cField,1,Len(cField)-2)+"DG") := 0
							Else
								MsgStop(STR0141,STR0002)
								lRet := .F.
							EndIf
						Else
							&(SubStr(cField,1,Len(cField)-2)+"DG") := ( ( nCampoTV5 - &cField. ) *100 ) / nCampoTV5
						EndIf
					Else
						MsgStop(STR0139,STR0002)
						lRet := .F.
					EndIf
				Else
					MsgStop(STR0139,STR0002)
					lRet := .F.
				EndIf
			Else
				MsgStop(STR0140,STR0002)
				lRet := .F.
			EndIf
		EndIf

	EndIf

	(cAliasAnt)->(dbCloseArea())
	(cAliasPos)->(dbCloseArea())

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fM688TOK()
Valida confirmação da tela de medição de material rodante

@author Bruno Lobo de Souza
@since 13/06/2016
@version P12
@return Nil

/*/
//-------------------------------------------------------------------
Static Function fM688TOK()

	Local i
	Local nTV5
	Local lRet := .T.

	For i := 1 To (cTRB)->(FCount())
		x := "(cTRB)->" + TV9->(FieldName(i))
		y := TV9->(FieldName(i))
		If "DIR" $ x .Or. "ESQ" $ x
			z := "TV5->TV5" + SubStr(x,12,Len(x))
			nTV5 := &z.
			If !(lRet := f688PerDes(nTV5,x,y) )
				Exit
			EndIf
		EndIf
	Next i

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fRetDtRef()
Retorna data do ultimo serviço de reforma para material rodante.

@author Bruno Lobo de Souza
@since 13/06/2016
@version P12
@return Nil
/*/
//-------------------------------------------------------------------
Static Function fRetDtRef()

	Local cAliasQry := getNextAlias()
	Local cQuery := ""
	Local cServico := GetNewPar("MV_NGMNTMM")

	cQuery := " SELECT TV9.TV9_DTMED"
	cQuery += " FROM "+RetSqlName("TV9")+" TV9"
	cQuery += " INNER JOIN "+RetSqlName("STJ")+" STJ"
	cQuery += " ON STJ.TJ_ORDEM = TV9.TV9_ORDEM"
	cQuery += " AND STJ.TJ_CODBEM = TV9.TV9_CODBEM"
	cQuery += " WHERE"
	cQuery += " STJ.TJ_SERVICO = '"+cServico+"'"
	cQuery += " AND STJ.TJ_CODBEM = '"+STJ->TJ_CODBEM+"'"
	cQuery += " AND STJ.TJ_FILIAL = '"+xFilial("STJ")+"'"
	cQuery += " AND TV9.TV9_FILIAL = '"+xFilial("TV9")+"'"
	cQuery += " AND STJ.D_E_L_E_T_ <> '*'"
	cQuery += " AND TV9.D_E_L_E_T_ <> '*'"

	cQuery += " ORDER BY TV9.TV9_DTMED, (TV9.R_E_C_N_O_) DESC"
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .F.)

Return StoD((cAliasQry)->TV9_DTMED)
