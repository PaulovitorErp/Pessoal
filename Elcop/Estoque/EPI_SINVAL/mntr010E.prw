#Include "Protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MNTR010E  ³ Autor ³ Sinval Gedolin       ³ Data ³04/08/2020³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio para listar manutencoes a vencer dentro do       ³±±
±±³          ³ periodo                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
user Function MNTR010E()
    
    Local aNGBEGINPRM := NGBEGINPRM()
    
    Local cString    := "STF"
    Local cDesc1     := "Relatório de manutenções a vencer dentro do período selecionado"
    Local cDesc2     := "nos parâmetros."
    Local cDesc3     := ""
    Local wnrel      := "MNTR010E"
    
    Private aReturn  := {"Zebrado", 1,"Administração", 1, 2, 1, "",1 }  //"Zebrado"###"Administração"
    Private nLastKey := 0
    Private cPerg    := "MNT010"
    Private Titulo   := "Manutenções a Vencer no Período"
    Private Tamanho  := "G"
    Private nomeprog := "MNTR010E"
    
    /*---------------------------------------------------------------
    Vetor utilizado para armazenar retorno da função MNT045TRB,
    criada de acordo com o item 18 (RoadMap 2013/14)
    ---------------------------------------------------------------*/
    Private vFilTRB := MNT045TRB()
    
	SetKey(VK_F4, {|| MNT045FIL( vFilTRB[2] )})
        
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Variaveis utilizadas para qarametros!                        ³
    //³ mv_par01     De Bem                                          ³
    //³ mv_par02     Ate Bem                                         ³
    //³ mv_par03     De Servico                                      ³
    //³ mv_par04     Ate Servico                                     ³
    //³ mv_par05     De Data                                         ³
    //³ mv_par06     Ate Data                                        ³
    //³ mv_par07     Considera (Todas, Somente sem Os)               ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
   
	Pergunte(cPerg,.F.)
    
    wnrel := SetPrint( cString, wnrel, cPerg, titulo, cDesc1, cDesc2, cDesc3, .F., "" )
    
    SetKey(VK_F4, {|| })
    
    If nLastKey = 27
        Set Filter To
        dbSelectArea("STF")
        
        MNT045TRB( .T., vFilTRB[1], vFilTRB[2])
        
        Return
    Endif
    
    Titulo := "Manutenções a Vencer no Período de " + DToC(MV_PAR05) + " á " + DToC(MV_PAR06) //###
    
    SetDefault(aReturn,cString)
    RptStatus({|lEnd| RFR010Imp(@lEnd,wnRel,titulo,tamanho)},titulo)
    
    dbSelectArea("STF")
    
    MNT045TRB( .T., vFilTRB[1], vFilTRB[2])
    
    /*----------------------------------------------------------------
     Devolve a condicao original do arquivo principal
    ----------------------------------------------------------------*/
    RetIndex("STF")
    Set Filter To
    Set device to Screen
    
    If aReturn[5] == 1
        Set Printer To
        dbCommitAll()
        OurSpool(wnrel)
    EndIf
    
    MS_FLUSH()
    
    NGRETURNPRM(aNGBEGINPRM)
    
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³RFR010Imp ³ Autor ³ Elisangela Costa      ³ Data ³ 26/09/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Chamada do Relat¢rio                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
static Function RFR010Imp(lEND,WNREL,TITULO,TAMANHO)
    
    Local cRODATXT  := ""
    Local nCNTIMPR  := 0
    Local lImpRel   := .F.
    
    Private li := 80 ,m_pag := 1
    
    nTIPO  := IIf( aReturn[4] == 1, 15, 18 )
    CABEC1 := "Bem       Placa    Veiculo                             Descrição Manutençao                Dt.Ult.Man. Dt.Próx.Man Ord Serv  Contador Dt.Contad. Var.Di KM Prev. Dias"
    CABEC2 := " "
    
    cCondicao := 'STF->TF_SERVICO >= MV_PAR03 .And. STF->TF_SERVICO <= MV_PAR04'
    
    /*/
    1         2         3         4         5         6         7         8         9         0         1         2         3
    0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
    *************************************************************************************************************************************
Bem       Placa    Descrição                                Descrição                      Dt.Ult.Man. Dt.Próx.Man Ord Serv Contador Dt.Contad. Var.Di KM Prev. Dias
123456789 12345678 123456789012345678901234567890 1234567890123456789012345678901234567890
    *************************************************************************************************************************************
                                                                                                                    
xxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxcxxxxxxxxxxxxxxxxxxxxxxx  99/99/9999 99/99/9999   xxxxxx   999.999 12/12/1234  9999  999.999  9999
    
    */
    dbSelectArea("STF")
    dbSetOrder(01)
    dbSeek(xFilial("STF") + MV_PAR01, .T.)
        
    SetRegua(LastRec())
    
    While !Eof() .And. STF->TF_FILIAL == xFilial("STF") .And.;
            STF->TF_CODBEM <= MV_PAR02
        
        cCODBEMSTF := STF->TF_CODBEM
        lPRIIMPB   := .T.
        
        If MNT045STB( STF->TF_CODBEM, vFilTRB[2] )
            dbSkip()
            Loop
        EndIf
        
        While !Eof() .And. STF->TF_FILIAL == xFilial("STF") .And.;
                STF->TF_CODBEM == cCODBEMSTF
            
            IncRegua()
            
            If &(cCondicao)
                
                vOSABER := NGPROCOSAB( ,"B",STF->TF_CODBEM,STF->TF_SERVICO,STF->TF_SEQRELA)
                If MV_PAR07 == 2
                    If !vOSABER[1]
                        dbSelectArea("STF")
                        dbSkip()
                        Loop
                    EndIf
                EndIf
                
                dDataProx := NGXPROXMAN(STF->TF_CODBEM)
                
                If dDataProx >= MV_PAR05 .And. dDataProx <= MV_PAR06
                    If STF->TF_ATIVO == "N"
                        dbSelectArea("STF")
                        dbSkip()
                        Loop
                    EndIf
                    
                    If STF->TF_PERIODO == "E"
                        dbSelectArea("STF")
                        dbSkip()
                        Loop
                    EndIf
                    
                    lImpRel := .T.
                    
                    NGSOMALI(58)
                    If lPRIIMPB
                        lPRIIMPB := .F.
                        @LI,000 Psay substr(STF->TF_CODBEM,1,09)  Picture "@!"
                    	@LI,010 PSay NGSEEK('ST9',STF->TF_CODBEM,1,'T9_PLACA')
                        @LI,019 Psay NGSEEK('ST9',STF->TF_CODBEM,1,'Substr(T9_NOME,1,30)')  Picture "@!"
                    EndIf
                    
                    @LI,051 Psay NGSEEK('ST4',STF->TF_SERVICO,1,'Substr(T4_NOME,1,40)')  Picture "@!"
                    @LI,092 Psay STF->TF_DTULTMA Picture "99/99/9999"
                    @LI,104 Psay dDataProx Picture "99/99/9999"
                    @LI,117 Psay vOSABER[2] Picture "@!"      
                    @LI,126 PSay Transform(NGSEEK('ST9',STF->TF_CODBEM,1,'T9_POSCONT'),"@e 999,999")
                    @LI,134 Psay NGSEEK('ST9',STF->TF_CODBEM,1,'T9_DTULTAC') Picture "99/99/9999"
                    @LI,146 Psay Transform(NGSEEK('ST9',STF->TF_CODBEM,1,'T9_VARDIA'),"@e 9999")
					if !Empty(alltrim(vOSABER[2]))
	                    @LI,152 PSay Transform(NGSEEK('STJ',vOSABER[2]    ,1,'TJ_CONTINI'),"@e 999,999")
    	                @LI,161 Psay (NGSEEK('STJ',vOSABER[2]    ,1,'TJ_CONTINI') - NGSEEK('ST9',STF->TF_CODBEM,1,'T9_POSCONT') ) ;
        	             / IF(NGSEEK('ST9',STF->TF_CODBEM,1,'T9_VARDIA')=0,1,NGSEEK('ST9',STF->TF_CODBEM,1,'T9_VARDIA')) Picture "@E 9999"
                    else
	                    @LI,152 PSay Transform(STF->(TF_CONMANU+TF_INENMAN),"@e 999,999")
    	                @LI,161 Psay (STF->(TF_CONMANU+TF_INENMAN) - NGSEEK('ST9',STF->TF_CODBEM,1,'T9_POSCONT') ) ;
        	             / IF(NGSEEK('ST9',STF->TF_CODBEM,1,'T9_VARDIA')=0,1,NGSEEK('ST9',STF->TF_CODBEM,1,'T9_VARDIA')) Picture "@E 9999"                        
                        
     				endif
                EndIf
            EndIf
            dbSelectArea("STF")
            dbSkip()
        EndDo
    EndDo
    
    If lImpRel
        Roda(nCntImpr,cRodaTxt,Tamanho)
    Else
        MsgInfo("STR0019", "STR0018")
        Return .F.
    EndIf
    
Return .T.
