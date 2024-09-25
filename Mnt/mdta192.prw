#Include 'Protheus.ch'
#Include 'MDTA192.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTA192
Job que realiza a verificação de funcionários demitidos que tenham
histórico de exposição ao agente asbesto, para a programação de exames
relacionados, efetuando o contínuo acompanhamento médico, de acordo com
a NR15

@type    function
@author  Julia Kondlatsch
@since   09/07/2019
@sample  MDTA192()

@Obs Conforme o item 19 da NR15:
'Cabe ao empregador, após o término do contrato de trabalho envolvendo
exposição ao asbesto, manter disponível a realização periódica de exames
médicos de controle dos trabalhadores durante 30 (trinta) anos.'

Logo após, no item 19.1, consta: 'Estes exames deverão ser realizados
com a seguinte periodicidade:
a) A cada 3 (três) anos para trabalhadores com período de exposição
de 0 (zero) a 12 (doze) anos;
b) A cada 2 (dois) anos para trabalhadores com período de exposição
de 12 (doze) a 20 (vinte) anos;
c) Anual para trabalhadores com período de exposição superior a 20
(vinte) anos.'

@return  Nil, Sempre nulo
/*/
//-------------------------------------------------------------------
Function MDTA192()

	Local cSRAFil    := xFilial('SRA')
	Local aDBF       := {}
	Local aPeriodos  := {}

	Private cAlsDem    := GetNextAlias()
	Private lSigaMdtPS := SuperGetMv( 'MV_MDTPS' , .F. , 'N' ) == 'S'
	Private aRiscos	   := {}
	Private cTRBHIS    := GetNextAlias()
	Private cTRBTN0    := GetNextAlias()
	Private nSizeSI3   := TAMSX3('I3_CUSTO')[1]
	Private nSizeSRJ   := TAMSX3('RJ_FUNCAO')[1]
	Private nSizeTN5   := TAMSX3('TN5_CODTAR')[1]
	Private nSizeSQB   := TAMSX3('QB_DEPTO')[1]
	Private nSizeCod   := TAMSX3('B1_COD')[1]
	Private nSizeQtA   := TamSX3( 'TN0_QTAGEN' )
	Private cSvFilAnt  := cFilAnt // Salva a Filial Corrente
	Private cSvEmpAnt  := cEmpAnt // Salva a Empresa Corrente
	Private cAsbesto   := SuperGetMv( 'MV_NG2ASBE' , .F. , '' ) // Parâmetro que define o código do agente asbesto

	// cTRBHIS - Histrico - Empresa/Filial/Centro de Custo/Departamanto/Função/Tarefa
	aAdd( aDBF, { 'DTDE'  , 'D', 8             , 0 } )
	aAdd( aDBF, { 'DTATE' , 'D', 8             , 0 } )
	aAdd( aDBF, { 'CNPJ'  , 'C', 20            , 0 } )
	aAdd( aDBF, { 'SEQ'   , 'C', 01            , 0 } )
	aAdd( aDBF, { 'TIPINS', 'N', 01            , 0 } )
	aAdd( aDBF, { 'CUSTO' , 'C', nSizeSI3      , 0 } )
	aAdd( aDBF, { 'DPTHIS', 'C', nSizeSQB      , 0 } )
	aAdd( aDBF, { 'FILIAL', 'C', FwSizeFilial(), 0 } )
	aAdd( aDBF, { 'MATHIS', 'C', 6             , 0 } )
	aAdd( aDBF, { 'CARGO' , 'C', 5             , 0 } )
	aAdd( aDBF, { 'CODFUN', 'C', nSizeSRJ      , 0 } )
	aAdd( aDBF, { 'DESFUN', 'C', 30            , 0 } )
	aAdd( aDBF, { 'DESCAR', 'C', 30            , 0 } )
	aAdd( aDBF, { 'GFIP'  , 'C', 2             , 0 } )
	aAdd( aDBF, { 'EMP'   , 'C', 2             , 0 } )

	oTemHisP := FWTemporaryTable():New( cTRBHIS, aDBF )
	oTemHisP:AddIndex( '1', {'DTDE','DTATE'} )
	oTemHisP:Create()

	// TRBTN0 - Riscos
	aAdd( aDBF, { 'NUMRIS'   , 'C', 09         , 0          } )
	aAdd( aDBF, { 'CODAGE'   , 'C', 06         , 0          } )
	aAdd( aDBF, { 'AGENTE'   , 'C', 40         , 0          } )
	aAdd( aDBF, { 'MAT'      , 'C', 06         , 0          } )
	aAdd( aDBF, { 'DT_DE'    , 'D', 08         , 0          } )
	aAdd( aDBF, { 'DT_ATE'   , 'D', 08         , 0          } )
	aAdd( aDBF, { 'SETOR'    , 'C', nSizeSI3   , 0          } )
	aAdd( aDBF, { 'FUNCAO'   , 'C', nSizeSRJ   , 0          } )
	aAdd( aDBF, { 'TAREFA'   , 'C', 06         , 0          } )
	aAdd( aDBF, { 'DEPTO'    , 'C', nSizeSQB   , 0          } )
	aAdd( aDBF, { 'INTENS'   , 'N', nSizeQtA[1], nSizeQtA[2]} )
	aAdd( aDBF, { 'UNIDAD'   , 'C', 06         , 0          } )
	aAdd( aDBF, { 'TECNIC'   , 'C', 40         , 0          } )
	aAdd( aDBF, { 'PROTEC'   , 'C', 02         , 0          } )
	aAdd( aDBF, { 'EPC'      , 'C', 01         , 0          } )
	aAdd( aDBF, { 'GRISCO'   , 'C', 01         , 0          } )
	aAdd( aDBF, { 'NUMCAP'   , 'C', 12         , 0          } )
	aAdd( aDBF, { 'INDEXP'   , 'C', 01         , 0          } )
	aAdd( aDBF, { 'ATIVO'    , 'C', 01         , 0          } )
	aAdd( aDBF, { 'OBSINT'   , 'C', 20         , 0          } )
	aAdd( aDBF, { 'CODEPI'   , 'C', nSizeCod   , 0          } )
	aAdd( aDBF, { 'AVALIA'   , 'C', 01         , 0          } )
	aAdd( aDBF, { 'NECEPI'   , 'C', 01         , 0          } )
	aAdd( aDBF, { 'MEDCON'   , 'C', 06         , 0          } )
	aAdd( aDBF, { 'TIPCTR'   , 'C', 01         , 0          } )

	oTempTN0 := FWTemporaryTable():New( cTRBTN0, aDBF )
	oTempTN0:AddIndex( '1', {'DT_DE','DT_ATE','NUMRIS'} )
	oTempTN0:AddIndex( '2', {'GRISCO','AGENTE','INTENS','TECNIC','EPC','PROTEC','CODEPI','NUMCAP'} )
	oTempTN0:AddIndex( '3', {'GRISCO','AGENTE','INTENS','TECNIC','DT_DE','DT_ATE'} )
	oTempTN0:AddIndex( '4', { 'MAT' } )
	oTempTN0:Create()

	If lSigaMdtPS
		If !IsBlind()
			MsgInfo( STR0001 ) // "Esta funcionalidade não está disponível para sistemas prestadores de serviço"
		EndIf
	ElseIf Empty(cAsbesto)
		If !IsBlind()
			MsgInfo( STR0002 ) // "Nenhum código de agente foi definido no parâmetro MV_NG2ASBE"
		EndIf
	Else

		// Busca todos os funcionários demitidos
		BeginSQL Alias cAlsDem
			SELECT RA_FILIAL, TM0_FILFUN, TM0_NUMFIC, RA_CC, RA_CODFUNC, RA_DEPTO,
				RA_MAT, RA_ADMISSA, RA_DEMISSA, RA_POSTO, RA_TNOTRAB
			FROM %table:SRA% SRA
			JOIN %table:TM0% TM0 ON
				RA_FILIAL = TM0_FILIAL
				AND RA_MAT = TM0_MAT
				AND TM0.%NotDel%
			WHERE RA_SITFOLH = 'D'
				AND RA_DEMISSA <> ''
				AND RA_FILIAL = %exp:cSRAFil%
				AND SRA.%NotDel%
		EndSQL

		dbSelectArea( cAlsDem )
		While ( cAlsDem )->( !EoF() )

			dbSelectArea('SRA')
			dbSetOrder( 1 )
			dbSeek( cSRAFil+( cAlsDem )->( RA_MAT ) )
			// Traz o histórico do funcionário
			MDTA192HIS()

			// Soma os períodos de exposição
			dbSelectArea( cTRBTN0 )
			( cTRBTN0 )->(dbGoTop())
			While ( cTRBTN0 )->( !EoF() )
				aAdd( aPeriodos, { (cTRBTN0)->DT_DE, (cTRBTN0)->DT_ATE } )
				(cTRBTN0)->(dbSkip())
			EndDo

			// Se houver algum período de exposição gera os exames do funcionário
			If !Empty(aPeriodos)
				fGeraExames( MDTA192INT(aPeriodos) )
			EndIf

			// Limpa variável e TRB
			aPeriodos := {}
			dbSelectArea( cTRBTN0 )
			ZAP
			dbSelectArea( cTRBHIS )
			ZAP
			( cAlsDem )->( dbSkip() )

		End

	EndIf

	oTemHisP:Delete()
	oTempTN0:Delete()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTA192HIS
Carrega os dados do histórico do funcionario posicionado

@Obs     Baseada na função NG700HISTO do PPP
@author  Julia Kondlatsch
@since   16/07/2019
@sample  MDTA192HIS()

@return  Nil, sempre nulo
/*/
//-------------------------------------------------------------------
Function MDTA192HIS( )

	Local nWWW        := 0
	Local nXYZ        := 0
	Local nBeg        := 0
	Local nSizeSRE    := If(TAMSX3('RE_FILIALD')[1] > 0, TAMSX3('RE_FILIALD')[1], Len(SRE->RE_FILIALD))
	Local cCBO        := ' ' // Guarda o CBO da Funcao
	Local lFimHis     := .F. // Verifica se acabou o historico de setores
	Local dDtAdm      := SRA->RA_ADMISSA //Data Admissao
	Local dDtDem      := SRA->RA_DEMISSA // Data limite p/ uma transferencia
	Local aDadosHis   := {} //Grava dados do historico de setores
	Local cDesFunHis  := Space(25) //Descricao da Funcao do periodo anterior
	Local cDesFunFOR  := Space(25) //Descricao da Funcao do periodo anterior
	Local cFuncaoHis  := Space(Len(SRA->RA_CODFUNC)) // Funcao do periodo anterior
	Local cFuncaoFOR  := Space(Len(SRA->RA_CODFUNC)) // Funcao do periodo anterior
	Local cCargoHis   := Space(5)
	Local cDesCarHis  := Space(30)
	Local cCargoFOR   := Space(5)
	Local cDesCarFOR  := Space(30)
	Local cGFIP       := '' //Variavel para receber o ultimo código da SR9, antes de 01/01/2004
	Local lAchou      := .T. //Variavel de Controle
	Local lInicio     := .T. //Variavel de Controle
	Local lTemSR7     := .F. //Variavel de Controle
	Local dDataFOR    := CToD('  /  /  ')
	Local cKeyEmp     := SM0->M0_CODIGO // Empresa origem
	Local cKeyFil     := Padr(SRA->RA_FILIAL,nSizeSRE)// Filial origem
	Local cKeyMat     := SRA->RA_MAT // Matricula origem
	Local cKeyCus     := SRA->RA_CC // Centro Custo origem
	Local cKeyDep     := SRA->RA_DEPTO // Departamento origem
	Local cCondCus    := Space(Len(SRA->RA_CC))
	Local cCondDep    := Space(Len(SRA->RA_DEPTO))
	Local cCondALL    := Space(10)
	Local lFirstSRE   := .T. //Indica se é o primeiro SRE
	Local lFirst      := .T.
	Local lAchouSRE   := .F.
	Local lPrimeiro   := .T.
	Local dDtFimVer   := CToD('  /  /  ')
	Local cFunAnter   := Space(5) //Funcao Anterior, para verificar se nao esta gravando funcao igual
	Local cCarAnter   := Space(5)
	Local cRA_CODFUNC := SRA->RA_CODFUNC //Se nao achar transf. de funcao o programa adota a funcao atual
	Local lCposSR7    := If(Empty(SRA->RA_CARGO),.F.,.T.)
	Local cRA_CARGO   := If(lCposSR7,SRA->RA_CARGO,Space(5)) //Se nao achar transf. de funcao o programa adota a funcao atual
	Local dDateAte    := CToD('  /  /  ') //Data final do funcionario em uma determinada funcao
	Local aDadosTmp   := {} //Temporario
	Local cModoTM0    := ''
	Local cXFilTM0    := ''
	Local cModoSRA    := ''
	Local cXFilSRA    := ''
	Local cModoCTT    := ''
	Local cXFilCTT    := ''
	Local cModoSRJ    := ''
	Local cXFilSRJ    := ''
	Local cModoSQ3    := ''
	Local cXFilSQ3    := ''
	Local cModoSR9    := ''
	Local cXFilSR9    := ''
	Local dDataSRE    := CToD('')
	Local aAreaSRE	  := {}
	Local aCargoSv    := {}

	Private cEmpHis     := cEmpAnt
	Private aMatriculas := {}
	Private aFichasUsa  := {}
	Private dDtTransf   := CToD('  /  /  ')
	Private cFilTNF     := ''
	Private lMudEmpr    := .T.
	Private lMudFilial  := .T.
	Private cModo       := ''

	// Busca se houve alguma transferencia do funcionario, baseado nos dados da SRA atual, após é analisado os dados referente a SRE
	lNaoAchou := .T.

	While !lFimHis
		lPrimeiro := .T.
		dDtFimVer  := CToD('  /  /  ')
		cCondCus  := cKeyCus
		cCondDep  := cKeyDep
		cCondALL  := cKeyEmp + cKeyFil + cKeyMat

		dbSelectArea('SRE')
		dbSetOrder(1)
		dbSeek(cCondALL)

		While !Eof() .And. cCondALL == SRE->RE_EMPD+SRE->RE_FILIALD+SRE->RE_MATD

			If SRE->RE_DATA < dDataSRE
				dbSelectArea('SRE')
				dbSkip()
				Loop
			EndIf

			If SRE->RE_EMPP == SRE->RE_EMPD .And. SRE->RE_FILIALP == SRE->RE_FILIALD .And. ;
				SRE->RE_MATP == SRE->RE_MATD .And. SRE->RE_CCP == SRE->RE_CCD .And. SRE->RE_DEPTOP == SRE->RE_DEPTOD
				dbSelectArea('SRE')
				dbSkip()
				Loop
			EndIf

			If (If(lFirstSRE,SRE->RE_DATA > dDataBase,SRE->RE_DATA >= dDataBase)) .Or. ;
				SRE->RE_DATA < dDtAdm
				dbSelectArea('SRE')
				dbSkip()
				Loop
			EndIf

			If SRE->RE_CCD <> cCondCus .Or. SRE->RE_DEPTOD <> cCondDep
				dbSelectArea('SRE')
				dbSkip()
				Loop
			EndIf

			lFirstSRE := .F.

			If lPrimeiro
				dDataSRE := SRE->RE_DATA

				If lMudEmpr
					cKeyEmp := SRE->RE_EMPP
				EndIf

				If lMudFilial
					cKeyFil := SRE->RE_FILIALP
				EndIf

				cKeyMat := SRE->RE_MATP
				cKeyCus := SRE->RE_CCP
				cKeyDep := SRE->RE_DEPTOP
				aADD(aDadosTmp,{SRE->RE_DATA,dDataBase,SRE->RE_FILIALD,SRE->RE_MATD,SRE->RE_CCD,SRE->RE_EMPD,SRE->RE_DEPTOD})
				dDtFimVer := SRE->RE_DATA

			ElseIf SRE->RE_DATA < aDadosTmp[Len(aDadosTmp)][1]

				dDataSRE := SRE->RE_DATA

				If lMudEmpr
					cKeyEmp := SRE->RE_EMPP
				EndIf

				If lMudFilial
					cKeyFil := SRE->RE_FILIALP
				EndIf

				cKeyMat := SRE->RE_MATP
				cKeyCus := SRE->RE_CCP
				cKeyDep := SRE->RE_DEPTOD
				aDadosTmp[Len(aDadosTmp)][1] := SRE->RE_DATA
				dDtFimVer := SRE->RE_DATA

			EndIf

			lPrimeiro := .F.

			// O funcionario esta mudando de Empresa/Filial, portanto, o processo para aqui
			lFimHis := (SRE->RE_EMPP != cEmpHis .And. !lMudEmpr ) .Or. ;
						(SRE->RE_EMPP+SRE->RE_FILIALP != cSvEmpAnt+cSvFilAnt .And. !lMudFilial)

			dbSelectArea('SRE')
			dbSkip()
		End

		If lPrimeiro
			lFimHis := .T.

			If dDtAdm < dDtDem
				aAdd(aDadosTmp,{dDtAdm,dDtDem,cKeyFil,cKeyMat,cKeyCus,cKeyEmp,cKeyDep})
			EndIf

		Else
			dDtDem := dDtFimVer
		EndIf

	End

	If Len(aDadosTmp) > 0
		aSRArea := SRA->(GetArea())
		cKeyEmp := aDadosTmp[Len(aDadosTmp),6] // Empresa origem
		cKeyFil := aDadosTmp[Len(aDadosTmp),3] // Filial origem
		cKeyMat := aDadosTmp[Len(aDadosTmp),4] // Matricula origem
		cKeyCus := aDadosTmp[Len(aDadosTmp),5] // Centro Custo origem
		cKeyDep := aDadosTmp[Len(aDadosTmp),7] // Departamento origem

		If lMudEmpr .And. cKeyEmp != cEmpHis .And. !Empty(cKeyEmp)
			cModo := FWModeAccess('SRA')
			EMP700OPEN('SRA','SRA',1,cKeyEmp,@cModo,Substr(cKeyFil,1,Len(SRA->RA_FILIAL)))
		EndIf

		cModoSRA := FWModeAccess('SRA',1) + FWModeAccess('SRA',2) + FWModeAccess('SRA',3)
		cFilSRA := FwxFilial('SRA',Substr(cKeyFil,1,Len(SRA->RA_FILIAL)),Substr(cModoSRA,1,1),Substr(cModoSRA,2,1),Substr(cModoSRA,3,1))
		dbSelectArea('SRA')
		dbSetOrder(1)
		dbSeek(cFilSRA+cKeyMat)
		dDtDem   := If(Empty(SRA->RA_DEMISSA),dDataBase,SRA->RA_DEMISSA) // Data limite p/ uma transferencia
		dDtDemiss := If(Empty(SRA->RA_DEMISSA),PPPDTDEMIS(),SRA->RA_DEMISSA) //Busca data demissao do SRG
		lDemitido := !Empty( dDtDemiss )

		If lMudEmpr .And. cKeyEmp != cEmpHis .And. !Empty(cKeyEmp)
			EMP700OPEN('SRA','SRA',1,cEmpHis,@cModo)
		EndIf

		RestArea(aSRArea)
	EndIf

	// Busca informações do funcionario quando transferido para outro empresa
	lFirstSRE := .T.
	lFimHis   := .F.

	While !lFimHis
		lPrimeiro := .T.
		dDtFimVer  := CToD('  /  /  ')
		cCondCus  := cKeyCus
		cCondDep  := cKeyDep
		cCondALL  := cKeyEmp + cKeyFil + cKeyMat
		dbSelectArea('SRE')
		dbSetOrder(2)
		dbSeek(cCondALL)

		While !Eof() .And. cCondALL == SRE->RE_EMPP + SRE->RE_FILIALP + SRE->RE_MATP

			If SRE->RE_EMPP == SRE->RE_EMPD .And. SRE->RE_FILIALP == SRE->RE_FILIALD .And. ;
			   SRE->RE_MATP == SRE->RE_MATD .And. SRE->RE_CCP == SRE->RE_CCD .And. SRE->RE_DEPTOP == SRE->RE_DEPTOD
				dbSelectArea('SRE')
				dbSkip()
				Loop
			EndIf

			If (If(lFirstSRE,SRE->RE_DATA > dDtDem,SRE->RE_DATA >= dDtDem)) .Or. ;
				SRE->RE_DATA < dDtAdm
				dbSelectArea('SRE')
				dbSkip()
				Loop
			EndIf

			If Alltrim(SRE->RE_CCP) <> Alltrim(cCondCus) .Or. ( Alltrim(SRE->RE_DEPTOP) <> Alltrim(cCondDep) )
				dbSelectArea('SRE')
				dbSkip()
				Loop
			EndIf

			lFirstSRE := .F.

			If lPrimeiro

				If lMudEmpr
					cKeyEmp := SRE->RE_EMPD
				EndIf

				If lMudFilial
					cKeyFil := SRE->RE_FILIALD
				EndIf

				cKeyMat := SRE->RE_MATD
				cKeyCus := SRE->RE_CCD
				cKeyDep := SRE->RE_DEPTOD
				aAdd(aDadosHis,{SRE->RE_DATA,dDtDem,SRE->RE_FILIALP,SRE->RE_MATP,SRE->RE_CCP,SRE->RE_EMPP,SRE->RE_DEPTOP})
				dDtFimVer := SRE->RE_DATA

			ElseIf SRE->RE_DATA > aDadosHis[Len(aDadosHis)][1]

				If lMudEmpr
					cKeyEmp := SRE->RE_EMPD
				EndIf

				If lMudFilial
					cKeyFil := SRE->RE_FILIALD
				EndIf

				cKeyMat := SRE->RE_MATD
				cKeyCus := SRE->RE_CCD
				cKeyDep := SRE->RE_DEPTOD
				aDadosHis[Len(aDadosHis)][1] := SRE->RE_DATA
				dDtFimVer := SRE->RE_DATA

			EndIf

			lPrimeiro := .F.

			// O funcionario esta mudando de Empresa/Filial, portanto, o processo para aqui
			lFimHis := (SRE->RE_EMPD != cEmpHis .And. !lMudEmpr) .Or. ;
			           (SRE->RE_EMPD+SRE->RE_FILIALD != cSvEmpAnt+cSvFilAnt .And. !lMudFilial)

			dbSelectArea('SRE')
			dbSkip()
		End

		If lPrimeiro
			lFimHis := .T.

			If dDtAdm < dDtDem
				aAdd(aDadosHis,{dDtAdm,dDtDem,cKeyFil,cKeyMat,cKeyCus,cKeyEmp,cKeyDep})
			EndIf

		Else
			dDtDem := dDtFimVer
		EndIf

	End

	If Len(aDadosHis) == 0
		aAdd(aDadosHis,{dDtAdm,dDtDem,SRA->RA_FILIAL,SRA->RA_MAT,SRA->RA_CC,SM0->M0_CODIGO, SRA->RA_DEPTO})
	EndIf

	If Len(aDadosHis) > 0

		For nWWW := 1 to Len(aDadosHis)
			cFilSR7 := Substr(aDadosHis[nWWW][3],1,FwSizeFilial(aDadosHis[nWWW][6]))

			If lMudEmpr .And. aDadosHis[nWWW][6] != cEmpHis
				cModo := FWModeAccess('SR7')
				EMP700OPEN('SR7','SR7',1,aDadosHis[nWWW][6],@cModo,cFilSR7)
			EndIf

			cModoSR7 := FWModeAccess('SR7',1) + FWModeAccess('SR7',2) + FWModeAccess('SR7',3)
			cXFilSR7 := FwxFilial('SR7',cFilSR7,Substr(cModoSR7,1,1),Substr(cModoSR7,2,1),Substr(cModoSR7,3,1))
			lTemSR7 := .F.
			cSeqSR7 := 'Z'
			dbSelectArea('SR7')
			dbSetOrder(1)
			// Se não encontrar, pode ser devido a uma restrição criada na busca por transferências de filial/empresa
			If !dbSeek(cXFilSR7 + aDadosHis[nWWW][4] + DTOS(aDadosHis[nWWW][1]),.T.) .And. (!lMudEmpr .Or. !lMudFilial)
				dbSkip(-1) // Volta um registro e verifica se ainda é do funcionário em questão

				If SR7->R7_MAT == aDadosHis[nWWW][4]
					cFuncaoHis := SR7->R7_FUNCAO
					cDesFunHis := SR7->R7_DESCFUN

					If lCposSR7
						cCargoHis  := SR7->R7_CARGO
						cDesCarHis := SR7->R7_DESCCAR
					EndIf

				EndIf

				lTemSR7 := .T.
			Else

				While !Eof() .And. SR7->R7_FILIAL == cXFilSR7     .And. ;
								SR7->R7_MAT == aDadosHis[nWWW][4] .And. ;
								SR7->R7_DATA <= aDadosHis[nWWW][2]

					If SR7->R7_SEQ <= cSeqSR7
						cFuncaoHis := SR7->R7_FUNCAO
						cDesFunHis := SR7->R7_DESCFUN
						cSeqSR7    := SR7->R7_SEQ

						If lCposSR7
							cCargoHis  := SR7->R7_CARGO
							cDesCarHis := SR7->R7_DESCCAR
						EndIf

						lTemSR7 := .T.
					EndIf

					dbselectArea("SR7")
					dbSkip()
				End

			EndIf

			If !lTemSR7
				// Caso não ocorreu mudança de função (SR7) busca informações na função atual.
				dbSelectArea('SRA')
				dbSetOrder(1)//RA_FILIAL + RA_MAT

				If dbSeek(xFilial('SRA', Substr(aDadosHis[nWWW][3], 1, FwSizeFilial()))  + aDadosHis[nWWW,4] )
					cFuncaoHis	:= SRA->RA_CODFUNC
					cDesFunHis	:= Posicione( 'SRJ' , 1 , xFilial( 'SRJ' ) + cFuncaoHis , 'RJ_DESC' ) //Busca da Descrição da Função

					If lCposSR7 // Caso tenha Cargo na SRA
						cCargoHis := SRA->RA_CARGO // Busca o Cargo
					Else // Caso contrário busca o cargo da Função
						cCargoHis := Posicione( 'SRJ' , 1 , xFilial( 'SRJ' ) + cFuncaoHis , 'RJ_CARGO' ) //Busca o Cargo
					EndIf

					cDesCarHis	:= Posicione( 'SQ3' , 1 , xFilial( 'SQ3' ) + cCargoHis  , 'Q3_DESCSUM' ) //Busca a Descrição do Cargo
				EndIf

			EndIf

			If lMudEmpr .And. aDadosHis[nWWW][6] != cEmpHis
				EMP700OPEN('SR7','SR7',1,cEmpHis,@cModo)
			EndIf

		Next nWWW

	Else
		cFuncaoHis := SRA->RA_CODFUNC
	EndIf

	lAchouSRE := .F.
	aSRArea := SRA->(GetArea())

	For nXYZ := Len(aDadosHis) to 1 Step -1

		If nXYZ != Len(aDadosHis)
			cFunAnter := cFuncaoHis

			If lCposSR7
				cCarAnter := cCargoHis
			EndIf

		Else
			cFunAnter := Space(5)

			If lCposSR7
				cCarAnter := Space(5)
			EndIf

		EndIf

		cFilMat := Substr(aDadosHis[nXYZ][3],1,FwSizeFilial(aDadosHis[nXYZ][6]))

		If (aScan(aMatriculas,{|x| x[1]+x[2]+x[3] == cFilMat+aDadosHis[nXYZ][4] + aDadosHis[nXYZ][6]})) <= 0
			aAdd(aMatriculas,{cFilMat,aDadosHis[nXYZ][4],aDadosHis[nXYZ][6]}) // MAtriculas Utilizadas pelo funcionario na empresa
		EndIf

		aAreaAtual := {}
		aAreaVelha := {}
		dDtTermino := CToD('  /  /    ')
		lAchou     := .T.
		lInicio    := .T.
		lFirst     := .T.

		If lMudEmpr .And. aDadosHis[nXYZ][6] != cEmpHis
			cModo := FWModeAccess('SR7')
			EMP700OPEN('SR7','SR7',1,aDadosHis[nXYZ][6],@cModo,cFilMat)
			cModo := FWModeAccess('SRJ')
			EMP700OPEN('SRJ','SRJ',1,aDadosHis[nXYZ][6],@cModo,cFilMat)
			cModo := FWModeAccess('SQ3')
			EMP700OPEN('SQ3','SQ3',1,aDadosHis[nXYZ][6],@cModo,cFilMat)
		EndIf

		cModoSR7 := FWModeAccess('SR7',1) + FWModeAccess('SR7',2) + FWModeAccess('SR7',3)
		cXFilSR7 := FwxFilial('SR7',cFilMat,Substr(cModoSR7,1,1),Substr(cModoSR7,2,1),Substr(cModoSR7,3,1))

		cModoSRJ := FWModeAccess('SRJ',1) + FWModeAccess('SRJ',2) + FWModeAccess('SRJ',3)
		cXFilSRJ := FwxFilial('SRJ',cFilMat,Substr(cModoSRJ,1,1),Substr(cModoSRJ,2,1),Substr(cModoSRJ,3,1))

		cModoSQ3 := FWModeAccess('SQ3',1) + FWModeAccess('SQ3',2) + FWModeAccess('SQ3',3)
		cXFilSQ3 := FwxFilial('SQ3',cFilMat,Substr(cModoSQ3,1,1),Substr(cModoSQ3,2,1),Substr(cModoSQ3,3,1))

		dbSelectArea('SR7')
		dbSetOrder(1)
		dbSeek(cFilMat + aDadosHis[nXYZ][4] + Dtos(aDadosHis[nXYZ][1]), .T.)

		While !Eof() .And. cFilMat+aDadosHis[nXYZ][4] == SR7->R7_FILIAL+SR7->R7_MAT .And.;
			  (If(nXYZ != 1,SR7->R7_DATA < aDadosHis[nXYZ][2],SR7->R7_DATA <= aDadosHis[nXYZ][2]))

			cCNPJ := Space(10)
			nTIPINS := 2
			aAreaEMP := SM0->( GetArea() )

			dbSelectArea('SM0')
			dbSeek(aDadosHis[nXYZ][6]+cFilMat)
			cCNPJ := SM0->M0_CGC
			nTIPINS := SM0->M0_TPINSC

			RestArea(aAreaEMP)

			dbSelectArea('SRJ')
			dbSetOrder(1)
			dbSeek(cXFilSRJ + SR7->R7_FUNCAO)

			dbSelectArea('SQ3')
			dbSetOrder(1)
			dbSeek(cXFilSQ3 + If(lCposSR7, SR7->R7_CARGO, SRJ->RJ_CARGO))

			dbSelectArea(cTRBHIS)
			dbSetOrder(1)

			If (SR7->R7_FUNCAO != cFunAnter .Or. If(lCposSR7, SR7->R7_CARGO != cCarAnter, .F.))
				lAchouSRE := .T.
				Reclock(cTRBHIS, .T.)
				(cTRBHIS)->DTDE   := SR7->R7_DATA
				(cTRBHIS)->DTATE  := aDadosHis[nXYZ][2]
				(cTRBHIS)->CNPJ   := cCNPJ
				(cTRBHIS)->TIPINS := nTIPINS
				(cTRBHIS)->SEQ    := SR7->R7_SEQ
				(cTRBHIS)->FILIAL := cFilMat
				(cTRBHIS)->MATHIS := aDadosHis[nXYZ][4]
				(cTRBHIS)->CUSTO  := aDadosHis[nXYZ][5]
				(cTRBHIS)->DPTHIS := aDadosHis[nXYZ][7]
				(cTRBHIS)->EMP    := aDadosHis[nXYZ][6]
				(cTRBHIS)->CARGO  := If(lCposSR7,SR7->R7_CARGO,SRJ->RJ_CARGO)
				(cTRBHIS)->CODFUN := SR7->R7_FUNCAO

				If !Empty(SR7->R7_DESCFUN) .And. (Len(Alltrim(SRJ->RJ_DESC)) <= 25 .Or. Len(Alltrim(SR7->R7_DESCFUN)) > 25)
					(cTRBHIS)->DESFUN := SR7->R7_DESCFUN
				Else
					(cTRBHIS)->DESFUN := SRJ->RJ_DESC
				EndIf

				If lCposSR7

					If !Empty(SR7->R7_DESCCAR) .And. (Len(Alltrim(SQ3->Q3_DESCSUM)) <= 25 .Or. Len(Alltrim(SR7->R7_DESCCAR)) > 25)
						(cTRBHIS)->DESCAR := SR7->R7_DESCCAR
					Else
						(cTRBHIS)->DESCAR := SQ3->Q3_DESCSUM
					EndIf

				EndIf

				(cTRBHIS)->( Msunlock())
				cFunAnter := SR7->R7_FUNCAO

				If lCposSR7
					cCarAnter := SR7->R7_CARGO
				EndIf

			Else
				dbSelectArea('SR7')
				dbSkip()
				Loop
			EndIf

			//Guarda ultimo registro do arquivo de trabalho cTRBHIS. Para alterar a data fim no proximo laco.
			aAreaAtual := (cTRBHIS)->(GetArea())
			cFuncaoFOR := SR7->R7_FUNCAO
			cDesFunFOR := SR7->R7_DESCFUN

			If lCposSR7
				cCargoFOR  := SR7->R7_CARGO
				cDesCarFOR := SR7->R7_DESCCAR
			EndIf

			dDtTermino := SR7->R7_DATA // Variavel para alterar a data fim do registro anterior
			cSeqTabR7  := (cTRBHIS)->SEQ

			lVelha := .T.

			If lFirst // Se for a primeira vez que entrou no laco
				dDataFOR := SR7->R7_DATA
				lFirst := .F.
			Else
				RestArea(aAreaVelha)

				If !Eof() .And. !Bof()

					If dDtTermino == (cTRBHIS)->DTDE .And. (cTRBHIS)->SEQ > cSeqTabR7
						cFunAnter := (cTRBHIS)->CODFUN

						If lCposSR7
							cCarAnter := (cTRBHIS)->CARGO
						EndIf

						RestArea(aAreaAtual)
						lVelha := .F.
					EndIf

					Reclock(cTRBHIS,.F.)
					(cTRBHIS)->DTATE  := dDtTermino //Altera a data fim do registro anterior
					(cTRBHIS)->( Msunlock())
				EndIf

				RestArea(aAreaAtual)
			EndIf

			If lVelha
				aAreaVelha := (cTRBHIS)->(GetArea())
			EndIf

			// Variavel de controle. Para saber se existe mudanca de funcao no comeco da transferencia
			If aDadosHis[nXYZ][1] == SR7->R7_DATA
				lInicio := .F.
			EndIf

			// Variavel de controle. Para saber se houve mudanca de funcao
			lAchou := .F.

			dbSelectArea('SR7')
			dbSkip()
		End

		// Verifica se existe registro do funcionário na SRE
		aAreaSRE := SRE->(GetArea())
		dbSelectArea('SRE')
		dbSetOrder(2)

		If dbSeek(cCondAll)
			lAchouSRE := .T.
		EndIf

		RestArea(aAreaSRE)

		If lMudEmpr .And. aDadosHis[nXYZ][6] != cEmpHis
			EMP700OPEN('SR7','SR7',1,cEmpHis,@cModo)
			EMP700OPEN('SQ3','SQ3',1,cEmpHis,@cModo)
		EndIf

		If lAchou // Se nao achou nenhuma mudanca de funcao
			cCNPJ := Space(10)
			nTIPINS := 2
			aAreaEMP := SM0->(GetArea())

			dbSelectArea('SM0')
			dbSeek(aDadosHis[nXYZ][6]+cFilMat)
			cCNPJ := SM0->M0_CGC
			nTIPINS := SM0->M0_TPINSC

			RestArea(aAreaEMP)

			dbSelectArea('SRJ')
			dbSetOrder(1)
			dbSeek(cXFilSRJ+cFuncaoHis)

			dbSelectArea('SQ3')
			dbSetOrder(1)
			dbSeek(cXFilSQ3 + If(lCposSR7,cCargoHis,SRJ->RJ_CARGO))

			dbSelectArea(cTRBHIS)
			dbSetOrder(1)

			If !dbSeek( DTOS(aDadosHis[nXYZ][1]) )
				Reclock(cTRBHIS,.T.)
				(cTRBHIS)->DTDE   := aDadosHis[nXYZ][1]
				(cTRBHIS)->DTATE  := aDadosHis[nXYZ][2]
				(cTRBHIS)->CNPJ   := cCNPJ
				(cTRBHIS)->TIPINS := nTIPINS
				(cTRBHIS)->CUSTO  := aDadosHis[nXYZ][5]
				(cTRBHIS)->DPTHIS := aDadosHis[nXYZ][7]
				(cTRBHIS)->FILIAL := cFilMat
				(cTRBHIS)->EMP    := aDadosHis[nXYZ][6]
				(cTRBHIS)->MATHIS := aDadosHis[nXYZ][4]
				(cTRBHIS)->CARGO  := If(lCposSR7,cCargoHis,SRJ->RJ_CARGO)
				(cTRBHIS)->CODFUN := cFuncaoHis

				If !Empty(SRJ->RJ_DESC)
					(cTRBHIS)->DESFUN := SRJ->RJ_DESC
				Else
					(cTRBHIS)->DESFUN := cDesFunHis
				EndIf

				If lCposSR7

					If !Empty(SQ3->Q3_DESCSUM)
						(cTRBHIS)->DESCAR := SQ3->Q3_DESCSUM
					Else
						(cTRBHIS)->DESCAR := cDesCarHis
					EndIf

				EndIf

				cFuncaoFOR := cFuncaoHis
				cDesFunFOR := cDesFunHis

				If lCposSR7
					cCargoFOR  := If(lCposSR7,cCargoHis,SRJ->RJ_CARGO)
					cDesCarFOR := (cTRBHIS)->DESCAR
				EndIf

				(cTRBHIS)->( Msunlock())
			EndIf

		ElseIf lInicio // Se nao achou nenhuma mudanca de funcao no inicio da mudanca de setor

			cCNPJ := Space(10)
			nTIPINS := 2
			aAreaEMP := SM0->(GetArea())

			dbSelectArea('SM0')
			dbSeek(aDadosHis[nXYZ][6]+cFilMat)
			cCNPJ := SM0->M0_CGC
			nTIPINS := SM0->M0_TPINSC

			RestArea(aAreaEMP)

			dbSelectArea('SRJ')
			dbSetOrder(1)
			dbSeek(cXFilSRJ+cFuncaoHis)

			dbSelectArea('SQ3')
			dbSetOrder(1)
			dbSeek(cXFilSQ3 + If(lCposSR7,cCargoHis,SRJ->RJ_CARGO))

			dbSelectArea(cTRBHIS)
			dbSetOrder(1)

			If !dbSeek(DTOS(aDadosHis[nXYZ][1]))
				Reclock(cTRBHIS,.T.)
				(cTRBHIS)->DTDE   := aDadosHis[nXYZ][1]
				(cTRBHIS)->DTATE  := dDataFOR
				(cTRBHIS)->CNPJ   := cCNPJ
				(cTRBHIS)->TIPINS := nTIPINS
				(cTRBHIS)->CUSTO  := aDadosHis[nXYZ][5]
				(cTRBHIS)->DPTHIS := aDadosHis[nXYZ][7]
				(cTRBHIS)->FILIAL := cFilMat
				(cTRBHIS)->EMP    := aDadosHis[nXYZ][6]
				(cTRBHIS)->MATHIS := aDadosHis[nXYZ][4]
				(cTRBHIS)->CARGO  := If(lCposSR7,cCargoHis,SRJ->RJ_CARGO)
				(cTRBHIS)->CODFUN := cFuncaoHis

				If !Empty(SRJ->RJ_DESC)
					(cTRBHIS)->DESFUN := SRJ->RJ_DESC
				Else
					(cTRBHIS)->DESFUN := cDesFunHis
				EndIf

				If lCposSR7

					If !Empty(SQ3->Q3_DESCSUM)
						(cTRBHIS)->DESCAR := SQ3->Q3_DESCSUM
					Else
						(cTRBHIS)->DESCAR := cDesCarHis
					EndIf

				EndIf

				(cTRBHIS)->( Msunlock())
			EndIf

		EndIf

		cFuncaoHis := cFuncaoFOR
		cDesFunHis := cDesFunFOR

		If lCposSR7
			cCargoHis  := cCargoFOR
			cDesCarHis := cDesCarFOR
		EndIf

		If lMudEmpr .And. aDadosHis[nXYZ][6] != cEmpHis
			EMP700OPEN('SRJ','SRJ',1,cEmpHis,@cModo)
		EndIf

	Next

	RestArea(aSRArea)

	If !lAchouSRE

		Begin Sequence
			dbSelectArea('SRJ')
			dbSetOrder(1)

			If dbSeek(xFilial('SRJ') + cRA_CODFUNC)

				If lCposSR7
					dbSelectArea('SQ3')
					dbSetOrder(1)
					dbSeek(xFilial('SQ3')+cRA_CARGO)
				EndIf

				dbSelectArea(cTRBHIS)
				dbGoTop()

				While !Eof()
					RecLock(cTRBHIS,.F.)
					(cTRBHIS)->CODFUN := cRA_CODFUNC
					(cTRBHIS)->DESFUN := SRJ->RJ_DESC
					(cTRBHIS)->CARGO  := SRJ->RJ_CARGO

					If lCposSR7
						(cTRBHIS)->CARGO  := cRA_CARGO
						(cTRBHIS)->DESCAR := SQ3->Q3_DESCSUM
					EndIf

					(cTRBHIS)->( MsUnlock())
					dbskip()
				End

				Break
			EndIf

			For nBeg := Len(aMatriculas) To 1 step -1

				If lMudEmpr .And. aMatriculas[nBeg][3] != cEmpHis
					cModo := FWModeAccess('SRJ')
					EMP700OPEN('SRJ','SRJ',1,aMatriculas[nBeg][3],@cModo,aMatriculas[nBeg][1])
				EndIf

				dbSelectArea('SRJ')
				dbSetOrder(1)

				If dbSeek(xFilial('SRJ',aMatriculas[nBeg,1])+cRA_CODFUNC)
					dbSelectArea(cTRBHIS)
					dbGoTop()

					While !Eof()
						RecLock(cTRBHIS,.F.)
						(cTRBHIS)->CODFUN := cRA_CODFUNC
						(cTRBHIS)->DESFUN := SRJ->RJ_DESC
						(cTRBHIS)->CARGO  := SRJ->RJ_CARGO
						(cTRBHIS)->( Msunlock())
						dbSkip()
					End

					Break
				EndIf

				If lMudEmpr .And. aMatriculas[nBeg][3] != cEmpHis
					EMP700OPEN('SRJ','SRJ',1,cEmpHis,@cModo)
				EndIf

			Next nBeg

		End Sequence

	EndIf

	cGFIPant := '  '
	lGfipAll := .F. // Se achou alguma alteracao de GFIP

	dbSelectArea(cTRBHIS)
	dbSetOrder(1)
	dbGoTop()

	While !Eof()

		If !Empty((cTRBHIS)->GFIP)
			dbSelectArea(cTRBHIS)
			dbSkip()
			Loop
		EndIf

		aAreaSv := (cTRBHIS)->(GetArea())
		aAreaAnt := {}
		lAchou := .F.
		cFilSR9 := Substr((cTRBHIS)->FILIAL,1,FwSizeFilial((cTRBHIS)->EMP))

		If lMudEmpr .And. (cTRBHIS)->EMP != cEmpHis
			cModo := FWModeAccess('SR9')
			EMP700OPEN('SR9','SR9',1,(cTRBHIS)->EMP,@cModo,cFilSR9)
		EndIf

		cModoSR9 := FWModeAccess('SR9',1) + FWModeAccess('SR9',2) + FWModeAccess('SR9',3)
		cXFilSR9 := FwxFilial('SR9',cFilSR9,Substr(cModoSR9,1,1),Substr(cModoSR9,2,1),Substr(cModoSR9,3,1))

		cChaveHis := cXFilSR9+(cTRBHIS)->MATHIS
		svDTDE    := (cTRBHIS)->DTDE
		svDTATE   := (cTRBHIS)->DTATE

		dbSelectArea('SR9')
		dbSetOrder(1)
		dbSeek(cXFilSR9+(cTRBHIS)->MATHIS+'RA_OCORREN')

		While !Eof() .And. cChaveHis == SR9->R9_FILIAL+SR9->R9_MAT .And. 'RA_OCORREN' == SR9->R9_CAMPO

			aAreaSR9 := ( 'SR9' )->(GetArea())

			RestArea( aAreaSR9 )

			If svDTDE > SR9->R9_DATA .Or. svDTATE <= SR9->R9_DATA
				dbSelectArea('SR9')
				dbSkip()
				Loop
			EndIf

			tmpDTDE   := (cTRBHIS)->DTDE
			tmpDTATE  := (cTRBHIS)->DTATE
			tmpCNPJ   := (cTRBHIS)->CNPJ
			tmpTIPINS := (cTRBHIS)->TIPINS
			tmpCUSTO  := (cTRBHIS)->CUSTO
			tmpDEPTO  := (cTRBHIS)->DPTHIS
			tmpFILIAL := (cTRBHIS)->FILIAL
			tmpMAT    := (cTRBHIS)->MATHIS
			tmpCARGO  := (cTRBHIS)->CARGO
			tmpCODFUN := (cTRBHIS)->CODFUN
			tmpDESFUN := (cTRBHIS)->DESFUN
			tmpEMP    := (cTRBHIS)->EMP

			lInsertTRB := .F.
			dbSelectArea(cTRBHIS)

			If !lAchou

				If (cTRBHIS)->DTDE >= SR9->R9_DATA-5
					RecLock(cTRBHIS,.F.)
					(cTRBHIS)->GFIP  := AllTrim(SR9->R9_DESC)
					(cTRBHIS)->( Msunlock())
				Else
					RecLock(cTRBHIS,.F.)
					(cTRBHIS)->DTATE := SR9->R9_DATA
					(cTRBHIS)->GFIP  := If( !Empty( cGFIP ), cGFIP, cGFIPant)
					(cTRBHIS)->( Msunlock())
					lInsertTRB := .T.
				EndIf

			Else
				lInsertTRB := .T.
				RestArea(aAreaAnt)
				RecLock(cTRBHIS,.F.)
				(cTRBHIS)->DTATE := SR9->R9_DATA
				(cTRBHIS)->( Msunlock())
			EndIf

			If lInsertTRB
				RecLock(cTRBHIS,.T.)
				(cTRBHIS)->DTDE   := SR9->R9_DATA
				(cTRBHIS)->DTATE  := tmpDTATE
				(cTRBHIS)->CNPJ   := tmpCNPJ
				(cTRBHIS)->TIPINS := tmpTIPINS
				(cTRBHIS)->CUSTO  := tmpCUSTO
				(cTRBHIS)->DPTHIS := tmpDEPTO
				(cTRBHIS)->FILIAL := tmpFILIAL
				(cTRBHIS)->MATHIS := tmpMAT
				(cTRBHIS)->CARGO  := tmpCARGO
				(cTRBHIS)->CODFUN := tmpCODFUN
				(cTRBHIS)->DESFUN := tmpDESFUN
				(cTRBHIS)->EMP    := tmpEMP
				(cTRBHIS)->GFIP   := Alltrim(SR9->R9_DESC)
				(cTRBHIS)->( Msunlock())
			EndIf

			aAreaAnt := (cTRBHIS)->(GetArea())

			lAchou     := .T. //Controle p/ ver se houve alguma alteracao de GFIP em cada periodo de trabalho
			lGfipAll   := .T.
			cGFIPant   := Alltrim(SR9->R9_DESC)

			dbSelectArea('SR9')
			dbSkip()
		End

		RestArea(aAreaSv)

		If lMudEmpr .And. (cTRBHIS)->EMP != cEmpHis
			EMP700OPEN('SR9','SR9',1,cEmpHis,@cModo)
		EndIf

		dbSelectArea(cTRBHIS)

		If !lAchou
			RecLock(cTRBHIS,.F.)
			(cTRBHIS)->GFIP := cGFIPant
			(cTRBHIS)->( Msunlock())
		EndIf

		RestArea(aAreaSv)
		dbSelectArea(cTRBHIS)
		dbSkip()
	End

	dbSelectArea(cTRBHIS)
	dbSetOrder(1)
	dbGoTop()

	While !Eof()

		If Empty((cTRBHIS)->GFIP) .Or. (cTRBHIS)->GFIP == '00'

			If lMudEmpr .And. (cTRBHIS)->EMP != cEmpHis
				cModo := FWModeAccess('CTT')
				EMP700OPEN('CTT','CTT',1,(cTRBHIS)->EMP,@cModo,Substr((cTRBHIS)->FILIAL,1,FwSizeFilial((cTRBHIS)->EMP)))
			EndIf

			cModoCTT := FWModeAccess('CTT',1) + FWModeAccess('CTT',2) + FWModeAccess('CTT',3)
			cXFilCTT := FwxFilial('CTT',Substr((cTRBHIS)->FILIAL,1,FwSizeFilial((cTRBHIS)->EMP)),Substr(cModoCTT,1,1),Substr(cModoCTT,2,1),Substr(cModoCTT,3,1))

			dbSelectArea('CTT')
			dbSetOrder(1)

			If dbSeek(cXFilCTT+(cTRBHIS)->CUSTO)

				If !Empty(CTT->CTT_OCORRE)
					dbSelectArea(cTRBHIS)
					RecLock(cTRBHIS,.F.)
					(cTRBHIS)->GFIP := CTT->CTT_OCORRE
					(cTRBHIS)->( Msunlock())
				EndIf

			EndIf

			If lMudEmpr .And. (cTRBHIS)->EMP != cEmpHis
				EMP700OPEN('CTT','CTT',1,cEmpHis,@cModo)
			EndIf

			If !Empty(SRA->RA_OCORREN) .And. (Empty((cTRBHIS)->GFIP) .Or. (cTRBHIS)->GFIP == '00') .And. !lGfipAll
				RecLock(cTRBHIS,.F.)
				(cTRBHIS)->GFIP := SRA->RA_OCORREN
				(cTRBHIS)->( Msunlock())
			EndIf

		EndIf

		dbSelectArea(cTRBHIS)
		dbSkip()
	End

	dbSelectArea(cTRBHIS)
	dbSetOrder(1)
	dbGoTop()

	While !Eof()

		aAreaTmp := (cTRBHIS)->(GetArea())
		dDtFimsv := CToD('  /  /  ')
		svHischv := (cTRBHIS)->CNPJ+Str((cTRBHIS)->TIPINS,1)+(cTRBHIS)->CUSTO+(cTRBHIS)->DPTHIS+(cTRBHIS)->FILIAL+(cTRBHIS)->MATHIS+;
					(cTRBHIS)->CARGO+(cTRBHIS)->CODFUN+(cTRBHIS)->DESFUN+(cTRBHIS)->EMP+(cTRBHIS)->GFIP
		dbSkip()

		If !Eof()
			dbSelectArea(cTRBHIS)

			While !Eof() .And. svHischv == (cTRBHIS)->CNPJ+Str((cTRBHIS)->TIPINS,1)+(cTRBHIS)->CUSTO+(cTRBHIS)->DPTHIS+(cTRBHIS)->FILIAL+;
				(cTRBHIS)->MATHIS+(cTRBHIS)->CARGO+(cTRBHIS)->CODFUN+(cTRBHIS)->DESFUN+(cTRBHIS)->EMP+(cTRBHIS)->GFIP

				If dDtFimsv < (cTRBHIS)->DTATE
					dDtFimsv := (cTRBHIS)->DTATE
				EndIf

				RecLock(cTRBHIS,.F.)
				dbDelete()
				(cTRBHIS)->( Msunlock())
				dbSelectArea(cTRBHIS)
				dbSkip()
			End

			If !Empty(dDtFimsv)
				RestArea(aAreaTmp)
				RecLock(cTRBHIS,.F.)
				(cTRBHIS)->DTATE := dDtFimsv
				(cTRBHIS)->( Msunlock())
			EndIf

		EndIf

		RestArea(aAreaTmp)
		dbSelectArea(cTRBHIS)
		dbSkip()
	End

	lTroca    := .T.
	// Executa os historicos
	dbSelectArea(cTRBHIS)
	Pack

	nRegTRB := (cTRBHIS)->(RECCOUNT())
	nConTRB := 0
	dbGoTop()

	While !EoF()
		nConTRB++

		If nConTRB > 1

			If cFilTNF != (cTRBHIS)->EMP+(cTRBHIS)->FILIAL
				dDtTransf := (cTRBHIS)->DTDE
				cFilTNF   := (cTRBHIS)->EMP+(cTRBHIS)->FILIAL
			EndIf

		Else
			cFilTNF := (cTRBHIS)->EMP+(cTRBHIS)->FILIAL
		EndIf

		cFilFichas := Substr((cTRBHIS)->FILIAL,1,FwSizeFilial((cTRBHIS)->EMP))

		If lMudEmpr .And. (cTRBHIS)->EMP != cEmpHis
			cModo := FWModeAccess('TM0')
			EMP700OPEN('TM0','TM0',1,(cTRBHIS)->EMP,@cModo,cFilFichas)
			cModo := FWModeAccess('SRJ')
			EMP700OPEN('SRJ','SRJ',1,(cTRBHIS)->EMP,@cModo,cFilFichas)
			cModo := FWModeAccess('SQ3')
			EMP700OPEN('SQ3','SQ3',1,(cTRBHIS)->EMP,@cModo,cFilFichas)
			cModo := FWModeAccess('CTT')
			EMP700OPEN('CTT','CTT',1,(cTRBHIS)->EMP,@cModo,cFilFichas)
		EndIf

		cModoTM0 := FWModeAccess('TM0',1) + FWModeAccess('TM0',2) + FWModeAccess('TM0',3)
		cXFilTM0 := FwxFilial('TM0',cFilFichas,Substr(cModoTM0,1,1),Substr(cModoTM0,2,1),Substr(cModoTM0,3,1))

		cModoSRA := FWModeAccess('SRA',1) + FWModeAccess('SRA',2) + FWModeAccess('SRA',3)
		cXFilSRA := FwxFilial('SRA',cFilFichas,Substr(cModoSRA,1,1),Substr(cModoSRA,2,1),Substr(cModoSRA,3,1))

		cModoSRJ := FWModeAccess('SRJ',1) + FWModeAccess('SRJ',2) + FWModeAccess('SRJ',3)
		cXFilSRJ := FwxFilial('SRJ',cFilFichas,Substr(cModoSRJ,1,1),Substr(cModoSRJ,2,1),Substr(cModoSRJ,3,1))

		cModoSQ3 := FWModeAccess('SQ3',1) + FWModeAccess('SQ3',2) + FWModeAccess('SQ3',3)
		cXFilSQ3 := FwxFilial('SQ3',cFilFichas,Substr(cModoSQ3,1,1),Substr(cModoSQ3,2,1),Substr(cModoSQ3,3,1))

		cModoCTT := FWModeAccess('CTT',1) + FWModeAccess('CTT',2) + FWModeAccess('CTT',3)
		cXFilCTT := FwxFilial('CTT',cFilFichas,Substr(cModoCTT,1,1),Substr(cModoCTT,2,1),Substr(cModoCTT,3,1))

		If (cTRBHIS)->DTDE == (cTRBHIS)->DTATE
			dDateAte := (cTRBHIS)->DTATE
		Else
			dDateAte := IIf( Posicione('SRA', 1, xFilial('SRA', (cTRBHIS)->FILIAL )+(cTRBHIS)->MATHIS, 'RA_DEMISSA') == (cTRBHIS)->DTATE, ;
					(cTRBHIS)->DTATE, (cTRBHIS)->DTATE - If( nRegTRB == nConTRB, 0, 1 ) )
		EndIf

		dbSelectArea('TM0')
		dbSetOrder(3)

		If dbSeek(cXFilSRA+(cTRBHIS)->MATHIS)

			If (aScan(aFichasUsa,{|x| x[5]+x[1]+x[2]+DTOS(x[3])+DTOS(x[4]) == (cTRBHIS)->EMP+cFilFichas+TM0->TM0_NUMFIC+;
				DTOS((cTRBHIS)->DTDE)+DTOS(dDateAte)})) <= 0
				aAdd(aFichasUsa,{cFilFichas,TM0->TM0_NUMFIC,(cTRBHIS)->DTDE,dDateAte,(cTRBHIS)->EMP})
				//Fichas Utilizadas pelo funcionario na empresa
				MDTA192CAT(cFilFichas,TM0->TM0_NUMFIC,(cTRBHIS)->EMP) //Verifica se existe CAT para a Ficha Medica do Funcionario
			EndIf

		EndIf

		strFuncao := (cTRBHIS)->DESFUN

		cCBO  := SRJ->RJ_CBO

		If Year((cTRBHIS)->DTATE-1) >= 2003
			lTroca := .F.

			If !Empty(SRJ->RJ_CODCBO)
				cCBO := SRJ->RJ_CODCBO
			EndIf

		EndIf

		dbSelectArea('SQ3')
		dbSetOrder(1)

		If  !dbSeek(cXFilSQ3+(cTRBHIS)->CARGO+(cTRBHIS)->CUSTO)
			dbSelectArea('SQ3')
			dbSetOrder(1)
			dbSeek(cXFilSQ3+(cTRBHIS)->CARGO)

			If aScan(aCargoSv,{|x| x[1]+x[2]+x[4] == cFilFichas+(cTRBHIS)->CARGO+(cTRBHIS)->EMP}) <= 0
				aAdd(aCargoSv,{cFilFichas,(cTRBHIS)->CARGO,'',(cTRBHIS)->EMP})
			EndIf
		Else

			If aScan(aCargoSv,{|x| x[1]+x[2]+x[3]+x[4] == cFilFichas+(cTRBHIS)->CARGO+(cTRBHIS)->CUSTO+(cTRBHIS)->EMP}) <= 0
				aAdd(aCargoSv,{cFilFichas,(cTRBHIS)->CARGO,(cTRBHIS)->CUSTO,(cTRBHIS)->EMP})
			EndIf

		EndIf

		strCargo := SQ3->Q3_DESCSUM

		If Empty(strCargo)
			strCargo := (cTRBHIS)->DESCAR
		EndIf

		cCNPJtrb := (cTRBHIS)->CNPJ
		cTIPOtrb := (cTRBHIS)->TIPINS
		dbSelectArea('CTT')
		dbSetOrder(1)

		If dbSeek(cXFilCTT+(cTRBHIS)->CUSTO)

			If !Empty(CTT->CTT_CEI)
				cTIPOtrb := If(CTT->CTT_TIPO=='1',2,1)
				cCNPJtrb := CTT->CTT_CEI
			EndIf

		EndIf

		// Verifica se o funcionario executou alguma tarefa
		MDTA192TAR(cFilFichas, (cTRBHIS)->MATHIS, (cTRBHIS)->DTDE, dDateAte, (cTRBHIS)->CUSTO, (cTRBHIS)->DPTHIS, ;
					(cTRBHIS)->CODFUN, TM0->TM0_NUMFIC, (cTRBHIS)->EMP)

		If lMudEmpr .And. (cTRBHIS)->EMP != cEmpHis
			EMP700OPEN('TM0','TM0',1,cEmpHis,@cModo)
			EMP700OPEN('SRJ','SRJ',1,cEmpHis,@cModo)
			EMP700OPEN('SQ3','SQ3',1,cEmpHis,@cModo)
			EMP700OPEN('CTT','CTT',1,cEmpHis,@cModo)
		EndIf

		dbSelectArea(cTRBHIS)
		dbSkip()
	End

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTATARE19F
Busca as tarefas do funcionario no período

@author  Denis Hyroshi de Souza
@since   21/10/02

@sample  MDTA192TAR('D MG 01 ', '000001', 01/01/2018, 19/07/2018, ;
					'10.001   ', '', '00001', '000000001', 'T1')

@param   Fil, Caracter, Filial do funcionario
@param   Mat, Caracter, Matricula do funcionario
@param   dDTde, Date, Data inicio do período das tarefas
@param   dDTate, Date, Data fim do período das tarefas
@param   cCusto, Caracter, Codigo do centro de custo do funcionario
@param   cDepto, Caracter, Codigo do departamento do funcionario
@param   cFuncc, Caracter, Codigo da funcao do funcionario
@param   cFicha, Caracter, Numero da ficha medica do funcionario
@param   cEmpNG, Caracter, Empresa no sistema

@return  Nil, Sempre Nulo
/*/
//-------------------------------------------------------------------
Function MDTA192TAR( Fil, Mat, dDTde, dDTate, cCusto, cDepto, cFuncc, cFicha, cEmpNG )

	Local cTarefa := '*'
	Local cModoTN6
	Local cXFilTN6

	Private _cEmpNG     := cEmpNG
	Private _Fil        := Fil
	Private _cFicha     := cFicha
	Private _cCusto     := cCusto
	Private _cDepto     := cDepto
	Private _cFuncc     := cFuncc
	Private _Mat        := Mat
	Private _dDTinicio  := dDTde
	Private _dDTfim     := dDTate
	Private lStart      := .F.

	If lMudEmpr .And. _cEmpNG != cEmpHis
		cModo := FWModeAccess('TN6')
		EMP700OPEN('TN6','TN6',1,_cEmpNG,@cModo,Fil)
	EndIf

	cModoTN6 := FWModeAccess('TN6',1) + FWModeAccess('TN6',2) + FWModeAccess('TN6',3)
	cXFilTN6 := FwxFilial('TN6',_Fil,Substr(cModoTN6,1,1),Substr(cModoTN6,2,1),Substr(cModoTN6,3,1))

	// Busca os riscos que o funcinario esta exposto nessas condicoes
	dbSelectArea('TN6')
	dbSetOrder(2)
	dbSeek(cXFilTN6 + _Mat)

	While !Eof() .And. cXFilTN6 == TN6->TN6_FILIAL .And. _Mat == TN6->TN6_MAT

		_dDTinicio  := dDTde
		_dDTfim := dDTate

		If TN6->TN6_DTINIC > _dDTfim .Or. (TN6->TN6_DTTERM < _dDTinicio  .And. !Empty(TN6->TN6_DTTERM))
			dbSelectArea('TN6')
			dbSkip()
			Loop
		EndIf

		If TN6->TN6_DTINIC >= _dDTinicio  .And. TN6->TN6_DTINIC <= _dDTfim
			lStart  := .T.

			If TN6->TN6_DTTERM < _dDTfim .And. !Empty(TN6->TN6_DTTERM)
				_dDTfim := TN6->TN6_DTTERM
			EndIf

			_dDTinicio := TN6->TN6_DTINIC

		ElseIf TN6->TN6_DTINIC < _dDTinicio .And. (TN6->TN6_DTTERM >= _dDTinicio .Or. Empty(TN6->TN6_DTTERM))
			lStart  := .T.

			If TN6->TN6_DTTERM < _dDTfim .And. !Empty(TN6->TN6_DTTERM)
				_dDTfim := TN6->TN6_DTTERM
			EndIf

		EndIf

		cTarefa := TN6->TN6_CODTAR

		If lStart
			MDTA192RIS(_Fil,_cFicha,cTarefa,_cCusto,_cDepto,_cFuncc,_Mat,_dDTinicio,_dDTfim,2,_cEmpNG)
		EndIf

		dbSelectArea('TN6')
		dbSkip()
	EndDo

	If lMudEmpr .And. _cEmpNG != cEmpHis
		EMP700OPEN('TN6','TN6',1,cEmpHis,@cModo)
	EndIf

	Padr('*',nSizeTN5)
	MDTA192RIS(_Fil,_cFicha,cTarefa,_cCusto,_cDepto,_cFuncc,_Mat,dDTde,dDTate,1,_cEmpNG)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTA192RIS
Verifica os riscos que o funcionario esteve exposto

@author  Denis Hyroshi de Souza
@since   21/10/02

@sample  MDTA192RIS('D MG 01', '000000001', '*', '10.001', '', ;
		'00001', '000001', 01/01/2018, 19/07/2018, 1, 'T1')

@param   cFilFun, Caracter, Filial do funcionario
@param   cFichaM, Caracter, Numero da ficha medica do funcionario
@param   cTarefa, Caracter, Codigo da tarefa do funcionario, '*' representa todas
@param   cCusto, Caracter, Codigo do centro de custo do funcionario, '*' representa todos
@param   cDepto, Caracter, Codigo do departamento do funcionario, '*' representa todos
@param   cFuncc, Caracter, Codigo da funcao do funcionario, '*' representa todas
@param   Mat, Caracter, Matricula do funcioario
@param   dIniRisco, Date, Data inicio da exposicao
@param   dFinRisco, Date, Data funal da exposicao
@param   nParam, Numerico, Quantidade de vezes que sarao executadas as operacoes da funcao
@param   cEmpFun, Caracter, Codigo da empresa no sistema

@return  Nil, Sempre Nulo
/*/
//-------------------------------------------------------------------
Function MDTA192RIS( cFilFun, cFichaM, cTarefa, cCusto, cDepto, cFuncc, Mat, dIniRisco, dFinRisco, nParam, cEmpFun )

	Local nx         := 0
	Local ny         := 0
	Local nTam       := 8
	Local cModoTN0   := ''
	Local cModoTNX   := ''
	Local cModoTNF   := ''
	Local cXFilTNF   := ''
	Local cModoTN3   := ''
	Local cXFilTN3   := ''
	Local aAfasTip   := ''
	Local nW         := 0
	Local dInicioRis := SToD('')
	Local dFimRis    := SToD('')

	Private cXFilTNX, cXFilTN0, cXFilTJF, cXFilTO4

	_cTarefa     := cTarefa
	_centrCusto  := cCusto
	_cFunccRis   := cFuncc
	_cDeptoRis   := cDepto
	cMatric      := Mat
	nRisco       := space(9)

	If lMudEmpr .And. cEmpFun != cEmpHis
		cModo := FWModeAccess('TN0')
		EMP700OPEN('TN0','TN0',1,cEmpFun,@cModo,cFilFun)
		cModo := FWModeAccess('TNX')
		EMP700OPEN('TNX','TNX',1,cEmpFun,@cModo,cFilFun)
		cModo := FWModeAccess('TNF')
		EMP700OPEN('TNF','TNF',1,cEmpFun,@cModo,cFilFun)
		cModo := FWModeAccess('TN3')
		EMP700OPEN('TN3','TN3',1,cEmpFun,@cModo,cFilFun)
		cModo := FWModeAccess('TMA')
		EMP700OPEN('TMA','TMA',1,cEmpFun,@cModo,cFilFun)
		cModo := FWModeAccess('SR8')
		EMP700OPEN('SR8','SR8',1,cEmpFun,@cModo,cFilFun)
		cModo := FWModeAccess('TJF')
		EMP700OPEN('TJF','TJF',1,cEmpFun,@cModo,cFilFun)
		cModo := FWModeAccess('TO4')
		EMP700OPEN('TO4','TO4',1,cEmpFun,@cModo,cFilFun)
	EndIf

	cModoTN0 := FWModeAccess('TN0',1) + FWModeAccess('TN0',2) + FWModeAccess('TN0',3)
	cXFilTN0 := FwxFilial('TN0',cFilFun,Substr(cModoTN0,1,1),Substr(cModoTN0,2,1),Substr(cModoTN0,3,1))

	cModoTNX := FWModeAccess('TNX',1) + FWModeAccess('TNX',2) + FWModeAccess('TNX',3)
	cXFilTNX := FwxFilial('TNX',cFilFun,Substr(cModoTNX,1,1),Substr(cModoTNX,2,1),Substr(cModoTNX,3,1))

	cModoTNF := FWModeAccess('TNF',1) + FWModeAccess('TNF',2) + FWModeAccess('TNF',3)
	cXFilTNF := FwxFilial('TNF',cFilFun,Substr(cModoTNF,1,1),Substr(cModoTNF,2,1),Substr(cModoTNF,3,1))

	cModoTN3 := FWModeAccess('TN3',1) + FWModeAccess('TN3',2) + FWModeAccess('TN3',3)
	cXFilTN3 := FwxFilial('TN3',cFilFun,Substr(cModoTN3,1,1),Substr(cModoTN3,2,1),Substr(cModoTN3,3,1))

	cModoTL0 := FWModeAccess('TL0',1) + FWModeAccess('TL0',2) + FWModeAccess('TL0',3)
	cXFilTL0 := FwxFilial('TL0',cFilFun,Substr(cModoTL0,1,1),Substr(cModoTL0,2,1),Substr(cModoTL0,3,1))

	cModoTJF := FWModeAccess('TJF',1) + FWModeAccess('TJF',2) + FWModeAccess('TJF',3)
	cXFilTJF := FwxFilial('TJF',cFilFun,Substr(cModoTJF,1,1),Substr(cModoTJF,2,1),Substr(cModoTJF,3,1))

	cModoTO4 := FWModeAccess('TO4',1) + FWModeAccess('TO4',2) + FWModeAccess('TO4',3)
	cXFilTO4 := FwxFilial('TO4',cFilFun,Substr(cModoTO4,1,1),Substr(cModoTO4,2,1),Substr(cModoTO4,3,1))

	For nx := 1 to nTam

		For nY := 1 To nParam

			_cTarefa := If( nY == 1 , Padr('*',nSizeTN5) , cTarefa )

			If nx == 1
				_centrCusto := cCusto
				_cFunccRis  := cFuncc
				_cDeptoRis  := cDepto
			ElseIf nx == 2
				_centrCusto:= Padr('*',nSizeSI3)
				_cFunccRis := cFuncc
				_cDeptoRis := cDepto
			ElseIf nx == 3
				_centrCusto := cCusto
				_cFunccRis := Padr('*',nSizeSRJ)
				_cDeptoRis := cDepto
			ElseIf nx == 4
				_centrCusto:= Padr('*',nSizeSI3)
				_cFunccRis := Padr('*',nSizeSRJ)
				_cDeptoRis := cDepto
			ElseIf nx == 5
				_centrCusto := cCusto
				_cFunccRis  := cFuncc
				_cDeptoRis  := Padr('*',nSizeSQB)
			ElseIf nx == 6
				_centrCusto:= Padr('*',nSizeSI3)
				_cFunccRis := cFuncc
				_cDeptoRis := Padr('*',nSizeSQB)
			ElseIf nx == 7
				_centrCusto := cCusto
				_cFunccRis := Padr('*',nSizeSRJ)
				_cDeptoRis := Padr('*',nSizeSQB)
			ElseIf nx == 8
				_centrCusto:= Padr('*',nSizeSI3)
				_cFunccRis := Padr('*',nSizeSRJ)
				_cDeptoRis := Padr('*',nSizeSQB)
			EndIf

			dbSelectArea('TN0')
			dbSetOrder(5)

			If dbSeek(cXFilTN0 + _centrCusto + _cFunccRis + _cTarefa + _cDeptoRis )

				Do While !Eof()                           .And.;
							TN0->TN0_CC == _centrCusto    .And.;
							TN0->TN0_CODFUN == _cFunccRis .And.;
							TN0->TN0_CODTAR == _cTarefa   .And.;
							TN0->TN0_DEPTO  == _cDeptoRis .And.;
							TN0->TN0_FILIAL == cXFilTN0

					aAfasTip := MDTA192AFA( Mat, dIniRisco, dFinRisco  ) // Verifica afastamentos durante período do risco.

					For nW := 1 To Len (aAfasTip)
						lStart     := .F.
						dInicioRis := aAfasTip[nW,1] // dIniRisco
						dFimRis    := aAfasTip[nW,2] // dFinRisco
						dtAval     := TN0->TN0_DTRECO

						If dtAval > dFimRis .Or. Empty( TN0->TN0_DTAVAL )
							Loop
						EndIf

						If !Empty(TN0->TN0_DTELIM) .And. TN0->TN0_DTELIM <  dInicioRis
							Loop
						EndIf

						If dtAval >= dInicioRis  .And. dtAval <= dFimRis
							lStart  := .T.

							If !Empty(TN0->TN0_DTELIM) .And. TN0->TN0_DTELIM < dFimRis
								dFimRis := TN0->TN0_DTELIM
							EndIf

							dInicioRis := dtAval
						ElseIf dtAval < dInicioRis .And. (Empty(TN0->TN0_DTELIM) .Or. TN0->TN0_DTELIM >= dInicioRis)
							lStart  := .T.

							If !Empty(TN0->TN0_DTELIM) .And. TN0->TN0_DTELIM < dFimRis
								dFimRis := TN0->TN0_DTELIM
							EndIf

						EndIf

						MDTA192GRV(cFilFun,cFichaM,cCusto,cDepto,cFuncc,Mat,dInicioRis,dFimRis,Space(12),'NA',cEmpFun,Space(15))

					Next nW

					dbSelectArea('TN0')
					dbSkip()
				EndDo

			EndIf

		Next ny

	Next nx

	If lMudEmpr .And. cEmpFun != cEmpHis
		EMP700OPEN('TN0','TN0',1,cEmpHis,@cModo)
		EMP700OPEN('TNX','TNX',1,cEmpHis,@cModo)
		EMP700OPEN('TNF','TNF',1,cEmpHis,@cModo)
		EMP700OPEN('TN3','TN3',1,cEmpHis,@cModo)
		EMP700OPEN('TMA','TMA',1,cEmpHis,@cModo)
		EMP700OPEN('SR8','SR8',1,cEmpHis,@cModo)
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTA192GRV
Grava arquivo de trabalho contendo os riscos do funcionario

@author  Denis Hyroshi de Souza
@since   21/10/02

@sample  MDTA192GRV('D MG 01 ', '000000001', '10.001   ', '', '00001', ;
			'000001', 20/04/2018, 20/04/2018, '', 'NA', 'T1', '')

@param   cFilFun, Caracter, Filial do funcionario
@param   cFichaM, Caracter, Numero da ficha medica do funcionario
@param   cCusto, Caracter, Codigo do centro de custo do funcionario
@param   cDepto, Caracter, Codigo do departamento do funcionario
@param   cFuncc, Caracter, Codigo da funcao do funcionario
@param   Mat, Caracter, Matricula do funcionario
@param   dInicioRis, Date, Inicio do periodo de exposicao aos riscos que serao gravados
@param   dFimRis, Date, Fim do periodo de exposicao aos riscos que serao gravados
@param   cNUMCAP, Caracter, Numero do certificado de aprovacao do epi relacionado ao risco
@param   cEpiFunc, Caracter, Indica se há EPI eficaz
@param   cEmpFun, Caracter, Empresa do sistema
@param   cCodEPI, Caracter, Codigo do Epi relacionado ao risco

Return   Nil, Sempre nulo
/*/
//-------------------------------------------------------------------
Function MDTA192GRV( cFilFun, cFichaM, cCusto, cDepto, cFuncc, Mat, dInicioRis, dFimRis, cNUMCAP, cEpiFunc, cEmpFun, cCodEPI )

	Local lSave       := .F.
	Local lAchouRisco := .F.
	Local cEXPOSICAO  := ''
	Local cModoTMA    := ''
	Local cXFilTMA    := ''

	Private lEpiFunc := Substr(cEpiFunc,1,Len(cEpiFunc))
	Private lEpcFunc := TN0->TN0_EPC
	Private _cNUMCAP := cNUMCAP
	Private cTECNICA := Space(40)
	Private _cCodEpi := cCodEPI

	Default cCodEpi  := ''

	cCondRis := cFilFun+TN0->TN0_NUMRIS+DTOS(dInicioRis)+DTOS(dFimRis)+cFichaM+cEmpFun

	If aSCAN(aRiscos,{|x| x[1]+x[2]+DTOS(x[3])+DTOS(x[4])+x[5]+x[7] == cCondRis}) <= 0
		aAdd(aRiscos,{cFilFun,TN0->TN0_NUMRIS,dInicioRis,dFimRis,cFichaM,TN0->TN0_AGENTE,cEmpFun})
		// Adiciona o numero do risco na array aRISCOS
	EndIf

	cEXPOSICAO := TN0->TN0_INDEXP
	cTECNICA := TN0->TN0_TECUTI+Space(40-Len(TN0->TN0_TECUTI))
	cModoTMA := FWModeAccess('TMA',1) + FWModeAccess('TMA',2) + FWModeAccess('TMA',3)
	cXFilTMA := FwxFilial('TMA',cFilFun,Substr(cModoTMA,1,1),Substr(cModoTMA,2,1),Substr(cModoTMA,3,1))

	dbSelectArea('TMA')
	dbSetOrder(1)

	If !dbSeek(cXFilTMA+TN0->TN0_AGENTE)
		Return .T.
	EndIf

	cNOME_AGENTE := 'TMA->TMA_NOMAGE'

	// Se for agente quimico, pegar a substancia ativa como descricao.
	If TMA->TMA_GRISCO == '2' .And. !Empty(TMA->TMA_SUBATI)
		cNOME_AGENTE := 'Substr(TMA->TMA_SUBATI,1,40)'
	EndIf

	cKeyRisco := 'TMA->TMA_GRISCO+'+cNOME_AGENTE+'+Str(TN0->TN0_QTAGEN,nSizeQtA[1],nSizeQtA[2])+'
	cKeyRisco += 'cTECNICA+lEpcFunc+lEpiFunc+_cCodEpi+_cNUMCAP'

	dbSelectArea(cTRBTN0)
	dbSetOrder(2)  // GRISCO + AGENTE + Str(INTENS,9,3) + TECNIC + EPC + PROTEC + CODEPI + NUMCAP

	If !dbSeek(&cKeyRisco)
		lSave  := .T.
	Else
		dtstart := dInicioRis
		dtstop  := dFimRis
		nRecOld := Nil
		dbSelectArea(cTRBTN0)
		dbSetOrder(2)
		dbSeek(&cKeyRisco)
		While !Eof() .And. &cKeyRisco == (cTRBTN0)->(GRISCO+AGENTE+Str(INTENS,nSizeQtA[1],nSizeQtA[2])+TECNIC+EPC+PROTEC+CODEPI+NUMCAP)


			If (cTRBTN0)->DT_DE <= dtstart .And. (cTRBTN0)->DT_ATE >= dtstart-1

				If dtStop > (cTRBTN0)->DT_ATE
					RecLock(cTRBTN0,.F.)
					(cTRBTN0)->DT_ATE := dtstop
					dtstart := (cTRBTN0)->DT_DE
					Msunlock()
					aAreaTRB := (cTRBTN0)->(GetArea())

					If nRecOld != Nil
						dbSelectArea(cTRBTN0)
						dbGoTo(nRecOld)
						(cTRBTN0)->(Dbdelete())
					EndIf

					RestArea(aAreaTRB)
				EndIf

				lAchouRisco := .T.
				nRecOld := recno()

			ElseIf (cTRBTN0)->DT_DE <= dtstop + 1 .And. (cTRBTN0)->DT_ATE >= dtstop

				If dtstart < (cTRBTN0)->DT_DE
					RecLock(cTRBTN0,.F.)
					(cTRBTN0)->DT_DE := dtstart
					dtstop := (cTRBTN0)->DT_ATE
					MsUnlock()
					aAreaTRB := (cTRBTN0)->(GetArea())

					If nRecOld != Nil
						dbSelectArea(cTRBTN0)
						dbGoTo(nRecOld)
						(cTRBTN0)->(Dbdelete())
					EndIf

					RestArea(aAreaTRB)
				EndIf

				lAchouRisco := .T.
				nRecOld := recno()

			ElseIf (cTRBTN0)->DT_DE > dtstart .And. (cTRBTN0)->DT_ATE < dtstop
				RecLock(cTRBTN0,.F.)
				(cTRBTN0)->DT_DE := dtstart
				(cTRBTN0)->DT_ATE := dtstop
				MsUnlock()
				aAreaTRB := (cTRBTN0)->(GetArea())

				If nRecOld != Nil
					dbSelectArea(cTRBTN0)
					dbGoTo(nRecOld)
					(cTRBTN0)->(dbDelete())
				EndIf

				RestArea(aAreaTRB)
				lAchouRisco := .T.
				nRecOld := Recno()
			EndIf

			dbSkip()
		End

		If !lAchouRisco
			lSave := .T.
		EndIf

	EndIf

	If lSave .And. Alltrim(TN0->TN0_AGENTE) == Alltrim(cAsbesto)

		dbSelectArea(cTRBTN0)
		(cTRBTN0)->(dbAppend())
		(cTRBTN0)->NUMRIS := TN0->TN0_NUMRIS
		(cTRBTN0)->CODAGE := TN0->TN0_AGENTE

		If !Empty(TMA->TMA_SUBATI) .And. TMA->TMA_GRISCO == '2'
			(cTRBTN0)->AGENTE := Substr(TMA->TMA_SUBATI,1,40)
		Else
			(cTRBTN0)->AGENTE := TMA->TMA_NOMAGE
		EndIf

		(cTRBTN0)->GRISCO := TMA->TMA_GRISCO
		(cTRBTN0)->NUMCAP := _cNUMCAP
		(cTRBTN0)->MAT    := cMatric
		(cTRBTN0)->DT_DE  := dInicioRis
		(cTRBTN0)->DT_ATE := dFimRis
		(cTRBTN0)->SETOR  := _centrCusto
		(cTRBTN0)->DEPTO  := _cDepto
		(cTRBTN0)->FUNCAO := _cFuncc
		(cTRBTN0)->TAREFA := _cTarefa
		(cTRBTN0)->INTENS := TN0->TN0_QTAGEN   //Transform(TN0->TN0_QTAGEN,cQTAGtra)
		(cTRBTN0)->UNIDAD := TN0->TN0_UNIMED
		(cTRBTN0)->TECNIC := Substr(cTECNICA,1,40)
		(cTRBTN0)->PROTEC := lEpiFunc
		(cTRBTN0)->EPC    := lEpcFunc
		(cTRBTN0)->INDEXP := cEXPOSICAO
		(cTRBTN0)->ATIVO  := 'S'

		If TN0->(FieldPos('TN0_OBSINT')) > 0 //Campo especifico
			(cTRBTN0)->OBSINT := TN0->TN0_OBSINT
		EndIf

		(cTRBTN0)->CODEPI := _cCodEpi
		(cTRBTN0)->AVALIA := TMA->TMA_AVALIA
		(cTRBTN0)->MEDCON := TN0->TN0_MEDCON
		(cTRBTN0)->TIPCTR := NGSEEK('TO4',TN0->TN0_MEDCON,1,'TO4->TO4_TIPCTR')
		(cTRBTN0)->NECEPI := TN0->TN0_NECEPI

	EndIf

Return Nil

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} MDTA192AFA
Responsavel por verificar afastamento do funcionário durante o período de
exposição ao risco, e dividir em períodos o tempo de exposição.

@type function

@author Guilherme Freudenburg
@since 12/01/2017

@param cMat	, Caracter, Matrícula do funcionário utilizado
@param dIniRis, Date, Data Início do Risco
@param dFimRis, Date, Data Fim do Risco

@sample MDTA192AFA( '00001', 01/01/2017 , 01/01/2017  )

@return aEficaz, Array , Retorna a data de início e fim de cada período.
/*/
//----------------------------------------------------------------------------------------
Static Function MDTA192AFA( cMat, dIniRis, dFimRis )

	Local nX       := 0
	Local aEficaz  := {}
	Local aAfasta  := {}

	dbSelectArea('SR8')
	dbSetOrder(1)//R8_FILIAL+R8_MAT+DTOS(R8_DATAINI)+R8_TIPO

	If dbSeek(xFilial('SR8')+cMat)//Verifica se houve algum afastamento para o funcionário.

		While !Eof() .And. SR8->R8_MAT == cMat

			If AllTrim(Posicione('RCM', 1, xFilial('RCM') + SR8->R8_TIPOAFA, 'RCM_CODSEF')) $ 'O/P/Q'.And.;
				dIniRis <= SR8->R8_DATAFIM .And. dFimRis >= SR8->R8_DATAINI
				// Verifica se o tipo de afastamento está contido nos Afastamentos do SIGAMDT
			    // Verifica se o risco esta contido no periodo de afastamento
				aAdd(aAfasta,{  SR8->R8_DATAINI ,SR8->R8_DATAFIM }) // Adiciona o período de afastamento.
			EndIf

			SR8->(dbSkip())
		End

	EndIf

	If Len(aAfasta) > 0

		For nX := 1 To Len(aAfasta) //Percorre todos os períodos afastados.

			If nX == 1

				If aAfasta[nX,1]-1 >= dIniRis //Inicio do afastamento deve ser maior que o inicio do risco.
					aAdd(aEficaz,{ dIniRis ,aAfasta[nX,1]-1 })
				EndIf

				If nX + 1 <= Len(aAfasta)
					aAdd(aEficaz,{ aAfasta[nX,2]+1 ,aAfasta[nX+1,1]-1 })
				ElseIf nX == Len(aAfasta) .And. aAfasta[nX,2]+1 <= dFimRis
					aAdd(aEficaz,{ aAfasta[nX,2]+1 ,dFimRis })
				EndIf

			Else

				If nX == Len(aAfasta)
					aAdd(aEficaz,{ aAfasta[nX,2]+1 ,dFimRis })
				Else
					aAdd(aEficaz,{ aAfasta[nX,2]+1 ,aAfasta[nX+1,1]-1 })
				EndIf

			EndIf

		Next nX

	Else // Caso não encontre nenhum afastamento.
		aAdd( aEficaz, { dIniRis, dFimRis } )
	EndIf

Return aEficaz

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTA192CAT
Verifica se o Funcionario tem Cat impresso.

@author  Denis Hyroshi de Souza
@since   21/10/02

@sample  MDTA192CAT( cFilFichas, TM0->TM0_NUMFIC, (cTRBHIS)->EMP)

@param   cFilialTM0, Caracter, Filial da ficha medica do funcionario
@param   nFicha, Numerico, Numero da ficha medica do funcionario
@param   cEmpTM0, Caracter, Empresada ficha medica do funcionario
/*/
//-------------------------------------------------------------------
Function MDTA192CAT( cFilialTM0, nFicha, cEmpTM0 )

	Local lSai     := .F.
	Local cFilTNC  := ''
	Local cModoCom := ''

	If lMudEmpr .And. cEmpTM0 != cEmpHis
		cModo := FWModeAccess('TNC')
		EMP700OPEN('TNC','TNC',1,cEmpTM0,@cModo,cFilialTM0)
	EndIf

	cModoCom := FWModeAccess('TNC',1) + FWModeAccess('TNC',2) + FWModeAccess('TNC',3)
	cFilTNC := FwxFilial('TNC',cFilialTM0,Substr(cModoCom,1,1),Substr(cModoCom,2,1),Substr(cModoCom,3,1))
	dbSelectArea('TNC')
	dbSetOrder(1)
	dbSeek(cFilTNC)

	While !Eof() .And. cFilTNC == TNC->TNC_FILIAL

		If nFicha = TNC->TNC_NUMFIC .And. !Empty(TNC->TNC_DTEMIS) .And. TNC->TNC_DTEMIS >= dDtAdmiss

			cCat := TNC->TNC_ACIDEN

			If !Empty(TNC->TNC_CATINS)
				cCat := TNC->TNC_CATINS
			Else
				dbSelectArea('TNC')
				dbSkip()
				Loop
			EndIf

			If aScan(aCat,{|x| Dtos(x[1])+x[2] == Dtos(TNC->TNC_DTEMIS)+SubStr(cCat,1,13) }) <= 0
				aAdd(aCat,{TNC->TNC_DTEMIS,SubStr(cCat,1,13)})
			EndIf

		EndIf

		dbSkip()

	End

	If lMudEmpr .And. cEmpTM0 != cEmpHis
		EMP700OPEN('TNC','TNC',1,cEmpHis,@cModo)
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTA192INT
Função que soma os intervalos de exposição aos riscos do agente
asbesto, desconsiderando períodos coincidentes.

@type    function
@author  Julia Kondlatsch
@since   13/08/2019
@sample  MDTA192INT( { { 01/01/2005, 01/01/2010 } } )
@param   aInterv, Array, Matriz de intervalos

@return  nAnos, Numéricos, Numero de anos de exposição
/*/
//-------------------------------------------------------------------
Function MDTA192INT( aInterv )

	Local nCont   := 1
	Local nDias   := 0
	Local nAnos   := 0
	Local lCoin   := .F.

	Default aInterv := {}

	aSort( aInterv,,, { |x,y| x[1] < y[1] } ) // Ordena as datas da menor para a maior

	If Len(aInterv) > 1

		While nCont <= Len( aInterv )

			If nCont !=  Len( aInterv ) // Se não for o último intervalo

				dDataIn1 := aInterv[nCont,1]
				dDataFm1 := aInterv[nCont,2]

				nCont++

				dDataIn2 := aInterv[nCont,1]
				dDataFm2 := aInterv[nCont,2]

				If dDataIn1 == dDataIn2 .Or. dDataFm1 >= dDataIn2 // Se os períodos coincidem

					lCoin := .T.
					dIni  := dDataIn1 // Pega a data inicial do primeiro
					dFim  := IIf( dDataFm1 >= dDataFm2, dDataFm1, dDataFm2) // Pega a maior data final

					While lCoin .And. nCont < Len( aInterv ) // Junta os períodos enquanto eles conicidirem

						dIniUlt := dDataIn2
						dFimUlt := dDataFm2
						nCont++

						If aInterv[nCont,1] <= dFimUlt .Or. aInterv[nCont,1] ==  dIniUlt // Se estiver dentro do período sendo calculado
							lCoin := .T.
							If aInterv[nCont,2] > dFim
								dFim := aInterv[nCont,2]
							EndIf
							If nCont == Len( aInterv )
								nCont++ // Se for o último intervalo e já incorporou ele, extrapola o contador para não entrar no primeiro while
							EndIf
						Else
							lCoin := .F.
						EndIf

					End

				Else
					dIni := dDataIn1
					dFim := dDataFm1
				EndIf
			Else
				dIni := aInterv[nCont,1]
				dFim := aInterv[nCont,2]
				nCont++
			EndIf

			nDias +=  dFim - dIni + 1 // Soma os dias do Intervalo

		End

	ElseIf !Empty(aInterv)

		nDias +=  aInterv[1,2] - aInterv[1,1] + 1

	EndIf

	nAnos := nDias/365

Return nAnos

//-------------------------------------------------------------------
/*/{Protheus.doc} fGeraExames
Função que gera a programação dos exames necessários para o agente
asbesto, de acordo com a periodicidade presente na NR15, se baseando
na data dos últimos exames realizados.

@type    function
@author  Julia Kondlatsch
@since   09/09/2019
@sample  fGeraExames()
@param   nExpTotal, Numérico, Contém todos os funcionários com o seu
respectivo período de exposição

@return  Nil, Sempre nulo
/*/
//-------------------------------------------------------------------
Static Function fGeraExames( nExpTotal )

	Local aExames   := {}
	Local nExa      := 0
	Local dProxExam := SToD('')
	Local dUltExam  := SToD('')
	Local nFreq     := 0
	Local lResult   := .T.
	Local cPCMSO    := ''

	// Busca todos os agentes relacionado ao agente asbesto
	dbSelectArea('TMB') // Exames por Agente
	dbSetOrder(1) // TMB_FILIAL+TMB_AGENTE+TMB_EXAME
	dbSeek( xFilial('TMB') + cAsbesto )
	While TMB->( !EoF() ) .And. xFilial('TMB') == TMB->TMB_FILIAL .And. AllTrim(cAsbesto) == AllTrim(TMB->TMB_AGENTE)
		aAdd( aExames, TMB->TMB_EXAME )
		TMB->( dbSkip() )
	EndDo

	If nExpTotal <= 12
		nFreq := 3
	ElseIf nExpTotal <= 20
		nFreq := 2
	ElseIf nExpTotal > 20
		nFreq := 1
	EndIf

	// Programa todos os próximos exames para o funcionário
	For nExa := 1 To Len ( aExames )

		dProxExam := '' //Limpa a data de programação

		dUltExam := MDTA192EXA( ( cAlsDem )->TM0_NUMFIC, aExames[nExa], @lResult )

		If !Empty( dUltExam ) .And. lResult // Se houver exame com resultado, programa o próximo
			dProxExam := YearSum( SToD( dUltExam ), nFreq )
		ElseIf Empty( dUltExam ) // Se não houver exames já realizados pega a admissão de base
			dProxExam := YearSum( SToD(( cAlsDem )->RA_ADMISSA), nFreq ) //Soma os anos da frequência de acordo com os anos de exposição
		EndIf

		// Se o exame anterior for igual a admissão ou se o último exame programado foi realizado e
		// Se a data da programação do próximo exame for menor do que 30 anos após a demissão do funcionário e
		// Se a data da programação do próximo exame for maior que a data de demissão do fucnionário
		If !Empty(dProxExam) .And. dProxExam <= YearSum( SToD(( cAlsDem )->RA_DEMISSA), 30 )

			While dProxExam <= SToD(( cAlsDem )->RA_DEMISSA) // Enquanto for anterior a demissão do funcionário
				dProxExam := YearSum( dProxExam, nFreq ) // Soma os anos da frequência até ser maior que a demissão
			EndDo

			cPCMSO := MDTA192PCM( dProxExam ) //Busca um PCMSO ativo na data de programação

			If !Empty( cPCMSO )

				RecLock('TM5',.T.)

					TM5->TM5_FILIAL := xFilial('TM5')
					TM5->TM5_NUMFIC := ( cAlsDem )->TM0_NUMFIC
					TM5->TM5_EXAME  := aExames[nExa]
					TM5->TM5_DTPROG := dProxExam
					TM5->TM5_FILFUN := ( cAlsDem )->TM0_FILFUN
					TM5->TM5_MAT    := ( cAlsDem )->RA_MAT
					TM5->TM5_ORIGEX := '2' //Ocupacional
					TM5->TM5_PCMSO  := cPCMSO
					TM5->TM5_NATEXA := '2' //Periódico
					TM5->TM5_CC     := ( cAlsDem )->RA_CC
					TM5->TM5_CODFUN := ( cAlsDem )->RA_CODFUNC
					TM5->TM5_CBO    := Posicione( 'SRJ', 2, xFilial('SRJ') + ( cAlsDem )->RA_CODFUNC, 'RJ_CBO' ) //Busca CBO da função
					TM5->TM5_TNOTRA := ( cAlsDem )->RA_TNOTRAB

				MsUnlock('TM5')

			EndIf

		EndIf

	Next nExa

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTA192EXA
Busca a última programação de exame do funcionáirio

@type    function
@author  Julia Kondlatsch
@since   11/09/2019
@sample  MDTA192EXA()
@param   cFicha, Caractere, Numero da ficha médica do funcionário
@param   cExame, Caractere, Código do exame a ser buscado
@param   lResult, Lógico, Verdadeiro se o exame possui data de
resultado

@return  Nil, Sempre nulo
/*/
//-------------------------------------------------------------------
Static Function MDTA192EXA( cFicha, cExame, lResult )

	Local cAlsExame := GetNextAlias()
	Local cTM5Fil   := xFilial('TM5')
	Local dUltExam  := SToD('')

	lResult := .F.

	// Seleciona a data mais recente que o exame foi programado
	BeginSQL Alias cAlsExame
		SELECT TM5_DTPROG, TM5_DTRESU
			FROM %table:TM5% TM5
		WHERE TM5_FILIAL = %exp:cTM5Fil%
			AND	TM5.TM5_NUMFIC = %exp:cFicha%
			AND	TM5.TM5_EXAME = %exp:cExame%
			AND TM5.%NotDel%
		ORDER BY TM5.TM5_DTPROG DESC
	EndSQL

	If (cAlsExame)->(!Eof())
		If !Empty((cAlsExame)->TM5_DTRESU)
			lResult  := .T.
		EndIf
		dUltExam := (cAlsExame)->TM5_DTPROG
	EndIf

Return dUltExam

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTA192PCM
Busca um PCMSO ativo na data passada por parâmetro.

@type    function
@author  Julia Kondlatsch
@since   10/09/2019
@sample  MDTA192PCM()
@param   dProxExam, Data, Data da programação do exame

@return  cPCMSO, Caractere, Código do PCMSO válido
/*/
//-------------------------------------------------------------------
Function MDTA192PCM( dProxExam )

	Local cPCMSO    := ''
	Local cTMWFil   := xFilial('TMW')
	Local cAlsPCMSO := GetNextAlias()

	dbselectArea('TMW')
	dbSetOrder(3) //TMW_FILIAL + DTOS(TMW_DTINIC)
	dbSeek( xFilial('TMW') +  DTOS(dProxExam) )

	// Seleciona um PCMSO cuja data do exame estja contida
	BeginSQL Alias cAlsPCMSO
		SELECT TMW_PCMSO, TMW_DTINIC
			FROM %table:TMW% TMW
		WHERE TMW.TMW_FILIAL = %exp:cTMWFil%
			AND TMW.TMW_DTINIC <= %exp:dProxExam%
			AND TMW.TMW_DTFIM  >= %exp:dProxExam%
			AND TMW.%NotDel%
		ORDER BY TMW_DTINIC
	EndSQL

	dbselectArea(cAlsPCMSO)
	dbGoTop()
	If (cAlsPCMSO)->(!EoF())
		cPCMSO := (cAlsPCMSO)->TMW_PCMSO
	EndIf

Return cPCMSO

//---------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Execução de Parâmetros na Definição do Schedule

@return aParam, Array, Conteudo com as definições de parâmetros para WF

@sample SchedDef()

@author Alexandre Santos
@since 04/07/2018
/*/
//---------------------------------------------------------------------
Static Function SchedDef()
Return {"P", "PARAMDEF", "", {}, "Param"}
