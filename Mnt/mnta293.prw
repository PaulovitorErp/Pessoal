#include "Protheus.ch"
#include "MNTA293.ch"

#DEFINE _nVERSAO 3 //Versao do fonte
//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA293
Configuração da criticidade

@author Roger Rodrigues
@since 20/04/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Function MNTA293()
Local oDlgCfg, oPnlCfg, oObjClass
Local oFont12  := TFont():New("Arial",,-12,.T.,.T.)
Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)

//Verifica se o update de facilities foi aplicado
If !FindFunction("MNTUPDFAC") .or. !MNTUPDFAC()
	NGRETURNPRM(aNGBEGINPRM)
	Return .F.
Endif

Define MsDialog oDlgCfg Title STR0001 From 9,0 To 144,312 Of oMainWnd Pixel //"Configuração - Criticidade"
@ 000,000 MSPANEL oPnlCfg Size 170,150 OF oDlgCfg

@ 018,35 Say STR0002 PIXEL OF oPnlCfg Font oFont12 //"Classificação da Criticidade"
@ 030,25 BTNBMP oObjClass Resource 'FORM' Size 22,22 Pixel Of oPnlCfg Noborder Pixel Action MNTA293BRW()

@ 038,35 Say STR0003 PIXEL OF oPnlCfg Font oFont12 //"Definição da Criticidade"
@ 070,25 BTNBMP oObjClass Resource 'SDUIMPORT' Size 22,22 Pixel Of oPnlCfg Noborder Pixel Action MNTA297()
  
Activate MsDialog oDlgCfg Centered

NGRETURNPRM(aNGBEGINPRM)
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA293BRW
Manutenção da tabela de niveis de criticidade

@author Roger Rodrigues
@since 20/04/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Function MNTA293BRW()
Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO,"MNTA293")
Private cCadastro := STR0004 //"Criticidade"
Private aRotina   := MenuDef()

dbSelectArea("TU9")
dbSetOrder(1)

mBrowse(6,1,22,75,"TU9")

NGRETURNPRM(aNGBEGINPRM)
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Retorna as opções do Menu

@author Roger Rodrigues
@since 20/04/2012
@version MP10/MP11
@return aRotina
/*/
//---------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {{STR0005, "AxPesqui"	, 0, 1},; //"Pesquisar"
					{STR0006	, "MNT293CAD"	, 0, 2},; //"Visualizar"
				  	{STR0007	, "MNT293CAD"	, 0, 3},; //"Incluir"
				  	{STR0008	, "MNT293CAD"	, 0, 4},; //"Alterar"
					{STR0009	, "MNT293CAD"	, 0, 5,3}} //"Excluir"
					
Return aRotina
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT293CAD
Monta tela de cadastro

@param cAlias Tabela para montagem do cadastro 
@param nRecno Numero do registro a ser visualizado/alterado
@param nOpcx  Opcao de montagem da tela 

@author Roger Rodrigues
@since 20/04/2012
@version MP10/MP11
@return nOpca
/*/
//---------------------------------------------------------------------
Function MNT293CAD(cAlias,nRecno,nOpcx)
Local nOpca := 0
Private aMemos := {{"TU9_OBSERV","TU9_MEMO"}}

nOpca := NGCAD01(cAlias,nRecno,nOpcx)

Return nOpca
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT293VAL
Retorna conteudo dos campos virtuais da tabela

@param cReadVar Campo a ser validado

@author Roger Rodrigues
@since 20/04/2012
@version MP10/MP11
@return lRet
/*/
//---------------------------------------------------------------------
Function MNT293VAL(cReadVar)
Local lRet := .T.
Local xVar
Local aArea := GetArea()
Local nRecno := TU9->(Recno())
Local nPERCFI := 0
Default cReadVar := ReadVar()

xVar := &(cReadVar)
If cReadVar == "M->TU9_PERCIN" .or. cReadVar == "M->TU9_PERCFI"
	xVar := If( ValType( &(cReadVar) ) == "N", &(cReadVar), Val( &(cReadVar) ) )
	If xVar > 0 .And. NaoVazio() 
		If xVar > 100
			lRet := .F.
			ShowHelpDlg(STR0011,{STR0012},1,{STR0013}) //"Atenção" ## "O valor digitado é inválido." ## "Informe um valor de 1 até 100."
		Endif
		If lRet
			nPERCFI := If( ValType( M->TU9_PERCFI ) == "N", M->TU9_PERCFI, Val( M->TU9_PERCFI ) )
			If (cReadVar == "M->TU9_PERCIN" .and. nPERCFI > 0 .and. nPERCFI < xVar) .or.;
					(cReadVar == "M->TU9_PERCFI" .and. M->TU9_PERCIN > 0 .and. M->TU9_PERCIN > xVar)
				lRet := .F.
				ShowHelpDlg(STR0011,{STR0012},1,; // "Atenção" ## "O valor digitado é inválido."
									{STR0014+If(cReadVar == "M->TU9_PERCIN",STR0015, STR0016)+STR0017+; //"Informe um valor " ## "menor" ## "maior" ## " que o informado no campo "
										If(cReadVar == "M->TU9_PERCIN", Trim(RetTitle("TU9_PERCFI"))+" ("+AllTrim(Str(nPERCFI,3))+")",;
																					 Trim(RetTitle("TU9_PERCIN"))+" ("+AllTrim(Str(M->TU9_PERCIN,3))+")")+"."})
			Else
				dbSelectArea("TU9")
				dbSetOrder(2)
				dbSeek(xFilial("TU9"))
				nPERCFI := If( ValType( TU9->TU9_PERCFI ) == "N", TU9->TU9_PERCFI, Val( TU9->TU9_PERCFI ) )
				While !Eof() .and. xFilial("TU9") == TU9->TU9_FILIAL
					If ( Inclui .or. TU9->(Recno()) <> nRecno) .and. (xVar >= TU9->TU9_PERCIN .and. xVar <= nPERCFI )
						lRet := .F.
						ShowHelpDlg(STR0011,{STR0018},1,; //"Atenção" ## "Já existe uma criticidade cadastrada com este valor."
										{STR0019+AllTrim(Str( nPERCFI, 3 ))+STR0020+AllTrim(Str(TU9->TU9_PERCIN,3))+"."}) //"Informe um valor maior que " ## " ou menor que "
						Exit
					Endif
					dbSelectArea("TU9")
					dbSkip()
				End
			Endif
		Endif
	Else
		lRet := .F.
	Endif
ElseIf cReadVar == "M->TU9_CORLEG"
	xVar := If( valTYpe( xVar ) == "C", xVar, cValToChar( xVar ) )
	dbSelectArea("TU9")
	dbSetOrder(2)
	dbSeek(xFilial("TU9")+xVar)
	While !Eof() .and. xFilial("TU9")+xVar == TU9->TU9_FILIAL+TU9->TU9_CORLEG
		If Inclui .or. TU9->(Recno()) <> nRecno
			lRet := .F.
			Exit
		Endif
		dbSelectArea("TU9")
		dbSkip()
	End
	If !lRet
		ShowHelpDlg(STR0011,{STR0021},1,{STR0022}) //"Atenção" ## "Já existe um nível de criticidade cadastrado com esta cor." ## "Informe outra cor."
	Endif
ElseIf cReadVar == "M->TU9_TMPMAX"
	xVar := If( valTYpe( xVar ) == "C", xVar, cValToChar( xVar ) )
	lRet := MNTA290TEM(xVar)
ElseIf cReadVar == "M->TU9_PRIORI"
	lRet := Pertence("123")
Endif	

RestArea(aArea)
Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT293CBOX
Retorna conteudo do combobox

@param cValor Valor da opcao do combo

@author Roger Rodrigues
@since 20/04/2012
@version MP10/MP11
@return cRetorno
/*/
//---------------------------------------------------------------------
Function MNT293CBOX(cValor,nOpcRet)
Local i, nPos
Local cRetorno := ""
Local aCores := {}
Default cValor := ""

aAdd(aCores, {"1",STR0023,"BR_AMARELO" }) //"Amarelo"
aAdd(aCores, {"2",STR0024,"BR_AZUL"	    }) //"Azul"
aAdd(aCores, {"3",STR0025,"BR_BRANCO"  }) //"Branco" 
aAdd(aCores, {"4",STR0026,"BR_CINZA"   }) //"Cinza"
aAdd(aCores, {"5",STR0027,"BR_LARANJA" }) //"Laranja"
aAdd(aCores, {"6",STR0028,"BR_MARROM"  }) //"Marrom"
aAdd(aCores, {"7",STR0029,"BR_PRETO"   }) //"Preto"
aAdd(aCores, {"8",STR0030,"BR_PINK"    }) //"Rosa"
aAdd(aCores, {"9",STR0031,"BR_VERDE"   }) //"Verde"
aAdd(aCores, {"A",STR0032,"BR_VERMELHO"}) //"Vermelho"

If Empty(cValor)//Retorna combo
	For i:=1 to Len(aCores)
		cRetorno += aCores[i][1]+"="+aCores[i][2]+";"
	Next i
Else
	If (nPos := aScan(aCores,{|x| x[1] == cValor})) > 0
		cRetorno := aCores[nPos][3]
	Endif
Endif

Return cRetorno
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT293LEG
Monta tela de legenda da criticidade cadastrada

@author Roger Rodrigues
@since 23/04/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Function MNT293LEG(lSituac, lCritic, lPriori, lTercei)
Local aSituac := {}
Local aCritic := MNT293CRI(.T.)
Local aPriori := {}
Local aTercei := {}

Local oDlgLeg
Local cDlgLeg := STR0010//"Legenda"
Local oPnlLeg
Local nAltura  := 400
Local nLargura := 600

Local oPnlTop
Local oPnlAll
Local oPnlSit, oPnlCri, oPnlPri, oPnlTer, oPnlAux
Local oPnlTitulo, oPnlConteud, oScroll
Local nLin, nCol
Local nX

Local oFnt16  := TFont():New(,,16,.T.,.T.)
Local oFntPad := TFont():New(,,,.T.,.T.)

Local aColors := NGCOLOR("10")
Local nClrFore := aColors[1]
Local nClrBack := aColors[2]

Local nIncLinha  := 015
Local nTamImagem := 030

// Defaults
Default lSituac := .T.
Default lCritic := .T.
Default lPriori := .T.
Default lTercei := .T.

//--------------------
// Define Legendas
//--------------------
// Situação
aSituac := {	{"BR_VERMELHO", NGRetSX3Box("TQB_SOLUCA","A") }, ;
				{"BR_VERDE"   , NGRetSX3Box("TQB_SOLUCA","D")}, ;
				{"BR_AZUL"    , NGRetSX3Box("TQB_SOLUCA","E")}, ;
				{"BR_PRETO"   , NGRetSX3Box("TQB_SOLUCA","C")} }
// Prioridade
aPriori := {	{"BR_VERMELHO", STR0033 }, ; //"Prioridade Alta"
				{"BR_AMARELO" , STR0034 }, ; //"Prioridade Média"
				{"BR_AZUL"    , STR0035 }, ; //"Prioridade Baixa"
				{"BR_PRETO"   , STR0036 }}   //"Prioridade Indefinida"
// Terceiro
aTercei := {	{"BR_BRANCO", STR0037 }, ; //"Não envolvido na S.S."
				{"BR_PRETO" , STR0038 } }  //"Envolvido na S.S."

// Redimensiona Janela
If ( !lSituac .And. !lPriori ) .Or. ( !lCritic .And. !lTercei )	
	nAltura := ( nAltura / 1.5 )
EndIf
If ( !lSituac .And. !lCritic ) .Or. ( !lPriori .And. !lTercei )	
	//nLargura := ( nLargura / 1.5 )
EndIf

//--------------------
// Executa Legenda
//--------------------
If lCritic .And. Len(aCritic) == 0
	ShowHelpDlg(STR0011,{STR0039},1,{STR0040}) // "Atenção" ## "Não existem criticidades cadastradas." ## "Cadastre pelo uma escala de criticidade"
EndIf
DEFINE MSDIALOG oDlgLeg TITLE cDlgLeg FROM 0,0 TO nAltura,nLargura OF oMainWnd PIXEL
	
	// Painél principal do Dialog
	oPnlLeg := TPanel():New(01, 01, , oDlgLeg, , , , CLR_BLACK, CLR_WHITE, 100, 100)
	oPnlLeg:Align := CONTROL_ALIGN_ALLCLIENT
		
		// Painél TOP
		oPnlTop := TPanel():New(01, 01, , oPnlLeg, , , , CLR_BLACK, CLR_WHITE, 100, 030)
		oPnlTop:Align := CONTROL_ALIGN_TOP
			
			// Subtítulo da Janela
			TSay():New(010, 010, {|| STR0010 }, oPnlTop, , oFnt16, , , , .T., CLR_BLACK, CLR_WHITE, 100, 020) //"Legenda"
			
			// GroupBox de Enfeite
			TGroup():New(019, 003, 021, (oPnlTop:nClientWidth*0.50)-005, , oPnlTop, , , .T.)
		
		// Painél ALL
		oPnlAll := TPanel():New(01, 01, , oPnlLeg, , , , CLR_BLACK, CLR_WHITE, 100, 100)
		oPnlAll:Align := CONTROL_ALIGN_ALLCLIENT
			
			// Painél Auxiliar para conter demais legendas
			If lSituac .Or. lCritic
				oPnlAux := TPanel():New(01, 01, , oPnlAll, , , , CLR_BLACK, CLR_WHITE, ((nLargura*0.50)/2), 100)
				oPnlAux:Align := If(lPriori .Or. lTercei, CONTROL_ALIGN_LEFT, CONTROL_ALIGN_ALLCLIENT)
			EndIf
				
				// Painél da SITUAÇÃO
				If lSituac
					oPnlSit := TPanel():New(01, 01, , oPnlAux, , , , CLR_BLACK, CLR_WHITE, 100, 080)
					oPnlSit:Align := CONTROL_ALIGN_TOP
						
						// Título
						oPnlTitulo := TPanel():New(01, 01, STR0041, oPnlSit, oFntPad, .T., , nClrFore, nClrBack, 100, 012) //"Situação"
						oPnlTitulo:Align := CONTROL_ALIGN_TOP
						
						// Conteúdo
						oPnlConteud := TPanel():New(01, 01, , oPnlSit, , , , CLR_BLACK, CLR_WHITE, 100, 100)
						oPnlConteud:Align := CONTROL_ALIGN_TOP
							
							// Monta a Legenda
							nLin := 010
							nCol := 010
							For nX := 1 To Len(aSituac)
								// Imagem
								TBitmap():New(nLin, nCol, nTamImagem, nTamImagem, , &("'" + aSituac[nX][1] + "'"), .T., oPnlConteud,;
									 			, , .F., .F., , , .T., , .T., , .F.)
								// Descrição
								TSay():New(nLin, nCol+(nTamImagem/2), &("{|| '" + aSituac[nX][2] + "' }"), oPnlConteud,;
												, , , , , .T., CLR_BLACK, CLR_WHITE, 250, nTamImagem)
								
								// Incrementa a Linha
								nLin += nIncLinha
							Next nX
				EndIf
				
				// Painél da CRITICIDADE
				If lCritic
					oPnlCri := TPanel():New(01, 01, , oPnlAux, , , , CLR_BLACK, CLR_WHITE, 100, 100)
					oPnlCri:Align := CONTROL_ALIGN_ALLCLIENT
						
						// Título
						oPnlTitulo := TPanel():New(01, 01, STR0042, oPnlCri, oFntPad, .T., , nClrFore, nClrBack, 100, 012) //"Criticidade"
						oPnlTitulo:Align := CONTROL_ALIGN_TOP
						
						// ScrollBox
						oScroll := TScrollBox():New(oPnlCri, 0, 0, 100, 100, .T., .F., .F.)
						oScroll:Align := CONTROL_ALIGN_ALLCLIENT
						
						// Monta a Legenda
						nLin := 010
						nCol := 010
						For nX := 1 To Len(aCritic)
							// Imagem
							TBitmap():New(nLin, nCol, nTamImagem, nTamImagem, , &("'" + aCritic[nX][1] + "'"), .T., oScroll,;
								 			, , .F., .F., , , .T., , .T., , .F.)
							// Descrição
							TSay():New(nLin, nCol+(nTamImagem/2), &("{|| '" + aCritic[nX][2] + "' }"), oScroll,;
											, , , , , .T., CLR_BLACK, CLR_WHITE, 250, nTamImagem)
							
							// Incrementa a Linha
							nLin += nIncLinha
						Next nX
				EndIf
			
			// Painél Auxiliar para Separação
			If ( lSituac .Or. lCritic ) .And. ( lPriori .Or. lTercei )
				oPnlAux := TPanel():New(01, 01, , oPnlAll, , , , nClrFore, nClrBack, 002, 100)
				oPnlAux:Align := CONTROL_ALIGN_LEFT
			EndIf
			
			// Painél Auxiliar para conter demais legendas
			If lPriori .Or. lTercei
				oPnlAux := TPanel():New(01, 01, , oPnlAll, , , , CLR_BLACK, CLR_WHITE, 100, 100)
				oPnlAux:Align := CONTROL_ALIGN_ALLCLIENT
			EndIf
				
				// Painél da PRIORIDADE
				If lPriori
					oPnlPri := TPanel():New(01, 01, , oPnlAux, , , , CLR_BLACK, CLR_WHITE, 100, 080)
					oPnlPri:Align := CONTROL_ALIGN_TOP
						
						// Título
						oPnlTitulo := TPanel():New(01, 01, STR0043, oPnlPri, oFntPad, .T., , nClrFore, nClrBack, 100, 012) //"Prioridade"
						oPnlTitulo:Align := CONTROL_ALIGN_TOP
						
						// Conteúdo
						oPnlConteud := TPanel():New(01, 01, , oPnlPri, , , , CLR_BLACK, CLR_WHITE, 100, 100)
						oPnlConteud:Align := CONTROL_ALIGN_TOP
							
							// Monta a Legenda
							nLin := 010
							nCol := 010
							For nX := 1 To Len(aPriori)
								// Imagem
								TBitmap():New(nLin, nCol, nTamImagem, nTamImagem, , &("'" + aPriori[nX][1] + "'"), .T., oPnlConteud,;
									 			, , .F., .F., , , .T., , .T., , .F.)
								// Descrição
								TSay():New(nLin, nCol+(nTamImagem/2), &("{|| '" + aPriori[nX][2] + "' }"), oPnlConteud,;
												, , , , , .T., CLR_BLACK, CLR_WHITE, 250, nTamImagem)
								
								// Incrementa a Linha
								nLin += nIncLinha
							Next nX
					EndIf
				
				// Painél do TERCEIRO
				If lTercei
					oPnlTer := TPanel():New(01, 01, , oPnlAux, , , , CLR_BLACK, CLR_WHITE, 100, 080)
					oPnlTer:Align := CONTROL_ALIGN_TOP
						
						// Título
						oPnlTitulo := TPanel():New(01, 01, STR0044, oPnlTer, oFntPad, .T., , nClrFore, nClrBack, 100, 012) //"Terceiro"
						oPnlTitulo:Align := CONTROL_ALIGN_TOP
						
						// Conteúdo
						oPnlConteud := TPanel():New(01, 01, , oPnlTer, , , , CLR_BLACK, CLR_WHITE, 100, 100)
						oPnlConteud:Align := CONTROL_ALIGN_TOP
							
							// Monta a Legenda
							nLin := 010
							nCol := 010
							For nX := 1 To Len(aTercei)
								// Imagem
								TBitmap():New(nLin, nCol, nTamImagem, nTamImagem, , &("'" + aTercei[nX][1] + "'"), .T., oPnlConteud,;
									 			, , .F., .F., , , .T., , .T., , .F.)
								// Descrição
								TSay():New(nLin, nCol+(nTamImagem/2), &("{|| '" + aTercei[nX][2] + "' }"), oPnlConteud,;
												, , , , , .T., CLR_BLACK, CLR_WHITE, 250, nTamImagem)
								
								// Incrementa a Linha
								nLin += nIncLinha
							Next nX
				EndIf
	
ACTIVATE MSDIALOG oDlgLeg CENTERED

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT293CRI
Retorna array com todas as criticidades definidas

@param lSort Indica se deve ordernar por criticidade

@author Roger Rodrigues
@since 23/04/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Function MNT293CRI(lSort)
Local aCritic := {}
Default lSort := .F.

//Item adicionado por primeiro pois legenda de browse obedece a ordem
aAdd(aCritic, {"PMSEDT3", STR0045, 0.5, 0.5}) //"MELHORIA"

//Le todas as criticidades
dbSelectArea("TU9")
dbSetOrder(1)
dbSeek(xFilial("TU9"))
While !Eof() .and. xFilial("TU9") == TU9->TU9_FILIAL
	aAdd(aCritic, {MNT293CBOX(TU9->TU9_CORLEG), TU9->TU9_DESLEG, TU9->TU9_PERCIN, TU9->TU9_PERCFI})
	dbSelectArea("TU9")
	dbSkip()
End

//Item adicionado por ultimo pois legenda de browse obedece a ordem
aAdd(aCritic, {"BR_CANCEL", STR0046, 0, 0}) //"CRITICIDADE NÃO DEFINIDA"

If lSort
	aSort(aCritic,,,{|x,y| x[3] > y[3]})
Endif

Return aCritic
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT293CPO
Retorna conteudo de campo definido para a criticidade 

@param nCritic Indica criticidade que deve ser comparada
@param cCampo Indicaçao do campo de retorno da funçao

@author Roger Rodrigues
@since 27/04/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Function MNT293CPO(nCritic, cCampo)
	Local xCampo := ""
	Local nPERCFI

	dbSelectArea("TU9")
	dbSetOrder(1)
	dbSeek(xFilial("TU9"))
	While !Eof() .and. xFilial("TU9") == TU9->TU9_FILIAL
		nPERCFI := If( ValType( TU9->TU9_PERCFI ) == "N", TU9->TU9_PERCFI, Val( TU9->TU9_PERCFI ) )
		If nCritic >= TU9->TU9_PERCIN .and. nCritic <= nPERCFI
			xCampo := &("TU9->"+cCampo)
			Exit
		Endif
		dbSelectArea("TU9")
		dbSkip()
	End

Return xCampo