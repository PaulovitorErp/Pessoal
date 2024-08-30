#include 'protheus.ch'
#include 'parmtype.ch'


/*----------------------------------------------------------------------------
ULogMsg

@author  Raquel Pereira
@since   08/04/2017
@version 1.0

Objetivo: padronizar a geração de mensagens no console (antigo Conout).


----------------------------------------------------------------------------*/

User Function UWCLogMsg(cMsg)

Default cMsg 	:= ""

LogMsg(FunName(), 22, 5, 1, '', '', cMsg)

Return()
