//Bibliotecas
#Include "TOTVS.ch"
 
/*/{Protheus.doc} User Function zExe079
Exemplo de como criar uma tabela que ainda não existe no banco de dados (também pode ser usado a ChkFile)
@type Function
@author Atilio
@since 08/12/2022
@obs 
    Função CheckFile
    Parâmetros
        + Alias da tabela
        + Nome real da tabela que ficará no banco de dados
 
    **** Apoie nosso projeto, se inscreva em https://www.youtube.com/TerminalDeInformacao ****
/*/
 
User Function zExe079()
    Local aArea     := FWGetArea()
    Local cAlias    := ""
    Local cArquivo  := ""
 
    //Aciona a verificação se a tabela (padrão) não existir, será criada
    cAlias    := "ZC2"
    cArquivo  := "ZC2010"
    CheckFile(cAlias, cArquivo)

     FWRestArea(aArea)
Return
