#INCLUDE "MNTA905.CH"
#INCLUDE "Protheus.CH"
#DEFINE _nVERSAO 3 //Versao do fonte

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA905
Rotina de desenvolvimento de Planta Grafica, possibilitando fazer a total
alteração da Árvore Lógica e sua representação gráfica.

@author Vitor Emanuel Batista
@since 04/03/2010
@build 7.00.100601A-20100707
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Function MNTA905
	Local lOpened := Type("oMainWnd") == "O"
	Local lExect  := fValRunRot()//Verifica a execução da rotina.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Guarda conteudo e declara variaveis padroes ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aNGBEGINPRM := If(lOpened,NGBEGINPRM(_nVERSAO,"MNTA905",{},.T.,.T.),{})
	Local oDlg, oTPanel
	Local bClose
	
	//Variaveis de Largura/Altura da Janela
	Local aSize   := If(lOpened,MsAdvSize(,.f.,430),{0,0,0,0,(GetScreenRes()[1]-7),(GetScreenRes()[2]-85)})
	Local nColIni   := oMainWnd:nLeft+8
	Local nLinIni   := aSize[7]-2
	Local nLargura  := aSize[5]+4
	Local nAltura   := aSize[6]

	If lExect
		If !lOpened
			oDlg := tWindow():New( 0, 0, nAltura, nLargura,"",,,,,,,,CLR_BLACK,CLR_WHITE,,,,,,,.f. ) 
		Else
			Define Dialog oDlg From nLinIni,nColIni To nAltura,nLargura COLOR CLR_BLACK, CLR_WHITE STYLE nOr(DS_SYSMODAL,WS_MAXIMIZEBOX,WS_POPUP) Of oMainWnd Pixel
				oDlg:lMaximized := .T.
		EndIf
		
			oDlg:lEscClose := .F.
			oDlg:bValid := {|| oTPanel:Destroy()}
			oTPanel := TNGPG():New(oDlg,.T.)
				oTPanel:Activate()
			
		If !lOpened
			oDlg:bInit := {|| IncLocTAF(oTPanel)}
			oDlg:Activate("MAXIMIZED")
		Else
			ACTIVATE DIALOG oDlg ON INIT IncLocTAF(oTPanel)
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Retorna conteudo de variaveis padroes       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	NGRETURNPRM(aNGBEGINPRM)
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} IncLocTAF
Verifica e inclui o primeiro nivel da Arvore Logica

@author Vitor Emanuel Batista
@since 04/03/2010
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function IncLocTAF(oTPanel)
	//Guarda bloco de codigo das telhas de atalho
	Local aKeys := GetKeys()

	//Limpa tecla de atalhos para nao poderem ser executados
	RestKeys(,.T.)
	
	dbSelectArea("TAF")
	dbSetOrder(1)
	If !dbSeek(xFilial('TAF')+'001')
		While .T.
			oTPanel:SetBlackPnl(.T.)
			ShowHelpDlg(STR0001,	{STR0002},1,; //"ATENÇÃO"##"O primeiro nível da Árvore Lógica ainda não foi configurado."
										{STR0003},1) //"Informe a seguir os dados para o primeiro nível da Árvore Lógica."
			oTPanel:SetBlackPnl(.F.)
			If oTPanel:AlterLocTree()
				Exit
			EndIf
		EndDo
	EndIf

	//Restaura teclas de atalho
	RestKeys(aKeys,.T.)
Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fValRunRot
Verifica se é permitido a execução da rotina.

@author Guilherme Benkendorf
@since 30/06/2014
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fValRunRot()
	Local lSigaMdtPs:= SuperGetMv("MV_MDTPS",.F.,"N") == "S"
	Local lRet      := .T.

	If lSigaMdtPs
		MsgStop( STR0004 , STR0001 ) //"Prestador de Serviço não tem acesso a Árvore Lógica."###"Atenção"
		lRet := .F.
	Else
		//Verificação para a utilização da Planta Grafica em MDT
		If nModulo == 35 
			If !FindFunction("MNT902VlId")
				Aviso(OemToAnsi(STR0001), OemToAnsi(STR0005), {"Ok"})	//"Atenção"#"Repositório incompatível para esta operação, favor contatar o Administrador para atualizar."
				lRet := .F.
			ElseIf !NGCADICBASE( "TAF_CODAMB", "D", "TAF", .F. )
				NGINCOMPDIC( "UPDMDTA1" , "TPTZE6" )
				lRet := .F.
			ElseIf !NGCADICBASE( "TAF_EVEMDT", "D", "TAF", .F. )
				NGINCOMPDIC( "UPDMDTA3" , "TQEKGE" )
				lRet := .F.
			EndIf
		EndIf
	EndIf

Return lRet