#INCLUDE "MNTA305.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE _nVERSAO 1 //Versao do fonte

//-----------------------------------------------------------
/*/{Protheus.doc} MNTA305
Programa para Apontar Pesquisa de Satisfacao das S.S.

@author Lucas Guszak
@since 04/07/2014
@version MP11
@return Nil
/*/
//-----------------------------------------------------------
Function MNTA305( cTipoSS , cCodBem )

	Local aNGBEGINPRM := NGBEGINPRM( _nVERSAO, "MNTA305" )
	Local cFiltroTQB := fFiltroTQB( cTipoSS , cCodBem )
	Local oBrowse
	Private aRotina := {}
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( "TQB" ) // Alias da tabela utilizada
	oBrowse:SetFilterDefault( cFiltroTQB ) //Filtro do Alias
	oBrowse:SetMenuDef( "MNTA305" )  // Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription( STR0001 ) // Descrição do browse // "Apontamento de Satisfação"
	oBrowse:Activate()

	NGRETURNPRM(aNGBEGINPRM)

Return Nil

//-----------------------------------------------------------
/*/{Protheus.doc} MenuDef
Interface da rotina

@author Lucas Guszak
@since 04/07/2014
@version MP11
@return aRotina
/*/
//-----------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}
	
	ADD OPTION aRotina TITLE STR0003 ACTION 'MNTA305SAT(2)' OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0004 ACTION 'MNTA305SAT(4)' OPERATION 4 ACCESS 0 //"Satisfacao" 
	
Return aRotina

//-----------------------------------------------------------
/*/{Protheus.doc} fFiltroTQB
Filtra registros da tabela TQB

@author Lucas Guszak
@since 04/07/2014
@version MP11
@return cCondicao
/*/
//-----------------------------------------------------------
Static Function fFiltroTQB( cTipoSS , cCodBem )
	
	Local cCondicao	:= ''
	Local cAddFiltro	:= ''
	Local lFacilit := If(FindFunction("MNTINTFAC"),MNTINTFAC(),.F.)

	dbSelectArea("TQB")
	
	cCondicao := 'TQB->TQB_FILIAL == "'+ xFilial("TQB")+'"'+'.And. '
	cCondicao += 'Alltrim(TQB->TQB_CDSOLI) == "'+ Alltrim(RetCodUsr()) +'" .And. '
	cCondicao += 'TQB->TQB_SOLUCA == "E" '
	
	If ValType(cCodBem) == "C" .And. ValType(cTipoSS) == "C"
		cCondicao += " .And. TQB->TQB_TIPOSS == '"+cTipoSS
		cCondicao += "' .And. TQB->TQB_CODBEM == '"+Padr(cCodBem,TAMSX3("TQB_CODBEM")[1])+"' "
	EndIf
	
	If lFacilit
		cCondicao += '.And. !Empty(TQB->TQB_SEQQUE) .and. TQB->TQB_SATISF == "2"'
	Else
		cCondicao += '.And. (Empty(TQB->TQB_PSAP) .Or. Empty(TQB->TQB_PSAN)) .And. MNT305CHKP()'
	Endif
	
	If ExistBlock("MNTA3051")
		cAddFiltro := ExecBlock("MNTA3051",.F.,.F.)
		If !Empty(cAddFiltro)
			cCondicao += ' .And. ('+cAddFiltro+')'
		EndIf
	EndIf

Return cCondicao  

//-----------------------------------------------------------
/*/{Protheus.doc} MNTA305SAT
Apontamento de Satisfacao das S.S. 

@author Ricardo Dal Ponte
@since 06/12/2006
@version MP11
@return .T.
/*/
//-----------------------------------------------------------
Function MNTA305SAT(nOpcx)
	
	Local aNGBEGINPRM := NGBEGINPRM( _nVERSAO, "MNTA305" )
	Local lFacilit := If(FindFunction("MNTINTFAC"),MNTINTFAC(),.F.)
	Local lConfirm := .F.
	
	If lFacilit .and. nOpcx != 2
		DbSelectArea("TQB")
		lConfirm := ( MNT307QUE( .F. , TQB->TQB_SOLICI ) == 1 )
	Else
		DbSelectArea( "TQB" )
		lConfirm := !Empty( MNTA280IN( nOpcx , 4 , STR0001 ) )
	Endif
	
	If lConfirm
		If ExistBlock (("MNTA3053"))
			ExecBLock(("MNTA3053"),.F.,.F.)
		EndIf
	Endif
	
	NGRETURNPRM(aNGBEGINPRM)

Return .T.

//-----------------------------------------------------------
/*/{Protheus.doc} MNTA305OBR
Checa se os campos referentes a Satisfação foram informados

@author Evaldo Cevinscki Jr.
@since 13/07/2009
@version MP11
@return lRet
/*/
//-----------------------------------------------------------
Function MNTA305OBR()

	Local lRet := .T.
	
	If Empty(M->TQB_PSAP)
		Help(1," ","OBRIGAT2",,RetTitle("TQB_PSAP"),3,0)
		lRet := .F.
	ElseIf Empty(M->TQB_PSAN)
		Help(1," ","OBRIGAT2",,RetTitle("TQB_PSAN"),3,0)
		lRet := .F.
	EndIf	

Return lRet

//-----------------------------------------------------------
/*/{Protheus.doc} MNT305CHKP
Checa se para o Tipo de Servico da SS usa Pesquisa de Satis.

@author Evaldo Cevinscki Jr.
@since 08/04/2010
@version MP11
@return lUsaPesq
/*/
//-----------------------------------------------------------
Function MNT305CHKP()

	Local aArea := GetArea()
	Local lUsaPesq := !NGCADICBASE("TQ3_PESQST","A","TQ3",.F.) .or. !NGIFDBSEEK('TQ3',TQB->TQB_CDSERV,1) .or. TQ3->TQ3_PESQST != "2"
	
	RestArea(aArea)
	
Return lUsaPesq