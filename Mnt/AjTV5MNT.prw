#Include "Protheus.ch"
#Include "FWBROWSE.CH"

#DEFINE BUTTON_CONFIRM "QPushButton{ border-radius: 3px;border: 1px solid #3079ED; color: #FFFFFF; background-color: #30A8CD;  }"
#DEFINE BUTTON_CLOSE "QPushButton{ border-radius: 3px;border: 1px solid #3079ED; color: #FFFFFF; background-color: #FF0000;  }"

//---------------------------------------------------------------------
/*/{Protheus.doc} AjTV5MNT
Define as mudancas a serem feitas na base de dados

@author Bruno Lobo de Souza
@since 30/05/2016
@version MP12
/*/
//---------------------------------------------------------------------
Function AjTV5MNT()


	Local cCadastro	:= OemtoAnsi("Atualização de material rodante metálico")
	Local aSizeScr	:= MsAdvSize()
	Local oTempBrw

	Private cMVPAR01 := Space(FwSizeFilial())
	Private cMVPAR02 := Replicate("Z",FwSizeFilial())
	Private cTrbBrw
	Private oDlg, oBrw, oColumn, oFont12B
	Private oPnlFilter, oPnlClose, oPnlBrw

	cTrbBrw	:= GetNextAlias()

	aDbfBrw := {}
	aAdd(aDbfBrw,{ "EMPRESA", "C" , 02, 0 })
	aAdd(aDbfBrw,{ "DESEMP" , "C" , 20, 0 })
	aAdd(aDbfBrw,{ "FILIAL" , "C" , FWSIZEFILIAL(), 0 })
	aAdd(aDbfBrw,{ "DESFIL" , "C" , 20, 0 })
	aAdd(aDbfBrw,{ "CODBEM" , "C" , 16, 0 })
	aAdd(aDbfBrw,{ "NOMBEM" , "C" , 20, 0 })

	oTempBrw:= FWTemporaryTable():New( cTrbBrw, aDbfBrw )
	oTempBrw:AddIndex( "1", {"EMPRESA","FILIAL","CODBEM"} )
	oTempBrw:Create()

	Define MsDialog oDlg Title cCadastro From aSizeScr[7],0 To aSizeScr[6], aSizeScr[5];
		COLOR CLR_BLACK,CLR_WHITE STYLE nOr(WS_POPUP,WS_VISIBLE) Pixel
		oDlg:lEscClose := .F.

		oFont12 := TFont():New("Trebuchet MS",,-12)
		oFont12B := TFont():New("Trebuchet MS",,-14,.T.)


		oPnlFilter := TPanel():New( 01, 01,, oDlg,,,, CLR_BLACK, CLR_WHITE, 150, 70, .F., .F.)
			oPnlFilter:Align := CONTROL_ALIGN_TOP

		oPnlClose := TPanel():New( 01, 01,, oPnlFilter,,,, CLR_BLACK, CLR_WHITE, 10, 10, .F., .F.)
			oPnlClose:Align := CONTROL_ALIGN_RIGHT

		@ 30, 150 Button oClose Prompt "X" Action (oDlg:End()) Size 30,10 Font oFont12B Of oPnlClose Pixel
				oClose:SetCss(BUTTON_CLOSE)
				oClose:Align := CONTROL_ALIGN_TOP

		oPnlBrw := TPanel():New( 01, 01,, oDlg,,,, CLR_BLACK, CLR_WHITE, 50, 50, .F., .F.)
			oPnlBrw:Align := CONTROL_ALIGN_ALLCLIENT

		@ 010,020 Say Oemtoansi("De Filial  ?") Of oPnlFilter Pixel
		@ 030,020 Say Oemtoansi("Até Filial ?") Of oPnlFilter Pixel
		@ 005,060 MsGet oMVPAR01 Var cMVPAR01 Size 16,12 Font oFont12 Picture "@!" F3 "XM0" Hasbutton of oPnlFilter Pixel
		@ 025,060 MsGet oMVPAR02 Var cMVPAR02 Size 16,12 Font oFont12 Picture "@!" F3 "XM0" Hasbutton of oPnlFilter Pixel
		@ 50, 20 Button oOk Prompt "Buscar" Action (fTrbBrw()) Size 76,16 Font oFont12B Of oPnlFilter Pixel
				oOk:SetCss(BUTTON_CONFIRM)
		@ 030,160 Say Oemtoansi("Para alterar a medição inicial dê um duplo-click no registro do browse.") Font oFont12B Of oPnlFilter Pixel

		//-------------------------------------------------------------------
		// Define o Browse
		//-------------------------------------------------------------------
		fCriaBrowse()

	Activate MSDIALOG oDlg Centered

	//Deleta arquivo temporário
	oTempBrw:Delete()

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fCriaBrowse
Cria o Browse com registros das medições iniciais.

@author Bruno Lobo de Souza
@since 04/07/2016
@version MP12
/*/
//---------------------------------------------------------------------
Static Function fCriaBrowse()

	Define FwFormBrowse oBrw Data Table Alias cTrbBrw Of oPnlBrw
    oBrw:bLDblClick := { |oBrw| cFilAnt := (cTrbBrw)->FILIAL, MNTA688((cTrbBrw)->CODBEM), oBrw:Refresh() }
	oBrw:SetSizeBrowse(100)
	oBrw:SetTemporary(.T.)
	oBrw:DisableDetails()

	ADD COLUMN oColumn Data { || (cTrbBrw)->EMPRESA	} Title "Empresa"	SIZE 02 OF oBrw
    ADD COLUMN oColumn Data { || (cTrbBrw)->DESEMP	} Title "Descrição"	SIZE 20 OF oBrw
    ADD COLUMN oColumn Data { || (cTrbBrw)->FILIAL	} Title "Filial"	SIZE 12 OF oBrw
    ADD COLUMN oColumn Data { || (cTrbBrw)->DESFIL	} Title "Descrição"	SIZE 20 OF oBrw
    ADD COLUMN oColumn Data { || (cTrbBrw)->CODBEM	} Title "Bem"		SIZE 16 OF oBrw
    ADD COLUMN oColumn Data { || (cTrbBrw)->NOMBEM	} Title "Nome"		SIZE 20 OF oBrw

	Activate FwFormBrowse oBrw

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fTrbBrw
Geracao do arquivo temporario

@author Bruno Lobo
@since 06/02/13
/*/
//---------------------------------------------------------------------
Static Function fTrbBrw()

	Local cAliasQry := GetNextAlias()
	Local nCont := 0

	cQuery := " SELECT "
	cQuery += " TV5.TV5_FILIAL, TV5.TV5_CODBEM"
	cQuery += " FROM " + RetSqlName("TV5") + " TV5"
	cQuery += " WHERE "
	cQuery += "       TV5.TV5_FILIAL >= '"+cMVPAR01+"'"
	cQuery += " AND   TV5.TV5_FILIAL <= '"+cMVPAR02+"'"
	cQuery += " AND   TV5.D_E_L_E_T_ <> '*' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	dbSelectArea("SM0")

	dbSelectArea(cTrbBrw)
	dbSetOrder(1)
	ZAP

	dbSelectArea(cAliasQry)
	dbGoTop()
	While !Eof()

		If (cTrbBrw)->(!dbSeek( SM0->M0_CODIGO+(cAliasQry)->TV5_FILIAL+(cAliasQry)->TV5_CODBEM ))

			// Monta tabela temporaria
		    DbSelectArea(cTrbBrw)
			RecLock(cTrbBrw,.T.)
			(cTrbBrw)->EMPRESA	:= SM0->M0_CODIGO
			(cTrbBrw)->DESEMP	:= SM0->M0_NOME
			(cTrbBrw)->FILIAL	:= (cAliasQry)->TV5_FILIAL
			(cTrbBrw)->DESFIL	:= FWFILIALNAME(, (cAliasQry)->TV5_FILIAL )
			(cTrbBrw)->CODBEM	:= (cAliasQry)->TV5_CODBEM
			(cTrbBrw)->NOMBEM	:= NgSeek("ST9",(cAliasQry)->TV5_CODBEM,1,"ST9->T9_NOME")
		    MsUnlock(cTrbBrw)
		    nCont++
		EndIf

		dbSelectArea(cAliasQry)
		dbSkip()
	End
	(cAliasQry)->(dbCloseArea())

	dbSelectArea(cTrbBrw)
	dbGoTop()

	If ValType(oBrw) == "O"
		oBrw:DeActivate( .T. )
		fCriaBrowse()
	EndIf

Return .T.