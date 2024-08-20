#include 'protheus.ch'
#include 'parmtype.ch'


User function RCRMA001()
Private cretorno := ""

If m->ad1_xoport == '4'

	cretorno := fOpcPro()

Endif	

return(cretorno)

//Selecao
Static Function fOpcPro() 
Local _nate		:= 0
Private asize 	:= msadvsize()
Private aestru  := {}
Private acampos	:= {}
Private odlg,omark,cfiles
Private aopcoes	:= {}
Private copcao	:= ""
Public _marca := getmark()

aadd( aestru, { 'ok'	   			, 'C', 002, 0 } )
aadd( aestru, { 'Conteudo'			, 'C', 030, 0 } )

aadd(aopcoes, {"Quente"})
aadd(aopcoes, {"Médio"})
aadd(aopcoes, {"Preço"})

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

define msdialog odlg title "Selecione o tipo de oportunidade." from 0,0 to 300,400 pixel 

	_omark := msselect():new("temp","ok",,acampos,.f.,@_marca,{30,00,150,203},,,odlg)
	_omark:bmark := {||SelOpc(_marca)}
	_omark:obrowse:lallmark    := .t.
	_omark:obrowse:refresh()

activate msdialog odlg centered on init enchoicebar(odlg, {||_nopc := 1,ConfSele()}, {||_nopc := 0,CancSele()},,)

return(copcao)

//Seleciona frota...
Static function SelOpc(cparam)

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