#Include "Protheus.ch"
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#INCLUDE "TbiConn.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ProcImp   �Autor  �Adriano       Reis  � Data �  05/12/22   ���
�������������������������������������������������������������������������͹��
���Desc.     � Importa��o de Ativo Fixo SN1                               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User function ProcImp()

Private oLeTxt

//���������������������������������������������������������������������Ŀ
//� Montagem da tela de processamento.                                  �
//�����������������������������������������������������������������������

@ 200,1 TO 380,380 DIALOG oLeTxt TITLE "Importar tabelas"
@ 02,10 TO 080,190
@ 10,018 Say " Este programa ir� ler o conteudo de um arquivo texto, conforme"
@ 18,018 Say " os parametros definidos pelo usuario, e grav�-lo em sua"
@ 26,018 Say " respectiva tabela no Protheus.                                "

@ 70,128 BMPBUTTON TYPE 01 ACTION OkLeTxt()
@ 70,158 BMPBUTTON TYPE 02 ACTION Close(oLeTxt)

Activate Dialog oLeTxt Centered

Return 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �OkLeTxt   �Autor  �Microsiga           � Data �  05/12/22   ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o que abre a tela para sele��o do arquivo que ser�    ���
���          � Importado                                                  ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function OkLeTxt()

//����������������������������������Ŀ
//�Tela para sele��o do arquivo texto�
//������������������������������������
Local cArqTxt := cGetFile( '*.TXT' , 'Arquivo de importa��o', 1, "", .T., GETF_LOCALHARD,.T.,.T.)

//����������������������������������Ŀ
//�Abre o arquivo selecionado        �
//������������������������������������
Private nHandle := FT_FUse(cArqTxt)  

//�������������������������������������������������Ŀ
//�Se houver erro de abertura abandona processamento�
//���������������������������������������������������
if nHandle == -1  
	MsgAlert("O arquivo "+cArqTxt+" nao pode ser aberto! Verifique os parametros.","Aten��o!")
	return
endif 
Private _cArqTxt := cArqTxt

//����������������������������������������Ŀ
//�Inicia regua de processamento do arquivo�
//������������������������������������������
Processa({|| RunCont() },"Processando...")

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RunCont   �Autor  �Microsiga           � Data �  05/12/22   ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o responsavel pela leitura do arquivo texto e         ���
���          � e tamb�m a grava��o dos registros lidos                    ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function RunCont()

// Local aLog  := {}
// Local aLog2 := {}
// Local aLog3 := {}
// Local aLog4 := {}
// Local aLog5 := {}
// Local aLog6 := {}
Local aLog7 := 0 
Local aLog8 := 0

//���������������������������������������������������Ŀ
//�Retorna a quantidade de registros do arquivo texto.�
//�����������������������������������������������������
nTamFile := FT_FLastRec()
ProcRegua(nTamFile) // Numero de registros a processar

FT_FGoTop()// Posiciona na primeira linha do arquivo texto de impota��o 

SX3->(DbSetOrder(2))                         

aCab  := STRTOKARR(FT_FReadLn(),";")

FT_FSKIP() 
While !FT_FEOF()
	IncProc()   
	//aLine  := STRTOKARR(FT_FReadLn(),";")
	aLine  := StringToArray(FT_FReadLn())   

	cFilAtu := cFilAnt //Grava a Filial corrente
	cFilAnt := (aLine[aScan(aCab,"N1_FILIAL")])
	
	DbSelectArea("SN1")  
	SN1->( DbSetOrder(1) )
    DbSelectArea("SN3")
    SN3->( DbSetOrder(1) )

    lRetorno := .T. 
    aCabec	 := {}
	aItens   := {} 
	aParam	 := {}

	cExecSN1 := .F.
    Private lMsErroAuto := .F. // Determina se houve alguma inconsistencia na execucao da rotina 
	Private lMsHelpAuto := .F. //COMENTADO
	Private cN1FIL   := PADL(aLine[aScan(aCab,"N1_FILIAL")] ,4,'0')               
	Private cN1COD   := PADL(aLine[aScan(aCab,"N1_CBASE")],6,'0')
//	Private cN1COD   := Strzero(val(aLine[aScan(aCab,"N1_CBASE")]),10)
	Private cN1ITEM  := PADL(aLine[aScan(aCab,"N1_ITEM")],4,'0')
	// Private _cItem 	 := u_PROXSN1("SN1","N1_ITEM",cN1COD,,.T.)
	// Private cN1ITEM  := PADL(_cItem,4,'0')
    Private cN3CC    := (aLine[aScan(aCab,"N3_CCUSTO")])      	                                                     
    Private cChapa   := padl(aLine[aScan(aCab,"N1_CHAPA")],tamsx3("N1_CHAPA")[1],"0")
	//Private cCliente := ''
	//Private cLoja    := ''

//IF !SN1->(dbSeek(cN1FIL+cN1COD+cN1ITEM))      	                         

	SN1->( dbgotop() )
	SN1->( DbSetOrder(1) )   
	IF !SN1->(dbSeek(cN1FIL+cN1COD))       	                       
			aadd( aCabec,{ "N1_FILIAL"   , Alltrim((aLine[aScan(aCab,"N1_FILIAL")]))						 		, NIL } )
			aadd( aCabec,{ "N1_CBASE" 	 , PADL(aLine[aScan(aCab,"N1_CBASE")],6,"0")					 	 		, NIL } )
			aadd( aCabec,{ "N1_ITEM" 	 , PADL(cN1ITEM,4,"0")		 				 	 					 		, NIL } )
			aadd( aCabec,{ "N1_AQUISIC"  , CTOD(aLine[aScan(aCab,"N1_AQUISIC")])	 								, NIL } )
			aadd( aCabec,{ "N1_DESCRIC"  , SubStr(Upper(Alltrim((aLine[aScan(aCab,"N1_DESCRIC")]))),1,40)	 		, NIL } )
			aadd( aCabec,{ "N1_QUANTD"   , 1																		, NIL } )
			aadd( aCabec,{ "N1_CHAPA"	 , PADL(aLine[aScan(aCab,"N1_CHAPA")],12,"0")								, NIL } ) // tamsx3("N1_CHAPA")[1]
		//	aadd( aCabec,{ "N1_GRUPO" 	 , PADL(aLine[aScan(aCab,"N1_GRUPO")],4,"0")	 				     		, NIL } )
			aadd( aCabec,{ "N1_DLOCAL"   , SubStr(Upper(Alltrim((aLine[aScan(aCab,"N1_DLOCAL")]))),1,40)            , NIL } )   
//			aadd( aCabec,{ "N3_TIPO"     , PADL(aLine[aScan(aCab,"N3_TIPO")],6,"0")							    	, NIL } )  
//			aadd( aCabec,{ "N1_FORNEC"   , (aLine[aScan(aCab,"N1_FORNEC")])	 							     		, NIL } )
//			aadd( aCabec,{ "N1_LOJA"	 , (aLine[aScan(aCab,"N1_LOJA")])	 							     		, NIL } )
//			aadd( aCabec,{ "N1_NFISCAL"  , (aLine[aScan(aCab,"N1_NFISCAL")])	 						     		, NIL } )
//			aadd( aCabec,{ "N1_NSERIE"   , (aLine[aScan(aCab,"N1_NSERIE")])	 							     		, NIL } )
			// aadd( aCabec,{ "N1_PRODUTO"  , (aLine[aScan(aCab,"N1_PRODUTO")])	 							 		, NIL } )
			// aadd( aCabec,{ "N1_TPCTRAT"  , '1'	 													     		, NIL } )   
//			aadd( aCabec,{ "N1_VLAQUIS"  , Val(StrTran(StrTran(aLine[aScan(aCab,"N1_VLAQUIS")],".",""),",","."))	, NIL } )

		aadd(aItens,{ 	{ "N3_FILIAL"	 , (aLine[aScan(aCab,"N1_FILIAL")])	 							    		, NIL} ,;
						{ "N3_TIPO" 	 , '01'	 																	, NIL} ,;
						{ "N3_HISTOR"    , "IMPORTACAO"																, NIL} ,;
						{ "N3_TPDEPR" 	 , '1'	 																	, NIL} ,;					
						{ "N3_CCONTAB"   , (aLine[aScan(aCab,"N3_CCONTAB")])	 									, NIL} ,;
						{ "N3_CUSTBEM"   , (aLine[aScan(aCab,"N3_CUSTBEM")])	 									, NIL} ,;
						{ "N3_CDEPREC"   , "320104028"	 															, NIL} ,;   
						{ "N3_CCUSTO"    , (aLine[aScan(aCab,"N3_CCUSTO")]) 										, NIL} ,;
						{ "N3_CCDEPR"   , (aLine[aScan(aCab,"N3_CCDEPR")])	 										, NIL} ,;
						{ "N3_AQUISIC"   , CTOD(aLine[aScan(aCab,"N1_AQUISIC")])	 								, NIL} ,;
						{ "N3_DINDEPR"   , CTOD(aLine[aScan(aCab,"N1_AQUISIC")])	 								, NIL} ,;
						{ "N3_VORIG1"    , Val(StrTran(StrTran(aLine[aScan(aCab,"N3_VORIG1")],".",""),",","."))		, NIL} ,;
						{ "N3_TXDEPR1"   , Val(StrTran(StrTran(aLine[aScan(aCab,"N3_TXDEPR1")],".",""),",","."))	, NIL} ,;
					    { "N3_CCDESP"    , aLine[aScan(aCab,"N3_CCDESP")]	 								     	, NIL} })
					//	{ "N3_CCCDEP"    , (aLine[aScan(aCab,"N3_CCCDEP")])	 								     	, NIL} })
					//  { "N3_VRDACM1"   , Val(StrTran(StrTran(aLine[aScan(aCab,"N3_VRDACM1")],".",""),",","."))	, NIL} })

		Private cErroLog := ''
		Private cPath    := ''
		Private cArq     := ''

    	// MsExecAuto({|x,y,z| ATFA010(x,y,z)}, aCabec, aItens, 3)	    	// FINALIDADE - INCLUS�O //                                        
		MSExecAuto({|x,y,z,w| Atfa012(x,y,z,w)},aCabec,aItens,3,aParam)	    	// FINALIDADE - INCLUS�O //  

		If lMsErroAuto 
			lRetorno 	:= .F.                                              
			cPath 		:= Upper(GetSrvProfString("STARTPATH","")) 
			cArq  		:= aCabec[3,2]+SUBSTR(Time(),1,2)+SUBSTR(Time(),4,2)+".log"
			//cErroLog 	:= MostraErro(cPath,cArq) // COMENTADO
			MostraErro() 
			//cLog 		:= ("O Ativo - Filial -  "+(aLine[aScan(aCab,"N1_FILIAL")])+' Codigo Bem - '+aLine[aScan(aCab,"N1_CBASE")]+' Item - '+cN1ITEM+' Chapa - '+(aLine[aScan(aCab,"N1_CHAPA")])+" N�o Foi Importado - Motivo : "+cErroLog)
			//MemoWrite("C:\Temp\Log_Importacao_Ativos -"+substr(_cArqTxt,09,15)+cvaltochar(aLine[aScan(aCab,"N1_CHAPA")])+cvaltochar(dtos(ddatabase))+".txt",cLog)

			aLog8++
			FT_FSKIP()
			Loop
		Else              
			aLog7++
			lRetorno:=.T.
		EndIf 
	
	EndIf

 
	FT_FSKIP()
EndDo 

cFilAnt := cFilAtu

FWAlertInfo("Importa��o da Planilha Finalizada. Log Criado C:\Temp\Log_Importacao_Ativo - "+substr(_cArqTxt,09,15)+Transform(Time(),"@E 99999999")+cvaltochar(dtos(ddatabase))+".txt","Aten��o")

FT_FUSE()                            
Return()                         

Static FUNCTION StringToArray( cString, cSeparator ) 
LOCAL nPos 
    LOCAL aString := {} 
    DEFAULT cSeparator := ";" 
    cString := ALLTRIM( cString ) + cSeparator 
    DO WHILE .T. 
		nPos := AT( cSeparator, cString ) 
		IF nPos = 0 
			EXIT 
		ENDIF 
		AADD( aString, SUBSTR( cString, 1, nPos-1 ) ) 
		cString := SUBSTR( cString, nPos+1 ) 
    ENDDO 
RETURN ( aString ) 

