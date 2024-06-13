#include "rwmake.ch"  
#INCLUDE "PROTHEUS.CH"
#Include "SigaWin.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RCTBA002 º Autor ³  Claudio Ferreira  º Data ³  22/03/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Cadastro de Amarracoes Contabeis (Mod2)                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function RCTBA002()

SetPrvt("CCADASTRO,AROTINA,")

cCadastro := "Cadastro de Amarrações Mod.2"

aRotina   := { { "Pesquisar"    ,"AxPesqui" , 0, 1},;
{ "Visualizar"   ,"u_CadAmar(1)" , 0, 2},;
{ "Alterar"      ,"u_CadAmar(3)" , 0, 4},;
{ "Incluir"      ,"u_CadAmar(2)" , 0, 3}}
//{ "Excluir"      ,"u_CadAmar(4)" , 0, 5} }

LoadAmar()

dbSelectArea("ZC1")
dbSetOrder(1)

mBrowse( 6,1,22,75,"ZC1")

Return


User Function CadAmar(nOp)

SetPrvt("COPCAO,NOPCE,NOPCG,NUSADO,AHEADER,ACOLS")
SetPrvt("_NI,_NPOSNAT,_NPOSCC,_NPOSITEM,_NPOSDEL,CTITULO")
SetPrvt("CALIASENCHOICE,CALIASGETD,CLINOK,CTUDOK,CFIELDOK,ACPOENCHOICE")
SetPrvt("_LRET,NNUMIT,NIT,_NPOSREF")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Opcoes de acesso para a Modelo 2                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

if nOp == 1
	nOpcx := 1
elseif nOp == 4
	nOpcx := 1
elseif nOp == 2
	nOpcx := 3
elseif nOp == 3
	nOpcx := 3
endif
xOpc=nOp

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("ZC1",.t.)

// inicia variaveis
if nOp= 2
	//cTipo	:= Space(1)
else
	//cTipo	:= SZ4->Z4_TIPO
endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

nUsado  := 0
dbSelectArea("SX3")
dbSeek("ZC1")
aHeader := {}
While !Eof().And.(x3_arquivo=="ZC1")
	//If Upper(AllTrim(X3_CAMPO)) $ "Z4_TIPO/Z4_GRUPO/Z4_NATUREZ/Z4_FOLHA"
	//	dbSkip()
	//	Loop
	//Endif
	If X3USO(x3_usado) .And. cNivel >= x3_nivel
		nUsado:=nUsado+1
		
		Aadd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,X3_VALID,;     //Iif(!Upper(AllTrim(X3_CAMPO)) $ "Z4_CONTA2" ,X3_VALID,'')
		x3_usado, x3_tipo, x3_arquivo, x3_context } )
	Endif
	dbSkip()
End


//+--------------------------------------------------------------+
//¦ Montando aCols                                               ¦
//+--------------------------------------------------------------+
If nOp==2
	aCols:={Array(nUsado+1)}
	aCols[1,nUsado+1]:=.F.
	For _ni:=1 to nUsado
		aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
	Next 
Else
	aCols:={}
	dbSelectArea("ZC1")    
	dbSeek(xFilial("ZC1"))
	While !eof() .and. xFilial() == ZC1->ZC1_FILIAL 
		AADD(aCols,Array(nUsado+1))
		For _ni:=1 to nUsado
		  //if aHeader[_ni,2]="ZC1_DESC"
          //   aCols[Len(aCols),_ni]:=posicione("CTT",1,xfilial("CTT")+Z4_CC,"CTT_DESC01") 
          // else
  			aCols[Len(aCols),_ni]:=FieldGet(FieldPos(aHeader[_ni,2]))
  	      //endif	
		Next
		aCols[Len(aCols),nUsado+1]:=.F.
		dbSelectArea("ZC1")
		dbSkip()
	Enddo
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis de posicionamento no aCols                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

_nPosDel  := Len(aHeader) + 1

If Len(aCols)>0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a Modelo 2                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTitulo        := "Cadastro de Amarrações Mod.2"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Array com descricao dos campos do Cabecalho do Modelo 2      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aC:={}
	// aC[n,1] = Nome da Variavel Ex.:"cCliente"
	// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
	// aC[n,3] = Titulo do Campo
	// aC[n,4] = Picture
	// aC[n,5] = Validacao  iif(nOp=2,u_TestaRef(dData),.t.)
	// aC[n,6] = F3
	// aC[n,7] = Se campo e' editavel .t. se nao .f. 
	//lEdGrupo:=iif((nOp=2 .or. nOp=3).and. M->cTipo='G',.t.,.f.)
	//AADD(aC,{"cTipo"	,{15,10} ,"Tipo [G,N,F] "	,"@!",'u_ValTipo()',,iif(nOp=2,.t.,.f.)})
	//AADD(aC,{"cGrupo"	,{15,100} ,"Grp Produto  "	,"@!",'u_ValGrp()','SBM',iif(nOp=2,.t.,.f.)})     
	//AADD(aC,{"cNatur"	,{30,10} ,"Natureza  "	,"@!",'u_ValNat()','SED',iif(nOp=2,.t.,.f.)})
	//AADD(aC,{"cFolha"	,{30,100} ,"Folha  "	,"@!",'u_ValFol()','CT5',iif(nOp=2,.t.,.f.)})
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Array com descricao dos campos do Rodape do Modelo 2         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aR:={}
	// aR[n,1] = Nome da Variavel Ex.:"cCliente"
	// aR[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
	// aR[n,3] = Titulo do Campo
	// aR[n,4] = Picture
	// aR[n,5] = Validacao
	// aR[n,6] = F3
	// aR[n,7] = Se campo e' editavel .t. se nao .f.
	//AADD(aR,{"nLinGetD"	,{120,10},"Linha na GetDados"	,"@E 999",,,.F.})
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Array com coordenadas da GetDados no modelo2                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCGD:={60,5,118,315}
	
	cLinhaOk       := "u_LCtbA002(xOpc)"
	cTudoOk        := "AllwaysTrue()"

	n:=1
	_lRet:= Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk)
    //_lRet:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk,,,,,,.F.,GetmBrowse())
	
 	If _lRet
		If nOp==2 .or. nOp==3 .or. nOp==4
			If nOp == 4 .or. nOp == 3
				//se opcao for alteracao ou exclusao, exclui os dados
				dbSelectArea("ZC1")
				If 	dbSeek(xFilial("ZC1"))					
   			      While !eof() .and. xFilial() == ZC1->ZC1_FILIAL 
						RecLock("ZC1",.f.)
						dbDelete()
						MsUnLock()
						dbskip()
					enddo
				endif
			endif
			If nOp==2 .or. nOp == 3
				//se opcao for inclusao ou alteracao, grava os dados
				dbSelectArea("ZC1")
				dbSetOrder(1)
				For nIt := 1 To Len(aCols)
					If !aCols[nIt,_nPosDel]
						RecLock("ZC1",.T.)
						ZC1->ZC1_FILIAL  := xFilial()
						ZC1->ZC1_ID      := aCols[nIt,aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="ZC1_ID" })]
						ZC1->ZC1_DESC    := aCols[nIt,aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="ZC1_DESC" })]
						ZC1->ZC1_CONTA   := aCols[nIt,aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="ZC1_CONTA" })]
						MsUnLock()
					Endif
				Next
			endif
		endif
	Endif
Endif
Return (.t.)

user Function LCtbA002(xOp,cChave)
Local nPos
// n = linha ativa do getdados
if aCols[n,_nPosDel] //deletado
	return(.t.)
endif  

nPos:=aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "ZC1_ID" })

cCod := aCols[n,nPos]

for _ii=1 to len(aCols)
	// se já existe o código em outra posição e está linha não está deletada exibe msg
	if aCols[_ii,nPos] = cCod .and. _ii#n .and. !aCols[_ii,_nPosDel]
		msgbox("ID já cadastrado nesta Tabela")
		return (.f.)
	endif
next 

return .t.
 
Static Function LoadAmar()
Local i
Local aAmar:={}
aadd(aAmar,{'001','CONTA CLIENTES'})
aadd(aAmar,{'002','CONTA FORNECEDORES'})
aadd(aAmar,{'003','CONTA ADIANTAMENTO A CLIENTES'})
aadd(aAmar,{'004','CONTA ADIANTAMENTO A FORNECEDORES'})
aadd(aAmar,{'005','ISS RETIDO A RECOLHER TOMADO'})
aadd(aAmar,{'006','INSS A RECOLHER'})
aadd(aAmar,{'007','IRRF A RECOLHER'})
aadd(aAmar,{'008','DESCONTO CONCEDIDO'})
aadd(aAmar,{'009','JUROS RECEBIDOS'})
aadd(aAmar,{'010','DESCONTO OBTIDOS'})
aadd(aAmar,{'011','JUROS PAGOS'})
aadd(aAmar,{'012','RETENCAO CSLL/COFINS/PIS - (Lei 10833) S/ COMPRA'})
aadd(aAmar,{'013','DEDUCAO RECEITA - PIS'})
aadd(aAmar,{'014','DEDUCAO RECEITA - COFINS'})
aadd(aAmar,{'015','PIS A RECOLHER'})
aadd(aAmar,{'016','COFINS A RECOLHER'})
aadd(aAmar,{'017','DEDUCAO RECEITA - ICMS'})
aadd(aAmar,{'018','DEDUCAO RECEITA - IPI'})
aadd(aAmar,{'019','ICMS A RECOLHER'})
aadd(aAmar,{'020','IPI A RECOLHER'})
aadd(aAmar,{'021','DEDUCAO RECEITA - ICMS ST'})
aadd(aAmar,{'022','ICMS ST A RECOLHER'})
aadd(aAmar,{'023','DESCONTO INCONDICIONAL S/ VENDAS'})
aadd(aAmar,{'024','ICMS A RECUPERAR'})
aadd(aAmar,{'025','ICMS ATIVO PERMANENTE A RECUPERAR'})
aadd(aAmar,{'026','FUNRURAL A RECOLHER'})
aadd(aAmar,{'027','IPI A RECUPERAR'})
aadd(aAmar,{'028','PIS A RECUPERAR'})
aadd(aAmar,{'029','COFINS A RECUPERAR'})
aadd(aAmar,{'030','DEDUCAO RECEITA - DEVOLUCAO DE VENDAS'})
aadd(aAmar,{'031','DEVOLUCAO DE CLIENTE'})
aadd(aAmar,{'032','PIS DEV VENDAS A COMPENSAR'})
aadd(aAmar,{'033','COFINS DEV VENDAS A COMPENSAR'})
aadd(aAmar,{'034','ELABORACAO DE PRODUTOS'})
aadd(aAmar,{'035','REDUTORA DA DESPESA (ABSORCAO DE MAO-DE-OBRA)'})
aadd(aAmar,{'036','AJUSTE DE INVENTARIO'})
aadd(aAmar,{'037','VARIACAO CAMBIAL PASSIVA'})
aadd(aAmar,{'038','VARIACAO CAMBIAL  ATIVA'})
aadd(aAmar,{'039','DEVOLUCAO DE CHEQUES'})
aadd(aAmar,{'040','PIS/COFINS/CSLL S/ FATURAMENTO'})
aadd(aAmar,{'041','IRRF S/ FATURAMENTO'})
aadd(aAmar,{'042','ISS S/ FATURAMENTO'})
aadd(aAmar,{'043','INSS S/ FATURAMENTO'})
aadd(aAmar,{'044','DEDUCAO RECEITA - ISS'})
aadd(aAmar,{'045','LEASING A PAGAR LONGO PRAZO'})
aadd(aAmar,{'046','LEASING A PAGAR CURTO PRAZO'})
aadd(aAmar,{'047','FINANCIAMENTO A PAGAR LONGO PRAZO'})
aadd(aAmar,{'048','FINANCIAMENTO A PAGAR CURTO PRAZO'})
aadd(aAmar,{'049','JUROS A TRANSCORRER S/ LEASING LONGO PRAZO'})
aadd(aAmar,{'050','JUROS A TRANSCORRER S/ LEASING CURTO PRAZO'})
aadd(aAmar,{'051','JUROS A TRANSCORRER S/ FINANCIAMENTO LONGO PRAZO'})
aadd(aAmar,{'052','JUROS A TRANSCORRER S/ FINANCIAMENTO CURTO PRAZO'})
aadd(aAmar,{'053','JUROS S/ LEASING'})
aadd(aAmar,{'054','JUROS S/ FINANCIAMENTOS'})
aadd(aAmar,{'055','ISS A RECOLHER S/ FATURAMENTO'})
aadd(aAmar,{'056','PIS S/ FATURAMENTO'})
aadd(aAmar,{'057','COFINS S/ FATURAMENTO'})
aadd(aAmar,{'058','CSLL S/ FATURAMENTO'})
aadd(aAmar,{'059','RETENCAO PIS - (Lei 10833) S/ COMPRA'})
aadd(aAmar,{'060','RETENCAO COFINS - (Lei 10833) S/ COMPRA'})
aadd(aAmar,{'061','RETENCAO CSLL - (Lei 10833) S/ COMPRA'})
aadd(aAmar,{'062','CUSTO DO PRODUTO VENDIDO (CPV)'})
aadd(aAmar,{'063','CUSTO DA MERCADORIA VENDIDA (CMV)'})
aadd(aAmar,{'064','CUSTO DA MERCADORIA BONIFICADA'})
aadd(aAmar,{'065','CUSTO DA MERCADORIA TRANSFERIDA'})
aadd(aAmar,{'066','CUSTO DA MERCADORIA EM TERCEIROS'})
aadd(aAmar,{'070','ICMS ST A RECOLHER - AC'}) 
aadd(aAmar,{'071','ICMS ST A RECOLHER - AL'})
aadd(aAmar,{'072','ICMS ST A RECOLHER - AM'})
aadd(aAmar,{'073','ICMS ST A RECOLHER - AP'})
aadd(aAmar,{'074','ICMS ST A RECOLHER - BA'})
aadd(aAmar,{'075','ICMS ST A RECOLHER - CE'})
aadd(aAmar,{'076','ICMS ST A RECOLHER - DF'})
aadd(aAmar,{'077','ICMS ST A RECOLHER - ES'})
aadd(aAmar,{'078','ICMS ST A RECOLHER - GO'})
aadd(aAmar,{'079','ICMS ST A RECOLHER - MA'})
aadd(aAmar,{'080','ICMS ST A RECOLHER - MG'})
aadd(aAmar,{'081','ICMS ST A RECOLHER - MS'})
aadd(aAmar,{'082','ICMS ST A RECOLHER - MT'})
aadd(aAmar,{'083','ICMS ST A RECOLHER - PA'})
aadd(aAmar,{'084','ICMS ST A RECOLHER - PB'})
aadd(aAmar,{'085','ICMS ST A RECOLHER - PE'})
aadd(aAmar,{'086','ICMS ST A RECOLHER - PI'})
aadd(aAmar,{'087','ICMS ST A RECOLHER - PR'})
aadd(aAmar,{'088','ICMS ST A RECOLHER - RJ'})
aadd(aAmar,{'089','ICMS ST A RECOLHER - RN'})
aadd(aAmar,{'090','ICMS ST A RECOLHER - RO'})
aadd(aAmar,{'091','ICMS ST A RECOLHER - RR'})
aadd(aAmar,{'092','ICMS ST A RECOLHER - RS'})
aadd(aAmar,{'093','ICMS ST A RECOLHER - SC'})
aadd(aAmar,{'094','ICMS ST A RECOLHER - SE'})
aadd(aAmar,{'095','ICMS ST A RECOLHER - SP'})
aadd(aAmar,{'096','ICMS ST A RECOLHER - TO'})
aadd(aAmar,{'097','PROVISAO DEVEDORES DUVIDOSOS'})
aadd(aAmar,{'098','PERDA RECEBIMENTO'})
aadd(aAmar,{'099','RECUPERACAO DE CREDITOS'})
aadd(aAmar,{'100','COBRANCA POR VENDOR (RETIFICADORA ATIVO)'})
aadd(aAmar,{'101','RECEITA VENDOR'})
aadd(aAmar,{'102','DESPESA VENDOR'})
aadd(aAmar,{'103','ISS A RETIDO A RECUPERAR'})
aadd(aAmar,{'104','CHEQUES A COMPENSAR'})
aadd(aAmar,{'105','ATIVO - PIS - CREDITO S/ DEPRECIACAO'})
aadd(aAmar,{'106','ATIVO - RESULTADO (-) PIS'})
aadd(aAmar,{'107','ATIVO - COFINS - CREDITO S/ DEPRECIACAO'})
aadd(aAmar,{'108','ATIVO - RESULTADO (-) COFINS'})
aadd(aAmar,{'109','ICMS ATIVO PERMANENTE NAO RECUPERAVEL'})
aadd(aAmar,{'110','(-) CREDITO CIAP REDUTORA IMOBILIZADO'})
aadd(aAmar,{'111','DESPESA COM JUROS SOBRE EMPRESTIMOS'})
aadd(aAmar,{'112','(-) JUROS SOBRE EMPRESTIMOS'})
aadd(aAmar,{'113','COMPENSAÇÃO DE ADIANTAMENTO'})
aadd(aAmar,{'114','RESERVA TECNICA'})
aadd(aAmar,{'115','ATIVO DIF ALIQ CIAP'})
                                                          
dbSelectArea("ZC1")
dbSetOrder(1)
For i:=Len(aAmar) to 1 step -1
   if !dbSeek(xFilial("ZC1")+aAmar[i,1])
 	 RecLock("ZC1",.t.)
	 ZC1->ZC1_FILIAL  := xFilial("ZC1")
	 ZC1->ZC1_ID      := aAmar[i,1]
	 ZC1->ZC1_DESC    := aAmar[i,2]
	 MsUnLock()
   endif
Next i

Return

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ RetCta   ¦ Autor ¦ Cláudio Ferreira   ¦ Data ¦  09/04/2012 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Rotina para retornar a cta contábil amarrada               ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ LP´s                                                       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

User Function RetCta(cID) 
Local cRet
cRet:=Posicione('ZC1',1,xFilial('ZC1')+cID,'ZC1_CONTA')
If empty(cRet)
  cRet:='Cta vza id:'+cID
endif  
  
Return cRet


/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ RetCtaCa ¦ Autor ¦ Cláudio Ferreira   ¦ Data ¦  09/04/2012 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Rotina para retornar a cta contábil por carteira           ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ LP´s                                                       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

User Function RetCtaCa(cCart)
Local cConta
if empty(cCart)
  cCart := '0' //Em Carteira
Endif
Do Case  
    Case cCart='0' //Em Carteira
      cConta:=IIF(!EMPTY(SA6->A6_CONTA), SA6->A6_CONTA, 'CTA BANCO VAZIA')
    Case cCart='1' //Cobrança simples
      cConta:=IIF(!EMPTY(SA6->A6_CONTA), SA6->A6_CONTA, 'CTA BANCO VAZIA')
    Case cCart='2' //Cobrança descontada
      cConta:=IIF(!EMPTY(SA6->A6_XCTADES), SA6->A6_XCTADES, 'CTA BAN DESC VZA')
    Case cCart='3' //Cobrança caucionada
      cConta:=IIF(!EMPTY(SA6->A6_CONTA), SA6->A6_CONTA, 'CTA BANCO VAZIA')
    Case cCart='4' //Cobrança vinculada
      cConta:=IIF(!EMPTY(SA6->A6_CONTA), SA6->A6_CONTA, 'CTA BANCO VAZIA')
    Case cCart='5' //Cobrança c/advogado
      cConta:='CTA ADV VZA'
    Case cCart='6' //Cobrança judicial
      cConta:=IIF(!EMPTY(SA6->A6_CONTA), SA6->A6_CONTA, 'CTA BANCO VAZIA')
    Case cCart='7' //Cobrança Cauc Desconto
      cConta:='CTA CAUC DESC VZA'
    Case cCart='F' //Cobrança Protesto
      cConta:='CTA PROT. VZA'
    Case cCart='G' //Cobrança Acordo
      cConta:='CTA ACORDO VZA'
    Case cCart='H' //Cobrança Cartório
      cConta:='CTA CART. VZA'
    OtherWise //Desconhecido
      cConta:=IIF(!EMPTY(SA6->A6_CONTA), SA6->A6_CONTA, 'CTA BANCO VAZIA')
    EndCase
     
 //endif   

//dbSelectArea(_sAlias)
Return cConta

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ RetCtaCc ¦ Autor ¦ Cláudio Ferreira   ¦ Data ¦  04/06/2012 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Rotina para retornar a cta contábil por cc                 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ LP´s                                                       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

User Function RetCtaCc(cCC)
Local cConta
Local cTpCC:=' '

If CTT->(FieldPos("CTT_XCD"))> 0
  cTpCC:= Posicione('CTT',1,xFilial('CTT')+cCC,'CTT_XCD')
Endif   

cConta:=iif(cTpCC='C',SB1->B1_XCTAC,SB1->B1_XCTAD)
cConta:=iif(!EMPTY(cConta), cConta, 'CTA '+iif(cTpCC='C','CUSTO','DESP')+' PROD VAZIA')
Return cConta

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ RetFolCc ¦ Autor ¦ Cláudio Ferreira   ¦ Data ¦  29/08/2012 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Rotina para retornar a cta contábil por cc                 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ LP´s  Folha                                                ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

//Credito
User Function RetFolCc(cCC)
Local cConta
Local cTpCC:=' '

If CTT->(FieldPos("CTT_XCD"))> 0
  cTpCC:= Posicione('CTT',1,xFilial('CTT')+cCC,'CTT_XCD')
Endif   

cConta:=iif(cTpCC='C',POSICIONE("SRV",1,xFilial("SRV")+SRZ->RZ_PD,"RV_XCTACC"),POSICIONE("SRV",1,xFilial("SRV")+SRZ->RZ_PD,"RV_XCTACR"))
cConta:=iif(!EMPTY(cConta), cConta, 'CTA CRE '+iif(cTpCC='C','CUSTO','DESP')+' VERBA VAZIA')
Return cConta

//Debito
User Function RetFolCd(cCC)
Local cConta
Local cTpCC:=' '

If CTT->(FieldPos("CTT_XCD"))> 0
  cTpCC:= Posicione('CTT',1,xFilial('CTT')+cCC,'CTT_XCD')
Endif   

cConta:=iif(cTpCC='C',POSICIONE("SRV",1,xFilial("SRV")+SRZ->RZ_PD,"RV_XCTAC"),POSICIONE("SRV",1,xFilial("SRV")+SRZ->RZ_PD,"RV_XCTAD"))
cConta:=iif(!EMPTY(cConta), cConta, 'CTA DEB '+iif(cTpCC='C','CUSTO','DESP')+' VERBA VAZIA')
Return cConta

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ RetCcCta ¦ Autor ¦ Cláudio Ferreira   ¦ Data ¦  10/10/2012 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Rotina para retornar o C.Custo dependendo da Conta Ctb     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ LP´s                                                       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

User Function RetCcCta(cCC,cCta)
If !Posicione('CT1',1,xFilial('CT1')+cCta,'CT1_ACCUST')=='1'
  cCC:=''
Endif   
Return cCC

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ RetItCta ¦ Autor ¦ Cláudio Ferreira   ¦ Data ¦  07/11/2012 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Rotina para retornar o Item Ctb dependendo da Conta Ctb    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ LP´s                                                       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

User Function RetItCta(cIt,cCta)
If !Posicione('CT1',1,xFilial('CT1')+cCta,'CT1_ACITEM')=='1'
  cIt:=''
Endif   
Return cIt


/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ RetCtaIm ¦ Autor ¦ Cláudio Ferreira   ¦ Data ¦  23/08/2012 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Rotina para retornar a cta contábil do imobilizado         ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ LP´s                                                       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

User Function RetCtaIm()
Local cConta

If SB1->(FieldPos("B1_XCTAI"))> 0
  cConta:=iif(!EMPTY(SB1->B1_XCTAI),SB1->B1_XCTAI,'CTA IMOB PROD VAZIA')
else      
  cConta:=iif(!EMPTY(SB1->B1_CONTA),SB1->B1_CONTA,'CTA CTB PROD VAZIA')
Endif    

Return cConta

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ RetCtaRec ¦ Autor ¦ Cláudio Ferreira  ¦ Data ¦  07/11/2012 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Rotina para retornar a cta contábil CR por Natureza        ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ LP´s                                                       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

User Function RetCtaRec(cDC,cTipo)
Local cConta:=' '
Local lOld:=.t.

Default cDC:=' '
Default cTipo:=' '

If (SED->(FieldPos("ED_XPROVIS"))> 0 .AND. SED->(FieldPos("ED_XBAIXA"))> 0 ) .AND. !SED->(Eof())
  lOld:=.f.
Endif   

if Upper(cDC)='D' .and. Upper(cTipo)='P'
  if lOld
    cConta:=IIF(!EMPTY(SED->ED_DEBITO), SED->ED_DEBITO, IF(!EMPTY(SA1->A1_CONTA),SA1->A1_CONTA, U_RetCta('001')))
  else      
    if SED->ED_XPROVIS="1"
      cConta:=IF(!EMPTY(SA1->A1_CONTA),SA1->A1_CONTA, U_RetCta('001'))
    else
      cConta:=IIF(!EMPTY(SED->ED_DEBITO), SED->ED_DEBITO, 'CTA DEB NATZ VZA')
    endif  
  endif 
elseif Upper(cDC)='C' .and. Upper(cTipo)='P'
  if lOld
    cConta:=IIF(!EMPTY(SED->ED_CONTA), SED->ED_CONTA, 'CTA CTB NATZ VZA')
  else      
    if SED->ED_XPROVIS="1"
      cConta:=IIF(!EMPTY(SED->ED_CONTA), SED->ED_CONTA, 'CTA CTB NATZ VZA')
    else
      cConta:=IIF(!EMPTY(SED->ED_CREDIT), SED->ED_CREDIT, 'CTA CRE NATZ VZA')
    endif  
  endif  
elseif Upper(cDC)='D' .and. Upper(cTipo)='B'
    cConta:=U_RetCtaCa(SE5->E5_SITCOB)
elseif Upper(cDC)='C' .and. Upper(cTipo)='B'
  if lOld
    cConta:=IF(!EMPTY(SA1->A1_CONTA),SA1->A1_CONTA, U_RetCta('001'))
  else      
    if SED->ED_XBAIXA="1"
      cConta:=IF(!EMPTY(SA1->A1_CONTA),SA1->A1_CONTA, U_RetCta('001'))
    elseif SED->ED_XBAIXA="2"
      cConta:=IIF(!EMPTY(SED->ED_DEBITO), SED->ED_DEBITO, 'CTA DEB NATZ VZA')
    else
      cConta:=IIF(!EMPTY(SED->ED_CREDIT), SED->ED_CREDIT, 'CTA CRE NATZ VZA')
    endif  
  endif  
endif
  
Return cConta

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ RetCtaPag ¦ Autor ¦ Cláudio Ferreira  ¦ Data ¦  07/11/2012 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Rotina para retornar a cta contábil CP por Natureza        ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ LP´s                                                       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

User Function RetCtaPag(cDC,cTipo)
Local cConta:=' '
Local lOld:=.t.

Default cDC:=' '
Default cTipo:=' '

If (SED->(FieldPos("ED_XPROVIS"))> 0 .AND. SED->(FieldPos("ED_XBAIXA"))> 0) .AND. !SED->(Eof())
  lOld:=.f.
Endif   

if Upper(cDC)='D' .and. Upper(cTipo)='P'
  if lOld
    cConta:=IIF(!EMPTY(SED->ED_CONTA), SED->ED_CONTA, 'CTA CTB NATZ VZA')
  else      
    if SED->ED_XPROVIS="1"
      cConta:=IIF(!EMPTY(SED->ED_CONTA), SED->ED_CONTA, 'CTA CTB NATZ VZA')
    else
      cConta:=IIF(!EMPTY(SED->ED_DEBITO), SED->ED_DEBITO, 'CTA DEB NATZ VZA')
    endif  
  endif 
elseif Upper(cDC)='C' .and. Upper(cTipo)='P'
  if lOld
    cConta:=IF(!EMPTY(SA2->A2_CONTA),SA2->A2_CONTA,U_RetCta('002'))
  else      
    if SED->ED_XPROVIS="1"
      cConta:=IF(!EMPTY(SA2->A2_CONTA),SA2->A2_CONTA,U_RetCta('002'))
    else
      cConta:=IIF(!EMPTY(SED->ED_CREDIT), SED->ED_CREDIT, 'CTA CRE NATZ VZA')
    endif  
  endif  
elseif Upper(cDC)='D' .and. Upper(cTipo)='B'
  if lOld
    cConta:=iif(!SE2->E2_TIPO$'NF /DP /FT /RC /BOL/CT /OP ',iif(!empty(SED->ED_CONTA), SED->ED_CONTA, 'CTA NATUREZ VAZIA'),IF(!EMPTY(SA2->A2_CONTA),SA2->A2_CONTA,U_RetCta('002')))
  else      
    if SED->ED_XBAIXA="1"
      cConta:=IF(!EMPTY(SA2->A2_CONTA),SA2->A2_CONTA,U_RetCta('002'))
    elseif SED->ED_XBAIXA="2"
      cConta:=IIF(!EMPTY(SED->ED_DEBITO), SED->ED_DEBITO, 'CTA DEB NATZ VZA')
    else
      cConta:=IIF(!EMPTY(SED->ED_CREDIT), SED->ED_CREDIT, 'CTA CRE NATZ VZA')
    endif  
  endif  
elseif Upper(cDC)='C' .and. Upper(cTipo)='B'
    cConta:=IIF(!EMPTY(SA6->A6_CONTA), SA6->A6_CONTA, 'CTA BANCO VAZIA')
endif
  
Return cConta


/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ RetCtaMvb ¦ Autor ¦ Cláudio Ferreira  ¦ Data ¦  07/11/2012 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Rotina para retornar a cta contábil Mov.Banc por Natureza  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ LP´s                                                       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

User Function RetCtaMvb(cDC,cTipo)
Local cConta:=' '
Local lOld:=.t.

Default cDC:=' '
Default cTipo:=' '

If (SED->(FieldPos("ED_XPROVIS"))> 0 .AND. SED->(FieldPos("ED_XBAIXA"))> 0 ) .AND. !SED->(Eof())
  lOld:=.f.
Endif   

if Upper(cDC)='D' .and. Upper(cTipo)='P'
  if lOld
    cConta:=IIF(!EMPTY(SED->ED_CONTA), SED->ED_CONTA,'CTA CTB NATZ VZA')
  else      
    if SED->ED_XPROVIS="1"
      cConta:=IIF(!EMPTY(SED->ED_CONTA), SED->ED_CONTA, 'CTA CTB NATZ VZA')
    elseif SED->ED_XBAIXA="2"
      cConta:=IIF(!EMPTY(SED->ED_DEBITO), SED->ED_DEBITO, 'CTA DEB NATZ VZA')
    else
      cConta:=IIF(!EMPTY(SED->ED_CREDIT), SED->ED_CREDIT, 'CTA CRE NATZ VZA')
    endif  
  endif 
elseif Upper(cDC)='C' .and. Upper(cTipo)='P'
    cConta:=IF(SE5->E5_SITUACA$"C,X".and.!empty(SE5->E5_CREDITO),SE5->E5_CREDITO,IIF(!EMPTY(SA6->A6_CONTA),SA6->A6_CONTA, 'CTA BANCO VAZIA'))
elseif Upper(cDC)='D' .and. Upper(cTipo)='R'
    cConta:=IF(SE5->E5_SITUACA$"C,X".and.!empty(SE5->E5_DEBITO),SE5->E5_DEBITO,IIF(!EMPTY(SA6->A6_CONTA), SA6->A6_CONTA, 'CTA BANCO VAZIA'))
elseif Upper(cDC)='C' .and. Upper(cTipo)='R'
  if lOld
    cConta:=IIF(!EMPTY(SED->ED_CONTA), SED->ED_CONTA,'CTA CTB NATZ VZA')
  else      
    if SED->ED_XPROVIS="1"
      cConta:=IIF(!EMPTY(SED->ED_CONTA), SED->ED_CONTA, 'CTA CTB NATZ VZA')
    elseif SED->ED_XBAIXA="2"
      cConta:=IIF(!EMPTY(SED->ED_DEBITO), SED->ED_DEBITO, 'CTA DEB NATZ VZA')
    else
      cConta:=IIF(!EMPTY(SED->ED_CREDIT), SED->ED_CREDIT, 'CTA CRE NATZ VZA')
    endif  
  endif 
endif
  
Return cConta

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ SEV2SE1  ¦ Autor ¦ Cláudio Ferreira   ¦ Data ¦  16/08/2012 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Rotina para posicionar a SE1 na contabilização MultiNatur. ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ LP´s                                                       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

User Function SEV2SE1()

if !SEV->(Eof())
  SE1->(Dbsetorder(1))
  SE1->(Dbseek(xFilial("SE1")+SEV->(EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO)))
endif  

Return .T.

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ SEV2SE2  ¦ Autor ¦ Cláudio Ferreira   ¦ Data ¦  16/08/2012 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Rotina para posicionar a SE2 na contabilização MultiNatur. ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ LP´s                                                       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

User Function SEV2SE2()
if !SEV->(Eof())
  SE2->(Dbsetorder(1))
  SE2->(Dbseek(xFilial("SE2")+SEV->(EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIFOR+EV_LOJA)))
endif  

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºPrograma  ³ RCTBE001 º Autor ³ TBC-GO             º Data ³  02/04/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retorna os valores de retencao do PIS/COFINS/CSLL somente  º±±
±±º          ³ se foram retidos pela EMISSAO                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LP´s                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function RCTBE001(_ctipo)
Local nRet := 0, cAlias := getNextAlias(), aArea := getArea()
Local cNum := SF2->F2_DUPL, cPref := SF2->F2_SERIE, cCliente := SF2->F2_CLIENTE, cLoja := SF2->F2_LOJA

_ctipo := Upper(_ctipo)
                      
if _ctipo = 'PIS'
                BEGINSQL ALIAS cAlias
                               column VRET as Numeric(14,2)
                               SELECT coalesce(SUM(E1_VALOR),0) VRET
                                 FROM %table:SE1% SE1
                                WHERE SE1.%notdel%
                                  AND E1_PREFIXO = %exp:cPref%
                                  AND E1_NUM     = %exp:cNum%
                                  AND E1_CLIENTE = %exp:cCliente%
                                  AND E1_LOJA    = %exp:cLoja%
                                  AND LTRIM(RTRIM(E1_TIPO)) = 'PI-'
                ENDSQL
elseif _ctipo = 'COFINS'                
                BEGINSQL ALIAS cAlias
                               column VRET as Numeric(14,2)
                               SELECT coalesce(SUM(E1_VALOR),0) VRET
                                 FROM %table:SE1% SE1
                                WHERE SE1.%notdel%
                                  AND E1_PREFIXO = %exp:cPref%
                                  AND E1_NUM     = %exp:cNum%
                                  AND E1_CLIENTE = %exp:cCliente%
                                  AND E1_LOJA    = %exp:cLoja%     
                                  AND LTRIM(RTRIM(E1_TIPO)) = 'CF-'
                ENDSQL
elseif _ctipo = 'CSLL'       
                BEGINSQL ALIAS cAlias
                               column VRET as Numeric(14,2)
                               SELECT coalesce(SUM(E1_VALOR),0) VRET
                                 FROM %table:SE1% SE1
                                WHERE SE1.%notdel%
                                  AND E1_PREFIXO = %exp:cPref%
                                  AND E1_NUM     = %exp:cNum%
                                  AND E1_CLIENTE = %exp:cCliente%
                                  AND E1_LOJA    = %exp:cLoja%   
                                  AND LTRIM(RTRIM(E1_TIPO)) = 'CS-'
                ENDSQL
elseif _ctipo = 'IRRF'
                BEGINSQL ALIAS cAlias
                               column VRET as Numeric(14,2)
                               SELECT coalesce(SUM(E1_IRRF),0) VRET
                                 FROM %table:SE1% SE1
                                WHERE SE1.%notdel%
                                  AND E1_PREFIXO = %exp:cPref%
                                  AND E1_NUM     = %exp:cNum%
                                  AND E1_CLIENTE = %exp:cCliente%
                                  AND E1_LOJA    = %exp:cLoja%   
                ENDSQL
elseif _ctipo = 'INSS'      
                BEGINSQL ALIAS cAlias
                               column VRET as Numeric(14,2)
                               SELECT coalesce(SUM(E1_INSS),0) VRET
                                 FROM %table:SE1% SE1
                                WHERE SE1.%notdel%
                                  AND E1_PREFIXO = %exp:cPref%
                                  AND E1_NUM     = %exp:cNum%
                                  AND E1_CLIENTE = %exp:cCliente%
                                  AND E1_LOJA    = %exp:cLoja%   
                ENDSQL
endif                        


nRet := (cAlias)->VRET
(cAlias)->( dbCloseArea() )
restArea(aArea)

Return( nRet )
   
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºPrograma  ³ RCTBE002 º Autor ³ TBC-GO             º Data ³  10/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retorna os valores de retencao do PIS/COFINS/CSLL somente  º±±
±±º          ³ se foram retidos  pela BAIXA                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LP´s                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function RCTBE002(_ctipo)
Local nRet := 0, cAlias := getNextAlias(), aArea := getArea()
Local cNum := SE1->E1_NUM, cPref := SE1->E1_PREFIXO, cCliente := SE1->E1_CLIENTE, cLoja := SE1->E1_LOJA

_ctipo := Upper(_ctipo)
                      
if _ctipo = 'PIS'
                BEGINSQL ALIAS cAlias
                               column VRET as Numeric(14,2)
                               SELECT coalesce(SUM(E1_VALOR),0) VRET
                                 FROM %table:SE1% SE1
                                WHERE SE1.%notdel%
                                  AND E1_PREFIXO = %exp:cPref%
                                  AND E1_NUM     = %exp:cNum%
                                  AND E1_CLIENTE = %exp:cCliente%
                                  AND E1_LOJA    = %exp:cLoja%
                                  AND LTRIM(RTRIM(E1_TIPO)) = 'PIS'
                ENDSQL
elseif _ctipo = 'COFINS'                
                BEGINSQL ALIAS cAlias
                               column VRET as Numeric(14,2)
                               SELECT coalesce(SUM(E1_VALOR),0) VRET
                                 FROM %table:SE1% SE1
                                WHERE SE1.%notdel%
                                  AND E1_PREFIXO = %exp:cPref%
                                  AND E1_NUM     = %exp:cNum%
                                  AND E1_CLIENTE = %exp:cCliente%
                                  AND E1_LOJA    = %exp:cLoja%     
                                  AND LTRIM(RTRIM(E1_TIPO)) = 'COF'
                ENDSQL
elseif _ctipo = 'CSLL'       
                BEGINSQL ALIAS cAlias
                               column VRET as Numeric(14,2)
                               SELECT coalesce(SUM(E1_VALOR),0) VRET
                                 FROM %table:SE1% SE1
                                WHERE SE1.%notdel%
                                  AND E1_PREFIXO = %exp:cPref%
                                  AND E1_NUM     = %exp:cNum%
                                  AND E1_CLIENTE = %exp:cCliente%
                                  AND E1_LOJA    = %exp:cLoja%   
                                  AND LTRIM(RTRIM(E1_TIPO)) = 'CSL'
                ENDSQL
elseif _ctipo = 'IRRF'
                BEGINSQL ALIAS cAlias
                               column VRET as Numeric(14,2)
                               SELECT coalesce(SUM(E1_IRRF),0) VRET
                                 FROM %table:SE1% SE1
                                WHERE SE1.%notdel%
                                  AND E1_PREFIXO = %exp:cPref%
                                  AND E1_NUM     = %exp:cNum%
                                  AND E1_CLIENTE = %exp:cCliente%
                                  AND E1_LOJA    = %exp:cLoja%   
                ENDSQL
elseif _ctipo = 'INSS'      
                BEGINSQL ALIAS cAlias
                               column VRET as Numeric(14,2)
                               SELECT coalesce(SUM(E1_INSS),0) VRET
                                 FROM %table:SE1% SE1
                                WHERE SE1.%notdel%
                                  AND E1_PREFIXO = %exp:cPref%
                                  AND E1_NUM     = %exp:cNum%
                                  AND E1_CLIENTE = %exp:cCliente%
                                  AND E1_LOJA    = %exp:cLoja%   
                ENDSQL
endif                        


nRet := (cAlias)->VRET
(cAlias)->( dbCloseArea() )
restArea(aArea)

Return( nRet )

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ RetCtaST ¦ Autor ¦ Daniel Coelho      ¦ Data ¦  21/09/2012 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Rotina para retornar a cta contábil ICMS ST por estado     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ LP´s                                                       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

User Function RetCtaST(cID,cUF) 
Local cRet   
Local _cID := cID 
Local _aUF := {"AC" ,"AL" ,"AM" ,"AP" ,"BA" ,"CE" ,"DF" ,"ES" ,"GO" ,"MA" ,"MG" ,"MS" ,"MT" ,"PA" ,;
               "PB" ,"PE" ,"PI" ,"PR" ,"RJ" ,"RN" ,"RO" ,"RR" ,"RS" ,"SC" ,"SE" ,"SP" ,"TO"        }
Local _aID := {"070","071","072","073","074","075","076","077","078","079","080","081","082","083",;
               "084","085","086","087","088","089","090","091","092","093","094","095","096"       }
               
If ! SuperGetMV("MV_XICMSST",.F.,.T.)
   If (_nPos := aScan(_aUF, {|x| x[1]==cUF})) > 0
      _cID := _aID[_nPos]
   Endif
EndIf

cRet:=Posicione('ZC1',1,xFilial('ZC1')+_cID,'ZC1_CONTA')
If empty(cRet)
  cRet:='Cta vza id:'+_cID
endif  
  
Return cRet

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ RetForNf ¦ Autor ¦ Adriano Reis       ¦ Data ¦  09/04/2012 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Rotina para retornar a cta contábil Pessoa Fisica          ¦¦¦
¦¦¦Descriçào ¦ Retorna Tipo do Fornecedor NF caso seja Compensação.       ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ LP´s                                                       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

//Passando Parâmetro Fornecedor+Loja
User Function RetForNf(cForID) 
Local aArea    := getArea()
Local aAreaSA2 := SA2->(GetArea())
Local cRet

cRet := Posicione('SA2',1,xFilial('SA2')+cForID,'A2_TIPO')

If Empty(cRet)
  cRet := 'Fornec nf n enc:'+cID
Endif         

restArea(aArea)  
restArea(aAreaSA2)  

Return(cRet)


