#Include "MNTC855.ch"
#Include "Protheus.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTC855
Consulta de interface com o estoque
@author Soraia de Carvalho
@since 18/01/06
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Function MNTC855()

	Local oTempTable

	Private aRotina := MenuDef()
	Private cCadastro  := OemtoAnsi(STR0003) //"Consulta de Estoque"
	Private cPerg := "MNC855"
	Private aPerg := {}
	Private aPesq := {}
	Private cTRBB := GetNextAlias()


	SetKey( VK_F9, { | | NGVersao( "MNTC855" , 2 ) } )

	aPos1      := {15,1,95,315 }

	aDBFB := {}
		Aadd(aDBFB,{"COD"    ,"C", TAMSX3("TQF_CODIGO")[1],0,})
		Aadd(aDBFB,{"LOJA"   ,"C", 04,0})
		Aadd(aDBFB,{"HOMEB"  ,"C", 40,0})
		Aadd(aDBFB,{"QTDL"   ,"N", 09,2})
		Aadd(aDBFB,{"VALTOT" ,"N", 15,3})
		Aadd(aDBFB,{"VALUNI" ,"N", TAMSX3("TQN_VALUNI")[1]/*9*/,TAMSX3("TQN_VALUNI")[2]/*3*/})

	//Instancia classe FWTemporaryTable
	oTempTable := FWTemporaryTable():New( cTRBB, aDBFB )
	//Cria indices
	oTempTable:AddIndex( "Ind01" , {"HOMEB"} )
	oTempTable:AddIndex( "Ind02" , {"COD"}   )
	//Cria a tabela temporaria
	oTempTable:Create()


	aTRBB := { {STR0018,"COD"    ,"C",TAMSX3("A2_COD")[1],0,"@!"},; 	 	 	 	 	            //"Cod.Posto"
			   {STR0019,"LOJA"   ,"C",04,0, "@!" },;   	 	 	 	 	 	                        //"Loja"
			   {STR0009,"HOMEB"  ,"C",40,0, "@!" },; 	 	 	 	 	 	          	 	 	    //"Posto Interno"
			   {STR0010,"QTDL"   ,"N",09,2, "@E 999,999.99"},;     	 	 	 	 				    //"Total Litros"
			   {STR0011,"VALTOT" ,"N",15,3, "@E 99,999,999.999" },;  	 	 	 				    //"Valor Total"
			   {STR0012,"VALUNI" ,"N",09,3, '@E 99,999.'+Replicate('9',TAMSX3("TQN_VALUNI")[2]) }}  //"Valor Unitario"

	If pergunte("MNC855",.T.)
		Processa({ |lEnd| MNC855INI()}, STR0013)
		DbSelectarea(cTRBB)
		If Reccount() == 0
			Help(" ",1,"NGATENCAO",,STR0020,3,1)//"Não existem dados para montar a tela de consulta"
		Else
			DbSelectarea(cTRBB)
			DbGotop()

			aAdd( aPesq , { STR0009 ,{{"","C" , 255 , 0 ,"","@!"} }} )   // Indices de pesquisa
			aAdd( aPesq , { STR0018   ,{{"","C" , 255 , 0 ,"","@!"} }} ) // Indices de pesquisa

			oBrowse:= FWMBrowse():New()
			oBrowse:SetDescription(cCadastro)
			oBrowse:SetTemporary(.T.)
			oBrowse:SetAlias(cTRBB)
			oBrowse:SetFields(aTRBB)
			oBrowse:SetSeek(.T.,aPesq)
			oBrowse:Activate()
		EndIf
	Endif

	oTempTable:Delete()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} ATECD855
Validaçao do codigo do Posto Interno
@author Heverson Vitoreti
@since 18/04/06
@version undefined
@param ALIAS, , descricao
@param PAR1, , descricao
@param PAR2, , descricao
@param TAM, , descricao
@type function
/*/
//---------------------------------------------------------------------
Function ATECD855(ALIAS,PAR1,PAR2,TAM)
	If Empty(par2)
		Help(" ",1,STR0021,,STR0022,3,1)//"ATENÇÃO"##"Posto Interno final não pode ser vazio."
		Return .F.
	Elseif par2 < par1
		Help(" ",1,STR0021,,STR0023,3,1)//"ATENÇÃO"##"Posto Interno final informado é inválido."
		Return .F.
	Endif
	If par2 = Replicate('Z',Len(PAR2))
		Return .T.
	Else
		If !Atecodigo('TQF',Par1+Mv_Par04,Par2+Mv_Par06,08)
			Return .F.
		Endif
	Endif

	MNT855LO()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNC855INI
Monta o arquivo temporario inicial mostrado no browse
@author Soraia de Carvalho
@since 18/01/06
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Function MNC855INI()

	DbselectArea("TQN")
	DbSetorder(01)
	Dbseek(xFilial("TQN"))
	While !EoF() .and. xFilial("TQN") == TQN->TQN_FILIAL //.and. TQN->TQN_POSTO <= Mv_Par04

		If (TQN->TQN_POSTO <= Mv_Par03 .or. TQN->TQN_POSTO >= Mv_Par05) .And.;
		(TQN->TQN_LOJA < Mv_Par04 .or. TQN->TQN_LOJA > Mv_Par06)
			DbSelectArea("TQN")
			DbSkip()
			Loop
		Endif

		If !empty(Mv_par01) .and. !empty(Mv_par02)
			if TQN->TQN_DTABAS <Mv_Par01 .or. TQN->TQN_DTABAS > Mv_par02
				DbSelectArea("TQN")
				DbSkip()
				Loop
			EndIf

		Else
			DbSelectArea("TQN")
			DbSkip()
			Loop
		EndIf

		If !Empty(Mv_Par07)
			If TQN->TQN_CODCOM <> Mv_Par07
				DbSelectArea("TQN")
				DbSkip()
				Loop
			EndIf
		EndIf

		DbSelectArea("TQF")
		DbSetOrder(1)
		If DbSeek(xFilial("TQF")+TQN->TQN_POSTO)
			If TQF->TQF_TIPPOS <> "2"
				DbSelectArea("TQN")
				DbSkip()
				Loop
			EndIf
		EndIf

		DbSelectArea("TQM")
		DbSetOrder(1)
		If DbSeek(xFilial("TQM")+MV_PAR05)
			If TQM->TQM_CODCOM <> Mv_Par05
				DbSelectArea("TQN")
				DbSkip()
				Loop
			EndIf
		EndIf

		DbSelectArea("TQF")
		DbSetOrder(01)
		IF DbSeek(xFilial("TQF")+TQN->TQN_POSTO+TQN->TQN_LOJA)

			DbSelectArea(cTRBB)
			DbSetOrder(1)
			If !DbSeek(TQF->TQF_NREDUZ)
				RecLock((cTRBB), .T.)
				(cTRBB)->COD    := TQN->TQN_POSTO
				(cTRBB)->LOJA   := TQN->TQN_LOJA
				(cTRBB)->QTDL   := TQN->TQN_QUANT
				(cTRBB)->VALTOT := TQN->TQN_VALTOT
				(cTRBB)->VALUNI := TQN->TQN_VALUNI
				(cTRBB)->HOMEB  := TQF->TQF_NREDUZ
			Else
				RecLock((cTRBB),.f.)
				(cTRBB)->QTDL   += TQN->TQN_QUANT
				(cTRBB)->VALTOT += TQN->TQN_VALTOT
			EndIf
			MsUnLock(cTRBB)
		Endif

		DbselectArea("TQN")
		DbSkip()
	END

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNC855PA
Reprocessa o browse de acordo com os parametros
@author Soraia de Carvalho
@since 18/01/06
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Function MNC855PA()

	If !Pergunte("MNC855",.T.)
		Return
	EndIf

	DbSelectArea(cTRBB)
	Zap

	Processa({ |lEnd| MNC855INI() }, STR0013 )  //"Aguarde ..Processando Arquivo de Postos"
	DbSelectArea(cTRBB)
	DbGoTop()
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT855LOJA
Valida o parametro de Loja
@author Elisangela Costa
@since 06/01/06
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Function  MNT855LOJA()

	If Empty(MV_PAR03)
		MsgStop(STR0024)//"Informe o Codigo do Posto"
		Return .F.
		If !Empty(MV_PAR03)
			DbSelectArea("TQF")
			DbSetOrder(01)
			DbSeek (xFilial("TQF")+MV_PAR04)
			MV_PAR03 := TQF->TQF_CODIGO
		EndIf
	EndIf
	If !ExistCpo("TQF",MV_PAR03+MV_PAR04)
		Return .F.
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT855LO
Valida o parametro de Loja
@author Elisangela Costa
@since 06/01/06
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Function MNT855LO()

	If Empty(MV_PAR05)
		MsgStop(STR0024) //"Informe o Codigo do Posto"
		Return .F.
		If !Empty(MV_PAR05)
			DbSelectArea("TQF")
			DbSetOrder(01)
			DbSeek (xFilial("TQF")+MV_PAR06)
			MV_PAR05 := TQF->TQF_CODIGO
		EndIf
	EndIf
	If !ExistCpo("TQF",MV_PAR05+MV_PAR06)
		Return .F.
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT855DT
Valida o parametro ate data
@author Soraia de Carvalho
@since 25/07/06
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Function MNT855DT()

	If  MV_PAR02 < MV_PAR01
		MsgStop(STR0025) //"Data final não pode ser inferior à data inicial!"
		Return .F.
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Utilizacao de Menu Funcional.
@author Rafael Diogo Richter
@since 02/02/2008
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina :=	{{STR0002 ,"MNC855PA" ,0,3,0}}  //"Parametros"

	//+---------------------------------------------------------------------------+
	//| Parametros do array a Rotina:                                             |
	//|            1. Nome a aparecer no cabecalho                                |
	//|            2. Nome da Rotina associada                                    |
	//|            3. Reservado                                                   |
	//|            4. Tipo de Transa‡„o a ser efetuada:                           |
	//|            		1 - Pesquisa e Posiciona em um Banco de Dados             |
	//|                 2 - Simplesmente Mostra os Campos                         |
	//|                 3 - Inclui registros no Bancos de Dados                   |
	//|                 4 - Altera o registro corrente                            |
	//|                 5 - Remove o registro corrente do Banco de Dados          |
	//|            5. Nivel de acesso                                             |
	//|            6. Habilita Menu Funcional                                     |
	//+---------------------------------------------------------------------------+

Return aRotina
