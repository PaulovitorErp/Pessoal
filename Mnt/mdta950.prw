#INCLUDE "Mdta950.ch"
#Include "Protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MDTA950  ³ Autor ³ Thiago Olis Machado   ³ Data ³ 23/12/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Manutencao do Historico de Alteracoes de setores do funcio-³±±
±±³          ³ nario                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMDT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³Solic.³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function MDTA950()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Guarda conteudo e declara variaveis padroes ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aNGBEGINPRM := NGBEGINPRM( )

Local cPerg:= PADR( "MDT950", 10 )
Private nSizeSI3
Private cSvFilAnt := cFilAnt	//Salva a Filial Corrente
Private cSvEmpAnt := cEmpAnt	//Salva a Empresa Corrente
Private aKeyCcFilter := {}
Private cAliasCc := If(GetMv("MV_MCONTAB") = 'CON', "SI3", "CTT")
PRIVATE cEmpPPP := cEmpAnt
Private nTamTable  := Len(cArqTab)
Private aVetinr := {}
aKeyCcFilter := {	PrefixoCpo(cAliasCc)+"_FILIAL",;
					PrefixoCpo(cAliasCc)+"_CUSTO",;
					IF( cAliasCc == "CTT" , "CTT_DESC01" , "I3_DESC" ) }

nSizeSI3 := If((TAMSX3("I3_CUSTO")[1]) < 1,9,(TAMSX3("I3_CUSTO")[1]))
nSizeSI3 := If(nSizeSI3 > 20,20,nSizeSI3)

If !pergunte(cPerg,.t.)
	Return .f.
EndIf

Processa({|lEnd| MD950BROW()},STR0002)   //"Processando Arquivo..."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorna conteudo de variaveis padroes       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
NGRETURNPRM(aNGBEGINPRM)
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MD950BROW ³ Autor ³ Thiago Olis Machado   ³ Data ³ 23/12/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Montagem do Arquivo para gerar o Browse                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MDTA950                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MD950BROW()

Local nSizeFil := If(FindFunction("FWSizeFilial"),FwSizeFilial(),Len(cFilAnt))
Local oTempTRB

Private aRotina := MenuDef()
Private cTmp95Fil := cFilAnt //Ultima Filial utilizada
Private cTmp95Emp := cEmpAnt //Ultima Empresa utilizada

Private cCadastro :=OemtoAnsi(STR0007)  //"Histórico C.custos"
Private aSMenu :={},aChkdel :={}
Private cCusAnt   := SRA->RA_CC
Private aVetinr := {}

aDbf := {{"DATAH"     , "D", 08,0} ,;
          {"EMPD"      , "C", 02,0} ,;
          {"FILIALD"   , "C", nSizeFil,0} ,;
          {"NOMFILD"   , "C", 20,0} ,;
          {"MATD"      , "C", 06,0} ,;
          {"NOMFUND"   , "C", 30,0} ,;
          {"CCD"       , "C",nSizeSI3,0} ,;
          {"NOMCCD"    , "C", 30,0} ,;
          {"EMPP"      , "C", 02,0} ,;
          {"FILIALP"   , "C", nSizeFil,0} ,;
          {"NOMFILP"   , "C", 20,0} ,;
          {"MATP"      , "C", 06,0} ,;
          {"CCP"       , "C",nSizeSI3,0},;
          {"NOMCCP"    , "C", 30,0}}


//Cria TRB
oTempTRB := FWTemporaryTable():New( "TRB", aDBF )
oTempTRB:AddIndex( "1", {"EMPD","FILIALD","MATD","DATAH"} )
oTempTRB:Create()

aField := {{STR0008,"DATAH" ,"D",08,0,"99/99/99"},;   //"Data Transf."
           {STR0009,"EMPD"   ,"C",02,0,"@!"},;   //"Empresa Orig."
           {STR0010,"FILIALD","C",nSizeFil,0,"@!"},; //"Filial Orig. "
           {STR0030,"NOMFILD","C",20,0,"@!"},; //"Nome Filial Orig."
           {STR0011,"MATD"   ,"C",06,0,"@!"},;  //"Matrícula Orig."
           {STR0031,"NOMFUND","C",30,0,"@!"},; //"Nome do Funcionário"
           {STR0012,"CCD"    ,"C",nSizeSI3,0,"@!"},; //"C.C. Origem "
           {STR0032,"NOMCCD","C",30,0,"@!"},; //"Nome C.C. Origem"
           {STR0013,"EMPP"   ,"C",02,0,"@!"},;  //"Empr.Destino"
           {STR0014,"FILIALP","C",nSizeFil,0,"@!"},; //"Fil. Destino"
           {STR0033,"NOMFILP","C",20,0,"@!"},; //"Nome Fil. Destino"
           {STR0015,"MATP"   ,"C",06,0,"@!"},; //"Mat. Destino"
           {STR0016,"CCP"    ,"C",nSizeSI3,0,"@!"},;    //"C.C. Destino"
           {STR0034,"NOMCCP","C",30,0,"@!"}} //"Nome C.C. Destino"


dbSelectArea("SRE")
dbSetOrder(1)
Processa({||MD950TRB()})

dbSelectArea("TRB")
DbGotop()

mBrowse( 6, 1,22,75,"TRB",aField)

oTempTRB:Delete()
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MD950TRB  ³ Autor ³ Thiago Olis Machado   ³ Data ³ 23/12/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gravacao do Arquivo de Trabalho (TRB)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MDTA950                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function MD950TRB(nOpcx)
Local cTmp95Fil := cFilAnt //Ultima Filial utilizada
Local cTmp95Emp := cEmpAnt //Ultima Empresa utilizada
Local aAreaSM0  := SM0->(GetArea())

If nOpcx = 2 .or. nOpcx = 3
	dbSelectArea("TRB")
	Zap
EndIf

dbSelectArea("SRA")
dbSetOrder(1)
dbSeek(xFilial("SRA")+Mv_Par01)
cNomeFun := SRA->RA_NOME
cNomeFil := SM0->M0_NOME
cFilOrig := PADR(SRA->RA_FILIAL,TAMSX3('RE_FILIALD')[1])

dbSelectArea("SRE")
dbSetOrder(1)
dbSeek(SM0->M0_CODIGO+cFilOrig+Mv_Par01)
Do While !Eof() .and. SRE->RE_EMPD == SM0->M0_CODIGO .And. SRE->RE_FILIALD == cFilOrig .and. ;
	SRE->RE_MATD == Mv_Par01
	If nOpcx <> 1
		dbSelectArea("TRB")
		If !dbSeek(SRE->RE_EMPD+SRE->RE_FILIALD+SRE->RE_MATD+DtoS(SRE->RE_DATA))
			RecLock("TRB",.t.)
		Else
			RecLock("TRB",.f.)
		EndIf

		TRB->DATAH   := SRE->RE_DATA
		TRB->EMPD    := SRE->RE_EMPD
		TRB->FILIALD := SRE->RE_FILIALD
		TRB->MATD    := SRE->RE_MATD
		TRB->CCD     := SRE->RE_CCD
		TRB->EMPP    := SRE->RE_EMPP
		TRB->FILIALP := SRE->RE_FILIALP
		TRB->MATP    := SRE->RE_MATP
		TRB->CCP     := SRE->RE_CCP
		TRB->NOMFUND := cNomeFun
		TRB->NOMFILD := cNomeFil
		TRB->NOMCCD  := Posicione(cAliasCc,1,xFilial(cAliasCc)+SRE->RE_CCD,aKeyCcFilter[3])

		If SRE->RE_EMPP <> cTmp95Emp .or. SRE->RE_FILIALP <> cTmp95Fil
			dbSelectArea("SM0")
			If dbSeek(SRE->RE_EMPP+SRE->RE_FILIALP)
				If SRE->RE_EMPP <> cTmp95Emp
					NGPrepTBL({{cAliasCc,01}},SRE->RE_EMPP,SRE->RE_FILIALP)
					TRB->NOMFILP := SM0->M0_NOME
					TRB->NOMCCP  := Posicione(cAliasCc,1,xFilial(cAliasCc,SRE->RE_FILIALP)+SRE->RE_CCP,aKeyCcFilter[3])
					NGPrepTBL({{cAliasCc,01}},cTmp95Emp,cTmp95Fil)
				Else
					TRB->NOMFILP := SM0->M0_NOME
					TRB->NOMCCP  := Posicione(cAliasCc,1,xFilial(cAliasCc,SRE->RE_FILIALP)+SRE->RE_CCP,aKeyCcFilter[3])
				Endif
			Endif
			RestArea(aAreaSM0)
		Else
			TRB->NOMFILP := cNomeFil
			TRB->NOMCCP  := Posicione(cAliasCc,1,xFilial(cAliasCc)+SRE->RE_CCP,aKeyCcFilter[3])
		Endif
	EndIf

	MsUnlock("TRB")

	dbSelectArea("SRE")
	dbSetOrder(1)
	DbSkip()
EndDo

cFilAnt := cTmp95Fil
cEmpAnt := cTmp95Emp

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MD950IN   ³ Autor ³ Thiago Olis Machado   ³ Data ³ 23/12/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Montagem da Tela de Inclusao/Alteracao/Exclusao/Visual     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MDTA950                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function MD950IN(cAlias,nReg,nOpcx)
Local oGet,oDlg
Local lWhen,lRet,lRet1,lRet2
Local dDt_Tran
Local cCcXb
Local nOpcA
Local aAreaSM0 := SM0->(GetArea())
Local nSizeEmp := Len(cEmpAnt)
Local nSizeFil := If(FindFunction("FWSizeFilial"),FwSizeFilial(),Len(cFilAnt))
Local nTamanho

Private oGet01,oGet02,oGet03,oGet04,oGet05,oGet06,oGet07,oGet08
Private oGet11,oGet12,oGet13,oGet14,oGet15,oGet16,oGet17,oGet18
Private cEmp_O,cFil_O,cMat_O,cCus_O
Private cEmp_D,cFil_D,cMat_D,cCus_D
Private cEmpFiltro

lRet     := .F.
lRet1    := .F.
lRet2    := .F.
nOpcA    := 0.00
lWhen    := .f.
dDt_Tran := cTod("  /  /  ")
cCcXb    := IF( cAliasCc == "CTT" , "XTT" , "XI3" )


//Se encontrar a função verifica o tamanho do X1
If FindFunction("NGMTAMFIL")
	nTamanho := NGMTAMFIL()//Função que retorna maior tamanho de filial entre as empresas
Else
	nTamanho := nSizeFil
Endif

cEmp_D := Space(nSizeEmp)
cFil_D := Space(nTamanho)
Store Space(Len(SRE->RE_MATP)) To cMat_D
Store Space(nSizeSI3) To cCus_D
cEmp_O := cSvEmpAnt
cFil_O := PadR(cSvFilAnt, nTamanho)
cMat_O := Mv_par01
cCus_O := cCusAnt

If nOpcx = 1
	cTitulo := cCadastro //" - Visualizar"
ElseIf nOpcx = 2
	cTitulo := cCadastro //" - Incluir"
	lWhen := .t.
ElseIf nOpcx = 3
	cTitulo := cCadastro //" - Excluir"
EndIf

If nOpcx <> 2
	dbSelectArea(cAlias)
	DbGoto(nReg)
	dbSelectArea("SRE")
	dbSetOrder(1)
	If dbSeek(TRB->EMPD+PADR(TRB->FILIALD,TAMSX3('RE_FILIALD')[1])+TRB->MATD+dToS(TRB->DATAH))
		dDt_Tran := SRE->RE_DATA
		cEmp_O   := SRE->RE_EMPD
		cFil_O   := SRE->RE_FILIALD
		cEmp_D   := SRE->RE_EMPP
		cFil_D   := SRE->RE_FILIALP
		cMat_O   := SRE->RE_MATD
		cMat_D   := SRE->RE_MATP
		cCus_O   := SRE->RE_CCD
		cCus_D   := SRE->RE_CCP
	Endif
EndIf

nOpca := 0

DEFINE MSDIALOG oDlg FROM  50,110 TO 360,450 TITLE OemToAnsi(cTitulo) PIXEL

oDlg:lEscClose := .F.
nOpcA := 2
@002,11 SAY STR0021 SIZE 100,10 OF oDlg PIXEL //"Data da Transferência no Historico:"
@002,100 MSGET oGet VAR dDt_Tran SIZE 50 , 10 OF oDlg PIXEL	VALID (lRet:=MDT950DMVL(dDt_Tran),oGet:Refresh(),lRet) WHEN lWhen HASBUTTON

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
@ 13, 10 TO 071, 152 LABEL STR0022	  OF oDlg PIXEL //"Origem"
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

@ 22,13 SAY STR0024 Color CLR_HBLUE SIZE 33,7 OF oDlg PIXEL //"Empresa:"
@ 34,13 SAY STR0025 Color CLR_HBLUE SIZE 33,7 OF oDlg PIXEL //"Filial :"
@ 46,13 SAY STR0026 Color CLR_HBLUE SIZE 33,7 OF oDlg PIXEL //"Matrícula :"
@ 58,13 SAY STR0027 Color CLR_HBLUE SIZE 33,7 OF oDlg PIXEL //"C.Custo :"

@ 22,50 MSGET oGet11 VAR cEmp_O SIZE 010,10 OF oDlg PIXEL PICTURE "@!" F3 "YM0" VALID (lRet := CHKEMPA950(cEmp_O,1),cEmpFiltro := cEmp_O,oGet11:Refresh(),lRet) WHEN lWhen HASBUTTON

@ 34,50 MSGET oGet13 VAR cFil_O SIZE 060,10 OF oDlg PIXEL PICTURE "@!" F3 "NGXM0" VALID (lRet := CHKFILA950(cEmp_O,AllTrim(cFil_O),1),oGet13:Refresh(),lRet) WHEN lWhen HASBUTTON
oGet13:bGotFocus  := { || cEmpAnt := cEmp_O,cEmpFiltro := cEmp_O}
oGet13:bLostFocus := { || cEmpAnt := cSvEmpAnt}

@ 46,50 MSGET oGet15 VAR cMat_O SIZE 040,10 OF oDlg PIXEL PICTURE "@!" F3 "MDTSRA" VALID (lRet2 := MDTA950SRA(cMat_O,1),oGet15:Refresh(),IF(!lRet2,MDTCHANSI3(cEmp_O,AllTrim(cFil_O)),NIL),lRet2) WHEN lWhen HASBUTTON
oGet15:bGotFocus  := { || MDTCHANSI3(cEmp_O,AllTrim(cFil_O))}

@ 58,50 MSGET oGet17 VAR cCus_O SIZE (nSizeSI3*4),10 OF oDlg PIXEL PICTURE "@!" F3 cAliasCc VALID (lRet2 := MDTA950CC(cCus_O,1),oGet17:Refresh(),IF(!lRet2,MDTCHANSI3(cEmp_O,AllTrim(cFil_O)),NIL),lRet2) WHEN lWhen HASBUTTON
oGet17:bGotFocus  := { || MDTCHANSI3(cEmp_O,AllTrim(cFil_O))}

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
@ 79, 10 TO 138, 152 LABEL STR0023 OF oDlg PIXEL //"Destino"
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

@089,13 SAY STR0024 Color CLR_HBLUE SIZE 33,7 OF oDlg PIXEL //"Empresa:"
@101,13 SAY STR0025 Color CLR_HBLUE SIZE 33,7 OF oDlg PIXEL //"Filial :"
@113,13 SAY STR0026 Color CLR_HBLUE SIZE 33,7 OF oDlg PIXEL //"Matrícula :"
@125,13 SAY STR0027 Color CLR_HBLUE SIZE 33,7 OF oDlg PIXEL //"C.Custo :"

@  89,50 MSGET oGet01 VAR cEmp_D SIZE 010,10 OF oDlg PIXEL PICTURE "@!" F3 "YM0" VALID (lRet := CHKEMPA950(cEmp_D,2),cEmpFiltro := cEmp_D,oGet01:Refresh(),lRet) WHEN lWhen HASBUTTON

@ 101,50 MSGET oGet03 VAR cFil_D SIZE 060,10 OF oDlg PIXEL PICTURE "@!" F3 "NGXM0" VALID (lRet := CHKFILA950(cEmp_D,AllTrim(cFil_D),2),oGet03:Refresh(),lRet) WHEN lWhen HASBUTTON
oGet03:bGotFocus  := { || cEmpAnt := cEmp_D,cEmpFiltro := cEmp_D }
oGet03:bLostFocus := { || cEmpAnt := cSvEmpAnt }

@113,50 MSGET oGet05 VAR cMat_D SIZE 040,10 OF oDlg PIXEL PICTURE "@!" F3 "MDTSRA" VALID (lRet2 := MDTA950SRA(cMat_D,2),oGet05:Refresh(),IF(!lRet2,MDTCHANSI3(cEmp_D,AllTrim(cFil_D)),NIL),lRet2) WHEN lWhen HASBUTTON
oGet05:bGotFocus  := { || MDTCHANSI3(cEmp_D,AllTrim(cFil_D))}

@125,50 MSGET oGet07 VAR cCus_D SIZE (nSizeSI3*4),10 OF oDlg PIXEL PICTURE "@!" F3 cAliasCc VALID (lRet2 := MDTA950CC(cCus_D,2),oGet07:Refresh(),IF(!lRet2,MDTCHANSI3(cEmp_D,AllTrim(cFil_D)),NIL),lRet2) WHEN lWhen HASBUTTON
oGet07:bGotFocus  := { || MDTCHANSI3(cEmp_D,AllTrim(cFil_D))}

DEFINE SBUTTON FROM 139,085 TYPE 1 ENABLE OF oDlg ACTION (nOpcA :=1,oDlg:End())
DEFINE SBUTTON FROM 139,115 TYPE 2 ENABLE OF oDlg ACTION (nOpcA :=2,oDlg:End())
ACTIVATE MSDIALOG oDlg CENTERED VALID IIF(nOpcA == 1 .AND. nOpcx = 2,CHKFINL950(cEmp_O,cEmp_D,AllTrim(cFil_O),AllTrim(cFil_D),cMat_O,cMat_D,cCus_O,cCus_D,dDt_Tran),.T.)

MDTCHANSI3(cSvEmpAnt,cSvFilAnt) // Retorna a Empresa-Filial salva

If nOpca = 1
	MD950GRAVA(nReg,nOpcx,{cEmp_O,cEmp_D,AllTrim(cFil_O),AllTrim(cFil_D),cMat_O,cMat_D,cCus_O,cCus_D,dDt_Tran})
EndIf

Processa({||MD950TRB(nOpcx)})
If nOpcx == 1
	dbSelectArea(cAlias)
	DbGoto(nReg)
Endif
RestArea(aAreaSM0)
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MD950GRAVA³ Autor ³ Thiago Olis Machado   ³ Data ³ 23/12/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava registro SRE.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MDTA950                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MD950GRAVA(nReg,nOpca,aHist)

Local aRecordSRE := {}
dbSelectArea("TRB")
DbGoTo(nReg)

If nOpca = 2
	aAdd( aRecordSRE , { "RE_DATA"		,	aHist[9]	}	)
	aAdd( aRecordSRE , { "RE_EMPD"		,	aHist[1]	}	)
	aAdd( aRecordSRE , { "RE_FILIALD"	,	aHist[3]	}	)
	aAdd( aRecordSRE , { "RE_MATD"		,	aHist[5]	}	)
	aAdd( aRecordSRE , { "RE_CCD"		,	aHist[7]	}	)
	aAdd( aRecordSRE , { "RE_EMPP"		,	aHist[2]	}	)
	aAdd( aRecordSRE , { "RE_FILIALP"	,	aHist[4]	}	)
	aAdd( aRecordSRE , { "RE_MATP"		,	aHist[6]	}	)
	aAdd( aRecordSRE , { "RE_CCP"		,	aHist[8]	}	)
	aAdd( aRecordSRE , { "RE_FILIAL"	,	xFilial("SRE") } )

	MDTGravSRE( "SRE" , 1 , 3 , aHist[2]+PADR(aHist[4],TAMSX3('RE_FILIALD')[1])+aHist[6]+dToS(aHist[9]) , aRecordSRE )
ElseIf nOpca = 3
	MDTGravSRE( "SRE" , 1 , 5 , TRB->EMPD+PADR(TRB->FILIALD,TAMSX3('RE_FILIALD')[1])+TRB->MATD+dToS(TRB->DATAH) )
EndIf

Return .t.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MDTCHANSI3³ Autor ³Denis Hyroshi de Souza ³ Data ³ 12/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Abrir SI3 e SRA para Consulta via Tecla F3                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MDTCHANSI3(cEmpF3,cFilF3)

If Empty(cFilF3) .Or. Empty(cEmpF3)
	Return Nil
EndIf
//Somente abre tabela de outra Empresa, se for realmente alterado o campo Empresa
dbSelectArea("SM0")
IF dbSeek(cEmpF3+cFilF3)
	cEmpAnt := cEmpF3
	cFilAnt := cFilF3
	If cEmpF3 <> cTmp95Emp
		cModo := "E"
		EMP950OPEN("SRA","SRA",1,cEmpF3,@cModo,cFilF3)
		EMP950OPEN("CTT","CTT",1,cEmpF3,@cModo,cFilF3)
		//NGPrepTBL({{cAliasCc,01},{"SRA",01}},cEmpF3,cFilF3)
		cTmp95Emp := cEmpF3
		cTmp95Fil := cFilF3
		cEmpAnt   := cEmpF3
		cFilAnt   := cFilF3
	ElseIf cFilF3 <> cTmp95Fil
		cTmp95Fil := cFilF3
		cFilAnt   := cFilF3
	Endif
Else
	cFilAnt := Space( Len(cFilAnt) )
	cEmpAnt := Space( Len(cEmpAnt) )
Endif

Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CHKFILA950³ Autor ³Denis Hyroshi de Souza ³ Data ³ 12/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se existe filial                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CHKFILA950(cEmp,cFil,nTipoFil)
Local aArea    := GetArea()
Local aAreaSM0 := SM0->(GetArea())
Local lRet     := .T.
Local cTmpEmp  := cTmp95Emp
Local cTmpFil  := cTmp95Fil
Local lAltAmb  := fBackupFil(nTipoFil)

If !Empty(cFil)
	dbSelectArea("SM0")
	IF !dbSeek(cEmp+cFil)
		Help(" ",1,"REGNOIS")
		lRet := .F.
	EndIF
Endif

If nTipoFil == 1
	dbSelectArea("SM0")
	If !dbSeek(cEmp+cFil)
		cMat_O := Space( Len(cMat_O) )
		cCus_O := Space( Len(cCus_O) )
	Else
		MDTCHANSI3(cEmp,cFil) //Abre tabela na Empresa/Filial Origem
		If !Empty(cMat_O) .and. Empty( Posicione("SRA",1,xFilial("SRA")+cMat_O,"RA_MAT") )
			cMat_O := Space( Len(cMat_O) )
		Endif
		If !Empty(cCus_O) .and. Empty( Posicione(cAliasCc,1,xFilial(cAliasCc)+cCus_O,aKeyCcFilter[2]) )
			cCus_O := Space( Len(cCus_O) )
		Endif
	Endif
ElseIf nTipoFil == 2
	dbSelectArea("SM0")
	If !dbSeek(cEmp+cFil)
		cMat_D := Space( Len(cMat_D) )
		cCus_D := Space( Len(cCus_D) )
	Else
		MDTCHANSI3(cEmp,cFil) //Abre tabela na Empresa/Filial Destino
		If !Empty(cMat_D) .and. Empty( Posicione("SRA",1,xFilial("SRA")+cMat_D,"RA_MAT") )
			cMat_D := Space( Len(cMat_D) )
		Endif
		If !Empty(cCus_D) .and. Empty( Posicione(cAliasCc,1,xFilial(cAliasCc)+cCus_D,aKeyCcFilter[2]) )
			cCus_D := Space( Len(cCus_D) )
		Endif
	Endif
Endif

If lAltAmb
	MDTCHANSI3(cTmpEmp,cTmpFil) //Abre tabela na Empresa/Filial Salva
Endif

RestArea(aAreaSM0)
RestArea(aArea)
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CHKEMPA950³ Autor ³Denis Hyroshi de Souza ³ Data ³ 12/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se existe empresa                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CHKEMPA950(cEmp,nTipoEmp)
Local aArea    := GetArea()
Local aAreaSM0 := SM0->(GetArea())
Local lRet     := .T.
Local cTmpEmp  := cTmp95Emp
Local cTmpFil  := cTmp95Fil
Local lAltAmb  := fBackupFil(nTipoEmp)

If !Empty(cEmp)
	dbSelectArea("SM0")
	If !dbSeek(cEmp)
		Help(" ",1,"REGNOIS")
		lRet := .f.
	Endif
Endif

If nTipoEmp == 1
	dbSelectArea("SM0")
	If !dbSeek(cEmp+AllTrim(cFil_O))
		cFil_O := Space( Len(cFil_O) )
		cMat_O := Space( Len(cMat_O) )
		cCus_O := Space( Len(cCus_O) )
	Else
		MDTCHANSI3(cEmp,AllTrim(cFil_O)) //Abre tabela na Empresa/Filial Origem
		If !Empty(cMat_O) .and. Empty( Posicione("SRA",1,xFilial("SRA")+cMat_O,"RA_MAT") )
			cMat_O := Space( Len(cMat_O) )
		Endif
		If !Empty(cCus_O) .and. Empty( Posicione(cAliasCc,1,xFilial(cAliasCc)+cCus_O,aKeyCcFilter[2]) )
			cCus_O := Space( Len(cCus_O) )
		Endif
	Endif
ElseIf nTipoEmp == 2
	dbSelectArea("SM0")
	If !dbSeek(cEmp+AllTrim(cFil_D))
		cFil_D := Space( Len(cFil_D) )
		cMat_D := Space( Len(cMat_D) )
		cCus_D := Space( Len(cCus_D) )
	Else
		MDTCHANSI3(cEmp,AllTrim(cFil_D)) //Abre tabela na Empresa/Filial Destino
		If !Empty(cMat_D) .and. Empty( Posicione("SRA",1,xFilial("SRA")+cMat_D,"RA_MAT") )
			cMat_D := Space( Len(cMat_D) )
		Endif
		If !Empty(cCus_D) .and. Empty( Posicione(cAliasCc,1,xFilial(cAliasCc)+cCus_D,aKeyCcFilter[2]) )
			cCus_D := Space( Len(cCus_D) )
		Endif
	Endif
Endif

If lAltAmb
	MDTCHANSI3(cTmpEmp,cTmpFil) //Abre tabela na Empresa/Filial Salva
Endif

RestArea(aAreaSM0)
RestArea(aArea)
cEmpFiltro := cEmp_D

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MDTA950SRA ³ Autor ³Denis Hyroshi de Souza ³ Data ³ 12/09/03³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se existe Funcionario                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MDTA950SRA(cMatSRA,nTipoSRA)
Local aArea    := GetArea()
Local lRet     := .T.
Local cTmpEmp  := cTmp95Emp
Local cTmpFil  := cTmp95Fil
Local lAltAmb  := fBackupFil(nTipoSRA)

If !Empty(cMatSRA)
	dbSelectArea("SRA")
	dbSetOrder(1)
	IF !dbSeek(xFilial("SRA")+cMatSRA)
		Help(" ",1,"REGNOIS")
		lRet := .F.
	EndIF
Endif

If lAltAmb
	MDTCHANSI3(cTmpEmp,cTmpFil) //Abre tabela na Empresa/Filial Salva
Endif

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MDTA950CC ³ Autor ³Denis Hyroshi de Souza ³ Data ³ 12/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se existe Centro de CUsto                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MDTA950CC(cCenCust,nTipoCC)
Local aArea    := GetArea()
Local aAreaSM0 := SM0->(GetArea())
Local lRet     := .T.
Local cTmpEmp  := cTmp95Emp
Local cTmpFil  := cTmp95Fil
Local lAltAmb  := fBackupFil(nTipoCC)

If !Empty(cCenCust)
	dbSelectArea(cAliasCc)
	IF !dbSeek(xFilial(cAliasCc)+cCenCust)
		Help(" ",1,"REGNOIS")
		lRet := .F.
	EndIF
Endif

If lAltAmb
	MDTCHANSI3(cTmpEmp,cTmpFil) //Abre tabela na Empresa/Filial Salva
Endif

RestArea(aAreaSM0)
RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CHKFINL950³ Autor ³Denis Hyroshi de Souza ³ Data ³ 12/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se existe Centro de CUsto                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CHKFINL950(cOemp,cDemp,cOfil,cDfil,cOmat,cDmat,cOcc,cDcc,dDtTra)

If Empty(dDtTra)
	HELP(" ",1,"OBRIGAT",,CHR(13)+STR0036+Space(35),3) //"Data de Transferencia"
	Return .f.
ElseIf Empty(cOemp)
	HELP(" ",1,"OBRIGAT",,CHR(13)+STR0037+Space(35),3) //"Empresa Origem"
	Return .f.
ElseIf Empty(cOfil)
	HELP(" ",1,"OBRIGAT",,CHR(13)+STR0038+Space(35),3) //"Filial de Origem."
	Return .f.
ElseIf Empty(cOmat)
	HELP(" ",1,"OBRIGAT",,CHR(13)+STR0039+Space(35),3) //"Código da Matricula Origem."
	Return .f.
ElseIf Empty(cOcc)
	HELP(" ",1,"OBRIGAT",,CHR(13)+STR0040+Space(35),3) //"Centro de Custo Origem."
	Return .f.
ElseIf Empty(cDemp)
	HELP(" ",1,"OBRIGAT",,CHR(13)+STR0041+Space(35),3) //"Código da empresa Destino."
	Return .f.
ElseIf Empty(cDfil)
	HELP(" ",1,"OBRIGAT",,CHR(13)+STR0042+Space(35),3) //"Filial de Destino."
	Return .f.
ElseIf Empty(cDmat)
	HELP(" ",1,"OBRIGAT",,CHR(13)+STR0043+Space(35),3) //"Código da Matricula Destino."
	Return .f.
ElseIf Empty(cDcc)
	HELP(" ",1,"OBRIGAT",,CHR(13)+STR0044+Space(35),3) //"Centro de Custo Destino."
	Return .f.
Endif
dbSelectArea("SRE")
dbSetOrder(1)
If dbSeek(cOemp+cOfil+cOmat+DtoS(dDtTra))
	Help(" ",1,"JAGRAVADO")
	Return .f.
Endif
If cOemp==cDemp .and. cOfil==cDfil .and. cOmat==cDmat .and. cOcc==cDcc
	Help(" ",1,"EMPREIGUAL")
	Return .f.
Endif
Return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MenuDef  ³ Autor ³ Rafael Diogo Richter  ³ Data ³29/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Utilizacao de Menu Funcional.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaMDT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³    1 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    2- Inclui registros no Bancos de Dados                  ³±±
±±³          ³    3 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Local aRotina := {{STR0003,"MD950IN" , 0, 2},;     //"Visualizar"
					{STR0004   ,"MD950IN" , 0, 3},;     //"Incluir"
					{STR0006   ,"MD950IN" , 0, 6, 3}}   //"Excluir"

Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fBackupFil³ Autor ³Denis Hyroshi de Souza ³ Data ³ 12/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Backup dos campos Empresa e Filial                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fBackupFil(nTipo)
Local lRet := .f.

If nTipo == 1
	If cEmp_O <> cTmp95Emp .or. AllTrim(cFil_O) <> cTmp95Fil
		MDTCHANSI3(cEmp_O,AllTrim(cFil_O)) //Abre tabela na Empresa/Filial Origem
		lRet  := .t.
	Else
		cEmpAnt := cEmp_O
		cFilAnt := AllTrim(cFil_O)
	Endif
ElseIf nTipo == 2
	If cEmp_D <> cTmp95Emp .or. AllTrim(cFil_D) <> cTmp95Fil
		MDTCHANSI3(cEmp_D,AllTrim(cFil_D)) //Abre tabela na Empresa/Filial Destino
		lRet  := .t.
	Else
		cEmpAnt := cEmp_D
		cFilAnt := AllTrim(cFil_D)
	Endif
Endif

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MDT950DMVLºAutor  ³Roger Rodrigues     º Data ³  17/07/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida se a data informada é menor que a data de demissão doº±±
±±º          ³funcionário.                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MD950IN                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MDT950DMVL(dDataTran)
Local lRet := .T.

If dDataTran > dDataBase
	MsgStop(STR0045) //"A data informada é maior que a data atual."
	lRet := .F.
	Return lRet
EndIf
IF !Naovazio(dDataTran)
	lRet := .F.
Else
	dbSelectArea("SRA")
	dbSetOrder(1)
	If dbSeek(xFilial("SRA")+mv_par01)
		If SRA->RA_DEMISSA < dDataTran .and. !Empty(SRA->RA_DEMISSA)
			lRet := MsgYesNo(STR0028,STR0029)//"A data informada é maior que a data de demissão do funcionário. Deseja incluir o registro mesmo assim?"##"Atenção"
		Endif
	Endif
Endif


Return lRet
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³EMP950OPEN³ Autor ³Taina Alberto Cardoso  ³ Data ³ 27/07/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Abre arquivo de outra empresa                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function EMP950OPEN(cAlias1,cAlias2,nIndice,MvEmpresa,cMd,MvFilial)
Local nAT := 0
Default nIndice := 1
Default cAlias1 := Alias()
Default cAlias2 := Alias()
Default MvEmpresa := cEmpAnt
Default cMd := If(FindFunction("FWModeAccess"),FWModeAccess(Alias()),If(Empty(xFilial(Alias())),"C","E"))
Default MvFilial  := cSvFilAnt

//Restaura variaveis para alteracao da tabela
dbSelectArea("SM0")
dbSeek(cEmpPPP+cSvFilAnt)
cEmpAnt := cEmpPPP
cFilAnt := cSvFilAnt

UniqueKey( NIL , cAlias1 , .T. )
EmpOpenFile(cAlias2,cAlias1,nIndice,.t.,MvEmpresa,@cMd)   // Abre arquivo da empresa selecionada
nAT := AT(cAlias1,cArqTab)
IF nAT > 0
	cArqTab := Subs(cArqTab,1,nAT+2)+cMd+Subs(cArqTab,nAT+4)
EndIF

cArqTab := Subs(cArqTab,1,nTamTable)

//Altera variaveis para o xFilial
dbSelectArea("SM0")
dbSeek(MvEmpresa+MvFilial)
cEmpAnt := MvEmpresa
cFilAnt := MvFilial

Return .t.