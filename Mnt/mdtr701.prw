#Include "Mdtr701.ch"
#Include "Msole.CH"
#Include "Protheus.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTR701
PPP somente com dados cadastrais 

@author Jackson Machado
@since 15/03/2011

/*/
//---------------------------------------------------------------------
Function MDTR701()

	If Pergunte( 'MDT701', .T.)

		fImprime()

	Endif

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fImprime
Impressao do relatório

@author Jackson Machado
@since 15/03/2011

/*/
//---------------------------------------------------------------------
Static Function fImprime()

	Local cNome	:= IIf( !Empty( mv_par03 ), Capital( AllTrim( mv_par03 ) ), 'Documento1' ) // Nome do arquivo de saída
	Local cModelo := Alltrim( GetMv( 'MV_DIRACA' ) ) // Caminho do modelo
	Local cSalvar := Alltrim( GetMv( 'MV_DIREST' ) ) // Caminho para salvar arquivo
	Local cEstacao := IIf( GetRemoteType() == 2, '/', '\' ) // Estação linux ou windows
	Local cArquivo := 'ppp.dotm'
	Local cServidor := IIf( IsSrvUnix(), '/', '\' ) // Servidor linux ou windows

	Local lLinux := IIf( GetRemoteType() == 2 .Or. isSrvUnix(), .T., .F. ) //Verifica se servidor ou estacao é Linux

	Local oWord

	cModelo += IIf( Substr( cModelo, Len( cModelo ), 1 ) != cServidor, cServidor, '' ) + cArquivo
	cSalvar += IIf( Substr( cSalvar, Len( cSalvar ), 1 ) != cEstacao, cEstacao, '' )

	MontaDir( cSalvar ) // Cria o diretório se ainda não existir

	If File( cSalvar + cArquivo )
		Ferase( cSalvar + cArquivo ) // Apaga arquivo salvo anteriormente
	EndIf

	If !File( cModelo )

		// "O arquivo ppp.dot não foi encontrado no servidor. // "Verificar parâmetro 'MV_DIRACA'." //"ATENÇÃO"
		MsgStop( STR0013 + Chr( 10 ) + STR0014, STR0012 )

		Return

	EndIf

	CpyS2T( cModelo, cSalvar, .T. ) // Copia o arquivo para estação

	oWord := OLE_CreateLink() // Cria link com o Word

	OLE_NewFile( oWord, cSalvar + cArquivo ) // Abre o arquivo modelo automaticamente

	fDados( oWord ) // Define os dados a serem impressos

	OLE_ExecuteMacro( oWord, 'Atualiza' ) // Atualiza os campos do documento
	OLE_ExecuteMacro( oWord, 'Begin_Text' ) // Posiciona o cursor no início do documento

	If mv_par02 == 1

		OLE_SetProperty( oWord, '208', .F. )

		OLE_PrintFile( oWord, 'ALL', Nil, Nil, 1 )

	Else

		OLE_SetProperty( oWord, oleWdVisible, .T.)

		OLE_ExecuteMacro( oWord, 'Maximiza_Tela' )

		If !lLinux

			If DIRR701( cSalvar )
				OLE_SaveAsFile( oWord, cSalvar + cNome, Nil, Nil, .F., oleWdFormatDocument )
			Endif

		Endif

		MsgInfo( STR0011 ) // "Alterne para o programa do Ms-Word para visualizar o documento ou clique no botao para fechar."

	EndIF

	OLE_CloseFile( oWord )
	OLE_CloseLink( oWord )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fDados
Define os dados que serão impressos no documento

@author Gabriel Sokacheski
@since 14/07/2022

@param, oWord, objeto de impressão
/*/
//---------------------------------------------------------------------
Static Function fDados( oWord )

	Local cCnpj := ''
	Local cCnae := ''
	Local cBrpdh := 'NA'
	Local cRegime := 'NA'
	Local cEmpresa := SM0->M0_NOMECOM

	Local nCnae := Len( Alltrim( SM0->M0_CNAE ) )

	If !Empty( SM0->M0_CGC )
		cCnpj := IIf( SM0->M0_TPINSC == 2, Transform( SM0->M0_CGC, '@R 99.999.999/9999-99' ), Transform( SM0->M0_CGC, '@R 99.999.99999/99' ) )
	EndIf

	If !Empty( SM0->M0_CNAE )
		cCnae := IIf( nCnae > 5, Transform( SM0->M0_CNAE, '@R 99.99-9/99' ), Transform( SM0->M0_CNAE, '@R 99.99-9' ) )
	Endif

	// Dados Empresa
	OLE_SetDocumentVar( oWord, 'Emp_Nome', cEmpresa )
	OLE_SetDocumentVar( oWord, 'Emp_cnpj', cCNPJ )
	OLE_SetDocumentVar( oWord, 'Emp_cnae', cCnae )

	DbSelectArea( 'SRA' )
	DbSetOrder(1)

	If DbSeek( xFilial( 'SRA' ) + mv_par01 )

		If SRA->RA_BRPDH == '1'
			cBrpdh := 'BR'
		Elseif SRA->RA_BRPDH == '2'
			cBrpdh := 'PDH'
		Endif

		// Dados do funcionário
		OLE_SetDocumentVar( oWord, 'Fun_Nome', SRA->RA_NOME )
		OLE_SetDocumentVar( oWord, 'Fun_mat', SRA->RA_MAT )

		OLE_SetDocumentVar( oWord, 'Cpf', Transform( SRA->RA_CIC, '@R 999.999.999-99' ) )
		OLE_SetDocumentVar( oWord,  'eSocial', AllTrim( SRA->RA_CODUNIC ) )

		OLE_SetDocumentVar( oWord, 'Fun_brpdh' ,cBrpdh )
		OLE_SetDocumentVar( oWord, 'Fun_Admissao', SRA->RA_ADMISSA )
		OLE_SetDocumentVar( oWord, 'Fun_Sexo', SRA->RA_SEXO )
		OLE_SetDocumentVar( oWord, 'Fun_Nasc', SRA->RA_NASC )

		DbSelectArea( 'SR6' )
		DbSetOrder( 1 )
		If DbSeek( xFilial( 'SR6' ) + SRA->RA_TNOTRAB )

			If !Empty( Substr( SR6->R6_REVEZAM, 1, 20 ) )
				cRegime := Substr( Posicione( 'SR6', 1, xFilial( 'SR6' ) + SRA->RA_TNOTRAB, 'R6_REVEZAM' ), 1, 20 )
			Endif

		EndIf

	EndIf

	OLE_SetDocumentVar( oWord, 'Fun_Reg', cRegime )

	If mv_par04 == 1 // Imprime comprovante

		OLE_SetDocumentVar( oWord, 'matricula', SRA->RA_MAT )
		OLE_SetDocumentVar( oWord, 'cc', Posicione( 'CTT', 1, xFilial( 'CTT' ) + SRA->RA_CC, 'CTT_DESC01' ) )
		OLE_SetDocumentVar( oWord, 'func', Posicione( 'SRJ', 1, xFilial( 'SRJ' ) + SRA->RA_CODFUNC, 'RJ_DESC' ) )
		OLE_SetDocumentVar(oWord, 'termo', Posicione( 'TMZ', 1, xFilial( 'TMZ' ) + mv_par05, 'TMZ_DESCRI' ) )
		OLE_SetDocumentVar( oWord, 'cidade', SA1->A1_MUN )
		OLE_SetDocumentVar( oWord, 'dia', Day( dDataBase ) )
		OLE_SetDocumentVar( oWord, 'mes', MesExtenso( dDataBase ) )
		OLE_SetDocumentVar( oWord, 'ano', Year( dDataBase ) )

	Else

		OLE_ExecuteMacro( oWord, 'deleta_comprovante' )

	Endif

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} DIRR701
Verifica se o diretorio existe

@author Jackson Machado
@since 15/03/2011

/*/
//---------------------------------------------------------------------
Static Function DIRR701(cCaminho)

	Local lDir := .F.
	Local cBARRAS   := If(isSRVunix(),"/","\")
	Local cBARRAD := If(isSRVunix(),"//","\\")

	If !empty(cCaminho) .and. !(cBARRAD$cCaminho)
		cCaminho := alltrim(cCaminho)
		if Right(cCaminho,1) == cBARRAS
			cCaminho := SubStr(cCaminho,1,len(cCaminho)-1)
		Endif
		lDir :=(Ascan( Directory(cCaminho,"D"),{|_Vet | "D" $ _Vet[5] } ) > 0)
	EndIf

Return lDir
