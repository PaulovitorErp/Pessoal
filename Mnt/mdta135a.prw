#include 'Protheus.ch'
#include 'FWMVCDEF.ch'
#include 'Totvs.Ch'

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MDT135A
Classe de evento do MVC Medidas de Controle

@author  Luis Fellipy Bett
@since   24/08/2018
@type    Class
@version 12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
Class MDT135A FROM FWModelEvent

    Method New()
	Method ModelPosVld() //Method de pós validação do modelo

End Class

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Mehtod New para criação da estancia entre o evento e as classes.

@author  Luis Fellipy Bett
@since   24/08/2018
@type    Class
@version 12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
Method New() Class MDT135A

Return

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
Method para pós-validação do Modelo.

@param oModel	- Objeto	- Modelo utilizado.
@param cModelId	- Caracter	- Id do modelo utilizado.

@class MDT135A - Classe origem

@author  Luis Fellipy Bett
@since   24/08/2018
@type    Class
@version 12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
Method ModelPosVld( oModel , cModelId ) Class MDT135A

	Local lRet			:= .T.

	Local aAreaTO4		:= TO4->( GetArea() )

	Local nOperation	:= oModel:GetOperation() // Operação de ação sobre o Modelo

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
	aCHKSQL := NGRETSX9( "TO4" )

	// Recebe relação do Cadastro - Formato:
	// 1 - Chave
	// 2 - Alias
	// 3 - Ordem (Índice)
	aAdd( aCHKDEL , { "TO4->TO4_CONTRO" , "TO3" , 2 } )
	If NGCADICBASE( "TJF_NUMRIS" , "A" , "TJF" , .F. )
		aAdd( aCHKDEL , { "TO4->TO4_CONTRO" , "TJF" , 2 } )
	Endif

	If nOperation == MODEL_OPERATION_DELETE //Exclusão

		If !NGCHKDEL( "TO4" )
			lRet := .F.
		EndIf

		If lRet .And. !NGVALSX9( "TO4" , {} , .T. , .T. )
			lRet := .F.
		EndIf

	EndIf

	RestArea( aAreaTO4 )

Return lRet