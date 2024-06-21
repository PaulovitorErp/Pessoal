#include "rwmake.ch"
#include "topconn.ch"
#include "colors.ch"
#include "tbiconn.ch"

User Function WF013()

Local oProcess
Local cHtml   := "\workflow\WF013A.htm"
Local cMail,lFirst,cTabela := ""
Local cGar := ""

WFPrepEnv("02", "00")

oProcess := TWFProcess():New("CtExp","Contrato de Experiencia")
oProcess:NewTask("CtExp",cHtml)
oHtml := oProcess:oHtml
oProcess:cSubject := "Vencimento do contrato de experiência - 1o Periodo"

cQuery := " SELECT RA_NOME,RA_MAT,RA_ADMISSA,RA_VCTOEXP'FIM',ISNULL(LOWER(B.A9_EMAIL),'')A9_EMAIL,ISNULL(LOWER(C.A9_EMAIL),'')'DAR'"
cQuery += " FROM "+RetSqlName("SRA")+" SRA"
cQuery += " 	LEFT JOIN "+RetSqlName("SA9")+" A ON(A.A9_MATRH = RA_MAT AND A.D_E_L_E_T_ = '')"
cQuery += " 	LEFT JOIN "+RetSqlName("SA9")+" B ON(A.A9_REGIAO = B.A9_REGIAO AND B.A9_TIPO = 'GI' AND B.D_E_L_E_T_ = '')"
cQuery += " 	LEFT JOIN "+RetSqlName("SA9")+" C ON(B.A9_REGIAO = C.A9_TECNICO  AND C.D_E_L_E_T_ = '')"
cQuery += " WHERE SRA.D_E_L_E_T_ = ''"
cQuery += " AND RA_CATFUNC = 'M'"
cQuery += " AND RA_SITFOLH <> 'D'"
cQuery += " AND RA_VCTOEXP = CONVERT(CHAR,(GETDATE()+5),112)"
cQuery += " ORDER BY RA_MAT"

If Select("TSZW") <> 0
	TSZW->(dbCloseArea("TSZW"))
Endif

TcQuery cQuery NEW ALIAS "TSZW"

TSZW->(dbGoTop())

While TSZW->(!EOF())
	
	cTabela += "<tr>"                                                      
	cTabela += "	<td align='center' valign='middle'>"+TSZW->RA_MAT+"</td>"	
	cTabela += "	<td align='left' valign='middle'>&nbsp;"+TSZW->RA_NOME+"</td>"
	cTabela += "	<td align='center' valign='middle'>"+DTOC(STOD(TSZW->RA_ADMISSA))+"</td>"
	cTabela += "	<td align='center' valign='middle'>"+DTOC(STOD(TSZW->FIM))+"</td>"
	cTabela += "</tr>"
	
	TSZW->(dbSkip())
Enddo

if (!empty(cTabela))
	// CORPO DA CONSULTA
	oHtml:ValByName("tabela",cTabela)
	
	//SELECIONA AS CONTAS DE E-MAIL
	cQuery := " SELECT ZW_EMAIL "
	cQuery += " FROM "+RetSqlName("SZW")+" SZW "
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND ZW_CODIGO = 'WF013' "
	
	If Select("TSZW") <> 0
		TSZw->(dbCloseArea("TSZW"))
	Endif
	
	TcQuery cQuery NEW ALIAS "TSZW"
	
	cMail := ""
	lFirst := .T.
	
	TSZW->(dbGoTop())
	While TSZW->(!EOF())
		If !lFirst
			cMail += ";"
		Endif
		cMail += ALLTRIM(TSZW->ZW_EMAIL)
		lFirst := .F.
		TSZW->(dbSkip())
	Enddo
	
	If !Empty(cMail)
		oProcess:ClientName(cUserName)
		oProcess:cTo := cMail
		oProcess:UserSiga := "000000"
		oProcess:Start()
	Endif
Endif


/**************/
cHtml   := "\workflow\WF013B.htm"
cTabela := ""
cGar := ""
oProcess := TWFProcess():New("CtExp","Contrato de Experiencia")
oProcess:NewTask("CtExp",cHtml)
oHtml := oProcess:oHtml
oProcess:cSubject := "Vencimento do contrato de experiência - 2o Periodo"

cQuery := " SELECT RA_NOME,RA_MAT,RA_ADMISSA,RA_VCTEXP2'FIM',ISNULL(LOWER(B.A9_EMAIL),'')A9_EMAIL,ISNULL(LOWER(C.A9_EMAIL),'')'DAR'"
cQuery += " FROM "+RetSqlName("SRA")+" SRA"
cQuery += " 	LEFT JOIN "+RetSqlName("SA9")+" A ON(A.A9_MATRH = RA_MAT AND A.D_E_L_E_T_ = '')"
cQuery += " 	LEFT JOIN "+RetSqlName("SA9")+" B ON(A.A9_REGIAO = B.A9_REGIAO AND B.A9_TIPO = 'GI' AND B.D_E_L_E_T_ = '')"
cQuery += " 	LEFT JOIN "+RetSqlName("SA9")+" C ON(B.A9_REGIAO = C.A9_TECNICO  AND C.D_E_L_E_T_ = '')"
cQuery += " WHERE SRA.D_E_L_E_T_ = ''"
cQuery += " AND RA_CATFUNC = 'M'"
cQuery += " AND RA_SITFOLH <> 'D'"
cQuery += " AND RA_VCTEXP2 = CONVERT(CHAR,(GETDATE()+15),112)"
cQuery += " ORDER BY RA_MAT"


If Select("TSZW") <> 0
	TSZW->(dbCloseArea("TSZW"))
Endif

TcQuery cQuery NEW ALIAS "TSZW"

TSZW->(dbGoTop())

While TSZW->(!EOF())
	
	cTabela += "<tr>"
	cTabela += "	<td align='center' valign='middle'>"+TSZW->RA_MAT+"</td>"
	cTabela += "	<td align='left' valign='middle'>&nbsp;"+TSZW->RA_NOME+"</td>"
	cTabela += "	<td align='center' valign='middle'>"+DTOC(STOD(TSZW->RA_ADMISSA))+"</td>"
	cTabela += "	<td align='center' valign='middle'>"+DTOC(STOD(TSZW->FIM))+"</td>"
	cTabela += "</tr>"

	TSZW->(dbSkip())
Enddo

if (!empty(cTabela))
	// CORPO DA CONSULTA
	oHtml:ValByName("tabela",cTabela)
	
	//SELECIONA AS CONTAS DE E-MAIL
	cQuery := " SELECT ZW_EMAIL "
	cQuery += " FROM "+RetSqlName("SZW")+" SZW "
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND ZW_CODIGO = 'WF013' "
	
	If Select("TSZW") <> 0
		TSZw->(dbCloseArea("TSZW"))
	Endif
	
	TcQuery cQuery NEW ALIAS "TSZW"
	
	cMail := "marcelo.nascimento@elcop.eng.br"
	lFirst := .T.
	
	TSZW->(dbGoTop())
	While TSZW->(!EOF())
		If !lFirst
			cMail += ";"
		Endif
		cMail += ALLTRIM(TSZW->ZW_EMAIL)
		lFirst := .F.
		TSZW->(dbSkip())
	Enddo

	If !Empty(cMail)
		oProcess:ClientName(cUserName)
		oProcess:cTo := cMail
		oProcess:UserSiga := "000000"
		oProcess:Start()
	Endif
Endif

Return Nil
