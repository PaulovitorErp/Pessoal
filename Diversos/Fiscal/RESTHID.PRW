#define DRIVE_LETTER IIf(GetRemoteType() == 1, "C:", "l:")

#INCLUDE "totvs.ch"
#INCLUDE 'TOPCONN.CH'
#INCLUDE "rwmake.ch"

User Function RESTHD()



	If Pergunte("RESTHD", .T.)
		MakeDir( DRIVE_LETTER + "\RESTHD" )
		FWMsgRun(, {|oSay| Execute(oSay) }, "Gerando Rest Hidrolandia", "Processando...")
	EndIf

Return





Static Function Execute(osay)


	Local cDir    := DRIVE_LETTER + "\RESTHD\loteREST.txt"
	Local nHandle := FCreate(cDir)
	Local cLinha  :=''
	Local cAlias  :=Getnextalias()

	If nHandle < 0
		fwalertinfo ("Falha ao criar arquivo!!")

		RETURN
	EndIf



	BeginSql Alias cAlias
	
SELECT DISTINCT CASE
                    WHEN LEN(CONVERT(VARCHAR(10), FT_CODISS)) = 3 THEN FORMAT(CAST(FT_CODISS AS NUMERIC(10, 2)) / 100.0, '0.00')
                    WHEN LEN(CONVERT(VARCHAR(10), FT_CODISS)) = 4 THEN FORMAT(CAST(FT_CODISS AS NUMERIC(10, 2)) / 100.0, '0.00')
                    ELSE CONVERT(VARCHAR(10), FT_CODISS)
                END AS CODISS,
                CASE
                    WHEN FT_ESPECIE = 'NFS' THEN 'NF'
                END AS MODELO,
                A2_COD_MUN AS [MUNPREST],
                FT_EMISSAO AS EMISNF,
                FT_NFISCAL AS NF,
                CASE
                    WHEN FT_ALIQICM > 0 THEN '1'
                    WHEN FT_ALIQICM = 0 THEN '0'
                END AS TRIBMUN,
                SUM(FT_VALCONT) AS VLNFTRIB,
                REPLACE(FT_ALIQICM, '.', '') AS ALIQ,
                SUM(FT_VALICM) AS VLRISS,
                A2_CGC AS CGC,
                A2_INSCRM AS IMUNI,
                A2_INSCR AS IEST,
                A2_NOME AS NOME,
                A2_END AS ENDE,
                A2_NR_END AS NUMERO,
                A2_COMPLEM AS COMPL,
                A2_BAIRRO AS BAIRRO,
                A2_COD_MUN AS [MUNPREST],
                A2_CEP AS CEP,
                A2_EMAIL AS EMAIL,
                FT_FILIAL AS Filial,
                M0_INSCM M0IM,
                CASE
                    WHEN SA2.A2_EST = 'RO' THEN '11'
                    WHEN SA2.A2_EST = 'AC' THEN '12'
                    WHEN SA2.A2_EST = 'AM' THEN '13'
                    WHEN SA2.A2_EST = 'RR' THEN '14'
                    WHEN SA2.A2_EST = 'PA' THEN '15'
                    WHEN SA2.A2_EST = 'AP' THEN '16'
                    WHEN SA2.A2_EST = 'TO' THEN '17'
                    WHEN SA2.A2_EST = 'MA' THEN '21'
                    WHEN SA2.A2_EST = 'PI' THEN '22'
                    WHEN SA2.A2_EST = 'CE' THEN '23'
                    WHEN SA2.A2_EST = 'RN' THEN '24'
                    WHEN SA2.A2_EST = 'PB' THEN '25'
                    WHEN SA2.A2_EST = 'PE' THEN '26'
                    WHEN SA2.A2_EST = 'AL' THEN '27'
                    WHEN SA2.A2_EST = 'MG' THEN '31'
                    WHEN SA2.A2_EST = 'ES' THEN '32'
                    WHEN SA2.A2_EST = 'RJ' THEN '33'
                    WHEN SA2.A2_EST = 'SP' THEN '35'
                    WHEN SA2.A2_EST = 'PR' THEN '41'
                    WHEN SA2.A2_EST = 'SC' THEN '42'
                    WHEN SA2.A2_EST = 'RS' THEN '43'
                    WHEN SA2.A2_EST = 'MS' THEN '50'
                    WHEN SA2.A2_EST = 'MT' THEN '51'
                    WHEN SA2.A2_EST = 'GO' THEN '52'
                    WHEN SA2.A2_EST = 'DF' THEN '53'
                    WHEN SA2.A2_EST = 'SE' THEN '28'
                    WHEN SA2.A2_EST = 'BA' THEN '29'
                    WHEN SA2.A2_EST = 'EX' THEN '99'
                END AS CODEST
FROM %table:SFT% SFT
INNER JOIN %table:SA2% SA2 ON (SFT.FT_CLIEFOR = SA2.A2_COD
                          AND SFT.FT_LOJA = SA2.A2_LOJA)
INNER JOIN SYS_COMPANY EMP ON EMP.M0_CODFIL = SFT.FT_FILIAL
AND EMP.D_E_L_E_T_ = SFT.D_E_L_E_T_
WHERE SFT.%notdel%
  AND A2_COD_MUN <> '09705'
  AND FT_FILIAL >= %Exp:MV_PAR01%
  AND FT_FILIAL <= %Exp:MV_PAR02%
  AND FT_ENTRADA >= %Exp:Dtos(MV_PAR03)%
  AND FT_ENTRADA <= %Exp:Dtos(MV_PAR04)%
  AND FT_ESPECIE = 'NFS'

 GROUP BY FT_CODISS,
         FT_ESPECIE,
         A2_COD_MUN,
         FT_EMISSAO,
         FT_NFISCAL,
         FT_ALIQICM,
         FT_VALICM,
         A2_CGC,
         A2_INSCRM,
         A2_INSCR,
         A2_NOME,
         A2_END,
         A2_NR_END,
         A2_COMPLEM,
         A2_BAIRRO,
         A2_CEP,
         A2_EMAIL,
         FT_FILIAL,
         M0_INSCM,
         A2_EST 
  
  GROUP BY FT_CODISS,FT_ESPECIE,A2_COD_MUN,FT_EMISSAO,FT_NFISCAL,FT_ALIQICM,FT_VALICM,A2_CGC,A2_INSCRM,A2_INSCR,A2_NOME,A2_END,A2_NR_END,A2_COMPLEM,A2_BAIRRO,A2_CEP,A2_EMAIL,FT_FILIAL,M0_INSCM,A2_EST
  ORDER BY NF
	
    EndSql

	cData    := Date()
	// Registro Tipo 1 – Cabeçalho
	cLinha +="1" //Tipo de Registro - 1
	cLinha +=PADL("REST_LOTE",12) //Tipo do Arquivo - 2/13
	cLinha +=PADL((cAlias)->M0IM,15) //Inscrição Municipal do Tomador - 14/28
	cLinha +=PADL("",3) // Campo Reservado Prefeitura - 29/31
	cLinha +=STRTRAN((DTOS(cData)), '/', '' ) //Data que o arquivo foi gerado - 32/39
	cLinha +=CRLF
	// Registro Tipo 2 – Nota Fiscal
	While (cAlias)->(! Eof())
        cAliq := STRTRAN((cAlias)->ALIQ," ","")
		cLinha += PADL("2",1) // Cod segmento - 1
		cLinha += PADL(Alltrim((cAlias)->CODISS),7) // Cod serviço  - 2/8 -Informe o código do serviço, de acordo com Lei 116 de 2003
		cLinha += (cAlias)->MODELO // Tipo documento 9/10
		cLinha += PADL(Alltrim((cAlias)->CODEST),2) // Código Cidade Serviço prestado - 11/17
		cLinha += PADL(Alltrim((cAlias)->MUNPREST),5) // Código Cidade Serviço prestado - 11/17
		cLinha += PADL(Alltrim((cAlias)->EMISNF),8) // Data do serviço - 18/25
		cLinha += PADL(Alltrim((cAlias)->NF),15) // Numero documento - 26/40
		cLinha += (cAlias)->TRIBMUN // Tributado no municipio - 1
		cLinha += PADL(ALLTRIM(STRTRAN(STR((cAlias)->VLNFTRIB, 15, 2), ".", "")), 15, "0") // Valor do Serviço - 42/56
        cLinha += PADR(cAliq,3,"0")// Alíquota 57/59
        cLinha += PADL(ALLTRIM(STRTRAN(STR((cAlias)->VLRISS, 15, 2), ".", "")), 15, "0") //Valor Retenção ISS - 60/74
		cLinha += PADL(Alltrim((cAlias)->CGC),15) // CPF / CNPJ Prestador - 75/89
		cLinha += PADL(Alltrim((cAlias)->IMUNI),15) // Inscrição Municipal prestador - 90/104
		cLinha += PADL(Alltrim((cAlias)->IEST),15) // Inscrição Estadual prestador - 105/119
		cLinha += PADL(Alltrim((cAlias)->NOME),100) // Nome / Razão Social prestador - 120/219
		cLinha += PADL(Alltrim((cAlias)->ENDE),50) // Endereço prestador - 220/269
		cLinha += PADL(Alltrim((cAlias)->NUMERO),10) // Número prestador - 270/279
		cLinha += PADL(Alltrim((cAlias)->COMPL),30) // Complemento Endereço prestador - 280/309
		cLinha += PADL(Alltrim((cAlias)->BAIRRO),30) //Bairro Prestador - 310/339
		cLinha += PADL(Alltrim((cAlias)->MUNPREST),7) // Código Cidade prestador(Código IBGE) - 340/346
		cLinha += PADL(Alltrim((cAlias)->CEP),8) // CEP prestador - 347/354
		cLinha += PADL(Alltrim((cAlias)->EMAIL),100) // E-mail prestador - 355/454
		cLinha += PADL("SERVICO TOMADO",100) // Descrição de Serviço - 462 <=2000


		cLinha +=CRLF
		(cAlias)->(DbSkip())
	EndDo
    // RRegistro Tipo 3 – Rodapé
       cLinha += PADL("3",1) // Cod segmento - 1
	FWrite(nHandle, cLinha)
	FCLOSE(nHandle)


Return
