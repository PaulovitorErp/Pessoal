#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MDTM002.CH"

//-------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------
//  _______           _______  _       _________ _______             _______  _______  _______  __    _______  ------
// (  ____ \|\     /|(  ____ \( (    /|\__   __/(  ___  )           (  ____ \/ ___   )/ ___   )/  \  (  __   ) ------
// | (    \/| )   ( || (    \/|  \  ( |   ) (   | (   ) |           | (    \/\/   )  |\/   )  |\/) ) | (  )  | ------
// | (__    | |   | || (__    |   \ | |   | |   | |   | |   _____   | (_____     /   )    /   )  | | | | /   | ------
// |  __)   ( (   ) )|  __)   | (\ \) |   | |   | |   | |  (_____)  (_____  )  _/   /   _/   /   | | | (/ /) | ------
// | (       \ \_/ / | (      | | \   |   | |   | |   | |                 ) | /   _/   /   _/    | | |   / | | ------
// | (____/\  \   /  | (____/\| )  \  |   | |   | (___) |           /\____) |(   (__/\(   (__/\__) (_|  (__) | ------
// (_______/   \_/   (_______/|/    )_)   )_(   (_______)           \_______)\_______/\_______/\____/(_______) ------
//-------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MDTM002
Rotina de Envio de Eventos - Comunicação de Acidente de Trabalho (S-2210)
Realiza a composição do Xml a ser enviado ao Governo

@return cRet, Caracter, Retorna o Xml gerado pela CAT

@sample MDTM002( 3, .T., {}, oModel )

@param nOper, Numérico, Indica a operação que está sendo realizada (3-Inclusão/4-Alteração/5-Exclusão)
@param lIncons, Boolean, Indica se é avaliação de inconsistências das informações de envio
@param aIncEnv, Array, Array que recebe as inconsistências, se houver, das informações a serem enviadas
@param oModelTNC, Objeto, Indica o modelo utilizado para fazer a manipulação dos registros caso seja chamado pelo MDTA640A
@param cChave, Caracter, Chave atual do registro a ser utilizada na busca do registro na RJE
@param cChvNov, Caracter, Chave nova do registro a ser utilizada para verificar se deve buscar o TAFKEY
@param cTAFKey, Caracter, Chave a ser retornado no caso de alteração da data, hora ou tipo do acidente

@author Luis Fellipy Bett
@since	10/07/2018
/*/
//-------------------------------------------------------------------------------------------------------------------
Function MDTM002( nOper, lIncons, aIncEnv, oModelTNC, cChave, cChvNov, cTAFKey )

	Local aArea		:= GetArea()
	Local aAreaTNC	:= TNC->( GetArea() )
	Local cRet		:= ""
	Local cSeekAci	:= ""
	Local nCont		:= 0
	Local nLenGrid	:= 0
	Local oCausa
	Local oParte
	Local aDadFun  := {} //Busca as informações do funcionário

	//Variáveis de chamadas
	Local lXml := IsInCallStack( "MDTGeraXml" ) //Verifica se é geração de Xml

	//Variáveis auxiliares para busca das informações a serem enviadas
	Private cNumMat				:= "" //Matrícula do Funcionário (RA_MAT)
	Private cNomeFun			:= "" //Nome do Funcionário (RA_NOME)
	Private dDtAdm				:= SToD( "" ) //Data de Admissão do Funcionário (RA_ADMISSA)
	Private cCodMedico			:= "" //Código do médico/dentista que emitiu o Atestado (TMT_CODUSU ou TNY_EMITEN)
	Private cCodUF				:= "" //Variável auxiliar para busca do código da UF, caso envio via Middleware
	Private lAtesAcid			:= .F. //Variável de verificação de validação do atendimento pelo acidente
	Private aInfAten			:= {} //Busca as informações do atendimento médico

	//Variáveis das informações a serem envidas
	Private cTpInsc				:= IIf( SM0->M0_TPINSC == 2, "1", IIf( SM0->M0_TPINSC == 3, "2", "" ) ) //Tipo de Inscrição da Empresa
	Private cCpfTrab			:= "" //CPF do Funcionário (RA_CIC)
	Private cMatricula			:= "" //Matrícula do Funcionário a ser considerada no envio (RA_CODUNIC)
	Private cCodCateg			:= "" //Categoria do Funcionário (RA_CATEFD)
	Private dDtAcid				:= SToD( "" ) //Data do Acidente (TNC_DTACID)
	Private cTpAcid				:= "" //Tipo do Acidente (TNC_INDACI)
	Private cHrAcid				:= "" //Hora do Acidente (TNC_HRACID)
	Private cHrsTrabAntesAcid	:= "" //Horas trabalhadas anteriormente ao acidente ()
	Private cTpCat				:= "" //Tipo de CAT (TNC_TIPCAT)
	Private cIndCatObito		:= "" //Indicação de Óbito (TNC_MORTE)
	Private dDtObito			:= SToD( "" ) //Data do Óbito (TNC_DTOBIT)
	Private cIndComunPolicia	:= "" //Indicação de Comunicação à Autoridade Policial (TNC_POLICI)
	Private cCodSitGeradora		:= "" //Código do Situação Geradora do Acidente (TNG_ESOC)
	Private cObsCat				:= "" //Observação da CAT (TNC_DETALH)
	Private cTpLocal			:= "" //Tipo do Local do Acidente (TNC_INDLOC)
	Private cDscLocal			:= "" //Descrição do Local do Acidente (TNC_LOCAL)
	Private cTpLograd			:= "" //Tipo de Logradouro do Acidente (TNC_TPLOGR)
	Private cDscLograd			:= "" //Descrição do Logradouro do Acidente (TNC_DESLOG)
	Private cNrLograd			:= "" //Número do Logradouro do Acidente (TNC_NUMLOG)
	Private cComplemento		:= "" //Complemento do Logradouro do Acidente (TNC_COMPL)
	Private cBairro				:= "" //Bairro do Local do Acidente (TNC_BAIRRO)
	Private cCEP				:= "" //CEP do Local do Acidente (TNC_CEP)
	Private cCodMunic			:= "" //Código do Município do Local do Acidente (Se for Middleware: Código da UF + TNC_CODCID, senão: TNC_CODCID )
	Private cUFAci				:= "" //UF do Local do Acidente (TNC_ESTACI)
	Private cCodPai				:= "" //País do Local do Acidente (C08_PAISSX)
	Private cCodPostal			:= "" //Código de Endereçamento Postal do Acidente (TNC_CODPOS)
	Private cTpInscAci			:= "" //Tipo de Inscrição do Local do Acidente (TNC_TPINS)
	Private cNrInscAci			:= "" //Número de Inscrição do Local do Acidente (TNC_CGCPRE)
	Private aParte				:= {} //Parte Atingida e Lateralidade do Funcionário que sofreu o Acidente (TOI_ESOC e TYF_LATERA)
	Private aCausa				:= {} //Agente Causador do Acidente (TNH_ESOC)
	Private dDtAtendimento 		:= SToD( "" ) //Data do Atendimento do Funcionário que sofreu o Acidente (TNC_DTATEN, TMT_DTATEN ou TNY_DTCONS)
	Private cHrAtendimento 		:= "" //Hora de Atendimento do Funcionário que sofreu o Acidente (TNC_HRATEN, TMT_HRATEN ou TNY_HRCONS)
	Private cIndInternacao		:= "" //Indicativo de Internação do Funcionário que sofreu o Acidente (TNC_INTERN)
	Private cDurTrat 			:= "" //Duração do Tratamento do Funcionário que sofreu o Acidente (TNC_QTAFAS, TMT_QTAFAS ou TNY_QTDTRA)
	Private cIndAfast 			:= "" //Indicativo de Afastamento (TNC_AFASTA, TMT_QTAFAS ou TNY_CODAFA)
	Private cDscLesao			:= "" //Código da Descrição da Natureza da Lesão (TOJ_ESOC)
	Private cDscCompLesao 		:= "" //Descrição Complementar da Lesão (TNC_DESLES)
	Private cDiagProvavel 		:= "" //Diagnóstico Provável do Atendimento (TMT_DIAGNO)
	Private cCodCID				:= "" //CID do Acidente (TNC_CID, TMT_CID ou TNY_CID)
	Private cObservacao			:= "" //Observação do Atendimento (TMT_OUTROS)
	Private cNmEmit 			:= "" //Nome do médico/dentista que emitiu o Atestado (TMK_NOMUSU ou TNP_NOME)
	Private cIdeOC 				:= "" //Órgão de Classe do Emitente do Atestado (TMK_ENTCLA ou TNP_ENTCLA)
	Private cNrOC 				:= "" //Número de Inscrição no Órgão de Classe (TMK_NUMENT ou TNP_NUMENT)
	Private cUfOC 				:= "" //UF do Órgão de Classe (TMK_UF ou TNP_UF)
	Private cNrRecCatOrig		:= "" //Número do Recibo da última CAT, quando a CAT atual ser de reabertura ou de óbito (Se Middleware)
	Private dUltDiaTra			:= StoD( '' )
	Private cHouAfa				:= ''

	Default lIncons	  := .F.
	Default nOper	  := 3
	Default oModelTNC := Nil
	Default cChvNov	  := ""
	Default cTAFKey	  := ""

	If lXml
		cSeekAci := TNC->TNC_FILIAL + TNC->TNC_ACIDEN
	ElseIf lDiagnostico
		cSeekAci := xFilial( "TNC" ) + M->TMT_ACIDEN
	ElseIf lAtestado
		cSeekAci := xFilial( "TNC" ) + M->TNY_ACIDEN
	EndIf

	If lDiagnostico .Or. lAtestado .Or. lXml //Alimenta as variáveis de memória para utilização
		dbSelectArea( "TNC" )
		dbSetOrder( 1 )
		dbSeek( cSeekAci )
		RegToMemory( "TNC", .F., , .F. ) //Carrega os valores do Acidente na memória
	EndIf

	aDadFun := MDTDadFun( M->TNC_NUMFIC )

	//Verifica se valida as informações do atendimento através do acidente
	lAtesAcid := !Empty( M->TNC_DTATEN ) .And. !Empty( M->TNC_HRATEN )

	//Variáveis auxiliares para busca de informações a serem enviadas
	cNumMat	 := aDadFun[1] //Matrícula do Funcionário
	cNomeFun := aDadFun[2] //Nome do Funcionário
	dDtAdm	 := aDadFun[6] //Data de Admissão do Funcionário

	//Busca da informação a ser enviada na tag <cpfTrab>
	cCpfTrab := aDadFun[3] //CPF do Funcionário

	//Busca da informação a ser enviada na tag <matricula>
	cMatricula := aDadFun[4] //Código Único do Funcionário

	//Busca da informação a ser enviada na tag <matricula>
	cCodCateg := aDadFun[5] //Categoria do Funcionário

	//Verifica se existe CAT Origem e busca as informações das tags <dtAcid> e <hrAcid>
	MDTCATOrig( M->TNC_TIPCAT, M->TNC_DTACID, M->TNC_HRACID )

	//Busca da informação a ser enviada na tag <tpAcid>
	cTpAcid	:= M->TNC_INDACI

	//------- Tipo de Acidente de Trabalho -------
	//	1- Acidente Tipico			1- Típico
	//	2- Acidente de Trajeto		3- Trajeto
	//	3- Doenca do Trabalho		2- Doença
	//-----------------------------------
	Do Case
		Case cTpAcid == "2" ; cTpAcid := "3"
		Case cTpAcid == "3" ; cTpAcid := "2"
	End Case

	//Busca da informação a ser enviada na tag <hrsTrabAntesAcid>
	cHrsTrabAntesAcid := StrTran( M->TNC_HRTRAB, ":", "" )

	//Busca da informação a ser enviada na tag <tpCat>
	cTpCat := M->TNC_TIPCAT

	//Busca da informação a ser enviada na tag <indCatObito>
	cIndCatObito := IIf( M->TNC_MORTE == "1", "S", "N" )

	//Busca da informação a ser enviada na tag <dtObito>
	dDtObito := M->TNC_DTOBIT

	//Busca da informação a ser enviada na tag <indComunPolicia>
	cIndComunPolicia := IIf( M->TNC_POLICI == "1", "S", "N" )

	//Busca da informação a ser enviada na tag <codSitGeradora>
	If X3USO( GetSx3Cache( "TNG_ESOC", "X3_USADO" ) )
		If !Empty( Posicione( "TNG", 1, xFilial( "TNG" ) + M->TNC_TIPACI, "TNG_ESOC" ) )
			cCodSitGeradora	:= Posicione( "TNG", 1, xFilial( "TNG" ) + M->TNC_TIPACI, "TNG_ESOC" )
		EndIf
	Else
		If !Empty( Posicione( "TNG", 1, xFilial( "TNG" ) + M->TNC_TIPACI, "TNG_ESOC1" ) )
			cCodSitGeradora	:= Posicione( "TNG", 1, xFilial( "TNG" ) + M->TNC_TIPACI, "TNG_ESOC1" )
		EndIf
	EndIf

	//Busca da informação a ser enviada na tag <obsCAT>
	cObsCat := Alltrim( MDTSubTxt( Upper( SubStr( M->TNC_DETALH, 1, 999 ) ) ) )

	//Busca da informação a ser enviada na tag <tpLocal>
	cTpLocal := M->TNC_INDLOC

	//-------Indica Localização-------
	// 1 - Estab da Empresa;    	1 - Estabelecimento do empregador no Brasil;
	// 2 - Onde Presta Serviço;		3 - Estabelecimento de terceiros onde o empregador presta serviços;
	// 3 - Via Publica;				4 - Via pública;
	// 4 - Area Rural; 				5 - Área rural;
	// 5 - Embarcação				6 - Embarcação;
	// 6 - Exterior					2 - Estabelecimento do empregador no Exterior;
	// 9 - Outros;					9 - Outros.
	//--------------------------------
	Do Case
		Case cTpLocal == "2" ; cTpLocal := "3"
		Case cTpLocal == "3" ; cTpLocal := "4"
		Case cTpLocal == "4" ; cTpLocal := "5"
		Case cTpLocal == "5" ; cTpLocal := "6"
		Case cTpLocal == "6" ; cTpLocal := "2"
	End Case

	//Busca da informação a ser enviada na tag <dscLocal>
	cDscLocal := Alltrim( MDTSubTxt( M->TNC_LOCAL ) )

	//Busca da informação a ser enviada na tag <tpLograd>
	cTpLograd := AllTrim( M->TNC_TPLOGR )

	//Busca da informação a ser enviada na tag <dscLograd>
	cDscLograd := Alltrim( MDTSubTxt( M->TNC_DESLOG ) )

	//Busca da informação a ser enviada na tag <nrLograd>
	cNrLograd := IIf( !Empty( M->TNC_NUMLOG ), cValtoChar( M->TNC_NUMLOG ), "S/N" )

	//Busca da informação a ser enviada na tag <complemento>
	cComplemento := AllTrim( MDTSubTxt( M->TNC_COMPL ) )

	//Busca da informação a ser enviada na tag <bairro>
	cBairro := AllTrim( MDTSubTxt( M->TNC_BAIRRO ) )

	//Busca da informação a ser enviada na tag <cep>
	cCEP := M->TNC_CEP

	//Busca da informação a ser enviada na tag <codMunic>
	If lMiddleware //Caso for envio pelo Middleware, compõe o código do estado junto com o da cidade
		Do Case
			Case M->TNC_ESTACI = "AC" ; cCodUF := "12"
			Case M->TNC_ESTACI = "AL" ; cCodUF := "27"
			Case M->TNC_ESTACI = "AP" ; cCodUF := "16"
			Case M->TNC_ESTACI = "AM" ; cCodUF := "13"
			Case M->TNC_ESTACI = "BA" ; cCodUF := "29"
			Case M->TNC_ESTACI = "CE" ; cCodUF := "23"
			Case M->TNC_ESTACI = "DF" ; cCodUF := "53"
			Case M->TNC_ESTACI = "ES" ; cCodUF := "32"
			Case M->TNC_ESTACI = "GO" ; cCodUF := "52"
			Case M->TNC_ESTACI = "MA" ; cCodUF := "21"
			Case M->TNC_ESTACI = "MT" ; cCodUF := "51"
			Case M->TNC_ESTACI = "MS" ; cCodUF := "50"
			Case M->TNC_ESTACI = "MG" ; cCodUF := "31"
			Case M->TNC_ESTACI = "PA" ; cCodUF := "15"
			Case M->TNC_ESTACI = "PB" ; cCodUF := "25"
			Case M->TNC_ESTACI = "PR" ; cCodUF := "41"
			Case M->TNC_ESTACI = "PE" ; cCodUF := "26"
			Case M->TNC_ESTACI = "PI" ; cCodUF := "22"
			Case M->TNC_ESTACI = "RN" ; cCodUF := "24"
			Case M->TNC_ESTACI = "RS" ; cCodUF := "43"
			Case M->TNC_ESTACI = "RJ" ; cCodUF := "33"
			Case M->TNC_ESTACI = "RO" ; cCodUF := "11"
			Case M->TNC_ESTACI = "RR" ; cCodUF := "14"
			Case M->TNC_ESTACI = "SC" ; cCodUF := "42"
			Case M->TNC_ESTACI = "SP" ; cCodUF := "35"
			Case M->TNC_ESTACI = "SE" ; cCodUF := "28"
			Case M->TNC_ESTACI = "TO" ; cCodUF := "17"
		End Case

		If !Empty( M->TNC_CODCID ) //Caso o usuário tenha informado uma cidade no cadastro, adiciona o código da UF
			cCodMunic := cCodUF + M->TNC_CODCID
		EndIf
	Else
		cCodMunic := M->TNC_CODCID
	EndIf

	//Busca da informação a ser enviada na tag <uf>
	cUFAci := M->TNC_ESTACI

	//Busca da informação a ser enviada na tag <pais>
	cCodPai := Posicione( "C08", 3, xFilial( "C08" ) + M->TNC_CODPAI, "C08_PAISSX" ) //Pega o código esperado pelo eSocial

	//Busca da informação a ser enviada na tag <codPostal>
	cCodPostal := M->TNC_CODPOS

	//Busca da informação a ser enviada na tag <tpInsc>
	cTpInscAci := M->TNC_TPINS

	dUltDiaTra := M->TNC_DTULTI

	cHouAfa := IIf( M->TNC_AFASTA == '1', 'S', 'N' )

	//------- Tipos de Inscrição -------
	//	1- CNPJ			1- CNPJ
	//	2- CAEPF		3- CAEPF
	//	3- CNO			4- CNO
	//-----------------------------------
	Do Case
		Case cTpInscAci == "2" ; cTpInscAci := "3"
		Case cTpInscAci == "3" ; cTpInscAci := "4"
	End Case

	//Busca da informação a ser enviada na tag <nrInsc>
	cNrInscAci := M->TNC_CGCPRE

	//Busca da informação a ser enviada nas tags <codParteAting> e <lateralidade>
	If lAcidente
		oParte := oModelTNC:GetModel( 'TNMPARTE' )
		nLenGrid := oParte:Length()

		For nCont := 1 To nLenGrid //Percorre a Grid para buscar todas as Partes Atingidas
			oParte:GoLine( nCont ) //Posiciona na linha desejada.
			If !( oParte:IsDeleted() ) .And. !Empty( oParte:GetValue( "TYF_CODPAR" ) ) //Verifica se registro não está deletado.
				aAdd( aParte, { Posicione( "TOI", 1, xFilial( "TOI" ) + oParte:GetValue( "TYF_CODPAR" ), "TOI_ESOC" ), oParte:GetValue( "TYF_LATERA" ) } )
				Exit //Sai do laço pra adicionar apenas uma parte (leiaute do eSocial permite apenas uma parte atingida)
			EndIf
		Next nCont
	Else
		dbSelectArea( "TYF" )
		dbSetOrder( 1 )
		If dbSeek( xFilial( "TYF" ) + M->TNC_ACIDEN )
			While !Eof() .And. TYF->TYF_FILIAL == xFilial( "TYF" ) .And. TYF->TYF_ACIDEN == M->TNC_ACIDEN
				aAdd( aParte, { Posicione( "TOI", 1, xFilial( "TOI" ) + TYF->TYF_CODPAR, "TOI_ESOC" ), TYF->TYF_LATERA } )
				Exit //Sai do laço pra adicionar apenas uma parte (leiaute do eSocial permite apenas uma parte atingida)
				TYF->( dbSkip() )
			End
		EndIf
	EndIf

	//Busca da informação a ser enviada na tag <codAgntCausador>
	If lAcidente
		oCausa	 := oModelTNC:GetModel( 'TNMCAUSA' )
		nLenGrid := oCausa:Length()

		For nCont := 1 To nLenGrid // Percorre a Grid para buscar todas as Causa de Acidente
			oCausa:GoLine( nCont ) //Posiciona na linha desejada.
			If !( oCausa:IsDeleted() ) .And. !Empty( oCausa:GetValue( "TYE_CAUSA" ) ) //Verifica se registro não está deletado.
				aAdd( aCausa, { Posicione( "TNH", 1, xFilial( "TNH" ) + oCausa:GetValue( "TYE_CAUSA" ), "TNH_ESOC" ) } )
				Exit //Sai do laço pra adicionar apenas um agente (leiaute do eSocial permite apenas um agente causador)
			EndIf
		Next nCont
	Else
		dbSelectArea( "TYE" )
		dbSetOrder( 1 )
		If dbSeek( xFilial( "TYE" ) + M->TNC_ACIDEN )
			While !Eof() .And. TYE->TYE_FILIAL == xFilial( "TYE" ) .And. TYE->TYE_ACIDEN == M->TNC_ACIDEN
				aAdd( aCausa, { Posicione( "TNH", 1, xFilial( "TNH" ) + TYE->TYE_CAUSA, "TNH_ESOC" ) } )
				Exit //Sai do laço pra adicionar apenas um agente (leiaute do eSocial permite apenas um agente causador)
				TYE->( dbSkip() )
			End
		EndIf
	EndIf

	//Busca as informações referentes ao atendimento médico do acidente
	aInfAten := MDTInfAte()

	//Busca da informação a ser enviada na tag <dtAtendimento>
	dDtAtendimento := IIf( Len( aInfAten ) > 0, aInfAten[ 1 ], SToD( "" ) )

	//Busca da informação a ser enviada na tag <hrAtendimento>
	cHrAtendimento := IIf( Len( aInfAten ) > 0, aInfAten[ 2 ], "" )

	//Busca da informação a ser enviada na tag <indInternacao>
	cIndInternacao := IIf( Len( aInfAten ) > 0, IIf( M->TNC_INTERN == "1", "S", "N" ), "" )

	//Busca da informação a ser enviada na tag <durTrat>
	cDurTrat := IIf( Len( aInfAten ) > 0, aInfAten[ 3 ], "" )

	//Busca da informação a ser enviada na tag <indAfast>
	cIndAfast := IIf( Len( aInfAten ) > 0, aInfAten[ 4 ], "" )

	//Busca da informação a ser enviada na tag <dscLesao>
	cDscLesao := IIf( Len( aInfAten ) > 0, Posicione( "TOJ", 1, xFilial( "TOJ" ) + M->TNC_CODLES, "TOJ_ESOC" ), "" )

	//Busca da informação a ser enviada na tag <dscCompLesao>
	cDscCompLesao := IIf( Len( aInfAten ) > 0, Alltrim( MDTSubTxt( M->TNC_DESLES ) ), "" )

	//Busca da informação a ser enviada na tag <diagProvavel>
	cDiagProvavel := IIf( Len( aInfAten ) > 5, aInfAten[ 6 ], "" )

	//Busca da informação a ser enviada na tag <codCID>
	cCodCID := IIf( Len( aInfAten ) > 0, aInfAten[ 5 ], "" )

	//Busca da informação a ser enviada na tag <observacao>
	cObservacao := IIf( Len( aInfAten ) > 5, aInfAten[ 7 ], "" )

	//Busca da informação a ser enviada na tag <nmEmit>
	cNmEmit := IIf( Len( aInfAten ) > 5, aInfAten[ 8 ], "" )

	//Busca da informação a ser enviada na tag <ideOC>
	cIdeOC := IIf( Len( aInfAten ) > 5, aInfAten[ 9 ], "" )

	//Busca da informação a ser enviada na tag <nrOC>
	cNrOC := IIf( Len( aInfAten ) > 5, aInfAten[ 10 ], "" )

	//Busca da informação a ser enviada na tag <ufOC>
	cUfOC := IIf( Len( aInfAten ) > 5, aInfAten[ 11 ], "" )

	//Busca da informação a ser utilizada no relatório de inconsistências referente ao código do médico/dentista emitente do atestado
	cCodMedico := IIf( Len( aInfAten ) > 5, aInfAten[ 12 ], "" )

	//Realiza a verificação das inconsistências ou carrega o Xml
	If lIncons
		fInconsis( @aIncEnv ) //Verifica as inconsistências das informações a serem enviadas
	Else
		cRet := fCarrCAT( cValToChar( nOper ), cChave ) //Carrega o Xml

		//Caso for integração via SIGATAF e a chave do registro tenha sido alterada (alteração da data, hora ou tipo do acidente)
		If !lMiddleware .And. !Empty( cChvNov ) .And. cChave <> cChvNov

			//Verifica se o acidente teve a data, hora ou tipo alterados e busca o TAFKEY do registro
			cTAFKey := MDTGetTKEY( cChave )

		EndIf

	EndIf

	RestArea( aAreaTNC )
	RestArea( aArea )

Return cRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fCarrCAT
Monta o Xml da CAT para envio ao Governo

@return	cXml, Caracter, Estrutura XML a ser enviada para o SIGATAF/Middleware

@sample	fCarrCAT( "3" )

@param cOper, Caracter, Indica a operação que está sendo realizada (3-Inclusão/4-Alteração/5-Exclusão)
@param cChave, Caracter, Chave atual do registro a ser utilizada na busca do registro na RJE

@author	Luis Fellipy Bett
@since	30/08/2018
/*/
//---------------------------------------------------------------------
Static Function fCarrCAT( cOper, cChave )

	Local cXml	:= ""
	Local nCont	:= 0

	Default cOper := "3"

	//Cria o cabeçalho do Xml com o ID, informações do Evento e Empregador
	MDTGerCabc( @cXml, "S2210", cOper, cChave )

	//-------------
	// Trabalhador
	//-------------

	cXml += 		'<ideVinculo>'

	cXml += 			'<cpfTrab>'		+ cCpfTrab		+ '</cpfTrab>' //Obrigatório
	If !MDTVerTSVE( cCodCateg ) //Caso não for TSVE
		cXml +=			'<matricula>'	+ cMatricula	+ '</matricula>' //Obrigatório
	Else
		cXml +=			'<codCateg>'	+ cCodCateg		+ '</codCateg>' //Obrigatório
	EndIf

	cXml += 		'</ideVinculo>'

	//-------------------------------------
	// Comunicação de acidente de trabalho
	//-------------------------------------

	cXml += 		'<cat>'

	cXml += 			'<dtAcid>'				+ MDTAjsData( dDtAcid )		+ '</dtAcid>' //Obrigatório
	cXml += 			'<tpAcid>'				+ cTpAcid					+ '</tpAcid>' //Obrigatório
	If cTpAcid != "2" .And. !Empty( cHrAcid ) //Se for acidente típico ou de trajeto e a hora estiver preenchida
		cXml +=			'<hrAcid>'				+ cHrAcid					+ '</hrAcid>'
	EndIf
	If cTpAcid != "2" .And. !Empty( cHrsTrabAntesAcid ) //Se for acidente típico ou de trajeto e a hora estiver preenchida
		cXml +=			'<hrsTrabAntesAcid>'	+ cHrsTrabAntesAcid			+ '</hrsTrabAntesAcid>'
	EndIf
	cXml += 			'<tpCat>'				+ cTpCat					+ '</tpCat>' //Obrigatório
	cXml += 			'<indCatObito>'			+ cIndCatObito				+ '</indCatObito>' //Obrigatório
	If cIndCatObito == "S"
		cXml += 		'<dtObito>'				+ MDTAjsData( dDtObito )	+ '</dtObito>'
	EndIf
	cXml += 			'<indComunPolicia>'		+ cIndComunPolicia			+ '</indComunPolicia>' //Obrigatório
	cXml += 			'<codSitGeradora>'		+ cCodSitGeradora			+ '</codSitGeradora>' //Obrigatório
	cXml += 			'<iniciatCAT>'			+ "1" 						+ '</iniciatCAT>' //Obrigatório
	If !Empty( cObsCat )
		cXml +=			'<obsCAT>'				+ cObsCat 					+ '</obsCAT>'
	EndIf
	If !Empty( dUltDiaTra ) .And. Mdt062022( dDtAcid )
		cXml +=			'<ultDiaTrab>'			+ MDTAjsData( dUltDiaTra )	+ '</ultDiaTrab>' // Obrigatório
	EndIf
	If !Empty( cHouAfa ) .And. Mdt062022( dDtAcid )
		cXml +=			'<houveAfast>'			+ cHouAfa					+ '</houveAfast>' // Obrigatório
	EndIf

	cXml += 			'<localAcidente>'

	cXml += 				'<tpLocal>'			+ cTpLocal					+ '</tpLocal>' //Obrigatório
	If !Empty( cDscLocal )
		cXml += 			'<dscLocal>'		+ cDscLocal					+ '</dscLocal>'
	EndIf
	If !Empty( cTpLograd )
		cXml += 			'<tpLograd>'		+ cTpLograd					+ '</tpLograd>'
	EndIf
	cXml += 				'<dscLograd>'		+ cDscLograd				+ '</dscLograd>' //Obrigatório
	cXml += 				'<nrLograd>'		+ cNrLograd					+ '</nrLograd>' //Obrigatório
	If !Empty( cComplemento )
		cXml += 			'<complemento>'		+ cComplemento				+ '</complemento>'
	EndIf
	If !Empty( cBairro )
		cXml += 			'<bairro>'			+ cBairro					+ '</bairro>'
	EndIf
	If cTpLocal $ "1/3/5" //Se for "Estabelecimento do empregador no Brasil", "Estabelecimento de terceiros" ou "Área rural"
		cXml += 			'<cep>'				+ cCEP						+ '</cep>'
	EndIf
	If cTpLocal $ "1/3/4/5" //Se for "Estabelecimento do empregador no Brasil", "Estabelecimento de terceiros", "Via Pública" ou "Área rural"
		cXml += 			'<codMunic>'		+ cCodMunic 				+ '</codMunic>'
		cXml += 			'<uf>'				+ cUFAci 					+ '</uf>'
	EndIf
	If cTpLocal == "2" //Se for "Estabelecimento do empregador no Exterior"
		cXml += 			'<pais>'			+ cCodPai	 				+ '</pais>'
		cXml += 			'<codPostal>'		+ cCodPostal				+ '</codPostal>'
	EndIf
	If !Empty( cTpInscAci ) .And. !Empty( cNrInscAci )
		cXml += 			'<ideLocalAcid>'
		cXml += 				'<tpInsc>' 		+ cTpInscAci			+ '</tpInsc>'
		cXml += 				'<nrInsc>' 		+ cNrInscAci			+ '</nrInsc>'
		cXml += 			'</ideLocalAcid>'
	EndIf

	cXml += 			'</localAcidente>'

	For nCont := 1 To Len( aParte )
		cXml += 		'<parteAtingida>'
		cXml += 			'<codParteAting>'	+ aParte[ nCont, 1 ] + '</codParteAting>' //Obrigatório
		cXml += 			'<lateralidade>'	+ aParte[ nCont, 2 ] + '</lateralidade>' //Obrigatório
		cXml += 		'</parteAtingida>'
	Next nCont

	For nCont := 1 To Len( aCausa )
		cXml += 		'<agenteCausador>'
		cXml += 			'<codAgntCausador>' + aCausa[ nCont, 1 ] + '</codAgntCausador>' //Obrigatório
		cXml += 		'</agenteCausador>'
	Next nCont

	//Caso exista informações de atestado a serem enviadas
	If Len( aInfAten ) > 0 .Or. !lMiddleware //Caso existam informações de atendimento ou seja envio pelo SIGATAF, envia
		cXml += 		'<atestado>'
		cXml += 			'<dtAtendimento>'	+ MDTAjsData( dDtAtendimento )	+ '</dtAtendimento>'
		cXml += 			'<hrAtendimento>'	+ cHrAtendimento				+ '</hrAtendimento>'
		cXml += 			'<indInternacao>'	+ cIndInternacao				+ '</indInternacao>'
		cXml +=				'<durTrat>'			+ cDurTrat						+ '</durTrat>'
		cXml += 			'<indAfast>'		+ cIndAfast						+ '</indAfast>'
		cXml += 			'<dscLesao>'		+ cDscLesao						+ '</dscLesao>'
		If !Empty( cDscCompLesao ) .Or. !lMiddleware
			cXml +=			'<dscCompLesao>'	+ cDscCompLesao					+ '</dscCompLesao>'
		EndIf
		If !Empty( cDiagProvavel ) .Or. !lMiddleware
			cXml +=			'<diagProvavel>'	+ cDiagProvavel					+ '</diagProvavel>'
		EndIf
		cXml += 			'<codCID>'			+ cCodCID						+ '</codCID>'
		If !Empty( cObservacao ) .Or. !lMiddleware
			cXml +=			'<observacao>'		+ cObservacao					+ '</observacao>'
		EndIf
		cXml += 			'<emitente>'
		cXml += 				'<nmEmit>'		+ AllTrim( MDTSubTxt( cNmEmit ) )	+ '</nmEmit>'
		cXml += 				'<ideOC>'		+ cIdeOC 							+ '</ideOC>'
		cXml += 				'<nrOC>' 		+ cNrOC 							+ '</nrOC>'
		If !Empty( cUfOC ) //Caso esteja preenchido
			cXml += 			'<ufOC>' 		+ cUfOC 							+ '</ufOC>'
		EndIf
		cXml += 			'</emitente>'
		cXml += 		'</atestado>'
	EndIf

	//Caso tenha encontrado uma CAT Origem para a CAT atual
	If !Empty( cNrRecCatOrig )
		cXml += '		<catOrigem>'
		cXml += '			<nrRecCatOrig>' + cNrRecCatOrig + '</nrRecCatOrig>'
		cXml += '		</catOrigem>'
	EndIf

	cXml += 		'</cat>'

	cXml += 	'</evtCAT>'

	cXml += '</eSocial>'

Return cXml

//---------------------------------------------------------------------
/*/{Protheus.doc} fInconsis
Valida as informações a serem enviadas para o SIGATAF/Middleware

@return	Nil, Nulo

@sample	fInconsis( aIncEnv )

@param	aIncEnv, Array, Array passado por referência que irá receber os logs de inconsistências (se houver)

@author Luis Fellipy Bett
@since	30/08/2018 - Refatorada em: 17/02/2021
/*/
//---------------------------------------------------------------------
Static Function fInconsis( aIncEnv )

	//Variáveis de controle
	Local aArea	  := GetArea()
	Local cFilBkp := cFilAnt
	Local lVldFun := .T. //Variável de controle de validação do funcionário

	//Variáveis de contadores
	Local nCont := 0
	Local nLinha := 0
	Local nLinhas := 0

	//Variáveis de composição de informações
	Local cStrFil  := STR0084 + ": " + AllTrim( cFilEnv ) //Filial: XXX
	Local cStrFunc := STR0001 + ": " + AllTrim( cNumMat ) + " - " + AllTrim( cNomeFun ) //Funcionário: XXX - XXXXX
	Local cStrAci  := STR0002 + ": " + AllTrim( M->TNC_ACIDEN ) //Acidente: XXX
	Local cStrEmi  := STR0003 + ": " + AllTrim( cCodMedico ) + " - " + AllTrim( cNmEmit ) //Emitente: XXX - XXXXX

	//Seta a filial de envio para as validações de tabelas do TAF
	cFilAnt := cFilEnv

	Help := .T. //Desativa as mensagens de Help

	//Validação de ficha médica relacionada ao acidente
	If ( lAtestado .Or. lDiagnostico ) .And. Empty( M->TNC_NUMFIC )
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0012 ) //Acidente: XXX / O acidente selecionado não possui nenhuma ficha médica vinculada
		aAdd( aIncEnv, '' )
		lVldFun := .F. //Caso o acidente não possuir um funcionário vinculado, não valida as informações dele
	EndIf

	//Validação da tag <cpfTrab> - CPF do trabalhador
	//Preencher com o número do CPF do trabalhador.
	//Informação obrigatória.
	If lVldFun .And. Empty( cCpfTrab )
		aAdd( aIncEnv, cStrFil + " / " + cStrFunc + " / " + STR0013 + ": " + STR0006 ) //Funcionário: XXX - XXXXX / CPF: Em branco
		aAdd( aIncEnv, '' )
	ElseIf lVldFun .And. !CHKCPF( cCpfTrab )
		aAdd( aIncEnv, cStrFil + " / " + cStrFunc + " / " + STR0013 + ": " + cCpfTrab ) //Funcionário: XXX - XXXXX / CPF: XXX
		aAdd( aIncEnv, STR0007 + ": " + STR0011 ) //Validação: Deve ser um número de CPF válido
		aAdd( aIncEnv, '' )
	EndIf

	//Validação da tag <matricula> - Matrícula atribuída ao trabalhador pela empresa
	//Deve corresponder à matrícula informada pelo empregador no evento S-2190, S-2200 ou S-2300 do respectivo contrato. Não preencher no caso de
	//Trabalhador Sem Vínculo de Emprego/Estatutário - TSVE sem informação de matrícula no evento S-2300
	//A validação de existência de um registro S-2190, S-2200 ou S-2300 já é realizada no começo do envio, através da função MDTVld2200

	//Validação da tag <codCateg> - Código da categoria do trabalhador
	//Informação obrigatória e exclusiva se não houver preenchimento de matricula. Se informado, deve ser um código válido e existente na Tabela 01.
	If lVldFun .And. Empty( cMatricula ) .And. Empty( cCodCateg )
		aAdd( aIncEnv, cStrFil + " / " + cStrFunc + " / " + STR0014 + ": " + STR0006 ) //Funcionário: XXX - XXXXX / Categoria: Em branco
		aAdd( aIncEnv, '' )
	ElseIf lVldFun .And. Empty( cMatricula ) .And. !ExistCPO( "C87", cCodCateg, 2 )
		aAdd( aIncEnv, cStrFil + " / " + cStrFunc + " / " + STR0014 + ": " + cCodCateg ) //Funcionário: XXX - XXXXX / Categoria: XXX
		aAdd( aIncEnv, STR0007 + ": " + STR0015 ) //Validação: Deve ser um código válido e existente na tabela 01 do eSocial
		aAdd( aIncEnv, '' )
	EndIf

	//Validação da tag <dtAcid> - Data do acidente
	//Deve ser uma data válida, igual ou anterior à data atual e igual ou posterior à data de admissão do trabalhador e à data de início da
	//obrigatoriedade deste evento para o empregador no eSocial. Se tpCat = [2, 3], deve ser informado valor igual ao preenchido no evento de
	//CAT anterior, quando informado em nrRecCatOrig.
	//Informação obrigatória.
	If Empty( dDtAcid )
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0016 + ": " + STR0006 ) //Acidente: XXX / Data do Acidente: Em branco
		aAdd( aIncEnv, '' )
	ElseIf !( dDtAcid >= dDtEsoc .And. dDtAcid >= dDtAdm .And. dDtAcid <= dDataBase )
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0016 + ": " + DToC( dDtAcid ) ) //Acidente: XXX / Data do Acidente: XX/XX/XXXX
		aAdd( aIncEnv, STR0007 + ": " + STR0017 + ":" ) //Validação: Deve ser uma data válida e:
		aAdd( aIncEnv, "* " + STR0018 + ": " + DToC( dDataBase ) ) //* Igual ou anterior à data atual: XX/XX/XXXX
		aAdd( aIncEnv, "* " + STR0019 + ": " + DToC( dDtAdm ) ) //* Igual ou posterior à data de admissão do trabalhador: XX/XX/XXXX
		aAdd( aIncEnv, "* " + STR0020 + ": " + DToC( dDtEsoc ) ) //* Igual ou posterior à data de início de obrigatoriedade dos eventos de SST ao eSocial: XX/XX/XXXX
		aAdd( aIncEnv, '' )
	EndIf

	//Validação da tag <tpAcid> - Tipo de acidente de trabalho
	//Valores válidos: 1 - Típico, 2 - Doença ou 3 - Trajeto
	//Informação obrigatória.
	If Empty( cTpAcid )
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0021 + ": " + STR0006 ) //Acidente: XXX / Tipo do Acidente: Em branco
		aAdd( aIncEnv, '' )
	ElseIf !( cTpAcid $ "1/2/3" )
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0021 + ": " + cTpAcid ) //Acidente: XXX / Tipo do Acidente: XXX
		aAdd( aIncEnv, STR0007 + ": " + STR0022 ) //Validação: Deve ser igual a 1- Típico, 2- Doença ou 3- Trajeto
		aAdd( aIncEnv, '' )
	EndIf

	//Validação da tag <hrAcid> - Hora do acidente
	//Preenchimento obrigatório se tpAcid = [1] ou se (tpAcid = [3] e dtAcid >= [2022-01-26]). Não informar
	//se tpAcid = [2]. Se preenchida, deve estar no intervalo entre [0000] e [2359], criticando inclusive a segunda parte
	//do número, que indica os minutos, que deve ser menor ou igual a 59. Se tpCat = [2, 3], deve ser informado valor igual ao
	//preenchido no evento de CAT anterior, quando informado em nrRecCatOrig.
	If ( cTpAcid == "1" .Or. ( cTpAcid == "3" .And. dDtAcid >= SToD( "20220126" ) ) ) .And. Empty( cHrAcid )
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0023 + ": " + STR0006 ) //Acidente: XXX / Hora do Acidente: Em branco
		aAdd( aIncEnv, '' )
	EndIf

	//Validação da tag <hrsTrabAntesAcid> - Horas trabalhadas antes da ocorrência do acidente
	//Preenchimento obrigatório se tpAcid = [1] ou se (tpAcid = [3] e dtAcid >= [2022-07-20]). Não informar 
	//se tpAcid = [2]. Se preenchida, deve estar no intervalo entre [0000] e [9959], criticando inclusive a segunda parte
	//do número, que indica os minutos, que deve ser menor ou igual a 59.
	If ( cTpAcid == "1" .Or. ( cTpAcid == "3" .And. dDtAcid >= SToD( "20220720" ) ) ) .And. ( Empty( cHrsTrabAntesAcid ) .Or. AllTrim( cHrsTrabAntesAcid ) == ":" )
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0024 + ": " + STR0006 ) //Acidente: XXX / Horas Trabalhadas Antes do Acidente: Em branco
		aAdd( aIncEnv, '' )
	EndIf

	//Validação da tag <tpCat> - Tipo de CAT
	//Valores válidos: 1 - Inicial, 2 - Reabertura ou 3 - Comunicação de óbito
	//Informação obrigatória.
	If Empty( cTpCat )
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0025 + ": " + STR0006 ) //Acidente: XXX / Tipo de CAT: Em branco
		aAdd( aIncEnv, '' )
	ElseIf !( cTpCat $ "1/2/3" )
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0025 + ": " + cTpCat ) //Acidente: XXX / Tipo de CAT: XXX
		aAdd( aIncEnv, STR0007 + ": " + STR0026 ) //Validação: Deve ser igual a 1- Inicial, 2- Reabertura ou 3- Comunicação de óbito
		aAdd( aIncEnv, '' )
	EndIf

	//Validação da tag <indCatObito> - Houve óbito?
	//Valores válidos: S - Sim ou N - Não. Validação: Se o tpCat for igual a [3], o campo deverá sempre ser preenchido com [S]. Se o tpCat for
	//igual a [2], o campo deverá sempre ser preenchido com [N].
	//Informação obrigatória.
	If Empty( cIndCatObito )
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0027 + ": " + STR0006 ) //Acidente: XXX / Indicativo de Óbito: Em branco
		aAdd( aIncEnv, '' )
	ElseIf !( cIndCatObito $ "S/N" )
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0027 + ": " + cIndCatObito ) //Acidente: XXX / Indicativo de Óbito: XXX
		aAdd( aIncEnv, STR0007 + ": " + STR0028 ) //Validação: Deve ser igual a S- Sim ou N- Não
		aAdd( aIncEnv, '' )
	ElseIf cTpCat == "3" .And. !( cIndCatObito == "S" )
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0027 + ": " + cIndCatObito ) //Acidente: XXX / Indicativo de Óbito: XXX
		aAdd( aIncEnv, STR0007 + ": " + STR0029 ) //Validação: Se o Tipo de CAT for igual a 3- Comunicação de óbito, o campo 'Houve Morte' deve ser igual a 'Sim'
		aAdd( aIncEnv, '' )
	ElseIf cTpCat == "2" .And. !( cIndCatObito == "N" )
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0027 + ": " + cIndCatObito ) //Acidente: XXX / Indicativo de Óbito: XXX
		aAdd( aIncEnv, STR0007 + ": " + STR0030 ) //Validação: Se o Tipo de CAT for igual a 2- Reabertura, o campo 'Houve Morte' deve ser igual a 'Não'
		aAdd( aIncEnv, '' )
	EndIf

	//Validação da tag <dtObito> - Data do óbito
	//Validação: Deve ser uma data válida, igual ou posterior a dtAcid e igual ou anterior à data atual. Preenchimento obrigatório e exclusivo
	//se indCatObito = [S].
	If cIndCatObito == "S"
		If !( dDtObito >= dDtAcid .And. dDtObito <= dDataBase )
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0031 + ": " + DToC( dDtObito ) ) //Acidente: XXX / Data do Óbito: XX/XX/XXXX
			aAdd( aIncEnv, STR0007 + ": " + STR0017 + ":" ) //Validação: Deve ser uma data válida e:
			aAdd( aIncEnv, "* " + STR0032 + ": " + DToC( dDtAcid ) ) //* Igual ou posterior à data do acidente: XX/XX/XXXX
			aAdd( aIncEnv, "* " + STR0018 + ": " + DToC( dDataBase ) ) //* Igual ou anterior à data atual: XX/XX/XXXX
			aAdd( aIncEnv, '' )
		EndIf
	EndIf

	//Validação da tag <indComunPolicia> - Houve comunicação à autoridade policial?
	//Valores válidos: S - Sim ou N - Não
	//Informação obrigatória.
	If Empty( cIndComunPolicia )
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0033 + ": " + STR0006 ) //Acidente: XXX / Indicativo de Comunicação à Autoridade Policial: Em branco
		aAdd( aIncEnv, '' )
	ElseIf !( cIndComunPolicia $ "S/N" )
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0033 + ": " + cIndComunPolicia ) //Acidente: XXX / Indicativo de Comunicação à Autoridade Policial: XXX
		aAdd( aIncEnv, STR0007 + ": " + STR0028 ) //Validação: Deve ser igual a S- Sim ou N- Não
		aAdd( aIncEnv, '' )
	EndIf

	//Validação da tag <codSitGeradora> - Código da situação geradora do acidente ou da doença profissional.
	//Validação: Deve ser um código válido e existente na Tabela 15 ou na Tabela 16.
	//Informação obrigatória.
	If Empty( cCodSitGeradora )
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0034 + ": " + STR0006 ) //Acidente: XXX / Código da Situação Geradora: Em branco
		aAdd( aIncEnv, '' )
	ElseIf !ExistCPO( "C8K", cCodSitGeradora, 2 )
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0034 + ": " + cCodSitGeradora ) //Acidente: XXX / Código da Situação Geradora: XXX
		aAdd( aIncEnv, STR0007 + ": " + STR0035 ) //Validação: Deve ser um código válido e existente na tabela 15 do eSocial
		aAdd( aIncEnv, '' )
	EndIf

	If Empty( dUltDiaTra )

		If Mdt062022( dDtAcid )

			//-------------------------
			// "Último dia trabalhado"
			// "Em branco"
			//-------------------------
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0085 + ": " + STR0006 )
			aAdd( aIncEnv, '' )

		EndIf

	ElseIf dUltDiaTra > dDataBase .Or. dUltDiaTra < dDtAdm

		//------------------------------------------------------------------------------------------------------------
		// "Acidente"
		// "Último dia trabalhado"
		// "Validação"
		// "Deve ser uma data igual ou anterior à data atual e igual ou posterior à data de admissão do trabalhador."
		//------------------------------------------------------------------------------------------------------------
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0085 + ": " + DtoC( dUltDiaTra ) )
		aAdd( aIncEnv, STR0007 + ": " + STR0086 )
		aAdd( aIncEnv, '' )

	EndIf

	//Validação da tag <iniciatCAT> - Iniciativa da CAT.
	//Valores válidos: 1 - Empregador, 2 - Ordem judicial ou 3 - Determinação de órgão fiscalizador
	//Chumbado para ser enviado sempre como '1'

	//Validação da tag <obsCAT> - Observação.
	//Não possui nenhuma validação específica

	//Validação da tag <tpLocal> - Tipo de local do acidente.
	//Valores válidos: 1 - Estabelecimento do empregador no Brasil, 2 - Estabelecimento do empregador no exterior, 3 - Estabelecimento de terceiros
	//onde o empregador presta serviços, 4 - Via pública, 5 - Área rural, 6 - Embarcação ou 9 - Outros
	//Informação obrigatória.
	If Empty( cTpLocal )
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0036 + ": " + STR0006 ) //Acidente: XXX / Tipo de Local do Acidente: Em branco
		aAdd( aIncEnv, '' )
	ElseIf !( cTpLocal $ "1/2/3/4/5/6/9" )
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0036 + ": " + cTpLocal ) //Acidente: XXX / Tipo de Local do Acidente: XXX
		aAdd( aIncEnv, STR0007 + ": " + STR0037 + ":" ) //Validação: Deve ser igual a:
		aAdd( aIncEnv, STR0038 ) //1- Estabelecimento do empregador no Brasil
		aAdd( aIncEnv, STR0039 ) //2- Estabelecimento do empregador no exterior
		aAdd( aIncEnv, STR0040 ) //3- Estabelecimento de terceiros onde o empregador presta serviços
		aAdd( aIncEnv, STR0041 ) //4- Via pública
		aAdd( aIncEnv, STR0042 ) //5- Área rural
		aAdd( aIncEnv, STR0043 ) //6- Embarcação
		aAdd( aIncEnv, STR0044 ) //9- Outros
		aAdd( aIncEnv, '' )
	EndIf

	//Validação da tag <dscLocal> - Especificação do local do acidente (pátio, rampa de acesso, posto de trabalho, etc.).
	//Não possui nenhuma validação específica

	//Validação da tag <tpLograd> - Tipo de logradouro.
	//Validação: Se informado, deve ser um código válido e existente na Tabela 20.
	If !Empty( cTpLograd ) .And. !ExistCPO( "C06", cTpLograd, 4 )
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0045 + ": " + cTpLograd ) //Acidente: XXX / Tipo de Logradouro: XXX
		aAdd( aIncEnv, STR0007 + ": " + STR0046 ) //Validação: Deve ser um código válido e existente na tabela 20 do eSocial
		aAdd( aIncEnv, '' )
	EndIf

	//Validação da tag <dscLograd> - Descrição do logradouro.
	//Informação obrigatória.
	If Empty( cDscLograd )
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0047 + ": " + STR0006 ) //Acidente: XXX / Descrição do Logradouro: Em branco
		aAdd( aIncEnv, '' )
	EndIf

	//Validação da tag <nrLograd> - Número do logradouro.
	//Se não houver número a ser informado, preencher com "S/N".
	//Caso o campo TNC_NUMLOG esteja preenchido envia o conteúdo dele, senão envia 'S/N'

	//Validação da tag <complemento> - Complemento do logradouro.
	//Não possui nenhuma validação específica

	//Validação da tag <bairro> - Nome do bairro/distrito.
	//Não possui nenhuma validação específica

	//Validação da tag <cep> - Código de Endereçamento Postal - CEP.
	//Validação: Preenchimento obrigatório se tpLocal = [1, 3, 5]. Não preencher se tpLocal = [2]. Se preenchido, deve ser informado apenas com
	//números, com 8 (oito) posições.
	If cTpLocal $ "1/3/5"
		If Empty( cCEP )
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0048 + ": " + STR0006 ) //Acidente: XXX / CEP: Em branco
			aAdd( aIncEnv, '' )
		EndIf
	EndIf

	//Validação da tag <codMunic> - código do município, conforme tabela do IBGE.
	//Validação: Preenchimento obrigatório se tpLocal = [1, 3, 4, 5]. Não preencher se tpLocal = [2]. Se informado, deve ser um código válido
	//e existente na tabela do IBGE.
	If cTpLocal $ "1/3/4/5"
		If Empty( cCodMunic )
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0049 + ": " + STR0006 ) //Acidente: XXX / Município: Em branco
			aAdd( aIncEnv, '' )
		EndIf
	EndIf

	//Validação da tag <uf> - Sigla da Unidade da Federação - UF.
	//Valores válidos: AC, AL, AP, AM, BA, CE, DF, ES, GO, MA, MT, MS, MG, PA, PB, PR, PE, PI, RJ, RN, RS, RO, RR, SC, SP, SE, TO.
	//Validação: Preenchimento obrigatório se tpLocal = [1, 3, 4, 5]. Não preencher se tpLocal = [2].
	If cTpLocal $ "1/3/4/5"
		If Empty( cUFAci )
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0050 + ": " + STR0006 ) //Acidente: XXX / UF: Em branco
			aAdd( aIncEnv, '' )
		EndIf
	EndIf

	//Validação da tag <pais> - Código do país.
	//Validação: Deve ser um código de país válido e existente na Tabela 06. Preenchimento obrigatório se tpLocal = [2]. Não preencher nos
	//demais casos.
	If cTpLocal == "2"
		If Empty( cCodPai )
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0051 + ": " + STR0006 ) //Acidente: XXX / País: Em branco
			aAdd( aIncEnv, '' )
		ElseIf !ExistCPO( "C08", cCodPai, 4 )
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0051 + ": " + cCodPai ) //Acidente: XXX / País: XXX
			aAdd( aIncEnv, STR0007 + ": " + STR0052 ) //Validação: Deve ser um código válido e existente na tabela 06 do eSocial
			aAdd( aIncEnv, '' )
		ElseIf cCodPai $ "008/009/020/025/047/100/106/131/150/151/152/237/263/358/367/388/395/396/423/452/490/563/569/583/678/738/785/790/840/855/873/895" //Países extintos de acordo com o leiaute do eSocial
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0051 + ": " + cCodPai + " - " + AllTrim( Posicione( xFilial( "C08" ), 4, xFilial( "C08" ) + cCodPai, "C08_DESCRI" ) ) ) //Acidente: XXX / País: XXX - XXXXX
			aAdd( aIncEnv, STR0007 + ": " + STR0083 ) //Validação: O país selecionado está extinto de acordo com o leiaute do eSocial
			aAdd( aIncEnv, '' )
		EndIf
	EndIf

	//Validação da tag <codPostal> - Código de Endereçamento Postal.
	//Validação: Preenchimento obrigatório se tpLocal = [2]. Não preencher nos demais casos.
	If cTpLocal == "2"
		If Empty( cCodPostal )
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0053 + ": " + STR0006 ) //Acidente: XXX / Código de Endereçamento Postal: Em branco
			aAdd( aIncEnv, '' )
		EndIf
	EndIf

	//Validação da tag <tpInsc> - código correspondente ao tipo de inscrição do local onde ocorreu o acidente ou a doença ocupacional,
	//conforme Tabela 05.
	//Validação: O (se ideEmpregador/tpInsc = [1] e tpLocal = [1, 3]); OC (nos demais casos)
	If ( cTpInsc == "1" .And. cTpLocal $ "1/3" ) .Or. ( MdtTraAvul( cCodCateg ) .And. Mdt062022( dDtAcid ) )
		If Empty( cTpInscAci )
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0054 + ": " + STR0006 ) //Acidente: XXX / Tipo de Inscrição do Local do Acidente: Em branco
			aAdd( aIncEnv, '' )
		ElseIf !( cTpInscAci $ "1/3/4" )
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0054 + ": " + cTpInscAci ) //Acidente: XXX / Tipo de Inscrição do Local do Acidente: XXX
			aAdd( aIncEnv, STR0007 + ": " + STR0055 ) //Validação: Deve ser igual a 1- CNPJ, 3- CAEPF ou 4- CNO
			aAdd( aIncEnv, '' )
		EndIf
	EndIf

	//Validação da tag <nrInsc> - número de inscrição do estabelecimento, de acordo com o tipo de inscrição indicado no campo ideLocalAcid/tpInsc
	//Validação: Deve ser compatível com o conteúdo do campo ideLocalAcid/tpInsc. Deve ser um identificador válido, constante das bases da RFB, e:
	//a) Se tpLocal = [1], deve ser válido e existente na Tabela de Estabelecimentos (S-1005); b) Se tpLocal = [3], deve ser diferente dos
	//estabelecimentos informados na Tabela S-1005 e, se ideLocalAcid/tpInsc = [1], diferente do CNPJ base indicado em S-1000.
	//O (se ideEmpregador/tpInsc = [1] e tpLocal = [1, 3]); OC (nos demais casos)
	If cTpInsc == "1" .And. cTpLocal $ "1/3" .And. !Empty( cTpInscAci )
		If Empty( cNrInscAci )
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0056 + ": " + STR0006 ) //Acidente: XXX / Inscrição do Local do Acidente: Em branco
			aAdd( aIncEnv, '' )
		ElseIf !MDTNrInsc( cTpLocal, cTpInscAci, cNrInscAci, cNumMat )
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0056 + ": " + cNrInscAci ) //Acidente: XXX / Inscrição do Local do Acidente: XXX
			aAdd( aIncEnv, STR0007 + ": " + STR0057 ) //Validação: 1) Deve constar na tabela S-1005 se o local do acidente for igual a 'Estabelecimento do Empregador no Brasil'.
			aAdd( aIncEnv, STR0058 ) //2) Deve ser diferente dos estabelecimentos informados na Tabela S-1005 se o local do acidente for igual a 'Estabelecimento de
			aAdd( aIncEnv, STR0059 ) //Terceiros' e diferente do CNPJ base indicado em S-1000 se o tipo de inscrição do local do acidente for igual a CNPJ.
			aAdd( aIncEnv, '' )
		EndIf
	EndIf

	If MdtTraAvul( cCodCateg ) .And. !( cTpLocal $ '1/3' ) .And. !MDTNrInsc( cTpLocal, cTpInscAci, cNrInscAci, cNumMat )

		//---------------------------------------------------------------------------------------------------------------
		// "Inscrição do Local do Acidente"
		// "Validação"
		// "Deve constar na tabela S-1005 se o local do acidente for igual a 'Estabelecimento do empregador no exterior'
		//		e o trabalhador for da categoria 2XX."
		//---------------------------------------------------------------------------------------------------------------

		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0056 + ": " + cNrInscAci )

		nLinhas := MlCount( STR0087 )

		For nLinha := 1 To nLinhas

			If nLinha == 1
				aAdd( aIncEnv, STR0007 + ": " + MemoLine( STR0087, 108, nLinha ) )
			Else
				aAdd( aIncEnv, MemoLine( STR0087, 108, nLinha ) )
			EndIf

		Next nLinha

		aAdd( aIncEnv, '' )

	EndIf

	//Validação das tags <codParteAting> - Código da parte atingida e <lateralidade> - Lateralidade da(s) parte(s) atingida(s).
	//<codParteAting> Validação: Deve ser um código válido e existente na Tabela 13.
	//<lateralidade> Valores válidos: 0 - Não aplicável, 1 - Esquerda, 2 - Direita ou 3 - Ambas
	//Informação obrigatória.
	If Len( aParte ) > 0
		For nCont := 1 To Len( aParte )
			If Empty( aParte[ nCont, 1 ] )
				aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0060 + ": " + STR0006 ) //Acidente: XXX / Parte do Corpo Atingida: Em branco
				aAdd( aIncEnv, '' )
			ElseIf !ExistCPO( "C8I", aParte[ nCont, 1 ], 2 )
				aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0060 + ": " + aParte[ nCont, 1 ] ) //Acidente: XXX / Parte do Corpo Atingida: XXX
				aAdd( aIncEnv, STR0007 + ": " + STR0061 ) //Validação: Deve ser um código válido e existente na tabela 13 do eSocial
				aAdd( aIncEnv, '' )
			EndIf
			If Empty( aParte[ nCont, 2 ] )
				aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0062 + ": " + STR0006 ) //Acidente: XXX / Lateralidade da Parte Atingida: Em branco
				aAdd( aIncEnv, '' )
			EndIf
		Next nCont
	Else
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0063 ) //Acidente: XXX / Não existem partes atingidas relacionadas ao acidente
		aAdd( aIncEnv, '' )
	EndIf

	//Validação da tag <codAgntCausador> - Código correspondente ao agente causador do acidente.
	//Validação: Deve ser um código válido e existente na Tabela 14 ou na Tabela 15.
	//Informação obrigatória.
	If Len( aCausa ) > 0
		For nCont := 1 To Len( aCausa )
			If Empty( aCausa[ nCont, 1 ] )
				aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0064 + ": " + STR0006 ) //Acidente: XXX / Agente Causador do Acidente: Em branco
				aAdd( aIncEnv, '' )
			ElseIf !( 'S_01_02' $ MdtRetLei( 'S-2210' ) ) // Validação Leiaute S-1.1 (Remover condição a partir do dia 22/01/2024)

				If !ExistCPO( 'C8J', aCausa[ nCont, 1 ], 2 ) .And. !ExistCPO( 'C8K', aCausa[ nCont, 1 ], 2 )
					aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0064 + ": " + aCausa[ nCont, 1 ] ) //Acidente: XXX / Agente Causador do Acidente: XXX
					aAdd( aIncEnv, STR0007 + ": " + STR0065 ) //Validação: Deve ser um código válido e existente na tabela 14 ou 15 do eSocial
					aAdd( aIncEnv, '' )
				EndIf

			Else // Validação Leiaute S-1.2

				If cTpAcid == '2' .Or. dDtAcid < CtoD( '22/01/2024' )

					If !ExistCPO( 'C8J', aCausa[ nCont, 1 ], 2 ) .And. !ExistCPO( 'C8K', aCausa[ nCont, 1 ], 2 )

						aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0064 + ": " + aCausa[ nCont, 1 ] ) //Acidente: XXX / Agente Causador do Acidente: XXX
						aAdd( aIncEnv, STR0007 + ": " + STR0065 ) //Validação: Deve ser um código válido e existente na tabela 14 ou 15 do eSocial
						aAdd( aIncEnv, '' )

					EndIf

				ElseIf ( cTpAcid == '1' .Or. cTpAcid == '3' ) .And. dDtAcid >= CtoD( '22/01/2024' )

					If !ExistCPO( "C8J", aCausa[ nCont, 1 ], 2 )

						aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0064 + ": " + aCausa[ nCont, 1 ] ) //Acidente: XXX / Agente Causador do Acidente: XXX
						aAdd( aIncEnv, STR0007 + ": " + STR0088 ) // "Deve ser um código válido e existente na tabela 14 do eSocial"
						aAdd( aIncEnv, '' )

					EndIf

				EndIf

			EndIf

		Next nCont

	Else
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0066 ) //Acidente: XXX / Não existem agentes causadores relacionados ao acidente
		aAdd( aIncEnv, '' )
	EndIf

	//Validação da tag <dtAtendimento> - Data do atendimento.
	//Validação: Deve ser uma data igual ou posterior à data do acidente e igual ou anterior à data atual.
	If Len( aInfAten ) > 0 //Caso existam informações de atendimento
		If Empty( dDtAtendimento )
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0067 + ": " + STR0006 ) //Acidente: XXX / Data do Atendimento: Em branco
			aAdd( aIncEnv, '' )
		ElseIf !( dDtAtendimento >= dDtAcid .And. dDtAtendimento <= dDataBase )
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0067 + ": " + DToC( dDtAtendimento ) ) //Acidente: XXX / Data do Atendimento: XX/XX/XXXX
			aAdd( aIncEnv, STR0007 + ": " + STR0017 + ":" ) //Validação: Deve ser uma data válida e:
			aAdd( aIncEnv, "* " + STR0032 + ": " + DToC( dDtAcid ) ) //* Igual ou posterior à data do acidente: XX/XX/XXXX
			aAdd( aIncEnv, "* " + STR0018 + ": " + DToC( dDataBase ) ) //* Igual ou anterior à data atual: XX/XX/XXXX
			aAdd( aIncEnv, '' )
		EndIf
	EndIf

	//Validação da tag <hrAtendimento> - Hora do atendimento.
	//Validação: Deve estar no intervalo entre [0000] e [2359], criticando inclusive a segunda parte do número, que indica os minutos, que deve ser
	//menor ou igual a 59.
	If Len( aInfAten ) > 0 //Caso existam informações de atendimento
		If Empty( cHrAtendimento )
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0069 + ": " + STR0006 ) //Acidente: XXX / Hora do Atendimento: Em branco
			aAdd( aIncEnv, '' )
		EndIf
	EndIf

	//Validação da tag <indInternacao> - Indicativo de internação.
	//Valores válidos: S - Sim ou N - Não
	If Len( aInfAten ) > 0 //Caso existam informações de atendimento
		If Empty( cIndInternacao )
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0070 + ": " + STR0006 ) //Acidente: XXX / Indicativo de Internação: Em branco
			aAdd( aIncEnv, '' )
		ElseIf !( cIndInternacao $ "S/N" )
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0070 + ": " + cIndInternacao ) //Acidente: XXX / Indicativo de Internação: XXX
			aAdd( aIncEnv, STR0007 + ": " + STR0028 ) //Validação: Deve ser igual a S- Sim ou N- Não
			aAdd( aIncEnv, '' )
		EndIf
	EndIf

	//Validação da tag <durTrat> - Duração estimada do tratamento, em dias.
	//Caso os campos referentes a duração do tratamento (TMT_QTAFAS, TNY_QTDTRA ou TNC_QTAFAS) estiverem preenchidos, envia o conteúdo deles,
	//senão envia a quantidade de dias como '0'

	//Validação da tag <indAfast> - Indicativo de afastamento do trabalho durante o tratamento.
	//Valores válidos: S - Sim ou N - Não. Validação: Se o campo indCatObito for igual a [S], o campo deve sempre ser preenchido com [N].
	If Len( aInfAten ) > 0 //Caso existam informações de atendimento
		If Empty( cIndAfast )
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0071 + ": " + STR0006 ) //Acidente: XXX / Indicativo de Afastamento: Em branco
			aAdd( aIncEnv, '' )
		ElseIf !( cIndAfast $ "S/N" )
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0071 + ": " + cIndAfast ) //Acidente: XXX / Indicativo de Afastamento: XXX
			aAdd( aIncEnv, STR0007 + ": " + STR0028 ) //Validação: Deve ser igual a S- Sim ou N- Não
			aAdd( aIncEnv, '' )
		ElseIf cIndCatObito == "S" .And. !( cIndAfast == "N" )
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0071 + ": " + cIndAfast ) //Acidente: XXX / Indicativo de Afastamento: XXX
			aAdd( aIncEnv, STR0007 + ": " + STR0072 ) //Validação: Se o campo 'Houve Morte' for igual a 'Sim', o indicativo de 'Afastamento' deve ser igual a 'Não'
			aAdd( aIncEnv, '' )
		EndIf
	EndIf

	//Validação da tag <dscLesao> - Descrição da natureza da lesão.
	//Validação: Deve ser um código válido e existente na Tabela 17.
	If Len( aInfAten ) > 0 //Caso existam informações de atendimento
		If Empty( cDscLesao )
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0073 + ": " + STR0006 ) //Acidente: XXX / Código de Descrição da Natureza da Lesão: Em branco
			aAdd( aIncEnv, '' )
		ElseIf !ExistCPO( "C8M", cDscLesao, 2 )
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0073 + ": " + cDscLesao ) //Acidente: XXX / Código de Descrição da Natureza da Lesão: XXX
			aAdd( aIncEnv, STR0007 + ": " + STR0074 ) //Validação: Deve ser um código válido e existente na tabela 17 do eSocial
			aAdd( aIncEnv, '' )
		EndIf
	EndIf

	//Validação da tag <dscCompLesao> - Descrição complementar da lesão.
	//Não possui nenhuma validação específica

	//Validação da tag <diagProvavel> - Diagnóstico provável.
	//Não possui nenhuma validação específica

	//Validação da tag <codCID> - Código da tabela de Classificação Internacional de Doenças - CID.
	//Validação: Deve ser preenchido com caracteres alfanuméricos, conforme opções constantes na tabela CID.
	If Len( aInfAten ) > 0 //Caso existam informações de atendimento
		If Empty( cCodCID )
			aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0075 + ": " + STR0006 ) //Acidente: XXX / CID: Em branco
			aAdd( aIncEnv, '' )
		EndIf
	EndIf

	//Validação da tag <observacao> - Observação.
	//Não possui nenhuma validação específica

	//Validação da tag <nmEmit> - Nome do médico/dentista que emitiu o atestado.
	//Informação obrigatória
	If Len( aInfAten ) > 0 //Caso existam informações de atendimento
		If Empty( cNmEmit )
			aAdd( aIncEnv, cStrFil + " / " + cStrEmi + " / " + STR0076 + ": " + STR0006 ) //Emitente: XXX - XXXXX / Nome: Em branco
			aAdd( aIncEnv, '' )
		EndIf
	EndIf

	//Validação da tag <ideOC> - Órgão de classe.
	//Valores válidos: 1 - Conselho Regional de Medicina - CRM, 2 - Conselho Regional de Odontologia - CRO ou 3 - Registro do Ministério da Saúde - RMS
	If Len( aInfAten ) > 0 //Caso existam informações de atendimento
		If Empty( cIdeOC )
			aAdd( aIncEnv, cStrFil + " / " + cStrEmi + " / " + STR0077 + ": " + STR0006 ) //Emitente: XXX - XXXXX / Órgão de Classe: Em branco
			aAdd( aIncEnv, '' )
		ElseIf !( cIdeOC $ "1/2/3" )
			aAdd( aIncEnv, cStrFil + " / " + cStrEmi + " / " + STR0077 + ": " + cIdeOC ) //Emitente: XXX - XXXXX / Órgão de Classe: XXX
			aAdd( aIncEnv, STR0007 + ": " + STR0078 ) //Validação: Deve ser igual a 1- CRM, 2- CRO ou 3- RMS
			aAdd( aIncEnv, '' )
		EndIf
	EndIf

	//Validação da tag <nrOC> - Número de inscrição no órgão de classe.
	//Informação obrigatória
	If Len( aInfAten ) > 0 //Caso existam informações de atendimento
		If Empty( cNrOC )
			aAdd( aIncEnv, cStrFil + " / " + cStrEmi + " / " + STR0079 + ": " + STR0006 ) //Emitente: XXX - XXXXX / Número de Inscrição do Órgão de Classe: Em branco
			aAdd( aIncEnv, '' )
		EndIf
	EndIf

	//Validação da tag <ufOC> - UF do órgão de classe.
	//Valores válidos: AC, AL, AP, AM, BA, CE, DF, ES, GO, MA, MT, MS, MG, PA, PB, PR, PE, PI, RJ, RN, RS, RO, RR, SC, SP, SE, TO
	//Preenchimento obrigatório se ideOC = [1, 2].
	If Len( aInfAten ) > 0 //Caso existam informações de atendimento
		If ( cIdeOC == "1" .Or. cIdeOC == "2" ) .And. Empty( cUfOC )
			aAdd( aIncEnv, cStrFil + " / " + cStrEmi + " / " + STR0080 + ": " + STR0006 ) //Emitente: XXX - XXXXX / UF do Órgão de Classe: Em branco
			aAdd( aIncEnv, '' )
		EndIf
	EndIf

	If cTpCat $ '2/3' .And. Empty( cNrRecCatOrig )

		//----------------------------------
		// "Acidente"
		// "Número de Recibo da CAT Origem"
		//----------------------------------
		aAdd( aIncEnv, cStrFil + " / " + cStrAci + " / " + STR0081 + ": " + STR0006 )
		aAdd( aIncEnv, '' )

	EndIf

	Help := .F. //Ativa novamente as mensagens de Help

	cFilAnt := cFilBkp //Retorna filial do registro
	RestArea( aArea ) //Retorna área

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTCATOrig
Verifica se a CAT atual possui CAT Origem e retorna as o recibo pela
variável private cNrRecCatOrig, além de inicializar as variáveis
dDtAcid e cHrAcid para envio do evento S-2210 ao SIGATAF/Middleware

@sample	MDTCATOrig( "2", 13/10/2021, "23:59" )

@param	cTipoCAT, Caracter, Indica o tipo da CAT para que será buscada a CAT origem
@param	dDtCAT, Data, Indica a data da CAT para que será buscada a CAT origem
@param	cHrCAT, Caracter, Indica a hora da CAT para que será buscada a CAT origem

@author	Luis Fellipy Bett
@since	14/04/2020
/*/
//-------------------------------------------------------------------
Function MDTCATOrig( cTipoCAT, dDtCAT, cHrCAT )

	//Salva as áreas
	Local aArea := GetArea()
	Local aAreaTNC := TNC->( GetArea() ) //Guarda a área do registro atual da TNC
	
	//Variáveis de busca das informações
	Local aEvento   := {}
	Local cIdFunc	:= ""
	Local nEvento   := 0

	//Variáveis de chamadas
	Local lMDTA883 := IsInCallStack( "MDTA883" )

	//Caso seja CAT de Reabertura ou Comunicação de Óbito, a data e número da CAT Origem estiverem
	//preenchidos e a data da CAT Origem for maior que a data de início da obrigatoriedade do eSocial
	If cTipoCAT $ "2/3"

		//Caso envio seja através do SIGATAF
		If !lMiddleware

			//Busca o ID do funcionário
			cIdFunc := MDTGetIdFun( cNumMat )

			//Posiciona na CM0 para buscar as CAT's de mesma data e hora
			dbSelectArea( "CM0" )
			dbSetOrder( 4 )
			If dbSeek( xFilial( "CM0" ) + cIdFunc + DToS( dDtCAT ) + StrTran( cHrCAT, ":", "" ) )

				While CM0->( !Eof() ) .And. CM0->CM0_FILIAL == xFilial( "CM0" ) .And. CM0->CM0_TRABAL == cIdFunc .And. ;
					DToS( CM0->CM0_DTACID ) == DToS( dDtCAT ) .And. StrTran( CM0->CM0_HRACID, ":", "" ) == StrTran( cHrCAT, ":", "" ) .And. ;
					CM0->CM0_TPCAT != cTipoCAT

					//Salva o recibo da CAT origem
					cNrRecCatOrig := AllTrim( CM0->CM0_PROTUL )

					//Pula o registro para verificar se existe um próximo
					CM0->( dbSkip() )

				End

			EndIf

		Else

			//Busca os Xml's do evento S-2210 para o funcionário
			aEvento := MDTLstXml( "S2210", cNumMat )

			//Verifica entre os Xml's encontrados qual se refere a CAT Origem
			For nEvento := 1 To Len( aEvento )

				//Verifica se o xml atual se refere a CAT cadastrada
				If ( MDTXmlVal( "S2210", aEvento[ nEvento, 1 ], "/ns:eSocial/ns:evtCAT/ns:cat/ns:dtAcid", "D" ) == dDtCAT ) .And.;
				( MDTXmlVal( "S2210", aEvento[ nEvento, 1 ], "/ns:eSocial/ns:evtCAT/ns:cat/ns:hrAcid", "C" ) == StrTran( cHrCAT, ":", "" ) ) .And.;
				( MDTXmlVal( "S2210", aEvento[ nEvento, 1 ], "/ns:eSocial/ns:evtCAT/ns:cat/ns:tpCat", "C" ) != cTipoCAT )

					cNrRecCatOrig := AllTrim( aEvento[ nEvento, 2 ] ) // Salva o recibo da CAT origem

					Exit

				EndIf

			Next nEvento

		EndIf

	EndIf

	//Caso não for chamado pela rotina de sincronização das informações da CAT
	If !lMDTA883

		//Caso não tenha CAT Origem, pega a data e horário da CAT Atual
		dDtAcid := dDtCAT
		cHrAcid := StrTran( cHrCAT, ":", "" )

	EndIf

	//Retorna as área
	RestArea( aAreaTNC ) //Retorna área para o registro correto da TNC
	RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTInfAte
Busca as informações do emitente do atestado quando cadastro de acidente

@sample	MDTInfAte()

@return	aInfo, Array, Array contendo as informações do atendimento médico do acidente

@author	Luis Fellipy Bett
@since	17/02/2021
/*/
//-------------------------------------------------------------------
Function MDTInfAte()

	//Variáveis para busca das informações
	Local aInfo		:= {} //Guarda as informações no array para retorno
	Local cMaisRec	:= "" //Variável de verificação do registro de diagnóstico/atestado mais recente
	Local cAcidente	:= M->TNC_ACIDEN
	Local cNumFic	:= M->TNC_NUMFIC
	Local cDtAcid	:= M->TNC_DTACID
	Local cHrAcid	:= M->TNC_HRACID
	Local cTipoCAT	:= M->TNC_TIPCAT

	//Caso for uma CAT de reabertura ou óbito, busca o acidente inicial
	If cTipoCAT $ "2/3"

		//Busca a CAT inicial
		cAcidente := MDTCatIni( cNumFic, cDtAcid, cHrAcid )

	EndIf

	//--------------------------------------------------------------
	// Verifica se as informações do atendimento serão consideradas
	// do Diagnóstico, Atestado ou o mais recente deles
	//--------------------------------------------------------------
	If cAtendAci == "1" //Caso deva ser considerado o Diagnóstico

		aInfo := fGetDiagn( cAcidente )

	ElseIf cAtendAci == "2" //Caso deva ser considerado o Atestado

		aInfo := fGetAtest( cAcidente )

	ElseIf cAtendAci == "3" //Caso deva ser considerado o mais recente entre Diagnóstico e Atestado

		cMaisRec := fVerMaisRec( cAcidente ) //Verifica se o atestado ou o diagnóstico é o mais recente

		If cMaisRec == "1" //Se o mais atual for o Diagnóstico

			aInfo := fGetDiagn( cAcidente )

		ElseIf cMaisRec == "2" //Se o mais atual for o Atestado

			aInfo := fGetAtest( cAcidente )

		EndIf

	EndIf

	//Caso exista um diagnóstico/atestado vinculado ao acidente
	If Len( aInfo ) > 0
		//Trata o campo para os valores padrões do eSocial
		If "CRM" $ aInfo[ 9 ]
			aInfo[ 9 ] := "1"
		ElseIf "CRO" $ aInfo[ 9 ]
			aInfo[ 9 ] := "2"
		ElseIf "RMS" $ aInfo[ 9 ]
			aInfo[ 9 ] := "3"
		EndIf
	EndIf

	//Caso o atendimento tenha sido definido no acidente, troca as informações do atendimento do diagnóstico/atestado pelas do acidente
	If lAtesAcid
		If Len( aInfo ) > 0 //Caso exista um diagnóstico/atestado vinculado ao acidente
			aInfo[ 1 ] := M->TNC_DTATEN //Pega a data de atendimento definida no acidente
			aInfo[ 2 ] := StrTran( M->TNC_HRATEN, ":", "" ) //Pega a hora de atendimento definida no acidente
			aInfo[ 3 ] := cValToChar( M->TNC_QTAFAS ) //Pega a duração do tratamento definida no acidente
			aInfo[ 4 ] := IIf( M->TNC_AFASTA == "1", "S", "N" ) //Pega o indicativo de afastamento relacionado ao acidente
			aInfo[ 5 ] := AllTrim( StrTran( M->TNC_CID, ".", "" ) ) //Pega o CID relacionado ao acidente
		Else
			aAdd( aInfo, M->TNC_DTATEN ) //Pega a data de atendimento definida no acidente
			aAdd( aInfo, StrTran( M->TNC_HRATEN, ":", "" ) ) //Pega a hora de atendimento definida no acidente
			aAdd( aInfo, cValToChar( M->TNC_QTAFAS ) ) //Pega a duração do tratamento definida no acidente
			aAdd( aInfo, IIf( M->TNC_AFASTA == "1", "S", "N" ) ) //Pega o indicativo de afastamento relacionado ao acidente
			aAdd( aInfo, AllTrim( StrTran( M->TNC_CID, ".", "" ) ) ) //Pega o CID relacionado ao acidente
		EndIf
	EndIf

Return aInfo

//-------------------------------------------------------------------
/*/{Protheus.doc} fGetDiagn
Busca as informações do Diagnóstico

@sample	fGetDiagn()

@return	aInfo, Array, Array com as informações do Diagnóstico

@author	Luis Fellipy Bett
@since	11/03/2021
/*/
//-------------------------------------------------------------------
Static Function fGetDiagn( cAcidente )

	Local aArea	 := GetArea() //Pega a área
	Local aInfo	 := {}
	Local lAchou := .T.
	Local lExclu  := IIf( IsInCallStack( "MDTA155" ), !( INCLUI .Or. ALTERA ), .F. ) //Verifica se é exclusão

	If !lDiagnostico
		dbSelectArea( "TMT" )
		dbSetOrder( 7 )
		If dbSeek( xFilial( "TMT" ) + cAcidente )
			RegToMemory( "TMT", .F., , .F. )
		Else
			lAchou := .F. //Define como .F. para não salvar as informações no array
		EndIf
	EndIf

	If lAchou .And. !lExclu 
	
		If lDiagnostico .Or. IsInCallStack( "MDTR832" ) .Or. IsInCallStack( "MDTA640" ) //Caso ache o registro
		
			//Adiciona ao array de retorno as informações do diagnóstico
			aAdd( aInfo, M->TMT_DTATEN )
			aAdd( aInfo, StrTran( M->TMT_HRATEN, ":", "" ) )
			aAdd( aInfo, IIf( !Empty( M->TMT_QTAFAS ), AllTrim( cValToChar( M->TMT_QTAFAS ) ), "0" ) )
			aAdd( aInfo, IIf( M->TMT_QTAFAS > 0, "S", "N" ) )
			aAdd( aInfo, AllTrim( StrTran( M->TMT_CID, ".", "" ) ) )
			aAdd( aInfo, AllTrim( MDTSubTxt( Upper( NgMemo( M->TMT_DIASYP ) ) ) ) )
			aAdd( aInfo, Alltrim( MDTSubTxt( Upper( M->TMT_OUTROS ) ) ) )
			aAdd( aInfo, Posicione( "TMK", 1, xFilial( "TMK" ) + M->TMT_CODUSU, "TMK_NOMUSU" ) )
			aAdd( aInfo, AllTrim( Posicione( "TMK", 1, xFilial( "TMK" ) + M->TMT_CODUSU, "TMK_ENTCLA" ) ) )
			aAdd( aInfo, AllTrim( Posicione( "TMK", 1, xFilial( "TMK" ) + M->TMT_CODUSU, "TMK_NUMENT" ) ) )
			aAdd( aInfo, Posicione( "TMK", 1, xFilial( "TMK" ) + M->TMT_CODUSU, "TMK_UF" ) )
			aAdd( aInfo, M->TMT_CODUSU )
			
		EndIf

	EndIf

	//Retorna a área
	RestArea( aArea )

Return aInfo

//-------------------------------------------------------------------
/*/{Protheus.doc} fGetAtest
Busca as informações do Atestado

@sample	fGetAtest()

@return	aInfo, Array, Array com as informações do Atestado

@author	Luis Fellipy Bett
@since	11/03/2021
/*/
//-------------------------------------------------------------------
Static Function fGetAtest( cAcidente )

	Local aArea	 := GetArea() //Pega a área
	Local aInfo	 := {}
	Local lAchou := .T.
	Local lExclu  := IIf( IsInCallStack( "MDTA685" ), !( INCLUI .Or. ALTERA ), .F. ) //Verifica se é exclusão

	If !lAtestado
		dbSelectArea( "TNY" )
		dbSetOrder( 5 )
		If dbSeek( xFilial( "TNY" ) + cAcidente )
			RegToMemory( "TNY", .F., , .F. )
		Else
			lAchou := .F. //Define como .F. para não salvar as informações no array
		EndIf
	EndIf

	If lAchou .And. !lExclu

		If lAtestado .Or. IsInCallStack( "MDTR832" ) .Or. IsInCallStack( "MDTA640" ) //Caso ache o registro

			//Adiciona no array de retorno as informações do atestado
			aAdd( aInfo, M->TNY_DTCONS )
			aAdd( aInfo, StrTran( M->TNY_HRCONS, ":", "" ) )
			aAdd( aInfo, IIf( !Empty( !Empty( M->TNY_QTDTRA ) ), AllTrim( M->TNY_QTDTRA ), "0" ) )
			aAdd( aInfo, IIf( !Empty( M->TNY_CODAFA ), "S", "N" ) )
			aAdd( aInfo, AllTrim( StrTran( M->TNY_CID, ".", "" ) ) )
			aAdd( aInfo, AllTrim( MDTSubTxt( Upper( fGetDesDia() ) ) ) )
			aAdd( aInfo, Alltrim( MDTSubTxt( Upper( Posicione( "TMT", 7, xFilial( "TMT" ) + M->TNY_ACIDEN + M->TNY_NUMFIC, "TMT_OUTROS" ) ) ) ) )
			aAdd( aInfo, Posicione( "TNP", 1, xFilial( "TNP" ) + M->TNY_EMITEN, "TNP_NOME" ) )
			aAdd( aInfo, AllTrim( Posicione( "TNP", 1, xFilial( "TNP" ) + M->TNY_EMITEN, "TNP_ENTCLA" ) ) )
			aAdd( aInfo, AllTrim( Posicione( "TNP", 1, xFilial( "TNP" ) + M->TNY_EMITEN, "TNP_NUMENT" ) ) )
			aAdd( aInfo, Posicione( "TNP", 1, xFilial( "TNP" ) + M->TNY_EMITEN, "TNP_UF" ) )
			aAdd( aInfo, M->TNY_EMITEN )

		EndIf

	EndIf

	//Retorna a área
	RestArea( aArea )

Return aInfo

//-------------------------------------------------------------------
/*/{Protheus.doc} fVerMaisRec
Verifica qual o registro de diagnóstico/atestado mais recente vinculado ao acidente

@sample	fVerMaisRec()

@return	cRet, Caracter, "1" caso Diagnóstico mais recente, "2" caso atestado e "0" se não existir nenhum atestado/diagnóstico vinculado

@author	Luis Fellipy Bett
@since	11/03/2021
/*/
//-------------------------------------------------------------------
Static Function fVerMaisRec( cAcidente )

	Local cRet	  := "0" //Define por padrão 0 para caso não encontrar nenhum diagnóstico/atestado
	Local dDtDiag := SToD( "" )
	Local dDtAtes := SToD( "" )
	Local lGeraXml  := IsInCallStack( "MDTGeraXml" ) //Verifica se é geração de XML
	Local lExcluExam  := IIf( IsInCallStack( "MDTA155" ) .Or. IsInCallStack( "MDTR685" ), !( INCLUI .Or. ALTERA ), .F.  ) //Verifica se é exclusão
	
	//Busca a data do atendimento do Diagnóstico
	If lDiagnostico
		dDtDiag := IIf( lExcluExam, SToD( "" ), M->TMT_DTATEN ) //Caso for exclusão do diagnóstico, pega a data como vazia
	Else
		dDtDiag := Posicione( "TMT", 7, xFilial( "TMT" ) + cAcidente, "TMT_DTATEN" )
	EndIf

	//Busca a data do atendimento do Atestado
	If lAtestado
		dDtAtes := IIf( lExcluExam, SToD( "" ), M->TNY_DTCONS ) //Caso for exclusão do atestado, pega a data como vazia
	Else
		dDtAtes := Posicione( "TNY", 5, xFilial( "TNY" ) + cAcidente, "TNY_DTCONS" )
	EndIf

	//Avalia o documento mais recente
	If !Empty( dDtDiag ) .And. Empty( dDtAtes ) //Caso só exista um atestado cadastrado
		cRet := "1"
	ElseIf Empty( dDtDiag ) .And. !Empty( dDtAtes ) //Caso só exista um diagnóstico cadastrado
		cRet := "2"
	ElseIf !Empty( dDtDiag ) .And. !Empty( dDtAtes ) //Caso exista os dois, verifica qual o mais atual
		If dDtDiag >= dDtAtes
			cRet := "1"
		Else
			cRet := "2"
		EndIf
	ElseIf Empty( dDtDiag ) .And. Empty( dDtAtes ) .And. lGeraXml

		If lDiagnostico

			cRet := "1"

		ElseIf lAtestado

			cRet := "2"

		EndIf

	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fGetDesDia
Busca as informações do diagnóstico médico (TMT_MDIAGN), quando
chamado pelo acidente ou pelo atestado médico

@sample	fGetDesDia()

@return	cRet, Caracter, Informação do diagnóstico a ser retornada

@author	Luis Fellipy Bett
@since	10/03/2021
/*/
//-------------------------------------------------------------------
Static Function fGetDesDia( nOpc )

	Local aArea := GetArea() //Guarda a área
	Local cRet := ""

	If aArea[ 1 ] <> "TMT"
		dbSelectArea( "TMT" )
		dbSetOrder( 7 )
		dbSeek( xFilial( "TMT" ) + IIf( lAtestado, M->TNY_ACIDEN + M->TNY_NUMFIC, TNY->TNY_ACIDEN + TNY->TNY_NUMFIC ) )
	EndIf

	//Busca a descrição do campo de acordo com o código da SYP
	cRet := NgMemo( TMT->TMT_DIASYP )

	//Retorna a área
	RestArea( aArea )

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTGetTKEY
Busca a TAFKEY do acidente na tabela TAFXERP do TAF

@sample	MDTGetTKEY()

@return	cKey, Caracter, TAFKEY do registro do acidente

@param	cChave, Caracter, Chave atual do registro no TAF

@author	Luis Fellipy Bett
@since	27/10/2021
/*/
//-------------------------------------------------------------------
Function MDTGetTKEY( cChave )

	Local aArea		:= GetArea() //Salva a área
	Local cAliasTAF	:= ""
	Local cKey		:= ""
	Local cIdFunc	:= ""
	Local nRecnoCM0 := 0

	//Busca o ID do funcionário
	cIdFunc := MDTGetIdFun( cNumMat )

	dbSelectArea( "CM0" )
	dbSetOrder( 4 ) //CM0_FILIAL + CM0_TRABAL + DTOS(CM0_DTACID) + CM0_HRACID + CM0_TPCAT + CM0_ATIVO
	If dbSeek( xFilial( "CM0" ) + cIdFunc + cChave )
		
		//Caso exista o campo referente ao TAFKEY na CM0 e esteja preenchido
		If CM0->( ColumnPos( "CM0_TAFKEY" ) ) > 0 .And. !Empty( CM0->CM0_TAFKEY )

			cKey := AllTrim( CM0->CM0_TAFKEY )

		Else //Caso o campo não existir, continua pegando o Recno para buscar pela TAFXERP
		
			nRecnoCM0 := CM0->( Recno() )

		EndIf

	EndIf

	//Caso o registro exista na CM0, busca o TAFKEY na tabela TAFXERP
	If nRecnoCM0 > 0

		//Pega o alias para montar a query
		cAliasTAF := GetNextAlias()

		//Monta a query para busca do TAFKEY
		BeginSQL Alias cAliasTAF
			SELECT TAFKEY
				FROM TAFXERP
					WHERE TAFALIAS = 'CM0'
						AND TAFRECNO = %Exp:nRecnoCM0%
						AND TAFXERP.%NotDel%
		EndSQL

		//Posiciona no registro encontrado para pegar o TAFKEY
		dbSelectArea( cAliasTAF )

		//Pega a TAFKEY do registro
		cKey := AllTrim( ( cAliasTAF )->TAFKEY )

		//Fecha a tabela temporária
		( cAliasTAF )->( dbCloseArea() )

	EndIf

	//Retrona a área
	RestArea( aArea )

Return cKey

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTCatIni
Busca o acidente inicial em casos de CAT de reabertura ou óbito para
buscar corretamente as informações do atestado/diagnóstico

@sample	MDTCatIni()

@return	cKey, Caracter, TAFKEY do registro do acidente

@param	cChave, Caracter, Chave atual do registro
@param	cChvNov, Caracter, Chave nova do registro

@author	Luis Fellipy Bett
@since	27/10/2021
/*/
//-------------------------------------------------------------------
Function MDTCatIni( cNumFic, cDtAcid, cHrAcid )

	//Salva as áreas
	Local aArea := GetArea()
	Local aAreaTNC := TNC->( GetArea() )

	//Variáveis para busca das informações
	Local cAcidente := ""

	//Variáveis de tabelas temporárias
	Local cAliasTNC := GetNextAlias() //Pega o próximo alias

	BeginSQL Alias cAliasTNC

		SELECT
			TNC.TNC_ACIDEN
		FROM
			%Table:TNC% TNC
		WHERE
			TNC.TNC_FILIAL = %xFilial:TNC% AND
			TNC.TNC_NUMFIC = %Exp:cNumFic% AND
			TNC.TNC_DTACID = %Exp:cDtAcid% AND
			TNC.TNC_HRACID = %Exp:cHrAcid% AND
			TNC.TNC_TIPCAT = '1' AND
			TNC.%NotDel%

	EndSQL

	//Posiciona na tabela para pegar o acidente inicial
	dbSelectArea( cAliasTNC )
	( cAliasTNC )->( dbGoTop() )

	//Pega o código do acidente inicial
	cAcidente := ( cAliasTNC )->TNC_ACIDEN

	//Fecha a tabela temporária
	( cAliasTNC )->( dbCloseArea() )

	//Retorna as áreas
	RestArea( aAreaTNC )
	RestArea( aArea )

Return cAcidente
