#INCLUDE "MNTR390.ch"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNTR390   ³ Autor ³ Ricardo Dal Ponte     ³ Data ³ 12/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relatorio de Infracoes no Ano                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/      
Function MNTR390()  
	
	Private nAnoSEL1 := 0
	Private nAnoSEL2 := 0
	Private nAnoSEL3 := 0

	Private nINFREC101 := 0
	Private nINFREC102 := 0
	Private nINFREC103 := 0
	Private nINFREC104 := 0
	Private nINFREC105 := 0
	Private nINFREC106 := 0
	Private nINFREC107 := 0
	Private nINFREC108 := 0
	Private nINFREC109 := 0
	Private nINFREC110 := 0
	Private nINFREC111 := 0
	Private nINFREC112 := 0

	Private nVALREC101 := 0
	Private nVALREC102 := 0
	Private nVALREC103 := 0
	Private nVALREC104 := 0
	Private nVALREC105 := 0
	Private nVALREC106 := 0
	Private nVALREC107 := 0
	Private nVALREC108 := 0
	Private nVALREC109 := 0
	Private nVALREC110 := 0
	Private nVALREC111 := 0
	Private nVALREC112 := 0

	Private nINFSOF101 := 0
	Private nINFSOF102 := 0
	Private nINFSOF103 := 0
	Private nINFSOF104 := 0
	Private nINFSOF105 := 0
	Private nINFSOF106 := 0
	Private nINFSOF107 := 0
	Private nINFSOF108 := 0
	Private nINFSOF109 := 0
	Private nINFSOF110 := 0
	Private nINFSOF111 := 0
	Private nINFSOF112 := 0

	Private nVALSOF101 := 0
	Private nVALSOF102 := 0
	Private nVALSOF103 := 0
	Private nVALSOF104 := 0
	Private nVALSOF105 := 0
	Private nVALSOF106 := 0
	Private nVALSOF107 := 0
	Private nVALSOF108 := 0
	Private nVALSOF109 := 0
	Private nVALSOF110 := 0
	Private nVALSOF111 := 0
	Private nVALSOF112 := 0

	Private nINFREC201 := 0
	Private nINFREC202 := 0
	Private nINFREC203 := 0
	Private nINFREC204 := 0
	Private nINFREC205 := 0
	Private nINFREC206 := 0
	Private nINFREC207 := 0
	Private nINFREC208 := 0
	Private nINFREC209 := 0
	Private nINFREC210 := 0
	Private nINFREC211 := 0
	Private nINFREC212 := 0 

	Private nVALREC201 := 0
	Private nVALREC202 := 0
	Private nVALREC203 := 0
	Private nVALREC204 := 0
	Private nVALREC205 := 0
	Private nVALREC206 := 0
	Private nVALREC207 := 0
	Private nVALREC208 := 0
	Private nVALREC209 := 0
	Private nVALREC210 := 0
	Private nVALREC211 := 0
	Private nVALREC212 := 0

	Private nINFSOF201 := 0
	Private nINFSOF202 := 0
	Private nINFSOF203 := 0
	Private nINFSOF204 := 0
	Private nINFSOF205 := 0
	Private nINFSOF206 := 0
	Private nINFSOF207 := 0
	Private nINFSOF208 := 0
	Private nINFSOF209 := 0
	Private nINFSOF210 := 0
	Private nINFSOF211 := 0
	Private nINFSOF212 := 0 

	Private nVALSOF201 := 0
	Private nVALSOF202 := 0
	Private nVALSOF203 := 0
	Private nVALSOF204 := 0
	Private nVALSOF205 := 0
	Private nVALSOF206 := 0
	Private nVALSOF207 := 0
	Private nVALSOF208 := 0
	Private nVALSOF209 := 0
	Private nVALSOF210 := 0
	Private nVALSOF211 := 0
	Private nVALSOF212 := 0

	Private nINFREC301 := 0
	Private nINFREC302 := 0
	Private nINFREC303 := 0
	Private nINFREC304 := 0
	Private nINFREC305 := 0
	Private nINFREC306 := 0
	Private nINFREC307 := 0
	Private nINFREC308 := 0
	Private nINFREC309 := 0
	Private nINFREC310 := 0
	Private nINFREC311 := 0
	Private nINFREC312 := 0

	Private nVALREC301 := 0
	Private nVALREC302 := 0
	Private nVALREC303 := 0
	Private nVALREC304 := 0
	Private nVALREC305 := 0
	Private nVALREC306 := 0
	Private nVALREC307 := 0
	Private nVALREC308 := 0
	Private nVALREC309 := 0
	Private nVALREC310 := 0
	Private nVALREC311 := 0
	Private nVALREC312 := 0

	Private nINFSOF301 := 0
	Private nINFSOF302 := 0
	Private nINFSOF303 := 0
	Private nINFSOF304 := 0
	Private nINFSOF305 := 0
	Private nINFSOF306 := 0
	Private nINFSOF307 := 0
	Private nINFSOF308 := 0
	Private nINFSOF309 := 0
	Private nINFSOF310 := 0
	Private nINFSOF311 := 0
	Private nINFSOF312 := 0

	Private nVALSOF301 := 0
	Private nVALSOF302 := 0
	Private nVALSOF303 := 0
	Private nVALSOF304 := 0
	Private nVALSOF305 := 0
	Private nVALSOF306 := 0
	Private nVALSOF307 := 0
	Private nVALSOF308 := 0
	Private nVALSOF309 := 0
	Private nVALSOF310 := 0
	Private nVALSOF311 := 0
	Private nVALSOF312 := 0

	Private nTOTREC1 := 0
	Private nVALREC1 := 0
	Private nTOTSOF1 := 0 
	Private nVALSOF1 := 0
	Private nTOTREC2 := 0
	Private nVALREC2 := 0
	Private nTOTSOF2 := 0
	Private nVALSOF2 := 0
	Private nTOTREC3 := 0
	Private nVALREC3 := 0
	Private nTOTSOF3 := 0 
	Private nVALSOF3 := 0

	Private NOMEPROG := "MNTR390"
	Private TAMANHO  := "G"
	Private aRETURN  := {STR0001,1,STR0002,1,2,1,"",1} //"Zebrado"###"Administracao"
	Private TITULO   := STR0003 //"Relatorio de Infrações no Ano"
	Private nTIPO    := 0
	Private nLASTKEY := 0
	Private CABEC1,CABEC2 
	Private aVETINR := {}    
	Private cPERG := "MNT390"   
	Private aPerg :={}

	SetKey( VK_F9, { | | NGVersao( "MNTR390" , 1 ) } )

	WNREL      := "MNTR390"
	LIMITE     := 132
	cDESC1     := STR0004 //"O relatório de infrações no Ano apresentará a quantidade "
	cDESC2     := STR0005 //"de infrações recebidas e sofridas no ano (tabulando por mês)."
	cDESC3     := ""
	cSTRING    := "TRH"       

	Pergunte(cPERG,.F.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ		ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	WNREL:=SetPrint(cSTRING,WNREL,cPERG,TITULO,cDESC1,cDESC2,cDESC3,.F.,"")
	If nLASTKEY = 27
		Set Filter To
		DbSelectArea("TRH")  
		Return
	EndIf     
	SetDefault(aReturn,cSTRING)
	RptStatus({|lEND| MNTR390IMP(@lEND,WNREL,TITULO,TAMANHO)},STR0012,STR0013) //"Aguarde..."###"Processando Registros..."
	Dbselectarea("TRH")  

Return .T.    

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |MNT390IMP | Autor ³ Ricardo Dal Ponte     ³ Data ³ 08/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Chamada do Relat¢rio                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR390                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTR390IMP(lEND,WNREL,TITULO,TAMANHO) 
	Local nI
	Private cRODATXT := ""
	Private nCNTIMPR := 0     
	Private li := 80 ,m_pag := 1    
	Private cNomeOri
	Private aVetor := {}
	Private aTotGeral := {}
	Private nAno, nMes 
	Private nTotCarga := 0, nTotManut := 0 
	Private nTotal := 0
	Private c390Cabec1 := '', c390Cabec2 := ''

	Processa({|lEND| MNTR390TMP()},STR0014) //"Processando Arquivo..."

	nTIPO  := IIf(aReturn[4]==1,15,18)                                                                                                                                                                                               

	c390Cabec1 := "MES       "

	If nAnoSEL1 <> 0
		c390Cabec1 += "   "+STR0015 //"MULTAS RECEB.   VALOR INFRAÇÃO   INFRA COMETID.   VALOR INFRAÇÃO"
		c390Cabec2 += "                 "+AllTrim(Str(nAnoSEL1))+"                              "+AllTrim(Str(nAnoSEL1))
	Endif
	If nAnoSEL2 <> 0
		c390Cabec1 += "    "+STR0015 //"MULTAS RECEB.   VALOR INFRAÇÃO   INFRA COMETID.   VALOR INFRAÇÃO"
		c390Cabec2 += "                              "+AllTrim(Str(nAnoSEL2))+"                              "+AllTrim(Str(nAnoSEL2))
	Endif
	If nAnoSEL3 <> 0
		c390Cabec1 += "    "+STR0015 //"MULTAS RECEB.   VALOR INFRAÇÃO   INFRA COMETID.   VALOR INFRAÇÃO"
		c390Cabec2 += "                              "+AllTrim(Str(nAnoSEL3))+"                              "+AllTrim(Str(nAnoSEL3))
	Endif

	CABEC1 := c390Cabec1
	CABEC2 := c390Cabec2

	If nTOTREC1 = 0 .AND. nTOTREC2 = 0 .AND. nTOTREC3 = 0 .AND. nTOTSOF1 = 0 .AND. nTOTSOF2 = 0 .AND. nTOTSOF3 = 0
		MsgInfo(STR0033,STR0031)    //"Não existem dados para montar o relatório."###"ATENÇÃO"
		Return .F.
	Endif

	NgSomaLi(58)

	cPictire := "@E 99999999999999"
	cPictValor := "@E 999,999,999.99"

	@ Li,000 	 Psay STR0017 //"JANEIRO"
	If nAnoSEL1 <> 0
		@ Li,012 	 Psay nINFREC101 Picture cPictire
		@ Li,029 	 Psay nVALREC101 Picture cPictValor
		@ Li,046 	 Psay nINFSOF101 Picture cPictire
		@ Li,063 	 Psay nVALSOF101 Picture cPictValor   
	EndIf

	If nAnoSEL2 <> 0
		@ Li,080 	 Psay nINFREC201 Picture cPictire
		@ Li,097 	 Psay nVALREC201 Picture cPictValor  	
		@ Li,114 	 Psay nINFSOF201 Picture cPictire
		@ Li,131 	 Psay nVALSOF201 Picture cPictValor    
	Endif

	If nAnoSEL3 <> 0
		@ Li,148 	 Psay nINFREC301 Picture cPictire  
		@ Li,165 	 Psay nVALREC301 Picture cPictValor    	
		@ Li,182 	 Psay nINFSOF301 Picture cPictire
		@ Li,199 	 Psay nVALSOF301 Picture cPictValor      
	EndIf

	NgSomaLi(58) 
	@ Li,000 	 Psay STR0018 //"FEVEREIRO"
	If nAnoSEL1 <> 0
		@ Li,012 	 Psay nINFREC102 Picture cPictire
		@ Li,029 	 Psay nVALREC102 Picture cPictValor   	
		@ Li,046 	 Psay nINFSOF102 Picture cPictire
		@ Li,063 	 Psay nVALSOF102 Picture cPictValor    
	EndIf

	If nAnoSEL2 <> 0
		@ Li,080 	 Psay nINFREC202 Picture cPictire
		@ Li,097 	 Psay nVALREC202 Picture cPictValor    	
		@ Li,114 	 Psay nINFSOF202 Picture cPictire
		@ Li,131 	 Psay nVALSOF202 Picture cPictValor   
	Endif

	If nAnoSEL3 <> 0
		@ Li,148 	 Psay nINFREC302 Picture cPictire
		@ Li,165 	 Psay nVALREC302 Picture cPictValor   	
		@ Li,182 	 Psay nINFSOF302 Picture cPictire
		@ Li,199 	 Psay nVALSOF302 Picture cPictValor    
	EndIf

	NgSomaLi(58) 
	@ Li,000 	 Psay STR0019 //"MARCO"
	If nAnoSEL1 <> 0
		@ Li,012 	 Psay nINFREC103 Picture cPictire
		@ Li,029 	 Psay nVALREC103 Picture cPictValor  	
		@ Li,046 	 Psay nINFSOF103 Picture cPictire
		@ Li,063 	 Psay nVALSOF103 Picture cPictValor    
	EndIf

	If nAnoSEL2 <> 0
		@ Li,080 	 Psay nINFREC203 Picture cPictire
		@ Li,097 	 Psay nVALREC203 Picture cPictValor   	
		@ Li,114 	 Psay nINFSOF203 Picture cPictire
		@ Li,131 	 Psay nVALSOF203 Picture cPictValor    
	Endif

	If nAnoSEL3 <> 0
		@ Li,148 	 Psay nINFREC303 Picture cPictire
		@ Li,165 	 Psay nVALREC303 Picture cPictValor  	
		@ Li,182 	 Psay nINFSOF303 Picture cPictire 
		@ Li,199 	 Psay nVALSOF303 Picture cPictValor   
	EndIf

	NgSomaLi(58) 
	@ Li,000 	 Psay STR0020 //"ABRIL"
	If nAnoSEL1 <> 0
		@ Li,012 	 Psay nINFREC104 Picture cPictire
		@ Li,029 	 Psay nVALREC104 Picture cPictValor   	
		@ Li,046 	 Psay nINFSOF104 Picture cPictire
		@ Li,063 	 Psay nVALSOF104 Picture cPictValor    
	EndIf

	If nAnoSEL2 <> 0
		@ Li,080 	 Psay nINFREC204 Picture cPictire
		@ Li,097 	 Psay nVALREC204 Picture cPictValor   	
		@ Li,114 	 Psay nINFSOF204 Picture cPictire
		@ Li,131 	 Psay nVALSOF204 Picture cPictValor   
	Endif

	If nAnoSEL3 <> 0
		@ Li,148 	 Psay nINFREC304 Picture cPictire 
		@ Li,165 	 Psay nVALREC304 Picture cPictValor   	
		@ Li,182 	 Psay nINFSOF304 Picture cPictire
		@ Li,199 	 Psay nVALSOF304 Picture cPictValor    
	EndIf

	NgSomaLi(58) 
	@ Li,000 	 Psay STR0021 //"MAIO"
	If nAnoSEL1 <> 0
		@ Li,012 	 Psay nINFREC105 Picture cPictire
		@ Li,029 	 Psay nVALREC105 Picture cPictValor   	
		@ Li,046 	 Psay nINFSOF105 Picture cPictire
		@ Li,063 	 Psay nVALSOF105 Picture cPictValor   
	EndIf

	If nAnoSEL2 <> 0
		@ Li,080 	 Psay nINFREC205 Picture cPictire
		@ Li,097 	 Psay nVALREC205 Picture cPictValor    	
		@ Li,114 	 Psay nINFSOF205 Picture cPictire 
		@ Li,131 	 Psay nVALSOF205 Picture cPictValor   
	Endif

	If nAnoSEL3 <> 0
		@ Li,148 	 Psay nINFREC305 Picture cPictire
		@ Li,165 	 Psay nVALREC305 Picture cPictValor  	
		@ Li,182 	 Psay nINFSOF305 Picture cPictire
		@ Li,199 	 Psay nVALSOF305 Picture cPictValor   
	EndIf

	NgSomaLi(58) 
	@ Li,000 	 Psay STR0022 //"JUNHO"
	If nAnoSEL1 <> 0
		@ Li,012 	 Psay nINFREC106 Picture cPictire
		@ Li,029 	 Psay nVALREC106 Picture cPictValor  	
		@ Li,046 	 Psay nINFSOF106 Picture cPictire
		@ Li,063 	 Psay nVALSOF106 Picture cPictValor    
	EndIf

	If nAnoSEL2 <> 0
		@ Li,080 	 Psay nINFREC206 Picture cPictire
		@ Li,097 	 Psay nVALREC206 Picture cPictValor  	  	
		@ Li,114 	 Psay nINFSOF206 Picture cPictire
		@ Li,131 	 Psay nVALSOF206 Picture cPictValor     
	Endif

	If nAnoSEL3 <> 0
		@ Li,148 	 Psay nINFREC306 Picture cPictire
		@ Li,165 	 Psay nVALREC306 Picture cPictValor   	
		@ Li,182 	 Psay nINFSOF306 Picture cPictire
		@ Li,199 	 Psay nVALSOF306 Picture cPictValor    
	EndIf

	NgSomaLi(58) 
	@ Li,000 	 Psay STR0023 //"JULHO"
	If nAnoSEL1 <> 0
		@ Li,012 	 Psay nINFREC107 Picture cPictire
		@ Li,029 	 Psay nVALREC107 Picture cPictValor    	
		@ Li,046 	 Psay nINFSOF107 Picture cPictire
		@ Li,063 	 Psay nVALSOF107 Picture cPictValor    
	EndIf

	If nAnoSEL2 <> 0
		@ Li,080 	 Psay nINFREC207 Picture cPictire
		@ Li,097 	 Psay nVALREC207 Picture cPictValor   	
		@ Li,114 	 Psay nINFSOF207 Picture cPictire
		@ Li,131 	 Psay nVALSOF207 Picture cPictValor    
	Endif

	If nAnoSEL3 <> 0
		@ Li,148 	 Psay nINFREC307 Picture cPictire 
		@ Li,165 	 Psay nVALREC307 Picture cPictValor   	
		@ Li,182 	 Psay nINFSOF307 Picture cPictire
		@ Li,199 	 Psay nVALSOF307 Picture cPictValor      
	EndIf

	NgSomaLi(58) 
	@ Li,000 	 Psay STR0024 //"AGOSTO"
	If nAnoSEL1 <> 0
		@ Li,012 	 Psay nINFREC108 Picture cPictire
		@ Li,029 	 Psay nVALREC108 Picture cPictValor   	
		@ Li,046 	 Psay nINFSOF108 Picture cPictire
		@ Li,063 	 Psay nVALSOF108 Picture cPictValor    
	EndIf

	If nAnoSEL2 <> 0
		@ Li,080 	 Psay nINFREC208 Picture cPictire 
		@ Li,097 	 Psay nVALREC208 Picture cPictValor  	
		@ Li,114 	 Psay nINFSOF208 Picture cPictire 
		@ Li,131 	 Psay nVALSOF208 Picture cPictValor     
	Endif

	If nAnoSEL3 <> 0
		@ Li,148 	 Psay nINFREC308 Picture cPictire 
		@ Li,165 	 Psay nVALREC308 Picture cPictValor  	
		@ Li,182 	 Psay nINFSOF308 Picture cPictire
		@ Li,199 	 Psay nVALSOF308 Picture cPictValor     
	EndIf

	NgSomaLi(58) 
	@ Li,000 	 Psay STR0025 //"SETEMBRO"
	If nAnoSEL1 <> 0
		@ Li,012 	 Psay nINFREC109 Picture cPictire
		@ Li,029 	 Psay nVALREC109 Picture cPictValor   	
		@ Li,046 	 Psay nINFSOF109 Picture cPictire 
		@ Li,063 	 Psay nVALSOF109 Picture cPictValor    
	EndIf

	If nAnoSEL2 <> 0
		@ Li,080 	 Psay nINFREC209 Picture cPictire
		@ Li,097 	 Psay nVALREC209 Picture cPictValor  	
		@ Li,114 	 Psay nINFSOF209 Picture cPictire
		@ Li,131 	 Psay nVALSOF209 Picture cPictValor     
	Endif

	If nAnoSEL3 <> 0
		@ Li,148 	 Psay nINFREC309 Picture cPictire
		@ Li,165 	 Psay nVALREC309 Picture cPictValor
		@ Li,182 	 Psay nINFSOF309 Picture cPictire
		@ Li,199 	 Psay nVALSOF309 Picture cPictValor    
	EndIf

	NgSomaLi(58) 
	@ Li,000 	 Psay STR0026 //"OUTUBRO"
	If nAnoSEL1 <> 0
		@ Li,012 	 Psay nINFREC110 Picture cPictire
		@ Li,029 	 Psay nVALREC110 Picture cPictValor  	
		@ Li,046 	 Psay nINFSOF110 Picture cPictire 
		@ Li,063 	 Psay nVALSOF110 Picture cPictValor     
	EndIf

	If nAnoSEL2 <> 0
		@ Li,080 	 Psay nINFREC210 Picture cPictire
		@ Li,097 	 Psay nVALREC210 Picture cPictValor   	
		@ Li,114 	 Psay nINFSOF210 Picture cPictire
		@ Li,131 	 Psay nVALSOF210 Picture cPictValor   
	Endif

	If nAnoSEL3 <> 0
		@ Li,148 	 Psay nINFREC310 Picture cPictire
		@ Li,165 	 Psay nVALREC310 Picture cPictValor  	
		@ Li,182 	 Psay nINFSOF310 Picture cPictire
		@ Li,199 	 Psay nVALSOF310 Picture cPictValor    
	EndIf

	NgSomaLi(58) 
	@ Li,000 	 Psay STR0027 //"NOVEMBRO"
	If nAnoSEL1 <> 0
		@ Li,012 	 Psay nINFREC111 Picture cPictire
		@ Li,029 	 Psay nVALREC111 Picture cPictValor   	
		@ Li,046 	 Psay nINFSOF111 Picture cPictire
		@ Li,063 	 Psay nVALSOF111 Picture cPictValor   
	EndIf

	If nAnoSEL2 <> 0
		@ Li,080 	 Psay nINFREC211 Picture cPictire 
		@ Li,097 	 Psay nVALREC211 Picture cPictValor     	
		@ Li,114 	 Psay nINFSOF211 Picture cPictire 
		@ Li,131 	 Psay nVALSOF211 Picture cPictValor    
	Endif

	If nAnoSEL3 <> 0
		@ Li,148 	 Psay nINFREC311 Picture cPictire
		@ Li,165 	 Psay nVALREC311 Picture cPictValor   	
		@ Li,182 	 Psay nINFSOF311 Picture cPictire 
		@ Li,199 	 Psay nVALSOF311 Picture cPictValor      
	EndIf

	NgSomaLi(58) 
	@ Li,000 	 Psay STR0028 //"DEZEMBRO"
	If nAnoSEL1 <> 0
		@ Li,012 	 Psay nINFREC112 Picture cPictire 
		@ Li,029 	 Psay nVALREC112 Picture cPictValor  	
		@ Li,046 	 Psay nINFSOF112 Picture cPictire
		@ Li,063 	 Psay nVALSOF112 Picture cPictValor    
	EndIf

	If nAnoSEL2 <> 0
		@ Li,080 	 Psay nINFREC212 Picture cPictire
		@ Li,097 	 Psay nVALREC212 Picture cPictValor   	
		@ Li,114 	 Psay nINFSOF212 Picture cPictire
		@ Li,131 	 Psay nVALSOF212 Picture cPictValor    
	Endif

	If nAnoSEL3 <> 0
		@ Li,148 	 Psay nINFREC312 Picture cPictire
		@ Li,165 	 Psay nVALREC312 Picture cPictValor  	
		@ Li,182 	 Psay nINFSOF312 Picture cPictire 
		@ Li,199 	 Psay nVALSOF312 Picture cPictValor 
	EndIf

	NgSomaLi(58)
	@ Li,000 	 Psay Replicate("-",213)
	NgSomaLi(58)

	@ Li,000 	 Psay STR0029 //"TOTAL"

	If nAnoSEL1 <> 0
		@ Li,012 	 Psay nTOTREC1 Picture cPictire
		@ Li,029 	 Psay nVALREC1 Picture cPictValor   
		@ Li,046 	 Psay nTOTSOF1 Picture cPictire
		@ Li,063 	 Psay nVALSOF1 Picture cPictValor   
	EndIf

	If nAnoSEL2 <> 0
		@ Li,080 	 Psay nTOTREC2 Picture cPictire
		@ Li,097 	 Psay nVALREC2 Picture cPictValor  	
		@ Li,114 	 Psay nTOTSOF2 Picture cPictire
		@ Li,131 	 Psay nVALSOF2 Picture cPictValor    
	EndIf

	If nAnoSEL3 <> 0
		@ Li,148 	 Psay nTOTREC3 Picture cPictire
		@ Li,165 	 Psay nVALREC3 Picture cPictValor   
		@ Li,182 	 Psay nTOTSOF3 Picture cPictire
		@ Li,199 	 Psay nVALSOF3 Picture cPictValor   	
	EndIf

	RODA(nCNTIMPR,cRODATXT,TAMANHO)       

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Devolve a condicao original do arquivo principal             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RetIndex('TRH')
	Set Filter To
	Set Device To Screen
	If aReturn[5] == 1
		Set Printer To
		dbCommitAll()
		OurSpool(WNREL)
	EndIf
	MS_FLUSH()

Return Nil  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |R390DIFDT | Autor ³ Ricardo Dal Ponte     ³ Data ³ 13/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao dos Parametros	                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR390                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function R390DIFDT() 

	If !Empty(MV_PAR01) .AND. !Empty(MV_PAR02)
		If (MV_PAR01 + 2) < MV_PAR02
			MsgStop(STR0030,STR0031) //"Intervalo de consulta não pode ser superior a 2 anos!"###"Atenção"
			Return .F.	
		Endif 
		If MV_PAR02 < MV_PAR01
			MsgStop(STR0035,STR0031)  //"Até Ano não pode ser menor que o parâmetro De Ano!"###"Atenção"
			Return .F.	
		Endif
	Endif
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |MNTR390TMP| Autor ³ Ricardo Dal Ponte     ³ Data ³ 08/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Geracao do arquivo temporario                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR390                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function MNTR390TMP()
	cAliasQry := GetNextAlias()

	cQuery := " SELECT TRX.TRX_DTINFR, TRX.TRX_DTREC, TRX.TRX_MULTA, TSH.TSH_CODINF, TSH.TSH_FLGTPM, TRX.TRX_VALPAG "
	cQuery += " FROM " + RetSqlName("TRX")+" TRX, " + RetSqlName("TSH")+" TSH "
	cQuery += " WHERE "
	cQuery += "       (TRX.TRX_DTINFR  >= '"+AllTrim(Str(MV_PAR01))+"0101'"
	cQuery += " AND    TRX.TRX_DTINFR  <= '"+AllTrim(Str(MV_PAR02))+"1231')"
	//cQuery += " AND   TRX.TRX_FILIAL = '"+xFilial("TRX")+"'"
	//cQuery += " AND   TSH.TSH_FILIAL = TRX.TRX_FILIAL "
	cQuery += " AND   TSH.TSH_CODINF = TRX.TRX_CODINF "
	cQuery += " AND   TRX.D_E_L_E_T_ <> '*' "
	cQuery += " AND   TSH.D_E_L_E_T_ <> '*' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)  

	dbSelectArea(cAliasQry)			   
	dbGoTop()

	nAnoSEL1 := MV_PAR02
	nSomaAno := MV_PAR02
	nAnoSEL2 := 0
	nAnoSEL3 := 0

	nSomaAno -=1

	If nSomaAno >= MV_PAR01
		nAnoSEL2 := nSomaAno
	EndIf

	nSomaAno -=1

	If nSomaAno >= MV_PAR01
		nAnoSEL3 := nSomaAno
	EndIf

	If Eof()
		(cALIASQRY)->(dbCloseArea())
		Return
	Endif

	SetRegua(LastRec())

	While !Eof()
		IncProc(STR0012) //"Aguarde..."

		If MV_PAR03 = 2 .And. (cAliasQry)->TSH_FLGTPM <> "1"
			dbSkip()
			Loop   
		EndIf

		If MV_PAR03 = 3 .And. (cAliasQry)->TSH_FLGTPM <> "2"
			dbSkip()
			Loop   
		EndIf                                               

		nAnoLTR := Val(Substr((cAliasQry)->TRX_DTREC, 1, 4))
		nMesLTR := Val(Substr((cAliasQry)->TRX_DTREC, 5, 2))

		nAnoLT := Val(Substr((cAliasQry)->TRX_DTINFR, 1, 4))
		nMesLT := Val(Substr((cAliasQry)->TRX_DTINFR, 5, 2))
		nDiaLT := Val(Substr((cAliasQry)->TRX_DTINFR, 7, 2))

		dDataCalc := DTOS(dDataBase)

		//INFRACOES RECEBIDAS
		If nAnoLTR = nAnoSEL1 
			Do Case 	
				Case nMesLTR = 1; nINFREC101 += 1; nVALREC101 += (cAliasQry)->TRX_VALPAG
				Case nMesLTR = 2; nINFREC102 += 1; nVALREC102 += (cAliasQry)->TRX_VALPAG
				Case nMesLTR = 3; nINFREC103 += 1; nVALREC103 += (cAliasQry)->TRX_VALPAG
				Case nMesLTR = 4; nINFREC104 += 1; nVALREC104 += (cAliasQry)->TRX_VALPAG
				Case nMesLTR = 5; nINFREC105 += 1; nVALREC105 += (cAliasQry)->TRX_VALPAG
				Case nMesLTR = 6; nINFREC106 += 1; nVALREC106 += (cAliasQry)->TRX_VALPAG
				Case nMesLTR = 7; nINFREC107 += 1; nVALREC107 += (cAliasQry)->TRX_VALPAG
				Case nMesLTR = 8; nINFREC108 += 1; nVALREC108 += (cAliasQry)->TRX_VALPAG
				Case nMesLTR = 9; nINFREC109 += 1; nVALREC109 += (cAliasQry)->TRX_VALPAG
				Case nMesLTR = 10; nINFREC110 += 1; nVALREC110 += (cAliasQry)->TRX_VALPAG
				Case nMesLTR = 11; nINFREC111 += 1; nVALREC111 += (cAliasQry)->TRX_VALPAG
				Case nMesLTR = 12; nINFREC112 += 1; nVALREC112 += (cAliasQry)->TRX_VALPAG
			End Case

			nTOTREC1 += 1
			nVALREC1 += (cAliasQry)->TRX_VALPAG
		EndIf

		If nAnoLTR = nAnoSEL2 
			Do Case 	
				Case nMesLTR = 1; nINFREC201 += 1; nVALREC201 += (cAliasQry)->TRX_VALPAG
				Case nMesLTR = 2; nINFREC202 += 1; nVALREC202 += (cAliasQry)->TRX_VALPAG
				Case nMesLTR = 3; nINFREC203 += 1; nVALREC203 += (cAliasQry)->TRX_VALPAG
				Case nMesLTR = 4; nINFREC204 += 1; nVALREC204 += (cAliasQry)->TRX_VALPAG
				Case nMesLTR = 5; nINFREC205 += 1; nVALREC205 += (cAliasQry)->TRX_VALPAG
				Case nMesLTR = 6; nINFREC206 += 1; nVALREC206 += (cAliasQry)->TRX_VALPAG
				Case nMesLTR = 7; nINFREC207 += 1; nVALREC207 += (cAliasQry)->TRX_VALPAG
				Case nMesLTR = 8; nINFREC208 += 1; nVALREC208 += (cAliasQry)->TRX_VALPAG
				Case nMesLTR = 9; nINFREC209 += 1; nVALREC209 += (cAliasQry)->TRX_VALPAG
				Case nMesLTR = 10; nINFREC210 += 1; nVALREC210 += (cAliasQry)->TRX_VALPAG
				Case nMesLTR = 11; nINFREC211 += 1; nVALREC211 += (cAliasQry)->TRX_VALPAG
				Case nMesLTR = 12; nINFREC212 += 1; nVALREC212 += (cAliasQry)->TRX_VALPAG
			End Case

			nTOTREC2 += 1 
			nVALREC2 += (cAliasQry)->TRX_VALPAG		
		EndIf

		If nAnoLTR = nAnoSEL3 
			Do Case 	
				Case nMesLTR = 1; nINFREC301 += 1; nVALREC301 += (cAliasQry)->TRX_VALPAG
				Case nMesLTR = 2; nINFREC302 += 1; nVALREC302 += (cAliasQry)->TRX_VALPAG
				Case nMesLTR = 3; nINFREC303 += 1; nVALREC303 += (cAliasQry)->TRX_VALPAG
				Case nMesLTR = 4; nINFREC304 += 1; nVALREC304 += (cAliasQry)->TRX_VALPAG
				Case nMesLTR = 5; nINFREC305 += 1; nVALREC305 += (cAliasQry)->TRX_VALPAG
				Case nMesLTR = 6; nINFREC306 += 1; nVALREC306 += (cAliasQry)->TRX_VALPAG
				Case nMesLTR = 7; nINFREC307 += 1; nVALREC307 += (cAliasQry)->TRX_VALPAG
				Case nMesLTR = 8; nINFREC308 += 1; nVALREC308 += (cAliasQry)->TRX_VALPAG
				Case nMesLTR = 9; nINFREC309 += 1; nVALREC309 += (cAliasQry)->TRX_VALPAG
				Case nMesLTR = 10; nINFREC310 += 1; nVALREC310 += (cAliasQry)->TRX_VALPAG
				Case nMesLTR = 11; nINFREC311 += 1; nVALREC311 += (cAliasQry)->TRX_VALPAG
				Case nMesLTR = 12; nINFREC312 += 1; nVALREC312 += (cAliasQry)->TRX_VALPAG
			End Case

			nTOTREC3 += 1
			nVALREC3 += (cAliasQry)->TRX_VALPAG		
		EndIf

		//INFRACOES SOFRIDAS
		If nAnoLT = nAnoSEL1 
			Do Case 	
				Case nMesLT = 1; nINFSOF101 += 1; nVALSOF101 += (cAliasQry)->TRX_VALPAG
				Case nMesLT = 2; nINFSOF102 += 1; nVALSOF102 += (cAliasQry)->TRX_VALPAG
				Case nMesLT = 3; nINFSOF103 += 1; nVALSOF103 += (cAliasQry)->TRX_VALPAG
				Case nMesLT = 4; nINFSOF104 += 1; nVALSOF104 += (cAliasQry)->TRX_VALPAG
				Case nMesLT = 5; nINFSOF105 += 1; nVALSOF105 += (cAliasQry)->TRX_VALPAG
				Case nMesLT = 6; nINFSOF106 += 1; nVALSOF106 += (cAliasQry)->TRX_VALPAG
				Case nMesLT = 7; nINFSOF107 += 1; nVALSOF107 += (cAliasQry)->TRX_VALPAG
				Case nMesLT = 8; nINFSOF108 += 1; nVALSOF108 += (cAliasQry)->TRX_VALPAG
				Case nMesLT = 9; nINFSOF109 += 1; nVALSOF109 += (cAliasQry)->TRX_VALPAG
				Case nMesLT = 10; nINFSOF110 += 1; nVALSOF110 += (cAliasQry)->TRX_VALPAG
				Case nMesLT = 11; nINFSOF111 += 1; nVALSOF111 += (cAliasQry)->TRX_VALPAG
				Case nMesLT = 12; nINFSOF112 += 1; nVALSOF112 += (cAliasQry)->TRX_VALPAG
			End Case

			nTOTSOF1 += 1
			nVALSOF1 += (cAliasQry)->TRX_VALPAG		
		EndIf

		If nAnoLT = nAnoSEL2 
			Do Case 	
				Case nMesLT = 1; nINFSOF201 += 1; nVALSOF201 += (cAliasQry)->TRX_VALPAG
				Case nMesLT = 2; nINFSOF202 += 1; nVALSOF202 += (cAliasQry)->TRX_VALPAG
				Case nMesLT = 3; nINFSOF203 += 1; nVALSOF203 += (cAliasQry)->TRX_VALPAG
				Case nMesLT = 4; nINFSOF204 += 1; nVALSOF204 += (cAliasQry)->TRX_VALPAG
				Case nMesLT = 5; nINFSOF205 += 1; nVALSOF205 += (cAliasQry)->TRX_VALPAG
				Case nMesLT = 6; nINFSOF206 += 1; nVALSOF206 += (cAliasQry)->TRX_VALPAG
				Case nMesLT = 7; nINFSOF207 += 1; nVALSOF207 += (cAliasQry)->TRX_VALPAG
				Case nMesLT = 8; nINFSOF208 += 1; nVALSOF208 += (cAliasQry)->TRX_VALPAG
				Case nMesLT = 9; nINFSOF209 += 1; nVALSOF209 += (cAliasQry)->TRX_VALPAG
				Case nMesLT = 10; nINFSOF210 += 1; nVALSOF210 += (cAliasQry)->TRX_VALPAG
				Case nMesLT = 11; nINFSOF211 += 1; nVALSOF211 += (cAliasQry)->TRX_VALPAG
				Case nMesLT = 12; nINFSOF212 += 1; nVALSOF212 += (cAliasQry)->TRX_VALPAG
			End Case

			nTOTSOF2 += 1
			nVALSOF2 += (cAliasQry)->TRX_VALPAG			
		EndIf

		If nAnoLT = nAnoSEL3 
			Do Case 	
				Case nMesLT = 1; nINFSOF301 += 1; nVALSOF301 += (cAliasQry)->TRX_VALPAG
				Case nMesLT = 2; nINFSOF302 += 1; nVALSOF302 += (cAliasQry)->TRX_VALPAG
				Case nMesLT = 3; nINFSOF303 += 1; nVALSOF303 += (cAliasQry)->TRX_VALPAG
				Case nMesLT = 4; nINFSOF304 += 1; nVALSOF304 += (cAliasQry)->TRX_VALPAG
				Case nMesLT = 5; nINFSOF305 += 1; nVALSOF305 += (cAliasQry)->TRX_VALPAG
				Case nMesLT = 6; nINFSOF306 += 1; nVALSOF306 += (cAliasQry)->TRX_VALPAG
				Case nMesLT = 7; nINFSOF307 += 1; nVALSOF307 += (cAliasQry)->TRX_VALPAG
				Case nMesLT = 8; nINFSOF308 += 1; nVALSOF308 += (cAliasQry)->TRX_VALPAG
				Case nMesLT = 9; nINFSOF309 += 1; nVALSOF309 += (cAliasQry)->TRX_VALPAG
				Case nMesLT = 10; nINFSOF310 += 1; nVALSOF310 += (cAliasQry)->TRX_VALPAG
				Case nMesLT = 11; nINFSOF311 += 1; nVALSOF311 += (cAliasQry)->TRX_VALPAG
				Case nMesLT = 12; nINFSOF312 += 1; nVALSOF312 += (cAliasQry)->TRX_VALPAG
			End Case

			nTOTSOF3 += 1
			nVALSOF3 += (cAliasQry)->TRX_VALPAG			
		EndIf

		dbSelectArea(cAliasQry)			   
		dbSkip()
	End
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |MNR390ANO | Autor ³Evaldo Cevinscki Jr.   ³ Data ³ 23/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o |Valida o ano digitado no grupo de perguntas                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR390                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNR390ANO(nPar)

	cAno := AllTrim(Str(IF(nPar==1,MV_PAR01,MV_PAR02)))
	If Len(cAno) != 4
		MsgStop(STR0037,STR0031) //"O Ano informado deverá conter 4 dígitos!"###"ATENÇÃO"
		Return .f.
	Endif
	If (nPar = 1 .AND. MV_PAR01 > Year(dDATABASE)) .OR. (nPar = 2 .AND. MV_PAR02 > Year(dDATABASE))
		MsgStop(STR0036+AllTrim(Str(Year(dDATABASE)))+'!',STR0031)  //"Ano informado não poderá ser maior que "###"ATENÇÃO"
		Return .f.
	Endif

Return .t.