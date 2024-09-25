#include "MDTA997.ch"
#include "Protheus.ch"
//-------------------------------------------------------
/*{Protheus.doc} MDTA997
Programa de cadastro de medições de dosimetria.

@type 	Function
@author Elynton Fellipe Bazzo
@since  21/03/2012
@sample MDTA997()

@return  Nil, Sempre Nulo
*/
//-------------------------------------------------------
Function MDTA997()

	Local oTempTJ7
	Local aCpsTJ7 := APBuildHeader( 'TJ7' )
	Local cCampo  := ''
	Local aTamCpo := {}
	Local nCps    := 0

	Private aNGBEGINPRM	:= NGBEGINPRM()
	Private aDBFTJ7     := {}
	Private cAliasTJ7   := GetNextAlias()
	Private aFieldsTJ7  := {}
	Private	aTROCAF3	:= {}
	Private	aRotina		:= MenuDef()

	//Define o cabecalho da tela de atualizacoes
	Private cCadastro	:= OemtoAnsi( STR0006 ) // "Medição de Dosimetro"

	If FindFunction( 'MDTChkTJ7' )

		If MDTChkTJ7() // Verifica o tamanho do campo TJ7_CODIGO

			dbSelectArea( "TJ7" )
			dbSetOrder( 01 )

			For nCps := 1 To Len( aCpsTJ7 )

				If nCps == 1
					cCampo := "TJ7_FILIAL"
					aAdd( aFieldsTJ7, { Posicione( 'SX3', 2, cCampo, 'X3Titulo()' ), cCampo, GetSx3Cache( cCampo, 'X3_TIPO' ), ;
							TamSX3( cCampo )[1], TamSX3( cCampo )[2], X3Picture( cCampo ) } )
					aAdd( aDBFTJ7, {cCampo, GetSx3Cache( cCampo, 'X3_TIPO' ), TamSX3( cCampo )[1], TamSX3( cCampo )[2]} )
				EndIf

				cCampo  := Alltrim( aCpsTJ7[ nCps, 2 ] )
				aTamCpo := TamSX3( cCampo )
				cTipo   := GetSx3Cache( cCampo, 'X3_TIPO' )

				If GetSx3Cache( cCampo, 'X3_BROWSE' ) == 'S' .And. cCampo != "TJ7_TIPREG"
					aAdd( aFieldsTJ7, { X3Titulo(), cCampo, cTipo, aTamCpo[1], aTamCpo[2], X3Picture( cCampo ) } )
				EndIf
				aAdd( aDBFTJ7, {cCampo, cTipo, aTamCpo[1], aTamCpo[2]} )

			Next nCps

			aAdd( aDBFTJ7, { "DESCCOM", "C", 30, 0 } )

			// Cria arquivo temporário para Não Conformidade x Credenciado
			oTempTJ7 := FWTemporaryTable():New( cAliasTJ7, aDBFTJ7 )
			oTempTJ7:AddIndex( "1", {"TJ7_FILIAL", "TJ7_TIPREG", "TJ7_CODIGO", "TJ7_PONTO", "TJ7_DATA" } )
			oTempTJ7:Create()

			fMdtaTrb() // Popula TRB com TJ7

			DbSelectArea( cAliasTJ7 )
			DbSetOrder( 01 ) // TJ7_FILIAL+TJ7_TIPREG+TJ7_CODIGO+TJ7_PONTO+DESCEND(DTOS(TJ7_DATA))
			mBrowse( 6, 1, 22, 75, ( cAliasTJ7 ), aFieldsTJ7 )

			oTempTJ7:Delete()

			//Retorna conteudo de variaveis padroes
			NGRETURNPRM(aNGBEGINPRM)
		EndIf
	Else
		MsgStop( STR0014 ) //"Seu ambiente encontra-se desatualizado ou com inconsistências no campo Código (TJ7_CODIGO) da tabela de Serviços (TJ7). Favor atualizar o ambiente."
	EndIf

Return Nil

//-------------------------------------------------------
/*{Protheus.doc} MenuDef
Utilização de Menu Funcional.

Parametros do array a Rotina:
1. Nome a aparecer no cabecalho
2. Nome da Rotina associada
3. Reservado
4. Tipo de Transa‡„o a ser efetuada:
	1 - Pesquisa e Posiciona em um Banco de Dados
	2 - Simplesmente Mostra os Campos
	3 - Inclui registros no Bancos de Dados
	4 - Altera o registro corrente
	5 - Remove o registro corrente do Banco de Dados
5. Nivel de acesso
6. Habilita Menu Funcional

@author  	Elynton Fellipe Bazzo
@since  	21/03/2012
@Return 	Array com opcoes da rotina.

*/
//--------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {{ STR0001, "MDT997PESQ", 0, 1 },; // "Pesquisar"
                   	 { 	STR0002, "MDT997CAD", 0, 2  },; // "Visualizar"
                   	 { 	STR0003, "MDT997CAD", 0, 3  },; // "Incluir"
                   	 { 	STR0004, "MDT997CAD", 0, 4  },; // "Alterar"
                   	 { 	STR0005, "MDT997CAD", 0, 5, 3 } } // "Excluir"

Return aRotina

//---------------------------------------------------------------------
/*{Protheus.doc} MDTA997TF3
Função que Troca o F3 do campo TJ7_CODIGO, conforme a opção selecionada
no campo que identifica o tipo de registro.

@type 	Function
@author Elynton Fellipe Bazzo
@since  22/03/2012
@sample MDTA997TF3()

@return lRet, verdadeiro se encontrar o Funcionário
*/
//---------------------------------------------------------------------
Function MDTA997TF3()

	Local lRet  := .T.
  	aTROCAF3	:= {}

 	If M->TJ7_TIPREG == "1"     //Ambiente Físico
   		aAdd( aTROCAF3, { "TJ7_CODIGO", "TNE" } )
 	ElseIf M->TJ7_TIPREG == "2" //Funcionário
   		aAdd( aTROCAF3, { "TJ7_CODIGO", "SRA" } )
	ElseIf M->TJ7_TIPREG == "3" //Centro de Custo
   		aAdd( aTROCAF3, { "TJ7_CODIGO", "CTT" } )
	ElseIf M->TJ7_TIPREG == "4" //Função
   		aAdd( aTROCAF3, { "TJ7_CODIGO", "SRJ" } )
	ElseIf M->TJ7_TIPREG == "5" //Tarefa
   		aAdd( aTROCAF3, { "TJ7_CODIGO", "TN5" } )
	EndIf
	lRefresh := .T.

Return lRet

//---------------------------------------------------------------------
/*{Protheus.doc} LoadRegraTJ7
Função que executa o Gatilho do campo TJ7_CODIGO, dependendo do tipo de
registro selecionado.

@type Funcion
@author Elynton Fellipe Bazzo
@since  25/03/2012
@sample LoadRegraTJ7(1, )
@param cTipReg, caracter, tipo do registro informado
@param cCod, caracter

@return cDescri, caracter, retorna com as informções
*/
//---------------------------------------------------------------------
Function LoadRegraTJ7( cTipReg, cCod )

	Local cTable
	Local nTamCod
	Local nIdx
	Local cDesc
	Local cDescri

	If cTipReg == "1"     // Ambiente Físico
		cTable		:= "TNE"
		nIdx		:= 1
		nTamCod	:= TAMSX3( "TNE_CODAMB" )[ 1 ]
		cDesc		:= "TNE->TNE_NOME"
	ElseIf cTipReg == "2" // Funcionário
		cTable		:= "SRA"
		nIdx		:= 1
		nTamCod	:= TAMSX3( "RA_MAT" )[ 1 ]
		cDesc		:= "SRA->RA_NOME"
	ElseIf cTipReg == "3" // Centro de Custo
		cTable		:= "CTT"
		nIdx		:= 1
		nTamCod	:= TAMSX3( "CTT_CUSTO" )[ 1 ]
		cDesc		:= "CTT->CTT_DESC01"
	ElseIf cTipReg == "4" // Função
		cTable		:= "SRJ"
		nIdx		:= 1
		nTamCod	:= TAMSX3( "RJ_FUNCAO" )[ 1 ]
		cDesc		:= "SRJ->RJ_DESC"
	ElseIf cTipReg == "5" // Tarefa
		cTable		:= "TN5"
		nIdx		:= 1
		nTamCod	:= TAMSX3( "TN5_CODTAR" )[ 1 ]
		cDesc		:= "TN5->TN5_NOMTAR"
	EndIf

	cDescri := NGSEEK( cTable, Padr( cCod, nTamCod ), nIdx, cDesc )

Return cDescri

//---------------------------------------------------------------------
/*{Protheus.doc} MDTA997VCOD
Função que  valida o campo TJ7_CODIGO, conforme a opção selecionada
no campo que identifica o tipo de registro.

@type   Function
@author Elynton Fellipe Bazzo
@since  06/04/2012
@sample MDTA997VCOD()

@Return lRet, verdadeiro se encontrar o Funcionário
*/
//---------------------------------------------------------------------
Function MDTA997VCOD()

	Local lRet 	 := .T.
	Local cAlias := ""
	Local cCampo := ""

	Do Case
		Case M->TJ7_TIPREG == "1"
	   		cAlias := "TNE"
	   		cCampo := "TNE_CODAMB"
	  	Case M->TJ7_TIPREG == "2"
	   		cAlias := "SRA"
	   		cCampo := "RA_MAT"
	  	Case M->TJ7_TIPREG == "3"
	   		cAlias := "CTT"
	   		cCampo := "CTT_CUSTO"
	  	Case M->TJ7_TIPREG == "4"
	   		cAlias := "SRJ"
	   		cCampo := "RJ_FUNCAO"
	  	Case M->TJ7_TIPREG == "5"
	   		cAlias := "TN5"
	   		cCampo := "TN5_CODTAR"
	 EndCase

	lRet := ExistCpo( cAlias, Padr( M->TJ7_CODIGO, TAMSX3( cCampo )[1] ) )

Return lRet

//---------------------------------------------------------------------
/*{Protheus.doc} VALIDTIPREG()
Função que valida os campos código e nome, quando o tipo de registro De dosimetria for alterado.

@type   Function
@author Elynton Fellipe Bazzo
@since  16/04/2012
@sample VALIDTIPREG()

@return Lógico, Sempre verdadeiro
*/
//---------------------------------------------------------------------
Function VALIDTIPREG()

	M->TJ7_CODIGO := Space( TAMSX3( "TJ7_CODIGO" )[1] )
	M->TJ7_NOME	  := Space( TAMSX3( "TJ7_NOME" )[1] )

Return .T.

//---------------------------------------------------------------------
/*{Protheus.doc} MDT997CAD()
Utilização de Menu Funcional.

@type   Function
@author Elynton Fellipe Bazzo
@since  23/04/2012
@sample MDT997CAD( "TJ7", 38, 2 )
@param cAlias, caracter, indica qual a tabela posicionada
@param nRecno, numérico, indica qual o registro posicionado
@param nOpcx, numérico,

@return Lógico, Sempre verdadeiro
*/
//---------------------------------------------------------------------
Function MDT997CAD( cAlias, nRecno, nOpcx )

	Private aTROCAF3	:= {}

	dbSelectArea( "TJ7" )
	dbSetOrder( 01 )
	dbSeek( xFilial( "TJ7" ) + (cAliasTJ7)->TJ7_TIPREG + (cAliasTJ7)->TJ7_CODIGO + (cAliasTJ7)->TJ7_PONTO + DTOS( (cAliasTJ7)->TJ7_DATA))

	//Necessário para o F3 vir com os registro corretos
	If nOpcx == 2 .Or. nOpcx == 5
	 	If TJ7->TJ7_TIPREG == "1"     //Ambiente Físico
	   		aAdd( aTROCAF3, { "TJ7_CODIGO", "TNE" } )
	 	ElseIf TJ7->TJ7_TIPREG == "2" //Funcionário
	   		aAdd( aTROCAF3, { "TJ7_CODIGO", "SRA" } )
		ElseIf TJ7->TJ7_TIPREG == "3" //Centro de Custo
	   		aAdd( aTROCAF3, { "TJ7_CODIGO", "CTT" } )
		ElseIf TJ7->TJ7_TIPREG == "4" //Função
	   		aAdd( aTROCAF3, { "TJ7_CODIGO", "SRJ" } )
		ElseIf TJ7->TJ7_TIPREG == "5" //Tarefa
	   		aAdd( aTROCAF3, { "TJ7_CODIGO", "TN5" } )
		EndIf
	EndIf

	If nOpcx != 5
  		NGCAD01( "TJ7", TJ7->( Recno() ), nOpcx )
 	Else
  		NGCAD01( "TJ7", TJ7->( Recno() ), nOpcx, 3 )
 	EndIf

 	fMdtaTrb()

Return .T.

//---------------------------------------------------------------------
/*{Protheus.doc} fMdtaTrb()
Função que popula arquivo de trabalho com registros da tabela TJ7

@author  	Elynton Fellipe Bazzo
@since  	23/04/2012
@uso		SIGAMDTA
@version 	01
//---------------------------------------------------------------------
*/
Static Function fMdtaTrb()

	Local nI

	dbSelectArea(cAliasTJ7)
	ZAP

	dbSelectArea( "TJ7" )
	dbSetOrder( 01 )
	dbSeek( xFilial( "TJ7" ))
	While !Eof() .And. TJ7->TJ7_FILIAL == xFilial( "TJ7" )
		DbSelectArea( cAliasTJ7 )
		DbAppend()
		For nI := 1 To TJ7->( Fcount() )
			x   := "TJ7->" + TJ7->( Fieldname( nI ) )
			y   := cAliasTJ7 + "->" + TJ7->( Fieldname( nI ) )
			&y. := &x.
		Next nI
		( cAliasTJ7 )->DESCCOM := NGRETSX3BOX( "TJ7_TIPREG",TJ7->TJ7_TIPREG )
		dbSelectArea( "TJ7" )
		dbSkip()
	End

Return

//---------------------------------------------------------------------
/*{Protheus.doc} ValDtMdt997()
Valida data da medição de dosimetria, sendo que a data não pode ser maior que a atual.

@author  	Elynton Fellipe Bazzo
@since  	23/04/2012
@Return 	.T.
@uso		SIGAMDTA
@version 	01
//---------------------------------------------------------------------
*/
Function ValDtMdt997(cTipoReg, cCodigo)

	Local lRet := .T.
	Local dDTADM
	Local dDTDEM

	If M->TJ7_DATA > dDataBase
		ShowHelpDlg(STR0008,;//"Atenção"
					{STR0007},1,;//"A data da realização da medição de dosímetro não pode ser maior que a data atual."
					{STR0009},1) //"Informe uma data menor ou igual a data atual."
		lRet := .F.
	EndIf
	If cTipoReg == "2"
		dDTADM 	:= NGSEEK("SRA", Alltrim(cCodigo),1,'SRA->RA_ADMISSA')
		dDTDEM 	:= NGSEEK("SRA", Alltrim(cCodigo),1,'SRA->RA_DEMISSA')
		If	M->TJ7_DATA < dDTADM
			ShowHelpDlg(STR0008,;//"Atenção"
						{STR0010},1,;//
						{STR0011+DtoC(dDTADM)},1)
			lRet := .F.
		ElseIf !Empty(dDTDEM) .And. M->TJ7_DATA > dDTDEM
			ShowHelpDlg(STR0008,;//"Atenção"
						{STR0012},1,;//
						{STR0013+DtoC(dDTDEM)},1)
			lRet := .F.
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*{Protheus.doc} MDT997PESQ
Funcionalidade de pesquisa no arquivo temporário do browse

@author: Elynton Fellipe Bazzo
@since: 23/04/2012
@return: .T.
@uso: SIGAMDTA
@version: P11
//---------------------------------------------------------------------
*/
Function MDT997PESQ()

	Local nTamTotChv := TAMSX3( "TJ7_FILIAL" )[1] + TAMSX3( "TJ7_TIPREG" )[1] + TAMSX3( "TJ7_CODIGO" )[1] + ;
		TAMSX3( "TJ7_PONTO" )[1] + TAMSX3( "TJ7_DATA" )[1]

	// Gera dialog para funcionalidade de Pesquisa
	NGPESQTRB( cAliasTJ7,{ "Filial+Registro+Codigo+Ponto+Data" },nTamTotChv,"Pesquisar" )

Return Nil