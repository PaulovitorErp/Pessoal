#include "protheus.ch"
#include "fileio.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIsRoute
Modelo de rotas REST

@author  Marcelo Camargo
@since   15/03/2016
@version P11/P12
@param   aUrl - Lista de paths vindos do webservice
@param   cPath - Caminho esperado com padrao para verificacao
@return  logic
/*/
//---------------------------------------------------------------------
Function NGIsRoute( aUrl, cPath )
    Local nI
    Local aPath := StrTokArr( cPath, '/' )

    If Len( aUrl ) <> Len( aPath )
        Return .F.
    EndIf

    For nI := 1 To Len( aUrl )
        If !( aPath[ nI ] == aUrl[ nI ] ) .And. !( SubStr( aPath[ nI ], 1, 1 ) == '{' )
            Return .F.
        EndIf
    Next nI
    Return .T.
