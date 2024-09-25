#Include "Protheus.ch"
#Include "FWADAPTEREAI.CH"

#DEFINE _nVERSAO 1 //Versao do fonte

#DEFINE _TOTAL_CAMPOS_ARQUIVO_ 12 // Indica total de campos que o arquivo de importação deve ter

#DEFINE _RESIDUO_     "1"
#DEFINE _DESTINO_     "2"
#DEFINE _LOCALIZACAO_ "3"

//---------------------------------------------------------------------
/*/{Protheus.doc} SGAA151
Função para integração com aplicativo uMov.me para registro de 
ocorrência de resíduos - SGA

@param String cXML: indica xml que contém informações do arquivo 
importado/exportado
@author André Felipe Joriatti
@since 12/11/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------

Function SGAA151( cXML )

	Local aRegistros  := {}
	Local cErro       := ""
	Local cAviso      := ""
	Local nPosLinha   := 0
	Local dOcorrencia := Nil
	Local nPosCodRes  := Nil
	Local nPosCodDes  := Nil
	Local nPosQtd     := Nil
	Local nPosUniMed  := Nil
	Local nPosCodOco  := Nil
	Local nI          := 0
	Local nT          := 0
	Local aColsIns    := {}
	Local nSaveSX8SQT := GETSX8LEN() // Recupera a quantidade de números atualmente registrados
	Local aRetorno    := { .T.,"" }

	Private aCols     := {}
	Private aHeader   := {}
	Private cOco      := ""
	Private cCodEst   := ""
	Private aLocal    := {}

	Default cXML := ""

	// Default cXML := "<UmovImport>"
		    // cXML += "<FileName>Registro_Ocorrencia.csv</FileName>"
		    // cXML += "<IPAddress>192.168.0.167</IPAddress>"
		    // cXML += "<FTPPort>10</FTPPort>"
    	    // cXML += "<Directory>D:\AP118\Protheus_Data\umov\ap_ss\import\Registro_Ocorrencia.csv</Directory>"
    	    // cXML += "<RelativeDirectory>D:\AP118\Protheus_Data\umov\ap_ss\import</RelativeDirectory>"
		    // cXML += "</UmovImport>"

	oXml := XmlParser( cXML,"_",@cErro,@cAviso )

	If XmlChildEx( oXml,"_UMOVIMPORT" ) != Nil

		If ( nHandle := FT_FUSE( AllTrim( oXml:_UmovImport:_RelativeDirectory:Text + ;
			 "\" + oXml:_UmovImport:_FileName:Text ) ) ) < 1 // Abertura do arquivo de leitura
			lRet := .F.
			aRetorno[1] := .F.
			aRetorno[2] := "Não foi possível abrir o arquivo."
		Else

			nTot := FT_FLASTREC()
			FT_FGOTOP() // Posiciona na linha de cabeçalho

			// Pula linhas do cabeçalho
			FT_FSKIP()
			FT_FSKIP()

			BEGIN TRANSACTION

				While !FT_FEOF()

					If Len( FT_FREADLN() ) < 1023
						cLinhaAtu := FT_FREADLN()
					Else
						cLinhaAtu := ""
						lExecute := .T.
						While lExecute
							lExecute  := !( Len( FT_FREADLN() ) < 1023 )
							cLinhaAtu += FT_FREADLN()
						End While
					EndIf

					aLinha := NGEXPLSTR( DECodeUTF8( cLinhaAtu ),";" )
					If Len( aLinha ) == _TOTAL_CAMPOS_ARQUIVO_ // Valida tamanho total de campos que a linha deve possuir
						aAdd( aRegistros,aLinha )
					EndIf

					FT_FSKIP()
				End While
				FT_FUSE() // Fecha arquivo de leitura

			END TRANSACTION

		EndIf

		DbSelectArea( "TB0" ) // Ocorrências
		DbSelectArea( "TB4" ) // Destinos da Ocorrencia
		DbSelectArea( "TBJ" ) // Localização da Ocorrência

		nI := 1

		While nI <= Len( aRegistros )

			cIdOcorr := aRegistros[nI][1]

			FillGetDados( 3,"TB4",1,"TB4->TB4_CODOCO",{ || }, { || .T. },{ "TB4_CODOCO","TB4_CODRES" },,,,;
				{ || NGMontaAcols( "TB4",Space( TAMSX3( "TB0_CODOCO" )[1] ),"" ) } )

			cOco  := GETSXENUM( "TB0","TB0_CODOCO" ) // Essa variável é chamada pelo relação do campo TB0_CODOCO

			While nI <= Len( aRegistros ) .And. cIdOcorr == aRegistros[nI][1]

				Do Case

					Case aRegistros[nI][3] == _RESIDUO_ // Somente 1

						dOcorrencia := STOD( SubStr( aRegistros[nI][9],1,4 ) + ; // YYYY
										SubStr( aRegistros[nI][9],6,2 ) + ; // MM
											SubStr( aRegistros[nI][9],9,2 ) ) // DD

						DbSelectArea( "TB0" )
						RegToMemory( "TB0",.T. )
						cCodRes := PadR( aRegistros[nI][5],TAMSX3( "B1_COD" )[1] )
						M->TB0_DATA   := dOcorrencia
						M->TB0_HORA   := aRegistros[nI][10]
						M->TB0_CODRES := cCodRes
						M->TB0_QTDE   := Val( aRegistros[nI][7] )
						M->TB0_UNIMED := NGSEEK( "SB1",cCodRes,01,"SB1->B1_UM" )
						M->TB0_FATOR  := Val( aRegistros[nI][8] )
						M->TB0_ORIGE2 := "UMOV.ME"

					Case aRegistros[nI][3] == _LOCALIZACAO_ // Somente 1

						DbSelectArea( "TBJ" )
						aLocal := {} // // Variável utilizada pela função Sg150Grava para alimentar o campo TBJ_CODNIV
						aAdd( aLocal,{ SubStr( aRegistros[nI][5],4,3 ),.T. } )
						cCodEst := SubStr( aRegistros[nI][5],1,3 ) // Variável utilizada pela função Sg150Grava para alimentar o campo TBJ_CODEST

					Case aRegistros[nI][3] == _DESTINO_ // Pode ser mais de 1

						DbSelectArea( "TB4" )
						// Campos do aCols que serão preenchidos:
						// nPosCodRes := GDFIELDPOS( "TB4_CODRES",aHeader )
						nPosCodDes := GDFIELDPOS( "TB4_CODDES",aHeader )
						nPosQtd    := GDFIELDPOS( "TB4_QUANTI",aHeader )
						nPosUniMed := GDFIELDPOS( "TB4_UNIMED",aHeader )
						// nPosCodOco := GDFIELDPOS( "TB4_CODOCO",aHeader )

						aColsIns := BLANKGETD( aHeader )
						aAdd( aCols,Array( Len( aColsIns[1] ) ) )
						For nT := 1 To Len( aColsIns[1] )
							aCols[Len( aCols )][nT] := aColsIns[1][nT]
						Next nT
						nPosLinha := Len( aCols )

						//aCols[nPosLinha][nPosCodRes] := cCodRes
						aCols[nPosLinha][nPosCodDes] := aRegistros[nI][5]
						aCols[nPosLinha][nPosQtd]    := Val( aRegistros[nI][12] )
						aCols[nPosLinha][nPosUniMed] := NGSEEK( "TB2",aCols[nPosLinha][nPosCodDes],01,"TB2->TB2_UNIMED" )
						//aCols[nPosLinha][nPosCodOco] := cOco

				EndCase

				nI++
			End While

			// Grava registro de Ocorrência Ambiental
			If Sg150Grava( 3 ) // Grava registro de Registro de Ocorrência

				CONFIRMSX8()

				While ( GETSX8LEN() > nSaveSX8SQT )
					CONFIRMSX8()
				End While
			Else
				RollBackSX8()
			EndIf

			aHeader := {}
			aCols   := {}

		End While

	ElseIf XmlChildEx( oXml,"_UMOVEXPORT" ) != Nil
		// Para processamentos a serem realizados nos processos de exportação envolvendo 
		// aplicação de Solicitação de Serviço
	EndIf

Return aRetorno