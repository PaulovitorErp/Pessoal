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

User function RFINX001()
	Private _oReport
	Private _nqtreg		:= 0
	Private _caliasSE1	:= getnextalias()
	Private _aqry		:= {}
	Private oFont11b
	
	Define Font oFont11b Name "Arial" Size 0,-10 Bold // Arial 11 Negrito

	If !Parametros()
		Return
	Else

		If mv_par09 == "A receber"
			BeginSql Alias _caliasSE1
				Select *
				from %table:SE1% se1
				left join %table:SA1% sa1
				on se1.e1_cliente = sa1.a1_cod and se1.e1_loja = sa1.a1_loja
				where se1.e1_emissao between %exp:dtos(mv_par01)% and %exp:dtos(mv_par02)%
				and se1.e1_vencrea between %exp:dtos(mv_par03)% and %exp:dtos(mv_par04)%
				and se1.e1_cliente between %exp:mv_par05% and %exp:mv_par07%
				and se1.e1_loja between %exp:mv_par06% and %exp:mv_par08%
				and se1.e1_prefixo in ('LOC','1')
				and se1.e1_saldo > %exp:0%
				and se1.e1_tipo not in ('AB-','NCC','RA','PR')
				and se1.%notdel%
				and sa1.%notdel%
				order by  e1_filial, e1_vencrea, a1_nome
			EndSql
		Else
			BeginSql Alias _caliasSE1
				Select *
				from %table:SE1% se1
				left join %table:SA1% sa1
				on se1.e1_cliente = sa1.a1_cod and se1.e1_loja = sa1.a1_loja
				where se1.e1_emissao between %exp:dtos(mv_par01)% and %exp:dtos(mv_par02)%
				and se1.e1_vencrea between %exp:dtos(mv_par03)% and %exp:dtos(mv_par04)%
				and se1.e1_cliente between %exp:mv_par05% and %exp:mv_par07%
				and se1.e1_loja between %exp:mv_par06% and %exp:mv_par08%
				and se1.e1_tipo not in ('AB-','NCC','RA','PR')
				and se1.e1_prefixo in ('LOC','1')
				and se1.e1_origem = %exp:'MATA460'%
				and se1.%notdel%
				and sa1.%notdel%
				order by  e1_filial, e1_vencrea, a1_nome
			EndSql
		Endif
	
		_aqry := getlastquery()
		memowrite(gettemppath()+'RFINX001.TXT',_aqry[2])

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
	Private _cTitulo	:= "Contas a Receber - Inadimplência"

	_oReport := Treport():New("Contas a Receber - Inadimplência",_cTitulo,{|_oReport| Parametros() },{|_oReport| PrintReport(_oReport)},"Contas a Receber - Inadimplência")
	_oReport:SetLandscape()
	_oReport:oPage:setPaperSize(9)

	//Parametros.
	_oSection1 := Trsection():New(_oReport,"CR",{"qry"},nil , .f., .t.)
	If mv_par09 == "A Receber"

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
		TrCell():New(_oSection1,"C13","QRY","Dias Atraso","@!",15)
		TrCell():New(_oSection1,"C14","QRY","PCLD","@!",15)
		TrCell():New(_oSection1,"C15","QRY","% Inad. Titulo","@!",15)
		TrCell():New(_oSection1,"C16","QRY","Vendedor","@!",50)
	
		_oSection2 := Trsection():New(_oReport,"CR",{"qry"},nil , .f., .t.)
	
		TrCell():New(_oSection2,"C1","QRY","","@!",15)							
		TrCell():New(_oSection2,"C2","QRY","","@!",15)							
		TrCell():New(_oSection2,"C3","QRY","","@!",15)							
		TrCell():New(_oSection2,"C4","QRY","","@!",15)							
		TrCell():New(_oSection2,"C5","QRY","","@!",15)							
		TrCell():New(_oSection2,"C6","QRY","","@!",15)							
		TrCell():New(_oSection2,"C7","QRY","","@!",15)							
		TrCell():New(_oSection2,"C8","QRY","","@!",50)							
		TrCell():New(_oSection2,"C9","QRY","","@!",15)							
		TrCell():New(_oSection2,"C10","QRY","","@!",15)							
		TrCell():New(_oSection2,"C11","QRY","Total Original","@!",15)							
		TrCell():New(_oSection2,"C12","QRY","Total Inadimplente","@!",15)
		TrCell():New(_oSection2,"C13","QRY","","@!",15)
		TrCell():New(_oSection2,"C14","QRY","","@!",15)
		TrCell():New(_oSection2,"C15","QRY","Soma Perc. Inadimplência","@!",15)

	Else
	
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
		TrCell():New(_oSection1,"C14","QRY","Vendedor","@!",50)
	
		_oSection2 := Trsection():New(_oReport,"CR",{"qry"},nil , .f., .t.)
	
		TrCell():New(_oSection2,"C1","QRY","","@!",15)							
		TrCell():New(_oSection2,"C2","QRY","","@!",15)							
		TrCell():New(_oSection2,"C3","QRY","","@!",15)							
		TrCell():New(_oSection2,"C4","QRY","","@!",15)							
		TrCell():New(_oSection2,"C5","QRY","","@!",15)							
		TrCell():New(_oSection2,"C6","QRY","","@!",15)							
		TrCell():New(_oSection2,"C7","QRY","","@!",15)							
		TrCell():New(_oSection2,"C8","QRY","","@!",50)							
		TrCell():New(_oSection2,"C9","QRY","","@!",15)							
		TrCell():New(_oSection2,"C10","QRY","","@!",15)							
		TrCell():New(_oSection2,"C11","QRY","Total Original","@!",15)							
		TrCell():New(_oSection2,"C12","QRY","Saldo Total","@!",15)
		TrCell():New(_oSection2,"C13","QRY","","@!",15)

	
	Endif
	
	_oReport:nFontBody := 9
	_oReport:CFONTBODY:="Courier New"
	_oReport:lParamPage := .T.
	_oReport:GetOrientation(2) //2 - Paisagem

Return _oReport

//Impressão
Static Function PrintReport(_oReport)
	Local _oSection1 	:= _oReport:section(1)		//Seção 1.
	Local _oSection2 	:= _oReport:section(2)		//Seção 1.
	Local _nsaltot		:= 0	//Saldo total
	Local _npertit		:= 0	//Percentual de inadimplencia por título
	Local _npermed		:= 0
	Local _nqtreg		:= 0
	Local _ntotal		:= 0
	Local _nsaldo		:= 0
	Local _ntotperc		:= 0
	Local _cvendedor	:= ""

	_oReport:SetMeter(_nQtReg)

	_oSection1:Init()

	While !(_cAliasSE1)->(Eof())
	
		_nqtreg++
		
		ndias	 := ddatabase - stod((_cAliasSE1)->e1_vencrea)
		
		_ntotal	+= (_cAliasSE1)->e1_valor
		
		If ((_cAliasSE1)->e1_saldo > 0 .and. ndias <= 0)
			(_cAliasSE1)->(DBSKIP())
			loop
		Endif
		
		do case
			case (((_cAliasSE1)->e1_saldo > 0 .and.  (_cAliasSE1)->e1_saldo <= 15000) .and. ndias > 180)
				cpcld	:= "PCLD-A"
			case ((_cAliasSE1)->e1_saldo > 15000 .and. (_cAliasSE1)->e1_saldo < 100000 .and. ndias >= 365)
				cpcld	:= "PCLD-B"
			case ((_cAliasSE1)->e1_saldo > 100000 .and. ndias > 365)
				cpcld	:= "PCLD-C"
			case ((_cAliasSE1)->e1_saldo > 0 .and. (ndias > 0 .and.  ndias < 180))
				_nsaltot	+= (_cAliasSE1)->e1_saldo			
			case ((_cAliasSE1)->e1_saldo > 0 .and. ndias <= 0)
				cpcld	:= "A Vencer"			
			otherwise
				cpcld	:= "Inadimplente"
				If mv_par09 == "A Receber"
					_nsaltot	+= (_cAliasSE1)->e1_saldo
				Endif			
		endcase
 
		If mv_par09 <> "A Receber"
 
			_nsaltot	+= (_cAliasSE1)->e1_saldo
 
		Endif
		
		(_cAliasSE1)->(DBSKIP())
		
	enddo	
	
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
		
		If mv_par09	== "A Receber"
		
			do case
				case (((_cAliasSE1)->e1_saldo > 0 .and.  (_cAliasSE1)->e1_saldo <= 15000) .and. ndias > 180)
					cpcld	:= "PCLD-A"
				case ((_cAliasSE1)->e1_saldo > 15000 .and. (_cAliasSE1)->e1_saldo < 100000 .and. ndias >= 365)
					cpcld	:= "PCLD-B"
				case ((_cAliasSE1)->e1_saldo > 100000 .and. ndias > 365)
					cpcld	:= "PCLD-C"
				case ((_cAliasSE1)->e1_saldo > 0 .and. (ndias > 0 .and.  ndias < 180))
					cpcld	:= "Inadimplente"			
				case ((_cAliasSE1)->e1_saldo > 0 .and. ndias <= 0)
					cpcld	:= "A Vencer"			
				otherwise
					cpcld	:= "Inadimplente"
			endcase
			
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
			_oSection1:Cell("C13"):SetValue(transform(ndias,"@E 999999"))
			_oSection1:Cell("C14"):SetValue(cpcld)
	
			_npertit := ((_cAliasSE1)->e1_saldo / _nsaltot)*100
	
			If (ndias > 0 .and. !"PCLD" $ cpcld) 
				_oSection1:Cell("C15"):SetValue(transform(_npertit,"@E 999.9999999999999999"))
				_ntotperc	+= _npertit
				
			else
				_oSection1:Cell("C15"):SetValue('')
			endif
			
			_oSection1:Cell("C16"):SetValue(_cvendedor)
			
			_oSection1:PrintLine()

		Else

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
			
			_oSection1:Cell("C14"):SetValue(_cvendedor)
			
			_oSection1:PrintLine()
			
			
		Endif
		
		(_cAliasSE1)->(DBSKIP())

	enddo
	
	_oSection2:Init()
	If mv_par09 == "A Receber"
		_oSection2:Cell("C1"):SetValue()
		_oSection2:Cell("C2"):SetValue()
		_oSection2:Cell("C3"):SetValue()
		_oSection2:Cell("C4"):SetValue()
		_oSection2:Cell("C5"):SetValue()
		_oSection2:Cell("C6"):SetValue()
		_oSection2:Cell("C7"):SetValue()
		_oSection2:Cell("C8"):SetValue()
		_oSection2:Cell("C9"):SetValue()
		_oSection2:Cell("C10"):SetValue('Totais : ')
		_oSection2:Cell("C11"):SetValue(transform(_ntotal,PesqPict('SE1','E1_VALOR')))
		_oSection2:Cell("C12"):SetValue(transform(_nsaltot,PesqPict('SE1','E1_SALDO')))
		_oSection2:Cell("C13"):SetValue()
		_oSection2:Cell("C14"):SetValue()
		_oSection2:Cell("C15"):SetValue(transform(_ntotperc,PesqPict('SE1','E1_VALOR'))+'%')
	Else
		_oSection2:Cell("C1"):SetValue()
		_oSection2:Cell("C2"):SetValue()
		_oSection2:Cell("C3"):SetValue()
		_oSection2:Cell("C4"):SetValue()
		_oSection2:Cell("C5"):SetValue()
		_oSection2:Cell("C6"):SetValue()
		_oSection2:Cell("C7"):SetValue()
		_oSection2:Cell("C8"):SetValue()
		_oSection2:Cell("C9"):SetValue()
		_oSection2:Cell("C10"):SetValue('Totais : ')
		_oSection2:Cell("C11"):SetValue(transform(_ntotal,PesqPict('SE1','E1_VALOR')))
		_oSection2:Cell("C12"):SetValue(transform(_nsaltot,PesqPict('SE1','E1_SALDO')))
		_oSection2:Cell("C13"):SetValue()
	Endif

	_oSection2:PrintLine()
		
	If _oReport:row()	> 2600
		_oReport:EndPage()
		_oReport:StartPage()
	Endif

	(_cAliasSE1)->(DbCloseArea())

Return

//Parâmetros do Relatório
Static Function Parametros()
	Local FINX001 := {}
	Local aret   := {}
	Local aCombo := {"A Receber","Faturados"}
	
	Aadd(FINX001,{1,"Da emissão  "				,dDatabase,PesqPict("SE1", "E1_EMISSAO"),'.t.',"" ,'.t.', 50, .t.})
	Aadd(FINX001,{1,"Até a emissão  "			,dDatabase,PesqPict("SE1", "E1_EMISSAO"),'.t.',"" ,'.t.', 50, .t.})
	Aadd(FINX001,{1,"Do vencimento "			,dDatabase,PesqPict("SE1", "E1_VENCREA"),'.t.',"" ,'.t.', 50, .t.})
	Aadd(FINX001,{1,"Até o vencimento "			,dDatabase,PesqPict("SE1", "E1_VENCREA"),'.t.',"" ,'.t.', 50, .t.})
	Aadd(FINX001,{1,"Do Cliente "				,Space(TamSx3('E1_CLIENTE')[1]),PesqPict("SE1", "E1_CLIENTE"),'.t.',"SA1" ,'.t.', 50, .f.})
	Aadd(FINX001,{1,"Da Loja  "					,Space(TamSx3('E1_LOJA')[1]),PesqPict("SE1", "E1_LOJA"),'.t.',"" ,'.t.', 50, .f.})
	Aadd(FINX001,{1,"Até o Cliente "			,Space(TamSx3('E1_CLIENTE')[1]),PesqPict("SE1", "E1_CLIENTE"),'.t.',"SA1" ,'.t.', 50, .T.})
	Aadd(FINX001,{1,"Até a Loja  "				,Space(TamSx3('E1_LOJA')[1]),PesqPict("SE1", "E1_LOJA"),'.t.',"" ,'.t.', 50, .T.})
	Aadd(FINX001,{2,"Tipo de Relatório  "		,,aCombo,50,"",.F.})	

	If !Parambox(FINX001,"parâmetros",@aret)
		Return .f.
	Endif

Return .t.