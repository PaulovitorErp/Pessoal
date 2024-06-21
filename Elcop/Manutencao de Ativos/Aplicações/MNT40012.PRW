#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"


User Function MNT40012()
    //Indica se o ponto de entrada é chamado pela finalização de O.S. do MNTA435
    Local lRetMod2  := IsInCallStack("Mnt435Fin")
    //Variavel de contador do laço de repetição
    Local nX
    Local nMdo      := 1
    Local aAreaSD1 := SD1->(FWGetArea())
    //+---------------------------------------------------------------------------------+
    //| Variavel de retorno (array), deve receber o conteudo a |
    //| ser usado como relação dos campos no modelo: |
    //| {"TJ_DTPRINI","SToD('"+DToS(dDtIni)+"')"} |
    //| Sendo: |
    //| primeira posição o nome do campo que receberá o conteúdo |
    //| segunda posição o conteúdo que o campo receberá (o conteúdo deve ser executavel |
    //+---------------------------------------------------------------------------------+
    Local aArray    := {}
    //Variaveis com o conteudo a ser passado para a variavel de retorno
    Local dDtIni    := StoD(Space(TamSx3("TJ_DTPRINI")[1]))
    Local cHrIni    := Space(TamSx3("TJ_HOPRINI")[1])
    Local dDtFim    := StoD(Space(TamSx3("TJ_DTPRFIM")[1]))
    Local cHrFim    := Space(TamSx3("TJ_HOPRFIM")[1])
    Local cFornece   := Space(TamSx3("TJ_XCODFOR")[1])
    Local cIrregu   := Space(TamSx3("TJ_IRREGU")[1])
    //Variaveis utilizadas para verificação do acols, quando PE chamado pelo MNTA435
    Local aHeader
    Local aCols
    Local nTpReg
    Local nDtIni
    Local nHrIni
    Local nDtFim
    Local nHrFim
    If lRetMod2
        aHeader         := ParamIxb[1]
        aCols           := ParamIxb[2]
        If Len(aHeader) > 0 .And. Len(aCols) > 0 //Verifica se o array de insumos possui conteúdo
            //Pega a posição correspondente dos campos
            nTpReg          := aScan(aHeader,{|x| Trim(Upper(x[2])) == "TL_TIPOREG"})
            nDtIni          := aScan(aHeader,{|x| Trim(Upper(x[2])) == "TL_DTINICI"})
            nHrIni          := aScan(aHeader,{|x| Trim(Upper(x[2])) == "TL_HOINICI"})
            nDtFim          := aScan(aHeader,{|x| Trim(Upper(x[2])) == "TL_DTFIM"})
            nHrFim          := aScan(aHeader,{|x| Trim(Upper(x[2])) == "TL_HOFIM"})
            //Efetua a lógica para o valor a ser passado para os campos
            For nX          := 1 To Len(aCols)
                If aCols[nX][nTpReg] == "M" .And. !aCols[nX][Len(aCols[nX])]
                    If nMdo == 1
                        dDtIni          := aCols[nX][nDtIni]
                        cHrIni          := aCols[nX][nHrIni]
                        dDtFim          := aCols[nX][nDtFim]
                        cHrFim          := aCols[nX][nHrFim]
                    Else
                        If DtoS(aCols[nX][nDtIni]) + aCols[nX][nHrIni] < DtoS(dDtIni)+cHrIni
                            dDtIni          := aCols[nX][nDtIni]
                            cHrIni          := aCols[nX][nHrIni]
                        EndIf
                        If DtoS(aCols[nX][nDtFim]) + aCols[nX][nHrFim] > DtoS(dDtFim)+cHrFim
                            dDtFim          := aCols[nX][nDtFim]
                            cHrFim          := aCols[nX][nHrFim]
                        EndIf
                    EndIf
                    nMdo++
                EndIf
            Next nX
        EndIf
    Else
        //Caso não seja chamado pelo MNTA435, indica que o PE foi chamado pelo MNTA400
        //Então realiza a busca na tabela de insumos ao invés do array.
        dbSelectArea("STL")
        dbSetOrder(4) //TL_FILIAL+TL_ORDEM+TL_PLANO+TL_TIPOREG+TL_CODIGO
        dbSeek(xFilial("STL") + STJ->TJ_ORDEM + STJ->TJ_PLANO + "P" )
        While !Eof() .And. STL->TL_ORDEM == STJ->TJ_ORDEM .And.;
                STL->TL_PLANO == STJ->TJ_PLANO .And. STL->TL_TIPOREG == "P"
            If STL->TL_SEQRELA <> "0"
                If nMdo == 1
                    dDtIni          := STL->TL_DTINICI
                    cHrIni          := STL->TL_HOINICI
                    dDtFim          := STL->TL_DTFIM
                    cHrFim          := STL->TL_HOFIM
                Else
                    If DtoS(STL->TL_DTINICI) + STL->TL_HOINICI < DtoS(dDtIni)+cHrIni
                        dDtIni          := STL->TL_DTINICI
                        cHrIni          := STL->TL_HOINICI
                    EndIf
                    If DtoS(STL->TL_DTFIM) + STL->TL_HOFIM > DtoS(dDtFim)+cHrFim
                        dDtFim          := STL->TL_DTFIM
                        cHrFim          := STL->TL_HOFIM
                    EndIf
                EndIf
                nMdo++
            EndIf
            dbSkip()
        EndDo
 //   EndIf

// Grava busca o conteudo do campo TJ_XCODFOR 
 //   If (EMPTY(STJ->TJ_XCODFOR))

 /*
#############################################################################
#############################################################################
## Programa  | MNTA40012 |Autor|  ANDRE CASTILHO		|Data|  03/03/2024 ##
##=========================================================================##
## Desc.| PONTO DE ENTRADA RETORNA CODIGO FORNECEDOR NA BAIXA O.S          ##
##=========================================================================##
## Uso       | Elcop	                                               	   ##
#############################################################################
#############################################################################
*/

DBSelectArea("SD1")
        SD1->(DbSetorder(9)) //D1_FILIAL+D1_COD+D1_ORDEM
        dbSeek(xFilial("SD1")+ALLTRIM(STJ->TJ_ORDEM))
     //    If ALLTRIM(SD1->D1_ORDEM) = ALLTRIM(STJ->TJ_ORDEM)
       //         STJ->(reclock("STJ",.T.))
         //           STJ->TJ_XCODFOR := ALLTRIM(SD1->D1_FORNECE)
           //         			If !MsUnlock()
            //            Alert("erro ao desbloquear registro!")
                    cFornece  := SD1->D1_FORNECE
                    cIrregu :="006"
              
             //  EndIf
                dbCloseArea("SD1")
               // EndIf
     EndIf
    aadd(aArray, {"TJ_DTPRINI", "SToD( '"+DToS(dDtIni)+"' )"})
    aadd(aArray, {"TJ_HOPRINI", " '"+cHrIni+"' "})
    aadd(aArray, {"TJ_DTPRFIM", "SToD( '"+DToS(DaySum(dDtFim,1))+"' )"})
    aadd(aArray, {"TJ_HOPRFIM", " '"+cHrFim+"' "})
    aadd(aArray, {"TJ_DTMRFIM", "SToD( '"+DToS(DaySum(dDtFim,1))+"' )"})
    aadd(aArray, {"TJ_XCODFOR", " '"+cFornece+"' "})
    aadd(aArray, {"TJ_IRREGU", " '"+cIrregu+"' "})
  

Return aArray