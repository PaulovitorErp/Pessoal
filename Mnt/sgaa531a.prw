#include 'Protheus.ch'
#include 'FWMVCDEF.ch'
#include 'Totvs.Ch'
#Include 'SGAA531.ch'

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} sgaa531a
Classe de evento do MVC Disposição Final.

@author  Bruno Lobo de Souza
@since   28/03/2018
@type    Class
/*/
//-------------------------------------------------------------------------------------------------------------
Class sgaa531a From FWModelEvent

	Data aTB4Sch AS ARRAY INIT {}

    Method New() CONSTRUCTOR
    Method BeforeTTS(oModel) //Method executado antes do Commit
	Method MovEst() //Execução da Movimentação de Estoque
	Method GridLinePosVld(oSubModel, cModelID, nLine) //Method executado na validação da linha do grid.
	Method ModelPosVld(oModel, cModelId) //Method executado após a validação.

End Class

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Method New para criação da estancia entre o evento e as classes.

@author  Bruno Lobo de Souza
@since   28/03/2018
@type    Method
/*/
//-------------------------------------------------------------------------------------------------------------
Method New() Class sgaa531a
	::aTB4Sch := {}
Return

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Method BeforeTTS para gravações antes da transação

@author  Bruno Lobo de Souza
@since   28/03/2018
@type    Method
/*/
//-------------------------------------------------------------------------------------------------------------
Method BeforeTTS( oModel ) Class sgaa531a

	Local lRet := .T.
	Local nOperation := oModel:GetOperation()
	Local lIntEst	 := SuperGetMv( "MV_NGSGAES", .F., "N" ) == "S"

	BEGIN TRANSACTION

		If nOperation == MODEL_OPERATION_INSERT
			dbSelectArea( cTRBSEL )
			dbGoTop()
			While !Eof()
				//Altera carga da ocorrencia
				dbSelectArea( "TB0" )
				dbSetOrder( 1 )
				If dbSeek( xFilial( "TB0" ) + (cTRBSEL)->TRB_CODOCO )
					RecLock( "TB0", .F. )
					TB0->TB0_QTDDES += (cTRBSEL)->TRB_PESOTO
					MsUnlock( "TB0" )
				Endif
				dbSelectArea( cTRBSEL )
				dbSkip()
			End
			//Requisição
			If lIntEst
				lRet := ::MovEst()
			EndIf

		ElseIf nOperation == MODEL_OPERATION_DELETE
			dbSelectArea( "TH4" )
			dbSetOrder( 1 )
			dbSeek( xFilial( "TH4" ) + M->TH3_CODCOM )
			While !Eof() .And. TH4->TH4_FILIAL + TH4->TH4_CODCOM == xFilial( "TH4" ) + M->TH3_CODCOM
				//Restaura carga da ocorrencia
				dbSelectArea( "TB0" )
				dbSetOrder( 1 )
				If dbSeek( xFilial( "TB0" ) + TH4->TH4_CODOCO )
					RecLock( "TB0", .F. )
					TB0->TB0_QTDDES -= TH4->TH4_PESOUT
					MsUnlock( "TB0" )
				Endif
				dbSelectArea( "TH4" )
				dbSkip()
			End

			//Estorno
			If lIntEst
				lRet := ::MovEst(.T.)
			EndIf
		EndIf

	END TRANSACTION

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} MovEst
Gera movimentação de residuos no estoque

@author  Bruno Lobo de Souza
@since   15/03/2018

@sample  fMovEst(3)

@param   nOpcx, numeric, tipo de operação (inclusão, alteração, etc...)

@type    Method
/*/
//-------------------------------------------------------------------
Method MovEst( lEstorno ) Class sgaa531a

	Local nOco
	Local i
	Local nLoc
	Local lRet			:= .T.
	Local oModel		:= FWModelActive()
	Local oModelTH3		:= oModel:GetModel("FORMTH3")
	Local oModelTH4		:= oModel:GetModel("GRIDTH4")
	Local cDocumSD3		:= NextNumero( "SD3", 2, "D3_DOC", .T. )
	Local cCodDes		:= ""
	Local aLocEst		:= {}
	Local lError		:= .F.
	Local lLocDes		:= .F.
	Local aSaveLines	:= FwSaveRows()

	Local aCols			:= {}
	Local aSim			:= { "TB4_CODOCO", "TB4_CODDES", "TB4_DESCDE", "TB4_QUANTI",;
								"TB4_UNIMED", "TB4_LOTECT", "TB4_NUMLOT", "TB4_DTVALI" }

	Private aHeader		:= {}
	Default lEstorno	:= .F.

	aHeader := CabecGetD( "TB4", {} )

	If lEstorno
		BEGIN TRANSACTION
			dbSelectArea("SD3")
			dbSetOrder(2)
			dbSeek( xFilial("SD3") + oModelTH3:GetValue("TH3_DOC") )
			While SD3->( !EoF() ) .And. SD3->D3_FILIAL == xFilial("SD3") .And.;
					SD3->D3_DOC == oModelTH3:GetValue("TH3_DOC")
				//Faz baixa no estoque
				aNumSeqD := SgMovEstoque( "RE0", SD3->D3_LOCAL, SD3->D3_COD,, SD3->D3_UM, SD3->D3_QUANT, SD3->D3_EMISSAO,;
											SD3->D3_DOC, SD3->D3_LOTECTL, SD3->D3_NUMLOTE, SD3->D3_DTVALID, .T. )

				//Se der erro desfaz tudo
				If aNumSeqD[2]
					lRet := .F.
					DisarmTransaction()
					lError := .T.
					Exit
				EndIf
				dbSelectArea( "SD3" )
				dbSkip()
			EndDo
		END TRANSACTION
	Else
		If Len( ::aTB4Sch ) > 0
			aCols := aClone( ::aTB4Sch )
			::aTB4Sch := {}
		Else
			aHeader := CabecGetD( "TB4", {} )

			For nOco := 1 To oModelTH4:Length()
				aLocEst := {}
				oModelTH4:GoLine( nOco )
				dbSelectArea( "TB4" )
				dbSetOrder( 1 )
				dbSeek( xFilial( "TB4" ) + oModelTH4:GetValue( "TH4_CODOCO" ) )
				While !Eof() .And. xFilial( "TB4" ) + oModelTH4:GetValue( "TH4_CODOCO" ) == TB4->TB4_FILIAL + TB4->TB4_CODOCO
					aAdd( aLocEst, BlankGetD( aHeader )[1] )
					For i := 1 To Len( aSim )
						nPos := GdFieldPos( aSim[i] )
						If nPos > 0
							If aSim[i] == "TB4_CODOCO"
								aLocEst[Len(aLocEst)][nPos] := TB4->TB4_CODOCO
							ElseIf aSim[i] == "TB4_CODDES"
								aLocEst[Len(aLocEst)][nPos] := TB4->TB4_CODDES
							ElseIf aSim[i] == "TB4_QUANTI"
								aLocEst[Len(aLocEst)][nPos] := TB4->TB4_CODDES
							ElseIf aSim[i] == "TB4_DESCDE"
								dbSelectArea("TB2")
								dbSetOrder(1)
								If dbSeek(xFilial("TB2")+TB4->TB4_CODDES)
									If TB2->TB2_TIPO == "1"
										aLocEst[Len(aLocEst)][nPos] := TB2->TB2_DESLOC
									Else
										aLocEst[Len(aLocEst)][nPos] := SA2->A2_NOME
									Endif
								Endif
							ElseIf aSim[i] == "TB4_UNIMED"
								aLocEst[Len(aLocEst)][nPos] := oModelTH4:GetValue( "TH4_UNIMED" )
							Endif
						Endif
					Next i
					dbSelectArea( "TB4" )
					dbSkip()
				End

				If Len( aLocEst ) > 1
					For nLoc := 1 To Len( aLocEst )
						aAdd( aCols, aClone( aLocEst ) )
					Next nLoc
				EndIf
			Next nOco
		EndIf

		BEGIN TRANSACTION
			nPosLoc	:= 0
			nPosOco	:= GdFieldPos("TB4_CODOCO")
			nPosDes	:= GdFieldPos("TB4_CODDES")
			nPosLot	:= GdFieldPos("TB4_LOTECT")
			nPosNum	:= GdFieldPos("TB4_NUMLOT")
			nPosDtv	:= GdFieldPos("TB4_DTVALI")
			For nOco := 1 To oModelTH4:Length()
				lLocDes := .F.
				oModelTH4:GoLine(nOco)
				While ( nPosLoc := aScan( aCols, { |x| x[nPosOco] == oModelTH4:GetValue("TH4_CODOCO") } ) ) > 0 .Or. !lLocDes
					lLocDes := .T.
					dbSelectArea("TB4")
					dbSetOrder(1)
					If dbSeek( xFilial("TB4") + oModelTH4:GetValue("TH4_CODOCO") + If( nPosLoc > 0, aCols[nPosLoc,nPosDes], "" ) )
						If nPosLoc > 0
							cCodDes := aCols[nPosLoc][nPosDes]
							cLote	:= aCols[nPosLoc][nPosLot]
							cNumLot := aCols[nPosLoc][nPosNum]
							dDtVali	:= aCols[nPosLoc][nPosDtv]
						Else
							cCodDes := TB4->TB4_CODDES
							cLote	:= TB4->TB4_LOTECT
							cNumLot := TB4->TB4_NUMLOT
							dDtVali	:= TB4->TB4_DTVALI
						EndIf
						cCodDes := NGSEEK( "TB2", cCodDes, 1, "TB2->TB2_CODALM" )
						cCodRes := Posicione( "TB0", 1, xFilial("TB0") + oModelTH4:GetValue("TH4_CODOCO"), "TB0_CODRES" )
						dbSelectArea("SB1")
						dbSetOrder(1)
						dbSeek( xFilial("SB1") + cCodRes )
						cCodDes := If( Empty(cCodDes), SB1->B1_LOCPAD, cCodDes )
						//Faz baixa no estoque
						aNumSeqD := SgMovEstoque( "RE0", cCodDes, cCodRes,, SB1->B1_UM, oModelTH4:GetValue("TH4_PESOUT"), dDataBase,;
													cDocumSD3, cLote, cNumLot, dDtVali,, .F. )
						//Se der erro desfaz tudo
						If aNumSeqD[2]
							lRet := .F.
							DisarmTransaction()
							lError := .T.
							Exit
						EndIf
						If nPosLoc > 0
							aDel( aCols, nPosLoc )
							aSize( aCols, Len( aCols ) - 1 )
						EndIf
					EndIf
				EndDo
				If lError
					Exit
				EndIf
			Next nOco
		END TRANSACTION

		oModelTH3:SetValue( "TH3_DOC", cDocumSd3 )

		FwRestRows( aSaveLines )
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GridLinePosVld
Valida linha da grid de ococrrências

@author	Bruno Lobo de Souza
@since	15/03/2018

@sample	GridLinePosVld(oSubModel, cModelID, nLine)

@param	oSubModel, object, Modelo principal
@param	cModelId, caracter, Id do submodelo
@param	nLine, numeric, Linha do grid

@type    Method
/*/
//-------------------------------------------------------------------
Method GridLinePosVld(oSubModel, cModelID, nLine) Class sgaa531a

	Local lRet		:= .T.
	Local oModel	:= FWModelActive()
	Local oModelTH3 := oModel:GetModel( "FORMTH3" )

	Local cCodRes := Posicione("TB0", 1, xFilial("TB0") + oSubModel:GetValue("TH4_CODOCO"), "TB0_CODRES")

	If cModelID == "GRIDTH4" .And. !Empty(oModelTH3:GetValue("TH3_CODTIP"))
		dbSelectArea("TB7")
		dbSetOrder(1)
		If !dbSeek(xFilial("TB7") + cCodRes + oModelTH3:GetValue("TH3_TIPDES") + oModelTH3:GetValue("TH3_CODTIP") )
			lRet := .F.
			Help( ,, 'Help',, STR0016 +;
				CRLF + CRLF + STR0017, 1, 0 )
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld

description

@type    Method

@author  Bruno Lobo de Souza
@since   07/05/18
@version 12.1.17

@param   oModel, object, param_descr
@param   cModelId, caracter, param_descr

@return lRet, boolean, caso a validação seja correspondida retorna verdadeiro
/*/
//-------------------------------------------------------------------
Method ModelPosVld(oModel, cModelId) Class sgaa531a

	Local lRet		:= .T.
	Local oModelTH3 := oModel:GetModel( "FORMTH3" )
	Local oModelTH4	:= oModel:GetModel( "GRIDTH4" )
	Local cCodRes	:= Posicione("TB0", 1, xFilial("TB0") + oModelTH4:GetValue("TH4_CODOCO"), "TB0_CODRES")

	dbSelectArea("TB7")
	dbSetOrder(1)
	If !dbSeek(xFilial("TB7") + cCodRes + oModelTH3:GetValue("TH3_TIPDES") + oModelTH3:GetValue("TH3_CODTIP") )
		lRet := .F.
		Help( ,, 'Help',, STR0016 +;
			CRLF + CRLF + STR0017, 1, 0 )
	EndIf

Return lRet