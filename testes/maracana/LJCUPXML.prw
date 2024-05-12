#include 'protheus.ch'
#include 'parmtype.ch'

/*/-------------------------------------------------------------------
- Programa: LJCUPXML
- Autor: DUOFY
- Data: 20/10/2023
- Descrição: Este ponto de entrada é chamado em pontos diferentes durante a geração do XML do cupom da venda,
possibilitando a inserção de novos trechos conforme obrigações específicas.
-------------------------------------------------------------------/*/

User Function LJCUPXML()

Local aSD2          := SD2->(GetArea())
Local aArea         := GetArea()
Local cModeloDoc    := ParamIXB[1]  // Modelo de documento do XML
Local cPontoXML     := ParamIXB[2]  // Ponto do XML em que o PE esta sendo chamado
Local cRetXML       := "" // Retorno do Ponto de Entrada
Local cChaveCD2     := ""
Local nAliq         := 0
Local nLitragem     := 0
Local nValor        := 0
Local nTotLit       := 0
Local nTolValor     := 0

If Upper(cModeloDoc) == "65" // NFC-e

    If Upper(cPontoXML) == "ICMS"   // Itens

        SD2->( DbSetOrder(3) )
        if SD2->( DbSeek( xFilial("SD2") + SL2->L2_DOC + SL2->L2_SERIE + SL1->L1_CLIENTE + SL1->L1_LOJA + SL2->L2_PRODUTO + SL2->L2_ITEM) )
        
            if Right(SD2->D2_CLASFIS,2) == '61'
            
                // Neste trecho o P.E. estar posicionado no loop dos impostos dos itens
                // SitTrib 61

                cChaveCD2 := xFilial("CD2")+"S"+SD2->D2_SERIE+SD2->D2_DOC+SD2->D2_CLIENTE+SD2->D2_LOJA+SD2->D2_ITEM
                if CD2->(DbSeek(cChaveCD2))
                    
                    While CD2->(!eof()) .AND. CD2->CD2_FILIAL+CD2->CD2_TPMOV+CD2->CD2_SERIE+CD2->CD2_DOC+CD2->CD2_CODCLI+CD2->CD2_LOJCLI+Alltrim(CD2->CD2_ITEM) == cChaveCD2
                                        
                        if Alltrim(CD2->CD2_IMP) == "STMONO" .AND. CD2->CD2_CST == "61"

                            nAliq       := CD2->CD2_ALIQ
                            nLitragem   := CD2->CD2_BC
                            nValor      := CD2->CD2_VLTRIB

                            cRetXML := "<ICMS61>"
                            cRetXML += "<orig>0</orig>"
                            cRetXML += "<CST>61</CST>"
                            cRetXML += "<qBCMonoRet>"   + AllTrim( Str(nLitragem,16,4) ) + "</qBCMonoRet>"
                            cRetXML += "<adRemICMSRet>" + AllTrim( Str(nAliq,16,4) ) + "</adRemICMSRet>"
                            cRetXML += "<vICMSMonoRet>" + AllTrim( Str(nValor,16,2) ) + "</vICMSMonoRet>"
                            cRetXML += "</ICMS61>"

                            Exit

                        endif

                        CD2->( DbSkip() )

                    Enddo
                
                endif
            
            endif

        endif 

    ElseIf UPPER(cPontoXML) == "ICMSTOT" // Totalizador

        if SD2->( DbSeek( xFilial("SD2") + SL2->L2_DOC + SL2->L2_SERIE + SL1->L1_CLIENTE + SL1->L1_LOJA) )

            while !SD2->( Eof() ) .and. SL2->L2_DOC == SD2->D2_DOC .and. SL2->L2_SERIE == SD2-D2_SERIE .and. ;
                SL1->L1_CLIENTE == SD2->D2_CLIENTE .and. SL1->L1_LOJA == SD2->D2_LOJA

                if Right(SD2->D2_CLASFIS,2) == '61'
                
                    cChaveCD2 := xFilial("CD2")+"S"+SD2->D2_SERIE+SD2->D2_DOC+SD2->D2_CLIENTE+SD2->D2_LOJA+SD2->D2_ITEM
                    if CD2->(DbSeek(cChaveCD2))
                        
                        While CD2->(!eof()) .AND. CD2->CD2_FILIAL+CD2->CD2_TPMOV+CD2->CD2_SERIE+CD2->CD2_DOC+CD2->CD2_CODCLI+CD2->CD2_LOJCLI+Alltrim(CD2->CD2_ITEM) == cChaveCD2
                                            
                            if Alltrim(CD2->CD2_IMP) == "STMONO" .AND. CD2->CD2_CST == "61"

                                nTotLit   += CD2->CD2_BC
                                nTolValor += CD2->CD2_VLTRIB

                                Exit

                            endif

                            CD2->( DbSkip() )

                        Enddo
                    
                    endif

                endif

                SD2->( DbSkip() )

            enddo

            // Neste trecho o P.E. esta posicionado no totalizador do ICMS
            if nTotLit > 0
                cRetXML := "<qBCMonoRet>"   + AllTrim( Str(nTotLit,16,4) ) + "</qBCMonoRet>"
                cRetXML += "<vICMSMonoRet>" + AllTrim( Str(nTolValor,16,2) ) + "</vICMSMonoRet>""
            endif

        endif

    EndIf

EndIf

RestArea(aSD2)
RestArea(aArea)

Return(cRetXML)
