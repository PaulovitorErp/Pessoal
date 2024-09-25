#Include "MNTR010.ch"
#Include "Protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MNTR010  ³ Autor ³ Elisangela Costa      ³ Data ³26/09/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio para listar manutencoes a vencer dentro do       ³±±
±±³          ³ periodo                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTR010()
    
    Local aNGBEGINPRM := NGBEGINPRM()
    
    Local cString    := "STF"
    Local cDesc1     := STR0001 //"Relatório de manutenções a vencer dentro do período selecionado"
    Local cDesc2     := STR0002 //"nos parâmetros."
    Local cDesc3     := ""
    Local wnrel      := "MNTR010"
    
    Private aReturn  := {STR0003, 1,STR0004, 1, 2, 1, "",1 }  //"Zebrado"###"Administração"
    Private nLastKey := 0
    Private cPerg    := "MNT010"
    Private Titulo   := STR0005 //"Manutenções a Vencer no Período"
    Private Tamanho  := "M"
    Private nomeprog := "MNTR010"
    
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
    
    Titulo := STR0015 + DToC(MV_PAR05) + STR0016 + DToC(MV_PAR06) //"Manutenções a Vencer no Período de "###" á "
    
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
Function RFR010Imp(lEND,WNREL,TITULO,TAMANHO)
    
    Local xx
    Local cRODATXT  := ""
    Local nCNTIMPR  := 0
    Local nMULT     := 1
    Local lImpRel   := .F.
    
    Private li := 80 ,m_pag := 1
    
    nTIPO  := IIf( aReturn[4] == 1, 15, 18 )
    CABEC1 := STR0017 //"Bem              Descrição                      Serviço Descrição                      Seq. Dt.Ult.Manut. Dt.Próx.Manut. Ordem Serv."
    CABEC2 := " "
    
    cCondicao := 'STF->TF_SERVICO >= MV_PAR03 .And. STF->TF_SERVICO <= MV_PAR04'
    
    /*/
    1         2         3         4         5         6         7         8         9         0         1         2         3
    0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
    *************************************************************************************************************************************
    Bem              Descrição                      Serviço Descrição                      Seq. Dt.Ult.Manut. Dt.Próx.Manut. Ordem Serv.
    *************************************************************************************************************************************
    
    xxxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx xxxxxx  xxxxxxxxxxxxxxxxcxxxxxxxxxxxxx xxx  99/99/9999    99/99/9999     xxxxxx
    
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
                        @LI,000 Psay STF->TF_CODBEM  Picture "@!"
                        @LI,017 Psay NGSEEK('ST9',STF->TF_CODBEM,1,'Substr(T9_NOME,1,30)')  Picture "@!"
                    EndIf
                    
                    @LI,048 Psay STF->TF_SERVICO  Picture "@!"
                    @LI,056 Psay NGSEEK('ST4',STF->TF_SERVICO,1,'Substr(T4_NOME,1,30)')  Picture "@!"
                    @LI,087 Psay STF->TF_SEQRELA Picture "@!"
                    @LI,092 Psay STF->TF_DTULTMA Picture "99/99/9999"
                    @LI,106 Psay dDataProx Picture "99/99/9999"
                    @LI,121 Psay vOSABER[2] Picture "@!"
                EndIf
            EndIf
            dbSelectArea("STF")
            dbSkip()
        EndDo
    EndDo
    
    If lImpRel
        Roda(nCntImpr,cRodaTxt,Tamanho)
    Else
        MsgInfo(STR0019, STR0018)
        Return .F.
    EndIf
    
Return .T.