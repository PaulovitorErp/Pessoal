#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �WF011     �Autor  �Microsiga           � Data �  06/19/15   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function WF011()

Local FimPAqui    	:= ""
Local DFimPAqui   	:= ""
Local DPRPAqui    	:= ""
Local cAcessaSRA  	:= &("{ || .T.}")
Local cDescCC	  	:= ""
Local lTemCpoProg
Local lUnicoPer		:= .F.
Local dDtIProg1
Local dDtIProg2
Local dDtIProg3
Local nDiasFer1 	:= 0
Local nDiasFer2		:= 0
Local nDiasFer3		:= 0
Local nDiasAbo1		:= 0
Local nDiasAbo2		:= 0
Local nDiasAbo3		:= 0

WFPrepEnv("02", "00")

Private oProcess
Private cHtml   := "\workflow\WF011.htm"
Private cMail
Private lFirst
Private cTabela := ""
Private cOutros := ""
Private nTValor	:= 0
Private Normal    	:= 0
Private Descanso  	:= 0
Private cPerFeAc  	:= GetMv("MV_FERPAC",,"N")		// Ferias por ano civil
Private aTabFer   	:= {}    			         	// Tabela para calculo dos dias de ferias
Private aCodFol   	:= ARRAY(1)		         		// Incializada para nao ser carregada em Calc_Fer
Private cTafaFer  	:= GetMv("MV_TAFAFER" )      	// Trata Perda de Periodo Para Afastados
Private dDtBasFim 	:= Ctod("")
Private cAliasSRF	:= "SRF"

//Parametro do servidor para envio do email
cServer	:= alltrim(GetMV("MV_RELSERV"))
cEmail	:= alltrim(GetMV("MV_RELACNT"))
cPass	:= alltrim(GetMV("MV_RELPSW"))

//��������������������������������������������������������������Ŀ
//� Verifica a existencia dos campos de programacao ferias no SRF�
//����������������������������������������������������������������
lTemCpoProg 		:= fTCpoProg()

//��������������������������������������������������������������Ŀ
//� Carregando variaveis mv_par?? para Variaveis do Sistema.     �
//����������������������������������������������������������������
nOrdem     := 5		//aReturn[8]
cFilDe     := " "	//mv_par01                          //  Filial De
cFilAte    := "Z"	//mv_par02                          //  Filial Ate
cCcDe      := " "	//mv_par03                          //  Centro de Custo De
cCcAte     := "Z"	//mv_par04                          //  Centro de Custo Ate
cMatDe     := " "	//mv_par05                          //  Matricula De
cMatAte    := "Z"	//mv_par06                          //  Matricula Ate
nTipo      := 1		//mv_par16
cSituacao  := " A**T"//mv_par07                       	//  Situacao Funcionario
cCategoria := "********M****"							//  Categoria Funcionario
lSalta     := .F.	//If( mv_par09 == 1 , .T. , .F. )   //  Salta Pagina Quebra C.Custo
cNomDe     := " "	//mv_par10                          //  Nome De
cNomAte    := "Z"	//mv_par11                          //  Nome Ate
nTipFerias := 3		//mv_par12                          //  1-Nao programadas, 2-Programadas e 3-Ambas
dProgDe    := stod("")//mv_par13                       	//  Data inicial para ferias programdas
dProgAte   := stod("")//mv_par14                       	//  Data Final   para ferias programdas
nPeriodo   := 1		//mv_par15							// Imprimir 1 periodo, 2 periodos ou os 3 periodos

cTabela := ""
cOutros := ""

dbSelectArea( "SRA" )
dbGoTop()
dbSelectArea("SRF")
cIndCond:= "SRF->RF_FILIAL + DTOS(SRF->RF_DATABAS)"
cFor:= '(SRF->RF_FILIAL+SRF->RF_MAT >= "'+cFilDe+cMatDe+'")'
cFor+= '.And. (SRF->RF_FILIAL+SRF->RF_MAT <= "'+cFilAte+cMatAte+'")'
cInicio := "SRF->RF_FILIAL"
cFim    := cFilAte

//��������������������������������������������������������������Ŀ
//� Cria Indice caso Impressao por Programa��o de F�rias ("SRF") �
//����������������������������������������������������������������
dbSelectArea("SRF")
cArqNtx  := CriaTrab(NIL,.f.)
dbGoTop()
dbSelectArea( "SRF" )

cFiAnt := Space(2)
cCcAnt := space(20)

While !Eof() .And. &cInicio <= cFim
	
	dbSelectArea( "SRA" )
	dbSetOrder(1)
	dbSeek( SRF->RF_FILIAL + SRF->RF_MAT )
	
	//��������������������������������������������������������������Ŀ
	//� Testa Situacao do Funcionario na Folha                       �
	//����������������������������������������������������������������
	If !( SRA->RA_SITFOLH $ cSituacao ) .Or. !( SRA->RA_CATFUNC $ cCategoria )		
		dbSelectArea( "SRF" )		
		dbSkip()
		Loop
	Endif
	
	//��������������������������������������������������������������Ŀ
	//� Consiste Parametriza��o do Intervalo de Impress�o            �
	//����������������������������������������������������������������
	If	(SRA->RA_FILIAL < cFilDe) .Or. (SRA->RA_FILIAL > cFilAte) .Or. ;
		(SRA->RA_MAT    < cMatDe) .Or. (SRA->RA_MAT    > cMatAte) .Or. ;
		(SRA->RA_CC     < cCcDe)  .Or. (SRA->RA_CC     > cCcAte)  .Or. ;
		(SRA->RA_NOME   < cNomDe) .Or. (SRA->RA_NOME   > cNomAte)
		dbSelectArea( "SRF")
		dbSkip()
		Loop
	EndIf
	
	//��������������������������������������������������������������Ŀ
	//| Carrega tabela para apuracao dos dias de ferias - aTabFer    |
	//| 1-Meses Periodo    2-Nro Periodos   3-Dias do Mes    4-Fator |
	//����������������������������������������������������������������
	fTab_Fer(@aTabFer)
	
	//��������������������������������������������������������������Ŀ
	//� Se Nao Achou Registro no SRF Gera Automatico                 �
	//����������������������������������������������������������������
	dbSelectArea( "SRF" )
	dbSelectArea( "SRF" )
	
	//��������������������������������������������������������������Ŀ
	//� Calculo dos Dias de Ferias Vencidas e a Vencer               �
	//����������������������������������������������������������������
	nDiasVenc := nDiasProp := nDiasAbono := 0
	dDtBaseFer:=(cAliasSRF)->RF_DATABAS
	
	Calc_Fer(@dDtBaseFer,dDataBase,@nDiasVenc,@nDiasProp,,,@dDtBasFim,.F.,cTafaFer)
	
	If nDiasVenc > 0 .And. SRF->RF_DFERANT > 0
		nDiasVenc	:= Max(nDiasVenc - SRF->RF_DFERANT, 0)
	Elseif nDiasVenc == 0 .And. nDiasProp > 0 .And. SRF->RF_DFERANT > 0
		nDiasProp   :=  Max(nDiasProp - SRF->RF_DFERANT, 0)
	Endif
	
	//�����������������������������������������������������������������Ŀ
	//� Calculo dias de ferias pela data de inicio das ferias progrmadas�
	//�������������������������������������������������������������������
	nDiaVen	:= 0 												//Dias de Ferias qdo efetua programacao
	nDiaPro	:= 0
	If ! Empty(SRF->RF_DATAINI)
		Calc_Fer(@dDtBaseFer,SRF->RF_DATAINI,@nDiaVen,@nDiaPro,,,@dDtBasFim,.F.,cTafaFer)
		nDiaVen := If (nDiaVen > aTabFer[3], aTabFer[3], nDiaVen)
	Endif
	
	//��������������������������������������������������������������Ŀ
	//� Calculo dias de  faltas                                      �
	//����������������������������������������������������������������
	nDFaltaV:= SRF->RF_DFALVAT
	nDFaltaP:= SRF->RF_DFALAAT
	TabFaltas(@nDFaltaV)
	TabFaltas(@nDFaltaP)
	nDFaltaP := ((nDFaltaP / 30) * nDiasProp )
	
	//��������������������������������������������������������������Ŀ
	//� Montagem da data do inicio da programacao das ferias         �
	//����������������������������������������������������������������
	dDtIProg1 	:= SRF->RF_DATAINI
	dDtIProg2 	:= dDtIProg3 := CTOD("")
	nDiasFer1 	:= nDiasFer2 := nDiasFer3 := 0
	nDiasAbo1	:= nDiasAbo2 := nDiasAbo3 := 0
	lUnicoPer	:= .F.
	
	//-- Prioriza as informacoes digitadas no novos cpos de program.
	If lTemCpoProg
		dDtIProg2 := SRF->RF_DATINI2
		dDtIProg3 := SRF->RF_DATINI3
		nDiasFer1 := SRF->RF_DFEPRO1
		nDiasFer2 := SRF->RF_DFEPRO2
		nDiasFer3 := SRF->RF_DFEPRO3
		nDiasAbo1 := SRF->RF_DABPRO1
		nDiasAbo2 := SRF->RF_DABPRO2
		nDiasAbo3 := SRF->RF_DABPRO3
		lUnicoPer := If(  (nDiasFer1+nDiasAbo1) == nDiaVen , .T., lUnicoPer)
	EndIf
	
	//-- Calcula dias de abono
	If SRF->RF_TEMABPE == "S" .And.  ! Empty(SRF->RF_DATAINI) .And. nDiasAbo1 = 0 .And. nDiasFer1 = 0
		nDiasAbo1	:=  (Min(nDiaVen-SRF->RF_DFERANT,aTabFer[3]) - nDFaltaV ) /3
		nDiasAbo1	:= Int(nDiasAbo1)
		//����������������������������������������������������������������Ŀ
		//� Se Ferias forem  gozadas em  um  unico periodo, proporcionaliza�
		//� o abono pecuniario, se nao, utiliza o que for informado nos cam�
		//� pos de dias de ferias e abono de cada  periodo                 �
		//������������������������������������������������������������������
	ElseIf SRF->RF_TEMABPE == "S" .And. lUnicoPer
		//����������������������������������������������������������������Ŀ
		//� Garantir que os dias de gozo e abono pecuniario estejam iguais �
		//� ao total de dias de ferias vencidas antes de fazer a proporcio-�
		//� nalizacao dos dias de abono pecuniario em funcao das faltas no �
		//� periodo aquisitivo.                                            �
		//������������������������������������������������������������������
		nDiasAbo1	:= int( ( nDiaVen - nDFaltaV ) / 3 )
	EndIf
	
	//��������������������������������������������������������������Ŀ
	//� Verifica Data Inicio                                         �
	//����������������������������������������������������������������
	If (!Empty(dDtIProg1) .Or. !Empty(dDtIProg2) .Or. !Empty(dDtIProg3)) .And. nTipFerias == 1
		dbSkip()
		Loop
	ElseIf Empty(dDtIProg1) .And. Empty(dDtIProg2) .And. Empty(dDtIProg3) .And. nTipFerias == 2
		dbSkip()
		Loop
	EndIf
	
	//��������������������������������������������������������������Ŀ
	//� Consiste Ferias Programdas no Intervalo Definido			 �
	//����������������������������������������������������������������
	If nTipFerias == 2 .And. (dDtIProg1 < dProgDe .Or. dDtIProg1 > dProgAte) .And.;
		(dDtIProg2 < dProgDe .Or. dDtIProg2 > dProgAte) .And.;
		(dDtIProg3 < dProgDe .Or. dDtIProg3 > dProgAte)
		dbSkip()
		Loop
	EndIf
	
	If !(cFiAnt == SRA->RA_FILIAL)
		If !(cFiAnt == Space(02))
			Impr("","P")
		EndIf
		cFiAnt := SRA->RA_FILIAL
	EndIf
	
	//��������������������������������������������������������������Ŀ
	//�Verifica Quebra de Centro de Custo e Filial                   �
	//����������������������������������������������������������������
	//��������������������������������������������������������������Ŀ
	//� Periodo Aquisitivo                                           �
	//����������������������������������������������������������������
	DFIMPAQUI := If (Empty(dDtBasFim), fCalcFimAq(dDtBaseFer), dDtBasFim)
	DPRPAQUI  := fCalcFimAq(DFIMPAQUI+1)
	
	//��������������������������������������������������������������Ŀ
	//� Imprime Detalhe Para o Funcionario                           �
	//����������������������������������������������������������������
	if(nDiasVenc >= 30)		
		cTabela += "<tr><td align='center'>"+SRA->RA_MAT+"</td><td>&nbsp;"+Capital(SRA->RA_NOME)+"</td>"
		cTabela += "<td align='center'>"+PadR(DtoC(SRA->RA_ADMISSA),10)+"</td>"
		cTabela += "<td align='center'>"+PadR(DtoC(dDtBaseFer),10)+" - "+PadR(DtoC(DFIMPAQUI),10)+"</td>"
		cTabela += "<td align='center'>"+PadR(DtoC(DFIMPAQUI + 30),10)+"</td>"
		cTabela += "<td align='center'>"+PadR(DtoC(DPRPAQUI - 45) ,10)+"</td>"
		cTabela += "<td align='center'>"+Transform(nDiasVenc,"999.9")+"</td>"
		cTabela += "<td align='center'>"+Transform(nDiasProp,"999.9")+"</td></tr>"
	else
		cOutros += "<tr><td align='center'>"+SRA->RA_MAT+"</td><td>&nbsp;"+Capital(SRA->RA_NOME)+"</td>"
		cOutros += "<td align='center'>"+PadR(DtoC(SRA->RA_ADMISSA),10)+"</td>"
		cOutros += "<td align='center'>"+PadR(DtoC(dDtBaseFer),10)+" - "+PadR(DtoC(DFIMPAQUI),10)+"</td>"
		cOutros += "<td align='center'>"+PadR(DtoC(DFIMPAQUI + 30),10)+"</td>"
		cOutros += "<td align='center'>"+PadR(DtoC(DPRPAQUI - 45) ,10)+"</td>"
		cOutros += "<td align='center'>"+Transform(nDiasVenc,"999.9")+"</td>"
		cOutros += "<td align='center'>"+Transform(nDiasProp,"999.9")+"</td></tr>"			
   endif
	
	cFiAnt   := SRA->RA_FILIAL
	cCcAnt   := SRA->RA_CC
	dbSelectArea( "SRF" )
	dbSkip()
Enddo

//��������������������������������������������������������������Ŀ
//� Termino do relatorio                                         �
//����������������������������������������������������������������
dbSelectArea( "SRF" )
Set Filter to
RetIndex("SRF")
dbSetOrder(1)
fErase(cArqNtx  + OrdBagExt() )

dbSelectArea( "SRA" )
Set Filter to
dbSetOrder(1)

//Conteudo do Email
EnviaWf(cTabela)

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �WF010     �Autor  �Microsiga           � Data �  06/16/15   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function EnviaWf(cTabela)
oProcess := TWFProcess():New("WF011","ferias")
oProcess:NewTask("WF011",cHtml) 
oProcess:cSubject := "TOTVS VP - Vencimento de Ferias"

oHtml := oProcess:oHtml
oHtml:ValByName("tabela", cTabela)
oHtml:ValByName("outros", cOutros)

If !Empty(cTabela) .or. !Empty(cOutros)
	oProcess:ClientName(cUserName)
	oProcess:cTo	:= "dp@elcop.eng.br;ketly.cristina@elcop.eng.br;jakeline.silva@elcop.eng.br;marcelo.nascimento@elcop.eng.br"
	oProcess:cCC	:= "andre.castilho@elcop.eng.br"
	oProcess:cBCC	:= "marcelo.nascimento@elcop.eng.br"
	oProcess:UserSiga := "000000"
	oProcess:Start()
Endif

Return Nil
