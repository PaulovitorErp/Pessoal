#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � AESTA00  �Autor �Sinval Gedolin       � Data �     02/2021 ���
�������������������������������������������������������������������������͹��
���Desc.     � Importa planilha de Pedido de Vendas - ENEL                ���
�������������������������������������������������������������������������͹��
���Uso       � Funcao Auxilia                                             ���
�������������������������������������������������������������������������͹��
���DATA      � ANALISTA �  MOTIVO                                         ���
�������������������������������������������������������������������������͹��
���          �          �                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function AFAT001()
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

	if MsgYesNo("Confirma Importacao do Arquivo => "+Alltrim(MV_PAR01)+Alltrim(MV_PAR02)+ " ?")
		Processa( {|| AFATIMP(Alltrim(MV_PAR01)+Alltrim(MV_PAR02),MV_PAR03) }, "Aguarde...",;
			"Importando Localizaçoes ",.F.)

		msginfo("Importacao Finalizada..","Importacao")
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
	//| Verifica se foi poss�vel abrir o arquivo                            |
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
	|1  |C�digo  (N�mero do Pedido)        |
	|2  |Contrato                          |
	|3  |Descri��o do Servi�o              |
	|4  |Grupo Comprador  (Centro de Custo)|
	|5  |Descri��o grupo Comprador         |
    |6  |Provedor Descri��o                |
    |7  |Posi��o                           |
    |8  |C�digo Baremo                     |
    |9  |Descri��o Baremo                  |
    |10 |Quantidade                        |
    |11 |Valor Unit�rio                    |
    |12 |Valor Total                       |
    |13 |Codigo Ordem                      |
    |14 |Numero Conformidade               |
    |15 |Estado                            |
    |16 |Motivo recusa                     |
    |17 |Domicilio Fiscal (Cod Municip)    |
    |18 |Munic�pio                         |
    |19 |Codigo Lei Comp                   |
    |20 |Centro de Custo                   |
	+---+----------------------------------+*/  

   //nPos := aScan( aPedidos, {| aPosicao | aPosicao[1] == alltrim(aItens[14])+alltrim(aitens[17]) } ) 
   nPos := aScan( aPedidos, {| aPosicao | alltrim(aPosicao[1]) == alltrim(aItens[14])+alltrim(aitens[17]) } ) 
   // vi aqui um post dp aScan colocando alltrim na pesquisa do array


    if nPos = 0
        aAdd(aPedidos,{alltrim(aItens[14])+alltrim(aitens[17])  ,; //Chave de Busca N�mero Conformidade e Domicilio Fiscal
                        aItens[14]                              ,; // Numero Conformidade
                        substr(aitens[17],1,2)                  ,; // Domiclio Fiscal (Estado)
                        substr(aitens[17],6,5)                  ,; // Domiclio Fiscal (Minic�pio)
                        val(strTran(aItens[12],",","."))        ,; // Valor Total
                        aItens[04]                              ,; // Grupo Comprador (Centro de Custo)
                        sTrTran(aItens[03],"_"," ")             ,; // Descri��o do Servi�o
                        alltrim(aItens[01])                     ,; // N�mero do Pedido
                        alltrim(aItens[02])                     ,; // N�mero do Contrato      
                        alltrim(aitens[20])                     ,; // Centro de Custo 
                        alltrim(aitens[19])})                      // Cod iss                     
                  

   else
        aPedidos[nPos][5] += val(strTran(aItens[12],",","."))        
    endif
Return Nil

//Gera��o dos Pedidos de Vendas
static Function fFatPed(aPedidos)

Local cDoc       := ""              // N�mero do Pedido de Vendas
Local cA1Cod     := MV_PAR04        // C�digo do Cliente
Local cA1Loja    := MV_PAR05        // Loja do Cliente
Local cB1Cod     := ""              // C�digo do Produto
Local cF4TES     := ""              // C�digo do TES
Local naliqfat   :=""               // Aliq iss no faturamento
Local cE4Codigo  := Posicione("SA1",1,xFilial("SA1")+MV_PAR04+MV_PAR05,"A1_COND") // C�digo da Condi��o de Pagamento
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
Local cComerc := ""
Local cCodiss := ""
Local cNat1     := SuperGetMv( "MV_XNAT1")
Local cNat2     := SuperGetMv( "MV_XNAT2")

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
  
   IncProc("Gerando Pedidos, N�mero ==> "+Alltrim(cDoc))

   //Buscando o C�digo do Produto, que conter�, TES, Munic�pio, Centro de Custo, CodISS, Aliqu ISS, CNAE
   cEstado  := aPedidos[nItem][3]
   cMunic   := aPedidos[nItem][4]
   cComerc  := aPedidos[nItem][9]
   cCodiss  := aPedidos[nItem][11]

   cAliasTop := GetNextAlias()

   if select(cAliasTop) > 0
      (cAliasTop)->(DbcloseArea())
   endif

   cQuery := "SELECT SB1.B1_COD, SB1.B1_XEST, SB1.B1_XCODMUN,B1_CODISS "
   cQuery += "FROM "+RetSqlName("SB1")+" SB1 "
   cQuery += "WHERE SB1.D_E_L_E_T_=' ' AND SB1.B1_XEST ='"+cEstado+"' AND SB1.B1_XCODMUN = '"+cMunic+"' AND SB1.B1_CODISS = '"+cCodiss+"' " 
  
   cQuery := ChangeQuery(cQuery)
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)

   (cAliasTop)->(dbGoTop())
   do while (cAliasTop)->(!Eof())
         
      cB1Cod := (cAliasTop)->B1_COD
         
      (cAliasTop)->(dbSkip())
   enddo

   (cAliasTop)->(DbcloseArea())

   if empty(alltrim(cB1Cod))
      Help( ,, "Produto","Municipio",;
               "N�o foi Localizado Municipio no Cadastro do Produto => "+cMunic, 1, 0)     
   else

      cb1CodISS   := strZero(val(alltrim(Posicione("SB1",1,xFilial("SB1")+cB1Cod,"B1_CODISS"))),4)
      cF4TES      := Posicione("SB1",1,xFilial("SB1")+cB1Cod,"B1_TS")
      naliqfat    := Posicione("SB1",1,xFilial("SB1")+cB1Cod,"B1_XISSFAT")

      //Alterado a regra saiu do Cadastro de Produtos para a Informa��o na Planilha
      cB1CC       := aPedidos[nItem][10]   //Posicione("SB1",1,xFilial("SB1")+cB1Cod,"B1_CC")

      cXMennfs    := cb1CodISS+" "+aPedidos[nItem][7]+cEOL
      cXMennfs    += "Centro de Custo: "+alltrim(aPedidos[nItem][6])+cEOL
      cXMennfs    += "Pedido: "+alltrim(aPedidos[nItem][8])+cEOL
      cXMennfs    += "Conformidade: "+alltrim(aPedidos[nItem][2])+cEOL
      cXMennfs    += "Contrato: "+alltrim(aPedidos[nItem][9])+cEOL
      //cXMennfs    += "ISSQN RETIDO: "+alltrim(aPedidos[nItem][11])+cEOL
      cXMennfs += "ISSQN RETIDO: "+alltrim(transform(aPedidos[nItem][5],"@e 99,999,999.99")) + " X " + alltrim(Str(naliqfat)) + "% "+"= " + alltrim(transform(  ABS((aPedidos[nItem][5]*naliqfat/100)),"@e 99,999,999.99")) +cEOL



      /* Composi��o da Observa��o
      0702 NCO ELCOP CONTEMERG SUL OPEX 0321 2168
      Centro de Custo: GCI
      Pedido: 6000112635
      Conformidade: 5000455010
      Contrato: 52L0002168
      */

	Aadd(aCabec, {"C5_ESTPRES" , cEstado   , Nil})
	Aadd(aCabec, {"C5_MUNPRES" , cMunic    , Nil})
	Aadd(aCabec, {"C5_XMENNFS" , cXMennfs  , Nil})
	 	If cCodiss ='1705' 
	Aadd(aCabec, {"C5_NATUREZ" , cNat1  , Nil})
	Endif
	If cCodiss = '1701'
	Aadd(aCabec, {"C5_NATUREZ" , cNat2  , Nil})
	Endif

	
	If SF4->(! MsSeek(cFilSF4 + cF4TES))
		cMsgLog += "Cadastrar a TES: " + cF4TES + cEOL
		lOk     := .F.
	EndIf

	If SE4->(! MsSeek(cFilSE4 + cE4Codigo))
		cMsgLog += "Cadastrar a Codi��o de Pagamento: " + cE4Codigo + cEOL
		lOk     := .F.
	EndIf

	If SA1->(! MsSeek(cFilSA1 + cA1Cod+cA1Cod))
		cMsgLog += "Cadastrar o Cliente: " + cA1Cod+cA1Cod + cEOL
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
		Help( ,, "Cadastros","Informa��es", cMsgLog, 1, 0)
	endif
endif
next

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � AjustaSX1�Autor � Sinval Gedolin      � Data �  22/05/06   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ajusta o SX1 - Arquivo de Perguntas..                      ���
�������������������������������������������������������������������������͹��
���Uso       � Funcao Principal                                           ���
�������������������������������������������������������������������������͹��
���DATA      � ANALISTA � MOTIVO                                          ���
�������������������������������������������������������������������������͹��
���          �          �                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
	aAdd(aRegs,{cPerg,'04','C�digo do Cliente  ?','C�digo do Cliente  ?','C�digo do Cliente  ?','mv_ch4','C', 6,0,0,'G','','mv_par04','','','','','','',"","","","","","","","","","","","","","","","","","","SA1"})
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


/*
   aCabec         := {}
   aItens         := {}
   aLinha         := {}
   lMsErroAuto    := .F.
   lAutoErrNoFile := .F.
 
   aadd(aCabec, {"C5_NUM",     cDoc,      Nil})
   aadd(aCabec, {"C5_TIPO",    "N",       Nil})
   aadd(aCabec, {"C5_CLIENTE", cA1Cod,    Nil})
   aadd(aCabec, {"C5_LOJACLI", cA1Loja,   Nil})
   aadd(aCabec, {"C5_LOJAENT", cA1Loja,   Nil})
   aadd(aCabec, {"C5_CONDPAG", cE4Codigo, Nil})
 
   If cPaisLoc == "PTG"
      aadd(aCabec, {"C5_DECLEXP", "TESTE", Nil})
   Endif
 
   For nX := 1 To 02
      //--- Informando os dados do item do Pedido de Venda
      aLinha := {}
      aadd(aLinha,{"LINPOS",     "C6_ITEM",     StrZero(nX,2)})
      aadd(aLinha,{"AUTDELETA",  "N",           Nil})
      aadd(aLinha,{"C6_PRODUTO", cB1Cod,        Nil})
      aadd(aLinha,{"C6_QTDVEN",  2,             Nil})
      aadd(aLinha,{"C6_PRCVEN",  2000,          Nil})
      aadd(aLinha,{"C6_PRUNIT",  2000,          Nil})
      aadd(aLinha,{"C6_VALOR",   4000,          Nil})
      aadd(aLinha,{"C6_TES",     cF4TES,        Nil})
      aadd(aItens, aLinha)
   Next nX
 
   nOpcX := 4
   MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCabec, aItens, nOpcX, .F.)
   If !lMsErroAuto
      ConOut("Alterado com sucesso! " + cDoc)
   Else
      ConOut("Erro na altera��o!")
      aErroAuto := GetAutoGRLog()
      For nCount := 1 To Len(aErroAuto)
         cLogErro += StrTran(StrTran(aErroAuto[nCount], "<", ""), "-", "") + " "
         ConOut(cLogErro)
      Next nCount
   EndIf

   ConOut(PadC("Teste de exclus�o",80))
 
   aCabec         := {}
   aItens         := {}
   aLinha         := {}
   lMsErroAuto    := .F.
   lAutoErrNoFile := .F.
 
   aadd(aCabec, {"C5_NUM",     cDoc,      Nil})
   aadd(aCabec, {"C5_TIPO",    "N",       Nil})
   aadd(aCabec, {"C5_CLIENTE", cA1Cod,    Nil})
   aadd(aCabec, {"C5_LOJACLI", cA1Loja,   Nil})
   aadd(aCabec, {"C5_LOJAENT", cA1Loja,   Nil})
   aadd(aCabec, {"C5_CONDPAG", cE4Codigo, Nil})
 
   If cPaisLoc == "PTG"
      aadd(aCabec, {"C5_DECLEXP", "TESTE", Nil})
   Endif
 
   For nX := 1 To 02
      //--- Informando os dados do item do Pedido de Venda
      aLinha := {}
      aadd(aLinha,{"C6_ITEM",    StrZero(nX,2), Nil})
      aadd(aLinha,{"C6_PRODUTO", cB1Cod,        Nil})
      aadd(aLinha,{"C6_QTDVEN",  2,             Nil})
      aadd(aLinha,{"C6_PRCVEN",  2000,          Nil})
      aadd(aLinha,{"C6_PRUNIT",  2000,          Nil})
      aadd(aLinha,{"C6_VALOR",   4000,          Nil})
      aadd(aLinha,{"C6_TES",     cF4TES,        Nil})
      aadd(aItens, aLinha)
   Next nX
 
   MSExecAuto({|a, b, c| MATA410(a, b, c)}, aCabec, aItens, 5)
   If !lMsErroAuto
      ConOut("Exclu�do com sucesso! " + cDoc)
   Else
      ConOut("Erro na exclus�o!")
   EndIf
  
*/
