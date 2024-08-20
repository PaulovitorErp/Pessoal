#include 'protheus.ch'
#include 'parmtype.ch'

/*
========================================================================================================================
Programa--------------: RCRMA003
Autor-----------------: Erivaldo Oliveira 
Data da Criação-------: 06/04/2020
========================================================================================================================
Descricao-------------: Grafico de etapas das propostas. 
========================================================================================================================						   
Uso-------------------: CRM
========================================================================================================================
Parametros------------: Nenhum
========================================================================================================================
Retorno---------------: Nenhum
========================================================================================================================
*/

User function RCRMA004()
Local _dinicio := firstday(ddatabase)
Local _dfim	   := ctod('')
Local _cfim	   := ''
Local _nmes	   := month(ddatabase)
Local _cmes	   := ""
Local _cdia	   := ""
Local _cano	   := ""
Local _nqtreg  := 0
Private _aqry		
Private _oDlg
Private _oChart,_oChart2,_oChart3,_oChart4,_oChart5,_oChart6,_oChart7,_oChart8,_oChart9,_oChart10,_oChart11,_oChart12
Private _oPanel
Private _oPanel2
Private _nfaz 		:= 0
Private _oAtualiza
Private _XALIAS		:= getnextalias()
Private _ctitulo	:= ""

	_nmes	:= _nmes+1
	
	_cmes	:= cvaltochar(_nmes)
	_cano	:= cvaltochar(year(ddatabase))
	_cdia   := "01"
	
	_cfim	:= _cdia+'/'+_cmes+'/'+_cano
	_dfim	:= ctod(_cfim)

	_ctitulo := "Contratos encerrando entre : "+dtoc(_dinicio)+' e '+dtoc(_dfim)+'.'
	
    DEFINE DIALOG _oDlg TITLE "Contratos" SIZE 800,800 PIXEL

    	_oPanel:= TPanel():New( ,30,,_oDlg,,,,,SETTRANSPARENCE(CLR_LIGHTGRAY,95),800,350,.F.,.F.)

		If _oChart <> NIL
			FreeObj(_oChart)
		Endif       

    	_oChart := FWChartFactory():New()
    	_oChart:SetOwner(_oPanel)
 
    	_oDlg:lMaximized := .T.

    	_oAtualiza   := TTimer():New(20000, { || fAtuGraf()}, _oDlg )
    	_oAtualiza:Activate()
    	
    	fAtuGraf()
    	
    ACTIVATE DIALOG _oDlg CENTERED
    
Return
  
//Atualiza graficos.
Static function fAtuGraf()
Local _nfaz := 0
Local _aresult := {}
Local _dinicio := firstday(ddatabase)
Local _dfim	   := ctod('')
Local _cfim	   := ''
Local _nmes	   := month(ddatabase)
Local _cmes	   := ""
Local _cdia	   := ""
Local _cano	   := ""
Local _nqtreg  := 0
	
	_nmes	:= _nmes+1
	
	_cmes	:= cvaltochar(_nmes)
	_cano	:= cvaltochar(year(ddatabase))
	_cdia   := "01"
	
	_cfim	:= _cdia+'/'+_cmes+'/'+_cano
	_dfim	:= ctod(_cfim)

	beginsql alias _xalias
		select za3_contra, za3_dtfim, count(za3_chplac) as qt
		from %table:za3% za3 
		where za3.%notdel%
		and za3.za3_situac = %exp:'05'% 
		and za3.za3_dtfim between %exp:dtos(_dinicio)% and %exp:dtos(_dfim)% 		
		group by za3_contra, za3_dtfim
		order by za3_dtfim
	endsql
	
	_aqry	:= getlastquery()
	memowrite(gettemppath()+'rcrma003.txt',_aqry[2])
	
	count to _nqtreg
	
	If _nqtreg == 0
		msginfo("Sem contratos com vencimento entre : "+dtoc(_dinicio)+' e '+dtoc(_dfim))
		return
	else
		(_xalias)->(dbgotop())
	Endif
		
	while !(_xalias)->(eof())
	
		aadd(_aresult,{(_xalias)->qt,alltrim((_xalias)->za3_contra),dtoc(stod((_xalias)->za3_dtfim))})
		(_xalias)->(dbskip())
		
	enddo
	
	_aresult := asort(_aresult,,,{ |x,y| x[3] < y[3] })

	(_xalias)->(dbclosearea())

 
   	for _nfaz := 1 to len(_aresult)
   		_oChart:addSerie(_aresult[_nfaz][2]+' - '+_aresult[_nfaz][3],  _aresult[_nfaz][1] )
	next _nfaz
     
	_oChart:setPicture("@E 999,999")
	     
	_oChart:SetLegend(CONTROL_ALIGN_LEFT)
	     
	_oChart:setTitle(_ctitulo, CONTROL_ALIGN_CENTER) //"Oportunidades por fase"
	         
    //CONTROL_ALIGN_RIGHT | CONTROL_ALIGN_LEFT | CONTROL_ALIGN_CENTER
    //----------------------------------------------
    _oChart:SetAlignSerieLabel(CONTROL_ALIGN_RIGHT)
	     
    //Desativa menu que permite troca do tipo de gráfico pelo usuário
    _oChart:EnableMenu(.f.)
	             
    //Define o tipo do gráfico
    _oChart:SetChartDefault(COLUMNCHART)

    _oChart:Activate()
	    
Return