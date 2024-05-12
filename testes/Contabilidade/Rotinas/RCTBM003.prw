#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RCTBM003 บ Autor ณ Claudio Ferreira   บ Data ณ  16/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Programa para criar documenta็ใo dos LPดs                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TOTVS-GO                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function RCTBM003()
Local cQry := ''

if msgyesno("Confirma o processamento dos LPดs Contabeis?")
	Processa({|| RunLP() },"Processando...")
endif
Return()

Static Function RunLP()
Local nCont:=0
Local cHTML:=''

cHTML+='<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
cHTML+='<html xmlns="http://www.w3.org/1999/xhtml" xmlns:m="http://schemas.microsoft.com/office/2004/12/omml" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office">'
cHTML+='<head>'
cHTML+='<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />'
cHTML+='<title>Contas a Receber</title>'
cHTML+='<style type="text/css">'
cHTML+='h2'
cHTML+='	{margin-top:6.0pt;'
cHTML+='	margin-right:0cm;'
cHTML+='	margin-bottom:3.0pt;'
cHTML+='	margin-left:0cm;'
cHTML+='	page-break-after:avoid;'
cHTML+='	font-size:14.0pt;'
cHTML+='	font-family:"Arial","sans-serif";'
cHTML+='	}'
cHTML+='h3'
cHTML+='	{margin-top:6.0pt;'
cHTML+='	margin-right:0cm;'
cHTML+='	margin-bottom:3.0pt;'
cHTML+='	margin-left:36.0pt;'
cHTML+='	page-break-after:avoid;'
cHTML+='	font-size:12.0pt;'
cHTML+='	font-family:"Arial","sans-serif";'
cHTML+='	font-style:italic;'
cHTML+='	}'
cHTML+=' table.MsoNormalTable'
cHTML+='	{font-size:11.0pt;'
cHTML+='	font-family:"Calibri","sans-serif";'
cHTML+='	}'
cHTML+=' p.MsoNormal'
cHTML+='	{margin-bottom:.0001pt;'
cHTML+='	font-size:12.0pt;'
cHTML+='	font-family:"Times New Roman","serif";'
cHTML+='	margin-left: 0cm;'
cHTML+='	margin-right: 0cm;'
cHTML+='	margin-top: 0cm;'
cHTML+='}'
cHTML+='</style>'
cHTML+='</head>'
cHTML+='<body>'

Cab:=.t.  
CabMod:=''

dbSelectArea("CT5")
dbSetOrder(1)

DBGotop()
dbEval({|| nCont++})
ProcRegua(nCont)
DBGotop()

cDirDocs:=MsDocPath()
cArq:="LP.html"
If File(cDirDocs+"\"+cArq)
	ferase(cDirDocs+"\"+cArq)
EndIf
nhandle:=fcreate(cdirdocs+"\"+carq,0)
if nhandle != -1
	
	While !CT5->(Eof())
		IncProc()
		if CT5_STATUS='2'
			dbSkip()
			loop
		endif
		If Cab
			cDescr:=Posicione('CVA',1,xFilial('CVA')+CT5_LANPAD,'CVA_DESCRI')
			nPos:=At('-',cDescr)
			if Empty(cDescr)
				cDescr:='Especificos'
			endif
			if nPos>0
				cModulo:=Substr(cDescr,1,nPos-1)
				cEvento:=Substr(cDescr,nPos+1)
			else
				cModulo:=''
				cEvento:=cDescr
			endif
			if CabMod<>cModulo
			  cHTML+='<h2><a>'+cModulo+'</a></h2>'
			  CabMod:=cModulo
			endif  
			cHTML+='<h3><a>'+CT5_LANPAD+' - '+cEvento+'</a></h3>'
			cHTML+='<table class="MsoNormalTable" border="1" cellspacing="0" cellpadding="0" width="673" style="margin-left: 18.45pt; border-collapse: collapse; mso-table-layout-alt: fixed; border: none; mso-border-alt: solid windowtext .5pt; mso-yfti-tbllook: 480; mso-padding-alt: 0cm 5.4pt 0cm 5.4pt; mso-border-insideh: .5pt solid windowtext; mso-border-insidev: .5pt solid windowtext">'
			Cab:=.f.
			cLP:=CT5_LANPAD
		EndIf

		cHTML+='<tr style="mso-yfti-irow: 10; mso-yfti-lastrow: yes; page-break-inside: avoid">'
		cHTML+='				<td width="59" colspan="2" valign="top" style="width: 44.05pt; border: solid windowtext 1.0pt; mso-border-top-alt: solid windowtext .5pt; mso-border-alt: solid windowtext .5pt; background: white; padding: 0cm 5.4pt 0cm 5.4pt">'
		cHTML+='				<p class="MsoNormal" style="mso-pagination: none; mso-layout-grid-align: none; text-autospace: none">'
		cHTML+='				<span style="font-size: 8.0pt; font-family: &quot;Tahoma&quot;,&quot;sans-serif&quot;">'
		cHTML+='				Lancamento<o:p></o:p></span></p>'
		cHTML+='				</td>'
		cHTML+='				<td width="614" colspan="6" valign="top" style="width: 460.35pt; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; mso-border-top-alt: solid windowtext .5pt; mso-border-left-alt: solid windowtext .5pt; mso-border-alt: solid windowtext .5pt; background: white; padding: 0cm 5.4pt 0cm 5.4pt">'
		cHTML+='				<p class="MsoNormal" style="mso-pagination: none; mso-layout-grid-align: none; text-autospace: none">'
		cHTML+='				<span style="font-size: 8.0pt; font-family: &quot;Tahoma&quot;,&quot;sans-serif&quot;">'
		cHTML+='				<b>'+CT5_DESC+'</b><o:p></o:p></span></p>'
		cHTML+='				</td>'
		cHTML+='</tr>'

		cHTML+='<tr style="mso-yfti-irow: 0; mso-yfti-firstrow: yes; page-break-inside: avoid">'
		cHTML+='				<td width="46" rowspan="'+iif(CT5_DC='3','8','4')+'" style="width: 34.15pt; border: solid windowtext 1.0pt; mso-border-alt: solid windowtext .5pt; background: white; padding: 0cm 5.4pt 0cm 5.4pt">'
		cHTML+='				<p class="MsoNormal" align="center" style="text-align: center; mso-pagination: none; mso-layout-grid-align: none; text-autospace: none">'
		cHTML+='				<span style="font-size: 8.0pt; font-family: &quot;Tahoma&quot;,&quot;sans-serif&quot;">'
		cHTML+='				'+CT5_LANPAD+'<o:p></o:p></span></p>'
		cHTML+='				</td>'
		cHTML+='				<td width="39" colspan="2" rowspan="'+iif(CT5_DC='3','8','4')+'" style="width: 29.3pt; border: solid windowtext 1.0pt; border-left: none; mso-border-left-alt: solid windowtext .5pt; mso-border-alt: solid windowtext .5pt; background: white; padding: 0cm 5.4pt 0cm 5.4pt">'
		cHTML+='				<p class="MsoNormal" align="center" style="text-align: center; mso-pagination: none; mso-layout-grid-align: none; text-autospace: none">'
		cHTML+='				<span style="font-size: 8.0pt; font-family: &quot;Tahoma&quot;,&quot;sans-serif&quot;">'
		cHTML+='				'+CT5_SEQUEN+'<o:p></o:p></span></p>'
		cHTML+='				</td>'
		cHTML+='				<td width="70" rowspan="'+iif(CT5_DC='3','8','4')+'" style="width: 52.75pt; border: solid windowtext 1.0pt; border-left: none; mso-border-left-alt: solid windowtext .5pt; mso-border-alt: solid windowtext .5pt; background: white; padding: 0cm 5.4pt 0cm 5.4pt">'
		cHTML+='				<p class="MsoNormal" align="center" style="text-align: center; mso-pagination: none; mso-layout-grid-align: none; text-autospace: none">'
		cHTML+='				<span style="font-size: 8.0pt; font-family: &quot;Tahoma&quot;,&quot;sans-serif&quot;">'
		cTipo:=iif(CT5_DC='1','Debito',iif(CT5_DC='2','Credito','Partida dobrada'))
		cHTML+='				'+cTipo+'<o:p></o:p></span></p>'
		cHTML+='				</td>'
		cHTML+='				<td width="373" colspan="3" valign="top" style="width: 279.95pt; border-top: solid windowtext 1.0pt; border-left: none; border-bottom: none; border-right: solid windowtext 1.0pt; mso-border-left-alt: solid windowtext .5pt; mso-border-top-alt: solid windowtext .5pt; mso-border-left-alt: solid windowtext .5pt; mso-border-right-alt: solid windowtext .5pt; background: white; padding: 0cm 5.4pt 0cm 5.4pt">'
		cHTML+='				<p class="MsoNormal" style="mso-pagination: none; mso-layout-grid-align: none; text-autospace: none">'
		cHTML+='				<span style="font-size: 8.0pt; font-family: &quot;Tahoma&quot;,&quot;sans-serif&quot;">'
		if CT5_DC$'1/3'
			cCDeb:=StrQuebra(CT5_DEBITO,50)
			cHTML+='				Debito: '+cCDeb+'<o:p></o:p></span></p>'
		else
			cCCre:=StrQuebra(CT5_CREDIT,50)
			cHTML+='				Credito: '+cCCre+'<o:p></o:p></span></p>'
		endif
		cHTML+='				</td>'
		cHTML+='				<td width="144" rowspan="'+iif(CT5_DC='3','8','4')+'" style="width: 108.25pt; border: solid windowtext 1.0pt; border-left: none; mso-border-left-alt: solid windowtext .5pt; mso-border-alt: solid windowtext .5pt; background: white; padding: 0cm 5.4pt 0cm 5.4pt">'
		cHTML+='				<p class="MsoNormal" style="mso-pagination: none; mso-layout-grid-align: none; text-autospace: none">'
		cHTML+='				<span style="font-size: 8.0pt; font-family: &quot;Tahoma&quot;,&quot;sans-serif&quot;">'
		cHTML+='				Valor</span><span style="font-size: 8.0pt; font-family: &quot;Bell MT&quot;,&quot;serif&quot;; mso-bidi-font-family: Tahoma">'
		cHTML+='				</span><br>'
		cHTML+='				<span style="font-size: 6.0pt; font-family: &quot;Tahoma&quot;,&quot;sans-serif&quot;">'
		cValor:=StrQuebra(CT5_VLR01,60)
		cHTML+='				'+cValor+'</span><span style="font-size: 8.0pt; font-family: &quot;Tahoma&quot;,&quot;sans-serif&quot;"><o:p></o:p></span></p>'
		cHTML+='				</td>'
		cHTML+='</tr>'
		cHTML+='<tr style="mso-yfti-irow: 1; page-break-inside: avoid">'
		cHTML+='				<td width="16" valign="top" style="width: 11.8pt; border: none; mso-border-left-alt: solid windowtext .5pt; background: white; padding: 0cm 5.4pt 0cm 5.4pt">'
		cHTML+='				<p class="MsoNormal" style="mso-pagination: none; mso-layout-grid-align: none; text-autospace: none">'
		cHTML+='				<span style="font-size: 8.0pt; font-family: &quot;Tahoma&quot;,&quot;sans-serif&quot;"><o:p>'
		cHTML+='				&nbsp;</o:p></span></p>'
		cHTML+='				</td>'
		cHTML+='				<td width="39" valign="top" style="width: 29.05pt; border: none; background: white; padding: 0cm 5.4pt 0cm 5.4pt">'
		cHTML+='				<p class="MsoNormal" style="mso-pagination: none; mso-layout-grid-align: none; text-autospace: none">'
		cHTML+='				<span style="font-size: 8.0pt; font-family: &quot;Tahoma&quot;,&quot;sans-serif&quot;">'
		cHTML+='				CC<o:p></o:p></span></p>'
		cHTML+='				</td>'
		cHTML+='				<td width="319" valign="top" style="width: 239.1pt; border: none; border-right: solid windowtext 1.0pt; mso-border-right-alt: solid windowtext .5pt; background: white; padding: 0cm 5.4pt 0cm 5.4pt">'
		cHTML+='				<p class="MsoNormal" style="mso-pagination: none; mso-layout-grid-align: none; text-autospace: none">'
		cHTML+='				<span style="font-size: 8.0pt; font-family: &quot;Tahoma&quot;,&quot;sans-serif&quot;"><o:p>'
		if CT5_DC$'1/3'
			cHTML+='				'+CT5_CCD+'</o:p></span></p>'
		else
			cHTML+='				'+CT5_CCC+'</o:p></span></p>'
		endif
		cHTML+='				</td>'
		cHTML+='</tr>'
		cHTML+='<tr style="mso-yfti-irow: 2; page-break-inside: avoid">'
		cHTML+='				<td width="16" valign="top" style="width: 11.8pt; border: none; mso-border-left-alt: solid windowtext .5pt; background: white; padding: 0cm 5.4pt 0cm 5.4pt">'
		cHTML+='				<p class="MsoNormal" style="mso-pagination: none; mso-layout-grid-align: none; text-autospace: none">'
		cHTML+='				<span style="font-size: 8.0pt; font-family: &quot;Tahoma&quot;,&quot;sans-serif&quot;"><o:p>'
		cHTML+='				&nbsp;</o:p></span></p>'
		cHTML+='				</td>'
		cHTML+='				<td width="39" valign="top" style="width: 29.05pt; border: none; background: white; padding: 0cm 5.4pt 0cm 5.4pt">'
		cHTML+='				<p class="MsoNormal" style="mso-pagination: none; mso-layout-grid-align: none; text-autospace: none">'
		cHTML+='				<span style="font-size: 8.0pt; font-family: &quot;Tahoma&quot;,&quot;sans-serif&quot;">'
		cHTML+='				IC<o:p></o:p></span></p>'
		cHTML+='				</td>'
		cHTML+='				<td width="319" valign="top" style="width: 239.1pt; border: none; border-right: solid windowtext 1.0pt; mso-border-right-alt: solid windowtext .5pt; background: white; padding: 0cm 5.4pt 0cm 5.4pt">'
		cHTML+='				<p class="MsoNormal" style="mso-pagination: none; mso-layout-grid-align: none; text-autospace: none">'
		cHTML+='				<span style="font-size: 8.0pt; font-family: &quot;Tahoma&quot;,&quot;sans-serif&quot;"><o:p>'
		if CT5_DC$'1/3'
			cHTML+='				'+CT5_ITEMD+'</o:p></span></p>'
		else
			cHTML+='				'+CT5_ITEMC+'</o:p></span></p>'
		endif
		cHTML+='				</td>'
		cHTML+='</tr>'
		cHTML+='<tr style="mso-yfti-irow: 3; page-break-inside: avoid">'
		cHTML+='				<td width="16" valign="top" style="width: 11.8pt; border: none; border-bottom: solid windowtext 1.0pt; mso-border-left-alt: solid windowtext .5pt; mso-border-left-alt: solid windowtext .5pt; mso-border-bottom-alt: solid windowtext .5pt; background: white; padding: 0cm 5.4pt 0cm 5.4pt">'
		cHTML+='				<p class="MsoNormal" style="mso-pagination: none; mso-layout-grid-align: none; text-autospace: none">'
		cHTML+='				<span style="font-size: 8.0pt; font-family: &quot;Tahoma&quot;,&quot;sans-serif&quot;"><o:p>'
		cHTML+='				&nbsp;</o:p></span></p>'
		cHTML+='				</td>'
		cHTML+='				<td width="39" valign="top" style="width: 29.05pt; border: none; border-bottom: solid windowtext 1.0pt; mso-border-bottom-alt: solid windowtext .5pt; background: white; padding: 0cm 5.4pt 0cm 5.4pt">'
		cHTML+='				<p class="MsoNormal" style="mso-pagination: none; mso-layout-grid-align: none; text-autospace: none">'
		cHTML+='				<span style="font-size: 8.0pt; font-family: &quot;Tahoma&quot;,&quot;sans-serif&quot;">'
		cHTML+='				CV<o:p></o:p></span></p>'
		cHTML+='				</td>'
		cHTML+='				<td width="319" valign="top" style="width: 239.1pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; mso-border-bottom-alt: solid windowtext .5pt; mso-border-right-alt: solid windowtext .5pt; background: white; padding: 0cm 5.4pt 0cm 5.4pt">'
		cHTML+='				<p class="MsoNormal" style="mso-pagination: none; mso-layout-grid-align: none; text-autospace: none">'
		cHTML+='				<span style="font-size: 8.0pt; font-family: &quot;Tahoma&quot;,&quot;sans-serif&quot;"><o:p>'
		if CT5_DC$'1/3'
			cHTML+='				'+CT5_CLVLDB+'</o:p></span></p>'
		else
			cHTML+='				'+CT5_CLVLCR+'</o:p></span></p>'
		endif
		cHTML+='				</td>'
		cHTML+='</tr>'
		if CT5_DC$'3'
			cHTML+='<tr style="mso-yfti-irow: 4; page-break-inside: avoid">'
			cHTML+='				<td width="373" colspan="3" valign="top" style="width: 279.95pt; border: none; border-right: solid windowtext 1.0pt; mso-border-top-alt: solid windowtext .5pt; mso-border-left-alt: solid windowtext .5pt; mso-border-top-alt: solid windowtext .5pt; mso-border-left-alt: solid windowtext .5pt; mso-border-right-alt: solid windowtext .5pt; background: white; padding: 0cm 5.4pt 0cm 5.4pt">'
			cHTML+='				<p class="MsoNormal" style="mso-pagination: none; mso-layout-grid-align: none; text-autospace: none">'
			cHTML+='				<span style="font-size: 8.0pt; font-family: &quot;Tahoma&quot;,&quot;sans-serif&quot;; color: black">'
			cHTML+='				Credito: </span>'
			cHTML+='				<span style="font-size: 8.0pt; font-family: &quot;Tahoma&quot;,&quot;sans-serif&quot;">'
			cCCre:=StrQuebra(CT5_CREDIT,50)
			cHTML+='				'+cCCre+'<span style="color: black"><o:p></o:p></span></span></p>'
			cHTML+='				</td>'
			cHTML+='</tr>'
			cHTML+='<tr style="mso-yfti-irow: 5; page-break-inside: avoid">'
			cHTML+='				<td width="16" valign="top" style="width: 11.8pt; border: none; mso-border-left-alt: solid windowtext .5pt; background: white; padding: 0cm 5.4pt 0cm 5.4pt">'
			cHTML+='				<p class="MsoNormal" style="mso-pagination: none; mso-layout-grid-align: none; text-autospace: none">'
			cHTML+='				<span style="font-size: 8.0pt; font-family: &quot;Tahoma&quot;,&quot;sans-serif&quot;"><o:p>'
			cHTML+='				&nbsp;</o:p></span></p>'
			cHTML+='				</td>'
			cHTML+='				<td width="39" valign="top" style="width: 29.05pt; border: none; background: white; padding: 0cm 5.4pt 0cm 5.4pt">'
			cHTML+='				<p class="MsoNormal" style="mso-pagination: none; mso-layout-grid-align: none; text-autospace: none">'
			cHTML+='				<span style="font-size: 8.0pt; font-family: &quot;Tahoma&quot;,&quot;sans-serif&quot;">''
			cHTML+='				CC  <o:p></o:p></span></p>'
			cHTML+='				</td>'
			cHTML+='				<td width="319" valign="top" style="width: 239.1pt; border: none; border-right: solid windowtext 1.0pt; mso-border-right-alt: solid windowtext .5pt; background: white; padding: 0cm 5.4pt 0cm 5.4pt">'
			cHTML+='				<p class="MsoNormal" style="mso-pagination: none; mso-layout-grid-align: none; text-autospace: none">'
			cHTML+='				<span style="font-size: 8.0pt; font-family: &quot;Tahoma&quot;,&quot;sans-serif&quot;"><o:p>'
			cHTML+='				'+CT5_CCC+'</o:p></span></p>'
			cHTML+='				</td>'
			cHTML+='</tr>'
			cHTML+='<tr style="mso-yfti-irow: 6; page-break-inside: avoid">'
			cHTML+='				<td width="16" valign="top" style="width: 11.8pt; border: none; mso-border-left-alt: solid windowtext .5pt; background: white; padding: 0cm 5.4pt 0cm 5.4pt">'
			cHTML+='				<p class="MsoNormal" style="mso-pagination: none; mso-layout-grid-align: none; text-autospace: none">'
			cHTML+='				<span style="font-size: 8.0pt; font-family: &quot;Tahoma&quot;,&quot;sans-serif&quot;"><o:p>'
			cHTML+='				&nbsp;</o:p></span></p>'
			cHTML+='				</td>'
			cHTML+='				<td width="39" valign="top" style="width: 29.05pt; border: none; background: white; padding: 0cm 5.4pt 0cm 5.4pt">'
			cHTML+='				<p class="MsoNormal" style="mso-pagination: none; mso-layout-grid-align: none; text-autospace: none">'
			cHTML+='				<span style="font-size: 8.0pt; font-family: &quot;Tahoma&quot;,&quot;sans-serif&quot;">'
			cHTML+='				IC<o:p></o:p></span></p>'
			cHTML+='				</td>'
			cHTML+='				<td width="319" valign="top" style="width: 239.1pt; border: none; border-right: solid windowtext 1.0pt; mso-border-right-alt: solid windowtext .5pt; background: white; padding: 0cm 5.4pt 0cm 5.4pt">'
			cHTML+='				<p class="MsoNormal" style="mso-pagination: none; mso-layout-grid-align: none; text-autospace: none">'
			cHTML+='				<span style="font-size: 8.0pt; font-family: &quot;Tahoma&quot;,&quot;sans-serif&quot;; color: black">'
			cHTML+='				'+CT5_ITEMC+'<o:p></o:p></span></p>'
			cHTML+='				</td>'
			cHTML+='</tr>'
			cHTML+='<tr style="mso-yfti-irow: 7; page-break-inside: avoid">'
			cHTML+='				<td width="16" valign="top" style="width: 11.8pt; border: none; border-bottom: solid windowtext 1.0pt; mso-border-left-alt: solid windowtext .5pt; mso-border-left-alt: solid windowtext .5pt; mso-border-bottom-alt: solid windowtext .5pt; background: white; padding: 0cm 5.4pt 0cm 5.4pt">'
			cHTML+='				<p class="MsoNormal" style="mso-pagination: none; mso-layout-grid-align: none; text-autospace: none">'
			cHTML+='				<span style="font-size: 8.0pt; font-family: &quot;Tahoma&quot;,&quot;sans-serif&quot;"><o:p>'
			cHTML+='				&nbsp;</o:p></span></p>'
			cHTML+='				</td>'
			cHTML+='				<td width="39" valign="top" style="width: 29.05pt; border: none; border-bottom: solid windowtext 1.0pt; mso-border-bottom-alt: solid windowtext .5pt; background: white; padding: 0cm 5.4pt 0cm 5.4pt">'
			cHTML+='				<p class="MsoNormal" style="mso-pagination: none; mso-layout-grid-align: none; text-autospace: none">'
			cHTML+='				<span style="font-size: 8.0pt; font-family: &quot;Tahoma&quot;,&quot;sans-serif&quot;">'
			cHTML+='				CV<o:p></o:p></span></p>'
			cHTML+='				</td>'
			cHTML+='				<td width="319" valign="top" style="width: 239.1pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; mso-border-bottom-alt: solid windowtext .5pt; mso-border-right-alt: solid windowtext .5pt; background: white; padding: 0cm 5.4pt 0cm 5.4pt">'
			cHTML+='				<p class="MsoNormal" style="mso-pagination: none; mso-layout-grid-align: none; text-autospace: none">'
			cHTML+='				<span style="font-size: 8.0pt; font-family: &quot;Tahoma&quot;,&quot;sans-serif&quot;"><o:p>'
			cHTML+='				'+CT5_CLVLCR+'</o:p></span></p>'
			cHTML+='				</td>'
			cHTML+='</tr>'
		endif
		cHTML+='<tr style="mso-yfti-irow: 8; page-break-inside: avoid">'
		cHTML+='				<td width="59" colspan="2" valign="top" style="width: 44.05pt; border: solid windowtext 1.0pt; border-top: none; mso-border-top-alt: solid windowtext .5pt; mso-border-alt: solid windowtext .5pt; background: white; padding: 0cm 5.4pt 0cm 5.4pt">'
		cHTML+='				<p class="MsoNormal" style="mso-pagination: none; mso-layout-grid-align: none; text-autospace: none">'
		cHTML+='				<span style="font-size: 8.0pt; font-family: &quot;Tahoma&quot;,&quot;sans-serif&quot;">'
		cHTML+='				Historico<o:p></o:p></span></p>'
		cHTML+='				</td>'
		cHTML+='				<td width="614" colspan="6" valign="top" style="width: 460.35pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; mso-border-top-alt: solid windowtext .5pt; mso-border-left-alt: solid windowtext .5pt; mso-border-alt: solid windowtext .5pt; background: white; padding: 0cm 5.4pt 0cm 5.4pt">'
		cHTML+='				<p class="MsoNormal" style="mso-pagination: none; mso-layout-grid-align: none; text-autospace: none">'
		cHTML+='				<span style="font-size: 8.0pt; font-family: &quot;Tahoma&quot;,&quot;sans-serif&quot;">'
		//cHist:=StrQuebra(CT5_HIST,80)
		cHist:=CT5_HIST
		cHTML+='		     	'+cHist+'<o:p></o:p></span></p>'
		cHTML+='				</td>'
		cHTML+='</tr>'
		cHTML+='<tr style="mso-yfti-irow: 9; page-break-inside: avoid">'
		cHTML+='				<td width="59" colspan="2" valign="top" style="width: 44.05pt; border: solid windowtext 1.0pt; border-top: none; mso-border-top-alt: solid windowtext .5pt; mso-border-alt: solid windowtext .5pt; background: white; padding: 0cm 5.4pt 0cm 5.4pt">'
		cHTML+='				<p class="MsoNormal" style="mso-pagination: none; mso-layout-grid-align: none; text-autospace: none">'
		cHTML+='				<span style="font-size: 8.0pt; font-family: &quot;Tahoma&quot;,&quot;sans-serif&quot;">'
		cHTML+='				Origem<o:p></o:p></span></p>'
		cHTML+='				</td>'
		cHTML+='				<td width="614" colspan="6" valign="top" style="width: 460.35pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; mso-border-top-alt: solid windowtext .5pt; mso-border-left-alt: solid windowtext .5pt; mso-border-alt: solid windowtext .5pt; background: white; padding: 0cm 5.4pt 0cm 5.4pt">'
		cHTML+='				<p class="MsoNormal" style="mso-pagination: none; mso-layout-grid-align: none; text-autospace: none">'
		cHTML+='				<span style="font-size: 8.0pt; font-family: &quot;Tahoma&quot;,&quot;sans-serif&quot;">'
		cHTML+='				'+CT5_ORIGEM+'<o:p></o:p></span></p>'
		cHTML+='				</td>'
		cHTML+='</tr>'
		
		dbSelectArea("CT5")
		CT5->(dbSkip())
		if cLP<>CT5_LANPAD
			cHTML+='</table>'
			Cab:=.t.
			fwrite(nhandle,cHTML+chr(13)+chr(10))
			cHTML:=''
		endif
	EndDo
	
	cHTML+='</body>'
	cHTML+='</html>'
	fwrite(nhandle,cHTML+chr(13)+chr(10))
	fclose(nhandle)
	//cpathtmp:=alltrim('d:\')
	cpathtmp:=alltrim(gettemppath())
	If File(cpathtmp+cArq)
		ferase(cpathtmp+cArq)
	EndIf
	cpys2t(cDirDocs+"\"+cArq,cPathtmp,.t.)
	shellexecute("open",cArq,"",cpathtmp,1)
Endif

Return

Static Function StrQuebra(cStr,nTam)
Local cString:=''
Local cTexto:=cStr
While !Empty(cTexto)
	cString+=Substr(cTexto,1,nTam)+'<br>'
	cTexto:=Substr(cTexto,nTam+1)
Enddo
Return cString
