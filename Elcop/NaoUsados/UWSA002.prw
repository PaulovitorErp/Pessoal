#Include "Protheus.ch"
#Include "Totvs.ch"
#Include "ApWebSrv.ch"
#Include 'RestFul.ch'
#Include "TopConn.ch"
#Include "TbiConn.ch"

/*/-------------------------------------------------------------------
- Programa: UWSA002
- Autor: Tarcisio Silva Miranda
- Data: 06/01/2023
- Descrição: Servico REST utilizado no processo de manutenção de ativo.
-------------------------------------------------------------------/*/

WSRESTFUL UWSA002 DESCRIPTION "Servico REST utilizado no processo de manutenção de ativo fixo"

	WSDATA cFilials  AS String OPTIONAL
	WSDATA cCodBem   AS String OPTIONAL
	WSDATA cCodServ  AS String OPTIONAL
	WSDATA cNumPv    AS String OPTIONAL

	WSMETHOD POST 	postBens 	DESCRIPTION "Inclui Cadastro de Bens ST9." 		WSSYNTAX "/incluibem"  	   	PATH "/incluibem"
	WSMETHOD PUT  	putBens  	DESCRIPTION "Altera Cadastro de Bens ST9." 		WSSYNTAX "/alterabem"  	   	PATH "/alterabem"
	WSMETHOD DELETE deletabem 	DESCRIPTION "Deleta Cadastro de Bens ST9." 		WSSYNTAX "/delbem" 	   	   	PATH "/delbem"
	WSMETHOD POST 	postServico DESCRIPTION "Inclui Cadastro de Serviços ST4." 	WSSYNTAX "/incluiservico"  	PATH "/incluiservico"
	WSMETHOD PUT  	putServico  DESCRIPTION "Altera Cadastro de Serviços ST4." 	WSSYNTAX "/alteraservico"  	PATH "/alteraservico"
	WSMETHOD DELETE excServico 	DESCRIPTION "Deleta Cadastro de Serviços ST4." 	WSSYNTAX "/delservico" 	   	PATH "/delservico"
	WSMETHOD POST 	postPV  	DESCRIPTION "Inclui Pedido de Vendas SC5/SC6." 	WSSYNTAX "/incluipv"   		PATH "/incluipv"
	WSMETHOD PUT  	putPV   	DESCRIPTION "Altera Pedido de Vendas SC5/SC6." 	WSSYNTAX "/alterapv"   		PATH "/alterapv"
	WSMETHOD DELETE deelPV		DESCRIPTION "Deleta Pedido de Vendas SC5/SC6." 	WSSYNTAX "/delpv" 	   		PATH "/delpv"

END WSRESTFUL

/*/-------------------------------------------------------------------z
- Programa: postBens
- Autor: Tarcisio Silva Miranda
- Data: 06/01/2023
- Descrição: API para inclusão de bens.
http://localhost:8400/rest/UWSA002/incluibem
{
"T9_CALENDA": "001",
"T9_CCUSTO" : "110000001",
"T9_CODBEM" : "EMP0003",
"T9_CODFAMI": "222001",
"T9_NOME"   : "TESTE"
}
-------------------------------------------------------------------/*/

WSMETHOD POST postBens WSSERVICE UWSA002

	Local aArea 		:= FWGetArea()
	Local aAreaST9 		:= ST9->(FWGetArea())
	Local cJson			:= ""
	Local cMsgLog 		:= ""
	Local oResponse		:= JsonObject():New()

	Self:SetContentType("application/json; charset=utf-8")
	cJson := AllTrim(Self:GetContent())

	if U_UMNTA002(cJson,3,@cMsgLog)
		oResponse["status"] := 201
		oResponse["msg"] 	:= "Cadastro realizado com sucesso!"
	else
		oResponse["status"] := 500
		oResponse["msg"] 	:= "Erro ao realizar cadastro! " + cMsgLog
	endif

	Self:SetResponse(oResponse:toJson())

	FWRestArea(aAreaST9)
	FwRestArea(aArea)

Return(.T.)

/*/-------------------------------------------------------------------
	- Programa: putBens
	- Autor: Tarcisio Silva Miranda
	- Data: 06/01/2023
	- Descrição: API para alteração de bens.
	http://localhost:8400/rest/UWSA002/alterabem?cFilials=01&cCodBem=EMP0003
	{
	"T9_NOME"   : "TESTE2"
	}
-------------------------------------------------------------------/*/

WSMETHOD PUT putBens WSRECEIVE cFilials, cCodBem WSSERVICE UWSA002

	Local aArea 	:= FWGetArea()
	Local aAreaST9 	:= ST9->(FWGetArea())
	Local oResponse	:= JsonObject():New()
	Local cJson		:= ""
	Local cFilials	:= ""
	Local cCodBem	:= ""
	Local cMsgLog 	:= ""

	Self:SetContentType("application/json; charset=utf-8")
	cJson 		:= AllTrim(Self:GetContent())
	cFilials	:= Padr(AllTrim(Self:cFilials),TamSx3("T9_FILIAL")[1])
	cCodBem		:= Padr(AllTrim(Self:cCodBem),TamSx3("T9_CODBEM")[1])

	ST9->(DbSelectArea("ST9"))
	ST9->(DbSetOrder(1))
	ST9->(DbGotop())

	if ST9->(DbSeek( cFilials +  cCodBem ))
		if U_UMNTA002(cJson,4,@cMsgLog)
			oResponse["status"] := 201
			oResponse["msg"] 	:= "Cadastro alterado com sucesso!"
		else
			oResponse["status"] := 500
			oResponse["msg"] 	:= "Erro ao realizar Alteração : " + cMsgLog
		endif
	else
		oResponse["status"] := 500
		oResponse["msg"] 	:= "Erro ao realizar alteração, registro não localizado!"
	endif

	Self:SetResponse(oResponse:toJson())

	FWRestArea(aAreaST9)
	FwRestArea(aArea)

Return(.T.)

/*/-------------------------------------------------------------------
	- Programa: deleteBem
	- Autor: Tarcisio Silva Miranda
	- Data: 06/01/2023
	- Descrição: API para exclusão de bem.
	http://localhost:8400/rest/UWSA002/delbem?cFilials=01&cCodBem=EMP0003
-------------------------------------------------------------------/*/

WSMETHOD DELETE deletabem WSRECEIVE cFilials, cCodBem WSSERVICE UWSA002

	Local aArea 	:= FWGetArea()
	Local aAreaST9 	:= ST9->(FWGetArea())
	Local oResponse	:= JsonObject():New()
	Local cJson		:= ""
	Local cFilials	:= ""
	Local cCodBem	:= ""
	Local cMsgLog 	:= ""

	Self:SetContentType("application/json; charset=utf-8")
	cJson 		:= AllTrim(Self:GetContent())
	cFilials	:= Padr(AllTrim(Self:cFilials),TamSx3("T9_FILIAL")[1])
	cCodBem		:= Padr(AllTrim(Self:cCodBem),TamSx3("T9_CODBEM")[1])

	ST9->(DbSelectArea("ST9"))
	ST9->(DbSetOrder(1))
	ST9->(DbGotop())

	if ST9->(DbSeek( cFilials +  cCodBem ))
		if U_UMNTA002(cJson,5,@cMsgLog)
			oResponse["status"] := 201
			oResponse["msg"] 	:= "Cadastro excluso com sucesso!"
		else
			oResponse["status"] := 500
			oResponse["msg"] 	:= "Erro ao realizar a exclusão : " + cMsgLog
		endif
	else
		oResponse["status"] := 500
		oResponse["msg"] 	:= "Erro ao realizar exclusão, registro não localizado!"
	endif

	Self:SetResponse(oResponse:toJson())

	FWRestArea(aAreaST9)
	FwRestArea(aArea)

Return(.T.)

/*/-------------------------------------------------------------------
	- Programa: postServico
	- Autor: Tarcisio Silva Miranda
	- Data: 06/01/2023
	- Descrição: API para inclusão de serviços.
	http://localhost:8400/rest/UWSA002/incluiservico
	{
	"T4_SERVICO" : "000001",
	"T4_NOME"    : "TESTE 1",
	"T4_CODAREA" : "000000",
	"T4_TIPOMAN" : "001"
	}
-------------------------------------------------------------------/*/

WSMETHOD POST postServico WSSERVICE UWSA002

	Local aArea 		:= FWGetArea()
	Local aAreaST4 		:= ST4->(FWGetArea())
	Local cJson			:= ""
	Local cMsgLog 		:= ""
	Local oResponse		:= JsonObject():New()

	Self:SetContentType("application/json; charset=utf-8")
	cJson := AllTrim(Self:GetContent())

	if U_UMNTA004(cJson,3,@cMsgLog)
		oResponse["status"] := 201
		oResponse["msg"] 	:= "Cadastro realizado com sucesso!"
	else
		oResponse["status"] := 500
		oResponse["msg"] 	:= "Erro ao realizar cadastro! " + cMsgLog
	endif

	Self:SetResponse(oResponse:toJson())

	FWRestArea(aAreaST4)
	FwRestArea(aArea)

Return(.T.)

/*/-------------------------------------------------------------------
	- Programa: putServico
	- Autor: Tarcisio Silva Miranda
	- Data: 06/01/2023
	- Descrição: API para alteração de serviços.
	http://localhost:8400/rest/UWSA002/alteraservico?cFilials=01&cCodServ=000001
	{
	"T4_NOME"   : "TESTE2"
	}
-------------------------------------------------------------------/*/

WSMETHOD PUT putServico WSRECEIVE cFilials, cCodServ WSSERVICE UWSA002

	Local aArea 	:= FWGetArea()
	Local aAreaST4 	:= ST4->(FWGetArea())
	Local oResponse	:= JsonObject():New()
	Local cJson		:= ""
	Local cFilials	:= ""
	Local cCodServ	:= ""
	Local cMsgLog 	:= ""

	Self:SetContentType("application/json; charset=utf-8")
	cJson 		:= AllTrim(Self:GetContent())
	cFilials	:= Padr(AllTrim(Self:cFilials),TamSx3("T4_FILIAL")[1])
	cCodServ	:= Padr(AllTrim(Self:cCodServ),TamSx3("T4_SERVICO")[1])

	ST4->(DbSelectArea("ST4"))
	ST4->(DbSetOrder(1))
	ST4->(DbGotop())

	if ST4->(DbSeek( cFilials +  cCodServ ))
		if U_UMNTA004(cJson,4,@cMsgLog)
			oResponse["status"] := 201
			oResponse["msg"] 	:= "Cadastro alterado com sucesso!"
		else
			oResponse["status"] := 500
			oResponse["msg"] 	:= "Erro ao realizar Alteração : " + cMsgLog
		endif
	else
		oResponse["status"] := 500
		oResponse["msg"] 	:= "Erro ao realizar alteração, registro não localizado!"
	endif

	Self:SetResponse(oResponse:toJson())

	FWRestArea(aAreaST4)
	FwRestArea(aArea)

Return(.T.)

/*/-------------------------------------------------------------------
	- Programa: excServico
	- Autor: Tarcisio Silva Miranda
	- Data: 06/01/2023
	- Descrição: API para exclusão de serviços.
	http://localhost:8400/rest/UWSA002/delServico?cFilials=01&cCodServ=000001
-------------------------------------------------------------------/*/

WSMETHOD DELETE excServico WSRECEIVE cFilials, cCodServ WSSERVICE UWSA002

	Local aArea 	:= FWGetArea()
	Local aAreaST4 	:= ST4->(FWGetArea())
	Local oResponse	:= JsonObject():New()
	Local cJson		:= ""
	Local cFilials	:= ""
	Local cCodServ	:= ""
	Local cMsgLog 	:= ""

	Self:SetContentType("application/json; charset=utf-8")
	cJson 		:= AllTrim(Self:GetContent())
	cFilials	:= Padr(AllTrim(Self:cFilials),TamSx3("T4_FILIAL")[1])
	cCodServ	:= Padr(AllTrim(Self:cCodServ),TamSx3("T4_SERVICO")[1])

	ST4->(DbSelectArea("ST4"))
	ST4->(DbSetOrder(1))
	ST4->(DbGotop())

	if ST4->(DbSeek( cFilials +  cCodServ ))
		if U_UMNTA004(cJson,5,@cMsgLog)
			oResponse["status"] := 201
			oResponse["msg"] 	:= "Cadastro excluso com sucesso!"
		else
			oResponse["status"] := 500
			oResponse["msg"] 	:= "Erro ao realizar a exclusão : " + cMsgLog
		endif
	else
		oResponse["status"] := 500
		oResponse["msg"] 	:= "Erro ao realizar exclusão, registro não localizado!"
	endif

	Self:SetResponse(oResponse:toJson())

	FWRestArea(aAreaST4)
	FwRestArea(aArea)

Return(.T.)


/*/-------------------------------------------------------------------
	- Programa: postPV
	- Autor: Tarcisio Silva Miranda
	- Data: 18/01/2023
	- Descrição: API para inclusão do pedido de vendas.
	http://localhost:8400/rest/UWSA002/incluipv
	{
	"PEDIDO": {
	"C5_CLIENTE": "000001",
	"C5_LOJACLI": "01",
	"C5_CONDPAG": "002",
	"C5_NATUREZ": "010101001"
	},
	"ITENS": [
	{
	"C6_PRODUTO": "000001",
	"C6_QTDVEN"	: 1,
	"C6_PRCVEN"	: 170.82,
	"C6_VALOR"	: 170.82,
	"C6_TES"	: "501"
	},
	{
	"C6_PRODUTO": "000002",
	"C6_QTDVEN"	: 2,
	"C6_PRCVEN"	: 4414.52,
	"C6_VALOR"	: 8829.04,
	"C6_TES"	: "501"
	}
	]
	}
-------------------------------------------------------------------/*/

WSMETHOD POST postPV WSSERVICE UWSA002

	Local aArea 		:= FWGetArea()
	Local aAreaSC5 		:= SC5->(FWGetArea())
	Local aAreaSC6 		:= SC6->(FWGetArea())
	Local cJson			:= ""
	Local cMsgLog 		:= ""
	Local oResponse		:= JsonObject():New()

	Self:SetContentType("application/json; charset=utf-8")
	cJson := AllTrim(Self:GetContent())

	if U_UMNTA005(cJson,3,@cMsgLog)
		oResponse["status"] := 201
		oResponse["msg"] 	:= "Movimentação realizado com sucesso, pedido : " + cMsgLog
	else
		oResponse["status"] := 500
		oResponse["msg"] 	:= "Erro ao realizar Movimentação! " + cMsgLog
	endif

	Self:SetResponse(oResponse:toJson())

	FWRestArea(aAreaSC5)
	FWRestArea(aAreaSC6)
	FwRestArea(aArea)

Return(.T.)

/*/-------------------------------------------------------------------
	- Programa: putPV
	- Autor: Tarcisio Silva Miranda
	- Data: 18/01/2023
	- Descrição: API para alteração do pedido de vendas.
	http://localhost:8400/rest/UWSA002/alterapv?cFilials=01&cNumPv=000008
	{
	"PEDIDO": {
	"C5_CLIENTE": "000001",
	"C5_LOJACLI": "01",
	"C5_CONDPAG": "002",
	"C5_NATUREZ": "010101001"
	},
	"ITENS": [
	{
	"C6_PRODUTO": "000001",
	"C6_QTDVEN"	: 1,
	"C6_PRCVEN"	: 170.82,
	"C6_VALOR"	: 170.82,
	"C6_TES"	: "501"
	},
	{
	"C6_PRODUTO": "000002",
	"C6_QTDVEN"	: 1,
	"C6_PRCVEN"	: 4414.52,
	"C6_VALOR"	: 4414.52,
	"C6_TES"	: "501"
	}
	]
	}
-------------------------------------------------------------------/*/

WSMETHOD PUT putPV WSRECEIVE cFilials, cNumPv WSSERVICE UWSA002

	Local aArea 	:= FWGetArea()
	Local aAreaSC5 	:= SC5->(FWGetArea())
	Local aAreaSC6 	:= SC6->(FWGetArea())
	Local oResponse	:= JsonObject():New()
	Local cJson		:= ""
	Local cFilials	:= ""
	Local cNumPv	:= ""
	Local cMsgLog 	:= ""

	Self:SetContentType("application/json; charset=utf-8")
	cJson 		:= AllTrim(Self:GetContent())
	cFilials	:= Padr(AllTrim(Self:cFilials),TamSx3("C5_FILIAL")[1])
	cNumPv		:= Padr(AllTrim(Self:cNumPv),TamSx3("C5_NUM")[1])

	SC5->(DbSelectArea("SC5"))
	SC5->(DbSetOrder(1))
	SC5->(DbGotop())

	if SC5->(DbSeek( cFilials +  cNumPv ))
		if U_UMNTA005(cJson,4,@cMsgLog)
			oResponse["status"] := 201
			oResponse["msg"] 	:= "Alteração realizada com sucesso, pedido : " + cMsgLog
		else
			oResponse["status"] := 500
			oResponse["msg"] 	:= "Erro ao realizar Alteração : " + cMsgLog
		endif
	else
		oResponse["status"] := 500
		oResponse["msg"] 	:= "Erro ao realizar alteração, registro não localizado!"
	endif

	Self:SetResponse(oResponse:toJson())

	FWRestArea(aAreaSC5)
	FWRestArea(aAreaSC6)
	FwRestArea(aArea)

Return(.T.)


/*/-------------------------------------------------------------------
	- Programa: deelPV
	- Autor: Tarcisio Silva Miranda
	- Data: 18/01/2023
	- Descrição: API para exclusão do pedido de vendas.
	http://localhost:8400/rest/UWSA002/delpv?cFilials=01&cNumPv=000001
-------------------------------------------------------------------/*/

WSMETHOD DELETE deelPV WSRECEIVE cFilials, cNumPv WSSERVICE UWSA002

	Local aArea 	:= FWGetArea()
	Local aAreaSC5 	:= SC5->(FWGetArea())
	Local aAreaSC6 	:= SC6->(FWGetArea())
	Local oResponse	:= JsonObject():New()
	Local cJson		:= ""
	Local cFilials	:= ""
	Local cNumPv	:= ""
	Local cMsgLog 	:= ""

	Self:SetContentType("application/json; charset=utf-8")
	cJson 		:= AllTrim(Self:GetContent())
	cFilials	:= Padr(AllTrim(Self:cFilials),TamSx3("C5_FILIAL")[1])
	cNumPv		:= Padr(AllTrim(Self:cNumPv),TamSx3("C5_NUM")[1])

	SC5->(DbSelectArea("SC5"))
	SC5->(DbSetOrder(1))
	SC5->(DbGotop())

	if SC5->(DbSeek( cFilials +  cNumPv ))
		if U_UMNTA005(cJson,5,@cMsgLog)
			oResponse["status"] := 201
			oResponse["msg"] 	:= "Cadastro excluso com sucesso!"
		else
			oResponse["status"] := 500
			oResponse["msg"] 	:= "Erro ao realizar a exclusão : " + cMsgLog
		endif
	else
		oResponse["status"] := 500
		oResponse["msg"] 	:= "Erro ao realizar exclusão, registro não localizado!"
	endif

	Self:SetResponse(oResponse:toJson())

	FWRestArea(aAreaSC5)
	FWRestArea(aAreaSC6)
	FwRestArea(aArea)

Return(.T.)
