#INCLUDE "MNTP050.ch"
#INCLUDE "PROTHEUS.CH"
#include "msgraphi.ch"

//----------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MNTP050
Monta array para Painel de Gestao Tipo 2 padrao 2, Analise de Ordens de Serviço. 
@type function

@author Elisangela Costa
@since 05/03/2007

@sample MNTP050()

@param 
@return aRetPanel, Array, Array[1]  , Caracter       , Tipo do gráfico.
						  Array[2,1], Caracter       , Titulo do gráfico.
                          Array[2,2], Bloco de Código, Executado no click do gráfico.
                          Array[2,3], Array          , Atributos do eixo X.                          
                          Array[2,4], Array          , Atributos do eixo Y.                          
                          Array[3,1], Caracter       , Titulo da tabela.
                          Array[3,2], Bloco de codigo, Executado no click da tabela. 
                          Array[3,3], Array          , Contém os array por filtro. {"filtro",aCabec,aValores}
/*/
//--------------------------------------------------------------------------------------------------------------

Function MNTP050()

	Local aArea            := GetArea()
	Local aAreaSTJ         := STJ->( GetArea() )
	Local aAreaSTS         := STS->( GetArea() )
	Local aAreaST9         := ST9->( GetArea() )
	Local aRetPanel        := {}
	Local cMensagem1       := ''
	Local aTipoOs          := {}
	Local aTable           := {}
	Local aQtdOs           := {}
	Local aTitle           := { STR0001,STR0002,STR0003,STR0004 }  //OS###Tipo OS###Bem/Localização###Descrição

	Private aVetAbertas    := {}
	Private aVetConcluidas := {}
	Private aVetPendente   := {}
	Private aVetCancelada  := {}

	Pergunte("MNTP050",.F.)

	BeginSql Alias "TRBSTJ"
		Select STJ.TJ_ORDEM,STJ.TJ_CODBEM,STJ.TJ_SITUACA,STJ.TJ_TERMINO,STJ.TJ_TIPOOS
		From %table:STJ% STJ
		Where STJ.TJ_FILIAL = %xFilial:STJ%
				And (STJ.TJ_DTMPINI >= %Exp:mv_par01% And STJ.TJ_DTMPINI <= %Exp:mv_par02%)
				And STJ.%NotDel%
		Order by STJ.TJ_ORDEM,STJ.TJ_CODBEM
	EndSql

	BeginSql Alias "TRBSTS"
		Select STS.TS_ORDEM,STS.TS_CODBEM,STS.TS_SITUACA,STS.TS_TERMINO,STS.TS_TIPOOS
		From %table:STS% STS
		Where STS.TS_FILIAL = %xFilial:STS%
				And (STS.TS_DTMPINI >= %Exp:mv_par01% And STS.TS_DTMPINI <= %Exp:mv_par02%)
				And STS.%NotDel%
		Order by STS.TS_ORDEM,STS.TS_CODBEM
	EndSql

	dbSelectArea("TRBSTJ")
	dbGotop()
	While !Eof()
		MNTP50GAR( TRBSTJ->TJ_CODBEM, TRBSTJ->TJ_ORDEM, TRBSTJ->TJ_SITUACA, TRBSTJ->TJ_TERMINO, TRBSTJ->TJ_TIPOOS )
		dbSkip()
	End
	dbSelectArea("TRBSTJ")
	dbCloseArea()

	dbSelectArea("TRBSTS")
	dbGotop()
	While !Eof()
		MNTP50GAR( TRBSTS->TS_CODBEM, TRBSTS->TS_ORDEM, TRBSTS->TS_SITUACA, TRBSTS->TS_TERMINO, TRBSTS->TS_TIPOOS )
		dbSkip()
	End
	dbSelectArea("TRBSTS")
	dbCloseArea()

	cMensagem1 := STR0007 + chr(13)+chr(10)  //"Ordens de Serviço"
	cMensagem1 += chr(13) + chr(10)

	If !Empty(aVetAbertas)
		Aadd(aTipoOs,STR0008)  //"Abertas"
		Aadd(aTable ,{aTipoOs[Len(aTipoOs)] , aTitle, aVetAbertas})
		Aadd(aQtdOs ,Len(aVetAbertas))

		cMensagem1 += STR0008+": "+Alltrim(Str(Len(aVetAbertas)))+chr(13)+chr(10)   //"Abertas"

	EndIf

	If !Empty(aVetConcluidas)
		Aadd(aTipoOs,STR0009)  //"Concluídas"
		Aadd(aTable ,{aTipoOs[Len(aTipoOs)] , aTitle, aVetConcluidas})
		Aadd(aQtdOs ,Len(aVetConcluidas))

		cMensagem1 += STR0009+": "+Alltrim(Str(Len(aVetConcluidas)))+chr(13)+chr(10)   //"Concluídas"

	EndIf

	If !Empty(aVetPendente)
		Aadd(aTipoOs,STR0010)  //"Pendentes"
		Aadd(aTable ,{aTipoOs[Len(aTipoOs)] , aTitle, aVetPendente})
		Aadd(aQtdOs ,Len(aVetPendente))

		cMensagem1 += STR0010+": "+Alltrim(Str(Len(aVetPendente)))+chr(13)+chr(10)   //"Pendentes"

	EndIf

	If !Empty(aVetCancelada)
		Aadd(aTipoOs,STR0011)  //"Canceladas"
		Aadd(aTable ,{aTipoOs[Len(aTipoOs)] , aTitle, aVetCancelada})
		Aadd(aQtdOs ,Len(aVetCancelada))

		cMensagem1 += STR0011+": "+Alltrim(Str(Len(aVetCancelada))) //"Canceladas"

	EndIf

	//Complementa o array com informacoes nulas, caso nao haja informacao p/ ser exibida
	If Empty(aTable)
		aAdd( aTipoOs, '' )
		aAdd( aTable , { aTipoOs[1], aTitle, {{'', '', '', ''}} } )
	EndIf

	//Preenche array do Painel de Gestao
	aRetPanel := {GRP_PIE, {STR0007,{ || MsgInfo(cMensagem1) },aTipoOs,aQtdOs},;  //"Ordens de Serviço"
							{STR0007,/*bClickT*/, aTable }}  //"Ordens de Serviço"

	RestArea(aAreaSTJ)
	RestArea(aAreaSTS)
	RestArea(aAreaST9)
	RestArea(aArea)

Return aRetPanel

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNTP50GAR ³ Autor ³ Elisangela Costa      ³ Data ³07/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Grava valores na array                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cCodbem   => Codigo do Bem                                  ³±±
±±³          ³nOrdem50  => Ordem de Servico                               ³±±
±±³          ³cSituac   => Situacao da O.s                                ³±±
±±³          ³cTermin   => Termino da O.s                                 ³±±
±±³          ³cTipoOs   => Tipo da Os (Bem ou Localizacao)                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTP050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTP50GAR(cCodbem,nOrdem50,cSituac,cTermin,cTipoOs)

//Abertas para serem feitas no periodo independente da situacao
Aadd(aVetAbertas,{nOrdem50,cTipoOs,cCodbem,If(cTipoOs == "B",NGSEEK("ST9",cCodbem,1,"T9_NOME"),;
     NGSEEK("TAF","X2"+Substr(cCodbem,1,3),7,"TAF_NOMNIV"))} )

//Pendentes no periodo (Com Situacao pendente e liberada)
If (cSituac = "L" .Or. cSituac = "P") .And. cTermin = "N"
   Aadd(aVetPendente,{nOrdem50,cTipoOs,cCodbem,If(cTipoOs == "B",NGSEEK("ST9",cCodbem,1,"T9_NOME"),;
        NGSEEK("TAF","X2"+Substr(cCodbem,1,3),7,"TAF_NOMNIV"))} )
EndIf

//Concluidas no periodo
If cSituac = "L" .And. cTermin = "S"
   Aadd(aVetConcluidas,{nOrdem50,cTipoOs,cCodbem,If(cTipoOs == "B",NGSEEK("ST9",cCodbem,1,"T9_NOME"),;
        NGSEEK("TAF","X2"+Substr(cCodbem,1,3),7,"TAF_NOMNIV"))} )
EndIf

//Canceladas no periodo
If cSituac = "C"
   Aadd(aVetCancelada,{nOrdem50,cTipoOs,cCodbem,If(cTipoOs == "B",NGSEEK("ST9",cCodbem,1,"T9_NOME"),;
        NGSEEK("TAF","X2"+Substr(cCodbem,1,3),7,"TAF_NOMNIV"))} )
EndIf

Return .T.