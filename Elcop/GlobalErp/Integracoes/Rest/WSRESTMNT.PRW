#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE 'RESTFUL.CH'
#INCLUDE "topconn.ch"
#INCLUDE "TBICONN.CH"

// INICIO A CRIAÇÃO DO REST

WSRESTFUL WSRESTMNT DESCRIPTION "SERVICO REST PARA INCLUSAO DE ORDEM DE SERVIÇO/CONSULTA SOLICITAÇÃO DE SERVICO / PEDIDOS DE COMPRA "


// metodo para retornar o numero da solicitação de serviço, pode ser usado para deletar

WSDATA ConsultaSS as STRING

WSDATA ordemservico as STRING

WSDATA ConsultaVeiculo as STRING

WSDATA RetProd as STRING

WSDATA cTipo                                                           AS CHARACTER OPTIONAL

//WSDATA ordemservico                                                       as STRING

// INICIO A CRIAÇÃO DOS METODOS DO WS

//INCLUIR ORDEM DE SERVIÇO

WSMETHOD POST incluios;
DESCRIPTION "INCLUI ORDEM DE SERVIÇO NA STJ";
WSSYNTAX "/incluios";
PATH "incluios" PRODUCES APPLICATION_JSON



//INCLUI PEDIDO DE COMPRA
WSMETHOD POST CriaPedidoCompra;
DESCRIPTION "INCLUI PEDIDO DE COMPRA EXECAUTO";
WSSYNTAX "/CriaPedidoCompra";
PATH "CriaPedidoCompra" PRODUCES APPLICATION_JSON


// METODO PARA CONSULTAR SS

WSMETHOD GET BuscarService;
DESCRIPTION "CONSULTA SOLICITACAO DE SERVICO";
WSSYNTAX "/BuscarService";
PATH "BuscarService" PRODUCES APPLICATION_JSON

// METODO PARA CONSULTAR OS
WSMETHOD GET RetornaOrdemServico;
DESCRIPTION "CONSULTA SOLICITACAO DE ORDEM SERVICO";
WSSYNTAX "/RetornaOrdemServico";
PATH "RetornaOrdemServico" PRODUCES APPLICATION_JSON

// METODO PARA CONSULTAR VEICULOS
WSMETHOD GET FindCar;
DESCRIPTION "CONSULTA VEICULOS";
WSSYNTAX "/FindCar";
PATH "FindCar" PRODUCES APPLICATION_JSON

// METODO PARA CONSULTAR PRODUTOS
WSMETHOD GET FindProduct;
DESCRIPTION "CONSULTA PRODUTOS";
WSSYNTAX "/FindProduct";
PATH "FindProduct" PRODUCES APPLICATION_JSON

ENDWSRESTFUL

/*
+----------------------------------------------------------------------------+
! FICHA TECNICA DO PROGRAMA !
+------------------+---------------------------------------------------------+
!Tipo ! RESTFULL!
+------------------+---------------------------------------------------------+
!Modulo ! FRT- FROTAS!
+------------------+---------------------------------------------------------+
!Nome ! WSRESTMNT !
+------------------+---------------------------------------------------------+
!Descricao ! Rotina criada para consultar SOLICITACAO DE SERVICO!
! !  !
+------------------+---------------------------------------------------------+
!Autor ! ANDRE CASTILHO !
+------------------+---------------------------------------------------------+
!Data de Criacao ! 21/03/2024 !
+------------------+---------------------------------------------------------+
*/


// INICIO DO METODO DE BUSCAR DE S.S TABELA TQB_SOLICI
WSMETHOD GET BuscarService WSRECEIVE ConsultaSS WSREST WSRESTMNT
 
Local lRet:= .T. // VARIAVEL LOGICA DE RETORNO

Local cCodSs:= Self:ConsultaSS // SELF E IGUAL INTERNO TUDO QUE ESTA DENTRO DESTE FONTE

Local aArea:= GetArea() // SELECIONA A AREA

Local oJson:= JsonObject():New() //INSTANCIO A CLASSE PARA TRANSFORMAR A VARIAVEL OJson em Strutura Json

Local oReturn:= JsonObject():New() // CASO O PRODUTO NAO SEJA ENCONTRADO RETORNA UMA MENSAGEM DE ERRO 

Local cReturn //RETORNO DE SUCESSO

Local aDados:= {} // ARRAY QUE SERA POPULADO COM OS DADOS DA S.S

Local cQuery:= ""

Local cPulaLinha:= chr(13) + chr(10)

//oJson:FromJson(Self:GetContent())

Conout("++++++++++++ API REST BUSCA DE SERVICOS ++++++++++++++++")

// INICIO FAZENDO A BUSCA NA TABELA PARA PEGAR O ULTIMO REGISTRO

if Select("TRB") > 0
   TRB - (DBCLOSEAREA())
endif


cQuery:= " SELECT MAX(TQB_SOLICI) AS SEQMAX " + cPulaLinha
cQuery:= " FROM " + RetSqlName("TQB") + " " + cPulaLinha
cQuery:= " WHERE D_E_L_E_T_ <> '*' " + cPulaLinha

TcQuery cQuery New Alias "TRB"

DbSelectArea("TRB") // SELECIONO A AREA DA TABELA TQB
aadd(aDados, JsonObject():New())
aDados[1]['numss'] := TRB->SEQMAX





oReturn:= JsonObject():New()
oReturn['cRet']    := "200"
cReturn:= FwJsonSerialize(oReturn) //serializo o retorno

oJson["solicitass"]  := aDados
cJson:= FwJsonSerialize(oJson)
::SetResponse(cJson)
::SetResponse(cReturn)

TRB->(DbCloseArea())
RestArea(aArea)
FreeObj(oJson)
FreeObj(oReturn)

Return(lRet)






/*
+----------------------------------------------------------------------------+
! FICHA TECNICA DO PROGRAMA !
+------------------+---------------------------------------------------------+
!Tipo ! RESTFULL!
+------------------+---------------------------------------------------------+
!Modulo ! FRT- FROTAS!
+------------------+---------------------------------------------------------+
!Nome ! WSRESTMNT !
+------------------+---------------------------------------------------------+
!Descricao ! Rotina criada para consultar ORDEM DE SERVICO!
! ! !
+------------------+---------------------------------------------------------+
!Autor ! ANDRE CASTILHO !
+------------------+---------------------------------------------------------+
!Data de Criacao ! 21/03/2024 !
+------------------+---------------------------------------------------------+
*/


WSMETHOD GET RetornaOrdemServico WSRECEIVE ordemservico WSREST WSRESTMNT
 
Local lRet:= .T. // VARIAVEL LOGICA DE RETORNO

Local cCodOS:= Self:ordemservico // SELF E IGUAL INTERNO TUDO QUE ESTA DENTRO DESTE FONTE

Local aArea:= GetArea() // SELECIONA A AREA

Local oJson:= JsonObject():New() //INSTANCIO A CLASSE PARA TRANSFORMAR A VARIAVEL OJson em Strutura Json

Local oReturn:= JsonObject():New() // CASO O PRODUTO NAO SEJA ENCONTRADO RETORNA UMA MENSAGEM DE ERRO 

Local cReturn //RETORNO DE SUCESSO

Local aDados:= {} // ARRAY QUE SERA POPULADO COM OS DADOS DA S.S

Local cQuery:= ""

Local cPulaLinha:= chr(13) + chr(10)

//oJson:FromJson(Self:GetContent())

Conout("++++++++++++ API REST RETORNA ORDEM DE SERVICO ++++++++++++++++")


// INICIO FAZENDO A BUSCA NA TABELA PARA PEGAR O ULTIMO REGISTRO

if Select("TRB1") > 0
   TRB1-(DBCLOSEAREA())
endif


cQuery:= " SELECT MAX(TJ_ORDEM) AS SEQMAX " + cPulaLinha
cQuery:= " FROM " + RetSqlName("STJ") + " " + cPulaLinha
cQuery:= " WHERE D_E_L_E_T_ <>'*' " + cPulaLinha

TcQuery cQuery New Alias "TRB1"

DbSelectArea("TRB1") // SELECIONO A AREA DA TABELA TQB
aadd(aDados, JsonObject():New())
aDados[1]['numos'] := TRB1->SEQMAX

oReturn:= JsonObject():New()
oReturn['cRet']    := "200"
cReturn:= FwJsonSerialize(oReturn) //serializo o retorno

oJson["OrdemServ"]   := aDados
cJson:= FwJsonSerialize(oJson)
::SetResponse(cJson)
::SetResponse(cReturn)

TRB1->(DbCloseArea())
RestArea(aArea)
FreeObj(oJson)
FreeObj(oReturn)

Return(lRet)





/*
+----------------------------------------------------------------------------+
! FICHA TECNICA DO PROGRAMA !
+------------------+---------------------------------------------------------+
!Tipo ! RESTFULL!
+------------------+---------------------------------------------------------+
!Modulo ! FRT- FROTAS!
+------------------+---------------------------------------------------------+
!Nome ! WSRESTMNT !
+------------------+---------------------------------------------------------+
!Descricao ! Rotina criada para criar PEDIDO DE COMPRA!
! ! !
+------------------+---------------------------------------------------------+
!Autor ! ANDRE CASTILHO !
+------------------+---------------------------------------------------------+
!Data de Criacao ! 21/03/2024 !
+------------------+---------------------------------------------------------+
*/


WSMETHOD POST CriaPedidoCompra WSRECEIVE WSREST WSRESTMNT


Local lRet:= .T.
Local aArea:= GetArea()
Local oJson:= JsonObject():New()
Local oReturn:= JsonObject():New()
Local cPedido:= ""
Local aCabec:= {}
Local aItens:= {}
Local aItem:= {}
Local aLog:= {}
Local cError := "\logs_pedido\"
Local cMsg  := ""
Local nCount := 0
Local oItems:= Nil
Local nOpc:= 3 // 3 inclusao de pedido de compra 
Local cPulaLinha:= chr(13) + chr(10)
Local TcQuery:= ""
Local i:= 0
Private lMSHelpAuto:= .T. // para nao mostrar os erro na tela
Private lMSErroAuto:= .F. 
Private lAutoErrNoFile:= .T.

   Conout("++++++++++++ API REST CRIA PEDIDO DE COMPRA ++++++++++++++++")

oJson:FromJson(Self:GetContent())  // pego o conteudo do json

oItems:= oJson:GetJsonObject('items')


aAdd(aCabec,{"C7_FILIAL", xFilial("SC7"), NIL})
aAdd(aCabec,{"C7_EMISSAO", CTod(oJson['dDataBase']), NIL})
aAdd(aCabec,{"C7_FORNECE", oJson['cFornece'], NIL })
aAdd(aCabec,{"C7_LOJA", oJson['cLoja'], NIL })
aAdd(aCabec,{"C7_COND", oJson['cCondPag'], NIL })
aAdd(aCabec,{"C7_MOEDA", GetDToVal(oJson['nMoeda']), NIL})
aAdd(aCabec,{"C7_FILENT" , xFilial("SC7"), NIL })

  For i:= 1 To Len(oItems)
         cProduto:= PadR(AllTrim(oItems[i]:GetJsonObject('produto')), TamSX3("C7_PRODUTO")[1])
         cLocal:= PadR(AllTrim(oItems[i]:GetJsonObject('armazem')), TamSX3("C7_LOCAL")[1])
         nQtde:= GetDToVal(oItems[i]:GetJsonObject('quantidade'))//,TamSX3("C7_QUANT")[1]
         nValor:= GetDToVal(oItems[i]:GetJsonObject('precoUnitario'))//,TamSX3("C7_PRECO")[1]
         nTotal:= nQtde * nValor
         cCusto:= AllTrim(oItems[i]:GetJsonObject('custo'))
         cRateio:= AllTrim(oItems[i]:GetJsonObject('rateio'))
         cEMAIL:= AllTrim(oItems[i]:GetJsonObject('email'))

aItem:= {}
         aAdd(aItem, { "C7_ITEM"	, StrZero(i,4)	, NIL })
         aAdd(aItem, { "C7_PRODUTO", cProduto, NIL })
         aAdd(aItem, { "C7_QUANT"	, nQtde, NIL })
         aAdd(aItem, { "C7_PRECO"	, nValor, NIL })
         aAdd(aItem, { "C7_TOTAL"	, nTotal, NIL })
         aAdd(aItem, { "C7_LOCAL"	, cLocal, NIL })
         aAdd(aItem, { "C7_CC"	,    cCusto, NIL })
         aAdd(aItem, { "C7_RATEIO"	,    cRateio, NIL })
         aAdd(aItem, { "C7_XWFMAIL"	, cEMAIL, NIL })
         aAdd(aItens, aItem)

Next

//Executa a inclusão automática de pedido de compras
FwLogMsg("INFO",, "CriarPedido", "WSCOM01", "", "01", "MSExecAuto")
MSExecAuto({| v, x, y, z | MATA120(v, x, y, z)}, 1, aCabec, aItens, nOpc)

    
   If lMsErroAuto // inicializa como .F., volta .T. se houver erro
         aLog:= GetAutoGRlog()
         For nCount:= 1 To Len(aLog)
         cMsg += aLog[nCount] + CRLF
         Next nCount

         oReturn['status'] := EncodeUTF8(cMsg)
         MostraErro(cError,"LogPedidos.txt")
Else
         oReturn["pedido"] := SC7->C7_NUM
         ConOut("Incluido PC:" + SC7->C7_NUM)
EndIf
         Self:SetResponse(oReturn:toJson())
    //     Self:SetResponse(FWJsonDeserialize(oReturn))

        
         Return()

//Self:SetStatus(201)
//Self:SetContentType(APPLICATION_JSON)
//Self:SetResponse(FWJsonDeserialize(oReturn, .F., .F., .T.))
//::SetResponse("Numero do Pedido"+cReturn)


//RestArea(aArea)
//FreeObj(oJson)
//FreeObj(oReturn)









/*
+----------------------------------------------------------------------------+
! FICHA TECNICA DO PROGRAMA !
+------------------+---------------------------------------------------------+
!Tipo ! RESTFULL!
+------------------+---------------------------------------------------------+
!Modulo ! FRT- FROTAS!
+------------------+---------------------------------------------------------+
!Nome ! WSRESTMNT !
+------------------+---------------------------------------------------------+
!Descricao ! Rotina criada para criar CONSULTAR PLACA / VEICULOS
! ! !
+------------------+---------------------------------------------------------+
!Autor ! ANDRE CASTILHO !
+------------------+---------------------------------------------------------+
!Data de Criacao ! 21/03/2024 !
+------------------+---------------------------------------------------------+
*/


WSMETHOD GET FindCar WSRECEIVE ConsultaVeiculo WSREST WSRESTMNT
 
Local lRet:= .T. // VARIAVEL LOGICA DE RETORNO
                                 // SELF E IGUAL INTERNO TUDO QUE ESTA DENTRO DESTE FONTE
Local aArea:= GetArea() // SELECIONA A AREA

Local oJson:= JsonObject():New() //INSTANCIO A CLASSE PARA TRANSFORMAR A VARIAVEL OJson em Strutura Json

Local oReturn:= JsonObject():New() // CASO O PRODUTO NAO SEJA ENCONTRADO RETORNA UMA MENSAGEM DE ERRO 

Local cReturn //RETORNO DE SUCESSO

Local aDados:= {} // ARRAY QUE SERA POPULADO COM OS DADOS DA S.S

Local cQry:= ""

Local cPulaLinha:= chr(13) + chr(10)

Local cPlaca:= Self:ConsultaVeiculo

Local cCodErro:= "informar placa correta"


Conout("++++++++++++ API REST DE CONSULTA DE VEICULOS ++++++++++++++++")


if Select("TAB") > 0
   TAB - (DBCLOSEAREA())
endif

//--------------------------------
// tratativa da chave de busca
//--------------------------------
If!Empty(cPlaca)

cQry:= " SELECT T9_CODBEM, T9_NOME , T9_PLACA, T9_CCUSTO, CTT_DESC01" + cPulaLinha
cQry += " FROM " + RetSqlName('ST9') + " ST9									" + cPulaLinha
cQry += " INNER JOIN " + RetSqlName('CTT') + " CTT ON CTT.CTT_CUSTO = ST9.T9_CCUSTO	" + cPulaLinha
cQry += " WHERE ST9.D_E_L_E_T_ <> '*' AND  CTT.D_E_L_E_T_ <> '*' AND CTT_CLASSE ='2' " + cPulaLinha
cQry += " AND CTT_BLOQ ='2' AND ST9.T9_STATUS ='01'  AND T9_PLACA LIKE '%" + AllTrim(cPlaca) + "%'		" + cPulaLinha

    TcQuery cQry New Alias "TAB"

DbSelectArea("TAB") // SELECIONO A AREA DA TABELA TQB
aadd(aDados, JsonObject(): New())
aDados[1]['cVeiculo']  := ALLTRIM(TAB->T9_CODBEM)
aDados[1]['cNome']    := ALLTRIM(TAB->T9_NOME)
aDados[1]['cPlaca']   := ALLTRIM(TAB->T9_PLACA)
aDados[1]['cCentCusto']:= ALLTRIM(TAB->T9_CCUSTO)
aDados[1]['cCentNome'] := ALLTRIM(TAB->CTT_DESC01)

oJson["cFindCar"]  := aDados[1]

//oReturn              := JsonObject():New()
oReturn['cRet']    := "200"
cReturn:= FwJsonSerialize(oReturn) //serializo o retorno
cJson:= FwJsonSerialize(oJson)



/*
oJson["cVeiculo"]  := aDados[1]
oJson["cNome"]     := aDados[1]
oJson["cPlaca"]    := aDados[1]
oJson["cCentCusto"]:= aDados[1]
oJson["cCentNome"] := aDados[1]
*/


::SetResponse(cJson)
//::SetResponse(cReturn)


TAB->(DbCloseArea())
EndIF

RestArea(aArea)
FreeObj(oJson)
FreeObj(oReturn)

Return(lRet)



/*
+----------------------------------------------------------------------------+
! FICHA TECNICA DO PROGRAMA !
+------------------+---------------------------------------------------------+
!Tipo ! RESTFULL!
+------------------+---------------------------------------------------------+
!Modulo ! FRT- FROTAS!
+------------------+---------------------------------------------------------+
!Nome ! WSRESTMNT !
+------------------+---------------------------------------------------------+
!Descricao ! Rotina criada para CONSULTAR PRODUTOS
! ! !
+------------------+---------------------------------------------------------+
!Autor ! ANDRE CASTILHO !
+------------------+---------------------------------------------------------+
!Data de Criacao ! 21/03/2024 !
+------------------+---------------------------------------------------------+
*/



WSMETHOD GET FindProduct WSRECEIVE RetProd, cTipo WSREST WSRESTMNT
 
Local lRet:= .T. // VARIAVEL LOGICA DE RETORNO
                                 // SELF E IGUAL INTERNO TUDO QUE ESTA DENTRO DESTE FONTE
Local aArea:= GetArea() // SELECIONA A AREA

Local oJson:= JsonObject():New() //INSTANCIO A CLASSE PARA TRANSFORMAR A VARIAVEL OJson em Strutura Json

Local oReturn:= JsonObject():New() // CASO O PRODUTO NAO SEJA ENCONTRADO RETORNA UMA MENSAGEM DE ERRO 

Local cReturn //RETORNO DE SUCESSO

Local aDados:= {} // ARRAY QUE SERA POPULADO COM OS DADOS DA S.S

Local cQry:= ""

Local cPulaLinha:= chr(13) + chr(10)

Local cNomeProduto:= Self:RetProd

Local cTipoProduto:= Self:cTipo

Local oAux:= Nil

Local cCodErro:= "informar placa correta"


Conout("++++++++++++ API REST DE CONSULTA DE VEICULOS ++++++++++++++++")


if Select("TAB") > 0
   TAB-(DBCLOSEAREA())
endif

//--------------------------------
// tratativa da chave de busca
//--------------------------------
If!Empty(cNomeProduto)

cQry:= " 	SELECT " + cPulaLinha
cQry += " 	SB1.B1_COD 			AS CODIGO, " + cPulaLinha
cQry += " 	SB1.B1_DESC 		AS DESCRICAO, " + cPulaLinha
cQry += " 	SB1.B1_UM 			AS UM, " + cPulaLinha
cQry += " 	SB1.B1_GRUPO 		AS B1_GRUPO, " + cPulaLinha
cQry += " 	SB1.B1_POSIPI 		AS B1_POSIPI, " + cPulaLinha
cQry += " 	SB1.B1_TIPO 		AS B1_TIPO, " + cPulaLinha
cQry += " 	SB1.B1_CODBAR		AS CODBAR, " + cPulaLinha
cQry += " 	SB1.B1_MSBLQL     	AS B1_MSBLQL, " + cPulaLinha
cQry += " 	SB1.B1_LOCPAD       AS B1_LOCPAD " + cPulaLinha
cQry += " 	FROM " + RetSqlName("SB1") + " SB1 " + cPulaLinha
 //  cQry += " 	WHERE SB1.D_E_L_E_T_ = '' AND SB1.B1_TIPO IN ('SV', 'PV', 'M2', 'M1') " + cPulaLinha
//	cQry += " 	WHERE SB1.D_E_L_E_T_ = '' AND ( SB1.B1_TIPO ='SV' OR SB1.B1_TIPO ='PV' OR SB1.B1_TIPO ='M2' OR SB1.B1_TIPO ='M1' ) " + cPulaLinha//AND SB1.B1_TIPO LIKE ('SV,PV') " + cPulaLinha
   If cTipoProduto = "SV"
cQry += " WHERE (SB1.B1_TIPO = 'SV' OR SB1.B1_TIPO = 'PV') " + cPulaLinha
    ElseIf cTipoProduto = "M1"
cQry += " WHERE SB1.B1_TIPO = 'M1' " + cPulaLinha
    ElseIf cTipoProduto = "M2"
cQry += " WHERE SB1.B1_TIPO = 'M2' " + cPulaLinha
EndIf
cQry += " 	AND SB1.B1_MSBLQL = '2' AND SB1.B1_XBLOQ = '2' AND SB1.D_E_L_E_T_ = ' '  " + cPulaLinha
cQry += "   AND SB1.B1_DESC LIKE '%" + UPPER(cNomeProduto) + "%' " + cPulaLinha

    TcQuery cQry New Alias "TAB"
EndIf
if TAB->(!Eof())

	//	oResponse["status"] 	:= 100
	//	oResponse["produtos"] 	:= {}
	
      oJson["produtos"] 	:= { }

		While TAB -> (!Eof())

oAux:= JsonObject():New()

aadd(aDados, JsonObject(): New())
oAux["codproduto"]	:= AllTrim(TAB->CODIGO)
oAux["descricao"]	:= EncodeUTF8(cValToChar(AllTrim(TAB->DESCRICAO)))
oAux["unidade"]		:= AllTrim(TAB->UM)
oAux["codbar"]		:= AllTrim(TAB->CODBAR)
oAux["grupo"]		:= AllTrim(TAB->B1_GRUPO)
oAux["status"]		:= IIF(TAB->B1_MSBLQL = '2', 'Ativo', 'Bloqueado')
oAux["ncm"]			:= AllTrim(TAB->B1_POSIPI)
oAux["tipo"]		:= AllTrim(TAB->B1_TIPO)
oAux["LocalPadrao"]	:= AllTrim(TAB->B1_LOCPAD)
aadd(oJson["produtos"], oAux)
FreeObj(oAux)


TAB->(DbSkip())
EndDo
EndIF
oReturn['cRet']    := "200"
cReturn:= FwJsonSerialize(oReturn) //serializo o retorno
cJson:= FwJsonSerialize(oJson)



::SetResponse(cJson)
//::SetResponse(cReturn)


TAB->(DbCloseArea())


RestArea(aArea)
FreeObj(oJson)
FreeObj(oReturn)

Return(lRet)



/*




WSMETHOD POST incluios WSRECEIVE WSREST WSRESTMNT

Local lRet           := .T.

Local aArea          := GetArea()

Local oJson          := JsonObject():New()

Local oReturn        := JsonObject():New()
//Local dOrigem       := oJson['dtaorig']
// carrega os dados vindo da String/Body da resquisição Json
oJson:FromJson(Self:GetContent()) //getcontente pega o conteudo do json


DbSelectArea("STJ")
STJ->(DbSetOrder(1))
if Empty(oJson[ 'nomefor' ])
  // RESTFUL():SetFault(400, 'codigo fornecedor em branco')
   SetRestFault(400, 'codigo fornecedor em branco' )
   lRet                 := .F.
   Return(lRet)

Else
      DbSelectArea("ST9")
      ST9->(DbSetOrder(1))
      STJ->(DbSeek(xFilial("STJ")+(STJ->TJ_CODBEM)))
      oJson[ 'ccusto' ]    := ST9->T9_CCUSTO
      oJson[ 'numos' ]     := GetSXENum( "STJ","TJ_ORDEM" )
   
   RecLock("STJ",.T.)
    STJ->TJ_FILIAL       := cFilAnt
    STJ->TJ_ORDEM        := oJson[ 'numos' ]
    STJ->TJ_PLANO        := '000000'
    STJ->TJ_TIPOOS       := ALLTRIM( 'B' ) //tipoos conteudo B de bem 
    STJ->TJ_CODBEM       := oJson[ 'codbem' ]
  //  STJ->TJ_NOMBEM := oJson['nomebem']
    STJ->TJ_SERVICO      := oJson[ 'codservi' ]
    STJ->TJ_SEQRELA      := '0'
    STJ->TJ_CODAREA      := '000001'
    STJ->TJ_CCUSTO       := oJson[ 'ccusto' ]
 //   STJ->TJ_NOMSERV :=oJson['descserv']
    STJ->TJ_DTORIGI      := cTod(oJson[ 'dtaorig' ]) // inicio ordem de servico
    STJ->TJ_POSCONT      := VAL(oJson[ 'contador1' ])
    STJ->TJ_HORACO1      := oJson[ 'hrleicont1' ] // hora da leitura contador1
    STJ->TJ_OBSERVA      := oJson[ 'obs' ] // campo memo para comentario
    STJ->TJ_SITUACA      := oJson[ 'status' ] // P = pendente, C = cancelada, L = Liberada
    STJ->TJ_POSCON2      := VAL(oJson[ 'contador2' ]) //posição do contador2 na hora da execução
    STJ->TJ_HORACO2      := oJson[ 'hora2' ] // hora da do contador 2
    STJ->TJ_TERCEIR      := oJson[ 'terceiro' ] // indica se foi enviado a terceiro 
    STJ->TJ_DTPRINI      := cTod(oJson[ 'dtareal' ]) // data real da parada do bem
    STJ->TJ_HOPRINI      := oJson[ 'hrreal' ] // hora real da parada do bem
    STJ->TJ_XCODFOR      := oJson[ 'codfor' ] //  codigo fornecedor
    STJ->TJ_XDESCFO      := oJson[ 'nomefor' ] // nome fornecedor
    STJ->TJ_USUARIO      := oJson[ 'usuario' ] //usuario da inclusao
    STJ->TJ_XPLACA       := oJson[ 'placa' ] // placa veiculo
  
  
 STJ->(MsUnlock())
 STJ->(DbCloseArea())
 ST9->(DbCloseArea())
 oReturn[ 'cNumOs' ]  := oJson[ 'numos' ]
 oReturn[ 'cRet' ]    := "Ordem de serviço incluida com sucesso"

Self:SetStatus(201)
Self:SetContentType(APPLICATION_JSON)
Self:SetResponse(FWJsonDeserialize(oReturn))

EndIF

RestArea(aArea)
FreeObj(oJson)
FreeObj(oReturn)

Return(.T.)










