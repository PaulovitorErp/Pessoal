#include 'protheus.ch'

/*
========================================================================================================================
Programa--------------: RFINX001
Autor-----------------: Erivaldo Oliveira
Data da Criação-------: 02/04/2020
========================================================================================================================
Descrição-------------: Relatório de contas a receber (Inadimplência)
========================================================================================================================
Uso-------------------: Financeiro
========================================================================================================================
Parâmetros------------: De usuário, na entrada da rotina.
========================================================================================================================
Retorno---------------: Nenhum
========================================================================================================================

*/

User function RFINX002()
	Private _oReport
	Private _nqtreg		:= 0
	Private _caliasSE1	:= getnextalias()
	Private _aqry		:= {}
	Private oFont11b
	
	Define Font oFont11b Name "Arial" Size 0,-10 Bold // Arial 11 Negrito

	If !Parametros()
		Return
	Else

		BeginSql Alias _caliasSE1
			Select *
			from %table:SE1% se1
			left join %table:SA1% sa1
			on se1.e1_cliente = sa1.a1_cod and se1.e1_loja = sa1.a1_loja
			where se1.e1_baixa between %exp:dtos(mv_par01)% and %exp:dtos(mv_par02)%
			and se1.e1_tipo not in ('AB-','NCC','RA','PR')
			and se1.e1_prefixo in ('1')
			and se1.e1_origem = %exp:'MATA460'%
			and se1.%notdel%
			and sa1.%notdel%
			order by  e1_filial, e1_vencrea, a1_nome
		EndSql
	
		_aqry := getlastquery()
		memowrite(gettemppath()+'RFINX002.TXT',_aqry[2])

		count to _nqtreg

		If _nqtreg	== 0
			MsgStop("Sem dados para esses parâmetros.")
			(_caliasSE1)->(DbCloseArea())
			Return
		Else
			(_caliasSE1)->(DbGoTop())
		Endif

	Endif

	_oReport := Reportdef()
	_oReport:nDevice := 2 //1-Arquivo,2-Impressora,3-email,4-Planilha e 5-Html
	_oReport:PrintDialog()

Return

Static Function Reportdef()
	Private _oReport := NIL
	Private _oSection1
	Private _oSection2
	Private _cTitulo	:= "Contas a Receber - Baixas"

	_oReport := Treport():New("Contas a Receber - Baixas",_cTitulo,{|_oReport| Parametros() },{|_oReport| PrintReport(_oReport)},"Contas a Receber - Baixas")
	_oReport:SetLandscape()
	_oReport:oPage:setPaperSize(9)

	//Parametros.
	_oSection1 := Trsection():New(_oReport,"CR",{"qry"},nil , .f., .t.)
	TrCell():New(_oSection1,"C1","QRY","Filial","@!",15)							
	TrCell():New(_oSection1,"C2","QRY","Prefixo","@!",15)							
	TrCell():New(_oSection1,"C3","QRY","Numero","@!",15)							
	TrCell():New(_oSection1,"C4","QRY","Parcela","@!",15)							
	TrCell():New(_oSection1,"C5","QRY","Tipo","@!",15)							
	TrCell():New(_oSection1,"C6","QRY","Codigo","@!",15)							
	TrCell():New(_oSection1,"C7","QRY","Loja","@!",15)							
	TrCell():New(_oSection1,"C8","QRY","Nome","@!",50)							
	TrCell():New(_oSection1,"C9","QRY","Emissao","@!",15)							
	TrCell():New(_oSection1,"C10","QRY","Vencto. Real","@!",15)							
	TrCell():New(_oSection1,"C11","QRY","Valor Original","@!",15)							
	TrCell():New(_oSection1,"C12","QRY","Saldo","@!",15)
	TrCell():New(_oSection1,"C13","QRY","Baixas","@!",15)
	TrCell():New(_oSection1,"C14","QRY","Dt. Baixa","@!",15)
	TrCell():New(_oSection1,"C15","QRY","Vendedor","@!",50)
	TrCell():New(_oSection1,"C16","QRY","Cidade/Estado (cliente)","@!",75)

	_oSection2 := Trsection():New(_oReport,"CR",{"qry"},nil , .f., .t.)
	
	TrCell():New(_oSection2,"C1","QRY","","@!",15)							
	TrCell():New(_oSection2,"C2","QRY","","@!",20)							
	TrCell():New(_oSection2,"C3","QRY","","@!",60)							
	
	_oSection3 := Trsection():New(_oReport,"CR",{"qry"},nil , .f., .t.)
	
	TrCell():New(_oSection3,"C1","QRY","","@!",15)							
	TrCell():New(_oSection3,"C2","QRY","","@!",15)							
	TrCell():New(_oSection3,"C3","QRY","","@!",15)							
	TrCell():New(_oSection3,"C4","QRY","","@!",15)							
	TrCell():New(_oSection3,"C5","QRY","","@!",15)							
	TrCell():New(_oSection3,"C6","QRY","","@!",15)							
	TrCell():New(_oSection3,"C7","QRY","","@!",15)							
	TrCell():New(_oSection3,"C8","QRY","","@!",50)							
	TrCell():New(_oSection3,"C9","QRY","","@!",15)							
	TrCell():New(_oSection3,"C10","QRY","","@!",15)							
	TrCell():New(_oSection3,"C11","QRY","Total Original","@!",15)							
	TrCell():New(_oSection3,"C12","QRY","Saldo Total","@!",15)
	TrCell():New(_oSection3,"C13","QRY","","@!",15)

	_oReport:nFontBody := 9
	_oReport:CFONTBODY:="Courier New"
	_oReport:lParamPage := .T.
	_oReport:GetOrientation(2) //2 - Paisagem

Return _oReport

//Impressão
Static Function PrintReport(_oReport)
	Local _oSection1 	:= _oReport:section(1)		//Seção 1.
	Local _oSection2 	:= _oReport:section(2)		//Seção 1.
	Local _oSection3 	:= _oReport:section(3)		//Seção 1.
	Local _nsaltot		:= 0	//Saldo total
	Local _npertit		:= 0	//Percentual de inadimplencia por título
	Local _npermed		:= 0
	Local _nqtreg		:= 0
	Local _ntotal		:= 0
	Local _nsaldo		:= 0
	Local _ntotperc		:= 0
	Local _cvendedor	:= ""
	Local _caliassd2	:= getnextalias()

	_oReport:SetMeter(_nQtReg)

	_oSection1:Init()

	(_cAliasSE1)->(dbgotop())
	
	While !(_cAliasSE1)->(Eof())
	
		If _oReport:row()	> 2700
			_oReport:EndPage()
			_oReport:StartPage()
		Endif

		_oReport:IncMeter()

		If _oReport:Cancel()
			Exit
		Endif

		cNomeCli := Posicione("SA1",1,xFilial("SA1")+(_cAliasSE1)->e1_cliente+(_cAliasSE1)->e1_loja,"A1_NOME")
		ndias	 := ddatabase - stod((_cAliasSE1)->e1_vencrea)
		_cvendedor := posicione('SA3',1,xfilial('SA3')+(_cAliasSE1)->e1_vend1,'A3_NOME')
		
		_ntotal	+= (_cAliasSE1)->e1_valor
		_nsaltot	+= (_cAliasSE1)->e1_saldo
		
		_oSection1:Cell("C1"):SetValue((_cAliasSE1)->e1_filial)
		_oSection1:Cell("C2"):SetValue((_cAliasSE1)->e1_prefixo)
		_oSection1:Cell("C3"):SetValue((_cAliasSE1)->e1_num)
		_oSection1:Cell("C4"):SetValue((_cAliasSE1)->e1_parcela)
		_oSection1:Cell("C5"):SetValue((_cAliasSE1)->e1_tipo)
		_oSection1:Cell("C6"):SetValue((_cAliasSE1)->e1_cliente)
		_oSection1:Cell("C7"):SetValue((_cAliasSE1)->e1_loja)
		_oSection1:Cell("C8"):SetValue(cNomeCli)
		_oSection1:Cell("C9"):SetValue(dtoc(stod((_cAliasSE1)->e1_emissao)))
		_oSection1:Cell("C10"):SetValue(dtoc(stod((_cAliasSE1)->e1_vencrea)))
		_oSection1:Cell("C11"):SetValue(transform((_cAliasSE1)->e1_valor,PesqPict('SE1','E1_VALOR')))
		_oSection1:Cell("C12"):SetValue(transform((_cAliasSE1)->e1_saldo,PesqPict('SE1','E1_SALDO')))
		If !empty((_cAliasSE1)->e1_baixa)
			_oSection1:Cell("C13"):SetValue('SIM')
		Else
			_oSection1:Cell("C13"):SetValue('')			
		Endif
			
		_oSection1:Cell("C14"):SetValue(dtoc(stod((_cAliasSE1)->e1_baixa)))	
		_oSection1:Cell("C15"):SetValue(_cvendedor)
		_oSection1:Cell("C16"):SetValue(alltrim((_cAliasSE1)->a1_mun)+'-'+(_cAliasSE1)->a1_est)
			
		_oSection1:PrintLine()
		
		BeginSql Alias _caliasSD2
			Select d2_cod, b1_desc
			from %table:SD2% sd2 
			left join %table:SB1% sb1 
			on sd2.d2_cod = sb1.b1_cod 
			where sd2.d2_cliente = %exp:(_caliasse1)->e1_cliente%
			and sd2.d2_loja = %exp:(_caliasse1)->e1_loja%
			and sd2.d2_serie = %exp:(_caliasse1)->e1_prefixo%
			and sd2.d2_doc = %exp:(_caliasse1)->e1_num%
			and sd2.%notdel%
			and sb1.%notdel%
		EndSql
		
		_oSection2:Init()
		
		while !(_caliasSD2)->(eof())
		
			_oSection2:Cell("C1"):SetValue("Produto(s) : ")
			_oSection2:Cell("C2"):SetValue((_cAliasSD2)->d2_cod)
			_oSection2:Cell("C3"):SetValue((_cAliasSD2)->b1_desc)
		
			_oSection2:PrintLine()
		
			(_cAliasSD2)->(DBSKIP())
		enddo
		
		(_cAliasSD2)->(DBCLOSEAREA())
		
		(_cAliasSE1)->(DBSKIP())

	enddo
	
	_oSection3:Init()
	_oSection3:Cell("C1"):SetValue()
	_oSection3:Cell("C2"):SetValue()
	_oSection3:Cell("C3"):SetValue()
	_oSection3:Cell("C4"):SetValue()
	_oSection3:Cell("C5"):SetValue()
	_oSection3:Cell("C6"):SetValue()
	_oSection3:Cell("C7"):SetValue()
	_oSection3:Cell("C8"):SetValue()
	_oSection3:Cell("C9"):SetValue()
	_oSection3:Cell("C10"):SetValue('Totais : ')
	_oSection3:Cell("C11"):SetValue(transform(_ntotal,PesqPict('SE1','E1_VALOR')))
	_oSection3:Cell("C12"):SetValue(transform(_nsaltot,PesqPict('SE1','E1_SALDO')))
	_oSection3:Cell("C13"):SetValue()

	_oSection3:PrintLine()
		
	If _oReport:row()	> 2600
		_oReport:EndPage()
		_oReport:StartPage()
	Endif

	(_cAliasSE1)->(DbCloseArea())

Return

//Parâmetros do Relatório
Static Function Parametros()
	Local FINX002 := {}
	Local aret   := {}
	
	Aadd(FINX002,{1,"Da data de baixa "				,dDatabase,PesqPict("SE1", "E1_EMISSAO"),'.t.',"" ,'.t.', 50, .t.})
	Aadd(FINX002,{1,"Até a data de baixa  "			,dDatabase,PesqPict("SE1", "E1_EMISSAO"),'.t.',"" ,'.t.', 50, .t.})

	If !Parambox(FINX002,"parâmetros",@aret)
		Return .f.
	Endif

Return .t.