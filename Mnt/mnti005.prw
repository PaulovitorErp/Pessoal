#INCLUDE "mnti005.ch"
#include "rwmake.ch"
#include "topconn.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "FILEIO.CH"

Static __cLocation     := ""
Static __cSPIssuerName := ""

#define ENTER chr(13)+chr(10)

//Variaveis da Ordem do Array de Opcoes
#DEFINE __POS_OPCSUP__ 01
#DEFINE __POS_OPCPER__ 02
#DEFINE __POS_OPCTIP__ 03
#DEFINE __POS_OPCPAN__ 04

//Variaveis da Ordem do Array de Perguntas
#DEFINE __POS_NIVSUP__ 01
#DEFINE __POS_CODNIV__ 02
#DEFINE __POS_DESCRI__ 03
#DEFINE __POS_PERGUN__ 04
#DEFINE __POS_TIPO__ 05
#DEFINE __POS_PERGOP__ 06
#DEFINE __POS_MARCAD__ 07
#DEFINE __POS_IMAGEM__ 08
#DEFINE __POS_OBJTXT__ 09
#DEFINE __POS_PAIANT__ 10

//------------------------------------------------------------------------
/*/{Protheus.doc} PORTALNG
Portal de Inclusใo de Solicita็ใo de Servi็o
Aciona Primeira pแgina

@author Ricardo Dal Ponte
@since 14/12/2006
@source SIGAMNT
@param lReconect, boolean, se deve acionar pแgina de reconectar - timeout
@return string, html para login
/*/
//-------------------------------------------------------------------------
Web Function PORTALNG(lReconect)

	Local cHtml     := ""

	Private cEmpAnt := ""
	Private cFilAnt := ""

	Default lReconect := .F. // se deve reconectar, encaminhado de outra fun็ใo

	Public __TimeOut := lReconect // Seta uma vแriavel p๚blica para que possa ser identificada mesmo com Atualiza็ใo ou em outro fonte aph.

	If __TimeOut
		ExecInPage("MNTI0062")
		__TimeOut := .F.
	EndIf

	WEB EXTENDED INIT cHtml

		HttpSession->PWSaEMPFIL	:= {}


		fOpenSm0() // abre sm0 e carrega array de empresas/filiais do ambiente

		HttpSession->cCODMEMP   := "" // empresa selecionada pelo usuแrio
		HttpSession->cCODMFIL   := "" // filial selecioanda pelo usuแrio
		HttpSession->cENVSERVER := GetEnvServer()
		HttpSession->cDataMicro := MsDate()
		HttpSession->FocoLogin  := 1
		HttpSession->txt_Senha  := ""
		HttpSession->Mens_Login := ""
		HttpSession->aEnviaPS   := {}

		If fVerFluig("") == "0" // Chamada via fluig

			HttpSession->UserID := __cUserId
			cHtml += ExecInPage("MNTI0063") //Tela de sele็ใo de Empresa/Filial

		Else //Via LocalHost ou TimeOut do Fluig
			HttpSession->txt_Nome := ""
			HttpSession->UserID   := ""
			cHtml += ExecInPage("MNTI0051")
		EndIf

	WEB EXTENDED END

Return cHtml

//------------------------------------------------------------------------
/*/{Protheus.doc} fOpenSm0
Abertura do arquivo sigamat.emp e carrega array de empresas/filiais

@author  Ricardo Dal Ponte
@since   15/02/2007
@source  SIGAMNT
@version P12
@return
/*/
//-------------------------------------------------------------------------
Static Function fOpenSm0()

	Local nX      := 0
	Local aFilSM0 := {}

	OpenSM0() // Realiza abertura da SM0

	aFilSM0 := FWLoadSM0() // Carrega as filiais da SM0.

	For nX := 1 To Len(aFilSM0)

		aAdd(HttpSession->PWSaEMPFIL,{;
				aFilSM0[nX,1],; // T3
				Upper( aFilSM0[nX,2] ),; // M RJ 01 
				Upper( aFilSM0[nX,2] ) ,;// M RJ 01 
				Alltrim( Capital( aFilSM0[nX,6] ) ),; // Grupo totvs
				"ENVNGPORTAL"+aFilSM0[nX,1]+ aFilSM0[nX,2] }) // ENVNGPORTALT3M RJ 01 

	Next nX

Return aFilSM0

//------------------------------------------------------------------------
/*/{Protheus.doc} fValidUser
Validacao do Login verificando regras de usuario e grupo.

@author  Ricardo Dal Ponte
@since   14/12/2006

@param
@return  lLogin, L๓gico, Verifica se o login serแ permitido.

@obs Reescrito por Alexandre Santos, 25/07/2018.
/*/
//-------------------------------------------------------------------------
Static Function fValidUser()

	Local nGroup   := 0
	Local nValue   := 0
	Local cHtml    := ""
	Local cGrpRule := ""
	Local lRet     := .T.
	Local cMsg     := ""
	Local aPswRet  := {}
	Local aValues  := {}
	Local aGroups  := {}
	Local aBlqGrps := {}

	WEB EXTENDED INIT cHtml

		HttpSession->Mens_Login := " "

		If fVerFluig(HttpGet->cAmbEnv) == "2"

			If Empty( HttpPost->txt_Nome )
			
				lRet := .F.
			
			Else

				PswOrder(2) //Nome do Usuario
				lRet := PswSeek(HttpPost->txt_Nome,.T.) .And. PswName(HttpPost->txt_Senha)

			EndIf
		Else

			If Empty( HttpSession->UserID )
				
				lRet := .F.

			Else
			
				PswOrder(1)
				lRet := PswSeek(HttpSession->UserID)

			EndIf

		EndIf

		If lRet

			lRet     := .F.
			aPswRet  := PswRet()
			cGrpRule := FWUsrGrpRule(aPswRet[1][1])
			aGroups  := aPswRet[1][10]

			//Valida se usuario estแ bloqueado para o acesso.
			If aPswRet[1][17]
				cMsg := STR0003 //Usuแrio BLOQUEADO!
			ElseIf !Empty(aPswRet[1][6]) .And. DtoC(aPswRet[1][6]) < DtoC(MsDate()) //Valida se a senha de usuario encontr-se dentro da validade.
				cMsg := STR0004 //Senha EXPIRADA!
			EndIf

			//Prioriza regra por grupo OU Soma regras de grupo com usuario.
			If ( cGrpRule == "1" .Or. cGrpRule == "3" ) .And. Empty(cMsg)

				For nGroup := 1 to Len(aGroups)

					aBlqGrps := FWGrpParam(aGroups[nGroup])

					//Verifica se o grupo estแ bloqueado
					If aBlqGrps[1][3] == "2" .Or. (!Empty(aBlqGrps[1][4]) .And. DtoC(aBlqGrps[1][4]) > DtoC(MsDate()))
						aValues := FWGrpMenu(aGroups[nGroup])
						For nValue := 1 To Len(aValues)
							//Verifica se usuario tem acesso ao modulo manuten็ใo de ativos - 19 ou Gestใo de Frotas - 95
							If fValMod( aValues )
								lRet := .T.
								cMsg := ""
								Exit
							Else
								lRet := .F.
								cMsg := STR0008 // Usuแrio sem acesso ao Manuten็ใo de Ativos ou Gestใo de Frotas
							EndIf

						Next nValue
					Else
						lRet := .F.
						cMsg := STR0015
					EndIf

					//Caso o usuario possuir acesso em um grupo, este jแ ้ liberado e dispensa o restante do loop.
					If lRet
						Exit
					EndIf

				Next nGroup

			EndIf

			// Desconsidera regra por grupo OU Soma regras de grupo com usuario.
			If ( cGrpRule == '2' .And. Empty( cMsg ) )

				// Verifica se usuario tem acesso aos modulos de Manuten็ใo de Ativos 19 ou Gestใo de Frotas 95
				If Len(aPswRet) > 0 .And. !fValMod( aPswRet[ 3 ] )
					cMsg := STR0008 // Usuแrio sem acesso ao Manuten็ใo de Ativos ou Gestใo de Frotas
					lRet := .F.
				Else
					lRet := .T.
				EndIf

			EndIf

			If lRet
				HttpSession->TQB_CDSOLI := Substr(aPswRet[1][1], 1, 6)
				HttpSession->TQB_NMSOLI := Substr(aPswRet[1][4], 1, 50)
				HttpSession->TQB_EMAIL  := Substr(aPswRet[1][14], 1, 50)
				HttpSession->TQB_RAMAL  := If(Empty(aPswRet[1][20]), "", aPswRet[1][20])
				HttpSession->txt_Nome   := aPswRet[1][2]
				HttpSession->txt_Senha  := HttpPost->txt_Senha
				HttpSession->Mens_Login := STR0002 //"Acesso Autorizado!"
				HttpSession->FocoLogin  := 2
			EndIf

		EndIf

		If !lRet

			If Empty( cMsg )
				cMsg := STR0001 //"Usuแrio nใo Autenticado!"
			EndIf

			HttpSession->Mens_Login := cMsg
			HttpSession->FocoLogin  := 1
			HttpSession->txt_Nome   := ""
			HttpSession->txt_Senha  := ""
		
		EndIf

	WEB EXTENDED END

Return lRet

//------------------------------------------------------------------------
/*/{Protheus.doc} I5PE02
Ponto de Entrada 02 - Inclusao de Campos do Usuario

@author  Felipe N. Welter
@since   14/08/2008
@source  SIGAMNT
@version P12
@return  True
/*/
//-------------------------------------------------------------------------
Web Function I5PE02( nOpcx )

	Local cHtml  := ""
	Local nCnt

	Default nOpcx := 3

	// As variaveis abaixo podem ser acessadas pelo Ponto de Entrada
	Private aDesc  := {}, aDesc2  := {}, cDesc  := '' //cDesc - Descricao do Campo (Depto.:)
	Private aCampo := {}, aCampo2 := {}, cCampo := '' //cCampo - Nome do campo (TQB_DEPTO)
	Private aTam   := {}, aTam2   := {}, cTam   := '' //cTam - Tamanho definido ao campo (30)
	Private aVazio := {}, aVazio2 := {}, cVazio := '' //aVazio - Determina se aceita ou nao campo vazio (S/N)

	I05CLEAR() // limpa variแveis

	WEB EXTENDED INIT cHtml START "I005ENV"

	aArea := GetArea()

	If ExistBlock("MNTI5002")
		ExecBlock("MNTI5002",.F.,.F.)
		RestArea(aArea)

		aArea := GetArea()
		dbSelectArea("TQB")
		dbSetOrder(1)
		For nCnt := 1 to Len(aCampo)
			If FieldPos(aCampo[nCnt]) > 0
				AADD(aDesc2,aDesc[nCnt])
				AADD(aCampo2,aCampo[nCnt])
				AADD(aTam2,aTam[nCnt])
				AADD(aVazio2,aVazio[nCnt])
			EndIf
		Next
		If !(Len(aCampo2) > 0)
			cDesc  := '-'
			cCampo := '-'
			cTam   := '-'
			aVazio := '-'
		EndIf
	Else
		cDesc  := '-'
		cCampo := '-'
		cTam   := '-'
		aVazio := '-'
	EndIf

	If (Len(aDesc2) == Len(aCampo2)) .And. (Len(aCampo2) == Len(aTam2)) .And. (cDesc != '-')
		For nCnt := 1 to Len(aDesc2)
			cDesc  += aDesc2[nCnt]+'#'
			cCampo += aCampo2[nCnt]+'#'
			cTam   += aTam2[nCnt]+'#'
			cVazio += aVazio2[nCnt]+'#'
		Next
	EndIf

	HttpSession->cPE5002c1 := cDesc
	HttpSession->cPE5002c2 := cCampo
	HttpSession->cPE5002c3 := cTam
	HttpSession->cPE5002c4 := Len(aDesc2)
	HttpSession->cPE5002c5 := ""
	HttpSession->cPE5003c2 := cVazio

	RestArea(aArea)

	WEB EXTENDED END

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณI05VLDUSRCPบ Autor ณ Felipe N. Welter   บ Data ณ 20/08/2008 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณPonto de Entrada 03 - Validacao de Campos do Usuario        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAMNT                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Web Function I05VLDUSRCP()

	Local cHtml  := ""

	WEB EXTENDED INIT cHtml START "I005ENV"

	I05REFRESH()

	aArea := GetArea()

	HttpSession->cPE5003c1  := HttpPost->cPE5003c1

	// As variaveis abaixo podem ser acessadas pelo Ponto de Entrada
	// lPERet indica validacao .T./.F., cPEMsg mensagem mostrada na tela (para "" nao sera mostrada)
	cCampo    := Substr(HttpSession->cPE5003c1,4,(At("#",HttpSession->cPE5003c1)-4))
	cConteudo := SubStr(HttpSession->cPE5003c1,(At("#",HttpSession->cPE5003c1)+1),Len(HttpSession->cPE5003c1)-(At("#",HttpSession->cPE5003c1)))
	lPERet    := .T.
	cPEMsg    := ""
	If ExistBlock("MNTI5003")
		ExecBlock("MNTI5003",.F.,.F.)
		If !lPERet
			HttpSession->cPE5003c1 += "#0"+"#"+cPEMsg+"#"
		Else
			HttpSession->cPE5003c1 += "#1"+"#"+cPEMsg+"#"
		EndIf
	EndIf

	RestArea(aArea)

	WEB EXTENDED END

Return h_MNTI0052()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜdÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณIRECOVER  บAutor  ณ Ricardo Dal Ponte   บ Data ณ  14/12/06  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAMNT                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Web Function IRECOVER()

	Local cHtml := ""

	WEB EXTENDED INIT cHtml

	HttpSession->cCODMEMP   := ""
	HttpSession->cCODMFIL   := ""
	HttpSession->cENVSERVER := GetEnvServer()

	WEB EXTENDED END

Return h_MNTI0051()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณIREDIRECT บAutor  ณ Ricardo Dal Ponte   บ Data ณ  14/12/06  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Alteracao do ambiente no servidor                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAMNT                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Web Function IREDIRECT()

	Local cHtml       := ""
	Local cEnviremont := ""
	Local cEnvi       := GetPvProfString("HTTP", "Environment", "",GetAdv97())
	Local cSetEnv     := GetPvProfString("FACILITIES_"+cEnvi, "PREPAREIN" , "",GetAdv97())
	Local cEmpFac     := GetPvProfString("FACILITIES_"+cEnvi, "WebEmpresa", "",GetAdv97())
	Local cFilFac     := GetPvProfString("FACILITIES_"+cEnvi, "WebFilial" , "",GetAdv97())
	Local aSetEnv     := {}
	Local cSPath      := ''

	WEB EXTENDED INIT cHtml

		If !Empty(HttpGet->cAmbEmp)
			cAmbiente             := HttpGet->cAmbEmp
			cEnviremont           := HttpGet->cAmbEnv
			HttpSession->cCODMEMP := Substr(cAmbiente,12,2)
			HttpSession->cCODMFIL := Substr(cAmbiente,14)

		Else //Chamada via fluig, quando nใo existe tela de sele็ใo de ambiente. (fVerFluig == 2)

			If !Empty(cEmpFac) .And. !Empty(cFilFac)
				aSetEnv := {cEmpFac,cFilFac}
			Else
				aSetEnv := StrTokArr(cSetEnv,",")
			EndIf

			cEnviremont := cEnvi

			If Len(aSetEnv) > 0
				HttpSession->cCODMEMP := aSetEnv[1]
			EndIf
			
			If Len(aSetEnv) > 1
				HttpSession->cCODMFIL := aSetEnv[2]
			EndIf
		EndIf

		cTSTRespJob := "FACILITIES_"+cEnviremont

		cSPath := GetPvProfString(cEnviremont,"SourcePath","",GetAdv97())

		If Empty(cSPath)
			HttpSession->Mens_Login := STR0006+" "+cEnviremont//"Ambiente nใo localizado"
			HttpSession->FocoLogin  := 3

			cHtml := " <form name='FALHAAMB' method='post' action='W_IRECOVER.APW' target='_self'>"
			cHtml += " </form> "
			cHtml += " </body> "
			cHtml += " </html> "
			cHtml += " <script language='JavaScript'> "
			cHtml += " document.FALHAAMB.submit(); "
			cHtml += " </script> "

			Return cHtml
		EndIf

		cRespJob := GetPvProfString(cTSTRespJob,"Environment","",GetADV97())

		If Empty(cRespJob)
			HttpSession->Mens_Login := STR0011+"<br>"+STR0007+" "+cTSTRespJob //"Ambiente nใo configurado para acesso ao facilities"##"Working Threads nใo encontrada"
			HttpSession->FocoLogin  := 3
			cHtml := " <form name='FALHAWT' method='post' action='W_IRECOVER.APW' target='_self'>"
			cHtml += " </form> "
			cHtml += " </body> "
			cHtml += " </html> "
			cHtml += " <script language='JavaScript'> "
			cHtml += " document.FALHAWT.submit(); "
			cHtml += " </script> "

			Return cHtml
		Endif

		If Empty( HttpSession->cCODMEMP ) .Or. Empty( HttpSession->cCODMFIL ) .Or. !fConfigEnv( HttpSession->cCODMEMP, HttpSession->cCODMFIL ) // Realiza abertura do ambiente
			
			HttpSession->Mens_Login := STR0016 // Nใo foi possํvel realizar a abertura do ambiente
			HttpSession->FocoLogin  := 3
			cHtml := " <form name='FALHAWT' method='post' action='W_IRECOVER.APW' target='_self'>"
			cHtml += " </form> "
			cHtml += " </body> "
			cHtml += " </html> "
			cHtml += " <script language='JavaScript'> "
			cHtml += " document.FALHAWT.submit(); "
			cHtml += " </script> "

			Return cHtml
		EndIf

		If !fValidUser() //Verifica usuario
			cHtml := " <form name='USERSENHA' method='post' action='W_IRECOVER.APW' target='_self'>"
			cHtml += " </form> "
			cHtml += " </body> "
			cHtml += " </html> "
			cHtml += " <script language='JavaScript'> "
			cHtml += " document.USERSENHA.submit(); "
			cHtml += " </script> "

			Return cHtml
		Endif

		HttpCookies->APRESPONSEJOB := cTSTRespJob

		If Empty(cHtml)

			//Pesquisa de Satisfacao
			If !NG280SAT(HttpSession->TQB_CDSOLI) .And. AllTrim(SuperGetMv("MV_NGPSATI")) == "S"
				HttpSession->Mens_Login := STR0012 //"Antes de acessar a tela de Solicita็ใo de Servi็os, voc๊ deverแ responder a Pesquisa de Satisfa็ใo"
				//Campos para poder reenviar o WF da pesquisa de satisfa็ใo
				aAdd(HttpSession->aEnviaPS, {.T./*habilita botใo reenviar*/, TQB->(RECNO()), HttpSession->cCODMEMP,HttpSession->cCODMFIL})
				cHtml := " <form name='VALIDPS' method='post' action='W_IRECOVER.APW' target='_self'>"
				cHtml += " </form> "
				cHtml += " </body> "
				cHtml += " </html> "
				cHtml += " <script language='JavaScript'> "
				cHtml += " document.VALIDPS.submit(); "
				cHtml += " </script> "

				Return cHtml
			EndIf

			If MNTINTFAC()
				cHtml += " <form name='ISTART' method='post'  action='W_I005BRWSS.APW' target='_self'> "
			Else
				cHtml += " <form name='ISTART' method='post'  action='W_I005INCSS.APW' target='_self'> "
			Endif
			cHtml += " </form> "
			cHtml += " </body> "
			cHtml += " </html> "
			cHtml += " <script language='JavaScript'> "
			cHtml += " document.ISTART.submit(); "
			cHtml += " </script> "
		EndIf

	Web Extended End

Return cHtml

//------------------------------------------------------------------------
/*/{Protheus.doc} W_CONFSMAT()
Acionada ap๓s preenchimento do campo usuแrio

@author  Maicon Andr้ Pinheiro
@since   12/07/2016
@version P12
@return  string
/*/
//-------------------------------------------------------------------------
Web Function CONFSMAT()

	Local cHtml     := ""
	Local nI        := 0
	Local aBkpAcss  := {}
	Local aAcess    := {}
	Local nPosCampo := 0

	//-----------------------------------------
	// verifica se hแ necessidade de reconectar
	//-----------------------------------------
	If Empty( HttpGet->cNome )
		W_PORTALNG() //Retorna เ tela Inicial
		Return ""
	EndIf

	WEB EXTENDED INIT cHtml

		HttpSession->txt_Nome   := HttpGet->cNome
		HttpSession->FocoLogin  := 4
		HttpSession->PWSaEMPFIL := {}

		fOpenSm0() // carrega filiais do ambiente

		aAcess := aClone(fAcessUser(HttpSession->txt_Nome)) // carrega filiais do usuแrio

		If Len(aAcess) > 0 .And. aAcess[1] != "@@@@" .And. !Empty(HttpSession->txt_Nome)

			For nI := 1 To Len(aAcess)

				nPosCampo := aScanX(HttpSession->PWSaEMPFIL, {|x,y| AllTrim(x[1]+x[3]) == AllTrim(aAcess[nI]) .And. y > 0 })

				If nPosCampo > 0
					aAdd(aBkpAcss,{;
						HttpSession->PWSaEMPFIL[nPosCampo][1],;
						HttpSession->PWSaEMPFIL[nPosCampo][2],;
						HttpSession->PWSaEMPFIL[nPosCampo][3],;
						HttpSession->PWSaEMPFIL[nPosCampo][4],;
						HttpSession->PWSaEMPFIL[nPosCampo][5]})
				EndIf

			Next nI
			HttpSession->PWSaEMPFIL := aClone(aBkpAcss)
		EndIf

	Web Extended End

Return h_MNTI0051()

//------------------------------------------------------------------------
/*/{Protheus.doc} W_ENVIAPS()
Fun็ใo para reenvio do workflow quando estiver pendente responder
o questionแrio de satisfa็ใo.

@author  Diego de Oliveira
@since   03/03/2019
@version P12
@return  h_MNTI0051
/*/
//-------------------------------------------------------------------------
Web Function ENVIAPS()


	WEB EXTENDED INIT cHtml

		If !Empty(HttpSession->aEnviaPS[1][2])
			StartJob("MNTW035F",GetEnvserver(),.F.,HttpSession->aEnviaPS[1][2],HttpSession->aEnviaPS[1][3],HttpSession->aEnviaPS[1][4])
		EndIf

	Web Extended End

Return h_MNTI0051()

//--------------------------------------------------------------------------------
/*/{Protheus.doc} fAcessUser
Fun็ใo para buscar as empresas e filiais as quais um determinado
usuแrio possui acesso.

@author Alexandre Santos
@since 19/07/2018

@param  cVerCodUsr, Caracter, C๓dico do usuario.
@return aUsrAccess, Array   , Lista com as empresas/filiais que o usuario tem acesso.

/*/
//--------------------------------------------------------------------------------
Static Function fAcessUser(cVerCodUsr)

	Local cGrpRule   := ""
	Local nGroup     := 0
	Local nValue     := 0
	Local aArea      := GetArea()
	Local aValues    := {}
	Local aRet       := {}
	Local aUsrAccess := {}
	Local aPswRet    := {}
	Local aBlqGrps   := {}
	Local cMsgErro   := ''

	PswOrder(2)
	If PswSeek(cVerCodUsr,.T.)
		aPswRet    := PswRet()
		cGrpRule   := FWUsrGrpRule(aPswRet[1][1])
		aUsrAccess := aPswRet[2][6]
		aGroups    := aPswRet[1][10]

		__cUserID           := aPswRet[1,1]
		HttpSession->UserID := aPswRet[1,1]
		cUserName           := UsrRetName( aPswRet[1,1] )

		Do Case
			Case cGrpRule == "1" //Prioriza regra por grupo

				For nGroup := 1 to Len(aGroups)
					aBlqGrps := FWGrpParam(aGroups[nGroup])
					If aBlqGrps[1][3] == "2" .Or. (!Empty(aBlqGrps[1][4]) .And. DtoC(aBlqGrps[1][4]) < DtoC(MsDate()))
						aValues := FWGrpEmp(aGroups[nGroup])
						For nValue := 1 To Len(aValues)
							aAdd(aRet, aValues[nValue] )
						Next nValue
					EndIf
				Next nGroup

			Case cGrpRule == "2" //Desconsidera regra por grupo
				aRet := aClone(aUsrAccess)
			Case cGrpRule == "3" //Soma regra por grupo

				For nGroup := 1 to Len(aGroups)
					aBlqGrps := FWGrpParam(aGroups[nGroup])
					If aBlqGrps[1][3] == "2" .Or. (!Empty(aBlqGrps[1][4]) .And. DtoC(aBlqGrps[1][4]) < DtoC(MsDate()))
						aValues := FWGrpEmp(aGroups[nGroup])
						For nValue := 1 To Len(aValues)
							If AScan( aUsrAccess, Alltrim( aValues[nValue] )) == 0
								aAdd(aUsrAccess, aValues[nValue] )
							EndIf
						Next nValue
					EndIf
				Next nGroup

				aRet := aClone(aUsrAccess)
			OtherWise
				cMsgErro := STR0001//"Usuแrio nใo Autenticado!"
				HttpSession->FocoLogin  := 1
		EndCase
	EndIf

	If !Empty(cMsgErro )
		HttpSession->Mens_Login := cMsgErro 
	ElseIf Empty(aRet)
		HttpSession->Mens_Login := STR0014//"Usuแrio nใo possui acesso เ nenhuma Empresa/Filial."
		HttpSession->FocoLogin  := 1
	EndIf

	RestArea(aArea)

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ I05CDSERVบAutor  ณ Ricardo Dal Ponte   บ Data ณ  14/12/06  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Checagem do codigo do servico                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAMNT                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Web Function I05CDSERV(cValor)

	Local lRet       := .T.
	Local cHtml      :=""
	Local cMsg       := ""
	Local cCdServ    := ""
	Local cRetCdResp := ""
	Local cRetNmResp := ""

	//-----------------------------------------
	// Redireciona para a tela de login
	//-----------------------------------------
	If Empty( HttpSession->txt_Nome ) .Or. HttpSession->txt_Nome == Nil
		W_PORTALNG(.T.)
		Return ''
	EndIf

	WEB EXTENDED INIT cHtml START "I005ENV"

		If !Empty(cValor)
			
			cCdServ  := Padr(Alltrim(SubStr(cValor, 1, TAMSX3("TQ3_CDSERV")[1])),TAMSX3("TQ3_CDSERV")[1])

			dbSelectArea("TQ3")
			dbSetOrder(1)
			If !dbSeek(xFilial("TQ3")+cCdServ)

				cMsg := STR0010//"Nใo existe registro relacionado a este c๓digo."
				lRet := .F.
			
			Else

				HttpSession->TQB_CDSERV := TQ3->TQ3_CDSERV
				HttpSession->TQB_NMSERV := TQ3->TQ3_NMSERV
				cRetCdResp := TQ3->TQ3_CDRESP
			EndIf
	
			If lRet .And. !Empty(cRetCdResp)
				PswOrder(2)
				If PswSeek(cRetCdResp)
					cRetNmResp := SubStr(UsrFullName(PswRet(1)[1][1]), 1, 40)
					HttpSession->TQB_NOMFUN  := cRetNmResp
				EndIf
			Endif
		EndIf

		If !lRet .Or. Empty(cCdServ)
			HttpSession->TQB_CDSERV := ""
			HttpSession->TQB_NMSERV := ""
			HttpSession->TQB_NOMFUN := ""
		EndIf

		HttpSession->cValidacao := "txtTQB_CDSERV"+"#"+If(lRet,"1","0")+"#"+If(lRet,"","A")+"#"+cMsg+"#"+" #"

	WEB EXTENDED END

Return h_MNTI0052()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณI05CDSOLI บAutor  ณRoger Rodrigues      บ Data ณ  06/01/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica codigo do solicitante                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMNTI0052                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Web Function I05CDSOLI(cValor)

	Local nPos := 0
	Local lRet := .T.
	Local cHtml:="", cMsg := ""
	Local cCdSoli := ""
	Local aUsers := FWSFALLUSERS()//Carrega todos usuarios

	//-----------------------------------------
	// Redireciona para a tela de login
	//-----------------------------------------
	If Empty( HttpSession->txt_Nome ) .Or. HttpSession->txt_Nome == Nil
		W_PORTALNG(.T.)
		Return ''
	EndIf

	WEB EXTENDED INIT cHtml START "I005ENV"

	cCdSoli  := Padr(Alltrim(SubStr(cValor, 1, TAMSX3("TQB_CDSOLI")[1])),TAMSX3("TQB_CDSOLI")[1])

	If (nPos := aScan(aUsers, {|x| Padr(x[2],6) == AllTrim(cCdSoli)})) > 0//Verifica se encontra usuario
		HttpSession->TQB_NMSOLI := Substr(aUsers[nPos][4], 1, 50)
		HttpSession->TQB_EMAIL  := aUsers[nPos][5]
		HttpSession->TQB_RAMAL  := ""
	ElseIf Empty(cCdSoli)
		lRet := .T.
	Else
		cMsg := STR0010//"Nใo existe registro relacionado a este c๓digo."
		lRet := .F.
	EndIf

	If !lRet .or. Empty(cCdSoli)
		HttpSession->TQB_CDSOLI := ""
		HttpSession->TQB_NMSOLI := ""
		HttpSession->TQB_EMAIL  := ""
	EndIf

	HttpSession->cValidacao := "txtTQB_CDSOLI"+"#"+If(lRet,"1","0")+"#"+If(lRet,"","A")+"#"+cMsg+"#"+" #"

	WEB EXTENDED END

Return h_MNTI0052()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณI05REFRESHบAutor  ณ Ricardo Dal Ponte   บ Data ณ  19/12/06  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava conteudo da tela nas variaveis do html               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAMNT                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function I05REFRESH()

	HttpSession->TQB_CODBEM := HttpPost->cCODBEM
	HttpSession->TQB_RAMAL  := HttpPost->cRAMAL
	HttpSession->TQB_DESCSS := HttpPost->cDESCSS
	HttpSession->TQB_CDSERV := HttpPost->cCDSERV
	HttpSession->TQB_TPSERV := HttpPost->cTPSERV
	HttpSession->TQB_CDSOLI := HttpPost->cCDSoli
	HttpSession->TQB_ARQUIVO:= HttpPost->cARQUIVO
	HttpSession->cPE5002c5  := HttpPost->cPE5002c5
	HttpSession->cValidacao := ""

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณI05CLEAR  บAutor  ณ Ricardo Dal Ponte   บ Data ณ  20/12/06  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para limpar a tela de inclusao de SS                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAMNT                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function I05CLEAR(nOpcx)

	Local xValor
	Local aNGHeader := {}
	Local nTamTot   := 0
	Local nInd      := 0

	Default nOpcx := 3

	cUserName := HttpSession->txt_Nome//Para validacao de Restricao de acesso

	If HttpSession->txt_Nome == Nil
		HttpSession->txt_Nome := ""
	EndIf

	HttpSession->TQB_SOLICI  := ""
	HttpSession->TQB_CODBEM  := ""
	HttpSession->TQB_NOMBEM  := ""
	HttpSession->TQB_CCUSTO  := ""
	HttpSession->TQB_NOMCUS  := ""
	HttpSession->TQB_CENTRA  := ""
	HttpSession->TQB_NOMCTR  := ""
	HttpSession->TQB_DTABER  := dDataBase
	HttpSession->TQB_HOABER  := Substr(time(),1, 5)
	HttpSession->TQB_DESCSS  := ""
	HttpSession->TQB_SOLUCA  := ""
	HttpSession->TQB_TPSERV  := ""
	HttpSession->TQB_CDSERV  := ""
	HttpSession->TQB_NMSERV  := ""
	HttpSession->TQB_NOMFUN  := ""
	HttpSession->TQB_ARQUIVO := "2"
	HttpSession->cSupAtu     := "001"
	HttpSession->aQUEST      := {}
	HttpSession->cPES        := ""
	HttpSession->cValidacao  := ""
	HttpSession->nOpcx       := nOpcx

	If Select('SM0') > 0

		//Cria variaveis para todos campos da TQB
		aNgHeader := NGHeader( "TQB" ) // Buscar os campos das tabela.
		nTamTot := Len(aNgHeader)
		For nInd := 1 To nTamTot
			xValor := ""
			If aNgHeader[nInd, 8] == "N" // X3_TIPO
				xValor := 0
			ElseIf aNgHeader[nInd, 8] == "D" // X3_TIPO
				xValor := CTOD("")
			Endif

			&("HttpSession->"+Trim(aNgHeader[nInd, 2])) := xValor // X3_CAMPO
		Next nInd

		//Reposiciona no usuario
		If fVerFluig("") == "2"

			PswOrder( 2 )
			If PswSeek( HttpSession->txt_Nome, .T. )

				aPswRet := PswRet( 1 )

				PswOrder( 1 )
				If PswSeek( aPswRet[1,1] ) .And. PswName( HttpSession->txt_Senha )

					HttpSession->TQB_CDSOLI := SubStr( aPswRet[1,1] , 1, 06 )
					HttpSession->TQB_NMSOLI := SubStr( aPswRet[1,4] , 1, 50 )
					HttpSession->TQB_EMAIL  := SubStr( aPswRet[1,14], 1, 50 )
					HttpSession->TQB_RAMAL  := IIf( Empty( aPswRet[1,20] ), '', aPswRet[1,20] )

				EndIf
			
			EndIf

		Else

			PswOrder( 1 )
			If PswSeek( HttpSession->UserID )
				aPswRet := PswRet( 1 )
				HttpSession->TQB_CDSOLI := SubStr( aPswRet[1,1] , 1, 6  )
				HttpSession->TQB_NMSOLI := SubStr( aPswRet[1,4] , 1, 50 )
				HttpSession->TQB_EMAIL  := SubStr( aPswRet[1,14], 1, 50 )
				HttpSession->TQB_RAMAL  := IIf( Empty( aPswRet[1,20] ), '', aPswRet[1,20] )

			EndIf
		EndIf

		HttpSession->cPE5002c5 := ""
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ I05CDGRAVบAutor  ณ Ricardo Dal Ponte   บ Data ณ  19/12/06  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Gravacao da Solicitacao de Servico                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAMNT                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Web Function I05CDGRAV()

	Local cHtml  := ""
	Local cCodSS := ""
	Local i
	Local cMemoDg
	Local lFacilit
	Local nCriticidade

	WEB EXTENDED INIT cHtml START "I005ENV"

		I05REFRESH()

		If !Empty(HttpSession->TQB_CODBEM) .And.; //If para nao gravar duas vezes, o ConnectWebex chama a funcao 2 vezes
		    Empty(HttpSession->TQB_SOLICI)        //Verifica se jแ incluiu SS, pois ao dar F5 na tela ele inclui uma nova SS com os mesmo dados.

			lFacilit  := MNTINTFAC()

			dbSelectArea("TQB")
			dbSetOrder(1)

			cCodSS := GETSXENUM("TQB","TQB_SOLICI")
			ConfirmSX8()
			While dbSeek(xFilial("TQB")+cCodSS)
				cCodSS := GETSXENUM("TQB","TQB_SOLICI")
				ConfirmSX8()
			End

			dbSelectArea("TQB")
			dbSetOrder(1)
			RecLock("TQB",.T.)
			TQB->TQB_FILIAL := xFilial("TQB")
			TQB->TQB_SOLICI := cCodSS
			TQB->TQB_TIPOSS := HttpSession->TQB_TIPOSS
			TQB->TQB_CODBEM := HttpSession->TQB_CODBEM
			TQB->TQB_CCUSTO := HttpSession->TQB_CCUSTO
			TQB->TQB_CENTRA := HttpSession->TQB_CENTRA
			TQB->TQB_DTABER := HttpSession->TQB_DTABER
			TQB->TQB_HOABER := HttpSession->TQB_HOABER
			TQB->TQB_SOLUCA := "A"
			TQB->TQB_RAMAL  := HttpSession->TQB_RAMAL
			TQB->TQB_CDSERV := HttpSession->TQB_CDSERV
			If lFacilit
				If Empty(HttpSession->TQB_TPSERV)
					TQB->TQB_TPSERV := "1"//Incidente
				Else
					TQB->TQB_TPSERV := HttpSession->TQB_TPSERV
				Endif
			Endif
			
			TQB->TQB_CDSOLI := HttpSession->TQB_CDSOLI
			TQB->TQB_USUARI := Alltrim(SubStr(UsrFullName(HttpSession->TQB_CDSOLI), 1, 30))
			TQB->TQB_ORIGEM := 'MNTI005'

			If !Empty(HttpSession->cPE5002c4) .and. !Empty(HttpSession->cPE5002c2) .and. !Empty(HttpSession->cPE5002c5)
				nQnt := HttpSession->cPE5002c4
				cCampAll := HttpSession->cPE5002c2
				cCntdAll := HttpSession->cPE5002c5
				nIni1 := 1
				nIni2 := 1
				nTot1 := Len(cCampAll)
				nTot2 := Len(cCntdAll)
				nPos1 := 0
				nPos2 := 0
				For i := 1 To nQnt
					ctTxt := Substr(cCampAll,nIni1,(nTot1-nPos1))
					nPos1  := At("#",ctTxt)
					cCamp := Substr(ctTxt,1,nPos1-1)
					nIni1  := nPos1+1

					ctCnt := Substr(cCntdAll,nIni2,(nTot2-nPos2))
					nPos2  := At("#",ctCnt)
					cCtdo := Substr(ctCnt,1,nPos2-1)
					nIni2  := nPos2+1

					&('TQB->'+cCamp) := cCtdo
				Next i
			Endif

			MsUnLock("TQB")

			HttpSession->TQB_SOLICI := cCodSS

			//Calcula criticidade
			If FindFunction("NGCALCRI")
				nCriticidade := NGCALCRI(TQB->TQB_TIPOSS,TQB->TQB_CODBEM,TQB->TQB_CCUSTO,TQB->TQB_DTABER, TQB->TQB_CDSERV)
				dbSelectArea("TQB")
				RecLock("TQB",.F.)
				TQB->TQB_CRITIC := nCriticidade
				MsUnlock("TQB")
				//Preenche prioridade
				cPriori := MNT293CPO(nCriticidade, "TU9_PRIORI")
				dbSelectArea("TQB")
				RecLock("TQB",.F.)
				TQB->TQB_PRIORI := cPriori
				MsUnlock("TQB")
			Endif

			If ExistBlock('MNTI5006')
				ExecBlock('MNTI5006', .F., .F., { cCodSS } )
			EndIf

			//Grava Questionario
			If lFacilit .and. FindFunction("A280GRVPER")
				dbSelectArea("TQB")
				aOpcoes := HttpSession->aQUEST
				cMemoDg := A280GRVPER(aOpcoes)
				MSMM(,,,cMemoDg,1,,,"TQB","TQB_MEMODG")
			Endif

			dbSelectArea("TQB")
			MSMM(,,,HttpSession->TQB_DESCSS,1,,,"TQB","TQB_CODMSS")

			//Grava Follow-up
			If FindFunction("MNT280GFU") .and. lFacilit
				MNT280GFU(cCodSS,"01",,,,,,HttpSession->TQB_CDSOLI)//Inclusao
			Endif

			EvalTrigger() // Processa Gatilhos

			//Gera Workflow
			If Alltrim(SuperGetMv("MV_NGSSWRK",.F.,"-1")) == "S"
				MNTW025(TQB->TQB_SOLICI,HttpSession->cCODMEMP,HttpSession->cCODMFIL)
			Endif

			//Verifica se distribui automaticamente
			If lFacilit .and. FindFunction("MNT298AUT")
				MNT298AUT(TQB->TQB_SOLICI,TQB->TQB_TIPOSS,TQB->TQB_CODBEM,TQB->TQB_CDSERV,TQB->TQB_DTABER)
			Endif
		EndIf

	WEB EXTENDED END

	If HttpSession->TQB_ARQUIVO == "1"
		Return h_MNTI0061()
	Endif

 Return h_MNTI0053()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณI005ANEXO บAutor  ณRoger Rodrigues     บ Data ณ  10/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAnexa Arquivo                                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMNTI0061                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Web Function I005ANEXO()

	//Inclui arquivo no banco de conhecimento
	If !Empty(HttpPost->txtFile)
		fCopyFile(Trim(HttpPost->txtFile),HttpSession->TQB_SOLICI)
	Endif

Return h_MNTI0053()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfCopyFile บAutor  ณRoger Rodrigues     บ Data ณ  05/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCopia arquivo para o banco de conhecimento                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMNTI005                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
 Static Function fCopyFile(cArquivo, cCodSS)

	Local cNomeArq, cExtArq, cCodObj, cNovoArq
	Local cDirUpload := GetPvProfString("Http", "UploadPath", "", GetAdv97())
	Local cDirDocs   := If(FindFunction("MsMultDir") .and. MsMultDir(), MsRetPath(), MsDocPath())
	Local cBarraSrv  := If(isSRVunix(),"/","\")

	SplitPath( cArquivo, , , @cNomeArq, @cExtArq)
	cNomeArq += cExtArq

	If Empty(cDirUpload)
		cDirUpload := cBarraSrv
	Endif

	If !Empty(cDirUpload) .and. !Empty(cNomeArq) .and. !Empty(cDirDocs)
		cDirUpload := If(Right(cDirUpload, 1 ) == cBarraSrv, cDirUpload, cDirUpload+cBarraSrv)
		cDirDocs   := If(Right(cDirDocs, 1 ) == cBarraSrv, cDirDocs, cDirDocs+cBarraSrv)
		//Realiza copia
		If File(cDirUpload+cNomeArq)
			cNovoArq := Upper(Ft340RmvAc("SS"+cCodSS+"-"+cNomeArq))
			__CopyFile( cDirUpload+cNomeArq, cDirDocs+cNovoArq)
			//Apaga arquivo
			FErase(cDirUpload+cNomeArq)

			//Inclui objeto no conhecimento
			If File(cDirDocs+cNovoArq)
				cCodObj := GetSxeNum("ACB","ACB_CODOBJ")
				dbSelectArea("ACB")
				dbSetOrder(2)
				If !dbSeek(xFilial("ACB")+cNovoArq)
					RecLock("ACB", .T.)
					ACB->ACB_FILIAL  := xFilial("ACB")
					ACB->ACB_CODOBJ  := cCodObj
					ACB->ACB_OBJETO  := cNovoArq
					ACB->ACB_DESCRI  := "SS"+cCodSS
					If FindFunction("MsMultDir") .And. MsMultDir()
						ACB->ACB_PATH	:= MsRetPath(cNovoArq)
					Endif
					MsUnlock("ACB")
				Endif

				dbSelectArea("AC9")
				dbSetOrder(1)
				If !dbSeek(xFilial("AC9")+cCodObj+"TQB"+xFilial("TQB")+cCodSS)
					RecLock("AC9", .T.)
					AC9->AC9_FILIAL := xFilial("AC9")
					AC9->AC9_FILENT := xFilial("TQB")
					AC9->AC9_ENTIDA := "TQB"
					AC9->AC9_CODENT := xFilial("TQB") + cCodSS
					AC9->AC9_CODOBJ := cCodObj
					MsUnlock("AC9")
				Endif
			Endif
		Endif
	Endif

 Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณI005INCSS บAutor  ณ Ricardo Dal Ponte   บ Data ณ  20/12/06  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Chama tela de inclusao de SS                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAMNT                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

 Web Function I005INCSS()

	Local cHtml     := ""

	If Empty(HttpSession->txt_Nome) .Or. HttpSession->txt_Nome == Nil
		W_PORTALNG(.T.) //Retorna เ tela Inicial
		Return ""
	EndIf

	WEB EXTENDED INIT cHtml START "I005ENV"

		W_I5PE02() //Carrega campos a serem criados na tela

		If ExistBlock("MNTI5004")
			ExecBlock("MNTI5004",.F.,.F.)
		Else
			cHtml += ExecInPage("MNTI0052")
		EndIf

	WEB EXTENDED END

 Return  ""

//-------------------------------------------------------------------
/*/{Protheus.doc} I005VISSS
Chama tela de visualizacao de SS

@author  Roger Rodrigues
@since   16/06/12
@version P12
/*/
//-------------------------------------------------------------------
Web Function I005VISSS()

	Local cHtml      := ""
	Local cCodSS     := ""
	Local aNgHeader  := {}
	Local nTamTot    := 0
	Local nInd       := 0
	Local cCampoSX3  := ""
	Local cContexSX3 := ""

	WEB EXTENDED INIT cHtml START "I005ENV"

	W_I5PE02() //Carrega campos a serem criados na tela

	cCodSS := HttpGet->CodSS

	SetVisual(.T.)

	//Carrega variaveis para todos campos da TQB
	dbSelectArea("TQB")
	dbSetOrder(1)
	If dbSeek(xFilial("TQB")+cCodSS)
		aNgHeader := NGHeader( "TQB" ) // Buscar os campos das tabela.
		nTamTot := Len(aNgHeader)
		For nInd := 1 To nTamTot

			cCampoSX3  := aNgHeader[nInd, 2]
			cContexSX3 := aNgHeader[nInd, 10]

			If cContexSX3 != "V"
				&("HttpSession->"+Trim(cCampoSX3)) := &("TQB->" + cCampoSX3)
			ElseIf ExistIni(cCampoSX3)
				&("HttpSession->"+Trim(cCampoSX3)) := InitPad( Posicione("SX3", 2, aNgHeader[nInd, 2], "X3_RELACAO") )
			EndIf

		Next nInd
	Endif

	dbSelectArea("AC9")
	dbSetOrder(2)
	If dbSeek(xFilial("AC9")+"TQB"+xFilial("TQB")+cCodSS)
		HttpSession->TQB_ARQUIVO:= "1"
	EndIf

	If ExistBlock("MNTI5004")
		ExecBlock("MNTI5004",.F.,.F.)
	Else
		cHtml += ExecInPage("MNTI0052")
	EndIf

	WEB EXTENDED END

Return  ""

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณI005BRWSS บAutor  ณRoger Rodrigues      บ Data ณ  23/02/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Chama browse com SS                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAMNT                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Web Function I005BRWSS()

	Local cHtml := ""
	Local cPages:= ""
	Local nQtd  := 0

	If Empty( HttpSession->txt_Nome )
		
		W_PORTALNG(.T.) // Retorna a tela inicial

	Else
		WEB EXTENDED INIT cHtml START "I005ENV"

		cUserName := HttpSession->txt_Nome//Para validacao de Restricao de acesso

		I05CLEAR() // Limpa a tela de inclusao de SS

		If Select('SM0') > 0

			dbSelectArea("TQB")
			dbSetOrder(10)
			dbSeek(xFilial("TQB")+HttpSession->TQB_CDSOLI)
			While !Eof() .And. TQB->(TQB_FILIAL+Trim(TQB_CDSOLI)) == xFilial("TQB")+HttpSession->TQB_CDSOLI
				//Nao considera as encerradas e canceladas
				If TQB->TQB_SOLUCA == "E" .or. TQB->TQB_SOLUCA == "C"
					dbSelectArea("TQB")
					dbSkip()
					Loop
				Endif
				nQtd++
				If nQtd = 1 .And. Empty(cPages)
					cPages += cValToChar(TQB->(RecNo()))+";"
				ElseIf nQtd = 25
					nQtd := 0
					TQB->(dbSkip())
					If TQB->(!Eof())
						cPages += cValToChar(TQB->(RecNo()))+";"
					EndIf
				Else
					TQB->(dbSkip())
				EndIf
			End

			If Empty(cPages)
				cPages := "0;"
			Endif
			HttpSession->cPages := cPages
			HttpSession->cCurPg := "1"

			cHtml += ExecInPage("MNTI0058")
		
		EndIf

		WEB EXTENDED END

	EndIf

Return ''

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณI05CODBEM  ณ Autor ณ Ricardo Dal Ponte     ณ Data ณ20/12/2006ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณConsistencia do bem ou localizacao                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณSIGAMNT                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Web Function I05CODBEM(cValor)

	Local cHtml   :=""
	Local lBEMLOC := .F.
	Local aArea   := {}
	Local aRet    := {}

	Private cPECodBem := ""
	Private cPETipoOS := ""
	Private cPEMsg    := ""
	Private cPETpMsg  := ""
	Private lPERet    := .T.
	Private Inclui    := .T.
	Private Altera    := .F.
	Private cUserName := HttpSession->txt_Nome//Para validacao de Restricao de acesso

	WEB EXTENDED INIT cHtml START "I005ENV"

		M->TQB_CODBEM := Padr(Alltrim(SubStr(cValor, 1, TAMSX3("T9_CODBEM")[1])),TAMSX3("T9_CODBEM")[1])

		HttpSession->TQB_NOMBEM := M->TQB_NOMBEM := ""
		HttpSession->TQB_CCUSTO := M->TQB_CCUSTO := ""
		HttpSession->TQB_NOMCUS := M->TQB_NOMCUS := ""
		HttpSession->TQB_CENTRA := M->TQB_CENTRA := ""
		HttpSession->TQB_NOMCTR := M->TQB_NOMCTR := ""
		HttpSession->TQB_CDSERV := ""
		HttpSession->TQB_NMSERV := ""
		HttpSession->TQB_TIPOSS := ""

		M->TQB_DESCSS := HttpSession->TQB_DESCSS

		If !Empty(cValor)
			dbSelectArea("ST9")
			dbSetOrder(1)
			If dbSeek(xFilial("ST9")+M->TQB_CODBEM)
				lBEMLOC := .T.
				cTipoSS := "B"
			Else
				lBEMLOC := .F.
				cTipoSS := "L"
			Endif

			aRet := NG280BEMLOC(cTipoSS,.T.)

			If aRet[1]
				HttpSession->TQB_TIPOSS := cTipoSS

				HttpSession->TQB_NOMBEM := M->TQB_NOMBEM
				HttpSession->TQB_CCUSTO := M->TQB_CCUSTO
				HttpSession->TQB_NOMCUS := M->TQB_NOMCUS
				HttpSession->TQB_CENTRA := M->TQB_CENTRA
				HttpSession->TQB_NOMCTR := M->TQB_NOMCTR
				HttpSession->TQB_DESCSS := M->TQB_DESCSS

				//Carrega Questionario
				If cTipoSS == "L"
					cFamMod  := aRet[3] + Space(TamSX3('T9_TIPMOD')[1])
				Else
					cFamMod  := aRet[3]
				EndIf

				HttpSession->cSupAtu := "001"
				If FindFunction("MNT280PERG")
					HttpSession->aQUEST  := MNT280PERG("001",.T.,,"")
				Else
					HttpSession->aQUEST  := {}
				Endif

				//-------------------------------------//
				//Executa ponto de entrada apos sistema//
				//-------------------------------------//
				// As variaveis abaixo podem ser acessadas pelo Ponto de Entrada
				// lPERet indica validacao .T./.F., cPEMsg mensagem mostrada na tela (para "" nao sera mostrada)
				cPECodBem := M->TQB_CODBEM
				cPETipoOS := cTipoSS
				lPERet    := .T.
				cPEMsg    := ""
				cPETpMsg  := "A"
				aArea     := GetArea()

				If ExistBlock("MNTI5001")
					ExecBlock("MNTI5001",.F.,.F.)
				EndIf

				RestArea(aArea)
				If lPERet
					cPEMsg    := aRet[2]
					cPETpMsg  := "C"
				Endif

			Else//Utiliza variaveis do ponto para mostrar mensagens de erro
				lPERet    := .F.
				cPEMsg    := aRet[2]
				cPETpMsg  := "A"
			Endif
		Endif

		If Empty(cValor) .or. !lPERet

			If Empty(cValor)
				HttpSession->TQB_CODBEM := ""
			Endif

			HttpSession->TQB_NOMBEM := ""
			HttpSession->TQB_CCUSTO := ""
			HttpSession->TQB_NOMCUS := ""
			HttpSession->TQB_CENTRA := ""
			HttpSession->TQB_NOMCTR := ""
			HttpSession->TQB_TIPOSS := ""
			HttpSession->cSupAtu    := "001"
			HttpSession->aQUEST     := {}
		EndIf

		If !(cPETpMsg $ "AC")
			cPETpMsg := "A"
		EndIf
		/******PE5001******/

		If !Empty(cValor) .And. !lPERet
			HttpSession->cValidacao := "txtTQB_CODBEM"+"#"+If(lPERet,"1","0")+"#"+cPETpMsg+"#"+cPEMsg+"#"+If(lPERet .and. !Empty(cPEMsg),"fcDiag();","")+"#"
			HttpSession->TQB_CODBEM := ""
		EndIf

	WEB EXTENDED END

Return h_MNTI0052()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณI05CTAFI   ณ Autor ณ Ricardo Dal Ponte     ณ Data ณ03/01/2007ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณConsulta Estrutura Organizacional                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณSIGAMNT                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Web Function I05CTAFI()

	Local cHtml     := ""
	Local cPesquisa := " "
	Local cIndCon   := "8"
	Local nDados	:= 0
	Local nTamTAF   := FWTamSX3( 'TAF_CODNIV' )[1]
	Local aArea 	:= TAF->(GetArea())

	dbSelectArea("TAF")
	dbSetOrder(1)
	nDados := TAF->(RecCount())
	RestArea(aArea)

	If Type("HttpPost->cFilho") == "U"
		HttpSession->cFilho := Replicate( '0', nTamTAF )
	Else
		HttpSession->cFilho := HttpPost->cFilho
	EndIf

	If Type("HttpPost->cPES") != "U"
		cPesquisa := HttpPost->cPES
	EndIf

	If Type("HttpPost->nIndCon") != "U"
		cIndCon := HttpPost->nIndCon
	EndIf

	WEB EXTENDED INIT cHtml START "I005ENV"

	If nDados > 3000

		If !Empty(HttpSession->txt_Nome)

			//Carrega variaveis de sessao
			HttpSession->cConPad   := "TAF"
			HttpSession->cCampo    := "txtTQB_CODBEM"
			HttpSession->cAliasCon := "TAF"
			HttpSession->nIndCon   := cIndCon
			HttpSession->cPES	   := cPesquisa
			HttpSession->cPages    := "0;"
			HttpSession->cCurPg    := "1"

			cHtml += ExecInPage("MNTI0064")
		Else
			I05CLEAR()//Restaura variaveis
			cHtml := W_PORTALNG(.T.)
		EndIf

	Else

		cHtml += ExecInPage("MNTI0056")

	EndIf

	WEB EXTENDED END

Return cHtml

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณI005ENV   ณ Autor ณ Ricardo Dal Ponte     ณ Data ณ22/01/2007ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณAbre o enviremont definido na tela de login pelo usuario    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAMNT                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function I005ENV()

	If Empty(HttpSession->txt_Nome) .Or. HttpSession->txt_Nome == Nil
		W_PORTALNG(.T.)
		Return ""
	EndIf

	fConfigEnv(HttpSession->cCODMEMP, HttpSession->cCODMFIL)

Return ''
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณI05PAGBRW  ณ Autor ณ Roger Rodrigues       ณ Data ณ 25/02/10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณTroca de pagina no browse                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณSIGAMNT                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Web Function I05PAGBRW()

	Local cHtml := ""

	WEB EXTENDED INIT cHtml START "I005ENV"

	HttpSession->cCurPg := HttpPost->cCurPg
	HttpSession->cPages := HttpPost->cPages

	cHtml += ExecInPage("MNTI0058")

	WEB EXTENDED END

Return cHtml
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณISXBCALL  บAutor  ณRoger Rodrigues     บ Data ณ  28/02/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณChama tela de consulta padrao                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAMNT                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Web Function ISXBCALL()

Return W_INGCONPAD(HttpGet->TabelaF3,,HttpGet->CampoF3)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณINGCONPAD บAutor  ณRoger Rodrigues     บ Data ณ  28/02/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณChama tela de consulta padrao                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAMNT                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Web Function INGCONPAD(cConPad, cPesquisa, cCampo, nIndCon)

	Local i, aUsers := {}, nIndex := 0
	Local cHtml := ""
	Local cPages:= ""
	Local cAliasCon := ""
	Local cAliasQry := ""
	Local cTempAli := ""
	Local nQtd  := 0
	Local nTamPage := 10
	Local lRestri := .F.
	Local aArea := {}
	Local cCondPes := ""

	Default cConPad   := HttpSession->cConPad
	Default cPesquisa := ""
	Default nIndCon   := "0"

	WEB EXTENDED INIT cHtml START "I005ENV"

	If !Empty(HttpSession->txt_Nome)

		cPesquisa := Trim(cPesquisa)

		If AllTrim(cConPad) == "QUS"//Consulta de Usuarios
			cConPad := AllTrim(cConPad)

			cAliasCon := "aUsers"
			cTempAli := cAliasCon
			If nIndCon == "0"
				nIndCon := "1"
			Endif
			nIndCon := Val(nIndCon)
			aUsers := FWSFALLUSERS()//Retorna todos usuarios
			aSort( aUsers,,, { |x,y| x[nIndCon] < y[nIndCon] } )//Ordena pelo Indice
			If !Empty(cPesquisa)
				nIndex := aScan(aUsers, {|x| Substr(x[nIndCon],1,Len(cPesquisa)) == AllTrim(cPesquisa)})//Posiciona pela pesquisa
			Endif
			If nIndex < 1
				nIndex := 1
			Endif
			For i:=nIndex to Len(aUsers)
				If Empty(cPesquisa) .or. Substr(aUsers[i][nIndCon],1,Len(cPesquisa)) == cPesquisa
					nQtd++
					If nQtd == 1 .And. Empty(cPages)
						cPages += cValToChar(i)+";"
					ElseIf nQtd == nTamPage
						nQtd := 0
						If i < Len(aUsers)
							cPages += cValToChar(i)+";"
						EndIf
					Endif
				Endif
			Next i
		ElseIf Len(AllTrim(cConPad)) == 2 //Consultas SX5
			cConPad := Padr(cConPad, 2)

			cAliasCon := "SX5"
			cTempAli := cAliasCon
			If nIndCon == "0"
				nIndCon := "1"
			Endif

			nIndCon := Val(nIndCon)

			dbSelectArea(cAliasCon)
			dbSetOrder(nIndCon)
			cPesquisa := cConPad + cPesquisa
			If "_FILIAL"$Substr(IndexKey(),1,10)
				cPesquisa := xFilial(cAliasCon)+cPesquisa
			Endif
			If !Empty(Alias())
			dbSeek(cPesquisa)
			Else
				dbCloseArea()
				RpcSetType(3)
				RPCSetEnv(HttpSession->cCODMEMP,HttpSession->cCODMFIL,"","","MNT","",)
				dbSelectArea(cAliasCon)
				dbSetOrder(nIndCon)
				If !Empty(Alias())
					dbSeek(cPesquisa)
				EndIf
			EndIf
			While !Eof() .And. Substr(&(cAliasCon+"->("+IndexKey()+")"),1,Len(cPesquisa)) == cPesquisa
				nQtd++
				If nQtd = 1 .And. Empty(cPages)
					cPages += cValToChar((cAliasCon)->(RecNo()))+";"
				ElseIf nQtd = nTamPage
					nQtd := 0
					(cAliasCon)->(dbSkip())
					If (cAliasCon)->(!Eof())
						cPages += cValToChar((cAliasCon)->(RecNo()))+";"
					EndIf
				Else
					(cAliasCon)->(dbSkip())
				EndIf
			End

		Else //Consultas normais
			cConPad := Padr(cConPad, 6)

			dbSelectArea("SXB")
			dbSetOrder(1)
			If dbSeek(cConPad+"101")
				cAliasCon := AllTrim(SXB->XB_CONTEM)
				cTempAli    := cAliasCon
			Endif
			If dbSeek(cConPad+"201") .and. nIndCon == "0"
				nIndCon := AllTrim(SXB->XB_COLUNA)
			Endif

			nIndCon := Val(nIndCon)

			If cAliasCon <> 'ST9'
				dbSelectArea(cAliasCon)
				dbSetOrder(nIndCon)
				If "_FILIAL"$Substr(IndexKey(),1,10)
					cPesquisa := xFilial(cAliasCon)+cPesquisa
				Endif
			EndIf

			If !Empty(Alias())
				dbSeek(cPesquisa)
			Else
				dbCloseArea()
				RpcSetType(3)
				RPCSetEnv(HttpSession->cCODMEMP,HttpSession->cCODMFIL,"","","MNT","",)
				dbSelectArea(cAliasCon)
				dbSetOrder(nIndCon)
				If !Empty(Alias())
					dbSeek(cPesquisa)
				EndIf
			EndIf

			If AllTrim(cConPad) == "ST9"
				cIndST9  := &( cTempAli )->( IndexKey( nIndCon ) )
				cCondPes := StrTran( cIndST9, "+", " || " ) + " LIKE "
				cAliasQry := GetNextAlias()
				cQuery := " SELECT R_E_C_N_O_, ST9.T9_CODBEM FROM "  + RetSQLName("ST9")+" ST9 "
				cQuery += " WHERE ST9.T9_FILIAL  = "  + ValToSQL(xFilial("ST9"))
				cQuery += "   AND " + cCondPes        + ValToSql('%'+cPesquisa+'%')
				cQuery += "   AND ST9.T9_SITMAN  = 'A' "
				cQuery += "   AND ST9.T9_SITBEM  = 'A' "
				cQuery += "   AND ST9.D_E_L_E_T_ <> '*' "

				If ExistBlock( 'MNTI005A' )
					cQuery += ExecBlock( 'MNTI005A', .F., .F. )
				EndIf

				cQuery += " ORDER BY T9_CODBEM || T9_NOME "
				cQuery := ChangeQuery(cQuery)
				MPSysOpenQuery( cQuery , cAliasQry )
			EndIf

			//Verifica se possui registro de restri็ใo de acesso
			aArea := GetArea()
			dbSelectArea("TUA")
			dbSetoRder(1)
			If dbSeek(xFilial("TUA"))
				lRestri := .T.
			EndIf
			lRestri := .F.
			RestArea(aArea)
			While If(cAliasCon == "ST9", (cAliasQry)->(!Eof()), (cTempAli)->(!Eof())) .And.;
				IIf (cAliasCon == "ST9", .T. , Substr(&(cAliasCon+"->("+IndexKey()+")"),1,Len(cPesquisa)) == cPesquisa)

				If cAliasCon == "ST9" .And. lRestri

					dbSelectArea("ST9")
					dbGoTo((cAliasQry)->R_E_C_N_O_)
					If FindFunction("MNT280FBEM") .and. !MNT280FBEM(ST9->T9_CODBEM)
						(cAliasQry)->(dbSkip())
						Loop
					Endif
					dbSelectArea("TAF")
					dbSetOrder(6)
					If AliasInDic("TUB") .and. FindFunction("MNT902REST") .and. dbSeek(xFilial("TAF")+"X"+"1"+ST9->T9_CODBEM) .and. !MNT902REST(TAF->TAF_CODNIV,"S","I")
						(cAliasQry)->(dbSkip())

						Loop
					Endif
					dbSelectArea("ST9")
				EndIf
				
				nQtd++
				
				If nQtd == 1 .And. Empty(cPages)

					If cAliasCon == 'ST9'

						cPages += cValToChar( Trim( (cAliasQry)->T9_CODBEM ) ) + ';'

						(cAliasQry)->( dbSkip() )

					Else
						
						cPages += cValToChar( (cAliasCon)->( RecNo() ) ) + ';'

						(cAliasCon)->( dbSkip() )

					EndIf

				ElseIf nQtd > nTamPage

					nQtd := 0

					If cAliasCon == 'ST9'

						If (cAliasQry)->( !EoF() )
							cPages += cValToChar( Trim( (cAliasQry)->T9_CODBEM ) ) + ';'
						EndIf

					Else

						If (cAliasCon)->(!Eof())
							cPages += cValToChar( (cAliasCon)->(RecNo())) +";"
						EndIf

					EndIf

				Else
					IIf( cAliasCon == "ST9", (cAliasQry)->(dbSkip()), (cAliasCon)->(dbSkip()) )
				EndIf

			End

			If Select(cAliasQry) > 0 .and. !empty(cAliasQry)
				(cAliasQry)->(dbCloseArea())
			EndIf

		EndIf

		If Empty(cPages)
			cPages := "0;"
		Endif

		//Carrega variaveis de sessao
		HttpSession->cConPad   := cConPad
		HttpSession->cCampo    := cCampo
		HttpSession->cAliasCon := cAliasCon
		HttpSession->nIndCon   := nIndCon
		HttpSession->cPES	   := cPesquisa
		HttpSession->cPages    := cPages
		HttpSession->cCurPg    := "1"

		cHtml += ExecInPage("MNTI0059")
	Else
		I05CLEAR()//Restaura variaveis
		cHtml := W_PORTALNG(.T.)
	EndIf

	WEB EXTENDED END

Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณINGCONPESQ ณ Autor ณRoger Rodrigues        ณ Data ณ28/02/2011ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณUtilizado na pesquisa da Consulta padrao                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณSIGAMNT                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Web Function INGCONPESQ()

Return W_INGCONPAD(HttpPost->cConPad, HttpPost->cPESQUISA, HttpSession->cCampo, HttpPost->indices)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณINGPAGCON  ณ Autor ณRoger Rodrigues        ณ Data ณ 28/02/11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณTroca de pagina na consulta padrao                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณSIGAMNT                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Web Function INGPAGCON()

	Local cHtml := ""

	WEB EXTENDED INIT cHtml START "I005ENV"

	HttpSession->cCurPg := HttpPost->cCurPg
	HttpSession->cPages := HttpPost->cPages

	cHtml += ExecInPage("MNTI0059")

	WEB EXTENDED END

Return cHtml
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIDIAGCALL บAutor  ณRoger Rodrigues     บ Data ณ  02/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณChama tela de Questionแrio de Sintomas                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAMNT                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Web Function IDIAGCALL()

	Local cHtml := ""
	Local lFirst:= .F.
	Local nPos := 0, nAt, n2At, i
	Local aOpcoes  := HttpSession->aQUEST
	Local cSupAtu  := "001", cTipAtu  := "1", cEscolha := ""
	Local lPaiPerg := .F., lVolta := .F.

	WEB EXTENDED INIT cHtml START "I005ENV"

	//Carrega variaveis
	If HttpGet->cSupAtu != Nil
		cSupAtu := AllTrim(HttpGet->cSupAtu)
		nOpcao  := Val(HttpGet->nOpcao)
		lFirst  := .T.
	Else
		nOpcao   := HttpSession->nOpcao
		cSupAtu  := HttpSession->cSupAtu
		cTipAtu  := HttpSession->cTipAtu
		cEscolha := HttpSession->cEscolha
		lPaiPerg := HttpSession->lPaiPerg
	Endif

	If HttpGet->nVolta != Nil
		lVolta := (HttpGet->nVolta == "1")
	Endif

	nAt := aScan(aOpcoes, {|x| x[__POS_OPCSUP__] == cSupAtu})
	If nAt == 0//Encerra pagina
		cHtml += " <script language='JavaScript'> "
		cHtml += " alert('Nใo existem op็๕es a serem respondidas'); "
		cHtml += " window.close(); "
		cHtml += " </script> "
		Return cHtml
	Endif
	cTipAtu  := aOpcoes[nAt,__POS_OPCTIP__]
	lPaiPerg := (aOpcoes[nAt,__POS_OPCTIP__] == "2")

	//Marca o item selecionado e desmarca os demais do mesmo nivel
	If HttpGet->nPos != Nil
		nPos := Val(HttpGet->nPos)
		If nPos > 0
			For i:= 1 To Len(aOpcoes[nAt,__POS_OPCPER__])
				If i == nPos
					aOpcoes[nAt,__POS_OPCPER__,i,__POS_MARCAD__] := 1
					aOpcoes[nAt,__POS_OPCPER__,i,__POS_IMAGEM__] := "C"
				Else
					If aOpcoes[nAt,__POS_OPCPER__,i,__POS_MARCAD__] <> 0
						aOpcoes[nAt,__POS_OPCPER__,i,__POS_MARCAD__] := 0
						aOpcoes[nAt,__POS_OPCPER__,i,__POS_IMAGEM__] := "C"
					Endif
				Endif
			Next i
		Endif
	Endif

	If !lFirst//Remonta tela

		If !lVolta//Proximo
			If nPos > 0
				//Limpa Variaveis de tela
				HttpSession->TQB_CDSERV := ""
				HttpSession->TQB_NMSERV := ""
				HttpSession->TQB_DESCSS := A280MTRESP(aOpcoes, HttpSession->TQB_DESCSS,.T.)
				If lPaiPerg//Se for pergunta, pega o selecionado
					cEscolha := Substr(aOpcoes[nAt,__POS_OPCPER__,nPos,__POS_DESCRI__],1,1)
				Endif
				cSupAtu := aOpcoes[nAt,__POS_OPCPER__,nPos,__POS_CODNIV__]
				nAt := aScan(aOpcoes, {|x| x[__POS_OPCSUP__] == cSupAtu})
				cHtml += W_I05ATUMEMO((nAt == 0))
				If nAt == 0 //Encerra pagina
					Return cHtml
				Endif
				cTipAtu  := aOpcoes[nAt,__POS_OPCTIP__]
			Endif
		Else//Anterior
			//Configura item superior
			cSupAtu := aOpcoes[nAt,__POS_OPCPAN__]
			nAt := aScan(aOpcoes, {|x| x[__POS_OPCSUP__] == cSupAtu})
			cTipAtu  := aOpcoes[nAt,__POS_OPCTIP__]
			//Verifica se era uma pergunta
			If (n2At := aScan(aOpcoes, {|x| x[__POS_OPCSUP__] == aOpcoes[nAt,__POS_OPCPAN__]})) > 0
				lPaiPerg := (aOpcoes[n2At,__POS_OPCTIP__] == "2")
				If lPaiPerg//Se for pergunta, pega o selecionado
					nPos := aScan(aOpcoes[n2At,__POS_OPCPER__], {|x| x[__POS_MARCAD__] > 0})
					If nPos > 0
						cEscolha := Substr(aOpcoes[n2At,__POS_OPCPER__,nPos,__POS_DESCRI__],1,1)
					Endif
				Endif
			Endif
		Endif
	Endif
	If nAt == 0 .or. Len(aOpcoes[nAt,__POS_OPCPER__]) == 0//Encerra Pagina
	cHtml += " <script language='JavaScript'> "
	cHtml += " window.close(); "
	cHtml += " </script> "
	Return cHtml
	Endif


	HttpSession->nAt := nAt
	HttpSession->nOpcao  := nOpcao
	HttpSession->cSupAtu := cSupAtu
	HttpSession->cTipAtu := cTipAtu
	HttpSession->lPaiPerg:= lPaiPerg
	HttpSession->cEscolha:= cEscolha
	HttpSession->aQUEST  := aOpcoes

	cHtml += ExecInPage("MNTI0060")

	WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณI05VLDCPO บAutor  ณRoger Rodrigues     บ Data ณ  01/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณChama Validacao dos campos da tela                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMNTI0052                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Web Function I05VLDCPO()

	Local cHtml  	:= ''
	Local cMsgErro	:= ''
	Local cValor 	:= If(!Empty(HttpGet->cValor),Trim(HttpGet->cValor),"")
	Local cCampo 	:= If(!Empty(HttpGet->cCampo),Trim(HttpGet->cCampo),"")
	Local lEmpty 	:= .F.

	cUserName := HttpSession->txt_Nome//Para validacao de Restricao de acesso

	If Empty(cUserName) .Or. cUserName == Nil
		W_PORTALNG(.T.)
		Return ""
	EndIf

	WEB EXTENDED INIT cHtml START "I005ENV"

		I05REFRESH()

		If cCampo == "TQB_CODBEM"
			Return W_I05CODBEM(cValor)
		ElseIf cCampo == "TQB_CDSERV"
			Return W_I05CDSERV(cValor)
		ElseIf cCampo == "TQB_CDSOLI"
			Return W_I05CDSOLI(cValor)
		ElseIf ExistBlock("MNTI5007")
			cMsgErro	:= ExecBlock( 'MNTI5007', .F., .F., { cCampo, cValor } )
			lEmpty 		:= Empty(cMsgErro)
			HttpSession->cValidacao := "txt" + cCampo + "#" + IIf(lEmpty,"1","0") + "#" + IIf( lEmpty, "", "A" ) + "#" + cMsgErro + "#" + " #"
		Endif

		cHtml += ExecInPage("MNTI0052")
	WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณI05HEADER บAutor  ณRoger Rodrigues     บ Data ณ  23/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna inicio de pagina html, importando CSS               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Web Function I05HEADER(cTitulo, cArqCSS, lCSSPad)

	Local cHtml := ""
	Default cArqCSS := ""
	Default lCSSPad := .T.

	cHtml += '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">'
	cHtml += '<html>'
	cHtml += '<head>'
	cHtml += '	<title>'
	cHtml += '	'+cTitulo
	cHtml += '	</title>'
	cHtml += '	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">'
	If lCSSPad
		cHtml += '	<link rel="stylesheet" type="text/css" href="NGCSS.css">'
	Endif
	If !Empty(cArqCSS)
		cHtml += '	<link rel="stylesheet" type="text/css" href="'+cArqCSS+'">'
	Endif
	cHtml += '</head>'

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณI05TOPO   บAutor  ณRoger Rodrigues     บ Data ณ  23/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna HTML padrao do topo da pagina                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Web Function I05TOPO()

	Local cHtml := ""
	Local cHome := IIf(fVerFluig("") != "2","W_IREDIRECT.APW","W_PORTALNG.APW")

	cHtml += '<div id="divTopo">'
	cHtml += '	<div id="divGradiente">'
	cHtml += '		<div id="divTotvs" class="divCentralizada">'
	cHtml += '			<div id="logoTotvs" style="float: left; margin: 5pt 0pt 0pt 0pt;">'
	cHtml += '				<a href="http://www.totvs.com" target="_blank"><img src="ng_logo_totvs.png" onerror="fShowErrImg()" border="0"/></a>'
	cHtml += '			</div>'
	cHtml += '			<div id="tituloGeral" style="padding: 18pt 0pt 0pt 0pt;">'
	cHtml += '				<a href="http://www.totvs.com" target="_blank">'
	cHtml += '					<span class="labels" style="font-size: 28px; margin: 0pt 0pt 0pt 15pt;">'
	cHtml += '						Portal de Solicita&ccedil;&atilde;o de Servi&ccedil;o'
	cHtml += '					</span>'
	cHtml += '				</a>'
	cHtml += '			</div>'
	cHtml += '		</div>'
	cHtml += '	</div>'
	cHtml += '	<div id="divAzul">'
	cHtml += '		<div id="divNG" class="divCentralizada">'
	cHtml += '			<div id="conteudoNG" class="divtitulo">'
	cHtml += '				<div id="home" style="float: left; margin: 4pt 0pt 0pt 0pt;">'
	cHtml += '					<span style="padding: 0pt 0pt 0pt 14pt; font-weight: bold;"><a href="' + cHome + '">HOME</a></span>'
	cHtml += '				</div>'
	cHtml += '				<div id="logoNG" style="float: right; padding: 0pt 5pt 0pt 0pt;">'
	cHtml += '					<a href="http://www.ngi.com.br" target="_blank"><img src="ng_logo_ng.png" border="0" height="20px"/></a>'
	cHtml += '				</div>'
	cHtml += '			</div>'
	cHtml += '		</div>'
	cHtml += '	</div>'
	cHtml += '</div>'

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณI05CABEC  บAutor  ณRoger Rodrigues     บ Data ณ  23/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna HTML do cabecalho padrao da tela                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Web Function I05CABEC(cTitulo)

	Local cHtml := ""

	cHtml += '<div class="divCentralizada" id="divCabec">'
	cHtml += '	<div id="bordaCabec" style="width: 100%;">'
	cHtml += '		<b class="bordaEsqAzul1"></b><b class="bordaEsqAzul2"></b><b class="bordaEsqAzul3"></b><b class="bordaEsqAzul4"></b>'
	cHtml += '		<div id="tituloCabec" class="divtitulo" style="width: 100%; height:15px;">'
	cHtml += '			<span style="padding: 0pt 0pt 0pt 18pt">'+cTitulo+'</span>'
	cHtml += '		</div>'
	cHtml += '		<b class="bordaDirAzul4"></b><b class="bordaDirAzul3"></b><b class="bordaDirAzul2"></b><b class="bordaDirAzul1"></b>'
	cHtml += '	</div>'
	cHtml += '</div>'

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณI05CONTEUDบAutor  ณRoger Rodrigues     บ Data ณ  23/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorn HTML padrao de div de conteudo                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Web Function I05CONTEUD(cHeight)

	Local cHtml := ""
	Default cHeight := ""

	cHtml += '<div id="bordaTopo" class="divCentralizada">'
	cHtml += '	<b class="bordaDirBranca1"></b><b class="bordaDirBranca2"></b><b class="bordaDirBranca3"></b><b class="bordaDirBranca4"></b>'
	cHtml += '</div>'
	cHtml += '<div class="divCentralizada" id="divConteudo" '
	If !Empty(cHeight)
		cHtml += 'style="height: '+cHeight+'"'
	Endif
	cHtml += '>'

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณI05RODAPE บAutor  ณRoger Rodrigues     บ Data ณ  23/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna Html padrao de rodape do conteudo                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Web Function I05RODAPE(lMostra)

	Local cHtml := ""
	Local cEmpFil	:= ""
	Local nX		:= 0
	Default lMostra := .F. // Define se mostra ou nใo a empresa e filial no rodap้

	If HttpSession->PWSaEMPFIL == Nil
		HttpSession->PWSaEMPFIL	:= {}
	EndIf

	cHtml += '<div id="rodape" class="divCentralizada">'
	cHtml += '	<b class="bordaBranca4"></b><b class="bordaBranca3"></b><b class="bordaBranca2"></b><b class="bordaBranca1"></b>'
	cHtml += '</div>'

	If lMostra // Verifica se mostra a legenda azul com a empresa e a filial corrente
		For nX := 1 To Len(HttpSession->PWSaEMPFIL) // Passa por todos os registros do array com empresa e filial
			If HttpSession->PWSaEMPFIL[nX][1] == HttpSession->cCODMEMP .And. HttpSession->PWSaEMPFIL[nX][2] == HttpSession->cCODMFIL // Verifica se o codigo for igual a empresa e filial atual
				cEmpFil := " "+HttpSession->PWSaEMPFIL[nX][4]+" / "+HttpSession->PWSaEMPFIL[nX][3] // Guarda a descricao da empresa e filial
			EndIf
		Next nX // Proximo registro
		cHtml += '<div class="divCentralizada" id="divCabec">'
		cHtml += '	<div id="bordaCabec" style="width: 100%;">'
		cHtml += '		<b class="bordaEsqAzul1"></b><b class="bordaEsqAzul2"></b><b class="bordaEsqAzul3"></b><b class="bordaEsqAzul4"></b>'
		cHtml += '		<div id="tituloCabec" class="divtitulo" style="width: 100%; height:15px;">'
		cHtml += '			<span style="padding: 0pt 0pt 0pt 18pt">Empresa/Filial:'+cEmpFil+'</span>'
		cHtml += '		</div>'
		cHtml += '		<b class="bordaDirAzul4"></b><b class="bordaDirAzul3"></b><b class="bordaDirAzul2"></b><b class="bordaDirAzul1"></b>'
		cHtml += '	</div>'
		cHtml += '</div>'
	EndIf

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณI05ATUMEMOบAutor  ณRoger Rodrigues     บ Data ณ  13/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna script para atualizacao de campos da tela de        บฑฑ
ฑฑบ          ณcadastro pelo questionario                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMNTI0060                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Web Function I05ATUMEMO(lClose)

	Local cHtml := ""

	Default lClose := .F.

	cHtml += "<script language='JavaScript'> "
	cHtml += 'window.opener.document.getElementById("txtTQB_CDSERV").value = "'+HttpSession->TQB_CDSERV+'";'
	cHtml += 'window.opener.document.getElementById("txtcCDSERV").value = "'+HttpSession->TQB_CDSERV+'";'
	cHtml += 'window.opener.document.getElementById("txtTQB_NMSERV").value = "'+HttpSession->TQB_NMSERV+'";'
	cHtml += 'window.opener.document.getElementById("txtTQB_DESCSS").innerHTML = "'+HttpSession->TQB_DESCSS+'";'
	cHtml += 'window.opener.document.getElementById("cDESCSS").value = window.opener.document.getElementById("txtTQB_DESCSS").value;'

	If lClose
		//Refresh por causa do IE e do FF
		cHtml += 'window.opener.document.MNTI0052.action = "'+"W_I05VLDCPO.APW?cValor=''&cCampo='DIAG'"+'";'
		cHtml += "window.opener.document.MNTI0052.submit();"
		cHtml += "close(); "
	Endif

	cHtml += "</script> "

Return cHtml

//------------------------------------------------------------------------
/*/{Protheus.doc} fVerFluig

Verifica se o sistema estแ sendo carregado via Fluig.

@author  Maicon Andr้ Pinheiro
@since   10/07/2017
@version P12
@return  cRet
/*/
//-------------------------------------------------------------------------
Static Function fVerFluig(cEnvLogin)

	Local cRet        := "2" //Nใo logado via Fluig
	Local cEnviromnt  := GetPvProfString("HTTP", "Environment", "",GetAdv97())
	Local cLocation   := ""
	Local cTSTRespJob := ""
	Local cHost       := "http://" + httpHeadin->HOST

	Default cEnvLogin := ''

	If Type("HttpSession->SAMLSESSION") != "U" // SAML estแ preenchido entใo o sistema foi chamado diretamente do Fluig
		cRet := "0"
	Else
		//Caso SAML nใo esteja preenchido pode ter sido chamado do Fluig tamb้m por้m tendo ocorrido erro de TimeOut
		If !Empty(cEnvLogin)
			cEnviromnt := cEnvLogin
		EndIf

		cTSTRespJob := "FACILITIES_" + cEnviromnt
		cLocation   := GetPvProfString(cTSTRespJob,"Location","",GetADV97())

		If cHost == cLocation //Chamada via Fluig com erro de TimeOut ou com perca do SAML
			If Type("__cUserId") != "U" .And. !Empty(__cUserId)
				HttpSession->UserID := __cUserId
			EndIf
			cRet := "1"
		EndIf

	EndIf

Return cRet

//------------------------------------------------------------------------
/*/{Protheus.doc} SWMNT

Fun็ใo que prepara o ambiente na inicializa็ใo das working threads

@author  Maicon Andr้ Pinheiro
@since   10/07/2017
@version P12
@return  cRet
/*/
//-------------------------------------------------------------------------
Function SWMNT()

	Local cEnvi    := GetPvProfString("HTTP", "Environment", "",GetAdv97())
	Local cRespJob := "FACILITIES_"+cEnvi
	Local cEmpFac  := GetPvProfString(cRespJob, "WebEmpresa", "",GetAdv97())
	Local cFilFac  := GetPvProfString(cRespJob, "WebFilial", "",GetAdv97())
	Local cSetEnv  := GetPvProfString(cRespJob, "PREPAREIN", "",GetAdv97())
	Local aSetEnv  := {}

	If !Empty(cEmpFac) .And. !Empty(cFilFac)
		aSetEnv := {cEmpFac,cFilFac}
	Else
		aSetEnv := StrTokArr(cSetEnv,",")
	EndIf

	StartWebex() //P.E. executado na inicializa็ใo de cada Working Thread, quando utilizada a configura็ใo para a Lib APWEBEX.

	If Len(aSetEnv) > 0

		If (Select("SX3") == 0) .Or. ((Type("cEmpAnt") == "C" .And. cEmpAnt <> aSetEnv[1]) .Or. (Type("cFilAnt") == "C" .And. cFilAnt <> aSetEnv[2])  )
			RpcClearEnv()
			RpcSetType(3)
			RpcSetEnv(LTrim(aSetEnv[1]),LTrim(aSetEnv[2]))
		EndIf

		__cLocation     := GetPvProfString(cRespJob,"LOCATION","",GetADV97())
		__cSPIssuerName := GetPvProfString(cRespJob,"SPISSUERNAME","",GetADV97())

	EndIf

Return .T.

//------------------------------------------------------------------------
/*/{Protheus.doc} Login

Fun็ใo que faz a chamada do AppServer configurado como Service Provider
para realizar o login pelo Fluig Identity

@author  Maicon Andr้ Pinheiro
@since   10/07/2017
@version P12
@return  cRet
/*/
//-------------------------------------------------------------------------
Web Function Login()

	Local cHTML      := ""
	Local cSPIsName  := ""
	Local cRedirect  := ""
	Local cHeaderRet := ""
	Local aHeadStr   := {}

	Private __cMessage := ''

	cRedirect := __cLocation + '/w_redirect.apw'
	cSPIsName := __cSPIssuerName

	Aadd(aHeadStr, 'generateSamlRequest: ' + MD5(cSPIsName, 2))
	cHTML := HTTPGet(cSPIsName + '/saml2/get/url' , cRedirect,, aHeadStr, @cHeaderRet )

	If Empty(cHTML)
		cHTML := "<script>alert('" + STR0013 + "')</script>" //"Nใo houve resposta do Service Provider, favor consultar a FAQ MNT0073."
	EndIf

Return cHTML

//------------------------------------------------------------------------
/*/{Protheus.doc} Index

Fun็ใo de entrada no portal de SS via Fluig

@author  Maicon Andr้ Pinheiro
@since   10/07/2017
@version P12
@return  cRet
/*/
//-------------------------------------------------------------------------
Web Function Index()

	Local cHTML   := ""
	Local aPswRet := {}

	WEB EXTENDED INIT cHTML START "W_SETENV"

		PswOrder(1)
		If PswSeek(__cUserId)
			aPswRet := PswRet(1)
			HttpSession->txt_Nome := aPswRet[1,2]
		EndIf

		cHTML := W_PORTALNG()

	WEB EXTENDED END

Return cHTML

//------------------------------------------------------------------------
/*/{Protheus.doc} Redirect
Fun็ใo que redireciona para a entrada do portal de SS ap๓s o login realizado
diretamente pelo fluig.

@author  Maicon Andr้ Pinheiro
@since   10/07/2017
@version P12
@return  cRet
/*/
//-------------------------------------------------------------------------
Web Function Redirect()

	Local cHTML := ""

	WEB EXTENDED INIT cHTML

		If Empty(HttpGet->SAMLSESSION)
			cHTML := "<script>alert('Redirecionamento invแlido')</script>"
		Else
			HttpSession->SAMLSESSION := HttpGet->SAMLSESSION
			cHTML := "<script>location.replace('" + __cLocation + "')</script>"
		EndIf

	WEB EXTENDED END

Return cHTML

//------------------------------------------------------------------------
/*/{Protheus.doc} SetEnv
Fun็ใo que valida a sessใo para realizar o login via fluig

@author  Maicon Andr้ Pinheiro
@since   10/07/2017
@version P12
@return  cHTML
/*/
//-------------------------------------------------------------------------
Web Function SetEnv()

	Local cHTML        := ""
	Local cSAMLSession := HttpSession->SAMLSESSION
	Local cMsgError    := ""
	Local cEnviromnt   := GetPvProfString("HTTP", "Environment", "",GetAdv97())

	If Empty(cSAMLSession)
		cHTML := W_LOGIN()
	ElseIf !FWHTTPAuth('SAML', cSAMLSession, '', @cMsgError)
		HttpSession->SAMLSESSION := ''
		If Empty(cMsgError)
			cMsgError := "Usuแrio nใo configurado para o ambiente " + cEnviromnt
		EndIf
		cHTML :=  "<script>alert('" + cMsgError + "')</script>"
	EndIf

Return cHTML

Function MNTIDesTAF(cCodNiv)

	Local cDescNiv := ""

	dbSelectArea("TAF")
	dbSetOrder(8)
	If dbSeek(xFilial("TAF") + cCodNiv)
		cDescNiv := TAF->TAF_NOMNIV
	EndIf

Return cDescNiv

Function MNTIBscChl(cCodNiv)

	Local lPossuiChl := .F.
	Local cAliasQry  := GetNextAlias()
	Local cQuery     := ""

	cQuery  = "SELECT * "
	cQuery += "  FROM " + RetSQLName("TAF")
	cQuery += " WHERE TAF_FILIAL = " + ValToSQL(xFilial("TAF"))
	cQuery += "   AND TAF_NIVSUP = " + ValToSQL(cCodNiv)
	cQuery += "   AND TAF_INDCON <> '0' "
	cQuery += "   AND D_E_L_E_T_ <> '*' "
	cQuery := ChangeQuery(cQuery)
	MPSysOpenQuery( cQuery , cAliasQry )

	While (cAliasQry)->(!Eof())
		lPossuiChl := .T.
		Exit
	End

Return lPossuiChl

Function MNTIBscPai(cCodNiv)

	Local cNivSup := ""

	dbSelectArea("TAF")
	dbSetOrder(8)
	If dbSeek(xFilial("TAF") + cCodNiv)
		cNivSup := TAF->TAF_NIVSUP
	EndIf

Return cNivSup

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTIFUNC
Efetua busca do executante da SS

@author  Eduardo Mussi
@since   13/04/18
@version P12
@use 	 X3_RELACAO e X3_INIBRW do campo TQB_NMEXEC.
@param	 cCodExec, Caracter, C๓digo do Executante da SS
@return	 cNomeFunc, Caracter, Retorna nome do Executante da SS
/*/
//-------------------------------------------------------------------
Function MNTIFUNC(cCodExec)

	Local cNomeFunc := ''
	Local lFacilit	:= SuperGetMv("MV_NG1FAC",.F.,"2") == '1' //Facilities

	If lFacilit
		cNomeFunc := SUBSTR( POSICIONE("ST1", 1, xFilial("ST1") + cCodExec, "T1_NOME"), 1, 20 )
	Else
		cNomeFunc := SUBSTR( POSICIONE("TQ4", 1, xFilial("TQ4") + cCodExec, "TQ4_NMEXEC"), 1, 20 )
	EndIf

Return cNomeFunc

//-------------------------------------------------------------------
/*/{Protheus.doc} fValMod
Verifica se usuแrio possui acesso ao m๓dulo SIGAMNT ou SIGAGFR

@type   Function

@author Eduardo Mussi
@since  15/07/2021

@Param  aMods, Array, Informa็๕es do menu(Retorno PswRet[3]).
				Ex: [1] = "019\sigaadv\sigaatf.xnu"
            		[2] = "029\sigaadv\sigacom.xnu"

@return L๓gico, Identifica qual a posi็ใo das informa็๕es do m๓dulo 19 ou 95
/*/
//-------------------------------------------------------------------
Static Function fValMod( aMods )

	Local nPosMNT := aScan( aMods, { | x | SubStr( x, 1, 2 ) == '19' } )
	Local nPosGFR := 0
	Local lChkMod := .F.

	// Caso esteja no release 12133 ou superior o ambiente possuirแ o novo modulo,
	// sendo necessแrio validar se o usuแrio possui acesso.
	If nPosMNT > 0
		lChkMod := SubStr( aMods[ nPosMNT ], 3, 1 ) != 'X' // verifica se 19 estแ marcado ( 'X' ้ desmarcado )
	EndIf

	// Caso nใo possua acesso ao m๓dulo SIGAMNT, verifica se existe o m๓dulo 95 no ambiente
	If !lChkMod .And. ( nPosGFR := Ascan( aMods,{ | x | Left( x, 2 ) == '95' } ) ) > 0 // recupera a posi็ใo do m๓dulo 95 - SIGAGFR
		lChkMod := SubStr( aMods[ nPosGFR ], 3, 1 ) != 'X' // verifica se 95 estแ marcado ( 'X' ้ desmarcado )
	EndIf

Return lChkMod

//-------------------------------------------------------------------
/*/{Protheus.doc} fConfigEnv
Realiza acesso a empresa e filial

@author Maria Elisandra de Paula
@since 25/10/2021
@param cEnterprise, string, c๓digo da empresa
@param cBranch, string, c๓digo da filial
@return boolean, se obteve sucesso
/*/
//--------------------------------------------------------------
Static Function fConfigEnv( cEnterprise, cBranch )

	Local lRet := .F.

	//----------------------------------------------------------------
	// Limpa ambiente apenas quando empresa ainda nใo foi definida
	//----------------------------------------------------------------
	If Type( 'cEmpAnt' ) == 'U' .Or. Empty( cEmpAnt )
		RpcClearEnv()
	EndIf

	RpcSetType(3)
	lRet := RPCSetEnv( cEnterprise, cBranch, "", "", "MNT", "" )

	If lRet
		cEmpAnt := cEnterprise
		cFilAnt := cBranch
	EndIf

	If Empty( __cUserID ) .And. !Empty( HttpSession->UserID )

		/*------------------------------------------------------------+
		| Restaura __cUserID nos casos onde a variavel estiver vazia. |
		+------------------------------------------------------------*/
		__cUserID := HttpSession->UserID

	EndIf

Return lRet
