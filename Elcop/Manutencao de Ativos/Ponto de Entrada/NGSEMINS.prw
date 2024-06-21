//----------------------------------------------------------------------------
/*/{Protheus.doc} NGSEMINS
O ponto de entrada NGSEMINS ser� executado ao finalizar uma Ordem de Servi�o pelo Retorno de O.S. (MNTA400), 
Fechamento em lote (MNTA510) ou pelo Retorno Modelo 2 (MNTA435) permitindo a finaliza��o sem reporte de insumo.
 
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