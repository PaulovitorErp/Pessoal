#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

/*
------------------------------------------------------------------------------------------------------------
FUNçãO:  RGPEM008

TIPO: FUNçãO DE USUáRIO

DESCRIçãO: IMPORTAçãO PARA O Protheus X Tron.

USO: TECNOMONT

PARâMETROS:

RETORNO:

--------------------------------------------------
ATUALIZAçõES:
- 13/11/2011 - KAREM CAROLINE DE OLIVEIRA RICARTE - CONSTRUçãO INICIAL DO FONTE
------------------------------------------------------------------------------------------------------------
*/


User Function RGPEM008 ()

	Define Dialog oForm Title "Importação Verba Protheus X Tron " From  0,0 To 200,300 Pixel
	@05,05 TO 80,145 OF oForm Pixel
	
	@09,10 SAY "Com este programa, é possível importar    " OF oForm PIXEL
	@15,10 SAY "os Acumulados do arquivo para o          " OF oForm PIXEL
	@26,10 SAY " gestão de pessoa do protheus.            " OF oForm PIXEL

	
	oBtn := tButton():new(85,34 ,"&Importar" ,oForm,{||CAGPE00101()},35,12,,,,.T.)
 //	oBtn := tButton():new(85,71 ,"&Consultar",oForm,{||CAGPE00105()},35,12,,,,.T.)
	oBtn := tButton():new(85,71,"&Fechar"   ,oForm,{|| oForm:End()},35,12,,,,.T.)
	
	Activate Dialog oForm Centered
	
Return

/*+----------+----------+-------+-------------  ----------+------+-------------+
|FUNçãO    |CAGPE00101| AUTOR |KAREM CAROLINE O. RICARTE| DATA |10.05.2010     |
+----------+----------+-------+-------------------------+------+---------------+
|DESCRIçãO |ROTINA DE INTERFACE COM O R3 - VELIDAçãO DO TXT SELECIONADO        |
|PARA IMPORTAçãO                                                               |
|                                                                              |
+----------+-------------------------------------------------------------------+
|RETORNO   |DEMARCAçãO DOS LIMITES DO ARQUIVO TEXTO(LINHA A LINHA)             |
|			 |QUE SERá IMPORTADO,      										   |
|          |BEM COMO CHAMADA DAS ROTINAS ONDE A OPERAçãO é REALIZADA.          |
+----------+-------------------------------------------------------------------+*/
Static Function CAGPE00101

	Private cFileOpen	:= ""
	Private cCadastro 	:= "Ler arquivo texto"
	Private cEOL 		:= "CHR(13)+CHR(10)
	Private cLog 		:= ""
	Private oProcess

//Carrega arquivo texto
	cFileOpen := cGetFile("Arquivos Texto|*.TXT",OemToAnsi("Abrir Arquivo...")) 
	
	//Caso ocorraMicrosiga	 erro na abertura do arquivo
	If !File(cFileOpen) .Or. Empty(cFileOpen)
		MsgAlert("Arquivo texto: "+cFileOpen+" não localizado",cCadastro)
		Return
	Endif
	
	//Abre arquivo texto
	FT_FUSE(cFileOpen)
	
	//Posiciona no topo
	FT_FGOTOP()

//_nCont := 1

//Carrega quantidade de linhas
	_nQtdProc := FT_FLASTREC()

//Cria regua de processamento
	ProcRegua(_nQtdProc)
	
	If Empty(cEOL)
		cEOL := CHR(13)+CHR(10)
	Else
		cEOL := Trim(cEOL)
		cEOL := &cEOL
	Endif
	
//barra de processo e chamada para a função que cria o arquivo de trabalho
	oProcess := MsNewProcess():New({|lEnd| CAGPE00102()})
	oProcess:Activate()
	
	//Fecha o arquivo
	FT_FUSE()
oForm:End()	
Return



Static function CAGPE00102

		Local   cTrab    := ""
		Local 	aTmp	 := {}
		Local   aRecNos  := {}              
		Local   _aCMP  := {}
		Local   dData    := dDataBase
		Local   nInclui  := 0
		Local   nAltera  := 0
		Local   nCount   := 1
		Local   nSeq     := 01 
		lOCAL _aBuffer   := {}
		Private nCampo   := 1
		Private lAchou   := .T.
		Private lValorD  := .T.
		Private lNaoImp  := .T.
		
		//Pega as configurações da tabela SRK como: tamanho, tipo, campo da tabela atravez da SX3
		_aCMP  := CAGPE00103('ZZZ')
		
		aTmp := _aCMP
		aCampos := {}
		SX3->(DbSetOrder(2))
		For nx:=1 To Len(aTmp)
			
			If SX3->(DbSeek(aTmp[nx]))
				AADD(aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			Else
				MsgStop("Campo não encontrado!","CAGPE00102")
			EndIf
			
		Next nx
		

		
	

/*+-----------------------------------+
  | CRIAÇÃO DO ARQUIVO DE LOG         |
  +-----------------------------------+*/
      /*
		cHora := Time()
		cLog  := "\logs\impEMPRESTIMOS"+DtoS(Date())+Substr(cHora,1,2)+Substr(cHora,4,2)+".log"
		
		If Select("TRBLOG") > 0
			TRBLOG->(DbCloseArea("TRBLOG"))
		End
		DbCreate(cLog,aLog)
		dbUseArea(.T.,,cLog ,"TRBLOG",.T.)   */
		//Enquanto naõ estiver no fim do arquivo
		While !FT_FEOF()
			//incrementa a regua com a quantidade de linhas lidas e a quantidade do total de linhas  
			
			oProcess:IncRegua2("Lendo Linha " + cValToChar(nCount) + " de um total de " + cValToChar(_nQtdProc) + ".")
			
			nCount++
			//carrega a linha para leitura
			cBuffer	:= FT_FREADLN()
			
			//ignora as linhas em branco e pula para a próxima
			If Empty(cBuffer) //.Or. ValType(cBuffer) <> 'N'
				FT_FSKIP()	
				Loop
			Endif 
	 		 
	  		If  cValToChar(nCount) == '2' 
	 			FT_FSKIP()	
				Loop
			Endif   
			_aBuffer := STRTOKARR(cBuffer,';') //separa(cBuffer, '|') 
			          
			If nCount == 2
				FT_FSKIP()	
				Loop
			Endif    
		_cFilial := ' '
			     	   	 
 			_aBuffer := STRTOKARR(cBuffer,';') //separa(cBuffer, '|')  
			
			_aCria :=  STRTOKARR(_aBuffer[3] ,'/' )
			ZZZ->(DbSetOrder(1))  
			If Len(_aCria) == 1 
				RecLock('ZZZ',.T.)
					//Posições do .txt
		 		  ZZZ->ZZZ_FILIAL :=  '    '                                      
				  ZZZ->ZZZ_VERBAP      :=  padl(_aBuffer[1] ,3,'0')                                       
				  ZZZ->ZZZ_VERBAT      :=  _aBuffer[3] 
				  ZZZ->(MSUnLock())     
		    Else
		    
				For nx := 1 to Len(_aCria)
				//	If !(ZZZ->(DbSeek(xFilial("ZZZ")+_aCria[nx])))
						RecLock('ZZZ',.T.)
						//Posições do .txt
			 		  ZZZ->ZZZ_FILIAL :=  '    '                                      
					  ZZZ->ZZZ_VERBAP      :=  padl(_aBuffer[1] ,3,'0')                                    
					  ZZZ->ZZZ_VERBAT      :=  alltrim(_aCria[nx]) 
					  ZZZ->(MSUnLock())     
			//	EndIf
				Next  
			EndIf 	 

		
			FT_FSKIP() 
		EndDo    
 
MsgAlert('Importação concuida com sucesso!','Sucesso') 
//Substr(StrTran(_aBuffer[5],"'",""),5,4) + Substr(StrTran(_aBuffer[5],"'",""),4,2) +  Substr(StrTran(_aBuffer[5],"'",""),1,2)

return   



Static Function CAGPE00103(_cAlias)

Local _aCMP    := {}

If _cAlias == 'ZZZ'

	_aCMP    := {   "ZZZ_VERBAP",;
		   			"ZZZ_VERBAT "}
EndIf




return  _aCMP