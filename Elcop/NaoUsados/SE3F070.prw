#INCLUDE "rwmake.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TbiCode.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

User Function SE3F070() 

Local aArea 	:= GetArea()
Local aAreaSE1 	:= SE1->(GetArea() )
Local cNum      := SE1->E1_NUM

SE1->(DBselectArea("SE1"))  // posiciono no E1
SE1->(DbSetOrder(1))
SE1->(DbSeek(xFilial("SE1")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO)) 
//If !Empty(SE1->E1_BAIXA) .and. !( SE1->E1_TIPO $ MVABATIM .and. SE1->E1_SALDO > 0 )// Validaçao se Baixa Parcial ou Total 
    If !Empty(SE1->E1_BAIXA) .and. !( SE1->E1_TIPO $ MVABATIM .or.SE1->E1_TIPO $ MVNOTAFIS .and. SE1->E1_SALDO > 0 )// Validaçao se Baixa Parcial ou Total
	lRetVM := MsgYesNo("deseja efetuar a baixa do impostos?", "baixa de impostos")
	If lRetVM
		
		If(SELECT("QRYSE1") > 0)
			QRYSE1->(DBCLOSEAREA()) 
		Endif
		
		cQry:=" SELECT SE1.* "
		cQry+=" FROM " + RetSqlName("SE1")+ " SE1 "
		cQry+=" WHERE SE1.D_E_L_E_T_	<> '*'
		cQry+=" 	AND SE1.E1_FILIAL 	= '"+xFilial("SE1")+"'"
		cQry+=" 	AND SE1.E1_NUM  	= '"+SE1->E1_NUM+"' "
	    cQry+=" 	AND SE1.E1_PREFIXO	= '"+SE1->E1_PREFIXO+"' " 
	    	TcQuery cQry New Alias "QRYSE1" 
		// 	cQry+="     AND SE1.E1_TIPO     <> 'NF'  "
		//	cQry+=" 	AND SE1.E1_SALDO	> 0 "
		//	cQry+="     AND SE1.E1_IRRF     > 0 "
		//	cQry+="     AND SE1.E1_INSS     > 0 "
		//	cQry+="     AND SE1.E1_ISS      > 0 "                                    
		//	cQry+="     AND SE1.E1_COFINS   > 0 "
		//	cQry+="     AND SE1.E1_PIS      > 0 "
		//	cQry+="     AND SE1.E1_CSLL     > 0 "
	 
	 	
	  	QRYSE1->(DbGoTop())
	  	While QRYSE1->( !EOF() )
   //		DbSelectArea("QRYSE1")
		SE1->(DbGoTop())           
		SE1->(DbSetOrder(1)) 
		If SE1->(DbSeek(QRYSE1->E1_FILIAL+QRYSE1->E1_PREFIXO+QRYSE1->E1_NUM+QRYSE1->E1_PARCELA+QRYSE1->E1_TIPO) ) 
	
			If SE1->E1_SALDO > 0   
		
			Msgalert("Executando Baixa do Titulo"+" "+SE1->E1_NUM+" "+"TIPO"+" "+E1_TIPO)
				cHistBaixa := "Baixa impostos"
				   RECLOCK("SE1", .F.) 
				   
				   SE1->E1_BAIXA  := DDATABASE 
				   SE1->E1_SALDO  := 0  
				   SE1->E1_STATUS :="B" 
				   
				   If SE1-> E1_TIPO == 'NF'
				   SE1->E1_SALDO  := (SE1->E1_PIS-SE1->E1_COFINS-SE1->E1_CSSL)
				   SE1->E1_COFINS := 0
				   SE1->E1_PIS    := 0 
				   SE1->E1_CSLL   := 0
				   
			       SE1->(MsUnlock())    
				   
			
		 //	Else
		   //		Alert("O título não possui saldo a pagar em aberto")
		 //	EndIf
			
	  //	Else
		//	Alert("O título a pagar não foi localizado")
	  //	EndIf  
		
	             
		
	QRYSE1->(DbSkip())  

MsgAlert("Executado com Sucesso!!")

RestArea(aAreaSE1)
RestArea(aArea)
  Return





