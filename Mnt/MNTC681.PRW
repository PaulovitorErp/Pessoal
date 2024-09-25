#Include "MNTC681.ch"
#Include "PROTHEUS.CH"
#Include "FWBROWSE.CH"
#Include "RWMAKE.CH"

#Define _nVersao 001	//Versao do Fonte

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTC681
Consulta de Planejamentos de Mobilizacao e Desmobilizacao de Equipamentos (Bens).

@author Wagner S. de Lacerda
@since 08/08/2011
@return 
/*/
//---------------------------------------------------------------------
Function MNTC681()

	Local aNGBEGINPRM := NGBEGINPRM(_nVersao)

	Private aRotina	:= aClone( MenuDef() )
	Private aSize		:= MsAdvSize()
	
	Private cCadastro	:= OemToAnsi(STR0001) //"Consulta de Histórico de Desmobilização"
	Private cPrograma	:= "MNTC681"
	Private cPerg		:= "MNTC681"
	Private cGrupo	:= ""
	
	Private nLargura	:= 0
	Private nAltura	:= 0

	If !MntCheckCC(cPrograma)
		Return .F.
	EndIf

	//Define Altura e Largura
	If !(Alltrim( GetTheme() ) == "FLAT") .And. !SetMdiChild()
		aSize[7] -= 50
		aSize[6] -= 30
	ElseIf SetMdiChild()
		aSize[5] -= 03
	EndIf
	
	nAltura  := aSize[6]
	nLargura := aSize[5]

	Inclui := .F.
	Altera := .F.

	//-------------------------------------------------------------------------
	// Parametrizacao da Consulta:
	// MV_PAR01 - Imprimir ?
	//-------------------------------------------------------------------------

	dbSelectArea("TVZ")
	dbSetOrder(1)
	dbGoTop()
	mBrowse(6, 1, 22, 75, "TVZ")

	NGRETURNPRM(aNGBEGINPRM)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Utilizacao de Menu Funcional. 
@Param do array a Rotina:                              
	1. Nome a aparecer no cabecalho                            
	2. Nome da Rotina associada                                
	3. Reservado                                              
	4. Tipo de Transacao a ser efetuada:                       
		1 - Pesquisa e Posiciona em um Banco de Dados           
		2 - Simplesmente Mostra os Campos                      
		3 - Inclui registros no Bancos de Dados                
		4 - Altera o registro corrente                          
		5 - Remove o registro corrente do Banco de Dados        
	5. Nivel de acesso                                        
	6. Habilita Menu Funcional 
@author Wagner S. de Lacerda
@since 08/08/2011
@return Array com opcoes da rotina. 
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina

	aRotina := { { STR0002 ,   "AxPesqui" , 0, 1},; //"Pesquisar"
					{ STR0003,   "NGCAD01" , 0, 2},; //"Visualizar"
					{ STR0004,   "MNTC681R", 0, 3} } //"Imprimir"

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTC681R
Imprime o relatorio do Historico. 

@author Wagner S. de Lacerda
@since 08/08/2011
@return 
/*/
//---------------------------------------------------------------------
Function MNTC681R(cAlias, nRecNo, nOpcx)

	Local nX		:= 0
	Local nAcesso	:= 0
	
	Local aChave   := {}
	Local aAcesso	 := {}
	Local aTitulos := {}
	
	Local cChave := ""

	Local lQuebraPag := .F.

	If Pergunte(cPerg,.T.)
	
		aAcessos := aClone( MNTRETEF(,.F.) )
	
		CursorWait()
	
		If MV_PAR01 == 1
			dbSelectArea("TVZ")
			dbSetOrder(1)
			dbGoTo(nRecNo)
		
			If ( nAcesso := aScan(aAcessos, {|x| x[1] + x[2] == cEmpAnt + TVZ->TVZ_FILIAL }) ) > 0
				aAdd(aChave, TVZ->( TVZ_FILIAL + TVZ_CODBEM + DToS(TVZ_DTALT) + TVZ_HRALT + DToS(TVZ_DTDES) ))
			EndIf
		Else
		
			dbSelectArea("TVZ")
			dbSetOrder(1)
			dbGoTop()
			While !EoF()
			
				If TVZ->TVZ_CODBEM < MV_PAR03 .Or. TVZ->TVZ_CODBEM > MV_PAR04
					dbSelectArea("TVZ")
					dbSkip()
					Loop
				EndIf
			
				If ( nAcesso := aScan(aAcessos, {|x| x[1] + x[2] == cEmpAnt + TVZ->TVZ_FILIAL }) ) > 0
					aAdd(aChave, TVZ->( TVZ_FILIAL + TVZ_CODBEM + DToS(TVZ_DTALT) + TVZ_HRALT + DToS(TVZ_DTDES) ))
				EndIf
			
				dbSelectArea("TVZ")
				dbSkip()
			EndDo
		EndIf
	
		For nX := 1 To Len(aChave)
			aAdd(aTitulos, OemToAnsi(STR0005) + PadL(nX, 6, "0") + " / " + PadL( Len(aChave), 6, "0" ) ) //"Histórico: "
		Next nX
	
		lQuebraPag := ( MV_PAR02 <> 1 )
	
		CursorArrow()
	
		NGImpCad(cAlias, aChave, 1, lQuebraPag, aTitulos)
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTC681BE
Validaca da Pergunta: De/Ate Empresa    

@author Wagner S. de Lacerda
@since 24/08/2011
@Param nParam -> Obrigatorio; 
			Indica qual dos tipos de pergunta sera validado:
			1 - De
			2 - Ate  
@return 	.T. -> Bem OK.
			.f. -> Bem invalido. 
/*/			
//---------------------------------------------------------------------

Function MNTC681BE(nParam)

	Local lRet := .T.

	If nParam == 1
		If !Empty(MV_PAR03) .And. !ExistCpo("ST9",MV_PAR03,1)
			lRet := .F.
		EndIf
	Else
		If !AteCodigo("ST9",MV_PAR03,MV_PAR04)
			lRet := .F.
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTRETEF
Recebe as empresas e filiais que o usuario possui acesso
e retorna de forma mais organizada.  

@author Wagner S. de Lacerda
@since 24/08/2011
@Param	cVerCodUsr -> Opcional;                                    
               Indica um usuario em especifico para         
               pesquisar.                                   
               Default: Usuario Atual.                      
 		lShowMsg ---> Opcional;                                    
               Indica se deve mostrar a mensagem.           
                .T. - Mostra a mensagem                     
                .F. - Nao mostra a mensagem                 
               Default: .F.                                 
 		cFiltEmp1 --> Opcional;                                    
               Indice a empresa DE para o filtro.           
               Default: "  "                                
 		cFiltFil1 --> Opcional;                                    
               Indice a filial DE para o filtro.            
               Default: "  "                                
 		cFiltEmp2 --> Opcional;                                    
               Indice a empresa ATE para o filtro.          
               Default: "ZZ"                                
 		cFiltFil2 --> Opcional;                                    
               Indice a filial ATE para o filtro.           
               Default: "ZZ"                                
@return 	aEmpsFils -> Array com as empresas/filiais as quais  
			o usuario possui acesso.
			
/*/			
//---------------------------------------------------------------------
Function MNTRETEF(cVerCodUsr, lShowMsg, cFiltEmp1, cFiltFil1, cFiltEmp2, cFiltFil2)

	Local aArea      := {}
	Local aUsrAccess := {}
	Local aEmpsFils  := {}

	Local lTemAcesso := .F.
	Local nTodas     := 0

	Local nTAMCODIGO := Len(SM0->M0_CODIGO)
	Local nTAMFILIAL := If(FindFunction("FWSizeFilial"),FWSizeFilial(),2)

	Local cVerCodEmp := ""
	Local cVerCodFil := ""

	Default cVerCodUsr := RetCodUsr()
	Default lShowMsg   := .F.
	Default cFiltEmp1  := Space(nTamCodigo)
	Default cFiltFil1  := Space(nTamFilial)
	Default cFiltEmp2  := Replicate('Z', nTamCodigo)
	Default cFiltFil2  := Replicate('Z', nTamFilial)

	aUsrAccess := aClone( MntAccess(cVerCodUsr, lShowMsg) )

	dbSelectArea("SM0")
	
	aArea := GetArea()

	nTodas := aScan(aUsrAccess, {|x| AllTrim(x) == "@@@@" })

	CursorWait()
	
	aEmpsFils := {}

	dbSelectArea("SM0")
	dbSetOrder(1)
	dbGoTop()
	While !Eof()
	
		cVerCodEmp := PadR(SM0->M0_CODIGO, nTamCodigo, " ")
		cVerCodFil := PadR(SM0->M0_CODFIL, nTamFilial, " ")
	
		If cVerCodEmp < cFiltEmp1 .Or. cVerCodEmp > cFiltEmp2
			dbSelectArea("SM0")
			dbSkip()
			Loop
		EndIf
		
		If cVerCodEmp == cFiltEmp1 .And. cVerCodFil < cFiltFil1
			dbSelectArea("SM0")
			dbSkip()
			Loop
		EndIf
		
		If cVerCodEmp == cFiltEmp2 .And. cVerCodFil > cFiltFil2
			dbSelectArea("SM0")
			dbSkip()
			Loop
		EndIf
	
		If ( lTemAcesso := IIf( nTodas > 0, .T., ( aScan(aUsrAccess, {|x| AllTrim(x) == cVerCodEmp+cVerCodFil }) > 0 ) ) )
			aAdd(aEmpsFils, {cVerCodEmp, cVerCodFil})
		EndIf
	
		dbSelectArea("SM0")
		dbSkip()
	End
	
	If nTodas > 0
		aAdd(aEmpsFils, {"ALL", "ALL"})
	EndIf

	If Len(aEmpsFils) > 0
		aSort(aEmpsFils, , , {|x,y| x[1] + x[2] < y[1] + y[2] })
	EndIf

	CursorArrow()

	RestArea(aArea)

Return aEmpsFils

//---------------------------------------------------------------------
/*/{Protheus.doc} MntAccess
Função para buscar as empresas e filiais as quais um determinado usuário 
possui acesso. 

@author Wagner S. de Lacerda
@since 24/08/2011
@Param cVerCodUsr -> Opcional;                                    
		               Indica um usuario em especifico para         
		               pesquisar.                                   
		               Default: Usuario Atual.                      
		 lShowMsg ---> Opcional;                                    
		               Indica se deve mostrar a mensagem.           
		                .T. - Mostra a mensagem                     
		                .F. - Nao mostra a mensagem                 
		               Default: .F.  

@return  aUsrAccess -> Array com as empresas/filiais 
			as quais o usuario possui acesso. 
/*/			
//---------------------------------------------------------------------
Function MntAccess(cVerCodUsr, lShowMsg)

	Local aArea		:= GetArea()
	Local aGroups		:= {}
	Local aUsrAccess	:= {}
	
	Local nGroup, nEmpFil, nTotal := 0

	Default cVerCodUsr := RetCodUsr()
	Default lShowMsg   := .F.

	PswOrder(1)
	
	If PswSeek(cVerCodUsr, .T.)
	
		dbSelectArea("SM0")
		
		aArea := GetArea()
	
		//Verifica se a restrição será pelo grupo de usuários
		If Len( PswRet()[1][10] ) > 0 .And. PswRet()[2][11]
			
			aGroups := PswRet()[1][10]
		
			//Adiciona as Empresas e Filiais de todos os Grupos do usuário
			For nGroup := 1 To Len(aGroups)
		
				//Seta no Grupo para buscar informações
				If PswSeek(aGroups[nGroup], .F.)
			
					//Veifica e adiciona Empresa e Filial permitida para o grupo
					aEmpFil := PswRet()[1][11]
					
					For nEmpFil := 1 To Len(aEmpFil)
					
						//Verifica se já não foi adicionado na array
						If aScan(aUsrAccess, aEmpFil[nEmpFil]) == 0
							aAdd(aUsrAccess,aEmpFil[nEmpFil])
						EndIf
						
					Next nEmpFil
				EndIf
			Next nGroup
		Else
		
			//Utiliza as restrições direto do usuário
			aUsrAccess := PswRet()[2][6]
			
		EndIf

		//Verifica se array contem todas as empresas e filiais
		dbSelectArea("SM0")
		dbGoTop()
		dbEval({|| nTotal++ },,{|| aScan(aUsrAccess, SM0->( M0_CODIGO + M0_CODFIL )) == 0})
	
		//Se todas as empresas e filiais estiverem na array, troca-se para @@@@
		//Reduzindo a lentidao e nao ocorrendo erro de overflow
		If nTotal == 0
			aUsrAccess := {"@@@@"}
		EndIf
	EndIf

	If lShowMsg .And. Len(aUsrAccess) == 0
		ApMsgAlert(STR0021)//"Usuário não encontrado no cadastro do sistema."
	EndIf

	RestArea(aArea)

Return aUsrAccess