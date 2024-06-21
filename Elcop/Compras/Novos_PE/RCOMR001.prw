#include "protheus.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ RCOMR001  ³ Autor ³Sinval Gedolin        ³ Data ³30/10/2020³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Indice de Qualidade ELCOP                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RLTE003G(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

user Function RCOMR001()
Local oReport

//AjustaSX1("COMR01")
oReport:= ReportDef()
oReport:PrintDialog()
                                               
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ ReportDef³Autor  ³Alexandre Inacio Lemes ³Data  ³21/06/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relacao Detalhes do Acerto do Leite.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ oExpO1: Objeto do relatorio                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()
Local aOrdem   := {} 
Local cTitle   := "Índica de Qualidade do Fornecedor ELCOP - IQF - Período: "
Local oReport 
Local oSection1
Local oSection2

Local aMes		:= {"Janeiro","Fevereiro","Março","Abril","Maio", "Junho", "Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"}      

Pergunte("COMR01",.T.)

cTitle := cTitle + aMes[month(MV_PAR01)]+"/"+StrZero(Year(MV_PAR01),4)

oReport:= TReport():New("RCOMR001",cTitle,"COMR01", {|oReport| ReportPrint(oReport,aOrdem,cTitle)},"Índice de Qualidade do Fornecedor ELCOP" )
oReport:SetTotalInLine(.F.)
oReport:SetLandscape() 
oReport:ShowHeader()

oSection1:= TRSection():New(oReport,"Indice de Qualidade do Fornecedor - IQF: "+dToc(MV_PAR01),{ },,,,,.F.,.T.,.F.,.T.)
oSection1:SetTotalInLine(.F.)

TRCell():New(oSection1,"CODFOR" 		,"   ","Codigo",/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"LOJA"			,"   ","Loja",/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"NOME"			,"   ","Razão Social" ,/*Picture*/,80 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"CNPJ"			,"   ","CNPJ","@R 99.999.999/9999-99",20 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"QTDEENT" 		,"   ","Qt Entregas","@e 99999", 12 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"QTDEATR" 		,"   ","Qt Atrasos","@e 99999", 12 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"EFIENT" 		,"   ","Efic. Entrega=EE","@e 999.99", 15 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"LICALV" 		,"   ","Lic.Alvarás=LA","@e 999.99",15 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"DOCUME" 		,"   ","Documen=DOC","@e 999.99",13 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"QP" 			,"   ","Qua Pro=QP","@e 99999", 13 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"AE" 			,"   ","Aval.Est=AE","@e 999",13/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"IQF" 			,"   ","I Q F","@e 99999",08/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"STATUS" 		,"   ","Status","@!",08/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oSection2:= TRSection():New(oReport,"Memória de Cálculo - IQF: "+dToc(MV_PAR01),{ },,,,,.F.,.T.,.F.,.T.)
oSection2:SetTotalInLine(.F.)

TRCell():New(oSection2,"CODFOR" ,"   ","Codigo",/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"LOJA"	,"   ","Loja",/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"NOME"	,"   ","Razão Social" ,/*Picture*/,80 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"CNPJ"	,"   ","CNPJ","@R 99.999.999/9999-99",20 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"NF" 	,"   ","Nota Fiscal","@!", /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"SERIE" 	,"   ","Série","@!", /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"DTENT" 	,"   ","Dta Receb.",/* */, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"PEDIDO" ,"   ","Ped.Compra","@!", /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"DTPED" 	,"   ","Dta Entrega",/*  */, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"PRODUTO","   ","Produto","@!", /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"DESC" 	,"   ","Descrição","@!",/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"QTDE" 	,"   ","Qtde Receb.","@e 999999",/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"QUAPRO" ,"   ","Qua.Prod=QP","@!",13/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

Return(oReport)

Static Function ReportPrint(oReport,aOrdem,cTitle)
Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(2)
Local cChave 	:= ""
Local nQtdeEnt	:= 0
Local nQtdeDev	:= 0
Local nQtdeAtr	:= 0
Local nIQF		:= 0
Local nNotaDoc	:= 0  
Local nItem		:= 1
Local aIQF		:= {}
Local cQuery	:= ""
Local cAliasSD1 := GetNextAlias()

MakeSqlExpr(oReport:uParam)

oReport:Section(1):BeginQuery()	

//BeginSql Alias cAliasSD1
if SELECT(cAliasSD1) > 0
	(cAliasSD1)->(dbCloseArea())
endif
 
cQuery := "SELECT 	SA2.A2_COD, SA2.A2_LOJA, SA2.A2_NOME, SA2.A2_CGC, SA2.A2_XNOTDOC AS DOC, SA2.A2_XNOTLIC AS LICALV, "
cQuery += "	SA2.A2_XTIPDOC, D1_FILIAL, D1_COD, D1_QUANT, D1_TOTAL, D1_DTDIGIT, D1_PEDIDO, D1_ITEMPC,  "
cQuery += "	SC7.C7_DATPRF, D1_DOC, D1_SERIE, D1_ITEM " // Retirado campo D1_XNOTREC 
cQuery += "FROM "+retSqlName("SA2") + " SA2 "
cQuery += "LEFT JOIN "+retSqlName("SD1") + " SD1 ON SD1.D_E_L_E_T_= ' ' AND SD1.D1_FORNECE = SA2.A2_COD  "
cQuery += "AND SD1.D1_LOJA = SA2.A2_LOJA "
cQuery += "AND SD1.D1_DTDIGIT BETWEEN '"+dtos(firstDay(MV_PAR01))+"' AND '"+dtos(LastDay(MV_PAR01))+"' "   
cQuery += "LEFT JOIN "+retSqlName("SC7") + " SC7 ON SC7.D_E_L_E_T_ = ' ' AND SC7.C7_NUM = SD1.D1_PEDIDO "
cQuery += "AND SC7.C7_ITEM = SD1.D1_ITEMPC AND SC7.C7_FILIAL = SD1.D1_FILIAL "
cQuery += "WHERE SA2.D_E_L_E_T_ = ' ' "
cQuery += "AND  SA2.A2_COD BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"' "
cQuery += "AND SA2.A2_XTIPO = 'O' "
cQuery += "ORDER BY SA2.A2_NOME, SA2.A2_CGC "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD1,.T.,.T.)

//oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)
oReport:SetMeter((cAliasSD1)->(LastRec()))
oSection1:Init()

dbSelectArea(cAliasSD1)
dbGoTop()
While !oReport:Cancel() .And. !(cAliasSD1)->(Eof())

	oReport:IncMeter()
	If oReport:Cancel()
		Exit
	EndIf

	oSection1:Cell("CODFOR"):SetValue( (cAliasSD1)->A2_COD )
	oSection1:Cell("CODFOR"):SetAlign("LEFT")
 
	oSection1:Cell("LOJA"):SetValue((cAliasSD1)->A2_LOJA)
	oSection1:Cell("LOJA"):SetAlign("LEFT")
 
	oSection1:Cell("NOME"):SetValue((cAliasSD1)->A2_NOME)
	oSection1:Cell("NOME"):SetAlign("LEFT")

	oSection1:Cell("CNPJ"):SetValue((cAliasSD1)->A2_CGC)
	oSection1:Cell("CNPJ"):SetAlign("LEFT")

	nQtdeAtr 	:= nQtdeEnt := nQtdeDev := nIQF := 0

	nQP			:= 0 // Qualidade do produto
	nRefQP		:= 0
	nSomaQP		:= 0
	nAE			:= 0
	
	cChave := (cAliasSD1)->(A2_NOME+A2_CGC)
	do while (cAliasSD1)->(!Eof()) .and. (cAliasSD1)->(A2_NOME+A2_CGC) = cChave

		cXTIPDOC	:= (cAliasSD1)->A2_XTIPDOC
		cChaveFor	:= (cAliasSD1)->(A2_COD+A2_LOJA)
		nNotaDoc	:= 0
		nLICALV		:= (cAliasSD1)->LICALV 
		nDOC		:= (cAliasSD1)->DOC
		if cXTIPDOC = "1"
			nNotaDoc := (cAliasSD1)->LICALV 
			
		elseif cXTIPDOC = "2"
			nNotaDoc := (cAliasSD1)->DOC
		else
			nNotaDoc := ( (cAliasSD1)->LICALV + (cAliasSD1)->DOC ) / 2
		endif

		if (cAliasSD1)->D1_QUANT > 0 
			if ( stoD((cAliasSD1)->D1_DTDIGIT) - stoD((cAliasSD1)->C7_DATPRF) > 4 ) .and. (cAliasSD1)->D1_PEDIDO <> '      '

				nQtdeAtr++

			endif
	
			/*if (cAliasSD1)->D1_XNOTREC == "1"
				nRefQP	+= 100 //Atende
			elseif (cAliasSD1)->D1_XNOTREC == "2"
					nRefQP	+= 50 //Atende Parcialmente
			else
				nRefQP	+= 100  // Não Atende
			endif*/// Retirado Validação 09/01/2024
			
			nQtdeEnt ++
			nSomaQP += 100

			aAdd(aIQF, { (cAliasSD1)->A2_COD, (cAliasSD1)->A2_LOJA, (cAliasSD1)->A2_NOME, (cAliasSD1)->A2_CGC,;
						(cAliasSD1)->D1_DOC, (cAliasSD1)->D1_SERIE, stoD((cAliasSD1)->D1_DTDIGIT),;
						(cAliasSD1)->D1_PEDIDO, stoD((cAliasSD1)->C7_DATPRF), (cAliasSD1)->D1_COD,;
						Posicione("SB1",1,xFilial("SB1")+(cAliasSD1)->D1_COD,"B1_DESC"),;
						(cAliasSD1)->D1_QUANT }) //(cAliasSD1)->D1_XNOTREC
		endif

		(cAliasSD1)->(dbSkip())
	enddo

	oSection1:Cell("QTDEENT"):SetValue(nQtdeEnt)
	oSection1:Cell("QTDEENT"):SetAlign("CENTER")
 
	oSection1:Cell("QTDEATR"):SetValue(nQtdeAtr)
	oSection1:Cell("QTDEATR"):SetAlign("CENTER")
 	
	oSection1:Cell("EFIENT"):SetValue(((nQtdeEnt- nQtdeAtr)/if(nQtdeEnt=0,1,nQtdeEnt))*100)
	oSection1:Cell("EFIENT"):SetAlign("CENTER")
	 
	oSection1:Cell("LICALV"):SetValue(nLicAlv)
	oSection1:Cell("LICALV"):SetAlign("CENTER")

	oSection1:Cell("DOCUME"):SetValue(nDOC)
	oSection1:Cell("DOCUME"):SetAlign("CENTER")

	if nQtdeEnt > 0 
		//Nota de Avaliação após a entrega (AE): (registro de Problemas)/ Total Entregue do Último Lote

		nQtdeAE 	:= fQtdeAE( (cAliasSD1)->A2_COD,(cAliasSD1)->A2_LOJA,(cAliasSD1)->D1_COD, MV_PAR01)
		nQtUlLote 	:= fQtUlLote( (cAliasSD1)->A2_COD,(cAliasSD1)->A2_LOJA,(cAliasSD1)->D1_COD )
		
		if nQtdeAE = 0 
			nAE := 100
		else
			if ( nQtdeAE / nQtUlLote ) > 1
				nAE := 0
			else
				nAE := Round(( nQtdeAE / nQtUlLote ) * 100,0)
			endif
		endif

		nQP := Round((nRefQP / nSomaQP) * 100,0)

		if cXTIPDOC $ "1-2"
			nIQF := Round( 0.2 * ((nQtdeEnt- nQtdeAtr)/if(nQtdeEnt=0,1,nQtdeEnt))*100 + 0.3 * (nNotaDoc) + 0.3 * nQP + 0.2 * nAE, 0)
		else
			nIQF := Round( 0.2 * ((nQtdeEnt- nQtdeAtr)/if(nQtdeEnt=0,1,nQtdeEnt))*100 + 0.4 * (nNotaDoc) + 0.3 * nQP + 0.1 * nAE, 0)
		endif
	else
		nIQF := nNotaDoc
	endif

	oSection1:Cell("QP"):SetValue(nQP)
	oSection1:Cell("QP"):SetAlign("CENTER")

	oSection1:Cell("AE"):SetValue(nAE)
	oSection1:Cell("AE"):SetAlign("CENTER")
	
	oSection1:Cell("IQF"):SetValue(nIQF)
	oSection1:Cell("IQF"):SetAlign("CENTER")

	if MV_PAR04 = 2  // 1=Não e 2=Sim
		SA2->(DbSetOrder(1))
		if SA2->(DbSeek(xFilial("SA2")+cChaveFor))
			//Só Atualiza IQF Fornecedor no caso da Data de processamento 
			//do Relatório ser maior do que a últma gravada
			
			If MV_PAR01 >= SA2->A2_XDTAIQF 
				SA2->(recLock("SA2",.F.))
				SA2->A2_XIQF 	:= nIQF
				SA2->A2_XDTAIQF := MV_PAR01
				
				if  nIQF <= 59  //grava a data do bloqueio
					SA2->A2_XDTBIQF := dDatabase
				else
					SA2->A2_XDTBIQF := ctod("  /  /  ")
				endif  
				SA2->(msUnLock())		
		    endif
		endif	
	endif

	if Posicione("SA2",1,xFilial("SA2")+cChaveFor,"A2_XIQF") <> nIQF 
		if MV_PAR01 == Posicione("SA2",1,xFilial("SA2")+cChaveFor,"A2_XDTAIQF")
			oSection1:Cell("STATUS"):SetValue("Alterado")
			oSection1:Cell("STATUS"):SetAlign("CENTER")
		else
			oSection1:Cell("STATUS"):SetValue("       ")
			oSection1:Cell("STATUS"):SetAlign("CENTER")
		endif
	else
		if Posicione("SA2",1,xFilial("SA2")+cChaveFor,"A2_XDTBIQF") <> ctod("  /  /    ")
			oSection1:Cell("STATUS"):SetValue("Bloqueado")
			oSection1:Cell("STATUS"):SetAlign("CENTER")
		else
			oSection1:Cell("STATUS"):SetValue("       ")
			oSection1:Cell("STATUS"):SetAlign("CENTER")
		endif
	endif

   	oSection1:PrintLine()

	dbSelectArea(cAliasSD1)
EndDo

(cAliasSD1)->(dbCloseArea())
oSection1:Finish()

oSection2:Init()

for nItem := 1 to len(aIQF)

	oSection2:Cell("CODFOR"):SetValue(aIQF[nItem][1])
	oSection2:Cell("CODFOR"):SetAlign("LEFT")

	oSection2:Cell("LOJA"):SetValue(aIQF[nItem][2])
	oSection2:Cell("LOJA"):SetAlign("LEFT")
	
	oSection2:Cell("NOME"):SetValue(aIQF[nItem][3])
	oSection2:Cell("NOME"):SetAlign("LEFT")

	oSection2:Cell("CNPJ"):SetValue(aIQF[nItem][4])
	oSection2:Cell("CNPJ"):SetAlign("LEFT")

	oSection2:Cell("NF"):SetValue(aIQF[nItem][5])
	oSection2:Cell("NF"):SetAlign("LEFT")

	oSection2:Cell("SERIE"):SetValue(aIQF[nItem][6])
	oSection2:Cell("SERIE"):SetAlign("LEFT")

	oSection2:Cell("DTENT"):SetValue(aIQF[nItem][7])
	oSection2:Cell("DTENT"):SetAlign("LEFT")
	
	oSection2:Cell("PEDIDO"):SetValue(aIQF[nItem][8])
	oSection2:Cell("PEDIDO"):SetAlign("LEFT")

	oSection2:Cell("DTPED"):SetValue(aIQF[nItem][9])
	oSection2:Cell("DTPED"):SetAlign("LEFT")

	oSection2:Cell("PRODUTO"):SetValue(aIQF[nItem][10])
	oSection2:Cell("PRODUTO"):SetAlign("LEFT")

	oSection2:Cell("DESC"):SetValue(aIQF[nItem][11])
	oSection2:Cell("DESC"):SetAlign("LEFT")

	oSection2:Cell("QTDE"):SetValue(aIQF[nItem][12])
	oSection2:Cell("QTDE"):SetAlign("RIGHT")

	if aIQF[nItem][13] = "1"
		oSection2:Cell("QUAPRO"):SetValue(100)
	elseif aIQF[nItem][13] = "2"
			oSection2:Cell("QUAPRO"):SetValue(50)
	else
		oSection2:Cell("QUAPRO"):SetValue(0)
	endif

	oSection2:Cell("QUAPRO"):SetAlign("RIGHT")

	oSection2:PrintLine()
next

oSection2:Finish()

Return Nil 

static function fQtUlLote(cFornece, cLoja, cProduto)
Local _cQuery 	:= ""
Local dData	

_cQuery := "SELECT MAX(D1_EMISSAO) EMISSAO "
_cQuery += "FROM "+retSqlName("SD1")+ " SD1 "
_cQuery += "WHERE SD1.D_E_L_E_T_ <> '*' AND SD1.D1_TIPO = 'N' "
_cQuery += "AND SD1.D1_COD  = '"+cProduto+"' "
_cQuery += "AND SD1.D1_FORNECE = '"+cFornece+"' "
_cQuery += "AND SD1.D1_LOJA = '"+cLoja+"' "
dbUseArea(.T.,"TOPCONN",TCGenQry(,,ALLTRIM(Upper(_cQuery))),'TRBF',.F.,.T.)

dbSelectArea("TRBF")
TRBF->(DbGotop()) 
dData := sToD(TRBF->EMISSAO)
TRBF->(DbCloseArea())

_cQuery := "SELECT SUM(D1_QUANT) QTDE "
_cQuery += "FROM "+retSqlName("SD1")+ " SD1 "
_cQuery += "WHERE SD1.D_E_L_E_T_ <> '*' AND SD1.D1_TIPO = 'N' "
_cQuery += "AND SD1.D1_COD  = '"+cProduto+"' "
_cQuery += "AND SD1.D1_FORNECE = '"+cFornece+"' "
_cQuery += "AND SD1.D1_LOJA = '"+cLoja+"' "
_cQuery += "AND SD1.D1_EMISSAO BETWEEN '"+dTos(firstDay(dData))+"' AND '"+dTos(lastDay(dData))+"' "
dbUseArea(.T.,"TOPCONN",TCGenQry(,,ALLTRIM(Upper(_cQuery))),'TRBF',.F.,.T.)

dbSelectArea("TRBF")
TRBF->(DbGotop()) 
nQtde := TRBF->QTDE
TRBF->(DbCloseArea())

Return(nQtde)					


/* verifica se existe lançamentos para o Produto e Fornecedor como problema de qualidade */
static function fQtdeAE( cFornece,cLoja, cProduto, dData )
	Local nQtde := 0

	ZCV->(DbSetOrder(1))
	if ZCV->(DbSeek(xFilial("ZCV")+cProduto+cFornece+cLoja))
		do while ZCV->(!Eof()) .and. ZCV->(ZCV_FILIAL+ZCV_PRODUTO+ZCV_FORNEC+ZCV_LOJA) == ;
										xFilial("ZCV")+cProduto+cFornece+cLoja
			if ZCV->ZCV_DATA >= dData .and. ZCV->ZCV_DATA <= dData
				nQtde += ZCV->ZCV_QTDE
			endif

			ZCV->(DbSkip())
		enddo
	endif

return(nQtde)

//===============
// AjustaSX1 
//
Static Function AjustaSX1(cPerg)
Local _sAlias := Alias()
Local aRegs := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

//(sx1) Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
aAdd(aRegs,{cPerg,"01","Data Referencia?"  	,"","","mv_ch1","D", 08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Fornecedor De ?"   	,"","","mv_ch2","C", 06,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SA2"})
aAdd(aRegs,{cPerg,"03","Fornecedor Até ?" 	,"","","mv_ch3","C", 06,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SA2"})
aAdd(aRegs,{cPerg,"04","Atualiza IQF ?"  	,"","","mv_ch4","N", 01,0,0,"C","","mv_par04","Sim","","","Não","","","","","","","","","","","","","","","","","","","","","",""})

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
