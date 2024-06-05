#define DRIVE_LETTER IIf(GetRemoteType() == 1, "C:", "l:")

#INCLUDE "totvs.ch"
#INCLUDE 'TOPCONN.CH'
#INCLUDE "rwmake.ch"

User Function RESTAP()

	//https://www.notacontrol.com.br/static-issnetonline/Ajuda/Html/index.html?ajuda_importacao_iss_net.html

	If Pergunte("RESTAP", .T.)
		MakeDir( DRIVE_LETTER + "\restap" )
		FWMsgRun(, {|oSay| Execute(oSay) }, "Gerando Rest Aparecida", "Processando...")
	EndIf

Return





Static Function Execute(osay)


	Local cDir    := DRIVE_LETTER + "\restap\RESTAP020101.txt"
	Local nHandle := FCreate(cDir)
	Local cLinha  :=''
	Local cAlias  :=Getnextalias()

	If nHandle < 0
		fwalertinfo ("Falha ao criar arquivo!!")

		RETURN
	EndIf



	BeginSql Alias cAlias
		SELECT
			CASE
				WHEN FT_ESPECIE = 'NFS'
					THEN '4'
			END AS MODELO,
			FT_NFISCAL AS NF,
			FT_VALCONT AS VLNFTRIB,
			FT_VALCONT AS VLNF,
			FT_ALIQICM AS ALIQ,
			FT_EMISSAO AS EMISNF,
			E2_VENCREA AS VENC,
			A2_CGC AS CGC,
			A2_NOME AS NOME,
			A2_INSCRM AS IMUNI,
			CASE
				WHEN FT_ALIQICM > 0
					THEN '1'
				WHEN FT_ALIQICM = 0
					THEN '0'
			END AS ISSRET,
			A2_CEP AS CEP,
			A2_END AS ENDE,
			A2_NR_END AS NUMERO,
			A2_BAIRRO AS BAIRRO,
			A2_MUN AS CIDADE,
			A2_EST AS ESTADO,
			A2_DDD AS DDD,
			CASE
				WHEN FT_ALIQICM > 0
					THEN '1'
				WHEN FT_ALIQICM = 0
					THEN '0'
			END AS ISSTRIB,
			FT_CODISS AS CODISS
		FROM
			SFT020 SFT
		INNER JOIN SA2010 SA2
		ON (
				SFT.FT_CLIEFOR = SA2.A2_COD
				AND SFT.FT_LOJA = SA2.A2_LOJA
			)
		INNER JOIN SE2020 SE2
		ON (
				SFT.FT_NFISCAL = SE2.E2_NUM
				AND SFT.FT_SERIE = SE2.E2_PREFIXO
				AND SFT.FT_CLIEFOR = SE2.E2_FORNECE
				AND SFT.FT_LOJA = SE2.E2_LOJA
				AND SFT.D_E_L_E_T_ = SE2.D_E_L_E_T_
			)
		WHERE
			SFT.D_E_L_E_T_ = ''
			AND E2_TIPO = 'NF'
			AND A2_COD_MUN <> '01405'
			AND FT_FILIAL >= %Exp:MV_PAR01%
			AND FT_FILIAL <= %Exp:MV_PAR02%
			AND FT_ENTRADA >= %Exp:Dtos(MV_PAR03)%
			AND FT_ENTRADA <= %Exp:Dtos(MV_PAR04)%
			AND FT_ESPECIE = 'NFS'
	EndSql
	cTime    := TIME()
	cHora    := SUBSTR(cTime, 1, 2)
	cMinutos := SUBSTR(cTime, 4, 2)
	cData    := Date()
	cNome    := UsrFullName()

	cLinha +="136793" + ";"
	cLinha +="0" + CVALTOCHAR(Month(MV_PAR03)) + ";"
	cLinha +=CVALTOCHAR(Year(MV_PAR03)) + ";"
	cLinha += cHora + ":"+cMinutos + " " + CVALTOCHAR(cData) + cNome + ";"
	cLinha += "1" + ";"
	cLinha += "EXPORTACAO DECLARACAO ELETRONICA-ONLINE-NOTA CONTROL"
	cLinha +=CRLF
	While (cAlias)->(! Eof())

		cLinha += (cAlias)->MODELO + ";"
		cLinha += Alltrim((cAlias)->NF) + ";"
		cLinha += CVALTOCHAR((cAlias)->VLNFTRIB) + ";"
		cLinha += CVALTOCHAR((cAlias)->VLNF) + ";"
		cLinha += CVALTOCHAR((cAlias)->ALIQ) + ";"
		cLinha += Alltrim(STRTRAN( DTOC(STOD((cAlias)->EMISNF)), '/', '' )) + ";"
		cLinha += Alltrim(STRTRAN( DTOC(STOD((cAlias)->VENC)), '/', '' )) + ";"
		cLinha += Alltrim((cAlias)->CGC) + ";"
		cLinha += Alltrim((cAlias)->NOME) + ";"
		cLinha += + ";"
		cLinha += Alltrim((cAlias)->ISSRET) + ";"
		cLinha += Alltrim((cAlias)->CEP) + ";"
		cLinha += Alltrim((cAlias)->ENDE) + ";"
		cLinha += Alltrim((cAlias)->NUMERO) + ";"
		cLinha += Alltrim((cAlias)->BAIRRO) + ";"
		cLinha += Alltrim((cAlias)->CIDADE) + ";"
		cLinha += Alltrim((cAlias)->ESTADO) + ";"
		cLinha += Alltrim((cAlias)->DDD) + ";"
		cLinha += Alltrim((cAlias)->ISSTRIB) + ";"
		cLinha += Alltrim((cAlias)->CODISS) + ";"
		cLinha += "1" + ";"


		cLinha +=CRLF
		(cAlias)->(DbSkip())
	EndDo

	FWrite(nHandle, cLinha)
	FCLOSE(nHandle)


Return
