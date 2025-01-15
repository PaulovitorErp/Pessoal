#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

#DEFINE CRLF CHR(10)+CHR(13)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RCOMA009 ºAutor ³Tarcísio Silva Mirandaº Data³  19/03/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina automática do MVC para cadastro de Alunos.		  º±±
±±º          ³ 			                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TREINAMENTO MVC                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RCOMA009()

Local aCampos	:= {}
Local nI 		:= 0
Local nPos 		:= 0
Local lRet 		:= .T.
Local aAux 		:= {}
Local cCodZB1 	:= ""
Local oModel, oAux, oStruct

if MsgYesNo("Deseja cadastrar Turma vs Alunos?") 
	
	// Criamos um vetor com os dados
	aCab := {}
	aAux 	:= {}
	aItens	:= {}
	
	aAdd( aCab, { 'ZB5_FILIAL'	, xFilial("ZB2") 	} )
	aAdd( aCab, { 'ZB5_CODTUR' 	, "004" 		 	} )
	aAdd( aCab, { 'ZB5_DESTUR' 	, "BANCO DE DADOS" 	} )  
	
	aAdd( aAux, { 'ZB6_FILIAL'	, xFilial("ZB2") 	} )
	aAdd( aAux, { 'ZB6_CODTUR' 	, "004" 			} )
	aAdd( aAux, { 'ZB6_RA' 		, "0002" 			} )
	
	aAdd( aItens, aAux )
	
	Grava( 'ZB5', 'ZB6', aCab, aItens )
	
	endif

Return()

Static Function Grava(  cMaster, cDetail, aCpoMaster, aCpoDetail )
Local  oModel, oAux, oStruct
Local  nI        := 0
Local  nJ        := 0
Local  nPos      := 0
Local  lRet      := .T.
Local  aAux	     := {}
Local  aC  	     := {}
Local  aH        := {}
Local  nItErro   := 0
Local  lAux      := .T.
Local oView 	 := FWViewActive()

//Private aDataModel := {}
Private INCLUI := .T.
Private ALTERA := .F.

dbSelectArea( cDetail )
dbSetOrder( 1 )

dbSelectArea( cMaster )
dbSetOrder( 1 )

// Aqui ocorre o instanciamento do modelo de dados (Model)
// Neste exemplo instanciamos o modelo de dados do fonte COMP021_MVC
// que é a rotina de manutenção de musicas
oModel := FWLoadModel( 'RCOMA008' )

// Temos que definir qual a operação deseja: 3 – Inclusão / 4 – Alteração / 5 - Exclusão
oModel:SetOperation( MODEL_OPERATION_INSERT )

// Antes de atribuirmos os valores dos campos temos que ativar o modelo
// Se o Modelo nao puder ser ativado, talvez por uma regra de ativacao
// o retorno sera .F.
lRet := oModel:Activate()

If lRet

	// Instanciamos apenas a parte do modelo referente aos dados de cabeçalho
	oAux    := oModel:GetModel( cMaster + 'MASTER' )

	// Obtemos a estrutura de dados do cabeçalho
	oStruct := oAux:GetStruct()
	aAux	:= oStruct:GetFields()

	If lRet
		For nI := 1 To Len( aCpoMaster )

			// Verifica se os campos passados existem na estrutura do cabeçalho
			If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) ==  AllTrim( aCpoMaster[nI][1] ) } ) ) > 0

				// È feita a atribuicao do dado aos campo do Model do cabeçalho
				If !( lAux := oModel:SetValue( cMaster + 'MASTER', aCpoMaster[nI][1], aCpoMaster[nI][2] ) )

					// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
					// o método SetValue retorna .F.
					lRet    := .F.
					Exit

				EndIf
			EndIf
		Next
	EndIf
EndIf

If lRet
	// Intanciamos apenas a parte do modelo referente aos dados do item
	oAux     := oModel:GetModel( cDetail + 'DETAIL' )

	// Obtemos a estrutura de dados do item
	oStruct  := oAux:GetStruct()
	aAux	 := oStruct:GetFields()

	nItErro  := 0

	For nI := 1 To Len( aCpoDetail )
		// Incluímos uma linha nova
		// ATENCAO: O itens são criados em uma estrura de grid (FORMGRID), portanto já é criada uma primeira linha
		//branco automaticamente, desta forma começamos a inserir novas linhas a partir da 2ª vez

		If nI > 1

			// Incluimos uma nova linha de item

			If  ( nItErro := oAux:AddLine() ) <> nI

				// Se por algum motivo o metodo AddLine() não consegue incluir a linha,
				// ele retorna a quantidade de linhas já
				// existem no grid. Se conseguir retorna a quantidade mais 1
				lRet    := .F.
				Exit

			EndIf

		EndIf

		For nJ := 1 To Len( aCpoDetail[nI] )

		// Verifica se os campos passados existem na estrutura de item
			If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) ==  AllTrim( aCpoDetail[nI][nJ][1] ) } ) ) > 0

				If !( lAux := oModel:SetValue( cDetail + 'DETAIL', aCpoDetail[nI][nJ][1], aCpoDetail[nI][nJ][2] ) )

					// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
					// o método SetValue retorna .F.
					lRet    := .F.
					nItErro := nI
					Exit

				EndIf
			EndIf
		Next

		If !lRet
			Exit
		EndIf

	Next

EndIf

If lRet

	// Faz-se a validação dos dados, note que diferentemente das tradicionais "rotinas automáticas"
	// neste momento os dados não são gravados, são somente validados.
	If ( lRet := oModel:VldData() )

		// Se o dados foram validados faz-se a gravação efetiva dos dados (commit)
		lRet := oModel:CommitData()

	EndIf
EndIf

If !lRet

	// Se os dados não foram validados obtemos a descrição do erro para gerar LOG ou mensagem de aviso
	aErro   := oModel:GetErrorMessage()

	// A estrutura do vetor com erro é:
	//  [1] Id do formulário de origem
	//  [2] Id do campo de origem
	//  [3] Id do formulário de erro
	//  [4] Id do campo de erro
	//  [5] Id do erro
	//  [6] mensagem do erro
	//  [7] mensagem da solução
	//  [8] Valor atribuido
	//  [9] Valor anterior

	AutoGrLog( "Id do formulário de origem:" + ' [' + AllToChar( aErro[1]  ) + ']' )
	AutoGrLog( "Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']' )
	AutoGrLog( "Id do formulário de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']' )
	AutoGrLog( "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']' )
	AutoGrLog( "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']' )
	AutoGrLog( "Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']' )
	AutoGrLog( "Mensagem da solução:       " + ' [' + AllToChar( aErro[7]  ) + ']' )
	AutoGrLog( "Valor atribuido:           " + ' [' + AllToChar( aErro[8]  ) + ']' )
	AutoGrLog( "Valor anterior:            " + ' [' + AllToChar( aErro[9]  ) + ']' )

	If nItErro > 0
		AutoGrLog( "Erro no Item:              " + ' [' + AllTrim( AllToChar( nItErro  ) ) + ']' )
	EndIf

	MostraErro()
	
	else 
	
	Alert("Cadastro efetuado com sucesso!")	

EndIf

// Desativamos o Model
oModel:DeActivate()

Return lRet 