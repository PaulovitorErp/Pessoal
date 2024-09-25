#Include "MDTA410.ch"
#Include "FWBROWSE.CH"
#Include "PROTHEUS.CH"

/*
MELHORIAS
--------------------------
( ) INCLUIR BOTÃO DE IMPRIMIR NO FOLDER DE EPI
( ) POSSIBILITAR ORDENAR ITENS DO MENU DE FICHA MÉDICA, COMO O MBROWSE
( ) IMPLEMENTAR CID COMPLEMENTAR(TKK), CONFORME MDTA640 (UPDMDT88)
( ) IMPLEMENTAR DESPESAS DE ACIDENTE, CONFORME MDTA640
(X) POSSIBILITAR INCLUIR, ALTERAR E EXCLUIR FICHA MÉDICA INTEGRADO COM BIOMETRIA.
*/

//-------------------------------------
// Posições para controle de restrição
//-------------------------------------
#DEFINE __CODIGO__ 1
#DEFINE __OPCAO__ 2
#DEFINE __HABILITADO__ 3
#DEFINE __ROTINAS__ 4
#DEFINE __TITULO__ 5

//-----------------------------------------
// Define que o FwBalloon será informativo
//-----------------------------------------
#Define FW_BALLOON_INFORMATION	3

//---------------------------------------------------------
// Define o layout do FwBalloon de acordo com sua posição
//---------------------------------------------------------
#Define BALLOON_POS_TOP_MIDDLE     02
#Define BALLOON_POS_TOP_RIGTH      03
#Define BALLOON_POS_LEFT_TOP       07
#Define BALLOON_POS_LEFT_MIDDLE    08

//-------------------------------------
// Sequencia de execução dos FwBalloon
//-------------------------------------
#DEFINE BALLOON_INIT '1'
#DEFINE BALLOON_FOLDER '2'
#DEFINE BALLOON_OPERACOES '3'
#DEFINE BALLOON_FWBROWSE '4'
#DEFINE BALLOON_BACK '5'
#DEFINE BALLOON_PRINT '6'
#DEFINE BALLOON_EPI '7'

//------------------------------------------------
// Define a identificação do botões de aButtonTM0
//------------------------------------------------
#DEFINE TM0_BTN_TAR 1 //Relacionamento de Tarefas
#DEFINE TM0_BTN_BIO 2 //Biometria
#DEFINE TM0_BTN_TQD 3 //Clique da Direita

Static __TM0_FOLDER__ := 01 //Ficha Médica
Static __TMJ_FOLDER__ := 02 //Consultas
Static __TMN_FOLDER__ := 03 //Programa de Saude
Static __TMF_FOLDER__ := 04 //Restricoes
Static __TNA_FOLDER__ := 05 //Doeças
Static __TM5_FOLDER__ := 06 //Exames
Static __TMY_FOLDER__ := 07 //ASO'S
Static __TNY_FOLDER__ := 08 //Atestado
Static __TNC_FOLDER__ := 09 //Acidentes
Static __TMT_FOLDER__ := 10 //Diagnósticos Médicos
Static __TL9_FOLDER__ := 11 //Vacinas
Static __TNF_FOLDER__ := 12 //EPI'S
Static __TMI_FOLDER__ := 13 //Questionário Médico

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA410
Prontuario de Funcionario

Programa que lista informações de:
- Consultas
- Programa de Saúde
- Restrições
- Doenças
- Exames
- ASO's
- Atestados
- EPI's
- Diagnosticos
- Vacinas

@param cFichaAuto Indica o número da ficha médica a ser aberta automaticamente

@param cMedico Indica o Médico posicionado no momento - Variavel alimentada pelo MDTA076

@author Vitor Emanuel Batista
@since 25/11/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Function MDTA410( cFichaAuto, cMedico )

	// Guarda conteudo e declara variaveis padroes
	Local aNGBEGINPRM := NGBEGINPRM( , , , , .T. )

	Local oDlg // Objeto do Dialog principal
	Local nOrd := 0
	Local aOrdem := { "TMJ", "TMN", "TMF", "TNA", "TM5", "TMY", "TNY", "TNC", "TMT", "TL9", "TNF", "TMI" } // Ordem padrao dos folders, pode ser alterada com o ponto de entrada MDTA4102

	Private nOpcPro := 0

	If AMiIn( 35 ) // Somente autorizado para SIGAMDT

		Private cCodUsu := '' // Médico PCMSO escolhido

		// Variaveis para bkp de empresa e filial
		Private cEmpAsoOld := cEmpAnt
		Private cFilAsoOld := cFilAnt

		// Filtro Padrão para Ficha Médica 02
		Private cFilterTM0 := " TM0_FILIAL = '" + xFilial( "TM0" ) + "'"

		// Variaveis de Largura/Altura da Janela
		Private aSize		:= MsAdvSize( Nil, .F. )
		Private nLargura	:= aSize[5]
		Private nAltura410	:= aSize[6]

		// Descritivo do Dialog
		Private cCadastro := STR0001 //"Ficha Médica"

		// Objetos de Browse e Enchoice
		Private oEncFun, oEncImg
		Private oBrwTM0, oEncTM0 //Ficha Médica
		Private oBrwTMJ, oEncTMJ //Consultas
		Private oBrwTMN, oEncTMN //Programa de Saude
		Private oBrwTMF, oEncTMF //Restricoes
		Private oBrwTNA, oEncTNA //Doecas
		Private oBrwTM5, oEncTM5 //Exames
		Private oBrwTMY, oEncTMY //ASO'S
		Private oBrwTNY, oEncTNY //Atestado
		Private oBrwTNC, oEncTNC //Acidentes
		Private oBrwTNF, oEncTNF //EPI'S
		Private oBrwTMT, oEncTMT //Diagnósticos Médicos
		Private oBrwTM2, oEncTM2 //Medicamentos Utilizados
		Private oBrwTMI, oEncTMI //Questionário Médico
		Private oBrwTL9, oEncTL9 //Vacinas

		// Variaveis utilizadas na construção da tela e botôes
		Private aNao
		Private bValid
		Private bSave
		Private bInit
		Private oPnlDown
		Private oPnlTM0 // Objeto Panel que recebera Enchoice Esquerdo

		// Variável de controle do Número da Ficha Médica
		Private _nRecno410 := 0
		Private _cNumFi410 := IIf( Empty( cFichaAuto ), Space( Len( TM0->TM0_NUMFIC ) ), cFichaAuto )
		Private _cMatri410 := Space( Len( TM0->TM0_MAT ) )
		Private _cFil410   := cFilAnt
		Private _aArea410
		Private _cFilter410:= TM0->( dbFilter() )

		// Variável de controle para o Prestador de Serviço
		Private lSigaMdtPS := SuperGetMv( "MV_MDTPS", .F., "N" ) == "S"
		Private cCliMdtPs := Space( Len( SA1->A1_COD+SA1->A1_LOJA ) )

		// Variável de controle do nome do funcionário
		Private oNomeFun1, oNomeFun2

		// Variaveis de controle de Inclusao,alteracao e exclusao
		Private lIncReg := .F.
		Private lAltReg := .F.

		// Indica se utiliza biometria
		Private lBiometria := SuperGetMv( "MV_NG2BIOM", .F., "2" ) == "1"
		Private lPyme      := IIf( Type( "__lPyme" ) <> "U", __lPyme, .F. )
		Private oEncIncAlt 	// Enchoice de Inclusao/Alteracao
		Private oEnchBar 	// EnchoiceBar criado na Inclusao/Alteracao

		Private oPnlRight 	// Panel com os objetos da direita
		Private oBlackPnl	// Objeto Panel escuro com transparencia
		Private oFolder410	// Objeto folder do Panel da direita
		Private oFolderTMT	// Objeto folder específico do Diagnostico
		Private oFolderTNY	// Objeto folder específico do Afastamento
		Private oBalloon	// Objeto para o FwBalloon com informativos

		// Botões utilizados antes de escolher a Ficha Medica
		Private oBtnLgd
		Private oBtnFilt
		Private oBtnQuit
		Private oBtnConh
		Private oBtnSavFic
		Private oBtnCanFic
		Private oBtnIncFic
		Private oBtnAltFic
		Private oBtnExcFic
		Private aButtonTM0 := fButtonTM0()

		Private oPnlLeft As Object
		Private oPnlShow As Object

		VariableTM0()	// VariableTM0 - Cria variavel de aButtonTM0

		// Cor utilizada para os Panel de divisao
		Private aColors := NGCOLOR()//{67,70,87} //NGHEXRGB("83AAE2") // NGHEXRGB("C3DBF9") //
		Private aTROCAF3 := {}		// Variável para controle de consulta F3

		SetAltera()	// Seta variaveis de INCLUI e ALTERA

		// Variaveis utilizadas por VALID/RELACAO/WHEN
		Private nSizeSI3  := IIf( ( TAMSX3( "I3_CUSTO" )[1] ) < 1, 9, ( TAMSX3( "I3_CUSTO" )[1] ) )  //Usado no X3_RELACAO do TNC_CC
		Private lENumFic  := .F. //Usado no X3_WHEN do TMN_NUMFIC
		Private lECODUSU  := .T. //Variável de controle WHEN da TMY
		Private lEDTCANC  := .F. //Variável de controle WHEN da TMY
		Private lEDTEMIS  := .T. //Variável de controle WHEN da TMY - Abertura do campo para atender ao eSocial (ASO's de terceiros)
		Private lEDTPROG  := .T. //Variável de controle WHEN da TMY
		Private lEEXAME   := .T. //Variável de controle WHEN da TMY
		Private lWhenEpi  := .F. //Variável de controle WHEN da TNF
		Private TMTNUMFIC := .F. //DESABILITA CAMPO TMT_NUMFIC DO TMT
		Private TMTDTCONS := .T. //HABILITA CAMPO TMT_DTCONS DO TMT
		Private TMTHRCONS := .T. //HABILITA CAMPO TMT_HRCONS DO TMT
		Private TMTCODUSU := .T. //HABILITA CAMPO TMT_CODUSU DO TMT
		Private lENTRADA  := .F. //Variavel de controle WHEN da TM2
		Private lALTMEDIC := .T. //Variavel de controle WHEN da TM2
		Private lWh695TNF := .T. //Variavel que controla o X3_WHEN dos campos da TNF
		Private lWh695IND := .T. //Variavel que controla o X3_WHEN do campo TNF_INDDEV
		Private lWh695LOT := .T. //Variavel que controla o X3_WHEN do campo Lote SubLote
		Private lWh695OBS := .T. //Variavel que controla o X3_WHEN do campo Observação
		Private lMDT685Con := .F.//Variavel que indica se é continuação de atestado
		Private lFicha	   := .T.
		Private lContinu   := .F.
		Private cRetF3	   := ""

		//----------------------------------------------------------
		// Verifica qual tipo de produto é o tipo EPI e atualiza
		// a consulta padrao de EPI's de acordo com isso
		//----------------------------------------------------------
		Private cTipo := SuperGetMv( "MV_MDTPEPI", .F., "" )
		Private lSX5  := !Empty( cTipo )  //Variavel utilizadas na validacao do campo TNX_EPI

		// Variaveis utilizadas por
		Private lTabTLW   := NGCADICBASE( "TLW_MAT", "D", "TLW", .F. )
		Private lCpDtDev  := NGCADICBASE( "TNF_DTDEVO", "D", "TNF", .F. )
		Private lLoteTNF  := NGCADICBASE( "TNF_LOTECT", "D", "TNF", .F. ) .And. NGCADICBASE( "TNF_LOTESB", "D", "TNF", .F. ) .And.;
			NGCADICBASE( "TNF_ENDLOC", "D", "TNF", .F. ) .And. NGCADICBASE( "TNF_NSERIE", "D", "TNF", .F. )

		// Variaveis utilizadas para integrações
		Private lHist695   := .F.
		Private cUsaInt1   := AllTrim( GetMv( "MV_NGMDTES" ) )
		Private cUsaLocz   := AllTrim( GetMv( "MV_LOCALIZ" ) )
		Private cUsaRast   := AllTrim( GetMv( "MV_RASTRO" ) )
		Private lESTNEGA   := AllTrim( GETMV( "MV_ESTNEG" ) ) == 'S'
		Private lCpoNumSep := TNF->( FieldPos( "TNF_NUMSEQ" ) ) > 0 .And. lCpDtDev
		Private cMdtDurab  := SuperGetMv( "MV_NG2EPDU", .F., "0" ) //Indica se verifica se o Epi deve ser trocado
		Private lMdtGerSA  := SuperGetMv( "MV_NG2SA", .F., "N" ) == "S" //Indica se gera SA ao inves de requisitar do estoque
		Private lGera_SA   := NGCADICBASE( "TNF_ITEMSA", "D", "TNF", .F. ) .And. NGCADICBASE( "TNF_NUMSA", "D", "TNF", .F. )
		Private lMedicSx6  := Alltrim( Getmv( "MV_NG2ESTN" ) ) == "N"

		// Variaveis utilizadas pelo folder Ficha Medica
		Private aTarefaTKD := {}
		Private aHeadTar
		Private cAliasTrf
		Private lFirstTKD  := .T.

		// Variaveis utilizadas pelo folder Atestado
		Private aColsCID := {}
		Private aOldRF0  := {}

		// Variaveis utilizadas pelo folder EPI
		Private cAliasTLW
		Private cArquivTLW
		Private oGetTNF695
		Private oTempTLW

		Private aCols := {}
		Private aHeader := {}
		Private aChvTNF := {}
		Private n := 1

		Private aCOLSTNF := {}
		Private aHeaTNF  := {}
		Private aColsTLW := {} //Dados temporarios da TLW
		Private aHeadTLW := {} //Cabeçalho da TLW
		Private aOld_TLW := {} //Dados salvos da TLW
		Private aPerAtual:= {}

		Private aOldACols := {}
		Private dDtMin := dDataBase
		Private dDtMax := dDataBase

		Private l695Auto := .F.
		Private l695ExibeMsg := .F.//Controla a verificação da apresentação da Mensagem do Controle de Estoque (MDTMOVEST - MDTUTIL)
		Private lMSErroAuto := .F.


		// Variaveis utilizadas pelo folder Questionário
		Private nFatMlt
		Private nContPG
		Private cCombo		:= ""
		Private aObjects 	:= {}
		Private aPosObj, aInfo
		Private oFont12  	:= TFont():New( "Arial", , -12, .T., .T. )
		Private nLinObj 	:= 0
		Private nLastPanel 	:= 1 //Indica última página de perguntas apresentada
		Private aCadTipo 	:= {}
		Private oIndNG		:= {}
		Private oBtnFirst
		Private oBtnNext
		Private oBtnPrevi
		Private oBtnLast
		Private oCombo
		Private oPanelTmp
		Private aQuesSelc	:= {}

		// Variaveis utilizadas pelo folder Atestado (ASO)
		Private cFilAtu		:= ""
		Private cEmpFiltro	:= ""
		Private cMdtGenFun	:= "MDT200SXB()"
		Private cMdtGenRet	:= "MDT200RSXB()"
		Private cMarca	    := GetMark()
		Private lInvert     := .F.
		Private aExameBack  := {}
		Private aDadAsoPon	:= {} // Dados do aso do prontuário médico antes da alteração

		// Variaveis utilizadas pelo folder Diagnóstico
		Private aCampos	:= { { "TMT_QUEIXA", "TMT_QUESYP", "TMT_MQUEIX"	},;
			{ "TMT_DESATE", "TMT_DATSYP", "TMT_MDESAT"	},;
			{ "TMT_DIAGNO", "TMT_DIASYP", "TMT_MDIAGN"	},;
			{ "TMT_HDA", "TMT_HDASYP", "TMT_MHDA"		},;
			{ "TMT_HISPRE", "TMT_HISSYP", "TMT_MHISPR"	},;
			{ "TMT_CABECA", "TMT_CABSYP", "TMT_MCABEC"	},;
			{ "TMT_OLHOS", "TMT_OLHSYP", "TMT_MOLHOS"	},;
			{ "TMT_OUVIDO", "TMT_OUVSYP", "TMT_MOUVID"	},;
			{ "TMT_PESCOC", "TMT_PESSYP", "TMT_MPESCO"	},;
			{ "TMT_APRESP", "TMT_APRSYP", "TMT_MAPRES"	},;
			{ "TMT_APDIGE", "TMT_APDSYP", "TMT_MAPDIG"	},;
			{ "TMT_APCIRC", "TMT_APCSYP", "TMT_MAPCIR"	},;
			{ "TMT_APURIN", "TMT_APUSYP", "TMT_MAPURI"	},;
			{ "TMT_MMIISS", "TMT_MISSYP", "TMT_MMIS"	},;
			{ "TMT_PELE", "TMT_PELSYP", "TMT_MPELE"	},;
			{ "TMT_EXAMEF", "TMT_EXFSYP", "TMT_MEXAME"	},;
			{ "TMT_OROFAR", "TMT_ORFSYP", "TMT_MOROFA"	},;
			{ "TMT_OTOSCO", "TMT_OTSSYP", "TMT_MOTOSC"	},;
			{ "TMT_ABDOME", "TMT_ABDSYP", "TMT_MABDOM"	},;
			{ "TMT_AUSCAR", "TMT_AUCSYP", "TMT_MAUSCA"	},;
			{ "TMT_AUSPUL", "TMT_AUPSYP", "TMT_MAUSPU"	} }

		aAdd( aObjects, { 200, 200, .T., .F. } )
		aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0 }
		aPosObj := MsObjSize( aInfo, aObjects, .T. )
		If aSize[6] > 900
			aPosObj[1, 3] := aPosObj[1, 3] * ( aSize[6] / 560 )
		ElseIf aSize[6] > 650
			aPosObj[1, 3] := aPosObj[1, 3] * ( aSize[6] / 590 )
		Else
			aPosObj[1, 3] := aPosObj[1, 3] * ( aSize[6] / 610 )
		EndIf

		nFatMlt := 1.95
		If aPosObj[1, 4] <= 410
			nFatMlt := 1.9
		ElseIf aPosObj[1, 4] <= 550
			nFatMlt := 1.93
		EndIf

		// Controle interno do MDTA410 para aCols e aHeader da TNF
		Private aOldTNFCols := {}
		Private aOldTNFHead := {}

		Pergunte( "MDT695", .F. )

		Private nEPIDev   := MV_PAR01
		Private dDtEntEpi := MV_PAR02
		
		If ValType( nEPIDev ) <> "N"
			nEPIDev := 1
		EndIf

		Private lCodFun  := .F.
		Private c1CodFun := "RA_CODFUNC"
		Private c2CodFun := "TNF_CODFUN"
		Private c3CodFun := "TNB_CODFUN"
		Private c1NomFun := "RJ_DESC"
		Private cTab_Fun := "SRJ"
		Private nIndTNB  := 1

		Private cMARCA    := GetMark()
		Private cIndRelac := " "
		Private lPrimeiro := .F.

		Private nIndTNF, cSeekTNF, cCondTNF, nInd2TNF
		Private nINDDEV, aDevEpi := {}

		Private nOpcVenc := 3 //1-Entrega EPI Vencido / 2-Não entrega EPI Vencido / 3-Pergunta se entrega EPI Vencido

		Private lForPad := .F., cForPad := ""

		//Variaveis para devolução de EPI.
		Private aDevPar		:= {}

		Private cMVForPd := AllTrim( GetNewPar( "MV_NGFORPD", " " ) )
		If !Empty( cMVForPd )
			dbSelectArea( "SA2" )
			dbSetOrder( 1 )
			If dbSeek( xFilial( "SA2" )+SubStr( GetMv( "MV_NGFORPD" ), 1, TAMSX3( "A2_COD" )[1] )+SubStr( Getmv( "MV_NGFORPD" ),;
					TAMSX3( "A2_COD" )[1]+1, ( TAMSX3( "A2_COD" )[1]+TAMSX3( "A2_LOJA" )[1] ) ) )
				lForPad := .T.
				cForPad := GetMv( "MV_NGFORPD" )
			EndIf
		EndIf

		Private lConfExc := AllTrim( GetNewPar( "MV_MDTEPID", "N" ) ) == "S"

		If cUsaInt1 != "S" .Or. !lMdtGerSA
			lGera_SA := .F.
		EndIf

		If !lLoteTNF .Or. (cUsaInt1 != "S" .Or. cUsaLocz != "S" .And. cUsaRast != "S")
			lLoteTNF := .F.
			cUsaLocz := "N"
			cUsaRast := "N"
		EndIf

		// Variaveis utilizadas pelo folder Diagnóstico Médico
		Private cCID  := Space( Len( TMT->TMT_CID ) )
		Private cCID2 := Space( Len( TMT->TMT_CID2 ) )

		// Variaveis utilizadas pelo folder de Atestado ASO
		Private cRelExam   := SuperGetMv( "MV_NGEXREL", .F., "1" ) //Indica o padrao para o filtro de exames relacionados.
		Private lUpdExec   := .T.
		Private lImpAso := .T.

		// Variaveis utilizadas pelo folder de Atestado Médico
		Private nDiasEx    	:= GetNewPar( "MV_NG2D685", 0 ) // numero minimo de dias para gerar um exame de (NR7).
		Private lCpoCid    	:= NGCADICBASE( "R8_CID", "A", "SR8", .F. )
		Private lCpoRais   	:= NGCADICBASE( "TNY_AFRAIS", "A", "TNY", .F. ) .And. NGCADICBASE( "R8_AFARAIS", "A", "SR8", .F. )
		Private lCpoDura   	:= NGCADICBASE( "R8_DURACAO", "A", "SR8", .F. ) .And. NGCADICBASE( "R8_DPAGAR", "A", "SR8", .F. ) .And. NGCADICBASE( "R8_DIASEMP", "A", "SR8", .F. )
		Private lAtesAnt   	:= NGCADICBASE( "TNY_ATEANT", "A", "TNY", .F. )
		Private nIndSR8    	:= f685RetOrder( "SR8", "R8_FILIAL+R8_NATEST" )
		Private lCpoSr8    	:= .F.
		Private lCpoIndSr8 	:= .F.
		Private lCpoPonto  	:= AliasInDic( "RF0" )
		Private lInt_AfaGpe := SuperGetMv( "MV_NGMDTAF", .F., "N" ) == "S"
		Private nDiasFecha  := 0
		Private lInt_PonGpe := IIf( FindFunction( "MDT685VPON" ), MDT685VPON( lInt_AfaGpe, @nDiasFecha ), IIf( lInt_AfaGpe, .T., .F. ) )
		Private aOldTNY    	:= {}
		Private lExe_Ponto 	:= .T.
		Private lPriCont  	:= .F.
		Private cAliasQue 	:= GetNextAlias() // Variaveis utilizadas pelo folder de Questionário Médico

		If SR8->( FieldPos( "R8_NATEST" ) ) > 0
			lCpoSr8 := .T.
			If nIndSR8 > 0
				lCpoIndSr8 := .T.
			EndIf
		EndIf

		// Array contendo estrutura da restrição (Codigo,Numero do Folder,Habilitado)
		Private aRestricao := {}
		aAdd( aRestricao, { __TM0_FOLDER__, 1, .T., {}, STR0001 } ) //"Ficha Médica" deve ser o primeiro folder independente do ponto de entrada

		If ExistBlock( "MDTA4102" ) // Ponto de entrada para alterar a ordem dos folders no Prontuario
			aRet := ExecBlock( "MDTA4102", .F., .F. )

			If ValType( aRet ) == "A" .And. Len( aRet ) > 0
				aOrdem := aRet
			EndIf

		EndIf

		For nOrd := 1 To Len( aOrdem ) // Cria o array com os folders na ordem padrão ou na passada pelo ponto de entrada MDTA4102

			Do Case
			Case aOrdem[nOrd] == "TMJ"

				If !IsInCallStack( "MDTA076" )
					aAdd( aRestricao, { __TMJ_FOLDER__, 0, .F., { "MDTA075" }, STR0002 } ) //"Consultas"
				EndIf

				Loop

			Case aOrdem[nOrd] == "TMN"
				aAdd( aRestricao, { __TMN_FOLDER__, 0, .F., { "MDTA115", "MDTA110" }, STR0003 } ) //"Prog. Saúde"
				Loop

			Case aOrdem[nOrd] == "TMF"
				aAdd( aRestricao, { __TMF_FOLDER__, 0, .T., { "MDTA110" }, STR0004 } ) //"Restrições"
				Loop

			Case aOrdem[nOrd] == "TNA"
				aAdd( aRestricao, { __TNA_FOLDER__, 0, .T., { "MDTA110" }, STR0005 } ) //"Doenças"
				Loop

			Case aOrdem[nOrd] == "TM5"
				aAdd( aRestricao, { __TM5_FOLDER__, 0, .F., { "MDTA120", "MDTA110" }, STR0006 } ) //"Exames"
				Loop

			Case aOrdem[nOrd] == "TMY"
				aAdd( aRestricao, { __TMY_FOLDER__, 0, .F., { "MDTA200", "MDTA110" }, STR0007 } ) //"ASO's"
				Loop

			Case aOrdem[nOrd] == "TNY"
				aAdd( aRestricao, { __TNY_FOLDER__, 0, .F., { "MDTA685", "MDTA110" }, STR0008 } ) //"Atestado"
				Loop

			Case aOrdem[nOrd] == "TNC"
				aAdd( aRestricao, { __TNC_FOLDER__, 0, .F., { "MDTA640" }, STR0009 } ) //"Acidentes"
				Loop

			Case aOrdem[nOrd] == "TMT"
				aAdd( aRestricao, { __TMT_FOLDER__, 0, .F., { "MDTA155" }, STR0011 } ) //"Diagnósticos"
				Loop

			Case aOrdem[nOrd] == "TL9"
				aAdd( aRestricao, { __TL9_FOLDER__, 0, .F., { "MDTA530" }, STR0013 } ) //"Vacinas"
				Loop

			Case aOrdem[nOrd] == "TNF"

				If !IsInCallStack( "MDTA076" )
					aAdd( aRestricao, { __TNF_FOLDER__, 0, .F., { "MDTA695", "MDTA630" }, STR0010 } ) //"EPI'S"
				EndIf

				Loop

			Case aOrdem[nOrd] == "TMI"
				aAdd( aRestricao, { __TMI_FOLDER__, 0, .T., { "MDTA145" }, STR0012 } ) //"Questionário"
				Loop

			End Case

		Next nOrd

		// Carrega na memoria os campos utilizados
		RegtoMemory( "TM0", .T., , .F. ) //Ficha Medica
		If !IsInCallStack( "MDTA076" )
			RegtoMemory( "TMJ", .T., , .F. ) //Consultas
		EndIf
		RegtoMemory( "TMN", .T., , .F. ) //Programa de Saude
		RegtoMemory( "TMF", .T., , .F. ) //Restricoes
		RegtoMemory( "TNA", .T., , .F. ) //Doecas
		RegtoMemory( "TM5", .T., , .F. ) //Exames
		RegtoMemory( "TMY", .T., , .F. ) //ASO'S
		RegtoMemory( "TNY", .T., , .F. ) //Atestado
		RegtoMemory( "TNC", .T., , .F. ) //Acidentes
		RegtoMemory( "TMT", .T., , .F. ) //Diagnósticos Médicos
		RegtoMemory( "TM2", .T., , .F. ) //Medicamentos Utilizados
		RegtoMemory( "TL9", .T., , .F. ) //Vacinas
		If !IsInCallStack( "MDTA076" )
			RegtoMemory( "TNF", .T., , .F. ) //EPI'S
		EndIf
		RegtoMemory( "TMI", .T., , .F. ) //Questionário Médico

		Private oDlg410 // Objeto Dialog para controle interno
		Private oModel	// Modelo de dados para a aba de Atestado Médico e Acidentes.

		RetPermission() // Verifica permissoes de acesso do usuário

		DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7], 0 TO nAltura410, nLargura Of oMainWnd COLOR CLR_BLACK, CLR_WHITE STYLE nOr(DS_SYSMODAL, WS_MAXIMIZEBOX, WS_POPUP) Pixel
		oDlg:lMaximized := .T.
		oDlg:lEscClose := .F.
		oDlg410 := oDlg

		// Cria objetos a Esquerda da Tela
		CreateTop( oDlg )

		// Cria objetos a Esquerda da Tela
		CreateLeft( oDlg )

		// Cria objetos a Direita da Tela
		CreateRight( oDlg )

		// Cria Panel escuro cobrindo toda a Dialog
		oBlackPnl := TPanel():New( 0, 0, , oDlg, , , , , SetTransparentColor( CLR_BLACK, 70 ), nLargura, nAltura410, .F., .F. )
		oBlackPnl:Hide()

		//-------------------------------------------------
		// Mostra informações de uma ficha automaticamente
		//-------------------------------------------------
		If !Empty( _cNumFi410 )
			dbSelectArea( "TM0" )
			dbSetOrder( 1 )
			dbSeek( xFilial( "TM0" )+_cNumFi410 )
			Eval( oBrwTM0:bChange )
			Eval( oBrwTM0:bLDblClick )
		Else
			TM0->(dbGoTop())
			oBrwTM0:GoUp()
		EndIf

		ACTIVATE MSDIALOG oDlg

	EndIf

	// Retorna conteudo de variaveis padroes
	NGRETURNPRM( aNGBEGINPRM )

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} CreateTop
Cria objetos no topo da tela

@param oParent Objeto pai
@author Vitor Emanuel Batista
@since 25/11/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function CreateTop(oParent)

	Local oPnlTop
	Local oPnlLeft
	Local oPnlRight
	Local nLarguraPnl

	oPnlTop := TPanel():New( 0, 0, , oParent, , , , , aColors[2], 0, 35, .F., .F. )
	oPnlTop:Align := CONTROL_ALIGN_TOP

	//--------------------------------------------------------
	// Cria Cabeçalho com informações do usuário/funcionário
	//--------------------------------------------------------
	oPnlLeft := TPanel():New( 0, 0, , oPnlTop, , , , , aColors[2], 205, 35, .F., .F. )
	oPnlLeft:Align := CONTROL_ALIGN_LEFT

	oTPanel410 := TPaintPanel():New( 5, 15, 190, 25, oPnlLeft )
	oTPanel410:addShape( "id=0;type=1;left=0;top=0;width=380;height=50;"+;
		"gradient=1,0,-10,0,40,0.4,#C3DBF9,0.9,#83AAE2,0.0,#FFF6FF;pen-width=2;"+;
		"pen-color=#FFFFFF;can-move=0;can-mark=0;is-container=1;" )

	aRGB := NGHEXRGB( "104479" )
	oNomeFun2 := TSay():New( 6, 3, , oTPanel410, , TFont():New( , , 28, .T., .T. ), .F., , , .T., RGB( aRGB[1], aRGB[2], aRGB[3] ), CLR_WHITE, 200, 20 )
	oNomeFun1 := TSay():New( 6, 4, , oTPanel410, , TFont():New( , , 28, .T., .T. ), .F., , , .T., CLR_WHITE, CLR_WHITE, 200, 20 )

	//----------------------------------------------
	// Cria cabecalho e botao de impressao da Ficha
	//----------------------------------------------
	oPnlRight := TPanel():New( 0, 0, , oPnlTop, , , , , aColors[2], 0, 35, .F., .F. )
	oPnlRight:Align := CONTROL_ALIGN_ALLCLIENT

	nLarguraPnl := Int( oPnlRight:NCLIENTWIDTH/2 ) - 85
	oTPanel410 := TPaintPanel():New( 5, 8, nLarguraPnl, 25, oPnlRight )
	oTPanel410:addShape( "id=0;type=1;left=0;top=0;width="+Str( ( nLarguraPnl*2 ) )+";height=50;"+;
		"gradient=1,0,-15,0,40,0.4,#C3DBF9,0.9,#83AAE2,0.0,#FFF6FF;pen-width=2;"+;
		"pen-color=#FFFFFF;can-move=0;can-mark=0;is-container=1;" )

	//----------------------------------
	// Implementação de sombra no texto
	//----------------------------------
	TSay():New( 0, 0, {|| STR0080 }, oTPanel410, , TFont():New( , , 28, .T., .T. ), .T., , , .T., CLR_BLACK, CLR_BLACK, nLarguraPnl+1, 26 )//"Ficha do Funcionário"
	TSay():New( 0, 0, {|| STR0080 }, oTPanel410, , TFont():New( , , 28, .T., .T. ), .T., , , .T., CLR_WHITE, CLR_WHITE, nLarguraPnl, 25 )//"Ficha do Funcionário"

	oTPanel410 := TPaintPanel():New( 5, nLarguraPnl+20, 60, 25, oPnlRight )
	oTPanel410:addShape( "id=0;type=1;left=0;top=0;width=120;height=50;"+;
		"gradient=1,0,-15,0,40,0.4,#C3DBF9,0.9,#83AAE2,0.0,#FFF6FF;pen-width=2;"+;
		"pen-color=#FFFFFF;can-move=0;can-mark=0;is-container=1;" )

	//--------------------------------------
	// Botão para impressão da Ficha Médica
	//--------------------------------------
	TBtnBmp2():New( 2, 5, 50, 49, 'ng_impressora', , , , {|| MDTR400( TM0->TM0_NUMFIC ) }, oTPanel410, , {|| !lIncReg .And. !lAltReg}, .T. )
	TSay():New( 7.5, 30.5, {|| STR0081 }, oTPanel410, , TFont():New( , , 24, .T., .T. ), .F., , , .T., CLR_BLACK, CLR_BLACK, 31, 26 )//"Ficha"
	TSay():New( 7, 30, {|| STR0081 }, oTPanel410, , TFont():New( , , 24, .T., .T. ), .F., , , .T., CLR_WHITE, CLR_WHITE, 30, 25 )	//"Ficha"
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} CreateLeft
Cria objetos a esquerda da tela

@param oParent Objeto pai
@author Vitor Emanuel Batista
@since 25/11/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function CreateLeft(oParent)

	Local nX
	Local oPnlBtn, oPnlAux
	Local cBtnAux
	Local oTBtnBmp
	
	Local aChoice := {"TM0_NUMFIC", "TM0_CANDID", "TM0_FILFUN", "TM0_MAT", "TM0_NOMFIC", "TM0_DTIMPL", "TM0_DTNASC",;
		"TM0_SEXO", "TM0_RG", "TM0_LOCFIC", "TM0_CODFUN", "TM0_CC", "TM0_NUMCP", "TM0_SERCP", "TM0_UFCP",;
		"TM0_CPF"}
	//------------------------------------
	// Cria Panel com os botoes laterais
	//------------------------------------
	oPnlBtn := TPanel():New( 0, 0, , oParent, , , , , aColors[2], 13, 0, .F., .F. ) // RGB(67,70,87)
	oPnlBtn:Align := CONTROL_ALIGN_LEFT

	oBtnFilt  := TBtnBmp():NewBar( "ng_ico_filtro1", "ng_ico_filtro1", , , , {|| SetBlackPnl(), BuildFilter( "TM0" ), SetBlackPnl( .F. )}, ,;
		oPnlBtn, , { || } )
	oBtnFilt:cToolTip := STR0014 //"Filtrar"
	oBtnFilt:Align    := CONTROL_ALIGN_TOP

	oBtnIncFic  := TBtnBmp():NewBar( "ng_ico_incluir", "ng_ico_incluir", , , , {|| nOpcPro := 3, oBrwTM0:Hide(), LoadEmployee( oPnlTM0, , 3 ),;
		oEncTM0:Refresh(), oEncTM0:oBox:Refresh()}, , oPnlBtn, , {|| } )
	oBtnIncFic:cToolTip := STR0034 //"Incluir"
	oBtnIncFic:Align    := CONTROL_ALIGN_TOP

	// Verificação do bloqueio de alterações da ficha médica
	oBtnAltFic  := TBtnBmp():NewBar( "bpm_ico_editar", "bpm_ico_editar", , , , {|| IIf( SuperGetMv( 'MV_NG2ATM0', .F., '3' ) == '1',;
		Help( , , 'NG2ATM0' ), ( nOpcPro := 4, oBrwTM0:Hide(), LoadEmployee( oPnlTM0, , 4 ), oEncTM0:Refresh(),;
		oEncTM0:oBox:Refresh() ) ) }, , oPnlBtn, , { || TM0->( !Eof() .Or. !Bof() ) } )
	oBtnAltFic:cToolTip := STR0035 //"Alterar"
	oBtnAltFic:Align    := CONTROL_ALIGN_TOP

	oBtnExcFic  := TBtnBmp():NewBar( "ng_ico_excluir", "ng_ico_excluir", , , , {|| nOpcPro := 5, oBrwTM0:Hide(), LoadEmployee( oPnlTM0, , 5 ) }, ,;
		oPnlBtn, , {|| TM0->( !Eof() .Or. !Bof() ) } )
	oBtnExcFic:cToolTip := STR0036 //"Excluir"
	oBtnExcFic:Align    := CONTROL_ALIGN_TOP

	oBtnLgd  := TBtnBmp():NewBar( "ng_ico_lgndos", "ng_ico_lgndos", , , , {|| SetBlackPnl(), fLegenda(), SetBlackPnl( .F. )}, , oPnlBtn, , {|| .T. } )
	oBtnLgd:cToolTip := STR0015 //"Legenda"
	oBtnLgd:Align    := CONTROL_ALIGN_TOP

	If !lPyme
		oBtnConh  := TBtnBmp():NewBar( "ng_ico_conhecimento", "ng_ico_conhecimento", , , , {||MDTA410DOC() }, , oPnlBtn, , {|| .T. } )
		oBtnConh:cToolTip := STR0093 //"Conhecimento"
		oBtnConh:Align    := CONTROL_ALIGN_TOP
	EndIf

	oBtnSavFic  := TBtnBmp():NewBar( "NG_ICO_SALVAR", "NG_ICO_SALVAR", , , , { || IIf( fOpeFicha(), CloseRecord(), ) }, , oPnlBtn, , {|| } )
	oBtnSavFic:cToolTip := STR0063 //"Salvar"
	oBtnSavFic:Align    := CONTROL_ALIGN_TOP
	oBtnSavFic:Hide()

	oBtnCanFic  := TBtnBmp():NewBar( "ng_ico_cancelar", "ng_ico_cancelar", , , , , , oPnlBtn, , {|| } )
	oBtnCanFic:bAction  := { || fOpeFicha( .F. ), CloseRecord(), ChangeTM0( oNomeFun1, oNomeFun2 ) }
	oBtnCanFic:cToolTip := STR0050 //"Cancelar"
	oBtnCanFic:Align    := CONTROL_ALIGN_TOP
	oBtnCanFic:Hide()

	For nX := 1 To Len( aButtonTM0 )

		cBtnAux := "oBtnFic" + cValToChar( nX )

		&(cBtnAux)  := TBtnBmp():NewBar( aButtonTM0[ nX, 3 ], aButtonTM0[ nX, 3 ], , , , aButtonTM0[ nX, 2 ], , oPnlBtn, , {|| } )
		&( cBtnAux ):cToolTip := aButtonTM0[ nX, 1 ]
		&( cBtnAux ):Align    := CONTROL_ALIGN_TOP
		&( cBtnAux ):Hide()
	Next nX

	oBtnQuit  := TBtnBmp():NewBar( "ng_ico_saida", "ng_ico_saida", , , , {|| CloseRecord()}, , oPnlBtn, , {|| !lIncReg .And. !lAltReg} )
	oBtnQuit:cToolTip := STR0016 //"Sair da Ficha Médica"
	oBtnQuit:Align    := CONTROL_ALIGN_TOP
	oBtnQuit:Hide()

	oTBtnBmp  := TBtnBmp():NewBar( "ng_ico_final", "ng_ico_final", , , , {|| IIf( MDT410Exit() .And. FindFunction( "MDTA076" ), oParent:End(), .F. )}, , oPnlBtn ) //"Atenção"
	oTBtnBmp:cToolTip := STR0018 //"Sair"
	oTBtnBmp:Align    := CONTROL_ALIGN_TOP

	oPnlLeft := TPanel():New( 0, 0, , oParent, , , , , /*RGB(17,80,07)*/ , 190, 0, .F., .F. )
	oPnlLeft:SetCss( "Q3Frame{ border: 0px }" )
	oPnlLeft:Align := CONTROL_ALIGN_LEFT

	oPnlAux := TPanel():New( 0, 0, , oPnlLeft, , , , , aColors[2], 0, 0, .F., .F. )
	oPnlAux:SetCss( "Q3Frame{ border: 0px }" )
	oPnlAux:Align := CONTROL_ALIGN_ALLCLIENT

	//------------------------------
	// Cria Browse com todos os TM0
	//------------------------------
	oBrwTM0 := TCBrowse():New( 0, 0, 0, 0, , , , oPnlAux, , , , , , , , , , , , , 'TM0', .T., , , , .T., .T. )
	oBrwTM0:Align := CONTROL_ALIGN_ALLCLIENT
	oBrwTM0:AddColumn( TCColumn():New( " ", {|| SituacaoFicha() }, , , , , 10, .T., .F., , , , , ) )
	oBrwTM0:AddColumn( TCColumn():New( STR0060, {|| TM0->TM0_NUMFIC }, , , , 'LEFT', , .F., .F., , , , .F., ) ) //"Código"
	oBrwTM0:AddColumn( TCColumn():New( STR0061, {|| TM0->TM0_NOMFIC}, , , , 'LEFT', , .F., .F., , , , .F., ) ) //"Nome"
	oBrwTM0:bLDblClick := {|| oBrwTM0:Hide(), LoadEmployee( oPnlTM0, .T. ), oEncImg:Refresh(), oEncImg:oBox:Refresh()}
	oBrwTM0:bChange := {|| FieldsToMemory( "TM0", .F. ), ChangeTM0( oNomeFun1, oNomeFun2 ) }
	oBrwTM0:bWhen   := {|| TM0->( !Eof() .Or. !Bof() ) }
	oBrwTM0:bHeaderClick := {|oOwner, nCol| fOrderFic( oOwner, nCol ) } // Evento de clique no cabeçalho da browse
	FilBrowse( "TM0", {}, cFilterTM0 )//Filtra o browser

	//------------------------------
	// Cria Painel com o registro TM0
	//------------------------------
	oPnlTM0 := TPanel():New( 0, 0, , oPnlAux, , , , , aColors[2], 3000, 3000, .F., .F. )
	oPnlTM0:SetCss( "Q3Frame{ border: 0px }" )
	oPnlTM0:Align := CONTROL_ALIGN_ALLCLIENT

	//----------------------------------------
	// Cria Enchoice com campo de Foto da TM0
	//----------------------------------------
	oEncImg := MsMGet():New( "TM0", 0, 4, , , , {"TM0_BITMAP"}, {0, 0, 130, 0}, , , , , , oPnlTM0, , .T., .T., , .T., .T. )
	oEncImg:oBox:Align := CONTROL_ALIGN_TOP

	//----------------------------------------
	// Cria Enchoice com demais campos da TM0
	//----------------------------------------
	oEncFun := MsMGet():New( "TM0", 0, 4, , , , aChoice, {0, 140, 0, 40}, , , , , , oPnlTM0, , .T., .T., , .T., .T. )
	oEncFun:oBox:Align := CONTROL_ALIGN_ALLCLIENT
	oEncFun:Disable()

	oPnlTM0:Hide()//Esconde o painel pois será exibido somente no duplo click

	//Botao para esconder menu lateral esquerdo
	oPnlShow := TButton():New( 002, 002, "<", oParent, , 5, 10, , , .F., .T., .F., , .F., , , .F. )
	oPnlShow:bAction := {|x, y| (oPnlShow:cTitle := IIf( oPnlShow:cTitle == ">", "<", ">" ),;
		IIf( oPnlShow:cTitle == "<", oPnlLeft:Show(), oPnlLeft:Hide() ) ), oEncTM0:SetFocus()}
	oPnlShow:Align := CONTROL_ALIGN_LEFT
	oPnlShow:SetCSS( "QPushButton{ background-color: #F4F4F4; color: #BEBEBE; font-size: 8px; border: 1px solid #D3D3D3; } " +;
		"QPushButton:Focus{ background-color: #FFFAFA; } " +;
		"QPushButton:Hover{ background-color: #F4F4F4; color: #000000; border: 1px solid #D3D3D3; } " )

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} ChangeTM0
Altera o nome do funcionario no Say acima do Browse

@author Vitor Emanuel Batista
@since 26/11/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function ChangeTM0( oNomeFun1, oNomeFun2 )
	Local cNomeFicha := IIf( lIncReg, Space( Len( TM0->TM0_NOMFIC ) ), AllTrim( TM0->TM0_NOMFIC ) )

	oNomeFun1:SetText( Capital( cNomeFicha ) )
	oNomeFun2:SetText( Capital( cNomeFicha ) )
	oEncTM0:Refresh()

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} SituacaoFicha
Retorna a cor respectiva para a Ficha posicionada

@author Vitor Emanuel Batista
@since 26/11/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function SituacaoFicha()

	Local nX
	Local aCores := fCriaCor() //Função do GPECFGEN
	Local cCor   := "BR_VERMELHO"

	If Empty( TM0->TM0_MAT ) .And. !Empty( TM0->TM0_CANDID )
		cCor := "BR_BRANCO"
	Else
		dbSelectArea( "SRA" )
		dbSetOrder( 1 )
		dbSeek( xFilial( "SRA", TM0->TM0_FILFUN )+TM0->TM0_MAT )

		For nX := 1 To Len( aCores )
			If &(aCores[nX][1])
				cCor := aCores[nX][2]
				Exit
			EndIf
		Next nX
	EndIf

Return LoadBitmap( GetResources(), cCor )

//---------------------------------------------------------------------
/*/{Protheus.doc} LoadEmployee
Monta Enchoice detalhando o funcionário

@param oParent Objeto pai
@author Vitor Emanuel Batista
@since 26/11/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function LoadEmployee( oParent, lDbClick, nOperacao )

	Local nX
	Local lIncluiTM0 := .F.
	Local lAlteraTM0 := .F.
	Local lExcluiTM0 := .F.
	Local cClassM := "ClassMethArr"
	Local aClassM := {}
	Local aSM0 		 := FwLoadSM0()
	Local nPosFil	 := 0

	Default nOperacao := 1
	Default lDbClick  := .F.

	lIncluiTM0 := nOperacao == 3
	lAlteraTM0 := nOperacao == 4
	lExcluiTM0 := nOperacao == 5

	//------------------------------
	// Coloca o ponteiro em espera
	//------------------------------
	CursorWait()

	//-----------------------------------
	// Libera botoes nao mais utilizados
	//-----------------------------------
	oBtnLgd:Hide()
	oBtnFilt:Hide()
	oBtnIncFic:Hide()
	oBtnAltFic:Hide()
	oBtnExcFic:Hide()

	If !lDbClick

		/*------------------------------------------------------------+
		| Libera panel esquerdo, maximizando o browse da ficha médica |
		+------------------------------------------------------------*/
		oPnlLeft:Hide()
		oPnlShow:Hide()

	EndIF

	If !lPyme .And. !IsInCallStack( "MDTA076" )  //Caso for chamado pela Agenda Médica ainda mostra o botão
		oBtnConh:Hide()
	EndIf
	//------------------------------------------------
	// Variável de controle do Número da Ficha Médica
	//------------------------------------------------
	If ( lIncluiTM0 .Or. lAlteraTM0 .Or. lExcluiTM0 )
		If lIncluiTM0
			SetInclui()
		ElseIf lAlteraTM0
			SetAltera()
		Else
			SetExclui()
		EndIf

		//-----------------------------------------------
		// Variaveis de controle de Inclusão e Alteração
		//-----------------------------------------------
		lIncReg := Inclui
		lAltReg := Altera .Or. Exclui

		//---------------------------------------------------------------------
		// Variavel zerada para utliziaçao da operação de tarefas do candidato
		//---------------------------------------------------------------------
		aTarefaTKD := {}
		lFirstTKD  := .T.

		oBtnSavFic:Show()
		oBtnCanFic:Show()

		If lExcluiTM0
			oEncImg:Disable()
			oEncTM0:Disable()
		Else
			For nX := 1 To Len( aButtonTM0 )
				&("oBtnFic" + cValToChar( nX )):Show()
			Next nX

			oEncImg:Enable()
			oEncTM0:Enable()
		EndIf
		oEncFun:Hide()

	Else
		If IsInCallStack( "MDTA076" )
			oBtnQuit:Hide()
		Else
			oBtnQuit:Show()
		EndIf
		oEncImg:Disable()
		oEncTM0:Disable()
		oEncFun:Show()
	EndIf
	//------------------------------------------------
	// Busca a Filial conforme a Ficha Médica
	// Caso não encontre mantem a atual
	// Caso filial seja compartilhada salva a primeira
	//  correspodente ao compartilhamento da TM0
	//------------------------------------------------
	If ( nPosFil := aScan( aSM0, { | x | x[ 1 ] == cEmpAnt .And. AllTrim( TM0->TM0_FILIAL ) $ x[ 2 ] } ) ) > 0
		cFilAnt	   := aSM0[ nPosFil, 2 ]
		cFilAsoOld := aSM0[ nPosFil, 2 ]
	EndIf

	//------------------------------------------------
	// Variável de controle do Número da Ficha Médica
	//------------------------------------------------
	_cNumFi410 := IIf( lIncluiTM0, Space( Len( TM0->TM0_NUMFIC ) ), TM0->TM0_NUMFIC )
	_cMatri410 := IIf( lIncluiTM0, Space( Len( TM0->TM0_MAT ) ), TM0->TM0_MAT )
	_nRecno410 := TM0->(Recno())
	_cFilter410:= TM0->(dbFilter())

	//--------------------------------------------------
	// Variável de controle para o Prestador de Serviço
	//--------------------------------------------------
	If lSigaMdtPS
		cCliMdtPs := TM0->TM0_CLIENT + TM0->TM0_LOJA

		dbSelectArea( "SA1" )
		dbSetOrder( 1 )
		Set Filter To xFilial( "SA1" ) == TM0->TM0_FILFUN .And. SA1->A1_COD + SA1->A1_LOJA == TM0->TM0_CLIENT + TM0->TM0_LOJA
	EndIf

	//---------------------------------
	// Carrega dados na memoria da TM0
	//---------------------------------
	FieldsToMemory( "TM0", lIncluiTM0 )
	If !lIncluiTM0
		dbSelectArea( "TM0" )
		dbSetOrder( 1 )
		dbGoTo( _nRecno410 )
		If lDbClick
			Set Filter To TM0->TM0_FILIAL == xFilial( "TM0" ) .And. TM0->TM0_NUMFIC == _cNumFi410
		EndIf

		If !Empty( _cMatri410 )
			dbSelectArea( "SRA" )
			dbSetOrder( 1 )
			Set Filter To SRA->RA_FILIAL == TM0->TM0_FILFUN .And. SRA->RA_MAT == _cMatri410
		EndIf
	EndIf

	//-------------------------------------
	// Habilita Painel com MsGet
	//-------------------------------------
	//Força reposicionamento para atualização da Imagem
	dbSelectArea( "TM0" )
	dbSetOrder( 1 )
	dbSeek( M->TM0_FILIAL + M->TM0_NUMFIC )

	oParent:Show()
	oEncFun:Refresh()
	If ( lDbClick .And. Empty( M->TM0_BITMAP ) )
		oEncImg:Hide()
	Else
		oEncImg:Show()
		If FindFunction( cClassM )
			aClassM := &cClassM.( oEncImg, .T. )
			If aScan( aClassM, {|x| x[1] == "UPDBMP"} ) > 0   //Verifica se a classe UPDBMP existe.
				oEncImg:UpdBMP( M->TM0_BITMAP ) //Atualiza o campo TM0_BITMAP
			EndIf
		EndIf
	EndIf

	//-------------------------------------
	// Habilita todas as opções de  Folder
	//-------------------------------------
	FolderEnable( lDbClick )

	//-------------------------------------------
	// Verifica se funcionário possui matrícula
	// para bloquear folder de EPI
	//-------------------------------------------
	If Empty( _cMatri410 ) .And. __TNF_FOLDER__ > 0
		oFolder410:aEnable( __TNF_FOLDER__, .F. )
	EndIf

	//---------------------------
	// Libera ponteiro do mouse
	//---------------------------
	CursorArrow()

	//------------------------------------------------------
	// Altera o nome do funcionario no Say acima do Browse
	//------------------------------------------------------
	ChangeTM0( oNomeFun1, oNomeFun2 )

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} CreateRight
Cria objetos a direita da tela

@param oParent Objeto pai
@author Vitor Emanuel Batista
@since 25/11/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function CreateRight(oParent)

	Local nX
	Local oPnlAux
	Local aChoice  := {}
	Local aTFolder := {}

	aNaoChoice := {"TM0_BITMAP", "TM0_CLIENT", "TM0_LOJA", "TM0_NOMCLI0", "TM0_REGBIO"}
	If !lBiometria
		aAdd( aNaoChoice, "TM0_INDBIO" )
	EndIf

	aChoice := NGCAMPNSX3( "TM0", aNaoChoice )

	For nX := 1 To Len( aRestricao )
		If aRestricao[nX][__HABILITADO__]
			aAdd( aTFolder, aRestricao[nX][__TITULO__] )
			aRestricao[nX][__OPCAO__] := Len( aTFolder )
		EndIf
	Next nX

	oPnlRight := TPanel():New( 0, 0, , oParent, , , , , , 0, 100, .F., .F. )
	oPnlRight:Align := CONTROL_ALIGN_ALLCLIENT

	//----------------------------
	// Cria Folder com seus dados
	//----------------------------
	oFolder410 := TFolder():New( 0, 0, aTFolder, , oPnlRight, , , , .T., , nLargura, nAltura410 )
	oFolder410:Align := CONTROL_ALIGN_ALLCLIENT
	oFolder410:bSetOption := {|nOption| ChangeFolder( oFolder410:nOption, nOption )}

	//---------------------------------------
	// Desabilita todas as opções de  Folder
	//---------------------------------------
	FolderEnable( .F. )

	//-------------------------------
	// Cria enchoice da Ficha Medica
	//-------------------------------
	oPnlAux := TPanel():New( 0, 0, , oFolder410:aDialogs[1], , , , , aColors[2], 0, 13, .F., .F. )
	oPnlAux:Align := CONTROL_ALIGN_TOP

	TSay():New( 03, 02, {|| STR0001}, oPnlAux, , TFont():New( , , 18, .T., .T. ), , , , .T., aColors[1], CLR_WHITE, 200, 20 )  //"Ficha Médica"

	oEncTM0 := MsMGet():New( "TM0", TM0->( Recno() ), 4, , , , aChoice, , , , , , , oFolder410:aDialogs[1], , .T., .T., , .T., .T. )
	oEncTM0:oBox:Align := CONTROL_ALIGN_ALLCLIENT
	oEncTM0:Disable()

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} CreateFolder
Cria objetos do folder de acordo com a opção escolhida

@param nOption Opção do folder
@author Vitor Emanuel Batista
@since 04/06/2011
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function CreateFolder(nOption)

	Local aButtons := {}
	Local nCps
	Local cFilter
	Local bValid
	Local bSave
	Local nUpdNatAso
	Local cNatAsoSav, cInPareSav

	If RetCodigoFolder( nOption ) == __TMJ_FOLDER__

		//-------------------------
		// Cria dados - Consultas
		//-------------------------
		dbSelectAreA( "TMJ" )
		dbSetOrder( 6 )
		aButtons := {{"ng_os_troca", {|| SetBlackPnl(), NG075MUD(), oBrwTMJ:Refresh(), FieldsToMemory( "TMJ", .F. ), SetBlackPnl( .F. )}, STR0019}} //"Transferência"
		cFilter  := ValToSql( xFilial( "TMJ" ) )+' == TMJ->TMJ_FILIAL .And. TMJ->TMJ_NUMFIC == '+ValToSql( _cNumFi410 )
		bValid   := {|| MDT075VAL( .F. )}
		aNao     := {"TMJ_NUMFIC", "TMJ_NOMFIC", "TMJ_MAT", "TMJ_PCMSO", "TMJ_DTATEN", "TMJ_DTPROG", "TMJ_CONVOC"}
		bInit    := {|| M->TMJ_FILFUN := TM0->TM0_FILFUN }

		CreateOption( oFolder410:aDialogs[nOption], "TMJ", aNao, @oBrwTMJ, @oEncTMJ, STR0020, aButtons, cFilter, bValid, Nil, bInit ) //"Agenda de Consultas Médicas"

	ElseIf RetCodigoFolder( nOption ) == __TMN_FOLDER__

		//---------------------------------
		// Cria dados - Programa de Saude
		//---------------------------------
		cFilter := ValToSql( xFilial( "TMN" ) )+' == TMN->TMN_FILIAL .And. TMN->TMN_NUMFIC == '+ValToSql( _cNumFi410 )
		aNao     := {"TMN_NUMFIC", "TMN_NOMFIC"}

		CreateOption( oFolder410:aDialogs[nOption], "TMN", aNao, @oBrwTMN, @oEncTMN, STR0062, Nil, cFilter ) //"Programa de Saúde"

	ElseIf RetCodigoFolder( nOption ) == __TMF_FOLDER__

		//---------------------------
		// Cria dados - Restricoes
		//---------------------------
		cFilter := ValToSql( xFilial( "TMF" ) )+' == TMF->TMF_FILIAL .And. TMF->TMF_NUMFIC == '+ValToSql( _cNumFi410 )
		aNao	:= {"TMF_NUMFIC", "TMF_NOMFIC"}

		CreateOption( oFolder410:aDialogs[nOption], "TMF", aNao, @oBrwTMF, @oEncTMF, STR0021, Nil, cFilter ) //"Restrições do Funcionário"

	ElseIf RetCodigoFolder( nOption ) == __TNA_FOLDER__

		//-------------------------
		// Cria dados - Doenças
		//-------------------------
		cFilter := ValToSql( xFilial( "TNA" ) )+' == TNA->TNA_FILIAL .And. TNA->TNA_NUMFIC == '+ValToSql( _cNumFi410 )
		aNao    := {"TNA_NUMFIC", "TNA_NOMFIC"}

		CreateOption( oFolder410:aDialogs[nOption], "TNA", aNao, @oBrwTNA, @oEncTNA, STR0022, Nil, cFilter ) //"Doenças do Funcionário"

	ElseIf RetCodigoFolder( nOption ) == __TM5_FOLDER__

		//----------------------
		// Cria dados - Exames
		//----------------------
		aButtons := {{"ng_ico_resultado", {|| SetBlackPnl(), REXAME120(), oBrwTM5:Refresh(), SetBlackPnl( .F. )}, "Resultado"}}
		cFilter  := ValToSql( xFilial( "TM5" ) )+' == TM5->TM5_FILIAL .And. TM5->TM5_NUMFIC == '+ValToSql( _cNumFi410 )
		aNao     := {"TM5_NUMFIC", "TM5_NOMFIC"}
		bValid   := Nil
		bSave    := Nil
		bInit    := {|| MDT120INIT( _cNumFi410 ) }

		CreateOption( oFolder410:aDialogs[nOption], "TM5", aNao, @oBrwTM5, @oEncTM5, STR0023, aButtons, cFilter, bValid, bSave, bInit ) //"Exames do Funcionário"

	ElseIf RetCodigoFolder( nOption ) == __TMY_FOLDER__
		//-----------------------
		// Cria dados - ASO'S
		//-----------------------

		If Empty( M->TMY_DTPROG )
			M->TMY_DTPROG := dDataBase
		EndIf

		aButtons := {{"ng_ico_imp", {|| SetBlackPnl(), NG200IMP(), oBrwTMY:Refresh(), SetBlackPnl( .F. )}, STR0026}} //"Imprimir"

		aAdd( aButtons, {"ng_ico_relac", {||SetBlackPnl(), fMenuRel( oFolder410:aDialogs[nOption] ), oBrwTMY:Refresh(), SetBlackPnl( .F. )}, STR0085} ) //"Relacionamentos"

		cFilter  := ValToSql( xFilial( "TMY" ) )+' == TMY->TMY_FILIAL .And. TMY->TMY_NUMFIC == '+ValToSql( _cNumFi410 )
		aNao     := {"TMY_NUMFIC", "TMY_NOMFIC", "TMY_DESPAR", "TMY_DESNAT"}
		bValid   := {|| a200CHK( IIf( INCLUI, 3, IIf( ALTERA, 4, 5 ) ), nUpdNatAso, cNatAsoSav, cInPareSav )}
		bInit    := {|| MDT200INIT( @nUpdNatAso, @cNatAsoSav, @cInPareSav ) }
		bSave    := {|lSave| IIf( lSave, MDT200GRV( IIf( INCLUI, 3, IIf( ALTERA, 4, 5 ) ), nUpdNatAso, cNatAsoSav, cInPareSav ), Nil ) }

		CreateOption( oFolder410:aDialogs[nOption], "TMY", aNao, @oBrwTMY, @oEncTMY, STR0024, aButtons, cFilter, bValid, bSave, bInit ) //"Atestado Saúde Ocupacional"

	ElseIf RetCodigoFolder( nOption ) == __TNY_FOLDER__

		//-------------------------
		// Cria dados - Atestado
		//-------------------------
		oModel := MDT685ACTI( , oModel, .T. )
		cFilter  := ValToSql( xFilial( "TNY" ) )+' == TNY->TNY_FILIAL .And. TNY->TNY_NUMFIC == '+ValToSql( _cNumFi410 )
		If AliasInDic( "TYZ" ) //Caso possua a tabela de afastamentos.
			aNao    := {"TNY_NUMFIC", "TNY_NOMFIC", "TNY_DTSAID", "TNY_DTALTA", "TNY_DTSAI2", "TNY_DTALT2", "TNY_DTSAI3", "TNY_DTALT3" }
		Else
			aNao    := {"TNY_NUMFIC", "TNY_NOMFIC" }
		EndIf
		bValid  := {|| MDT685CODA() .And. MDT685POS( oModel, IIf( INCLUI, 4, IIf( ALTERA, 4, 5 ) ) ) }
		bSave   := {|lSave| IIf( lSave, MDT685ACTI( IIf( INCLUI, 4, IIf( ALTERA, 4, 5 ) ), oModel, .T., .T. ), )}
		bInit	:= {|| MDT685ACTI( , oModel, .F. ) }

		Aadd( aButtons, {"ng_ico_reprocessa", {|| SetBlackPnl(), MDT685AFAS(), oBrwTNY:Refresh(), SetBlackPnl( .F. )}, STR0025, STR0025} ) //"Afastamentos"
		Aadd( aButtons, {"ng_ico_imp", {|| SetBlackPnl(), MDT685IMP(), oBrwTNY:Refresh(), SetBlackPnl( .F. )}, STR0026, STR0026} )		 //"Imprimir"
		If AliasInDic( "TYZ" ) //Caso possua a tabela de afastamentos.
			Aadd( aButtons, {"ng_os_troca", {|| SetBlackPnl(), MDT685LOC(), oBrwTNY:Refresh(), SetBlackPnl( .F. )}, STR0090, STR0090} ) //"Incluir Afastamentos"
		EndIf
		CreateOption( oFolder410:aDialogs[nOption], "TNY", aNao, @oBrwTNY, @oEncTNY, STR0027, aButtons, cFilter, bValid, bSave ) //"Atestados Médicos"

	ElseIf RetCodigoFolder( nOption ) == __TNC_FOLDER__

		//-------------------------
		// Cria dados - Acidentes
		//-------------------------

		cFilter := ValToSql( xFilial( "TNC" ) )+' == TNC->TNC_FILIAL .And. TNC->TNC_NUMFIC == '+ValToSql( _cNumFi410 )
		aNao    := {"TNC_NUMFIC", "TNC_NOMFIC"}
		If AliasInDic( "TYE" )
			aAdd( aNao, "TNC_CODOBJ" )
			aAdd( aNao, "TNC_DESOBJ" )
			aAdd( aNao, "TNC_CODPAR" )
			aAdd( aNao, "TNC_DESPAR" )
		EndIf
		bInit    := {|| A640CARMEM() .And. MDT640ACTI() }
		bSave    := {|lSave| IIf( lSave, MDT640ACTI( , , .T., IIf( INCLUI, 3, IIf( ALTERA, 4, 5 ) ) ), ) } //Gravação do registro
		CreateOption( oFolder410:aDialogs[nOption], "TNC", aNao, @oBrwTNC, @oEncTNC, STR0028, Nil, cFilter, Nil, bSave, bInit ) //"Acidentes de Trabalho"

	ElseIf RetCodigoFolder( nOption ) == __TMT_FOLDER__

		//-----------------------------------
		// Cria dados - Diagnosticos Medicos
		//-----------------------------------
		cFilter  := ValToSql( xFilial( "TMT" ) )+' == TMT->TMT_FILIAL .And. TMT->TMT_NUMFIC == '+ValToSql( _cNumFi410 )
		aNao     := {"TMT_NUMFIC", "TMT_NOMFIC", "TMT_MAT"}
		For nCps := 1 To Len( aCampos )
			aAdd( aNao, aCampos[ nCps, 2 ] )
		Next nCps
		bValid   := {|| IIf( INCLUI .Or. ALTERA, NG155CID( IIf( INCLUI, 3, IIf( ALTERA, 4, 5 ) ) ), AllwaysTrue() )}
		bSave    := {|lSave| IIf( FindFunction( "MDT155GDI" ), MDT155GDI( , aCampos, .T. ), ), oFolderTMT:aEnable( 2, .T. ) }
		bInit    := {|| oFolderTMT:aEnable( 2, .F. ) }

		If IsInCallStack( "MDTA076" )
			Aadd( aButtons, {"ng_ico_imp", {|| SetBlackPnl(), R406RECE(), oBrwTMT:Refresh(), SetBlackPnl( .F. )}, STR0026, STR0026} )		 //"Imprimir"
		EndIf

		CreateOption( oFolder410:aDialogs[nOption], "TMT", aNao, @oBrwTMT, @oEncTMT, STR0029, aButtons, cFilter, bValid, bSave, bInit, "MDTA155A" ) //"Diagnóstico Médico"

	ElseIf RetCodigoFolder( nOption ) == __TL9_FOLDER__

		//-----------------------
		// Cria dados - Vacinas
		//-----------------------
		cFilter  := ValToSql( xFilial( "TL9" ) )+' == TL9->TL9_FILIAL .And. TL9 ->TL9_NUMFIC == '+ValToSql( _cNumFi410 )
		aNao     := {"TL9_NUMFIC", "TL9_NOMFIC"}
		bValid   := { || MDT530INDV( "TL9" ) }

		CreateOption( oFolder410:aDialogs[nOption], "TL9", aNao, @oBrwTL9, @oEncTL9, STR0013, Nil, cFilter, bValid ) //"Vacinas"

	ElseIf RetCodigoFolder( nOption ) == __TMI_FOLDER__

		//-----------------------------------------------------
		// Cria Folder com informações do Questionário médico
		//-----------------------------------------------------
		SetBlackPnl()
		CreateQuiz( oFolder410:aDialogs[nOption], STR0030, @oBrwTMI ) //"Questionário Médico"
		SetBlackPnl( .F. )

	ElseIf RetCodigoFolder( nOption ) == __TNF_FOLDER__ .And. ( Type( "oGetTNF695" ) != "O" .Or. Type( "oGetTNF695:oBrowse" ) != "O" )

		oGetTNF695 := Nil
		SetBlackPnl()
		MsgRun( STR0031, STR0032, { || CreateEPI( oFolder410:aDialogs[nOption], STR0033 ) } ) //"Carregando EPI's"###"Aguarde..."###"EPI'S do Funcionário"

		SetBlackPnl( .F. )

	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} CreateOption
Cria objetos do folder Consultas no Relacionamentos Ocupacionais

@param oParent Objeto pai
@param cAlias Alias para a geracao do Enchoice
@param aNao Vetor com campos que nao irao ser listados em tela
@param oBrowse Variavel passada como referencia para o Browse
@param oEnchoice Variavel passada como referencia para o Enchoice
@param cText Texto apresentado no cabeçalho do Enchoice
@param aButtons Array contendo botoes específicos
@param cFilter Filtro padrão do Browse
@param bValid Indica validação ao confirmar inclusão e alteração do registro
@param bSave Bloco de código para executar operações extras no banco de dados
@param bInit Bloco de código para inicializar variáveis ao incluir, alterar.
@param [cRotina], Caractere, Nome do fonte ralacionado ao folder sendo criado
@author Vitor Emanuel Batista
@since 07/12/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function CreateOption( oParent, cAlias, aNao, oBrowse, oEnchoice, cText, aButtons, cFilter, bValid, bSave, bInit, cRotina )

	Local nButton
	Local oBoxCria
	Local oSplitter
	Local oPnlAux, oPnlShow
	Local oPnlTop, oPnlBottom, oPnlDown, oPnlCenter
	Local oPnlBtn
	Local oBtnInc, oBtnAlt, oBtnExc, oBtnEsp
	Local aChoice := NGCAMPNSX3( cAlias, aNao )
	Local aNao2

	Local lValid   := .T.
	Local lBtns    := .T. // verifica se deve habilitar botoes laterais
	Local bHelpUsu := { || Help( " ", 1, STR0017, , STR0094, 4, 5 ) } // "Atenção" # "Esse usuário não possui acesso para executar essa operação"

	Default cRotina := "MDTA410"

	If FindFunction( "MDTA076" ) .And. cAlias == "TMJ"
		aAdd( aNao, "TMJ_HRSAID" )
		aAdd( aNao, "TMJ_HRCHGD" )
		aAdd( aNao, "TMJ_CONVOC" )
		aAdd( aNao, "TMJ_PCMSO" )
	EndIf

	If cAlias == "TMY"
		aAdd( aChoice, "TMY_DTPROG" )
	EndIf

	Default aButtons := {}

	oParent:FreeChildren()

	//----------------------------------------
	// Cria Panel com Say do titulo do Folder
	//----------------------------------------
	oPnlAux := TPanel():New( 0, 0, , oParent, , , , , aColors[2], 0, 13, .F., .F. )
	oPnlAux:Align := CONTROL_ALIGN_TOP

	TSay():New( 03, 15, {|| cText}, oPnlAux, , TFont():New( , , 18, .T., .T. ), , , , .T., aColors[1], CLR_WHITE, 200, 20 )

	//--------------------------------------------
	// Splitter para dividir o Browse do Enchoice
	//--------------------------------------------
	oSplitter := TSplitter():New( 0, 0, oParent, 0, 0, 1 )
	oSplitter:Align := CONTROL_ALIGN_ALLCLIENT
	oSplitter:SetOrient( 1 )

	oPnlTop := TPanel():New( 0, 0, , oSplitter, , , , CLR_WHITE, CLR_WHITE, 1000, ( nAltura410/4 ) * 0.70, .F., .F. )
	oPnlTop:Align := CONTROL_ALIGN_TOP
	oPnlTop:bWhen := {|| !lIncReg .And. !lAltReg}

	//-----------------------------
	// Monta menu lateral esquerdo
	//-----------------------------
	oPnlBtn := TPanel():New( 0, 0, , oPnlTop, , , , , aColors[2], 13, 0, .F., .F. )
	oPnlBtn:Align := CONTROL_ALIGN_LEFT

	oBtnInc  := TBtnBmp():NewBar( "ng_ico_incluir", "ng_ico_incluir", , , , IIf( PermisaoOpc( cRotina, 3 ),;
		{|| SetInclui(), lValid := FieldsToMemory( cAlias, .T. ), RecLockReg( cAlias, .T., oPnlBottom, aNao, bValid, bSave, bInit, oPnlDown, lValid )},;
		bHelpUsu ), , oPnlBtn, , {|| } )
	oBtnInc:cToolTip := STR0034 //"Incluir"
	oBtnInc:Align    := CONTROL_ALIGN_TOP

	oBtnAlt  := TBtnBmp():NewBar( "bpm_ico_editar", "bpm_ico_editar", , , , IIf( PermisaoOpc( cRotina, 4 ),;
		{ || fBusDadAso(), SetAltera(), FieldsToMemory( cAlias, .F. ), RecLockReg( cAlias, .F., oPnlBottom, aNao, bValid, bSave, bInit, oPnlDown )},;
		bHelpUsu ), , oPnlBtn, , {|| ( cAlias )->( !Eof() )} )
	oBtnAlt:cToolTip := STR0035 //"Alterar"
	oBtnAlt:Align    := CONTROL_ALIGN_TOP

	oBtnExc  := TBtnBmp():NewBar( "ng_ico_excluir", "ng_ico_excluir", , , , IIf( PermisaoOpc( cRotina, 5 ),;
		{|| DeleteReg( cAlias, bValid, bSave ), oEnchoice:Refresh() }, bHelpUsu ), , oPnlBtn, , {|| (cAlias)->(!Eof())} )
	oBtnExc:cToolTip := STR0036 //"Excluir"
	oBtnExc:Align    := CONTROL_ALIGN_TOP

	//-----------------------------
	// Adiciona botoes especificos
	//-----------------------------
	For nButton := 1 To Len( aButtons )

		oBtnEsp  := TBtnBmp():NewBar( aButtons[nButton][1], aButtons[nButton][1], , , , aButtons[nButton][2], ,;
			oPnlBtn, , {|| ( cAlias )->(!Eof() )} )
		oBtnEsp:cToolTip := aButtons[nButton][3]
		oBtnEsp:Align    := CONTROL_ALIGN_TOP

	Next nButton


	oPnlCenter := TPanel():New( 0, 0, , oPnlTop, , , , , RGB( 67, 70, 37 ), 1000, ( nAltura410/4 ) * 0.80, .F., .F. )
	oPnlCenter:Align := CONTROL_ALIGN_ALLCLIENT
	oPnlCenter:bWhen := {|| !lIncReg .And. !lAltReg}

	oPnlShow := TButton():New( 002, 002, STR0037, oPnlTop, , 0, 7, , , .F., .T., .F., , .F., , , .F. ) //"Inibir detalhes do registro"
	oPnlShow:bAction := {|x, y| ( oPnlShow:cTitle := IIf( STR0038 $ oPnlShow:cTitle, STR0039, STR0037 ),;
		IIf( STR0038 $ oPnlShow:cTitle, oPnlDown:Show(), oPnlDown:Hide() ) ),;
		oBrowse:SetFocus()} //"Inibir"###"Exibir detalhes do registro"##"Inibir detalhes do registro"
	oPnlShow:SetCSS( "QPushButton{ background-color: #F4F4F4; color: #BEBEBE; font-size: 8px; border: 1px solid #D3D3D3; } " +;
		"QPushButton:Focus{ background-color: #FFFAFA; } " +;
		"QPushButton:Hover{ background-color: #F4F4F4; color: #000000; border: 1px solid #D3D3D3; } " )
	oPnlShow:Align := CONTROL_ALIGN_BOTTOM


	//--------------------------
	// Implementação específica
	//--------------------------
	If cAlias == "TMT"

		//----------------------------
		// Cria Folder com seus dados
		//----------------------------
		oFolderTMT := TFolder():New( 0, 0, {STR0040, STR0041}, , oSplitter, , , , .T., , 0, nAltura410/2 ) //"Diagnóstico"###"Medicamentos"
		oFolderTMT:Align := CONTROL_ALIGN_ALLCLIENT
		oFolderTMT:bWhen := {|| TMT->(!Eof()) .Or. lIncReg}
		oFolderTMT:bSetOption := {|| oBrwTM2:SetFilterDefault( 'xFilial("TM2") == TM2->TM2_FILIAL .And. TM2->TM2_DTCONS == STOD('+;
			ValToSql( TMT->TMT_DTCONS )+') .And. TM2->TM2_HRCONS == '+ValToSql( TMT->TMT_HRCONS )+;
			' .And. TM2->TM2_NUMFIC == '+ValToSql( _cNumFi410 ) ), oBrwTM2:Refresh( .T. ), oBrwTM2:SetFocus()}

		oPnlShow:bAction := {|x, y| (oPnlShow:cTitle := IIf( STR0038 $ oPnlShow:cTitle, STR0039, STR0037 ),;
			IIf( STR0038 $ oPnlShow:cTitle, oFolderTMT:Show(), oFolderTMT:Hide() ) ),;
			oBrowse:SetFocus()} //"Inibir"##"Exibir detalhes do registro"##"Inibir detalhes do registro"##"Inibir"

		oBoxCria := oFolderTMT:aDialogs[1]

		//Tratamento específico para altura do Splitter
		nAltura410 /= 2

		//---------------------------------------
		// Cria dados - Medicamentos Utilizados
		//---------------------------------------
		cFilter2 := Nil
		aNao2 := {"TM2_NUMFIC", "TM2_NOMFIC", "TM2_DTCONS", "TM2_HRCONS"}
		bSave2 := {|lSave| IIf( lSave, NG155ESTQ( IIf( INCLUI, 3, IIf( ALTERA, 4, 5 ) ) ), Nil )}
		bInit2 := {|| LALTMEDIC := !ALTERA}
		bValid2:= Nil
		CreateOption( oFolderTMT:aDialogs[2], "TM2", aNao2, @oBrwTM2, @oEncTM2, STR0042, Nil, cFilter2, bValid2, bSave2, bInit2 ) //"Médicamentos Utilizados"

		//Tratamento específico para altura do Splitter
		nAltura410 *= 2
	Else
		oBoxCria := oSplitter
	EndIf

	//----------------------------------------
	// Panel Pai e Enchoice da parte inferior
	//----------------------------------------
	oPnlDown := TPanel():New( 0, 0, , oBoxCria, , , , , , 0, 800, .F., .F. )
	oPnlDown:bWhen := {|| (cAlias)->(!Eof()) .Or. lIncReg}
	oPnlDown:Align := CONTROL_ALIGN_ALLCLIENT

	oPnlBottom := TPanel():New( 0, 0, , oPnlDown, , , , , , 0, 800, .F., .F. )
	oPnlBottom:Align := CONTROL_ALIGN_ALLCLIENT

	//------------------------------------------
	// Cria Panel com Say de Incluir ou Alterar
	//------------------------------------------
	oPnlAux := TPanel():New( 0, 0, , oPnlDown, , , , , aColors[2], 0, 13, .F., .F. )
	oPnlAux:Align := CONTROL_ALIGN_TOP

	TSay():New( 03, 03, {|| IIf( lIncReg, STR0043, IIf( lAltReg, STR0044, STR0045 ) ) }, oPnlAux, , TFont():New( , , 18, .T., .T. ),;
		, , , .T., aColors[1], CLR_WHITE, 200, 20 ) //"Inclusão"###"Alteração"###"Visualização"

	oEnchoice := MsMGet():New( cAlias, ( cAlias )->( Recno() ), 1, , , , aChoice, , , , , , , oPnlBottom, , , .T., , , .T. )
	oEnchoice:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	//-----------------------------------------
	// Monta Browse da Alias na parte superior
	//-----------------------------------------
	dbSelectArea( cAlias )
	oBrowse := CreateFwBrowse( oPnlCenter, cAlias, aNao, oEnchoice )
	If cAlias == "TNY"
		//---------------------------------
		// Verificação feita para o X3_RELACAO de TNY_HRINIC que utiliza a variavel INCLUI,
		// e quando a ficha médica não possui um atestado será inclusão
		//---------------------------------
		dbSelectArea( cAlias )
		dbSetOrder( 1 ) //TNY_FILIAL+TNY_NUMFIC+DTOS(TNY_DTINIC)+TNY_HRINIC
		SetInclui()
		Inclui := !dbSeek( xFilial( "TNY" ) + _cNumFi410 )
		Altera := !Inclui
	EndIf
	If IsInCallstack( "MDTA076" )

		If cAlias <> "TMT" .And. cAlias <> "TM2"
			//verfica se possui Atendimento
			DbSelectArea( "TMT" )
			DbSetOrder( 2 )
			If dbSeek( xFilial( "TMT" ) + cMedico + DTOS( dDiaAtu ) + cHora )
				If !Empty( Msmm( TMT->TMT_DIASYP ) )
					lBtns := .F. //Só desabilitará os botões se for informado o diagnóstico
				EndIf
			EndIf
		EndIf

		If !lBtns
			If cAlias == "TMT" .Or. cAlias == "TM2"
				oBtnInc:Disable()
			Else
				oBtnInc:Disable()
				oBtnAlt:Disable()
				oBtnExc:Disable()
				If Len( aButtons ) > 0
					oBtnEsp:Disable()
				EndIf
			EndIf
		EndIf
	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} CreateFwBrowse
Cria FwBrowse de acordo com alias e campos informados nos parâmetros

@param oParent, Objeto pai onde será criado
@param cAlias, Alias a verificar campos do dicionario SX3
@param aNao, Vetor contendo campos que nao deverao ser listados
@param oEnchoice, Enchoice a ser atualizado
@param cFilter, Expressão para filtrar o browse

@return oBrowse, objeto que define o browse

@author Vitor Emanuel Batista

@since 07/12/2010
@version MP10
/*/
//---------------------------------------------------------------------
Static Function CreateFwBrowse(oParent, cAlias, aNao, oEnchoice)

	Local oBrowse
	Local oColumn
	Local nCp       := 0
	Local cNomCp    := ''
	Local cTipo     := ''
	Local cContx    := ''
	Local cBrowse   := ''
	Local cPicture  := ''
	Local cTam      := ''
	Local cTipo     := ''
	Local cTitulo   := ''
	Local aCpsTab   := APBuildHeader( cAlias )

	Default aNao := {}

	oParent:nHeight *= 4
	oParent:nWidth 	*= 4

	DEFINE FWBROWSE oBrowse DATA TABLE ALIAS cAlias CHANGE { || ChangeMemoBrw( @oBrowse,cAlias,oEnchoice ) } ; // FILTER FILTERDEFAULT cFilter;
		PROFILEID cAlias+"MDTA410" NO SEEK FILTER OF oParent // NO LOCATE SEEK ORDER {{'1','teste',.T.,.T.}}

	For nCp := 1 To Len( aCpsTab )

		cNomCp   := aCpsTab[ nCp, 2 ]
		cContx   := GetSx3Cache( cNomCp, "X3_CONTEXT" )
		cBrowse  := GetSx3Cache( cNomCp, "X3_BROWSE" )
		cPicture := X3Picture( cNomCp )
		cTam     := GetSx3Cache( cNomCp, "X3_TAMANHO" )
		cTipo    := GetSx3Cache( cNomCp, "X3_TIPO" )
		cTitulo  := Posicione( "SX3", 2, cNomCp, "X3Titulo()" )

		If cBrowse == "S" .And. aScan( aNao, {|x| x == cNomCp} ) == 0
			If cContx != "V"
				If !Empty( GetSx3Cache( cNomCp, "X3_CBOX" ) )
					ADD COLUMN oColumn DATA &("{|| NGRETSX3BOX('"+cNomCp+"',"+cAlias+"->"+cNomCp+")}") OPTIONS {'A','B','C'} ;
						Title cTitulo  PICTURE cPicture SIZE cTam TYPE cTipo Of oBrowse
				Else
					ADD COLUMN oColumn DATA &( "{|| " + cAlias + "->" + cNomCp + "}" ) Title cTitulo PICTURE cPicture SIZE cTam ;
						TYPE cTipo ALIGN IIf( cTipo == "D", 0, IIf( cTipo == "N", 2, 1 ) ) EDIT DETAILS Of oBrowse
				EndIf
			Else
				ADD COLUMN oColumn DATA &("{|| " + AllTrim( GetSx3Cache( cNomCp, "X3_RELACAO" ) ) + "}") Title cTitulo  ;
					PICTURE cPicture SIZE cTam TYPE cTipo Of oBrowse
			EndIf
		EndIf

	Next nCp

	oBrowse:DisableReport()
	oBrowse:DisableConfig()
	dbSelectArea( cAlias )

	ACTIVATE FWBROWSE oBrowse

Return oBrowse

//---------------------------------------------------------------------
/*/{Protheus.doc} CreateQuiz
Cria Folder de Questionário Médico

@param oParent Objeto pai
@param cText Texto apresentado no cabeçalho do Enchoice
@param oBrowse Variavel passada como referencia para o Browse
@author Vitor Emanuel Batista
@since 27/07/2011
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function CreateQuiz( oParent, cText, oBrowse )

	Local cAlias  := "TMI"
	Local oSplitter
	Local oPnlAux
	Local oPnlTop
	Local oPnlBottom
	Local oPnlDown
	Local oPnlBtn
	Local oPnlShow
	Local oBtnInc
	Local oBtnAlt
	Local oBtnExc
	Local oBtnImp
	Local aNao := NGCAMPNSX3( cAlias, {"TMI_DTREAL", "TMI_QUESTI", "TMI_NOMQUE"} )
	Local aChoice := NGCAMPNSX3( cAlias, aNao )
	Local cAliasQry := GetNextAlias()

	If cAlias == "TMY"
		aAdd( aChoice, "TMY_DTPROG" )
	EndIf

	If ValType( oBrowse ) == "O" .And. ValType( oBrowse:oOwner ) == "O"
		Return
	Else
		oParent:FreeChildren()
	EndIf

	//----------------------------------------
	// Cria Panel com Say do titulo do Folder
	//----------------------------------------
	oPnlAux := TPanel():New( 0, 0, , oParent, , , , , aColors[2], 0, 13, .F., .F. )
	oPnlAux:Align := CONTROL_ALIGN_TOP

	TSay():New( 03, 15, {|| cText}, oPnlAux, , TFont():New( , , 18, .T., .T. ), , , , .T., aColors[1], CLR_WHITE, 200, 20 )

	//--------------------------------------------
	// Splitter para dividir o Browse do Enchoice
	//--------------------------------------------
	oSplitter := TSplitter():New( 0, 0, oParent, 0, 0, 1 )
	oSplitter:Align := CONTROL_ALIGN_ALLCLIENT
	oSplitter:SetOrient( 1 )

	oPnlTop := TPanel():New( 0, 0, , oSplitter, , , , CLR_WHITE, CLR_WHITE, 0, (nAltura410/4) * 0.80, .F., .F. )
	oPnlTop:Align := CONTROL_ALIGN_TOP
	oPnlTop:bWhen := {|| !lIncReg .And. !lAltReg}

	//-----------------------------
	// Monta menu lateral esquerdo
	//-----------------------------
	oPnlBtn := TPanel():New( 0, 0, , oPnlTop, , , , , aColors[2], 13, 0, .F., .F. )
	oPnlBtn:Align := CONTROL_ALIGN_LEFT

	oBtnInc  := TBtnBmp():NewBar( "ng_ico_incluir", "ng_ico_incluir", , , , {|| SetInclui(), SetBlackPnl(),;
		RecLockQuiz( cAliasQry, .T., oPnlBottom, oBrowse ), SetBlackPnl( .F. )}, , oPnlBtn, , {|| } )
	oBtnInc:cToolTip := STR0034 //"Incluir"
	oBtnInc:Align    := CONTROL_ALIGN_TOP

	oBtnAlt  := TBtnBmp():NewBar( "bpm_ico_editar", "bpm_ico_editar", , , , {|| SetAltera(), FieldsToMemory( "TMI", .F. ),;
		RecLockQuiz( cAliasQry, .F., oPnlBottom, oBrowse )}, , oPnlBtn, , {|| ( cAliasQry )->( !Eof() )} )
	oBtnAlt:cToolTip := STR0035 //"Alterar"
	oBtnAlt:Align    := CONTROL_ALIGN_TOP

	oBtnExc  := TBtnBmp():NewBar( "ng_ico_excluir", "ng_ico_excluir", , , , {|| IIf( DeleteReg( cAliasQry ),;
		UnLockQuiz( cAlias, 5, oBrowse ), Nil )}, , oPnlBtn, , {|| ( cAliasQry )->( !Eof() )} )
	oBtnExc:cToolTip := STR0036 //"Excluir"
	oBtnExc:Align    := CONTROL_ALIGN_TOP

	oBtnImp  := TBtnBmp():NewBar( "ng_ico_imp", "ng_ico_imp", , , , {|| SetBlackPnl(), MDTIMPTMI(), SetBlackPnl( .F. )},;
		, oPnlBtn, , {|| ( cAliasQry )->( !Eof() )} )
	oBtnImp:cToolTip := STR0026 //"Imprimir"
	oBtnImp:Align    := CONTROL_ALIGN_TOP

	oPnlCenter := TPanel():New( 0, 0, , oPnlTop, , , , , RGB( 67, 70, 37 ), 0, ( nAltura410/4 ) * 0.80, .F., .F. )
	oPnlCenter:Align := CONTROL_ALIGN_ALLCLIENT
	oPnlCenter:bWhen := {|| !lIncReg .And. !lAltReg}

	oPnlShow := TButton():New( 002, 002, STR0037, oPnlTop, , 0, 7, , , .F., .T., .F., , .F., , , .F. ) //"Inibir detalhes do registro"
	oPnlShow:bAction := {|x, y| ( oPnlShow:cTitle := IIf( STR0038 $ oPnlShow:cTitle, STR0039, STR0037 ),;
		IIf( STR0038 $ oPnlShow:cTitle, oPnlDown:Show(), oPnlDown:Hide() ) )} //"Inibir"##"Exibir detalhes do registro"##"Inibir detalhes do registro"##"Inibir"
	oPnlShow:SetCSS( "QPushButton{ background-color: #F4F4F4; color: #BEBEBE; font-size: 8px; border: 1px solid #D3D3D3; } " +;
		"QPushButton:Focus{ background-color: #FFFAFA; } " +;
		"QPushButton:Hover{ background-color: #F4F4F4; color: #000000; border: 1px solid #D3D3D3; } " )
	oPnlShow:Align := CONTROL_ALIGN_BOTTOM

	//----------------------------------------
	// Panel Pai e Enchoice da parte inferior
	//----------------------------------------
	oPnlDown := TPanel():New( 0, 0, , oSplitter, , , , , , 0, 800, .F., .F. )
	oPnlDown:Align := CONTROL_ALIGN_ALLCLIENT

	oPnlBottom := TPanel():New( 0, 0, , oPnlDown, , , , , , 0, 800, .F., .F. )
	oPnlBottom:Align := CONTROL_ALIGN_ALLCLIENT
	oPnlBottom:bWhen := {|| lIncReg .Or. lAltReg }

	//------------------------------------------
	// Cria Panel com Say de Incluir ou Alterar
	//------------------------------------------
	oPnlAux := TPanel():New( 0, 0, , oPnlDown, , , , , aColors[2], 0, 13, .F., .F. )
	oPnlAux:Align := CONTROL_ALIGN_TOP

	TSay():New( 03, 03, {|| IIf( lIncReg, STR0043, IIf( lAltReg, STR0044, STR0045 ) )}, oPnlAux, , TFont():New( , , 18, .T., .T. ), , , ,;
		.T., /*CLR_WHITE*/aColors[1], CLR_WHITE, 200, 20 ) //"Inclusão"##"Alteração"##"Visualização"

	//-----------------------------------------
	// Monta Browse da Alias na parte superior
	//-----------------------------------------
	cQuery := " SELECT TMI_NUMFIC,TMI_DTREAL,TMI_QUESTI "
	cQuery += " FROM " + RetSqlName( "TMI" )
	cQuery += " WHERE TMI_FILIAL = '" + xFilial( "TMI" ) + "' AND "
	cQuery += " D_E_L_E_T_ != '*' AND TMI_NUMFIC = " + ValToSql( _cNumFi410 )
	cQuery += " GROUP BY TMI_NUMFIC,TMI_DTREAL,TMI_QUESTI"

	DEFINE FWBROWSE oBrowse DATA QUERY ALIAS cAliasQry QUERY cQuery INDEXQUERY {'TMI_DTREAL+TMI_QUESTI'} PROFILEID cAlias+"MDTA410" ;
		CHANGE {|| oPnlBottom:FreeChildren(), MDTA145CAD( "TMI", 1, 1, oPnlBottom, cAliasQry, .F. )} FILTER OF oPnlCenter

	ADD COLUMN oColumn DATA {|| StoD( ( cAliasQry )->TMI_DTREAL) } Title NGRETTITULO( 'TMI_DTREAL' ) PICTURE '99/99/9999' SIZE '8' TYPE 'D' ALIGN 0 Of oBrowse
	ADD COLUMN oColumn DATA {|| ( cAliasQry )->TMI_QUESTI } Title NGRETTITULO( 'TMI_QUESTI' ) PICTURE '@!' SIZE '6' TYPE 'C' ALIGN 1 Of oBrowse
	ADD COLUMN oColumn DATA {|| NGSEEK( "TMG", ( cAliasQry )->TMI_QUESTI, 1, 'TMG->TMG_NOMQUE' ) } Title NGRETTITULO( 'TMI_NOMQUE' ) PICTURE '@!' SIZE '40' TYPE 'C' ALIGN 1 Of oBrowse

	oBrowse:SetSeek()
	oBrowse:DisableReport()
	oBrowse:DisableConfig()
	ACTIVATE FWBROWSE oBrowse

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} RecLockQuiz
Inclui ou Altera um registro do Questionário Médico

@param cAlias Alias a verificar campos do dicionario SX3
@param lInclui Identifica se eh inclusao ou alteracao
@param oParent Objeto Pai do MsMGet de inclusao
@param oBrowse Variavel passada como referencia para o Browse
@author Vitor Emanuel Batista
@since 27/07/2011
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function RecLockQuiz( cAlias, lInclui, oParent, oBrowse )

	Local nOpcao := IIf( lInclui, 3, 4 )

	//------------------------------------------------------------
	// Guarda a Tabela, Indice e Registro para retorno no Unlock
	//------------------------------------------------------------
	_aArea410 := (cAlias)->(GetArea())

	//-----------------------------------------------
	// Variaveis de controle de Inclusão e Alteração
	//-----------------------------------------------
	lIncReg := lInclui
	lAltReg := !lInclui

	//-----------------------------------
	// Seta variaveis de INCLUI e ALTERA
	//-----------------------------------
	If lIncReg
		SetInclui()
	Else
		SetAltera()
	EndIf

	//---------------------------------------
	// Desabilita todas as opções de  Folder
	//---------------------------------------
	FolderEnable( .F. )

	//-------------------------------------------------------
	// Destroi com o objeto EnchoiceBar se já estiver criado
	//-------------------------------------------------------
	If Type( "oEnchBar" ) == "O"
		oEnchBar:Free()
	EndIf

	dbSelectArea( "TM0" )
	dbSetOrder( 1 )
	dbGoTo( _nRecno410 )

	oParent:FreeChildren()
	//---------------------------
	// Cria EnchoiceBar no Panel
	//---------------------------
	oEnchBar := MyEnchBar( oParent:oParent, {|| IIf( MDTA145Ok( .T. ), UnLockQuiz( cAlias, nOpcao, oBrowse ), .F. ) },;
		{|| UnLockReg( cAlias, .F. ), oBrwTMI:OnChange() } )

	nRet := MDTA145CAD( "TMI", 1, nOpcao, oParent, cAlias, .F. )
	M->TMI_NUMFIC := _cNumFi410

	If nRet <> 1 .And. lIncReg
		UnLockReg( cAlias, .F. )
		oBrwTMI:OnChange()
		Return
	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} UnLockQuiz
Finaliza processo de inclusao, alteracao ou exclusão do questionário médico

@param cAlias Alias a verificar campos do dicionario SX3
@param nOpcao Opção do processo (3=Incluir;4=Alterar;5=Excluir)
@param oBrowse Variavel passada como referencia para o Browse
@author Vitor Emanuel Batista
@since 28/07/2011
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function UnLockQuiz( cAlias, nOpcao, oBrowse )

	//----------------------------------------------------
	// Grava informações de acordo com função do MDTA145
	//----------------------------------------------------
	MDTA145Grv( nOpcao, 2 )

	//----------------------------------------------------
	// Ajusta Browse para exibir valores corretos
	//----------------------------------------------------
	//TODO Rever, pois está repetida na função MDTA145Grv
	MDTA145INI()

	//------------------------------------
	// Libera variaveis e habilita folder
	//------------------------------------
	If nOpcao <> 5
		UnLockReg( cAlias, .F. )
		//----------------------------------------
		// Faz alterações no conteúdo do FWBrowse
		//----------------------------------------
		If nOpcao == 3
			dbSelectArea( "TMI" )
			dbSetOrder( 1 )
			If dbSeek( xFilial( "TMI" )+M->TMI_NUMFIC+DTOS( M->TMI_DTREAL )+M->TMI_QUESTI )
				RecLock( cAlias, .T. )
				(cAlias)->TMI_NUMFIC := M->TMI_NUMFIC
				(cAlias)->TMI_DTREAL := DTOS( M->TMI_DTREAL )
				(cAlias)->TMI_QUESTI := M->TMI_QUESTI
				MsUnLock()
			EndIf
		EndIf

	EndIf

	//------------------------------------------------------------------
	// Força a atualização e posiciona no primeiro registro do FWBrowse
	//------------------------------------------------------------------
	SetBlackPnl()
	SetBlackPnl( .F. )

	oBrwTMI:Refresh( .T. )
	oBrwTMI:SetFocus()

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} CreateEPI
Cria Folder de EPI

@param oParent Objeto pai
@param cText Texto apresentado no cabeçalho do Enchoice
@author Vitor Emanuel Batista
@since 19/04/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function CreateEPI( oParent, cText )

	Local oPnlAux, oPnlMenu, oBtnAux, oPnlBtn
	Local bSalvar

	aCols   := {}
	aHeader := {}
	n := 1

	dbSelectArea( "SRA" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "SRA" )+_cMatri410 )

	//----------------------------------------
	// Cria Panel com Say do titulo do Folder
	//----------------------------------------
	oPnlMenu := TPanel():New( 0, 0, , oParent, , , , , aColors[2], 0, 13, .F., .F. )
	oPnlMenu:Align := CONTROL_ALIGN_TOP

	TSay():New( 03, 15, {|| cText}, oPnlMenu, , TFont():New( , , 18, .T., .T. ), , , , .T., /*CLR_WHITE*/ aColors[1], CLR_WHITE, 200, 20 )

	//-----------------------------
	// Monta menu lateral esquerdo
	//-----------------------------
	oPnlBtn := TPanel():New( 0, 0, , oParent, , , , , aColors[2], 13, 0, .F., .F. )
	oPnlBtn:Align := CONTROL_ALIGN_LEFT

	oBtnAux  := TBtnBmp():NewBar( "NG_ICO_SALVAR", "NG_ICO_SALVAR", , , , {|| RegToMemory( "SRA", .F. ), SaveEPI( bSalvar ) }, , oPnlBtn,;
		, {|| oGetTNF695:lActive} )
	oBtnAux:cToolTip := STR0063 //"Salvar"
	oBtnAux:Align    := CONTROL_ALIGN_TOP

	oBtnAux  := TBtnBmp():NewBar( "bpm_ico_editar", "bpm_ico_editar", , , , {|| EditEPI()}, , oPnlBtn, , {|| !oGetTNF695:lActive} )
	oBtnAux:cToolTip := STR0035 //"Alterar"
	oBtnAux:Align    := CONTROL_ALIGN_TOP

	oBtnAux  := TBtnBmp():NewBar( "ng_ico_excluir", "ng_ico_excluir", , , , {|| SetBlackPnl(), CancelEPI(), SetBlackPnl( .F. )}, , oPnlBtn,;
		, {|| oGetTNF695:lActive} )
	oBtnAux:cToolTip := STR0050 //"Cancelar"
	oBtnAux:Align    := CONTROL_ALIGN_TOP

	oBtnAux  := TBtnBmp():NewBar( "ng_ico_lgndos", "ng_ico_lgndos", , , , {|| SetBlackPnl(), LegMdtTNF(), SetBlackPnl( .F. )}, , oPnlBtn,;
		, {|| .T.} )
	oBtnAux:cToolTip := STR0015 //"Legenda"
	oBtnAux:Align    := CONTROL_ALIGN_TOP


	oPnlAux := TPanel():New( 0, 0, , oParent, , , , , , 1400, 1200, .F., .F. )
	oPnlAux:Align := CONTROL_ALIGN_ALLCLIENT
	bSalvar := NGFUN695( "SRA", 0, 4, oPnlAux, @oGetTNF695, @oTempTLW )

	If Type( "oGetTNF695" ) != "O"
		oPnlAux:Free()
		oParent:FreeChildren()
		oFolder410:SetOption( __TM0_FOLDER__ )
		Return
	EndIf

	SetAltera()
	n := 1
	oGetTNF695:oBrowse:nAt := n

	//---------------------------------
	// Bloqueia alterações no GetDados
	//---------------------------------
	oGetTNF695:Disable()

	//----------------------------------
	// Variáveis de controle do MDTA695
	//----------------------------------
	aCOLSTNF := aClone( oGetTNF695:aCols )
	aHeaTNF  := aClone( oGetTNF695:aHeader )

	//-------------------------------------------
	// Faz copia de segurança do aCols e aHeader
	//-------------------------------------------
	aOldTNFCols := aClone( oGetTNF695:aCols )
	aOldTNFHead := aClone( oGetTNF695:aHeader )

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} EditEPI
Permite edição dos EPI

@author Vitor Emanuel Batista
@since 28/05/2011
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function EditEPI()

	oGetTNF695:Enable()

	//----------------------------------
	// Variáveis de controle do MDTA695
	//----------------------------------
	aCOLSTNF := aClone( oGetTNF695:aCols )
	aHeaTNF  := aClone( oGetTNF695:aHeader )

	//---------------------------------------
	// Desabilita todas as opções de  Folder
	//---------------------------------------
	FolderEnable( .F. )

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} SaveEPI
Salva as informações de EPI

@param bSave Bloco de código para salvar
@author Vitor Emanuel Batista
@since 28/05/2011
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function SaveEPI(bSave)

	Local nX := 1

	Private lAtuTel := .T.

	dbSelectArea( "SRA" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "SRA" )+_cMatri410 )

	//--------------------------------------------
	// Executa bloco de código para salvar os EPI
	//--------------------------------------------
	MsgRun( STR0064, STR0032, {|| Eval( bSave ) } ) //"Salvando EPI's"##"Aguarde..."

	If lAtuTel
		While nX <= Len( oGetTNF695:aCols )
			If aTail( oGetTNF695:aCols[nX] )
				aDel( oGetTNF695:aCols, nX )
				aSize( oGetTNF695:aCols, Len( oGetTNF695:aCols ) - 1 )
				Loop
			EndIf
			nX++
		EndDo
		If Len( oGetTNF695:aCols ) == 0
			oGetTNF695:aCols := BLANKGETD( oGetTNF695:aHeader )
		EndIf

		//-------------------------------------------
		// Faz copia de segurança do aCols e aHeader
		//-------------------------------------------
		aOldTNFCols := aClone( oGetTNF695:aCols )
		aOldTNFHead := aClone( oGetTNF695:aHeader )

		//---------------------------------
		// Bloqueia alterações no GetDados
		//---------------------------------
		oGetTNF695:Disable()

		//-------------------------------------
		// Habilita todas as opções de  Folder
		//-------------------------------------
		FolderEnable( .T. )

	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} CancelEPI
Cancela as alterações feitas no folder de EPI, voltando as informações
de aCols

@author Vitor Emanuel Batista
@since 28/05/2011
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function CancelEPI()

	If MsgYesNo( STR0065, STR0017 ) //"Atenção"##"Deseja cancelar as alterações realizadas?"
		oGetTNF695:aCols := aClone( aOldTNFCols )
		n := 1

		//---------------------------------
		// Bloqueia alterações no GetDados
		//---------------------------------
		oGetTNF695:Disable()

		oGetTNF695:oBrowse:GoTop()

		//-------------------------------------
		// Habilita todas as opções de  Folder
		//-------------------------------------
		FolderEnable( .T. )
	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} ChangeMemoBrw
Altera valores de memoria do Browse inferior do folder atual

@param cAlias Alias a ser atualizado
@param oEnchoice Objeto Enchoice a ser atualizado
@author Vitor Emanuel Batista
@since 04/03/2011
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function ChangeMemoBrw( oBrowse, cAlias, oEnchoice )

	If !lIncReg .And. ValType( oEnchoice ) == "O"
		FieldsToMemory( cAlias, ( cAlias )->( Eof() ) )
		oEnchoice:SetFocus()
		oEnchoice:Refresh()
		oBrowse:SetFocus()
		oBrowse:Refresh( .F. )
	EndIf

	If cAlias == "TMT
		oBrwTM2:SetFilterDefault( 'xFilial("TM2") == TM2->TM2_FILIAL .And. TM2->TM2_DTCONS == STOD(';
			+ValToSql( TMT->TMT_DTCONS )+') .And. TM2->TM2_HRCONS == '+ValToSql( TMT->TMT_HRCONS )+' .And. TM2->TM2_NUMFIC == ';
			+ValToSql( _cNumFi410 ) )
		oBrwTM2:Refresh( .T. )
		oBrwTM2:SetFocus()
		If Type( "oBrwTMT" ) == "O"
			oBrwTMT:SetFocus()
		EndIf
	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} RecLockReg
Inclui ou Altera um registro para a tabela informada

@param cAlias Alias a verificar campos do dicionario SX3
@param lInclui Identifica se eh inclusao ou alteracao
@param oParent Objeto Pai do MsMGet de inclusao
@param aNao Vetor com os campos que não serão apresentados
@param bValid Indica validação ao confirmar inclusão e alteração do registro
@param bSave Bloco de código para executar operações extras no banco de dados
@param bInit Bloco de código para inicializar variáveis ao incluir, alterar.
@param oPnlDown Painel da parte inferior (para forçar exibição)
@param lValid - Verifica se deseja incluir novo atendimento pelo MDTA076
@author Vitor Emanuel Batista
@since 08/12/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function RecLockReg( cAlias, lInclui, oParent, aNao, bValid, bSave, bInit, oPnlDown, lValid )

	Local nX
	Local aChoice
	Local nRecno  := 0
	Local nOpcao  := IIf( lInclui, 3, 4 )
	Local bError  := ErrorBlock( {|e| Error( e )} )
	Local lExecut := .T.
	Local lGrvVal := .F.
	Local cNovCC  := ""
	Local cNovFun := ""
	Local cNovTar := ""

	Default aNao := {}
	Default lValid := .F.

	If cAlias == "TMT"
		//verifica se deseja incluir outro atendimento
		If IsInCallStack( "MDTA076" )
			lGrvVal := IIf( INCLUI, lValid, .F. )
			lExecut := IIf( ALTERA, .T., lGrvVal )
			If lGrvVal
				TMTDTCONS  := .F.
				TMTHRCONS  := .F.
				TMTCODUSU  := .F.
				M->TMT_HRCONS := cHora
				M->TMT_DTCONS := dDiaAtu
				M->TMT_CODUSU := cMedico
				M->TMT_NOMUSU := Posicione( "TMK", 1, xFilial( "TMK" )+cMedico, "TMK_NOMUSU" )
			EndIf
		EndIf
	EndIf

	//--------------------------------------------
	// Verifica se é possível a execução do Browse
	//--------------------------------------------
	If ValType( oPnlDown ) <> "O" .Or. !oPnlDown:lVisible
		ShowHelpDlg( STR0017, { STR0077 }, 1, { STR0078 }, 1 )
		lExecut := .F.
	EndIf

	If lExecut
		//-----------------------------------------------------------------
		// Limpa variáveis de aCols e aHeader pois pode já estar carregado
		//-----------------------------------------------------------------
		aCols   := {}
		aHeader := {}

		//------------------------------------------------------------
		// Guarda a Tabela, Indice e Registro para retorno no Unlock
		//------------------------------------------------------------
		_aArea410 := (cAlias)->(GetArea())

		//-----------------------------------------------
		// Carrega campos que serão listados no Enchoice
		//-----------------------------------------------
		aChoice := NGCAMPNSX3( cAlias, aNao )
		If cAlias == "TMY"
			aAdd( aChoice, "TMY_DTPROG" )
			If Empty( M->TMY_DTPROG )
				M->TMY_DTPROG := dDataBase
			EndIf
		EndIf
		//-----------------------------------------------
		// Variaveis de controle de Inclusão e Alteração
		//-----------------------------------------------
		lIncReg := lInclui
		lAltReg := !lInclui

		//-----------------------------------
		// Seta variaveis de INCLUI e ALTERA
		//-----------------------------------
		If lIncReg
			SetInclui()
		Else
			SetAltera()
			nRecno := (cAlias)->(Recno())
		EndIf

		//------------------------------------------------------------------
		// Executa bloco de código para inicialização da inclusão/alteração
		//------------------------------------------------------------------
		If ValType( bInit ) == "B"
			BEGIN SEQUENCE
				Eval( bInit )
			END SEQUENCE
		EndIf
		//---------------------------------------                       '
		// Realiza as tratativas necessarias para os folders
		//---------------------------------------
		If cAlias == "TMY" .And. !lInclui
			If !Empty( TMY->TMY_DTEMIS )
				If !MSGYESNO( STR0079, STR0017 )
					lIncReg := .F.
					lAltReg := .F.
					Return .F.
				EndIf
			EndIf
			LEDTCANC   := .T.
			aChoice := { "TMY_CODUSU",;
				"TMY_DESCRI",;
				"TMY_INDPAR",;
				"TMY_DTCANC",;
				"TMY_NATEXA",;
				'TMY_INDEXA',;
				cNovCC,;
				cNovFun,;
				cNovTar }

			If TMY->( FieldPos( "TMY_DTEMIS" ) ) > 0 //Abertura do campo para atender ao eSocial (ASO's de terceiros)
				aAdd( aChoice, "TMY_DTEMIS" )
			EndIf
			If TMY->( FieldPos( "TMY_NOVFUN" ) ) > 0
				aAdd( aChoice, "TMY_NOVFUN" )
			EndIf
			If TMY->( FieldPos( "TMY_NOVTAR" ) ) > 0
				aAdd( aChoice, "TMY_NOVTAR" )
			EndIf
			If TMY->( FieldPos( "TMY_NOVCC" ) ) > 0
				aAdd( aChoice, "TMY_NOVCC" )
			EndIf
			If TMY->( FieldPos( "TMY_ALTURA" ) ) > 0
				aAdd( aChoice, "TMY_ALTURA" )
			EndIf
			If TMY->( FieldPos( "TMY_ELETRI" ) ) > 0
				aAdd( aChoice, "TMY_ELETRI" )
			EndIf
			If TMY->( FieldPos( "TMY_CONFIN" ) ) > 0
				aAdd( aChoice, "TMY_CONFIN" )
			EndIf
			If TMY->( FieldPos( "TMY_TMC" ) ) > 0
				aAdd( aChoice, "TMY_TMC" )
			EndIf
			If TMY->( FieldPos( "TMY_EMPFUT" ) ) > 0
				aAdd( aChoice, "TMY_EMPFUT" )
			EndIf
			If TMY->( FieldPos( "TMY_FILFUT" ) ) > 0
				aAdd( aChoice, "TMY_FILFUT" )
			EndIf
			If TMY->( FieldPos( "TMY_NOVDEP" ) ) > 0
				aAdd( aChoice, "TMY_NOVDEP" )
			EndIf
			If TMY->( FieldPos( "TMY_PLAT" ) ) > 0
				aAdd( aChoice, "TMY_PLAT")
			EndIf
			If TMY->( FieldPos( "TMY_MANCIV" ) ) > 0
				aAdd( aChoice, "TMY_MANCIV")
			EndIf
			If TMY->( FieldPos( "TMY_EXPLO" ) ) > 0
				aAdd( aChoice, "TMY_EXPLO" )
			EndIf
			If TMY->( FieldPos( "TMY_ESCAV" ) ) > 0
				aAdd( aChoice, "TMY_ESCAV" )
			EndIf
			If TMY->( FieldPos( "TMY_SOLDA" ) ) > 0
				aAdd( aChoice, "TMY_SOLDA" )
			EndIf
			If TMY->( FieldPos( "TMY_FRIO" ) ) > 0
				aAdd( aChoice, "TMY_FRIO")
			EndIf
			If TMY->( FieldPos( "TMY_RADIA" ) ) > 0
				aAdd( aChoice, "TMY_RADIA")
			EndIf
			If TMY->( FieldPos( "TMY_PRESS " ) ) > 0
				aAdd( aChoice, "TMY_PRESS ")
			EndIf
			If TMY->( FieldPos( "TMY_OUTROS" ) ) > 0
				aAdd( aChoice, "TMY_OUTROS")
			EndIf
			If TMY->( FieldPos( "TMY_INFLA" ) ) > 0
				aAdd( aChoice, "TMY_INFLA")
			EndIf
		Else
			LEDTCANC   := .F.
		EndIf

		//---------------------------------------
		// Desabilita todas as opções de  Folder
		//---------------------------------------
		FolderEnable( .F. )

		//--------------------------------------------
		// Cria Enchoice para a inclusão ou alteração
		//--------------------------------------------
		oEncIncAlt := MsMGet():New( cAlias, nRecno, nOpcao, , , , aChoice, , , , , , , oParent, , , .T., , , .T. )
		oEncIncAlt:oBox:Align := CONTROL_ALIGN_ALLCLIENT

		//-------------------------------------------------
		// Carrega memória dos campos que não são listados
		//-------------------------------------------------
		For nX := 1 to Len( aNao )
			cCpoAlias := "M->" + aNao[nX]
			cCposTM0  := "M->TM0" + Substr( aNao[nX], 4, 7 )
			If fVldType( cCpoAlias ) != "U" .And. fVldType( cCposTM0 ) != "U"
				&(cCpoAlias) := &cCposTM0
			EndIf
		Next nX

		If ExistBlock( "MDTA4103" )
			ExecBlock( "MDTA4103", .F., .F. )
		EndIf

		//-------------------------------------------------------
		// Destroi com o objeto EnchoiceBar se já estiver criado
		//-------------------------------------------------------
		If Type( "oEnchBar" ) == "O"
			oEnchBar:Free()
		EndIf

		//---------------------------
		// Cria EnchoiceBar no Panel
		//---------------------------
		oEnchBar := MyEnchBar( oParent, { || IIf( ValidRecLock( cAlias, bValid ), UnLockReg( cAlias, .T., bSave ), Nil ) },;
			{ || UnLockReg( cAlias, .F., bSave ) }, cAlias )

		ErrorBlock( bError )
	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fVldType
Valida a Tipagem da variável - Retirada Sonarqube P.O.G.

@param xVariable, Undefined, Valor a ser avaliado

@return Caracter, Indica o tipo do Dado
@author Jackson Machado
@since 12/12/2018
/*/
//---------------------------------------------------------------------
Static Function fVldType( xVariable )
Return Type( xVariable )

//---------------------------------------------------------------------
/*/{Protheus.doc} UnLockReg
Finaliza processo de inclusao ou alteracao

@param cAlias Alias a verificar campos do dicionario SX3
@param lConfirm Identifica se confirmou ou cancelou o processo
@param bSave Bloco de código para executar operações extras no banco de dados
@author Vitor Emanuel Batista
@since 08/12/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function UnLockReg( cAlias, lConfirm, bSave )

	Local nX
	Local cMemory, cField
	Local cBrowse := "oBrw"+cAlias
	Local aArea
	Local bError := ErrorBlock( {|e| Error( e )} )

	//Verifica se está na empresa correta
	If cAlias == "TMY"
		If FindFunction( "MDT200REMP" )
			MDT200REMP() //Retorna para empresa inicial
		EndIf
	EndIf
	//-----------------------------------
	// Seta variaveis de INCLUI e ALTERA
	//-----------------------------------
	If lIncReg
		SetInclui()
	Else
		SetAltera()
	EndIf

	//----------------------------------
	// Grava registro no banco de dados
	//----------------------------------
	If lConfirm
		RecLock( cAlias, lIncReg )
		For nX := 1 To FCount()
			If "FILIAL" $ FieldName( nX )
				cMemory := "xFilial('"+cAlias+"')"
			Else
				If NGCADICBASE( "TMT_HRRETO", "A", "TMT", .F. ) .And. "HRRETO" $ FieldName( nX )
					If At( ":", AllTrim( &( "M->"+FieldName( nX ) ) ) ) == 1
						M->TMT_HRRETO := ""
					EndIf
				EndIf
				
				cMemory := "M->"+FieldName( nX )

				If cMemory == M->TNY_ACIDEN .And. M->TNY_ACIDEN == .T.
					cMemory := Space(6)
				EndIf

			EndIf
			cField  := cAlias+"->"+FieldName( nX )
			Replace &cField. with &cMemory.
		Next nX
		MsUnlock( cAlias )

		//----------------------------------------------------------
		// Se houver controle de SXE/SXF confirma número sequencial
		//----------------------------------------------------------
		If __lSX8
			ConfirmSX8()
		EndIf
	Else
		//----------------------------------------------------------
		// Se houver controle de SXE/SXF cancela número sequencial
		//----------------------------------------------------------
		If __lSX8
			RollBackSX8()
		EndIf

		//------------------------------------------------------------
		// Retorna a Tabela, Indice e Registro para retorno no Unlock
		//------------------------------------------------------------
		If Type( "_aArea410" ) == "A"
			RestArea( _aArea410 )
		EndIf
	EndIf


	//-------------------------------------------------------
	// Execita bloco de código específico para gravar tabela
	//-------------------------------------------------------
	If ValType( bSave ) == "B"
		BEGIN SEQUENCE
			Eval( bSave, lConfirm )
		END SEQUENCE
	EndIf

	//-------------------------------------
	// Habilita todas as opções de  Folder
	//-------------------------------------
	FolderEnable( .T. )

	//-----------------------------------------------
	// Variaveis de controle de Inclusão e Alteração
	//-----------------------------------------------
	lIncReg := .F.
	lAltReg := .F.

	//---------------------------------------
	// Exclui Enchoice de Inclusão/Alteração
	//---------------------------------------
	If Type( "oEncIncAlt" ) == "O"
		oEncIncAlt:oBox:Free()
		oEncIncAlt := Nil
	EndIf

	//------------------------
	// Some com o EnchoiceBar
	//------------------------
	If Type( "oEnchBar" ) == "O"
		oEnchBar:lVisible := .F.
	EndIf

	//-----------------------------------
	// Seta variaveis de INCLUI e ALTERA
	//-----------------------------------
	SetAltera()

	//-----------------
	// Habilita Browse
	//-----------------
	If Type( cBrowse ) == "O"
		aArea := (cAlias)->(GetArea())
		&cBrowse:Refresh()
		RestArea( aArea )

		&cBrowse:Refresh()
		Eval( &cBrowse:bChange )
		&cBrowse:SetFocus()
	EndIf

	ErrorBlock( bError )

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} FolderEnable
Habilita ou desabilita os folders, menos o atual

@param lEnable Indica se Habilita ou Desabilita
@author Vitor Emanuel Batista
@since 18/04/2011
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function FolderEnable(lEnable)

	Local nOption

	For nOption := Len( oFolder410:aPrompts ) To 1 Step -1
		If lEnable .Or. oFolder410:nOption != nOption
			oFolder410:aEnable( nOption, lEnable )
		EndIf
	Next nOption

	//-------------------------------------------
	// Verifica se funcionário possui matrícula
	// para bloquear folder de EPI
	//-------------------------------------------
	If Empty( _cMatri410 ) .And. __TNF_FOLDER__ > 0
		oFolder410:aEnable( __TNF_FOLDER__, .F. )
	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} Error
Faz tratamento de erro.log mostrando em tela

@param e Objeto erro.log
@author Vitor Emanuel Batista
@since 02/02/2012
@version MP10
/*/
//---------------------------------------------------------------------
Function Error(e)

	Local nS
	Local cInfo := e:description  + CRLF

	For nS := 2 to 20
		If !Empty( Procname( nS ) )
			cInfo += 'Called from ' + Padr( Procname( nS ), 20 ) + ' ' + Str( Procline( nS ), 6 ) + CRLF
		EndIf
	Next

	Alert( cInfo )

	Break  // Volta para o RECOVER ou End Sequence

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidRecLock
Verifica se já existe registro com a mesma informação, validando pelo
primeiro indice da Alias passada como parâmetro

@param cAlias Alias para verificar X2_UNICO
@param bValid Indica validação ao confirmar inclusão e alteração do registro
@author Vitor Emanuel Batista
@since 15/04/2011
@version MP10
@return lRet Indica se validacao esta Ok
/*/
//---------------------------------------------------------------------
Static Function ValidRecLock( cAlias, bValid )

	Local aArea  := (cAlias)->(GetArea())
	Local nRecno := (cAlias)->(Recno())
	Local oObj   := &("oEnc"+cAlias)
	Local bError := ErrorBlock( {|e| Error( e )} )
	Local nInd   := 1

	//Chama função para retornar para empresa correta
	If cAlias == "TMY"
		If FindFunction( "MDT200REMP" )
			MDT200REMP()
		EndIf
	EndIf

	//-----------------------------------
	// Seta variaveis de INCLUI e ALTERA
	//-----------------------------------
	If lIncReg
		SetInclui()
	Else
		SetAltera()
	EndIf

	//-------------------------------------------
	// Verifica conteúdo dos campos obrigatórios
	//-------------------------------------------
	If !Obrigatorio( oObj:aGets, oObj:aTela )
		ErrorBlock( bError )
		Return .F.
	EndIf

	//------------------------------------------------------------
	// Verifica pela chave única ou primeiro indice se não existe
	// outro registro com as mesmas informações
	//------------------------------------------------------------
	cUnico := AllTrim( Posicione( "SX2", 1, cAlias, "X2_UNICO" ) )

	//-------------------------------------------------------------
	// Se a chave única do SX2 estiver em branco verifica pelo SIX
	//-------------------------------------------------------------
	If Empty( cUnico )
		dbSelectArea( "SIX" )
		dbSetOrder( 1 )
		dbSeek( cAlias+"1" )
		cUnico := AllTrim( SIX->CHAVE )
	Else
		//------------------------------------------------------
		// Acha o indice respectivo com a chave única (Ex: TMT)
		//------------------------------------------------------
		dbSelectArea( "SIX" )
		dbSetOrder( 1 )
		dbSeek( cAlias )
		While !Eof() .And. SIX->INDICE == cAlias
			If cUnico == AllTrim( SIX->CHAVE )
				nInd := Val( SIX->ORDEM )
			EndIf
			dbSelectArea( "SIX" )
			dbSkip()
		EndDo
	EndIf

	cUnico := StrTran( cUnico, " ", "" ) //Retira todos os espaçamentos
	cUnico := StrTran( cUnico, PrefixoCpo( cAlias )+"_FILIAL", "xFilial('"+cAlias+"')" ) //Adiciona xFilial
	cUnico := StrTran( cUnico, "+DTOS(", "#DTOS(M->" )
	cUnico := StrTran( cUnico, "+", "+M->" )
	cUnico := StrTran( cUnico, "#", "+" )

	dbSelectArea( cAlias )
	dbSetOrder( nInd )
	If dbSeek( &cUnico ) .And. ( INCLUI .Or. nRecno != Recno() )
		Help( " ", 1, "JAEXISTINF" )
		ErrorBlock( bError )
		Return .F.
	EndIf

	//---------------------------------
	// Validações específicas da Alias
	//---------------------------------
	If ValType( bValid ) == "B"
		BEGIN SEQUENCE
			lRet := Eval( bValid )
			RECOVER
			lRet := Nil
		END SEQUENCE

		If ValType( lRet ) <> "L"
			Return .F.
		ElseIf !lRet
			ErrorBlock( bError )
			Return .F.
		EndIf
	EndIf

	//-------------------------------------
	// Seta ALTERA para funcionamento de
	// campos de relacionamento do browse
	//-------------------------------------
	SetAltera()

	RestArea( aArea )

	ErrorBlock( bError )

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} DeleteReg

Pergunta e Exclui registro posicionado na Alias informada no parametro

@param cAlias Alias a verificar campos do dicionario SX3

@author Vitor Emanuel Batista
@since 07/12/2010

@return Logico, Sempre verdadeiro
/*/
//---------------------------------------------------------------------
Static Function DeleteReg(cAlias, bValid, bSave, aNao )

	Local aArea	:= GetArea()

	Local bError := ErrorBlock( {|e| Error( e )} )

	Local cObject := "oBrw"+cAlias

	Local lExclui := .T.
	Local lSit    := .T. 
	Default aNao := {}

	// Ponto de Entrada MDTA4101
	// Valida a exclusao de um registro
	If ExistBlock( "MDTA4101" )

		If !ExecBlock( "MDTA4101", .F., .F., {cAlias} )
			Return .F.
		EndIf

	EndIf

	SetExclui() // Seta variáveis INCLUIR e ALTERA

	// Realiza tratativas especificas por tabela
	If cAlias == "TMY"
		aNao := { "TMX", "TKB", "TMC", "TYD" }
	ElseIf cAlias == 'TNY'
		aNao := { 'TKI', 'TYZ' }
	EndIf

	If !NGVALSX9( cAlias, aNao, .T. ) .Or. !MsgYesNo( STR0046 ) //"Deseja realmente excluir este registro?"
		ErrorBlock( bError )
		Return .F.
	EndIf

	If ValType( bValid ) == "B"

		BEGIN SEQUENCE
			lRet := Eval( bValid )
			RECOVER
			lRet := Nil
		END SEQUENCE

		If ValType( lRet ) <> "L"
			Return .F.
		ElseIf !lRet
			ErrorBlock( bError )
			Return .F.
		EndIf

	EndIf

	//---------------------------------------------------------------
	// TODO: Validações totalmente específicas, padronizar no futuro
	//---------------------------------------------------------------
	If cAlias == "TMJ"

		// Exclui possivel atendimento agendado
		dbselectarea( "TMY" )
		dbsetorder( 3 )
		If !Dbseek( xFilial( "TMY" )+TMJ->TMJ_NUMFIC+DTOS( TMJ->TMJ_DTPROG ) )
			dbSelectArea( "TMJ" )
			RecLock( "TMJ", .F. )
			TMJ->TMJ_DTATEN := CTOD( "  /  /    " )
			MsUnlock( "TMJ" )
		EndIf

	ElseIf cAlias == "TMY"

		If !Empty( TMY->TMY_DTEMIS ) .And. !MsgYesNo( STR0047, STR0017 ) //"ASO ja foi impresso deseja excluir"##"Atenção"
			ErrorBlock( bError )
			Return .F.
		EndIf

	ElseIf cAlias == "TMT"
		// Altera horario do atendimento e outros campos para vazio.
		dbSelectArea( "TMJ" )
		dbSetOrder( 1 ) // TMJ_FILIAL+TMJ_CODUSU+DTOS(TMJ_DTCONS)+TMJ_HRCONS

		If dbSeek( xFilial( "TMJ" ) + M->TMT_CODUSU + DTOS( M->TMT_DTCONS ) + M->TMT_HRCONS )
			RecLock( "TMJ", .F. )
			TMJ->TMJ_DTATEN := CTOD( "  /  /    " )

			If TMJ->( FieldPos( "TMJ_HRCHGD" ) ) > 0
				TMJ->TMJ_HRCHGD := ""
				TMJ->TMJ_HRSAID := ""
			EndIf

			MsUnlock( "TMJ" )
		EndIf

	EndIf

	// Executa bloco de código específico para gravar tabela
	If ValType( bSave ) == "B"

		BEGIN SEQUENCE
			Eval( bSave, .T. )
		END SEQUENCE

	EndIf

	// Exclui registro posicionado
	dbSelectArea( cAlias )

	If cAlias == "TM0" //Caso for exclusão de Ficha Médica, posiciona no registro
		dbSetOrder( 1 )
		dbSeek( xFilial( "TM0" ) + M->TM0_NUMFIC )
	EndIf

	// Verifica se possui CID complementar antes de excluir o registro
	If cAlias == 'TMT'

		dbSelectArea( 'TKJ' )
		dbSetOrder( 1 )
		dbGoTop()
		If dbSeek( xFilial( 'TKJ' ) + M->TMT_NUMFIC )

			lExclui := .F.
			MsgStop( STR0103, STR0017 )

		EndIf

	EndIf

	If cAlias == 'TNY'
		lSit := MDT685COMM( oModel, 5, .F. )
		If !lSit
			lExclui := .F.
		EndIf
	EndIf

	If lExclui

		RecLock( cAlias, .F. )
		( cAlias )->( dbDelete() )
		( cAlias )->( MsUnLock() )

	EndIf

	// Atualiza objeto e vai para primeira linha
	If Type( cObject ) == "O"
		&(cObject):Refresh()
		&(cObject):GoTop()
		Eval( &(cObject):bChange ) // Força a atualização conforme onChange do FwBrowse
		&(cObject):Refresh()
	EndIf

	ErrorBlock( bError )

	RestArea( aArea )

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MyEnchBar
Cria Barra superior com botões disponíveis, possibilitando ser filha de Panels
e nao somente de Dialogs, como a função EnchoiceBar.

@author Vitor Emanuel Batista
@since 01/03/2011

@param oParent, Objeto, Pai.
@param bOk, Bloco de código, Executado ao clicar sobre o botao de confirmar.
@param bCancel, Bloco de código, Executado ao clicar sobre o botao de cancelar.

@return oBar, Objeto, Barra com os botoes.
/*/
//---------------------------------------------------------------------
Static Function MyEnchBar( oParent, bOk, bCancel, cAlias )

	Local oBar, oBtnOk, oBtnCan
	Local oBtn
	Local nBar := 0
	Local oWalkThru

	DEFINE BUTTONBAR oBar SIZE 25, 25 3D TOP OF oParent

	oBar:nGroups += 8

	DEFINE BUTTON oBtn RESOURCE "S4WB008N" OF oBar GROUP ACTION Calculadora() TOOLTIP STR0048 PROMPT "" // "Calculadora..."
	oBtn:cDefaultAct:= STR0048 //"Calculadora..."
	DEFINE BUTTON oBtn RESOURCE "impressao" OF oBar GROUP ACTION OurSpool() TOOLTIP "Spool" PROMPT "" // "Impressao"
	oBtn:cDefaultAct:= "Spool"
	DEFINE BUTTON oBtn RESOURCE "WalkThrough" OF oBar GROUP ACTION (oWalkThru := _TWalkThru():New( Alias() ), oWalkThru:Execute() ) TOOLTIP "WalkThru" PROMPT ""
	oBtn:cDefaultAct:= "WalkThru" // WalkThru

	// Todas as rotinas que contenham CID complementar
	If cAlias == 'TMT' .Or. cAlias == 'TNY' .Or. cAlias == 'TNC'

		DEFINE BUTTON oBtn RESOURCE 'ng_ico_ioscom' OF oBar GROUP ACTION fCidCom( cAlias ) TOOLTIP 'CID Complementar' PROMPT ''
		oBtn:cDefaultAct:= 'CID Complementar'

	EndIf

	DEFINE BUTTON oBtnOk RESOURCE "OK" OF oBar GROUP ACTION ( lOk:=SafeEval( bOk ), EvalRetOK( lOK, nBar ) ) TOOLTIP "Ok" PROMPT "" // Ok

	DEFINE BUTTON oBtnCan RESOURCE "CANCEL" OF oBar ACTION Eval( bCancel ) TOOLTIP STR0050 PROMPT "" // "Cancelar"

	SetKEY( K_CTRL_O, {|| oBtnOk:Click() } )
	SetKEY( K_CTRL_X, {|| oBtnCan:Click()} )

Return oBar

//---------------------------------------------------------------------
/*/{Protheus.doc} RetCodigoFolder
Retorna o código padrão da alias de acordo com o número do folder

@param nOption Número do folder
@author Vitor Emanuel Batista
@since 14/09/2011
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function RetCodigoFolder(nOption)

Return aRestricao[aScan( aRestricao, {|x| x[__OPCAO__] == nOption} )][__CODIGO__]
//---------------------------------------------------------------------
/*/{Protheus.doc} ChangeFolder
Valida a alteração de Folders, pois nao será possível alterar de Folder
caso o registro do Folder atual esteja sendo Incluido ou Alterado

@param nCurrent Número do folder atual
@param nOption Número do folder clicado
@author Vitor Emanuel Batista
@since 02/03/2011
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function ChangeFolder( nCurrent, nOption )

	Local lInclui :=.F.
	Local cFilter
	Local cFilerAlter := ''
	Local oBrowse

	//----------------------------------------------------------------------------------------
	// Validação para dar Free em objetos, não ocorrendo erro de Maximum number of components
	//----------------------------------------------------------------------------------------
	If RetCodigoFolder( nCurrent ) == __TNF_FOLDER__ .Or. RetCodigoFolder( nCurrent ) ==  __TMI_FOLDER__ .Or.;
			RetCodigoFolder( nCurrent ) ==  __TMT_FOLDER__ .Or. RetCodigoFolder( nCurrent ) ==  __TNC_FOLDER__ .Or.;
			RetCodigoFolder( nOption ) ==  __TMT_FOLDER__ .Or. RetCodigoFolder( nOption ) ==  __TNC_FOLDER__

		If RetCodigoFolder( nCurrent ) == __TNF_FOLDER__
			//---------------------------------------------------------
			// Faz copia de segurança do aCols e aHeader do folder EPI
			//---------------------------------------------------------
			aOldTNFCols := aClone( aCols )
			aOldTNFHead := aClone( aHeader )
		EndIf

		//-------------------------------------------------------
		// Exclui objetos para não dar estouro de Maximum number
		//-------------------------------------------------------
		If RetCodigoFolder( nCurrent ) != __TM0_FOLDER__
			oFolder410:aDialogs[nCurrent]:FreeChildren()
		EndIf

	EndIf

	//------------------------------------
	// Cria Opjetos do folder selecionado
	//------------------------------------
	CreateFolder( nOption )

	//Seta F12 vazio
	SetKey( VK_F12, { | | } )

	If RetCodigoFolder( nOption ) == __TMJ_FOLDER__
		cFilter := ValToSql( xFilial( "TMJ" ) )+' == TMJ->TMJ_FILIAL .And. TMJ->TMJ_NUMFIC == '+ValToSql( _cNumFi410 )
		oBrowse := oBrwTMJ
	ElseIf RetCodigoFolder( nOption ) == __TMN_FOLDER__
		dbSelectArea( "TMN" )
		cFilter := ValToSql( xFilial( "TMN" ) )+' == TMN->TMN_FILIAL .And. TMN->TMN_NUMFIC == '+ValToSql( _cNumFi410 )
		oBrowse := oBrwTMN
	ElseIf RetCodigoFolder( nOption ) == __TMF_FOLDER__
		//-------------------
		// Filtra Restricao
		//-------------------
		dbSelectArea( "TMF" )
		cFilter := ValToSql( xFilial( "TMF" ) )+' == TMF->TMF_FILIAL .And. TMF->TMF_NUMFIC == '+ValToSql( _cNumFi410 )
		oBrowse := oBrwTMF
	ElseIf RetCodigoFolder( nOption ) == __TNA_FOLDER__
		//-------------------
		// Filtra Doencas
		//-------------------
		dbSelectArea( "TNA" )
		cFilter := ValToSql( xFilial( "TNA" ) )+' == TNA->TNA_FILIAL .And. TNA->TNA_NUMFIC == '+ValToSql( _cNumFi410 )
		oBrowse := oBrwTNA
	ElseIf RetCodigoFolder( nOption ) == __TM5_FOLDER__
		//-------------------
		// Filtra Exames
		//-------------------
		dbSelectArea( "TM5" )
		cFilter := ValToSql( xFilial( "TM5" ) )+' == TM5->TM5_FILIAL .And. TM5->TM5_NUMFIC == '+ValToSql( _cNumFi410 )
		oBrowse := oBrwTM5
	ElseIf RetCodigoFolder( nOption ) == __TMY_FOLDER__
		//-------------------
		// Filtra ASO's
		//-------------------
		dbSelectArea( "TMY" )
		cFilter := ValToSql( xFilial( "TMY" ) )+' == TMY->TMY_FILIAL .And. TMY->TMY_NUMFIC == '+ValToSql( _cNumFi410 )
		oBrowse := oBrwTMY
	ElseIf RetCodigoFolder( nOption ) == __TNY_FOLDER__
		//-------------------
		// Filtra Atestado
		//-------------------
		dbSelectArea( "TNY" )
		cFilter := ValToSql( xFilial( "TNY" ) )+' == TNY->TNY_FILIAL .And. TNY->TNY_NUMFIC == '+ValToSql( _cNumFi410 )
		oBrowse := oBrwTNY
	ElseIf RetCodigoFolder( nOption ) == __TNC_FOLDER__
		//-------------------
		// Filtra Acidentes
		//-------------------
		dbSelectArea( "TNC" )
		cFilter := ValToSql( xFilial( "TNC" ) )+' == TNC->TNC_FILIAL .And. TNC->TNC_NUMFIC == '+ValToSql( _cNumFi410 )
		oBrowse := oBrwTNC
	ElseIf RetCodigoFolder( nOption ) == __TMT_FOLDER__
		//-------------------
		// Filtra Diagnósticos Médicos
		//-------------------
		dbSelectArea( "TMT" )
		//Se for MDTA076 dá a opção de traz somente os diagnósticos do funcionário selecionado do dia do atendimento
		If IsInCallStack( "MDTA076" )
			cFilerAlter := ValToSql( xFilial( "TMT" ) ) + ' == TMT->TMT_FILIAL .And. DTOS(TMT->TMT_DTCONS) == ' + ValToSql( dDiaAtu ) +;
				'.And. TMT->TMT_NUMFIC == ' + ValToSql( _cNumFi410 )
		EndIf

		cFilter := ValToSql( xFilial( "TMT" ) ) + ' == TMT->TMT_FILIAL .And. TMT->TMT_NUMFIC == ' + ValToSql( _cNumFi410 )
		oBrowse := oBrwTMT
	ElseIf RetCodigoFolder( nOption ) == __TL9_FOLDER__
		//-------------------
		// Filtra Vacinas
		//-------------------
		dbSelectArea( "TL9" )
		cFilter  := ValToSql( xFilial( "TL9" ) )+' == TL9->TL9_FILIAL .And. TL9 ->TL9_NUMFIC == '+ValToSql( _cNumFi410 )
		oBrowse := oBrwTL9
	ElseIf RetCodigoFolder( nOption ) == __TNF_FOLDER__
		If Type( "oGetTNF695" ) == "O"
			//--------------------------------------------------------
			// Faz retorno dos dados de aCols e aHeader por segurança
			//--------------------------------------------------------
			aCols   := aClone( aOldTNFCols )
			aHeader := aClone( aOldTNFHead )

			RegToMemory( "SRA", .F. )
			oGetTNF695:oBrowse:SetFocus()
			oGetTNF695:oBrowse:Refresh()
		EndIf
	ElseIf RetCodigoFolder( nOption ) == __TMI_FOLDER__
		SetKey( VK_F12, { | | MDT145OBD( "MDT145" )} )
	EndIf

	If ValType( oBrowse ) == "O"

		If !Empty( cFilerAlter )
			oBrowse:AddFilter( STR0092, cFilerAlter, .F., .T. ) //'Diagnósticos de Hoje'
		EndIf

		If oBrowse:GetFilterDefault() != cFilter
			oBrowse:SetFilterDefault( cFilter )
		EndIf

		oBrowse:Refresh()
		oBrowse:OnChange()
		oBrowse:SetFocus()

	EndIf

	dbSelectArea( "TM0" )
	dbSetOrder( 1 )
	dbGoTo( _nRecno410 )
	Set Filter To TM0->TM0_FILIAL == xFilial( "TM0" ) .And. TM0->TM0_NUMFIC == _cNumFi410

	//---------------------------------
	// Carrega dados na memoria da TM0
	//---------------------------------
	FieldsToMemory( "TM0", lInclui )

	RegToMemory( "TM0", .F. )
	oEncTM0:Refresh()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} BuildFilter
Cria filtro de acordo com a Alias passada como parâmetro

@param cAlias Alias do filtro
@author Vitor Emanuel Batista
@since 15/04/2011
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function BuildFilter(cAlias)

	Local cFilter := (cAlias)->( dbFilter() ) //Guarda a expressao atual para ser usada no botão Cancelar da tela de filtro

	cFilter := BuildExpr( cAlias, , cFilter, .F. )

	dbSelectArea( cAlias )
	Set Filter To
	FilBrowse( cAlias, {}, cFilter )//Filtra o browser

	//Posiciona no topo para que ocorra corretamente a atualizacao
	//das informações do funcionario depois de mudancas de filtro
	If ( cAlias )->( BoF() ) .Or. ( cAlias )->( EoF() )
		( cAlias )->( dbGoTop() )
	EndIf

	FieldsToMemory( cAlias, .F. )//Atualiza a ficha e as informações do func.

	ChangeTM0( oNomeFun1, oNomeFun2 ) //Atualiza o nome do funcionário (superior)

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} SetBlackPnl
Função que cria painel escuro transparente, utilizado ao exibir novas
dialogs sobre a Dialog

@param lVisible Indica se deve mostrar o painel ou nao
@author Vitor Emanuel Batista
@since 27/04/2011
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function SetBlackPnl(lVisible)

	Default lVisible := .T.

	If lVisible
		oBlackPnl:nWidth  := 2000 //::nWidth
		oBlackPnl:nHeight := 2000 //::nHeight
		oBlackPnl:Show()
	Else
		oBlackPnl:Hide()
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} CloseRecord
Fecha com o registro da Ficha Médica e volta para o browse com todas as
fichas

@author Vitor Emanuel Batista
@since 07/12/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function CloseRecord()

	Local nObject
	Local nX

	//---------------------------------------------
	// Seta opção do folder para o enchoice da TM0
	//---------------------------------------------
	oFolder410:SetOption( __TM0_FOLDER__ )

	//---------------------------------------
	// Desabilita todas as opções de  Folder
	//---------------------------------------
	FolderEnable( .F. )
	For nObject := 1 To Len( oFolder410:aDialogs )
		If ValType( oFolder410:aDialogs[nObject] ) == "O" .And. __TM0_FOLDER__ != nObject
			oFolder410:aDialogs[nObject]:FreeChildren()
		EndIf
	Next nObject

	//-----------------------------------
	// Libera botoes nao mais utilizados
	//-----------------------------------
	oBtnLgd:Show()
	oBtnFilt:Show()
	oBtnIncFic:Show()
	oBtnAltFic:Show()
	oBtnExcFic:Show()
	oPnlLeft:Show()
	oPnlShow:Show()

	If !lPyme
		oBtnConh:Show()
	EndIf

	oBtnSavFic:Hide()
	oBtnCanFic:Hide()
	For nX := 1 To Len( aButtonTM0 )
		&("oBtnFic" + cValToChar( nX )):Hide()
	Next nX
	oBtnQuit:Hide()

	//----------------------------
	// Destroi com Panel esquerdo
	//----------------------------
	oPnlTM0:Hide()

	//--------------------------------------------------
	// Variável de controle para o Prestador de Serviço
	//--------------------------------------------------
	If lSigaMdtPS
		dbSelectArea( "SA1" )
		dbSetOrder( 1 )
		Set Filter To
	EndIf

	//----------------------------
	// Limpa filtro na tabela SRA
	//----------------------------
	dbSelectArea( "SRA" )
	dbSetOrder( 1 )
	Set Filter To

	//----------------------------
	// Limpa filtro na tabela TM0
	//----------------------------
	dbSelectArea( "TM0" )
	dbSetOrder( 1 )
	Set Filter To
	FilBrowse( "TM0", {}, _cFilter410 )//Filtra o browser de acordo com a expressão anterior a abertura da ficha

	dbGoTo( _nRecno410 )
	oBrwTM0:Show()

	FieldsToMemory( "TM0", .F. )
	oEncTM0:Disable()
	oEncTM0:Refresh()
	oBrwTM0:SetFocus()

	//------------------------------------------------
	// Variável de controle do Número da Ficha Médica
	//------------------------------------------------
	cFilAnt	   := _cFil410
	cFilAsoOld := _cFil410
	_cNumFi410 := Space( Len( TM0->TM0_NUMFIC ) )
	_cMatri410 := Space( Len( TM0->TM0_MAT ) )

	//-----------------------------------------------
	// Variaveis de controle de Inclusão e Alteração
	//-----------------------------------------------
	lIncReg := .F.
	lAltReg := .F.

	//--------------------------------------------------
	// Variável de controle para o Prestador de Serviço
	//--------------------------------------------------
	cCliMdtPs := Space( Len( SA1->A1_COD+SA1->A1_LOJA ) )

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} FieldsToMemory
Altera memória dos campos de uma alias

@param cAlias Indica a Alias dos campos a serem carregados
@param lInclui Indica se será inclusão ou não, carrendo em branco
@author Vitor Emanuel Batista
@since 13/09/2011
@version MP10
@return bool
/*/
//---------------------------------------------------------------------
Static Function FieldsToMemory( cAlias, lInclui )

	Local aArea    := GetArea()
	Local lExecut  := .T.
	Local nCp      := 0
	Local cNomCp   := ''
	Local cRealc   := ''
	Local cTipo    := ''
	Local aCpsTab
	Local aAreaTM0

	aCpsTab := APBuildHeader( cAlias )
	aAreaTM0 := TM0->(GetArea())

	If cAlias == "TMT"
		//Verifica se deseja incluir outro atendimento
		If IsInCallStack( "MDTA076" )
			lExecut := IIf( lInclui, MDT410DIAG(), .T. )
		EndIf

	EndIf

	If IsInCallStack( 'MDTA076' )
		dbSelectAreA( 'TM0' )
		dbSetOrder( 1 ) // TM0_FILIAL+TM0_NUMFIC
		dbSeek( xFilial( 'TM0' ) + _cNumFi410 )
	EndIf

	If lExecut
		&( "M->" + cAlias + "_FILIAL" ) := &( cAlias + "->" + cAlias + "_FILIAL" )
		For nCp := 1 To Len( aCpsTab )

			cNomCp   := aCpsTab[ nCp, 2 ]
			cContx   := GetSx3Cache( cNomCp, "X3_CONTEXT" )
			cRealc   := GetSx3Cache( cNomCp, "X3_RELACAO" )
			cTipo    := GetSx3Cache( cNomCp, "X3_TIPO" )

			If "_NUMFIC" $ cNomCp .And. !Empty( _cNumFi410 )
				&("M->"+cNomCp) := _cNumFi410
			ElseIf "_MAT   " $ cNomCp .And. !Empty( _cMatri410 )
				&("M->"+cNomCp) := _cMatri410
			ElseIf "TM0_DESCRI" $ cNomCp .And.  FindFunction( "MDTAHIS" )
				MDTAHIS( .F. )
				&("M->"+cNomCp) := TM0->TM0_DESCRI
			ElseIf aScan( aCampos, { | x | x[ 3 ] == AllTrim( cNomCp ) } ) > 0 // Caso seja um campo memo do diagnóstico
				cRealc := StrTran( cRealc, "M->", "TMT->" ) // Substitui a memória para execução do inicialzador
				&("M->"+cNomCp) := InitPad( cRealc )
			Else //If X3USO(X3_USADO)
				If cContx <> "V"
					If !lInclui
						&("M->"+cNomCp) := &(cAlias+"->"+cNomCp)
					Else
						If cTipo == "C"
							&("M->"+cNomCp) := Space( TamSX3( cNomCp )[1] )
						ElseIf cTipo == "D"
							&("M->"+cNomCp) := SToD( Space( 8 ) )
						ElseIf cTipo == "N"
							&("M->"+cNomCp) := 0
						ElseIf cTipo == "M"
							&("M->"+cNomCp) := ""
						EndIf

						If !Empty( cRealc )
							&( "M->"+cNomCp ) := InitPad( cRealc )
						EndIf
					EndIf
				Else
					If !Empty( cRealc )
						&( "M->"+cNomCp ) := InitPad( cRealc )
					EndIf
				EndIf

			EndIf

		Next nCp

	EndIf

	RestArea( aArea )
	RestArea( aAreaTM0 )

Return lExecut

//---------------------------------------------------------------------
/*/{Protheus.doc} RetPermission
Retorna as permissões de acesso as rotinas no Folder

@author Vitor Emanuel Batista
@since 14/09/2011
@version MP10
@return array
/*/
//---------------------------------------------------------------------
Static Function RetPermission()

	Local nOption, nRotina

	For nOption := 1 To Len( aRestricao )
		For nRotina := 1 To Len( aRestricao[nOption][__ROTINAS__] )
			If MPUserHasAccess( aRestricao[nOption][__ROTINAS__][nRotina], 2, , .F., .F. )
				aRestricao[nOption][__HABILITADO__] := .T.
			EndIf
		Next nRotina
	Next nOption

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PermisaoOpc
Retorna as permissões de acesso das opções do menu das rotinas dos
Folders

@type    function
@author  Julia Kondlatsch
@since   22/08/2019
@sample  PermisaoOpc( "MDTA155A", 5 )

@param   cRotina, Caractere, Nome do fonte
@param   nOpc, Numérico, Opção do menu

@return  Lógico, Verdadeiro quando o usuário possuir permissão de
acesso a rotina e opção definidas.
/*/
//-------------------------------------------------------------------
Static Function PermisaoOpc( cRotina, nOpc )

	Local lRet := .T.

	If cRotina <> 'MDTA410'
		lRet := MPUserHasAccess( cRotina, nOpc, , .F., .F. )
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fOpeFicha

Executa a inclusao / alteracao / exclusao da ficha medica

@author  Guilherme Benkendorf
@since   01/07/2015

@sample  fOpeFicha (.T.)

@param   lConrfirm, Logico, Determina qual botão foi clicado,
                            confirmar ou cancelar

@return  lRet, Logico, Determina se confirma as alterações
/*/
//-------------------------------------------------------------------
Static Function fOpeFicha( lConfirm )

	Local lRet := .T.
	Local nOpcTM0 := IIf( Inclui, 3, IIf( Altera, 4, 5 ) )

	// Variaveis para verificação da função CHKTA005
	Private cFichaGrv := Space( Len( TM0->TM0_MAT ) )
	Private cDepenGrv := Space( Len( TM0->TM0_NUMDEP ) )
	Private cSetorGrv := Space( Len( TM0->TM0_CC ) )
	Private cFuncaGrv := Space( Len( TM0->TM0_CODFUN ) )
	Private cCliMdtSv := ""

	Default lConfirm := .T.

	If lConfirm
		lRet := fValidTM0( nOpcTM0 )

		If nOpcTM0 = 4
			// Verificação do parametro MV_NG2ATM0, questiona a confirmação da alteração
			lRet := MDTA005Atm0()
		EndIf

	EndIf

	// Grava Ficha
	If lRet

		// Operações de inclusão e alteração realiza pela UnLockReg
		If nOpcTM0 <> 5
			UnLockReg( "TM0", lConfirm )

			If lConfirm
				_nRecno410 := TM0->(Recno())
			EndIf

		EndIf

		If FindFunction( "MDT005Ope" )
			MDT005Ope( nOpcTM0, lConfirm )
		EndIf

	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fValidTM0
Limpa registros de memória do sistema.

@author Guilherme Benkendorf
@since 18/06/2015
@version MP110/MP112
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fValidTM0( nOpcTM0 )

	Local lRet  := .T.
	Local aNao  := {}

	Default nOpcTM0 := 3

	If nOpcTM0 == 5

		If !Empty( M->TM0_MAT )
			aNao := {"TKD"}
		EndIf

		lRet := DeleteReg( "TM0", , , aNao )

		If lRet
			_cNumFi410 := TM0->TM0_NUMFIC
			_cMatri410 := TM0->TM0_MAT
			_nRecno410 := TM0->( Recno() )
		EndIf

	Else

		If nOpcTM0 == 4
			cFichaGrv := TM0->TM0_MAT
			cDepenGrv := TM0->TM0_NUMDEP
			If lSigaMdtPs
				cSetorGrv := TM0->TM0_CC
				cFuncaGrv := TM0->TM0_CODFUN
			EndIf
		ElseIf nOpcTM0 == 3
			cCliMdtSv := SA1->A1_COD+SA1->A1_LOJA
		EndIf

		lRet := CHKTA005()

		If lRet
			lRet := Obrigatorio( oEncFun:aGets, oEncFun:aTela )
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} VariableTM0
Cria variaveis nas "Ações Relacionadas" na inclusão\alteração da ficha
médica

@author Guilherme Benkendorf
@since 13/07/2015
@version MP110/MP112
@return Nil
/*/
//---------------------------------------------------------------------
Static Function VariableTM0()

	Local nCont := 0

	For nCont := 1 To Len( aButtonTM0 )

		_SetOwnerPrvt( "oBtnFic" + cValToChar( nCont ), Nil )

	Next nCont

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fButtonTM0
Cria o array, conforme a estrutura do clique da direita, para incluir
nas "Ações Relacionadas" na inclusão\alteração da ficha médica

@author Guilherme Benkendorf
@since 13/07/2015
@version MP110/MP112
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fButtonTM0()

	Local aButtonAux := {}
	Local aRClickTM0 := NGRIGHTCLICK( "MDTA005" )

	aAdd( aButtonAux, { STR0082, { || Mdta410Tar() }, "NG_ICO_ALT_FMR_M", TM0_BTN_TAR } )//"Relacionar Tarefas"

	If lBiometria
		aAdd( aButtonAux, { STR0083, { || MDTRegBio() },;
			 "ng_ico_biometria.png", TM0_BTN_BIO } )//"Biometria"
	EndIf

	aEval( aRClickTM0, { | x | aAdd( aButtonAux, { x[1], &( "{||" + x[2] + "}" ), IIf( Empty( x[3] ),;
		"ng_ico_ferram.png", x[3] ), TM0_BTN_TQD } ) } )

Return aButtonAux

//-------------------------------------------------------------------
/*/{Protheus.doc} Mdta410Tar
Cadastro de tarefas do funcionário ou candidato

@author Gabriel Sokacheski
@since 14/02/2023

/*/
//-------------------------------------------------------------------
Function Mdta410Tar()

    If !Empty( M->TM0_MAT ) // Tarefas do funcionário
        FWExecView( Nil, 'mdta007b', 4 )
    Else // Tarefas do candidato
        FWExecView( Nil, 'mdta092', 4 )
    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT410Exit
Limpa registros de memória do sistema.

@author Guilherme Benkendorf
@since 18/06/2015
@version MP112
@return Nil
/*/
//---------------------------------------------------------------------
Static Function MDT410Exit()

	Local lRet := .T.

	lRet := MsgYesNo( STR0076, STR0017 )//"Deseja realmente sair?"###"Atenção"

	If lRet
		DbSelectArea( "TM0" )
		Set Filter To
		DbSelectArea( "SRA" )
		Set Filter To
		dbSelectArea( 'TMT' )
		Set Filter To

		EndFilBrw( 'TM0' )
		EndFilBrw( 'TMT' )

		//Realiza a exclusão da tabela temporária caso esteja ativa
		If ValType( oTempTLW ) == "O" .And. ;
				Select( oTempTLW:GetAlias() ) > 0
			oTempTLW:Delete()
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT410DIAG
Verifica se foi realizado o atendimento do agendamento selecionado

@type function

@source MDTA410.prw

@author Jean Pytter da costa
@since 25/05/2016

@param

@sample MDT410DIAG()

@return Logico, Indica se todas validações estão corretas.
/*/
//---------------------------------------------------------------------
Function MDT410DIAG()

	Local lRet := .T.

	dbSelectArea( "TMJ" )
	dbSetOrder( 1 )
	If dbSeek( xFilial( "TMJ" ) + cMedico + DtoS( dDiaAtu ) + cHora )
		If !Empty( TMJ->TMJ_DTATEN )
			If !MsgYesNo( STR0084, STR0017 )//"O funcionário já foi atendido. Deseja continuar ?"
				lRet := .F.
			EndIf
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fOrderFic
Ordena browse com os registros de ficha médica, de acordo com a coluna
selecionada.
@type  Static Function
@author Bruno Lobo de Souza
@since 24/08/18
@param oOwner, object, instância do browse que será atualizado
@param nCol, numeric, numero da coluna selecionada
@return bollean, sempre verdadeiro
/*/
//---------------------------------------------------------------------
Static Function fOrderFic(oOwner, nCol)

	dbSelectArea( "TM0" )
	If nCol == 2
		dbSetOrder( 1 )
	ElseIf nCol == 3
		dbSetOrder( 2 )
	EndIf
	oOwner:Refresh()
	oOwner:GoTop()

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA410DOC
Amarração no Banco de conhecimento

@param oParent Objeto pai
@author Milena Leite de Oliveira
@since 28/01/2020
@return Nil
/*/
//---------------------------------------------------------------------
Function MDTA410DOC()

	Local nOld := n

	n := 1

	MsDocument( "TM0", TM0->( Recno() ), 4 )

	n := nOld

Return Nil
//---------------------------------------------------------------------
/*/{Protheus.doc} fLegenda
Legenda da Ficha Médica

@author Milena Leite de Oliveira
@since 12/02/2020
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fLegenda()

	Local aLegenda := {}

	If FindFunction( "GpeGetLegend" )
		aLegenda := GpeGetLegend()

		aAdd( aLegenda, { "BR_BRANCO", OemToAnsi( "Candidato" ) } )

		BrwLegenda( OemToAnsi( cCadastro ),; //Titulo do Cadastro
		OemToAnsi( STR0015 ),;   //"Legenda"
		aLegenda )
	Else
		GpLegend()
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fCidCom
Encaminha para montagem da grid de CID complementar da respectiva
rotina.

@author Gabriel Sokacheski
@since 27/05/2021

/*/
//---------------------------------------------------------------------
Static Function fCidCom( cAlias )

	If cAlias == 'TMT'

		If !Empty( M->TMT_HRCONS ) .And. !Empty( M->TMT_DTCONS ) .And. !Empty( M->TMT_CID )

			If MDT076HOR( M->TMT_HRCONS )

				fCidDia()

			EndIf

		Else

			MsgStop( STR0095, STR0017 )

		EndIf

	ElseIf cAlias == 'TNY'

		If !Empty( M->TNY_CID )

			fCidAte()

		Else

			MsgStop( STR0096, STR0017 )

		EndIf

	ElseIf cAlias == 'TNC'

		If !Empty( M->TNC_CID )

			fCidAci()

		Else

			MsgStop( STR0096, STR0017 )

		EndIf

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fCidDia
Monta grid de CID complementar da rotina de diagnóstico.

@author Gabriel Sokacheski
@since 27/05/2021

/*/
//---------------------------------------------------------------------
Static Function fCidDia()

	Local aArea	:= GetArea()

	Private aColunas := {}
	Private aCabeca := {}

	Private oGrid

	aAdd( aCabeca, { 'Grupo CID', 'TKJ_GRPCID', '@!', 3, 0, 'f410GrpDia()', '', 'C', '', '' } )
	aAdd( aCabeca, { 'Desc. Grupo', 'TKJ_DESGRP', '@!', 80, 0, '', '', 'C', '', '' } )
	aAdd( aCabeca, { 'CID Compl.', 'TKJ_CID', '@!', 8, 0, 'f410CidDia()', '', 'C', '', '' } )
	aAdd( aCabeca, { 'Desc. Doenca', 'TKJ_DOENCA', '@!', 80, 0, '', '', 'C', '', '' } )

	DEFINE MSDIALOG oDlg TITLE 'CID Complementar' FROM 000, 000  TO 300, 900  PIXEL

	oGrid := MsNewGetDados():New(;
		053,;
		078,;
		415,;
		775,;
		GD_INSERT+GD_DELETE+GD_UPDATE,;
		'AllwaysTrue',;
		'AllwaysTrue',;
		'AllwaysTrue',;
		{ 'TKJ_GRPCID', 'TKJ_CID' },;
		0,;
		999,;
		'f410DiaOk',;
		'',;
		'AllwaysTrue',;
		oDlg,;
		aCabeca,;
		aColunas;
		)

	dbSelectArea( 'TKJ' )
	dbSetOrder( 1 )
	dbGoTop()

	If dbSeek( xFilial( 'TKJ' ) + M->TMT_NUMFIC + DTOS( M->TMT_DTCONS ) + M->TMT_HRCONS )

		While !Eof() .And. TKJ->TKJ_FILIAL == xFilial( 'TKJ' ) .And. TKJ->TKJ_NUMFIC == M->TMT_NUMFIC .And.;
				TKJ->TKJ_DTCONS == M->TMT_DTCONS .And. TKJ->TKJ_HRCONS == M->TMT_HRCONS

			aAdd( aColunas, {;
				TKJ->TKJ_GRPCID,;
				Posicione( 'TLG', 1, xFilial( 'TLG' ) + TKJ->TKJ_GRPCID, 'TLG_DESCRI' ),;
				TKJ->TKJ_CID,;
				Posicione( 'TMR', 1, xFilial( 'TMR' ) + TKJ->TKJ_CID, 'TMR_DOENCA' ),;
				.F.;
				} )

			TKJ->( dbSkip() )

		End

	Else

		aAdd( aColunas, {;
			Space( 3 ),;
			Space( 80 ),;
			Space( 8 ),;
			Space( 80 ),;
			.F.;
			} )

	EndIf

	oGrid:SetArray( aColunas, .F. )
	oGrid:Refresh( .T. )

	// Alinhar grid para ocupar todo o formulário
	oGrid:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	// Ao abrir a janela o cursor está posicionado no objeto
	oGrid:oBrowse:SetFocus()

	ACTIVATE MSDIALOG oDlg CENTERED On Init EnchoiceBar(;
		oDlg,;
		{ || fCadCidDia(), oDlg:End() },;
		{ || oDlg:End() };
		)

	RestArea( aArea )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fCidAte
Monta grid de CID complementar da rotina de atestado médico.

@author Gabriel Sokacheski
@since 27/05/2021

/*/
//---------------------------------------------------------------------
Static Function fCidAte()

	Local aArea	:= GetArea()

	Private aColunas := {}
	Private aCabeca := {}

	Private oGrid

	aAdd( aCabeca, { 'Grupo CID', 'TKI_GRPCID', '@!', 3, 0, 'f410GruAte()', '', 'C', '', '' } )
	aAdd( aCabeca, { 'Desc. Grupo', 'TKI_DESGRP', '@!', 80, 0, '', '', 'C', '', '' } )
	aAdd( aCabeca, { 'CID Compl.', 'TKI_CID', '@!', 8, 0, 'f410CidAte()', '', 'C', '', '' } )
	aAdd( aCabeca, { 'Desc. Doenca', 'TKI_DOENCA', '@!', 80, 0, '', '', 'C', '', '' } )

	DEFINE MSDIALOG oDlg TITLE 'CID Complementar' FROM 000, 000  TO 300, 900  PIXEL

	oGrid := MsNewGetDados():New(;
		053,;
		078,;
		415,;
		775,;
		GD_INSERT+GD_DELETE+GD_UPDATE,;
		'AllwaysTrue',;
		'AllwaysTrue',;
		'AllwaysTrue',;
		{ 'TKI_GRPCID', 'TKI_CID' },;
		0,;
		999,;
		'f410AteOk',;
		'',;
		'AllwaysTrue',;
		oDlg,;
		aCabeca,;
		aColunas;
		)

	dbSelectArea( 'TKI' )
	dbSetOrder( 1 )
	dbGoTop()

	If dbSeek( xFilial( 'TKI' ) + M->TNY_NATEST )

		While !Eof() .And. TKI->TKI_FILIAL == xFilial( 'TKI' ) .And. TKI->TKI_NATEST == M->TNY_NATEST

			aAdd( aColunas, {;
				TKI->TKI_GRPCID,;
				Posicione( 'TLG', 1, xFilial( 'TLG' ) + TKI->TKI_GRPCID, 'TLG_DESCRI' ),;
				TKI->TKI_CID,;
				Posicione( 'TMR', 1, xFilial( 'TMR' ) + TKI->TKI_CID, 'TMR_DOENCA' ),;
				.F.;
				} )

			TKI->( dbSkip() )

		End

	Else

		aAdd( aColunas, {;
			Space( 3 ),;
			Space( 80 ),;
			Space( 8 ),;
			Space( 80 ),;
			.F.;
			} )

	EndIf

	oGrid:SetArray( aColunas, .F. )
	oGrid:Refresh( .T. )

	// Alinhar grid para ocupar todo o formulário
	oGrid:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	// Ao abrir a janela o cursor está posicionado no objeto
	oGrid:oBrowse:SetFocus()

	ACTIVATE MSDIALOG oDlg CENTERED On Init EnchoiceBar(;
		oDlg,;
		{ || fCadCidAte(), oDlg:End() },;
		{ || oDlg:End() };
		)

	RestArea( aArea )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fCidAci
Monta grid de CID complementar da rotina de acidente.

@author Gabriel Sokacheski
@since 27/05/2021

/*/
//---------------------------------------------------------------------
Static Function fCidAci()

	Local aArea	:= GetArea()

	Private aColunas := {}
	Private aCabeca := {}

	Private oGrid

	aAdd( aCabeca, { 'Grupo CID', 'TKK_GRPCID', '@!', 3, 0, 'f410GruAci()', '', 'C', '', '' } )
	aAdd( aCabeca, { 'Desc. Grupo', 'TKK_DESGRP', '@!', 80, 0, '', '', 'C', '', '' } )
	aAdd( aCabeca, { 'CID Compl.', 'TKK_CID', '@!', 8, 0, 'f410CidAci()', '', 'C', '', '' } )
	aAdd( aCabeca, { 'Desc. Doenca', 'TKK_DOENCA', '@!', 80, 0, '', '', 'C', '', '' } )

	DEFINE MSDIALOG oDlg TITLE 'CID Complementar' FROM 000, 000  TO 300, 900  PIXEL

	oGrid := MsNewGetDados():New(;
		053,;
		078,;
		415,;
		775,;
		GD_INSERT+GD_DELETE+GD_UPDATE,;
		'AllwaysTrue',;
		'AllwaysTrue',;
		'AllwaysTrue',;
		{ 'TKK_GRPCID', 'TKK_CID' },;
		0,;
		999,;
		'f410AciOk',;
		'',;
		'AllwaysTrue',;
		oDlg,;
		aCabeca,;
		aColunas;
		)

	dbSelectArea( 'TKK' )
	dbSetOrder( 1 )
	dbGoTop()

	If dbSeek( xFilial( 'TKK' ) + M->TNC_ACIDEN )

		While !Eof() .And. TKK->TKK_FILIAL == xFilial( 'TKK' ) .And. TKK->TKK_ACIDEN == M->TNC_ACIDEN

			aAdd( aColunas, {;
				TKK->TKK_GRPCID,;
				Posicione( 'TLG', 1, xFilial( 'TLG' ) + TKK->TKK_GRPCID, 'TLG_DESCRI' ),;
				TKK->TKK_CID,;
				Posicione( 'TMR', 1, xFilial( 'TMR' ) + TKK->TKK_CID, 'TMR_DOENCA' ),;
				.F.;
				} )

			TKK->( dbSkip() )

		End

	Else

		aAdd( aColunas, {;
			Space( 3 ),;
			Space( 80 ),;
			Space( 8 ),;
			Space( 80 ),;
			.F.;
			} )

	EndIf

	oGrid:SetArray( aColunas, .F. )
	oGrid:Refresh( .T. )

	// Alinhar grid para ocupar todo o formulário
	oGrid:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	// Ao abrir a janela o cursor está posicionado no objeto
	oGrid:oBrowse:SetFocus()

	ACTIVATE MSDIALOG oDlg CENTERED On Init EnchoiceBar(;
		oDlg,;
		{ || fCadCidAci(), oDlg:End() },;
		{ || oDlg:End() };
		)

	RestArea( aArea )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} f410GrpDia
Valida o campo de grupo de CID do CID complementar da rotina de
diagnóstico.

@author Gabriel Sokacheski
@since 27/05/2021

/*/
//---------------------------------------------------------------------
Function f410GrpDia()

	Local lRet := ExistCpo( 'TLG', M->TKJ_GRPCID )

	aColunas := oGrid:aCols

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} f410GruAte
Valida o campo de grupo de CID do CID complementar da rotina de
atestado médico.

@author Gabriel Sokacheski
@since 27/05/2021

/*/
//---------------------------------------------------------------------
Function f410GruAte()

	Local lRet := ExistCpo( 'TLG', M->TKI_GRPCID )

	aColunas := oGrid:aCols

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} f410GruAci
Valida o campo de grupo de CID do CID complementar da rotina de
acidente.

@author Gabriel Sokacheski
@since 27/05/2021

/*/
//---------------------------------------------------------------------
Function f410GruAci()

	Local lRet := ExistCpo( 'TLG', M->TKK_GRPCID )

	aColunas := oGrid:aCols

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} f410CidDia
Valida o campo de CID do CID complementar da rotina de diagnóstico.

@author Gabriel Sokacheski
@since 27/05/2021

/*/
//---------------------------------------------------------------------
Function f410CidDia()

	Local lRet := ExistCpo( 'TMR', M->TKJ_CID )

	Local nI := 0
	Local nLinhas := Len( aColunas )

	aColunas := oGrid:aCols

	If lRet .And. M->TKJ_CID == M->TMT_CID

		Help( Nil, Nil, STR0097, Nil, STR0098, 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0099 } )
		lRet := .F.

	EndIf

	If lRet .And. nLinhas > 1

		For nI := 1 To nLinhas - 1

			If M->TKJ_CID == aColunas[ nI, 3 ]

				Help( Nil, Nil, STR0097, Nil, STR0100, 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0099 } )
				lRet := .F.
				Exit

			EndIf

		Next

	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} f410CidAte
Valida o campo de CID do CID complementar da rotina de atestado.

@author Gabriel Sokacheski
@since 27/05/2021

/*/
//---------------------------------------------------------------------
Function f410CidAte()

	Local lRet := ExistCpo( 'TMR', M->TKI_CID )

	Local nI := 0
	Local nLinhas := Len( aColunas )

	aColunas := oGrid:aCols

	If lRet .And. M->TKI_CID == M->TNY_CID

		Help( Nil, Nil, STR0097, Nil, STR0098, 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0099 } )
		lRet := .F.

	EndIf

	If lRet .And. nLinhas > 1

		For nI := 1 To nLinhas - 1

			If M->TKI_CID == aColunas[ nI, 3 ]

				Help( Nil, Nil, STR0097, Nil, STR0100, 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0099 } )
				lRet := .F.
				Exit

			EndIf

		Next

	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} f410CidAci
Valida o campo de CID do CID complementar da rotina de acidente.

@author Gabriel Sokacheski
@since 27/05/2021

/*/
//---------------------------------------------------------------------
Function f410CidAci()

	Local lRet := ExistCpo( 'TMR', M->TKK_CID )

	Local nI := 0
	Local nLinhas := Len( aColunas )

	aColunas := oGrid:aCols

	If lRet .And. M->TKK_CID == M->TNC_CID

		Help( Nil, Nil, STR0097, Nil, STR0098, 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0099 } )
		lRet := .F.

	EndIf

	If lRet .And. nLinhas > 1

		For nI := 1 To nLinhas - 1

			If M->TKI_CID == aColunas[ nI, 3 ]

				Help( Nil, Nil, STR0097, Nil, STR0100, 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0099 } )
				lRet := .F.
				Exit

			EndIf

		Next

	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} f410LinOk
Valida a linha de CID complementar da rotina de diagnóstico.

@author Gabriel Sokacheski
@since 27/05/2021

/*/
//---------------------------------------------------------------------
Function f410DiaOk()

	Local lRet := .T.

	Local nLinhas := Len( aColunas )

	aColunas := oGrid:aCols

	If !Empty( M->TKJ_GRPCID ) // Caminho do CID por primeiro

		If !Empty( aColunas[ nLinhas, 3 ] ) .And. M->TKJ_GRPCID != SubStr( AllTrim( aColunas[ nLinhas, 3 ] ), 1, 3 )

			Help( Nil, Nil, STR0097, Nil, STR0101, 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0102 } )
			lRet := .F.

		EndIf

	ElseIf !Empty( M->TKJ_CID ) // Caminho do grupo por primeiro

		If !Empty( aColunas[ nLinhas, 1 ] ) .And. ( aColunas[ nLinhas, 1 ] )!= SubStr( M->TKJ_CID, 1, 3 )

			Help( Nil, Nil, STR0097, Nil, STR0101, 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0102 } )
			lRet := .F.

		EndIf

	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} f410AteOk
Valida a linha de CID complementar da rotina de atestado médico.

@author Gabriel Sokacheski
@since 27/05/2021

/*/
//---------------------------------------------------------------------
Function f410AteOk()

	Local lRet := .T.

	Local nLinhas := Len( aColunas )

	aColunas := oGrid:aCols

	If !Empty( M->TKI_GRPCID ) // Caminho do CID por primeiro

		If !Empty( aColunas[ nLinhas, 3 ] ) .And. M->TKI_GRPCID != SubStr( AllTrim( aColunas[ nLinhas, 3 ] ), 1, 3 )

			Help( Nil, Nil, STR0097, Nil, STR0101, 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0102 } )
			lRet := .F.

		EndIf

	ElseIf !Empty( M->TKI_CID ) // Caminho do grupo por primeiro

		If !Empty( aColunas[ nLinhas, 1 ] ) .And. ( aColunas[ nLinhas, 1 ] )!= SubStr( M->TKI_CID, 1, 3 )

			Help( Nil, Nil, STR0097, Nil, STR0101, 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0102 } )
			lRet := .F.

		EndIf

	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} f410AciOk
Valida a linha de CID complementar da rotina de atestado médico.

@author Gabriel Sokacheski
@since 27/05/2021

/*/
//---------------------------------------------------------------------
Function f410AciOk()

	Local lRet := .T.

	Local nLinhas := Len( aColunas )

	aColunas := oGrid:aCols

	If !Empty( M->TKK_GRPCID ) // Caminho do CID por primeiro

		If !Empty( aColunas[ nLinhas, 3 ] ) .And. M->TKK_GRPCID != SubStr( AllTrim( aColunas[ nLinhas, 3 ] ), 1, 3 )

			Help( Nil, Nil, STR0097, Nil, STR0101, 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0102 } )
			lRet := .F.

		EndIf

	ElseIf !Empty( M->TKK_CID ) // Caminho do grupo por primeiro

		If !Empty( aColunas[ nLinhas, 1 ] ) .And. ( aColunas[ nLinhas, 1 ] )!= SubStr( M->TKK_CID, 1, 3 )

			Help( Nil, Nil, STR0097, Nil, STR0101, 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0102 } )
			lRet := .F.

		EndIf

	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fCadCidDia
Efetua o cadastro do CID complementar da rotina de diagnóstico.

@author Gabriel Sokacheski
@since 27/05/2021

/*/
//---------------------------------------------------------------------
Static Function fCadCidDia()

	Local aArea	:= GetArea()

	Local nI := 0

	aColunas := oGrid:aCols

	dbSelectArea( 'TKJ' )
	dbSetOrder( 1 )
	dbGoTop()

	For nI := 1 To Len( aColunas )

		If !aColunas[ nI, 5 ]

			If !dbSeek( xFilial( 'TKJ' ) + M->TMT_NUMFIC + DTOS( M->TMT_DTCONS ) + M->TMT_HRCONS + aColunas[ nI, 1 ] + aColunas[ nI, 3 ] )

				RecLock( 'TKJ', .T. )

				TKJ->TKJ_FILIAL := xFilial( 'TKJ' )
				TKJ->TKJ_NUMFIC := M->TMT_NUMFIC
				TKJ->TKJ_DTCONS := M->TMT_DTCONS
				TKJ->TKJ_HRCONS := M->TMT_HRCONS
				TKJ->TKJ_GRPCID := aColunas[ nI, 1 ]
				TKJ->TKJ_CID := aColunas[ nI, 3 ]

				( 'TKJ' )->( MsUnLock() )

			EndIf

		Else

			If dbSeek( xFilial( 'TKJ' ) + M->TMT_NUMFIC + DTOS( M->TMT_DTCONS ) + M->TMT_HRCONS + aColunas[ nI, 1 ] + aColunas[ nI, 3 ] )

				RecLock( 'TKJ', .F. )
				( 'TKJ' )->( dbDelete() )
				( 'TKJ' )->( MsUnLock() )

			EndIf

		EndIf

		dbGoTop()

	Next

	RestArea( aArea )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fCadCidAte
Efetua o cadastro do CID complementar da rotina de atestado médico.

@author Gabriel Sokacheski
@since 28/05/2021

/*/
//---------------------------------------------------------------------
Static Function fCadCidAte()

	Local aArea	:= GetArea()

	Local nI := 0

	aColunas := oGrid:aCols

	dbSelectArea( 'TKI' )
	dbSetOrder( 1 )
	dbGoTop()

	For nI := 1 To Len( aColunas )

		If !aColunas[ nI, 5 ]

			If !dbSeek( xFilial( 'TKI' ) + M->TNY_NATEST + aColunas[ nI, 1 ] + aColunas[ nI, 3 ] )

				RecLock( 'TKI', .T. )

				TKI->TKI_FILIAL := xFilial( 'TKI' )
				TKI->TKI_NATEST := M->TNY_NATEST
				TKI->TKI_GRPCID := aColunas[ nI, 1 ]
				TKI->TKI_CID := aColunas[ nI, 3 ]

				( 'TKI' )->( MsUnLock() )

			EndIf

		Else

			If dbSeek( xFilial( 'TKI' ) + M->TNY_NATEST + aColunas[ nI, 1 ] + aColunas[ nI, 3 ] )

				RecLock( 'TKI', .F. )
				( 'TKI' )->( dbDelete() )
				( 'TKI' )->( MsUnLock() )

			EndIf

		EndIf

		dbGoTop()

	Next

	RestArea( aArea )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fCadCidAci
Efetua o cadastro do CID complementar da rotina de acidente.

@author Gabriel Sokacheski
@since 28/05/2021

/*/
//---------------------------------------------------------------------
Static Function fCadCidAci()

	Local aArea	:= GetArea()

	Local nI := 0

	aColunas := oGrid:aCols

	dbSelectArea( 'TKK' )
	dbSetOrder( 1 )
	dbGoTop()

	For nI := 1 To Len( aColunas )

		If !aColunas[ nI, 5 ]

			If !dbSeek( xFilial( 'TKK' ) + M->TNC_ACIDEN + aColunas[ nI, 1 ] + aColunas[ nI, 3 ] )

				RecLock( 'TKK', .T. )

				TKK->TKK_FILIAL := xFilial( 'TKK' )
				TKK->TKK_ACIDEN := M->TNC_ACIDEN
				TKK->TKK_GRPCID := aColunas[ nI, 1 ]
				TKK->TKK_CID := aColunas[ nI, 3 ]

				( 'TKI' )->( MsUnLock() )

			EndIf

		Else

			If dbSeek( xFilial( 'TKK' ) + M->TNC_ACIDEN + aColunas[ nI, 1 ] + aColunas[ nI, 3 ] )

				RecLock( 'TKK', .F. )
				( 'TKK' )->( dbDelete() )
				( 'TKK' )->( MsUnLock() )

			EndIf

		EndIf

		dbGoTop()

	Next

	RestArea( aArea )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fMenuRel
Criação do menu para opções de relacionamentos com atestado ASO

@author Eloisa Anibaletto
@since 08/05/2024

@param oParent, Objeto, Pai
/*/
//---------------------------------------------------------------------
Static Function fMenuRel( oParent )

	oMenu := TMenu():New( 0, 0, 0, 0, .T. )

	// Adiciona itens no Menu
	oTMenuRis := TMenuItem():New( , STR0086, , , , { ||MDT200VAR( IIf( INCLUI, 3, IIf( ALTERA, 4, 5 ) ), 1, .F. ) }, ;
		, , , , , , , , .T. ) //"Riscos"
	oTMenuExa := TMenuItem():New( , STR0006, , , , { ||MDT200VAR( IIf( INCLUI, 3, IIf( ALTERA, 4, 5 ) ), 2, .F. ) }, ;
		, , , , , , , , .T. ) //"Exames"
	oTMenuAge := TMenuItem():New( , STR0087, , , , { ||MDT200VAR( IIf( INCLUI, 3, IIf( ALTERA, 4, 5 ) ), 3, .F. ) },;
		, , , , , , , , .T. ) //"Agentes"
	oTMenuQue := TMenuItem():New( , STR0012, , , , { ||MDT200VAR( IIf( INCLUI, 3, IIf( ALTERA, 4, 5 ) ), 4, .F. ) }, ;
		, , , , , , , , .T. ) //"Questionário"
	oTMenuRes := TMenuItem():New( , STR0088, , , , { ||MDT200VAR( IIf( INCLUI, 3, IIf( ALTERA, 4, 5 ) ), 5, .F. ) }, ;
		, , , , , , , , .T. ) //"Restrição"

	oMenu:Add( oTMenuRis )
	oMenu:Add( oTMenuAge )
	oMenu:Add( oTMenuQue )
	oMenu:Add( oTMenuRes )
	oMenu:Add( oTMenuExa )

	If AliasInDic( "TYD" )
		oTMenuTar := TMenuItem():New( , STR0091, , , , {||MDT200VAR( IIf( INCLUI, 3, IIf( ALTERA, 4, 5 ) ), 6, .F. )}, ;
			, , , , , , , , .T. ) //"Tarefa"
		oMenu:Add( oTMenuTar )
	EndIf

	oMenu:Activate( 25, 150, oParent )

Return

//--------------------------------------------------------------------------
/*/{Protheus.doc} fBusDadAso
Guarda os dados importantes para o eSocial antes da alteração do registro

@author Gabriel Sokacheski
@since 15/05/2024

/*/
//--------------------------------------------------------------------------
Static Function fBusDadAso()

	aDadAsoPon := {;
		M->TMY_NATEXA,;
		M->TMY_DTEMIS,;
		M->TMY_INDPAR,;
		M->TMY_INDEXA,;
		M->TMY_CODUSU;
	}

Return
