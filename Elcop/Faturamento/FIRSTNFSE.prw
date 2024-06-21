#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "hbutton.ch"
#INCLUDE "Fisa022.ch" 

User Function FIRSTNFSE

	Local aArea := GetArea()

	aadd( aRotina , { "Impressao NFS-e"  , "U_RFUNA023" , 0 , 10 } )
//	aadd( aRotina , { "Transmitir Elcop"  , "U_FisElcop(.F.)" , 0 , 10 } )

	RestArea( aArea )

Return( aRotina )


user Function FisElcop(lUsaColab)

Local aArea		:= GetArea()
Local aPerg		:= {}   
Local aParam		:= {}

Local cAlias		:= "SF2"
Local cParTrans	:= if( type( "oSigamatX" ) == "U",SM0->M0_CODIGO + SM0->M0_CODFIL + "Fisa022Rem",oSigamatX:M0_CODIGO + oSigamatX:M0_CODFIL + "Fisa022Rem" )
Local cCodMun	:= if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN )
Local cNotasOk	:= ""
//Local cForca		:= ""            
Local cDEST			:= Space(10)
Local cMensRet		:= "" 
Local cMvPar06		:= ""
Local cNftMvPar6	:= ""
Local cWhen 		:= ".T."
Local cAmbNfse 		:= ""
//local cMsgAIDF 	:= ""

Local dDataIni		:= CToD('  /  /  ')
Local dDataFim  	:= CToD('  /  /  ')
LOCAL dData	 		:= Date()

Local lObrig		:= .T.
Local lNFT			:= .F.
Local lNFTE			:= .F.
Local lOk			:= .T.
Local nForca		:= 1
Local cRetorno		:= ""

Local cDtNFTS		:= GetNewPar( "MV_DTNFTS", "0" ) // 0-Filtro por Data de Emissao (Padrao) ou 1-Filtro por Data de Entrada
Local cDataDe		:= IIf( cDtNFTS == "1", "Data Entrada de", "Data de" )
Local cDataAte		:= IIf( cDtNFTS == "1", "Data Entrada ate", "Data ate" )
Default lUsaColab	:= UsaColaboracao("3")

If cEntSai == "1"
	cAlias	:= "SF2"
	aParam	:= {Space(Len(SF2->F2_SERIE)),Space(Len(SF2->F2_DOC)),Space(Len(SF2->F2_DOC)),"",1,dData,dData,""}
ElseIf cEntSai == "0"   
	cAlias	:= "SF1"                                                                                        
	aParam	:= {Space(Len(SF1->F1_SERIE)),Space(Len(SF1->F1_DOC)),Space(Len(SF1->F1_DOC)),"",1,dData,dData,""}
EndIf

MV_PAR01:=cSerie   := aParam[01] := PadR(ParamLoad(cParTrans,aPerg,1,aParam[01]),Len(SF2->F2_SERIE))
MV_PAR02:=cNotaini := aParam[02] := PadR(ParamLoad(cParTrans,aPerg,2,aParam[02]),Len(SF2->F2_DOC))
MV_PAR03:=cNotaFin := aParam[03] := PadR(ParamLoad(cParTrans,aPerg,3,aParam[03]),Len(SF2->F2_DOC))
MV_PAR04:=""
MV_PAR05:=""
MV_PAR06:= dData
MV_PAR07:= dData
MV_PAR08:= aParam[08] := PadR(ParamLoad(cParTrans,aPerg,8,aParam[08]),100)
//Montagem das perguntas
aadd(aPerg,{1,STR0010,aParam[01],"",".T.","",".T.",30,.F.})	//"Serie da Nota Fiscal"
aadd(aPerg,{1,STR0011,aParam[02],"",".T.","",".T.",30,.T.})	//"Nota fiscal inicial"
aadd(aPerg,{1,STR0012,aParam[03],"",".T.","",".T.",30,.T.}) //"Nota fiscal final"

If lUsaColab
	//-- TOTVS Colaboracao 2.0
	lOk := ColParValid("NFS",@cRetorno)
	If lOk
		cAmbienteNFSe := ColGetPar("MV_AMBINSE","2")
		cVersaoNFSe   := ColGetPar("MV_VERNSE" ,"")
	Else
		Aviso("NFS-e","Execute a funcionalidade Parâmetros, antes de utilizar esta opção!"+CRLF+cRetorno,{STR0114},3) //"Ok"
	EndIf
Else
	//-- Geracao XML Arquivo Fisico
	If ( cCodMun $ Fisa022Cod("101") .or. cCodMun $ Fisa022Cod("102") .Or. ( cCodMun $ GetMunNFT() .And. cEntSai == "0"  ) ) .And. !(cCodMun $ Fisa022Cod("201") .Or. cCodMun $ Fisa022Cod("202"))
		MV_PAR04:= cDEST  := aParam[04] := PadR(ParamLoad(cParTrans,aPerg,4,aParam[04]),10)
		MV_PAR05:= nForca := aParam[05] := PadR(ParamLoad(cParTrans,aPerg,5,aParam[05]), 1)
		aadd(aPerg,{1,"Nome arquivo",aParam[04],"",".T.","",cWhen,40,lObrig})			//"Nome do arquivo XML Gerado"
		aadd(aPerg,{2,"Força Transmissão",aParam[05],{"1-Sim","2-Não"},40,"",.T.,""})	//"Força Transmissão"
		If ( cCodMun $ GetMunNFT() .And. cEntSai == "0"  )
			MV_PAR06:= dDataIni:= aParam[06] := ParamLoad(cParTrans,aPerg,6,aParam[06])
			MV_PAR07:= dDataFim:= aParam[07] := ParamLoad(cParTrans,aPerg,5,aParam[07])
			aadd(aPerg,{1,cDataDe,aParam[06],"",".T.","",".T.",50,.F.})				//"Data de:"
			aadd(aPerg,{1,cDataAte,aParam[07],"",".T.","","",50,.F.})  				//"Data ate:"
			lNFT := .T.
		EndIf
		cMvPar06 := MV_PAR06
		oWs := WsSpedCfgNFe():New()
		oWs:cUSERTOKEN      := "TOTVS"
		oWS:_URL            := AllTrim(cURL)+"/SPEDCFGNFe.apw"
		oWS:lftpEnable      := nil
		If ( execWSRet( oWS ,"tssCfgFTP" ) )
			If ( oWS:lTSSCFGFTPRESULT )
//				aadd(aPerg,{6,"Caminho do arquivo","","","",040,.T.,"","",""})
				aAdd(aPerg,{6,"Caminho do arquivo",padr('',100),"",,"",90 ,.T.,"",'',GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY})
			EndIf
		EndIf
	ElseIf ( cCodMun $ GetMunNFT() .And. cEntSai == "0"  )
		MV_PAR06:= dDataIni:= aParam[06] := ParamLoad(cParTrans,aPerg,6,aParam[06])
		MV_PAR07:= dDataFim:= aParam[07] := ParamLoad(cParTrans,aPerg,5,aParam[07])
		aadd(aPerg,{1,cDataDe,aParam[06],"",".T.","",".T.",50,.F.})				//"Data de:"
		aadd(aPerg,{1,cDataAte,aParam[07],"",".T.","","",50,.F.})  				//"Data ate:"
		lNFTE := .T.
	EndIf
EndIf

//Verifica se o serviço foi configurado - Somente o Adm pode configurar
If lUsaColab
cAmbNfse :=	IIF (ColGetPar("MV_AMBINSE","2") == '2',STR0057/*2-Homologação*/,STR0056/*1-Produção*/)
Endif
If lOk .And. ParamBox(aPerg,cAmbNfse+" NFS-e",,,,,,,,cParTrans,.T.,.T.)
	
	if ( lNFT )
		cGravaDest := MV_PAR08
		cNftMvPar6 := MV_PAR06
	else
		cGravaDest := MV_PAR06
	endif

	If lNFTE
		MV_PAR06 := MV_PAR04
		MV_PAR07 := MV_PAR05
		MV_PAR04 := ""
		MV_PAR05 := ""
		cMvPar06 := MV_PAR06
	EndIf

	MV_PAR05 := Val(Substr(MV_PAR05,1,1))

	// Retornando ao valor original ao Mv_PAR06
	if ( lNFT )
		MV_PAR06 := cNftMvPar6
	else
		MV_PAR06 := cMvPar06
	endif

	_cNota := val(MV_PAR02)

	do while strZero(_cNota,6) <= alltrim(MV_PAR03)

		cNotasOk := ""
		
		Processa( {|| Fisa022Trs(cCodMun,MV_PAR01,strZero(_cNota,6)+"   ",strZero(_cNota,6)+"   ",MV_PAR04,cAlias,@cNotasOk,cDEST,MV_PAR05,@cMensRet,MV_PAR06,MV_PAR07,,,cGravaDest, lUsaColab, lNFTE)}, "Aguarde...","(1/2) Verificando dados...", .T. )
		If Empty(cNotasOk) 	
			Aviso("NFS-e","Nenhuma nota foi transmitida."+CRLF+cMensRet,{STR0114},3)
		Else
			If lUsaColab .Or. ((cCodMun $ Fisa022Cod("101") .Or. cCodMun $ Fisa022Cod("102") .Or. (cCodMun $ GetMunNFT() .And. cEntSai == "0")) .And. !(cCodMun $ Fisa022Cod("201") .Or. cCodMun $ Fisa022Cod("202")))
				Aviso("NFS-e","Arquivos Gerados:" +CRLF+ cNotasOk,{STR0114},3)
			Else		
				cMensRet := Iif("Uma ou mais notas nao puderam ser transmitidas:"$cNotasOk,"","Notas Transmitidas:"+CRLF)
				Aviso("NFS-e",cMensRet + cNotasOk,{STR0114},3)
			EndIf
		EndIf

		_cNota++
	enddo
EndIf    

RestArea(aArea)

Return 
