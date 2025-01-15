#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

#DEFINE CRLF CHR(10)+CHR(13)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RCOMA009 �Autor �Tarc�sio Silva Miranda� Data�  19/03/2014 ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina autom�tica do MVC para cadastro de Alunos.		  ���
���          � 			                                                  ���
�������������������������������������������������������������������������͹��
���Uso       � TREINAMENTO MVC                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
// que � a rotina de manuten��o de musicas
oModel := FWLoadModel( 'RCOMA008' )

// Temos que definir qual a opera��o deseja: 3 � Inclus�o / 4 � Altera��o / 5 - Exclus�o
oModel:SetOperation( MODEL_OPERATION_INSERT )

// Antes de atribuirmos os valores dos campos temos que ativar o modelo
// Se o Modelo nao puder ser ativado, talvez por uma regra de ativacao
// o retorno sera .F.
lRet := oModel:Activate()

If lRet

	// Instanciamos apenas a parte do modelo referente aos dados de cabe�alho
	oAux    := oModel:GetModel( cMaster + 'MASTER' )

	// Obtemos a estrutura de dados do cabe�alho
	oStruct := oAux:GetStruct()
	aAux	:= oStruct:GetFields()

	If lRet
		For nI := 1 To Len( aCpoMaster )

			// Verifica se os campos passados existem na estrutura do cabe�alho
			If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) ==  AllTrim( aCpoMaster[nI][1] ) } ) ) > 0

				// � feita a atribuicao do dado aos campo do Model do cabe�alho
				If !( lAux := oModel:SetValue( cMaster + 'MASTER', aCpoMaster[nI][1], aCpoMaster[nI][2] ) )

					// Caso a atribui��o n�o possa ser feita, por algum motivo (valida��o, por exemplo)
					// o m�todo SetValue retorna .F.
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
		// Inclu�mos uma linha nova
		// ATENCAO: O itens s�o criados em uma estrura de grid (FORMGRID), portanto j� � criada uma primeira linha
		//branco automaticamente, desta forma come�amos a inserir novas linhas a partir da 2� vez

		If nI > 1

			// Incluimos uma nova linha de item

			If  ( nItErro := oAux:AddLine() ) <> nI

				// Se por algum motivo o metodo AddLine() n�o consegue incluir a linha,
				// ele retorna a quantidade de linhas j�
				// existem no grid. Se conseguir retorna a quantidade mais 1
				lRet    := .F.
				Exit

			EndIf

		EndIf

		For nJ := 1 To Len( aCpoDetail[nI] )

		// Verifica se os campos passados existem na estrutura de item
			If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) ==  AllTrim( aCpoDetail[nI][nJ][1] ) } ) ) > 0

				If !( lAux := oModel:SetValue( cDetail + 'DETAIL', aCpoDetail[nI][nJ][1], aCpoDetail[nI][nJ][2] ) )

					// Caso a atribui��o n�o possa ser feita, por algum motivo (valida��o, por exemplo)
					// o m�todo SetValue retorna .F.
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

	// Faz-se a valida��o dos dados, note que diferentemente das tradicionais "rotinas autom�ticas"
	// neste momento os dados n�o s�o gravados, s�o somente validados.
	If ( lRet := oModel:VldData() )

		// Se o dados foram validados faz-se a grava��o efetiva dos dados (commit)
		lRet := oModel:CommitData()

	EndIf
EndIf

If !lRet

	// Se os dados n�o foram validados obtemos a descri��o do erro para gerar LOG ou mensagem de aviso
	aErro   := oModel:GetErrorMessage()

	// A estrutura do vetor com erro �:
	//  [1] Id do formul�rio de origem
	//  [2] Id do campo de origem
	//  [3] Id do formul�rio de erro
	//  [4] Id do campo de erro
	//  [5] Id do erro
	//  [6] mensagem do erro
	//  [7] mensagem da solu��o
	//  [8] Valor atribuido
	//  [9] Valor anterior

	AutoGrLog( "Id do formul�rio de origem:" + ' [' + AllToChar( aErro[1]  ) + ']' )
	AutoGrLog( "Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']' )
	AutoGrLog( "Id do formul�rio de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']' )
	AutoGrLog( "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']' )
	AutoGrLog( "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']' )
	AutoGrLog( "Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']' )
	AutoGrLog( "Mensagem da solu��o:       " + ' [' + AllToChar( aErro[7]  ) + ']' )
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