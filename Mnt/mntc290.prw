#INCLUDE "MNTC290.ch"
#Include "Protheus.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTC290
Consulta de S.C. a partir de O.S.

@author	Felipe N. Welter
@since 16/07/09

@sample MNTC290()

@param cOs, Caracter, Numero da OS que será verificada.
@return
/*/
//---------------------------------------------------------------------
Function MNTC290(cOS)

	Local aNGBEGINPRM  := NGBEGINPRM(1)
	Local aIdxTRB      := {}
	Local x            := 0
	Local aPesq        := {}
	Local cOsIni       := ""
	Local cOsFim       := ""
	Local cOldProg     := FunName()

	Private cCadastro  := OemToAnsi(STR0001) //"Consulta de Solicitação de Compra a partir da O.S."
	Private aRotina    := MenuDef()
	Private oTmpTblTRB := Nil
	Private cTRB       := GetNextAlias()
	Private aVETINR    := {}
	Private aCores     := {}
	Private cPERG      := "MNC290"

	SetFunName( 'MNTC290' ) // Assume a função posicionada como Pai.

	// Preenche as variaveis DE/ATÉ dependendo de como a consulta é chamada.
	If !Empty(cOS)
		cOsIni := cOs
		cOsFim := cOs
	ElseIf Pergunte(cPerg,.T.)
		cOsIni := MV_PAR01
		cOsFim := MV_PAR02
	Else
		Return .F.
	EndIf

	/*--------------------------------------------------------------------------
	| Criacao da Tabela Temporaria                                             |
	--------------------------------------------------------------------------*/
	aDBF := {{"SOLCOM"    ,"C", TAMSX3("C1_NUM")[1]    ,TAMSX3("C1_NUM")[2]}    ,;  //C1_NUM
	         {"ITEMCO"    ,"C", TAMSX3("C1_ITEM")[1]   ,TAMSX3("C1_ITEM")[2]}   ,;  //C1_ITEM
	         {"CODPRO"    ,"C", TAMSX3("C1_PRODUTO")[1],TAMSX3("C1_PRODUTO")[2]},;  //C1_PRODUTO
	         {"DESPRO"    ,"C", TAMSX3("C1_DESCRI")[1] ,TAMSX3("C1_DESCRI")[2]} ,;  //C1_DESCRI
	         {"UNMD"      ,"C", TAMSX3("C1_UM")[1]     ,TAMSX3("C1_UM")[2]}     ,;  //C1_UM
	         {"DTEMISS"   ,"D", TAMSX3("C1_EMISSAO")[1],TAMSX3("C1_EMISSAO")[2]},;  //C1_EMISSAO
	         {"PEDIDO"    ,"C", TAMSX3("C1_PEDIDO")[1] ,TAMSX3("C1_PEDIDO")[2]} ,;  //C1_PEDIDO
	         {"DATPRF"    ,"D", TAMSX3("C1_DATPRF")[1] ,TAMSX3("C1_DATPRF")[2]} ,;  //C1_DATPRF
	         {"OS"        ,"C", TAMSX3("TJ_ORDEM")[1]  ,TAMSX3("TJ_ORDEM")[2]}  ,;  //TJ_ORDEM
	         {"C1_RESIDUO","C", TAMSX3("C1_RESIDUO")[1],TAMSX3("C1_RESIDUO")[2]},;
	         {"C1_QUJE"   ,"N", TAMSX3("C1_QUJE")[1]   ,TAMSX3("C1_QUJE")[2]}   ,;
	         {"C1_COTACAO","C", TAMSX3("C1_COTACAO")[1],TAMSX3("C1_COTACAO")[2]},;
	         {"C1_APROV"  ,"C", TAMSX3("C1_APROV")[1]  ,TAMSX3("C1_APROV")[2]}  ,;
	         {"C1_QUANT"  ,"N", TAMSX3("C1_QUANT")[1]  ,TAMSX3("C1_QUANT")[2]}  ,;
	         {"C1_IMPORT" ,"C", TAMSX3("C1_IMPORT")[1] ,TAMSX3("C1_IMPORT")[2]}}

	If NGCADICBASE("C1_FLAGGCT","A","SC1",.F.)
		aAdd(aDBF,{"C1_FLAGGCT","C",TAMSX3("C1_FLAGGCT")[1],TAMSX3("C1_FLAGGCT")[2]})
	EndIf
	If NGCADICBASE("C1_TIPO","A","SC1",.F.)
		aAdd(aDBF,{"C1_TIPO","N",TAMSX3("C1_TIPO")[1],TAMSX3("C1_TIPO")[2]})
	EndIf

	aTRB := {{STR0002,"OS"      ,"C" , TAMSX3("TJ_ORDEM")[1]  ,TAMSX3("TJ_ORDEM")[2]  ,NGSEEKDIC("SX3","TJ_ORDEM"  ,2,"X3_PICTURE")},; //"Número O.S."
	         {STR0003,"SOLCOM"  ,"C" , TAMSX3("C1_NUM")[1]    ,TAMSX3("C1_NUM")[2]    ,NGSEEKDIC("SX3","C1_NUM"    ,2,"X3_PICTURE")},; //"Número S.C."
	         {STR0004,"CODPRO"  ,"C" , TAMSX3("C1_PRODUTO")[1],TAMSX3("C1_PRODUTO")[2],NGSEEKDIC("SX3","C1_PRODUTO",2,"X3_PICTURE")},; //"Produto"
	         {STR0005,"DESPRO"  ,"C" , TAMSX3("C1_DESCRI")[1] ,TAMSX3("C1_DESCRI")[2] ,NGSEEKDIC("SX3","C1_DESCRI" ,2,"X3_PICTURE")},; //"Descrição"
	         {STR0006,"C1_QUANT","N" ,TAMSX3("C1_QUANT")[1]   ,TAMSX3("C1_QUANT")[2]  ,NGSEEKDIC("SX3","C1_QUANT"  ,2,"X3_PICTURE")},; //"Qtde."
	         {STR0007,"UNMD"    ,"C" , TAMSX3("C1_UM")[1]     ,TAMSX3("C1_UM")[2]     ,NGSEEKDIC("SX3","C1_UM"     ,2,"X3_PICTURE")},; //"Unid. Med."
	         {STR0008,"DTEMISS" ,"D" , TAMSX3("C1_EMISSAO")[1],TAMSX3("C1_EMISSAO")[2],NGSEEKDIC("SX3","C1_EMISSAO",2,"X3_PICTURE")},; //"Dt. Emissão"
	         {STR0009,"PEDIDO"  ,"C" , TAMSX3("C1_PEDIDO")[1] ,TAMSX3("C1_PEDIDO")[2] ,NGSEEKDIC("SX3","C1_PEDIDO" ,2,"X3_PICTURE")},; //"Pedido"
	         {STR0010,"DATPRF"  ,"D" , TAMSX3("C1_DATPRF")[1] ,TAMSX3("C1_DATPRF")[2] ,NGSEEKDIC("SX3","C1_DATPRF" ,2,"X3_PICTURE")}} //"Dt. Prev. Ent."

	aIdxTRB    := {{"OS","SOLCOM","DTEMISS"}}
	oTmpTblTRB := NGFwTmpTbl(cTRB,aDBF,aIdxTRB)

	Processa({ |lEnd| MNT290SC1(cOsIni, cOsFim) },STR0011) //"Aguarde... Selecionando Registros..."

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Semafaro do Browse conforme MATA110.PRX                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If GetNewPar("MV_APROVSI",.F.)
		//-- Integracao com o modulo de Gestao de Contratos
		If SC1->(FieldPos("C1_FLAGGCT")) > 0
			aAdd(aCores,{'C1_FLAGGCT == "1" ','BR_MARROM',"SC Totalmente Atendida pelo SIGAGCT"})  //SC Totalmente Atendida pelo SIGAGCT
		EndIf
		If SC1->(FieldPos("C1_TIPO")) > 0
			aAdd(aCores,{'C1_TIPO==2','BR_BRANCO',"Solicitacao de Importacao"})  //Solicitacao de Importacao
		Endif
		aAdd(aCores,{'!Empty(C1_RESIDUO)','BR_PRETO',"SC Eliminada por Residuo"})  //SC Eliminada por Residuo
		aAdd(aCores,{'C1_QUJE==0.And.C1_COTACAO==Space(Len(C1_COTACAO)).And.C1_APROV$" ,L"','ENABLE',"SC em Aberto"})	//SC em Aberto
		aAdd(aCores,{'C1_QUJE==0.And.(C1_COTACAO==Space(Len(C1_COTACAO)).Or.C1_COTACAO=="IMPORT").And.C1_APROV="R"','BR_LARANJA',"SC Rejeitada"})	//SC Rejeitada
		aAdd(aCores,{'C1_QUJE==0.And.(C1_COTACAO==Space(Len(C1_COTACAO)).Or.C1_COTACAO=="IMPORT").And.C1_APROV="B"','BR_CINZA',"SC Bloqueada"})	//SC Bloqueada
		aAdd(aCores,{'C1_QUJE==C1_QUANT','DISABLE',"SC com Pedido Colocado"})	//SC com Pedido Colocado
		aAdd(aCores,{'C1_QUJE>0','BR_AMARELO',"SC com Pedido Colocado Parcial"})	//SC com Pedido Colocado Parcial
		aAdd(aCores,{'C1_QUJE==0.And.C1_COTACAO<>Space(Len(C1_COTACAO)).And. C1_IMPORT <>"S" ','BR_AZUL',"SC em Processo de Cotacao"})	//SC em Processo de Cotacao
		aAdd(aCores,{'C1_QUJE==0.And.C1_COTACAO<>Space(Len(C1_COTACAO)).And. C1_IMPORT =="S".And.C1_APROV$" ,L"','BR_PINK',"SC com Produto Importado"})	//SC com Produto Importado
	Else
		//-- Integracao com o modulo de Gestao de Contratos
		If SC1->(FieldPos("C1_FLAGGCT")) > 0
			aAdd(aCores,{'C1_FLAGGCT=="1"','BR_MARROM',"SC Totalmente Atendida pelo SIGAGCT"})  //SC Totalmente Atendida pelo SIGAGCT
		EndIf
		If SC1->(FieldPos("C1_TIPO")) > 0
			aAdd(aCores,{'C1_TIPO==2','BR_BRANCO',"Solicitacao de Importacao"})  //Solicitacao de Importacao
		EndIf
		aAdd(aCores,{'!Empty(C1_RESIDUO)','BR_PRETO',"SC Eliminada por Residuo"})	//SC Eliminada por Residuo
		aAdd(aCores,{'C1_QUJE==0.And.C1_COTACAO==Space(Len(C1_COTACAO)).And.C1_APROV$" ,L"','ENABLE',"SC em Aberto"})  //SC em Aberto
		aAdd(aCores,{'C1_QUJE==0.And.C1_COTACAO==Space(Len(C1_COTACAO)).And.C1_APROV="R"','BR_LARANJA',"SC Rejeitada"})  //SC Rejeitada
		aAdd(aCores,{'C1_QUJE==0.And.C1_COTACAO==Space(Len(C1_COTACAO)).And.C1_APROV="B"','BR_CINZA',"SC Bloqueada"})  //SC Bloqueada
		aAdd(aCores,{'C1_QUJE==C1_QUANT','DISABLE',"SC com Pedido Colocado"})  //SC com Pedido Colocado
		aAdd(aCores,{'C1_QUJE>0','BR_AMARELO',"SC com Pedido Colocado Parcial"})  //SC com Pedido Colocado Parcial
		aAdd(aCores,{'C1_QUJE==0.And.C1_COTACAO<>Space(Len(C1_COTACAO)).And. C1_IMPORT <>"S" ','BR_AZUL',"SC em Processo de Cotacao"})  //SC em Processo de Cotacao
		aAdd(aCores,{'C1_QUJE==0.And.C1_COTACAO<>Space(Len(C1_COTACAO)).And. C1_IMPORT =="S"','BR_PINK',"SC com Produto Importado"})  //SC com Produto Importado
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada para alterar cores do Browse do Cadastro    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("MT110COR")
		aCoresNew := ExecBlock("MT110COR",.F.,.F.,{aCores})
		If ValType(aCoresNew) == "A"
			aCores := aCoresNew
		EndIf
	EndIf

	dbSelectArea((cTRB))
	dbSetOrder(01)
	dbGoTop()

	oBrowse:= FWMBrowse():New()
	oBrowse:SetDescription(cCadastro)
	oBrowse:SetTemporary(.T.)
	oBrowse:SetAlias(cTRB)
	oBrowse:SetFields(aTRB)
	For x := 1 To Len(aCores)
		oBrowse:AddLegend(aCores[x][1],aCores[x][2],aCores[x][3])
	Next x
	oBrowse:SetSeek(.F.,aPesq)
	oBrowse:Activate()

	//Deleta o arquivo temporario fisicamente
	oTmpTblTRB:Delete()
	SetFunName( cOldProg ) // Retoma a função de origem como Pai.
	NGRETURNPRM(aNGBEGINPRM)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT290SC1
Processa os arquivos e carrega arquivo temporario

@author	Felipe N. Welter
@since 16/07/09

@sample MNT290SC1()

@param cOsIni, Caracter, Numero da OS inicial que será verificada.
       cOsFim, Caracter, Numero da OS final que será verificada.
@return
/*/
//---------------------------------------------------------------------
Static Function MNT290SC1(cOsIni, cOsFim)

	dbSelectArea("STJ")
	dbSetOrder(01)

	ProcRegua(LastRec())

	dbSeek(xFilial("STJ") + cOsIni,.T.)

	While !Eof() .And. STJ->TJ_FILIAL == xFilial("STJ") .And. ;
	STJ->TJ_ORDEM >= cOsIni .And. STJ->TJ_ORDEM <= cOsFim

		IncProc()

		dbSelectArea("SC1")
		dbSetOrder(04)
		dbSeek(xFilial("SC1") + STJ->TJ_ORDEM + "OS001")
		While !Eof() .And. SC1->C1_FILIAL  == xFilial("SC1") .And.;
		SUBSTR(SC1->C1_OP,1,11) == STJ->TJ_ORDEM + "OS001"

			(cTRB)->(dbAppend())
			(cTRB)->SOLCOM := SC1->C1_NUM
			(cTRB)->ITEMCO := SC1->C1_ITEM
			(cTRB)->CODPRO := SC1->C1_PRODUTO
			(cTRB)->DESPRO := SC1->C1_DESCRI
			(cTRB)->C1_QUANT := SC1->C1_QUANT
			(cTRB)->UNMD := SC1->C1_UM
			(cTRB)->DTEMISS := SC1->C1_EMISSAO
			(cTRB)->PEDIDO := SC1->C1_PEDIDO
			(cTRB)->DATPRF := SC1->C1_DATPRF
			(cTRB)->OS := STJ->TJ_ORDEM

			If NGCADICBASE("C1_FLAGGCT","A","SC1",.F.)
				(cTRB)->C1_FLAGGCT := SC1->C1_FLAGGCT
			EndIf
			If NGCADICBASE("C1_TIPO","A","SC1",.F.)
				(cTRB)->C1_TIPO := SC1->C1_TIPO
			EndIf
			(cTRB)->C1_RESIDUO := SC1->C1_RESIDUO
			(cTRB)->C1_QUJE := SC1->C1_QUJE
			(cTRB)->C1_COTACAO := SC1->C1_COTACAO
			(cTRB)->C1_APROV := SC1->C1_APROV
			(cTRB)->C1_IMPORT := SC1->C1_IMPORT

			dbSelectArea("SC1")
			dbSkip()
		EndDo

		dbSelectArea("STJ")
		dbSkip()
	EndDo

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNTC290VIS³ Autor ³ Felipe N. Welter      ³ Data ³ 16/07/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Posiciona registro para visualizacao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GENERICO                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNTC290VIS()

	dbSelectArea("SC1")
	dbSetOrder(01)
	dbSeek(xFilial('SC1')+(cTRB)->SOLCOM+(cTRB)->ITEMCO)
	A110Visual("SC1",Recno(),2)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNTC290IMP³ Autor ³ Felipe N. Welter      ³ Data ³ 16/07/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Posiciona registro para impressao                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GENERICO                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNTC290IMP()

	dbSelectArea("SC1")
	dbSetOrder(01)
	dbSeek(xFilial('SC1')+(cTRB)->SOLCOM+(cTRB)->ITEMCO)
	A110Impri("SC1",Recno(),2)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Felipe N. Welter      ³ Data ³ 16/07/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Utilizacao de menu Funcional                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados         ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

	Local aRotina  := {{STR0012,"MNTC290VIS", 0, 2},;    //"Visualizar"
	{STR0014,"MNTC290IMP",0,4,0,NIL}} //"Imprimir"
Return(aRotina)
