#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "topconn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"




WSSERVICE UWS008 DESCRIPTION "Integração Protheus X Fluig"

/////////////////////////////////////////////////////////////////////////////
///////////////////////   MÉTODOS DE CONSULTA       /////////////////////////
/////////////////////////////////////////////////////////////////////////////


WSDATA		EntCargos			    as Cargos
WSDATA 		RetCargos			    as ListaRetCargos
WSMETHOD    ConsultaCargos        DESCRIPTION "Consulta Cargos"

ENDWSSERVICE

/////////////////////////////////////////////////////////////////////////////////////
//////////////////     CONSULTA DE Cargos            ////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////


WSSTRUCT Cargos

	WSDATA 		cDescricao			as String OPTIONAL

ENDWSSTRUCT

WSSTRUCT ListaRetCargos

	WSDATA 		cRetorno			as String
	WSDATA 		aCargos   		    as Array of StructRetCargos	OPTIONAL

ENDWSSTRUCT

WSSTRUCT StructRetCargos

	WSDATA 		cCodigo				as String
	WSDATA 		cDescricao			as String

ENDWSSTRUCT


WSMETHOD ConsultaCargos WSRECEIVE EntCargos WSSEND RetCargos WSSERVICE UWS008

	Local aArea		:= GetArea()
	Local aRetorno	:= {}
	Local oDadosEnt := Nil
	Local oDadosRet	:= Nil
	Local oStructCC := Nil
	Local cEOL 		:= Chr(13)+Chr(10)
	Local cQry		:= ""
	Local cMsgRet	:= ""

	oDadosEnt := EntCargos
	oDadosRet := RetCargos

	Conout("############ Web Services para Consulta de Cargos ############")


	cQry := " SELECT TOP 30 RJ_FUNCAO, RJ_DESC, RJ_CBO, RJ_CARGO  " + cEOL
	cQry += "  FROM SRJ010                                        " + cEOL
	cQry += "  WHERE D_E_L_E_T_ = ' '                             " + cEOL

	if !empty(AllTrim(oDadosEnt:cDescricao))

		cQry += " AND RJ_DESC LIKE '%"+AllTrim(oDadosEnt:cDescricao)+"%'  " + cEOL

	endif

//	cQry += " AND CTT_FILIAL = '"+xFilial("CTT")+"' 				     " + cEOL

	If Select("QRYSRJ") > 0
		QRYSRJ->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "QRYSRJ"

	if QRYSRJ->( !Eof() )

		While QRYSRJ->( !Eof() )

			oStructCC	:= NIL
			oStructCC 	:= WsClassNew("StructRetCargos")

			oStructCC:cCodigo		:= QRYSRJ->RJ_FUNCAO
			oStructCC:cDescricao	:= QRYSRJ->RJ_DESC

			aAdd(aRetorno,oStructCC)

			QRYSRJ->( DbSkip() )

		EndDo


		cMsgRet	:= " Consulta realizada com sucesso!"
		Conout(cMsgRet)
		oDadosRet:cRetorno := cMsgRet
		oDadosRet:aCargos := aRetorno

	else

		cMsgRet	:= "Não foi encontrado o Cargo nos parametros informados"
		oDadosRet:cRetorno := cMsgRet
		Conout(cMsgRet)

	endif

	RestArea(aArea)

Return(.T.)
