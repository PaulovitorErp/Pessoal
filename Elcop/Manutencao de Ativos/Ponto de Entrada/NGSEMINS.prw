//----------------------------------------------------------------------------
/*/{Protheus.doc} NGSEMINS
O ponto de entrada NGSEMINS será executado ao finalizar uma Ordem de Serviço pelo Retorno de O.S. (MNTA400), 
Fechamento em lote (MNTA510) ou pelo Retorno Modelo 2 (MNTA435) permitindo a finalização sem reporte de insumo.
 
@type function

@author Sinval 
@since 01/06/2020

@sample NGSEMINS()

@param
@return lFinaliza
/*/
//----------------------------------------------------------------------------

User Function NGSEMINS()

Local lFinaliza := .T.
 
Return lFinaliza