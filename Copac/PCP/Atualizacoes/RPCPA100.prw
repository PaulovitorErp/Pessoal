#include "TOTVS.CH"

/*
==============================================================================================================================
Programa--------------: RPCPA100
Autor-----------------: Erivaldo Oliveira 
Data da Criação-------: 02/03/2020
==============================================================================================================================
Descriçao-------------: Painel de acompanhamento de produção.
==============================================================================================================================				   
Uso-------------------: PCP Copac.
==============================================================================================================================
Parâmetros------------: Nenhum
==============================================================================================================================
Retorno---------------: Nenhum
==============================================================================================================================
*/

User Function RPCPA100()
	
	Local _aScreens 	:= getScreenRes()		//Resolução da tela		
	Local _clinok		:= "allwaystrue"
	Local _ctudook   	:= "allwaystrue"
	Local _cinicpos 	:= "" 
	Local _nfreezep  	:= 000
	Local _nfreeze  	:= 000
	Local _nmax      	:= 999
	Local _cfieldok  	:= "allwaystrue"
	Local _csuperdel 	:= ""
	Local _cdelok    	:= "allwaystrue"
	Local _aalter		:= {}
	Private _aCposFro 	:= {'','Novo/Usado','Placa','Chassi','AR','Ano','Modelo','Mod. Cx.',;
						   'Número','Id. Cx.','DI','Entre Eixos','Mecânica','Reforma','Encarroçamento',;
						   'Hidráulica','Pintura','Elétrica','Qualidade','Observação','Reserv./Dispon.',;
						   'Cliente','Data Pedido','Primeira Alteração','Data da Saí­da','Horário Saí­da','Contrato',;
						   'Vendedor','Avalia Reforma','OK','Restrição'}  //Campos do grid Frota Local

	Private _aOrdFro 	:= {'','1-Novo/Usado','2-Placa','3-Chassi','4-AR','5-Ano','6-Modelo','7-Mod. Cx.',;
						   '8-Número','9-Id. Cx.','10-DI','11-Entre Eixos','12-Mecânica','13-Reforma','14-Encarroçamento',;
						   '15-Hidráulica','16-Pintura','17-Elétrica','18-Qualidade','19-Observação','20-Reserv./Dispon.',;
						   '21-Cliente','22-Data Pedido','23-Primeira Alteração','24-Data da Saí­da','25-Horário Saí­da','26-Contrato',;
						   '27-Vendedor','28-Avalia Reforma','29-OK','30-Restrição'}  //Campos para ordenar o grid Frota Local

	Private _aCpos1920 	:= {'','Id Veículo','Placa','Chassi','Ano Modelo','Data Entrada','Iní­cio Produção','Dias Fila',;
						   'Entrega/Qualidade','Dias','Dias em Produção','Média'}  //Campos do grid Frota 1920

	Private _aOrd1920 	:= {'','1-Id Veículo','2-Placa','3-Chassi','4-Ano Modelo','5-Data Entrada','6-Iní­cio Produção','7-Dias Fila',;
						   '8-Entrega/Qualidade','9-Dias','10-Dias em Produção','11-Média'}  //Campos para ordenar o grid Frota 1920

	Private _aCposCx 	:= {'','Tipo','Número','Ano Modelo','Fabricante','Modelo','Capacidade','DI',;
						   'Pintura','Reforma','Hidráulica','Acoplado'}  //Campos do grid Caixa

	Private _aOrdCx 	:= {'','1-Tipo','2-Número','3-Ano Modelo','4-Fabricante','5-Modelo','6-Capacidade','7-DI',;
						   '8-Pintura','9-Reforma','10-Hidráulica','11-Acoplado'}  //Campos para ordem do grid Caixa
	
	Private _ccbox		:= ""					//Item selecionado no combobox 
	Private _ccboxVei	:= ""					//Item selecionado no combobox
	Private _ccboxCx	:= ""					//Item selecionado no combobox
	Private _ccboxordf	:= ""					//Box ordenacao frota local
	Private _ccbovei	:= ""					//Box ordenacao frota local 1920
	Private _ccbocx		:= ""					//Box ordenacao caixas.
	Private _aHeadFro	:= {}					//Cabeçalho Frota local
	Private _aColsFro	:= {}					//Itens Frota local 
	Private _aCFroBkp	:= {}					//backup Itens Frota local
	Private _aHeadVei	:= {}					//Cabeçalho Veículos
	Private _aColsVei	:= {}					//Itens Veículos
	Private _aCVeiBkp	:= {}					//backup Itens Frota local
	Private _aHeadCx	:= {}					//Cabeçalho Compactador
	Private _aColsCx	:= {}					//Itens Compactador
	Private _aCCxBkp	:= {}					//backup Itens Compactador
	Private _aHeadCon	:= {}					//Cabeçalho Conjunto
	Private _aColsCon	:= {}					//Itens Conjunto
	Private _aTFolder	:= {}					//Abas
	Private _aFilFro	:= {}					//Filtros aba Frota Local
	Private _aCFilFro	:= {}					//Campos aba Frota Local
	Private _cSayFRo,_cSayVei,_cSayCx,nLinFim, nColFim
	
	Private _oDlg, _oTFolder, _ogetFro, _ogetVei, _ogetcx, _ocbox, _ocboxvei, ;
			_ocboxcx, _ocboxordf,_oboxvei, _oboxcx, _omark,_omarkvei,_omarkcx , ;
			_obutcvei,_obutdvei, _obutccx,_obutdcx,_ogrpcx, _osayqfro, _osayqvei,;
			_osayqcx,_oBtnFilFro
	
	Processa( {|| fFrotaLocal()		}, "Processando dados : frota local.", "Frota Local",.F.)
	Processa( {|| fVeiculos()  		}, "Processando dados : frota 1920.", "Frota 1920",.F.)
	Processa( {|| fCaixas()			}, "Processando dados : caixas.", "Caixa",.F.)
 

	If _aScreens[1]	== 1280
		nLinFim := _aScreens[1]-980
		nColFim	:= _aScreens[2]-165
	Else
		nLinFim := _aScreens[1]-1085
		nColFim	:= _aScreens[2]-90
	Endif
 
 
	DEFINE DIALOG _oDlg TITLE "Acompanhamento PCP" FROM 000,050 TO 400,450 PIXEL
	
		// Frota Local
		_aTFolder := { 'Frota Local','Frota 1920', 'Caixas'}
		_oTFolder := TFolder():New( 0,0,_aTFolder,,_oDlg,,,,.T.,,_aScreens[1],_aScreens[2] )
	
		@ 09,02 SAY "Filtro: " SIZE 15,8 PIXEL OF _oTFolder:aDialogs[1]
		@ 04,20 combobox _ocbox var _ccbox items _aCposFro size 65,50 of _oTFolder:aDialogs[1] pixel ;
				on change ffilfrota(_ccbox)
	
		_oBtnFilFro := tButton():New(04,87,"Limpa filtro" ,_oTFolder:aDialogs[1],{|| fLimFFro()},32,015,,,,.T.)
		_oBtnFilFro:disable()

		@ 09,130 SAY "Ordem : " SIZE 20,8 PIXEL OF _oTFolder:aDialogs[1]
		@ 04,153 combobox _ocboxordf var _ccboxordf items _aOrdFro size 65,50 of _oTFolder:aDialogs[1] pixel ;

		_oButcvei := TButton():New(04,225,'      Crescente',_oTFolder:aDialogs[1],{|| fordfrota(_ccboxordf,1)},41,17,,,.F.,.T.,.F.,,.F.,,,.F. )
		_oButcvei:SetCss("QPushButton{ background-image: url(rpo:officebtnsectionopenhover.png);"+;                            
		"background-repeat: none; margin: 5px }")

		_oButdvei := TButton():New(04,265,'       Decrescente',_oTFolder:aDialogs[1],{|| fordfrota(_ccboxordf,2)},44,17,,,.F.,.T.,.F.,,.F.,,,.F. )
		_oButdvei:SetCss("QPushButton{ background-image: url(rpo:officebtnsectionclosehover.png);"+;                            
		"background-repeat: none; margin: 5px }")

		_osayqfro := TSay():New( 09, 313, {||"Quantidade : "+cvaltochar(len(_AcolsFro))},_oTFolder:aDialogs[1],,;
		,.F., .F., .F., .T.,,, 45, 8, .F., .F., .F., .F., .F. )

		_ogetFro := msnewgetdados():new(22,00,nLinFim,nColFim,GD_UPDATE,_clinok,_ctudook,_cinicpos,_aalter,_nfreezep,_nmax,_cfieldok,_csuperdel,_cdelok,_oTFolder:aDialogs[1],_aHeadFro,_AcolsFro)
		_ogetFro:SetEditLine(.f.) 

		//Frota 1920
		@ 09,02 SAY "Filtro: " SIZE 15,8 PIXEL OF _oTFolder:aDialogs[2]
		@ 04,20 combobox _ocboxVei var _ccboxVei items _aCpos1920 size 65,50 of _oTFolder:aDialogs[2] pixel ;
				on change ffilVei(_ccboxVei)
	
		_oBtnFilVei := tButton():New(04,87,"Limpa filtro" ,_oTFolder:aDialogs[2],{|| fLimFVei()},32,015,,,,.T.)
		_oBtnFilVei:disable()

		@ 09,130 SAY "Ordem : " SIZE 20,8 PIXEL OF _oTFolder:aDialogs[2]
		@ 04,153 combobox _oboxvei var _ccbovei items _aOrd1920 size 65,50 of _oTFolder:aDialogs[2] pixel 

		_oButcvei := TButton():New(04,225,'      Crescente',_oTFolder:aDialogs[2],{|| ford1920(_ccbovei,1)},41,17,,,.F.,.T.,.F.,,.F.,,,.F. )
		_oButcvei:SetCss("QPushButton{ background-image: url(rpo:officebtnsectionopenhover.png);"+;                            
		"background-repeat: none; margin: 5px }")

		_oButdvei := TButton():New(04,265,'       Decrescente',_oTFolder:aDialogs[2],{|| ford1920(_ccbovei,2)},44,17,,,.F.,.T.,.F.,,.F.,,,.F. )
		_oButdvei:SetCss("QPushButton{ background-image: url(rpo:officebtnsectionclosehover.png);"+;                            
		"background-repeat: none; margin: 5px }")

		oBtnGrafVei := TButton():New(004,310,'        Gráfico',_oTFolder:aDialogs[2],{|| msginfo("Em desenvolvimento")},41,17,,,.F.,.T.,.F.,,.F.,,,.F. )
		oBtnGrafVei:SetCss("QPushButton{ background-image: url(rpo:graf3d.png);"+;                            
		"background-repeat: none; margin: 5px }")

		_osayqvei := TSay():New( 09, 355, {||"Quantidade : "+cvaltochar(len(_AcolsVei))},_oTFolder:aDialogs[2],,;
		,.F., .F., .F., .T.,,, 45, 8, .F., .F., .F., .F., .F. )

		_ogetVei := msnewgetdados():new(22,00,nLinFim,nColFim,GD_UPDATE,_clinok,_ctudook,_cinicpos,_aalter,_nfreezep,_nmax,_cfieldok,_csuperdel,_cdelok,_oTFolder:aDialogs[2],_aHeadVei,_AcolsVei)

		//Caixa
		@ 09,02 SAY "Filtro: " SIZE 15,8 PIXEL OF _oTFolder:aDialogs[3]
		@ 04,20 combobox _ocboxCx var _ccboxCx items _aCposCX size 65,50 of _oTFolder:aDialogs[3] pixel ;
				on change ffilCx(_ccboxCx)
		
		_oBtnFilCx := tButton():New(04,87,"Limpa filtro" ,_oTFolder:aDialogs[3],{|| fLimFCx()},32,015,,,,.T.)
		_oBtnFilCx:disable()

		@ 09,130 SAY "Ordem : " SIZE 20,8 PIXEL OF _oTFolder:aDialogs[3]
		@ 04,153 combobox _oboxcx var _ccbocx items _aOrdcx size 65,50 of _oTFolder:aDialogs[3]  pixel 

		_oButccx := TButton():New(04,225,'      Crescente',_oTFolder:aDialogs[3],{|| fordcx(_ccbocx,1)},41,17,,,.F.,.T.,.F.,,.F.,,,.F. )
		_oButccx:SetCss("QPushButton{ background-image: url(rpo:officebtnsectionopenhover.png);"+;                            
		"background-repeat: none; margin: 5px }")

		_oButdcx := TButton():New(04,265,'       Decrescente',_oTFolder:aDialogs[3],{|| fordcx(_ccbocx,2)},44,17,,,.F.,.T.,.F.,,.F.,,,.F. )
		_oButdcx:SetCss("QPushButton{ background-image: url(rpo:officebtnsectionclosehover.png);"+;                            
		"background-repeat: none; margin: 5px }")

		oBtnGrafCx := TButton():New(004,310,'        Gráfico',_oTFolder:aDialogs[3],{|| msginfo("Em Desenvolvimento")},41,17,,,.F.,.T.,.F.,,.F.,,,.F. )
		oBtnGrafCx:SetCss("QPushButton{ background-image: url(rpo:graf3d.png);"+;                            
		"background-repeat: none; margin: 5px }")

		_osayqcx := TSay():New( 09, 355, {||"Quantidade : "+cvaltochar(len(_AcolsCx))},_oTFolder:aDialogs[3],,;
		,.F., .F., .F., .T.,,, 45, 8, .F., .F., .F., .F., .F. )

		_ogetCx := msnewgetdados():new(22,00,nLinFim,nColFim,GD_UPDATE,_clinok,_ctudook,_cinicpos,_aalter,_nfreezep,_nmax,_cfieldok,_csuperdel,_cdelok,_oTFolder:aDialogs[3],_aHeadCx,_AcolsCx)

		_oDlg:lescclose := .t.
		_oDlg:lMaximized := .T.
	 
	ACTIVATE DIALOG _oDlg CENTERED
  
Return

//Frota Local 
Static Function fFrotaLocal()
Local _xalias		:= GetNextAlias()
Local _xalias2		:= GetNextAlias()
Local _nreg			:= 0
Local _aqry			:= {}
Local _cdescmodeloCx:= ""
Local _ctpcx		:= ""
Local _cdesctip		:= ""
Local _nok			:= 0
Local _okfalEnt		:= ""
Local _okfalMec		:= ""
Local _okfalRef		:= ""
Local _okfalEnc		:= ""
Local _okfalHid		:= ""
Local _okfalPin		:= ""
Local _okfalEle		:= ""
Local _okfalQua		:= ""
Local _npos			:= 0
Local _car 			:= ""
Local _cdi 			:= ""
Local _crestricao   := ""
Local _ccodvei		:= ""
Local _creserva		:= "Disponível"
Local _ccliente		:= ""
Local _ddataped		:= ctod('')
Local _cprialt		:= ""
Local _ddatasai		:= ctod('')
Local _chorsai		:= ""
Local _cvendedor	:= ""
Local _aqry         := {}

Local _nconta	:= 0
				   
aadd(_aHeadFro,{ "Novo/Usado","Novo/Usado","",20,0,"","C","C",,,,""}) 
aadd(_aHeadFro,{ "Placa","Placa","",20,0,"","C","C",,,,""})
aadd(_aHeadFro,{ "Chassi","Chassi","",20,0,"","C","C",,,,""})
aadd(_aHeadFro,{ "AR","AR","",20,0,"","C","C",,,,""})
aadd(_aHeadFro,{ "Ano","Ano","",20,0,"","C","C",,,,""})
aadd(_aHeadFro,{ "Modelo","Modelo","",20,0,"","C","C",,,,""})
aadd(_aHeadFro,{ "Mod. Cx.","Mod. Cx.","",20,0,"","C","C",,,,""})
aadd(_aHeadFro,{ "Número","Número","",20,0,"","C","C",,,,""})
aadd(_aHeadFro,{ "Id. Cx.","Id. Cx.","",20,0,"","C","C",,,,""})
aadd(_aHeadFro,{ "DI","DI","",20,0,"","C","C",,,,""})
aadd(_aHeadFro,{ "Entre Eixos","Entre Eixos","",20,0,"","C","C",,,,""})
aadd(_aHeadFro,{ "Mecânica","Mecânica","",20,0,"","C","C",,,,""})
aadd(_aHeadFro,{ "Reforma","Reforma","",20,0,"","C","C",,,,""})
aadd(_aHeadFro,{ "Encarroçamento","Encarroçamento","",20,0,"","C","C",,,,""})
aadd(_aHeadFro,{ "Hidráulica","Hidráulica","",20,0,"","C","C",,,,""})
aadd(_aHeadFro,{ "Pintura","Pintura","",20,0,"","C","C",,,,""})
aadd(_aHeadFro,{ "Elétrica","Elétrica","",20,0,"","C","C",,,,""})
aadd(_aHeadFro,{ "Qualidade","Qualidade","",20,0,"","C","C",,,,""})
aadd(_aHeadFro,{ "Observação","Observação","",20,0,"","C","C",,,,""})
aadd(_aHeadFro,{ "Reserv./Dispon.","Reserv./Dispon.","",20,0,"","C","C",,,,""})
aadd(_aHeadFro,{ "Cliente","Cliente","",20,0,"","C","C",,,,""})
aadd(_aHeadFro,{ "Data Pedido","Data Pedido","",8,0,"","D","C",,,,""})
aadd(_aHeadFro,{ "Primeira Alteração","Primeira Alteração","",20,0,"","C","C",,,,""})
aadd(_aHeadFro,{ "Data da Saí­da","Data da Saí­da","",8,0,"","D","C",,,,""})
aadd(_aHeadFro,{ "Horário Saída","Horário Saída","",20,0,"","C","C",,,,""})
aadd(_aHeadFro,{ "Contrato","Contrato","",20,0,"","C","C",,,,""})
aadd(_aHeadFro,{ "Vendedor","Vendedor","",20,0,"","C","C",,,,""})
aadd(_aHeadFro,{ "Avalia Reforma","Avalia Reforma","",20,0,"","C","C",,,,""})
aadd(_aHeadFro,{ "OK","OK","",20,0,"","N","C",,,,""})
aadd(_aHeadFro,{ "Restrição","Restrição","",20,0,"","C","C",,,,""})

//Veiculos que nao estao vinculados a um contrato ativo.
Beginsql alias _xalias
	select *
	from %table:da3% da3
	where da3.da3_filial = %exp:xfilial('DA3')% and
	da3.da3_placa not in (select za3_chplac 
						  from %table:za3% za3 
						  		left join %table:cn9% cn9 on za3.za3_contra = cn9.cn9_numero
						  where cn9.cn9_situac = %exp:'05'% and 
						  		za3.%notdel% and
						  		cn9.%notdel%) and
	da3.%notdel%
Endsql

_aqry	:= getlastquery()
memowrite(gettemppath()+'rpcpa100.txt',_aqry[2])

count to _nreg
procregua(_nreg)

(_xalias)->(dbgotop()) 

while !(_xalias)->(eof())
	
	_nconta++
	
	incproc("Aguarde...")

	beginsql alias _xalias2
		select za3_cxdesm,za3_cxid
		from %table:za3% za3
		where za3.za3_filial = %exp:xfilial('ZA3')% and
		za3.za3_chplac	= %exp:(_xalias)->da3_placa% and
		za3.%notdel%
	endsql

	_aqry	:= getlastquery()
	memowrite(gettemppath()+'pcpa100cx.txt',_aqry[2])
	
	_cdescmodeloCx	:= (_xalias2)->za3_cxdesm
	_ccxid := (_xalias2)->za3_cxid	

	(_xalias2)->(dbclosearea())
	
	beginsql alias _xalias2
		select xcx_novo, xcx_di
		from %table:xcx% xcx
		where xcx.xcx_codid	= %exp:_ccxid% and
		xcx.%notdel%
	endsql
	
	_aqry	:= getlastquery()
	memowrite(gettemppath()+'pcpa-xcx.txt',_aqry[2])
	
	_ctpcx := X3CBoxDesc("XCX_NOVO",(_xalias2)->xcx_novo)

	_cdi := X3CBoxDesc("XCX_DI",(_xalias2)->xcx_di)


	(_xalias2)->(dbclosearea())

	Beginsql alias _xalias2
		select cn1_descri
		from %table:cn1% cn1 
			left join %table:cn9% cn9 on cn1.cn1_codigo = cn9.cn9_tpcto
			left join %table:za3% za3 on cn9.cn9_numero = za3.za3_contra
		where za3.za3_chplac = %exp:(_xalias)->da3_placa% and  
			cn1.%notdel% and
			cn9.%notdel% and
		    za3.%notdel% 
	Endsql

	_cdesctip := (_xalias2)->cn1_descri
	(_xalias2)->(dbclosearea())

	//Retira codigo e sinal de "=" da descricao da x3 combobox.
	_okfalEnt		:= X3CBoxDesc("DA3_XSTENT",(_xalias)->DA3_XSTENT)
	_okfalEnt		:= substr(_okfalEnt,3,len(_okfalEnt))
	
	//Quantidade de op's finalizadas parao a coluna OK'
	if 'OK' $ _okfalEnt  
		_nok++
	Endif	
	
	_okfalMec		:= X3CBoxDesc("DA3_XSTMEC",(_xalias)->DA3_XSTMEC)
	_okfalMec		:= substr(_okfalMec,3,len(_okfalMec))
	
	if 'OK' $ _okfalMec  
		_nok++
	Endif	
	
	_okfalRef		:= X3CBoxDesc("DA3_XSTREF",(_xalias)->DA3_XSTREF)
	_okfalRef		:= substr(_okfalRef,3,len(_okfalRef))
	
	if 'OK' $ _okfalRef  
		_nok++
	Endif	
	
	_okfalEnc		:= X3CBoxDesc("DA3_XSTENC",(_xalias)->DA3_XSTENC)
	_okfalEnc		:= substr(_okfalEnc,3,len(_okfalEnc))

	if 'OK' $ _okfalEnc  
		_nok++
	Endif	
	
	_okfalHid		:= X3CBoxDesc("DA3_XSTHID",(_xalias)->DA3_XSTHID)
	_okfalHid		:= substr(_okfalHid,3,len(_okfalHid))
	
	if 'OK' $ _okfalHid  
		_nok++
	Endif	
	
	_okfalPin		:= X3CBoxDesc("DA3_XSTPIN",(_xalias)->DA3_XSTPIN)
	_okfalPin		:= substr(_okfalPin,3,len(_okfalPin))
	
	if 'OK' $ _okfalPin  
		_nok++
	Endif	
	
	_okfalEle		:= X3CBoxDesc("DA3_XSTELE",(_xalias)->DA3_XSTELE)
	_okfalEle		:= substr(_okfalEle,3,len(_okfalEle))
	
	if 'OK' $ _okfalEle  
		_nok++
	Endif	
	
	_okfalQua		:= X3CBoxDesc("DA3_XSTQUA",(_xalias)->DA3_XSTQUA)
	_okfalQua		:= substr(_okfalQua,3,len(_okfalQua))

	if 'OK' $ _okfalQua  
		_nok++
	Endif	

	if _nconta	== 1
		_nok	:= 2
	elseif _nconta	== 2
		_nok	:= 5
	endif

	_okfalPin		:= X3CBoxDesc("DA3_XSTPIN",(_xalias)->DA3_XSTPIN)
	_okfalPin		:= substr(_okfalPin,3,len(_okfalPin))

	_car	:= X3CBoxDesc("DA3_XAR",(_xalias)->DA3_XAR)
	_npos	:= at('-',_car)
	_car	:= substr(_car,_npos+1,len(_car))

	_npos	:= at('-',_cdi)
	_cdi	:= substr(_cdi,_npos+1,len(_cdi))

	_crestricao := X3CBoxDesc("DA3_MSBLQL",(_xalias)->DA3_MSBLQL)
	_npos		:= at('-',_crestricao)
	_crestricao	:= substr(_crestricao,_npos+1,len(_crestricao))	

	_ccodvei	:= (_xalias)->da3_cod

	Beginsql alias _xalias2
		select *
		from %table:sze% sze 
		where sze.ze_cod = %exp:_ccodvei% and  
		    sze.ze_finaliz = %exp:'N'% and  
			sze.%notdel%
	Endsql

	If !(_xalias2)->(eof())
		_creserva	:= "Reservado"
		_ccliente	:= (_xalias2)->ze_nome
		_ddataped	:= stod((_xalias2)->ze_dtped)
		_cprialt	:= ""     //Criar campo na sze
		_ddatasai	:= stod((_xalias2)->ze_dtsaida)
		_chorsai	:= (_xalias2)->ze_horasai
		_cvendedor	:= (_xalias2)->ze_nomeven
	Endif

	(_xalias2)->(DbCloseArea())

	aadd(_acolsFro,{X3CBoxDesc("DA3_XNOVO",(_xalias)->da3_xnovo),(_xalias)->da3_placa,(_xalias)->da3_chassi,_car,;
	  				substr((_xalias)->da3_anofab,3,2)+'/'+substr((_xalias)->da3_anomod,3,2),;
	  				(_xalias)->da3_desc,_cdescmodeloCx,_ccxid,_ctpcx,_cdi,_okfalEnt,;
					_okfalMec,_okfalRef,_okfalEnc,_okfalHid,_okfalPin,_okfalEle,_okfalQua,;
					"",_creserva,_ccliente,_ddataped,_cprialt,_ddatasai,_chorsai,_cdesctip,_cvendedor,"",_nok,_crestricao,.f.})

	(_xalias)->(dbskip())

	_nok	:= 0

	_creserva	:= ""
	_ccliente	:= ""
	_ddataped	:= ""
	_cprialt	:= ""     
	_ddatasai	:= ""
	_chorsai	:= ""
	_cvendedor	:= ""
	
enddo

// ordena pelo campo ok (quantidade de op's finalizadas).
_acolsFro := aSort(_acolsFro,,,{ |x,y| x[29] > y[29] })	

_aCFroBkp := _acolsFro		//Backup do acols para restauraração quando limpar o filtro.

(_xalias)->(dbclosearea())

Return

//Frota Veículos 
Static Function fVeiculos()
Local _xalias	:= GetNextAlias()
Local _llocado  := .f.
Local _lreserva := .f.
Local _nreg		:= 0
Local _aqry		:= {}

aadd(_aHeadVei,{ "Id Veículo","Id Veículo","",20,0,"","C","C",,,,""}) 
aadd(_aHeadVei,{ "Placa","Placa","",20,0,"","C","C",,,,""})
aadd(_aHeadVei,{ "Chassi","Chassi","",20,0,"","C","C",,,,""})
aadd(_aHeadVei,{ "Ano Modelo","Ano Modelo","",20,0,"","C","C",,,,""})
aadd(_aHeadVei,{ "Data Entrada","Data Entrada","",20,0,"","C","C",,,,""})
aadd(_aHeadVei,{ "Início Produção","Inicio Produção","",20,0,"","C","C",,,,""})
aadd(_aHeadVei,{ "Dias Fila","Dias Fila","",20,0,"","C","C",,,,""})
aadd(_aHeadVei,{ "Entrega/Qualidade","Entrega/Qualidade","",20,0,"","C","C",,,,""})
aadd(_aHeadVei,{ "Dias","Dias","",20,0,"","C","C",,,,""})
aadd(_aHeadVei,{ "Dias em Produção","Dias em Produção","",20,0,"","C","C",,,,""})
aadd(_aHeadVei,{ "Média","Média","",20,0,"","C","C",,,,""})

Beginsql alias _xalias
	select *
	from %table:da3% da3
	where da3.da3_filial = %exp:xfilial('DA3')% and
	da3.da3_anofab >= %exp:'2019'% and
	da3.%notdel%
Endsql

count to _nreg
procregua(_nreg)

(_xalias)->(dbgotop()) 

while !(_xalias)->(eof())

	incproc("Aguarde...")
	
	aadd(_acolsVei,{(_xalias)->da3_xidweb,(_xalias)->da3_placa,(_xalias)->da3_chassi,(_xalias)->da3_anomod,"","","","","","","",.f.})
	(_xalias)->(dbskip())

enddo

_aCVeiBkp := _acolsVei		//Backup do acols para restauraraÃ§ao quando limpar o filtro.

(_xalias)->(dbclosearea())

Return

//Frota Compactador
Static Function fCaixas()
Local _xalias		:= GetNextAlias()
Local _xalias2		:= GetNextAlias()
Local _nreg			:= 0
Local _aqry			:= {}
Local _cacoplado	:= space(8)
Local _cnovo		:= ""
Local _npos			:= 0
Local _cdi          := ""
Local _cdespin		:= ""
Local _cdesref		:= ""
Local _cdeshid		:= ""

aadd(_aHeadCx,{ "Tipo","Tipo","",20,0,"","C","C",,,,""}) 
aadd(_aHeadCx,{ "Número","Número","",20,0,"","C","C",,,,""})
aadd(_aHeadCx,{ "Ano Modelo","Ano Modelo","",20,0,"","C","C",,,,""})
aadd(_aHeadCx,{ "Fabricante","Fabricante","",20,0,"","C","C",,,,""})
aadd(_aHeadCx,{ "Modelo","Modelo","",20,0,"","C","C",,,,""})
aadd(_aHeadCx,{ "Capacidade M³","Capacidade M³","",20,0,"","C","C",,,,""})
aadd(_aHeadCx,{ "DI","DI","",20,0,"","C","C",,,,""})
aadd(_aHeadCx,{ "Pintura","Pintura","",20,0,"","C","C",,,,""})
aadd(_aHeadCx,{ "Reforma","Reforma","",20,0,"","C","C",,,,""})
aadd(_aHeadCx,{ "Hidráulica","Hidráulica","",20,0,"","C","C",,,,""})
aadd(_aHeadCx,{ "Acoplado","Acoplado","",20,0,"","C","C",,,,""})

//coluna acoplado, verificar cadastro de conjuntos.

Beginsql alias _xalias
	select *
	from %table:xcx% xcx
	where xcx.xcx_filial = %exp:xfilial('XCX')% and
	xcx.%notdel%
Endsql

count to _nreg
procregua(_nreg)

(_xalias)->(dbgotop()) 

while !(_xalias)->(eof())

	incproc("Aguarde...")

	Beginsql alias _xalias2
		select *
		from %table:za3% za3
		where za3.za3_cxid = %exp:(_xalias)->xcx_codid% and
		za3.%notdel%
	Endsql

	If !(_xalias2)->(eof())
		_cacoplado	:= (_xalias2)->za3_chplac
		_aqry := getlastquery()
	else
		_cacoplado	:= 'N'
	endif

	(_xalias2)->(DbCloseArea())

	_cnovo	:= X3CBoxDesc("XCX_NOVO",(_xalias)->xcx_novo)
	_npos	:= at('-',_cnovo)
	_cnovo	:= substr(_cnovo,_npos+1,len(_cnovo))
	
	_cdi := X3CBoxDesc("XCX_DI",(_xalias)->xcx_di)
	_npos	:= at('-',_cdi)
	_cdi	:= substr(_cdi,_npos+1,len(_cdi))
	
	_cdespin := X3CBoxDesc("XCX_XSTPIN",(_xalias)->xcx_xstpin)
	_cdespin := substr(_cdespin,3,10)
	
	_cdesref := X3CBoxDesc("XCX_XSTREF",(_xalias)->xcx_xstref)
	_cdesref := substr(_cdesref,3,10)

	_cdeshid := X3CBoxDesc("XCX_XSTHID",(_xalias)->xcx_xsthid)
	_cdeshid := substr(_cdeshid,3,10)
	
	aadd(_acolsCx,{_cnovo,(_xalias)->xcx_codid,(_xalias)->xcx_anomod,X3CBoxDesc("XCX_FABRIC",(_xalias)->xcx_fabric),;
	(_xalias)->xcx_descmo,cvaltochar((_xalias)->xcx_capaci),_cdi,_cdespin,_cdesref,_cdeshid,;
	_cacoplado,.f.})

	(_xalias)->(dbskip())
						
enddo

_aCCxBkp := _acolsCx		//Backup do acols para restauraração quando limpar o filtro.

(_xalias)->(dbclosearea())

Return

//Opção de filtro na Aba Frota Local
Static Function ffilfrota(campo)
Local _nate	:= 0
Private _npos	:= 0
Private asize 	:= msadvsize()
Private aestru  := {}
Private acampos	:= {}
Private odlg,omark,cfiles
Private _abut	:= {}
Public _marca := getmark()

//Botao de pesquisa
_abut := {{"",{|| PesqFrota()},"Pesquisar", "Pesquisar"}}

If empty(campo)
	return
endif

cret := .t.                                                                                                                                                                                                                                                      

_npos := aScan(_aCposFro, {|x| x = campo } ) 
_npos--				//Matriz _aCposFro tem a primeira coluna em branco para o combox, entao desconsidera.

_oBtnFilFro:enable()

aadd( aestru, { 'ok'	   			, 'C', 002, 0 } )
aadd( aestru, { 'Conteudo'			, 'C', 030, 0 } )

if select("temp") > 0
	dbselectarea("temp")
	temp->(dbclosearea())
endif

cfiles	:= criatrab( aestru, .t. )
dbusearea( .t.,, cfiles, 'temp', .t. )

carqind	:= criatrab(nil, .f.)
cchave  := "Conteudo"
indregua("temp",carqind,cchave,,,"criando Ã­ndice para arquivo de trabalho")

for _nate := 1 to len(_acolsFro)
	reclock("temp",.t.)
	temp->ok 		:= "" 
	temp->conteudo 	:= 	_acolsFro[_nate][_npos]
next

temp->(dbgotop())
aadd( acampos, {"ok"				,,"  "						," "})
aadd( acampos, {"Conteudo"			,,"Conteudo"				," "})

define msdialog odlg title "Selecione um ou mais itens." from 0,0 to 300,400 pixel 

	_omark := msselect():new("temp","ok",,acampos,.f.,@_marca,{30,00,150,203},,,odlg)
	_omark:bmark := {||SelFrota(_marca)}
	_omark:obrowse:lallmark    := .t.
	_omark:obrowse:refresh()

activate msdialog odlg centered on init enchoicebar(odlg, {||_nopc := 1,ConfSFro(),odlg:end()}, {||_nopc := 0,CancFFro(),odlg:end()},,_abut)

return(cret)

//Opção de ordenacao aba Frota Local
Static Function fordfrota(campo,ntipo)
Local _npos	:= 0
Local _cordem	:= ""
Local _nordem := 0

If !empty(campo)
	_npos := at('-',campo)
	_cordem	:= substr(campo,1,_npos-1)
	_nordem := val(_cordem)

	//Ordem crescente.
	If ntipo == 1 
		_acolsFro := aSort(_acolsFro,,,{ |x,y| x[_nordem] > y[_nordem] })	
	else
		_acolsFro := aSort(_acolsFro,,,{ |x,y| x[_nordem] < y[_nordem] })			
	Endif

	_ogetFro:acols	:= _AcolsFro
	_ogetFro:ForceRefresh()

else

	_ogetFro:acols	:= {}
	_ogetFro:ForceRefresh()

	_ogetFro:acols	:= _aCFroBkp
	_ogetFro:ForceRefresh()

Endif

return()

//Opção de filtro na Aba Frota 1920
Static Function ffilVei(campo)
Local _nate		:= 0
Private _nposvei:= 0
Private asize 	:= msadvsize()
Private aestru  := {}
Private acampos	:= {}
Private odlg,omark,cfiles
Private _abut	:= {}
Public _marca := getmark()

//Botao de pesquisa
_abut := {{"",{|| PesqVei()},"Pesquisar", "Pesquisar"}}

If empty(campo)
	return
endif

cret := .t.                                                                                                                                                                                                                                                      


_nposvei := aScan(_aCpos1920, {|x| x = campo } ) 
_nposvei--				//Matriz _aCpos1920 tem a primeira coluna em branco para o combox, entao desconsidera.

_oBtnFilVei:enable()

aadd( aestru, { 'ok'	   			, 'C', 002, 0 } )
aadd( aestru, { 'Conteudo'			, 'C', 030, 0 } )

if select("tempvei") > 0
	dbselectarea("tempvei")
	tempvei->(dbclosearea())
endif

cfiles	:= criatrab( aestru, .t. )
dbusearea( .t.,, cfiles, 'tempvei', .t. )

carqind	:= criatrab(nil, .f.)
cchave  := "Conteudo"
indregua("tempvei",carqind,cchave,,,"Criando índice para arquivo de trabalho")

for _nate := 1 to len(_acolsVei)
	reclock("tempvei",.t.)
	tempvei->ok 		:= "" 
	tempvei->conteudo 	:= 	_acolsVei[_nate][_nposvei]
next

tempvei->(dbgotop())
aadd( acampos, {"ok"				,,"  "						," "})
aadd( acampos, {"Conteudo"			,,"Conteudo"				," "})

define msdialog odlg title "Selecione um ou mais itens." from 0,0 to 300,400 pixel 

	_omarkvei := msselect():new("tempvei","ok",,acampos,.f.,@_marca,{30,00,150,203},,,odlg)
	_omarkvei:bmark := {||SelVei(_marca)}
	_omarkvei:obrowse:lallmark    := .t.
	_omarkvei:obrowse:refresh()

activate msdialog odlg centered on init enchoicebar(odlg, {||_nopc := 1,ConfSVei(),odlg:end()}, {||_nopc := 0,CancFVei(),odlg:end()},,_abut)

return(cret)

//Opção de ordenacao aba Frota 1920
Static Function ford1920(campo,ntipo)
Local _npos	:= 0
Local _cordem	:= ""
Local _nordem := 0

If !empty(campo)

	_npos := at('-',campo)
	_cordem	:= substr(campo,1,_npos-1)
	_nordem := val(_cordem)

	//Ordem crescente.
	If ntipo == 1 
		_acolsVei := aSort(_acolsVei,,,{ |x,y| x[_nordem] > y[_nordem] })	
	else
		_acolsVei := aSort(_acolsVei,,,{ |x,y| x[_nordem] < y[_nordem] })			
	Endif

	_ogetVei:acols	:= _AcolsVei
	_ogetVei:ForceRefresh()

else
	
	_ogetVei:acols	:= _aCVeiBkp
	_ogetVei:ForceRefresh()

Endif

return()

//OpÃ§ao de filtro na Aba Caixas
Static Function ffilCx(campo)
Local _nate		:= 0
Private _nposcx := 0
Private _aposcx := {}
Private asize 	:= msadvsize()
Private aestru  := {}
Private acampos	:= {}
Private odlg,omark,cfiles
Private _abut	:= {}
Public _marca := getmark()

//Botao de pesquisa
_abut := {{"",{|| PesqCx()},"Pesquisar", "Pesquisar"}}

If empty(campo)
	return
endif

cret := .t.                                                                                                                                                                                                                                                      

_nposcx := aScan(_aCposCx, {|x| x = campo } ) 
_nposcx--				//Matriz _aCposCx tem a primeira coluna em branco para o combox, entao desconsidera.

_oBtnFilCx:enable()

aadd( aestru, { 'ok'	   			, 'C', 002, 0 } )
aadd( aestru, { 'Conteudo'			, 'C', 030, 0 } )

if select("tempcx") > 0
	dbselectarea("tempcx")
	tempcx->(dbclosearea())
endif

cfiles	:= criatrab( aestru, .t. )
dbusearea( .t.,, cfiles, 'tempcx', .t. )

carqind	:= criatrab(nil, .f.)
cchave  := "Conteudo"
indregua("tempcx",carqind,cchave,,,"criando Ã­ndice para arquivo de trabalho")

for _nate := 1 to len(_acolsCx)
	reclock("tempcx",.t.)
	tempcx->ok 		:= "" 
	tempcx->conteudo 	:= 	_acolsCx[_nate][_nposcx]
next

tempcx->(dbgotop())
aadd( acampos, {"ok"				,,"  "						," "})
aadd( acampos, {"Conteudo"			,,"Conteudo"				," "})

define msdialog odlg title "Selecione um ou mais itens." from 0,0 to 300,400 pixel 

	_omarkcx := msselect():new("tempcx","ok",,acampos,.f.,@_marca,{30,00,150,203},,,odlg)
	_omarkcx:bmark := {||SelCx(_marca)}
	_omarkcx:obrowse:lallmark    := .t.
	_omarkcx:obrowse:refresh()

activate msdialog odlg centered on init enchoicebar(odlg, {||_nopc := 1,ConfSCx(),odlg:end()}, {||_nopc := 0,CancFCx(),odlg:end()},,_abut)

return(cret)


//Opção de ordenacao aba Caixas
Static Function fordcx(campo,ntipo)
Local _npos	:= 0
Local _cordem	:= ""
Local _nordem := 0

If !empty(campo)
	_npos := at('-',campo)
	_cordem	:= substr(campo,1,_npos-1)
	_nordem := val(_cordem)

	//Ordem crescente.
	If ntipo == 1 
		_acolsCx := aSort(_acolsCx,,,{ |x,y| x[_nordem] > y[_nordem] })	
	else
		_acolsCx := aSort(_acolsCx,,,{ |x,y| x[_nordem] < y[_nordem] })			
	Endif

	_ogetCx:acols	:= _AcolsCx
	_ogetCx:ForceRefresh()

else
	
	_ogetCx:acols	:= _aCCxBkp
	_ogetCx:ForceRefresh()

Endif

return()

//Seleciona frota...
Static function SelFrota(cparam)

	//desmarcando
	if temp->ok <> _marca
		reclock("temp",.f.)
		temp->ok	:= " "
		temp->(msunlock())
		_omark:obrowse:refresh()
	else
		reclock("temp",.f.)
		temp->ok	:= _marca
		temp->(msunlock())
		_omark:obrowse:refresh()
	endif

return

//Seleciona frota 1920...
Static function SelVei(cparam)

	//desmarcando
	if tempvei->ok <> _marca
		reclock("tempvei",.f.)
		tempvei->ok	:= " "
		tempvei->(msunlock())
		_omarkvei:obrowse:refresh()
	else
		reclock("tempvei",.f.)
		tempvei->ok	:= _marca
		tempvei->(msunlock())
		_omarkvei:obrowse:refresh()
	endif
return

//Seleciona caixa...
Static function SelCx(cparam)

	//desmarcando
	if tempcx->ok <> _marca
		reclock("tempcx",.f.)
		tempcx->ok	:= " "
		tempcx->(msunlock())
		_omarkcx:obrowse:refresh()
	else
		reclock("tempcx",.f.)
		tempcx->ok	:= _marca
		tempcx->(msunlock())
		_omarkcx:obrowse:refresh()
	endif
return

//Confirma filtro Frota Local
Static Function ConfSFro
Local _aColsFiltro	:= {}
Local _aPosfiltro	:= {}
Local _nposic		:= 0
Local _nate			:= 0
Local _nfaz			:= 0

temp->(dbgotop())

//Le temporario
while !temp->(eof())

	//item selecionaddo
	if !empty(temp->ok)

		for _nfaz :=  1 to len(_AcolsFro)

			If alltrim(_AcolsFro[_nfaz,_npos]) == alltrim(temp->Conteudo) 
				aadd(_aPosfiltro,{_nfaz})
			Endif

		next _nfaz

	endif

	temp->(dbskip())
	
enddo

//le as posicoes dos itens selecionados.
for _nate := 1 to len(_aPosfiltro)
		
	aadd(_aColsFiltro,{_AcolsFro[_aPosfiltro[_nate][1]][1],;
					   _AcolsFro[_aPosfiltro[_nate][1]][2],;
					   _AcolsFro[_aPosfiltro[_nate][1]][3],;
					   _AcolsFro[_aPosfiltro[_nate][1]][4],;
					   _AcolsFro[_aPosfiltro[_nate][1]][5],;	
					   _AcolsFro[_aPosfiltro[_nate][1]][6],;
					   _AcolsFro[_aPosfiltro[_nate][1]][7],;
					   _AcolsFro[_aPosfiltro[_nate][1]][8],;							
					   _AcolsFro[_aPosfiltro[_nate][1]][9],;
					   _AcolsFro[_aPosfiltro[_nate][1]][10],;
					   _AcolsFro[_aPosfiltro[_nate][1]][11],;
					   _AcolsFro[_aPosfiltro[_nate][1]][12],;
					   _AcolsFro[_aPosfiltro[_nate][1]][13],;
					   _AcolsFro[_aPosfiltro[_nate][1]][14],;
					   _AcolsFro[_aPosfiltro[_nate][1]][15],;
					   _AcolsFro[_aPosfiltro[_nate][1]][16],;
					   _AcolsFro[_aPosfiltro[_nate][1]][17],;
					   _AcolsFro[_aPosfiltro[_nate][1]][18],;
					   _AcolsFro[_aPosfiltro[_nate][1]][19],;
					   _AcolsFro[_aPosfiltro[_nate][1]][20],;
					   _AcolsFro[_aPosfiltro[_nate][1]][21],;
					   _AcolsFro[_aPosfiltro[_nate][1]][22],;
					   _AcolsFro[_aPosfiltro[_nate][1]][23],;
					   _AcolsFro[_aPosfiltro[_nate][1]][24],;
					   _AcolsFro[_aPosfiltro[_nate][1]][25],;
					   _AcolsFro[_aPosfiltro[_nate][1]][26],;
					   _AcolsFro[_aPosfiltro[_nate][1]][27],;
					   _AcolsFro[_aPosfiltro[_nate][1]][28],;
					   _AcolsFro[_aPosfiltro[_nate][1]][29],;
					   _AcolsFro[_aPosfiltro[_nate][1]][30],;
					   .f.})

next _nate

//Filtra localizados
_AcolsFro		:= {}
_ogetFro:acols	:= _AcolsFro
_ogetFro:ForceRefresh()

_AcolsFro		:= _aColsFiltro
_ogetFro:acols	:= _AcolsFro
_ogetFro:ForceRefresh()

//Atualiza quantidade
_osayqfro:Refresh()

Return

//Confirma filtro Frota 1920
Static Function ConfSVei
Local _aColsFiltro	:= {}
Local _aPosfiltro	:= {}
Local _nposic		:= 0
Local _nate			:= 0
Local _nfaz			:= 0

tempvei->(dbgotop())

//Le temporario
while !tempvei->(eof())

	//item selecionaddo
	if !empty(tempvei->ok)
		
		for _nfaz :=  1 to len(_AcolsVei)

			If alltrim(_AcolsVei[_nfaz,_nposvei]) == alltrim(tempvei->Conteudo) 
				aadd(_aPosfiltro,{_nfaz})
			Endif

		next _nfaz

	endif

	tempvei->(dbskip())
	
enddo


//le as posicoes dos itens selecionados.
for _nate := 1 to len(_aPosfiltro)
		
	aadd(_aColsFiltro,{_AcolsVei[_aPosfiltro[_nate][1]][1],;
					   _AcolsVei[_aPosfiltro[_nate][1]][2],;
					   _AcolsVei[_aPosfiltro[_nate][1]][3],;
					   _AcolsVei[_aPosfiltro[_nate][1]][4],;
					   _AcolsVei[_aPosfiltro[_nate][1]][5],;	
					   _AcolsVei[_aPosfiltro[_nate][1]][6],;
					   _AcolsVei[_aPosfiltro[_nate][1]][7],;
					   _AcolsVei[_aPosfiltro[_nate][1]][8],;							
					   _AcolsVei[_aPosfiltro[_nate][1]][9],;
					   _AcolsVei[_aPosfiltro[_nate][1]][10],;
					   _AcolsVei[_aPosfiltro[_nate][1]][11],;
					   .f.})

next _nate

//Filtra localizados
_AcolsVei		:= {}
_ogetVei:acols	:= _AcolsVei
_ogetVei:ForceRefresh()

_AcolsVei		:= _aColsFiltro
_ogetVei:acols	:= _AcolsVei
_ogetVei:ForceRefresh()

//Atualiza quantidade
_osayqvei:Refresh()

Return

//Confirma filtro Caixas
Static Function ConfSCx
Local _aColsFiltro	:= {}
Local _aPosfiltro	:= {}
Local _nposic		:= 0
Local _nate			:= 0
Local _nfaz			:= 0

tempcx->(dbgotop())

//Le temporario
while !tempcx->(eof())
	
	//item selecionaddo
	if !empty(tempcx->ok)
			
		for _nfaz :=  1 to len(_AcolsCx)
			//localiza item selecionado 

			If alltrim(_AcolsCx[_nfaz,_nposcx]) == alltrim(tempcx->Conteudo) 
				aadd(_aPosfiltro,{_nfaz})
			Endif

		next _nfaz

	endif

	tempcx->(dbskip())
	
enddo

aadd(_aHeadCx,{ "Tipo","Tipo","",20,0,"","C","C",,,,""}) 
aadd(_aHeadCx,{ "Número","Número","",20,0,"","C","C",,,,""})
aadd(_aHeadCx,{ "Ano Modelo","Ano Modelo","",20,0,"","C","C",,,,""})
aadd(_aHeadCx,{ "Fabricante","Fabricante","",20,0,"","C","C",,,,""})
aadd(_aHeadCx,{ "Modelo","Modelo","",20,0,"","C","C",,,,""})
aadd(_aHeadCx,{ "Capacidade ","Capacidade","",20,0,"","C","C",,,,""})
aadd(_aHeadCx,{ "DI","DI","",20,0,"","C","C",,,,""})
aadd(_aHeadCx,{ "Pintura","Pintura","",20,0,"","C","C",,,,""})
aadd(_aHeadCx,{ "Reforma","Reforma","",20,0,"","C","C",,,,""})
aadd(_aHeadCx,{ "Hidráulica","Hidráulica","",20,0,"","C","C",,,,""})
aadd(_aHeadCx,{ "Acoplado","Acoplado","",20,0,"","C","C",,,,""})
aadd(_aHeadCx,{ "C. Telescópio","C. Telescópio","",20,0,"","C","C",,,,""})
aadd(_aHeadCx,{ "C. Compac.","C. Compac.","",20,0,"","C","C",,,,""})
aadd(_aHeadCx,{ "C. Transportador","C. Transportador","",20,0,"","C","C",,,,""})
aadd(_aHeadCx,{ "C. Elevação","C. Elevação","",20,0,"","C","C",,,,""})
aadd(_aHeadCx,{ "C. Bate Cont.","C. Bate Cont.","",20,0,"","C","C",,,,""})

//le as posicoes dos itens selecionados.
for _nate := 1 to len(_aPosfiltro)

	aadd(_aColsFiltro,{_AcolsCx[_aPosfiltro[_nate][1]][1],;
					_AcolsCx[_aPosfiltro[_nate][1]][2],;
					_AcolsCx[_aPosfiltro[_nate][1]][3],;
					_AcolsCx[_aPosfiltro[_nate][1]][4],;
					_AcolsCx[_aPosfiltro[_nate][1]][5],;	
					_AcolsCx[_aPosfiltro[_nate][1]][6],; 
					_AcolsCx[_aPosfiltro[_nate][1]][7],;
					_AcolsCx[_aPosfiltro[_nate][1]][8],;							
					_AcolsCx[_aPosfiltro[_nate][1]][9],;
					_AcolsCx[_aPosfiltro[_nate][1]][10],;
					_AcolsCx[_aPosfiltro[_nate][1]][11],;
					.f.})
	
next _nate

//Filtra localizados
_AcolsCx		:= {}
_ogetCx:acols	:= _AcolsCx
_ogetCx:ForceRefresh()

_AcolsCx		:= _aColsFiltro
_ogetCx:acols	:= _AcolsCx
_ogetCx:ForceRefresh()

//Atualiza quantidade
_osayqcx:Refresh()

Return

//Cancelou a tela de filtro...
Static Function CancFFro()

_ccbox := " "
_ocbox:refresh()

_oBtnFilFro:disable()

Return

//Cancelou a tela de filtro frota 1920...
Static Function CancFVei()

_ccboxVei := " "
_ocboxVei:refresh()

_oBtnFilVei:disable()

Return

//Cancelou a tela de filtro caixas...
Static Function CancFCx()

_ccboxCx := " "
_ocboxCx:refresh()

_oBtnFilCx:disable()

Return

//Pesquisa na tela de filtro frota local
Static Function PesqFrota()
Local _aBox 		:= {}
Local _aRet		:= {}

aadd(_aBox,{1,"Conteúdo : "				,space(50),"@!","naovazio()","","",50,.t.})												

If parambox(_abox,"Parâmetros",@_aRet)		//confirma 

	If !temp->(dbseek(mv_par01))
		msginfo("Conteúdo não localizado.")
		temp->(dbgotop())
	Endif
	
	Return(.t.)		
	
Else										//cancela
	
	Return(.f.)
	
Endif

Return

//Pesquisa na tela de filtro frota 1920
Static Function PesqVei()
Local _aBox 		:= {}
Local _aRet		:= {}

aadd(_aBox,{1,"Conteúdo : "				,space(50),"@!","naovazio()","","",50,.t.})												

If parambox(_abox,"Parâmetros",@_aRet)		//confirma 

	If !tempvei->(dbseek(mv_par01))
		msginfo("Conteúdo não localizado.")
		tempvei->(dbgotop())
	Endif
	
	Return(.t.)		
	
Else										//cancela
	
	Return(.f.)
	
Endif

Return

//Pesquisa na tela de filtro caixas
Static Function PesqCx()
Local _aBox 		:= {}
Local _aRet		:= {}

aadd(_aBox,{1,"Conteúdo : "				,space(50),"@!","naovazio()","","",50,.t.})												

If parambox(_abox,"Parâmetros",@_aRet)		//confirma 

	If !tempcx->(dbseek(mv_par01))
		msginfo("Conteúdo não localizado.")
		tempcx->(dbgotop())
	Endif
	
	Return(.t.)		
	
Else										//cancela
	
	Return(.f.)
	
Endif

Return

//Limpa filtro frota local
Static Function fLimFFro()

_AcolsFro		:= {}
_ogetFro:acols	:= _AcolsFro
_ogetFro:ForceRefresh()

_AcolsFro		:= _aCFroBkp
_ogetFro:acols	:= _AcolsFro
_ogetFro:ForceRefresh()

_ccbox := " "
_ocbox:refresh()

_oBtnFilFro:disable()

Return

//Limpa filtro frota 1920
Static Function fLimFVei()

_AcolsVei		:= {}
_ogetVei:acols	:= _AcolsVei
_ogetVei:ForceRefresh()

_AcolsVei		:= _aCVeiBkp
_ogetVei:acols	:= _AcolsVei
_ogetVei:ForceRefresh()

_ccboxVei := " "
_ocboxVei:refresh()

_oBtnFilVei:disable()

Return

//Limpa filtro caixas
Static Function fLimFCx()

_AcolsCx		:= {}
_ogetCx:acols	:= _AcolsCx
_ogetCx:ForceRefresh()

_AcolsCx		:= _aCCxBkp
_ogetCx:acols	:= _AcolsCx
_ogetCx:ForceRefresh()

_ccboxCx := " "
_ocboxCx:refresh()

_oBtnFilCx:disable()

Return