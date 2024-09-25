#INCLUDE "dbTree.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "MNTA298.ch"

//Variaveis de numeracao dos folders
#DEFINE __FOLDER_CTT__ 01 //CENTRO DE CUSTO
#DEFINE __FOLDER_SHB__ 02 //CENTRO DE TRABALHO
#DEFINE __FOLDER_ST6__ 03 //FAMILIA
#DEFINE __FOLDER_TQR__ 04 //TIPO MODELO
#DEFINE __FOLDER_LTAF__ 05 //LOCALIZACAO LOGICA
#DEFINE __FOLDER_ST9__ 06 //BENS
#DEFINE __FOLDER_TAF__ 07 //LOCALIZACAO
#DEFINE __FOLDER_TQ3__ 08 //TIPO SERVICO
#DEFINE __FOLDER_SAZ__ 09 //SAZONALIDADE

#DEFINE __SIZE_ARRAY__ 09 //TAMANHO DO ARRAY

#DEFINE __SIZE_ARROPT__ 04 //TAMANHO DO ARRAY DE VALIDACAO DE OPCOES

#DEFINE __POS_ACOLS__ 01//Posicao do acols
#DEFINE __POS_AHEAD__ 02//Posicao do aheader
#DEFINE __POS_CAMPO1__ 03//Posicao do campo 1
#DEFINE __POS_CAMPO2__ 04//Posicao do campo 2

#DEFINE _nVERSAO 1 //Versao do fonte
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMNTA298   บAutor  ณRoger Rodrigues     บ Data ณ  04/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefinicao dos criterios de distribuicao automaticos         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAMNT                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNTA298()
//Guarda Variaveis Padrao
Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)

Private cCadastro := OemtoAnsi(STR0001) //"Defini็ใo de Crit้rios de Distribui็ใo Automแtica"
Private aRotina := MenuDef()

// Variแvel das cores da tela
Private aNGColor := aClone( NGCOLOR("10") )

//Verifica se o update de facilities foi aplicado
If !FindFunction("MNTUPDFAC") .or. !MNTUPDFAC()
	Return .F.
Endif

dbSelectArea("TUD")
dbSetOrder(1)
mBrowse(6,1,22,75,"TUD")

//Retorna variaveis padrao
NGRETURNPRM(aNGBEGINPRM)
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณMenuDef   ณ Autor ณ Roger Rodrigues       ณ Data ณ04/08/2011ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Utilizacao de menu Funcional                               ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณArray com opcoes da rotina.                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณParametros do array a Rotina:                               ณฑฑ
ฑฑณ          ณ1. Nome a aparecer no cabecalho                             ณฑฑ
ฑฑณ          ณ2. Nome da Rotina associada                                 ณฑฑ
ฑฑณ          ณ3. Reservado                                                ณฑฑ
ฑฑณ          ณ4. Tipo de Transacao a ser efetuada:                        ณฑฑ
ฑฑณ          ณ    1 - Pesquisa e Posiciona em um Banco de Dados           ณฑฑ
ฑฑณ          ณ    2 - Simplesmente Mostra os Campos                       ณฑฑ
ฑฑณ          ณ    3 - Inclui registros no Bancos de Dados                 ณฑฑ
ฑฑณ          ณ    4 - Altera o registro corrente                          ณฑฑ
ฑฑณ          ณ    5 - Remove o registro corrente do Banco de Dados        ณฑฑ
ฑฑณ          ณ5. Nivel de acesso                                          ณฑฑ
ฑฑณ          ณ6. Habilita Menu Funcional                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ               ณ                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function MenuDef()
Local aRotina := {	{STR0002,"PesqBrw"	, 0, 1},; //"Pesquisar"
		            {STR0003,"MNT298INC"	, 0, 2},; //"Visualizar"
		            {STR0004,"MNT298INC"	, 0, 3},; //"Incluir"
		            {STR0005,"MNT298INC"	, 0, 4},; //"Alterar"
		            {STR0006,"MNT298INC"	, 0, 5,,.F.}} //"Excluir"

Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMNT298INC บAutor  ณRoger Rodrigues     บ Data ณ  04/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta tela de inclusao de criterios                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMNTA298                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNT298INC(cAlias, nRecno, nOpcx)

Local oDlg298, oEnc298, oPnlLeg, oPnlBot, oPnlTot
Local aFolder := {}
Local lOk := .F.

//Variaveis de tamanho de tela e objetos
Local aSize := {}, aObjects := {}, aInfo := {}, aPosObj := {}

//Variaveis de getdados
Local aArrGet := {}
Local nOpcGet := If(nOpcx == 3 .or. nOpcx == 4, GD_INSERT+GD_DELETE+GD_UPDATE, 0)
Private oGet298

//Variaveis da enchoice
Private aTrocaF3 := {}
Private aGets := {}, aTela := {}
Private cFilOld := cFilAnt//Variavel para troca de filiais

//Arrays de controle de Variaveis
Private aTFolder   := Array(__SIZE_ARRAY__)
Private aAlias     := Array(__SIZE_ARRAY__)
Private aKeyField  := Array(__SIZE_ARRAY__)
Private aDescField := Array(__SIZE_ARRAY__)

//Carrega array com Folders
aTFolder[__FOLDER_CTT__] := STR0007 //"Centro de Custo"
aTFolder[__FOLDER_SHB__] := STR0008 //"Centro de Trabalho"
aTFolder[__FOLDER_ST6__] := STR0009 //"Famํlia"
aTFolder[__FOLDER_TQR__] := STR0010 //"Tipo Modelo"
aTFolder[__FOLDER_LTAF__]:= STR0011 //"Localiza็ใo L๓gica"
aTFolder[__FOLDER_ST9__] := STR0012 //"Bens"
aTFolder[__FOLDER_TAF__] := STR0013 //"Localiza็ใo Fํsica"
aTFolder[__FOLDER_TQ3__] := STR0014 //"Tipo de Servi็o"
aTFolder[__FOLDER_SAZ__] := STR0015 //"Sazonalidade"

//Carrega array com Alias
aAlias[__FOLDER_CTT__] := "CTT"
aAlias[__FOLDER_SHB__] := "SHB"
aAlias[__FOLDER_ST6__] := "ST6"
aAlias[__FOLDER_TQR__] := "TQR"
aAlias[__FOLDER_LTAF__]:= "TAF"
aAlias[__FOLDER_ST9__] := "ST9"
aAlias[__FOLDER_TAF__] := "TAF"
aAlias[__FOLDER_TQ3__] := "TQ3"
aAlias[__FOLDER_SAZ__] := "TUE"

//Carrega array com chaves
aKeyField[__FOLDER_CTT__] := "CTT_CUSTO"
aKeyField[__FOLDER_SHB__] := "HB_COD"
aKeyField[__FOLDER_ST6__] := "T6_CODFAMI"
aKeyField[__FOLDER_TQR__] := "TQR_TIPMOD"
aKeyField[__FOLDER_LTAF__]:= "TAF_CODNIV"
aKeyField[__FOLDER_ST9__] := "T9_CODBEM"
aKeyField[__FOLDER_TAF__] := "TAF_CODNIV"
aKeyField[__FOLDER_TQ3__] := "TQ3_CDSERV"
aKeyField[__FOLDER_SAZ__] := "TUE_PERINI"

//Carrega array com descricoes
aDescField[__FOLDER_CTT__] := "CTT_DESC01"
aDescField[__FOLDER_SHB__] := "HB_NOME"
aDescField[__FOLDER_ST6__] := "T6_NOME"
aDescField[__FOLDER_TQR__] := "TQR_DESMOD"
aDescField[__FOLDER_LTAF__]:= "TAF_NOMNIV"
aDescField[__FOLDER_ST9__] := "T9_NOME"
aDescField[__FOLDER_TAF__] := "TAF_NOMNIV"
aDescField[__FOLDER_TQ3__] := "TQ3_NMSERV"
aDescField[__FOLDER_SAZ__] := "TUE_PERFIM"

//Definicao de tamanho de tela e objetos
aSize := MsAdvSize(,.f.,430)
Aadd(aObjects,{025,025,.t.,.t.})
Aadd(aObjects,{075,075,.t.,.t.})
aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
aPosObj := MsObjSize(aInfo, aObjects,.t.)

//|------------------------------------------------------|
//| Seta Visual, Inclui, Altera ou Exclui conforme nOpc  |
//|------------------------------------------------------|
aRotSetOpc(cAlias,nRecno,nOpcx)

Define MsDialog oDlg298 Title cCadastro From aSize[7],0 To aSize[6],aSize[5] Of oMainWnd Pixel
oDlg298:lMaximized := .T.

//Painel geral para alinhamento da Enchoice.
oPnlTot := TPanel():New( , , , oDlg298 , , , , , , , , .F. , .F. )
	oPnlTot:Align := CONTROL_ALIGN_ALLCLIENT

//|------------------------------------------------------|
//| Parte Superior da tela                               |
//|------------------------------------------------------|
Dbselectarea("TUD")
RegToMemory("TUD",Inclui)
oEnc298 := MsMGet():New("TUD",nRecno,nOpcx,,,,,aPosObj[1],,,,,,oPnlTot,,,.F.)
	oEnc298:oBox:Align := CONTROL_ALIGN_TOP

//|------------------------------------------------------|
//| Parte Inferior da tela                               |
//|------------------------------------------------------|
oPnlBot := TPanel():New(00,00,,oPnlTot,,,,,,aPosObj[2,4],aPosObj[2,3],.F.,.F.)
	oPnlBot:Align := CONTROL_ALIGN_ALLCLIENT

	//|---------------------------------|
	//| Carrega dados da Regra          |
	//|---------------------------------|
	//Cria Panel de Legenda
	oPnlLeg:=TPanel():New(00,00,,oPnlBot,,,,aNGColor[1],aNGColor[2],200,200,.F.,.F.)
		oPnlLeg:nHeight := 25
		oPnlLeg:Align := CONTROL_ALIGN_TOP

		@ 003,003 Say OemToAnsi(STR0016) Of oPnlLeg Color aNGColor[1] Pixel //"Informe os parโmetros da regra de distribui็ใo automแtica"

	Processa({|| aArrGet := fLoadFold(nOpcx)},STR0017, STR0018) //"Aguarde..." ## "Carregando dados da Regra..."
	oGet298 := MsNewGetDados():New(5,5,500,500,nOpcGet,"MNT298LOK()","AllWaysTrue()",,,,9999,,,,oPnlBot,aArrGet[1], aArrGet[2])
	oGet298:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGet298:oBrowse:Refresh()

Activate MsDialog oDlg298 On Init (EnchoiceBar(oDlg298,{|| If(fTudoOk(),(lOk:=.T.,oDlg298:End()),lOk:=.F.)},{|| lOk:=.F.,oDlg298:End()})) Centered

If !lOk .and. Inclui
	RollBackSX8()
ElseIf lOk .and. nOpcx != 2
	fGrava()
	If Inclui
		ConfirmSX8()
	Endif
Endif
cFilAnt := cFilOld
If nOpcx != 3
	dbSelectArea("TUD")
	dbGoTo(nRecno)
Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMNT298VAL บAutor  ณRoger Rodrigues     บ Data ณ  05/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida campos da tela                                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMNTA298                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNT298VAL(cReadVar)
Local nOpcAtu
Local cVar := ""
Local cDia := cMes := ""
Local dData:= CTOD("")
Local aHeadVal := {}, aColsVal := {}, nAt, nPos
Local lRet := .T.
Default cReadVar := ReadVar()

If cReadVar == "M->TUD_TIPATE"
	If Pertence("12")
		M->TUD_FILATE := Space(TAMSX3("TUD_FILATE")[1])
		M->TUD_CODATE := Space(TAMSX3("TUD_CODATE")[1])
		M->TUD_DESATE := Space(TAMSX3("TUD_DESATE")[1])
	Else
		lRet := .F.
	Endif
ElseIf cReadVar == "M->TUD_FILATE"
	If !Empty(M->TUD_FILATE)
		lRet := FilChkNew(cEmpAnt,M->TUD_FILATE)
		If lRet
			M->TUD_CODATE := Space(TAMSX3("TUD_CODATE")[1])
			M->TUD_DESATE := Space(TAMSX3("TUD_DESATE")[1])
		Endif
	Endif
ElseIf cReadVar == "M->TUD_CODATE"
	If !Empty(M->TUD_CODATE)
		If M->TUD_TIPATE == "1"//Equipe
			lRet := ExistCpo("TP4",M->TUD_CODATE)
		Else
			lRet := ExistCpo("ST1",M->TUD_CODATE)
		Endif
		If lRet
			M->TUD_DESATE := MNT298REL("TUD_DESATE")
		Endif
	Endif
ElseIf cReadVar == "M->TUD_LOGICA"
	If Pertence("12")
		If M->TUD_LOGICA == "2" .and. !fChkFold(__FOLDER_CTT__) .and. !fChkFold(__FOLDER_SHB__)
			Return .F.
		Endif
	Else
		Return .F.
	Endif
ElseIf "TUE_" $ cReadVar
	nOpcAtu := fRetOpcAtu()
	aHeadVal := oGet298:aHeader
	aColsVal := oGet298:aCols
	nAt := oGet298:nAt
	If cReadVar == "M->TUE_TIPO"
		If !Empty(M->TUE_TIPO)
			lRet := Pertence("123465789")
			nOpcAtu := Val(M->TUE_TIPO)
			//Limpa campos
			If lRet
				nPos := GDFIELDPOS("TUE_CODIGO",aHeadVal)
				aColsVal[nAt][nPos] := Space(TAMSX3("TUE_CODIGO")[1])
				nPos := GDFIELDPOS("TUE_DESCRI",aHeadVal)
				aColsVal[nAt][nPos] := Space(TAMSX3("TUE_DESCRI")[1])
				nPos := GDFIELDPOS("TUE_PERINI",aHeadVal)
				aColsVal[nAt][nPos] := Space(TAMSX3("TUE_PERINI")[1])
				nPos := GDFIELDPOS("TUE_PERFIM",aHeadVal)
				aColsVal[nAt][nPos] := Space(TAMSX3("TUE_PERFIM")[1])

				//Verifica se deve apagar outro folder
				If M->TUD_LOGICA == "2" .and. (nOpcAtu == __FOLDER_CTT__ .or. nOpcAtu == __FOLDER_SHB__)
					If !fChkFold(nOpcAtu,.F.)
						Return .F.
					Endif
				Endif
			Endif
		Endif
	ElseIf cReadVar == "M->TUE_CODIGO"
		If !Empty(M->TUE_CODIGO)
			If aAlias[nOpcAtu] == "TAF"
				//Somente permite local. do MNT
				dbSelectArea("TAF")
				dbSetOrder(8)
				If !dbSeek(xFilial("TAF")+M->TUE_CODIGO) .or. Empty(TAF->TAF_MODMNT)
					Help(" ",1,"REGNOIS")
					lRet := .F.
				ElseIf TAF->TAF_INDCON != "2"
					ShowHelpDlg(STR0019,{STR0020},1,{STR0021}) //"Aten็ใo" ## "O c๓digo informado nใo se refere a uma localiza็ใo." ##"Favor informar uma localiza็ใo vแlida."
					lRet := .F.
				Endif
			Else
				lRet := ExistCpo(aAlias[nOpcAtu],Trim(M->TUE_CODIGO))
			Endif
		Endif
	ElseIf cReadVar == "M->TUE_PERINI" .or. cReadVar == "M->TUE_PERFIM"
		cVar := &(cReadVar)
		cDia := Substr(cVar,1,2)
		cMes := Substr(cVar,4,2)
		If NaoVazio(cDia) .and. NaoVazio(cMes)
			dData := CTOD(cVar+"/"+Str(Year(dDatabase),4))
			If (At("-",cVar) > 0) .or. Empty(dData)
				If cDia != "29" .or. ((Len(AllTrim(cMes)) == 1 .and. AllTrim(cMes) <> "2") .or. (Len(AllTrim(cMes)) > 1 .and. cMes <> "02"))//Tratamento para ano bisexto
					ShowHelpDlg(STR0019,{STR0022},1,{STR0023}) //"Aten็ใo" ## "O dia/m๊s informado estแ incorreto." ## "Favor informar um dia/m๊s vแlido."
					Return .F.
				Endif
			Endif
			&(cReadVar) := StrZero(Val(cDia),2)+"/"+StrZero(Val(cMes),2)//Corrige mes com zero
			nPos := If(cReadVar == "M->TUE_PERINI", GDFIELDPOS("TUE_PERFIM",aHeadVal), GDFIELDPOS("TUE_PERINI",aHeadVal))
			If !Empty(aColsVal[nAt][nPos])
				If (cReadVar == "M->TUE_PERINI" .and. A297CPER(M->TUE_PERINI, aColsVal[nAt][nPos], ">")) .or.;
					(cReadVar == "M->TUE_PERFIM" .and. A297CPER(aColsVal[nAt][nPos], M->TUE_PERFIM, ">"))
					ShowHelpDlg(STR0019,{STR0024},1,{STR0025}) //"Aten็ใo" ## "O perํodo informado nใo ้ vแlido." ## "Favor informar um perํodo vแlido."
					Return .F.
				Endif
			Endif
		Else
			Return .F.
		Endif
	Endif
Endif

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMNT298WHENบAutor  ณRoger Rodrigues     บ Data ณ  05/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณWhen dos campos da tela                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMNTA298                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNT298WHEN(cVar)
Local lRet := .T.
Local nOpcAtu := fRetOpcAtu()

cFilAnt := cFilOld

If cVar == "TUD_FILATE"
	If Altera
		lRet := .F.
	ElseIf M->TUD_TIPATE == "1" .and. NGSX2MODO("TP4") == "C"
		lRet := .F.
	ElseIf M->TUD_TIPATE == "2" .and. NGSX2MODO("ST1") == "C"
		lRet := .F.
	ElseIf Empty(M->TUD_TIPATE)
		lRet := .F.
	Endif
ElseIf cVar == "TUD_CODATE"
	aTrocaF3 := {}
	If MNT298WHEN("TUD_FILATE")
		cFilAnt  := M->TUD_FILATE
	Endif
	If M->TUD_TIPATE == "1" //Equipe
		aAdd(aTrocaF3,{"TUD_CODATE","TP4"})
	Else
		aAdd(aTrocaF3,{"TUD_CODATE","ST1"})
	EndIf
ElseIf cVar == "TUE_CODIGO"
	aTrocaF3 := {}
	If nOpcAtu == __FOLDER_SHB__
		aAdd(aTrocaF3,{"TUE_CODIGO","SHB"})
	ElseIf nOpcAtu == __FOLDER_ST6__
		aAdd(aTrocaF3,{"TUE_CODIGO","ST6"})
	ElseIf nOpcAtu == __FOLDER_TQR__
		aAdd(aTrocaF3,{"TUE_CODIGO","TQR"})
	ElseIf nOpcAtu == __FOLDER_ST9__
		aAdd(aTrocaF3,{"TUE_CODIGO","ST9"})
	ElseIf nOpcAtu == __FOLDER_TQ3__
		aAdd(aTrocaF3,{"TUE_CODIGO","TQ3"})
	ElseIf nOpcAtu == __FOLDER_LTAF__ .or. nOpcAtu == __FOLDER_TAF__
		aAdd(aTrocaF3,{"TUE_CODIGO","SGATAF"})
	ElseIf nOpcAtu != __FOLDER_CTT__
		lRet := .F.
	Endif
ElseIf cVar == "TUE_PERINI" .or. cVar == "TUE_PERFIM"
	If nOpcAtu != __FOLDER_SAZ__
		lRet := .F.
	Endif
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMNT298REL บAutor  ณRoger Rodrigues     บ Data ณ  05/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRelacao dos campos da tela                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMNTA298                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNT298REL(cVar,lIniBrw)
Local cRetorno := ""
Local nTipo := 0
Local cTipo := cCodigo := ""
Local cFilOld := cFilAnt
Default lIniBrw := .F.

If cVar == "TUD_DESATE"
	If lIniBrw
		cFilAnt := TUD->TUD_FILATE
		cTipo   := TUD->TUD_TIPATE
		cCodigo := TUD->TUD_CODATE
	Else
		cFilAnt := M->TUD_FILATE
		cTipo   := M->TUD_TIPATE
		cCodigo := M->TUD_CODATE
	Endif
	If cTipo == "1"//Equipe
		cRetorno := NGSEEK("TP4",Substr(cCodigo,1,TAMSX3("TP4_CODIGO")[1]),1,"TP4->TP4_DESCRI")
	Else
		cRetorno := NGSEEK("ST1",Substr(cCodigo,1,TAMSX3("T1_CODFUNC")[1]),1,"ST1->T1_NOME")
	Endif
	cFilAnt := cFilOld
ElseIf cVar == "TUE_DESCRI"
	If Type("M->TUE_CODIGO") == "C"
		nTipo := fRetOpcAtu()
		cCodigo := Trim(M->TUE_CODIGO)
	Else
		nTipo := Val(TUE->TUE_TIPO)
		cCodigo := Trim(TUE->TUE_CODIGO)
	Endif
	If !Empty(cCodigo) .and. nTipo != __FOLDER_SAZ__
		cRetorno:= NGSEEK(aAlias[nTipo],cCodigo, If(aAlias[nTipo]=="TAF", 8, 1) ,aDescField[nTipo])
	Endif
Endif

Return cRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfLoadFold บAutor  ณRoger Rodrigues     บ Data ณ  13/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega conteudo do folder                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMNTA298                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fLoadFold(nOpcx)
Local cKey  := M->TUD_CODIGO
Local cWhile:= 'TUE->TUE_FILIAL == xFilial("TUE") .AND. TUE->TUE_CODREG == M->TUD_CODIGO'
Local aNao  := {}
Local aCols := {}, aHead := {}

aNao := {"TUE_CODREG"}

FillGetDados( nOpcx,"TUE",1,cKey,{||},{||.T.},aNao,,,,{|| NGMontaAcols("TUE",cKey,cWhile) },,aHead,aCols)
If Len(aCols) == 0
	aCols := BlankGetD(aHead)
Endif

Return {aHead,aCols}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfGrava    บAutor  ณRoger Rodrigues     บ Data ณ  13/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza gravacao da tela                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMNTA298                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fGrava()
Local i, j, k
Local cTipo := cCodigo := cPerIni := ""
Local nPosTipo := nPosCod := nPosPer := nPos := 0
Local aCols   := aHeader := {}

//Grava parte superior
dbSelectArea("TUD")
dbSetOrder(1)
If dbSeek(xFilial("TUD")+M->TUD_CODIGO)
	RecLock("TUD",.F.)
Else
	RecLock("TUD",.T.)
Endif
If Inclui .or. Altera
	For i:=1 to FCount()
		If "_FILIAL" $ Upper(FieldName(i))
			FieldPut(i, xFilial("TUD"))
		Else
			FieldPut(i, &("M->"+FieldName(i)))
		Endif
	Next i
Else
	dbDelete()
Endif
MsUnlock("TUD")

//Exclui itens da getdados
If !Inclui
	dbSelectArea("TUE")
	dbSetOrder(1)
	dbSeek(xFilial("TUE")+M->TUD_CODIGO)
	While !eof() .and. xFilial("TUE")+M->TUD_CODIGO == TUE->(TUE_FILIAL+TUE_CODREG)
		RecLock("TUE",.F.)
		dbDelete()
		MsUnlock("TUE")
		dbSelectArea("TUE")
		dbSkip()
	End
Endif

aCols   := oGet298:aCols
aHeader := oGet298:aHeader

nPosTipo:= GDFIELDPOS("TUE_TIPO",aHeader)
nPosCod := GDFIELDPOS("TUE_CODIGO",aHeader)
nPosPer := GDFIELDPOS("TUE_PERINI",aHeader)

If Inclui .or. Altera
	aSort(aCols,,,{|x,y| x[Len(aHeader)+1] .and. !y[Len(aHeader)+1]})
	For j:=1 to Len(aCols)
		cTipo   := aCols[j][nPosTipo]
		cCodigo := aCols[j][nPosCod]
		If Empty(cCodigo)
			cPerIni := aCols[j][nPosPer]
		Else
			cPerIni := AllTrim(StrTran(aCols[j][nPosPer],"/"," "))
		Endif
		If !aCols[j][Len(aHeader)+1] .and. !Empty(cTipo) .and. (!Empty(cCodigo) .or. !Empty(cPerIni))
			dbSelectArea("TUE")
			dbSetOrder(1)
			If dbSeek(xFilial("TUE")+M->TUD_CODIGO+cTipo+cCodigo+cPerIni)
				RecLock("TUE",.F.)
			Else
				RecLock("TUE",.T.)
			Endif
			For k:=1 to FCount()
				If "_FILIAL" $ Upper(FieldName(k))
					FieldPut(k, xFilial("TUE"))
				ElseIf "_CODREG" $ Upper(FieldName(k))
					FieldPut(k, M->TUD_CODIGO)
				ElseIf "_TIPO" $ Upper(FieldName(k))
					FieldPut(k, cTipo)
				ElseIf (nPos := GDFIELDPOS(FieldName(k), aHeader)) > 0
					FieldPut(k, aCols[j][nPos])
				Endif
			Next k
			MsUnlock("TUE")
		ElseIf !Empty(cTipo) .and. (!Empty(cCodigo) .or. !Empty(cPerIni))
			dbSelectArea("TUE")
			dbSetOrder(1)
			If dbSeek(xFilial("TUE")+M->TUD_CODIGO+cTipo+cCodigo+cPerIni)
				RecLock("TUE",.F.)
				dbDelete()
				MsUnlock("TUE")
			Endif
		Endif
	Next j
Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMNT298LOK บAutor  ณRoger Rodrigues     บ Data ณ  13/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida linha da getdados                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMNTA298                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNT298LOK(lFim)
Local f, nTipo
Local aColsOk := oGet298:aCols
Local aHeadOk := oGet298:aHeader
Local nAt     := oGet298:nAt
Local nPosTipo:= GDFIELDPOS("TUE_TIPO",aHeadOk)
Local nPosCod := GDFIELDPOS("TUE_CODIGO",aHeadOk)
Local nPosIni := GDFIELDPOS("TUE_PERINI",aHeadOk)
Local nPosFim := GDFIELDPOS("TUE_PERFIM",aHeadOk)
Default lFim := .F.

For f:=1 to Len(aColsOk)
	If !aColsOk[f][Len(aColsOk[f])]
		nTipo := Val(aColsOk[f][nPosTipo])
		//Verifica se os campos obrigat๓rios estใo preenchidos
		If lFim .or. f == nAt
			If Empty(aColsOk[f][nPosTipo])
				//Mostra mensagem de Help
				Help(1," ","OBRIGAT2",,aHeadOk[nPosTipo][1],3,0)
				Return .F.
			Endif
			If nTipo == __FOLDER_SAZ__
				If Empty(aColsOk[f][nPosIni])
					//Mostra mensagem de Help
					Help(1," ","OBRIGAT2",,aHeadOk[nPosIni][1],3,0)
					Return .F.
				ElseIf Empty(aColsOk[f][nPosFim])
					//Mostra mensagem de Help
					Help(1," ","OBRIGAT2",,aHeadOk[nPosFim][1],3,0)
					Return .F.
				Endif
			Else
				If Empty(aColsOk[f][nPosCod])
					//Mostra mensagem de Help
					Help(1," ","OBRIGAT2",,aHeadOk[nPosCod][1],3,0)
					Return .F.
				Endif
			Endif
		Endif

		//Verifica se ้ somente LinhaOk
		If f <> nAt .and. !aColsOk[nAt][Len(aColsOk[nAt])]
			If nTipo != __FOLDER_SAZ__
				If aColsOk[f][nPosTipo]+aColsOk[f][nPosCod] == aColsOk[nAt][nPosTipo]+aColsOk[nAt][nPosCod]
					Help(" ",1,"JAEXISTINF",,aHeadOk[nPosTipo][1]+"+"+aHeadOk[nPosCod][1])
					Return .F.
				Endif
			ElseIf Val(aColsOk[nAt][nPosTipo]) == __FOLDER_SAZ__
				If (A297CPER(aColsOk[nAt][nPosIni], aColsOk[f][nPosIni], ">=") .and. A297CPER(aColsOk[nAt][nPosIni], aColsOk[f][nPosFim], "<=")) .or.;
					(A297CPER(aColsOk[nAt][nPosFim], aColsOk[f][nPosIni], ">=") .and. A297CPER(aColsOk[nAt][nPosFim], aColsOk[f][nPosFim], "<=")) .or.;
					(A297CPER(aColsOk[nAt][nPosIni], aColsOk[f][nPosIni], "<=") .and. A297CPER(aColsOk[nAt][nPosFim], aColsOk[f][nPosFim], ">="))
					ShowHelpDlg("JAEXISTINF",{STR0026},1,{STR0027}) //"Perํodo jแ informado." ## "Informe um perํodo vแlido."
					Return .F.
				Endif
			Endif
		Endif
	Endif
Next f
PutFileInEof("TUE")

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfChkCols  บAutor  ณRoger Rodrigues     บ Data ณ  14/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna se existe linhas preenchidas no acols               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMNTA298                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fChkCols(nOpcao)
Local i
Local nLine := 0
Local aCols := oGet298:aCols
Local aHead := oGet298:aHeader
Local nPosTipo := GDFIELDPOS("TUE_TIPO",aHead)
Local nPosCod  := GDFIELDPOS("TUE_CODIGO",aHead)
Local nPosIni  := GDFIELDPOS("TUE_PERINI",aHead)
Local nPosFim  := GDFIELDPOS("TUE_PERFIM",aHead)
Default nOpcao := 0

For i:=1 to Len(aCols)
	If !aCols[i][Len(aCols[i])] .and. (aCols[i][nPosTipo] == cValToChar(nOpcao) .or. nOpcao == 0) .and. (!Empty(aCols[i][nPosCod]) .or.;
			!Empty(StrTran(aCols[i][nPosIni],"/"," ")) .or. !Empty(StrTran(aCols[i][nPosFim],"/"," ")))
		nLine ++
		Exit
	Endif
Next i

Return nLine

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfTudoOk   บAutor  ณRoger Rodrigues     บ Data ณ  14/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se esta tudo cadastrado corretamente na rotina     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMNTA298                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fTudoOk()

If Inclui .or. Altera
	If !Obrigatorio(aGets,aTela)
		Return .F.
	Endif
	If !MNT298LOK(.T.)
		Return .F.
	Endif
	If fChkCols() == 0
		ShowHelpDlg(STR0019,{STR0028},1,{STR0029}) //"Aten็ใo" ## "Nenhum parโmetro foi informado para a regra." ## "Favor informar um parโmetro nos folders inferiores da tela."
		Return .F.
	Endif
	If !fChkOpts()
		Return .F.
	Endif
Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfRetOpcAtuบAutor  ณRoger Rodrigues     บ Data ณ  05/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna qual opcao selecionada na linha atual da getDados   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMNTA298                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fRetOpcAtu()
Local nOpcAtu := 0
Local aCols := oGet298:aCols
Local nAt := oGet298:nAt
Local nPos := GDFIELDPOS("TUE_TIPO", oGet298:aHeader)

If nAt > 0
	nOpcAtu := Val(aCols[nAt][nPos])
Endif

Return nOpcAtu
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfClearScr บAutor  ณRoger Rodrigues     บ Data ณ  14/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLimpa todas getdados                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMNTA298                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fClearScr(nOpcao)
Local i := 1, cOpcao
Local aCols := oGet298:aCols
Local aHead := oGet298:aHeader
Local nAt   := oGet298:nAt
Local nAtPost  := nAt
Local nPosTipo := GDFIELDPOS("TUE_TIPO",aHead)
Default nOpcao := 0

cOpcao := cValToChar(nOpcao)
If cOpcao == "0"
	//Limpa GetDados
	aCols := {}
Else
	While i <= Len(aCols)
		If aCols[i][nPosTipo] == cOpcao
			//Deleta uma linha e atualiza nAt
			If i < nAt
				nAtPost --
			Endif
			aDel(aCols, i)
			aSize(aCols, Len(aCols)-1)
		Else
			i++
		Endif
	End
Endif

If Len(aCols) == 0
	aCols := BlankGetD(aHead)
Endif
oGet298:aCols := aCols
oGet298:nAt   := nAtPost
n := nAtPost//Variavel atualizada, pois MsNewGetDados ainda utiliza a mesma
oGet298:ForceRefresh()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfChkFold  บAutor  ณRoger Rodrigues     บ Data ณ  15/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se os outros folders estao preenchidos             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMNTA298                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fChkFold(nOpcao,lChkAtu)
Local aColsVal := oGet298:aCols
Local aHeadVal := oGet298:aHeader
Local nPosTipo := GDFIELDPOS("TUE_TIPO",aHeadVal)
Local nPosCod  := GDFIELDPOS("TUE_CODIGO",aHeadVal)
Local cItens := "", cItemAtu := ""
Local lChkCTT, lChkSHB
Default lChkAtu := .T.

Store .F. to lChkCTT, lChkSHB

If !lChkAtu .or. fChkCols(nOpcao) > 0
	If nOpcao == __FOLDER_CTT__
		lChkSHB := .T.
		cItemAtu := STR0030 //"os Centros de Custo"
	Elseif nOpcao == __FOLDER_SHB__
		lChkCTT := .T.
		cItemAtu := STR0031 //"os Centros de Trabalho"
	Endif
Endif
//Centros de Custo
If lChkCTT
	If aScan(aColsVal, {|x| x[nPosTipo] == cValToChar(__FOLDER_CTT__) .and. !Empty(x[nPosCod]) .and. !x[Len(aHeadVal)+1]}) > 0
		cItens += STR0032 //"Centros de Custo"
	Else
		fClearScr(__FOLDER_CTT__)
	Endif
Endif
//Centros de Trabalho
If lChkSHB
	If aScan(aColsVal, {|x| x[nPosTipo] == cValToChar(__FOLDER_SHB__) .and. !Empty(x[nPosCod]) .and. !x[Len(aHeadVal)+1]}) > 0
		cItens += STR0033 //"Centros de Trabalho"
	Else
		fClearScr(__FOLDER_SHB__)
	Endif
Endif

If !Empty(cItens)
	If MsgYesNo(STR0034+cItens+STR0035+cItemAtu+STR0036+cItens+STR0037,STR0019) //"Jแ existem " # " informados. Deseja utilizar " # "? Todos " # " serใo apagados." # "Aten็ใo"
		//Limpa getDados
		If lChkCTT
			fClearScr(__FOLDER_CTT__)
		Endif
		If lChkSHB
			fClearScr(__FOLDER_SHB__)
		Endif
	Else
		Return .F.
	Endif
Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfChkOpts  บAutor  ณRoger Rodrigues     บ Data ณ  15/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se existem regras com a opcao duplicada            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMNTA298                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fChkOpts()
Local i,a,b,c,d
Local lEmpty := .T.
Local aColsVal := oGet298:aCols
Local aHeadVal := oGet298:aHeader
Local nPosTipo := GDFIELDPOS("TUE_TIPO",aHeadVal)
Local cCampo, cCCusto, cCTrab, cFamilia, cTipMod, cLocalLog, cBem, cLocal
Local aOpts := Array(__SIZE_ARRAY__,__SIZE_ARROPT__)

//Preenche todos arrays de acols, aheader e nopc
For i:=1 to Len(aOpts)
	aOpts[i][__POS_ACOLS__] := {}
	aOpts[i][__POS_AHEAD__] := aHeadVal
	If i == __FOLDER_SAZ__
		aOpts[i][__POS_CAMPO1__] := GDFIELDPOS("TUE_PERINI",aOpts[i][__POS_AHEAD__])
		aOpts[i][__POS_CAMPO2__] := GDFIELDPOS("TUE_PERFIM",aOpts[i][__POS_AHEAD__])
	Else
		aOpts[i][__POS_CAMPO1__] := GDFIELDPOS("TUE_CODIGO",aOpts[i][__POS_AHEAD__])
		aOpts[i][__POS_CAMPO2__] := 0
	Endif
	For a:=1 to Len(aColsVal)
		If !aColsVal[a][Len(aHeadVal)+1] .and. !Empty(aColsVal[a][nPosTipo]) .and. Val(aColsVal[a][nPosTipo]) == i .and.;
				 !Empty(aColsVal[a][aOpts[i][__POS_CAMPO1__]])
			aAdd(aOpts[i][__POS_ACOLS__], aColsVal[a])
		Endif
	Next a
	If fChkCols(i) == 0
		aOpts[i][__POS_ACOLS__] := BlankGetD(aOpts[i][__POS_AHEAD__])
	ElseIf i < __FOLDER_TQ3__
		lEmpty := .F.//Indica que existe algum acols da esquerda preenchido
	Endif
Next i

If M->TUD_LOGICA == "1"//OU
	//Percorre todos arrays, exceto area e sazonalidade
	For a:=1 to (__SIZE_ARRAY__)
		If a < __FOLDER_TQ3__ .or. (lEmpty .and. a > 1)
			cCCusto  := ""
			cCTrab   := ""
			cFamilia := ""
			cTipMod  := ""
			cLocalLog:= ""
			cBem     := ""
			cLocal   := ""
			//Percorre array
			For i:=1 to Len(aOpts[a][__POS_ACOLS__])
				//Se a linha nao estiver deletada
				If !aOpts[a][__POS_ACOLS__][i][Len(aOpts[a][__POS_AHEAD__])+1]
					cCampo := aOpts[a][__POS_ACOLS__][i][aOpts[a][__POS_CAMPO1__]]
					//Otimizacao, para nao verificar varias vezes pelo campo em branco
					If Empty(cCampo) .and. !lEmpty
						Loop
					Endif
					If a == __FOLDER_CTT__
						cCCusto  := cCampo
					ElseIf a == __FOLDER_SHB__
						cCTrab   := cCampo
					ElseIf a == __FOLDER_ST6__
						cFamilia := cCampo
					ElseIf a == __FOLDER_TQR__
						cTipMod  := cCampo
					ElseIf a == __FOLDER_LTAF__
						cLocalLog:= cCampo
					ElseIf a == __FOLDER_ST9__
						cBem     := cCampo
					ElseIf a == __FOLDER_TAF__
						cLocal   := cCampo
					Endif
					//Concatena Area e Sazonalidade
					If !fChkTQ3SAZ(aOpts, cCCusto, cCTrab, cFamilia, cTipMod, cLocalLog, cBem, cLocal)
						Return .F.
					Endif
				Endif
			Next i
		Endif
	Next a
Else//E
	cCCusto  := ""
	cCTrab   := ""
	cFamilia := ""
	cTipMod  := ""
	cLocalLog:= ""
	cBem     := ""
	cLocal   := ""
	For a:=1 to Len(aOpts[__FOLDER_CTT__][__POS_ACOLS__])
		cCCusto := aOpts[__FOLDER_CTT__][__POS_ACOLS__][a][aOpts[__FOLDER_CTT__][__POS_CAMPO1__]]

		For b:=1 to Len(aOpts[__FOLDER_SHB__][__POS_ACOLS__])
			cCTrab := aOpts[__FOLDER_SHB__][__POS_ACOLS__][b][aOpts[__FOLDER_SHB__][__POS_CAMPO1__]]

			For c:=1 to Len(aOpts[__FOLDER_ST6__][__POS_ACOLS__])
				cFamilia := aOpts[__FOLDER_ST6__][__POS_ACOLS__][c][aOpts[__FOLDER_ST6__][__POS_CAMPO1__]]

				For d:=1 to Len(aOpts[__FOLDER_TQR__][__POS_ACOLS__])
					cTipMod := aOpts[__FOLDER_TQR__][__POS_ACOLS__][d][aOpts[__FOLDER_TQR__][__POS_CAMPO1__]]

					For i:=1 to Len(aOpts[__FOLDER_LTAF__][__POS_ACOLS__])
						cTipMod := aOpts[__FOLDER_LTAF__][__POS_ACOLS__][d][aOpts[__FOLDER_LTAF__][__POS_CAMPO1__]]

						If !Empty(cCCusto) .or. !Empty(cCTrab) .or. !Empty(cFamilia) .or. !Empty(cTipMod) .or. !Empty(cLocalLog) .or. lEmpty
							If !fChkTQ3SAZ(aOpts, cCCusto, cCTrab, cFamilia, cTipMod, cLocalLog, cBem, cLocal)
								Return .F.
							Endif
						Endif
					Next i
				Next d

			Next c

		Next b

	Next j

	cCCusto  := ""
	cCTrab   := ""
	cFamilia := ""
	cTipMod  := ""
	cLocalLog:= ""
	cBem     := ""
	cLocal   := ""
	For a:=1 to Len(aOpts[__FOLDER_ST9__][__POS_ACOLS__])//Verifica combinacoes dos bens
		cBem := aOpts[__FOLDER_ST9__][__POS_ACOLS__][a][aOpts[__FOLDER_ST9__][__POS_CAMPO1__]]

		If !Empty(cBem)
			If !fChkTQ3SAZ(aOpts, cCCusto, cCTrab, cFamilia, cTipMod, cLocalLog, cBem, cLocal)
				Return .F.
			Endif
		Endif
	Next a
	cCCusto  := ""
	cCTrab   := ""
	cFamilia := ""
	cTipMod  := ""
	cLocalLog:= ""
	cBem     := ""
	cLocal   := ""
	For b:=1 to Len(aOpts[__FOLDER_TAF__][__POS_ACOLS__])//Verifica combinacoes das localizacoes
		cLocal := aOpts[__FOLDER_TAF__][__POS_ACOLS__][b][aOpts[__FOLDER_TAF__][__POS_CAMPO1__]]

		If !Empty(cLocal)
			If !fChkTQ3SAZ(aOpts, cCCusto, cCTrab, cFamilia, cTipMod, cLocalLog, cBem, cLocal)
				Return .F.
			Endif
		Endif
	Next b

Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfChkTQ3SAZบAutor  ณRoger Rodrigues     บ Data ณ  16/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica combinacoes com as tabelas de Serv e Sazonalidade  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMNTA298                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fChkTQ3SAZ(aOpts, cCCusto, cCTrab, cFamilia, cTipMod, cLocalLog, cBem, cLocal)
Local f, g
Local cRegra:= ""
Local cCdServ := cPerIni := cPerFim := ""

//Concatena Area
For f:=1 to Len(aOpts[__FOLDER_TQ3__][__POS_ACOLS__])
	If !aOpts[__FOLDER_TQ3__][__POS_ACOLS__][f][Len(aOpts[__FOLDER_TQ3__][__POS_AHEAD__])+1]
		cCdServ := aOpts[__FOLDER_TQ3__][__POS_ACOLS__][f][aOpts[__FOLDER_TQ3__][__POS_CAMPO1__]]

		//Concatena Periodo
		For g:=1 to Len(aOpts[__FOLDER_SAZ__][__POS_ACOLS__])
			If !aOpts[__FOLDER_SAZ__][__POS_ACOLS__][g][Len(aOpts[__FOLDER_SAZ__][__POS_AHEAD__])+1]
				cPerIni := aOpts[__FOLDER_SAZ__][__POS_ACOLS__][g][aOpts[__FOLDER_SAZ__][__POS_CAMPO1__]]
				cPerFim := aOpts[__FOLDER_SAZ__][__POS_ACOLS__][g][aOpts[__FOLDER_SAZ__][__POS_CAMPO2__]]

				cRegra := fExistReg(M->TUD_CODIGO, cCCusto, cCTrab, cFamilia, cTipMod, cLocalLog, cBem, cLocal, cCdServ, cPerIni, cPerFim)
				If !Empty(cRegra)
					fShowDupli(cRegra, cCCusto, cCTrab, cFamilia, cTipMod, cLocalLog, cBem, cLocal, cCdServ, cPerIni, cPerFim)
					Return .F.
				Endif
			Endif
		Next g
	Endif
Next f

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfShowDupliบAutor  ณRoger Rodrigues     บ Data ณ  19/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMostra mensagem de erro de duplicidade                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMNTA298                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fShowDupli(cRegra, cCCusto, cCTrab, cFamilia, cTipMod, cLocalLog, cBem, cLocal, cCdServ, cPerIni, cPerFim)
Local cMsg := ""
Local oDlg, oPnlCabec, oPnlBtn, oVoltar, oTMGet, oFont

cMsg := STR0038+CRLF //"Favor alterar os parโmetros. Jแ existe uma regra que contempla a seguinte combina็ใo:"
cMsg += STR0039+Trim(cRegra) //"Regra: "
If !Empty(cCCusto)
	cMsg += CRLF+aTFolder[__FOLDER_CTT__]+": "+Trim(cCCusto)+" - "+Substr(NGSEEK(aAlias[__FOLDER_CTT__],Trim(cCCusto),1,aDescField[__FOLDER_CTT__]),1,30)
Endif
If !Empty(cCTrab)
	cMsg += CRLF+aTFolder[__FOLDER_SHB__]+": "+Trim(cCTrab)+" - "+Substr(NGSEEK(aAlias[__FOLDER_SHB__],Trim(cCTrab),1,aDescField[__FOLDER_SHB__]),1,30)
Endif
If !Empty(cFamilia)
	cMsg += CRLF+aTFolder[__FOLDER_ST6__]+": "+Trim(cFamilia)+" - "+Substr(NGSEEK(aAlias[__FOLDER_ST6__],Trim(cFamilia),1,aDescField[__FOLDER_ST6__]),1,30)
Endif
If !Empty(cTipMod)
	cMsg += CRLF+aTFolder[__FOLDER_TQR__]+": "+Trim(cTipMod)+" - "+Substr(NGSEEK(aAlias[__FOLDER_TQR__],Trim(cTipMod),1,aDescField[__FOLDER_TQR__]),1,30)
Endif
If !Empty(cLocalLog)
	cMsg += CRLF+aTFolder[__FOLDER_LTAF__]+": "+Trim(cLocalLog)+" - "+Substr(NGSEEK(aAlias[__FOLDER_TAF__],Trim(cLocal),8,aDescField[__FOLDER_LTAF__]),1,30)
Endif
If !Empty(cBem)
	cMsg += CRLF+aTFolder[__FOLDER_ST9__]+": "+Trim(cBem)+" - "+Substr(NGSEEK(aAlias[__FOLDER_ST9__],Trim(cBem),1,aDescField[__FOLDER_ST9__]),1,30)
Endif
If !Empty(cLocal)
	cMsg += CRLF+aTFolder[__FOLDER_TAF__]+": "+Trim(cLocal)+" - "+Substr(NGSEEK(aAlias[__FOLDER_TAF__],Trim(cLocal),8,aDescField[__FOLDER_TAF__]),1,30)
Endif
If !Empty(cCdServ)
	cMsg += CRLF+aTFolder[__FOLDER_TQ3__]+": "+Trim(cCdServ)+" - "+Substr(NGSEEK(aAlias[__FOLDER_TQ3__],Trim(cCdServ),1,aDescField[__FOLDER_TQ3__]),1,30)
Endif
If !Empty(cPerIni)
	cMsg += CRLF+aTFolder[__FOLDER_SAZ__]+": "+Trim(cPerIni)+" - "+Trim(cPerFim)
Endif

Define Dialog oDlg From 0,0 To 300,360 Of oMainWnd COLOR CLR_BLACK,CLR_WHITE Pixel
	oDlg:lEscClose := .T.

	//Titulo da Janela
	oPnlCabec := TPanel():New(0,0,,oDlg,,,,aNGColor[1],aNGColor[2],355,20,.F.,.F.)
		oPnlCabec:nHeight := 25
		oPnlCabec:Align := CONTROL_ALIGN_TOP

		oFont := TFont():New("Arial",,14,,.F.,,,,,,.F.)

		TSay():New(02,02,{|| STR0040},oPnlCabec,,oFont,,,,.T.,aNGColor[1],aNGColor[2],200,20) //"Combina็ใo Existente"

		oTMGet := TMultiget():New(20,10,{|u|if(Pcount()>0,cMsg:=u,cMsg)},oDlg,160,100,oFont,.T.,,,,.T.,,,,,,.T.)

	//Botao 'Voltar'
	oPnlBtn := TPanel():New(0,0,,oDlg,,,,CLR_BLACK,CLR_WHITE,355,30,.F.,.F.)
		oPnlBtn:Align := CONTROL_ALIGN_BOTTOM

	oVoltar := TButton():New(9,135,"Ok",oPnlBtn, {|| oDlg:End()}, 36, 12, ,,,.T.,,,,,,)
		oVoltar:lCanGotFocus := .F.

Activate Dialog oDlg Centered
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfExistReg บAutor  ณRoeger Rodrigues    บ Data ณ  16/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se existe regra semelhante a dos parametros        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMNTA298                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fExistReg(cCodRegra, cCCusto, cCTrab, cFamilia, cTipMod, cLocalLog, cBem, cLocal, cCdServ, cPerIni, cPerFim)
Local cRet := ""
Local lPriNiv := .T., lSecNiv := .T., lTerNiv := .T.
Default cCCusto  := ""
Default cCTrab   := ""
Default cFamilia := ""
Default cTipMod  := ""
Default cLocalLog:= ""
Default cBem     := ""
Default cLocal   := ""
Default cCdServ    := ""
Default cPerIni  := ""
Default cPerFim  := ""

dbSelectArea("TUD")
dbSetOrder(1)
dbSeek(xFilial("TUD"))
While !eof() .and. xFilial("TUD") == TUD->TUD_FILIAL

	lPriNiv := .F.//Indica se a primeira parte da regra existe (CC,CT,F,TM,BEM,LOC)
	lSecNiv := .F.//Indica se a segunda parte da regra existe(AREA)
	lTerNiv := .F.//Indica se a terceira parte da regra existe(SAZ)
	If TUD->TUD_CODIGO != cCodRegra//Elimina a propria regra
		dbSelectArea("TUE")
		dbSetOrder(1)
		If !Empty(cBem) .and. dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_ST9__)+cBem)
			lPriNiv := .T.
		ElseIf !Empty(cLocal) .and. dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_TAF__)+cLocal)
			lPriNiv := .T.
		ElseIf Empty(cBem) .and. Empty(cLocal)
			If TUD->TUD_LOGICA == "1"//OU
				//Somente verifica caso exista soh 1 parametro preenchido
				If (!Empty(cCCusto) .and. Empty(cCTrab+cFamilia+cTipMod+cLocalLog)) .or.;
				 	(!Empty(cCTrab) .and. Empty(cCCusto+cFamilia+cTipMod+cLocalLog)) .or.;
					(!Empty(cFamilia) .and. Empty(cCCusto+cCTrab+cTipMod+cLocalLog)) .or.;
					(!Empty(cTipMod) .and. Empty(cCCusto+cCTrab+cFamilia+cLocalLog)) .or.;
					(!Empty(cLocalLog) .and. Empty(cCCusto+cCTrab+cFamilia+cTipMod))
					//Se encontrar algum
					If (!Empty(cCCusto) .and. dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_CTT__)+cCCusto))
						lPriNiv := .T.
					Endif
					If (!Empty(cCTrab) .and. dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_SHB__)+cCTrab))
						lPriNiv := .T.
					Endif
					If (!Empty(cFamilia) .and. dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_ST6__)+cFamilia))
						lPriNiv := .T.
					Endif
					If (!Empty(cTipMod) .and. dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_TQR__)+cTipMod))
						lPriNiv := .T.
					Endif
					If (!Empty(cLocalLog) .and. dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_LTAF__)+cLocalLog))
						lPriNiv := .T.
					Endif
				Else
					//Se todos estiverem vazios e nao encontrar nenhum
					If Empty(cCCusto) .and. Empty(cCTrab) .and. Empty(cFamilia) .and. Empty(cTipMod) .and. Empty(cLocalLog) .and. ;
						!dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_CTT__)+Trim(cCCusto)) .and.;
						!dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_SHB__)+Trim(cCTrab)) .and.;
						!dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_ST6__)+Trim(cFamilia)) .and.;
						!dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_TQR__)+Trim(cTipMod)) .and.;
						!dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_LTAF__)+Trim(cLocalLog))
						lPriNiv := .T.
					Endif
				Endif
			Else//E
				//Se encontrar todos
				If ((!Empty(cCCusto) .and. dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_CTT__)+cCCusto)) .or.;
					(Empty(cCCusto) .and. !dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_CTT__)+Trim(cCCusto)))) ;
					.and.;
					((!Empty(cCTrab) .and. dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_SHB__)+cCTrab)) .or.;
					(Empty(cCTrab) .and. !dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_SHB__)+Trim(cCTrab))));
					.and.;
					((!Empty(cFamilia) .and. dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_ST6__)+cFamilia)) .or.;
					(Empty(cFamilia) .and. !dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_ST6__)+Trim(cFamilia)))) ;
					.and.;
					((!Empty(cTipMod) .and. dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_TQR__)+cTipMod)) .or. ;
					(Empty(cTipMod) .and. !dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_TQR__)+Trim(cTipMod)))) ;
					.and.;
					((!Empty(cLocalLog) .and. dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_LTAF__)+cLocalLog)) .or.;
					(Empty(cLocalLog) .and. !dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_LTAF__)+Trim(cLocalLog))))
					lPriNiv := .T.
				Endif
			Endif
		Endif
		If lPriNiv
			dbSelectArea("TUE")
			dbSetOrder(1)
			If !Empty(cCdServ) .and. dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_TQ3__)+cCdServ) .or. ;
				Empty(cCdServ) .and. !dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_TQ3__))
				lSecNiv  := .T.
			Endif
		Endif
		If lSecNiv
			dbSelectArea("TUE")
			dbSetOrder(1)
			If !Empty(cPerIni)
				dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_SAZ__))
				While !eof() .and. xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_SAZ__) == TUE->TUE_FILIAL+TUE->TUE_CODREG+TUE->TUE_TIPO
					If (A297CPER(cPerIni, TUE->TUE_PERINI, ">=") .and. A297CPER(cPerIni, TUE->TUE_PERFIM, "<=")) .or.;
						(A297CPER(cPerFim, TUE->TUE_PERINI, ">=") .and. A297CPER(cPerFim, TUE->TUE_PERFIM, "<=")) .or.;
						(A297CPER(cPerIni, TUE->TUE_PERINI, "<=") .and. A297CPER(cPerFim, TUE->TUE_PERFIM, ">="))
						lTerNiv := .T.
						Exit
					Endif
					dbSelectArea("TUE")
					dbSkip()
				End
			Else
				lTerNiv := !dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_SAZ__))
			Endif
		Endif
	Endif

	If lPriNiv .and. lSecNiv .and. lTerNiv//Se existirem nos 3 niveis, retorna duplicidade
		cRet := TUD->TUD_CODIGO
		Exit
	Else
		dbSelectArea("TUD")
		dbSkip()
	Endif
End

Return cRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMNT298AUT บAutor  ณRoger Rodrigues     บ Data ณ  19/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza a distribuicao automatica da solicitacao            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบVariaveis ณcTipoSS - Tipo da SS (Obrigatorio)                          บฑฑ
ฑฑบ          ณcBemLoc - Bem/Localizacao da SS (Obrigatorio)               บฑฑ
ฑฑบ          ณcCdServ - Tipo de Servico da SS (Opcional)                  บฑฑ
ฑฑบ          ณdDataSS - Data da SS (Opcional)                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ.T./.F. -> Indica se a SS foi distribuida                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNT298AUT(cCodSS,cTipoSS,cBemLoc,cCdServ,dDataSS,cTrb40)
Local lRet   := .F.
Local i, nPontos, nMaxPt := 1000
Local aArea  := GetArea(), aRegras := {}
Local cFamilia := ""
Local cTipMod  := ""
Local cBem     := ""
Local cLocal   := ""

Default cCdServ := ""
Default dDataSS  := dDatabase
Default cTrb40 := GetNextAlias()

//Valida existencia das tabelas TUD e TUE
If !AliasInDic("TUD") .or. !AliasInDic("TUE")
	RestArea(aArea)
	Return lRet
Endif

If !Empty(cTipoSS) .and. !Empty(cBemLoc)
	//Preenche informacoes
	If cTipoSS == "B"//Bem
		cBem := cBemLoc
		dbSelectArea("ST9")
		dbSetOrder(1)
		If dbSeek(xFilial("ST9")+cBemLoc)
			cFamilia := ST9->T9_CODFAMI
			cTipMod  := ST9->T9_TIPMOD
			cCCusto := ST9->T9_CCUSTO
			cCTrab := ST9->T9_CENTRAB
		Endif
	Else//Localizacao
		cLocal := cBemLoc
		dbSelectArea("TAF")
		dbSetOrder(8)
		If dbSeek(xFilial("TAF")+cBemLoc)
			cFamilia := TAF->TAF_CODFAM
			cCCusto := TAF->TAF_CCUSTO
			cCTrab := TAF->TAF_CENTRA
		Endif
	Endif
	aRegras := NGRETRDIST(cCCusto, cCTrab, cFamilia, cTipMod, cBem, cLocal, cCdServ, dDataSS)
	//Verifica qual regra mais especifica
	For i:=1 to Len(aRegras)
		nPontos := 0
		If aRegras[i][__FOLDER_ST9__] .or. aRegras[i][__FOLDER_TAF__]
			nPontos += nMaxPt+3
		Else
			If aRegras[i][__FOLDER_CTT__]
				nPontos += nMaxPt/20
			Endif
			If aRegras[i][__FOLDER_SHB__]
				nPontos += nMaxPt/10
			Endif
			If aRegras[i][__FOLDER_ST6__]
				nPontos += nMaxPt/5
			Endif
			If aRegras[i][__FOLDER_TQR__]
				nPontos += nMaxPt/2
			Endif
			If aRegras[i][__FOLDER_LTAF__] > 0
				nPontos += nMaxPt/aRegras[i][__FOLDER_LTAF__]
			Endif
		Endif
		If aRegras[i][__FOLDER_TQ3__]
			nPontos += nMaxPt+2
		Endif
		If aRegras[i][__FOLDER_SAZ__]
			nPontos += nMaxPt+1
		Endif
		aRegras[i][__SIZE_ARRAY__+2] := nPontos
	Next i
	If Len(aRegras) > 0
		aSort(aRegras,,,{|x,y| x[__SIZE_ARRAY__+2] > y[__SIZE_ARRAY__+2]})
		dbSelectArea("TUD")
		dbSetOrder(1)
		If dbSeek(xFilial("TUD")+aRegras[1][__SIZE_ARRAY__+1])
			lRet := .T.
			//Distribui solicitacao
			MNT296DIST({{xFilial("TQB"),cCodSS}}, {{TUD->TUD_TIPATE, TUD->TUD_FILATE, TUD->TUD_CODATE, ""}}, , STR0041, cTrb40) //"SS Distribuํda Automaticamente"
		Endif
	Endif
Endif

RestArea(aArea)

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNGRETRDISTบAutor  ณRoger Rodrigues     บ Data ณ  16/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna todas as opcoes de distribuicao automatica que se   บฑฑ
ฑฑบ          ณadequam aos parametros                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบVariaveis ณcCusto -  Centro de Custo da SS (Opcional)                  บฑฑ
ฑฑบ          ณcCTrab - Centro de Trabalho da SS (Opcional)                บฑฑ
ฑฑบ          ณcFamilia - Familia do Bem/Localizao da SS (Opcional)        บฑฑ
ฑฑบ          ณcTipMod - Tipo de Modelo do Bem da SS (Opcional)            บฑฑ
ฑฑบ          ณcBem - Bem da SS (Opcional)                                 บฑฑ
ฑฑบ          ณcLocal - Localizacao da SS (Opcional)                       บฑฑ
ฑฑบ          ณcCdServ - Tipo de Servico da SS (Opcional)                  บฑฑ
ฑฑบ          ณdDataSS - Data da SS (Opcional)                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณaRegras -> Array com regras que tiveram combinacoes         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function NGRETRDIST(cCCusto, cCTrab, cFamilia, cTipMod, cBem, cLocal, cCdServ, dDataSS)
Local aRegras := {}, aLocPais := {}
Local cPeriodo:= "", i
Local lPriNiv := .T., lSecNiv := .T., lTerNiv := .T.
Local lCTT, lSHB, lST6, lTQR, nLTAF := 0
Default cCCusto := ""
Default cCTrab  := ""
Default cFamilia:= ""
Default cTipMod := ""
Default cBem    := ""
Default cLocal  := ""
Default cCdServ   := ""
Default dDataSS := dDataBase

dbSelectArea("TUD")
dbSetOrder(1)
dbSeek(xFilial("TUD"))
While !eof() .and. xFilial("TUD") == TUD->TUD_FILIAL

	lPriNiv := .F.//Indica se a primeira parte da regra existe (CC,CT,F,TM,BEM,LOC)
	lSecNiv := .F.//Indica se a segunda parte da regra existe(SERVICO)
	lTerNiv := .F.//Indica se a terceira parte da regra existe(SAZ)

	aAdd(aRegras, Array(__SIZE_ARRAY__+2))//Adiciona uma linha de regra

	//Inicializa tudo como falso
	For i:=1 to __SIZE_ARRAY__
		aRegras[Len(aRegras)][i] := .F.
	Next i
	aRegras[Len(aRegras)][__FOLDER_LTAF__]  := 0//Proximidade do nivel
	aRegras[Len(aRegras)][__SIZE_ARRAY__+1] := TUD->TUD_CODIGO//Codigo da regra
	aRegras[Len(aRegras)][__SIZE_ARRAY__+2] := 0//Pontuacao

	dbSelectArea("TUE")
	dbSetOrder(1)
	//Se a regra tiver a primeira parte inteira vazia
	If !dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_CTT__)) .and.;
		!dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_SHB__)) .and.;
		!dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_ST6__)) .and.;
		!dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_TQR__)) .and.;
		!dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_LTAF__)) .and.;
		!dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_ST9__)) .and.;
		!dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_TAF__))
		lPriNiv := .T.
	ElseIf !Empty(cBem) .and. dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_ST9__)+cBem)
		lPriNiv := .T.
		aRegras[Len(aRegras)][__FOLDER_ST9__] := .T.
	ElseIf !Empty(cLocal) .and. dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_TAF__)+cLocal)
		lPriNiv := .T.
		aRegras[Len(aRegras)][__FOLDER_TAF__] := .T.
	Else
		If TUD->TUD_LOGICA == "1"//OU
			//Se encontrar algum
			If (!Empty(cCCusto) .and. dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_CTT__)+cCCusto))
				lPriNiv := .T.
				aRegras[Len(aRegras)][__FOLDER_CTT__] := .T.
			Endif
			If (!Empty(cCTrab) .and. dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_SHB__)+cCTrab))
				lPriNiv := .T.
				aRegras[Len(aRegras)][__FOLDER_SHB__] := .T.
			Endif
			If (!Empty(cFamilia) .and. dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_ST6__)+cFamilia))
				lPriNiv := .T.
				aRegras[Len(aRegras)][__FOLDER_ST6__] := .T.
			Endif
			If (!Empty(cTipMod) .and. dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_TQR__)+cTipMod))
				lPriNiv := .T.
				aRegras[Len(aRegras)][__FOLDER_TQR__] := .T.
			Endif
			If dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_LTAF__))
				aLocPais := fRetSup(cBem, Substr(cLocal,1,3))
				For i:=1 to Len(aLocPais)
					If dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_LTAF__)+aLocPais[i])
						lPriNiv := .T.
						aRegras[Len(aRegras)][__FOLDER_LTAF__] := i
						Exit
					Endif
				Next i
			Endif
		Else//E
			lCTT := (!Empty(cCCusto) .and. dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_CTT__)+cCCusto))

			lSHB := (!Empty(cCTrab) .and. dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_SHB__)+cCTrab))

			lST6 := (!Empty(cFamilia) .and. dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_ST6__)+cFamilia))

			lTQR := (!Empty(cTipMod) .and. dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_TQR__)+cTipMod))

			If dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_LTAF__))
				aLocPais := fRetSup(cBem, Substr(cLocal,1,3))
				For i:=1 to Len(aLocPais)
					If dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_LTAF__)+aLocPais[i])
						nLTAF := i
						Exit
					Endif
				Next i
			Endif
			If (lCTT .or. !dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_CTT__))) .and.;
			 	(lSHB .or. !dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_SHB__))) .and.;
			 	(lST6 .or. !dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_ST6__))) .and.;
			 	(lTQR .or. !dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_TQR__))) .and.;
			 	(nLTAF > 0 .or. !dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_LTAF__)))

				lPriNiv := .T.
				aRegras[Len(aRegras)][__FOLDER_CTT__] := lCTT
				aRegras[Len(aRegras)][__FOLDER_SHB__] := lSHB
				aRegras[Len(aRegras)][__FOLDER_ST6__] := lST6
				aRegras[Len(aRegras)][__FOLDER_TQR__] := lTQR
				aRegras[Len(aRegras)][__FOLDER_LTAF__]:= nLTAF
			Endif
		Endif
	Endif
	If lPriNiv
		dbSelectArea("TUE")
		dbSetOrder(1)
		If (!Empty(cCdServ) .and. dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_TQ3__)+cCdServ)) .or. ;
			!dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_TQ3__))
			lSecNiv  := .T.
			If !Empty(cCdServ)
				aRegras[Len(aRegras)][__FOLDER_TQ3__] := .T.
			Endif
		Endif
	Endif
	If lSecNiv .and. !Empty(dDataSS)
		cPeriodo := StrZero(Day(dDataSS),2)+"/"+StrZero(Month(dDataSS),2)
		dbSelectArea("TUE")
		dbSetOrder(1)
		If dbSeek(xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_SAZ__))
			While !eof() .and. xFilial("TUE")+TUD->TUD_CODIGO+cValToChar(__FOLDER_SAZ__) == TUE->TUE_FILIAL+TUE->TUE_CODREG+TUE->TUE_TIPO
				If (A297CPER(cPeriodo, TUE->TUE_PERINI, ">=") .and. A297CPER(cPeriodo, TUE->TUE_PERFIM, "<="))
					lTerNiv := .T.
					aRegras[Len(aRegras)][__FOLDER_SAZ__] := .T.
					Exit
				Endif
				dbSelectArea("TUE")
				dbSkip()
			End
		Else
			lTerNiv := .T.
		Endif
	Endif

	If !lPriNiv .or. !lSecNiv .or. !lTerNiv//Se nao encontrar combinacao
		aDel(aRegras, Len(aRegras))
		aSize(aRegras, Len(aRegras)-1)
	Endif
	dbSelectArea("TUD")
	dbSkip()
End

Return aRegras

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfRetSup   บAutor  ณRoger Rodrigues     บ Data ณ  07/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna niveis superiores ao bem/localizacao                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMNTA298                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fRetSup(cBem, cLocal)
Local aArea := GetArea()
Local cCodNiv := cNivSup := ""
Local aNiveis := {}

dbSelectArea("TAF")
If !Empty(cBem)
	dbSetOrder(6)
	If dbSeek(xFilial("TAF")+"X1"+cBem)
		cCodNiv := TAF->TAF_CODNIV
		cNivSup := TAF->TAF_NIVSUP
	Endif
Else
	dbSetOrder(8)
	If dbSeek(xFilial("TAF")+cLocal)
		cCodNiv := TAF->TAF_CODNIV
		cNivSup := TAF->TAF_NIVSUP
	Endif
Endif

If !Empty(cCodNiv)
	dbSelectArea("TAF")
	dbSetOrder(8)
	While !Eof() .and. dbSeek(xFilial("TAF")+cNivSup)
		aAdd(aNiveis, cNivSup)
		cNivSup := TAF->TAF_NIVSUP
		If cNivSup == "000"
			Exit
		Endif
	End
Endif

RestArea(aArea)

Return aNiveis
