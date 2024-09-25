#Include "mdta200.ch"
#Include "Protheus.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA200A
Monta markbrowse dos riscos.

@author Inacio Luiz Kolling
@since 28/03/2000
@return .T.
/*/
//---------------------------------------------------------------------
Function MDTA200A()

	Private aOldDBF
	Private aVETINR := {}
	Private aRotina := MenuDef()


	SetFunName( "MDTA200A" )

	//Abre empresa e filial correta
	MDT200AEMP()

	If MDT200MUDF()

		If cNatExam != M->TMY_NATEXA
			RISCOSTRB()
			cNatExam := M->TMY_NATEXA
		Endif

		OldRot := aCLONE( aROTINA )

		dbSelectArea( cTRB200 )
		dbGoTop()
		If SuperGetMV( "MV_NGMDTRI",.F.,"1" ) == "2"//Indica se todos os riscos serão impressos no atestado ASO ou apenas os que foram selecionados. 1 = Todos; 2 = Selecionados.
			MARKBROW( cTRB200,"TN0_OK",,aEstRis,lInverte, cMarca, "A200Invert(cMarca)" )
		Else

			aField := {	{ Posicione( "SX3", 2, "TN0_NUMRIS", "X3Titulo()" ), "TN0_NUMRIS", "C", 09, 0, "999999999" },;//"Dt. Transfer"
						{ Posicione( "SX3", 2, "TN0_AGENTE", "X3Titulo()" ), "TN0_AGENTE", "C", 09, 0, "@!" 	   },;//"Empr. Origem"
						{ Posicione( "SX3", 2, "TN0_NOMAGE", "X3Titulo()" ), "TN0_NOMAGE", "C", 20, 0, "@!"		   },;//"Fil. Origem "
						{ Posicione( "SX3", 2, "TN0_FONTE" , "X3Titulo()" ), "TN0_FONTE",  "C", 08, 0, "@!" 	   },;//"Nome Fil. Origem"
						{ Posicione( "SX3", 2, "TN0_NOMFON", "X3Titulo()" ), "TN0_NOMFON", "C", 20, 0, "@!" 	   },;//"Mat. Origem "
						{ Posicione( "SX3", 2, "TN0_DTAVAL", "X3Titulo()" ), "TN0_DTAVAL", "D", 08, 0, "99/99/99"  } }//"Nome Funcionário"*/

			mBrowse( 6, 1,22,75,cTRB200,aField )

		Endif

		aRotina := aCLONE( OldRot )

		// Realiza gravação dos riscos ao ASO
		If IsInCallStack( "MDTA410" ) .And. SuperGetMV("MV_NGMDTRI",.F.,"1") == "2"
			MDT200VAR(nOPPAR,,.T. )
		Endif

	EndIf

	//Fecha a empresa
	MDT200REMP()

	SetFunName( "MDTA200A" )

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA200AV()
Monta markbrowse dos riscos.

@author Inacio Luiz Kolling
@since 28/03/2000

@param

@return
/*/
//---------------------------------------------------------------------
Function MDTA200AV()

	//Abre a empresa
	MDT200AEMP()

	dbSelectArea( "TN0" )
	dbsetorder( 1 )
	dbseek( xFilial( "TN0" )+( cTRB200 )->TN0_NUMRIS )

	NGCAD01( 'TN0', RECNO(),1 )
	dbSelectArea( cTRB200 )

	//Retorna para empresa e filial correta
	MDT200REMP()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Utilizacao de Menu Funcional

@type function

@source MDTA200A.prx

@author Inacio Luiz Kolling
@since 28/03/2000

@param lMdtPs, Lógico, Determina se é prestador de serviço

@Obs Tipo de transações a serem efetuadas
@Obs     2 - Visualizar detalhes do risco

@sample MenuDef( .F. )

@return Array, Retorna as opções do menu
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina

		aRotina := { { STR0033,"MDTA200AV",0,2 } }//Visualizar

Return aRotina