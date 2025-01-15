/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � EXERC007 �Autor �Tarc�sio Silva Miranda� Data�  19/03/2014 ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina autom�tica do MVC para cadastro de Alunos.		  ���
���          � 			                                                  ���
�������������������������������������������������������������������������͹��
���Uso       � TREINAMENTO MVC                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RCOMA007(_Env_CadAluno,_Rec_CadAluno)

Local aCampos	:= {}
Local nI 		:= 0
Local nPos 		:= 0
Local lRet 		:= .T.
Local aAux 		:= {}
Local cCodZB1 	:= ""
Local oModel, oAux, oStruct

	// Criamos um vetor com os dados
	aCampos := {}
	aAdd( aCampos, { 'ZB2_FILIAL'	, _Env_CadAluno:cFil 			} )
	aAdd( aCampos, { 'ZB2_RA' 		, _Env_CadAluno:cRa  			} )
	aAdd( aCampos, { 'ZB2_NOME' 	, _Env_CadAluno:cNome  			} )
	aAdd( aCampos, { 'ZB2_NASC' 	, cTod(_Env_CadAluno:cDtNasci)	} )
	aAdd( aCampos, { 'ZB2_SITUAC' 	, _Env_CadAluno:cSituac  		} )
	aAdd( aCampos, { 'ZB2_OK' 		, 'OK' 			 				} )
	
	// Aqui ocorre o inst�nciamento do modelo de dados (Model)
	oModel := FWLoadModel( 'RCOMA002' )
	
	// Temos que definir qual a opera��o deseja: 3 � Inclus�o / 4 � Altera��o / 5 - Exclus�o
	oModel:SetOperation( 3 )
	
	// Antes de atribuirmos os valores dos campos temos que ativar o modelo
	oModel:Activate()
	
	// Instanciamos apenas referentes �s dados
	oAux := oModel:GetModel( 'ZB2MASTER' )
	
	// Obtemos a estrutura de dados
	oStruct := oAux:GetStruct()
	aAux 	:= oStruct:GetFields()
	
	For nI := 1 To Len( aCampos )
		
		// Verifica se os campos passados existem na estrutura do modelo
		If ( nPos := aScan(aAux,{|x| AllTrim( x[3] )== AllTrim(aCampos[nI][1]) } ) ) > 0
			
			// � feita a atribui��o do dado ao campo do Model
			If !( lAux := oModel:SetValue( 'ZB2MASTER', aCampos[nI][1], aCampos[nI][2] ) )
				// Caso a atribui��o n�o possa ser feita, por algum motivo (valida��o, por
				// o m�todo SetValue retorna .F.
				lRet := .F.
				Exit
			EndIf
			
		EndIf
		
	Next nI
	
	If lRet
		
		// Faz-se a valida��o dos dados
		If ( lRet := oModel:VldData() )
			// Se o dados foram validados faz-se a grava��o efetiva dos dados (commit)
			oModel:CommitData()
		EndIf
		
	EndIf
	
	If !lRet
		
		// Se os dados n�o foram validados obtemos a descri��o do erro para gerar LOG ou mensagem de aviso
		aErro := oModel:GetErrorMessage()
		// A estrutura do vetor com erro �:
		// [1] identificador (ID) do formul�rio de origem
		// [2] identificador (ID) do campo de origem
		// [3] identificador (ID) do formul�rio de erro
		// [4] identificador (ID) do campo de erro
		// [5] identificador (ID) do erro
		// [6] mensagem do erro
		// [7] mensagem da solu��o
		// [8] Valor atribu�do
		// [9] Valor anterior
		AutoGrLog( "Id do formul�rio de origem:" + ' [' + AllToChar( aErro[1] ) + ']' )
		AutoGrLog( "Id do campo de origem: " + ' [' + AllToChar( aErro[2] ) + ']' )
		AutoGrLog( "Id do formul�rio de erro: " + ' [' + AllToChar( aErro[3] ) + ']' )
		AutoGrLog( "Id do campo de erro: " + ' [' + AllToChar( aErro[4] ) + ']' )
		AutoGrLog( "Id do erro: " + ' [' + AllToChar( aErro[5] ) + ']' )
		AutoGrLog( "Mensagem do erro: " + ' [' + AllToChar( aErro[6] ) + ']' )
		AutoGrLog( "Mensagem da solu��o: " + ' [' + AllToChar( aErro[7] ) + ']' )
		AutoGrLog( "Valor atribu�do: " + ' [' + AllToChar( aErro[8] ) + ']' )
		AutoGrLog( "Valor anterior: " + ' [' + AllToChar( aErro[9] ) + ']' )
		
		_Rec_CadAluno:lRet 		:= .F.
		_Rec_CadAluno:cMensagem := "Falha na inclus�o !"+MostraErro("\temp")
	
	Else
	
		_Rec_CadAluno:lRet 		:= .T.
		_Rec_CadAluno:cMensagem := "Cadastro efetuado com sucesso!"
	
	EndIf
	
	// Desativamos o Model
	oModel:DeActivate()

Return()