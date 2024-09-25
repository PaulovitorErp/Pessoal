#INCLUDE "MNTR030.ch"
#INCLUDE "PROTHEUS.CH"
#DEFINE _nVERSAO 2 //Versao do fonte

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MNTR030  ³ Autor ³ NG Informatica        ³ Data ³ 03/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relacao Das Ordens de Servico de Manutencao Pendentes      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTR030()
    
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³Guarda conteudo e declara variaveis padroes ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)
    
	Local cString    := "STJ"
	Local cDesc1     := STR0001 //"Relatorio de apresentacao das Ordens de Servico de manutencao pendentes."
	Local cDesc2     := STR0002 //"Atraves dos parametros o usuario podera efetuar a selecao desejada."
	Local cDesc3     := ""
	Local wnrel      := "MNTR030"
    
	Private aReturn  := { STR0003, 1,STR0004, 2, 2, 1, "",1 }  //"Zebrado"###"Administracao"
	Private nLastKey := 0
	Private titulo   := STR0005 //"Equipamentos Sujeitos a Manutenção Preventiva"
	Private Tamanho  := "G"
	Private aPerg    := {}
	Private cPerg    := "MNT030"
    
	Private lST6Tipo := NGCADICBASE('T6_TIPO1','A','ST6',.F.)
	Private lTolConE := If(NGCADICBASE("TF_MARGEM","A","STF",.F.),.t.,.f.)
	Private nSizeFil := If(FindFunction("FWSizeFilial"),FwSizeFilial(),Len(ST9->T9_FILIAL))
    
    /*---------------------------------------------------------------
    Vetor utilizado para armazenar retorno da função MNTTRBSTB,
    criada de acordo com o item 18 (RoadMap 2013/14)
    ---------------------------------------------------------------*/
	Private vFilTRB := MNT045TRB()
    
	SetKey(VK_F4, {|| MNT045FIL( vFilTRB[2] )})
    
	//+------------------------------------------------+
	//| Variaveis utilizadas para parametros           |
	//| mv_par01     // De Período                     |
	//| mv_par02     // Ate Período                    |
	//| mv_par03     // De Filial                      |
	//| mv_par04     // Ate Filial                     |
	//| mv_par05     // De Centro de Custo             |
	//| mv_par06     // Ate Centro de Custo            |
	//| mv_par07     // De centro de trabalho          |
	//| mv_par08    // Ate centro de trabalho          |
	//| mv_par09     // De Modelo                      |
	//| mv_par10     // Ate Modelo                     |
	//| mv_par11     // De Familia                     |
	//| mv_par12     // Ate Familia                    |
	//| mv_par13     // Imprimir Localizacao           |
	//+------------------------------------------------+
    
	Pergunte(cPerg,.F.)
    
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Envia controle para a funcao SETPRINT                        ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wnrel := SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,"")
    
	SetKey(VK_F4, {|| })
    
	If nLastKey = 27
		Set Filter To
		
		MNT045TRB( .T., vFilTRB[1], vFilTRB[2])
		
		NGRETURNPRM(aNGBEGINPRM)
		Return
	EndIf
    
	SetDefault(aReturn,cString)
	RptStatus({|lEnd| R030Imp(@lEnd,wnRel,titulo,tamanho)},titulo)
    
	MNT045TRB( .T., vFilTRB[1], vFilTRB[2])
    
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³Retorna conteudo de variaveis padroes       ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	NGRETURNPRM(aNGBEGINPRM)
    
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ R030Imp  ³ Autor ³ NG Informatica Ltda.  ³ Data ³ 03/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada do Relat¢rio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTR030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function R030Imp(lEnd,wnRel,titulo,tamanho)

Local cRodaTxt  := ""
Local nCntImpr  := 0
Local nAviso    := 0
Local cSituacao := " " 
Local nSituacao := 0
Local cLocalizacao
Local aLocalizacao := {}
Local nMaxCarac := 201
Local nContX
Local lImpCar := .F.

Private nProxMan := 0
Private cabec1,cabec2
Private ntipo    := 0
Private nomeprog := "MNTR030"    

cAliasQry := GetNextAlias()   

cQuery := " SELECT STJ.*,ST9.T9_CODFAMI,ST9.T9_TIPMOD,ST9.T9_POSCONT,ST9.T9_CONTACU,ST9.T9_VARDIA,ST9.T9_FABRICA,ST9.T9_CODBEM,"
cQuery += " ST9.T9_TPCONTA,STF.TF_CONMANU,STF.TF_INENMAN,STF.TF_TIPACOM,STF.TF_TOLERA,STF.TF_TOLECON,STF.TF_DTULTMA,"
cQuery += " STF.TF_TEENMAN,STF.TF_UNENMAN,STF.TF_SERVICO,STF.TF_SEQRELA" 
cQuery += " FROM "+RetSQLName("STJ")+" STJ,"+RetSQLName("ST9")+" ST9,"+RetSQLName("STF")+" STF "
cQuery += " WHERE STJ.TJ_SITUACA = 'L' And STJ.TJ_TERMINO = 'N' AND"    

If NGSX2MODO("STJ") == "E"
    cQuery += " STJ.TJ_FILIAL BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND"
    If NGSX2MODO("ST9") == "E"
        cQuery += " STJ.TJ_FILIAL = ST9.T9_FILIAL AND"
    EndIf
    If NGSX2MODO("STF") == "E"
        cQuery += " STJ.TJ_FILIAL = STF.TF_FILIAL AND"
    EndIf
EndIf

cQuery += " STJ.TJ_CCUSTO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' AND STJ.TJ_PLANO<>'000000'" 
cQuery += " AND STJ.TJ_TIPOOS = 'B' AND STJ.TJ_DTMPINI BETWEEN '"+Dtos(MV_PAR01)+"' AND '"+Dtos(MV_PAR02)+"'"
cQuery += " AND STJ.TJ_CODBEM = ST9.T9_CODBEM AND ST9.T9_TIPMOD BETWEEN '"+mv_par09+"' AND '"+mv_par10+"' "
cQuery += " AND ST9.T9_CODFAMI BETWEEN '"+mv_par11+"' AND '"+mv_par12+"' "
cQuery += " AND ST9.T9_CENTRAB >= '"+mv_par07+"' AND ST9.T9_CENTRAB <= '"+mv_par08+"' "
cQuery += " AND STF.TF_CODBEM=STJ.TJ_CODBEM AND STF.TF_SERVICO=STJ.TJ_SERVICO AND STF.TF_SEQRELA=STJ.TJ_SEQRELA"
cQuery += " AND STF.TF_ATIVO <> 'N' AND STF.TF_PERIODO <> 'E'"
cQuery += " AND STJ.D_E_L_E_T_ = ' ' AND STF.D_E_L_E_T_ = ' ' AND ST9.D_E_L_E_T_ = ' '"
cQuery += " ORDER BY STJ.TJ_FILIAL,STJ.TJ_CODBEM,STJ.TJ_DTMPINI,STJ.TJ_ORDEM"

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)                                 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Contadores de linha e pagina                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private li := 80 ,m_pag := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se deve comprimir ou nao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTipo  := IIF(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta os Cabecalhos                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cabec1 := STR0014 //"Bem               C.Custo               Fabricante/Modelo                          Familia  Unit.  Cont.Acumulado   Prox.Man.   Antecedência  Situação  Manutenção                           Increm.  Nr. O.S.  Data O.S."
cabec2 := STR0021 //"Localização"

//          1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2
//0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345
//__________________________________________________________________________________________________________________________________________________________________________________________________________________________________
//Bem               C.Custo               Fabricante/Modelo                          Familia  Unit.  Cont.Acumulado   Prox.Man.   Antecedência  Situação  Manutenção                           Increm.  Nr. O.S.  Data O.S.
//Localização
//__________________________________________________________________________________________________________________________________________________________________________________________________________________________________
//xxxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxxxxxx-xxxxxxxxxxxxxxxxxxxx  xxxxxx   xxx    999,999,999,999  99,999,999   999,999,999  x 99,999  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  999,999  999999    99/99/9999
//xxxxxxxxxxxxxxx > xxxxxxxxxxxxxxx > xxxxxxxxxxxxxxx > xxxxxxxxxxxxxxx
//

If EoF()
    MsgInfo( STR0029, STR0028 ) //"Não existem dados para montar o relatório."###"ATENÇÃO"
    Return .F.
EndIf

SetRegua(LastRec())
While !Eof()
    
    If lEnd
        @ PROW()+1,001 Psay STR0015 //"CANCELADO PELO OPERADOR"
        Exit
    EndIf
    IncRegua()
    
    If MNT045STB( (cAliasQry)->T9_CODBEM, vFilTRB[2] )
        dbSkip()
        Loop
    EndIf
    
    lImpCar := .T.

    //Varíaveis para tempo, quando for ambos
    nSituac2 := 0
    nAviso2  := 0
    nProx2   := 0
    nIncr2	 := 0
    cSituac2 := ""
    nIncr := 0
    //Por Contador e Ambos
    If (cAliasQry)->TF_TIPACOM $ "CA"
        //Verifica Contador
        nIncr := NGMINCSUBS((cAliasQry)->T9_CODBEM,(cAliasQry)->TF_SERVICO,(cAliasQry)->TF_SEQRELA,(cAliasQry)->TF_INENMAN)
        nProxMan := (cAliasQry)->TF_CONMANU + nIncr
        nAviso   := If(!lTolConE,(cAliasQry)->TF_TOLECON,(cAliasQry)->T9_VARDIA * (cAliasQry)->TF_TOLERA)
        
        If (cAliasQry)->T9_CONTACU >= (nProxMan - ((cAliasQry)->T9_VARDIA * nAviso))
            If (cAliasQry)->T9_CONTACU > nProxMan
                cSituacao := "A"
                nSituacao := (cAliasQry)->T9_CONTACU - nProxMan
            Else
                cSituacao := "F"
                nSituacao := nProxMan - (cAliasQry)->T9_CONTACU
            EndIf
        Else
            dbSelectArea(cAliasQry)
            dbSkip()
            Loop
        EndIf
        //Se ambos verifica por tempo
        If (cAliasQry)->TF_TIPACOM == "A"
            If (cAliasQry)->TF_UNENMAN == "D"
                nIncr2 := (cAliasQry)->TF_TEENMAN
            ElseIf (cAliasQry)->TF_UNENMAN == "S"
                nIncr2 := (cAliasQry)->TF_TEENMAN * 7
            ElseIf (cAliasQry)->TF_UNENMAN == "M"
                nIncr2 := (cAliasQry)->TF_TEENMAN * 30
            End
            nProx2 := NGPROXMANT(StoD((cAliasQry)->TF_DTULTMA),(cAliasQry)->TF_TEENMAN,(cAliasQry)->TF_UNENMAN)
            nAviso2:= (cAliasQry)->TF_TOLERA
            If dDataBase >= (nProx2 - nAviso2)
                If dDataBase > nProx2
                    cSituac2 := "A"
                    nSituac2 := dDataBase - nProx2
                Else
                    cSituac2 := "F"
                    nSituac2 := nProx2 - dDataBase
                EndIf
            EndIf
        Endif
    ElseIf (cAliasQry)->TF_TIPACOM == "T"//Por Tempo
        If (cAliasQry)->TF_UNENMAN == "D"
            nIncr := (cAliasQry)->TF_TEENMAN
        ElseIf (cAliasQry)->TF_UNENMAN == "S"
            nIncr := (cAliasQry)->TF_TEENMAN * 7
        ElseIf (cAliasQry)->TF_UNENMAN == "M"
            nIncr := (cAliasQry)->TF_TEENMAN * 30
        End
        nProxMan := NGPROXMANT(StoD((cAliasQry)->TF_DTULTMA),(cAliasQry)->TF_TEENMAN,(cAliasQry)->TF_UNENMAN)
        nAviso   := (cAliasQry)->TF_TOLERA
        If dDataBase >= (nProxMan - nAviso)
            If dDataBase > nProxMan
                cSituacao := "A"
                nSituacao := dDataBase - nProxMan
            Else
                cSituacao := "F"
                nSituacao := nProxMan - dDataBase
            EndIf
        Else
            dbSelectArea(cAliasQry)
            dbSkip()
            Loop
        EndIf
    ElseIf (cAliasQry)->TF_TIPACOM $ "S"//Por Segundo Contador
        nIncr := NGMINCSUBS((cAliasQry)->T9_CODBEM,(cAliasQry)->TF_SERVICO,(cAliasQry)->TF_SEQRELA,(cAliasQry)->TF_INENMAN)
        nProxMan := (cAliasQry)->TF_CONMANU + nIncr
        TPE->(dbSetOrder(1))
        If TPE->(dbSeek(xFILIAL("TPE")+(cAliasQry)->TJ_CODBEM))
            nPOSCONT := TPE->TPE_CONTAC
            nVARDIA  := TPE->TPE_VARDIA
            
            nAviso   := nVARDIA * (cAliasQry)->TF_TOLECON
            If nPOSCONT >= (nProxMan - nAviso)
                If nPOSCONT > nProxMan
                    cSituacao := "A"
                    nSituacao := nPOSCONT - nProxMan
                Else
                    cSituacao := "F"
                    nSituacao := nProxMan - nPOSCONT
                EndIf
            EndIf
        Else
            dbSelectArea(cAliasQry)
            dbSkip()
            Loop
        EndIf
    EndIf
    
    If Li > 58
        Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
    EndIf
    //Verifica se existem os campos na familia de bens
    If lST6Tipo
        If !Empty(NGSEEK('ST6',(cAliasQry)->T9_CODFAMI,1,'T6_TIPO1'))
            cTipo := NGSEEK('ST6',(cAliasQry)->T9_CODFAMI,1,'T6_TIPO1')
        Else
            cTipo := SubStr((cAliasQry)->T9_TPCONTA,1,3)
        Endif
    Else
        cTipo := SubStr((cAliasQry)->T9_TPCONTA,1,3)
    Endif
    
    @ Li,000 Psay (cAliasQry)->TJ_CODBEM
    @ Li,018 Psay (cAliasQry)->TJ_CCUSTO
    @ Li,040 Psay AllTrim(Substr(NGSEEK("ST7",(cAliasQry)->T9_FABRICA,1,"T7_NOME"),1,20))+"-"+AllTrim(NGSEEK("TQR",(cAliasQry)->T9_TIPMOD,1,"TQR_DESMOD"))
    @ Li,083 Psay (cAliasQry)->T9_CODFAMI
    @ Li,092 Psay cTipo
    @ Li,098 Psay PADL(Transform((cAliasQry)->T9_CONTACU,"@E 999,999,999,999"),15)
    @ Li,116 Psay nProxMan
    @ Li,129 Psay PADL(Transform(nAviso,"@E 999,999,999"),11)
    @ Li,142 Psay cSituacao
    @ Li,144 Psay PADL(Transform(nSituacao,"@E 99,999"),6)
    @ Li,152 Psay SUBSTR(NGSEEK("STF",(cAliasQry)->TJ_CODBEM+(cAliasQry)->TF_SERVICO+(cAliasQry)->TF_SEQRELA,1,"TF_NOMEMAN"),1,35)
    @ Li,189 Psay PADL(Transform(nIncr,"@E 999,999"),7)
    @ Li,198 Psay (cAliasQry)->TJ_ORDEM
    @ Li,208 Psay StoD((cAliasQry)->TJ_DTORIGI)
    
    If MV_PAR13 == 1
        // Recebe a localizaca completa do Bem
        If FindFunction("NGLocComp")
            cLocalizacao := NGLocComp((cAliasQry)->TJ_CODBEM,"1")
        EndIf
        aLocalizacao := {}
        
        If !Empty(cLocalizacao)
            If Len(cLocalizacao) > nMaxCarac
                While Len(cLocalizacao) > nMaxCarac
                    aAdd(aLocalizacao,SubStr(cLocalizacao,1,nMaxCarac))
                    cLocalizacao := SubStr(cLocalizacao,nMaxCarac+1)
                End
            EndIf
        EndIf
        
        If AllTrim(cLocalizacao) == AllTrim((cAliasQry)->TJ_CODBEM)
            aAdd(aLocalizacao,AllTrim(SubStr(NGSEEK("ST9",cLocalizacao,1,"T9_NOME"),1,nMaxCarac)))
        Else
            aAdd(aLocalizacao,cLocalizacao)
        EndIf
        
        Li++
        For nContX := 1 To Len(aLocalizacao)
            @ Li,000 Psay AllTrim(aLocalizacao[nContX])
            Li++
        Next nContX
    Endif
    
    Li++
    If !Empty(cSituac2)
        @ Li,000 Psay (cAliasQry)->TJ_CODBEM
        @ Li,018 Psay (cAliasQry)->TJ_CCUSTO
        @ Li,040 Psay AllTrim(Substr(NGSEEK("ST7",(cAliasQry)->T9_FABRICA,1,"T7_NOME"),1,20))+"-"+AllTrim(NGSEEK("TQR",(cAliasQry)->T9_TIPMOD,1,"TQR_DESMOD"))
        @ Li,083 Psay (cAliasQry)->T9_CODFAMI
        @ Li,092 Psay cTipo
        @ Li,098 Psay PADL(Transform((cAliasQry)->T9_CONTACU,"@E 999,999,999,999"),15)
        @ Li,116 Psay nProx2
        @ Li,129 Psay PADL(Transform(nAviso2,"@E 999,999,999"),11)
        @ Li,142 Psay cSituac2
        @ Li,144 Psay PADL(Transform(nSituac2,"@E 99,999"),6)
        @ Li,152 Psay NGSEEK("STF",(cAliasQry)->TJ_CODBEM+(cAliasQry)->TF_SERVICO+(cAliasQry)->TF_SEQRELA,1,"TF_NOMEMAN")
        @ Li,189 Psay PADL(Transform(nIncr2,"@E 999,999"),7)
        @ Li,198 Psay (cAliasQry)->TJ_ORDEM
        @ Li,208 Psay StoD((cAliasQry)->TJ_DTORIGI)
        
        If MV_PAR13 == 1
            // Recebe a localizaca completa do Bem
            If FindFunction("NGLocComp")
                cLocalizacao := NGLocComp((cAliasQry)->TJ_CODBEM,"1")
            EndIf
            aLocalizacao := {}
            
            If !Empty(cLocalizacao)
                If Len(cLocalizacao) > nMaxCarac
                    While Len(cLocalizacao) > nMaxCarac
                        aAdd(aLocalizacao,SubStr(cLocalizacao,1,nMaxCarac))
                        cLocalizacao := SubStr(cLocalizacao,nMaxCarac+1)
                    End
                EndIf
            EndIf
            
            If AllTrim(cLocalizacao) == AllTrim((cAliasQry)->TJ_CODBEM)
                aAdd(aLocalizacao,AllTrim(SubStr(NGSEEK("ST9",cLocalizacao,1,"T9_NOME"),1,nMaxCarac)))
            Else
                aAdd(aLocalizacao,cLocalizacao)
            EndIf
            
            Li++
            For nContX := 1 To Len(aLocalizacao)
                @ Li,000 Psay AllTrim(aLocalizacao[nContX])
                Li++
            Next nContX
        Endif
        
        Li++
        
    Endif
    dbSelectArea(cAliasQry)
    dbSkip()
EndDo

(cAliasQry)->(dbCloseArea())

If lImpCar
    Roda(nCntImpr,cRodaTxt,Tamanho)
Else
    MsgInfo(STR0029, STR0028) //"Não existem dados para montar o relatório."###"ATENÇÃO"
    Return .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve a condicao original do arquivo principal             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Set Filter To

Set device to Screen

If aReturn[5] = 1
    Set Printer To
    dbCommitAll()
    OurSpool(wnrel)
EndIf

MS_FLUSH()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNTR030DT ³ Autor ³Evaldo Cevinscki Jr.   ³ Data ³ 27/11/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida o parametro ate data                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR030                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNTR030DT()
    
If MV_PAR02 < MV_PAR01
    MsgStop(STR0016) //"Data final não pode ser inferior à data inicial!"
    Return .F.
EndIf
    
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |MNTR030FL | Autor ³Evaldo Cevinscki Jr.   ³ Data ³ 27/11/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o |Valida codigos de Filial, Ate Filial                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR030                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNTR030FL(nOpc,cParDe,cParAte)

If Empty(cParDe) .AND. (cParAte == Replicate('Z',nSizeFil))
    Return .T.
Else
    If nOpc == 1
        If Empty(cParDe)
            Return .t.
        Else
            lRet := IIf(Empty(cParDe),.t.,ExistCpo('SM0',SM0->M0_CODIGO+cParDe))
            If !lRet
                Return .f.
            EndIf
        Endif
    Elseif nOpc == 2
        If (cParAte == Replicate('Z',nSizeFil))
            Return .t.
        Else
            lRet := IIF(ATECODIGO('SM0',SM0->M0_CODIGO+cParDe,SM0->M0_CODIGO+cParAte,2+nSizeFil),.T.,.F.)
            If !lRet
                Return .f.
            EndIf
        Endif
    EndIf
EndIf
       
Return .t.
