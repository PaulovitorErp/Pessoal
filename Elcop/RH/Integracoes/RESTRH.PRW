#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE 'RESTFUL.CH'
#INCLUDE "topconn.ch"
#INCLUDE "TBICONN.CH"

// INICIO A CRIAÇÃO DO REST

WSRESTFUL RESTRH DESCRIPTION "SERVICO REST PARA INCLUSAO DE ADMISSÃO DE FUNCIONARIOS E CONSULTAS DE CAMPOS"


// metodo para retornar as consultas, pode ser usado para deletar

WSDATA CodFunc                                                             as STRING

WSDATA CodIbge                                                             as STRING

WSDATA CodMun                                                              as STRING

WSDATA RegrApont                                                           as STRING

WSDATA CodSind                                                             as STRING

WSDATA aLog                                                                as STRING





WSMETHOD GET FindFunc;
DESCRIPTION "CONSULTA CODIGO DA FUNCAO";
WSSYNTAX "/FindFunc";
PATH "FindFunc" PRODUCES APPLICATION_JSON


WSMETHOD GET FindIbge;
DESCRIPTION "CONSULTA CODIGO IBGE";
WSSYNTAX "/FindIbge";
PATH "FindIbge" PRODUCES APPLICATION_JSON

WSMETHOD GET LocaMuni;
DESCRIPTION "CONSULTA CODIGO DO MUNICIPIO";
WSSYNTAX "/LocaMuni";
PATH "LocaMuni" PRODUCES APPLICATION_JSON

WSMETHOD GET FindApont;
DESCRIPTION "CONSULTA REGRA DE APONTAMENTO";
WSSYNTAX "/FindApont";
PATH "FindApont" PRODUCES APPLICATION_JSON

WSMETHOD GET FindSindica;
DESCRIPTION "CONSULTA SINDICATOS";
WSSYNTAX "/FindSindica";
PATH "FindSindica" PRODUCES APPLICATION_JSON

WSMETHOD POST AddEmployee;
DESCRIPTION "INCLUI FUNCIONARIO";
WSSYNTAX "/AddEmployee";
PATH "AddEmployee" PRODUCES APPLICATION_JSON

WSMETHOD POST AddDepend;
DESCRIPTION "INCLUI DEPEND";
WSSYNTAX "/AddDepend";
PATH "AddDepend" PRODUCES APPLICATION_JSON



ENDWSRESTFUL

/*
+------------------+---------------------------------------------------------+
!Autor ! ANDRE CASTILHO !
+------------------+---------------------------------------------------------+
!Data de Criacao ! 21/06/2024 !
!Aplicação: Consulta cadastros de sindicato protheus
+------------------+---------------------------------------------------------+
*/

WSMETHOD GET FindSindica WSRECEIVE CodSind WSREST RESTRH

Local cCodSindica := Self:CodSind
Local aArea      := GetArea()
Local oJson      := JsonObject():New() // classe para transformar a variavel oJson, em uma estrutura Json
Local oReturn    := JsonObject():New()//Caso não encontre o sindicato, retorna uma mensagem informativa
Local cReturn     //Retorno de sucesso
Local aDados     :={} //Retorna array com as informações
Local cQuery     :=""
Local cPulaLinha     := chr(13)+chr(10)
Local oSindicato

Local nCont := 1


Conout("++++++++++++ API REST BUSCA DE SINDICATO ++++++++++++++++") 
If Select("cQuery") > 0
		cQuery->(DbCloseArea())
	EndIf

If !Empty(cCodSindica)
          
//If Select("RSQL") > 0
 // RSQL->(DBCLOSEAREA())
    
cQuery :=" SELECT RCE_CODIGO, RCE_DESCRI FROM "+RetSqlName("RCE")+"  " +cPulaLinha
cQuery +=" WHERE RCE_DESCRI LIKE '%"+UPPER(cCodSindica)+"%'" +cPulaLinha
cQuery += " AND D_E_L_E_T_ <>'*' "+cPulaLinha

TcQuery cQuery New Alias "QRY"

DbSelectArea("QRY")
If !EOF()
  Do While !EOF()
   oSindicato :=JsonObject():New()
    oSindicato['CodigoSindicato'] := ALLTRIM(QRY->RCE_CODIGO)
    oSindicato['NomeSindicato'] := AllTrim(QRY->RCE_DESCRI)
    AAdd(aDados, oSindicato)
  //  nCont++
   // Next
     DbSkip()
  EndDo  
 
/*aadd(aDados,JsonObject():New())
aDados[1]['Codigo Sindicato'] := AllTrim(RSQL->RCE_CODIGO)
aDados[1]['Nome Sindicato'] := AllTrim(RSQL->RCE_DESCRI)
*/
    oJson['Sindicato'] := aDados

Else
   oReturn['Mensagem'] :="Sindicato nao encontrado"
EndIF

    oReturn[ 'cRet' ]    := "200"
    cReturn := FwJsonSerialize(oReturn) //serializo o retorno
    cJson  := FwJsonSerialize(oJson)

    ::SetResponse(cJson)
//::SetResponse(cReturn)

    QRY->(DbCloseArea())

Else

    oReturn['Mensagem'] :="Codigo Sindicato Vazio, e obrigatorio informar um conteudo"
    oReturn[ 'cRet' ]    := "400"
     cReturn  := FwJsonSerialize(oReturn)
     ::SetResponse(cReturn)
EndIF

RestArea(aArea)
FreeObj(oJson)
FreeObj(oReturn)

Return()


/*
+------------------+---------------------------------------------------------+
!Autor ! ANDRE CASTILHO !
+------------------+---------------------------------------------------------+
!Data de Criacao ! 21/06/2024 !
!Aplicação: Consulta cadastros de sindicato protheus
+------------------+---------------------------------------------------------+
*/

WSMETHOD GET FindApont WSRECEIVE RegrApont WSREST RESTRH

Local cRegrApontamento := Self:RegrApont
Local aArea := GetArea()
Local oJson := JsonObject():New()
Local oReturn := JsonObject():New()
Local cReturn 
Local aDados := {}
Local cQry := ""
Local cPulaLinha := chr(13)+chr(10)
Local oTurno

Conout("++++++++++++ API REST BUSCA TURNO DE TRABALHO ++++++++++++++++") 
If Select("cQuery") > 0
		cQuery->(DbCloseArea())
	EndIf

if !Empty(cRegrApontamento)

cQry := "SELECT R6_TURNO, R6_DESC, R6_HRNORMA FROM " + RetSqlName("SR6")+" "+cPulaLinha
cQry += " WHERE D_E_L_E_T_ <>'*' AND R6_DESC LIKE '%"+UPPER(cRegrApontamento)+"%'" +cPulaLinha

TcQuery cQry New Alias "cQuery"

DbSelectArea("cQuery")
if !EOF()
    Do While !EOF()
    oTurno := JsonObject():New()
    oTurno['CodigoTurno'] := cQuery->R6_TURNO
    oTurno['Descricao'] := AllTrim(cQuery->R6_DESC)
    oTurno['JornadaMensal'] := cQuery->(R6_HRNORMA)
    AAdd(aDados,oTurno)
    DbSkip()
EndDo
    oJson['Turnos'] := aDados
Else

    oReturn['Mensagem'] := "Turno nao encontrado"
    oReturn['cRet'] :="404"
    cReturn := FwJsonSerialize(oReturn)
    ::SetResponse(cReturn)
    Return()
EndIF

    oReturn['cRet'] := "200"
    cReturn := FwJsonSerialize(oReturn)
    cJson := FwJsonSerialize(oJson)
    ::SetResponse(cJson)

    cQuery->(DbCloseArea())

Else

    oReturn['Mensagem'] := "Codigo de Turno Vazio"
    oReturn['cRet'] := "400"
    cReturn := FWJsonDeserialize(oReturn)
    ::SetResponse(cReturn)
Endif

RestArea(aArea)
FreeObj(oJson)
FreeObj(oReturn)

Return()


/*
+------------------+---------------------------------------------------------+
!Autor ! ANDRE CASTILHO !
+------------------+---------------------------------------------------------+
!Data de Criacao ! 21/06/2024 !
!Aplicação: Consulta cadastros de Municipios protheus
+------------------+---------------------------------------------------------+
*/

WSMETHOD GET FindIbge WSRECEIVE CodIbge WSREST RESTRH

Local cIbge     :=Self:CodIbge
Local aArea     := GetArea()
Local oReturn   := JsonObject():New()
Local oJson     := JsonObject():New()
Local cReturn   
Local aDados    :={}
Local cQry      :=""
Local cPulaLinha := chr(13)+chr(10)
Local oIbge  

If Select("cQuery") > 0
		cQuery->(DbCloseArea())
	EndIf

If !Empty(cIbge)



    cQry := " SELECT X5_TABELA, X5_CHAVE, X5_DESCRI, CC2_CODMUN, CC2_MUN FROM " + RetSqlName("SX5")+" AS X5 "+cPulaLinha
    cQry += " INNER JOIN CC2010 AS CC2 ON CC2.CC2_EST = X5.X5_CHAVE " +cPulaLinha
    cQry += " WHERE CC2.CC2_MUN LIKE '%" + UPPER(cIbge) + "%'" +cPulaLinha
    cQry += " AND X5.X5_TABELA ='12' AND CC2.D_E_L_E_T_ =' ' AND X5.D_E_L_E_T_ =' '  "+cPulaLinha

    TcQuery cQry New Alias "cQuery"

    DbSelectArea("cQuery")
If !EOF()
    Do While !EOF()
    oIbge := JsonObject():New()
    oIbge["UF"] :=ALLTRIM(cQuery->X5_CHAVE)
    oIbge["DescEstado"]    :=AllTrim(EncodeUTF8(cQuery->X5_DESCRI))
    oIbge["CodigoMunicipio"] :=Alltrim(cQuery->CC2_CODMUN)
    oIbge["NomeMunicipio"] :=Alltrim(EncodeUTF8(cQuery->CC2_MUN))
    AAdd(aDados,oIbge)
    DbSkip()
EndDo
    oJson['Estados'] :=aDados
Else 
    oReturn['Mensagem'] := "Estado nao encontrado"
    oReturn['cRet'] :="404"
    cReturn := FwJsonSerialize(oReturn)
    ::SetResponse(cReturn)
    Return()
EndIF

    oReturn['cRet'] := "200"
    cReturn := FwJsonSerialize(oReturn)
    cJson := FwJsonSerialize(oJson)
    ::SetResponse(cJson)

    cQuery->(DbCloseArea())

Else

    oReturn['Mensagem'] := "Codigo Vazio"
    oReturn['cRet'] := "400"
    cReturn := FWJsonDeserialize(oReturn)
    ::SetResponse(cReturn)
Endif

RestArea(aArea)
FreeObj(oJson)
FreeObj(oReturn)

Return()


   
/*
+------------------+---------------------------------------------------------+
!Autor ! ANDRE CASTILHO !
+------------------+---------------------------------------------------------+
!Data de Criacao ! 21/06/2024 !
!Aplicação: Inclusao de admissao protheus
+------------------+---------------------------------------------------------+
*/



WSMETHOD POST AddEmployee WSRECEIVE aLog WSREST RESTRH

Local aCabec := {}
Local oReturn := JsonObject():New()
Local oEmployee := JsonObject():New()
Local cJsonRetorno := JsonObject():New()
Local cResponse := ""
Local cError :=""
Local cLog := ""
Local cContent := Self:GetContent()
Local cError := "\logs_admissao\"
Local cMsg  := ""
Local nMat 
Local aLog := {}
Local nCount := 0
Local lRet := .T.
Private lMSHelpAuto := .T. // para nao mostrar os erro na tela
Private lMSErroAuto := .F. 
Private lAutoErrNoFile := .T.





//MemoWrite(cArquivo, cContent)

Conout("++++++++++++ API REST DE ADMISSAO DE FUNCIONARIO VIA FLUIG ++++++++++++++++") 

  nMat := U_PROXSRA("SRA","RA_MAT") 

// Convertendo o conteúdo da requisição para um objeto JSON
oEmployee:FromJson(cContent)


// Configuração do ambiente
RpcSetEnv("01","0101",,, "GPE")  // Empresa "99", Filial "01"


// Preenchendo o array aCabec com os dados do funcionário recebido via JSON

aCabec   := {}
AAdd(aCabec, {"RA_FILIAL", xFilial("SRA"), Nil})
//AAdd(aCabec, {"RA_MAT", GetSXENum('SRA','RA_MAT'), Nil})
AAdd(aCabec, {"RA_MAT", nMat, Nil})
AAdd(aCabec, {'RA_NOME', oEmployee:RA_NOME, Nil})
AAdd(aCabec, {'RA_SEXO', oEmployee:RA_SEXO, Nil})
AAdd(aCabec, {'RA_RACACOR', oEmployee:RA_RACACOR, Nil})
AAdd(aCabec, {'RA_NASC', Stod(oEmployee:RA_NASC), Nil})
AAdd(aCabec, {'RA_ESTCIVI', oEmployee:RA_ESTCIVI, Nil})
AAdd(aCabec, {'RA_CPAISOR', oEmployee:RA_CPAISOR, Nil})
AAdd(aCabec, {'RA_NACIONA', oEmployee:RA_NACIONA, Nil})
AAdd(aCabec, {'RA_NACIONC', oEmployee:RA_NACIONC, Nil})
AAdd(aCabec, {'RA_NATURAL', oEmployee:RA_NATURAL, Nil})
AAdd(aCabec, {'RA_NCODMUNN', oEmployee:RA_NCODMUNN, Nil})
AAdd(aCabec, {'RA_GRINRAI', oEmployee:RA_GRINRAI, Nil})
AAdd(aCabec, {'RA_CC', oEmployee:RA_CC, Nil})
AAdd(aCabec, {'RA_ADMISSA', Stod(oEmployee:RA_ADMISSA), Nil})
AAdd(aCabec, {'RA_TIPOADM', oEmployee:RA_TIPOADM, Nil})
AAdd(aCabec, {'RA_OPCAO', Stod(oEmployee:RA_OPCAO), Nil})
//AAdd(aCabec, {'RA_BCDPFGT', oEmployee:RA_BCDPFGT, Nil})
//AAdd(aCabec, {'RA_CTDPFGT', oEmployee:RA_CTDPFGT, Nil})
AAdd(aCabec, {'RA_HRSMES', oEmployee:RA_HRSMES, Nil})  //@E 999.9999                                  
AAdd(aCabec, {'RA_HRSDIA', oEmployee:RA_HRSDIA, Nil})
AAdd(aCabec, {'RA_PROCES', oEmployee:RA_PROCES, Nil})
AAdd(aCabec, {'RA_CATFUNC', oEmployee:RA_CATFUNC, Nil})
AAdd(aCabec, {'RA_HRSEMAN', oEmployee:RA_HRSEMAN, Nil})
AAdd(aCabec, {'RA_CODFUNC', oEmployee:RA_CODFUNC, Nil})
AAdd(aCabec, {'RA_HOPARC', oEmployee:RA_HOPARC, Nil})
AAdd(aCabec, {'RA_SINDICA', oEmployee:RA_SINDICA, Nil})
AAdd(aCabec, {'RA_TIPOPGT', oEmployee:RA_TIPOPGT, Nil})
AAdd(aCabec, {'RA_VIEMRAI', oEmployee:RA_VIEMRAI, Nil})
AAdd(aCabec, {'RA_CATEFD', oEmployee:RA_CATEFD, Nil})
AAdd(aCabec, {'RA_COMPSAB', oEmployee:RA_COMPSAB, Nil})
AAdd(aCabec, {'RA_CIC', oEmployee:RA_CIC, Nil})
AAdd(aCabec, {'RA_TNOTRAB', oEmployee:RA_TNOTRAB, Nil})
AAdd(aCabec, {'RA_REGRA', oEmployee:RA_REGRA, Nil})
AAdd(aCabec, {'RA_SEQTURN', oEmployee:RA_SEQTURN, Nil})
AAdd(aCabec, {'RA_TIPENDE', oEmployee:RA_TIPENDE, Nil})
AAdd(aCabec, {'RA_LOGRTP', oEmployee:RA_LOGRTP, Nil})
AAdd(aCabec, {'RA_LOGRDSC', oEmployee:RA_LOGRDSC, Nil})
AAdd(aCabec, {'RA_LOGRNUM', oEmployee:RA_LOGRNUM, Nil})
AAdd(aCabec, {'RA_NUMENDE', oEmployee:RA_NUMENDE, Nil})
AAdd(aCabec, {'RA_BAIRRO', oEmployee:RA_BAIRRO, Nil})
AAdd(aCabec, {'RA_ESTADO', oEmployee:RA_ESTADO, Nil})
AAdd(aCabec, {'RA_CODMUN', oEmployee:RA_CODMUN, Nil})
AAdd(aCabec, {'RA_CEP', oEmployee:RA_CEP, Nil})
AAdd(aCabec, {'RA_ADTPOSE', oEmployee:RA_ADTPOSE, Nil})
AAdd(aCabec, {'RA_XSUBST', oEmployee:RA_XSUBST, Nil})
AAdd(aCabec, {'RA_VLALIME', oEmployee:RA_VLALIME, Nil})
AAdd(aCabec, {'RA_COMBUST', oEmployee:RA_COMBUST, Nil})
AAdd(aCabec, {'RA_VTRANSP', oEmployee:RA_VTRANSP, Nil})
AAdd(aCabec, {'RA_RG', oEmployee:RA_RG, Nil})
AAdd(aCabec, {'RA_DTRGEXP', Stod(oEmployee:RA_DTRGEXP), Nil})
AAdd(aCabec, {'RA_RGEXP', oEmployee:RA_RGEXP, Nil})
AAdd(aCabec, {'RA_RGUF', oEmployee:RA_RGUF, Nil})
AAdd(aCabec, {'RA_MAE', oEmployee:RA_MAE, Nil})
AAdd(aCabec, {'RA_PAI', oEmployee:RA_PAI, Nil})
AAdd(aCabec, {'RA_PIS', oEmployee:RA_PIS, Nil})
AAdd(aCabec, {'RA_EMAIL', oEmployee:RA_EMAIL, Nil})
AAdd(aCabec, {'RA_COMPLEM', oEmployee:RA_COMPLEM, Nil})
AAdd(aCabec, {'RA_BCDEPSA', oEmployee:RA_BCDEPSA, Nil})
AAdd(aCabec, {'RA_CTDEPSA', oEmployee:RA_CTDEPSA, Nil})
AAdd(aCabec, {'RA_SALARIO', Val(StrTran(oEmployee:RA_SALARIO,",",".")), Nil})
AAdd(aCabec, {'RA_ADCPERI', oEmployee:RA_ADCPERI, Nil})
AAdd(aCabec, {'RA_ADCINS', oEmployee:RA_ADCINS, Nil})
AAdd(aCabec, {'RA_XADICIO', oEmployee:RA_XADICIO, Nil})
AAdd(aCabec, {'RA_NUMCP', oEmployee:RA_NUMCP, Nil})
AAdd(aCabec, {'RA_SERCP', oEmployee:RA_SERCP, Nil})
AAdd(aCabec, {'RA_UFCP', oEmployee:RA_UFCP, Nil})
AAdd(aCabec, {'RA_DTCPEXP', Stod(oEmployee:RA_DTCPEXP), Nil})
AAdd(aCabec, {'RA_CNHORG', oEmployee:RA_CNHORG, Nil})
AAdd(aCabec, {'RA_HABILIT', oEmployee:RA_HABILIT, Nil})
AAdd(aCabec, {'RA_UFCNH', oEmployee:RA_UFCNH, Nil})
AAdd(aCabec, {'RA_CATCNH', oEmployee:RA_CATCNH, Nil})
AAdd(aCabec, {'RA_TITULOE', oEmployee:RA_TITULOE, Nil})
AAdd(aCabec, {'RA_ZONASEC', oEmployee:RA_ZONASEC, Nil})
AAdd(aCabec, {'RA_SECAO', oEmployee:RA_SECAO, Nil})
AAdd(aCabec, {'RA_TIPCERT', oEmployee:RA_TIPCERT, Nil})
AAdd(aCabec, {'RA_EMICERT', Stod(oEmployee:RA_EMICERT), Nil})
AAdd(aCabec, {'RA_MATCERT', oEmployee:RA_MATCERT, Nil})
AAdd(aCabec, {'RA_LIVCERT', oEmployee:RA_LIVCERT, Nil})
AAdd(aCabec, {'RA_FOLCERT', oEmployee:RA_FOLCERT, Nil})
AAdd(aCabec, {'RA_CARCERT', oEmployee:RA_CARCERT, Nil})
AAdd(aCabec, {'RA_UFCERT', oEmployee:RA_UFCERT, Nil})
AAdd(aCabec, {'RA_CDMUCER', oEmployee:RA_CDMUCER, Nil})
AAdd(aCabec, {'RA_TIPOS', oEmployee:RA_TIPOS, Nil})
//AAdd(aCabec, {'RA_CODMUNN', oEmployee:RA_CODMUNN, Nil}) 
//AAdd(aCabec, {'RA_DDDCELU', oEmployee:RA_CODMUNN, Nil})
//AAdd(aCabec, {'RA_NUMCELU', oEmployee:RA_CODMUNN, Nil})//RA_CODMUNN RA_DDDCELU RA_NUMCELU




// Chamando a função de inclusão
MSExecAuto({|x,y,k,w| GPEA010(x,y,k,w)}, NIL, NIL, aCabec, 3)

If lMsErroAuto  // inicializa como .F., volta .T. se houver erro

    aLog := GetAutoGRlog()
    For nCount := 1 To Len(aLog)
        cMsg += aLog[nCount] + CRLF
    Next nCount

      oReturn['status'] := cMsg
     MostraErro(cError,"LogAdmissao.txt")
Else
      oReturn['status'] :="sucess"
      oReturn['Matricula'] := nMat
    ConOut("Funcionario incluido com sucesso matricula:"+nMat)

EndIf 
   
        Self:SetResponse(oReturn:toJson())

    Return()


User Function PROXSRA(_alias,_campo)

	LOCAL _CLOCAL	:= GETAREA()
	LOCAL _NPROX	:= ''
	LOCAL _CCAMPO	:= _campo
	LOCAL _CALIAS	:= _alias
	LOCAL _TAM		:= 6

cQry := "  SELECT MAX(CAST(RA_MAT AS CHAR)) PROX "
cQry += " FROM SRA010 "
cQry += " WHERE D_E_L_E_T_<> '*' "
        
	If Select("QAUX") > 0
		QAUX->(dbCloseArea())
	EndIf

	cQry := ChangeQuery(cQry)
	dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQry), "QAUX", .F., .T.)

	IF EMPTY(QAUX->PROX)
		_NPROX  := STRZERO(1,_TAM)
	ELSE
		_NPROX 	:= STRZERO(val(QAUX->PROX)+1,_TAM)
		_NAUX   := VAL(_NPROX)

		FreeUsedCode()
		While !MayIUseCode(_CALIAS+xFilial(_CALIAS)+STRZERO(_NAUX,_TAM))
			_NAUX+=1
		EndDo

		_NPROX:= STRZERO(_NAUX,_TAM)

	ENDIF

	QAUX->(DBCLOSEAREA())

Return(_NPROX)


/*
+------------------+---------------------------------------------------------+
!Autor ! ANDRE CASTILHO !
+------------------+---------------------------------------------------------+
!Data de Criacao ! 21/06/2024 !
!Aplicação: Inclusao de Dependentes Protheus
+------------------+---------------------------------------------------------+
*/



/*WSMETHOD POST AddDepend WSRECEIVE WSREST RESTRH

Local aCabec := {}
Local oReturn := JsonObject():New()
Local oDepende := JsonObject():New()
Local cJsonRetorno := JsonObject():New()
Local cResponse := ""
Local cError :=""
Local cLog := ""
Local cContent := Self:GetContent()
Local cError := "\logs_admissao\"
Local cMsg  := ""
Local nMat 
Local aLog := {}
Local nCount := 0
Local lRet := .T.
Local i := 0
Private lMSHelpAuto := .T. // para nao mostrar os erro na tela
Private lMSErroAuto := .F. 
Private lAutoErrNoFile := .T.


Conout("++++++++++++ API REST DE INCLUSAO DE DEPENDENTES VIA FLUIG ++++++++++++++++") 

// Convertendo o conteúdo da requisição para um objeto JSON
oJson:FromJson(Self:GetContent())
oDepende:FromJson(cContent)


// Configuração do ambiente
RpcSetEnv("01","0101",,, "GPE")  // Empresa "99", Filial "01"

aCabec   := {}
AAdd(aCabec, {"RA_FILIAL", xFilial("SRA"), Nil})
AAdd(aCabec, {"RA_MAT", nMat, Nil})


    For i:= 1 To Len(oItems)

aLinha := {}aItens := {}
AAdd(aLinha,{'RB_FILIAL',xFilial("SRA"), Nil})
AAdd(aLinha,{'RB_MAT',oDepende:RA_MAT, Nil})
AAdd(aLinha,{'RB_COD',oDepende:RB_COD, Nil})
AAdd(aLinha,{'RB_NOME',Stod(oDepende:RB_NOME), Nil})
AAdd(aLinha,{'RB_DTNASC',oDepende:RB_DTNASC, Nil})
AAdd(aLinha,{'RB_SEXO',oDepende:RB_SEXO, Nil})
aadd(aLinha,{"RB_GRAUPAR",oDepende:RB_GRAUPAR, Nil })
aadd(aLinha,{"RB_TIPIR"  ,oDepende:RB_TIPIR, Nil })
aadd(aLinha,{"RB_TIPSF"  ,oDepende:RB_TIPSF, Nil })
aadd(aLinha,{"RB_LOCNASC" ,oDepende:RB_LOCNASC, Nil })

aadd(aItens,aLinha)

    Next 

MSExecAuto({|x,y,k,w,z| GPEA020(x,y,k,w,z)},3,aCabec,aItens,3)

If lMsErroAuto
	MostraErro()
Else 	
	Alert("Registro(s) Incluído(s) !!!")  	
EndIf

Self:SetResponse(oReturn:toJson())
 return()

*/