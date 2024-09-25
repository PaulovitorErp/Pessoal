#Include 'Protheus.ch'
#Include 'MDTR975.ch'

#DEFINE _nVERSAO 02 //Versao do fonte

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTR975
Relatório de treinamentos por produto químico.

@author André Felipe Joriatti
@since 22/04/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------

Function MDTR975

	Local aNGBEGINPRM  := NGBEGINPRM( _nVERSAO )
	Local lRet         := .T.
	Local cDesc1       := STR0001 // "Relatório de Treinamentos por Produto Químico"
	Local cDesc2       := ""
	Local cDesc3       := ""
	Local cString      := "TJC"

	Private wnrel    := "MDTR975"
	Private aReturn  := { "Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
	Private nLastKey := 0
	Private cPerg    := "MDTR975"
	Private titulo   := STR0002 // "Relatório de Treinamentos por Produto Químico" 
	Private cabec1,cabec2
	Private Tamanho  := "G"
	Private ntipo    := 0
	Private nomeprog := "MDTR975"
	Private cQuebra  := Space( 09 )
	
	/*------------------------------
	//PADRÃO						|
	|  De Agente ?					|
	|  Até Agente ?					|
	|  De Produto ?					|
	|  Ate Produto ?				|
	|  De  Treinamento ?			|
	|  Ate Treinamento ?			|
	|  Listar Funcionários ?		|
	------------------------------*/
	Pergunte( cPerg,.F. )
	
	//---------------------------------------
	// Envia controle para a funcao SETPRINT
	//---------------------------------------
	wnrel := SetPrint( cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,"" )

	If nLastKey = 27
		Set Filter To
		Return
	Endif
	SetDefault( aReturn,cString )
	RptStatus( { |lEnd| R975Imp( @lEnd,wnRel,titulo,tamanho ) },titulo )

	NGRETURNPRM( aNGBEGINPRM )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} R975Imp
Impressão do relatório

@author André Felipe Joriatti
@since 22/04/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------

Static Function R975Imp()

	Local cRodaTxt   := ""
	Local nCntImpr   := 0
	Local nContRegs  := 0
	Local cAgente    := ""
	Local lListaFun  := .F.
	Local lDepto     := NGCADICBASE( "TN0_DEPTO", "A" , "TN0" , .F. )
	Local aMatFuncs  := {} // Array para conter os funcionários que realizaram determinado Treinamento
	Local nI         := 0
	Local cCurso     := ""
	Local nTamAgente := TAMSX3( "TJC_AGENTE" )[1]
	Local nTCdProTJC := TAMSX3( "TJC_CODPRO" )[1]
	Local nTCursoTJB := TAMSX3( "TJB_CURSO"  )[1]
	Local nTCdProTJB := TAMSX3( "TJB_CODPRO" )[1]
	Local nTAgTN0    := TAMSX3( "TN0_AGENTE" )[1]
	Local nTamCC     := TAMSX3( "RA_CC" )[1]
	Local nTamFun    := TAMSX3( "RA_CODFUNC" )[1]
	Local nTamDepto  := TAMSX3( "RA_DEPTO" )[1]

	Local cAgenteIni := If ( !Empty( MV_PAR01 ),Padr( MV_PAR01,nTamAgente ),"" )

	// Contadores de Linha e página
	Private li := 80 ,m_pag := 1

	// Verifica se deve imprimir ou não
	nTipo  := IIF( aReturn[4] == 1,15,18 )

	cabec1 := STR0003 // "Agente       Nome"
	cabec2 := STR0004 // "           Produto                           Descrição                  Treinamento       Descrição"
	
	//Se estiver vazio deverá verificar todos os Agentes
	If Empty( cAgenteIni )
		DbSelectArea( "TMA" )
		DbGoTop()
	Else
		DbSelectArea( "TMA" )
		DbSetOrder( 1 ) //TMA_FILIAL+TMA_AGENTE
		DbSeek( xFilial( "TMA" ) + cAgenteIni )		
	EndIf
	
	While !EoF() .And. If( !Empty( cAgenteIni ), TMA->TMA_FILIAL == xFilial( "TMA" ) ;
								 .And. TMA->TMA_AGENTE <= Padr( MV_PAR02,nTamAgente ), .T. )
	
		DbSelectArea( "TJC" ) // Agentes x Produtos Químicos
		DbSetOrder( 01 ) // TJC_FILIAL+TJC_AGENTE+TJC_CODPRO
		DbSeek( xFilial( "TJC" ) + TMA->TMA_AGENTE )
		While !EoF() .And. TJC->TJC_FILIAL == xFilial( "TJC" ) .And. TJC->TJC_AGENTE <= Padr( MV_PAR02,nTamAgente )
	
			// Pula caso o codigo do produto não esteja dentro dos parametros
			If TJC->TJC_CODPRO < Padr( MV_PAR03,nTCdProTJC ) .Or. TJC->TJC_CODPRO > Padr( MV_PAR04,nTCdProTJC )
				fSkipReg( "TJC" )
				Loop
			EndIf
			
			// Pula, caso o treinamento do produto não esteja dentro dos parametros.
			cCurso := ""
			cCurso := NGSEEK( "TJB",TJC->TJC_CODPRO,01,"TJB->TJB_CURSO" )
			If cCurso < MV_PAR05 .Or. cCurso > MV_PAR06
				fSkipReg( "TJC" )
				Loop
			EndIf
	
			cAgente := TJC->TJC_AGENTE
			SomaLinha()
			@ Li,000 Psay TJC->TJC_AGENTE
			@ Li,013 Psay NGSEEK( "TMA",TJC->TJC_AGENTE,01,"TMA->TMA_NOMAGE" )
			SomaLinha()
			DbSelectArea( "TJC" )
			While !EoF() .And. TJC->TJC_AGENTE == cAgente
	
				If TJC->TJC_CODPRO < Padr( MV_PAR03,nTCdProTJC ) .Or. TJC->TJC_CODPRO > Padr( MV_PAR04,nTCdProTJC )
					fSkipReg( "TJC" )
					Loop
				EndIf
	
				DbSelectArea( "TJB" ) // Produtos Químicos
				DbSetOrder( 01 ) // TJB_FILIAL+TJB_CODPRO
				DbSeek( xFilial( "TJB" ) + Padr( TJC->TJC_CODPRO,nTCdProTJB ) )
	
				If TJB->TJB_CURSO < Padr( MV_PAR05,nTCursoTJB ) .Or. TJB->TJB_CURSO > Padr( MV_PAR06,nTCursoTJB )
					fSkipReg( "TJC" )
					Loop
				EndIf
	
				@ Li,011 Psay TJC->TJC_CODPRO
				@ Li,045 Psay SubStr( NGSEEK( "SB1", TJB->TJB_CODPRO, 1,"SB1->B1_DESC" ),1,20 ) // Descrição do produto
				@ Li,072 Psay TJB->TJB_CURSO
				@ Li,090 Psay SubStr( NGSEEK( "RA1",Padr( TJB->TJB_CURSO,TAMSX3( "RA1_CURSO" )[1] ),01,"RA1->RA1_DESC" ),1,20 )
				
				//-----------------------------------------------------------------------------
				// Imprime Funcionários expostos ao Agente que realizaram ou não o Treinamento
				//-----------------------------------------------------------------------------
				aMatFuncs := {}
				DbSelectArea( "TN0" ) // Riscos
				DbSetOrder( 02 ) // TN0_FILIAL+TN0_AGENTE+TN0_NUMRIS
				DbSeek( xFilial( "TN0" ) + Padr( cAgente,nTAgTN0 ) )
				While !EoF() .And. TN0->( TN0_FILIAL + TN0_AGENTE ) == xFilial( "TN0" ) + Padr( cAgente,nTAgTN0 )
					If Empty( TN0->TN0_DTAVAL )
						fSkipReg( "TN0" )
						Loop
					EndIf
	
					DbSelectArea( "SRA" )
					DbSetOrder( 01 ) // RA_FILIAL+RA_MAT
					DbSeek( xFilial( "SRA" ) )
					While !EoF() .And. SRA->RA_FILIAL == xFilial( "SRA" )
						If ( SRA->RA_CC <> Padr( TN0->TN0_CC,nTamCC ) .And. Alltrim(TN0->TN0_CC) <> "*" ) .Or.;
							( SRA->RA_CODFUNC <> Padr( TN0->TN0_CODFUN,nTamFun ) .And. AllTrim(TN0->TN0_CODFUN) <> "*" ) .Or.;
							If( lDepto , ( SRA->RA_DEPTO <>  Padr( TN0->TN0_DEPTO,nTamDepto ) .And. AllTrim( TN0->TN0_DEPTO ) <> "*" ), .F. ) .Or. ;
						   !fRelTarFun( SRA->RA_MAT,TN0->TN0_CODTAR )
							fSkipReg( "SRA" )
							Loop
						EndIf
						
						If  SRA->RA_SITFOLH == "D" .Or. !Empty( SRA->RA_DEMISSA )
							fSkipReg( "SRA" )
							Loop
						EndIf
	
						// Verifica se deve listar o Funcionário de acordo com o parametro MV_PAR07
						lListaFun := fVerListFun( SRA->RA_MAT,TJB->TJB_CURSO )
						DbSelectArea( "RA4" )
						If lListaFun .And. aSCAN(aMatFuncs,{|x| Alltrim(x[1]) + Alltrim(x[2]) == Alltrim(SRA->RA_MAT) + Alltrim(RA4->RA4_DATAFI)}) < 1 
							aAdd( aMatFuncs,{ SRA->RA_MAT,RA4->RA4_DATAFI } )
						EndIf
						fSkipReg( "SRA" )
					EndDo
					fSkipReg( "TN0" )
				EndDo
	
				If Len( aMatFuncs ) > 0
					SomaLinha()
					@ Li,012 Psay STR0005 // "Funcionários Expostos ao Agente: Matrícula         Nome                            Data Treinamento"
					SomaLinha()
					For nI := 1 To Len( aMatFuncs )
						@ Li,045 Psay aMatFuncs[nI][1]
						@ Li,063 Psay SubStr( NGSEEK( "SRA",aMatFuncs[nI][1],01,"SRA->RA_NOME" ),1,25 )
						@ Li,095 Psay aMatFuncs[nI][2]
						SomaLinha()
					Next nI
				EndIf
	
				SomaLinha()
				fSkipReg( "TJC" )
			EndDo
	
			nContRegs++
	
			fSkipReg( "TJC" )
	
		EndDo
		fSkipReg( "TMA" )
	EndDo
	Roda( nCntImpr,cRodaTxt,tamanho )

	If nContRegs == 0
		MsgStop( STR0006 ) // "Não existem dados para compor o relatório!"

		DbSelectArea( "TMA" ) // Agentes
		DbSelectArea( "TJC" ) // Agentes x Produto Químico
		DbSelectArea( "TJB" ) // Produto Químico
		RetIndex( "TMA" )
		RetIndex( "TJC" )
		RetIndex( "TJB" )
		Set Filter To	
		Set Device To Screen
		If aReturn[5] == 1
			// Set Printer To
			DbCommitAll()
		EndIf

		MS_FLUSH()	

		Return .F.
	EndIf

	DbSelectArea( "TMA" ) // Agentes
	DbSelectArea( "TJC" ) // Agentes x Produto Químico
	DbSelectArea( "TJB" ) // Produto Químico
	RetIndex( "TMA" )
	RetIndex( "TJC" )
	RetIndex( "TJB" )
	Set Filter To

	Set Device To Screen
	If aReturn[5] == 1
		Set Printer To
		DbCommitAll()
		OurSpool( wnrel ) 
	EndIf
	MS_FLUSH()	

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} SomaLinha
Incrementa Linha e Controla Salto de Página

@author André Felipe Joriatti
@since 22/04/2013
@version MP11
@return .T.
/*/
//---------------------------------------------------------------------

Static Function SomaLinha()

	Local lRet := .T.
	Li++
	If Li > 58
		Cabec( titulo,cabec1,cabec2,nomeprog,tamanho,nTipo )
	EndIf
	
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fSkipReg
Pula registro do alias informado.

@param String cAlias: indica alias para se pular o registro
@author André Felipe Joriatti
@since 25/04/2013
@version MP11
@return .T.
/*/
//---------------------------------------------------------------------

Static Function fSkipReg( cAlias )
	DbSelectArea( cAlias )
	DbSkip()
Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fRelTarFun
Verifica se Funcionário está relacionado a Tarefa

@param String cMat: indica a matrícula do Funcionário
@param String cTar: indica a Tarefa para verificar relacionamento
@author André Felipe Joriatti
@since 25/04/2013
@version MP11
@return .T.
/*/
//---------------------------------------------------------------------

Static Function fRelTarFun( cMat,cTar )
	Local lRet := If( AllTrim( cTar ) == "*",.T.,NGIFDBSEEK( "TN6",Padr( cTar,TAMSX3( "TN6_CODTAR" )[1] ) + Padr( cMat,TAMSX3( "TN6_MAT" )[1] ),01,.F. ) )
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fVerListFun
Verifica se deve listar o Funcionário de acordo com o conteúdo de 
MV_PAR07
MV_PAR07 == 1: Todos os expostos.
MV_PAR07 == 2: Já realizou o treinamento.
MV_PAR07 == 3: Não realizou Treinamento.

@param String cMat: indica a matrícula do Funcionário para se verificar
@param String cCurso: indica o curso para verificar se funcionário já fez.
@author André Felipe Joriatti
@since 25/04/2013
@version MP11
@return .T.
/*/
//---------------------------------------------------------------------

Static Function fVerListFun( cMat,cCurso )

	Local lRet   := .F.
	Local lFound := .F.
	cMat   := Padr( cMat,TAMSX3( "RA4_MAT" )[1] )
	cCurso := Padr( cCurso,TAMSX3( "RA4_CURSO" )[1] )

	DbSelectArea( "RA4" )
	DbSetOrder( 01 ) // RA4_FILIAL+RA4_MAT+RA4_CURSO
	lFound := DbSeek( xFilial( "RA4" ) + cMat + cCurso )

	If MV_PAR07 == 1
		lRet := .T.
	ElseIf ( !lFound .Or. Empty( RA4->RA4_DATAFI ) ) .And. MV_PAR07 == 3
		lRet := .T.
	ElseIf ( lFound .And. !Empty( RA4->RA4_DATAFI ) ) .And. MV_PAR07 == 2
		lRet := .T.
	EndIf

Return lRet