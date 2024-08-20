#include 'protheus.ch'

/*
========================================================================================================================
Programa--------------: RFINX001
Autor-----------------: Erivaldo Oliveira
Data da Cria��o-------: 02/04/2020
========================================================================================================================
Descri��o-------------: Relat�rio de contas a receber (Inadimpl�ncia)
========================================================================================================================
Uso-------------------: Financeiro
========================================================================================================================
Par�metros------------: De usu�rio, na entrada da rotina.
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

		BeginSql Alias _caliasSE1
			Select *
			from %table:SE1% se1
			left join %table:SA1% sa1
			on se1.e1_cliente = sa1.a1_cod and se1.e1_loja = sa1.a1_loja
			where se1.e1_emissao between %exp:dtos(mv_par01)% and %exp:dtos(mv_par02)%
			and se1.e1_vencrea between %exp:dtos(mv_par03)% and %exp:dtos(mv_par04)%
			se1.e1_cliente between %exp:mv_par05% and %exp:mv_par07%
			and se1.e1_loja between %exp:mv_par06% and %exp:mv_par08%
			and se1.e1_saldo > %exp:0%
			and se1.%notdel%
			and sa1.%notdel%
			order by  e1_vencrea, a1_nome
		EndSql
	
		_aqry := getlastquery()
		memowrite(gettemppath()+'cmv06r05.txt',_aqry[2])

		count to _nqtreg

		If _nqtreg	== 0
			MsgStop("Sem dados para esses par�metros.")
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
	Private _oSection3
	Private _oSection4
	Private _oSection5
	Private _cTitulo	:= "Contas a Receber - Inadimpl�ncia"

	_oReport := Treport():New("Contas a Receber - Inadimpl�ncia",_cTitulo,{|_oReport| Parametros() },{|_oReport| PrintReport(_oReport)},"Contas a Receber - Inadimpl�ncia")
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
	TrCell():New(_oSection1,"C13","QRY","Dias Atraso","@!",15)
	TrCell():New(_oSection1,"C14","QRY","PCLD","@!",15)

	_oReport:nFontBody := 9
	_oReport:CFONTBODY:="Courier New"
	_oReport:lParamPage := .T.
	_oReport:GetOrientation(2) //2 - Paisagem

Return _oReport

//Impress�o
Static Function PrintReport(_oReport)
	Local _oSection1 	:= _oReport:section(1)		//Se��o 1.

	_oReport:SetMeter(_nQtReg)

	_oSection1:Init()

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
		
		do case
			case ((_cAliasSE1)->e1_saldo <= 1500 .and. ndias > 180)
				cpcld	:= "PDLD-A"
			case ((_cAliasSE1)->e1_saldo > 1500 .and. (_cAliasSE1)->e1_saldo < 100000 .and. ndias >= 365)
				cpcld	:= "PDLD-B"
			case ((_cAliasSE1)->e1_saldo > 100000 .and. ndias > 365)
				cpcld	:= "PDLD-C"
			otherwise
				cpcld	:= "NAO SE APLICA"
		endcase
		
		_oSection1:Cell("C1"):SetValue((_cAliasSE1)->e1_filial)
		_oSection1:Cell("C2"):SetValue((_cAliasSE1)->e1_prefixo)
		_oSection1:Cell("C3"):SetValue((_cAliasSE1)->e1_numero)
		_oSection1:Cell("C4"):SetValue((_cAliasSE1)->e1_parcela)
		_oSection1:Cell("C5"):SetValue((_cAliasSE1)->e1_tipo)
		_oSection1:Cell("C6"):SetValue((_cAliasSE1)->e1_cliente)
		_oSection1:Cell("C7"):SetValue((_cAliasSE1)->e1_loja)
		_oSection1:Cell("C8"):SetValue(cNomeCli)
		_oSection1:Cell("C9"):SetValue(dtoc(stod((_cAliasSE1)->e1_emissao)))
		_oSection1:Cell("C10"):SetValue(dtoc(stod((_cAliasSE1)->e1_vencrea)))
		_oSection1:Cell("C11"):SetValue(transform((_cAliasSE1)->e1_valor,PesqPict('SE1','E1_VALOR')))
		_oSection1:Cell("C12"):SetValue(transform((_cAliasSE1)->e1_saldo,PesqPict('SE1','E1_SALDO')))
		_oSection1:Cell("C13"):SetValue(transform(ndias,"@E 999.999"))
		_oSection1:Cell("C14"):SetValue(cpcld)

		_oSection1:PrintLine()

		(_cAliasSE1)->(DBSKIP())

	enddo
		
	If _oReport:row()	> 2600
		_oReport:EndPage()
		_oReport:StartPage()
	Endif

	(_cAliasSE1)->(DbCloseArea())

Return

//Par�metros do Relat�rio
Static Function Parametros()
	Local cmvr05 := {}
	Local aret   := {}
	Local aCombo := {"Cooperado","Terceiro","Todos"}

	Aadd(cmvr05,{1,"Da emiss�o  "				,dDatabase,PesqPict("SE1", "E1_EMISSAO"),'.t.',"" ,'.t.', 50, .t.})
	Aadd(cmvr05,{1,"At� a emiss�o  "			,dDatabase,PesqPict("SE1", "E1_EMISSAO"),'.t.',"" ,'.t.', 50, .t.})
	Aadd(cmvr05,{1,"Do vencimento "				,dDatabase,PesqPict("SE1", "E1_VENCREA"),'.t.',"" ,'.t.', 50, .t.})
	Aadd(cmvr05,{1,"At� o vencimento "			,dDatabase,PesqPict("SE1", "E1_VENCREA"),'.t.',"" ,'.t.', 50, .t.})
	Aadd(cmvr05,{1,"Do Cliente "				,Space(TamSx3('E1_CLIENTE')[1]),PesqPict("SE1", "E1_CLIENTE"),'.t.',"SA1" ,'.t.', 50, .f.})
	Aadd(cmvr05,{1,"Da Loja  "					,Space(TamSx3('E1_LOJA')[1]),PesqPict("SE1", "E1_LOJA"),'.t.',"" ,'.t.', 50, .f.})
	Aadd(cmvr05,{1,"At� o Cliente "				,Space(TamSx3('E1_CLIENTE')[1]),PesqPict("SE1", "E1_CLIENTE"),'.t.',"SA1" ,'.t.', 50, .T.})
	Aadd(cmvr05,{1,"At� a Loja  "				,Space(TamSx3('E1_LOJA')[1]),PesqPict("SE1", "E1_LOJA"),'.t.',"" ,'.t.', 50, .T.})

	If !Parambox(cmvr05,"par�metros",@aret)
		Return .f.
	Endif

Return .t.

//Parametros
Static Function fCabec()
	
	Local _oSection1 	:= _oReport:section(1)		//Se��o 1.
	Local _oSection2 	:= _oReport:section(2)		//Se��o 2.
	Local cParam1		:= "Filiais : "+ strtran(strtran(strtran(strtran(strtran(mv_par01,"  ','","/"),"  ')"," "),"('"," "),"','","/"),"')"," ")	//Par�metros, linha 1.
	//Local cParam1		:= "Filiais : "+ mv_par01																//Par�metros, linha 1.
	Local cParam2		:= "Cooperado/Loja de  : "+mv_par02+"/"+mv_par03+" at� "+mv_par04+"/"+mv_par05  		//Par�metros, linha 2.
	Local cParam3		:= "Emiss�o de : "+dtoc(mv_par06)+" at� "+dtoc(mv_par07)								//Par�metros, linha 3.
	Local cParam4		:= "Vencimento de : "+dtoc(mv_par08)+" at� "+dtoc(mv_par09)								//Par�metros, linha 4.
	Local cParam5		:= "Data base p/ Calc. Juros : "+dtoc(mv_par10)											//Par�metros, linha 5.
	Local cParam6		:= "N�o Listar Tipos: "+mv_par11														//Par�metros, linha 6.
	Local cParam7		:= "Tipo de Cliente: "+mv_par12														    //Par�metros, linha 7.
	Local cParam8		:= "Usu�rio : ("+ RetCodUsr() +")"+ UsrFullName(RetCodUsr())							//Par�metros, linha 8.

	//Imprime par�metros
	_oSection1:Init()
	_oSection1:Cell("C1"):SetValue(cParam1)
	_oSection1:PrintLine()
	_oSection1:Cell("C1"):SetValue(cParam2)
	_oSection1:PrintLine()
	_oSection1:Cell("C1"):SetValue(cParam3)
	_oSection1:PrintLine()
	_oSection1:Cell("C1"):SetValue(cParam4)
	_oSection1:PrintLine()
	_oSection1:Cell("C1"):SetValue(cParam5)
	_oSection1:PrintLine()
	_oSection1:Cell("C1"):SetValue(cParam6)
	_oSection1:PrintLine()
	_oSection1:Cell("C1"):SetValue(cParam7)
	_oSection1:PrintLine()
	_oSection1:Cell("C1"):SetValue(cParam8)
	_oSection1:PrintLine()

	_oSection1:Cell("C1"):SetValue()
	_oSection1:PrintLine()

	_oSection1:Finish()

	//Cabe�alho das colunas
	_oSection2:Init()
	_oSection2:Cell("C1"):SetValue("Documento")
	_oSection2:Cell("C2"):SetValue("Emiss�o")
	_oSection2:Cell("C3"):SetValue("Vencimento")
	_oSection2:Cell("C4"):SetValue("Vlr. do T�tulo")
	_oSection2:Cell("C5"):SetValue("Vlr. em aberto")
	_oSection2:Cell("C6"):SetValue("Corre��o")
	_oSection2:Cell("C7"):SetValue("Juros")
	_oSection2:Cell("C8"):SetValue("Multa")
	_oSection2:Cell("C9"):SetValue("Descontos")
	_oSection2:Cell("C10"):SetValue("Total")
	_oSection2:Cell("C11"):SetValue("Filial")

	_oSection2:PrintLine()

	_oSection2:Finish()

return

//	//Personaliza o rodap�
//	 
//_oReport:SetPageFooter(20, {|| Rodape(_oReport, cUser)})
//	
//Static Function Rodape(oReport, cUser)
//	Local cNome     := ""
//	Local cTel      := Space(10)
//	Local cFax      := ""
//	Local cEMail    := ""
//
//    oReport:ThinLine()
//    oReport:PrintText(PADC("I M P O R T A N T E!!!", 93, "*") + padc("",2,"") + PADC("A T E N C A O!!!", 79, "*"))
//    oReport:PrintText(PadR("*� obrigat�rio constar o n�mero da ordem de compra no corpo da nota fiscal.                 *",95) + "*N�o ser�o aceitos boletos negociados com terceiros. (Fomento mercantil)      *")
//    
//    oReport:ThinLine()
//Return Nil 

//Consulta espec�fica - Filiais
User Function MCMVR05()
Local _MvPar
Local _MvRet
Local _MvParDef := ""
Local _aItens   := array(0)
Local _cAux	  := ""
Local _cAux2	  := ""
Local _aArea    := GetArea()

_MvPar := &(Alltrim(ReadVar()))       
_MvRet := Alltrim(ReadVar())          

dbSelectArea('SM0')
dbSetOrder(1)
SM0->(dbGotop())
While SM0->(!Eof())
	aAdd(_aItens,substr(SM0->M0_CODFIL,1,6)+' - '+Alltrim(SM0->M0_FILIAL))
	_MvParDef += substr(SM0->M0_CODFIL,1,6)+','
	SM0->(Dbskip())
EndDo

IF f_Opcoes(@_MvPar, "Selecione a(s) filiais(s).", _aItens, _MvParDef,,,.f.,7,40,,,,,,,' ')
	
	_cAux2 := ''
	For nX := 1 To Len(_MvPar)
		_cAux := Substr(_MvPar,nX,1)
		If '*' <> _cAux
			if ',' == _cAux
				_cAux2 += "'"+_cAux+"'"
			else
				_cAux2 += _cAux
			endif
		EndIf
	Next nX

	_cAux2 := substr(_cAux2,1,len(_cAux2)-2)
	
	If !empty(_cAux2)
		_cAux2 := "('"+_cAux2+")"
		_MvPar := _cAux2
	Else
		_MvPar := ""
	Endif

	&_MvRet := _MvPar
	                                      
EndIF

RestArea(_aArea)                                  
Return .t.
