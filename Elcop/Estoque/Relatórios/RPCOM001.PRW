/* Impressão de etiquetas  

Sinval 06/2021

*/

#Include 'Protheus.ch'
#INCLUDE "TBICONN.CH" 

User Function RPCOM001()

    Local cPorta    := "LPT1"
    Local cModelo   := "ZEBRA"

    MSCBPRINTER(cModelo, cPorta,,18,.F.,,,,,,.F.,)
    MSCBCHKSTATUS(.F.)

    MSCBBEGIN(1,6)

    MSCBSAY(05,01,"PENEIRA CLASS ACO SAE M.40 MM", "N","0","020,020")
    MSCBSAY(50,01,"PENEIRA CLASS ACO SAE M.40 MM", "N","0","020,020")

    MSCBSAY(05,04,"NF: 000000123", "N","0","020,020")
    MSCBSAY(50,04,"NF: 000000123", "N","0","020,020")

    MSCBSAY(05,07,"DT ENT: 26/04/2021", "N","0","020,020")
    MSCBSAY(50,07,"DT ENT: 26/04/2021", "N","0","020,020")

    MSCBEND()

    MSCBCLOSEPRINTER()

Return

/*
oPrint := TMSPrinter():New("Etiquetas de Produtos")
oPrint:Setup()
oPrint:SetPortrait()
// Fonte Tamanho Negrito
oFont8 := TFont():New("Arial", 9, 08, .T., .F., 5,,, .T., .F.,,,,,, oPrint)
oFont8n := TFont():New("Arial", 9, 08, .T., .T., 5,,, .T., .F.,,,,,, oPrint)
oFont9 := TFont():New("Arial", 9, 09, .T., .F., 5,,, .T., .F.,,,,,, oPrint)
oFont9n := TFont():New("Arial", 9, 09, .T., .T., 5,,, .T., .F.,,,,,, oPrint)
oFont10 := TFont():New("Arial", 9, 10, .T., .F., 5,,, .T., .F.,,,,,, oPrint)
oFont10n := TFont():New("Arial", 9, 10, .T., .T., 5,,, .T., .F.,,,,,, oPrint)
oFont12 := TFont():New("Arial", 9, 12, .T., .F., 5,,, .T., .F.,,,,,, oPrint)
oFont12n := TFont():New("Arial", 9, 12, .T., .T., 5,,, .T., .F.,,,,,, oPrint)
oFont13 := TFont():New("Arial", 9, 13, .T., .F., 5,,, .T., .F.,,,,,, oPrint)
oFont13n := TFont():New("Arial", 9, 13, .T., .T., 5,,, .T., .F.,,,,,, oPrint)
oFont14 := TFont():New("Arial", 9, 14, .T., .F., 5,,, .T., .F.,,,,,, oPrint)
oFont14n := TFont():New("Arial", 9, 14, .T., .T., 5,,, .T., .F.,,,,,, oPrint)
oFont16 := TFont():New("Arial", 9, 16, .T., .F., 5,,, .T., .F.,,,,,, oPrint)
oFont16n := TFont():New("Arial", 9, 16, .T., .T., 5,,, .T., .F.,,,,,, oPrint)
oFont18 := TFont():New("Arial", 9, 18, .T., .F., 5,,, .T., .F.,,,,,, oPrint)
oFont18n := TFont():New("Arial", 9, 18, .T., .T., 5,,, .T., .F.,,,,,, oPrint)
oFont24 := TFont():New("Arial", 9, 24, .T., .F., 5,,, .T., .F.,,,,,, oPrint)
oFont24n := TFont():New("Arial", 9, 24, .T., .T., 5,,, .T., .F.,,,,,, oPrint)
//
oBrush := TBrush():New("", 4)
//

oPrint:StartPage()

nLinha := 003 // Linha InItemcial em Pixels
nColuna := 010 // Coluna InItemcial em Pixels

oPrint:sayBitmap(nLinha,nColuna,"GABITEC.bmp",330,120)


cDesc := AllTrim(SB1->B1_COD)+' - ' + SB1->B1_DESC
nLinha := 060
For nx:=1 to MlCount(cDesc,30)
oPrint:Say(nLinha,400,MemoLine(cDesc,30,nx),oFont12n,,0)
nLinha += 60
Next

nLinha += 080
oPrint:Say(nLinha, nColuna, SC5->C5_CLIENTE+'/'+SC5->C5_LOJACLI+' - ' + Capital(Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NOME")), oFont10n)

nLinha += 070
oPrint:Say(nLinha, nColuna, "Fone:", oFont10)
oPrint:Say(nLinha, nColuna+100, SA1->A1_DDD + ' ' + SA1->A1_TEL, oFont10n)
If Empty(SC5->C5_NOTA)
oPrint:Say(nLinha, nColuna+400, "Pedido:", oFont10)
oPrint:Say(nLinha, nColuna+530, SC5->C5_NUM, oFont10n)
Else
oPrint:Say(nLinha, nColuna+400, "Nota:", oFont10)
oPrint:Say(nLinha, nColuna+530, SC5->C5_NOTA+'/'+SC5->C5_SERIE, oFont10n)
Endif
oPrint:Say(nLinha, nColuna+800, "Peso:", oFont10)
oPrint:Say(nLinha, nColuna+900, TransForm(Round(xCols[nItem,5]*SB1->B1_PESO,4),"@E 99,999.9999"), oFont10n)

nLinha += 060
oPrint:Say(nLinha, nColuna, "Unidade:", oFont10)
oPrint:Say(nLinha, nColuna+160, SB1->B1_UM, oFont10n)

oPrint:Say(nLinha, nColuna + 300, "Qtde:", oFont10)

 

oPrint:Say(nLinha, nColuna+400, TransForm(xCols[nItem,5],PesqPict("SC6","C6_QTDVEN")), oFont10n)
nLinha += 060
oPrint:Say(nLinha, nColuna, "No Pedido Cliente:", oFont10)
oPrint:Say(nLinha, nColuna+300, SC5->C5_PEDCLI, oFont10n)
nLinha += 060
oPrint:Say(nLinha, nColuna, "Cód.Prod.Cliente::", oFont10)
If SA7->(dbSetOrder(2), dbSeek(xFilial("SA7")+SB1->B1_COD+SC5->C5_CLIENTE+SC5->C5_LOJACLI))
oPrint:Say(nLinha, nColuna+300, SA7->A7_CODCLI, oFont10n)
Endif
cCodBar := Iif(!Empty(SB1->B1_CODBAR),SB1->B1_CODBAR,'7898472230017')

*/
// MSBAR("EAN13" ,4.6,8.5,cCodBar,oPrint,/*lCheck*/,/*Color*/,/*lHorz*/,nItemL,1,.F.,nItemL,nItemL,.F.)
// MsBar("EAN13" ,3.6,5.5,cCodBar,oPrint,.F.,,,0.040,1.0,,,,.T.)
//MSBAR("INT25" ,3.6,5.5,Alltrim(cCodBar),oPrint,.F.,,.T.,0.028,0.9,,,"A",.F.) // Tiago se vira

//oPrint:EndPage()

