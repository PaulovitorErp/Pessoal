#include 'protheus.ch'
#include 'rwmake.ch'

User Function F040CPO()
//Estrutura do aCpos original da rotina,
//contendo os campos que foram definidos
//para serem editáveis na alteração do título 
Local aAux := aClone( ParamIxb ) 

//Array para retorno dos campos que poderão ser editados
//na alteração de um título a receber
Local aRet := {}

aAdd( aAux, 'E1_CCUSTO' )
aAdd( aAux, 'E1_ITEMCTA' )
aAdd( aAux, 'E1_CLVL' )

aRet := aClone( aAux )

Return aRet

  

 