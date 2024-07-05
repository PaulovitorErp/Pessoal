//Bibliotecas
#Include "TOTVS.ch"
 
/*/{Protheus.doc} User Function zExe079
Exemplo de como criar uma tabela que ainda n�o existe no banco de dados (tamb�m pode ser usado a ChkFile)
@type Function
@author Atilio
@since 08/12/2022
@obs 
    Fun��o CheckFile
    Par�metros
        + Alias da tabela
        + Nome real da tabela que ficar� no banco de dados
 
    **** Apoie nosso projeto, se inscreva em https://www.youtube.com/TerminalDeInformacao ****
/*/
 
User Function zExe079()
    Local aArea     := FWGetArea()
    Local cAlias    := ""
    Local cArquivo  := ""
 
    //Aciona a verifica��o se a tabela (padr�o) n�o existir, ser� criada
    cAlias    := "ZC2"
    cArquivo  := "ZC2010"
    CheckFile(cAlias, cArquivo)

     FWRestArea(aArea)
Return
