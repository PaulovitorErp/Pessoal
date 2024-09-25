#INCLUDE "SGAA530.ch"
#include "protheus.ch"
#include "MSOLE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSGAA530   บAutor  ณRoger Rodrigues     บ Data ณ  30/03/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para Composicao de Carga e Emissao do MTR - Manifestoบฑฑ
ฑฑบ          ณdo Transporte           	       							  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGASGA                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SGAA530()
Local aNGBEGINPRM := NGBEGINPRM( )
Private aRotina   := MenuDef()
Private cCadastro := OemToAnsi(STR0001) //"Composi็ใo de Carga para Transporte"

//Verifica se o Update de FMR esta aplicado
If !SGAUPDFMR()
	Return .F.
Endif

dbSelectArea("TDI")
mBrowse( 6, 1,22,75,"TDI",,,,,,SG530SEMAF())

NGRETURNPRM(aNGBEGINPRM)
Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ MenuDef  ณ Autor ณRoger Rodrigues        ณ Data ณ30/03/2011ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณUtilizacao de Menu Funcional.                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SigaSGA                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณArray com opcoes da rotina.                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณParametros do array a Rotina:                               ณฑฑ
ฑฑณ          ณ1. Nome a aparecer no cabecalho                             ณฑฑ
ฑฑณ          ณ2. Nome da Rotina associada                                 ณฑฑ
ฑฑณ          ณ3. Reservado                                                ณฑฑ
ฑฑณ          ณ4. Tipo de Transao a ser efetuada:                        ณฑฑ
ฑฑณ          ณ	  1 - Pesquisa e Posiciona em um Banco de Dados           ณฑฑ
ฑฑณ          ณ    2 - Simplesmente Mostra os Campos                       ณฑฑ
ฑฑณ          ณ    3 - Inclui registros no Bancos de Dados                 ณฑฑ
ฑฑณ          ณ    4 - Altera o registro corrente                          ณฑฑ
ฑฑณ          ณ    5 - Remove o registro corrente do Banco de Dados        ณฑฑ
ฑฑณ          ณ5. Nivel de acesso                                          ณฑฑ
ฑฑณ          ณ6. Habilita Menu Funcional                                  ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function MenuDef()
Local aRotina :=	{	{ STR0002	, "AxPesqui"	, 0 , 1},; //"Pesquisar"
						{ STR0003	, "SG530INC"	, 0 , 2},; //"Visualizar"
						{ STR0004	, "SG530INC"	, 0 , 3},; //"Incluir"
						{ STR0005	, "SG530INC"	, 0 , 4},; //"Alterar"
						{ STR0006	, "SG530INC"	, 0 , 5, 3},; //"Excluir"
						{ STR0007	, "SG530MAN"	, 0 , 4},; //"Manifesto"
						{ STR0008	, "SG530DOT"	, 0 , 7},; //"Relatorio"
						{ STR0009	, "SG530LEG"	, 0 , 8}} //"Legenda"

Return aRotina
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSG530SEMAFบAutor  ณRoger Rodrigues     บ Data ณ  30/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefine cores do semaforo no browse                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SG530SEMAF()
Local aCores := {	{"TDI->TDI_STATUS == '1'" , "BR_VERMELHO" },;
					{"TDI->TDI_STATUS == '2'" , "BR_AMARELO"},;
					{"TDI->TDI_STATUS == '3'" , "BR_VERDE" },;
					{"TDI->TDI_STATUS == '4'" , "BR_PRETO" }}
Return aCores

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSG530LEG  บAutor  ณRoger Rodrigues     บ Data ณ  30/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria janela com explicao da legenda                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SG530LEG()
BrwLegenda(cCadastro,STR0009,{	{"BR_VERMELHO",STR0010},; //"Legenda"###"Em Elabora็ใo"
									{"BR_AMARELO" ,STR0011},; //"Expedi็ใo"
									{"BR_VERDE"   ,STR0012},; //"Finalizado"
									{"BR_PRETO"   ,STR0013}}) //"Cancelado"

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSG530INC  บAutor  ณRoger Rodrigues     บ Data ณ  30/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTela de Composicao de Carga                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SG530INC(cAlias, nRecno, nOpcx)
Local oDlg, oEnchoice
Local nY, nX
Local aChoice  := {"TDI_CODCOM","TDI_CODRES","TDI_DESCRE","TDI_DTCOMP","TDI_HRCOMP","TDI_PESOTO","TDI_PESOBA",;
						"TDI_UNIDAD","TDI_DESEST","TDI_UNIBAL","NOUSER"}//NOUSER para nao mostrar campos do usuario

Local aPos     := {0,0,65,0}
Local lInverte := .F.
Local lConfirma:= .F.
Local lNoFolder:= .T.
Local aButtons := {}
Local cMarca   := GetMark()
Local aTDI     := {}

//Variแveis de Objeto
Local oPnlAll
Local oPnlEnc
Local oPnlTop, oPnlTLeft, oPnlTRight
Local oPnlMrk
Local oTempDIS, oTempSEL

Private cTRBDIS, cTRBSEL
Private aDBF530   := {}
Private aVetInr   := {}
Private cCadastro := STR0001 //"Composi็ใo de Carga para Transporte"
Private aSize := MsAdvSize(,.f.,430), aObjects := {}
Aadd(aObjects,{050,050,.t.,.t.})
Aadd(aObjects,{100,100,.t.,.t.})
aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}

//Declara variaveis Inclui, Altera, Visual, Exclui
aRotSetOpc( cAlias , nRecno , nOpcx , .F. )

//Carrega na memoria variaveis
dbSelectArea(cAlias)
dbSelectArea(1)
RegtoMemory(cAlias,Inclui)

//Cria estrutura do MsSelect
aAdd(aTDI,{ "TRB_OK"	, Nil ," ",})
aAdd(aTDI,{ "TRB_CODOCO", Nil ,RetTitle("TDJ_CODOCO")})
aAdd(aTDI,{ "TRB_PESOTO", Nil ,RetTitle("TDJ_PESOUT")})
aAdd(aTDI,{ "TRB_DATA"  , Nil ,RetTitle("TB0_DATA")})

aAdd(aDBF530,{ "TRB_OK"		, "C" ,2, 0 })
aAdd(aDBF530,{ "TRB_CODOCO"	, "C" ,TAMSX3("TDJ_CODOCO")[1], 0 })
aAdd(aDBF530,{ "TRB_PESOTO"	, "N" ,TAMSX3("TDJ_PESOUT")[1], TAMSX3("TDJ_PESOUT")[2] })
aAdd(aDBF530,{ "TRB_DATA"	, "D" ,TAMSX3("TB0_DATA")[1]  , TAMSX3("TB0_DATA")[2] })

cTRBDIS := GetNextAlias()
cTRBSEL := GetNextAlias()

//Cria TRB utilizando estrutura acima
oTempDIS := FWTemporaryTable():New( cTRBDIS, aDBF530 )
oTempDIS:AddIndex( "1", {"TRB_CODOCO"} )
oTempDIS:Create()

oTempSEL := FWTemporaryTable():New( cTRBSEL, aDBF530 )
oTempSEL:AddIndex( "1", {"TRB_CODOCO"} )
oTempSEL:Create()

If !Inclui
	If Altera
		If M->TDI_STATUS != "1"
			MsgStop(STR0014) //"Nใo ้ possํvel alterar Composi็๕es com status diferente de 'Em labora็ใo'"
			Return .F.
		EndIf
	EndIf
	If nOpcx == 5
		If M->TDI_STATUS <> "1" .AND. M->TDI_STATUS <> "2"
			MsgStop(STR0015) //"Nใo ้ possํvel excluir Composi็๕es com status diferente de 'Em Elabora็ใo' e 'Expedi็ใo'"
			Return .F.
		Endif
	Endif
	SG530RES()
EndIf
If Inclui .or. Altera
	aAdd(aButtons, {"RECALC", { || SG530QTD() }, STR0016+" - < F4 >", STR0080 } ) //"Alterar quantidade destinada"###"Alt. Qtde."
	SetKey( VK_F4 , { || SG530QTD() } )
Endif

DEFINE MsDIALOG oDlg FROM aSize[7],0 To aSize[6],aSize[5] TITLE cCadastro Of oMainWnd COLOR CLR_BLACK,CLR_WHITE Pixel

	oPnlAll := TPanel():New(01,01,,oDlg,,,,,,10,10,.F.,.F.)
		oPnlAll:Align := CONTROL_ALIGN_ALLCLIENT

		oPnlEnc := TPanel():New(0,0,,oPnlAll,,,,,CLR_WHITE,0,65,.F.,.F.)
			oPnlEnc:Align := CONTROL_ALIGN_TOP

			oEnchoice := MsmGet():New(cAlias, nRecno, nOpcx,,,,aCHOICE,aPos,,3,,,,oPnlEnc,,,,,lNoFolder)
				oEnchoice:oBox:Align := CONTROL_ALIGN_ALLCLIENT

		oPnlTop := TPanel():New(0,0,,oPnlAll,,,,,CLR_WHITE,0,10,.F.,.F.)
			oPnlTop:Align := CONTROL_ALIGN_TOP

			oPnlTLeft := TPanel():New(0,0,,oPnlTop,,,,,CLR_WHITE,323,0,.F.,.F.)
				oPnlTLeft:Align := CONTROL_ALIGN_LEFT

				TSay():New(0,000,{||STR0017} ,oPnlTLeft,,,,,,.T.,CLR_HBLUE,CLR_WHITE,200,20) //'Disponํveis'

			oPnlTRight := TPanel():New(0,0,,oPnlTop,,,,,CLR_WHITE,0,10,.F.,.F.)
				oPnlTRight:Align := CONTROL_ALIGN_ALLCLIENT

				TSay():New(0,000,{||STR0018},oPnlTRight,,,,,,.T.,CLR_HBLUE,CLR_WHITE,200,20) //'Selecionadas'

		oPnlMrk := TPanel():New(0,0,,oPnlAll,,,,,CLR_WHITE,0,10,.F.,.F.)
			oPnlMrk:Align := CONTROL_ALIGN_ALLCLIENT

			oMarkDis := MsSelect():New(cTRBDIS,"TRB_OK",,aTDI,@lInverte,@cMarca,{0,0,50,310},,,oPnlMrk,,)
			oMarkDis:oBrowse:Align := CONTROL_ALIGN_LEFT
			If Str(nOpcx,1) $ "2/5"
				oMarkDis:bMark := { || ClearMark(cTRBDIS, cMarca) }
			Else
				oMarkDis:oBrowse:bAllMark := { || SG530INV(cMarca,cTRBDIS) }
			EndIf
			oPnlBtn := TPanel():New(0,0,,oPnlMrk,,,,,CLR_WHITE,13,0,.F.,.F.)
				oPnlBtn:Align := CONTROL_ALIGN_LEFT

			@ 165 ,0 BTNBMP oBtnNext Resource "PGNEXT" Size 29,29 Pixel Of oPnlBtn Noborder Pixel Action fTrocaOco(cTRBDIS,cTRBSEL,.T.) WHEN Inclui .Or. Altera
			@ 195 ,0 BTNBMP oBtnNext Resource "PGPREV" Size 29,29 Pixel Of oPnlBtn Noborder Pixel Action fTrocaOco(cTRBSEL,cTRBDIS,.F.) WHEN Inclui .Or. Altera

			oMarkSel := MsSelect():New(cTRBSEL,"TRB_OK",,aTDI,@lInverte,@cMarca,{0,0,50,310},,,oPnlMrk,,)
			oMarkSel:oBrowse:Align := CONTROL_ALIGN_RIGHT
			If Str(nOpcx,1) $ "2/5"
				oMarkSel:bMark := { || ClearMark( cTRBSEL , cMarca ) }
			Else
				oMarkSel:oBrowse:bAllMark := { || SG530INV(cMarca,cTRBSEL) }
			EndIf

ACTIVATE MsDIALOG oDlg ON INIT EnchoiceBar(@oDlg,{|| lConfirma := .T.,If(ValTudOK(oEnchoice),oDlg:End(),lConfirma := .F.)},;
													{|| lConfirma := .F.,oDlg:End()},,aButtons) CENTERED

If lConfirma
	If Inclui .Or. Altera
		If Inclui
			ConfirmSX8()
		EndIf
		dbSelectArea("TDI")
		RecLock("TDI",Inclui)
		For nY := 1 To Fcount()
			nX := "M->" + FieldName(nY)

			If "_FILIAL"$Upper(nX)
				FieldPut(nY, xFilial('TDI'))
			Else
				FieldPut(nY, &nX.)
			EndIf
		Next nY
		TDI->TDI_DTALTE := dDataBase
		TDI->TDI_HRALTE := Substr(Time(),1,5)
		TDI->TDI_STATUS := "1"
		MsUnLock("TDI")

		dbSelectArea("TDJ")
		dbSetOrder(1)
		dbSeek(xFilial("TDJ")+M->TDI_CODCOM)
		While !Eof() .And. TDJ->TDJ_FILIAL+TDJ->TDJ_CODCOM == xFilial("TDJ")+M->TDI_CODCOM
			//Restaura carga da ocorrencia
			dbSelectArea("TB0")
			dbSetOrder(1)
			If dbSeek(xFilial("TB0")+TDJ->TDJ_CODOCO)
				RecLock("TB0",.F.)
				TB0->TB0_QTDDES -= TDJ->TDJ_PESOUT
				MsUnlock("TB0")
			Endif
			RecLock("TDJ",.F.)
			dbDelete()
			MsUnLock("TDJ")
			dbSelectArea("TDJ")
			dbSkip()
		End

		dbSelectArea(cTRBSEL)
		dbGoTop()
		While !Eof()
			//Altera carga da ocorrencia
			dbSelectArea("TB0")
			dbSetOrder(1)
			If dbSeek(xFilial("TB0")+(cTRBSEL)->TRB_CODOCO)
				RecLock("TB0",.F.)
				TB0->TB0_QTDDES += (cTRBSEL)->TRB_PESOTO
				MsUnlock("TB0")
			Endif
			RecLock("TDJ",.T.)
			TDJ->TDJ_FILIAL := xFilial("TDJ")
			TDJ->TDJ_CODCOM := M->TDI_CODCOM
			TDJ->TDJ_CODOCO := (cTRBSEL)->TRB_CODOCO
			TDJ->TDJ_PESOUT := (cTRBSEL)->TRB_PESOTO
			MsUnLock()
			dbSelectArea(cTRBSEL)
			dbSkip()
		End
	ElseIf EXCLUI
		lRet := .T.
		//Exclui pedido de venda caso exista
		If !Empty(M->TDI_NUM)
			lRet := .F.
			dbSelectArea("SC6")
			dbSetOrder(1)
			If dbSeek(xFilial("SC6")+M->TDI_NUM+"01"+M->TDI_CODRES)
				dbSelectArea("SC9")
				dbSetOrder(1)
				If dbSeek(xFilial("SC9")+M->TDI_NUM+"01"+"01"+M->TDI_CODRES)
					a460Estorna()
				Endif
			Endif
			GeraPedVend(5)
		Endif
		If lRet
			dbSelectArea("TDI")
			dbSetOrder(1)
			If dbSeek(xFilial("TDI")+M->TDI_CODCOM)
				RecLock("TDI",.F.)
				dbDelete()
				MsUnLock("TDI")
			EndIf

			dbSelectArea("TDJ")
			dbSetOrder(1)
			dbSeek(xFilial("TDJ")+M->TDI_CODCOM)
			While !Eof() .And. TDJ->TDJ_FILIAL+TDJ->TDJ_CODCOM == xFilial("TDJ")+M->TDI_CODCOM
				//Restaura carga da ocorrencia
				dbSelectArea("TB0")
				dbSetOrder(1)
				If dbSeek(xFilial("TB0")+TDJ->TDJ_CODOCO)
					RecLock("TB0",.F.)
					TB0->TB0_QTDDES -= TDJ->TDJ_PESOUT
					MsUnlock("TB0")
				Endif
				RecLock("TDJ",.F.)
				dbDelete()
				MsUnLock("TDJ")
				dbSelectArea("TDJ")
				dbSkip()
			End
		Endif
	EndIf
Else
	If Inclui
		RollBackSX8()
	EndIf
EndIf

SetKey( VK_F4,Nil )

//Deleta tabelas temporarias
oTempDIS:Delete()
oTempSEL:Delete()

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณValTudOK   ณAutorณRoger Rodrigues         ณ Data ณ31/03/2011ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณValida tela de Composi็ใo da Carga para Transporte          ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณSGAA530                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ValTudOK(oEnchoice)

	Local aPeso := TamSX3("TDI_PESOTO")
	Local aAreaSEL := (cTRBSEL)->(GetArea())

	Local lRet := .T.

	Local nMaxPesoT

	If !Obrigatorio( oEnchoice:aGets , oEnchoice:aTela )
		Return .F.
	EndIf

	dbSelectArea(cTRBSEL)
	dbGoTop()
	If Eof()
		ShowHelpDlg(STR0019,{STR0020},1,{STR0021}) //"Aten็ใo"###"Pelo menos uma Ocorr๊ncia deve ser selecionada."###"Passe uma Ocorr๊ncia para o browse 'Selecionadas'."
		lRet := .F.
	EndIf

	//Recebe o tamanho atual do campo e verifica se ele possui numeros decimais para ajustar o tamanho correto do campo.
	aPeso[1] := If(aPeso[2] > 0, aPeso[1] - aPeso[2] - 1, aPeso[1])
	nMaxPesoT := Val(Replicate("9",aPeso[1]) + "." + Replicate("9",aPeso[2]))

	If M->TDI_PESOTO > nMaxPesoT
		ShowHelpDlg(STR0019,{STR0081},1,{STR0082}) //"Aten็ใo"###"O valor ultrapassa o limite do Peso Total"###"Selecionar ocorr๊ncias onde a soma nใo ultrapasse o limite do campo Peso Total."
		lRet := .F.
	EndIf

	RestArea(aAreaSEL)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณSG530RES  ณAutorณRoger Rodrigues          ณ Data ณ31/03/2011ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณCarrega TRBs da Composi็ใo da Carga para Transporte         ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณSGAA530                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function SG530RES()
Local cQuery
Local cCodRes

cCodRes := M->TDI_CODRES

dbSelectArea("TAX")
dbSetOrder(1)
If !dbSeek(xFilial("TAX")+cCodRes)
	HELP(" ",1,"REGNOIS")
	Return .F.
EndIf

M->TDI_PESOTO := 0
dbSelectArea(cTRBSEL)
dbGoTop()
While !Eof()
	dbDelete()
	dbSkip()
End

If !INCLUI
	cQuery := " SELECT TDJ_CODOCO AS TRB_CODOCO, TDJ_PESOUT AS TRB_PESOTO, TB0_DATA AS TRB_DATA FROM " + RetSqlName("TDJ") + " TDJ"
	cQuery += " INNER JOIN " + RetSqlName( "TB0" ) + " TB0 ON TB0.TB0_FILIAL = " + ValToSQl( xFilial("TB0") ) + " AND TB0.TB0_CODOCO = TDJ.TDJ_CODOCO AND TB0.D_E_L_E_T_ <> '*' "
	cQuery += " WHERE TDJ_FILIAL = "+ValToSql(xFilial("TDJ"))+" AND TDJ_CODCOM = "+ValToSql(M->TDI_CODCOM)+" AND TDJ.D_E_L_E_T_ = '' "

	SqlToTrb(cQuery,aDBF530,cTRBSEL)

	dbSelectArea(cTRBSEL)
	dbGoTop()
	While !Eof()
		M->TDI_PESOTO += (cTRBSEL)->TRB_PESOTO
		dbSkip()
	End
EndIf

dbSelectArea(cTRBDIS)
dbGoTop()
While !Eof()
	dbDelete()
	dbSkip()
End

cQuery := " SELECT TB0.TB0_CODOCO AS TRB_CODOCO, (TB0.TB0_QTDE-TB0.TB0_QTDDES) AS TRB_PESOTO, TB0_DATA AS TRB_DATA FROM " + RetSqlName("TB0") + " TB0"
cQuery += " WHERE TB0.TB0_FILIAL = "+ValToSql(xFilial("TB0"))+" AND TB0.TB0_CODRES = "+ValToSql(cCodRes)
cQuery += " AND TB0.TB0_QTDE > TB0.TB0_QTDDES AND TB0.D_E_L_E_T_ = '' "

SqlToTrb(cQuery,aDBF530,cTRBDIS)

(cTRBSEL)->(dbGoTop())
(cTRBDIS)->(dbGoTop())
If INCLUI
	oMarkDis:oBrowse:Refresh()
	oMarkSel:oBrowse:Refresh()
EndIf
lRefresh := .T.
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun็ใo    ณSG530INV ณ Autor ณRoger Rodrigues         ณ Data ณ31/03/2011ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri็ใo ณInverte marcacoes                                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso      ณSGAA530                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SG530INV(cMARCA,cTRB)
Local nRecno

dbSelectArea(cTRB)
nRecno := Recno()
DbGoTop()
While !Eof()
   (cTRB)->TRB_OK := If(!Empty((cTRB)->TRB_OK) ," ",cMARCA)
   DbSkip()
End

DbGoTo(nRecno)
lREFRESH := .T.
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณfTrocaOco ณ Autor ณRoger Rodrigues        ณ Data ณ31/03/2011ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณPassa as ocorrencias de um lado para outro da tela          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso      ณSGAA530                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fTrocaOco(cTRBDe,cTRBPara,lSoma)

dbSelectArea(cTRBDe)
dbGoTop()
While !Eof()
	If !Empty((cTRBDe)->TRB_OK)
		dbSelectArea(cTRBPara)
		dbSetOrder(1)
		If dbSeek((cTRBDe)->TRB_CODOCO)
			RecLock(cTRBPara,.F.)
			(cTRBPara)->TRB_PESOTO += (cTRBDe)->TRB_PESOTO
		Else
			RecLock(cTRBPara,.T.)
			(cTRBPara)->TRB_OK     := (cTRBDe)->TRB_OK
			(cTRBPara)->TRB_CODOCO := (cTRBDe)->TRB_CODOCO
			(cTRBPara)->TRB_PESOTO := (cTRBDe)->TRB_PESOTO
			(cTRBPara)->TRB_DATA   := (cTRBDe)->TRB_DATA
		EndIf
		MsUnLock()

		M->TDI_PESOTO := M->TDI_PESOTO +If(lSoma,+(cTRBDe)->TRB_PESOTO,-(cTRBDe)->TRB_PESOTO)

		dbSelectArea(cTRBDe)
		dbDelete()
	EndIf
	dbSkip()
End

dbSelectArea(cTRBDe)
dbGoTop()
dbSelectArea(cTRBPara)
dbGoTop()
oMarkDis:oBrowse:Refresh()
oMarkSel:oBrowse:Refresh()
lRefresh := .T.
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSG530QTD  บAutor  ณRoger Rodrigues     บ Data ณ  31/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAltera quantidade do residuo utilizada na composicao        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SG530QTD()
Local aArea := GetArea()
Local oDlgQtd
Local nOldQtd:= 0
Private lRet := .F., nQtd := 0

dbSelectArea(cTRBSEL)
If Eof()
	ShowHelpDlg(STR0019,{STR0022},1,{STR0023}) //"Aten็ใo"###"Nใo existe nenhuma ocorr๊ncia selecionada."###"Favor selecionar uma ocorr๊ncia no Browse 'Selecionadas'."
	Return .F.
Endif

nQtd := nOldQtd := (cTRBSEL)->TRB_PESOTO

DEFINE MSDIALOG oDlgQtd FROM  0,0 TO 100,230 TITLE OemToAnsi(STR0016) PIXEL //"Alterar Quantidade Destinada"

@ 12,05 Say STR0024 of oDlgQtd Pixel //"Quantidade:"
@ 10,45 MsGet oQtd Var nQtd Size 50,8 of oDlgQtd Pixel Picture PesqPict("TDJ","TDJ_PESOUT") Valid fValQtdRes((cTRBSEL)->TRB_CODOCO) HasButton

DEFINE SBUTTON FROM 35,50  TYPE 1 ENABLE OF oDlgQtd ACTION EVAL({|| If(fValQtdRes((cTRBSEL)->TRB_CODOCO,nQtd),(lRet := .T.,oDlgQtd:END()),lRet := .F.)})
DEFINE SBUTTON FROM 35,80 TYPE 2 ENABLE OF oDlgQtd ACTION oDlgQtd:END()

ACTIVATE MSDIALOG oDlgQtd CENTERED

If lRet
	//Altera peso nos selecionados
	dbSelectArea(cTRBSEL)
	RecLock(cTRBSEL,.F.)
	(cTRBSEL)->TRB_PESOTO := nQtd
	MsUnlock(cTRBSEL)

	//Joga resto para outro Mark
	dbSelectArea(cTRBDIS)
	dbSetOrder(1)
	If dbSeek((cTRBSEL)->TRB_CODOCO)
		RecLock(cTRBDIS,.F.)
		If ((cTRBDIS)->TRB_PESOTO + (nOldQtd - nQtd)) > 0
			(cTRBDIS)->TRB_PESOTO += (nOldQtd - nQtd)
		Else
			dbDelete()
		EndIf
		MsUnlock(cTRBDIS)
	ElseIf nOldQtd > nQtd //Se os pesos forem iguais, nao adiciona no Mark
		RecLock(cTRBDIS,.T.)
		(cTRBDIS)->TRB_PESOTO := (nOldQtd - nQtd)
		(cTRBDIS)->TRB_CODOCO := (cTRBSEL)->TRB_CODOCO
		(cTRBDIS)->TRB_DATA   := (cTRBSEL)->TRB_DATA
		MsUnlock(cTRBDIS)
	EndIf

	//Atualiza peso total
	M->TDI_PESOTO := M->TDI_PESOTO-(nOldQtd - nQtd)
	oMarkDis:oBrowse:Refresh()
	oMarkSel:oBrowse:Refresh()
	lRefresh := .T.
Endif

RestArea(aArea)
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfValQtdResบAutor  ณRoger Rodrigues     บ Data ณ  01/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida quantidade digitada                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fValQtdRes(cOcor,nQtde)
Local lRet := .T.
Default nQtde := nQtd
lRet := Positivo(nQtde) .and. NaoVazio(nQtde)
//Verifica se existe quantidade disponivel
If lRet
	dbSelectArea("TB0")
	dbSetOrder(1)
	If dbSeek(xFilial("TB0")+cOcor)
		If TB0->TB0_QTDE < nQtde   //(TB0->TB0_QTDE-TB0->TB0_QTDDES) = 0
			ShowHelpDlg(STR0019,{STR0025},1,; //"Aten็ใo"###"A quantidade digitada ultrapassa a disponํvel para composi็ใo da carga."
									{STR0026+AllTrim(Str((TB0->TB0_QTDE)))+"."}) //"Informe uma quantidade menor ou igual a "
			lRet := .F.
		Endif
	Endif
Endif
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSG530MAN  บAutor  ณRoger Rodrigues     บ Data ณ  01/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTela para montagem do Manifesto do Transporte               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SG530MAN(cAlias, nRecno, nOpcx)

	Local nOpca, nY, nX, nC, i, k
	Local aSize    := MsAdvSize(,.f.,430)
	Local aInfo    := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	Local aObjects := { {050,050,.t.,.t.},{100,100,.t.,.t.}}
	Local aPosObj  := MsObjSize(aInfo, aObjects,.t.)
	Local aArea

	Private lIntFat  := (SuperGetMv("MV_NGSGAFA",.F.,"2") == "1")
	Private lIntEst  := (SuperGetMv("MV_NGSGAES",.F.,"N") != "N")
	Private aTrocaF3 := {}
	Private cStatus  := TDI->TDI_STATUS

	//Variaveis da Getdados
	Private oGetTran, cGetWhlVei := ""
	Private cCodTrans  := ""//Variavel para filtragem no F3 de veiculos

	nOpcx := 4
	SetAltera()
	RegtoMemory(cAlias,.F.)

	If M->TDI_TPDEST == "2"
		aTrocaF3 := {{"TDI_FORNNF","SA1"}}
	Endif
	If M->TDI_STATUS == "3" .OR. M->TDI_STATUS == "4"
		nOpcx := 2
		//Declara variaveis Inclui, Altera, Visual, Exclui
		aRotSetOpc( cAlias , nRecno , nOpcx , .F. )
	Endif

	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL
		oEnchoice := Msmget():New(cAlias, nRecno, nOpcx ,,,,,aPosObj[1],,3)

		//Monta GetDados
		cGetWhlVei := "TDK->TDK_FILIAL == '"+xFilial("TDK")+"' .AND. TDK->TDK_CODCOM == '"+TDI->TDI_CODCOM+"'"
		FillGetDados( nOpcx, "TDK", 1, "TDI->TDI_CODCOM", {|| }, {|| .T.},{"TDK_CODCOM"},,,,{|| NGMontaAcols("TDK", TDI->TDI_CODCOM,cGetWhlVei)})

		If Empty(aCols)
			aCols := BlankGetD(aHeader)
		EndIf

		oGetTran  := MSGetDados():New(13,1,aSize[6]/4,aSize[5],If(M->TDI_STATUS != "1",2,3),"SG530LOK()","AllWaysTrue()","",.T., , , ,300, , , , ,oEnchoice:oBox:aDialogs[3])
		oGetTran:oBrowse:Align := CONTROL_ALIGN_BOTTOM
		oGetTran:oBrowse:Refresh()

		PutFileInEof("TDM")
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca:=1,If(!ValManifesto(oEnchoice,nOpcx),nOpca := 0,oDlg:End())},;
																	{||oDlg:End()},AlignObject(oDlg,{oEnchoice:oBox},1))

	If nOpca == 1
		dbSelectArea(cAlias)
		RecLock(cAlias,.F.)
		For nY := 1 To FCount()
			nC := "M->" + FieldName(nY)
			FieldPut(nY, &nC.)
		Next nY
		TDI->TDI_DTALTE := dDataBase
		TDI->TDI_HRALTE := Substr(Time(),1,5)
		MsUnLock("TDI")

		nPosCod := gdFieldPos("TDK_CODVEI")
		//Grava Responsแveis
		For i:=1 to Len(aCols)
			If aCols[i][Len(aCols[i])] .and. !Empty(aCols[i][nPosCod])
				dbSelectArea("TDK")
				dbSetOrder(1)
				If dbSeek(xFilial("TDK")+TDI->TDI_CODCOM+aCols[i][nPosCod])
					RecLock("TDK",.F.)
					dbDelete()
					MsUnlock("TDK")
				Endif
			ElseIf !Empty(aCols[i][nPosCod])
				dbSelectArea("TDK")
				dbSetOrder(1)
				If dbSeek(xFilial("TDK")+TDI->TDI_CODCOM+aCols[i][nPosCod])
					RecLock("TDK",.F.)
				Else
					RecLock("TDK",.T.)
				Endif
				For k:=1 to FCount()
					If "_FILIAL"$Upper(FieldName(k))
						FieldPut(k, xFilial("TDK"))
					Elseif "_CODCOM"$Upper(FieldName(k))
						FieldPut(k, TDI->TDI_CODCOM)
					ElseIf (nPosCpo := gdFieldPos(FieldName(k))) > 0
						FieldPut(k, aCols[i][nPosCpo])
					Endif
				Next k
				MsUnlock("TDK")
			Endif
		Next i

		//Atualiza Ocorrencias e FMRS
		If TDI->TDI_STATUS == "3" .and. cStatus != "3"
			Processa({ |lEnd| A530HISTFMR("7") })
		Endif
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSG530EXMTRบAutor  ณRoger Rodrigues     บ Data ณ  04/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se o numero digitado do MTR ja existe              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SG530EXMTR(cNumMTR,nRecno)
Local aAreaTDI := TDI->(GetArea())
Local lRet := .T.
Default cNumMTR := &(ReadVar())
Default nRecno  := TDI->(Recno())

dbSelectArea("TDI")
dbSetOrder(3)
dbSeek(xFilial("TDI")+cNumMTR)
While xFilial("TDI")+cNumMTR == TDI->TDI_FILIAL+TDI->TDI_NUMMTR
	If TDI->TDI_STATUS != "4" .And. nRecno <> Recno()
		Help(" ",1, "JAGRAVADO")
		lRet := .F.
		Exit
	Endif
	dbSelectArea("TDI")
	dbSkip()
End
dbSelectArea("TDI")
dbGoTo(nRecno)
RestArea(aAreaTDI)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณValManifesto บAutor  ณRoger Rodrigues  บ Data ณ  14/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida manifesto                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ValManifesto(oEnchoice,nOpcx)

	Local lEstAuto := SuperGetMv( 'MV_NGSGAES', .F., 'N' ) == 'S'

	Local nX
	Local nPosCod := gdFieldPos("TDK_CODVEI")
	Local nPosDel := Len(aHeader)+1
	Local nPeso := 0.00, nMTRPeso := 0.00

	If lEstAuto .And. !SgaCodMov() // Verifica o preenchimento dos parโmtros MV_SGADEV e MV_SGAREQ
		Return .F.
	EndIf

	If nOpcx == 2
		Return .T.
	Endif
	If !Obrigatorio(oEnchoice:aGets,oEnchoice:aTela)
		Return .F.
	EndIf

	If aScan(aCols, {|x| !Empty(x[nPosCod]) .and. !x[nPosDel]}) == 0
		ShowHelpDlg(STR0019,{STR0027},1,{STR0028}) //"Aten็ใo"###"Deve ser informado pelo menos um Veํculo utilizado pelo Manifesto."###"Favor informar um Veํculo na aba Transportador."
		Return .F.
	EndIf
	//Verfifica se estแ dentro do limite de peso
	If M->TDI_STATUS == "2"
		For nX := 1 To Len(aCols)
			If !aTail(aCols[nX]) .And. !Empty(aCols[nX][nPosCod])
				dbSelectArea("DA3")
				dbSetOrder(1)
				If dbSeek(xFilial("DA3")+aCols[nX][nPosCod])
					nPeso += DA3->DA3_CAPACM
				Endif
			EndIf
		Next nX
		nMTRPeso := M->TDI_PESOBA
		If M->TDI_UNIBAL == "2"
			nMTRPeso := M->TDI_PESOBA/1000
		ElseIf M->TDI_UNIBAL == "3"
			nMTRPeso := 0
			dbSelectArea("TAX")
			dbSetOrder(1)
			If dbSeek(xFilial("TAX")+M->TDI_CODRES)
				If Empty(TAX->TAX_DENSID)
					nMTRPeso := 0
					ShowHelpDlg(STR0019,{STR0029},; //"Aten็ใo"###"Nใo foi definida a Densidade do Resํduo, portanto nใo serแ possํvel verificar se o peso do Manifesto ultrapassa a capacidade dos Veํculos."
									1,{STR0030}) //"Preencha a Densidade do Resํduo na rotina de Defini็ใo de Resํduos."
				Else
					nMTRPeso := ((TAX->TAX_DENSID*M->TDI_PESOBA)/1000)
				Endif
			Endif
		Endif
		If nMTRPeso > 0
			If nMTRPeso > nPeso
				ShowHelpDlg(STR0019,{STR0031}) //"Aten็ใo"###"O peso da balan็a do MTR ้ maior que a capacidade total permitida para os veํculos cadastrados."
				Return .F.
			Endif
		Endif
	Endif
	If lIntFat .and. M->TDI_STATUS == "4" .and. cStatus != "1"
		MsgStop(STR0032,STR0019) //"O status Cancelado se aplica somente quando o pedido de venda ้ cancelado. Favor informar um status vแlido."###"Aten็ใo"
		Return .F.
	Endif

	If M->TDI_STATUS != "1" .and. M->TDI_STATUS != "4"//Finalizacao ou Devolucao

		If M->TDI_STATUS == "3" //Finalizado
			If Empty(M->TDI_DTRTRA) .Or. Empty(M->TDI_DTEGER) .Or. Empty(M->TDI_DTEREC)
				MsgStop(STR0033) //"Para finalizar o MTR, deverใo ser informadas as Datas de Recebimento e Entrega nas pastas: Gerador, Transportador e Receptor"
				Return .F.
			EndIf
		EndIf
		If lIntFat
			If Empty(M->TDI_PREVEN)
				Help(1," ","OBRIGAT2",,RetTitle("TDI_PREVEN"),3,0)
				Return .F.
			ElseIf Empty(M->TDI_CONPAG)
				Help(1," ","OBRIGAT2",,RetTitle("TDI_CONPAG"),3,0)
				Return .F.
			ElseIf Empty(M->TDI_TES)
				Help(1," ","OBRIGAT2",,RetTitle("TDI_TES"),3,0)
				Return .F.
			ElseIf Empty(M->TDI_TPDEST)
				Help(1," ","OBRIGAT2",,RetTitle("TDI_TPDEST"),3,0)
				Return .F.
			ElseIf Empty(M->TDI_FORNNF)
				Help(1," ","OBRIGAT2",,RetTitle("TDI_FORNNF"),3,0)
				Return .F.
			ElseIf Empty(M->TDI_LOJANF)
				Help(1," ","OBRIGAT2",,RetTitle("TDI_LOJANF"),3,0)
				Return .F.
			ElseIf Val(M->TDI_TES) < 501
				MsgStop(STR0034) //"Favor informar uma TES de saํda.(Maior que 500)"
				Return .F.
			ElseIf Empty(M->TDI_NUM)
				If !MsgYesNo(STR0035+CRLF+STR0036) //"Serแ gerado Pedido de Venda, nใo sendo possํvel fazer altera็๕es ap๓s confirma็ใo."###"Deseja continuar?"
					Return .F.
				Else
					If !GeraPedVend(3) //Gera Pedido de Nota Fiscal
						Return .F.
					EndIf
				EndIf
			EndIf
		ElseIf lIntEst .and. M->TDI_STATUS == "3"
			If !GeraMovEst(3)//Gera Movimentacao no Estoque
				Return .F.
			Endif
		Endif
	ElseIf M->TDI_STATUS == "4" .and. cStatus != "4"
		If MsgYesNo(STR0037+CRLF+STR0036) //"O manifesto serแ cancelado, nใo sendo possํvel fazer altera็๕es ap๓s confirma็ใo."###"Deseja continuar?"
			SG530CANC()
		Else
			Return .F.
		Endif
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA530SM0INFบAutor  ณRoger Rodrigues     บ Data ณ  04/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna informacoes referentes a empresa geradora           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A530SM0INF(cCampo,lTransp)
Local cEmp, cFil
Local cReturn := ""
Default lTransp := .F.
If INCLUI
	If FindFunction("FWGrpCompany")
		cEmp := FWGrpCompany()
		cFil := FWCodFil()
	Else
		cEmp := SM0->M0_CODIGO
		cFil := SM0->M0_CODFIL
	Endif
Else
	If lTransp
		cEmp := TDI->TDI_EMPTRA
		cFil := TDI->TDI_FILTRA
	Else
		cEmp := TDI->TDI_EMPGER
		cFil := TDI->TDI_FILGER
	Endif
EndIf
If !Empty(NGSEEKSM0(TDI->TDI_EMPGER+TDI->TDI_FILGER,{cCampo}))
	cReturn := NGSEEKSM0(cEmp+cFil,{cCampo})[1]
Endif
Return cReturn
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSG530VAL  บAutor  ณRoger Rodrigues     บ Data ณ  13/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que valida os campos da tela                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SG530VAL(cCampo)
Local i
Local lIntFat := (SuperGetMv("MV_NGSGAFA",.F.,"2") == "1")

Default cCampo := ReadVar()

If cCampo == "M->TDI_STATUS"
	If Pertence("1234")
		If TDI->TDI_STATUS == "1" .And. M->TDI_STATUS == "3"
			MsgStop(STR0038) //"Opera็ใo nใo permitida, pois o manifesto deve ser enviado primeiro para o status de 2=Expedi็ใo."
			Return .F.
		Endif
		If lIntFat .and. TDI->TDI_STATUS != "1" .And. M->TDI_STATUS == "1"
			MsgStop(STR0039) //"Opera็ใo nใo permitida, pois jแ houve inclusใo de Pedido de Nota Fiscal."
			Return .F.
		EndIf
	Else
		Return .F.
	Endif
ElseIf cCampo == "M->TDI_TPTRAN"
	If Pertence("12")
		//Limpa Campos
		If M->TDI_TPTRAN == "1"
			M->TDI_CDTRAN := Space(TAMSX3("TDI_CDTRAN")[1])
			M->TDI_NOMTRA := A530SM0INF("M0_NOMECOM")
			M->TDI_ENDTRA := A530SM0INF("M0_ENDCOB")
			M->TDI_CIDTRA := A530SM0INF("M0_CIDCOB")
			M->TDI_ESTTRA := A530SM0INF("M0_ESTCOB")
			M->TDI_TELTRA := A530SM0INF("M0_TEL")
		Else
			M->TDI_NOMTRA := Space(TAMSX3("TDI_NOMTRA")[1])
			M->TDI_ENDTRA := Space(TAMSX3("TDI_ENDTRA")[1])
			M->TDI_CIDTRA := Space(TAMSX3("TDI_CIDTRA")[1])
			M->TDI_ESTTRA := Space(TAMSX3("TDI_ESTTRA")[1])
			M->TDI_TELTRA := Space(TAMSX3("TDI_TELTRA")[1])
			M->TDI_CODMOT := Space(TAMSX3("TDI_CODMOT")[1])
		Endif
		//Variavel de Filtragem do F3
		cCodTrans := M->TDI_CDTRAN
		M->TDI_LICTRA := Space(TAMSX3("TDI_LICTRA")[1])
		M->TDI_NOMMOT := Space(TAMSX3("TDI_NOMMOT")[1])
		//Limpa aCols
		aCols := BlankGetD(aHeader)
	Else
		Return .F.
	Endif
ElseIf cCampo == "M->TDI_CDTRAN"
	If ExistCpo("TDL",M->TDI_CDTRAN)
		dbSelectArea("TDL")
		dbSetOrder(1)
		If dbSeek(xFilial("TDL")+M->TDI_CDTRAN) .and. TDL->TDL_STATUS == "2"
			ShowHelpDlg("INATIVO",{STR0040,STR0041},2,{STR0042}) //"A Transportadora se encontra inativa "###"no sistema."###"Informe uma transportadora ativa."
			Return .F.
		Else
			//Variavel de Filtragem do F3
			cCodTrans := M->TDI_CDTRAN
			//Limpa aCols
			aCols := BlankGetD(aHeader)
		Endif
	Else
		Return .F.
	Endif
ElseIf cCampo == "M->TDI_LICTRA"
	If !ExistCpo("TA0",M->TDI_LICTRA)
		Return .F.
	Endif
ElseIf cCampo == "M->TDI_CODREC"
	If ExistCpo("TB5",M->TDI_CODREC)
		dbSelectArea("TC4")
		dbSetOrder(1)
		If !dbSeek(xFilial("TC4")+M->TDI_CODREC+M->TDI_CODRES)
			ShowHelpDlg(STR0019, {STR0043},1,{STR0044}) //"Aten็ใo"###"O Receptor nใo possui licenciamento para este resํduo."###"Selecione outro receptor."
			Return .F.
		Else
			M->TDI_NOMREC := SG280INFD(M->TDI_CODREC,"NOME")
			M->TDI_ENDREC := SG280INFD(M->TDI_CODREC,"END")
			M->TDI_TELREC := SG280INFD(M->TDI_CODREC,"TEL")
			M->TDI_CIDREC := SG280INFD(M->TDI_CODREC,"MUN")
			M->TDI_ESTREC := SG280INFD(M->TDI_CODREC,"EST")
			M->TDI_LICREC := NGSEEK("TB5",M->TDI_CODREC,1,"TB5_CODLAM")

			dbSelectArea("TB5")
			dbSetOrder(1)
			If lIntFat .and. dbSeek(xFilial("TB5")+M->TDI_CODREC)
				If Empty(M->TDI_TPDEST) .or. Empty(M->TDI_FORNNF)
					M->TDI_TPDEST := TB5->TB5_TPRECE
					M->TDI_FORNNF := TB5->TB5_FORNEC
					M->TDI_LOJANF := TB5->TB5_LOJA
					M->TDI_NOMDES := SG280INFD(M->TDI_CODREC,"NOME")
				Endif
				dbSelectArea("SB1")
				dbSetOrder(1)
				If dbSeek(xFilial("SB1")+M->TDI_CODRES)
					M->TDI_TES		:= SB1->B1_TS
					If TB5->TB5_TPRECE == "2"
						M->TDI_PREVEN	:= SB1->B1_PRV1
					Else
						M->TDI_PREVEN	:= SB1->B1_CUSTD
					Endif
				Endif
			Endif
		Endif
	Else
		Return .F.
	Endif
Elseif cCampo == "M->TDI_TPDEST"
	If Pertence("12")
		If M->TDI_TPDEST == "1"
			aTrocaF3 := {{"TDI_FORNNF","FOR"}}
		Else
			aTrocaF3 := {{"TDI_FORNNF","SA1"}}
		Endif
		M->TDI_FORNNF := Space(TAMSX3("TDI_FORNNF")[1])
		M->TDI_LOJANF := Space(TAMSX3("TDI_LOJANF")[1])
		M->TDI_NOMDES := Space(TAMSX3("TDI_NOMDES")[1])
		//Atualiza a tela
		lRefresh := .T.
	Else
		Return .F.
	Endif
ElseIf cCampo == "M->TDI_FORNNF"
	If M->TDI_TPDEST == "1"
		If !ExistCpo("SA2",M->TDI_FORNNF+M->TDI_LOJANF)
			Return .F.
		EndIf
	Else
		If !ExistCpo("SA1",M->TDI_FORNNF+M->TDI_LOJANF)
			Return .F.
		EndIf
	Endif
	M->TDI_NOMDES := SG280RELA(M->TDI_TPDEST,M->TDI_FORNNF,M->TDI_LOJANF,"NOME")
ElseIf cCampo == "M->TDI_CODMOT"
	If !ExistCpo("DA4",M->TDI_CODMOT)
		Return .F.
	Endif
ElseIf cCampo == "M->TDK_CODVEI"
	If ExistCpo("TDM",M->TDK_CODVEI)
		dbSelectArea("TDM")
		dbSetOrder(1)
		If dbSeek(xFilial("TDM")+M->TDK_CODVEI)
			If TDM->TDM_STATUS == "2"
				ShowHelpDlg("INATIVO",{STR0045},2,{STR0046}) //"O Veํculo se encontra inativo no sistema."###"Informe um veํculo ativo."
				Return .F.
			Else
				If M->TDI_TPTRAN == "1" .and. !Empty(TDM->TDM_CODTRA)//Proprio
					ShowHelpDlg(STR0019,{STR0047},1,{STR0048}) //"Aten็ใo"###"O Veํculo informado estแ relacionado a uma Transportadora."###"Favor informar um Veํculo pr๓prio."
					Return .F.
				ElseIf M->TDI_TPTRAN == "2" .and. cCodTrans != TDM->TDM_CODTRA
					ShowHelpDlg(STR0019,{STR0049},1,{STR0050}) //"Aten็ใo"###"O Veํculo informado nใo pertence เ Transportadora informada."###"Favor informar um Veํculo da Transportadora informada."
					Return .F.
				Endif
				If !SG530LOK(,.T.)
					Return .F.
				Endif
			Endif
		Endif
	Else
		Return .F.
	Endif
ElseIf cCampo == "M->TB4_QUANTI"
	If !IsInCallStack("SGAA530")
		Return .T.
	Else
		If Positivo(M->TB4_QUANTI)
			//Verifica peso digitado
			nPosOco := gdFieldPos("TB4_CODOCO")
			nPosQtd := gdFieldPos("TB4_QUANTI")

			dbSelectArea("TDJ")
			dbSetOrder(1)
			If dbSeek(xFilial("TDJ")+M->TDI_CODCOM+aCols[n][nPosOco])
				If M->TB4_QUANTI > TDJ->TDJ_PESOUT
					ShowHelpDlg(STR0019,{STR0051},1,; //"Aten็ใo"###"O peso digitado ้ maior que o utilizado na Composi็ใo da Carga."
									{STR0052+AllTrim(Transform(TDJ->TDJ_PESOUT,PesqPict("TDJ","TDJ_PESOUT")))+"."}) //"Informe um peso menor ou igual a "
					Return .F.
				Endif
				//Soma peso utilizado da ocorrencia
				nPesoTot := 0.00
				For i:=1 to Len(aCols)
					If i != n .and. aCols[n][nPosOco] == aCols[i][nPosOco]
						nPesoTot += aCols[i][nPosQtd]
					Endif
				Next i
				If (nPesoTot+M->TB4_QUANTI) > TDJ->TDJ_PESOUT
					ShowHelpDlg(STR0019,{STR0051},1,; //"Aten็ใo"###"O peso digitado ้ maior que o utilizado na Composi็ใo da Carga."
									{STR0052+AllTrim(Transform((TDJ->TDJ_PESOUT-nPesoTot),PesqPict("TDJ","TDJ_PESOUT")))+"."})				 //"Informe um peso menor ou igual a "
					Return .F.
				Endif
			Endif
			Return .T.
		Else
			Return .F.
		Endif
	Endif
Endif
//oGetTran:Refresh()
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSG530REL  บAutor  ณRoger Rodrigues     บ Data ณ  14/04/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRelacao dos campos da tela                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SG530REL(cCampo)
Local cRetorno := ""

If cCampo == "M->TDI_NOMTRA"
	If M->TDI_TPTRAN == "1"
		cRetorno := A530SM0INF("M0_NOMECOM")
	ElseIf !Empty(M->TDI_CDTRAN)
		cRetorno := NGSEEK("SA4",M->TDI_CDTRAN,1,"SA4->A4_NOME")
	Endif
ElseIf cCampo == "M->TDI_ENDTRA"
	If M->TDI_TPTRAN == "1"
		cRetorno := A530SM0INF("M0_ENDCOB")
	ElseIf !Empty(M->TDI_CDTRAN)
		cRetorno := NGSEEK("SA4",M->TDI_CDTRAN,1,"SA4->A4_END")
	Endif
ElseIf cCampo == "M->TDI_CIDTRA"
	If M->TDI_TPTRAN == "1"
		cRetorno := A530SM0INF("M0_CIDCOB")
	ElseIf !Empty(M->TDI_CDTRAN)
		cRetorno := NGSEEK("SA4",M->TDI_CDTRAN,1,"SA4->A4_MUN")
	Endif
ElseIf cCampo == "M->TDI_ESTTRA"
	If M->TDI_TPTRAN == "1"
		cRetorno := A530SM0INF("M0_ESTCOB")
	ElseIf !Empty(M->TDI_CDTRAN)
		cRetorno := NGSEEK("SA4",M->TDI_CDTRAN,1,"SA4->A4_EST")
	Endif
ElseIf cCampo == "M->TDI_TELTRA"
	If M->TDI_TPTRAN == "1"
		cRetorno := A530SM0INF("M0_TEL")
	ElseIf !Empty(M->TDI_CDTRAN)
		cRetorno := NGSEEK("SA4",M->TDI_CDTRAN,1,"SA4->A4_TEL")
	Endif
ElseIf cCampo == "M->TDI_PREVEN"
	cRetorno := 0
	If Empty(TDI->TDI_PREVEN) .and. !Empty(M->TDI_CODRES)
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1")+M->TDI_CODRES)
		cRetorno := SB1->B1_CUSTD
	EndIf
ElseIf cCampo == "M->TDK_TIPVEI"
	If !Empty(TDK->TDK_CODVEI) .and. TDK->TDK_CODCOM == M->TDI_CODCOM
		dbSelectArea("DA3")
		dbSetOrder(1)
		If dbSeek(xFilial("DA3")+TDK->TDK_CODVEI)
			dbSelectArea("DUT")
			dbSetOrder(1)
			If dbSeek(xFilial("DUT")+DA3->DA3_TIPVEI)
				cRetorno := DUT->DUT_CATVEI
			Endif
		Endif
	Endif
ElseIf cCampo == "M->TDK_PLACA"
	If !Empty(TDK->TDK_CODVEI) .and. TDK->TDK_CODCOM == M->TDI_CODCOM
		cRetorno := NGSEEK("DA3",TDK->TDK_CODVEI,1,"DA3->DA3_PLACA")
	Endif
ElseIf cCampo == "M->TDK_NOMVEI"
	If !Empty(TDK->TDK_CODVEI) .and. TDK->TDK_CODCOM == M->TDI_CODCOM
		cRetorno := NGSEEK("DA3",TDK->TDK_CODVEI,1,"DA3->DA3_DESC")
	Endif
Endif

Return cRetorno
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSG530LOK  บAutor  ณRoger Rodrigues     บ Data ณ  14/04/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida se linha da Get Dados esta ok                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SG530LOK(lFim,lVal)
Local f
Local nPosCod := gdFieldPos("TDK_CODVEI")
Local cCodVei := ""
Default lVal := .F.
Default lFim := .F.

//Percorre aCols
For f = 1 to Len(aCols)
	If !aCols[f][Len(aCols[f])]
		If !lVal .and. (lFim .or. f == n)
			//VerIfica se os campos obrigat๓rios estใo preenchidos
			If Empty(aCols[f][nPosCod])
				//Mostra mensagem de Help
				Help(1," ","OBRIGAT2",,aHeader[nPosCod][1],3,0)
				Return .F.
			Endif
		Endif
		//Verifica se ้ somente LinhaOk
		If f <> n .and. !aCols[n][Len(aCols[n])]
			If lVal
				cCodVei := M->TDK_CODVEI
			Else
				cCodVei := aCols[n][nPosCod]
			Endif
			If aCols[f][nPosCod] == cCodVei
				Help(" ",1,"JAEXISTINF")
				Return .F.
			Endif
		Endif
	Endif
Next f

If !lVal
	PutFileInEof("TDK")
Endif

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณGeraPedVend ณAutorณ Roger Rodrigues       ณ Data ณ18/04/2011ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณGera Pedido de Venda para o Manifesto                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณSGAA530                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function GeraPedVend(nOpcao)

	Local cOldMod := cModulo
	Local nOldMod := nModulo
	Local nPe
	Local cPedido := If(nOpcao == 5,M->TDI_NUM,GetSxeNum("SC5","C5_NUM"))
	
	//Varivaeis para gravacao do memo
	Local nTam := If((TAMSX3("C5_MENNOTA")[1]) < 1, 60, (TAMSX3("C5_MENNOTA")[1]))
	
	cModulo := "FAT"
	nModulo := 5
	lMsErroAuto := .T.
	lMSHelpAuto := .T. // para mostrar os erros na tela

	RollBackSx8()
	dbSelectArea("TB5")
	dbSetOrder(1)
	dbSeek(xFilial("TB5")+M->TDI_CODREC)
	aCab := {}
	aAdd( aCab, {"C5_NUM",     cPedido, Nil}) // Nro.do Pedido
	aAdd( aCab, {"C5_TIPO",    If(M->TDI_TPDEST == "1", "B", "N"), Nil}) //Tipo de Pedido
	aAdd( aCab, {"C5_CLIENTE", M->TDI_FORNNF, Nil})  //Cod. Cliente
	aAdd( aCab, {"C5_LOJACLI", M->TDI_LOJANF, Nil}) //Loja Cliente
	If !Empty(M->TDI_CDTRAN)
		aAdd( aCab,{"C5_TRANSP", M->TDI_CDTRAN, Nil})  //Transportadora
	Endif
	aAdd( aCab, {"C5_TIPOCLI", "F", Nil}) //Tipo Cliente
	aAdd( aCab, {"C5_CONDPAG", M->TDI_CONPAG, Nil})
	aAdd( aCab, {"C5_MOEDA", 1, Nil})
	aAdd( aCab, {"C5_EMISSAO", dDatabase, Nil})
	aAdd( aCab, {"C5_DESC1", 0, Nil})
	aAdd( aCab, {"C5_INCISS", "N", Nil})
	aAdd( aCab, {"C5_TIPLIB", "1", Nil})
	aAdd( aCab, {"C5_LIBEROK", " ", Nil})
	aAdd( aCab, {"C5_TPCARGA", "2", Nil})
	aAdd( aCab, {"C5_MENPAD", M->TDI_MENPAD, Nil})
	aAdd( aCab, {"C5_ESPECI1", M->TDI_ESPEC1, Nil})
	aAdd( aCab, {"C5_VOLUME1", M->TDI_VOLUM1, Nil})
	aAdd( aCab, {"C5_PESOL", M->TDI_PESOL, Nil})
	aAdd( aCab, {"C5_PBRUTO", M->TDI_PBRUTO, Nil})
	aAdd( aCab, {"C5_MENNOTA", M->TDI_MENNOT, Nil})

	aItens := {}
	aReg   := {}
	cItem  := "01"

	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial("SB1")+M->TDI_CODRES)
	aAdd(aReg, {"C6_NUM", cPedido, Nil}) // Pedido
	aAdd(aReg, {"C6_ITEM", cItem, Nil}) // Item sequencial
	aAdd(aReg, {"C6_PRODUTO", SB1->B1_COD, Nil}) // Cod.Item
	aAdd(aReg, {"C6_UM", SB1->B1_UM, Nil}) // Unidade
	aAdd(aReg, {"C6_QTDVEN", M->TDI_PESOBA, Nil}) // Quantidade
	aAdd(aReg, {"C6_PRCVEN", If(TB5->TB5_TPRECE == "1", 0.01, M->TDI_PREVEN), Nil}) // Preco Unit.
	aAdd(aReg, {"C6_PRUNIT", If(TB5->TB5_TPRECE == "1", 0.01, M->TDI_PREVEN), Nil}) // Preco Unit.
	aAdd(aReg, {"C6_VALOR", If(TB5->TB5_TPRECE == "1",;
								Round(0.01*M->TDI_PESOBA,2),;
								Round(M->TDI_PREVEN*M->TDI_PESOBA,2)),;
								Nil}) // Valor Tot.
	aAdd(aReg, {"C6_TES", M->TDI_TES, Nil})  // Tipo de Saida ...
	aAdd(aReg, {"C6_LOCAL", SB1->B1_LOCPAD, Nil})  // Almoxarifado
	aAdd(aReg, {"C6_ENTREG", dDataBase, Nil})  // Dt.Entrega
	aAdd(aReg, {"C6_TPOP", "F", Nil})
	aAdd(aReg, {"C6_DESCONT", 0, Nil})
	aAdd(aReg, {"C6_COMIS1", 0, Nil})

	aAdd(aItens,aClone(aReg))

	//Ponto de entrada para grava็ao de campos no pedido de venda
	If ExistBlock( "sgaa5301" ) 

		aRet := ExecBlock( "sgaa5301", .F., .F., { aCab, aItens, nOpcao } )

		 //Adiciona novos campos nos arrays

            If Type( "aRet[ 1 ]" ) == "A"

                aCab := aClone( aRet[ 1 ] )

            EndIf

            If Type( "aRet[ 2 ]" ) == "A"

                For nPe := 1 To Len(aRet[ 2 ])

                    aItens[ nPe ] := aClone( aRet[ 2, nPe ] )

                Next nPe

            EndIf

	EndIf

	lMSErroAuto := .F.
	lMSHelpAuto := .F. // para mostrar os erros na tela
	aSort(aItens,,, { |x, y| x[2,2] < y[2,2] })
	MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCab, aItens, nOpcao, .F.)

	If lMsErroAuto
		Mostraerro()
	Else
		If __lSX8
			ConfirmSX8()
		EndIf
		If nOpcao <> 5
			M->TDI_NUM := SC5->C5_NUM
		Endif
	EndIf

	cModulo := cOldMod
	nModulo := nOldMod

Return !lMSErroAuto
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA530HISTFMR บAutor  ณRoger Rodrigues    บ Data ณ  18/04/2011บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava hist๓rico na FMR                                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A530HISTFMR(cStatus)
Local i

dbSelectArea("TDJ")
dbSetOrder(1)
dbSeek(xFilial("TDJ")+M->TDI_CODCOM)
ProcRegua(TDJ->(RecCount()))
While !eof() .and. TDJ->TDJ_FILIAL+TDJ->TDJ_CODCOM == xFilial("TDJ")+M->TDI_CODCOM
	IncProc()
	dbSelectArea("TB0")
	dbSetOrder(1)
	If dbSeek(xFilial("TB0")+TDJ->TDJ_CODOCO)
		RecLock("TB0",.F.)
		TB0->TB0_QTDRED += TDJ->TDJ_PESOUT
		MsUnlock("TB0")

		//Campos de Hist๓rico
		dDtHist := dDataBase
		cHora	:= Time()
		cUsHist	:= cUserName
		dbSelectArea("TDC")
		dbSetOrder(6)
		If TB0->TB0_QTDRED == TB0->TB0_QTDE .and. dbSeek(xFilial("TDC")+TB0->TB0_CODOCO)
			RecLock("TDC",.F.)
			TDC->TDC_STATUS := cStatus
			MsUnlock("TDC")
			dbSelectArea("TDC")
			//Grava Hist๓rico
			dbSelectArea("TDF")
			RecLock("TDF",.T.)
			For i:=1 to FCount()
				If "_FILIAL"$Upper(FieldName(i))
					FieldPut(i, xFilial("TDF"))
				Elseif "_DTALT"$Upper(FieldName(i))
					FieldPut(i, dDtHist)
				Elseif "_HRALT"$Upper(FieldName(i))
					FieldPut(i, cHora)
				Elseif "_USUALT"$Upper(FieldName(i))
					FieldPut(i, cUsHist)
				Else
					FieldPut(i, &("TDC->TDC"+Substr(FieldName(i),4)))
				Endif
			Next i
			MsUnlock("TDF")
			dbSelectArea("TDD")
			dbSetOrder(1)
			dbSeek(xFilial("TDD")+TDC->TDC_CODFMR)
			While !eof() .and. TDD->TDD_FILIAL+TDD->TDD_CODFMR == xFilial("TDD")+TDC->TDC_CODFMR
				dbSelectArea("TDG")
				RecLock("TDG",.T.)
				For i:=1 to FCount()
					If "_FILIAL"$Upper(FieldName(i))
						FieldPut(i, xFilial("TDG"))
					Elseif "_DTALT"$Upper(FieldName(i))
						FieldPut(i, dDtHist)
					Elseif "_HRALT"$Upper(FieldName(i))
						FieldPut(i, cHora)
					Elseif "_USUALT"$Upper(FieldName(i))
						FieldPut(i, cUsHist)
					Else
						FieldPut(i, &("TDD->TDD"+Substr(FieldName(i),4)))
					Endif
				Next i
				MsUnlock("TDG")
				dbSelectArea("TDD")
				dbSkip()
			End
			dbSelectArea("TDE")
			dbSetOrder(1)
			dbSeek(xFilial("TDE")+TDC->TDC_CODFMR)
			While !eof() .and. TDE->TDE_FILIAL+TDE->TDE_CODFMR == xFilial("TDE")+TDC->TDC_CODFMR
				dbSelectArea("TDH")
				RecLock("TDH",.T.)
				For i:=1 to FCount()
					If "_FILIAL"$Upper(FieldName(i))
						FieldPut(i, xFilial("TDH"))
					Elseif "_DTALT"$Upper(FieldName(i))
						FieldPut(i, dDtHist)
					Elseif "_HRALT"$Upper(FieldName(i))
						FieldPut(i, cHora)
					Elseif "_USUALT"$Upper(FieldName(i))
						FieldPut(i, cUsHist)
					Else
						FieldPut(i, &("TDE->TDE"+Substr(FieldName(i),4)))
					Endif
				Next i
				MsUnlock("TDH")
				dbSelectArea("TDE")
				dbSkip()
			End
		End
	Endif
	dbSelectArea("TDJ")
	dbSkip()
End
Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณSG530DOT  ณ Autor ณRoger Rodrigues        ณ Data ณ18/04/2011ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณRealiza a impressao (MS Word) do Manifesto de Residuo (MTR) ณฑฑ
ฑฑณ          ณque estแ selecionado na alias, ou atrav้s de parโmetro.     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณSG530DOT                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function SG530DOT()

	Local cExtDot  := ".dot"
	Local cArqDot  := "mtr"// Nome do arquivo modelo do Word (Tem que ser .dot)
	Local cPathDot := Alltrim(GetMv("MV_DIRACA")) // Path do arquivo modelo do Word
	Local cPathEst := Alltrim(GetMv("MV_DIREST")) // PATH DO ARQUIVO A SER ARMAZENADO NA ESTACAO DE TRABALHO

	Local cBarraRem := If(GetRemoteType() == 2,"/","\") //estacao com sistema operacional unix = 2
	Local cBarraSrv := If(isSRVunix(),"/","\") //servidor eh da familia Unix (linux, solaris, free-bsd, hp-ux, etc.)

	Local nCont, nX
	Local lIntFat := (SuperGetMv("MV_NGSGAFA",.F.,"2") == "1")

	If Empty(TDI->TDI_NUMMTR)
		ShowHelpDlg(STR0019,{STR0053},2,; //"ATENวรO"###"Nใo foram informados os dados necessแrios para o Manifesto."
								{STR0054},1) //"Informe-os clicando em Manifesto."
		Return .F.
	EndIf
	If TDI->TDI_STATUS == "4"
		ShowHelpDlg(STR0019,{STR0055,STR0056},2,; //"ATENวรO"###"O MTR se encontra com status 4=Cancelado."###"Nใo serแ possํvel a impressใo do mesmo."
								{STR0057}) //"O MTR deve se encontrar no status 2=Expedi็ใo ou 3=Finalizado."
		Return .F.
	Endif
	If lIntFat .and. TDI->TDI_STATUS != "3"
		dbSelectArea("SC5")
		dbSetOrder(1)
		If dbSeek(xFilial("SC5")+TDI->TDI_NUM) .and. !Empty(TDI->TDI_NUM)
			If Empty(SC5->C5_NOTA)
				ShowHelpDlg(STR0019,{STR0058},1,; //"ATENวรO"###"Nใo foi gerada nota fiscal para o pedido de venda do Manifesto."
										{STR0059},1) //"Favor gerar a nota fiscal do pedido de venda."
				Return .F.
			Endif
		Else
			ShowHelpDlg(STR0019,{STR0060},1,; //"ATENวรO"###"Nใo foi gerado pedido de venda para o Manifesto."
									{STR0061},1) //"O pedido de venda ้ gerado quando o status do Manifesto ้ alterado para 2=Expedi็ใo."
			Return .F.
		Endif
	ElseIf TDI->TDI_STATUS == "1"
		ShowHelpDlg(STR0019,{STR0062,STR0056},2,; //"ATENวรO"###"O MTR se encontra com status 1=Em Elabora็ใo."###"Nใo serแ possํvel a impressใo do mesmo."
								{STR0057}) //"O MTR deve se encontrar no status 2=Expedi็ใo ou 3=Finalizado."
		Return .F.
	Endif

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Variaveis utilizadas para parametros                         ณ
	//ณ MV_PAR01     Tipo de Impressao (Em Disco, Via Spool)         ณ
	//ณ MV_PAR02     Arquivo Saida                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Private cPerg := "SGA530"

	If !Pergunte(cPerg,.T.)
		Return .F.
	EndIf

	cLogo := SGA530LOG()
	If Empty(cLogo)//Caso nใo tenha logo especifica para o relat๓rio, pega a logo padrใo.
		cLogo :=NGLOCLOGO()
	Endif

	cPathDot += If(Substr(cPathDot,len(cPathDot),1) != cBarraSrv,cBarraSrv,"") + cArqDot
	cPathEst += If(Substr(cPathEst,len(cPathEst),1) != cBarraRem,cBarraRem,"")

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica versใo do Word                                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If mv_par03 == 2
		cExtDot := ".dotm"
	Endif

	cArqDot  += cExtDot
	cPathDot += cExtDot

	//Cria diretorio se nao existir
	MontaDir(cPathEst)

	//Se existir .dot na estacao, apaga
	If File( cPathEst + cArqDot )
		Ferase( cPathEst + cArqDot )
	EndIf
	If !File(cPathDot)
		ShowHelpDlg(STR0019,{STR0063 + cArqDot + STR0064},2,; //"ATENวรO"###"O arquivo "###" nใo foi encontrado no servidor."
								{STR0065},1) //"Verifique o parโmetro 'MV_DIRACA'."
		Return .F.
	EndIf

	CpyS2T(cPathDot,cPathEst,.T.) 	// Copia do Server para o Remote, eh necessario
	// para que o wordview e o proprio word possam preparar o arquivo para impressao e
	// ou visualizacao .... copia o DOT que esta no ROOTPATH Protheus para o PATH da
	// estacao , por exemplo C:\WORDTMP

	cNUMMTR   := TDI->TDI_NUMMTR
	cArqSaida := ""
	For nX := 1 To Len(cNUMMTR)
		If IsDigit(SubStr(cNUMMTR, nX, 1)) .Or. IsAlpha(SubStr(cNUMMTR, nX, 1))
			cArqSaida += SubStr(cNUMMTR, nX, 1)
		Endif
	Next

	//Variaveis utilizadas na integracao com macros do Word
	lImpress  := MV_PAR01 != 1	//Verifica se a saida sera em Tela ou Impressora
	cArqSaida := Upper(If(Empty(MV_PAR02),"MTR_"+cArqSaida,AllTrim(MV_PAR02)))
	If cExtDot == ".dotm"
		If !(".DOCX" $ cArqSaida)
			cArqSaida := StrTran( cArqSaida, ".DOC", ".DOCX" )
		Endif
		If !(".DOC" $ cArqSaida)
			cArqSaida += ".DOC"
		Else
			cArqSaida += ".DOCX"
		Endif
	Else
		cArqSaida := StrTran( cArqSaida, ".DOCX", ".DOC" )
		If !(".DOC" $ cArqSaida)
			cArqSaida += ".DOC"
		Else
			cArqSaida += ".DOCX"
		Endif
	Endif

	oWord := OLE_CreateLink('tMsOleWord97')//Cria link com o Word
	If lImpress //Impressao via Impressora
		OLE_SetProperty(oWord,oleWdVisible,  .F.)
		OLE_SetProperty(oWord,oleWdPrintBack,.T.)
	Else //Impressao na Tela(Arquivo)
		OLE_SetProperty(oWord,oleWdVisible,  .F.)
		OLE_SetProperty(oWord,oleWdPrintBack,.F.)
	EndIf

	OLE_NewFile(oWord,cPathEst + cArqDot) //Abrindo o arquivo modelo automaticamente

	//Seta as variaveis fixas no documento Word
	dbSelectArea("TDI")
	SetAltera()
	RegtoMemory("TDI",.F.)

	/*MTR*/
	OLE_SetDocumentVar(oWord,"cCodigo",TDI->TDI_NUMMTR)
	OLE_SetDocumentVar(oWord,"cCodRes",+AllTrim(TDI->TDI_CODRES)+" - "+NGSEEK("SB1",TDI->TDI_CODRES,1,"B1_DESC"))
	OLE_SetDocumentVar(oWord,"cNumRes",TDI->TDI_CODRES)
	cQuantid := Transform(TDI->TDI_PESOBA,"@E 999,999.99")

	If mv_par04 == 1 //Peso total
		cQuantid := Transform(TDI->TDI_PESOTO,"@E 999,999.99") + " " + TDI->TDI_UNIDAD
	Else //Peso da balan็a
		cQuantid := Transform(TDI->TDI_PESOBA,"@E 999,999.99")
		If TDI->TDI_UNIBAL = "1"
		cQuantid += " T"
		ElseIf TDI->TDI_UNIBAL = "2"
		cQuantid += " Kg"
		ElseIf TDI->TDI_UNIBAL = "3"
		cQuantid += " Mณ"
		EndIf
	EndIf

	OLE_SetDocumentVar(oWord,"cQntdRes",cQuantid)

	/*GERADOR*/
	OLE_SetDocumentVar(oWord,"cEmpGerador"	,NGSEEKSM0(TDI->TDI_EMPGER+TDI->TDI_FILGER,{"M0_NOMECOM"})[1])
	OLE_SetDocumentVar(oWord,"cEndGerador"	,NGSEEKSM0(TDI->TDI_EMPGER+TDI->TDI_FILGER,{"M0_ENDCOB"})[1])
	OLE_SetDocumentVar(oWord,"cCidGerador"	,NGSEEKSM0(TDI->TDI_EMPGER+TDI->TDI_FILGER,{"M0_CIDCOB"})[1])
	OLE_SetDocumentVar(oWord,"cUFGerador"	,NGSEEKSM0(TDI->TDI_EMPGER+TDI->TDI_FILGER,{"M0_ESTCOB"})[1])
	OLE_SetDocumentVar(oWord,"cTelGerador"	,NGSEEKSM0(TDI->TDI_EMPGER+TDI->TDI_FILGER,{"M0_TEL"})[1])
	OLE_SetDocumentVar(oWord,"cLicGerador"	,TDI->TDI_LICGER)
	OLE_SetDocumentVar(oWord,"cRespGerador"	,NGSEEK("QAA",TDI->TDI_RESPEX,1,"QAA_NOME"))
	OLE_SetDocumentVar(oWord,"cCargGerador"	,NGSEEK("QAC",NGSEEK("QAA",TDI->TDI_RESPEX,1,"QAA_CODFUN"),1,"QAC_DESC"))
	OLE_SetDocumentVar(oWord,"cAssGerador"	,NGSEEK("QAA",TDI->TDI_RESPEX,1,"QAA_NOME"))
	OLE_SetDocumentVar(oWord,"cClasse"		,"")
	OLE_SetDocumentVar(oWord,"cDtGerador"	,"____/____/____")

	/*TRANSPORTADOR*/
	OLE_SetDocumentVar(oWord,"cEmpTrans" ,SG530REL("M->TDI_NOMTRA"))
	OLE_SetDocumentVar(oWord,"cEndTrans" ,SG530REL("M->TDI_ENDTRA"))
	OLE_SetDocumentVar(oWord,"cCidTrans" ,SG530REL("M->TDI_CIDTRA"))
	OLE_SetDocumentVar(oWord,"cUFTrans"  ,SG530REL("M->TDI_ESTTRA"))
	OLE_SetDocumentVar(oWord,"cTelTrans" ,SG530REL("M->TDI_TELTRA"))
	OLE_SetDocumentVar(oWord,"cLicTrans" ,TDI->TDI_LICTRA)
	OLE_SetDocumentVar(oWord,"cRespTrans",TDI->TDI_RESPTR)
	OLE_SetDocumentVar(oWord,"cMotTrans" ,TDI->TDI_NOMMOT)

	dbSelectArea("TDK")
	dbSetOrder(1)
	dbSeek(xFilial("TDK")+TDI->TDI_CODCOM)
	cCertif := cTipVei := cPlaca := ""
	While !Eof() .And. xFilial("TDK")+TDI->TDI_CODCOM == TDK->TDK_FILIAL+TDK->TDK_CODCOM
		dbSelectArea("TDM")
		dbSetOrder(1)
		If dbSeek(xFilial("TDM")+TDK->TDK_CODVEI)
			dbSelectArea("DA3")
			dbSetOrder(1)
			If dbSeek(xFilial("DA3")+TDK->TDK_CODVEI)
				dbSelectArea("DUT")
				dbSetOrder(1)
				If dbSeek(xFilial("DUT")+DA3->DA3_TIPVEI)
					cTipVei := NGRETSX3BOX("TDM_TPVEIC",DUT->DUT_CATVEI)
				Endif
			Endif

			cPlaca  += NGSEEK("DA3",TDK->TDK_CODVEI,1,"DA3->DA3_PLACA") + " - " + cTipVei + "@"
			cCertif += TDM->TDM_CRLV + " - " + cTipVei + "@"
		Endif
		dbSelectArea("TDK")
		dbSkip()
	End
	SG530TEXT(Substr(cPlaca,1,Len(cPlaca)-1),2,5,4,3)
	SG530TEXT(Substr(cCertif,1,Len(cCertif)-1),2,6,4,3)

	OLE_SetDocumentVar(oWord,"cAssTrans",TDI->TDI_NOMMOT)
	OLE_SetDocumentVar(oWord,"cDtTransp","____/____/____")

	/*RECEPTOR*/
	OLE_SetDocumentVar(oWord,"cEmpRecep",SG280INFD(TDI->TDI_CODREC,"NOME"))
	OLE_SetDocumentVar(oWord,"cEndRecep",SG280INFD(TDI->TDI_CODREC,"END"))
	OLE_SetDocumentVar(oWord,"cCidRecep",SG280INFD(TDI->TDI_CODREC,"MUN"))
	OLE_SetDocumentVar(oWord,"cUFRecep" ,SG280INFD(TDI->TDI_CODREC,"EST"))
	OLE_SetDocumentVar(oWord,"cTelRecep",SG280INFD(TDI->TDI_CODREC,"TEL"))
	OLE_SetDocumentVar(oWord,"cLicRecep",NGSEEK("TB5",TDI->TDI_CODREC,1,"TB5_CODLAM"))
	OLE_SetDocumentVar(oWord,"cRespRecep",TDI->TDI_RESPRE)
	OLE_SetDocumentVar(oWord,"cCargRecep",TDI->TDI_CARGRR)
	OLE_SetDocumentVar(oWord,"cAssRecep",TDI->TDI_RESPRE)
	OLE_SetDocumentVar(oWord,"cDtReceptor","____/____/____")

	//Acondicionamento
	aAcond := RETACONDIC()
	cTexto1 := ""
	cTexto2 := ""
	For nX := 1 To Len(aAcond)
		cTexto1 := "(X) " + AllTrim(NGSEEK("TB6",aAcond[nX],1,"TB6->TB6_DESCRI"))
		SG530TEXT(cTexto1,2,6,1,1)
	Next nX

	//Estado Fisico

	cCombo := Posicione('SX3', 2, "TAX_ESTADO", 'X3Cbox()')

	cEstado := NGSEEK("TAX",TDI->TDI_CODRES,1,"TAX_ESTADO")
	aVet := RetSx3Box(cCombo,0,0,1,'1')
	cTexto1 := ""
	For nCont := 1 To Len(aVet)-1
		cTexto1 += If(cEstado == aVet[nCont,2],"(X) ","( ) ")+aVet[nCont,3] + " "
	Next nCont
	OLE_SetDocumentVar(oWord,"cEstFisico",cTexto1)

	//Origem
	aVet := FWGetSX5("DV")
	cTexto1 := ""
	cTexto2 := ""
	For nCont := 1 To Len(aVet)
		If nCont % 2 > 0 .And. Len(aVet[nCont,2]) < 12
			cTexto1 += If(TDI->TDI_ORIGEM == AllTrim(aVet[nCont,3]),"(X) ","( ) ")+aVet[nCont,4] + If(nCont >= Len(aVet),"","@")
		Else
			cTexto2 += If(TDI->TDI_ORIGEM == AllTrim(aVet[nCont,3]),"(X) ","( ) ")+aVet[nCont,4] + If(nCont >= Len(aVet),"","@")
		EndIf
	Next nCont
	SG530TEXT(cTexto1,2,3,3,1)
	SG530TEXT(cTexto2,2,3,4,1)


	//Procedencia
	aVet := FWGetSX5("DX")
	cTexto1 := ""
	cTexto2 := ""
	For nCont := 1 To Len(aVet)
		If nCont % 2 > 0
			cTexto1 += If(TDI->TDI_PROCED == AllTrim(aVet[nCont,3]),"(X) ","( ) ")+aVet[nCont,4] + If(nCont >= Len(aVet)-1,"","@")
		Else
			cTexto2 += If(TDI->TDI_PROCED == AllTrim(aVet[nCont,3]),"(X) ","( ) ")+aVet[nCont,4] + If(nCont >= Len(aVet)-1,"","@")
		EndIf
	Next nCont
	SG530TEXT(cTexto1,2,6,2,1)
	SG530TEXT(cTexto2,2,6,3,1)

	//Tratamento/Disposicao
	aVet := FWGetSX5("DY")
	cTexto1 := ""
	cTexto2 := ""
	For nCont := 1 To Len(aVet)
		If nCont % 2 > 0
			cTexto1 += If(TDI->TDI_CODTRA == AllTrim(aVet[nCont,3]),"(X) ","( ) ")+aVet[nCont,4] + If(nCont >= Len(aVet)-1,"","@")
		Else
			cTexto2 += If(TDI->TDI_CODTRA == AllTrim(aVet[nCont,3]),"(X) ","( ) ")+aVet[nCont,4] + If(nCont >= Len(aVet)-1,"","@")
		EndIf
	Next nCont
	SG530TEXT(cTexto1,2,6,4,1)
	SG530TEXT(cTexto2,2,6,5,1)

	If File(cLogo)
		//Insere o Logo da Empresa no cabecalho
		OLE_SetDocumentVar(oWord,"cVar",cLogo)
		OLE_ExecuteMacro(oWord,"Insere_Logo")
		OLE_SetDocumentVar(oWord,"cVar","")
	EndIf

	OLE_ExecuteMacro(oWord,"Atualiza") //Executa a macro que atualiza os campos do documento
	OLE_ExecuteMacro(oWord,"Begin_Text") //Posiciona o cursor no inicio do documento

	If lImpress //Impressao via Impressora
		OLE_SetProperty( oWord, '208', .F. )
		OLE_PrintFile( oWord, "ALL",,, 1 )
	Else //Impressao na Tela(Arquivo)
		OLE_ExecuteMacro(oWord,"Maximiza_Tela")
		OLE_SetProperty(oWord,oleWdVisible,.t.)
		If File(cPathEst+cArqSaida)
			FErase(cPathEst+cArqSaida)
		Endif
		OLE_SaveAsFile(oWord,cPathEst+cArqSaida,,,.f.,oleWdFormatDocument)
		MsgInfo(STR0070) //"Alterne para o programa do Ms-Word para visualizar o documento ou clique no botao para fechar."
	EndIF
	OLE_CloseFile(oWord) //Fecha o documento
	OLE_CloseLink(oWord) //Fecha o documento

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณRETACONDIC ณAutor ณRoger Rodrigues        ณ Data ณ19/04/2011ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณExecuta Macro para impressao do Texto no Doc                ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณSGAA530                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤdฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RETACONDIC()
Local aAcond := {}

dbSelectArea("TDJ")
dbSetOrder(1)
dbSeek(xFilial("TDJ")+TDI->TDI_CODCOM)
While !Eof() .And. xFilial("TDJ")+TDI->TDI_CODCOM == TDJ->TDJ_FILIAL+TDJ->TDJ_CODCOM
	dbSelectArea("TB0")
	dbSetOrder(1)
	If dbSeek(xFilial("TB0")+TDJ->TDJ_CODOCO)
		dbSelectArea("TDC")
		dbSetOrder(6)
		If dbSeek(xFilial("TDC")+TB0->TB0_CODOCO)
			dbSelectArea("TDD")
			dbSetOrder(1)
			dbSeek(xFilial("TDD")+TDC->TDC_CODFMR)
			While !Eof() .And. xFilial("TDD")+TDC->TDC_CODFMR == TDD->TDD_FILIAL+TDD->TDD_CODFMR
				If aSCAN(aAcond,{|x| x ==TDD->TDD_ACONDI}) == 0
					aAdd(aAcond,TDD->TDD_ACONDI+"6")
				EndIf
				dbSelectArea("TDD")
				dbSkip()
			End
		Else
			dbSelectArea("TB7")
			dbSetOrder(1)
			dbSeek(xFilial("TB7")+TDI->TDI_CODRES)
			While !eof() .and. xFilial("TB7")+TDI->TDI_CODRES == TB7->TB7_FILIAL+TB7->TB7_CODRES
				If TB7->TB7_TIPO == "6"//Somente acondicionamento
					If aSCAN(aAcond,{|x| x == TB7->TB7_CODTIP}) == 0
						aAdd(aAcond,TB7->TB7_CODTIP+"6")
					EndIf
				Endif
				dbSelectArea("TB7")
				dbSkip()
			End
		Endif
	Endif

	dbSelectArea("TDJ")
	dbSkip()
End
Return aAcond

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณSG530TEXT ณ Autor ณRoger Rodrigues        ณ Data ณ19/04/2011ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณExecuta Macro para impressao do Texto no Doc                ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณSGAA530                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function SG530TEXT(cTexto,nHV,nLin,nCol,nTBL)

Local nCont, cLIN, cCOL, cTBL, cVar

For nCont := 0 To 3
	cLIN := AllTrim(STR(nLin))
	cCOL := AllTrim(STR(nCol))
	cTBL := AllTrim(STR(nTBL+(nCont*4)))
	cVar := cTexto+"#"+cLIN+"#"+cCOL+"#"+cTBL
	OLE_SetDocumentVar(oWord,"cVar",cVar)
	If nHV == 1
		OLE_ExecuteMacro(oWord,"Cria_TextoH")
	ElseIf nHV == 2
		OLE_ExecuteMacro(oWord,"Cria_TextoV")
	EndIf
Next nCont

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSG530CANC บAutor  ณRoger Rodrigues     บ Data ณ  19/04/2010 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCancela MTR                                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SG530CANC(cNumPed)
Local aArea := GetArea()
Default cNumPed := ""

dbSelectArea("TDI")
If !Empty(cNumPed)
	dbSetOrder(4)
	If dbSeek(xFilial("TDI")+cNumPed)
		//Cancela MTR
		RecLock("TDI",.F.)
		TDI->TDI_STATUS := "4"
		MsUnlock("TDI")
	Else
		Return .T.
	Endif
Else
	dbSetOrder(1)
	If dbSeek(xFilial("TDI")+M->TDI_CODCOM)
		//Cancela MTR
		RecLock("TDI",.F.)
		TDI->TDI_STATUS := "4"
		MsUnlock("TDI")
	Endif
Endif
dbSelectArea("TDJ")
dbSetOrder(1)
dbSeek(xFilial("TDJ")+TDI->TDI_CODCOM)
While !eof() .and. xFilial("TDJ")+TDI->TDI_CODCOM == TDJ->TDJ_FILIAL+TDJ->TDJ_CODCOM
	//Restaura carga da ocorrencia
	dbSelectArea("TB0")
	dbSetOrder(1)
	If dbSeek(xFilial("TB0")+TDJ->TDJ_CODOCO)
		RecLock("TB0",.F.)
		TB0->TB0_QTDDES -= TDJ->TDJ_PESOUT
		MsUnlock("TB0")
	Endif
	dbSelectArea("TDJ")
	dbSkip()
End

RestArea(aArea)
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGeraMovEstบAutor  ณRoger Rodrigues     บ Data ณ  20/04/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGera movimentacao de retirada de residuos no estoque        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GeraMovEst(nOpcx)

	Local nOpca := 0, i, nPos
	Local oDlgMov, oPnlTop
	Local aOldHead := aClone(aHeader), aOldCols := aClone(aCols), nOldN := n
	Local cDocumSD3, cCodDes

	Private M->TB0_CODRES := M->TDI_CODRES //Para Validacao de Rastro
	Private oGetMov
	Private aHeader := {}, aCols := {}
	Private aSim := { "TB4_CODOCO", "TB4_CODDES", "TB4_DESCDE", "TB4_QUANTI", "TB4_UNIMED", "TB4_LOTECT", "TB4_NUMLOT", "TB4_DTVALI" }
	Private aNao := { "TB4_FILIAL", "TB4_CODRES", "TB4_CODCLA", "TB4_DESCLA" }

	aHeader := CabecGetD( "TB4", aNao )

	dbSelectArea("TDJ")
	dbSetOrder(1)
	dbSeek(xFilial("TDJ")+M->TDI_CODCOM)
	While !eof() .and. xFilial("TDJ")+M->TDI_CODCOM == TDJ->TDJ_FILIAL+TDJ->TDJ_CODCOM
		dbSelectArea("TB4")
		dbSetOrder(1)
		dbSeek(xFilial("TB4")+TDJ->TDJ_CODOCO)
		While !eof() .and. xFilial("TB4")+TDJ->TDJ_CODOCO == TB4->TB4_FILIAL+TB4->TB4_CODOCO
			aAdd(aCols, BlankGetD(aHeader)[1])
			For i:=1 to Len(aSim)
				nPos := gdFieldPos(aSim[i])
				If nPos > 0
					If aSim[i] == "TB4_CODOCO"
						aCols[Len(aCols)][nPos] := TB4->TB4_CODOCO
					ElseIf aSim[i] == "TB4_CODDES"
						aCols[Len(aCols)][nPos] := TB4->TB4_CODDES
					ElseIf aSim[i] == "TB4_DESCDE"
						dbSelectArea("TB2")
						dbSetOrder(1)
						If dbSeek(xFilial("TB2")+TB4->TB4_CODDES)
							If TB2->TB2_TIPO == "1"
								aCols[Len(aCols)][nPos] := TB2->TB2_DESLOC
							Else
								aCols[Len(aCols)][nPos] := SA2->A2_NOME
							Endif
						Endif
					ElseIf aSim[i] == "TB4_UNIMED"
						aCols[Len(aCols)][nPos] := M->TDI_UNIDAD
					Endif
				Endif
			Next i
			dbSelectArea("TB4")
			dbSkip()
		End
		dbSelectArea("TDJ")
		dbSkip()
	End

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Define tela                                                  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cTitulo:= ""

	DEFINE MSDIALOG oDlgMov TITLE OemToAnsi(cTitulo) From 6.5,10 To 29,115 OF oMainWnd

	oPnlTop := TPanel():New(00,00,,oDlgMov,,,,,RGB(67,70,87),200,200,.F.,.F.)
	oPnlTop:Align := CONTROL_ALIGN_TOP
	oPnlTop:nHeight := 20

	@ 002,004 Say OemToAnsi(STR0071) Of oPnlTop Color RGB(255,255,255) Pixel //"Preencha abaixo as quantidades do resํduo que serใo retiradas de cada Armaz้m."

	oGetMov  := MSGetDados():New(40,1,125,315,4,"AllWaysTrue()","AllWaysTrue()","",.F., , , ,Len(aCols), , , , ,oDlgMov)
	oGetMov:oBrowse:Refresh()
	oGetMov:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	ACTIVATE MSDIALOG oDlgMov ON INIT EnchoiceBar(oDlgMov,{||nOpca:=1,If(!ValIntEst(),nOpca := 0,oDlgMov:End())},{||oDlgMov:End()}) Centered

	If nOpca == 1 .and. nOpcx == 3
		nPosQtd := gdFieldPos("TB4_QUANTI")
		nPosDes := gdFieldPos("TB4_CODDES")
		nPosLot := gdFieldPos("TB4_LOTECT")
		nPosNum := gdFieldPos("TB4_NUMLOT")
		nPosDtv := gdFieldPos("TB4_DTVALI")
		cDocumSD3 := NextNumero("SD3",2,"D3_DOC",.T.)
		BeginTran()
		For i:=1 to Len(aCols)
			If aCols[i][nPosQtd] > 0
				cCodDes := NGSEEK("TB2",aCols[i][nPosDes],1,"TB2->TB2_CODALM")
				dbSelectArea("SB1")
				dbSetOrder(1)
				dbSeek(xFilial("SB1")+M->TDI_CODRES)
				cCodDes := If(Empty(cCodDes),SB1->B1_LOCPAD,cCodDes)
				//Faz baixa no estoque
				aNumSeqD := SgMovEstoque("RE0",cCodDes,M->TDI_CODRES,,SB1->B1_UM,aCols[i][nPosQtd],dDataBase,cDocumSD3,aCols[i][nPosLot],aCols[i][nPosNum],aCols[i][nPosDtv],,.F.)

				//Se der erro desfaz tudo
				If aNumSeqD[2]
					lRet := .F.
					DisarmTransaction()
					Exit
				Endif
			EndIf
		Next i
		EndTran()
		MsUnlockAll()
		M->TDI_DOC := cDocumSd3
	Endif

	aHeader := aClone(aOldHead)
	aCols := aClone(aOldCols)
	n := nOldN

Return (nOpca == 1)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณValIntEst บAutor  ณRoger Rodrigues     บ Data ณ  25/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a integracao com o estoque                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ValIntEst()
Local i
Local nPesoTo := 0.00
Local nPosQtd := gdFieldPos("TB4_QUANTI")
Local nPosOco := gdFieldPos("TB4_CODOCO")

dbSelectArea("TDJ")
dbSetOrder(1)
dbSeek(xFilial("TDJ")+M->TDI_CODCOM)
While !eof() .and. xFilial("TDJ")+M->TDI_CODCOM == TDJ->TDJ_FILIAL+TDJ_CODCOM
	nPesoTo := 0.00
	For i:=1 to Len(aCols)
		If TDJ->TDJ_CODOCO == aCols[i][nPosOco]
			nPesoTo += aCols[i][nPosQtd]
		Endif
	Next i
	If nPesoTo != TDJ->TDJ_PESOUT
		ShowHelpDlg("Aten็ใo",{STR0072+AllTrim(TDJ->TDJ_CODOCO)+STR0073,; //"O peso informado para a ocorr๊ncia "###" difere do peso utilizado na composi็ใo da carga."
			STR0074+AllTrim(Transform(nPesoTo,PesqPict("TDJ","TDJ_PESOUT")))+STR0075+; //"Foi informado no total "###" e deveria ter sido informado "
			AllTrim(Transform(TDJ->TDJ_PESOUT,PesqPict("TDJ","TDJ_PESOUT")))+"."},2,{STR0076}) //"Informe valores vแlidos."
		Return .F.
	Endif
	dbSelectArea("TDJ")
	dbSkip()
End
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} ClearMark
Limpa a marca็ใo dos registros atuais.

@param cTRBDIS - Tabela temporแria
@author Gabriel Werlich
@since 21/11/2014
@version 11/12
@return .T.
/*/
//---------------------------------------------------------------------
Static Function ClearMark(cTRBDIS, cOK)

dbSelectArea(cTRBDIS)
RecLock(cTRBDIS,.F.)
(cTRBDIS)->TRB_OK := Space(Len(cOK))
(cTRBDIS)->(MsUnlock())

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} SGA530LOG
Responsavel por buscar logo que serแ impresso no relat๓rio.

@author Guilherme Freudenburg
@since 14/01/2016
@sample SGAA530

@return cLogo - Logo que serแ impresso
/*/
//---------------------------------------------------------------------
Function SGA530LOG()

Local cBarras		:= If( isSRVunix() , "/" , "\" )
Local cSMCOD		:= If( FindFunction( "FWGrpCompany" ) , FWGrpCompany() , SM0->M0_CODIGO )
Local cSMFIL		:= AllTrim( If( FindFunction( "FWCodFil" ) , FWCodFil() , SM0->M0_CODFIL ) )
Local cRootPath	:= Alltrim( GetSrvProfString( "RootPath" , cBarras ) )
Local cStartPath	:= AllTrim( GetSrvProfString( "StartPath" , cBarras ) )
Private cLogo 	:= "" //Variavel que serแ adicionado o logo.

//----------------------------------------------------
//- Se StartPath NAO tiver barra no final, adiciona  -
//----------------------------------------------------
If SubStr(AllTrim(cStartPath),Len(AllTrim(cStartPath))) != cBarras
	cStartPath += cBarras
EndIf

//----------------------------------------------------
//- Se StartPath NAO tiver barra no inicio, adiciona -
//----------------------------------------------------
If SubStr(AllTrim(cStartPath),1) != cBarras
	cStartPath = cBarras + cStartPath
EndIf

//----------------------------------------------------
//-     Se RootPath tiver barra no final, exclui     -
//----------------------------------------------------
If SubStr(AllTrim(cRootPath),Len(AllTrim(cRootPath))) == cBarras
	cRootPath = SubStr(AllTrim(cRootPath),1,Len(AllTrim(cRootPath))-1)
EndIf

//----------------------------------------------------
//-                Empresa + Filial                  -
//----------------------------------------------------
If     File(cRootPath+cStartPath+"LGMTR"+cSMCOD+cSMFIL+".BMP")
	cLogo := cRootPath+cStartPath+"LGMTR"+cSMCOD+cSMFIL+".BMP"

ElseIf File(cStartPath+"LGMTR"+cSMCOD+cSMFIL+".BMP")
	cLogo := cStartPath+"LGMTR"+cSMCOD+cSMFIL+".BMP"

ElseIf File("LGMTR"+cSMCOD+cSMFIL+".BMP")
	cLogo := "LGMTR"+cSMCOD+cSMFIL+".BMP"

//----------------------------------------------------
//-                     Empresa                      -
//----------------------------------------------------
ElseIf File(cRootPath+cStartPath+"LGMTR"+cSMCOD+".BMP")
   cLogo := cRootPath+cStartPath+"LGMTR"+cSMCOD+".BMP"

ElseIf File(cStartPath+"LGMTR"+cSMCOD+".BMP")
   cLogo := cStartPath+"LGMTR"+cSMCOD+".BMP"

ElseIf File("LGMTR"+cSMCOD+".BMP")
	cLogo := "LGMTR"+cSMCOD+".BMP"

//----------------------------------------------------
//-                       Todos                      -
//----------------------------------------------------
ElseIf File(cRootPath+cStartPath+"LGMTR.BMP")
   cLogo := cRootPath+cStartPath+"LGMTR.BMP"

ElseIf File(cStartPath+"LGMTR.BMP")
   cLogo := cStartPath+"LGMTR.BMP"

ElseIf File("LGMTR.BMP")
	cLogo := "LGMTR.BMP"

Endif

Return (cLogo) //Retorna logo utilizada

//---------------------------------------------------------------------
/*/{Protheus.doc} SGA530RE
Responsavel por atribui os valores do campos da GetDados.

@author Guilherme Freudenburg
@since 14/01/2016
@sample SGAA530

@return .T.
/*/
//---------------------------------------------------------------------
Function SGA530RE()

Local nPlaca := 0
Local nNomeVei := 0
Local nCatVei := 0

	If IsInCallStack("SGAA530")//Verifica se estแ na rotina SGAA530

		nPlaca	:= aSCAN( aHeader, {|x| AllTrim(Upper(X[2])) == "TDK_PLACA"	}) //Posi็ใo da placa no acols
		nNomeVei:= aSCAN( aHeader, {|x| AllTrim(Upper(X[2])) == "TDK_NOMVEI"	}) //Posi็ใo da nome do veํculo no acols
		nCatVei	:= aSCAN( aHeader, {|x| AllTrim(Upper(X[2])) == "TDK_TIPVEI"	}) //Posi็ใo do tipo do veํculo no acols

		If !Empty( M->TDK_CODVEI ) //Verifica o c๓digo do veํculo
			dbSelectArea( "DA3" )
			dbSetOrder( 1 )
			If dbSeek( xFilial( "DA3" ) + M->TDK_CODVEI )
				aCols[ n , nPlaca ] := NGSEEK( "DA3" , M->TDK_CODVEI , 1 , "DA3->DA3_PLACA" ) //Adicionar valor ao campo Placa
				aCols[ n , nNomeVei ] := NGSEEK( "DA3" , M->TDK_CODVEI , 1 , "DA3->DA3_DESC" )  //Adicionar valor ao campo Nome Veํculo
				dbSelectArea( "DUT" )
				dbSetOrder( 1 )
				If dbSeek( xFilial( "DUT" ) + DA3->DA3_TIPVEI )
					aCols[ n , nCatVei ] := DUT->DUT_CATVEI//Adiciona valor ao campo Tipo Veํculo
				Endif
			Endif
		Endif

	EndIf

Return .T.
