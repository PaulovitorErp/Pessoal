#Include 'Protheus.ch'

/*/-------------------------------------------------------------------
- Programa: UACDA002
- Autor: Wellington Gonçalves
- Data: 20/06/2023
- Descrição: Execauto de baixa de pré-requisção via ACD - MATA185
-------------------------------------------------------------------/*/

User Function UACDA002()

Local aSCP := {}
Local aSD3 := {}
Local aRelProj := {}
Local nX
Local nAux
Local nAux2
Private lMSHelpAuto := .F.
Private lMsErroAuto := .F.


SCP->(dbSetOrder(1))
For nX := 1 To len(aItemReq)

    If SCP->(dbSeek(xFilial("SCP") + cRequisicao + aItemReq[nX][1]))
        
        aSCP := {   { "CP_NUM"   , cRequisicao        , Nil } , ;
                    { "CP_ITEM"  , aItemReq[nX][1]    , Nil } , ;
                    { "CP_QUANT" , aItemReq[nX][6]    , Nil } } 

        aSD3 := {   { "D3_TM"       , "501"              , Nil } , ; // Tipo do Mov.
                    { "D3_COD"      , aItemReq[nX][2]    , Nil } , ;
                    { "D3_LOCAL"    , aItemReq[nX][4]    , Nil } , ;
                    { "D3_DOC"      , ""                 , Nil } , ; // No.do Docto.
                    { "D3_LOCALIZ"  , aItemReq[nX][4]    , Nil } , ; // No.do Docto.
                    { "D3_LOTECTL"  , "P-01"             , Nil } , ;
                    { "D3_EMISSAO"  , DDATABASE          , Nil } }


        MSExecAuto({|v,x,y,z,w| mata185(v,x,y,z,w)},aSCP,aSD3,1,,aRelProj)   // 1 = BAIXA (ROT.AUT)
            
        If lMsErroAuto

            aLogAuto := GetAutoGRLog()
            cLogTxt := "" 

            //Percorrendo o Log e incrementando o texto (para usar o CRLF você deve usar a include "Protheus.ch")
            For nAux := 1 To Len(aLogAuto)

                If !Empty(aLogAuto[nAux])

                    aTemp := StrToKarr(Alltrim(aLogAuto[nAux]), CRLF)
                    For nAux2 := 1 to len(aTemp)
                        cLogTxt += Alltrim(aTemp[nAux2]) + "\n"
                        Conout(cLogTxt)
                    Next

                EndIf

            Next

            CBAlert(cLogTxt,"Erro",.T.,3000,2)
            VTKeyBoard(chr(20))

        Else

            // verifico se mesmo o execauto retornando que nao teve erro, se a SA foi baixada
            if SCP->CP_STATUS <> "E"
                cLogTxt += "Erro na baixa da SA!" + "\n"
                Conout("Erro na baixa da SA!")
            else 

                VtClear()
                CBAlert("Baixa efetuada com sucesso!","Aviso",.T.,3000,2)
                VTKeyBoard(chr(20))

            endif 

        EndIf

    EndIf

Next

Return
