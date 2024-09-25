#include "PROTHEUS.ch"
#Include 'FWMVCDef.ch'
#Include 'MNTA086.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA086
Classificação de pneus

@author Maria Elisandra de Paula
@since 08/09/20

@return
/*/
//---------------------------------------------------------------------
Function MNTA086()

	Local aNGBeginPrm := NGBeginPrm()
	Local cStatus     := Alltrim( SuperGetMv( 'MV_NGSTAFG', .F., '' ) )
	Local cFiltro     := "ST9->T9_CATBEM == '3' .And. ST9->T9_STATUS = '" + cStatus + "'"
	Local oBrowse
	
	If !Empty( cStatus )
		
		Private cCadastro := STR0001 // "Classificação de Pneus"

		If ExistBlock( 'MNTA0862' )
			cFiltro += ExecBlock( 'MNTA0862', .F., .F. )
		EndIf

		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias( 'ST9' )
		oBrowse:SetDescription( cCadastro )
		oBrowse:SetFilterDefault( cFiltro )
		oBrowse:SetMenuDef('MNTA086')
		oBrowse:AddLegend( 'MNTA086LG() == 1' , 'BR_BRANCO', STR0006 ) // 'Pneu em estoque (entrada por NF)'
		oBrowse:AddLegend( 'MNTA086LG() == 2' , 'BR_AZUL', STR0007 ) // 'Pneu aplicado em veículo'
		oBrowse:AddLegend( 'MNTA086LG() == 3' , 'BR_LARANJA', 'Pneu de inserção múltipla' ) // 'Pneu de inserção múltipla'
		oBrowse:Activate()

		NGReturnPrm( aNGBeginPrm )

	Else
		
		Help(' ',1, STR0005,, STR0004 ,2,0) // "NÃO CONFORMIDADE" #"Para utilizar esta rotina é necessário configurar o parâmetro 'MV_NGSTAFG'"
		
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Opções de menu

@author Maria Elisandra de Paula
@since 01/09/2020

@return aRotina
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRot := {}

	ADD OPTION aRot Title STR0002 Action 'MNTA080CAD("ST9",ST9->(Recno()),4,"3")' OPERATION MODEL_OPERATION_UPDATE ACCESS 0   //'Alterar'
	ADD OPTION aRot TITLE STR0003 ACTION 'VIEWDEF.MNTA083' OPERATION MODEL_OPERATION_VIEW ACCESS 0 //OPERATION 2 "Visualizar"

	If ExistBlock("MNTA0861")
		aRot := ExecBlock("MNTA0861",.F.,.F.,{ aRot } )
	EndIf

Return aRot

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA086LG
Definição de legenda

@author Maria Elisandra de Paula
@since 01/09/2020

@return numerico, Define por qual caminho o pneu foi incluso no sistema
/*/
//---------------------------------------------------------------------
Function MNTA086LG()

	Local nCond := 3 // pneu por inclusão multipla (opção no menu da rotina de pneus)
	Local cAliasQry

	If !Empty( ST9->T9_CODESTO )

		cAliasQry := GetNextAlias()
		BeginSQL Alias cAliasQry

			SELECT COUNT(TQZ.TQZ_CODBEM) COUNT
				FROM %table:TQZ% TQZ
			WHERE TQZ.TQZ_FILIAL = %xFilial:TQZ%
				AND TQZ.TQZ_CODBEM = %exp:ST9->T9_CODBEM%
				AND TQZ.TQZ_NUMSEQ <> ' '
				AND TQZ.TQZ_ORIGEM = 'SD1'
				AND TQZ.%NotDel%

		EndSQL

		If (cAliasQry)->COUNT > 0
			nCond := 1 // Pneu em estoque (entrada por NF)
		EndIf

		(cAliasQry)->( dbCloseArea() )

	Else

		dbSelectArea('TQS')
		dbSetOrder(1)
		If MsSeek( FwXFilial('TQS') + ST9->T9_CODBEM ) .And. !Empty( TQS->TQS_PLACA )
			nCond := 2 // inclusão por estrutura de veículo  (opção no menu da rotina de veículos)
		EndIf

	EndIf

Return nCond
