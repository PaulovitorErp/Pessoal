#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} RCRMA002
//TODO Abre opcoes especificas CRM Copac.
@author erivaldo
@since 16/03/2020
@version 1.0
@return ${return}, ${return_description}

@type function/*/

User function RCRMA002(xclass)
Local cUpd 			:= ""
Private cretorno 	:= ""
Private cret2	 	:= ""
Private aopcoes		:= {}
Private aopc		:= {}
Private nopc		:= 0
Private copcao		:= ""
Private copcao2		:= ""
Private copcao3		:= ""
Private xalias		:= getnextalias()
Private oDlg, oDlg2, oDlg3
Private aqry		:= {}
Private cclass		:= ""

Public aEtapas		:= {}

If xclass == '1'

	aadd(aopcoes, {"Sucesso"})
	aadd(aopcoes, {"Insucesso"})
	aadd(aopcoes, {"Não atendido"})
	aadd(aopcoes, {"Sucesso de atendimento"})

	cretorno := fOpcPro()
	
	If (alltrim(cretorno) == "Sucesso" .and. m->aof_status == '3')
		
		aadd(aEtapas,{"stage","000002"})
		aadd(aEtapas,{"chave",m->aof_chave})
		aadd(aEtapas,{"aij_filial",xfilial("AIJ")})
		aadd(aEtapas,{"aij_nropor",ad1->ad1_nropor})
		aadd(aEtapas,{"aij_revisa",ad1->ad1_revisa})
		aadd(aEtapas,{"aij_proven","000001"})
		aadd(aEtapas,{"aij_stage","000002"})
		aadd(aEtapas,{"aij_dtinic",ddatabase})
		aadd(aEtapas,{"aij_hrinic",time()})
		aadd(aEtapas,{"aij_histor",'02'})
		
	Endif

elseif xclass == '2'

	aadd(aopcoes, {"Hidráulica"})
	aadd(aopcoes, {"Chaparia"})
	aadd(aopcoes, {"Mecânica"})
	aadd(aopcoes, {"Elétrica"})
	aadd(aopcoes, {"Entre Eixo"})
	aadd(aopcoes, {"Pintura"})
	aadd(aopcoes, {"Resolução de problemas"})
	
	cretorno := fOpcPro()

elseif xclass == '3'

	aadd(aopcoes, {"Satisfeito"})
	aadd(aopcoes, {"Insatisfeito"})
	aadd(aopcoes, {"Sugestão"})
	
	cretorno := fOpcPro()

elseif xclass == '4'

	nopc := 4

	aadd(aopcoes, {"Semi novos"})
	aadd(aopcoes, {"Locação"})
	aadd(aopcoes, {"Peças"})
	aadd(aopcoes, {"Compactador"})
	aadd(aopcoes, {"Não atende"})
	
	//Descricao da primeira opcao
	cretorno := fOpcPro()

	If ((alltrim(cretorno) == "Semi novos" .or. alltrim(cretorno) == "Peças") .and. m->aof_status == '3') .or. ;
		((alltrim(cret2) == "Simples" .or. alltrim(cret2) == "Novo" .or. alltrim(cret2) == "Reformado" .or. alltrim(cret2) == "Aquisição") .and. m->aof_status == '3') 

		aadd(aEtapas,{"stage","000003"})
		aadd(aEtapas,{"chave",m->aof_chave})
		aadd(aEtapas,{"aij_filial",xfilial("AIJ")})
		aadd(aEtapas,{"aij_nropor",ad1->ad1_nropor})
		aadd(aEtapas,{"aij_revisa",ad1->ad1_revisa})
		aadd(aEtapas,{"aij_proven","000001"})
		aadd(aEtapas,{"aij_stage","000003"})
		aadd(aEtapas,{"aij_dtinic",ddatabase})
		aadd(aEtapas,{"aij_hrinic",time()})
		aadd(aEtapas,{"aij_histor",'02'})
		
	Endif

	//Descricao da segunda opcao
	If !empty(cret2)
		cretorno := alltrim(cretorno)+" = "+alltrim(cret2)
	endif

elseif xclass == '5'

	nopc := 5

	beginsql alias xalias
		select aof_xavtar
		from %table:aof% aof
		where aof.aof_filial = %exp:xfilial("aof")% and
		aof.aof_chave= %exp:ad1->ad1_nropor% and
		aof.aof_xclass = %exp:'4'% and
		aof.%notdel%
	endsql
	
	aqry := getlastquery()
	memowrite(gettemppath()+'rcrma002.txt',aqry[2])

	If "Simples" $ alltrim((xalias)->aof_xavtar) 
		aadd(aopcoes, {"6 meses"})
		aadd(aopcoes, {"12 meeses"})
	Elseif "Aquisição" $ alltrim((xalias)->aof_xavtar)
		aadd(aopcoes, {"24 meses"})		 
		aadd(aopcoes, {"36 meses"})
		aadd(aopcoes, {"48 meeses"})
		aadd(aopcoes, {"60 meeses"})
	Elseif "Semi novos" $ alltrim((xalias)->aof_xavtar)	 
		aadd(aopcoes, {"12 meses"})
		aadd(aopcoes, {"24 meses"})
		aadd(aopcoes, {"36 meeses"})
		aadd(aopcoes, {"48 meeses"})
	Endif
	
	(xalias)->(DbCloseArea())
	
	//Descricao da primeira opcao
	If len(aopcoes) > 0 
		cretorno := fOpcPro()
	Endif

	If (m->aof_status = '3' .and. m->aof_xclass == '5' .and. alltrim(cret2) == "Atende") 

		aadd(aEtapas,{"stage","000004"})
		aadd(aEtapas,{"chave",m->aof_chave})
		aadd(aEtapas,{"aij_filial",xfilial("AIJ")})
		aadd(aEtapas,{"aij_nropor",ad1->ad1_nropor})
		aadd(aEtapas,{"aij_revisa",ad1->ad1_revisa})
		aadd(aEtapas,{"aij_proven","000001"})
		aadd(aEtapas,{"aij_stage","000004"})
		aadd(aEtapas,{"aij_dtinic",ddatabase})
		aadd(aEtapas,{"aij_hrinic",time()})
		aadd(aEtapas,{"aij_histor",'02'})

	Endif

	//Descricao da segunda opcao
	If !empty(cret2)
		cretorno := alltrim(cretorno)+" = "+alltrim(cret2) 
	endif

elseif xclass == '6'

	nopc := 6

	aadd(aopcoes, {"Enviada"})
	aadd(aopcoes, {"Aceita"})
	aadd(aopcoes, {"Recusada"})
	aadd(aopcoes, {"Perdeu Licitação"})
	aadd(aopcoes, {"Concorrente"})
	 
	cretorno := fOpcPro()
	
	If m->aof_status = '3' .and. m->aof_xclass == '6' .and. alltrim(cretorno) == "Aceita"


		aadd(aEtapas,{"stage","000005"})
		aadd(aEtapas,{"chave",m->aof_chave})
		aadd(aEtapas,{"aij_filial",xfilial("AIJ")})
		aadd(aEtapas,{"aij_nropor",ad1->ad1_nropor})
		aadd(aEtapas,{"aij_revisa",ad1->ad1_revisa})
		aadd(aEtapas,{"aij_proven","000001"})
		aadd(aEtapas,{"aij_stage","000005"})
		aadd(aEtapas,{"aij_dtinic",ddatabase})
		aadd(aEtapas,{"aij_hrinic",time()})
		aadd(aEtapas,{"aij_histor",'02'})

	Endif
	
	//Descricao da segunda opcao
	If !empty(cret2)
		cretorno := alltrim(cretorno)+" = "+alltrim(cret2)
	Else
		cretorno := alltrim(cretorno)
	Endif

elseif xclass == '7'

	nopc := 7

	aadd(aopcoes, {"Aceita"})
	aadd(aopcoes, {"Aprovação de crédito"})
	aadd(aopcoes, {"Objeções"})
	
	//Descricao da primeira opcao  
	cretorno := fOpcPro()
	
	If m->aof_status = '3' .and. m->aof_xclass == '7' .and. alltrim(cretorno) == "Aceita"


		aadd(aEtapas,{"stage","000006"})
		aadd(aEtapas,{"chave",m->aof_chave})
		aadd(aEtapas,{"aij_filial",xfilial("AIJ")})
		aadd(aEtapas,{"aij_nropor",ad1->ad1_nropor})
		aadd(aEtapas,{"aij_revisa",ad1->ad1_revisa})
		aadd(aEtapas,{"aij_proven","000001"})
		aadd(aEtapas,{"aij_stage","000006"})
		aadd(aEtapas,{"aij_dtinic",ddatabase})
		aadd(aEtapas,{"aij_hrinic",time()})
		aadd(aEtapas,{"aij_histor",'02'})

	Endif
	
	//Descricao da segunda opcao
	If !empty(cret2)
		cretorno := alltrim(cretorno)+" = "+alltrim(cret2)
	Else
		cretorno := alltrim(cretorno)
	Endif
	
Endif	

FwFldPut("AOF_XAVTAR",cretorno)

return(.t.)

//Selecao
Static Function fOpcPro() 
Local _nate		:= 0
Private asize 	:= msadvsize()
Private aestru  := {}
Private acampos	:= {}
Private omark,cfiles
Public _marca := getmark()

aadd( aestru, { 'ok'	   			, 'C', 002, 0 } )
aadd( aestru, { 'Conteudo'			, 'C', 030, 0 } )

if select("temp") > 0
	dbselectarea("temp")
	temp->(dbclosearea())
endif

cfiles	:= criatrab( aestru, .t. )
dbusearea( .t.,, cfiles, 'temp', .t. )

for _nate := 1 to len(aopcoes)
	reclock("temp",.t.)
	temp->ok 		:= "" 
	temp->conteudo 	:= 	aopcoes[_nate][1]
next

temp->(dbgotop())
aadd( acampos, {"ok"				,,"  "						," "})
aadd( acampos, {"Conteudo"			,,"Conteudo"				," "})

define msdialog odlg title "Selecione." from 0,0 to 300,400 pixel 

	_omark := msselect():new("temp","ok",,acampos,.f.,@_marca,{30,00,150,203},,,odlg)
	_omark:bmark := {||SelOpc(_marca)}
	_omark:obrowse:lallmark    := .t.
	_omark:obrowse:refresh()

activate msdialog odlg centered on init enchoicebar(odlg, {||_nopc := 1,ConfSele()}, {||_nopc := 0,CancSele()},,)

return(copcao)

//Seleciona frota...
Static function SelOpc(cparam)

//Zera array, para nova entrada
aopc := {}

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

		copcao := temp->conteudo
		
		//Segunda opçao		
		If (nopc == 4 .and. alltrim(temp->conteudo) == "Locação")   

			aadd(aopc, {"Simples"})
			aadd(aopc, {"Aquisição"})
					
			cret2 := fopcpro2()
		
		Elseif (nopc == 4 .and. alltrim(temp->conteudo) == "Compactador")

			aadd(aopc, {"Novo"})
			aadd(aopc, {"Reformado"})
		
			cret2  := fopcpro2()
			
		Endif

		//Apresentaçao
		If nopc == 5
		
			aadd(aopc, {"Atende"})
			aadd(aopc, {"Não atende"})
			aadd(aopc, {"Estudar Necessidade"})
		
			cret2 := fopcpro2()
		
		endif
		
		//Proposta
		If nopc == 6 .and. alltrim(temp->conteudo) == "Recusada"
		
			aadd(aopc, {"Preco"})
			aadd(aopc, {"Produto"})
			aadd(aopc, {"Qualidade"})
		
			cret2 := fopcpro2()
		
		endif

		If nopc == 6 .and. alltrim(temp->conteudo) == "Concorrente"
		
			aadd(aopc, {"Planalto"})
			aadd(aopc, {"Usimeca"})
			aadd(aopc, {"Cimasp"})
			aadd(aopc, {"Librelato"})
			aadd(aopc, {"Outros"})
		
			cret2 := fopcpro2()
		
		endif

		If nopc == 7 .and. alltrim(temp->conteudo) == "Aprovação de crédito"
		
			aadd(aopc, {"Alto risco"})
			aadd(aopc, {"Médio"})
			aadd(aopc, {"Baixo"})
		
			cret2 := fopcpro2()
		
		endif

		If nopc == 7 .and. alltrim(temp->conteudo) == "Objeções" 
		
			aadd(aopc, {"Preço"})
			aadd(aopc, {"Prazo"})
		
			cret2 := fopcpro2()
		
		endif

		
		_omark:obrowse:refresh()
		
	endif

return

//Confirma selecao
Static Function ConfSele()
Local lselecionou := .f.

temp->(dbgotop())

//Le temporario
while !temp->(eof())

	//item selecionaddo
	if !empty(temp->ok)
		
		lselecionou := .t.
		copcao := temp->conteudo
		exit
		
	endif

	temp->(dbskip())
	
enddo

If !lselecionou

	MsgStop('Selecione algum item.')
	
Else

	odlg:end()

Endif

Return

//Cancela tela de selecao
Static Function CancSele()
Local lselecionou := .f.

temp->(dbgotop())

//Le temporario
while !temp->(eof())

	//item selecionaddo
	if !empty(temp->ok)

		lselecionou	:= .t.
		
	endif

	temp->(dbskip())
	
enddo

If lselecionou 
	
	msginfo('Quando selecionar algum item, utilize o botão confirmar.')

Else
	
	msginfo('Selecione algum item.')

Endif

Return

//Seleciona 
Static Function fOpcPro2() 
Local _nate			:= 0
Private asize 		:= msadvsize()
Private aestru2  	:= {}
Private acampo2		:= {}
Private omark2,cfiles
Public _marca2 		:= getmark()

aadd( aestru2, { 'ok'	   			, 'C', 002, 0 } )
aadd( aestru2, { 'Conteudo'			, 'C', 030, 0 } )

if select("tmp") > 0
	dbselectarea("tmp")
	tmp->(dbclosearea())
endif

cfiles	:= criatrab( aestru2, .t. )
dbusearea( .t.,, cfiles, 'tmp', .t. )

for _nate := 1 to len(aopc)
	reclock("tmp",.t.)
	tmp->ok 		:= "" 
	tmp->conteudo 	:= 	aopc[_nate][1]
next

tmp->(dbgotop())
aadd( acampo2, {"ok"				,,"  "						," "})
aadd( acampo2, {"Conteudo"			,,"Conteudo"				," "})

define msdialog odlg2 title "Selecione." from 300,0 to 600,400 pixel 

	_omark2 := msselect():new("tmp","ok",,acampo2,.f.,@_marca2,{30,00,150,203},,,odlg2)
	_omark2:bmark := {||SelOpc2(_marca2)}
	_omark2:obrowse:lallmark    := .t.
	_omark2:obrowse:refresh()

activate msdialog odlg2 centered on init enchoicebar(odlg2, {||_nopc := 1,ConfSel2()}, {||_nopc := 0,CancSel2()},,)

return(copcao2)

//Seleciona frota...
Static function SelOpc2(cparam)

	//desmarcando
	if tmp->ok <> _marca2
		reclock("tmp",.f.)
		tmp->ok	:= " "
		tmp->(msunlock())
		_omark2:obrowse:refresh()
	else
		reclock("tmp",.f.)
		tmp->ok	:= _marca2
		tmp->(msunlock())
		_omark2:obrowse:refresh()
	endif

return

//Confirma selecao
Static Function ConfSel2()
Local lselecionou := .f.

tmp->(dbgotop())

//Le temporario
while !tmp->(eof())

	//item selecionaddo
	if !empty(tmp->ok)
		
		lselecionou := .t.
		copcao2 := tmp->conteudo
		exit
		
	endif

	tmp->(dbskip())
	
enddo

If !lselecionou

	MsgStop('Selecione algum item.')
	
Else
	
	odlg2:end()
	odlg:end()

Endif

Return

//Cancela tela de selecao
Static Function CancSel2()
Local lselecionou := .f.

tmp->(dbgotop())

//Le temporario
while !tmp->(eof())

	//item selecionaddo
	if !empty(tmp->ok)

		lselecionou	:= .t.
		
	endif

	tmp->(dbskip())
	
enddo

If lselecionou 
	
	msginfo('Quando selecionar algum item, utilize o botão confirmar.')

Else
	
	msginfo('Selecione algum item.')

Endif

Return