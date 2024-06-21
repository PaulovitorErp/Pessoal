#Include 'TOTVS.ch'
#Include 'FWMVCDEF.ch'  



 /*
#############################################################################
#############################################################################
## Programa  | MNTA716A  |Autor|  ANDRE CASTILHO		|Data|  03/03/2024 ##
##=========================================================================##
## Desc.| IMPORTA ABASTECIMENTO VIA SCHEDULE                                ##
##=========================================================================##
## Uso       | Elcop	                                               	   ##
#############################################################################
#############################################################################
*/
 
User Function MNTA716A()
 
 Local aRet := {}
 

 /*Deve retornar um array de duas posições contendo respectivamente o

código do layout e também o caminho do arquivo de importação partindo

da pasta cadastrada no "StartPath" dentro do appserver.ini */

 aAdd(aRet, '000006')
 aAdd(aRet,' C:\Totvs\protheus_data\import.txt')
 
Return  aRet