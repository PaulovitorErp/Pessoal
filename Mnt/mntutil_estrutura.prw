#INCLUDE "PROTHEUS.CH"
#Include "TOPCONN.CH"
#Include "RWMAKE.CH"
#include "Fileio.ch"
#include "tbiconn.ch"
#INCLUDE "DBINFO.CH"
#INCLUDE "MSGRAPHI.CH"
#INCLUDE "DBTREE.CH"
#INCLUDE "mntutil_estrutura.CH"
#INCLUDE "FWADAPTEREAI.CH" // Integração via Mensagem Única

Static lRel12133 := GetRPORelease() >= '12.1.033'

//----------------------------------------------------------------
// Fonte destinado apenas as funções que tenham relação com
// estrutura. Ex.: Verificação de componentes, consistência, etc.
// Antes de adicionar uma função aqui, verifique se atende
// a este requisito.
//----------------------------------------------------------------

Function MNTUTILEST()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGESTCSTC   ³ Autor ³In cio Luiz Kolling  ³ Data ³14/11/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta vetor com os componentes que receberÆo o contador(STC)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³cBDMSTC  - Codigo do bem                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³NGESTCSTC                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGESTCSTC(cBEMSTC)

	Local vCOMPCOM  := {}
	Local cALIOLD   := Alias()
	Local nSETORDER := IndexOrd()

	Local aIdxSTC   := {{"TCODBEM"},{"TCOMPON"}}
	Local oTmpTblSTC

	Local aIdxTRBF  := {{"FCODBEM"}}
	Local oTpTbTRBF

	Local aIdxTRBI  := {{"ICODBEM"},{"ICOMPON"}}
	Local oTpTbTRBI

	//Alias das Tabelas
	Private cTRBS
	Private cTRBF
	Private cTRBI

	Private cBEMCSTC := cBEMSTC, aESTRU := {}

	DbselectArea("ST9")
	Dbsetorder(1)
	If Dbseek(xfilial('ST9')+cBEMCSTC)
		If st9->t9_temcont = 'S'
			DbselectArea("STC")
			Dbsetorder(1)
			If Dbseek(xfilial('STC')+cBEMCSTC)
				ADBFP := {}
				AADD(ADBFP,{"TCODBEM","C",16,0})
				AADD(ADBFP,{"TTIPOBE","C",01,0})
				AADD(ADBFP,{"TCOMPON","C",16,0})
				AADD(ADBFP,{"TTIPOCO","C",01,0})
				AADD(ADBFP,{"TSELECI","C",01,0})

				//Alias: cTRBS (STC)
				cTRBS := GetNextAlias()
				oTmpTblSTC := fTempTable(cTRBS, ADBFP, aIdxSTC)

				cBEMPAI := NGBEMPAI(cBEMCSTC)

				If !Empty(cBEMPAI)
					// LE O STC APARTIR DO BEM PAI (cBEMPAI)
					NGECOMTSTC(cBEMPAI)
				Else
					// LE O STC APARTIR DO BEM INFORMADO
					lPAIEST := .T.
					NGECOMTSTC(cBEMCSTC)
					IF Len(aESTRU) > 0
						cBEMPAI := cBEMCSTC
					Endif
				Endif

				DbselectArea(cTRBS)
				Dbsetorder(1)
				Dbgotop()
				If Reccount() > 0
					aDBFF := {}
					AADD(aDBFF,{"FCODBEM","C",16,0})
					AADD(aDBFF,{"FTIPOBE","C",01,0})
					AADD(aDBFF,{"FCOMPON","C",16,0})
					AADD(aDBFF,{"FTIPOCO","C",01,0})

					cTRBF := GetNextAlias()
					oTpTbTRBF := fTempTable(cTRBF, aDBFF, aIdxTRBF)

					aDBI := {}
					AADD(aDBI,{"ICODBEM","C",16,0})
					AADD(aDBI,{"ITIPOBE","C",01,0})
					AADD(aDBI,{"ICOMPON","C",16,0})
					AADD(aDBI,{"ITIPOCO","C",01,0})
					AADD(aDBI,{"ISELECI","C",01,0})

					cTRBI := GetNextAlias()
					oTpTbTRBI := fTempTable(cTRBI, aDBI, aIdxTRBI)

					If cBEMCSTC = cBEMPAI
						DbselectArea(cTRBS)
						Dbgotop()
						While !Eof()
							lGRAVABF := .F.
							If (cTRBS)->ttipoco = "P"
								lGRAVABF := .T.
							ElseIf (cTRBS)->ttipoco = "I"
								If (cTRBS)->tcodbem = cBEMCSTC .Or. (cTRBS)->ttipobe = "P"
									lGRAVABF := .T.
								Endif
							Endif
							If lGRAVABF
								(cTRBF)->(DbAppend())
								(cTRBF)->FCODBEM := (cTRBS)->tcodbem
								(cTRBF)->FTIPOBE := (cTRBS)->ttipobe
								(cTRBF)->FCOMPON := (cTRBS)->tcompon
								(cTRBF)->FTIPOCO := (cTRBS)->ttipoco
								(cTRBS)->TSELECI := "S"
							Endif
							DbselectArea(cTRBS)
							Dbskip()
						End

						DbselectArea(cTRBS)
						Dbsetorder(2)
						Dbgotop()
						While !Eof()
							If (cTRBS)->ttipoco = "I" .And. (cTRBS)->ttipobe = "I" .And. Empty((cTRBS)->tseleci)
								nRECNOTR := Recno()
								cFCOMPON := (cTRBS)->TCOMPON
								lINCOMPO := .F.

								NGESTCSTCREP(cFCOMPON)

								DbselectArea(cTRBS)
								Dbgoto(nRECNOTR)

								If lINCOMPO
									(cTRBF)->(DbAppend())
									(cTRBF)->FCODBEM := (cTRBS)->tcodbem
									(cTRBF)->FTIPOBE := (cTRBS)->ttipobe
									(cTRBF)->FCOMPON := (cTRBS)->tcompon
									(cTRBF)->FTIPOCO := (cTRBS)->ttipoco
									(cTRBS)->TSELECI := "S"
								Endif
							Endif
							DbselectArea(cTRBS)
							Dbskip()
						End

					Else

						NGESTCSTCARI(cBEMCSTC)
						DbselectArea(cTRBI)
						Dbsetorder(1)
						Dbgotop()
						While !Eof()
							If (cTRBI)->itipoco = "I" .And. (cTRBI)->icodbem = cBEMCSTC
								(cTRBF)->(DbAppend())
								(cTRBF)->FCODBEM := (cTRBI)->icodbem
								(cTRBF)->FTIPOBE := (cTRBI)->itipobe
								(cTRBF)->FCOMPON := (cTRBI)->icompon
								(cTRBF)->FTIPOCO := (cTRBI)->itipoco
								(cTRBI)->ISELECI := "S"
							Endif
							DbselectArea(cTRBI)
							Dbskip()
						End

						DbselectArea(cTRBI)
						Dbsetorder(2)
						Dbgotop()
						While !Eof()
							If (cTRBI)->itipoco = "I" .And. (cTRBI)->itipobe = "I" .And. Empty((cTRBI)->iseleci)
								nRECNOTR := Recno()
								cFCOMPON := (cTRBI)->ICOMPON
								lINCOMPO := .F.

								NGESTIMEDEI(cFCOMPON)

								DbselectArea(cTRBI)
								Dbgoto(nRECNOTR)

								If lINCOMPO
									(cTRBF)->(DbAppend())
									(cTRBF)->FCODBEM := (cTRBI)->icodbem
									(cTRBF)->FTIPOBE := (cTRBI)->itipobe
									(cTRBF)->FCOMPON := (cTRBI)->icompon
									(cTRBF)->FTIPOCO := (cTRBI)->itipoco
									(cTRBI)->ISELECI := "S"
								Endif
							Endif
							DbselectArea(cTRBI)
							Dbskip()
						End

					Endif

					DbselectArea(cTRBF)
					Dbgotop()
					While !Eof()
						Aadd(vCOMPCOM,(cTRBF)->fcompon)
						Dbskip()
					End

					//Fecha os arquivos temporarios e deleta fisicamente o arquivo temporario e seus
					//indices

					oTpTbTRBF:Delete()

					oTpTbTRBI:Delete()
				Endif

				oTmpTblSTC:Delete()
			Endif
		Endif
	Endif

	DbselectArea(cALIOLD)
	Dbsetorder(nSETORDER)

Return vCOMPCOM

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGECOMTSTC  ³ Autor ³ In cio Luiz Kolling ³ Data ³14/11/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria um vetor com TODOS os componente da estrutura          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³NGESTCSTC                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGECOMTSTC(cVBEM)

	DbselectArea("STC")
	Dbsetorder(1)
	Dbseek(xFILIAL("STC")+cVBEM)
	While !EOF() .and. stc->tc_filial == xFilial('STC') .and.;
	stc->tc_codbem == cVBEM

		nRec1 := Recno()
		cCOMP := stc->tc_compone
		If STC->TC_TIPOEST = "B"
			cTCODBEM := NGSEEK("ST9",STC->TC_CODBEM,1,"T9_TEMCONT")
			cTCOMPON := NGSEEK("ST9",STC->TC_COMPONE,1,"T9_TEMCONT")
			(cTRBS)->(DbAppend())
			(cTRBS)->TCODBEM := stc->tc_codbem
			(cTRBS)->TTIPOBE := cTCODBEM
			(cTRBS)->TCOMPON := cCOMP
			(cTRBS)->TTIPOCO := cTCOMPON
			Aadd(aESTRU,{cCOMP})
			DbselectArea("STC")
			If DbSeek(xFilial('STC')+cCOMP)
				NGECOMPCFIL(cCOMP)
			Endif
		Endif

		DbGoTo(nRec1)
		DbSkip()
	End
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGECOMPCFIL ³ Autor ³In cio Luiz Kolling  ³ Data ³14/11/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inclui os elementos filhos da estrutura                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³NGECOMTSTC                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGECOMPCFIL(cVCOMP)

	Local nRec2

	While !eof() .and. stc->tc_filial == xFilial('STC') .and.;
	stc->tc_codbem == cVCOMP

		nRec2 := Recno()
		cCOMP := stc->tc_compone
		If STC->TC_TIPOEST = "B"
			cTCODBEM := NGSEEK("ST9",STC->TC_CODBEM,1,"T9_TEMCONT")
			cTCOMPON := NGSEEK("ST9",STC->TC_COMPONE,1,"T9_TEMCONT")
			(cTRBS)->(DbAppend())
			(cTRBS)->TCODBEM := stc->tc_codbem
			(cTRBS)->TTIPOBE := cTCODBEM
			(cTRBS)->TCOMPON := cCOMP
			(cTRBS)->TTIPOCO := cTCOMPON
			DbselectArea("STC")
			If DbSeek(xFilial('STC')+cCOMP)
				NGECOMPCFIL(cCOMP)
			Endif
		Endif

		DbGoTo(nRec2)
		DbSkip()
	End

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGESTCSTCREP³ Autor ³In cio Luiz Kolling  ³ Data ³14/11/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inclui o componente imediato do bem pai da estrutura        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³NGESTCSTC                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGESTCSTCREP(cVBEM)

	While !EOF() .and. (cTRBS)->tcompon == cVBEM
		nRec1  := Recno()
		cCOMP1 := (cTRBS)->tcodbem
		DbselectArea(cTRBS)
		If DbSeek(cCOMP1)
			If ((cTRBS)->ttipoco = "I" .And. (cTRBS)->ttipobe = "P" );
			.Or. ((cTRBS)->ttipoco = "I" .And. (cTRBS)->tcodbem = cBEMCSTC)
				lINCOMPO := .T.
				Exit
			Endif
			NGESTREIMPAI(cCOMP1)
			If lINCOMPO
				Exit
			Endif
		Endif
		DbGoTo(nRec1)
		DbSkip()
	End

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGESTREIMPAI³ Autor ³In cio Luiz Kolling  ³ Data ³14/11/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Procura o pai do componente imediato                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³NGESTCSTCREP                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGESTREIMPAI(cVCOMP)

	Local nRec2

	While !eof() .and. (cTRBS)->tcompon == cVCOMP
		nRec2  := Recno()
		cCOMP2 := (cTRBS)->tcodbem
		If DbSeek(cCOMP2)
			If ((cTRBS)->ttipoco = "I" .And. (cTRBS)->ttipobe = "P");
			.Or. ((cTRBS)->ttipoco = "I" .And. (cTRBS)->tcodbem = cBEMCSTC)
				lINCOMPO := .T.
				Exit
			Endif

			NGESTREIMPAI(cCOMP2)
			If lINCOMPO
				Exit
			Endif
		Endif

		DbGoTo(nRec2)
		DbSkip()
	End

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGESTCSTCARI³ Autor ³In cio Luiz Kolling  ³ Data ³14/11/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Seleciona os componentes do imediato da estrutura           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³NGESTCSTC                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGESTCSTCARI(cVBEM)

	DbselectArea(cTRBS)
	Dbsetorder(1)
	Dbseek(cVBEM)
	While !EOF() .and. (cTRBS)->tcodbem == cVBEM
		nRec1  := Recno()
		cCOMP1 := (cTRBS)->tcompon
		(cTRBI)->(DbAppend())
		(cTRBI)->ICODBEM := (cTRBS)->tcodbem
		(cTRBI)->ITIPOBE := (cTRBS)->ttipobe
		(cTRBI)->ICOMPON := cCOMP1
		(cTRBI)->ITIPOCO := (cTRBS)->ttipoco
		DbselectArea(cTRBS)
		If DbSeek(cCOMP1)
			NGESTCIMEDE(cCOMP1)
		Endif
		DbGoTo(nRec1)
		DbSkip()
	End

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGESTCIMEDE ³ Autor ³In cio Luiz Kolling  ³ Data ³14/11/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inclui os elementos filhos do componente imediato          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³NGESTCSTCARI                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGESTCIMEDE(cVCOMP)

	Local nRec2

	While !eof() .and. (cTRBS)->tcodbem == cVCOMP
		nRec2  := Recno()
		cCOMP2 := (cTRBS)->tcompon
		(cTRBI)->(DbAppend())
		(cTRBI)->ICODBEM := (cTRBS)->tcodbem
		(cTRBI)->ITIPOBE := (cTRBS)->ttipobe
		(cTRBI)->ICOMPON := cCOMP2
		(cTRBI)->ITIPOCO := (cTRBS)->ttipoco
		DbselectArea(cTRBS)
		If DbSeek(cCOMP2)
			NGESTCIMEDE(cCOMP2)
		Endif
		DbGoTo(nRec2)
		DbSkip()
	End

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGESTIMEDEI ³ Autor ³In cio Luiz Kolling  ³ Data ³14/11/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inclui o componente imediato do bem                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³NGESTCSTC                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGESTIMEDEI(cVBEM)

	While !EOF() .and. (cTRBI)->icompon == cVBEM
		nRec1  := Recno()
		cCOMP1 := (cTRBI)->icodbem
		DbselectArea(cTRBI)
		If DbSeek(cCOMP1)
			If (cTRBI)->itipoco = "I" .And. (cTRBI)->icodbem = cBEMCSTC
				lINCOMPO := .T.
				Exit
			Endif
			NGCOMPRIMERE(cCOMP1)
			If lINCOMPO
				Exit
			Endif
		Endif
		DbGoTo(nRec1)
		DbSkip()
	End

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGCOMPRIMERE³ Autor ³In cio Luiz Kolling  ³ Data ³14/11/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inclui os componetes filhos do bem imediato                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³NGESTIMEDEI                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGCOMPRIMERE(cVCOMP)

	Local nRec2

	While !eof() .and. (cTRBI)->icompon == cVCOMP
		nRec2  := Recno()
		cCOMP2 := (cTRBI)->icodbem
		If DbSeek(cCOMP2)
			If (cTRBI)->itipoco = "I" .And. (cTRBI)->icodbem = cBEMCSTC
				lINCOMPO := .T.
				Exit
			Endif

			NGCOMPRIMERE(cCOMP2)
			If lINCOMPO
				Exit
			Endif
		Endif

		DbGoTo(nRec2)
		DbSkip()
	End

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} NGCOMPPCONT
Procura os componente da estrututra (STZ) que deverao receber
o contador
@type function

@author Inácio Luiz Kolling
@since 21/11/2003

@param [cBEMV]  , Caracter, Código do bem
@param [dDATAV] , Data    , Data para realizar a busca na estrutura
@param [cHORAV] , Caracter, Hora para realizar a busca na estutura
@param [aTrbEst], Array   , Array possuindo as tabelas temporárias responsáveis por montar a estrutura do bem.
							[1] tabela temporaria do pai da estrutura - cTRBS
							[2] tabela temporaria do pai da estrutura - cTRBF
@return aCOMPDAD - [1] (cTRBF)->fcompon - Código do componente.
				   [2] (cTRBF)->fdtmovi - Data da movimentação.
				   [3] (cTRBF)->fhoraen - Hora da entrada.
				   [4] (cTRBF)->fdtsaid - Data da saida.
				   [5] (cTRBF)->fhorasa - Hora da saida.
				   [6] (cTRBF)->flocali - Código da localização.
				   [7] (cTRBF)->fcodbem - Código do bem pai.
/*/
//---------------------------------------------------------------------

Function NGCOMPPCONT(cBEMV,dDATAV,cHORAV,cFilNov, aTrbEst)

	Local aArea      := GetArea()
	Local aAreaST9   := {}
	Local vSTZRECN   := {}
	Local aCOMPDAD   := {}
	Local aIdxSTC    := { { 'TCODBEM' }, { 'TCOMPON' } }
	Local aIdxTRBF   := { { 'FCOMPON' }, { 'FDTMOVI' } }
	Local xy         := 0
	Local nPosF      := 0
	Local lTemEst    := .F.
	Local lFrota     := NGVERUTFR()
	Local cTIPMOD    := ''
	Local cBEMRET    := ''
	Local oTableSTC
	Local oTpTbTRBF

	Private cBEMPAR  := cBEMV
	Private dDATAPAR := dDATAV
	Private cHORAPAR := cHORAV
	Private cTRBS    := ''
	Private cTRBF    := ''
	Private cFilSt9  := NGTROCAFILI( 'ST9', cFilNov )
	Private cFilStz  := NGTROCAFILI( 'STZ', cFilNov )

	Default aTrbEst  := {}

	lTemEst := Len(aTrbEst) > 0

	If !lTemEst
		cTRBF := GetNextAlias()
		cTRBS := GetNextAlias()
	Else
		cTRBS := aTrbEst[1]
		cTRBF := aTrbEst[2]
	EndIf

	// ESTRUTURA DA FAMILIA DO BEM
	DbselectArea('ST9')
	DbSetOrder(1)
	Dbseek(cFilSt9+cBEMV)
	cCODFAM := st9->t9_codfami
	cTIPMOD := If(lFrota,st9->t9_tipmod,Nil)
 	aESTFAM := NGCOMPEST(cCODFAM,"F",.T.,.F.,.T.,cFilNov,Nil,cTIPMOD)

	nRECNDAD := 0

	DbselectArea("STZ")
	DbSetOrder(01)
	If DbSeek(cFilStz+cBEMPAR)
		While !eof() .And. stz->tz_filial = cFilStz .And.;
		stz->tz_codbem = cBEMPAR
			lINCARR := .F.
			If Empty(stz->tz_datasai)
				If stz->tz_datamov <= dDATAPAR
					If stz->tz_datamov < dDATAPAR
						lINCARR := .T.
					Else
						If cHORAPAR >= stz->tz_horaent
							lINCARR := .T.
						Endif
					Endif
				Endif
			Else
				If stz->tz_datamov <= dDATAPAR .And.  stz->tz_datasai >= dDATAPAR
					If stz->tz_datamov = dDATAPAR .And. stz->tz_datasai = dDATAPAR
						If stz->tz_horaent <= cHORAPAR .And. stz->tz_horasai >= cHORAPAR
							lINCARR := .T.
						Endif
					ElseIf stz->tz_datamov < dDATAPAR  .And. stz->tz_datasai > dDATAPAR
						lINCARR := .T.
					ElseIf stz->tz_datamov = dDATAPAR
						If stz->tz_horaent <= cHORAPAR
							lINCARR := .T.
						EndIf
					ElseIf stz->tz_datasai = dDATAPAR
						If stz->tz_horasai >= cHORAPAR
							lINCARR := .T.
						EndIf
					EndIf
				EndIf
			Endif

			If lINCARR
				Aadd(vSTZRECN,Recno())
			Endif
			Dbskip()
		End
	Endif

	cBEMPSTZ := NGBEMPAI(cBEMPAR) //Retorna o bem pai de toda a estrutura
	If Empty(cBEMPSTZ)
		cBEMPSTZ := cBEMPAR
	EndIf

	If !lTemEst
		ADBFP := {}
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
		//campo repassa criado para manter o arquivo temporario com toda a estrutura para pesquisa
		//ao inves de excluir itens que nao repassa contador, apenas grava "N" neste campo e nao considera o registro

		oTableSTC := fTempTable(cTRBS, ADBFP, aIdxSTC)
	EndIf

	DbselectArea("STZ")
	Dbsetorder(4)
	Dbseek(cFilStz+cBEMPSTZ)
	While !Eof() .And. STZ->TZ_FILIAL == cFilStz .And.;
	STZ->TZ_BEMPAI == cBEMPSTZ
		nREC  := RECNO()
		cCOMP := STZ->TZ_CODBEM

		lINCARR := .F.
		If Empty(stz->tz_datasai)
			If stz->tz_datamov <= dDATAPAR
				If stz->tz_datamov < dDATAPAR
					lINCARR := .T.
				Else
					If cHORAPAR >= stz->tz_horaent
						lINCARR := .T.
					EndIf
				EndIf
			EndIf
		Else
			If stz->tz_datamov <= dDATAPAR .And.  stz->tz_datasai >= dDATAPAR
				If stz->tz_datamov = dDATAPAR .And. stz->tz_datasai = dDATAPAR
					If stz->tz_horaent <= cHORAPAR .And. stz->tz_horasai >= cHORAPAR
						lINCARR := .T.
					EndIf
				ElseIf stz->tz_datamov < dDATAPAR  .And. stz->tz_datasai > dDATAPAR
					lINCARR := .T.
				ElseIf stz->tz_datamov = dDATAPAR
					If stz->tz_horaent <= cHORAPAR
						lINCARR := .T.
					EndIf
				ElseIf stz->tz_datasai = dDATAPAR
					If stz->tz_horasai >= cHORAPAR
						lINCARR := .T.
					EndIf
				EndIf
			EndIf
		EndIf

		If lINCARR
			(cTRBS)->(DbAppend())
			(cTRBS)->TCODBEM := stz->tz_bempai
			(cTRBS)->TCOMPON := stz->tz_codbem
			(cTRBS)->TDTMOVI := stz->tz_datamov
			(cTRBS)->TTIPOMO := stz->tz_tipomov
			(cTRBS)->TDTSAID := stz->tz_datasai
			(cTRBS)->TTIPOCO := stz->tz_temcont
			(cTRBS)->THORAEN := stz->tz_horaent
			(cTRBS)->THORASA := stz->tz_horasai
			(cTRBS)->TTIPOBE := stz->tz_temcpai
			(cTRBS)->TLOCALI := stz->tz_localiz
			(cTRBS)->REPASSA := 'S'

			// BUSCA O VALOR DOS CONTADORES NO HISTORICO
			DbselectArea("STZ")
			If Dbseek(cFilStz+cCOMP)
				NGESTZCOMPZ(cCOMP)
			EndIf
		EndIf
		dbGoTo(nREC)
		dbSkip()
	End

	aBENNATU := {}
	If cBEMPAR <> cBEMPSTZ .And. !Empty(cBEMPSTZ)

		dbSelectArea(cTRBS)
		dbSetOrder(2)
		dbGotop()
		While !Eof()

			nRECTRBS := Recno()
			cVBEMAU  := (cTRBS)->TCOMPON
			cBEMRET  := " "

			If (cTRBS)->TTIPOCO <> "I"
				Aadd(aBENNATU,(cTRBS)->TCOMPON)
			Else

				//Verifica o bem pai do componente controlado pelo pai imediato
				While .T.
					dbSelectArea("ST9")
					dbSetOrder(01)
					If dbSeek(cFilSt9+cVBEMAU)
						If ST9->T9_TEMCONT = "S"
							cBEMRET := cVBEMAU
							Exit
						EndIf
					EndIf

					dbSelectArea(cTRBS)
					If dbSeek(cVBEMAU)
						cVBEMAU := (cTRBS)->TCODBEM
					Else
						dbSelectArea("ST9")
						dbSetOrder(01)
						If dbSeek(cFilSt9+cVBEMAU)
							If ST9->T9_TEMCONT = "S"
								cBEMRET := cVBEMAU
							EndIf
						Else
							cBEMRET   := Space(Len(cVBEM))
						EndIf
						Exit
					EndIf
				End

				dbSelectArea(cTRBS)
				dbGoto(nRECTRBS)
				If Empty(cBEMRET) .Or. cBEMRET <> cBEMPAR
					Aadd(aBENNATU,(cTRBS)->TCOMPON)
				EndIf

			EndIf
			dbSelectArea(cTRBS)
			dbSkip()
		End

	Else

		//Verificar os componentes que podem ser repassados o contador do pai da estrutura
		dbSelectArea(cTRBS)
		dbSetOrder(2)
		dbGotop()
		While !Eof()

			nRECTRBS := Recno()
			cVBEMAU  := (cTRBS)->TCOMPON
			cBEMRET  := " "

			If (cTRBS)->TTIPOCO == "S" .Or. (cTRBS)->TTIPOCO == "N"
				Aadd(aBENNATU,(cTRBS)->TCOMPON)
			ElseIf aSCAN(aBENNATU,{|x| x == (cTRBS)->TCODBEM }) > 0 //Verifica se o Pai não passar contador o filho nao repassa.
				aAreaST9 := GetArea()
				dbSelectArea("ST9")
				dbSetOrder(1)
				If dbSeek( xFilial("ST9") + (cTRBS)->TCOMPON )

					If ST9->T9_TEMCONT == "I"
						Aadd(aBENNATU,(cTRBS)->TCOMPON)
					EndIf

				EndIf
				RestArea(aAreaST9)
			Else

				//Verifica o bem pai do componente controlado pelo pai imediato
				If (cTRBS)->TTIPOCO == "I"
					While .T.
						dbSelectArea("ST9")
						dbSetOrder(01)
						If dbSeek(cFilSt9+cVBEMAU)
							If ST9->T9_TEMCONT = "S"
								cBEMRET := cVBEMAU
								Exit
							EndIf
						EndIf

						dbSelectArea(cTRBS)
						If dbSeek(cVBEMAU)
							cVBEMAU := (cTRBS)->TCODBEM
						Else
							dbSelectArea("ST9")
							dbSetOrder(01)
							If dbSeek(cFilSt9+cVBEMAU)
								If ST9->T9_TEMCONT = "S"
									cBEMRET := cVBEMAU
								EndIf
							Else
								cBEMRET   := Space(Len(cVBEM))
							EndIf
							Exit
						EndIf
					End

					dbSelectArea(cTRBS)
					dbGoto(nRECTRBS)
					If Empty(cBEMRET) .Or. cBEMRET <> cBEMPAR
						Aadd(aBENNATU,(cTRBS)->TCOMPON)
					EndIf
				EndIf
			EndIf
			dbSelectArea(cTRBS)
			dbSkip()
		End
	EndIf

	If Len(aBENNATU) > 0
		For xy := 1 To Len(aBENNATU)

			dbSelectArea(cTRBS)
			If dbSeek(aBENNATU[xy])
				RecLock((cTRBS),.F.)
				(cTRBS)->REPASSA := 'N'
				(cTRBS)->(MsUnlock())
			EndIf

		Next xy
	EndIf

	DbselectArea(cTRBS)
	Dbsetorder(1)
	Dbgotop()
	If Reccount() > 0

		If !lTemEst
			aDBFF := {}
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
			oTpTbTRBF := fTempTable(cTRBF, aDBFF, aIdxTRBF)
		EndIf
		dbSelectArea(cTRBS)
		dbSetOrder(1)
		dbGotop()
		While !Eof()

			(cTRBF)->(DbAppend())
			(cTRBF)->FCODBEM := (cTRBS)->tcodbem
			(cTRBF)->FTIPOBE := (cTRBS)->ttipobe
			(cTRBF)->FCOMPON := (cTRBS)->tcompon
			(cTRBF)->FTIPOCO := (cTRBS)->ttipoco
			(cTRBF)->FDTMOVI := (cTRBS)->tdtmovi
			(cTRBF)->FTIPOMO := (cTRBS)->ttipomo
			(cTRBF)->FDTSAID := (cTRBS)->tdtsaid
			(cTRBF)->FHORAEN := (cTRBS)->thoraen
			(cTRBF)->FHORASA := (cTRBS)->thorasa
			(cTRBF)->FLOCALI := (cTRBS)->tlocali
			(cTRBF)->REPASSA := (cTRBS)->repassa
			If (cTRBS)->repassa == "S"
				If NGESTUTRBS((cTRBS)->tdtsaid,(cTRBS)->tdtmovi,(cTRBS)->thoraen, (cTRBS)->thorasa)
					(cTRBF)->REPASSA := "S"
				Else
					(cTRBF)->REPASSA := "N"
				EndIf
			EndIf
			dbSelectArea(cTRBS)
			dbSkip()
		End

		DbselectArea(cTRBF)
		Dbgotop()
		While !Eof()
			If (cTRBF)->REPASSA == "S"
				cPaiSup := ""
				lEnd := .F.
				// VERIFICA OS COMPONENTES PARA NÇO REPASSAR APARTIR DA EST. PADRAO
				lREPASS := .T.
				//  If Len(aESTFAM) > 0
				//armazena variaveis do bem pai e do componente
				cCodPai := (cTRBF)->FCODBEM
				cCodCom := (cTRBF)->FCOMPON
				cFamPai := NGSEEK('ST9',cCodPai,1,'T9_CODFAMI',cFilSt9)+Space(Len(ST9->T9_CODBEM)-Len(ST9->T9_CODFAMI))
				cFamCom := NGSEEK('ST9',cCodCom,1,'T9_CODFAMI',cFilSt9)+Space(Len(ST9->T9_CODBEM)-Len(ST9->T9_CODFAMI))
				cLocPai := ""
				cLocCom := (cTRBF)->FLOCALI
				nPosF   := 0

				//Se bem bem pai deste componente também é filho de outro componente na estrutura,
				//busca sua localização
				nRecNo := (cTRBF)->(RecNo())
				If dbSeek(cCodPai)
					cLocPai := (cTRBF)->FLOCALI
					cPaiSup := (cTRBF)->FCODBEM
				EndIf
				dbSelectArea(cTRBF)
				dbGoTo(nRecNo)

				//com os dados acima, busca a posicao correspondente do bem na estrutura padrao
				If Len(aESTFAM) > 0
					nPosF := aSCAN(aESTFAM,{|x| cFamCom+cLocCom = x[1]+x[2] .And.;
					cFamPai+cLocPai = x[6]+x[7]})
				EndIf

				//caso tenha encontrado a posicao na estrutura padrao
				If nPosF > 0
					lREPASS := (aESTFAM[nPosF,3] != "N")
				ElseIf !Empty(cPaiSup)
					While !lEnd
						//se nao encontrou, busca estruturas padrao dos pais imediatos, ate o topo da estrutura
						cTpMod2 := If(lFrota,NGSEEK('ST9',cCodPai,1,'T9_TIPMOD',cFilSt9),Nil)
						cFamPa2 := NGSEEK('ST9',cCodPai,1,'T9_CODFAMI',cFilSt9)
						aESTFAM2 := NGCOMPEST(cFamPa2,"F",.T.,.F.,.T.,cFilNov,Nil,cTpMod2)

						//sobe um nivel na estrutura
						cCodCom := cCodPai
						cCodPai := cPaiSup

						//executa busca na nova estrutura padrao
						nPosF := aSCAN(aESTFAM2,{|x| cFamCom+cLocCom = x[1]+x[2] .And.;
						cFamPai+cLocPai = x[6]+x[7]})
						If nPosF > 0
							lREPASS := (aESTFAM2[nPosF,3] != "N")
							lEnd := .T.
						Else
							//Se bem bem pai deste componente também é filho de outro componente na estrutura:
							nRecNo := (cTRBF)->(RecNo())
							If dbSeek(cCodPai)
								cCodPai := cPaiSup
								cPaiSup := (cTRBF)->FCODBEM
							Else
								lEnd := .T.
							EndIf
							dbSelectArea(cTRBF)
							dbGoTo(nRecNo)
						EndIf
					EndDo
				EndIf

				If lREPASS
					Aadd(aCOMPDAD,{(cTRBF)->fcompon,(cTRBF)->fdtmovi,(cTRBF)->fhoraen,;
					(cTRBF)->fdtsaid,(cTRBF)->fhorasa,(cTRBF)->flocali,(cTRBF)->fcodbem})
				EndIf

			EndIf
			DbselectArea(cTRBF)
			dbSkip()
		End

		//Fecha e deleta o arquivo temporario e indices fisicamente
		If !lTemEst
			oTpTbTRBF:Delete()
		EndIf
	EndIf

	//Fecha e deleta o arquivo temporario e indices fisicamente
	If !lTemEst
		oTableSTC:Delete()
	EndIf

	RestArea(aArea)

Return aCOMPDAD

/*/
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGRETSTCDT ³ Autor ³ Felipe N. Welter      ³ Data ³ 27/07/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna os componentes da estrutura em determinado momento,  ³±±
±±³          ³com base nas movimentacoes dos bens.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³cBEMV   - Codigo do Bem                             -Obrigat.³±±
±±³          ³dDATAV  - Data                                      -Obrigat.³±±
±±³          ³cHORAV  - Hora                                      -Obrigat.³±±
±±³          ³lCCUST  - Valida se permite mov. C.Custo      -Nao Obr. D:.F.³±±
±±³          ³cFilNov - Codigo da filial para acesso          -Nao Obrigat.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³aESTRUT - Array com os dados:                                ³±±
±±³          ³ [1] - componente                                            ³±±
±±³          ³ [2] - data entrada                                          ³±±
±±³          ³ [3] - hora entrada                                          ³±±
±±³          ³ [4] - data saida                                            ³±±
±±³          ³ [5] - hora saida                                            ³±±
±±³          ³ [6] - localizacao                                           ³±±
±±³          ³ [7] - bem pai                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGRETSTCDT(cBEMV,dDATAV,cHORAV,lCCUST,cFilNov)

	Local cCOMP, nRec1, aArea := GetArea()
	Local cFilSTZ := NGTROCAFILI("STZ",cFilNov)
	Local cFilST6 := NGTROCAFILI("ST6",cFilNov)
	Local cFilST9 := NGTROCAFILI("ST9",cFilNov)

	If Type("aESTRUT") <> "A"
		Private aESTRUT := {}
	EndIf

	Default lCCUST := .F.

	dbSelectArea("STZ")
	dbSetOrder(04)
	dbSeek(cFilSTZ+cBEMV)
	While !Eof() .And. STZ->TZ_FILIAL == cFilSTZ .And. STZ->TZ_BEMPAI == cBEMV

		cCOMP := STZ->TZ_CODBEM
		nRec1 := Recno()

		//Verifica se o bem esta na estrutura em dDATAV e cHORAV
		lOK := .F.
		If Empty(STZ->TZ_DATASAI)
			If STZ->TZ_DATAMOV <= dDATAV
				If STZ->TZ_DATAMOV < dDATAV
					lOK := .T.
				Else
					If cHORAV >= STZ->TZ_HORAENT
						lOK := .T.
					EndIf
				EndIf
			EndIf
		Else
			If STZ->TZ_DATAMOV <= dDATAV .And. STZ->TZ_DATASAI >= dDATAV
				If STZ->TZ_DATAMOV == dDATAV .And. STZ->TZ_DATASAI == dDATAV
					If STZ->TZ_HORAENT <= cHORAV .And. STZ->TZ_HORASAI >= cHORAV
						lOK := .T.
					EndIf
				ElseIf STZ->TZ_DATAMOV < dDATAV .And. STZ->TZ_DATASAI > dDATAV
					lOK := .T.
				ElseIf STZ->TZ_DATAMOV == dDATAV
					If STZ->TZ_HORAENT <= cHORAV
						lOK := .T.
					EndIf
				ElseIf STZ->TZ_DATASAI == dDATAV
					If STZ->TZ_HORASAI >= cHORAV
						lOK := .T.
					EndIf
				EndIf
			EndIf
		EndIf

		//Verifica se o bem permite Movimentar C.Custo
		If lOK .And. lCCUST
			lOK := .F.
			dbSelectArea("ST9")
			dbSetOrder(01)
			dbSeek(cFilST9+cCOMP)
			If ST9->T9_MOVIBEM == "S"
				dbSelectArea("ST6")
				dbSetOrder(01)
				dbSeek(cFilST6+ST9->T9_CODFAMI)
				If ST6->T6_MOVIBEM == "S"
					lOK := .T.
				EndIf
			EndIf
		EndIf

		If lOK
			//Adiciona componente no array retorno
			Aadd(aESTRUT,{STZ->TZ_CODBEM,STZ->TZ_DATAMOV,STZ->TZ_HORAENT,;
			STZ->TZ_DATASAI,STZ->TZ_HORASAI,STZ->TZ_LOCALIZ,STZ->TZ_BEMPAI})
			//Verifica se o componente possui estrutura
			dbSelectArea("STZ")
			dbSetOrder(04)
			If dbSeek(cFilSTZ+cCOMP)
				NGRETSTCDT(cCOMP,dDATAV,cHORAV,lCCUST,cFilNov)
			EndIf
		EndIf

		dbSelectArea("STZ")
		dbGoTo(nRec1)
		dbSkip()

	EndDo

	RestArea(aArea)

Return aESTRUT

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGESTZCOMPZ ³ Autor ³ In cio Luiz Kolling ³ Data ³21/11/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inclui no arquivo de trabalho os itens filhos              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ NGCOMPPCONT                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function NGESTZCOMPZ(cVBEM)

	Local nREC1

	While !Eof() .And. STZ->TZ_FILIAL == cFilStz .And.;
	STZ->TZ_BEMPAI = cVBEM

		nREC1  := RECNO()
		cCOMP1 := STZ->TZ_CODBEM
		lINCAR2 := .F.
		If Empty(stz->tz_datasai)
			If stz->tz_datamov <= dDATAPAR
				If stz->tz_datamov < dDATAPAR
					lINCAR2 := .T.
				Else
					If cHORAPAR >= stz->tz_horaent
						lINCAR2 := .T.
					Endif
				Endif
			Endif
		Else
			/*
			If stz->tz_datamov >= dDATAPAR .And. stz->tz_datasai <= dDATAPAR
			If stz->tz_datamov = dDATAPAR .And. stz->tz_datasai = dDATAPAR
			If stz->tz_horaent >= cHORAPAR .And. stz->tz_horasai <= cHORAPAR
			lINCAR2 := .T.
			Endif
			ElseIf stz->tz_datamov = dDATAPAR .And. stz->tz_datasai <= dDATAPAR
			If stz->tz_horaent >= cHORAPAR .And. stz->tz_horasai <= cHORAPAR
			lINCAR2 := .T.
			Endif


			If cHORAPAR <= stz->tz_horasai .And. cHORAPAR <= stz->tz_horasai
			lINCAR2 := .T.
			Endif
			Endif
			/*/
			If stz->tz_datamov <= dDATAPAR .And.  stz->tz_datasai >= dDATAPAR
				If stz->tz_datamov = dDATAPAR .And. stz->tz_datasai = dDATAPAR
					If stz->tz_horaent <= cHORAPAR .And. stz->tz_horasai >= cHORAPAR
						lINCAR2 := .T.
					Endif
				ElseIf stz->tz_datamov < dDATAPAR  .And. stz->tz_datasai > dDATAPAR
					lINCAR2 := .T.
				ElseIf stz->tz_datamov = dDATAPAR
					If stz->tz_horaent <= cHORAPAR
						lINCAR2 := .T.
					EndIf
				ElseIf stz->tz_datasai = dDATAPAR
					If stz->tz_horasai >= cHORAPAR
						lINCAR2 := .T.
					EndIf
				EndIf
			EndIf
		EndIf

		If lINCAR2
			(cTRBS)->(DbAppend())
			(cTRBS)->TCODBEM := stz->tz_bempai
			(cTRBS)->TCOMPON := stz->tz_codbem
			(cTRBS)->TDTMOVI := stz->tz_datamov
			(cTRBS)->TTIPOMO := stz->tz_tipomov
			(cTRBS)->TDTSAID := stz->tz_datasai
			(cTRBS)->TTIPOCO := stz->tz_temcont
			(cTRBS)->THORAEN := stz->tz_horaent
			(cTRBS)->THORASA := stz->tz_horasai
			(cTRBS)->TTIPOBE := stz->tz_temcpai
			(cTRBS)->TLOCALI := stz->tz_localiz
			(cTRBS)->REPASSA := 'S'
			DbselectArea("STZ")
			If Dbseek(cFilStz+cCOMP1)
				NGESTZCOMPZ(cCOMP1)
			Endif
		Endif
		Dbgoto(nREC1)
		Dbskip()
	End

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGESTUTRBS³ Autor ³ In cio Luiz Kolling   ³ Data ³21/11/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consistencia do STZ - para atualizar contador/acumulado     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³.T.,.F.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³NGCOMPPCONT                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function NGESTUTRBS(dDATSAID,dDATMOVI,cHORENT,cHORSAI)

	Local lRETOR := .F.

	If Empty(dDATSAID)
		lRETOR := .T.
	Else
		If dDATSAID >= dDATAPAR
			If dDATSAID > dDATAPAR
				lRETOR := .T.
			Else
				If cHORSAI >= cHORAPAR
					lRETOR := .T.
				Endif
			Endif
		Endif
	Endif

Return lRETOR

//----------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} NGINREGEST
Faz o processo de inclusão de um registro de histórico de um componente (Pai ou Imediato), igual a data e hora
de entrada na estrutura.
@type function

@author Elisangela Costa
@since 17/03/2004

@sample NGINREGEST( "CodBem", 28/05/1996, "12:00", 1, 1000, 1000, 0 )
@sample NGINREGEST( ,,,,,,,{ "CodBem", 28/05/1996, "12:00", 1, 1000, 1000, 0 } )

@param cCODBEM     , Caracter, Código do bem
@param dDATAENT    , Data    , Data de entrada na estrutura
@param cHORAENT    , Caracter, Hora de entrada na estrutura
@param nTIPOCONT   , Númerico, Tipo de contador
@param nPOSENTR    , Númerico, Posicao do contador do bem pai ou dele mesmo.
@param nACUMENT    , Númerico, Contador acumulado do componente
@param nVIRADA     , Númerico, Numero de virada do contador.
@param [aEquipment], Array   , Lista de bens para processamento em lote. Quando este parametro
@param [lCalcHist] , boolean , Indica se realizará o processo de recalculo do histórico
for utilizado, dispensa o preenchimento dos demais anteriores.
							  [1] - Código do Bem.
							  [2] - Data de entrada na estrutura.
							  [3] - Tipo de contador.
							  [4] - Posicao do contador do bem pai ou dele mesmo.
							  [5] - Contador acumulado do componente
							  [6] - Numero de virada do contador.
@return .T.
/*/
//----------------------------------------------------------------------------------------------------------
Function NGINREGEST( cCODBEM, dDATAENT, cHORAENT, nTIPOCONT, nPOSENTR, nACUMENT, nVIRADA, aEquipment, lCalcHist )

	Local nX        := 0
	Local aRecalHis := {}
	Local vARQHIS   := {}
	Local aAreaSTZ	:= STZ->(GetArea())
	Local aMntInfo := GetApoInfo( 'MNTUTIL_CONTADOR.PRW' )
	Local cMntCAtu  := DtoS( aMntInfo[4] ) + aMntInfo[5]

	Default aEquipment := { { cCODBEM, dDATAENT, cHORAENT, nTIPOCONT, nPOSENTR, nACUMENT, nVIRADA } }

	Default lCalcHist  := .T.

	For nX:= 1 to Len( aEquipment )

		lULTIREG := .F. //Ultimo registro a ser incluido
		lPRIMEIR := .F. //Primeiro registro ser incluido

		vARQHIS := IIf( aEquipment[nX, 4] == 1,{'ST9','st9->t9_dtultac','st9->t9_poscont','st9->t9_contacu',;
											'st9->t9_vardia','st9->t9_viradas','st9->t9_limicon',;
											'STP','stp->tp_filial','stp->tp_codbem','stp->tp_poscont',;
											'stp->tp_dtleitu','stp->tp_hora','stp->tp_vardia',;
											'stp->tp_acumcon','stp->tp_viracon'},;
											{'TPE','tpe->tpe_dtulta','tpe->tpe_poscon','tpe->tpe_contac',;
											'tpe->tpe_vardia','tpe->tpe_virada','tpe->tpe_limico',;
											'TPP','tpp->tpp_filial','tpp->tpp_codbem','tpp->tpp_poscon',;
											'tpp->tpp_dtleit','tpp->tpp_hora','tpp->tpp_vardia',;
											'tpp->tpp_acumco','tpp->tpp_viraco'})

		DbselectArea( vARQHIS[8] )
		DbSetOrder( 5 ) //FILIAL + CODBEM + DTLEITU + HORA
		If !DbSeek( xFilial( vARQHIS[8] ) + aEquipment[nX, 1] )

			//Grava Historico do contador
			NGGRAVAHIS( aEquipment[nX, 1], aEquipment[nX, 5], 1, aEquipment[nX, 2], aEquipment[nX, 6], aEquipment[nX, 7], aEquipment[nX, 3], aEquipment[nX, 4], 'C' )

			//Atualiza cadastro do bem
			DbselectArea(vARQHIS[1])
			DbSetOrder(01)
			If DbSeek( xFilial( vARQHIS[1] ) + aEquipment[nX, 1] )
				RecLock(vARQHIS[1],.F.)
				&( vARQHIS[2] ) := aEquipment[nX, 2] //Data de Ultimo Acomp. do bem
				&( vARQHIS[3] ) := aEquipment[nX, 5] //Contador do bem
				&( vARQHIS[5] ) := 1        //Variacao dia do bem
				MsUnLock(vARQHIS[1])
			EndIf
			Return .T.
		EndIf

		DbselectArea(vARQHIS[8])
		If dbSeek( xFilial( vARQHIS[8] ) + aEquipment[nX, 1] + DtoS( aEquipment[nX, 2] ) + aEquipment[nX, 3] )
			Return .T.
		Else
			dbSeek( xFilial( vARQHIS[8] ) + aEquipment[nX, 1] + DtoS( aEquipment[nX, 2] ) + aEquipment[nX, 3], .T. )
			If Eof()
				Dbskip(-1)
				lULTIREG := .T.
			Else
				If &( vARQHIS[9] ) == xFILIAL( vARQHIS[8] ) .And. &( vARQHIS[10] ) <> aEquipment[nX, 1]
					Dbskip(-1)
					lULTIREG := .T.
				EndIf
			EndIf

			If &( vARQHIS[9] ) == xFilial( vARQHIS[8] ) .And. &( vARQHIS[10] ) == aEquipment[nX, 1]
				If &( vARQHIS[12] ) >= aEquipment[nX, 2]
					If &( vARQHIS[12] ) == aEquipment[nX, 2] .And. &( vARQHIS[13] ) > aEquipment[nX, 3]
						DbSkip(-1)

						If BoF() .Or. ( &( vARQHIS[9] ) == xFilial( vARQHIS[8] ) .And. &( vARQHIS[10]) <> aEquipment[nX, 1] )
							DbSkip()
							lPRIMEIR := .T.
						EndIf

					ElseIf &( vARQHIS[12] ) > aEquipment[nX, 2]
						DbSkip(-1)

						If BoF() .Or. ( &( vARQHIS[9] ) == xFilial( vARQHIS[8] ) .And. &( vARQHIS[10] ) <> aEquipment[nX, 1] )
							DbSkip()
							lPRIMEIR := .T.
						EndIf
					EndIf
				EndIf

				NGGRAVAHIS( aEquipment[nX, 1], aEquipment[nX, 5], 1, aEquipment[nX, 2], &( vARQHIS[15] ), &( vARQHIS[16] ), aEquipment[nX, 3], aEquipment[nX, 4], 'C' )

				dbSelectArea( vARQHIS[8] )
				dbSetOrder( 5 ) //FILIAL + CODBEM + DTLEITU + HORA
				dbSeek( xFilial( vARQHIS[8] ) + aEquipment[nX, 1] + DtoS( aEquipment[nX, 2] ) + aEquipment[nX, 3] )

				If cMntCAtu >= '2019051508:30:00'
					aAdd( aRecalHis, { aEquipment[nX, 1], (vARQHIS[8])->( Recno() ), 0, .F., &( vARQHIS[11] ), aEquipment[nX, 2], aEquipment[nX, 4], .F., .T., , , } )
				Else
					NGRECALHIS( cCODBEM, 0 , &(vARQHIS[11]), dDATAENT, nTIPOCONT, .F., .F., .T. )
				EndIf

			EndIf

		EndIf

	Next nX

	//Recalcula os registros a partir do registro incluido
	If !Empty( aRecalHis ) .And. lCalcHist
		NGRECALHIS( , , , , , , , , , , , aRecalHis )
	EndIf

	RestArea(aAreaSTZ)

Return .T.

//--------------------------------------------------------------------------------------------------
/*/{Proteus.doc} NGCONSTZ
Consiste se a data de saida ou entrada na estrutura está em um intervalo válido

@author Elisangela Costa
@since 12/05/2005
@param cBEMSTZ, string, código do bem
@param dDATALE, date, data para consistir
@param cHORALE, string, hora para consistir
@param [cTIPOSTZ], string, tipo de movimento
@param [cLOCALSTZ], string, localização
@return boolean

/*/
//------------------------------------------------------------------------------------------------
Function NGCONSTZ(cBEMSTZ,dDATALE,cHORALE,cTIPOSTZ,cLOCALSTZ)

	Local cALIOLD  := Alias()
	Local nORDOLD  := IndexOrd()

	Local dDATAENT  := Ctod('  /  /  '), cHORAENT := "  :  "  //Data e hora de entrada da movimentacao de entrada tz_tipomov = "E"
	Local cBEMPSTZ  := Space(Len(ST9->T9_CODBEM)) //Bem pai do componente
	Local dDTENTSTZ := Ctod('  /  /  ') //Data de entrada na estrutura
	Local cHORAESTZ := "  :  "          //Hora de entrada na estrutura
	Local dDTSAISTZ := Ctod('  /  /  ') //Data de saida na estrutura
	Local cHORASSTZ := "  :  "          //Hora de saida na estrutura
	Local cLOCAL1TZ := " "              //Localizacao

	Local lMENS     := .F.              //Variavel logica do controle do While
	Local lSAIDA    := .F.              //Indica se verdadeiro que e um processo de saida do componente da estrutura
	Local cInforma  := "" // mensagem para usuário

	If cTIPOSTZ = Nil
		DbselectArea("STZ")
		DbSetOrder(1)
		If DbSeek(xFilial("STZ")+cBEMSTZ+"E")

			lSAIDA := .T.
			If dDATALE <= STZ->TZ_DATAMOV
				If dDATALE = STZ->TZ_DATAMOV
					If cHORALE <= STZ->TZ_HORAENT
						lMENS     := .T.
					EndIf
				Else
					lMENS     := .T.
				EndIf
			EndIf
			dDATAENT := STZ->TZ_DATAMOV  //Data de entrada na estrutura
			cHORAENT := STZ->TZ_HORAENT  //Hora de entrada na estrutura

		EndIf

		If lMENS

			cInforma := STR0002  + chr(13)+chr(13) // //"Data/Hora de saida e menor ou igual a data/hora de entrada na estrutura."
			cInforma += STR0003 + cBEMSTZ+chr(13)  //"Bem...................: "  //"Bem....................: "
			cInforma += STR0004 + dtoc(dDATALE)+chr(13)  //  //"Data Informada..: "
			cInforma += STR0005 + Substr(cHORALE,1,5)+chr(13)  // //"Hora Informada..: "

			If !Empty( cLOCALSTZ )
				cInforma += STR0006 + cLOCALSTZ + chr(13)//"Localizacao........: "
			EndIf

			cInforma += chr(13)
			cInforma += STR0007 + STZ->TZ_BEMPAI+chr(13) // //"Bem Pai..............: "
			cInforma += STR0008 + dtoc(STZ->TZ_DATAMOV )+chr(13) // //"Data de Entrada.: "
			cInforma += STR0009 + STZ->TZ_HORAENT+chr(13) //  //"Hora de Entrada.: "
			cInforma += STR0006 +STZ->TZ_LOCALIZ // // #  //"Localizacao........:

			Help(" ",1, STR0010,, cInforma ,1,1) // "NAO CONFORMIDADE"

			Return .F.
		EndIf
	EndIf

	DbselectArea("STZ")
	DbSetOrder(2)
	If DbSeek(xFilial("STZ")+cBEMSTZ)
		While !Eof() .And. STZ->TZ_FILIAL == xFilial("STZ") .And.;
		STZ->TZ_CODBEM == cBEMSTZ .And. !lMENS

			If lSAIDA //SAIDA DA ESTRUTURA
				If STZ->TZ_TIPOMOV <> "E"

					If dDATALE >= STZ->TZ_DATAMOV .And. dDATALE <= STZ->TZ_DATASAI
						If dDATALE = STZ->TZ_DATAMOV  .And. dDATALE = STZ->TZ_DATASAI
							If cHORALE >= STZ->TZ_HORAENT .And. cHORALE <= STZ->TZ_HORASAI
								lMENS     := .T.
								cBEMPSTZ  := STZ->TZ_BEMPAI   //Bem Pai
								dDTENTSTZ := STZ->TZ_DATAMOV  //Data de entrada na estrutura
								cHORAESTZ := STZ->TZ_HORAENT  //Hora de entrada na estrutura
								dDTSAISTZ := STZ->TZ_DATASAI  //Data de saida na estrutura
								cHORASSTZ := STZ->TZ_HORASAI  //Hora de saida na estrutura
								cLOCAL1TZ := STZ->TZ_LOCALIZ  //Localizacao
							EndIf
						Else
							If dDATALE = STZ->TZ_DATAMOV  .Or. dDATALE = STZ->TZ_DATASAI
								If dDATALE = STZ->TZ_DATAMOV
									If cHORALE >= STZ->TZ_HORAENT
										lMENS     := .T.
										cBEMPSTZ  := STZ->TZ_BEMPAI   //Bem Pai
										dDTENTSTZ := STZ->TZ_DATAMOV  //Data de entrada na estrutura
										cHORAESTZ := STZ->TZ_HORAENT  //Hora de entrada na estrutura
										dDTSAISTZ := STZ->TZ_DATASAI  //Data de saida na estrutura
										cHORASSTZ := STZ->TZ_HORASAI  //Hora de saida na estrutura
										cLOCAL1TZ := STZ->TZ_LOCALIZ  //Localizacao
									EndIf
								Else
									If cHORALE <= STZ->TZ_HORASAI
										lMENS     := .T.
										cBEMPSTZ  := STZ->TZ_BEMPAI   //Bem Pai
										dDTENTSTZ := STZ->TZ_DATAMOV  //Data de entrada na estrutura
										cHORAESTZ := STZ->TZ_HORAENT  //Hora de entrada na estrutura
										dDTSAISTZ := STZ->TZ_DATASAI  //Data de saida na estrutura
										cHORASSTZ := STZ->TZ_HORASAI  //Hora de saida na estrutura
										cLOCAL1TZ := STZ->TZ_LOCALIZ  //Localizacao
									EndIf
								EndIf
							Else
								lMENS     := .T.
								cBEMPSTZ  := STZ->TZ_BEMPAI   //Bem Pai
								dDTENTSTZ := STZ->TZ_DATAMOV  //Data de entrada na estrutura
								cHORAESTZ := STZ->TZ_HORAENT  //Hora de entrada na estrutura
								dDTSAISTZ := STZ->TZ_DATASAI  //Data de saida na estrutura
								cHORASSTZ := STZ->TZ_HORASAI  //Hora de saida na estrutura
								cLOCAL1TZ := STZ->TZ_LOCALIZ  //Localizacao
							EndIf
						EndIf
					EndIf

					If !lMENS
						//A data de saida abrange todo um movimento ja existente
						If dDATAENT <= STZ->TZ_DATAMOV
							If dDATAENT = STZ->TZ_DATAMOV
								If cHORAENT <= STZ->TZ_HORAENT
									If dDATALE >= STZ->TZ_DATASAI
										If dDATALE = STZ->TZ_DATASAI
											If cHORALE >= STZ->TZ_HORASAI
												lMENS     := .T.
												cBEMPSTZ  := STZ->TZ_BEMPAI   //Bem Pai
												dDTENTSTZ := STZ->TZ_DATAMOV  //Data de entrada na estrutura
												cHORAESTZ := STZ->TZ_HORAENT  //Hora de entrada na estrutura
												dDTSAISTZ := STZ->TZ_DATASAI  //Data de saida na estrutura
												cHORASSTZ := STZ->TZ_HORASAI  //Hora de saida na estrutura
												cLOCAL1TZ := STZ->TZ_LOCALIZ  //Localizacao
											EndIf
										Else
											lMENS     := .T.
											cBEMPSTZ  := STZ->TZ_BEMPAI   //Bem Pai
											dDTENTSTZ := STZ->TZ_DATAMOV  //Data de entrada na estrutura
											cHORAESTZ := STZ->TZ_HORAENT  //Hora de entrada na estrutura
											dDTSAISTZ := STZ->TZ_DATASAI  //Data de saida na estrutura
											cHORASSTZ := STZ->TZ_HORASAI  //Hora de saida na estrutura
											cLOCAL1TZ := STZ->TZ_LOCALIZ  //Localizacao
										EndIf
									EndIf
								EndIf
							Else
								If dDATALE >= STZ->TZ_DATASAI
									If dDATALE = STZ->TZ_DATASAI
										If cHORALE >= STZ->TZ_HORASAI
											lMENS     := .T.
											cBEMPSTZ  := STZ->TZ_BEMPAI   //Bem Pai
											dDTENTSTZ := STZ->TZ_DATAMOV  //Data de entrada na estrutura
											cHORAESTZ := STZ->TZ_HORAENT  //Hora de entrada na estrutura
											dDTSAISTZ := STZ->TZ_DATASAI  //Data de saida na estrutura
											cHORASSTZ := STZ->TZ_HORASAI  //Hora de saida na estrutura
											cLOCAL1TZ := STZ->TZ_LOCALIZ  //Localizacao
										EndIf
									Else
										lMENS     := .T.
										cBEMPSTZ  := STZ->TZ_BEMPAI   //Bem Pai
										dDTENTSTZ := STZ->TZ_DATAMOV  //Data de entrada na estrutura
										cHORAESTZ := STZ->TZ_HORAENT  //Hora de entrada na estrutura
										dDTSAISTZ := STZ->TZ_DATASAI  //Data de saida na estrutura
										cHORASSTZ := STZ->TZ_HORASAI  //Hora de saida na estrutura
										cLOCAL1TZ := STZ->TZ_LOCALIZ  //Localizacao
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			Else      //ENTRADA NA ESTRUTURA

				If dDATALE >= STZ->TZ_DATAMOV .And. dDATALE <= STZ->TZ_DATASAI
					If dDATALE = STZ->TZ_DATAMOV  .And. dDATALE = STZ->TZ_DATASAI
						If cHORALE >= STZ->TZ_HORAENT .And. cHORALE <= STZ->TZ_HORASAI
							lMENS     := .T.
							cBEMPSTZ  := STZ->TZ_BEMPAI   //Bem Pai
							dDTENTSTZ := STZ->TZ_DATAMOV  //Data de entrada na estrutura
							cHORAESTZ := STZ->TZ_HORAENT  //Hora de entrada na estrutura
							dDTSAISTZ := STZ->TZ_DATASAI  //Data de saida na estrutura
							cHORASSTZ := STZ->TZ_HORASAI  //Hora de saida na estrutura
							cLOCAL1TZ := STZ->TZ_LOCALIZ  //Localizacao
						EndIf
					Else
						If dDATALE = STZ->TZ_DATAMOV  .Or. dDATALE = STZ->TZ_DATASAI
							If dDATALE = STZ->TZ_DATAMOV
								If cHORALE >= STZ->TZ_HORAENT
									lMENS     := .T.
									cBEMPSTZ  := STZ->TZ_BEMPAI   //Bem Pai
									dDTENTSTZ := STZ->TZ_DATAMOV  //Data de entrada na estrutura
									cHORAESTZ := STZ->TZ_HORAENT  //Hora de entrada na estrutura
									dDTSAISTZ := STZ->TZ_DATASAI  //Data de saida na estrutura
									cHORASSTZ := STZ->TZ_HORASAI  //Hora de saida na estrutura
									cLOCAL1TZ := STZ->TZ_LOCALIZ  //Localizacao
								EndIf
							Else
								If cHORALE <= STZ->TZ_HORASAI
									lMENS     := .T.
									cBEMPSTZ  := STZ->TZ_BEMPAI   //Bem Pai
									dDTENTSTZ := STZ->TZ_DATAMOV  //Data de entrada na estrutura
									cHORAESTZ := STZ->TZ_HORAENT  //Hora de entrada na estrutura
									dDTSAISTZ := STZ->TZ_DATASAI  //Data de saida na estrutura
									cHORASSTZ := STZ->TZ_HORASAI  //Hora de saida na estrutura
									cLOCAL1TZ := STZ->TZ_LOCALIZ  //Localizacao
								EndIf
							EndIf
						Else
							lMENS     := .T.
							cBEMPSTZ  := STZ->TZ_BEMPAI   //Bem Pai
							dDTENTSTZ := STZ->TZ_DATAMOV  //Data de entrada na estrutura
							cHORAESTZ := STZ->TZ_HORAENT  //Hora de entrada na estrutura
							dDTSAISTZ := STZ->TZ_DATASAI  //Data de saida na estrutura
							cHORASSTZ := STZ->TZ_HORASAI  //Hora de saida na estrutura
							cLOCAL1TZ := STZ->TZ_LOCALIZ  //Localizacao
						EndIf
					EndIf
				ElseIf DTOS(dDATALE) + cHORALE <= DTOS(STZ->TZ_DATAMOV) + STZ->TZ_HORAENT

					lMENS     := .T.
					cBEMPSTZ  := STZ->TZ_BEMPAI   //Bem Pai
					dDTENTSTZ := STZ->TZ_DATAMOV  //Data de entrada na estrutura
					cHORAESTZ := STZ->TZ_HORAENT  //Hora de entrada na estrutura
					dDTSAISTZ := STZ->TZ_DATASAI  //Data de saida na estrutura
					cHORASSTZ := STZ->TZ_HORASAI  //Hora de saida na estrutura
					cLOCAL1TZ := STZ->TZ_LOCALIZ  //Localizacao

				EndIf
			EndIf
			DbselectArea("STZ")
			DbSkip()
		End
		If lMENS
			If lSAIDA

				cInforma := STR0011  + chr(13)+chr(13)// //"Ja existe movimentacao do bem no intervalo de Data/Hora informada."
				cInforma += STR0003 + cBEMSTZ+chr(13)// //"Bem....................: "
				cInforma += STR0008 + dtoc(dDATAENT)+chr(13) //  //"Data de Entrada.: "
				cInforma += STR0009 + Substr(cHORAENT,1,5)+chr(13)+chr(13)//  //"Hora de Entrada.: "
				cInforma += STR0004 + dtoc(dDATALE)+chr(13) //  //"Data Informada..: "
				cInforma += STR0005 + Substr(cHORALE,1,5)+chr(13) //  //"Hora Informada..: "

				If !Empty( cLOCALSTZ )
					cInforma += STR0006 + cLOCALSTZ +chr(13) // //"Localizacao........: "
				EndIf

				cInforma += chr(13)
				cInforma += STR0012 + chr(13)+chr(13) // //"Movimentacao do bem ja existente: "
				cInforma += STR0007 + cBEMPSTZ+chr(13) // //"Bem Pai..............: "
				cInforma += STR0008 + dtoc(dDTENTSTZ)+chr(13) // //"Data de Entrada.: "
				cInforma += STR0009 + cHORAESTZ+chr(13) // //"Hora de Entrada.: "
				cInforma += STR0013 + dtoc(dDTSAISTZ)+chr(13)// //"Data de Saida....: "
				cInforma += STR0014 + cHORASSTZ+chr(13) // //"Hora de saida.....: "
				cInforma += STR0006 + cLOCAL1TZ // #  //"Localizacao........: "

				Help(" ",1, STR0010,, cInforma ,1,1) // "NAO CONFORMIDADE"

				Return .F.
			Else

				cInforma := STR0011 +chr(13)+chr(13) // //"Ja existe movimentacao do bem no intervalo de Data/Hora informada."
				cInforma += STR0003 + cBEMSTZ+chr(13)// //"Bem....................: "
				cInforma += STR0004 + dtoc(dDATALE)+chr(13)// //"Data Informada..: "
				cInforma += STR0005 + Substr(cHORALE,1,5)+chr(13) //   //"Hora Informada..: "

				If !Empty( cLOCALSTZ )
					cInforma += STR0015 + cLOCALSTZ+chr(13) // //"Localiz. Infor......: "
				EndIf

				cInforma += chr(13)
				cInforma += STR0012 + chr(13)+chr(13) //  //"Movimentacao do bem ja existente: "
				cInforma += STR0007 + cBEMPSTZ+chr(13) //      //"Bem Pai..............: "
				cInforma += STR0008 + dtoc(dDTENTSTZ)+chr(13) // //"Data de Entrada.: "
				cInforma += STR0009 + cHORAESTZ+chr(13)// //"Hora de Entrada.: "
				cInforma += STR0013 + dtoc(dDTSAISTZ)+chr(13)//  //"Data de Saida....: "
				cInforma += STR0014 + cHORASSTZ+chr(13) // //"Hora de saida.....: "
				cInforma += STR0006 + cLOCAL1TZ // # //"Localizacao........:

				Help(" ",1, STR0010,, cInforma ,1,1) // "NAO CONFORMIDADE"

				Return .F.
			EndIf
		EndIf
	EndIf
	DbselectArea(cALIOLD)
	DbSetOrder(nORDOLD)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGESTRU   ³ Autor ³ Paulo Pego            ³ Data ³ 20/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna um array contendo Codigo Bem Existentes em uma     ³±±
±±³          ³ Estrutura                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCODBEM - Codigo do Bem                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMNT - Planejamento de Manutencao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DT.ALTERAC³ANLISTA/PROG.³ MOTIVO                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³             ³                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGESTRU(cCODBEM)

	Local aESTRU := {}, aRET := {},nREG, i

	DbSelectArea("STC")
	dbSetOrder(1)
	DbSeek(xFilial("STC") + cCODBEM)
	Do While !Eof() .And. STC->TC_FILIAL == xFilial("STC") .And.;
	STC->TC_CODBEM == cCODBEM

		nREG := Recno()
		If STC->TC_TIPOEST = 'B'
			AAdd(aESTRU, STC->TC_COMPONE)

			aRET := NGESTRU(STC->TC_COMPONE)

			For i := 1 To Len(aRET)
				AAdd(aESTRU, aRET[i])
			Next
		EndIf

		DbGoto(nREG)
		DbSkip()
	EndDo

Return aESTRU

//-------------------------------------------------------------------
/*/{Protheus.doc} NGCOMPEST
Cria um vetor com os componentes da estrutura  

@author Inácio Luiz Kolling
@since  23/06/2002
@param cCode, string , código do bem ou da família
@param cTIPOE, string, Tipo de estrutura B=Bem; F=Família
@param [lIPAI], boolean, Considera o bem pai no retorno
@param [lREGU], boolean, Mostrar processamento
@param [lARRAY], boolean, Retorna uma array
@param [cFilNov], string, Codigo da filial para acesso 
@param [cEmpNov], string, Codigo de empresa para acesso
@param [cTIPMOD], string, tipo modelo
@return array
/*/
//-------------------------------------------------------------------
Function NGCOMPEST(cCode,cTIPOE,lIPAI,lREGU,lARRAY,cFilNov,cEmpNov,cTIPMOD)

	Local lPROCREG := If (lREGU = Nil,.F.,lREGU)
	Local cALIASOL := ALIAS()
	Local nORDEROL := IndexOrd()
	Local lTipMod  := lRel12133 .Or. NGVERUTFR()
	Local lAchou   := .F.
	Local nIndSTC
	Local cModSTC  := ''
	Local cVBEM    := Padr( cCode, TamSx3('TC_CODBEM')[1] )

	Private aESTRU := {}
	Private lPROCARR := If (lARRAY = Nil,.F.,lARRAY)
	Private cFilStc  := NGTROCAFILI("STC",cFilNov,cEmpNov)

	Default cTIPMOD := ""

	If cEmpNov <> Nil
		aAreaSTC := STC->(GetArea())
		cEmpInfo := SM0->M0_CODIGO
		cFilInfo := cFilAnt
		NGPrepTBL({{"STC"}},cEmpNov,cFilNov)
	EndIf

	nIndSTC := IIf( lTipMod .And. cTIPOE == 'F', NGRETORDEM("STC", "TC_FILIAL+TC_CODBEM+TC_TIPMOD+TC_COMPONE+TC_TIPOEST+TC_LOCALIZ+TC_SEQRELA", .T.), 1 )

	dbSelectArea("STC")
	dbSetOrder(nIndSTC)

	cModSTC := cTIPMOD

	If lRel12133 .And. cTIPOE == 'F'
		If dbSeek(cFilStc+cVBEM+cTIPMOD) .Or. dbSeek( cFilStc + cVBEM + Padr( '*', Len( STC->TC_TIPMOD ) ) )
			cModSTC := STC->TC_TIPMOD
		EndIf
	Else
		dbSeek(cFilStc+cVBEM+cTIPMOD,.T.)
	EndIf

	While !Eof() .And. STC->TC_FILIAL == cFilSTC .And. STC->TC_CODBEM == cVBEM .And. If(lTipMod .And. cTIPOE == 'F',STC->TC_TIPMOD == cModSTC,.T.)
		If (lAchou := (STC->TC_TIPOEST = cTIPOE))
			Exit
		EndIf
		STC->(dbSkip())
	EndDo

	If lAchou
		If lIPAI <> Nil .And. lIPAI
			If lPROCARR
				AAdd(aESTRU,{cVBEM,stc->tc_localiz,stc->tc_manuati,'',stc->tc_seqsup,'',''})
			Else
				AAdd(aESTRU,cVBEM)
			Endif
		EndIf
		cPROCEST := If(lPROCREG, Processa({ |lEnd| NGCOMPROC(cVBEM,cTIPOE,lIPAI,lPROCREG,cModSTC) },STR0016),;
		NGCOMPROC(cVBEM,cTIPOE,lIPAI,lPROCREG,cModSTC))
	EndIf

	If cEmpNov <> Nil
		NGPrepTBL({{"STC"}},cEmpInfo,cFilInfo)
		RestArea(aAreaSTC)
	EndIf

	If !Empty(cALIASOL)
		DbSelectArea(cALIASOL)
	Endif
	If !Empty(nORDEROL)
		DbSetOrder(nORDEROL)
	Endif
Return aESTRU

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGCOMPROC   ³ Autor ³In cio Luiz Kolling  ³ Data ³23/06/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta vetor                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cVBEM  - Codigo do bem                    - obrig.         ³±±
±±³          ³ cTIPOE - Tipo de estrutura (Bem/Familia)  - obrig.         ³±±
±±³          ³ lIPAI  - Considera o bem pai no retorno   - N obrig D .F.  ³±±
±±³          ³ lREGUP - Mostrar processamento (.T.,.F.)  - N obrig D .F.  ³±±
±±³          ³ cTIPMOD- Tipo Modelo, obrg. quando tipo familia  - N obrig ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGCOMPROC(cVBEM,cTIPOE,lIPAI,lREGUP,cTIPMOD)
	Local aAreaSTC, aArea := GetArea()
	Local lTipMod := lRel12133 .Or. NGVERUTFR()
	Local lAchou := .F.

	nREGPROC := If (lREGUP,ProcRegua(Reccount()),0)

	//quando por bem: busca por seus componentes e adiciona no array
	//quando por familia: encontra familia+tipmod para seqsup vazio (pai da estrutura padrao)
	If lTipMod .And. cTIPOE == 'F'
		dbSelectArea("STC")
		dbSetOrder(5)
	Else
		dbSelectArea("STC")
		dbSetOrder(1)
	EndIf

	lAchou := .F.
	dbSeek(cFilStc+cVBEM+cTIPMOD,.T.)
	While !Eof() .And. STC->TC_FILIAL == cFilSTC .And. STC->TC_CODBEM == cVBEM .And. If(lTipMod .And. cTIPOE == 'F',STC->TC_TIPMOD == cTIPMOD,.T.)
		If (lAchou := (STC->TC_TIPOEST = cTIPOE))
			Exit
		EndIf
		STC->(dbSkip())
	EndDo

	If lTipMod .And. cTIPOE == 'F'
		While !Eof() .And. cFilSTC == STC->TC_FILIAL .And. STC->TC_CODBEM == cVBEM .And.;
		STC->TC_TIPMOD == cTIPMOD

			nINCPROC := If (lREGUP,IncProc(),0)
			aAreaSTC := STC->(GetArea())
			cCOMP    := stc->tc_compone
			cLOCA    := stc->tc_localiz
			If STC->TC_TIPOEST = cTIPOE .And. Empty(STC->TC_SEQSUP)
				If lPROCARR
					AAdd(aESTRU,{cCOMP,cLOCA,stc->tc_manuati,stc->tc_seqrela,stc->tc_seqsup,cVBEM,''})
				Else
					AAdd(aESTRU,cCOMP)
				Endif

				dbSetOrder(07)
				cSeq := STC->TC_SEQRELA
				If dbSeek(cFilStc+cSeq)
					NGCOMPFIL(cCOMP,cTIPOE,cSeq,cLOCA)
				EndIf
			EndIf

			dbSelectArea("STC")
			RestArea(aAreaSTC)
			dbSkip()
		End
	Else
		While !Eof() .and. stc->tc_filial == cFilStc .And.;
		stc->tc_codbem == cVBEM

			nINCPROC := If (lREGUP,IncProc(),0)
			aAreaSTC := STC->(GetArea())
			nRec1    := Recno()
			cCOMP    := stc->tc_compone
			cLOCA    := stc->tc_localiz
			If STC->TC_TIPOEST = cTIPOE
				If lPROCARR
					AAdd(aESTRU,{cCOMP,cLOCA,stc->tc_manuati,stc->tc_seqrela,stc->tc_seqsup,cVBEM,''})
				Else
					AAdd(aESTRU,cCOMP)
				Endif
				If DbSeek(cFilStc+cCOMP)
					NGCOMPFIL(cCOMP,cTIPOE,Nil,cLOCA)
				EndIf
			EndIf

			dbSelectArea("STC")
			RestArea(aAreaSTC)
			dbSkip()
		End
	EndIf
	RestArea(aArea)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGCOMPFIL   ³ Autor ³In cio Luiz Kolling  ³ Data ³23/06/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inclui os elementos filhos no vetor                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³NGCOMPROC                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGCOMPFIL(cVCOMP,cESTIP,cSEQSUP,cLOCA)
	Local nX := 1
	Local aVerFil := {}
	Local aAreaTmp1, aAreaTmp2
	Local aAreaSTC, aArea := GetArea()
	Local lGFrota   := NGVERUTFR()

	If lGFrota .And. cESTIP == 'F'
		dbSetOrder(07)
		dbSeek(xFilial("STC")+cSEQSUP)
		While !Eof() .and. stc->tc_filial == cFilStc .And. stc->tc_seqsup == cSEQSUP
			aAreaSTC := STC->(GetArea())
			aAdd(aVerFil,STC->TC_SEQRELA)
			If STC->TC_TIPOEST = cESTIP
				If lPROCARR
					AAdd(aESTRU,{stc->tc_compone,stc->tc_localiz,stc->tc_manuati,stc->tc_seqrela,stc->tc_seqsup,cVCOMP,cLOCA})
				Else
					AAdd(aESTRU,stc->tc_compone)
				Endif
				aAreaTmp1 := STC->(GetArea())
				While nX <= Len(aVerFil)
					DbSelectArea("STC")
					If dbSeek(cFilStc+aVerFil[nX])
						aAreaTmp2 := STC->(GetArea())
						While !Eof() .and. stc->tc_filial == cFilStc .And. stc->tc_seqsup == aVerFil[nX]
							If STC->TC_TIPOEST = cESTIP
								aAdd(aVerFil,STC->TC_SEQRELA)

								If lPROCARR
									AAdd(aESTRU,{stc->tc_compone,stc->tc_localiz,stc->tc_manuati,stc->tc_seqrela,stc->tc_seqsup,cVCOMP,cLOCA})
								Else
									AAdd(aESTRU,stc->tc_compone)
								Endif
							Endif
							dbSelectArea("STC")
							dbSkip()
						End
						RestArea(aAreaTmp2)
					EndIf
					nX++
				End
				RestArea(aAreaTmp1)
			EndIf
			dbSelectArea("STC")
			RestArea(aAreaSTC)
			dbSkip()
		End
	Else
		While !Eof() .And. stc->tc_filial == cFilStc .And. stc->tc_codbem == cVCOMP
			aAreaSTC := STC->(GetArea())
			aAdd(aVerFil,STC->TC_COMPONE)
			If STC->TC_TIPOEST = cESTIP
				If lPROCARR
					AAdd(aESTRU,{stc->tc_compone,stc->tc_localiz,stc->tc_manuati,stc->tc_seqrela,stc->tc_seqsup,cVCOMP,cLOCA})
				Else
					AAdd(aESTRU,stc->tc_compone)
				Endif
				DbSelectArea("STC")
				If DbSeek(cFilStc+STC->TC_COMPONE)
					aAreaTmp1 := STC->(GetArea())
					While nX <= Len(aVerFil)
						DbSelectArea("STC")
						If dbSeek(cFilStc+aVerFil[nX])
							aAreaTmp2 := STC->(GetArea())
							While !Eof() .and. stc->tc_filial == cFilStc .And. stc->tc_codbem == aVerFil[nX]
								If STC->TC_TIPOEST = cESTIP
									aAdd(aVerFil,STC->TC_COMPONE)

									If lPROCARR
										AAdd(aESTRU,{stc->tc_compone,stc->tc_localiz,stc->tc_manuati,stc->tc_seqrela,stc->tc_seqsup,cVCOMP,cLOCA})
									Else
										AAdd(aESTRU,stc->tc_compone)
									Endif
								Endif
								dbSelectArea("STC")
								dbSkip()
							End
							RestArea(aAreaTmp2)
						EndIf
						nX++
					End
					RestArea(aAreaTmp1)
				EndIf
			EndIf

			dbSelectArea("STC")
			RestArea(aAreaSTC)
			dbSkip()
		End
	EndIf
	RestArea(aArea)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGESTVITRB  ³ Autor ³ In cio Luiz Kolling ³ Data ³26/08/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Visualizar a estrutura a partir de um arquivo temporario    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cVALI     - Alias do arquivo temporario       - Obrigatorio ³±±
±±³          ³nLINI     - Linha inicial ( polegadas)        - Obrigatorio ³±±
±±³          ³nCOLI     - Coluna inicial ( polegadas)       - Obrigatorio ³±±
±±³          ³nTITU     - Titulo da janela                  - Obrigatorio ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGESTVITRB(cVALI,nLINI,nCOLI,cTITU)
	Private oTREE,oDLGEST                                 //objeto
	Private lTRB,lTREE                                    //logicos
	Private cLOCEST := Space(50),cALIES := '"'+cVALI+'"'  //strings
	Private nLINIF  := nLINI,nCOLIF := nCOLI              //numericas

	If Select(cVALI) = 0
		MsgInfo(STR0017+cVALI+STR0018,STR0010)
		Return
	Endif

	nOPC  := 2
	lTREE := .F.

	nLINIF := If(nLINIF > 260,260,If(nLINIF < 1,1,nLINIF))
	nCOLIF := If(nCOLIF > 375,375,If(nLINIF < 1,1,nCOLIF))

	DEFINE FONT NgFont NAME "Mono AS Regular" SIZE 0, -10
	DEFINE MSDIALOG oDLGEST FROM nLINIF,nCOLIF To nLINIF+270,nCOLIF+420 TITLE cTITU PIXEL

	@ 125,02 SAY oLOC1 VAR cLOCEST SIZE 120,08 Of oDLGEST PIXEL
	NGESTVITOB()

	ACTIVATE MSDIALOG oDLGEST

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGESTVITOB  ³ Autor ³ In cio Luiz Kolling ³ Data ³26/08/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³CRIA O OBJETO oTREE QUE GERENCIA OS NIVEIS                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³NGESTVITOB                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGESTVITOB()

	Local cDESC	:= Space(40), cDESC2, cSeque
	Local aItens	:= {}
	Local nI		:= 0

	Private lSequeSTC := NGCADICBASE( "TC_SEQUEN","A","STC",.F. ) //Verifica se existe o campo TC_SEQUEN no dicionário ou base dados.

	If lTREE
		oTREE:END()
		lTREE := .F.
	Endif
	oTREE  := DbTree():NEW(002,005,120,210,oDLGEST,{|| NGESTVIMOV(oTREE:GETCARGO())},,.T.)
	lTREE  := .T.

	Dbselectarea("ST9")
	Dbsetorder(1)
	cDESC := If(Dbseek(xFILIAL('ST9')+cBEMPAI) .And. !Empty(cBEMPAI),ST9->T9_NOME,cDESC)

	Dbselectarea(&(cALIES))
	Dbsetorder(1)
	lTRB := Dbseek(cBEMPAI)

	If lTRB
		cDESC2   := cBEMPAI+REPLICATE(" ",25-Len(RTRIM(cBEMPAI)))
		cPRODESC := cDESC2+' - '+cDESC
		DBADDTREE oTREE PROMPT cPRODESC OPENED RESOURCE "FOLDER5", "FOLDER6" CARGO cBEMPAI

		If lSequeSTC .And. IsInCallStack( "MNTA098" ) //Verifica se existe o campo TC_SEQUEN no dicionário ou base dados.

			While !Eof() .And. Alltrim(&(cALIES)->TC_CODBEM) == Alltrim(cBEMPAI)

				nREC	 	:= RECNO()
				cCOMP		:= (cTRB981)->TC_COMPONE
				cITEM	 	:= If(ST9->(Dbseek(xFILIAL('ST9')+cCOMP)),ST9->T9_NOME," ")
				cSEQ	 	:= (cTRB981)->TC_SEQRELA
				cLOC	 	:= (cTRB981)->TC_LOCALIZ
				cSeque	 	:= (cTRB981)->TC_SEQUEN
				cPRODESC	:= If(!Empty(cLOC),cCOMP+' - '+Alltrim(cITEM)+' - '+cLOC,cCOMP+' - '+cITEM)

				aAdd( aItens,{ cCOMP,cITEM,cSEQ,cLOC,cSeque } )

				Dbgoto(nREC)
				Dbskip()

			End While

			// Ordena itens antes de exibir na árvore
			aItens := aSort( aItens,,,{ |x,y| x[5] < y[5] } )

			For nI := 1 To Len( aItens )

				cCOMP 	:= aItens[nI][1] //Componente
				cITEM 	:= aItens[nI][2] //Item
				cSEQ  	:= aItens[nI][3] //Sequência
				cLOC  	:= aItens[nI][4] //Localização
				cSeque	:= aItens[nI][5] //Sequencial

				Dbselectarea(&(cALIES))
				If Dbseek(cCOMP)
					NGESTVIMAK(cCOMP, cITEM)
				Else
					cDESC2   := cCOMP+REPLICATE(" ",25-Len(RTRIM(cCOMP)))
					cPRODESC := cDESC2+' - '+cITEM
					DBADDITEM oTREE PROMPT cPRODESC RESOURCE "FOLDER5" CARGO cCOMP
				Endif

			Next nI

		Else

			While !Eof() .And. Alltrim(&(cALIES)->TC_CODBEM) == Alltrim(cBEMPAI)

				nREC  := RECNO()
				cCOMP := &(cALIES)->TC_COMPONE
				cITEM := If(ST9->(Dbseek(xFILIAL('ST9')+cCOMP)),ST9->T9_NOME," ")
				Dbselectarea(&(cALIES))
				If Dbseek(cCOMP)
					NGESTVIMAK(cCOMP, cITEM)
				Else
					cDESC2   := cCOMP+REPLICATE(" ",25-Len(RTRIM(cCOMP)))
					cPRODESC := cDESC2+' - '+cITEM
					DBADDITEM oTREE PROMPT cPRODESC RESOURCE "FOLDER5" CARGO cCOMP
				Endif
				Dbgoto(nREC)
				Dbskip()

			End While

		EndIf

		DBENDTREE oTREE
	Endif
	oTREE:REFRESH()
	oTREE:SETFOCUS()
	oTREE:TREESEEK(cBEMPAI)
	oTREE:SETFOCUS()
	oDLGEST:REFRESH()
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGESTVIMAK  ³ Autor ³ In cio Luiz Kolling ³ Data ³26/08/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Busca Itens filhos na estrutura - Funcao Recursiva         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³NGESTVITOB                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGESTVIMAK(cPAI,cDESCPAI)

	Local nREC,cDESC2,cSeque
	Local aItens		:= {}
	Local nI			:= 0

	cDESCPAI := If(ST9->(Dbseek(xFILIAL('ST9')+cPAI)),ST9->T9_NOME," ")
	cDESC2   := cPAI+REPLICATE(" ",25-Len(RTRIM(cPAI)))
	cPRODESC := cDESC2+' - '+cDESCPAI
	DBADDTREE oTREE PROMPT cPRODESC OPENED RESOURCE "FOLDER5", "FOLDER6" CARGO cPAI

	If lSequeSTC .And. IsInCallStack( "MNTA098" ) //Verifica se existe o campo TC_SEQUEN no dicionário ou base dados.

		While !Eof() .And. &(cALIES)->TC_CODBEM == cPAI

			nREC		:= RECNO()
			cCOMP		:= (cTRB981)->TC_COMPONE
			cITEM		:= If(ST9->(Dbseek(xFILIAL('ST9')+cCOMP)),ST9->T9_NOME," ")
			cSEQ		:= (cTRB981)->TC_SEQRELA
			cLOC		:= (cTRB981)->TC_LOCALIZ
			cSeque		:= (cTRB981)->TC_SEQUEN
			cPRODESC	:= If(!Empty(cLOC),cCOMP+' - '+Alltrim(cITEM)+' - '+cLOC,cCOMP+' - '+cITEM)

			aAdd( aItens,{ cCOMP,cITEM,cSEQ,cLOC,cSeque } )

			Dbgoto(nREC)
			Dbskip()

		End While

		// Ordena itens antes de exibir na árvore
		aItens := aSort( aItens,,,{ |x,y| x[5] < y[5] } )

		For nI := 1 To Len( aItens )

			cCOMP	:= aItens[nI][1] //Componente
			cITEM	:= aItens[nI][2] //Item
			cSEQ	:= aItens[nI][3] //Sequência
			cLOC	:= aItens[nI][4] //Localização
			cSeque	:= aItens[nI][5] //Sequencial

			Dbselectarea(&(cALIES))
			If Dbseek(cCOMP)
				NGESTVIMAK(cCOMP)
			Else
				cDESC2   := cCOMP+REPLICATE(" ",25-Len(RTRIM(cCOMP)))
				cPRODESC := cDESC2+' - '+cITEM
				DBADDITEM oTREE PROMPT cPRODESC RESOURCE "FOLDER5" CARGO cCOMP
			Endif
			Dbgoto(nREC)
			Dbskip()

		Next nI

	Else

		While !Eof() .And. &(cALIES)->TC_CODBEM == cPAI
			nREC  := RECNO()
			cCOMP := &(cALIES)->TC_COMPONE
			cITEM := If(ST9->(Dbseek(xFILIAL('ST9')+cCOMP)),ST9->T9_NOME," ")
			Dbselectarea(&(cALIES))
			If Dbseek(cCOMP)
				NGESTVIMAK(cCOMP)
			Else
				cDESC2   := cCOMP+REPLICATE(" ",25-Len(RTRIM(cCOMP)))
				cPRODESC := cDESC2+' - '+cITEM
				DBADDITEM oTREE PROMPT cPRODESC RESOURCE "FOLDER5" CARGO cCOMP
			Endif
			Dbgoto(nREC)
			Dbskip()
		End While

	EndIf

	DBENDTREE oTREE
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGESTVIMOV  ³ Autor ³ In cio Luiz Kolling ³ Data ³26/08/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Navega‡Æo nos elementos da estrutura ( localiza‡Æo )        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³NGESTVITOB                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGESTVIMOV(cCOD)
	cLOCEST := Space(50)
	Dbselectarea(&(cALIES))
	Dbsetorder(2)
	If Dbseek(cCOD)
		If !Empty(&(cALIES)->TC_LOCALIZ)
			cLOCEST := STR0019+Alltrim(&(cALIES)->TC_LOCALIZ)+' - ';
			+NGSEEK("TPS",&(cALIES)->TC_LOCALIZ,1,"TPS_NOME")
		Endif
	Endif
	oLOC1:Refresh()
	Dbselectarea(&(cALIES))
	Dbsetorder(1)
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGESTRUTRB³ Autor ³ Inacio Luiz Kolling   ³ Data ³24/11/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta um arquivo temporário com a Estrutura                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cVCODBEM - Codigo do bem                      - Obrigatorio³±±
±±³          ³ cTIPOEST - Tipo da estrutura                  - Obrigatorio³±±
±±³          ³ cVALITRB - Alias do arquivo temporario        - Obrigatorio³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGESTRUTRB(cVCODBEM, cTIPOEST, cVALITRB, oTmpTblx, lCriaTBL)

	Local cALIASOL := ALIAS()
	Local nORDEROL := IndexOrd()
	Local aIdx     := {{"TC_CODBEM","TC_COMPONE"},{"TC_COMPONE","TC_CODBEM"}}

	Private cALISTRB := IIf(ValType(cVALITRB) <> "U", cVALITRB, GetNextAlias()) // Alias da tabela

	Default lCriaTBL := .T.

	DbSelectArea("STC")

	If lCriaTBL
		aDBFX := DbStruct()
		Aadd(aDBFX,{"TC_TEMCPAI","C",01,0})
		Aadd(aDBFX,{"TC_TEMCCOM","C",01,0})
		Aadd(aDBFX,{"TC_CONTBE1","N",09,0})
		Aadd(aDBFX,{"TC_CONTBE2","N",09,0})

		oTmpTblx := fTempTable(cALISTRB, aDBFX, aIdx)
	EndIf

	cCODBEME := (cALISTRB) + "->TC_CODBEM"
	cCOMPONE := (cALISTRB) + "->TC_COMPONE"
	cTEMPAI  := (cALISTRB) + "->TC_TEMCPAI"
	cTEMCOM  := (cALISTRB) + "->TC_TEMCCOM"
	cCONBE1  := (cALISTRB) + "->TC_CONTBE1"
	cCONBE2  := (cALISTRB) + "->TC_CONTBE2"

	DbSelectArea("STC")
	DbSetOrder(1)
	If DbSeek(xFilial('STC')+cVCODBEM) .And. STC->TC_TIPOEST = cTIPOEST
		NGRESTRUTRB(cVCODBEM,cTIPOEST)
	EndIf

	If !Empty(cALIASOL)
		DbSelectArea(cALIASOL)
	Endif
	If !Empty(nORDEROL)
		DbSetOrder(nORDEROL)
	Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGRESTRUTRB ³ Autor ³In cio Luiz Kolling  ³ Data ³24/11/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta arquivo com os filhos                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³NGESTRUTRB                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGRESTRUTRB(cVBEM,cTIPOE)

	Local i

	While !Eof() .and. stc->tc_filial == xFilial('STC') .And.;
	stc->tc_codbem == cVBEM

		nRec1    := Recno()
		cCOMP    := stc->tc_compone
		If STC->TC_TIPOEST = cTIPOE
			&(cALISTRB)->(DbAppend())
			For i := 1 To Fcount()
				&(cALISTRB)->(FieldPut(i,STC->(FIELDGET(i)) ))
			Next i

			DbSelectArea("ST9")
			DbSetOrder(1)
			If DbSeek(xFilial('ST9')+&(cCODBEME))
				&(cTEMPAI) := ST9->T9_TEMCONT
			Endif
			If DbSeek(xFilial('ST9')+&(cCOMPONE))
				&(cTEMCOM) := ST9->T9_TEMCONT
				&(cCONBE1) := ST9->T9_POSCONT
			Endif
			DbSelectArea("TPE")
			DbSetOrder(1)
			If DbSeek(xFilial('TPE')+&(cCOMPONE))
				&(cCONBE2) := TPE->TPE_POSCON
			Endif

			DbSelectArea("STC")

			If DbSeek(xFilial('STC')+cCOMP)
				NGFESTRUTRB(cCOMP,cTIPOE)
			EndIf
		EndIf

		DbGoTo(nRec1)
		DbSkip()
	End

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGFESTRUTRB ³ Autor ³In cio Luiz Kolling  ³ Data ³24/11/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta arquivo com os filhos (RECURSIVA)                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³NGRESTRUTRB                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGFESTRUTRB(cVCOMP,cESTIP)

	Local nRec2, i

	While !Eof() .And. stc->tc_filial == xFilial('STC') .And.;
	stc->tc_codbem == cVCOMP

		nRec2 := Recno()
		cCOMP := stc->tc_compone
		If STC->TC_TIPOEST = cESTIP
			&(cALISTRB)->(DbAppend())
			For i := 1 To Fcount()
				&(cALISTRB)->(FieldPut(i,STC->(FIELDGET(i)) ))
			Next i
			DbSelectArea("ST9")
			DbSetOrder(1)
			If DbSeek(xFilial('ST9')+&(cCODBEME))
				&(cTEMPAI) := ST9->T9_TEMCONT
			Endif
			If DbSeek(xFilial('ST9')+&(cCOMPONE))
				&(cTEMCOM) := ST9->T9_TEMCONT
				&(cCONBE1) := ST9->T9_POSCONT
			Endif

			DbSelectArea("TPE")
			DbSetOrder(1)
			If DbSeek(xFilial('TPE')+&(cCOMPONE))
				&(cCONBE2) := TPE->TPE_POSCON
			Endif

			DbSelectArea("STC")
			If DbSeek(xFilial('STC')+cCOMP)
				NGFESTRUTRB(cCOMP,cESTIP)
			EndIf
		EndIf

		DbGoTo(nRec2)
		DbSkip()
	End

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³NGRETCOMPEST³  Autor³ In cio Luiz Kolling ³ Data ³28/06/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Monta a estrutura do bem para pesquisa                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³cBemPai  - C¢digo do bem                      - Obrigatorio ³±±
±±³          ³cEmpBem  - C¢digo da empresa do Bem                         ³±±
±±³          ³cEmpFil  - C¢digo da filial do Bem                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³cBemSet  - C¢digo do bem/componente selecionado             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Se cBemSet for vazio,nao foi confirmado a selecao ou ha pro-³±±
±±³          ³blema para a montagem da estrutura. Se necessario testar o  ³±±
±±³          ³retorno da funcao. Ex:                                      ³±±
±±³          ³                                                            ³±±
±±³          ³cComp := NGRETCOMPEST(cBemPai)                              ³±±
±±³          ³If Empty(cComp)                                             ³±±
±±³          ³   // Help e/ou retorno ???                                 ³±±
±±³          ³Endif                                                       ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGRETCOMPEST(cBemPai,cEmpBem,cFilBem)

	Local aAREARET := GetArea(),I := 0,cMenSa := Space(1)
	Local aTables  := {{"ST9"},{"STC"}}
	Local cOldFil  := cFilAnt
	Local aIndTRB  :=  {{"TC_CODBEM"},{"TC_COMPONE"}}
	Local oTmpTblTC

	Private cTRBSTC
	Private oTREE,ODLG,lRET := .T.
	Private aVETINR := {}

	cBemSet := Space(len(st9->t9_codbem))

	If !Empty(cEmpBem)
		NGPrepTBL(aTables,cEmpBem,cFilBem)
	EndIf

	If Empty(NGSEEK("ST9",cBemPai,1,"T9_NOME"))
		cMenSa := STR0020
	ElseIf Empty(NGSEEK("STC",cBemPai,1,"TC_CODBEM"))
		cMenSa := STR0020+" "+STR0021
	Endif

	If !Empty(cMenSa)
		MsgInfo(cMenSa,STR0010)
		Return cBemSet
	Endif

	Dbselectarea("STC")
	aDBFTRB := DbStruct()

	cTRBSTC := GetNextAlias()
	oTmpTblTC := fTempTable(cTRBSTC, aDBFTRB, aIndTRB)

	Dbselectarea("STC")
	Set Filter To STC->TC_FILIAL = xFilial("STC") .And. STC->TC_TIPOEST == "B"
	Dbseek(xFILIAL("STC")+cBemPai)
	While !Eof() .And. STC->TC_FILIAL = xFILIAL("STC") .And. STC->TC_CODBEM = cBemPai
		nREC  := RECNO()
		cCOMP := STC->TC_COMPONE
		(cTRBSTC)->(DbAppend())
		For i := 1 TO FCOUNT()
			(cTRBSTC)->(FieldPut(i, STC->(FIELDGET(i)) ))
		Next i
		Dbselectarea("STC")
		If Dbseek(xFILIAL("STC")+cCOMP)
			NGCOMPFILEST(cCOMP)
		Endif
		Dbgoto(nREC)
		Dbskip()
	End

	Dbselectarea("STC")
	Set Filter To
	Dbsetorder(1)

	DEFINE FONT NgFont NAME "Courier New" SIZE 6, 0
	DEFINE MSDIALOG ODLG FROM 03.5,6 TO 370,580 TITLE STR0022+" "+Alltrim(cBemPai)+"  "+NGSEEK("ST9",cBemPai,1,"T9_NOME") ;
	COLOR CLR_BLACK,CLR_WHITE PIXEL

	NGMONTESTPES(cBemPai)

	DEFINE SBUTTON FROM 165,215 TYPE 1 ENABLE OF ODLG ACTION If(NGRETESTROK(),EVAL({|| lRet := .T.,ODLG:END()}),lRET := .F.)
	DEFINE SBUTTON FROM 165,244 TYPE 2 ENABLE OF ODLG ACTION ODLG:END()
	ACTIVATE MSDIALOG ODLG CENTERED

	oTmpTblTC:Delete()

	If !Empty(cEmpBem)
		NGPrepTBL(aTables,cEmpAnt,cOldFil)
	EndIf

	RestArea(aAREARET)
Return If(lRet,cBemSet,Space(Len(st9->t9_codbem)))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³NGCOMPFILEST³ Autor ³Inacio Luiz Kolling  ³ Data ³29/06/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Inclui os filhos do bem no arquivo temporario               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³NGMONTESTPES                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGCOMPFILEST(cVPAI)
	Local nREC,ng1
	While !Eof() .And. STC->TC_FILIAL = xFILIAL("STC") .And. STC->TC_CODBEM = cVPAI
		nREC  := RECNO()
		cCOMP := STC->TC_COMPONE
		(cTRBSTC)->(DbAppend())
		For ng1 := 1 TO FCOUNT()
			(cTRBSTC)->(FieldPut(ng1,STC->(FIELDGET(ng1))))
		Next ng1
		Dbselectarea("STC")
		If Dbseek(xFILIAL("STC")+cCOMP)
			NGCOMPFILEST(cCOMP)
		Endif
		Dbgoto(nREC)
		Dbskip()
	End
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³NGMONTESTPES³  Autor³ Inacio Luiz Kolling ³ Data ³29/06/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cria o objeto oTREE que gerencia os niveis                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³NGRETCOMPEST                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGMONTESTPES(cPAI)
	Local cDESC := SPACE(40), cDESC2
	cFIRST := cPAI
	oTREE  := DbTree():NEW(005,012,150,272,ODLG,{|| NGRETESTMOV(oTREE:GETCARGO())},,.T.)
	cDESC  := NGSEEK("ST9",cFIRST,1,"T9_NOME")

	Dbselectarea(cTRBSTC)
	Dbsetorder(1)
	Dbseek(cFIRST)

	cDESC2   := cFIRST+REPLICATE(" ",25-Len(RTRIM(cFIRST)))
	cPRODESC := cDESC2+" - "+cDESC
	DBADDTREE oTREE PROMPT cPRODESC OPENED RESOURCE "FOLDER5", "FOLDER6" CARGO cFIRST
	While !Eof() .And. Alltrim((cTRBSTC)->TC_CODBEM) == Alltrim(cFIRST)
		nREC  := RECNO()
		cCOMP := (cTRBSTC)->TC_COMPONE
		cITEM := If(ST9->(Dbseek(xFILIAL("ST9")+cCOMP)),ST9->T9_NOME," ")
		Dbselectarea(cTRBSTC)
		If Dbseek(cCOMP)
			NGMAKESTMONT(cCOMP,cITEM)
		Else
			cDESC2   := cCOMP+REPLICATE(" ",25-Len(RTRIM(cCOMP)))
			cPRODESC := cDESC2+" - "+cITEM
			DBADDITEM oTREE PROMPT cPRODESC RESOURCE "FOLDER5" CARGO cCOMP
		Endif
		Dbgoto(nREC)
		Dbskip()
	End
	DBENDTREE oTREE

	oTREE:REFRESH()
	oTREE:TREESEEK(cFIRST)
	ODLG:REFRESH()

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³NGMAKESTMONT³ Autor ³Inacio Luiz Kolling  ³ Data ³29/06/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Busca Itens filhos na estrutura - Funcao Recursiva          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³NGMONTESTPES                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGMAKESTMONT(cPAI,cDESCPAI)
	Local nREC,cDESC2
	cDESCPAI := NGSEEK("ST9",cPAI,1,"T9_NOME")
	cDESC2   := cPAI+REPLICATE(" ",25-Len(RTRIM(cPAI)))
	cPRODESC := cDESC2+" - "+cDESCPAI
	DBADDTREE oTREE PROMPT cPRODESC OPENED RESOURCE "FOLDER5", "FOLDER6" CARGO cPAI
	While !(cTRBSTC)->(Eof()) .And. (cTRBSTC)->TC_CODBEM == cPAI
		nREC  := RECNO()
		cCOMP := (cTRBSTC)->TC_COMPONE
		cITEM := If(ST9->(Dbseek(xFILIAL("ST9")+cCOMP)),ST9->T9_NOME," ")
		Dbselectarea(cTRBSTC)
		If Dbseek(cCOMP)
			NGMAKESTMONT(cCOMP)
		Else
			cDESC2   := cCOMP+REPLICATE(" ",25-Len(RTRIM(cCOMP)))
			cPRODESC := cDESC2+" - "+cITEM
			DBADDITEM oTREE PROMPT cPRODESC RESOURCE "FOLDER5" CARGO cCOMP
		Endif
		Dbgoto(nREC)
		Dbskip()
	End
	DBENDTREE oTREE
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³NGRETESTROK³ Autor ³Inacio Luiz Kolling  ³ Data ³29/06/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Confirmacao da selecao do bem/componente                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³NGRETCOMPEST                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGRETESTROK()
	cBemSet := oTREE:GETCARGO()
	If Empty(cBemSet)
		MsgInfo(STR0023,STR0010)
		lRET := .F.
	Else
		ODLG:END()
		lRET := .T.
	Endif
Return lRET

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NGESESTRC ³ Autor ³Inacio Luiz Kolling   ³ Data ³30/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Entrada e/ou saida de um compomente da estrutura            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cBEMPES - Bem pai da estrutura                - Obrigatorio ³±±
±±³          ³cCOMPES - Componente de estrutura (E/S)       - Obrigatorio ³±±
±±³          ³nCONTES - Contador do bem pai\Componente (E/S)- Nao Obrigat.³±±
±±³          ³dDATAES - Data de entrada/saida               - Obrigatorio ³±±
±±³          ³cHORAES - Hora de entrada/saida               - Obrigatorio ³±±
±±³          ³nTPCONT - Tipo do contador (1/2)              - Nao Obrigat.³±±
±±³          ³cTPMOES - Tipo de movimentacao (E/S)          - Obrigatorio ³±±
±±³          ³cMOTISA - Motivo da movimentacao              - Obrig. para ³±±
±±³          ³                                                 cTPMOES = S³±±
±±³          ³cLOCLES - Localizacao do componente (E)       - Nao Obrig.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³vVETRES - Vetor [1], .T.,.F. - Realizou a operacao, ou nao  ³±±
±±³          ³                [2] mensagem                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³P. Entrada³NGESETPTO - Alimenta vVETRES - Vetor [1], .T.,.F.           ³±±
±±³          ³                                     [2] mensagem           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³NGESESTR e/ou GENERICO                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGESESTRC(cBEMPES,cCOMPES,nCONTES,dDATAES,cHORAES,nTPCONT,cTPMOES,;
	cMOTISA,cLOCLES)
	Local aAreastru := GetArea(),vVetBa := {},cNaoInf := STR0024,cNaoCad := STR0025
	Local cCadast   := STR0026,nTpoCont := If(nTPCONT = Nil,1,nTPCONT)
	Local lIntTms   := GetMV('MV_INTTMS',,.F.) //Integracao com o TMS
	Local lMntTms  := (GetMV('MV_NGMNTMS',,'N') == 'S') //Ativa integracao TMS X MNT
	// Consistencia do bem pai

	Private vVetRes := {.T.,STR0027,.F.} //"Operacao realizada com sucesso."

	cFilBPai := xFILIAL("STC")

	If cBEMPES = Nil .Or. Empty(cBEMPES)
		vVetRes := {.F.,STR0028+" "+cNaoInf} //"Bem pai da estrutura"###"nao informado"
	Else
		NGDBAREAORDE("ST9",1)
		//--Se for exclusivo, para esta pesquisa preciso da filial que o veiculo foi cadastrado
		//--Somente quando utiliza TMS e a integracao est ativada
		If lIntTms .And. lMntTms .And. !Empty(cFilBPai)
			cFilBPai := Posicione("DA3",5,xFilial("DA3")+cBEMPES,"DA3_FILBAS")
		EndIf

		If !DbSeek(NGTROCAFILI("ST9",cFilBPai)+cBEMPES)
			vVetRes := {.F.,STR0028+" "+cNaoCad+" "+cCadast+" "+NGSX2NOME("ST9")} //"Bem pai da estrutura"###"nao cadastrado"###"no cadastro de"
		Endif

		If st9->t9_sitbem = "I"
			vVetRes := {.F.,STR0029+" "+STR0030} //"Bem Pai"###"esta com a situacao de inativo"
		Endif

		cTemCPai := ST9->T9_TEMCONT
		nRecST9  := Recno()

		NGDBAREAORDE("ST9",1)
		dbgoto(nRecST9)

   If cTPMOES == 'S'
		If vVetRes[1]
			NGDBAREAORDE("STC",1)
			If !DbSeek(NGTROCAFILI("STC",cFilBPai)+cBEMPES)
				vVetRes := {.F.,STR0028+" "+cNaoCad+" "+cCadast+" "+NGSX2NOME("STC")} //"Bem pai da estrutura"###"nao cadastrado"###"no cadastro de"
			Endif
		Endif
   EndIF
	Endif

	If vVetRes[1]
		vVetBa := NGCADICBASE('TP9_ACOPLA','A','TP9')
		If !vVetBa[1]
			vVetRes := {.F.,vVetBa[2]}
		Endif
	Endif

	// consistencia do tipo de movimentacao
	If vVetRes[1]
		If cTPMOES = Nil .Or. Empty(cTPMOES)
			vVetRes := {.F.,STR0070+" "+cNaoInf} //") NAO FOI ABERTO..."###"nao informado"
		Else
			If !(cTPMOES$"ES")
				vVetRes := {.F.,STR0031+" "+STR0032+" E/S"} //"Tipo de movimentacao"###"devera ser a"
			Endif
		Endif
	Endif

	If vVetRes[1]
		If cTPMOES = "E"
			vVetRes := NGPADACOPLA(cBEMPES,"P")
			If vVetRes[1]
				vVetRes := NGPADACOPLA(cCOMPES,"C")
			Endif
		Endif
	Endif

	// Consistencia do compomente
	If vVetRes[1]
		If cCOMPES = Nil .Or. Empty(cCOMPES)
			vVetRes := {.F.,STR0033+" "+cNaoInf} //"Componente de estrutura"###"nao informado"
		Else
			NGDBAREAORDE("ST9",1)
			If !DbSeek(NGTROCAFILI("ST9",cFilBPai)+cCOMPES)
				vVetRes := {.F.,STR0033+" "+cNaoCad+" "+cCadast+" "+NGSX2NOME("ST9")} //"Componente de estrutura"###"nao cadastrado"###"no cadastro de"
			Endif
			If st9->t9_sitbem = "I"
				vVetRes := {.F.,STR0034+" "+STR0030} //"Componente"
			Endif
			If vVetRes[1]
				If cTPMOES = "S"
					NGDBAREAORDE("STC",1)
					If !DbSeek(NGTROCAFILI("STC",cFilBPai)+cBEMPES+cCOMPES)
						vVetRes := {.F.,STR0033+" "+cNaoCad+" "+cCadast+" "+NGSX2NOME("STC")} //"Componente de estrutura"###"nao cadastrado"###"no cadastro de"
					Endif
				Else
					NGDBAREAORDE("STC",3)
					If DbSeek(NGTROCAFILI("STC",cFilBPai)+cCOMPES)
						vVetRes := {.F.,STR0035+" "+STR0036} //"Componente ja faz parte de outra estrutura"###"ou na mesma"
					Endif

					If vVetRes[1]
						NGDBAREAORDE("STC",1)
						If DbSeek(NGTROCAFILI("STC",cFilBPai)+cBEMPES+cCOMPES)
							vVetRes := {.F.,STR0037} //"Ja existe estrutura para o Bem pai X Componente"
						Endif
					Endif

				Endif
			Endif
			cTemComp := ST9->T9_TEMCONT
		Endif
	Endif

	If vVetRes[1]
		If !Empty(cBEMPES) .And. !Empty(cCOMPES)
			If cBEMPES = cCOMPES
				vVetRes := {.F.,STR0038+" "+STR0039+" "+STR0034} //"Bem Pai"###"igual ao"###"Componente"
			Endif
		Endif
	Endif

	// consistencia do contador
	If vVetRes[1]
		If cTemCPai = "S" .Or. cTemComp = "S"
			If nTpoCont >= 1 .And. nTpoCont <= 2
			Else
				vVetRes := {.F.,STR0040+" 1"+" "+STR0041+" 2"} //"Tipo de contador devera ser"###"ou"
			Endif
			If vVetRes[1]
				If nTpoCont = 2
					If cTemComp = "S"
						If !NGIFDBSEEK('TPE',cCOMPES,1)
							vVetRes := {.F.,STR0033+" "+cNaoCad+" "+cCadast+" "+NGSX2NOME("TPE")} //"Componente de estrutura"###"nao cadastrado"###"no cadastro de"
							cTemComp := Space(1)
						Endif
					Endif
					If vVetRes[1]
						If cTemCPai = "S"
							If !NGIFDBSEEK('TPE',cBEMPES,1)
								vVetRes := {.F.,STR0028+" "+cNaoCad+" "+cCadast+" "+NGSX2NOME("TPE")} //"Bem pai da estrutura"###"nao cadastrado"###"no cadastro de"
								cTemCPai := Space(1)
							Endif
						Endif
					Endif
				Endif
			Endif
		Endif
	Endif

	// consistencia do contador
	If vVetRes[1]
		If cTemCPai = "S" .Or. cTemComp = "S"
			If nCONTES = Nil .Or. Empty(nCONTES)
				vVetRes := {.F.,STR0042+" "+cNaoInf} //"Contador"###"nao informado"
			Endif
		Endif
	Endif

	// Consistencia da data
	If vVetRes[1]
		If dDATAES = Nil .Or. Empty(dDATAES)
			vVetRes := {.F.,STR0043+" "+cNaoInf} //"Data da movimentacao"###"nao informado"
		Else
			If cTPMOES = "S"
				If dDATAES < stc->tc_dataini
					vVetRes := {.F.,STR0044} //"Data de saida menor do que a data de entrada na estrutura"
				Endif
			Endif
		Endif
	Endif

	// Consistencia da hora
	If vVetRes[1]
		If cHORAES = Nil .Or. Empty(cHORAES) .Or. Ltrim(cHORAES) = ":"
			vVetRes := {.F.,STR0045+" "+cNaoInf} //"Hora da movimentacao"###"nao informado"
		ElseIf !NGVALHORA(cHORAES,.F.)
			vVetRes := {.F.,STR0045+" "+STR0046} //"Hora da movimentacao"###"Invalida"
		Else
			If cTPMOES = "S" .And. dDATAES = stc->tc_dataini
				If NGIFDBSEEK('STZ',cCOMPES+"E",1)
					If cHORAES <= stz->tz_horaent
						vVetRes := {.F.,STR0047+" "+cHORAES+" "+STR0048+chr(13); //"Hora da saida componente"###  ###"devera ser maior"
						+STR0049+" "+stz->tz_horaent+" "+STR0050} //"do que a hora"###"de entrada na estrutura"
					Endif
				Endif
			Endif
		Endif
	Endif

	// Consistencia do motivo da saida da estrutura

	If vVetRes[1]
		If cTPMOES = "S"
			If cMOTISA = Nil .Or. Empty(cMOTISA)
				vVetRes := {.F.,STR0051+" "+cNaoInf} //"Motivo da movimentacao de saida"###"nao informado"
			Else
				If !NGIFDBSEEK('ST8',cMOTISA,1)
					vVetRes := {.F.,STR0051+" "+cNaoCad} //"Motivo da movimentacao de saida"###"nao cadastrado"
				Else
					If ST8->T8_TIPO <> 'C'
						vVetRes := {.F.,STR0051+" "+STR0052} //"Motivo da movimentacao de saida"###"devera ser do tipo causa"
					Endif
				Endif
			Endif
		Else
			If cLOCLES <> Nil .And. !Empty(cLOCLES)
				If !NGIFDBSEEK('TPS',cLOCLES,1)
					vVetRes := {.F.,STR0053+" "+cNaoCad} //"Localizacao do compomente"###"nao cadastrado"
				Endif
			Endif
		Endif
	Endif

	// Consistencia lancamento de contador

	If vVetRes[1]
		If cTemCPai = "S" .Or. cTemComp = "S"
			cBemCon := If(cTemComp = "S",cCOMPES,cBEMPES)
			vVETCHKB := NGCHKHISTO(cBemCon,dDATAES,nCONTES,cHORAES,nTpoCont,,.F.,cFilBPai)
			If !vVETCHKB[1]
				vVetRes := {.F.,vVETCHKB[2],.F.}
			Endif
		Endif
	Endif

	If vVetRes[1]
		If ExistBlock("NGESETPTO")
			ExecBlock("NGESETPTO",.F.,.F.,;
			{cBEMPES,cCOMPES,nCONTES,dDATAES,cHORAES,nTPCONT,cTPMOES,;
			cMOTISA,cLOCLES})
		Endif
	Endif

	RestArea(aAreastru)

Return vVetRes

//---------------------------------------------------------------------
/*/{Protheus.doc} NGESESTRF
Entrada e/ou saída de um compomente da estrutura.

@type function
@author Inácio Luiz Kolling
@since 30/11/2006

@param [cBEMPES], Caracter, Bem pai da estrutura
@param [cCOMPES], Caracter, Componente de estrutura (E/S)
@param nCONTES  , Numérico, Contador do bem pai\Componente (E/S)
@param [dDATAES], Data	  , Data de entrada/saida
@param [cHORAES], Caracter, Hora de entrada/saida
@param nTPCONT  , Numérico, Tipo do contador (1/2)
@param [cTPMOES], Caracter, Tipo de movimentacao (E/S)
@param cMOTISA  , Caracter, Motivo da movimentacao
							Obs.: obrigatório quando cTPMOES = S
@param cLOCLES	, Caracter, Localizacao do componente (E)
@param [aTrbEst], Array	  , Possui as tabelas temporárias responsáveis por montar
							a estrutura do bem.
							[1] tabela temporaria do pai da estrutura - cTRBS
							[2] tabela temporaria do pai da estrutura - cTRBF
							[3] tabela temporaria do eixo suspenso    - CTRBEixo
@Param [aBemCnt], Array   , Estrutura para validação do bem/componente
	   [ 1, 1 ] - Código bem Pai  |  [ 2, 1 ] - Código Componente
	   [ 1, 2 ] - Contador 1 Pai  |  [ 2, 2 ] - Contador 1 Componente
	   [ 1, 3 ] - Contador 2 Pai  |  [ 2, 3 ] - Contador 2 Componente
	   [ 1, 4 ] - When Contador 1 |  [ 2, 4 ] - When Contador 1
	   [ 1, 5 ] - When Contador 2 |  [ 2, 5 ] - When Contador 2
@obs: Array aBemCnt utilizada somente as 3 primeiras posições;

@return vVettrf - Vetor [1], .T.,.F. - Realizou a operação, ou não
			            [2] mensagem
/*/
//---------------------------------------------------------------------
Function NGESESTRF(cBEMPES,cCOMPES,nCONTES,dDATAES,cHORAES,nTPCONT,cTPMOES,cMOTISA,cLOCLES,aTrbEst, aBemCnt)

	Local aAreastr2 := GetArea(),nVi := 0,xE := 0,vVettrf := {.T.,STR0027}
	Local nTpoCont  := If(nTPCONT = Nil,1,nTPCONT),cFilBPai := xFilial("STC")
	Local lIntTms   := GetMV('MV_INTTMS',,.F.) //Integracao com o TMS
	Local lMntTms   := (GetMV('MV_NGMNTMS',,'N') == 'S') //Ativa integracao TMS X MNT
	Local nRecTPN   := 0
	Local nCont2    := 0
	Local lPIMSINT	:= SuperGetMV("MV_PIMSINT",.F.,.F.)
	Local lOMainWnd := Type( "oMainWnd" ) == "O"

	Default aTrbEst := {}
	Default aBemCnt := {}

	If Len( aBemCnt ) > 0
		nCONTES := aBemCnt[ 2, 2 ]
		// Caso tenha valor nos contadores é realizado reporte.
		If aBemCnt[ 1, 2 ] > 0
			// Reporta contador 1 para o bem Pai
			NGTRETCON(cBEMPES,dDATAES,aBemCnt[ 1, 2 ],cHORAES, 1,,.T.,,cFilBPai,,,aTrbEst)
		EndIf
		If aBemCnt[ 1, 3 ] > 0
			// Reporta contador 2 para o bem Pai
			NGTRETCON(cBEMPES,dDATAES, aBemCnt[ 1, 3 ],cHORAES, 2,,.T.,,cFilBPai,,,aTrbEst)
		EndIf
		If aBemCnt[ 2, 2 ] > 0 .And. cTemComp == 'S'
			// Reporta contador 1 para o componente
			NGTRETCON(cCOMPES,dDATAES,aBemCnt[ 2, 2 ],cHORAES, 1,,.T.,,cFilBPai,,,aTrbEst)
		EndIf
		If aBemCnt[ 2, 3 ] > 0 .And. cTemComp == 'S'
			// Reporta contador 2 para o componente
			NGTRETCON(cCOMPES,dDATAES, aBemCnt[ 2, 3 ],cHORAES, 2,,.T.,,cFilBPai,,,aTrbEst)
			// Atribui valor do contador 2
			nCont2 := aBemCnt[ 2, 3 ]
		EndIf
	Else
		NGIFDBSEEK('TPE',cCOMPES,1)
		nCont2 := TPE->TPE_POSCON
		// Reporta contador para o bem Pai do acoplamento
		NGTRETCON(cBEMPES,dDATAES,nCONTES,cHORAES,nTpoCont,,.T.,,cFilBPai,,,aTrbEst)
	EndIf

	If cTPMOES == "E"

		NGDBAREAORDE("STC",1)
		If !Dbseek(NGTROCAFILI("STC",cFilBPai)+cBEMPES+cCOMPES)
			RecLock("STC",.T.)
			STC->TC_FILIAL  := NGTROCAFILI("STC",cFilBPai)
			STC->TC_TIPOEST := "B"
			STC->TC_CODBEM  := cBEMPES
			STC->TC_COMPONE := cCOMPES
			STC->TC_LOCALIZ := cLOCLES
			STC->TC_DATAINI := dDATAES
			If NGCADICBASE("TC_TIPMOD","D","STC",.F.)
				dbSelectArea("ST9")
				dbSetOrder(16)
				If dbSeek(STC->TC_CODBEM)
					STC->TC_TIPMOD := ST9->T9_TIPMOD
				EndIf
			EndIf
			STC->(MsUnlock())
		EndIf

		aEstComp := NGCOMPEST(cCOMPES,"B",.T.,.F.,,cFilBPai)

		aAdd(aEstComp,cCOMPES)

		NGIFDBSEEK('ST9',cBEMPES,1)

		cCodCust := st9->t9_ccusto
		cCodTrab := st9->t9_centrab
		cCodCale := st9->t9_calenda

		For nVi := 1 To Len(aEstComp)

			nRecTPN := 0
			// ALTERA OS CENTROS DE ( CUSTO E TRABALHO ) E CALENDARIO
			NGIFDBSEEK('TPE',aEstComp[nVi],1)
			NGDBAREAORDE("ST9",1)
			If Dbseek(NGTROCAFILI("ST9",cFilBPai)+aEstComp[nVi])
				RecLock("ST9",.F.)
				If cCodCust <> ST9->T9_CCUSTO .And. !Empty(cCodCust) .And.;
				ST9->T9_MOVIBEM == 'S'
					ST9->T9_CCUSTO := cCodCust

					//Atualiza o centro de custo no ativo fixo
					NGATUATF(ST9->T9_CODIMOB,ST9->T9_CCUSTO)

					dbSelectArea("TPN")
					dbSetOrder(1)
					RecLock("TPN",.T.)
					TPN->TPN_FILIAL := xFILIAL("TPN")
					TPN->TPN_CODBEM := st9->t9_codbem
					TPN->TPN_DTINIC := dDATABASE
					TPN->TPN_HRINIC := Time()
					TPN->TPN_CCUSTO := cCodCust
					TPN->TPN_CTRAB  := cCodTrab
					TPN->TPN_UTILIZ := "U"
					TPN->TPN_POSCON := st9->t9_poscont
					TPN->TPN_POSCO2 := tpe->tpe_poscon
					TPN->(MsUnlock())
					nRecTPN := TPN->(RecNo())

				EndIf

				If cCodTrab <> ST9->T9_CENTRAB .And. !Empty(cCodTrab)
					ST9->T9_CENTRAB := cCodTrab
				EndIf

				If cCodCale <> ST9->T9_CALENDA .And. !Empty(cCodCale)
					ST9->T9_CALENDA := cCodCale
				EndIf
				ST9->(MsUnlock())

				//Funcao de integracao com o PIMS atraves do EAI
				If lPIMSINT .And. FindFunction("NGIntPIMS") .And. nRecTPN > 0
					NGIntPIMS("TPN",nRecTPN,3)
				EndIf

				//----------------------------------------------------
				// Integração via mensagem única do cadastro de Bem
				//----------------------------------------------------
				If FindFunction("MN080INTMB") .And. MN080INTMB(ST9->T9_CODFAMI)

					dbSelectArea( "ST9" )

					// Define array private que será usado dentro da integração
					aParamMensUn    := Array( 4 )
					aParamMensUn[1] := Recno() // Indica numero do registro
					aParamMensUn[2] := 4       // Indica tipo de operação que esta invocando a mensagem unica
					aParamMensUn[3] := .F.     // Indica que se deve recuperar dados da memória
					aParamMensUn[4] := 1       // Indica se deve inativar o bem (1 ativo,2 - inativo)

					lMuEquip := .F.
					bBlock := { || FWIntegDef( "MNTA080",EAI_MESSAGE_BUSINESS,TRANS_SEND,Nil ) }

					If lOMainWnd
						MsgRun("Aguarde integração com backoffice...","Equipment",bBlock)
					Else
						Eval(bBlock)
					EndIf

				EndIf

			EndIf
		Next nVi

		dbSelectArea("STZ")
		RecLock("STZ",.T.)
		STZ->TZ_FILIAL  := NGTROCAFILI("STZ",cFilBPai)
		STZ->TZ_CODBEM  := cCOMPES
		STZ->TZ_BEMPAI  := cBEMPES
		STZ->TZ_LOCALIZ := cLOCLES
		STZ->TZ_DATAMOV := dDATAES
		STZ->TZ_POSCONT := nCONTES
		STZ->TZ_TIPOMOV := "E"
		STZ->TZ_POSCON2 := nCont2

		//Verificar se o bem tem 1º contador
		If cTemComp <> "N"
			STZ->TZ_HORACO1 := cHORAES //Time()
		EndIf

		//Verificar se o bem tem 2º contador
		If NGIFDBSEEK('TPE',cCOMPES,1)
			STZ->TZ_HORACO2 := cHORAES //Time()
		EndIf

		STZ->TZ_HORAENT := cHORAES
		STZ->TZ_TEMCONT := cTemComp
		STZ->TZ_TEMCPAI := cTemCPai
		STZ->(MsUnlock())

		//Atualizar o campo T9_ESTRUTURA quando acoplado ao Bem
		dbSelectArea("ST9")
		If dbSeek(NGTROCAFILI("ST9",cFilBPai)+cCOMPES)
			RecLock("ST9",.F.)
			ST9->T9_ESTRUTU := "S"
			MsUnLock("ST9")
		EndIf

		nPOSC := Ascan(aEstComp,cCOMPES)
		If nPOSC > 0

			//para essa chamada e' ideal que STC e STZ ja estejam atualizados
			vESTCOMPO := NGCOMPPCONT(cCOMPES,dDATAES,cHORAES,cFilBPai)

			For xE := 1 To Len(vESTCOMPO)
				NGDBAREAORDE("ST9",1)
				If Dbseek(NGTROCAFILI("ST9",cFilBPai)+vESTCOMPO[xE,1])
					If dDATAES > st9->t9_dtultac .Or. (dDATAES = st9->t9_dtultac .And. nCONTES > st9->t9_poscont);
					.And. ST9->T9_TEMCONT $ "P/I"
						RecLock("ST9",.F.)
						ST9->T9_POSCONT := nCONTES
						ST9->T9_DTULTAC := dDATAES
						MsUnlock("ST9")
					EndIf
				EndIf
			Next xE
		EndIf

	Else

		NGDBAREAORDE("STZ",1)
		If Dbseek(NGTROCAFILI("STZ",cFilBPai)+cCOMPES+'E')
			RecLock("STZ",.F.)
			STZ->TZ_TIPOMOV := 'S'
			STZ->TZ_DATASAI := dDATAES
			STZ->TZ_CONTSAI := nCONTES
			STZ->TZ_CONTSA2 := nCont2
			STZ->TZ_HORASAI := cHORAES
			STZ->TZ_CAUSA   := cMOTISA
			STZ->(MsUnlock())
		EndIf
		//Atualizar o campo T9_ESTRUTURA quando acoplado ao Bem
		dbSelectArea("ST9")
		If dbSeek(NGTROCAFILI("ST9",cFilBPai)+cCOMPES)
			RecLock("ST9",.F.)
			ST9->T9_ESTRUTU := "N"
			MsUnLock("ST9")
		EndIf
		NGDBAREAORDE("STC",1)
		If Dbseek(NGTROCAFILI("STC",cFilBPai)+cBEMPES+cCOMPES)
			NGDELETAREG("STC")
		EndIf
	EndIf

	// Historico de contadores
	If cTemCPai = "S" .Or. cTemComp = "S"
		cBemCon := If(cTemComp = "S",cCOMPES,cBEMPES)
		If lIntTms .And. lMntTms .And. !Empty(cFilBPai)
			cFilBPai := Posicione("DA3",5,xFilial("DA3")+cBEMPES,"DA3_FILBAS")
		EndIf

		//Reporta contador para o Filho a ser acomplado a estrutura, para os filhos da estrutura não é repassado contador
		If cTemComp <> 'S' .And. cTemComp <> 'N' //Quando Bem possuir contador próprio ou não tiver contador, não repassa contador
			NGINREGEST(cCOMPES,dDATAES,cHORAES,nTpoCont,nCONTES,ST9->T9_CONTACU,ST9->T9_VIRADAS)
		EndIf

	EndIf

	RestArea(aAreastr2)
Return vVettrf

//-------------------------------------------------------------------
/*/{Protheus.doc} NGACOPLAD
Entrada/saida de um compomente da estrutura (ACOPL/DESACOPL)

@author  Inacio Luiz Kolling
@since   01/12/2006
@version P11/P12
@param   cVBPai, Caracter, Código do bem pai
/*/
//-------------------------------------------------------------------
Function NGACOPLAD(cVBPai)

	Local dBDMov    := Ctod('  /  /    ')
	Local cBHMov    := Space(5)
	Local lLeBp     := .T.
	Local aTMov     := {STR0054,STR0055} //Acoplamento...Desacoplamento
	Local aAreaPl   := GetArea()
	Local aAreaST9  := ST9->(GetArea())
	Local cSpaceCod := Space(Len(ST9->T9_CODBEM))
	// [1,1] - Código bem Pai / [1,2] - Contador 1 Pai / [1,3] - Contador 2 Pai / [1,4] - When Contador 1 / [1,5] - When Contador 2
	// [2,1] - Código Componente / [2,2] - Contador 1 Componente / [2,3] - Contador 2 Componente / [2,4] - When Contador 1 / [2,5] - When Contador 2
	Local aBemCount := { { cSpaceCod, 0, 0, .T., .T. }, { cSpaceCod, 0, 0, .T., .T. } }

	Private nBCont  := 0
	Private oDlgC,cTComp := Space(1),cTCPai := Space(1)
	Private cNomBe,cNomCo,cNomMo,cNomLo,lLerMo,lLerLo
	Private cTemComp,cTemCPai,cBMoti,cBLoc,cBPai,cBComp,cBTMov


	cBPai   := cSpaceCod
	cBMoti  := Space(Len(ST8->T8_CODOCOR))
	cBLoc   := Space(Len(TPS->TPS_CODLOC))
	cBComp  := cBPai
	nBCont  := 0
	cBTMov  := STR0054
	lLerMo  := .F.
	lLerLo  := .T.
	Store Space(1)  To cTemComp,cTemCPai
 	Store Space(40) To cNomBe,cNomCo,cNomMo,cNomLo

	If cVBPai <> Nil
		aBemCount[ 1, 1 ] := cVBPai
		NGALINVARP("ST9",aBemCount[ 1, 1 ],1,{{"cNomBe","T9_NOME"},;
		{"cTemCPai","T9_TEMCONT"}})
		lLeBp := .F.
		// Carrega os campos de contador 1 e 2.
		NGACOPB( aBemCount[ 1, 1 ], 1, @aBemCount, cBTMov)
	Endif

	While .T.
		nOpca   := 0
		DEFINE MSDIALOG oDlgC FROM 250,150 TO 490,1000 TITLE STR0054+" / "+STR0055 PIXEL //Acoplamento ... Desacoplamento

		@ 041,008 say OemtoAnsi(STR0038) of oDlgC Pixel Color CLR_HBLUE //Bem Pai
		@ 040,040 Msget aBemCount[ 1, 1 ]  Picture '@!' When lLeBp Valid;
		ExistCpo("ST9",aBemCount[ 1, 1 ]) .And. NGACOPB(aBemCount[ 1, 1 ],1, @aBemCount, cBTMov);
		F3 "ST9" SIZE 60,7 of oDlgC Pixel HasButton

		@ 040,105 Msget cNomBE Picture '@!' When .F. SIZE 180,7 of oDlgC Pixel

		@ 041,290 say OemtoAnsi(STR0042) of oDlgC PIXEL //Contador
		@ 040,315 MSGET aBemCount[1,2] PICTURE '@E 999,999,999' WHEN;
		aBemCount[ 1, 4 ] .And. (!FindFunction("NGBlCont") .Or. NGBlCont( aBemCount[ 1, 1 ] )) VALID;
		naovazio(aBemCount[1,2]) .And. Positivo(aBemCount[1,2]) .And. fAtuCont( @aBemCount, 2 ) SIZE 36,7 OF oDlgC PIXEL

		@ 041,355 say OemtoAnsi(STR0042+' 2') of oDlgC PIXEL //Contador 2
		@ 040,385 MSGET aBemCount[1,3] PICTURE '@E 999,999,999' WHEN aBemCount[ 1, 5 ] VALID;
		naovazio(aBemCount[1,3]) .And. Positivo(aBemCount[1,3]) .And. fAtuCont( @aBemCount, 3 ) SIZE 36,7 OF oDlgC PIXEL


		@ 056,008 say OemtoAnsi(STR0034) of oDlgC Pixel Color CLR_HBLUE //Componente
		@ 055,040 Msget aBemCount[ 2, 1 ] Picture '@!' Valid;
		ExistCpo("ST9",aBemCount[ 2, 1 ]) .And. NGACOPB(aBemCount[ 2, 1 ], 2, @aBemCount, cBTMov);
		F3 "ST9" SIZE 60,7 of oDlgC Pixel HasButton

		@ 055,105 Msget cNomCo Picture '@!' When .F. SIZE 180,7 of oDlgC Pixel

		@ 056,290 say OemtoAnsi(STR0042) of oDlgC PIXEL //Contador
		@ 055,315 MSGET aBemCount[2,2] PICTURE '@E 999,999,999' WHEN;
		aBemCount[ 2, 4 ] .And. (!FindFunction("NGBlCont") .Or. NGBlCont( aBemCount[ 2, 1 ] )) VALID;
		naovazio(aBemCount[2,2]) .And. Positivo(aBemCount[2,2]) SIZE 36,7 OF oDlgC PIXEL

		@ 056,355 say OemtoAnsi(STR0042+' 2') of oDlgC PIXEL //Contador 2
		@ 055,385 MSGET aBemCount[2,3] PICTURE '@E 999,999,999' WHEN aBemCount[ 2, 5 ] VALID;
		naovazio(aBemCount[2,3]) .And. Positivo(aBemCount[2,3]) SIZE 36,7 OF oDlgC PIXEL

		@ 071,008 say OemtoAnsi(STR0056) of oDlgC PIXEL Color CLR_HBLUE //Data Mov.
		@ 070,040 MSGET dBDMov PICTURE x3Picture("T9_DTULTAC")  VALID;
		naovazio(dBDMov) SIZE 45,7 OF oDlgC PIXEL HasButton

		@ 071,90 say OemtoAnsi(STR0057) of oDlgC PIXEL Color CLR_HBLUE //Hora
		@ 070,105 MSGET cBHMov PICTURE '99:99' VALID;
		naovazio(cBHMov) .And. NGVALHORA(cBHMov,.T.) .And. MNTESTCCB(aBemCount[ 2, 1 ], dBDMov, cBHMov) SIZE 5,7 OF oDlgC PIXEL

		@ 071,137 say OemtoAnsi(STR0059) of oDlgC Pixel Color CLR_HBLUE //Tipo Mov.
		@ 070,162 COMBOBOX cBTMov ITEMS aTMov Valid NGACOPBOX(cBTMov) SIZE 56,7 OF oDlgC PIXEL

		@ 086,008 say OemtoAnsi(STR0019) of oDlgC Pixel //Localizacao
		@ 085,040 MSGET cBLoc  Picture "@" When lLerLo Valid;
		If(Empty(cBLoc),.T.,Existcpo("TPS",cBLoc) .And. NGACOPLOC(cBLoc));
		F3 "TPS" SIZE 15,7 of oDlgC Pixel HasButton

		@ 085,075 Msget cNomLo Picture '@!' When .F. SIZE 170,7 of oDlgC Pixel

		@ 101,008 say OemtoAnsi(STR0060) of oDlgC Pixel //Motivo
		@ 100,040 MSGET cBMoti Picture "@" When lLerMo Valid;
		If(Empty(cBMoti),.T.,Existcpo("ST8",cBMoti) .And. NGACOPMOT(cBMoti));
		F3 "STN" SIZE 15,7 of oDlgC Pixel HasButton

		@ 100,075 Msget cNomMo Picture '@!' When .F. SIZE 170,7 of oDlgC Pixel

		Activate MsDialog oDlgC On Init EnchoiceBar(oDlgC,{|| nOPCA := 1,;
		If(!NGACOPF(aBemCount[ 1, 1 ],aBemCount[ 2, 1 ],,dBDMov,cBHMov,,cBTMov,cBMoti,cBLoc, aBemCount),nOPCA := 0,oDlgC:End())},{||oDlgC:End()})

		If nOpca == 0
			Exit
		Endif

		cMovBT := If(Substr(cBTMov,1,1) = "A","E","S")
		vRetes := NGESESTRF(aBemCount[ 1, 1 ],aBemCount[ 2, 1 ],,dBDMov,cBHMov,,cMovBT,cBMoti,cBLoc, ,aBemCount )
		If vRetes[1]
			aBemCount := { { cSpaceCod, 0, 0, .T., .T. }, { cSpaceCod, 0, 0, .T., .T. } }
			cBMoti  := Space(Len(ST8->T8_CODOCOR))
			cBLoc   := Space(Len(TPS->TPS_CODLOC))
			cBHMov  := Space(5)
			dBDMov  := Ctod('  /  /    ')
			nBCont  := 0
			cBTMov  := STR0054
			lLerMo  := .F.
			lLerLo  := .T.
			Store Space(1)  To cTemComp,cTemCPai
			Store Space(40) To cNomBe,cNomCo,cNomMo,cNomLo
		Endif

		//---------------------------------------------------------
		// Atualiza memória de campos que foram alterados na base
		// pela função NGTRETCON chamada dentro de NGESESTRF.
		//---------------------------------------------------------
		M->T9_POSCONT := NGSEEK("ST9",M->T9_CODBEM,1,"T9_POSCONT")
		M->T9_CONTACU := NGSEEK("ST9",M->T9_CODBEM,1,"T9_CONTACU")
		M->T9_VARDIA  := NGSEEK("ST9",M->T9_CODBEM,1,"T9_VARDIA")
		M->T9_DTULTAC := NGSEEK("ST9",M->T9_CODBEM,1,"T9_DTULTAC")
		//---------------------------------------------------------------
		// Refresh na tela para mostrar os valores de memóra atualizados.
		//---------------------------------------------------------------
		lRefresh := .T.
		If !lLeBp
			Exit
		Endif

	End
	RestArea(aAreaPl)
	RestArea(aAreaST9)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGPADACOPLA³ Autor ³Inacio Luiz Kolling   ³ Data ³10/01/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consistencia se permite acoplamento (Pai/Componente)        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cBemPesq  - Codigo do bem (Pai/Componente)    - Obrigatorio ³±±
±±³          ³cVTip     - Tipo do bem (Pai/Componente)      - Obrigatorio ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³vVRetPa  [1] .T.,.F., [2] Mensagem                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³NGACOPLAD                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGPADACOPLA(cBemPesq,cVTip)

	Local vVRetPa  := {.T.,Space(1)},cMenPad := Space(1), cFilBPai := xFilial("STC")
	Local lIntTms  := GetMV('MV_INTTMS',,.F.) //Integracao com o TMS
	Local lMntTms  := (GetMV('MV_NGMNTMS',,'N') == 'S') //Ativa integracao TMS X MNT

	NGDBAREAORDE("ST9",1)
	If lIntTms .And. lMntTms .And. !Empty(cFilBPai)
		cFilBPai := Posicione("DA3",5,xFilial("DA3")+cBemPesq,"DA3_FILBAS")
	EndIf

	If msSeek(NGTROCAFILI("ST9",cFilBPai)+cBemPesq)
		cField := If(Type("M->T9_ACOPLA")=="U","ST9","M")+"->"+"T9_ACOPLA"  //MNTA080 in call stack
		If cVTip == 'P' .AND. &(cField) == '2'
			cMenPad := STR0028+" "+STR0061+" "+STR0054
		Endif
	Else
		cMenPad := If(cVTip = "P",STR0028,STR0034)+" "+STR0025
	Endif

	If !Empty(cMenPad)
		vVRetPa := {.F.,cMenPad}
	Endif

Return vVRetPa

//-------------------------------------------------------------------
/*/{Protheus.doc} NGACOPF
Consistencia final

@author Inacio Luiz Kolling
@since  01/12/2006
@param  cBPai     , Caracter, Bem pai da estrutura
@param  cBComp    , Caracter, Componente de estrutura (E/S)
@param  [nBCont]  , Numérico, Contador do bem pai\Componente (E/S)
@param  dBDMov    , Data    , Data de entrada/saida
@param  cBHMov    , Caracter, Hora de entrada/saida
@param  [nBPCont] , Numérico, Tipo do contador (1/2)
@param  cBTMov    , Caracter, Tipo de movimentacao (E/S)
@param  cBMoti    , Caracter, Motivo da movimentacao
@param  cBLoc     , Caracter, Localizacao do componente (E)
@param  [lContPro], Lógico  , Define se possui contador próprio.
@Param  [aBemCnt] , Array   , Estrutura para validação do bem/componente
		[ 1, 1 ] - Código bem Pai  |  [ 2, 1 ] - Código Componente
		[ 1, 2 ] - Contador 1 Pai  |  [ 2, 2 ] - Contador 1 Componente
		[ 1, 3 ] - Contador 2 Pai  |  [ 2, 3 ] - Contador 2 Componente
		[ 1, 4 ] - When Contador 1 |  [ 2, 4 ] - When Contador 1
		[ 1, 5 ] - When Contador 2 |  [ 2, 5 ] - When Contador 2
@obs: Array aBemCnt utilizada somente as 3 primeiras posições;
@return Lógico, Define se o registro é consistente.
/*/
//-------------------------------------------------------------------
Function NGACOPF(cBPai,cBComp,nBCont,dBDMov,cBHMov,nBTCont,cBTMov,cBMoti,cBLoc, aBemCnt )

	Local nY := 0
	Local vRetes := { .T., '' }

	Private cAutonomia := STR0092 //"Essa posição do contador superou a autonomia do veículo."f

	Default aBemCnt := {}

	cMovBT := IIf( Substr(cBTMov,1,1) == "A","E","S")

	If !NGLANCON(CBCOMP,DBDMOV,CBHMOV,CBPAI)
		Return .F.
	EndIf

	If Len( aBemCnt ) > 0
		For nY := 1 To 2
			// Verifica histórico do contador para o Pai
			If aBemCnt[ 1, nY + 3 ] .And. !NGCHKHISTO(aBemCnt[ 1, 1 ], dBDMov, aBemCnt[ 1, nY + 1 ], cBHMov, nY ) .Or.;
				!aBemCnt[ 1, 4 ] .And. aBemCnt[ 1, 2 ] == 0 .And. !NGCHKHISTO(aBemCnt[ 1, 1 ], dBDMov, aBemCnt[ 1, nY + 1 ], cBHMov, nY )
				Return .F.
			EndIf

			// Verifica se o contador está habilitado
			If aBemCnt[ 2, nY + 3 ] .And. cTemComp == 'S'
				// Verifica histórico do contador para o componente
				If !NGCHKHISTO(aBemCnt[ 2, 1 ], dBDMov, aBemCnt[ 2, nY + 1 ], cBHMov, nY )
					Return .F.
				EndIf
				vRetes := NGESESTRC(cBPai,cBComp, aBemCnt[ 2, nY + 1 ],dBDMov,cBHMov, nY, cMovBT,cBMoti,cBLoc)
				If !vRetes[1]
					Exit
				EndIf
			EndIf
		Next nY
		
	EndIf

	If !vRetes[1]
		If cAutonomia $ vRetes[2] //"Essa posição do contador superou a autonomia do veículo."
			If !MsgYesNo(vRetes[2],STR0010) // "Essa posição do contador superou a autonomia do veículo."###"NAO CONFORMIDADE"
				Return .F.
			EndIf
		Else
			MsgInfo(vRetes[2],STR0010) // ... NAO COMFORMIDADE
			Return .F.
		EndIf
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} NGACOPB
Atribuicao de valores as variaveis

@author  Inacio Luiz Kolling
@since   01/12/2006
@version P11/P12
@param   cVCBem  , Caracter, Codigo do bem
@param   cVTip   , Caracter, Tipo do bem (Pai/Componente)
@param  [aBemCnt], Array   , Estrutura para validação do bem/componente
		[ 1, 1 ] - Código bem Pai  |  [ 2, 1 ] - Código Componente
		[ 1, 2 ] - Contador 1 Pai  |  [ 2, 2 ] - Contador 1 Componente
		[ 1, 3 ] - Contador 2 Pai  |  [ 2, 3 ] - Contador 2 Componente
		[ 1, 4 ] - When Contador 1 |  [ 2, 4 ] - When Contador 1
		[ 1, 5 ] - When Contador 2 |  [ 2, 5 ] - When Contador 2
@param   cAcopla, Caractere, Informa se vai ser feito um acoplamento ou um desacoplamento
@obs: Array aBemCnt utilizada somente as 3 primeiras posições;
/*/
//-------------------------------------------------------------------
Function NGACOPB( cVCBem, nVTip, aBemCnt, cAcopla )

	Local lPosBem := nvTip == 1

	Default aBemCnt := {}
	Default cAcopla := ''

	cTCBE := Posicione( 'ST9', 1, xFilial( 'ST9' ) + cVCBEM, 'T9_TEMCONT' )
	If nvTip == 1
		cTemCPai := cTCBE
		cNomBE   := ST9->T9_NOME
	Else
		cTemComp := cTCBE
		cNomCo   := ST9->T9_NOME
	Endif

	If Len( aBemCnt ) > 0

		If lPosBem
			// Atribui valor do contador 1
			aBemCnt[ nvTip, 2 ] := ST9->T9_POSCONT
			// Define se o campo de contador 1 será aberto para edição
			aBemCnt[ nvTip, 4 ] := ST9->T9_TEMCONT == 'S'
		Else
			// Verifica se foi informado um novo componente.
			If cBComp != aBemCnt[ 2, 1 ]
				// Zera contador
				aBemCnt[ nvTip, 2 ] := IIf( ST9->T9_TEMCONT == 'S', 0, aBemCnt[ 1, 2 ] )
				// Define se o campo de contador 1 será aberto para edição
				aBemCnt[ nvTip, 4 ] := ST9->T9_TEMCONT == 'S'
			EndIf
		EndIf

		// Carrega campo de segundo contador.
		If !Empty( Posicione('TPE', 1, xFilial( 'TPE' ) + cVCBem, 'TPE_CODBEM' ) ) .And. TPE->TPE_SITUAC == '1'

			If lPosBem
				// Atribui valor do contador 2
				aBemCnt[ nvTip, 3 ] := TPE->TPE_POSCON
				// Define se o campo de contador 2 será aberto para edição
				aBemCnt[ nvTip, 5 ] := aBemCnt[ 1, 4 ]
			Else
				// Verifica se foi informado um novo componente.
				If cBComp != aBemCnt[ 2, 1 ]
					// Zera contador
					aBemCnt[ nvTip, 3 ] := IIf( ST9->T9_TEMCONT == 'S', 0, aBemCnt[ 1, 3 ] )
					// Define se o campo de contador 2 será aberto para edição
					aBemCnt[ nvTip, 5 ] := aBemCnt[ 1, 5 ] .And. TPE->TPE_SITUAC == '1'
				EndIf
			EndIf

		Else
			aBemCnt[ nvTip, 3 ] := 0
			aBemCnt[ nvTip, 5 ] := .F.
		EndIf
		cBPai  := aBemCnt[ 1, 1 ] 
		cBComp := aBemCnt[ 2, 1 ]
	EndIf

	If !Empty(cBPai) .And. !Empty(cBComp)
		If cBPai == cBComp
			MsgInfo(STR0038+" "+STR0039+" "+STR0034,STR0010)
			Return .F.
		Endif
		If NGIFDBSEEK('ST9',cBComp,1)
			If ST9->T9_CATBEM == "3"
				ShowHelpDlg(STR0062,{STR0063},1,{STR0064},1)
				Return .F.
			Endif
		Endif
	Endif

	dbSelectArea( 'STC' )
	dbSetOrder( 1 ) // TC_FILIAL+TC_CODBEM+TC_COMPONE+TC_TIPOEST+TC_LOCALIZ+TC_SEQRELA

	If dbSeek( xFilial( 'STC' ) + aBemCnt[ 2, 1 ] + aBemCnt[ 1, 1 ] )
		
		Help( NIL, 1, STR0062, NIL, STR0095 + allTrim( aBemCnt[ 2, 1 ] ) + STR0096 + allTrim( aBemCnt[ 1, 1 ] ),;
		 1, 0, NIL, NIL, NIL, NIL, NIL, {} ) // "ATENÇÃO"###"Existe uma estrutura onde o bem "###" é pai do bem "
		
		Return .F.

	EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NGACOPMOT ³ Autor ³Inacio Luiz Kolling   ³ Data ³01/12/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atribuicao de valores as variav‚is                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cVBMot  - Codigo do motivo                    - Obrigatorio ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³NGACOPLAD                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGACOPMOT(cVBMot)

	cNomMo := NGSEEK("ST8",cVBMot,1,'T8_NOME')

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NGACOPMOT ³ Autor ³Inacio Luiz Kolling   ³ Data ³01/12/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atribuicao de valores as variav‚is                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cVBLoc  - Codigo do motivo                    - Obrigatorio ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³NGACOPLAD                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGACOPLOC(cVBLoc)

	cNomLo := NGSEEK("TPS",cVBLoc,1,'TPS_NOME')

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NGACOPBOX ³ Autor ³Inacio Luiz Kolling   ³ Data ³01/12/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atribuicao de valores as variav‚is                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cVBTMov - Codigo do tipo de movimentacao      - Obrigatorio ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³NGACOPLAD                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGACOPBOX(cVBTMov)

	lLerMo := If(Substr(cVBTMov,1,1) = "A",.F.,.T.)
	lLerLo := If(Substr(cVBTMov,1,1) = "A",.T.,.F.)
	If Substr(cVBTMov,1,1) = "A"
		cBMoti := Space(Len(ST8->T8_CODOCOR))
		cNomMo := Space(40)
	Else
		cBLoc  := Space(Len(TPS->TPS_CODLOC))
		cNomLo := Space(40)
	Endif
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGFILHOPAR³ Autor ³ Paulo Pego            ³ Data ³ 22/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna a quantidade de dias do Bem filho fora da estrutura ³±±
±±³          ³e/ou em posicao de INATIVO (pela estrutura padrao)          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCODBEM  -> Codigo do bem filho                            ³±±
±±³          ³ dINI     -> Data Inicio                                    ³±±
±±³          ³ dFIM     -> Data Fim                                       ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION NGFILHOPAR(cCODBEM, dINI, dFIM)

	Local nDIAS := 0, lSAI := .F.
	Local dSAI := dFIM

	DbSelectArea('STZ')
	DbSetOrder(2)
	DbSeek(xFilial("STZ")+cCODBEM+DTOS(dINI),.T.)
	Do While STZ->TZ_FILIAL  == xFILIAL("STZ") .and.;
	STZ->TZ_CODBEM  == cCODBEM         .and.;
	STZ->TZ_DATAMOV <= dFIM            .and.;
	!EOF()

		If !lSAI
			If STZ->TZ_TIPOMOV == "S"
				dSAI := STZ->TZ_DATASAI
				lSAI := .T.
			Endif
		Endif
		If lSAI
			If STZ->TZ_TIPOMOV == "E"
				nDIAS := nDIAS+(STZ->TZ_DATAMOV - dSAI)
				lSAI  := .F.
			Endif
		Endif
		DbSkip()
	EndDo

	If lSAI
		If STZ->TZ_TIPOMOV == "S"
			nDIAS := nDIAS  + (dFIM - dSAI)
		Endif
	Endif
	DbSelectArea('STZ')
	DbSetOrder(1)

Return nDIAS

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGVERESTRU³ Autor ³ Inacio Luiz Kolling   ³ Data ³17/01/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Faz verificacao das estruturas dos arquivos ( HISTORICOS )  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aARR1 - Vetor com os alias do(s) arquivo(s) base           ³±±
±±³          ³ aARR2 - Vetor com os alias do(s) arquivo(s) a comparar     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GENERICO                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGINTESTRU(aARR01,aARR02)

	Local aIdxTRB1 := {{"DESCRIC"}}
	Local oTmpTblHis

	Private aRotina := {{STR0065,"NGIMPESTRU",0,6}} //"IMPRIMIR"
	Private  cTRB1

	aDBF  := {{"DESCRIC","C",200,0}}

	cTRB1 := GetNextAlias()
	oTmpTblHis := fTempTable(cTRB1, aDBF, aIdxTRB1)

	processa({|lEnd| NGVERESTRU(aARR01,aARR02)},STR0066) //"Verificando Estrutura dos Arquivos..."
	dbSelectArea(cTRB1)
	dbGOTOP()

	If RECCOUNT() > 0
		aFIELD2 := {{STR0067,"DESCRIC" ,"C",200,0,"@!"}} //"Descricao do Problema da Estrutura"
		mBrowse(6,1,22,75,(cTRB1),aFIELD2)
		oTmpTblHis:Delete()
		Return .F.
	Endif

	oTmpTblHis:Delete()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGVERESTRU³ Autor ³ Inacio Luiz Kolling   ³ Data ³17/01/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Faz verificacao das estruturas dos arquivos ( HISTORICOS )  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aARR1 - Vetor com os alias do(s) arquivo(s) base           ³±±
±±³          ³ aARR2 - Vetor com os alias do(s) arquivo(s) a comparar     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GENERICO                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGVERESTRU(aARR1,aARR2)
	Local XV,XX,I
	Local cCampo

	If len(aARR1[1]) <> len(aARR2[1])
		dbSelectArea(cTRB1)
		(cTRB1)->(DbAppend())
		(cTRB1)->DESCRIC := STR0068 //"Numero De Arquivos Especificados Para Avaliar as Estrutura Estao Diferente..."
		Return
	Endif
	ProcRegua(len(aARR1[1]))

	For I := 1 to len(aARR1[1])
		Incproc()
		If Select(aARR1[1][I]) = 0
			dbSelectArea(cTRB1)
			(cTRB1)->(DbAppend())
			(cTRB1)->DESCRIC := STR0069+aARR1[1][I]+STR0070 //"ARQUIVO DE ALIAS ("###") "NAO FOI ABERTO..."
		Endif
		dbSelectArea(aARR1[1][I])
		aSX3US1 := DbStruct()
		dbSelectArea(aARR2[1][I])
		aSX3US2 := DbStruct()

		// DETERMINA O SUFIXO DO CAMPO ( TJ ...TPX..)
		If substr(aARR1[1][I],1,1) == 'T'
			cSUFIXO1 := substr(aARR1[1][I],1,3)
			cSUFIXO2 := substr(aARR2[1][I],1,3)
			nINICIO  := 4
			nFIM     := 7
		Else
			cSUFIXO1 := substr(aARR1[1][I],2,3)
			cSUFIXO2 := substr(aARR2[1][I],2,3)
			nINICIO  := 3
			nFIM     := 8
		Endif

		// LE A ESTRUTURA aSX3US1 -
		For XX := 1 TO len(aSX3US1)
			cNOMEC1 := substr(aSX3US1[XX][1],nINICIO,nFIM)
			cNOMEC2 := cSUFIXO2 +cNOMEC1
			NPOS    := ASCAN(aSX3US2,{|x| x[1] == cNOMEC2 })
			If NPOS == 0
				DbSelectArea(cTRB1)
				(cTRB1)->(DbAppend())
				(cTRB1)->DESCRIC := STR0071+cSUFIXO1+cNOMEC1+STR0072+aARR1[1][I]+STR0073+aARR2[1][I]+STR0074+cSUFIXO2+cNOMEC1+STR0075 //"Campo ( "###" )  Do "###"  Nao Tem Campo Correpondente no "###" ( "###" )"
			Else
				For XV := 2 to 4
					If aSX3US1[XX][XV] <> aSX3US2[NPOS][XV]
						cCAMPO := SPACE(7)
						IF XV == 1
							cCAMPO := STR0076 //"NOME"
						ElseIF XV == 2
							cCAMPO := STR0077 //"TIPO"
						ElseIF XV == 3
							cCAMPO := STR0078 //"TAMANHO"
						ElseIF XV == 4
							cCAMPO := STR0079 //"DECIMAL"
						Endif
						DbSelectArea(cTRB1)
						(cTRB1)->(DbAppend())
						(cTRB1)->DESCRIC := STR0080+cCampo+STR0081+aSX3US1[XX][1]  +STR0082+aARR1[1][I]+STR0083+;
						STR0080+cCampo+STR0081+aSX3US2[NPOS][1]+STR0082+aARR2[1][I]
					Endif
				Next XV
			Endif
		Next XX
	Next I
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} NGESESTR
Entrada e/ou saída de um compomente da estrutura.

@type function

@param [cBEMPES], Caracter, Bem pai da estrutura
@param [cCOMPES], Caracter, Componente de estrutura (E/S)
@param nCONTES  , Numérico, Contador do bem pai\Componente (E/S)
@param [dDATAES], Data	  , Data de entrada/saida
@param [cHORAES], Caracter, Hora de entrada/saida
@param nTPCONT  , Numérico, Tipo do contador (1/2)
@param [cTPMOES], Caracter, Tipo de movimentacao (E/S)
@param cMOTISA  , Caracter, Motivo da movimentacao
							Obs.: obrigatório quando cTPMOES = S
@param [aTrbEst], Array	  , Possui as tabelas temporárias responsáveis por montar
							a estrutura do bem.
							[1] tabela temporaria do pai da estrutura - cTRBS
							[2] tabela temporaria do pai da estrutura - cTRBF
							[3] tabela temporaria do eixo suspenso    - CTRBEixo

@author Inácio Luiz Kolling
@since 05/05/2006

@return vRetConsSTR - Vetor [1], .T.,.F. - Realizou operacao, ou nao
					        [2] mensagem
/*/
//---------------------------------------------------------------------
Function NGESESTR(cBEMPES,cCOMPES,nCONTES,dDATAES,cHORAES,nTPCONT,cTPMOES,;
	cMOTISA,cLOCLES, aTrbEst)

	Private cTemComp := Space(1),cTemCPai := Space(1)

	Default aTrbEst := {}

	vRetConSTR := NGESESTRC(cBEMPES,cCOMPES,nCONTES,dDATAES,cHORAES,nTPCONT,cTPMOES,;
	cMOTISA,cLOCLES)

	If vRetConSTR[1]

		vRetConSTR := NGESESTRF( cBEMPES, cCOMPES, nCONTES, dDATAES, cHORAES, nTPCONT, cTPMOES, cMOTISA,;
			cLOCLES, aTrbEst )
	
	Endif

Return vRetConSTR

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGCOMSTZFREC2³ Autor ³In cio Luiz Kolling  ³ Data ³23/06/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inclui os elementos filhos no vetor  (imediato)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³NGCOMSTZFREC2                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function NGCOMSTZFREC2(cVCOMP)
	Local nRec2
	While !eof() .and. (cTRBI)->icompon == cVCOMP
		nRec2  := Recno()
		cCOMP2 := (cTRBI)->icodbem
		If DbSeek(cCOMP2)
			If (cTRBI)->itipoco = "I" .And. (cTRBI)->icodbem = cBEMPAR
				lINCOMPO := .T.
				Exit
			Endif

			NGCOMSTZFREC2(cCOMP2)
			If lINCOMPO
				Exit
			Endif
		Endif

		DbGoTo(nRec2)
		DbSkip()
	End
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGCOMPREC2  ³ Autor ³In cio Luiz Kolling  ³ Data ³23/06/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inclui os elementos filhos no vetor  (pai)                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³NGCOMPIMD1                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function NGCOMPREC2(cVCOMP)
	Local nRec2
	While !eof() .and. (cTRBS)->tcodbem == cVCOMP
		nRec2  := Recno()
		cCOMP2 := (cTRBS)->tcompon
		(cTRBI)->(DbAppend())
		(cTRBI)->ICODBEM := (cTRBS)->tcodbem
		(cTRBI)->ITIPOBE := (cTRBS)->ttipobe
		(cTRBI)->ICOMPON := (cTRBS)->tcompon
		(cTRBI)->ITIPOCO := (cTRBS)->ttipoco
		(cTRBI)->IDTMOVI := (cTRBS)->tdtmovi
		(cTRBI)->ITIPOMO := (cTRBS)->ttipomo
		(cTRBI)->IDTSAID := (cTRBS)->tdtsaid
		(cTRBI)->IHORAEN := (cTRBS)->thoraen
		(cTRBI)->IHORASA := (cTRBS)->thorasa
		(cTRBI)->ILOCALI := (cTRBS)->tlocali
		DbselectArea(cTRBS)
		If DbSeek(cCOMP2)
			NGCOMPREC2(cCOMP2)
		Endif
		DbGoTo(nRec2)
		DbSkip()
	End
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGCOMSTZREC1³ Autor ³In cio Luiz Kolling  ³ Data ³23/06/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inclui os elementos filhos no vetor                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³NGCOMPFZZ                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function NGCOMSTZREC1(cVCOMP)
	Local nRec2
	While !eof() .and. (cTRBS)->tcompon == cVCOMP
		nRec2  := Recno()
		cCOMP2 := (cTRBS)->tcodbem
		If DbSeek(cCOMP2)
			If ((cTRBS)->ttipoco = "I" .And. (cTRBS)->ttipobe = "P");
			.Or. ((cTRBS)->ttipoco = "I" .And. (cTRBS)->tcodbem = cBEMPAR)
				lINCOMPO := .T.
				Exit
			Endif

			NGCOMSTZREC1(cCOMP2)
			If lINCOMPO
				Exit
			Endif
		Endif

		DbGoTo(nRec2)
		DbSkip()
	End
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGVLANRETR³ Autor ³Elisangela Costa       ³ Data ³21/08/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica movimento da estrutura de bens de acordo com dados ³±±
±±³          ³passados por paramentro de historico de contador            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cFilSTZ - Filial do STZ                        - Obrigatorio³±±
±±³          ³cVBem   - Codigo do componente                 - Obrigat¢rio³±±
±±³          ³cVBemPai- C¢digo do bem pai do lancamento retr.- Obrigatorio³±±
±±³          ³cDLEIT  - Data da leitura                      - Obrigat¢rio³±±
±±³          ³cHORAL  - Hora de leitura                      - Obrigat¢rio³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³ .T. = Se o lancamento posterior do contador o bem for      ³±±
±±³          ³ diferente do bem em que se esta fazendo o lancamento do    ³±±
±±³          ³ contador. E .F. se nao for diferente                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGVLANRETR(cFilSTZ,cVBem,cVBemPai,cDLEIT,cHORAL)

	Local lAchoMov := .F., lBemDif := .F.

	dbSelectArea("STZ")
	dbSetOrder(01)
	dbSeek(cFilSTZ+cVBem+"S")
	While !Eof() .And. STZ->TZ_FILIAL == cFilSTZ .And. STZ->TZ_CODBEM == cVBem .And.;
	STZ->TZ_TIPOMOV == "S" .And. !lAchoMov

		If cDLEIT >= STZ->TZ_DATAMOV .And. cDLEIT <= STZ->TZ_DATASAI
			If cDLEIT == STZ->TZ_DATAMOV .And. cDLEIT == STZ->TZ_DATASAI
				If cHORAL >= STZ->TZ_HORAENT .And. cHORAL <= STZ->TZ_HORASAI
					lAchoMov := .T.
					If STZ->TZ_BEMPAI <> cVBemPai
						lBemDif := .T.
					EndIf
				EndIf
			Else
				If cDLEIT >= STZ->TZ_DATAMOV
					If cDLEIT == STZ->TZ_DATAMOV
						If cHORAL >= STZ->TZ_HORAENT
							lAchoMov := .T.
							If STZ->TZ_BEMPAI <> cVBemPai
								lBemDif := .T.
							EndIf
						EndIf
					Else
						lAchoMov := .T.
						If STZ->TZ_BEMPAI <> cVBemPai
							lBemDif := .T.
						EndIf
					EndIf
				ElseIf cDLEIT <= STZ->TZ_DATASAI
					If cDLEIT == STZ->TZ_DATASAI
						If cHORAL <= STZ->TZ_HORASAI
							lAchoMov := .T.
							If STZ->TZ_BEMPAI <> cVBemPai
								lBemDif := .T.
							EndIf
						EndIf
					Else
						lAchoMov := .T.
						If STZ->TZ_BEMPAI <> cVBemPai
							lBemDif := .T.
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		dbSelectArea("STZ")
		dbSkip()
	End

	If !lAchoMov
		dbSelectArea("STZ")
		dbSetOrder(01)
		If dbSeek(cFilSTZ+cVBem+"E")
			If cDLEIT >= STZ->TZ_DATAMOV
				If cDLEIT == STZ->TZ_DATAMOV
					If cHORAL >= STZ->TZ_HORAENT
						If STZ->TZ_BEMPAI <> cVBemPai
							lBemDif := .T.
						EndIf
					EndIf
				Else
					If STZ->TZ_BEMPAI <> cVBemPai
						lBemDif := .T.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

Return lBemDif

//---------------------------------------------------------------------
/*/{Protheus.doc} NGLANCON
Verifica se existe lançamento de contador para componente controlado pelo pai da estrutura.
Validação feita, para não permitir lançamentos retroativos quando para o componente já
lançamento futuro. Seja de contador ou abastecimento.

@type function

@source NGUTIL04.PRX

@author Maicon André Pinheiro
@since 01/08/2016

@param cCodBem, Caracter, Código do componente da estrutura
@param dDataMov, Data, Data da movimentação do componente.
@param cHora, Caracter, Hora da movimentação do componente.
@param cBPai, Caracter, Código do bem pai da estrutura
@param [lShowMsg], boolean, Se apresenta mensagem para usuário

@return Lógico, retorna False se encontrou lançamento futuro, bloqueando movimentação do componente.

/*/
//---------------------------------------------------------------------
Function NGLANCON( cCodBem, dDataMov, cHora, cBPai, lShowMsg )

	Local cQuery     := ""
	Local lPossuiLan := .F.
	Local cMsg       := ""
	Local aArea      := GetArea()

	Default lShowMsg := .T.

	cAliasQry := GetNextAlias()

	cQuery := " SELECT Max(TP_DTLEITU || TP_HORA) AS MAIORDATA "
	cQuery += "   FROM " + RetSQLName("STP")
	cQuery += "  WHERE TP_FILIAL           = " + ValToSql(xFilial("STP"))
	cQuery += "    AND TP_CODBEM           = " + ValToSql(cCodBem)
	cQuery += "    AND TP_DTLEITU || TP_HORA >= " + ValToSql(dToS(dDataMov) + cHora)
	cQuery += "    AND D_E_L_E_T_          = '' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	While (cAliasQry)->(!EOF())

		If !Empty((cAliasQry)->MAIORDATA)

			cDataSTP := DtoC(StoD(SubStr((cAliasQry)->MAIORDATA,1,10)))
			cHoraSTP := SubStr((cAliasQry)->MAIORDATA,9,5)
			cMsg     := STR0084 + Chr(13)           + Chr(13) +; //"Existe lançamento de contador posterior a essa saída"
			STR0085 + cCodBem           + Chr(13) +; //"Bem...................: "
			STR0086 + dToC(dDataMov)    + Chr(13) +; //"Data Informada..: "
			STR0087 + SubStr(cHora,1,5) + Chr(13) +; //"Hora Informada..: "
			Chr(13)                               +;
			STR0088 + cBPai             + Chr(13) +; //"Bem Pai............: "
			STR0089 + cDataSTP          + Chr(13) +; //"Ult. Leitura.......: "
			STR0090 + cHoraSTP          + Chr(13) +; //"Hr do Lanc........: "
			Chr(13)                               +;
			STR0091                                  //"Favor informar um lançanmento para uma data posterior"

			lPossuiLan := .T.

		EndIf
		dbSelectArea(cAliasQry)
		dbSkip()

	End
	(cAliasQry)->(dbCloseArea())

	RestArea(aArea)

	If lPossuiLan

		If lShowMsg
			MsgInfo(cMsg,STR0010) //"Favor informar um lançado para uma data posterior"###"NAO CONFORMIDADE"
		EndIf

		Return .F.
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTPROBRE - Procura Bem Relacionado.
Procura o pai e/ou imediato conforme tipo de controle do bem

@param cBEMRE: Código do bem (Obrigatório)
@param cTPCONRE: Tipo de contador (Obrigatório)

@author Inácio Luiz Kolling
@since 10/00/2004
@version 1.0
@sample MNT
@return cBEMRET
/*/
//---------------------------------------------------------------------
Function MNTPROBRE(cBEMRE,cTPCONRE)

	Local aAreaSTC := STC->( FWGetArea() )
	Local aAreaST9 := ST9->( FWGetArea() )
	Local cVBEMAU := cBEMRE
	Local cBEMRET := Space( FWTamSX3( 'T9_CODBEM' )[1] )

	If NGIFdbSeek('STC',cVBEMAU,3)

		If cTPCONRE = 'P'
			While .T.
				If dbSeek(xFilial('STC')+cVBEMAU)
					cVBEMAU := STC->TC_CODBEM
				Else
					Exit
				EndIf
			End

			If !Empty(cVBEMAU)
				If NGIFdbSeek('ST9',cVBEMAU,1)
					If ST9->T9_TEMCONT = 'S'
						cBEMRET := cVBEMAU
					EndIf
				EndIf
			EndIf

		ElseIf cTPCONRE = 'I'

			While .T.
				
				If NGIFdbSeek('ST9',cVBEMAU,1)
					
					If ST9->T9_TEMCONT = 'S'
						
						cBEMRET := cVBEMAU
						
						Exit

					EndIf

				EndIf

				If NGIFdbSeek('STC',cVBEMAU,3)

					cVBEMAU := STC->TC_CODBEM

				Else
					
					cBEMRET := Space( Len( cVBEMAU ) )

					If NGIFdbSeek('ST9',cVBEMAU,1)

						If ST9->T9_TEMCONT = 'S'
							cBEMRET := cVBEMAU
						EndIf

					EndIf

					Exit

				EndIf

			End

		EndIf

	EndIf

	FWRestArea( aAreaSTC )
	FWRestArea( aAreaST9 )

	FWFreeArray( aAreaSTC )
	FWFreeArray( aAreaST9 )

Return cBEMRET

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTVERATV
Verifica se o bem está numa posição ativa na estrutura no período informado

@sample MNT

@param cCodBem: Código do bem a ser pesquisado (Obrigatório)
@param dData: Data em que o bem esteve na estrutura (Obrigatório)
@param cHora: Hora em que o bem esteve na estrutura (Obrigatório)

@author Wexlei Silveira
@since 30/09/2016
@version 1.0
@return True se o bem estiver ativo, False se inativo
/*/
//---------------------------------------------------------------------
Function MNTVERATV(cCodBem, dData, cHora)

	Local lRet      := .T.
	Local lSeek     := .F.
	Local cQrySTZ   := ""
	Local cAliasSTZ := GetNextAlias()
	Local aArea     := GetArea()
	Local aAreaSTC  := STC->( GetArea() )

	If Valtype(dData) == "D"
		dData := DToS(dData)
	EndIf

	cQrySTZ :=	"SELECT TZ_BEMPAI, TZ_LOCALIZ"
	cQrySTZ +=	"  FROM " + RetSQLName("STZ")
	cQrySTZ +=  " WHERE D_E_L_E_T_ <> '*'"
	cQrySTZ +=	"   AND TZ_FILIAL = " + ValToSQL(xFilial("STZ"))
	cQrySTZ +=	"   AND TZ_CODBEM = " + ValToSQL(cCodBem)
	cQrySTZ +=	"   AND ((TZ_TIPOMOV = 'E' AND TZ_DATAMOV || TZ_HORACO1 <= " + ValToSQL(dData+cHora) + ")"
	cQrySTZ +=	"     OR (TZ_TIPOMOV = 'S' AND " + ValToSQL(dData) + " BETWEEN TZ_DATAMOV AND TZ_DATASAI"
	cQrySTZ +=	"                          AND (" + ValToSQL(dData+cHora) + " < TZ_DATASAI || TZ_HORASAI )))"

	cQrySTZ := ChangeQuery(cQrySTZ)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQrySTZ), cAliasSTZ, .F., .T.)
	dbSelectArea(cAliasSTZ)

	If !(cAliasSTZ)->( EoF() )

		dbSelectArea("ST9")
		dbSetOrder(1)
		If dbseek( xFilial("ST9") + (cAliasSTZ)->TZ_BEMPAI )

			If lRel12133
				lSeek := MNTSeekPad( 'STC', 6, Padr( ST9->T9_CODFAMI, TamSx3('TC_CODBEM')[1]), ST9->T9_TIPMOD, 'F' + (cAliasSTZ)->TZ_LOCALIZ )
			Else
				dbSelectArea('STC')
				dbSetOrder(6) // TC_FILIAL+TC_CODBEM+TC_TIPMOD+TC_TIPOEST+TC_LOCALIZ
				lSeek := dbSeek( xFilial('STC') + Padr( ST9->T9_CODFAMI, TamSx3('TC_CODBEM')[1]) + ST9->T9_TIPMOD + 'F' + (cAliasSTZ)->TZ_LOCALIZ )
			EndIf

			//------------------------------------------------------------------------------
			// A regra para não repassar contador é ter um cadastro e o campo de ativo = 'N'
			//------------------------------------------------------------------------------
			lRet := !( lSeek .And. STC->TC_MANUATI == 'N' )

		EndIf

	EndIf

	(cAliasSTZ)->(DbCloseArea())
	RestArea(aAreaSTC)
	RestArea(aArea)

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fTempTable
Cria tabelas temporarias
@author douglas.constancio
@since 24/02/2017
@version undefined
@param cAliasTmp, characters, cAlias ta tabela temporaria
@param aField   , array     , array de campos da tabela
@param aIndex   , array     , indice da tabela
@type function
/*/
//---------------------------------------------------------------------
Static Function fTempTable(cAliasTmp, aField, aIndex)

	Local nIdx
	Local oTempTbl

	//Intancia classe FWTemporaryTable
	oTempTbl  := FWTemporaryTable():New( cAliasTmp, aField )
	//Cria Indices para tabela temporaria
	For nIdx := 1 To Len(aIndex)
		oTempTbl:AddIndex( "Ind"+cValToChar(nIdx) , aIndex[nIdx] )
	Next
	//Cria objeto
	oTempTbl:Create()

Return oTempTbl
//---------------------------------------------------------------------
/*/{Protheus.doc} MNTESTCCB
Carrega o valor do contador do bem se o campo estiver bloqueado

@param cCobBem: Código do bem
@param dData: Data
@param cHora: Hora
@author Wexlei Silveira
@since 05/12/2017
@return True
/*/
//---------------------------------------------------------------------
Static Function MNTESTCCB(cCobBem, dData, cHora)

	If FindFunction("NGBlCont") .And. !NGBlCont( cCobBem )
		nBCont := NGTpCont(cCobBem, dData, cHora)
	EndIf

Return .T.

//--------------------------------------------------------------------------------------------------
/*/{Proteus.doc} MntUpdCC
Verifica se o bem é pai de estrutura, assim realizando a alteração de C.C. e C.T. juntamente
com o repasse para seus filhos.
@type function

@author Alexandre Santos
@since  17/10/2019

@sample MntUpdCC( 'BEM0001' )

@param  cCode  , Caracter, Código do bem.
@param  cKeyTAF, Caracter, Chave para posicionamento na localização pai. ( TAF - Índice 1 )
@return Array  , 	[1] - Centro de custos atualizado do bem.
					[2] - Centro de trabalho atualizado do bem.
/*/
//------------------------------------------------------------------------------------------------
Function MntUpdCC( cCode, cKeyTAF )

	Local aStruct   := {}
	Local aRet      := {}
	Local aAreaTAF  := TAF->( GetArea() )
	Local aAreaST9  := ST9->( GetArea() )
	Local aAreaSTC  := STC->( GetArea() )
	Local cOldCostC := ''
	Local cOldWorkC := ''
	Local cNewCostC := ''
	Local cNewWorkC := ''
	Local cHour     := SubStr( Time(), 1, 5 )
	Local lFather   := .F.
	Local nIndex    := 0

	// CASO O BEM NÃO ESTEJA DENTRO DE UMA ESTRUTURA
	dbSelectArea( 'ST9' )
	dbSetOrder( 1 )
	If dbSeek( xFilial( 'ST9' ) + cCode ) .And. ( ST9->T9_ESTRUTU == 'N' .And. ST9->T9_MOVIBEM == 'S' )

		// BUSCA SE O BEM É PAI DE ALGUMA ESTRUTURA.
		dbSelectArea( 'STC' )
		dbSetOrder( 1 ) // TC_FILIAL + TC_CODBEM + TC_TIPMOD + TC_COMPONE + TC_TIPOEST + TC_LOCALIZ + TC_SEQRELA
		If dbSeek( xFilial( 'STC' ) + ST9->T9_CODBEM )

			aStruct := NGCompEst( cCode, 'B', .T., .T., .T. )

			// ATUALIZA CENTRO DE CUSTOS DO BEM PAI E SEUS COMPONENETES.
			For nIndex := 1 to Len( aStruct )

				dbSelectArea( 'ST9' )
				dbSetOrder( 1 )
				If dbSeek( xFilial( 'ST9' ) + aStruct[nIndex,1] )

					cOldCostC := ST9->T9_CCUSTO
					cOldWorkC := ST9->T9_CENTRAB

					// PERMITE MOVIMENTAÇÃO DE C.C.
					If ST9->T9_MOVIBEM == 'S'

						// CASO NÃO POSSUA PAI, CONSIDERA ESTE COMO PAI DA ESTRUTURA.
						If Empty( aStruct[nIndex,6] )

							// DEFINE QUE ESTE BEM É O PAI DA ESTRUTURA.
							lFather := .T.

							// QUANDO PAI DA ESTRUTURA, RECUPERA C.C. DA LOCALIZAÇÃO ONDE ESTE BEM ESTÁ.
							dbSelectArea( 'TAF' )
							dbSetOrder( 2 ) // TAF_FILIAL + TAF_CODEST + TAF_CODNIV + TAF_NOMNIV
							If dbSeek( cKeyTAF )

								cNewCostC := TAF->TAF_CCUSTO
								cNewWorkC := TAF->TAF_CENTRA

							EndIf

						Else

							// CASO SEJA UM COMPONENTE, RECUPERA O C.C. DO PAI IMEDIATO NA ESTRUTURA.
							dbSelectArea( 'ST9' )
							dbSetOrder( 1 )
							If dbSeek( xFilial( 'ST9' ) + aStruct[nIndex,6] )

								cNewCostC  := ST9->T9_CCUSTO
								cNewWorkC  := ST9->T9_CENTRAB

							EndIf

						EndIf

						// VERIFICA SE REALMENE HOUVE ALTERAÇÃO DE C.C. OU C.T.
						If !Empty( cNewCostC ) .And. ( cOldCostC != cNewCostC .Or. cOldWorkC != cNewWorkC )

							// REALIZA A ATUALIZAÇÃO DO C.C. E C.T. NO BEM PASSADO POR PARÂMETRO GERANDO O REGISTRO NA TPN.
							NGRETCC( aStruct[nIndex,1], dDataBase, cNewCostC, cNewWorkC, cHour, 'D', '', .F. )

						// SE O PAI DA ESTRUTURA NÃO SOFREU ALTERAÇÃO, ENCERRA O PROCESSO.
						ElseIf lFather

							Exit

						EndIf

					EndIf

				EndIf

			Next nIndex

		Else

			cOldCostC := ST9->T9_CCUSTO
			cOldWorkC := ST9->T9_CENTRAB

			// QUANDO PAI DA ESTRUTURA, RECUPERA C.C. DA LOCALIZAÇÃO ONDE ESTE BEM ESTÁ.
			dbSelectArea( 'TAF' )
			dbSetOrder( 2 ) // TAF_FILIAL + TAF_CODEST + TAF_CODNIV
			If dbSeek( cKeyTAF )

				cNewCostC := TAF->TAF_CCUSTO
				cNewWorkC := TAF->TAF_CENTRA

			EndIf

			// VERIFICA SE REALMENE HOUVE ALTERAÇÃO DE C.C. OU C.T.
			If !Empty( cNewCostC ) .And. ( cOldCostC != cNewCostC .Or. cOldWorkC != cNewWorkC )

				// REALIZA A ATUALIZAÇÃO DO C.C. E C.T. NO BEM PASSADO POR PARÂMETRO GERANDO O REGISTRO NA TPN.
				NGRETCC( ST9->T9_CODBEM, dDataBase, cNewCostC, cNewWorkC, cHour, 'D', '', .F. )

			EndIf

		EndIf

	EndIf

	aAdd( aRet, IIf( !Empty( cNewCostC ), cNewCostC, cOldCostC ) )
	aAdd( aRet, IIf( !Empty( cNewWorkC ), cNewWorkC, cOldWorkC ) )

	RestArea( aAreaST9 )
	RestArea( aAreaSTC )
	RestArea( aAreaTAF )

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fAtuCont
Atualiza contador

@author Eduardo Mussi
@since  23/03/2020
@Param  [aBemCnt], Array   , Estrutura para validação do bem/componente
		[ 1, 1 ] - Código bem Pai  |  [ 2, 1 ] - Código Componente
		[ 1, 2 ] - Contador 1 Pai  |  [ 2, 2 ] - Contador 1 Componente
		[ 1, 3 ] - Contador 2 Pai  |  [ 2, 3 ] - Contador 2 Componente
		[ 1, 4 ] - When Contador 1 |  [ 2, 4 ] - When Contador 1
		[ 1, 5 ] - When Contador 2 |  [ 2, 5 ] - When Contador 2
@param  nPosCont, Numerico, Define qual contador será atualizado.
							O numero é com base no array aBemCnt.
							2 = Primeiro Contador
							3 = Segundo contador
/*/
//-------------------------------------------------------------------
Static Function fAtuCont( aBem, nPosCont )

	If cTemComp != 'S' .And. !Empty( aBem[ 2, 1 ]  )
		If nPosCont == 3
			If !Empty( Posicione('TPE', 1, xFilial( 'TPE' ) + aBem[ 2, 1 ], 'TPE_CODBEM' ) ) .And. TPE->TPE_SITUAC == '1'
				aBem[ 2, nPosCont ] := aBem[ 1, nPosCont ]
			EndIf
		Else
			aBem[ 2, nPosCont ] := aBem[ 1, nPosCont ]
		EndIf

	EndIf

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} MNTIntTMS
Função de integração SIGAGFR x SIGATMS.
@type function

@author Alexandre Santos
@since  09/03/2023

@param  aEstrut, array  , Lista de bens para estrutura.
			[1] - Informações do Bem Pai
				[1] - Código do bem
				[2] - Contador próprio
			[2] - Informações do 1° Reboque
				[1] - Código do bem
				[2] - Contador próprio
			[3] - Informações do 2° Reboque
				[1] - Código do bem
				[2] - Contador próprio
			[4] - Informações do 3° Reboque
				[1] - Código do bem
				[2] - Contador próprio
@param  lEstorn, boolean, Indica se o processo trata-se de um estorno.
@param  dDtCont, date   , Data de leitura do contador.
@param  cHrCont, string , Hora de leitura do contador.
@param  nProces, int    , Indica o processo: 
							1 - Montagem, 2 - Desmontagem e 3 - O.S. Auto.
@param  aTrbEst, array  , Tabelas temporárias necessárias para o processo.
		
@param boolean, Indica se o processo ocorreu corretamente.
/*/
//------------------------------------------------------------------------------
Function MNTIntTMS( aEstrut, lEstorn, dDtCont, cHrCont, nProces, aTrbEst )

	Local lRet := .T.
	
	Do Case

		Case nProces == 1

			/*----------------------------------------------------------------+
			| Processo de montagem da estrutura para saída em viagem SIGATMS. |
			+----------------------------------------------------------------*/
			lRet := fEntEstrut( aEstrut, lEstorn, dDtCont, cHrCont, aTrbEst )

		Case nProces == 2
			
			/*---------------------------------------------------------------------+
			| Processo de desmontagem da estrutura após chegada de viagem SIGATMS. |
			+---------------------------------------------------------------------*/
			lRet := fSaiEstrut( aEstrut, lEstorn, dDtCont, cHrCont, aTrbEst )

		Case nProces == 3

			/*-------------------------------------------------------+
			| Processo de geração de O.S. automática para estrutura. |
			+-------------------------------------------------------*/
			fOSAutEstr( aEstrut, aTrbEst )

	End Case

	
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} fEntEstrut
Processo de montagem da estrutura para viagem SIGATMS.
@type function

@author Alexandre Santos
@since  09/03/2023

@param  aEstrut, array  , Lista de bens para estrutura.
			[1] - Informações do Bem Pai
				[1] - Código do bem
				[2] - Contador próprio
			[2] - Informações do 1° Reboque
				[1] - Código do bem
				[2] - Contador próprio
			[3] - Informações do 2° Reboque
				[1] - Código do bem
				[2] - Contador próprio
			[4] - Informações do 3° Reboque
				[1] - Código do bem
				[2] - Contador próprio
@param  lEstorn, boolean, Indica se o processo trata-se de um estorno.
@param  dDtCont, date   , Data de leitura do contador.
@param  cHrCont, string , Hora de leitura do contador.
@param  aTrbEst, array  , Tabelas temporárias necessárias para o processo.
		
@param boolean, Indica se o processo ocorreu corretamente.
/*/
//------------------------------------------------------------------------------
Static Function fEntEstrut( aEstrut, lEstorn, dDtCont, cHrCont, aTrbEst )

	Local lRet      := .T.
	Local lFi1CtPro := .F.
	Local lFi2CtPro := .F.
	Local lFi3CtPro := .F.

	aEstrut[1,1] := PadR( aEstrut[1,1], FWTamSX3( 'T9_CODBEM' )[1] )

	If lEstorn

		/*--------------------------+
		| Estorno pai da estrutura. |
		+--------------------------*/ 
		MNT470EXCO( aEstrut[1,1], dDtCont, cHrCont, 1, aTrbEst )

		If Len( aEstrut ) > 1 .And. ( lFi1CtPro := Posicione( 'ST9', 1,;
			FWxFilial( 'ST9' ) + aEstrut[2,1], 'T9_TEMCONT' ) == 'S' )

			/*-----------------------------------------+
			| Estorno 1° reboque com contador proprio. |
			+-----------------------------------------*/
			MNT470EXCO( aEstrut[2,1], dDtCont, cHrCont, 1, aTrbEst )

		EndIf

		If Len( aEstrut ) > 2 .And. ( lFi2CtPro := Posicione( 'ST9', 1,;
			FWxFilial( 'ST9' ) + aEstrut[3,1], 'T9_TEMCONT' ) == 'S' )

			/*-----------------------------------------+
			| Estorno 2° reboque com contador proprio. |
			+-----------------------------------------*/
			MNT470EXCO( aEstrut[3,1], dDtCont, cHrCont, 1, aTrbEst )

		EndIf

		If Len( aEstrut ) > 3 .And. ( lFi3CtPro := Posicione( 'ST9', 1,;
			FWxFilial( 'ST9' ) + aEstrut[4,1], 'T9_TEMCONT' ) == 'S' )
			
			/*-----------------------------------------+
			| Estorno 3° reboque com contador proprio. |
			+-----------------------------------------*/
			MNT470EXCO( aEstrut[4,1], dDtCont, cHrCont, 1, aTrbEst )

		EndIf

	ElseIf Len( aEstrut ) < 2

		/*-------------------------------------------------------+
		| Reporte de contador do veículo que não possui reboque. |
		+-------------------------------------------------------*/ 
		lRet := MntInfCnt( aEstrut[1,1], dDtCont, cHrCont, 1, aEstrut[1,2] )

	EndIf

	/*---------------------------------------+
	| Processo de acoplamento do 1° reboque. |
	+---------------------------------------*/ 
	If lRet .And. Len( aEstrut ) > 1

		aEstrut[2,1] := PadR( aEstrut[2,1], FWTamSX3( 'T9_CODBEM' )[1] )
		lFi1CtPro    := Posicione( 'ST9', 1, FWxFilial( 'ST9' ) + aEstrut[2,1], 'T9_TEMCONT' ) == 'S'

		If lEstorn

			/*-----------------------------------------------------------------------------+
			| Incrementa em 1 min, pois a saída da estrutura deve ser posterior a entrada. |
			+-----------------------------------------------------------------------------*/ 
			SomaDiaHor( @dDtCont, @cHrCont, HoraToInt( '00:01' ) )

		EndIf

		dbSelectArea( 'STC' )
		dbSetOrder( 3 ) // TC_FILIAL + TC_COMPONE + TC_CODBEM
		If !msSeek( FWxFilial( 'STC' ) + aEstrut[2,1] + aEstrut[1,1] ) //-- Verifica a existencia da estrutura

			/*---------------------------------------------------------+
			| Monta estrutura com o 1° reboque e reporta seu contador. |
			+---------------------------------------------------------*/	
			aError := NGESESTR( aEstrut[1,1], aEstrut[2,1], aEstrut[1,2], dDtCont, cHrCont, 1, 'E', , , aTrbEst )
		
			If !aError[1]

				Help( '', 1, 'TMSXFUNA40', , aError[2], 3, 1 ) // Nao foi atualizado o Odometro do Bem

				lRet := .F.

			Else

				If lEstorn

					/*------------------------------------------------------------------+
					| Estorno 1° reboque com contador controlado pelo pai da estrutura. |
					+------------------------------------------------------------------*/
					MNT470EXCO( aEstrut[1,1], dDtCont, cHrCont, 1, aTrbEst )

					lRet := .T.

				ElseIf lFi1CtPro

					/*-------------------------------------------+
					| Reporte de contador proprio do 1° reboque. |
					+-------------------------------------------*/
					lRet := MntInfCnt( aEstrut[2,1], dDtCont, cHrCont, 1, aEstrut[2,2] )
				
				EndIf

			EndIf

		EndIf

	EndIf

	/*---------------------------------------+
	| Processo de acoplamento do 2° reboque. |
	+---------------------------------------*/ 
	If lRet .And. Len( aEstrut ) > 2

		aEstrut[3,1] := PadR( aEstrut[3,1], FWTamSX3( 'T9_CODBEM' )[1] )
		lFi2CtPro    := Posicione( 'ST9', 1, FWxFilial( 'ST9' ) + aEstrut[3,1], 'T9_TEMCONT' ) == 'S'

		If !lEstorn .And. !lFi2CtPro

			/*------------------------------------------------------------------------------------------+
			| Exclui contador do 1° reboque, pois será gerado um novo registro ao acoplar o 2° reboque. |
			+------------------------------------------------------------------------------------------*/
			MNT470EXCO( aEstrut[1,1], dDtCont, cHrCont, 1, aTrbEst )

		EndIf
			
		dbSelectArea( 'STC' )
		dbSetOrder( 3 ) // TC_FILIAL + TC_COMPONE + TC_CODBEM
		If !msSeek( FWxFilial( 'STC' ) + aEstrut[3,1] + aEstrut[1,1] )

			/*---------------------------------------------------------+
			| Monta estrutura com o 2° reboque e reporta seu contador. |
			+---------------------------------------------------------*/	
			aError := NGESESTR( aEstrut[1,1], aEstrut[3,1], aEstrut[1,2], dDtCont, cHrCont, 1, 'E', , , aTrbEst )

			If !aError[1]

				Help( '', 1, 'TMSXFUNA40', , aError[2], 3, 1 ) // Nao foi atualizado o Odometro do Bem

				lRet := .F.

			Else

				If lEstorn

					/*------------------------------------------------------------------+
					| Estorno 2° reboque com contador controlado pelo pai da estrutura. |
					+------------------------------------------------------------------*/
					MNT470EXCO( aEstrut[1,1], dDtCont, cHrCont, 1, aTrbEst )

					lRet := .T.
				
				ElseIf lFi2CtPro
					
					/*-------------------------------------------+
					| Reporte de contador proprio do 2° reboque. |
					+-------------------------------------------*/
					lRet := MntInfCnt( aEstrut[3,1], dDtCont, cHrCont, 1, aEstrut[3,2] )
				
				EndIf

			EndIf

		EndIf

	EndIf

	/*---------------------------------------+
	| Processo de acoplamento do 3° reboque. |
	+---------------------------------------*/ 
	If lRet .And. Len( aEstrut ) > 3

		aEstrut[4,1] := PadR( aEstrut[4,1], FWTamSX3( 'T9_CODBEM' )[1] )
		lFi3CtPro    := Posicione( 'ST9', 1, FWxFilial( 'ST9' ) + aEstrut[4,1], 'T9_TEMCONT' ) == 'S'

		If !lEstorn .And. !lFi3CtPro

			/*------------------------------------------------------------------------------------------+
			| Exclui contador do 2° reboque, pois será gerado um novo registro ao acoplar o 3° reboque. |
			+------------------------------------------------------------------------------------------*/
			MNT470EXCO( aEstrut[1,1], dDtCont, cHrCont, 1, aTrbEst )

		EndIf

		dbSelectArea( 'STC' )
		dbSetOrder( 3 ) // TC_FILIAL + TC_COMPONE + TC_CODBEM
		If !msSeek( FWxFilial( 'STC' ) + aEstrut[4,1] + aEstrut[1,1] )

			/*---------------------------------------------------------+
			| Monta estrutura com o 3° reboque e reporta seu contador. |
			+---------------------------------------------------------*/	
			aError := NGESESTR( aEstrut[1,1], aEstrut[4,1], aEstrut[1,2], dDtCont, cHrCont, 1, 'E', , , aTrbEst )

			If !aError[1]

				Help( '', 1, 'TMSXFUNA40', , aError[2], 3, 1 ) // Nao foi atualizado o Odometro do Bem

				lRet := .F.

			Else

				If lEstorn

					/*------------------------------------------------------------------+
					| Estorno 3° reboque com contador controlado pelo pai da estrutura. |
					+------------------------------------------------------------------*/
					MNT470EXCO( aEstrut[1,1], dDtCont, cHrCont, 1, aTrbEst )

					lRet := .T.
				
				ElseIf lFi3CtPro

					/*-------------------------------------------+
					| Reporte de contador proprio do 3° reboque. |
					+-------------------------------------------*/
					lRet := MntInfCnt( aEstrut[4,1], dDtCont, cHrCont, 1, aEstrut[4,2] )
				
				EndIf

			EndIf

		EndIf

	EndIf
	
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} fSaiEstrut
Processo de desmontagem da estrutura para viagem SIGATMS.
@type function

@author Alexandre Santos
@since  09/03/2023

@param  aEstrut, array  , Lista de bens para estrutura.
			[1] - Informações do Bem Pai
				[1] - Código do bem
				[2] - Contador próprio
			[2] - Informações do 1° Reboque
				[1] - Código do bem
				[2] - Contador próprio
			[3] - Informações do 2° Reboque
				[1] - Código do bem
				[2] - Contador próprio
			[4] - Informações do 3° Reboque
				[1] - Código do bem
				[2] - Contador próprio
@param  lEstorn, boolean, Indica se o processo trata-se de um estorno.
@param  dDtCont, date   , Data de leitura do contador.
@param  cHrCont, string , Hora de leitura do contador.
@param  aTrbEst, array  , Tabelas temporárias necessárias para o processo.
		
@param boolean, Indica se o processo ocorreu corretamente.
/*/
//------------------------------------------------------------------------------
Static Function fSaiEstrut( aEstrut, lEstorn, dDtCont, cHrCont, aTrbEst )

	Local aError    := {}
	Local cTMSREST  := SuperGetMv( 'MV_TMSREST', .F., '' )
	Local lRet      := .T.
	Local lFi1CtPro := .F.
	Local lFi2CtPro := .F.
	Local lFi3CtPro := .F.

	If lEstorn
		
		/*------------------------------------+
		| Estorno de contador para o bem pai. |
		+------------------------------------*/
		MNT470EXCO( aEstrut[1,1], dDtCont, cHrCont, 1, aTrbEst )

		If Len( aEstrut ) > 1
		
			If ( lFi1CtPro := Posicione( 'ST9', 1, FWxFilial( 'ST9' ) + aEstrut[2,1], 'T9_TEMCONT' ) == 'S' )

				/*-------------------------------------------------------+
				| Estorno apontamento do contador proprio do 1° reboque. |
				+-------------------------------------------------------*/
				MNT470EXCO( aEstrut[2,1], dDtCont, cHrCont, 1, aTrbEst )

			EndIf

		EndIf

		If Len( aEstrut ) > 2
		
			If ( lFi2CtPro := Posicione( 'ST9', 1, FWxFilial( 'ST9' ) + aEstrut[2,1], 'T9_TEMCONT' ) == 'S' )

				/*-------------------------------------------------------+
				| Estorno apontamento do contador proprio do 2° reboque. |
				+-------------------------------------------------------*/
				MNT470EXCO( aEstrut[3,1], dDtCont, cHrCont, 1, aTrbEst )

			EndIf

		EndIf

		If Len( aEstrut ) > 3
		
			If ( lFi3CtPro := Posicione( 'ST9', 1, FWxFilial( 'ST9' ) + aEstrut[4,1], 'T9_TEMCONT' ) == 'S' )

				/*-------------------------------------------------------+
				| Estorno apontamento do contador proprio do 3° reboque. |
				+-------------------------------------------------------*/
				MNT470EXCO( aEstrut[4,1], dDtCont, cHrCont, 1, aTrbEst )

			EndIf

		EndIf

	ElseIf Len( aEstrut ) < 2

		/*---------------------------------------------+
		| Reporte de contador para o bem sem reboques. |
		+---------------------------------------------*/
		lRet := MntInfCnt( aEstrut[1,1], dDtCont, cHrCont, 1, aEstrut[1,2] )
		
	EndIf

	/*---------------------------------------+
	| Processo de acoplamento do 1° reboque. |
	+---------------------------------------*/ 
	If lRet .And. Len( aEstrut ) > 1
		
		aEstrut[2,1] := PadR( aEstrut[2,1], FWTamSX3( 'T9_CODBEM' )[1] )
		lFi1CtPro    := Posicione( 'ST9', 1, FWxFilial( 'ST9' ) + aEstrut[2,1], 'T9_TEMCONT' ) == 'S'

		If lEstorn

			/*-----------------------------------------------------------------------------+
			| Incrementa em 1 min, pois a saída da estrutura deve ser posterior a entrada. |
			+-----------------------------------------------------------------------------*/ 
			SomaDiaHor( @dDtCont, @cHrCont, HoraToInt( '00:01' ) )

		EndIf

		/*----------------------------------+
		| Desmonta estrutura do 1° reboque. |
		+----------------------------------*/	
		aError := NGESESTR( aEstrut[1,1], aEstrut[2,1], aEstrut[1,2], dDtCont, cHrCont, 1, 'S', cTMSREst, , aTrbEst )
		
		If !aError[1]
			
			Help( '', 1, 'TMSXFUNA40', , aError[2], 3, 1 ) // Nao foi atualizado o Odometro do Bem

			lRet := .F.

		Else

			If lEstorn

				/*------------------------------------------------------------------+
				| Estorno 1° reboque com contador controlado pelo pai da estrutura. |
				+------------------------------------------------------------------*/
				MNT470EXCO( aEstrut[1,1], dDtCont, cHrCont, 1, aTrbEst )
					
				lRet := .T.

			ElseIf lFi1CtPro

				/*-------------------------------------------+
				| Reporte de contador proprio do 1° reboque. |
				+-------------------------------------------*/
				lRet := MntInfCnt( aEstrut[2,1], dDtCont, cHrCont, 1, aEstrut[2,2] )
					
			EndIf

		EndIf

	EndIf

	/*---------------------------------------+
	| Processo de acoplamento do 2° reboque. |
	+---------------------------------------*/ 
	If lRet .And. Len( aEstrut ) > 2
		
		aEstrut[2,1] := PadR( aEstrut[3,1], FWTamSX3( 'T9_CODBEM' )[1] )
		lFi2CtPro    := Posicione( 'ST9', 1, FWxFilial( 'ST9' ) + aEstrut[3,1], 'T9_TEMCONT' ) == 'S'

		If !lEstorn .And. !lFi2CtPro

			/*------------------------------------------------------------------------------------------+
			| Exclui contador do 1° reboque, pois será gerado um novo registro ao acoplar o 2° reboque. |
			+------------------------------------------------------------------------------------------*/
			MNT470EXCO( aEstrut[1,1], dDtCont, cHrCont, 1, aTrbEst )

		EndIf

		/*-------------------------------------+
		| Desmonta estrutura com o 2° reboque. |
		+-------------------------------------*/
		aError := NGESESTR( aEstrut[1,1], aEstrut[3,1], aEstrut[1,2], dDtCont, cHrCont, 1, 'S', cTMSREst, , aTrbEst )
		
		If !aError[1]
			
			Help( '', 1, 'TMSXFUNA40', , aError[2], 3, 1 ) // Nao foi atualizado o Odometro do Bem

			lRet := .F.

		Else

			If lEstorn
				
				/*------------------------------------------------------------------+
				| Estorno 2° reboque com contador controlado pelo pai da estrutura. |
				+------------------------------------------------------------------*/
				MNT470EXCO( aEstrut[1,1], dDtCont, cHrCont, 1, aTrbEst )
				
				lRet := .T.

			ElseIf lFi2CtPro

				/*-------------------------------------------+
				| Reporte de contador proprio do 3° reboque. |
				+-------------------------------------------*/
				lRet := MntInfCnt( aEstrut[3,1], dDtCont, cHrCont, 1, aEstrut[3,2] )
					
			EndIf

		EndIf

	EndIf

	/*---------------------------------------+
	| Processo de acoplamento do 3° reboque. |
	+---------------------------------------*/ 
	If lRet .And. Len( aEstrut ) > 3
		
		aEstrut[2,1] := PadR( aEstrut[4,1], FWTamSX3( 'T9_CODBEM' )[1] )
		lFi3CtPro    := Posicione( 'ST9', 1, FWxFilial( 'ST9' ) + aEstrut[4,1], 'T9_TEMCONT' ) == 'S'

		If !lEstorn .And. !lFi3CtPro

			/*------------------------------------------------------------------------------------------+
			| Exclui contador do 1° reboque, pois será gerado um novo registro ao acoplar o 2° reboque. |
			+------------------------------------------------------------------------------------------*/
			MNT470EXCO( aEstrut[1,1], dDtCont, cHrCont, 1, aTrbEst )

		EndIf

		/*---------------------------------------------------------+
		| Desmonta estrutura com o 3° reboque e reporta seu contador. |
		+---------------------------------------------------------*/	
		aError := NGESESTR( aEstrut[1,1], aEstrut[4,1], aEstrut[1,2], dDtCont, cHrCont, 1, 'S', cTMSREst, , aTrbEst )
		
		If !aError[1]
			
			Help( '', 1, 'TMSXFUNA40', , aError[2], 3, 1 ) // Nao foi atualizado o Odometro do Bem

			lRet := .F.

		Else

			If lEstorn

				/*------------------------------------------------------------------+
				| Estorno 3° reboque com contador controlado pelo pai da estrutura. |
				+------------------------------------------------------------------*/
				MNT470EXCO( aEstrut[1,1], dDtCont, cHrCont, 1, aTrbEst )

				lRet := .T.

			ElseIf lFi3CtPro

				/*-------------------------------------------+
				| Reporte de contador proprio do 3° reboque. |
				+-------------------------------------------*/
				lRet := MntInfCnt( aEstrut[4,1], dDtCont, cHrCont, 1, aEstrut[4,2] )
					
			EndIf

		EndIf

	EndIf
	
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} fOSAutEstr
Gera O.S. automática para a estrutura que chega de viagem SIGATMS.
@type function

@author Alexandre Santos
@since  09/03/2023

@param  aEstrut, array  , Lista de bens para estrutura.
			[1] - Informações do Bem Pai
				[1] - Código do bem
				[2] - Contador próprio
			[2] - Informações do 1° Reboque
				[1] - Código do bem
				[2] - Contador próprio
			[3] - Informações do 2° Reboque
				[1] - Código do bem
				[2] - Contador próprio
			[4] - Informações do 3° Reboque
				[1] - Código do bem
				[2] - Contador próprio
@param  aTrbEst, array  , Tabelas temporárias necessárias para o processo.
/*/
//------------------------------------------------------------------------------
Static Function fOSAutEstr( aEstrut, aTrbEst )

	Local aAreaST9 := ST9->( FWGetArea() )
	Local nCntAux  := 0

	If SuperGetMv( 'MV_NGGERPR', .F., 'N' ) == 'S'

		/*----------------------------------+
		| Gera O.S. automática para bem pai |
		+----------------------------------*/
		NGGEROSAUT( aEstrut[1,1], aEstrut[1,2], Nil, aTrbEst )

		If Len( aEstrut ) > 1

			/*-------------------------------------------------+
			| Verifica se o 1° reboque possui contador próprio |
			+-------------------------------------------------*/
			If Posicione( 'ST9', 1, FWxFilial( 'ST9' ) + aEstrut[2,1], 'T9_TEMCONT' ) == 'S'

				nCntAux := aEstrut[2,2]
			
			Else

				nCntAux := Posicione( 'ST9', 1, FWxFilial( 'ST9' ) + aEstrut[2,1], 'T9_POSCONT' )

			EndIf
			
			/*---------------------------------------+
			| Gera O.S. automática para o 1° reboque |
			+---------------------------------------*/
			NGGEROSAUT( aEstrut[1,1], nCntAux, aEstrut[2,1], aTrbEst )

		EndIf

		If Len( aEstrut ) > 2

			/*-------------------------------------------------+
			| Verifica se o 2° reboque possui contador próprio |
			+-------------------------------------------------*/
			If Posicione( 'ST9', 1, FWxFilial( 'ST9' ) + aEstrut[3,1], 'T9_TEMCONT' ) == 'S'

				nCntAux := aEstrut[3,2]
			
			Else

				nCntAux := Posicione( 'ST9', 1, FWxFilial( 'ST9' ) + aEstrut[3,1], 'T9_POSCONT' )

			EndIf

			/*---------------------------------------+
			| Gera O.S. automática para o 2° reboque |
			+---------------------------------------*/
			NGGEROSAUT( aEstrut[1,1], nCntAux, aEstrut[3,1], aTrbEst )

		EndIf

		If Len( aEstrut ) > 3

			/*-------------------------------------------------+
			| Verifica se o 3° reboque possui contador próprio |
			+-------------------------------------------------*/
			If Posicione( 'ST9', 1, FWxFilial( 'ST9' ) + aEstrut[4,1], 'T9_TEMCONT' ) == 'S'

				nCntAux := aEstrut[4,2]
			
			Else

				nCntAux := Posicione( 'ST9', 1, FWxFilial( 'ST9' ) + aEstrut[4,1], 'T9_POSCONT' )

			EndIf
			
			/*---------------------------------------+
			| Gera O.S. automática para o 3° reboque |
			+---------------------------------------*/
			NGGEROSAUT( aEstrut[1,1], nCntAux, aEstrut[4,1], aTrbEst )

		EndIf

	EndIf

	FWRestArea( aAreaST9 )

	FWFreeArray( aAreaST9 )
	
Return
