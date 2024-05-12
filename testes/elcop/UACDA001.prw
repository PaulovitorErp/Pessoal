#Include "TopConn.ch"
#Include "PROTHEUS.CH"
#Include "TOTVS.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWMVCDEF.CH"

/*/-------------------------------------------------------------------
- Programa: UACDA002
- Autor: Wellington Gonçalves
- Data: 20/06/2023
- Descrição: Rotina de baixa de pré-requisção via ACD
-------------------------------------------------------------------/*/

User Function UACDA001()

    Local lContinua     := .T.
    Private cAliasEmp   := ""
    Private cRequisicao := Space(TamSx3("CP_NUM")[1])
    Private cCodEti     := Space(TamSx3("B1_CODBAR")[1])
    Private cEndereco   := Space(TamSx3("D3_LOCALIZ")[1])
    Private nQtdTrf     := 0
    Private nQtdSDC     := 0
    Private aCols       := {}
    Private aItemReq    := {}

    //solicitando produto e lote
    VTClear
    @ 0,0 vtSay "Baixa Req. Armazém"
    @ 1,0 VTSAY "Num. Solicitação: "
    @ 2,0 VTGET cRequisicao Pict PesqPict("SCP","CP_NUM")  Valid vldReq() F3 "SCP"
    VTREAD	

    While lContinua

        VTClear
        @ 0,0 vtSay "Baixa Req. Armazém"
        @ 1,0 VTSAY "Produto: "
        @ 2,0 VTGET cCodEti Pict PesqPict("SB1","B1_CODBAR")  Valid VldCodEti() 
        @ 3,0 VTSAY "Endereço: "
        @ 4,0 VTGET cEndereco Pict PesqPict("SD3","D3_LOCALIZ")  Valid VldEnd() 
        VTREAD
        
        If VTLastkey() == 27 //esq
            Exit
        endif

        cCodEti := Space(TamSx3("B1_CODBAR")[1])
        
    EndDo

    VtClear()

    if VTYesNo("Confirma a conferencia?","Atencao",.t.)

        @ 0,0 vtSay "Aguarde... efetuando"
        @ 1,0 vtSay "a baixa!"
        //Executa Baixa da requisição
        U_UACDA002()
        VtClear()

    endif

Return

Static Function vldReq()

    aItemReq := {}
    
    if Empty(cRequisicao)

        CBAlert("Informe uma requisição!","Aviso",.T.,3000,2)
		VTKeyBoard(chr(20))
		Return .F.

    endif

    SCP->(DbSetOrder(1))
    If !SCP->(DbSeek(xFilial("SCP") + cRequisicao))

        CBAlert("Requisição não encontrada!","Aviso",.T.,3000,2)
		VTKeyBoard(chr(20))
		Return .F.

    Else

        If Empty(SCP->CP_STATUS) .and. !Empty(SCP->CP_PREREQU)

            While !SCP->(Eof()) .And. SCP->(CP_FILIAL+CP_NUM) == xFilial("SCP") + cRequisicao
                aAdd(aItemReq,{SCP->CP_ITEM,SCP->CP_PRODUTO,SCP->CP_QUANT-SCP->CP_QUJE,SCP->CP_LOCAL,AllTrim(SCP->CP_LOTE),0,""})
                SCP->(DbSkip())
            EndDo

        elseIf !Empty(SCP->CP_STATUS)

            CBAlert("Requisição já baixada!","Aviso",.T.,3000,2)
            VTKeyBoard(chr(20))
            Return .F.

        elseIf Empty(SCP->CP_PREREQU)

            CBAlert("Pré-requisição não gerada!","Aviso",.T.,3000,2)
            VTKeyBoard(chr(20))
            Return .F.

        EndIf

    Endif

Return .T.

Static Function VldCodEti()

    if Empty(cCodEti)

        CBAlert("Informe um produto!","Aviso",.T.,3000,2)
		VTKeyBoard(chr(20))
		Return .F.

    endif

    SB1->(DbSetOrder(5)) // B1_FILIAL + B1_CODBAR
    If !SB1->(DbSeek(xFilial("SB1") + cCodEti))

        CBAlert("Produto não encontrado!","Aviso",.T.,3000,2)
		VTKeyBoard(chr(20))
		Return .F.

    Endif

    VTBEEP(1)

Return .T.

Static Function VldEnd()

    if Empty(cCodEti)

        CBAlert("Informe um produto!","Aviso",.T.,3000,2)
		VTKeyBoard(chr(20))
		Return .F.

    endif

    if Empty(cEndereco)

        CBAlert("Informe o endereço do produto!","Aviso",.T.,3000,2)
		VTKeyBoard(chr(20))
		Return .F.

    endif

    SB1->(DbSetOrder(5)) // B1_FILIAL + B1_CODBAR
    If !SB1->(DbSeek(xFilial("SB1") + cCodEti))

        CBAlert("Produto não encontrado!","Aviso",.T.,3000,2)
		VTKeyBoard(chr(20))
		Return .F.

    Else

        SBE->(DbSetOrder(9)) // BE_FILIAL+BE_LOCALIZ
        If !SBE->(DbSeek(xFilial("SBE") + cEndereco))

            CBAlert("Endereço não encontrado!","Aviso",.T.,3000,2)
            VTKeyBoard(chr(20))
            Return .F.

        Else

            nPos := aScan(aItemReq,{|X| Alltrim(x[2]) == AlltRim(SB1->B1_COD)})

            If nPos > 0

                If aItemReq[nPos][6] < aItemReq[nPos][3]

                    aItemReq[nPos][6] += 1
                    aItemReq[nPos][7] := cEndereco
                    VTAlert("Produto registrado","Aviso",.t.,1500)  

                else

                    CBAlert("Item atingiu quantidade limite!","Aviso",.T.,3000,2)
                    VTKeyBoard(chr(20))
                    Return .F.    

                EndIf


            else

                VTKeyBoard(chr(20))
                Return .F.

            EndIf 

        endif

    Endif

    VTBEEP(1)

Return .T.
