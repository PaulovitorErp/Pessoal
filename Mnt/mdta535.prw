#INCLUDE "MDTA535.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA535()
Geracao da Programacao de Vacinação.

@param
@sample MDTA535()
@return .T.
@author Andre E. Perez Alvarez - Refeito por: Gabriel Gustavo de Mora
@since 14/02/07 - Revisão: 01/04/2016
/*/
//---------------------------------------------------------------------
Function MDTA535( aRotAuto , nOpcAuto , lFontPS )

	Local nSizeSA1 := 0
	Local nSizeLo1 := 0

	Local oBrowse
	Local lReturn	:= .T.

	Private lSigaMdtPS := If( SuperGetMv("MV_MDTPS",.F.,"N") == "S", .T. , .F. )
	Private lAuto	:= !Empty( aRotAuto )
	Private aRecnos := {} //Array com os recnos incluídos ou alterados durante o processo de reprogramação
	Private lReprog
	Private cCliMdtPs
	Private cPrograma

	Default lFontPS := IsInCallStack("MDTA535PS")

	// Seta visualização de versão para tecla F9
	SetKey( VK_F9, { | | NGVersao( "MDTA535" ,  ) } )

	If lAuto
		If lSigaMdtPS
			lReturn := .F.
		Else
			aRotina := MenuDef()
			FwMVCRotAuto( ModelDef() , "TLE" , nOpcAuto , { { "TLEMASTER" , aRotAuto } } )
		EndIf
	Else
		If !fValExeRot( lFontPS )
			//Instância da classe de Browse
			oBrowse := FWMBrowse():New()

				oBrowse:SetAlias( "TLE" )			//Alias da tabela utilizada pela rotina
				oBrowse:SetMenuDef( "MDTA535" ) 	//Nome do fonte onde se encontra o MenuDef
				oBrowse:SetDescription ( STR0001 )	//"Geracao de Programação para Vacinação"

				If lSigaMdtPs
					nSizeSA1 := If((TAMSX3("A1_COD")[1]) < 1,6,(TAMSX3("A1_COD")[1]))
					nSizeLo1 := If((TAMSX3("A1_LOJA")[1]) < 1,2,(TAMSX3("A1_LOJA")[1]))

					cCliMdtPs := SA1->A1_COD+SA1->A1_LOJA

					oBrowse:SetFilterDefault( "TLE->(TLE_CLIENT + TLE_LOJA) == cCliMdtps" )
				EndIf
			oBrowse:Activate()
		EndIf
	EndIf
	// Seta visualização de versão para tecla F9
	SetKey( VK_F9, { | |  } )

Return lReturn
//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do Menu (padrão MVC)
@param
@sample MenuDef()
@return aRotina
@author Gabriel Gustavo de Mora
@since 01/04/2016
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE "Pesquisar" 	ACTION "AxPesqui" 		 OPERATION 1 ACCESS 0 //Pesquisar
	ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.MDTA535" OPERATION 2 ACCESS 0 //Visualizar
	ADD OPTION aRotina TITLE "Incluir" 		ACTION "VIEWDEF.MDTA535" OPERATION 3 ACCESS 0 //Incluir
	ADD OPTION aRotina TITLE "Reprogramar" 	ACTION "VIEWDEF.MDTA535" OPERATION 4 ACCESS 0 //Reprogramar
	ADD OPTION aRotina TITLE "Excluir" 		ACTION "VIEWDEF.MDTA535" OPERATION 5 ACCESS 0 //Excluir

Return aRotina
//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do Modelo (padrão MVC)

@param
@sample ModelDef()
@return oModel
@author Gabriel Gustavo de Mora
@since 01/04/2016
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	//Cria estrutura usada no Modelo de Dados
	Local oStructTLE := FWFormStruct( 1 , "TLE" ) //1 - Modelo de Dados

	//Modelo de dados a ser criado
	Local oModel

	//Cria objeto do modelo de dados
	oModel := MPFormModel():New( "MDTA535" , { | oModel | fMPreValid( oModel ) } , { | oModel | fMPosValid( oModel ) } , { | oModel | fMCommit( oModel ) } , /*bCancel*/ )

		//Adiciona ao Modelo um componente de Formulário Principal
		oModel:AddFields( "TLEMASTER" , Nil , oStructTLE , /*bPre*/ , /*bPost*/ , /*bLoad*/ )

			oModel:SetDescription( STR0001 )	//"Geracao de Programação para Vacinação"

			oModel:GetModel( "TLEMASTER" ):SetDescription( STR0001 )	//"Geracao de Programação para Vacinação"

			oModel:SetPrimaryKey( { "TLE_FILIAL" , "TLE_NUMCON" } )

Return oModel
//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da View (padrão MVC)

@param
@sample ViewDef()
@return oView
@author Gabriel Gustavo de Mora
@since 01/04/2016
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	//Carrega objeto de Modelo baseado no ModelDef()
	Local oModel := FWLoadModel( "MDTA535" )

	//Cria estrutura usada na View
	Local oStructTLE := FWFormStruct( 2 , "TLE" ) //2 - Interface de visualização

	//Interface de visualização construída
	Local oView

	//Cria objeto da View
	oView := FWFormView():New()

		//Associação do objeto Model a View
		oView:SetModel( oModel )

		//Adiciona controle do tipo formulário
		oView:AddField( "VIEW_TLE" , oStructTLE , "TLEMASTER" )

			//Adiciona titulo ao formulário
			oView:EnableTitleView( "VIEW_TLE" , STR0001 )	//"Geracao de Programação para Vacinação"

			//Criação de box horizontais
			oView:CreateHorizontalBox( "TELATLE" , 100 , /*cIdOwner*/ , /*lFixPixel*/ , /*cIDFolder*/ , /*cIDSheet*/ )

		//Associa a View a um box
		oView:SetOwnerView( "VIEW_TLE" , "TELATLE" )

Return oView
//---------------------------------------------------------------------
/*/{Protheus.doc} fMPreValid()
Pré_validações do Modelo de Dados (padrão MVC)

@param
@sample fMPreValid(oModel)
@return Lógico - .T. se as validações estiverem verdadeiras
@author Gabriel Gustavo de Mora
@since 01/04/2016
/*/
//---------------------------------------------------------------------
Static Function fMPreValid( oModel )

	Local lRet			:= .T.

	Local nOperation	:= oModel:GetOperation() 			// Operação de ação sobre o Modelo
	Local oModelTLE		:= oModel:GetModel( "TLEMASTER" )	//Modelo a ser usado

	If SuperGetMV("MV_NG2SEG",.F.,"2") == "1" .AND. !(SuperGetMV("MV_MDTPS",.F.,"N") == "S")
		oModel:SetValue( "TLEMASTER" , "TLE_CODRES" , MDTUSRLOG() )
		oModel:SetValue( "TLEMASTER" , "TLE_NOMRES" , MDTUSRLOG(2) )
	Endif

	If nOperation == MODEL_OPERATION_UPDATE //Reprogramar
		lReprog := .T.
		//Evita que a mensagem de update seja apresentada na reprogramação
		oModel:lModify := .T.
	Else
		lReprog := .F.
	EndIf

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fMPosValid()
Pós_validações do Modelo de Dados (padrão MVC)

@param
@sample fMPosValid(oModel)
@return Lógico - .T. se as validações estiverem verdadeiras
@author Gabriel Gustavo de Mora
@since 01/04/2016
/*/
//---------------------------------------------------------------------
Static Function fMPosValid( oModel )

	Local lRet			:= .T.
	Local lVacRealizada := .F.
	Local aAreaTLE		:= TLE->( GetArea() )

	Local nOperation	:= oModel:GetOperation() 			// Operação de ação sobre o Modelo
	Local oModelTLE		:= oModel:GetModel( "TLEMASTER" )	//Modelo a ser usado

	Private aCHKSQL 	:= {} // Variável para consistência na exclusão (via SX9)
	Private aCHKDEL 	:= {} // Variável para consistência na exclusão (via Cadastro)

	// Recebe SX9 - Formato:
	// 1 - Domínio (tabela)
	// 2 - Campo do Domínio
	// 3 - Contra-Domínio (tabela)
	// 4 - Campo do Contra-Domínio
	// 5 - Condição SQL
	// 6 - Comparação da Filial do Domínio
	// 7 - Comparação da Filial do Contra-Domínio
	aCHKSQL := NGRETSX9( "TLE" )

	If nOperation == MODEL_OPERATION_DELETE //Exclusão

		If !NGCHKDEL( "TLE" )
			lRet := .F.
		EndIf

		If lRet .And. !NGVALSX9( "TLE" , { "TL9" } , .T. , .T. )
			lRet := .F.
		EndIf

		If lRet
			//Verifica se alguma vacina está realizada
			If fDelVac( .T. )
				If lAuto .Or. Msgyesno(STR0006+chr(13)+chr(13)+; //"Foi encontrada pelo menos uma vacinação realizada associada a esta programação."
								STR0007+chr(13)+chr(13)+; //"Por isto, esta programação não será deletada."
								STR0008) //"Deseja excluir as vacinações que ainda não foram realizadas?"
					//Executa o DELETE
					fDelVac()
					Help( " " , 1 , "PRGVACEXA" , , STR0014 , 4 , 5 ) //"Operação de exclusão efetuada com sucesso."
				Else
					Help( " " , 1 , "PRGVACEXA" , , STR0015 , 4 , 5) //"Esta Programação não pode ser excluída, já possui vacinas realizadas."
				EndIf
				lRet := .F.
			Else
				fDelVac()
			EndIf
		EndIf
	EndIf

	RestArea( aAreaTLE )

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fDelVac()
Função para exclusão de vacinas.

@param lValid
@sample fDelVac(lValid)
@return Lógico
@author Gabriel Gustavo de Mora
@since 05/04/2016
/*/
//---------------------------------------------------------------------
Static Function fDelVac( lValid )

	Local lRet := .F.

	Default lValid := .F.

	dbSelectArea("TL9")
	dbSetOrder(5)
	dbSeek(xFilial("TL9")+TLE->TLE_NUMCON)
	While TL9->( !Eof() ) .And. xFilial( "TL9" )+TLE->TLE_NUMCON == TL9->TL9_FILIAL+TL9->TL9_NUMCON

		If lValid
			lRet := !Empty(TL9->TL9_DTREAL)
			If lRet
				Exit
			EndIf
		Else
			If Empty(TL9->TL9_DTREAL)
				RecLock("TL9",.F.)
				TL9->( dbDelete() )
				TL9->( MsUnlock() )
			EndIf
		EndIf
		TL9->( dbSkip() )
	End

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fMCommit()
Função de persistência dos dados.

@param
@sample fMCommit()
@return Lógico
@author Gabriel Gustavo de Mora
@since 05/04/2016
/*/
//---------------------------------------------------------------------
Static Function fMCommit( oModel )

	Local nOperation	:= oModel:GetOperation() // Operação de ação sobre o Modelo

	FWFormCommit( oModel )

	// Faz a geração da Programação de Vacinas quando for Inclusao ou Reprogramação
	If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE
		If !lAuto
			Processa( { | lEnd | MDT535PRIN( If( nOperation == MODEL_OPERATION_INSERT , 1 , 3 ),,,oModel ) } ) // MONTA TELA PARA ACOMPANHAMENTO DO PROCESSO.
		Else
			MDT535PRIN( If( nOperation == MODEL_OPERATION_INSERT , 1 , 3 ) )
		EndIf
	EndIf

Return .T.


Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fValExeRot()
Função de verificação da permissão de acesso a rotina e, em caso de
prestador, verifica se foi realizada a chamada pelo fonte MDTA535PS.

@param lFontPS - Indica se função foi chamada pelo fonte do prestador
@sample fValExeRot(lFontPS)
@return Lógico
@author Gabriel Gustavo de Mora
@since 04/04/2016
/*/
//---------------------------------------------------------------------
Static Function fValExeRot( lFontPS )
	Local lIncons := .F.

	//Verifica se usuario de acesso tem permissão para a execução.
	If FindFunction("MDTRESTRI") .And. !MDTRESTRI(cPrograma)
		lIncons := .T.
	EndIf

	If !lIncons .And. lSigaMDTPS .And. !lFontPS .AND. !lAuto
		ShowHelpDlg( 	"NOCALLPS" , ;
		{ STR0009 } , 1 , ; //"Função incorreta."
		{ STR0010 + ; //"Faz se necessário a alteração do Menu. A rotina 'Exames por Risco' deverá chamar o programa MDTA535PS."
		STR0011 } , 3 )//"Favor contate administrador de sistemas"
		lIncons := .T.
	EndIf

Return lIncons
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT535PRIN()
Funcao principal que chama as funcoes para gerar a programacao de vacinacao.

@param
@sample MDT535PRIN()
@return Lógico
@author Andre E. Perez Alvarez
@since 14/02/07
/*/
//---------------------------------------------------------------------
Function MDT535PRIN()

	Local cChave     := ""
	Local cFiltro	 := ""
	Local lDep       := .F.
	Local nIndTM0    := 1
	Local nIndTL7    := 2
	Local nIndTL6    := 1
	Local nIndTKF    := 1
	Local nIndTKG    := 1
	Local nIndTKH    := 1
	Local cSeekTM0   := "xFilial('TM0')"
	Local cSeekTL6   := "xFilial('TL6')+TL7->TL7_VACINA"
	Local cSeekTKF   := "xFilial('TKF')+TL7->TL7_VACINA+SRA->RA_CC"
	Local cSeekTKG   := "xFilial('TKG')+TL7->TL7_VACINA+SRA->RA_CODFUNC"
	Local cSeekTKH   := "xFilial('TKH')+TL7->TL7_VACINA+SRA->RA_MAT"
	Local cWhileTM0  := "TM0->TM0_FILIAL"

	Private dULTIMAREAL //Data da ultima vacinacao aplicada
	Private cDose


	If lSigaMdtPs
		nIndTL7    := 5
		nIndTKF    := 2
		nIndTKG    := 2
		nIndTKH    := 2
		nIndTL6    := 3
		nIndTM0    := 8
		cSeekTM0   := "xFilial('TM0')+cCliMdtps"
		cSeekTL6   := "xFilial('TL6')+cCliMdtPs+TL7->TL7_VACINA"
		cSeekTKF   := "xFilial('TKF')+cCliMdtPs+TL7->TL7_VACINA+SRA->RA_CC"
		cSeekTKG   := "xFilial('TKG')+cCliMdtPs+TL7->TL7_VACINA+SRA->RA_CODFUNC"
		cSeekTKH   := "xFilial('TKH')+cCliMdtPs+TL7->TL7_VACINA+SRA->RA_MAT"
		cWhileTM0  := "TM0->TM0_FILIAL+TM0->(TM0_CLIENT+TM0_LOJA)"
	Endif

	dbSelectArea("TM0")
	dbSetorder(nIndTM0)
	dbSeek(&(cSeekTM0)) //TM0_FILIAL+TM0_NUMFIC ## TM0_FILIAL+TM0_CLIENT+TM0_LOJA+TM0_NUMFIC
	ProcRegua(RecCount())
	While !Eof() .AND. 	&(cSeekTM0) == &(cWhileTM0)
		aRecnos := {}
		lDep    := .F.
		IncProc()

		dbSelectArea("SRA")
		dbSetOrder(1)
		If !dbSeek( TM0->TM0_FILFUN + TM0->TM0_MAT )
			dbSelectArea("TM0")
			dbSkip()
			Loop
		Endif

		If SRA->RA_SITFOLH == "D" .OR. !Empty(SRA->RA_DEMISSA)
			DelVacProg(TM0->TM0_NUMFIC, TLE->TLE_DTINI, TLE->TLE_DTFIM)
			dbSelectArea("TM0")
			dbSkip()
			Loop
		Endif

		If !Empty(TM0->TM0_NUMDEP)
			dbSelectArea("SRB")
			dbSetOrder(1)
			If dbSeek( SRA->RA_FILIAL + SRA->RA_MAT )
				While !Eof() .And. SRA->RA_FILIAL == SRB->RB_FILIAL .And. SRA->RA_MAT == SRB->RB_MAT
					If SRB->RB_COD == TM0->TM0_NUMDEP
						lDep := .T.
						Exit
					Endif
					dbSkip()
				End
			EndIf
			If !lDep
				dbSelectArea("TM0")
				dbSkip()
				Loop
			EndIf
		EndIf

		cIdade := Substr(Alltrim(STR(MDT535IDA(lDep))), 1, 3)

		//---------------------------------------------------------------------------
		// Filtra os registros do Calendario de Vacinacao
		// Verifica as vacinas existentes para a faixa etaria do funcionario
		//---------------------------------------------------------------------------

		dbSelectArea("TL7")
		dbSetorder(nIndTL7)  //TL7_FILIAL + TL7_IDADEI ## TL7_FILIAL+TL7_CLIENT+TL7_LOJA+TL7_IDADEI)
		cFiltro := 'TL7->TL7_FILIAL =="' + xFilial("TL7")  + '".And.'
		If lSigaMdtPs
			cFiltro += 'TL7->TL7_CLIENT+TL7->TL7_LOJA =="' + cCliMdtps + '".And.'
		Endif
		cFiltro += 'Val(TL7->TL7_IDADEI) <= ' + cIdade + '.And.'
		cFiltro += 'Val(TL7->TL7_IDADEF) >= ' + cIdade

		Set Filter To &( cFiltro )

		dbGoTop()
		While !Eof()
			If NGCADICBASE("TL6_SEXO","A","TL6",.F.) .And. NGCADICBASE("TL6_CC","A","TL6",.F.) .And. NGCADICBASE("TL6_FUNC","A","TL6",.F.) .And. NGCADICBASE("TL6_FNCR","A","TL6",.F.)
				dbSelectArea("TL6")
				dbSetOrder(nIndTL6)
				If dbSeek(&(cSeekTL6))
					If AllTrim(TL6->TL6_SEXO) == "1"
						cSexo := "M"
					Elseif AllTrim(TL6->TL6_SEXO) == "2"
						cSexo := "F"
					Else
						cSexo := "A"
					Endif
					If lDep
						dbSelectArea("SRB")
						If SRB->RB_SEXO == cSexo .Or. AllTrim(TL6->TL6_SEXO) == "3"
							If  AllTrim(TL6->TL6_CC) <> "2" .OR. AllTrim(TL6->TL6_FUNC) <> "2" .OR. AllTrim(TL6->TL6_FNCR) <> "2"
								dbSelectArea("TL7")
								dbSkip()
								Loop
							Endif
						Else
							dbSelectArea("TL7")
							dbSkip()
							Loop
						EndIf
					Else
						dbSelectArea("SRA")
						If SRA->RA_SEXO == cSexo .Or. AllTrim(TL6->TL6_SEXO) == "3"
							If  AllTrim(TL6->TL6_CC) == "1"
								dbSelectArea("TKF")
								dbSetOrder(nIndTKF)
								If !dbSeek(&(cSeekTKF))
									dbSelectArea("TL7")
									dbSkip()
									Loop
								Endif
							Endif
							If	AllTrim(TL6->TL6_FUNC) == "1"
								dbSelectArea("TKG")
								dbSetOrder(nIndTKG)
								If !dbSeek(&(cSeekTKG))
									dbSelectArea("TL7")
									dbSkip()
									Loop
								Endif
							Endif
							If	AllTrim(TL6->TL6_FNCR) == "1"
								dbSelectArea("TKH")
								dbSetOrder(nIndTKH)
								If !dbSeek(&(cSeekTKH))
									dbSelectArea("TL7")
									dbSkip()
									Loop
								Endif
							Endif
						Else
							dbSelectArea("TL7")
							dbSkip()
							Loop
						Endif
					EndIf
				Endif
			Endif
			//Busca a data da ultima aplicacao da vacina
			UltimaVac()

			If ValType(dULTIMAREAL)=="D"  //Se esta vacina foi aplicada anteriormente ao funcionario
				MDT535CALC(.T.)
			Else
				MDT535CALC(.F.)
			Endif
			dULTIMAREAL := NIL
			cDose := ""
			dbSelectArea("TL7")
			dbSkip()
		End

		dbSelectArea("TL7")
		Set Filter To
		DelVacProg(TM0->TM0_NUMFIC, TLE->TLE_DTINI, TLE->TLE_DTFIM,aRecnos)

		dbSelectArea("TM0")
		dbSkip()
	End
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} UltimaVac()
Busca a data da ultima aplicacao da vacina.

@param
@sample UltimaVac()
@return Lógico
@author Andre E. Perez Alvarez
@since 14/02/07
/*/
//---------------------------------------------------------------------
Static Function UltimaVac()

	Local cAliTL9 := GetNextAlias()

	BeginSQL Alias cAliTL9

		SELECT TL9.TL9_DTREAL, TL9.TL9_DOSE
			FROM %table:TL9% TL9
		WHERE TL9.TL9_FILIAL = %xFilial:TL9% AND
			TL9.TL9_NUMFIC = %exp:TM0->TM0_NUMFIC% AND
			TL9.TL9_VACINA = %exp:TL7->TL7_VACINA% AND
			TL9.TL9_DTREAL != ''
		ORDER BY TL9.TL9_DTREAL DESC

	EndSql

	dbSelectArea( cAliTL9 )
	If ( cAliTL9 )->( !EoF() )
		dULTIMAREAL := ( cAliTL9 )->TL9_DTREAL
		cDose := ( cAliTL9 )->TL9_DOSE
	EndIf

	( cAliTL9 )->( dbCloseArea() )

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT535CALC()
Calcula as datas para a Geracao de Programacao de Vacinacao.

@param
@sample MDT535CALC()
@return Lógico
@author Andre E. Perez Alvarez
@since 14/02/07
/*/
//---------------------------------------------------------------------
Static Function MDT535CALC(lAplicada)

	Local lFirst    := .T. //Para uma dose, indica se eh a 1a. PROGRAMACAO dela
	Local dDataPrev
	Local lPrin     := .T.  //Indica se eh a 1a. DOSE
	Local nIndTL8   := 1
	Local cSeekTL8  := xFilial("TL8") + TL7->TL7_VACINA + TL7->TL7_IDADEI
	Local cWhileTL8 := "TL8->TL8_FILIAL+TL8->TL8_VACINA+TL8->TL8_IDADEI"
	Local cAliTL9

	Private nQuanti := 0  //Quantidade de Vacinas

	If lSigaMdtps
		nIndTL8   := 4
		cSeekTL8  := xFilial("TL8") + cCliMdtps + TL7->TL7_VACINA + TL7->TL7_IDADEI
		cWhileTL8 := "TL8->TL8_FILIAL+cCliMdtps+TL8->TL8_VACINA+TL8->TL8_IDADEI"
	Endif

	If !lAplicada //Se a vacina nao foi aplicada anteriormente ao funcionario
		dDataPrev := TLE->TLE_DTINI
		cWhile := "!Eof() .And. &(cWhileTL8) == cSeekTL8"
	Else
		dDataPrev := dULTIMAREAL
		cWhile := "( cSeekTL8 ) == &(cWhileTL8)"
	EndIf

	//---------------------------------------------
	// Busca as doses do calendario de vacinacao
	//---------------------------------------------
	dbSelectArea("TL8")
	dbSetOrder(nIndTL8) //TL8_FILIAL+TL8_VACINA+TL8_IDADEI+TL8_DOSEID ## TL8_FILIAL+TL8_CLIENT+TL8_LOJA+TL8_VACINA+TL8_IDADEI+TL8_DOSEID
	dbSeek( cSeekTL8 )

	If !lAplicada //Se a vacina nao foi aplicada anteriormente ao funcionario
		While &cWhile
			If TL8_REPETI == "1"  //Se a dose eh com repeticao
				While .T.
					If !lFirst
						dDataRef := TL8->TL8_PERIOD
						cUnidRef := TL8->TL8_UNIDA1
					Else
						If !lPrin .AND. !Empty(TL8->TL8_INIDOS)
							dDataRef := TL8->TL8_INIDOS
							cUnidRef := TL8->TL8_UNIDA2
						EndIf
					EndIf
					If !lFirst .OR. (!lPrin .AND. !Empty(TL8->TL8_INIDOS))
						Do Case
							Case cUnidRef == "1" //Dia
							dDataPrev := dDataPrev + dDataRef
							Case cUnidRef == "2" //Semana
							dDataPrev := dDataPrev + (dDataRef * 7)
							Case cUnidRef == "3" //Mes
							dDataPrev := NGSomaMes(dDataPrev, dDataRef)
							Case cUnidRef == "4" //Ano
							dDataPrev := NGSomaAno(dDataPrev, dDataRef)
						EndCase
					EndIf

					If (dDataPrev > TLE->TLE_DTFIM) .OR. (dDataPrev < TLE->TLE_DTINI)
						Exit
					Endif
					MDT535GERA(dDataPrev)
					lFirst := .F.
				End
			Else
				//Se a dose eh sem repeticao
				dbSelectArea("TL9")
				dbSetOrder(2)  //TL9_FILIAL + TL9_NUMFIC + TL9_VACINA + DTOS(TL9_DTPREV)

				lAchouDose := .F.
				If Dbseek(xFilial("TL9")+TM0->TM0_NUMFIC+TL7->TL7_VACINA)
					cAliTL9 := GetNextAlias()
					BeginSQL Alias cAliTL9

						SELECT R_E_C_N_O_
							FROM %table:TL9% TL9
						WHERE TL9.TL9_FILIAL = %xFilial:TL9% AND
							TL9.TL9_NUMFIC = %exp:TM0->TM0_NUMFIC% AND
							TL9.TL9_VACINA = %exp:TL7->TL7_VACINA% AND
							TL9.TL9_DOSE = %exp:TL8->TL8_DOSEID% AND
							TL9.TL9_DTREAL != ''

					EndSql

					dbSelectArea( cAliTL9 )
					While ( cAliTL9 )->( !EoF() )
						aAdd(aRecnos,TL9->(RECNO()))
						lAchouDose := .T.
						( cAliTL9 )->( dbSkip() )
					EndDo

					( cAliTL9 )->( dbCloseArea() )
				EndIf

				If lAchouDose
					lFirst := .T.
					lPrin := .F.
					dbSelectArea("TL9")
					Set Filter To
					dbSelectArea("TL8")
					dbSkip()
					Loop
				Endif

				If !lPrin .AND. !Empty(TL8->TL8_INIDOS)  //Se for da segunda dose em diante
					Do Case
						Case TL8->TL8_UNIDA2 == "1" //Dia
						dDataPrev := dDataPrev + TL8->TL8_INIDOS
						Case TL8->TL8_UNIDA2 == "2" //Semana
						dDataPrev := dDataPrev + (TL8->TL8_INIDOS * 7)
						Case TL8->TL8_UNIDA2 == "3" //Mes
						dDataPrev := NGSomaMes(dDataPrev, TL8->TL8_INIDOS)
						Case TL8->TL8_UNIDA2 == "4" //Ano
						dDataPrev := NGSomaAno(dDataPrev, TL8->TL8_INIDOS)
					EndCase
				Endif
				MDT535GERA(dDataPrev)

			Endif

			lFirst := .T.
			lPrin := .F.
			dbSelectArea("TL8")
			dbSkip()
		End
	Else //Se a vacina foi aplicada anteriormente ao funcionario
		While &cWhile

			dbSelectArea("TL9")
			dbSetOrder(2)  //TL9_FILIAL + TL9_NUMFIC + TL9_VACINA + DTOS(TL9_DTPREV)

			lAchouDose := .F.
			If Dbseek(xFilial("TL9")+TM0->TM0_NUMFIC+TL7->TL7_VACINA)
				cAliTL9 := GetNextAlias()
				BeginSQL Alias cAliTL9

					SELECT R_E_C_N_O_
						FROM %table:TL9% TL9
					WHERE TL9.TL9_FILIAL = %xFilial:TL9% AND
						TL9.TL9_NUMFIC = %exp:TM0->TM0_NUMFIC% AND
						TL9.TL9_VACINA = %exp:TL7->TL7_VACINA% AND
						TL9.TL9_DOSE = %exp:TL8->TL8_DOSEID% AND
						TL9.TL9_DTREAL != ''

				EndSql

				dbSelectArea( cAliTL9 )
				While ( cAliTL9 )->( !EoF() )
					aAdd(aRecnos,TL9->(RECNO()))
					lAchouDose := .T.
					( cAliTL9 )->( dbSkip() )
				EndDo

				( cAliTL9 )->( dbCloseArea() )
			EndIf

			If TL8->TL8_REPETI == "1"  //Se a dose eh com repeticao
				While .T.
					If lFirst .And. !lAchouDose .And. !Empty(TL8->TL8_INIDOS)
						dDataRef := TL8->TL8_INIDOS
						cUnidRef := TL8->TL8_UNIDA2
					Else
						dDataRef := TL8->TL8_PERIOD
						cUnidRef := TL8->TL8_UNIDA1
					EndIf
					Do Case
						Case cUnidRef == "1" //Dia
						dDataPrev := dDataPrev + dDataRef
						Case cUnidRef == "2" //Semana
						dDataPrev := dDataPrev + (dDataRef * 7)
						Case cUnidRef == "3" //Mes
						dDataPrev := NGSomaMes(dDataPrev, dDataRef)
						Case cUnidRef == "4" //Ano
						dDataPrev := NGSomaAno(dDataPrev, dDataRef)
					EndCase

					lFirst := .F.
					If (dDataPrev < TLE->TLE_DTINI)
						dDataPrev := TLE->TLE_DTINI
						MDT535GERA(dDataPrev)
						Loop
					Endif
					If (dDataPrev > TLE->TLE_DTFIM)
						Exit
					Endif
					MDT535GERA(dDataPrev)
				End
			Else
				If lAchouDose //Se a dose ja foi programada ou aplicada, não programa novamente.
					lFirst := .T.
					dDataPrev := dULTIMAREAL

					dbSelectArea("TL9")
					Set Filter To
					dbSelectArea("TL8")
					dbSkip()
					Loop
				Endif

				If !Empty(TL8->TL8_INIDOS)
					Do Case
						Case TL8->TL8_UNIDA2 == "1" //Dia
						dDataPrev := dDataPrev + TL8->TL8_INIDOS
						Case TL8->TL8_UNIDA2 == "2" //Semana
						dDataPrev := dDataPrev + (TL8->TL8_INIDOS * 7)
						Case TL8->TL8_UNIDA2 == "3" //Mes
						dDataPrev := NGSomaMes(dDataPrev, TL8->TL8_INIDOS)
						Case TL8->TL8_UNIDA2 == "4" //Ano
						dDataPrev := NGSomaAno(dDataPrev, TL8->TL8_INIDOS)
					EndCase
				Endif
				If (dDataPrev < TLE->TLE_DTINI)
					dDataPrev := TLE->TLE_DTINI
					MDT535GERA(dDataPrev)
				ElseIf (dDataPrev <= TLE->TLE_DTFIM)
					MDT535GERA(dDataPrev)
				Endif
			Endif

			lFirst := .T.

			dbSelectArea("TL8")
			dbSkip()
		End
	EndIf

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT535GERA()
 Gera a Programacao de Vacinacao.

@param
@sample MDT535GERA()
@return Lógico
@author Andre E. Perez Alvarez
@since 14/02/07
/*/
//---------------------------------------------------------------------
Static Function MDT535GERA(dDataPrev)

	Local cFilTL9 := xFilial("TL9")

	dbSelectArea("TL9")
	dbSetOrder(1)
	If !dbSeek( cFilTL9 + TM0->TM0_NUMFIC + DtoS(dDataPrev) + TL7->TL7_VACINA )
		RecLock("TL9", .T.)
		TL9->TL9_FILIAL := cFilTL9
		TL9->TL9_NUMFIC := TM0->TM0_NUMFIC
		TL9->TL9_VACINA := TL7->TL7_VACINA
		TL9->TL9_DTPREV := dDataPrev
		TL9->TL9_NUMCON := TLE->TLE_NUMCON
		TL9->TL9_DOSE   := TL8->TL8_DOSEID
		MsUnLock("TL9")
	Else
		If Val(TLE->TLE_NUMCON) >= Val(TL9->TL9_NUMCON)
			RecLock("TL9", .F.)
			TL9->TL9_NUMCON := TLE->TLE_NUMCON
			TL9->TL9_DOSE   := TL8->TL8_DOSEID
			MsUnLock("TL9")
		Endif
	Endif
	aAdd(aRecnos,TL9->(RECNO()))

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT535IDA()
Calcula a idade do funcionario.

@param
@sample MDT535IDA()
@return Númerico - nIdade
@author Andre E. Perez Alvarez
@since 14/02/07
/*/
//---------------------------------------------------------------------
Static Function MDT535IDA(lDep)

	Local nAnoAtu
	Local nMesAtu
	Local nAnoNas
	Local nMesNas
	Local nDifMes
	Local nIdade

	nAnoAtu :=  year(DATE())
	nMesAtu :=  month(DATE())
	If lDep
		dbSelectArea("SRB")
		nAnoNas :=  year(SRB->RB_DTNASC)
		nMesNas :=  month(SRB->RB_DTNASC)
	Else
		dbSelectArea("SRA")
		nAnoNas :=  year(SRA->RA_NASC)
		nMesNas :=  month(SRA->RA_NASC)
	Endif
	nDifMes :=  nMesNas - nMesAtu
	IF nDifMes > 6
		nIDADE := (nAnoAtu - nAnoNas) - 1
	ELSE
		nIdade := (nAnoAtu - nAnoNas)
	ENDIF

Return nIdade
//---------------------------------------------------------------------
/*/{Protheus.doc} DelVacProg()
Deleta as vacinas programadas para o período.

@param
@sample DelVacProg()
@return Lógico - lRet
@author Jackson Machado
@since 27/01/12
/*/
//---------------------------------------------------------------------
Static Function DelVacProg(cTM0_NUMFIC, dDtIniTLE, dDtFimTLE, aRec)

	Local lRet := .f.
	Local aAreaXXX := GetArea()
	Local aAreaTL9 := TL9->(GetArea())

	dbSelectArea("TL9")
	dbSetOrder(1)
	dbSeek(xFilial("TL9")+cTM0_NUMFIC)
	While !Eof() .and. xFilial("TL9")+cTM0_NUMFIC == TL9->TL9_FILIAL+TL9->TL9_NUMFIC
		If !Empty(TL9->TL9_NUMCON) .and. TL9->TL9_DTPREV >= dDtIniTLE .and. TL9->TL9_DTPREV <= dDtFimTLE .and. Empty(TL9->TL9_DTREAL)
			If ValType(aRec) == "A"
				If aScan( aRec, { |x| x == TL9->(RECNO()) } ) > 0
					dbSelectArea("TL9")
					dbSkip()
					Loop
				Endif
			Endif
			RecLock("TL9",.F.)
			dbDelete()
			MsUnLock("TL9")
		Endif
		dbSkip()
	End

	RestArea(aAreaTL9)
	RestArea(aAreaXXX)

Return lRet