#include 'protheus.ch'

/*
========================================================================================================================
Programa--------------: RESTX001
Autor-----------------: Erivaldo Oliveira
Data da Criação-------: 06/04/2020
========================================================================================================================
Descrição-------------: Relatório requisiçoes
========================================================================================================================
Uso-------------------: Estoque
========================================================================================================================
Parâmetros------------: De usuário, na entrada da rotina.
========================================================================================================================
Retorno---------------: Nenhum
========================================================================================================================

*/

User function RESTX001()
	Private _oReport
	Private _nqtreg		:= 0
	Private _caliasSCP	:= getnextalias()
	Private _aqry		:= {}
	Private oFont11b
	
	Define Font oFont11b Name "Arial" Size 0,-10 Bold // Arial 11 Negrito

	If !Parametros()
		Return
	Else

		BeginSql Alias _caliasSCP
			Select cp_filial,cp_num, cp_produto,cp_descri,cp_um,cp_segum,cp_quant,b1_uprc,cp_emissao,cp_cc,ctt_desc01
			from %table:scp% scp
			left join %table:sb1% sb1
			on scp.cp_produto = sb1.b1_cod
			left join %table:ctt% ctt
			on scp.cp_cc = ctt.ctt_custo 
			where scp.cp_emissao between %exp:dtos(mv_par01)% and %exp:dtos(mv_par02)%
			and scp.cp_produto between %exp:mv_par03% and %exp:mv_par04%
			and scp.cp_status = %exp:'E'%  
			and scp.%notdel%
			and sb1.%notdel%
			and ctt.%notdel%			
			order by  cp_filial, cp_emissao
		EndSql
	
		_aqry := getlastquery()
		memowrite(gettemppath()+'cmv06r05.txt',_aqry[2])

		count to _nqtreg

		If _nqtreg	== 0
			MsgStop("Sem dados para esses parâmetros.")
			(_caliasSCP)->(DbCloseArea())
			Return
		Else
			(_caliasSCP)->(DbGoTop())
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
	Private _oSection3
	Private _oSection4
	Private _oSection5
	Private _cTitulo	:= "Requisiçoes"

	_oReport := Treport():New("Requisiçoes",_cTitulo,{|_oReport| Parametros() },{|_oReport| PrintReport(_oReport)},"Requisiçoes")
	_oReport:SetLandscape()
	_oReport:oPage:setPaperSize(9)

	//Parametros.
	_oSection1 := Trsection():New(_oReport,"CR",{"qry"},nil , .f., .t.)

	TrCell():New(_oSection1,"C1","QRY","Filial","@!",15)							
	TrCell():New(_oSection1,"C2","QRY","Numero","@!",15)							
	TrCell():New(_oSection1,"C3","QRY","Produto","@!",15)							
	TrCell():New(_oSection1,"C4","QRY","Descriçao","@!",15)							
	TrCell():New(_oSection1,"C5","QRY","Unidade medida","@!",15)							
	TrCell():New(_oSection1,"C6","QRY","Segunda Unidade","@!",15)							
	TrCell():New(_oSection1,"C7","QRY","Quantidade","@!",15)							
	TrCell():New(_oSection1,"C8","QRY","Ultime preço compra","@!",50)							
	TrCell():New(_oSection1,"C9","QRY","Emissao","@!",15)							
	TrCell():New(_oSection1,"C10","QRY","Centro de Custo","@!",15)							
	TrCell():New(_oSection1,"C11","QRY","Descriçao CC","@!",15)							

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
	TrCell():New(_oSection2,"C11","QRY","","@!",15)							

	_oReport:nFontBody := 9
	_oReport:CFONTBODY:="Courier New"
	_oReport:lParamPage := .T.
	_oReport:GetOrientation(2) //2 - Paisagem

Return _oReport

//Impressão
Static Function PrintReport(_oReport)
	Local _oSection1 	:= _oReport:section(1)		//Seção 1.
	Local _oSection2 	:= _oReport:section(2)		//Seção 1.
	Local _ntotquant	:= 0

	_oReport:SetMeter(_nQtReg)

	_oSection1:Init()

	(_caliasSCP)->(dbgotop())
	
	While !(_caliasSCP)->(Eof())
	
		If _oReport:row()	> 2700
			_oReport:EndPage()
			_oReport:StartPage()
		Endif

		_oReport:IncMeter()

		If _oReport:Cancel()
			Exit
		Endif

		_oSection1:Cell("C1"):SetValue((_caliasSCP)->cp_filial)
		_oSection1:Cell("C2"):SetValue((_caliasSCP)->cp_num)
		_oSection1:Cell("C3"):SetValue((_caliasSCP)->cp_produto)
		_oSection1:Cell("C4"):SetValue((_caliasSCP)->cp_descri)
		_oSection1:Cell("C5"):SetValue((_caliasSCP)->cp_um)
		_oSection1:Cell("C6"):SetValue((_caliasSCP)->cp_segum)
		_oSection1:Cell("C7"):SetValue(transform((_caliasSCP)->cp_quant,PesqPict('SCP','CP_QUANT')))
		_oSection1:Cell("C8"):SetValue(transform((_caliasSCP)->b1_uprc,PesqPict('SB1','B1_UPRC')))
		_oSection1:Cell("C9"):SetValue(dtoc(stod((_caliasSCP)->cp_emissao)))
		_oSection1:Cell("C10"):SetValue((_caliasSCP)->cp_cc)
		_oSection1:Cell("C11"):SetValue((_caliasSCP)->ctt_desc01)

		_oSection1:PrintLine()

		_ntotquant += (_caliasSCP)->cp_quant

		(_caliasSCP)->(DBSKIP())

	enddo
	
	_oSection2:Init()

	_oSection2:Cell("C1"):SetValue()
	_oSection2:Cell("C2"):SetValue()
	_oSection2:Cell("C3"):SetValue()
	_oSection2:Cell("C4"):SetValue()
	_oSection2:Cell("C5"):SetValue()
	_oSection2:Cell("C6"):SetValue("Totais :")
	_oSection2:Cell("C7"):SetValue(transform(_ntotquant,PesqPict('SCP','CP_QUANT')))
	_oSection2:Cell("C8"):SetValue()
	_oSection2:Cell("C9"):SetValue()
	_oSection2:Cell("C10"):SetValue()
	_oSection2:Cell("C11"):SetValue()

	_oSection2:PrintLine()
	

	If _oReport:row()	> 2600
		_oReport:EndPage()
		_oReport:StartPage()
	Endif

	(_caliasSCP)->(DbCloseArea())

Return

//Parâmetros do Relatório
Static Function Parametros()
	Local FINX001 := {}
	Local aret   := {}

	Aadd(FINX001,{1,"Da emissão  "				,dDatabase,PesqPict("SE1", "E1_EMISSAO"),'.t.',"" ,'.t.', 50, .t.})
	Aadd(FINX001,{1,"Até a emissão  "			,dDatabase,PesqPict("SE1", "E1_EMISSAO"),'.t.',"" ,'.t.', 50, .t.})
	Aadd(FINX001,{1,"Do Produto "				,SPACE(TAMSX3('B1_COD')[1]),PESQPICT("SB1", "B1_COD"),"","SB1","",80,.F.})												
	Aadd(FINX001,{1,"Até o Produto"				,repl('Z',TAMSX3('B1_COD')[1]),PESQPICT("SB1", "B1_COD"),"","SB1","",80,.T.})

	If !Parambox(FINX001,"parâmetros",@aret)
		Return .f.
	Endif

Return .t.