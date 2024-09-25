#INCLUDE "SGAC070.ch"
#Include "Protheus.ch"
#DEFINE _nVERSAO 2 //Versao do fonte
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSGAC070   บAutor  ณRoger Rodrigues     บ Data ณ  05/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConsulta de criterios de avalicao dos requisitos            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGASGA                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SGAC070()
Local aNGBEGINPRM	:= NGBEGINPRM(_nVERSAO)

Private cCadastro	:= OemtoAnsi(STR0001) //"Consulta de Crit้rios de Avalia็ใo dos Requisitos"
Private cPerg		:= "SGC070"
Private aPerg		:= {}
//Varํaveis para verificar tamanho dos campos
Private nTamTA1 := If((TAMSX3("TA1_CODAVA")[1]) < 1,3,(TAMSX3("TA1_CODAVA")[1]))
Private nTamCOD := If((TAMSX3("TA2_CODOPC")[1]) < 1,3,(TAMSX3("TA2_CODOPC")[1]))
Private nTamOPC := If((TAMSX3("TA2_OPCAO")[1]) < 1,20,(TAMSX3("TA2_OPCAO")[1]))

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis utilizadas para parametros                             ณ
//ณ mv_par01     // De Data                                          ณ
//ณ mv_par02     // Ate Data                                         ณ
//ณ mv_par03     // Criterio de Avaliacao                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica as perguntas selecionadas                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Pergunte("SGC070",.T.)
	cAliasTRB := GetNextAlias()
	//Cria Estrutura da tabela
	aCampos := {}
	aADD(aCampos, {"TA2_CODOPC"	, "C" , nTamCOD		, 0})
	aADD(aCampos, {"TA2_OPCAO"	, "C" , nTamOPC		, 0})
	aADD(aCampos, {"QUANTIDADE"	, "N" , 09			, 0})
			
	oTempTRB := FWTemporaryTable():New( cAliasTRB, aCampos )
	oTempTRB:AddIndex( "1", {"TA2_CODOPC"} )
	oTempTRB:AddIndex( "2", {"TA2_OPCAO"} )
	oTempTRB:AddIndex( "3", {"QUANTIDADE"} )
	oTempTRB:Create()
	
	//Carrega tabela temporaria
	Processa({|| SGC70TRB()})
	
	//Verifica se foram carregados registros
	If (cAliasTRB)->(RecCount()) == 0
		MsgStop(STR0005) //"Nใo existem dados para montar a consulta."
	Else
		//Monta tela com registros
		SGC70CON()
	Endif
	//Deleta o arquivo temporario fisicamente
	oTempTRB:Delete()
	dbSelectArea("TA1")
EndIf

NGRETURNPRM(aNGBEGINPRM)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSGC70TRB  บAutor  ณRoger Rodrigues     บ Data ณ  05/04/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega Tabela Temporแria com as opcoes do criterios de     บฑฑ
ฑฑบ          ณavalicao do requisito                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAC070                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SGC70TRB()
Local nQuantidade := 0

//Verifica se existe criterio
dbSelectArea("TA1")
dbSetOrder(1)
If dbSeek(xFilial("TA1")+MV_PAR03)
	//Percorre respostas do criterio
	dbSelectArea("TA2")
	dbSetOrder(1)
	dbSeek(xFilial("TA2")+TA1->TA1_CODAVA)
	ProcRegua(TA2->(Recno()))
	While !eof() .and. xFilial("TA2")+TA1->TA1_CODAVA == TA2->TA2_FILIAL+TA2->TA2_CODAVA
		IncProc()
		nQuantidade := 0
		//Verifica quantidade respondida
		dbSelectArea("TAC")
		dbSetOrder(2)
		dbSeek(xFilial("TAC")+TA2->TA2_CODAVA+TA2->TA2_CODOPC)
		While !eof() .and. xFilial("TAC")+TA2->TA2_CODAVA+TA2->TA2_CODOPC == TAC->TAC_FILIAL+TAC->TAC_CODAVA+TAC->TAC_CODOPC
			If TAC->TAC_DTRESU < MV_PAR01 .OR. TAC->TAC_DTRESU > MV_PAR02
				dbSelectArea("TAC")
				dbSkip()
				Loop
			Endif
			nQuantidade ++
			dbSelectArea("TAC")
			dbSkip()
		End

		//Grava novo registro
		dbSelectArea(cAliasTRB)
		dbSetOrder(1)
		If !dbSeek(TA2->TA2_CODOPC)
			RecLock(cAliasTRB,.T.)
		Else
			RecLock(cAliasTRB,.F.)
		Endif
		(cAliasTRB)->TA2_CODOPC := TA2->TA2_CODOPC
		(cAliasTRB)->TA2_OPCAO  := TA2->TA2_OPCAO
		(cAliasTRB)->QUANTIDADE := nQuantidade
		MsUnlock(cAliasTRB)
		
		dbSelectArea("TA2")
		dbSkip()
	End
Endif

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSGC70CON  บAutor  ณRoger Rodrigues     บ Data ณ  05/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta tela com criterios de avaliacao do requisito          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAC070                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SGC70CON()
Local oDlg70
Local cTitulo 		:= STR0006 + MV_PAR03 + " - "+ Substr(NGSEEK("TA1",MV_PAR03,1,"TA1->TA1_DESCRI"),1,25) //"Opcoes do criterio de avaliacao "
Local aSize		:= MsAdvSize( .T. , .F. , 430 )
Local aBtnG070		:= {{"",{|| SG070GRAFI()},STR0010,STR0010}}

Define MsDialog oDlg70 Title cTitulo From 9,0 To 28,80 Of oMainWnd 

dbSelectArea(cAliasTRB)
@ 02.5,00 Listbox oList Fields	TA2_CODOPC , TA2_OPCAO, Transform(QUANTIDADE,"@E 999,999,999") ;
				          			FieldSizes 60,80,80	;
						          	Size 310,95			;
									HEADERS STR0007, STR0008, STR0009 //"Opcao"###"Descricao"###"Quantidade"
oList:Align := CONTROL_ALIGN_ALLCLIENT 
dbSelectArea(cAliasTRB)
dbGoTop()


Activate MsDialog oDlg70 On Init EnchoiceBar(oDlg70,{||oDlg70:End()},{||oDlg70:End()},,aBtnG070) Centered

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSG070GRAFIบAutor  ณRoger Rodrigues     บ Data ณ  05/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta grafico com respostas                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAC070                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SG070GRAFI()

NGGRAFICO(" "+cCadastro," ",cCadastro,STR0011+TA1->TA1_DESCRI,"",; //"Criterios de Avaliacao do Requisito "
                     {Dtoc(MV_PAR01)+STR0012+Dtoc(MV_PAR02)},"A",cAliasTRB) //" a "

DbselectArea(cAliasTRB)
Dbgotop()

Return .t.