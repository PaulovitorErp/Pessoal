#Include "Protheus.ch"

User Function MATA030()

    Local aParam     := PARAMIXB
    Local oObj       := aParam[1]
    Local cIdPonto   := aParam[2]
    Local cIdModel   := IIf( oObj<> NIL, oObj:GetId(), aParam[3] ) //cIdModel   := aParam[3]
    Local cClasse    := IIf( oObj<> NIL, oObj:ClassName(), '' )
    Local nOperation := IIf( oObj<> NIL, oObj:GetOperation(), 0)
    Local xRet       := .T.
    Local lIsGrid    := .F.
    Local nLinha     := 0
    Local nQtdLinhas := 0
    Local cMsg       := ''
    Local cOperad := ""

    If aParam <> NIL

        oObj       := aParam[1]
        cIdPonto   := aParam[2]
        cIdModel   := IIf( oObj<> NIL, oObj:GetId(), aParam[3] ) //cIdModel   := aParam[3]
        cClasse    := IIf( oObj<> NIL, oObj:ClassName(), '' )
        nOperation := IIf( oObj<> NIL, oObj:GetOperation(), 0)

        lIsGrid    := ( Len( aParam ) > 3 ) .and. cClasse == 'FWFORMGRID'

        If lIsGrid
            nQtdLinhas := oObj:GetQtdLine()
            nLinha     := oObj:nLine
        EndIf

        If cIdPonto == 'MODELVLDACTIVE'

            Alert("Entrou no ponto de entrada MODELVLDACTIVE")

        ElseIf cIdPonto == 'BUTTONBAR'
            //Para a inclusão de botões na ControlBar.
            Alert("Entrou no ponto de entrada BUTTONBAR")

        ElseIf cIdPonto == 'FORMLINEPRE'
            //Antes da alteração da linha do formulário FWFORMGRID.
            Alert("Entrou no ponto de entrada FORMLINEPRE")

        ElseIf cIdPonto ==  'FORMPRE'
            //Antes da alteração de qualquer campo do formulário.
            Alert("Entrou no ponto de entrada FORMPRE")

        ElseIf cIdPonto == 'FORMPOS'
            //Na validação total do formulário.
            Alert("Entrou no ponto de entrada FORMPOS")

        ElseIf cIdPonto == 'FORMLINEPOS'
            //Na validação total da linha do formulário FWFORMGRID. formulário
            Alert("Entrou no ponto de entrada FORMLINEPOS")

        ElseIf cIdPonto ==  'MODELPRE'
            //Antes da alteração de qualquer campo do modelo.
            Alert("Entrou no ponto de entrada MODELPRE")

        ElseIf cIdPonto == 'MODELPOS'
            //Na validação total do modelo.
            Alert("Entrou no ponto de entrada MODELPOS")

        ElseIf cIdPonto == 'FORMCANCEL'
            //No cancelamento do botão.
            Alert("Entrou no ponto de entrada FORMCANCEL")

        ElseIf cIdPonto == 'FORMCOMMITTTSPRE'
            //Antes da gravação da tabela do formulário.
            Alert("Entrou no ponto de entrada FORMCOMMITTTSPRE")

        ElseIf cIdPonto == 'FORMCOMMITTTSPOS'
            //Após a gravação da tabela do formulário.
            Alert("Entrou no ponto de entrada FORMCOMMITTTSPOS")

        ElseIf cIdPonto == 'MODELCOMMITTTS'
            //Após a gravação total do modelo e dentro da transação.
            Alert("Entrou no ponto de entrada MODELCOMMITTTS")

        ElseIf cIdPonto == 'MODELCOMMITNTTS'
            //Após a gravação total do modelo e fora da transação.
            Alert("Entrou no ponto de entrada MODELCOMMITNTTS")


        ElseIf cIdPonto == 'MODELCANCEL'
            Alert("Entrou no ponto de entrada MODELCANCEL")
            //cMsg := 'Chamada no Botão Cancelar (MODELCANCEL).' + CRLF + 'Deseja Realmente Sair ?'

        endif

    endif

Return xRet
