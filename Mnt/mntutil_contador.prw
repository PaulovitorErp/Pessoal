#INCLUDE "mntutil_contador.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "Fileio.ch"
#INCLUDE "tbiconn.ch"

//Vari·veis de criaÁ„o/deleÁ„o de tabelas tempor·rias para evitar
//commit em banco de dados Oracle. Para garantir o Disarm Transaction
Static oTpTbTRBF  := Nil
Static oTmpTblSTC := Nil
Static oTmpTbl    := Nil

Static cQryAbaTTV
Static cQryKmSTP
Static cQryKmTPP

//---------------------------------------------------------------------
// Fonte destinado apenas as funÁıes que tenham relaÁ„o com
// contador. Ex.: VerificaÁ„o de histÛrico, retorno de contador, etc.
// Antes de adicionar uma funÁ„o aqui, verifique se atende a este
// requisito.
//---------------------------------------------------------------------

//---------------------------------------------------------------------
/*/{Protheus.doc} NGREGIHIST

Posiciona no intervalo de valores v·lidos do historico (STP)

@param cVBEM	- CÛdigo do bem             - ObrigatÛrio
@param nPOSCON	- Valor do contador         - ObrigatÛrio
@param dVLEIT	- Data da leitura         	- ObrigatÛrio
@param cVHORA	- Hora da leitura           - ObrigatÛrio
@param nTIPOC	- Tipo do contador ( 1/2 )	- ObrigatÛrio

@author In·cio Luiz Kolling
@since 11/03/2003
@version 1.0
@return  nVARDBEM - variacao
         nACUMCHK - acumulado
         nVIRAD   - viradas
         nPOSCCHK - contador
         cHORACHK - hora

/*/
//---------------------------------------------------------------------
Function NGREGIHIST(cVBEM,nPOSCON,dVLEIT,cVHORA,nTIPOC)

	Local nPOSCCHK,nVARDBEM,nACUMCHK,nVIRAD,cHORACHK
	Local vARQVAR  := If(nTIPOC = 1,{'ST9','STP','STP->TP_FILIAL','STP->TP_CODBEM','STP->TP_ACUMCON','STP->TP_POSCONT',;
		'STP->TP_VIRACON','STP->TP_DTLEITU','STP->TP_HORA'},;
		{'TPE','TPP','TPP->TPP_FILIAL','TPP->TPP_CODBEM','TPP->TPP_ACUMCO','TPP->TPP_POSCON',;
		'TPP->TPP_VIRACO','TPP->TPP_DTLEIT','TPP->TPP_HORA'})

	Store 0 To nPOSCCHK,nVARDBEM,nACUMCHK,nVIRAD
	cHORACHK := ' :  '

	dbSelectArea(vARQVAR[1])
	dbSetOrder(01)
	dbSeek(xFilial(vARQVAR[1])+cVBEM)

	dbSelectArea(vARQVAR[2])
	dbSetOrder(5)
	dbSeek(xfilial(vARQVAR[2])+cVBEM+Dtos(dVLEIT)+cVHORA,.T.)
	If Eof()
		dbSkip(-1)
	Else
		If &(vARQVAR[3]) == xFILIAL(vARQVAR[2]) .And. &(vARQVAR[4]) <> cVBEM
			dbSkip(-1)
		Endif
	Endif
	If &(vARQVAR[3]) == xFILIAL(vARQVAR[2]) .And. &(vARQVAR[4]) = cVBEM
		nACUMCHK := &(vARQVAR[5])
		nPOSCCHK := &(vARQVAR[6])
		nVIRAD   := &(vARQVAR[7])
		cHORACHK := &(vARQVAR[9])
		If &(vARQVAR[8]) > dVLEIT
			dbSkip(-1)
			If &(vARQVAR[3]) == xFILIAL(vARQVAR[2]) .And. &(vARQVAR[4]) <> cVBEM
				dbSkip(-1)
			Endif
		Endif
		If !Bof() .And. &(vARQVAR[3]) == xFILIAL(vARQVAR[2]) .And. &(vARQVAR[4]) = cVBEM
			If &(vARQVAR[8]) = dVLEIT
				If &(vARQVAR[9]) < cVHORA
					nACUMCHK := &(vARQVAR[5])
					nPOSCCHK := &(vARQVAR[6])
					nVIRAD   := &(vARQVAR[7])
					cHORACHK := &(vARQVAR[9])
				Endif
			Else
				nACUMCHK := &(vARQVAR[5])
				nPOSCCHK := &(vARQVAR[6])
				nVIRAD   := &(vARQVAR[7])
				cHORACHK := &(vARQVAR[9])
			Endif
		Endif
		nDIFECO  := If(nPOSCON >= nPOSCCHK,nPOSCON - nPOSCCHK,nPOSCCHK - nPOSCON)
		nACUMCHK := nACUMCHK + nDIFECO
	Else
		nACUMCHK := nPOSCON
	Endif

	nVARDBEM := NGVARIADT(cVBEM,dVLEIT,nTIPOC,nACUMCHK,.F.,.T.)

Return {nVARDBEM,nACUMCHK,nVIRAD,nPOSCCHK,cHORACHK}
/*/
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
	±±≥FunáÖo    ≥NGACUMEHIS≥ Autor ≥In†cio Luiz Kolling    ≥ Data ≥11/03/2003≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥DescriáÖo ≥Procura o contador acumulado especial ( ANTES/DEPOIS )      ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥Parametros≥cBEM     - C¢digo do bem                       - Obrigat¢rio≥±±
	±±≥          ≥dDATA    - Data da leitura                     - Obrigat¢rio≥±±
	±±≥          ≥cHORA    - Hora da leitura                     - Obrigat¢rio≥±±
	±±≥          ≥nTIPC    - Tipo do contador                    - Obrigat¢rio≥±±
	±±≥          ≥cTIPR    - Tipo do registro (A - Anterior                   ≥±±
	±±≥          ≥                             D - Depois                     ≥±±
	±±≥          ≥                             P - Proximo ou exato)          ≥±±
	±±≥          ≥                             E - Exato ou anterior          ≥±±
	±±≥          ≥cFilTa   - Codigo da filial                    - Nao Obrig. ≥±±
	±±≥          ≥cCondi   - Condicao                            - Nao Obrig. ≥±±
	±±≥          ≥lComFil  - Acesso com a filial (indice)        - Nao Obrig. ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥Retorna   ≥ vCONTAU                                                    ≥±±
	±±≥          ≥ vCONTAU[1] - Valor do contador                             ≥±±
	±±≥          ≥ vCONTAU[2] - Valor do acumulado                            ≥±±
	±±≥          ≥ vCONTAU[3] - Data do Lancamento                            ≥±±
	±±≥          ≥ vCONTAU[4] - Hora do Lancamento                            ≥±±
	±±≥          ≥ vCONTAU[5] - Viradas                                       ≥±±
	±±≥          ≥ vCONTAU[6] - Variacao dia                                  ≥±±
	±±≥          ≥ vCONTAU[7] - Tipo do Lancamento                            ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥ Uso      ≥ GENERICO                                                   ≥±±
	±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function NGACUMEHIS(cBEM,dDATA,hHORA,nTIPC,cTIPR,cFilTa,cCondi,lComFil,cPlaca)

	Local nTIPOCO := If(nTIPC = NIL,1,nTIPC)
	Local cChaAce := ""

	Private vCONTAU := {0,0,Ctod('  /  /  '),Space(5),0,0,Space(Len(stp->tp_tipolan))}
	Private lTestFi := If(lComFil = Nil,.T.,lComFil)
	Private cFilHiA := ""
	Private vARQCON := If(nTIPOCO = 1,{'STP','STP->TP_FILIAL','STP->TP_CODBEM','STP->TP_DTLEITU','STP->TP_HORA','STP->TP_POSCONT','STP->TP_ACUMCON',;
		'STP->TP_VIRACON','STP->TP_VARDIA','STP->TP_TIPOLAN','TP_CODBEM+DTOS(TP_DTLEITU)+TP_HORA'},;
		{'TPP','TPP->TPP_FILIAL','TPP->TPP_CODBEM','TPP->TPP_DTLEIT','TPP->TPP_HORA','TPP->TPP_POSCON','TPP->TPP_ACUMCO',;
		'TPP->TPP_VIRACO','TPP->TPP_VARDIA','TPP->TPP_TIPOLA','TPP_CODBEM+DTOS(TPP_DTLEIT)+TPP_HORA'})

	If IsInCallStack("MNTA655") .And. !Empty(cPlaca)
		dbSelectArea("ST9")
		dbSetOrder(14)
		If dbSeek(cPlaca)
			cFilHiA := ST9->T9_FILIAL
		EndIf
	Else
		cFilHiA := NGTROCAFILI(vARQCON[1],cFilTa)
	EndIf

	If !lTestFi
		lTestFi := If(NGRETORDEM(vARQCON[1],vARQCON[11],.T.) = 0,.T.,.F.)
	Endif

	cChaAce := If(lTestFi,cFilHiA+cBEM+Dtos(dDATA)+hHORA,cBEM+Dtos(dDATA)+hHORA)

	dbSelectArea(vARQCON[1])
	Dbsetorder(If(lTestFi,5,9)) //FILIAL+CODBEM+DTLEITU+HORA .OR. TP_CODBEM+DTOS(TP_DTLEITU)+TP_HORA
	dbSeek(cChaAce,.T.)

	If !Eof()
		If   &(vARQCON[3]) = cBEM .And. &(vARQCON[4]) = dDATA .And. &(vARQCON[5]) = hHORA;
				.And. If(lTestFi,&(vARQCON[2]) = cFilHiA,.T.)
			NGACUMEHI2(vARQCON[1],vARQCON[2],vARQCON[3],vARQCON[6],vARQCON[7],vARQCON[4],vARQCON[5],cBEM,cTIPR,dDATA,hHORA,;
				cFilHiA,vARQCON[8],cCondi,vARQCON[9],vARQCON[10])
		Else

			If &(vARQCON[3]) <> cBEM .And. IIf( lTestFi, ( &(vARQCON[2]) == cFilHiA .Or. &(vARQCON[2]) != cFilHiA ), .T.)
				dbSkip(-1)
			EndIf

			If !Bof() .And. &(vARQCON[3]) == cBEM .And. IIf( lTestFi, &(vARQCON[2]) == cFilHiA, .T. )
				NGACUMEHI2(vARQCON[1],vARQCON[2],vARQCON[3],vARQCON[6],vARQCON[7],vARQCON[4],vARQCON[5],cBEM,cTIPR,dDATA,hHORA,cFilHiA,vARQCON[8],cCondi,vARQCON[9],vARQCON[10])
			EndIf
		EndIf
	Else
		dbSkip(-1)
		If !Bof() .And. &(vARQCON[3]) = cBEM .And. If(lTestFi,&(vARQCON[2]) = cFilHiA,.T.)
			NGACUMEHI2(vARQCON[1],vARQCON[2],vARQCON[3],vARQCON[6],vARQCON[7],vARQCON[4],vARQCON[5],cBEM,cTIPR,dDATA,hHORA,cFilHiA,vARQCON[8],cCondi,vARQCON[9],vARQCON[10])
		EndIf
	EndIf

Return vCONTAU
/*/
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
	±±≥FunáÖo    ≥NGACUMEHI2≥ Autor ≥In†cio Luiz Kolling    ≥ Data ≥11/03/2003≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥DescriáÖo ≥Procura o contador acumulado especial ( ANTES/DEPOIS )      ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥Parametros≥cALIARQ  - Alias do arquivo  (P/ Pesquisa)     - Obrigat¢rio≥±±
	±±≥          ≥cARQFIL  - Filial do arquivo (P/ Pesquisa)     - Obrigat¢rio≥±±
	±±≥          ≥cARQBEM  - C¢digo do bem     (P/ Pesquisa)     - Obrigat¢rio≥±±
	±±≥          ≥cPOSCON  - Contador          (P/ Pesquisa)     - Obrigat¢rio≥±±
	±±≥          ≥cACUMCO  - Acumulado         (P/ Pesquisa)     - Obrigat¢rio≥±±
	±±≥          ≥dDATARQ  - Data Arquivo      (P/ Pesquisa)     - Obrigat¢rio≥±±
	±±≥          ≥cHORARQ  - Hora Arquivo      (P/ Pesquisa)     - Obrigat¢rio≥±±
	±±≥          ≥cBEMPAR  - C¢digo do bem     (P/ Comparacao)   - Obrigat¢rio≥±±
	±±≥          ≥cTIPOR2  - Tipo do registro (A/D)              - Obrigat¢rio≥±±
	±±≥          ≥dDATAPE  - Data da pesquisa                    - Obrigat¢rio≥±±
	±±≥          ≥cHORAPE  - Hora da pesquisa                    - Obrigat¢rio≥±±
	±±≥          ≥cFilTa2  - Codigo da filial                    - Nao Obrig. ≥±±
	±±≥          ≥nNUMVIRA - Numero de virada do contador        - Obrigatorio≥±±
	±±≥          ≥cCondi   - Condicao                            - Nao Obrig. ≥±±
	±±≥          ≥nVARDIAH - Variacao dia                        - Obrigatorio≥±±
	±±≥          ≥cTIPOLAN - Tipo do lancamento                  - Obrigatorio≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥Usado     ≥ NGACUMEHIS                                                 ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥Retorna   ≥ nill                                                       ≥±±
	±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function NGACUMEHI2(cALIARQ,cARQFIL,cARQBEM,cPOSCON,cACUMCO,dDATARQ,cHORARQ,cBEMPAR,cTIPOR2,dDATAPE,cHORAPE,cFilTa2,nNUMVIRA,cCondi,nVARDIAH,cTIPOLAN)

	Local lRegAnt := .F.

	cEOFBOF := If(cTIPOR2 = 'A','!Bof()','!Eof()')

	While &(cEOFBOF) .And. &(cARQBEM) = cBEMPAR .And. If(lTestFi,&(vARQCON[2]) = cFilHiA,.T.)
		lExit := .F.
		If &(cEOFBOF) .And. &(cARQBEM) = cBEMPAR .And. If(lTestFi,&(vARQCON[2]) = cFilHiA,.T.)
			If cTIPOR2 = 'A'
				If &(dDATARQ) <= dDATAPE
					If &(dDATARQ) < dDATAPE
						NGACUMEHEX(cCondi)
					Else
						If &(cHORARQ) < cHORAPE
							NGACUMEHEX(cCondi)
						Endif
					Endif
				Endif
			Elseif  cTIPOR2 = 'D'
				If &(dDATARQ) >= dDATAPE
					If &(dDATARQ) > dDATAPE
						NGACUMEHEX(cCondi)
					Else
						If &(cHORARQ) > cHORAPE
							NGACUMEHEX(cCondi)
						Endif
					Endif
				Endif
			Elseif  cTIPOR2 = 'E' //Exato ou menor (Anterior)
				If &(dDATARQ) = dDATAPE .And. &(cHORARQ) = cHORAPE
					NGACUMEHEX(cCondi)
				Else
					If &(dDATARQ) <= dDATAPE
						If &(dDATARQ) < dDATAPE
							NGACUMEHEX(cCondi)
						Else
							If &(cHORARQ) < cHORAPE
								NGACUMEHEX(cCondi)
							Else
								dbSkip(-1)
								If !BoF() .And. &(cARQBEM) = cBEMPAR .And. If(lTestFi,&(vARQCON[2]) = cFilHiA,.T.)
									NGACUMEHEX(cCondi)
									lRegAnt := .T.
								Else
									dbSkip()
									NGACUMEHEX(cCondi)
								EndIf
							EndIf
						EndIf
					Else
						dbSkip(-1)
						If !BoF() .And. &(cARQBEM) = cBEMPAR .And. If(lTestFi,&(vARQCON[2]) = cFilHiA,.T.)
							NGACUMEHEX(cCondi)
							lRegAnt := .T.
						Else
							dbSkip()
							NGACUMEHEX(cCondi)
						EndIf
					EndIf
				EndIf
			Else
				lExit := .T.
			Endif
		Endif

		If lExit
			NGACUMAVET(cPOSCON,cACUMCO,dDATARQ,cHORARQ,nNUMVIRA,nVARDIAH,cTIPOLAN)
			Exit
		Endif

		If cTIPOR2 = "A"
			dbSkip(-1)
		Else
			dbSkip(If(!lRegAnt,1,-1))
			cEOFBOF := If(!lRegAnt,cEOFBOF,'!Bof()')
		Endif
	End
Return
/*/
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
	±±≥FunáÖo    ≥NGACUMEHEX≥ Autor ≥In†cio Luiz Kolling    ≥ Data ≥08/10/2009≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥DescriáÖo ≥Alimenta a variavel lExit e faz a consistencia do registro  ≥±±
	±±≥          ≥do historico do contador                                    ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥Parametros≥cCondi   - Condicao de filtro do historico     - Nao Obrig. ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥Usado     ≥ NGACUMEHI2                                                 ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥Retorna   ≥ nil                                                        ≥±±
	±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function NGACUMEHEX(cCondi)
	If cCondi = Nil
		lExit := .T.
	Else
		If &(cCondi)
			lExit := .T.
		Endif
	Endif
Return
/*/
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
	±±≥FunáÖo    ≥NGACUMAVET≥ Autor ≥In†cio Luiz Kolling    ≥ Data ≥11/03/2003≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥DescriáÖo ≥Alementa o vetor do acumulado especial                      ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥Parametros≥cPOSCON  - Contador          (P/ Pesquisa)     - Obrigat¢rio≥±±
	±±≥          ≥cACUMCO  - Acumulado         (P/ Pesquisa)     - Obrigat¢rio≥±±
	±±≥          ≥dDATARQ  - Data Arquivo      (P/ Pesquisa)     - Obrigat¢rio≥±±
	±±≥          ≥cHORARQ  - Hora Arquivo      (P/ Pesquisa)     - Obrigat¢rio≥±±
	±±≥          ≥cNUMRVIR - Virada do contador(P/ Pesquisa)     - Obrigat¢rio≥±±
	±±≥          ≥cVARDIA  - Virada do contador(P/ Pesquisa)     - Obrigat¢rio≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥Usado     ≥ NGACUMEHI2                                                 ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥Retorna   ≥ nil                                                        ≥±±
	±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function NGACUMAVET(cPOSCON,cACUMCO,dDATARQ,cHORARQ,cNUMRVIR,cVARDIA,cTIPOLAN)
	vCONTAU[1] := &(cPOSCON)
	vCONTAU[2] := &(cACUMCO)
	vCONTAU[3] := &(dDATARQ)
	vCONTAU[4] := &(cHORARQ)
	vCONTAU[5] := &(cNUMRVIR)
	vCONTAU[6] := &(cVARDIA)
	vCONTAU[7] := &(cTIPOLAN)
Return .T.
/*/
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
	±±≥FunáÖo    ≥NGACUMHIST≥ Autor ≥In†cio Luiz Kolling    ≥ Data ≥11/03/2003≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥DescriáÖo ≥Procura o contador acumulado e/ou projeto                   ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥Parametros≥cBEM     - C¢digo do bem                       - Obrigat¢rio≥±±
	±±≥          ≥dDATA    - Data da leitura                     - Obrigat¢rio≥±±
	±±≥          ≥cHORA    - Hora da leitura                     - Obrigat¢rio≥±±
	±±≥          ≥nTIPC    - Tipo do contador                    - Obrigat¢rio≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥Retorna   ≥vetor                                                       ≥±±
	±±≥          ≥ vetor[1] - Valor do contador                               ≥±±
	±±≥          ≥ vetor[2] - Valor do acumulado                              ≥±±
	±±≥          ≥ vetor[3] - .T./.F.  .T. - Contadores projetados            ≥±±
	±±≥          ≥                     .F. - Contadores reais (nao projetados)≥±±
	±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function NGACUMHIST(cBEM,dDATA,hHORA,nTIPC)
	Local nTIPOCO := If(nTIPC = NIL,1,nTIPC)
	Local nCONTAD,nCONTA1,nCONTA2,nHORA1,nHORA2,nACUMLO,nACUML1,nACUML2,nVADSTP
	Local dDTSTP1,dDTSTP2,lDATAIG,lPROJET
	Local vARQCON := If(nTIPOCO = 1,{'STP','stp->tp_filial','stp->tp_codbem',;
		'stp->tp_dtleitu','stp->tp_hora',;
		'stp->tp_acumcon','stp->tp_poscont',;
		'stp->tp_vardia'},;
		{'TPP','tpp->tpp_filial','tpp->tpp_codbem',;
		'tpp->tpp_dtleit','tpp->tpp_hora',;
		'tpp->tpp_acumco','tpp->tpp_poscon',;
		'tpp->tpp_vardia'})

	Store Ctod('  /  /  ') To dDTSTP1,dDTSTP2
	Store .F.              To lDATAIG,lPROJET
	Store 0 To nCONTAD,nCONTA1,nCONTA2,nHORA1,nHORA2,nACUMLO,nACUML1,nACUML2,nVADSTP

	dbSelectArea(vARQCON[1])
	Dbsetorder(5)
	dbSeek(xfilial(vARQCON[1])+cBEM+Dtos(dDATA)+hHORA,.T.)

	If !Eof()
		If &(vARQCON[2]) = xfilial(vARQCON[1]) .And. &(vARQCON[3]) = cBEM;
				.And. &(vARQCON[4]) = dDATA .And. &(vARQCON[5]) = hHORA
			nACUMLO := &(vARQCON[6])
			nCONTAD := &(vARQCON[7])
		Else
			lPROJET := .T.
			If &(vARQCON[2]) = xfilial(vARQCON[1]) .And. &(vARQCON[3]) <> cBEM
				dbSkip(-1)
			Endif
			If !Bof() .And. &(vARQCON[2]) = xfilial(vARQCON[1]) .And. &(vARQCON[3]) = cBEM
				If &(vARQCON[4]) >= dDATA
					nACUML2 := &(vARQCON[6])
					dDTSTP2 := &(vARQCON[4])
					nVADSTP := &(vARQCON[8])
					nHORA2  := &(vARQCON[5])
					nCONTA2 := &(vARQCON[7])
					dbSkip(-1)
					If !Bof() .And. &(vARQCON[2]) = xfilial(vARQCON[1]) .And. &(vARQCON[3]) = cBEM
						nACUML1 := &(vARQCON[6])
						dDTSTP1 := &(vARQCON[4])
						lDATAIG := If(dDTSTP1 = dDTSTP2,.T.,.F.)
						nHORA1  := &(vARQCON[5])
						nCONTA1 := &(vARQCON[7])
					Endif
					If Empty(nACUML1)
						nACUMLO := nACUML2 - (nVADSTP * (dDATA - dDTSTP2))
						nCONTAD := nCONTA2 - (nVADSTP * (dDATA - dDTSTP2))
					Else
						nACUMLO := nACUML2 - ((nACUML2 - nACUML1) / (dDTSTP2 - dDTSTP1)) * (dDTSTP2 - dDATA)

						nCONTAD := If(nCONTA2 >= nCONTA1,;
							nCONTA2 - ((nCONTA2 - nCONTA1) / (dDTSTP2 - dDTSTP1)) * (dDTSTP2 - dDATA),;
							nCONTA1 + ((nACUML2 - nACUML1) / (dDTSTP2 - dDTSTP1)) * (dDATA - dDTSTP1))

						If lDATAIG .And. nACUML2 <> nACUML1
							nHORMI1 := Round((HTON(nHORA2) - HTON(nHORA1)) * 60,0)
							nHORMI2 := Round((HTON(nHORA2) - HTON(hHORA)) * 60,0)
							nACUMLO := nACUML2 - ((nACUML2 - nACUML1) / nHORMI1) * nHORMI2
						Endif

						If lDATAIG .And. nCONTA2 <> nCONTA1
							nHORMI1 := Round((HTON(nHORA2) - HTON(nHORA1)) * 60,0)
							nHORMI2 := Round((HTON(nHORA2) - HTON(hHORA)) * 60,0)

							nCONTAD := If(nCONTA2 >= nCONTA1,;
								nCONTA2 - ((nCONTA2 - nCONTA1) / nHORMI1) * nHORMI2,;
								nCONTA1 + ((nACUML2 - nACUML1) / nHORMI1) * nHORMI2)
						Endif

					Endif
				Else
					If &(vARQCON[4]) <= dDATA
						nACUML1 := &(vARQCON[6])
						nCONTA1 := &(vARQCON[7])
						dDTSTP1 := &(vARQCON[4])
						nVADSTP := &(vARQCON[8])
						nHORA1  := &(vARQCON[5])
						dbSkip()
						If !Eof() .And. &(vARQCON[2]) = xfilial(vARQCON[1]) .And. &(vARQCON[3]) = cBEM
							nACUML2 := &(vARQCON[6])
							nCONTA2 := &(vARQCON[7])
							dDTSTP2 := &(vARQCON[4])
							nHORA2  := &(vARQCON[5])
							lDATAIG := If(dDTSTP1 = dDTSTP2,.T.,.F.)
						Endif
						If Empty(nACUML2)
							nACUMLO := nACUML1 + (nVADSTP * (dDATA - dDTSTP1))
							nCONTAD := nCONTA1 + (nVADSTP * (dDATA - dDTSTP1))
						Else
							nACUMLO := nACUML2 - ((nACUML2 - nACUML1) / dDTSTP2 - dDTSTP1) * (dDTSTP2 - dDATA)

							nCONTAD := If(nCONTA2 >= nCONTA1,;
								nCONTA2 - ((nCONTA2 - nCONTA1) / dDTSTP2 - dDTSTP1) * (dDTSTP2 - dDATA),;
								nCONTA1 + ((nACUML2 - nACUML1) / dDTSTP2 - dDTSTP1) * (dDATA - dDTSTP1))

							If lDATAIG .And. nACUML2 <> nACUML1
								nHORMI1 := Round((HTON(nHORA2) - HTON(nHORA1)) * 60,0)
								nHORMI2 := Round((HTON(nHORA2) - HTON(hHORA)) * 60,0)
								nACUMLO := nACUML2 - ((nACUML2 - nACUML1) / nHORMI1) * nHORA2
							Endif

							If lDATAIG .And. nCONTA2 <> nCONTA1
								nHORMI1 := Round((HTON(nHORA2) - HTON(nHORA1)) * 60,0)
								nHORMI2 := Round((HTON(nHORA2) - HTON(hHORA)) * 60,0)

								nCONTAD := If(nCONTA2 >= nCONTA1,;
									nCONTA2 - ((nCONTA2 - nCONTA1) / nHORMI1) * nHORA2,;
									nCONTA1 + ((nACUML2 - nACUML1) / nHORMI1) * nHORA2)
							Endif
						Endif
					Endif
				Endif
			Endif
		Endif
	Else
		dbSkip(-1)
		If !Bof() .And. &(vARQCON[2]) = xfilial(vARQCON[1]) .And. &(vARQCON[3]) = cBEM
			lPROJET := .T.
			nACUMLO := &(vARQCON[6]) + ( &(vARQCON[8]) * (dDATA - &(vARQCON[4])) )
			nCONTAD := &(vARQCON[7]) + ( &(vARQCON[8]) * (dDATA - &(vARQCON[4])) )
		Endif
	Endif
Return {Round(nCONTAD,0),Round(nACUMLO,0),lPROJET}

//---------------------------------------------------------------------
/*/{Protheus.doc} NGTRETCON
Processa hist¢rio dos contadores.
@type function

@author In·cio Luiz Kolling
@since 11/03/2003

@sample NGTRETCON()

@param  cBEM      , Caracter, CÛdigo do bem.
@param  dLEIT     , Data    , Data da leitura.
@param  nPOSCONT  , NumÈrico, Valor do contador.
@param  cVHORA    , Caracter, Hora da leitura.
@param  nTIPOC    , NumÈrico, Tipo do contador.
@param  [vNREPAC] , Array   , Vetor com os elementos n„o repassar.
@param  lGERAUT   , LÛgico  , Gera O.S. autom·tica.
@param  cTipoLan  , Caracter, Tipo lanÁamento.
@param  cFilTroc  , Caracter, Filial de troca de acesso.
@param  [lProcEst], LÛgico  , Reprocessa estrutura do bem pai.
@param  [cOrigem] , Caracter, Rotina que est· gerando o historico de contador.
@para   [aTrbEst] , Array   , Array possuindo as tabelas tempor·rias responsaveis por montar a estrutura do bem.
							[1] tabela temporaria do pai da estrutura - cTRBS
							[2] tabela temporaria do pai da estrutura - cTRBF
							[3] tabela temporaria do eixo suspenso    - CTRBEixo
@return
/*/
//---------------------------------------------------------------------
Function NGTRETCON( cBEM, dLEIT, nPOSCONT, cHORAL, nTIPOC, vNREPAC, lGERAUT, cTIPOLAN, cFilTroc, lProcEst, cOrigem, aTrbEst )

	Local aAreaSTZ   := STZ->( GetARea() )
	Local lVIRADA    := .F.
	Local lRecalhist := .T.
	Local lViraFilho := .F.
	Local nDIFERE    := 0
	Local nDiffFilho := 0
	Local nIncrFilho := 0
	Local vARQCON    := If(nTIPOC = 1,{'ST9','STP',;
		'STP->TP_FILIAL' ,'STP->TP_CODBEM',;
		'STP->TP_DTLEITU','STP->TP_POSCONT',;
		'STP->TP_VARDIA' ,'STP->TP_ACUMCON',;
		'STP->TP_VIRACON','ST9->T9_LIMICON',;
		'ST9->T9_POSCONT','ST9->T9_CONTACU',;
		'ST9->T9_VIRADAS','STP->TP_HORA',;
		'STP->TP_TIPOLAN'},;
		{'TPE','TPP',;
		'TPP->TPP_FILIAL','TPP->TPP_CODBEM',;
		'TPP->TPP_DTLEIT','TPP->TPP_POSCON',;
		'TPP->TPP_VARDIA','TPP->TPP_ACUMCO',;
		'TPP->TPP_VIRACO','TPE->TPE_LIMICO',;
		'TPE->TPE_POSCON','TPE->TPE_CONTAC',;
		'TPE->TPE_VIRADA','TPP->TPP_HORA',;
		'TPP->TPP_TIPOLA'})
	Local lFrota      := NGVERUTFR()
	Local lGravaHist  := .T.
	Local mm          := 0
	Local nn          := 0
	Local cTIPLA      := If(cTIPOLAN = NIL,"C",cTIPOLAN)
	Local cTipoFilho  := cTIPLA
	Local vNREPAS     := If (vNREPAC <> NIL,Aclone(vNREPAC),{})
	Local nACUMULPE   := 0
	Local lENTRADA    := .F. // Variavel que indica se Bem Filho n„o participou do incremento do contador
	Local lATF        := IIf(Type("lAtfExecAuto") != "U",lAtfExecAuto,.F.)
	Local aComponents := {}
	Local cUseLanex   := AllTrim( SuperGetMv( 'MV_NGLANEX', .F., '' ))
	Local cAliasSTZ   := GetNextAlias()
	Local nPosPai     := 0
	Local nPosFilho   := 0
	Local cFather     := ""
	Local nDifContad  := 0

	Default lProcEst  := .T.
	Default cOrigem   := ''
	Default aTrbEst   := {}

	Private nDifF     := 0
	Private aESTSTZ   := {}
	Private cFamiPai  := ""
	Private cTipMPai  := ""

	If nPOSCONT > 0

		cFilCon := NGTROCAFILI(vARQCON[1],cFilTroc)
		cFilHis := NGTROCAFILI(vARQCON[2],cFilTroc)

		dbSelectArea(vARQCON[1])
		dbSetOrder(1)
		If dbSeek(cFilCon+cBEM)

			dbSelectArea(vARQCON[2])
			dbSetOrder(5)
			dbSeek(cFilHis+cBEM+Dtos(dLEIT)+cHORAL,.T.)
			nREGSTP := Recno()

			If Eof()
				// FINAL DO ARQUIVO
				dbSelectArea(vARQCON[2])
				dbSkip(-1)
				If !Bof()
					If &(vARQCON[3]) == cFilHis .And. &(vARQCON[4]) == cBEM
						If &(vARQCON[5]) <= dLEIT
							If &(vARQCON[5]) == dLEIT .And. &(vARQCON[6]) == nPOSCONT

								lRecalhist := .F. // data e contador s„o iguais ao lanÁamento anterior
								NGGRAVAHIS( cBEM, nPOSCONT, &( vARQCON[7] ), dLEIT, &( vARQCON[8] ), &( vARQCON[9] ), cHORAL, nTIPOC, cTIPLA, cFilHis, cFilCon, cOrigem )
								lGravaHist := .F.
							Else

								lVIRADA := nPOSCONT < &(vARQCON[6])
								nDIFERE := If(lVIRADA,(&(vARQCON[10]) - &(vARQCON[11])) + nPOSCONT, nPOSCONT - &(vARQCON[6]))

								nACUMUL := &(vARQCON[12]) + nDIFERE

								If Type("nDifCont") <> 'U' .And. Type("nAcum655") <> 'U' .And. Type("nAcu6552") <> 'U'
									If nTIPOC = 1 .And. nAcum655 > 0
										nACUMUL := nAcum655
									ElseIf nTIPOC = 2 .And. nAcu6552 > 0
										nACUMUL := nAcu6552
									Endif
								Endif

								nVIRADA := If(lVIRADA,&(vARQCON[13]) + 1,&(vARQCON[13]))
								nVARDIA := NGVARIADT(cBEM,dLEIT,nTIPOC,nACUMUL,.F.,.F.,cFilHis,cFilCon)

								NGATUCONT(cBEM,dLEIT,nPOSCONT,nACUMUL,nVARDIA,nTIPOC,lVIRADA,.F.,cFilCon)

								dbSelectArea(vARQCON[2])
								NGGRAVAHIS( cBEM, nPOSCONT, nVARDIA, dLEIT, nACUMUL, nVIRADA, cHORAL, nTIPOC, cTIPLA, cFilHis, cFilCon, cOrigem )
								lGravaHist := .F.
								dbSelectArea(vARQCON[2])
							Endif
						Else

						Endif
					Else

						// TALVEZ NAO SEJA NECESSARIO TER O IF ABAIXO

						If &(vARQCON[5]) == dLEIT .And. &(vARQCON[6]) == nPOSCONT
							lRecalhist := .F. // data e contador s„o iguais ao lanÁamento anterior
							nACUMUL := &(vARQCON[8])
							nVIRADA := &(vARQCON[9])
							nVARDIA := &(vARQCON[7])
						Else
							nDIFERE := nPOSCONT - &(vARQCON[11])
							nACUMUL := &(vARQCON[12]) + nDIFERE
							nVIRADA := &(vARQCON[13])
							nVARDIA := NGVARIADT(cBEM,dLEIT,nTIPOC,nACUMUL,.F.,.F.,cFilHis,cFilCon)

							NGATUCONT(cBEM,dLEIT,nPOSCONT,nACUMUL,nVARDIA,nTIPOC,lVIRADA,.F.,cFilCon)
						Endif

						dbSelectArea(vARQCON[2])
						NGGRAVAHIS( cBEM, nPOSCONT, nVARDIA, dLEIT, nACUMUL, nVIRADA, cHORAL, nTIPOC, cTIPLA, cFilHis, cFilCon, cOrigem )
						lGravaHist := .F.
						dbSelectArea(vARQCON[2])

					Endif
				Endif
			Else

				If &(vARQCON[3]) == cFilHis .And. &(vARQCON[4]) == cBEM

					If &(vARQCON[5]) == dLEIT .And. &(vARQCON[6]) == nPOSCONT
						lRecalhist := .F. // data e contador s„o iguais ao lanÁamento anterior
						nACUMUL := &(vARQCON[8])

						// registro anterior para pegar diferenÁa
						dbSkip(-1)
						If !Bof() .And. &(vARQCON[3]) == cFilHis .And. &(vARQCON[4]) = cBEM
							nDIFERE := nPOSCONT - &(vARQCON[6])
							If FindFunction("MNTVERATV") .And. MNTVERATV(cBEM,dLEIT,SubStr(cHORAL,1,5))
								nACUMUL := &(vARQCON[8]) + nDIFERE
							Else
								nACUMUL := &(vARQCON[8])
							EndIf
						EndIf
						dbSkip()

						NGGRAVAHIS( cBEM, nPOSCONT, &( vARQCON[7] ), dLEIT, &( vARQCON[8] ), &( vARQCON[9] ), cHORAL, nTIPOC, cTIPLA, cFilHis, cFilCon, cOrigem )
						lGravaHist  := .F.
						nVIRADA := &(vARQCON[9])
					Else
						If &(vARQCON[5]) == dLEIT .And. nPOSCONT > &(vARQCON[6]) .And. &(vARQCON[15]) <> "Q"
							//Se o registro anterior for uma Quebra, deixa posicionado nele, pois este sera o Contador valido para o resto dos calculos
							dbSkip(-1)
							If &(vARQCON[3]) <> cFilHis .Or. &(vARQCON[4]) <> cBEM .Or. &(vARQCON[15]) <> "Q"
								dbSkip() //Se nao for uma Quebra, ou for um historico de outro Bem, deixa o registro normal
							EndIf
							nDIFERE := nPOSCONT - &(vARQCON[6])
							If FindFunction("MNTVERATV") .And. MNTVERATV(cBEM,dLEIT,SubStr(cHORAL,1,5))
								nACUMUL := &(vARQCON[8])+nDIFERE
							Else
								nACUMUL := &(vARQCON[8])
							EndIf

							nVIRADA := &(vARQCON[9])
							nVARDIA := NGVARIADT(cBEM,dLEIT,nTIPOC,nACUMUL,.F.,.F.,cFilHis,cFilCon)

							dbSelectArea(vARQCON[2])
							NGGRAVAHIS( cBEM, nPOSCONT, nVARDIA, dLEIT, nACUMUL, nVIRADA, cHORAL, nTIPOC, cTIPLA, cFilHis, cFilCon, cOrigem )
							lGravaHist := .F.
							dbSelectArea(vARQCON[2])
						Else
							dDATAINI := Ctod(' /  /  ')
							nPOSCINI := 0
							nACOMINI := 0
							nVIRAINI := 0
							cHORAINI := Space(5)

							dDATAFIM := &(vARQCON[5])
							nPOSCFIM := &(vARQCON[6])
							cHORAFIM := &(vARQCON[14])
							nACOMFIM := &(vARQCON[8])
							nVIRAFIM := &(vARQCON[9])

							dbSkip(-1)
							If !Bof()
								If &(vARQCON[3]) == cFilHis .And. &(vARQCON[4]) = cBEM
									dDATAINI := &(vARQCON[5])
									nPOSCINI := &(vARQCON[6])
									cHORAINI := &(vARQCON[14])
									nACOMINI := &(vARQCON[8])
									nVIRAINI := &(vARQCON[9])
								Endif
							Endif

							If !Empty(nPOSCINI)
								If nPOSCONT < nPOSCINI .And. nPOSCONT < nPOSCFIM

									lVIRADA := .T.
									nDIFERE := (&(vARQCON[10]) - nPOSCINI)+nPOSCONT
									nACUMUL := nACOMINI+nDIFERE
									nVIRADA := nVIRAINI + 1

									nVARDIA := NGVARIADT(cBEM,dLEIT,nTIPOC,nACUMUL,.F.,.F.,cFilHis,cFilCon)

									dbSelectArea(vARQCON[2])
									NGGRAVAHIS( cBEM, nPOSCONT, nVARDIA, dLEIT, nACUMUL, nVIRADA, cHORAL, nTIPOC, cTIPLA, cFilHis, cFilCon, cOrigem )
									lGravaHist := .F.
									dbSelectArea(vARQCON[2])

								Else

									nDIFERE := nPOSCONT-&(vARQCON[6])
									If FindFunction("MNTVERATV") .And. MNTVERATV(cBEM,dLEIT,SubStr(cHORAL,1,5))
										nACUMUL := &(vARQCON[8])+nDIFERE
									Else
										nACUMUL := &(vARQCON[8])
									EndIf
									nVIRADA := &(vARQCON[9])
									nVARDIA := NGVARIADT(cBEM,dLEIT,nTIPOC,nACUMUL,.F.,.F.,cFilHis,cFilCon)

									dbSelectArea(vARQCON[2])
									NGGRAVAHIS( cBEM, nPOSCONT, nVARDIA, dLEIT, nACUMUL, nVIRADA, cHORAL, nTIPOC, cTIPLA, cFilHis, cFilCon, cOrigem )
									lGravaHist := .F.
									dbSelectArea(vARQCON[2])

								Endif

							Else

								nDIFERE := nPOSCFIM - nPOSCONT
								nACUMUL := nACOMFIM - nDIFERE
								nVIRADA := nVIRAFIM

								nVARDIA := NGVARIADT(cBEM,dLEIT,nTIPOC,nACUMUL,.F.,.F.,cFilHis,cFilCon)

								dbSelectArea(vARQCON[2])
								NGGRAVAHIS( cBEM, nPOSCONT, nVARDIA, dLEIT, nACUMUL, nVIRADA, cHORAL, nTIPOC, cTIPLA, cFilHis, cFilCon, cOrigem )
								lGravaHist := .F.
								dbSelectArea(vARQCON[2])

							Endif
						Endif
					Endif
				Else

					DbSkip(-1)
					If !Bof()

						If &(vARQCON[3]) == cFilHis .And. &(vARQCON[4]) = cBEM
							If &(vARQCON[5]) == dLEIT .And. &(vARQCON[6]) == nPOSCONT
								lRecalhist := .F. // data e contador s„o iguais ao lanÁamento anterior
								NGGRAVAHIS( cBEM, nPOSCONT, &( vARQCON[7] ), dLEIT, &( vARQCON[8] ), &( vARQCON[9] ), cHORAL, nTIPOC, cTIPLA, cFilHis, cFilCon, cOrigem )
								lGravaHist := .F.
							Else
								If nPOSCONT < &(vARQCON[6])

									lVIRADA := .T.
									nDIFERE := (&(vARQCON[10]) - &(vARQCON[6]))+nPOSCONT
									If FindFunction("MNTVERATV") .And. MNTVERATV(cBEM,dLEIT,SubStr(cHORAL,1,5))
										nACUMUL := &(vARQCON[8])+nDIFERE
									Else
										nACUMUL := &(vARQCON[8])
									EndIf
									nVIRADA := &(vARQCON[9]) + 1

									nVARDIA := NGVARIADT(cBEM,dLEIT,nTIPOC,nACUMUL,.F.,.F.,cFilHis,cFilCon)

									dbSelectArea(vARQCON[2])
									NGGRAVAHIS( cBEM, nPOSCONT, nVARDIA, dLEIT, nACUMUL, nVIRADA, cHORAL, nTIPOC, cTIPLA, cFilHis, cFilCon, cOrigem )
									lGravaHist := .F.
									dbSelectArea(vARQCON[2])

								Else

									nDIFERE := nPOSCONT-&(vARQCON[6])
									If FindFunction("MNTVERATV") .And. MNTVERATV(cBEM,dLEIT,SubStr(cHORAL,1,5))
										nACUMUL := &(vARQCON[8])+nDIFERE
									Else
										nACUMUL := &(vARQCON[8])
									EndIf
									nVIRADA := &(vARQCON[9])
									nVARDIA := NGVARIADT(cBEM,dLEIT,nTIPOC,nACUMUL,.F.,.F.,cFilHis,cFilCon)

									dbSelectArea(vARQCON[2])
									NGGRAVAHIS( cBEM, nPOSCONT, nVARDIA, dLEIT, nACUMUL, nVIRADA, cHORAL, nTIPOC, cTIPLA, cFilHis, cFilCon, cOrigem )
									lGravaHist := .F.
									dbSelectArea(vARQCON[2])

								Endif
							Endif
						Endif

					Else

						nDIFERE := 0
						nACUMUL := nPOSCONT - nDIFERE
						nVIRADA := 0

						nVARDIA := NGVARIADT(cBEM,dLEIT,nTIPOC,nACUMUL,.F.,.F.,cFilHis,cFilCon)

						dbSelectArea(vARQCON[2])
						NGGRAVAHIS( cBEM, nPOSCONT, nVARDIA, dLEIT, nACUMUL, nVIRADA, cHORAL, nTIPOC, cTIPLA, cFilHis, cFilCon, cOrigem )
						lGravaHist := .F.
						dbSelectArea(vARQCON[2])

					Endif

				Endif

			Endif

			nIncrFilho := nDIFERE //Armazena a diferenca do contador para usar no filho, sem considerar a virada (abaixo) do Pai
			// INCLUI O NOVO REGISTRO DO BEM PAI
			If lRecalhist
				If lGravaHist
					NGGRAVAHIS( cBEM, nPOSCONT, 1, dLEIT, ST9->T9_CONTACU, ST9->T9_VIRADAS, cHORAL, nTIPOC, cTIPLA, cFilHis, cFilCon, cOrigem )
				Endif
				nDIFERE := If(lVIRADA,nACUMUL,nDIFERE)
				NGRECALHIS(cBem,nDIFERE,nPOSCONT,dLEIT,nTIPOC,.T.,lVIRADA,.T.,,cFilCon,cFilHis)
			Endif

			nACUMULPE := If(Type("nACUMUL")=='U',0,nACUMUL)

			// CARREGAR OS BENS FILHOS A PARTIR DE E RECALCULAR
			// Se a chamada for via transferÍncia do ATF060 n„o precisa verificar estrutura pois Ativos
			// relacionados com bens/veÌculos que possuam estrutura n„o podem ser transferido por essa rotina,
			// dessa forma n„o precisa refazer essa validaÁ„o.
			If lProcEst .And. !lATF
				aESTSTZ := NGCOMPPCONT(cBEM,dLEIT,cHORAL,cFilCon,aTrbEst)
			EndIf
			If NGIFDBSEEK("ST9",cBEM,1,,cFilCon)
				cFamiPai := ST9->T9_CODFAMI
				cTipMPai := If(lFrota,ST9->T9_TIPMOD,"")//ST9->T9_TIPMOD
			Endif

			// TINHA ESTRUTURA NO INTERVALO DE DIAS ???
			nDifF := nDIFERE

			If Len(aESTSTZ) > 0

				If NGCADICBASE("TQ1_SUSPEN","A","TQ1",.F.) .And. !IsBlind()
					NGMARKSUSP(AllTrim(Str(nTIPOC)),aTrbEst)
				Endif

				// ORDENA A MATRIZ DOS BENS MOVIMENTADOS
				aESTORD := Asort(aESTSTZ,,,{|x,y| x[1] < y[1] .And. x[2] < y[2]})

				// EXTRAI A DATA INICIO DE CADA BEM MOVIMENTADO
				aESTREC := {}
				For mm := 1 To Len(aESTORD)
					dbSelectArea("ST9")
					dbSetOrder(1)
					If dbSeek(cFilCon +  aESTSTZ[mm,1])
						If ST9->T9_TEMCONT $ 'P/I'
							If aSCAN(aESTREC,{|x| x[1] == aESTORD[mm][1]}) = 0
								dbSelectArea("STZ")
								dbSetOrder(02)
								dbSeek(NGTROCAFILI("STZ",cFilCon)+aESTSTZ[mm,1]+DTOS(aESTSTZ[mm,2])+If(Empty(aESTSTZ[mm,4]),"E","S")+aESTSTZ[mm,3])
								Aadd(aESTREC,{aESTORD[mm][1],aESTORD[mm][2],aESTORD[mm][3],aESTORD[mm][6], STZ->TZ_BEMPAI,STZ->TZ_TEMCONT})
							EndIf
						EndIf
					Endif
				Next mm

				// RECALCULA OS BENS FILHOS A PARTIR DA DATA
				For nn := 1 To Len(aESTREC)
					If vNREPAS <> NIL
						If Len(vNREPAS) > 0
							If aSCAN(vNREPAS,{|x| x == aESTREC[nn][1]}) > 0
								Loop
							Endif
						Endif
					Endif
					dbSelectArea(vARQCON[1])
					dbSetOrder(1)
					If dbSeek(cFilCon+aESTREC[nn][1])

						nDiffFilho := nDIFERE //Diferenca percorrida pelo Pai, com virada (caso o Pai tenha feito virada)
						cTipoFilho := cTIPLA  //Tipo de Lancamento do filho
						lViraFilho := lVIRADA //Virada de Contador do Filho

						//Contadores controlados pelo Pai nao possuem virada
						If vARQCON[1] == "ST9" .And. ST9->T9_TEMCONT == "P"
							nDiffFilho := nIncrFilho //Diferenca percorrida pelo Pai -> sem fazer virada
							cTipoFilho := If(cTipoFilho <> "V", cTipoFilho, "C") //Tipo de Lancamento do filho -> filho nao tem virada se controlado pelo Pai
							lViraFilho := .F. //Virada de Contador do Filho -> nao existe
						EndIf

						//---------------------------------------------------------------------------
						// Se a Data+Hora for igual a entrada do componente n„o poder· ser feita a
						// alteraÁ„o de contador, pois o componente n„o participou deste incremento.
						//---------------------------------------------------------------------------
						lENTRADA := .F.
						If DTOS(dLEIT)+cHORAL == DTOS(aESTREC[nn][2])+aESTREC[nn][3]
							nDiffFilho := 0
							lENTRADA := .T.
						EndIf

						dbSelectArea(vARQCON[2])
						dbSetOrder(5)

						// VERIFICAR QUAL A POSIÄ«O QUE IRµ CAIR PARA PEGAR O ACUMULADO
						// CALCULAR A VARIACAO DIA

						// INCLUIR O NOVO REGISTRO NO STP
						// RECALCULAR OS REGISTRO POSTERIORES
						// ATUALIZAR O ST9
						dbSeek(cFilHis+aESTREC[nn][1]+Dtos(dLEIT)+cHORAL,.T.)
						If Eof()
							dbSkip(-1)
						Else
							If &(vARQCON[3]) == cFilHis .And. &(vARQCON[4]) <> aESTREC[nn][1]
								dbSkip(-1)
								If &(vARQCON[3]) == cFilHis .And. &(vARQCON[4]) <> aESTREC[nn][1]
									dbSkip()
								Endif
							Endif
						Endif
						If &(vARQCON[3]) == cFilHis .And. &(vARQCON[4]) = aESTREC[nn][1]
							nACUMUL := &(vARQCON[8])
							If &(vARQCON[5]) > dLEIT
								dbSkip(-1)
							Endif
							If !Bof() .And. &(vARQCON[3]) == cFilHis .And. &(vARQCON[4]) = aESTREC[nn][1]
								If &(vARQCON[5]) = dLEIT
									If &(vARQCON[14]) < cHORAL
										nACUMUL := &(vARQCON[8])
									Else
										dbSkip(-1)
										If !Bof() .And. &(vARQCON[3]) == cFilHis .And. &(vARQCON[4]) = aESTREC[nn][1]
											nACUMUL := &(vARQCON[8])
										Endif
									Endif
								Else
									nACUMUL := &(vARQCON[8])
								Endif
							Endif
							If lViraFilho
								nACUMUL += ( (&(vARQCON[10]) - &(vARQCON[6])) + nPOSCONT )
							Else
								nACUMUL += nDiffFilho
							EndIf
						Else
							nACUMUL := &(vARQCON[12]) + nDiffFilho
						Endif

						nVIRADA := &(vARQCON[9])

						nVARDIA := NGVARIADT(aESTREC[nn][1],dLEIT,nTIPOC,nACUMUL,.F.,.F.,cFilHis,cFilCon)

						dbSelectArea(vARQCON[2])
						NGGRAVAHIS( aESTREC[nn][1], nPOSCONT, nVARDIA, dLEIT, nACUMUL, nVIRADA, cHORAL, nTIPOC, cTipoFilho, cFilHis, cFilCon, cOrigem )

						//Define lista de filhos que ser· reprocessado o contador conforme o pai da estrutura.
						aAdd( aComponents, { aESTREC[nn,1], (vARQCON[2])->( Recno() ), nDiffFilho, lViraFilho, nPOSCONT, dLEIT, nTIPOC, .T., .T., Nil, cFilCon, cFilHis, .F., aESTREC[nn,6], aESTREC[nn,5] } )

					Endif
				Next nn

				//Recalcula o Historico do Contador para filhos da estrutura.
				If !Empty( aComponents )
					NGRECALHIS( , , , , , , , , , , , aComponents )
				EndIf

			/* Verifica se esta utlizando o MV_NGLANEX com a opÁ„o "A" e se o bem possui filhos que entraram posteriormente 
			   ao lanÁamento do contador. 			   
			   Caso exista componentes que entraram anterior a esta data j· È tratado no IF. 
			*/ 
			ElseIf cUseLanex $ "A" .And. lProcEst 

				//Query para verificar e buscar os componentes que entraram na estrutura posterior ao lanÁamento deste contador.
				BeginSql Alias cAliasSTZ

					SELECT STZ.TZ_FILIAL, STZ.TZ_BEMPAI, STZ.TZ_CODBEM, STZ.TZ_DATAMOV, STZ.TZ_HORAENT, STZ.TZ_TEMCONT, STP.R_E_C_N_O_ 
					FROM %Table:STZ% STZ
						INNER JOIN %Table:STP% STP
						ON STP.TP_FILIAL = STZ.TZ_FILIAL AND STP.TP_CODBEM = STZ.TZ_CODBEM AND STP.%NotDel%
						AND STP.TP_DTLEITU = STZ.TZ_DATAMOV AND STP.TP_HORA = STZ.TZ_HORAENT
					WHERE STZ.TZ_BEMPAI= %exp:cBEM%
						AND STZ.%NotDel% AND STZ.TZ_FILIAL = %xFilial:STZ%
						AND STZ.TZ_DATAMOV || STZ.TZ_HORAENT > %exp:DtoS(dLEIT)+cHORAL% 
				EndSql

				While (cAliasSTZ)->( !EoF() )
					
					If (cAliasSTZ)->TZ_TEMCONT == "P"
						cFather := NGBEMPAI(cBEM, dLEIT, cHORAL)
						
						If Empty(cFather)
							cFather	:= (cAliasSTZ)->TZ_BEMPAI
						EndIf

					Else
						
						cFather	:= (cAliasSTZ)->TZ_BEMPAI
					
					EndIf
					
					DbSelectArea("STP")
					dbSetOrder(5) // TP_FILIAL + TP_CODBEM + TP_DTLEITU + TP_HORA
					// Busca o contador do bem pai no momento da entrada na estrutura
					If dbseek((cAliasSTZ)->TZ_FILIAL + cFather + (cAliasSTZ)->TZ_DATAMOV + (cAliasSTZ)->TZ_HORAENT)
						
						nPosPai	:= STP->TP_POSCONT
						
						// Busca o contador do bem filho no momento da entrada na estrutura
						If dbseek((cAliasSTZ)->TZ_FILIAL + (cAliasSTZ)->TZ_CODBEM + (cAliasSTZ)->TZ_DATAMOV + (cAliasSTZ)->TZ_HORAENT)
							nPosFilho := STP->TP_POSCONT
						EndIf
						
						// Atualiza a diferenÁa do contador.
						nDifContad := nPosFilho - nPosPai

					EndIf

					aAdd( aComponents, { (cAliasSTZ)->TZ_CODBEM, (cAliasSTZ)->R_E_C_N_O_ , nDifContad, .F., nPosCont, StoD((cAliasSTZ)->TZ_DATAMOV), 1, .F., .T., Nil, cFilCon, cFilHis,.F., (cAliasSTZ)->TZ_TEMCONT, cFather } )
					
					(cAliasSTZ)->(DbSkip())

				End
				
				(cAliasSTZ)->(dbCloseArea())

				If !Empty( aComponents )
					NGRECALHIS( , , , , , , , , , , , aComponents )
				EndIf

			EndIf

		EndIf

	EndIf

	If ExistBlock("NGUTIL4C")
		ExecBlock("NGUTIL4C",.F.,.F.,{cBEM,dLEIT,cHORAL,nPOSCONT,nACUMULPE})
	Endif

	RestArea( aAreaSTZ )

Return nDIFERE
/*/
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
	±±≥FunáÖo    ≥NGATUCONT ≥ Autor ≥In†cio Luiz Kolling    ≥ Data ≥11/03/2003≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥DescriáÖo ≥Atualiza o contador                                         ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥Parametros≥cBEMT9   - C¢digo do bem                       - Obrigat¢rio≥±±
	±±≥          ≥dLEITT9  - Data da leitura                     - Obrigat¢rio≥±±
	±±≥          ≥nPOSCT9  - Valor do contador                   - Obrigat¢rio≥±±
	±±≥          ≥nACUMUT9 - Valor do contador acumulado         - Obrigat¢rio≥±±
	±±≥          ≥nVARDT9  - Valor da variaá∆o dia               - Obrigat¢rio≥±±
	±±≥          ≥nTIPOC   - Tipo do contador                    - Obrigat¢rio≥±±
	±±≥          ≥lVIRA    - Indice se houve virada              - Obrigat¢rio≥±±
	±±≥          ≥lRECSTP  - Indice se foi recalculado STP       - Obrigat¢rio≥±±
	±±≥          ≥cFilNov  - Codigo da filial                    - Nao Obrig. ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥Retorna   ≥ .T.                                                        ≥±±
	±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function NGATUCONT(cBEMT9,dLEITT9,nPOSCT9,nACUMUT9,nVARDT9,nTIPOC,lVIRA,;
		lRECSTP,cFilNov)
	Local lGRAVRES := .F.
	Local vATUBEMC := If(nTIPOC = 1,{'ST9','st9->t9_dtultac','st9->t9_poscont',;
		'st9->t9_contacu','st9->t9_vardia',;
		'st9->t9_viradas'},;
		{'TPE','tpe ->tpe_dtulta','tpe ->tpe_poscon',;
		'tpe ->tpe_contac','tpe ->tpe_vardia',;
		'tpe ->tpe_virada'})

	Local cFilArq := NGTROCAFILI(vATUBEMC[1],cFilNov)

	dbSelectArea(vATUBEMC[1])
	dbSetOrder(1)
	If dbSeek(cFilArq+cBEMT9)
		RecLock(vATUBEMC[1],.F.)
		If dLEITT9 > &(vATUBEMC[2])
			&(vATUBEMC[2]) := dLEITT9
			&(vATUBEMC[3]) := nPOSCT9
			lGRAVRES := .T.
		ElseIf dLEITT9 = &(vATUBEMC[2])
			If nPOSCT9 <> &(vATUBEMC[3]) .And. nACUMUT9 > &(vATUBEMC[4])
				&(vATUBEMC[3]) := nPOSCT9
				lGRAVRES := .T.
			Endif
		ElseIf lRECSTP
			lGRAVRES := .T.
		Endif

		If lGRAVRES
			&(vATUBEMC[4]) := nACUMUT9
			&(vATUBEMC[5]) := nVARDT9
			&(vATUBEMC[6]) := If(lVIRA,&(vATUBEMC[6])+1,&(vATUBEMC[6]))
		Endif
		MsUnLock(vATUBEMC[1])
	Endif
Return .T.
/*/
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
	±±≥Funá∆o    ≥NGGRAVAHIS≥ Autor ≥In†cio Luiz Kolling    ≥ Data ≥11/03/2003≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥DescriáÖo ≥Gera registro de historico ( STP )                          ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥Parametros≥cVBEM   - C¢digo do bem                        - Obrigat¢rio≥±±
	±±≥          ≥nVCONT  - Valor do contador                    - Obrigat¢rio≥±±
	±±≥          ≥nVVARD  - Valor da variaá∆o dia                - Obrigat¢rio≥±±
	±±≥          ≥dVDLEIT - Data da leitura                      - Obrigat¢rio≥±±
	±±≥          ≥nVACUM  - Valor do contador acumulado          - Obrigat¢rio≥±±
	±±≥          ≥nVIRACO - N£mero de viradas ia                 - Obrigat¢rio≥±±
	±±≥          ≥cVHORA  - Hora do lancamento                   - Obrigat¢rio≥±±
	±±≥          ≥nTIPOC  - Tipo do contador ( 1/2 )             - Obrigat¢rio≥±±
	±±≥          ≥cTIPOL  - Tipo de lancamento                   - Obrigat¢rio≥±±
	±±≥          ≥cFIHIS  - Codigo da filial do historico        - Obrigat¢rio≥±±
	±±≥          ≥cFICON  - Codigo da filial do contador         - Obrigat¢rio≥±±
	±±≥          ≥cOrigem  - Nome do programa origem (Ex: MNTAXXX)             ±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥Retorna   ≥ .T.                                                        ≥±±
	±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function NGGRAVAHIS(cVBEM,nVCONT,nVVARD,dVDLEIT,nVACUM,nVIRACO,cVHORA,;
		nTIPOC,cTIPOL,cFIHIS,cFICON,cOrigem)
	Local cPLATP := Replicate('0',Len(stp->tp_ordem))
	Local cLANTP := If(cTIPOL = Nil .Or. Empty(cTIPOL),"C",cTIPOL)
	Local lApropri:= NGCADICBASE("TP_APROPRI","A","STP",.F.) .And. NGCADICBASE("TPP_APROPR","A","TPP",.F.) .And. AllTrim(GetNewPar("MV_NGINTER","N")) == "M"
	Local lOrigem := NGCADICBASE("TP_ORIGEM","A","STP",.F.) .And. NGCADICBASE("TPP_ORIGEM","A","TPP",.F.)
	Local cOSSTP
	Local cFICONG  := If(nTIPOC = 1,NGTROCAFILI("ST9",cFICON),NGTROCAFILI("TPE",cFICON))
	Local cFIHISG  := If(nTIPOC = 1,NGTROCAFILI("STP",cFIHIS),NGTROCAFILI("TPP",cFIHIS))
	Local lSeek    := .F.
	Local cApropri := '2'

	Default cOrigem := ''

	If nTIPOC = 1
		dbselectArea('ST9')
		dbSetOrder(1)
		If dbseek(cFICONG+cVBEM)
			dbselectArea('STP')
			dbSetOrder(05)
			If !dbSeek(cFIHISG+cVBEM+DTOS(dVDLEIT)+cVHORA)

				cOSSTP := GETSXENUM('STP','TP_ORDEM',cFIHISG+x2path('STP'))
				ConfirmSX8()

				// Evita duplicidade de registros
				lSeek := .T.
				While lSeek
					dbSelectArea("STP")
					dbSetOrder(1)
					lSeek := dbSeek(cFIHISG + cOSSTP + cPLATP + cVBEM + DTOS(dDataBase))
					If lSeek

						cOSSTP := GETSXENUM('STP','TP_ORDEM',cFIHISG+x2path('STP'))
						ConfirmSX8()

						If lApropri
							cApropri := If(MNA385APR(cVBEM,dVDLEIT,cVHORA,1,.T.),'1','2')
						EndIf

					EndIf
				End

				//VariaÁ„o dia nao pode ser menor que 1
				If nVVARD < 1
					nVVARD := 1
				EndIf

				dbSetOrder(5)

				dbselectArea("STP")
				RecLock("STP",.T.)
				STP->TP_FILIAL  := cFIHISG
				STP->TP_ORDEM   := cOSSTP
				STP->TP_PLANO   := cPLATP
				STP->TP_CODBEM  := cVBEM
				STP->TP_CCUSTO  := st9->t9_ccusto
				STP->TP_CENTRAB := st9->t9_centrab
				STP->TP_DTORIGI := dDataBase
				STP->TP_DTREAL  := dDataBase
				STP->TP_POSCONT := nVCONT
				STP->TP_VARDIA  := nVVARD
				STP->TP_DTULTAC := dVDLEIT
				STP->TP_DTLEITU := dVDLEIT
				STP->TP_SITUACA := "L"
				STP->TP_TERMINO := "S"
				STP->TP_USULEI  := If(Len(STP->TP_USULEI) > 15,cUsername,Substr(cUsuario,7,15))
				STP->TP_TEMCONT := st9->t9_temcont
				STP->TP_ACUMCON := nVACUM
				STP->TP_VIRACON := nVIRACO
				STP->TP_HORA    := cVHORA
				STP->TP_TIPOLAN := cLANTP
				If lApropri
					STP->TP_APROPRI := cApropri
				EndIf
				If lOrigem
					STP->TP_ORIGEM := IIf( !Empty(cOrigem), cOrigem, fGetOrigem() )
				EndIf
				MsUnLock("STP")
			EndIf
		Endif
	Else
		nACUMPP := nVACUM
		nVVARDP := nVVARD
		dbSelectArea('TPE')
		dbSetOrder(1)
		If dbSeek(cFICONG+cVBEM)
			dbSelectArea('TPP')
			dbSetOrder(2)
			If !dbSeek(cFIHISG+cVBEM)
				nACUMPP := tpe->tpe_contac
				nVVARDP := tpe->tpe_vardia
			Endif
		Else
			dbSelectArea('TPP')
			dbSetOrder(2)
			If !dbSeek(cFIHISG+cVBEM)
				nACUMPP := 0
				nVVARDP := 1
			Endif
		Endif

		dbSelectArea('TPP')
		dbSetOrder(5)
		If !dbSeek(cFIHISG+cVBEM+DTOS(dVDLEIT)+cVHORA)

			cOSSTP := GETSXENUM('TPP','TPP_ORDEM',cFIHISG+x2path('TPP'))
			ConfirmSX8()

			If lApropri
				cApropri := If(MNA385APR(cVBEM,dVDLEIT,cVHORA,2,.T.),'1','2')
			EndIf

			// Evita duplicidade de registros
			lSeek := .T.
			While lSeek
				dbSelectArea("TPP")
				dbSetOrder(1)
				lSeek := dbSeek(cFIHISG + cOSSTP + cPLATP + cVBEM)
				If lSeek

					cOSSTP := GETSXENUM('TPP','TPP_ORDEM',cFIHISG+x2path('TPP'))
					ConfirmSX8()

				EndIf
			End

			//VariaÁ„o dia nao pode ser menor que 1
			If nVVARDP < 1
				nVVARDP := 1
			EndIf

			dbSetOrder(5)

			dbSelectArea("TPP")
			RecLock("TPP",.T.)
			TPP->TPP_FILIAL := cFIHISG
			TPP->TPP_ORDEM  := cOSSTP
			TPP->TPP_PLANO  := cPLATP
			TPP->TPP_CODBEM := cVBEM
			TPP->TPP_CCUSTO := st9->t9_ccusto
			TPP->TPP_CENTRA := st9->t9_centrab
			TPP->TPP_DTORIG := dDataBase
			TPP->TPP_DTREAL := dDataBase
			TPP->TPP_POSCON := nVCONT
			TPP->TPP_VARDIA := nVVARDP
			TPP->TPP_DTULTA := dVDLEIT
			TPP->TPP_DTLEIT := dVDLEIT
			TPP->TPP_SITUAC := "L"
			TPP->TPP_TERMIN := "S"
			TPP->TPP_USULEI := If(Len(TPP->TPP_USULEI) > 15,cUsername,Substr(cUsuario,7,15))
			TPP->TPP_ACUMCO := nACUMPP
			TPP->TPP_VIRACO := nVIRACO
			TPP->TPP_HORA   := cVHORA
			TPP->TPP_TIPOLA := cLANTP
			If lApropri
				TPP->TPP_APROPR := cApropri
			EndIf
			If lOrigem
				TPP->TPP_ORIGEM := IIf( !Empty(cOrigem), cOrigem, fGetOrigem() )
			EndIf
			MsUnLock("TPP")
		EndIf
	Endif

	//-------------------------
	// Incrementa a Km do Pneu
	//-------------------------
	If nTIPOC == 1
		If IsInCallStack("MNTA875") .And. !IsInCallStack("MNTA877")
			MNT877TQS(cVBEM, cFICONG)
		ElseIf !IsInCallStack("MNTA877")
			NGKMTQS(cVBEM,dVDLEIT,cVHORA)
		EndIf
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetOrigem
Identifica o fonte chamador para funÁ„o NGGravaHis, quando n„o informado

@since  21/09/17
@author Felipe Nathan Welter
@version P12
@return  cOrigem: cÛdigo do programa origem
/*/
//---------------------------------------------------------------------
Static Function fGetOrigem()

	Local aFontes := Array(25)
	Local cOrigem := ""

	aEVal(aFontes,{ |x,y| aFontes[y] := ProcName(y) })
	nPos := aScan(aFontes, { |x| Len(x)              == 7      .And.; //Testa [MNTA830]
	Type(SubStr(x,5,3)) == 'N'    .And.; //Testa MNTA[830]
	SubStr(x,1,3) $ 'MNT/EST/TMS' .And.; //Testa [MNT]A830
	SubStr(x,4,1) $ 'A/C/R/V/W/I/X/H' }) //Testa MNT[A]830

	If nPos > 0
		cOrigem := aFontes[nPos]
	EndIf

Return cOrigem

//-------------------------------------------------------------------
/*/{Protheus.doc} NGVARIADT
Calcula a variaÁ„o dia do bem

@type    Function
@author  In·cio Luiz Kolling
@since   11/03/2003
@version P11/P12

@param   cCODBEM,   Caracter, CÛdigo do bem
@param   dDATALEI,  Data,     Data da leitura
@param   nTIPOC,    NumÈrico, Tipo do contador ( 1 / 2 )
@param   nACUMSTP,  NumÈrico, Contador acumulado
@param   lRECAL,    LÛgico,   Indica se dever† incluir na array o
                              Contador Acumulado do STP ou o contador
do par‚metro nACUMSTP\
@param   lESTOUR,   LÛgico,   Indica se dever† considerar o estouro
                              da variaÁ„o dia
@param   [cFilNov], Caracter, CÛdigo da filial

@return nVarDia, NumÈrico,    C·lculo da variaÁ„o dia.
/*/
//-------------------------------------------------------------------
FUNCTION NGVARIADT(cCODBEM,dDATALEI,nTIPOC,nACUMSTP,lRECAL,lESTOUR,cFilNov,cFilMulEmp)

	Local nVARDIA := 0
	Local nMIN	  := 0
	Local nMAX	  := 0
	Local dMIN    := CtoD("  /  /  ")
	Local dMAX    := dMIN
	Local aVARDIA := {}
	Local cALIOLD := Alias()
	Local nORDOLD := IndexOrd()
	Local nREGVAR := GetNewPar("MV_VARDIA",0)
	Local lPRECAL := .T.
	Local aArqBem := If(nTIPOC == 1, {"ST9", "ST9->T9_VARDIA" }, {"TPE", "TPE->TPE_VARDIA"} )
	Local vARQDIA := If(nTIPOC == 1, {'STP','stp->tp_filial','stp->tp_codbem',;
		'stp->tp_dtleitu','stp->tp_acumcon','stp->tp_vardia'},;
		{'TPP','tpp->tpp_filial','tpp->tpp_codbem',;
		'tpp->tpp_dtleit','tpp->tpp_acumco','tpp->tpp_vardia'})

	Local vLAc := TamSX3(Alltrim(UPPER(Substr(vARQDIA[5],At('>',vARQDIA[5])+1,Len(vARQDIA[5])))))
	//Atualiza filial se enviado como par‚metro na chamada da funÁ„o
	Local cFilArx  := NGTROCAFILI(vARQDIA[1],cFilNov)

	If !Empty(cFilNov)
		cFilArx := cFilNov
	EndIf

	dbSelectArea(vARQDIA[1])
	While !Bof() .And. cFilArx == &(vARQDIA[2]) .And. &(vARQDIA[3]) == cCODBEM .and. nREGVAR > 0
		If !Empty(&(vARQDIA[4]))
			If !lRECAL
				aadd(aVARDIA,{&(vARQDIA[4]),&(vARQDIA[5]),&(vARQDIA[6])})
			Else
				If lPRECAL
					aadd(aVARDIA,{&(vARQDIA[4]),nACUMSTP,&(vARQDIA[6])})
					lPRECAL := .F.
				Else
					aadd(aVARDIA,{&(vARQDIA[4]),&(vARQDIA[5]),&(vARQDIA[6])})
				Endif
			Endif
			nREGVAR--
		Endif
		dbSkip(-1)
	EndDo

	If !lRECAL
		aadd(aVARDIA,{dDATALEI,nACUMSTP,0})
	Endif

	lVARDIG := .F.

	If Len(aVARDIA) > 0
		aVARDIA := Asort(aVARDIA,,,{|x,y| Dtos(x[1])+Str(x[2],vLAc[1]) < Dtos(y[1])+Str(y[2],vLAc[1])})
		dMIN    := aVARDIA[1][1]
		nMIN    := aVARDIA[1][2]
		dMAX    := aVARDIA[Len(aVARDIA)][1]
		nMAX    := aVARDIA[Len(aVARDIA)][2]
		lVARDIG := If(nMIN = nMAX .And. dMIN = dMAX,.T.,.F.)
	Endif

	If !lVARDIG
		nVARDIA := ROUND ((nMAX - nMIN) / (dMAX - dMIN),0)
	Else
		nVARDIA := If(!Empty(aVARDIA[1][3]),aVARDIA[1][3],aVARDIA[Len(aVARDIA)][3])
	Endif

	nVARDIA := IIf( nVARDIA <= 0, 1, nVARDIA )

	If !lESTOUR
		nVARDIA := If(nVARDIA > 999999,999999,nVARDIA)
	Endif

	If !Empty(cALIOLD)
		dbSelectArea(cALIOLD)
		dbSetOrder(nORDOLD)

		aSize(aVARDIA,0)
		aVARDIA := Nil
		aSize(aArqBem,0)
		aArqBem := Nil
		aSize(vARQDIA,0)
		vARQDIA := Nil
	EndIf

Return nVARDIA

//------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} NGRECALHIS
Realiza a chamada do processo de recalculo do histÛrico de contadores, utilizando-se de threads ou n„o.
@type function

@author In·cio Luiz Kolling
@since 11/03/2003

@sample NGRECALHIS( , , , , , , , , , , , { 'Bem', 1, 225, .T., 100, 28/05/1996, 1, .F., .T., 100, 'M RJ 01 ', 'M RJ 01 '} )
@sample NGRECALHIS( 'Bem', 225, 100, 28/05/1996, 1, .F., .T., .T., 100, 'M RJ 01 ', 'M RJ 01 ' )

@param [cVBem]      , Caracter, CÛdigo do bem.
@param [nVDIF]      , N˙merico, Valor a ser somado no acumulado.
@param nVPOSC       , N˙merico, PosiÁ„o do contador.
@param dDLEIT       , Data    , Leitura do contador.
@param nTIPOC       , N˙merico, Tipo do contador.
@param lSKIP        , LÛgico  , Indica se deve selecionar um registro anterior ao atual ( bem/filho).
@param [lVIRA]      , LÛgico  , Indice se houve virada.
@param lATUST9      , LÛgico  , Indice se sempre atualiza ST9 ao final do processo.
@param [nACUMEX]    , N˙merico, Aculumador na alteracao do historico.
@param [cFilCon]    , Caracter, Filial do contador.
@param [cFilHis]    , Caracter, Filial do historico contador.
@param [aEquipments], Array   , Lista de bens para reprocessamento em lote dos contadores. Quando este parametro
	for utilizado, dispensa o preenchimento dos par‚metros anteriores. Mesmo assim caso sejam informados juntamente
ser· priorizado o conteudo do par‚metro a aEquipments

@return Nil
/*/
//------------------------------------------------------------------------------------------------------
Function NGRECALHIS( cVBem, nVDIF, nVPOSC, dDLEIT, nTipoC, lSKIP, lVIRA, lATUST9, nACUMEX, cFilCon, cFilHis, aEquipments )

	Local aAreaSTP  := STP->( FWGetArea() )
	Local nRecHis   := IIf( ValType( nTipoC ) == 'N', IIf( nTipoC == 1, STP->( Recno() ), TPP->( Recno() ) ), Nil )
	Local lStartJob := IsInCallStack( 'MNTA400' ) .Or.;
					   IsInCallStack( 'MNTA435' ) .Or.;
					   IsInCallStack( 'MNTA420' ) .Or.;
					   IsInCallStack( 'MNTA655' ) .Or.;
					   IsInCallStack( 'MNTA656' ) .Or.;
					   IsInCallStack( 'MNTA260' ) .Or.;
					   IsInCallStack( 'MNTA995' ) .Or.;
					   IsInCallStack( 'MNT635CONS' )

	Default lATUST9     := .F.
	Default aEquipments := { { cVBem, nRecHis, nVDIF, lVIRA, nVPOSC, dDLEIT, nTipoC, lSKIP, lATUST9, nACUMEX, cFilCon, cFilHis, .F. } }

	If lStartJob

		StartJob( 'NGRECALREG', GetEnvserver(), .F., .T., cEmpAnt, cFilAnt, aEquipments )

	Else

		Processa({|lEnd| NGRECALREG( /*lJob*/, /*cEmpAtu*/, /*cFilAtu*/, aEquipments ) }, STR0001 ) // Reprocessando Lancamentos

	EndIf

	FWRestArea( aAreaSTP )

Return

//----------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} NGRECALREG
Realiza o recalculo de contadores por registros.
@type function

@author NG Inform·tica
@since 17/08/2015

@sample NGRECALREG( .F., 'T1', 'M RJ 01 ', aArray )

@param lJob       , LÛgico  , Indica se o processo ser· executado em thread
@param cEmpAtu    , Caracter, Empresa atual.
@param cFilAtu    , Caracter, Filial atual.
@param aEquipments, Array   , ContÈm registros para reprocessamento em lote.
					[1]  - CÛdigo do Bem
					[2]  - Recno do registro na tabela STP ou TPP.
					[3]  - Valor a ser somado no acumulado.
					[4]  - Indice se houve virada.
					[5]  - PosiÁ„o do contador.
					[6]  - Data de leitura do contador.
					[7]  - Tipo do contador.
					[8]  - Indica se dever†selecionar um registro anterior ao atual ( bem/filho).
					[9]  - Indice se sempre atualiza ST9 ao final do processo.
					[10] - Aculumador na alteracao do historico.
					[11] - Filial do contador.
					[12] - Filial do historico contador.
					[13] - Se atualiza TQS apÛs rec·lculo
					[14] - Contador controlado por: (P-Pai ,I-Imediato, N-N„o tem, S-Proprio)
					[15] - CÛdigo do bem Pai
@return .T.
/*/
//----------------------------------------------------------------------------------------------------------
Function NGRECALREG( lJob, cEmpAtu, cFilAtu, aEquipments )

	Local nREGSTP    := 0
	Local nVARDSTP   := 0
	Local nACUMSTP   := 0
	Local nVIRASTP   := 0
	Local nPOSCSTP   := 0
	Local nPOSCUTI   := 0
	Local nVIRADTI   := 0
	Local nContLim   := 0
	Local nContAnt   := 0
	Local nContDiff  := 0
	Local nPosScan   := 0
	Local nACUMANT   := 0
	Local nACUMATU   := 0
	Local nX         := 0
	Local nVDIF      := 0
	Local cVBem      := ''
	Local cFilCont   := ""
	Local cFilHist   := ""
	Local cFilCTQS   := ""
	Local cFILARQ    := ""
	Local cCODBEM    := ""
	Local cHorLanAtu := ""
	Local cCodBemPai := ""
	Local cLanex     := ""
	Local cHORASTP   := ""
	Local cHORAENT   := ""
	Local cTPLAN     := ""
	Local cTipLanAtu := ""
	Local cTIPOLAN   := ""
	Local dDATAMOV   := StoD("")
	Local dDATALEI   := StoD("")
	Local dDatLanAtu := StoD("")
	Local lAcumulou  := .F.
	Local lEntrada   := .F.
	Local lULTIMOR   := .T.
	Local lVIRA      := .F.
	Local aAreaSave  := {}
	Local aEstBemPai := {}
	Local aAreaSSTP  := {}
	Local aFldHisC   := {}
	Local aFldCntB   := {}
	Local aARQHist   := {}
	Local aARQCont   := {}
	Local lNGUTIL4S  := ExistBlock("NGUTIL4S")
	Local lUpdTQS    := .F.
	Local cTipoCont  := ""
	Local cBemPai    := ""
	Local cAliasSTZ	 := GetNextAlias()

	Default lJob      := .F.

	If lJob
		RPCSetType( 3 )
		RPCSetEnv( cEmpAtu, cFilAtu, '', '', 'MNT' )
	EndIf

	If lJob
		// AdiÁ„o do sleep, pois h· cen·rios em que o processo demora muito para finalizar, ent„o ao comeÁar o job algumas informaÁıes n„o existem
		Sleep( 6000 )
	EndIf

	aAdd( aFldHisC, { 'STP', 'STP->TP_FILIAL', 'STP->TP_CODBEM', 'STP->TP_POSCONT', 'STP->TP_ACUMCON', 'STP->TP_DTLEITU',;
		'STP->TP_VIRACON', 'STP->TP_VARDIA', 'STP->TP_HORA', 'STP->TP_TIPOLAN' } )

	aAdd( aFldHisC, { 'TPP', 'TPP->TPP_FILIAL', 'TPP->TPP_CODBEM', 'TPP->TPP_POSCON', 'TPP->TPP_ACUMCO', 'TPP->TPP_DTLEIT',;
		'TPP->TPP_VIRACO', 'TPP->TPP_VARDIA', 'TPP->TPP_HORA', 'TPP->TPP_TIPOLA' } )

	aAdd( aFldCntB, { 'ST9', 'ST9->T9_DTULTAC', 'ST9->T9_POSCONT', 'ST9->T9_CONTACU', 'ST9->T9_VARDIA', 'ST9->T9_VIRADAS',;
		'ST9->T9_LIMICON', 'ST9->T9_TEMCONT' } )

	aAdd( aFldCntB, { 'TPE', 'TPE->TPE_DTULTA', 'TPE->TPE_POSCON', 'TPE->TPE_CONTAC', 'TPE->TPE_VARDIA', 'TPE->TPE_VIRADA',;
		'TPE->TPE_LIMICO', "'S'" } )

	For nX := 1 to Len( aEquipments )

		cVBem     := aEquipments[nX,1]  // CÛdigo do Bem
		nVDIF     := aEquipments[nX,3]  // DiferenÁa somada ao acumulado
		lVIRA     := aEquipments[nX,4]  // Indica se houve virada
		nVPOSC    := aEquipments[nX,5]  // Valor do contador
		dDLEIT    := aEquipments[nX,6]  // Data da leitura
		nTIPOC    := aEquipments[nX,7]  // Tipo contador
		lSKIP     := aEquipments[nX,8]  // Indica se dever†selecionar um registro anterior ao registro atual(bem/filho)
		IST9ATU   := aEquipments[nX,9]  // Indice se sempre atualiza ST9
		nACUMEX   := aEquipments[nX,10] // Aculumador na alteracao do historico
		cFilCon   := aEquipments[nX,11] // Filial do contador
		cFilHis   := aEquipments[nX,12] // Filial do historico do contador
		lUpdTQS   := Len( aEquipments[nX] ) > 12 .And. ValType( aEquipments[nX,13] ) == "L" .And. aEquipments[nX,13]

		

		If Len( aEquipments[nX] ) >= 14

			cTipoCont := aEquipments[nX,14] // Contador controlado por
			cBemPai   := aEquipments[nX,15] // CÛdigo do bem PAI

		Else

			cTipoCont := ''
			cBemPai   := cVBem

		EndIf

		aARQHist  := aClone( aFldHisC[nTIPOC] )
		aARQCont  := aClone( aFldCntB[nTIPOC] )

		//Preenchimento de variaveis que necessitam de posicionamento.
		dbSelectArea( aARQHist[1] )
		dbGoTo( aEquipments[nX,2] )

		lULTIMOR  := .T.
		nVARDSTP  := &(aARQHist[8])
		nACUMSTP  := &(aARQHist[5])
		nVIRASTP  := &(aARQHist[7])
		nPOSCSTP  := &(aARQHist[4])
		nPOSCUTI  := &(aARQHist[4])
		nVIRADTI  := &(aARQHist[7])
		cHORASTP  := &(aARQHist[9])
		nACUMANT  := &(aARQHist[5])
		nACUMATU  := &(aARQHist[5])
		dDATALEI  := &(aARQHist[6])
		cTIPOLAN  := &(aARQHist[10])
		cFilCont  := NGTROCAFILI(aARQCont[1],cFilCon)
		cFilHist  := NGTROCAFILI(aARQHist[1],cFilHis)
		cFilCTQS  := NGTROCAFILI("TQS",cFilCon)
		cFILARQ   := &(aARQHist[2])
		cCODBEM   := &(aARQHist[3])
		dDATAMOV  := &(aARQHist[6])
		cHORAENT  := &(aARQHist[9])
		cTPLAN    := &(aARQHist[10])

		If lNGUTIL4S
			If ExecBlock("NGUTIL4S",.F.,.F.,{&(aARQHist[3]),&(aARQHist[6]),&(aARQHist[9]),IST9ATU,lVIRA,nVPOSC,cFilCont,nVARDSTP,;
					cFilHist,cVBem,nPOSCSTP,nACUMSTP,nACUMATU,nACUMEX,nVDIF,nACUMANT,dDATALEI,nPOSCUTI,nVIRADTI,lSKIP})
				Return .T.
			Endif
		Endif

		cLanex := ""
		If nTIPOC == 1
			cLanex := NGUSELANEX( STP->TP_CODBEM, .F., STP->TP_DTLEITU, STP->TP_HORA ) // verifica par‚metro
		EndIf

		dbSelectArea(aARQHist[1])
		dbSetOrder(5)
		If lSKIP
			//Antes de pular o registro para recalcular os demais, verifica se ele mesmo precisa ser atualizado
			aAreaSSTP := STP->(GetArea())
			aAreaSave := GetArea()

			cTipLanAtu := &(aARQHist[10])
			dDatLanAtu := &(aARQHist[6])
			cHorLanAtu := &(aARQHist[9])
			lAcumulou  := .F.

			dbSkip(-1)
			If &(aARQHist[2]) == cFilHist .And. &(aARQHist[3]) == cVBem
				If cTipLanAtu == "Q" //Se o registro e' uma Quebra, deixa o acumulado de acordo com o anterior
					nACUMSTP  := &(aARQHist[5])
					lAcumulou := .T.
				EndIf
			EndIf
			dbSkip()

			//Atualiza o Contador Acumulado do registro do historico
			If lAcumulou .And. &(aARQHist[5]) <> nACUMSTP
				RecLock(aARQHist[1],.F.)
				&(aARQHist[5]) := nACUMSTP
				MsUnLock(aARQHist[1])
			EndIf

			RestArea(aAreaSSTP)
			RestArea(aAreaSave)

			dbSkip()
		Endif

		ProcRegua(LastRec())
		While !Eof() .And. cFilHist == &(aARQHist[2]) .And. &(aARQHist[3]) == cVBem
			IncProc(STR0002+cVBEM) //"Processando Bem -> "
			nREGSTP  := Recno()
			lULTIMOR := .F.

			cTipLanAtu := &(aARQHist[10])
			dDatLanAtu := &(aARQHist[6])
			cHorLanAtu := &(aARQHist[9])
			lAcumulou  := .F.
			lEntrada   := .F.

			//------------------------------------------------------------------------------
			// ValidaÁ„o especÌfica quando for componente que acaba de entrar na estrutura
			// n„o incrementar o contador, devendo ser igual ao anterior a este registro
			//------------------------------------------------------------------------------
			If ValType(nVDIF) == "N" .And. nACUMATU == &(aARQHist[5])+nVDIF .And. cTIPOLAN <> "Q" .And. ;
					(NGIFDBSEEK("STZ",&(aARQHist[3])+DTOS(dDatLanAtu)+'E'+cHorLanAtu,2) .Or. ;
					NGIFDBSEEK("STZ",&(aARQHist[3])+DTOS(dDatLanAtu)+'S'+cHorLanAtu,2))
				nACUMSTP := nACUMATU
				lAcumulou := .T.
				lEntrada  := .T.
			EndIf
			If !lAcumulou
				//Condicao especial para se o registro for uma Quebra ou uma Virada; deve ser verificado o registro anterior
				If cTipLanAtu == "Q" .Or. cTipLanAtu == "V"
					dbSelectArea(aARQHist[1])
					dbSkip(-1)
					If &(aARQHist[2]) == cFilHist .And. &(aARQHist[3]) == cVBem
						//Se o atual for uma Quebra, o acumulado atual È o mesmo do anterior
						If cTipLanAtu == "Q"
							nACUMSTP := &(aARQHist[5])
							lAcumulou := .T.
						ElseIf cTipLanAtu == "V" //Caso o atual seja uma virada, verifica o registro anterior para fazer o acumulo do contador
							//Busca o Bem para receber o Limite do Contador
							dbSelectArea(aARQCont[1])
							dbSetOrder(1)
							
							If dbSeek(cFilHist+cVBem)							
								
								nContAnt  := &(aARQHist[4]) //Posicao do Contador anterior a virada
																
								If &(aARQCont[8]) == "S"
									nContLim  := &(aARQCont[7]) //Limite do Contador
								Else
									/*	Quando ocorre uma VIRADA e o bem n„o possui contador proprio, n„o poder· ser utilizado o campo T9_LIMICON para o calculo
										Ser· realizado a busca pelo pai da entutura e realizado o seguinte calculo:
										DiferenÁa := Acumulado Pai Posterior a Virada - Acumulado Pai Anterior a Virada
									*/
									nACUMSTP  := &(aARQHist[5])
									BeginSql Alias cAliasSTZ
										SELECT TZ_BEMPAI, TZ_TEMCONT					
											FROM %Table:STZ%
												WHERE TZ_CODBEM = %exp:cVBem% AND %NotDel% AND TZ_FILIAL = %xFilial:STZ% AND TZ_TEMCONT <> 'N'
												AND ( 
												// Quando o pneu j· saiu da estrutura, onde a dat aem quest„o precisa estar entre a entrega e saida
													(	%exp:DtoS(dDatLanAtu)+cHorLanAtu%  BETWEEN TZ_DATAMOV || TZ_HORAENT AND TZ_DATASAI || TZ_HORASAI AND TZ_TIPOMOV = 'S') 
												OR 
												// Quando a data em quest„o È maior que a entrada do pneu ele ainda n„o saiu da estrutura.
													(	%exp:DtoS(dDatLanAtu)+cHorLanAtu%  >= TZ_DATAMOV || TZ_HORAENT AND TZ_TIPOMOV  = 'E')
													)
									EndSql
									
									If (cAliasSTZ)->( !EoF() )
										
										cBemPai := cVBem

										If (cAliasSTZ)->TZ_TEMCONT == "P"
											
											// Bem controlado pelo Pai da estrutura e precisa busca em toda a arvore
											cBemPai := NGBEMPAI(cVBem, dDatLanAtu, cHorLanAtu)
											
										ElseIf (cAliasSTZ)->TZ_TEMCONT == "I"
											
											// Bem controlado pelo Pai Imediato, ou seja, o mesmo informado na TZ_BEMPAI
											cBemPai := (cAliasSTZ)->TZ_BEMPAI
																			
										EndIf

									EndIf									
									
									(cAliasSTZ)->(dbCloseArea())

									nContLim  := Posicione(aARQCont[1],1,xFilial(aARQCont[1])+cBemPai,aARQCont[7])
							
								EndIf
								nContDiff := (nContLim - nContAnt) //Diferenca Do Contador ate' a virada
								nACUMSTP  := (nACUMATU + nContDiff) //Acumula o Contador Atual com a Diferenca da Virada
								lAcumulou := .T.
							EndIf																
						EndIf						
					EndIf
					dbSelectArea(aARQHist[1])
					dbSkip()
				EndIf
			EndIf
			If !lAcumulou
				If &(aARQCont[8]) == "P"
					aAreaSSTP  := STP->(GetArea())
					aAreaSave  := GetArea()
					cCodBemPai := NGBEMPAI(cVBem,dDatLanAtu,cHorLanAtu)
					nContDiff  := 0

					//Busca a Data de Entrada e Saida do Filho na estrutura do Bem Pai
					aEstBemPai := NGRETSTCDT(cCodBemPai,dDatLanAtu,cHorLanAtu)
					nPosScan   := aScan(aEstBemPai, {|x| x[1] == cVBem })
					If nPosScan > 0
						//Se o filho ainda estava na estrutura no periodo
						If dDatLanAtu > aEstBemPai[nPosScan][2] .Or. ( dDatLanAtu == aEstBemPai[nPosScan][2] .And. cHorLanAtu >= aEstBemPai[nPosScan][3]) //Entrada
							If Empty(aEstBemPai[nPosScan][4]) .Or. ( dDatLanAtu < aEstBemPai[nPosScan][4] .Or. (dDatLanAtu == aEstBemPai[nPosScan][4] .And. cHorLanAtu <= aEstBemPai[nPosScan][5]) ) //Saida
								//Busca o lancamento do contador desse Bem Pai para a mesma Data e Hora do filho
								dbSelectArea(aARQHist[1])
								dbSetOrder(5)
								//Se encontrou e foi uma virada para o Pai, recebe a diferenca e joga essa diferenca para o filho, porque o filho nao tem virada
								If dbSeek(cFilHist+cCodBemPai+DTOS(dDatLanAtu)+cHorLanAtu) .And. &(aARQHist[10]) == "V"
									nContAnt := 0
									dbSkip(-1)
									If &(aARQHist[2]) == cFilHist .And. &(aARQHist[3]) == cCodBemPai
										nContAnt := &(aARQHist[5]) //Contador Acumulado Anterior
									EndIf
									dbSkip()
									nContDiff := ( &(aARQHist[5]) - nContAnt - &(aARQHist[4]) ) //Acumulado Atual - Acumulado Anterior - Posicao do Contador Atual da Virada
								EndIf
							EndIf
						EndIf
					EndIf

					RestArea(aAreaSSTP)
					RestArea(aAreaSave)

					If nContDiff > 0
						nACUMSTP  := (nACUMATU + nContDiff)
						lAcumulou := .T.
					EndIf
				EndIf
			EndIf
			
			If lAcumulou
				If !lEntrada
					nACUMSTP += If(cTipLanAtu == "Q", 0, &(aARQHist[4]))
				EndIf
			Else 
				nDIFA := &(aARQHist[4]) - nPOSCUTI
				nACUMSTP := nACUMSTP + nDIFA
				If nDIFA < 0
					nACUMSTP := If(nACUMEX <> NIL,&(aARQHist[5]) - nACUMEX,&(aARQHist[5])+nVDIF)
				EndIf
			EndIf

			cFILARQ  := &(aARQHist[2])
			cCODBEM  := &(aARQHist[3])
			dDATAMOV := &(aARQHist[6])
			cHORAENT := &(aARQHist[9])
			cTPLAN   := &(aARQHist[10])

			dbSelectArea("STZ")
			dbSetOrder(2) //TZ_FILIAL+TZ_CODBEM+DTOS(TZ_DATAMOV)+TZ_TIPOMOV+TZ_HORAENT
			If dbSeek(cFILARQ + cCODBEM + DToS(dDATAMOV) + "E" + cHORAENT,.T.);
					.And. !(cTIPOLAN $ "QV")
				nACUMSTP := nACUMANT
			ElseIf dbSeek(cFILARQ + cCODBEM + DToS(dDATAMOV) + "S" + cHORAENT,.T.);
					.And. !(cTIPOLAN $ "QV")
				nACUMSTP := nACUMANT
			EndIf

			nVARDSTP := NGVARIADT(&(aARQHist[3]),dDatLanAtu,nTIPOC,nACUMSTP,.T.,.F.,cFilHist)
			dbSelectArea(aARQHist[1])
			Dbgoto(nREGSTP)
			nACUMANT := &(aARQHist[5])
			nPOSCONSTP := &(aARQHist[4])

			// quando parametro LANEX est· habilitado, altera todos os registros "C"
			// conforme lanÁamento anterior tipo A Q ou V
			If cTPLAN == "C" .And. nTIPOC == 1 .And. cLanex == "A"
				nPOSCONSTP := NGGetCont( cVBem, dDATAMOV, cHORAENT, "A", .T., &(aARQHist[2]) ) // Contador
				nACUMSTP   := NGGetCont( cVBem, dDATAMOV, cHORAENT, "A", .F., &(aARQHist[2]) ) // Acumulado
			EndIf

			RecLock(aARQHist[1],.F.)

			&(aARQHist[8]) := nVARDSTP
			&(aARQHist[5]) := nACUMSTP
			&(aARQHist[7]) := If(lVIRA,&(aARQHist[7])+1,&(aARQHist[7]))
			&(aARQHist[4]) := nPOSCONSTP

			MsUnLock()

			dDATALEI := dDatLanAtu
			nPOSCUTI := &(aARQHist[4])
			nACUMATU := &(aARQHist[5])
			nVIRADTI := &(aARQHist[7])

			NGPACONT(&(aARQHist[3]), &(aARQHist[6]), &(aARQHist[9]), &(aARQHist[4]), &(aARQHist[5]), nTIPOC ) //Atualiza tabelas relacionadas

			dbSelectArea(aARQHist[1])
			dbSkip()
		End

		If !IST9ATU
			lPassaAbas := IF((FunName()=="MNTA655" .Or. FunName() == "MNTA656") .And. ValType(nPOSCONSTP) != 'N',.T.,.F.)
			If lULTIMOR
				NGATUCONT(cVBEM,dDLEIT,IF(lPassaAbas,nPOSCONSTP,nPOSCSTP),nACUMSTP,nVARDSTP,nTIPOC,lVIRA,.T.,cFilCont)
			Else
				If nVARDSTP > 0
					NGATUCONT(cVBEM,dDLEIT,IF(lPassaAbas,nPOSCONSTP,nVPOSC),nACUMSTP,nVARDSTP,nTIPOC,lVIRA,.T.,cFilCont)
				Endif
			Endif
		Else
			dbSelectArea(aARQCont[1])
			dbSetOrder(1)
			If dbSeek(cFilCont+cVBEM)
				RecLock(aARQCont[1],.F.)
				&(aARQCont[2]) := dDATALEI
				&(aARQCont[3]) := nPOSCUTI
				&(aARQCont[4]) := nACUMSTP
				&(aARQCont[5]) := nVARDSTP
				&(aARQCont[6]) := nVIRADTI
				MsUnLock(aARQCont[1])
			Endif
		Endif

		//---------------------
		// Atualiza TQS
		//---------------------
		If lUpdTQS
			MNT877TQS( cVBem )
		EndIf

	Next nX

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} NGGetCont
Retorna a posiÁ„o do contador ou contador acumulado anterior do tipo
configurado no par‚metro LANEX, Q, V ou I.

@param cCodBem, string, CÛdigo do bem
@param dData, date, Data do ˙ltimo registro a ser procurado
@param cHora, Hora do ˙ltimo registro a ser procurado
@param [cLanex], string, conte˙do do par‚metro NGLANEX
@param [lCont], boolean, .T. para retornar a posiÁ„o do contador, .F. para acumulado
@param [cFilStp], string, campo filial da tabela stp
@param [cFather], string, cÛdigo do pai (utilizado para pneus)
@author Hamilton Soldati
@author Maria Elisandra de Paula
@since 07/03/2019
@version P11
@return nContAnt
/*/
//---------------------------------------------------------------------
Function NGGetCont( cCodBem, dData, cHora, cLanex, lCont, cFilStp, cFather )

	Local nContAnt 	:= 0
	Local cAliasQry	:= GetNextAlias()
	Local cAliasSTZ	:= GetNextAlias()
	Local dDataLei	:= DtoS(dData)
	Local cCondSql	:= "%%"
	Local lLanex    := .F.

	Default lCont   := .T.
	Default cFilStp := xFilial("STP")
	Default cLanex  := ""
	Default cFather := ""

	// Verifica se foi enviado o pai da estrutura, caso n„o, tenta busca-lo.
	If Empty(cFather)

		/*/ Verifica se o bem estava em uma estrutura, caso estiver, verifica qual o controle e seu pai.
		Verifica tanto a data de entrada como de saida da entrutura
		/*/
		BeginSql Alias cAliasSTZ
			SELECT TZ_BEMPAI, TZ_TEMCONT					
			FROM %Table:STZ%
				WHERE TZ_CODBEM = %exp:cCodBem% AND %NotDel% AND TZ_FILIAL = %xFilial:STZ% AND TZ_TEMCONT <> 'N'
				AND ( 
					// Quando o pneu j· saiu da estrutura, onde a dat aem quest„o precisa estar entre a entrega e saida
						(	%exp:dDataLei+cHora%  BETWEEN TZ_DATAMOV || TZ_HORAENT AND TZ_DATASAI || TZ_HORASAI AND TZ_TIPOMOV = 'S') 
					OR 
					// Quando a data em quest„o È maior que a entrada do pneu ele ainda n„o saiu da estrutura.
						(	%exp:dDataLei+cHora%  >= TZ_DATAMOV || TZ_HORAENT AND TZ_TIPOMOV  = 'E')
					)
		EndSql

		If (cAliasSTZ)->( !EoF() )

			cFather := cCodBem

			If (cAliasSTZ)->TZ_TEMCONT == "P"

				// Bem controlado pelo Pai da estrutura e precisa busca em toda a arvore
				cFather := NGBEMPAI(cCodBem, dData, cHora)
				
			ElseIf (cAliasSTZ)->TZ_TEMCONT == "I"

				// Bem controlado pelo Pai Imediato, ou seja, o mesmo informado na TZ_BEMPAI
				cFather := (cAliasSTZ)->TZ_BEMPAI
				
			EndIf

		EndIf
		(cAliasSTZ)->(dbCloseArea())
	EndIf

	If Empty( cLanex )
		cLanex := NGUSELANEX( cCodBem, .F., dData, cHora, cFather )
	EndIf

	lLanex := cLanex == "A"

	If lLanex
		cCondSql := "%AND TP_TIPOLAN IN ('A', 'I', 'Q', 'V' )%"
	EndIf

	If Empty(cFather)
		cFather := cCodBem
	ElseIf cFather <> cCodBem .And. !lCont
		cFather := cCodBem
	EndIf

	/*/ Busca a posiÁ„o ou acumulado do contador com data e hora menor a enviada no paramentro.
	Se o bem tiver contador proprio, a busca ser· feita por seu cÛdigo.
	Se o bem for controlado pelo pai da estrutura ou pai imediato e o mesmo estiver na estrutura, a posiÁ„o do
	contador ser· o bem pai e o acumulado dele mesmo.
	Se o bem for controlado pelo pai da estrutura ou pai imediato e o mesmo N¬O estiver na estrutura, a posiÁ„o do
	contador e o acumulado dele mesmo.
	Caso contr·rio
	/*/
	BeginSql Alias cAliasQry

		SELECT STP.TP_POSCONT POSCONT, STP.TP_ACUMCON ACUMCON
		FROM %Table:STP% STP
		WHERE STP.TP_CODBEM = %exp:cFather%
			AND STP.TP_FILIAL = %exp:cFilStp%
			AND STP.TP_DTLEITU || STP.TP_HORA <= %exp:dDataLei+cHora%			
			AND %notDel%
			%exp:cCondSql%
		ORDER BY STP.TP_DTLEITU || STP.TP_HORA DESC

	EndSql

	If !(cAliasQry)->(Eof()) // Se encontrou movimentaÁ„o com data anterior
		If lCont // Retorna a posiÁ„o do contador
			nContAnt := (cAliasQry)->POSCONT
		Else // Retorna o acumulado
			nContAnt := (cAliasQry)->ACUMCON
		EndIf
	EndIf

	(cAliasQry)->(dbCloseArea())

Return nContAnt

//-------------------------------------------------------------------
/*/{Protheus.doc} NGCHKHISTO
Valida o lanÁamento no histÛrico.

@author  Inacio Luiz Kolling
@since   11/03/2003
@version p12

@param cVBEM, CÛdigo do bem, caractere
@param dVDATA, Data da leitura, date
@param nVPOSCONT, Valor do contador, numÈrico
@param cHORA, Hora da leitura, caractere
@param nTIPOC, Tipo do contador ( 1/2 ), numÈrico
@param nVITEM, Item do GetDados, numÈrico
@param lGETVAR, Indica se a saÌda de erro na tela, lÛgico
@param cFilTroc, Filial de troca de acesso, caractere
@param cCombus, CÛdigo do CombustÌvel, caractere

@return LÛgico ou Array, se lGETVAR = .T. retorna LÛgico se n„o retorna aVETOR[1] - lÛgico, aVETOR[2] - mensagem de erro ou nulo
/*/
//-------------------------------------------------------------------
Function NGCHKHISTO( cVBEM, dVDATA, nVPOSCONT, cHORA, nTIPOC, nVITEM, lGETVAR, cFilTroc, cCombus, lAskAuto )

	Local nCONTINI  := 0
	Local nCONTFIM  := 0
	Local dDATAINI
	Local dDATAFIM
	Local aVETOR    := {}
	Local aVETRE    := {}
	Local aRetPE    := {}
	Local vARQHI    := {}
	Local aAreaHist := {}
	Local lRETHIS   := .T.
	Local lRETORN   := .T.
	Local lPROBPA   := .F.
	Local lCanib    := .F. //Indica se o status do bem esta como canibalismo
	Local cMENOBR   := STR0003 // " e obrigatorio"
	Local cMENSA    := Space(1)
	Local cMENOP1   := STR0004 + IIf( nVITEM <> Nil, STR0005, '.' ) + CRLF //1 - Alterar o contador e/ou a data ### do item
	Local cMENOP2   := STR0006 + IIf( nVITEM = Nil, STR0007, STR0008 ) + CRLF //2 - ### Cancelar a operacao. ### Deletar o item que contem o problema.
	Local cMENAU    := IIf( nVITEM <> NIL, STR0009 + Str( nVITEM, 3 ), ' ' ) // do item
	Local cMENSP    := Space(1)
	Local cTIPOC    := Space(1)
	Local cMENSO    := STR0010 + CRLF + cMENOP1 + cMENOP2 +STR0011 // "3 - Selecionar a opcao VIRADA do INFORMA CONTADOR (menu)."
	Local cFilSt9   := NGTROCAFILI( 'ST9', cFilTroc )
	Local cFilTpe   := NGTROCAFILI( 'TPE', cFilTroc )
	Local cFilHis   := ''

	lGETVAR := If(lGETVAR = NIL,.T.,lGETVAR)

	Default lAskAuto := !IsInCallStack("MNTA876")

	nTIPOC  := If(Empty(nTIPOC) .Or. nTIPOC = NIL,1,nTIPOC)
	cTIPOC  := If(nTIPOC = 1,' 1 ',' 2 ')
	vARQHI  := IIf( nTIPOC == 1, { 'STP', 'STP->TP_FILIAL' , 'STP->TP_DTLEITU', 'STP->TP_HORA' , 'STP->TP_POSCONT',;
									'STP->TP_CODBEM' , 'STP->TP_TIPOLAN' },;
	 							 { 'TPP', 'TPP->TPP_FILIAL', 'TPP->TPP_DTLEIT', 'TPP->TPP_HORA', 'TPP->TPP_POSCON',;
								 	'TPP->TPP_CODBEM', 'TPP->TPP_TIPOLA' } )

	If FunName() != "MNTA656"
		
		If lGetVar
		
			If !NGAUTONOMIA(cVBem,dVData,cHora,nVPosCont,lGetVar,cCombus,nTIPOC,cFilSt9)
				Return .F.
			EndIf
		
		Else
			
			vVetAuto := NGAUTONOMIA( cVBem, dVData, cHora, nVPosCont, lGetVar, cCombus, nTIPOC, cFilSt9,  lAskAuto )

			If !vVetAuto[1]
				Return vVetAuto
			EndIf

		EndIf

	EndIf

	// VALIDA OS PAR¬METROS
	// 1 BEM
	If Empty(cVBEM) .Or. cVBEM = NIL
		aVETOR := {.F.,STR0012+cMENOBR} // "Codigo do bem"
		lPROBPA := .T.
	Else

		dbSelectArea("ST9")
		Dbsetorder(1)
		If !dbSeek(cFilSt9+cVBEM)
			aVETOR := {.F.,STR0013} // "Bem nao cadastrado"
			lPROBPA := .T.
		Else
			If FieldPos('T9_STATUS') > 0
				If !Empty(ST9->T9_STATUS) .And. AllTrim(ST9->T9_STATUS) == GetNewPar("MV_NGSTACA"," ")
					lCanib := .T.
				EndIf
			EndIf
		Endif
		If nTIPOC = 1
			If st9->t9_temcont = 'N'
				aVETOR := {.F.,STR0014} // "Bem nao e controlado por contador"
				lPROBPA := .T.
			Endif
		Else
			dbSelectArea("TPE")
			Dbsetorder(1)
			If !dbSeek(cFilTpe+cVBEM)
				aVETOR := {.F.,STR0013+" "+STR0015+" 2 "} // "Bem nao cadastrado"###"Contador"
				lPROBPA := .T.
			Endif
		Endif
	Endif

	// 2 DATA DE LEITURA
	If !lPROBPA
		If Empty(dVDATA) .Or. dVDATA = NIL
			aVETOR := {.F.,STR0016+cMENOBR} // "Data da leitura"
			lPROBPA := .T.
		Endif
	Endif

	// 3 CONTADOR
	If !lPROBPA
		If Empty(nVPOSCONT) .Or. nVPOSCONT = NIL
			aVETOR := {.F.,STR0015+cMENOBR} // "Contador"
			lPROBPA := .T.
		Endif
	Endif

	// 4 HORA
	If !lPROBPA
		If Empty(cHORA) .Or. cHORA = NIL
			aVETOR := {.F.,STR0017+cMENOBR} // "Hora"
			lPROBPA := .T.
		Endif
	Endif

	If !lPROBPA
		cMENSP  := STR0018+cTIPOC+STR0019+cMENAU+CRLF+CRLF; // "Problema de contador"###"no lancamento "
		+STR0020+Alltrim(cVBEM)+CRLF; // "Bem..................: "
		+STR0021+dtoc(dVDATA)+CRLF; // "Data..................: "
		+STR0022+Str(nVPOSCONT,9)+CRLF; // "Contador...........: "
		+STR0023+cHORA+CRLF+CRLF // "Hora Informada.: "

		Store 0 To nCONTINI,nCONTFIM
		Store Ctod('  /  /  ') To dDATAINI,dDATAFIM

		cFilHis := NGTROCAFILI(vARQHI[1],cFilTroc)
		// Verifica se o lancamento do contador e posterior ao tipo de lancametno I (Inclusao)
		aVETOR := NGCHKCINC(cVBEM,dVDATA,nVPOSCONT,cHORA,nTIPOC,lGETVAR,cFilHis)

		If aVETOR[1] .And. !NGBlCont( cVBEM, .F. )  // Se controla apenas por abastecimento

			cMENSA := fVldLanex(cFilHis, cVBEM, dVDATA, cHORA, nVPOSCONT, nTIPOC )
			If !Empty(cMENSA)
				lRETHIS := .F.
				aVETOR := {lRETHIS,cMENSP + cMENSA + cMENSO}				
			EndIf
		
		ElseIf aVETOR[1]
			
			dbSelectArea(vARQHI[1])
			Dbsetorder(5)
			dbSeek(cFilHis+cVBEM+DTOS(dVDATA)+cHORA,.T.)

			If !Eof()
				If &(vARQHI[2]) == cFilHis .And. &(vARQHI[6]) == cVBEM;
						.And. &(vARQHI[3]) = dVDATA .And. &(vARQHI[4]) = cHORA

					cMENSA := cMENSP +STR0024+cTIPOC+STR0025+CRLF+CRLF // ### //"Ja existe um lancamento para o contador"###"com as caracteristicas:"
					cMENSA := cMENSA +STR0026+Dtoc(&(vARQHI[3]))+CRLF // "Data Lancamento..: "
					cMENSA := cMENSA +STR0027+str(&(vARQHI[5]),9)+CRLF // "Contador................: "
					cMENSA := cMENSA +STR0028+&(vARQHI[4])+CRLF+CRLF // "Hora Lancamento..: "
					cMENSA := cMENSA +cMENSO
					lRETHIS   := .F.
					aVETOR := {lRETHIS,cMENSA}
				Else
					If &(vARQHI[2]) <> cFilHis
						Dbskip(-1)
					Endif
					If &(vARQHI[2]) == cFilHis .And. &(vARQHI[6]) == cVBEM;
							.And. &(vARQHI[3]) = dVDATA

						If nVPOSCONT < &(vARQHI[5])
							If &(vARQHI[7]) <> "I"
								dbSkip(-1) // Se for Menor que o Atual, posiciona no registro Anterior
							EndIf
							If !Bof()
								If &(vARQHI[2]) == cFilHis .And. &(vARQHI[6]) == cVBEM
									// Verifica se È menor que o lanÁamento Anterior
									If nVPOSCONT < &(vARQHI[5])
										cMENSA := cMENSP +STR0029+cTIPOC+STR0030+CRLF // ### //"O Contador"###"informado e menor do que o do lancamento do historico."
										cMENSA := cMENSA +STR0026+Dtoc(&(vARQHI[3]))+CRLF // "Data Lancamento..: "
										cMENSA := cMENSA +STR0027+str(&(vARQHI[5]),9)+CRLF // "Contador................: "
										cMENSA := cMENSA +STR0028+&(vARQHI[4])+CRLF+CRLF // "Hora Lancamento..: "
										cMENSA := cMENSA +cMENSO
										lRETHIS   := .F.
									Else // Se for Maior ou Igual ao Anterior
										aAreaHist := GetArea()
										dbSkip()
										// Se n„o houver mais lanÁamentos para o mesmo Bem, ent„o este È o ˙ltimo e est· Ok
										// Caso contr·rio, verifica se est· Ok com o registro Posterior
										If &(vARQHI[2]) == cFilHis .And. &(vARQHI[6]) == cVBEM
											// Se a HORA Atual for MAIOR que a do Posterior, ent„o o CONTADOR deve ser MAIOR
											If cHORA > &(vARQHI[4]) .And. nVPOSCONT < &(vARQHI[5])
												cMENSA := cMENSP +STR0029+cTIPOC+STR0030+CRLF //### //"O Contador"###"informado e menor do que o do lancamento do historico."
												cMENSA := cMENSA +STR0026+Dtoc(&(vARQHI[3]))+CRLF // "Data Lancamento..: "
												cMENSA := cMENSA +STR0027+str(&(vARQHI[5]),9)+CRLF // "Contador................: "
												cMENSA := cMENSA +STR0028+&(vARQHI[4])+CRLF+CRLF // "Hora Lancamento..: "
												cMENSA := cMENSA +cMENSO
												lRETHIS := .F.
												// Se a HORA Atual for MENOR que a do Posterior, ent„o o CONTADOR deve ser MENOR
											ElseIf cHORA < &(vARQHI[4]) .And. nVPOSCONT > &(vARQHI[5])
												cMENSA := cMENSP +STR0029+cTIPOC+STR0031+CRLF //### //"O Contador"###"informado e maior do que o do lancamento do historico."
												cMENSA := cMENSA +STR0026+Dtoc(&(vARQHI[3]))+CRLF // "Data Lancamento..: "
												cMENSA := cMENSA +STR0027+str(&(vARQHI[5]),9)+CRLF // "Contador................: "
												cMENSA := cMENSA +STR0028+&(vARQHI[4])+CRLF+CRLF // "Hora Lancamento..: "
												cMENSA := cMENSA +cMENSO
												lRETHIS := .F.
												// Se a HORA Atual IGUAL a do Posterior, ent„o o CONTADOR deve ser IGUAL
											ElseIf cHORA == &(vARQHI[4]) .And. nVPOSCONT <> &(vARQHI[5])
												cMENSA := cMENSP +STR0024+cTIPOC+STR0025+CRLF+CRLF //### //"Ja existe um lancamento para o contador"###"com as caracteristicas:"
												cMENSA := cMENSA +STR0026+Dtoc(&(vARQHI[3]))+CRLF // "Data Lancamento..: "
												cMENSA := cMENSA +STR0027+str(&(vARQHI[5]),9)+CRLF // "Contador................: "
												cMENSA := cMENSA +STR0028+&(vARQHI[4])+CRLF+CRLF // "Hora Lancamento..: "
												cMENSA := cMENSA +cMENSO
												lRETHIS := .F.
											EndIf
										EndIf
										RestArea(aAreaHist)
									EndIf
									aVETOR := {lRETHIS,cMENSA}
								Else
									aVETOR := {lRETHIS,cMENSA}
								Endif
							Else
								aVETOR := {lRETHIS,cMENSA}
							Endif
						Else

							If &(vARQHI[2]) == cFilHis .And. &(vARQHI[6]) == cVBEM;
									.And. nVPOSCONT > &(vARQHI[5]) .And. &(vARQHI[4]) > cHORA  .And. !(&(vARQHI[7]) $ "QV")
								cTpLanc := ' '
								If ExistBlock("NGUTIL4T")
									cTpLanc := ExecBlock("NGUTIL4T",.F.,.F.)
								Endif
								If Empty(cTpLanc) .Or. &(vARQHI[7]) == cTpLanc
									cMENSA := cMENSP +STR0029+cTIPOC+STR0031+CRLF //### //"O Contador"###"informado e maior do que o do lancamento do historico."
									cMENSA := cMENSA +STR0026+Dtoc(&(vARQHI[3]))+CRLF // "Data Lancamento..: "
									cMENSA := cMENSA +STR0027+str(&(vARQHI[5]),9)+CRLF // "Contador................: "
									cMENSA := cMENSA +STR0028+&(vARQHI[4])+CRLF+CRLF // "Hora Lancamento..: "
									cMENSA := cMENSA +cMENSO
									lRETHIS   := .F.
								Endif
							Else
								dbSkip(-1)
								If !Bof()
									If &(vARQHI[2]) == cFilHis .And. &(vARQHI[6]) == cVBEM
										nCONTINI := &(vARQHI[5])
										dDATAINI := &(vARQHI[3])
									Endif
								Endif
								dbSkip()
								While !Eof() .And. &(vARQHI[2]) == cFilHis .And. &(vARQHI[6]) == cVBEM;
										.And. &(vARQHI[3]) = dVDATA
									dbSkip()
								End

								If !Eof() .And. &(vARQHI[2]) == cFilHis .And. &(vARQHI[6]) == cVBEM
									nCONTFIM := &(vARQHI[5])
									dDATAFIM := &(vARQHI[3])
								Else
									If !Eof() .And. &(vARQHI[2]) == cFilHis .And. &(vARQHI[6]) == cVBEM
										// QUAL OS VALORES V¡LIDOS ????
										nCONTFIM := &(vARQHI[5])
										dDATAFIM := &(vARQHI[3])
									Endif
								Endif

								lPROBL := .F.
								If nCONTINI > 0 .Or. nCONTFIM > 0
									If nVPOSCONT < nCONTINI
										cMENAX := STR0032 // " e menor do o primeiro lancamento "
										lPROBL := .T.
									Else
										If nCONTFIM > nCONTINI
											If nVPOSCONT > nCONTINI .And. nVPOSCONT > nCONTFIM
												cMENAX := STR0033 // " devera ser entre o intervalo dos lancamentos "
												lPROBL := .T.
											Endif
										Endif
									Endif

									If lPROBL
										If nCONTINI > 0
											cMENAX := STR0033 // " devera ser entre o intervalo dos lancamentos "
											cMENSK := STR0034+Dtoc(dDATAINI)+CRLF // //"Data 1 Lancamento..: "
											cMENSK := cMENSK +STR0035+str(nCONTINI,9)+CRLF+CRLF // //"Contador..................: "
											cMENSK := cMENSK +STR0036+Dtoc(dDATAFIM)+CRLF // //"Data 2 Lancamento..: "
											cMENSK := cMENSK +STR0035+str(nCONTFIM,9)+CRLF+CRLF // //"Contador..................: "
											cMENSA := cMENSA +STR0023+cHORA+CRLF+CRLF // //"Hora Informada.: "
										Else
											cMENAX := STR0037 // " e maior do que o do lancamento "
											cMENSK := STR0026+Dtoc(dDATAFIM)+CRLF // "Data Lancamento..: "
											cMENSK := cMENSK +STR0027+str(nCONTFIM,9)+CRLF+CRLF // "Contador................: "
											cMENSA := cMENSA +STR0028+&(vARQHI[4])+CRLF+CRLF // "Hora Lancamento..: "
										Endif
										cMENSA := cMENSP +STR0029+cTIPOC+STR0038+cMENAX+STR0039+CRLF //###### //"O Contador"###"informado "###" do historico."
										cMENSA := cMENSA +cMENSK
										cMENSA := cMENSA +cMENSO
										lRETHIS   := .F.
									Endif
								Endif
							Endif
							aVETOR := {lRETHIS,cMENSA}
						Endif
					Else

						// BEM !=
						If &(vARQHI[2]) == cFilHis .And. &(vARQHI[6]) <> cVBEM
							dbSkip(-1)
						Endif

						// BEM = E DATA !=

						cTpLanc := ' '
						If ExistBlock("NGUTIL4T")
							cTpLanc := ExecBlock("NGUTIL4T",.F.,.F.)
						Endif
						If AllTrim(&(vARQHI[2])) == AllTrim(cFilHis) .And. AllTrim(&(vARQHI[6])) == AllTrim(cVBEM) .And. (Empty(cTpLanc) .Or. &(vARQHI[7]) == cTpLanc)
							If &(vARQHI[3]) <> dVDATA

								If dVDATA > &(vARQHI[3]) .And. nVPOSCONT >= &(vARQHI[5])
									// .And. cHORA >= &(vARQHI[4])
								Else
									If dVDATA > &(vARQHI[3]) .And. nVPOSCONT < &(vARQHI[5])
										cMENSA := cMENSP +STR0029+cTIPOC+STR0030+CRLF //### //"O Contador"###"informado e menor do que o do lancamento do historico."
										cMENSA := cMENSA +STR0026+Dtoc(&(vARQHI[3]))+CRLF // "Data Lancamento..: "
										cMENSA := cMENSA +STR0027+str(&(vARQHI[5]),9)+CRLF // "Contador................: "
										cMENSA := cMENSA +STR0028+&(vARQHI[4])+CRLF+CRLF // "Hora Lancamento..: "
										cMENSA := cMENSA +cMENSO
										lRETHIS   := .F.
									Else

										lPROBLEM := .F.
										nCONTFIM := &(vARQHI[5])
										dDATAFIM := &(vARQHI[3])
										cHORAFIM := &(vARQHI[4])
										nCONTINI := 0
										dDATAINI := Ctod('  /  /  ')
										cHORAINI := ' :  '

										dbSkip(-1)
										If !NGBlCont( cVBEM, .F. ) // Se controla apenas por abastecimento
											While !Bof()// valida com o registro de Abastecimento, Quebra, Virada ou Inclus„o anterior
												If !(&(vARQHI[7]) $ "AQVI")
													Dbskip(-1)
												Else
													Exit
												EndIf
											EndDo
										EndIf

										//dbSkip(-1)
										If !Bof()
											If &(vARQHI[2]) == cFilHis .And. &(vARQHI[6]) == cVBEM
												nCONTINI := &(vARQHI[5])
												dDATAINI := &(vARQHI[3])
												cHORAINI := &(vARQHI[4])
											Endif
										Endif
										If !Empty(nCONTINI)
											If dDATAINI = dDATAFIM
												If cHORA > cHORAINI .And. cHORA < cHORAFIM .And.;
														nVPOSCONT >= nCONTINI .And. nVPOSCONT <= nCONTFIM
												Else
													lPROBLEM := .T.
												Endif
											Else
												lTESTADO := .F.
												If !Empty(nCONTFIM)
													If nCONTFIM < nCONTINI
														lTESTADO := .T.

														If nVPOSCONT >= nCONTINI .And. nCONTFIM <= nVPOSCONT
														Else
															lPROBLEM := .T.
														Endif
													Else
														If nCONTFIM = nCONTINI
															If nVPOSCONT <> nCONTINI
																lTESTADO := .T.
																lPROBLEM := .T.
															Endif
														Endif
													Endif
												Endif
												If !lTESTADO
													If nVPOSCONT >= nCONTINI .And. nVPOSCONT <= nCONTFIM
													Else
														lPROBLEM := .T.
													Endif
												Endif
											Endif

											If lPROBLEM
												cMENSA := cMENSP +STR0029+cTIPOC+STR0040+CRLF //### //"O Contador"###"informado devera ser entre o intervalo dos lancamentos do historico."
												cMENSA := cMENSA +STR0034+Dtoc(dDATAINI)+CRLF // "Data 1 Lancamento..: "
												cMENSA := cMENSA +STR0041+str(nCONTINI,9)+CRLF // "Contador...................: "
												cMENSA := cMENSA +STR0042+cHORAINI+CRLF+CRLF // "Hora 1 Lancamento..: "
												cMENSA := cMENSA +STR0036+Dtoc(dDATAFIM)+CRLF // "Data 2 Lancamento..: "
												cMENSA := cMENSA +STR0041+str(nCONTFIM,9)+CRLF // "Contador...................: "
												cMENSA := cMENSA +STR0043+cHORAFIM+CRLF+CRLF // "Hora 2 Lancamento..: "
												cMENSA := cMENSA +cMENSO
												lRETHIS   := .F.
											Endif
										Else
											//  If nVPOSCONT <= &(vARQHI[5])
											If nVPOSCONT <= nCONTFIM
											Else
												cMENSA := cMENSP +STR0029+cTIPOC+STR0031+CRLF //### //"O Contador"###"informado e maior do que o do lancamento do historico."
												cMENSA := cMENSA +STR0026+Dtoc(dDATAFIM)+CRLF // "Data Lancamento..: "
												cMENSA := cMENSA +STR0027+str(nCONTFIM,9)+CRLF // "Contador................: "
												cMENSA := cMENSA +STR0028+cHORAFIM+CRLF+CRLF // "Hora Lancamento..: "
												cMENSA := cMENSA +cMENSO
												lRETHIS   := .F.
											Endif
										Endif
									Endif
								Endif
							Else
								If nVPOSCONT >= &(vARQHI[5]) .And. cHORA > &(vARQHI[4])
								Else
									//  If cHORA < &(vARQHI[4])

									cMENSA := cMENSP +STR0029+cTIPOC+STR0030+CRLF //### //"O Contador"###"informado e menor do que o do lancamento do historico."
									cMENSA := cMENSA +STR0026+Dtoc(&(vARQHI[3]))+CRLF // "Data Lancamento..: "
									cMENSA := cMENSA +STR0027+str(&(vARQHI[5]),9)+CRLF // "Contador................: "
									cMENSA := cMENSA +STR0028+&(vARQHI[4])+CRLF+CRLF // "Hora Lancamento..: "
									cMENSA := cMENSA +cMENSO
									lRETHIS   := .F.
								Endif
							Endif
						Endif

						aVETOR := {lRETHIS,cMENSA}
					Endif
				Endif
			Else
				dbSkip(-1)
				If Alltrim(&(vARQHI[2])) == Alltrim(cFilHis) .And. Alltrim(&(vARQHI[6])) == Alltrim(cVBEM)
					lPROBLEM := .F.
					If &(vARQHI[3]) <> dVDATA
						If nVPOSCONT >= &(vARQHI[5])
						Else
							lPROBLEM := .T.
						Endif
					Else
						If cHORA > &(vARQHI[4]) .And. nVPOSCONT >= &(vARQHI[5])
						Else
							lPROBLEM := .T.
						Endif
					Endif
					If lPROBLEM
						cMENSA := cMENSP +STR0029+cTIPOC+STR0030+CRLF //### //"O Contador"###"informado e menor do que o do lancamento do historico."
						cMENSA := cMENSA +STR0026+Dtoc(&(vARQHI[3]))+CRLF // "Data Lancamento..: "
						cMENSA := cMENSA +STR0027+str(&(vARQHI[5]),9)+CRLF // "Contador................: "
						cMENSA := cMENSA +STR0028+&(vARQHI[4])+CRLF+CRLF // "Hora Lancamento..: "
						cMENSA := cMENSA +cMENSO
						lRETHIS   := .F.
					Endif
				Endif
				aVETOR := {lRETHIS,cMENSA}
			Endif
		Endif
	EndIf

	aVETRE := aVETOR

	// PE para inibir valores de contador na mensagem de alerta de inconsistencia
	If ExistBlock("NGUTIL4D")
		aVETRE[2] := ExecBlock("NGUTIL4D", .F., .F., {aVETRE[2]})
	EndIf

	// PE para incluir uma nova validaÁ„o na checagem do historico de contador.
	If aVetRe[1] .And. ExistBlock( 'NGUTIL4A' )
		aRetPE := ExecBlock( 'NGUTIL4A', .F., .F., { cVBem, dVData, nVPosCont, cHora, nTipoC, lGetVar } )

		If ValType( aRetPE ) == 'A'
			aVetRe := aClone( aRetPE )
		EndIf

	EndIf

	If lGETVAR

		If lCanib
			If nVPOSCONT > &(vARQHI[5]) .And. (DtoS(dVDATA)+cHORA) > (DtoS(&(vARQHI[3]))+&(vARQHI[4]))
				MsgInfo(STR0127+CRLF+; // "Procedimento n„o permitido para Bens com status de Canibalismo, pois o mesmo n„o poder· receber reporte de contador."
				STR0128+Str(&(vARQHI[5]),9),STR0044) // "NAO CONFORMIDADE"	//"Para realizar esse procedimento È necess·rio informar o contador do ˙ltimo lanÁamento :"
				Return .F.
			EndIf
		EndIf

		If !aVETRE[1]
			MsgInfo(aVETRE[2],STR0044) // "NAO CONFORMIDADE"
			lRETORN := .F.
		EndIf

		Return lRETORN

	EndIf

Return IIf( lGetVar, aVetRe[1], aVetRe )

/*/
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
	±±≥FunáÖo    ≥NGCONTRET ≥ Autor ≥In†cio Luiz Kolling    ≥ Data ≥11/03/2003≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥DescriáÖo ≥Valida os compos de retorno de contador (1/2)               ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥Parametros≥dVDAT1    - Data da leitura 1                  - Obrigat¢rio≥±±
	±±≥          ≥nVPOS1    - Valor do contador 1                - Obrigat¢rio≥±±
	±±≥          ≥cHORA1    - Hora do 1 contador                 - Obrigat¢rio≥±±
	±±≥          ≥lTEMC1    - Tem contador 1                     - Obrigat¢rio≥±±
	±±≥          ≥dVDAT2    - Data da leitura 2                  - Obrigat¢rio≥±±
	±±≥          ≥nVPOS2    - Valor do contador 2                - Obrigat¢rio≥±±
	±±≥          ≥cHORA2    - Hora do 2 contador                 - Obrigat¢rio≥±±
	±±≥          ≥lTEMC2    - Tem contador 2                     - Obrigat¢rio≥±±
	±±≥          ≥lMENSA    - Sa°da da mensgem                   - Obrigat¢rio≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥Retorna   ≥ SE lMENSA = .T.                                            ≥±±
	±±≥          ≥    .T. /ou .F.                                             ≥±±
	±±≥          ≥ SENAO                                                      ≥±±
	±±≥          ≥    aVETORC    Onde:                                        ≥±±
	±±≥          ≥    SE  aVETORC[1] = .T.                                    ≥±±
	±±≥          ≥        Sem problema                                        ≥±±
	±±≥          ≥        aVETORC[2] = Conteudo vazio                         ≥±±
	±±≥          ≥    SENAO                                                   ≥±±
	±±≥          ≥       Problema                                             ≥±±
	±±≥          ≥       aVETORC[2] = Mensagem do problema                    ≥±±
	±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function NGCONTRET(dVDAT1,nVPOS1,cHORA1,lTEMC1,dVDAT2,nVPOS2,cHORA2,lTEMC2,;
		lMENSA)
	Local aVETORC := {}
	Local cMENSFI := Space(1)
	Local cMENSP1 := STR0045 //"Quanto for informado o contador "
	Local cMENSP2 := STR0046+CRLF; //"Os campos de Data da leitura ou Dt. Original"
	+STR0047+CRLF; //"Ou Dt.Man.Re.F. e Hora da leitura ou Hora Cont."
	+STR0048 //"Do contador "
	Local cMENSP3 := STR0049 //" sao obrigatorios"
	Local lRETCON := .T.

	If lTEMC1
		If nVPOS1 > 0
			If !Empty(dVDAT1) .And. Alltrim(cHORA1) <> ':'
			Else
				cMENSFI := '1'
			Endif
		Endif

		If Empty(cMENSFI)
			If lTEMC2
				If nVPOS2 > 0
					If !Empty(dVDAT2) .And. Alltrim(cHORA2) <> ':'
					Else
						cMENSFI := '2'
					Endif
				Endif
			Endif
		Endif
	Endif

	cMENSFI := If (!Empty(cMENSFI),cMENSP1+cMENSFI+CRLF+cMENSP2+cMENSFI+cMENSP3,cMENSFI)

	aVETORC := {lRETCON,cMENSFI}

	If lMENSA
		If !Empty(cMENSFI)
			MsgInfo(cMENSFI,STR0044) //"NAO CONFORMIDADE"
			lRETCON := .F.
		Endif
		Return lRETCON
	Else
		lRETCON := .F.
		aVETORC := {lRETCON,cMENSFI}
	Endif
Return aVETORC
/*/
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
	±±≥FunáÖo    ≥NGTBEMPAI ≥ Autor ≥In†cio Luiz Kolling    ≥ Data ≥11/03/2003≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥DescriáÖo ≥Valida os compos de retorno de contador (1/2)               ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥Parametros≥cVBEM     - C¢digo do bem                      - Obrigatorio≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥Retorna   ≥ cBEMRET  - C¢digo do bem em que dever† ser informado o con-≥±±
	±±≥          ≥            tador. Se o mesmo for vazio nao poder† ser edi- ≥±±
	±±≥          ≥            tados os campos de contador                     ≥±±
	±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function NGTBEMPAI(cVBEM,cBEMRET,cFilN)
	Local ccalias := alias(),nvordem := INDEXORD(),cVBEMAU := cVBEM
	Local cFilBem := NGTROCAFILI("ST9",cFilN)
	Local cFilSTC := NGTROCAFILI("STC",cFilN)

	TIPOACOM := .F.
	TIPOACOM2 := .F.

	dbSelectArea("ST9")
	dbSetOrder(01)
	If dbSeek(cFilBem+cVBEMAU)
		If st9->t9_temcont = 'S'
			cBEMRET := NGTBEMCON(cVBEMAU,cFilN)
		Else
			cTIPOCON := st9->t9_temcont
			dbSelectArea("STC")
			dbSetOrder(03)
			If dbSeek(cFilSTC+cVBEMAU)
				If st9->t9_temcont = 'P'
					While .T.
						If dbSeek(cFilSTC+cVBEMAU)
							cVBEMAU := stc->tc_codbem
						Else
							Exit
						Endif
					End
					If !Empty(cVBEMAU)
						dbSelectArea("ST9")
						dbSetOrder(01)
						If dbSeek(cFilBem+cVBEMAU)
							If st9->t9_temcont = 'S'
								cBEMRET := NGTBEMCON(cVBEMAU,cFilN)
							Endif
						Endif
					Endif
				ElseIf st9->t9_temcont = 'I'
					While .T.
						dbSelectArea("ST9")
						dbSetOrder(01)
						If dbSeek(cFilBem+cVBEMAU)
							If st9->t9_temcont = 'S'
								cBEMRET := NGTBEMCON(cVBEMAU,cFilN)
								If cTIPOCON = 'I'
									Exit
								Endif
							Endif
						Endif

						dbSelectArea("STC")
						dbSetOrder(03)
						If dbSeek(cFilSTC+cVBEMAU)
							cVBEMAU := stc->tc_codbem
						Else
							dbSelectArea("ST9")
							dbSetOrder(01)
							If dbSeek(cFilBem+cVBEMAU)
								If st9->t9_temcont = 'S'
									cBEMRET := NGTBEMCON(cVBEMAU,cFilN)
								Endif
							Else
								TIPOACOM := .F.
								TIPOACOM2 := .F.
								cBEMRET   := space(len(cVBEM))
							Endif
							Exit
						Endif
					End
				Endif
			Endif
		Endif
	Endif

	dbSelectArea(ccalias)
	dbSetOrder(nvordem)

Return cBEMRET
/*/
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
	±±≥FunáÖo    ≥NGTBEMCON ≥ Autor ≥In†cio Luiz Kolling    ≥ Data ≥11/03/2003≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥DescriáÖo ≥Alimenta vari†veis e retorna o c¢digo do bem / contador     ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥Parametros≥cVBEM     - C¢digo do bem                      - Obrigatorio≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥Retorna   ≥ cBEMCON  - C¢digo do bem em que dever† ser informado o con-≥±±
	±±≥          ≥            tador.                                          ≥±±
	±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function NGTBEMCON(cVBEM,cFilV)
	Local cBEMCON := cVBEM
	Local cFilAli := NGTROCAFILI("TPE",cFilV)
	TIPOACOM := .T.
	dbSelectArea("TPE")
	dbSetOrder(01)
	If dbSeek(cFilAli+cBEMCON)
		TIPOACOM2 := .T.
	Endif
Return cBEMCON

//-------------------------------------------------------------------
/*/{Protheus.doc} NGVALIVARD
Checa a variaÁ„o dia ( intervalo de valores v·lidos )

@author  In·cio Luiz Kolling
@since   11/03/2003
@version P11/P12
@param   cVBEM,      Caracter, CÛdigo do bem
@param   nPOSCON,    NumÈrico, Valor do contador
@param   dVLEIT,     Data,     Data da leitura
@param   cVHORA,     Caracter, Hora da leitura
@param   nTIPOC,     NumÈrico, Tipo do contador ( 1/2 )
@param   lSAIDA,     LÛgico,   Indica se a sa°da de erro na tela
@param   [nITEMC],   NumÈrico, Item do getdados
@param   [cFilTroc], Caracter, Filial de troca de acesso

@return  SE lSAIDA = .T.
            .T. /ou .F.
         SENAO
            aVETCHK    Onde:
            SE  aVETCHC[1] = .T.
                Sem problema
                aVETCHC[2] = Conteudo vazio
                aVETCHC[3] = Valor variacao dia
            SENAO
                Problema
                aVETCHC[2] = Mensagem do problema
                aVETCHC[3] = Valor variacao dia
/*/
//-------------------------------------------------------------------
Function NGVALIVARD(cVBEM,nPOSCON,dVLEIT,cVHORA,nTIPOC,lSAIDA,nITEMC,cFilTroc)

	Local nVARDCHK := 0
	Local nVARDCAL := 0
	Local nACUMCHK := 0
	Local nVARMEN  := 0
	Local dDATACHK := Ctod('  /  /  ')
	Local cHORACHK := '  :  '
	Local aVETCHK  := {}
	Local lRETCHK  := .T.
	Local cFAMI    := Space(Len(ST9->T9_CODFAMI))
	Local cMENCHK  := Space(1)
	Local cTitulo  := STR0050+CRLF+CRLF+;        //"CONTADOR INFORMADO ESTA FORA DO PADRAO"
	STR0051+Str(nTIPOC,1)+CRLF //"Problema Com Variacao Dia do Contador "
	Local vARQVAR  := If(nTIPOC = 1,{'ST9','STP','STP->TP_FILIAL','STP->TP_CODBEM','STP->TP_ACUMCON','STP->TP_VARDIA','STP->TP_POSCONT',;
		'ST9->T9_LIMICON','ST9->T9_CONTACU','ST9->T9_POSCONT','STP->TP_DTLEITU','STP->TP_HORA'},;
		{'TPE','TPP','TPP->TPP_FILIAL','TPP->TPP_CODBEM','TPP->TPP_ACUMCO','TPP->TPP_VARDIA','TPP->TPP_POSCON',;
		'TPE->TPE_LIMICO','TPE->TPE_CONTAC','TPE->TPE_POSCON','TPP->TPP_DTLEIT','TPP->TPP_HORA'})

	Local cFilCoc := NGTROCAFILI(vARQVAR[1],cFilTroc)
	Local cFilHic := NGTROCAFILI(vARQVAR[2],cFilTroc)
	Local xValor  := ''

	cTitulo := If(nITEMC <> NIL,cTitulo+STR0052+Str(nITEMC,2)+CRLF+CRLF,cTitulo+CRLF) //"No item "

	dbSelectArea(vARQVAR[1])
	dbSetOrder(01)
	dbSeek(cFilCoc+cVBEM)
	cFAMI := ST9->T9_CODFAMI

	dbSelectArea(vARQVAR[2])
	dbSetOrder(5)
	dbSeek(cFilHic+cVBEM+Dtos(dVLEIT)+cVHORA,.T.)
	If Eof()
		dbSkip(-1)
	Else
		If (&(vARQVAR[3]) == cFilHic .And. &(vARQVAR[4]) <> cVBEM) .Or. (&(vARQVAR[3]) <> cFilHic .And. &(vARQVAR[4]) == cVBEM) .Or.;
				(&(vARQVAR[3]) <> cFilHic .And. &(vARQVAR[4]) <> cVBEM)
			dbSkip(-1)
		Endif
	Endif

	If &(vARQVAR[3]) == cFilHic .And. &(vARQVAR[4]) = cVBEM
		nACUMCHK := &(vARQVAR[5])
		nVARDCHK := &(vARQVAR[6])
		dDATACHK := &(vARQVAR[11])
		cHORACHK := &(vARQVAR[12])

		If &(vARQVAR[11]) > dVLEIT
			dbSkip(-1)
			If &(vARQVAR[3]) == cFilHic .And. &(vARQVAR[4]) <> cVBEM
				dbSkip(-1)
			Endif
		Endif

		If !Bof() .And. &(vARQVAR[3]) == cFilHic .And. &(vARQVAR[4]) == cVBEM
			If &(vARQVAR[11]) == dVLEIT
				If &(vARQVAR[12]) < cVHORA
					nACUMCHK := &(vARQVAR[5])
					nVARDCHK := &(vARQVAR[6])
					dDATACHK := &(vARQVAR[11])
					cHORACHK := &(vARQVAR[12])

				ElseIf &(vARQVAR[12]) > cVHORA
					dbSkip(-1)
					If !Bof() .And. &(vARQVAR[3]) == cFilHic .And. &(vARQVAR[4]) = cVBEM
						nACUMCHK := &(vARQVAR[5])
						nVARDCHK := &(vARQVAR[6])
						dDATACHK := &(vARQVAR[11])
						cHORACHK := &(vARQVAR[12])
					Endif
				ElseIf &(vARQVAR[12]) == cVHORA .And. &(vARQVAR[7]) <> nPosCon // Caso o contador esteja sendo editado
					dbSkip(-1)
					If !Bof() .And. &(vARQVAR[3]) == cFilHic .And. &(vARQVAR[4]) == cVBEM
						nACUMCHK := &(vARQVAR[5])
						nVARDCHK := &(vARQVAR[6])
						dDATACHK := &(vARQVAR[11])
						cHORACHK := &(vARQVAR[12])
					Else
						dbSkip()
					EndIf
				EndIf
			Else
				nACUMCHK := &(vARQVAR[5])
				nVARDCHK := &(vARQVAR[6])
				dDATACHK := &(vARQVAR[11])
				cHORACHK := &(vARQVAR[12])
			Endif
		Endif
		nDIFECO  := nPOSCON - &(vARQVAR[7])
		lVIRACO  := If(nDIFECO < 0,.T.,.F.)
		nACUMCHK := If(lVIRACO,((&(vARQVAR[8]) - &(vARQVAR[7])) + nPOSCON)+nACUMCHK,;
			nACUMCHK+nDIFECO)
	Else
		nACUMCHK := &(vARQVAR[9])+(nPOSCON - &(vARQVAR[10]))
	Endif

	nVARDCAL := NGVARIADT(cVBEM,dVLEIT,nTIPOC,nACUMCHK,.F.,.T.,cFilHic,cFilTroc)

	aVETCHK  := {lRETCHK,cMENCHK,nVARDCAL,.T.}

	If nVARDCAL > 999999
		cMENCHK := STR0053+CRLF; // //"O sistema nao comporta uma variacao dia"
		+STR0054+CRLF+CRLF; // //"maior do que 999999"
		+STR0055+Str(nVARDCAL,9) // //"Variacao Calculada  -> "
		If lSAIDA
			Help(" ",1,STR0044,,cTITULO+cMENCHK,4,5) // "NAO CONFORMIDADE"
			lRETCHK := .F.
		Else
			lRETCHK := .F.
			aVETCHK := {lRETCHK,cMENCHK,nVARDCAL,.T.}
		Endif
	Else
		If nVARDCHK > 0
			nVARPAR := GetMv("MV_NGPRVDI")
			nVARIAC := Round((nVARDCHK * nVARPAR )/100,0)
			nVARMEN := nVARDCHK - nVARIAC
			nVARMAI := nVARDCHK+nVARIAC
			vRetLim := NGCHKLIMVAR(cVBEM,cFAMI,nTIPOC,nVARDCAL,lSAIDA)

			If !vRetLim[1]
				lRETCHK := vRetLim[1]
				aVETCHK := Aclone(vRetLim)
			Else
				If !( nVARDCAL >= nVARMEN .And. nVARDCAL <= nVARMAI )

					cMENCHK := STR0056+cVBEM+CRLF+CRLF;             // "Bem            -> "
					+STR0057+CRLF+CRLF;                   // "Dados do Lancamento Anterior:"
					+STR0058+Dtoc(dDATACHK)+CRLF;         // "   Data do Lancamento     -> "
					+STR0059+cHORACHK+CRLF;               // "   Hora do Lancamento     -> "
					+STR0060+Str(nVARDCHK,9)+CRLF+CRLF;   // "   Variacao dia do Lanc.  -> "
					+STR0061+CRLF+CRLF;                   // "Dados da variacao dia Calculada:"
					+STR0062+Dtoc(dVLEIT)+CRLF;           // "   Data Informada p/ cal. -> "
					+STR0063+Substr(cVHORA,1,5)+CRLF;     // "   Hora Informada p/ cal. -> "
					+STR0064+Str(nVARDCAL,9)+CRLF+CRLF;   // "   Variacao Calculada     -> "
					+STR0065+STR(nVARPAR,9)+"%"+CRLF+CRLF;// "Tolerancia       -> "

					If lSAIDA
						If !MsgYesNo(cTitulo+cMENCHK+STR0066,STR0067) //### //"Confirma ?"###"ATENCAO"
							lRETCHK := .F.
						EndIf
					Else
						lRETCHK := .F.
						aVETCHK := {lRETCHK,cMENCHK,nVARDCAL,.F.}
					Endif
				EndIf
			EndIf
		EndIf
	Endif

	If ExistBlock("NGCHECVAR")
		xValor := ExecBlock( "NGCHECVAR", .F., .F., { lSAIDA, cVBEM, nPOSCON, dVLEIT, cVHORA, nTIPOC, nVARDCAL, nVARMEN, aVETCHK, nVARDCHK } )
		// Tratativa realizada para n„o afetar os usu·rio que j· utilizam o P.E.
		If ValType( xValor ) == 'A'
			aVETCHK := xValor
		Else
			lRETCHK := xValor
		EndIf
	EndIf

Return IIf( lSAIDA, lRETCHK, aVETCHK )

//---------------------------------------------------------------------
/*/{Protheus.doc} NGCHKVIRAD
ConsistÍncia da virada de contador

@param cVBEMV   - CÛdigo do bem - ObrigatÛrio
@param dDTLEIT  - Data da leitura - ObrigatÛrio
@param nCONTAV  - Valor do contador - ObrigatÛrio
@param cHORAV   - Hora da leitura - ObrigatÛrio
@param nTIPOC   - Tipo do contador ( 1/2 ) - ObrigatÛrio
@param cFilTroc - Filial de troca de acesso - N„o obrigatÛrio
@param lGETVAR  - Define se o retorno ser· lÛgico ou array - N„o obrigatÛrio
@param lRetMen  - Retorno para compor a memo do reprocessamento de contador prÛprio (mnta876) - N„o obrigatÛrio

@author Inacio Luiz Kolling
@since 27/05/2003
@version 1.0
@return SE lGETVAR = .T.
			.T. /ou .F.
 		SENAO
    		aVETOR    Onde:
			SE  aVETOR[1] = .T.
				Sem problema
				aVETOR[2] = Conteudo vazio
			SENAO
				Problema
       			aVETOR[2] = Mensagem do problema
/*/
//---------------------------------------------------------------------
Function NGCHKVIRAD(cVBEMV,dDTLEIT,nCONTAV,cHORAV,nTIPOC,cFilTroc,lGETVAR,lRetMen)
	Local cMENSAV := Space(1), cMENV1 := Space(1), cMENV2 := Space(1)
	Local cMENV3  := Space(1)
	Local cMENVP  := STR0072+CRLF // //"Para caracterizar como sendo uma virada"
	Local cMENSP  := STR0073+Str(nTIPOC)+CRLF+CRLF; // //"Problema na virada do contador "
	+STR0020+Alltrim(cVBEMV)+CRLF; // //"Bem..................: "
	+STR0021+dtoc(dDTLEIT)+CRLF; // //"Data..................: "
	+STR0022+Str(nCONTAV,9)+CRLF; // //"Contador...........: "
	+STR0023+cHORAV+CRLF+CRLF // //"Hora Informada.: "

	Local aVETVIR := If(nTIPOC = 1,{'STP','stp->tp_filial','stp->tp_codbem',;
		'stp->tp_poscont','stp->tp_dtleitu','stp->tp_hora'},;
		{'TPP','tpp->tpp_filial','tpp->tpp_codbem',;
		'tpp->tpp_poscon','tpp->tpp_dtleit','tpp->tpp_hora'})

	Local cFilHis := NGTROCAFILI(aVETVIR[1],cFilTroc)
	Local nPercV
	Local cMenRet := ""

	Default lRetMen := .F.

	lGETVAR := If(lGETVAR = NIL,.T.,lGETVAR)

	dbSelectArea(aVETVIR[1])
	dbSetOrder(5)
	dbSeek(cFilHis+cVBEMV+Dtos(dDTLEIT)+cHORAV,.T.)
	If Eof()
		dbSkip(-1)
		If !Bof()
			If &(aVETVIR[2]) == cFilHis .And. &(aVETVIR[3]) = cVBEMV
				If nCONTAV >= &(aVETVIR[4])
					cMENV3 := cMENVP+STR0074+CRLF+CRLF // //"Contador devera ser menor ao do lancamento"
					cMENV1 := STR0026+Dtoc(&(aVETVIR[5]))+CRLF+; // //"Data Lancamento..: "
					STR0027+str(&(aVETVIR[4]),9)+CRLF+; // //"Contador................: "
					STR0028+&(aVETVIR[6]) // //"Hora Lancamento..: "
					cMENSAV := cMENSP+cMENV3+cMENV1
					cMenRet := STR0074 + ":" + CRLF +;//"Contador devera ser menor ao do lancamento"
					STR0026 + Dtoc(&(aVETVIR[5])) + CRLF +;//"Data Lancamento..: "
					STR0028 + &(aVETVIR[6]) + CRLF +;//"Hora Lancamento..: "
					STR0027+str(&(aVETVIR[4]),9) //"Contador................: "
				Endif
			Else
				If &(aVETVIR[2]) == cFilHis .And. &(aVETVIR[3]) <> cVBEMV
					dbSkip(-1)
				Endif
				If !Bof()
					If &(aVETVIR[2]) == cFilHis .And. &(aVETVIR[3]) = cVBEMV
						If nCONTAV >= &(aVETVIR[4])
							cMENV3 := cMENVP+STR0074+CRLF+CRLF // //"Contador devera ser menor ao do lancamento"
							cMENV1 := STR0026+Dtoc(&(aVETVIR[5]))+CRLF+; // //"Data Lancamento..: "
							STR0027+str(&(aVETVIR[4]),9)+CRLF+; // //"Contador................: "
							STR0028+&(aVETVIR[6]) // //"Hora Lancamento..: "
							cMENSAV := cMENSP+cMENV3+cMENV1
							cMenRet := STR0074 + ":" + CRLF +;//"Contador devera ser menor ao do lancamento"
							STR0026 + Dtoc(&(aVETVIR[5])) + CRLF +; //"Data Lancamento..: "
							STR0028 + &(aVETVIR[6]) + CRLF +; //"Hora Lancamento..: "
							STR0027 + str(&(aVETVIR[4]),9) //"Contador................: "
						Endif
					Else
						cMENV3 := STR0075+CRLF+cMENVP+CRLF // //"Nao ha registro anterior ao lancamento"
						cMENSAV := cMENSP+cMENV3
						cMenRet := STR0075
					Endif
				Endif
			Endif
		Else
			If &(aVETVIR[2]) == cFilHis .And. &(aVETVIR[3]) = cVBEMV
				If nCONTAV >= &(aVETVIR[4])
					cMENV3 := cMENVP+STR0074+CRLF+CRLF // //"Contador devera ser menor ao do lancamento"
					cMENV1 := STR0026+Dtoc(&(aVETVIR[5]))+CRLF+; // //"Data Lancamento..: "
					STR0027+str(&(aVETVIR[4]),9)+CRLF+; // //"Contador................: "
					STR0028+&(aVETVIR[6]) // //"Hora Lancamento..: "
					cMENSAV := cMENSP+cMENV3+cMENV1
					cMenRet := STR0074 + CRLF +; //"Contador devera ser menor ao do lancamento"
					STR0026 + Dtoc(&(aVETVIR[5])) + CRLF +; //"Data Lancamento..: "
					STR0028 + &(aVETVIR[6]) + CRLF +; //"Hora Lancamento..: "
					STR0027 + str(&(aVETVIR[4]),9) //"Contador................: "
				Endif
			Else
				cMENV3 := STR0075+CRLF+cMENVP+CRLF // //"Nao ha registro anterior ao lancamento"
				cMENSAV := cMENSP+cMENV3
				cMenRet := STR0075
			Endif
		Endif
	Else
		If &(aVETVIR[2]) = cFilHis .And. &(aVETVIR[3]) = cVBEMV;
				.And. &(aVETVIR[5]) = dDTLEIT .And. &(aVETVIR[6]) = cHORAV
			cMENV3 := STR0076+CRLF+CRLF // //"Ja existe um lancamento com as caracteristicas"
			cMENV1 := STR0026+Dtoc(&(aVETVIR[5]))+CRLF+; // //"Data Lancamento..: "
			STR0027+str(&(aVETVIR[4]),9)+CRLF+; // //"Contador................: "
			STR0028+&(aVETVIR[6]) // //"Hora Lancamento..: "
			cMENSAV := cMENSP+cMENV3+cMENV1
			cMenRet := STR0076 + CRLF +; //"Ja existe um lancamento com as caracteristicas"
			STR0026 + Dtoc(&(aVETVIR[5])) + CRLF +; //"Data Lancamento..: "
			STR0028 + &(aVETVIR[6]) + CRLF +; //"Hora Lancamento..: "
			STR0027 + str(&(aVETVIR[4]),9) //"Contador................: "
		Else
			If &(aVETVIR[2]) == cFilHis .And. &(aVETVIR[3]) <> cVBEMV
				dbSkip(-1)
			Endif
			If !Bof()
				If &(aVETVIR[2]) == cFilHis .And. &(aVETVIR[3]) = cVBEMV
					If &(aVETVIR[5]) < dDTLEIT
						If nCONTAV >= &(aVETVIR[4])

							cMENV3 := cMENVP+STR0074+CRLF+CRLF // //"Contador devera ser menor ao do lancamento"
							cMENV1 := STR0026+Dtoc(&(aVETVIR[5]))+CRLF+; // //"Data Lancamento..: "
							STR0027+str(&(aVETVIR[4]),9)+CRLF+; // //"Contador................: "
							STR0028+&(aVETVIR[6]) // //"Hora Lancamento..: "
							cMENSAV := cMENSP+cMENV3+cMENV1
							cMenRet := STR0074 + CRLF +; //"Contador devera ser menor ao do lancamento"
							STR0026 + Dtoc(&(aVETVIR[5])) + CRLF +; //"Data Lancamento..: "
							STR0028 + &(aVETVIR[6]) + CRLF +; //"Hora Lancamento..: "
							STR0027 + str(&(aVETVIR[4]),9) //"Contador................: "
						Endif
					ElseIf &(aVETVIR[5]) = dDTLEIT
						If cHORAV < &(aVETVIR[6])
							nCONTAN := &(aVETVIR[4])
							nCONTPO := 0
							dDATAAN := &(aVETVIR[5])
							cHORAAN := &(aVETVIR[6])
							dDATAPO := Ctod('  /  /  ')
							cHORAPO := Space(5)

							Dbskip(-1)
							If !Bof() .And. &(aVETVIR[2]) == cFilHis .And. &(aVETVIR[3]) = cVBEMV
								nCONTPO := &(aVETVIR[4])
								dDATAPO := &(aVETVIR[5])
								cHORAPO := &(aVETVIR[6])
							Endif

							lPROBLV := .T.
							If !Empty(nCONTAN) .And. !Empty(nCONTPO)

								lVIRAB := .F.
								If nCONTAN >= nCONTPO   // 45000 12000 - 5
									If nCONTAV < nCONTAN .And. nCONTAV < nCONTPO
										lPROBLV := .F.
									Else
										cMENV3 := cMENVP+STR0077+CRLF+CRLF // //"Contador devera ser menor ao do intervalo"
										lVIRAB := .T.
									Endif
								Else
									If nCONTAN < nCONTPO   // 100 12000 - 5
										cMENV3 := STR0078+CRLF+CRLF // //"Nao ha possibilidade de virada entre os lancamentos"
										lVIRAB := .T.
									Endif
								Endif
								If lVIRAB := .T.
									cMENV1 := STR0026+Dtoc(dDATAPO)+CRLF; // //"Data Lancamento..: "
									+STR0027+str(nCONTPO,9)+CRLF; // //"Contador................: "
									+STR0028+cHORAPO+CRLF+CRLF // //"Hora Lancamento..: "

									cMENV2 := STR0026+Dtoc(dDATAAN)+CRLF; // //"Data Lancamento..: "
									+STR0027+str(nCONTAN,9)+CRLF; // //"Contador................: "
									+STR0028+cHORAAN // //"Hora Lancamento..: "
								Endif
							Endif

							If Empty(nCONTPO)
								cMENV3 := STR0075+CRLF+cMENVP+CRLF // //"Nao ha registro anterior ao lancamento"
							Endif

							If lPROBLV
								cMENSAV := cMENSP+cMENV3+cMENV1+cMENV2
								cMenRet := STR0078 + CRLF +; //"Nao ha possibilidade de virada entre os lancamentos"
								STR0026 + Dtoc(dDATAPO) + CRLF +; //"Data Lancamento..: "
								STR0028 + cHORAPO + CRLF +; //"Hora Lancamento..: "
								STR0027 + str(nCONTPO,9) + CRLF + CRLF +; //"Contador................: "
								STR0026 + Dtoc(dDATAAN) + CRLF +; //"Data Lancamento..: "
								STR0028 + cHORAAN + CRLF +; //"Hora Lancamento..: "
								STR0027 + str(nCONTAN,9) //"Contador................: "
							Endif
						Else
							If nCONTAV >= &(aVETVIR[4])
								cMENV3 := cMENVP+STR0074+CRLF+CRLF // //"Contador devera ser menor ao do lancamento"
								cMENV1 := STR0026+Dtoc(&(aVETVIR[5]))+CRLF+; // //"Data Lancamento..: "
								STR0027+str(&(aVETVIR[4]),9)+CRLF+; // //"Contador................: "
								STR0028+&(aVETVIR[6]) // //"Hora Lancamento..: "
								cMENSAV := cMENSP+cMENV3+cMENV1
								cMenRet := STR0074 + CRLF +; //"Contador devera ser menor ao do lancamento"
								STR0026 + Dtoc(&(aVETVIR[5])) + CRLF +; //"Data Lancamento..: "
								STR0028 + &(aVETVIR[6]) + CRLF +; //"Hora Lancamento..: "
								STR0027 + str(&(aVETVIR[4]),9) //"Contador................: "
							Endif
						Endif
					Else
						nCONTAN := &(aVETVIR[4])
						nCONTPO := 0
						dDATAAN := &(aVETVIR[5])
						cHORAAN := &(aVETVIR[6])
						dDATAPO := Ctod('  /  /  ')
						cHORAPO := Space(5)

						dbSkip(-1)
						If !Bof() .And. &(aVETVIR[2]) == cFilHis .And. &(aVETVIR[3]) = cVBEMV
							nCONTPO := &(aVETVIR[4])
							dDATAPO := &(aVETVIR[5])
							cHORAPO := &(aVETVIR[6])
						Endif

						lPROBLV := .T.
						If !Empty(nCONTAN) .And. !Empty(nCONTPO)

							lVIRAB := .F.
							If nCONTAN >= nCONTPO   // 45000 12000 - 5
								If nCONTAV < nCONTAN .And. nCONTAV < nCONTPO
									lPROBLV := .F.
								Else
									cMENV3 := cMENVP+STR0077+CRLF+CRLF // //"Contador devera ser menor ao do intervalo"
									lVIRAB := .T.
								Endif
							Else
								If nCONTAN < nCONTPO   // 100 12000 - 5
									cMENV3 := STR0078+CRLF+CRLF // //"Nao ha possibilidade de virada entre os lancamentos"
									lVIRAB := .T.
								Endif
							Endif
							If lVIRAB := .T.
								cMENV1 := STR0026+Dtoc(dDATAPO)+CRLF; // //"Data Lancamento..: "
								+STR0027+str(nCONTPO,9)+CRLF; // //"Contador................: "
								+STR0028+cHORAPO+CRLF+CRLF // //"Hora Lancamento..: "

								cMENV2 := STR0026+Dtoc(dDATAAN)+CRLF; // //"Data Lancamento..: "
								+STR0027+str(nCONTAN,9)+CRLF; // //"Contador................: "
								+STR0028+cHORAAN // //"Hora Lancamento..: "
							Endif
						Endif

						If Empty(nCONTPO)
							cMENV3 := STR0075+CRLF+cMENVP+CRLF // //"Nao ha registro anterior ao lancamento"
						Endif

						If lPROBLV
							cMENSAV := cMENSP+cMENV3+cMENV1+cMENV2
							cMenRet := STR0078 + CRLF +; //"Nao ha possibilidade de virada entre os lancamentos"
							STR0026 + Dtoc(dDATAPO) + CRLF +; //"Data Lancamento..: "
							STR0028 + cHORAPO + CRLF +; //"Hora Lancamento..: "
							STR0027 + str(nCONTPO,9) + CRLF + CRLF +; //"Contador................: "
							STR0026 + Dtoc(dDATAAN) + CRLF +; //"Data Lancamento..: "
							STR0028 + cHORAAN + CRLF +; //"Hora Lancamento..: "
							STR0027 + str(nCONTAN,9) //"Contador................: "
						Endif
					Endif
				Else
				Endif
			EndIf
		Endif

		If (SuperGetMv("MV_NGPERCV", .F., 0) > 0)
			nPercV := ((&(aVETVIR[4]) / NGSEEK("ST9",&(aVETVIR[3]),1,"T9_LIMICON")) * 100)
			If(nPercV < SuperGetMv("MV_NGPERCV", .F., 0))
				cMENV3 :=  STR0157 + chr(13); //"Contador anterior n„o alcanÁou o mÌnimo"
				+ STR0158 + chr(13) + chr(13) //"percentual para realizar a virada:"
				cMENV1 :=  STR0159 + cValToChar(SuperGetMv("MV_NGPERCV", .F., 0)) + "%" + chr(13); //"Min. percentual......: "
				+ STR0026 + Dtoc(&(aVETVIR[5])) + chr(13); //"Data Lancamento..: "
				+ STR0027 + str(&(aVETVIR[4]),9) + chr(13); //"Contador................: "
				+ STR0028 + &(aVETVIR[6]) //"Hora Lancamento..: "
				cMENSAV := cMENSP+cMENV3+cMENV1
				cMenRet := STR0157 + " " + STR0158 + CRLF +; //"Contador anterior n„o alcanÁou o mÌnimo percentual para realizar a virada:"
				STR0159 + cValToChar(SuperGetMv("MV_NGPERCV", .F., 0)) + "%" + CRLF +; //"Min. percentual......: "
				STR0026 + Dtoc(&(aVETVIR[5])) + CRLF +; //"Data Lancamento..: "
				STR0028 + &(aVETVIR[6]) + CRLF +; //"Hora Lancamento..: "
				STR0027 + AllTrim(str(&(aVETVIR[4]),9)) //"Contador................: "
			EndIf
		EndIf

	Endif

	If lRetMen//Retorno para compor a memo do reprocessamento de contador prÛprio (mnta876)
		Return {Empty(cMenRet),cMenRet}
	EndIf

	If !Empty(cMENSAV)
		If lGETVAR
			MsgInfo(cMENSAV,STR0044) //"NAO CONFORMIDADE"
			Return .F.
		Else
			Return {.F.,cMENSAV}
		EndIf
	EndIf

Return IIF(lGETVAR, .T., {.T.,""})
/*/
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
	±±≥FunáÖo    ≥NGCRETROAT≥ Autor ≥In†cio Luiz Kolling    ≥ Data ≥14/03/2006≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥DescriáÖo ≥Acerto de contador acumulado de saida de um componente re-  ≥±±
	±±≥          ≥troativo em relaá∆o ao ultimo reporte de contador           ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥Parametros≥cVCOMP    - Codigo do componente               - Obrigatorio≥±±
	±±≥          ≥dVDATA    - Data da entrada do componente      - Obrigat¢rio≥±±
	±±≥          ≥cVHORA    - Hora da entrada do componente      - Obrigat¢rio≥±±
	±±≥          ≥nCONT1    - Contador 1                         - Nao Obrig. ≥±±
	±±≥          ≥nCONT2    - Contador 2                         - Nao Obrig. ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥Tabela/arq≥STP,STZ,ST9                                                 ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥Retorna   ≥.T.                                                         ≥±±
	±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function NGCRETROAT(cVCOMP,dVDATA,cVHORA,nCONT1,nCONT2)
	Local aAreaco   := GetArea(),lRETOAT := .T.,lTROCALC := .F.
	Local nal       := 0,nVE := 0,nREGSTPAT := 0,nRECRECAT := 0
	Local cCOMPTRO  := Space(Len(st9->t9_codbem))

	Local cTrbE		:= GetNextAlias()
	Local oTmpTbl

	Local vVETCBEM  := {{'ST9','st9->t9_dtultac','st9->t9_poscont','st9->t9_vardia','st9->t9_contacu'},;
		{'TPE','tpe->tpe_dtulta','tpe->tpe_poscon','tpe->tpe_vardia','tpe->tpe_contac'}}

	Local vVETCHIS  := {{'STP','stp->tp_filial','stp->tp_codbem','stp->tp_dtleitu',;
		'stp->tp_hora','stp->tp_acumcon','stp->tp_vardia','stp->tp_poscont',;
		'TP_CODBEM+Dtos(TP_DTLEITU)+TP_HORA','TRBE->TP_POSCONT',;
		'TRBE->TP_VARDIA','TRBE->TP_DTLEITU','TRBE->TP_VIRACON',;
		'TRBE->TP_HORA'},;
		{'TPP','tpp->tpp_filial','tpp->tpp_codbem','tpp->tpp_dtleit',;
		'tpp->tpp_hora','tpp->tpp_acumco','tpp->tpp_vardia','tpp->tpp_poscon',;
		'TPP_CODBEM+Dtos(TPP_DTLEIT)+TPP_HORA','TRBE->TPP_POSCON',;
		'TRBE->TPP_VARDIA','TRBE->TPP_DTLEIT','TRBE->TPP_VIRACO',;
		'TRBE->TPP_HORA'}}

	Local nPLI := 1,nPFL := 2

	If nCONT2 = Nil .Or. Empty(nCONT2)
		nPFL := 1
	ElseIf nCONT1 = Nil .Or. Empty(nCONT1)
		nPLI := 2
	Endif

	For nVE := nPLI To nPFL
		nREGSTPAT := 0
		nRECRECAT := 0
		lRETOAT   := .T.
		lTROCALC  := .F.

		// procura o ultimo lancamento do componente no historio
		dbSelectArea(vVETCHIS[nVE,1])
		dbSetOrder(05)
		dbSeek(xFILIAL(vVETCHIS[nVE,1])+cVCOMP+Dtos(dDataBase+300),.T.)
		If !Eof()
			If &(vVETCHIS[nVE,2]) <> xFILIAL(vVETCHIS[nVE,1]) .Or. &(vVETCHIS[nVE,3]) <> cVCOMP
				dbSkip(-1)
			Endif
		ElseIf !Bof()
			If &(vVETCHIS[nVE,2]) <> xFILIAL(vVETCHIS[nVE,1]) .Or. &(vVETCHIS[nVE,3]) <> cVCOMP
				dbSkip()
			Endif
		ElseIf Eof()
			dbSkip(-1)
		Endif

		// verifica o ultimo lancamento do componente no historio
		If &(vVETCHIS[nVE,2]) = xFILIAL(vVETCHIS[nVE,1]) .And. &(vVETCHIS[nVE,3]) = cVCOMP

			// verifica se o lancamento de contador Ç retroativo
			dbSelectArea("STZ")
			dbSetOrder(02)
			If dbSeek(xFILIAL('STZ')+cVCOMP+Dtos(dVDATA)+"S"+cVHORA)

				// verifica se o componente recebe contador

				If stz->tz_datasai <= &(vVETCHIS[nVE,4])
					If stz->tz_datasai = &(vVETCHIS[nVE,4])
						lRETOAT := If(stz->tz_horasai < &(vVETCHIS[nVE,5]),.T.,.F.)
					Endif
					If lRETOAT

						// procura lancamento de entrada do componente em outra estrutura

						dbSelectArea("STZ")
						dDATAENC := stz->tz_datasai
						cHORAENC := stz->tz_horasai
						dDATASAC := stz->tz_datasai
						cHORASAC := stz->tz_horasai
						cVBEMP   := stz->tz_bempai
						cLOCALIC := stz->tz_localiz
						lENTOEST := .F.

						dbSelectArea("STZ")
						While !Eof() .And. stz->tz_filial = Xfilial("STZ") .And.;
								stz->tz_codbem = cVCOMP
							If stz->tz_bempai <> cVBEMP
								dDATAENC := stz->tz_datamov
								cHORAENC := stz->tz_horaent
								lENTOEST := .T.
								Exit
							Endif
							dbSkip()
						End

						If !Empty(cLOCALIC)
							dbSelectArea("STZ")
							dbSetOrder(03)
							If dbSeek(xFILIAL('STZ')+cVBEMP+cLOCALIC+Dtos(dDATASAC))
								While !Eof() .And. stz->tz_filial = Xfilial("STZ") .And.;
										stz->tz_bempai = cVBEMP .And. stz->tz_localiz = cLOCALIC;
										.And. stz->tz_datamov = dDATASAC
									If stz->tz_tipomov = "E"
										lTROCALC := .T.
										cCOMPTRO := stz->tz_codbem
										dDTMPTRO := stz->tz_datamov
										cHOMPTRO := stz->tz_horaent
										Exit
									Endif
									dbSkip()
								End
							Endif

							If lTROCALC
								dbSelectArea(vVETCHIS[nVE,1])
								aDBFSTP := DbStruct()
								Aadd(aDBFSTP,{"DIFACUM" ,"N", 12,0})

								// Definicao dos indice(s) temporario(s)
								vINDC := {vVETCHIS[nVE,9]}

								//Instancia classe FWTemporaryTable
								oTmpTbl := FWTemporaryTable():New( cTrbE, aDBFSTP )

								//Cria indices
								oTmpTbl:AddIndex( "Ind01" , vINDC )

								//Cria a tabela temporaria
								oTmpTbl:Create()
							Endif
						Endif

						If !lENTOEST
							dDATAENC := Date()
							cHORAENC := Substr(Time(),1,5)
						Endif

						// procura o primeiro lancamento do contador no historico

						dbSelectArea(vVETCHIS[nVE,1])
						dbSetOrder(05)
						dbSeek(xFILIAL(vVETCHIS[nVE,1])+cVCOMP+Dtos(dDATASAC),.T.)
						If !Eof()
							If &(vVETCHIS[nVE,2]) <> xFILIAL(vVETCHIS[nVE,1]) .Or. &(vVETCHIS[nVE,3]) <> cVCOMP
								dbSkip(-1)
							Endif
						ElseIf !Bof()
							If &(vVETCHIS[nVE,2]) <> xFILIAL(vVETCHIS[nVE,1]) .Or. &(vVETCHIS[nVE,3]) <> cVCOMP
								dbSkip()
							Endif
						ElseIf Eof()
							dbSkip(-1)
						Endif

						// verifica o lancamento mais proximo do componente no historico
						nREGSTPAT := 0
						If &(vVETCHIS[nVE,2]) = xFILIAL(vVETCHIS[nVE,1]) .And. &(vVETCHIS[nVE,3]) = cVCOMP
							nREGSTPAT := Recno()

							While !Eof() .And. &(vVETCHIS[nVE,2]) = xFILIAL(vVETCHIS[nVE,1]) .And.;
									&(vVETCHIS[nVE,3]) = cVCOMP
								If &(vVETCHIS[nVE,4]) > dDATASAC
									nREGSTPAT := Recno()
									Exit
								ElseIf &(vVETCHIS[nVE,4]) = dDATASAC
									If !lENTOEST
										// If &(vVETCHIS[nVE,5]) < cHORASAC
										If &(vVETCHIS[nVE,5]) > cHORASAC
											nREGSTPAT := Recno()
											Exit
										Endif
									ElseIf &(vVETCHIS[nVE,5]) > cHORASAC
										nREGSTPAT := Recno()
										Exit
									Endif
								Endif
								dbSkip()
							End

							If nREGSTPAT > 0
								Dbgoto(nREGSTPAT)
								nREGSTPAT := Recno()
								nACUMAN := 0
								dbSkip(-1)
								If !Bof() .And. &(vVETCHIS[nVE,2]) = Xfilial(vVETCHIS[nVE,1]) .And.;
										&(vVETCHIS[nVE,3]) = cVCOMP
									nACUMAN := &(vVETCHIS[nVE,6])
								Endif

								nTOTDES := 0

								// deleta os registro de historico do contador e soma a
								// diferenca do contador acumulado
								Dbgoto(nREGSTPAT)
								If lENTOEST
									While !Eof() .And. &(vVETCHIS[nVE,2]) = Xfilial(vVETCHIS[nVE,1]) .And.;
											&(vVETCHIS[nVE,3]) = cVCOMP .And. &(vVETCHIS[nVE,4]) <= dDATAENC;
											.And. &(vVETCHIS[nVE,5]) < cHORAENC

										If lTROCALC
											dbSelectArea(cTrbE)
											RecLock(cTrbE,.T.)
											dbSelectArea(vVETCHIS[nVE,1])
											For nal := 1 To Fcount()
												ny   := "(cTrbE)->" + Fieldname(nal)
												nx   := vVETCHIS[nVE,1]+"->" + Fieldname(nal)
												&ny. := &nx.
											Next nal
											TRBE->DIFACUM := &(vVETCHIS[nVE,6]) - nACUMAN
											MsUnlock(cTrbE)
										Endif

										dbSelectArea(vVETCHIS[nVE,1])
										nTOTDES += &(vVETCHIS[nVE,6]) - nACUMAN
										nACUMAN := &(vVETCHIS[nVE,6])
										RecLock(vVETCHIS[nVE,1],.F.)
										Dbdelete()
										MsUnlock(vVETCHIS[nVE,1])
										dbSkip()
									End
								Else
									While !Eof() .And. &(vVETCHIS[nVE,2]) = Xfilial(vVETCHIS[nVE,1]) .And.;
											&(vVETCHIS[nVE,3]) = cVCOMP .And. &(vVETCHIS[nVE,4]) <= dDATAENC

										If lTROCALC
											dbSelectArea(cTrbE)
											RecLock(cTrbE,.T.)
											dbSelectArea(vVETCHIS[nVE,1])
											For nal := 1 To Fcount()
												ny   := "(cTrbE)->" + Fieldname(nal)
												nx   := vVETCHIS[nVE,1]+"->" + Fieldname(nal)
												&ny. := &nx.
											Next nal
											TRBE->DIFACUM := &(vVETCHIS[nVE,6]) - nACUMAN
											MsUnlock(cTrbE)
										Endif

										dbSelectArea(vVETCHIS[nVE,1])
										nTOTDES += &(vVETCHIS[nVE,6]) - nACUMAN
										nACUMAN := &(vVETCHIS[nVE,6])

										RecLock(vVETCHIS[nVE,1],.F.)
										Dbdelete()
										MsUnlock(vVETCHIS[nVE,1])
										dbSkip()
									End
								Endif

								If nTOTDES > 0
									// recalcula o cantador acumulado
									While !Eof() .And. &(vVETCHIS[nVE,2]) = Xfilial(vVETCHIS[nVE,1]) .And.;
											&(vVETCHIS[nVE,3]) = cVCOMP
										RecLock(vVETCHIS[nVE,1],.F.)
										&(vVETCHIS[nVE,6]) -= nTOTDES
										MsUnlock(vVETCHIS[nVE,1])
										dbSkip()
									End

									// recalcula a variacao dia
									Dbgoto(nREGSTPAT)
									dbSkip(-1)
									nREGSTPAT := Recno()
									While !Eof() .And. &(vVETCHIS[nVE,2]) = Xfilial(vVETCHIS[nVE,1]) .And.;
											&(vVETCHIS[nVE,3]) = cVCOMP

										nREGSTPAT := Recno()
										nVARDIN := NGVARIADT(cVCOMP,&(vVETCHIS[nVE,4]),1,&(vVETCHIS[nVE,6]),.T.,.F.)
										Dbgoto(nREGSTPAT)
										RecLock(vVETCHIS[nVE,1],.F.)
										&(vVETCHIS[nVE,7]) := nVARDIN
										MsUnlock(vVETCHIS[nVE,1])
										dbSkip()
									End

									// atualiza o contador
									dbSelectArea(vVETCHIS[nVE,1])
									Dbgoto(nREGSTPAT)
									If !Eof() .And. &(vVETCHIS[nVE,2]) = Xfilial(vVETCHIS[nVE,1]) .And.;
											&(vVETCHIS[nVE,3]) = cVCOMP
										dbSelectArea(vVETCBEM[nVE,1])
										dbSetOrder(01)
										If dbSeek(xFILIAL(vVETCBEM[nVE,1])+cVCOMP)
											RecLock(vVETCBEM[nVE,1],.F.)
											&(vVETCBEM[nVE,2]) := &(vVETCHIS[nVE,4])
											&(vVETCBEM[nVE,3]) := &(vVETCHIS[nVE,8])
											&(vVETCBEM[nVE,4]) := &(vVETCHIS[nVE,7])
											&(vVETCBEM[nVE,5]) := &(vVETCHIS[nVE,6])
											MsUnlock(vVETCBEM[nVE,1])
										Endif
									Endif
								Endif
							Endif

							// Troca de componente

							If lTROCALC
								// Inclui o componente que entrou na localizacao
								dbSelectArea(cTrbE)
								Dbgotop()
								If Reccount() > 0
									// Procura o lancamento do componente
									nRECRECAT := 0
									dbSelectArea(vVETCHIS[nVE,1])
									dbSetOrder(05)
									dbSeek(xFILIAL(vVETCHIS[nVE,1])+cCOMPTRO+Dtos(dDTMPTRO),.T.)
									If !Eof()
										If &(vVETCHIS[nVE,2]) <> xFILIAL(vVETCHIS[nVE,1]) .Or. &(vVETCHIS[nVE,3]) <> cCOMPTRO
											dbSkip(-1)
										Endif
									ElseIf !Bof()
										If &(vVETCHIS[nVE,2]) <> xFILIAL(vVETCHIS[nVE,1]) .Or. &(vVETCHIS[nVE,3]) <> cCOMPTRO
											dbSkip()
										Endif
									ElseIf Eof()
										dbSkip(-1)
									Endif

									// verifica o lancamento mais proximo do componente no historio
									nRECRECAT := 0
									If &(vVETCHIS[nVE,2]) = xFILIAL(vVETCHIS[nVE,1]) .And. &(vVETCHIS[nVE,3]) = cCOMPTRO
										nRECRECAT := Recno()

										While !Eof() .And. &(vVETCHIS[nVE,2]) = xFILIAL(vVETCHIS[nVE,1]) .And.;
												&(vVETCHIS[nVE,3]) = cCOMPTRO
											If &(vVETCHIS[nVE,4]) > dDTMPTRO
												nRECRECAT := Recno()
												Exit
											ElseIf &(vVETCHIS[nVE,4]) = dDTMPTRO
												If !lENTOEST
													If &(vVETCHIS[nVE,5]) < cHOMPTRO
														nRECRECAT := Recno()
														Exit
													Endif
												ElseIf &(vVETCHIS[nVE,5]) > cHOMPTRO
													nRECRECAT := Recno()
													Exit
												Endif
											Endif
											dbSkip()
										End

										If nRECRECAT > 0
											dbSelectArea(vVETCHIS[nVE,1])
											Dbgoto(nRECRECAT)
											nAUXACUM := &(vVETCHIS[nVE,6])
											nRECRECAT2 := 0
											dbSelectArea(cTrbE)
											While !Eof()
												NGGRAVAHIS(cCOMPTRO,&(vVETCHIS[nVE,10]),&(vVETCHIS[nVE,11]),;
													&(vVETCHIS[nVE,12]),nAUXACUM+(cTrbE)->DIFACUM,;
													&(vVETCHIS[nVE,13]),&(vVETCHIS[nVE,14]),nVE,"C")

												nAUXACUM := &(vVETCHIS[nVE,6])

												If Empty(nRECRECAT2)
													nRECRECAT2 := Recno()
												Endif

												dbSelectArea(cTrbE)
												dbSkip()
											End

											// Recalcula os demais registros
											dbSelectArea(vVETCHIS[nVE,1])
											dbSkip()

											While !Eof() .And. &(vVETCHIS[nVE,2]) = Xfilial(vVETCHIS[nVE,1]);
													.And. &(vVETCHIS[nVE,3]) = cCOMPTRO
												RecLock(vVETCHIS[nVE,1],.F.)
												&(vVETCHIS[nVE,6]) += nTOTDES
												MsUnlock(vVETCHIS[nVE,1])
												dbSkip()
											End

											// recalcula a variacao dia
											Dbgoto(nRECRECAT2)
											While !Eof() .And. &(vVETCHIS[nVE,2]) = Xfilial(vVETCHIS[nVE,1]) .And.;
													&(vVETCHIS[nVE,3]) = cCOMPTRO

												nREGSTPAT := Recno()
												nVARDIN := NGVARIADT(cCOMPTRO,&(vVETCHIS[nVE,4]),1,&(vVETCHIS[nVE,6]),.T.,.F.)
												Dbgoto(nREGSTPAT)
												RecLock(vVETCHIS[nVE,1],.F.)
												&(vVETCHIS[nVE,7]) := nVARDIN
												MsUnlock(vVETCHIS[nVE,1])
												dbSkip()
											End

											// atualiza o contador
											dbSelectArea(vVETCHIS[nVE,1])
											Dbgoto(nREGSTPAT)
											dbSelectArea(vVETCBEM[nVE,1])
											dbSetOrder(01)
											If dbSeek(xFILIAL(vVETCBEM[nVE,1])+cCOMPTRO)
												RecLock(vVETCBEM[nVE,1],.F.)
												&(vVETCBEM[nVE,2]) := &(vVETCHIS[nVE,4])
												&(vVETCBEM[nVE,3]) := &(vVETCHIS[nVE,8])
												&(vVETCBEM[nVE,4]) := &(vVETCHIS[nVE,7])
												&(vVETCBEM[nVE,5]) := &(vVETCHIS[nVE,6])
												MsUnlock(vVETCBEM[nVE,1])
											Endif
										Endif
									Endif
								Endif
								// deleta arquivos temporarios
								oTmpTbl:Delete()
							Endif
						Endif
					Endif
				Endif
			Endif
		Endif
	Next nVE
	RestArea(aAreaco)
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} NGAUTONOMIA
Programa para calcular a autonomia do veiculo.

@author  Evaldo Cevinscki Jr.
@since   04/12/2006
@version p12

@param cBem, Bem para verificar contador, caractere
@param dData, Data do Contador, date
@param cHora, Hora Contador, caractere
@param nPosCont, PosiÁ„o do contador, numÈrico
@param lGetVar, Se Verdadeiro o retorno È lÛgico se n„o retorna Array e n„o mostra mensagens em Tela, lÛgico
@param cCombus, CÛdigo do CombustÌvel, caractere
@param nTIPC, Tipo do contador ( 1/2 ), numÈrico
@param cFiliST9, Filial ST9, caractere
@param lPerg, Perguntar se "Deseja confirmar?", lÛgico

@return LÛgico ou Array, se lGETVAR = .T. retorna LÛgico se n„o retorna aVETRE[1] - lÛgico, aVETRE[2] - mensagem de erro ou nulo
/*/
//-------------------------------------------------------------------
Function NGAUTONOMIA(cBem,dData,cHora,nPosCont,lGetVar,cCombus,nTIPC,cFiliST9, lPerg)

	Local nKmA       := 0
	Local nKmB       := 0
	Local aVETRE     := {}
	Local cMensag    := " "
	Local lReturn    := .T.
	Local aArea      := GetArea()
	Local lMsg       := .F.
	Local lMsgAuton  := .F.
	Local cComb      := IIf(cCombus == Nil,"",cCombus)
	Local nPercAuto  := IIF(Empty(GetNewPar("MV_NGPRAUT"," ")),0,GetNewPar("MV_NGPRAUT"," "))
	Local cAutonomia := SuperGetMV( 'MV_NGAUTON', .F., ' ' )
	Local cMsgAuto   := ''
	Local lBloqAut   := AllTrim(GetNewPar("MV_NGBLQAU","N")) == "1"
	Local nTIPOCO    := IIf(nTIPC = NIL,1,nTIPC)
	Local lCalc      := .F. //Indica se devera ser feito calculo
	Local cPlaca     := ST9->T9_PLACA
	Local cForMd1    := "1"
	Local cForMd2    := "1"
	Local cIncr      := ""

	Default lPerg    := .T.
	Default cFiliST9 := xFilial("ST9")

	/*--------------------------------------------------+
	| 1- N„o realiza consistencia de autonomia.         |
	| 2- Consistir sempre, indifere da rotina.          |
	| 3- Consistir apenas nas rotinas de abastecimento. |
	+--------------------------------------------------*/
	If cAutonomia == '1' .Or. ( cAutonomia == '3' .And. !FWIsInCallStack( 'MNTA635' ) .And.;
		!FWIsInCallStack('MNTA655')	.And. !FWIsInCallStack('MNTA700') .And. !FWIsInCallStack( 'MNTA656' ) )

		If lGetVar

			lReturn := .T.

		Else

			aVETRE := { .T., ' ' }

		EndIf
	
	Else

		/*Se a mensagem nao for mostrada em tela e n„o estiver configurado para bloquear
		a autonomia o retorno sempre ser· verdadeiro*/
		If !lGetVar .And. !lBloqAut
			Return {.T.,' '}
		EndIf

		cData  := SubStr(DTOS(dData),7,2)+"/"+SubStr(DTOS(dData),5,2)+"/"+SubStr(DTOS(dData),3,2)
		aVETRE := {.T.,cMensag}
		cBem   := cBem+(Space(Len(ST9->T9_CODBEM) - Len(cBem)))
		dbSelectArea("SIX")
		dbSetOrder(1)
		If dbSeek("ST9G")
			dbSelectArea("ST9")
			dbSetOrder(1)
			If dbSeek(cFiliST9+cBem)

				While !EoF() .And. cFiliST9 == ST9->T9_FILIAL .And. cBem == ST9->T9_CODBEM
					If ST9->T9_SITBEM == "A"
						If FieldPos('T9_MEDIA') > 0 .And. FieldPos('T9_CAPMAX') > 0
							//Caso tenha transferÍncia localiza a filial do ˙ltimo registro de contador e atualiza o cFiliST9
							dbSelectArea("TQ2")
							dbSetOrder(1)
							If dbSeek(xFilial("TQ2") + cBem) //DtoS(dData) + cHora, .T.)
								cFiliST9 := NGTRANSF(cBem,dData,cHora)
							EndIf

							dbSelectArea("ST6")
							dbSetOrder(1)
							If dbSeek(xFilial("ST6")+ST9->T9_CODFAMI)
								cForMd1 := IIf(!Empty(ST6->T6_MEDIA1),ST6->T6_MEDIA1,cForMd1)
								cForMd2 := IIf(!Empty(ST6->T6_MEDIA2),ST6->T6_MEDIA2,cForMd2)
							EndIf

							vRetApBe := NGACUMEHIS(cBem,dData,cHora,nTIPOCO,"A",cFiliST9,IIf(nTIPOCO = 1,'STP->TP_TIPOLAN = "A" .Or. STP->TP_TIPOLAN = "I"',;
												'TPP->TPP_TIPOLA = "A" .Or. TPP->TPP_TIPOLA = "I"'),.T.,cPlaca)
							nPrimCon := vRetApBe[1] // contador
							nAcumAnB := vRetApBe[2] // acumulado
							nTipLAnB := vRetApBe[7] // lancamento

							vRetApBe := NGACUMEHIS(cBem,dData,cHora,nTIPOCO,"E",cFiliST9,,.F.,cPlaca)
							nAcumAtu := vRetApBe[2]+(nPosCont-vRetApBe[1])
							nKmA     := nAcumAtu-nAcumAnB

							If NGSX2EXIST("TT8")

								lTPCONT   := .F.
								lTPCONT   := NGCADICBASE("TT8_TPCONT","A","TT8",.F.)

								dbSelectArea("TT8")
								dbSetOrder(1)
								If dbSeek(ST9->T9_FILIAL+ST9->T9_CODBEM+cComb)

									If ( TT8->TT8_MEDIA > 0 .Or. TT8->TT8_CAPMAX > 0 ) .And. Empty(cComb)
										nKmB := TT8->TT8_MEDIA * TT8->TT8_CAPMAX
										lCalc := .T.
									EndIf

									While !Eof() .And. TT8->TT8_FILIAL == ST9->T9_FILIAL .And. TT8->TT8_CODBEM == ST9->T9_CODBEM
										If lTPCONT .And. If(!Empty(cComb), AllTrim( TT8->TT8_CODCOM ) == AllTrim( cComb ), .F.) .And.;
										!Empty(TT8->TT8_TPCONT)  .And. TT8->TT8_TPCONT == AllTrim(Str(nTIPOCO)) .And.;
										(TT8->TT8_MEDIA > 0       .Or. TT8->TT8_CAPMAX > 0)
												If nTIPOCO == 1
												nKmB  := IIf(cForMd1 == "1",TT8->TT8_MEDIA * TT8->TT8_CAPMAX,TT8->TT8_CAPMAX / TT8->TT8_MEDIA)
												lCalc := .T.
											Else
												nKmB  := IIf(cForMd2 == "1",TT8->TT8_MEDIA * TT8->TT8_CAPMAX,TT8->TT8_CAPMAX / TT8->TT8_MEDIA)
												lCalc := .T.
											EndIf
										EndIf
										TT8->(dbSkip())
									End

								Else

									If (ST9->T9_MEDIA > 0 .Or. ST9->T9_CAPMAX > 0) .And. nTIPOCO == 1
										nKmB := ST9->T9_MEDIA * ST9->T9_CAPMAX
										lCalc := .T.
									EndIf

								EndIf
							Else

								If (ST9->T9_MEDIA > 0 .Or. ST9->T9_CAPMAX > 0) .And. nTIPOCO == 1
									nKmB := ST9->T9_MEDIA * ST9->T9_CAPMAX
									lCalc := .T.
								EndIf

							EndIf

							If lCalc

								If nKmA >= (nKmB-(nKmB*(nPercAuto/100))) .And. nKmA <= (nKmB+(nKmB*(nPercAuto/100))) .And. nPercAuto != 0
									lMsgAuton := .T.
								Endif

								If nKmA > nKmB  .And. nPrimCon > 0

									If nTipLAnB = "I" .And. lGetVar .And. FunName() $ "MNTA655/MNTA700/MNTA875"
										lMsg := .T.
										If !MsgYesNo(STR0097+AllTrim(Str(nTIPOCO))+CRLF+STR0122,STR0067)// "Essa posiÁ„o do contador superou a autonomia, porÈm È o primeiro abastecimento.Confirma?"//
											lRETURN := .F.
										EndIf
									EndIf

									If !lMsg

										If (nTIPOCO == 1 .And. cForMd1 == "1") .Or. (nTIPOCO == 2 .And. cForMd2 == "1")
											cIncr := STR0098 // "Km Percorrido:   "
										Else
											cIncr := STR0149 // "Horas..........: "
										EndIf

										If lMsgAuton
											cMensag:= STR0097+AllTrim(Str(nTIPOCO))+CRLF+STR0093+CRLF+; // "Essa posiÁ„o do contador superou a autonomia do veÌculo."
													STR0129+"("+AllTrim(Str(nPercAuto))+"%)."+CRLF+; // "Entretanto est· dentro do percentual toler·vel "
													IIF(lPerg, STR0130 + Chr(10), "") + Chr(10)+; // "Deseja confirmar?"
													STR0094+AllTrim((cBem))+Chr(10)+; // "VeÌculo.........: "
													STR0095+(cData)+CRLF+; // "Data..............: "
													STR0096+(cHora)+CRLF+; // "Hora..............: "
													STR0097+AllTrim(Str(nPosCont))+Chr(10)+Chr(10)+; // "Contador.......: "
													AllTrim(cIncr)+' '+AllTrim(Str(nKmA))+CRLF+;
													STR0099+' '+AllTrim(Str(nKmB))+CRLF+; // "Autonomia......:"
													STR0131+AllTrim(Str((nKmB+(nKmB*(nPercAuto/100)))))+CRLF // "Aut. Permitida : "
										Else

											If !lBloqAut
												cMsgAuto := STR0130+Chr(10)+Chr(10) // "Deseja confirmar?"
											Endif

											cMensag := STR0097+AllTrim(Str(nTIPOCO))+CRLF+STR0093+CRLF+; // "Essa posiÁ„o do contador superou a autonomia do veÌculo."
													IIF(lPerg, cMsgAuto, "")+;
													STR0094+AllTrim((cBem))+Chr(10)+; // "VeÌculo.........: "
													STR0095+(cData)+CRLF+; // "Data..............: "
													STR0096+(cHora)+CRLF+; // "Hora..............: "
													STR0097+AllTrim(Str(nPosCont))+Chr(10)+Chr(10)+; // "Contador.......: "
													AllTrim(cIncr)+' '+AllTrim(Str(nKmA))+CRLF+;
													STR0099+' '+AllTrim(Str(nKmB)) // "Autonomia......:"
										Endif

										aVETRE := {.F.,cMensag}
									EndIf
								EndIf
							EndIf
						EndIf
						Exit
					EndIf

					dbSelectArea("ST9")
					dbSkip()
				End
			EndIf

			If lGETVAR
				If !aVETRE[1]
					lLimiteAut := .F.
					If (!lBloqAut .And. !lMsgAuton) .Or. lMsgAuton
						If !MsgYesNo(aVETRE[2],STR0067)// ###"ATENCAO"
							lRETURN := .F.
						Endif
					Else
						MsgInfo(aVETRE[2],STR0067)// ###"ATENCAO"
						lRETURN := .F.
					Endif
				Endif
				RestArea(aArea)
				Return lRETURN
			Endif
		EndIf

	EndIf

	RestArea(aArea)

Return IIf(lGetVar,lReturn,aVETRE)
/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ NGRETSTP  ≥ Autor ≥ Evaldo Cevinscki Jr. ≥ Data ≥05/12/2006≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Retorna posicao anterior,posterior do contador              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ SigaSGF, MNTA635, MNTA655                                  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Parametro≥cFilFro = Filial do Bem;                                    ≥±±
±±≥          ≥cFrota  = Bem para verificar contador;                      ≥±±
±±≥          ≥dData   = Data do Contador;                                 ≥±±
±±≥          ≥cHora   = Hora Contador;                                    ≥±±
±±≥          ≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥         ATUALIZACOES SOFRIDAS DESDE A CONSTRUÄAO INICIAL.             ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Programador ≥ Data   ≥ F.O  ≥  Motivo da Alteracao                     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥            ≥        ≥      ≥                                          ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function NGRETSTP(cFilFro,cFrota,dData,cHora)
	Local nKmAnt := 0, nKmPos := 0
	Local lKmPos := .T.,cTipLanAnt := " " ,cTipLanPos := ""
	LOcal nKmAtuAcu := 0, nKmAntAcu :=0, nKmPosAcu := 0
	Local lTemAbast := .F.
	Local dDataLeitu := CTOD("  /  /  "),cHoraLeitu := " "

	cAliasQry := "KMTQN"

	cQuery := " SELECT TP_FILIAL,TP_CODBEM,TP_TIPOLAN,TP_DTLEITU,TP_HORA,TP_POSCONT,TP_ACUMCON "
	cQuery += " FROM " + RetSQLName("STP")
	cQuery += " WHERE TP_CODBEM = '"+cFROTA+"' "
	cQuery += " AND (TP_TIPOLAN='A') AND D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY TP_CODBEM,TP_DTLEITU,TP_HORA "

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	While !EOF()
		If (cAliasQry)->TP_DTLEITU < dData
			nKmAnt     := (cAliasQry)->TP_POSCONT
			nKmAntAcu  := (cAliasQry)->TP_ACUMCON
			cTipLanAnt := (cAliasQry)->TP_TIPOLAN
			dDataLeitu := STOD((cAliasQry)->TP_DTLEITU)
			cHoraLeitu := (cAliasQry)->TP_HORA
		ElseIF (cAliasQry)->TP_DTLEITU > dData .And. lKmPos
			nKmPos := (cAliasQry)->TP_POSCONT
			nKmPosAcu := (cAliasQry)->TP_ACUMCON
			lKmPos := .F.
			cTipLanPos := (cAliasQry)->TP_TIPOLAN
			dDataLeitu := STOD((cAliasQry)->TP_DTLEITU)
			cHoraLeitu := (cAliasQry)->TP_HORA
		ElseIf (cAliasQry)->TP_DTLEITU == dData .And. (cAliasQry)->TP_HORA > cHora
			nKmPos := (cAliasQry)->TP_POSCONT
			nKmPosAcu := (cAliasQry)->TP_ACUMCON
			lKmPos := .F.
			cTipLanPos := (cAliasQry)->TP_TIPOLAN
			dDataLeitu := STOD((cAliasQry)->TP_DTLEITU)
			cHoraLeitu := (cAliasQry)->TP_HORA
		EndIf
		If (cAliasQry)->TP_DTLEITU == dData .And. (cAliasQry)->TP_HORA < cHora
			nKmAnt := (cAliasQry)->TP_POSCONT
			nKmAntAcu := (cAliasQry)->TP_ACUMCON
			cTipLanAnt := (cAliasQry)->TP_TIPOLAN
			dDataLeitu := STOD((cAliasQry)->TP_DTLEITU)
			cHoraLeitu := (cAliasQry)->TP_HORA
		EndIf
		If (cAliasQry)->TP_DTLEITU == dData .And. (cAliasQry)->TP_HORA == cHora
			nKmAtuAcu := (cAliasQry)->TP_ACUMCON
			nKmAnt := (cAliasQry)->TP_POSCONT
			cTipLanAnt := (cAliasQry)->TP_TIPOLAN
			dDataLeitu := STOD((cAliasQry)->TP_DTLEITU)
			cHoraLeitu := (cAliasQry)->TP_HORA
		EndIf
		If (cAliasQry)->TP_TIPOLAN = "A" .And. !lTemAbast .And. ((cAliasQry)->TP_DTLEITU + (cAliasQry)->TP_HORA) <= dData + cHora
			lTemAbast := .T.
		EndIf
		dbSelectArea(cALIASQRY)
		dbSkip()
	End
	aKms := {nKmAnt,nKmPos,cTipLanPos,nKmAtuAcu,nKmAntAcu,nKmPosAcu,cTipLanAnt,lTemAbast,dDataLeitu,cHoraLeitu}
	(cALIASQRY)->( dbCloseArea() )
Return aKms
/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥NGHISTRETR≥ Autor ≥In†cio Luiz Kolling    ≥ Data ≥13/08/2007≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Consiste se o lancamento do historico/contador Ç retroativo ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥cVBemPe   - C¢digo do bem                    - Obrigatorio  ≥±±
±±≥          ≥dDtaLan   - Data do lancamento               - Obrigotorio  ≥±±
±±≥          ≥cHorLan   - Hora do lancamento               - Obrigotorio  ≥±±
±±≥          ≥nTipoCP   - Tipo do contador ( 1/2 )         - Nao Obrigot. ≥±±
±±≥          ≥cFilPes   - Codigo da filial                 - Nao Obrigat. ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorna   ≥.T.,.F.                                                     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Observacao≥Esta funcao SOMENTE devera ser chamada depois que a funcao  ≥±±
±±≥          ≥NGCHKHISTO retornar verdadeiro (.T.)                        ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function NGHISTRETR(cVBemPe,dDtaLan,cHorLan,nTipoCP,cFilPes)
	Local aAreaAn := GetArea()
	Local nConTip := If(nTipoCP = Nil,1,nTipoCP),lRetLan := .F.
	Local vAliasP := If(nConTip = 1,{'STP','stp->tp_filial','stp->tp_codbem',;
	'stp->tp_dtleitu','stp->tp_hora'},;
	{'TPP','tpp->tpp_filial','tpp->tpp_codbem',;
	'tpp->tpp_dtleit','tpp->tpp_hora'})
	Local cFilBus := NGTROCAFILI(vAliasP[1],cFilPes)

	dbSelectArea(vAliasP[1])
	dbSetOrder(05)
	dbSeek(cFilBus+cVBemPe+Dtos(Date())+'24:00',.T.)
	If Eof()
		dbSkip(-1)
	Else
		If &(vAliasP[2]) <> cFilBus .Or. (&(vAliasP[2]) = cFilBus .And. &(vAliasP[3]) <> cVBemPe)
			dbSkip(-1)
		Endif
	Endif

	If !Bof() .And. &(vAliasP[2]) = cFilBus .And. &(vAliasP[3]) = cVBemPe
		If dDtaLan < &(vAliasP[4])
			lRetLan := .T.
		ElseIf dDtaLan = &(vAliasP[4])
			If cHorLan < &(vAliasP[5])
				lRetLan := .T.
			Endif
		Endif
	Endif
	RestArea(aAreaAn)
Return lRetLan
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥NGREFMOVR ≥ Autor ≥Incaio Luiz Kolling    ≥ Data ≥14/08/2007≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥Processa movimentacoes retroativas dos componentes          ≥±±
±±≥          ≥Somente para modulos folhas                                 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥          ≥cBemPai - Codigo do Bem Pai da Estrutura      - Obrigatorio ≥±±
±±≥Parametros≥vComEnt - Vetor componente que entraram       - Obrigatorio ≥±±
±±≥          ≥vComSai - Vetor componente que sairam         - Obrigatorio ≥±±
±±≥          ≥dDtMov  - Data da Movimentacao                - Obrigatorio ≥±±
±±≥          ≥cHrMov  - Hora da Movimentacao                - Obrigatorio ≥±±
±±≥          ≥cVFilB  - Codigo da Filial de Acesso          - Nao Obrigat.≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥SIGAMNT                                                     ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function NGREFMOVR(cBemPai,vComEnt,vComSai,dDtMov,cHrMov,nPoscont,cVFilB)
	Local lIntPneu := .F.,aAreaMo := GetArea()
	Local dAteData,cAteHora,x := 0,dMaxDtSai,cMaxHoSai,lTemProx := .F.
	Local lPrimAce,nRecStpC,nRegUlSTP

	Local cFilSTP  := NGTROCAFILI("STP",cVFilB)
	Local cFilSTZ  := NGTROCAFILI("STZ",cVFilB)
	Local cFilTQV  := NGTROCAFILI("TQV",cVFilB)
	Local cFilTQZ  := NGTROCAFILI("TQZ",cVFilB)
	Local nDifRet  := 0

	Local nSizeFil	:= If(FindFunction("FWSizeFilial"),FwSizeFilial(),Len(SM0->M0_CODFIL))

	Local oTmpTbl1
	Local oTmpTbl2
	Local oTmpTbl3

	Local cTRBLAN  := GetNextAlias()
	Local cTRBLAN2 := GetNextAlias()
	Local cTRBLAN3 := GetNextAlias()

	Private cFilST9 := NGTROCAFILI("ST9",cVFilB)
	Private cFilTQS := NGTROCAFILI("TQS",cVFilB)

	lRet := SuperGetMv("MV_NGPNEUS",.F.,"N") == "S"
	If lRet
		lIntPneu := .T.
	Endif

	//+----------------------------------------------------------+
	//| Armazena os lancamentos posteriores do bem pai           |
	//+----------------------------------------------------------+

	aDBFAUX := {}
	aAdd(aDBFAUX,{"FILLANC","C", nSizeFil,0})
	aAdd(aDBFAUX,{"BEMLANC","C", 16,0})
	aAdd(aDBFAUX,{"DTALANC","D", 08,0})
	aAdd(aDBFAUX,{"HORLANC","C", 05,0})
	aAdd(aDBFAUX,{"CONLANC","N", 09,0})
	aAdd(aDBFAUX,{"ACULANC","N", 12,0})

	vINDLANT := {"FILLANC","BEMLANC","DTALANC","HORLANC"}
	oTmpTbl1 := FWTemporaryTable():New( cTRBLAN, aDBFAUX )
	oTmpTbl1:AddIndex( "Ind01" , vINDLANT )
	oTmpTbl1:Create()

	aDBFAUX2 := {}
	aAdd(aDBFAUX2,{"FILLANC2","C", nSizeFil,0})
	aAdd(aDBFAUX2,{"BEMLANC2","C", 16,0})
	aAdd(aDBFAUX2,{"DTALANC2","D", 08,0})
	aAdd(aDBFAUX2,{"HORLANC2","C", 05,0})
	aAdd(aDBFAUX2,{"CONLANC2","N", 09,0})
	aAdd(aDBFAUX2,{"ACULANC2","N", 12,0})

	vINDLANT2 := {"FILLANC2","BEMLANC2","DTALANC2","HORLANC2"}
	oTmpTbl2 := FWTemporaryTable():New( cTRBLAN2, aDBFAUX2 )
	oTmpTbl2:AddIndex( "Ind01" , vINDLANT2 )
	oTmpTbl2:Create()

	aDBFAUX3 := {}
	aAdd(aDBFAUX3,{"FILLANC3","C", nSizeFil,0})
	aAdd(aDBFAUX3,{"BEMLANC3","C", 16,0})
	aAdd(aDBFAUX3,{"DTALANC3","D", 08,0})
	aAdd(aDBFAUX3,{"HORLANC3","C", 05,0})
	aAdd(aDBFAUX3,{"CONLANC3","N", 09,0})
	aAdd(aDBFAUX3,{"ACULANC3","N", 12,0})

	vINDLANT3 := {"FILLANC3","BEMLANC3","DTALANC3","HORLANC3"}
	oTmpTbl3 := FWTemporaryTable():New( cTRBLAN3, aDBFAUX3 )
	oTmpTbl3:AddIndex( "Ind01" , vINDLANT3 )
	oTmpTbl3:Create()

	dbSelectArea("STP")
	dbSetOrder(5)
	If dbSeek(cFilSTP+cBemPai+Dtos(dDtMov)+cHrMov)

		For x := 1 To Len(vComSai)
			lTemProx := .F.
			If !Empty(vComSai[x])
				dbSelectArea("STP")
				dbSetOrder(5)
				dbSeek(cFilSTP+vComSai[x]+Dtos(dDtMov)+cHrMov,.T.)
				If !Eof() .And. STP->TP_FILIAL = cFilSTP .And. STP->TP_CODBEM = vComSai[x]
					dAteData  := Ctod('  /  /  ')
					cAteHora  := Space(5)
					dMaxDtSai := dAteData
					cMaxHoSai := cAteHora

					dbSelectArea("STZ")
					dbSetOrder(6)
					If dbSeek(cFilSTZ+cBemPai+vComSai[x]+Dtos(dDtMov)+cHrMov)
						dbSetOrder(2)
						If dbSeek(cFilSTZ+vComSai[x]+Dtos(STZ->TZ_DATAMOV)+"S"+STZ->TZ_HORAENT)
							dMaxDtSai := stz->tz_datasai
							cMaxHoSai := stz->tz_horasai
							dbSkip()
							While !Eof() .And. stz->tz_filial = cFilSTZ .And. stz->tz_codbem = vComSai[x]
								lTemProx := .T.
								If Empty(dAteData)
									dAteData := STZ->TZ_DATAMOV
									cAteHora := STZ->TZ_HORAENT
								Endif
								If stz->tz_datasai >= dMaxDtSai
									dMaxDtSai := stz->tz_datasai
									cMaxHoSai := stz->tz_horasai
								Endif
								dbskip()
							End
						Endif
					Endif

					dbSelectArea("STP")
					Store 0 To nAcumAn,nDifRet,nAcumI,nAcumf,nRegUlSTP
					nRecnoA := Recno()

					dbSelectArea(cTRBLAN)
					RecLock(cTRBLAN,.T.)
					(cTRBLAN)->FILLANC := STP->TP_FILIAL
					(cTRBLAN)->BEMLANC := STP->TP_CODBEM
					(cTRBLAN)->DTALANC := STP->TP_DTLEITU
					(cTRBLAN)->HORLANC := STP->TP_HORA
					(cTRBLAN)->CONLANC := STP->TP_POSCONT
					(cTRBLAN)->ACULANC := STP->TP_ACUMCON
					(cTRBLAN)->(MsUnLock())
					nAcumI := (cTRBLAN)->ACULANC

					dbSelectArea("STP")
					dbskip()

					While !Eof() .and. STP->TP_FILIAL = cFilSTP .and. STP->TP_CODBEM = vComSai[x]
						If Empty(dAteData)
							If lIntPneu
								Dbselectarea("TQV")
								Dbsetorder(1)
								If dbseek(cFilTQV+STP->TP_CODBEM+DtoS(STP->TP_DTLEITU)+STP->TP_HORA)
									RecLock("TQV",.F.)
									dbdelete()
									TQV->(MsUnLock())
								Endif

								Dbselectarea("TQZ")
								Dbsetorder(1)
								If dbseek(cFilTQZ+STP->TP_CODBEM+DtoS(STP->TP_DTLEITU)+STP->TP_HORA)
									RecLock("TQZ",.F.)
									dbdelete()
									TQZ->(MsUnLock())
								Endif
							Endif

							dbSelectArea(cTRBLAN)
							RecLock(cTRBLAN,.T.)
							(cTRBLAN)->FILLANC := STP->TP_FILIAL
							(cTRBLAN)->BEMLANC := STP->TP_CODBEM
							(cTRBLAN)->DTALANC := STP->TP_DTLEITU
							(cTRBLAN)->HORLANC := STP->TP_HORA
							(cTRBLAN)->CONLANC := STP->TP_POSCONT
							(cTRBLAN)->ACULANC := STP->TP_ACUMCON
							(cTRBLAN)->(MsUnLock())

							nAcumf := (cTRBLAN)->ACULANC

							dbSelectArea("STP")
							//--------------------------------
							// Decrementa Km da Banda do pneu
							//--------------------------------
							NGKMTQS(STP->TP_CODBEM,STP->TP_DTLEITU,STP->TP_HORA,.T.)
							RecLock("STP",.F.)
							DbDelete()
							STP->(MsUnLock())

						Else
							lGrava := .F.
							If stp->tp_dtleitu = dAteData .And. stp->tp_hora = cAteHora
								If !lTemProx
									Exit
								Endif
							Endif

							If stp->tp_dtleitu <= dAteData
								If stp->tp_dtleitu < dAteData
									lGrava := .T.
								Else
									If stp->tp_hora < cAteHora
										lGrava := .T.
									Endif
								EndIf

								If lGrava
									If lIntPneu
										Dbselectarea("TQV")
										Dbsetorder(1)
										If dbseek(cFilTQV+STP->TP_CODBEM+DtoS(STP->TP_DTLEITU)+STP->TP_HORA)
											RecLock("TQV",.F.)
											dbdelete()
											TQV->(MsUnLock())
										Endif

										Dbselectarea("TQZ")
										Dbsetorder(1)
										If dbseek(cFilTQZ+STP->TP_CODBEM+DtoS(STP->TP_DTLEITU)+STP->TP_HORA)
											RecLock("TQZ",.F.)
											dbdelete()
											TQZ->(MsUnLock())
										Endif
									Endif

									dbSelectArea(cTRBLAN)
									RecLock(cTRBLAN,.T.)
									(cTRBLAN)->FILLANC := STP->TP_FILIAL
									(cTRBLAN)->BEMLANC := STP->TP_CODBEM
									(cTRBLAN)->DTALANC := STP->TP_DTLEITU
									(cTRBLAN)->HORLANC := STP->TP_HORA
									(cTRBLAN)->CONLANC := STP->TP_POSCONT
									(cTRBLAN)->ACULANC := STP->TP_ACUMCON
									(cTRBLAN)->(MsUnLock())

									nAcumf := (cTRBLAN)->ACULANC

									dbSelectArea("STP")
									//--------------------------------
									// Decrementa Km da Banda do pneu
									//--------------------------------
									NGKMTQS(STP->TP_CODBEM,STP->TP_DTLEITU,STP->TP_HORA,.T.)
									RecLock("STP",.F.)
									DbDelete()
									STP->(MsUnLock())
								Else
									nRegUlSTP := Recno()
								Endif
							Else

								If !lTemProx
									Exit
								Endif

								lGrava2 := .F.
								If !Empty(dMaxDtSai)
									If stp->tp_dtleitu >= dMaxDtSai
										If stp->tp_dtleitu > dMaxDtSai
											lGrava2 := .T.
										Else
											If stp->tp_hora > cMaxHoSai
												lGrava2 := .T.
											Endif
										EndIf
									EndIf

									If lGrava2
										dbSelectArea(cTRBLAN2)
										RecLock(cTRBLAN2,.T.)
										(cTRBLAN2)->FILLANC2 := STP->TP_FILIAL
										(cTRBLAN2)->BEMLANC2 := STP->TP_CODBEM
										(cTRBLAN2)->DTALANC2 := STP->TP_DTLEITU
										(cTRBLAN2)->HORLANC2 := STP->TP_HORA
										(cTRBLAN2)->CONLANC2 := STP->TP_POSCONT
										(cTRBLAN2)->ACULANC2 := STP->TP_ACUMCON
										(cTRBLAN2)->(MsUnLock())
									Endif
								Endif
							Endif
						Endif
						dbSelectArea("STP")
						dbskip()
					End

					nDifRet := nAcumf - nAcumI

					If nDifRet > 0
						dbSelectArea("STP")

						If nRegUlSTP <> 0
							Dbgoto(nRegUlSTP)
						Endif

						While !Eof() .and. STP->TP_FILIAL = cFilSTP .and. STP->TP_CODBEM = vComSai[x]
							nRecnoA := Recno()

							//--------------------------------
							// Decrementa Km da Banda do pneu
							//--------------------------------
							NGKMTQS(STP->TP_CODBEM,STP->TP_DTLEITU,STP->TP_HORA,.T.)

							RecLock("STP",.F.)
							stp->tp_acumcon -= nDifRet
							STP->(MsUnLock())

							//--------------------------------
							// Decrementa Km da Banda do pneu
							//--------------------------------
							NGKMTQS(STP->TP_CODBEM,STP->TP_DTLEITU,STP->TP_HORA)

							dbskip()
						End

						// Retira a diferenca para o segundo processo

						dbSelectArea(cTRBLAN2)
						If dbSeek(cFilSTP+vComSai[x])
							While !Eof() .And. (cTRBLAN2)->BEMLANC2 = vComSai[x]
								RecLock(cTRBLAN2,.F.)
								(cTRBLAN2)->ACULANC2 -= nDifRet
								(cTRBLAN2)->(MsUnLock())
								dbSkip()
							End
						Endif

						//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
						//≥Atualiza o contador do Bem≥
						//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
						If !Empty(nRecnoA)
							Dbselectarea("STP")
							dbgoto(nRecnoA)
							NGREFMST9()
						Endif
					Endif

					// Segundo processo
					If lTemProx
						lPrimAce := .T.
						Store 0 To nRecStpC
						dbSelectArea(cTRBLAN2)
						Dbgotop()
						While !Eof()
							dbSelectArea("STP")
							dbSetOrder(5)
							If dbSeek((cTRBLAN2)->FILLANC2+(cTRBLAN2)->BEMLANC2+Dtos((cTRBLAN2)->DTALANC2)+(cTRBLAN2)->HORLANC2)
								If lPrimAce
									nRecStpA := Recno()
									dbSkip(-1)
									If !Bof() .and. STP->TP_FILIAL = (cTRBLAN2)->FILLANC2 .and. STP->TP_CODBEM = (cTRBLAN2)->BEMLANC2
										nRecStpC := Recno()
										dbSelectArea(cTRBLAN3)
										RecLock(cTRBLAN3,.T.)
										(cTRBLAN3)->FILLANC3 := STP->TP_FILIAL
										(cTRBLAN3)->BEMLANC3 := STP->TP_CODBEM
										(cTRBLAN3)->DTALANC3 := STP->TP_DTLEITU
										(cTRBLAN3)->HORLANC3 := STP->TP_HORA
										(cTRBLAN3)->CONLANC3 := STP->TP_POSCONT
										(cTRBLAN3)->ACULANC3 := STP->TP_ACUMCON
										(cTRBLAN3)->(MsUnLock())
									Endif
									lPrimAce := .F.
									dbSelectArea("STP")
									Dbgoto(nRecStpA)
								Endif

								dbSelectArea("STP")
								//--------------------------------
								// Decrementa Km da Banda do pneu
								//--------------------------------
								NGKMTQS(STP->TP_CODBEM,STP->TP_DTLEITU,STP->TP_HORA,.T.)

								RecLock("STP",.F.)
								DbDelete()
								STP->(MsUnLock())
							Endif
							dbSelectArea(cTRBLAN2)
							dbSkip()
						End

						dbSelectArea(cTRBLAN3)
						Dbgotop()
						While !Eof()
							dbSelectArea(cTRBLAN2)
							RecLock(cTRBLAN2,.T.)
							(cTRBLAN2)->FILLANC2 := (cTRBLAN3)->FILLANC3
							(cTRBLAN2)->BEMLANC2 := (cTRBLAN3)->BEMLANC3
							(cTRBLAN2)->DTALANC2 := (cTRBLAN3)->DTALANC3
							(cTRBLAN2)->HORLANC2 := (cTRBLAN3)->HORLANC3
							(cTRBLAN2)->CONLANC2 := (cTRBLAN3)->CONLANC3
							(cTRBLAN2)->ACULANC2 := (cTRBLAN3)->ACULANC3
							(cTRBLAN2)->(MsUnLock())
							dbSelectArea(cTRBLAN3)
							dbSkip()
						End

						If nRecStpC > 0
							dbSelectArea("STP")
							Dbgoto(nRecStpC)
							NGREFMST9()
						Endif
					Endif
				Endif
			Endif
		Next x

		// Inclui os componentes que entraram
		For x := 1 To Len(vComSai)
			If !Empty(vComSai[x])
				If !Empty(vComEnt[x])

					// acessar o trb e gravar no STP,ST9....
					dbSelectArea(cTRBLAN)
					Dbsetorder(1)
					If dbSeek(cFilSTP+vComSai[x])
						nDifLan   := (cTRBLAN)->ACULANC
						dDtLanGtp := (cTRBLAN)->DTALANC
						cHoLanGtp := (cTRBLAN)->HORLANC
						dbSkip()
						While !Eof() .And. (cTRBLAN)->FILLANC = cFilSTP .And. (cTRBLAN)->BEMLANC = vComSai[x]

							vRetCoSTP := NGACUMEHIS(vComEnt[x],(cTRBLAN)->DTALANC, (cTRBLAN)->HORLANC,1,"A",cFilSTP)
							nAcumLSTP := vRetCoSTP[2]
							nViradSTP := vRetCoSTP[5]

							nDifELan := (cTRBLAN)->ACULANC-nDifLan
							nNovAcum := nAcumLSTP+nDifELan

							// Calcula a variacao dia

							nVARDIAN := NGVARIADT(vComEnt[x],(cTRBLAN)->DTALANC,1,nNovAcum,.F.,.F.,cFilSTP)

							// grava o novo lancamento

							NGGRAVAHIS(vComEnt[x],(cTRBLAN)->CONLANC,nVARDIAN,(cTRBLAN)->DTALANC,nNovAcum,nViradSTP,(cTRBLAN)->HORLANC,1,"C",cFilSTP,cFilST9)

							NGRECALHIS(vComEnt[x],nDifELan,(cTRBLAN)->CONLANC,(cTRBLAN)->DTALANC,1,.F.,.F.,.T.,nNovAcum,cFilSTP,cFilSTP)

							nDifLan   := (cTRBLAN)->ACULANC
							dDtLanGtp := (cTRBLAN)->DTALANC
							cHoLanGtp := (cTRBLAN)->HORLANC

							dbSelectArea(cTRBLAN)
							dbSkip()
						End
					Endif

					dbSelectArea(cTRBLAN2)
					Dbsetorder(1)

					If dbSeek(cFilSTP+vComSai[x])
						nDifLan   := (cTRBLAN2)->ACULANC2
						dDtLanGtp := (cTRBLAN2)->DTALANC2
						cHoLanGtp := (cTRBLAN2)->HORLANC2
						dbSkip()
						While !Eof() .And. (cTRBLAN2)->FILLANC2 = cFilSTP .And. (cTRBLAN2)->BEMLANC2 = vComSai[x]

							vRetCoSTP := NGACUMEHIS(vComEnt[x],(cTRBLAN2)->DTALANC2, (cTRBLAN2)->HORLANC2,1,"A",cFilSTP)

							nAcumLSTP := vRetCoSTP[2]
							nViradSTP := vRetCoSTP[5]

							nDifELan := (cTRBLAN2)->ACULANC2-nDifLan
							nNovAcum := nAcumLSTP+nDifELan

							// Calcula a variacao dia

							nVARDIAN := NGVARIADT(vComEnt[x],(cTRBLAN2)->DTALANC2,1,nNovAcum,.F.,.F.,cFilSTP)

							// grava o novo lancamento

							NGGRAVAHIS(vComEnt[x],(cTRBLAN2)->CONLANC2,nVARDIAN,(cTRBLAN2)->DTALANC2,nNovAcum,nViradSTP,(cTRBLAN2)->HORLANC2,1,"C",cFilSTP,cFilST9)

							NGRECALHIS(vComEnt[x],nDifELan,(cTRBLAN2)->CONLANC2,(cTRBLAN2)->DTALANC2,1,.F.,.F.,.T.,nNovAcum,cFilSTP,cFilSTP)

							nDifLan   := (cTRBLAN2)->ACULANC2
							dDtLanGtp := (cTRBLAN2)->DTALANC2
							cHoLanGtp := (cTRBLAN2)->HORLANC2

							dbSelectArea(cTRBLAN2)
							dbSkip()
						End
					Endif

				Endif
			Endif
		Next x
	Endif

	oTmpTbl1:Delete()
	oTmpTbl2:Delete()
	oTmpTbl3:Delete()

	RestArea(aAreaMo)
Return .T.
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥NGCHKCINC ≥ Autor ≥Evaldo Cevinscki Jr.   ≥ Data ≥28/08/2007≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Checa se a data e hora de lancamento de contador nao eh     ≥±±
±±≥          ≥menor que a data e hora de inclusao do bem                  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥cVBEM     - C¢digo do bem                      - Obrigatorio≥±±
±±≥          ≥dVDATA    - Data da leitura                    - Obrigat¢rio≥±±
±±≥          ≥nVPOSCONT - Valor do contador                  - Obrigat¢rio≥±±
±±≥          ≥cHORA     - Hora da leitura                    - Obrigat¢rio≥±±
±±≥          ≥nTIPOC    - Tipo do contador ( 1/2 )           - Obrigat¢rio≥±±
±±≥          ≥lGETVAR   - Indica se a sa°da de erro na tela  - Obrigatorio≥±±
±±≥          ≥cFilB     - Filial do bem                      - Nao Obrig. ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorna   ≥ SE lGETVAR = .T.                                           ≥±±
±±≥          ≥    .T. /ou .F.                                             ≥±±
±±≥          ≥ SENAO                                                      ≥±±
±±≥          ≥    aVETOR    Onde:                                         ≥±±
±±≥          ≥    SE  aVETOR[1] = .T.                                     ≥±±
±±≥          ≥        Sem problema                                        ≥±±
±±≥          ≥        aVETOR[2] = Conteudo vazio                          ≥±±
±±≥          ≥    SENAO                                                   ≥±±
±±≥          ≥       Problema                                             ≥±±
±±≥          ≥       aVETOR[2] = Mensagem do problema                     ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function NGCHKCINC(cVBEM,dVDATA,nVPOSCONT,cHORA,nTIPOC,lGETVAR,cFilB)
	Local aVETOR := {}
	Local lRETHIS := .T.
	Local cMENSA := " "
	Local vARQHI := If(nTIPOC = 1,{'STP','stp->tp_filial','stp->tp_dtleitu',;
		'stp->tp_hora','stp->tp_poscont','stp->tp_codbem'},;
		{'TPP','tpp->tpp_filial','tpp->tpp_dtleit',;
		'tpp->tpp_hora','tpp->tpp_poscon','tpp->tpp_codbem'})
	dbselectArea(vARQHI[1])
	dbsetorder(8)
	If dbseek(cFilB+cVBEM+"I")
		cData := SubStr(DTOS(&(vARQHI[3])),7,2)+"/"+SubStr(DTOS(&(vARQHI[3])),5,2)+"/"+SubStr(DTOS(&(vARQHI[3])),3,2)
		If &(vARQHI[3]) == dVData
			If &(vARQHI[4]) > cHora
				cMENSA := STR0123 + CRLF+; //"Hor·rio de lanÁamento È inferior ao informado na inclus„o do Contador no Bem."
				STR0124 + cData+CRLF+; //"Inclus„o: "
				STR0125 + &(vARQHI[4])+CRLF //"Hora......: "
				lRETHIS   := .F.
			EndIf
		ElseIf &(vARQHI[3]) > dVData
			cMENSA := STR0126 + CRLF+; //"Hor·rio e Data de lanÁamento s„o inferiores ao informado na inclus„o do Contador no Bem."
			STR0124 + cData+CRLF+; //"Inclus„o: "
			STR0125 + &(vARQHI[4])+CRLF //"Hora......: "
			lRETHIS := .F.
		EndIf
	EndIf
	aVETOR := {lRETHIS,cMENSA}

Return aVetor
/*/
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
	±±≥Funcao    ≥NGUltConBom≥ Autor ≥Vitor Emanuel Batista ≥ Data ≥09/09/2009≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥Descricao ≥ Retorna a ultima posicao para o contador da bomba, ficando ≥±±
	±±≥          ≥ TTV setado no registro.                                    ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥Parametros≥ cPosto  - TTV_POSTO                            -Obrigatorio≥±±
	±±≥          ≥ cLoja   - TTV_LOJA                             -Obrigatorio≥±±
	±±≥          ≥ cTanque - TTV_TANQUE                           -Obrigatorio≥±±
	±±≥          ≥ cBomba  - TTV_BOMBA                            -Obrigatorio≥±±
	±±≥          ≥ cData   - TTV_DATA                                         ≥±±
	±±≥          ≥ cHora   - TTV_HORA                                         ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥Retorno   ≥ nPosCon - Posicao do contador da bomba                     ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥ Uso      ≥SIGAMNT                                                     ≥±±
	±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function NGUltConBom(cPosto,cLoja,cTanque,cBomba,dData,cHora,_cNABAST,lAntAtual)
	Local aArea := GetArea()
	Local nPosCon   := 0
	Local cAliasQry := GetNextAlias()
	Local cQuery
	Local cFullName := NGRetX2("TTV")
	Default lAntAtual := .F.//Indica se considera sinal de = na query com data+hora

	//Coloca tabela TTV em Eof
	NGSETIFARQUI("TTV","F",1)

	cQuery := " SELECT TTV1.R_E_C_N_O_ AS TTV_RECNO FROM " + cFullName + " TTV1 "
	cQuery += " 	WHERE (TTV1.TTV_DATA||TTV1.TTV_HORA) = (SELECT MAX(TTV2.TTV_DATA||TTV2.TTV_HORA) FROM "+ cFullName + " TTV2"
	cQuery += " 		WHERE TTV2.TTV_POSTO = " + ValToSql(cPosto)
	cQuery += " 		   AND TTV2.TTV_LOJA = " + ValToSql(cLoja)
	cQuery += " 		   AND TTV2.TTV_TANQUE = " + ValToSql(cTanque)
	cQuery += " 		   AND TTV2.TTV_BOMBA = " + ValToSql(cBomba)

	If ValType(dData) = "D" .And. ValType(cHora) = "C"
		cQuery += "			AND TTV2.TTV_DATA||TTV2.TTV_HORA "
		If lAntAtual
			cQuery += " < "
		Else
			cQuery += " <= "
		Endif
		cQuery += ValToSql(DTOS(dData)+cHora)
	EndIf
	If ValType(_cNABAST) == "C"
		cQuery += "			AND TTV2.TTV_NABAST NOT IN (" + _cNABAST + ")"
	Endif
	cQuery += " 			AND TTV2.TTV_FILIAL = '"+xFilial("TTV")+"' AND TTV2.D_E_L_E_T_ = '')"
	cQuery += "		AND TTV1.TTV_POSTO = "+ValToSql(cPosto)
	cQuery += "		AND TTV1.TTV_LOJA = "+ValToSql(cLoja)
	cQuery += "		AND TTV1.TTV_TANQUE = "+ValToSql(cTanque)
	cQuery += "		AND TTV1.TTV_BOMBA = "+ValToSql(cBomba)
	cQuery += "		AND TTV1.TTV_FILIAL = '"+xFilial("TTV")+"' AND TTV1.D_E_L_E_T_ = ''"
	If ValType(_cNABAST) == "C"
		cQuery += "		AND TTV1.TTV_NABAST NOT IN (" + _cNABAST + ")"
	Endif
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	dbSelectArea(cAliasQry)
	dbGoTop()
	If !Eof()
		TTV->(dbGoTo((cAliasQry)->(TTV_RECNO)))
		nPosCon := TTV->TTV_POSFIM
	EndIf
	(cAliasQry)->(dbCloseArea())
	RestArea(aArea)
Return nPosCon

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIncTTV
Inclui na TTV novo registro

@param cPosto, caractere, Codigo do Posto                                         
@param cLoja, caractere, Codigo da Loja do Posto                                 
@param cTanque, caractere, Codigo do Tanque do Posto                               
@param cBomba, caractere, Codigo da Bomba do Tanque                               
@param cData, caractere, Data da ocorrencia                                      
@param cHora, caractere, Hora da ocorrencia                                      
@param cTipoLan, caractere, Tipo de Lancamento 1=Manual/2=Lote                      
@param nPosCon, numerico, Posicao do contador da bomba na data/hora
@param nQuanti, numerico, Quantidade a ser incrementada no ultimo Contador
@param cNAbast, caractere, Numero do abastecimento                                 
@param cNumDoc, caractere, Numero do documento de saida                            
@param cSerieDoc, caractere, Serie do documento de saida                             
@param lSaiComb, logico, Indica se o processo realizado È saÌda de combustÌvel   

@author Vitor Emanuel Batista
@since 09/09/2009
@version MP12
@return LÛgico
/*/
//---------------------------------------------------------------------
Function NGIncTTV( cPosto, cLoja, cTanque, cBomba, dData, cHora, cTipoLa, nPosCon, nQuanti, cNAbast, cNumDoc, cSerieDoc, lSaiComb )
	Local cMotivo   := "1"
	Local nAcumCo   := 0
	Local nUltPos   := 0
	Local aAreaTTV  := {}
	Local cFilTTA   := xFilial( 'TTA' )
	Local cFilTQN   := xFilial( 'TQN' )

	//Se nao existe a tabela TTV, retorna
	If !AliasInDic("TTV")
		Return
	EndIf

	Default cNAbast   := Space(Len(TQN->TQN_NABAST))
	Default cNumDoc   := Space(Len(SF2->F2_DOC))
	Default cSerieDoc := Space(Len(SF2->F2_SERIE))
	Default lSaiComb  := .F.

	//Se for diferente de posto interno
	dbSelectArea("TQF")
	dbSetOrder(1)
	dbSeek(xFilial("TQF")+cPosto+cLoja)
	If TQF->TQF_TIPPOS != '2'
		Return .F.
	EndIf

	dbSelectArea("TQJ")
	dbSetOrder(1)
	If dbSeek(xFilial("TQJ")+cPosto+cLoja+cTanque+cBomba)
		//Retorna ultima posicao do contador da Bomba
		nUltPos := NGUltConBom(cPosto,cLoja,cTanque,cBomba,dData,cHora)
		nAcumCo := TTV->TTV_ACUMCO

		If ValType(nPosCon) != "N"
			//Se nao for informado a posicao do contador da bomba, soma com a quantidade
			nPosCon := nUltPos + nQuanti
		ElseIf nPosCon < nUltPos //Verifica se havera uma virada
			cMotivo := "2" //Virada
		EndIf

		//Verifica se havera uma virada
		If nPosCon > TQJ->TQJ_LIMCON
			cMotivo := "2" //Virada
			nPosCon -= TQJ->TQJ_LIMCON
			nQuanti := (TQJ->TQJ_LIMCON - nUltPos) + nPosCon
		EndIf

		If ValType(nQuanti) != "N"
			nQuanti := nPosCon - nUltPos //If(cMotivo=="1",nPosCon - nUltPos,nPosCon)
		EndIf

		dbSelectArea("TTV")
		dbSetOrder(1)
		If !dbSeek(xFilial("TTV")+cPosto+cLoja+cTanque+cBomba+DTOS(dData)+cHora+cNAbast)
			RecLock("TTV",.T.)
			TTV->TTV_FILIAL := xFilial("TTV")
			TTV->TTV_POSTO  := cPosto
			TTV->TTV_LOJA   := cLoja
			TTV->TTV_TANQUE := cTanque
			TTV->TTV_BOMBA  := cBomba
			TTV->TTV_DATA   := dData
			TTV->TTV_HORA   := cHora
			TTV->TTV_POSINI := nUltPos
			TTV->TTV_POSFIM := nPosCon
			TTV->TTV_MOTIVO := cMotivo
			TTV->TTV_ACUMCO := nAcumCo + nQuanti
			TTV->TTV_CONSUM := nQuanti
			TTV->TTV_TIPOLA := cTipoLa
			TTV->TTV_USUARI := RetCodUsr()
			TTV->TTV_DTINCL := dDataBase
			TTV->TTV_HRINCL := Time()
			TTV->TTV_NABAST := cNAbast
			If !Empty(cNumDoc) .And. NGCADICBASE("TTV_DOC","A","TTV",.F.)
				TTV->TTV_DOC := cNumDoc
				TTV->TTV_SERIE := cSerieDoc
			EndIf
			MsUnLock()
		EndIf

		//Salva posicao do registro incluso
		aAreaTTV := GetArea()

		dbSelectArea("TTV")
		dbSkip()

		If TTV->( !EoF() ) .And. FWxFilial( 'TTV' ) == TTV->TTV_FILIAL .And. TTV->TTV_POSTO == cPosto .And. TTV->TTV_LOJA == cLoja .And.;
			TTV->TTV_TANQUE == cTanque .And. TTV->TTV_BOMBA == cBomba

			// FunÁ„o usada para realizar o rec·lculo dos registros apÛs o incluido na TTV
			NgRecTTV( { cPosto, cLoja, cTanque, cBomba, dData, cHora }, 3 )
			
			If lSaiComb
			
				NgRecTTA( 3, { cPosto, cLoja, cTanque, cBomba, dData, cHora, nQuanti } )
			
			EndIf

		EndIf

		//retorna posicao do registro de incluso
		RestArea(aAreaTTV)
		
	EndIf

Return

/*/
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
	±±≥Funcao    ≥ NGDelTTV  ≥ Autor ≥Vitor Emanuel Batista ≥ Data ≥09/09/2009≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥Descricao ≥ Exclui registro da TTV                                     ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥Observ.   ≥ O Alias() devera estar na TTV, posicionado  no registro a  ≥±±
	±±≥          ≥ ser deletado                                               ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥ Uso      ≥SIGAMNT                                                     ≥±±
	±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function NGDelTTV()
	Local cPosto    := TTV->TTV_POSTO
	Local cLoja     := TTV->TTV_LOJA
	Local cTanque   := TTV->TTV_TANQUE
	Local cBomba    := TTV->TTV_BOMBA
	Local nQuanti   := TTV->TTV_CONSUM
	Local dData     := TTV->TTV_DATA
	Local cHora     := TTV->TTV_HORA

	dbSelectArea("TQJ")
	dbSetOrder(1)
	If dbSeek(xFilial("TQJ")+cPosto+cLoja+cTanque+cBomba)
		dbSelectArea("TTV")
		dbSetOrder(1)
		RecLock("TTV",.F.)
		dbDelete()
		MsUnLock()

		// FunÁ„o usada para realizar o rec·lculo dos registros apÛs o deletado na TTV
		NgRecTTV( { cPosto, cLoja, cTanque, cBomba, dData, cHora, nQuanti }, 5 )
	
	EndIf
	
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NGAltTTVQnt
Altera Consumo em um registro da TTV

@type Function

@author Vitor Emanuel Batista
@since 09/09/2009

@Param cPosto,    caractere, Codigo do Posto 
@Param cLoja,     caractere, Codigo da Loja do Posto
@Param cTanque,   caractere, Codigo do Tanque do Posto 
@Param cBomba,    caractere, Codigo da Bomba do Tanque
@Param cData,     caractere, Data da ocorrencia 
@Param cHora,     caractere, Hora da ocorrencia 
@Param nQuanti,   numerico,  Quantidade a ser incrementada no ultimo Contador 
@Param nQuantAnt, numerico,  Quantidade antes da alteraÁ„o
@Param lSaiComb,  logica,    Indica se a operaÁ„o realizada È SaÌda de CombustÌvel

/*/
//------------------------------------------------------------------------------
Function NGAltTTVQnt(cPosto,cLoja,cTanque,cBomba,dData,cHora,cTipoLa,nQuanti,nQuantAnt, lSaiComb)
	
	Local nOldQuant, nContIni
	Local lFirst := .T.
	Default lSaiComb := .F.

	If AliasInDic("TTV")
		nContIni  := NGUltConBom(cPosto,cLoja,cTanque,cBomba,dData,cHora,,.T.)
		dbSelectArea("TQJ")
		dbSetOrder(1)
		If dbSeek(xFilial("TQJ")+cPosto+cLoja+cTanque+cBomba)
			dbSelectArea("TTV")
			dbSetOrder(1)
			If dbSeek(xFilial("TTV")+cPosto+cLoja+cTanque+cBomba+DtoS(dData)+cHora) .And. nQuanti <> TTV->TTV_CONSUM
				
				nOldQuant := TTV->TTV_CONSUM

				cMotivo := Nil

				RecLock("TTV",.F.)
				
				TTV->TTV_CONSUM := nQuanti
				TTV->TTV_POSINI := nContIni

				nQuanti -= nOldQuant

				TTV->TTV_ACUMCO += nQuanti
				
				//Se a quantidade a ser diminuida eh maior que o contador
				If !lFirst
					If (TTV->TTV_POSINI + nQuanti) < 0
						cMotivo := TTV->TTV_MOTIVO
						TTV->TTV_POSINI := TQJ->TQJ_LIMCON + (nQuanti + TTV->TTV_POSINI)
						TTV->TTV_MOTIVO  := "1"
					ElseIf (TTV->TTV_POSINI + nQuanti) > TQJ->TQJ_LIMCON //Indica se havera uma virada
						TTV->TTV_POSINI := (TTV->TTV_POSINI + nQuanti) - TQJ->TQJ_LIMCON
						TTV->TTV_MOTIVO  := "2"
					Else
						If cMotivo != Nil
							TTV->TTV_MOTIVO := cMotivo
							cMotivo := Nil
						EndIf
						TTV->TTV_POSINI += nQuanti
					EndIf
				Endif
				If (TTV->TTV_POSFIM + nQuanti) < 0
					cMotivo := If(Empty(cMotivo),TTV->TTV_MOTIVO,cMotivo)
					TTV->TTV_POSFIM := TQJ->TQJ_LIMCON + (nQuanti + TTV->TTV_POSFIM)
					TTV->TTV_MOTIVO := "1"
				ElseIf (TTV->TTV_POSFIM + nQuanti) > TQJ->TQJ_LIMCON //Indica se havera uma virada
					TTV->TTV_POSFIM := (TTV->TTV_POSFIM + nQuanti) - TQJ->TQJ_LIMCON
					TTV->TTV_MOTIVO := "2"
				Else
					If cMotivo != Nil
						TTV->TTV_MOTIVO := cMotivo
						cMotivo := Nil
					EndIf
					TTV->TTV_POSFIM += nQuanti
				EndIf

				MsUnLock()

				// FunÁ„o usada para realizar o rec·lculo dos registros apÛs o alterado na TTV
				NgRecTTV( { cPosto, cLoja, cTanque, cBomba, dData, cHora, TTV->TTV_CONSUM }, 4 )
				
				If lSaiComb
			
					NgRecTTA( 4, { cPosto, cLoja, cTanque, cBomba, dData, cHora, TTV->TTV_CONSUM, nQuantAnt } )
			
				EndIf
			
			EndIf
		EndIf
	EndIf

Return
/*/
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
	±±≥FunáÖo    ≥NGCHKLIMVAR≥ Autor ≥In†cio Luiz Kolling    ≥ Data ≥05/08/2010≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥DescriáÖo ≥Validacao do limite da variacao dia                          ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥Parametros≥cVBEM     - C¢digo do bem                       - Obrigatorio≥±±
	±±≥          ≥cFAMI     - Codigo da familia                   - Obrigat¢rio≥±±
	±±≥          ≥nTIPOC    - Tipo do contador                    - Obrigat¢rio≥±±
	±±≥          ≥nVarDC    - Variacao dia                        - Obrigat¢rio≥±±
	±±≥          ≥lSAIDA    - Indica mostra mensagem via tela     - Obrigat¢rio≥±±
	±±≥          ≥lDicion   - Indica se e chamada pelo dicinario  - Nao Obriga.≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥Retorna   ≥.T.,.F. ou um vetor de acordo ao lDicion                     ≥±±
	±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function NGCHKLIMVAR(cVBEM,cFAMI,nTIPOC,nVarDC,lSAIDA,lDicion)
	Local vRetLimL := {.T.,Space(1)}, lVDicion := If(lDicion = Nil,.F.,lDicion)
	If NGIFDBSEEK("ST6",cFAMI,1) .And. (NGCADICBASE("T6_VARDIA1","A","ST6",.F.);
			.Or. NGCADICBASE("T6_VARDIA2","A","ST6",.F.))
		If nTIPOC = 1
			If !Empty(ST6->T6_VARDIA1) .And. nVarDC > ST6->T6_VARDIA1
				vRetLimL[1] := .F.
			EndIf
		Else
			If !Empty(ST6->T6_VARDIA2) .And. nVarDC > ST6->T6_VARDIA2
				vRetLimL[1] := .F.
			EndIf
		EndiF
	Endif
	If !vRetLimL[1]
		vRetLimL[2] := STR0135+CRLF+CRLF;
			+STR0136+cVbem+CRLF;
			+STR0137+cFAMI+CRLF;
			+STR0138+Str(nVarDC,6)+CRLF;
			+STR0139+Str(If(nTIPOC = 1,ST6->T6_VARDIA1,ST6->T6_VARDIA2),6)+CRLF;
			+STR0140+If(nTIPOC = 1,"1","2")

		If lSAIDA .Or. lVDicion
			Help(" ",1,STR0044,,vRetLimL[2],4,5)
		EndIf
	EndIf
Return If(lVDicion,vRetLimL[1],vRetLimL)
/*/
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
	±±≥FunáÖo    ≥NGVALABAST  ≥ Autor ≥ Marcos Wagner Junior  ≥ Data ≥28/10/2010≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥DescriáÖo ≥Validacoes do abastecimento                                 ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥Parametros≥                                                            ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥Retorna   ≥.T. ou .F.                                                  ≥±±
	±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function NGVALABAST(cPosto,cLoja,cTanque,cBomba,dData,cHora,_lTemaCols,_lDel)

	Local nI
	Local aOldArea := GetArea()
	Local lRet     := .T.

	If (!Inclui .And. !Altera) .Or. !AliasInDic("TTV")
		Return .T.
	Endif

	If (!_lTemaCols .And. Inclui) .Or. (_lTemaCols .And. aScan(aOldCols,{|x| DtoS(x[nPOSDATAB])+x[nPOSHORAB] == DtoS(aCols[n][nPOSDATAB])+aCols[n][nPOSHORAB] }) == 0)
		cAliasQry := GetNextAlias()

		cQuery := " SELECT 1 "
		cQuery += "   FROM " + RetSQLName("TTV")
		cQuery += "  WHERE TTV_FILIAL = " + ValToSql(xFilial("TTV"))
		cQuery += "    AND TTV_POSTO  = " + ValToSql(cPosto)
		cQuery += "    AND TTV_LOJA   = " + ValToSql(cLoja)
		cQuery += "    AND TTV_TANQUE = " + ValToSql(cTanque)
		cQuery += "    AND TTV_BOMBA  = " + ValToSql(cBomba)
		cQuery += "    AND TTV_DATA   = " + ValToSql(DTOS(dData))
		cQuery += "    AND TTV_HORA   = " + ValToSql(cHora)
		cQuery += "    AND D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

		dbSelectArea(cAliasQry)
		dbGoTop()
		If !Eof()
			lRet := .F.
		EndIf
		(cAliasQry)->(dbCloseArea())
	Endif

	//valida para nao permitir abastecimentos com mesma data e hora
	If IsInCallStack("MNTA656")
		If lRet .And. _lTemaCols
			For nI := 1 to Len(aCols)
				If !aCols[nI][Len(aCols[nI])] .And. nI != n .And. (_lDel .Or. !aCols[n][Len(aCols[n])])
					If DTOS(aCols[nI][nPOSDATAB])+aCols[nI][nPOSHORAB] == DTOS(dData)+cHora
						lRet := .F.
						Exit
					Endif
				Endif
			Next
		ElseIf _lTemaCols
			For nI := 1 to Len(aCols)
				If nI != n .And. DTOS(aCols[nI][nPOSDATAB])+aCols[nI][nPOSHORAB] == DTOS(dData)+cHora
					If aCols[nI][Len(aCols[nI])]
						lRet := .T.
					Else
						lRet := .F.
						Exit
					EndIf
				Endif
			Next
		Endif
	EndIf

	If !lRet

        Help( NIL, 1, STR0067, NIL, STR0141+CRLF+CRLF+STR0142+cPosto+CRLF+;
		STR0143+cLoja+CRLF+STR0144+cTanque+CRLF+STR0145+cBomba+CRLF+;
		STR0146+DTOC(dData)+CRLF+STR0147+cHora, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0031} ) // "ATENCAO"###"J· existe um lanÁamento com essas caracterÌsticas:"
																						   // "Posto:"###"Loja:"###"Tanque:"###"Bomba:"###"Data:"###"Hora:"
	Endif

	RestArea(aOldArea)

Return lRet

//----------------------------------------------------------------
/*/{Protheus.doc} NGKMTQS
FunÁ„o que incrementa ou decrementa o KM para um Pneu, de
acordo com um registro na STP ou par‚metro nKmDif

@param cPneu, string, CÛdigo do Pneu
@param dData, date, Data da leitura do contador
@param cHora, string, Hora da leitura do contador
@param lDel, boolean, Indica se operaÁ„o È exclus„o, decrementando o TQS
@param nKmDif, numÈrico, DiferenÁa de contador para o registro atual

@author Vitor Emanuel Batista
@since 15/06/2011

@return nil
/*/
//----------------------------------------------------------------
Function NGKMTQS(cPneu,dData,cHora,lDel,nKmDif)
	Local aArea := GetArea()
	Local aAreaSTP := STP->(GetArea())
	Local aAreaST9 := ST9->(GetArea())
	Local aAreaTQS := TQS->(GetArea())
	Local cAliaTQV := GetNextAlias()

	Local cTipoLan := ""

	Local nKmAtu := 0 //Km Atual
	Local nKmAnt := 0 //Km Anterior
	Local cVida  := "1" //Vida que ser· incrementada
	Local nVida  := 0  //Vida que ser· incrementada
	Local aBanda := {	{"1","TQS->TQS_KMOR"},; //Array contendo valor do campo TQS_BANDAA
	{"2","TQS->TQS_KMR1"},; //com o seu respectivo campo de Contador
	{"3","TQS->TQS_KMR2"},;
		{"4","TQS->TQS_KMR3"},;
		{"5","TQS->TQS_KMR4"},;
		{"6","TQS->TQS_KMR5"},;
		{"7","TQS->TQS_KMR6"},;
		{"8","TQS->TQS_KMR7"},;
		{"9","TQS->TQS_KMR8"},;
		{"A","TQS->TQS_KMR9"}}
	Local nATRefer := 6 // A partir de qual caracter, se cortar a string, fica somente o campo. Exmeplo: "TQS->TQS_KMOR" => SubStr("TQS->TQS_KMOR",nATRefer) => "TQS_KMOR"

	//--------------------------------------------------------
	// Indifica se a operaÁ„o È exclus„o, decrementando o TQS
	//--------------------------------------------------------
	Default lDel   := .F.

	//---------------------------------------
	// DiferenÁa de contador para a operaÁ„o
	//---------------------------------------
	Default nKmDif := 0

	//--------------------------------------------------------
	// Verifica se Ambiente possui TQS e Bem informado È Pneu
	//--------------------------------------------------------
	dbSelectArea("ST9")
	dbSetOrder(1)
	If !AliasInDic("TQS") .Or. !dbSeek(xFilial("ST9")+cPneu) .Or. ST9->T9_CATBEM != '3'
		RestArea(aAreaST9)
		RestArea(aArea)
		Return
	EndIf

	//--------------------------------------------------------
	// Pega Contador Acumulado pelo Bem+Data+Hora informado
	//--------------------------------------------------------
	dbSelectArea("STP")
	dbSetOrder(5)
	dbSeek(xFilial("STP")+cPneu+DTOS(dData)+cHora)
	nKmAtu   := STP->TP_ACUMCON
	cTipoLan := STP->TP_TIPOLAN

	If Empty(nKmDif)
		
		//Se for o contador de inclusoa o Km anterior sera o mesmo
		If cTipoLan == "I"
			nKmAnt := STP->TP_ACUMCON
		EndIf
		//------------------------------------------------------------
		// Pega contador anterior ao informado para fazer a diferenÁa
		//------------------------------------------------------------
		dbSkip(-1)
		If xFilial("STP") == STP->TP_FILIAL .And. STP->TP_CODBEM == cPneu
			nKmAnt := STP->TP_ACUMCON
		EndIf
	
	Else

		nKmAnt := nKmAtu - nKmDif

	EndIf

	//---------------------------------------------------------------
	// Identifica qual Vida que o pneu estava na Data+Hora informada
	//---------------------------------------------------------------
	BeginSql Alias cAliaTQV
		SELECT TQV_BANDA
		FROM %Table:TQV%
		WHERE TQV_CODBEM = %exp:cPneu% AND %NotDel% AND TQV_FILIAL = %xFilial:TQV%
		AND TQV_DTMEDI || TQV_HRMEDI <= %exp:DTOS(dData)+cHora%
		Order by TQV_DTMEDI || TQV_HRMEDI DESC
	EndSql

	If (cAliaTQV)->(!Eof())
		cVida	:= (cAliaTQV)->TQV_BANDA
	EndIf

	(cAliaTQV)->(dbCloseArea())

	nVida := aScan(aBanda,{|x| x[1] == cVida})

	//------------------------------------------------------------
	// Se o Contador Anterior for o mesmo que o informado n„o È
	// necess·rio incrementar TQS pois ela j· foi incrementada
	//------------------------------------------------------------
	If nKmAtu == nKmAnt

		//--------------------------------------------------------------
		// Caso o registro de entrada na estrutura for alterada dever·
		// ser incrementado ou decrementado o contador final da banda
		//--------------------------------------------------------------
		If !lDel .And. nVida > 0
			dbSelectArea("STZ")
			dbSetOrder(2)
			If dbSeek(xFilial("STZ")+cPneu+DTOS(dData)+"E"+cHora) .Or. dbSeek(xFilial("STZ")+cPneu+DTOS(dData)+"S"+cHora) .Or. cTipoLan == "Q"

				//-----------------------------------------------------------------
				// Decrementa caso seja positivo ou incrementa caso seja negativo
				//-----------------------------------------------------------------
				nKmDif *= -1

				// Se o campo existir, executa
				If NGCADICBASE(SubStr(aBanda[nVida][2],nATRefer), "A", "TQS", .F.)
					dbSelectArea("TQS")
					dbSetOrder(1)
					If dbSeek(xFilial("TQS")+cPneu)
						RecLock("TQS",.F.)
						If (&(aBanda[nVida][2]) + nKmDif) < 0
							&(aBanda[nVida][2]) := 0
						Else
							&(aBanda[nVida][2]) += nKmDif
						EndIf
						MsUnLock()
					EndIf
				EndIf

			EndIf

		EndIf

		RestArea(aAreaSTP)
		RestArea(aAreaST9)
		RestArea(aArea)
		Return
	EndIf

	//-------------------------------------------
	// DiferanÁa do KM Atual para o Anterior
	//-------------------------------------------
	nKmDif := nKmAtu - nKmAnt

	//----------------------------------------------------------------
	// Verifica se Contador È o ˙ltimo informado
	// Quando n„o È o ˙ltimo verifica se deve incrementar a banda
	//----------------------------------------------------------------
	dbSelectArea("STP")
	dbSkip(2)

	If xFilial("STP") == STP->TP_FILIAL .And. STP->TP_CODBEM == cPneu .And. ;
			!fIncrement( cPneu, dData, cHora, cTipoLan, STP->TP_DTLEITU, STP->TP_HORA, STP->TP_TIPOLAN  )
		RestArea(aAreaSTP)
		RestArea(aAreaST9)
		RestArea(aArea)
		Return

	EndIf

	If nKmDif <> 0

		If nVida > 0

			//-----------------------------------------------
			// Se a operaÁ„o È exclus„o, decrementando o TQS
			//-----------------------------------------------
			If lDel
				nKmDif *= -1
			EndIf

			// Se o campo existir, executa
			If NGCADICBASE(SubStr(aBanda[nVida][2],nATRefer), "A", "TQS", .F.)
				dbSelectArea("TQS")
				dbSetOrder(1)
				If dbSeek(xFilial("TQS")+cPneu)
					RecLock("TQS",.F.)
					If (&(aBanda[nVida][2]) + nKmDif) < 0
						&(aBanda[nVida][2]) := 0
					Else
						&(aBanda[nVida][2]) += nKmDif
					EndIf

					MsUnLock()
				EndIf
			EndIf
		EndIf

	EndIf

	//----------------------------------------------------------------------------------------------------
	// Ponto de Entrada para realizar algum processo especÌfico para a Banda ou mesmo o histÛrico
	//----------------------------------------------------------------------------------------------------
	If ExistBlock("NGKMTQS1")
		ExecBlock("NGKMTQS1", .F., .F., cPneu, cVida, nKmAtu, nKmAnt, nKmDif, cTipoLan, lDel)
	EndIf

	RestArea(aAreaSTP)
	RestArea(aAreaST9)
	RestArea(aAreaTQS)
	RestArea(aArea)
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} NGMARKSUSP
Valida eixo suspenso
@author Marcos Wagner Junior
@since 13/04/2011
@version undefined
@param _cTpCont, characters, Tipo de contador, primeiro ou segundo
@para  [aTrbEst] , Array   , Array possuindo as tabelas tempor·rias responsavel por montar a estrutura do bem.
							[1] tabela temporaria do pai da estrutura - cTRBS
							[2] tabela temporaria do pai da estrutura - cTRBF
							[3] tabela temporaria do eixo suspenso    - CTRBEixo

@type function
/*/
//---------------------------------------------------------------------
Function NGMARKSUSP(_cTpCont ,aTrbEst)

	Local aOldArea	:= GetArea()
	Local aTRB      := {}
	Local cMarca    := GetMark()
	Local lCriaTela := .F.
	Local lTemTRB   := .F.
	Local lInverte  := .F.
	Local nOpcOK	:= 0
	Local oDlg1
	Local oTmpTbl
	Local nI

	Private aDBF 	:= {}


	Default aTrbEst := {}

	lTemTRB := Len(aTrbEst) > 2

	If !lTemTRB
		aDBF 	:= {{"OK"    , "C", 02, 0},;
			{"EIXO"  , "C", 10, 0},;
			{"DESCRI", "C", 20, 0}}

		vIND := {"EIXO"}
		// Cria arquivos temporarios
		cTRBP := GetNextAlias()
		oTmpTbl := FWTemporaryTable():New( cTRBP, aDBF )
		oTmpTbl:AddIndex( "Ind01" , vIND )
		oTmpTbl:Create()
	Else
		cTRBP := aTrbEst[3]
	EndIf

	If NGIFDBSEEK("TQ1",cFamiPai+cTipMPai,1)
		While !Eof() .And. xFilial("TQ1") == TQ1->TQ1_FILIAL .And. cFamiPai == TQ1->TQ1_DESENH .And. cTipMPai == TQ1->TQ1_TIPMOD
			If TQ1->TQ1_SUSPEN == '1'
				lCriaTela := .T.
				dbSelectArea(cTRBP)
				RecLock(cTRBP,.T.)
				(cTRBP)->EIXO   := TQ1->TQ1_EIXO
				(cTRBP)->DESCRI := "Eixo: "+AllTrim(TQ1->TQ1_EIXO)
				(cTRBP)->(MsUnLock())
			Endif
			dbSelectArea("TQ1")
			dbSkip()
		End
		dbSelectArea(cTRBP)
		dbGoTop()
	Endif

	If lCriaTela

		aAdd( aTRB, { 'OK'     , NIL, ' '    , } )
		aAdd( aTRB, { 'DESCRI' , NIL, STR0160, } ) // "Eixo Suspenso:"

		Define MsDialog oDlg1 Title STR0148+_cTpCont From 300,120 To 480,640 Of oMainWnd Pixel COLOR CLR_BLACK //"Indique os eixos suspensos que n„o ter„o reporte de contador "

		oPanel := TPanel():New(0, 0, Nil, oDlg1, Nil, .T., .F., Nil, Nil, 0,70, .T., .F. )
		oPanel:Align := CONTROL_ALIGN_ALLCLIENT

		oMarkBrow := MsSelect():New(cTRBP,"OK",,aTRB,@lInverte,@cMarca,{60,1,285,417})

		oMarkBrow:oBrowse:lHasMark = .T.
		oMarkBrow:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		oMarkBrow:oBrowse:lCanAllMark := .T.
		oMarkBrow:oBrowse:bAllMark    := { || NGMARKALL( @cMarca ) }

		Activate Msdialog oDlg1 On Init EnchoiceBar(oDlg1,{|| nOpcOK := 1,oDlg1:End()},{|| nOpcOK := 0,oDlg1:End()}) CENTERED
	Endif

	If nOpcOK == 1
		dbSelectArea(cTRBP)
		dbGoTop()
		While !Eof()
			If !Empty((cTRBP)->OK)
				If NGIFDBSEEK("TQ1",cFamiPai+cTipMPai,1)
					While !Eof() .And. xFilial("TQ1") == TQ1->TQ1_FILIAL .And. cFamiPai == TQ1->TQ1_DESENH .And. cTipMPai == TQ1->TQ1_TIPMOD
						If AllTrim(TQ1->TQ1_EIXO) == AllTrim((cTRBP)->EIXO)
							For nI := 0 to 9
								nPosSusp := aSCAN(aESTSTZ,{|x| x[6] == &('TQ1->TQ1_LOCPN'+AllTrim(Str(nI)))})
								If nPosSusp > 0
									Adel(aESTSTZ,nPosSusp)
									ASize(aESTSTZ,Len(aESTSTZ)-1)
								Endif
							Next
						Endif
						dbSkip()
					End
				Endif
			Endif
			dbSelectArea(cTRBP)
			dbSkip()
		End
	Endif

	If !lTemTRB
		oTmpTbl:Delete()
	EndIf
	RestArea(aOldArea)

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} NGEixoSusp
( antiga NGMARKSUSP ) Recebe array com itens da estrutura que recebem
contador, exibe tela para marcar eixos suspensos e retorna array alterado.

@param String _aESTSTZ: estrutura de bens conforme NGCOMPPCONT()
@param Integer nDifer: diferenÁa do acumulado reportado para o pai
@param Integer nTipoC: contador 1 ou 2
@author Marcos Wagner Junior - 13/04/2011
@author Felipe Nathan Welter - 13/12/2011
@version P11
@return Array _aESTSTZ
/*/
//---------------------------------------------------------------------
Function NGEixoSusp( _aESTSTZ,nDifer,nTipoC,cPaiEstrutura )

	Local oDlg
	Local oTmpTbl
	Local nI, lOK := .F.
	Local aBens   := {}
	Local aArea   := GetArea()
	Local lKMSUSP := .F.

	Private aDBF    := {{"OK"    , "C", 02, 0},;
		{"CODBEM", "C", 16, 0},;
		{"EIXO"  , "C", 10, 0},;
		{"DESCRI", "C", 20, 0},;
		{"KMSUSP", "N", 09, 0},;
		{"KMSANT", "N", 09, 0}}
	Private aTRB 	:= {{"OK"    , NIL, " "    ,},;
		{"CODBEM", Nil, "Bem/Componente",},;
		{"DESCRI", Nil, "Eixo Suspenso",},;
		{"KMSUSP", PesqPict("ST9","T9_POSCONT"), "Rodado Suspenso",} }
	Private lInverte := .F.
	Private vIND := {"CODBEM","EIXO"}
	Private cMARCA := GetMark()

	// Cria arquivos temporarios
	cTRBP	:= GetNextAlias()
	oTmpTbl := FWTemporaryTable():New( cTRBP, aDBF )
	oTmpTbl:AddIndex( "Ind01" , vIND )
	oTmpTbl:Create()

	//Verifica necessidade de colua KM Suspenso Anterior
	aEval(_aESTSTZ, {|x| If( x[8]>0,lKMSUSP := .T.,Nil) })
	If lKMSUSP
		aAdd(aTRB,{"KMSANT" ,NIL,"Suspenso Anterior",})
	EndIf

	//monta arquivo temporario
	For nI := 1 To Len(_aESTSTZ)
		//percorre todos os bens da estrutura para encontrar os pais
		If aSCan(aBens,{|x| x == _aESTSTZ[nI,7] }) == 0
			aAdd(aBens,_aESTSTZ[nI,7])
			dbSelectArea("ST9")
			dbSetOrder(01)
			//para cada pai busca estrutura padrao
			If dbSeek(xFilial("ST9")+_aESTSTZ[nI,7])
				NGIFDBSEEK("TQ1",ST9->T9_CODFAMI+ST9->T9_TIPMOD,1)
				While !Eof() .And. xFilial("TQ1") == TQ1->TQ1_FILIAL .And. ST9->T9_CODFAMI == TQ1->TQ1_DESENH .And. ST9->T9_TIPMOD == TQ1->TQ1_TIPMOD

					// Adiciona apenas eixo suspenso que pertenÁa ao primeiro nÌvel da estrutura (tratativa tempor·ria)
					If ( AllTrim( ST9->T9_CODBEM ) == AllTrim( cPaiEstrutura ) ) .And. TQ1->TQ1_SUSPEN == '1' .And. AllTrim(TQ1->TQ1_EIXO) != "RESERVA"
						dbSelectArea(cTRBP)
						RecLock(cTRBP,.T.)
						(cTRBP)->CODBEM := ST9->T9_CODBEM
						(cTRBP)->EIXO   := TQ1->TQ1_EIXO
						(cTRBP)->DESCRI := "Eixo: "+AllTrim(TQ1->TQ1_EIXO)
						(cTRBP)->KMSUSP := 0
						(cTRBP)->(MsUnLock())

						//preenche valor rodado suspenso para cada eixo
						For nI := 1 to TQ1->TQ1_QTDPNE
							nPosSusp := aSCAN(_aESTSTZ,{|x| x[7] == (cTRBP)->CODBEM .And.;
								x[6] == &('TQ1->TQ1_LOCPN'+AllTrim(Str( If(nI==10,0,nI) )))})
							If nPosSusp > 0
								RecLock(cTRBP,.F.)
								(cTRBP)->KMSUSP := If(_aESTSTZ[nPosSusp,8]>nDifer,;
									If( (cTRBP)->KMSUSP > 0, (cTRBP)->KMSUSP, 0),;
										If(_aESTSTZ[nPosSusp,8]>(cTRBP)->KMSUSP,_aESTSTZ[nPosSusp,8],(cTRBP)->KMSUSP) )
										(cTRBP)->KMSANT := _aESTSTZ[nPosSusp,8]
										(cTRBP)->OK     := If((cTRBP)->KMSUSP>0,cMarca,'  ')
										(cTRBP)->(MsUnLock())
									EndIf
								Next

							EndIf

							dbSelectArea("TQ1")
							dbSkip()

						EndDo
						dbSelectArea(cTRBP)
						dbGoTop()
					EndIf
				EndIf
			Next nI

			//MONTA TELA PARA SELECAO DOS EIXOS SUSPENSOS
			// If (cTRBP)->(RecCount()) > 0 .And. nDifer > 0
			// Ajuste tempor·rio para n„o ocorrer erro no ambiente do cliente, ser· aberto nova S.S. para tratar
			// eixo suspenso. AndrÈ Felipe Joriatti
			If .F.
				Define MsDialog oDlg Title "Eixos suspensos" From 250,120 To 480,640 Of oMainWnd Pixel COLOR CLR_BLACK

				oPanelHead := TPanel():New(0,0,Nil,oDlg,Nil,.T.,Nil, Nil, Nil, 0,20, .T., .F. )
				oPanelHead:Align := CONTROL_ALIGN_TOP

				TSay():New(6,8,{||STR0148+':'},oPanelHead,,,,,,.T.,,,200,20)  //"Indique os eixos que foram suspensos no percurso:"
				TSay():New(6,220,{||"(Contador "+cValToChar(nTipoC)+")"},oPanelHead,,,,,,.T.,,,200,20)

				oPanel := TPanel():New(0,0,Nil,oDlg,Nil,.T.,Nil, Nil, Nil, 0,70, .T., .F. )
				oPanel:Align := CONTROL_ALIGN_ALLCLIENT

				oMarkBrow := MsSelect():New(cTRBP,"OK",,aTRB,@lInverte,@cMarca,{60,1,285,417},,oPanel)
				oMarkBrow:oBrowse:lHasMark = .T.
				oMarkBrow:oBrowse:lCanAllMark := .F.
				oMarkBrow:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

				oPanelBtn := TPanel():New(0,0,Nil,oDlg,Nil,.T.,Nil, Nil, Nil, 0,20, .T., .F. )
				oPanelBtn:Align := CONTROL_ALIGN_BOTTOM

				SButton():New( 04,185,01,{||lOK := .T.,oDlg:End()},oPanelBtn,.T.,'OK',/*bWhen*/)
				SButton():New( 04,215,02,{||lOK := .F.,oDlg:End()},oPanelBtn,.T.,'OK',/*bWhen*/)

				Activate Msdialog oDlg Centered
			EndIf

			//e alimenta com informacoes do eixo
			If lOK
				dbSelectArea(cTRBP)
				dbGoTop()
				While (cTRBP)->(!Eof())
					NGIFDBSEEK("ST9",(cTRBP)->CODBEM,1)
					If NGIFDBSEEK("TQ1",ST9->T9_CODFAMI+ST9->T9_TIPMOD,1)
						While TQ1->(!Eof()) .And. xFilial("TQ1") == TQ1->TQ1_FILIAL .And.;
								ST9->T9_CODFAMI == TQ1->TQ1_DESENH .And. ST9->T9_TIPMOD == TQ1->TQ1_TIPMOD
							If AllTrim(TQ1->TQ1_EIXO) == AllTrim((cTRBP)->EIXO)
								For nI := 1 to TQ1->TQ1_QTDPNE
									nPosSusp := aSCAN(_aESTSTZ,{|x| x[7] == (cTRBP)->CODBEM .And.;
										x[6] == &('TQ1->TQ1_LOCPN'+AllTrim(Str( If(nI==10,0,nI) )))})
									If !Empty((cTRBP)->OK) .And. nPosSusp > 0
										_aESTSTZ[nPosSusp][8] := (cTRBP)->KMSUSP
									ElseIf nPosSusp > 0
										_aESTSTZ[nPosSusp][8] := 0
									EndIf
								Next
							EndIf
							dbSkip()
						EndDo
					EndIf
					(cTRBP)->(dbSkip())
				EndDo
			Else
				For nI := 1 To Len(_aESTSTZ)
					_aESTSTZ[nI][8] := 0
				Next nI
			EndIf

			oTmpTbl:Delete()
			//NGDELETRB(cTRBP,cARQTEMP)
			RestArea(aArea)

			Return _aESTSTZ
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥NGBUSCONTHI≥ Autor ≥In†cio Luiz Kolling    ≥ Data ≥11/11/2004≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Pesquisa lancamento do historico do contador e/ou projeta    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥cVBEM     - C¢digo do bem                       - Obrigatorio≥±±
±±≥          ≥dVDATA    - Data da leitura                     - Obrigat¢rio≥±±
±±≥          ≥cHORA     - Hora da leitura                     - Obrigat¢rio≥±±
±±≥          ≥nTIPOC    - Tipo do contador ( 1/2 )            - Obrigat¢rio≥±±
±±≥          ≥lVPROJ    - Projeta contadores                  - Nao Obrig. ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorna   ≥vRETOR    {Contador,dt.leitura,v.dia,acumulado,hora,endereco}≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function NGBUSCONTHI(cVBEM,dVDTA,cHOR,nTIPOC,lVPROJ)
	Local vRETOR := {}
	Local vARQAC := If(nTIPOC = 1,{'STP','stp->tp_filial','stp->tp_codbem',;
		'stp->tp_dtleitu','stp->tp_hora',;
		'stp->tp_poscont','stp->tp_vardia',;
		'stp->tp_acumcon'},{'TPP','tpp->tpp_filial',;
		'tpp->tpp_codbem','tpp->tpp_dtleit',;
		'tpp->tpp_hora','tpp->tpp_poscon',;
		'tpp->tpp_vardia','tpp->tpp_acumco'})

	Private nCONTAA := 0,nVARDIAA := 0,nACUMULA := 0
	Private nCONTAB := 0,nVARDIAB := 0,nACUMULB := 0
	Private nCONTAC := 0,nVARDIAC := 0,nACUMULC := 0
	Private cHORAA  := "  :  ",cHORAB := cHORAA,cHORAC := cHORAA
	Private dDATAA  := Ctod("  /  /  "),dDATAB := dDATAA,dDATAC := dDATAA

	lPROJ   := If(lVPROJ = NIL,.F.,lVPROJ)
	nTIPOC  := If(Empty(nTIPOC) .Or. nTIPOC = NIL,1,nTIPOC)
	cTIPOC  := If(nTIPOC = 1,' 1 ',' 2 ')
	dVDATA  := dVDTA
	cHORA   := cHOR

	nRECSTP := 0
	NGDBAREAORDE(vARQAC[1],5)
	dbSeek(xFilial(vARQAC[1])+cVBEM+Dtos(dVDATA),.T.)
	If !Eof()
		If &(vARQAC[2]) = xfilial(vARQAC[1]) .And. &(vARQAC[3]) = cVBEM
			If (&(vARQAC[4]) <= dVDATA .And. &(vARQAC[5]) <= cHORA)
				While !Eof() .And. &(vARQAC[2]) = xfilial(vARQAC[1]) .And.;
						&(vARQAC[3]) = cVBEM
					If &(vARQAC[4]) <= dVDATA .And. &(vARQAC[5]) <= cHORA
						nRECSTP := Recno()
					Endif
					dbSkip()
				End
			Else
				While !Bof() .And. &(vARQAC[2]) = xfilial(vARQAC[1]) .And.;
						&(vARQAC[3]) = cVBEM
					If  &(vARQAC[4]) <= dVDATA
						If &(vARQAC[4]) < dVDATA
							nRECSTP := Recno()
							Exit
						ElseIf &(vARQAC[4]) = dVDATA .And. cHORA <= &(vARQAC[5])
							nRECSTP := Recno()
							Exit
						Endif
					ElseIf &(vARQAC[4]) >= dVDATA
						nRECSTP := Recno()
						Exit
					Endif
					dbSkip(-1)
				End
			Endif
		Else
			dbSkip(-1)
			If !Bof() .And. &(vARQAC[2]) = xfilial(vARQAC[1]) .And. &(vARQAC[3]) <> cVBEM
				dbSkip(-1)
			Endif
			If &(vARQAC[2]) = xfilial(vARQAC[1]) .And. &(vARQAC[3]) = cVBEM
				While !Bof() .And. &(vARQAC[2]) = xfilial(vARQAC[1]) .And.;
						&(vARQAC[3]) = cVBEM
					If (&(vARQAC[4]) <= dVDATA .And. &(vARQAC[5]) <= cHORA) .Or.;
							(dVDATA >= &(vARQAC[4]) .And. cHORA <= &(vARQAC[5]))
						nRECSTP := Recno()
						Exit
					Endif
					dbSkip(-1)
				End
			Endif
		Endif
	Else
		dbSkip(-1)
		If !Bof() .And. &(vARQAC[2]) = xfilial(vARQAC[1]) .And. &(vARQAC[3]) <> cVBEM
			dbSkip(-1)
		Endif
		If &(vARQAC[2]) = xfilial(vARQAC[1]) .And. &(vARQAC[3]) = cVBEM
			While !Bof() .And. &(vARQAC[2]) = xfilial(vARQAC[1]) .And.;
					&(vARQAC[3]) = cVBEM
				If (&(vARQAC[4]) <= dVDATA .And. &(vARQAC[5]) <= cHORA) .Or.;
						(dVDATA >= &(vARQAC[4]) .And. cHORA <= &(vARQAC[5]))
					nRECSTP := Recno()
					Exit
				Endif
				dbSkip(-1)
			End
		Endif
	Endif

	If nRECSTP > 0
		nHORA24 := Htom("24:00")
		nHORAVI := Htom(cHORA)

		dbSelectArea(vARQAC[1])
		Dbgoto(nRECSTP)
		If &(vARQAC[2]) = xfilial(vARQAC[1]) .And. &(vARQAC[3]) = cVBEM
			nCONTAB  := &(vARQAC[6])
			dDATAB   := &(vARQAC[4])
			nVARDIAB := &(vARQAC[7])
			nACUMULB := &(vARQAC[8])
			cHORAB   := &(vARQAC[5])
			dbSkip(-1)
			If !Bof() .And. &(vARQAC[2]) = xfilial(vARQAC[1]) .And. &(vARQAC[3]) = cVBEM
				nCONTAA  := &(vARQAC[6])
				dDATAA   := &(vARQAC[4])
				nVARDIAA := &(vARQAC[7])
				nACUMULA := &(vARQAC[8])
				cHORAA   := &(vARQAC[5])
			Endif
			Dbgoto(nRECSTP)
			dbSkip()
			If !Bof() .And. &(vARQAC[2]) = xfilial(vARQAC[1]) .And. &(vARQAC[3]) = cVBEM
				nCONTAC  := &(vARQAC[6])
				dDATAC   := &(vARQAC[4])
				nVARDIAC := &(vARQAC[7])
				nACUMULC := &(vARQAC[8])
				cHORAC   := &(vARQAC[5])
			Endif
			Dbgoto(nRECSTP)
		Endif

		nHORAVB := Htom(cHORAB)

		If dDATAB = dVDATA .And. cHORAB = cHORA
			vRETOR   := {nCONTAB,dDATAB,nVARDIAB,nACUMULB,cHORAB,nRECSTP,.F.}

		ElseIf dDATAB = dVDATA
			If lPROJ
				cPARFI := "S"

				If nACUMULA = 0 .And. nACUMULC = 0
					vRETOR := {If(cHORA < cHORAB,nCONTAB-nVARDIAB,nCONTAB+nVARDIAB),;
						dVDATA,nVARDIAB,;
						(cHORA < cHORAB,nACUMULF-nVARDIAB,nACUMULB+nVARDIAB),;
						cHORA,nRECSTP,.T.}

				ElseIf nACUMULA = 0 .And. nACUMULC > 0

					If cHORA < cHORAB
						vRETOR := {nCONTAB-nVARDIAB,dVDATA,nVARDIAB,;
							nACUMULB-nVARDIAB,cHORA,nRECSTP,.T.}
					Else
						vRETOR := NGBUSTPIN1()
					Endif

				ElseIf nACUMULA > 0 .And. nACUMULC = 0

					If cHORA > cHORAB
						vRETOR := {nCONTAB+nVARDIAB,dVDATA,nVARDIAB,nACUMULB+nVARDIAB,;
							cHORA,nRECSTP,.T.}
					Else
						vRETOR := NGBUSTPIN2()
					Endif

				ElseIf nACUMULA > 0 .And. nACUMULC > 0

					If cHORA < cHORAB
						vRETOR := NGBUSTPIN2()
					Else
						vRETOR := NGBUSTPIN1()
					Endif
				Endif
			Else
				vRETOR   := {nCONTAB,dDATAB,nVARDIAB,nACUMULB,cHORAB,nRECSTP,.T.}
			Endif

		ElseIf dDATAB > dVDATA
			If lPROJ
				cPARFI := "S"
				If nACUMULA > 0
					nDIFAC := nACUMULB-nACUMULA
					If nDIFAC > 0
						// CALCULA A VARIACAO DIA DO PERIODO
						nDIFDV   := (dDATAB-dDATAA)-1
						nDIFDV   := If(nDIFDV < 0,0,nDIFDV)
						nHORADV  := nDIFDV * nHORA24
						nHORAVA  := Htom(cHORAA)
						cTOTHOV  := Mtoh((nHORA24-nHORAVA)+nHORADV+nHORAVB)
						nPOSDOI  := At(":",cTOTHOV)
						cHORACV  := Substr(cTOTHOV,1,nPOSDOI-1)+"."+Substr(cTOTHOV,nPOSDOI+1,2)
						nHORACV  := Val(cHORACV)

						nVARDPER := nDIFAC/nHORACV

						// CALCULA A QUANTIDADE DE HORAS ENTRE HORA INFORMADA x STP

						nDIFDIN  := (dDATAB-dVDATA)-1
						nHORADI  := nDIFDIN * nHORA24
						nHORAIN  := Htom(cHORA)
						nHORAIB  := Htom(cHORAB)
						cTOTHOI  := Mtoh((nHORA24-nHORAIN)+nHORAIB+nHORADI)
						nPOSDOI  := At(":",cTOTHOI)
						cHORACI  := Substr(cTOTHOI,1,nPOSDOI-1)+"."+Substr(cTOTHOI,nPOSDOI+1,2)
						nHORACI  := Val(cHORACI)

						nDECREME := nVARDPER * nHORACI

						vRETOR   := {Int(nCONTAB-nDECREME),dVDATA,nVARDPER,;
							Int(nACUMULB-nDECREME),cHORA,nRECSTP,.T.}
					Else
						vRETOR   := {nCONTAB,dVDATA,nVARDIAB,nACUMULB,cHORA,nRECSTP,.T.}
					Endif
				Else
					nDECREME := (dDATAB - dVDATA) * nVARDIAB
					nCONTAF  := nCONTAB-nDECREME
					nACUMULF := nACUMULB - nDECREME

					nCONTAF  := If(nCONTAF < 0,0,nCONTAF)
					nACUMULF := If(nACUMULF < 0,0,nACUMULF)

					vRETOR   := {nCONTAF,dVDATA,nVARDIAB,nACUMULF,cHORA,nRECSTP,.T.}
				Endif
			Else
				vRETOR   := {nCONTAB,dVDATA,nVARDIAB,nACUMULB,cHORA,nRECSTP,.T.}
			Endif

		ElseIf dDATAB < dVDATA
			If lPROJ
				cPARFI   := "S"
				nDECREME := (dVDATA-dDATAB) * nVARDIAB
				nCONTAF  := nCONTAB+nDECREME
				nACUMULF := nACUMULB + nDECREME
				vRETOR   := {nCONTAF,dVDATA,nVARDIAB,nACUMULF,cHORA,nRECSTP,.T.}
			Else
				vRETOR   := {nCONTAB,dDATAB,nVARDIAB,nACUMULB,cHORAB,nRECSTP,.T.}
			Endif
		Endif
	Else
		vRETOR := {0,CTOD("  /  /  "),0,0,"  :  ",0,.F.}
	Endif
Return vRETOR
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥NGBUSTPIN1≥ Autor ≥In†cio Luiz Kolling    ≥ Data ≥11/11/2004≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Projeta contadores quando nACUMULA = 0 e nACUMULC > 0 e     ≥±±
±±≥          ≥e cHORA < cHORAB ou quando nACUMULA > 0 e nACUMULC > 0 e    ≥±±
±±≥          ≥e cHORA > cHORAB                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorna   ≥vINRET {Cont.,dt.leitura,v.dia,acumulado,hora,end.,projetou}≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function NGBUSTPIN1()
	Local vINRET := {},nDIFAC := nACUMULC-nACUMULB
	If nDIFAC > 0
		// CALCULA A VARIACAO DIA DO PERIODO
		nHORAVC  := Htom(cHORAC)
		nDIFDV   := (dDATAC-dDATAB)-1
		nDIFDV   := If(nDIFDV < 0,0,nDIFDV)
		nHORADV  := nDIFDV * nHORA24
		nHORACV  := If(dDATAC = dDATAB,(nHORAVC-nHORAVB),;
			(nHORA24-nHORAVB)+nHORADV+nHORAVC)
		nVARDPER := nDIFAC/nHORACV

		// CALCULA INCREMENTO

		nDIFDV   := (dVDATA-dDATAB)-1
		nDIFDV   := If(nDIFDV < 0,0,nDIFDV)
		nHORADV  := nDIFDV * nHORA24
		nHORACI  := (nHORAVI-nHORAVB)+nHORADV

		vINRET   := {Int(nCONTAB+(nVARDPER * nHORACI)),;
			dVDATA,nVARDPER,Int(nACUMULB+(nVARDPER * nHORACI)),;
			cHORA,nRECSTP,.T.}
	Else
		vINRET := {nCONTAB,dVDATA,nVARDIAB,nACUMULB,cHORA,nRECSTP,.T.}
	Endif
Return vINRET
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥NGBUSTPIN2≥ Autor ≥In†cio Luiz Kolling    ≥ Data ≥11/11/2004≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Projeta contadores quando nACUMULA > 0 e nACUMULC = 0 e     ≥±±
±±≥          ≥e cHORA > cHORAB ou quando nACUMULA > 0 e nACUMULC > 0 e    ≥±±
±±≥          ≥e cHORA < cHORAB                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorna   ≥vINRET {Cont.,dt.leitura,v.dia,acumulado,hora,end.,projetou}≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function NGBUSTPIN2()
	Local vINRET := {},nDIFAC := nACUMULB-nACUMULA
	If nDIFAC > 0

		// CALCULA A VARIACAO DIA DO PERIODO
		nHORAVA  := Htom(cHORAA)
		nDIFDV   := (dDATAB-dDATAA)-1
		nDIFDV   := If(nDIFDV < 0,0,nDIFDV)
		nHORADV  := nDIFDV * nHORA24
		nHORACV  := If(dDATAA = dDATAB,(nHORAVB-nHORAVA),;
			(nHORA24-nHORAVA)+nHORADV+nHORAVB)
		nVARDPER := nDIFAC/nHORACV

		// CALCULA INCREMENTO
		nDIFDV   := (dVDATA-dDATAB)-1
		nDIFDV   := If(nDIFDV < 0,0,nDIFDV)
		nHORADV  := nDIFDV * nHORA24
		nHORACI  := (nHORAVB-nHORAVI)+nHORADV
		vINRET   := {Int(nCONTAB-(nVARDPER * nHORACI)),;
			dVDATA,nVARDPER,Int(nACUMULB-(nVARDPER * nHORACI)),;
			cHORA,nRECSTP,.T.}
	Else
		vINRET := {nCONTAB,dVDATA,nVARDIAB,nACUMULB,cHORA,nRECSTP,.T.}
	Endif
Return vINRET
/*/
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
	±±≥FunáÖo    ≥NGACOPCONT ≥ Autor ≥Inacio Luiz Kolling   ≥ Data ≥01/12/2006≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥DescriáÖo ≥Consistencia do tipo do contador                            ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥Parametros≥cVBTCont - Tipo do contador (1...2)           - Obrigatorio ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥Retorna   ≥.F.,.T.                                                     ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥Uso       ≥NGACOPLAD                                                   ≥±±
	±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function NGACOPCONT(nVBTCONT)
	If nVBTCONT >= 1 .And. nVBTCONT <= 2
	Else
		MsgInfo(STR0111+CRLF+CRLF+STR0112+" 1 "+STR0086+" 2",STR0050)
		// Tipo de contador invalido .. Valores validos ... ou
		Return .F.
	Endif
Return .T.
/*/
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
	±±≥FunáÖo    ≥ NGCONTAP  ≥ Autor ≥ Evaldo Cevinscki Jr. ≥ Data ≥12/11/2007≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥DescriáÖo ≥Checa contador informado em relacao ao anterior e posterior.≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥ Uso      ≥ SigaMNT                                                    ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥         ATUALIZACOES SOFRIDAS DESDE A CONSTRUÄAO INICIAL.             ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥Programador ≥ Data   ≥ F.O  ≥  Motivo da Alteracao                     ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥            ≥        ≥      ≥                                          ≥±±
	±±¿ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function NGCONTAP(cBemF, cDtCon, cHrCon, nTipOc, cFilBemF)

	Local aAreaSTP   := GetArea()
	Local nConAnt    := 0
	Local nConPos    := 0
	Local nVira      := 0
	Local nConACU    := 0
	Local cTipLanAnt := " "
	Local cTipLanPos := " "
	Local lVira      := .T.
	Local dDtAnt     := CtoD("  /  /  ")
	Local cHrAnt     := "  :  "
	Local dDtPos     := CtoD("  /  /  ")
	Local cHrPos     := "  :  "
	Local lIdentico  := .F.
	Local nAcumCon   := 0
	Local vArqDia    := {}
	Local cPostoAnte := ''
	Local cPostoPos  := ''
	Local cLojaAnte  := ''
	Local cLojaPos   := ''
	Local cFilCons   := ''
	Local cQuery     := ""

	Private aConts   := {}

	Default cFilBemF := ''

	If nTipOc = Nil
		nTipOc := 1
	EndIf

	vARQDIA := IIf(nTIPOC = 1, {'STP','STP->TP_FILIAL','STP->TP_CODBEM','STP->TP_DTLEITU','STP->TP_HORA','STP->TP_TIPOLAN',;
		'STP->TP_POSCONT','STP->TP_VIRACON','STP->TP_ACUMCON',;
		'TP_CODBEM+DTOS(TP_DTLEITU)+TP_HORA','TP_FILIAL+TP_CODBEM+DTOS(TP_DTLEITU)+TP_HORA'},;
		{'TPP','TPP->TPP_FILIAL','TPP->TPP_CODBEM','TPP->TPP_DTLEIT','TPP->TPP_HORA','TPP->TPP_TIPOLA',;
		'TPP->TPP_POSCON','TPP->TPP_VIRACO','TPP->TPP_ACUMCO',;
		'TPP_CODBEM+DTOS(TPP_DTLEIT)+TPP_HORA','TPP_FILIAL+TPP_CODBEM+DTOS(TPP_DTLEIT)+TPP_HORA'})

	lTestFi := IIf(NGRETORDEM(vARQDIA[1],vARQDIA[11],.T.) = 5,.T.,.F.)

	If (IsInCallStack("MNTA655") .Or. IsInCallStack("MNTA656")).And. !Empty(cFilBemF)

		dbSelectArea(vARQDIA[1])
		dbSetOrder(5)
		dbSeek(cFilBemF + cBemF + cDtCon + cHrCon, .T.)
		//Dever· usar essa variavel para comparaÁ„o dos registros, pois caso a chamada seja do MNTA655/656 e a filial cFilBemF esteja marcada
		//o bem poder· estar numa filial diferente do posto, e na hora de fazer a comparaÁ„o "&(vARQDIA[2]) == xFilial(vARQDIA[1]" est· errada,
		//pois n„o considera a parametrizaÁ„o acima (Chamada via MNTA655/MNTA656 E cFilBemF preenchido).
		//Dessa forma o cFilCons estar· sempre preenchido com a informaÁıes correta.
		//SS: 027181
		cFilCons := cFilBemF
	Else
		dbSelectArea(vARQDIA[1])
		dbSetOrder(IIf(lTestFi, 5, 9))
		dbSeek(IIf(lTestFi, IIF(!Empty(cFilBemF), cFilBemF, xFilial(vARQDIA[1])), "") + cBemF + cDtCon + cHrCon, .T.)
		cFilCons := IIF(!Empty(cFilBemF), cFilBemF, xFilial(vARQDIA[1]))
	EndIf

	If !EoF()
		If &(vARQDIA[3]) == cBemF .And. IIf(lTestFi, &(vARQDIA[2]) == cFilCons, .T.)
			If STOD(cDtCon) == &(vARQDIA[4]) .And. cHrCon == &(vARQDIA[5])

				If &(vARQDIA[6]) == "A"
					lIdentico := .T.
					cTipLanPos := &(vARQDIA[6])
				EndIf

				dbSkip()
			EndIf

			If &(vARQDIA[3]) == cBemF .And. IIf(lTestFi, &(vARQDIA[2]) == cFilCons, .T.) .And.;
					(NgBlCont( cBemF, .F. ) .Or. &(vARQDIA[6]) == "A")// Se o par‚metro LANEX estiver habilitado, carrega apenas registro do tipo Abastecimento
				aRetorno := {}

				If ExistBlock("NGUTILF")
					aRetorno   := ExecBlock("NGUTILF", .F., .F., {cBemF, STOD(cDtCon), cHrCon})
				EndIf

				If Len(aRetorno) > 0
					nConPos    := aRetorno[1][1]
					cTipLanPos := aRetorno[1][2]
					dDtPos     := aRetorno[1][3]
					cHrPos     := aRetorno[1][4]
				Else
					nConACU    := &(vARQDIA[9])
					nConPos    := &(vARQDIA[7])
					cTipLanPos := &(vARQDIA[6])
					dDtPos     := &(vARQDIA[4])
					cHrPos     := &(vARQDIA[5])
				EndIf

				If lVira
					nVira := &(vARQDIA[8])
					lVira := .F.
				EndIf

			EndIf
		EndIf
	EndIf

	If !BoF()
		dbSkip(-1)

		If lIdentico
			dbSkip(-1)
		EndIf

		nAcumCon := &(vARQDIA[7])

		While !BoF() .And. &(vARQDIA[3]) == cBemF .And. IIf(lTestFi, &(vARQDIA[2]) == cFilCons, .T.) .And. &(vARQDIA[7]) == nAcumCon

			If NgBlCont( cBemF, .F. ) .Or. ( &(vARQDIA[6]) == "A" .Or. &(vARQDIA[6]) == "I" )// Se o par‚metro LANEX estiver habilitado, carrega apenas registro do tipo Abastecimento

				nConACU    := &(vARQDIA[9])
				nConAnt    := &(vARQDIA[7])
				cTipLanAnt := &(vARQDIA[6])
				dDtAnt     := &(vARQDIA[4])
				cHrAnt     := &(vARQDIA[5])

				If lVira
					nVira := &(vARQDIA[8])
				EndIf

				Exit
			Else
				dbSkip(-1)
			EndIf

		End

	EndIf

	cQry := GetNextAlias()
	cQuery := " SELECT TQN_DTABAS, TQN_HRABAS, TQN_POSTO, TQN_LOJA "
	cQuery += " FROM " + RetSQLName("TQN")
	cQuery += " WHERE TQN_FROTA  = '"+cBemF+"' "
	cQuery += " AND   (TQN_DTABAS = '" + DTOS(dDtAnt) + "'"
	cQuery += " AND   TQN_HRABAS = '" + cHrAnt + "') OR "
	cQuery += "       (TQN_DTABAS = '" + DTOS(dDtPos) + "'"
	cQuery += " AND   TQN_HRABAS = '" + cHrPos + "') "
	cQuery += " AND D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY TQN_DTABAS, TQN_HRABAS "
	cQuery := ChangeQuery(cQuery)

	DbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), cQry, .F., .T.)

	While !Eof()
		If (cQry)->TQN_DTABAS+(cQry)->TQN_HRABAS == DTOS(dDtAnt)+cHrAnt
			cPostoAnte := (cQry)->TQN_POSTO
			cLojaAnte  := (cQry)->TQN_LOJA
		ElseIf (cQry)->TQN_DTABAS+(cQry)->TQN_HRABAS == DTOS(dDtPos)+cHrPos
			cPostoPos  := (cQry)->TQN_POSTO
			cLojaPos   := (cQry)->TQN_LOJA
		EndIf

		dbSkip()
	End

	(cQry)->(dbCloseArea())

	aConts := {nConAnt,nConPos,cTipLanPos,cTipLanAnt,nConAnt,cTipLanAnt,nVira,dDtPos,cHrPos,dDtAnt,cHrAnt,cPostoAnte,cLojaAnte,cPostoPos,cLojaPos,nConACU}
	RestArea(aAreaSTP)

Return aConts

//---------------------------------------------------------------------
/*/{Protheus.doc} NGCONTPER
Calcula o Km percorrido entre dois abastecimentos.

@author Evaldo Cevinscki Jr.

@since 12/11/2007

@version MP12
@type function
@param cBemF    , caractere, bem para o qual o abastecimento foi realizado
@param cDtCon   , caractere, data do abastecimento
@param cHrCon   , caractere, hora do abastecimento
@param cTipoCn  , caractere, tipo do contador
@param [cFilAba], string   , Indica a filial origem do abastecimento.

@return numerico, retorna a diferenÁa entre o contador acumulado dos abastecimentos
/*/
//---------------------------------------------------------------------
Function NGCONTPER( cBemF, cDtCon, cHrCon, cTipoCn, cFilAba )

	Local nConAnt   := 0, nContAtu := 0
	Local cAliasQry := GetNextAlias()
	Local aBind     := {}
	Local cBanco    := Upper(TCGetDB())

	Default cTipoCn := '1'
	Default cFilAba := FWxFilial( 'STP' )
		
	cBemF := cBemF + Space(Len(ST9->T9_CODBEM)-Len(cBemF))

	If cTipoCn == '1'
	
		If Empty( cQryKmSTP )

			cQryKmSTP :=	'SELECT '

			If cBanco $ 'MSSQL7'
			
				cQryKmSTP += ' TOP (2) '

			EndIf

			cQryKmSTP += 		'TP_POSCONT '
			cQryKmSTP +=	'FROM '
			cQryKmSTP += 		RetSqlName( 'STP' ) + ' STP '
			cQryKmSTP += 	'WHERE '
			cQryKmSTP += 		'STP.TP_FILIAL  = ? AND '
			cQryKmSTP += 		'STP.TP_CODBEM  = ? AND '
			cQryKmSTP += 		"STP.TP_TIPOLAN IN ('A', 'I') AND "
			cQryKmSTP += 		'STP.TP_DTLEITU || STP.TP_HORA <= ? AND '
			cQryKmSTP += 		"STP.D_E_L_E_T_ = ' ' "

			cQryKmSTP += 		' ORDER BY TP_DTLEITU || TP_HORA DESC '
			
			If cBanco == 'ORACLE'

				cQryKmSTP += ' fetch first 2 rows only '

			ElseIf cBanco $ 'POSTGRES/MYSQL'

				cQryKmSTP += ' LIMIT 2 '

			EndIf
			
			cQryKmSTP := ChangeQuery( cQryKmSTP )

		EndIf

		aAdd( aBind, cFilAba )
		aAdd( aBind, cBemF )
		aAdd( aBind, cDtCon+cHrCon )


		dbUseArea( .T., 'TOPCONN', TcGenQry2( , , cQryKmSTP, aBind ), cAliasQry, .T., .T. )

		While (cAliasQry)->(!Eof())  

			If nContAtu = 0
				
				nContAtu := (cAliasQry)->TP_POSCONT

			Else

				nConAnt := (cAliasQry)->TP_POSCONT

			EndIf

			(cAliasQry)->(dbSkip())

		End

	Else	

		If Empty( cQryKmTPP )

			cQryKmTPP :=	'SELECT '
			
			If cBanco $ 'MSSQL7'
				
				cQryKmTPP += ' TOP (2) '
			
			EndIf
			
			cQryKmTPP += 		'TPP_POSCON '
			cQryKmTPP +=	'FROM '
			cQryKmTPP += 		RetSqlName( 'TPP' ) + ' TPP '
			cQryKmTPP += 	'WHERE '
			cQryKmTPP += 		'TPP.TPP_FILIAL  = ? AND '
			cQryKmTPP += 		'TPP.TPP_CODBEM  = ? AND '
			cQryKmTPP += 		"TPP.TPP_TIPOLA IN ('A', 'I') AND "
			cQryKmTPP += 		'TPP.TPP_DTLEIT || TPP.TPP_HORA <= ? AND '
			cQryKmTPP += 		"TPP.D_E_L_E_T_ = ' ' "
			cQryKmTPP += 		' ORDER BY TPP_DTLEIT || TPP_HORA DESC '
			
			If cBanco == 'ORACLE'

				cQryKmTPP += ' fetch first 2 rows only '

			ElseIf cBanco $ 'POSTGRES/MYSQL'

				cQryKmTPP += 'LIMIT 2'

			EndIf
			
			cQryKmTPP := ChangeQuery( cQryKmTPP )

		EndIf

		aAdd( aBind, cFilAba )
		aAdd( aBind, cBemF )
		aAdd( aBind, cDtCon+cHrCon )


		dbUseArea( .T., 'TOPCONN', TcGenQry2( , , cQryKmTPP, aBind ), cAliasQry, .T., .T. )

		While (cAliasQry)->(!Eof())

			If nContAtu = 0

				nContAtu := (cAliasQry)->TPP_POSCON

			Else

				nConAnt := (cAliasQry)->TPP_POSCON

			EndIf

			(cAliasQry)->(dbSkip())

		End

	EndIf

	(cAliasQry)->( dbCloseArea() )

	nKm := nContAtu - nConAnt

	FwFreeArray(aBind)

Return nKm
/*/
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
	±±≥FunáÖo    ≥ NGSTPALT  ≥ Autor ≥ Evaldo Cevinscki Jr. ≥ Data ≥07/03/2008≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥DescriáÖo ≥Diminui 1 minuto de um lancamento de historico de contador. ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥ Uso      ≥ Para abastecimentos com a mesma data e hora de um lancamen-≥±±
	±±≥			 ≥ to de Implantacao,Virada ou Quebra diminui 1 minuto.       ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥         ATUALIZACOES SOFRIDAS DESDE A CONSTRUÄAO INICIAL.             ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥Programador ≥ Data   ≥ F.O  ≥  Motivo da Alteracao                     ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥            ≥        ≥      ≥                                          ≥±±
	±±¿ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function NGSTPALT(cFilSTP,cBemSTP,dDtSTP,cHrSTP)

	dbSelectArea("STP")
	Dbsetorder(5)
	If dbSeek(cFilSTP+cBemSTP+DTOS(dDtSTP)+cHrSTP)

		dDtLei := STP->TP_DTLEITU
		cHoLei := STP->TP_HORA
		nConta := STP->TP_POSCONT
		nAcumu := STP->TP_ACUMCON
		nVardi := STP->TP_VARDIA
		nVarCo := STP->TP_VIRACON

		lGrava := .T.
		If dDtLei = STP->TP_DTLEITU
			cHoEnt := NGSOMAHCAR('00:01',cHoLei)
			dDtEnt := dDtLei
			nHora := Val(SubStr(STP->TP_HORA,1,2))
			nMinu := Val(SubStr(STP->TP_HORA,4,2))
			nMFim := nMinu - 1
			If nMFim < 0
				nHora --
				nMFim := 59
			Endif
			If nHora = -1 //trata hr-> 00:00
				nHora := 23
				dDtEnt := dDtEnt-1
			EndIf
			cHoEnt := StrZero(nHora,2)+":"+StrZero(nMFim,2)
		Endif

		nRecno := Recno()
		dbSkip(-1)
		If !Bof() .And. STP->TP_CODBEM == cBemSTP .And. STP->TP_DTLEITU == dDtEnt .And. STP->TP_HORA == cHoEnt
			lGrava := .F.
		EndIf

		If lGrava
			DbGoTo(nRecno)
			Reclock("STP",.F.)
			STP->TP_DTLEITU := dDtEnt
			STP->TP_HORA    := cHoEnt
			MsUnLock("STP")
		Endif
	Endif

Return lGrava
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥ FunáÖo   ≥ NGPCONTPE≥ Autor ≥ Elisangela Costa      ≥ Data ≥ 31/05/05 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ DescriáÖo≥ Procura o contador acumulado na data do parametro          ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Parametro≥ cCODBEMP - Codigo do bem                                   ≥±±
±±≥          ≥ dDATAP   - Data do periodo                                 ≥±±
±±≥          ≥ cTIPOC   - Tipo do contador (1-Contador 1, 2-Contador 2)   ≥±±
±±≥          ≥ lPRIP    - Indica se pega o primeiro ou ultimo registro da ≥±±
±±≥          ≥            do parametro (.T. - primeiro parecido ou .F.    ≥±±
±±≥          ≥            ultimo lancamento da data do parametro)         ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Generico                                                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function NGPCONTPE(cCODBEMP,dDATAP,cTIPOC,lPRIP)

	Local vARQUI := If(cTIPOC = 1,{'STP','stp->tp_filial','stp->tp_codbem',;
		'stp->tp_dtleitu','stp->tp_hora','stp->tp_poscont','stp->tp_acumcon'},;
		{'TPP','tpp->tpp_filial','tpp->tpp_codbem',;
		'tpp->tpp_dtleit','tpp->tpp_hora','tpp->tpp_poscon','tpp->tpp_acumco'})

	Local vCONTA := {0,0,Ctod('  /  /  '),Space(5)}

	dbSelectArea(vARQUI[1])
	dbSetOrder(5)
	dbSeek(xFilial(vARQUI[1])+cCODBEMP+DTOS(dDATAP),.T.)
	If Eof()
		dbSkip(-1)
	Else
		If !Bof() .And. &(vARQUI[2]) = xFILIAL(vARQUI[1]) .And. &(vARQUI[3]) <> cCODBEMP
			dbSkip(-1)
		Endif
	EndIf

	If !Bof() .And. &(vARQUI[2]) = xFILIAL(vARQUI[1]) .And. &(vARQUI[3]) = cCODBEMP

		If lPRIP
			vCONTA := {&(vARQUI[6]),&(vARQUI[7]),&(vARQUI[4]),&(vARQUI[5])}
		Else
			dDATAHIS := &(vARQUI[4])
			While !Eof() .And. &(vARQUI[2]) = xFILIAL(vARQUI[1]) .And. &(vARQUI[3]) = cCODBEMP;
					.And. &(vARQUI[4]) = dDATAHIS

				vCONTA := {&(vARQUI[6]),&(vARQUI[7]),&(vARQUI[4]),&(vARQUI[5])}

				dbSelectArea(vARQUI[1])
				dbSkip()
			End
		EndIf

	EndIf

Return vCONTA

//-------------------------------------------------------------------
/*/{Protheus.doc} NGMARKALL
Inverte a marcacao total

@author  Marcos Wagner Junior
@since   13/04/2011
@version P11/P12
@param   cMarca, Caracter, Define marcaÁ„o
/*/
//-------------------------------------------------------------------
Static Function NGMARKALL( cMarca )

	Local nRecno := Recno()

	dbSelectarea(cTRBP)
	dbGoTop()
	While !Eof()
		dbSelectArea(cTRBP)
		RecLock(cTRBP,.F.)
		(cTRBP)->OK := Iif(IsMark("OK",cMarca),Space(2),cMarca)
		MsUnLock()
		dbSkip()
	End
	dbGoTo(nRecno)
	lREFRESH := .T.

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} NGTRANSF
FunÁ„o para buscar filial da ˙ltimo registro de contador

@author Diego de Oliveira
@since 14/11/2016
@version MP11/MP12
@param   cFrota,  Caracter, CÛdigo do bem
@param   dData,   Data,     Data para registro do contador
@param   cHora,   Caracter, Hora para registro do contador
@return  cFilSTP, Caracter, Retorna Filial que ser· realizada
							buscas para validar o contador
/*/
//---------------------------------------------------------------------
Static Function NGTRANSF(cFrota,dData,cHora)

	Local cFilSTP   := ""
	Local cAliasQry := ""
	Local cQuery    := ""
	Local _cGetDB 	:= Upper(TCGetDB()) //ObtÈm qual o Banco de Dados corrente

	//Cria query que pega o primeiro registro do bem sem STP de inclus„o
	cAliasQry := GetNextAlias()
	If _cGetDB $ 'MSSQL7/POSTGRES'

		cQuery    := " SELECT "
		If _cGetDB $ 'MSSQL7'
			cQuery    += "TOP 1 " 
		EndIf
		cQuery    += "TP_FILIAL,TP_CODBEM,TP_TIPOLAN,TP_DTLEITU,TP_HORA,TP_POSCONT,TP_ACUMCON "
		cQuery    += " FROM " + RetSQLName("STP")
		cQuery    += " WHERE TP_CODBEM     = "+ValToSQL(cFROTA)
		cQuery 	  += "      AND TP_DTLEITU || TP_HORA < " + ValToSql( DtoS( dData ) + cHora )
		cQuery    += " 	    AND ( TP_TIPOLAN = 'A' OR TP_TIPOLAN = 'I' )"
		cQuery    += "      AND D_E_L_E_T_   = ' ' "
		cQuery    += " ORDER BY TP_DTLEITU || TP_HORA DESC "
		If _cGetDB $ 'POSTGRES'
			cQuery += " LIMIT 1 "
		EndIf
	Else
	
		cQuery := " SELECT "
		cQuery += "TP_FILIAL,TP_CODBEM,TP_TIPOLAN,TP_DTLEITU,TP_HORA,TP_POSCONT,TP_ACUMCON "
		cQuery += " FROM (SELECT * FROM " + RetSQLName("STP") + " STP "
		cQuery += " WHERE TP_CODBEM = " + ValToSQL(cFROTA)
		cQuery += "     AND TP_DTLEITU || TP_HORA < " + ValToSql( DtoS( dData ) + cHora )
		cQuery += "     AND ( TP_TIPOLAN = 'A' OR TP_TIPOLAN = 'I' ) "
		cQuery += "     AND D_E_L_E_T_ = ' ' "
		cQuery += " ORDER BY TP_DTLEITU || TP_HORA DESC ) "
		
		If _cGetDB == "ORACLE"
			cQuery += " 			WHERE ROWNUM < 2 "
		Else
			cQuery += " 			LIMIT 1 "
		EndIf
	
	EndIf

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)

	While !EoF()

		//Atribui a filial do registro encontrado
		cFilSTP := (cAliasQry)->TP_FILIAL
		Exit

	End

	(cALIASQRY)->( dbCloseArea() )

Return cFilSTP

//----------------------------------------------------------------
/*/{Protheus.doc} NGACERMANS()
Atualiza a manutencao padrao e/ou a ser substituida.

@author Inacio Luiz Kolling
@since 25/05/2011

@param cCBem: CÛdigo do bem (obrigatÛrio)
@param cServ: CÛdigo do seviÁo (obrigatÛrio)
@param cSeq: Sequencias da manutencao (obrigatÛrio)
@param dDulM: Data da ultima manutenÁ„o (n„o obrigatÛrio)
@param nCoAm: Acumulado do ultima manutenÁ„o (n„o obrigatÛrio)

/*/
//----------------------------------------------------------------
Function NGACERMANS(cCBem,cServ,cSeq,dDulM,nCoAM,cFila)

	Local nFl := 0

	vStrSubs := NGMANCASCATA(cCBem,cServ,cSeq)

	For nFl := 1 To Len(vStrSubs)
		cSeqS  := vStrSubs[nFl]
		NGACEPROCMAN(cCBem,cServ,cSeqS,dDulM,nCoAM,cFila)
	Next nFl

Return
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥NGACERMANSUB≥ Autor ≥Inacio Luiz Kolling    ≥ Data ≥25/05/2011≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥Atualiza a manutencao padrao e/ou a ser substituida           ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥cCBem - Codigo do bem                            - Obrigatorio≥±±
±±≥          ≥cServ - Codigo do sevico                         - Obrigatorio≥±±
±±≥          ≥cSeq  - Sequencias da manutencao                 - Obrigatorio≥±±
±±≥          ≥dDulM - Data da ultima manutencao                - Nao Obrig. ≥±±
±±≥          ≥nCoAm - Acumulado do ultima manutencao           - Nao Obrig. ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ NGACERTOMANU,NGACERMANSUB                                    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function NGACEPROCMAN(cCBem,cServ,cSeq,dDulM,nCoAM,cFila)

	Local cFilASTJ := NGTROCAFILI("STJ",cFilA),cAliasQry := GetNextAlias()
	Local cFilASTP  := NGTROCAFILI("STP",cFilA)

	If NGIFDBSEEK("STF",cCBem+cServ+cSeq,1,.F.) .And. STF->TF_ATIVO = "S"
		cQuery := " SELECT TJ_DTULTMA,TJ_DTMRFIM,TJ_HOMRFIM,TJ_COULTMA,TJ_HORACO1,TJ_HORACO2 FROM "+RetSqlName("STJ")
		cQuery += " WHERE TJ_FILIAL = '" + cFilASTJ + "' AND TJ_CODBEM  = '" + cCBem + "' AND TJ_SERVICO = '" + cServ + "' AND "
		cQuery += " TJ_SEQRELA = '" + cSeq + "' AND  TJ_SITUACA =  'L' AND  TJ_TERMINO = 'S' AND TJ_TIPOOS = 'B' AND "
		cQuery += "  D_E_L_E_T_ = ' '"
		cQuery += " ORDER BY TJ_DTMRFIM||TJ_HOMRFIM DESC "
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
		DbSelectArea("STF")
		RecLock("STF",.F.)
		If !Eof() .And. !Empty((cAliasQry)->TJ_DTMRFIM)
			If STF->TF_TIPACOM <> "T"
				nTipoC     := If(STF->TF_TIPACOM = "S",2,1)
				cFilASTP := If(nTipoC = 1,cFilASTP,NGTROCAFILI("TPP",cFilA))
				dDataA  := (cAliasQry)->TJ_DTMRFIM
				HoraA  := If(nTipoC = 1,(cAliasQry)->TJ_HORACO1,(cAliasQry)->TJ_HORACO2)
				vRetHist := NGACUMEHIS(cCBem,Stod(dDataA),HoraA,nTipoC,"E",cFilASTP)
				If !Empty(vRetHist[2])
					STF->TF_CONMANU := vRetHist[2]
				EndIf
			EndIf
			If dDulM = NIL
				STF->TF_DTULTMA := Stod((cAliasQry)->TJ_DTMRFIM)
			Else
				If Stod((cAliasQry)->TJ_DTMRFIM) < dDulM   // = E HORA?????
					STF->TF_DTULTMA := Stod((cAliasQry)->TJ_DTMRFIM)
				EndIf
			EndIf
		Else
			STF->TF_DTULTMA := If(dDulM = NIL,STJ->TJ_DTULTMA,dDulM)
			STF->TF_CONMANU := If(nCoAM = NIL,STJ->TJ_COULTMA,nCoAM)
		EndIf
		DbSelectArea("STF")
		STF->(MsUnLock())
		(cAliasQry)->(DbCloseArea())
	EndIf

Return

//----------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} NGPACONT
Pesquisa e atualiza o contador nas tabelas relacionadas.
@type function

@author Wexlei Silveira
@since 13/07/2016

@sample NGPACONT( "CodBem", 28/05/1996, "12:00", 1000, 1000, 1)

@param cBem       , Caracter, Bem a ser pesquisado na tabela
@param dData      , Caracter, Data do registro a ser alterado
@param cHora      , Caracter, Hora do registro a ser alterado
@param cCont      , Caracter, Valor novo do contador
@param nTpAcumcon , N˙merico, Contador acumulado da STP (utilizado para consistÍncia da ST9)
@param [nTypCount], N˙merico, Indica se o processo vai tratar contador 1 ou 2
@param [lChild]   , LÛgico  , Replica o contador para tabelas relacionadas aos filhos da estrutura.

@return

@obs Reescrito por: Alexandre Santos, 17/10/2018.
/*/
//----------------------------------------------------------------------------------------------------------
Function NGPACONT( cCodBem, dData, cHora, cCont, nTpAcumcon, nTypCount, lChild )

	Local aTables     := {}
	Local aCountField := {}
	Local aArea       := GetArea()
	Local nIndex      := 0

	Default nTypCount := 1
	Default lChild    := .F.

	If !lChild
		aAdd(aTables, {"TQN", "TPN", "ST9", "STJ", "STS", "STW", "STY", "STZ", "STZ",; //Tabelas que dever„o ser verificadas
		"TPW", "TQ2", "TQA", "TQB", "TR9", "TTI", "TTI", "TUZ", "HTJ"})//acumulado ST9 com acumulado da STP

		aAdd(aCountField, {"TQN_HODOM" , "TQN_POSCO2"})
		aAdd(aCountField, {"TPN_POSCON", "TPN_POSCO2"})
		aAdd(aCountField, {"T9_POSCONT", "TPE_POSCON"})
		aAdd(aCountField, {"TJ_POSCONT", "TJ_POSCON2"})
		aAdd(aCountField, {"TS_POSCONT", "TS_POSCON2"})
		aAdd(aCountField, {"TW_POSCONT", "TW_POSCON2"})
		aAdd(aCountField, {"TY_POSFIM1", "TY_POSFIM2"})
		aAdd(aCountField, {"TZ_POSCONT", "TZ_POSCON2"})
		aAdd(aCountField, {"TZ_CONTSAI", ""          })
		aAdd(aCountField, {"TPW_POSCON", ""          })
		aAdd(aCountField, {"TQ2_POSCON", "TQ2_POSCO2"})
		aAdd(aCountField, {"TQA_POSCON", "TQA_POSCO2"})
		aAdd(aCountField, {"TQB_POSCON", "TQB_POSCO2"})
		aAdd(aCountField, {"TR9_KMATU" , ""          })
		aAdd(aCountField, {"TTI_POS1EN", "TTI_POS2EN"})
		aAdd(aCountField, {"TTI_POS1SA", "TTI_POS2SA"})
		aAdd(aCountField, {"TUZ_POSCON", "TUZ_POSCO2"})
		aAdd(aCountField, {"HTJ_POSCON", "HTJ_POSCO2"})
	Else
		aAdd(aTables, {"TPN"})
		aAdd(aCountField, {"TPN_POSCON", "TPN_POSCO2"})
	EndIf

	For nIndex := 1 To Len(aTables[1])
		If AliasInDic(aTables[1][nIndex])
			If !Empty(aCountField[nIndex][nTypCount])
				fVerTab( aTables[1][nIndex], cCodBem, dData, cHora, cCont, nTpAcumcon, aCountField[nIndex][nTypCount], nTypCount )
			EndIf
		EndIf
	Next nIndex

	RestArea(aArea)

Return

//----------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} fVerTab
Verifica se o bem possui algum registro inserido na tabela
@type static

@author Wexlei Silveira
@since 13/07/2016

@sample fVerTab("STJ", "CodBem", 28/05/1996, "12:00", 1000, 1000, "TJ_POSCONT", 1)

@param cBem      , Caracter, Bem a ser pesquisado na tabela
@param dData     , Caracter, Data do registro a ser alterado
@param cHora     , Caracter, Hora do registro a ser alterado
@param cCont     , Caracter, Valor novo do contador
@param nTpAcumcon, N˙merico, Contador acumulado da STP (utilizado para consistÍncia da ST9)
@param cField    , Caracter, Nome do campo posiÁ„o contador da tabela em uso.
@param nTypCount , N˙merico, Indica qual tipo de contado est· sendo trabalhado.

@return

@obs Reescrito por: Alexandre Santos, 17/10/2018.
/*/
//----------------------------------------------------------------------------------------------------------
Static Function fVerTab(cTabela, cBem, dData, cHora, cCont, nTpAcumcon, cField, nTypCount )

	Local aCampos := {}

	dbSelectArea(cTabela)

	Do Case
	Case (cTabela == "TQ2")
		aCampos := {"TQ2_FILIAL", "TQ2_CODBEM", "TQ2_DATATR", "TQ2_HORATR"}
	Case (cTabela == "HTJ")
		aCampos := {"HTJ_FILIAL", "HTJ_CODBEM", "HTJ_DTORIG", "HTJ_HRCO1"}
	Case(cTabela == "STJ")
		aCampos := {"TJ_FILIAL" , "TJ_CODBEM" , "TJ_TERMINO", "TJ_DTMRFIM", IIf(nTypCount == 1, "TJ_HORACO1", "TJ_HORACO2"), "TJ_DTORIGI"}
	Case(cTabela == "STS")
		aCampos := {"TS_FILIAL" , "TS_CODBEM" , "TS_DTMRFIM", IIf(nTypCount == 1, "TS_HORACO1", "TS_HORACO2")}
	Case(cTabela == "STW")
		aCampos := {"TW_FILIAL" , "TW_CODBEM" , IIf(nTypCount == 1, "TW_DTLEITU", "TW_DTLEIT"), IIf(nTypCount == 1, "TW_HORAC1", "TW_HORAC2")}
	Case(cTabela == "STY")
		aCampos := {"TY_FILIAL" , "TY_CODBEM" , "TY_DATAFIM", "TY_HORAFIM"}
	Case(cTabela == "STZ" .And. (cField $ "TZ_POSCONT/TZ_POSCON2"))
		aCampos := {"TZ_FILIAL" , "TZ_BEMPAI" , "TZ_DATAMOV", IIf(nTypCount == 1, "TZ_HORACO1", "TZ_HORACO2")}
	Case(cTabela == "STZ" .And. (cField == "TZ_CONTSAI"))
		aCampos := {"TZ_FILIAL" , "TZ_BEMPAI" , "TZ_DATASAI", "TZ_HORASAI"}
	Case(cTabela == "TPN")
		aCampos := {"TPN_FILIAL", "TPN_CODBEM", "TPN_DTINIC", "TPN_HRINIC"}
	Case(cTabela == "TPW")
		aCampos := {"TPW_FILIAL", "TPW_CODBEM", "TPW_DTORIG", "TPW_HORA"  }
	Case(cTabela == "TQA")
		aCampos := {"TQA_FILIAL", "TQA_CODBEM", IIf(nTypCount == 1, "TQA_DTLEI1", "TQA_DTLEI2"), IIf(nTypCount == 1, "TQA_HORAC1", "TQA_HORAC2")}
	Case(cTabela == "TQB")
		aCampos := {"TQB_FILIAL", "TQB_CODBEM", "TQB_DTABER", "TQB_HOABER"}
	Case(cTabela == "TQN")
		aCampos := {"TQN_FILIAL", "TQN_FROTA" , "TQN_DTABAS", "TQN_HRABAS"}
	Case(cTabela == "TR9")
		aCampos := {"TR9_FILIAL", "TR9_FROTA" , "TR9_DTINSP", "TR9_HRINSP"}
	Case(cTabela == "TTI" .And. (cField $ 'TTI_POS1EN/TTI_POS2EN'))
		aCampos := {"TTI_FILIAL", "TTI_CODVEI", "TTI_DTENT" , "TTI_HRENT" }
	Case(cTabela == "TTI" .And. (cField $ 'TTI_POS1SA/TTI_POS2SA'))
		aCampos := {"TTI_FILIAL", "TTI_CODVEI", "TTI_DTSAI" , "TTI_HRSAI" }
	Case(cTabela == "TUZ")
		aCampos := {"TUZ_FILIAL", "TUZ_CODBEM", "TUZ_DATAIN", "TUZ_HORAIN"}
	Case(cTabela == "ST9")
		If cField == "T9_POSCONT"
			dbSelectArea("ST9")
			dbSetOrder(1)
			If dbSeek(xFilial("ST9") + cBem)
				If(ST9->T9_CONTACU == nTpAcumcon)
					RecLock("ST9", .F.)
					ST9->T9_POSCONT := cCont
					MsUnLock()
				EndIf
			EndIf
		Else
			dbSelectArea("TPE")
			dbSetOrder(1)
			If dbSeek(xFilial("TPE") + cBem)
				If(TPE->TPE_CONTAC == nTpAcumcon)
					RecLock("TPE", .F.)
					TPE->TPE_POSCON := cCont
					MsUnLock()
				EndIf
			EndIf
		EndIf
	End Case

	If cTabela != "ST9" .And. Len(aCampos) > 0
		fUpdCnt( aCampos, cTabela, cBem, cField, dData, cHora, cCont )
	EndIf

Return

//----------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} fUpdCnt
Cria uma query que altera a existÍncia do registro de histÛrico.
@type static

@author Wexlei Silveira
@since 13/07/2016

@sample fUpdCnt(aCampos, "STJ", "cBem", aAnd, "TJ_POSCONT", 28/05/1996, "12:00", 1000)

@param aCampos   , Array   , Campos utilizados no select
@param cTabela   , Caracter, Nome da tabela do select
@param cBem      , Caracter, CÛdigo do bem a ser filtrado
@param cField    , Caracter, Nome do campo de PosiÁ„o do contador
@param dData     , Data    , Data do registro a ser alterado
@param cHora     , Caracter, Hora do registro a ser alterado
@param cCont     , N˙merico, Valor novo do contador

@return

@obs Reescrito por: Alexandre Santos, 14/08/2018.
/*/
//----------------------------------------------------------------------------------------------------------
Static Function fUpdCnt(aCampos, cTabela, cBem, cField, dData, cHora, cCont )

	Local cUpdate   := ""
	Local cSelect   := ""	
	Local cAliasAtu := GetNextAlias()

	cSelect := "SELECT "
	cSelect +=     "R_E_C_N_O_ AS REC"

	If cTabela == "STJ"
		cSelect +=  ", TJ_FILIAL, TJ_CODBEM, TJ_TERMINO, TJ_SERVICO, TJ_SEQRELA, TJ_ORDEM, TJ_PLANO, TJ_SUBSTIT"
	EndIf

	cSelect += " FROM" + RetSQLName(cTabela)
	cSelect += " WHERE "
	cSelect +=       aCampos[2] + " = " + ValToSQL(cBem)
	cSelect +=     " AND D_E_L_E_T_ = ' '"
	If(cTabela == "STJ")
		cSelect += " AND "
		cSelect +=     "(CASE " + aCampos[3]
		cSelect +=         " WHEN 'N' THEN " + aCampos[6]
		cSelect +=         " WHEN 'S' THEN " + aCampos[4]
		cSelect +=     " END) = " + ValToSQL(DToS(dData))
		cSelect += " AND " + aCampos[5] + " = " + ValToSQL(cHora)
	Else
		cSelect += " AND " + aCampos[3] + " = " + ValToSQL(DToS(dData))
		cSelect += " AND " + aCampos[4] + " = " + ValToSQL(cHora)
	EndIf

	If cTabela $ "TQ2/HTJ/TPN/TPW/TQA/TQB/TQN/TR9/TUZ/TTI/STZ"
		cSelect += " AND " + cField + " > 0"
	ElseIf cTabela == "STJ"
		cSelect += " AND " + cField + " > 0 AND TJ_SITUACA = 'L'"
	ElseIf cTabela == "STS"
		cSelect += " AND " + cField + " > 0 AND TS_SITUACA = 'L'"
	ElseIf cTabela == "TQA"
		cSelect += " AND TQA_RETORN = 'S' AND " + cField + " > 0"
	EndIf

	cSelect := ChangeQuery(cSelect)

	dbUseArea(.T., "TOPCONN", TcGenQry(,,cSelect), cAliasAtu, .F., .T.)
	dbSelectArea(cAliasAtu)
	dbGoTop()
	While (cAliasAtu)->(!EoF())

		cUpdate := "UPDATE " + RetSQLName(cTabela)
		cUpdate +=     " SET "
		cUpdate +=         cField + " = " + cValToChar(cCont)
		cUpdate +=     " WHERE "
		cUpdate +=         "R_E_C_N_O_ = " + ValToSQL((cAliasAtu)->REC)

		TCSQLExec(cUpdate)

		//----------------------------------------------------
		// Atualiza manutenÁ„o, tratamento para uso do lanex
		//----------------------------------------------------
		If cTabela == 'STJ' .And. (cAliasAtu)->TJ_PLANO != '000000' .And. (cAliasAtu)->TJ_TERMINO == 'S'

			// Atualiza manutenÁ„o
			NGATUMANUT( (cAliasAtu)->TJ_CODBEM, (cAliasAtu)->TJ_SERVICO, (cAliasAtu)->TJ_SEQRELA,,,,,,(cAliasAtu)->TJ_FILIAL )

			// Atualiza manutenÁıes que foram substituÌdas, aglutinadas
			dbSelectArea("STJ")
			dbSetOrder(1)
			If dbSeek( (cAliasAtu)->TJ_FILIAL + (cAliasAtu)->TJ_ORDEM + (cAliasAtu)->TJ_PLANO ) .And.;
					( !Empty( (cAliasAtu)->TJ_SUBSTIT ) .Or. SuperGetMV("MV_NG1SUBS", .F., "1" ) == "2" )
				NGAgluFim()
			EndIf

		EndIf
		(cAliasAtu)->(dbSkip())
	EndDo

	(cAliasAtu)->(dbCloseArea())

Return
//----------------------------------------------------------------
/*/{Protheus.doc} NGTpCont()
When dos campos de contador que retorna o ˙ltimo contador informado,
considerando Quebra e Virada.

@param cCobBem: CÛdigo do bem (n„o obrigatÛrio)
@param dData: Data do registro que est· sendo inserido (n„o obrigatÛrio)
@param cHora: Hora do registro que est· sendo inserido (n„o obrigatÛrio)
@param nAtuCont: Valor atual do contador (n„o obrigatÛrio)
@author Wexlei Silveira
@since 10/05/2016

@return nCont
/*/
//----------------------------------------------------------------
Function NGTpCont(cCobBem, dData, cHora, nAtuCont)

	Local cAliasSTP := GetNextAlias()
	Local cQuery    := ""
	Local cTipoLan  := ""
	LOcal cTpLanLt  := ""
	Local nLoop     := 0
	Local nCont     := -1

	aArea := GetArea()

	Default cCobBem  := ""
	Default dData    := CToD("")
	Default cHora    := ""
	Default nAtuCont := 0

	//----------------------------------------------------------
	// ValidaÁ„o para os par‚metros obrigatÛrios
	// Em alguns casos essa funÁ„o È acionada antes da definiÁ„o
	//----------------------------------------------------------
	If Empty( cCobBem ) .Or. Empty( dData ) .Or. Empty( cHora )
		Return 0
	EndIf

	cTipoLan := NGUSELANEX( cCobBem )

	If Empty( cTipoLan ) //Se o par‚metro n„o existir ou estiver vazio, n„o busca o contador.
		If FunName() $ 'MNTA291/MNTA280/MNTA295' .And. Altera
			Return TQB->TQB_POSCON
		ElseIf IsInCallStack('MNTA902') .And. Type('TIPOACOM') != 'U' .And. !TIPOACOM
			Return 0
		ElseIf Type("M->TJ_POSCONT") != "U"
			Return M->TJ_POSCONT
		Else
			Return 0
		EndIf
	EndIf

	If (IsInCallStack("MNTA400") .Or. IsInCallStack("MNTA435")) .And.;
			(Type("M->TJ_CODBEM") != "U" .And. Type("M->TJ_DTORIGI") != "U" .And. Type("M->TJ_HORACO1") != "U")
		cCobBem := M->TJ_CODBEM
		dData := IIf(!Empty(M->TJ_DTMRFIM), M->TJ_DTMRFIM, M->TJ_DTORIGI)
		cHora := M->TJ_HORACO1
		nAtuCont := M->TJ_POSCONT
	EndIf

	If cTipoLan != '-1' .And. Len(cTipoLan) > 1// Forma uma lista separada por vÌrgula dos tipos de contadores a serem listados. Ex.: "A, C"
		For nLoop := 1 to Len(cTipoLan)
			cTpLanLt += SubStr(cTipoLan,nLoop,1)
			cTpLanLt += If(nLoop < Len(cTipoLan), ', ','')
		Next nLoop
	Else
		cTpLanLt := cTipoLan
	EndIf
	//TODO quando for implementado mais de um tipo de contador para o par‚metro NGLANEX,
	//ser· necess·rio saber qual tipo de contador (A,C, etc.) deve ser considerado no SELECT abaixo.
	//Provavelmente a vari·vel cTpLanLt dever· conter apenas uma letra, referente ao tipo do contador que ser· filtrado.
	cQuery := "SELECT TP_POSCONT, TP_DTLEITU, TP_HORA"+;
		"  FROM " + RetSqlName("STP")+;
		" WHERE TP_FILIAL = "+ ValToSQL(xFilial("STP")) +;
		"   AND TP_CODBEM = "+ ValToSQL(cCobBem) +;
		"   AND TP_TIPOLAN IN('" + cTpLanLt + "','Q','V','I')"+;
		"   AND D_E_L_E_T_ = ' '"+;
		" ORDER BY TP_DTLEITU || TP_HORA DESC"

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasSTP, .F., .T.)
	dbSelectArea(cAliasSTP)
	dbGoTop()

	While !Eof()

		If (((cAliasSTP)->TP_DTLEITU+(cAliasSTP)->TP_HORA <= DToS(dData)+cHora) .Or. (Empty(cHora) .And. (cAliasSTP)->TP_DTLEITU <= DToS(dData)))

			nCont := (cAliasSTP)->TP_POSCONT

			Exit

		EndIf

		(cAliasSTP)->(dbSkip())

	EndDo

	(cAliasSTP)->(dbCloseArea())

	RestArea(aArea)

Return IIF(nCont == -1, nAtuCont, nCont)
//----------------------------------------------------------------
/*/{Protheus.doc} NGBlCont()
Bloqueia o campo de contador caso o par‚metro LANEX exista e
contenha o valor correspondente ao tipo de contador a ser bloqueado.

@param cBemSt9, string, cÛdigo do bem
@author Wexlei Silveira
@since 10/05/2016
@return lRet .F. para bloquear o campo ou .T. para n„o bloquear
/*/
//----------------------------------------------------------------
Function NGBlCont( cBemSt9, lVerVar )

	Local lRet := .F.

	Default cBemSt9  := ""
	Default lVerVar  := .T.

	//Retorna .F. se o conte˙do for A, bloqueando o campo de contador nas rotinas n„o relacionadas a abastecimento
	lRet := !( NGUSELANEX( cBemSt9 ) $ "A")

	If lVerVar .And. Type("TIPOACOM") != "U"
		lRet := lRet .And. TIPOACOM
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTCTemp
Cria as tabelas tempor·rias relacionadas ao contador/estrutura de bens para
garantir que, em banco de dados oracle, os registros n„o sejam inseridos
quando houver alguma inconsistÍncia durante o processo.

@type function

@param [aTrbEst], Array, Possui as tabelas tempor·rias respons·veis por montar
						a estrutura do bem.
						[1] tabela temporaria do pai da estrutura - cTRBS
						[2] tabela temporaria do pai da estrutura - cTRBF
						[3] tabela temporaria do eixo suspenso    - CTRBEixo

@author Diego de Oliveira
@since 22/05/2019

@return .T.
/*/
//---------------------------------------------------------------------
Function MNTCTemp( aTrbEst )

	Local aIdxSTC   := {{"TCODBEM"},{"TCOMPON"}}
	Local aIdxTRBF  := {{"FCOMPON"},{"FDTMOVI"}}
	Local vINDEixo  := {{"EIXO"}}
	Local ADBFP     := {}
	Local aDBFF     := {}
	Local aDBFEixo  := {}

	Default aTrbEst := {}

	If Len(aTrbEst) > 0
		cTRBF 	 := aTrbEst[1]
		cTRBS 	 := aTrbEst[2]
		CTRBEixo := aTrbEst[3]
	EndIf

	Aadd(ADBFP,{"TCODBEM","C",16,0})
	Aadd(ADBFP,{"TTIPOBE","C",01,0})
	Aadd(ADBFP,{"TCOMPON","C",16,0})
	Aadd(ADBFP,{"TTIPOCO","C",01,0})
	Aadd(ADBFP,{"TTIPOMO","C",01,0})
	Aadd(ADBFP,{"TDTMOVI","D",08,0})
	Aadd(ADBFP,{"TDTSAID","D",08,0})
	Aadd(ADBFP,{"THORAEN","C",05,0})
	Aadd(ADBFP,{"THORASA","C",05,0})
	Aadd(ADBFP,{"TSELECI","C",01,0})
	Aadd(ADBFP,{"TLOCALI","C",06,0})
	Aadd(ADBFP,{"REPASSA","C",01,0})

	oTmpTblSTC := NGFwTmpTbl(cTRBS,ADBFP,aIdxSTC)

	Aadd(aDBFF,{"FCODBEM","C",16,0})
	Aadd(aDBFF,{"FTIPOBE","C",01,0})
	Aadd(aDBFF,{"FCOMPON","C",16,0})
	Aadd(aDBFF,{"FTIPOCO","C",01,0})
	Aadd(aDBFF,{"FDTMOVI","D",08,0})
	Aadd(aDBFF,{"FTIPOMO","C",01,0})
	Aadd(aDBFF,{"FDTSAID","D",08,0})
	Aadd(aDBFF,{"FHORAEN","C",05,0})
	Aadd(aDBFF,{"FHORASA","C",05,0})
	Aadd(aDBFF,{"FLOCALI","C",06,0})
	Aadd(aDBFF,{"REPASSA","C",01,0})

	//Alias: cTRBF

	oTpTbTRBF := NGFwTmpTbl(cTRBF,aDBFF,aIdxTRBF)

	aAdd(aDBFEixo,{"OK"    , "C", 02, 0})
	aAdd(aDBFEixo,{"EIXO"  , "C", 10, 0})
	aAdd(aDBFEixo,{"DESCRI", "C", 20, 0})

	// Cria arquivos para Eixo Suspenso
	oTmpTbl := NGFwTmpTbl( CTRBEixo, aDBFEixo, vINDEixo )

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTDTemp
Deleta as tabelas tempor·rias criadas pela funÁ„o MNTCTemp.

@type function

@author Diego de Oliveira
@since 22/05/2019

@return .T.
/*/
//---------------------------------------------------------------------
Function MNTDTemp()

	oTpTbTRBF:Delete()
	oTmpTblSTC:Delete()
	oTmpTbl:Delete()

Return .T.

//----------------------------------------------------------------
/*/{Protheus.doc} MNTCont2
Verifica se o campo de contador 2 pode ser habilitado
@type function

@author Tain„ Alberto Cardoso
@since 04/11/2019

@param cFilCont    , string, Filial do bem.
@param cCodBem     , string, CÛdigo do bem.
@param [lChkStruct], boolean, Define se deve considerar controle 
de contador por estrutura.

@return lRet .F. para bloquear o campo ou .T. para n„o bloquear
/*/
//----------------------------------------------------------------
Function MNTCont2( cFilCont, cCodBem, lChkStruct )

	Local lRet         := .F.

	Default lChkStruct := .F.

	dbSelectArea('TPE')
	dbSetOrder(1) //TPE_FILIAL+TPE_CODBEM
	If dbSeek( xFilial( 'TPE', cFilCont ) + cCodBem ) .And. TPE->TPE_SITUAC == '1'

		cHasCounter := NGSEEK( 'ST9', cCodBem, 1, 'T9_TEMCONT' )

		lRet := ( cHasCounter == 'S' ) .Or. ( IIf( lChkStruct, cHasCounter $ 'P#I', .F. ) )

	EndIf

Return lRet

//----------------------------------------------------------------
/*/{Protheus.doc} fIncrement
Verifica se deve incrementar km da banda

@param cCodBem, string, cÛdigo do bem
@param dDataAtu, date, data do lanÁamento
@param cHoraAtu, string, hora do lanÁamento
@param cTipoLan, string, tipo de lanÁamento
@param dDataPost, date, data do lanÁamento posterior
@param cHoraPost, string, hora do lanÁamento posterior
@param cTipPost, string, tipo de lanÁamento posterior

@author Maria Elisandra de Paula
@since 07/02/2020

@return string
/*/
//----------------------------------------------------------------
Static Function fIncrement( cCodBem, dDataAtu, cHoraAtu, cTipAtu, dDataPost, cHoraPost, cTipPost )

	Local lReturn    := .F.
	Local cAliasQry  := GetNextAlias()

	//--------------------------------------------------------------------------------------------
	// Verifica se existem reformas apÛs o lanÁamento do contador e antes do prÛximo registro da STP
	//--------------------------------------------------------------------------------------------
	BeginSql Alias cAliasQry

		SELECT COUNT( TJ_FILIAL ) AS REFORMAS
		FROM %Table:STJ% STJ
		WHERE STJ.TJ_FILIAL = %xFilial:STJ%
			AND STJ.%notDel%
			AND STJ.TJ_CODBEM = %exp:cCodBem%
			AND STJ.TJ_SITUACA = 'L'
			AND STJ.TJ_TERMINO = 'S'
			AND STJ.TJ_DTMRFIM || STJ.TJ_HOMRFIM >= %Exp:Dtos( dDataAtu ) + cHoraAtu%
			AND STJ.TJ_DTMRFIM || STJ.TJ_HOMRFIM < %Exp:Dtos( dDataPost ) + cHoraPost%
			AND STJ.TJ_SERVICO IN
				( SELECT ST4.T4_SERVICO FROM %Table:ST4% ST4
					WHERE ST4.T4_VIDAUTI = 'S'
						AND ST4.%notDel%
						AND ST4.T4_FILIAL = %xFilial:ST4%
				)

	EndSql

	// Se existir reforma deve incrementar o km da banda
	lReturn := (cAliasQry)->REFORMAS > 0

	(cAliasQry)->( dbCloseArea() )

	If !lReturn .And. NGUSELANEX( cCodBem, .F., dDataAtu, cHoraAtu ) == "A" .And. cTipAtu == "A"

		If cTipPost == "A" // se o lanÁamento posterior È A n„o h· necessidade de incrementar o km da banda
			lReturn := .F.
		Else

			//-----------------------------------------------------------------------------
			// Verifica se h· pelo menos um lanÁamento tipo A apÛs a data.
			// Se houver n„o h· necessidade de incrementar o km da banda
			//-----------------------------------------------------------------------------
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry

				SELECT COUNT( STP.TP_POSCONT ) QUANTD
				FROM %Table:STP% STP
				WHERE STP.TP_CODBEM = %exp:cCodBem%
					AND STP.TP_FILIAL = %xFilial:STP%
					AND STP.TP_DTLEITU || STP.TP_HORA > %Exp:Dtos( dDataAtu ) + cHoraAtu%
					AND TP_TIPOLAN = 'A'
					AND %notDel%

			EndSql

			lReturn := (cAliasQry)->QUANTD == 0

			(cAliasQry)->(dbCloseArea())

		EndIf

	EndIf

Return lReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} MntInfCnt
Valida e insere contador.

@author Tain„ Alberto Cardoso
@since 12/05/2020

@param cCodBem, Caractere, CÛdigo do bem
@param dData, Data, Data do lanÁamento
@param cHora, Caractere, Hora do lanÁamento
@param nTpCont, NumÈrico, Tipo de contador
@param nContador, NumÈrico, PosiÁ„o do contador

@return cErro, Caractere, Mensagem de erro, ou vazio se validado com sucesso
/*/
//---------------------------------------------------------------------
Function MntInfCnt(cCodBem, dData, cHora, nTpCont, nContador)

	Local lRet := .T.


	If nContador <= 0
		lRet := .F.
		Help(Nil, Nil, '', Nil, STR0161, 1, 0)// PosiÁ„o de contador deve ser maior que zero.
	EndIf

	//------------------------------------------------
	// Valida se o bem existe e est· ativo na filial
	//------------------------------------------------
	If lRet

		lRet := NGBemAtiv(cCodBem)

	EndIf

	If lRet

		dbSelectArea( 'ST9' )
		dbSetOrder(1)
		If dbSeek(xFilial("ST9") + cCodBem)

			If ST9->(FieldPos("T9_MSBLQL")) > 0 .And. ST9->T9_MSBLQL == "1"

				Help(Nil, Nil, STR0015, Nil, STR0163, 1, 0) // O bem est· bloqueado e n„o pode ser utilizado.
				lRet := .F.

			ElseIf ST9->T9_TEMCONT != 'S'

				Help(Nil, Nil, STR0015, Nil, STR0014, 1, 0) // Bem n„o È controlado por contador.
				lRet := .F.

			EndIf

		EndIf

	EndIf

	//------------------------------------------------
	// Valida o par‚metro de hora
	//------------------------------------------------
	If lRet

		lRet := NGValHora(cHora, .T., .T.)

	EndIf

	// -----------------------------------------------
	// Valida o lanÁamento no histÛrico
	// -----------------------------------------------
	If lRet

		lRet := NGCHKHISTO(cCodBem, dData, nContador, cHora, nTpCont,, .T.)

	Endif

	// -----------------------------------------------
	// Valida a posiÁ„o do contador com o limite
	// -----------------------------------------------
	If lRet

		lRet := CHKPOSLIM(cCodBem, nContador, nTpCont,, .T.)

	EndIf

	//------------------------------------------------------
	// Valida a variaÁ„o dia (intervalo de valores v·lidos)
	//------------------------------------------------------
	If lRet

		lRet := NGVALIVARD(cCodBem, nContador, dData, cHora, nTpCont,.T.)

	Endif

	// -----------------------------------------------------
	// Efetua o reporte do contador, se validado com sucesso
	// -----------------------------------------------------
	If lRet

		NGTRETCON(cCodBem, dData, nContador, cHora, nTpCont,, .T., 'C',, .F.)

	EndIf

Return lRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} NGUSELANEX
Verifica se bem usa lanex, controle sÛ por abastecimento

@author Maria Elisandra de paula
@since 31/07/2020

@param cBemSt9, string, CÛdigo do bem
@param [lBlocking], boolean, indica se È verificaÁ„o para bloqueio de campo
@param [dDtMov], date, data da movimentaÁ„o
@param [cHrMov], string, hora da movimentaÁ„o
@param [cToCheck], string, cÛdigo do pai, quando j· est· identificado
@param [cUseLanex], string, conte˙do do par‚metro

@return string, conteudo do lanex (considera) ou vazio (desconsidera)
/*/
//-------------------------------------------------------------------------------
Function NGUSELANEX( cBemSt9, lBlocking, dDtMov, cHrMov, cToCheck, cUseLanex )

	Local aArea       := GetArea()
	Default cBemSt9   := ""
	Default cToCheck  := ""
	Default lBlocking := .T.
	Default cUseLanex := AllTrim( SuperGetMv( 'MV_NGLANEX', .F., '' ) )

	If Empty( cUseLanex )
		RestArea( aArea )
		Return ""
	ElseIf cUseLanex != "A" .Or. Empty( cBemSt9 )
		RestArea( aArea )
		Return cUseLanex
	EndIf

	dbSelectArea("ST9")
	dbSetOrder(1)
	If dbSeek( xFilial("ST9") + cBemSt9 )
		If ST9->T9_TEMCONT == 'S'
			If lBlocking .And. ST9->T9_CATBEM == "3"
				RestArea( aArea )
				Return "A" // pneus deixar campo bloqueado
			EndIf
			cToCheck := cBemSt9 // tem contador prÛprio deve verificar se ele mesmo possui tanque
		ElseIf lBlocking
			RestArea( aArea )
			Return "A" // quando utilizado para bloquear campo contador mas n„o tem contador prÛprio
		EndIf
	EndIf

	//--------------------------------------------------
	// busca pai, usado somente para recalculo
	//--------------------------------------------------
	If Empty( cToCheck )
		// para pneus e comp sem contador prÛprio verifica o pai
		cToCheck := NGBEMPAI( cBemSt9, dDtMov, cHrMov )
		If Empty( cToCheck )
			cToCheck := cBemSt9 // quando nunca entrou em estrutura
		EndIf
	EndIf

	//----------------------------------------------------------------------------
	// quando n„o tem tanque, n„o È controlado por abastecimento, retorna vazio
	//----------------------------------------------------------------------------
	dbSelectArea("TT8")
	dbSetOrder(1)
	If !dbSeek( xFilial("TT8") + cToCheck )
		cUseLanex := ""
	EndIf

	RestArea( aArea )

Return cUseLanex

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTCONWHEN
When do campo contador, utilizado para lanex

@author Maria Elisandra de paula
@since 05/08/2020
@param cField, string, Campo em uso
@return boolean, se campo fica aberto
/*/
//---------------------------------------------------------------------
Function MNTCONWHEN( cField )

	Local lRet := .T.

	If cField == "TJ_POSCONT"
		lRet := TIPOACOM .And. NGBlCont( M->TJ_CODBEM )
	ElseIf cField == "TZ_POSCONT"
		lRet := NGBlCont()
	ElseIf cField == "TZ_CONTSAI"
		lRet := NGBlCont()
	ElseIf cField == "TPN_POSCON"
		lRet := TIPOACOM .And. NGBlCont( ST9->T9_CODBEM )
	ElseIf cField == "TQ2_POSCON"
		lRet := TIPOACOM .And. NGBlCont( M->TQ2_CODBEM )
	ElseIf cField == "TQA_POSCON"
		lRet := TIPOACOM .And. NGBlCont( M->TQA_CODBEM )
	ElseIf cField == "TTI_POS1EN"
		lRet := TIPOACOM .And. NGBlCont( M->TTI_CODVEI )
	ElseIf cField == "TTI_POS1SA"
		lRet := TIPOACOM .And. NGBlCont( M->TTI_CODVEI )
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTCONRELA
RelaÁ„o do campo contador, utilizado para lanex

@author Maria Elisandra de paula
@since 05/08/2020
@param cField, string, Campo em uso
@return numÈrico, valor do contador
/*/
//---------------------------------------------------------------------
Function MNTCONRELA( cField )

	Local nCount := 0

	If cField == "TJ_POSCONT"
		nCount := IIF( TIPOACOM, ST9->T9_POSCONT, 0 )
	ElseIf cField == "TZ_POSCONT"
		nCount := NGTpCont(M->TZ_CODBEM, M->TZ_DATAMOV, M->TZ_HORAENT)
	ElseIf cField == "TZ_CONTSAI"
		nCount := NGTpCont(M->TZ_CODBEM, M->TZ_DATASAI, M->TZ_HORASAI)
	ElseIf cField == "TPN_POSCON"
		nCount := IIF( TIPOACOM, ST9->T9_POSCONT, 0 )
	ElseIf cField == "TQA_POSCON"
		nCount := NGTpCont(M->TQA_CODBEM, M->TQA_DTLEI1, M->TQA_HORAC1)
	ElseIf cField == "TTI_POS1EN"
		nCount := NGTpCont(M->TTI_CODVEI, M->TTI_DTENT, M->TTI_HRENT)
	ElseIf cField == "TTI_POS1SA"
		nCount := NGTpCont(M->TTI_CODVEI, M->TTI_DTSAI, M->TTI_HRSAI)
	EndIf

Return nCount

//---------------------------------------------------------------------
/*/{Protheus.doc} fVldLanex
ValidaÁıes de contador para ambiente que usa lanex

@author Maria Elisandra de paula
@since 21/12/2021
@param cFilBem, string, filial do bem
@param cCodBem, string, cÛdigo do bem
@param dDtLeitu, date, data do lanÁamento
@param cHoraLei, string, hora do lanÁamento
@param nPosCont, numeric, valor do contador
@param nTipoC,   numeric, n˙mero do contador(1/2)
@return string, mensagem de erro
/*/
//---------------------------------------------------------------------
Static Function fVldLanex( cFilBem, cCodBem, dDtLeitu, cHoraLei, nPosCont, nTipoC  )

	Local aAreaSTP := STP->( FWGetArea() )
	Local cError   := ''

	Local aTabInf  := {}

	Default nTipoC := 1

	If nTipoC == 1
		aTabInf := { 'STP', 'STP->TP_FILIAL', 'STP->TP_POSCONT',;
					 'STP->TP_CODBEM' , 'STP->TP_TIPOLAN' }
	Else
		aTabInf := { 'TPP', 'TPP->TPP_FILIAL', 'TPP->TPP_POSCON',;
					 'TPP->TPP_CODBEM', 'TPP->TPP_TIPOLA' }
	EndIf

	/*----------------------------------------------------+
	| Verifica se h· um lanÁamento com mesma data e hora. |
	+----------------------------------------------------*/
	dbSelectArea( aTabInf[1] )
	dbSetOrder( 5 ) // TP_FILIAL + TP_CODBEM + TP_DTLEITU + TP_HORA
	If msSeek( cFilBem + cCodBem + DToS( dDtLeitu ) + cHoraLei, .T. )

		cError := fVldMsg( dDtLeitu, cHoraLei, Nil, &(aTabInf[3]), 1 )

	EndIf
		
	/*--------------------------------------------------------+
	| Verifica se o contador È menor que alguma STP anterior. |
	+--------------------------------------------------------*/
	If Empty( cError )

		&(aTabInf[1])->( dbSkip( -1 ) )

		If &(aTabInf[1])->( !BoF() ) .And. &(aTabInf[2]) == cFilBem .And. &(aTabInf[4]) == cCodBem .And.;
			&(aTabInf[3]) > nPosCont

			cError := fVldMsg( dDtLeitu, cHoraLei, Nil, &(aTabInf[3]), 2 )

		EndIf

		&(aTabInf[1])->( dbSkip() )

	EndIf

	/*---------------------------------------------------------+
	| Verifica se o contador È maior que alguma STP posterior. |
	+---------------------------------------------------------*/
	If Empty( cError )

		While &(aTabInf[1])->( !EoF() ) .And. &(aTabInf[2]) == cFilBem .And. &(aTabInf[4]) == cCodBem

			If &(aTabInf[5]) $ 'Q/V'

				Exit

			ElseIf &(aTabInf[5]) == 'A' 

				If &(aTabInf[3]) < nPosCont

					cError := fVldMsg( dDtLeitu, cHoraLei, Nil, &(aTabInf[3]), 3 )

				EndIf

				Exit

			EndIf

			&(aTabInf[1])->( dbSkip() )

		End
	
	EndIf

	FWRestArea( aAreaSTP )

Return cError

//---------------------------------------------------------------------
/*/{Protheus.doc} fVldMsg
Retorna mensagem de erro para reporte de contador

@author Maria Elisandra de paula
@since 21/12/2021

@param dDtLeitu, date, data do lanÁamento
@param cHoraLei, string, hora do lanÁamento
@param cTipoC, string, tipo de contador: 1 ou 2
@param cContador, numeric, valor do contador
@param cTipoMsg, string, tipo de mensagem

@return string, mensagem de erro
/*/
//---------------------------------------------------------------------
Static Function fVldMsg( dDtLeitu, cHoraLei, cTipoC, cContador, nTipoMsg )

	Local cMENSA   := ''

	Default cTipoC := '1'
	
	Do Case
	
		Case nTipoMsg == 1

			// J· existe um lancamento para o contador ### com as caracteristicas:
			cMENSA += STR0024 + Space( 1 ) + cTipoC + Space( 1 ) + STR0025 + CRLF + CRLF 

		Case nTipoMsg == 2

			// O Contador ### informado e menor do que o do lancamento do historico.
			cMENSA += STR0029 + Space( 1 ) + cTipoC + Space( 1 ) + STR0030 + CRLF + CRLF 

		Case nTipoMsg == 3

			// O Contador ### informado e maior do que o do lancamento do historico.
			cMENSA += STR0029 + Space( 1 ) + cTipoC + Space( 1 ) + STR0031 + CRLF + CRLF 

	End Case

	cMENSA += STR0026 + DToC( dDtLeitu ) + CRLF                      // Data Lancamento..:
	cMENSA += STR0028 + cHoraLei + CRLF                              // Hora Lancamento..: 
	cMENSA += STR0027 + AllTrim( Str( cContador, 9 ) ) + CRLF + CRLF // Contador.........:

Return cMENSA


//-------------------------------------------------------------------
/*/{Protheus.doc} NgRecTTV
FunÁ„o respons·vel por realizar o rec·lculo dos campos TTV_POSINI,
TTV_POSFIM, TTV_ACUMCO, e TTV_MOTIVO no caso de um registro
retroativo.

@type   Function

@author Jo„o Ricardo Santini Zandon·
@since  27/10/2022
@param  aValues, Array, Dados do abastecimento cadastrado / alterado ou excluÌdo.
	aValues[1] = Posto
	aValues[2] = Loja
	aValues[3] = Tanque
	aValues[4] = Bomba
	aValues[5] = Data
	aValues[6] = Hora

@param nOpx,     NumÈrico, OperaÁ„o realizada no abastecimento.

/*/
//-------------------------------------------------------------------
Function NgRecTTV( aValues, nOpx )

	Local cAliasQry   := ''
	Local aBind       := {}
	Local nLimBomb    := 0
	Local nLastFinal  := 0
	Local nAcum       := 0
    Local aAreaTTV    := TTV->( GetArea() )

	If nOpx == 5
	
		cAliasQry   := GetNextAlias()

		BeginSql Alias cAliasQry
		
			SELECT TTV.TTV_POSINI, TTV.TTV_POSFIM, TTV.TTV_ACUMCO FROM %Table:TTV% TTV
			
			WHERE TTV.TTV_FILIAL = %xFilial:TTV%
			AND   TTV.TTV_POSTO  = %exp:aValues[1]%
			AND   TTV.TTV_LOJA   = %exp:aValues[2]%
			AND   TTV.TTV_TANQUE = %exp:aValues[3]%
			AND   TTV.TTV_BOMBA  = %exp:aValues[4]% 
			AND   ((TTV.TTV_DATA = %exp:aValues[5]% AND TTV.TTV_HORA < %exp:aValues[6]%); 
				OR (TTV.TTV_DATA < %exp:aValues[5]%))
			AND   TTV.%NotDel%
			
			ORDER BY TTV.TTV_DATA DESC
		
		EndSql

		If (cAliasQry)->( !EoF() )

			nLastFinal := (cAliasQry)->TTV_POSFIM
			nAcum      := (cAliasQry)->TTV_ACUMCO
		
		EndIf

		(cAliasQry)->( dbCloseArea() )

	Else
		
		dbSelectArea( 'TTV')
		dbSetOrder( 1 )      //TTV_FILIAL+TTV_POSTO+TTV_LOJA+TTV_TANQUE+TTV_BOMBA+DTOS(TTV_DATA)+TTV_HORA+TTV_NABAST
		If dbSeek( xFilial( 'TTV' ) + aValues[ 1 ] + aValues[ 2 ] + aValues[ 3 ] + aValues[ 4 ] + DTOS( aValues[ 5 ] ) + aValues[ 6 ] )
			
			nLastFinal := TTV->TTV_POSFIM
			nAcum      := TTV->TTV_ACUMCO

		EndIf

	EndIf

	// Query realizada para quando o registro cadastrado for retroativo, os cadastros de abastecimentos
	// posteriores com virada de contador da bomba sejam recalculados
	If Empty( cQryAbaTTV )

		cQryAbaTTV := 'SELECT '
		cQryAbaTTV += 'TTV.R_E_C_N_O_ AS RECNO, TQJ_LIMCON AS LIMITE '
		cQryAbaTTV += 'FROM '
		cQryAbaTTV += RetSqlName('TTV') + ' TTV '
		cQryAbaTTV += 'INNER JOIN '+RetSqlName('TQJ')+' TQJ ON TQJ.TQJ_FILIAL = TTV.TTV_FILIAL AND TQJ.TQJ_CODPOS = TTV.TTV_POSTO AND TQJ.TQJ_LOJA = TTV.TTV_LOJA AND TQJ.TQJ_TANQUE = TTV.TTV_TANQUE AND TQJ.TQJ_BOMBA = TTV.TTV_BOMBA '
		cQryAbaTTV += 'WHERE '
		cQryAbaTTV += 'TTV.TTV_FILIAL = ? AND '
		cQryAbaTTV += 'TTV.TTV_POSTO  = ? AND '
		cQryAbaTTV += 'TTV.TTV_LOJA   = ? AND '
		cQryAbaTTV += 'TTV.TTV_TANQUE = ? AND '
		cQryAbaTTV += 'TTV.TTV_BOMBA  = ? AND '
		cQryAbaTTV += 'TTV.TTV_MOTIVO <> ? AND '
		cQryAbaTTV += '(TTV.TTV_DATA > ? OR (TTV.TTV_DATA = ? AND TTV.TTV_HORA > ?)) AND '
		cQryAbaTTV += 'TTV.D_E_L_E_T_ = ? '
		cQryAbaTTV += 'ORDER BY TTV_DATA || TTV.TTV_HORA'

		cQryAbaTTV := ChangeQuery(cQryAbaTTV)

	EndIf
	
	aBind := {}

	aAdd( aBind, FWxFilial( 'TTV' ) )
	aAdd( aBind, aValues[1] )
	aAdd( aBind, aValues[2] )
	aAdd( aBind, aValues[3] )
	aAdd( aBind, aValues[4] )
	aAdd( aBind, '3' )
	aAdd( aBind, DTOS(aValues[5]) )
	aAdd( aBind, DTOS(aValues[5]) )
	aAdd( aBind, aValues[6] )
	aAdd( aBind, Space( 1 ))

	cAliasQry := GetNextAlias()

	dbUseArea( .T., 'TOPCONN', TcGenQry2( , , cQryAbaTTV, aBind ), cAliasQry, .T., .T. )
	
	While (cAliasQry)->( !EoF() )
		
		dbSelectArea( 'TTV' )
		msGoTo( (cAliasQry)->RECNO )

		nLimBomb := (cAliasQry)->LIMITE

		RecLock( 'TTV', .F. )

		TTV->TTV_POSINI := nLastFinal

		If ( nLastFinal + TTV->TTV_CONSUM ) > nLimBomb
		
			TTV->TTV_POSFIM := ( nLastFinal + TTV->TTV_CONSUM ) - nLimBomb
			TTV->TTV_MOTIVO := '2'

		Else

			TTV->TTV_POSFIM := nLastFinal + TTV->TTV_CONSUM
			TTV->TTV_MOTIVO := '1'

		EndIf
		
		TTV->TTV_ACUMCO := nAcum + TTV->TTV_CONSUM	
		nLastFinal      := TTV->TTV_POSFIM
		nAcum           := TTV->TTV_ACUMCO
		TTV->( MsUnLock() )	

	    (cAliasQry)->( dbSkip() )
	
	End

	(cAliasQry)->( dbCloseArea() )

    RestArea( aAreaTTV )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} NgRecTTA
FunÁ„o respons·vel por realizar o rec·lculo do campo TTA_CONBOM no caso
de ser realizada uma saÌda de combustÌvel retroativa.

@type   Function

@author Jo„o Ricardo Santini Zandon·
@since  31/01/2023
@param nOpx,     NumÈrico, OperaÁ„o realizada no abastecimento.
@param  aValues, Array,    Dados do abastecimento cadastrado / alterado ou excluÌdo.
	aValues[1] = Posto
	aValues[2] = Loja
	aValues[3] = Tanque
	aValues[4] = Bomba
	aValues[5] = Data
	aValues[6] = Hora
	aValues[7] = Quantidade
	aValues[8] = Quantidade Antiga

/*/
//-------------------------------------------------------------------
Function NgRecTTA(nOpx, aValues)

	Local cAliasQry   := GetNextAlias()
	Local nQuantSaid  := 0

	// Trecho abaixo serve para que em caso de alteraÁ„o n„o seja somado novamente a quantidade apenas a diferenÁa
	If nOpx == 4

		nQuantSaid := (aValues[7] - aValues[8])

	Else

		nQuantSaid := aValues[7]

	EndIf

	BeginSql Alias cAliasQry
	
		SELECT TTA.R_E_C_N_O_ AS RECNO FROM %Table:TTA% TTA
		
		WHERE TTA.TTA_FILIAL = %xFilial:TTA%
		AND   TTA.TTA_POSTO  = %exp:aValues[1]%
		AND   TTA.TTA_LOJA   = %exp:aValues[2]%
		AND   TTA.TTA_TANQUE = %exp:aValues[3]%
		AND   TTA.TTA_BOMBA  = %exp:aValues[4]% 
		AND   ((TTA.TTA_DTABAS = %exp:aValues[5]% AND TTA.TTA_HRABAS > %exp:aValues[6]%); 
			OR (TTA.TTA_DTABAS > %exp:aValues[5]%))
		AND   TTA.%NotDel%
	
	EndSql

	While (cAliasQry)->( !EoF() )

		TTA->( dbGoTo( (cAliasQry)->RECNO ) )

		RecLock('TTA', .F.)
				
			TTA->TTA_CONBOM := TTA->TTA_CONBOM + nQuantSaid
		
		MsUnlock()

		(cAliasQry)->( dbSkip() )

	End
	
	(cAliasQry)->( dbCloseArea() )

Return .T.
