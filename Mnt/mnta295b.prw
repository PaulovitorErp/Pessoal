#INCLUDE "mnta295.ch"
#Include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTA295B
Monta Browse para cadastro de multiplas OS's

@author Cauê Girardi Petri
@since 05/02/2024

/*/
//-------------------------------------------------------------------
Function MNTA295B()

	Local aDBFC 	 := {}
	Local oTmpTbl2
	Local cBkpFun := FunName()
	Local aRotinaBkp := aRotina
	
	aRotina := MenuDef()

	M->TQB_CODBEM := TQB->TQB_CODBEM
	NG280BEMLOC(TQB->TQB_TIPOSS)

	If TQB->TQB_TIPOSS == "B" .And. !NGIFDBSEEK("SH7",NGSEEK("ST9",TQB->TQB_CODBEM,1,"T9_CALENDA"),1)
		Help(" ",1,"NGCALENBEM",,CHR(13) + OemToAnsi(STR0123) + NGSEEK("ST9",TQB->TQB_CODBEM,1,"T9_CALENDA") ,3,0)  //"Calendário: "
		Return .F.
	EndIf

	If TQB->TQB_SOLUCA <> "D"
		MsgInfo(STR0007, STR0008) //"A Solicitação de Serviço não está distribuída!"###"NAO CONFORMIDADE"
		Return
	EndIf

	SetFunName( 'MNTA295B' )

	cCadastro := OemtoAnsi(STR0114) //"Geração das OS's da Solicitação de Serviço"

	aAdd(aDBFC,{"SOLICI"  ,"C", 06,0})
	aAdd(aDBFC,{"ORDEM"   ,"C", 06,0})
	aAdd(aDBFC,{"PLANO"   ,"C", 06,0})
	aAdd(aDBFC,{"TIPOOS"  ,"C", 15,0})
	aAdd(aDBFC,{"CODBEM"  ,"C", 16,0})
	aAdd(aDBFC,{"NOMBEM"  ,"C", 20,0})
	aAdd(aDBFC,{"SERVICO" ,"C", 06,0})
	aAdd(aDBFC,{"NOMSERV" ,"C", 20,0})
	aAdd(aDBFC,{"CCUSTO"  ,"C", 09,0})
	aAdd(aDBFC,{"NOMCUST" ,"C", 20,0})
	aAdd(aDBFC,{"SEQRELA" ,"C", 03,0})
	aAdd(aDBFC,{"PRIORID" ,"C", 03,0})
	aAdd(aDBFC,{"TERMINO" ,"C", 01,0})

	//Intancia classe FWTemporaryTable
	oTmpTbl2:= FWTemporaryTable():New( cTRBC295, aDBFC )
	//Adiciona os Indices
	oTmpTbl2:AddIndex( "Ind01" , {"ORDEM","PLANO"} )
	//Cria a tabela temporaria
	oTmpTbl2:Create()

	aTRBC := {{STR0115,"SOLICI" ,"C"	,06,0,"@!" },; //"Sol.Servico"
	{STR0116,"ORDEM"  ,"C"	,06,0,"@!" },; //"Ordem Serv."
	{STR0117,"PLANO"  ,"C"	,06,0,"@!" },; //"Plano Manut."
	{STR0118,"TIPOOS" ,"C"	,15,0,"@!" },; //"Tipo OS"
	{STR0012,"CODBEM" ,"C"	,16,0,"@!" },; //"Bem"
	{STR0119,"NOMBEM" ,"C"	,20,0,"@!" },; //"Nome do Bem"
	{STR0020,"SERVICO","C"	,06,0,"@!" },; //"Servico"
	{STR0120,"NOMSERV","C"	,20,0,"@!" },; //"Nome Serviço"
	{STR0019,"CCUSTO" ,"C"	,09,0,"@!" },; //"Centro Custo"
	{STR0121,"NOMCUST","C"	,20,0,"@!" },; //"Nome C.Custo"
	{STR0090,"SEQRELA","C"	,03,0,"@!" },; //"Sequencia"
	{STR0111,"PRIORID","C"	,03,0,"@!" }} //"Prioridade"

	Processa({ |lEnd| MNA295TRBC() },STR0113) //"Aguarde... Carregando."

	DbSelectarea(cTRBC295)
	DbGotop()
	mBrowse(6,1,22,75,cTRBC295,aTRBC)

	oTmpTbl2:Delete()

	cCadastro := OemtoAnsi(STR0001) //"Distribuição e Geracao O.S. da Solicitacao Servico"

	SetFunName( cBkpFun )

	aRotina := aRotinaBkp

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do Menu.

@author Cauê Girardi Petri
@since 05/02/24

@return aRotina array com o Menu
/*/
//---------------------------------------------------------------------

Static Function MenuDef()

	Local aRotina := {{STR0042,"MNTA295A" , 0, 2, 0},; //"Visualizar"
					 {STR0109,"MNTA295GOS", 0, 3, 0} } //"Incluir"


Return aRotina
