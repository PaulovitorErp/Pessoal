#include "Protheus.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � SGAV004  � Autor � Felipe N. Welter      � Data �02/10/2008���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Indicador de Receita Faturada de Residuos                   ���
�������������������������������������������������������������������������Ĵ��
���Tabelas   �TAX - Definicao de Residuos                                 ���
���          �SD2 - Itens de Venda da NF                                  ���
�������������������������������������������������������������������������Ĵ��
���Tabelas   �dDataDe - Data Inicio para Emissao da Nota (SD2)            ���
���          �dDataAte - Data Fim para Emissao da Nota                    ���
���          �cGrupoDe - Grupo Inicio de Residuos (SB1)                   ���
���          �cGrupoAte - Grupo Fim de Residuos                           ���
���          �cLocalDe -  Local (Armazem) de Inicio (SD2)                 ���
���          �cLocalAte - Local (Armazem) de Fim                          ���
���          �cGerDe - Fonte Geradora Inicial (TAX)                       ���
���          �cGerAte - Fonte Geradora Final                              ���
���          �cResDe - Codigo do Residuo Inicio (TAX)                     ���
���          �cResAte - Codigo do Residuo Fim                             ���
���          �cGeracaoe - Tipo de Geracao Reciclavel/Nao-Reciclavel/Ambos ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SigaSGA                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � F.O  �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function SGAV004(dDataDe,dDataAte,cGrupoDe,cGrupoAte,cLocalDe,cLocalAte,cGerDe,cGerAte,cResDe,cResAte,cGeracao)

Local nRet := 0
Local cAliasQry, cQuery

cAliasQry := GetNextAlias()

cQuery := "SELECT ISNULL(SUM(SD2.D2_TOTAL),0) RESULT FROM "+ RetSQLName("TAX") +" TAX INNER JOIN "+ RetSQLName("SB1")+" "
cQuery += "SB1 ON TAX.TAX_CODRES = SB1.B1_COD "
cQuery += "JOIN "+ RetSQLName("SD2") +" SD2 ON SB1.B1_COD = SD2.D2_COD "

cQuery += "JOIN "+ RetSQLName("TAV") +" TAV ON (TAV.TAV_FILIAL = '"+ xFilial("TAV") +"' AND TAV.TAV_CODNIV = (SELECT MAX(TAV2.TAV_CODNIV) FROM "+ RetSQLName("TAV") +" TAV2 "
cQuery += "WHERE TAV2.TAV_FILIAL = '"+ xFilial("TAV") +"' AND TAV2.TAV_CODRES = SD2.D2_COD "
If cLocalDe <> Nil .And. cLocalAte <> Nil
	cQuery += "AND TAV2.TAV_CODNIV BETWEEN '"+cLocalDe+"' AND '"+cLocalAte+"' "
EndIf
cQuery += "AND TAV2.D_E_L_E_T_ = ' ') AND TAV.TAV_CODRES = SD2.D2_COD AND TAV.D_E_L_E_T_ = ' ') "

cQuery += "WHERE TAX.TAX_FILIAL = '"+ xFilial("TAX") +"' "
cQuery += "AND SD2.D2_FILIAL = '"+ xFilial("SD2") +"' "
cQuery += "AND SB1.B1_FILIAL = '"+ xFilial("SB1") +"' "
cQuery += " AND TAX.D_E_L_E_T_ = ' ' AND SB1.D_E_L_E_T_ = ' ' AND SD2.D_E_L_E_T_ = ' ' AND TAV.D_E_L_E_T_ = ' ' "

If cGeracao <> Nil
	If cGeracao $ '12'
		cQuery += "AND TAX.TAX_TPGERA = '"+cGeracao+"'"
	EndIf
EndIf

If dDataDe <> Nil .And. dDataAte <> Nil
	cQuery += "AND SD2.D2_EMISSAO BETWEEN '" + DTOS(dDataDe) + "' AND '" + DTOS(dDataAte) + "' "
EndIf

If cGrupoDe <> Nil .And. cGrupoAte <> Nil
	cQuery += "AND SB1.B1_GRUPO BETWEEN '" + cGrupoDe + "' AND '" + cGrupoAte + "' "
Endif

If cGerDe <> Nil .And. cGerAte <> Nil
	cQuery += " AND TAX.TAX_CODFON BETWEEN '" + cGerDe + "' AND '" + cGerAte + "' "
EndIf

If cResDe <> Nil .And. cResAte <> Nil
	cQuery += " AND TAX.TAX_CODRES BETWEEN '"+cResDe+"' AND '"+cResAte+"' "
EndIf

cQuery := ChangeQuery(cQuery)
MPSysOpenQuery( cQuery , cAliasQry )

dbSelectArea(cAliasQry)
nRet := (cAliasQry)->RESULT

Return nRet