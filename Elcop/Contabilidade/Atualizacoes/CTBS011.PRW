#INCLUDE "CTBS011.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "ECD.CH"
#INCLUDE "ECF.CH"

//amarracao ctbs103 
Static lFWCodFil 	:= FindFunction("FWCodFil")
Static __CodRev		:= ""
Static __lErro	 	:= .F.
Static __aDtLP	 	:= {}
Static __lBlind	 	:= IsBlind() 
Static __ECDIndTip 	:= {}
Static __aParamExp
Static __lExistCSQ  := NIL
Static cS011CNPJ	:= ""
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEcdExport บAutor  ณRenato F. Campos    บ Data ณ  03/01/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function EcdExport( lEnd, oProcess, aParamExp, cMatriz, cModEsc, bIncTree,  bEcdFatoCtb, aPerCalTri )
Local aArea    	:= GetArea()
Local lRet	 	:= .T.
Local aTpSald  	:= {}
Local lImpAntLP := ( !Empty(aParamExp[ECD_DATA_LP]) )
Local aEntRef 	:= {"00","10","20"}
Local cEntRef 	:= "  "
Local cCodPla	:= ' '
Local cVerPla	:= ' '
Local cTpApur  	:= If(aParamExp[ ECD_PER_APURACAO ]==1, "A", "T")
Local nX
Local nRecCS0 	:= 0
Local cTmpFil
Local cTmpFil1
Local aTmpFil	:= {}
Local nI        := 0
Local cMotSubst := ""

Private lPerCalTri 	:= If(aParamExp[ECD_TRI_UNI]==1,.T., .F.)
Private aEmpFil	 	:= Array(10)

Default cMatriz 	:= ""
Default oProcess	:= Nil
Default bIncTree   	:= {||.T.}
Default bEcdFatoCtb	:= {||.T.}
Default aPerCalTri  := {}

If __lExistCSQ  == NIL
	__lExistCSQ  := Exist_CSQ()
EndIf

cCodPla	:= aParamExp[ECD_COD_PLA]
cVerPla	:= aParamExp[ECD_VER_PLA]

If lLeiaute7
	Do Case
		Case aParamExp[ECD_MOT_SUBST] == 2
			cMotSubst := "001"
		Case aParamExp[ECD_MOT_SUBST] == 3
			cMotSubst := "002"
		Case aParamExp[ECD_MOT_SUBST] == 4
			cMotSubst := "003"
		Case aParamExp[ECD_MOT_SUBST] == 5
			cMotSubst := "004"
		Case aParamExp[ECD_MOT_SUBST] == 6
			cMotSubst := "005"
		Case aParamExp[ECD_MOT_SUBST] == 7
			cMotSubst := "099"
	End Case
EndIf

If cModEsc = "FCO" .And. aParamExp[ECD_QUALI_PJ] > 0
	cEntRef 	:= aEntRef[ aParamExp[ECD_QUALI_PJ] ]
EndIf

If oProcess <> Nil
	oProcess:SetRegua1(15)
Endif

EcdNewMsg() // inicio o controle de mensagens de erro

lRet := EcdVldParam( aParamExp, cModEsc, aTpSald ) // Efetua a valida็ใo dos parametros passados

If lRet
	EcdTpSald(aParamExp, cModEsc)  //alimenta variavel static contendo de-para dos tipos de saldo
	lRet := GeraRevisao( oProcess, aParamExp, cMatriz, cModEsc, cEntRef, bIncTree, @nRecCS0 )
	
	If lRet .And. lLeiaute2
		__aParamExp := aClone(aParamExp)
	
		CS0->( dbGoto(nRecCS0) )
		Eval(bEcdFatoCtb)
	EndIf
	
Endif  

IF lRet .And. aParamExp[ECD_PROC_CAD]
	lRet := ECDExpCad(oProcess, aParamExp,__CodRev, cModEsc)
Endif

If lRet .And. aParamExp[ECD_PROC_MOV]
	If cModEsc == "ECD" .Or. ( Len(aTpSald) > 0 )		
		lRet := ExportaMov( oProcess, aParamExp[ECD_AFILS], aParamExp[ECD_CALENDARIO], aParamExp[ECD_DATA_INI],;
								aParamExp[ECD_DATA_FIM], aParamExp[ECD_MOEDA], aParamExp[ECD_TIPO_SALDO],;
								aParamExp[ECD_CONTA_INI], aParamExp[ECD_CONTA_FIM], aParamExp[ECD_PROC_CUSTO], aTpSald, cEntRef, cModEsc, cCodPla,cVerPla,@cTmpFil)
	EndIf

	If lRet .And. cModEsc == "FCO"
		If cTpApur=="A"  // se for anual
			lRet := ExportaMov( oProcess, aParamExp[ECD_AFILS], aParamExp[ECD_CALENDARIO], aParamExp[ECD_DATA_LP],;
								aParamExp[ECD_DATA_LP], aParamExp[ECD_MOEDA], aParamExp[ECD_TIPO_SALDO],;
								aParamExp[ECD_CONTA_INI], aParamExp[ECD_CONTA_FIM], aParamExp[ECD_PROC_CUSTO], /*aTpSald*/, cEntRef, cModEsc, cCodPla,cVerPla,@cTmpFil1)
		Else	// se for trimestral							
			aDatApur := CalendTrim( aParamExp[ECD_CALENDARIO] )
			If Len(aDatApur) != 4
				MsgAlert( STR0055 ) //"Calendario informado devera conter 4 periodos (trimestral)"				
				lRet := .F.
			Else
				For nX := 1 TO Len(aDatApur)
					AADD(aTmpFil,' ')
					lRet := ExportaMov( oProcess, aParamExp[ECD_AFILS], aParamExp[ECD_CALENDARIO], aDatApur[nX,2],;
										aDatApur[nX,2], aParamExp[ECD_MOEDA], aParamExp[ECD_TIPO_SALDO],;
										aParamExp[ECD_CONTA_INI], aParamExp[ECD_CONTA_FIM], aParamExp[ECD_PROC_CUSTO], /*aTpSald*/, cEntRef, cModEsc, cCodPla,cVerPla,@aTmpFil[nX] )
					If !lRet
						Exit
					EndIf
				Next
			EndIf
		EndIf
	EndIf

Endif

If lRet .And. aParamExp[ECD_PROC_SALDO]
	lRet := ExportaBalanc(	oProcess,	aParamExp[ECD_AFILS],aParamExp[ECD_DATA_INI],aParamExp[ECD_DATA_FIM],;
							aParamExp[ECD_DATA_FIM], aParamExp[ECD_MOEDA], aParamExp[ECD_TIPO_SALDO], aParamExp[ECD_CONTA_INI],;
							aParamExp[ECD_CONTA_FIM], aParamExp[ECD_DATA_LP], aParamExp[ECD_PROC_CUSTO],aParamExp[ECD_CALENDARIO], ECD_SITESP[ aParamExp[ECD_SIT_ESP] ], cModEsc, lImpAntLP, cEntRef, cTpApur, , , , cCodPla,cVerPla )

	IF lRet .And. aParamExp[ECD_IND_ESC] == 4
		lRet :=	ExportaDiario( oProcess, aParamExp[ECD_AFILS],aParamExp[ECD_DATA_INI],aParamExp[ECD_DATA_FIM],aParamExp[ECD_MOEDA], aParamExp[ECD_TIPO_SALDO], aParamExp[ECD_CONTA_INI], aParamExp[ECD_CONTA_FIM], aParamExp[ECD_PROC_CUSTO], aParamExp[ECD_DATA_LP],aParamExp[ECD_CALENDARIO])
	Endif
Endif

If lRet .And. cModEsc == "ECD" .And. aParamExp[ECD_PROC_DEM]
	
	If lPerCalTri

		lRet := ExpDemTri(__CodRev,aPerCalTri,oProcess,aParamExp[ECD_AFILS],aParamExp[ECD_COD_BALPAT],aParamExp[ECD_MOEDA],aParamExp[ECD_TIPO_SALDO],;
									aParamExp[ECD_DATA_DEMINI],aParamExp[ECD_DATA_DEMFIM],ECD_BALANCO,aParamExp[ECD_CALENDARIO])

		lRet := ExpDemTri(__CodRev,aPerCalTri,oProcess,aParamExp[ECD_AFILS],aParamExp[ECD_COD_DRE],aParamExp[ECD_MOEDA],aParamExp[ECD_TIPO_SALDO],;
									aParamExp[ECD_DATA_DEMINI],aParamExp[ECD_DATA_DEMFIM],ECD_DRE,aParamExp[ECD_CALENDARIO])									
		
	Else
		lRet := lRet .And. ExportaDemonst( oProcess, aParamExp[ECD_AFILS], aParamExp[ECD_COD_BALPAT] , aParamExp[ECD_MOEDA]    , aParamExp[ECD_TIPO_SALDO],;
											aParamExp[ECD_DATA_INI], aParamExp[ECD_DATA_FIM] , aParamExp[ECD_DATA_DEMINI],;
											aParamExp[ECD_DATA_DEMFIM], aParamExp[ECD_DATA_LP], ECD_BALANCO, aParamExp[ECD_CALENDARIO],nil,nil,"12")
		lRet := lRet .And. ExportaDemonst( oProcess,aParamExp[ECD_AFILS], aParamExp[ECD_COD_DRE], aParamExp[ECD_MOEDA]   , aParamExp[ECD_TIPO_SALDO], ;
											aParamExp[ECD_DATA_INI]  , aParamExp[ECD_DATA_FIM], aParamExp[ECD_DATA_DEMINI],;
											aParamExp[ECD_DATA_DEMFIM], aParamExp[ECD_DATA_LP], ECD_DRE , aParamExp[ECD_CALENDARIO],nil,nil,"12")
	EndIf

	If lLeiaute2
		If aParamExp[ECD_SEL_DLPA_DMPL] == 1
			If lPerCalTri
				lRet := ExpDemTri(__CodRev,aPerCalTri,oProcess,aParamExp[ECD_AFILS],aParamExp[ECD_COD_DLPA],aParamExp[ECD_MOEDA],aParamExp[ECD_TIPO_SALDO],;
									aParamExp[ECD_DATA_DEMINI],aParamExp[ECD_DATA_DEMFIM],ECD_DLPA,aParamExp[ECD_CALENDARIO])
				
			Else
				lRet := lRet .And. ExportaDemonst( oProcess,aParamExp[ECD_AFILS], aParamExp[ECD_COD_DLPA], aParamExp[ECD_MOEDA]   , aParamExp[ECD_TIPO_SALDO], ;
												aParamExp[ECD_DATA_INI]  , aParamExp[ECD_DATA_FIM], aParamExp[ECD_DATA_DEMINI],;
												aParamExp[ECD_DATA_DEMFIM], aParamExp[ECD_DATA_LP], ECD_DLPA , aParamExp[ECD_CALENDARIO] )
			EndIf
		Else
			If lPerCalTri
				lRet := ExpDemTri(__CodRev,aPerCalTri,oProcess,aParamExp[ECD_AFILS],aParamExp[ECD_COD_DMPL],aParamExp[ECD_MOEDA],aParamExp[ECD_TIPO_SALDO],;
									aParamExp[ECD_DATA_DEMINI],aParamExp[ECD_DATA_DEMFIM],ECD_DMPL,aParamExp[ECD_CALENDARIO])
			Else
				lRet := lRet .And. ExportaDemonst( oProcess,aParamExp[ECD_AFILS], aParamExp[ECD_COD_DMPL], aParamExp[ECD_MOEDA]   , aParamExp[ECD_TIPO_SALDO], ;
											aParamExp[ECD_DATA_INI]  , aParamExp[ECD_DATA_FIM], aParamExp[ECD_DATA_DEMINI],;
											aParamExp[ECD_DATA_DEMFIM], aParamExp[ECD_DATA_LP], ECD_DMPL , aParamExp[ECD_CALENDARIO] )
			EndIf
		EndIf	
		
		If lPerCalTri
			lRet := ExpDemTri(__CodRev,aPerCalTri,oProcess,aParamExp[ECD_AFILS],aParamExp[ECD_COD_DFC],aParamExp[ECD_MOEDA],aParamExp[ECD_TIPO_SALDO],;
									aParamExp[ECD_DATA_DEMINI],aParamExp[ECD_DATA_DEMFIM],ECD_DFC,aParamExp[ECD_CALENDARIO])

			lRet := ExpDemTri(__CodRev,aPerCalTri,oProcess,aParamExp[ECD_AFILS],aParamExp[ECD_COD_DVA],aParamExp[ECD_MOEDA],aParamExp[ECD_TIPO_SALDO],;
									aParamExp[ECD_DATA_DEMINI],aParamExp[ECD_DATA_DEMFIM],ECD_DVA,aParamExp[ECD_CALENDARIO])
		Else
			lRet := lRet .And. ExportaDemonst( oProcess,aParamExp[ECD_AFILS], aParamExp[ECD_COD_DFC], aParamExp[ECD_MOEDA]   , aParamExp[ECD_TIPO_SALDO], ;
												aParamExp[ECD_DATA_INI]  , aParamExp[ECD_DATA_FIM], aParamExp[ECD_DATA_DEMINI],;
												aParamExp[ECD_DATA_DEMFIM], aParamExp[ECD_DATA_LP], ECD_DFC , aParamExp[ECD_CALENDARIO] )

			lRet := lRet .And. ExportaDemonst( oProcess,aParamExp[ECD_AFILS], aParamExp[ECD_COD_DVA], aParamExp[ECD_MOEDA]   , aParamExp[ECD_TIPO_SALDO], ;
											aParamExp[ECD_DATA_INI]  , aParamExp[ECD_DATA_FIM], aParamExp[ECD_DATA_DEMINI],;
											aParamExp[ECD_DATA_DEMFIM], aParamExp[ECD_DATA_LP], ECD_DVA , aParamExp[ECD_CALENDARIO] )
		EndIf
	EndIf

	
	If lLeiaute2 
		lRet := lRet .And. ExportaOutDem( oProcess,aParamExp[ECD_DATA_INI], aParamExp[ECD_DATA_FIM], aParamExp[ECD_DATA_DEMINI],	;
											aParamExp[ECD_DATA_DEMFIM], aParamExp[ECD_OUT_DEM],aParamEcd[ECD_OUT_RAP],aParamEcd[ECD_OUT_DFC], ;
											aParamEcd[ECD_OUT_DVA], aParamEcd[ECD_OUT_NTE], aParamEcd[ECD_OUT_RADM] , ;
											aParamEcd[ECD_OUT_PRAU], aParamEcd[ECD_OUT_OTR], aParamEcd[ECD_OUT_TVFS], cModEsc, cMotSubst   )
	Else
		lRet := lRet .And. ExportaOutDem( oProcess,aParamExp[ECD_DATA_INI], aParamExp[ECD_DATA_FIM], aParamExp[ECD_DATA_DEMINI],	;
											aParamExp[ECD_DATA_DEMFIM], aParamExp[ECD_OUT_DEM],,,,,,,,, cModEsc   )
	
	EndIf	 									

Endif

RestArea( aArea )

CtbTmpErase(cTmpFil)
CtbTmpErase(cTmpFil1)

For nX	:= 1 To Len(aTmpFil)
	CtbTmpErase(aTmpFil[nX])
Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEcdVldParamบAutor  ณMicrosiga          บ Data ณ  03/01/10   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Efetua a valida็ใo dos parametros passados                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function EcdVldParam( aParamExp, cModEsc, aTpSald )
Local lRet := .T.
Local lRetSld := .T.

Default cModEsc 		:= "ECD"
Default aTpSald 	:= {}

If Empty( aParamExp[ ECD_CODEMP ] )
	EcdAddMsg( STR0006 , "2" ) //"Nenhuma Empresa informada!"
	lRet := .F.
Endif

If Len( aParamExp[ ECD_AFILS ] ) <= 0
	EcdAddMsg( STR0007 , "2" ) //"Nenhuma Filial informada!"
	lRet := .F.
Endif

If Empty( aParamExp[ ECD_TIPOESC ] )
	EcdAddMsg( STR0008 , "2" ) //"Tipo de Escritura็ใo nใo informada!"
	lRet := .F.
Endif

If Empty( aParamExp[ ECD_SIT_ESP ] )
	EcdAddMsg( STR0009 , "2" ) //"Situa็ใo Especial nใo informada!"
	lRet := .F.
Endif

If Empty( aParamExp[ ECD_CALENDARIO	] )
	EcdAddMsg( STR0014 , "2" ) //"Calendแrio nใo informado!"
	lRet := .F.
Endif

If Empty( aParamExp[ ECD_DATA_INI ] )
	EcdAddMsg( STR0015 , "2" ) //"Data Inicial da Escritura็ใo informada!"
	lRet := .F.
Endif

If Empty( aParamExp[ ECD_DATA_FIM ] )
	EcdAddMsg( STR0016 , "2" ) //"Data Final da Escritura็ใo informada!"
	lRet := .F.
Endif

If Empty( aParamExp[ ECD_MOEDA ] )
	EcdAddMsg( STR0017 , "2" ) //"Moeda nใo informada!"
	lRet := .F.
Endif

If Empty( aParamExp[ ECD_TIPO_SALDO	] )
	EcdAddMsg( STR0018 , "2" ) //"Tipo de Saldo nใo informada!"
	lRet := .F.
Else
	lRetSld := VldTpSald(aParamExp[ ECD_TIPO_SALDO	], .F., NIL, .F.)
	If !lRetSld
		EcdAddMsg( STR0041+Space(1)+aParamExp[ ECD_TIPO_SALDO	], "2" )  //"Tipo de Saldo Invalido"
		lRet := .F.
	Else
		If cModEsc == "ECD"
			aAdd(aTpSald, aParamExp[ ECD_TIPO_SALDO	] )
		Endif
	EndIf
Endif

If Empty( aParamExp[ ECD_IND_ESC ] )
	EcdAddMsg( STR0011 , "2" ) //"Indica็ใo de Esc. nใo informada!"
	lRet := .F.
Endif

If cModEsc == "ECD"
	
	If Empty( aParamExp[ ECD_OUT_INSC ] )
		EcdAddMsg( STR0010 , "2" ) //"Outras Incri็๕es nใo informada!"
		lRet := .F.
	Endif
	
	If Empty( aParamExp[ ECD_NATUREZA ] )
		EcdAddMsg( STR0012 , "2" ) //"Natureza nใo informada!"
		lRet := .F.
	Endif
	
	If Empty( aParamExp[ ECD_NUM_ORDEM	] )
		EcdAddMsg( STR0013 , "2" ) //"Numero do Livro informado!"
		lRet := .F.
	Endif
	
ElseIf cModEsc == "FCO"

	If Empty( aParamExp[ ECD_ESCR_ORI_RET	] )
		EcdAddMsg( STR0042 , "2" )   //"Falta informar se escrituracao ้ original ou retificadora!"
		lRet := .F.
	Endif

	If Empty( aParamExp[ ECD_QUALI_PJ		] )
		EcdAddMsg( STR0043 , "2" )   //"Falta informar qualifica็ใo pessoa juridica!"
		lRet := .F.
	Endif

	If aParamExp[ ECD_ESCR_ORI_RET	] == 2 .And. Empty( aParamExp[ ECD_REC_ANTERIOR	] )
		EcdAddMsg( STR0044 , "2" )   //"Falta informar numero de recibo anterior!"
		lRet := .F.
	Endif

	If Empty( aParamExp[ ECD_CTA_APURACAO ] )
		EcdAddMsg( STR0045 , "2" )   //"Falta informar c๓digo da conta de apura็ใo!"
		lRet := .F.
	Endif

	If Empty( aParamExp[ ECD_PER_APURACAO	] )
		EcdAddMsg( STR0046 , "2" )    //"Falta informar perํodo de apura็ใo!"
		lRet := .F.
	Endif

	If Empty( aParamExp[ ECD_SLD_REC_DESP ] )
		EcdAddMsg( STR0047 , "2" )    //"Falta informar se considera saldo anterior a receita/despesas!"
		lRet := .F.
	Endif

	If aParamExp[ ECD_SLD_REC_DESP ] == 1 .And. Empty( aParamExp[ ECD_GRU_REC_DESP ] )
		EcdAddMsg( STR0048 , "2" )   //"Falta informar grupo de receitas e despesas!"
		lRet := .F.
	Endif

	If aParamExp[ ECD_SLD_REC_DESP ] == 1 .And. Empty( aParamExp[ ECD_DAT_REC_DESP ] )
		EcdAddMsg( STR0049 , "2" )   //"Falta informar data de saldo anterior a receitas e despesas!"
		lRet := .F.
	Endif


	If ! Empty( aParamExp[ ECD_TIP_X_LANC	] )
 		If Ascan(aTpSald, aParamExp[ ECD_TIP_X_LANC ] ) > 0
			EcdAddMsg( STR0050+" [ X ]"+STR0051 , "2" )   //"Tipo de saldo referente a lancamentos do tipo"##"ja utilizado!"
			lRet := .F.
		Else
			lRetSld := VldTpSald(aParamExp[ ECD_TIP_X_LANC ], .F., NIL, .F.)
			If !lRetSld
				EcdAddMsg( STR0041+" [ X ]" , "2" )     //"Tipo de Saldo Invalido"
				lRet := .F.
			Else
				aAdd(aTpSald, aParamExp[ ECD_TIP_X_LANC ] )
			EndIf
		EndIf	
	Endif

	If ! Empty( aParamExp[ ECD_TIP_F_LANC	] )
 		If Ascan(aTpSald, aParamExp[ ECD_TIP_F_LANC	] ) > 0
			EcdAddMsg( STR0050+" [ F ]"+STR0051 , "2" )    //"Tipo de saldo referente a lancamentos do tipo"##"ja utilizado!"
			lRet := .F.
		Else
			lRetSld := VldTpSald(aParamExp[ ECD_TIP_F_LANC	], .F., NIL, .F.)
			If !lRetSld
				EcdAddMsg( STR0041+" [ F ]" , "2" )   //"Tipo de Saldo Invalido"
				lRet := .F.
			Else
				aAdd(aTpSald, aParamExp[ ECD_TIP_F_LANC	] )
			EndIf
		EndIf	
	Endif

	If ! Empty( aParamExp[ ECD_TIP_TR_LANC	] )
 		If Ascan(aTpSald, aParamExp[ ECD_TIP_TR_LANC	] ) > 0
			EcdAddMsg( STR0050+" [ TR ]"+STR0051 , "2" )    //"Tipo de saldo referente a lancamentos do tipo"##"ja utilizado!"
			lRet := .F.
		Else
			lRetSld := VldTpSald(aParamExp[ ECD_TIP_TR_LANC ], .F., NIL, .F.)
			If !lRetSld
				EcdAddMsg( STR0041+" [ TR ]" , "2" )   //"Tipo de Saldo Invalido"
				lRet := .F.
			Else
				aAdd(aTpSald, aParamExp[ ECD_TIP_TR_LANC	] )
			EndIf
		EndIf	
	Endif

	If ! Empty( aParamExp[ ECD_TIP_TF_LANC	] )
 		If Ascan(aTpSald, aParamExp[ ECD_TIP_TF_LANC ] ) > 0
			EcdAddMsg( STR0050+" [ TF ]"+STR0051 , "2" )    //"Tipo de saldo referente a lancamentos do tipo"##"ja utilizado!"
			lRet := .F.
		Else
			lRetSld := VldTpSald(aParamExp[ ECD_TIP_TF_LANC ], .F., NIL, .F.)
			If !lRetSld
				EcdAddMsg( STR0041+" [ TF ]" , "2" )   //"Tipo de Saldo Invalido"
				lRet := .F.
			Else
				aAdd(aTpSald, aParamExp[ ECD_TIP_TF_LANC ] )
			EndIf
		EndIf	
	Endif

	If ! Empty( aParamExp[ ECD_TIP_TS_LANC	] )
 		If Ascan(aTpSald, aParamExp[ ECD_TIP_TS_LANC ] ) > 0
			EcdAddMsg( STR0050+" [ TS ]"+STR0051 , "2" )    //"Tipo de saldo referente a lancamentos do tipo"##"ja utilizado!"
			lRet := .F.
		Else
			lRetSld := VldTpSald(aParamExp[ ECD_TIP_TS_LANC ], .F., NIL, .F.)
			If !lRetSld
				EcdAddMsg( STR0041+" [ TS ]" , "2" )   //"Tipo de Saldo Invalido"
				lRet := .F.
			Else
				aAdd(aTpSald, aParamExp[ ECD_TIP_TS_LANC ] )
			EndIf
		EndIf	
	Endif

	If ! Empty( aParamExp[ ECD_TIP_EF_LANC	] )
 		If Ascan(aTpSald, aParamExp[ ECD_TIP_EF_LANC ] ) > 0
			EcdAddMsg( STR0050+" [ EF ]"+STR0051 , "2" )    //"Tipo de saldo referente a lancamentos do tipo"##"ja utilizado!"
			lRet := .F.
		Else
			lRetSld := VldTpSald(aParamExp[ ECD_TIP_EF_LANC ], .F., NIL, .F.)
			If !lRetSld
				EcdAddMsg( STR0041+" [ EF ]" , "2" )   //"Tipo de Saldo Invalido"
				lRet := .F.
			Else
				aAdd(aTpSald, aParamExp[ ECD_TIP_EF_LANC ] )
			EndIf
		EndIf	
	Endif

	If ! Empty( aParamExp[ ECD_TIP_IF_LANC	] )
 		If Ascan(aTpSald, aParamExp[ ECD_TIP_IF_LANC ] ) > 0
			EcdAddMsg( STR0050+" [ IF ]"+STR0051 , "2" )    //"Tipo de saldo referente a lancamentos do tipo"##"ja utilizado!"
			lRet := .F.
		Else
			lRetSld := VldTpSald(aParamExp[ ECD_TIP_IF_LANC ], .F., NIL, .F.)
			If !lRetSld
				EcdAddMsg( STR0041+" [ IF ]" , "2" )   //"Tipo de Saldo Invalido"
				lRet := .F.
			Else
				aAdd(aTpSald, aParamExp[ ECD_TIP_IF_LANC ] )
			EndIf
		EndIf	
	Endif

	If ! Empty( aParamExp[ ECD_TIP_IS_LANC	] )
 		If Ascan(aTpSald, aParamExp[ ECD_TIP_IS_LANC ] ) > 0
			EcdAddMsg( STR0050+" [ IS ]"+STR0051 , "2" )    //"Tipo de saldo referente a lancamentos do tipo"##"ja utilizado!"
			lRet := .F.
		Else
			lRetSld := VldTpSald(aParamExp[ ECD_TIP_IS_LANC ], .F., NIL, .F.)
			If !lRetSld
				EcdAddMsg( STR0041+" [ IS ]" , "2" )   //"Tipo de Saldo Invalido"
				lRet := .F.
			Else
				aAdd(aTpSald, aParamExp[ ECD_TIP_IS_LANC ] )
			EndIf
		EndIf	
	Endif

EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGeraRevisao    บAutor  ณEquipe CTB     บ Data ณ  26/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Exporta็ใo dos dados para ECD                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GeraRevisao( oProcess, aParamExp, cMatriz, cModEsc, cEntRef, bIncTree, nRecCS0 )
Local aArea 	:= GetArea()
Local lRet		:= .T.
Local cFilEsc	:= "" 
Local nIx		:= 0
Local cMoedfun:=""

Default cMatriz 	:= ""
Default cModEsc 	:= "ECD"
Default cEntRef  	:= "  "
Default bIncTree	:= {||.T.}

If oProcess <> Nil
	oProcess:IncRegua1( STR0038 )
	oProcess:SetRegua2(1 + Len( aParamExp[ECD_AFILS] ) )
Endif

If oProcess <> Nil
	oProcess:IncRegua2( STR0038 )
Endif

If !Empty( cMatriz ) .And. aParamExp[ECD_TIPOESC] == 2
	cFilEsc := cMatriz
Else
	For nIx := 1 TO Len( aParamExp[ECD_AFILS] )
		IF ValType( aParamExp[ECD_AFILS][nIx][1] ) == 'L' .And. aParamExp[ECD_AFILS][nIx][1]
			cFilEsc := aParamExp[ECD_AFILS][nIx][3]
			
			
			EXIT
		Endif
	Next
EndIf

DbSelectArea( "SM0" )
DbSetOrder(1)
MsSeek( aParamExp[ECD_CODEMP] + cFilEsc )

__CodRev := GerNextRev( aParamExp[ECD_CODEMP])

IF ( __CodRev == '000000' )
	EcdAddMsg( STR0019 , "2" ) //"GeraRevisao-> Erro na gera็ใo do codigo de revisใo!"
	Return .F.
EndIf

RecLock( "CS0" , .T. )
CS0->CS0_FILIAL := xFilial("CS0")
CS0->CS0_CODREV := __CodRev 								// Cod. Revisao
CS0->CS0_CODEMP := aParamExp[ECD_CODEMP]   					// Cod. Empresa
CS0->CS0_CODFIL := cFilEsc 									// Cod. Filial
CS0->CS0_TPESC  := Iif(aParamExp[ECD_TIPOESC] == 1,'1','2')	// Tipo Escritur
CS0->CS0_DTINI  := aParamExp[ECD_DATA_INI]			  		// Dt Ini ECD
CS0->CS0_DTFIM  := aParamExp[ECD_DATA_FIM]			  		// Dt Fim ECD
CS0->CS0_CONSLD := Iif(aParamExp[ECD_TIPOESC] == 1,.T.,.F.)// Consolidado
CS0->CS0_USER   := Substring(cUsuario,1,20)  				// Usuario
CS0->CS0_UPDATE := dDataBase 				 				// Dt Atualizac
CS0->CS0_ECDREV := cModEsc 				 					// cModEsc pode ser ECD ou FCO
CS0->CS0_CODPLA := aParamExp[ECD_COD_PLA] 	 				// C๓digo Plano Referencial
CS0->CS0_VERPLA	:= aParamExp[ECD_VER_PLA] 	 				// Versใo Plano Referencial

If cModEsc == "ECD"
	CS0->CS0_NUMLIV := aParamExp[ECD_NUM_ORDEM]					// Num Livro
	CS0->CS0_TIPLIV := ECD_TPLIVRO[aParamExp[ECD_IND_ESC]][1]	// Tipo do Livro
	CS0->CS0_NATLIV := aParamExp[ECD_NATUREZA]					// Nat. do Livro
ElseIf cModEsc == "LAL"
		CS0->CS0_TIPLIV := "L"		// Lalur
ElseIf cModEsc == "FCO"
	CS0->CS0_TIPLIV := "F"		// Tipo do Livro FCONT
	CS0->CS0_SITPER := aParamExp[ECD_INDSITPER]   	//0-Inicio no primeiro dia do ano;1-Abertura;2-Result Cisao/Fusao;3-Obrig.Entrega FCONT	
EndIf

If cModEsc == "ECD" .And. lLeiaute2
	If lLeiaute7
		CS0->CS0_LEIAUT := "7.00"
	ElseIf lLeiaute6
		CS0->CS0_LEIAUT := "6.00"
	ElseIf lLeiaute5
		CS0->CS0_LEIAUT := "5.00"
	ElseIf lLeiaute4
		CS0->CS0_LEIAUT := "4.00"
	ElseIf lLeiaute3
		CS0->CS0_LEIAUT := "3.00"
	Else
		CS0->CS0_LEIAUT := "2.00"
	EndIf
	CS0->CS0_SITPER := aParamExp[ECD_INDSITPER]   	//0-Inicio no primeiro dia do ano;1-Abertura;2-Result Cisao/Fusao;3-Obrig.Entrega FCONT
	CS0->CS0_FINESC := Alltrim( Str(aParamExp[ ECD_FIN_ESC ]-1) )
	CS0->CS0_INNIRE := Alltrim( Str(aParamExp[ ECD_EXISTNIRE ]-1) )
	CS0->CS0_HASHSB := aParamExp[ ECD_HASH_ESC_SUBST ]                                                                      
	CS0->CS0_NIRESB := aParamExp[ ECD_NIRE_ESC_SUBST ] 
	CS0->CS0_DATALP := aParamExp[ ECD_DATA_LP ]     //DATA ENCERRRAMENTO EXERCICIO SOCIAL
EndIf

If cModEsc == "ECD" .And. lLeiaute3
	CS0->CS0_GDEPOR := Alltrim( Str( aParamExp[ ECD_GDE_PORTE]-1 ) )
	CS0->CS0_TIPECD := Alltrim( Str( aParamExp[ ECD_SCP_IND	 ]-1 ) )
	CS0->CS0_PLAREF := Alltrim( Str( aParamExp[ ECD_PLANOREF ], 2, 0 ) )
EndIf
If cModEsc == "ECD" .And. lMoedfun .and. lLeiaute4
	cMoedfun:="S|"	 
	If !(len(aParamExp) < ECD_MOE_FUN)
		For nIx := 1 TO Len(aParamExp[ECD_MOE_FUN])
			cMoedfun +=aParamExp[ECD_MOE_FUN][nIx]+"|"	
		Next
	Endif 
	CS0->CS0_MOEFUN :=cMoedfun
EndIf

//Sempre gravar N at้ libera็ใo do bloco K

If cModEsc == "ECD" .And. ( lLeiaute5 .Or. lLeiaute6 )
	If !IsInCallStack("CTBS040")   //Livro Z
		If aParamExp[ECD_OUT_CEC] == 2
			CS0->CS0_CONGEC := 'N'
		Else
			If ( CS0->( ColumnPos( "CS0_IDBLK" )) > 0 )
				CS0->CS0_CONGEC := 'S'
				CS0->CS0_IDBLK  := aParamExp[ ECD_IDBLK ] 	//IDENTIFICADOR DO BLOCO K
			EndIf
		EndIf
	Else
		CS0->CS0_CONGEC := 'N'
	EndIf 
EndIf

If cModEsc == "ECD" .And. lLeiaute7
	CS0->CS0_CALEND := aParamExp[ECD_CALENDARIO]	
EndIf

nRecCS0 := CS0->( Recno() )
MsUnLock()

cS011CNPJ := SM0->M0_CGC

Eval(bIncTree)

If cModEsc == "FCO"  //GRAVA DADOS FCONT
	RecLock( "CSM" , .T. )
	CSM->CSM_FILIAL := xFilial("CSM")
	CSM->CSM_CODREV := __CodRev 											//Cod. Revisao
	CSM->CSM_QUALPJ := cEntRef												//Entidade Referencial 00=SUSEP 10=RFB 20=COSIF
	CSM->CSM_TPESCR := If(aParamExp[ ECD_ESCR_ORI_RET ]==1, "0", "1")		//0-Original 1-Retificadora
	CSM->CSM_RECANT := aParamExp[ ECD_REC_ANTERIOR ] 						//Recibo anterior
	CSM->CSM_FMAPUR := If( aParamExp[ ECD_PER_APURACAO ] == 1, "A","T")		//Forma de Apuracao
	CSM->CSM_FMTRIB := Str( aParamExp[ ECD_FORMA_TRIBUT ], 1, 0)			//Forma de Tributacao
	CSM->CSM_TARBIT := aParamExp[ ECD_ALUCROARBIT ] 						//Trimestre Arbitrado
	CSM->CSM_APUTRI := aParamExp[ ECD_ARRAPURTRIM ] 						//Trimestre Apuracao
	CSM->CSM_APUCTA := aParamExp[ ECD_CTA_APURACAO ] 						//Conta de Apuracaco
	CSM->CSM_APUCC  := aParamExp[ ECD_APURCCUSTO ] 							//Centro Custo Apuracao
	CSM->CSM_CTAREF := aParamExp[ ECD_APCTAREF ] 							//Conta Referencial Apuracao
	CSM->CSM_TPUTIL := C011Ref(CSM->CSM_APUCTA,CSM->CSM_APUCC,cEntRef) 		//Tipo de Utilizacao
	MsUnLock()
EndIf

If Len( aParamExp[ECD_AFILS] ) > 0
	lRet := ExportaEmpresas( oProcess, aParamExp, cMatriz, cModEsc, ECDlCodSCP(cModEsc) )
Endif

RestArea( aArea )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณExportaEmpresasบAutor  ณEquipe CTB     บ Data ณ  26/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Exporta็ใo dos dados para ECD                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ExportaEmpresas( oProcess, aParamExp, cMatriz, cModEsc, lECDSCP )
Local aArea 	:= GetArea()
Local lRet		:= .T.
Local nIx		:= 0
Local aSocOsten
Local aAreaSM0	:= SM0->(GetArea())

Default cMatriz := ""
Default cModEsc := "ECD"
Default lECDSCP := .F.

//NO CASO DE ECD DA SCP TEM QUE PRIMEIRO GRAVAR DADOS DO SOCIO OSTENSIVO
If lECDSCP   //ecd da SCP
	
	aSocOsten := ECDSocOst()
	
	If aSocOsten[1] != NIL .And. Len(aSocOsten[1]) > 0
		DbSelectArea( "SM0" )
		DbSetOrder(1)
		If MsSeek( aSocOsten[1][2] + aSocOsten[1][3] )
		
			RecLock( "CS2" , .T. )
			
			CS2->CS2_FILIAL	:= xFilial("CS2")
			CS2->CS2_CODREV	:=  __CodRev		//Cod. Revisao
			CS2->CS2_CODEMP	:=  SM0->M0_CODIGO	//Cod. Empresa
			CS2->CS2_CODFIL	:=  SM0->M0_CODFIL	//Cod. Filial
			CS2->CS2_NOMEEM	:=  SM0->M0_NOMECOM	//Nome Empresa
			CS2->CS2_CNPJ	:=  SM0->M0_CGC		//CNPJ
			CS2->CS2_UF		:=  SM0->M0_ESTENT	//UF
			CS2->CS2_IE		:=  SM0->M0_INSC	//Insc. Estadu
			CS2->CS2_IM		:=  SM0->M0_INSCM	//Insc. Munici
			CS2->CS2_CODMUN	:=  SM0->M0_CODMUN	//Codigo Munic
			CS2->CS2_NOMFIL	:=  SM0->M0_FILIAL	//Nome Filial
			CS2->CS2_DESCMU :=  SM0->M0_CIDENT	//Municipio
			CS2->CS2_INSCR	:=  SM0->M0_INSCANT	//Inscri็ใo
			CS2->CS2_NIRE	:=  SM0->M0_NIRE	//NIRE
			CS2->CS2_DTNIRE	:= 	SM0->M0_DTRE	// Data do Nire
			CS2->CS2_SITESP	:=  ECD_SITESP[ aParamExp[ECD_SIT_ESP] ]	//Ind Sit Esp
			
			If cModEsc == "ECD"
				CS2->CS2_ENTREF :=  IIF(aParamExp[ECD_OUT_INSC] <= 5 , ECD_ENTREF[ aParamExp[ECD_OUT_INSC] ] , aParamExp[ECD_OUT_UF] ) 	//Entidades da inscri็ใo
				CS2->CS2_INSCR  :=  aParamExp[ECD_INSCRICAO]	//INSCRICAO
				
				If lLeiaute3
					CS2->CS2_CODSCP	:=  aParamExp[ ECD_COD_SCP ]	
				EndIf
				
			EndIf
			
			MsUnLock()
		Endif
	Endif
EndIf

For nIx := 1 TO Len( aParamExp[ECD_AFILS] )
	If oProcess <> Nil
		oProcess:IncRegua2( STR0020 + aParamExp[ECD_AFILS][nIx][3] ) //"Gravando Filial: "
	Endif
	
	DbSelectArea( "SM0" )
	DbSetOrder(1)
	
	If (aParamExp[ECD_AFILS][nIx][1]) .And. MsSeek( aParamExp[ECD_AFILS][nIx][2] + aParamExp[ECD_AFILS][nIx][3] ) 
		RecLock( "CS2" , .T. )
		
		CS2->CS2_FILIAL	:= xFilial("CS2")
		CS2->CS2_CODREV	:=  __CodRev		//Cod. Revisao
		CS2->CS2_CODEMP	:=  SM0->M0_CODIGO	//Cod. Empresa
		CS2->CS2_CODFIL	:=  SM0->M0_CODFIL	//Cod. Filial
		CS2->CS2_NOMEEM	:=  SM0->M0_NOMECOM	//Nome Empresa
		CS2->CS2_CNPJ	:=  SM0->M0_CGC		//CNPJ
		CS2->CS2_UF		:=  SM0->M0_ESTENT	//UF
		CS2->CS2_IE		:=  SM0->M0_INSC	//Insc. Estadu
		CS2->CS2_IM		:=  SM0->M0_INSCM	//Insc. Munici
		CS2->CS2_CODMUN	:=  SM0->M0_CODMUN	//Codigo Munic
		CS2->CS2_NOMFIL	:=  SM0->M0_FILIAL	//Nome Filial
		CS2->CS2_DESCMU:=  SM0->M0_CIDENT	//Municipio
		CS2->CS2_INSCR	:=  SM0->M0_INSCANT	//Inscri็ใo
		CS2->CS2_NIRE	:=  SM0->M0_NIRE	//NIRE
		CS2->CS2_DTNIRE	:= 	SM0->M0_DTRE	// Data do Nire
		CS2->CS2_SITESP	:=  ECD_SITESP[ aParamExp[ECD_SIT_ESP] ]	//Ind Sit Esp
		
		If cModEsc == "ECD"
			CS2->CS2_ENTREF :=  IIF(aParamExp[ECD_OUT_INSC] <= 5 , ECD_ENTREF[ aParamExp[ECD_OUT_INSC] ] , aParamExp[ECD_OUT_UF] ) 	//Entidades da inscri็ใo
			CS2->CS2_INSCR  :=  aParamExp[ECD_INSCRICAO]	//INSCRICAO
			If lLeiaute3
				CS2->CS2_CODSCP	:=  aParamExp[ ECD_COD_SCP ]	
			EndIf
		EndIf
		
		MsUnLock()
	Endif
Next
RestArea(aAreaSM0)
RestArea( aArea )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณExportaConta   บAutor  ณEquipe CTB     บ Data ณ  26/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Exporta็ใo dos dados para ECD                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ExportaConta(oProcess,cContaIni,cContaFim,dDataRef,dDataIni,cMoeda,cSaldo,cModEsc,aFils,lProcCusto,cIdBlocoK )

Local aArea		:= GetArea()
Local aStruct	:= {}
Local cAliasCT1	:= "CT1"
Local cFilCT1	:= xFilial( "CT1" )
Local cQuery 	:= ""
Local cWhere 	:= ""
Local nIx	 	:= 0
Local nNivelCta := 1
Local lRet		:= .T.
Local axFil 	:= {}
Local cTmpFil
Local cTmpFil1
Local cTmpFil2
Local cTmpFil3

Default cContaIni 	:= Space( TAMSX3("CT1_CONTA")[1] )
Default cContaFim 	:= Space( TAMSX3("CT1_CONTA")[1] )
Default dDataRef		:= Ctod("")
Default dDataIni		:= Ctod("")
Default cMoeda    	:= '01'
Default cSaldo 			:= '1'
Default cModEsc 		:= "ECD"
Default aFils				:= { { .T. , "" , cFilAnt } }
Default lProcCusto	:= .F.
Default cIdBlocoK		:= ""

Private aCtaSup   	:= {{},{}}

If oProcess <> Nil
	oProcess:IncRegua1( STR0021 ) //"Exportando Plano de Contas"
	oProcess:SetRegua2(0)
Endif

DbSelectArea( "CT1" )
DbSetOrder(1)

For nIx := 1 To Len( aFils )  
    If aFils[nIx][1]
		Aadd( axFil , aFils[nIx][3])
	EndIf
Next

cQuery := "SELECT CT1.CT1_FILIAL" ;
		+ ", CT1.CT1_CONTA      " ;
		+ ", CT1.CT1_DESC01     " ;
		+ ", CT1.CT1_CTASUP     " ;
		+ ", CT1.CT1_CLASSE     " ;
		+ ", CT1.CT1_NTSPED     " ;
		+ ", CT1.CT1_SPEDST     " ;
		+ ", CT1.CT1_NORMAL     " ;
		+ ", CT1.CT1_DTEXIS"
		
cQuery += " FROM " + RetSqlName( "CT1" ) + " CT1 "

cWhere := AddSqlExpr( cWhere , "CT1.CT1_FILIAL =" , cFilCT1 )

If ! Empty( Alltrim( cContaIni ) )
	cWhere := AddSqlExpr( cWhere , "CT1.CT1_CONTA >= " 	, cContaIni )
Endif

If ! Empty( Alltrim( cContaFim ) )
	cWhere := AddSqlExpr( cWhere , "CT1.CT1_CONTA <= " 	, cContaFim )
Endif

If ! Empty( dDataRef )
	cWhere := AddSqlExpr( cWhere , "CT1.CT1_DTEXIS <=" 	, dDataRef   )
Endif

cWhere := AddSqlExpr( cWhere , "CT1.D_E_L_E_T_ = ' '" )

If cModEsc == "ECD" .OR. cModEsc == "ECF"
	cWhere += "AND CT1.CT1_CLASSE = '2' "

	cWhere += "AND (  (CT1.CT1_CONTA IN " + EcdSubCQ1(dDataRef,dDataIni,cMoeda,cSaldo,axFil,.T.,@cTmpFil) + ")"
	cWhere += "    OR (CT1.CT1_CONTA IN " + EcdSubCQ1(dDataIni-1,,cMoeda,cSaldo,axFil,.F.,@cTmpFil1)+")"

	If lProcCusto
		cWhere += "    OR (CT1.CT1_CONTA IN " + EcdSubCQ3(dDataRef,dDataIni,cMoeda,cSaldo,axFil,.T.,@cTmpFil2)+")"
		cWhere += "    OR (CT1.CT1_CONTA IN " + EcdSubCQ3(dDataIni-1,,cMoeda,cSaldo,axFil,.F.,@cTmpFil3)+")"
	Endif

	cWhere += "    )"
Endif

cQuery := ChangeQuery( cQuery + cWhere + " ORDER BY " + SqlOrder(CT1->(IndexKey())))

// gera um novo alias
cAliasCT1 := GetNextAlias()

dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCT1 )

aStruct   := CT1->(dbStruct())

For nIx := 1 To Len(aStruct)
	If aStruct[nIx][2] <> "C"
		TcSetField(cAliasCT1,aStruct[nIx][1],aStruct[nIx][2],aStruct[nIx][3],aStruct[nIx][4])
	EndIf
Next nIx

While (cAliasCT1)->(!Eof())

	If oProcess <> Nil 
		oProcess:IncRegua2( STR0021+" "+ (cAliasCT1)->CT1_CONTA ) //"Plano de Conta: "
	EndIf

	If cModEsc == "ECD" .OR. cModEsc == "ECF" 
		nNivelCta := ECDNivCta( (cAliasCT1)->CT1_CONTA ,.T.,dDataRef)
	Else
		nNivelCta := CtbNivCta( (cAliasCT1)->CT1_CONTA )
	Endif
	
	If !Empty( dDataRef ) .And. (cAliasCT1)->CT1_DTEXIS > dDataRef
		(cAliasCT1)->( DbSkip() )
		Loop
	Endif
	
	CS11RecCS3(__CodRev,nNivelCta,cAliasCT1)

	(cAliasCT1)->( DbSkip() )

EndDo

(cAliasCT1)->( dbCloseArea() )

//Inser็ใo das contas referentes ao bloco k210. Estas contas, caso possuam a mesma raiz
//de CNPJ, devem tamb้m compor o bloco I050 (representado pelo cadastro da tabela CS3).
If (!Empty(cIdBlocoK))
	CS011k210(cIdBlocoK,dDataRef)
EndIf	

dbSelectArea("CT1")

RestArea( aArea )

CtbTmpErase(cTmpFil)
CtbTmpErase(cTmpFil1)
CtbTmpErase(cTmpFil2)
CtbTmpErase(cTmpFil3)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณExportaCusto   บAutor  ณEquipe CTB     บ Data ณ  26/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Exporta็ใo dos dados para ECD                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ExportaCusto( oProcess, dDataRef,lProcCusto )
Local aArea	:= GetArea()
Local aStruct	:= {}

Local cAliasCTT	:= "CTT"
Local cQuery	:= ""
Local cWhere	:= ""

Local lRet		:= .T.

Local nx		:= 0

If lProcCusto
	If oProcess <> Nil
		oProcess:IncRegua1( STR0022 ) //"Exportando Centro de Custo"
		oProcess:SetRegua2(0)
	Endif
	
	dbSelectArea( "CTT" )
	dbSetOrder(1)

	cQuery := "SELECT CTT.CTT_FILIAL, CTT.CTT_CUSTO, CTT.CTT_DESC01, CTT.CTT_DTEXIS"
	
	cQuery += " FROM " + RetSqlName( "CTT" ) + " CTT ";
	
	cWhere := AddSqlExpr( cWhere , "CTT.CTT_FILIAL =" , xFilial( "CTT" ) )
	
	If ! Empty( dDataRef )
		cWhere := AddSqlExpr( cWhere , "CTT.CTT_DTEXIS <=" 	, dDataRef   )
	Endif
	
	cWhere := AddSqlExpr( cWhere , "CTT.D_E_L_E_T_ = ' '" )
	
	cQuery := ChangeQuery( cQuery + cWhere + " ORDER BY " + SqlOrder(CTT->(IndexKey())))
	
	cAliasCTT := GetNextAlias()
	
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery),cAliasCTT)
	
	aStruct   := CTT->(dbStruct())
	
	For nX := 1 To Len(aStruct)
		If aStruct[nX][2] <> "C"
			TcSetField(cAliasCTT,aStruct[nX][1],aStruct[nX][2],aStruct[nX][3],aStruct[nX][4])
		EndIf
	Next nX
	
	While (cAliasCTT)->( !Eof() )
		
		If oProcess <> Nil
			oProcess:IncRegua2( STR0022+ (cAliasCTT)->CTT_CUSTO) 
		EndIf
		RecLock( "CS5", .T. )
		CS5->CS5_FILIAL := xFilial("CS5")
		CS5->CS5_CODREV	:= __CodRev
		CS5->CS5_CUSTO	:= (cAliasCTT)->CTT_CUSTO
		CS5->CS5_NOME	:= (cAliasCTT)->CTT_DESC01
		CS5->CS5_DTALT	:= IIF( ! Empty( (cAliasCTT)->CTT_DTEXIS ), (cAliasCTT)->CTT_DTEXIS, CTOD( "01/01/1980" ) )
		MsUnLock()
		
		(cAliasCTT)->( DbSkip() )
	EndDo
	
	(cAliasCTT)->( dbCloseArea() )
	dbSelectArea("CTT")

EndIf

RestArea( aArea )
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณExportaCtRef   บAutor  ณEquipe CTB     บ Data ณ  26/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Exporta็ใo dos dados para ECD                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ExportaCtRef( oProcess,cContaIni,cContaFim,dDataRef,lProcCusto, cCodPla, cModEsc,cVerPla,lAutomato,cIdBlocoK )
Local aArea	:= GetArea()
Local aStruct	:= {}

Local cAliasCVD	:= "CVD"
Local cFilCVD	:= xFilial( "CVD" )
Local cQuery	:= ""
Local cWhere	:= ""

// variaveis de controle da procedure
Local aProc     := {}
Local cProc     := ""
Local iX        := 0
Local iRet      := 0
Local axFil		:= {}
Local cExecDrop := ""
Local lUsaProc	:= GetNewPar( 'MV_CTBSPRC' , .T. )
Local cArqTrb	:= ""

Local lRet		:= .T.
Local nx		:= 0
Private aResult := {}

Default cCodPla := " "
Default cVerPla := " "
Default cModEsc := "ECD"
Default lAutomato := .F.
Default cIdBlocoK := ""

If oProcess <> Nil
	oProcess:IncRegua1( STR0023 ) //"Exportando Plano Referencial"
	oProcess:SetRegua2(0)
Endif

If lUsaProc
	If Alltrim( Upper(TcGetDb())) $ 'MSSQL7|MSSQL|ORACLE|DB2' .and. Alltrim(TcSrvType()) != "AS/400"
		cArqTrb := CriaTrab(,.F.)
		
		cArq  := cArqTrb + '01'
		AADD( aProc, cArq+"_"+cEmpAnt)

		cArq  := cArqTrb + '02'
		AADD( aProc, cArq+"_"+cEmpAnt)

		// procedure da xfilial
		lUsaProc := Ct11Filial(aProc[2])
		lUsaProc := lUsaProc .And. ProcCtaRef(aProc,/*aFils*/,cModEsc)

		// chamada da procedure do contaref
		If lUsaProc
		
			If !lAutomato
				MsgRun( STR0029 , STR0030 , {|| ;
						aResult := TCSPEXEC( xProcedures(SubString(aProc[1], 1, Len(aProc[1])- 3)), cFilAnt ;
															   , If(Len(__CodRev)== 0, ' ',__CodRev) ;
															   , If(lProcCusto, '1','0');
															   , cCodPla ;
															   , If(Empty(cCodPla), '1', '0');
															   , cVerPla);
											} )
			Else
				aResult := TCSPEXEC( xProcedures(SubString(aProc[1], 1, Len(aProc[1])- 3)), cFilAnt ;
													   , If(Len(__CodRev)== 0, ' ',__CodRev) ;
													   , If(lProcCusto, '1','0');
													   , cCodPla ;
													   , If(Empty(cCodPla), '1', '0');
													   , cVerPla)
			EndIf

			If Empty(aResult) .or. aResult[1] = "0"
				lUsaProc := .F.
				If !lAutomato
					MsgAlert( STR0056)//"Erro na inclusใo de dados da CS4! Processo manual serแ ativado"
				EndIf
			Endif
		EndIf

		If Len( aProc ) > 0
			For iX := 1 to Len(aProc)
				cExecDrop := "Drop procedure "+ aProc[iX]
				iRet := TcSqlExec(cExecDrop)
				If iRet != 0
					If !lAutomato
						MsgAlert(STR0057+aProc[iX]+STR0058)//"Erro na exclusao da Procedure: "##". Excluir manualmente no banco"
					EndIf
				Endif
			Next iX
		EndIf
	Else
		lUsaProc := .F.
	EndIf
EndIf

IF !lUsaProc

	iRet := -1

	DbSelectArea( "CVD" )
	DbSetOrder(1)	

	cQuery := "SELECT CVD.* FROM " + RetSqlName( "CVD" ) + " CVD "
	cWhere := AddSqlExpr( cWhere , "CVD.CVD_FILIAL =" , cFilCVD )
		
	//Enviar somente as contas analํticas
	If cModEsc != "FCO"
		cWhere := AddSqlExpr( cWhere , "CVD.CVD_CLASSE =" , '2' )
	EndIf
	
	If !Empty( cCodPla )
		cWhere := AddSqlExpr( cWhere , "CVD.CVD_CODPLA =" , cCodPla )
		cWhere := AddSqlExpr( cWhere , "CVD.CVD_VERSAO =" , cVerPla )
	EndIf
		
	cWhere := AddSqlExpr( cWhere , "CVD.D_E_L_E_T_ = ' '" )

	cQuery := ChangeQuery( cQuery + cWhere + " ORDER BY " + SqlOrder(CVD->(IndexKey())))
	
	cAliasCVD := GetNextAlias()
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCVD )
	
	aStruct	:= CVD->(dbStruct())
	
	For nX := 1 To Len(aStruct)
		If aStruct[nX][2] <> "C"
			TcSetField(cAliasCVD,aStruct[nX][1],aStruct[nX][2],aStruct[nX][3],aStruct[nX][4])
		EndIf
	Next nX
	
	While (cAliasCVD)->CVD_FILIAL == cFilCVD .And. (cAliasCVD)->( !Eof() )
		
		If oProcess <> Nil 
	 		oProcess:IncRegua2( STR0023 + " " + Alltrim( (cAliasCVD)->CVD_CONTA ) + "|" + Alltrim( (cAliasCVD)->CVD_CTAREF ) ) 
		EndIf
	
		CS11RecCS4(lProcCusto,cAliasCVD)
		
		If ( iRet < 0 )
			iRet := 0
		EndIf	

		(cAliasCVD)->( dbSkip() )
	EndDo

	(cAliasCVD)->( dbCloseArea() )

	dbSelectArea( "CVD" )

Endif

//Inser็ใo das contas referentes ao bloco k210. Estas contas, caso possuam a mesma raiz
//de CNPJ, devem tamb้m compor o bloco I050 (representado pelo cadastro da tabela CS4).
If ( !Empty(cIdBlocoK) .And. iRet == 0 )
	CS011k210(cIdBlocoK,dDataRef,{.t.,lProcCusto,cCodPla,cVerPla})
EndIf	

RestArea( aArea )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณExportaPlanDem บAutor  ณEquipe CTB     บ Data ณ  26/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Exporta็ใo dos dados para ECD                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ExportaPlanDem( oProcess, cCodBalPat, cCodDre, lProcCusto, cCodDLPA, cCodDMPL, cCodDFC, cCodDVA )
Local aArea		:= GetArea()
Local aStruct	:= {}

Local cQuery	:= ""
Local cAliasCTS	:= "CTS"
Local cFilCTS	:= xFilial( "CTS" )
Local cFilCT1	:= xFilial( "CT1" )
Local cFilCTN	:= xFilial( "CTN" )
Local cFilCTT	:= xFilial( "CTT" )
Local cDoc 		:= ""

Local nx		:= 0
Local lRet		:= .T.

If oProcess <> Nil
	oProcess:IncRegua1( STR0024 ) //"Exportando Plano Demonstrativo"
Endif

If Empty( cCodBalPat ) .And. Empty( cCodDre ) .And. ( Empty(cCodDLPA) .OR. Empty(cCodDMPL) ) .And. Empty(cCodDFC) .And. Empty(cCodDVA)
	Return .T.
Endif

If !Empty( cCodBalPat )
	cDoc := "'" + cCodBalPat + "'"
Endif

If !Empty( cCodDre ) .And. ( cCodDre <> cCodBalPat )
	IF !Empty( cDoc )
		cDoc += " , "
	Endif
	
	cDoc += "'" + cCodDre + "'"
Endif

If !Empty( cCodDLPA ) .And. ! ( cCodDLPA $ cDoc )
	IF !Empty( cDoc )
		cDoc += " , "
	Endif
	
	cDoc += "'" + cCodDLPA + "'"
Endif

If Empty( cCodDLPA ) .And. ! Empty( cCodDMPL ) .And. ! ( cCodDMPL $ cDoc )
	IF !Empty( cDoc )
		cDoc += " , "
	Endif

	cDoc += "'" + cCodDMPL + "'"
Endif

If !Empty( cCodDFC ) .And. ! ( cCodDFC $ cDoc )
	IF !Empty( cDoc )
		cDoc += " , "
	Endif

	cDoc += "'" + cCodDFC + "'"
Endif
dbSelectArea( "CTS" )
dbSetOrder(1)

cQuery := "SELECT CTS.*" ;
		 + " FROM " + RetSqlName( "CTS" ) + " CTS ";
		+ " WHERE CTS.CTS_FILIAL = '" + cFilCTS + "'";
		  + " AND CTS_CODPLA IN ( " ;
								+ " SELECT CTN.CTN_PLAGER " ;
								  + " FROM " + RetSqlName( "CTN" ) + " CTN ";
								 + " WHERE CTN.CTN_FILIAL = '" + cFilCTN + "'";
								   + " AND CTN.CTN_CODIGO IN ( " + cDoc + ") " ;
								   + " AND CTN.D_E_L_E_T_ = ' '" ;
							+ " ) " ;
		  + " AND CTS.D_E_L_E_T_=' ' ";
		  + " ORDER BY " + SqlOrder(CTS->(IndexKey()))
		  
cQuery := ChangeQuery( cQuery )

cAliasCTS := GetNextAlias()
dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCTS )

aStruct   := CTS->(dbStruct())

For nX := 1 To Len(aStruct)
	If aStruct[nX][2] <> "C"
		TcSetField(cAliasCTS,aStruct[nX][1],aStruct[nX][2],aStruct[nX][3],aStruct[nX][4])
	EndIf
Next nX

While lRet .And. (cAliasCTS)->( !Eof() )
	
	If (cAliasCTS)->CTS_CLASSE == '2' .AND. (cAliasCTS)->CTS_IDENT == '1'
		
		dbSelectArea("CT1")
		dbSetOrder(1)
		MsSeek( cFilCT1 + (cAliasCTS)->CTS_CT1INI , .T. )
		
		While lRet .And. CT1->CT1_FILIAL == cFilCT1 .And. CT1->CT1_CONTA <= (cAliasCTS)->CTS_CT1FIM .And. CT1->( !Eof() )

			If oProcess <> Nil 
				oProcess:IncRegua2( STR0024 +" "+(cAliasCTS)->CTS_CODPLA+" "+(cAliasCTS)->CTS_DESCCG )
			EndIf

			If CT1->CT1_CLASSE == "2"

				IF lProcCusto .And. !(Empty( (cAliasCTS)->CTS_CTTINI ) .And. Empty((cAliasCTS)->CTS_CTTFIM)) // registra o centro de custo
				
					If Empty( (cAliasCTS)->CTS_CTTINI )
						lRet := GravaPlanDem( (cAliasCTS)->CTS_CODPLA + (cAliasCTS)->CTS_CONTAG , (cAliasCTS)->CTS_CTASUP , StrZero((cAliasCTS)->CTS_COLUNA,2) , CT1->CT1_CONTA , "" )
					Endif 
					
					dbSelectArea("CTT")
					dbSetOrder(1)
					MsSeek( cFilCTT + (cAliasCTS)->CTS_CTTINI,.T.)

					While lRet .And. CTT->CTT_FILIAL == cFilCTT .And. CTT->CTT_CUSTO <= (cAliasCTS)->CTS_CTTFIM .And. CTT->( !Eof() )

						lRet := GravaPlanDem( (cAliasCTS)->CTS_CODPLA + (cAliasCTS)->CTS_CONTAG , (cAliasCTS)->CTS_CTASUP , StrZero((cAliasCTS)->CTS_COLUNA,2) , CT1->CT1_CONTA , CTT->CTT_CUSTO )

						dbSelectArea("CTT")
						dbSkip()
					EndDo

				Else
					lRet := GravaPlanDem( c + c , (cAliasCTS)->CTS_CTASUP , StrZero((cAliasCTS)->CTS_COLUNA,2) , CT1->CT1_CONTA )
				EndIf
			EndIf
			
			dbSelectArea( "CT1" )
			dbSkip()
		EndDo
	Else
		lRet := GravaPlanDem( (cAliasCTS)->CTS_CODPLA + (cAliasCTS)->CTS_CONTAG , (cAliasCTS)->CTS_CTASUP , StrZero((cAliasCTS)->CTS_COLUNA,2) )
	EndIf
	
	dbSelectArea(cAliasCTS)
	dbSkip()
EndDo

(cAliasCTS)->( dbCloseArea() )
dbSelectArea("CTS")

RestArea( aArea )

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGravaPlanDem   บAutor  ณEquipe CTB     บ Data ณ  26/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava a Visใo gerencial / Aglutinadora                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Exporta็ใo dos dados para ECD                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function GravaPlanDem(cCtaAgl,cCtaSup,cCodNat,cConta,cCusto)

Local lRet := .T.

DEFAULT cCtaAgl := ""
DEFAULT cCtaSup := ""
DEFAULT cCodNat := ""
DEFAULT cConta  := ""
DEFAULT cCusto  := ""

RecLock( "CS6", .T. )
CS6->CS6_FILIAL := xFilial("CS6")
CS6->CS6_CODREV	:= __CodRev
CS6->CS6_CCUSTO	:= cCusto
CS6->CS6_CODAGL	:= cCtaAgl
CS6->CS6_AGLSUP	:= cCtaSup
CS6->CS6_CODNAT	:= cCodNat
CS6->CS6_CONTA	:= cConta
MsUnLock()

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณExportaHistPadrบAutor  ณEquipe CTB     บ Data ณ  26/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Exporta็ใo dos dados para ECD                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ExportaHistPadrao(oProcess)
Local aArea		:= GetArea()
Local aStruct	:= {}

Local cAliasCT8	:= "CT8"
Local cFilCT8	:= xFilial( "CT8" )
Local cQuery	:= ""
Local cWhere	:= ""
Local cQrOrd	:= ""

Local lRet		:= .T.
Local nx		:= 0

If oProcess <> Nil
	oProcess:IncRegua1( STR0025 ) //"Exportando Hist๓rico Padrao"
	oProcess:SetRegua2(0)
Endif

cQuery := "SELECT CT8.* FROM " + RetSqlName("CT8") + " CT8 "
cWhere := AddSqlExpr( cWhere , "CT8.CT8_FILIAL =" , cFilCT8 )
cWhere := AddSqlExpr( cWhere , "CT8.CT8_SEQUEN = '000001'" )
cWhere := AddSqlExpr( cWhere , "CT8.D_E_L_E_T_ = ' '" )
cQrOrd := " ORDER BY CT8.CT8_FILIAL, CT8.CT8_HIST, CT8.CT8_SEQUEN "

cQuery := ChangeQuery( cQuery + cWhere + cQrOrd )

cAliasCT8 := GetNextAlias()
dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCT8 )

aStruct := CT8->(dbStruct())

For nX := 1 To Len(aStruct)
	If aStruct[nX][2] <> "C"
		TcSetField(cAliasCT8,aStruct[nX][1],aStruct[nX][2],aStruct[nX][3],aStruct[nX][4])
	EndIf
Next nX

While (cAliasCT8)->( !Eof() )
	
	IF CT8->CT8_IDENT <> 'I' .OR. ( CT8->CT8_IDENT == 'I' .AND. CT8->CT8_SEQUEN == '000001' )
		If oProcess <> Nil 
 			oProcess:IncRegua2( STR0025+" "+ (cAliasCT8)->CT8_HIST )  "
		EndIf
		Reclock("CS7",.T.)
		CS7->CS7_FILIAL := xFilial("CS7")
		CS7->CS7_CODREV := __CodRev
		CS7->CS7_CODHIS := (cAliasCT8)->CT8_HIST
		CS7->CS7_DESCRI := (cAliasCT8)->CT8_DESC
		MsUnLock()
	EndIf
	
	(cAliasCT8)->( dbSkip() )
EndDo

(cAliasCT8)->( dbCloseArea() )
dbSelectArea( "CT8" )

RestArea( aArea )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณExportaContabilบAutor  ณEquipe CTB     บ Data ณ  26/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Exporta็ใo dos dados para ECD                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ExportaSignatario( oProcess, dDataRef, lLeiaute2, cModEsc, nFinEsc)
Local aArea		:= GetArea()
Local aStruct	:= {}

Local cAliasCVB	:= "CVB"
Local cFilCVB   := xFilial( "CVB" )
Local cQuery	:= ""
Local cWhere	:= ""

Local lRet		:= .T.
Local nx		:= 0
Local nTipEscr := 0

Default dDataRef	:= CTod( '' )
Default lLeiaute2	:= .T.
Default cModEsc := ""
Default nFinEsc := 1


If cModEsc != "ECF"
	If FwIsInCallStack('ECDImpLivro') 
		nTipEscr := nFinEsc - 1
	Elseif lLeiaute3
		nTipEscr := aRespSped1[5]-1
	EndIf
EndIf

If oProcess <> Nil
	oProcess:IncRegua1( STR0026 ) //"Exportando Signatแrio"
	oProcess:SetRegua2(0)
	oProcess:IncRegua2( '' )
Endif

cQuery := "SELECT CVB.* FROM " + RetSqlName( "CVB" ) + " CVB "
cWhere := AddSqlExpr( cWhere , "CVB.CVB_FILIAL =" , cFilCVB )
If  cModEsc == "ECF"
		cWhere := AddSqlExpr( cWhere , "CVB.CVB_ASSIN NOT IN ('001','910','920')" )
ElseIf nTipEscr < 1
		cWhere := AddSqlExpr( cWhere , "CVB.CVB_ASSIN NOT IN ('910','920')" )
EndIf
cWhere := AddSqlExpr( cWhere , "CVB.D_E_L_E_T_ = ' '" )

IF ! Empty( dDataRef )
	cWhere := AddSqlExpr( cWhere , "( CVB.CVB_DTFIM = '        ' OR CVB.CVB_DTFIM >= '" + DTOS( dDataRef ) + "' )" )
ENDIF

IF CVB->( FieldPos( "CVB_MSBLQL" ) ) > 0
	cWhere := AddSqlExpr( cWhere , "CVB.CVB_MSBLQL <> '1'" )
ENDIF

cQuery := ChangeQuery( cQuery + cWhere )

cAliasCVB := GetNextAlias()
dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQuery ) , cAliasCVB )

aStruct   := CVB->(dbStruct())
For nX := 1 To Len(aStruct)
	If aStruct[nX][2] <> "C"
		TcSetField(cAliasCVB,aStruct[nX][1],aStruct[nX][2],aStruct[nX][3],aStruct[nX][4])
	EndIf
Next nX

While (cAliasCVB)->(!Eof())
	
	If oProcess <> Nil 
 		oProcess:IncRegua2( STR0026 + " " + (cAliasCVB)->CVB_CODCTB ) //"Contabilista: "
	EndIf 
	RecLock( "CS8" , .T. )
	CS8->CS8_FILIAL	:= xFilial("CS8")
	CS8->CS8_CODREV	:= __CodRev
	CS8->CS8_CODSIG	:= (cAliasCVB)->CVB_CODCTB
	CS8->CS8_NOME	:= (cAliasCVB)->CVB_NOME
	CS8->CS8_QUALIF	:= (cAliasCVB)->CVB_QUALIF
	CS8->CS8_CODASS	:= (cAliasCVB)->CVB_ASSIN
	
	If Empty( (cAliasCVB)->CVB_CGC )
		CS8->CS8_CPF  	:= (cAliasCVB)->CVB_CPF
	Else
		CS8->CS8_CGC  	:= (cAliasCVB)->CVB_CGC
		CS8->CS8_CPF  	:= (cAliasCVB)->CVB_CPF
	EndIf
	CS8->CS8_CRC  	:= (cAliasCVB)->CVB_CRC
	If lLeiaute2
		CS8->CS8_UFCRC  	:= (cAliasCVB)->CVB_UFCRC
		CS8->CS8_SEQCRC  	:= (cAliasCVB)->CVB_SEQCRC
		CS8->CS8_DTCRC  	:= (cAliasCVB)->CVB_DTCRC
		CS8->CS8_EMAIL  	:= (cAliasCVB)->CVB_EMAIL
		CS8->CS8_FONE  		:= (cAliasCVB)->CVB_TEL
	EndIf
	
	If cModEsc != "ECF"
		If CS8->(FieldPos("CS8_RESP")) > 0
			CS8->CS8_RESP 	:= (cAliasCVB)->CVB_RESP
		EndIf
	EndIf

	MsUnLock()
	
	(cAliasCVB)->( dbSkip() )
EndDo

(cAliasCVB)->( dbCloseArea() )
dbSelectArea("CVB")

RestArea( aArea )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณExportaParticipบAutor  ณEquipe CTB     บ Data ณ  26/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Exporta็ใo dos dados para ECD                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ExportaParticip( oProcess, dDataRef )
Local aArea		:= GetArea()
Local aStruct	:= {}

Local cAliasCVC	:= "CVC"
Local cFilCVC	:= xFilial( "CVC" )
Local cQuery	:= ""
Local cWhere	:= ""

Local lRet		:= .T.
Local nx		:= 0

Default	dDataRef:= CTod( '' )

If oProcess <> Nil
	oProcess:IncRegua1( STR0027 ) //"Exportando Participante"
	oProcess:SetRegua2(0)
Endif

cQuery := "SELECT CVC.* FROM " + RetSqlName( "CVC" ) + " CVC "
cWhere := AddSqlExpr( cWhere , "CVC.CVC_FILIAL =" , cFilCVC )
cWhere := AddSqlExpr( cWhere , "CVC.D_E_L_E_T_ = ' '" )

IF ! Empty( dDataRef )
	cWhere := AddSqlExpr( cWhere , "(CVC.CVC_DTFIM >=" , dDataRef )
	cWhere += " OR CVC.CVC_DTFIM = '')"
ENDIF

IF CVC->( FieldPos( "CVC_MSBLQL" ) ) > 0
	cWhere := AddSqlExpr( cWhere , "CVC.CVC_MSBLQL <> '1'" )
ENDIF

cQuery := ChangeQuery( cQuery + cWhere )

cAliasCVC := GetNextAlias()
DbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCVC )

aStruct   := CVC->(dbStruct())
For nX := 1 To Len(aStruct)
	If aStruct[nX][2] <> "C"
		TcSetField(cAliasCVC,aStruct[nX][1],aStruct[nX][2],aStruct[nX][3],aStruct[nX][4])
	EndIf
Next nX

While (cAliasCVC)->( ! EOF() )
	
	If oProcess <> Nil 
 		oProcess:IncRegua2( STR0027+" "+ (cAliasCVC)->CVC_CODPAR ) 
	EndIf
	RecLock( "CS9" , .T.)
	CS9->CS9_FILIAL := xFilial("CS9")
	CS9->CS9_CODREV  := __CodRev
	CS9->CS9_CODPAR  := (cAliasCVC)->CVC_CODPAR
	CS9->CS9_NOME    := (cAliasCVC)->CVC_NOME
	CS9->CS9_CODPAI  := (cAliasCVC)->CVC_PAIS 
	CS9->CS9_CNPJ    := IIf((cAliasCVC)->CVC_TIPO=="J",(cAliasCVC)->CVC_CGC,"")
	CS9->CS9_CPF     := IIf((cAliasCVC)->CVC_TIPO=="F",(cAliasCVC)->CVC_CGC,"")
	CS9->CS9_NIT     := ""
	CS9->CS9_UF      := (cAliasCVC)->CVC_UF
	CS9->CS9_IE      := (cAliasCVC)->CVC_IE
	CS9->CS9_IEST    := (cAliasCVC)->CVC_IE_ST
	CS9->CS9_CODMUN  := (cAliasCVC)->CVC_CODMUN
	CS9->CS9_IM      := (cAliasCVC)->CVC_IM
	CS9->CS9_SUFRAM  := (cAliasCVC)->CVC_SUFRAM
	CS9->CS9_CODREL  := (cAliasCVC)->CVC_CODREL
	CS9->CS9_DTINI	  := (cAliasCVC)->CVC_DTINI
	CS9->CS9_DTFIM	  := (cAliasCVC)->CVC_DTFIM
	MsUnLock()
	
	(cAliasCVC)->( dbSkip() )
EndDo

(cAliasCVC)->( dbCloseArea() )
dbSelectArea( "CVC" )

RestArea( aArea )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณExportaMov     บAutor  ณEquipe CTB     บ Data ณ  26/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Exporta็ใo dos dados para ECD                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ExportaMov( oProcess, afils, cCalend, dDataini, dDatafim, cMoeda, cTpSald, cContaini, cContafim, lProcCusto, aTpSald, cEntRef, cModEsc, cCodPla,cVerPla,cTmpFil)

Local aArea		:= GetArea()
Local aStruct	:= {}
Local cAliasCT2 := Criatrab(,.F.)
Local cAliasCTC	:= "CTC"
Local cFilCT2	:= xFilial( "CT2" )
Local cFilCTC	:= xFilial( "CTC" )
Local cChave	:= ""
Local cDoc     	:= ""
Local cQuery	:= ""
Local cWhere	:= ""
Local cQryGrp	:= ""
Local cQryOrd	:= ""
Local nIx		:= 0
Local lRet		:= .T.
Local lCplLote 	:= .F.
Local bCondCt2	:= {|| .T. }
Local bCondCTC	:= {|| .T. }  // Altera็ใo p/ o caso: advert๊ncia CFC 1299/2010
Local aProc     := {}
Local cProc     := ""
Local iX        := 0
Local iRet      := 0
Local axFil		:= {}
Local cExecDrop := ""
Local lUsaProc	:= GetNewPar( 'MV_CTBSPRC' , .T. ) 
Local lProcDoc	:= GetNewPar( 'MV_CTBSDOC' , .F. ) 
Local nX
Local cAuxTpSald 	:= ""
Local cTipoLivro 	:= CS0->CS0_TIPLIV
Local aCs0			:=StrTokArr("N|","|")
Local cIndTip		:= ""	 
Local cDtExt	:= ""

Private aResult := {}

Default afils		:= {xFilial( "CTC" )}
Default cCalend		:= ""
Default dDataini	:= Ctod( "" )
Default dDatafim	:= stod( "19801231" )
Default cMoeda		:= "01"
Default cTpSald		:= "1"
Default cContaini	:= ""
Default cContafim	:= ""
Default lProcCusto	:= .F.
Default aTpSald 	:= {}
Default cEntRef 	:= "  "
Default cCodPla     := " "
Default cVerPla     := " "
Default cTmpFil		:= " "	

If cModEsc == "ECD" .And. lMoedfun .and. lLeiaute4
	aCs0:=	StrTokArr( CS0->CS0_MOEFUN,"|" )
Endif
If oProcess <> Nil
	oProcess:IncRegua1( STR0028 ) //"Exportando Movimenta็ใo"
Endif

For nIx := 1 To Len( aFils )  
    If aFils[nIx][1]
		Aadd( axFil , aFils[nIx][3])
	EndIf
Next

If lUsaProc
	If Alltrim( Upper(TcGetDb())) $ 'MSSQL7|MSSQL|ORACLE|DB2' .and. Alltrim(TcSrvType()) != "AS/400"
		lUsaProc := Ctbs11Proc(@aProc, aFils, aTpSald, cModEsc, cEntRef, cCodPla,cVerPla,cMoeda) // tratar codpla na procedure

		If lUsaProc
			cProc := SubString(aProc[7], 1, Len(aProc[7])- 3)
			If cModEsc == "ECD" .And. lMoedfun .and. lLeiaute4
				MsgRun( STR0029 , STR0030 , {|| aResult := TCSPEXEC( xProcedures(cProc),; 
				cEmpAnt, cFilAnt, dtos(dDataIni), Dtos(dDataFim), cMoeda,aCs0[2], cTpSald, If(Empty(cContaIni), ' ', cContaIni), cContaFim, If(Len(__CodRev)= 0, ' ',__CodRev), If(lProcCusto, '1','0'),cEntRef, cTipoLivro )} )
			Else    
				MsgRun( STR0029 , STR0030 , {|| aResult := TCSPEXEC( xProcedures(cProc),;
				cEmpAnt, cFilAnt, dtos(dDataIni), Dtos(dDataFim), cMoeda, cTpSald, If(Empty(cContaIni), ' ', cContaIni), cContaFim, If(Len(__CodRev)= 0, ' ',__CodRev), If(lProcCusto, '1','0'),cEntRef, cTipoLivro )} )		
			Endif 			

			TcRefresh(RetSqlName("CSA"))
        	TcRefresh(RetSqlName("CSB"))
        	
			If Empty(aResult) .or. aResult[1] = "0"
				lUsaProc := .F.
				MsgAlert( STR0031) //"Erro na inclusao de dados no CSA e/ou CSB via procedure. A inclusใo sera feita pelo processo padrao "
			Endif
		EndIf

		If Len( aProc ) > 0
			For iX := 1 to Len(aProc)
				cExecDrop := "Drop procedure "+ aProc[iX]
				iRet := TcSqlExec(cExecDrop)
				If iRet != 0
					MsgAlert(STR0057+aProc[iX]+STR0058)//"Erro na exclusao da Procedure: "##". Excluir manualmente no banco"
				Endif
			Next iX
		EndIf
	Else
		lUsaProc := .F.
	EndIf
EndIf

If !lUsaProc
	cQuery := "SELECT CTC.CTC_FILIAL, CTC.CTC_DATA, CTC.CTC_LOTE, CTC.CTC_SBLOTE, 
	If lProcDoc
		cQuery += "CTC.CTC_DOC,"
	Endif
	If lLeiaute7 .and. !lProcDoc
		cQuery += "ISNULL(CSQ_DTEXT,'') CSQ_DTEXT,"
	EndIf
	
	cQuery += "CTC.CTC_MOEDA, CTC.CTC_TPSALD, SUM( CTC.CTC_DEBITO ) CTC_DEBITO, SUM( CTC.CTC_CREDIT ) CTC_CREDIT"
	cQuery += " FROM " + RetSqlName( "CTC" ) + " CTC "
	
	If lLeiaute7 .and. !lProcDoc
		cQuery += "LEFT JOIN " + RetSqlName( "CSQ" ) + " CSQ "+CRLF
		cQuery += "ON CSQ.CSQ_FILIAL  " + GetRngFil( aXFil, "CTC", .T.,@cTmpFil)+CRLF	
		cQuery += "AND CSQ.CSQ_DATA = CTC.CTC_DATA "+CRLF
		cQuery += "AND CSQ.CSQ_LOTE = CTC.CTC_LOTE "+CRLF
		cQuery += "AND CSQ.CSQ_SBLOTE = CTC.CTC_SBLOTE"+CRLF
		cQuery += "AND CSQ.CSQ_DOC = CTC.CTC_DOC"+CRLF
	EndIf
	
	cWhere := "WHERE CTC.CTC_FILIAL " + GetRngFil( aXFil, "CTC", .T.,@cTmpFil)												 
	
	If !Empty( dDataIni )
		cWhere := AddSqlExpr( cWhere , "CTC.CTC_DATA >=" , dDataIni)
	Endif
	
	If !Empty( dDataFim )
		cWhere := AddSqlExpr( cWhere , "CTC.CTC_DATA <=" , dDataFim)
	Endif
	
	If !Empty( cMoeda )
		cWhere := AddSqlExpr( cWhere , "CTC.CTC_MOEDA =" , cMoeda )
	Endif
	
	If Len(aTpSald) > 0
		cWhere += " AND CTC.CTC_TPSALD IN ("
		For nX := 1 TO Len(aTpSald)
			cTpSald := aTpSald[nX]		
		
			If !Empty( cTpSald )
				cAuxTpSald += "'"+cTpSald+"',"
			Endif
			
		Next
		cWhere += Left(cAuxTpSald, Len(cAuxTpSald)-1)+") "
	Else
		cWhere := AddSqlExpr( cWhere , "CTC.CTC_TPSALD =" , cTpSald)
	EndIf
			
	cWhere := AddSqlExpr( cWhere , "CTC.D_E_L_E_T_ = ' '" )
	
	cQryGrp := " GROUP BY CTC.CTC_FILIAL, CTC.CTC_DATA, CTC.CTC_LOTE, CTC.CTC_SBLOTE," + Iif(lProcDoc, "CTC.CTC_DOC,","" ) + " CTC.CTC_MOEDA, CTC.CTC_TPSALD" +  Iif(lLeiaute7 .And. !lProcDoc, ", CSQ.CSQ_DTEXT","" )
	cQryOrd := " ORDER BY CTC.CTC_FILIAL, CTC.CTC_DATA, CTC.CTC_LOTE, CTC.CTC_SBLOTE," + Iif(lProcDoc, "CTC.CTC_DOC,","" ) + " CTC.CTC_MOEDA, CTC.CTC_TPSALD"
	
	cQuery := ChangeQuery( cQuery + cWhere + cQryGrp + cQryOrd )
	
	cAliasCTC := CriaTrab(,.F.)

	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCTC )
	
	aStruct   := CTC->(dbStruct())
	
	For nIx := 1 To Len(aStruct)
		If aStruct[nIx][2] <> "C"
			TcSetField(cAliasCTC,aStruct[nIx][1],aStruct[nIx][2],aStruct[nIx][3],aStruct[nIx][4])
		EndIf
	Next nIx
	
	While (cAliasCTC)->( !Eof() ) .And. Eval( bCondCTC )// // Altera็ใo p/ o caso: advert๊ncia CFC 1299/2010
		
		If (cAliasCTC)->CTC_DEBITO <> 0 .Or. (cAliasCTC)->CTC_CREDITO <> 0
			
			nValor	 := Iif( (cAliasCTC)->CTC_DEBITO <> 0 , (cAliasCTC)->CTC_DEBITO, (cAliasCTC)->CTC_CREDITO )
			cFilMov  := (cAliasCTC)->CTC_FILIAL
			dData	 := (cAliasCTC)->CTC_DATA
			cLote	 := (cAliasCTC)->CTC_LOTE
			cSbLote  := (cAliasCTC)->CTC_SBLOTE
			cDoc	 := Iif(lProcDoc,(cAliasCTC)->CTC_DOC,"")
			cIndTip := ECDIndTip( (cAliasCTC)->CTC_TPSALD )

			If lLeiaute7 .And. !lProcDoc
				cDtExt	:= (cAliasCTC)->CSQ_DTEXT
			EndIf

			IF cIndTip == "E"
					cChave	 := cFilMov + DTOS( dData ) + cLote + cSbLote + cDoc + "APURACAO" + iif(  cModEsc == 'FCO' , (cAliasCTC)->CTC_TPSALD , '' )
			Else
				If lProcDoc
					cChave	 := cFilMov + DTOS( dData ) + cLote + cSbLote + cDoc + iif(  cModEsc == 'FCO' , (cAliasCTC)->CTC_TPSALD , '' )
				ElseIf lLeiaute7
					cChave	 := cFilMov + DTOS( dData ) + cLote + AllTrim(cSbLote) + AllTrim(cDtExt) + iif(  cModEsc == 'FCO' , (cAliasCTC)->CTC_TPSALD , '' ) 
				Else
					cChave	 := cFilMov + DTOS( dData ) + cLote + cSbLote + iif(  cModEsc == 'FCO' , (cAliasCTC)->CTC_TPSALD , '' )
				Endif
			Endif

			IF ExistBlock( "ECDCHVCAB" )
				cChave := ExecBlock( "ECDCHVCAB", .F., .F.)
			Endif

			dbSelectArea("CSA")
			dbSetOrder(1)
		
			If !DbSeek( xFilial("CSA") + __CodRev + Dtos((cAliasCTC)->CTC_DATA) + cChave)
				RecLock( "CSA" , .T. )
				CSA->CSA_FILIAL := xFilial("CSA")
				CSA->CSA_CODREV := __CodRev
				CSA->CSA_NUMLOT := cChave
				CSA->CSA_DTLANC := (cAliasCTC)->CTC_DATA
				CSA->CSA_VLLCTO := nValor
				CSA->CSA_INDTIP := cIndTip
				MsUnLock()
			EndIf
		
			ProcMov( cFilMov, dData, cLote, cSbLote, cMoeda, (cAliasCTC)->CTC_TPSALD/*cTpSald*/, cContaIni, cContaFim,lProcCusto, oProcess, cEntRef, cModEsc, cTipoLivro, cAliasCT2, cCodPla, cVerPla, cDoc,  cDtExt )
		Endif
		
		DbSelectArea( cAliasCTC )
		DbSkip()
	EndDo
	
	DbSelectArea(cAliasCTC)
	DbCloseArea()

EndIf

RestArea( aArea )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณProcMov   บAutor  ณEquipe CTB          บ Data ณ  03/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ProcMov( cFilMov, dData, cLote, cSbLote, cMoeda, cTpSald, cContaIni, cContaFim,lProcCusto, oProcess, cEntRef, cModEsc, cTipoLivro, cAliasCT2, cCodPla , cVerPla, cDoc, cDtExt)
Local aArea		:= GetArea()
Local aStruct	:= {}
Local nIx		:= 0
Local lRet		:= .T.
Local cSeqLan
Local cDtLP
Local cQuery:=""
Local cWhere:="" 
Local cQryOrd:=""
Local cQryGrp:=""
Local cAliasCSB	:= "CSB"	
Local lMovZerado:= GetNewPar( "MV_SPDAPZR" , .F. ) 	// parametro de verifica็ใo de movimento de apura็ใo zerado, se .T. irแ filtrar as movimenta็๕es
													// a ativa็ใo deste parametro poderแ implicar em uma aumento no tempo de processamento. ษ recomendado
Local aCs0:=StrTokArr("N|","|")													
Local lProcDoc	:= GetNewPar("MV_CTBSDOC" , .F.)
Local lDtApur	:= .F.
Local lFoundCSQ := .F.

Default cFilMov		:= xFilial('CTC')
Default dData		:= cTod('')
Default cLote		:= ""
Default cSbLote		:= ""
Default cDoc	    := ""
Default lProcCusto	:= .F.
Default cEntRef		:= "  "
Default cTipoLivro 	:= "G"
Default cAliasCT2 	:= Criatrab(,.F.)
Default cCodPla		:= ' ' 
Default cVerPla		:= ' ' 
Default cDtExt		:= ' '


If cModEsc == "ECD" .And. lMoedfun .and. lLeiaute4
	aCs0:=StrTokArr( CS0->CS0_MOEFUN,"|" )
Endif 													


If oProcess <> Nil
	oProcess:IncRegua1( STR0028 ) //"Exportando Movimenta็ใo"
	oProcess:SetRegua2(0)
Endif

cQuery := "SELECT CT2.CT2_FILIAL, CT2.CT2_DATA	, CT2.CT2_LOTE	, CT2.CT2_SBLOTE, CT2.CT2_DOC	, CT2.CT2_LINHA" ;
			+ " , CT2.CT2_SEQLAN, CT2.CT2_DC	, CT2.CT2_DEBITO, CT2.CT2_CREDIT, CT2.CT2_HP 	, CT2.CT2_HIST"	 ;
			+ " , CT2.CT2_CCD	, CT2.CT2_CCC	, CT2.CT2_DTLP	, CT2.CT2_SEQHIS, CT2.CT2_MOEDLC, CT2.CT2_TPSALD";
			+ " , CT2.CT2_VALOR	, CT2.CT2_EMPORI, CT2.CT2_FILORI, CT2.CT2_CODPAR";
			+ " FROM " + RetSqlName( "CT2" ) + " CT2"
			
cWhere := ""
cWhere := AddSqlExpr( cWhere , "CT2.CT2_FILIAL ="	, cFilMov )
cWhere := AddSqlExpr( cWhere , "CT2.CT2_DATA ="		, dData   )
cWhere := AddSqlExpr( cWhere , "CT2.CT2_LOTE ="		, cLote   )
cWhere := AddSqlExpr( cWhere , "CT2.CT2_SBLOTE ="	, cSbLote )
If lProcDoc
	cWhere := AddSqlExpr( cWhere , "CT2.CT2_DOC ="		, cDoc    )
Endif
cWhere := AddSqlExpr( cWhere , "CT2.CT2_MOEDLC ="	, cMoeda  )
cWhere := AddSqlExpr( cWhere , "CT2.CT2_TPSALD ="	, cTpSald )

IF !Empty( cContaIni ) .Or. !Empty( cContaFim )
	cWhere := AddSqlExpr( cWhere ,	"( ( CT2_DEBITO BETWEEN '" + cContaIni + "' AND '" + cContaFim + "' " ;
										+ " OR CT2_CREDIT BETWEEN '" + cContaIni + "' AND '" + cContaFim + "' " ;
										+ ") OR CT2_DC = '4' )" )
Endif

cWhere := AddSqlExpr( cWhere , "CT2.D_E_L_E_T_ = ' '" )
cQryOrd := " ORDER BY " + SqlOrder( CT2->(IndexKey(10) ) )

cQuery := ChangeQuery( cQuery + cWhere + cQryOrd )

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCT2)

aStruct   := CT2->(dbStruct())
For nIx := 1 To Len(aStruct)
	If aStruct[nIx][2] <> "C"
		TcSetField(cAliasCT2,aStruct[nIx][1],aStruct[nIx][2],aStruct[nIx][3],aStruct[nIx][4])
	EndIf
Next nX

While (cAliasCT2)->( !Eof() )
	
	
	If lLeiaute7 .and. !lProcDoc .and. CTBFindCSQ(DtoS((cAliasCT2)->CT2_DATA),(cAliasCT2)->CT2_LOTE,(cAliasCT2)->CT2_SBLOTE,(cAliasCT2)->CT2_DOC,cDtExt)
		(cAliasCT2)->(dbSkip())
		Loop
	EndIf
		
	cFilMov	:= (cAliasCT2)->CT2_FILIAL
	dData	:= (cAliasCT2)->CT2_DATA
	cLote	:= (cAliasCT2)->CT2_LOTE
	cSbLote	:= (cAliasCT2)->CT2_SBLOTE
	cDoc 	:= (cAliasCT2)->CT2_DOC
	nValor	:= (cAliasCT2)->CT2_VALOR

	If ! Empty((cAliasCT2)->CT2_DTLP)
		lDtApur := .T.
		cChave	:= (cAliasCT2)->CT2_FILIAL + DTOS( (cAliasCT2)->CT2_DATA ) + (cAliasCT2)->CT2_LOTE + (cAliasCT2)->CT2_SBLOTE + iif( cModEsc = 'FCO' , (cAliasCT2)->CT2_TPSALD  , '' )
	Else
		lDtApur := .F.
		If lProcDoc	
			cChave	:= (cAliasCT2)->CT2_FILIAL + DTOS( (cAliasCT2)->CT2_DATA ) + (cAliasCT2)->CT2_LOTE + (cAliasCT2)->CT2_SBLOTE + (cAliasCT2)->CT2_DOC + iif( cModEsc = 'FCO' , (cAliasCT2)->CT2_TPSALD  , '' )
		ElseIf lLeiaute7
			cChave	:= (cAliasCT2)->CT2_FILIAL + DTOS( (cAliasCT2)->CT2_DATA ) + (cAliasCT2)->CT2_LOTE + AllTrim((cAliasCT2)->CT2_SBLOTE) + AllTrim(cDtExt) + iif( cModEsc = 'FCO' , (cAliasCT2)->CT2_TPSALD  , '' )
		Else
			cChave	:= (cAliasCT2)->CT2_FILIAL + DTOS( (cAliasCT2)->CT2_DATA ) + (cAliasCT2)->CT2_LOTE + (cAliasCT2)->CT2_SBLOTE + iif( cModEsc = 'FCO' , (cAliasCT2)->CT2_TPSALD  , '' )
		Endif
	EndIf

	cMoeda	:= (cAliasCT2)->CT2_MOEDLC
	cTpSald	:= (cAliasCT2)->CT2_TPSALD
	cCodHis	:= (cAliasCT2)->CT2_HP
	cLinha	:= (cAliasCT2)->CT2_LINHA
	cCodPart:= (cAliasCT2)->CT2_CODPAR
	cEmpOri	:= (cAliasCT2)->CT2_EMPORI
	cFilOri	:= (cAliasCT2)->CT2_FILORI
	cSeqLan	:= (cAliasCT2)->CT2_SEQLAN	
	cDtLP	:= (cAliasCT2)->CT2_DTLP
	lFoundCSQ := .F.	
	
	If oProcess <> Nil 
		oProcess:IncRegua2( STR0028+" "+ cChave )
	EndIf
	
	IF ExistBlock( "ECDCHVMOV" )
		cChave := ExecBlock( "ECDCHVMOV", .F., .F.)
	Endif
	
	IF lMovZerado
		IF ! EcdMovZera( cFilMov, dData, (cAliasCT2)->CT2_DEBITO, (cAliasCT2)->CT2_CREDIT, cMoeda, cTpSald, lProcCusto, (cAliasCT2)->CT2_CCD , (cAliasCT2)->CT2_CCC )
			dbSelectArea( cAliasCT2 )
			dbSkip()
			Loop
		Endif
	Endif
	
	If nValor <> 0
		dbselectArea(cAliasCT2)		
		cDescHist := Alltrim( (cAliasCT2)->CT2_HIST ) + GetMovHist(cFilMov, dData, cLote, cSbLote, cDoc, cMoeda, cTpSald, cSeqLan, GetNextAlias())		
		
		If ( cTipoLivro = 'A' .And. Empty( cDtLP ) ) .Or. ( cTipoLivro <> 'A' )
			If (cAliasCT2)->CT2_DC == '1' .Or. (cAliasCT2)->CT2_DC == '3'
				GravaMov( cChave + iif(lDtApur,"APURACAO",""), cFilMov, dData, cLote, cSbLote, cDoc, 'D', (cAliasCT2)->CT2_DEBITO, IIF(lProcCusto,(cAliasCT2)->CT2_CCD,""), cMoeda, cTpSald, nValor, cCodHis, cDescHist, cLinha, cCodPart, cEmpOri, cFilOri, lProcCusto, cEntRef, cSeqLan, cCodPla, cVerPla, @lFoundCSQ )
			Endif
			
			If (cAliasCT2)->CT2_DC == '2' .Or. (cAliasCT2)->CT2_DC == '3'
				GravaMov( cChave + iif(lDtApur,"APURACAO",""), cFilMov, dData, cLote, cSbLote, cDoc, 'C', (cAliasCT2)->CT2_CREDIT, IIF(lProcCusto,(cAliasCT2)->CT2_CCC,""), cMoeda, cTpSald, nValor, cCodHis, cDescHist, cLinha, cCodPart, cEmpOri, cFilOri, lProcCusto, cEntRef, cSeqLan, cCodPla, cVerPla, @lFoundCSQ )
			Endif
		EndIf
		
		If __lExistCSQ .And. lLeiaute7 .And. lFoundCSQ
			Reclock( "CSA" , .F. )
			CSA->CSA_INDTIP := "X"
			CSA->CSA_DTEXT := CSQ->CSQ_DTEXT  //CSQ jแ esta posicionado
			MsUnlock()
		EndIf
		
		
		If ! Empty( (cAliasCT2)->CT2_DTLP )
			SetMovLpCSA( dData, cChave, cMoeda, cTpSald, cFilMov, cTipoLivro )
		Endif
	Endif
	
	DbSelectArea(cAliasCT2)
	DbSkip()
EndDo

DbSelectArea(cAliasCT2)
DbCloseArea()

RestArea( aArea )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetMovHistบAutor  ณEquipe CTB          บ Data ณ  03/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GetMovHist(cFilMov, dData, cLote, cSbLote, cDoc, cMoeda, cTpSald, cSeqLan, cAliasHist)
Local aArea		 := GetArea()
Local cQuery 	 := ""
Local cWhere 	 := ""
Local cQryOrd	 := ""
Local cAliasHist := ""
Local cDescHist	 := ""

Default cAliasHist := GetNextAlias()

If cAliasHist==""
	cAliasHist := GetNextAlias()
Endif

cQuery := "SELECT CT2_HIST HISTORICO" ;
		+ "  FROM " + RetSqlName( "CT2" ) + " CT2"

cWhere := ""
cWhere := AddSqlExpr( cWhere , "CT2.CT2_FILIAL ="	, cFilMov )
cWhere := AddSqlExpr( cWhere , "CT2.CT2_DATA ="		, dData   )
cWhere := AddSqlExpr( cWhere , "CT2.CT2_LOTE ="		, cLote   )
cWhere := AddSqlExpr( cWhere , "CT2.CT2_SBLOTE ="	, cSbLote )
cWhere := AddSqlExpr( cWhere , "CT2.CT2_DOC ="		, cDoc	  )
cWhere := AddSqlExpr( cWhere , "CT2.CT2_MOEDLC ="	, cMoeda  )
cWhere := AddSqlExpr( cWhere , "CT2.CT2_TPSALD ="	, cTpSald )
cWhere := AddSqlExpr( cWhere , "CT2.CT2_SEQLAN ="	, cSeqLan  )
cWhere := AddSqlExpr( cWhere , "CT2.CT2_DC = '4'"	)
cWhere := AddSqlExpr( cWhere , "CT2.D_E_L_E_T_ = ' '" )

cQryOrd := " ORDER BY " + SqlOrder( CT2->(IndexKey(10) ) )

cQuery := ChangeQuery( cQuery + cWhere + cQryOrd )

IF Select( cAliasHist ) > 0
	DbSelectArea( cAliasHist )
	DbCloseArea()
	FErase(cAliasHist+GetDBExtension())
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), cAliasHist)

While (cAliasHist)->(!Eof())
	
	cDescHist += " "+Alltrim( (cAliasHist)->HISTORICO )
	
	DbSelectArea( cAliasHist )
	DbSkip()
EndDo

DbSelectArea( cAliasHist )
DbCloseArea()

RestArea( aArea )

Return cDescHist

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGravaMov       บAutor  ณEquipe CTB     บ Data ณ  26/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Exporta็ใo dos dados para ECD                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GravaMov( cChave, cFilMov, dData, cLote, cSbLote, cDoc, cIndDc, cCodCta, cCCusto, cMoeda, cTpSald, nValor, cCodHis, cDescHist, cLinha, cCodPart, cEmpOri, cFilOri, lProcCusto , cEntRef, cSeqLan, cCodPla ,cVerPla, lFoundCSQ)
Local aArea		:= GetArea()
Local bWhile    := {||.T.}
Local aCs0:=StrTokArr("N|","|")
Local nX:=0
Local nTaxa:=0
DEFAULT cEntRef := '  '
DEFAULT cSeqLan := '   '
DEFAULT cCodPla := ' '
DEFAULT cCCusto := " "
DEFAULT cVerPla := " "
DEFAULT cChave:= ""

If Empty(cCCusto)
	cCCusto := Space( TAMSX3("CTT_CUSTO")[1] )
EndIf
If  !type("lMoedfun")=="U" .And. lMoedfun .and. lLeiaute4
	aCs0:=StrTokArr( CS0->CS0_MOEFUN,"|" )
Endif

RecLock( "CSB" , .T. )
CSB->CSB_FILIAL := xFilial("CSB")
CSB->CSB_CODREV	:= __CodRev
CSB->CSB_NUMLOT	:= cChave
CSB->CSB_INDDC	:= cIndDc
CSB->CSB_CODCTA	:= cCodCta

If lProcCusto
	CSB->CSB_CCUSTO	:= cCCusto
EndIf

CSB->CSB_CODHIS	:= cCodHis
CSB->CSB_HISTOR	:= cDescHist
CSB->CSB_CODPAR	:= cCodPart
CSB->CSB_LINHA	:= cLinha
If aCs0[1]=="S" // Se for moeda funcional executa processo diferenciado 
	CSB->CSB_FUPART  := nValor
	CT1->(DbSetOrder(1))
	CT1->(DbSeek(xFilial("CT1") + cCodCta))
	If CT1->CT1_NTSPED $ "01|02"
		nTaxa:=val(aCs0[17])
	Elseif CT1->CT1_NTSPED $ "03"
		CTP->(DbSetOrder(1))
		CTP->(DbSeek(xFilial("CTP") + DTOS(dData) + aCs0[2]))
		nTaxa:=CTP->CTP_TAXA
	Elseif CT1->CT1_NTSPED $ "04"
		For nX := 1 TO 12
			nTaxa :=nTaxa+VAL(aCs0[nX+5])
		Next
		nTaxa:=nTaxa/12
	Endif
	CSB->CSB_TAXA    := nTaxa
	CSB->CSB_VLPART  := nValor*nTaxa
	CT2->(DbSetOrder(1))
	If  CT2->(DbSeek(xFilial("CT2") + DTOS(dData) + cLote +cSbLote+cDoc+cLinha+cTpSald+cEmpOri+cFilOri+aCs0[2]   ))
		CSB->CSB_ADPART:=CT2->CT2_VALOR
	Endif 		
Else//Processo padrใo
	CSB->CSB_VLPART	:= nValor
Endif
CSB->CSB_NUMARQ	:= cChave + cDoc + cLinha + cSeqLan + cIndDc + cMoeda + cTpSald + cEmpOri + cFilOri
CSB->CSB_DTLANC := dData

If lLeiaute7
	If __lExistCSQ
		CSQ->(dbSetOrder(1))
		lFoundCSQ  :=  CSQ->(dbSeek(cFilMov+DTOS(dData)+cLote+cSbLote+cDoc+cLInha+cEmpOri+cFilOri))
		If  lFoundCSQ  
			//gravar data informado no movimento (CT2)
			CSB->CSB_DTEXT := CSQ-> CSQ_DTEXT
		EndIf
	EndIf
EndIf

MsUnLock()

IF !Empty( cEntRef ) .And. !VerUnicRef( cEntRef, cCodPla, cVerPla ) // passar ccodpla
	DbSelectArea( 'CVD' )
	If Empty(cCodPla)
		CVD->( DbSetOrder(3) )  /* CVD_FILIAL+CVD_ENTREF+CVD_CONTA+CVD_CUSTO */
		MsSeek( xFilial("CVD") + cEntRef + cCodCta + cCCusto )
		bWhile := {||CVD->( !Eof() .And. CVD_FILIAL == xFilial("CVD") .And. CVD_ENTREF == cEntRef .And. CVD_CONTA == cCodCta .And. CVD_CUSTO == cCCusto )}
	Else
		CVD->( DbSetOrder(4) )  /* CVD_FILIAL+CVD_ENTREF+CVD_CODPLA+CVD_CONTA+CVD_CUSTO+CVD_VERSAO */
		MsSeek( xFilial("CVD") + cEntRef + cCodPla + cCodCta + cCCusto + cVerPla )
		bWhile := {||CVD->( !Eof() .And. CVD->( CVD_FILIAL+CVD_ENTREF+CVD_CODPLA+CVD_CONTA+CVD_CUSTO+CVD_VERSAO ) ==  xFilial("CVD") + cEntRef + cCodPla + cCodCta + cCCusto + cVerPla  )}
	Endif
	
	Do While Eval(bWhile)		
		RecLock( "CSL" , .T. )
		CSL->CSL_FILIAL := xFilial("CSL")
		CSL->CSL_CODREV	:= __CodRev
		CSL->CSL_DTLANC := dData
		CSL->CSL_LINHA  := cLinha
		CSL->CSL_NUMLOT	:= cChave
		CSL->CSL_INDDC	:= cIndDc
		CSL->CSL_CODCTA	:= cCodCta
		CSL->CSL_CTAREF	:= CVD->CVD_CTAREF
		
		If lProcCusto
			CSL->CSL_CCUSTO	:= cCCusto
		EndIf


		If aCs0[1]=="S"// Se for moeda funcional executa processo diferenciado
			CSl->CSL_FUPART  := nValor
			CSL->CSL_TAXA    := nTaxa
			CSL->CSL_VLPART  := nValor*nTaxa
			CT2->(DbSetOrder(1))
			If  CT2->(DbSeek(xFilial("CT2") + DTOS(dData) + cLote +cSbLote+cDoc+cLinha+cTpSald+cEmpOri+cFilOri+aCs0[2]   ))
				CSL->CSL_ADPART:=CT2->CT2_VALOR
			Endif 
		Else//Processo padrใo		
			CSL->CSL_VLPART	:= nValor
		Endif
	
		CSL->CSL_NUMARQ	:= CSB->CSB_NUMARQ

		MsUnLock()
		
		CVD->( DbSkip() )
	EndDo

Endif

RestArea( aArea )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSetMovLpCSAบAutor  ณEquipe CTB         บ Data ณ  03/04/10   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SetMovLpCSA( dData, cChave, cMoeda, cTpSald, cFilMov, cTipoLivro )
Local aArea := GetArea()
Default cTipoLivro := "G"

If IsInCallStack("CTBS301")   //EXPORTACAO LALUR
	__CodRev := CS0->CS0_CODREV
EndIf

IF procMovLp( dData, cMoeda, cTpSald, "Z", cFilMov )
	DbSelectArea( 'CSA' )
	DbSetOrder(1)
	
	IF DbSeek( xFilial("CSA") + __CodRev + dTos( dData ) + cChave )
		If !(Alltrim(CSA->CSA_NUMLOT) == Alltrim(cChave) + "APURACAO") 
			If cTipoLivro <> 'A'
				Reclock( "CSA" , .F. )
				CSA->CSA_INDTIP := "E"
				CSA->CSA_NUMLOT := Rtrim(cChave) + "APURACAO"
				MsUnlock()
			Else
				Reclock( "CSA" , .F. )
				CSA->CSA_INDTIP := "E"
				CSA->CSA_NUMLOT := Rtrim(cChave) + "APURACAO"
				MsUnlock()
				
				Reclock( "CSA" , .F. )
				CSA->(DbDelete())
				MsUnlock()		
			EndIf
		EndIf
	Endif
Endif

RestArea( aArea )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณProcMovLp บAutor  ณRenato F. Campos    บ Data ณ  30/01/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ProcMovLp( dData, cMoeda, cTpSald, cTipo, cFilMov )
Local lProc := .F.
Local nIx	:= 0

IF Len( __aDtLp ) == 0
	ECDGetDtLp( cFilMov )
EndIf

For nIx := 1 TO Len( __aDtLp )
	IF __aDtLp[ nIx ][1] == dtos( dData ) .And. __aDtLp[ nIx ][2] == cMoeda .And. __aDtLp[ nIx ][3] == cTpSald .And. __aDtLp[ nIx ][4] == cTipo
		lProc := .T.
		Exit
	Endif
Next

Return lProc

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPrMovZeradoบAutor ณRenato F. Campos    บ Data ณ  30/01/10   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se a conta contabil ้ de resultado e se possui salบฑฑ
ฑฑบ          ณ do zerado antes da apura็ใo                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ProcMov                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PrMovZerado( cFilMov, dData, cContaD, cContaC, cMoeda, cTpSald, lProcCusto, cCustoD, cCustoC )
Local lRet 	:= .T.
Local lProc		:= .F.
Local aArea 	:= GetArea()
Local nIx		:= 0

For nIx := 1 TO 2
	
	IF nIx == 1
		cConta	:= cContaD
		cCusto  := cCustoD
	Else
		cConta	:= cContaC
		cCusto  := cCustoC
	EndIf
	
	lProc := .F.
	
	IF Ascan( __aCtRes, {|x| x[1] = cConta } ) == 0
		lProc := .T.
	Endif
	
	DbSelectArea( "CT1" )
	DbSetOrder(1)
	IF lProc .And. DbSeek( xFilial("CT1") + cConta  )
		Aadd( __aCtRes , {cConta} )
		
		IF CT1->CT1_NTSPED == '04' // contas de resultado
			
			IF !lProcCusto
				aSldAnt := SaldoCT7(cConta,dData,cMoeda,cTpSald,"CTBXFUN", .T. , dData )
			Else
				aSldAnt	:= SaldoCT3(cConta,cCusto,dData,cMoeda,cTpSald,'CTBXFUN',.T. , dData )
			Endif
			
			IF ( ( aSldAnt[4] - aSldAnt[7] ) - ( aSldAnt[5] - aSldAnt[8] ) ) == 0 // verifica se o saldo antes da apura็ใo nใo estแ zerado
				lRet := .F.
				Aadd( __aCtRes , {cConta,cCusto} )
			Endif
		Endif
	Else
		If Ascan( __aCtZero, {|x| x[1] = cConta .and. x[2] = cCusto } ) == 0
			lRet := .F.
		Endif
	Endif
	
	IF !lRet
		Exit
	Endif
NEXT

RestArea( aArea )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณExportaBalancบAutor  ณEquipe CTB       บ Data ณ  03/04/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ExportaBalanc( oProcess, aFils, dDataIni, dDataFim, dDiaProc, cMoeda, cTpSald, cContaIni, cContaFim, dDataLp, lProcCusto, cCalend, cSitEsp, cModEsc, lImpAntLP, cEntRef, cTpApur, aForTrib, cRegist, cTpApurC, cCodPla,cVerPla, cTpApurI )
Local aArea  		:= GetArea()
Local lRetorno 		:= .T.
Local nx			:= 0
Local aStruct		:= {}
Local cQuery		:= ""
Local cAliasCTG		:= "CTG"
Local cFilCTG		:= xFilial( "CTG" )
Local dDtProcIni
Local dDtProcFim
Local dDtFimQry
Local nCount		:= 0
Local lIndSitEsp	:= .F.
Local lUltDtOk		:= .T.

Default dDataLp 	:= Stod( '' )
Default aForTrib	:= {}
Default cRegist		:= ''
Default cTpApur		:= ''
Default cTpApurC	:= ''
Default cTpApurI	:= ''
Default cCodPla		:= ' '
Default cVerPla		:= " "

If cModEsc == 'FCO' .And. cTpApur == 'A' // se for FCONT e possuir apura็ใo anual -- Processo somente o calendario cheio
	lRetorno := ECDGRVBal( dDataIni, dDataFim, cMoeda, cTpSald, cContaIni, cContaFim, lProcCusto, dDataLp,oProcess,aFils,cModEsc,lImpAntLP,cEntRef, , ,cCodPla, cVerPla)
ElseIf cModEsc == 'ECD' .OR. cModEsc == 'FCO'
	dbSelectArea("CTG")
	dbSetOrder(1)	
	MsSeek( cFilCTG + cCalend + DTOS( dDataIni ) , .T. )
	
	If cSitEsp <> 'Z'
		dDtFimQry := DTOS(LastDay(dDataFim))
	Else
		dDtFimQry := DTOS(dDataFim)
	Endif
	
	cQuery := "SELECT CTG.*";
			 + " FROM " + RetSqlName("CTG") + " CTG ";
			+ " WHERE CTG_FILIAL = '" + cFilCTG + "'";
			  + " AND CTG_CALEND = '" + cCalend + "'" ;
			  + " AND CTG_DTINI >= '" + DTOS(dDataIni) + "'";
			  + " AND CTG_DTFIM <= '" + dDtFimQry + "'";
			  + " AND CTG.D_E_L_E_T_=' ' "	
	
	cQuery := ChangeQuery(cQuery) 
	
	cAliasCTG := GetNextAlias()

	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCTG )

	aStruct   := CTG->(dbStruct())

	For nX := 1 To Len(aStruct)
		If aStruct[nX][2] <> "C"
			TcSetField(cAliasCTG,aStruct[nX][1],aStruct[nX][2],aStruct[nX][3],aStruct[nX][4])
		EndIf
	Next nX
	 
	If oProcess <> Nil
		oProcess:IncRegua1( STR0032 ) //"Exportando Balancete"
		oProcess:SetRegua2(0)
	Endif
	
	While lRetorno .And. cFilCTG == (cAliasCTG)->CTG_FILIAL .And. ;
		(cAliasCTG)->CTG_CALEND == cCalend .And. ;
		(cAliasCTG)->CTG_DTINI  >= dDataIni .And. ;
		(cAliasCTG)->CTG_DTFIM  <= dDataFim .And. ;
		(cAliasCTG)->( !Eof() )
	  
		dDtProcIni	:= (cAliasCTG)->CTG_DTINI
		dDtProcFim	:= (cAliasCTG)->CTG_DTFIM

		If aParamEcd[ ECD_INDSITPER ] <> '2' .And. cSitEsp == 'Z' .and. cModEsc == 'ECD'
			If lPerCalTri
				If (cAliasCTG)->CTG_DTINI > (cAliasCTG)->CTG_DTFIM .Or.;
					(cAliasCTG)->CTG_DTFIM <> LastDay(MonthSum((cAliasCTG)->CTG_DTINI,2)) .Or.;
					(cAliasCTG)->CTG_DTINI <> FirstDay(MonthSub((cAliasCTG)->CTG_DTFIM,2))

					Help("ECDBalanc",1,"HELP",STR0033,STR0034,1,0)  //"Balancete Parcial"###"Perํodo Invแlido"
					lRetorno := .F.	
				EndIf
			ElseIf (cAliasCTG)->CTG_DTINI > (cAliasCTG)->CTG_DTFIM .Or.;
					(cAliasCTG)->CTG_DTFIM <> LastDay((cAliasCTG)->CTG_DTINI) .Or.;
					(cAliasCTG)->CTG_DTINI <> FirstDay((cAliasCTG)->CTG_DTFIM)
					
					Help("ECDBalanc",1,"HELP",STR0033,STR0034,1,0)  //"Balancete Parcial"###"Perํodo Invแlido"
					lRetorno := .F.					
			EndIf
		Else
			lIndSitEsp := .T.
			If dDtProcFim >= dDataFim
				dDtProcFim := dDataFim
			Endif
		Endif
				
		If lRetorno
			If lPerCalTri							
				nMesDif 	:= (Month((cAliasCTG)->CTG_DTFIM)-Month((cAliasCTG)->CTG_DTINI))+1 // Para contemplar casos de situa็ใo especial
				dDataLp 	:= (cAliasCTG)->CTG_DTFIM
				dDtProcIni 	:= (cAliasCTG)->CTG_DTINI 
				dDtProcFim 	:= LastDay((cAliasCTG)->CTG_DTINI)

				If lIndSitEsp
					lUltDtOk := DtoS((cAliasCTG)->CTG_DTFIM) $  (cAliasCTG)->CTG_EXERC+"0331/"+; //Verifica se situa็ใo especial de Extin็ใo
																(cAliasCTG)->CTG_EXERC+"0630/"+;
																(cAliasCTG)->CTG_EXERC+"0930/"+;
																(cAliasCTG)->CTG_EXERC+"1231"
				EndIf
				
				For nX := 1 to nMesDif // processo o trimestre					
					
					If !lUltDtOk .And. nX==nMesDif
						dDtProcFim := (cAliasCTG)->CTG_DTFIM
					EndIf
					
					lRetorno := ECDGRVBal( dDtProcIni, dDtProcFim, cMoeda, cTpSald, cContaIni, cContaFim, lProcCusto, dDataLp,oProcess,aFils,cModEsc,lImpAntLP,cEntRef, , ,cCodPla,cVerPla)						
					
					dDtProcIni := FirstDay(MonthSum((cAliasCTG)->CTG_DTINI,nX))						
					dDtProcFim := LastDay(MonthSum((cAliasCTG)->CTG_DTINI,nX))						
				Next nX						
			Else
				lRetorno := ECDGRVBal( dDtProcIni, dDtProcFim, cMoeda, cTpSald, cContaIni, cContaFim, lProcCusto, dDataLp,oProcess,aFils,cModEsc,lImpAntLP,cEntRef, , ,cCodPla,cVerPla)						
			EndIf
		EndIf
		
		( cAliasCTG )->(dbSkip())
	EndDo
	
	(cAliasCTG)->( dbCloseArea() )
	dbSelectArea( "CTG" )

ElseIf cModEsc == 'ECF'
	dbSelectArea("CTG")
	dbSetOrder(1)	
	MsSeek( cFilCTG + cCalend + DTOS( dDataIni ) , .T. )
	
	If cSitEsp <> 0
		dDtFimQry := DTOS(LastDay(dDataFim))
	Else
		dDtFimQry := DTOS(dDataFim)
	Endif
	
	cQuery := "SELECT CTG.*";
			 + " FROM " + RetSqlName("CTG") + " CTG ";
			 + " WHERE CTG_FILIAL  = '" + cFilCTG        + "'";
			 + " AND CTG_CALEND    = '" + cCalend        + "'";
			 + " AND CTG.D_E_L_E_T_= ' ' "	
	
	cQuery := ChangeQuery(cQuery) 
	cAliasCTG := GetNextAlias()
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCTG )

	aStruct   := CTG->(dbStruct())

	For nX := 1 To Len(aStruct)
		If aStruct[nX][2] <> "C"
			TcSetField(cAliasCTG,aStruct[nX][1],aStruct[nX][2],aStruct[nX][3],aStruct[nX][4])
		EndIf
	Next nX
	
	While lRetorno .And. cFilCTG == (cAliasCTG)->CTG_FILIAL .And. ;
		(cAliasCTG)->CTG_CALEND == cCalend .And. ;
		(cAliasCTG)->( !Eof() )
	    
	    nCount++
	    
	    If oProcess <> Nil
			oProcess:IncRegua1( STR0032 + " - " + cRegist ) //"Exportando Balancete"
			oProcess:SetRegua2(0)
			oProcess:IncRegua2( '' )
		Endif
	    
	    //Tratamento para verificar se o periodo de apura็ใo ้ igual ao calendแrio contabil
	    If cTpApur = "T" .AND. nCount > 4
	    	Alert ("Perํodo de Apura็ใo incompatํvel com Calendแrio Contแbil")
	    	lRetorno := .F.
	    	Exit
	    EndIf
	    
		If ( cTpApur = "A") .OR. ( cTpApur = "T")
			dDtProcIni	:= (cAliasCTG)->CTG_DTINI
			dDtProcFim	:= (cAliasCTG)->CTG_DTFIM
		
			If cSitEsp == 0
				If (cAliasCTG)->CTG_DTINI > (cAliasCTG)->CTG_DTFIM .Or.;
					(cAliasCTG)->CTG_DTFIM  <> LastDay((cAliasCTG)->CTG_DTINI) .Or.;
					(cAliasCTG)->CTG_DTINI <> FirstDay((cAliasCTG)->CTG_DTFIM)
					
					Help("ECDBalanc",1,"HELP",STR0033,STR0034,1,0)  //"Balancete Parcial"###"Perํodo Invแlido"
					lRetorno := .F.	
				EndIf
			Else
				If dDtProcFim >= dDataFim
					dDtProcFim := dDataFim
				Endif
			Endif

			//--------------------------------------------------------------------------------------
			// -- Regra Perํodo de Apura็ใo
			//--------------------------------------------------------------------------------------
			// Quando a apura็ใo ้ trimestral a data de LP serแ a data fim de cada trimestre.
			//
			// O imposto serแ determinado por perํodos de apura็ใo trimestrais, encerrados nos dias
			//    31 de mar็o, 30 de junho, 30 de setembro e 31 de dezembro de cada ano-calendแrio.
			// 
			// Nos casos de incorpora็ใo, fusใo ou cisใo, a apura็ใo da base de cแlculo e do imposto 
			//    devido serแ efetuada na data do evento.
			// 
			// Na extin็ใo da pessoa jurํdica, pelo encerramento da liquida็ใo, a apura็ใo da base de 
			//    cแlculo e do imposto devido serแ efetuada na data desse evento.
			// 
			// Link: http://www.portaltributario.com.br/guia/lucro_real.html
			//       http://www.portaltributario.com.br/guia/lucro_presumido.html
			//       http://www.portaltributario.com.br/guia/lucro_arbitrado.html
			//--------------------------------------------------------------------------------------
			// --- Regra: K030/K155/K156/K355/K356 ---
			//--------------------------------------------------------------------------------------
			//- Se (0010. FORMA_TRIB = “1”,“2”, “3” ou “4”)
			//- Se (0010. FORMA_TRIB = “5” ou “7” ou “8
			//- Se A(Anual), Existir um reg. p/ cada m๊s no 0010.MES_BAL_RED [1..12] como “B”
			//- Se T(Ttrimestral), Existir um reg. p/ cada trimestre no 0010.FORMA_TRIB_PER[1..4] como “R”
			//--------------------------------------------------------------------------------------
			If lRetorno
				If (cRegist == 'K155') .OR. (cRegist == 'K355')
					If ( (cTpApur = "A") .AND. (Substr(aForTrib[2],nCount,1) == 'B') ) .OR. (cTpApurC = "A") .OR.  (cTpApurI = "A")
						lRetorno := ECDGRVBal( dDataIni, dDtProcFim, cMoeda, cTpSald, cContaIni, cContaFim, lProcCusto, dDataLp,oProcess,aFils,cModEsc,lImpAntLP,cEntRef, aForTrib[4][nCount], cRegist,cCodPla,cVerPla)
					ElseIf ( (cTpApur = "T") .AND. (Substr(aForTrib[1],nCount,1) $ 'R|P') ) .OR. (cTpApurC = "T" .OR. cTpApurI = "T")
						lRetorno := ECDGRVBal( dDtProcIni, dDtProcFim, cMoeda, cTpSald, cContaIni, cContaFim, lProcCusto, dDtProcFim /*dDataLp*/,oProcess,aFils,cModEsc,lImpAntLP,cEntRef, aForTrib[3][nCount], cRegist,cCodPla, cVerPla)
					EndIf
				ElseIf (cRegist == 'L100') .OR. (cRegist == 'L300')
					If (cTpApur = "A") .AND. (Substr(aForTrib[2],nCount,1) $ 'B')
						lRetorno := ECDGRVBal( dDataIni, dDtProcFim, cMoeda, cTpSald, cContaIni, cContaFim, lProcCusto, dDataLp,oProcess,aFils,cModEsc,lImpAntLP,cEntRef, aForTrib[4][nCount], cRegist, cCodPla, cVerPla)
					ElseIf (cTpApur = "T") .AND. (Substr(aForTrib[1],nCount,1) == 'R')
						lRetorno := ECDGRVBal( dDtProcIni, dDtProcFim, cMoeda, cTpSald, cContaIni, cContaFim, lProcCusto, dDtProcFim /*dDataLp*/,oProcess,aFils,cModEsc,lImpAntLP,cEntRef, aForTrib[3][nCount], cRegist,cCodPla, cVerPla)
					EndIf
				ElseIf (cRegist == 'P100') .OR. (cRegist == 'P150')
					If (cTpApur = "T") .AND. (Substr(aForTrib[1],nCount,1) == 'P') 
						lRetorno := ECDGRVBal( dDtProcIni, dDtProcFim, cMoeda, cTpSald, cContaIni, cContaFim, lProcCusto, dDtProcFim /*dDataLp*/,oProcess,aFils,cModEsc,lImpAntLP,cEntRef, aForTrib[3][nCount], cRegist,cCodPla, cVerPla)
					EndIf 
				ElseIf (cRegist == 'U100') .OR. (cRegist == 'U150')
					If (cTpApurC = "A") .OR.  (cTpApurI = "A")
						lRetorno := ECDGRVBal( dDataIni, dDtProcFim, cMoeda, cTpSald, cContaIni, cContaFim, lProcCusto, dDataLp,oProcess,aFils,cModEsc,lImpAntLP,cEntRef, aForTrib[4][nCount], cRegist,cCodPla, cVerPla)
					ElseIf (cTpApurC = "T")
						lRetorno := ECDGRVBal( dDtProcIni, dDtProcFim, cMoeda, cTpSald, cContaIni, cContaFim, lProcCusto, dDtProcFim /*dDataLp*/,oProcess,aFils,cModEsc,lImpAntLP,cEntRef, aForTrib[3][nCount], cRegist,cCodPla, cVerPla)
					EndIf
				EndIf								
			EndIf			
		EndIf
		
		( cAliasCTG )->(dbSkip())
	EndDo
	
	(cAliasCTG)->( dbCloseArea() )
	dbSelectArea( "CTG" )
EndIf
	
RestArea( aArea )

Return lRetorno


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณECDGRVBal บAutor  ณEquipe CTB          บ Data ณ  08/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo que grava o balancete                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ECDGRVBal(dDataIni, dDataFim, cMoeda, cTpSald, cContaIni, cContaFim, lProcCusto, dDataLp,oProcess, aFils, cModEsc, lImpAntLP, cEntRef, cPeriodo, cRegist, cCodPla,cVerPla)

Local cAliasProc:= IIF( lProcCusto, "CT3" , "CT7" )
Local cArqTmp	:= ""
Local aArea    	:= GetArea() 
Local axFil		:= {}
Local nIx		:= 0 
Local lGerBalZer:= GetNewPar( 'MV_ECDBLZR' , .F. )
Local aCs0:=StrTokArr("N|","|")


Default aFils 	:= {}
Default cPeriodo:= ''
Default cModEsc := "ECD"
Default cRegist	:= ''
Default cCodPla	:= ' '
Default cVerPla := " "
If cModEsc == "ECD" .And. lMoedfun .and. lLeiaute4
	aCs0:=StrTokArr( CS0->CS0_MOEFUN,"|" )
Endif

If Select("cArqTmp") > 0
	cArqTmp->( dbCloseArea() )
EndIf

For nIx := 1 To Len( aFils )  
    If aFils[nIx][1]
		Aadd( axFil , aFils[nIx][3])
	EndIf
Next

If cModEsc == 'ECF'
	CtGerPlan(	,,,.F.,@cArqTmp,dDataIni,dDataFim, cAliasProc, "" , cContaIni , cContaFim,;
			"",Repl("Z",len(CTT->CTT_CUSTO)), "",Repl("Z", Len(CTD->CTD_ITEM)),"",Repl("Z", Len(CTH->CTH_CLVL)),;
			cMoeda,cTpSald,CTBSetOf(""),,,,,.F.,.T.,2,"CT1",lImpAntLP,dDataLp,1,lGerBalZer,,,,,,,,,,,,,,.T.,,,,,,,,,,,,,axFil,,,,.T.)
Else
	CtGerPlan(	,,,.F.,@cArqTmp,dDataIni,dDataFim, cAliasProc, "" , cContaIni , cContaFim,;
				"",Repl("Z",len(CTT->CTT_CUSTO)), "",Repl("Z", Len(CTD->CTD_ITEM)),"",Repl("Z", Len(CTH->CTH_CLVL)),;
				cMoeda,cTpSald,CTBSetOf(""),,,,,.F.,.T.,2,"CT1",.F.,dDataLp,1,lGerBalZer,,,,,,,,,,,,,,.F.,,,,,,,,,,,,,axFil,,,,.T.)
EndIf						
				
cArqTmp->( dbGoTop() )
If cModEsc == 'ECD' .AND. aCs0[1]=="S"
	//Caso seja utilizado moeda funcional ้ primeiro efetuado a grava็ใo dos dados em moeda funcional 
	//e Depois em moeda nacional.


	//Executa a grava็ใo de dados em moeda funcional	
	BalMoedFun(1,cArqTmp,aCs0,oProcess,dDataIni,dDataFim,lProcCusto)	
	//Roda novamente a gerplan para a moeda nacional	
	CtGerPlan(	,,,.F.,@cArqTmp,dDataIni,dDataFim, cAliasProc, "" , cContaIni , cContaFim,;
				"",Repl("Z",len(CTT->CTT_CUSTO)), "",Repl("Z", Len(CTD->CTD_ITEM)),"",Repl("Z", Len(CTH->CTH_CLVL)),;
				aCs0[2],cTpSald,CTBSetOf(""),,,,,.F.,.T.,2,"CT1",.F.,dDataLp,1,lGerBalZer,,,,,,,,,,,,,,.F.,,,,,,,,,,,,,axFil,,,,.T.)
	cArqTmp->( dbGoTop() )				
	//Executa a grava็ใo de dados em moeda Nacional				
	BalMoedFun(2,cArqTmp,aCs0,oProcess,dDataIni,dDataFim,lProcCusto)			
Else
	//Caso Nใo utilize moeda funcional ้ exectado o Processamento padrใo
	While cArqTmp->( !Eof() )
		If oProcess <> Nil 
			oProcess:IncRegua2( STR0032 + ": " + cArqTmp->CONTA)
		EndIf
	
		RecLock("CSC",.T.)
		CSC->CSC_FILIAL	 := xFilial("CSC")
		CSC->CSC_CODREV  := __CodRev
		CSC->CSC_DTINI   := dDataIni
		CSC->CSC_DTFIM   := dDataFim
		CSC->CSC_CONTA   := cArqTmp->CONTA
		CSC->CSC_CCUSTO  := Iif( lProcCusto, cArqTmp->CUSTO, "" )
		CSC->CSC_VALINI  := ABS( cArqTmp->SALDOANT )
		CSC->CSC_VALDEB  := ABS( cArqTmp->SALDODEB )
		CSC->CSC_VALCRE  := ABS( cArqTmp->SALDOCRD )
		CSC->CSC_VALMOV  := ABS( cArqTmp->( SALDODEB - SALDOCRD ) )
		CSC->CSC_VALFIN  := ABS( cArqTmp->SALDOATU )
		CSC->CSC_INDINI  := IIF( cArqTmp->SALDOANT > 0, "C","D" )
		CSC->CSC_INDFIM  := IIF( cArqTmp->SALDOATU > 0, "C","D" )
		
		If cModEsc == 'ECF'
			CSC->CSC_PERIOD	 := cPeriodo
			CSC->CSC_REGIST	 := cRegist
			CSC->CSC_CLASSE	 := cArqTmp->TIPOCONTA
		EndIf		
		
		MsUnLock()
		
		If cModEsc == "FCO" .OR. cModEsc == "ECF"
			SaldoPlanRef( oProcess, cEntRef, cModEsc, cPeriodo, cRegist, cCodPla,cVerPla)
		EndIf
	
		cArqTmp->(dbSkip())
	EndDo
	
	dbSelectArea("cArqTmp")
	dbCloseArea()
	
	If Select( "cArqTmp" ) == 0
		FErase(cArqTmp+GetDBExtension())
		FErase(cArqTmp+OrdBagExt())
	EndIF
Endif

RestArea(aArea)  

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณExportaDiario  บAutor  ณEquipe CTB     บ Data ณ  26/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Exporta็ใo dos dados para ECD                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ExportaDiario( oProcess, afils, ddataini, ddatafim, cmoeda, ctpsald, ccontaini, ccontafim, lproccusto, dDataLp, cCalend)
Local aArea    	:= GetArea()
Local lRet 	:= .T.
Local nx		:= 0

Local aStruct	:= {}
Local cQuery	:= ""

Local cAliasCTG	:= "CTG"
Local cFilCTG	:= xFilial( "CTG" )

dbSelectArea("CTG")
dbSetOrder(1)
MsSeek( cFilCTG + cCalend + DTOS( dDataIni ) , .T. )

If oProcess <> Nil
	oProcess:IncRegua1( STR0035 ) //"Exportando Balancete Diario"
	oProcess:SetRegua2(0)
Endif


cQuery := "SELECT CTG.*";
		+ " FROM " + RetSqlName("CTG") + " CTG ";
		+ " WHERE CTG_FILIAL = '" + cFilCTG + "'";
		+ "   AND CTG_CALEND = '" + cCalend + "'" ;
		+ "   AND CTG_DTINI >= '" + DTOS(dDataIni) + "'";
		+ "   AND CTG_DTFIM <= '" + DTOS(dDataFim) + "'";
		+ "   AND CTG.D_E_L_E_T_=' ' "

cQuery := ChangeQuery(cQuery) 	 
			
cAliasCTG := GetNextAlias()

dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCTG )

aStruct   := CTG->(dbStruct())

For nX := 1 To Len(aStruct)
	If aStruct[nX][2] <> "C"
		TcSetField(cAliasCTG,aStruct[nX][1],aStruct[nX][2],aStruct[nX][3],aStruct[nX][4])
	EndIf
Next nX

While lRet .And. (cAliasCTG)->( !Eof() )
	
	dDiaProc := (cAliasCTG)->CTG_DTINI
	
	WHILE dDiaProc <= (cAliasCTG)->CTG_DTFIM
		lRet := procCTBDia(dDiaProc, cMoeda, cTpSald, cContaIni, cContaFim, lProcCusto, dDataLp, afils)
		If oProcess <> Nil 
 			oProcess:IncRegua2( STR0035+" "+ dToc(dDiaProc) ) 
		EndIf
		dDiaProc++
	Enddo
	
	dbSelectArea(cAliasCTG)
	dbSkip()
EndDo

(cAliasCTG)->( dbCloseArea() )
dbSelectArea( "CTG" )

RestArea( aArea )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณExportaDemonst บAutor  ณEquipe CTB     บ Data ณ  26/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Exporta็ใo dos dados para ECD                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ExportaDemonst( oProcess, aFils, cCodVis, cMoeda, cTpSald, dDataIni, dDataFim, dDtDemIni, dDtDemFim, dDataLP, nCabDem, cCalend, lLeiaute2, cModEsc, cPeriodo, cRegist, lValZero, lImpAntLP, cIdBloco_V, cCodInstFi )
Local aArea    		:= GetArea()
Local lRet 			:= .T.
Local aSetOfBook 	:= CtbSetOf( cCodVis )
Local cArqTmp 		:= ""
Local dFinalA 		:= cTod( "" )
Local dFinal 		:= cTod( "" )
Local axFil			:= {}
Local nIx			:= 0
Local lZerdado		:= Iif(nCabDem == ECD_DLPA .or. nCabDem == ECD_DMPL, .T.,.F. ) 
Local lDemDRE 		:= NIL
Local dFimAnt 		:= NIL

Default lLeiaute2	:= .T.
Default cModEsc 	:= 'ECD'
Default cPeriodo 	:= ''
Default cRegist		:= ''
Default lValZero	:= .F.
Default lImpAntLP	:= .F.
Default cIdBloco_V := ""
Default cCodInstFi := ""

If cRegist == 'V100' .And. ( Empty(cIdBloco_V) .Or. Empty(cCodInstFi) ) //para registro V100 ้ obrigatorio passar identificador do bloco V
	Return .T.
Endif

If oProcess <> Nil
	oProcess:IncRegua1( STR0036 + ' - ' + cRegist ) //"Exportando Demonstrativos"
	oProcess:SetRegua2(0)
Endif

dDtDemIni := Iif( !Empty( dDtDemIni ) ,dDtDemIni, dDataIni)
dDtDemFim := Iif( !Empty( dDtDemFim ) ,dDtDemFim, dDataFim)

If Empty( aSetOfBook[5] )
	Return .T.
Endif

IF nCabDem == ECD_DRE .And. GetNewPar( "MV_ECDMOVP" , .F. )
	CTG->( DbSeek( xFilial() + cCalend ))
	
	While CTG->CTG_FILIAL = xFilial( "CTG" ) .And. CTG->CTG_CALEND = cCalend
		dFinal	:= CTG->CTG_DTFIM
		
		CTG->(DbSkip())
	EndDo
	
	dFinalA := Ctod(Left(Dtoc(dFinal), 6) + Str(Year(dFinal) - 1, 4))
	
	If Empty( dFinalA )
		If MONTH(dFinal) == 2
			If Day(dFinal) > 28 .and. Day(dFinal) == 29
				dFinalA := Ctod(Left( STRTRAN( Dtoc(dFinal) , "29" , "28" ), 6) + Str(Year(dFinal) - 1, 4))
			EndIf
		EndIf
	EndIf
	
	dDtDemIni := dFinalA+1
	dDtDemFim := dFinal
Endif

lComNivel := .T.

If Select("cArqTmp") > 0
	cArqTmp->(dbCloseArea())
EndIf

For nIx := 1 To Len( aFils )  
    If aFils[nIx][1]
		Aadd( axFil , aFils[nIx][3])
	EndIf
Next

If cModEsc == 'ECF'
	CTGerPlan(	,,,.F.,@cArqTmp,dDtDemIni, dDtDemFim,"","","",Repl("z", Len(CT1->CT1_CONTA)),;
				"",Repl("Z", Len(CTT->CTT_CUSTO)),	"",Repl("Z", Len(CTD->CTD_ITEM)),;
				"",Repl("Z", Len(CTH->CTH_CLVL)),cMoeda,cTpSald,CTBSetOf(cCodVis),;
				Space(2),Space(20),Repl("z",20),Space(30),,;
				,,, lImpAntLP,dDataLP,,lValZero,,,,,,,,,,,,,,,".F.",,,,,,,,,,,.T.,axFil)
Else
	lDemDRE := .T.
	dFimAnt := dDtDemIni-1
	If cModEsc == 'ECD' .And. nCabDem == ECD_DRE
		If CS0->CS0_LEIAUT >= '7.00'
			lDemDRE := NIL
			dFimAnt := NIL
		EndIf 
	EndIf
	CTGerPlan(	,,,.F.,@cArqTmp,dDtDemIni, dDtDemFim,"","","",Repl("z", Len(CT1->CT1_CONTA)),;
				"",Repl("Z", Len(CTT->CTT_CUSTO)),	"",Repl("Z", Len(CTD->CTD_ITEM)),;
				"",Repl("Z", Len(CTH->CTH_CLVL)),cMoeda,cTpSald,CTBSetOf(cCodVis),;
				Space(2),Space(20),Repl("z",20),Space(30),,;
				,,, nCabDem == ECD_DRE,dDataLP,,lZerdado,,,,,,,,,,,,,,,".F.",,,,,,,,,,,.T.,axFil,,,,,,,,,,,,,lDemDRE,dFimAnt)
EndIf
			
If lRet	
	ECDGrvDem(oProcess, cCodVis, dDtDemIni, dDtDemFim, nCabDem, lLeiaute2, cModEsc, cPeriodo, cRegist, cIdBloco_V, cCodInstFi, aSetOfBook)
EndIf

RestArea( aArea )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณExportaOutDem  บAutor  ณEquipe CTB     บ Data ณ  26/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Exporta็ใo dos dados para ECD                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ExportaOutDem( oProcess, dDataIni, dDataFim, dDtDemIni, dDtDemFim, cOutDem, cRap, cDfc, cDva, cNte, cRadm, cPrau, cOtr, cTvfs, cModEsc, cMotSubst )
Local aArea    	:= GetArea()
Local lRet	 	:= .T.
Local aArqRtf	:= {}
Local cFile    	:= ""
Local cExt     	:= ""
Local nX		:= 0
Local cLinha	:= Replicate("0",18)


Default cOutDem  := ''
Default cRap     := ''
Default cDfc     := ''
Default cDva     := ''
Default cNte     := ''
Default cRadm    := ''
Default cPrau    := ''
Default cOtr     := ''
Default cTvfs    := ''
Default cModEsc  := "ECF"
Default cMotSubst:= ""

If ((cModEsc == "ECD" .And. ! lLeiaute2) .OR. cModEsc == "ECF" ) .And. Empty(cOutDem)
	Return .T.
Endif

If oProcess <> Nil
	oProcess:IncRegua1( STR0037 ) //"Exportando Outros Demonstrativos"
	oProcess:SetRegua2(0)
Endif

dDtDemIni 	:= Iif( !Empty( dDtDemIni ) ,dDtDemIni, dDataIni)
dDtDemFim 	:= Iif( !Empty( dDtDemFim ) ,dDtDemFim, dDataFim)


//Tipos de documentos a serem gravados no campo CSF_TIPDOC

cOutDem 	:= Iif( Upper(TCSrvType())=="LINUX", AllTrim(StrTran(cOutDem ,"\","/")), AllTrim(cOutDem))
SplitPath( cOutDem,/*cDrive*/,/*cPath*/, @cFile,@cExt)

If cModEsc == "ECD" .And. (lLeiaute2)	
	cRap 		:= Iif( Upper(TCSrvType())=="LINUX", AllTrim(StrTran(cRap    ,"\","/")), AllTrim(cRap))		//001 Demonstra็ใo do Resultado Abrangente do Perํodo
	cDfc 		:= Iif( Upper(TCSrvType())=="LINUX", AllTrim(StrTran(cDfc    ,"\","/")), AllTrim(cDfc))		//002 Demonstra็ใo dos Fluxos de Caixa
	cDva 		:= Iif( Upper(TCSrvType())=="LINUX", AllTrim(StrTran(cDva    ,"\","/")), AllTrim(cDva))		//003 Demonstra็ใo do Valor Adicionado
	cNte 		:= Iif( Upper(TCSrvType())=="LINUX", AllTrim(StrTran(cNte    ,"\","/")), AllTrim(cNte))		//010 Notas Explicativas
	cRadm 		:= Iif( Upper(TCSrvType())=="LINUX", AllTrim(StrTran(cRadm   ,"\","/")), AllTrim(cRadm))	//011 Relat๓rio da Administra็ใo
	cPrau 		:= Iif( Upper(TCSrvType())=="LINUX", AllTrim(StrTran(cPrau   ,"\","/")), AllTrim(cPrau))	//012 Parecer dos Auditores
	cOtr		:= Iif( Upper(TCSrvType())=="LINUX", AllTrim(StrTran(cOtr    ,"\","/")), AllTrim(cOtr))		//099 Outros
	cTvfs		:= Iif( Upper(TCSrvType())=="LINUX", AllTrim(StrTran(cTvfs   ,"\","/")), AllTrim(cTvfs))	//000 J801 Termo de Verifica็ใo para Fins de Substitui็ใo  ECD
	
	SplitPath( cRap   ,/*cDrive*/,/*cPath*/, @cFile,@cExt)
	SplitPath( cDfc   ,/*cDrive*/,/*cPath*/, @cFile,@cExt)
	SplitPath( cDva   ,/*cDrive*/,/*cPath*/, @cFile,@cExt)
	SplitPath( cNte   ,/*cDrive*/,/*cPath*/, @cFile,@cExt)
	SplitPath( cRadm  ,/*cDrive*/,/*cPath*/, @cFile,@cExt)
	SplitPath( cPrau  ,/*cDrive*/,/*cPath*/, @cFile,@cExt)
	SplitPath( cOtr   ,/*cDrive*/,/*cPath*/, @cFile,@cExt)
	SplitPath( cTvfs  ,/*cDrive*/,/*cPath*/, @cFile,@cExt)

EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณQuebra o arquivo em linha de 65500 caracteres ณ
//ณe carrega no array                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If Val(CS0->CS0_LEIAUT) < 7 
	If cModEsc == "ECD" .And. (lLeiaute5)
		//Demonstra็ใo do Resultado Abrangente por Perํodo 001
		If !Empty(cRap) 
			aArqRtf := EcdLoadTXT( cRap )

			For nX := 1 to Len(aArqRtf)
				If oProcess <> Nil 
					oProcess:IncRegua2( STR0071 + cLinha) 
				EndIf
				cLinha := Soma1(cLinha)
				RecLock("CSF",.T.)
				CSF_FILIAL 	:= xFilial("CSF")
				CSF_CODREV 	:= __CodRev
				CSF_LINHA  	:= cLinha
				CSF_DTINI	:= dDataIni
				CSF_DTFIM	:= dDataFim
				CSF_NOMDEM 	:= cFile
				CSF_ARQRTF	:= aArqRtf[ nX ]
				CSF_CODREG := 'J800'
				CSF_TIPDOC := '001'
				
				MsUnLock()
			Next nX
		EndIf
		
		//Demonstra็ใo dos Fluxos de Caixa 002
		If !Empty(cDfc) 
			aArqRtf := EcdLoadTXT( cDfc )
			
			For nX := 1 to Len(aArqRtf)
				If oProcess <> Nil 
					oProcess:IncRegua2( STR0072 + cLinha) 
				EndIf
				cLinha := Soma1(cLinha)
				RecLock("CSF",.T.)
				CSF_FILIAL 	:= xFilial("CSF")
				CSF_CODREV 	:= __CodRev
				CSF_LINHA  	:= cLinha
				CSF_DTINI	:= dDataIni
				CSF_DTFIM	:= dDataFim
				CSF_NOMDEM 	:= cFile
				CSF_ARQRTF	:= aArqRtf[ nX ]
				CSF_CODREG := 'J800'
				CSF_TIPDOC := '002'
				
				MsUnLock()
			Next nX
		EndIf
		
		//Demonstra็ใo do Valor Acionado 003
		If !Empty(cDva) 
			aArqRtf := EcdLoadTXT( cDva )
			
			For nX := 1 to Len(aArqRtf)
				If oProcess <> Nil 
					oProcess:IncRegua2( STR0073 + cLinha) 
				EndIf
				cLinha := Soma1(cLinha)
				RecLock("CSF",.T.)
				CSF_FILIAL 	:= xFilial("CSF")
				CSF_CODREV 	:= __CodRev
				CSF_LINHA  	:= cLinha
				CSF_DTINI	:= dDataIni
				CSF_DTFIM	:= dDataFim
				CSF_NOMDEM 	:= cFile
				CSF_ARQRTF	:= aArqRtf[ nX ]
				CSF_CODREG := 'J800'
				CSF_TIPDOC := '003'
				
				MsUnLock()
			Next nX
		EndIf
		
		//Notas Explicativas 010
		If !Empty(cNte) 
			aArqRtf := EcdLoadTXT( cNte )
			
			For nX := 1 to Len(aArqRtf)
				If oProcess <> Nil 
					oProcess:IncRegua2( STR0074 + cLinha) 
				EndIf
				cLinha := Soma1(cLinha)
				RecLock("CSF",.T.)
				CSF_FILIAL 	:= xFilial("CSF")
				CSF_CODREV 	:= __CodRev
				CSF_LINHA  	:= cLinha
				CSF_DTINI	:= dDataIni
				CSF_DTFIM	:= dDataFim
				CSF_NOMDEM 	:= cFile
				CSF_ARQRTF	:= aArqRtf[ nX ]
				CSF_CODREG := 'J800'
				CSF_TIPDOC := '010'
				
				MsUnLock()
			Next nX
		EndIf
		
		//Relat๓rio da Administra็ใo 011
		If !Empty(cRadm) 
			aArqRtf := EcdLoadTXT( cRadm )
			
			For nX := 1 to Len(aArqRtf)
				If oProcess <> Nil 
					oProcess:IncRegua2( STR0075 + cLinha) 
				EndIf
				cLinha := Soma1(cLinha)
				RecLock("CSF",.T.)
				CSF_FILIAL 	:= xFilial("CSF")
				CSF_CODREV 	:= __CodRev
				CSF_LINHA  	:= cLinha
				CSF_DTINI	:= dDataIni
				CSF_DTFIM	:= dDataFim
				CSF_NOMDEM 	:= cFile
				CSF_ARQRTF	:= aArqRtf[ nX ]
				CSF_CODREG := 'J800'
				CSF_TIPDOC := '011'
				
				MsUnLock()
			Next nX
		EndIf
		
		//Parecer dos Auditores 012
		If !Empty(cPrau) 
			aArqRtf := EcdLoadTXT( cPrau )
			
			For nX := 1 to Len(aArqRtf)
				If oProcess <> Nil 
					oProcess:IncRegua2( STR0076 + cLinha) 
				EndIf
				cLinha := Soma1(cLinha)
				RecLock("CSF",.T.)
				CSF_FILIAL 	:= xFilial("CSF")
				CSF_CODREV 	:= __CodRev
				CSF_LINHA  	:= cLinha
				CSF_DTINI	:= dDataIni
				CSF_DTFIM	:= dDataFim
				CSF_NOMDEM 	:= cFile
				CSF_ARQRTF	:= aArqRtf[ nX ]
				CSF_CODREG := 'J800'
				CSF_TIPDOC := '012'
				
				MsUnLock()
			Next nX
		EndIf
		
		//Outros 099
		If !Empty(cOtr) 
			aArqRtf := EcdLoadTXT( cOtr )
			
			For nX := 1 to Len(aArqRtf)
				If oProcess <> Nil 
					oProcess:IncRegua2( STR0077 + cLinha) 
				EndIf
				cLinha := Soma1(cLinha)
				RecLock("CSF",.T.)
				CSF_FILIAL 	:= xFilial("CSF")
				CSF_CODREV 	:= __CodRev
				CSF_LINHA  	:= cLinha
				CSF_DTINI	:= dDataIni
				CSF_DTFIM	:= dDataFim
				CSF_NOMDEM 	:= cFile
				CSF_ARQRTF	:= aArqRtf[ nX ]
				CSF_CODREG := 'J800'
				CSF_TIPDOC := '099'
				
				MsUnLock()
			Next nX
		EndIf

	Else
		//serve para ECD ate versao 4 e ECF
		//Outras Demonstra็๕es
		If !Empty(cOutDem) 
			aArqRtf := EcdLoadTXT( cOutDem )

			For nX := 1 to Len(aArqRtf)
				If oProcess <> Nil 
					oProcess:IncRegua2( STR0037 + cLinha) 
				EndIf
				cLinha := Soma1(cLinha)
				RecLock("CSF",.T.)
				CSF_FILIAL 	:= xFilial("CSF")
				CSF_CODREV 	:= __CodRev
				CSF_LINHA  	:= cLinha
				CSF_DTINI	:= dDataIni
				CSF_DTFIM	:= dDataFim
				CSF_NOMDEM 	:= cFile
				CSF_ARQRTF	:= aArqRtf[ nX ]
				
				MsUnLock()
			Next nX
		EndIf
	EndIf
EndIf

//Termo de Substitui็ใo da ECD 001
If cModEsc == "ECD" .And. (lLeiaute2)  
	If !Empty(cTvfs)
		aArqRtf := EcdLoadTXT( cTvfs )
	
		For nX := 1 to Len(aArqRtf)
			If oProcess <> Nil 
				oProcess:IncRegua2( STR0078 + cLinha) 
			EndIf
			cLinha := Soma1(cLinha)
			RecLock("CSF",.T.)
				CSF_FILIAL := xFilial("CSF")
				CSF_CODREV := __CodRev
				CSF_LINHA  := cLinha
				CSF_DTINI  := dDataIni
				CSF_DTFIM  := dDataFim
				CSF_NOMDEM := cFile
				CSF_ARQRTF := aArqRtf[ nX ]
				CSF_CODREG := 'J801'
				CSF_TIPDOC := '001'
				If !Empty(cMotSubst)
					CSF_MOTSUB := cMotSubst
				EndIf
			MsUnLock()
		Next nX
	EndIf
EndIf
	
RestArea( aArea )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณProcCTBDiaบAutor  ณEquipe CTB          บ Data ณ   22/01/10  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็a๕ que unifica a gravacao do balancete diario           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SPED Contabil                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ProcCTBDia(dDiaProc, cMoeda, cTpSald, cContaIni, cContaFim, lProcCusto, dDataLp, afils)

Local cArqTmp	:= ""
Local aArea  	:= GetArea()
Local cAliasProc := IIF( lProcCusto ==.T. , "CT3" , "CT7" )   
Local axFil		:= {}
Local nIx		:= 0
Local aCs0:=StrTokArr("N|","|")


DEFAULT dDataLp := Stod( '' )


If !type("lMoedfun")=="U" .And. lMoedfun .and. lLeiaute4
	aCs0:=	StrTokArr( CS0->CS0_MOEFUN,"|" )
Endif

If Select("cArqTmp") > 0
	cArqTmp->(dbCloseArea())
EndIf

For nIx := 1 To Len( aFils )  
    If aFils[nIx][1]
		Aadd( axFil , aFils[nIx][3])
	EndIf
Next

CtGerPlan(	,,,.F.,@cArqTmp,dDiaProc,dDiaProc, cAliasProc, "" , cContaIni , cContaFim,;
"",Repl("Z",len(CTT->CTT_CUSTO)), "",Repl("Z", Len(CTD->CTD_ITEM)),"",Repl("Z", Len(CTH->CTH_CLVL)),;
cMoeda,cTpSald,CTBSetOf(""),,,,,.F.,.T.,2,"CT1",.F.,dDataLp,1,.F.,,,,,,,,,,,,,,.F.,,,,,,,,,,,,,axFil,,,,.T.)

cArqTmp->( dbGoTop() )
If aCs0[1]=="S"
	//Caso seja utilizado moeda funcional ้ primeiro efetuado a grava็ใo dos dados em moeda funcional 
	//e Depois em moeda nacional.
	//Executa a grava็ใo de dados em moeda funcional	
	ProcDiaFun(1,cArqTmp,aCs0,dDiaProc,lProcCusto)	
	CtGerPlan(	,,,.F.,@cArqTmp,dDiaProc,dDiaProc, cAliasProc, "" , cContaIni , cContaFim,;
	"",Repl("Z",len(CTT->CTT_CUSTO)), "",Repl("Z", Len(CTD->CTD_ITEM)),"",Repl("Z", Len(CTH->CTH_CLVL)),;
	aCs0[2],cTpSald,CTBSetOf(""),,,,,.F.,.T.,2,"CT1",.F.,dDataLp,1,.F.,,,,,,,,,,,,,,.F.,,,,,,,,,,,,,axFil,,,,.T.)
	cArqTmp->( dbGoTop() )				
	//Executa a grava็ใo de dados em moeda Nacional				
	ProcDiaFun(2,cArqTmp,aCs0,dDiaProc,lProcCusto)

Else
	//Caso Nใo utilize moeda funcional ้ exectado o Processamento padrใo	
	While cArqTmp->( !Eof() )
		IF cArqTmp->SALDODEB == 0 .And. cArqTmp->SALDOCRD == 0
			cArqTmp->(dbSkip())
			Loop
		Endif
		
		RecLock("CSG",.T.)
		CSG->CSG_FILIAL 	:= xFilial("CSG")
		CSG->CSG_CODREV 	:= __CodRev
		CSG->CSG_DTBAL 		:= dDiaProc
		CSG->CSG_CONTA 		:= cArqTmp->CONTA
		CSG->CSG_CCUSTO 	:= Iif(lProcCusto==.T.,cArqTmp->CUSTO,"")
		CSG->CSG_VALINI 	:= ABS(cArqTmp->SALDOANT)
		CSG->CSG_VALDEB 	:= ABS(cArqTmp->SALDODEB)
		CSG->CSG_VALCRE		:= ABS(cArqTmp->SALDOCRD)
		CSG->CSG_VALMOV 	:= ABS(cArqTmp->MOVIMENTO)
		CSG->CSG_VALFIN 	:= ABS(cArqTmp->SALDOATU)
		CSG->CSG_INDINI 	:= IIF(cArqTmp->SALDOANT>0,"C","D")
		CSG->CSG_INDFIM 	:= IIF(cArqTmp->SALDOATU>0,"C","D")
		
		MsUnLock()
		cArqTmp->(dbSkip())
	EndDo
	
	dbSelectArea("cArqTmp")
	Set Filter To
	dbCloseArea()
	If Select("cArqTmp") == 0
		FErase(cArqTmp+GetDBExtension())
		FErase(cArqTmp+OrdBagExt())
	EndIF
Endif

RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณECDGetDtLp บAutor ณRenato F. Campos    บ Data ณ  04/06/09   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se a movimenta็ใo ้ de apura็ใo de resultado      บฑฑ
ฑฑบ          ณ caso for apura็ใo de ponte, a mesma ้ ignorada             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SpedMov                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ECDGetDtLp( cFilMov )
Local aArea := GetArea()

If Empty(cFilMov)
	cFilMov := cFilAnt
EndIf
If FindFunction("CtLPCW0Tab") .And. CtLPCW0Tab()
	DbSelectArea( "CW0" )
	DbSetOrder(1)
	IF DbSeek( xFilial( "CW0" ) + "LP" + cEmpAnt + cFilMov )
		While CW0->CW0_FILIAL == xFilial( "CW0" ) .AND. CW0->CW0_TABELA == "LP" .AND.;
			Alltrim( CW0->CW0_CHAVE ) == Alltrim( cEmpAnt + cFilMov ) .AND. !Eof()
			
			aAdd( __aDtLp , ;
							{ Substr( CW0->CW0_DESC01 ,1,8) ;
							, Substr( CW0->CW0_DESC01 ,9,2) ;
							, Substr( CW0->CW0_DESC01 ,11,1) ;
							, Substr( CW0->CW0_DESC01 ,12,1) ;
							})
	
			CW0->( DbSkip() )
		EndDo
	Endif
Else
	DbSelectArea( "SX5" )
	DbSetOrder(1)
	
	IF DbSeek( xFilial( "SX5" ) + "LP" + cEmpAnt + cFilMov )
		While SX5->X5_FILIAL == xFilial( "SX5" ) .AND. SX5->X5_TABELA == "LP" .AND.;
			Alltrim( SX5->X5_CHAVE ) == cEmpAnt + cFilMov .AND. !Eof()
			
			aAdd( __aDtLp , ;
							{ Substr( SX5->X5_DESCRI ,1,8) ;
							, Substr( SX5->X5_DESCRI ,9,2) ;
							, Substr( SX5->X5_DESCRI ,11,1) ;
							, Substr( SX5->X5_DESCRI ,12,1) ;
							})
	
			SX5->( DbSkip() )
		EndDo
	Endif
EndIf

RestArea( aArea )

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBS011   บAutor  ณMicrosiga           บ Data ณ  03/26/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ECDExpCad(oProcess, aParamExp, __CodRev, cModEsc, nFinEsc)
Local lRet := .T.
Local aArea := GetArea()
Default cModEsc := "ECD"

lRet := lRet .And. ExportaConta( oProcess,; 
								aParamExp[ECD_CONTA_INI] ,;
								aParamExp[ECD_CONTA_FIM],;
								aParamExp[ECD_DATA_FIM],;
								aParamExp[ECD_DATA_INI],;
								aParamExp[ECD_MOEDA],;
								aParamExp[ECD_TIPO_SALDO],;
								cModEsc,;
								aParamExp[ECD_AFILS],;
								aParamExp[ECD_PROC_CUSTO],;
								aParamExp[ ECD_IDBLK ])

lRet := lRet .And. ExportaCusto( oProcess, aParamExp[ECD_DATA_FIM] ,aParamExp[ECD_PROC_CUSTO] )

lRet := lRet .And. ExportaCtRef( oProcess,; 
								aParamExp[ECD_CONTA_INI],; 
								aParamExp[ECD_CONTA_FIM],;
								aParamExp[ECD_DATA_FIM],;
								aParamExp[ECD_PROC_CUSTO],;
								aParamExp[ECD_COD_PLA],;
								cModEsc,;
								aParamExp[ECD_VER_PLA],;
								Nil,;
								aParamExp[ ECD_IDBLK ])

If cModEsc == "ECD"
	lRet := lRet .And. ExportaPlanDem( oProcess, aParamExp[ECD_COD_BALPAT], aParamExp[ECD_COD_DRE]  , aParamExp[ECD_PROC_CUSTO] , aParamExp[ECD_COD_DLPA], aParamExp[ECD_COD_DMPL], aParamExp[ECD_COD_DFC], aParamExp[ECD_COD_DVA] )	
EndIf
lRet := lRet .And. ExportaHistPadrao( oProcess )
lRet := lRet .And. ExportaSignatario( oProcess, aParamExp[ECD_DATA_FIM], ,cModEsc, nFinEsc )
lRet := lRet .And. ExportaParticipante( oProcess, aParamExp[ECD_DATA_FIM] )

If cModEsc == "ECD" .And. lLeiaute3
	
	If aParamExp[ ECD_GDE_PORTE	] == 2 //cadastro de auditores para empresa sujeita a auditoria
		lRet := lRet .And. ExportaAuditor( oProcess )
	EndIf
	
	If aParamExp[ ECD_SCP_IND ] == 2 //cadastro de SCP para empresas que possuem socio ostensivo
		lRet := lRet .And. ExportaSCP( oProcess )
	EndIf
	
	lRet := lRet .And. ExportaSubConta( oProcess )
	
EndIf
RestArea(aArea)
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBS011   บAutor  ณMicrosiga           บ Data ณ  03/26/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GetCodRev()

Return __CodRev
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณProcCTBDiaบAutor  ณEquipe CTB          บ Data ณ   23/03/10  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Cria Procedures para de geracao do moviemntos             บฑฑ
ฑฑบ          ณ   nas tabelas CAS e CSB                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SPED Contabil                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ctbs11Proc(aProc, aFils, aTpSald, cModEsc,cEntRef, cCodPla,cVerPla,cMoeda)
Local aArea   := GetArea()
Local lRet    := .T.
Local cArqTrb := ""
Local cArq    := ""
Local nProx   := 1
Local aCs0:=StrTokArr("N|","|")

/* ------------------------------------------------------------------------------
	NAO mudar a ordem de criacao das procedures
   Ct11ProcPa - GERA MOV................................................ aProc[6]
      +--> ECDCHVMOV  - Ponto de entrada que altera a chave............. aProc[1]
      +--> Ct11Filial - Cria procedure que retorna a filial corrente.... aProc[2]
      +--> Ct11DtLp   - GetDtp()-Verifica se tem apuracao nessa Data.... aProc[3]
      +--> Ct11PopCSA - Grava CSA....................................... aProc[4]
              +--> CTB205 - Grava CSL................................... aProc[4]
      +--> Ct11PopCSB - Grava CSB....................................... aProc[5]
   ------------------------------------------------------------------------------ */
   
If cModEsc == "ECD" .And. lMoedfun .and. lLeiaute4
	aCs0:=	StrTokArr( CS0->CS0_MOEFUN,"|" )
Endif
   
   
cArqTrb := CriaTrab(,.F.)
cArq    := cArqTRB+StrZero(nProx,2)
AADD( aProc, "ECDCHVMOV"+"_"+cEmpAnt)
/* Cria Ponto de entrada ECDCHVMOV */
lRet := Ct11PtoE(aProc[nProx])
/* Cria Procedure XFILIAL no database - TAM de cada uni// de negocio */
If lRet
	nProx := nProx + 1
	cArq  := cArqTRB+StrZero(nProx,2)
	AADD( aProc, cArq+"_"+cEmpAnt)
	lRet := Ct11Filial(aProc[nProx])
EndIf
/* Cria Procedure que verifaca se e data de Apuracao de Lucros e Perdas */
If lRet
	nProx := nProx + 1
	cArq  := cArqTRB+StrZero(nProx,2)
	AADD( aProc, cArq+"_"+cEmpAnt)
	lRet := Ct11DtLp(aProc[nProx])
EndIf
/* Cria Procedure que faz a gravacao do CSA */
If lRet
	nProx := nProx + 1
	cArq  := cArqTRB+StrZero(nProx,2)
	AADD( aProc, cArq+"_"+cEmpAnt)
	lRet := Ct11PopCSA(aProc[nProx])
EndIf
/* Cria Procedure que faz a gravacao do CSL que eh chamada na gravacao da CSB */
If lRet
	nProx := nProx + 1
	cArq  := cArqTRB+StrZero(nProx,2)
	AADD( aProc, cArq+"_"+cEmpAnt)
	lRet := Ct11PopCSL(aProc[nProx],aProc, cCodPla,cVerPla)
EndIf
/* Cria Procedure que faz a gravacao do CSB */
If lRet
	nProx := nProx + 1
	cArq  := cArqTRB+StrZero(nProx,2)
	AADD( aProc, cArq+"_"+cEmpAnt)
	lRet := Ct11PopCSB(aProc[nProx], aProc[nProx-1], aProc, cEntRef, cCodPla,cVerPla)
EndIf
/* Cria Procedure Pai */
If lRet
	If cModEsc == "ECD" .And. lMoedfun .and. lLeiaute4
		nProx := nProx + 1
		cArq  := cArqTRB+StrZero(nProx,2)
		AADD( aProc, cArq+"_"+cEmpAnt)
		lRet := Ct11PMF(aProc[nProx], aProc, aFils, aTpSald, cModEsc, aCs0[2],cMoeda)	
	Else
		nProx := nProx + 1
		cArq  := cArqTRB+StrZero(nProx,2)
		AADD( aProc, cArq+"_"+cEmpAnt)
		lRet := Ct11ProcPa(aProc[nProx], aProc, aFils, aTpSald, cModEsc)
	Endif 
EndIf

Restarea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCt11PtoE  บAutor  ณEquipe CTB          บ Data ณ   23/03/10  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Cria Procedures de ponto de entrada ECDCHVMOV             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SPED Contabil                                              บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParmetrosณ ExpC1 = Nome da procedure a ser criada                     ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ   
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ */

Function Ct11PtoE(cProc)
Local aArea  := GetArea()
Local lRet   := .T.
Local cQuery := ""
Local nPTratRec := 0

cQuery := "Create Procedure "+cProc+" ("+CRLF
cQuery += "    @IN_CHAVE  VarChar( "+StrZero(TamSx3('CSA_NUMLOT')[1], 3)+ " ),"+CRLF
cQuery += "    @OUT_CHAVE VarChar( "+StrZero(TamSx3('CSA_NUMLOT')[1], 3)+ " ) OutPut"+CRLF
cQuery += ")"+CRLF

cQuery += "as"+CRLF
/* ------------------------------------------------------------------------------------
    Versใo          - <v>  Protheus 9.12 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBS011.PRW </s>
    Descricao       - <d>  SPED SigaCTB </d>
    Procedure       -      Popular CSA, CSB
    Funcao do Siga  -      ECDCHVMOV  - ponto de entrada que permite a alteracao da chave
    Entrada         - <ri> @IN_CHAVE  - Chave que pode ser alterada </ri> 
    Saida           - <o>  @OUT_CHAVE - Retorna chave alterada </o>
    Responsavel :     <r>  	</r>
    Data        :     02/03/2010

   Obs :@cChave = @cCT2_FILIAL||@cCT2_DATA||@cCT2_LOTE||@cCT2_SBLOTE||@cCT2_DOC 
   -------------------------------------------------------------------------------------- */

cQuery += "Declare @cChave Char( "+StrZero(TamSx3('CSA_NUMLOT')[1], 3)+" )"+CRLF
cQuery += "begin"+CRLF
cQuery += "   select @cChave = @IN_CHAVE"+CRLF
cQuery += "   select @OUT_CHAVE = @cChave"+CRLF
cQuery += "end"+CRLF

cQuery := CtbAjustaP(.T., cQuery, @nPTratRec)
cQuery := MsParse(cQuery,If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
cQuery := CtbAjustaP(.F., cQuery, nPTratRec)

If !TCSPExist( cProc )
	nRet := TcSqlExec(cQuery)
	If nRet != 0 
		If !__lBlind
			MsgAlert(STR0059+aProc)//'Erro na criacao da procedure Ponto de entrada '
			lRet:= .F.
		EndIf
	EndIf
EndIf

RestArea(aArea)
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCt11DtLp  บAutor  ณEquipe CTB          บ Data ณ   24/03/10  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Cria procedure par verifcar se a data e de apuracao de    บฑฑ
ฑฑบ          ณ Lucros e Perdas                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SPED Contabil                                              บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParmetrosณ ExpC1 = Nome da procedure a ser criada                     ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ */

Function Ct11DtLp(cProc)
Local aArea  := GetArea()
Local lRet   := .T.
Local cQuery := ""
Local nPTratRec := 0
Local nTamData  := 8
Local nTamMoeda := TamSx3('CT2_MOEDLC')[1]
Local nTamTpSald:= TamSx3('CT2_TPSALD')[1]
Local nTamTot   := nTamData+nTamMoeda+nTamTpSald+1  // +1 de 'Z'

cQuery := "Create Procedure "+cProc+CRLF
cQuery += "("+CRLF
cQuery += "   @IN_EMP      Char( "+StrZero(TamSx3('CT2_EMPORI')[1], 3)+" ),"+CRLF
cQuery += "   @IN_FIL      Char( "+StrZero(TamSx3('CT2_FILIAL')[1], 3)+" ),"+CRLF
cQuery += "   @IN_DATA     Char( 08 ),"+CRLF
cQuery += "   @IN_MOEDA    Char( "+StrZero(TamSx3('CT2_MOEDLC')[1], 3)+" ),"+CRLF
cQuery += "   @IN_TPSALD   Char( "+StrZero(TamSx3('CT2_TPSALD')[1], 3)+" ),"+CRLF
cQuery += "   @OUT_RESULT  Char( 01 ) OutPut"+CRLF
cQuery += "   )"+CRLF
cQuery += "as"+CRLF
/* ------------------------------------------------------------------------------------
    Versใo          - <v>  Protheus P.10 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  SPEDCTBA.PRW </s>
    Descricao       - <d>  SPED SigaCTB </d>
    Procedure       -      Verifica se ้ data de Apuracao
    Funcao do Siga  -      ProcMov()
    Entrada         - <ri> @IN_EMP     - Empresa onde procurar a data de apuracao
                           @IN_FIL     - Filial onde procurar a data de Apuracao
                           @IN_DATA    - Data a Verificar
                           @IN_MOEDA   - Moeda escolhida
                           @IN_TPSALD  - Tipos de Saldo escolhido
    Saida           - <o>  @OUT_RESULT - '0' NAO e data de Apuracao, '1' e data de Apuracao </ro>
    Responsavel :     <r>  	</r>
    Data        :     26/02/2010
   -------------------------------------------------------------------------------------- */
cQuery += "Declare @iRecno integer"+CRLF

cQuery += "begin"+CRLF
   
cQuery += "   Select @iRecno = Null"+CRLF
cQuery += "   select @OUT_RESULT = '0'"+CRLF

If FindFunction("CtLPCW0Tab") .And. CtLPCW0Tab()   
	cQuery += "    Select @iRecno = R_E_C_N_O_"+CRLF
	cQuery += "      From "+RetSqlName("CW0")+CRLF
	cQuery += "     Where CW0_TABELA = 'LP'"+CRLF
	cQuery += "       and CW0_CHAVE  = @IN_EMP||@IN_FIL "+CRLF
	cQuery += "       and Substring(CW0_DESC01,1,"+StrZero(nTamTot,2)+") = @IN_DATA||@IN_MOEDA||@IN_TPSALD||'Z'"+CRLF
	cQuery += "       and D_E_L_E_T_ = ' '"+CRLF
	cQuery += "    If @iRecno is null select @OUT_RESULT = '0'"+CRLF
	cQuery += "    Else select @OUT_RESULT = '1'"+CRLF
	cQuery += "End"+CRLF
Else
	cQuery += "    Select @iRecno = R_E_C_N_O_"+CRLF
	cQuery += "      From "+RetSqlName("SX5")+CRLF
	cQuery += "     Where X5_TABELA = 'LP'"+CRLF
	cQuery += "       and X5_CHAVE  = @IN_EMP||@IN_FIL "+CRLF
	cQuery += "       and Substring(X5_DESCRI,1,"+StrZero(nTamTot,2)+") = @IN_DATA||@IN_MOEDA||@IN_TPSALD||'Z'"+CRLF
	cQuery += "       and D_E_L_E_T_ = ' '"+CRLF
	cQuery += "    If @iRecno is null select @OUT_RESULT = '0'"+CRLF
	cQuery += "    Else select @OUT_RESULT = '1'"+CRLF
	cQuery += "End"+CRLF
EndIf
cQuery := CtbAjustaP(.T., cQuery, @nPTratRec)
cQuery := MsParse(cQuery,If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
cQuery := CtbAjustaP(.F., cQuery, nPTratRec)

If !TCSPExist( cProc )
	nRet := TcSqlExec(cQuery)
	If nRet != 0 
		If !__lBlind
			MsgAlert(STR0060+cProc)//'Erro na criacao da procedure de verificacao de data de Apuracao de Lucros e Perdas'
			lRet:= .F.
		EndIf
	EndIf
EndIf

RestArea(aArea)
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCt11PopCSAบAutor  ณEquipe CTB          บ Data ณ   24/03/10  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Cria procedure de gravacao de movimentos no CSA           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SPED Contabil                                              บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParmetrosณ ExpC1 = Nome da procedure a ser criada                     ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ */

Function Ct11PopCSA(cProc)
Local aArea  := GetArea()
Local lRet   := .T.
Local cQuery := ""
Local nPTratRec := 0
Local aCs0:=StrTokArr("N|","|")

If !type("lMoedfun")=="U" .And. lMoedfun .and. lLeiaute4
	aCs0:=	StrTokArr( CS0->CS0_MOEFUN,"|" )
Endif

cQuery := "Create Procedure "+cProc+CRLF
cQuery += "("+CRLF
cQuery += "   @IN_FILIAL  Char( "+StrZero(TamSx3('CSA_FILIAL' )[1], 3)+" ),"+CRLF
cQuery += "   @IN_CODREV  Char( "+StrZero(TamSx3('CSA_CODREV' )[1], 3)+" ),"+CRLF
cQuery += "   @IN_NUMLOT  Char( "+StrZero(TamSx3('CSA_NUMLOT' )[1], 3)+" ),"+CRLF
cQuery += "   @IN_DTLANC  Char( "+StrZero(TamSx3('CSA_DTLANC' )[1], 3)+" ),"+CRLF
cQuery += "   @IN_VLLCTO  Float,"+CRLF
cQuery += "   @IN_INDTIP  Char( "+StrZero(TamSx3('CSA_INDTIP' )[1], 3)+" ),"+CRLF
cQuery += "   @IN_DTEXT   Char( "+StrZero(8, 3)+" )"+CRLF

If  !type("lMoedfun")=="U" .And. lMoedfun .and. lLeiaute4
	cQuery += ",   @IN_VLLFUN  Float,"+CRLF
	cQuery += "   @IN_ADDVLL  Float"+CRLF	
Endif 
cQuery += "   )"+CRLF
/* ------------------------------------------------------------------------------------
    Versใo          - <v>  Protheus P.10 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  SPEDCTBA.PRW </s>
    Descricao       - <d>  SPED SigaCTB </d>
    Procedure       -      Grava CSA
    Funcao do Siga  -      
    Entrada         - <ri> @IN_FILIAL - filial a gravar
                           @IN_CODREV - Codigo da Revisao
                           @IN_NUMLOT - Numero do Lote
                           @IN_DTLANC - Data do Lancto
                           @IN_VLLCTO - Valro do Lancto
                           @IN_INDTIP - indice do lancto
    Saida           - <o>  </ro>
    Responsavel :     <r>  	</r>
    Data        :     01/03/2010
   -------------------------------------------------------------------------------------- */
cQuery += "as"+CRLF
cQuery += "Declare @iRecno      integer"+CRLF
cQuery += "Declare @nVlLcto     Float"+CRLF
If  !type("lMoedfun")=="U" .And. lMoedfun .and. lLeiaute4
	cQuery += "Declare @nVLLFUN     Float"+CRLF
	cQuery += "Declare @nADDVLL     Float"+CRLF
Endif  
cQuery += CRLF
cQuery += "begin"+CRLF
   
cQuery += "   select @nVlLcto = Round( @IN_VLLCTO, 2 )"+CRLF
If  !type("lMoedfun")=="U" .And. lMoedfun .and. lLeiaute4
	cQuery += "   select @nVLLFUN = Round( @IN_VLLFUN, 2 )"+CRLF
	cQuery += "   select @nADDVLL = Round( @IN_ADDVLL, 2 )"+CRLF
Endif  

cQuery += "   select @iRecno = IsNull(Max( R_E_C_N_O_ ), 0 ) from "+RetSqlName("CSA")+CRLF
cQuery += "   select @iRecno = @iRecno + 1"+CRLF
   
cQuery += "   ##TRATARECNO @iRecno\"+CRLF
cQuery += "   Insert into "+REtSqlName("CSA")+" ( CSA_FILIAL, CSA_CODREV, CSA_NUMLOT, CSA_DTLANC, CSA_VLLCTO, CSA_INDTIP "

If __lExistCSQ
	cQuery += ",  CSA_DTEXT"  
EndIf

If  !type("lMoedfun")=="U" .And. lMoedfun .and. lLeiaute4
	cQuery += ", CSA_VLLFUN, CSA_ADDVLL "  
Endif
cQuery += ", R_E_C_N_O_ )" +CRLF

If __lExistCSQ
	cQuery += "                values( @IN_FILIAL, @IN_CODREV, RTRIM(@IN_NUMLOT)||@IN_DTEXT, @IN_DTLANC, @nVlLcto, @IN_INDTIP, @IN_DTEXT "  
Else
	cQuery += "                values( @IN_FILIAL, @IN_CODREV, @IN_NUMLOT, @IN_DTLANC, @nVlLcto, @IN_INDTIP "
EndIf

If  !type("lMoedfun")=="U" .And. lMoedfun .and. lLeiaute4
	cQuery += ", @nVLLFUN, @nADDVLL "  
Endif
cQuery +=",@iRecno )"+CRLF
cQuery += "   ##FIMTRATARECNO"+CRLF
   
cQuery += "End"+CRLF

cQuery := CtbAjustaP(.T., cQuery, @nPTratRec)
cQuery := MsParse(cQuery,If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
cQuery := CtbAjustaP(.F., cQuery, nPTratRec)

If !TCSPExist( cProc )
	nRet := TcSqlExec(cQuery)
	If nRet != 0 
		If !__lBlind
			MsgAlert(STR0061+cProc)//'Erro na criacao da procedure de geracao do CSA '
			lRet:= .F.
		EndIf
	EndIf
EndIf

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCt11PopCSBบAutor  ณEquipe CTB          บ Data ณ   24/03/10  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Cria procedure de gravacao de movimentos no CSB           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SPED Contabil                                              บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParmetrosณ ExpC1 = Nome da procedure a ser criada                     ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ */

Function Ct11PopCSB(cProc, cProcCSL,aProc,cEntRef, cCodPla,cVerPla)
Local aArea  := GetArea()
Local lRet   := .T.
Local cQuery := ""
Local nPTratRec := 0

Local aCs0:=StrTokArr("N|","|")

If !type("lMoedfun")=="U" .And. lMoedfun .and. lLeiaute4
	aCs0:=	StrTokArr( CS0->CS0_MOEFUN,"|" )
Endif

cQuery := "Create Procedure "+cProc+CRLF
cQuery += "("+CRLF
cQuery += "   @IN_FILIAL  Char( "+StrZero(TamSx3( 'CSB_FILIAL' )[1], 3)+" ),"+CRLF
cQuery += "   @IN_CODREV  Char( "+StrZero(TamSx3( 'CSB_CODREV' )[1], 3)+" ),"+CRLF
cQuery += "   @IN_CHAVE   Char( "+StrZero(TamSx3('CSB_NUMLOT' )[1], 3)+" ),"+CRLF
cQuery += "   @IN_LINHA   Char( "+StrZero(TamSx3('CSB_LINHA' )[1], 3)+" ),"+CRLF
cQuery += "   @IN_DEBITO  Char( "+StrZero(TamSx3('CSB_CODCTA' )[1], 3)+" ),"+CRLF
cQuery += "   @IN_CCD     Char( "+StrZero(TamSx3('CSB_CCUSTO' )[1], 3)+" ),"+CRLF
cQuery += "   @IN_DC      Char( 01 ),"+CRLF
cQuery += "   @IN_CODHIST Char( "+StrZero(TamSx3('CSB_CODHIS' )[1], 3)+" ),"+CRLF
cQuery += "   @IN_HIST    VarChar( "+StrZero(TamSx3('CSB_HISTOR' )[1], 3)+" ),"+CRLF
cQuery += "   @IN_VALOR   Float,"+CRLF
cQuery += "   @IN_DTEXT   Char( 008 ), "+CRLF  //DATA DE LANวAMENTO EXTEMPORANEO

If  !type("lMoedfun")=="U" .And. lMoedfun .and. lLeiaute4
	cQuery += "   @IN_FUVALOR   Float,"+CRLF
	cQuery += "   @IN_ADVALOR   Float,"+CRLF
	cQuery += "   @IN_TXFECHA   Float,"+CRLF
	cQuery += "   @IN_TXMEDIA   Float,"+CRLF
Endif  

cQuery += "   @IN_CODPAR  Char( "+StrZero(TamSx3('CSB_CODPAR' )[1], 3)+" ),"+CRLF
cQuery += "   @IN_NUMARQ  Char( "+StrZero(TamSx3('CSB_NUMARQ' )[1], 3)+" ),"+CRLF
cQuery += "   @IN_DATA    Char( 08 ), "+CRLF
cQuery += "   @IN_LCUSTO  Char( 01 ), "+CRLF
cQuery += "   @IN_ENTREF  Char( 02 ), "+CRLF
cQuery += "   @OUT_RECNO  Integer OUTPUT "+CRLF
cQuery += " )"+CRLF

/* ------------------------------------------------------------------------------------
    Versใo          - <v>  Protheus P.10 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  SPEDCTBA.PRW </s>
    Descricao       - <d>  SPED SigaCTB </d>
    Procedure       -      Grava CSA
    Funcao do Siga  -      
    Entrada         - <ri> @IN_FILIAL - filial a gravar
                           @IN_CODREV - Codigo da Revisao
                           @IN_NUMLOT - Numero do Lote
                           @IN_DTLANC - Data do Lancto
                           @IN_VLLCTO - Valro do Lancto
                           @IN_INDTIP - indice do lancto
                           @IN_DATA   - Data do Lancto <ri/>
    Saida           - <o>  </ro>
    Responsavel :     <r>  	</r>
    Data        :     01/03/2010
   -------------------------------------------------------------------------------------- */
cQuery += "as"+CRLF
cQuery += "Declare @cFilial_CSB char( " + StrZero(TamSx3('CSB_FILIAL')[1], 3)+" ) "+CRLF
cQuery += "Declare @iRecno      integer"+CRLF
cQuery += "Declare @nVlLcto     Float"+CRLF
cQuery += "Declare @cCusto      Char( "+StrZero(TamSx3('CSB_CCUSTO' )[1], 3)+" )"+CRLF
cQuery += "declare @iRecnoZ     Integer"+CRLF
cQuery += "Declare @cAux        Char( 03 )"+CRLF
cQuery += "Declare @NCONT       Integer"+CRLF
If  !type("lMoedfun")=="U" .And. lMoedfun .and. lLeiaute4
	cQuery += "Declare @nFuVlLcto     Float"+CRLF
	cQuery += "Declare @nAdVlLcto     Float"+CRLF
	cQuery += "Declare @cNtSped     Char( "+StrZero(TamSx3('CT1_NTSPED' )[1], 3)+" )"+CRLF	
	cQuery += "Declare @nTaxa     Float"+CRLF
	cQuery += "Declare @nCtpTaxa    Float"+CRLF
	cQuery += "Declare @nCtpTxMd    Float"+CRLF
	cQuery += "Declare @nDebCsa     Float"+CRLF
	cQuery += "Declare @nCreCsa     Float"+CRLF
	cQuery += "Declare @nDFuCsa     Float"+CRLF
	cQuery += "Declare @nCFuCsa     Float"+CRLF
	cQuery += "Declare @nDAdCsa     Float"+CRLF
	cQuery += "Declare @nCAdCsa     Float"+CRLF
		
Endif 

cQuery += ""+CRLF
cQuery += "begin"+CRLF
If  !type("lMoedfun")=="U" .And. lMoedfun .and. lLeiaute4
	cQuery += "select @nFuVlLcto     = 0"+CRLF
	cQuery += "select @nAdVlLcto     = 0"+CRLF
	cQuery += "select @cNtSped     = ''"+CRLF		
	cQuery += "select @nTaxa     = 0"+CRLF
	cQuery += "select @nCtpTaxa    = 0"+CRLF
	cQuery += "select @nCtpTxMd    = 0"+CRLF
	cQuery += "select @nDebCsa     = 0"+CRLF
	cQuery += "select @nCreCsa     = 0"+CRLF
	cQuery += "select @nDFuCsa     = 0"+CRLF
	cQuery += "select @nCFuCsa     = 0"+CRLF
	cQuery += "select @nDAdCsa     = 0"+CRLF
	cQuery += "select @nCAdCsa     = 0"+CRLF

	cQuery += "   select @nCtpTxMd = @IN_TXMEDIA "+CRLF
	cQuery += "   select @cNtSped = CT1_NTSPED FROM " + RetSqlName( "CT1" ) + " WHERE CT1_CONTA = @IN_DEBITO"+CRLF
	//perguntar referente a filial 
	cQuery += "   select @nCtpTaxa = CTP_TAXA FROM " + RetSqlName( "CTP" ) + "  WHERE CTP_FILIAL = '"+ xFilial("CTP") +"' and CTP_MOEDA ='" +aCs0[2]+"' and CTP_DATA = @IN_DATA"+CRLF
	cQuery += "   If @cNtSped  between '01' and '02' begin select @nTaxa = @IN_TXFECHA end"+CRLF
	cQuery += "   If @cNtSped  = '03' select @nTaxa = @nCtpTaxa"+CRLF
	cQuery += "   If @cNtSped  = '04' begin select @nTaxa = @nCtpTxMd end"+CRLF
	cQuery += "   select @nVlLcto = Round( (@IN_VALOR *@nTaxa) , 2 )"+CRLF
	cQuery += "   select @nFuVlLcto = Round( @IN_VALOR, 2 )"+CRLF
	cQuery += "   select @nAdVlLcto = Round( @IN_ADVALOR, 2 )"+CRLF
Else
	cQuery += "   select @nVlLcto = Round( @IN_VALOR, 2 )"+CRLF
Endif
cQuery += "   select @cAux = 'CSB'"+CRLF

// chama a procedure xfilial
cQuery += "   Exec "+aProc[2]+ " @cAux, @IN_FILIAL, @cFilial_CSB OutPut"+CRLF

cQuery += "   select @OUT_RECNO = 0"+CRLF
cQuery += "   select @cCusto = @IN_CCD"+CRLF
cQuery += "   If @IN_LCUSTO = '0' select @cCusto = ' '"+CRLF

cQuery += "   select @iRecno = IsNull(Max( R_E_C_N_O_ ), 0 ) from "+RetSqlName('CSB') +CRLF
cQuery += "   select @iRecno = @iRecno + 1"+CRLF
cQuery += "   If Round( @nVlLcto , 2 ) != 0.00  begin" + CRLF
cQuery += "   ##TRATARECNO @iRecno\"+CRLF

If  !type("lMoedfun")=="U" .And. lMoedfun .and. lLeiaute4
	cQuery += "   Insert into "+RetSqlName('CSB')+" ( CSB_FILIAL,  CSB_CODREV, CSB_NUMLOT, CSB_LINHA,  CSB_CODCTA, CSB_CCUSTO, CSB_INDDC," + CRLF
	cQuery += "                        CSB_CODHIS,  CSB_HISTOR, CSB_VLPART,CSB_FUPART, CSB_TAXA, CSB_ADPART, CSB_CODPAR, CSB_NUMARQ, CSB_DTLANC"
	If __lExistCSQ  //se existe a tabela CSQ leiaute 7
		cQuery += " , CSB_DTEXT" + CRLF
	EndIf 
	cQuery += " , R_E_C_N_O_ )" + CRLF
	cQuery += "                values( @cFilial_CSB,  @IN_CODREV, @IN_CHAVE,  @IN_LINHA,  @IN_DEBITO, @cCusto,    @IN_DC," + CRLF
	cQuery += "                        @IN_CODHIST, SUBSTRING( @IN_HIST,1, " + StrZero(TamSx3('CSB_HISTOR' )[1], 3) + " )," + CRLF
	cQuery += "                        @nVlLcto,@nFuVlLcto,@nTaxa,@nAdVlLcto, @IN_CODPAR, @IN_NUMARQ, @IN_DATA "
	If __lExistCSQ  //se existe a tabela CSQ leiaute 7
		cQuery += " , @IN_DTEXT" + CRLF
	EndIf 
	cQuery += " , @iRecno )" + CRLF	   
	cQuery += "   ##FIMTRATARECNO"+CRLF
Else
	cQuery += "   Insert into "+RetSqlName('CSB')+" ( CSB_FILIAL,  CSB_CODREV, CSB_NUMLOT, CSB_LINHA,  CSB_CODCTA, CSB_CCUSTO, CSB_INDDC," + CRLF
	cQuery += "                        CSB_CODHIS,  CSB_HISTOR, CSB_VLPART, CSB_CODPAR, CSB_NUMARQ, CSB_DTLANC"
	
	If __lExistCSQ  //se existe a tabela CSQ leiaute 7
		cQuery += " , CSB_DTEXT" + CRLF
	EndIf 
	cQuery += " , R_E_C_N_O_ )" + CRLF

	If __lExistCSQ
		cQuery += "                values( @cFilial_CSB,  @IN_CODREV, RTRIM(@IN_CHAVE)||@IN_DTEXT,  @IN_LINHA,  @IN_DEBITO, @cCusto, @IN_DC," + CRLF
	Else
		cQuery += "                values( @cFilial_CSB,  @IN_CODREV, @IN_CHAVE,  @IN_LINHA,  @IN_DEBITO, @cCusto, @IN_DC," + CRLF
	EndIf

	cQuery += "                        @IN_CODHIST, SUBSTRING( @IN_HIST,1, " + StrZero(TamSx3('CSB_HISTOR' )[1], 3) + " )," + CRLF
	cQuery += "                        @nVlLcto,  @IN_CODPAR, @IN_NUMARQ, @IN_DATA"
	If __lExistCSQ  //se existe a tabela CSQ leiaute 7
		cQuery += " , @IN_DTEXT" + CRLF
	EndIf 
	cQuery += " , @iRecno )" + CRLF	   
	cQuery += "   ##FIMTRATARECNO"+CRLF
Endif 

If !Empty( cEntRef ) .And. !VerUnicRef( cEntRef, cCodPla ,cVerPla )
	//chama a procedure para gravar CSL
	If  !type("lMoedfun")=="U" .And. lMoedfun .and. lLeiaute4
		cQuery += "         exec "+cProcCSL+" @IN_FILIAL, @IN_CODREV,   @IN_CHAVE,      @IN_LINHA, @IN_DEBITO, @cCusto, @IN_DC, "+CRLF
		cQuery += "                           @nVlLcto,@nFuVlLcto,@nAdVlLcto,@IN_TAXA @IN_DATA, @IN_LCUSTO, @IN_ENTREF, @IN_NUMARQ, @iRecnoZ OutPut"+CRLF
	Else
		cQuery += "         exec "+cProcCSL+" @IN_FILIAL, @IN_CODREV,   @IN_CHAVE,      @IN_LINHA, @IN_DEBITO, @cCusto, @IN_DC, "+CRLF
		cQuery += "                           @nVlLcto, @IN_DATA, @IN_LCUSTO, @IN_ENTREF, @IN_NUMARQ, @iRecnoZ OutPut"+CRLF
	Endif

EndIf

cQuery += "   End"+CRLF

If  !type("lMoedfun")=="U" .And. lMoedfun .and. lLeiaute4
	
	cQuery += "   SELECT @nDebCsa = isnull(sum(CSB_VLPART),0) FROM "+RetSqlName("CSB")+" WHERE CSB_FILIAL = '"+ xFilial("CSB") +"' and D_E_L_E_T_=' '  AND CSB_INDDC='D' AND CSB_DTLANC = @IN_DATA AND CSB_CODREV = @IN_CODREV  GROUP BY CSB_FILIAL, CSB_CODREV, CSB_DTLANC, CSB_NUMLOT   "+CRLF
	cQuery += "   SELECT @nCreCsa = isnull(sum(CSB_VLPART),0) FROM "+RetSqlName("CSB")+" WHERE CSB_FILIAL = '"+ xFilial("CSB") +"' and D_E_L_E_T_=' '  AND CSB_INDDC='C' AND CSB_DTLANC = @IN_DATA AND CSB_CODREV = @IN_CODREV  GROUP BY CSB_FILIAL, CSB_CODREV, CSB_DTLANC, CSB_NUMLOT   "+CRLF
	
	cQuery += "   SELECT @nDFuCsa = isnull(sum(CSB_FUPART),0) FROM "+RetSqlName("CSB")+" WHERE CSB_FILIAL = '"+ xFilial("CSB") +"' and D_E_L_E_T_=' '  AND CSB_INDDC='D' AND CSB_DTLANC = @IN_DATA AND CSB_CODREV = @IN_CODREV  GROUP BY CSB_FILIAL, CSB_CODREV, CSB_DTLANC, CSB_NUMLOT   "+CRLF
	cQuery += "   SELECT @nCFuCsa = isnull(sum(CSB_FUPART),0) FROM "+RetSqlName("CSB")+" WHERE CSB_FILIAL = '"+ xFilial("CSB") +"' and D_E_L_E_T_=' '  AND CSB_INDDC='C' AND CSB_DTLANC = @IN_DATA AND CSB_CODREV = @IN_CODREV  GROUP BY CSB_FILIAL, CSB_CODREV, CSB_DTLANC, CSB_NUMLOT   "+CRLF
	
	cQuery += "   SELECT @nDAdCsa = isnull(sum(CSB_ADPART),0) FROM "+RetSqlName("CSB")+" WHERE CSB_FILIAL = '"+ xFilial("CSB") +"' and D_E_L_E_T_=' '  AND CSB_INDDC='D' AND CSB_DTLANC = @IN_DATA AND CSB_CODREV = @IN_CODREV  GROUP BY CSB_FILIAL, CSB_CODREV, CSB_DTLANC, CSB_NUMLOT   "+CRLF
	cQuery += "   SELECT @nCAdCsa = isnull(sum(CSB_ADPART),0) FROM "+RetSqlName("CSB")+" WHERE CSB_FILIAL = '"+ xFilial("CSB") +"' and D_E_L_E_T_=' '  AND CSB_INDDC='C' AND CSB_DTLANC = @IN_DATA AND CSB_CODREV = @IN_CODREV  GROUP BY CSB_FILIAL, CSB_CODREV, CSB_DTLANC, CSB_NUMLOT   "+CRLF
	
	cQuery += "				If @nDebCsa != 0 begin"+CRLF
	cQuery += "       			UpDate "+RetSqlName("CSA")+CRLF
	cQuery += "             			Set CSA_VLLCTO = Round( @nDebCsa, 2 ), CSA_VLLFUN= Round( @nDFuCsa, 2 ), CSA_ADDVLL= Round( @nDAdCsa, 2 )"+CRLF
	cQuery += "          		   	Where CSA_FILIAL = '"+ xFilial("CSA") +"' AND CSA_CODREV= @IN_CODREV AND  CSA_DTLANC = @IN_DATA AND CSA_NUMLOT = @IN_CHAVE "+CRLF
	cQuery += "         		End else begin"+CRLF
	cQuery += "       			UpDate "+RetSqlName("CSA")+CRLF
	cQuery += "             			Set CSA_VLLCTO = Round( @nCreCsa, 2 ), CSA_VLLFUN= Round( @nCFuCsa, 2 ), CSA_ADDVLL= Round( @nCAdCsa, 2 )"+CRLF
	cQuery += "          		   	Where CSA_FILIAL = '"+ xFilial("CSA") +"' AND CSA_CODREV= @IN_CODREV AND  CSA_DTLANC = @IN_DATA AND CSA_NUMLOT = @IN_CHAVE "+CRLF
	cQuery += "         		End"+CRLF

Endif 


cQuery += "   SELECT @OUT_RECNO = @iRecno "+CRLF
   
cQuery += "End"+CRLF

cQuery := CtbAjustaP(.T., cQuery, @nPTratRec)
cQuery := MsParse(cQuery,If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
cQuery := CtbAjustaP(.F., cQuery, nPTratRec)

If !TCSPExist( cProc )
	nRet := TcSqlExec(cQuery)
	If nRet != 0 
		If !__lBlind
			MsgAlert(STR0062+cProc)//'Erro na criacao da procedure de geracao do CSB '
			lRet:= .F.
		EndIf
	EndIf
EndIf

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCt11PopCSBบAutor  ณEquipe CTB          บ Data ณ   17/10/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Cria procedure de gravacao de movimentos na tabela CSL    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SPED Contabil                                              บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParmetrosณ ExpC1 = Nome da procedure a ser criada                     ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ */

Function Ct11PopCSL(cProc,aProc, cCodPla,cVerPla)
Local aArea  := GetArea()
Local lRet   := .T.
Local cQuery := ""
Local nPTratRec := 0

Default cCodPla := " "
Default cVerPla := " "

cQuery := "Create Procedure "+cProc+CRLF
cQuery += "("+CRLF
cQuery += "   @IN_FILIAL  Char( "+StrZero(TamSx3( 'CSL_FILIAL' )[1], 3)+" ),"+CRLF
cQuery += "   @IN_CODREV  Char( "+StrZero(TamSx3( 'CSL_CODREV' )[1], 3)+" ),"+CRLF
cQuery += "   @IN_CHAVE   Char( "+StrZero(TamSx3('CSL_NUMLOT' )[1], 3)+" ),"+CRLF
cQuery += "   @IN_LINHA   Char( "+StrZero(TamSx3('CSL_LINHA' )[1], 3)+" ),"+CRLF
cQuery += "   @IN_DEBITO  Char( "+StrZero(TamSx3('CSL_CODCTA' )[1], 3)+" ),"+CRLF
cQuery += "   @IN_CCD     Char( "+StrZero(TamSx3('CSL_CCUSTO' )[1], 3)+" ),"+CRLF
cQuery += "   @IN_DC      Char( 01 ),"+CRLF
cQuery += "   @IN_VALOR   Float,"+CRLF
If  !type("lMoedfun")=="U" .And. lMoedfun .and. lLeiaute4
	cQuery += "   @IN_FUVALOR   Float,"+CRLF
	cQuery += "   @IN_ADVALOR   Float,"+CRLF	
	cQuery += "   @IN_TAXA   Float,"+CRLF
	
Endif 
cQuery += "   @IN_DATA    Char( 08 ), "+CRLF
cQuery += "   @IN_LCUSTO  Char( 01 ), "+CRLF
cQuery += "   @IN_ENTREF  Char( 02 ), "+CRLF
cQuery += "   @IN_NUMARQ  Char( "+StrZero(TamSx3('CSL_NUMARQ' )[1], 3)+" ),"+CRLF
cQuery += "   @OUT_RECNO  Integer OUTPUT "+CRLF
cQuery += " )"+CRLF

/* ------------------------------------------------------------------------------------
    Versใo          - <v>  Protheus P.10 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  SPEDCTBA.PRW </s>
    Descricao       - <d>  SPED SigaCTB </d>
    Procedure       -      Grava CSA
    Funcao do Siga  -      
    Entrada         - <ri> @IN_FILIAL - filial a gravar
                           @IN_CODREV - Codigo da Revisao
                           @IN_NUMLOT - Numero do Lote
                           @IN_DTLANC - Data do Lancto
                           @IN_VLLCTO - Valro do Lancto
                           @IN_DATA   - Data do Lancto <ri/>
    Saida           - <o>  </ro>
    Responsavel :     <r>  	</r>
    Data        :     01/03/2010
   -------------------------------------------------------------------------------------- */
cQuery += "as"+CRLF
cQuery += "Declare @iRecno      integer"+CRLF
cQuery += "Declare @nVlLcto     Float"+CRLF
If  !type("lMoedfun")=="U" .And. lMoedfun .and. lLeiaute4
	cQuery += "Declare @nFUVlLcto     Float"+CRLF
	cQuery += "Declare @nADVlLcto     Float"+CRLF
Endif 

cQuery += "Declare @cCusto      Char( "+StrZero(TamSx3('CSB_CCUSTO' )[1], 3)+" )"+CRLF

cQuery += "Declare @cFilial_CVD char( " + StrZero(TamSx3('CVD_FILIAL')[1], 3)+" ) "+CRLF
cQuery += "Declare @cFilial_CSL char( " + StrZero(TamSx3('CSL_FILIAL')[1], 3)+" ) "+CRLF
cQuery += "Declare @cCVD_CONTA varchar( " + StrZero(TamSx3('CVD_CONTA' )[1], 3)+" ) "+CRLF
cQuery += "Declare @cCVD_CTAREF varchar( " + StrZero(TamSx3('CVD_CTAREF' )[1], 3)+" ) "+CRLF
cQuery += "Declare @cCVD_ENTREF char( " + StrZero(TamSx3('CVD_ENTREF' )[1], 3)+" ) "+CRLF
cQuery += "Declare @cCVD_CUSTO char( " + StrZero(TamSx3('CVD_CUSTO' )[1], 3)+" ) "+CRLF
cQuery += "Declare @cAux        Char( 03 )"+CRLF
cQuery += "Declare @NCONT       Integer"+CRLF

cQuery += ""+CRLF
cQuery += "begin"+CRLF

// chama a procedure da xfilial
cQuery += "   select @cAux = 'CVD'"+CRLF
cQuery += "   Exec "+aProc[2]+ " @cAux, @IN_FILIAL, @cFilial_CVD OutPut"+CRLF
cQuery += "   select @cAux = 'CSL'"+CRLF
cQuery += "   Exec "+aProc[2]+ " @cAux, @IN_FILIAL, @cFilial_CSL OutPut"+CRLF

cQuery += "   select @OUT_RECNO = 0"+CRLF
cQuery += "   select @cCusto = @IN_CCD"+CRLF
cQuery += "   select @cCVD_CONTA = ' '"+CRLF
cQuery += "   select @cCVD_ENTREF = ' '"+CRLF
cQuery += "   select @cCVD_CTAREF = ' '"+CRLF
cQuery += "   select @cCVD_CUSTO = ' '"+CRLF
cQuery += "   If @IN_LCUSTO = '0' select @cCusto = ' '"+CRLF
cQuery += "   select @nVlLcto = Round( @IN_VALOR, 2 )"+CRLF

If  !type("lMoedfun")=="U" .And. lMoedfun .and. lLeiaute4
	cQuery += "   select @nFUVlLcto = Round( @IN_FUVALOR, 2 )"+CRLF
	cQuery += "   select @nADVlLcto = Round( @IN_ADVALOR, 2 )"+CRLF
Endif 

cQuery += "		Declare cursor_CVD insensitive cursor for"+CRLF
cQuery += "			Select CVD_CONTA, CVD_ENTREF, CVD_CTAREF, CVD_CUSTO"+CRLF
cQuery += "           From " + RetSqlName("CVD") +CRLF
cQuery += "          Where CVD_FILIAL = @cFilial_CVD"+CRLF
cQuery += "            and CVD_ENTREF = @IN_ENTREF"+CRLF
If !Empty(cCodPla)
	cQuery += "            and CVD_CODPLA = '" + cCodPla + "'" 
	cQuery += "            and CVD_VERSAO = '" + cVerPla + "'" 
EndIf
cQuery += "            and CVD_CONTA  = @IN_DEBITO"+CRLF
cQuery += "            and CVD_CUSTO  = @cCusto"+CRLF
cQuery += "            and D_E_L_E_T_ = ' '"+CRLF
cQuery += "			   for read only"+CRLF

cQuery += "  "+CRLF
cQuery += "		OPEN cursor_CVD"+CRLF
cQuery += "		Fetch cursor_CVD into @cCVD_CONTA, @cCVD_ENTREF, @cCVD_CTAREF, @cCVD_CUSTO"+CRLF
cQuery += "  "+CRLF
cQuery += "		While ( @@Fetch_Status = 0) begin"+CRLF

cQuery += "   		select @iRecno = IsNull(Max( R_E_C_N_O_ ), 0 ) from "+RetSqlName('CSL') +CRLF
cQuery += "   		select @iRecno = @iRecno + 1"+CRLF
cQuery += "   		If Round( @nVlLcto , 2 ) != 0.00  begin" + CRLF
cQuery += "			##TRATARECNO @iRecno\"+CRLF
If  !type("lMoedfun")=="U" .And. lMoedfun .and. lLeiaute4
	cQuery += "   select @nFUVlLcto = Round( @IN_FUVALOR, 2 )"+CRLF
	cQuery += "   select @nADVlLcto = Round( @IN_ADVALOR, 2 )"+CRLF
	
	cQuery += "   		Insert into "+RetSqlName('CSL')+" ( CSL_FILIAL, CSL_CODREV, CSL_NUMLOT, CSL_LINHA,  CSL_CODCTA, CSL_CCUSTO, CSL_INDDC," + CRLF
	cQuery += "     		                   				CSL_VLPART,CSL_FUPART,CSL_ADPART,CSL_TAXA, CSL_DTLANC, CSL_CTAREF, CSL_NUMARQ, R_E_C_N_O_ )" + CRLF
	cQuery += "         					       values( @cFilial_CSL, @IN_CODREV, @IN_CHAVE,  @IN_LINHA,  @IN_DEBITO, @cCusto,    @IN_DC," + CRLF
	cQuery += "             	           					@nVlLcto,@nFUVlLcto,@nADVlLcto,@IN_TAXA, @IN_DATA, @cCVD_CTAREF, @IN_NUMARQ, @iRecno )"+CRLF
	cQuery += "   		##FIMTRATARECNO"+CRLF
	cQuery += "			End"+CRLF

Else
	cQuery += "   		Insert into "+RetSqlName('CSL')+" ( CSL_FILIAL, CSL_CODREV, CSL_NUMLOT, CSL_LINHA,  CSL_CODCTA, CSL_CCUSTO, CSL_INDDC," + CRLF
	cQuery += "     		                   				CSL_VLPART, CSL_DTLANC, CSL_CTAREF, CSL_NUMARQ, R_E_C_N_O_ )" + CRLF
	cQuery += "         					       values( @cFilial_CSL, @IN_CODREV, @IN_CHAVE,  @IN_LINHA,  @IN_DEBITO, @cCusto,    @IN_DC," + CRLF
	cQuery += "             	           					@nVlLcto, @IN_DATA, @cCVD_CTAREF, @IN_NUMARQ, @iRecno )"+CRLF
	cQuery += "   		##FIMTRATARECNO"+CRLF
	cQuery += "			End"+CRLF
Endif 

cQuery += "	    Fetch cursor_CVD into @cCVD_CONTA, @cCVD_ENTREF, @cCVD_CTAREF, @cCVD_CUSTO"+CRLF

cQuery += "   End"+CRLF

cQuery += "	  Close cursor_CVD"+CRLF
cQuery += "	  Deallocate cursor_CVD"+CRLF

cQuery += "   SELECT @OUT_RECNO = @iRecno "+CRLF

   
cQuery += "End"+CRLF

cQuery := CtbAjustaP(.T., cQuery, @nPTratRec)
cQuery := MsParse(cQuery,If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
cQuery := CtbAjustaP(.F., cQuery, nPTratRec)

If !TCSPExist( cProc )
	nRet := TcSqlExec(cQuery)
	If nRet != 0 
		If !__lBlind
			MsgAlert(STR0063+cProc)//'Erro na criacao da procedure de geracao do CSL '
			lRet:= .F.
		EndIf
	EndIf
EndIf

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCt11ProcPaบAutor  ณEquipe CTB          บ Data ณ   24/03/10  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Cria procedure de gravacao de movimentos no CSB           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SPED Contabil                                              บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParmetrosณ ExpC1 = Nome da procedure a ser criada                     ณฑฑ
ฑฑณ          ณ ExpA1 = Array com todas as procedures criadas              ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ */

Function Ct11ProcPa(cProc, aProc, aFils, aTpSald, cModEsc)
Local aArea  := GetArea()
Local lRet   := .T.
Local cQuery := ""
Local nPTratRec := 0
Local iX     := 0
Local cFils  := ""  
Local lExclusivo := IIF(FindFunction("ADMTabExc"), ADMTabExc("CT2") , !Empty(xFilial("CT2") ))
Local nX
Local lProcDoc	:= GetNewPar("MV_CTBSDOC" , .F.)

/* -----------------------------------------------------------------------------------------
	NAO mudar a ordem de criacao das procedures
   aProc[7] -> CTB201 - GERA MOV................................................... aProc[5]
   aProc[1] ->    +--> ECDCHVMOV - Ponto de entrada que altera a chave............. aProc[1]
   aProc[2] ->    +--> Ct11Filial.................................................. aProc[2]
   aProc[3] ->    +--> CTB202 - GetDtp()-Verifica se tem apuracao nessa Data....... aProc[2]
   aProc[4] ->    +--> CTB203 - Grava CSA.......................................... aProc[3]
   aProc[5] ->            +--> CTB205 - Grava CSL.................................. aProc[4]
   aProc[6] ->    +--> CTB204 - Grava CSB.......................................... aProc[4]
   ----------------------------------------------------------------------------------------- */
cQuery := "Create Procedure "+cProc+CRLF
cQuery += "("+CRLF
cQuery += "   @IN_EMP       Char( "+StrZero(TamSx3('CT2_EMPORI' )[1], 3)+" ),"+CRLF
cQuery += "   @IN_FILIAL    Char( "+StrZero(TamSx3('CT2_FILIAL' )[1], 3)+" ),"+CRLF
cQuery += "   @IN_DATAI     Char( 08 ),"+CRLF
cQuery += "   @IN_DATAF     Char( 08 ),"+CRLF
cQuery += "   @IN_MOEDA     Char( "+StrZero(TamSx3('CT2_MOEDLC' )[1], 3)+" ),"+CRLF
cQuery += "   @IN_TPSALD    Char( "+StrZero(TamSx3('CT2_TPSALD' )[1], 3)+" ),"+CRLF
cQuery += "   @IN_CONTAI    Char( "+StrZero(TamSx3('CT1_CONTA' )[1], 3)+" ),"+CRLF
cQuery += "   @IN_CONTAF    Char( "+StrZero(TamSx3('CT1_CONTA' )[1], 3)+" ),"+CRLF
cQuery += "   @IN_CODREV    Char( "+StrZero(TamSx3('CSA_CODREV' )[1], 3)+" ),"+CRLF
cQuery += "   @IN_PRODCUSTO Char( 01 ),"+CRLF
cQuery += "   @IN_ENTREF    Char( 02 ),"+CRLF
cQuery += "   @IN_TPLIVRO   Char( 01 ),"+CRLF
cQuery += "   @OUT_RESULT   Char( 01 ) OutPut"+CRLF
cQuery += ")"+CRLF
cQuery += "as"+CRLF
/* ------------------------------------------------------------------------------------
    Versใo          - <v>  Protheus 9.12 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBS011.PRW </s>
    Descricao       - <d>  SPED SigaCTB </d>
    Funcao do Siga  -      ProcMov()
    Entrada         - <ri> @IN_EMP     - Empresa Corrente
                           @IN_FILIAL  - Filial Corrente
                           @IN_DATAI   - Data Inicial
                           @IN_DATAF   - Data Final
                           @IN_MOEDA   - Moeda escolhida
                           @IN_TPSALD  - Tipo de Saldo a gerar movimento
                           @IN_CONTAI  - Conta Inicial do Range
                           @IN_CONTAF  - Conta Final do Range
                           @IN_CODREV  - Codigo da revisao
                           @IN_PROCUSTO - Se '1', gravo CT2_CCD, se '0' gravo ' '
                           @IN_LCUSTO   - Se '1, gravo o CCusto, '0' nao gravo CCusto <ri/>
                           @IN_TPLIVRO  - Tipo de Livro                           
    Saida           - <o>  @OUT_RESULT - Indica o termino OK da procedure </ro>
    Responsavel :     <r> totvs  	</r>
    Data        :     26/02/2010

   CTB201 - GERA MOV
      +--> ECDCHVMOV - Ponto de entrada que altera a chave
      +--> CTB202 - GetDtp()- SPEDCTBA - Verifica se tem apuracao nessa Data
      +--> CTB203 - Grava CSA
      +--> CTB204 - Grava CSB
              +--> CTB205 - GravaCSL
   -------------------------------------------------------------------------------------- */

cQuery += "Declare @cFilial_CT2 Char( "+StrZero(TamSx3('CT2_FILIAL' )[1], 3)+" )"+CRLF
cQuery += "Declare @cFilial_CTC Char( "+StrZero(TamSx3('CTC_FILIAL' )[1], 3)+" )"+CRLF
cQuery += "Declare @cFilial_CT8 Char( "+StrZero(TamSx3('CT8_FILIAL' )[1], 3)+" )"+CRLF
cQuery += "Declare @cFilial_CSA Char( "+StrZero(TamSx3('CSA_FILIAL' )[1], 3)+" )"+CRLF
cQuery += "Declare @cFilial_CSB Char( "+StrZero(TamSx3('CSB_FILIAL' )[1], 3)+" )"+CRLF
cQuery += "Declare @cAux        Char( 03 )"+CRLF
cQuery += "Declare @cCT2_FILIAL Char( "+StrZero(TamSx3('CT2_FILIAL' )[1], 3)+" )"+CRLF
cQuery += "Declare @cCT2_DATA   Char( "+StrZero(TamSx3('CT2_DATA' )[1], 3)+" )"+CRLF
cQuery += "Declare @cCT2_LOTE   Char( "+StrZero(TamSx3('CT2_LOTE' )[1], 3)+" )"+CRLF
cQuery += "Declare @cCT2_SBLOTE Char( "+StrZero(TamSx3('CT2_SBLOTE' )[1], 3)+" )"+CRLF
cQuery += "Declare @cCT2_DOC    Char( "+StrZero(TamSx3('CT2_DOC' )[1], 3)+" )"+CRLF
cQuery += "Declare @cCT2_SEQLAN Char( "+StrZero(TamSx3('CT2_SEQLAN' )[1], 3)+" )"+CRLF
cQuery += "Declare @cCT2_EMPORI Char( "+StrZero(TamSx3('CT2_EMPORI' )[1], 3)+" )"+CRLF
cQuery += "Declare @cCT2_FILORI Char( "+StrZero(TamSx3('CT2_FILORI' )[1], 3)+" )"+CRLF
cQuery += "Declare @cCT2_MOEDLC Char( "+StrZero(TamSx3('CT2_MOEDLC' )[1], 3)+" )"+CRLF
cQuery += "Declare @cCT2_SEQHIS Char( "+StrZero(TamSx3('CT2_SEQIDX' )[1], 3)+" )"+CRLF
cQuery += "Declare @cCT2_LINHA  Char( "+StrZero(TamSx3('CT2_LINHA' )[1], 3)+" )"+CRLF
cQuery += "Declare @cCT2_DC     Char( "+StrZero(TamSx3('CT2_DC' )[1], 3)+" )"+CRLF
cQuery += "Declare @cCT2_DEBITO Char( "+StrZero(TamSx3('CT2_DEBITO' )[1], 3)+" )"+CRLF
cQuery += "Declare @cCT2_CREDIT Char( "+StrZero(TamSx3('CT2_CREDIT' )[1], 3)+" )"+CRLF
cQuery += "Declare @cCT2_HP     Char( "+StrZero(TamSx3('CT2_HP' )[1], 3)+" )"+CRLF
cQuery += "Declare @cCT2_HIST   Char( "+StrZero(TamSx3('CT2_HIST' )[1], 3)+" )"+CRLF
cQuery += "Declare @cCT2_CCD    Char( "+StrZero(TamSx3('CT2_CCD' )[1], 3)+" )"+CRLF
cQuery += "Declare @cCT2_CCC    Char( "+StrZero(TamSx3('CT2_CCC' )[1], 3)+" )"+CRLF
cQuery += "Declare @cCT2_DTLP   Char( "+StrZero(TamSx3('CT2_DTLP' )[1], 3)+" )"+CRLF
cQuery += "Declare @cCT2_TPSALD Char( "+StrZero(TamSx3('CT2_TPSALD' )[1], 3)+" )"+CRLF
cQuery += "Declare @nCT2_VALOR  Float"+CRLF
cQuery += "Declare @nCT2_VLCSA  Float"+CRLF
cQuery += "Declare @cCT2_CODPAR Char( "+StrZero(TamSx3('CT2_CODPAR' )[1], 3)+" )"+CRLF
cQuery += "Declare @cChave      VarChar( "+StrZero(TamSx3('CSA_NUMLOT' )[1], 3)+" )"+CRLF
cQuery += "Declare @cChaveAux   VarChar( "+StrZero(TamSx3('CSA_NUMLOT' )[1], 3)+" )"+CRLF
cQuery += "Declare @cCSB_NUMARQ Varchar( "+StrZero(TamSx3('CSB_NUMARQ' )[1], 3)+" )"+CRLF
cQuery += "Declare @cDc         Char( 01 )"+CRLF
cQuery += "Declare @cCSA_INDTIP Char( "+StrZero(TamSx3('CSA_INDTIP' )[1], 3)+" )"+CRLF
cQuery += "Declare @cRet        Char( 01 )"+CRLF
cQuery += "Declare @cCT8_IDENT  Char( "+StrZero(TamSx3('CT8_IDENT' )[1], 3)+" )"+CRLF
cQuery += "Declare @cExtHIST    Varchar( "+StrZero(TamSx3('CT2_HIST')[1], 3)+" )"+CRLF
cQuery += "Declare @nLenHist    Integer"+CRLF
cQuery += "Declare @iNroRegs1   Integer"+CRLF
cQuery += "Declare @iTranCount  Integer"+CRLF   // --Var.de ajuste para SQLServer e Sybase.
cQuery += "declare @iRecno      Integer"+CRLF
cQuery += "declare @iRecnoD     Integer"+CRLF
cQuery += "declare @iRecnoC     Integer"+CRLF
cQuery += "Declare @iRecnoCSA   Integer"+CRLF
cQuery += "Declare @NCONT       Integer"+CRLF

cQuery += "Declare @iFoundCSQ   integer"+CRLF
cQuery += "Declare @cCSQ_DTEXT  Char( "+StrZero(8, 3)+" )"+CRLF

cQuery += "begin"+CRLF
cQuery += "   select @NCONT= 0"+CRLF
cQuery += "   select @cAux = 'CT2'"+CRLF
cQuery += "   Exec "+aProc[2]+ " @cAux, @IN_FILIAL, @cFilial_CT2 OutPut"+CRLF
cQuery += "   select @cAux = 'CTC'"+CRLF
cQuery += "   Exec "+aProc[2]+ " @cAux, @IN_FILIAL, @cFilial_CTC OutPut"+CRLF
   
cQuery += "   select @cChave = ''"+CRLF
cQuery += "   select @cChaveAux = ''"+CRLF
cQuery += "   select @cCSB_NUMARQ = ''"+CRLF
cQuery += "   select @iRecno = 0"+CRLF
cQuery += "   select @iRecnoD = 0"+CRLF
cQuery += "   select @iRecnoC = 0"+CRLF
cQuery += "   select @iRecnoCSA = 0"+CRLF
cQuery += "   select @iNroRegs1 = 0"+CRLF
cQuery += "   select @OUT_RESULT = '0'"+CRLF
cQuery += "   select @cDc = ''"+CRLF
cQuery += "   select @cCSA_INDTIP = ''"+CRLF
cQuery += "   select @cRet        = '0'"+CRLF
cQuery += "   select @cCT8_IDENT  = ' '"+CRLF
cQuery += "   select @iFoundCSQ   = 0 "+CRLF

cQuery += "   Declare CUR_PROCMOV insensitive cursor for"+CRLF
cQuery += "      Select CT2_FILIAL, CT2_DATA,   CT2_LOTE,  CT2_SBLOTE, CT2_DOC,    CT2_SEQLAN, CT2_EMPORI, CT2_FILORI, "+CRLF
cQuery += "             CT2_MOEDLC, CT2_SEQHIS, CT2_LINHA, CT2_DC,     CT2_DEBITO, CT2_CREDIT, CT2_HP,     CT2_HIST,"+CRLF
cQuery += "             CT2_CCD,    CT2_CCC,    CT2_DTLP,  CT2_TPSALD, CT2_VALOR,  CT2_CODPAR"+CRLF
cQuery += "        From "+RetSqlName("CTC")+" T1, "+RetSqlName("CT2")+" T2"+CRLF
cQuery += "       Where T1.CTC_DATA between @IN_DATAI and @IN_DATAF"+CRLF
cQuery += "         and T1.CTC_MOEDA  = @IN_MOEDA"+CRLF

If Len(aTpSald) > 0
	cQuery += "         and T1.CTC_TPSALD IN ("
	For nX := 1 TO Len(aTpSald)
		cQuery += "'"+aTpSald[nX]+"'"
		If nX < Len(aTpSald)
			cQuery += ","
		Else
			cQuery += ")"
		EndIf
	Next		
Else
	cQuery += "         and T1.CTC_TPSALD = @IN_TPSALD"+CRLF
EndIf
cQuery += "         and T1.D_E_L_E_T_ = ' '"+CRLF

If lExclusivo
	cQuery += "         and T2.CT2_FILIAL IN ( "
	For iX := 1 To Len(aFils)
		If aFils[ix][1]
			cFils += "'"+xFilial("CT2",aFils[ix][3])+"',"
		EndIf
	Next
	cQuery += SubString(cFils, 1 , Len(cFils) -1)+" )"+CRLF
Else
	cQuery += "         and T2.CT2_FILIAL = '"+xFilial("CT2")+"' " +CRLF
EndIf
cQuery += "         and T1.CTC_FILIAL = T2.CT2_FILIAL"+CRLF
cQuery += "         and T2.CT2_DATA   = T1.CTC_DATA"+CRLF
cQuery += "         and T2.CT2_LOTE   = T1.CTC_LOTE"+CRLF
cQuery += "         and T2.CT2_SBLOTE = T1.CTC_SBLOTE"+CRLF
cQuery += "         and T2.CT2_DOC    = T1.CTC_DOC"+CRLF
cQuery += "         and T2.CT2_MOEDLC = T1.CTC_MOEDA"+CRLF
cQuery += "         and T2.CT2_TPSALD = T1.CTC_TPSALD"+CRLF
cQuery += "         and ((( T2.CT2_DEBITO between @IN_CONTAI and @IN_CONTAF) or"+CRLF
cQuery += "               ( T2.CT2_CREDIT between @IN_CONTAI and @IN_CONTAF)) OR T2.CT2_DC = '4')"+CRLF
cQuery += "         and T2.D_E_L_E_T_ = ' '"+CRLF
cQuery += "   order by 1, 2, 3, 4, 5, 6, 7, 8, 9, 10"+CRLF
cQuery += "   for read only"+CRLF
cQuery += "   Open CUR_PROCMOV"+CRLF
cQuery += "   Fetch CUR_PROCMOV into @cCT2_FILIAL, @cCT2_DATA,   @cCT2_LOTE,  @cCT2_SBLOTE, @cCT2_DOC,    @cCT2_SEQLAN, @cCT2_EMPORI, @cCT2_FILORI, "+CRLF
cQuery += "                          @cCT2_MOEDLC, @cCT2_SEQHIS, @cCT2_LINHA, @cCT2_DC,     @cCT2_DEBITO, @cCT2_CREDIT, @cCT2_HP,     @cCT2_HIST,"+CRLF
cQuery += "                          @cCT2_CCD,    @cCT2_CCC,    @cCT2_DTLP,  @cCT2_TPSALD, @nCT2_VALOR,  @cCT2_CODPAR"+CRLF
cQuery += CRLF
cQuery += "   While ( @@fetch_status = 0 ) begin"+CRLF
cQuery += "  "+CRLF

cQuery += "   select @iFoundCSQ = 0 "+CRLF
cQuery += "   select @cCSQ_DTEXT = ' ' "+CRLF

// chama a procedure xfilial
cQuery += "   select @cAux = 'CT8'"+CRLF
cQuery += "   Exec "+aProc[2]+ " @cAux, @IN_FILIAL, @cFilial_CT8 OutPut"+CRLF
cQuery += "   select @cAux = 'CSA'"+CRLF
cQuery += "   Exec "+aProc[2]+ " @cAux, @IN_FILIAL, @cFilial_CSA OutPut"+CRLF
cQuery += "   select @cAux = 'CSB'"+CRLF
cQuery += "   Exec "+aProc[2]+ " @cAux, @IN_FILIAL, @cFilial_CSB OutPut"+CRLF

cQuery += "      select @iNroRegs1 = @iNroRegs1 + 1"+CRLF

If cModEsc == "FCO"
	cQuery += "      Select @cChave = @cCT2_FILIAL||@cCT2_DATA||@cCT2_LOTE||@cCT2_SBLOTE||@cCT2_TPSALD"+CRLF
Else
	cQuery += "      If @cCT2_DTLP != ' ' begin"+CRLF
	cQuery += "      	Select @cChave = @cCT2_FILIAL||@cCT2_DATA||@cCT2_LOTE||@cCT2_SBLOTE||'APURACAO'"+CRLF
	cQuery += "      End else begin" +CRLF
	If lProcDoc
		cQuery += "      	Select @cChave = @cCT2_FILIAL||@cCT2_DATA||@cCT2_LOTE||@cCT2_SBLOTE||@cCT2_DOC"+CRLF
	Else
		cQuery += "      	Select @cChave = @cCT2_FILIAL||@cCT2_DATA||@cCT2_LOTE||@cCT2_SBLOTE"+CRLF
	Endif
	cQuery += "      End"+CRLF
Endif

cQuery += CRLF

// chama a procedure do ponto de entrada
cQuery += "      Exec "+aProc[1]+ " @cChave, @cChaveAux OutPut"+CRLF

cQuery += "  "+CRLF
cQuery += "      If @cChaveAux != ' ' select @cChave = @cChaveAux"+CRLF
cQuery += "      If @cCT2_TPSALD = @IN_TPSALD select @cCSA_INDTIP = 'N'"+CRLF

If cModEsc == "FCO"
 	For nX := 2 TO Len(__ECDIndTip)
 		If !Empty(__ECDIndTip[nX, 2])
			cQuery += "      If @cCT2_TPSALD = '"+__ECDIndTip[nX, 2]+"' select @cCSA_INDTIP = '"+__ECDIndTip[nX, 1]+"'"+CRLF
		EndIf
	Next		
EndIf         

cQuery += CRLF

//chama a procedure da marca็ใo do tipo de lan็amento INDTIP
cQuery += "      select @cRet = '0'"+CRLF

cQuery += "      If @cCT2_DTLP != ' ' begin"+CRLF
cQuery += CRLF
cQuery += "         Exec "+aProc[3]+"  @IN_EMP, @IN_FILIAL, @cCT2_DATA, @cCT2_MOEDLC, @cCT2_TPSALD, @cRet OutPut"+CRLF
cQuery += CRLF
cQuery += "         If @cRet = '1' begin " +CRLF
cQuery += "             select @cCSA_INDTIP = 'E'"+CRLF
cQuery += "      		end "+CRLF

cQuery += "      end "+CRLF

If __lExistCSQ  //se existe a tabela CSQ leiaute 7
	cQuery += "      If @cRet = '0' begin"+CRLF
	                        //consultar tabela CSQ
	cQuery += "             select @iFoundCSQ = IsNull(Max( R_E_C_N_O_ ), 0 ), @cCSQ_DTEXT = IsNull(CSQ_DTEXT, ' ')  from "+RetSqlName("CSQ")+CRLF
	cQuery += "              where CSQ_FILIAL = @cCT2_FILIAL "+CRLF
	cQuery += "                and CSQ_DATA = @cCT2_DATA "		+CRLF
	cQuery += "                and CSQ_LOTE = @cCT2_LOTE "		+CRLF
	cQuery += "                and CSQ_SBLOTE = @cCT2_SBLOTE "+CRLF
	cQuery += "                and CSQ_DOC = @cCT2_DOC "		  +CRLF
	cQuery += "                and CSQ_LINHA = @cCT2_LINHA "	+CRLF
	cQuery += "                and CSQ_EMPORI = @cCT2_EMPORI "+CRLF
	cQuery += "                and CSQ_FILORI = @cCT2_FILORI "+CRLF
	cQuery += "                and D_E_L_E_T_ = ' ' "+CRLF
	cQuery += "             group by R_E_C_N_O_ , CSQ_DTEXT "+CRLF
	cQuery += "      end"+CRLF

	cQuery += "      If @iFoundCSQ != 0 select @cCSA_INDTIP = 'X'"+CRLF

EndIf

cQuery += "      If @iNroRegs1 = 1 begin"+CRLF
cQuery += "         begin tran"+CRLF
cQuery += "         select @iNroRegs1 = @iNroRegs1"+CRLF
cQuery += "      End"+CRLF
      
cQuery += "      If ( Round(@nCT2_VALOR,2 ) != 0.00) and ( @cCT2_DC = '1' or @cCT2_DC = '2' or @cCT2_DC = '3') begin"+CRLF

cQuery += "         select @iRecnoCSA = 0"+CRLF
cQuery += "         Select @iRecnoCSA = IsNull( MIN(R_E_C_N_O_), 0 )"+CRLF
cQuery += "           From "+REtSqlName("CSA")+CRLF
cQuery += "          Where CSA_FILIAL = @cFilial_CSA"+CRLF
cQuery += "            and CSA_CODREV = @IN_CODREV"+CRLF
cQuery += "            and CSA_DTLANC = @cCT2_DATA"+CRLF
cQuery += "            and CSA_NUMLOT = @cChave"+CRLF   //@cCT2_FILIAL||@cCT2_DATA||@cCT2_LOTE||@cCT2_SBLOTE 
If __lExistCSQ 
		cQuery += "            and CSA_DTEXT  = @cCSQ_DTEXT"+CRLF
EndIf
If cModEsc == "FCO"
	cQuery += "            and CSA_INDTIP = @cCSA_INDTIP"+CRLF
EndIf

cQuery += "            and D_E_L_E_T_ = ' '"+CRLF

// RFC: Somente considero o valor do d้bito. O LOTE DEVE ESTAR SEMPRE BATIDO.
cQuery += "      	If ( Round(@nCT2_VALOR,2 ) != 0.00) and ( @cCT2_DC = '1' or @cCT2_DC = '3') begin"+CRLF
cQuery += "         	Select @nCT2_VLCSA = Round(@nCT2_VALOR,2 )"+CRLF
cQuery += "      	End else begin" + CRLF
cQuery += "         	Select @nCT2_VLCSA = 0"+CRLF
cQuery += "      	End"+CRLF

// chama a procedure para inclusใo da CSA
cQuery += "			If @cCSA_INDTIP != 'E'  and @IN_TPLIVRO = 'A' begin"+CRLF
cQuery += "				If @iRecnoCSA = 0  begin"+CRLF 
cQuery += "          		Exec "+aProc[4]+" @cFilial_CSA, @IN_CODREV, @cChave, @cCT2_DATA, @nCT2_VLCSA, @cCSA_INDTIP, @cCSQ_DTEXT"+CRLF
cQuery += "         	End else begin"+CRLF

cQuery += "       			UpDate "+RetSqlName("CSA")+CRLF
cQuery += "             			Set CSA_VLLCTO = CSA_VLLCTO + Round( @nCT2_VLCSA, 2 )"+CRLF
cQuery += "          		   	Where R_E_C_N_O_ = @iRecnoCSA"+CRLF
cQuery += "         	End"+CRLF
cQuery += "   		End"+CRLF

// chama a procedure para inclusใo da CSA
cQuery += "			If @IN_TPLIVRO != 'A' begin"+CRLF
cQuery += "         If @iRecnoCSA = 0  begin"+CRLF
cQuery += "            Exec "+aProc[4]+" @cFilial_CSA, @IN_CODREV, @cChave, @cCT2_DATA, @nCT2_VLCSA, @cCSA_INDTIP, @cCSQ_DTEXT"+CRLF
cQuery += "         End else begin"+CRLF
cQuery += "       	   UpDate "+RetSqlName("CSA")+CRLF
cQuery += "               Set CSA_VLLCTO = CSA_VLLCTO + Round( @nCT2_VLCSA, 2 )"+CRLF
cQuery += "          	  Where R_E_C_N_O_ = @iRecnoCSA"+CRLF
cQuery += "   		  End"+CRLF
cQuery += "   		End"+CRLF
cQuery += "		End"+CRLF
      
/* -----------------------------
| preparacao para CSB
----------------------------- */

cQuery += "      If @cCT2_DC != '4' begin"+CRLF
cQuery += "         select @iRecnoD = 0"+CRLF
cQuery += "         select @iRecnoC = 0"+CRLF
cQuery += "      End"+CRLF

      /*   grava debitos  */
cQuery += "      If (( @cCT2_DC = '1' or @cCT2_DC = '3') and ( @cCT2_DEBITO between @IN_CONTAI and @IN_CONTAF )) begin"+CRLF
cQuery += "         select @cDc = 'D'"+CRLF
If cModEsc == "FCO"
	cQuery += "         select @cCSB_NUMARQ = @cCT2_FILIAL||@cCT2_DATA||@cCT2_LOTE||@cCT2_SBLOTE||@cCT2_TPSALD||@cCT2_DOC||@cCT2_LINHA||@cCT2_SEQLAN||@cDc||@cCT2_MOEDLC||@cCT2_TPSALD||@cCT2_EMPORI||@cCT2_FILORI"+CRLF
Else
	cQuery += "         select @cCSB_NUMARQ = @cCT2_FILIAL||@cCT2_DATA||@cCT2_LOTE||@cCT2_SBLOTE||@cCT2_DOC||@cCT2_LINHA||@cCT2_SEQLAN||@cDc||@cCT2_MOEDLC||@cCT2_TPSALD||@cCT2_EMPORI||@cCT2_FILORI"+CRLF
Endif
cQuery += "   "+CRLF
cQuery += "   	If @cCT2_DTLP = ' ' and @IN_TPLIVRO = 'A' begin"+CRLF
cQuery += "       	If @IN_PRODCUSTO = '0' select @cCT2_CCD = ' '"+CRLF
cQuery += "          exec "+aProc[6]+" @IN_FILIAL, @IN_CODREV,   @cChave,      @cCT2_LINHA, @cCT2_DEBITO, @cCT2_CCD, @cDc, @cCT2_HP, @cCT2_HIST,"+CRLF
cQuery += "          	              @nCT2_VALOR, @cCSQ_DTEXT,  @cCT2_CODPAR, @cCSB_NUMARQ, @cCT2_DATA, @IN_PRODCUSTO, @IN_ENTREF, @iRecnoD OutPut "+CRLF
cQuery += "   	end"+CRLF
cQuery += "   "+CRLF
cQuery += "   	If @IN_TPLIVRO != 'A' begin "+CRLF
cQuery += "       	If @IN_PRODCUSTO = '0' select @cCT2_CCD = ' '"+CRLF
cQuery += "          exec "+aProc[6]+" @IN_FILIAL, @IN_CODREV,   @cChave,      @cCT2_LINHA, @cCT2_DEBITO, @cCT2_CCD, @cDc, @cCT2_HP, @cCT2_HIST,"+CRLF
cQuery += "                            @nCT2_VALOR, @cCSQ_DTEXT,  @cCT2_CODPAR, @cCSB_NUMARQ, @cCT2_DATA, @IN_PRODCUSTO, @IN_ENTREF, @iRecnoD OutPut "+CRLF
cQuery += "   	end"+CRLF
cQuery += "   end"+CRLF

//-----------------
// Grava CREDITOS
//----------------- 
cQuery += "      If (( @cCT2_DC = '2' or @cCT2_DC = '3') and ( @cCT2_CREDIT between @IN_CONTAI and @IN_CONTAF )) begin"+CRLF
cQuery += "         select @cDc = 'C'"+CRLF      
If cModEsc == "FCO"
	cQuery += "         select @cCSB_NUMARQ = @cCT2_FILIAL||@cCT2_DATA||@cCT2_LOTE||@cCT2_SBLOTE||@cCT2_TPSALD||@cCT2_DOC||@cCT2_LINHA||@cCT2_SEQLAN||@cDc||@cCT2_MOEDLC||@cCT2_TPSALD||@cCT2_EMPORI||@cCT2_FILORI"+CRLF
Else
	cQuery += "         select @cCSB_NUMARQ = @cCT2_FILIAL||@cCT2_DATA||@cCT2_LOTE||@cCT2_SBLOTE||@cCT2_DOC||@cCT2_LINHA||@cCT2_SEQLAN||@cDc||@cCT2_MOEDLC||@cCT2_TPSALD||@cCT2_EMPORI||@cCT2_FILORI"+CRLF
Endif
cQuery += "   "+CRLF
cQuery += "		If @cCT2_DTLP = ' '  and @IN_TPLIVRO = 'A' begin"+CRLF
cQuery += "			If @IN_PRODCUSTO = '0' select @cCT2_CCD = ' '"+CRLF
cQuery += "			exec "+aProc[6]+" @IN_FILIAL, @IN_CODREV,   @cChave,      @cCT2_LINHA, @cCT2_CREDIT, @cCT2_CCC, @cDc, @cCT2_HP, @cCT2_HIST,"+CRLF
cQuery += "         	              @nCT2_VALOR, @cCSQ_DTEXT,  @cCT2_CODPAR, @cCSB_NUMARQ, @cCT2_DATA, @IN_PRODCUSTO, @IN_ENTREF, @iRecnoC OutPut"+CRLF
cQuery += "		end"+CRLF
cQuery += "   "+CRLF

cQuery += "   	If @IN_TPLIVRO != 'A' begin"+CRLF
cQuery += "   		If @IN_PRODCUSTO = '0' select @cCT2_CCD = ' '"+CRLF
cQuery += "			exec "+aProc[6]+" @IN_FILIAL, @IN_CODREV,   @cChave,      @cCT2_LINHA, @cCT2_CREDIT, @cCT2_CCC, @cDc, @cCT2_HP, @cCT2_HIST,"+CRLF
cQuery += "      	                  @nCT2_VALOR, @cCSQ_DTEXT,  @cCT2_CODPAR, @cCSB_NUMARQ, @cCT2_DATA, @IN_PRODCUSTO, @IN_ENTREF, @iRecnoC OutPut"+CRLF
cQuery += "		end"+CRLF
cQuery += "   end"+CRLF

cQuery += "      If @cCT2_DC = '4' begin"+CRLF
cQuery += "         If @iRecnoD > 0 begin"+CRLF
           
cQuery += "            UpDate "+RetSqlName("CSB")+CRLF

If Alltrim(Upper(TcGetDb())) = 'INFORMIX'
	cQuery += "               Set CSB_HISTOR = Substring( trim(CSB_HISTOR)||' '||trim(@cCT2_HIST),1," + StrZero(TamSx3('CSB_HISTOR' )[1], 3) + ")" +CRLF
Else
	cQuery += "               Set CSB_HISTOR = Substring( Rtrim(Ltrim(CSB_HISTOR))||' '||Rtrim(ltrim(@cCT2_HIST)),1," + StrZero(TamSx3('CSB_HISTOR' )[1], 3) + ")" +CRLF
EndIf

cQuery += "             Where R_E_C_N_O_ = @iRecnoD"+CRLF
cQuery += "         End"+CRLF

cQuery += "         If @iRecnoC > 0 begin"+CRLF
           
cQuery += "            UpDate "+RetSqlName("CSB")+CRLF

If Alltrim(Upper(TcGetDb())) = 'INFORMIX'
	cQuery += "               Set CSB_HISTOR = Substring( trim(CSB_HISTOR)||' '||trim(@cCT2_HIST),1," + StrZero(TamSx3('CSB_HISTOR' )[1], 3) + ")" +CRLF
Else
	cQuery += "               Set CSB_HISTOR = Substring( Rtrim(Ltrim(CSB_HISTOR))||' '||Rtrim(ltrim(@cCT2_HIST)),1," + StrZero(TamSx3('CSB_HISTOR' )[1], 3) + ")" +CRLF
EndIf

cQuery += "             Where R_E_C_N_O_ = @iRecnoC"+CRLF
cQuery += "         End"+CRLF
cQuery += "      End"+CRLF

cQuery += "      If @iNroRegs1 >= 10000 begin"+CRLF
cQuery += "         commit tran"+CRLF
cQuery += "         select @iNroRegs1 = 0"+CRLF
cQuery += "      End"+CRLF
If Alltrim(Upper(TcGetDb())) $ 'DB2|DB2/400'
	cQuery += "      SELECT @fim_CUR = 0"+CRLF
EndIf
cQuery += "      Fetch CUR_PROCMOV into @cCT2_FILIAL, @cCT2_DATA,   @cCT2_LOTE,  @cCT2_SBLOTE, @cCT2_DOC,    @cCT2_SEQLAN, @cCT2_EMPORI, @cCT2_FILORI, "+CRLF
cQuery += "                             @cCT2_MOEDLC, @cCT2_SEQHIS, @cCT2_LINHA, @cCT2_DC,     @cCT2_DEBITO, @cCT2_CREDIT, @cCT2_HP,     @cCT2_HIST,"+CRLF
cQuery += "                             @cCT2_CCD,    @cCT2_CCC,    @cCT2_DTLP,  @cCT2_TPSALD, @nCT2_VALOR,  @cCT2_CODPAR"+CRLF
      
cQuery += "   End"+CRLF
cQuery += "   Close CUR_PROCMOV"+CRLF
cQuery += "   Deallocate CUR_PROCMOV"+CRLF
   
cQuery += "   If @iNroRegs1 > 0 begin"+CRLF
cQuery += "      commit tran"+CRLF
cQuery += "      select @iTranCount = 0"+CRLF
cQuery += "   End"+CRLF
   
cQuery += "   select @OUT_RESULT = '1'"+CRLF
cQuery += "End"+CRLF

cQuery := CtbAjustaP(.T., cQuery, @nPTratRec)
cQuery := MsParse(cQuery,If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
cQuery := CtbAjustaP(.F., cQuery, nPTratRec)

If !TCSPExist( cProc )
	nRet := TcSqlExec(cQuery)
	If nRet != 0 
		If !__lBlind
			MsgAlert(STR0064+cProc)//'Erro na criacao da procedure de Exportacao de Movimento '
			lRet:= .F.
		EndIf
	EndIf
EndIf

RestArea(aArea)
Return lRet

/* --------------------------------------------------------------------
Funcao xFilial para uso dentro do corpo das procedures dinamicas do PCO
Recebe como parametro as strings das variaveis da procedure a serem
utilizadas : Alias, Filial atual ou default, e filial de retorno
Retorna o corpo da xfilial a ser executado.
OBSERVACAO : PARA USO DA FUNCAO, DEVE SER DECLARADA A VARIAVEL @NCONT NO INICIO DA PROCEDURE
OUTRA OBSERVACAO : Deu erro no AS400 , nao sabemos por que. Reclama de passagem de valores null como parametro.
Nao achamos onde era, e trocamos pela query direta. Funciona, sem erro, e torna esse programa 
totalmente independente da aplicacao de procedures do padrao.
-------------------------------------------------------------------- */
STATIC Function Ct11Filial(cProc)
Local cQuery := ''
Local aArea  := GetArea()
Local lRet   := .T.
Local nPTratRec := 0

cQuery  := "Create procedure "+cProc+CRLF
cQuery  += "( "+CRLF
cQuery  += "  @IN_ALIAS        Char(03),"+CRLF
cQuery  += "  @IN_FILIALCOR    Char( "+StrZero(TamSx3('CT2_FILIAL' )[1], 3)+" ),"+CRLF
cQuery  += "  @OUT_FILIAL      Char( "+StrZero(TamSx3('CT2_FILIAL' )[1], 3)+" ) OutPut"+CRLF
cQuery  += ")"+CRLF
cQuery  += "as"+CRLF

/* -------------------------------------------------------------------
    Versใo      -  <v> Gen้rica </v>
    Assinatura  -  <a> 010 </a>
    Descricao   -  <d> Retorno o modo de acesso da tabela em questao </d>

    Entrada     -  <ri> @IN_ALIAS        - Tabela a ser verificada
                        @IN_FILIALCOR    - Filial corrente </ri>

    Saida       -  <ro> @OUT_FILIAL      - retorna a filial a ser utilizada </ro>
                   <o> brancos para modo compartilhado @IN_FILIALCOR para modo exclusivo </o>

    Responsavel :  <r> Alice Yaeko </r>
    Data        :  <dt> 14/12/10 </dt>
   
   X2_CHAVE X2_MODO X2_MODOUN X2_MODOEMP X2_TAMFIL X2_TAMUN X2_TAMEMP
   -------- ------- --------- ---------- --------- -------- ---------
   CT2      E       E         E          3.0       3.0        2.0       
      X2_CHAVE   - Tabela
      X2_MODO    - Comparti/o da Filial, 'E' exclusivo e 'C' compartilhado
      X2_MODOUN  - Comparti/o da Unidade de Neg๓cio, 'E' exclusivo e 'C' compartilhado
      X2_MODOEMP - Comparti/o da Empresa, 'E' exclusivo e 'C' compartilhado
      X2_TAMFIL  - Tamanho da Filial
      X2_TAMUN   - Tamanho da Unidade de Negocio
      X2_TAMEMP  - tamanho da Empresa
   
   Existe hierarquia no compartilhamento das entidades filial, uni// de negocio e empresa.
   Se a Empresa for compartilhada as demais entidades DEVEM ser compartilhadas
   Compartilhamentos e tamanhos possํveis
   compartilhaemnto         tamanho ( zero ou nao zero)
   EMP UNI FIL             EMP UNI FIL
   --- --- ---             --- --- ---
    C   C   C               0   0   X   -- 1 - somente filial
    E   C   C               0   X   X   -- 2 - filial e unidade de negocio
    E   E   C               X   0   X   -- 3 - empresa e filial
    E   E   E               X   X   X   -- 4 - empresa, unidade de negocio e filial
------------------------------------------------------------------- */
cQuery  += "Declare @cModo    Char( 01 )"+CRLF
cQuery  += "Declare @cModoUn  Char( 01 )"+CRLF
cQuery  += "Declare @cModoEmp Char( 01 )"+CRLF
cQuery  += "Declare @iTamFil  Integer"+CRLF
cQuery  += "Declare @iTamUn   Integer"+CRLF
cQuery  += "Declare @iTamEmp  Integer"+CRLF

cQuery  += "begin"+CRLF
  
cQuery  += "  Select @OUT_FILIAL = ' '"+CRLF
cQuery  += "  Select @cModo = ' ', @cModoUn = ' ', @cModoEmp = ' '"+CRLF
cQuery  += "  Select @iTamFil = 0, @iTamUn = 0, @iTamEmp = 0"+CRLF
  
cQuery  += "  Select @cModo = X2_MODO,   @cModoUn = X2_MODOUN, @cModoEmp = X2_MODOEMP,"+CRLF
cQuery  += "         @iTamFil = X2_TAMFIL, @iTamUn = X2_TAMUN, @iTamEmp = X2_TAMEMP"+CRLF
cQuery  += "    From SX2"+cEmpAnt+"0"+CRLF
cQuery  += "   Where X2_CHAVE = @IN_ALIAS"+CRLF
cQuery  += "     and D_E_L_E_T_ = ' '"+CRLF
  
  /*   SITUACAO -> 1 somente FILIAL */
cQuery  += "  If ( @iTamEmp = 0 AND @iTamUn = 0 AND @iTamFil  >= 2 ) begin"+CRLF  //   -- so tem filial tam 2 sem gestao
cQuery  += "    If @cModo = 'C' select @OUT_FILIAL = '  '"+CRLF
cQuery  += "    else select @OUT_FILIAL = @IN_FILIALCOR"+CRLF
cQuery  += "  end else begin"+CRLF
    /*  SITUACAO -> 2 UNIDADE DE NEGOCIO e FILIAL  */
cQuery  += "    If @iTamEmp = 0 begin"+CRLF
cQuery  += "      If @cModoUn = 'E' begin"+CRLF
cQuery  += "        If @cModo = 'E' select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamUn)||Substring( @IN_FILIALCOR, @iTamUn + 1, @iTamFil )"+CRLF
cQuery  += "        else select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamUn)"+CRLF
cQuery  += "      end"+CRLF
cQuery  += "    end else begin"+CRLF
      /* SITUACAO -> 4 EMPRESA, UNIDADE DE NEGOCIO e FILIAL */
cQuery  += "      If @iTamUn > 0 begin"+CRLF
cQuery  += "        If @cModoEmp = 'E' begin"+CRLF
cQuery  += "          If @cModoUn = 'E' begin"+CRLF
cQuery  += "            If @cModo = 'E' select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)||Substring(@IN_FILIALCOR, @iTamEmp+1, @iTamUn)||Substring( @IN_FILIALCOR, @iTamEmp+@iTamUn + 1, @iTamFil )"+CRLF
cQuery  += "            else select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)||Substring(@IN_FILIALCOR, @iTamEmp+1, @iTamUn)"+CRLF
cQuery  += "          end else begin"+CRLF
cQuery  += "            select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)"+CRLF
cQuery  += "          end"+CRLF
cQuery  += "        end"+CRLF
cQuery  += "      end else begin"+CRLF
        /*  SITUACAO -> 3 EMPRESA e FILIAL */
cQuery  += "        If @cModoEmp = 'E' begin"+CRLF
cQuery  += "          If @cModo = 'E' select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)||Substring( @IN_FILIALCOR, @iTamEmp+1, @iTamFil )"+CRLF
cQuery  += "          else select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)"+CRLF
cQuery  += "        end"+CRLF
cQuery  += "      end"+CRLF
cQuery  += "    end"+CRLF
cQuery  += "  end"+CRLF
cQuery  += "end"+CRLF

cQuery := CtbAjustaP(.T., cQuery, @nPTratRec)
cQuery := MsParse(cQuery,If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
cQuery := CtbAjustaP(.F., cQuery, nPTratRec)

If !TCSPExist( cProc )
	nRet := TcSqlExec(cQuery)
	If nRet != 0 
		If !__lBlind
			MsgAlert(STR0065+cProc)//'Erro na criacao da procedure Filial '
			lRet:= .F.
		EndIf
	EndIf
EndIf

RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEcdMovZera บAutor ณRenato F. Campos    บ Data ณ  04/06/09   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se a conta contabil ้ de resultado e se possui salบฑฑ
ฑฑบ          ณ do zerado antes da apura็ใo                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SpedMov                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function EcdMovZera( cFilMov, dData, cContaD, cContaC, cMoeda, cTpSald, lProcCusto, cCustoD, cCustoC )
Local lRetorno 	:= .T. 
Local lProc		:= .F.
Local aArea 	:= GetArea()
Local nIx		:= 0

For nIx := 1 TO 2
	
	IF nIx == 1
		cConta	:= cContaD
		cCusto  := cCustoD
	Else
		cConta	:= cContaC
		cCusto  := cCustoC
	EndIf

	lProc := .F.

	IF Ascan( __aCtRes, {|x| x[1] = cConta } ) == 0
		lProc := .T.
	Endif
		
	DbSelectArea( "CT1" )
	DbSetOrder(1)
	IF lProc .And. DbSeek( xFilial("CT1") + cConta  ) 
		Aadd( __aCtRes , {cConta} )

		IF CT1->CT1_NTSPED == '04' // contas de resultado
	
		    IF !lProcCusto
			    aSldAnt := SaldoCT7(cConta,dData,cMoeda,cTpSald,"CTBXFUN", .T. , dData )
			Else
				aSldAnt	:= SaldoCT3(cConta,cCusto,dData,cMoeda,cTpSald,'CTBXFUN',.T. , dData )				
			Endif
		
			IF ( ( aSldAnt[4] - aSldAnt[7] ) - ( aSldAnt[5] - aSldAnt[8] ) ) == 0 // verifica se o saldo antes da apura็ใo nใo estแ zerado
				lRetorno := .F.
				Aadd( __aCtRes , {cConta,cCusto} )
			Endif
		Endif
	Else
		If Ascan( __aCtZero, {|x| x[1] = cConta .and. x[2] = cCusto } ) == 0
			lRetorno := .F.
		Endif
	Endif
	
	IF !lRetorno
		Exit
	Endif
NEXT
	
RestArea( aArea )

RETURN lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณProcCtaRefบAutor  ณRenato F Campos     บ Data ณ   14/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Cria procedure de gravacao das contas referenciais        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SPED Contabil                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParmetrosณ ExpA1 = Array com todas as procedures criadas			  บฑฑ
ฑฑบ          ณ ExpA2 = Filiais a serem processadas			              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Function ProcCtaRef(aProc, aFils, cModEsc)
Local aArea		:= GetArea()
Local lRet		:= .T.
Local cQuery	:= ""
Local nPTratRec	:= 0
Default cModEsc := "ECD"
Default aFils	:= {}

cProc := aProc[1]

cQuery := "Create Procedure "+aProc[1]+CRLF
cQuery += "("+CRLF
cQuery += " @IN_FILIAL    Char( "+StrZero(TamSx3('CS4_FILIAL' )[1], 3)+" ),"+CRLF
cQuery += " @IN_CODREV    Char( "+StrZero(TamSx3('CS4_CODREV' )[1], 3)+" ),"+CRLF
cQuery += " @IN_LPROCCTO  Char( 01 ),"+CRLF
cQuery += " @IN_CODPLA    Char( "+StrZero(TamSx3('CVD_CODPLA' )[1], 3)+" ),"+CRLF
cQuery += " @IN_LEMPTYPLA Char( 01 ),"+CRLF
cQuery += " @IN_VERPLA    Char( "+StrZero(TamSx3('CVD_VERSAO' )[1], 3)+" ),"+CRLF
cQuery += " @OUT_RESULT   Char(01) OutPut"+CRLF

cQuery += ")"+CRLF

cQuery += "  "+CRLF

cQuery += "as "+CRLF
cQuery += "  "+CRLF
/* ------------------------------------------------------------------------------------
    Versใo          - <v>  Protheus P.11 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBS011.PRW </s>
    Descricao       - <d>  SPED SigaCTB </d>
    Procedure       -      Grava CS4
    Funcao do Siga  -      
    Entrada         - <ri> @IN_FILIAL - filial a gravar
                           @IN_CODREV - Codigo da Revisao
                           @IN_LPROCCTO - Se processa o custo - ainda estamos mandando tudo
    Saida           - <o>  </ro>
    Responsavel :     <r>  Renato F Campos </r>
    Data        :     14/06/2011
   -------------------------------------------------------------------------------------- */

cQuery += "	Declare @cFilial_CVD char( " + StrZero(TamSx3('CVD_FILIAL')[1], 3)+" ) "+CRLF
cQuery += "	Declare @cFilial_CS4 char( " + StrZero(TamSx3('CS4_FILIAL')[1], 3)+" ) "+CRLF
cQuery += "	Declare @cCVD_CONTA varchar( " + StrZero(TamSx3('CVD_CONTA' )[1], 3)+" ) "+CRLF
cQuery += "	Declare @cCVD_CTAREF varchar( " + StrZero(TamSx3('CVD_CTAREF' )[1], 3)+" ) "+CRLF
cQuery += "	Declare @cCVD_ENTREF char( " + StrZero(TamSx3('CVD_ENTREF' )[1], 3)+" ) "+CRLF
cQuery += "	Declare @cCVD_CUSTO char( " + StrZero(TamSx3('CVD_CUSTO' )[1], 3)+" ) "+CRLF
cQuery += "	Declare @cCVD_TPUTIL char( " + StrZero(TamSx3('CVD_TPUTIL' )[1], 3)+" ) "+CRLF
cQuery += "	Declare @cCVD_CLASSE char( " + StrZero(TamSx3('CVD_CLASSE' )[1], 3)+" ) "+CRLF
cQuery += "	Declare @cCVD_NATCTA char( " + StrZero(TamSx3('CVD_NATCTA' )[1], 3)+" ) "+CRLF
cQuery += "	Declare @cCVD_CTASUP char( " + StrZero(TamSx3('CVD_CTASUP' )[1], 3)+" ) "+CRLF
cQuery += "	Declare @cAux char(03) "+CRLF
cQuery += "	Declare @iRecno Integer "+CRLF
cQuery += " Declare @iNroRegs Integer"+CRLF
cQuery += " Declare @NCONT Integer"+CRLF
cQuery += " Declare @iTranCount Integer"+CRLF
cQuery += "  "+CRLF

cQuery += "	begin"+CRLF
cQuery += "  "+CRLF
cQuery += "		select @cCVD_CONTA = ''"+CRLF
cQuery += "		select @cCVD_CTAREF = ''"+CRLF
cQuery += "		select @cCVD_ENTREF = ''"+CRLF
cQuery += "		select @cCVD_CUSTO = '' "+CRLF
cQuery += "		select @cCVD_TPUTIL = '' "+CRLF
cQuery += "		select @cCVD_CLASSE = '' "+CRLF
cQuery += "		select @cCVD_NATCTA = '' "+CRLF
cQuery += "		select @cCVD_CTASUP = '' "+CRLF
cQuery += "		select @iRecno = 0"+CRLF
cQuery += "		select @iNroRegs = 0"+CRLF
cQuery += "		select @OUT_RESULT = '0'"+CRLF
cQuery += "		select @NCONT = 0"+CRLF
cQuery += "     select @cAux = 'CVD'"+CRLF
cQuery += "  "+CRLF

cQuery += "     Exec "+aProc[2]+ " @cAux, @IN_FILIAL, @cFilial_CVD OutPut"+CRLF

cQuery += "  "+CRLF
cQuery += "		select @NCONT = 0"+CRLF
cQuery += "     select @cAux = 'CS4'"+CRLF
cQuery += "     Exec "+aProc[2]+ " @cAux, @IN_FILIAL, @cFilial_CS4 OutPut"+CRLF
cQuery += "  "+CRLF

cQuery += "		Declare cursor_referencial insensitive cursor for"+CRLF
cQuery += "			SELECT CVD_CONTA, CVD_ENTREF, CVD_CTAREF, CVD_CUSTO, CVD_TPUTIL, CVD_CLASSE, CVD_NATCTA, CVD_CTASUP" + CRLF
cQuery += "           From " + RetSqlName("CVD") +CRLF
cQuery += "          Where CVD_FILIAL = @cFilial_CVD"+CRLF

If cModEsc != "FCO"
	cQuery += "            and CVD_CLASSE = '2'"+CRLF
EndIf

cQuery += " 		   and (( @IN_LEMPTYPLA = '0' and CVD_CODPLA = @IN_CODPLA AND CVD_VERSAO = @IN_VERPLA) or ( @IN_CODPLA= ' ' AND CVD_VERSAO = @IN_VERPLA  ) )"+CRLF
cQuery += "            and D_E_L_E_T_ = ' '"+CRLF
cQuery += "			   for read only"+CRLF

cQuery += "  "+CRLF
cQuery += "		OPEN cursor_referencial"+CRLF
cQuery += "		Fetch cursor_referencial into @cCVD_CONTA, @cCVD_ENTREF, @cCVD_CTAREF, @cCVD_CUSTO, @cCVD_TPUTIL"+CRLF
cQuery += ",    @cCVD_CLASSE, @cCVD_NATCTA, @cCVD_CTASUP" + CRLF
cQuery += "  "+CRLF
cQuery += "		While ( @@Fetch_Status = 0) begin"+CRLF
cQuery += "  "+CRLF
cQuery += "     	select @iNroRegs = @iNroRegs + 1"+CRLF
cQuery += "  "+CRLF
cQuery += "      	If @iNroRegs = 1 begin"+CRLF
cQuery += "         	begin tran"+CRLF
cQuery += "         	select @iNroRegs = @iNroRegs"+CRLF
cQuery += "      	End"+CRLF
cQuery += "  "+CRLF
cQuery += "			select @iRecno = IsNull(Max( R_E_C_N_O_ ), 0 ) from "+RetSqlName('CS4')+CRLF
cQuery += "			select @iRecno = @iRecno + 1"+CRLF
cQuery += "  "+CRLF
cQuery += "   		##TRATARECNO @iRecno\" + CRLF
cQuery += " 		Insert into "+RetSqlName('CS4')+" ( CS4_FILIAL, CS4_CODREV, CS4_CONTA, CS4_CTAREF, CS4_ENTREF, CS4_CCUSTO, CS4_TPUTIL, CS4_CLASSE, CS4_NATCTA, CS4_CTASUP"+CRLF
cQuery += ", R_E_C_N_O_ )"+CRLF
cQuery += "              values( @cFilial_CS4,  @IN_CODREV, @cCVD_CONTA, @cCVD_CTAREF, @cCVD_ENTREF, @cCVD_CUSTO"
cQuery += ", @cCVD_TPUTIL, @cCVD_CLASSE, @cCVD_NATCTA, @cCVD_CTASUP"+CRLF
cQuery += ", @iRecno )"+CRLF
cQuery += "   		##FIMTRATARECNO"+CRLF
cQuery += "  "+CRLF
cQuery += "			Fetch cursor_referencial into @cCVD_CONTA, @cCVD_ENTREF, @cCVD_CTAREF, @cCVD_CUSTO, @cCVD_TPUTIL, @cCVD_CLASSE, @cCVD_NATCTA, @cCVD_CTASUP"+CRLF
cQuery += "      	If @iNroRegs >= 10000 begin"+CRLF
cQuery += "         	commit tran"+CRLF
cQuery += "         	select @iNroRegs = 0"+CRLF
cQuery += "      	End"+CRLF

cQuery += "		End"+CRLF
cQuery += "		Close cursor_referencial"+CRLF
cQuery += "		Deallocate cursor_referencial"+CRLF
cQuery += "  "+CRLF

cQuery += "    	If @iNroRegs > 0 begin"+CRLF
cQuery += "        	commit tran"+CRLF
cQuery += "        	select @iTranCount = 0"+CRLF
cQuery += "    	End"+CRLF
cQuery += "  "+CRLF

cQuery += "		select @OUT_RESULT = '1'"+CRLF
cQuery += "	End"+CRLF

cQuery := CtbAjustaP(.T., cQuery, @nPTratRec)
cQuery := MsParse(cQuery,If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
cQuery := CtbAjustaP(.F., cQuery, nPTratRec)

If !TCSPExist( aProc[1] )
	nRet := TcSqlExec(cQuery)
	If nRet != 0 
		If !__lBlind
			MsgAlert('Erro na criacao da procedure de Exportacao de contas referenciais' + aProc[1])
			lRet:= .F.
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return lRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEcdIndTip บAutor  ณMicrosiga           บ Data ณ  11/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna Indicador por tipo de saldo                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function EcdIndTip(cTpSald)
Local cRetIndTip := "N"
Local nPosTpSald := 0

If( nPosTpSald := aScan(__ECDIndTip,{|x| x[2] == cTpSald }) ) > 0
	cRetIndTip := __ECDIndTip[nPosTpSald, 1]
EndIf

Return(cRetIndTip)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEcdTpSald บAutor  ณMicrosiga           บ Data ณ  11/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDE-PARA ** carrega array contendo ind.tipo com              บฑฑ
ฑฑบ          ณ2 elementos por linha --> 1o.Elemento Ind.Tipo              บฑฑ
ฑฑบ          ณ                          2o.Elemento Tipo de Saldo         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function EcdTpSald(aParamExp, cModEsc)

Default cModEsc := "ECD"

//DE-PARA ** carrega array contendo ind.tipo com 2 elementos por linha --> 1o.Elemento Ind.Tipo;2o.Elemento Tipo de Saldo
__ECDIndTip := {}
aAdd(__ECDIndTip, {"N", aParamExp[ ECD_TIPO_SALDO ] } )

If cModEsc == "FCO"	
	aAdd(__ECDIndTip, {"X"	, aParamExp[ ECD_TIP_X_LANC  ] } )
	aAdd(__ECDIndTip, {"F"	, aParamExp[ ECD_TIP_F_LANC  ] } )
	aAdd(__ECDIndTip, {"TR"	, aParamExp[ ECD_TIP_TR_LANC ] } )
	aAdd(__ECDIndTip, {"TF"	, aParamExp[ ECD_TIP_TF_LANC ] } )
	aAdd(__ECDIndTip, {"TS"	, aParamExp[ ECD_TIP_TS_LANC ] } )
	aAdd(__ECDIndTip, {"EF"	, aParamExp[ ECD_TIP_EF_LANC ] } )
	aAdd(__ECDIndTip, {"IF"	, aParamExp[ ECD_TIP_IF_LANC ] } )
	aAdd(__ECDIndTip, {"IS"	, aParamExp[ ECD_TIP_IS_LANC ] } )
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSaldoPlanRef บAutor  ณEquipe CTB       บ Data ณ  13/10/11   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExporta saldo de plano referencial                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SaldoPlanRef( oProcess, cEntRef, cModEsc, cPeriodo, cRegist, cCodPla ,cVerPla)
Local aArea  	:= GetArea()
Local aCtaSup   := {{},{}}

Local cConta 	:= PadR(CSC->CSC_CONTA, Len(CVD->CVD_CONTA))
Local cCusto 	:= PadR(CSC->CSC_CCUSTO, Len(CVD->CVD_CUSTO))
Local cAliasCVD	:= "CVD"
Local cContaSup := ''

Local nNivelCta := 1

Local lSeek		:= .T.


Default cModEsc := 'FCO'
Default cPeriodo:= ''
Default cRegist	:= ''
Default cCodPla	:= ' '
Default cVerPla := " "

//--------------------------------------------------------
// Verifica se existe um unico registro para as contas
// esta valida็ใo nใo ้ aplicada ao ECF
//--------------------------------------------------------
IF cModEsc != 'ECF' .AND. VerUnicRef( cEntRef, cCodPla,cVerPla )
	Return
Endif

IF (cModEsc = 'ECF' .AND. !Empty( cEntRef )) .OR. (cModEsc = 'FCO' .AND. !Empty( cEntRef ) .AND. !VerUnicRef( cEntRef, cCodPla ))
	
	DbSelectArea( 'CVD' )

	//Se informado C๓d Plano Referencial
	If !Empty(cCodPla) 
		CVD->( DbSetOrder(4) ) // CVD_FILIAL+CVD_ENTREF+CVD_CODPLA+CVD_CONTA+CVD_CUSTO+CVD_VERSAO 
		lSeek := MsSeek( xFilial("CVD") + cEntRef + cCodPla + cConta + cCusto + cVerPla )
	Else
	//Se NยO informado C๓d Plano Referencial
		CVD->( DbSetOrder(3) )
		lSeek := MsSeek( xFilial("CVD") + cEntRef + cConta + cCusto )
	EndIf
	
	If lSeek
		Do While CVD->( !Eof() .And. CVD_FILIAL == xFilial("CVD") .And. CVD_ENTREF == cEntRef .AND. CVD_CONTA == cConta .And. CVD_CUSTO == cCusto)
		
			If oProcess <> Nil 
				oProcess:IncRegua2( STR0067 + CVD->CVD_CTAREF)//'Conta Referencial: '
			EndIf
			If Empty(cCodPla) .OR. (CVD->CVD_CODPLA == cCodPla .And. CVD->CVD_VERSAO == cVerPla)
				RecLock("CSK",.T.)
				//Campos chaves herdado
				CSK->CSK_FILIAL 	:= xFilial("CSK")
				CSK->CSK_CODREV 	:= CSC->CSC_CODREV
				CSK->CSK_DTINI  	:= CSC->CSC_DTINI
				CSK->CSK_DTFIM 	 	:= CSC->CSC_DTFIM
				CSK->CSK_CONTA 	 	:= CSC->CSC_CONTA
				CSK->CSK_CCUSTO 	:= CSC->CSC_CCUSTO
				CSK->CSK_CTAREF 	:= CVD->CVD_CTAREF 
				CSK->CSK_VALDEB		:= CSC->CSC_VALDEB
				CSK->CSK_VALCRE		:= CSC->CSC_VALCRE
	
				//-----------------------------------------------
				//Campos incluidos apos aplica็ใo de update ECF
				//-----------------------------------------------
				If cModEsc == 'ECF'		
					CSK->CSK_VALINI	:= CSC->CSC_VALINI
					CSK->CSK_INDINI	:= CSC->CSC_INDINI		
					CSK->CSK_VALFIN	:= CSC->CSC_VALFIN
					CSK->CSK_INDFIM	:= CSC->CSC_INDFIM
					CSK->CSK_PERIOD	:= CSC->CSC_PERIOD
					CSK->CSK_CLASSE := CVD->CVD_CLASSE
					CSK->CSK_NATCTA := CVD->CVD_NATCTA
					CSK->CSK_CTASUP := CVD->CVD_CTASUP
				EndIf			
				
				If cModEsc == 'ECF'
					If cRegist = 'K155'
						CSK->CSK_REGIST	 := 'K156'
					ElseIf cRegist = 'K355'
						CSK->CSK_REGIST	 := 'K356'
					ElseIf cRegist = 'L100'
						CSK->CSK_REGIST	 := 'L100'
					ElseIf cRegist = 'L300'
						CSK->CSK_REGIST	 := 'L300'					
					ElseIf cRegist = 'P100'
						CSK->CSK_REGIST	 := 'P100'
					ElseIf cRegist = 'P150'
						CSK->CSK_REGIST	 := 'P150'										
					ElseIf cRegist = 'U100'
						CSK->CSK_REGIST	 := 'U100'
					ElseIf cRegist = 'U150'
						CSK->CSK_REGIST	 := 'U150'
					EndIf
				EndIf	
				
				If cModEsc == 'ECF'
					If (cAliasCVD)->CVD_CTASUP <> cContaSup
				
						nScanSup := Ascan( aCtaSup[01] , (cAliasCVD)->CVD_CTASUP )
						If nScanSup == 0
							nNivelCta := CtbNivCta( (cAliasCVD)->CVD_CONTA, "CTT" )
						Else
							nNivelCta := aCtaSup[ 02 , nScanSup]
						EndIf
						
						cContaSup := (cAliasCVD)->CVD_CTASUP				
						Aadd(aCtaSup[1] , cContaSup )
						Aadd(aCtaSup[2] , nNivelCta )
					EndIf
				 
					CSK->CSK_NIVEL := nNivelCta
				EndIf		
	
				MsUnLock()
			EndIf		
			CVD->(dbSkip())

		EndDo
	
	EndIf
	
EndIf
	
RestArea( aArea )

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC011Ref   บAutor  ณMicrosiga           บ Data ณ  28/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna tipo de utilizacao para conta referencial (FCONT)   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function C011Ref(ContaApu,CCustoApu,cEntRef)
Local aArea		:= GetArea()
Local cTpUtil  := " "

DEFAULT cEntRef := '  '

IF !Empty( cEntRef ) .And. !Empty( ContaApu )
	
	DbSelectArea( 'CVD' )
	CVD->( DbSetOrder(3) )

	IF MsSeek( xFilial("CVD") + PadR(cEntRef,Len(CVD->CVD_ENTREF)) + PadR(ContaApu,Len(CVD->CVD_CONTA)) + PadR(CCustoApu,Len(CVD->CVD_CUSTO)) )
		cTpUtil := CVD->CVD_TPUTIL
	Endif
Endif

RestArea( aArea )

Return(cTpUtil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณInd_Per   บAutor  ณMicrosiga           บ Data ณ  28/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Indica periodo para tipo de apuracao (FCONT)               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function Ind_Per( cTpPer, cDatIni, cDatFim)
Local dDataIni, dDataFim
Local cRetPer
Default cTpPer := "A"

If cTpPer == "A"
	cRetPer := "A00"
ElseIf cTpPer == "T"
	dDataIni := STOD(cDatIni)
	dDataFim := STOD(cDatFim)
	
	If Year(dDataIni) != Year(dDataFim)
		Conout(STR0054)  //"Erro na utilizacao da funcao Ind_Per() - Geracao FCONT"
		cRetPer := "   "
	Else	
		If Month(dDataIni) >= 1 .And. Month(dDataFim) <= 3
			cRetPer := "T01"
		ElseIf Month(dDataIni) >= 4 .And. Month(dDataFim) <= 6
			cRetPer := "T02"
		ElseIf Month(dDataIni) >= 7 .And. Month(dDataFim) <= 9
			cRetPer := "T03"
		ElseIf Month(dDataIni) >= 10 .And. Month(dDataFim) <= 12
			cRetPer := "T04"
		Else
			Conout(STR0054)  //"Erro na utilizacao da funcao Ind_Per() - Geracao FCONT"
			cRetPer := "   "
		EndIf
	EndIf
Else
	cRetPer := "A00"
EndIf

Return( cRetPer )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCalendTrimบAutor  ณMicrosiga           บ Data ณ  22/11/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna os periodos para calendario informado               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function CalendTrim(cCalend)
Local aArea := GetArea()
Local aCalRet := {}
dbSelectArea("CTG")
dbSetOrder(1)
dbSeek(xFilial("CTG")+cCalend)

While CTG->( !Eof() .And. CTG_FILIAL+CTG_CALEND==xFilial("CTG")+cCalend )
	aAdd(aCalRet, {})   
	aAdd(aCalRet[Len(aCalRet)], CTG->CTG_DTINI) //
	aAdd(aCalRet[Len(aCalRet)], CTG->CTG_DTFIM)
	CTG->( dbSkip())
EndDo

RestArea(aArea)
Return aCalRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณECdGetDMPLบAutor  ณMicrosiga           บ Data ณ  04/10/2013 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o codigo da visao gerencial utilizado como iniciali-บฑฑ
ฑฑบ          ณzador padrao para o campo CSO_CODVIS utilizado no registro  บฑฑ
ฑฑบ          ณJ215 DETALHE DO FATO CONTABIL DLPA/DMPL                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function ECdGetDMPL()
Local cVisGer := ""

If !Empty(__aParamExp[ECD_COD_DLPA]) .And. __aParamExp[ECD_SEL_DLPA_DMPL]==1
	cVisGer := __aParamExp[ECD_COD_DLPA]
ElseIf !Empty(__aParamExp[ECD_COD_DMPL]) .And. __aParamExp[ECD_SEL_DLPA_DMPL]==2
	cVisGer := __aParamExp[ECD_COD_DMPL]
EndIf

If !Empty(cVisGer) .And. CTN->( dbSeek(xFilial("CTN")+Alltrim(cVisGer)) )
	cVisGer := CTN->CTN_PLAGER
Else
	cVisGer := ""
EndIf

cEcdCodVis := cVisGer
Return(cVisGer)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ECF_CodRev บAutor  ณFelipe Cunha        บ Data ณ  29/01/2015 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAjusta valor da variavel static __CodRev quando chamado     บฑฑ
ฑฑบ          ณ  de outro fonte.											  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ECF_CodRev( cCodRev)
If __CodRev == ""  .OR. ( __CodRev != cCodRev )
  __CodRev := cCodRev
EndIf
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณExportaAuditor บAutor  ณTotvs          บ Data ณ  02/04/2015 บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExportacao Cad.Auditor                                      บฑฑ
ฑฑบ          ณ                     										  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ExportaAuditor( oProcess )
Local lRet := .T.
Local aArea := GetArea()

dbSelectArea("CVR")
dbSetOrder(1)
dbSeek( xFilial("CVR") )

While CVR->( !Eof() .And. CVR_FILIAL == xFilial("CVR") )
		
	If oProcess <> Nil 
		oProcess:IncRegua2( STR0068 + " " + Alltrim( CVR->CVR_CODCVM ) + "|" + Alltrim( CVR->CVR_NOMAUD ) )//"Auditor :" 
	EndIf
	
	RecLock( "CSP", .T.)
		CSP->CSP_FILIAL := xFilial("CSP")
		CSP->CSP_CODREV := __CodRev
		CSP->CSP_CODCVM := CVR->CVR_CODCVM
		CSP->CSP_NOMAUD	:= CVR->CVR_NOMAUD
		CSP->CSP_CGC	:= CVR->CVR_CGC
	MsUnLock()
	
	CVR->( dbSkip() )

EndDo
	
RestArea( aArea )

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณExportaSCPบAutor  ณTotvs               บ Data ณ  02/04/2015 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExportacao SCP                                              บฑฑ
ฑฑบ          ณ                     										  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
	
Function ExportaSCP( oProcess )
Local lRet := .T.
Local aArea := GetArea()

dbSelectArea("CVS")
dbSetOrder(1)
dbSeek( xFilial("CVS") )

While CVS->( !Eof() .And. CVS_FILIAL == xFilial("CVS") )
		
	If oProcess <> Nil 
		oProcess:IncRegua2( "SCP :" + " " + Alltrim( CVS->CVS_IDTSCP ) + "|" + Alltrim( CVS->CVS_NOMSCP ) ) 
	EndIf
	
	RecLock( "CSR", .T.)
	CSR->CSR_FILIAL := xFilial("CSR")
	CSR->CSR_CODREV  := __CodRev
	CSR->CSR_IDTSCP   := CVS->CVS_IDTSCP
	CSR->CSR_NOMSCP   := CVS->CVS_NOMSCP
	MsUnLock()
    
	CVS->( dbSkip() )

EndDo
	
RestArea( aArea )

Return(lRet)
		

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออหออออออัออออออออออออออปฑฑ
ฑฑบPrograma  ณExportaSubContaบAutor  ณTotvs         บ Data ณ  02/04/2015  บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออสออออออฯออออออออออออออนฑฑ
ฑฑบDesc.     ณExportacao SubConta Correlata                               บฑฑ
ฑฑบ          ณ                     										  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function ExportaSubConta( oProcess )
Local lRet := .T.
Local aArea := GetArea()
Local cAliasCVT 	:= GetNextAlias()


BeginSql Alias cAliasCVT
	SELECT DISTINCT CVT_CTAPAI, CVT_CODIDT,CVT_SUBCTA,CVT_NATSUB,CVT_FILIAL FROM %Table:CVT%  CVT  
		where  
			CVT.CVT_FILIAL = %xFilial:CVT%  AND
			(CVT.CVT_CTAPAI in (SELECT CS3_CONTA FROM %Table:CS3% CS3 WHERE CS3.%NotDel% AND CS3.CS3_CODREV = %exp:__CodRev%  ) and 
			CVT.CVT_SUBCTA in (SELECT CS3_CONTA FROM %Table:CS3% CS3 WHERE CS3.%NotDel%  AND CS3.CS3_CODREV = %exp:__CodRev% )) 
			AND CVT.%NotDel%
EndSql


While (cAliasCVT)->( !Eof() .And. (cAliasCVT)->CVT_FILIAL == xFilial("CVT") )
		
	If oProcess <> Nil 
		oProcess:IncRegua2( STR0069 + " " + Alltrim( (cAliasCVT)->CVT_CTAPAI ) + STR0070 + Alltrim( (cAliasCVT)->CVT_SUBCTA ) )//"Subconta Correlata -> Conta Pai :"##"| Correlata: " 
	EndIf
	
	RecLock( "CST", .T.)
	CST->CST_FILIAL := xFilial("CST")
	CST->CST_CODREV  := __CodRev
	CST->CST_CTAPAI   := (cAliasCVT)->CVT_CTAPAI
	CST->CST_CODIDT   := (cAliasCVT)->CVT_CODIDT
	CST->CST_SUBCTA   := (cAliasCVT)->CVT_SUBCTA
	CST->CST_NATSUB   := (cAliasCVT)->CVT_NATSUB
	MsUnLock()
    
	(cAliasCVT)->( dbSkip() )

EndDo
	
RestArea( aArea )

Return(lRet)






/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออหออออออัออออออออออออออปฑฑ
ฑฑบPrograma  ณBalMoedFun     บAutor  ณTotvs         บ Data ณ  23/02/2016  บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออสออออออฯออออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo que grava o balancete para moeda funcional           บฑฑ
ฑฑบ          ณ                     										    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function BalMoedFun(nParte,cArqTmp,aCs0,oProcess,dDataIni,dDataFim,lProcCusto)
Local nx:=0
Local nTaxa:=0

If nParte==1
	While cArqTmp->( !Eof() )
		If oProcess <> Nil 
			oProcess:IncRegua2( STR0032 + ": " + cArqTmp->CONTA)
		EndIf
		RecLock("CSC",.T.)
		CSC->CSC_FILIAL	 := xFilial("CSC")
		CSC->CSC_CODREV  := __CodRev
		CSC->CSC_DTINI   := dDataIni
		CSC->CSC_DTFIM   := dDataFim
		CSC->CSC_CONTA   := cArqTmp->CONTA
		CSC->CSC_CCUSTO  := Iif( lProcCusto, cArqTmp->CUSTO, "" )
		CSC->CSC_FUNINI  := ABS( cArqTmp->SALDOANT )
		CSC->CSC_FUNDEB  := ABS( cArqTmp->SALDODEB )
		CSC->CSC_FUNCRE  := ABS( cArqTmp->SALDOCRD )
		CSC->CSC_FUNMOV  := ABS( cArqTmp->( SALDODEB - SALDOCRD ) )
		CSC->CSC_FUNFIN  := ABS( cArqTmp->SALDOATU )
		CT1->(DbSetOrder(1))
		CT1->(DbSeek(xFilial("CT1") + cArqTmp->CONTA))
		/*/	If CT1->CT1_NTSPED == "1|2"
			nTaxa:=aCs0[17]
		Elseif CT1->CT1_NTSPED == "3"
			nTaxa:=aCs0[17]/*/
		// o tipo patrimonio liquido foi considerado como taxa do fechamento por nใo se ter como obter a taxa do dia quando atraves de saldo.
		If CT1->CT1_NTSPED $ "01|02|03"
			nTaxa:=VAL(aCs0[17])
		Elseif CT1->CT1_NTSPED $ "04"
			For nX := 1 TO 12
				nTaxa :=nTaxa+VAL(aCs0[nX+5])
			Next
			nTaxa:=nTaxa/12
		Endif
		CSC->CSC_TAXA    := nTaxa
		CSC->CSC_VALINI  := ABS( cArqTmp->SALDOANT )*nTaxa
		CSC->CSC_VALDEB  := ABS( cArqTmp->SALDODEB )*nTaxa
		CSC->CSC_VALCRE  := ABS( cArqTmp->SALDOCRD )*nTaxa
		CSC->CSC_VALMOV  := ABS( cArqTmp->( SALDODEB - SALDOCRD ) )*nTaxa
		CSC->CSC_VALFIN  := ABS( cArqTmp->SALDOATU )*nTaxa
		
		CSC->CSC_INDINI  := IIF( cArqTmp->SALDOANT > 0, "C","D" )
		CSC->CSC_INDFIM  := IIF( cArqTmp->SALDOATU > 0, "C","D" )
		MsUnLock()
		cArqTmp->(dbSkip())
	EndDo
	
	dbSelectArea("cArqTmp")
	dbCloseArea()
	
	If Select( "cArqTmp" ) == 0
		FErase(cArqTmp+GetDBExtension())
		FErase(cArqTmp+OrdBagExt())
	EndIF

Else
	While cArqTmp->( !Eof() )
		If oProcess <> Nil 
			oProcess:IncRegua2( STR0032 + ": " + cArqTmp->CONTA)
		EndIf
			
		CSC->(DbSetOrder(1))
		If !(CSC->(DbSeek(xFilial("CSC")+__CodRev+DTOS(dDataIni)+DTOS(dDataFim)+cArqTmp->CONTA+Iif( lProcCusto, cArqTmp->CUSTO, "" ))))
			RecLock("CSC",.T.)
			CSC->CSC_FILIAL	 := xFilial("CSC")
			CSC->CSC_CODREV  := __CodRev
			CSC->CSC_DTINI   := dDataIni
			CSC->CSC_DTFIM   := dDataFim
			CSC->CSC_CONTA   := cArqTmp->CONTA
			CSC->CSC_CCUSTO  := Iif( lProcCusto, cArqTmp->CUSTO, "" )
			CSC->CSC_INDINI  := IIF( cArqTmp->SALDOANT > 0, "C","D" )
			CSC->CSC_INDFIM  := IIF( cArqTmp->SALDOATU > 0, "C","D" )
		Else
			RecLock("CSC",.F.)
		Endif
		CSC->CSC_ADDINI  := ABS( cArqTmp->SALDOANT )
		CSC->CSC_ADDDEB  := ABS( cArqTmp->SALDODEB )
		CSC->CSC_ADDCRE  := ABS( cArqTmp->SALDOCRD )
		CSC->CSC_ADDMOV  := ABS( cArqTmp->( SALDODEB - SALDOCRD ) )
		CSC->CSC_ADDFIN  := ABS( cArqTmp->SALDOATU )		
		MsUnLock()
		cArqTmp->(dbSkip())
	EndDo
	
	dbSelectArea("cArqTmp")
	dbCloseArea()
	
	If Select( "cArqTmp" ) == 0
		FErase(cArqTmp+GetDBExtension())
		FErase(cArqTmp+OrdBagExt())
	EndIF			
Endif 


Return .T.




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออหออออออัออออออออออออออปฑฑ
ฑฑบPrograma  ณProcDiaFun     บAutor  ณTotvs         บ Data ณ  23/02/2016  บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออสออออออฯออออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo que grava o balancete para moeda funcional           บฑฑ
ฑฑบ          ณ                     										    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function ProcDiaFun(nParte,cArqTmp,aCs0,dDiaProc,lProcCusto)
Local nx:=0
Local nTaxa:=0

If nParte==1
	While cArqTmp->( !Eof() )
		IF cArqTmp->SALDODEB == 0 .And. cArqTmp->SALDOCRD == 0
			cArqTmp->(dbSkip())
			Loop
		Endif
		
		RecLock("CSG",.T.)
		CSG->CSG_FILIAL 	:= xFilial("CSG")
		CSG->CSG_CODREV 	:= __CodRev
		CSG->CSG_DTBAL 		:= dDiaProc
		CSG->CSG_CONTA 		:= cArqTmp->CONTA
		CSG->CSG_CCUSTO 	:= Iif(lProcCusto==.T.,cArqTmp->CUSTO,"")
		CSG->CSG_FUNINI 	:= ABS(cArqTmp->SALDOANT)
		CSG->CSG_FUNDEB 	:= ABS(cArqTmp->SALDODEB)
		CSG->CSG_FUNCRE		:= ABS(cArqTmp->SALDOCRD)
		CSG->CSG_FUNMOV 	:= ABS(cArqTmp->MOVIMENTO)
		CSG->CSG_FUNFIN 	:= ABS(cArqTmp->SALDOATU)
		CSG->CSG_INDINI 	:= IIF(cArqTmp->SALDOANT>0,"C","D")
		CSG->CSG_INDFIM 	:= IIF(cArqTmp->SALDOATU>0,"C","D")
		CT1->(DbSetOrder(1))
		CT1->(DbSeek(xFilial("CT1") + cArqTmp->CONTA))
		/*/	If CT1->CT1_NTSPED == "1|2"
			nTaxa:=aCs0[17]
		Elseif CT1->CT1_NTSPED == "3"
			nTaxa:=aCs0[17]/*/
		// o tipo patrimonio liquido foi considerado como taxa do fechamento por nใo se ter como obter a taxa do dia quando atraves de saldo.
		If CT1->CT1_NTSPED $ "01|02|03"
			nTaxa:=VAL(aCs0[17])
		Elseif CT1->CT1_NTSPED $ "04"
			For nX := 1 TO 12
				nTaxa :=nTaxa+VAL(aCs0[nX+5])
			Next
			nTaxa:=nTaxa/12
		Endif
		CSG->CSG_TAXA    := nTaxa
		CSG->CSG_VALINI 	:= ABS(cArqTmp->SALDOANT)*nTaxa
		CSG->CSG_VALDEB 	:= ABS(cArqTmp->SALDODEB)*nTaxa
		CSG->CSG_VALCRE		:= ABS(cArqTmp->SALDOCRD)*nTaxa
		CSG->CSG_VALMOV 	:= ABS(cArqTmp->MOVIMENTO)*nTaxa
		CSG->CSG_VALFIN 	:= ABS(cArqTmp->SALDOATU)*nTaxa
		MsUnLock()
		cArqTmp->(dbSkip())
	EndDo
	
	
	dbSelectArea("cArqTmp")
	Set Filter To
	dbCloseArea()
	If Select("cArqTmp") == 0
		FErase(cArqTmp+GetDBExtension())
		FErase(cArqTmp+OrdBagExt())
	EndIF


Else
	While cArqTmp->( !Eof() )
		IF cArqTmp->SALDODEB == 0 .And. cArqTmp->SALDOCRD == 0
			cArqTmp->(dbSkip())
			Loop
		Endif
			
		CSG->(DbSetOrder(1))
		If !(CSG->(DbSeek(xFilial("CSG")+__CodRev+DTOS(dDiaProc)+cArqTmp->CONTA+Iif( lProcCusto, cArqTmp->CUSTO, "" ))))
			RecLock("CSG",.T.)
			CSG->CSG_FILIAL 	:= xFilial("CSG")
			CSG->CSG_CODREV 	:= __CodRev
			CSG->CSG_DTBAL 		:= dDiaProc
			CSG->CSG_CONTA 		:= cArqTmp->CONTA
			CSG->CSG_CCUSTO 	:= Iif(lProcCusto==.T.,cArqTmp->CUSTO,"")
			CSG->CSG_INDINI 	:= IIF(cArqTmp->SALDOANT>0,"C","D")
			CSG->CSG_INDFIM 	:= IIF(cArqTmp->SALDOATU>0,"C","D")
		Else
			RecLock("CSG",.F.)
		Endif
		CSG->CSG_ADDINI 	:= ABS(cArqTmp->SALDOANT)
		CSG->CSG_ADDDEB 	:= ABS(cArqTmp->SALDODEB)
		CSG->CSG_ADDCRE		:= ABS(cArqTmp->SALDOCRD)
		CSG->CSG_ADDMOV 	:= ABS(cArqTmp->MOVIMENTO)
		CSG->CSG_ADDFIN 	:= ABS(cArqTmp->SALDOATU)		
		
		MsUnLock()
		cArqTmp->(dbSkip())
	EndDo
	
	dbSelectArea("cArqTmp")
	dbCloseArea()
	
	If Select( "cArqTmp" ) == 0
		FErase(cArqTmp+GetDBExtension())
		FErase(cArqTmp+OrdBagExt())
	EndIF			
Endif 


Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCt11PMFบAutor  ณEquipe CTB          บ Data ณ   24/03/10  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Cria procedure de gravacao de movimentos no CSB           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SPED Contabil                                              บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParmetrosณ ExpC1 = Nome da procedure a ser criada                     ณฑฑ
ฑฑณ          ณ ExpA1 = Array com todas as procedures criadas              ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ */

Function Ct11PMF(cProc, aProc, aFils, aTpSald, cModEsc, cMoedaX,cMoeda)
Local aArea  := GetArea()
Local lRet   := .T.
Local cQuery := ""
Local nPTratRec := 0
Local iX     := 0
Local cFils  := ""  
Local lExclusivo := IIF(FindFunction("ADMTabExc"), ADMTabExc("CT2") , !Empty(xFilial("CT2") ))
Local nX
Local aCs0:=StrTokArr("N|","|")
Local lProcDoc	:= GetNewPar("MV_CTBSDOC" , .F.)

/* -----------------------------------------------------------------------------------------
	NAO mudar a ordem de criacao das procedures
   aProc[7] -> CTB201 - GERA MOV................................................... aProc[5]
   aProc[1] ->    +--> ECDCHVMOV - Ponto de entrada que altera a chave............. aProc[1]
   aProc[2] ->    +--> Ct11Filial.................................................. aProc[2]
   aProc[3] ->    +--> CTB202 - GetDtp()-Verifica se tem apuracao nessa Data....... aProc[2]
   aProc[4] ->    +--> CTB203 - Grava CSA.......................................... aProc[3]
   aProc[5] ->            +--> CTB205 - Grava CSL.................................. aProc[4]
   aProc[6] ->    +--> CTB204 - Grava CSB.......................................... aProc[4]
   ----------------------------------------------------------------------------------------- */
   
   
If cModEsc == "ECD" .And. lMoedfun .and. lLeiaute4
	aCs0:=	StrTokArr( CS0->CS0_MOEFUN,"|" )
Endif
   
cQuery := "Create Procedure "+cProc+CRLF
cQuery += "("+CRLF
cQuery += "   @IN_EMP       Char( "+StrZero(TamSx3('CT2_EMPORI' )[1], 3)+" ),"+CRLF
cQuery += "   @IN_FILIAL    Char( "+StrZero(TamSx3('CT2_FILIAL' )[1], 3)+" ),"+CRLF
cQuery += "   @IN_DATAI     Char( 08 ),"+CRLF
cQuery += "   @IN_DATAF     Char( 08 ),"+CRLF
cQuery += "   @IN_MOEDA     Char( "+StrZero(TamSx3('CT2_MOEDLC' )[1], 3)+" ),"+CRLF
cQuery += "   @IN_MOEDAX    Char( "+StrZero(TamSx3('CT2_MOEDLC' )[1], 3)+" ),"+CRLF
cQuery += "   @IN_TPSALD    Char( "+StrZero(TamSx3('CT2_TPSALD' )[1], 3)+" ),"+CRLF
cQuery += "   @IN_CONTAI    Char( "+StrZero(TamSx3('CT1_CONTA' )[1], 3)+" ),"+CRLF
cQuery += "   @IN_CONTAF    Char( "+StrZero(TamSx3('CT1_CONTA' )[1], 3)+" ),"+CRLF
cQuery += "   @IN_CODREV    Char( "+StrZero(TamSx3('CSA_CODREV' )[1], 3)+" ),"+CRLF
cQuery += "   @IN_PRODCUSTO Char( 01 ),"+CRLF
cQuery += "   @IN_ENTREF    Char( 02 ),"+CRLF
cQuery += "   @IN_TPLIVRO   Char( 01 ),"+CRLF
cQuery += "   @OUT_RESULT   Char( 01 ) OutPut"+CRLF
cQuery += ")"+CRLF
cQuery += "as"+CRLF
/* ------------------------------------------------------------------------------------
    Versใo          - <v>  Protheus 9.12 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBS011.PRW </s>
    Descricao       - <d>  SPED SigaCTB </d>
    Funcao do Siga  -      ProcMov()
    Entrada         - <ri> @IN_EMP     - Empresa Corrente
                           @IN_FILIAL  - Filial Corrente
                           @IN_DATAI   - Data Inicial
                           @IN_DATAF   - Data Final
                           @IN_MOEDA   - Moeda escolhida
                           @IN_TPSALD  - Tipo de Saldo a gerar movimento
                           @IN_CONTAI  - Conta Inicial do Range
                           @IN_CONTAF  - Conta Final do Range
                           @IN_CODREV  - Codigo da revisao
                           @IN_PROCUSTO - Se '1', gravo CT2_CCD, se '0' gravo ' '
                           @IN_LCUSTO   - Se '1, gravo o CCusto, '0' nao gravo CCusto <ri/>
                           @IN_TPLIVRO  - Tipo de Livro                           
    Saida           - <o>  @OUT_RESULT - Indica o termino OK da procedure </ro>
    Responsavel :     <r> totvs  	</r>
    Data        :     26/02/2010

   CTB201 - GERA MOV
      +--> ECDCHVMOV - Ponto de entrada que altera a chave
      +--> CTB202 - GetDtp()- SPEDCTBA - Verifica se tem apuracao nessa Data
      +--> CTB203 - Grava CSA
      +--> CTB204 - Grava CSB
              +--> CTB205 - GravaCSL
   -------------------------------------------------------------------------------------- */

cQuery += "Declare @cFilial_CT2 Char( "+StrZero(TamSx3('CT2_FILIAL' )[1], 3)+" )"+CRLF
cQuery += "Declare @cFilial_CTC Char( "+StrZero(TamSx3('CTC_FILIAL' )[1], 3)+" )"+CRLF
cQuery += "Declare @cFilial_CT8 Char( "+StrZero(TamSx3('CT8_FILIAL' )[1], 3)+" )"+CRLF
cQuery += "Declare @cFilial_CSA Char( "+StrZero(TamSx3('CSA_FILIAL' )[1], 3)+" )"+CRLF
cQuery += "Declare @cFilial_CSB Char( "+StrZero(TamSx3('CSB_FILIAL' )[1], 3)+" )"+CRLF
cQuery += "Declare @cAux        Char( 03 )"+CRLF
cQuery += "Declare @cCT2_FILIAL Char( "+StrZero(TamSx3('CT2_FILIAL' )[1], 3)+" )"+CRLF
cQuery += "Declare @cCT2_DATA   Char( "+StrZero(TamSx3('CT2_DATA' )[1], 3)+" )"+CRLF
cQuery += "Declare @cCT2_LOTE   Char( "+StrZero(TamSx3('CT2_LOTE' )[1], 3)+" )"+CRLF
cQuery += "Declare @cCT2_SBLOTE Char( "+StrZero(TamSx3('CT2_SBLOTE' )[1], 3)+" )"+CRLF 
cQuery += "Declare @cCT2_DOC    Char( "+StrZero(TamSx3('CT2_DOC' )[1], 3)+" )"+CRLF
cQuery += "Declare @cCT2_SEQLAN Char( "+StrZero(TamSx3('CT2_SEQLAN' )[1], 3)+" )"+CRLF
cQuery += "Declare @cCT2_EMPORI Char( "+StrZero(TamSx3('CT2_EMPORI' )[1], 3)+" )"+CRLF
cQuery += "Declare @cCT2_FILORI Char( "+StrZero(TamSx3('CT2_FILORI' )[1], 3)+" )"+CRLF
cQuery += "Declare @cCT2_MOEDLC Char( "+StrZero(TamSx3('CT2_MOEDLC' )[1], 3)+" )"+CRLF
cQuery += "Declare @cCT2_SEQHIS Char( "+StrZero(TamSx3('CT2_SEQIDX' )[1], 3)+" )"+CRLF
cQuery += "Declare @cCT2_LINHA  Char( "+StrZero(TamSx3('CT2_LINHA' )[1], 3)+" )"+CRLF
cQuery += "Declare @cCT2_DC     Char( "+StrZero(TamSx3('CT2_DC' )[1], 3)+" )"+CRLF
cQuery += "Declare @cCT2_DEBITO Char( "+StrZero(TamSx3('CT2_DEBITO' )[1], 3)+" )"+CRLF
cQuery += "Declare @cCT2_CREDIT Char( "+StrZero(TamSx3('CT2_CREDIT' )[1], 3)+" )"+CRLF
cQuery += "Declare @cCT2_HP     Char( "+StrZero(TamSx3('CT2_HP' )[1], 3)+" )"+CRLF
cQuery += "Declare @cCT2_HIST   Char( "+StrZero(TamSx3('CT2_HIST' )[1], 3)+" )"+CRLF
cQuery += "Declare @cCT2_CCD    Char( "+StrZero(TamSx3('CT2_CCD' )[1], 3)+" )"+CRLF
cQuery += "Declare @cCT2_CCC    Char( "+StrZero(TamSx3('CT2_CCC' )[1], 3)+" )"+CRLF
cQuery += "Declare @cCT2_DTLP   Char( "+StrZero(TamSx3('CT2_DTLP' )[1], 3)+" )"+CRLF
cQuery += "Declare @cCT2_TPSALD Char( "+StrZero(TamSx3('CT2_TPSALD' )[1], 3)+" )"+CRLF
cQuery += "Declare @nCT2_VALOR  Float"+CRLF
cQuery += "Declare @cCT2_CODPAR Char( "+StrZero(TamSx3('CT2_CODPAR' )[1], 3)+" )"+CRLF
cQuery += "Declare @cChave      VarChar( "+StrZero(TamSx3('CSA_NUMLOT' )[1], 3)+" )"+CRLF
cQuery += "Declare @cChaveAux   VarChar( "+StrZero(TamSx3('CSA_NUMLOT' )[1], 3)+" )"+CRLF
cQuery += "Declare @cCSB_NUMARQ Varchar( "+StrZero(TamSx3('CSB_NUMARQ' )[1], 3)+" )"+CRLF
cQuery += "Declare @cDc         Char( 01 )"+CRLF
cQuery += "Declare @cCSA_INDTIP Char( "+StrZero(TamSx3('CSA_INDTIP' )[1], 3)+" )"+CRLF
cQuery += "Declare @cRet        Char( 01 )"+CRLF
cQuery += "Declare @cCT8_IDENT  Char( "+StrZero(TamSx3('CT8_IDENT' )[1], 3)+" )"+CRLF
cQuery += "Declare @cExtHIST    Varchar( "+StrZero(TamSx3('CT2_HIST')[1], 3)+" )"+CRLF
cQuery += "Declare @nLenHist    Integer"+CRLF
cQuery += "Declare @iNroRegs1   Integer"+CRLF
cQuery += "Declare @iTranCount  Integer"+CRLF   // --Var.de ajuste para SQLServer e Sybase.
cQuery += "declare @iRecno      Integer"+CRLF
cQuery += "declare @iRecnoD     Integer"+CRLF
cQuery += "declare @iRecnoC     Integer"+CRLF
cQuery += "Declare @iRecnoCSA   Integer"+CRLF
cQuery += "Declare @iRecnoCSL   Integer"+CRLF
cQuery += "Declare @NCONT       Integer"+CRLF
cQuery += "Declare @cChvCSBAnt  VarChar( "+StrZero(TamSx3('CSB_NUMARQ' )[1], 3)+" )"+CRLF
cQuery += "Declare @nVlrMoedFu  Float"+CRLF

cQuery += "Declare @iFoundCSQ   integer"+CRLF
cQuery += "Declare @cCSQ_DTEXT  Char( "+StrZero(8, 3)+" )"+CRLF

cQuery += "begin"+CRLF
cQuery += "   select @NCONT= 0"+CRLF
cQuery += "   select @cAux = 'CT2'"+CRLF
cQuery += "   Exec "+aProc[2]+ " @cAux, @IN_FILIAL, @cFilial_CT2 OutPut"+CRLF
cQuery += "   select @cAux = 'CTC'"+CRLF
cQuery += "   Exec "+aProc[2]+ " @cAux, @IN_FILIAL, @cFilial_CTC OutPut"+CRLF
   
cQuery += "   select @cChave = ''"+CRLF
cQuery += "   select @cChaveAux = ''"+CRLF
cQuery += "   select @cCSB_NUMARQ = ''"+CRLF
cQuery += "   select @iRecno = 0"+CRLF
cQuery += "   select @iRecnoD = 0"+CRLF
cQuery += "   select @iRecnoC = 0"+CRLF
cQuery += "   select @iRecnoCSA = 0"+CRLF
cQuery += "   select @iRecnoCSL = 0"+CRLF
cQuery += "   select @iNroRegs1 = 0"+CRLF
cQuery += "   select @OUT_RESULT = '0'"+CRLF
cQuery += "   select @cDc = ''"+CRLF
cQuery += "   select @cCSA_INDTIP = ''"+CRLF
cQuery += "   select @cRet        = '0'"+CRLF
cQuery += "   select @cCT8_IDENT  = ''"+CRLF
cQuery += "   select @cChvCSBAnt  = ''"+CRLF

cQuery += "   Declare CUR_PROCMOV insensitive cursor for"+CRLF
cQuery += "      Select CT2_FILIAL, CT2_DATA,   CT2_LOTE,  CT2_SBLOTE, CT2_DOC,    CT2_SEQLAN, CT2_EMPORI, CT2_FILORI, "+CRLF
cQuery += "             CT2_MOEDLC, CT2_SEQHIS, CT2_LINHA, CT2_DC,     CT2_DEBITO, CT2_CREDIT, CT2_HP,     CT2_HIST,"+CRLF
cQuery += "             CT2_CCD,    CT2_CCC,    CT2_DTLP,  CT2_TPSALD, CT2_VALOR,  CT2_CODPAR"+CRLF
cQuery += "        From "+RetSqlName("CTC")+" T1, "+RetSqlName("CT2")+" T2"+CRLF
cQuery += "       Where T1.CTC_DATA between @IN_DATAI and @IN_DATAF"+CRLF
/*  moeda funcional */
cQuery += "         and T1.CTC_MOEDA  IN ('"+ cMoeda+"', '"+cMoedaX +"')"+CRLF
If Len(aTpSald) > 0
	cQuery += "         and T1.CTC_TPSALD IN ("
	For nX := 1 TO Len(aTpSald)
		cQuery += "'"+aTpSald[nX]+"'"
		If nX < Len(aTpSald)
			cQuery += ","
		Else
			cQuery += ")"
		EndIf
	Next		
Else
	cQuery += "         and T1.CTC_TPSALD = @IN_TPSALD"+CRLF
EndIf
cQuery += "         and T1.D_E_L_E_T_ = ' '"+CRLF

If lExclusivo
	cQuery += "         and T2.CT2_FILIAL IN ( "
	For iX := 1 To Len(aFils)
		If aFils[ix][1]
			cFils += "'"+xFilial("CT2",aFils[ix][3])+"',"
		EndIf
	Next
	cQuery += SubString(cFils, 1 , Len(cFils) -1)+" )"+CRLF
Else
	cQuery += "         and T2.CT2_FILIAL = '"+xFilial("CT2")+"' " +CRLF
EndIf
cQuery += "         and T1.CTC_FILIAL = T2.CT2_FILIAL"+CRLF
cQuery += "         and T2.CT2_DATA   = T1.CTC_DATA"+CRLF
cQuery += "         and T2.CT2_LOTE   = T1.CTC_LOTE"+CRLF
cQuery += "         and T2.CT2_SBLOTE = T1.CTC_SBLOTE"+CRLF
// cQuery += "      If @cCT2_DTLP = ' ' begin"+CRLF
cQuery += "         and T2.CT2_DOC    = T1.CTC_DOC"+CRLF
//cQuery += "      End"+CRLF
cQuery += "         and T2.CT2_MOEDLC = T1.CTC_MOEDA"+CRLF
cQuery += "         and T2.CT2_TPSALD = T1.CTC_TPSALD"+CRLF
cQuery += "         and ((( T2.CT2_DEBITO between @IN_CONTAI and @IN_CONTAF) or"+CRLF
cQuery += "               ( T2.CT2_CREDIT between @IN_CONTAI and @IN_CONTAF)) OR T2.CT2_DC = '4')"+CRLF
cQuery += "         and T2.D_E_L_E_T_ = ' '"+CRLF
cQuery += "   order by 1, 2, 3, 4, 5, 6, 7, 8, 9, 10"+CRLF
cQuery += "   for read only"+CRLF
cQuery += "   Open CUR_PROCMOV"+CRLF
cQuery += "   Fetch CUR_PROCMOV into @cCT2_FILIAL, @cCT2_DATA,   @cCT2_LOTE,  @cCT2_SBLOTE, @cCT2_DOC,    @cCT2_SEQLAN, @cCT2_EMPORI, @cCT2_FILORI, "+CRLF
cQuery += "                          @cCT2_MOEDLC, @cCT2_SEQHIS, @cCT2_LINHA, @cCT2_DC,     @cCT2_DEBITO, @cCT2_CREDIT, @cCT2_HP,     @cCT2_HIST,"+CRLF
cQuery += "                          @cCT2_CCD,    @cCT2_CCC,    @cCT2_DTLP,  @cCT2_TPSALD, @nCT2_VALOR,  @cCT2_CODPAR"+CRLF
cQuery += CRLF
cQuery += "   While ( @@fetch_status = 0 ) begin"+CRLF
cQuery += "      "+CRLF

cQuery += "      select @iFoundCSQ = 0 "+CRLF
cQuery += "      select @cCSQ_DTEXT = ' ' "+CRLF

cQuery += "      select @cAux = 'CT8'"+CRLF
cQuery += "      Exec "+aProc[2]+ " @cAux, @IN_FILIAL, @cFilial_CT8 OutPut"+CRLF
cQuery += "      select @cAux = 'CSA'"+CRLF
cQuery += "      Exec "+aProc[2]+ " @cAux, @IN_FILIAL, @cFilial_CSA OutPut"+CRLF
cQuery += "      select @cAux = 'CSB'"+CRLF
cQuery += "      Exec "+aProc[2]+ " @cAux, @IN_FILIAL, @cFilial_CSB OutPut"+CRLF

cQuery += "      select @iNroRegs1 = @iNroRegs1 + 1"+CRLF
/* @IN_MOEDA - funcional -? moeda '01'  
   @IN_MOEDAX  - outra Moeda */
cQuery += "      If @cCT2_MOEDLC = '01' begin"+CRLF

If cModEsc == "FCO"
	cQuery += "         Select @cChave = @cCT2_FILIAL||@cCT2_DATA||@cCT2_LOTE||@cCT2_SBLOTE||@cCT2_TPSALD"+CRLF
Else
	cQuery += "      If @cCT2_DTLP != ' ' begin"+CRLF
	cQuery += "      	Select @cChave = @cCT2_FILIAL||@cCT2_DATA||@cCT2_LOTE||@cCT2_SBLOTE||'APURACAO'"+CRLF
	cQuery += "      End else begin" +CRLF
	If lProcDoc
		cQuery += "      	Select @cChave = @cCT2_FILIAL||@cCT2_DATA||@cCT2_LOTE||@cCT2_SBLOTE||@cCT2_DOC"+CRLF
	Else
		cQuery += "      	Select @cChave = @cCT2_FILIAL||@cCT2_DATA||@cCT2_LOTE||@cCT2_SBLOTE"+CRLF
	Endif
	cQuery += "      End"+CRLF
Endif
cQuery += CRLF
cQuery += "      Exec "+aProc[1]+ " @cChave, @cChaveAux OutPut"+CRLF
cQuery += "  "+CRLF
cQuery += "         If @cChaveAux != ' ' select @cChave = @cChaveAux"+CRLF
cQuery += "         If @cCT2_TPSALD = @IN_TPSALD select @cCSA_INDTIP = 'N'"+CRLF
If cModEsc == "FCO"
 	For nX := 2 TO Len(__ECDIndTip)
 		If !Empty(__ECDIndTip[nX, 2])
			cQuery += "         If @cCT2_TPSALD = '"+__ECDIndTip[nX, 2]+"' select @cCSA_INDTIP = '"+__ECDIndTip[nX, 1]+"'"+CRLF
		EndIf
	Next		
EndIf         
cQuery += CRLF
cQuery += "         If @cCT2_DTLP != ' ' begin"+CRLF
cQuery += "            select @cRet = '0'"+CRLF
cQuery += CRLF
cQuery += "            Exec "+aProc[3]+"  @IN_EMP, @IN_FILIAL, @cCT2_DATA, @cCT2_MOEDLC, @cCT2_TPSALD, @cRet OutPut"+CRLF
cQuery += CRLF
         
cQuery += "            If @cRet = '1' begin "+CRLF
cQuery += "                select @cCSA_INDTIP = 'E'"+CRLF
cQuery += "      	   end "+CRLF

cQuery += "         end"+CRLF



If __lExistCSQ  //se existe a tabela CSQ leiaute 7
	cQuery += "      If @cRet = '0' begin"+CRLF
	                        //consultar tabela CSQ
	cQuery += "             select @iFoundCSQ = IsNull(Max( R_E_C_N_O_ ), 0 ), @cCSQ_DTEXT = IsNull(CSQ_DTEXT, ' ')  from "+RetSqlName("CSQ")+CRLF
	cQuery += "              where CSQ_FILIAL = @cCT2_FILIAL "
	cQuery += "                and CSQ_DATA = @cCT2_DATA "		
	cQuery += "                and CSQ_LOTE = @cCT2_LOTE "		
	cQuery += "                and CSQ_SBLOTE = @cCT2_SBLOTE "		
	cQuery += "                and CSQ_DOC = @cCT2_DOC "		
	cQuery += "                and CSQ_LINHA = @cCT2_LINHA "		
	cQuery += "                and CSQ_EMPORI = @cCT2_EMPORI "		
	cQuery += "                and CSQ_FILORI = @cCT2_FILORI "		
	cQuery += "                and D_E_L_E_T_ = ' ' "		
	cQuery += "             group by R_E_C_N_O_ , CSQ_DTEXT
	cQuery += "      end"+CRLF

	cQuery += "      If @iFoundCSQ != 0 select @cCSA_INDTIP = 'X'"+CRLF

EndIf
      
cQuery += "         If @iNroRegs1 = 1 begin"+CRLF
cQuery += "            begin tran"+CRLF
cQuery += "            select @iNroRegs1 = @iNroRegs1"+CRLF
cQuery += "         End"+CRLF
      
//If cModEsc == "FCO"
	cQuery += "         If ( Round(@nCT2_VALOR,2 ) != 0.00) and ( @cCT2_DC = '1' or @cCT2_DC = '2' or @cCT2_DC = '3') begin"+CRLF
//Else
//	cQuery += "         If ( Round(@nCT2_VALOR,2 ) != 0.00) and ( @cCT2_DC = '1' or @cCT2_DC = '3') begin"+CRLF/
//EndIf

cQuery += "         select @iRecnoCSA = 0"+CRLF
cQuery += "         Select @iRecnoCSA = IsNull( MIN(R_E_C_N_O_), 0 )"+CRLF
cQuery += "           From "+REtSqlName("CSA")+CRLF
cQuery += "          Where CSA_FILIAL = @cFilial_CSA"+CRLF
cQuery += "            and CSA_CODREV = @IN_CODREV"+CRLF
cQuery += "            and CSA_DTLANC = @cCT2_DATA"+CRLF
cQuery += "            and CSA_NUMLOT = @cChave"+CRLF
If cModEsc == "FCO"
	cQuery += "            and CSA_INDTIP = @cCSA_INDTIP"+CRLF
EndIf
cQuery += "               and D_E_L_E_T_ = ' '"+CRLF
         
cQuery += "			If @cCSA_INDTIP != 'E'  and @IN_TPLIVRO = 'A' begin"+CRLF
cQuery += "			   If @iRecnoCSA = 0 begin"+CRLF
 
cQuery += "          		Exec "+aProc[4]+" @cFilial_CSA, @IN_CODREV, @cChave, @cCT2_DATA, @nCT2_VALOR, @cCSA_INDTIP,@cCSQ_DTEXT,0,0"+CRLF
cQuery += "         		End else begin"+CRLF
cQuery += "       			UpDate "+RetSqlName("CSA")+CRLF
cQuery += "             			Set CSA_VLLCTO = CSA_VLLCTO + Round( @nCT2_VALOR, 2 )"+CRLF
cQuery += "          		   	Where R_E_C_N_O_ = @iRecnoCSA"+CRLF
cQuery += "         		End"+CRLF
cQuery += "   		End"+CRLF
cQuery += "			If @IN_TPLIVRO != 'A' begin"+CRLF
cQuery += "				If @iRecnoCSA = 0 begin"+CRLF
cQuery += "          		Exec "+aProc[4]+" @cFilial_CSA, @IN_CODREV, @cChave, @cCT2_DATA, @nCT2_VALOR, @cCSA_INDTIP,@cCSQ_DTEXT,0,0"+CRLF
cQuery += "         		End else begin"+CRLF
cQuery += "       			UpDate "+RetSqlName("CSA")+CRLF
cQuery += "             			Set CSA_VLLCTO = CSA_VLLCTO + Round( @nCT2_VALOR, 2 )"+CRLF
cQuery += "          		   	Where R_E_C_N_O_ = @iRecnoCSA"+CRLF
cQuery += "         		End"+CRLF
cQuery += "   		End"+CRLF
cQuery += "		End"+CRLF
      /* -----------------------------
         preparacao para CSB
         ----------------------------- */

cQuery += "      If @cCT2_DC != '4' begin"+CRLF
cQuery += "         select @iRecnoD = 0"+CRLF
cQuery += "         select @iRecnoC = 0"+CRLF
cQuery += "      End"+CRLF

      /*   grava debitos  */
cQuery += "      If (( @cCT2_DC = '1' or @cCT2_DC = '3') and ( @cCT2_DEBITO between @IN_CONTAI and @IN_CONTAF )) begin"+CRLF
cQuery += "         select @cDc = 'D'"+CRLF
If cModEsc == "FCO"
	cQuery += "         select @cCSB_NUMARQ = @cCT2_FILIAL||@cCT2_DATA||@cCT2_LOTE||@cCT2_SBLOTE||@cCT2_TPSALD||@cCT2_DOC||@cCT2_LINHA||@cCT2_SEQLAN||@cDc||@cCT2_MOEDLC||@cCT2_TPSALD||@cCT2_EMPORI||@cCT2_FILORI"+CRLF
Else
	cQuery += "         select @cCSB_NUMARQ = @cCT2_FILIAL||@cCT2_DATA||@cCT2_LOTE||@cCT2_SBLOTE||@cCT2_DOC||@cCT2_LINHA||@cCT2_SEQLAN||@cDc||@cCT2_MOEDLC||@cCT2_TPSALD||@cCT2_EMPORI||@cCT2_FILORI"+CRLF
Endif
cQuery += "   select @nVlrMoedFu = CT2_VALOR FROM "+RetSqlName("CT2")+" WHERE CT2_FILIAL = '"+ xFilial("CT2") +"' and CT2_DATA = @cCT2_DATA and CT2_LOTE = @cCT2_LOTE and CT2_SBLOTE = @cCT2_SBLOTE and CT2_DOC = @cCT2_DOC and CT2_DC = @cCT2_DC and CT2_LINHA = @cCT2_LINHA and CT2_MOEDLC = '" +aCs0[2]+"'"+CRLF
cQuery += "   "+CRLF
cQuery += "   	If @cCT2_DTLP = ' ' and @IN_TPLIVRO = 'A' begin"+CRLF
cQuery += "       	If @IN_PRODCUSTO = '0' select @cCT2_CCD = ' '"+CRLF
cQuery += "          exec "+aProc[6]+" @IN_FILIAL, @IN_CODREV,   @cChave,      @cCT2_LINHA, @cCT2_DEBITO, @cCT2_CCD, @cDc, @cCT2_HP, @cCT2_HIST,"+CRLF
cQuery += "          	              @nCT2_VALOR,0 ,@nVlrMoedFu, "+ aCs0[18] +","+ aCs0[19] +",  @cCT2_CODPAR, @cCSB_NUMARQ, @cCT2_DATA, @IN_PRODCUSTO, @IN_ENTREF, @iRecnoD OutPut "+CRLF
cQuery += "   	end"+CRLF
cQuery += "   "+CRLF
cQuery += "   	If @IN_TPLIVRO != 'A' begin "+CRLF
cQuery += "       	If @IN_PRODCUSTO = '0' select @cCT2_CCD = ' '"+CRLF
cQuery += "          exec "+aProc[6]+" @IN_FILIAL, @IN_CODREV,   @cChave,      @cCT2_LINHA, @cCT2_DEBITO, @cCT2_CCD, @cDc, @cCT2_HP, @cCT2_HIST,"+CRLF
cQuery += "                            @nCT2_VALOR,0 ,@nVlrMoedFu, "+ aCs0[18] +","+ aCs0[19] +",  @cCT2_CODPAR, @cCSB_NUMARQ, @cCT2_DATA, @IN_PRODCUSTO, @IN_ENTREF, @iRecnoD OutPut "+CRLF
cQuery += "   	end"+CRLF
cQuery += "   end"+CRLF

//-----------------
// Grava CREDITOS
//----------------- 
cQuery += "      If (( @cCT2_DC = '2' or @cCT2_DC = '3') and ( @cCT2_CREDIT between @IN_CONTAI and @IN_CONTAF )) begin"+CRLF
cQuery += "         select @cDc = 'C'"+CRLF      
If cModEsc == "FCO"
	cQuery += "         select @cCSB_NUMARQ = @cCT2_FILIAL||@cCT2_DATA||@cCT2_LOTE||@cCT2_SBLOTE||@cCT2_TPSALD||@cCT2_DOC||@cCT2_LINHA||@cCT2_SEQLAN||@cDc||@cCT2_MOEDLC||@cCT2_TPSALD||@cCT2_EMPORI||@cCT2_FILORI"+CRLF
Else
	cQuery += "         select @cCSB_NUMARQ = @cCT2_FILIAL||@cCT2_DATA||@cCT2_LOTE||@cCT2_SBLOTE||@cCT2_DOC||@cCT2_LINHA||@cCT2_SEQLAN||@cDc||@cCT2_MOEDLC||@cCT2_TPSALD||@cCT2_EMPORI||@cCT2_FILORI"+CRLF
Endif
cQuery += "   select @nVlrMoedFu = CT2_VALOR FROM "+RetSqlName("CT2")+" WHERE CT2_FILIAL = '"+ xFilial("CT2") +"' and CT2_DATA = @cCT2_DATA and CT2_LOTE = @cCT2_LOTE and CT2_SBLOTE = @cCT2_SBLOTE and CT2_DOC = @cCT2_DOC and CT2_DC = @cCT2_DC and CT2_LINHA = @cCT2_LINHA and CT2_MOEDLC = '" +aCs0[2]+"'"+CRLF
cQuery += "   "+CRLF
cQuery += "		If @cCT2_DTLP = ' '  and @IN_TPLIVRO = 'A' begin"+CRLF
cQuery += "			If @IN_PRODCUSTO = '0' select @cCT2_CCD = ' '"+CRLF
cQuery += "			exec "+aProc[6]+" @IN_FILIAL, @IN_CODREV,   @cChave,      @cCT2_LINHA, @cCT2_CREDIT, @cCT2_CCC, @cDc, @cCT2_HP, @cCT2_HIST,"+CRLF
cQuery += "         	              @nCT2_VALOR,0 ,@nVlrMoedFu, "+ aCs0[18] +","+ aCs0[19] +",  @cCT2_CODPAR, @cCSB_NUMARQ, @cCT2_DATA, @IN_PRODCUSTO, @IN_ENTREF, @iRecnoC OutPut"+CRLF
cQuery += "		end"+CRLF
cQuery += "   "+CRLF

cQuery += "   	If @IN_TPLIVRO != 'A' begin"+CRLF
cQuery += "   		If @IN_PRODCUSTO = '0' select @cCT2_CCD = ' '"+CRLF
cQuery += "			exec "+aProc[6]+" @IN_FILIAL, @IN_CODREV,   @cChave,      @cCT2_LINHA, @cCT2_CREDIT, @cCT2_CCC, @cDc, @cCT2_HP, @cCT2_HIST,"+CRLF
cQuery += "      	                  @nCT2_VALOR,0 ,@nVlrMoedFu, "+ aCs0[18] +","+ aCs0[19] +",  @cCT2_CODPAR, @cCSB_NUMARQ, @cCT2_DATA, @IN_PRODCUSTO, @IN_ENTREF, @iRecnoC OutPut"+CRLF
cQuery += "		end"+CRLF
cQuery += "   end"+CRLF

cQuery += "      If @cCT2_DC = '4' begin"+CRLF
cQuery += "         If @iRecnoD > 0 begin"+CRLF
           
cQuery += "            UpDate "+RetSqlName("CSB")+CRLF

If Alltrim(Upper(TcGetDb())) = 'INFORMIX'
	cQuery += "               Set CSB_HISTOR = Substring( trim(CSB_HISTOR)||' '||trim(@cCT2_HIST),1," + StrZero(TamSx3('CSB_HISTOR' )[1], 3) + ")" +CRLF
Else
	cQuery += "               Set CSB_HISTOR = Substring( Rtrim(Ltrim(CSB_HISTOR))||' '||Rtrim(ltrim(@cCT2_HIST)),1," + StrZero(TamSx3('CSB_HISTOR' )[1], 3) + ")" +CRLF
EndIf

cQuery += "             Where R_E_C_N_O_ = @iRecnoD"+CRLF
cQuery += "         End"+CRLF

cQuery += "         If @iRecnoC > 0 begin"+CRLF
           
cQuery += "            UpDate "+RetSqlName("CSB")+CRLF

If Alltrim(Upper(TcGetDb())) = 'INFORMIX'
	cQuery += "               Set CSB_HISTOR = Substring( trim(CSB_HISTOR)||' '||trim(@cCT2_HIST),1," + StrZero(TamSx3('CSB_HISTOR' )[1], 3) + ")" +CRLF
Else
	cQuery += "               Set CSB_HISTOR = Substring( Rtrim(Ltrim(CSB_HISTOR))||' '||Rtrim(ltrim(@cCT2_HIST)),1," + StrZero(TamSx3('CSB_HISTOR' )[1], 3) + ")" +CRLF
EndIf

cQuery += "             Where R_E_C_N_O_ = @iRecnoC"+CRLF
cQuery += "         End"+CRLF
cQuery += "      End"+CRLF
cQuery += "      End"+CRLF
/* --------------------------------------------------------------
	Salva a chave anterior
   -------------------------------------------------------------- */
cQuery += "      select @cChvCSBAnt =  @cCT2_FILIAL||@cCT2_DATA||@cCT2_LOTE||@cCT2_SBLOTE||@cCT2_DOC||@cCT2_LINHA||@cCT2_EMPORI||@cCT2_FILORI"+CRLF
cQuery += "      If @iNroRegs1 >= 10000 begin"+CRLF
cQuery += "         commit tran"+CRLF
cQuery += "         select @iNroRegs1 = 0"+CRLF
cQuery += "      End"+CRLF
   
If Alltrim(Upper(TcGetDb())) $ 'DB2|DB2/400'
	cQuery += "      SELECT @fim_CUR = 0"+CRLF
EndIf
cQuery += "      Fetch CUR_PROCMOV into @cCT2_FILIAL, @cCT2_DATA,   @cCT2_LOTE,  @cCT2_SBLOTE, @cCT2_DOC,    @cCT2_SEQLAN, @cCT2_EMPORI, @cCT2_FILORI, "+CRLF
cQuery += "                             @cCT2_MOEDLC, @cCT2_SEQHIS, @cCT2_LINHA, @cCT2_DC,     @cCT2_DEBITO, @cCT2_CREDIT, @cCT2_HP,     @cCT2_HIST,"+CRLF
cQuery += "                             @cCT2_CCD,    @cCT2_CCC,    @cCT2_DTLP,  @cCT2_TPSALD, @nCT2_VALOR,  @cCT2_CODPAR"+CRLF
      
cQuery += "   End"+CRLF
cQuery += "   Close CUR_PROCMOV"+CRLF
cQuery += "   Deallocate CUR_PROCMOV"+CRLF
   
cQuery += "   If @iNroRegs1 > 0 begin"+CRLF
cQuery += "      commit tran"+CRLF
cQuery += "      select @iTranCount = 0"+CRLF
cQuery += "   End"+CRLF
   
cQuery += "   select @OUT_RESULT = '1'"+CRLF
cQuery += "End"+CRLF

cQuery := CtbAjustaP(.T., cQuery, @nPTratRec)
cQuery := MsParse(cQuery,If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
cQuery := CtbAjustaP(.F., cQuery, nPTratRec)

If !TCSPExist( cProc )
	nRet := TcSqlExec(cQuery)
	If nRet != 0 
		If !__lBlind
			MsgAlert(STR0064+cProc)//'Erro na criacao da procedure de Exportacao de Movimento '
			lRet:= .F.
		EndIf
	EndIf
EndIf

RestArea(aArea)
Return lRet

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณECDNivCta   ณ Autor ณ eduardo.flima        ณ Data ณ 25.05.2016		ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Retorna o nivel da conta  E grava  contas sinteticas                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ ECDNivCta()                                                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SigaCtb                                                   			ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ cConta 	   = Codigo da conta                            		   	ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ECDNivCta(cConta,lDtExis,dDataRef,axFil)

Local aSaveArea	:= GetArea()

Local nNivel	:= 1
Local nDefNiv	:= 1 
Local nRecno	:= CT1->(Recno())
Local nAtuRec	:= 0
Local aCtaGrv  	:= {}
Local nX 		:= 1

Default cConta		:= ''
Default lDtExis		:= .T.
Default dDataRef	:= ctod("")
Default axFil		:= {}

dbSelectArea("CT1")       
dbSetOrder(1)
If MsSeek(xFilial()+cConta)	
	While !Eof() .And. CT1->CT1_FILIAL == xFilial() .And. !Empty(CT1->CT1_CTASUP)
		If MsSeek(xFilial()+CT1->CT1_CTASUP)	    	
			If Ascan( aCtaSup[01] , CT1->CT1_CONTA )==0
				Aadd(aCtaGrv,{})
				Aadd(aCtaGrv[nNivel] , xFilial("CS3") )
				Aadd(aCtaGrv[nNivel] , __CodRev)
				Aadd(aCtaGrv[nNivel] , CT1->CT1_CONTA )
				Aadd(aCtaGrv[nNivel] , CT1->CT1_CTASUP )
				Aadd(aCtaGrv[nNivel] , CT1->CT1_DESC01 )
				Aadd(aCtaGrv[nNivel] , CT1->CT1_NTSPED )
				Aadd(aCtaGrv[nNivel] , IIF( CT1->CT1_CLASSE == '1' , 'S' , 'A' ) )
				Aadd(aCtaGrv[nNivel] , IIF( lDtExis .And. ! Empty( CT1->CT1_DTEXIS ), CT1->CT1_DTEXIS, CTOD( "01/01/1980" ) ))
				Aadd(aCtaGrv[nNivel] , CT1->CT1_SPEDST )
				Aadd(aCtaGrv[nNivel] , CT1->CT1_NORMAL )
			Endif
			nNivel++
 		Else
 			dbSkip()
		EndIf	
	End
	nDefNiv:=nNivel
	nNivel:=nNivel-LEN(aCtaGrv)
	nX:=0
	While nX <  LEN(aCtaGrv)
		nAtuRec:= CT1->(Recno())
		RecLock( "CS3" , .T. )
		CS3->CS3_FILIAL := aCtaGrv[LEN(aCtaGrv)-nX][1]
		CS3->CS3_CODREV	:= aCtaGrv[LEN(aCtaGrv)-nX][2]
		CS3->CS3_CONTA	:= aCtaGrv[LEN(aCtaGrv)-nX][3]
		CS3->CS3_CTASUP	:= aCtaGrv[LEN(aCtaGrv)-nX][4]
		CS3->CS3_NOMECT	:= aCtaGrv[LEN(aCtaGrv)-nX][5]
		CS3->CS3_CODNAT	:= aCtaGrv[LEN(aCtaGrv)-nX][6]
		CS3->CS3_NIVEL	:= nNivel
		CS3->CS3_INDCTA	:= aCtaGrv[LEN(aCtaGrv)-nX][7]
		CS3->CS3_DTALT	:= aCtaGrv[LEN(aCtaGrv)-nX][8]
		//Tratamento da contas sinteticas do registro I015
		If CT1->( FieldPos("CT1_SPEDST") ) > 0
			CS3->CS3_CTASIN	:= aCtaGrv[LEN(aCtaGrv)-nX][9]
		EndIf

		If CS3->( FieldPos("CS3_NORMAL") ) > 0
			CS3->CS3_NORMAL	:= aCtaGrv[LEN(aCtaGrv)-nX][10]
		EndIf		
		
		Aadd(aCtaSup[1] , aCtaGrv[LEN(aCtaGrv)-nX][3] )
		Aadd(aCtaSup[2] , nX+1 )
		MsUnLock()
		nNivel++
		nX++
	End
EndIf

dbSelectArea("CT1")
dbGoto(nRecno)

RestArea(aSaveArea)

Return(nDefNiv)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEcdSubCQ1 บAutor  ณEduardo.fLima       บ Data ณ  25/05/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna SubQuery para que verificar contas sem saldo        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function EcdSubCQ1(dDataFin,dDataIni,cMoeda,cSaldo,axFil,lConsMovZer,cTmpFil)
Local cQuery := ""
Local cWhere := ""

Default dDataFin	:= Ctod("")
Default dDataIni	:= Ctod("")
Default cMoeda		:= ''
Default cSaldo		:= ''
Default axFil		:= {}
Default lConsMovZer	:= .F. // Considera somente contas movimentadas?
Default cTmpFil		:= " "	

CQ1->(dbSeek("CQ1"))

cQuery := "( SELECT CQ1_CONTA" 
cQuery += "	FROM ( "
cQuery += "			SELECT CQ1.CQ1_CONTA, SUM(CQ1.CQ1_DEBITO - CQ1.CQ1_CREDIT) VALOR "
cQuery += "			FROM " + RetSqlName( "CQ1" ) + " CQ1 "
cQuery += "			WHERE CQ1.CQ1_FILIAL " + GetRngFil( aXFil, "CQ1", .T.,@cTmpFil)

If !Empty(dDataIni)
	cQuery += "			  AND CQ1.CQ1_DATA >= '" + DTOS(dDataIni) + "'" 
EndIf

If !Empty(dDataFin)
	cQuery += "			  AND CQ1.CQ1_DATA <= '" + DTOS(dDataFin) + "'" 
EndIf

cQuery += "			  AND CQ1.CQ1_MOEDA = '" + cMoeda + "'"  
cQuery += "			  AND CQ1.CQ1_TPSALD = '" + cSaldo + "'" 
cQuery += "			  AND CQ1.D_E_L_E_T_ = ' ' "
cQuery += "			GROUP BY CQ1.CQ1_CONTA"
cQuery += "		) CQ11" 

If !lConsMovZer
	cQuery += "	WHERE CQ11.VALOR <> 0"
Endif

cQuery += ")

Return(cQuery)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma ณEcdSubCT3 บAutor  ณAndre.Luiz          บ Data ณ  05/05/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.    ณRetorna SubQuery para que verificar centro de custo sem saldoบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso      ณ AP                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function EcdSubCQ3(dDataFin,dDataIni,cMoeda,cSaldo,axFil, lConsMovZer,cTmpFil)

Local cQuery := ""
Local cWhere := ""

Default dDataFin	:= Ctod("")
Default dDataIni	:= Ctod("")
Default cMoeda		:= ''
Default cSaldo		:= ''
Default axFil		:= {}
Default lConsMovZer	:= .F.
Default cTmpFil		:= " "	

CT3->(dbSeek("CQ3"))

cQuery := "( SELECT CQ3_CONTA" 
cQuery += "	FROM ( "
cQuery += "			SELECT CQ3.CQ3_CONTA,CQ3.CQ3_CCUSTO, SUM(CQ3.CQ3_DEBITO - CQ3.CQ3_CREDIT) VALOR "
cQuery += "			FROM " + RetSqlName( "CQ3" ) + " CQ3 "
cQuery += "			WHERE CQ3.CQ3_FILIAL " + GetRngFil( aXFil, "CQ3",.T.,@cTmpFil) 

If !Empty(dDataIni)
	cQuery += "			  AND CQ3.CQ3_DATA >= '" + DTOS(dDataIni) + "'" 
EndIf

If !Empty(dDataFin)
	cQuery += "			  AND CQ3.CQ3_DATA <= '" + DTOS(dDataFin) + "'" 
EndIf

cQuery += "			  AND CQ3.CQ3_MOEDA = '" + cMoeda + "'"  
cQuery += "			  AND CQ3.CQ3_TPSALD = '" + cSaldo + "'" 
cQuery += "			  AND CQ3.D_E_L_E_T_ = ' ' "
cQuery += "			GROUP BY CQ3.CQ3_CONTA,CQ3.CQ3_CCUSTO"
cQuery += "		) CQ31" 

If !lConsMovZer
	cQuery += "	WHERE CQ31.VALOR <> 0"
Endif

cQuery += ")

Return(cQuery)
/*/{Protheus.doc} GoYear

Muda data de acordo com os parโmetros passados

@author TOTVS
@since 07/02/2019
@version P12.1.25
/*/
Static Function GoYear(dDate,nYear)
Local dDateAux := ""

dDateAux := Ctod(Left(Dtoc(dDate), 6) + Str(Year(dDate) + nYear, 4))

If Empty( dDateAux )
	If MONTH(dDate) == 2
		If Day(dDate) > 28 .and. Day(dDate) == 29
			dDateAux := Ctod(Left( STRTRAN( Dtoc(dDate) , "29" , "28" ), 6) + Str(Year(dDate) + nYear, 4))
		EndIf
	EndIf
EndIf

Return dDateAux
/*/{Protheus.doc} ECDGrvDem

Grava tabelas CSD e CSE

@author TOTVS
@since 07/02/2019
@version P12.1.25
/*/
Static Function ECDGrvDem(oProcess, cCodVis, dDtDemIni, dDtDemFim, nCabDem, lLeiaute2, cModEsc, cPeriodo, cRegist, cIdBloco_V, cCodInstFi,aSetOfBook)
Local nSaldTmp		:= 0
Local nSaldIni 		:= 0
Local nSaldFim 		:= 0
Local aVisao		:= {}
Local lGrvVisOrd	:= GetNewPar("MV_GRVISOR",.F.) //Grava o c๓digo de aglutina็ใo com a Ordem da Visใo
Local lDMPL			:= .F.	
Default cCodVis     := ""
Default dDtDemIni	:= StoD("")
Default dDtDemFim   := StoD("")
Default nCabDem		:= 0
Default lLeiaute2	:= .T.
Default cModEsc 	:= 'ECD'
Default cPeriodo 	:= ''
Default cRegist		:= ''
Default cIdBloco_V 	:= ""
Default cCodInstFi 	:= ""
Default aSetOfBook	:= {}

lDMPL := (nCabDem == ECD_DMPL .Or. nCabDem == ECD_DLPA )

dbSelectArea("cArqTmp")
dbGotop()

If cArqTmp->( !Eof() )
	CSD->(RecLock("CSD",.T.))
		CSD->CSD_FILIAL := xFilial("CSD")
		CSD->CSD_CODREV := __CodRev
		CSD->CSD_CODVIS := cCodVis
		CSD->CSD_DTINI  := ddtdemini
		CSD->CSD_DTFIN  := ddtdemfim
		CSD->CSD_TPDEM  := cValToChar(nCabDem)
		
		If cModEsc == 'ECF'
			CSD->CSD_REGIST	 := cRegist
			CSD->CSD_PERIOD	 := cPeriodo
			
			If cRegist == 'V100'
				CSD->CSD_IDBLV	 := cIdBloco_V
				CSD->CSD_CDINST	 := cCodInstFi
			EndIf
			
		ElseIf cModEsc == 'ECD' 
		
			If  lPerCalTri			
				CSD->CSD_PERIOD	 := cPeriodo
			EndIf
		
			If nCabDem == ECD_BALANCO
				CSD->CSD_REGIST := "J100"
			ElseIf nCabDem == ECD_DRE
				CSD->CSD_REGIST := "J150"
			ElseIf lDMPL
				CSD->CSD_REGIST := "J210"
			EndIf

		EndIf		
	CSD->(MsUnLock())
EndIf

While cArqTmp->( !Eof() )
	
	If cModEsc == 'ECF'
		If cRegist == 'V100'
			nSaldTmp := ( cArqTmp->SALDOCRD - cArqTmp->SALDODEB ) 
		Else
			nSaldTmp := cArqTmp->SALDOATU
		EndIf
		nSaldIni := cArqTmp->SALDOANT
		nSaldFim := cArqTmp->SALDOATU
	Else
		If nCabDem == ECD_DRE
			nSaldTmp := cArqTmp->(SALDOATU-SALDOANT)
			nSaldIni := cArqTmp->(SALDOANT)
		ElseIf nCabDem == ECD_BALANCO
			nSaldTmp := cArqTmp->SALDOATU
			nSaldIni := cArqTmp->SALDOANT
		ElseIf lDMPL
			nSaldTmp := cArqTmp->SALDOATU
			nSaldIni := cArqTmp->SALDOANT	
		ElseIf nCabDem == ECD_DFC
			nSaldTmp := cArqTmp->(SALDOATU-SALDOANT)
			nSaldIni := cArqTmp->SALDOANT
			nSaldFim := cArqTmp->SALDOATU
		ElseIf nCabDem == ECD_DVA
			nSaldTmp := cArqTmp->SALDOATU
			nSaldIni := cArqTmp->SALDOANT
		EndIf
	Endif
	
	If !Empty( cArqTmp->CONTA )
		CSE->(RecLock("CSE",.T.))		
			If oProcess <> Nil
				If cModEsc == 'ECF'
					oProcess:IncRegua2( "Perํodo: " + cPeriodo + " / Conta: " + AllTrim(Str(Val(cArqTmp->CONTA))) ) 
				Else					
					If nCabDem == ECD_DRE
						oProcess:IncRegua2(STR0036 + STR0039)
					ElseIf nCabDem == ECD_BALANCO
						oProcess:IncRegua2(STR0036 + STR0040)
					ElseIf nCabDem == ECD_DLPA
						oProcess:IncRegua2(STR0036 + "( DLPA )")
					ElseIf nCabDem == ECD_DMPL
						oProcess:IncRegua2(STR0036 + "( DMPL )")
					ElseIf nCabDem == ECD_DFC
						oProcess:IncRegua2(STR0036 + "( DFC )")
					ElseIf nCabDem == ECD_DVA
						oProcess:IncRegua2(STR0036 + "( DVA )")
					Else
						oProcess:IncRegua2( STR0036 )
					EndIf												
				EndIf
			EndIf
			CSE->CSE_FILIAL  := xFilial("CSE")
			CSE->CSE_CODREV  := __CodRev
			CSE->CSE_CODVIS  := cCodVis
			
			If cModEsc == 'ECF'
				CSE->CSE_CODAGL := cArqTmp->CONTA
			Else
				If lGrvVisOrd .And. !lDMPL
					CSE->CSE_CODAGL := aSetOfBook[5] + cArqTmp->ORDEM
					aAdd(aVisao,{cArqTmp->CONTA, cArqTmp->ORDEM})     				
					CSE->CSE_AGLSUP := cArqTmp->SUPERIOR	
				Else
					CSE->CSE_CODAGL := aSetOfBook[5] + cArqTmp->CONTA
					If !Empty(cArqTmp->SUPERIOR)
						CSE->CSE_AGLSUP := aSetOfBook[5] + cArqTmp->SUPERIOR
					EndIf	
				EndIf	
			EndIf		

			CSE->CSE_TPDEM    := cValToChar(nCabDem)
			CSE->CSE_NIVEL    := cArqTmp->NIVEL
			CSE->CSE_DESCRI   := cArqTmp->DESCCTA
			CSE->CSE_INDVAL   := Iif( nSaldTmp >= 0 , 'C'  , 'D'  )			
			CSE->CSE_VALOR	  := ABS( nSaldTmp )
			CSE->CSE_CLASSE   := cArqTmp->TIPOCONTA
			CSE->CSE_INDAGL   := IIf(cArqTmp->TIPOCONTA=="1","T","D")
			
			If cModEsc == 'ECF'
				CSE->CSE_NATCTA := cArqTmp->NATCTA
				CSE->CSE_CTASUP := cArqTmp->SUPERIOR
				CSE->CSE_PERIOD	:= cPeriodo
				CSE->CSE_REGIST	:= cRegist
				CSE->CSE_VALDEB	  := cArqTmp->SALDOATUDB 
				CSE->CSE_VALCRE	  := cArqTmp->SALDOATUCR
				
				If cRegist == 'V100'
					CSE->CSE_IDBLV	 := cIdBloco_V
					CSE->CSE_CDINST	 := cCodInstFi
				EndIf
			ElseIf cModEsc == 'ECD' .And. lPerCalTri
				CSE->CSE_PERIOD	:= cPeriodo
			EndIf
			
			If cModEsc == 'ECD' .And. nCabDem == ECD_DRE 
				If lLeiaute7
					CSE->CSE_INDDRE := IIF( nSaldTmp < 0 , "D" , "R" )				
					CSE->CSE_INDVAL := IIF( nSaldTmp < 0 , "D" , "C" )		
				Else
					CSE->CSE_INDVAL  := IIF( cArqTmp->IDENTIFI > "2" , IIF( nSaldTmp < 0 , "N" , "P" ) , IIF( nSaldTmp < 0 , "D" , "R" ))		
				EndIf
			ElseIf cModEsc == 'ECF'				
				CSE->CSE_INDVAL  := IIF( cArqTmp->IDENTIFI > "2" , IIF( nSaldTmp < 0 , "N" , "P" ) , IIF( nSaldTmp < 0 , "D" , "R" ))
			Endif
			
			If lLeiaute2
				CSE->CSE_VLRINI	:= ABS( nSaldIni )
				CSE->CSE_INDINI  := IIF( nSaldIni < 0, "D" , "C" )
				
				IF cModEsc == "ECD" .And. nCabDem == ECD_DRE .And. !lLeiaute7
					CSE->CSE_INDINI  := IIF( cArqTmp->IDENTIFI > "2" , IIF( nSaldINI < 0 , "N" , "P" ) , IIF( nSaldIni < 0 , "D" , "R" )) //Campo nใo utilizado no ECD
				Endif

				IF nCabDem == ECD_DFC
					//saldo final vai estar na coluna propria para DFC 
					CSE->CSE_VLRFIM	:= ABS( nSaldFim )
					CSE->CSE_INDFIM  := IIF( nSaldFim < 0, "D" , "C" )
				
					IF  Left(cArqTmp->DESCCTA,3) == "(+)"				
						CSE->CSE_TIPOPE :=  "A"
					ElseIF  Left(cArqTmp->DESCCTA,3) == "(-)"				
						CSE->CSE_TIPOPE :=  "S"
					ElseIF   cArqTmp->IDENTIFI > "2"			
						CSE->CSE_TIPOPE :=  IIF( nSaldINI < 0 , "N" , "P" )
					Else
						CSE->CSE_TIPOPE :=  "L"
					EndIf
					CSE->CSE_INDSLD := "SF"  //SALDO FINAL
				EndIf
			End
			
			If cModEsc == 'ECF'
				CSE_VLRINI	:= ABS( nSaldIni )
				CSE_INDINI  := IIF( nSaldIni < 0, "D" , "C" )
				CSE_VLRFIM	:= ABS( nSaldFim )
				CSE_INDFIM  := IIF( nSaldFim < 0, "D" , "C" )				
			Endif
		
		CSE->(MsUnLock())
		
	EndIf		
	cArqTmp->(dbSkip())
EndDo

If lGrvVisOrd .And. !lDMPL
	CtbGrvSup(aVisao,__CodRev,cCodVis,aSetOfBook)
EndIf

dbSelectArea( "cArqTmp" )
dbCloseArea()
asize(aVisao, 0)
aVisao := NIL

Return
/*/{Protheus.doc} ExpDemTri

Exporta demonstrativos trimestrais

@author TOTVS
@since 08/02/2019
@version P12.1.25
/*/
Static Function ExpDemTri(cCodRev,aPerCalTri,oProcess,aFilsAux,cCodVisao,cMoeda,cTpSaldo,dDtDemIni,dDtDemFim,nTpVisao,cCalendario)
Local lRet := .T.
Local nI   := 0

Default cCodRev		:= ""
Default aPerCalTri 	:= {}
Default aFilsAux	:= {}
Default cCodVisao	:= ""
Default cMoeda		:= ""
Default cTpSaldo	:= ""
Default dDtDemIni	:= StoD("")
Default dDtDemFim	:= StoD("")
Default nTpVisao	:= 0
Default cCalendario	:= ""

For nI := 1 to Len(aPerCalTri)
	lRet := ExportaDemonst( oProcess, aFilsAux, cCodVisao, cMoeda, cTpSaldo,; 
							aPerCalTri[nI,1]/*Data INI*/, aPerCalTri[nI,2]/*Data FIM*/,;
							aPerCalTri[nI,1]/*Data Dem INI*/, aPerCalTri[nI,2]/*Data Dem FIM*/,;
							aPerCalTri[nI,2]/*Data LP*/, nTpVisao, cCalendario,nil,nil,"T"+StrZero(nI,2))
Next nI

Return lRet
/*/{Protheus.doc} CtbsSel()
Chama a tela para informar o J800 e J801

@author TOTVS
@since 05/02/2018
@version P12.1.17
/*/
Function CtbGRVJ800()
Local aArea := {}

If CS0->CS0_ECDREV == "ECD"
	If AllTrim(CS0->CS0_TIPLIV)$"A/Z"
		MsgAlert(STR0081) //"Op็ใo nใo disponํvel para o tipo de livro selecionado."
	Else		
		If Val(CS0->CS0_LEIAUT) >= 7
			aArea := GetArea()
			
			CTBS070()
			
			RestArea(aArea)
		Else
			MsgAlert(STR0079)//"Op็ใo disponํvel somente a partir do leiaute 7."
		EndIf
	EndIf
Else
	MsgAlert(STR0080)//"Op็ใo disponํvel somente para o ECD."
EndIf

Return

                        
/*/{Protheus.doc} Exist_CSQ()

Verifica alias CSQ se existe e campos de data extemporaneo

@author TOTVS
@since 26/02/2019
@version P12.1.25
/*/
Static Function Exist_CSQ()
Local lRet := .F.

lRet := FwAliasInDic('CSQ')

lRet := lRet .And. CSQ->( FieldPos("CSQ_DTEXT") ) > 0

lRet := lRet .And. CSA->( FieldPos("CSA_DTEXT") ) > 0
 
lRet := lRet .And. CSB->( FieldPos("CSB_DTEXT") ) > 0

Return( lRet )
/*/{Protheus.doc} CTBFindCSQ()

Verifica alias CSQ se existe e campos de data extemporaneo

@author TOTVS
@since 15/03/2019
@version P12.1.25
/*/
Static Function CTBFindCSQ(cDtLcto,cLote,cSubLot,cDocto,cDtExt)
Local lRet       := .F.
Local lExisDtExt := .F.

Local aArea      := GetArea()
Local aAreaCSQ   := CSQ->( GetArea() )

DEFAULT cDtLcto  := ""
DEFAULT cLote	 := ""
DEFAULT cSubLot  := ""
DEFAULT cDocto	 := ""
DEFAULT cDtExt	 := ""

CSQ->( dbSetOrder(1) )

If Empty(cDtExt)
	lRet := CSQ->( dbSeek( xFilial("CSQ")+cDtLcto+cLote+cSbLote+cDocto ) )
Else
	If CSQ->( ! dbSeek(xFilial("CSQ")+cDtLcto+cLote+cSbLote+cDocto))
		lRet := .T.   //SE NAO ENCONTRADO RETORNA .T.
	Else
		lExisDtExt := .F.  //ACHOU DOC MAS AINDA NAO AVALIOU DT EXTEMP
		//SE ENCONTROU REGISTROS NA MESMA CHAVE TEM QUE VERIFICAR SE EXISTE A DATA E CASO EXISTA RETORNA FALSO
		While CSQ->( !Eof() .And. CSQ_FILIAL+DTOS( CSQ_DATA )+CSQ_LOTE+CSQ_SBLOTE+CSQ_DOC == xFilial("CSQ")+cDtLcto+cLote+cSbLote+cDocto )

			If DTOS(CSQ->CSQ_DTEXT) == cDtExt
				lExisDtExt := .T.  //SE ENCONTROU A DATA
				EXIT
			EndIf

			CSQ->( dbSkip() )
		EndDo

		lRet := ! lExisDtExt //SE TEM A DATA DO EXTEMPORANEO INFORMADO NA BASE DEVE RETORNAR FALSO
		
	EndIf

EndIf

RestArea(aAreaCSQ)
RestArea(aArea)

Return lRet 

/*/{Protheus.doc} CtbGrvSup()

Grava c๓digo de aglutina็ใo de acordo com a ordem

@author TOTVS
@since 15/03/2019
@version P12.1.25
/*/
Static Function CtbGrvSup(aVisao,cCodRev,cCodVis,aSetOfBook)
Local aAreaCSE  :=  CSE->(GetArea())
Local aAreaCS6  :=  CS6->(GetArea())
Local nPos1			:= 0
Local nPos2			:= 0
Local cSQL      := ""
Local cSetOfBook:= ""

DEFAULT aVisao	:= {}
DEFAULT cCodRev	:= ""
DEFAULT cCodVis := ""
DEFAULT aSetOfBook := {}

cCodVis := PadR(cCodVis,TamSX3("CSE_CODVIS")[1])
cSetOfBook := aSetOfBook[5]

CSE->(dbSetOrder(1))
If CSE->(dbSeek(xFilial("CSE")+cCodRev+cCodVis))
	While !CSE->(Eof()) .And. CSE->(CSE_FILIAL+CSE_CODREV+CSE_CODVIS) == xFilial("CSE")+cCodRev+cCodVis
		If !Empty(CSE->CSE_AGLSUP)
			nPos1 := aScan(aVisao, {|x| AllTrim(x[1])== AllTrim(CSE->CSE_AGLSUP)})
			If ( nPos1 > 0 )
					CSE->(RecLock("CSE",.F.))
						CSE->CSE_AGLSUP := cSetOfBook + aVisao[nPos1,2]
					CSE->(MsUnLock())
			EndIf
		EndIf
		CSE->(dbSkip())
	EndDo
Endif

cSQL := " SELECT "
cSQL += "  	CS6_CODAGL, CS6_AGLSUP, R_E_C_N_O_ REC"
cSQL += " 	FROM "
cSQL +=  			RetSQLName("CS6")
cSQL += " 		WHERE "
cSQL += " 			CS6_FILIAL = '"+xFilial("CS6")+"' AND "
cSQL += " 			CS6_CODREV = '"+cCodRev+"' AND "
cSQL += " 			SUBSTRING(CS6_CODAGL, 1,"+cValToChar(Len(cSetOfBook))+") = '"+cSetOfBook+"' AND "
cSQL += " 			D_E_L_E_T_  = ' ' "

cSQL := ChangeQuery(cSQL)

cTRBCS6 := GetNextAlias()
dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cSQL), cTRBCS6 )

While !(cTRBCS6)->(Eof())
	
		nPos1 := aScan(aVisao, {|x| AllTrim(cSetOfBook+x[1]) == AllTrim((cTRBCS6)->CS6_CODAGL) })
		nPos2 := aScan(aVisao, {|x| AllTrim(x[1]) == AllTrim((cTRBCS6)->CS6_AGLSUP)})
		
		CS6->(dbGoTo((cTRBCS6)->REC))
		CS6->(RecLock("CS6",.F.))
			If ( nPos1 > 0 )
					CS6->CS6_CODAGL := cSetOfBook + aVisao[nPos1,2]					
			EndIf
			If ( nPos2 > 0 )
					CS6->CS6_AGLSUP := aVisao[nPos2,2]					
			EndIf
		CS6->(MsUnLock())

	(cTRBCS6)->(dbSkip())	
EndDo
(cTRBCS6)->(dbCLoseArea())

RestArea(aAreaCS6)
RestArea(aAreaCSE)

Return 

/*/{Protheus.doc} CS011k210()
    Fun็ใo para composi็ใo das contas do bloco I050 (tabela CS3) a partir das
		contas do K210

    @type  Function
    @author Fernando Radu Muscalu
    @since 07/05/2019
    @version version
    
		@params	
			cIdBlocoK		- Caractere, c๓digo do cadastro do bloco K
			dDataRef		- Data, Data de refer๊ncia do ECD
			aUsoCtaRef	- Array, este array indica a gera็ใo do plano referencial do ECD
				aUsoCtaRef[1]	-L๓gico, indica se ้ plano referencial (.t.)
				aUsoCtaRef[2]	-L๓gico, indica se no plano referencial utiliza Centro de Custo
		
		@return Nil
		@see (links_or_references)
/*/
Function CS011k210(cIdBlocoK,dDataRef,aUsoCtaRef)

Local cQuery			:= ""
Local cTab				:= ""
Local cCodPla			:= ""
Local cVersao 		:= ""
Local nI					:= 0

Local aAreaCT1		:= CT1->(GetArea())
Local aAreaCVD 		:= CVD->(GetArea())
Local aTamFil			:= {0,0,0,0}
Local aResultSet	:= {}
Local aSeek				:= {}

Local lContaRef		:= .F.
Local lProcCusto	:= .f.	

Local oTabK210

Default aUsoCtaRef	:= {}

If ( !Empty(cS011CNPJ) )
	
	aTamFil := ECDFilLength()
	
	cQuery := "SELECT " + chr(13)
	cQuery += "	DISTINCT " + chr(13)
	cQuery += "	SUBSTRING(CQR_GRUFIL,"+cValToChar(aTamFil[1]+1)+","+cValToChar(aTamFil[2]+aTamFil[3]+aTamFil[4])+") FILIAL, " + chr(13)
	cQuery += "	CQV_CTAEMP " + chr(13)
	cQuery += "FROM " + chr(13)
	cQuery += "	" + RetSQLName("CQR") + " CQR " + chr(13)
	cQuery += "INNER JOIN " + chr(13)
	cQuery += "	" + RetSQLName("CQV") + " CQV " + chr(13)
	cQuery += "ON " + chr(13)
	cQuery += "	CQR_FILIAL = CQV_FILIAL " + chr(13)
	cQuery += "	AND CQR_IDBLK = CQV_IDBLK " + chr(13)
	cQuery += "	AND CQR_CODEMP = CQV_CODEMP " + chr(13)
	cQuery += "	AND CQV.D_E_L_E_T_ = '' " + chr(13)
	cQuery += "WHERE " + chr(13)
	cQuery += "	CQR_FILIAL = '" + xFilial("CQR") + "' " + chr(13)
	cQuery += "	AND CQR_IDBLK = '" + cIdBlocoK + "' " + chr(13)
	cQuery += "	AND	SUBSTRING(CQR_CNPJ,1,8) = '" + SubStr(cS011CNPJ,1,8) + "' " + chr(13)
	
	lContaRef := Len(aUsoCtaRef) > 0 .And. aUsoCtaRef[1]
	
	If ( !lContaRef )

		If ( !Empty(__CodRev) )

			cQuery += "AND CQV_CTAEMP NOT IN
			cQuery += "( " + chr(13)
			cQuery += "	SELECT " + chr(13)
			cQuery += "		CS3_CONTA CONTA " + chr(13)
			cQuery += "	FROM " + chr(13)
			cQuery += "		" + RetSQLName("CS3") + " CS3 " + chr(13)
			cQuery += "	WHERE" + chr(13)
			cQuery += "		CS3_FILIAL = '" + xfilial("CS3") + "' " + chr(13)
			cQuery += "		AND	CS3_CODREV = '" + __CodRev + "' " + chr(13)
			cQuery += "		AND CS3.D_E_L_E_T_ = '' " + chr(13)
			cQuery += ") " + chr(13)
		
		EndIf
	
	ElseIf ( aUsoCtaRef[1] .And. !Empty(__CodRev) )
		
		cQuery += "AND CQV_CTAEMP NOT IN
		cQuery += "( " + chr(13)
		cQuery += "	SELECT " + chr(13)
		cQuery += "		DISTINCT " + chr(13)
		cQuery += "		CS4_CONTA " + chr(13)
		cQuery += "	FROM " + chr(13)
		cQuery += "		" + RetSQLName("CS4") + " CS4 " + chr(13)
		cQuery += "	WHERE" + chr(13)
		cQuery += "		CS4_FILIAL = '" + xfilial("CS4") + "' " + chr(13)
		cQuery += "		AND	CS4_CODREV = '" + __CodRev + "' " + chr(13)
		cQuery += "		AND CS4.D_E_L_E_T_ = '' " + chr(13)
		cQuery += ") " + chr(13)	

	EndIf

	cQuery += "	AND CQR.D_E_L_E_T_ = '' "

	oTabK210	:= ATFTempTable(cQuery)
	cTab			:= oTabK210:GetAlias()

	If ( lContaRef )
	
		lProcCusto	:= aUsoCtaRef[2]
		cCodPla			:= aUsoCtaRef[3]
		cVersao 		:= aUsoCtaRef[4]
	
	EndIf

	While ( (cTab)->(!Eof()) )

		If ( !lContaRef )

			CT1->(DbSetOrder(1))

			If ( CT1->(DbSeek(xFilial("CT1",(cTab)->FILIAL) + (cTab)->CQV_CTAEMP )) )

					If ( !Empty( dDataRef ) .And. CT1->CT1_DTEXIS > dDataRef )
						(cTab)->( DbSkip() )			
						Loop			
					Endif

				nNivelCta := ECDNivCta(CT1->CT1_CONTA ,.T.,dDataRef)

				CS11RecCS3(__CodRev,nNivelCta,"CT1")
			
			EndIf
		
		Else

			aResultSet 	:= {}
			aSeek				:= {}

			aAdd(aSeek,{"CVD_FILIAL", XFilial("CVD",(cTab)->FILIAL)})
			aAdd(aSeek,{"CVD_CONTA", (cTab)->CQV_CTAEMP})
			aAdd(aSeek,{"CVD_CODPLA", cCodPla})
			aAdd(aSeek,{"CVD_VERSAO", cVersao})

			ATFSeekTable("CVD",aSeek,aResultSet)

			For nI := 2 to Len(aResultSet) 

				CVD->(dbGoTo(aResultSet[nI,Len(aResultSet[nI])]))

				CS11RecCS4(lProcCusto,"CVD")

			Next nI

		EndIf

		(cTab)->(DbSkip())

	End While

	oTabK210:Delete()

	FreeObj(oTabK210)

	RestArea(aAreaCT1)
	RestArea(aAreaCVD)

EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} CS11RecCS3
Fun็ใo para persistir os dados na tabela CS3

@params	cCodRev:		Caractere. C๓digo da Revisใo do ECD
				nNivelCta:	Num้rico. Nํvel da Conta Contแbil
				cAliasCT1:	Caractere. Alias da Tabela CT1 (pode ser ela mesma 
					ou uma tabela temporแria). Valor Padrใo: "CT1"	

@return nil
@author TOTVS
@since 07/05/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function CS11RecCS3(cCodRev,nNivelCta,cAliasCT1)

Default cAliasCT1 := "CT1"
DbSelectArea("CS3")
DbSetOrder(1)
If !DbSeek(xFilial("CS3")+ cCodRev + (cAliasCT1)->CT1_CONTA  )
	RecLock( "CS3" , .T. )

	CS3->CS3_FILIAL := xFilial("CS3")
	CS3->CS3_CODREV	:= cCodRev
	CS3->CS3_CONTA	:= (cAliasCT1)->CT1_CONTA
	CS3->CS3_CTASUP	:= (cAliasCT1)->CT1_CTASUP
	CS3->CS3_NOMECT	:= (cAliasCT1)->CT1_DESC01
	CS3->CS3_CODNAT	:= (cAliasCT1)->CT1_NTSPED
	CS3->CS3_NIVEL	:= nNivelCta
	CS3->CS3_INDCTA	:= IIF( (cAliasCT1)->CT1_CLASSE == '1' , 'S' , 'A' )
	CS3->CS3_DTALT	:= IIF( ! Empty( (cAliasCT1)->CT1_DTEXIS ), (cAliasCT1)->CT1_DTEXIS, CTOD( "01/01/1980" ) )
	CS3->CS3_CTASIN	:= (cAliasCT1)->CT1_SPEDST
	
	If CS3->( FieldPos("CS3_NORMAL") ) > 0
		CS3->CS3_NORMAL	:= (cAliasCT1)->CT1_NORMAL
	EndIf
	
	CS3->(MsUnLock())
EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} CS11RecCS4
Fun็ใo para persistir os dados na tabela CS4

@params	cCodRev:		Caractere. C๓digo da Revisใo do ECD
				nNivelCta:	Num้rico. Nํvel da Conta Contแbil
				cAliasCVD:	Caractere. Alias da Tabela CVD (pode ser ela mesma 
					ou uma tabela temporแria). Valor Padrใo: "CVD"	

@return nil
@author TOTVS
@since 07/05/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function CS11RecCS4(lProcCusto,cAliasCVD)

Default cAliasCVD	:= "CVD"

RecLock( "CS4", .T.)

		CS4->CS4_FILIAL	 	:= xFilial("CS4")
		CS4->CS4_CODREV  	:= __CodRev
		CS4->CS4_CONTA   	:= (cAliasCVD)->CVD_CONTA
		CS4->CS4_ENTREF  	:= (cAliasCVD)->CVD_ENTREF
		CS4->CS4_CTAREF  	:= (cAliasCVD)->CVD_CTAREF
		CS4->CS4_TPUTIL  	:= If(Empty ( (cAliasCVD)->CVD_TPUTIL ), "A", (cAliasCVD)->CVD_TPUTIL )	
		CS4->CS4_CLASSE 	:= (cAliasCVD)->CVD_CLASSE
		CS4->CS4_NATCTA 	:= (cAliasCVD)->CVD_NATCTA
		CS4->CS4_CTASUP 	:= (cAliasCVD)->CVD_CTASUP
				
		If lProcCusto
			CS4->CS4_CCUSTO  := (cAliasCVD)->CVD_CUSTO
		EndIf
				
	CS4->(MsUnLock())

Return()		
