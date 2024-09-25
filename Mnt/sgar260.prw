#include "SGAR260.ch"
#include "protheus.ch"

#DEFINE _nVERSAO 02 //Versao do fonte
//-------------------------------------------------------------------------------
/*/{Protheus.doc} SGAR260() 
Relatório IBAMA de Unidades Poluidoras

@Author: Elynton Fellipe Bazzo 
@since: 03/05/2013
@version 110
@return .T.
/*/
//--------------------------------------------------------------------------------
Function SGAR260()
	
	Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)
	
	Private cCadastro := OemtoAnsi(STR0001) //"Relatório IBAMA de Unidades Poluidoras"
	Private cPerg	  := STR0002 //"SGAR260"
	Private aPerg	  := {}
	
	If !NGCADICBASE("TEH_ANO","D","TEH",.F.)
		If !NGINCOMPDIC("UPDSGA24","THYPMU",.F.)
			Return .F.
		EndIf
	EndIf
	
	Pergunte(cPerg,.F.)
	
	SGAR260PAD()
	
	NGRETURNPRM( aNGBEGINPRM )
	
Return .T.
//-------------------------------------------------------------------------------
/*/{Protheus.doc} SGAR260PAD() 
Imprime Relatório IBAMA de Unidades Poluidoras 

@Author: Elynton Fellipe Bazzo 
@since: 03/05/2013
@version 110
@return .T.
/*/
//--------------------------------------------------------------------------------
Static Function SGAR260PAD()
	
	Local WnRel		:= STR0002 //"SGAR260"
	Local Limite	:= 220
	Local cDesc1	:= STR0001 //"Relatório IBAMA de Unidades Poluidoras"
	Local cDesc2	:= ""
	Local cDesc3	:= ""
	Local cString	:= "TEH"
	Local aPoluentes:= {}
	Local i
	
	Private NomeProg:= STR0002 //"SGAR260"
	Private Tamanho	:= "G"
	Private aReturn	:= {STR0003,1,STR0004,1,2,1,"",1}
	Private Titulo	:= STR0005 //"Relatório IBAMA - Unidades Poluidoras"
	Private nTipo	:= 0
	Private nLastKey:= 0
	
	//---------------------------------------
	// Envia controle para a funcao SETPRINT
	//---------------------------------------
	WnRel:=SetPrint(cString,WnRel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,"")
	
	If nLastKey = 27
		Set Filter To
		DbSelectArea( "TEH" )
		Return
	EndIf
	SetDefault( aReturn,cString )
	Processa({|lEND| SGAR260Imp(@lEND,WnRel,Titulo,Tamanho)},STR0006) //"Processando Registros..."

Return .T.
//-------------------------------------------------------------------------------
/*/{Protheus.doc} SGAR260Imp(lEND,WnRel,Titulo,Tamanho)
Relatório IBAMA de Unidades Poluidoras   

@Author: Elynton Fellipe Bazzo 
@since: 03/05/2013
@version 110
@return .T.
/*/
//--------------------------------------------------------------------------------
Static Function SGAR260Imp(lEND,WnRel,Titulo,Tamanho)
	
	Local cRodaTxt	:= ""
	Local nCntImpr	:= 0
	Local lImp 		:= .F.
	Local i, j
	
	Private li 		:= 80 ,m_pag := 1
	Private cabec1	:= STR0007 //"Ano   Código      Descrição                                 Fonte Poluidora                                      Cap. Nominal  Func. Diário  Equipamento Controle                      Tp. Emissão"
	Private cabec2	:= STR0008 //"   Chaminé?     Altitude     Altura    Temp. Gases    Diâmetro Int.    Vazão Gases    Lat. Graus    Lat. Minutos    Lat. Segundos    Tipo Latitude    Lon. Graus    Lon. Minutos    Lon. Segundos"
	
	/*
	0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2         3
	012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	***************************************************************************************************************************************************************************************************************************************
	Ano   Código      Descrição                                 Fonte Poluidora                                      Cap. Nominal  Func. Diário  Equipamento Controle                      Chaminé?  Tp. Emissão
	   Altitude     Altura  Temp. Gases  Diâmetro Int.    Vazão Gases  Lat. Graus  Lat. Minutos  Lat. Segundos  Tipo Latitude  Lon. Graus  Lon. Minutos  Lon. Segundos
	***************************************************************************************************************************************************************************************************************************************
	9999  XXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  9,999,999.999      99 h/dia  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXX       XXXXXXXXXX
	     9999 m  9999999 m    999.99 Cº     9,999.99 m  9999999 Nm³/h          99            99           99.9  XXXXX                  99            99           99.9
	     
	      Poluentes:
	                Código Poluente  Descrição                                           Quantidade Un.  Método        Identificação  Sigilo  Justificativa
	                XXXXXX           XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  999,999,999,999,999,999,999.99 XX   XXXXXXXXXXXX  XXXXXXXXXXXX   XXX     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	*/
	
	dbSelectArea("TEH")
	dbSetOrder(1)
	dbSeek(xFilial("TEH")+MV_PAR01)
	While !eof() .and. xFilial("TEH")+MV_PAR01 == TEH->(TEH_FILIAL+TEH_ANO)
		NGSOMALI(58)
		If lImp
			NGSOMALI(58)
			NGSOMALI(58)
		Endif
		lImp := .T.
		
		@ Li,000 pSay TEH->TEH_ANO Picture PesqPict("TEH","TEH_ANO")
		@ Li,006 pSay TEH->TEH_CODIGO Picture "@!"
		@ Li,018 pSay Substr(TEH->TEH_DESCRI,1,40) Picture "@!"
		@ Li,060 pSay Substr(NGSEEK("TEE",TEH->TEH_FONPOL,1,"TEE->TEE_DESCRI"),1,50) Picture "@!"
		@ Li,112 pSay TEH->TEH_CAPNOM Picture PesqPict("TEH","TEH_CAPNOM")
		@ Li,131 pSay TEH->TEH_FUNDIA Picture PesqPict("TEH","TEH_FUNDIA")
		@ Li,134 pSay STR0009 Picture "@!" //"h/dia"
		@ Li,141 pSay Substr(NGSEEK("TEF",TEH->TEH_EQTCON,1,"TEF->TEF_DESCRI"),1,40) Picture "@!"	
		@ Li,183 pSay NGRETSX3BOX("TEH_TIPEMI",TEH->TEH_TIPEMI) Picture "@!"
	
		NGSOMALI(58)
		NGSOMALI(58)
		@ Li,003 pSay NGRETSX3BOX("TEH_POSCHA",TEH->TEH_POSCHA) Picture "@!"
		@ Li,018 pSay TEH->TEH_ALTITU Picture PesqPict("TEH","TEH_ALTITU")
		@ Li,023 pSay STR0010 Picture "@!"  //"m"
		@ Li,026 pSay TEH->TEH_ALTURA Picture PesqPict("TEH","TEH_ALTURA")
		@ Li,034 pSay STR0010 Picture "@!"  //"m"
		@ Li,042 pSay TEH->TEH_TMPGAS Picture PesqPict("TEH","TEH_TMPGAS")
		@ Li,049 pSay STR0011 Picture "@!"  //"Cº"
		@ Li,057 pSay TEH->TEH_DIAINT Picture PesqPict("TEH","TEH_DIAINT")
		@ Li,066 pSay STR0010 Picture "@!"  //"m"
		@ Li,069 pSay TEH->TEH_VAZGAS Picture PesqPict("TEH","TEH_VAZGAS")
		@ Li,077 pSay STR0012 Picture "@!"  //"Nm³/h"
		@ Li,094 pSay TEH->TEH_LATGRA Picture PesqPict("TEH","TEH_LATGRA")
		@ Li,110 pSay TEH->TEH_LATMIN Picture PesqPict("TEH","TEH_LATMIN")	
		@ Li,125 pSay TEH->TEH_LATSEG Picture PesqPict("TEH","TEH_LATSEG")
		If !Empty(TEH->TEH_LATTIP)
			@ Li,141 pSay AllTrim(NGRETSX3BOX("TEH_LATTIP",TEH->TEH_LATTIP)) Picture "@!"
		Endif
		@ Li,158 pSay TEH->TEH_LONGRA Picture PesqPict("TEH","TEH_LONGRA")
		@ Li,174 pSay TEH->TEH_LONMIN Picture PesqPict("TEH","TEH_LONMIN")
		@ Li,189 pSay TEH->TEH_LONSEG Picture PesqPict("TEH","TEH_LONSEG")
	
		aPoluentes:= {}	
		dbSelectArea("TEI")
		dbSetOrder(1)
		dbSeek(xFilial("TEI")+TEH->(TEH_ANO+TEH_CODIGO))
		While !eof() .and. xFilial("TEI")+TEH->(TEH_ANO+TEH_CODIGO) == TEI->(TEI_FILIAL+TEI_ANO+TEI_CODUNI)
			If (nPos := aScan(aPoluentes, {|x| x[1]+x[2]+x[3]+x[4]+x[5] == TEI->(TEI_CODPOL+TEI_UNIDAD+TEI_METODO+TEI_IDMETO+TEI_CONSIG) } ) ) == 0
				aAdd(aPoluentes, {TEI->TEI_CODPOL, TEI->TEI_UNIDAD, TEI->TEI_METODO, TEI->TEI_IDMETO, TEI->TEI_CONSIG,;
									 TEI->TEI_JUSSIG, TEI->TEI_QUANTI, Substr(NGSEEK("TEG",TEI->TEI_CODPOL,1,"TEG->TEG_DESCRI"),1,30),;
									 If(!Empty(TEI->TEI_METODO),AllTrim(NGRETSX3BOX("TEI_METODO",TEI->TEI_METODO)),""),;
									 If(!Empty(TEI->TEI_CONSIG),AllTrim(NGRETSX3BOX("TEI_CONSIG",TEI->TEI_CONSIG)),"")} )
			Else
				aPoluentes[nPos,7] += TEI->TEI_QUANTI
				If Empty(aPoluentes[nPos,6]) .and. !Empty(TEI->TEI_JUSSIG) 
					aPoluentes[nPos,6] += TEI->TEI_JUSSIG
				Endif
			Endif
			dbSelectArea("TEI")
			dbSkip()
		End
	
		For i:=1 to Len(aPoluentes)
			NGSOMALI(58)
			NGSOMALI(58)
			If i == 1
				@ Li,006 pSay STR0013 //"Poluentes:"
				NGSOMALI(58)
				@ Li,000 pSay STR0014 //"                Código Poluente  Descrição                                           Quantidade Un.  Método        Identificação  Sigilo  Justificativa"
				NGSOMALI(58)
			Endif
			@ Li,016 pSay AllTrim(aPoluentes[i,1]) Picture "@!"
			@ Li,033 pSay AllTrim(aPoluentes[i,8]) Picture "@!"
			@ Li,065 pSay aPoluentes[i,7] Picture "@E 999,999,999,999,999,999,999.99"
			@ Li,096 pSay AllTrim(aPoluentes[i,2]) Picture "@!"
			If !Empty(aPoluentes[i,9])
				@ Li,101 pSay AllTrim(aPoluentes[i,9]) Picture "@!"
			Endif
			If !Empty(aPoluentes[i,4])
				@ Li,115 pSay AllTrim(aPoluentes[i,4]) Picture "@!"	
			Endif
			If !Empty(aPoluentes[i,10])
				@ Li,130 pSay AllTrim(aPoluentes[i,10]) Picture "@!"
			Endif
			If !Empty(aPoluentes[i,6])
				cMemo := AllTrim(aPoluentes[i,6])
				nLinha:= MLCount(cMemo,80)
				For j:= 1 To nLinha
					If j != 1
						NGSomali(58)
					Endif
					@ Li,138 PSAY Memoline(cMemo,80,j)
				Next 
			Endif		
		Next i
		
		NGSOMALI(58)
		@li,000 PSAY Replicate("_",220)
		dbSelectArea("TEH")
		dbSkip()
	End

	If lImp
		RODA(nCntImpr,cRodaTxt,Tamanho)
		Set Device To Screen
		If aReturn[5] == 1
		   Set Printer To
		   dbCommitAll()
		   OurSpool(WnRel)
		EndIf
		MS_FLUSH()
	Else
		MsgInfo(STR0015) //"Não existem dados para montar o relatório."
	Endif
	
	//--------------------------------------------------
	// Devolve a condicao original do arquivo principal
	//--------------------------------------------------
	RetIndex( "TEH" )
	Set Filter To
	
Return .T.