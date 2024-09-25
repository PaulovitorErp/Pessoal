#INCLUDE "SGAR240.CH"
#include "protheus.ch"

#DEFINE _nVERSAO 2 //Versao do fonte
//---------------------------------------------------------------------
/*/{Protheus.doc} SGAR240()
Relatório IBAMA de Efluentes Liquidos

@author  Elynton Fellipe Bazzo
@since   03/05/2013
@version P11
@return  .T.
/*/
//---------------------------------------------------------------------
Function SGAR240()

	Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)

	Private cCadastro := OemtoAnsi(STR0001) //"Relatório IBAMA de Efluentes Líquidos"
	Private cPerg	  := STR0002 //"SGAR240"
	Private aPerg	  := {}

	If !NGCADICBASE("TEB_ANO","D","TEB",.F.)
		If !NGINCOMPDIC("UPDSGA23","THYRMV",.F.)
			Return .F.
		EndIf
	EndIf

	Pergunte(cPerg,.F.)

	SGAR240PAD()

	NGRETURNPRM(aNGBEGINPRM)

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} SGAR240PAD()
Imprime Relatório IBAMA de Efluentes Liquidos

@author  Elynton Fellipe Bazzo
@since   03/05/2013
@version P11
@return  .T.
/*/
//---------------------------------------------------------------------
Static Function SGAR240PAD()

	Local WnRel		:= STR0002 //"SGAR240"
	Local Limite	:= 220
	Local cDesc1	:= STR0001 //"Relatório IBAMA de Efluentes Líquidos"
	Local cDesc2	:= ""
	Local cDesc3	:= ""
	Local cString	:= "TEB"
	Local aPoluentes:= {}
	Local i
	Private NomeProg:= STR0002 //"SGAR240"
	Private Tamanho	:= "G"
	Private aReturn	:= {STR0003,1,STR0004,1,2,1,"",1}
	Private Titulo	:= STR0005 //"Relatório IBAMA - Efluentes Líquidos"
	Private nTipo	:= 0
	Private nLastKey:= 0

	//--------------------------------------------
	// Envia controle para a funcao SETPRINT
	//--------------------------------------------
	WnRel:=SetPrint(cString,WnRel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,"")

	If nLastKey = 27
		Set Filter To
		DbSelectArea("TEB")
		Return
	EndIf
	SetDefault(aReturn,cString)
	Processa({|lEND| SGAR240Imp(@lEND,WnRel,Titulo,Tamanho)},STR0006) //"Processando Registros..."

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} SGAR240Imp()
Relatório IBAMA de Efluentes Liquidos

@author  Elynton Fellipe Bazzo
@since   03/05/2013
@version P11
@return  .T.
/*/
//---------------------------------------------------------------------
Static Function SGAR240Imp(lEND,WnRel,Titulo,Tamanho)

	Local cRodaTxt	:= ""
	Local nCntImpr	:= 0
	Local lImp 		:= .F.
	Local i, j

	Private li 		:= 80 ,m_pag := 1
	Private cabec1	:= STR0007 //"Ano   Fonte   Descrição                            Descrição Monitoramento                 Efic.  Tratam.    Descrição                     Nível Trat.     C. Emissão  Tipo Emissão Solo    Qual?"
	Private cabec2	:= STR0008 //"  Tp. Emissão  Tp. Receptor  Classe    Nome                                 Lat. Graus  Min.  Seg.  Tipo  Lon. Graus  Min.  Seg.  Corpo Receptor      Qual                                 Fornecedor"
	/*
	0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2         3
	012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	***************************************************************************************************************************************************************************************************************************************
	Ano   Fonte   Descrição                            Tratam.  Descrição                       Efic.  Nível Trat.  C. Emissão  Tipo Emissão Solo    Qual?                           Descrição Monitoramento
	  Tp. Emissão  Tp. Receptor  Classe    Nome                                 Lat. Graus  Min.  Seg.  Tipo  Lon. Graus  Min.  Seg.  Corpo Receptor      Qual                                 Fornecedor
	***************************************************************************************************************************************************************************************************************************************
	9999  XXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXX   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   999%  XXXXXXXXXX   XXXX        XXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	  XXXXXXXX     XXXXXXXXXXXX  XXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX          99    99  99.9  XXXXX         99    99  99.9  XXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

	      Poluentes:
	                Código Poluente  Descrição                                           Quantidade Un.  Método        Identificação  Sigilo  Justificativa
	                XXXXXX           XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  999,999,999,999,999,999,999.99 XX   XXXXXXXXXXXX  XXXXXXXXXXXX   XXX     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	*/
	dbSelectArea("TEB")
	dbSetOrder(1)
	dbSeek(xFilial("TEB")+MV_PAR01)
	While !eof() .and. xFilial("TEB")+MV_PAR01 == TEB->(TEB_FILIAL+TEB_ANO)
		NGSOMALI(58)
		If lImp
			NGSOMALI(58)
			NGSOMALI(58)
		Endif
		lImp := .T.

		@ Li,000 pSay TEB->TEB_ANO Picture PesqPict("TEH","TEH_ANO")
		@ Li,006 pSay TEB->TEB_FONTE Picture "@!"
		@ Li,014 pSay Substr(NGSEEK("TCB",TEB->TEB_FONTE,1,"TCB->TCB_DESCRI"),1,30) Picture "@!"
		@ Li,084 pSay TEB->TEB_EFICIE Picture PesqPict("TEB","TEB_EFICIE")
		@ Li,087 pSay "%"
		@ Li,092 pSay TEB->TEB_TRATAM Picture "@!"
		@ Li,100 pSay Substr(NGSEEK("TB6",TEB->TEB_TRATAM,1,"TB6->TB6_DESCRI"),1,25) Picture "@!"
		@ Li,129 pSay AllTrim(NGRETSX3BOX("TEB_NIVELT",TEB->TEB_NIVELT)) Picture "@!"
		@ Li,146 pSay AllTrim(NGRETSX3BOX("TEB_COMPAR",TEB->TEB_COMPAR)) Picture "@!"
		If !Empty(TEB->TEB_TPSOLO)
	   		@ Li,158 pSay AllTrim(NGRETSX3BOX("TEB_TPSOLO",TEB->TEB_TPSOLO)) Picture "@!"
		Endif
		@ Li,180 pSay Substr(TEB->TEB_OUTSOL,1,35) Picture "@!"
		If !Empty(TEB->TEB_DESCRI)
			cMemo := AllTrim(TEB->TEB_DESCRI)
			nLinha:= MLCount(cMemo,80)
			For j:= 1 To nLinha
				If j != 1
					NGSomali(58)
				Endif
				@ Li,048 PSAY If(j == 1,Space(1),"") + Memoline(cMemo,30,j)
			Next
		Endif
		If TEB->TEB_COMPAR == "1"
			NGSOMALI(58)
			NGSOMALI(58)
			If !Empty(TEB->TEB_TIPOEM)
				@ Li,002 pSay AllTrim(NGRETSX3BOX("TEB_TIPOEM",TEB->TEB_TIPOEM)) Picture "@!"
			Endif
			If !Empty(TEB->TEB_CORHID) .and. TEB->TEB_TIPOEM == "1"
				dbSelectArea("TEA")
				dbSetOrder(1)
				If dbSeek(xFilial("TEA")+TEB->TEB_CORHID)
					If !Empty(TEA->TEA_TIPCOR)
						@ Li,015 pSay AllTrim(NGRETSX3BOX("TEA_TIPCOR",TEA->TEA_TIPCOR)) Picture "@!"
					Endif
					If !Empty(TEA->TEA_CLACOR)
						@ Li,029 pSay AllTrim(Substr(NGRETSX3BOX("TEA_CLACOR",TEA->TEA_CLACOR),8,8)) Picture "@!"
					Endif
					@ Li,040 pSay AllTrim(Substr(TEA->TEA_DESCRE,1,30)) Picture "@!"
					@ Li,075 pSay TEA->TEA_LATGRA Picture PesqPict("TEA","TEA_LATGRA")
					@ Li,082 pSay TEA->TEA_LATMIN Picture PesqPict("TEA","TEA_LATMIN")
					@ Li,087 pSay TEA->TEA_LATSEG Picture PesqPict("TEA","TEA_LATSEG")
					If !Empty(TEA->TEA_LATTIP)
						@ Li,093 pSay AllTrim(NGRETSX3BOX("TEA_LATTIP",TEA->TEA_LATTIP)) Picture "@!"
					Endif
					@ Li,104 pSay TEA->TEA_LONGRA Picture PesqPict("TEA","TEA_LONGRA")
					@ Li,112 pSay TEA->TEA_LONMIN Picture PesqPict("TEA","TEA_LONMIN")
					@ Li,118 pSay TEA->TEA_LONSEG Picture PesqPict("TEA","TEA_LONSEG")
					@ Li,132 pSay "-"
					@ Li,164 pSay "-"
					@ Li,187 pSay "-"
				Endif
			ElseIf TEB->TEB_TIPOEM == "2"
					@ Li,023 pSay "-"
					@ Li,034 pSay "-"
					@ Li,048 pSay "-"
					@ Li,083 pSay "-"
					@ Li,092 pSay "-"
					@ Li,097 pSay "-"
					@ Li,104 pSay "-"
					@ Li,113 pSay "-"
					@ Li,122 pSay "-"
					@ Li,128 pSay "-"
				If !Empty(TEB->TEB_CORPRE)
					@ Li,137 pSay AllTrim(NGRETSX3BOX("TEB_CORPRE",TEB->TEB_CORPRE)) Picture "@!"
				Endif
				@ Li,152 pSay Substr(TEB->TEB_OUTCOR,1,35) Picture "@!"
				@ Li,189 pSay Substr(NGSEEK("SA2",TEB->TEB_EMPREC+TEB->TEB_LOJREC,1,"SA2->A2_NOME"),1,30) Picture "@!"
			Endif
		Endif
		aPoluentes:= {}
		dbSelectArea("TEC")
		dbSetOrder(1)
		dbSeek(xFilial("TEC")+TEB->(TEB_ANO+TEB_FONTE+TEB_TRATAM))
		While !eof() .and. xFilial("TEC")+TEB->(TEB_ANO+TEB_FONTE+TEB_TRATAM) == TEC->(TEC_FILIAL+TEC_ANO+TEC_FONTE+TEC_TRATAM)
			If (nPos := aScan(aPoluentes, {|x| x[1]+x[2]+x[3]+x[4]+x[5] == TEC->(TEC_CODPOL+TEC_UNIDAD+TEC_METODO+TEC_IDMETO+TEC_CONSIG) } ) ) == 0
				aAdd(aPoluentes, {TEC->TEC_CODPOL, TEC->TEC_UNIDAD, TEC->TEC_METODO, TEC->TEC_IDMETO, TEC->TEC_CONSIG,;
									 TEC->TEC_JUSSIG, TEC->TEC_QUANTI, Substr(NGSEEK("TEG",TEC->TEC_CODPOL,1,"TEG->TEG_DESCRI"),1,30),;
									 If(!Empty(TEC->TEC_METODO),AllTrim(NGRETSX3BOX("TEC_METODO",TEC->TEC_METODO)),""),;
									 If(!Empty(TEC->TEC_CONSIG),AllTrim(NGRETSX3BOX("TEC_CONSIG",TEC->TEC_CONSIG)),"")} )
			Else
				aPoluentes[nPos,7] += TEC->TEC_QUANTI
				If Empty(aPoluentes[nPos,6]) .and. !Empty(TEC->TEC_JUSSIG)
					aPoluentes[nPos,6] += TEC->TEC_JUSSIG
				Endif
			Endif
			dbSelectArea("TEC")
			dbSkip()
		End

		For i:=1 to Len(aPoluentes)
			NGSOMALI(58)
			If i == 1
				NGSOMALI(58)
				@ Li,000 pSay STR0009 //"Identific. Tipo de Emissão:"
				@ Li,046 pSay STR0010 //"Poluentes:"
				NGSOMALI(58)
				If !Empty(TEB->TEB_EMISSA)
					@ Li,026 pSay AllTrim(NGRETSX3BOX("TEB_EMISSA",TEB->TEB_EMISSA)) Picture "@!"
				EndIf
				@ Li,040 pSay STR0011//"                Código Poluente  Descrição                                           Quantidade Un.  Método        Identificação  Sigilo  Justificativa"
				NGSOMALI(58)
			Endif
			@ Li,056 pSay AllTrim(aPoluentes[i,1]) Picture "@!"
			@ Li,066 pSay AllTrim(aPoluentes[i,8]) Picture "@!"
			@ Li,98 pSay aPoluentes[i,7] Picture "@E 999,999,999,999,999,999,999.99"
			@ Li,129 pSay AllTrim(aPoluentes[i,2]) Picture "@!"
			If !Empty(aPoluentes[i,9])
				@ Li,134 pSay AllTrim(aPoluentes[i,9]) Picture "@!"
			Endif
			If !Empty(aPoluentes[i,4])
				@ Li,153 pSay AllTrim(aPoluentes[i,4]) Picture "@!"
			Endif
			If !Empty(aPoluentes[i,10])
				@ Li,172 pSay AllTrim(aPoluentes[i,10]) Picture "@!"
			Endif
			If !Empty(aPoluentes[i,6])
				cMemo := AllTrim(aPoluentes[i,6])
				nLinha:= MLCount(cMemo,80)
				For j:= 1 To nLinha
					If j != 1
						NGSomali(58)
					Endif
					@ Li,180 PSAY Memoline(cMemo,30,j)
				Next
			Endif
		Next i

		NGSOMALI(58)
		@li,000 PSAY Replicate("_",220)
		dbSelectArea("TEB")
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
		MsgInfo(STR0012) //"Não existem dados para montar o relatório."
	Endif

	//--------------------------------------------------
	// Devolve a condicao original do arquivo principal
	//--------------------------------------------------
	RetIndex("TEB")
	Set Filter To

Return .T.