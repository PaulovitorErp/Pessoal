#INCLUDE "MNTR915.ch"
#INCLUDE "PROTHEUS.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTR915()
Relatorio de Bens Penhorados 

@author Ricardo Dal Ponte
@since 22/03/2007
@return .T.
/*/
//---------------------------------------------------------------------
Function MNTR915()
    
    Local aNGBEGINPRM  := NGBEGINPRM()
    
    Private cAliasQry  := GetNextAlias()
    Private lnRegistro := .F.
    
    Private NomeProg := "MNTR915"
    Private Tamanho  := "G"
    Private aReturn  := {STR0001,1,STR0002,1,2,1,"",1} //"Zebrado" ## "Administracao"
    Private Titulo   := STR0003 //"Relatório de Bens Penhorados"
    Private nTipo    := 0
    Private nLastKey := 0
    Private Cabec1, Cabec2
    Private aVETINR := {}
    Private cPerg   := "MNT915"
    Private aPerg   :={}
    
    /*---------------------------------------------------------------
    Vetor utilizado para armazenar retorno da função MNT045TRB,
    criada de acordo com o item 18 (RoadMap 2013/14)
    ---------------------------------------------------------------*/
    Private vFilTRB := MNT045TRB()
    
    SetKey(VK_F4, {|| MNT045FIL( vFilTRB[2] )})
    
    WNREL      := "MNTR915"
    LIMITE     := 232
    cDESC1     := STR0004 //"O relatório classificará e totalizará o valor da penhora por filial, "
    cDESC2     := STR0005 //"familia, modelo e data da indicação do bem. "
    cDESC3     := ""
    cSTRING    := ""
    
    Pergunte(cPERG,.F.)
    //---------------------------------------------------
    // Envia controle para a funcao SETPRINT
    //---------------------------------------------------
    WNREL := SetPrint(cSTRING,WNREL,cPERG,TITULO,cDESC1,cDESC2,cDESC3,.F.,"")
    
    SetKey(VK_F4, {|| })
    
    If nLASTKEY = 27
        Set Filter To
        MNT045TRB( .T., vFilTRB[1], vFilTRB[2])
        dbSelectArea("TS3")
        Return
    EndIf
    
    SetDefault(aReturn,cSTRING)
    
    RptStatus({|lEND| MNTR915IMP(@lEND,WNREL,TITULO,TAMANHO)},STR0019,STR0020) //"Aguarde..."###"Processando Registros..."
    
    dbSelectArea("TS3")
    
    MNT045TRB( .T., vFilTRB[1], vFilTRB[2])
    
    NGRETURNPRM(aNGBEGINPRM)
    
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTR915IMP()
Chamada do Relatorio 

@author Ricardo Dal Ponte
@since 22/03/2007
@return nil
/*/
//---------------------------------------------------------------------
Function MNTR915IMP(lEND,WNREL,TITULO,TAMANHO)

    Local nI
    // [LGPD] Se as funcionalidades, referentes à LGPD, podem ser utilizadas
    Local lLgpd := FindFunction( 'FWPDCanUse' ) .And. FwPdCanUse( .T. )
    Local lAdvog := .F.
	Local lReclam := .F.
	Local aOfusc := {}

    Private cRODATXT := ""
    Private nCNTIMPR := 0
    Private li := 80 ,m_pag := 1
    Private cNomeOri
    Private aVetor := {}
    Private aTotGeral := {}
    Private nAno, nMes
    Private nTotCarga := 0, nTotManut := 0
    Private nTotal := 0

    If lLgpd
        // [LGPD] Caso o usuário não possua acesso ao(s) campo(s), deve-se ofuscá-lo(s)
		aOfusc := FwProtectedDataUtil():UsrAccessPDField( __CUSERID, { 'TS3_ADVOG', 'TS3_RECLAM' } )
		lAdvog := Ascan( aOfusc, { |x| AllTrim(x) == 'TS3_ADVOG' } ) == 0
		lReclam:= Ascan( aOfusc, { |x| AllTrim(x) == 'TS3_RECLAM' } ) == 0
	EndIf
    
    Processa({|lEND| MNTR915TMP()},STR0021) //"Processando Arquivo..."
    
    If lnRegistro = .T.
        Return
    EndIf
    
    nTIPO  := IIf(aReturn[4]==1,15,18)
    
    CABEC1 := ""
    CABEC2 := ""
    
    dbSelectArea(cAliasQry)
    SetRegua(LastRec())
    
    lPvez := .T.
    nTOTAL     := 0
    nTOTALACAO := 0
    
    While !EoF()
        IncProc()
        
        If MNT045STB( (cALIASQRY)->TS3_CODBEM, vFilTRB[2] )
            dbSkip()
            Loop
        EndIf
        
        If lPvez = .T.
            NgSomaLi(58)
            @ Li,000 Psay STR0022 //"Filial"
            @ Li,031 Psay STR0023 //"Bem"
            @ Li,049 Psay STR0024 //"Descricao do Bem"
            @ Li,076 Psay STR0025 //"Placa"
            @ Li,086 Psay STR0026 //"Dt.Indi."
            @ Li,098 Psay STR0027 //"Dt.Acao"
            @ Li,110 Psay STR0028 //"Reclamante"
            @ Li,137 Psay STR0029 //"Advogado"
            @ Li,164 Psay STR0030 //"Processo"
            @ Li,194 Psay STR0037 //"Valor Ação"
            @ Li,211 Psay STR0031 //"Valor Bem"
            
            NgSomaLi(58)
            @ Li,000 	 Psay Replicate("-",220)
            NgSomaLi(58)
            
            lPvez := .F.
        EndIf
        
        dbSelectArea("SM0")
        dbSetOrder(1)
        
        cDESFIL := ""
        If dbSeek(cEmpAnt+(cALIASQRY)->TS3_FILIAL)
            cDESFIL := SM0->M0_FILIAL
        EndIf
        
        @ Li,000 	 Psay (cALIASQRY)->TS3_FILIAL+" - "+Substr(cDESFIL,1,18) Picture "@!"
        @ Li,031 	 Psay (cALIASQRY)->TS3_CODBEM             Picture "@!"
        @ Li,049 	 Psay Substr((cALIASQRY)->T9_NOME,1,25)   Picture "@!"
        @ Li,076 	 Psay (cALIASQRY)->TS3_PLACA  Picture "@!"
        @ Li,086 	 Psay DTOC(STOD((cALIASQRY)->TS3_DTIND))  Picture "99/99/9999"
        @ Li,098 	 Psay DTOC(STOD((cALIASQRY)->TS3_DTACAO)) Picture "99/99/9999"
        If lReclam
            @ Li,110 	 Psay FwProtectedDataUtil():ValueAsteriskToAnonymize( Substr( (cALIASQRY)->TS3_RECLAM, 1, 25 ) ) Picture "@!"
        Else
            @ Li,110 	 Psay Substr( (cALIASQRY)->TS3_RECLAM, 1, 25 ) Picture "@!"
        EndIf
        If lAdvog
            @ Li,137 	 Psay FwProtectedDataUtil():ValueAsteriskToAnonymize( Substr( (cALIASQRY)->TS3_ADVOG, 1, 25 ) )  Picture "@!"
        Else
            @ Li,137 	 Psay Substr( (cALIASQRY)->TS3_ADVOG, 1, 25 )  Picture "@!"
        EndIf
        @ Li,164 	 Psay Substr((cALIASQRY)->TS3_PROCES,1,24) Picture "@!"
        @ Li,190 	 Psay Transform(Round((cALIASQRY)->TS3_VALACA , 2), "@E 999,999,999.99")
        @ Li,206 	 Psay Transform(Round((cALIASQRY)->TS3_VALVEI , 2), "@E 999,999,999.99")
        
        nTOTAL     += (cALIASQRY)->TS3_VALVEI
        nTOTALACAO += (cALIASQRY)->TS3_VALACA
        NgSomaLi(58)
        
        dbSelectArea(cAliasQry)
        dbSkip()
    EndDo
    
    If lPvez = .F.
        @ Li,000 	 Psay Replicate("-",220)
        NgSomaLi(58)
        @ Li,176 	 Psay STR0032 //"Total......:"
        @ Li,190 	 Psay Transform(Round(nTOTALACAO , 2), "@E 999,999,999.99")
        @ Li,206 	 Psay Transform(Round(nTOTAL , 2), "@E 999,999,999.99")
        NgSomaLi(58)
    EndIf
    
    Roda(nCNTIMPR,cRODATXT,TAMANHO)
    
    //---------------------------------------------------
    // Devolve a condicao original do arquivo principal
    //---------------------------------------------------
    RetIndex('TS3')
    
    Set Filter To
    Set Device To Screen
    
    If aReturn[5] == 1
        Set Printer To
        dbCommitAll()
        OurSpool(WNREL)
    EndIf
    
    MS_FLUSH()
    
Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT915DT()
Valida o parametro ate data

@author Ricardo Dal Ponte
@since 22/03/2007
@return .T.
/*/
//---------------------------------------------------------------------
Function MNT915DT()

    If  MV_PAR02 < MV_PAR01
        MsgStop(STR0033) //"Data final não pode ser inferior à data inicial!"
        Return .F.
    EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNR915FL()
Validação do parametro Filial

@author Ricardo Dal Ponte
@since 22/03/2007
@return .T.
/*/
//---------------------------------------------------------------------
Function MNR915FL(nOpc)

    Local lRet
    
    If nOpc == 1
        lRet := NGFILIAL(1, MV_PAR03)
    ElseIf nOpc == 2
        lRet := NGFILIAL(2, MV_PAR03, MV_PAR04)
    EndIf
    
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTR915TMP()
Geracao do arquivo temporario

@author Ricardo Dal Ponte
@since 22/03/2007
/*/
//---------------------------------------------------------------------
Function MNTR915TMP()

    lnRegistro := .F.
    
    cQuery := " SELECT TS3.TS3_FILIAL, TS3.TS3_CODBEM, TS3.TS3_DTIND , TS3.TS3_DTACAO, TS3.TS3_RECLAM, "
    cQuery += "        TS3.TS3_ADVOG , TS3.TS3_PROCES, TS3.TS3_VALVEI, TS3.TS3_TIPMAT, TS3.TS3_DTLIB , "
    cQuery += "        TS3.TS3_PLACA , ST9.T9_CODBEM, ST9.T9_NOME, ST9.T9_CODFAMI, TS3.TS3_VALACA "
    cQuery += " FROM " + RetSqlName("TS3")+" TS3, "
    cQuery += "      " + RetSqlName("ST9")+" ST9  "
    cQuery += " WHERE "
    cQuery += "      (TS3.TS3_DTIND  >= '"+AllTrim(DTOS(MV_PAR01))+"'"
    cQuery += " AND   TS3.TS3_DTIND  <= '"+AllTrim(DTOS(MV_PAR02))+"')"
    cQuery += " AND   TS3.TS3_FILIAL >= '"+MV_PAR03+"'"
    cQuery += " AND   TS3.TS3_FILIAL <= '"+MV_PAR04+"'"
    cQuery += " AND   ST9.T9_CODFAMI >= '"+MV_PAR05+"'"
    cQuery += " AND   ST9.T9_CODFAMI <= '"+MV_PAR06+"'"
    cQuery += " AND   ST9.T9_TIPMOD  >= '"+MV_PAR07+"'"
    cQuery += " AND   ST9.T9_TIPMOD  <= '"+MV_PAR08+"'"
    
    If MV_PAR09 <> 5
        cQuery += " AND   TS3.TS3_TIPMAT  = '"+Alltrim(Str(MV_PAR09))+"'"
    EndIf
    
    cQuery += " AND   ST9.T9_FILIAL = TS3.TS3_FILIAL "
    cQuery += " AND   ST9.T9_CODBEM = TS3.TS3_CODBEM "
    cQuery += " AND   TS3.D_E_L_E_T_ <> '*' "
    cQuery += " AND   ST9.D_E_L_E_T_ <> '*' "
    cQuery += " ORDER BY TS3.TS3_FILIAL, ST9.T9_CODFAMI, ST9.T9_NOME, TS3.TS3_DTIND"
    cQuery := ChangeQuery(cQuery)
    dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
    
    dbSelectArea(cAliasQry)
    dbGoTop()
    
    If EoF()
        MsgInfo(STR0034,STR0035) //"Não existem dados para montar o relatório!"###"ATENÇÃO"
        (cAliasQry)->(dbCloseArea())
        lnRegistro := .T.
        Return
    EndIf
    
Return