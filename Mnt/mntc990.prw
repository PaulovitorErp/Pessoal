#INCLUDE "MNTC990.ch"
#INCLUDE "PROTHEUS.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTC990
Consulta de O.S./Manutencoes atrasadas
@author Felipe N. Welter
@since 10/08/09
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Function MNTC990()

	Local aNGBEGINPRM := NGBEGINPRM( , , , , .T. )

	//Browse detalhes: oListOS
	Local aTitOS := {STR0009, STR0010, STR0011, STR0012, STR0013,; //"T. Atraso"###"O.S."###"Prioridade"###"Bem"###"Descrição Bem"
	STR0014, STR0015, STR0016, STR0017},; //"Família"###"Serviço"###"Descrição Serviço"###"Sequência"
	aSizOS := {28,25,28,45,60,35,35,60,32},;
	cLinOS := "{|| {  (cAliDET)->TMPATR, (cAliDET)->ORDEM, (cAliDET)->PRIORI, (cAliDET)->CODBEM, (cAliDET)->NOMBEM,"+;
	"(cAliDET)->CODFAM, (cAliDET)->SERVIC, (cAliDET)->NOMSER, (cAliDET)->SEQUEN,"
	//Browse detalhes: oListMan
	Local	aTitMan := {STR0009, STR0011, STR0012, STR0013,STR0014,; //"T. Atraso"###"Prioridade"###"Bem"###"Descrição Bem"###"Família"
	STR0015, STR0016, STR0017},; //"Serviço"###"Descrição Serviço"###"Sequência"
	aSizMan := {28,28,45,60,35,35,60,76},;
	bLinMan := {|| { (cAliDET)->TMPATR, (cAliDET)->PRIORI, (cAliDET)->CODBEM, (cAliDET)->NOMBEM, (cAliDET)->CODFAM,;
	(cAliDET)->SERVIC, (cAliDET)->NOMSER, (cAliDET)->SEQUEN } }

	//Menus para click da direita
	Local	oMenu
	Local oMenuOS,;
	asMenuOS := {{STR0022,"Eval({|| STJ->(dbGoTo((cAliDET)->RECNBR)),NGCAD01('STJ',(cAliDET)->RECNBR,2)})"},; //"Visualizar O.S."
	{STR0023,"MNC600CON((cAliDET)->CODBEM)"},; //"Manutenções do Bem"
	{STR0024,"MNTA990()"}} //"Programação de O.S."
	Local oMenuMan,;
	asMenuMan := {{STR0025,"Eval({|| STF->(dbGoTo((cAliDET)->RECNBR)),MNC600FOLD('STF',(cAliDET)->RECNBR,2)})"}} //"Visualizar Manutenção"

	Local oFont14  := TFont():New("Arial",,14,,.F.,,,,.F.,.F.)
	Local oFont14N := TFont():New("Arial",,14,,.T.,,,,.F.,.F.)
	Local oDlg

	Local nAlt := (GetScreenRes()[2]-150)
	Local nLrg := (GetScreenRes()[1]-100)

	//Tabelas  Temporarias (p/ Markbrowse)
	Local oTmpTbl1

	//Consulta por:
	Private oTpCons, cTpCons := "1", aTpCons := {STR0001,STR0002} //"1=Ordem"###"2=Manutenção"

	//Visualizar por:
	Private oTpVis, cTpVis := "1",;
	aTpVisOS := {STR0003,STR0004,STR0005,STR0006,STR0007,STR0008},; //"1=Todos"###"2=Família"###"3=Tipo"###"4=Área"###"5=Serviço"###"6=Prioridade"
	aTpVisMan := {STR0003,STR0004,STR0005,STR0006,STR0007,STR0008} //"1=Todos"###"2=Família"###"3=Tipo"###"4=Área"###"5=Serviço"###"6=Prioridade"

	//Classificar por:
	Private oTpCla, cTpCla := "1", aTpCla := {STR0018,STR0019,STR0020,STR0021} //"1=Tempo Atraso"###"2=Prioridade"###"3=Bem"###"4=Servico"

	//Considera Localizacao/Bem
	Private oChkLc,oChkBm,;
	lChkLc := lChkBm := .T.

	Private nSizeForN := 12 //define o tamanho padrão para os campos numéricos
	Private cPicForN  := "@E 999,999,999,999" //define picture padrão para os campos numéricos

	Private cCadastro := STR0026 //"Consulta de O.S./Manutenções Atrasadas"
	Private cMarca := GetMark()

	Private lFolup := NGCADICBASE("TJ_STFOLUP","D","STJ",.F.)
	Private lTPLUB := NGCADICBASE("TF_TIPLUB ","D","STF",.F.)

	// Variaveis de controle das tabelas temporarias
	Private cAliMKB  := GetNextAlias()
	Private cAliDET  := GetNextAlias()
	Private oDetails

	If lFolup
		aAdd(aTpVisOS,STR0027) //"7=Status"
		aAdd(aTitOS,STR0028)   //"Status"
		aAdd(aSizOS,35)
		aAdd(aTitOS,STR0029)   //"Descrição Status"
		aAdd(aSizOS,65)

		cLinOS += "(cAliDET)->STATUS, (cAliDET)->DESTAT, "
	EndIf

	aAdd(aTitOS,STR0030) //"Plano"
	aAdd(aSizOS,30)

	cLinOS += "(cAliDET)->PLANO } }"
	bLinOS := &(cLinOS)

	aMKB    :=  {{"OK"    ,"C",02,0},;
			    {"CODIGO","C",06,0},;
			    {"DESCRI","C",30,0},;
			    {"QNTATR","N", nSizeForN, 0 },; //Quantidade de O.S./Manutencoes atrasadas
			    {"MEDATR","N", nSizeForN, 0 },; //Atraso Médio
			    {"MEDATO","N", nSizeForN, 0 },; //Atraso Total
			    {"MAXATR","N", nSizeForN, 0 },; //Maior Atraso
			    {"MINATR","N", nSizeForN, 0 }}  //Menor Atraso

	aCpMKB  := {{"OK"    ,NIL,"",""},;
				{"DESCRI",NIL,STR0031,"@!"},;        //"Descrição"
				{"QNTATR",NIL,STR0032, cPicForN },; //"Qtde."
				{"MEDATR",NIL,STR0033, cPicForN },; //"Atraso Médio"
				{"MEDATO",NIL,STR0059, cPicForN },; //"Atraso Total"
				{"MAXATR",NIL,STR0034, cPicForN },; //"Maior"
				{"MINATR",NIL,STR0035, cPicForN }}  //"Menor"

	//Intancia classe FWTemporaryTable
	oTmpTbl1	:= FWTemporaryTable():New( cAliMKB, aMKB )
	//Cria indices
	oTmpTbl1:AddIndex( "Ind01" , {"DESCRI"}  )
	//Cria a tabela temporaria
	oTmpTbl1:Create()

	//+-------------------------------------------------+
	//| Criacao da tabela temporaria p/ browse Detalhes |
	//+-------------------------------------------------+
	aDET := {{"TMPATR","N", nSizeForN,0},;
			 {"DTPREV","D",08,0},;
			 {"ORDEM" ,"C",06,0},;
			 {"PRIORI","C",03,0},;
			 {"CODBEM","C",16,0},;
			 {"NOMBEM","C",40,0},;
			 {"SERVIC","C",06,0},;
			 {"SEQUEN","C",03,0},;
			 {"NOMSER","C",40,0},;
			 {"CODFAM","C",06,0},;
			 {"STATUS","C",06,0},;
			 {"DESTAT","C",40,0},;
			 {"PLANO" ,"C",06,0},;
			 {"TIPO"  ,"C",03,0},;
			 {"AREA"  ,"C",06,0},;
			 {"RECNBR","N",09,0}}

	oDetails := FWTemporaryTable():New( cAliDET, aDET )

	oDetails:AddIndex( 'Ind01', { 'DTPREV' } )
	oDetails:AddIndex( 'Ind02', { 'PRIORI' } )
	oDetails:AddIndex( 'Ind03', { 'CODBEM' } )
	oDetails:AddIndex( 'Ind04', { 'SERVIC' } )
	oDetails:AddIndex( 'Ind05', { 'CODFAM' } )
	oDetails:AddIndex( 'Ind06', { 'TIPO' }	 )
	oDetails:AddIndex( 'Ind07', { 'AREA' }	 )
	oDetails:AddIndex( 'Ind08', { 'STATUS' } )

	oDetails:Create()

	CursorWait()

	//Montagem da tela
	Define MsDialog oDlg Title cCadastro From 120,0 To nAlt,nLrg Of oMainWnd Color CLR_BLACK,RGB(225,225,225) Pixel

	oDlg:lEscClose := .F.

	//Define a criacao do painel esquerdo
	oPnlA := tPanel():New(00,00,,oDlg,,,,,,nLrg*.1855,00,.F.,.F.)
	oPnlA:Align := CONTROL_ALIGN_LEFT

	oPnlA1 := tPanel():New(00,00,,oPnlA,,,,,,00,62,.F.,.F.)
	oPnlA1:Align := CONTROL_ALIGN_TOP

	//Define a criacao de um box superior (parte esquerda)
	@ 06,05 To 56,nLrg*.1809 Of oPnlA1 Pixel

	@ 10,10 Say STR0037 Of oPnlA1 Font oFont14N COLOR RGB(0,100,30) Pixel //"Consulta por:"
	@ 18,10 MsComboBox oTpCons Var cTpCons Items aTpCons Size 60,12 Of oPnlA1 Pixel;
	On Change oTpVis:SetItems(If(cTpCons=="1",aTpVisOS,aTpVisMan))

	@ 32,10 Say STR0038 Of oPnlA1 Font oFont14N COLOR RGB(0,100,30) Pixel //"Visualizar por:"
	@ 40,10 MsComboBox oTpVis Var cTpVis Items aTpVisOS Size 60,12 Of oPnlA1 Pixel;
	On Change (CursorWait(),MNC990MKB(cTpCons,cTpVis),CursorArrow())

	oPnlA11 := tPanel():New(00,00,,oPnlA1,,,,,,60,00,.F.,.F.)
	oPnlA11:Align := CONTROL_ALIGN_RIGHT

	//Define a criacao de um box superior (parte direita)
	@ 06,-5 To 56,55 Of oPnlA11 Pixel

	oChkBm := TCheckBox():New(14,5,STR0057,;  //'Bem'
	{|u|If(PCount()==0,lChkBm,lChkBm:=u)},oPnlA11,75,10,,,oFont14;
	,{||CursorWait(),MNC990MKB(cTpCons,cTpVis),CursorArrow()},,,,.T.,;
	STR0039,,{||oTpCons:nAt == 1}) //"Considera O.S. do tipo 'Bem'"
	oChkBm:SetColor(RGB(0,100,30))

	oChkLc := TCheckBox():New(23,5,STR0056,;  //'Localização'
	{|u|If(PCount()==0,lChkLc,lChkLc:=u)},oPnlA11,75,10,,,oFont14;
	,{||CursorWait(),MNC990MKB(cTpCons,cTpVis),CursorArrow()},,,,.T.,;
	STR0040,,{||oTpCons:nAt == 1}) //"Considera O.S. do tipo 'Localização'"
	oChkLc:SetColor(RGB(0,100,30))

	oBtnGC := tButton():New(39,2,STR0041,oPnlA11,{||CursorWait(),MNC990MKB(cTpCons,cTpVis),CursorArrow()},50,12,,,,.T.) //"Gerar &Consulta"

	oPnlA2 := tPanel():New(00,00,,oPnlA,,,,,,00,00,.F.,.F.)
	oPnlA2:Align := CONTROL_ALIGN_ALLCLIENT

	oPnlA21 := tPanel():New(00,00,,oPnlA2,,,,,,05,00,.F.,.F.)
	oPnlA21:Align := CONTROL_ALIGN_LEFT //borda esquerda

	oPnlA22 := tPanel():New(00,00,,oPnlA2,,,,,,00,00,.F.,.F.)
	oPnlA22:Align := CONTROL_ALIGN_ALLCLIENT

	dbSelectArea(cAliMKB)
	dbSetOrder(01)
	dbGoTop()
	oMark := MsSelect():New(cAliMKB,"OK",,aCpMKB,,@cMarca,{0,0,0,0},,,oPnlA22)
	oMark:oBrowse:bLDblClick := { || M990MarkOne() }
	oMark:oBrowse:bAllMark := {||M990MarkAll() }
	oMark:oBrowse:cToolTip := STR0042 //"Visualização de Ordens de Serviço/Manutenções atrasadas por grupo"
	oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	oPnlA23 := tPanel():New(00,00,,oPnlA2,,,,,,05,00,.F.,.F.)
	oPnlA23:Align := CONTROL_ALIGN_RIGHT  //borda direita

	oPnlA3 := tPanel():New(00,00,,oPnlA,,,,,,00,22,.F.,.F.)
	oPnlA3:Align := CONTROL_ALIGN_BOTTOM

	//Define a criacao de um box inferior (parte esquerda)
	@ 03,05 To 20,nLrg*.1809 Of oPnlA3 Pixel

	oPnlA31 := tPanel():New(00,00,,oPnlA3,,,,,,120,00,.F.,.F.)
	oPnlA31:Align := CONTROL_ALIGN_RIGHT

	//Define a criacao de um box inferior (parte direita)
	@ 03,-5 To 20,115 Of oPnlA31 Pixel

	oBtnDT := tButton():New(6,10,STR0043,oPnlA31,{|| Processa({||MNC990DET(cTpCons,cTpVis)},STR0044)},50,12,,,,.T.) //"&Detalhar"###"Aguarde..."
	oBtEnd := tButton():New(6,62,STR0060,oPnlA31,{|| Processa({|| oDlg:End() })},50,12,,,,.T.)//"Sair"

	//Define a criacao do painel direito
	oPnlB := tPanel():New(06,220,,oDlg,,,,,,00,00,.F.,.F.)
	oPnlB:Align := CONTROL_ALIGN_ALLCLIENT

	//Painel para sobreposicao
	oPnlBX := tPanel():New(00,000,,oDlg,,,,,,00,00,.T.,.F.)
	oPnlBX:Align := CONTROL_ALIGN_ALLCLIENT
	oSayDet := TSay():New(05,05,{||STR0045+CHR(13)+STR0046},oPnlBX,,oFont14N,,,,.T.,,,) //"Detalhes: "###"Visualização não disponível."
	oSayDet:SetColor(RGB(0,100,30))

	oPnlB1 := tPanel():New(00,00,,oPnlB,,,,,,00,62,.F.,.F.)
	oPnlB1:Align := CONTROL_ALIGN_TOP

	@ 10,05 Say STR0047 Of oPnlB1 Font oFont14N COLOR RGB(0,100,30) Pixel //"Classificar por:"
	@ 18,05 MsComboBox oTpCla Var cTpCla Items aTpCla Size 70,12 Of oPnlB1 Pixel;
	On Change (NGDBAREAORDE((cAliDET),Val(cTpCla)), oListOS:Refresh(),oListMan:Refresh())

	oPnlB2 := tPanel():New(00,00,,oPnlB,,,,,,00,00,.F.,.F.)
	oPnlB2:Align := CONTROL_ALIGN_ALLCLIENT

	oPnlB21 := tPanel():New(00,00,,oPnlB2,,,,,,05,00,.F.,.F.)
	oPnlB21:Align := CONTROL_ALIGN_LEFT //borda esquerda

	oPnlB22 := tPanel():New(00,00,,oPnlB2,,,,,,00,00,.F.,.F.)
	oPnlB22:Align := CONTROL_ALIGN_ALLCLIENT

	dbSelectArea(cAliDET)
	dbSetOrder(01)
	dbGoTop()

	oListOS := TWBrowse():New(00,00,00,00,,aTitOS,aSizOS,oPnlB22,,,,,,,,,,,,,(cAliDET),.T.,,,,,,)
	oListOS:Align := CONTROL_ALIGN_ALLCLIENT
	oListOS:bLine := bLinOS
	oListOS:cToolTip := STR0048 //"Ordens de Serviço atrasadas"
	oListOS:blDblClick := {|| STJ->(dbGoTo((cAliDET)->RECNBR)),NGCAD01("STJ",(cAliDET)->RECNBR,2)}
	oListOS:Hide()

	NGPOPUP(asMenuOS,@oMenuOS)
	oListOS:brClicked := { |o,x,y| oMenuOS:Activate(x,y,oListOS)}

	oListMan := TWBrowse():New(00,00,00,00,,aTitMan,aSizMan,oPnlB22,,,,,,,,,,,,,(cAliDET),.T.,,,,,,)
	oListMan:Align := CONTROL_ALIGN_ALLCLIENT
	oListMan:bLine := bLinMan
	oListMan:cToolTip := STR0049 //"Manutenções atrasadas"
	oListMan:blDblClick := {|| STF->(dbGoTo((cAliDET)->RECNBR)),MNC600FOLD("STF",(cAliDET)->RECNBR,2)}
	oListMan:Hide()

	NGPOPUP(asMenuMan,@oMenuMan)
	oListMan:brClicked := { |o,x,y| oMenuMan:Activate(x,y,oListMan)}

	oPnlB23 := tPanel():New(00,00,,oPnlB2,,,,,,05,00,.F.,.F.)
	oPnlB23:Align := CONTROL_ALIGN_RIGHT  //borda direita

	oPnlB3 := tPanel():New(00,00,,oPnlB,,,,,,00,22,.F.,.F.)
	oPnlB3:Align := CONTROL_ALIGN_BOTTOM

	oBtImp := tButton():New(6,318,STR0061,oPnlB3,{|| Processa({|| MNT990IMP() })},50,12,,,,.T.) //Imprimir

	Processa({|lEnd| MNC990MKB(cTpCons,cTpVis)},STR0050,STR0051) //"Processando informações"###"Aguarde"

	CursorArrow()

	NGPOPUP(asMenu,@oMenu)
	oDlg:brClicked := { |o,x,y| oMenu:Activate(x,y,oDlg)}

	Activate MsDialog oDlg Centered

	oTmpTbl1:Delete()
	oDetails:Delete()

	//Retorna conteudo de variaveis padroes
	NGRETURNPRM(aNGBEGINPRM)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} M990MarkOne
Funcao chamada no duplo clique em um elemento no markbrowse
@author Felipe N. Welter
@since 12/08/09
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Static Function M990MarkOne()

	dbSelectArea(cAliMKB)
	dbSetOrder(01)
	If !Eof() .And. !Bof()
		RecLock(cAliMKB,.F.)
		(cAliMKB)->OK := If(IsMark('OK',cMarca),"  ",cMarca)
		MsUnLock(cAliMKB)
		oMark:oBrowse:Refresh()
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} M990MarkAll
Grava marca em todos os registros no markbrowse (inverte)
@author Felipe N. Welter
@since 12/08/09
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Static Function M990MarkAll()

	dbSelectArea(cAliMKB)
	dbSetOrder(01)
	dbGoTop()
	While !Eof()
		RecLock(cAliMKB,.F.)
		(cAliMKB)->OK := If(IsMark('OK',cMarca),"  ",cMarca)
		MsUnLock(cAliMKB)
		dbSkip()
	End
	dbGoTop()
	MsUnLock(cAliMKB)
	oMark:oBrowse:Refresh()

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNC990MKB
Processamento da consulta/visualizacao do markbrowse
@author Felipe N. Welter
@since 10/08/09
@version undefined
@param cTpConV, characters, descricao
@param cTpVisV, characters, descricao
@type function
/*/
//---------------------------------------------------------------------
Static Function MNC990MKB(cTpConV,cTpVisV)

	Local aMKBReg := {}, aOldMKB := {}
	Local nSituac := 0, cCodigo := "", cDescri := "", nC
	Local dProxMan, nCont, nVarD

	//+----------------------------------------------------------------------------------+
	//| Parametros   1.cTpConV - Tipo de Consulta                           Obrigat.     |
	//|              		 1 - Ordem de Servico                                        |
	//|              		 2 - Manutencao                                              |
	//|              2.cTpVisV - Tipo de Visualizacao da Consulta            Obrigat.    |
	//|              -Se for Ordem de Servico (1):                                       |
	//|                     		1 - Todas as Ordens de Servico                       |
	//|                    			2 - por Status (follow-up)                           |
	//|                   			3 - por Familia de Bens                              |
	//|                				4 - por Tipo de Manutencao                           |
	//|                				5 - por Area de Manutencao                           |
	//|                				6 - por Servico de Manutencaoe do Banco de Dados     |
	//|                				7 - por Prioridade da O.S.                           |
	//+----------------------------------------------------------------------------------+

	//Salva marcados e limpa os registros da tabela
	dbSelectArea(cAliMKB)
	dbGoTop()
	While !Eof()
		aAdd(aOldMKB,{(cAliMKB)->CODIGO,(cAliMKB)->OK})
		dbSkip()
	EndDo
	ZAP

	//+----------------------------------------------+
	//| Montagem do Markbrowse para Ordem de Servico |
	//+----------------------------------------------+
	If cTpConV == "1" //ORDEM DE SERVICO
		dbSelectArea("STJ")
		dbSetOrder(01)
		//dbGoTop()
		dbSeek(xFilial("STJ"))
		While !Eof() .And. STJ->TJ_FILIAL == xFilial("STJ")

			If (STJ->TJ_DTMPFIM < dDataBase)
				If (STJ->TJ_TIPOOS $ "BL" .And. STJ->TJ_TERMINO = 'N')

					lLoop := .F.

					If (STJ->TJ_TIPOOS == "L" .And. !lChkLc) .Or.;  //Considera O.S. tipo Localizacao?
					(STJ->TJ_TIPOOS == "B" .And. !lChkBm) .Or.;     //Considera O.S. tipo Bem?
					((STJ->TJ_TIPOOS == "B") .And. (NGSEEK("ST9",STJ->TJ_CODBEM,1,"T9_SITBEM") != "A"))  //Bem inativo
						lLoop := .T.
					EndIf

					If cTpVisV != "7"
						If STJ->TJ_SITUACA != 'L'
							lLoop := .T.
						EndIf
					Else
						If Empty(STJ->TJ_STFOLUP)
							lLoop := .T.
						EndIf
					EndIf

					If lLoop
						STJ->(dbSkip())
						Loop
					EndIf

					Do Case
						Case cTpVisV == "1"  //TODOS
						cCodigo := STR0054  // "TODOS"
						cDescri := cCodigo
						Case cTpVisV == "2"  //FAMILIA
						cCodigo := If(STJ->TJ_TIPOOS == "L","LOCALI",NGSEEK("ST9",STJ->TJ_CODBEM,1,"T9_CODFAMI"))
						cDescri := If(STJ->TJ_TIPOOS == "L",STR0055,cCodigo)  //"LOCALIZAÇÃO"
						Case cTpVisV == "3"  //TIPO
						cCodigo := NGSEEK("STE",STJ->TJ_TIPO,1,"TE_TIPOMAN")
						cDescri := cCodigo
						Case cTpVisV == "4"  //AREA
						cCodigo := NGSEEK("STD",STJ->TJ_CODAREA,1,"TD_CODAREA")
						cDescri := cCodigo
						Case cTpVisV == "5"  //SERVICO
						cCodigo := NGSEEK("ST4",STJ->TJ_SERVICO,1,"T4_SERVICO")
						cDescri := cCodigo
						Case cTpVisV == "6"  //PRIORIDADE
						cCodigo := STJ->TJ_PRIORID
						cDescri := cCodigo
						Case cTpVisV == "7" .And. lFolup //STATUS
						cCodigo := STJ->TJ_STFOLUP
						cDescri := NGSEEK("TQW",STJ->TJ_STFOLUP,1,"TQW_DESTAT")
					EndCase

					nSituac := (dDataBase-STJ->TJ_DTMPFIM)

					//aMKBReg => {CODIGO,DESCRI,QNT,SOMA&MEDIA_ATRASO,MAX_ATRASO,MIN_ATRASO}
					If (nC := aScan(aMKBReg, {|x| x[1] == cCodigo})) == 0
						aAdd(aMKBReg,{cCodigo,cDescri,1,nSituac,nSituac,nSituac})
					Else
						aMKBReg[nC,3]++
						aMKBReg[nC,4] += nSituac
						aMKBReg[nC,5] := If(nSituac > aMKBReg[nC,5],nSituac,aMKBReg[nC,5])
						aMKBReg[nC,6] := If(nSituac < aMKBReg[nC,6],nSituac,aMKBReg[nC,6])
					EndIf

				EndIf
			EndIf

			dbSelectArea("STJ")
			dbSkip()

		EndDo

		//+----------------------------------------------+
		//| Gravacao do Arq. Tempor.                      |
		//+----------------------------------------------+
		For nC := 1 To Len(aMKBReg)
			dbSelectArea(cAliMKB)
			RecLock((cAliMKB),.T.)
			(cAliMKB)->CODIGO := aMKBReg[nC,1]
			(cAliMKB)->DESCRI := aMKBReg[nC,2]
			(cAliMKB)->QNTATR := aMKBReg[nC,3]
			(cAliMKB)->MEDATO := aMKBReg[nC,4]
			aMKBReg[nC,4] /= aMKBReg[nC,3]
			(cAliMKB)->MEDATR := aMKBReg[nC,4]
			(cAliMKB)->MAXATR := aMKBReg[nC,5]
			(cAliMKB)->MINATR := aMKBReg[nC,6]
			If (nD := aScan(aOldMKB, {|x| x[1] == (cAliMKB)->CODIGO})) > 0
				(cAliMKB)->OK := aOldMKB[nD,2]
			EndIf
			MsUnLock((cAliMKB))
		Next nC

		dbSelectArea(cAliMKB)
		dbGoTop()
		If (cAliMKB)->(RecCount()) == 1 .And. !IsMark('OK',cMarca)
			M990MarkOne()
		EndIf
		oMark:oBrowse:Refresh()

		//Esconde browse de Detalhes (sobrepoem panel)
		oPnlBX:Show()

		//+----------------------------------------------+
		//| Montagem do Markbrowse para Manutencao       |
		//+----------------------------------------------+
	ElseIf cTpConV == "2" //MANUTENCAO

		dbSelectArea("STF")
		dbSetOrder(01)
		//dbGoTop()
		dbSeek(xFilial("STF"))

		While !Eof() .And. STF->TF_FILIAL == xFilial("STF")

			If STF->TF_ATIVO <> "N" .And. STF->TF_PERIODO <> "E"

				dbSelectArea("ST9")
				dbSetOrder(01)
				dbSeek(xFilial("ST9")+STF->TF_CODBEM)

				If ST9->T9_SITBEM != "A" .Or. ST9->T9_SITMAN != "A"
					STF->(dbSkip())
					Loop
				EndIf

				//+----------------------------------------------+
				//| Verifica atraso da Manutencao  (MNTR895)     |
				//+----------------------------------------------+
				nSituac := 0
				cCodigo := ""

				cTipAcomp := STF->TF_TIPACOM
				If STF->TF_TIPACOM == 'A'
					dDATATEM := NGPROXMAN(STF->TF_DTULTMA,"T",STF->TF_TEENMAN,;
					STF->TF_UNENMAN,STF->TF_CONMANU,STF->TF_INENMAN,;
					ST9->T9_CONTACU,ST9->T9_VARDIA)
					dDATACON := NGPROXMAN(ST9->T9_DTULTAC,"C",STF->TF_TEENMAN,;
					STF->TF_UNENMAN,STF->TF_CONMANU,STF->TF_INENMAN,;
					ST9->T9_CONTACU,ST9->T9_VARDIA)

					dDataRet := If(dDATATEM < dDATACON,dDATATEM,dDATACON)
					cTipAcomp := If(dDATATEM < dDATACON,"T","C")

				Else
					dDataRet := NGXPROXMAN(STF->TF_CODBEM)
				EndIf

				nSituac := dDataBase - dDataRet

				If nSituac > 0
					If cTpVisV == "1"  //TODOS
						cCodigo := STR0054  //"TODOS"
					ElseIf cTpVisV == "2" //FAMILIA
						cCodigo := NGSEEK("ST9",STF->TF_CODBEM,1,"T9_CODFAMI")
					ElseIf cTpVisV == "3" //TIPO
						cCodigo := STF->TF_TIPO
					ElseIf cTpVisV == "4" //AREA
						cCodigo := STF->TF_CODAREA
					ElseIf cTpVisV == "5" //SERVICO
						cCodigo := STF->TF_SERVICO
					ElseIf cTpVisV == "6" //PRIORIDADE
						cCodigo := STF->TF_PRIORID
					EndIf

					//aMKBReg => {CODIGO,DESCRI,QNT,SOMA&MEDIA_ATRASO,MAX_ATRASO,MIN_ATRASO}
					If (nC := aScan(aMKBREG, {|x| x[1] == cCodigo})) == 0
						aAdd(aMKBReg,{cCodigo,cCodigo,1,nSituac,nSituac,nSituac})
					Else
						aMKBReg[nC,3]++
						aMKBReg[nC,4] += nSituac
						aMKBReg[nC,5] := If(nSituac > aMKBReg[nC,5],nSituac,aMKBReg[nC,5])
						aMKBReg[nC,6] := If(nSituac < aMKBReg[nC,6],nSituac,aMKBReg[nC,6])
					EndIf

				EndIf

			EndIf
			dbSelectArea("STF")
			dbSkip()
		EndDo

		//+----------------------------------------------+
		//| Gravacao do Arq. Tempor.                     |
		//+----------------------------------------------+
		For nC := 1 To Len(aMKBReg)
			dbSelectArea(cAliMKB)
			RecLock((cAliMKB),.T.)
			(cAliMKB)->CODIGO := aMKBReg[nC,1]
			(cAliMKB)->DESCRI := aMKBReg[nC,2]
			(cAliMKB)->QNTATR := aMKBReg[nC,3]
			(cAliMKB)->MEDATO := aMKBReg[nC,4]
			aMKBReg[nC,4] /= aMKBReg[nC,3]
			(cAliMKB)->MEDATR := aMKBReg[nC,4]
			(cAliMKB)->MAXATR := aMKBReg[nC,5]
			(cAliMKB)->MINATR := aMKBReg[nC,6]
			If (nD := aScan(aOldMKB, {|x| x[1] == (cAliMKB)->CODIGO})) > 0
				(cAliMKB)->OK := aOldMKB[nD,2]
			EndIf
			MsUnLock((cAliMKB))
		Next nC

		dbSelectArea(cAliMKB)
		dbGoTop()
		If (cAliMKB)->(RecCount()) == 1 .And. !IsMark('OK',cMarca)
			M990MarkOne()
		EndIf
		oMark:oBrowse:Refresh()

		//Esconde browse de Detalhes (sobrepoem panel)
		oPnlBX:Show()

	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNC990DET
Processamento da consulta/visualizacao dos detalhes
@author  Felipe N. Welter
@since 10/08/09
@version undefined
@param cTpConV, characters, descricao
@param cTpVisV, characters, descricao
@type function
/*/
//---------------------------------------------------------------------
Static Function MNC990DET(cTpConV,cTpVisV)

	Local aMarkd := {}
	Local cCodigo

	//Limpa os registros da tabela
	dbSelectArea(cAliDET)
	ZAP

	dbSelectArea(cAliMKB)
	dbGoTop()
	While !Eof()

		If IsMark('OK',cMarca)
			If cTpVisV $ "2/4/5" //FAMILIA//AREA//SERVICO
				aAdd(aMarkd,SubStr((cAliMKB)->CODIGO,1,6))
			ElseIf cTpVisV $ "3/6" //TIPO//PRIORIDADE
				aAdd(aMarkd,SubStr((cAliMKB)->CODIGO,1,3))
			ElseIf cTpVisV $ "7" .And. lFolup //STATUS
				aAdd(aMarkd,SubStr((cAliMKB)->CODIGO,1,6))
			Else
				aAdd(aMarkd,AllTrim((cAliMKB)->CODIGO))
			EndIf
		EndIf

		dbSelectArea(cAliMKB)
		dbSkip()
	EndDo

	dbGoTop()
	If Len(aMarkd) == 0
		ShowHelpDlg(STR0058,{STR0052,""},2,; //"INVALIDO"###"Não foram marcados itens para visualização das Manutenções."
		{STR0053,""},2) //"É necessário marcar no browse os itens que se deseja visualizar."
		oPnlBX:Show()
		Return .F.
	EndIf

	//+----------------------------------------------+
	//| Montagem dos detalhes para Ordem de Servico  |
	//+----------------------------------------------+
	If cTpConV == "1" //ORDEM

		dbSelectArea("STJ")
		dbSetOrder(01)
		//dbGoTop()
		dbSeek(xFilial("STJ"))
		ProcRegua(STJ->(RecCount()))
		While !Eof() .And. STJ->TJ_FILIAL == xFilial("STJ")

			IncProc()
			If (STJ->TJ_DTMPFIM < dDataBase)
				If (STJ->TJ_TIPOOS $ "BL" .And. STJ->TJ_TERMINO = 'N')

					lLoop := .F.

					If (STJ->TJ_TIPOOS == "L" .And. !lChkLc) .Or.;                               //Considera O.S. tipo Localizacao?
					(STJ->TJ_TIPOOS == "B" .And. !lChkBm) .Or.;                                          //Considera O.S. tipo Bem?
					((STJ->TJ_TIPOOS == "B") .And. (NGSEEK("ST9",STJ->TJ_CODBEM,1,"T9_SITBEM") != "A"))  //Bem inativo
						lLoop := .T.
					EndIf

					If cTpVisV != "7"
						If STJ->TJ_SITUACA != 'L'
							lLoop := .T.
						EndIf
					Else
						If Empty(STJ->TJ_STFOLUP)
							lLoop := .T.
						EndIf
					EndIf

					If lLoop
						STJ->(dbSkip())
						Loop
					EndIf

					Do Case
						Case cTpVisV == "1"  //TODOS
						cCodigo := STR0054 //"TODOS"
						Case cTpVisV == "2"  //FAMILIA
						cCodigo := If(STJ->TJ_TIPOOS == "L","LOCALI",NGSEEK("ST9",STJ->TJ_CODBEM,1,"T9_CODFAMI"))
						Case cTpVisV == "3"  //TIPO
						cCodigo := NGSEEK("STE",STJ->TJ_TIPO,1,"TE_TIPOMAN")
						Case cTpVisV == "4"  //AREA
						cCodigo := NGSEEK("STD",STJ->TJ_CODAREA,1,"TD_CODAREA")
						Case cTpVisV == "5"  //SERVICO
						cCodigo := NGSEEK("ST4",STJ->TJ_SERVICO,1,"T4_SERVICO")
						Case cTpVisV == "6"  //PRIORIDADE
						cCodigo := STJ->TJ_PRIORID
						Case cTpVisV == "7" .And. lFolup //STATUS
						cCodigo := STJ->TJ_STFOLUP
					EndCase

					If ( aScan(aMarkd, {|x| x == cCodigo}) > 0 )

						//+----------------------------------------------+
						//| Gravacao do Arq. Tempor.                     |
						//+----------------------------------------------+
						(cAliDET)->(dbAppend())
						(cAliDET)->TMPATR := (dDataBase-STJ->TJ_DTMPFIM)
						(cAliDET)->DTPREV := STJ->TJ_DTMPFIM
						(cAliDET)->ORDEM  := STJ->TJ_ORDEM
						(cAliDET)->PRIORI := STJ->TJ_PRIORID
						(cAliDET)->CODBEM := STJ->TJ_CODBEM
						(cAliDET)->NOMBEM := If(STJ->TJ_TIPOOS == "L",NGSEEK("TAF",'X2'+STJ->TJ_CODBEM,7,"TAF_NOMNIV"),NGSEEK("ST9",STJ->TJ_CODBEM,1,"T9_NOME"))
						(cAliDET)->SERVIC := STJ->TJ_SERVICO
						(cAliDET)->SEQUEN := STJ->TJ_SEQRELA
						(cAliDET)->NOMSER := NGSEEK("ST4",STJ->TJ_SERVICO,1,"T4_NOME")
						(cAliDET)->CODFAM := If(STJ->TJ_TIPOOS == "L","LOCALI",NGSEEK("ST9",STJ->TJ_CODBEM,1,"T9_CODFAMI"))
						If cTpVisV == "7" .And. lFolup
							(cAliDET)->STATUS := STJ->TJ_STFOLUP
							(cAliDET)->DESTAT := NGSEEK("TQW",STJ->TJ_STFOLUP,1,"TQW_DESTAT")
						EndIf
						(cAliDET)->PLANO  := STJ->TJ_PLANO
						(cAliDET)->TIPO	  := STJ->TJ_TIPO
						(cAliDET)->AREA	  := STJ->TJ_CODAREA
						(cAliDET)->RECNBR := STJ->(RecNo())
					EndIf

				EndIf
			EndIf

			dbSelectArea("STJ")
			dbSkip()

		EndDo

		dbSelectArea(cAliDET)
		dbGoTop()
		oListOS:Show()
		oListMan:Hide()
		oListOS:Refresh()

		//+----------------------------------------------+
		//| Montagem dos detalhes para Manutencao        |
		//+----------------------------------------------+
	ElseIf cTpConV == "2" //MANUTENCAO

		dbSelectArea("STF")
		dbSetOrder(01)
		//dbGoTop()
		dbSeek(xFilial("STF"))

		While !Eof() .And. STF->TF_FILIAL == xFilial("STF")

			IncProc()
			If STF->TF_ATIVO <> "N" .And. STF->TF_PERIODO <> "E"

				If cTpVisV == "1"  //TODOS
					cCodigo := STR0054 //"TODOS"
				ElseIf cTpVisV == "2" //FAMILIA
					cCodigo := NGSEEK("ST9",STF->TF_CODBEM,1,"T9_CODFAMI")
				ElseIf cTpVisV == "3" //TIPO
					cCodigo := STF->TF_TIPO
				ElseIf cTpVisV == "4" //AREA
					cCodigo := STF->TF_CODAREA
				ElseIf cTpVisV == "5" //SERVICO
					cCodigo := STF->TF_SERVICO
				ElseIf cTpVisV == "6" //PRIORIDADE
					cCodigo := STF->TF_PRIORID
				EndIf

				If ( aScan(aMarkd, {|x| x == cCodigo}) > 0 )

					dbSelectArea("ST9")
					dbSetOrder(01)
					dbSeek(xFilial("ST9")+STF->TF_CODBEM)

					If ST9->T9_SITBEM != "A" .Or. ST9->T9_SITMAN != "A"
						STF->(dbSkip())
						Loop
					EndIf

					//+----------------------------------------------+
					//| Verifica atraso da Manutencao  (MNTR895)     |
					//+----------------------------------------------+
					nSituac := 0
					cCodigo := ""

					cTipAcomp := STF->TF_TIPACOM
					If STF->TF_TIPACOM == 'A'
						dDATATEM := NGPROXMAN(STF->TF_DTULTMA,"T",STF->TF_TEENMAN,;
						STF->TF_UNENMAN,STF->TF_CONMANU,STF->TF_INENMAN,;
						ST9->T9_CONTACU,ST9->T9_VARDIA)
						dDATACON := NGPROXMAN(ST9->T9_DTULTAC,"C",STF->TF_TEENMAN,;
						STF->TF_UNENMAN,STF->TF_CONMANU,STF->TF_INENMAN,;
						ST9->T9_CONTACU,ST9->T9_VARDIA)

						dDataRet := If(dDATATEM < dDATACON,dDATATEM,dDATACON)
						cTipAcomp := If(dDATATEM < dDATACON,"T","C")

					Else
						dDataRet := NGXPROXMAN(STF->TF_CODBEM)
					EndIf

					nSituac := dDataBase - dDataRet

					If nSituac > 0

						//+----------------------------------------------+
						//| Gravacao do Arq. Tempor.                     |
						//+----------------------------------------------+
						dbSelectArea(cAliDET)
						RecLock((cAliDET),.T.)
						(cAliDET)->TMPATR := nSituac
						(cAliDET)->DTPREV := dDataRet
						(cAliDET)->PRIORI := STF->TF_PRIORID
						(cAliDET)->CODBEM := STF->TF_CODBEM
						(cAliDET)->NOMBEM := NGSEEK("ST9",STF->TF_CODBEM,1,"T9_NOME")
						(cAliDET)->SERVIC := STF->TF_SERVICO
						(cAliDET)->SEQUEN := STF->TF_SEQRELA
						(cAliDET)->NOMSER := NGSEEK("ST4",STF->TF_SERVICO,1,"T4_NOME")
						(cAliDET)->CODFAM := NGSEEK("ST9",STF->TF_CODBEM,1,"T9_CODFAMI")
						(cAliDET)->TIPO	  := STF->TF_TIPO
						(cAliDET)->AREA	  := STF->TF_CODAREA
						(cAliDET)->RECNBR := STF->(RecNo())
						MsUnLock((cAliDET))
					EndIf

				EndIf

			EndIf
			dbSelectArea("STF")
			dbSkip()
		EndDo

		dbSelectArea(cAliDET)
		dbGoTop()
		oListMan:Show()
		oListOS:Hide()
		oListMan:Refresh()
	EndIf

	oPnlBX:Hide()

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT990IMP
Funçaõ que imprime o relatório de consulta de ordens de serviço
e manuteções atrasadas.
@author Elynton Fellipe Bazzo
@since 21/02/2014
@return Nil
/*/
//---------------------------------------------------------------------
Function MNT990IMP()

	Local cString	:= "ST9"
	Local cDesc1	:= STR0062 //"O.S e Manutenções Atrasadas"
	Local cDesc2	:= ""
	Local cDesc3	:= ""
	Local wnrel	:= "MNTC990"
	Local aArea	:= GetArea()

	Private aReturn   := {STR0063, 1,STR0064, 2, 2, 1, "",1 } //"Zebrado"#"Administracao"
	Private nLastKey 	:= 0
	Private ntipo		:= 0
	Private Titulo   	:= cDesc1
	Private Tamanho  	:= "G"

	//Envia controle para a funcao SETPRINT
	wnrel := SetPrint(cString,wnrel,,titulo,cDesc1,cDesc2,cDesc3,.F.,"")
	If nLastKey = 27
		Set Filter To
		Return
	EndIf

	SetDefault( aReturn,cString )
	RptStatus({| lEnd | C990Imp(@lEnd,wnRel,titulo,tamanho)},titulo)
	RestArea(aArea)
Return Nil
//---------------------------------------------------------------------
/*/{Protheus.doc} C990Imp
Função que monta o cabeçalho e imprime o conteúdo do relatório.

@author Elynton Fellipe Bazzo
@since 21/02/2014
@return Nil
/*/
//---------------------------------------------------------------------
Function C990Imp(lEnd,wnRel,titulo,tamanho)

	Local cRodaTxt	  := ""
	Local nCntImpr	  := 0
	Local lImp		  := .F. // Variável de controle, para impressão do rodapé.
	Local aArea	      := GetArea()
	Local cAlsQry     := GetNextAlias()
	Local cFieldOrd   := ''
	Local cFldAgrup   := ''
	Local cOrderBy    := ''
	Local cTable      := ''

	Private lPriImp	  := .T., lTodos := .T.
	Private nQtdTotOs := 0, nTemTotAt := 0
	Private li		  := 80
	Private m_pag	  := 1
	Private Cabec1	  := " "
	Private Cabec2	  := " "
	Private nomeprog  := "MNTC990"
	nTipo             := IIF(aReturn[4]==1,15,18)

	// Classifica Por:
	Do Case

		Case cTpCla == '1' // Tempo Atraso

			cDesTpCla := STR0065 // Classifica por: Tempo Atraso
			cFieldOrd := 'TMPATR'

		Case cTpCla == '2' // Prioridade

			cDesTpCla := STR0066 // Classifica por: Prioridade
			cFieldOrd := 'PRIORI'

		Case cTpCla == '3' // Bem

			cDesTpCla := STR0067 // Classifica por: Bem
			cFieldOrd := 'CODBEM'

		Case cTpCla == '4' // Serviço

			cDesTpCla := STR0068 // Classifica por: Serviço
			cFieldOrd := 'SERVIC'

	EndCase

	// O.S. Atrasadas Por:
	Do Case

		Case cTpVis == '1' // Todos

			cDescTpVi := STR0070 // Todos
			cFldAgrup := 'DTPREV'

		Case cTpVis == '2' // Família

			cDescTpVi := STR0071 // Família
			cFldAgrup := 'CODFAM'
			cDescri	  := (cAliDET)->CODFAM

		Case cTpVis == '3' // Tipo

			cDescTpVi := STR0072 // Tipo
			cFldAgrup := 'TIPO'
			cDescri	  := (cAliDET)->TIPO

		Case cTpVis == '4' // Área

			cDescTpVi := STR0073 // Área
			cFldAgrup := 'AREA'
			cDescri	  := (cAliDET)->AREA

		Case cTpVis == '5' // Serviço

			cDescTpVi := STR0074 // Serviço
			cFldAgrup := 'SERVIC'
			cDescri	  := (cAliDET)->SERVIC

		Case cTpVis == '6' // Prioridade

			cDescTpVi := STR0075 // Prioridade
			cFldAgrup := 'PRIORI'
			cDescri	  := (cAliDET)->PRIORI

		Case cTpVis == '7' // Status

			cDescTpVi := STR0028 // Status
			cFldAgrup := 'STATUS'
			cDescri	  := (cAliDET)->STATUS

	EndCase

	// Cabeçalho
	If cTpCons == "1" //Ordem.
		Cabec1 := STR0069 + AllTrim( cDescTpVi ) + Space(50) + AllTrim( cDesTpCla )
	Else //Manutenção.
		Cabec1 := STR0098 + AllTrim( cDescTpVi ) + Space(50) + AllTrim( cDesTpCla )
	EndIf

	cCodFam  := (cAliDET)->CODFAM //Código Família
	cCodSer  := (cAliDET)->SERVIC //Código Serviço
	cCodPri  := (cAliDET)->PRIORI //Código Prioridade
	cTipo	 := (cAliDET)->TIPO	  //Tipo Serviço
	cCodArea := (cAliDET)->AREA	  //Area da Manutenção
	cStatus	 := (cAliDET)->STATUS //Status da O.S.
	cOrderBy := '%TMP.' + cFldAgrup + ', TMP.' + cFieldOrd + '%'
	cTable   := '%' + oDetails:GetRealName() + '%'

	// O.S. e Manutenções Atrasadas.
	BeginSQL Alias cAlsQry

		SELECT
			TMP.*
		FROM
			%exp:cTable% TMP
		ORDER BY
			%exp:cOrderBy%

	EndSQl

	SetRegua( LastRec() )

	Do While (cAlsQry)->( !EoF() )

		IncRegua()

		If lImp
			MNT990ROD() //Função que imprime o rodapé do relatório.
		EndIf

		MNT990CON( cAlsQry ) // Função que imprime o conteúdo do relatório.

		cCodFam  := (cAlsQry)->CODFAM // Código Família
		cCodSer  := (cAlsQry)->SERVIC // Código Serviço
		cCodPri  := (cAlsQry)->PRIORI // Código Prioridade
		cTipo	 := (cAlsQry)->TIPO	  // Tipo Serviço
		cCodArea := (cAlsQry)->AREA	  // Area da Manutenção
		cStatus	 := (cAlsQry)->STATUS //Status da O.S.
		lImp 	 := .F. 			  //Variável de controlde -> impressão.

		 (cAlsQry)->( dbSkip() )

		If cTpVis == "2" //Família
			If cCodFam <> (cAlsQry)->CODFAM
				lImp := .T.
			EndIf
		ElseIf cTpVis == "3" //Tipo
			If cTipo <> (cAlsQry)->TIPO
				lImp := .T.
			EndIf
		ElseIf cTpVis == "4" //Área
			If cCodArea <> (cAlsQry)->AREA
				lImp := .T.
			EndIf
		ElseIf cTpVis == "5" //Serviço
			If cCodSer <> (cAlsQry)->SERVIC
				lImp := .T.
			EndIf
		ElseIf cTpVis == "6" //Prioridade
			If cCodPri <> (cAlsQry)->PRIORI
				lImp := .T.
			EndIf
		ElseIf cTpVis == "7" //Status
			If cStatus <> (cAlsQry)->STATUS
				lImp := .T.
			EndIf
		EndIf

	EndDo

	MNT990ROD() //Função que imprime o rodapé com as informações referentes ao conteúdo.

	If cTpVis <> "1" //Todos
		NGSOMALI(58)
		NGSOMALI(58)
		If cTpCons == "1"
			@Li,005 Psay STR0076 // "Quantidade Total OS's.........:"
		Else
			@Li,005 Psay STR0100 // "Quantidade Total Manutenção....:"
		EndIf
		@Li,036 Psay nQtdTotOs	Picture cPicForN
		NGSOMALI(58)
		@Li,005 Psay STR0077 // "Tempo Total de Atraso.........:"
		@Li,036 Psay nTemTotAt	Picture cPicForN
	EndIf

	Roda(nCntImpr,cRodaTxt,Tamanho)
	Set Filter To
	Set Device To Screen

	If aReturn[5] = 1
		Set Printer To
		dbCommitAll()
		OurSpool(wnrel)
	EndIf

	(cAlsQry)->( dbCloseArea() )

	MS_FLUSH()
	RestArea(aArea)

Return Nil

//-----------------------------------------------------------------------------
/*/{Protheus.doc} MNT990CON
Função que imprime o conteúdo do relatório.
@type function

@author Elynton Fellipe Bazzo
@since 21/02/2014

@param cAlsQry, Caracter, Alias contendo registros para impressão já ordenados.
@return Nil
/*/
//-----------------------------------------------------------------------------
Static Function MNT990CON( cAlsQry )

	Local lImprime := .F.

	If cTpVis == "1" //Todos
		cDescTpVi 	:= STR0070
		cDescri	:= STR0070
		lPriImp	:= .F.
	ElseIf cTpVis == "2" //Família
		cDescTpVi	:= STR0071
		cDescri		:= (cAlsQry)->CODFAM
		If cCodFam <> (cAlsQry)->CODFAM .Or. lPriImp
			lImprime := .T.
			lPriImp	 := .F.
		EndIf
	ElseIf cTpVis == "3" //Tipo
		cDescTpVi	:= STR0072
		cDescri		:= (cAlsQry)->TIPO
		If cTipo <> (cAlsQry)->TIPO .Or. lPriImp
			lImprime := .T.
			lPriImp	 := .F.
		EndIf
	ElseIf cTpVis == "4" //Área
		cDescTpVi	:= STR0073
		cDescri		:= (cAlsQry)->AREA
		If cCodArea <> (cAlsQry)->AREA .Or. lPriImp
			lImprime := .T.
			lPriImp	 := .F.
		EndIf
	ElseIf cTpVis == "5" //Serviço
		cDescTpVi := STR0074
		cDescri	  := (cAlsQry)->SERVIC
		If cCodSer <> (cAlsQry)->SERVIC .Or. lPriImp
			lImprime := .T.
			lPriImp	 := .F.
		EndIf
	ElseIf cTpVis == "6" //Prioridade
		cDescTpVi := STR0075
		cDescri   := (cAlsQry)->PRIORI
		If cCodPri <> (cAlsQry)->PRIORI .Or. lPriImp
			lImprime := .T.
			lPriImp	 := .F.
		EndIf
	ElseIf cTpVis == "7" //Status
		cDescTpVi := STR0028
		cDescri   := (cAlsQry)->STATUS
		If cStatus <> (cAlsQry)->STATUS .Or. lPriImp
			lImprime := .T.
			lPriImp	 := .F.
		EndIf
	EndIf

	If lPriImp .Or. lImprime .Or. lTodos
		NGSOMALI(58)
		If cTpVis <> "1" //Todos
			@Li,000 Psay cDescTpVi+"....: "+cDescri
		Else
			If cTpCons == "1"
				@Li,000 Psay STR0102+"....: "+cDescri
			Else
				@Li,000 Psay STR0101+"....: "+cDescri
			EndIf
		EndIf
		NGSOMALI(58)
		If cTpCons == "1" // Se a consulta for por ordem.
			@Li,005 Psay STR0081 //"T. Atraso"
			@Li,019 Psay STR0082 //"O.S."
			@Li,028 Psay STR0083 //"Prioridade"
			@Li,043 Psay STR0084 //"Bem"
			@Li,062 Psay STR0085 //"Desc. Bem"
			@Li,087 Psay STR0086 //"Família"
			@Li,103 Psay STR0087 //"Serviço"
			@Li,126 Psay STR0088 //"Desc. Serviço"
			@Li,153 Psay STR0089 //"Sequência"
			@Li,180 Psay STR0090 //"Status"
			@Li,190 Psay STR0091 //"Desc. Status"
			@Li,214 Psay STR0092 //"Plano"
		Else
			@Li,005 Psay STR0081 //"T. Atraso"
			@Li,028 Psay STR0083 //"Prioridade"
			@Li,050 Psay STR0084 //"Bem"
			@Li,075 Psay STR0085 //"Desc. Bem"
			@Li,120 Psay STR0086 //"Família"
			@Li,150 Psay STR0087 //"Serviço"
			@Li,180 Psay STR0088 //"Desc. Serviço"
			@Li,211 Psay STR0089 //"Sequência"
		EndIf
	EndIf
	lTodos := .F.

	If cTpCons == "1" // Consulta por ordem.

		NGSOMALI(58) //Pula Linha.
		@Li,000 Psay (cAlsQry)->TMPATR Picture cPicForN // T. Atraso
		@Li,019 Psay (cAlsQry)->ORDEM                   // Ordem
		@Li,028 Psay (cAlsQry)->PRIORI                  // Prioridade
		@Li,043 Psay (cAlsQry)->CODBEM                  // Código do Bem
		@Li,062 Psay SubStr( (cAlsQry)->NOMBEM, 1, 20 ) // Descrição do Bem
		@Li,087 Psay (cAlsQry)->CODFAM                  // Código da Família
		@Li,103 Psay (cAlsQry)->SERVIC                  // Serviço
		@Li,126 Psay SubStr( (cAlsQry)->NOMSER, 1, 20 ) // Descrição do Serviço
		@Li,161 Psay (cAlsQry)->SEQUEN                  // Sequência
		@Li,180 Psay (cAlsQry)->STATUS                  // Status
		@Li,190 Psay (cAlsQry)->DESTAT                  // Descrição do Status
		@Li,215 Psay (cAlsQry)->PLANO                   // Plano

	Else // Consulta por manutenção.

		NGSOMALI(58)
		@Li,000 Psay (cAlsQry)->TMPATR Picture cPicForN // T. Atraso
		@Li,028 Psay (cAlsQry)->PRIORI                  // Prioridade
		@Li,050 Psay (cAlsQry)->CODBEM                  // Código do Bem
		@Li,075 Psay SubStr( (cAlsQry)->NOMBEM, 1, 20 ) // Descrição do Bem
		@Li,120 Psay (cAlsQry)->CODFAM                  // Código da Família
		@Li,150 Psay (cAlsQry)->SERVIC                  // Serviço
		@Li,180 Psay SubStr((cAlsQry)->NOMSER,1,20)     // Descrição do Serviço
		@Li,219 Psay (cAlsQry)->SEQUEN                  // Sequência

	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT990ROD
Função que imprime as quantidades totais e de tempo das manutenções
do relatório.
@author Elynton Fellipe Bazzo
@since 21/02/2014
@return Nil
/*/
//---------------------------------------------------------------------
Static Function MNT990ROD()

	Local cBusca := ""

	If cTpVis == "2"     //Família
		cBusca := cCodFam
	ElseIf cTpVis == "3" //Tipo
		cBusca := cTipo
	ElseIf cTpVis == "4" //Área
		cBusca := cCodArea
	ElseIf cTpVis == "5" //Serviço
		cBusca := cCodSer
	ElseIf cTpVis == "6" //Prioridade
		cBusca := cCodPri
	ElseIf cTpVis == "7" //Status
		cBusca := cStatus
	EndIf

	NGSOMALI(58)//Pula linha
	NGSOMALI(58)

	If cTpVis == "1"   // Se a consulta for por ordem  e a visualização por TODOS.
		DBSelectArea( cAliMKB )
		If cTpCons == "1"
			@Li,005 Psay STR0076 // "Quantidade Total OS's.........:"
		Else
			@Li,005 Psay STR0100 // "Quantidade Total Manutenção...:"
		EndIf
	ElseIf cTpVis $ "23456" // Se a consulta for por ordem e a visualização por Família/Tipo/Area/Serviço/Prioridade.
		DBSelectArea( cAliMKB )
		DBSetOrder( 01 )
		DBSeek( cBusca )
		If cTpCons == "1"
			@Li,005 Psay STR0099 // "Quantidade O.S........:"
		Else
			@Li,005 Psay STR0093 // "Quantidade Manutenção.:"
		EndIf
	EndIf

	@Li,036 Psay (cAliMKB)->QNTATR 	Picture cPicForN
	NGSOMALI(58)
	@Li,005 Psay STR0094 // "Tempo Tot. Atraso.....:"
	@Li,036 Psay (cAliMKB)->MEDATO 	Picture cPicForN
	NGSOMALI(58)
	@Li,005 Psay STR0095 // "Tempo Méd. Atraso.....:"
	@Li,036 Psay (cAliMKB)->MEDATR 	Picture cPicForN
	NGSOMALI(58)
	@Li,005 Psay STR0096 // "Maior Tempo Atraso....:"
	@Li,036 Psay (cAliMKB)->MAXATR 	Picture cPicForN
	NGSOMALI(58)
	@Li,005 Psay STR0097 // "Menor Tempo Atraso....:"
	@Li,036 Psay (cAliMKB)->MINATR 	Picture cPicForN
	NGSOMALI(58)

	nQtdTotOs := nQtdTotOs + (cAliMKB)->QNTATR // Quantidade Total de O.S.
	nTemTotAt := nTemTotAt + (cAliMKB)->MEDATO // Tempo Total de Atraso.

Return Nil