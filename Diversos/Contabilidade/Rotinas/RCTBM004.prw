#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RCTBM004 บ Autor ณ Claudio Ferreira   บ Data ณ  20/07/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Programa para criar Mapa de Validacao dos LPดs             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TOTVS-GO                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function RCTBM004()
Local cQry := ''
Private cPerg        := "RCTBM004"

ValidPerg()          // Cria pergunta


if pergunte(cPerg,.T.)
	Processa({|| RunLP() },"Processando...")
endif
Return()

Static Function RunLP()
Local nCont:=0
Local cHTML:=''

nLctosOk:=MV_PAR03

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

cQry :="SELECT CT5_LANPAD,CT5_SEQUEN,CT5_DESC,CT5_DC,CT2_ORIGEM,COUNT(1) AS TOTAL"
cQry += " FROM "+RetSqlName("CT5")+" left join "+RetSqlName("CT2")+" on CT5_LANPAD=CT2_LP AND CT5_SEQUEN=SUBSTRING(CT2_ORIGEM,5,3) and "+RetSqlName("CT2")+".D_E_L_E_T_<>'*' 
cQry += " AND CT2_DATA BETWEEN '"+DTOS(MV_PAR01)+ "' AND '"+DTOS(MV_PAR02)+ "'"
cQry += " AND CT2_DC<>'4' "
cQry += " WHERE CT5_STATUS='1' " 
if mv_par04=1
  cQry += " AND CT5_ORIGEM NOT LIKE '%AUTO%' "
endif  
cQry += " AND "+RetSqlName("CT5")+".D_E_L_E_T_<>'*'" 
cQry += " GROUP BY CT5_LANPAD,CT5_SEQUEN,CT5_DESC,CT5_DC,CT2_ORIGEM"        
cQry += " ORDER BY CT5_LANPAD,CT5_SEQUEN,CT5_DESC,CT5_DC,CT2_ORIGEM"        
cQry := ChangeQuery(cQry)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), 'QRY', .F., .T.)

dbSelectArea("QRY")
dbEval({|| nCont++})
ProcRegua(nCont)
DBGotop()

cDirDocs:=MsDocPath()
cArq:="VLP.html"
If File(cDirDocs+"\"+cArq)
	ferase(cDirDocs+"\"+cArq)
EndIf
nhandle:=fcreate(cdirdocs+"\"+carq,0)
if nhandle != -1
	
	While !QRY->(Eof())
		IncProc()
		
		If Cab
			cDescr:=Posicione('CVA',1,xFilial('CVA')+QRY->CT5_LANPAD,'CVA_DESCRI')
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
			cHTML+='<h3><a>'+QRY->CT5_LANPAD+' - '+cEvento+'</a></h3>'
			cHTML+='<table class="MsoNormalTable" border="1" cellspacing="0" cellpadding="0" width="673" style="margin-left: 18.45pt; border-collapse: collapse; mso-table-layout-alt: fixed; border: none; mso-border-alt: solid windowtext .5pt; mso-yfti-tbllook: 480; mso-padding-alt: 0cm 5.4pt 0cm 5.4pt; mso-border-insideh: .5pt solid windowtext; mso-border-insidev: .5pt solid windowtext">'
			Cab:=.f.
			cLP:=QRY->CT5_LANPAD
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
		cHTML+='				<b>'+QRY->CT5_DESC+'</b><o:p></o:p></span></p>'
		cHTML+='				</td>'
		cHTML+='</tr>'

		cHTML+='<tr style="mso-yfti-irow: 0; mso-yfti-firstrow: yes; page-break-inside: avoid">'
		cHTML+='				<td width="46" style="width: 34.15pt; border: solid windowtext 1.0pt; mso-border-alt: solid windowtext .5pt; background: white; padding: 0cm 5.4pt 0cm 5.4pt">'
		cHTML+='				<p class="MsoNormal" align="center" style="text-align: center; mso-pagination: none; mso-layout-grid-align: none; text-autospace: none">'
		cHTML+='				<span style="font-size: 8.0pt; font-family: &quot;Tahoma&quot;,&quot;sans-serif&quot;">'
		cHTML+='				'+QRY->CT5_LANPAD+'<o:p></o:p></span></p>'
		cHTML+='				</td>'
		cHTML+='				<td width="39" colspan="2" style="width: 29.3pt; border: solid windowtext 1.0pt; border-left: none; mso-border-left-alt: solid windowtext .5pt; mso-border-alt: solid windowtext .5pt; background: white; padding: 0cm 5.4pt 0cm 5.4pt">'
		cHTML+='				<p class="MsoNormal" align="center" style="text-align: center; mso-pagination: none; mso-layout-grid-align: none; text-autospace: none">'
		cHTML+='				<span style="font-size: 8.0pt; font-family: &quot;Tahoma&quot;,&quot;sans-serif&quot;">'
		cHTML+='				'+QRY->CT5_SEQUEN+'<o:p></o:p></span></p>'
		cHTML+='				</td>'
		cHTML+='				<td width="70" style="width: 52.75pt; border: solid windowtext 1.0pt; border-left: none; mso-border-left-alt: solid windowtext .5pt; mso-border-alt: solid windowtext .5pt; background: white; padding: 0cm 5.4pt 0cm 5.4pt">'
		cHTML+='				<p class="MsoNormal" align="center" style="text-align: center; mso-pagination: none; mso-layout-grid-align: none; text-autospace: none">'
		cHTML+='				<span style="font-size: 8.0pt; font-family: &quot;Tahoma&quot;,&quot;sans-serif&quot;">'
		cTipo:=iif(QRY->CT5_DC='1','Debito',iif(QRY->CT5_DC='2','Credito','Partida dobrada'))
		cHTML+='				'+cTipo+'<o:p></o:p></span></p>'
		cHTML+='				</td>'
		cHTML+='				<td width="373" colspan="2" valign="top" style="width: 279.95pt; border-top: solid windowtext 1.0pt; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; mso-border-left-alt: solid windowtext .5pt; mso-border-top-alt: solid windowtext .5pt; mso-border-left-alt: solid windowtext .5pt; mso-border-right-alt: solid windowtext .5pt; background: white; padding: 0cm 5.4pt 0cm 5.4pt">'
		cHTML+='				<p class="MsoNormal" style="mso-pagination: none; mso-layout-grid-align: none; text-autospace: none">'
		cHTML+='				<span style="font-size: 8.0pt; font-family: &quot;Tahoma&quot;,&quot;sans-serif&quot;">'
		cHTML+='				'+QRY->CT2_ORIGEM+'<o:p></o:p></span></p>'
		cHTML+='				</td>'
		cHTML+='				<td width="144" style="width: 108.25pt; border: solid windowtext 1.0pt; border-left: none; mso-border-left-alt: solid windowtext .5pt; mso-border-alt: solid windowtext .5pt; padding: 0cm 5.4pt 0cm 5.4pt">'
		cHTML+='				<p class="MsoNormal" style="mso-pagination: none; mso-layout-grid-align: none; text-autospace: none">'
		cHTML+='				<span style="font-size: 8.0pt; font-family: &quot;Tahoma&quot;,&quot;sans-serif&quot;">'
		cHTML+='				No Lactos</span><span style="font-size: 8.0pt; font-family: &quot;Bell MT&quot;,&quot;serif&quot;; mso-bidi-font-family: Tahoma">'
		cHTML+='				</span><br>'
		cHTML+='				<span style="font-size: 6.0pt; font-family: &quot;Tahoma&quot;,&quot;sans-serif&quot;">'
		nLactos:=QRY->TOTAL
		if Empty(QRY->CT2_ORIGEM)
		  nLactos:=0
		endif  
		cValor:=Str(nLactos,6)
		cHTML+='				'+cValor+'</span><span style="font-size: 8.0pt; font-family: &quot;Tahoma&quot;,&quot;sans-serif&quot;"><o:p></o:p></span></p>'
		cHTML+='				</td>'   
		cHTML+='				</td>'
		cStatus:=''
		if nLactos=0 .and. mv_par05=2              
			cCor:='#808080'
			cStatus:='Nao Utiliza'
		elseif nLactos<(nLctosOk/2)		
			cCor:='#FF0000'
			if nLactos=0
			  cStatus:='Nao simulado'
			else
			  cStatus:='Pouco simulado'
			endif  
		elseif nLactos<nLctosOk
			cCor:='#FFFF00'
	 		cStatus:='Parcialmente validado'
		else
			cCor:='#008000'
			cStatus:='Validado'
		endif	
		cHTML+='				<td width="144" style="width: 108.25pt; border: solid windowtext 1.0pt; border-left: none; mso-border-left-alt: solid windowtext .5pt; mso-border-alt: solid windowtext .5pt;background-color: '+cCor+'; padding: 0cm 5.4pt 0cm 5.4pt">'
		cHTML+='				<p class="MsoNormal" style="mso-pagination: none; mso-layout-grid-align: none; text-autospace: none">'
		cHTML+='				<span style="font-size: 8.0pt; font-family: &quot;Tahoma&quot;,&quot;sans-serif&quot;">'
		cHTML+='				Situacao</span><span style="font-size: 8.0pt; font-family: &quot;Bell MT&quot;,&quot;serif&quot;; mso-bidi-font-family: Tahoma">'
		cHTML+='				</span><br>'
		cHTML+='				<span style="font-size: 6.0pt; font-family: &quot;Tahoma&quot;,&quot;sans-serif&quot;">'
		cValor:=cStatus 
		cHTML+='				'+cValor+'</span><span style="font-size: 8.0pt; font-family: &quot;Tahoma&quot;,&quot;sans-serif&quot;"><o:p></o:p></span></p>'
		cHTML+='				</td>'		
		cHTML+='</tr>'
		QRY->(dbSkip())
		if cLP<>QRY->CT5_LANPAD
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

QRY->(DbCloseArea())

Return

Static Function ValidPerg()
_sAlias	:=	Alias()
dbSelectArea("SX1")
dbSetOrder(1)
cPerg 	:=	PADR(cPerg,10)

putSx1(     cPerg,"01","Data De ?",			"."     ,"."       ,"mv_ch1","D",08,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","")
putSx1(     cPerg,"02","Data Ate ?",		"."     ,"."       ,"mv_ch2","D",08,0,0,"G","","","","","mv_par02","","","","","","","","","","","","","","","","")
putSx1(     cPerg,"03","Qtd Lctos ?",		"."     ,"."       ,"mv_ch3","N",02,0,0,"G","","","","","mv_par03","","","","","","","","","","","","","","","","")
putSx1(     cPerg,"04","LP Estorno?",		"."   	,"."       ,"mv_ch4","N",01,0,0,"C","","","","","mv_par04","1-Nใo","","","","2-Sim","","","","","","","","","","")
putSx1(     cPerg,"05","Zero Lacto?",		"."   	,"."       ,"mv_ch5","N",01,0,0,"C","","","","","mv_par05","1-Nใo Simulado","","","","2-Nใo Utiliza","","","","","","","","","","")

dbSelectArea(_sAlias)

Return
