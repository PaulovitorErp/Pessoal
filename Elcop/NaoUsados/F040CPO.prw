#include 'protheus.ch'
#include 'rwmake.ch'

User Function F040CPO()
//Estrutura do aCpos original da rotina,
//contendo os campos que foram definidos
//para serem edit�veis na altera��o do t�tulo 
Local aAux := aClone( ParamIxb ) 

//Array para retorno dos campos que poder�o ser editados
//na altera��o de um t�tulo a receber
Local aRet := {}

aAdd( aAux, 'E1_CCUSTO' )
aAdd( aAux, 'E1_ITEMCTA' )
aAdd( aAux, 'E1_CLVL' )

aRet := aClone( aAux )

Return aRet

  

 