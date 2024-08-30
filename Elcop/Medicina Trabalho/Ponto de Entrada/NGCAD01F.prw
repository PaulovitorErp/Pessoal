#Include "Protheus.ch"

User Function NGCAD01F()

Local lRet 

Local cAlias   := PARAMIXB[1] // Alias utilizado para construcao da tela de cadastro.
Local nReg     := PARAMIXB[2] // Numero do registro em questao, quando uma operacao diferente de inclusao.
Local nOpcx    := PARAMIXB[3] // Opcao/Operacao selecionada, pelo  usuario, durante a apresentacao do componente MBrowse.
Local nOpca    := PARAMIXB[4] // Define se o usuario confirmou ou cancelou a tela de cadastro. 1 = Confirmacao; 0 = Cancelamento.
Local cFunName := PARAMIXB[5] // Programa que executou a funcao NGCAD01.//  Se cancelou a tela de cadastro

//If nOpca ==  2

If cFunName == "MDTA695" .And. nOpca == 2
  
  Alert("não permitido")

   lRet := .T.

Endif

Return

 /*Endif//  Verifica o programa que executou a funcao NGCAD01

If cFunName =="MDTA695" U_CSTFCD01(cAlias, nReg, nOpcx) // Efetua consistencias finais
Endif

Return
*/
