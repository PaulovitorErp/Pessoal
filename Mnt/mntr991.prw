#Include 'Protheus.ch'
#Include 'MNTR991.ch'
#DEFINE _nVERSAO 1 //Versao do fonte

//--------------------------------------------------------------
/*/{Protheus.doc} MNTR991
Relatório de Inconsistências do Sistema após conversão de fontes
para MVC, onde é listado todos os fontes que foram convertidos e 
que utilizam campo de memória(M->) em seu cadastro de clique da
direita(TQD).

@param array com as rotinas a serem verificadas

@author Pablo Servin
@since 11/04/2014
@version MP11
@return Nil
/*/
//---------------------------------------------------------------
Function MNTR991( aRotMVC )
	
	Local cString    := "TQD"
	Local cDesc1     := STR0001 /* "Relatório de Inconsistências do Sistema." */
	Local cDesc2     := ""
	Local cDesc3     := ""
	Local wnRel      := "MNTR991"
	
	Private aReturn  := { STR0002, 1,STR0003, 1, 2, 1, "",1 }  /* "Zebrado"###"Administração" */
	Private nLastKey := 0
	Private Titulo   := STR0001 /* "Relatório de Inconsistências do Sistema." */
	Private Tamanho  := "M"
	Private nomeprog := "MNTR991"
	Private aRotinas := aRotMVC /* aRotinas recebe o parâmetro, que contém as rotinas a serem verificadas. */
	
	/* Cria interface para configuração de impressão do relatório. */
	wnRel := SetPrint( cString, wnRel,, Titulo, cDesc1, cDesc2, cDesc3, .F., "")

	If ( nLastKey = 27 )
	   Set Filter To
	   dbSelectArea( "TQD" )
	   Return
	EndIf

	/* Prepara o ambiente de impressão. */
	SetDefault( aReturn,cString )
	/* Exibe um dialógo para acompanhamento da impressão(Régua de Progressão). */
	RptStatus( {|lEnd| MNTR991Imp( @lEnd, wnRel, Titulo, Tamanho)}, Titulo )
                
	Set Key VK_F9 To
	dbSelectArea( "TQD" )

Return Nil

//-----------------------------------------------------------
/*/{Protheus.doc} MNTR991Imp
Chamada de impressão do relatório.

@author Pablo Servin
@since 11/04/2014
@version MP11
@return .T.
/*/
//-------------------------------------------------------------
Function MNTR991Imp( lEnd, wnRel, Titulo, Tamanho )

	/* Variáveis padrão do relatório */
	Local cRODATXT := ""
	Local nCNTIMPR := 0
	Local nMULT    := 1,xx
	
	/* Variáveis usadas no processo */
	Local nX, nG
	Local aParam /* Usada para armazenar o retorno da função StrToKArr. */
	Local cParam /* Inidca o parametro */
	Local cProg := "" /* Indica o programa da click da direita.*/
	Local cRot := "" /* Indica a rotina. */

	Private li := 80 , m_pag := 1

	nTIPO  := IIf( aReturn[4]==1,15,18 )
	CABEC1 := STR0004 /* "Inconsistências no Click da Direita que devem ser corrigidas no Sistema." */
	CABEC2 := ""
	CABEC( Titulo, CABEC1, CABEC2, nomeprog, Tamanho, 15 )
	
	@LI,000 PSay STR0005
	NGSOMALI(58)
	
	/*--------------------------------------------------------------------------------------------------------------------------------------------------------//
	//------------------- TRECHO QUE IMPRIMIRÁ AS INCONSISTÊNCIAS DO CLICK DA DIREITA DO SISTEMAS APÓS A CONVERSÃO DAS ROTINAS PARA MVC ----------------------//
	//--------------------------------------------------------------------------------------------------------------------------------------------------------//
	
	
		aRotinas: Array que contém as rotinas a serem verificadas, é inicializada na função MNTR991.	 
		aRotinas[nX][1] = Nome da Rotina
		aRotinas[nX][2] = Id do Formulário (ViewDef da rotina)
		aRotinas[nX][3] = Código do chamado.	 
	
	*/
	For nX := 1 to Len( aRotinas )

		dbSelectArea( "TQD" )
		dbSetOrder( 01 ) /* TQD_FILIAL + TQD_PROGRA + TQD_FUNCAO */

		/* Verifica se encontra o registro de acordo com a rotina que está posicionada. */
		If ( dbSeek( xFilial( "TQD" ) + aRotinas[nX][1] ) )
			/* Lista todos os registros relacionados a rotina que está posicionada. */
			While !Eof() .And. TQD->TQD_PROGRA = aRotinas[nX][1]
				/* Se o campo de parâmetro(TQD->TQD_PARAM) contiver variável de memória, realiza os processos */
				If ( "M->" $ TQD->TQD_PARAM .Or. "m->" $ TQD->TQD_PARAM )

					/* Se a rotina que está posicionada for diferente da anterior, 
					imprime o nome da rotina atual na tela */
					If aRotinas[nX][1] != cRot 
						NGSOMALI(58)
						@LI,000 PSay aRotinas[nX][3] + " - " + aRotinas[nX][1] Picture "@!"
					EndIf

					/* Transforma o conteúdo do campo em array separado por uma ',' */
					aParam := StrToKArr( TQD->TQD_PARAM, "," )

					/* Percorre todo os elementos do array que foi criado a partir do retorno do StrToKArr. */
					For nG := 1 to Len( aParam )
						/* Se os elementos conterem campo de memória, mostra na 
						   tela os mesmos mais a função que é chamada no click da direita. */	
						If ( "M->" $ aParam[nG] .Or. "m->" $ aParam[nG] )

							@LI,023 PSay AllTrim( TQD->TQD_FUNCAO ) Picture "@!"	 /* Mostra a função respectiva a rotina */					
							@LI,037 PSay AllTrim( aParam[nG] ) Picture "@!" /* Mostra o conteúdo do parâmetro */  							                                
							@LI,059 PSay STR0006 + AllTrim( aParam[nG] ) + STR0007 +AllTrim( aRotinas[nX][2] )+; // "Trocar de " ## " para oView:GetValue('"
							"', '" + AllTrim( SubStr( aParam[nG], 4, Len(aParam[nG]) ) ) + "')" Picture "@!" /* Mostra a solução respectiva a ser feita */
											  /*Substr usado para retirar o 'M->' */
							NGSOMALI(58)

						EndIf
					Next nG
					cRot := aRotinas[nX][1] /* Armazena a última rotina verificada */
					cParam := TQD->TQD_PARAM	 /* Armazena o último parâmetro verificado */
					cProg := TQD->TQD_FUNCAO /* Armazena  a última função verificada */
				EndIf
				dbSelectArea( "TQD" )
				dbSkip()
			End While
		EndIf
	Next nX	

	NGSOMALI(58)
	NGSOMALI(58)
	@LI, 000 PSay STR0008 + STR0009 /* "Para maior entendimento e detalhamento sobre como funcionam as rotinas em MVC, "
	 ## "você pode acessar o seguinte link: " ## */
	NGSOMALI(58)
	@LI, 000 PSay "http://tdn.totvs.com/display/public/mp/MVC+-+Model+View+Control"
	NGSOMALI(58)
	@LI, 000 PSay STR0010
	NGSOMALI(58)
	//--------------------------------------------------------------------------------------------------------------------------------------------------------//
	//---------------------------- FIM DA IMPRESSÃO DAS INCONSISTÊNCIAS NO CLICK DA DIREITA CAUSADAS PELA CONVERSÃO PARA MVC --------------------------------//
	//--------------------------------------------------------------------------------------------------------------------------------------------------------// 
	Roda( nCntImpr, cRodaTxt, Tamanho )

	Set Filter To
	Set Device to Screen
	If ( aReturn[5] == 1 )
	   Set Printer To
	   dbCommitAll()
	   OurSpool( wnrel )
	EndIf

	MS_FLUSH()

Return .T.

//-------------------------------------------------------------
/*/{Protheus.doc} INIARRMOD
Função que inicializa o array com os IDs dos formulários dos 
fontes que foram convertidos para MVC.

@author Pablo Servin
@since 11/04/2014
@version MP11
@return aModelos - Array bidimensional com as rotinas e IDs dos
					 fontes que foram convertidos para MVC.
/*/
//--------------------------------------------------------------
Function INIARRMOD()

	Local aModelos := {}

	/*
	   Adicionar nesse array as rotinas que foram convertidas para MVC para serem
	   verificadas. Obs.: Utilizar a função aAdd para acrescentar 	novas rotinas...
	   	
	   aRotMVC[x][1] = Nome da Rotina
	   aRotMVC[x][2] = Id do Formulário (ViewDef da rotina)
	   aRotMVC[x][3] = Código do chamado.
	*/
	
	aAdd( aModelos, { "MNTA100", "MNTA100_STD", "" } )
	aAdd( aModelos, { "MNTA185", "MNTA185_TP3", "" } )
	aAdd( aModelos, { "MNTA215", "MNTA215_TP8", "" } )
	aAdd( aModelos, { "MNTA710", "MNTA710_TQY", "" } )
	aAdd( aModelos, { "MNTA025", "MNTA025_TPJ", "" } )
	aAdd( aModelos, { "MNTA065", "MNTA065_TPV", "" } )
	aAdd( aModelos, { "MNTA110", "MNTA110_STE", "" } )
	aAdd( aModelos, { "MNTA205", "MNTA205_TP7", "" } )

Return aModelos