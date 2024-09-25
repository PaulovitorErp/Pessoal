#INCLUDE "MDTC500.ch"
#INCLUDE "Protheus.CH"
#INCLUDE "Colors.CH"
#INCLUDE "Dbstruct.CH"
#INCLUDE "MSGRAPHI.CH"

//Definições de Tamanho de campo
Static _nTamCol1 := 0.013
Static _nTamCol2 := 0.01
Static _nTamCol3 := 0.003
Static _nTamCol4 := 0.105
Static _nTamCol5 := 0.169
Static _nTamCol6 := 0.243
Static _nTamCol7 := 0.292
Static _nTamCol8 := 0.356
Static _nTamCol9 := 0.438
Static _nTamLin1 := 0.09
Static _nTamLin2 := 0.128
Static _nTamLin3 := 0.154
Static _nTamLin4 := 0.180
Static _nTamLin5 := 0.206
Static _nTamLin6 := 0.232
Static _nTamLin7 := 0.258
Static _nTamLin8 := 0.285
Static _nTamLin9 := 0.168
Static _nTamLin10:= 0.082
Static _nTamLin11:= 0.220
Static _nTamLin12:= 0.336

//Tabelas Principais
Static _nPosDesFol := 1
Static _nPosTabPri := 2
Static _nPosCamRea := 3
Static _nPosCamVir := 4

//Posicao dos Campos Vifrtuais
Static _nPosVirCmp := 1
Static _nPosVirTab := 2
Static _nPosVirCp2 := 3
Static _nPosVirDom := 4
Static _nPosVirCDo := 5
Static _nPosVirVal := 6

//Correspondentes
Static _nPosTip := 1
Static _nPosTbl := 2
Static _nPosCmp := 3
Static _nPosSXB := 4

//Definições de campos virtuais
Static _nPosCampo	:= 1
Static _nPosAlign	:= 2
Static _nPosTitle	:= 3
Static _nPosType	:= 4
Static _nPosTam		:= 5
Static _nPosPictu	:= 6

//Posições dos campos
Static _nPosOco		:= 1
Static _nPosPer		:= 2
Static _nPosCod		:= 3

//Posições dos campos do Indice Geral
Static _nPosIndTot	:= 1
Static _nPosIndAbs	:= 2
Static _nPosIndAci	:= 3

//Posições dos campos da Faixa Periodica
Static _nPosFaiHom	:= 1
Static _nPosFaiHCo	:= 2
Static _nPosFaiPH 	:= 3
Static _nPosFaiMul	:= 4
Static _nPosFaiMOc	:= 5
Static _nPosFaiPM 	:= 6
Static _nPosFaiTot	:= 7

Static _nRowOne		:= 1
Static _nRowTwo		:= 2
Static _nRowThree	:= 3
Static _nRowFour	:= 4
Static _nRowFive	:= 5
Static _nRowSix		:= 6
Static _nRowSeven	:= 7

//Posições dos campos do Sexo
Static _nPosHSex	:= 1
Static _nPosMSex	:= 2

//Codificacoes de SQL
Static cSubString := If( "MSSQL" $ Upper( TCGetDB() ) , "SUBSTRING" , "SUBSTR" )
//---------------------------------------------------------------------
/*/{Protheus.doc} MDTC500
Gerencial Ocupacional
Nesta rotina será possível verificar todos os relacionamentos do funcionário dentro do
módulo de Medicina e Segurança do Trabalho de forma gerencial.

@return

@sample
MDTC500()

@author Jackson Machado
@since 13/06/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Function MDTC500()

	//-------------------------------------------------
	// Armazena variaveis p/ devolucao (NGRIGHTCLICK)
	//-------------------------------------------------
	Local aNGBEGINPRM 	:= NGBEGINPRM()

	//Variaveis a serem utilizadas para montagem da tela
	Local aColor		:= NGCOLOR()
	Local aColorH		:= NGCOLOR( , "H" )

	//Variaveis de tamanho de tela
	Local lEnchBar	    := .T. // Indica se a janela de diálogo possuirá enchoicebar
	Local lPadrao	    := .F. // Indica se a janela deve respeitar as medidas padrões do Protheus (.T.) ou usar o máximo disponível (.F.)
	Local nMinY		    := 430 // Altura mínima da janela
	Local aSize		    := MsAdvSize( lEnchBar , lPadrao , nMinY )

	//Ações de Tela
	Local bConfirm	    := { | | oDialog:End() }
	Local bCancel		:= { | | oDialog:End() }

	//Variáveis do TRB
	Local cTRBPrinc	    := GetNextAlias()
	Local cTRBSec		:= GetNextAlias()

	//Variáveis da parte do Cabeçalho
	Local cCmbTip	    := STR0001 //"Absenteísmo"
	Local cCmbVis	    := STR0002 //"Centro de Custo"
	Local cCmbPer	    := STR0003 //"Anual"
	Local dDtIni	    := STOD( Space( 8 ) )
	Local dDtFim	    := STOD( Space( 8 ) )
	Local cFilIni	    := Space( Len( CTT->CTT_CUSTO ) )
	Local cFilFim	    := Replicate( "Z" , Len( CTT->CTT_CUSTO ) )
	Local cF3Pesq	    := "CTT"
	Local aItensTip     := { STR0001 , STR0004 , STR0005 , STR0006 , STR0007 } //"Absenteísmo"###"Exames"###"Diagnósticos"###"Doenças"###"Acidentes"
	Local aItensAbs     := { STR0002 , STR0008 , STR0009 , STR0010 , STR0011 } //"Centro de Custo"###"Função"###"Funcionário"###"CID"###"Motivo"
	Local aItensExa     := { STR0002 , STR0008 , STR0009 , STR0012 , STR0013 } //"Centro de Custo"###"Função"###"Funcionário"###"Resultado"###"Tipo de Exame"
	Local aItensDia     := { STR0002 , STR0008 , STR0009 , STR0014 , STR0016 } //"Centro de Custo"###"Função"###"Funcionário"###"Massa Corporea"###"Tipo de Atendimento"
	Local aItensDoe     := { STR0002 , STR0008 , STR0009 , STR0010 } //"Centro de Custo"###"Função"###"Funcionário"###"CID"
	Local aItensAci     := { STR0002 , STR0008 , STR0009 , STR0010 , STR0017 , STR0018 , STR0019 , STR0020 , STR0021 , STR0022 /*, "Dia da Semana" , "Faixa de Hora"*/ } //"Centro de Custo"###"Função"###"Funcionário"###"CID"###"Objeto Causador"###"Natureza da Lesão"###"Parte Atingida"###"Com Afastamento"###"Sem Afastamento"###"Tipo de Acidente"
	Local aItensPer     := { STR0003 /*, "Semestral" , "Trimestral"*/ , STR0023 } //"Anual"###"Mensal"

	//Define os Objetos
	Local oDialog
	Local oPnlPai, oPnlTit, oPnlTop, oPnlBot
	Local oPnlLeft, oPnlRight
	Local oPnlRTop, oPnlRBot
	Local oPnlLTop, oPnlLBot
	Local oPnlLTBot, oPnlLTBtn
	Local oPnlRTTit, oPnlRTBtn, oGraphic
	Local oPnlLBBot, oPnlLBBtn
	Local oPnlRBTit, oPnlRBBtn
	Local oPnlList1, oPnlList2
	Local oBtnShow, oBtnCon, oBtnNew, oBtnVisual, oBtnResul
	Local oCmbTip, oCmbVis
	Local oDtIni, oDtFim
	Local oFilIni, oFilFim
	Local oCmbPer
	Local oBtnPesq
	Local oTotAbs, oTotAci
	Local oPerAbs, oPerAci
	Local oFontB 		:= TFont():New( , , , , .T. )
	Local oSayHrs1, oSayHrs2
	Local oSayQHrs1, oSayQHrs2
	Local oBtnRelFaix, oBtnRelGraf, oBtnRelLis1, oBtnRelLis2
	Local oBtnLegGraf, oBtnRetorno, oBtnRefres1, oBtnRefres2, oBtnAvNivel

	//Change
	Local bChange := { | |  }
	Local bDblClick := { | |  }

	//PaintPanel
	Local nId     := 0
	Local nPosWid := 0
	Local nPosHei := 0

	Local oTitFai

	//-------------------------------------------------
	// Define as propriedades principais:
	// 1. Nome da opção
	// 2. Tabela assossiada
	// 3. Campos a serem trazidos
	// 4. Campos externos a serem trazidos:
	//		1. Campo Virtual
	//		2. Tabela a ser buscada
	//		3. Campo a ser trazido
	//		4. Campo contra domínio da tabela atual
	//		5. Campo domínio da tabela a ser buscada
	//   6. Filtro
	//-------------------------------------------------
	Local aTabPrinc := { ;
							{ STR0001 , "SR8" , ; //"Absenteísmo"
														{ "R8_MAT" , "R8_DATA" , "R8_TIPO" , "R8_DATAINI" , "R8_DATAFIM" , "R8_CODCAT" , "R8_DTCAT" , "R8_CID" } , ;
														{ ;
															{ "R8_NOMFUN" , "SRA" , "RA_NOME" , "R8_MAT" , "RA_MAT", "" } , ;
															{ "R8_DESCID" , "TMR" , "TMR_DOENCA" , "R8_CID" , "TMR_CID" , "" } , ;
															{ "R8_MOTAFA" , "SX5" , "X5_DESCRI" , "R8_TIPO" , "X5_CHAVE" , "SX5.X5_TABELA = '30'" } ;
														} } , ;
							{ STR0004 , "TM5" , ; //"Exames"
														{ "TM5_NUMFIC" , "TM5_EXAME" , "TM5_DTPROG" , "TM5_DTRESU" , "TM5_PCMSO" } , ;
														{ ;
															{ "TM5_NOMFIC" , "TM0" , "TM0_NOMFIC" , "TM5_NUMFIC" , "TM0_NUMFIC", "" } , ;
															{ "TM5_NOMEXA" , "TM4" , "TM4_NOMEXA" , "TM5_EXAME" , "TM4_EXAME", "" } ;
														} } , ;
							{ STR0005 , "TMT" , ; //"Diagnósticos"
														{ "TMT_NUMFIC" , "TMT_DTCONS" , "TMT_CODUSU" , "TMT_DTATEN" , "TMT_HRATEN" , "TMT_CID" , "TMT_OCORRE" , "TMT_MASSA" , "TMT_ALTURA" , "TMT_PESO" , "TMT_TEMPER" /*, "TMT_QUEIXA" , "TMT_DIAGNO"*/ } , ;
														{ ;
															{ "TMT_NOMFIC" , "TM0" , "TM0_NOMFIC" , "TMT_NUMFIC" , "TM0_NUMFIC", "" } , ;
															{ "TMT_NOMUSU" , "TMK" , "TMK_NOMUSU" , "TMT_CODUSU" , "TMK_CODUSU", "" } , ;
															{ "TMT_DOENCA" , "TMR" , "TMR_DOENCA" , "TMT_CID" , "TMR_CID", "" } , ;
															{ "TMT_DESOCO" , "SX5" , "" , "TMT_OCORRE" , "", "" } ;
														} } , ;
							{ STR0006 , "TNA" , ; //"Doenças"
													{ "TNA_NUMFIC" , "TNA_CID" } , ;
													{ ;
														{ "TNA_NOMFIC" , "TM0" , "TM0_NOMFIC" , "TNA_NUMFIC" , "TM0_NUMFIC", "" } , ;
														{ "TNA_DOENCA" , "TMR" , "TMR_DOENCA" , "TNA_CID" , "TMR_CID", "" } ;
													} } , ;
							{ STR0007 , "TNC" , ; //"Acidentes"
													{ "TNC_ACIDEN" , "TNC_DESACI" , "TNC_DTACID" , "TNC_HRACID" , "TNC_NUMFIC" } , ;
													{ ;
														{ "TNC_NOMFIC" , "TM0" , "TM0_NOMFIC" , "TNC_NUMFIC" , "TM0_NUMFIC", "" } ;
													} } ;
						}
	//Variavel que indica as correspondencias
	Local aCorresp 	:=	{ ;
							{ STR0002 , "CTT" , "CTT_CUSTO" , "CTT" } , ; //"Centro de Custo"
							{ STR0008 , "SRJ" , "RJ_FUNCAO" , "SRJ" } , ; //"Função"
							{ STR0009 , "SRA" , "RA_MAT"    , "SRA" } , ; //"Funcionário"
							{ STR0010 , "TMR" , "TMR_CID"   , "TMR" } , ; //"CID"								{ STR0016 , "TMS" , "TMS_MOTIVO" } , ; //"Tipo de Atendimento"
							{ STR0012 , "TMU" , "TMU_CODRES", "TMU"  } , ; //"Resultado"
							{ STR0013 , "TM4" , "TM4_EXAME" , "TM4"  } , ; //"Tipo de Exame"
							{ STR0011 , "30" , 1            , "30"  } , ; //"Motivo"
							{ STR0017 , "TNH" , "TNH_CODOBJ", "TNH"  } , ; //"Objeto Causador"
							{ STR0018 , "TOJ" , "TOJ_CODLES", "TOJ"  } , ; //"Natureza da Lesão"
							{ STR0019 , "TOI" , "TOI_CODPAR", "TOI"  }   ; //"Parte Atingida"
						}
	//Array com os campos a serem apresentados em tela
	Local aCpsList	:= { ;
							{ STR0002 , { STR0024 , STR0025 , STR0002 , STR0026 , STR0027 , "%" , STR0028 , "%" } } , ; //"Centro de Custo"###"Quantidade"###"Período"###"Centro de Custo"###"Descrição"###"Normal"###"Alterado"
							{ STR0008 , { STR0024 , STR0025 , STR0008 , STR0026 , STR0027 , "%" , STR0028 , "%" } } , ; //"Função"###"Quantidade"###"Período"###"Função"###"Descrição"###"Normal"###"Alterado"
							{ STR0009 , { STR0024 , STR0025 , STR0029 , STR0030 , STR0027 , "%" , STR0028 , "%" } } , ; //"Funcionário"###"Quantidade"###"Período"###"Matrícula"###"Nome"###"Normal"###"Alterado"
							{ STR0010 , { STR0024 , STR0025 , STR0010 , STR0026 } } , ; //"CID"###"Quantidade"###"Período"###"CID"###"Descrição"
							{ STR0011 , { STR0024 , STR0025 , STR0011 , STR0026 } } , ; //"Motivo"###"Quantidade"###"Período"###"Motivo"###"Descrição"
							{ STR0012 , { STR0024 , STR0025 , STR0012 , STR0026 , STR0027 , "%" , STR0028 , "%" } } , ; //"Resultado"###"Quantidade"###"Período"###"Resultado"###"Descrição"###"Normal"###"Alterado"
							{ STR0013 , { STR0024 , STR0025 , STR0031 , STR0026 , STR0027 , "%" , STR0028 , "%" } } , ; //"Tipo de Exame"###"Quantidade"###"Período"###"Exame"###"Descrição"###"Normal"###"Alterado"
							{ STR0016 , { STR0024 , STR0025 , STR0032 , STR0033 } } , ; //"Tipo de Atendimento"###"Quantidade"###"Período"###"Tipo"###"Desc. Atend."
							{ STR0014 , { STR0024 , STR0025 , STR0034 } } , ; //"Massa Corporea"###"Quantidade"###"Período"###"Massa"
							{ STR0015 , { STR0024 , STR0025 , STR0035 } } , ; //"Pressão Sanguinea"###"Quantidade"###"Período"###"Desc. Pressão"###"Pressão Arterial"###"Limites Sistólica"###"Limites Diastólica"
							{ STR0017 , { STR0024 , STR0025 , STR0039 , STR0026 } } , ; //"Objeto Causador"###"Quantidade"###"Período"###"Objeto"###"Descrição"
							{ STR0018 , { STR0024 , STR0025 , STR0040 , STR0026 } } , ; //"Natureza da Lesão"###"Quantidade"###"Período"###"Natureza"###"Descrição"
							{ STR0019 , { STR0024 , STR0025 , STR0041 , STR0026 } } , ; //"Parte Atingida"###"Quantidade"###"Período"###"Parte Corpo"###"Descrição"
							{ STR0020 , { STR0024 , STR0025 } } , ;  //"Com Afastamento"###"Quantidade"###"Período"
							{ STR0021 , { STR0024 , STR0025 } } , ; //"Sem Afastamento"###"Quantidade"###"Período"
							{ STR0022 , { STR0024 , STR0025 , STR0032 , STR0026 } } ;//{ "Dia da Semana" , { "Quantidade" , "Período" , "Dia" } } , ;//								{ "Faixa de Hora" , { "Quantidade" , "Período" , "Faixa" } } ;  //"Tipo de Acidente"###"Quantidade"###"Período"###"Tipo"###"Descrição"
						}
	//Array com os campos de definições de SX3
	Local aCpsSX3	:= { ;
							{ STR0002 , { { STR0002 , "CTT_CUSTO" } , { STR0026 , "CTT_DESC01" } } } , ; //"Centro de Custo"###"Centro de Custo"###"Descrição"
							{ STR0008 , { { STR0008 , "RJ_FUNCAO" } , { STR0026 , "RJ_DESC" } } } , ; //"Função"###"Função"###"Descrição"
							{ STR0009 , { { STR0029 , "RA_MAT" } , { STR0030 , "RA_NOME" } } } , ; //"Funcionário"###"Matrícula"###"Nome"
							{ STR0010 , { { STR0010 , "TMR_CID" } , { STR0026 , "TMR_DOENCA" } } } , ; //"CID"###"CID"###"Descrição"
							{ STR0011 , { { STR0011 , "R8_TIPO" } } } , ; //"Motivo"###"Motivo"
							{ STR0012 , { { STR0012 , "TMU_CODRES" } , { STR0026 , "TMU_RESULT" } } } , ; //"Resultado"###"Resultado"###"Descrição"
							{ STR0013 , { { STR0031 , "TM4_EXAME" } , { STR0026 , "TM4_NOMEXA" } } } , ; //"Tipo de Exame"###"Exame"###"Descrição"
							{ STR0016 , { { STR0032 , "TMT_OCORRE" } } } , ; //"Tipo de Atendimento"###"Tipo"
							{ STR0014 , { { STR0034 , "TMT_MASSA" } } } , ; //"Massa Corporea"###"Massa"
							{ STR0015 , { { STR0037 , "TMT_PRESIS" } , { STR0038 , "TMT_PREDIS" } } } , ; //"Pressão Sanguinea"###"Pressão Arterial"###"Limites Sistólica"###"Limites Diastólica"
							{ STR0017 , { { STR0039 , "TNH_CODOBJ" } , { STR0026 , "TNH_DESOBJ" } } } , ; //"Objeto Causador"###"Objeto"###"Descrição"
							{ STR0018 , { { STR0040 , "TOJ_CODLES" } , { STR0026 , "TOJ_NOMLES" } } } , ; //"Natureza da Lesão"###"Natureza"###"Descrição"
							{ STR0019 , { { STR0041 , "TOI_CODPAR" } , { STR0026 , "TOI_DESPAR" } } } , ; //"Parte Atingida"###"Parte Corpo"###"Descrição"
							{ STR0022 , { { STR0032 , "TNG_TIPACI" } , { STR0026 , "TNG_DESTIP" } } }  ; //"Tipo de Acidente"###"Tipo"###"Descrição"
						}
	//Array com os campos 'virtuais' e suas definições
	Local aDefVirtu := { ;
							{ "OCORRENCIA" , CONTROL_ALIGN_RIGHT , STR0024 , "N" , 20 , "@E 99,999,999,999,999,999" } , ; //"Quantidade"
							{ "PERIODO" , CONTROL_ALIGN_LEFT , STR0025 , "C" , 8 , "@!" } , ; //"Período"
							{ "NORMAL" , CONTROL_ALIGN_RIGHT , STR0027 , "N" , 20 , "@E 99,999,999,999,999,999" } , ; //"Normal"
							{ "ALTERADO" , CONTROL_ALIGN_RIGHT , STR0028 , "N" , 20 , "@E 99,999,999,999,999,999" } , ; //"Alterado"
							{ "PRESART" , CONTROL_ALIGN_LEFT , STR0035 , "C" , 40 , "@!" } , ; //"Desc. Pressão"
							{ "LIMSIS" , CONTROL_ALIGN_LEFT , STR0037 , "C" , 40 , "@!" } , ; //"Limites Sistólica"
							{ "LIMDIS" , CONTROL_ALIGN_LEFT , STR0038 , "C" , 40 , "@!" } , ; //"Limites Diastólica"
							{ "DIA" , CONTROL_ALIGN_LEFT , STR0042 , "C" , 20 , "@!" } , ;//								{ "FAIXA" , CONTROL_ALIGN_LEFT , "Faixa" , "C" , 5 , "@!" } , ; //"Dia"
							{ "PERCPRE" , CONTROL_ALIGN_RIGHT , "%" , "N" , 6 , "@E 999.99" } , ;
							{ "PERCNOR" , CONTROL_ALIGN_RIGHT , "%" , "N" , 6 , "@E 999.99" } , ;
							{ "PERCALT" , CONTROL_ALIGN_RIGHT , "%" , "N" , 6 , "@E 999.99" } , ;
							{ "R8_MOTAFA" , CONTROL_ALIGN_LEFT , STR0026 , "C" , 55 , "@!" } , ; //"Descrição"
							{ "TMT_DESOCO" , CONTROL_ALIGN_LEFT , STR0033 , "C" , 20 , "@!" } ; //"Desc. Atend."
						}

	//Definidas variavies de FwBrowse privadas pois o objeto usa externamente
	Private oListPrinc
	Private oListSecun
	//Contadores
	Private nNivBrw	:= 1
	Private nNivLim	:= 1
	Private nTotFun	:= 0
	Private nTotOco	:= 0
	Private nQtdPri	:= 0
	Private nQtdSec	:= 0
	Private nQtdHPri:= 0
	Private nQtdHSec:= 0
	Private nQtdMPri:= 0
	Private nQtdMSec:= 0
	Private nHrsPri	:= 0
	Private nHrsSec	:= 0

	Private cDescFai   := ""
	Private cDescAna   := STR0001 //"Absenteísmo"

	Private aIndiceGer := Array( _nPosIndAci , _nRowThree ) // 3x2
	Private aFaixaGeral:= Array( _nPosFaiTot , _nRowSeven ) // 7x7
	Private aSexoGeral := Array( _nRowOne , _nRowTwo )//1x2

	//Define um novo aRotina padrao para nao ocorrer erro
	Private aRotina := {{ STR0043 ,   "AxPesqui"	, 0 , 1 } , ; 	//"Pesquisar"
                      	{ STR0044 ,   "NGCAD01"		, 0 , 2 } , ; 	//"Visualizar"
                      	{ STR0045 ,   "NGCAD01"		, 0 , 3 } , ; 	//"Incluir"
                      	{ STR0046 ,   "NGCAD01"		, 0 , 4 } , ; 	//"Alterar"
                      	{ STR0047 ,   "NGCAD01"		, 0 , 5, 3 } } 	//"Excluir"

	SetVisual()

	aEval( aFaixaGeral, {| x,y | aFill( aFaixaGeral[y], 0)  } )
	aEval( aIndiceGer,  {| x,y | aFill( aIndiceGer[y], 0)  } )
	aEval( aSexoGeral, {| x,y | aFill( aSexoGeral[y], 0)  } )

	fAdequaDic( @aItensAbs, @aTabPrinc , @aCorresp , @aCpsList , @aCpsSX3 , @aDefVirtu )

    //Valida opções extras
    If NGCADICBASE( "TMT_PRESIS" , "A" , "TMT" , .F. )
    	aAdd( aItensDia , STR0015 )//"Pressão Sanguinea"
    Endif

	Pergunte( "MDTC500" , .F. )

	SetKey( VK_F12 , { | | MDT500PERG() } )

	//Valida tamanho mínimo de tela
	If fVldTela( aSize )

		//Monta a Tela
		Define MsDialog oDialog Title OemToAnsi( STR0048 ) From aSize[ 7 ] , 0 To aSize[ 6 ] , aSize[ 5 ] Of oMainWnd Pixel //"Gerencial Ocupacional"
			//Desabilita possibilidade da saida pelo botao esc
			oDialog:lEscClose := .F.

			//Panel criado para correta disposicao da tela
			oPnlPai := TPanel():New( , , , oDialog , , , , , , , , .F. , .F. )
				oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT

			//--------------------------------------------------------------
			// CABEÇALHO DE PESQUISA
			//--------------------------------------------------------------

			//Título indicativo
			oPnlTit := TPanel():New( , , , oPnlPai , , , , , aColor[ 2 ] , , 10 , .F. , .F. )
		   		oPnlTit:Align := CONTROL_ALIGN_TOP
		   		//Monta o Texto indicativo do cABEÇALHO
		   		TSay():New( 2 , 4 , { | | OemtoAnsi( STR0049 ) } , oPnlTit , , , .F. , .F. , .F. , .T. , aColor[ 1 ] , , 600 , 008 )  //"Consulta Gerencial"

			//Painel - Parte Superior ( Cabeçalho )
			oPnlTop := TPanel():New( , , , oPnlPai , , , , , , , 55 , .F. , .F. )
		   		oPnlTop:Align := CONTROL_ALIGN_TOP

				//Combos de Análise
				TSay():New( 015 , 015 , { | | STR0050 } , oPnlTop , , , , , , .T. , , , 040 , 008 )			 //"Tipo de Análise:"
				oCmbTip := TComboBox():New( 014 , 060 , { | u | If( PCount() > 0 , cCmbTip := u , cCmbTip ) } , ;
											aItensTip , 100 , 020 , oPnlTop , , ;
											{ | | fChangeTipBox( cCmbTip , @oCmbVis , fGetCbx( cCmbTip , aItensTip , { aItensAbs , aItensExa , aItensDia , aItensDoe , aItensAci } ) , @cFilIni , @cFilFim , @cF3Pesq , oSayHrs1 , oSayHrs2 , oSayQHrs1 , oSayQHrs2 ) } ;
											, , , , .T. , , , , , , , , , "cCmbTip" )
					oCmbTip:bHelp := { | | ShowHelpCpo( "cCmbTip" , ;
										{ STR0051 } , 2 , ; //"Selecione o Tipo de Análise que deseja verificar. (Absenteísmo, Exames, Diagnósticos, Doenças, Acidentes) ."
										{ } , 2 ) }

				TSay():New( 035 , 015 , { | | STR0052 } , oPnlTop , , , , , , .T. , , , 040 , 008 )			 //"Visualizar Por:"
				oCmbVis := TComboBox():New( 034 , 060 , { | u | If( PCount() > 0 , cCmbVis := u , cCmbVis ) } , ;
											aItensAbs , 100 , 020 , oPnlTop , , ;
											{ | | fChangeVisBox( aCorresp , cCmbVis , @cFilIni , @cFilFim , @cF3Pesq , @oFilIni , @oFilFim ) } ;
											, , , , .T. , , , , , , , , , "cCmbVis" )
					oCmbVis:bHelp := { | | ShowHelpCpo( "cCmbVis" , ;
										{ STR0053 } , 2 , ; //"Selecione a Visualização na qual deseja verificar. (Varia de Acordo com a Seleção do 'Tipo de Análise') ."
										{ } , 2 ) }
				//Filtros de Seleção
				//Filtro de Datas
				oDtIni := TGet():New( 014 , 170 , { | u | If( PCount() > 0 , dDtIni := u , dDtIni ) } , oPnlTop , 045 , 008 , ;
										, { | | fValid( 1 , dDtIni , dDtFim , aCorresp , cCmbVis ) } , 0 , , , .F. , , .T. , , .F. , , .F. , .F. , , .F. , .F. , , "dDtIni" , , , , .T. )
					oDtIni:bHelp := { | | ShowHelpCpo( "dDtIni" , ;
										{ STR0054 } , 2 , ; //"Data de Início a ser considerada no Filtro."
										{ } , 2 ) }
				TSay():New( 015 , 225 , { | | STR0055 } , oPnlTop , , , , , , .T. , , , 020 , 008 )						 //"Até"
				oDtFim := TGet():New( 014 , 240 , { | u | If( PCount() > 0 , dDtFim := u , dDtFim ) } , oPnlTop , 045 , 008 , ;
										, { | | fValid( 2 , dDtIni , dDtFim , aCorresp , cCmbVis ) } , 0 , , , .F. , , .T. , , .F. , , .F. , .F. , , .F. , .F. , , "dDtFim" , , , , .T. )
					oDtFim:bHelp := { | | ShowHelpCpo( "dDtFim" , ;
										{ STR0056 } , 2 , ; //"Data de Fim a ser considerada no Filtro."
										{ } , 2 ) }
				//Filtro de Campos
				oFilIni := TGet():New( 034 , 170 , { | u | If( PCount() > 0 , cFilIni := u , cFilIni ) } , oPnlTop , 045 , 008 , ;
										, { | | fValid( 3 , cFilIni , cFilFim , aCorresp , cCmbVis ) } , 0 , , , .F. , , .T. , , .F. , , .F. , .F. , , .F. , .F. , cF3Pesq , "cFilIni" , , , , .T. )
					oFilIni:bHelp := { | | ShowHelpCpo( "cFilIni" , ;
										{ STR0057 } , 2 , ; //"Valor inicial de Filtro. Varia de acordo com a seleção o 'Tipo de Visualização' e 'Visualizar Por'."
										{ } , 2 ) }
				TSay():New( 035 , 225 , { | | STR0055 } , oPnlTop , , , , , , .T. , , , 020 , 008 )						 //"Até"
				oFilFim := TGet():New( 34 , 240 , { | u | If( PCount() > 0 , cFilFim := u , cFilFim ) } , oPnlTop , 045 , 008 , ;
										, { | | fValid( 4 , cFilIni , cFilFim , aCorresp , cCmbVis ) } , 0 , , , .F. , , .T. , , .F. , , .F. , .F. , , .F. , .F. , cF3Pesq , "cFilFim" , , , , .T. )
					oFilFim:bHelp := { | | ShowHelpCpo( "cFilFim" , ;
										{ STR0058 } , 2 , ; //"Valor final de Filtro. Varia de acordo com a seleção o 'Tipo de Visualização' e 'Visualizar Por'."
										{ } , 2 ) }

				//Período
				TSay():New( 015 , 300 , { | | STR0059 } , oPnlTop , , , , ; //"Período:"
								, , .T. , , , 040 , 008 )

				oCmbPer := TComboBox():New( 014 , 345 , { | u | If( PCount() > 0 , cCmbPer := u , cCmbPer ) } , ;
											aItensPer , 050 , 020 , oPnlTop , , ;
											, , , , .T. , , , , , , , , , "cCmbPer" )
					oCmbPer:bHelp := { | | ShowHelpCpo( "cCmbPer" , ;
										{ STR0060 } , 2 , ; //"Selecione o Período que deseja verificar. (Anual, Mensal) ."
										{ } , 2 ) }
				//Define botão de Consulta
				oBtnCon := TButton():New( 034 , 300 , STR0061 , oPnlTop , { | lAtu | lAtu := fAtuGeral( .T. , oDtIni , oDtFim , oFilIni , oFilFim , oCmbTip , oCmbVis , oCmbPer , oPnlBot , aCpsList , cCmbTip , cCmbVis , cCmbPer , oPnlList1 , oPnlList2 , aCpsSX3 , aTabPrinc , cTRBPrinc , cTRBSec , dDtIni , dDtFim , cFilIni , cFilFim , aItensTip , fGetCbx( cCmbTip , aItensTip , { aItensAbs , aItensExa , aItensDia , aItensDoe , aItensAci } ) , aItensPer , aDefVirtu , , , oBtnVisual , oBtnAvNivel , oBtnResul , oPnlRBot , @oGraphic , 2 , .F. , oSayHrs1 , oSayHrs2 , oSayQHrs1 , oSayQHrs2 ) , If( lAtu , oBtnCon:Disable() , ) , If( lAtu , oBtnNew:Enable() , ) } , 40 , 10 , , , .F. , .T. , .F. , , .F. , , , .F. ) //"Gerar Consulta"
				oBtnNew := TButton():New( 034 , 350 , STR0062 , oPnlTop , { | lAtu | lAtu := fAtuGeral( .F. , oDtIni , oDtFim , @oFilIni , @oFilFim , oCmbTip , @oCmbVis , oCmbPer , oPnlBot , aCpsList , @cCmbTip , @cCmbVis , @cCmbPer , oPnlList1 , oPnlList2 , aCpsSX3 , aTabPrinc , cTRBPrinc , cTRBSec , @dDtIni , @dDtFim , @cFilIni , @cFilFim , aItensTip , fGetCbx( STR0001 , aItensTip , { aItensAbs , aItensExa , aItensDia , aItensDoe , aItensAci } ) , aItensPer , aDefVirtu , , , oBtnVisual , oBtnAvNivel , oBtnResul , oPnlRBot , @oGraphic , 2 , .T. , oSayHrs1 , oSayHrs2 , oSayQHrs1 , oSayQHrs2 ) , If( lAtu , oBtnCon:Enable() , ) , If( lAtu , oBtnNew:Disable() , ) } , 40 , 10 , , , .F. , .T. , .F. , , .F. , , , .F. ) //"Nova Consulta"
					oBtnNew:Disable()

				//TPaintPanel - Indicadores Gerais
				oPnlInd := TPanel():New( , , , oPnlTop , , , , , , 200 , , .F. , .F. )
		   			oPnlInd:Align := CONTROL_ALIGN_RIGHT

					nPosWid := oPnlInd:nClientWidth - 5
					nPosHei := oPnlInd:nClientHeight -30

					//Label de Índices
					oPnlIndT := TPaintPanel():New( -2 , -2 , nPosWid , nPosHei , oPnlInd , .T.)
	 					oPnlIndT:addShape("id="+cValToChar(nId++)+";type=1;"+;
	 						"left="+cValToChar(nPosWid*_nTamCol2)+";top="+cValToChar(nPosHei*0.10)+";width="+cValToChar(nPosWid*0.99)+";height="+cValToChar(nPosHei*0.25)+";"+;
	 						"gradient=1,0,0,0,0,0.0,#FFFFFF;pen-width=1;pen-color=#DBDBDB;large=1;")

	 					oPnlIndT:addShape("id="+cValToChar(nId++)+";type=1;"+;
	 						"left="+cValToChar(nPosWid*_nTamCol2)+";top="+cValToChar(nPosHei*0.35)+";width="+cValToChar(nPosWid*0.99)+";height="+cValToChar(nPosHei)+";"+;
	 						"gradient=1,0,0,0,0,0.0,#FFFFFF;pen-width=1;pen-color=#DBDBDB;large=1;")
						//------------
						// Cabeçalho
						//------------
					TSay():New( nPosHei * (0.07), nPosWid * (0.02),		{ | | STR0063 } , oPnlIndT , , oFontB , , , , .T. , CLR_BLACK , , nPosWid * (0.05), nPosHei * (0.1) ) //"Índice"

 					TSay():New( nPosHei * (0.07), nPosWid * (0.303),{ | | STR0064 } , oPnlIndT , , oFontB , ,.T. , , .T. , CLR_BLACK , , nPosWid * (0.05) , nPosHei * (0.1) ) //"Total"

 					TSay():New( nPosHei * (0.07), nPosWid * (0.455),	{ | | "%" } , oPnlIndT , , oFontB , , , , .T. , CLR_BLACK , , nPosWid * (0.0125) , nPosHei * (0.1) )
	 					//-----------------------
	 					// Total de Funcionarios
	 					//-----------------------
 					TSay():New( nPosHei * (0.25) , nPosWid * (0.02) ,	{ | | STR0065 } , oPnlIndT , , oFontB , , , , .T. , CLR_BLACK , , nPosWid * (0.175) , nPosHei * (0.1) ) //"Total de Funcionários"

 					TSay():New( nPosHei * (0.25), nPosWid * (0.255), { | | aIndiceGer[_nPosIndTot][_nRowOne] } , oPnlIndT , , oFontB , , .T. , , .T. , CLR_BLACK , , nPosWid * (0.0975) , nPosHei * (0.1) )

						//---------------
						// Absenteísmo
						//---------------
					TSay():New( nPosHei * (0.38), nPosWid * (0.02), { | | STR0001 } , oPnlIndT , , oFontB , , , , .T. , CLR_BLACK , , nPosWid * (0.0975) , nPosHei * (0.1) ) //"Absenteísmo"

 					TSay():New( nPosHei * (0.38), nPosWid * (0.255), { | | aIndiceGer[_nPosIndAbs][_nRowOne] } , oPnlIndT , , oFontB , , .T. , , .T. , CLR_BLACK , , nPosWid * (0.0975) , nPosHei * (0.1) )

 					TSay():New( nPosHei * (0.38), nPosWid * (0.42), { | | aIndiceGer[_nPosIndAbs][_nRowTwo] } , oPnlIndT , "@E 999.99" , oFontB , , .T. , , .T. , CLR_BLACK , , nPosWid * (0.045) , nPosHei * (0.1) )

	 					//-----------
	 					// Acidente
	 					//-----------
 					TSay():New( nPosHei * (0.5), nPosWid * (0.02) , { | | STR0007 } , oPnlIndT , , oFontB , , , , .T. , CLR_BLACK , , nPosWid * (0.0975) , nPosHei * (0.1) ) //"Acidentes"

 					TSay():New( nPosHei * (0.5), nPosWid * (0.255) , { | | aIndiceGer[_nPosIndAci][_nRowOne] } , oPnlIndT , , oFontB , , .T. , , .T. , CLR_BLACK , , nPosWid * (0.0975) , nPosHei * (0.1) )

 					TSay():New( nPosHei * (0.5), nPosWid * (0.42) , { | | aIndiceGer[_nPosIndAci][_nRowTwo] } , oPnlIndT , "@E 999.99" , oFontB , , .T. , , .T. , CLR_BLACK , , nPosWid * (0.045) , nPosHei * (0.1) )

		   //Painel da Parte Inferior
			oPnlBot := TPanel():New( , , , oPnlPai , , , , , , , , .F. , .F. )
		   		oPnlBot:Align := CONTROL_ALIGN_ALLCLIENT

			 	//--------------------------------------------------------------
				// PAINEL GRÁFICO
				//--------------------------------------------------------------
			 	//Parte Direita
			 	oPnlRight := TPanel():New( , , , oPnlBot , , , , , aColor[ 2 ] , aSize[ 5 ] / 4 , , .F. , .F. )
			   		oPnlRight:Align := CONTROL_ALIGN_RIGHT

		  			//Painel Indicadores
			  		oPnlRTop := TPanel():New( , , , oPnlRight , , , , , , , aSize[ 6 ] / 6 , .F. , .F. )
						oPnlRTop:Align := CONTROL_ALIGN_TOP

						oPnlRAll := TPaintPanel():new(  ,  ,  ,  , oPnlRTop , .T.)
						oPnlRAll:Align := CONTROL_ALIGN_ALLCLIENT

					nPosWid := oPnlRAll:nClientWidth
					nPosHei := oPnlRAll:nClientHeight+5
						//-------------------------------------------------
						// Descrição do Centro de Custo
						//-------------------------------------------------
						oPnlRAll:addShape("id="+cValToChar(nId++)+";type=1;"+;
 						"left="+cValToChar(nPosWid*_nTamCol2)+";top="+cValToChar(nPosHei*0.02)+";width="+cValToChar(nPosWid*0.94)+";height="+cValToChar(nPosHei*0.08)+";"+;
							"gradient=1,0,0,0,0,0.0,#FFFFFF;pen-width=1;pen-color=#DBDBDB;large=1;")

 						TSay():New( nPosHei * (_nTamCol2) , nPosWid * (_nTamCol1) , { | | cDescFai } , oPnlRAll , , oFontB , , , , .T. , CLR_BLACK , , nPosWid , nPosWid * (_nTamCol1) )

					//-------------------------------------------------
					// Número de Absenteismo analisados
					//-------------------------------------------------
					oPnlRAll:addShape("id="+cValToChar(nId++)+";type=1;"+;
 					"left="+cValToChar(nPosWid*_nTamCol2)+";top="+cValToChar(nPosHei*0.10)+";width="+cValToChar(nPosWid*0.94)+";height="+cValToChar(nPosHei*0.08)+";"+;
						"gradient=1,0,0,0,0,0.0,#FFFFFF;pen-width=1;pen-color=#DBDBDB;large=1;")

					oTitFai := TSay():New( nPosHei * (0.05), nPosWid * (_nTamCol1) , { | | ( STR0066 + cDescAna + STR0067+Space(1)+ cValToChar(nTotOco) ) } , oPnlRAll , , oFontB , , , , .T. , CLR_BLACK , , nPosHei * (0,38) , nPosWid * (_nTamCol1) ) //"Nº de "###" analisados"
						oTitFai:bChange := { | |  }
					//-------------------------------------------------
					// Faixa | Homens|Ocorrencias|% | Mulheres|Ocorrencias|%
					//-------------------------------------------------
	 						oPnlRAll:addShape("id="+cValToChar(nId++)+";type=1;"+;
 							"left="+cValToChar(nPosWid*_nTamCol2)+";top="+cValToChar(nPosHei*0.18)+";width="+cValToChar(nPosWid*0.20)+";height="+cValToChar(nPosHei*0.08)+";"+;
								"gradient=1,0,0,0,0,0.0,"+aColorH[ 2 ]+";pen-width=1;pen-color="+aColorH[ 2 ]+";large=1;")

 						TSay():New( nPosHei * (_nTamLin1), nPosWid * (_nTamCol3) , { | | ( STR0068 ) } , oPnlRAll , , oFontB , .T. , , , .T. , aColor[ 1 ] , , nPosHei * (_nTamLin11) , nPosWid * (_nTamCol1) ) //"Faixas"

	 						oPnlRAll:addShape("id="+cValToChar(nId++)+";type=1;"+;
	 							"left="+cValToChar(nPosWid*0.21)+";top="+cValToChar(nPosHei*0.18)+";width="+cValToChar(nPosWid*0.37)+";height="+cValToChar(nPosHei*0.08)+";"+;
								"gradient=1,0,0,0,0,0.0,"+aColorH[ 2 ]+";pen-width=1;pen-color="+aColorH[ 2 ]+";large=1;")

								TSay():New( nPosHei * (_nTamLin1),nPosWid * (_nTamCol4) ,		{ | | ( STR0069 ) } , oPnlRAll , , oFontB , .T. , , , .T. , CLR_HBLUE , , nPosHei * (_nTamLin9) , nPosWid * (_nTamCol1) ) //"Homens"

 								TSay():New( nPosHei * (_nTamLin1), nPosWid * (_nTamCol5) ,{ | | ( STR0070 ) } , oPnlRAll , , oFontB ,.T. , , , .T. , CLR_HBLUE , , nPosHei * (_nTamLin9) , nPosWid * (_nTamCol1) ) //"Ocorrências"

								TSay():New( nPosHei * (_nTamLin1), nPosWid * (_nTamCol6) ,	{ | | ( "%" ) } , oPnlRAll , , oFontB , , .T. ,  , .T. , CLR_HBLUE , , 15 , nPosWid * (_nTamCol1) )


	 						oPnlRAll:addShape("id="+cValToChar(nId++)+";type=1;"+;
	 							"left="+cValToChar(nPosWid*0.58)+";top="+cValToChar(nPosHei*0.18)+";width="+cValToChar(nPosWid*0.37)+";height="+cValToChar(nPosHei*0.08)+";"+;
								"gradient=1,0,0,0,0,0.0,"+aColorH[ 2 ]+";pen-width=1;pen-color="+aColorH[ 2 ]+";large=1;")

 									TSay():New( nPosHei * (_nTamLin1), nPosWid * (_nTamCol7) ,	{ | | ( STR0071 ) } , oPnlRAll , , oFontB ,.T. , , , .T. , CLR_HRED , , nPosHei * (_nTamLin9) , nPosWid * (_nTamCol1) ) //"Mulheres"

 									TSay():New( nPosHei * (_nTamLin1), nPosWid * (_nTamCol8) ,{ | | ( STR0070 ) } , oPnlRAll , , oFontB , .T., , , .T. , CLR_HRED , , nPosHei * (_nTamLin9) , nPosWid * (_nTamCol1) ) //"Ocorrências"

 									TSay():New( nPosHei * (_nTamLin1), nPosWid * (_nTamCol9) ,	{ | | ( "%" ) } , oPnlRAll , , oFontB , , .T. ,  , .T. , CLR_HRED , , 15 , nPosWid * (_nTamCol1) )
	 						//-------------------------------------------------
	 						// Faixas
	 						//-------------------------------------------------
	 						oPnlRAll:addShape("id="+cValToChar(nId++)+";type=1;"+;
 							"left="+cValToChar(nPosWid*_nTamCol2)+";top="+cValToChar(nPosHei*0.26)+";width="+cValToChar(nPosWid*0.20)+";height="+cValToChar(nPosHei*0.49)+";"+;
								"gradient=1,0,0,0,0,0.0,#FFFFFF;pen-width=1;pen-color=#DBDBDB;large=1;")

									TSay():New( nPosHei * (_nTamLin2), nPosWid * (_nTamCol3) , { | | ( STR0072 ) } , oPnlRAll , , oFontB ,.T. , , , .T. , CLR_BLACK , , nPosHei * (_nTamLin11) , nPosWid * (_nTamCol1) ) //"Menor de 18"

									TSay():New( nPosHei * (_nTamLin3), nPosWid * (_nTamCol3) , { | | ( STR0073 ) } , oPnlRAll , , oFontB , .T. , , , .T. , CLR_BLACK , , nPosHei * (_nTamLin11) , nPosWid * (_nTamCol1) ) //"18 à 30"

									TSay():New( nPosHei * (0.180), nPosWid * (_nTamCol3) , { | | ( STR0074 ) } , oPnlRAll , , oFontB , .T. , , , .T. , CLR_BLACK , , nPosHei * (_nTamLin11) , nPosWid * (_nTamCol1) ) //"31 à 40"

									TSay():New( nPosHei * (_nTamLin5), nPosWid * (_nTamCol3) , { | | ( STR0075 ) } , oPnlRAll , , oFontB , .T. , , , .T. , CLR_BLACK , , nPosHei * (_nTamLin11) , nPosWid * (_nTamCol1) ) //"41 à 50"

									TSay():New( nPosHei * (_nTamLin6), nPosWid * (_nTamCol3) , { | | ( STR0076 ) } , oPnlRAll , , oFontB , .T. , , , .T. , CLR_BLACK , , nPosHei * (_nTamLin11) , nPosWid * (_nTamCol1) ) //"51 à 60"

									TSay():New( nPosHei * (_nTamLin7), nPosWid * (_nTamCol3) , { | | ( STR0077 ) } , oPnlRAll , , oFontB , .T. , , , .T. , CLR_BLACK , , nPosHei * (_nTamLin11) , nPosWid * (_nTamCol1) ) //"61 à 60"

									TSay():New( nPosHei * (_nTamLin8), nPosWid * (_nTamCol3) , { | | ( STR0078 ) } , oPnlRAll , , oFontB , .T. , , , .T. , CLR_BLACK , , nPosHei * (_nTamLin11) , nPosWid * (_nTamCol1) )											 //"Maior de 70"

								oPnlRAll:addShape("id="+cValToChar(nId++)+";type=1;"+;
	 								"left="+cValToChar(nPosWid*0.21)+";top="+cValToChar(nPosHei*0.26)+";width="+cValToChar(nPosWid*0.37)+";height="+cValToChar(nPosHei*0.49)+";"+;
									"gradient=1,0,0,0,0,0.0,#FFFFFF;pen-width=1;pen-color=#DBDBDB;large=1;")
										//-------------------------------
										// 1/3 - Somatório de Homens
										//-------------------------------

										//"Menor de 18"
									TSay():New( nPosHei * (_nTamLin2), nPosWid * (_nTamCol4) , { | | ( aFaixaGeral[_nPosFaiHom][_nRowOne] ) } , oPnlRAll , , oFontB ,.T. , , , .T. , CLR_BLACK , , nPosHei * (_nTamLin9) , nPosWid * (_nTamCol1) )

										//"18 à 30"
									TSay():New( nPosHei * (_nTamLin3), nPosWid * (_nTamCol4) , { | | ( aFaixaGeral[_nPosFaiHom][_nRowTwo] ) } , oPnlRAll , , oFontB , .T. , , , .T. , CLR_BLACK , , nPosHei * (_nTamLin9) , nPosWid * (_nTamCol1) )

										//"31 à 40"
									TSay():New( nPosHei * (_nTamLin4), nPosWid * (_nTamCol4) , { | | ( aFaixaGeral[_nPosFaiHom][_nRowThree] ) } , oPnlRAll , , oFontB , .T. , , , .T. , CLR_BLACK , , nPosHei * (_nTamLin9) , nPosWid * (_nTamCol1) )

										//"41 à 50"
									TSay():New( nPosHei * (_nTamLin5), nPosWid * (_nTamCol4) , { | | ( aFaixaGeral[_nPosFaiHom][_nRowFour] ) } , oPnlRAll , , oFontB , .T. , , , .T. , CLR_BLACK , , nPosHei * (_nTamLin9) , nPosWid * (_nTamCol1) )

										//"51 à 60"
									TSay():New( nPosHei * (_nTamLin6), nPosWid * (_nTamCol4) , { | | ( aFaixaGeral[_nPosFaiHom][_nRowFive] ) } , oPnlRAll , , oFontB , .T. , , , .T. , CLR_BLACK , , nPosHei * (_nTamLin9) , nPosWid * (_nTamCol1) )

										//"61 á 60"
									TSay():New( nPosHei * (_nTamLin7), nPosWid * (_nTamCol4) , { | | ( aFaixaGeral[_nPosFaiHom][_nRowSix] ) } , oPnlRAll , , oFontB , .T. , , , .T. , CLR_BLACK , , nPosHei * (_nTamLin9) , nPosWid * (_nTamCol1) )

										//"Maior de 70"
									TSay():New( nPosHei * (_nTamLin8), nPosWid * (_nTamCol4) , { | | ( aFaixaGeral[_nPosFaiHom][_nRowSeven] ) } , oPnlRAll , , oFontB , .T. , , , .T. , CLR_BLACK , , nPosHei * (_nTamLin9) , nPosWid * (_nTamCol1) )

										//-------------------------------
										//2/3 - Somatório de Ocorrências
										//-------------------------------

										//"Menor de 18"
									TSay():New( nPosHei * (_nTamLin2), nPosWid * (_nTamCol5) , { | | ( aFaixaGeral[_nPosFaiHCo][_nRowOne] ) } , oPnlRAll , , oFontB ,.T. , , , .T. , CLR_BLACK , , nPosHei * (_nTamLin9) , nPosWid * (_nTamCol1) )

										//"18 à 30"
									TSay():New( nPosHei * (_nTamLin3), nPosWid * (_nTamCol5) , { | | ( aFaixaGeral[_nPosFaiHCo][_nRowTwo] ) } , oPnlRAll , , oFontB , .T. , , , .T. , CLR_BLACK , , nPosHei * (_nTamLin9) , nPosWid * (_nTamCol1) )

										//"31 à 40"
									TSay():New( nPosHei * (_nTamLin4), nPosWid * (_nTamCol5) , { | | ( aFaixaGeral[_nPosFaiHCo][_nRowThree] ) } , oPnlRAll , , oFontB , .T. , , , .T. , CLR_BLACK , , nPosHei * (_nTamLin9) , nPosWid * (_nTamCol1) )

										//"41 à 50"
									TSay():New( nPosHei * (_nTamLin5), nPosWid * (_nTamCol5) , { | | ( aFaixaGeral[_nPosFaiHCo][_nRowFour] ) } , oPnlRAll , , oFontB , .T. , , , .T. , CLR_BLACK , , nPosHei * (_nTamLin9) , nPosWid * (_nTamCol1) )

										//"51 à 60"
									TSay():New( nPosHei * (_nTamLin6), nPosWid * (_nTamCol5) , { | | ( aFaixaGeral[_nPosFaiHCo][_nRowFive] ) } , oPnlRAll , , oFontB , .T. , , , .T. , CLR_BLACK , , nPosHei * (_nTamLin9) , nPosWid * (_nTamCol1) )

										//"61 á 60"
									TSay():New( nPosHei * (_nTamLin7), nPosWid * (_nTamCol5) , { | | ( aFaixaGeral[_nPosFaiHCo][_nRowSix] ) } , oPnlRAll , , oFontB , .T. , , , .T. , CLR_BLACK , , nPosHei * (_nTamLin9) , nPosWid * (_nTamCol1) )

										//"Maior de 70"
									TSay():New( nPosHei * (_nTamLin8), nPosWid * (_nTamCol5) , { | | ( aFaixaGeral[_nPosFaiHCo][_nRowSeven] ) } , oPnlRAll , , oFontB , .T. , , , .T. , CLR_BLACK , , nPosHei * (_nTamLin9) , nPosWid * (_nTamCol1) )

										//-------------------------------
										//3/3 - Percentual de Ocorrencias
										//-------------------------------
										//"Menor de 18"
									TSay():New( nPosHei * (_nTamLin2), nPosWid * (_nTamCol6) , { | | ( aFaixaGeral[_nPosFaiPH][_nRowOne] ) } , oPnlRAll , "@E 999.99" , oFontB ,.T. ,  , , .T. , CLR_BLACK , , nPosHei * (_nTamLin10) , nPosWid * (_nTamCol1) )

										//"18 à 30"
									TSay():New( nPosHei * (_nTamLin3), nPosWid * (_nTamCol6) , { | | ( aFaixaGeral[_nPosFaiPH][_nRowTwo] ) } , oPnlRAll , "@E 999.99" , oFontB ,.T. ,  , , .T. , CLR_BLACK , , nPosHei * (_nTamLin10) , nPosWid * (_nTamCol1) )

										//"31 à 40"
									TSay():New( nPosHei * (_nTamLin4), nPosWid * (_nTamCol6) , { | | ( aFaixaGeral[_nPosFaiPH][_nRowThree] ) } , oPnlRAll , "@E 999.99" , oFontB ,.T. ,  , , .T. , CLR_BLACK , , nPosHei * (_nTamLin10) , nPosWid * (_nTamCol1) )

										//"41 à 50"
									TSay():New( nPosHei * (_nTamLin5), nPosWid * (_nTamCol6) , { | | ( aFaixaGeral[_nPosFaiPH][_nRowFour] ) } , oPnlRAll , "@E 999.99" , oFontB ,.T.,  , , .T. , CLR_BLACK , , nPosHei * (_nTamLin10) , nPosWid * (_nTamCol1) )

										//"51 à 60"
									TSay():New( nPosHei * (_nTamLin6), nPosWid * (_nTamCol6) , { | | ( aFaixaGeral[_nPosFaiPH][_nRowFive] ) } , oPnlRAll , "@E 999.99" , oFontB ,.T. ,  , , .T. , CLR_BLACK , , nPosHei * (_nTamLin10) , nPosWid * (_nTamCol1) )

										//"61 á 60"
									TSay():New( nPosHei * (_nTamLin7), nPosWid * (_nTamCol6) , { | | ( aFaixaGeral[_nPosFaiPH][_nRowSix] ) } , oPnlRAll , "@E 999.99" , oFontB ,.T. ,  , , .T. , CLR_BLACK , , nPosHei * (_nTamLin10) , nPosWid * (_nTamCol1) )

										//"Maior de 70"
									TSay():New( nPosHei * (_nTamLin8), nPosWid * (_nTamCol6) , { | | ( aFaixaGeral[_nPosFaiPH][_nRowSeven] ) } , oPnlRAll , "@E 999.99" , oFontB ,.T. ,  , , .T. , CLR_BLACK , , nPosHei * (_nTamLin10) , nPosWid * (_nTamCol1) )

									oPnlRAll:addShape("id="+cValToChar(nId++)+";type=1;"+;
	 									"left="+cValToChar(nPosWid*0.58)+";top="+cValToChar(nPosHei*0.26)+";width="+cValToChar(nPosWid*0.37)+";height="+cValToChar(nPosHei*0.49)+";"+;
										"gradient=1,0,0,0,0,0.0,#FFFFFF;pen-width=1;pen-color=#DBDBDB;large=1;")

										//-------------------------------
										// 1/3 - Somatório de Mulheres
										//-------------------------------

									//"Menor de 18"
									TSay():New( nPosHei * (_nTamLin2), nPosWid * (_nTamCol7) , { | | ( aFaixaGeral[_nPosFaiMul][_nRowOne] ) } , oPnlRAll , , oFontB ,.T. , , , .T. , CLR_BLACK , , nPosHei * (_nTamLin9) , nPosWid * (_nTamCol1) )

									//"18 à 30"
									TSay():New( nPosHei * (_nTamLin3), nPosWid * (_nTamCol7) , { | | ( aFaixaGeral[_nPosFaiMul][_nRowTwo] ) } , oPnlRAll , , oFontB , .T. , , , .T. , CLR_BLACK , , nPosHei * (_nTamLin9) , nPosWid * (_nTamCol1) )

									//"31 à 40"
									TSay():New( nPosHei * (_nTamLin4), nPosWid * (_nTamCol7) , { | | ( aFaixaGeral[_nPosFaiMul][_nRowThree] ) } , oPnlRAll , , oFontB , .T. , , , .T. , CLR_BLACK , , nPosHei * (_nTamLin9) , nPosWid * (_nTamCol1) )

									//"41 à 50"
									TSay():New( nPosHei * (_nTamLin5), nPosWid * (_nTamCol7) , { | | ( aFaixaGeral[_nPosFaiMul][_nRowFour] ) } , oPnlRAll , , oFontB , .T. , , , .T. , CLR_BLACK , , nPosHei * (_nTamLin9) , nPosWid * (_nTamCol1) )

									//"51 à 60"
									TSay():New( nPosHei * (_nTamLin6), nPosWid * (_nTamCol7) , { | | ( aFaixaGeral[_nPosFaiMul][_nRowFive] ) } , oPnlRAll , , oFontB , .T. , , , .T. , CLR_BLACK , , nPosHei * (_nTamLin9) , nPosWid * (_nTamCol1) )

									//"61 á 60"
									TSay():New( nPosHei * (_nTamLin7), nPosWid * (_nTamCol7) , { | | ( aFaixaGeral[_nPosFaiMul][_nRowSix] ) } , oPnlRAll , , oFontB , .T. , , , .T. , CLR_BLACK , , nPosHei * (_nTamLin9) , nPosWid * (_nTamCol1) )

									//"Maior de 70"
									TSay():New( nPosHei * (_nTamLin8), nPosWid * (_nTamCol7) , { | | ( aFaixaGeral[_nPosFaiMul][_nRowSeven] ) } , oPnlRAll , , oFontB , .T. , , , .T. , CLR_BLACK , , nPosHei * (_nTamLin9) , nPosWid * (_nTamCol1) )

									//-------------------------------
									//2/3 - Somatório de Ocorrências
									//-------------------------------

									//"Menor de 18"
									TSay():New( nPosHei * (_nTamLin2), nPosWid * (_nTamCol8) , { | | ( aFaixaGeral[_nPosFaiMOc][_nRowOne] ) } , oPnlRAll , , oFontB ,.T. , , , .T. , CLR_BLACK , , nPosHei * (_nTamLin9) , nPosWid * (_nTamCol1) )

									//"18 à 30"
									TSay():New( nPosHei * (_nTamLin3), nPosWid * (_nTamCol8) , { | | ( aFaixaGeral[_nPosFaiMOc][_nRowTwo] ) } , oPnlRAll , , oFontB , .T. , , , .T. , CLR_BLACK , , nPosHei * (_nTamLin9) , nPosWid * (_nTamCol1) )

									//"31 à 40"
									TSay():New( nPosHei * (_nTamLin4), nPosWid * (_nTamCol8) , { | | ( aFaixaGeral[_nPosFaiMOc][_nRowThree] ) } , oPnlRAll , , oFontB , .T. , , , .T. , CLR_BLACK , , nPosHei * (_nTamLin9) , nPosWid * (_nTamCol1) )

									//"41 à 50"
									TSay():New( nPosHei * (_nTamLin5), nPosWid * (_nTamCol8) , { | | ( aFaixaGeral[_nPosFaiMOc][_nRowFour] ) } , oPnlRAll , , oFontB , .T. , , , .T. , CLR_BLACK , , nPosHei * (_nTamLin9) , nPosWid * (_nTamCol1) )

									//"51 à 60"
									TSay():New( nPosHei * (_nTamLin6), nPosWid * (_nTamCol8) , { | | ( aFaixaGeral[_nPosFaiMOc][_nRowFive] ) } , oPnlRAll , , oFontB , .T. , , , .T. , CLR_BLACK , , nPosHei * (_nTamLin9) , nPosWid * (_nTamCol1) )

									//"61 á 60"
									TSay():New( nPosHei * (_nTamLin7), nPosWid * (_nTamCol8) , { | | ( aFaixaGeral[_nPosFaiMOc][_nRowSix] ) } , oPnlRAll , , oFontB , .T. , , , .T. , CLR_BLACK , , nPosHei * (_nTamLin9) , nPosWid * (_nTamCol1) )

									//"Maior de 70"
									TSay():New( nPosHei * (_nTamLin8), nPosWid * (_nTamCol8) , { | | ( aFaixaGeral[_nPosFaiMOc][_nRowSeven] ) } , oPnlRAll , , oFontB , .T. , , , .T. , CLR_BLACK , , nPosHei * (_nTamLin9) , nPosWid * (_nTamCol1) )

									//-------------------------------
									//3/3 - Percentual de Ocorrencias
									//-------------------------------
									//"Menor de 18"
									TSay():New( nPosHei * (_nTamLin2), nPosWid * (_nTamCol9) , { | | ( aFaixaGeral[_nPosFaiPM][_nRowOne] ) } , oPnlRAll , "@E 999.99" , oFontB , .T., , , .T. , CLR_BLACK , , nPosHei * (_nTamLin10) , nPosWid * (_nTamCol1) )

									//"18 à 30"
									TSay():New( nPosHei * (_nTamLin3), nPosWid * (_nTamCol9) , { | | ( aFaixaGeral[_nPosFaiPM][_nRowTwo] ) } , oPnlRAll , "@E 999.99" , oFontB , .T., , , .T. , CLR_BLACK , , nPosHei * (_nTamLin10) , nPosWid * (_nTamCol1) )

									//"31 à 40"
									TSay():New( nPosHei * (_nTamLin4), nPosWid * (_nTamCol9) , { | | ( aFaixaGeral[_nPosFaiPM][_nRowThree] ) } , oPnlRAll , "@E 999.99" , oFontB , .T., , , .T. , CLR_BLACK , , nPosHei * (_nTamLin10) , nPosWid * (_nTamCol1) )

									//"41 à 50"
									TSay():New( nPosHei * (_nTamLin5), nPosWid * (_nTamCol9) , { | | ( aFaixaGeral[_nPosFaiPM][_nRowFour] ) } , oPnlRAll , "@E 999.99" , oFontB , .T., , , .T. , CLR_BLACK , , nPosHei * (_nTamLin10) , nPosWid * (_nTamCol1) )

									//"51 à 60"
									TSay():New( nPosHei * (_nTamLin6), nPosWid * (_nTamCol9) , { | | ( aFaixaGeral[_nPosFaiPM][_nRowFive] ) } , oPnlRAll , "@E 999.99" , oFontB , .T., , , .T. , CLR_BLACK , , nPosHei * (_nTamLin10) , nPosWid * (_nTamCol1) )

									//"61 á 60"
									TSay():New( nPosHei * (_nTamLin7), nPosWid * (_nTamCol9) , { | | ( aFaixaGeral[_nPosFaiPM][_nRowSix] ) } , oPnlRAll , "@E 999.99" , oFontB , .T., , , .T. , CLR_BLACK , , nPosHei * (_nTamLin10) , nPosWid * (_nTamCol1) )

									//"Maior de 70"
									TSay():New( nPosHei * (_nTamLin8), nPosWid * (_nTamCol9) , { | | ( aFaixaGeral[_nPosFaiPM][_nRowSeven] ) } , oPnlRAll , "@E 999.99" , oFontB , .T., , , .T. , CLR_BLACK , , nPosHei * (_nTamLin10) , nPosWid * (_nTamCol1) )

						//-------------------------------------------------
						// Total:	|			|			|			|
						//-------------------------------------------------
						oPnlRAll:addShape("id="+cValToChar(nId++)+";type=1;"+;
 							"left="+cValToChar(nPosWid*_nTamCol2)+";top="+cValToChar(nPosHei*0.67)+";width="+cValToChar(nPosWid*0.20)+";height="+cValToChar(nPosHei*0.08)+";"+;
							"gradient=1,0,0,0,0,0.0,#FFFFFF;pen-width=1;pen-color=#DBDBDB;large=1;")

							TSay():New( nPosHei * (_nTamLin12), nPosWid * (_nTamCol3) , { | | ( STR0079 ) } , oPnlRAll , , oFontB , .T. , , , .T. , CLR_BLACK , , nPosHei * (_nTamLin11) , nPosWid * (_nTamCol1) ) //"Total:"

						oPnlRAll:addShape("id="+cValToChar(nId++)+";type=1;"+;
 							"left="+cValToChar(nPosWid*0.21)+";top="+cValToChar(nPosHei*0.67)+";width="+cValToChar(nPosWid*0.37)+";height="+cValToChar(nPosHei*0.08)+";"+;
							"gradient=1,0,0,0,0,0.0,#FFFFFF;pen-width=1;pen-color=#DBDBDB;large=1;")
								//"Homens"
								TSay():New( nPosHei * (_nTamLin12), nPosWid * (_nTamCol4) ,		{ | | aFaixaGeral[_nPosFaiTot][_nRowOne] } , oPnlRAll , , oFontB , .T. , , , .T. , CLR_HBLUE , , nPosHei * (_nTamLin9) , nPosWid * (_nTamCol1) )
								//"Ocorrências"
								TSay():New( nPosHei * (_nTamLin12), nPosWid * (_nTamCol5) ,{ | | aFaixaGeral[_nPosFaiTot][_nRowTwo] } , oPnlRAll , , oFontB ,.T. , , , .T. , CLR_HBLUE , , nPosHei * (_nTamLin9) , nPosWid * (_nTamCol1) )
								//"%"
								TSay():New( nPosHei * (_nTamLin12), nPosWid * (_nTamCol6) ,	{ | | aFaixaGeral[_nPosFaiTot][_nRowThree] } , oPnlRAll , "@E 999.99" , oFontB , .T. , ,  , .T. , CLR_HBLUE , , nPosHei * (_nTamLin10) , nPosWid * (_nTamCol1) )

						oPnlRAll:addShape("id="+cValToChar(nId++)+";type=1;"+;
 							"left="+cValToChar(nPosWid*0.58)+";top="+cValToChar(nPosHei*0.67)+";width="+cValToChar(nPosWid*0.37)+";height="+cValToChar(nPosHei*0.08)+";"+;
							"gradient=1,0,0,0,0,0.0,#FFFFFF;pen-width=1;pen-color=#DBDBDB;large=1;")

								//"Mulheres"
								TSay():New( nPosHei * (_nTamLin12), nPosWid * (_nTamCol7) ,	{ | | aFaixaGeral[_nPosFaiTot][_nRowFour] } , oPnlRAll , , oFontB , .T. , , , .T. , CLR_HRED , , nPosHei * (_nTamLin9) , nPosWid * (_nTamCol1) )
								//"Ocorrências"
								TSay():New( nPosHei * (_nTamLin12), nPosWid * (_nTamCol8) ,{ | | aFaixaGeral[_nPosFaiTot][_nRowFive] } , oPnlRAll , , oFontB ,.T. , , , .T. , CLR_HRED , , nPosHei * (_nTamLin9) , nPosWid * (_nTamCol1) )
								//"%"
								TSay():New( nPosHei * (_nTamLin12), nPosWid * (_nTamCol9) ,	{ | | aFaixaGeral[_nPosFaiTot][_nRowSix] } , oPnlRAll , "@E 999.99" , oFontB , .T. , ,  , .T. , CLR_HRED , , nPosHei * (_nTamLin10) , nPosWid * (_nTamCol1) )

				//-------------------------------------------------
				// Total Funcionários Análisados
				//-------------------------------------------------
				oPnlRAll:addShape("id="+cValToChar(nId++)+";type=1;"+;
 					"left="+cValToChar(nPosWid*_nTamCol2)+";top="+cValToChar(nPosHei*0.75)+";width="+cValToChar(nPosWid*0.94)+";height="+cValToChar(nPosHei*0.11)+";"+;
					"gradient=1,0,0,0,0,0.0,#FFFFFF;pen-width=1;pen-color=#DBDBDB;large=1;")

								TSay():New( nPosHei * (0.382), nPosWid * (_nTamCol1) , { | | ( STR0080+Space(1)+ cValToChar(nTotFun) ) } , oPnlRAll , , oFontB , , , , .T. , CLR_BLACK , , 300 , nPosWid * (_nTamCol1) ) //"Total de Funcionários Analisados"

								TSay():New( nPosHei * (0.382), nPosWid * (0.250) , { | | ( STR0081+Space(1)+ cValToChar(aSexoGeral[_nRowOne][_nPosHSex])+Space(1)+"%" ) } , oPnlRAll , , oFontB , , , , .T. , CLR_HBLUE , , nPosHei * (0,38) , nPosWid * (_nTamCol1) ) //"Homens:"

								TSay():New( nPosHei * (0.382), nPosWid * (0.350) , { | | ( STR0082+Space(1)+ cValToChar(aSexoGeral[_nRowOne][_nPosMSex])+Space(1)+"%" ) } , oPnlRAll , , oFontB , , , , .T. , CLR_HRED , , nPosHei * (0,38) , nPosWid * (_nTamCol1) ) //"Mulheres:"

					oPnlRTTit  := TPanel():New( , , , oPnlRTop , , , , , aColor[ 2 ] , , 10 , .F. , .F. )
						oPnlRTTit:Align := CONTROL_ALIGN_TOP

						TSay():New( 002 , 014 , { | | STR0083 } , oPnlRTTit , , , , , , .T. , aColor[ 1 ] , , 040 , 008 ) //"Faixa Etária"

							//TPaintPanel - Faixas Etárias
						oPnlRTBtn  := TPanel():New( , , , oPnlRTop , , , , , aColor[ 2 ] , 12 , , .F. , .F. )
							oPnlRTBtn:Align := CONTROL_ALIGN_LEFT

							oBtnRefres1  := TBtnBmp():NewBar( "ng_ico_refresh" , "ng_ico_refresh" , , , , { | | fRefresh( , , 1 , aCpsList , cTRBPrinc , cCmbVis , aCpsSX3 , aDefVirtu ,  dDtIni , dDtFim , cFilIni , cFilFim, cCmbTip , cCmbPer , aItensTip , fGetCbx( cCmbTip , aItensTip , { aItensAbs , aItensExa , aItensDia , aItensDoe , aItensAci } ) , aItensPer ) } , , oPnlRTBtn )
								oBtnRefres1:cToolTip := STR0084 //"Atualizar"
								oBtnRefres1:Align		:= CONTROL_ALIGN_TOP
							oBtnRelFaix  := TBtnBmp():NewBar( "ng_ico_imp" , "ng_ico_imp" , , , , { | | fImpressoes( 1 ) } , , oPnlRTBtn )
								oBtnRelFaix:cToolTip := STR0085 //"Relatório"
								oBtnRelFaix:Align    := CONTROL_ALIGN_TOP

					//--------------------------------------------------------------
					//PAINEL GRÁFICO
					//--------------------------------------------------------------
					oPnlRBot := TPanel():New( , , , oPnlRight , , , , , , , aSize[ 6 ] / 6 , .F. , .F. )
			   	   		oPnlRBot:Align := CONTROL_ALIGN_ALLCLIENT

			   			oPnlRBTit  := TPanel():New( , , , oPnlRBot , , , , , aColor[ 2 ] , , 10 , .F. , .F. )
							oPnlRBTit:Align := CONTROL_ALIGN_TOP

							TSay():New( 002 , 014 , { | | STR0086 } , oPnlRBTit , , , , , , .T. , aColor[ 1 ] , , 040 , 008 ) //"Gráfico"

							//Cria o grafico pela primeira vez.
							If ValType( oGraphic ) <> "O"
								fMontaGraph( oPnlRBot , @oGraphic , .T. )//Montagem do grafico.
							EndIf

						oPnlRBBtn  := TPanel():New( , , , oPnlRBot , , , , , aColor[ 2 ] , 12 , , .F. , .F. )
							oPnlRBBtn:Align := CONTROL_ALIGN_LEFT

							oBtnRefres2  := TBtnBmp():NewBar( "ng_ico_refresh" , "ng_ico_refresh" , , , , { | | fRefresh( oPnlRBot , @oGraphic , 2 , aCpsList , cTRBPrinc , cCmbVis , aCpsSX3 , aDefVirtu ) } , , oPnlRBBtn )
								oBtnRefres2:cToolTip := STR0084 //"Atualizar"
								oBtnRefres2:Align		:= CONTROL_ALIGN_TOP
						oBtnRelGraf  := TBtnBmp():NewBar( "ng_ico_imp" , "ng_ico_imp" , , , , { | | Processa( { | lEnd | fImpGraphic( oGraphic , STR0086 , .T. , cTRBPrinc , aCpsList, cCmbVis , aCpsSX3 , oPnlRBot , aDefVirtu ) } ) } , , oPnlRBBtn ) //"Gráfico"
								oBtnRelGraf:cToolTip := STR0085 //"Relatório"
								oBtnRelGraf:Align    := CONTROL_ALIGN_TOP
							oBtnLegGraf  := TBtnBmp():NewBar( "ng_ico_grafpizza" , "ng_ico_grafpizza" , , , , { | | fMaximize( oPnlRBot , @oGraphic , aCpsList , cTRBPrinc , cCmbVis , aCpsSX3 , aDefVirtu ) , fRefresh( oPnlRBot , @oGraphic , 2 , aCpsList , cTRBPrinc , cCmbVis , aCpsSX3 , aDefVirtu ) } , , oPnlRBBtn )
								oBtnLegGraf:cToolTip := STR0087 //"Expandir"
								oBtnLegGraf:Align		:= CONTROL_ALIGN_TOP
			   	//Botão omitivo
			   	oBtnShow := TButton():New( 002 , 002 , ">" , oPnlBot , { | x , y | ( oBtnShow:cTitle := If( oBtnShow:cTitle == ">" , "<" , ">" ), HideGraf( oPnlRight ) ) } , ;
		                   						5 , 10 , , , .F. , .T. , .F. , , .F. , , , .F. )
					oBtnShow:Align := CONTROL_ALIGN_RIGHT

				//--------------------------------------------------------------
				// PAINEL DE LISTAGENS
				//--------------------------------------------------------------

			   	//Parte Esquerda
			 	oPnlLeft := TPanel():New( , , , oPnlBot , , , , , , aSize[ 5 ] / 4 , , .F. , .F. )
			   		oPnlLeft:Align := CONTROL_ALIGN_ALLCLIENT

			  		oSplitter := TSplitter():New( , , oPnlLeft , , , 1 )
						oSplitter:Align := CONTROL_ALIGN_ALLCLIENT

			   	   		//Listagem Princial
						oPnlLTop := TPanel():New( , , , oSplitter , , , , , CLR_RED , , aSize[ 6 ] / 5 , .F. , .F. )
				   	   		oPnlLTop:Align := CONTROL_ALIGN_TOP

							//Botões da Listagem Princial
							oPnlLTBtn  := TPanel():New( , , , oPnlLTop , , , , , aColor[ 2 ] , 12 , , .F. , .F. )
								oPnlLTBtn:Align := CONTROL_ALIGN_LEFT

								oBtnRelLis1  := TBtnBmp():NewBar( "ng_ico_imp" , "ng_ico_imp" , , , , { | | fImpressoes( 3 ) } , , oPnlLTBtn )
									oBtnRelLis1:cToolTip := STR0085 //"Relatório"
									oBtnRelLis1:Align    := CONTROL_ALIGN_TOP
								oBtnRetorno  := TBtnBmp():NewBar( "ng_ico_voltaniv" , "ng_ico_voltaniv" , , , , { | | fRetornaNivel( aCpsList , cCmbTip , cCmbVis , cCmbPer , oPnlList1 , oPnlList2 , aCpsSX3 , aTabPrinc , cTRBPrinc , cTRBSec , dDtIni , dDtFim , cFilIni , cFilFim , aItensTip , fGetCbx( cCmbTip , aItensTip , { aItensAbs , aItensExa , aItensDia , aItensDoe , aItensAci } ) , aItensPer , aDefVirtu , oBtnVisual , oBtnAvNivel , oBtnResul ) } , , oPnlLTBtn )
									oBtnRetorno:cToolTip := STR0088 //"Retorna Nível"
									oBtnRetorno:Align		:= CONTROL_ALIGN_TOP

							oPnlList1  := TPanel():New( , , , oPnlLTop , , , , , aColor[ 2 ] , , , .F. , .F. )
								oPnlList1:Align := CONTROL_ALIGN_ALLCLIENT

								oListPrinc := fMontaList( 1 , 0 , aCpsList , cCmbTip , cCmbVis , cCmbPer , oPnlList1 , aCpsSX3 , aTabPrinc , cTRBPrinc , dDtIni , dDtFim , cFilIni , cFilFim , aItensTip , fGetCbx( cCmbTip , aItensTip , { aItensAbs , aItensExa , aItensDia , aItensDoe , aItensAci } ) , aItensPer , , aDefVirtu )
									//Define a forma da troca de Linhas apos todos os Objetos montados
									bChange := { | | fAtuGeral( .T. , oDtIni , oDtFim , oFilIni , oFilFim , oCmbTip , oCmbVis , oCmbPer , oPnlBot , aCpsList , cCmbTip , cCmbVis , cCmbPer , oPnlList1 , oPnlList2 , aCpsSX3 , aTabPrinc , cTRBPrinc , cTRBSec , dDtIni , dDtFim , cFilIni , cFilFim , aItensTip , fGetCbx( cCmbTip , aItensTip , { aItensAbs , aItensExa , aItensDia , aItensDoe , aItensAci } ) , aItensPer , aDefVirtu , .T. , , oBtnVisual , oBtnAvNivel , oBtnResul ) }
								 	oListPrinc:SetChange( bChange )

							//Rodapé da Listagem Principal
							oPnlLTBot  := TPanel():New( , , , oPnlLTop , , , , , aColor[ 2 ] , , 10 , .F. , .F. )
								oPnlLTBot:Align := CONTROL_ALIGN_BOTTOM

								If MV_PAR01 == 1
									TSay():New( 002 , 014 , { | | STR0079 } , oPnlLTBot , , , , , , .T. , aColor[ 1 ] , , 040 , 008 ) //"Total:"
									TSay():New( 002 , 034 , { | | nQtdPri } , oPnlLTBot , , , , , , .T. , aColor[ 1 ] , , 040 , 008 )

									oSayHrs1 := TSay():New( 002 , 084 , { | | STR0089 } , oPnlLTBot , , , , , , .T. , aColor[ 1 ] , , 040 , 008 ) //"Horas:"
									oSayQHrs1 := TSay():New( 002 , 104 , { | | nHrsPri } , oPnlLTBot , , , , , , .T. , aColor[ 1 ] , , 040 , 008 )

									TSay():New( 002 , 160 , { | | STR0081 } , oPnlLTBot , , , , , , .T. , CLR_HBLUE , , 040 , 008 ) //"Homens:"
									TSay():New( 002 , 185 , { | | nQtdHPri } , oPnlLTBot , , , , , , .T. , CLR_HBLUE , , 040 , 008 )

									TSay():New( 002 , 220 , { | | STR0082 } , oPnlLTBot , , , , , , .T. , CLR_HRED , , 040 , 008 ) //"Mulheres:"
									TSay():New( 002 , 245 , { | | nQtdMPri } , oPnlLTBot , , , , , , .T. , CLR_HRED , , 040 , 008 )
								EndIf

						//Listagem Secundária
						oPnlLBot := TPanel():New( , , , oSplitter , , , , , CLR_BLACK , , aSize[ 6 ] / 5 , .F. , .F. )
				   	   		oPnlLBot:Align := CONTROL_ALIGN_ALLCLIENT

				   	   		//Botões da Listagem Secundária
				   	   		oPnlLBBtn  := TPanel():New( , , , oPnlLBot , , , , , aColor[ 2 ] , 12 , , .F. , .F. )
								oPnlLBBtn:Align := CONTROL_ALIGN_LEFT

								bDblClick := { | | fAtuGeral( .T. , oDtIni , oDtFim , oFilIni , oFilFim , oCmbTip , oCmbVis , oCmbPer , oPnlBot , aCpsList , cCmbTip , cCmbVis , cCmbPer , oPnlList1 , oPnlList2 , aCpsSX3 , aTabPrinc , cTRBPrinc , cTRBSec , dDtIni , dDtFim , cFilIni , cFilFim , aItensTip , fGetCbx( cCmbTip , aItensTip , { aItensAbs , aItensExa , aItensDia , aItensDoe , aItensAci } ) , aItensPer , aDefVirtu , , .T. , oBtnVisual , oBtnAvNivel , oBtnResul ) }
								oBtnAvNivel  := TBtnBmp():NewBar( "ng_ico_avancniv" , "ng_ico_avancniv" , , , , bDblClick , , oPnlLBBtn )
									oBtnAvNivel:cToolTip := STR0090 //"Avança Nível"
									oBtnAvNivel:Align    := CONTROL_ALIGN_TOP

								oBtnVisual  := TBtnBmp():NewBar( "ng_ico_visual" , "ng_ico_visual" , , , , { | | fVisual( cTRBSec , aTabPrinc , cCmbTip ) } , , oPnlLBBtn )
									oBtnVisual:cToolTip := STR0044 //"Visualizar"
									oBtnVisual:Align    := CONTROL_ALIGN_TOP
									oBtnVisual:Hide()

								oBtnRelLis2  := TBtnBmp():NewBar( "ng_ico_imp" , "ng_ico_imp" , , , , { | | fImpressoes( 4 ) } , , oPnlLBBtn )
									oBtnRelLis2:cToolTip := STR0085 //"Relatório"
									oBtnRelLis2:Align    := CONTROL_ALIGN_TOP

								oBtnResul  := TBtnBmp():NewBar( "ng_ico_exame1" , "ng_ico_exame1" , , , , { | | fResultado( cTRBSec , aTabPrinc , cCmbTip ) } , , oPnlLBBtn )
										oBtnResul:cToolTip := STR0012 //"Resultado"
										oBtnResul:Align    := CONTROL_ALIGN_TOP
										oBtnResul:Hide()

							oPnlList2  := TPanel():New( , , , oPnlLBot , , , , , aColor[ 2 ] , , , .F. , .F. )
								oPnlList2:Align := CONTROL_ALIGN_ALLCLIENT

								oListSecun := fMontaList( 2 , 0 , aCpsList , cCmbTip , cCmbVis , cCmbPer , oPnlList2 , aCpsSX3 , aTabPrinc , cTRBSec , dDtIni , dDtFim , cFilIni , cFilFim , aItensTip , fGetCbx( cCmbTip , aItensTip , { aItensAbs , aItensExa , aItensDia , aItensDoe , aItensAci } ) , aItensPer , , aDefVirtu )
									//oListSecun:SetDoubleClick( bDblClick )
							//Rodapé da Listagem Secundária
							oPnlLBBot  := TPanel():New( , , , oPnlLBot , , , , , aColor[ 2 ] , , 10 , .F. , .F. )
								oPnlLBBot:Align := CONTROL_ALIGN_BOTTOM

								If MV_PAR01 == 1
									TSay():New( 002 , 014 , { | | STR0079 } , oPnlLBBot , , , , , , .T. , aColor[ 1 ] , , 040 , 008 ) //"Total:"
									TSay():New( 002 , 034 , { | | nQtdSec } , oPnlLBBot , , , , , , .T. , aColor[ 1 ] , , 040 , 008 )

									oSayHrs2 := TSay():New( 002 , 084 , { | | STR0089 } , oPnlLBBot , , , , , , .T. , aColor[ 1 ] , , 040 , 008 ) //"Horas:"
									oSayQHrs2 := TSay():New( 002 , 104 , { | | nHrsSec } , oPnlLBBot , , , , , , .T. , aColor[ 1 ] , , 040 , 008 )

									TSay():New( 002 , 160 , { | | STR0081 } , oPnlLBBot , , , , , , .T. , CLR_HBLUE , , 040 , 008 ) //"Homens:"
									TSay():New( 002 , 185 , { | | nQtdHSec } , oPnlLBBot , , , , , , .T. , CLR_HBLUE , , 040 , 008 )

									TSay():New( 002 , 220 , { | | STR0082 } , oPnlLBBot , , , , , , .T. , CLR_HRED , , 040 , 008 ) //"Mulheres:"
									TSay():New( 002 , 245 , { | | nQtdMSec } , oPnlLBBot , , , , , , .T. , CLR_HRED , , 040 , 008 )
								EndIf
			oPnlBot:Disable()//Desabilita o Painel Gestor

			If MV_PAR02 <> 1
				oBtnShow:Hide()
				oPnlRight:Hide()
				oPnlInd:Hide()
			EndIf

		//Ativacao do Dialog
		Activate MsDialog oDialog Centered On Init EnchoiceBar( oDialog , bConfirm , bCancel )

		If Select( cTRBPrinc ) > 0
			( cTRBPrinc )->( dbCloseArea() )
		EndIf

		If Select( cTRBSec ) > 0
			( cTRBSec )->( dbCloseArea() )
		EndIf
	EndIf

	//-------------------------------------------------
	// Devolve variaveis armazenadas (NGRIGHTCLICK)
	//-------------------------------------------------
	NGRETURNPRM( aNGBEGINPRM )

	SetKey( VK_F12 , { | | } )

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fChangeTipBox
Troca de opções do box de tipos

@param cTipo Caracter Opção selecionada no combo de Tipos
@param oCombo Objeto Objeto do Combo de Agrupadores
@param aItens Array Itens a serem exibidos no Agrupadro
@param cFilIni Caracter Valor do Filtro Inicial
@param cFilFim Caracter Valor do Filtro Final
@param cF3Pesq Define a consulta F3 a ser utilizada
@param oSayHrs1 Objeto da Quantidade de Horas da Primeira Listagem
@param oSayHrs2 Objeto da Quantidade de Horas da Segunda Listagem
@param oSayQHrs1 Objeto do Valor da Quantidade de Horas da Primeira Listagem
@param oSayQHrs2 Objeto do Valor da  Quantidade de Horas da Segunda Listagem

@sample
HideGraf( oObjeto )

@author Jackson Machado
@since 09/07/2014
/*/
//---------------------------------------------------------------------
Static Function fChangeTipBox( cTipo , oCombo , aItens , cFilIni , cFilFim , cF3Pesq , oSayHrs1 , oSayHrs2 , oSayQHrs1 , oSayQHrs2)

	cF3Pesq := "CTT"
	cFilIni	:= Space( Len( CTT->CTT_CUSTO ) )
	cFilFim	:= Replicate( "Z" , Len( CTT->CTT_CUSTO ) )

	oCombo:SetItems( aItens )
	oCombo:Select( 1 )
	oCombo:Refresh()

	If MV_PAR01 == 1
		If cTipo == STR0001  //"Absenteísmo"
			oSayHrs1:Show()
			oSayHrs2:Show()
			oSayQHrs1:Show()
			oSayQHrs2:Show()
		Else
			oSayHrs1:Hide()
			oSayHrs2:Hide()
			oSayQHrs1:Hide()
			oSayQHrs2:Hide()
		EndIf
	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetCbx
Retorna o campo selecionado

@param cCmbTip Caracter Valor do Combo de Tipo de Visualização
@param aCmbTip Array Array contendo as opções do combo Tipo
@param aArrays Arrays contendo dos combos para o Tipo de Visualização

@sample
HideGraf( oObjeto )

@author Jackson Machado
@since 09/07/2014
/*/
//---------------------------------------------------------------------
Static Function fGetCbx( cCmbTip , aCmbTip , aArrays )

	Local nPosCmb

	//Busca o valor selecionado
	nPosCmb := aScan( aCmbTip , { | x | x == cCmbTip } )

Return aArrays[ nPosCmb ]

//---------------------------------------------------------------------
/*/{Protheus.doc} fChangeVisBox
Troca de opções do box de agrupadores

@param aCorresp Array Array contendo as relações
@param cCmbVis Caracter Valor do Combo de Agrupador de Visualização
@param cFilIni Caracter Valor do Filtro Inicial
@param cFilFim Caracter Valor do Filtro Final
@param cF3Pesq Define a consulta F3 a ser utilizada
@param oFilIni Objeto Objeto do Valor Início
@param oFilFim Objeto Objeto do Valor Fim

@sample
HideGraf( oObjeto )

@author Jackson Machado
@since 09/07/2014
/*/
//---------------------------------------------------------------------
Static Function fChangeVisBox( aCorresp , cCmbVis , cFilIni , cFilFim , cF3Pesq , oFilIni , oFilFim )

	Local nPosCmb
	Local nLenCmp
	Local cCampo

	oFilIni:Enable()
	oFilFim:Enable()

	If ( nPosCmb := aScan( aCorresp , { | x | x[ 1 ] == cCmbVis } ) ) > 0
		If ValType( aCorresp[ nPosCmb , _nPosCmp ] ) <> "N"
			cCampo	:= aCorresp[ nPosCmb , _nPosTbl ] + "->" + aCorresp[ nPosCmb , _nPosCmp ]
			nLenCmp := Len( &( cCampo ) )
		Else
			nLenCmp := aCorresp[ nPosCmb , _nPosCmp ]
		EndIf
		cFilIni	:= Space( nLenCmp )
		cFilFim	:= Replicate( "Z" , nLenCmp )
		cF3Pesq := aCorresp[ nPosCmb , _nPosSXB ]
		oFilIni:cF3 := cF3Pesq
		oFilFim:cF3 := cF3Pesq
		oFilIni:Refresh()
		oFilFim:Refresh()
	Else
		cFilIni	:= Space( 6 )
		cFilFim	:= Replicate( "Z" , 6 )
		oFilIni:Refresh()
		oFilFim:Refresh()
		oFilIni:Disable()
		oFilFim:Disable()
	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} HideGraf
Omite painel gráfico

@param oPnlGraf Objeto Painel a ser omitido

@sample
HideGraf( oObjeto )

@author Jackson Machado
@since 09/07/2014
/*/
//---------------------------------------------------------------------
Static Function HideGraf( oPnlGraf )

	If oPnlGraf:lVisible
		oPnlGraf:Hide()
	Else
		oPnlGraf:Show()
	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fImpressoes
Monta a impressão

@param nPnlImp Numerico Indica o tipo de impressao: 1 - Faixa; 2 - Gráfico; 3 - Listagem Principal; 4 - Listagem Secundária

@sample
fImpressoes( 1 )

@author Jackson Machado
@since 09/07/2014
/*/
//---------------------------------------------------------------------
Static Function fImpressoes( nPnlImp )

	Local oReport

	If nPnlImp == 1
		Private oSection1
		oReport := ReportDef()
		oReport:PrintDialog()
	ElseIf nPnlImp == 3
		oListPrinc:Report()
	ElseIf nPnlImp == 4
		oListSecun:Report()
	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Inicia a impressão do Relatório (Definições)

@sample
ReportDef()

@author Guilherme Benkendorf
@since 17/07/2014
/*/
//---------------------------------------------------------------------
Static Function ReportDef()

	Local oReport

	oReport := TReport():New("MDTC500",OemToAnsi(STR0094),/*uParam*/,{|oReport| ReportPrint(oReport)},, .F.) //"Faixa Etárias"

	oSection1 := TRSection():New(oReport,STR0094,{" "} )//"Faixa Etárias" //"Faixa Etárias"
	TRCell():New(oSection1,"FAIXA_1"," ",STR0068,/*Picture*/,20/*Tamanho*/,.T./*lPixel*/,{|| cImpFaixa }) //"Faixas" //"Faixas"
	TRCell():New(oSection1,"FAIXA_2"," ",STR0069,/*Picture*/,/*Tamanho*/,.T./*lPixel*/,{|| aFaixaImp[nPosImp,_nRowOne] },,,,,,,,CLR_HBLUE) //"Homens" //"Homens"
	TRCell():New(oSection1,"FAIXA_3"," ",STR0070,/*Picture*/,/*Tamanho*/,.T./*lPixel*/,{|| aFaixaImp[nPosImp,_nRowTwo] },,,,,,,,CLR_HBLUE) //"Ocorrências" //"Ocorrências"
	TRCell():New(oSection1,"FAIXA_4"," ","%",/*Picture*/,5/*Tamanho*/,.T./*lPixel*/,{|| aFaixaImp[nPosImp,_nRowThree] },,,"RIGHT",,,,,CLR_HBLUE) //"%"
	TRCell():New(oSection1,"FAIXA_5"," ",STR0071,/*Picture*/,/*Tamanho*/,.T./*lPixel*/,{|| aFaixaImp[nPosImp,_nRowFour] },,,,,,,,CLR_HRED) //"Mulheres" //"Mulheres"
	TRCell():New(oSection1,"FAIXA_6"," ",STR0070,/*Picture*/,/*Tamanho*/,.T./*lPixel*/,{|| aFaixaImp[nPosImp,_nRowFive] },,,,,,,,CLR_HRED) //"Ocorrências" //"Ocorrências"
	TRCell():New(oSection1,"FAIXA_7"," ","%",/*Picture*/,5/*Tamanho*/,.T./*lPixel*/,{|| aFaixaImp[nPosImp,_nRowSix] },,,"RIGHT",,,,,CLR_HRED) //"%"

Return oReport

//---------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Inicia a impressão do Relatório (Valores)

@param oReport Objeto Indica o objeto do TReport

@sample
ReportDef( oReport )

@author Guilherme Benkendorf
@since 17/07/2014
/*/
//---------------------------------------------------------------------
Static Function ReportPrint( oReport )

	Local nX, nY
	Local aFaixas := { STR0072 , STR0073 , STR0074 , STR0075 , STR0076 , STR0077 , STR0078, STR0064 } //"Menor de 18"###"18 à 30"###"31 à 40"###"41 à 50"###"51 à 60"###"61 à 70"###"Maior de 70"###"Total"
	Local aFaixaTot := {}
	Local aFaixaTmp := aClone( aFaixaGeral )
	Private nPosImp
	Private aFaixaImp := Array( _nRowSeven + 1 , _nRowSix ) //7x6

	oReport:PrintText( cDescFai ,oReport:nRow,010, , , ,.T.)
	oReport:IncRow()
	oReport:PrintText( STR0066 + cDescAna + STR0067+":"+Space(1)+ cValToChar(nTotOco) ,oReport:nRow,010, , , ,.T.) //"Nº de "###" analisados"
	oReport:IncRow()
	oSection1:Init()

	//Separa os totalizadores
	aFaixaTot := aFaixaTmp[ Len( aFaixaTmp ) ]
	aDel( aFaixaTmp , Len( aFaixaTmp ) )
	aSize( aFaixaTmp , Len( aFaixaTmp ) - 1 )

	//Inverte posições
	For nX := 1 To Len( aFaixaTmp )
		For nY := 1 To Len( aFaixaTmp[ nX ] )
			aFaixaImp[ nY , nX ] := aFaixaTmp[ nX , nY ]
		Next nY
	Next nX

	//Joga os totalizadores invertidos
	For nX := 1 To Len( aFaixaTot )
		If nX <> Len( aFaixaTot )//Desconsidera a ultima posição que não é utilizada
			aFaixaImp[ Len( aFaixaImp ) , nX ] := aFaixaTot[ nX ]
		EndIf
	Next nX

	For nX := 1 To Len( aFaixaImp )

		cImpFaixa := aFaixas[nX]
		nPosImp := nX

		oSection1:PrintLine()

	Next nX

	oSection1:Finish()
	oReport:IncRow()
	oReport:PrintText(STR0080+":"+Space(1)+ cValToChar(nTotFun)  ,oReport:nRow,010, , , ,.T.) //"Total de Funcionários Analisados"
	oReport:IncRow()
	oReport:PrintText(STR0081+Space(1)+ cValToChar(aSexoGeral[_nRowOne][_nPosHSex])+Space(1)+"%" ,oReport:nRow,010, CLR_HBLUE , , ,.T.) //"Homens:"
	oReport:PrintText(STR0082+Space(1)+ cValToChar(aSexoGeral[_nRowOne][_nPosMSex])+Space(1)+"%" ,oReport:nRow,200,CLR_HRED , , ,.T.) //"Mulheres:"


Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fRefresh
Atualiza o Objeto TPTpanel/TMSGraphic

@return

@param oPai: Objeto Pai
@param oObj: Objeto a ser atualizado
@param nObj: Numeração correspondente ao objeto a ser atualiza

@sample
fRefresh( oPnlRBot , @oGraphic , 2 )

@author Bruno Lobo / Guilherme Benkendorf
@since 14/07/2014
/*/
//---------------------------------------------------------------------
Static Function fRefresh( oPai , oObj , nObj , aFldList , cTrbPrin , cBoxVis , aFldSx3 , aDefVirtu ,  dDtIni , dDtFim , cFilIni , cFilFim, cCmbTip , cCmbPer , aItensTip , aItensVis , aItensPer )

	Local nTotFor
	Local nCps
	Local nPosCmp
	Local nPosTit
	Local nPosSX3
	Local nPosDef
	Local nPosTip := aScan( aItensTip , { | x | x == cCmbTip } )
	Local nPosVis := aScan( aItensVis , { | x | x == cBoxVis } )
	Local nPosPer := aScan( aItensPer , { | x | x == cCmbPer } )
	Local cAlsFai
	Local cAlsTot
	Local cAlsOco
	Local cAlsSex
	Local cDescri := ""
	Local cKey    := ""
	Local cCmpDes := ""
	Local cQryFai := ""
	Local cQryTot := "" //Instrução para Query de Totalizador
	Local cQryOco := ""
	Local cQrySex := ""
	Local aCpsDef
	Local aStrSX3
	Local xValue

	If nObj == 1
		cAlsFai := GetNextAlias()
		cAlsTot := GetNextAlias()
		cAlsOco := GetNextAlias()
		cAlsSex := GetNextAlias()

		If nNivBrw >= nNivLim
			nPosPer := 2
		EndIf

		nPosTit := aScan( aFldList , { | x | x[ 1 ] == cBoxVis } )
		nPosCmp := aScan( aFldSx3 , { | x | x[ 1 ] == cBoxVis } )
		aCpsDef := aFldList[ nPosTit , 2 ]//Salva os campos pré-definidos
		aStrSX3 := If( nPosCmp > 0 , aFldSx3[ nPosCmp , 2 ] , {} )
		If Len( aCpsDef ) > 2
			If aCpsDef[ 3 ] == STR0035 //"Pressão Arterial"
				nTotFor := 3
			Else
				nTotFor := 4
			EndIf
			For nCps := 3 To nTotFor//Percorre a posição de código e descrição
				If Len( aCpsDef ) >= nCps
				    	//Pesquisa se é um campo de SX3
					If ( nPosSX3 := aScan( aStrSX3 , { | x | x[ 1 ] == aCpsDef[ nCps ] } ) ) > 0
						If nCps == 3
							cKey := aStrSX3[ nPosSX3 , 2 ]
						Else
							cCmpDes := aStrSX3[ nPosSX3 , 2 ]
						EndIf
					ElseIf ( nPosDef := aScan( aDefVirtu , { | x | x[ _nPosTitle ] == aCpsDef[ nCps ] } ) ) > 0//Pesquisa se é um campo pré-definido
						If nCps == 3
							cKey := aDefVirtu[ nPosDef , _nPosCampo ]
						Else
							cCmpDes := aDefVirtu[ nPosDef , _nPosCampo ]
						EndIf
					EndIf
				EndIf
			Next nCps
			xValue := ( cTrbPrin )->( &( cKey ) )
			If !Empty( cCmpDes )
				cDescri := ( cTrbPrin )->( &( cCmpDes ) )
			Else
				cDescri := Nil
			EndIf
		Else
			xValue := Nil
			cDescri := Nil
		EndIf

		cDescFai := If( ValType( xValue ) == "C" .And. !Empty( xValue ), AllTrim( xValue ) , "" ) + If( ValType( cDescri ) == "C" .And. !Empty( xValue ), " - " + AllTrim( cDescri ) , "" )
		cDescFai := If( Empty( cDescFai ) , If( ValType( xValue ) == "C" .Or. ValType( cDescri ) == "C" , STR0095 , "" ) + cBoxVis , cDescFai ) + ": " + MDT500MPER( ( cTrbPrin )->PERIODO ) //"Sem "

		cDescAna := cCmbTip

		cQryTot := ReturnQuery( nPosTip , nPosVis , nPosPer , dDtIni , dDtFim , cFilIni , cFilFim , xValue , ( cTrbPrin )->PERIODO , , , 4 )
		MPSysOpenQuery( cQryTot , cAlsTot )
		nTotFun := ( cAlsTot )->TOTAL

		If nTotFun > 0
			cQrySex := ReturnQuery( nPosTip , nPosVis , nPosPer , dDtIni , dDtFim , cFilIni , cFilFim , xValue , ( cTrbPrin )->PERIODO , , , 5 )
				//Atualiza array de funcionários
			MPSysOpenQuery( cQrySex , cAlsSex )
		EndIf

		cQryOco := ReturnQuery( nPosTip , nPosVis , nPosPer , dDtIni , dDtFim , cFilIni , cFilFim , xValue , ( cTrbPrin )->PERIODO , , , 2 )
		MPSysOpenQuery( cQryOco , cAlsOco )
		nTotOco := ( cAlsOco )->TOTAL

		If nTotOco > 0
			cQryFai := ReturnQuery( nPosTip , nPosVis , nPosPer , dDtIni , dDtFim , cFilIni , cFilFim , xValue , ( cTrbPrin )->PERIODO , , , 3 )
				//Atualiza array de faixas
				MPSysOpenQuery( cQryFai , cAlsFai )
		EndIf

			//Atualiza array de faixas
		fAtuFaixa(cAlsFai , cAlsTot , cAlsOco , cAlsSex )

		( cAlsTot )->( dbCloseArea() )
		( cAlsOco )->( dbCloseArea() )
		If Select( cAlsTot ) > 0
			( cAlsFai )->( dbCloseArea() )
		EndIf
		If Select( cAlsSex ) > 0
			( cAlsSex )->( dbCloseArea() )
		EndIf
	Else
		Processa( { | lEnd | fMontaGraph( oPai , @oObj , .F. , aFldList , cTrbPrin , cBoxVis , aFldSx3 , , aDefVirtu ) } )//Montagem do grafico.
	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fVisual
Visualiza o Registro

@return

@param cTRB Caracter TRB da visualização
@param aTabPrinc Array Array contendo os campos da tabela principais
@param cCmbTip Caracter Valor do Combo de Tipo de Visualização

@sample
fVisual( 'SGC000005' , {} , "Exames" )

@author Jackson Machado
@since 09/07/2014
/*/
//---------------------------------------------------------------------
Static Function fVisual( cTRB , aTabPrinc , cCmbTip )

	Local nPosTab := aScan( aTabPrinc , { | x | x[ _nPosDesFol ] == cCmbTip } )//Localiza a posição no Array de Definições
	Local cTabela := ""
	Local cTabSec := ""
	Local cKey
	Local cValBus
	Local aCampos
	Local aRelac
	Local aArea := GetArea()
	Local aAreaTRB := ( cTRB )->( GetArea() )
	Local aAreaSRA := SRA->( GetArea() )
	Local aAreaTM0 := TM0->( GetArea() )

	Private cCadastro := cCmbTip + " - " + STR0044 //"VISUALIZAR"

	//Caso encontre a tabela
	If nPosTab > 0
		//Posiciona na tabela princial
		cTabela := aTabPrinc[ nPosTab , _nPosTabPri ]
		aCampos := aTabPrinc[ nPosTab , _nPosCamRea ]
		aRelac := aTabPrinc[ nPosTab , _nPosCamVir ]

		//Posicina nas tabelas principais
		If cTabela == "SR8"
			dbSelectArea( "SRA" )
			dbSetOrder( 1 )
			cTabSec := "SRA"
			cKey := aCampos[ 1 ]
		Else
			dbSelectArea( "TM0" )
			dbSetOrder( 1 )
			cTabSec := "TM0"
			If cTabela == "TNC"
				cKey := aCampos[ 5 ]
			Else
				cKey := aCampos[ 1 ]
			EndIf
		EndIf

		nPosCmp := aScan( aRelac , { | x | x[ _nPosVirDom ] == cKey } )
		cValBus := aRelac[ nPosCmp , _nPosVirCDo ]
		dbSeek( xFilial( cTabSec ) + ( cTabSec )->( &( cValBus ) ) )

		//Posiciona no Registro
		dbSelectArea( cTabela )
		dbSetOrder( 1 )
		dbGoTo( ( cTRB )->RECNO )

		//Chama tela padrão de visualização
		NGCAD01( cTabela , Recno() , 2 )

	Else
		MsgInfo( STR0096 ) //"Não foi possível a visualização do registro."
	EndIf

	RestArea( aAreaTRB )
	RestArea( aAreaSRA )
	RestArea( aAreaTM0 )
	RestArea( aArea )

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fResultado
Visualiza o resultado do exame

@return

@param cTRB Caracter TRB da visualização
@param aTabPrinc Array Array contendo os campos da tabela principais
@param cCmbTip Caracter Valor do Combo de Tipo de Visualização

@sample
fResultado( 'SGC000005' , {} , "Exames" )

@author Jackson Machado
@since 09/07/2014
/*/
//---------------------------------------------------------------------
Static Function fResultado( cTRB , aTabPrinc , cCmbTip )

	Local nPosTab := aScan( aTabPrinc , { | x | x[ _nPosDesFol ] == cCmbTip } )//Localiza a posição no Array de Definições
	Local cTabela := ""

	Private cCadastro := STR0012 + " - " + STR0044 //"RESULTADO"###"VISUALIZAR"

	//Caso encontre e seja exame
	If nPosTab > 0 .And. cCmbTip == STR0004 //"Exames"

		//Posiciona na tabela princial
		cTabela := aTabPrinc[ nPosTab , _nPosTabPri ]

		//Posiciona no Registro
		dbSelectArea( cTabela )
		dbSetOrder( 1 )
		dbGoTo( ( cTRB )->RECNO )

		If !Empty( TM5->TM5_DTRESU )
			//Chama a função de resultado
			REXAME120()
		Else
			ShowHelpDlg( "NORESUL" , 	{ STR0097 } , 2 , ; //"Exame não possui resultado."
										{ STR0098 } ) //"Resultado de exame apenas será apresentado para exames com 'Data de Resultado' preenchida."
		EndIf

	Else
		ShowHelpDlg( "NORESUL" , 	{ STR0097 } , 2 , ; //"Exame não possui resultado."
									{ STR0098 } ) //"Resultado de exame apenas será apresentado para exames com 'Data de Resultado' preenchida."
	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fMontaList
Realiza a montagem da listagem

@param nPrinc Numerico Indica se é o painel principal: 1 - Principal; 2 - Secundário
@param nTipMon Numérico Indica o tipo de montagem: 0 - Zerar valores; 1 - Agrupado; 2 - Listagem
@param aTitulos Array Array contendo a listagem de Campos
@param cCmbTip Caracter Valor do Combo de Tipo de Visualização
@param cCmbVis Caracter Valor do Combo de Agrupador de Visualização
@param cCmbPer Caracter Valor do Combo de Período de Visualização
@param oPnlPai Objeto Objeto pai onde a listagem deverá ser criado
@param aCpsSX3 Array Array contendo os campos de SX3
@param aTabPrinc Array Array contendo os campos da tabela principais
@param cAliTRB TRB a ser considerado
@param dDtIni Data Valor da Data Início
@param dDtFim Data Valor da Data Fim
@param cFilIni Caracter Valor do Filtro Inicial
@param cFilFim Caracter Valor do Filtro Final
@param aItensTip Array Array contendo as opções do combo Tipo
@param aItensVis Array Array contendo as opções do combo Visualizar
@param aItensPer Array Array contendo as opções do combo Período
@param cAliPrinc Alis do TRB Principal
@param aDefVirtu Array Array contendo os campos de definição virtual
@param lDblClick Logico Indica se veio do botao de 'Avança Nível'
@param lAtuFaixa Logico Indica se deve atualizar a Faixa Periodica
@param lExecChan Logico Indica execução do Change

@return oObjeto Objeto Objeto de montagem da lista (FwBrowse)

@sample
fMontaList( nPrinc , nTipMon , aTitulos , cCmbTip , cCmbVis , cCmbPer , oPnlPai , aCpsSX3 , aTabPrinc , cAliTRB , dDtIni , dDtFim , cFilIni , cFilFim , aItensTip , aItensVis , aItensPer , cAliPrinc , aDefVirtu , lDblClick )

@author Jackson Machado
@since 09/07/2014
/*/
//---------------------------------------------------------------------
Static Function fMontaList( nPrinc , nTipMon , aTitulos , cCmbTip , cCmbVis , cCmbPer , oPnlPai , aCpsSX3 , aTabPrinc , cAliTRB , dDtIni , dDtFim , cFilIni , cFilFim , aItensTip , aItensVis , aItensPer , cAliPrinc , aDefVirtu , lDblClick , lAtuFaixa , lExecChan )

	//Contadores
	Local nX
	Local nCps
	Local lPriPerc := .T.

	//Posicionamentos de Array
	Local nPosTab
	Local nPosSX3
	Local nPosTit
	Local nPosPer
	Local nPosTip
	Local nPosVis
	Local nPosCX3
	Local nPosDef
	Local nPosSec
	Local nAddVir := 0

	//Valores de Definições
	Local cQuery:= ""
	Local cTable
	Local cCodigo
	Local cCmpBus
	Local cFilPdr
	Local cFilPer := ""
	Local cTratRet
	Local cQrySex := ""
	Local cQryHrs := ""

	//Arrays de Busca
	Local aCpsDef
	Local aStrSX3
	Local aColLis := {}
	Local aColCmp := {}
	Local aColSec := {}
	Local aPosSec := {}
	Local aCampos := {}
	Local oFildDef

	//Variáveis de Backup
	Local lChange := .F.
	Local lClick  := .F.
	Local bChange := { | |  }
	Local bClick  := { | |  }

	Default lDblClick := .F.
	Default lAtuFaixa := .F.
	Default lExecChan := .F.

	//Salva as posições dos arrays
	nPosTit := aScan( aTitulos , { | x | x[ 1 ] == cCmbVis } )
	nPosTip := aScan( aItensTip , { | x | x == cCmbTip } )
	nPosVis := aScan( aItensVis , { | x | x == cCmbVis } )
	nPosPer := aScan( aItensPer , { | x | x == cCmbPer } )
	nPosCX3 := aScan( aCpsSX3 , { | x | x[ 1 ] == cCmbVis } )

	//Define o Objeto que será utilizado
	If nPrinc == 1
		oObjeto := oListPrinc
	Else
		oObjeto := oListSecun
	EndIf

	//Busca filtros padrões caso seja por evento do botão ou não seja o painel principal
	If lDblClick .Or. nPrinc <> 1
		If ValType( cAliPrinc ) == "C" .And. nPosTit > 0 .And. nTipMon > 0 .And. Len( aTitulos[ nPosTit , 2 ] ) >= _nPosCod
			cCodigo := aTitulos[ nPosTit , 2 , _nPosCod ]
			aStrSX3 := aCpsSX3[ nPosCX3 , 2 ]
			If ( nPosSX3 := aScan( aStrSX3 , { | x | x[ 1 ] == cCodigo } ) ) > 0
				cFilPdr := &( cAliPrinc + "->" + aStrSX3[ nPosSX3 , 2 ] )
			ElseIf ( nPosDef := aScan( aDefVirtu , { | x | x[ _nPosTitle ] == cCodigo } ) ) > 0
				cFilPdr := &( cAliPrinc + "->" + aDefVirtu[ nPosDef , _nPosCampo ] )
			EndIf
			cFilPer := ( cAliPrinc )->PERIODO
		EndIf
	EndIf

	//Se Objeto já tinha sido montado, deleta e remonta
	If ValType( oObjeto ) == "O"
		oObjeto:DeActivate( .T. )
		If ValType( oObjeto:bChange ) == "B"//Caso tenha alteração de linha, salva para posterior atribuição
			lChange := .T.
			bChange := oObjeto:bChange
		EndIf
	EndIf

	//Apaga o TRB caso exista
	If Select( cAliTRB ) > 0
		( cAliTRB )->( dbCloseArea() )
	EndIf

	//Caso a seleção não tenha sido por mês e esteja montando a segunda listagem sem ser a listagem final,
	//ou sendo a primeiro por evento do botão, salva o período como mensal
	If cCmbPer <> STR0023 .And. ( ( nPrinc == 2 .And. nTipMon <> 2 ) .Or. ( nPrinc == 1 .And. lDblClick ) ) //"Mensal"
		nPosPer := aScan( aItensPer , { | x | x == STR0023 } ) //"Mensal"
	EndIf

	//Caso venha do evento do botão e seja segunda listagem, faz a busca da listagem final
	If ( lDblClick .Or. ( lExecChan .And. nNivBrw >= nNivLim ) ) .And. nPrinc == 2
		nTipMon := 2
	EndIf

	If nTipMon == 0//Define um browse padrão zerado

		aAdd( aColLis , fFieldCol( .F. , "{ | | " + cAliTRB + "->OCORRENCIA }", , CONTROL_ALIGN_RIGHT , STR0024 , "N" , 20 , "@E 99,999,999,999,999,999" ) ) //"Quantidade"
		aAdd( aColLis , fFieldCol( .F. , "{ | | MDT500MPER( " + cAliTRB + "->PERIODO ) }", , CONTROL_ALIGN_LEFT , STR0025 , "C" , 8 , "@!" ) ) //"Período"

		cQuery := ReturnQuery( 0 , 0 , 0 )
	ElseIf nTipMon == 1//Busca as listagens agrupadas por ocorrencia

		//Verifica se localizou campos
		If nPosTit > 0

			aCpsDef := aTitulos[ nPosTit , 2 ]//Salva os campos pré-definidos
			aStrSX3 := If( nPosCX3 > 0 , aCpsSX3[ nPosCX3 , 2 ] , {} )//Salva os campos de SX3

			For nCps := 1 To Len( aCpsDef )//Percorre os campos para montar os objetos
				//Pesquisa se é um campo de SX3
				If ( nPosSX3 := aScan( aStrSX3 , { | x | x[ 1 ] == aCpsDef[ nCps ] } ) ) > 0

					aAdd( aColLis , fFieldCol( , "{ | | " + cAliTRB + "->" + AllTrim( aStrSX3[ nPosSX3 , 2 ] ) + " }", aStrSX3[ nPosSX3 , 2 ] ) )

				ElseIf aCpsDef[ nCps ] == "%"//Verifica se é um campo de Porcentagem

					If /*( cCmbTip == "Diagnósticos" .And. lPriPerc ) .Or. */cCmbTip == STR0004 //"Exames"
						If cCmbTip == STR0005//Caso seja do Dignóstico, seleciona o percentual de Pressão //"Diagnósticos"
							lPriPerc := .F.
							cCmpBus := "PERCPRE"
						ElseIf lPriPerc//Caso não seja de Diagnóstico, seleciona o primeiro do exame
							lPriPerc := .F.
							cCmpBus := "PERCNOR"
						Else
							//Caso não seja de Diagnóstico e nem o primeiro de exame, seleciona o segundo do exame
							cCmpBus := "PERCALT"
						EndIf
						If ( nPosDef := aScan( aDefVirtu , { | x | x[ _nPosCampo ] == cCmpBus } ) ) > 0//Pesquisa se é um campo pré-definido
							//Caso não seja de SX3, tenta localizar as pré-definições, se encontra, adiciona
							aAdd( aColLis , fFieldCol( ;
															.F. , ;
															"{ | | " + cAliTRB + "->" + aDefVirtu[ nPosDef , _nPosCampo ] + " }" , ;
															,;
															aDefVirtu[ nPosDef , _nPosAlign ] , ;
															aDefVirtu[ nPosDef , _nPosTitle ] , ;
															aDefVirtu[ nPosDef , _nPosType ] , ;
															aDefVirtu[ nPosDef , _nPosTam ] , ;
															aDefVirtu[ nPosDef , _nPosPictu ] ) ;
														)
						Endif
					EndIf
				ElseIf ( nPosDef := aScan( aDefVirtu , { | x | x[ _nPosTitle ] == aCpsDef[ nCps ] } ) ) > 0//Pesquisa se é um campo pré-definido
					If ( aCpsDef[ nCps ] <> STR0027 .And. aCpsDef[ nCps ] <> STR0028 ) .Or. cCmbTip == STR0004 //"Normal"###"Alterado"###"Exames"
						cTratRet := "{ | | " + cAliTRB + "->" + aDefVirtu[ nPosDef , _nPosCampo ] + " }"
						//Verifica se é o período, caso seja, joga com tratamento de retorno
						If aDefVirtu[ nPosDef , _nPosCampo ] == "PERIODO"
							cTratRet := "{ | | MDT500MPER( " + cAliTRB + "->" + aDefVirtu[ nPosDef , _nPosCampo ] + " ) }"
						EndIf
						//Caso não seja de SX3, tenta localizar as pré-definições, se encontra, adiciona
						aAdd( aColLis , fFieldCol( ;
														.F. , ;
														cTratRet , ;
														,;
														aDefVirtu[ nPosDef , _nPosAlign ] , ;
														aDefVirtu[ nPosDef , _nPosTitle ] , ;
														aDefVirtu[ nPosDef , _nPosType ] , ;
														aDefVirtu[ nPosDef , _nPosTam ] , ;
														aDefVirtu[ nPosDef , _nPosPictu ] ) ;
													)
					EndIf
				EndIf
			Next nCps

			//Retorna a Query de acordo com a Filtragem
			cQuery := ReturnQuery( nPosTip , nPosVis , nPosPer , dDtIni , dDtFim , cFilIni , cFilFim , cFilPdr , cFilPer )
			If MV_PAR01 == 1
				cQrySex := ReturnQuery( nPosTip , nPosVis , nPosPer , dDtIni , dDtFim , cFilIni , cFilFim , cFilPdr , cFilPer , , , , 1 )
				If nPosTip == 1
					cQryHrs := ReturnQuery( nPosTip , nPosVis , nPosPer , dDtIni , dDtFim , cFilIni , cFilFim , cFilPdr , cFilPer , , , , 2 )
				EndIf
			EndIf

		EndIf

	ElseIf nTipMon == 2

		//Caso seja montagem do Browse final de listagem, incrementa o nível
		If !lExecChan
			nNivBrw++
		EndIf

		//Localiza a tabela no Array de Definições
		nPosTab := aScan( aTabPrinc , { | x | x[ _nPosDesFol ] == cCmbTip } )

		If nPosTab > 0

			//Faz um Backup dos campos virtuais para salvar os valores
			aColSec := aClone( aTabPrinc[ nPosTab , _nPosCamVir ] )

			//Salva os campos pré-definidos da Tabela
			aColCmp := aTabPrinc[ nPosTab , _nPosCamRea ]
			For nCps := 1 To Len( aColCmp )

				//Posiciona no campo e adiciona como coluna

				If GetSx3Cache( aColCmp[ nCps ]  , 'X3_TIPO' ) == "D"//Caso for data, joga o valor com conversão
					aAdd( aColLis , fFieldCol( , "{ | | StoD( " + cAliTRB + "->" + aColCmp[ nCps ] + " ) }", aColCmp[ nCps ] ) )
				Else
					aAdd( aColLis , fFieldCol( , "{ | | " + cAliTRB + "->" + aColCmp[ nCps ] + " }", aColCmp[ nCps ] ) )
				EndIf

				//Pesquisa se o campo de relação existe para jogar a posição onde o campo virtual deveficar
				If ( nPosDef := aScan( aColSec , { | x | x[ _nPosVirDom ] == aColCmp[ nCps ] } ) ) > 0
					nPosSec := Len( aColLis )//Salva a ultima posição
					// Adiciona o valor de posição do campo virtual como sendo o tamanho do array somado com os campos já vistos
					// somando um, pois o tamanho do array corresponde aos campos reais, os campos virtuais já vistos corresponde a quantidade de campos totais
					// e a soma de um para que fique posicionado no campo logo após o 'codigo'
					aAdd( aPosSec , { aColCmp[ nCps ] , nPosSec + nAddVir + 1 } )
					nAddVir++//Incrementa os campos virtuais já vistos
					aAdd( aColSec[ nPosDef ] , nAddVir )//Salva um array com as posições dos campos virtuais para posterior ordenação
				EndIf
			Next nCps

			//Ordena as posições dos campos secundários para ficarem do menor para o maior
			aPosSec := aSort( aPosSec , , , { | x , y | x[ 2 ] < y[ 2 ] } )
			aColSec := aSort( aColSec , , , { | x , y | x[ Len( aColSec[ 1 ] ) ] < y[ Len( aColSec[ 1 ] ) ] } )

			//Busca os campos virtuais - Vindos de outras tabelas
			For nCps := 1 To Len( aColSec )
				cTable := aColSec[ nCps , _nPosVirTab ]
				If cTable == "SX5"
					If ( nPosDef := aScan( aDefVirtu , { | x | x[ _nPosCampo ] == aColSec[ nCps , _nPosVirCmp ] } ) ) > 0//Pesquisa se é um campo pré-definido
						//Caso não seja de SX3, tenta localizar as pré-definições, se encontra, adiciona
						oFildDef := fFieldCol( ;
																.F. , ;
																"{ | | " + cAliTRB + "->" + aDefVirtu[ nPosDef , _nPosCampo ] + " }" , ;
																,;
																aDefVirtu[ nPosDef , _nPosAlign ] , ;
																aDefVirtu[ nPosDef , _nPosTitle ] , ;
																aDefVirtu[ nPosDef , _nPosType ] , ;
																aDefVirtu[ nPosDef , _nPosTam ] , ;
																aDefVirtu[ nPosDef , _nPosPictu ] )
						//Localiza o campo virtual correspondente no array de posicoes
						nPosSec := aScan( aPosSec , { | x | x[ 1 ] == aColSec[ nCps , _nPosVirDom ] } )
						If nPosSec > 0 //Caso encontre a posição, joga o valor correspondente
							nPosSec := aPosSec[ nPosSec , 2 ]//Salva a posição que tem que ser colocado
							aAdd( aColLis , {} )//Adiciona um nova posição no array
							//Percorre o array de baixo para cima jogando todos até o localizado uma posição para baixo
							For nX := Len( aColLis ) To ( nPosSec + 1 ) Step - 1
								aColLis[ nX ] := aColLis[ nX - 1 ]
							Next nX
							//Adiciona o campo virtual na posiação abaixo do campo origem
							aColLis[ nPosSec  ] := oFildDef
						Else
							aAdd( aColLis , oFildDef )
						EndIf
					EndIf
				Else
					//Localiza o campo virtual correspondente no array de posicoes
					nPosSec := aScan( aPosSec , { | x | x[ 1 ] == aColSec[ nCps , _nPosVirDom ] } )

					If nPosSec > 0 //Caso encontre a posição, joga o valor correspondente
						nPosSec := aPosSec[ nPosSec , 2 ]//Salva a posição que tem que ser colocado
						aAdd( aColLis , {} )//Adiciona um nova posição no array
						//Percorre o array de baixo para cima jogando todos até o localizado uma posição para baixo
						For nX := Len( aColLis ) To ( nPosSec + 1 ) Step - 1
							aColLis[ nX ] := aColLis[ nX - 1 ]
						Next nX
						//Adiciona o campo virtual na posiação abaixo do campo origem
						aColLis[ nPosSec ] := fFieldCol( , "{ | | " + cAliTRB + "->" + aColSec[ nCps , _nPosVirCmp ] + " }", aColSec[ nCps , _nPosVirCp2 ] )
					Else
						aAdd( aColLis , fFieldCol( , "{ | | " + cAliTRB + "->" + aColSec[ nCps , _nPosVirCmp ] + " }", aColSec[ nCps , _nPosVirCp2 ] ) )
					EndIf
				EndIf
			Next nCps

			//Retorna a Query de acordo com a Filtragem
			cQuery := ReturnQuery( nPosTip , nPosVis , 3 , dDtIni , dDtFim , cFilIni , cFilFim , cFilPdr , cFilPer , aTabPrinc[ nPosTab , _nPosCamRea ] , aTabPrinc[ nPosTab , _nPosCamVir ] )
			If MV_PAR01 == 1
				cQrySex := ReturnQuery( nPosTip , nPosVis , 3 , dDtIni , dDtFim , cFilIni , cFilFim , cFilPdr , cFilPer , aTabPrinc[ nPosTab , _nPosCamRea ] , aTabPrinc[ nPosTab , _nPosCamVir ] , , 1 )
				If nPosTip == 1
					cQryHrs := ReturnQuery( nPosTip , nPosVis , 3 , dDtIni , dDtFim , cFilIni , cFilFim , cFilPdr , cFilPer , aTabPrinc[ nPosTab , _nPosCamRea ] , aTabPrinc[ nPosTab , _nPosCamVir ] , , 2 )
				EndIf
			EndIf

		EndIf
	EndIf

	//Monta o objeto
	oObjeto := FWBrowse():New()
	oObjeto:SetOwner( oPnlPai )//Define o objeto pai

	oObjeto:SetDataQuery()//Define que a utilizacao é por tabela
	oObjeto:SetAlias( cAliTRB )//Define alias de utilizacao
	oObjeto:SetQuery( cQuery )

	oObjeto:DisableReport()//Desabilita botao de impressao
	oObjeto:DisableConfig()//Desabilita botao de configuracao

	oObjeto:SetColumns( aColLis )//Define as colunas preestabelecidas

	oObjeto:Activate()//Ativa o browse

	If MV_PAR01 == 1
		fExecCount( nPrinc , nTipMon , cAliTRB , cQrySex , cQryHrs ) //Executa os Contadores Finais
	EndIf

	If lChange
     	oObjeto:SetChange( bChange )
    EndIf

    If nPrinc == 2
    	oListPrinc:SetFocus()
    EndIf

    //Verifica atualização da Faixa
	If lAtuFaixa .And. MV_PAR02 == 1
		fRefresh( , , 1 , aTitulos , cAliTRB , cCmbVis , aCpsSX3 , aDefVirtu ,  dDtIni , dDtFim , cFilIni , cFilFim, cCmbTip , cCmbPer , aItensTip , aItensVis , aItensPer )
	EndIf

Return oObjeto

//---------------------------------------------------------------------
/*/{Protheus.doc} fFieldCol
Define objeto das colunas

@return oColuna Objeto Objeto da Coluna

@param lSX3 Logico Indica se é um campo de SX3
@param cData Caracter Indica a busca do valor do campo
@param cAlign Caracter Indica o alinhamento do campo (CONTROL_ALIGN_RIGHT ou CONTROL_ALIGN_LEFT) (Somente obrigatório quando campo diferente de SX3)
@param cTitle Caracter Indica o titulo do campo (Somente obrigatório quando campo diferente de SX3)
@param cTipe Caracter Indica o tipo do campo (Somente obrigatório quando campo diferente de SX3)
@param nTam Numerico Indica o tamanho do campo (Somente obrigatório quando campo diferente de SX3)
@param cPicture Caracter Indica a Picture do campo (Somente obrigatório quando campo diferente de SX3)

@sample fFieldCol( , "{ | | ALIAS->CAMPO }", CAMPO )

@author Jackson Machado
@since 27/06/2014
/*/
//---------------------------------------------------------------------
Static Function fFieldCol( lSX3 , cData , cCampo ,cAlign , cTitle , cTipe , nTam , cPicture )

	Local oColuna
	Local aTam  := {}

	Default lSX3 := .T.

	//Caso seja pelo dicionário, busca as informações
	If lSX3
		cTipe    := GetSx3Cache( cCampo, 'X3_TIPO' )
		cAlign   := If(cTipe  == "N" , CONTROL_ALIGN_RIGHT ,CONTROL_ALIGN_LEFT )
		cTitle   := AllTrim( Posicione( 'SX3' , 2 , cCampo , 'X3Titulo()' ) )
		aTam     := TamSX3( cCampo )
		nTam	 := aTam[1] + aTam[2]
		cPicture := X3Picture(cCampo)
	EndIf

	//Adiciona as colunas do markbrowse
	oColuna := FWBrwColumn():New()//Cria objeto
		oColuna:SetAlign( cAlign )//Define alinhamento
		oColuna:SetData( &(cData ) )//Define valor

		oColuna:SetEdit( .F. )//Indica se é editavel
		oColuna:SetTitle( cTitle )//Define titulo
		oColuna:SetType( cTipe )//Define tipo
		oColuna:SetSize( nTam )//Define tamanho
		oColuna:SetPicture( cPicture ) //Define picture

Return oColuna

//---------------------------------------------------------------------
/*/{Protheus.doc} fExecCount
Atualização dos Contadores Principais

@return oColuna Objeto Objeto da Coluna

@param nPrinc Numerico Indica se é o painel principal: 1 - Principal; 2 - Secundário
@param nTipMon Numérico Indica o tipo de montagem: 0 - Zerar valores; 1 - Agrupado; 2 - Listagem
@param cAliTRB Caracter Indica o alias do TRB
@param cQrySex Caracter Indica a Query a ser executada para atualização dos contadores por sexo
@param cQryHrs Caracter Indica o Query a ser executada para atualização do contador de Absenteísmo

@sample fExecCount( 1 , 1 , 'SGC000005' , "" , "" )

@author Jackson Machado
@since 17/07/2014
/*/
//---------------------------------------------------------------------
Static Function fExecCount( nPrinc , nTipMon , cAliTRB , cQrySex , cQryHrs )

	Local nContador := 0
	Local aArea := ( cAliTRB )->( GetArea() )
	Local cAliSex
	Local cAliHrs

	//Zera todos os contadores
	If nPrinc == 1
		nQtdPri	:= 0
		nQtdHPri:= 0
		nQtdMPri:= 0
		nHrsPri	:= 0
	Else
		nQtdSec	:= 0
		nQtdHSec:= 0
		nQtdMSec:= 0
   		nHrsSec	:= 0
	EndIf

	If nTipMon <> 0
		//Executa o Contador Final
		If nTipMon == 1
			While ( cAliTRB )->( !Eof() )
				nContador += ( cAliTRB )->OCORRENCIA
				( cAliTRB )->( dbSkip() )
			End
		Else
			nContador := ( cAliTRB )->( LASTREC() )
		EndIf

		If nPrinc == 1
			nQtdPri := nContador
		Else
			nQtdSec := nContador
		EndIf

		//Alimenta contadores de Quantidade por Sexo
		cAliSex := GetNextAlias()
		MPSysOpenQuery( cQrySex , cAliSex )
		While ( cAliSex )->( !Eof() )
			If ( cAliSex )->SEXO == "M"
				If nPrinc == 1
					nQtdHPri:= ( cAliSex )->OCORRENCIA
				Else
					nQtdHSec:= ( cAliSex )->OCORRENCIA
				EndIf
			ElseIf ( cAliSex )->SEXO == "F"
				If nPrinc == 1
					nQtdMPri:= ( cAliSex )->OCORRENCIA
				Else
					nQtdMSec:= ( cAliSex )->OCORRENCIA
				EndIf
			EndIf
			( cAliSex )->( dbSkip() )
		End
		//Alimenta contadores de Horas, se houver
		If !Empty( cQryHrs )
			cAliHrs := GetNextAlias()
			MPSysOpenQuery( cQryHrs , cAliHrs )

			If nPrinc == 1
				nHrsPri := ( cAliHrs )->OCORRENCIA
			Else
				nHrsSec := ( cAliHrs )->OCORRENCIA
			EndIf
			( cAliHrs )->( dbCloseArea() )
		EndIf

	EndIf

	RestArea( aArea )

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} ReturnQuery
Retorna a Query a ser executada

@return cQuery Caracter Retorna a Query a ser executada

@param nPrinc Numerico Tipo de Visualização: 1 - Absenteísmo; 2 - Exames; 3 - Diagnósticos; 4 - Doenças; 5 - Acidentes
@param nType Numerico Tipo de Agrupamento (Varia de acordo com o Tipo de Visualização)
@param nTime Numerico Indica o período: 1 - Anual; 2 - Mensal
@param dDtIni Data Valor da Data Início
@param dDtFim Data Valor da Data Fim
@param cFilIni Caracter Valor do Filtro Inicial
@param cFilFim Caracter Valor do Filtro Final
@param cFilPdr Caracter Filtro da Listagem secundária, indica o agrupador da Listagem principal
@param cFilPer Caracter Filtro da Listagem secundária, indica o período da Listagem principal
@param aColCmp Array Campos a serem exibidos na Query
@param aCmpVir Array Campos 'virtuais' a serem exibidos na Query
@param nValBus Numerico Indica de qual busca deve fazer: 1 - Padrão; 2 - Quantidade de Ocorrências; 3 - Por Faixa de Idade; 4 - Quantidade de Funcionários (Filtrados); 5 - Quantidade de Funcionários por Sexo; 6 - Quantidade de Funcionários - Total; 7 - Quantidade de Horas Trabalhadas; 8 - Quantidade de Horas Trabalhadas Afastadas; 9 - Quantidade de Horas Afastadas (Acidente)
@param nTotais Somatórias finais: 1 - Sexo; 2 - Horas Afastamento

@sample
ReturnQuery( 1 , 1 , 1 , "01/01/2000" , "31/12/2020" , "" , "ZZZZZZ" , "2014" , "000001" , {} , {} )

@author Jackson Machado
@since 09/07/2014
/*/
//---------------------------------------------------------------------
Static Function ReturnQuery( nPrinc , nType , nTime , dDtIni , dDtFim , cFilIni , cFilFim , cFilPdr , cFilPer , aColCmp , aCmpVir , nValBus , nTotais )

	Local nCmp
	Local nTamGrp //Tamanho do agrupador de período 4 - Anual; 6 - Mensal
	Local nDiffMon //Calcula diferença entre data início e final
	Local cValBrc := "ISNULL" //Validação de ISNULL tratada
	Local cGetDB  := TcGetDb() //Traz a base de dados
	Local cQuery  := "" //Query Final
	Local cTabela := "" //Tabela a ser utilizada
	Local cDtGrup := "" //Data de Agrupamento
	Local cCmpWhr := ""//Campo do Valor do Filtro do Where
	Local cQryFrm := "" //Instrução de From da Query
	Local cQryJoi := "" //Instrução para os Join's Fixos
	Local cQryBkp := "" //Variável de Backup para utilização no processo de montagem
	Local cCpsQry := "" //Campos a serem trazidos pela query
	Local cJinQry := "" //Instrução para os Join's Padrões
	Local cWhrPdr := "" //Instrução que define o Where Padrão
	Local cFilQry := "" //Instrução para os Filtros da Query
	Local cGrpQry := "" //Instrução do GROUP BY da Query
	Local cJoiGrp := "" //Instrução do Join dos Contadores
	Local cCmpGrp := "" //Instrução dos campos dos Contadores
	Local cGrpAlt := "" //Instrução que define os exames Alterados nos Contadores
	Local cQryIdd := "" //Instrução para Query de Faixa Etária
	Local cGrpIdd := "" //Instrução do GROUP BY da Query de Faixa Etária
	Local cQrySex := "" //Instrução para Query de Sexo
	Local cGrpSex := "" //Instrução do GROUP BY da Query de Sexo
	Local cAgrup  := "SRA.RA_MAT"//Agrupador padrão de ocorrências
	Local cQryTrb := ""//Instrução para Query de Horas Trabalhadas
	Local cGrpTrb := ""//Instrução do GROUP BY da Query de Horas Trabalhadas
	Local cQryAbs := ""//Instrução para Query de Absenteísmo
	Local cWhrAbs := ""//Instrução do WHERE da Query de Absenteísmo
	Local cQryAci := ""//Instrução para Query de Acidente

	//Trativas do ComboBox
	Local nCBox   := 0
	Local nPosEqs := 0
	Local cCBox   := ""
	Local aCBox   := {}
	Default cFilPer := ""
	Default nValBus := 1
	Default nTotais := 0

	//Define o ISNULL de acordo com a base de dados
	If cGetDB == "ORACLE"
		cValBrc := "NVL"
	ElseIf "DB2" $ cGetDB .Or. cGetDB == "POSTGRES"
		cValBrc := "COALESCE"
	Else
		cValBrc := "ISNULL"
	EndIf

	//FAZ UMA INSTRUÇÃO DE QUERY ESPECÍFICA QUANDO FOR POR PRESSÃO ARTERIAL
	//POIS A QUERY ESTAVA TODA GENÉRICA E PEDIRAM PARA COLOCAR APÓS TODA A ROTINA CONCLUIDA
	//UMA FORMA DIFERENCIADA
	If nPrinc == 3 .And. nType == 6
		cQuery := RetQueryPress( nPrinc , nType , nTime , dDtIni , dDtFim , cFilIni , cFilFim , cFilPdr , cFilPer , aColCmp , aCmpVir , nValBus , nTotais )
	Else

		If nValBus == 3
			//Define a Query padrão de Idade
			If cGetDB == "ORACLE"
				cQryIdd += " SELECT IDADE, SEXO, SUM( QTDFUN ) AS QTDFUN, SUM( OCORRENCIA ) AS OCORRENCIA , ( SUM( OCORRENCIA ) * 100.0 ) / " + ValToSQL( nTotOco ) + " AS PERCEN FROM "
				cQryIdd += "( "
				cQryIdd += " SELECT "
				cQryIdd += " CASE "
				cQryIdd += " WHEN IDADE < 18 THEN 1"
				cQryIdd += " WHEN IDADE >= 18 AND IDADE <= 30 THEN 2 "
				cQryIdd += " WHEN IDADE >= 31 AND IDADE <= 40 THEN 3 "
				cQryIdd += " WHEN IDADE >= 41 AND IDADE <= 50 THEN 4 "
				cQryIdd += " WHEN IDADE >= 51 AND IDADE <= 60 THEN 5 "
				cQryIdd += " WHEN IDADE >= 61 AND IDADE <= 70 THEN 6 "
				cQryIdd += " WHEN IDADE >= 71 THEN 7 "
				cQryIdd += " ELSE 0 "
				cQryIdd += "END AS IDADE, SEXO, COUNT(DISTINCT(MAT)) AS QTDFUN , COUNT(MAT) AS OCORRENCIA FROM "
				cQryIdd += "( "
				cQryIdd += " SELECT SRA.RA_MAT AS MAT, CAST(CAST(CAST( "+ ValToSQL( DtoS( dDataBase ) ) +" AS DATE ) - CAST(SRA.RA_NASC AS  DATE) AS INT)/365 AS INT) AS IDADE , SRA.RA_SEXO AS SEXO "

				//Define o agrupador padrão de idade
				cGrpIdd += " ) TBL GROUP BY SEXO, IDADE "
				cGrpIdd += " ) ALS "
				cGrpIdd += " GROUP BY IDADE, SEXO "
			Else
				cQryIdd += " SELECT IDADE, SEXO, SUM( QTDFUN ) AS QTDFUN, SUM( OCORRENCIA ) AS OCORRENCIA , ( SUM( OCORRENCIA ) * 100.0 ) / " + ValToSQL( nTotOco ) + " AS PERCEN FROM "
				cQryIdd += "( "
				cQryIdd += " SELECT IDADE = "
				cQryIdd += " CASE "
				cQryIdd += " WHEN IDADE < 18 THEN 1"
				cQryIdd += " WHEN IDADE >= 18 AND IDADE <= 30 THEN 2 "
				cQryIdd += " WHEN IDADE >= 31 AND IDADE <= 40 THEN 3 "
				cQryIdd += " WHEN IDADE >= 41 AND IDADE <= 50 THEN 4 "
				cQryIdd += " WHEN IDADE >= 51 AND IDADE <= 60 THEN 5 "
				cQryIdd += " WHEN IDADE >= 61 AND IDADE <= 70 THEN 6 "
				cQryIdd += " WHEN IDADE >= 71 THEN 7 "
				cQryIdd += " ELSE 0 "
				cQryIdd += "END, SEXO, COUNT(DISTINCT(MAT)) AS QTDFUN , COUNT(MAT) AS OCORRENCIA FROM "
				cQryIdd += "( "
				cQryIdd += " SELECT SRA.RA_MAT AS MAT, ( CONVERT( INTEGER , "+ ValToSQL( DtoS( dDataBase ) ) +" ) - CONVERT( INTEGER , SRA.RA_NASC ) ) / 10000 AS IDADE , SRA.RA_SEXO AS SEXO "

				//Define o agrupador padrão de idade
				cGrpIdd += " ) TBL GROUP BY SEXO, IDADE "
				cGrpIdd += " ) ALS "
				cGrpIdd += " GROUP BY IDADE, SEXO "
			EndIf

		ElseIf nValBus == 5
			//Define a Query padrão Agrupada por Sexo
			cQrySex += " SELECT SRA.RA_SEXO AS SEXO, COUNT( DISTINCT( SRA.RA_MAT ) ) AS TOTAL , ( COUNT( DISTINCT( SRA.RA_MAT ) ) * 100.00 ) / " + ValToSQL( nTotFun ) + " AS PERCEN "

			//Define o agrupador padrão por Sexo
			cGrpSex += " GROUP BY SRA.RA_SEXO "
		ElseIf nValBus == 7

			//Define diferença de meses
			nDiffMon := ( dDtFim - dDtIni ) + 1//DateDiffMonth( dDtIni , dDtFim )
			//nDiffMon := ( nDiffMon ) / 30

			//Define a Query padrão de Total de Horas
			cQryTrb += " SELECT SUM( TOTHRS ) AS TOTHRS FROM ( "
			cQryTrb += " 				SELECT DISTINCT(SRA.RA_MAT) AS MAT, "
			cQryTrb += " 						CASE SRA.RA_HRSMES "
			cQryTrb += " 							WHEN 0 THEN 1 "
			cQryTrb += " 							ELSE 1 "
			cQryTrb += " 						END * " + ValToSQL( nDiffMon ) + " AS TOTHRS "

			//Define o agrupador padrão por Sexo
			cGrpTrb += " ) TBL"
		ElseIf nValBus == 8
			//Define o 'link' com a tabela de afastamento
			cQryAbs += " SELECT "+cValBrc+"( SUM( SR8.R8_DURACAO ) , 0 ) AS DURACAO "
			If nPrinc <> 1
				cQryAbs += " FROM " + RetSQLName( "SR8" ) + " SR8 "
				cQryAbs += " WHERE SR8.R8_DATAINI <= " + ValToSQL( dDtFim ) + " AND ( SR8.R8_DATAFIM = '' OR SR8.R8_DATAFIM >= " + ValToSQL( dDtIni ) + " ) AND SR8.D_E_L_E_T_ <> '*' AND SR8.R8_FILIAL = " + ValToSQL( xFilial( "SR8" ) )
				cQryAbs += " AND SR8.R8_MAT IN ( "
				cQryAbs += " SELECT DISTINCT( RA_MAT ) "
				//cQryJoi += " JOIN " + RetSQLName( "SR8" ) + " SR8 ON SRA.RA_MAT = SR8.R8_MAT AND SR8.R8_FILIAL = " + ValToSQL( xFilial( "SR8" ) ) + " AND SR8.D_E_L_E_T_ <> '*' "
			Else
				//Define a Query padrão de Absenteísmo
				//cQryAbs += " SELECT "+cValBrc+"( SUM( SR8.R8_DURACAO ) , 0 ) AS DURACAO "

				//Define o afastamento do período
				cWhrAbs := " SR8.R8_DATAINI <= " + ValToSQL( dDtFim ) + " AND ( SR8.R8_DATAFIM = '' OR SR8.R8_DATAFIM >= " + ValToSQL( dDtIni ) + " ) AND SR8.D_E_L_E_T_ <> '*' AND SR8.R8_FILIAL = " + ValToSQL( xFilial( "SR8" ) )
			EndIf

		ElseIf nValBus == 9
			//Define a Query padrão de Absenteísmo
			cQryAci += " SELECT "+cValBrc+"( SUM( SR8.R8_DURACAO ) , 0 ) AS DURACAO "

			If nPrinc <> 1 .And. nPrinc <> 5
				//Define o 'link' com a tabela de afastamento
				cQryAci += " FROM " + RetSQLName( "SR8" ) + " SR8 "
				cQryAci += " WHERE SR8.R8_DATAINI <= " + ValToSQL( dDtFim ) + " AND ( SR8.R8_DATAFIM = '' OR SR8.R8_DATAFIM >= " + ValToSQL( dDtIni ) + " ) AND SR8.D_E_L_E_T_ <> '*' AND SR8.R8_FILIAL = " + ValToSQL( xFilial( "SR8" ) )
				cQryAci += " AND SR8.R8_MAT IN ( "
				cQryAci += " SELECT DISTINCT( RA_MAT ) "
			Else
				If nPrinc <> 5
					cQryJoi += " JOIN " + RetSQLName( "TM0" ) + " TM0 ON SRA.RA_MAT = TM0.TM0_MAT AND TM0.TM0_FILIAL = " + ValToSQL( xFilial( "TM0" ) ) + " AND TM0.D_E_L_E_T_ <> '*' "
				Else
					//Define o 'link' com a tabela de afastamento
					cQryJoi += " JOIN " + RetSQLName( "SR8" ) + " SR8 ON SRA.RA_MAT = SR8.R8_MAT AND SR8.R8_FILIAL = " + ValToSQL( xFilial( "SR8" ) ) + " AND SR8.D_E_L_E_T_ <> '*' "
					cQryJoi += " AND SR8.R8_DATAINI <= " + ValToSQL( dDtFim ) + " AND ( SR8.R8_DATAFIM = '' OR SR8.R8_DATAFIM >= " + ValToSQL( dDtIni ) + ") "
				EndIf
			EndIF

			EndIf

		If nPrinc == 0 .And. nType == 0 .And. nTime == 0//Retorno sem valores
			cQuery += " SELECT DISTINCT( 0 ) AS OCORRENCIA, '' AS PERIODO FROM  " + RetSQLName( "TM0" )//Define query padrão de retorno zerado
		ElseIf nPrinc == 1 //Absenteísmo
			cTabela := "SR8"//Tabela padrão
			cDtGrup := "SR8.R8_DATAINI"//Agrupador de data
			//Define o WHERE padrão
			cWhrPdr := " WHERE SR8.R8_DATAINI <= " + ValToSQL( dDtFim ) + " AND ( SR8.R8_DATAFIM = '' AND SR8.R8_DATAINI >=" + ValToSQL( dDtIni ) + " AND SR8.R8_DATAINI <="+ ValToSQL( dDtFim ) +" OR SR8.R8_DATAFIM >= " + ValToSQL( dDtIni ) + " ) AND SR8.D_E_L_E_T_ <> '*' AND SR8.R8_FILIAL = " + ValToSQL( xFilial( "SR8" ) )
			If nTime == 1 .Or. nTime == 2//Anual ou Mensal
				If nType == 1//Centro de Custo
					//Define campos principais
					cCpsQry := " SRA.RA_CC AS CTT_CUSTO, "+cValBrc+"( CTT.CTT_DESC01 , '' ) AS CTT_DESC01 "

					//Define Join padrão na Tabela
					cJinQry := " JOIN " + RetSQLName( "CTT" ) + " CTT ON CTT.CTT_CUSTO = SRA.RA_CC AND CTT.CTT_FILIAL = " + ValToSQL( xFilial( "CTT" ) ) + " AND CTT.D_E_L_E_T_ <> '*' "

					//Define Filtro da Tabela
					cFilQry := "		SRA.RA_CC = "

					//Define campo comparativo do Where
					cCmpWhr := " SRA.RA_CC "

					//Define agrupadores
					cGrpQry := ", SRA.RA_CC, CTT.CTT_DESC01"
				ElseIf nType == 2//Função
					//Define campos principais
					cCpsQry := " SRA.RA_CODFUNC AS RJ_FUNCAO, "+cValBrc+"( SRJ.RJ_DESC , '' ) AS RJ_DESC "

					//Define Join padrão na Tabela
					cJinQry := " JOIN " + RetSQLName( "SRJ" ) + " SRJ ON SRJ.RJ_FUNCAO = SRA.RA_CODFUNC AND SRJ.RJ_FILIAL = " + ValToSQL( xFilial( "SRJ" ) ) + " AND SRJ.D_E_L_E_T_ <> '*' "

					//Define Filtro da Tabela
					cFilQry := "		SRA.RA_CODFUNC = "

					//Define campo comparativo do Where
					cCmpWhr := " SRA.RA_CODFUNC "

					//Define agrupadores
					cGrpQry := ", SRA.RA_CODFUNC, SRJ.RJ_DESC"
				ElseIf nType == 3//Funcionário
					//Define campos principais
					cCpsQry := " SRA.RA_MAT AS RA_MAT, "+cValBrc+"( SRA.RA_NOME , '' ) AS RA_NOME "

					//Define Join padrão na Tabela
					cJinQry := ""

					//Define Filtro da Tabela
					cFilQry := "		SRA.RA_MAT = "

					//Define campo comparativo do Where
					cCmpWhr := " SRA.RA_MAT "

					//Define agrupadores
					cGrpQry := ", SRA.RA_MAT, SRA.RA_NOME"
				ElseIf nType == 4//CID
					//Define campos principais
					cCpsQry := " SR8.R8_CID AS TMR_CID, "+cValBrc+"( TMR.TMR_DOENCA , '' ) AS TMR_DOENCA"

					//Define Join padrão na Tabela
					cJinQry := " LEFT JOIN " + RetSQLName( "TMR" ) + " TMR ON TMR.TMR_CID = SR8.R8_CID AND TMR.TMR_FILIAL = " + ValToSQL( xFilial( "TMR" ) ) + " AND TMR.D_E_L_E_T_ <> '*' "

					//Define Filtro da Tabela
					cFilQry := "		SR8.R8_CID = "

					//Define campo comparativo do Where
					cCmpWhr := " SR8.R8_CID "

					//Define agrupadores
					cGrpQry := ", SR8.R8_CID, TMR.TMR_DOENCA"
				ElseIf nType == 5//Motivo
					//Define campos principais
					cCpsQry := " SR8.R8_TIPO AS R8_TIPO, "+cValBrc+"( SX5.X5_DESCRI , '' ) AS R8_MOTAFA "

					//Define Join padrão na Tabela
					cJinQry := " JOIN " + RetSQLName( "SX5" ) + " SX5 ON SX5.X5_TABELA = '30' AND SX5.X5_CHAVE = SR8.R8_TIPO AND SX5.X5_FILIAL = " + ValToSQL( xFilial( "SX5" ) ) + " AND SX5.D_E_L_E_T_ <> '*' "

					//Define Filtro da Tabela
					cFilQry := "		SR8.R8_TIPO = "

					//Define campo comparativo do Where
					cCmpWhr := " SR8.R8_TIPO "

					//Define agrupadores
					cGrpQry := ", SR8.R8_TIPO, SX5.X5_DESCRI"

				ElseIf nType == 6 //Tipos Ausências
					//Define campos principais
					cCpsQry := " SR8.R8_TIPOAFA AS R8_TIPOAFA, "+cValBrc+"( RCM.RCM_DESCRI , '' ) AS R8_MOTAUS "

					//Define Join padrão na Tabela
					cJinQry := " JOIN " + RetSQLName( "RCM" ) + " RCM ON RCM.RCM_TIPO = SR8.R8_TIPOAFA AND RCM.RCM_FILIAL = " + ValToSQL( xFilial( "RCM" ) ) + " AND RCM.D_E_L_E_T_ <> '*' "

					//Define Filtro da Tabela
					cFilQry := "		SR8.R8_TIPOAFA = "

					//Define campo comparativo do Where
					cCmpWhr := " SR8.R8_TIPOAFA "

					//Define agrupadores
					cGrpQry := ", SR8.R8_TIPOAFA, RCM.RCM_DESCRI"

				EndIf

				//Define o FROM e Join's fixos
				cQryFrm += " FROM " + RetSQLName( "SR8" ) + " SR8 "
				cQryFrm += " JOIN " + RetSQLName( "SRA" ) + " SRA ON SRA.RA_MAT = SR8.R8_MAT AND SRA.RA_FILIAL = " + ValToSQL( xFilial( "SRA" ) ) + " AND SRA.D_E_L_E_T_ <> '*' "
			EndIf
			If nTime == 3 //Agrupador Final
				If nType == 1
					//Define Join padrão na Tabela
					cJinQry := " JOIN " + RetSQLName( "CTT" ) + " CTT ON CTT.CTT_CUSTO = SRA.RA_CC AND CTT.CTT_FILIAL = " + ValToSQL( xFilial( "CTT" ) ) + " AND CTT.D_E_L_E_T_ <> '*' "

					//Define Filtro da Tabela
					cFilQry := "		SRA.RA_CC = "
				ElseIf nType == 2
					//Define Join padrão na Tabela
					cJinQry := " JOIN " + RetSQLName( "SRJ" ) + " SRJ ON SRJ.RJ_FUNCAO = SRA.RA_CODFUNC AND SRJ.RJ_FILIAL = " + ValToSQL( xFilial( "SRJ" ) ) + " AND SRJ.D_E_L_E_T_ <> '*' "

					//Define Filtro da Tabela
					cFilQry := "		SRA.RA_CODFUNC = "
				ElseIf nType == 3
					//Define Join padrão na Tabela
					cJinQry := ""

					//Define Filtro da Tabela
					cFilQry := "		SRA.RA_MAT = "
				ElseIf nType == 4
					//Define Join padrão na Tabela
					cJinQry := ""

					//Define Filtro da Tabela
					cFilQry := "		SR8.R8_CID = "
				ElseIf nType == 5
					//Define Join padrão na Tabela
					cJinQry := ""

					//Define Filtro da Tabela
					cFilQry := "		SR8.R8_TIPO = "
				ElseIf nType == 6
					//Define Join padrão na Tabela
					cJinQry := ""

					//Define Filtro da Tabela
					cFilQry := "		SR8.R8_TIPOAFA = "
				EndIf
			EndIf
		ElseIf nPrinc == 2//Exames
			cTabela := "TM5"//Tabela padrão
			cDtGrup := "TM5.TM5_DTPROG"//Agrupador de data
			//Define o WHERE padrão
			cWhrPdr := " WHERE TM5.TM5_DTPROG <= " + ValToSQL( dDtFim ) + " AND TM5.TM5_DTPROG >= " + ValToSQL( dDtIni ) + " AND TM5.D_E_L_E_T_ <> '*' AND TM5.TM5_FILIAL = " + ValToSQL( xFilial( "TM5" ) )
			If nTime == 1 .Or. nTime == 2//Anual ou Mensal
				nTamGrp := 4
				If nTime == 2
					nTamGrp := 6
				EndIf
				If nType == 1//Centro de Custo
					//Define campos principais
					cCpsQry := " SRA.RA_CC AS CTT_CUSTO, "+cValBrc+"( CTT.CTT_DESC01 , '' ) AS CTT_DESC01 "

					//Define comparativo para os campos de percentual e contadores
					cCmpGrp := " AND SRA.RA_CC = SRA2.RA_CC "

					//Define os Join's dos Percentuais e Contadores
					cJoiGrp := " JOIN " + RetSQLName( "TM0" ) + " TM02 ON TM02.TM0_NUMFIC = TM52.TM5_NUMFIC AND TM02.TM0_FILIAL = " + ValToSQL( xFilial( "TM0" ) ) + " AND TM02.D_E_L_E_T_ <> '*' "
					cJoiGrp += " LEFT JOIN " + RetSQLName( "SRA" ) + " SRA2 ON SRA2.RA_MAT = TM02.TM0_MAT AND SRA2.RA_FILIAL = " + ValToSQL( xFilial( "SRA" ) ) + " AND SRA2.D_E_L_E_T_ <> '*' "
					cJoiGrp += " LEFT JOIN " + RetSQLName( "CTT" ) + " CTT2 ON CTT2.CTT_CUSTO = SRA2.RA_CC AND CTT2.CTT_FILIAL = " + ValToSQL( xFilial( "CTT" ) ) + " AND CTT2.D_E_L_E_T_ <> '*' "

					//Define Join padrão na Tabela
					cJinQry := " JOIN " + RetSQLName( "CTT" ) + " CTT ON CTT.CTT_CUSTO = SRA.RA_CC AND CTT.CTT_FILIAL = " + ValToSQL( xFilial( "CTT" ) ) + " AND CTT.D_E_L_E_T_ <> '*' "

					//Define Filtro da Tabela
					cFilQry := "		SRA.RA_CC = "

					//Define campo comparativo do Where
					cCmpWhr := " SRA.RA_CC "

					//Define agrupadores
					cGrpQry := ", SRA.RA_CC, CTT.CTT_DESC01"
				ElseIf nType == 2//Função
					//Define campos principais
					cCpsQry := " SRA.RA_CODFUNC AS RJ_FUNCAO, "+cValBrc+"( SRJ.RJ_DESC , '' ) AS RJ_DESC "

					//Define comparativo para os campos de percentual e contadores
					cCmpGrp := " AND SRA.RA_CODFUNC = SRA2.RA_CODFUNC "

					//Define os Join's dos Percentuais e Contadores
					cJoiGrp := " JOIN " + RetSQLName( "TM0" ) + " TM02 ON TM02.TM0_NUMFIC = TM52.TM5_NUMFIC AND TM02.TM0_FILIAL = " + ValToSQL( xFilial( "TM0" ) ) + " AND TM02.D_E_L_E_T_ <> '*' "
					cJoiGrp += " LEFT JOIN " + RetSQLName( "SRA" ) + " SRA2 ON SRA2.RA_MAT = TM02.TM0_MAT AND SRA2.RA_FILIAL = " + ValToSQL( xFilial( "SRA" ) ) + " AND SRA2.D_E_L_E_T_ <> '*' "
					cJoiGrp += " LEFT JOIN " + RetSQLName( "SRJ" ) + " SRJ2 ON SRJ2.RJ_FUNCAO = SRA2.RA_CODFUNC AND SRJ2.RJ_FILIAL = " + ValToSQL( xFilial( "SRJ" ) ) + " AND SRJ2.D_E_L_E_T_ <> '*' "

					//Define Join padrão na Tabela
					cJinQry := " JOIN " + RetSQLName( "SRJ" ) + " SRJ ON SRJ.RJ_FUNCAO = SRA.RA_CODFUNC AND SRJ.RJ_FILIAL = " + ValToSQL( xFilial( "SRJ" ) ) + " AND SRJ.D_E_L_E_T_ <> '*' "

					//Define Filtro da Tabela
					cFilQry := "		SRA.RA_CODFUNC = "

					//Define campo comparativo do Where
					cCmpWhr := " SRA.RA_CODFUNC "

					//Define agrupadores
					cGrpQry := ", SRA.RA_CODFUNC, SRJ.RJ_DESC"
				ElseIf nType == 3//Funcionário
					//Define campos principais
					cCpsQry := " SRA.RA_MAT AS RA_MAT, "+cValBrc+"( SRA.RA_NOME , '' ) AS RA_NOME "

					//Define comparativo para os campos de percentual e contadores
					cCmpGrp := " AND SRA.RA_MAT = SRA2.RA_MAT "

					//Define os Join's dos Percentuais e Contadores
					cJoiGrp := " LEFT JOIN " + RetSQLName( "TM0" ) + " TM02 ON TM02.TM0_NUMFIC = TM52.TM5_NUMFIC AND TM02.TM0_FILIAL = " + ValToSQL( xFilial( "TM0" ) ) + " AND TM02.D_E_L_E_T_ <> '*' "
					cJoiGrp += " LEFT JOIN " + RetSQLName( "SRA" ) + " SRA2 ON SRA2.RA_MAT = TM02.TM0_MAT AND SRA2.RA_FILIAL = " + ValToSQL( xFilial( "SRA" ) ) + " AND SRA2.D_E_L_E_T_ <> '*' "

					//Define Join padrão na Tabela
					cJinQry := ""

					//Define Filtro da Tabela
					cFilQry := "		SRA.RA_MAT = "

					//Define campo comparativo do Where
					cCmpWhr := " SRA.RA_MAT "

					//Define agrupadores
					cGrpQry := ", SRA.RA_MAT, SRA.RA_NOME"
				ElseIf nType == 4//Resultado
					//Define campos principais
					cCpsQry := " TM5.TM5_CODRES AS TMU_CODRES, "+cValBrc+"( TMU.TMU_RESULT , '' ) AS TMU_RESULT"

					//Define Join padrão na Tabela
					cJinQry := " LEFT JOIN " + RetSQLName( "TMU" ) + " TMU ON TMU.TMU_CODRES = TM5.TM5_CODRES AND TMU.TMU_FILIAL = " + ValToSQL( xFilial( "TMU" ) ) + " AND TMU.D_E_L_E_T_ <> '*' "

					//Define Filtro da Tabela
					cFilQry := "		TM5.TM5_CODRES = "
					cCmpGrp := " AND TM5.TM5_CODRES = TM52.TM5_CODRES "

					//Define campo comparativo do Where
					cCmpWhr := " TM5.TM5_CODRES "

					//Define agrupadores
					cGrpQry := ", TM5.TM5_CODRES, TMU.TMU_RESULT"
				ElseIf nType == 5//Tipo Exame
					//Define campos principais
					cCpsQry := " TM5.TM5_EXAME AS TM4_EXAME, "+cValBrc+"( TM4.TM4_NOMEXA , '' ) AS TM4_NOMEXA "

					//Define Join padrão na Tabela
					cJinQry := " JOIN " + RetSQLName( "TM4" ) + " TM4 ON TM4.TM4_EXAME = TM5.TM5_EXAME AND TM4.TM4_FILIAL = " + ValToSQL( xFilial( "TM4" ) ) + " AND TM4.D_E_L_E_T_ <> '*' "

					//Define Filtro da Tabela
					cFilQry := "		TM5.TM5_EXAME = "
					cCmpGrp := " AND TM5.TM5_EXAME = TM52.TM5_EXAME "

					//Define campo comparativo do Where
					cCmpWhr := " TM5.TM5_EXAME "

					//Define agrupadores
					cGrpQry := ", TM5.TM5_EXAME, TM4.TM4_NOMEXA"
				EndIf
				//Define os campos de Percentuais e Totais Normais e Alterados
				//Quantidade Normal
				cCpsQry += " , COUNT( CASE WHEN TM5.TM5_INDRES = '1' THEN 1 END ) AS NORMAL "
				//Percentual Normal
				cCpsQry += " , ( COUNT( CASE WHEN TM5.TM5_INDRES = '1' THEN 1 END ) * 100.00 ) / COUNT(*) AS PERCNOR "
				//Quantidade Alterado
				cCpsQry += " , COUNT( CASE WHEN TM5.TM5_INDRES = '2' THEN 1 END ) AS ALTERADO "
				//Percentual Alterado
				cCpsQry += " , ( COUNT( CASE WHEN TM5.TM5_INDRES = '2' THEN 1 END ) * 100.00 ) / COUNT(*) AS PERCALT "

				//Define o FROM e Join's fixos
				cQryFrm += " FROM " + RetSQLName( "TM5" ) + " TM5 "
				cQryFrm += " JOIN " + RetSQLName( "TM0" ) + " TM0 ON TM0.TM0_NUMFIC = TM5.TM5_NUMFIC AND TM0.TM0_FILIAL = " + ValToSQL( xFilial( "TM0" ) ) + " AND TM0.D_E_L_E_T_ <> '*' "
				cQryFrm += " JOIN " + RetSQLName( "SRA" ) + " SRA ON SRA.RA_MAT = TM0.TM0_MAT AND SRA.RA_FILIAL = " + ValToSQL( xFilial( "SRA" ) ) + " AND SRA.D_E_L_E_T_ <> '*' "
			ElseIf nTime == 3 //Agrupador Final
				If nType == 1//Centro de Custo
					//Define Join padrão na Tabela
					cJinQry := " JOIN " + RetSQLName( "CTT" ) + " CTT ON CTT.CTT_CUSTO = SRA.RA_CC AND CTT.CTT_FILIAL = " + ValToSQL( xFilial( "CTT" ) ) + " AND CTT.D_E_L_E_T_ <> '*' "

					//Define Filtro da Tabela
					cFilQry := "		SRA.RA_CC = "
				ElseIf nType == 2//Função
					//Define Join padrão na Tabela
					cJinQry := " JOIN " + RetSQLName( "SRJ" ) + " SRJ ON SRJ.RJ_FUNCAO = SRA.RA_CODFUNC AND SRJ.RJ_FILIAL = " + ValToSQL( xFilial( "SRJ" ) ) + " AND SRJ.D_E_L_E_T_ <> '*' "

					//Define Filtro da Tabela
					cFilQry := "		SRA.RA_CODFUNC = "
				ElseIf nType == 3//Funcionário
					//Define Join padrão na Tabela
					cJinQry := ""

					//Define Filtro da Tabela
					cFilQry := "		SRA.RA_MAT = "
				ElseIf nType == 4//Motivo
					//Define Join padrão na Tabela
					cJinQry := ""

					//Define Filtro da Tabela
					cFilQry := "		TM5.TM5_CODRES = "
				ElseIf nType == 5//Tipo Exame
					//Define Join padrão na Tabela
					cJinQry := ""

					//Define Filtro da Tabela
					cFilQry := "		TM5.TM5_EXAME = "
				EndIf

				//Define os Join's Fixos
				cQryJoi += " JOIN " + RetSQLName( "SRA" ) + " SRA ON SRA.RA_MAT = TM0.TM0_MAT AND SRA.RA_FILIAL = " + ValToSQL( xFilial( "SRA" ) ) + " AND SRA.D_E_L_E_T_ <> '*' "
			EndIf
		ElseIf nPrinc == 3//Diagnósticos
			cTabela := "TMT"//Tabela padrão
			cDtGrup := "TMT.TMT_DTATEN"//Agrupador de data
			cWhrPdr := " WHERE TMT.TMT_DTATEN <= " + ValToSQL( dDtFim ) + " AND TMT.TMT_DTATEN >= " + ValToSQL( dDtIni ) + " AND TMT.D_E_L_E_T_ <> '*' AND TMT.TMT_FILIAL = " + ValToSQL( xFilial( "TMT" ) )
			If nTime == 1 .Or. nTime == 2
				If nType == 1//Centro de Custo
					//Define campos principais
					cCpsQry := " SRA.RA_CC AS CTT_CUSTO, "+cValBrc+"( CTT.CTT_DESC01 , '' ) AS CTT_DESC01 "

					//Define Join padrão na Tabela
					cJinQry := " JOIN " + RetSQLName( "CTT" ) + " CTT ON CTT.CTT_CUSTO = SRA.RA_CC AND CTT.CTT_FILIAL = " + ValToSQL( xFilial( "CTT" ) ) + " AND CTT.D_E_L_E_T_ <> '*' "

					//Define Filtro da Tabela
					cFilQry := "		SRA.RA_CC = "

					//Define campo comparativo do Where
					cCmpWhr := " SRA.RA_CC "

					//Define agrupadores
					cGrpQry := ", SRA.RA_CC, CTT.CTT_DESC01"
				ElseIf nType == 2//Função
					//Define campos principais
					cCpsQry := " SRA.RA_CODFUNC AS RJ_FUNCAO, "+cValBrc+"( SRJ.RJ_DESC , '' ) AS RJ_DESC "

					//Define Join padrão na Tabela
					cJinQry := " JOIN " + RetSQLName( "SRJ" ) + " SRJ ON SRJ.RJ_FUNCAO = SRA.RA_CODFUNC AND SRJ.RJ_FILIAL = " + ValToSQL( xFilial( "SRJ" ) ) + " AND SRJ.D_E_L_E_T_ <> '*' "

					//Define Filtro da Tabela
					cFilQry := "		SRA.RA_CODFUNC = "

					//Define campo comparativo do Where
					cCmpWhr := " SRA.RA_CODFUNC "

					//Define agrupadores
					cGrpQry := ", SRA.RA_CODFUNC, SRJ.RJ_DESC"
				ElseIf nType == 3//Funcionário
					//Define campos principais
					cCpsQry := " SRA.RA_MAT AS RA_MAT, "+cValBrc+"( SRA.RA_NOME , '' ) AS RA_NOME "

					//Define Join padrão na Tabela
					cJinQry := ""

					//Define Filtro da Tabela
					cFilQry := "		SRA.RA_MAT = "

					//Define campo comparativo do Where
					cCmpWhr := " SRA.RA_MAT "

					//Define agrupadores
					cGrpQry := ", SRA.RA_MAT, SRA.RA_NOME"
				ElseIf nType == 4//Massa
					//Define campos principais
					cCpsQry := " "+cValBrc+"( TMT.TMT_MASSA , '' ) AS TMT_MASSA"

					//Define Join padrão na Tabela
					cJinQry := " "

					//Define Filtro da Tabela
					cFilQry := "		TMT.TMT_MASSA = "

					//Define campo comparativo do Where
					cCmpWhr := " TMT.TMT_MASSA "

					//Define agrupadores
					cGrpQry := ", TMT.TMT_MASSA"
				ElseIf nType == 5//Tipo de Atendimento
					//Define campos principais
					cCpsQry := " "+cValBrc+"( TMT.TMT_OCORRE , '' ) AS TMT_OCORRE"

					//Define campo descritivo do tipo de atendimento
					dbSelectArea( "SX3" )
					dbSetOrder( 2 )
					dbSeek( "TMT_OCORRE" )
					cCBox := X3CBOX()
					aCBox := StrTokArr( cCBox , ";" )
					For nCBox := 1 To Len( aCBox )
						If nCBox == 1
							cCpsQry += ", "
							cCpsQry += " CASE "
						EndIf
						nPosEqs := At( "=" , aCBox[ nCBox ] )
						cCpsQry += " WHEN TMT.TMT_OCORRE < " + ValToSQL( cValToChar( nCBox ) ) + " THEN " + ValToSQL( SubStr( aCBox[ nCBox ] , nPosEqs + 1 ) )
						If nCBox == Len( aCBox )
							cCpsQry += " ELSE '' "
							cCpsQry += "END "
							cCpsQry += "as TMT_DESOCO "
						EndIf
					Next nCBox

					//Define Join padrão na Tabela
					cJinQry := " "

					//Define Filtro da Tabela
					cFilQry := "		TMT.TMT_OCORRE = "

					//Define campo comparativo do Where
					cCmpWhr := " TMT.TMT_OCORRE "

					//Define agrupadores
					cGrpQry := ", TMT.TMT_OCORRE"
				ElseIf nType == 6//Pressão Sanguinea
					/*
					//Define campos principais
					cCpsQry := " "+cValBrc+"( TMT.TMT_PREART , '' ) AS TMT_PREART, '' AS LIMSIS, '' AS LIMDIS, "
					cCpsQry += " PRESART = "
					cCpsQry += " CASE "
					cCpsQry += " WHEN TMT.TMT_PRESIS > 0 AND TMT.TMT_PRESIS < 100 AND TMT.TMT_PREDIS < 60 AND TMT.TMT_PREDIS > 0 THEN 'HIPOTENSÃO' "
					cCpsQry += " WHEN TMT.TMT_PRESIS < 130 AND TMT.TMT_PREDIS < 85 THEN 'PRESSÃO NORMAL' "
					cCpsQry += " WHEN TMT.TMT_PRESIS >= 130 AND TMT.TMT_PRESIS < 139 AND TMT.TMT_PREDIS >= 85 AND TMT.TMT_PREDIS < 89 THEN 'PRESSÃO NORMAL LIMITROFE' "
					cCpsQry += " WHEN TMT.TMT_PRESIS < 140 AND TMT.TMT_PREDIS < 90 THEN 'HIPERTENSÃO SISTÓLICA ISOLADA' "
					cCpsQry += " WHEN TMT.TMT_PRESIS >= 140 AND TMT.TMT_PRESIS < 159 AND TMT.TMT_PREDIS >= 90 AND TMT.TMT_PREDIS < 99 THEN 'HIPERTENSÃO LEVE' "
					cCpsQry += " WHEN TMT.TMT_PRESIS >= 160 AND TMT.TMT_PRESIS < 179 AND TMT.TMT_PREDIS >= 100 AND TMT.TMT_PREDIS < 109 THEN 'HIPERTENSÃO MODERADA' "
					cCpsQry += " WHEN TMT.TMT_PRESIS >= 180 AND TMT.TMT_PRESIS < 200 AND TMT.TMT_PREDIS >= 110 THEN 'HIPERTENSÃO SEVERA' "
					cCpsQry += " WHEN TMT.TMT_PRESIS <= 200 THEN 'HIPERTENSÃO MUITO SEVERA' "
					cCpsQry += " ELSE 'VALORES INCOERENTES' "

					//Define Join padrão na Tabela
					cJinQry := " "

					//Define Filtro da Tabela
					cFilQry := "		TMT.TMT_PREART = "

					//Define campo comparativo do Where
					cCmpWhr := " TMT.TMT_PREART "

					//Define agrupadores
					cGrpQry := ", TMT.TMT_PREART" */
				EndIf
				//Define o FROM e Join's fixos
				cQryFrm += " FROM " + RetSQLName( "TMT" ) + " TMT "
				cQryFrm += " JOIN " + RetSQLName( "TM0" ) + " TM0 ON TM0.TM0_NUMFIC = TMT.TMT_NUMFIC AND TM0.TM0_FILIAL = " + ValToSQL( xFilial( "TM0" ) ) + " AND TM0.D_E_L_E_T_ <> '*' "
				cQryFrm += " JOIN " + RetSQLName( "SRA" ) + " SRA ON SRA.RA_MAT = TM0.TM0_MAT AND SRA.RA_FILIAL = " + ValToSQL( xFilial( "SRA" ) ) + " AND SRA.D_E_L_E_T_ <> '*' "
			ElseIf nTime == 3

				//Define campo descritivo do tipo de atendimento
				dbSelectArea( "SX3" )
				dbSetOrder( 2 )
				dbSeek( "TMT_OCORRE" )
				cCBox := X3CBOX()
				aCBox := StrTokArr( cCBox , ";" )
				For nCBox := 1 To Len( aCBox )
					If nCBox == 1
						cCpsQry += " CASE "
					EndIf
					nPosEqs := At( "=" , aCBox[ nCBox ] )
					cCpsQry += " WHEN TMT.TMT_OCORRE < " + ValToSQL( cValToChar( nCBox ) ) + " THEN " + ValToSQL( SubStr( aCBox[ nCBox ] , nPosEqs + 1 ) )
					If nCBox == Len( aCBox )
						cCpsQry += " ELSE '' "
						cCpsQry += "END "
						cCpsQry += "as TMT_DESOCO "
					EndIf
				Next nCBox

				If nType == 1//Centro de Custo
					//Define Join padrão na Tabela
					cJinQry := " JOIN " + RetSQLName( "CTT" ) + " CTT ON CTT.CTT_CUSTO = SRA.RA_CC AND CTT.CTT_FILIAL = " + ValToSQL( xFilial( "CTT" ) ) + " AND CTT.D_E_L_E_T_ <> '*' "

					//Define Filtro da Tabela
					cFilQry := "		SRA.RA_CC = "
				ElseIf nType == 2//Função
					//Define Join padrão na Tabela
					cJinQry := " JOIN " + RetSQLName( "SRJ" ) + " SRJ ON SRJ.RJ_FUNCAO = SRA.RA_CODFUNC AND SRJ.RJ_FILIAL = " + ValToSQL( xFilial( "SRJ" ) ) + " AND SRJ.D_E_L_E_T_ <> '*' "

					//Define Filtro da Tabela
					cFilQry := "		SRA.RA_CODFUNC = "
				ElseIf nType == 3//Funcionário
					//Define Join padrão na Tabela
					cJinQry := ""

					//Define Filtro da Tabela
					cFilQry := "		SRA.RA_MAT = "
				ElseIf nType == 4//Massa Corporea
					//Define Join padrão na Tabela
					cJinQry := ""

					//Define Filtro da Tabela
					cFilQry := "		TMT.TMT_MASSA = "
				ElseIf nType == 5//Tipo de Atendimento - TMS
					//Define Join padrão na Tabela
					cJinQry := " "

					//Define Filtro da Tabela
					cFilQry := "		TMT.TMT_OCORRE = "
				ElseIf nType == 6//Pressão Sanguinea
					/*
					//Define Join padrão na Tabela
					cJinQry := ""

					//Define Filtro da Tabela
					cFilQry := "		TMT.TMT_PREART = "*/
				EndIf
				//Define os Join's Fixos
				cQryJoi += " JOIN " + RetSQLName( "SRA" ) + " SRA ON SRA.RA_MAT = TM0.TM0_MAT AND SRA.RA_FILIAL = " + ValToSQL( xFilial( "SRA" ) ) + " AND SRA.D_E_L_E_T_ <> '*' "
			EndIf
		ElseIf nPrinc == 4 //Doenças
			cTabela := "TNA"//Tabela padrão
			cDtGrup := "TNA.TNA_DTINIC"//Agrupador de data
			//Define o WHERE padrão
			cWhrPdr := " WHERE TNA.TNA_DTINIC <= " + ValToSQL( dDtFim ) + " AND ( TNA.TNA_DTFIM = '' OR TNA.TNA_DTFIM >= " + ValToSQL( dDtIni ) + " ) AND TNA.D_E_L_E_T_ <> '*' AND TNA.TNA_FILIAL = " + ValToSQL( xFilial( "TNA" ) )
			If nTime == 1 .Or. nTime == 2
				If nType == 1//Centro de Custo
					//Define campos principais
					cCpsQry := " SRA.RA_CC AS CTT_CUSTO, "+cValBrc+"( CTT.CTT_DESC01 , '' ) AS CTT_DESC01 "

					//Define Join padrão na Tabela
					cJinQry := " JOIN " + RetSQLName( "CTT" ) + " CTT ON CTT.CTT_CUSTO = SRA.RA_CC AND CTT.CTT_FILIAL = " + ValToSQL( xFilial( "CTT" ) ) + " AND CTT.D_E_L_E_T_ <> '*' "

					//Define Filtro da Tabela
					cFilQry := "		SRA.RA_CC = "

					//Define campo comparativo do Where
					cCmpWhr := " SRA.RA_CC "

					//Define agrupadores
					cGrpQry := ", SRA.RA_CC, CTT.CTT_DESC01"
				ElseIf nType == 2//Função
					//Define campos principais
					cCpsQry := " SRA.RA_CODFUNC AS RJ_FUNCAO, "+cValBrc+"( SRJ.RJ_DESC , '' ) AS RJ_DESC "

					//Define Join padrão na Tabela
					cJinQry := " JOIN " + RetSQLName( "SRJ" ) + " SRJ ON SRJ.RJ_FUNCAO = SRA.RA_CODFUNC AND SRJ.RJ_FILIAL = " + ValToSQL( xFilial( "SRJ" ) ) + " AND SRJ.D_E_L_E_T_ <> '*' "

					//Define Filtro da Tabela
					cFilQry := "		SRA.RA_CODFUNC = "

					//Define campo comparativo do Where
					cCmpWhr := " SRA.RA_CODFUNC "

					//Define agrupadores
					cGrpQry := ", SRA.RA_CODFUNC, SRJ.RJ_DESC"
				ElseIf nType == 3//Funcionário
					//Define campos principais
					cCpsQry := " SRA.RA_MAT AS RA_MAT, "+cValBrc+"( SRA.RA_NOME , '' ) AS RA_NOME "

					//Define Join padrão na Tabela
					cJinQry := ""

					//Define Filtro da Tabela
					cFilQry := "		SRA.RA_MAT = "

					//Define campo comparativo do Where
					cCmpWhr := " SRA.RA_MAT "

					//Define agrupadores
					cGrpQry := ", SRA.RA_MAT, SRA.RA_NOME"
				ElseIf nType == 4//CID
					//Define campos principais
					cCpsQry := " TNA.TNA_CID AS TMR_CID, "+cValBrc+"( TMR.TMR_DOENCA , '' ) AS TMR_DOENCA"

					//Define Join padrão na Tabela
					cJinQry := " LEFT JOIN " + RetSQLName( "TMR" ) + " TMR ON TMR.TMR_CID = TNA.TNA_CID AND TMR.TMR_FILIAL = " + ValToSQL( xFilial( "TMR" ) ) + " AND TMR.D_E_L_E_T_ <> '*' "

					//Define Filtro da Tabela
					cFilQry := "		TNA.TNA_CID = "

					//Define campo comparativo do Where
					cCmpWhr := " TNA.TNA_CID "

					//Define agrupadores
					cGrpQry := ", TNA.TNA_CID, TMR.TMR_DOENCA"
				EndIf

				//Define o FROM e Join's fixos
				cQryFrm += " FROM " + RetSQLName( "TNA" ) + " TNA "
				cQryFrm += " JOIN " + RetSQLName( "TM0" ) + " TM0 ON TM0.TM0_NUMFIC = TNA.TNA_NUMFIC AND TM0.TM0_FILIAL = " + ValToSQL( xFilial( "TM0" ) ) + " AND TM0.D_E_L_E_T_ <> '*' "
				cQryFrm += " JOIN " + RetSQLName( "SRA" ) + " SRA ON SRA.RA_MAT = TM0.TM0_MAT AND SRA.RA_FILIAL = " + ValToSQL( xFilial( "SRA" ) ) + " AND SRA.D_E_L_E_T_ <> '*' "
			ElseIf nTime == 3
				If nType == 1//Centro de Custo
					//Define Join padrão na Tabela
					cJinQry := " JOIN " + RetSQLName( "CTT" ) + " CTT ON CTT.CTT_CUSTO = SRA.RA_CC AND CTT.CTT_FILIAL = " + ValToSQL( xFilial( "CTT" ) ) + " AND CTT.D_E_L_E_T_ <> '*' "

					//Define Filtro da Tabela
					cFilQry := "		SRA.RA_CC = "
				ElseIf nType == 2//Função
					//Define Join padrão na Tabela
					cJinQry := " JOIN " + RetSQLName( "SRJ" ) + " SRJ ON SRJ.RJ_FUNCAO = SRA.RA_CODFUNC AND SRJ.RJ_FILIAL = " + ValToSQL( xFilial( "SRJ" ) ) + " AND SRJ.D_E_L_E_T_ <> '*' "

					//Define Filtro da Tabela
					cFilQry := "		SRA.RA_CODFUNC = "
				ElseIf nType == 3//Funcionário
					//Define Join padrão na Tabela
					cJinQry := ""

					//Define Filtro da Tabela
					cFilQry := "		SRA.RA_MAT = "
				ElseIf nType == 4//CID
					//Define Join padrão na Tabela
					cJinQry := ""

					//Define Filtro da Tabela
					cFilQry := "		TNA.TNA_CID = "
				EndIf

				//Define os Join's Fixos
				cQryJoi += " JOIN " + RetSQLName( "SRA" ) + " SRA ON SRA.RA_MAT = TM0.TM0_MAT AND SRA.RA_FILIAL = " + ValToSQL( xFilial( "SRA" ) ) + " AND SRA.D_E_L_E_T_ <> '*' "
			EndIf
		ElseIf nPrinc == 5//Acidentes
			cAgrup	:= "TNC.TNC_ACIDEN"
			cTabela := "TNC"//Tabela padrão
			cDtGrup := "TNC.TNC_DTACID"//Agrupador de data
			//Define o WHERE padrão
			cWhrPdr := " WHERE TNC.TNC_DTACID <= " + ValToSQL( dDtFim ) + " AND TNC.TNC_DTACID >= " + ValToSQL( dDtIni ) + " AND TNC.D_E_L_E_T_ <> '*' AND TNC.TNC_FILIAL = " + ValToSQL( xFilial( "TNC" ) )
			If nTime == 1 .Or. nTime == 2
				If nType == 1//Centro de Custo
					//Define campos principais
					cCpsQry := " "+cValBrc+"( TNC.TNC_CC , '' ) AS CTT_CUSTO, "+cValBrc+"( CTT.CTT_DESC01 , '' ) AS CTT_DESC01 "

					//Define Join padrão na Tabela
					cJinQry := " LEFT JOIN " + RetSQLName( "CTT" ) + " CTT ON CTT.CTT_CUSTO = TNC.TNC_CC AND CTT.CTT_FILIAL = " + ValToSQL( xFilial( "CTT" ) ) + " AND CTT.D_E_L_E_T_ <> '*' "

					//Define Filtro da Tabela
					cFilQry := "		TNC.TNC_CC = "

					//Define campo comparativo do Where
					cCmpWhr := " TNC.TNC_CC "

					//Define agrupadores
					cGrpQry := ", TNC.TNC_CC, CTT.CTT_DESC01"
				ElseIf nType == 2//Função
					//Define campos principais
					cCpsQry := " "+cValBrc+"( SRA.RA_CODFUNC , '' ) AS RJ_FUNCAO, "+cValBrc+"( SRJ.RJ_DESC , '' ) AS RJ_DESC "

					//Define Join padrão na Tabela
					cJinQry := " LEFT JOIN " + RetSQLName( "SRJ" ) + " SRJ ON SRJ.RJ_FUNCAO = SRA.RA_CODFUNC AND SRJ.RJ_FILIAL = " + ValToSQL( xFilial( "SRJ" ) ) + " AND SRJ.D_E_L_E_T_ <> '*' "

					//Define Filtro da Tabela
					cFilQry := "		"+cValBrc+"( SRA.RA_CODFUNC , '' ) = "

					//Define campo comparativo do Where
					cCmpWhr := " "+cValBrc+"( SRA.RA_CODFUNC , '' ) "

					//Define agrupadores
					cGrpQry := ", SRA.RA_CODFUNC, SRJ.RJ_DESC"
				ElseIf nType == 3//Funcionário
					//Define campos principais
					cCpsQry := " "+cValBrc+"( SRA.RA_MAT , '' ) AS RA_MAT, "+cValBrc+"( SRA.RA_NOME , '' ) AS RA_NOME "

					//Define Join padrão na Tabela
					cJinQry := ""

					//Define Filtro da Tabela
					cFilQry := "		"+cValBrc+"( SRA.RA_MAT , '' ) = "

					//Define campo comparativo do Where
					cCmpWhr := " "+cValBrc+"( SRA.RA_MAT , '' ) "

					//Define agrupadores
					cGrpQry := ", SRA.RA_MAT, SRA.RA_NOME"
				ElseIf nType == 4//CID
					//Define campos principais
					cCpsQry := " TNC.TNC_CID AS TMR_CID, "+cValBrc+"( TMR.TMR_DOENCA , '' ) AS TMR_DOENCA"

					//Define Join padrão na Tabela
					cJinQry := " LEFT JOIN " + RetSQLName( "TMR" ) + " TMR ON TMR.TMR_CID = TNC.TNC_CID AND TMR.TMR_FILIAL = " + ValToSQL( xFilial( "TMR" ) ) + " AND TMR.D_E_L_E_T_ <> '*' "

					//Define Filtro da Tabela
					cFilQry := "		TNC.TNC_CID = "

					//Define campo comparativo do Where
					cCmpWhr := " TNC.TNC_CID "

					//Define agrupadores
					cGrpQry := ", TNC.TNC_CID, TMR.TMR_DOENCA"
				ElseIf nType == 5//Objeto Causado - TNH
					//Define campos principais
					cCpsQry := " "+cValBrc+"( TNC.TNC_CODOBJ , '' ) AS TNH_CODOBJ, "+cValBrc+"( TNH.TNH_DESOBJ , '' ) AS TNH_DESOBJ "

					//Define Join padrão na Tabela
					cJinQry := " LEFT JOIN " + RetSQLName( "TNH" ) + " TNH ON TNH.TNH_CODOBJ = TNC.TNC_CODOBJ AND TNH.TNH_FILIAL = " + ValToSQL( xFilial( "TNH" ) ) + " AND TNH.D_E_L_E_T_ <> '*' "

					//Define Filtro da Tabela
					cFilQry := "		TNC.TNC_CODOBJ = "

					//Define campo comparativo do Where
					cCmpWhr := " TNC.TNC_CODOBJ "

					//Define agrupadores
					cGrpQry := ", TNC.TNC_CODOBJ, TNH.TNH_DESOBJ"
				ElseIf nType == 6//Natureza - TOJ
					//Define campos principais
					cCpsQry := " "+cValBrc+"( TNC.TNC_CODLES , '' ) AS TOJ_CODLES, "+cValBrc+"( TOJ.TOJ_NOMLES , '' ) AS TOJ_NOMLES "

					//Define Join padrão na Tabela
					cJinQry := " LEFT JOIN " + RetSQLName( "TOJ" ) + " TOJ ON TOJ.TOJ_CODLES = TNC.TNC_CODLES AND TOJ.TOJ_FILIAL = " + ValToSQL( xFilial( "TOJ" ) ) + " AND TOJ.D_E_L_E_T_ <> '*' "

					//Define Filtro da Tabela
					cFilQry := "		TNC.TNC_CODLES = "

					//Define campo comparativo do Where
					cCmpWhr := " TNC.TNC_CODLES "

					//Define agrupadores
					cGrpQry := ", TNC.TNC_CODLES, TOJ.TOJ_NOMLES"
				ElseIf nType == 7//Parte - TOI
					//Define campos principais
					cCpsQry := " "+cValBrc+"( TNC.TNC_CODPAR , '' ) AS TOI_CODPAR, "+cValBrc+"( TOI.TOI_DESPAR , '' ) AS TOI_DESPAR "

					//Define Join padrão na Tabela
					cJinQry := " LEFT JOIN " + RetSQLName( "TOI" ) + " TOI ON TOI.TOI_CODPAR = TNC.TNC_CODPAR AND TOI.TOI_FILIAL = " + ValToSQL( xFilial( "TOI" ) ) + " AND TOI.D_E_L_E_T_ <> '*' "

					//Define Filtro da Tabela
					cFilQry := "		TNC.TNC_CODPAR = "

					//Define campo comparativo do Where
					cCmpWhr := " TNC.TNC_CODPAR "

					//Define agrupadores
					cGrpQry := ", TNC.TNC_CODPAR, TOI.TOI_DESPAR"
				ElseIf nType == 8 .Or. nType == 9//Com Afastamento
					//Define campos principais
					cCpsQry := ""

					//Define Join padrão na Tabela
					cJinQry := ""

					//Define Filtro da Tabela
					cFilQry := ""

					//Define campo comparativo do Where
					cCmpWhr := ""

					//Define agrupadores
					cGrpQry := ""

					If nType == 8
						//Define o Where de COM AFASTAMENTO
						cWhrPdr += " AND TNC_AFASTA = '1' "
					Else
						//Define o Where de SEM AFASTAMENTO
						cWhrPdr += " AND TNC_AFASTA = '2' "
					EndIf
				ElseIf nType == 10//Tipo - TNG
					//Define campos principais
					cCpsQry := " "+cValBrc+"( TNC.TNC_TIPACI , '' ) AS TNG_TIPACI, "+cValBrc+"( TNG.TNG_DESTIP , '' ) AS TNG_DESTIP "

					//Define Join padrão na Tabela
					cJinQry := " LEFT JOIN " + RetSQLName( "TNG" ) + " TNG ON TNG.TNG_TIPACI = TNC.TNC_TIPACI AND TNG.TNG_FILIAL = " + ValToSQL( xFilial( "TNG" ) ) + " AND TNG.D_E_L_E_T_ <> '*' "

					//Define Filtro da Tabela
					cFilQry := "		TNC.TNC_TIPACI = "

					//Define campo comparativo do Where
					cCmpWhr := " TNC.TNC_TIPACI "

					//Define agrupadores
					cGrpQry := ", TNC.TNC_TIPACI, TNG.TNG_DESTIP"
				EndIf
				//Define o FROM e Join's fixos
				cQryFrm += " FROM " + RetSQLName( "TNC" ) + " TNC "
				cQryFrm += " LEFT JOIN " + RetSQLName( "TM0" ) + " TM0 ON TM0.TM0_NUMFIC = TNC.TNC_NUMFIC AND TM0.TM0_FILIAL = " + ValToSQL( xFilial( "TM0" ) ) + " AND TM0.D_E_L_E_T_ <> '*' "
				If nValBus == 7
					cWhrPdr += " AND TNC.TNC_NUMFIC <> '' "
				EndIf
				cQryFrm += " LEFT JOIN " + RetSQLName( "SRA" ) + " SRA ON SRA.RA_MAT = TM0.TM0_MAT AND SRA.RA_FILIAL = " + ValToSQL( xFilial( "SRA" ) ) + " AND SRA.D_E_L_E_T_ <> '*' "
			ElseIf nTime == 3
				If nType == 1//Centro de Custo
					//Define Join padrão na Tabela
					cJinQry := " LEFT JOIN " + RetSQLName( "CTT" ) + " CTT ON CTT.CTT_CUSTO = TNC.TNC_CC AND CTT.CTT_FILIAL = " + ValToSQL( xFilial( "CTT" ) ) + " AND CTT.D_E_L_E_T_ <> '*' "

					//Define Filtro da Tabela
					cFilQry := "		TNC.TNC_CC = "
				ElseIf nType == 2//Função
					//Define Join padrão na Tabela
					cJinQry := " LEFT JOIN " + RetSQLName( "SRJ" ) + " SRJ ON SRJ.RJ_FUNCAO = SRA.RA_CODFUNC AND SRJ.RJ_FILIAL = " + ValToSQL( xFilial( "SRJ" ) ) + " AND SRJ.D_E_L_E_T_ <> '*' "

					//Define Filtro da Tabela
					cFilQry := "		SRA.RA_CODFUNC = "
				ElseIf nType == 3//Funcionário
					//Define Join padrão na Tabela
					cJinQry := ""

					//Define Filtro da Tabela
					cFilQry := "		SRA.RA_MAT = "
				ElseIf nType == 4//CID
					//Define Join padrão na Tabela
					cJinQry := ""

					//Define Filtro da Tabela
					cFilQry := "		TNC.TNC_CID = "
				ElseIf nType == 5//Objeto - TNH
					//Define Join padrão na Tabela
					cJinQry := " LEFT JOIN " + RetSQLName( "TNH" ) + " TNH ON TNH.TNH_CODOBJ = TNC.TNC_CODOBJ AND TNH.TNH_FILIAL = " + ValToSQL( xFilial( "TNH" ) ) + " AND TNH.D_E_L_E_T_ <> '*' "

					//Define Filtro da Tabela
					cFilQry := "		TNC.TNC_CODOBJ = "
				ElseIf nType == 6//Natureza - TOJ
					//Define Join padrão na Tabela
					cJinQry := " LEFT JOIN " + RetSQLName( "TOJ" ) + " TOJ ON TOJ.TOJ_CODLES = TNC.TNC_CODLES AND TOJ.TOJ_FILIAL = " + ValToSQL( xFilial( "TOJ" ) ) + " AND TOJ.D_E_L_E_T_ <> '*' "

					//Define Filtro da Tabela
					cFilQry := "		TNC.TNC_CODLES = "
				ElseIf nType == 7//Parte - TOI
					//Define Join padrão na Tabela
					cJinQry := " LEFT JOIN " + RetSQLName( "TOI" ) + " TOI ON TOI.TOI_CODPAR = TNC.TNC_CODPAR AND TOI.TOI_FILIAL = " + ValToSQL( xFilial( "TOI" ) ) + " AND TOI.D_E_L_E_T_ <> '*' "

					//Define Filtro da Tabela
					cFilQry := "		TNC.TNC_CODPAR = "
				ElseIf nType == 8 .Or. nType == 9//Com Afastamento e Sem Afastamento
					//Define Join padrão na Tabela
					cJinQry := ""

					//Define Filtro da Tabela
					cFilQry := ""

					If nType == 8
						//Define o Where de COM AFASTAMENTO
						cWhrPdr += " AND TNC_AFASTA = '1' "
					Else
						//Define o Where de SEM AFASTAMENTO
						cWhrPdr += " AND TNC_AFASTA = '2' "
					EndIf
				ElseIf nType == 10//Tipo de Acidente - TNG
					//Define Join padrão na Tabela
					cJinQry := " LEFT JOIN " + RetSQLName( "TNG" ) + " TNG ON TNG.TNG_TIPACI = TNC.TNC_TIPACI AND TNG.TNG_FILIAL = " + ValToSQL( xFilial( "TNG" ) ) + " AND TNG.D_E_L_E_T_ <> '*' "

					//Define Filtro da Tabela
					cFilQry := "		TNC.TNC_TIPACI = "
				ElseIf nType == 11//Faixa
				EndIf

				//Define os Join's Fixos
				cQryJoi += " LEFT JOIN " + RetSQLName( "SRA" ) + " SRA ON SRA.RA_MAT = TM0.TM0_MAT AND SRA.RA_FILIAL = " + ValToSQL( xFilial( "SRA" ) ) + " AND SRA.D_E_L_E_T_ <> '*' "
			EndIf
		EndIf

		//------------------------------
		// MONTAGEM DA QUERY
		//------------------------------
		If nTime == 1 .Or. nTime == 2//Caso seja agrupado por Ano ou Mes

			//Define o tamanho do Agrupador de Data
			nTamGrp := 4
			If nTime == 2
				nTamGrp := 6
			EndIf

			//Verifica se é a Busca Padrão
			If nTotais == 0
				If nValBus == 1
					cQuery += " SELECT COUNT(*) AS OCORRENCIA, "+cSubString+"(" + cDtGrup + ",1," + cValToChar( nTamGrp ) + ") AS PERIODO "
					If !Empty( cCpsQry )
						cQuery += ", "
						cQuery += cCpsQry
					EndIf
				ElseIf nValBus == 2//Indica se é a busca por total de ocorrências
					cQuery += " SELECT COUNT( " + cAgrup + " ) AS TOTAL "
				ElseIf nValBus == 3//Indica se é a busca agrupada por faixa etária
					cQuery += cQryIdd
				ElseIf nValBus == 4 .Or. nValBus == 6//Indica se é a busca por quantidade de funcionários
					cQuery += " SELECT COUNT( DISTINCT( SRA.RA_MAT ) ) AS TOTAL "
				ElseIf nValBus == 5//Indica se é a busca agrupada por sexo
					cQuery += cQrySex
				ElseIf nValBus == 7//Indica se é busca de horas trabalhadas
					cQuery += cQryTrb
				ElseIf nValBus == 8//Indica se é busca de horas de Absenteísmo
					cQuery += cQryAbs
				ElseIf nValBus == 9//Indica se é busca de horas de Acidente
					cQuery += cQryAci
				EndIf
			ElseIf nTotais == 1
				cQuery += " SELECT SRA.RA_SEXO AS SEXO ,COUNT(*) AS OCORRENCIA "
			ElseIf nTotais == 2
				cQuery += " SELECT "+cValBrc+"( SUM( SR8.R8_DURACAO ) , 0 ) AS OCORRENCIA "
			EndIf
			//Define o FROM
			cQuery += cQryFrm

			//Verifica se possui algum JOIN
			If !Empty( cJinQry )
				cQuery += cJinQry
			EndIf
			If !Empty( cQryJoi )
				cQuery += cQryJoi
			EndIf

			//Define o WHERE de Filtro
			cQuery += cWhrPdr

			//Adiciona campo de Filtro
			If !Empty( cCmpWhr )
				//Caso não tenha WHERE define apenas pelo campo de Filtro, caso possua adiciona um AND
				If Empty( cWhrPdr )
					cQuery += " WHERE "
				Else
					cQuery += " AND "
				EndIf
				cQuery += " " + cCmpWhr + " <= " + ValToSQL( cFilFim ) + " AND " + cCmpWhr + " >= " + ValToSQL( cFilIni )
			EndIf

			//Caso seja mensal, ajusta os Filtros
			If ( nTime == 2 .Or. nValBus >= 2 .And. nValBus <= 5) .And. ( !Empty( cFilPer ) .Or. ValType( cFilPdr ) == "C"  )
				//Caso não tenha WHERE define apenas pelo campo de Filtro, caso possua adiciona um AND
				If Empty( cWhrPdr ) .And. Empty( cCmpWhr )
					cQuery += " WHERE "
				Else
					cQuery += " AND "
				EndIf

				//Verifica se tem um Filtro de Data
				If nValBus >= 2
					If !Empty( cFilPer )
						cQuery += " 	"+cSubString+"(" + cDtGrup + ",1," + cValToChar( nTamGrp ) + ") = " + ValToSQL( cFilPer )
					EndIf
				Else
					If !Empty( cFilPer )
						cQuery += " 	"+cSubString+"(" + cDtGrup + ",1,4) = " + ValToSQL( cFilPer )
					EndIf
				EndIF

				//Verifiac se tem um Filtro Padrão
				If ( ValType( cFilPdr ) == "C" )
					If !Empty( cFilPer )
						cQuery += " AND "
					EndIf
					cQuery += cFilQry + ValToSQL( cFilPdr )
				EndIf
			EndIf

			If nValBus == 8 .And. !Empty( cWhrAbs )
				//Caso não tenha WHERE define apenas pelo campo de Filtro, caso possua adiciona um AND
				If Empty( cWhrPdr ) .And. Empty( cCmpWhr )
					cQuery += " WHERE "
				Else
					cQuery += " AND "
				EndIf
				cQuery += cWhrAbs
			EndIf

			If nTotais == 0
				//Verifica o Tipo de Retorno
				If nValBus == 1 //Caso seja Padrão, Agrupa pela Data Primeiramente e depois pelos Grupos definidos
					cQuery += " GROUP BY "+cSubString+"(" + cDtGrup + ",1," + cValToChar( nTamGrp ) + ")" + cGrpQry
				ElseIf nValBus == 3 //Caso seja por Faixa Etária, Agrupa pelas Faixas
					cQuery += cGrpIdd
				ElseIf nValBus == 5//Caso seja por Sexo, Agrupa pelos Sexos
					cQuery += cGrpSex
				ElseIf nValBus == 7//Caso seja por Sexo, Agrupa pelos Sexos
					cQuery += cGrpTrb
				ElseIf nValBus == 8 .And. nPrinc <> 1
					cQuery += ") "
				ElseIf nValBus == 9 .And. nPrinc <> 1 .And. nPrinc <> 5
					cQuery += ") "
				EndIf
			ElseIf nTotais == 1
				cQuery += " GROUP BY SRA.RA_SEXO "
			EndIf
		ElseIf nTime == 3//Caso seja o retorno final

			//Define o SELECT
			If nTotais == 0
				cQuery += " SELECT "
				For nCmp := 1 To Len( aColCmp )
					If nCmp > 1
						cQuery += ", "
					EndIf
					cQuery += cTabela + "." + aColCmp[ nCmp ]
				Next nCmp
			ElseIf nTotais == 1
				cQuery += " SELECT SRA.RA_SEXO AS SEXO, COUNT(*) AS OCORRENCIA "
			ElseIf nTotais == 2
				cQuery += " SELECT "+cValBrc+"( SUM( SR8.R8_DURACAO ) , 0 ) AS OCORRENCIA "
			EndIf
			If !Empty( cQryJoi )
				cQryBkp := cQryJoi
				cQryJoi	:= ""
			EndIF
			For nCmp := 1 To Len( aCmpVir )
				If !Empty( aCmpVir[ nCmp , _nPosVirCDo ] )
					If nTotais == 0
						If 	"SELECT" <> AllTrim( cQuery )
							cQuery += ", "
						EndIf
						cQuery += cValBrc + "( " + aCmpVir[ nCmp , _nPosVirTab ] + "." + aCmpVir[ nCmp , _nPosVirCp2 ] + ",'') AS " + aCmpVir[ nCmp , _nPosVirCmp ]
					EndIf
					cQryJoi += " LEFT JOIN " + RetSQLName( aCmpVir[ nCmp , _nPosVirTab ] ) + " " + aCmpVir[ nCmp , _nPosVirTab ]
					cQryJoi += " ON " + aCmpVir[ nCmp , _nPosVirTab ] + "." + aCmpVir[ nCmp , _nPosVirCDo ] + " = " + cTabela + "." + aCmpVir[ nCmp , _nPosVirDom ]
					cQryJoi += " AND " + aCmpVir[ nCmp , _nPosVirTab ] + "." + PrefixoCPO ( aCmpVir[ nCmp , _nPosVirTab ] ) + "_FILIAL = " + ValToSQL( xFilial( aCmpVir[ nCmp , _nPosVirTab ] ) )
					cQryJoi += 	" AND " + aCmpVir[ nCmp , _nPosVirTab ] + ".D_E_L_E_T_ <> '*' "
					If Len( aCmpVir[ nCmp ] ) >= _nPosVirVal .And. !Empty( aCmpVir[ nCmp , _nPosVirVal ] )
						cQryJoi += " AND " + aCmpVir[ nCmp , _nPosVirVal ]
					EndIf
				EndIf
			Next nCmp
			If !Empty( cQryBkp )
				cQryJoi += cQryBkp
			EndIF

			If nTotais == 0
				//Adiciona campos extras
				If 	"SELECT" <> AllTrim( cQuery ) .And. !Empty( cCpsQry )
					cQuery += ", "
				EndIf
				If !Empty( cCpsQry )
					cQuery += cCpsQry
				EndIf
				//Adiciona o RECNO para utilização da visualização
				If 	"SELECT" <> AllTrim( cQuery )
					cQuery += ", "
				EndIf
				cQuery += " " + cTabela + ".R_E_C_N_O_ AS RECNO "
			EndIf

			cQuery += " FROM " + RetSQLName( cTabela ) + " " + cTabela
			If !Empty( cQryJoi )
				cQuery += cQryJoi
			EndIf
			If !Empty( cJinQry )
				cQuery += cJinQry
			EndIf

			cQuery += cWhrPdr

			If ( !Empty( cFilPer ) .Or. ValType( cFilPdr ) == "C" )
				//Caso não tenha WHERE define apenas pelo campo de Filtro, caso possua adiciona um AND
				If Empty( cWhrPdr )
					cQuery += " WHERE "
				Else
					cQuery += " AND "
				EndIf

				//Verifica se tem um Filtro de Data
				If !Empty( cFilPer )
					cQuery += " 	"+cSubString+"(" + cDtGrup + ",1,6) = " + ValToSQL( cFilPer )
				EndIf

				//VerificA se tem um Filtro Padrão
				If ( ValType( cFilPdr ) == "C" )
					If !Empty( cFilPer )
						cQuery += " AND "
					EndIf
					cQuery += cFilQry + ValToSQL( cFilPdr )
				EndIf
			EndIf

			If nTotais == 1
				cQuery += " GROUP BY SRA.RA_SEXO "
			EndIf

		EndIf
	EndIf

Return cQuery

//---------------------------------------------------------------------
/*/{Protheus.doc} RetQueryPress
Retorna as querys da consulta de Pressão Sanguinea

@return cQuery Caracter Retorna a Query a ser executada

@param nPrinc Numerico Tipo de Visualização: 1 - Absenteísmo; 2 - Exames; 3 - Diagnósticos; 4 - Doenças; 5 - Acidentes
@param nType Numerico Tipo de Agrupamento (Varia de acordo com o Tipo de Visualização)
@param nTime Numerico Indica o período: 1 - Anual; 2 - Mensal
@param dDtIni Data Valor da Data Início
@param dDtFim Data Valor da Data Fim
@param cFilIni Caracter Valor do Filtro Inicial
@param cFilFim Caracter Valor do Filtro Final
@param cFilPdr Caracter Filtro da Listagem secundária, indica o agrupador da Listagem principal
@param cFilPer Caracter Filtro da Listagem secundária, indica o período da Listagem principal
@param aColCmp Array Campos a serem exibidos na Query
@param aCmpVir Array Campos 'virtuais' a serem exibidos na Query
@param nValBus Numerico Indica de qual busca deve fazer: 1 - Padrão;
														 2 - Quantidade de Ocorrências;
														 3 - Por Faixa de Idade;
														 4 - Quantidade de Funcionários (Filtrados);
														 5 - Quantidade de Funcionários por Sexo;
														 6 - Quantidade de Funcionários - Total;
														 7 - Quantidade de Horas Trabalhadas;
														 8 - Quantidade de Horas Trabalhadas Afastadas;
														 9 - Quantidade de Horas Afastadas (Acidente)
@param nTotais Somatórias finais: 1 - Sexo; 2 - Horas Afastamento

@sample
RetQueryPress( 1 , 1 , 1 , "01/01/2000" , "31/12/2020" , "" , "ZZZZZZ" , "2014" , "000001" , {} , {} )

@author Jackson Machado
@since 18/07/2014
/*/
//---------------------------------------------------------------------
Static Function RetQueryPress( nPrinc , nType , nTime , dDtIni , dDtFim , cFilIni , cFilFim , cFilPdr , cFilPer , aColCmp , aCmpVir , nValBus , nTotais  )

	Local cQuery := ""
	Local cValBrc	:= "ISNULL" //Validação de ISNULL tratada
	Local cGetDB 	:= TcGetDb() //Traz a base de dados
	Local nDiffMon //Calcula diferença entre data início e final
	//Define o ISNULL de acordo com a base de dados
	If cGetDB == "ORACLE"
		cValBrc := "NVL"
	ElseIf "DB2" $ cGetDB .Or. cGetDB == "POSTGRES"
		cValBrc := "COALESCE"
	Else
		cValBrc := "ISNULL"
	EndIf

	If nTime < 3
		If nTotais == 0
			If nValBus == 1
				If nTime == 1
					cQuery += " SELECT COUNT(*) AS OCORRENCIA, "
					cQuery += " CASE "
					cQuery += " WHEN TMT.TMT_PRESIS = 0 AND TMT.TMT_PREDIS = 0 THEN 'VALORES INCOERENTES'"
					cQuery += " WHEN TMT.TMT_PRESIS < 100 AND TMT.TMT_PREDIS < 60 THEN 'HIPOTENSÃO' "
					cQuery += " WHEN TMT.TMT_PRESIS < 130 AND TMT.TMT_PREDIS < 85 THEN 'PRESSÃO NORMAL' "
					cQuery += " WHEN TMT.TMT_PRESIS < 139 AND TMT.TMT_PREDIS < 89 THEN 'PRESSÃO NORMAL LIMITROFE' "
					cQuery += " WHEN TMT.TMT_PRESIS < 140 AND TMT.TMT_PREDIS <= 90 THEN 'HIPERTENSÃO SISTÓLICA ISOLADA' "
					cQuery += " WHEN TMT.TMT_PRESIS < 159 AND TMT.TMT_PREDIS < 99 THEN 'HIPERTENSÃO LEVE' "
					cQuery += " WHEN TMT.TMT_PRESIS < 179 AND TMT.TMT_PREDIS < 109 THEN 'HIPERTENSÃO MODERADA' "
					cQuery += " WHEN TMT.TMT_PRESIS < 200 AND TMT.TMT_PREDIS >= 110 THEN 'HIPERTENSÃO SEVERA' "
					cQuery += " WHEN TMT.TMT_PRESIS <= 200 THEN 'HIPERTENSÃO MUITO SEVERA' "
					cQuery += " ELSE 'VALORES INCOERENTES' "
					cQuery += " END AS PRESART, "
					cQuery += +cSubString+"(TMT.TMT_DTATEN,1,4) AS PERIODO  "
					cQuery += " FROM " + RetSQLName( "TMT" ) + " TMT "
					cQuery += " JOIN " + RetSQLName( "TM0" ) + " TM0 "
					cQuery += " ON TM0.TM0_NUMFIC = TMT.TMT_NUMFIC AND TM0.TM0_FILIAL = " + ValToSQL( xFilial( "TM0" ) ) + " AND TM0.D_E_L_E_T_ <> '*' "
					cQuery += " JOIN " + RetSQLName( "SRA" ) + " SRA ON SRA.RA_MAT = TM0.TM0_MAT AND SRA.RA_FILIAL = " + ValToSQL( xFilial( "SRA" ) ) + " AND SRA.D_E_L_E_T_ <> '*' "
					cQuery += " WHERE TMT.TMT_DTATEN <= " + ValToSQL( dDtFim ) + " AND TMT.TMT_DTATEN >= " + ValToSQL( dDtIni ) + " AND TMT.D_E_L_E_T_ <> '*' "
					cQuery += "AND TMT.TMT_FILIAL = " + ValToSQL( xFilial( "TMT" ) )
					cQuery += "GROUP BY "+cSubString+"(TMT.TMT_DTATEN,1,4),TMT.TMT_PRESIS,TMT.TMT_PREDIS "
				Else
					cQuery += " SELECT SUM( OCORRENCIA ) AS OCORRENCIA,PRESART, "
					cQuery += " PERIODO FROM "
					cQuery += " ( "
					cQuery += " SELECT COUNT(*) AS OCORRENCIA,"
					cQuery += " CASE "
					cQuery += " WHEN TMT.TMT_PRESIS = 0 AND TMT.TMT_PREDIS = 0 THEN 'VALORES INCOERENTES'"
					cQuery += " WHEN TMT.TMT_PRESIS < 100 AND TMT.TMT_PREDIS < 60 THEN 'HIPOTENSÃO' "
					cQuery += " WHEN TMT.TMT_PRESIS < 130 AND TMT.TMT_PREDIS < 85 THEN 'PRESSÃO NORMAL' "
					cQuery += " WHEN TMT.TMT_PRESIS < 139 AND TMT.TMT_PREDIS < 89 THEN 'PRESSÃO NORMAL LIMITROFE' "
					cQuery += " WHEN TMT.TMT_PRESIS < 140 AND TMT.TMT_PREDIS <= 90 THEN 'HIPERTENSÃO SISTÓLICA ISOLADA' "
					cQuery += " WHEN TMT.TMT_PRESIS < 159 AND TMT.TMT_PREDIS < 99 THEN 'HIPERTENSÃO LEVE' "
					cQuery += " WHEN TMT.TMT_PRESIS < 179 AND TMT.TMT_PREDIS < 109 THEN 'HIPERTENSÃO MODERADA' "
					cQuery += " WHEN TMT.TMT_PRESIS < 200 AND TMT.TMT_PREDIS >= 110 THEN 'HIPERTENSÃO SEVERA' "
					cQuery += " WHEN TMT.TMT_PRESIS <= 200 THEN 'HIPERTENSÃO MUITO SEVERA' "
					cQuery += " ELSE 'VALORES INCOERENTES' "
					cQuery += " END AS PRESART, "
					cQuery += +cSubString+"(TMT.TMT_DTATEN,1,6) AS PERIODO  "
					cQuery += " FROM " + RetSQLName( "TMT" ) + " TMT "
					cQuery += " JOIN " + RetSQLName( "TM0" ) + " TM0 "
					cQuery += " ON TM0.TM0_NUMFIC = TMT.TMT_NUMFIC AND TM0.TM0_FILIAL = " + ValToSQL( xFilial( "TM0" ) ) + " AND TM0.D_E_L_E_T_ <> '*' "
					cQuery += " JOIN " + RetSQLName( "SRA" ) + " SRA ON SRA.RA_MAT = TM0.TM0_MAT AND SRA.RA_FILIAL = " + ValToSQL( xFilial( "SRA" ) ) + " AND SRA.D_E_L_E_T_ <> '*' "
					cQuery += " WHERE TMT.TMT_DTATEN <= " + ValToSQL( dDtFim ) + " AND TMT.TMT_DTATEN >= " + ValToSQL( dDtIni ) + " AND TMT.D_E_L_E_T_ <> '*' "
					cQuery += " AND TMT.TMT_FILIAL = " + ValToSQL( xFilial( "TMT" ) )
					If ValType( cFilPer ) == "C" .And. !Empty( cFilPer )
						cQuery += " AND "+cSubString+"(TMT.TMT_DTATEN,1,4) = " + ValToSQL( cFilPer )
					EndIf
					cQuery += " GROUP BY "+cSubString+"(TMT.TMT_DTATEN,1,6),TMT.TMT_PRESIS,TMT.TMT_PREDIS "
					cQuery += ") TBL "
					If ValType( cFilPdr ) == "C" .And. !Empty( cFilPdr )
						cQuery += "WHERE PRESART = " + ValToSQL( cFilPdr ) + " "
					EndIf
					cQuery += "GROUP BY PRESART, PERIODO"
				EndIf
			ElseIf nValBus == 2
				cQuery += " SELECT COUNT( MAT ) AS TOTAL FROM ( "
				cQuery += " SELECT SRA.RA_MAT AS MAT, "
				cQuery += " CASE "
				cQuery += " WHEN TMT.TMT_PRESIS = 0 AND TMT.TMT_PREDIS = 0 THEN 'VALORES INCOERENTES'"
				cQuery += " WHEN TMT.TMT_PRESIS < 100 AND TMT.TMT_PREDIS < 60 THEN 'HIPOTENSÃO' "
				cQuery += " WHEN TMT.TMT_PRESIS < 130 AND TMT.TMT_PREDIS < 85 THEN 'PRESSÃO NORMAL' "
				cQuery += " WHEN TMT.TMT_PRESIS < 139 AND TMT.TMT_PREDIS < 89 THEN 'PRESSÃO NORMAL LIMITROFE' "
				cQuery += " WHEN TMT.TMT_PRESIS < 140 AND TMT.TMT_PREDIS <= 90 THEN 'HIPERTENSÃO SISTÓLICA ISOLADA' "
				cQuery += " WHEN TMT.TMT_PRESIS < 159 AND TMT.TMT_PREDIS < 99 THEN 'HIPERTENSÃO LEVE' "
				cQuery += " WHEN TMT.TMT_PRESIS < 179 AND TMT.TMT_PREDIS < 109 THEN 'HIPERTENSÃO MODERADA' "
				cQuery += " WHEN TMT.TMT_PRESIS < 200 AND TMT.TMT_PREDIS >= 110 THEN 'HIPERTENSÃO SEVERA' "
				cQuery += " WHEN TMT.TMT_PRESIS <= 200 THEN 'HIPERTENSÃO MUITO SEVERA' "
				cQuery += " ELSE 'VALORES INCOERENTES' "
				cQuery += " END AS PRESART"
				cQuery += " FROM " + RetSQLName( "TMT" ) + " TMT "
				cQuery += " JOIN " + RetSQLName( "TM0" ) + " TM0 "
				cQuery += " ON TM0.TM0_NUMFIC = TMT.TMT_NUMFIC AND TM0.TM0_FILIAL = " + ValToSQL( xFilial( "TM0" ) ) + " AND TM0.D_E_L_E_T_ <> '*' "
				cQuery += " JOIN " + RetSQLName( "SRA" ) + " SRA ON SRA.RA_MAT = TM0.TM0_MAT AND SRA.RA_FILIAL = " + ValToSQL( xFilial( "SRA" ) ) + " AND SRA.D_E_L_E_T_ <> '*' "
				cQuery += " WHERE TMT.TMT_DTATEN <= " + ValToSQL( dDtFim ) + " AND TMT.TMT_DTATEN >= " + ValToSQL( dDtIni ) + " AND TMT.D_E_L_E_T_ <> '*' "
				cQuery += " AND TMT.TMT_FILIAL = " + ValToSQL( xFilial( "TMT" ) )
				If nTime == 1
					cQuery += " AND "+cSubString+"(TMT.TMT_DTATEN,1,4) = " + ValToSQL( cFilPer ) +" "
				Else
					cQuery += " AND "+cSubString+"(TMT.TMT_DTATEN,1,6) = " + ValToSQL( cFilPer ) +" "
				EndIf
				cQuery += " ) TBL "
				If ValType( cFilPdr ) == "C" .And. !Empty( cFilPdr )
					cQuery += "WHERE PRESART = " + ValToSQL( cFilPdr ) + " "
				EndIf
			ElseIf nValBus == 3
				cQuery += " SELECT IDADE, SEXO, SUM( QTDFUN ) AS QTDFUN, SUM( OCORRENCIA ) AS OCORRENCIA , ( SUM( OCORRENCIA ) * 100.0 ) / " + ValToSQL( nTotOco ) + " AS PERCEN FROM "
				cQuery += "( "
				cQuery += " SELECT "
				cQuery += " CASE "
				cQuery += " WHEN IDADE < 18 THEN 1"
				cQuery += " WHEN IDADE >= 18 AND IDADE <= 30 THEN 2 "
				cQuery += " WHEN IDADE >= 31 AND IDADE <= 40 THEN 3 "
				cQuery += " WHEN IDADE >= 41 AND IDADE <= 50 THEN 4 "
				cQuery += " WHEN IDADE >= 51 AND IDADE <= 60 THEN 5 "
				cQuery += " WHEN IDADE >= 61 AND IDADE <= 70 THEN 6 "
				cQuery += " WHEN IDADE >= 71 THEN 7 "
				cQuery += " ELSE 0 "
				cQuery += "END AS IDADE"
				cQuery += ", SEXO, COUNT(DISTINCT(MAT)) AS QTDFUN , COUNT(MAT) AS OCORRENCIA FROM "
				cQuery += "( "
				cQuery += " SELECT SRA.RA_MAT AS MAT, ( CONVERT( INTEGER , "+ ValToSQL( DtoS( dDataBase ) ) +" ) - CONVERT( INTEGER , SRA.RA_NASC ) ) / 10000 AS IDADE , SRA.RA_SEXO AS SEXO, "
				cQuery += " CASE "
				cQuery += " WHEN TMT.TMT_PRESIS = 0 AND TMT.TMT_PREDIS = 0 THEN 'VALORES INCOERENTES'"
				cQuery += " WHEN TMT.TMT_PRESIS < 100 AND TMT.TMT_PREDIS < 60 THEN 'HIPOTENSÃO' "
				cQuery += " WHEN TMT.TMT_PRESIS < 130 AND TMT.TMT_PREDIS < 85 THEN 'PRESSÃO NORMAL' "
				cQuery += " WHEN TMT.TMT_PRESIS < 139 AND TMT.TMT_PREDIS < 89 THEN 'PRESSÃO NORMAL LIMITROFE' "
				cQuery += " WHEN TMT.TMT_PRESIS < 140 AND TMT.TMT_PREDIS <= 90 THEN 'HIPERTENSÃO SISTÓLICA ISOLADA' "
				cQuery += " WHEN TMT.TMT_PRESIS < 159 AND TMT.TMT_PREDIS < 99 THEN 'HIPERTENSÃO LEVE' "
				cQuery += " WHEN TMT.TMT_PRESIS < 179 AND TMT.TMT_PREDIS < 109 THEN 'HIPERTENSÃO MODERADA' "
				cQuery += " WHEN TMT.TMT_PRESIS < 200 AND TMT.TMT_PREDIS >= 110 THEN 'HIPERTENSÃO SEVERA' "
				cQuery += " WHEN TMT.TMT_PRESIS <= 200 THEN 'HIPERTENSÃO MUITO SEVERA' "
				cQuery += " ELSE 'VALORES INCOERENTES' "
				cQuery += " END AS PRESART"
				cQuery += " FROM " + RetSQLName( "TMT" ) + " TMT "
				cQuery += " JOIN " + RetSQLName( "TM0" ) + " TM0 "
				cQuery += " ON TM0.TM0_NUMFIC = TMT.TMT_NUMFIC AND TM0.TM0_FILIAL = " + ValToSQL( xFilial( "TM0" ) ) + " AND TM0.D_E_L_E_T_ <> '*' "
				cQuery += " JOIN " + RetSQLName( "SRA" ) + " SRA ON SRA.RA_MAT = TM0.TM0_MAT AND SRA.RA_FILIAL = " + ValToSQL( xFilial( "SRA" ) ) + " AND SRA.D_E_L_E_T_ <> '*' "
				cQuery += " WHERE TMT.TMT_DTATEN <= " + ValToSQL( dDtFim ) + " AND TMT.TMT_DTATEN >= " + ValToSQL( dDtIni ) + " AND TMT.D_E_L_E_T_ <> '*' "
				cQuery += " AND TMT.TMT_FILIAL = " + ValToSQL( xFilial( "TMT" ) )
				If nTime == 1
					cQuery += " AND "+cSubString+"(TMT.TMT_DTATEN,1,4) = " + ValToSQL( cFilPer ) +" "
				Else
					cQuery += " AND "+cSubString+"(TMT.TMT_DTATEN,1,6) = " + ValToSQL( cFilPer ) +" "
				EndIf
				cQuery += " ) TBL "
				If ValType( cFilPdr ) == "C" .And. !Empty( cFilPdr )
					cQuery += "WHERE PRESART = " + ValToSQL( cFilPdr ) + " "
				EndIf
				cQuery += " GROUP BY SEXO, IDADE "
				cQuery += " ) ALS "
				cQuery += " GROUP BY IDADE, SEXO "
			ElseIf nValBus == 4
				cQuery += " SELECT COUNT( DISTINCT( MAT ) ) AS TOTAL FROM ( "
				cQuery += " SELECT SRA.RA_MAT AS MAT, "
				cQuery += " CASE "
				cQuery += " WHEN TMT.TMT_PRESIS = 0 AND TMT.TMT_PREDIS = 0 THEN 'VALORES INCOERENTES'"
				cQuery += " WHEN TMT.TMT_PRESIS < 100 AND TMT.TMT_PREDIS < 60 THEN 'HIPOTENSÃO' "
				cQuery += " WHEN TMT.TMT_PRESIS < 130 AND TMT.TMT_PREDIS < 85 THEN 'PRESSÃO NORMAL' "
				cQuery += " WHEN TMT.TMT_PRESIS < 139 AND TMT.TMT_PREDIS < 89 THEN 'PRESSÃO NORMAL LIMITROFE' "
				cQuery += " WHEN TMT.TMT_PRESIS < 140 AND TMT.TMT_PREDIS <= 90 THEN 'HIPERTENSÃO SISTÓLICA ISOLADA' "
				cQuery += " WHEN TMT.TMT_PRESIS < 159 AND TMT.TMT_PREDIS < 99 THEN 'HIPERTENSÃO LEVE' "
				cQuery += " WHEN TMT.TMT_PRESIS < 179 AND TMT.TMT_PREDIS < 109 THEN 'HIPERTENSÃO MODERADA' "
				cQuery += " WHEN TMT.TMT_PRESIS < 200 AND TMT.TMT_PREDIS >= 110 THEN 'HIPERTENSÃO SEVERA' "
				cQuery += " WHEN TMT.TMT_PRESIS <= 200 THEN 'HIPERTENSÃO MUITO SEVERA' "
				cQuery += " ELSE 'VALORES INCOERENTES' "
				cQuery += " END AS PRESART"
				cQuery += " FROM " + RetSQLName( "TMT" ) + " TMT "
				cQuery += " JOIN " + RetSQLName( "TM0" ) + " TM0 "
				cQuery += " ON TM0.TM0_NUMFIC = TMT.TMT_NUMFIC AND TM0.TM0_FILIAL = " + ValToSQL( xFilial( "TM0" ) ) + " AND TM0.D_E_L_E_T_ <> '*' "
				cQuery += " JOIN " + RetSQLName( "SRA" ) + " SRA ON SRA.RA_MAT = TM0.TM0_MAT AND SRA.RA_FILIAL = " + ValToSQL( xFilial( "SRA" ) ) + " AND SRA.D_E_L_E_T_ <> '*' "
				cQuery += " WHERE TMT.TMT_DTATEN <= " + ValToSQL( dDtFim ) + " AND TMT.TMT_DTATEN >= " + ValToSQL( dDtIni ) + " AND TMT.D_E_L_E_T_ <> '*' "
				cQuery += " AND TMT.TMT_FILIAL = " + ValToSQL( xFilial( "TMT" ) )
				If nTime == 1
					cQuery += " AND "+cSubString+"(TMT.TMT_DTATEN,1,4) = " + ValToSQL( cFilPer ) +" "
				Else
					cQuery += " AND "+cSubString+"(TMT.TMT_DTATEN,1,6) = " + ValToSQL( cFilPer ) +" "
				EndIf
				cQuery += " ) TBL "
				If ValType( cFilPdr ) == "C" .And. !Empty( cFilPdr )
					cQuery += "WHERE PRESART = " + ValToSQL( cFilPdr ) + " "
				EndIf
			ElseIf nValBus == 5
				cQuery += " SELECT SEXO, COUNT( DISTINCT( MAT ) ) AS TOTAL, ( COUNT( DISTINCT( MAT ) ) * 100.00 ) / " + ValToSQL( nTotFun ) + " AS PERCEN  "
				cQuery += " FROM ( "
				cQuery += " SELECT SRA.RA_SEXO AS SEXO, SRA.RA_MAT AS MAT , "
				cQuery += " CASE "
				cQuery += " WHEN TMT.TMT_PRESIS = 0 AND TMT.TMT_PREDIS = 0 THEN 'VALORES INCOERENTES'"
				cQuery += " WHEN TMT.TMT_PRESIS < 100 AND TMT.TMT_PREDIS < 60 THEN 'HIPOTENSÃO' "
				cQuery += " WHEN TMT.TMT_PRESIS < 130 AND TMT.TMT_PREDIS < 85 THEN 'PRESSÃO NORMAL' "
				cQuery += " WHEN TMT.TMT_PRESIS < 139 AND TMT.TMT_PREDIS < 89 THEN 'PRESSÃO NORMAL LIMITROFE' "
				cQuery += " WHEN TMT.TMT_PRESIS < 140 AND TMT.TMT_PREDIS <= 90 THEN 'HIPERTENSÃO SISTÓLICA ISOLADA' "
				cQuery += " WHEN TMT.TMT_PRESIS < 159 AND TMT.TMT_PREDIS < 99 THEN 'HIPERTENSÃO LEVE' "
				cQuery += " WHEN TMT.TMT_PRESIS < 179 AND TMT.TMT_PREDIS < 109 THEN 'HIPERTENSÃO MODERADA' "
				cQuery += " WHEN TMT.TMT_PRESIS < 200 AND TMT.TMT_PREDIS >= 110 THEN 'HIPERTENSÃO SEVERA' "
				cQuery += " WHEN TMT.TMT_PRESIS <= 200 THEN 'HIPERTENSÃO MUITO SEVERA' "
				cQuery += " ELSE 'VALORES INCOERENTES' "
				cQuery += " END AS PRESART"
				cQuery += " FROM " + RetSQLName( "TMT" ) + " TMT "
				cQuery += " JOIN " + RetSQLName( "TM0" ) + " TM0 "
				cQuery += " ON TM0.TM0_NUMFIC = TMT.TMT_NUMFIC AND TM0.TM0_FILIAL = " + ValToSQL( xFilial( "TM0" ) ) + " AND TM0.D_E_L_E_T_ <> '*' "
				cQuery += " JOIN " + RetSQLName( "SRA" ) + " SRA ON SRA.RA_MAT = TM0.TM0_MAT AND SRA.RA_FILIAL = " + ValToSQL( xFilial( "SRA" ) ) + " AND SRA.D_E_L_E_T_ <> '*' "
				cQuery += " WHERE TMT.TMT_DTATEN <= " + ValToSQL( dDtFim ) + " AND TMT.TMT_DTATEN >= " + ValToSQL( dDtIni ) + " AND TMT.D_E_L_E_T_ <> '*' "
				cQuery += " AND TMT.TMT_FILIAL = " + ValToSQL( xFilial( "TMT" ) )
				If nTime == 1
					cQuery += " AND "+cSubString+"(TMT.TMT_DTATEN,1,4) = " + ValToSQL( cFilPer ) +" "
				Else
					cQuery += " AND "+cSubString+"(TMT.TMT_DTATEN,1,6) = " + ValToSQL( cFilPer ) +" "
				EndIf
				cQuery += " ) TBL "
				If ValType( cFilPdr ) == "C" .And. !Empty( cFilPdr )
					cQuery += "WHERE PRESART = " + ValToSQL( cFilPdr ) + " "
				EndIf
				cQuery += " GROUP BY SEXO "
			ElseIf nValBus == 6
				cQuery += " SELECT COUNT( DISTINCT( SRA.RA_MAT ) ) AS TOTAL "
				cQuery += " FROM " + RetSQLName( "TMT" ) + " TMT "
				cQuery += " JOIN " + RetSQLName( "TM0" ) + " TM0 "
				cQuery += " ON TM0.TM0_NUMFIC = TMT.TMT_NUMFIC AND TM0.TM0_FILIAL = " + ValToSQL( xFilial( "TM0" ) ) + " AND TM0.D_E_L_E_T_ <> '*' "
				cQuery += " JOIN " + RetSQLName( "SRA" ) + " SRA ON SRA.RA_MAT = TM0.TM0_MAT AND SRA.RA_FILIAL = " + ValToSQL( xFilial( "SRA" ) ) + " AND SRA.D_E_L_E_T_ <> '*' "
				cQuery += " WHERE TMT.TMT_DTATEN <= " + ValToSQL( dDtFim ) + " AND TMT.TMT_DTATEN >= " + ValToSQL( dDtIni ) + " AND TMT.D_E_L_E_T_ <> '*' "
				cQuery += " AND TMT.TMT_FILIAL = " + ValToSQL( xFilial( "TMT" ) )
			ElseIf nValBus == 7

				//Define diferença de meses
				nDiffMon := ( dDtFim - dDtIni ) + 1

				cQuery += " SELECT SUM( TOTHRS ) AS TOTHRS FROM ( "
				cQuery += "  				SELECT DISTINCT(SRA.RA_MAT) AS MAT, "
				cQuery += "  						CASE SRA.RA_HRSMES"
				cQuery += "  							WHEN 0 THEN 1"
				cQuery += "  							ELSE 1"
				cQuery += "  						END * " + ValToSQL( nDiffMon ) + " AS TOTHRS "
				cQuery += " FROM " + RetSQLName( "TMT" ) + " TMT "
				cQuery += " JOIN " + RetSQLName( "TM0" ) + " TM0 "
				cQuery += " ON TM0.TM0_NUMFIC = TMT.TMT_NUMFIC AND TM0.TM0_FILIAL = " + ValToSQL( xFilial( "TM0" ) ) + " AND TM0.D_E_L_E_T_ <> '*' "
				cQuery += " JOIN " + RetSQLName( "SRA" ) + " SRA ON SRA.RA_MAT = TM0.TM0_MAT AND SRA.RA_FILIAL = " + ValToSQL( xFilial( "SRA" ) ) + " AND SRA.D_E_L_E_T_ <> '*' "
				cQuery += " WHERE TMT.TMT_DTATEN <= " + ValToSQL( dDtFim ) + " AND TMT.TMT_DTATEN >= " + ValToSQL( dDtIni ) + " AND TMT.D_E_L_E_T_ <> '*' "
				cQuery += " AND TMT.TMT_FILIAL = " + ValToSQL( xFilial( "TMT" ) )
				cQuery += " ) TBL
			ElseIf nValBus == 8
				cQuery += " SELECT "+cValBrc+"( SUM( SR8.R8_DURACAO ) , 0 ) AS DURACAO  "
				cQuery += " FROM " + RetSQLName( "SR8" ) + " SR8  "
				cQuery += " WHERE SR8.R8_DATAINI <= " + ValToSQL( dDtFim ) + " AND ( SR8.R8_DATAFIM = '' OR SR8.R8_DATAFIM >= " + ValToSQL( dDtIni ) + " ) AND SR8.D_E_L_E_T_ <> '*' "
				cQuery += " AND SR8.R8_FILIAL = " + ValToSQL( xFilial( "SR8" ) ) + " AND SR8.R8_MAT IN (  SELECT DISTINCT( RA_MAT )  "
				cQuery += " FROM " + RetSQLName( "TMT" ) + " TMT "
				cQuery += " JOIN " + RetSQLName( "TM0" ) + " TM0 "
				cQuery += " ON TM0.TM0_NUMFIC = TMT.TMT_NUMFIC AND TM0.TM0_FILIAL = " + ValToSQL( xFilial( "TM0" ) ) + " AND TM0.D_E_L_E_T_ <> '*' "
				cQuery += " JOIN " + RetSQLName( "SRA" ) + " SRA ON SRA.RA_MAT = TM0.TM0_MAT AND SRA.RA_FILIAL = " + ValToSQL( xFilial( "SRA" ) ) + " AND SRA.D_E_L_E_T_ <> '*' "
				cQuery += " WHERE TMT.TMT_DTATEN <= " + ValToSQL( dDtFim ) + " AND TMT.TMT_DTATEN >= " + ValToSQL( dDtIni ) + " AND TMT.D_E_L_E_T_ <> '*' "
				cQuery += " AND TMT.TMT_FILIAL = " + ValToSQL( xFilial( "TMT" ) )
				cQuery += " ) "
			ElseIf nValBus == 9
				cQuery += " SELECT "+cValBrc+"( SUM( SR8.R8_DURACAO ) , 0 ) AS DURACAO  "
				cQuery += " FROM " + RetSQLName( "TMT" ) + " TMT "
				cQuery += " JOIN " + RetSQLName( "TM0" ) + " TM0 "
				cQuery += " ON TM0.TM0_NUMFIC = TMT.TMT_NUMFIC AND TM0.TM0_FILIAL = " + ValToSQL( xFilial( "TM0" ) ) + " AND TM0.D_E_L_E_T_ <> '*' "
				cQuery += " JOIN " + RetSQLName( "SRA" ) + " SRA ON SRA.RA_MAT = TM0.TM0_MAT AND SRA.RA_FILIAL = " + ValToSQL( xFilial( "SRA" ) ) + " AND SRA.D_E_L_E_T_ <> '*' "
				cQuery += " JOIN " + RetSQLName( "TNY" ) + " TNY ON TNY.TNY_NUMFIC = TM0.TM0_NUMFIC AND TNY.D_E_L_E_T_ <> '*' AND TNY.TNY_FILIAL = " + ValToSQL( xFilial( "TNY" ) ) + " "
				cQuery += " AND TNY.TNY_DTSAID <> '' "
				cQuery += " JOIN " + RetSQLName( "TNC" ) + " TNC ON TNC.TNC_ACIDEN = TNY.TNY_ACIDEN AND TNC.D_E_L_E_T_ <> '*' "
				cQuery += " AND TNC.TNC_FILIAL = " + ValToSQL( xFilial( "TNC" ) ) + " AND TNC.TNC_DTACID <= " + ValToSQL( dDtFim ) + " AND TNC.TNC_DTACID >= " + ValToSQL( dDtIni ) + " "
				cQuery += " JOIN " + RetSQLName( "SR8" ) + " SR8  "
				cQuery += " ON SR8.R8_DATAINI <= " + ValToSQL( dDtFim ) + " AND ( SR8.R8_DATAFIM = '' OR SR8.R8_DATAFIM >= " + ValToSQL( dDtIni ) + " ) AND SR8.D_E_L_E_T_ <> '*' "
				cQuery += " AND SR8.R8_FILIAL = " + ValToSQL( xFilial( "TM0" ) )
				cQuery += " AND "
				cQuery += "   			( TNY.TNY_DTSAID = SR8.R8_DATAINI OR TNY.TNY_DTSAI2 = SR8.R8_DATAINI OR TNY.TNY_DTSAI3 = SR8.R8_DATAINI )  "
				If nType == 5
					cQuery += " AND SR8.R8_TIPO = TNY.TNY_TIPAFA "
				ElseIf nType == 6
					cQuery += " AND SR8.R8_TIPOAFA = TNY.TNY_CODAFA "
				EndIf
				cQuery += " WHERE TMT.TMT_DTATEN <= " + ValToSQL( dDtFim ) + " AND TMT.TMT_DTATEN >= " + ValToSQL( dDtIni ) + " AND TMT.D_E_L_E_T_ <> '*' "
				cQuery += " AND TMT.TMT_FILIAL = " + ValToSQL( xFilial( "TMT" ) )
			EndIf
		ElseIf nTotais == 1
			If nTime == 1
				cQuery += " SELECT SRA.RA_SEXO AS SEXO ,COUNT(*) AS OCORRENCIA  "
				cQuery += " FROM " + RetSQLName( "TMT" ) + " TMT "
				cQuery += " JOIN " + RetSQLName( "TM0" ) + " TM0 "
				cQuery += " ON TM0.TM0_NUMFIC = TMT.TMT_NUMFIC AND TM0.TM0_FILIAL = " + ValToSQL( xFilial( "TM0" ) ) + " AND TM0.D_E_L_E_T_ <> '*' "
				cQuery += " JOIN " + RetSQLName( "SRA" ) + " SRA ON SRA.RA_MAT = TM0.TM0_MAT AND SRA.RA_FILIAL = " + ValToSQL( xFilial( "SRA" ) ) + " AND SRA.D_E_L_E_T_ <> '*' "
				cQuery += " WHERE TMT.TMT_DTATEN <= " + ValToSQL( dDtFim ) + " AND TMT.TMT_DTATEN >= " + ValToSQL( dDtIni ) + " AND TMT.D_E_L_E_T_ <> '*' "
				cQuery += " AND TMT.TMT_FILIAL = " + ValToSQL( xFilial( "TMT" ) )
				cQuery += " GROUP BY SRA.RA_SEXO "
			Else
				cQuery += " SELECT SEXO, COUNT(*) AS OCORRENCIA FROM ( "
				cQuery += " SELECT SRA.RA_SEXO AS SEXO , "
				cQuery += " CASE "
				cQuery += " WHEN TMT.TMT_PRESIS = 0 AND TMT.TMT_PREDIS = 0 THEN 'VALORES INCOERENTES'"
				cQuery += " WHEN TMT.TMT_PRESIS < 100 AND TMT.TMT_PREDIS < 60 THEN 'HIPOTENSÃO' "
				cQuery += " WHEN TMT.TMT_PRESIS < 130 AND TMT.TMT_PREDIS < 85 THEN 'PRESSÃO NORMAL' "
				cQuery += " WHEN TMT.TMT_PRESIS < 139 AND TMT.TMT_PREDIS < 89 THEN 'PRESSÃO NORMAL LIMITROFE' "
				cQuery += " WHEN TMT.TMT_PRESIS < 140 AND TMT.TMT_PREDIS <= 90 THEN 'HIPERTENSÃO SISTÓLICA ISOLADA' "
				cQuery += " WHEN TMT.TMT_PRESIS < 159 AND TMT.TMT_PREDIS < 99 THEN 'HIPERTENSÃO LEVE' "
				cQuery += " WHEN TMT.TMT_PRESIS < 179 AND TMT.TMT_PREDIS < 109 THEN 'HIPERTENSÃO MODERADA' "
				cQuery += " WHEN TMT.TMT_PRESIS < 200 AND TMT.TMT_PREDIS >= 110 THEN 'HIPERTENSÃO SEVERA' "
				cQuery += " WHEN TMT.TMT_PRESIS <= 200 THEN 'HIPERTENSÃO MUITO SEVERA' "
				cQuery += " ELSE 'VALORES INCOERENTES' "
				cQuery += " END AS PRESART"
				cQuery += " FROM " + RetSQLName( "TMT" ) + " TMT "
				cQuery += " JOIN " + RetSQLName( "TM0" ) + " TM0 "
				cQuery += " ON TM0.TM0_NUMFIC = TMT.TMT_NUMFIC AND TM0.TM0_FILIAL = " + ValToSQL( xFilial( "TM0" ) ) + " AND TM0.D_E_L_E_T_ <> '*' "
				cQuery += " JOIN " + RetSQLName( "SRA" ) + " SRA ON SRA.RA_MAT = TM0.TM0_MAT AND SRA.RA_FILIAL = " + ValToSQL( xFilial( "SRA" ) ) + " AND SRA.D_E_L_E_T_ <> '*' "
				cQuery += " WHERE TMT.TMT_DTATEN <= " + ValToSQL( dDtFim ) + " AND TMT.TMT_DTATEN >= " + ValToSQL( dDtIni ) + " AND TMT.D_E_L_E_T_ <> '*' "
				cQuery += " AND TMT.TMT_FILIAL = " + ValToSQL( xFilial( "TMT" ) )
				If ValType( cFilPer ) == "C" .And. !Empty( cFilPer )
					cQuery += " AND "+cSubString+"(TMT.TMT_DTATEN,1,4) = " + ValToSQL( cFilPer )
				EndIf
				cQuery += " ) TBL "
				If ValType( cFilPdr ) == "C" .And. !Empty( cFilPdr )
					cQuery += "WHERE PRESART = " + ValToSQL( cFilPdr ) + " "
				EndIf
				cQuery += " GROUP BY SEXO "
			Endif
		EndIf
	Else
		If nTotais == 0
			If nValBus == 1
				cQuery += " SELECT * FROM "
				cQuery += " ( "
				cQuery += " SELECT "
				cQuery += " TMT.TMT_NUMFIC, TMT.TMT_DTCONS, TMT.TMT_CODUSU, TMT.TMT_DTATEN, TMT.TMT_HRATEN, "
				cQuery += " TMT.TMT_CID, TMT.TMT_OCORRE, TMT.TMT_MASSA, TMT.TMT_ALTURA, TMT.TMT_PESO, TMT.TMT_TEMPER, "
				cQuery += " TMT.TMT_QUEIXA, TMT.TMT_DIAGNO, TM0.TM0_NOMFIC AS TMT_NOMFIC ,"
				cQuery += " TMK.TMK_NOMUSU AS TMT_NOMUSU, " +cValBrc+ "(TMR.TMR_DOENCA,'') AS TMT_DOENCA, "
				cQuery += " CASE  "
				cQuery += " WHEN TMT.TMT_OCORRE < '1' THEN 'Atend. Clinico' "
				cQuery += " WHEN TMT.TMT_OCORRE < '2' THEN 'Doença do Trabalho' "
				cQuery += " WHEN TMT.TMT_OCORRE < '3' THEN 'Acidente Tipico' "
				cQuery += " WHEN TMT.TMT_OCORRE < '4' THEN 'Acidente Trajeto' "
				cQuery += " WHEN TMT.TMT_OCORRE < '5' THEN 'Outros Atendimentos' "
				cQuery += " WHEN TMT.TMT_OCORRE < '6' THEN 'Avaliação NR7                ' "
				cQuery += " ELSE '' "
				cQuery += " END AS TMT_DESOCO, "
				cQuery += " CASE "
				cQuery += " WHEN TMT.TMT_PRESIS = 0 AND TMT.TMT_PREDIS = 0 THEN 'VALORES INCOERENTES'"
				cQuery += " WHEN TMT.TMT_PRESIS < 100 AND TMT.TMT_PREDIS < 60 THEN 'HIPOTENSÃO' "
				cQuery += " WHEN TMT.TMT_PRESIS < 130 AND TMT.TMT_PREDIS < 85 THEN 'PRESSÃO NORMAL' "
				cQuery += " WHEN TMT.TMT_PRESIS < 139 AND TMT.TMT_PREDIS < 89 THEN 'PRESSÃO NORMAL LIMITROFE' "
				cQuery += " WHEN TMT.TMT_PRESIS < 140 AND TMT.TMT_PREDIS <= 90 THEN 'HIPERTENSÃO SISTÓLICA ISOLADA' "
				cQuery += " WHEN TMT.TMT_PRESIS < 159 AND TMT.TMT_PREDIS < 99 THEN 'HIPERTENSÃO LEVE' "
				cQuery += " WHEN TMT.TMT_PRESIS < 179 AND TMT.TMT_PREDIS < 109 THEN 'HIPERTENSÃO MODERADA' "
				cQuery += " WHEN TMT.TMT_PRESIS < 200 AND TMT.TMT_PREDIS >= 110 THEN 'HIPERTENSÃO SEVERA' "
				cQuery += " WHEN TMT.TMT_PRESIS <= 200 THEN 'HIPERTENSÃO MUITO SEVERA' "
				cQuery += " ELSE 'VALORES INCOERENTES' "
				cQuery += " END AS PRESART,"
				cQuery += " TMT.R_E_C_N_O_ AS RECNO "
				cQuery += " FROM " + RetSQLName( "TMT" ) + " TMT "
				cQuery += " JOIN " + RetSQLName( "TM0" ) + " TM0 "
				cQuery += " ON TM0.TM0_NUMFIC = TMT.TMT_NUMFIC AND TM0.TM0_FILIAL = " + ValToSQL( xFilial( "TM0" ) ) + " AND TM0.D_E_L_E_T_ <> '*' "
				cQuery += " JOIN " + RetSQLName( "SRA" ) + " SRA ON SRA.RA_MAT = TM0.TM0_MAT AND SRA.RA_FILIAL = " + ValToSQL( xFilial( "SRA" ) ) + " AND SRA.D_E_L_E_T_ <> '*' "
				cQuery += " LEFT JOIN " + RetSQLName( "TMK" ) + " TMK ON TMK.TMK_CODUSU = TMT.TMT_CODUSU AND TMK.TMK_FILIAL = " + ValToSQL( xFilial( "TMK" ) ) + " AND TMK.D_E_L_E_T_ <> '*'  LEFT JOIN " + RetSQLName( "TMR" ) + " TMR ON TMR.TMR_CID = TMT.TMT_CID AND TMR.TMR_FILIAL = " + ValToSQL( xFilial( "TMR" ) ) + " AND TMR.D_E_L_E_T_ <> '*' "
				cQuery += " WHERE TMT.TMT_DTATEN <= " + ValToSQL( dDtFim ) + " AND TMT.TMT_DTATEN >= " + ValToSQL( dDtIni ) + " AND TMT.D_E_L_E_T_ <> '*' "
				cQuery += " AND TMT.TMT_FILIAL = " + ValToSQL( xFilial( "TMT" ) )
				cQuery += " AND "+cSubString+"(TMT.TMT_DTATEN,1,6) = " + ValToSQL( cFilPer )
				cQuery += ") TBL "
				If ValType( cFilPdr ) == "C" .And. !Empty( cFilPdr )
					cQuery += "WHERE PRESART = " + ValToSQL( cFilPdr ) + " "
				EndIf
			EndIf
		ElseIf nTotais == 1
			cQuery += " SELECT SEXO, COUNT(*) AS OCORRENCIA FROM ( "
			cQuery += " SELECT SRA.RA_SEXO AS SEXO , "
			cQuery += " CASE "
			cQuery += " WHEN TMT.TMT_PRESIS = 0 AND TMT.TMT_PREDIS = 0 THEN 'VALORES INCOERENTES'"
			cQuery += " WHEN TMT.TMT_PRESIS < 100 AND TMT.TMT_PREDIS < 60 THEN 'HIPOTENSÃO' "
			cQuery += " WHEN TMT.TMT_PRESIS < 130 AND TMT.TMT_PREDIS < 85 THEN 'PRESSÃO NORMAL' "
			cQuery += " WHEN TMT.TMT_PRESIS < 139 AND TMT.TMT_PREDIS < 89 THEN 'PRESSÃO NORMAL LIMITROFE' "
			cQuery += " WHEN TMT.TMT_PRESIS < 140 AND TMT.TMT_PREDIS <= 90 THEN 'HIPERTENSÃO SISTÓLICA ISOLADA' "
			cQuery += " WHEN TMT.TMT_PRESIS < 159 AND TMT.TMT_PREDIS < 99 THEN 'HIPERTENSÃO LEVE' "
			cQuery += " WHEN TMT.TMT_PRESIS < 179 AND TMT.TMT_PREDIS < 109 THEN 'HIPERTENSÃO MODERADA' "
			cQuery += " WHEN TMT.TMT_PRESIS < 200 AND TMT.TMT_PREDIS >= 110 THEN 'HIPERTENSÃO SEVERA' "
			cQuery += " WHEN TMT.TMT_PRESIS <= 200 THEN 'HIPERTENSÃO MUITO SEVERA' "
			cQuery += " ELSE 'VALORES INCOERENTES' "
			cQuery += " END AS PRESART"
			cQuery += " FROM " + RetSQLName( "TMT" ) + " TMT "
			cQuery += " JOIN " + RetSQLName( "TM0" ) + " TM0 "
			cQuery += " ON TM0.TM0_NUMFIC = TMT.TMT_NUMFIC AND TM0.TM0_FILIAL = " + ValToSQL( xFilial( "TM0" ) ) + " AND TM0.D_E_L_E_T_ <> '*' "
			cQuery += " JOIN " + RetSQLName( "SRA" ) + " SRA ON SRA.RA_MAT = TM0.TM0_MAT AND SRA.RA_FILIAL = " + ValToSQL( xFilial( "SRA" ) ) + " AND SRA.D_E_L_E_T_ <> '*' "
			cQuery += " WHERE TMT.TMT_DTATEN <= " + ValToSQL( dDtFim ) + " AND TMT.TMT_DTATEN >= " + ValToSQL( dDtIni ) + " AND TMT.D_E_L_E_T_ <> '*' "
			cQuery += " AND TMT.TMT_FILIAL = " + ValToSQL( xFilial( "TMT" ) )
			cQuery += " AND "+cSubString+"(TMT.TMT_DTATEN,1,6) = " + ValToSQL( cFilPer )
			cQuery += " ) TBL "
			If ValType( cFilPdr ) == "C" .And. !Empty( cFilPdr )
				cQuery += "WHERE PRESART = " + ValToSQL( cFilPdr ) + " "
			EndIf
			cQuery += " GROUP BY SEXO "
		EndIf
	EndIf

Return cQuery

//---------------------------------------------------------------------
/*/{Protheus.doc} fAtuGeral
Atualiza todas as informações da Consulta

@return
@param lConsulta Logico Indica se esta consultando ou remontando para uma nova consulta
@param oDtIni Objeto Objeto da Data Início
@param oDtFim Objeto Objeto da Data Fim
@param oFilIni Objeto Objeto do Valor Início
@param oFilFim Objeto Objeto do Valor Fim
@param oCmbTip Objeto Objeto do Combo de Tipo de Visualização
@param oCmbVis Objeto Objeto do Combo de Agrupador de Visualização
@param oCmbPer Objeto Objeto do Combo de Período de Visualização
@param oPnlBot Objeto Objeto do Painel Inferior (Listagens, Gráfico e Faixa Etária)
@param aCpsList Array Array contendo a lista de campos
@param cCmbTip Caracter Valor do Combo de Tipo de Visualização
@param cCmbVis Caracter Valor do Combo de Agrupador de Visualização
@param cCmbPer Caracter Valor do Combo de Período de Visualização
@param oPnlList1 Objeto Objeto que define o Painel da Primeira listagem
@param oPnlList2 Objeto Objeto que define o Painel da Segunda listagem
@param aCpsSX3 Array Array contendo os campos de SX3
@param aTabPrinc Array Array contendo os campos da tabela principais
@param cTRBPrinc Array Valor do TRB Principal
@param cTRBSec Caracter Valor do TRB Secundário
@param dDtIni Data Valor da Data Início
@param dDtFim Data Valor da Data Fim
@param cFilIni Caracter Valor do Filtro Inicial
@param cFilFim Caracter Valor do Filtro Final
@param aItensTip Array Array contendo as opções do combo Tipo
@param aItensVis Array Array contendo as opções do combo Visualizar
@param aItensPer Array Array contendo as opções do combo Período
@param aDefVirtu Array Array contendo os campos de definição virtual
@param oBtnVisual Objeto Objeto do Botão de Visualizar
@param oBtnAvNiv Objeto  Objeto do Botão de Avançar Nível
@param oBtnResult Objeto Objeto do Botão de Resultado
@param oPaiRight Objeto Indica o painel Pai
@param oObjRight Objeto Indica a variavel do objeto selecionado
@param nObjRight Numerico Indica o objeto selecionado
@param lFirstObj Lógico Indica se é a primeira montagem
@param oSayHrs1 Objeto da Quantidade de Horas da Primeira Listagem
@param oSayHrs2 Objeto da Quantidade de Horas da Segunda Listagem
@param oSayQHrs1 Objeto do Valor da Quantidade de Horas da Primeira Listagem
@param oSayQHrs2 Objeto do Valor da  Quantidade de Horas da Segunda Listagem

@sample
fAtuGeral( .T. , oObj , oObj , oObj , oObj , oObj , oObj , oObj , oObj ,  {} , '1' , '1' , '1' , oObj , oObj , {} , {} , 'SGC000005' , 'SGC000005' , '01/01/2000' , '31/12/2020' , '' , 'ZZZ' , {} , {} , {} , {} , oObj , oObj )

@author Jackson Machado
@since 09/07/2014
/*/
//---------------------------------------------------------------------
Static Function fAtuGeral( lConsulta , oDtIni , oDtFim , oFilIni , oFilFim , oCmbTip , oCmbVis , oCmbPer , oPnlBot , aCpsList , cCmbTip , cCmbVis , cCmbPer , oPnlList1 , oPnlList2 , aCpsSX3 , aTabPrinc , cTRBPrinc , cTRBSec , dDtIni , dDtFim , cFilIni , cFilFim , aItensTip , aItensVis , aItensPer , aDefVirtu , lChange , lDblClick , oBtnVisual , oBtnAvNiv , oBtnResult , oPaiRight , oObjRight , nObjRight , lFirstObj , oSayHrs1 , oSayHrs2 , oSayQHrs1 , oSayQHrs2)

	Local cAliTot
	Local cAliAbs
	Local cAliAci
	Local cAliHrs
	Local cQryTot := ""
	Local cQryAbs := ""
	Local cQryAci := ""
	Local cQryHrs := ""
	Local lMensal := cCmbPer == STR0023 //"Mensal"
	Local lTipMai := cCmbTip == STR0001 .Or. cCmbTip == STR0004  //"Absenteísmo"###"Exames"
	Local lValNiv := .T.
	Local lGeraAfa:= Alltrim( SuperGetMV( "MV_NGMDTAF" , .F. , "N" ) ) == "S"
	Local lRet    := .T.

	Default lChange := .F.
	Default lDblClick := .F.
	Default nObjRight := 0
	Default lFirstObj := .F.

	If lConsulta
		/*If lTipMai
			nNivLim := 3 - If( lMensal , 1 , 0 )
		Else*/
			nNivLim := 2 - If( lMensal , 1 , 0 )
		//EndIf
	EndIf

	If lDblClick .And. nNivBrw > nNivLim

		ShowHelpDlg( 	STR0099 , ; //"Atenção"
						{ STR0100 } , 1 , ; //"Opção não disponível."
						{ STR0101 , STR0102 } , 2 ) //"Para acessar nível inferiores deve-se estar em um nível superior."###"Nível atual já é o último disponível."
		lValNiv := .F.
	EndIf

	If !Empty( dDtIni ) .And. !Empty( dDtFim ) .And. ( !Empty( cFilFim ) .Or. ( cCmbVis == STR0011 .And. cCmbTip == STR0001 ) )//"Motivo"##"Absenteísmo"
		If lValNiv
			If lConsulta
				oDtIni:Disable()
				oDtFim:Disable()
				oFilIni:Disable()
				oFilFim:Disable()
				oCmbTip:Disable()
				oCmbVis:Disable()
				oCmbPer:Disable()
				oPnlBot:Enable()

				If !lChange
					//oListPrinc:DeActivate( .T. )
					oListPrinc := fMontaList( 1 , 1 , aCpsList , cCmbTip , cCmbVis , cCmbPer , oPnlList1 , aCpsSX3 , aTabPrinc , cTRBPrinc , dDtIni , dDtFim , cFilIni , cFilFim , aItensTip , aItensVis , aItensPer , If( lDblClick , cTRBPrinc , ) , aDefVirtu , lDblClick , If( lDblClick , .F. , .T. ) )
					If nObjRight == 2 .And. oPaiRight:lVisible
						Processa( { | lEnd | fMontaGraph( oPaiRight , @oObjRight , lFirstObj , aCpsList , cTRBPrinc , cCmbVis , aCpsSX3 , , aDefVirtu ) } )//Montagem do grafico.
					EndIf
				EndIf
				//oListSecun:DeActivate( .T. )
				oListSecun := fMontaList( 2 , If( lMensal , 2 , 1 ) , aCpsList , cCmbTip , cCmbVis , cCmbPer , oPnlList2 , aCpsSX3 , aTabPrinc , cTRBSec , dDtIni , dDtFim , cFilIni , cFilFim , aItensTip , aItensVis , aItensPer , cTRBPrinc , aDefVirtu , lDblClick , , lChange )
				If Type("oListSecun") == "O"//Caso o markbrowse exista, atualiza ele
					oListSecun:Refresh(.T.)
				Endif
				If !lChange
					oListPrinc:SetFocus()
					dbSelectArea( cTRBPrinc )
					dbGoTop()
				EndIf

				If nNivBrw >= nNivLim
					oBtnAvNiv:Hide()
					oBtnVisual:Show()
					If cCmbTip == STR0004  //"Exames"
						oBtnResult:Show()
					EndIf
				Else
					oBtnAvNiv:Show()
					oBtnVisual:Hide()
					oBtnResult:Hide()
				EndIf

				If !lDblClick .And. !lChange .And. MV_PAR02 == 1
					//Atualiza indicadores gerais
					aEval( aIndiceGer,  {| x,y | aFill( aIndiceGer[y], 0)  } )

					cAliTot := GetNextAlias()
					cAliAbs := GetNextAlias()
					cAliAci := GetNextAlias()
					cAliHrs := GetNextAlias()

					nPosTip := aScan( aItensTip , { | x | x == cCmbTip } )
					nPosVis := aScan( aItensVis , { | x | x == cCmbVis } )
					nPosPer := aScan( aItensPer , { | x | x == cCmbPer } )

					cQryTot := ReturnQuery( nPosTip , nPosVis , nPosPer , dDtIni , dDtFim , cFilIni , cFilFim , , , , , 6 )
					MPSysOpenQuery( cQryTot , cAliTot )
					aIndiceGer[_nPosIndTot][_nRowOne] := ( cAliTot )->TOTAL

					cQryHrs := ReturnQuery( nPosTip , nPosVis , nPosPer , dDtIni , dDtFim , cFilIni , cFilFim , , , , , 7 )
					MPSysOpenQuery( cQryHrs , cAliHrs )
					nTotHrs := ( cAliHrs )->TOTHRS

					cQryAbs := ReturnQuery( nPosTip , nPosVis , nPosPer , dDtIni , dDtFim , cFilIni , cFilFim , , , , , 8 )
					MPSysOpenQuery( cQryAbs , cAliAbs )
					aIndiceGer[_nPosIndAbs][_nRowOne] := ( cAliAbs )->DURACAO
					aIndiceGer[_nPosIndAbs][_nRowTwo] := ( ( cAliAbs )->DURACAO * 100 ) / nTotHrs

					If lGeraAfa
						cQryAci := ReturnQuery( nPosTip , nPosVis , nPosPer , dDtIni , dDtFim , cFilIni , cFilFim , , , , , 9 )
						MPSysOpenQuery( cQryAci , cAliAci )
						aIndiceGer[_nPosIndAci][_nRowOne] := ( cAliAci )->DURACAO
						aIndiceGer[_nPosIndAci][_nRowTwo] := ( ( cAliAci )->DURACAO * 100 ) / nTotHrs
					Else
						aIndiceGer[_nPosIndAci][_nRowOne] := 0
						aIndiceGer[_nPosIndAci][_nRowTwo] := 0
					EndIf

					(cAliTot)->(dbCloseArea())
					(cAliAbs)->(dbCloseArea())
					If lGeraAfa
						(cAliAci)->(dbCloseArea())
					EndIf
					(cAliHrs)->(dbCloseArea())

				EndIf

				If (cTRBPrinc)->(Eof())
					ShowHelpDlg( 	"NAODADOS" , ;
									{ STR0134 } , 1 , ;//"Não há dados para exibição da consulta."
									{ STR0135 } , 1 )//"Favor informar uma nova parametragem e consultar novamente."
					//Zera a Consulta
					fAtuGeral( .F. , oDtIni , oDtFim , oFilIni , oFilFim , oCmbTip , oCmbVis , oCmbPer , oPnlBot , aCpsList , cCmbTip , cCmbVis , cCmbPer , oPnlList1 , oPnlList2 , aCpsSX3 , aTabPrinc , cTRBPrinc , cTRBSec , dDtIni , dDtFim , cFilIni , cFilFim , aItensTip , aItensVis , aItensPer , aDefVirtu , lChange , lDblClick , oBtnVisual , oBtnAvNiv , oBtnResult , oPaiRight , oObjRight , nObjRight , lFirstObj , oSayHrs1 , oSayHrs2 , oSayQHrs1 , oSayQHrs2 )
					lRet := .F.
				EndIf
			Else
				//Zera os totalizadores
				nTotFun	:= 0
				nTotOco	:= 0
				nQtdPri	:= 0
				nQtdSec	:= 0
				nQtdHPri:= 0
				nQtdHSec:= 0
				nQtdMPri:= 0
				nQtdMSec:= 0
				nHrsPri	:= 0
				nHrsSec	:= 0
				aEval( aFaixaGeral, {| x,y | aFill( aFaixaGeral[y], 0)  } )
	   			aEval( aIndiceGer,  {| x,y | aFill( aIndiceGer[y], 0)  } )
	   			aEval( aSexoGeral, {| x,y | aFill( aSexoGeral[y], 0)  } )

	   			//Retorna Descrições
	   			cDescAna:= STR0001 //"Absenteísmo"
	   			cDescFai:= ""
				nNivBrw	:= 1

				cCmbTip	:= STR0001 //"Absenteísmo"
				cCmbVis	:= STR0002 //"Centro de Custo"
				cCmbPer	:= STR0003 //"Anual"

				dDtIni		:= STOD( Space( 8 ) )
				dDtFim		:= STOD( Space( 8 ) )
				cFilIni	:= Space( Len( CTT->CTT_CUSTO ) )
				cFilFim	:= Replicate( "Z" , Len( CTT->CTT_CUSTO ) )

				oFilIni:cF3 := "CTT"
				oFilFim:cF3 := "CTT"

				oCmbVis:SetItems( aItensVis )
				oCmbVis:Select( 1 )
				oCmbVis:Refresh()

				If MV_PAR01 == 1
					oSayHrs1:Show()
					oSayHrs2:Show()
					oSayQHrs1:Show()
					oSayQHrs2:Show()
				EndIf

				oDtIni:Enable()
				oDtFim:Enable()
				oFilIni:Enable()
				oFilFim:Enable()
				oCmbTip:Enable()
				oCmbVis:Enable()
				oCmbPer:Enable()
				oBtnVisual:Hide()
				oBtnResult:Hide()
				oBtnAvNiv:Show()
				oPnlBot:Disable()

				oListPrinc:DeActivate( .T. )
				oListPrinc := fMontaList( 1 , 0 , aCpsList , cCmbTip , cCmbVis , cCmbPer , oPnlList1 , aCpsSX3 , aTabPrinc , cTRBPrinc , dDtIni , dDtFim , cFilIni , cFilFim , aItensTip , aItensVis , aItensPer , , aDefVirtu , lDblClick )
				oListSecun:DeActivate( .T. )
				oListSecun := fMontaList( 2 , 0 , aCpsList , cCmbTip , cCmbVis , cCmbPer , oPnlList2 , aCpsSX3 , aTabPrinc , cTRBSec , dDtIni , dDtFim , cFilIni , cFilFim , aItensTip , aItensVis , aItensPer , cTRBPrinc , aDefVirtu , lDblClick )
				fMontaGraph( oPaiRight , @oObjRight , .T. )//Montagem do grafico.
			EndIf
		EndIf
	Else
		ShowHelpDlg( 	"CMPNOINF" , ;
						{ STR0136 } , 1 , ;//"Campos de Filtro não informados."
						{ STR0137 } , 1 )//"Favor informar todos os campos de Filtro da consulta."
		lRet := .F.
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fRetornaNivel
Realiza o retorno do Nível

@return

@param aCpsList Array Array contendo a lista de campos
@param cCmbTip Caracter Valor do Combo de Tipo de Visualização
@param cCmbVis Caracter Valor do Combo de Agrupador de Visualização
@param cCmbPer Caracter Valor do Combo de Período de Visualização
@param oPnlList1 Objeto Objeto que define o Painel da Primeira listagem
@param oPnlList2 Objeto Objeto que define o Painel da Segunda listagem
@param aCpsSX3 Array Array contendo os campos de SX3
@param aTabPrinc Array Array contendo os campos da tabela principais
@param cTRBPrinc Array Valor do TRB Principal
@param cTRBSec Caracter Valor do TRB Secundário
@param dDtIni Data Valor da Data Início
@param dDtFim Data Valor da Data Fim
@param cFilIni Caracter Valor do Filtro Inicial
@param cFilFim Caracter Valor do Filtro Final
@param aItensTip Array Array contendo as opções do combo Tipo
@param aItensVis Array Array contendo as opções do combo Visualizar
@param aItensPer Array Array contendo as opções do combo Período
@param aDefVirtu Array Array contendo os campos de definição virtual
@param oBtnVisual Objeto Objeto do Botão de Visualizar
@param oBtnAvNiv Objeto  Objeto do Botão de Avançar Nível
@param oBtnResult Objeto Objeto do Botão de Resultado

@sample
fRetornaNivel( {} , '1' , '1' , '1' , oObj , oObj , {} , {} , 'SGC000005' , 'SGC000005' , '01/01/2000' , '31/12/2020' , '' , 'ZZZ' , {} , {} , {} , {} , oObj , oObj )

@author Jackson Machado
@since 09/07/2014
/*/
//---------------------------------------------------------------------
Static Function fRetornaNivel( aCpsList , cCmbTip , cCmbVis , cCmbPer , oPnlList1 , oPnlList2 , aCpsSX3 , aTabPrinc , cTRBPrinc , cTRBSec , dDtIni , dDtFim , cFilIni , cFilFim , aItensTip , aItensVis , aItensPer , aDefVirtu , oBtnVisual , oBtnAvNiv , oBtnResult )

	Local lMensal := cCmbPer == STR0023//Define se a pesquisa é por mensal //"Mensal"
	Local lValNiv := .T.

	//Valida se está no primeiro nível e se é mensal, caso seja, não deixa 'retornar'
	If nNivBrw == 1 .Or. lMensal
		ShowHelpDlg( 	STR0099 , ; //"Atenção"
						{ STR0100 } , 1 , ; //"Opção não disponível."
						{ STR0103 , STR0104 } , 2 ) //"Para retorno deve-se estar em um nível inferior."###"Nível atual já é o primeiro."
		lValNiv := .F.
	EndIf

	//Caso validação correta, retorna nível
	If lValNiv
		//Decrementar contador de nível
		nNivBrw--

		//Exibe botão de avanço de nível e omite o de visualização
		oBtnAvNiv:Show()
		oBtnVisual:Hide()
		oBtnResult:Hide()

		//Refaz os Browses de Visualização
		oListPrinc:DeActivate( .T. )
		oListPrinc := fMontaList( 1 , 1 , aCpsList , cCmbTip , cCmbVis , cCmbPer , oPnlList1 , aCpsSX3 , aTabPrinc , cTRBPrinc , dDtIni , dDtFim , cFilIni , cFilFim , aItensTip , aItensVis , aItensPer , , aDefVirtu )
		oListSecun:DeActivate( .T. )
		oListSecun := fMontaList( 2 , 1 , aCpsList , cCmbTip , cCmbVis , cCmbPer , oPnlList2 , aCpsSX3 , aTabPrinc , cTRBSec , dDtIni , dDtFim , cFilIni , cFilFim , aItensTip , aItensVis , aItensPer , cTRBPrinc , aDefVirtu )
	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fValid
Função de validação dos campos de pesquisa

@return lRet Logico Retorna verdadeiro caso campo esteja correto

@param nTipVld Numerico Indica qual campo esta sendo validado: 1 - De Data; 2 - Até Data; 3 - De Valor; 4 - Até Valor
@param xValueIni Indefinido Indica o valor do campo 'De' correspondente
@param xValueFim Indefinido Indica o valor do campo 'Até' correspondente
@param aTabPrinc Array Array contendo os campos da tabela principais
@param cCmbTip Caracter Indica o combo selecionado

@sample
fFieldCol( 1 , "" , "ZZZZZ" , {} , "Exames" )

@author Jackson Machado
@since 09/07/2014
/*/
//---------------------------------------------------------------------
Static Function fValid( nTipVld , xValueIni , xValueFim , aTabPrinc , cCmbTip )

	Local nPosTab		:= aScan( aTabPrinc , { | x | x[ _nPosDesFol ] == cCmbTip } )
	Local cTabela		:= If( nPosTab > 0 , aTabPrinc[ nPosTab , _nPosTabPri ] , "" )
	Local cCmpMaior	:= ""
	Local cCmpMenor	:= ""
	Local cCompar		:= ""
	Local cCmp			:= ""
	Local cCmp2		:= ""
	Local lRet			:= .T.

	//Define o campo que está verificando bem como a mensagem a ser exibida
	If nTipVld == 1
		cCmp := STR0105 //"'De Data'"
		cCmp2 := STR0106 //"'Até Data'"
		cCompar := STR0107 //"menor"
	ElseIf nTipVld == 2
		cCmp := STR0106 //"'Até Data'"
		cCmp2 := STR0105 //"'De Data'"
		cCompar := STR0108 //"maior"
	ElseIf nTipVld == 3
		cCmp := STR0109 //"'De'"
		cCmp2 := STR0110 //"'Até'"
		cCompar := STR0107 //"menor"
	ElseIf nTipVld == 4
		cCmp := STR0110 //"'Até'"
		cCmp2 := STR0109 //"'De'"
		cCompar := STR0108 //"maior"
	EndIf

	//Caso seja validação de Data, joga os valores de Maior e Menor com o nome 'Data', caso não, apenas coloca o Prefixo
	If nTipVld == 1 .Or. nTipVld == 2
		cCmpMaior	:= STR0111 //"Até Data"
		cCmpMenor	:= STR0112 	 //"De Data"
	Else
		cCmpMaior	:= STR0055 //"Até"
		cCmpMenor	:= STR0113 //"De"
	EndIf

	//Valida início maior que fim apenas se os valores estiverem preenchidos
	If !Empty( xValueIni ) .And. !Empty( xValueFim )
		If xValueIni > xValueFim
			lRet := .F.
		EndIf
	EndIf

	If !lRet
		ShowHelpDlg( STR0099 , ; //"Atenção"
						{ STR0114 + cCmpMenor + STR0115+ cCmpMaior +"'." } , 1 , ; //"Campo '"###"' maior que campo '"
						{ STR0116 + cCmp + " " + cCompar + STR0117 + cCmp2 } , 1 ) //"Favor informar um valor no campo "###" que "
	Else
		//Faz a tratativa de SX5
		If nTipVld == 3 .Or. nTipVld == 4
			If cTabela == "30"
				cTabela := "SX5"
				xValueIni := "30"+xValueIni
				xValueFim := "30"+xValueFim
			EndIf
		EndIf
		//Faz as validações de existência apenas se validação de maior/menor estiver correta
		If nTipVld == 3
			If !Empty( xValueIni ) .And. !ExistCpo( cTabela , xValueIni )//Valida existência do valor início desde que preenchido
				lRet := .F.
			EndIf
		ElseIf nTipVld == 4
			If xValueFim <> Replicate( "Z" , Len( xValueFim ) ) .And. !ExistCpo( cTabela , xValueFim ) //Valida existência do valor fim desde que diferente de ZZZZ
				lRet := .F.
			EndIf
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT500MPER
Trata correto retorno do Período

@return cRet Caracter Retorna o valor correto do período

@param cPeriodo Caracter Retorno do valor da query

@sample
fFieldCol( "201406" )

@author Jackson Machado
@since 09/07/2014
/*/
//---------------------------------------------------------------------
Function MDT500MPER( cPeriodo )

	Local cRet := AllTrim( cPeriodo )

	If Len( cRet ) > 4
		cRet := SubStr( cPeriodo , 5 , 2  ) + "/" + SubStr( cPeriodo , 1 , 4 )
	EndIf

Return cRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fAtuFaixa
Função de preenchimento dos valores da Faixa Etaria. Conforme Filtro

@return Nil

@param fAtuFaixa Array Indica qual array será atualizado.


@sample
fAtuFaixa()

@author Guilherme Benkendorf
@since 15/07/2014
/*/
//---------------------------------------------------------------------
Static Function fAtuFaixa( cAlsFai , cAlsTot , cAlsOco , cAlsSex )

    //Zera as os arrays de valores
	aEval( aFaixaGeral, {| x,y | aFill( aFaixaGeral[y], 0)  } )
	aEval( aSexoGeral, {| x,y | aFill( aSexoGeral[y], 0)  } )

	If Select( cAlsFai ) > 0
		dbSelectArea(cAlsFai)
		While (cAlsFai)->( !Eof() )
			nIdade := (cAlsFai)->(IDADE)
			If Alltrim( (cAlsFai)->(SEXO) ) == "M"
				//----------------
				//Somatoria Homem
				//----------------
				aFaixaGeral[_nPosFaiHom][nIdade] += (cAlsFai)->(QTDFUN)
				//Ocorrencia Homem
				aFaixaGeral[_nPosFaiHCo][nIdade] += (cAlsFai)->(OCORRENCIA)

				aFaixaGeral[_nPosFaiPH][nIdade] += (cAlsFai)->(PERCEN)

				//Totalizador Funcionarios
				aFaixaGeral[_nPosFaiTot][_nRowOne]   += (cAlsFai)->(QTDFUN)
				//Totalizador Ocorrencias
				aFaixaGeral[_nPosFaiTot][_nRowTwo]   += (cAlsFai)->(OCORRENCIA)

				aFaixaGeral[_nPosFaiTot][_nRowThree] += (cAlsFai)->(PERCEN)

			ElseIf Alltrim( (cAlsFai)->(SEXO) ) == "F"
				//----------------
				//Somatoria Mulher
				//----------------
				aFaixaGeral[_nPosFaiMul][nIdade] += (cAlsFai)->(QTDFUN)

				aFaixaGeral[_nPosFaiMOc][nIdade] += (cAlsFai)->(OCORRENCIA)

				aFaixaGeral[_nPosFaiPM][nIdade] += (cAlsFai)->(PERCEN)

				//Totalizador
				aFaixaGeral[_nPosFaiTot][_nRowFour] += (cAlsFai)->(QTDFUN)
				//Totalizador
				aFaixaGeral[_nPosFaiTot][_nRowFive] += (cAlsFai)->(OCORRENCIA)
				//Totalizador
				aFaixaGeral[_nPosFaiTot][_nRowSix]  += (cAlsFai)->(PERCEN)
			EndIf

			(cAlsFai)->( dbSkip() )

		End Do

	EndIf

	//
	If Select( cAlsSex ) > 0
		dbSelectArea(cAlsSex)
		While (cAlsSex)->( !Eof() )
			If Alltrim( (cAlsSex)->(SEXO) ) == "M"
				aSexoGeral[_nRowOne][_nPosHSex] := Round( (cAlsSex)->(PERCEN) , 2 )
			ElseIf Alltrim( (cAlsSex)->(SEXO) ) == "F"
				aSexoGeral[_nRowOne][_nPosMSex] := Round( (cAlsSex)->(PERCEN) , 2 )
			EndIf
			(cAlsSex)->( dbSkip() )
		End Do
	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fMontaGraph
Monta o Gráfico

@param oObjPai		- Objeto onde sobre o qual é criado o gráfico

@sample
fMontaGraph(oPnlRBot)

@author Bruno Lobo de Souza
@since 09/07/2014
/*/
//---------------------------------------------------------------------
Static Function fMontaGraph( oObjPai , oGraphic , lFirst , aCpsList , cTRB , cCmbVis , aCpsSX3 , cPeriod , aDefVirtu )

	Local nCnt := 0
	Local nCps
	Local nPosTit
	Local nPosSer, nPosPer
	Local nPosCmp
	Local nSerieX //Serie inicial
	Local cTitulo := ""
	Local cCmpCod
	Local cCmpDes
	Local lGrupos := .F.
	Local lAdd    := .F.
	Local aCpsDef
	Local aStrSX3
	Local aSeries := {}
	Local aPeriod := {}
	Local nCont := 0

	//Array de cores a serem imputadas no gráfico
	Local aClrGraph   := { CLR_HGREEN , CLR_HBLUE , CLR_HRED , CLR_YELLOW , CLR_BROWN , CLR_CYAN ,;
								CLR_MAGENTA , CLR_GRAY , CLR_BLUE , CLR_GREEN , CLR_RED , CLR_HGRAY ,;
								CLR_HCYAN , CLR_HMAGENTA , CLR_BLACK , RGB(178,241,18) , RGB(131,199,154) ,;
								RGB(111,156,210) , RGB(236,99,120) , RGB(255,255,162) , RGB(19,88,88) ,;
								RGB(60,9,60) , RGB(141,125,194) , RGB(255,93,0) , RGB(255,196,0) }


	//Salva a area atual
	Local aArea
	Local aAreaTRB

	Default cPeriod := ""

	If MV_PAR02 <> 1
		lFirst := .T.
	Endif

	// Destroi e recria o objeto de grafico
	If ValType( oGraphic ) == "O"
		FreeObj(oGraphic)
	EndIf

    If !lFirst
    	aArea := GetArea()
		aAreaTRB := ( cTRB )->( GetArea() )

	    nPosTit := aScan( aCpsList , { | x | x[ 1 ] == cCmbVis } )
	    nPosCmp := aScan( aCpsSX3 , { | x | x[ 1 ] == cCmbVis } )
	    aCpsDef := aCpsList[ nPosTit , 2 ]//Salva os campos pré-definidos
	    lGrupos := Len( aCpsDef ) > 2
	    If lGrupos
    	    aStrSX3 := aCpsSX3[ nPosCmp , 2 ]
		    For nCps := 3 To 4//Percorre a posição de código e descrição
		    	If Len( aCpsDef ) >= nCps
					//Pesquisa se é um campo de SX3
					If ( nPosSX3 := aScan( aStrSX3 , { | x | x[ 1 ] == aCpsDef[ nCps ] } ) ) > 0
		                If nCps == 3
		                	cCmpCod := aStrSX3[ nPosSX3 , 2 ]
		                Else
		                	cCmpDes := aStrSX3[ nPosSX3 , 2 ]
		                EndIf
					ElseIf ( nPosDef := aScan( aDefVirtu , { | x | x[ _nPosTitle ] == aCpsDef[ nCps ] } ) ) > 0//Pesquisa se é um campo pré-definido
						If nCps == 3
		                	cCmpCod := aDefVirtu[ nPosDef , _nPosCampo ]
		                Else
		                	cCmpDes := aDefVirtu[ nPosDef , _nPosCampo ]
		                EndIf
		    		EndIf
		    	Else
		    		cCmpDes := ""
				EndIf
			Next nCps
			cTitulo := cCmbVis//( cTRB )->&( cCmpCod ) + " - " + If( !Empty( cCmpDes ) , ( cTRB )->&( cCmpDes ) , cCmpDes )
		EndIf
	EndIf
    // Cria o gráfico
    oGraphic := TMSGraphic():New( 0,0,oObjPai,,,RGB(239,239,239),1000,1000)
    oGraphic:SetTitle( cTitulo ,, CLR_BLACK , A_CENTER , .F. )
    oGraphic:SetMargins(2,6,6,6)
    oGraphic:SetLegenProp(4, CLR_LIGHTGRAY, 1, .T.)
    oGraphic:Align := CONTROL_ALIGN_ALLCLIENT

    // Itens do Gráfico
    If !lFirst
		If lGrupos
			dbSelectArea( cTRB )
			dbGoTop()
			While ( cTRB )->( !Eof() )
				If (cTRB)->(LASTREC()) > 30
					aAdd( aSeries , { ( cTRB )->&( cCmpCod ) , ( cTRB )->PERIODO  } )
				Else
				If aScan( aSeries , { | x | x[ 1 ] == ( cTRB )->&( cCmpCod ) } ) == 0
					nCnt++
					cColor := aClrGraph[ fRetClrGrp( nCnt ) ]
					nSerie := oGraphic:CreateSerie( 4 , ( cTRB )->&( cCmpCod ) )
					aAdd( aSeries , { ( cTRB )->&( cCmpCod ) , nSerie , cColor } )
				EndIf
				EndIf

				If aScan( aPeriod , { | x | x == ( cTRB )->PERIODO } ) == 0
					aAdd( aPeriod , ( cTRB )->PERIODO )
				EndIf
				( cTRB )->( dbSkip() )
			End
			aSort( aSeries , , , { | x , y | x[ 2 ] < y[ 2 ] } )
			aSort( aPeriod , , , { | x , y | x < y } )

			If cPeriod <> ""
				aPeriod := { cPeriod }
			EndIf
			If (cTRB)->(LASTREC()) > 30 //Caso possua mais de 30 Barras Gráficas.
				For nPosPer := 1 To Len( aPeriod )
					For nPosSer := 1 To Len( aSeries )
						If aPeriod[ nPosPer ] == aSeries[ nPosSer , 2 ]
							nCont++
						EndIf
					Next nPosSer
					If nCont > 0
						cColor := aClrGraph[ fRetClrGrp( nPosPer ) ]
						nSerie := oGraphic:CreateSerie( 4 , aPeriod[ nPosPer ],,.T. )
						oGraphic:Add( nPosPer , nCont ,  , cColor )
					EndIf
					nCont := 0
				Next nPosPer
			Else	//Caso possua menos de 30 registros.
				For nPosPer := 1 To Len( aPeriod )
					For nPosSer := 1 To Len( aSeries )
						lAdd := .F.
						nSerie := aSeries[ nPosSer , 2 ]
						cColor := aSeries[ nPosSer , 3 ]
						dbSelectArea( cTRB )
						dbGoTop()
						While ( cTRB )->( !Eof() )
							If aSeries[ nPosSer , 1 ] == ( cTRB )->&( cCmpCod ) .And. aPeriod[ nPosPer ] == ( cTRB )->PERIODO
								oGraphic:Add( nSerie , ( cTRB )->OCORRENCIA , MDT500MPER( aPeriod[ nPosPer ] ) , cColor )
								lAdd := .T.
								Exit
							EndIf
							( cTRB )->( dbSkip() )
						End
						If !lAdd
							oGraphic:Add( nSerie , 0 , aPeriod[ nPosPer ] , cColor )
						EndIf
					Next nPosSer
				Next nPosPer
			EndIf
		Else
			dbSelectArea( cTRB )
			dbGoTop()
			While ( cTRB )->( !Eof() )
				nCnt++
				cColor := aClrGraph[ fRetClrGrp( nCnt ) ]
				nSerie := oGraphic:CreateSerie( 4 , MDT500MPER( ( cTRB )->PERIODO ) )
				oGraphic:Add( nSerie , ( cTRB )->OCORRENCIA , '' , cColor )
				( cTRB )->( dbSkip() )
			End
		EndIf
	Else
		nSerieX := oGraphic:CreateSerie( 4 , '' )
		oGraphic:Add( nSerieX , 0 , '' ,CLR_BLACK  )
		oGraphic:lAxisVisib := .T.
		oGraphic:l3D := .F.
	EndIf

	If !lFirst
		//Retorna a área
		RestArea( aAreaTRB )
		RestArea( aArea )
	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fImpGraphic
Imprime grafico pelo TMSPrinter

@Param oGraphic Objeto, objeto do TMSGraphic
@Param cTitle Caracter, Titulo do grafico

@return .T./.F.

@sample
fImpGraphic(oGraphic,cTitle)

@author Bruno L. Souza
@since 15/07/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fImpGraphic(oGraphic,cTitle,lFor,cTrbPrinc,aCpsList, cCmbVis , aCpsSX3, oPnlPai , aDefVirtu )

	//Controle de Períodos
	Local nCntPer := 1
	Local aPeriodos := {}

	//Montagem das Imagens
	Local nImg
	Local cRaizServer := If(issrvunix(), "/", "\")
	Local cDirTemp    := GetTempPath()
	Local cNameImg
	Local aImgs			:= {}
	Local oPnlImp, oGphTmp

	//Salva a area atual
	Local aArea := GetArea()
	Local aAreaTRB

	Default lFor := .F.

	If lFor
		aAreaTRB := ( cTRBPrinc )->( GetArea() )

		//Levanta os Períodos Necessários
		dbSelectArea( cTrbPrinc )
		dbGoTop()
		While ( cTrbPrinc )->( !Eof() )
			 If aScan( aPeriodos , { | x | x == ( cTrbPrinc )->PERIODO } ) == 0
			 	aAdd( aPeriodos , ( cTrbPrinc )->PERIODO )
			 EndIf
			 ( cTrbPrinc )->( dbSkip() )
		End

		ProcRegua( Len( aPeriodos ) )

		oPrint	:= TMSPrinter():New(cTitle)
		oPrint:Setup()
		oPrint:SetLandscape()

		//Cria um Painel para Receber o objeto do Grafico a ser impresso
		oPnlImp := TPanel():New( , , , oPnlPai , , , , , , , , .F. , .F. )
			oPnlImp:Align := CONTROL_ALIGN_ALLCLIENT
			oPnlImp:Show()
		For nCntPer := 1 To Len( aPeriodos )

			IncProc( STR0118 + aPeriodos[ nCntPer ] ) //"Imprimindo Período: "

			cNameImg := GetNextAlias() + ".BMP"

			aAdd( aImgs , cRaizServer + cNameImg )
			If nCntPer <> 1
				oPrint:StartPage()
			EndIf

			fMontaGraph( oPnlImp , @oGphTmp , .F. , aCpsList , cTrbPrinc , cCmbVis , aCpsSX3 , aPeriodos[ nCntPer ] , aDefVirtu )

			If oGphTmp:SaveToImage(cNameImg,cRaizServer,"BMP") .And. __CopyFile(cRaizServer + cNameImg, cDirTemp + cNameImg)
				oPrint:SayBitmap( 50, 25, cDirTemp+cNameImg,3050,2400)
			EndIf

			oPrint:EndPage()
		Next nCntPer
		oPrint:Preview()
		oPnlImp:Hide()
		For nImg := 1 To Len( aImgs )
			Erase( aImgs[ nImg ] )
		Next nImg
		//Retorna a área
		RestArea( aAreaTRB )
	Else

		cNameImg := GetNextAlias() + ".BMP"

		If oGraphic:SaveToImage(cNameImg,cRaizServer,"BMP") .And. __CopyFile(cRaizServer + cNameImg, cDirTemp + cNameImg)

			Ferase(cRaizServer + cNameImg)

			oPrint	:= TMSPrinter():New(cTitle)
			oPrint:Setup()
			oPrint:SetLandscape()
			oPrint:SayBitmap( 50, 25, cDirTemp+cNameImg,3050,2400)
			oPrint:Preview()
		Else
			MsgStop(STR0119,STR0099) //"Não foi possível copiar a imagem para o servidor."###"Atenção"
		EndIf
	EndIf

	//Retorna a área
	RestArea( aArea )

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fRetClrGrp
Retorna a cor do grafico

@Param  n Numérico

@return nClr - Numérico

@sample
fRetClrGrp(50)

@author Bruno L. Souza
@since 15/07/2014
/*/
//---------------------------------------------------------------------
Static Function fRetClrGrp(n)

	Local nClr := n

	If n > 25
		While nClr > 25
			nClr := nClr-25
		End
	Endif

Return nClr

//---------------------------------------------------------------------
/*/{Protheus.doc} fMaximize()
Maximiza o gráfico e separa por periodos

@param oObjPai		- Objeto onde sobre o qual é criado o gráfico

@sample
fMaximize()

@author Bruno Lobo de Souza
@since 16/07/2014
/*/
//---------------------------------------------------------------------
Static Function fMaximize( oWnd , oObj , aFldList , cTrbPrin , cBoxVis , aFldSx3 , aDefVirtu )

	Local aAreaTRB := ( cTrbPrin )->( GetArea() )

	//Controle de Períodos
	Local nPeriodo := 1
	Local aPeriodos := {}

	//Objetos
	Local oDlgMax
	Local oPnlAll
	Local oPnlGrph
	Local oPnlBot
	Local oBtnLeft
	Local oBtnRight

	//Variaveis de tamanho de tela
	Local lEBar		:= .T. // Indica se a janela de diálogo possuirá enchoicebar
	Local lMedProth	:= .F. // Indica se a janela deve respeitar as medidas padrões do Protheus (.T.) ou usar o máximo disponível (.F.)
	Local nAltMin		:= 430 // Altura mínima da janela
	Local aSize		:= MsAdvSize( lEBar , lMedProth , nAltMin )

	//Ações de Tela
	Local bOkMax		:= { | | oDlgMax:End() }
	Local bCancMax	:= { | | oDlgMax:End() }

	//Levanta os Períodos Necessários
	dbSelectArea( cTrbPrin )
	dbGoTop()
	While ( cTRBPrin )->( !Eof() )
		 If aScan( aPeriodos , { | x | x == ( cTRBPrin )->PERIODO } ) == 0
		 	aAdd( aPeriodos , ( cTRBPrin )->PERIODO )
		 EndIf
		 ( cTRBPrin )->( dbSkip() )
	End

	Define MsDialog oDlgMax Title OemToAnsi( "" ) From aSize[ 7 ] , 0 To aSize[ 6 ] , aSize[ 5 ] Of oMainWnd Pixel
		oPnlAll := TPanel():New(00,00,,oDlgMax,,,,,,1000,1000,.F.,.F.)
			oPnlAll:Align := CONTROL_ALIGN_ALLCLIENT

			oPnlBot := TPanel():New(00,00,,oPnlAll,,,,,,465,24,.F.,.F.)
				oPnlBot:Align := CONTROL_ALIGN_BOTTOM
			oPnlGrph := TPanel():New(00,00,,oPnlAll,,,,,,1000,1000,.F.,.F.)
				oPnlGrph:Align := CONTROL_ALIGN_ALLCLIENT

				//Botao de Retroceder
				oBtnLeft := TBtnBmp2():New( 01 , 01 , 40 , 26 , "left" ,,,, {|| If( fVerPeriodo( 1 , @nPeriodo , aPeriodos ) , fMontaGraph( oPnlGrph , @oObj , .F. , aFldList , cTrbPrin , cBoxVis , aFldSx3 , aPeriodos[ nPeriodo ] , aDefVirtu ) , .F. ) } , oPnlBot , OemToAnsi( STR0120 ) )  //"Retroceder"
				oBtnLeft:Align := CONTROL_ALIGN_LEFT

				//Botao de Avançar
				oBtnRight := TBtnBmp2():New( 01 , 01 , 40 , 26 , "right" ,,,, {|| If( fVerPeriodo( 2 , @nPeriodo , aPeriodos ) , fMontaGraph( oPnlGrph , @oObj , .F. , aFldList , cTrbPrin , cBoxVis , aFldSx3 , aPeriodos[ nPeriodo ] , aDefVirtu ) , .F. ) } , oPnlBot , OemToAnsi( STR0121 ) ) //"Avançar"
				oBtnRight:Align := CONTROL_ALIGN_LEFT

				//Zoom (+)
				oBtnZoomin := TBtnBmp2():New(01, 01, 40, 26, "PMSZOOMIN", , , , {|| oObj:ZoomIn(),oObj:Refresh()}, oPnlBot, OemToAnsi(STR0122+" (+)")) //"Zoom"
				oBtnZoomin:Align := CONTROL_ALIGN_LEFT

				//Zoom (-)
				oBtnZoomout := TBtnBmp2():New(01, 01, 40, 26, "PMSZOOMOUT", , , , {|| oObj:ZoomOut(),oObj:Refresh()}, oPnlBot, OemToAnsi(STR0122+" (-)")) //"Zoom"
				oBtnZoomout:Align := CONTROL_ALIGN_LEFT

				//Impressão
				oBtnImp := TBtnBmp2():New(01, 01, 40, 26, "PMSPRINT", , , , {|| fImpGraphic(oObj,STR0086)}, oPnlBot, OemToAnsi(STR0123)) //"Gráfico"###"Imprimir"
				oBtnImp:Align := CONTROL_ALIGN_LEFT

				fMontaGraph( oPnlGrph , @oObj , .F. , aFldList , cTrbPrin , cBoxVis , aFldSx3 , aPeriodos[ 1 ] , aDefVirtu )//Montagem do grafico.

	Activate MsDialog oDlgMax Centered On Init EnchoiceBar( oDlgMax , bOkMax , bCancMax )

	RestArea( aAreaTRB )

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fVerPeriodo()
Verifica o Periodos a serem apresentados no grafico

@param nExec Numérico, indica a ação executada 1 = retroceder e 2 = avançar
@param nCnt Numérico, indica o periodo corrente
@param aPeriodos Array, contém os periodos disponiveis

@sample
fVerPeriodo( 2 , nPeriodo , aPeriodos )

@author Bruno Lobo de Souza
@since 17/07/2014
/*/
//---------------------------------------------------------------------
Static Function fVerPeriodo( nExec , nCnt , aPeriodos )
	Local lRet := .T.

	If nExec == 1
		If nCnt == 1
		 	ShowHelpDlg( 	"MINGRAF" , ;
		 					{ STR0124 } , 1 , ; //"Ação não executada."
		 					{ STR0125 } , 1 )  //"Limite início de períodos atigindo, favor selecionar a opção de avanço."
		 	lRet := .F.
		Else
		 	nCnt--
		EndIf
	Else
		If nCnt == Len( aPeriodos )
			ShowHelpDlg( 	"MAXGRAF" , ;
		 					{ STR0124 } , 1 , ; //"Ação não executada."
		 					{ STR0126 } , 1 )  //"Limite final de períodos atigindo, favor selecionar a opção de retorno."
		 	lRet := .F.
		Else
		 	nCnt++
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fVldTela()
Validações para abertura da tela

@param aSize Array Vetor contendo as posições de tela

@sample
fVldTela( {} )

@author Jackson Machado
@since 17/07/2014
/*/
//---------------------------------------------------------------------
Static Function fVldTela( aSize )

	Local lRet := .F.

	If aSize[ 6 ] >= 500 .And. aSize[ 5 ] >= 1200
		lRet := .T.
	EndIf

	If lRet
		If Alltrim( SuperGetMV( "MV_MDTGPE" , .F. , "N" ) ) <> "S"
			ShowHelpDlg( 	"NOINTGPE" , ;
						{ STR0138 } , 1 , ; //"Integração com o Gestão de Pessoas não está ativa."
						{ STR0139 + STR0093 } , 2 ) //"Para correto funcionamento da rotina, faz-se necessário o módulo de Medicina e Segurança do Trabalho estar integrado com o módulo de Gestão de Pessoas."###"Favor contate administrador de sistemas"
			lRet := .F.
		EndIf
	Else
		ShowHelpDlg( 	"NOTLTAM" , ;
						{ STR0091 } , 1 , ; //"Dimensões mínimas de tela não atigidas."
						{ STR0092 + STR0093 } , 2 ) //"Para correto funcionamento da rotina, faz-se necessário uma configuração mínima de tela de 1280x720."###"Favor contate administrador de sistemas"
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT500PERG()
Executa pergunte do SX1

@sample
MDT500PERG()

@author Jackson Machado
@since 18/07/2014
/*/
//---------------------------------------------------------------------
Function MDT500PERG()

	If Pergunte( "MDTC500" , .T. )

		MsgInfo( STR0133 ) //"As alterações surtirão efeito após próximo acesso a rotina."

	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fAdequaDic()
Adequa arrays conforme dicionario.

@sample
fAdequaDic()

@author Guilherme Benkendorf
@since 21/11/2014
/*/
//---------------------------------------------------------------------
Static Function fAdequaDic( aAbsAux, aTabPriAux , aCorrespAux , aCpsListAux , aCpsSX3Aux , aDefVirtuAux )

	Local nPosTab
	//Variaveis de controle de dicionário
	Local lTipoAfas:= TNY->( FieldPos( "TNY_CODAFA" ) ) > 0

	If lTipoAfas

		aAdd( aAbsAux , STR0140 ) //"Tipo Ausência"

		nPosTab := aScan( aTabPriAux, { |x| x[_nPosTabPri] == "SR8" } )
		If nPosTab > 0
			aAdd( aTabPriAux[ nPosTab ][_nPosCamVir], { "R8_MOTAUS" , "RCM" , "RCM_DESCRI" , "R8_TIPOAFA" , "RCM_TIPO" , "" } )
			aAdd( aTabPriAux[ nPosTab ][_nPosCamRea], "R8_TIPOAFA" )
		EndIf

		aAdd( aCorrespAux  , { STR0140 , "RCM" , "RCM_TIPO", "RCMMDT"  } ) //"Tipo Ausência"

		aAdd( aCpsListAux  , { STR0140 , { STR0024 , STR0025 , STR0140 , STR0141 } } ) //"Tipo Ausência"###"Quantidade"###"Período"###"Tipo Ausência"###"Desc. Ausência"

		aAdd( aCpsSX3Aux   , { STR0140 , { { STR0140 , "R8_TIPOAFA" } } } ) //"Tipo Ausência"###"Tipo Ausência"

		aAdd( aDefVirtuAux , { "R8_MOTAUS" , CONTROL_ALIGN_LEFT , STR0141 , "C" , 55 , "@!" } ) //"Desc. Ausência"
	EndIf

Return NIL