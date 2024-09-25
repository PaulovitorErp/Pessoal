#INCLUDE 'mnta876.ch'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "Fileio.ch"

Static cArqFun    := 'mntrepcont.ngi' //Arquivo para salvar as inconsitencias.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA876
Rotina que realiza o Ajuste/Reprocessamento de Contador Próprio

@author Wexlei Silveira
@since 07/10/2015
@version P11
@return .T.
/*/
//---------------------------------------------------------------------
Function MNTA876()

	Local aOpcoes     := {}  //Array contendo as opções que podem ser selecionadas
	Local oProcess    := Nil

	Local oDlg        := Nil // Objeto do MsDialog da tela inicial de seleção
	Local oPnlGeneral := Nil
	Local oPnlTopSay  := Nil
	Local oPnlOption  := Nil
	Local oPnlDate    := Nil
	Local oPnlBottom  := Nil
	Local oGroup1     := Nil
	Local oGroup2     := Nil

	Local nOpcao      := 0   //Variável que armazena o numeral que representa se foi confirmada a execução (nOpcao == 1) ou fechada a rotina (nOpcao == 0)
	Local nOpcSel     := 1   //Variável que armazena o número da opção selecionada, sendo:
						  //1 - Exportar histórico de contador
						  //2 - Importar histórico de contador

	Private cTitle             //Define o cabeçalho da tela de Importação/Exportação
	Private cFile      := ""   //Variavel que armazena o nome do arquivo carregado pelo usuario
	Private cBkp       := ""   //Variavel que armazena o nome do arquivo de backup da STP
	Private oMark              // Objeto do markbrowse
	Private lInverte   := .F.
	Private cMarca     := GetMark()
	Private cAliasVl
	Private aRelacTbl  := {}
	Private aBens      := {}     //array com os bens, suas filiais, e descrição do erro
	Private cMens      := ""
	Private lErro      := .F.
	Private cIdx       := ""
	Private cStartPath := GetPvProfString(GetEnvServer(), "StartPath", "ERROR", GetADV97())
	Private cBarras    := IIf( isSRVunix(), '/', '\' )
	Private cDicPath   := GetPvProfString(GetEnvServer(), "StartPath", "ERROR", GetADV97())
	Private oGetDBF    //Objeto da GetDados do dbf carregado pelo usuário
	Private cTRBBKP
	Private cTRBDBF

	Private oPnlBtm     //Objeto do TPanel dos botões do markbrowse e da grid
	Private oPnlOK      //Objeto do TPanel do botão OK do markbrowse e da grid
	Private oPnlPar     //Objeto do TPanel do botão de parâmetros do markbrowse e da grid
	Private oPnlTop     //Objeto do TPanel da busca do markbrowse e da grid
	Private oPnlBusca   //Objeto do TPanel dos objetos de busca do markbrowse e da grid

	Private aSize  := MsAdvSize(,.f.,430)
	Private aErros := {}    //Array do registro com erro da TRB

	Private oDlgGrid        //Objeto do MsDialog da Grid de importação
	Private cPerg   :=  PadR( "MNTA876" , Len(Posicione("SX1", 1, "MNTA876", "X1_GRUPO")) )
	Private aST9Bkp := {}   //Array de backup da ST9
	Private lTRBBKP := .F.  //Informa se a TRB de backup já foi criada
	Private cInTRB1
	Private cInTRB2
	Private cInTRB3
	Private nPosFilial
	Private nPosCodBem
	Private nPosDtLeitu
	Private nPosHora
	Private nPosPosCont
	Private nPosAcumCon
	Private nPosTipoLan
	Private dtIni     := dDataBase
	Private oDtIni
	Private oCheck
	Private dParcial  := ""
	Private lCheck  := .F.
	Private lParcInc  := .F. // Informa se foi encontrado o registro de inclusão na base, mas não no arquivo, no caso de importação parcial
	Private aTemInc   := {}  // Informa se o bem tem Registro de inclusão, na base ou no arquivo
	Private cMV_Lanex := AllTrim( SuperGetMv( 'MV_NGLANEX', .F., '' ) ) // verifica uso do lanex no ambiente
	Private lSTYIni   := .F.
	Private aTipolan  := {}
	Private cLog      := ""
	Private lDelARQ   := .F.
	Private lDelMKB   := .F.
	Private cDbExt    := ".txt"
	Private cTempPath
	Private cNGPath
	Private aDBFSTP   := {}
	Private Firstrec  := 0  //Recno do primeiro registro do arquivo, usado para controle do DbSkip
	Private nAcumAnt  := 0  //Acumulado anterior (utilizado no cálculo do acumulado na função fInsSTP)
	Private nContAnt  := 0  //Contador anterior (utilizado no cálculo do acumulado na função fInsSTP)
	Private cChaveInc := "" //Chave do primeiro registro do bem (inclusão) (utilizado no cálculo do acumulado na função fInsSTP)
	Private cTRBMKB   := ""
	Private cTRBARQ   := GetNextAlias()
	Private oTempTBL  := Nil
	Private oTempBKP  := Nil

	CriaDirNG()

	cStartPath += IIF(SubStr(cStartPath, Len(cStartPath), 1) == cBarras,"",cBarras) + "NG"
	cDicPath   := IIf(Rat(cBarras,cDicPath) == Len(cDicPath),Substring(cDicPath,1,Len(cDicPath)-1),cDicPath)
	cTempPath  := GetTempPath()
	cNGPath    := GetPvProfString(GetEnvServer(), "RootPath", "ERROR", GetADV97()) + cStartPath

	dbSelectArea("SX1")
	dbSetOrder(01)
	If !dbSeek(cPerg+"01")
		ShowHelpDlg( STR0066 ,     ; // "ATENÇÃO!"
					{ STR0067 }, 2,; // "O dicionário de dados está desatualizado, o que pode comprometer a utilização de algumas rotinas."
					{ STR0068 }, 2 )  // "Favor aplicar as atualizações contidas no pacote da issue DNG-2319"
	Else

		Pergunte(cPerg,.F.)

		aAdd(aOpcoes, STR0002) // "Exportar histórico de contador"
		aAdd(aOpcoes, STR0003) // "Importar histórico de contador"

		Define MsDialog oDlg From 0,0 To 200,415 Title STR0001 Pixel Style DS_MODALFRAME // "Ajuste/Reprocessamento de Contador Próprio"

			oPnlGeneral := TPanel():New( 0, 0, , oDlg, , , , , , 210, 80, .F., .F.)
			oPnlGeneral:Align := CONTROL_ALIGN_ALLCLIENT

				oPnlTopSay := TPanel():New( 0, 0   , , oPnlGeneral, , , , , , 210, 40 )

					@ 05, 05 Say OemToAnsi( STR0004 ) Size 180, 30 Of oPnlTopSay Pixel

				oPnlOption := TPanel():New( 40, 0  , , oPnlGeneral, , , , , , 120, 40 )

					oGroup1 := TGroup():Create( oPnlOption, 7, 10, 36, 110, OemToAnsi( STR0005 ), , , .T. ) // A Partir de:

					TRadMenu():New( 15, 15, aOpcoes, {|u| IIf (PCount() == 0, nOpcSel, nOpcSel := u)}, oGroup1,,;
						{|u|IIF(nOpcSel == 2, EnableArea(.F.), EnableArea(.T.))},,,,,, 105, 60,,,, .T.)

				oPnlDate   := TPanel():New( 40, 115, , oPnlGeneral, , , , , , 90 , 40 )

					oCheck  := TCheckBox():New( 06, 15, OemToAnsi( STR0018 ), { |u| IIf( PCount() > 0, lCheck:=u, lCheck ) },; // Exportação parcial
						oPnlDate, 70, 7, , { ||EnableData() }, , , , , , .T., , , )

					oGroup2 := TGroup():Create( oPnlDate, 15, 15, 36, 75, OemToAnsi( STR0019 ), , , .T. ) // A Partir de:

					@ 23, 24 MSGET oDtIni VAR dtIni SIZE 45,08 Pixel OF oGroup2 Valid VlData( nOpcSel, dtIni );
						HASBUTTON PICTURE '99/99/99'

					oDtIni:Disable()

			oPnlBottom  := TPanel():New( 200, 0, , oDlg, , , , , , 210, 20, .F., .F.)
			oPnlBottom:Align := CONTROL_ALIGN_BOTTOM

				@ 5,120 BUTTON STR0020 SIZE 036,012 Pixel OF oPnlBottom ACTION( nOpcao := 0, oDlg:End() ) // Anterior
				@ 5,160 BUTTON STR0021 SIZE 036,012 Pixel OF oPnlBottom ACTION( nOpcao := 1, oDlg:End() ) // Próximo

		//Inicia o wizard de Ajuste/Reprocessamento de Contador Próprio
		Activate MsDialog oDlg Centered

		If(nOpcao == 1) //Botão "Próximo"

			If(nOpcSel == 1)

				fExpHist() //Exportar histórico de contador

			ElseIf(nOpcSel == 2)

				oProcess := MsNewProcess():New({|lEnd| fImpHist(.T., @oProcess, @lEnd) },STR0022,STR0023,.T.) // "Validando dados "###"Aguarde, carregando..."
				oProcess:Activate()

			EndIf

		Else //Botão "Anterior"

			MNTA875() //Volta para a tela de opções anterior

		EndIf
	EndIf

	If File(cArqFun) //Se encontrar o arquivo deleta para recriar
		FT_FUSE()
		FErase(cArqFun) //Deleta o arquivo
	EndIf

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fExpHist
Exportar histórico de contador

@sample
fExpHist()

@author Wexlei Silveira
@since 13/10/2015
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fExpHist()

	Local aDBF     := {}
	Local aInd     := {}
	Local cQryHist := ""
	Local oTempST9 := Nil

	cTitle   := STR0002 // "Exportar histórico de contador"
	cQryHist := "SELECT DISTINCT ST9.T9_FILIAL, ST9.T9_CODBEM, ST9.T9_NOME, ST9.T9_TIPMOD, ST9.T9_CODFAMI "+;
				"  FROM " + RetSqlName("ST9") + " ST9 "+;
				"  JOIN " + RetSqlName("STP") + " STP "+;
				"    ON ST9.T9_FILIAL = STP.TP_FILIAL "+;
				"   AND ST9.T9_CODBEM = STP.TP_CODBEM "+;
				" WHERE ST9.D_E_L_E_T_ <> '*' "+;
				"   AND (ST9.T9_SITBEM = 'A' OR ST9.T9_SITBEM = 'I') "+;
				"   AND ST9.T9_TEMCONT = 'S' "

	dbSelectArea("ST9")

	//Adiciona os campos que compõem o markbrowse e que constam na query: AAdd(aDBF, {campo,tipo,tamanho,casas decimais})
	AAdd(aDBF, {"OK"        ,"C",2,0})
	AAdd(aDBF, {"T9_FILIAL" ,"C",TAMSX3("T9_FILIAL")[1],0})
	AAdd(aDBF, {"T9_CODBEM" ,"C",TAMSX3("T9_CODBEM")[1],0})
	AAdd(aDBF, {"T9_NOME"   ,"C",TAMSX3("T9_NOME")[1],0})
	AAdd(aDBF, {"T9_TIPMOD" ,"C",TAMSX3("T9_TIPMOD")[1],0})
	AAdd(aDBF, {"T9_CODFAMI","C",TAMSX3("T9_CODFAMI")[1],0})
	("ST9")->(dbCloseArea())

	aInd := {{"T9_CODBEM"},;
			 {"T9_FILIAL"},;
			 {"T9_FILIAL","T9_CODBEM"},;
			 {"T9_TIPMOD"},;
			 {"T9_CODFAMI"},;
			 {"T9_FILIAL","T9_CODBEM","T9_TIPMOD","T9_CODFAMI"}}

	cTRBMKB  := GetNextAlias()
	oTempST9 := NGFwTmpTbl(cTRBMKB,aDBF,aInd)
	SqlToTrb(cQryHist,aDBF,cTRBMKB)

	fCriaMkb()

	If !lDelMKB
		(cTRBMKB)->(dbCloseArea())
		oTempST9:Delete()
	EndIf

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} EnableArea
Habilita ou desabilita os componentes da seleção de data da popup inicial

@sample
EnableArea(lEnable)

@param lEnable: booleano que indica se habilita ou desabilita
@author Wexlei Silveira
@since 21/07/2016
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function EnableArea(lEnable)

	If(lEnable)
		oCheck:Enable()
		If lCheck
			oDtIni:Enable()
		EndIf
	Else
		oCheck:Disable()
		oDtIni:Disable()
	EndIf

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} EnableData
Habilita ou desabilita os componentes da seleção de data da popup inicial

@sample
EnableArea(lEnable)

@author Wexlei Silveira
@since 21/07/2016
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function EnableData()

	If oDtIni != NIL

		If lCheck
			oDtIni:Enable()
		ElseIf Empty( dtIni )
			lCheck := .T.
			oCheck:CtrlRefresh()
		Else
			oDtIni:Disable()
		EndIf
	EndIf

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} VlData
Valida se a data é maior que a data base

@sample
VlData(dData)

@param dData: Data a ser validada
@param nOpcSel: Opção selecionada na tela inicial
@author Wexlei Silveira
@since 21/07/2016
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function VlData(nOpcSel, dData)

	lRet := .F.

	If lCheck .And. NaoVazio()

		If(nOpcSel == 1 .And. (dData > dDataBase))
			lRet := .F.
			MsgStop(STR0024,STR0013) //"Selecione uma data igual ou menor que a data atual."###"Atenção"
		Else
			lRet := .T.
		EndIf

	EndIf

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fImpHist
Importar histórico de contador

@sample
fImpHist()

@author Wexlei Silveira
@since 13/10/2015
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fImpHist(lAccess, oProcess, lEnd)

	Local lRet     := .T.
	Local cMsg     := ""
	Local lRecBKP  := .F.
	Local lRepFile := .F.
	Local nArqAtu := 0

	If cFile == ""
		cFile  := cGetFile(STR0025 + " (*" + cDbExt + ") |*" + cDbExt + "|", STR0026,, cNGPath, .T., GETF_LOCALHARD + GETF_NETWORKDRIVE, .T., .F.) //"Arquivos de Banco de dados"###"Abrir"
		cTitle := STR0003 //"Importar histórico de contador"
	EndIf

	If cFile != ""

		If lAccess
			If !fLoadArq(cFile,@oProcess,@lEnd) //Carrega o arquivo na TRB
				cFile := ""
				lRet := fImpHist(.T., @oProcess, @lEnd)
			EndIf
		EndIf

		If lRet

			If !fCriaGrid(@oProcess,@lEnd) //Exibe a grid com os registros do arquivo

				NGMSGMEMO(STR0027, STR0028) // "Reprocessamento de contador próprio"###"Processo cancelado pelo usuário."
				If !Empty(cBkp)
					If File(cStartPath + cBarras + "backup" + cBarras + cBkp) .And. (FErase(cStartPath + cBarras + "backup" + cBarras + cBkp) != 0)//Deleta o arquivo de backup
						oTempBKP:Delete()
						FErase(cStartPath + cBarras + "backup" + cBarras + cBkp)
					EndIf
				EndIf

				If !lDelARQ
					oTempTBL:Delete()
					lDelARQ := .T.
				EndIf

				lRet := .F.
			EndIf

		EndIf

		If lRet

			aErros := {}

			If File(cArqFun) //Se encontrar o arquivo deleta para recriar
				FT_FUSE()
				FErase(cArqFun) //Deleta o arquivo
				nArqAtu := fCreate(cArqFun) // Cria arquivo.
			Else
				nArqAtu := fCreate(cArqFun) // Cria arquivo.
			EndIf

			oProcess:SetRegua1(4)
			oProcess:IncRegua1(STR0029) // "Carregando dados..."

			fAtuTRB(@oProcess,@lEnd)//Atualiza a TRB com os dados alterados pelo usuário, e preenche o array aBens
			aSort(aBens)

			If lAccess
				oProcess:IncRegua1(STR0030) // "Efetuando backup..."
				cBkp := fBkpTab("STP", "TP_CODBEM", @oProcess, @lEnd)//Cria backup da STP (e retorna o nome e a extensão do arquivo criado)
			EndIf

			oProcess:IncRegua1(STR0022)     // "Validando dados..."
			If fIniValid(@oProcess,@lEnd,nArqAtu)  // Validações de relacionamento
				lRecBKP := .T.
			EndIf

			oProcess:IncRegua1(STR0031) // "Importando histórico de contador..."
			SetInclui()
			nAcumAnt := 0
			fImpSTP(@oProcess,@lEnd,nArqAtu) //Deleta o registro da STP, valida e executa a importação

			If lErro

				If lRecBKP
					fRecBkp()// Recupera o backup da STP dos bens com erro
					cMens += If(fDelRDbf(), "", CRLF + Replicate('-',15) + CRLF + STR0032+CRLF) // "Não foi possível alterar o arquivo ou gerar um backup, por isso, os bens que foram inseridos na base ainda continuam no arquivo."
					NGMSGMEMO(STR0027, cLog) // "Reprocessamento de contador próprio"
				Else
					//Exibe log dos erros encontrados
					fViewLog()
				EndIf

				cMens := ""
				lErro := .F.
				fImpHist(.F., @oProcess, @lEnd)

			Else

				If File(cStartPath + cBarras + "backup" + cBarras + cBkp) .And. (FErase(cStartPath + cBarras + "backup" + cBarras + cBkp) != 0)//Deleta o arquivo de backup
					oTempBKP:Delete()
					If File(cStartPath + cBarras + "backup" + cBarras + cBkp) .And. (FErase(cStartPath + cBarras + "backup" + cBarras + cBkp) != 0)//da pasta NG/backup
						MsgStop(STR0033,STR0013) //"Erro ao tentar remover o arquivo de backup."###"Atenção"
					EndIf
				EndIf

				MsgInfo(STR0006 + CRLF + STR0007)//Importação executada com sucesso
				lRet := .T.
				lRepFile := .T.
			EndIf

			If lEnd
				NGMSGMEMO(STR0034) // "Processo abortado."
				If File(cStartPath + cBarras + "backup" + cBarras + cBkp)
					FErase(cStartPath + cBarras + "backup" + cBarras + cBkp)//Deleta o arquivo de backup da pasta NG/backup
				EndIf
				lRet := .T.
			EndIf

		EndIf
	Else
		lRet := .F.
	EndIf

	If lRet

		If !lDelARQ
			oTempTBL:Delete()
			lDelARQ := .T.
		EndIf

		If lRepFile
			cFile := StrTran(cFile, "\", cBarras, 1,)

			If !File(cNGPath + cBarras + "processados" + cBarras + GetFileName(cFile))
				If(__CopyFile(cFile, cNGPath + cBarras + "processados" + cBarras + GetFileName(cFile)))
					FErase(cFile)
				EndIf
			EndIf


		EndIf

	EndIf

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fCriaMkb
Cria o markbrowse para exibir a exportação

@sample
fCriaMkb()

@author Wexlei Silveira
@since 15/10/2015
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fCriaMkb()

	Local nComboIdx := Nil
	Local cPesquisa := Space(30)
	Local aTRB      := {}
	Local aIdx      := {}

	AAdd(aTRB, {"OK"        ,"C",""})
	AAdd(aTRB, {"T9_FILIAL" ,"C","Filial"})
	AAdd(aTRB, {"T9_CODBEM" ,"C","Código do Bem"})
	AAdd(aTRB, {"T9_NOME"   ,"C","Nome"})
	AAdd(aTRB, {"T9_TIPMOD" ,"C","Tipo Modelo"})
	AAdd(aTRB, {"T9_CODFAMI","C","Família"})

	aAdd(aIdx, "Bem")
	aAdd(aIdx, "Filial")
	aAdd(aIdx, "Filial + Bem")
	aAdd(aIdx, "Tipo Modelo")
	aAdd(aIdx, "Família")
	aAdd(aIdx, "Filial + Bem + Tipo Modelo + Família")

	cIdx := aIdx[1]

	DbSelectArea(cTRBMKB)
	Dbgotop()

	DEFINE MSDIALOG oDlgMkb TITLE OemToAnsi(cTitle) From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd COLOR CLR_BLACK,CLR_WHITE PIXEL

		oMark       := MsSelect():NEW((cTRBMKB),"OK",,aTRB,@lInverte,@cMarca,,,,oDlgMkb)
		oMark:bMark := {|| fMark(cMarca,lInverte,(cTRBMKB)->(Recno())) .And. oMark:oBROWSE:REFRESH(.T.)}

		oMark:oBrowse:lHASMARK    := .T.
		oMark:oBrowse:lCANALLMARK := .F.
		oMark:oBrowse:Align       := CONTROL_ALIGN_ALLCLIENT

		oPnlTop       := TPanel():New(1, 1,, oDlgMkb,,,,,CLR_HGRAY, 400, 12, .F., .F.)
		oPnlTop:Align := CONTROL_ALIGN_TOP

		oPnlBusca       := TPanel():New(1, 1,, oPnlTop,,,,,CLR_HGRAY, 300, 12, .F., .F.)
		oPnlBusca:Align := CONTROL_ALIGN_LEFT

		nComboIdx := TComboBox():New(1, 2,{| u | If(PCount() > 0, cIdx := u, cIdx)}, aIdx, 90, 10, oPnlBusca,,,,,,.T.,,,,,,,,,"cIdx")

		@01,95 Get cPesquisa Size 120,8 Picture "@X XXXXXXXXXXXXXXXXXXXXXXXXXXXXX" Pixel Of oPnlBusca
		@01,220 BUTTON STR0130 SIZE 036,010 Pixel OF oPnlBusca ACTION(fBusca(cIdx, cPesquisa)) //"Pesquisar"

		oPnlBtm       := TPanel():New(200, 400,, oDlgMkb,,,,,CLR_HGRAY, 200, 12, .F., .F.)
		oPnlBtm:Align := CONTROL_ALIGN_BOTTOM

		oPnlOK       := TPanel():New(200, 400,, oPnlBtm,,,,,CLR_HGRAY, 80, 12, .F., .F.)
		oPnlOK:Align := CONTROL_ALIGN_RIGHT

		@ 01,01 BUTTON STR0120  SIZE 36,10 Pixel OF oPnlOK ACTION(oDlgMkb:End()) //"Cancelar"
		@ 01,40 BUTTON "OK"       SIZE 36,10 Pixel OF oPnlOK ACTION(fGeraArq())

	Activate MsDialog oDlgMkb Centered

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fMark
Efetua a marcação do registro

@sample
fMark(cMarca,lInverte,nRegs)

@author Wexlei Silveira
@since 15/10/2015
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fMark(cMarca,lInverte,nRegs)

Local aArea := GetArea()

DbSelectArea(cTRBMKB)
Dbgotop()
While !EoF()
	RecLock((cTRBMKB),.F.)
	If nRegs == (cTRBMKB)->(Recno())
		If IsMark("OK",cMarca,lInverte)
			(cTRBMKB)->OK := cMarca
			AAdd(aBens, (cTRBMKB)->T9_CODBEM)
		Else
			(cTRBMKB)->OK := "  "
			ADel(aBens, AScan(aBens,{|cBem| cBem == (cTRBMKB)->T9_CODBEM}))
			ASize(aBens, Len(aBens)-1)
		EndIf
	Endif
	Dbskip()
	(cTRBMKB)->(MSUnlock())
End

RestArea(aArea)

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fBusca
Efetua a busca do registro

@sample
fBusca(cIndex, cPesquisa)

@param cIndex: Indice de pesquisa do arquivo
@param cPesquisa: valor a ser pesquisado no arquivo
@author Wexlei Silveira
@since 15/10/2015
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fBusca(cIndex, cPesquisa)

	Local nRecno := 0

	If(Empty(Trim(cPesquisa)))

		MsgStop(STR0035) // "O campo de pesquisa está vazio."

	Else

		dbSelectArea(cTRBMKB)
		nRecno := (cTRBMKB)->( Recno() )

		If(cIndex == "Bem")
			dbSetOrder(01)
		ElseIf(cIndex == "Filial")
			dbSetOrder(02)
		ElseIf(cIndex == "Filial + Bem")
			dbSetOrder(03)
		ElseIf(cIndex == "Tipo Modelo")
			dbSetOrder(04)
		ElseIf(cIndex == "Família")
			dbSetOrder(05)
		ElseIf(cIndex == "Filial + Bem + Tipo Modelo + Família")
			dbSetOrder(06)
		EndIf

		If !dbSeek(Upper(cPesquisa))
			//-----------------------------------------------
			//Tratamento para reposicionar TRB
			//-----------------------------------------------
			If nRecno > 0
				(cTRBMKB)->( dbGoTo( nRecno ) )
			Else
				(cTRBMKB)->( dbGoTop( ) )
			EndIf
		EndIf

	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} GetFileName
Retorna o nome do arquivo do endereço especificado

@sample
GetFileName(cPath)

@param: cPath: string com o caminho completo do arquivo
@author Wexlei Silveira
@since 04/02/2016
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function GetFileName(cPath)

Local cFile := Right(cPath, Len(cPath)-RAt(cBarras,cPath))

Return cFile
//---------------------------------------------------------------------
/*/{Protheus.doc} CriaDirNG
Cria as pastas NG, NG\Backup e NG\Processados

@sample
CriaDirNG()

@author Wexlei Silveira
@since 18/02/2016
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function CriaDirNG()

	Local nRet := MakeDir(cDicPath + cBarras + "ng")
	Local lRet

	If !(nRet == 0 .Or. nRet == 5) //criou ou ja existe
		MsgStop( STR0036 + cValToChar( fError() ), STR0013 ) // Não foi possível criar o diretório. Erro:
		lRet := .F.
	Else
		nRet := MakeDir(cDicPath + cBarras + "ng" + cBarras + "backup")
		If !(nRet == 0 .Or. nRet == 5) //criou ou ja existe
			MsgStop( STR0036 + cValToChar( fError() ), STR0013 ) // Não foi possível criar o diretório. Erro:
			lRet := .F.
		Else
			lRet := .T.
		EndIf

		nRet := MakeDir(cDicPath + cBarras + "ng" + cBarras + "processados")
		If !(nRet == 0 .Or. nRet == 5) //criou ou ja existe
			MsgStop( STR0036 + cValToChar( fError() ), STR0013 ) // Não foi possível criar o diretório. Erro:
			lRet := .F.
		Else
			lRet := .T.
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fGeraArq
Cria o arquivo dbf/dtc com base nos bens selecionados e salva no diretório
padrão.

@sample
fGeraArq()

@author Wexlei Silveira
@since 15/10/2015
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fGeraArq()

	Local cArqDot    := "NG876" + RetSqlName("STP") + cValToChar(Year(Date())) + cValToChar(Month(Date())) +;
	                     StrZero(Day(Date()),2) + StrTran(Time(),":","")
	Local nLoop      := 0
	Local nArqLog    := 0
	Local lRet       := .T.
	Local oTempSTP   := Nil
	Local cBarras    := IIf( isSRVunix(), '/', '\' )
	Local cStartPath := AllTrim(GetSrvProfString("StartPath", cBarras))
	Local cBens      := ""
	Local cQryDbf    := ""
	Local cPosCont   := ""
	Local cAcumCon   := ""
	Local cDtLeit    := ""
	Local cLocalCpl  := ""

	If SubStr(cStartPath,Len(cStartPath),1) != cBarras
		cStartPath := cStartPath + cBarras
	EndIf

	If Len(aBens) == 0
		MsgStop(STR0037,STR0013) // "Selecione um ou mais registros para gerar o arquivo."###"Atenção"
		Return .F.
	EndIf

	Define MsDialog oDlg From 0,0 To 100,285 Title "Nome do arquivo" Pixel Style DS_MODALFRAME

		@06,05 Say STR0038 Pixel Of oDlg // "Nome do arquivo:"
		@05,50 Get cArqDot Size 80,10 Picture "@X XXXXXXXXXXXXXXXXXXXXXXXXXX" Pixel Of oDlg

		oPnlOK       := TPanel():New(100, 260,, oDlg,,,,,CLR_HGRAY, 200, 15, .F., .F.)
		oPnlOK:Align := CONTROL_ALIGN_BOTTOM

		@ 1,60 BUTTON "OK" SIZE 036,010 Pixel OF oPnlOK ACTION(oDlg:End())

	Activate MsDialog oDlg Centered

	cArqDot := StrTran(cArqDot, "\", "_", 1,) //Substitui caracteres inválidos para nomeação de arquivo
	cArqDot := StrTran(cArqDot, "/", "_", 1,)
	cArqDot := StrTran(cArqDot, ":", "_", 1,)
	cArqDot := StrTran(cArqDot, "*", "_", 1,)
	cArqDot := StrTran(cArqDot, "?", "_", 1,)
	cArqDot := StrTran(cArqDot, '"', "_", 1,)
	cArqDot := StrTran(cArqDot, "<", "_", 1,)
	cArqDot := StrTran(cArqDot, ">", "_", 1,)
	cArqDot := StrTran(cArqDot, "|", "_", 1,)
	cArqDot := RTrim(cArqDot) + cDbExt
	cBens   := ""

	cLocalCpl := cStartPath + cBarras + "NG" + cBarras + cArqDot

	For nLoop := 1 to Len(aBens)//Converte o array de bens marcados numa string sequencial
		cBens += "'"+AllTrim(aBens[nLoop])+"'" //separado por vírgula para se adequar ao comando SELECT
		cBens += If(nLoop < Len(aBens), ", ", "")
	Next nLoop

	//Adiciona os campos que compõem o arquivo gerado com o histórico de contador dos bens selecionados:
	aAdd(aDBFSTP, {"TP_FILIAL" ,"C",TAMSX3("TP_FILIAL" )[1],0})
	aAdd(aDBFSTP, {"TP_CODBEM" ,"C",TAMSX3("TP_CODBEM" )[1],0})
	aAdd(aDBFSTP, {"TP_DTLEITU","D",TAMSX3("TP_DTLEITU")[1],0})
	aAdd(aDBFSTP, {"TP_HORA"   ,"C",TAMSX3("TP_HORA"   )[1],0})
	aAdd(aDBFSTP, {"TP_POSCONT","N",TAMSX3("TP_POSCONT")[1],TAMSX3("TP_POSCONT")[2]})
	aAdd(aDBFSTP, {"TP_ACUMCON","N",TAMSX3("TP_ACUMCON")[1],TAMSX3("TP_ACUMCON")[2]})
	aAdd(aDBFSTP, {"TP_TIPOLAN","C",TAMSX3("TP_TIPOLAN")[1],0})
	aAdd(aDBFSTP, {"DT_PARCIAL","C",8,0})

	cQryDbf := "SELECT STP.TP_FILIAL, STP.TP_CODBEM, STP.TP_DTLEITU, STP.TP_HORA, STP.TP_POSCONT, STP.TP_ACUMCON, STP.TP_TIPOLAN, "
	cQryDbf	+= "'" + IIF(lCheck == .T., DToS(dtIni), "") + "' AS DT_PARCIAL"
	cQryDbf	+= "  FROM " + RetSqlName("STP")+" STP JOIN "+RetSQLName("ST9")+" ST9 "
	cQryDbf	+= "    ON STP.TP_FILIAL = ST9.T9_FILIAL"
	cQryDbf	+= "    AND STP.TP_CODBEM = ST9.T9_CODBEM"
	cQryDbf	+= " WHERE STP.D_E_L_E_T_ <> '*'"
	cQryDbf	+= "   AND ST9.D_E_L_E_T_ <> '*'"
	cQryDbf	+= "   AND TP_CODBEM IN ("+ cBens +")"

	If lCheck
		cQryDbf	+= "   AND STP.TP_DTLEITU >= '"+ DToS(dtIni) + "'"
	EndIf
	cQryDbf	+=	" ORDER BY TP_CODBEM, TP_DTLEITU, TP_HORA, TP_FILIAL ASC"

	cTRBDBF  := GetNextAlias()
	oTempSTP := NGFwTmpTbl(cTRBDBF,aDBFSTP,{{"TP_FILIAL"}})
	SqlToTrb(cQryDbf,aDBFSTP,cTRBDBF)

	If (cTRBDBF)->(RecCount()) == 0
		// "Não foram encontrados registros de contador "###"no período "###"para o(s) bem(ns) selecionado(s)."###"Atenção"
		MsgStop(STR0039 + IIF(lCheck, STR0040,"") + STR0041, STR0013)
		Return .F.
	EndIf

	nArqLog := fCreate(cLocalCpl,FC_NORMAL) // "diferenca_de_tabelas.txt"
	If fError() == 0 // Se não houver erro na criação, gera o TXT com as mensagens.

		dbSelectArea(cTRBDBF)
		dbGoTop()
		While !EoF()

			cDtLeit  := dToC((cTRBDBF)->TP_DTLEITU)
			cPosCont := cValToChar((cTRBDBF)->TP_POSCONT)
			cAcumCon := cValToChar((cTRBDBF)->TP_ACUMCON)

			cLineTxt := (cTRBDBF)->TP_FILIAL  + "|" +;
			            (cTRBDBF)->TP_CODBEM  + "|" +;
			            cDtLeit               + "|" +;
			            (cTRBDBF)->TP_HORA    + "|" +;
			            cPosCont              + "|" +;
			            cAcumCon              + "|" +;
			            (cTRBDBF)->TP_TIPOLAN + "|" +;
			            (cTRBDBF)->DT_PARCIAL

			fWrite(nArqLog,cLineTxt)
			fWrite(nArqLog,Chr(13) + Chr(10))

			dbSelectArea(cTRBDBF)
			dbSkip()

		EndDo

		fClose(nArqLog)
		MsgInfo(STR0015 + cNGPath + cBarras + cArqDot) //"Arquivo gerado com sucesso em: "

	Else
		MsgStop(STR0016 + cTRBDBF + cDbExt + STR0017 + cLocalCpl, STR0013) // "Erro ao criar arquivo "###" para pasta " //"Atenção"
		Return .F.
	EndIf

	(cTRBDBF)->(dbCloseArea())

	oTempSTP:Delete()
	oDlgMkb:End()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fBkpTab
Cria um arquivo de backup para a tabela

@sample
fBkpTab(cTable, cBem)

@param cTable - Nome da tabela a ser copiada - Obrigatorio
@param cBem - Nome do campo com o código do bem - Obrigatorio

@author Wexlei Silveira
@since 26/10/2015
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fBkpTab(cTable, cBem, oProcess,lEnd)

	Local cNameBKP   := RetSqlName(cTable) + "_" + cValToChar(Year(Date())) + cValToChar(Month(Date())) + cValToChar(Day(Date())) +;
					    StrTran(Time(),":","") + "_backup" + cDbExt
	Local cBens      := ""
	Local nLoop      := 0
	Local cQry       := ""
	Local cLineTxt   := ""
	Local cCampo     := ""
	Local cBarras    := IIf( isSRVunix(), '/', '\' )
	Local cStartPath := AllTrim(GetSrvProfString("StartPath", cBarras))
	Local cLocalCpl  := ""
	Local nArqLog    := 0
	Local nTotStrt   := 0
	Local nInd       := 0
	Local aStruct    := {}

	If SubStr(cStartPath,Len(cStartPath),1) != cBarras
		cStartPath := cStartPath + cBarras
	EndIf

	cLocalCpl  := cStartPath + "NG" + cBarras+ "backup" + cBarras + cNameBKP

	If cTable == ""
		Return "ERROR"
	EndIf

	oProcess:SetRegua2(Len(aBens))
	For nLoop := 1 to Len(aBens)//Converte o array de bens marcados numa string sequencial

		oProcess:IncRegua2(STR0042 + Trim(aBens[nLoop,1]) + "...") // "Efetuando backup do bem "
		cBens += "'" + AllTrim(aBens[nLoop,1]) + "'" //separado por vírgula para se adequar ao comando SELECT
		cBens += If(nLoop < Len(aBens), ", ", "")

	Next nLoop

	cQry := "SELECT * FROM " + RetSqlName(cTable) + " WHERE " + cBem + " IN ("+ cBens +") AND D_E_L_E_T_ <> '*'"

	dbSelectArea(cTable)
	dbGoTop()
	cTRBBKP  := GetNextAlias()
	aStruct  := DBStruct()
	nTotStrt := Len(aStruct)

	oTempBKP := NGFwTmpTbl(cTRBBKP,aStruct,{{FieldName(1)}})
	SqlToTrb(cQry,aStruct,cTRBBKP)

	nArqLog := fCreate(cLocalCpl,FC_NORMAL)
	If fError() == 0 // Se não houver erro na criação, gera o TXT com as mensagens.

		cLineTxt := ""
		For nInd := 1 To nTotStrt

			cLineTxt += aStruct[nInd][1] // Monta o cabeçalho
			If nInd == nTotStrt
				fWrite(nArqLog,cLineTxt)
				fWrite(nArqLog,Chr(13) + Chr(10))
			Else
				cLineTxt += "|"
			EndIf

		Next nInd

		dbSelectArea(cTRBBKP)
		dbGoTop()
		While !EoF() // Lê todas as linhas da TRB.

			cLineTxt := ""
			For nInd := 1 To nTotStrt // Lê todas a

				cCampo := cTRBBKP + "->" + aStruct[nInd][1] // Monta linhas

				// Valida o tipo do campo
				If aStruct[nInd][2] == "C"
					cLineTxt += &cCampo
				ElseIf aStruct[nInd][2] == "N"
					cLineTxt += cValToChar(&cCampo)
				ElseIf aStruct[nInd][2] == "D"
					cLineTxt += DtoC(&cCampo)
				EndIf

				If nInd == nTotStrt
					fWrite(nArqLog,cLineTxt)
					fWrite(nArqLog,Chr(13) + Chr(10))
				Else
					cLineTxt += "|"
				EndIf

			Next nInd

			dbSelectArea(cTRBBKP)
			dbSkip()

		End

		fClose(nArqLog)

	Else
		MsgStop(STR0043,STR0013) // "Erro ao criar arquivo de backup."###"Atenção"
		Return "ERROR"
	EndIf

Return cNameBKP

//---------------------------------------------------------------------
/*/{Protheus.doc} fLoadArq
Carrega o arquivo selecionado pelo usuário

@sample
fLoadArq(cFile)

@param cFile: caminho do arquivo selecionado pelo usuário
@author Wexlei Silveira
@since 26/10/2015
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fLoadArq(cFile,oProcess,lEnd)

	Local lRet     := .T.

	fMontaTRB()

	If File(cFile)

		FT_FUse(cFile)
		FT_FGoTop()
		While (!FT_FEof())

			cLinha := FT_FREADLN()
			aLinha := StrTokArr2(cLinha,"|",.T.)

			RecLock(cTRBARQ, .T.)
			(cTRBARQ)->TP_FILIAL  := aLinha[1]
			(cTRBARQ)->TP_CODBEM  := aLinha[2]
			(cTRBARQ)->TP_DTLEITU := cToD(aLinha[3])
			(cTRBARQ)->TP_HORA    := aLinha[4]
			(cTRBARQ)->TP_POSCONT := Val(aLinha[5])
			(cTRBARQ)->TP_ACUMCON := Val(aLinha[6])
			(cTRBARQ)->TP_TIPOLAN := aLinha[7]
			(cTRBARQ)->DT_PARCIAL := aLinha[8]
			(cTRBARQ)->(MSUnlock())
			FT_fSkip()

		End

		FT_fUse()

	Else
		MsgStop(STR0045) // "Não foi possível abrir o arquivo."
		lRet := .F.
	EndIf


Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fMontaTRB
Monta TRB que guardará os registros lidos do arquivo de importação

@author  Maicon André Pinheiro
@since   19/04/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function fMontaTRB()

	Local aCampos := {}
	Local aInd    := {}

	aAdd(aCampos, {"TP_FILIAL" ,"C",TAMSX3("TP_FILIAL")[1],0})
	aAdd(aCampos, {"TP_CODBEM" ,"C",TAMSX3("TP_CODBEM")[1],0})
	aAdd(aCampos, {"TP_DTLEITU","D",TAMSX3("TP_DTLEITU")[1],0})
	aAdd(aCampos, {"TP_HORA"   ,"C",TAMSX3("TP_HORA")[1],0})
	aAdd(aCampos, {"TP_POSCONT","N",TAMSX3("TP_POSCONT")[1],TAMSX3("TP_POSCONT")[2]})
	aAdd(aCampos, {"TP_ACUMCON","N",TAMSX3("TP_ACUMCON")[1],TAMSX3("TP_ACUMCON")[2]})
	aAdd(aCampos, {"TP_TIPOLAN","C",TAMSX3("TP_TIPOLAN")[1],0})
	aAdd(aCampos, {"DT_PARCIAL","C",8,0})

	aInd := {{"TP_CODBEM"},;
			 {"TP_CODBEM","TP_DTLEITU","TP_HORA"   ,"TP_FILIAL"},;
			 {"TP_FILIAL","TP_CODBEM" ,"TP_DTLEITU","TP_HORA"}}

	oTempTBL := NGFwTmpTbl(cTRBARQ,aCampos,aInd)

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fIniValid
Executa as validações iniciais dos bens

@sample
fIniValid()

@author Wexlei Silveira
@since 17/11/2015
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fIniValid(oProcess,lEnd, nArqAtu)

Local nX
Local cErro := ""

oProcess:SetRegua2(Len(aBens))
For nX := 1 To Len(aBens)

	oProcess:IncRegua2(STR0046 + Trim(aBens[nX,1])) // "Validando bem "

	cErro := fValidTpI(aBens[nX,1])//validacao inicial (tipo inclusao)

	fWrite(nArqAtu, cErro + If(!Empty(cErro), CRLF, "") ) //Marca o registro com erro

	cErro := MNT876VLT(aBens[nX,1])//valida relacionamentos

	fWrite(nArqAtu, cErro + If(!Empty(cErro), CRLF, "") )//Marca o registro com erro

	cErro := fValidHis(aBens[nX,1])//validacao inicial (em relacao as filiais)

	fWrite(nArqAtu,	cErro + If(!Empty(cErro), CRLF, "") ) //Marca o registro com erro

	If!Empty(aBens[nX, 3])
		lErro := .T.
	EndIf
Next nX

Return lErro
//---------------------------------------------------------------------
/*/{Protheus.doc} fAtuTRB
Atualiza a TRB com os dados alterados pelo usuário e insere no array aBens

@sample
fAtuTRB()

@author Wexlei Silveira
@since 02/12/2015
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fAtuTRB(oProcess,lEnd)

Local nX

dbSelectArea(cTRBARQ)
(cTRBARQ)->(dbGoTop())
While (cTRBARQ)->(!EoF())
	RecLock(cTRBARQ,.F.)
	DBDelete()
	(cTRBARQ)->(MsUnLock())
	dbSkip()
EndDo

For nX := 1 To Len(oGetDBF:aCols)
	If !oGetDBF:aCols[nX][Len(oGetDBF:aCols[nX])]
		RecLock(cTRBARQ, .T.)
		(cTRBARQ)->TP_FILIAL  := oGetDBF:aCols[nX][nPosFilial]
		(cTRBARQ)->TP_CODBEM  := oGetDBF:aCols[nX][nPosCodBem]
		(cTRBARQ)->TP_DTLEITU := oGetDBF:aCols[nX][nPosDtLeitu]
		(cTRBARQ)->TP_HORA    := oGetDBF:aCols[nX][nPosHora]
		(cTRBARQ)->TP_POSCONT := oGetDBF:aCols[nX][nPosPosCont]
		(cTRBARQ)->TP_ACUMCON := oGetDBF:aCols[nX][nPosAcumCon]
		(cTRBARQ)->TP_TIPOLAN := oGetDBF:aCols[nX][nPosTipoLan]
		(cTRBARQ)->DT_PARCIAL := dParcial
		(cTRBARQ)->(MSUnlock())
	EndIf
Next nX

dbSetOrder(01)
(cTRBARQ)->(dbGoTop())

Firstrec := (cTRBARQ)->(Recno())

aBens := {}

aAdd(aBens,{(cTRBARQ)->TP_CODBEM, {(cTRBARQ)->TP_FILIAL}, ""})

//carrega bens
oProcess:SetRegua2(Len(aBens))
While (cTRBARQ)->(!EoF())
	oProcess:IncRegua2("Carregando bem " + Trim((cTRBARQ)->TP_CODBEM) + "...")
	If (cTRBARQ)->TP_CODBEM == aBens[Len(aBens),1]
		If AScan(aBens[Len(aBens),2], {|x| x == (cTRBARQ)->TP_FILIAL }) == 0
			aAdd(aBens[Len(aBens),2], (cTRBARQ)->TP_FILIAL)
		EndIf
	Else
		aAdd(aBens,{(cTRBARQ)->TP_CODBEM, {(cTRBARQ)->TP_FILIAL}, ""})
	EndIf
	(cTRBARQ)->(dbSkip())
EndDo

aSort(aBens)

fST9Bkp(aBens)//Realiza backup da ST9

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fImpSTP
Deleta o registro da STP, executa as validações específicas dos bens e executa a importação

@param oProcess - Objeto da barra de processamento
@param lEnd     - Indica o fim da barra de processamento
@param nArqAtu  - Arquivo que salva as inconsistencias

@sample
fImpSTP()

@author Wexlei Silveira
@since 17/11/2015
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fImpSTP(oProcess,lEnd, nArqAtu)

	Local nX := 0
	Local nY := 0
	Local aAbast := {}
	Local aCont := {}
	Local aVirada := {}
	Local aAutonomia := {}
	Local ctime
	Local nPosConA := -1
	Local lBemTr := .F.
	Local cChave := ""
	Local oQuebra
	Local cBemLanex := ""

	oProcess:SetRegua2(Len(aBens))
	For nX := 1 To Len(aBens)

		oProcess:IncRegua2(STR0046 + Trim(aBens[nX,1])) // "Validando bem "

		lBemTr := .F.
		dbSelectArea("ST9")
		dbSetOrder(16)
		dbSeek(aBens[nX, 1], .T.)
		While !EoF() .And. ST9->T9_CODBEM == aBens[nX, 1]
			If(ST9->T9_CODBEM == aBens[nX, 1] .And. ST9->T9_SITBEM == "T")
				lBemTr := .T.
			EndIF
		ST9->(DbSkip())
		End
		("ST9")->(dbCloseArea())

		fDelSTP(nX)//Estando tudo ok, exclui registro do bem na STP da base

		nPosConA := -1
		
		If cMV_Lanex $ "A"
			//No caso de bloqueio de contador, repassa contador de abastecimento para os contadores subsequentes
			cBemLanex := IIf( FindFunction('NGUSELANEX'), NGUSELANEX( aBens[nX,1] ), cMV_Lanex )
		EndIf

		If cBemLanex $ "A"
			dbSelectArea(cTRBARQ)
			dbSetOrder(02)
			dbSeek(aBens[nX, 1], .T.)
			While (cTRBARQ)->(!EoF()) .And. (cTRBARQ)->TP_CODBEM == aBens[nX,1] .And. !lErro
				If (cTRBARQ)->TP_TIPOLAN $ "AQVI"
					nPosConA := (cTRBARQ)->TP_POSCONT
				ElseIf !((cTRBARQ)->TP_TIPOLAN $ "IQV") .And. nPosConA != -1
					RecLock(cTRBARQ,.F.)
					(cTRBARQ)->TP_POSCONT := nPosConA
					(cTRBARQ)->(MSUnlock())
				EndIf

			(cTRBARQ)->(dbSkip())
			End
		EndIf

		//agora valida os registros novos com as premissas básicas
		dbSelectArea(cTRBARQ)
		dbSetOrder(02)
		dbSeek(aBens[nX, 1], .T.)//Inicia as validações
		cChave := (cTRBARQ)->TP_CODBEM + DTOS((cTRBARQ)->TP_DTLEITU) + (cTRBARQ)->TP_HORA + (cTRBARQ)->TP_FILIAL
		While (cTRBARQ)->(!EoF()) .And. (cTRBARQ)->TP_CODBEM == aBens[nX,1]

			ctime := time()

			If nY > 0
				If (cTRBARQ)->TP_FILIAL == aCont[nY,2] .And. (cTRBARQ)->TP_CODBEM == aCont[nY,1] .And.;
				((cTRBARQ)->TP_TIPOLAN == "C" .Or. ((cTRBARQ)->TP_TIPOLAN == "A")) .And.;
				((cTRBARQ)->TP_DTLEITU > aCont[nY,5] .Or. ((cTRBARQ)->TP_DTLEITU == aCont[nY,5] .And.;
				(cTRBARQ)->TP_HORA > aCont[nY,6])) .And. (cTRBARQ)->TP_POSCONT < aCont[nY,3]
					// Marca o registro com erro
					fWrite(nArqAtu,   STR0047 + cValToChar((cTRBARQ)->TP_POSCONT) + STR0048 + cValToChar((cTRBARQ)->TP_DTLEITU) +; //"Posição "###" do contador, da data: "
									STR0049 + cValToChar((cTRBARQ)->TP_HORA) + STR0050 + cValToChar(aCont[nY,3]) +; // " e hora: "###" é menor que a posição anterior: "
									"." + CRLF ) // ". Este erro foi ignorado."

					lErro := .T.
					aAdd(aErros, cValToChar((cTRBARQ)->TP_FILIAL) + cValToChar((cTRBARQ)->TP_CODBEM) + DToS((cTRBARQ)->TP_DTLEITU) +;
					cValToChar((cTRBARQ)->TP_HORA) + cValToChar((cTRBARQ)->TP_POSCONT) + cValToChar((cTRBARQ)->TP_ACUMCON) +;
					cValToChar((cTRBARQ)->TP_TIPOLAN))
					(cTRBARQ)->(dbSkip())
					Loop
				EndIf

				If lBemTr .And. ((cTRBARQ)->TP_CODBEM == aCont[nY,1] .And. (cTRBARQ)->TP_DTLEITU == aCont[nY,5] .And.;
				(cTRBARQ)->TP_HORA == aCont[nY,6] .And. (cTRBARQ)->TP_POSCONT != aCont[nY,3])
					// Marca o registro com erro

					fWrite(nArqAtu,STR0047 + cValToChar((cTRBARQ)->TP_POSCONT) + STR0048 + cValToChar((cTRBARQ)->TP_DTLEITU) +; //"Posição "###" do contador, da data: "
									STR0049 + cValToChar((cTRBARQ)->TP_HORA) + STR0051 + cValToChar(aCont[nY,3]) +; // " e hora: "###" é diferente da posição anterior: "
									STR0052 + CRLF ) // " do bem transferido."

					lErro := .T.
					aAdd(aErros, cValToChar((cTRBARQ)->TP_FILIAL) + cValToChar((cTRBARQ)->TP_CODBEM) + DToS((cTRBARQ)->TP_DTLEITU) +;
					cValToChar((cTRBARQ)->TP_HORA) + cValToChar((cTRBARQ)->TP_POSCONT) + cValToChar((cTRBARQ)->TP_ACUMCON) +;
					cValToChar((cTRBARQ)->TP_TIPOLAN))
					(cTRBARQ)->(dbSkip())
					Loop
				EndIf
			EndIf

			aAdd(aCont, {(cTRBARQ)->TP_CODBEM, (cTRBARQ)->TP_FILIAL, (cTRBARQ)->TP_POSCONT, (cTRBARQ)->TP_TIPOLAN, (cTRBARQ)->TP_DTLEITU,;
						(cTRBARQ)->TP_HORA})
			nY := nY + 1

			If ((cTRBARQ)->TP_POSCONT) <= 0

				fWrite(nArqAtu, STR0053 + CRLF ) // "Posição do contador menor ou igual a zero."

				lErro := .T.
				aAdd(aErros, cValToChar((cTRBARQ)->TP_FILIAL) + cValToChar((cTRBARQ)->TP_CODBEM) + DToS((cTRBARQ)->TP_DTLEITU) +;
				cValToChar((cTRBARQ)->TP_HORA) + cValToChar((cTRBARQ)->TP_POSCONT) + cValToChar((cTRBARQ)->TP_ACUMCON) +;
				cValToChar((cTRBARQ)->TP_TIPOLAN))
				(cTRBARQ)->(dbSkip())
				Loop
			EndIf
			If Empty((cTRBARQ)->TP_DTLEITU)

				fWrite(nArqAtu, STR0054 + CRLF ) // "Campo Data Leitura é obrigatório."

				lErro := .T.
				aAdd(aErros, cValToChar((cTRBARQ)->TP_FILIAL) + cValToChar((cTRBARQ)->TP_CODBEM) + DToS((cTRBARQ)->TP_DTLEITU) +;
				cValToChar((cTRBARQ)->TP_HORA) + cValToChar((cTRBARQ)->TP_POSCONT) + cValToChar((cTRBARQ)->TP_ACUMCON) +;
				cValToChar((cTRBARQ)->TP_TIPOLAN))
				(cTRBARQ)->(dbSkip())
				Loop
			EndIf
			If Empty((cTRBARQ)->TP_HORA)

				fWrite(nArqAtu, STR0055 + CRLF ) // "Campo Hora é obrigatório."

				lErro := .T.
				aAdd(aErros, cValToChar((cTRBARQ)->TP_FILIAL) + cValToChar((cTRBARQ)->TP_CODBEM) + DToS((cTRBARQ)->TP_DTLEITU) +;
				cValToChar((cTRBARQ)->TP_HORA) + cValToChar((cTRBARQ)->TP_POSCONT) + cValToChar((cTRBARQ)->TP_ACUMCON) +;
				cValToChar((cTRBARQ)->TP_TIPOLAN))
				(cTRBARQ)->(dbSkip())
				Loop
			EndIf
			If Empty((cTRBARQ)->TP_POSCONT)

				fWrite(nArqAtu, STR0056 + CRLF ) // "Campo Contador é obrigatório."

				lErro := .T.
				aAdd(aErros, cValToChar((cTRBARQ)->TP_FILIAL) + cValToChar((cTRBARQ)->TP_CODBEM) + DToS((cTRBARQ)->TP_DTLEITU) +;
				cValToChar((cTRBARQ)->TP_HORA) + cValToChar((cTRBARQ)->TP_POSCONT) + cValToChar((cTRBARQ)->TP_ACUMCON) +;
				cValToChar((cTRBARQ)->TP_TIPOLAN))
				(cTRBARQ)->(dbSkip())
				Loop
			EndIf

			If((cTRBARQ)->TP_TIPOLAN == "C" .Or. (cTRBARQ)->TP_TIPOLAN == "A" .Or. (cTRBARQ)->TP_TIPOLAN == "P")

				If (cTRBARQ)->TP_TIPOLAN == "A"
					aAbast := fVlAbast((cTRBARQ)->TP_FILIAL,(cTRBARQ)->TP_CODBEM,DtoS((cTRBARQ)->TP_DTLEITU),(cTRBARQ)->TP_HORA)
					// A variavel aAbast quando retorna do NGUTIL04  na função NGVALABAST pode não retornar um array,
					//dependendo a versão do fonte NGUTIL04
					lRetAba := IIf(Valtype(aAbast) == "L" , aAbast, aAbast[1])
					If !lRetAba

						fWrite(nArqAtu, IIF(Valtype(aAbast) == "L", STR0057,aAbast[2]) + CRLF ) // "Já existe um lançamento com essas características"

						lErro := .T.
						aAdd(aErros, cValToChar((cTRBARQ)->TP_FILIAL) + cValToChar((cTRBARQ)->TP_CODBEM) + DToS((cTRBARQ)->TP_DTLEITU) +;
						cValToChar((cTRBARQ)->TP_HORA) + cValToChar((cTRBARQ)->TP_POSCONT) + cValToChar((cTRBARQ)->TP_ACUMCON) +;
						cValToChar((cTRBARQ)->TP_TIPOLAN))
						(cTRBARQ)->(dbSkip())
						Loop
					EndIf
				Endif
				If !CHKPOSLIM((cTRBARQ)->TP_CODBEM,(cTRBARQ)->TP_POSCONT,1,(cTRBARQ)->TP_FILIAL)

					fWrite(nArqAtu, STR0058 + CRLF )// "Contador informado e maior do que o Limite do Contador"

					lErro := .T.
					aAdd(aErros, cValToChar((cTRBARQ)->TP_FILIAL) + cValToChar((cTRBARQ)->TP_CODBEM) + DToS((cTRBARQ)->TP_DTLEITU) +;
					cValToChar((cTRBARQ)->TP_HORA) + cValToChar((cTRBARQ)->TP_POSCONT) + cValToChar((cTRBARQ)->TP_ACUMCON) +;
					cValToChar((cTRBARQ)->TP_TIPOLAN))
					(cTRBARQ)->(dbSkip())
					Loop
				Endif
				If(MV_PAR02 == 1)//1 = Bloquear
					aAutonomia := NGCHKHISTO((cTRBARQ)->TP_CODBEM,(cTRBARQ)->TP_DTLEITU,(cTRBARQ)->TP_POSCONT,(cTRBARQ)->TP_HORA,1,,.F.,;
							(cTRBARQ)->TP_FILIAL)
					If !aAutonomia[1]
						aBens[nX, 3] += aAutonomia[2] + CRLF/*"Erro de histórico do contador " + cValToChar((cTRBARQ)->TP_POSCONT) + " da data: " +;
										cValToChar((cTRBARQ)->TP_DTLEITU) + " e hora: " + cValToChar((cTRBARQ)->TP_HORA) +;
										"." + CRLF*///Marca o registro com erro
						lErro := .T.
						aAdd(aErros, cValToChar((cTRBARQ)->TP_FILIAL) + cValToChar((cTRBARQ)->TP_CODBEM) + DToS((cTRBARQ)->TP_DTLEITU) +;
						cValToChar((cTRBARQ)->TP_HORA) + cValToChar((cTRBARQ)->TP_POSCONT) + cValToChar((cTRBARQ)->TP_ACUMCON) +;
						cValToChar((cTRBARQ)->TP_TIPOLAN))
						(cTRBARQ)->(dbSkip())
						Loop
					Endif
				ElseIf(MV_PAR02 == 3)//3 = Perguntar
					If !NGCHKHISTO((cTRBARQ)->TP_CODBEM,(cTRBARQ)->TP_DTLEITU,(cTRBARQ)->TP_POSCONT,(cTRBARQ)->TP_HORA,1,,.T.,;
								(cTRBARQ)->TP_FILIAL)
						aBens[nX, 3] += STR0059 + cValToChar((cTRBARQ)->TP_DTLEITU) + STR0060 +; // "Erro de histórico do contador: Data Leitura: "##" Posição contador: "###
										cValToChar((cTRBARQ)->TP_POSCONT) + STR0061 + cValToChar((cTRBARQ)->TP_HORA) + CRLF // " Hora: "
						lErro := .T.//Marca o registro com erro
						aAdd(aErros, cValToChar((cTRBARQ)->TP_FILIAL) + cValToChar((cTRBARQ)->TP_CODBEM) + DToS((cTRBARQ)->TP_DTLEITU) +;
						cValToChar((cTRBARQ)->TP_HORA) + cValToChar((cTRBARQ)->TP_POSCONT) + cValToChar((cTRBARQ)->TP_ACUMCON) +;
						cValToChar((cTRBARQ)->TP_TIPOLAN))
						(cTRBARQ)->(dbSkip())
						Loop
					Endif
				EndIf

				If(MV_PAR01 == 1)//1 = Bloquear
					If !NGVALIVARD((cTRBARQ)->TP_CODBEM,(cTRBARQ)->TP_POSCONT,(cTRBARQ)->TP_DTLEITU,(cTRBARQ)->TP_HORA,1,.F.,,;
								(cTRBARQ)->TP_FILIAL)[1]
						aBens[nX, 3] += STR0063 + cValToChar((cTRBARQ)->TP_POSCONT) + STR0064 +; // "Erro de variação dia do contador "##" da data: "
										cValToChar((cTRBARQ)->TP_DTLEITU) + STR0065 + cValToChar((cTRBARQ)->TP_HORA) +; // " e hora: "
										"." + CRLF//Marca o registro com erro
						lErro := .T.
						aAdd(aErros, cValToChar((cTRBARQ)->TP_FILIAL) + cValToChar((cTRBARQ)->TP_CODBEM) + DToS((cTRBARQ)->TP_DTLEITU) +;
						cValToChar((cTRBARQ)->TP_HORA) + cValToChar((cTRBARQ)->TP_POSCONT) + cValToChar((cTRBARQ)->TP_ACUMCON) +;
						cValToChar((cTRBARQ)->TP_TIPOLAN))
						(cTRBARQ)->(dbSkip())
						Loop
					Endif
				ElseIf(MV_PAR01 == 3)//3 = Perguntar
					If !NGVALIVARD((cTRBARQ)->TP_CODBEM,(cTRBARQ)->TP_POSCONT,(cTRBARQ)->TP_DTLEITU,(cTRBARQ)->TP_HORA,1,.T.,,;
								(cTRBARQ)->TP_FILIAL)

						fWrite(nArqAtu, STR0063 + cValToChar((cTRBARQ)->TP_POSCONT) + STR0064 +; // "Erro de variação dia do contador "##" da data: "
										cValToChar((cTRBARQ)->TP_DTLEITU) + STR0065 + cValToChar((cTRBARQ)->TP_HORA) +; // " e hora: "
										"." + CRLF ) //Marca o registro com erro


						lErro := .T.
						aAdd(aErros, cValToChar((cTRBARQ)->TP_FILIAL) + cValToChar((cTRBARQ)->TP_CODBEM) + DToS((cTRBARQ)->TP_DTLEITU) +;
						cValToChar((cTRBARQ)->TP_HORA) + cValToChar((cTRBARQ)->TP_POSCONT) + cValToChar((cTRBARQ)->TP_ACUMCON) +;
						cValToChar((cTRBARQ)->TP_TIPOLAN))
						(cTRBARQ)->(dbSkip())
						Loop
					Endif
				EndIf

			EndIf

			If((cTRBARQ)->TP_TIPOLAN == "V")

				aVirada := NGCHKVIRAD((cTRBARQ)->TP_CODBEM,(cTRBARQ)->TP_DTLEITU,(cTRBARQ)->TP_POSCONT,(cTRBARQ)->TP_HORA,1,;
									(cTRBARQ)->TP_FILIAL, .F., .T.)
				If !aVirada[1]

					fWrite(nArqAtu, AllTrim((cTRBARQ)->TP_CODBEM) + ":" + CRLF +;//Marca o registro com erro.
									aVirada[2] + CRLF )

					lErro := .T.
					aAdd(aErros, cValToChar((cTRBARQ)->TP_FILIAL) + cValToChar((cTRBARQ)->TP_CODBEM) + DToS((cTRBARQ)->TP_DTLEITU) +;
					cValToChar((cTRBARQ)->TP_HORA) + cValToChar((cTRBARQ)->TP_POSCONT) + cValToChar((cTRBARQ)->TP_ACUMCON) +;
					cValToChar((cTRBARQ)->TP_TIPOLAN))
					(cTRBARQ)->(dbSkip())
				EndIf

			EndIf

			If (cTRBARQ)->TP_TIPOLAN == "Q"

				oQuebra:= MNTCounter():New()
				oQuebra:setOperation(3)

				oQuebra:setValue("TP_CODBEM",(cTRBARQ)->TP_CODBEM)
				oQuebra:setValue("TP_POSCONT",(cTRBARQ)->TP_POSCONT)
				oQuebra:setValue("TP_DTLEITU",(cTRBARQ)->TP_DTLEITU)
				oQuebra:setValue("TP_HORA",(cTRBARQ)->TP_HORA)

				//Valida as informacoes da quebra do contador 1 e insere se estiver ok
				If !oQuebra:BreakCounter()

					fWrite(nArqAtu, STR0093 + cValToChar((cTRBARQ)->TP_CODBEM) + STR0094 +; //"Erro na quebra de contador do bem " ## " com data "
									cValToChar((cTRBARQ)->TP_DTLEITU) + STR0095 + cValToChar((cTRBARQ)->TP_HORA) + ": " +; //" e hora "
									oQuebra:getErrorList()[1] + CRLF ) //Inconsistência na quebra do contador.

					lErro := .T.
					aAdd(aErros, cValToChar((cTRBARQ)->TP_FILIAL) + cValToChar((cTRBARQ)->TP_CODBEM) + DToS((cTRBARQ)->TP_DTLEITU) +;
					cValToChar((cTRBARQ)->TP_HORA) + cValToChar((cTRBARQ)->TP_POSCONT) + cValToChar((cTRBARQ)->TP_ACUMCON) +;
					cValToChar((cTRBARQ)->TP_TIPOLAN))
					(cTRBARQ)->(dbSkip())
					Loop
				EndIf

			EndIf

			If !lErro .And. (cTRBARQ)->TP_TIPOLAN != "Q"
				fInsSTP()//Insere os bens que não tem inconsistência
			EndIf

			(cTRBARQ)->(dbSkip())

		EndDo

		If Empty(aBens[nX, 3]) .Or. (!Empty(aBens[nX, 3]) .And. AT("ignorado.", aBens[nX, 3]) != 0)
			fUpdRel()//Atualiza as tabelas relacionadas
		EndIf
	Next nX

	fClose(nArqAtu) // Fecha o arquivo.

Return lErro
//---------------------------------------------------------------------
/*/{Protheus.doc} fDelSTP
Exclui os registros da STP antes de validar

@sample
fDelSTP(nPos)

@param nPos: Posição do bem no array
@author Wexlei Silveira
@since 17/11/2015
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fDelSTP(nPos)

Local nY

For nY := 1 To Len(aBens[nPos,2]) //percorre cada filial em que o bem esteve
	dbSelectArea("STP")
	dbSetOrder(05)
	dbSeek(aBens[nPos,2,nY] + aBens[nPos,1] + dParcial, .T.)
	While !EoF() .And. Empty(aBens[nPos, 3])
		If STP->TP_CODBEM != aBens[nPos,1]
			Exit
		EndIf
		If STP->TP_TIPOLAN != "I"
			NGDELETAREG("STP")
		ElseIf !Empty(aTemInc) .And. aScan(aTemInc[Len(aTemInc)], aBens[nPos,1]) > 0
			If aTemInc[aScan(aTemInc[Len(aTemInc)], STP->TP_CODBEM),2] == "A"
				NGDELETAREG("STP")
			EndIf
		EndIf
		dbSkip()
	EndDo
	("STP")->(dbCloseArea())
Next nY

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fInsSTP
Insere os registros validados na STP

@sample
fInsSTP()

@author Wexlei Silveira
@since 17/11/2015
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fInsSTP()

Local nVarDia := 0
Local nAcumCon := 0


If (cTRBARQ)->TP_TIPOLAN == "I"
	If cChaveInc == ((cTRBARQ)->TP_FILIAL + (cTRBARQ)->TP_CODBEM + DTOS((cTRBARQ)->TP_DTLEITU) + (cTRBARQ)->TP_HORA) //Primeiro registro de inclusão do bem
		nAcumCon := (cTRBARQ)->TP_ACUMCON
	Else//Inclusão de transferência, repete o acumulado anterior
		nAcumCon := nAcumAnt
	EndIf
ElseIf (cTRBARQ)->TP_TIPOLAN $ "QV"

	nAcumCon := nAcumAnt

Else

	nAcumCon := ((cTRBARQ)->TP_POSCONT - nContAnt) + nAcumAnt

EndIf

nVarDia := NGVARIADT((cTRBARQ)->TP_CODBEM, (cTRBARQ)->TP_DTLEITU, 1, nAcumCon, .T., .T., (cTRBARQ)->TP_FILIAL)

If((cTRBARQ)->TP_TIPOLAN == "Q")//Grava registro de quebra do contador

	NGGRAVAHIS((cTRBARQ)->TP_CODBEM,(cTRBARQ)->TP_POSCONT,nVarDia,(cTRBARQ)->TP_DTLEITU,;
			   nAcumCon,ST9->T9_VIRADAS,(cTRBARQ)->TP_HORA,1,(cTRBARQ)->TP_TIPOLAN)

	("ST9")->(dbCloseArea())

ElseIf ((cTRBARQ)->TP_TIPOLAN == "I")//Grava registro de Inclusão

	NGGRAVAHIS((cTRBARQ)->TP_CODBEM,(cTRBARQ)->TP_POSCONT,nVarDia,(cTRBARQ)->TP_DTLEITU,nAcumCon,0,;
	           (cTRBARQ)->TP_HORA,1,"I",(cTRBARQ)->TP_FILIAL)
Else
	NGTRETCON((cTRBARQ)->TP_CODBEM,(cTRBARQ)->TP_DTLEITU,(cTRBARQ)->TP_POSCONT,(cTRBARQ)->TP_HORA,1,,.T.,;
	          (cTRBARQ)->TP_TIPOLAN,(cTRBARQ)->TP_FILIAL,.F.)
EndIf

dbSelectArea("STP")
dbSetOrder(05)
If dbSeek((cTRBARQ)->TP_FILIAL+(cTRBARQ)->TP_CODBEM+DToS((cTRBARQ)->TP_DTLEITU)+(cTRBARQ)->TP_HORA)
	nAcumAnt := ("STP")->TP_ACUMCON
	nContAnt := ("STP")->TP_POSCONT
Else
	nAcumAnt := nAcumCon
	nContAnt := (cTRBARQ)->TP_POSCONT
EndIf

DbSelectArea("ST9")
DbSetOrder(1)
If DbSeek((cTRBARQ)->TP_FILIAL+(cTRBARQ)->TP_CODBEM)

	RecLock("ST9",.F.)
	ST9->T9_POSCONT := (cTRBARQ)->TP_POSCONT
	If (cTRBARQ)->TP_DTLEITU > ST9->T9_DTULTAC
		ST9->T9_DTULTAC := (cTRBARQ)->TP_DTLEITU
	EndIf
	ST9->T9_CONTACU := nAcumCon
	ST9->(MsUnlock())
EndIf

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fUpdRel
Atualiza as tabelas relacionadas

@sample
fUpdRel()

@author Wexlei Silveira
@since 17/11/2015
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fUpdRel()

Local nY, nX
Local dDataUlt
Local nAcumul	:= 0
Local lVerSTJ 	:= SuperGetMV("MV_NG1SUBS", .F., "1" ) == "2"
Local aSubsti	:= {}

For nY := 1 To Len(aRelacTbl)
	dbSelectArea(aRelacTbl[nY,1])
	dbGoTo(aRelacTbl[nY,2])
	If !EoF()
		RecLock(aRelacTbl[nY,1],.F.)
		&((aRelacTbl[nY,1])+"->"+(aRelacTbl[nY,3])) := (aRelacTbl[nY,4])
		(aRelacTbl[nY,1])->(MsUnLock())

		//Atualiza Manutenção
		If aRelacTbl[nY,1] == "STJ"
			dbSelectArea("STF")
			dbSetOrder(1) //TF_FILIAL+TF_CODBEM+TF_SERVICO+TF_SEQRELA
			If dbSeek( xFilial("STF",STJ->TJ_FILIAL) + STJ->TJ_CODBEM + STJ->TJ_SERVICO + STJ->TJ_SEQRELA)
				If STF->TF_TIPACOM <> "T" .And. STF->TF_DTULTMA == STJ->TJ_DTMRFIM
					RecLock("STF",.F.)
					STF->TF_CONMANU := NGACUMEHIS(STJ->TJ_CODBEM,STJ->TJ_DTMRFIM,STJ->TJ_HORACO1,1,"E",STJ->TJ_FILIAL)[2]
					STF->(MsUnlock())
					dDataUlt	:= STF->TF_DTULTMA
					nAcumul		:= STF->TF_CONMANU
					
					aSubsti	:= MntSeqSub( STJ->TJ_CODBEM, STJ->TJ_SERVICO, STJ->TJ_SEQRELA,;
						STJ->TJ_PLANO, , !Empty( STJ->TJ_SUBSTIT ) )
					
					For nX :=1 To Len(aSubsti)
						If STF->(dbSeek(xFilial("STF",STJ->TJ_FILIAL) + STJ->TJ_CODBEM + STJ->TJ_SERVICO + Alltrim(aSubsti[nX])))
							RecLock("STF",.F.)
							STF->TF_CONMANU	:= nAcumul
							STF->TF_DTULTMA	:= dDataUlt
							STF->(MsUnlock())
						EndIf
					next nX
				EndIf
			EndIf
		EndIf
	EndIf
Next nY

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fAddMsg
Compoe mensagem de erro com quebra de linha das validacoes do bem

@sample
fAddMsg()

@author Wexlei Silveira
@since 11/11/2015
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fAddMsg()

Local cMens := "", nI

For nI := 1 To Len(aBens)
	If !Empty(aBens[nI, 3])
		cMens += RTrim(cValToChar(aBens[nI, 1])) + If(RTrim(cValToChar(aBens[nI, 2])) != "", " / " +;
				 RTrim(cValToChar(aBens[nI, 2])), "") + ":" + CRLF + aBens[nI, 3] + CRLF
	EndIf
Next nI

Return cMens
//---------------------------------------------------------------------
/*/{Protheus.doc} fRecBkp
Carrega o arquivo de backup da STP para restaurar os dados do bem com inconsistencia

@sample
fRecBkp()

@author Wexlei Silveira
@since 11/11/2015
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fRecBkp()

	Local nI, nX, nY

	For nX := 1 to Len(aBens) // Exclui registro do bem que já foi inserido na STP da base

		For nY := 1 To Len(aBens[nX,2])  // percorre cada filial em que o bem esteve
			dbSelectArea("STP")
			dbSetOrder(02)
			dbSeek(aBens[nX,2,nY] + aBens[nX,1])
			While dbSeek(aBens[nX,2,nY]+aBens[nX,1]) .And. Empty(aBens[nX, 3])
				NGDELETAREG("STP")
				dbSkip()
			EndDo
			("STP")->(dbCloseArea())
		Next nY

	Next nX

	fReadArq()

	Dbselectarea(cTRBBKP)
	Dbgotop()
	While (cTRBBKP)->(!EoF())
		dbSelectArea("STP")
		dbSetOrder(05)
		If !dbSeek((cTRBBKP)->TP_FILIAL+(cTRBBKP)->TP_CODBEM+DToS((cTRBBKP)->TP_DTLEITU)+(cTRBBKP)->TP_HORA)
			RecLock('STP', .T.)
			STP->TP_FILIAL  := (cTRBBKP)->TP_FILIAL
			STP->TP_ORDEM   := (cTRBBKP)->TP_ORDEM
			STP->TP_PLANO   := (cTRBBKP)->TP_PLANO
			STP->TP_CODBEM  := (cTRBBKP)->TP_CODBEM
			STP->TP_SERVICO := (cTRBBKP)->TP_SERVICO
			STP->TP_SEQUENC := (cTRBBKP)->TP_SEQUENC
			STP->TP_DTORIGI := (cTRBBKP)->TP_DTORIGI
			STP->TP_POSCONT := (cTRBBKP)->TP_POSCONT
			STP->TP_DTREAL  := (cTRBBKP)->TP_DTREAL
			STP->TP_DTLEITU := (cTRBBKP)->TP_DTLEITU
			STP->TP_SITUACA := (cTRBBKP)->TP_SITUACA
			STP->TP_TERMINO := (cTRBBKP)->TP_TERMINO
			STP->TP_USUCANC := (cTRBBKP)->TP_USUCANC
			STP->TP_USULEI  := (cTRBBKP)->TP_USULEI
			STP->TP_DTULTAC := (cTRBBKP)->TP_DTULTAC
			STP->TP_COULTAC := (cTRBBKP)->TP_COULTAC
			STP->TP_CCUSTO  := (cTRBBKP)->TP_CCUSTO
			STP->TP_CENTRAB := (cTRBBKP)->TP_CENTRAB
			STP->TP_VARDIA  := (cTRBBKP)->TP_VARDIA
			STP->TP_TEMCONT := (cTRBBKP)->TP_TEMCONT
			STP->TP_ACUMCON := (cTRBBKP)->TP_ACUMCON
			STP->TP_VIRACON := (cTRBBKP)->TP_VIRACON
			STP->TP_TIPOLAN := (cTRBBKP)->TP_TIPOLAN
			STP->TP_HORA    := (cTRBBKP)->TP_HORA
			STP->(MsUnLock())
		EndIf
		("STP")->(dbCloseArea())
		(cTRBBKP)->(dbSkip())
	End

	For nX := 1 to Len(aBens)//Recupera os dados da ST9
		For nI := 1 to Len(aBens[nX, 2])//Percorre as Filiais do bem
			For nY := 1 to Len(aST9Bkp)//Percorre o array de backup da ST9
				If aBens[nX, 1] == aST9Bkp[nY, 1] .And. aBens[nX, 2, nI] == aST9Bkp[nY, 2]//Procura Bem+Filial com erro
					DbSelectArea("ST9")
					Set Filter To
					DbSetOrder(1)
					If dbseek(NGTrocaFili("ST9",aST9Bkp[nY, 2]) + aST9Bkp[nY, 1])//Filial + Cód. Bem
						RecLock('ST9', .F.)
						ST9->T9_POSCONT := aST9Bkp[nY,3]
						ST9->T9_DTULTAC := aST9Bkp[nY,4]
						ST9->T9_CONTACU := aST9Bkp[nY,5]
						ST9->T9_VIRADAS := aST9Bkp[nY,6]
						ST9->(MsUnLock())
					EndIf
					("ST9")->(dbCloseArea())
				EndIf
			Next nY
		Next nI
	Next nX

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fReadArq
Faz a leitura do arquivo de Backup gerado em txt

@author  Maicon André Pinheiro
@since   06/04/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function fReadArq()

	Local lRet       := .F.
	Local cBarras    := IIf( isSRVunix(), '/', '\' )
	Local cStartPath := AllTrim(GetSrvProfString("StartPath", cBarras))
	Local cLocalCpl  := ""
	Local cLinha     := ""
	Local cTRBARQB   := ''
	Local nArqLog    := 0
	Local nHdlArq    := 0
	Local nInd       := 0
	Local nTot       := 0
	Local aLinha     := {}
	Local aCampos    := {}
	Local aStruct    := {}
	Local oTempLBKP  := Nil
	Local cTipo      := 0
	Local nTam       := 0
	Local nDeci      := 0

	If SubStr(cStartPath,Len(cStartPath),1) != cBarras
		cStartPath := cStartPath + cBarras
	EndIf

	cLocalCpl := cStartPath + "NG" + cBarras+ "backup" + cBarras + cBkp //+ cDbExt

	If File(cLocalCpl)

		cTRBARQB := GetNextAlias()
		nHdlArq  := FT_FUse(cLocalCpl)
		fSeek(nHdlArq,0,FS_END)
		FT_FGoTop()

		cLinha   := FT_FREADLN()
		aCampos  := StrTokArr2(cLinha,"|",.T.)
		nTot     := Len(aCampos)

		For nInd := 1 To nTot

			cTipo := Posicione("SX3",2,aCampos[nInd],"X3_TIPO")
			nTam  := TAMSX3(aCampos[nInd])[1]
			nDeci := TAMSX3(aCampos[nInd])[2]
			aAdd(aStruct, {aCampos[nInd],cTipo,nTam,nDeci})

		Next nInd

		oTempLBKP := NGFwTmpTbl(cTRBARQB,aStruct,{{aCampos[1]}})
		FT_fSkip() // Posiciona na segunda linha, a primeira com dados da tabela.

		// Monta array com os campos da tabela temporario.
		While (!FT_FEof())

			cLinha := FT_FREADLN()
			aLinha := StrTokArr2(cLinha,"|",.T.)

			RecLock(cTRBARQB, .T.)

			For nInd := 1 To nTot

				cCampo   := cTRBARQB + "->" + aStruct[nInd][1]

				If aStruct[nInd,2] == "N"
					&cCampo. := Val(aLinha[nInd])
				Elseif aStruct[nInd,2] == "D"
					&cCampo. := StoD(aLinha[nInd])
				Else
					&cCampo. := aLinha[nInd]
				EndIf

			Next nInd

			(cTRBARQB)->(MSUnlock())
			FT_fSkip()

		End

		FT_fUse()
		fClose(nhdlArq)

		(cTRBARQB)->( dbCloseArea() )
		oTempLBKP:Delete()

	Else
		MsgStop(STR0045) //"Não foi possível abrir o arquivo."
		lRet := .F.
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fValidTpI
Valida se há registro do tipo 'Inclusão' para o bem

@sample
fValidTpI(cBem)

@author Felipe Nathan Welter, Wexlei Silveira
@since 01/11/2015
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fValidTpI(cBem)

Local cMens := ""
Local aInc := {}
Local nX := 0
Local nY := 0
Local aCont := {}
Local aAreaTQ2
Local aAreaTRB

If !Empty(aTemInc) .And. aScan(aTemInc[Len(aTemInc)], cBem) > 0
	ADel(aTemInc, aScan(aTemInc[Len(aTemInc)], cBem))
	ASize(aTemInc, Len(aTemInc)-1)
EndIf

	dbSelectArea(cTRBARQ)
	dbSetOrder(02)
	dbSeek(cBem,.T.)
	cChaveInc := (cTRBARQ)->TP_FILIAL + (cTRBARQ)->TP_CODBEM + DTOS((cTRBARQ)->TP_DTLEITU) + (cTRBARQ)->TP_HORA//Chave do primeiro registro

	//testa o primeiro registro (por data e hora), precisa ser inclusão
	If (cTRBARQ)->TP_CODBEM == cBem .And. (cTRBARQ)->TP_TIPOLAN != "I"//Se não encontrar o registro de inclusão no arquivo
		If Trim((cTRBARQ)->DT_PARCIAL) != ""//Se este arquivo for uma importação parcial
			dbSelectArea("STP")
			dbSetOrder(08)
			If !dbSeek(cValToChar((cTRBARQ)->TP_FILIAL) + cValToChar((cTRBARQ)->TP_CODBEM) + "I",.T.)
				aAdd(aErros, cValToChar((cTRBARQ)->TP_FILIAL) + cValToChar((cTRBARQ)->TP_CODBEM) + DToS((cTRBARQ)->TP_DTLEITU) +;
				cValToChar((cTRBARQ)->TP_HORA) + cValToChar((cTRBARQ)->TP_POSCONT) + cValToChar((cTRBARQ)->TP_ACUMCON) +;
				cValToChar((cTRBARQ)->TP_TIPOLAN))
				lParcInc := .F.
			Else
				lParcInc := .T.
			EndIf
			("STP")->(dbCloseArea())
		Else
			cMens := STR0096 //"O primeiro registro para este bem precisa ser do tipo 'Inclusão'. "
		EndIf
	EndIf

	dbSelectArea("STP")
	dbSetOrder(05)
	If dbSeek(cValToChar((cTRBARQ)->TP_FILIAL) + cValToChar((cTRBARQ)->TP_CODBEM) + DToS((cTRBARQ)->TP_DTLEITU)+cValToChar((cTRBARQ)->TP_HORA))
		dbSkip(-1)
		If !((cTRBARQ)->TP_TIPOLAN $ "QV") .And. Empty(cMens) .And. (cTRBARQ)->TP_FILIAL == STP->TP_FILIAL .And. STP->TP_CODBEM == (cTRBARQ)->TP_CODBEM .And. STP->TP_POSCONT > (cTRBARQ)->TP_POSCONT
			aAdd(aErros, cValToChar((cTRBARQ)->TP_FILIAL) + cValToChar((cTRBARQ)->TP_CODBEM) + DToS((cTRBARQ)->TP_DTLEITU) +;
			cValToChar((cTRBARQ)->TP_HORA) + cValToChar((cTRBARQ)->TP_POSCONT) + cValToChar((cTRBARQ)->TP_ACUMCON) +;
			cValToChar((cTRBARQ)->TP_TIPOLAN))
			cMens	+= STR0047 + cValToChar((cTRBARQ)->TP_POSCONT) + STR0048 + cValToChar((cTRBARQ)->TP_DTLEITU) +; //"Posição " ## " do contador, da data: "
			STR0049 + cValToChar((cTRBARQ)->TP_HORA) + STR0050 + cValToChar(STP->TP_POSCONT) + "." + CRLF //" e hora: " ## " é menor que a posição anterior: "
		EndIf
	EndIf
	("STP")->(dbCloseArea())

	If Empty(cMens)
		//primeiro verifica se há alguma filial com mais de um registro de inclusão
		While (cTRBARQ)->TP_CODBEM == cBem
			If (cTRBARQ)->TP_TIPOLAN == "I"
				If AScan(aInc,{|x| x == (cTRBARQ)->TP_FILIAL}) == 0
					aAdd(aInc, (cTRBARQ)->TP_FILIAL)
				Else
					aAdd(aErros, cValToChar((cTRBARQ)->TP_FILIAL) + cValToChar((cTRBARQ)->TP_CODBEM) + DToS((cTRBARQ)->TP_DTLEITU) +;
					cValToChar((cTRBARQ)->TP_HORA) + cValToChar((cTRBARQ)->TP_POSCONT) + cValToChar((cTRBARQ)->TP_ACUMCON) +;
					cValToChar((cTRBARQ)->TP_TIPOLAN))
					cMens := STR0097+(cTRBARQ)->TP_FILIAL+". " //"Mais de um registro de inclusão encontrado para a filial "
				EndIf
			EndIf
			(cTRBARQ)->(dbSkip())
		EndDo

		If Empty(aInc)
			If lCheck == .T.//Se a importação for parcial, procura na STP o registro de inclusão do bem
				dbSelectArea("STP")
				dbSetOrder(08)
				If !dbSeek(xFilial("STP") + cValToChar(cBem) + "I",.T.)
					aAdd(aErros, cValToChar((cTRBARQ)->TP_FILIAL) + cValToChar((cTRBARQ)->TP_CODBEM) + DToS((cTRBARQ)->TP_DTLEITU) +;
					cValToChar((cTRBARQ)->TP_HORA) + cValToChar((cTRBARQ)->TP_POSCONT) + cValToChar((cTRBARQ)->TP_ACUMCON) +;
					cValToChar((cTRBARQ)->TP_TIPOLAN))
				Else
					aAdd(aTemInc,{cBem, "B"})
				EndIf
				("STP")->(dbCloseArea())
			Else
				cMens := STR0098 + AllTrim(cBem) + STR0099 //"Nenhum registro de inclusão foi encontrado para o bem " ## " no arquivo de importação. "
			EndIf
		Else
			aAdd(aTemInc,{cBem, "A"})
		EndIf
	EndIf

	If Empty(cMens) .And. NGSX2MODO("ST9") == "E"//verifica quais as filias pelas quais o bem ja passou e verifica se falta alguma

		dbSelectArea("TQ2")
		dbSetOrder(01)
		dbGoTop()
		While !EoF() .And. Empty(cMens) .And. TQ2->TQ2_CODBEM == cBem

			aAreaTQ2 := GetArea("TQ2")
			dbSelectArea(cTRBARQ)
			dbSetOrder(02)

			If dbSeek(cBem + DToS(TQ2->TQ2_DATATR) + TQ2->TQ2_HORATR + TQ2->TQ2_FILDES)//Se encontrar o registro transferência
				If (cTRBARQ)->TP_TIPOLAN != "I" .And. AScan(aInc,{|x| x == TQ2->TQ2_FILDES}) == 0//Se o lançamento não for do tipo inclusão

					aAreaTRB := GetArea(cTRBARQ)
					dbSelectArea("STP")
					dbSetOrder(08)
					If dbSeek((cTRBARQ)->TP_FILIAL + cBem + "I") .And. STP->TP_DTLEITU == (cTRBARQ)->TP_DTLEITU

						aAdd(aErros, cValToChar((cTRBARQ)->TP_FILIAL) + cValToChar((cTRBARQ)->TP_CODBEM) + DToS((cTRBARQ)->TP_DTLEITU) +;
						cValToChar((cTRBARQ)->TP_HORA) + cValToChar((cTRBARQ)->TP_POSCONT) + cValToChar((cTRBARQ)->TP_ACUMCON) +;
						cValToChar((cTRBARQ)->TP_TIPOLAN))
						cMens := STR0100 + cValToChar(IIF(ValType(TQ2->TQ2_DATATR) != "D", STOD(TQ2->TQ2_DATATR), TQ2->TQ2_DATATR)) + STR0095 + ; //"O registro com data " ## " e hora "
						 		cValToChar(TQ2->TQ2_HORATR) + STR0101 + ; //" refere-se ao registro de inclusão do bem transferido para a filial "
								AllTrim(TQ2->TQ2_FILDES) + STR0102 //". O tipo de lançamento atual está incorreto. "

					Endif
					RestArea(aAreaTRB)
					("STP")->(dbCloseArea())

				EndIf
			Else
				aAdd(aErros, cValToChar((cTRBARQ)->TP_FILIAL) + cValToChar((cTRBARQ)->TP_CODBEM) + DToS((cTRBARQ)->TP_DTLEITU) +;
				cValToChar((cTRBARQ)->TP_HORA) + cValToChar((cTRBARQ)->TP_POSCONT) + cValToChar((cTRBARQ)->TP_ACUMCON) +;
				cValToChar((cTRBARQ)->TP_TIPOLAN))
				cMens := STR0103 + TQ2->TQ2_FILDES + ". " //"Não foi encontrado registro do tipo 'Inclusão' para a filial "
			EndIf
			RestArea(aAreaTQ2)
			dbSkip()
		EndDo

		("TQ2")->(dbCloseArea())
	EndIf

Return cMens
//---------------------------------------------------------------------
/*/{Protheus.doc} fValidHis
Valida os registros da STP a serem importados com base na filial correta da TQ2

@sample
fValidHis(cBem)

@author Felipe Nathan Welter, Wexlei Silveira
@since 14/11/15
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fValidHis(cBem)

Local cMens := ""
Local aTQ2 := {}
Local cFilTQ2 := ''
Local cFilOTQ2 := ''
Local nX
Local aArea
Local cDtHrO
Local cErro := ""

	//primeiro armazena as datas limite de transferencias
	cAliasVl := GetNextAlias()
	cQry := "SELECT TQ2_FILIAL FILIAL, TQ2_FILORI, TQ2_FILDES, TQ2_CODBEM BEM, TQ2_DATATR DATA, TQ2_HORATR HORA"
	cQry += "  FROM " + RetSQLName("TQ2")
	cQry += " WHERE TQ2_CODBEM = " + ValToSQL(cBem)
	cQry += "   AND D_E_L_E_T_ <> '*'"
	cQry += " ORDER BY TQ2_DATATR||TQ2_HORATR ASC"

	cQry := ChangeQuery(cQry)
	MPSysOpenQuery( cQry , cAliasVl )

	dbSelectArea(cAliasVl)
	dbGoTop()
	While !EoF()
		aAdd(aTQ2,{(cAliasVl)->TQ2_FILORI, (cAliasVl)->TQ2_FILDES, (cAliasVl)->DATA, (cAliasVl)->HORA})
		(cAliasVl)->(dbSkip())
	EndDo

	(cAliasVl)->(dbCloseArea())

	//ordena as transferencias cronologicamente
	aSort(aTQ2,,,{|x,y| x[3]+x[4] <= y[3]+y[4]})

	If Len(aTQ2) > 0

		cFilTQ2 := aTQ2[1,1]

		dbSelectArea(cTRBARQ)
		dbSeek(cBem,.T.)

		//agora verifica se os STP's importados estão dentro das filiais corretas
		While !(cTRBARQ)->(EoF()) .And. (cTRBARQ)->TP_CODBEM == cBem

			//primeiro verifica a filial em que deve estar o registro da STP
			For nX := 1 To Len(aTQ2)
				If(DTOS((cTRBARQ)->TP_DTLEITU)+(cTRBARQ)->TP_HORA > aTQ2[nX,3]+aTQ2[nX,4])
					cFilTQ2 := aTQ2[nX,2]
				ElseIf(DTOS((cTRBARQ)->TP_DTLEITU)+(cTRBARQ)->TP_HORA == aTQ2[nX,3]+aTQ2[nX,4])

					cFilTQ2 := aTQ2[nX,2]
					cFilOTQ2 := aTQ2[nX,1]
					cDtHrO = DTOS((cTRBARQ)->TP_DTLEITU)+(cTRBARQ)->TP_HORA
					cErro := ""

					aArea := GetArea()
					dbSelectArea(cTRBARQ)
					dbSetOrder(2)
					dbSeek(cBem+cDtHrO,.T.)

					While !(cTRBARQ)->(EoF()) .And. (cTRBARQ)->TP_CODBEM == cBem .And. DToS((cTRBARQ)->TP_DTLEITU)+(cTRBARQ)->TP_HORA == cDtHrO

						If (cTRBARQ)->TP_FILIAL == cFilTQ2
							cErro+= "a"
						ElseIf (cTRBARQ)->TP_FILIAL == cFilOTQ2
							cErro+= "b"
						Else
							cErro := ""
							Exit
						EndIf

						DBSkip()

					EndDo

					RestArea(aArea)

					If!(Len(cErro) == 2 .And. "a" $ cErro .And. "b" $ cErro)
						aAdd(aErros, cValToChar((cTRBARQ)->TP_FILIAL) + cValToChar((cTRBARQ)->TP_CODBEM) + DToS((cTRBARQ)->TP_DTLEITU) +;
						cValToChar((cTRBARQ)->TP_HORA) + cValToChar((cTRBARQ)->TP_POSCONT) + cValToChar((cTRBARQ)->TP_ACUMCON) +;
						cValToChar((cTRBARQ)->TP_TIPOLAN))
						cMens := STR0104 + cBem + STR0105 + DTOC((cTRBARQ)->TP_DTLEITU) + " " + (cTRBARQ)->TP_HORA + STR0106 +; //"O código da filial do registro " ## " data " ## " da filial "
						         (cTRBARQ)->TP_FILIAL + STR0107 //" está incorreto, ou falta um registro de transferência da outra filial"
					EndIf
					Exit//Sai do for, pois já encontrou uma inconsistência de transferência de bem
				EndIf
			Next nX

			//Agora verifica se não está na filial correta
			If (cTRBARQ)->TP_FILIAL != cFilTQ2 .And. Empty(cErro)
					aAdd(aErros, cValToChar((cTRBARQ)->TP_FILIAL) + cValToChar((cTRBARQ)->TP_CODBEM) + DToS((cTRBARQ)->TP_DTLEITU) +;
					cValToChar((cTRBARQ)->TP_HORA) + cValToChar((cTRBARQ)->TP_POSCONT) + cValToChar((cTRBARQ)->TP_ACUMCON) +;
					cValToChar((cTRBARQ)->TP_TIPOLAN))
					cMens := STR0108 + DTOC((cTRBARQ)->TP_DTLEITU) + " " + (cTRBARQ)->TP_HORA + STR0106 + (cTRBARQ)->TP_FILIAL +; //"Registro " ## " da filial "
							 STR0109 + cFilTQ2 + STR0110 //" deve estar na filial " ## " conforme consta na tabela de histórico TQ2."
			EndIf

			(cTRBARQ)->(dbSkip())
		EndDo
	EndIf

Return cMens
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT876VLT
Valida relacionamento do bem entre as tabelas relevantes para o processo

@author Wexlei Silveira
@since 29/10/2015
@version P11
@return cLista ou caractere vazio ("")
/*/
//---------------------------------------------------------------------
Function MNT876VLT(cBem)

Local aTabelas := {}
Local nI := 0
Local cLista := ""

aAdd(aTabelas, {"TQN", "TPN", "ST9", "STJ", "STS", "STW", "STY", "STZ",; //Tabelas que deverão ser verificadas
				"TPW", "TQ2", "TQA", "TQB", "TR9", "TTI", "TUZ", "HTJ", "TTF"})

dbSelectArea(cTRBARQ)
dbSetOrder(1)
If dbSeek(cBem)
	For nI := 1 To Len(aTabelas[1])
		If AliasInDic(aTabelas[1][nI])
			cLista += fValTab(aTabelas[1][nI], cBem)
		EndIf
	Next nI
EndIf

If !Empty(cLista)
	Return cLista
EndIf

Return ""
//---------------------------------------------------------------------
/*/{Protheus.doc} fValTab
Verifica se o bem possui algum registro inserido na tabela

@param cTabela: tabela a ser verificada
@param cBem: bem a ser pesquisado na tabela
@author Wexlei Silveira
@since 29/10/2015
@version P11
@return cRet: Mensagem de erro, se houver
/*/
//---------------------------------------------------------------------
Static Function fValTab(cTabela, cBem)

//Local cQry
Local aCampos := {}
Local aAnd := {}
Local cRet := ""

If(cTabela == "TQ2") .And. NGSX2MODO("ST9") == "E"
	Aadd(aCampos, {"TQ2_FILIAL", "TQ2_CODBEM", "TQ2_DATATR DATA", "TQ2_HORATR HORA"})
	Aadd(aAnd, {"TQ2_POSCON > 0"})
	cRet := fVlQry(aCampos, "TQ2", cBem, aAnd, "TQ2_POSCON")
ElseIf(cTabela == "HTJ")
	Aadd(aCampos, {"HTJ_FILIAL", "HTJ_CODBEM", "HTJ_DTORIG DATA", "HTJ_HRCO1 HORA"})
	Aadd(aAnd, {"HTJ_POSCON > 0"})
	cRet := fVlQry(aCampos, "HTJ", cBem, aAnd, "HTJ_POSCON")
ElseIf(cTabela == "ST9")
	dbSelectArea("ST9")
	dbSetOrder(1)
	If dbSeek((cTRBARQ)->TP_FILIAL + cBem)

		dbSelectArea(cTRBARQ)
		dbSetOrder(3)
		//Pesquisa na TRB a existência do registro de histórico do contador
		If !dbSeek(ST9->T9_FILIAL + ST9->T9_CODBEM /*+ DtoS(ST9->T9_DTULTAC)*/)
			dbGoTop()
			cRet := STR0111 + cBem + STR0112 + cTabela + STR0113 + CRLF //"O registro " ## " da tabela " ## " não foi localizado no arquivo de importação."
		EndIf
		dbSelectArea(cTRBARQ)
		dbSetOrder(2)
	EndIf
	("ST9")->(dbCloseArea())
ElseIf(cTabela == "STJ")
	Aadd(aCampos, {"TJ_FILIAL", "TJ_CODBEM", "TJ_TERMINO", "TJ_DTMRFIM DATA", "TJ_HOMRFIM HORA", "TJ_DTORIGI DATA2", "TJ_HORACO1 HORA2"})
	Aadd(aAnd, {"TJ_POSCONT > 0", "TJ_SITUACA = 'L'", "(TJ_PLANO IN('000000', '000001') OR (TJ_PLANO NOT IN('000000', '000001') AND TJ_DTMRFIM <> '' AND TJ_HOMRFIM <> ''))"/*, "TJ_HOMRFIM <> ''"*/})
	cRet := fVlQry(aCampos, "STJ", cBem, aAnd, "TJ_POSCONT")
ElseIf(cTabela == "STS")
	Aadd(aCampos, {"TS_FILIAL", "TS_CODBEM", "TS_DTORIGI DATA", "TS_HOPPINI HORA"})
	Aadd(aAnd, {"TS_POSCONT > 0", "TS_SITUACA = 'L'"})
	cRet := fVlQry(aCampos, "STS", cBem, aAnd, "TS_POSCONT")
ElseIf(cTabela == "STW")
	Aadd(aCampos, {"TW_FILIAL", "TW_CODBEM", "TW_DTORIGI DATA", "TW_HORAC1 HORA"})
	Aadd(aAnd, {"TW_POSCONT > 0"})
	cRet := fVlQry(aCampos, "STW", cBem, aAnd, "TW_POSCONT")
ElseIf(cTabela == "STY")
	lSTYIni := .T.
	Aadd(aCampos, {"TY_FILIAL", "TY_CODBEM", "TY_DATAINI DATA", "TY_HORAINI HORA"})
	cRet := fVlQry(aCampos, "STY", cBem, aAnd, "TY_POSINI1")
	lSTYIni := .F.
	Aadd(aCampos, {"TY_FILIAL", "TY_CODBEM", "TY_DATAFIM DATA", "TY_HORAFIM HORA"})
	cRet := fVlQry(aCampos, "STY", cBem, aAnd, "TY_POSFIM1")
ElseIf(cTabela == "STZ")
	Aadd(aCampos, {"TZ_FILIAL", "TZ_BEMPAI", "TZ_DATAMOV DATA", "TZ_HORAENT HORA", "TZ_DATASAI DATA2", "TZ_HORASAI HORA2"})
	cRet := fVlQry(aCampos, "STZ", cBem,, "TZ_POSCONT")
ElseIf(cTabela == "TPN")
	Aadd(aCampos, {"TPN_FILIAL", "TPN_CODBEM", "TPN_DTINIC DATA", "TPN_HRINIC HORA"})
	Aadd(aAnd, {"TPN_POSCON > 0"})
	cRet := fVlQry(aCampos, "TPN", cBem, aAnd, "TPN_POSCON")
ElseIf(cTabela == "TPW")
	Aadd(aCampos, {"TPW_FILIAL", "TPW_CODBEM", "TPW_DTORIG DATA", "TPW_HORA HORA"})
	Aadd(aAnd, {"TPW_POSCON > 0"})
	cRet := fVlQry(aCampos, "TPW", cBem, aAnd, "TPW_POSCON")
ElseIf(cTabela == "TQA")
	Aadd(aCampos, {"TQA_FILIAL", "TQA_CODBEM", "TQA_DTORIG DATA", "TQA_HORAC1 HORA"})
	Aadd(aAnd, {"TQA_RETORN = 'S'", "TQA_POSCON > 0"})
	cRet := fVlQry(aCampos, "TQA", cBem, aAnd, "TQA_POSCON")
ElseIf(cTabela == "TQB")
	Aadd(aCampos, {"TQB_FILIAL", "TQB_CODBEM", "TQB_DTABER DATA", "TQB_HOABER HORA"})
	Aadd(aAnd, {"TQB_POSCON > 0"})
	cRet := fVlQry(aCampos, "TQB", cBem, aAnd, "TQB_POSCON")
ElseIf(cTabela == "TQN")
	Aadd(aCampos, {"TQN_FILIAL", "TQN_FROTA", "TQN_DTABAS DATA", "TQN_HRABAS HORA"})
	Aadd(aAnd, {"TQN_HODOM > 0"})
	cRet := fVlQry(aCampos, "TQN", cBem, aAnd, "TQN_HODOM")
ElseIf(cTabela == "TR9")
	Aadd(aCampos, {"TR9_FILIAL", "TR9_FROTA", "TR9_DTDIGI DATA", "TR9_HRDIGI HORA"})
	Aadd(aAnd, {"TR9_KMATU > 0"})
	cRet := fVlQry(aCampos, "TR9", cBem, aAnd, "TR9_KMATU")
ElseIf(cTabela == "TTI")
	Aadd(aCampos, {"TTI_FILIAL", "TTI_CODVEI", "TTI_DTENT DATA", "TTI_HRENT HORA"})
	cRet := fVlQry(aCampos, "TTI", cBem,,"TTI_POS1EN")
ElseIf(cTabela == "TUZ")
	Aadd(aCampos, {"TUZ_FILIAL", "TUZ_CODBEM", "TUZ_DATAIN DATA", "TUZ_HORAIN HORA"})
	Aadd(aAnd, {"TUZ_POSCON > 0"})
	cRet := fVlQry(aCampos, "TUZ", cBem, aAnd, "TUZ_POSCON")
ElseIf(cTabela == "TTF")
	Aadd(aCampos, {"TTF_FILIAL", "TTF_CODBEM", "TTF_DATA DATA", "TTF_HORA HORA"})
	cRet := fVlQry(aCampos, "TTF", cBem, aAnd, "TTF_POSCON")
EndIf

Return cRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fVlQry
Cria uma query que verifica a existência do registro de histórico do
contador da TRB

@sample
fVlQry(aCampos, cTabela, cBem, aAnd)

@param aCampos: array de campos do select. Com excessão da filial e do bem, todos os campos devem vir com apelido [Obrigatório]
@param cTabela: nome da tabela do select [Obrigatório]
@param cBem: código do bem a ser filtrado [Obrigatório]
@param aAnd: array com os filtros (AND) do select [não Obrigatório]
@param cField: nome do campo de Posição do contador [Obrigatório]
@author Wexlei Silveira
@since 30/10/2015
@version P11
@return cMens: Mensagem de erro, se houver
/*/
//---------------------------------------------------------------------
Static Function fVlQry(aCampos, cTabela, cBem, aAnd, cField)

	Local cQry
	Local Ni
	Local cMens      := ""
	Local cFiliArq   := ""
	Local cDtHr      := ""
	Local dData      := SToD("  /  /    ")
	Local aBemCod    := {"CODBEM", "_FROTA", "CODVEI", "BEMPAI"}
	Local lSTZ       := .F.
	Local lVlReg     := .F.
	Local cTzTemCont := ""
	Local cCampos    := ""

	Default aAnd := {}

	If !NGCADICBASE(aCampos[1][2], "A", cTabela, .F.)
		Return ""
	EndIf

	If cTabela == "TQ2"
		cCampos := "TQ2_FILORI, TQ2_FILDES, "
	ElseIf cTabela == "STZ"
		cCampos := "TZ_TIPOMOV, TZ_TEMCONT, "
	EndIf

	cAliasVl := GetNextAlias()

	cQry := "SELECT R_E_C_N_O_, "
	cQry += cCampos

	For Ni := 1 to Len(aCampos[1])

		cQry += aCampos[1][Ni] // Adiciona os campos que serão trazidos no SELECT

		If Right(aCampos[1][Ni], 6) == "FILIAL"
			cQry += " FILIAL"
		ElseIf AScan(aBemCod, Right(aCampos[1][Ni], 6)) != 0
			cQry += " BEM"
		EndIf

		IIf(Ni < Len(aCampos[1]), cQry += ", ", "")//Adiciona a vírgula entre os campos, exceto no último

	Next Ni

	cQry += ", " + cField + " POSCON"
	cQry += "  FROM " + RetSQLName(cTabela)
	cQry += " WHERE " + aCampos[1][2] + " = " + ValToSQL(cBem)

	If !Empty(aAnd)
		For Ni := 1 to Len(aAnd[1])
			cQry += "   AND " + aAnd[1][Ni]
		Next Ni
	EndIf

	cQry += "   AND D_E_L_E_T_ <> '*'"
	cQry := ChangeQuery(cQry)
	MPSysOpenQuery( cQry , cAliasVl )

	dbSelectArea(cAliasVl)
	dbGoTop()

	If (cAliasVl)->(!EoF())

		While(cAliasVl)->(!EoF()) // Pesquisa na TRB a existência do registro de histórico do contador

			dbSelectArea(cTRBARQ)
			dbSetOrder(2)

			If cTabela == "TQ2" .And. (cTRBARQ)->TP_TIPOLAN == "C"//Bem transferido desta filial, pega a filial de origem
				cFiliArq := (cAliasVl)->TQ2_FILORI
			ElseIf cTabela == "TQ2" .And. (cTRBARQ)->TP_TIPOLAN == "I"//Bem transferido para esta filial, pega a filial destino
				cFiliArq := (cAliasVl)->TQ2_FILDES
			Else
				cFiliArq := (cAliasVl)->FILIAL//Não sendo transferência, pega a filial do registro
			EndIf

			If(cTabela == "STJ")
				If ((cAliasVl)->TJ_TERMINO == "S")
					cDtHr := (cAliasVl)->DATA + (cAliasVl)->HORA// TJ_DTMRFIM + TJ_HOMRFIM
					dData := (cAliasVl)->DATA
				Else
					cDtHr := (cAliasVl)->DATA2 + (cAliasVl)->HORA2//TJ_DTORIGI + TJ_HORACO1
					dData := (cAliasVl)->DATA2
				EndIf
			Else
				cDtHr := (cAliasVl)->DATA + (cAliasVl)->HORA
				dData := (cAliasVl)->DATA
			EndIf

			If(cTabela == "STZ") .And. lSTZ
				dbSkip(-1)
				lSTZ := .F.
				If ((cAliasVl)->TZ_TIPOMOV == "S")
					cDtHr := (cAliasVl)->DATA2 + (cAliasVl)->HORA2//TZ_DATASAI +TZ_HORASAI
					lVlReg := .T.
				Else
					dbSkip()
				EndIf
			Else
				lVlReg := .F.
			EndIf

			If lSTYIni//Decrementa a hora inicial da STY em 1 porque ela é gravada assim na STP
				cDtHr := (cAliasVl)->DATA + MTOH(HTOM((cAliasVl)->HORA)-1)
			EndIf

			If ValType(dData) != "D"
				dData := SToD(dData)
			EndIf

			If cTabela == "STZ"
				cTzTemCont := (cAliasVl)->TZ_TEMCONT
			EndIf

			If ((dbSeek((cAliasVl)->BEM + cDtHr + xFilial("STP",cFiliArq)) .And. ((cTabela == "TQN" .And. (cTRBARQ)->TP_TIPOLAN == "A") .Or.;
				cTabela != "TQN") .Or. (dData < SToD(dParcial))) .Or. dData >= dDataBase) .Or. (cTzTemCont == "S")
				If(cTabela == "TQ2")
					If((cAliasVl)->TQ2_FILORI == (cTRBARQ)->TP_FILIAL .Or. (cAliasVl)->TQ2_FILDES == (cTRBARQ)->TP_FILIAL)
						aAdd(aRelacTbl,{cTabela,(cAliasVl)->R_E_C_N_O_, cField, IIF(lCheck .And.  DToS(dData) < dParcial, (cAliasVl)->POSCON, (cTRBARQ)->TP_POSCONT)})
					EndIf
				Else
					aAdd(aRelacTbl,{cTabela,(cAliasVl)->R_E_C_N_O_, cField, IIF(lCheck .And.  DToS(dData) < dParcial, (cAliasVl)->POSCON, (cTRBARQ)->TP_POSCONT)})
				EndIf
			ElseIf (!Empty(AllTrim(Substr(cDtHr,9,5))) .And. !Empty(AllTrim(Substr(cDtHr,1,8))))
				/*Adiciona ao TRB o registro que não foi encontrado somente se data E hora estiverem preenchidos na tabela relacionada*/
				If fAddReg((cAliasVl)->BEM, cValToChar(Substr(cDtHr,1,8)), Substr(cDtHr,9,5), (cAliasVl)->POSCON,;
						IIF(cTabela == "TQN", "A", IIF(cTabela == "STY","P","C")))
					cMens += STR0111 + (cAliasVl)->BEM + STR0114 + DToC(SToD(Substr(cDtHr,1,8))) + " " + Substr(cDtHr,9,5) +; //"O registro " ## " com a data "
								STR0112 + cTabela + IIF(cTabela == "TQN", STR0115, "") +; //" da tabela " ## " do tipo Abastecimento"
								STR0116 + CRLF //" não foi localizado no arquivo de importação. Este registro foi adicionado automaticamente ao arquivo."
				ElseIf dbSeek((cAliasVl)->BEM + cDtHr + cFiliArq) .And. (cTRBARQ)->TP_TIPOLAN != (IIF(cTabela == "TQN", "A", IIF(cTabela == "STY","P","C")))
					cMens += STR0111 + (cAliasVl)->BEM + STR0114 + DToC(SToD(Substr(cDtHr,1,8))) + " " + Substr(cDtHr,9,5) +; //"O registro " ## " com a data "
								STR0112 + cTabela + IIF(cTabela == "TQN", STR0115, "") +; //" da tabela " ## " do tipo Abastecimento"
								STR0117 + CRLF //" foi localizado no arquivo de importação com um tipo incorreto de lançamento."
				EndIf
			EndIf

			lSTZ := (cTabela == "STZ") .And. !lVlReg
			dbSelectArea(cAliasVl)
			dbSkip()
		End
	EndIf

	(cAliasVl)->(dbCloseArea())

Return cMens
//---------------------------------------------------------------------
/*/{Protheus.doc} fAddReg
Adiciona ao TRB o registro que não foi encontrado

@sample
fAddReg()

@param cBem: Código do Bem  do registro [Obrigatório]
@param cData: Data de leitura do registro [Obrigatório]
@param cHora: Hora do registro [Obrigatório]
@param fPoscon: Posição do contador do registro [Obrigatório]
@param cTipolan: Tipo de lançamento do registro [Obrigatório]
@author Wexlei Silveira
@since 02/03/2016
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fAddReg(cBem, cData, cHora, fPoscon, cTipolan)

Local lRet := .F.
Local aArea := GetArea()
Local cCodFil := NgFilTPN(cBem, SToD(cData), cHora, NGSEEK("ST9", cBem, 1, "T9_PLACA" ))[1]

If !(cTipolan == "I" .And. lParcInc == .T.)
	dbSelectArea(cTRBARQ)
	dBSetOrder(02)
	If !dbSeek(cBem+cData+cHora)
		RecLock((cTRBARQ), .T.)
		(cTRBARQ)->TP_FILIAL 	:= cCodFil
		(cTRBARQ)->TP_CODBEM 	:= cBem
		(cTRBARQ)->TP_DTLEITU 	:= SToD(cData)
		(cTRBARQ)->TP_HORA 	:= cHora
		(cTRBARQ)->TP_POSCONT 	:= fPoscon
		(cTRBARQ)->TP_ACUMCON 	:= 0
		(cTRBARQ)->TP_TIPOLAN 	:= cTipolan
		(cTRBARQ)->DT_PARCIAL  := dParcial
		MSUnlock(cTRBARQ)
		lRet := .T.
		aAdd(aErros, cCodFil + cBem + cValToChar(cData) + cHora + cValToChar(fPoscon) + cValToChar(0) + cTipolan)
	ElseIf (cTRBARQ)->TP_TIPOLAN != cTipolan
		aAdd(aErros, cCodFil + cBem + cValToChar(cData) + cHora + cValToChar(fPoscon) + cValToChar((cTRBARQ)->TP_ACUMCON) + (cTRBARQ)->TP_TIPOLAN)
		aAdd(aTipolan, {cCodFil + cBem + cValToChar(cData) + cHora + cValToChar(fPoscon) + cValToChar((cTRBARQ)->TP_ACUMCON) + (cTRBARQ)->TP_TIPOLAN, cTipolan})
	EndIf

EndIf

RestArea(aArea)

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fDelRDbf
Cria backup do arquivo selecionado pelo usuário e deleta arquivo do
diretório temporário

@sample
fDelRDbf()

@author Wexlei Silveira
@since 14/10/2015
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fDelRDbf()

	If File(cTempPath+ cBkp) .And. (FErase(cTempPath+ cBkp) != 0)//Deleta o arquivo de backup
		MsgStop(STR0118,STR0013)	//do diretório temporário##"Atenção" ## "Erro ao atualizar arquivo de backup."
		Return .F.
	EndIf

	If !File(cStartPath + "\backup\" + cBkp)
		If(!CpyS2T(cStartPath + "\" + GetFileName(cFile), cTempPath))
			MsgStop(STR0043,STR0013) //"Erro ao criar arquivo de backup." ## "Atenção"
			Return .F.
		ElseIf(FRename(cTempPath+ GetFileName(cFile), cTempPath+ cBkp) != 0)
			Return .F.
		ElseIf !CpyT2S(cTempPath+ cBkp, cStartPath+"\backup")
			MsgStop(STR0043,STR0013) //"Erro ao criar arquivo de backup." ## "Atenção"
			Return .F.
		EndIf
	EndIf

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT876When

@sample
MNT876When()

@author Felipe Nathan Welter
@since 23/10/2015
@version 1.0
/*/
//---------------------------------------------------------------------
Function MNT876When()

Local lWhen := .F.
Local cField := ReadVar()
Local nI

If "TP_ACUMCON" $ cField

	If aCols[n,7] == "I"

		aCols2 := {}
		AEval(aCols, {|x| IIf(x[7] == "I" .And. x[2] == aCols[n,nPosCodBem],aAdd(aCols2,aClone(x)),Nil)})
		If Len(aCols2) > 0
			ASort(aCols2, , , {|x,y|DTOS(x[3])+x[4] < DTOS(y[3])+y[4]})
			If Len(aCols2) == 1 .Or. DTOS(aCols[n,nPosDtLeitu])+aCols[n,nPosHora] == DTOS(aCols2[1,nPosDtLeitu])+aCols2[1,nPosHora]
				lWhen := .T.
			ElseIf Len(aCols2) > 1
				For nI := 1 To Len(aCols2)
					If DTOS(aCols[n,nPosDtLeitu])+aCols[n,nPosHora] == DTOS(aCols2[nI,nPosDtLeitu])+aCols2[nI,nPosHora]
						lWhen := .T.
					EndIf
				Next nI
			EndIf
		EndIf
	EndIf
EndIf

Return lWhen
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT876BTL
Bloqueia campos por tipo de lançamento conforme parâmetro MV_NGLANEX

Quando houver Abastecimento posterior:
Não permite alterar Quebra e Virada;
Quando não houver Abastecimento posterior:
Permite alterar Quebra e Virada;

@sample
MNT876BTL()

@author Wexlei Silveira
@since 11/10/2016
@version 1.0
/*/
//---------------------------------------------------------------------
Function MNT876BTL()

	Local lRet      := .T.
	Local nPosQVLan := 0 
	Local cBemLanex := cMV_Lanex

	If !Empty( cMV_Lanex ) .And. FindFunction('NGUSELANEX')
		cBemLanex := NGUSELANEX( aCols[n][nPosCodBem] ) // verifica se bem utiliza lanex
	EndIf

	nPosQVLan := aScan(aCols,{|x| Trim(Upper(x[nPosTipoLan])) $ "QV"+AllTrim(cBemLanex)},n+1,Len(aCols))//Posição do próximo registro do tipo Q, V ou contido no MV_NGLANEX

	If !((aCols[n][nPosTipoLan] $ cBemLanex) .Or. Empty(aCols[n][nPosTipoLan]) .Or. aCols[n][nPosTipoLan] == "I")
		lRet := !(aCols[n][nPosTipoLan] $ "QV" .And. nPosQVLan > 0 .And. !aCols[nPosQVLan][Len(aCols[nPosQVLan])])
		If !Empty(cBemLanex)
			lRet := (aCols[n][nPosTipoLan] $ AllTrim(cBemLanex) .And. (nPosQVLan == 0 .Or. !aCols[nPosQVLan][nPosTipoLan] $ cBemLanex))
		EndIf
	EndIf

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fCriaGrid
Cria o MsGetDados para executar a importação

@sample
fCriaGrid()

@author Wexlei Silveira
@since 15/10/2015
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fCriaGrid(oProcess,lEnd)

	Local aHeader    := {}
	Local aCols      := {}
	Local aAlterCols := {"TP_FILIAL","CODBEM","DTLEITU","HORA","TP_POSCONT","TP_ACUMCON","TP_TIPOLAN"}//Vetor com os campos que poderão ser alterados
	Local lRet       := .F.
	Local bfDeleta   := {|| fDelOk()}

	Local cTitulo		:= ""
	Local cPicture		:= ""
	Local cUsado		:= ""
	Local cTipo			:= ""
	Local cF3			:= ""
	Local cContext		:= ""
	Local cCBox			:= ""
	Local cRelacao		:= ""
	Local cValid		:= ""
	Local cWhen			:= ""
	Local nTamanho		:= 0
	Local nDecimal		:= 0
	Local nTot 			:= 0
	Local nInd			:= 0
	Local cCampo		:= ""
	Local aCampos		:= { "TP_FILIAL", "TP_CODBEM", "TP_DTLEITU", "TP_HORA", "TP_POSCONT", "TP_ACUMCON", "TP_TIPOLAN" }

	oProcess:SetRegua2(Len(aBens))

	nTot := Len(aCampos)
	For nInd := 1 To nTot

		cCampo := aCampos[nInd]
		If STP->(FieldPos(cCampo)) > 0

			cTitulo		:= AllTrim(Posicione("SX3", 2, cCampo, "X3Titulo()"))
			cPicture	:= X3Picture(cCampo)
			nTamanho	:= TAMSX3(cCampo)[1]
			nDecimal	:= TAMSX3(cCampo)[2]
			cValid		:= "MNT876VGrd()"
			cUsado		:= Posicione("SX3", 2, cCampo, "X3_USADO")
			cTipo		:= Posicione("SX3", 2, cCampo, "X3_TIPO") 
			cF3			:= Posicione("SX3", 2, cCampo, "X3_F3") 
			cContext	:= Posicione("SX3", 2, cCampo, "X3_CONTEXT")
			cCBox		:= Posicione("SX3", 2, cCampo, "X3CBox()")
			cRelacao	:= Posicione("SX3", 2, cCampo, "X3_RELACAO")
			cWhen		:= 'MNT876BTL()'

			Do Case
				Case cCampo == "TP_CODBEM"
					cF3		:= 'ST9VIS'
					cCampo 	:= "CODBEM"

				Case cCampo == "TP_DTLEITU"
					cCampo 	:= "DTLEITU"

				Case cCampo == "TP_HORA"
					cCampo 	:= "HORA"

				Case cCampo == "TP_ACUMCON"
					cWhen 	:= 'MNT876When() .And. MNT876BTL()'

			EndCase

			aAdd(aHeader, { cTitulo ,cCampo, cPicture, nTamanho, nDecimal, cValid, cUsado, cTipo, cF3, cContext, cCBox, cRelacao, cWhen})

        EndIf
    Next nInd

	(cTRBARQ)->(dbGoTop())

	lCheck := IIF(Trim((cTRBARQ)->DT_PARCIAL) == "", .F., .T.)//Registros do arquivo são uma importação parcial
	dParcial := IIF(Empty((cTRBARQ)->DT_PARCIAL),"", (cTRBARQ)->DT_PARCIAL)//Data da importação parcial

	While (cTRBARQ)->(!EoF())
		oProcess:IncRegua2(STR0119 + Trim((cTRBARQ)->TP_CODBEM)) //"Carregando bem "
		aAdd(aCols, {(cTRBARQ)->TP_FILIAL, (cTRBARQ)->TP_CODBEM, (cTRBARQ)->TP_DTLEITU, (cTRBARQ)->TP_HORA, (cTRBARQ)->TP_POSCONT,;
					(cTRBARQ)->TP_ACUMCON, (cTRBARQ)->TP_TIPOLAN, .F.})

		(cTRBARQ)->(dbSkip())
	EndDo

	nPosFilial  := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TP_FILIAL"})
	nPosCodBem  := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "CODBEM"})
	nPosDtLeitu := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "DTLEITU"})
	nPosHora    := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "HORA"})
	nPosPosCont := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TP_POSCONT"})
	nPosAcumCon := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TP_ACUMCON"})
	nPosTipoLan := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TP_TIPOLAN"})

	DEFINE MSDIALOG oDlgGrid TITLE OemToAnsi(cTitle) From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd COLOR CLR_BLACK,CLR_WHITE PIXEL

		oGetDBF := MsNewGetDados():New(0, 1, aSize[6] - 80, aSize[5], GD_INSERT + GD_UPDATE + GD_DELETE, {|| MNT876LIN()},;
		                               {|| MNT876TD()}, '',aAlterCols, 0, 9999, 'AllwaysTrue()', '', bfDeleta, oDlgGrid, aHeader, aCols)

		oGetDBF:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		oGetDBF:oBrowse:lUseDefaultColors := .F.
		oGetDBF:oBrowse:SetBlkBackColor({ || f876ACor(aHeader, aCols)})
		oGetDBF:oBrowse:Refresh()

		oPnlBtm       := TPanel():New(200, 400,, oDlgGrid,,,,,CLR_HGRAY, 200, 12, .F., .F.)
		oPnlBtm:Align := CONTROL_ALIGN_BOTTOM

		oPnlOK       := TPanel():New(200, 400,, oPnlBtm,,,,,CLR_HGRAY, 80, 12, .F., .F.)
		oPnlOK:Align := CONTROL_ALIGN_RIGHT

		oPnlPar       := TPanel():New(200, 400,, oPnlBtm,,,,,CLR_HGRAY, 90, 12, .F., .F.)
		oPnlPar:Align := CONTROL_ALIGN_LEFT

		@ 01,01 BUTTON STR0120 SIZE 036,010 Pixel OF oPnlOK  ACTION(lRet := .F., fCancel()) //"Cancelar"
		@ 01,40 BUTTON "OK"    SIZE 036,010 Pixel OF oPnlOK  ACTION(lRet := .T., oDlgGrid:End())
		@ 01,01 BUTTON STR0121 SIZE 036,010 Pixel OF oPnlPar ACTION(fParam()) //"Parâmetros"
		@ 01,40 BUTTON STR0122 SIZE 040,010 Pixel OF oPnlPar ACTION(fViewLog()) //"Visualizar Log"

	Activate MsDialog oDlgGrid Centered

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} f876ACor
Pinta as linhas da TRB que foram adicionadas ou que contém erro.

@author Wexlei Silveira, Felipe Nathan Welter
@since 10/01/2016
/*/
//---------------------------------------------------------------------
Static Function f876ACor(aHeader, aCols)

	Local cColor := CLR_WHITE
	Local nLoop
	Local nPos := 0
	Local cBemLanex := cMV_Lanex 
	
	If !Empty(aErros)

		If cMV_Lanex $ "A" .And. FindFunction('NGUSELANEX')
			cBemLanex := NGUSELANEX( cValToChar(oGetDBF:aCols[oGetDBF:nAt][nPosCodBem]) )
		EndIf

		For nLoop := 1 to Len(aErros)
			If(aErros[nLoop] == cValToChar(oGetDBF:aCols[oGetDBF:nAt][nPosFilial]) +;
				cValToChar(oGetDBF:aCols[oGetDBF:nAt][nPosCodBem]) + DToS(oGetDBF:aCols[oGetDBF:nAt][nPosDtLeitu]) +;
				cValToChar(oGetDBF:aCols[oGetDBF:nAt][nPosHora]) + cValToChar(oGetDBF:aCols[oGetDBF:nAt][nPosPosCont]) +;
				cValToChar(oGetDBF:aCols[oGetDBF:nAt][nPosAcumCon]) + cValToChar(oGetDBF:aCols[oGetDBF:nAt][nPosTipoLan]))

				nPos := IIF(Empty(aTipolan),0,aScan(aTipolan[1],aErros[nLoop]))
				If nPos > 0 .And. cBemLanex $ aTipolan[nPos,2]
					dbSelectArea((cTRBARQ))
					If(dbseek(cValToChar(oGetDBF:aCols[oGetDBF:nAt][nPosCodBem]) + DToS(oGetDBF:aCols[oGetDBF:nAt][nPosDtLeitu]) +;
							cValToChar(oGetDBF:aCols[oGetDBF:nAt][nPosHora])))
						RecLock((cTRBARQ), .F.)
						(cTRBARQ)->TP_TIPOLAN := aTipolan[nPos,2]
						cColor := CLR_YELLOW
						oGetDBF:aCols[oGetDBF:nAt][nPosTipoLan] := aTipolan[nPos,2]
						cColor := CLR_YELLOW
						MSUnlock(cTRBARQ)
						aDel(aTipolan,nPos)
						aSize(aTipolan, Len(aTipolan)-1)
					EndIf
				EndIf
				cColor := CLR_YELLOW
			EndIf
		Next nLoop
	EndIf

Return cColor
//---------------------------------------------------------------------
/*/{Protheus.doc} fViewLog
Exibe o Log de inconsistências.

@author Tainã Alberto Cardoso.
@since 25/11/2019
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fViewLog()

	Local cLinha  := ''
	Local cFile   := ''
	Local cMask   := "Arquivos Texto (*.TXT) |*.txt|"
	Local lLogProcess := .F.
	Local oDlg
	Local oTGetLog

	If File(cArqFun)

		DEFINE DIALOG oDlg TITLE STR0027 FROM 3, 10 TO 340, 550 PIXEL //"Reprocessamento de contador próprio"

  			oTGetLog := tMultiget():new( 01, 01, {| u | if( pCount() > 0, cLinha := u, cLinha ) },oDlg, 265, 145, , , , , , .T. )

			FT_FUSE(cArqFun)
			FT_FGOTOP()
			lLogProcess := !Empty(FT_FREADLN())

			While (!FT_FEof()) .And. lLogProcess

				cLinha    := FT_FREADLN()
				oTGetLog:AppendText( cLinha + CRLF )

				FT_FSKIP()

			End

			oBtnSal := SButton():New( 155 , 215 , 13 , {|| (cFile := cGetFile( cMask , OemToAnsi( STR0132 + "..." ) ),; //"Salvar Como"
				If( cFile == "" , .T. , MemoWrite( If( ".txt" $ cFile , cFile , AllTrim( cFile ) + ".txt" ), cLinha ) ), ;
				oDlg:End() ) } , oDlg , .T. , /*cMsg*/ , /*bWhen*/ )

			oBtnApa := SButton():New( 155 , 245 , 1 , {|| oDlg:End() } , oDlg , .T. , /*cMsg*/ , /*bWhen*/ )

		ACTIVATE DIALOG oDlg CENTERED
	Else
		MsgInfo(STR0131) //"Não possui Log de reprocessamento"
	EndIf

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fCancel
Restaura o backup da STP e ST9 quando o usuário cancelar a operação.

@author Wexlei Silveira
@since 01/03/2017
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fCancel()

If !Empty(cBkp)//Verifica se foi criado um arquivo de backup
	fRecBkp()
EndIf

oDlgGrid:End()

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fDelOk
Bloqueia a exclusão de registros de Quebra e Virada.

@author Wexlei Silveira
@since 06/04/2017
/*/
//---------------------------------------------------------------------
Static Function fDelOk()

	Local lRet      := .T.
	Local nPosAbast := 0 
	Local cBemLanex := cMV_Lanex

	If !Empty( cMV_Lanex ) .And. FindFunction('NGUSELANEX')
		cBemLanex := NGUSELANEX( aCols[n][nPosCodBem] ) // verifica se bem utiliza lanex
	EndIf

	nPosAbast := aScan(aCols,{|x| Trim(Upper(x[nPosTipoLan])) $ "QV"+AllTrim(cBemLanex)},n+1,Len(aCols))

	If Len(aCols) > 0
		If aCols[n][nPosTipoLan] == "I" .And. aCols[n][Len(aCols[n])]
			If aScanX(aCols,{ |x,y| Trim(Upper(x[nPosTipoLan]))  =="I" .AND. y <> n .And. !x[Len(aCols[n])]}) > 0
				MsgInfo(STR0077) //"Ja existe um registro do tipo de inclusão."
				lRet := .F.
			EndIf
		ElseIf aCols[n][nPosTipoLan] $ "QV"
			If aCols[n][nPosTipoLan] = "V"
				MsgStop(STR0078) //"Não é possível excluir registros do tipo Virada."
				lRet := .F.
			ElseIf nPosAbast > 0 .And. !aCols[nPosAbast][Len(aCols[nPosAbast])]
				MsgStop(STR0079) //"Não é possível alterar este registro, pois existem registros de Abastecimento, Quebra ou Virada posterior."
				lRet := .F.//Generalizar a mensagem para abranger outros tipos de contador quando estes forem implementados.
			EndIf
		ElseIf aCols[n][nPosTipoLan] $ AllTrim(cBemLanex)
			MsgStop(STR0080) //"O parâmetro MV_NGLANEX impede exclusão de registros de Abastecimento."
			lRet := .F.//Generalizar a mensagem para abranger outros tipos de contador quando estes forem implementados.
		EndIf
	EndIf

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT876VGrd
Validação por campo da grid

@sample
MNT876VGrd()

@author Felipe Nathan Welter, Wexlei Silveira
@since 15/10/2015
@version 1.0
/*/
//---------------------------------------------------------------------
Function MNT876VGrd()

	Local lRet      := .T.
	Local cField    := ReadVar()
	Local nPosInc   := 0
	Local cBemLanex := ""

	If "TP_FILIAL" $ cField
	ElseIf "CODBEM" $ cField
		ExistCPO("ST9", M->CODBEM)
	ElseIf "DTLEITU" $ cField
		If Empty(M->DTLEITU)
			ShowHelpDlg(STR0013, {STR0069}, 1, {STR0070}, 1) //"ATENCAO" ## "Campo Data inválido." ## "Informe uma data válida para o campo."
			lRet := .F.
		Else
			lRet := NGCPDIAATU(M->DTLEITU, "<=", .T., .T., .T.)
		EndIf
	ElseIf "HORA" $ cField
		Return NGVALHORA(M->HORA, .T.)
	ElseIf "TP_POSCONT" $ cField
		If M->TP_POSCONT < 0
			ShowHelpDlg(STR0013, {STR0071}, 1, {STR0072}, 1) //"ATENCAO" ## "Campo Contador menor que zero." ## "Informe um valor para o campo Contador maior que zero."
			lRet := .F.
		EndIf
	ElseIf "TP_ACUMCON" $ cField
		If M->TP_ACUMCON < 0
			ShowHelpDlg(STR0013, {STR0073}, 1, {STR0074}, 1) //"ATENCAO" ## "Campo Ac. Contador menor que zero." ## "Informe um valor para o campo Ac. Contador maior que zero."
			lRet := .F.
		EndIf
	ElseIf "TP_TIPOLAN" $ cField

		If !Empty( cMV_Lanex )
			cBemLanex := IIf( FindFunction('NGUSELANEX'), NGUSELANEX( oGetDBF:aCols[n][nPosCodBem] ), cMV_Lanex )
		EndIf

		If M->TP_TIPOLAN <> "I" .And. !Empty( cBemLanex ) .And. !(M->TP_TIPOLAN $ cBemLanex)
			ShowHelpDlg(STR0013, {STR0075}, 1, {STR0076}, 1) //"ATENCAO" ## "Tipo de lançamento nao permitido." ## "Informe um tipo que esteja configurado no parametro MV_NGLANEX."
			lRet := .F.
		ElseIf M->TP_TIPOLAN == "I"
			nPosInc := aScanX(oGetDBF:aCols,{ |x,y| Trim(Upper(x[nPosTipoLan]))  =="I" .AND. y <> n .And. !x[Len(oGetDBF:aCols[n])]})
			If nPosInc > 0
				MsgInfo(STR0077) //"Ja existe um registro do tipo de inclusão."
				lRet := .F.
			EndIf
		EndIf
	EndIf

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT876LIN
Validação por linhas do arquivo carregado pelo usuário

@sample
MNT876LIN()

@author Wexlei Silveira
@since 23/10/2015
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function MNT876LIN()

Local cErro := ""

If Empty(oGetDBF:aCols[oGetDBF:nAt][nPosFilial]) .And. NGSX2MODO("STP") = 'E'
	ShowHelpDlg(STR0013, {STR0081}, 1, {STR0082}, 1) //"ATENCAO" ## "Campo Filial vazio." ## "Informe um valor para o campo Filial."
	Return .F.
ElseIf Empty(oGetDBF:aCols[oGetDBF:nAt][nPosCodBem])
	ShowHelpDlg(STR0013, {STR0083}, 1, {STR0084}, 1) //"ATENCAO" ## "Campo Bem vazio." ## "Informe um valor para o campo Bem."
	Return .F.
ElseIf Empty(oGetDBF:aCols[oGetDBF:nAt][nPosDtLeitu])
	ShowHelpDlg(STR0013, {STR0085}, 1, {STR0086}, 1) //"ATENCAO" ## "Campo Data Leitura vazio." ## "Informe um valor para o campo Data Leitura."
	Return .F.
ElseIf Empty(oGetDBF:aCols[oGetDBF:nAt][nPosHora])
	ShowHelpDlg(STR0013, {STR0087}, 1, {STR0088}, 1) //"ATENCAO" ## "Campo Hora Lançamento vazio." ## "Informe um valor para o campo Hora Lançamento."
	Return .F.
ElseIf Empty(oGetDBF:aCols[oGetDBF:nAt][nPosPosCont])
	ShowHelpDlg(STR0013, {STR0089}, 1, {STR0090}, 1) //"ATENCAO" ## "Campo Contador vazio." ## "Informe um valor para o campo Contador."
	Return .F.
ElseIf Empty(oGetDBF:aCols[oGetDBF:nAt][nPosTipoLan])
	ShowHelpDlg(STR0013, {STR0091}, 1, {STR0092}, 1) //"ATENCAO" ## "Campo Tipo Lançamento vazio." ## "Informe um valor para o campo Tipo Lançamento."
	Return .F.
EndIf

If !Empty(cErro)
	MsgStop(cErro)
	Return .F.
EndIf

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT876TD
Validação do arquivo carregado pelo usuário (TUDOOK)

@sample
MNT876TD()

@author Wexlei Silveira
@since 23/10/2015
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function MNT876TD()

cErro := fValidTpI(oGetDBF:aCols[oGetDBF:nAt][nPosCodBem])//validacao inicial (tipo inclusao)

If !Empty(cErro)
	MsgStop(cErro)
	Return .F.
EndIf

cErro := MNT876VLT(oGetDBF:aCols[oGetDBF:nAt][nPosCodBem])//valida relacionamentos

If !Empty(cErro)
	MsgStop(cErro)
	Return .F.
EndIf

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fParam
Popup de parâmetros da grid de importação

Para adicionar uma nova aba de opções, siga as instruções nos comentários
da função e adicione o parâmetro MV_PAR da SX1 na função fCriaParam() nos
mesmos moldes dos parâmetros já existentes lá. Na função principal
(MNTA876) também é necessário inicializar o MV_PAR criado para o parâmetro
da nova aba. Já há um bloco lá para isso.

@sample
fParam()

@author Wexlei Silveira
@since 09/12/2015
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fParam()

Local oDlgPP, oPnlTop, oPnlCenter, oPnlBottom
//Local oComboRg
Local aOpt := {}//, aRegras := {"Variação Dia"}
//Local cRegra := ""
Local nOptVD := IIf(MV_PAR01 == 0, 1, MV_PAR01)//Adicione uma nova variável para armazenar a opção escolhida
Local nOptCT := IIf(MV_PAR02 == 0, 1, MV_PAR02)//quando for adicionar uma nova aba.
//Local nOptES := IIf(MV_PAR03 == 0, 3, MV_PAR03)
Local lOK := .F.
Local aTFolder := {STR0123,STR0124/*, "Eixo Suspenso"*/}//Adicione o título da nova aba aqui ## "Variação dia" ## "Contador"

aAdd(aOpt, {STR0125, STR0126, STR0127})//Adicione as opções de usuário aqui ## "Bloquear" ## "Liberar" ## "Perguntar"
//aAdd(aOpt, {"Nunca suspender", "Sempre suspender", "Perguntar"})//Opções especiais de eixo suspenso

Define MsDialog oDlgPP From 0,0 To 200,420 Title STR0121 Pixel Style DS_MODALFRAME //"Parâmetros"

	oPnlTop := TPanel():New(0, 0,, oDlgPP,,,,,, 200, 20, .F., .F.)
	oPnlCenter := TPanel():New(20, 0,, oDlgPP,,,,,, 200, 100, .F., .F.)
	oPnlBottom := TPanel():New(200, 400,, oDlgPP,,,,,CLR_HGRAY, 200, 15, .F., .F.)
	oPnlTop:Align := CONTROL_ALIGN_TOP
	oPnlBottom:Align := CONTROL_ALIGN_BOTTOM
	oPnlCenter:Align := CONTROL_ALIGN_ALLCLIENT

	oTFolder := TFolder():New(0,0,aTFolder,,oPnlCenter,,,,.T.,,200,100)
	oTFolder:Align := CONTROL_ALIGN_ALLCLIENT

	@ 05, 05 Say OemToAnsi(STR0008) Size 180, 60 Of oPnlTop Pixel

	/*Para adicionar uma nova aba de opções, copie o bloco abaixo (da aba Variação dia, por exemplo);
	  Necessário mudar no bloco:
	  -> O título da aba;
	  -> a posição no array aDIALOGS;
	  -> a variável nOpt.
	*/

	/*Aba Variação dia*/
	@ 15, 05 Say OemToAnsi(STR0009) Size 110, 65 Of oTFolder:aDIALOGS[1] Pixel
	@ 15, 125 To 45, 180 LABEL "" of oTFolder:aDIALOGS[1] Pixel
	TRadMenu():New(16, 130, aOpt[1], {|u| IIf (PCount() == 0, nOptVD, nOptVD := u)}, oTFolder:aDIALOGS[1],,,,,,,, 50, 60,,,, .T.)

	/*Aba Contador*/
	@ 15, 05 Say OemToAnsi(STR0010) Size 110, 65 Of oTFolder:aDIALOGS[2] Pixel
	@ 15, 125 To 45, 180 LABEL "" of oTFolder:aDIALOGS[2] Pixel
	TRadMenu():New(16, 130, aOpt[1], {|u| IIf (PCount() == 0, nOptCT, nOptCT := u)}, oTFolder:aDIALOGS[2],,,,,,,, 50, 60,,,, .T.)

	/*Barra inferior com os botões OK/Cancelar*/
	@ 3,120 BUTTON "OK" SIZE 036,010 Pixel OF oPnlBottom ACTION(lOK := .T., oDlgPP:End())
	@ 3,160 BUTTON STR0120 SIZE 036,010 Pixel OF oPnlBottom ACTION(lOK := .F., oDlgPP:End()) //"Cancelar"

	Activate MsDialog oDlgPP Centered

	If lOK //adicione um bloco de If para inserir na SX1 a opção selecionada na nova aba:
		MV_PAR01 := nOptVD//Adicione aqui o MV_PAR criado para manter a opção escolhida ao longo da utilização da rotina.
		MV_PAR02 := nOptCT
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fVlAbast
Valida se há um registro de abastecimento quando TIPOLAN do bem for "A"

@sample
fVlAbast()

@param cFilAb: Código da Filial
@param cFrota: Código do bem
@param cDtAbas: Data
@param cHrAbas: Hora
@author Wexlei Silveira
@since 14/12/2015
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fVlAbast(cFilAb, cFrota, cDtAbas, cHrAbas)

	Local aRet := {.T.,""}
	Local lTemAfer := .F.
	Local cAliasVl := GetNextAlias()

	BeginSql Alias cAliasVl
		SELECT TQN_POSTO, TQN_LOJA, TQN_TANQUE, TQN_BOMBA ,
		       TQN_DTABAS , TQN_HRABAS FROM %Table:TQN%
			WHERE %NotDel% AND
			TQN_FROTA = %exp:cFrota% AND
			TQN_DTABAS = %exp:cDtAbas% AND
			TQN_HRABAS = %exp:cHrAbas% AND
			TQN_FILIAL = %exp:xFilial('TQN', cFilAb )%
	EndSql

	/*Verifica se há registro na TQN para o abastecimento*/
	If (cAliasVl)->(!EoF())
		SetAltera()
		aRet := NGVALABAST((cAliasVl)->TQN_POSTO,(cAliasVl)->TQN_LOJA,(cAliasVl)->TQN_TANQUE,(cAliasVl)->TQN_BOMBA,;
		                   SToD((cAliasVl)->TQN_DTABAS),((cAliasVl)->TQN_HRABAS),.F.,.F., .F.)
	Else
		aRet := {.F.,STR0128 + cDtAbas + STR0049 + cHrAbas} //"Não foi encontrado abastecimento no dia: " ## " e hora: "
	EndIf

	/*Verifica a aferição da bomba*/
	If(SuperGetMv("MV_NGMNTAF",.F.,"2") == "1")//Verifica parametro que indica se deve validar com afericao
		dbSelectArea("TQL")
		dbSetOrder(1)
		If dbSeek(xFilial("TQL")+(cAliasVl)->TQN_POSTO+(cAliasVl)->TQN_LOJA+(cAliasVl)->TQN_TANQUE+(cAliasVl)->TQN_BOMBA+(cAliasVl)->TQN_DTABAS)
			While !EoF() .And. ;
				TQL->TQL_FILIAL + TQL->TQL_POSTO+TQL->TQL_LOJA + TQL->TQL_TANQUE + TQL->TQL_BOMBA+DTOS(TQL->TQL_DTCOLE) == xFilial("TQL") +;
				(cAliasVl)->TQN_POSTO + (cAliasVl)->TQN_LOJA + (cAliasVl)->TQN_TANQUE + (cAliasVl)->TQN_BOMBA + (cAliasVl)->TQN_DTABAS
				If (cAliasVl)->TQN_HRABAS > TQL->TQL_HRINIC .And. Empty(TQL->TQL_HRFIM)
					lTemAfer := .T.
				Elseif (cAliasVl)->TQN_HRABAS > TQL->TQL_HRINIC .And. !Empty(TQL->TQL_HRFIM) .And. (cAliasVl)->TQN_HRABAS < TQL->TQL_HRFIM
					lTemAfer := .T.
				Endif
				TQL->(dbSkip())
			End
		EndIf
		("TQL")->(dbCloseArea())
		If !lTemAfer .And. TQF->TQF_TIPPOS == "2" // Se for igual a Posto Interno.
			aRet := {.F.,STR0129 + cDtAbas + " "+ cHrAbas} //"Tanque/Bomba não possui aferição para data e hora do abastecimento: "
		EndIf
	EndIf

	(cAliasVl)->(dbCloseArea())

Return aRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fST9Bkp
Realiza o backup de campos da ST9 em um array

@sample
fST9Bkp()

@param aBens: Array contendo o Código do Bem e sua filial
@author Wexlei Silveira
@since 19/01/2016
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fST9Bkp(aBens)

Local nLoop, nFilial

If Empty(aST9Bkp)
	Dbselectarea("ST9")
	Set Filter To
	Dbsetorder(1)
	For nLoop := 1 to Len(aBens)
		For nFilial := 1 to Len(aBens[nLoop, 2])
			If dbseek(NGTrocaFili("ST9",aBens[nLoop, 2, nFilial]) + aBens[nLoop, 1])//Filial + Cód. Bem
				Aadd(aST9Bkp, {aBens[nLoop, 1], aBens[nLoop, 2, nFilial], ST9->T9_POSCONT, ST9->T9_DTULTAC, ST9->T9_CONTACU, ST9->T9_VIRADAS})
				RecLock('ST9', .F.)
				ST9->T9_POSCONT := 0
				ST9->T9_CONTACU := 0
				ST9->T9_DTULTAC := SToD('')
				ST9->T9_VIRADAS := 0
				ST9->(MsUnLock())
			EndIf
		Next nFilial
	Next nLoop
	("ST9")->(dbCloseArea())
EndIf
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fGetDtInc
Retorna a data de inclusão do bem, de acordo com o campo T9_DTCOMPR
e a data de leitura da inclusão do bem na STP para a filial.

@sample
fGetDtInc(cCodBem)

@param cCodBem: Bem a ser pesquisado
@param: cFil: Filial para verificação da STP
@author Wexlei Silveira
@since 08/06/2017
@version 1.0
@return dInc (char)
/*/
//---------------------------------------------------------------------
Static Function fGetDtInc(cCodBem, cFil)

Local aArea := GetArea()
Local aDtInc := {}

dbSelectArea("ST9")
dbSetOrder(16)
If dbSeek(cCodBem)
	aAdd(aDtInc, DToS(ST9->T9_DTCOMPR))
EndIf

dbSelectArea("STP")
dbSetOrder(08)
If dbSeek(cFil + cCodBem + "I")
	aAdd(aDtInc, DToS(STP->TP_DTLEITU))
EndIf

RestArea(aArea)

Return aDtInc
