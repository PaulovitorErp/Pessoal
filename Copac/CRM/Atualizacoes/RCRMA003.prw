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

User function RCRMA003()
Local _aqry		
Local _oDlg
Local _oChart
Local oPanel
Local _oPanel2
Local _nfaz 		:= 0
Private _aresult	:= {}
Private _XALIAS		:= getnextalias()

	beginsql alias _xalias
		select AIJ_STAGE, AC2_DESCRI, COUNT(*) AS QT
		from %table:aij% aij left join %table:ac2% ac2 
		on aij.aij_stage = ac2.ac2_stage
		where aij.%notdel%
		and ac2.%notdel%
		and aij.aij_dtinic >= %exp:dtos(ctod(('01/01/2020')))%		
		group by aij_stage,ac2_descri
	endsql
	
	_aqry	:= getlastquery()
	memowrite(gettemppath()+'rcrma003.txt',_aqry[2])
	
	while !(_xalias)->(eof())
	
		aadd(_aresult,{(_xalias)->qt,(_xalias)->ac2_descri})
		(_xalias)->(dbskip())
		
	enddo
	
	_aresult := asort(_aresult,,,{ |x,y| x[1] > y[1] })

	(_xalias)->(dbclosearea())

    DEFINE DIALOG _oDlg TITLE "Posiçao de Etapas" SIZE 800,800 PIXEL
     
    oPanel:= TPanel():New( , ,,_oDlg,,,,,, 0,  50)
    oPanel:Align := CONTROL_ALIGN_TOP
     
    _oPanel2:= TPanel():New( , ,,_oDlg,,,,,, 0,  0)
    _oPanel2:Align := CONTROL_ALIGN_ALLCLIENT
  //  TButton():New( 10, 10, "Refresh",oPanel,{||BtnClick(_oChart)},45,15,,,.F.,.T.,.F.,,.F.,,,.F. )
    _oChart := FWChartFactory():New()
    _oChart:SetOwner(_oPanel2)
     
    for _nfaz := 1 to len(_aresult)
	    //Para graficos de serie unica utilizar conforme abaixo
	    _oChart:addSerie(_aresult[_nfaz][2],  _aresult[_nfaz][1] )
	next _nfaz
     
    //----------------------------------------------
    //Picture
    //----------------------------------------------
    _oChart:setPicture("@E 999,999")
     
    //----------------------------------------------
    //Mascara
    //----------------------------------------------
    //_oChart:setMask("R$ *@*")
     
    //----------------------------------------------
    //Adiciona Legenda
    //opções de alinhamento da legenda:
    //CONTROL_ALIGN_RIGHT | CONTROL_ALIGN_LEFT |
    //CONTROL_ALIGN_TOP | CONTROL_ALIGN_BOTTOM
    //----------------------------------------------
    _oChart:SetLegend(CONTROL_ALIGN_LEFT)
     
    //----------------------------------------------
    //Titulo
    //opções de alinhamento do titulo:
    //CONTROL_ALIGN_RIGHT | CONTROL_ALIGN_LEFT | CONTROL_ALIGN_CENTER
    //----------------------------------------------
    _oChart:setTitle("Lopac / Copac", CONTROL_ALIGN_CENTER) //"Oportunidades por fase"
         
    //----------------------------------------------
    //Opções de alinhamento dos labels(disponível somente no gráfico de funil):
    //CONTROL_ALIGN_RIGHT | CONTROL_ALIGN_LEFT | CONTROL_ALIGN_CENTER
    //----------------------------------------------
    _oChart:SetAlignSerieLabel(CONTROL_ALIGN_RIGHT)
     
    //Desativa menu que permite troca do tipo de gráfico pelo usuário
    _oChart:EnableMenu(.T.)
             
    //Define o tipo do gráfico
    _oChart:SetChartDefault(FUNNELCHART)
    
    //-----------------------------------------
    // Opções disponiveis
    // RADARCHART  
    // FUNNELCHART 
    // COLUMNCHART 
    // NEWPIECHART 
    // NEWLINECHART
    //-----------------------------------------

    _oChart:Activate()
    _oDlg:lMaximized := .T.

    ACTIVATE DIALOG _oDlg CENTERED
    
Return
  
 
Static function BtnClick(_oChart)
Local _nfaz := 0

	_aresult	:= {}
     
    _oChart:DeActivate()
         
	beginsql alias _xalias
		select AIJ_FILIAL, AIJ_STAGE, AC2_DESCRI, COUNT(*) AS QT
		from %table:aij% aij left join %table:ac2% ac2 
		on aij.aij_stage = ac2.ac2_stage
		where aij.aij_filial = %exp:xfilial("aij")%
		and aij.%notdel%
		and ac2.%notdel%
		and aij.aij_dtinic >= %exp:dtos(ctod(('01/01/2020')))%
		group by aij_filial,aij_stage,ac2_descri
		order by  aij_filial,aij_stage
	endsql
	
	_aqry	:= getlastquery()
	memowrite(gettemppath()+'rcrma003.txt',_aqry[2])
	
	while !(_xalias)->(eof())
	
		aadd(_aresult,{(_xalias)->qt,(_xalias)->ac2_descri})
		(_xalias)->(dbskip())
		
	enddo

	(_xalias)->(dbclosearea())

    for _nfaz := 1 to len(_aresult)
	    //Para graficos de serie unica utilizar conforme abaixo
	    _oChart:addSerie(_aresult[_nfaz][2],  _aresult[_nfaz][1] )
	next _nfaz
    
    _oChart:Activate()
     
Return