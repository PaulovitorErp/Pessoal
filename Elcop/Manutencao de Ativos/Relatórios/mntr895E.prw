#Include "Protheus.ch"

//-----------------------------------------------------------------------------
/*/{Protheus.doc} MNTR895E
Relatório de Manutenções em Atraso

@author Marcos Wagner Junior
@since 12/08/2008

@sample MNTR895()

@param  
@return
/*/
//-----------------------------------------------------------------------------
user Function MNTR895E()
    
	Local aNGBEGINPRM := NGBEGINPRM()
    
	WNREL            := "MNTR895E"
	LIMITE           := 182
	cDESC1           := "O relatorio apresentará as manutenções atrasadas."
	cDESC2           := ""
	cDESC3           := ""
	cSTRING          := "STF"
	
    Private cTRB1	 := GetNextAlias() //Alias Tabela Temporária
	Private NOMEPROG := "MNTR895E"
	Private TAMANHO  := "G"
	Private aRETURN  := {"Zebrado",1,"Administracao",1,2,1,"",1} //"Zebrado"###"Administracao"
	Private TITULO   := "Relatório de Manutenções em Atraso"
	Private nTIPO    := 0
	Private nLASTKEY := 0
	Private CABEC1   := ""
	Private CABEC2   := ""
	Private aVETINR  := {}
	Private cPerg 	 := "MNR895    "
	Private aPerg 	 := {}
    
    /*---------------------------------------------------------------
    Vetor utilizado para armazenar retorno da função MNTTRBSTB,
    criada de acordo com o item 18 (RoadMap 2013/14)
    ---------------------------------------------------------------*/
	Private vFilTRB := MNT045TRB()
    
	SetKey(VK_F4, {|| MNT045FIL( vFilTRB[2] )})
    
	Pergunte(cPERG,.F.)
    
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Envia controle para a funcao SETPRINT                        ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	WNREL := SetPrint(cSTRING,WNREL,cPERG,TITULO,cDESC1,cDESC2,cDESC3,.F.,"")
    
	SetKey(VK_F4, {|| })
    
	If nLASTKEY = 27
		Set Filter To
		dbSelectArea("STF")
		
		MNT045TRB( .T., vFilTRB[1], vFilTRB[2])
		
		Return
	EndIf
    
	SetDefault(aReturn,cSTRING)
    
	RptStatus({|lEND| MNTR895IMP(@lEND,WNREL,TITULO,TAMANHO)},"Aguarde...","Processando Registros...") //"Aguarde..."###"Processando Registros..."
    
	dbSelectArea("STF")
    
	MNT045TRB( .T., vFilTRB[1], vFilTRB[2])
    
	NGRETURNPRM(aNGBEGINPRM)
    
Return Nil

//-----------------------------------------------------------------------------
/*/{Protheus.doc} MNT280AJU
Impressao do Relatorio

@author Marcos Wagner Junior
@since 12/08/2008

@sample MNTR895IMP(lEND,WNREL,TITULO,TAMANHO)

@param  lEnd   , Lógico  , Verifica se a operação foi cancelada pelo usuario.
        wNrel  , Array   , Configurações da impressão.
		Titulo , Caracter, Titulo do relatório.
		Tamanho, Caracter, Tamanho do relatório (P e G).
@return lRet, Lógico, Se foi realizado a impressão corretamente.
/*/
//-----------------------------------------------------------------------------
static Function MNTR895IMP(lEND,WNREL,TITULO,TAMANHO)
    
    Local lRet       := .T.
    Local aINDXTR1   := {}
    Local oARQXTR1   := Nil
    
    Private cRODATXT := ""
    Private nCNTIMPR := 0
    Private li       := 80 
	Private m_pag    := 1
    
    CABEC1 := "Bem        Placa    Nome                                      Serviço                         Ult. Man   Prox.Man   Dias Venc  Num OS  Cont.Atual   Ult. Manut  Incremt       Vencido"

    CABEC2 := " "
    
    /*
1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         1         2
0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
    ****************************************************************************************************************************************************************************************************************************
    Relatorio de Pneus
    ****************************************************************************************************************************************************************************************************************************
    -------------------------- Contador -------------------------
Bem        Placa    Nome                                      Descrição                       Ult. Man  Prox.Man Dias Venc Num OS   Cont.Atual   Ult. Manut  Incremt      Vencido

xxxxxxxxxx 12345678 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  99/99/99  99/99/99   99999   123456  999,999,999  999,999,999   99.999  999,999,999
                    1234567890123456789012345678901234567890
    */
    
    aCampo1 := {}
	    aAdd(aCampo1,{"CODBEB" , "C", 10, 0})
	    aAdd(aCampo1,{"PLACA"  , "C", 08, 0})
	    aAdd(aCampo1,{"NOMEBE" , "C", 40, 0})
	    aAdd(aCampo1,{"DESERV" , "C", 40, 0})
	    aAdd(aCampo1,{"DTULMA" , "D", 08, 0})
	    aAdd(aCampo1,{"DTPRMA" , "D", 08, 0})
	    aAdd(aCampo1,{"DVENCI" , "N", 05, 0})    
	    aAdd(aCampo1,{"TIPACO" , "C", 01, 0})
	    aAdd(aCampo1,{"NUMOS"  , "C", 06, 0})
	    aAdd(aCampo1,{"CONTACU", "N", 09, 0})
	    aAdd(aCampo1,{"CONMAN" , "N", 12, 0})
	    aAdd(aCampo1,{"INCMAN" , "N", 06, 0})
	    aAdd(aCampo1,{"POSVEN" , "N", 12, 0})
    
    aINDXTR1 := {{"CODBEB","DTPRMA"},;
			     {"DVENCI","CODBEB","DTPRMA"},;
			     {"POSVEN","CODBEB","DTPRMA"}}
    
    //Cria Tabela Temporária 
	oARQXTR1 := NGFwTmpTbl(cTRB1, aCampo1, aINDXTR1)
    
    cAliasQry := GetNextAlias()

    BeginSQL Alias cAliasQry

        SELECT ST9.T9_CODBEM, ST9.T9_NOME, ST9.T9_VARDIA, ST9.T9_POSCONT, ST9.T9_DTULTAC, ST9.T9_CONTACU,
               ST4.T4_NOME, STF.TF_TEENMAN, STF.TF_UNENMAN, STF.TF_CONMANU, STF.TF_INENMAN, STF.TF_TIPACOM,
               STF.TF_FILIAL, STF.TF_SERVICO, STF.TF_SEQRELA, STF.TF_DTULTMA, ST9.T9_PLACA
        FROM %table:ST9% ST9

        JOIN %table:STF% STF
            ON ST9.T9_CODBEM = STF.TF_CODBEM AND STF.TF_FILIAL = %xFilial:STF%
                AND STF.%NotDel%

        JOIN %table:ST4% ST4
            ON ST4.T4_SERVICO = STF.TF_SERVICO AND ST4.T4_FILIAL = %xFilial:ST4%
                AND ST4.%NotDel%
            
            WHERE ST9.T9_CODBEM  BETWEEN %Exp:MV_PAR04% AND %Exp:MV_PAR05%
                AND ST9.T9_CODFAMI BETWEEN %Exp:MV_PAR02% AND %Exp:MV_PAR03%
                AND ST9.T9_SITBEM = 'A' AND ST9.T9_SITMAN = 'A'
                AND STF.TF_ATIVO = 'S' AND STF.TF_PERIODO <> 'E'
                AND ST9.T9_FILIAL = %xFilial:ST9%
                AND ST9.%NotDel%
            
    EndSQL
    
    SetRegua(LastRec())
    If !EoF()
        While !EoF()
            
            dbSelectArea("STF")
            dbSetOrder(01)
            If dbSeek(xFilial("STF")+(cAliasQry)->T9_CODBEM+(cAliasQry)->TF_SERVICO+(cAliasQry)->TF_SEQRELA)
                //-- Filtro de usuario
                If !Empty(aReturn[7])
                    If STF->( ! &(aReturn[7]) )
                        (cAliasQry)->(DbSkip())
                        Loop
                    EndIf
                EndIf
                
                If MNT045STB( (cAliasQry)->T9_CODBEM, vFilTRB[2] )
                    (cAliasQry)->(dbSkip())
                    Loop
                EndIf
                
                cTipAcomp := (cAliasQry)->TF_TIPACOM
                
                If (cAliasQry)->TF_TIPACOM == 'A'
                    dDATATEM := NGPROXMAN(STOD((cAliasQry)->TF_DTULTMA),"T",(cAliasQry)->TF_TEENMAN,;
                        (cAliasQry)->TF_UNENMAN,(cAliasQry)->TF_CONMANU,(cAliasQry)->TF_INENMAN,;
                        (cAliasQry)->T9_CONTACU,(cAliasQry)->T9_VARDIA)
                    
                    dDATACON := NGPROXMAN(STOD((cAliasQry)->T9_DTULTAC),"C",(cAliasQry)->TF_TEENMAN,;
                        (cAliasQry)->TF_UNENMAN,(cAliasQry)->TF_CONMANU,(cAliasQry)->TF_INENMAN,;
                        (cAliasQry)->T9_CONTACU,(cAliasQry)->T9_VARDIA)
                    
                    If dDATATEM < dDATACON
                        dDataRet  := dDATATEM
                        cTipAcomp := "T"
                    Else
                        If MV_PAR07 == 2
                            If (cAliasQry)->T9_CONTACU <= STF->TF_CONMANU + STF->TF_INENMAN
                                dbSelectArea(cAliasQry)
                                dbSkip()
                                Loop
                            EndIf
                            dDataRet := dDATACON
                            cTipAcomp := "C"
                        Else
                            dDataRet := dDATACON
                            cTipAcomp := "C"
                        EndIf
                    EndIf
                Else
                    If (cAliasQry)->TF_TIPACOM == 'C' .And. MV_PAR07 == 2
                        If (cAliasQry)->T9_CONTACU <= STF->TF_CONMANU + STF->TF_INENMAN
                            dbSelectArea(cAliasQry)
                            dbSkip()
                            Loop
                        EndIf
                        dDataRet := NGXPROXMAN((cAliasQry)->T9_CODBEM)
                    Else
                        dDataRet := NGXPROXMAN((cAliasQry)->T9_CODBEM)
                    EndIf
                Endif
                
                While dDataRet <= MV_PAR01 .AND. dDataRet > STOD((cAliasQry)->TF_DTULTMA)
                    IncRegua()
                    dbSelectArea(cTRB1)
                    dbSetOrder(01)
                    If !dbSeek((cAliasQry)->T9_CODBEM+(cAliasQry)->TF_SERVICO+(cAliasQry)->TF_SEQRELA)
                        NGIFDBSEEK("TPE",(cAliasQry)->T9_CODBEM,1)    
                        vNumOS	:= NGPROCOSAB( ,"B",(cAliasQry)->T9_CODBEM,(cAliasQry)->TF_SERVICO,(cAliasQry)->TF_SEQRELA)
                        
                        dbSelectArea(cTRB1)
                        RecLock(cTRB1,.t.)
                        (cTRB1)->CODBEB := (cAliasQry)->T9_CODBEM
                        (cTRB1)->PLACA  := (cAliasQry)->T9_PLACA
                        (cTRB1)->NOMEBE := (cAliasQry)->T9_NOME
                        (cTRB1)->DESERV := (cAliasQry)->T4_NOME
                        (cTRB1)->DTULMA := STOD((cAliasQry)->TF_DTULTMA)
                        (cTRB1)->DTPRMA := dDataRet
                        (cTRB1)->DVENCI := dDATABASE - dDataRet  
                        (cTRB1)->TIPACO := cTipAcomp
                        (cTRB1)->NUMOS	:= vNumOS[2]
                        
                        If cTipAcomp == 'C' .OR. cTipAcomp == 'F' .OR. cTipAcomp == 'S' .OR. cTipAcomp == 'P'
                            (cTRB1)->CONTACU := IIF(cTipAcomp=='S',TPE->TPE_POSCON,(cAliasQry)->T9_CONTACU)
                            (cTRB1)->CONMAN := (cAliasQry)->TF_CONMANU
                            (cTRB1)->INCMAN := (cAliasQry)->TF_INENMAN
                            (cTRB1)->POSVEN := (cAliasQry)->TF_CONMANU + (cTRB1)->INCMAN - IIF(cTipAcomp=='S',TPE->TPE_CONTAC,(cAliasQry)->T9_CONTACU)
                        ElseIf cTipAcomp == 'T'
                            (cTRB1)->INCMAN := (cAliasQry)->TF_TEENMAN
                            (cTRB1)->UNIDAD := (cAliasQry)->TF_UNENMAN
                            (cTRB1)->POSVEN := dDATABASE - dDataRet
                        EndIf
                        
                        (cTRB1)->(MsUnlock())       
                    Endif
                    exit
                EndDo
            EndIf
            
            dbSelectArea(cAliasQry)
            dbSkip()
        EndDo
    Endif
    
    (cAliasQry)->(dbCloseArea())
    
    dbSelectArea(cTRB1)
    SetRegua(LastRec())
    If MV_PAR06 == 1
        dbSetOrder(01)
    ElseIf MV_PAR06 == 2
        dbSetOrder(02)
    Else
        dbSetOrder(03)
    Endif
    dbGoTop()
    If !Eof()
        NgSomaLi(58)
        While !Eof()
            IncRegua()
            If lEnd
                @ Prow()+1,001 PSay "CANCELADO PELO OPERADOR"
                Exit
            EndIf
            @ Li,000 Psay (cTRB1)->CODBEB      
            @ Li,011 Psay (cTRB1)->PLACA    
            @ Li,020 PSay SubStr((cTRB1)->NOMEBE,1,40)
            @ Li,063 PSay SubStr((cTRB1)->DESERV,1,30)
            @ Li,094 PSay (cTRB1)->DTULMA Picture "99/99/9999"
            @ Li,105 PSay (cTRB1)->DTPRMA Picture "99/99/9999"
            @ Li,118 PSay AllTrim(Transform((cTRB1)->DVENCI,"@E 99,999"))
			@ Li,127 Psay (cTRB1)->NUMOS            
            If (cTRB1)->CONTACU != 0
                @ Li,134 PSay PADL(Transform((cTRB1)->CONTACU,"@E 999,999,999"),11)
            Endif
            
            If (cTRB1)->CONMAN != 0
                @ Li,147 PSay PADL(Transform((cTRB1)->CONMAN,"@E 999,999,999"),11)
            Endif
            
            @ Li,160 PSay PADL(Transform((cTRB1)->INCMAN,"@E 999,999"),07)
            
            If (cTRB1)->POSVEN != 0
                If (cTRB1)->TIPACO == 'T'
                    @ Li,169 PSay PADL(Transform((cTRB1)->POSVEN,"@E 999,999,999"),11) + ' D'
                Else
                    @ Li,169 PSay PADL(Transform((cTRB1)->POSVEN,"@E 999,999,999"),11)
                Endif
            Endif
            NgSomaLi(58)
            dbSelectArea(cTRB1)
            dbSkip()
        EndDo
    Else
        MsgInfo("Não existem dados para montar o Relatório!","Atenção!")
        lRet := .F.
    Endif
    
    If lRet
        Roda(nCNTIMPR,cRODATXT,TAMANHO)
    
        //---------------------------------------------------------------
        // Devolve a condicao original do arquivo principal
        //---------------------------------------------------------------
        RetIndex('STF')
        Set Filter To
        Set Device To Screen
        If aReturn[5] == 1
            Set Printer To
            dbCommitAll()
            OurSpool(WNREL)
        EndIf
        MS_FLUSH()
    EndIf
    
    // Deleta Tabela Temporária 
    oARQXTR1:Delete()
    
Return lRet