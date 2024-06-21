#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AFAT003  ºAutor ³Sinval Gedolin       º Data ³     02/2021 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Importa planilha de Pedido de Vendas - ENERGISA            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Funcao Auxilia                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDATA      ³ ANALISTA ³  MOTIVO                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³          ³                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AFAT003()
	Local cPerg		:='AFAT01'
	Local cSep		:=';'

	//->Perguntas
	AjustaSX1(cPerg)
	if !pergunte(cPerg,.T.)
      Return
   endif
   
	cSep	:= MV_PAR03

	//->Validacoes                    
	If Empty(MV_PAR03)
		Alert("Separador Invalido!!!")
		Return(.F.)
	Endif         

    if MsgYesNo("Confirma Importação do Arquivo => "+Alltrim(MV_PAR01)+Alltrim(MV_PAR02)+ " ?")
        Processa( {|| AFATIMP(Alltrim(MV_PAR01)+Alltrim(MV_PAR02),MV_PAR03) }, "Aguarde...",;
                         "Importando Localizações ",.F.)

	    msginfo("Importação Finalizada..","Importação")
    endif

Return()           

/*
Importa Arquivo
*/
Static Function AFATIMP(cArquivo,cSep)
	Local aItens  := {}
	Local nCont   := 0	
    Local aPedidos:= {}

	Private nHdl  := 0
	Private cEOL  := "CHR(8)"

	If Empty(Alltrim(cArquivo))
		Alert("Nao existem arquivos para importar. Processo ABORTADO")
		Return.F.	
	EndIf

	//+---------------------------------------------------------------------+
	//| Abertura do arquivo texto                                           |
	//+---------------------------------------------------------------------+
	cArqTxt := cArquivo

	nHdl := fOpen(cArqTxt,0 )
	IF nHdl == -1
		IF FERROR()== 516
			ALERT("Feche o programa que gerou o arquivo.")
		EndIF
	EndIf

	//+---------------------------------------------------------------------+
	//| Verifica se foi possÌvel abrir o arquivo                            |
	//+---------------------------------------------------------------------+
	If nHdl == -1
		MsgAlert("O arquivo de nome "+cArquivo+" nao pode ser aberto! Verifique os parametros.","Atencao!" )
		Return
	Endif

	FSEEK(nHdl,0,0 )
	nTamArq:=FSEEK(nHdl,0,2 )
	FSEEK(nHdl,0,0 )
	fClose(nHdl)

	FT_FUse(cArquivo )  //abre o arquivo
	FT_FGoTop()         //posiciona na primeira linha do arquivo
	//nTamLinha := AT(cEOL,cBuffer )
	nTamLinha := Len(FT_FREADLN() ) //Ve o tamanho da linha
	FT_FGOTOP()

	//+---------------------------------------------------------------------+
	//| Verifica quantas linhas tem o arquivo                               |
	//+---------------------------------------------------------------------+
	nLinhas := FT_FLastRec() 

	ProcRegua(nLinhas)

	While !FT_FEOF()
		IF nCont > nLinhas
			exit
		Endif

		if nCont == 0
			FT_FSKIP()  
			nCont++
			loop
		endif

		IncProc("Lendo arquivo texto, Linha ==> "+Alltrim(str(nCont)))
		cLinha := Alltrim(FT_FReadLn())
		nRecno := FT_FRecno() // Retorna a linha corrente

		if !empty(Alltrim(cLinha))
			aItens:={}
			aItens:=strToKarr2(cLinha,cSep,.T.)
			AFATEXA(aItens,aPedidos)
		Endif
		FT_FSKIP()  
		nCont++
	EndDo

	FT_FUSE()
	fClose(nHdl )      

    if len(aPedidos) > 0
        //Gerando os Pedidos de Venda

        fFatPed(aPedidos)

    endif
Return                                        

Static Function AFATEXA(aItens,aPedidos)

   /*+--------------------------------------+
	|           Layout do Arquivo          |
	+---+----------------------------------+
	|POS|CAMPO                             |
	+---+----------------------------------+
	|1  |Posicao #             |
	|2  |CIDADE                              |
	|3  |COLABORADOR                        |
    |4  |PA TIPO                            | 
    |5  |QTDE PA    
    |6  |DIAS DESC
    |7  |VALOR DESCONTADO
    |8  |VALOR UNITÁRIO
    |9  |ESTADO
    |10 |COD MUNICIPIO
    |11 |NUMERO CONTRATO
    |12 |Medicao
    |13 | Autorização de Faturamento
	+---+----------------------------------+*/  
			
    //Agrupa os itens de Faturamento por Número Solicitação e Município
    nPos := aScan( aPedidos, {| aPosicao | aPosicao[1] == alltrim(aItens[1]) } ) 

    if nPos = 0
        aAdd(aPedidos,{alltrim(aItens[1])                       ,; //Chave de Busca Número da Cidade
                        aItens[01]                              ,; // Município Nome
                        aitens[09]                              ,; // Domiclio Fiscal (Estado)
                        aitens[10]                              ,; // Domiclio Fiscal (Código do Município)
                        val(strTran(aItens[08],",","."))        ,; // Valor Total
                        aItens[04]                              ,; // TIPO PA
                        aItens[05]                              ,; // Quantidade de PA
                        aItens[11]                              ,; // Número do Contrato
                        aItens[12]                              ,; // Mês/Ano Medição MEDICAL GERAL
                        aItens[13]                              }) // Autorização de Faturamento
    else
        aPedidos[nPos][5] += val(strTran(aItens[08],",","."))        
    endif
Return Nil

//Geração dos Pedidos de Vendas
static Function fFatPed(aPedidos)

Local cDoc       := ""              // Número do Pedido de Vendas
Local cA1Cod     := MV_PAR04        // Código do Cliente
Local cA1Loja    := MV_PAR05        // Loja do Cliente
Local cB1Cod     := ""              // Código do Produto
Local cF4TES     := ""              // Código do TES
Local cE4Codigo  := MV_PAR06 // Código da Condição de Pagamento
Local cMsgLog    := ""
Local cLogErro   := ""
Local cFilSA1    := ""
Local cFilSB1    := ""
Local cFilSE4    := ""
Local cFilSF4    := ""
Local nOpcX      := 0
Local nCount     := 0
Local aCabec     := {}
Local aItens     := {}
Local aLinha     := {}
Local aErroAuto  := {}
Local lOk        := .T.
Local cQuery     := ""
Local nItem      := 1
Local cEOL 		:= Chr(13)+Chr(10)

Private lMsErroAuto    := .F.
Private lAutoErrNoFile := .F.
 
//****************************************************************
//* Abertura do ambiente
//****************************************************************
SA1->(dbSetOrder(1))
SB1->(dbSetOrder(1))
SE4->(dbSetOrder(1))
SF4->(dbSetOrder(1))
 
cFilAGG := xFilial("AGG")
cFilSA1 := xFilial("SA1")
cFilSB1 := xFilial("SB1")
cFilSE4 := xFilial("SE4")
cFilSF4 := xFilial("SF4")
 
for nItem := 1 to len(aPedidos)   
   
    aCabec   := {}
    aItens   := {}
    aLinha   := {}
    lOk      := .T.

    cDoc := GetSxeNum("SC5", "C5_NUM")
    aadd(aCabec, {"C5_NUM"     , cDoc      , Nil})
    aadd(aCabec, {"C5_TIPO"    , "N"       , Nil})
    aadd(aCabec, {"C5_CLIENTE" , cA1Cod    , Nil})
    aadd(aCabec, {"C5_LOJACLI" , cA1Loja   , Nil})
    aadd(aCabec, {"C5_LOJAENT" , cA1Loja   , Nil})
    aadd(aCabec, {"C5_CONDPAG" , cE4Codigo , Nil})

    IncProc("Gerando Pedidos, Número ==> "+Alltrim(cDoc))

    //Buscando o Código do Produto, que conterá, TES, Município, Centro de Custo, CodISS, Aliqu ISS, CNAE
    cEstado  := alltrim(aPedidos[nItem][3])
    cMunic   := alltrim(aPedidos[nItem][4])

    cAliasTop := GetNextAlias()

    if select(cAliasTop) > 0
        (cAliasTop)->(DbcloseArea())
    endif

    cQuery := "SELECT SB1.B1_COD, SB1.B1_XEST, SB1.B1_XCODMUN "
    cQuery += "FROM "+RetSqlName("SB1")+" SB1 "
    cQuery += "WHERE SB1.D_E_L_E_T_=' ' AND SB1.B1_XEST ='"+cEstado+"' AND SB1.B1_XCODMUN = '"+cMunic+"' "
    cQuery := ChangeQuery(cQuery)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)

    (cAliasTop)->(dbGoTop())
    do while (cAliasTop)->(!Eof())
         
        cB1Cod := (cAliasTop)->B1_COD
         
        (cAliasTop)->(dbSkip())
    enddo

    (cAliasTop)->(DbcloseArea())

    if empty(alltrim(cB1Cod))
        Help( ,, "Produto","Município",;
                "Não foi Localizado Município no Cadastro do Produto => "+cMunic, 1, 0)     
    else

        cb1CodISS   := strZero(val(alltrim(Posicione("SB1",1,xFilial("SB1")+cB1Cod,"B1_CODISS"))),4)
        nAliqIss    := Posicione("SB1",1,xFilial("SB1")+cB1Cod,"B1_ALIQISS")
        cF4TES      := Posicione("SB1",1,xFilial("SB1")+cB1Cod,"B1_TS")
        cB1CC       := Posicione("SB1",1,xFilial("SB1")+cB1Cod,"B1_CC")

        cXMennfs    := "MEDICAO GERAL "+alltrim(aPedidos[nItem][09])+" Valor Total R$ "+alltrim(transform(aPedidos[nItem][5],"@e 99,999,999.99"))+cEOL
        cXMennfs    += "                 "+cEOL
        cXMennfs    += "SERVICO: "+alltrim(aPedidos[nItem][06])+cEOL
        cXMennfs    += "                 "+cEOL
        /*if cEstado == "MT"
        cXMennfs    += "Qtde Pas: "+alltrim(aPedidos[nItem][07])+ " - Valor Unit. R$ "+alltrim(transform(aPedidos[nItem][5],"@e 99,999,999.99"))+cEOL
        cXMennfs    += "                 "+cEOL
        Endif*/
        cXMennfs    += "N. CONTRATO: "+alltrim(aPedidos[nItem][08])+cEOL
        cXMennfs    += "                 "+cEOL
        cXMennfs    += "INSS (3,5%): "+alltrim(transform(aPedidos[nItem][5]*0.035,"@e 999,999.99"))+cEOL
        cXMennfs    += "                 "+cEOL
        cXMennfs    += "NUMERO FATURAMENTO: "+alltrim(aPedidos[nItem][10])+cEOL
        cXMennfs    += "                 "+cEOL
        if cEstado == "MS"
        cXMennfs    += "LIQUIDO A PAGAR: "+ alltrim(transform(  ABS((aPedidos[nItem][5]*0.1465)-aPedidos[nItem][5])  ,"@e 99,999,999.99"))+cEOL
        Endif
        

        Aadd(aCabec, {"C5_ESTPRES" , cEstado   , Nil}) 
        Aadd(aCabec, {"C5_MUNPRES" , cMunic    , Nil})
        Aadd(aCabec, {"C5_XMENNFS" , cXMennfs  , Nil})

        If SF4->(! MsSeek(cFilSF4 + cF4TES))
            cMsgLog += "Cadastrar o TES: " + cF4TES + cEOL
            lOk     := .F.
        EndIf

        If SE4->(! MsSeek(cFilSE4 + cE4Codigo))
            cMsgLog += "Cadastrar a Condição de Pagamento: " + cE4Codigo + cEOL
            lOk     := .F.
        EndIf

        If SA1->(! MsSeek(cFilSA1 + cA1Cod+cA1Loja))
            cMsgLog += "Cadastrar o Cliente: " + cA1Cod+cA1Loja + cEOL
            lOk     := .F.
        EndIf

        if lOk
            //--- Informando os dados do item do Pedido de Venda
            aLinha := {}
            aadd(aLinha,{"C6_ITEM"     , "01"               , Nil})
            aadd(aLinha,{"C6_PRODUTO"  , cB1Cod             , Nil})
            aadd(aLinha,{"C6_QTDVEN"   , 1                  , Nil})
            aadd(aLinha,{"C6_QTDLIB"   , 1                  , Nil})
            aadd(aLinha,{"C6_PRCVEN"   , aPedidos[nItem][5] , Nil})
            aadd(aLinha,{"C6_PRUNIT"   , aPedidos[nItem][5] , Nil})
            aadd(aLinha,{"C6_VALOR"    , aPedidos[nItem][5] , Nil})
            aadd(aLinha,{"C6_TES"      , cF4TES             , Nil})
            aadd(aLinha,{"C6_CC"       , cB1CC              , Nil})
            aadd(aLinha,{"C6_PEDCLI"   , aPedidos[nItem][8] , Nil})
            aadd(aItens, aLinha)
         
            nOpcX := 3
        
            MSExecAuto({|x, y, z| MATA410(x, y, z)}, aCabec, aItens, nOpcX)
            if lMsErroAuto
                aErroAuto := GetAutoGRLog()
                For nCount := 1 To Len(aErroAuto)
                    cLogErro += StrTran(StrTran(aErroAuto[nCount], "<", ""), "-", "") + " "
                    ConOut(cLogErro)
                Next nCount
                RollbackSX8()
            else
                ConfirmSX8()
            endIf
        else
            Help( ,, "Cadastros","Informações", cMsgLog, 1, 0)          
        endif    
    endif
next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AjustaSX1ºAutor ³ Sinval Gedolin      º Data ³  22/05/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ajusta o SX1 - Arquivo de Perguntas..                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Funcao Principal                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDATA      ³ ANALISTA ³ MOTIVO                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³          ³                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AjustaSX1(cPerg)
	Local aRegs     := {}  
   Local _sAlias	:= Alias()
   Local i, j

   dbSelectArea("SX1")
   dbSetOrder(1)
   cPerg	:= PADR(cPerg,10)

   //          Grupo/Ordem/Pergunta          /1Perspa/2Pereng/3Variavel/4Tipo/5Tamanho/6Decimal/7Presel/8GSC/9Valid/10Var01/11Def01/12Defspa1/13Defeng1/14Cnt01/15Var02/16Def02/17Defspa2/18Defeng2/19Cnt02/20Var03/21Def03/22Defspa3/23Defeng3/24Cnt03/25Var04/26Def04/27Defspa4/28Defeng4/29Cnt04/30Var05/31Def05/32Defspa5/33Defeng5/34Cnt05/35F3
   aAdd(aRegs,{cPerg,'01','Local do Arquivo   ?','Local do Arquivo   ?','Local do Arquivo   ?','mv_ch1','C',40,0,0,'G','','mv_par01','','','','','','',"","","","","","","","","","","","","","","","","","",""})
   aAdd(aRegs,{cPerg,'02','Nome do arquivo    ?','Nome do arquivo    ?','Nome do arquivo    ?','mv_ch2','C',20,0,0,'G','','mv_par02','','','','','','',"","","","","","","","","","","","","","","","","","",""})
   aAdd(aRegs,{cPerg,'03','Separador          ?','Separador          ?','Separador          ?','mv_ch3','C', 1,0,0,'G','','mv_par03','','','','','','',"","","","","","","","","","","","","","","","","","",""})
   aAdd(aRegs,{cPerg,'04','Código do Cliente  ?','Código do Cliente  ?','Código do Cliente  ?','mv_ch4','C', 6,0,0,'G','','mv_par04','','','','','','',"","","","","","","","","","","","","","","","","","","SA1"})
   aAdd(aRegs,{cPerg,'05','Loja do Cliente    ?','Loja do Cliente    ?','Loja do Cliente    ?','mv_ch5','C', 2,0,0,'G','','mv_par05','','','','','','',"","","","","","","","","","","","","","","","","","","SA1"})
   aAdd(aRegs,{cPerg,'06','Cond. Pagto        ?','Cond. Pagto        ?','Cond. Pagto        ?','mv_ch6','C', 3,0,0,'G','','mv_par06','','','','','','',"","","","","","","","","","","","","","","","","","","SE4"})

   For i:=1 to Len(aRegs)
	   If !dbSeek(cPerg+aRegs[i,2])
	      RecLock("SX1",.T.)
   		For j:=1 to FCount()
	   		If j <= Len(aRegs[i])
		    		FieldPut(j,aRegs[i,j])
			   Endif
    		Next
	    	MsUnlock()
	   Endif
   Next

   dbSelectArea(_sAlias)
Return

