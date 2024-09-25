#INCLUDE "MNTA745.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA745
Apropriacao de Debito da Multa

@sample MNTA745()
@version P12

@author Guilherme Freudenburg
@since  07/11/2018

@return Sempre verdadeiro.
/*/
//---------------------------------------------------------------------
Function MNTA745()

	Local aNGBEGINPRM := NGBEGINPRM() // Armazena as variáveis
	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("TSI") // Alias da tabela utilizada
	oBrowse:SetMenuDef("MNTA745") // Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription(STR0006) // "Cadastro de Apropriação de Débito da Multa"
	oBrowse:Activate()

	NGRETURNPRM(aNGBEGINPRM) // Devolve as variáveis armazenadas

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Opções de menu padrão.

@author Guilherme Freudenburg
@since 07/11/2018
@version P12
@return aRotina - Estrutura
	[n,1] Nome a aparecer no cabecalho
	[n,2] Nome da Rotina associada
	[n,3] Reservado
	[n,4] Tipo de Transação a ser efetuada:
		1 - Pesquisa e Posiciona em um Banco de Dados
		2 - Simplesmente Mostra os Campos
		3 - Inclui registros no Bancos de Dados
		4 - Altera o registro corrente
		5 - Remove o registro corrente do Banco de Dados
		6 - Alteração sem inclusão de registros
		7 - Cópia
		8 - Imprimir
	[n,5] Nivel de acesso
	[n,6] Habilita Menu Funcional
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina Title STR0001 Action "AxPesqui"        OPERATION 1 ACCESS 0 // "Pesquisar"
	ADD OPTION aRotina Title STR0002 Action "VIEWDEF.MNTA745" OPERATION 2 ACCESS 0 // "Visualizar"
	ADD OPTION aRotina Title STR0003 Action "VIEWDEF.MNTA745" OPERATION 3 ACCESS 0 // "Incluir"
	ADD OPTION aRotina Title STR0004 Action "MNTA745PE"       OPERATION 4 ACCESS 0 // "Alterar"
	ADD OPTION aRotina Title STR0005 Action "MNTA745PE"       OPERATION 5 ACCESS 0 // "Excluir"
	ADD OPTION aRotina Title STR0007 Action "MNTR745RE"       OPERATION 5 ACCESS 0 // "Relatório"

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Regras de Modelagem da gravacao

@author Guilherme Freudenburg
@since 07/11/2018
@version P12

@return oModel, Objeto, Modelo de dados (MVC)
/*/
//---------------------------------------------------------------------
Static Function ModelDef()
	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStructTSI := FWFormStruct( 1, 'TSI', /*bAvalCampo*/,/*lViewUsado*/ )
	Local oModel

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("MNTA745", /*bPreValid*/, /*bPosValid*/, { | oModel | fCommit(oModel) }/*bFormCommit*/, /*bFormCancel*/)

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields('MNTA745_TSI', /*cOwner*/, oStructTSI, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/)

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription(STR0006) // "Cadastro de Apropriação de Débito da Multa"

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel('MNTA745_TSI'):SetDescription(STR0006) // "Cadastro de Apropriação de Débito da Multa"

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da View (padrão MVC).

@author Guilherme Freudenburg
@since 07/11/2018
@version P12

@return oView,  Objeto, Objeto da View MVC
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
	Local oModel := FWLoadModel("MNTA745")

	// Cria a estrutura a ser usada na View
	Local oStruTSI := FWFormStruct(2, "TSI", /*bAvalCampo*/, /*lViewUsado*/)

	// Interface de visualização construída
	Local oView

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado na View
	oView:SetModel(oModel)

	// Adiciona no View um controle do tipo formulário (antiga Enchoice)
	oView:AddField("VIEW_TSI"/*cFormModelID*/, oStruTSI/*oViewStruct*/, "MNTA745_TSI")

	// Cria os componentes "box" horizontais para receberem elementos da View
	oView:CreateHorizontalBox("BOX_TSI"/*cID*/, 100)

	// Relaciona o identificador (ID) da View com o "box" para exibição
	oView:SetOwnerView("VIEW_TSI"/*cFormModelID*/, "BOX_TSI")

	//Inclusão de itens nas Ações Relacionadas de acordo com O NGRightClick
	NGMVCUserBtn(oView)

Return oView

//---------------------------------------------------------------------
/*/{Protheus.doc} fCommit
Grava na TRX o Numero do APD

@author Guilherme Freudenburg
@since 07/11/2018
@version P12

@return Sempre Verdadeiro.
/*/
//---------------------------------------------------------------------
Static Function fCommit(oModel)

	Local aOldArea   := GetArea()
	Local cCodMulta  := oModel:GetValue("MNTA745_TSI","TSI_MULTA")
	Local nOperation := oModel:GetOperation()

	If nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_INSERT
		dbSelectArea("TRX")
		dbSetOrder(01)
		If dbSeek(xFilial("TRX")+cCodMulta)
			RecLock("TRX",.F.)
			TRX->TRX_NUMAPD := oModel:GetValue("MNTA745_TSI","TSI_NUMAPD")
			TRX->(MsUnlock())
		Endif
	Endif

	FWFormCommit(oModel) // Gravação do Modelo de Dados

	RestArea(aOldArea) // Retorna área posicionada.

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA745PE
Funcao que chama o ponto de entrada para executar a montage da tela nas
opções de exclusão ou alteração.

@author Guilherme Freudenburg
@since 07/11/2018
/*/
//---------------------------------------------------------------------
Function MNTA745PE(cAlias,nReg,nOpcX)

   Local lRet := .T.

	If ExistBlock("MNTA7451")
		lRet := ExecBlock("MNTA7451",.F.,.F.)
	EndIf

	If lRet
		FWExecView(STR0006/*cTitulo*/, "MNTA745"/*cPrograma*/, nOpcX/*nOperation*/, /*oDlg*/,;
						{|| .T. }/*bCloseOnOk*/, /*bOk*/, /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/)
	Endif

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTR745RE
Relatório de APD de débito de multas.

@author Guilherme Freudenburg
@since 07/11/2018
/*/
//---------------------------------------------------------------------
Function MNTR745RE()

	Local aArea 	   := GetArea()
	Local cTRX_DESOBS  := ''
	Local cTRX_OBSCOND := ''
	Local nI, nX, nValMulta, nLetra
	Local cPesq, cText, cVal, cApd, cValApd
	Local lBox := .F., lPrim := .T.

	Private Titulo   := STR0008 //"Relatório de Apropriação de Débito da Multa"
	Private oPrint

	//Ponto de entrada para customização do relatório de APD
	If ExistBlock("MNTA7452")
		Return ExecBlock("MNTA7452",.F.,.F.)
	EndIf

	oPrint   := TMSPrinter():New( OemToAnsi( Titulo ) )

	oPrint:SetPortrait() //Default Retrato
	oFonte	:= TFont():New("ARIAL",15,15,,.F.,,,,.F.,.F.)
	oFont10	:= TFont():New("ARIAL",10,10,,.F.,,,,.F.,.F.)
	oFont14	:= TFont():New("ARIAL",14,14,,.T.,,,,.F.,.F.)
	oFont15	:= TFont():New("ARIAL",15,15,,.T.,,,,.F.,.F.)

	nLinBox := 0
	nLinFim	:= 70
	nColFim := 2350
	oPrint:StartPage() // Inicializa página de impressão.

	oPrint:Say( nLinFim, 025 , STR0011		   										  , oFont15 ) //"Número da multa:"
	oPrint:Say( nLinFim, 490 , Transform( AllTrim( TSI->TSI_MULTA ), "@R! 999/99/99" ), oFonte  )
	oPrint:Say( nLinFim, 1600, STR0012		   										  , oFont15 ) //"Número do APD:"
	oPrint:Say( nLinFim, 2050, AllTrim( TSI->TSI_NUMAPD ) 							  , oFonte	)

	//"Informações do Motorista"
	/*------------------------------------------------------*/
	//dependendo das informações cadastradas na multa, se for realizada a geração automática de APD pode ser que o campo fique vazio.
	nLinFim += 100
	oPrint:Say( nLinFim, 927, STR0013, oFont15 ) //"Informações do Motorista"
	nLinFim += 60
	oPrint:Line(nLinFim, 025, nLinFim, nColFim )
	nLinFim += 10
	dbSelectArea( "DA4" )
	dbSetOrder( 01 ) //DA4_FILIAL+DA4_COD
	dbSeek( xFilial( "DA4" )+TSI->TSI_CODMOT )
	dbSelectArea( "SRA" )
	dbSetOrder( 01 ) //RA_FILIAL+RA_MAT
	dbSeek( xFilial( "SRA" )+DA4->DA4_MAT )
	oPrint:Say( nLinFim, 035, STR0014+AllTrim( TSI->TSI_CODMOT )+" - "+Capital( NGSEEK( "DA4", TSI->TSI_CODMOT, 1, "DA4_NOME" )), oFont10 ) //"Motorista: "
	nLinFim += 45
	If !Empty( SRA->RA_CC )
		oPrint:Say( nLinFim, 035, STR0015+AllTrim( SRA->RA_CC )+" - "+Capital( NGSEEK( "CTT", SRA->RA_CC, 1, "CTT_DESC01" )), oFont10 ) //"Centro de custo: "
		nLinFim += 45
	EndIf
	If !Empty( SRA->RA_CARGO )
		cPesq   := " "
		cText   := Capital( NGSEEK( "SQ3", SRA->RA_CARGO, 1, "SubStr(Q3_DESCSUM,1,40)" ))
		nLetra	:= AT( cPesq, cText )
		If nLetra == 0
			cValApd	:= Capital( NGSEEK( "SQ3", SRA->RA_CARGO, 1, "SubStr(Q3_DESCSUM,1,40)" ))
		Else
			cVal	:= SubStr( AllTrim( Capital( NGSEEK( "SQ3", SRA->RA_CARGO, 1, "SubStr(Q3_DESCSUM,1,40)" ))), 1, nLetra )
			cApd	:= Lower( SubStr( AllTrim( NGSEEK( "SQ3", SRA->RA_CARGO, 1, "SubStr(Q3_DESCSUM,1,40)" )), nLetra, 150 ) )
			cValApd := cVal + cApd
		EndIf
		oPrint:Say( nLinFim, 035, STR0016+AllTrim( SQ3->Q3_CARGO )+" - "+cValApd, oFont10 ) //"Cargo: "
		nLinFim += 45
	EndIf
	dbSelectArea( "SM0" )
	SM0->( dbSetOrder( 01 ))
	If !Empty( DA4->DA4_FILBAS )
		oPrint:Say( nLinFim, 035, STR0017+AllTrim( DA4->DA4_FILBAS )+" - "+AllTrim( SM0->M0_FILIAL ), oFont10 ) //"Filial: "
		nLinFim += 45
	EndIf

	oPrint:Box( 170, 025, nLinFim, nColFim )
	/*------------------------------------------------------*/

	//"Informações Sobre Valores"
	/*------------------------------------------------------*/
	nLinFim += 45
	oPrint:Box( nLinFim, 025, nLinFim+165, nColFim ) //Monta Box.
	nLinFim += 10
	oPrint:Say( nLinFim, 911, STR0018, oFont15 ) //"Informações Sobre Valores"
	nLinFim += 60
	oPrint:Line( nLinFim, 025, nLinFim, nColFim )
	nLinFim += 10
	nValMulta := Transform( Val( Str( TSI->TSI_VALAPD )), "@E 999,999,999.99" )
	oPrint:Say( nLinFim, 035, STR0019+MV_SIMB1+AllTrim( nValMulta ), oFont10 ) //"Valor: "
	nLinFim += 45
	cPesq   := " "
	cText   :=  Alltrim( Extenso( TSI->TSI_VALAPD, .F., 1 ) )
	nLetra	:= AT( cPesq, cText )
	cVal	:= Capital( SubStr( AllTrim( Extenso( TSI->TSI_VALAPD, .F., 1 )), 1, nLetra ) )
	cApd	:= Lower( SubStr( AllTrim( Extenso( TSI->TSI_VALAPD, .F., 1 )), nLetra, 150 ) )
	cValApd := cVal + cApd
	oPrint:Say( nLinFim, 035, STR0020+cValApd, oFont10 ) //"Por extenso: "
	nLinFim += 45
	/*------------------------------------------------------*/

	//"Descrições dos Fatos"
	/*------------------------------------------------------*/
	nLinFim += 45
	nLinBox := nLinFim
	oPrint:Say( nLinFim ,1005, STR0021, oFont15 ) // Descrição dos Fatos
	nLinFim += 60
	oPrint:Line( nLinFim, 025, nLinFim, nColFim )
	dbSelectArea( "TRX" )
	dbSetOrder( 01 )
	dbSeek( xFilial( "TRX" )+TSI->TSI_MULTA )
	oPrint:Say( nLinFim, 035, STR0022+Dtoc( TRX->TRX_DTINFR ), oFont10 ) //"Data da infração: "
	nLinFim += 45
	oPrint:Say( nLinFim, 035, STR0023+TRX->TRX_RHINFR, oFont10 ) //"Hora da infração: "
	nLinFim += 45
	cPesq   := " "
	cText   := NGSEEK( "TSH", TRX->TRX_CODINF, 1, "TSH_DESART" )
	nLetra	:= AT( cPesq, cText )
	cVal	:= Capital( SubStr( AllTrim( NGSEEK( "TSH", TRX->TRX_CODINF, 1, "TSH_DESART" )), 1, nLetra ) )
	cApd	:= Lower( SubStr( AllTrim( NGSEEK( "TSH", TRX->TRX_CODINF, 1, "TSH_DESART" )), nLetra, 150 ) )
	cValApd := cVal + cApd
	oPrint:Say( nLinFim, 035, STR0024+AllTrim( TRX_CODINF )+" - "+cValApd, oFont10 ) //"Infração: "
	nLinFim += 45
	cPesq   := " "
	cText   := Capital( AllTrim( SubStr( TRX->TRX_LOCAL, 1, 40 )))
	nLetra	:= AT( cPesq, cText )
	cVal	:= Capital( SubStr( AllTrim( TRX->TRX_LOCAL ), 1, nLetra ) )
	cApd	:= Lower( SubStr( AllTrim( TRX->TRX_LOCAL ), nLetra, 40 ) )
	cValApd := cVal + cApd
	If !Empty( TRX->TRX_RODOVI ) .And. !Empty( TRX->TRX_CIDINF )
		oPrint:Say( nLinFim, 035, STR0025 + AllTrim( TRX->TRX_RODOVI ) + ", " + cValApd + ", " + Capital( AllTrim( TRX->TRX_CIDINF ))+", " + AllTrim( TRX->TRX_UFINF ), oFont10 )
		nLinFim += 45
	ElseIf !Empty( TRX->TRX_RODOVI ) .And. Empty( TRX->TRX_CIDINF )
		oPrint:Say( nLinFim, 035, STR0025 + AllTrim( TRX->TRX_RODOVI ) + ", " + cValApd + ", "+AllTrim( TRX->TRX_UFINF ), oFont10 )
		nLinFim += 45
	ElseIf Empty( TRX->TRX_RODOVI ) .And. !Empty( TRX->TRX_CIDINF )
		oPrint:Say( nLinFim, 035, STR0025 + cValApd + ", " + Capital( AllTrim( TRX->TRX_CIDINF )) + ", "+AllTrim( TRX->TRX_UFINF ), oFont10 )
		nLinFim += 45
	Else
		oPrint:Say( nLinFim, 035, STR0025 + cValApd + ", "+AllTrim( TRX->TRX_UFINF ), oFont10 )
		nLinFim += 45
	EndIf
	oPrint:Say( nLinFim, 035, STR0026+TRX->TRX_PLACA ,oFont10 ) //"Placa do veículo: "
	nLinFim += 45

	//"Observações da multa: "
   	cTRX_DESOBS := NGMEMOSYP( TRX->TRX_MMSYP ) //Busca memo da tabela TRX.
   	If !Empty( cTRX_DESOBS ) //Se estiver preenchido o campo TRX_OBS
   		oPrint:Say( nLinFim, 035, STR0027, oFont10 ) //"Observações da multa: "
		nX := MlCount( cTRX_DESOBS, 60 )
		For nI := 1 To nX
			If !Empty( MemoLine( cTRX_DESOBS, 60, nI ))
				cValApd	:= SubStr( AllTrim( MemoLine( cTRX_DESOBS, 60, nI )), 1, 150 )
				oPrint:Say( nLinFim, 420, cValApd, oFont10 ) // Conteúdo observ. de multa.
				nLinFim += 45
			EndIf
			If nLinFim > 3000// Pula linha.
				If lPrim
					oPrint:Box( nLinBox, 025, nLinFim, nColFim ) //Monta Box
					lPrim := .F.
				Else
					oPrint:Box( 025, 025, nLinFim, nColFim ) //Monta Box
				EndIf
				oPrint:EndPage() // Finaliza página de impressão.
				oPrint:StartPage() // Inicializa página de impressão.
				nLinFim := 45
				lBox 	:= .T.
			EndIf
		Next
	Else
		oPrint:Say( nLinFim, 035, STR0027, oFont10 ) //"Observações da multa: "
		nLinFim += 45
	EndIf

	//"Observações da APD: "
	cPesq   := " "
	cText   := Capital( TSI->TSI_DESOBS )
	nLetra	:= AT( cPesq, cText )
	If nLetra == 0
		cValApd	:= AllTrim( Capital( TSI->TSI_DESOBS ))
	Else
		cVal	:= SubStr( AllTrim( Capital( TSI->TSI_DESOBS )), 1, nLetra )
		cApd	:= Lower( SubStr( AllTrim( TSI->TSI_DESOBS ), nLetra, 150 ) )
		cValApd := cVal + cApd
	EndIf
	oPrint:Say( nLinFim, 035, STR0028+cValApd, oFont10 )
	nLinFim += 45

   	//"Observações do condutor:
   	cTRX_OBSCOND := NGMEMOSYP( TRX->TRX_MMCOND ) //Busca memo da tabela TRX.
   	If !Empty( cTRX_OBSCOND ) //Se estiver preenchido o campo TRX_OBCOND
		oPrint:Say( nLinFim, 035, STR0029 ,oFont10 ) //"Observações do condutor: "
		nX := MlCount( cTRX_OBSCOND, 60 )
		For nI := 1 To nX
			If !Empty( MemoLine( cTRX_OBSCOND, 60, nI ))
				cValApd	:= SubStr( AllTrim( MemoLine( cTRX_OBSCOND, 60, nI )), 1, 150 )
				oPrint:Say( nLinFim, 470, cValApd, oFont10 ) // Conteúdo observ. de multa.
				nLinFim += 45
			EndIf
			If nLinFim > 3000// Pula linha.
				If lPrim
					oPrint:Box( nLinBox, 025, nLinFim, nColFim ) //Monta Box
					lPrim := .F.
				Else
					oPrint:Box( 025, 025, nLinFim, nColFim ) //Monta Box
				EndIf
				oPrint:EndPage() // Finaliza página de impressão.
				oPrint:StartPage() // Inicializa página de impressão.
				nLinFim := 45
				lBox 	:= .T.
			EndIf
		Next
	Else
		oPrint:Say( nLinFim, 035, STR0029, oFont10 ) //"Observações do condutor: "
		nLinFim += 45
	EndIf

	If lBox
		oPrint:Box( 025, 025, nLinFim, nColFim ) //Monta Box
	Else
		oPrint:Box( nLinBox, 025, nLinFim, nColFim ) //Monta Box
	EndIf
	/*------------------------------------------------------*/

	If nLinFim > 2350// Pula linha.
		oPrint:EndPage()// Finaliza página de impressão.
		oPrint:StartPage()// Inicializa página de impressão.
		nLinFim := 0
	EndIf

	//"Parecer do Responsável"
	/*------------------------------------------------------*/
	nLinFim += 45
	oPrint:Box(  nLinFim, 025, nLinFim+760, nColFim ) // Monta Box
	nLinFim += 10
	oPrint:Say( nLinFim, 954, STR0030,	oFont15 ) // "Parecer do Responsável"
	nLinFim += 60
	oPrint:Line( nLinFim, 025, nLinFim , nColFim )
	oPrint:Say( nLinFim , 035, STR0031 , oFont10 ) //"Responsabilidade: "
	If TRX->TRX_REPON == "1"
		oPrint:Say( nLinFim , 335, STR0051, oFont10 ) // "Motorista"
	ElseIf TRX->TRX_REPON == "2"
		oPrint:Say( nLinFim , 335, STR0052, oFont10 ) // "Empresa"
	ElseIf TRX->TRX_REPON == "3"
		oPrint:Say( nLinFim , 335, STR0053, oFont10 ) // "Pessoa Física"
	ElseIf TRX->TRX_REPON == "4"
		oPrint:Say( nLinFim , 335, STR0054, oFont10 ) // "Pessoa Jurídica e Física"
	ElseIf TRX->TRX_REPON == "5"
		oPrint:Say( nLinFim , 335, STR0055, oFont10 ) // "Seguradora"
	ElseIf TRX->TRX_REPON == "6
		oPrint:Say( nLinFim , 335, STR0056, oFont10 ) // "Transportador"
	ElseIf TRX->TRX_REPON == "7"
		oPrint:Say( nLinFim , 335, STR0057, oFont10 ) // "Expedidor"
	EndIf
	nLinFim += 45
	oPrint:Say( nLinFim   , 035    , STR0032   , oFont10 ) //"- Concorda com os fatos da forma em que foram narrados ? "
	oPrint:Box( nLinFim+10, 1950   , nLinFim+30, 1950+20 )
	oPrint:Say( nLinFim	  , 1950+40, STR0038   , oFont10 ) //"Sim"
	oPrint:Box( nLinFim+10, 2100   , nLinFim+30, 2100+20 )
	oPrint:Say( nLinFim	  , 2100+40, STR0039   , oFont10 ) //"Não"
	nLinFim += 45
	oPrint:Say(  nLinFim, 035, STR0033, oFont10 ) //"- Por que : "
	nLinFim += 45
	oPrint:Line( nLinFim, 210, nLinFim, 2350 ) //Linhas
	nLinFim += 45
	oPrint:Line( nLinFim, 210, nLinFim, 2350 ) //Linhas
	nLinFim += 45
	oPrint:Line( nLinFim, 210, nLinFim, 2350 ) //Linhas
	nLinFim += 10
	oPrint:Say( nLinFim   , 035    , STR0034   , oFont10 ) //"- Se concorda, autoriza a cobrança dos valores acima citados ? "
	oPrint:Box( nLinFim+10, 1950   , nLinFim+30, 1950+20 )
	oPrint:Say( nLinFim	  , 1950+40, STR0038   , oFont10 ) //"Sim"
	oPrint:Box( nLinFim+10, 2100   , nLinFim+30, 2100+20 )
	oPrint:Say( nLinFim	  , 2100+40, STR0039   , oFont10 ) //"Não"
	nLinFim += 45
	oPrint:Say( nLinFim   , 035    , STR0035   , oFont10 ) //"- Diante dos fatos e provas acima, você se declara responsável pelo ocorrido ? "
	oPrint:Box( nLinFim+10, 1950   , nLinFim+30, 1950+20 )
	oPrint:Say( nLinFim	  , 1950+40, STR0038   , oFont10 ) //"Sim"
	oPrint:Box( nLinFim+10, 2100   , nLinFim+30, 2100+20 )
	oPrint:Say( nLinFim	  , 2100+40, STR0039   , oFont10 ) //"Não"
	nLinFim += 45
	oPrint:Say(  nLinFim, 035, STR0033 ,oFont10 ) //"- Por que: "
	nLinFim += 45
	oPrint:Line( nLinFim, 210, nLinFim, 2350 	) //Linha
	nLinFim += 45
	oPrint:Line( nLinFim, 210, nLinFim, 2350 	) //Linha
	nLinFim += 45
	oPrint:Line( nLinFim, 210, nLinFim, 2350 	) //Linha
	nLinFim += 10
	oPrint:Say( nLinFim   , 035    , STR0036   , oFont10 ) //"- Há algum procedimento a sugerir ou prova a apresentar ? "
	oPrint:Box( nLinFim+10, 1950   , nLinFim+30, 1950+20 )
	oPrint:Say( nLinFim	  , 1950+40, STR0038   , oFont10 ) //"Sim"
	oPrint:Box( nLinFim+10, 2100   , nLinFim+30, 2100+20 )
	oPrint:Say( nLinFim	  , 2100+40, STR0039   , oFont10 ) //"Não"
	nLinFim += 45
	oPrint:Say(  nLinFim, 035, STR0037, oFont10 ) //"- Descrição: "
	nLinFim += 45
	oPrint:Line( nLinFim, 235, nLinFim, 2350 	) //Linha
	nLinFim += 45
	oPrint:Line( nLinFim, 235, nLinFim, 2350 	) //Linha
	nLinFim += 45
	oPrint:Line( nLinFim, 235, nLinFim, 2350 	) //Linha
	nLinFim += 45
	/*------------------------------------------------------*/

	If nLinFim > 2350// Pula linha.
		oPrint:EndPage()// Finaliza página de impressão.
		oPrint:StartPage()// Inicializa página de impressão.
		nLinFim := 0
	EndIf

	// "Parecer do Gerente"
	/*------------------------------------------------------*/
	nLinFim += 45
	oPrint:Box( nLinFim, 025, nLinFim+160, nColFim ) // Monta Box
	nLinFim += 10
	oPrint:Say( nLinFim, 1004, STR0040, oFont15 )  // "Parecer do Gerente"
	nLinFim += 60
	oPrint:Line( nLinFim, 025, nLinFim, nColFim ) //
	oPrint:Say(  nLinFim, 035, STR0041, oFont10 ) // "Debitar para: "
	nLinFim += 45
	oPrint:Say( nLinFim, 035, STR0042, oFont10 )  // "Forma: "
	oPrint:Say( nLinFim, 1050, STR0043, oFont10 )  // "Parcelamento: "
	/*------------------------------------------------------*/

	If nLinFim > 2350// Pula linha.
		oPrint:EndPage()// Termina página de impressão.
		oPrint:StartPage()// Inicializa página de impressão.
		nLinFim := 0
	EndIf

	// Assinaturas
	/*------------------------------------------------------*/
	nLinFim += 500
	oPrint:Line( nLinFim, 025 , nLinFim, 1100 	 ) // Linha para Assinatura / carimbo do responsável
	oPrint:Line( nLinFim, 1250, nLinFim, nColFim ) // Linha para Assinatura do gerente
	nLinFim += 10
	oPrint:Say( nLinFim, 116 , STR0044, oFont14 )  // "Assinatura / carimbo do responsável"
	oPrint:Say( nLinFim, 1600, STR0045, oFont14 )  // "Assinatura do gerente"
	/*------------------------------------------------------*/

	// "Recusa de Assinatura"
	/*------------------------------------------------------*/
	nLinFim += 230
	oPrint:Box( nLinFim, 025, nLinFim+200, nColFim ) // Monta Box
	nLinFim += 10
	oPrint:Say( nLinFim, 979, STR0046, oFont15 )  // "Recusa de Assinatura"
	nLinFim += 60
	oPrint:Line( nLinFim, 025 , nLinFim, nColFim )
	oPrint:Say(  nLinFim, 035 , STR0047, oFont10 )// "Testemunha 1:"
	oPrint:Say(  nLinFim, 1250, STR0048, oFont10 )// "Testemunha 2:"
	nLinFim += 45
	oPrint:Say( nLinFim, 035 , STR0049, oFont10 ) // "RG:"
	oPrint:Say( nLinFim, 1250, STR0049, oFont10 ) // "RG:"
	nLinFim += 45
	oPrint:Say( nLinFim, 035 , STR0050, oFont10 ) // "CPF:"
	oPrint:Say( nLinFim, 1250, STR0050, oFont10 ) // "CPF:"
	nLinFim -= 45
	oPrint:Line( nLinFim, 280 , nLinFim, 1100 )   // Linha Testemunha 1
	oPrint:Line( nLinFim, 1490, nLinFim, 2300 )   // Linha Testemunha 2
	/*------------------------------------------------------*/

	oPrint:EndPage() // Finaliza página de impressão.
	oPrint:Preview() // Preview do relatório.

	RestArea( aArea ) // Retorna a área de trabalho.

Return
