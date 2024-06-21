#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#include "topconn.ch"

//MT150END - Complementa a atualização manual das cotações de compra

User Function MT150END()

Local nOp := PARAMIXB[1]

    IF nOp = 2 .OR. nOp = 3 //Caso seja Alterar ou Incluir
        TelaNotaFor()
    EndIf

Return()


Static Function TelaNotaFor()

	dbSelectArea("SA2")
	SA2->(dbSetOrder(1))  				
	MsSeek(xFilial("SA2")+SC8->C8_FORNECE+SC8->C8_LOJA)

    Private oButton1
    Private oButton2
    Private oGet1
    Private cGet1 := SA2->A2_XNOTALV //Cordialidade
    Private oGet2
    Private cGet2 := SA2->A2_XNOTDOC //Negociacao
    Private oGet3 
    Private cGet3 := SA2->A2_XNOTCOM //Forma Pagamento
    Private oSay1
    Private oSay2
    Private oSay3
    Private oComboBo1
    Private nComboBo1 := 1  
    Private oComboBo2
    Private nComboBo2 := 1    
    Private oComboBo3
    Private nComboBo3 := 1              
    Static oDlgfor

    if SA2->A2_XNOTALV = 100
        nComboBo1 := 1 
    Elseif SA2->A2_XNOTALV = 50 
        nComboBo1 := 2
    Elseif SA2->A2_XNOTALV = 0
        nComboBo1 := 3 
    EndIf

    if SA2->A2_XNOTDOC = 100
        nComboBo2 := 1 
    Elseif SA2->A2_XNOTDOC = 50 
        nComboBo2 := 2
    Elseif SA2->A2_XNOTDOC = 0
        nComboBo2 := 3 
    EndIf

    if SA2->A2_XNOTCOM = 100
        nComboBo3 := 1 
    Elseif SA2->A2_XNOTCOM = 50 
        nComboBo3 := 2
    Elseif SA2->A2_XNOTCOM = 0
        nComboBo3 := 3 
    EndIf

    DEFINE MSDIALOG oDlgfor TITLE "Nota Fornecedor" FROM 000, 000  TO 200, 500 COLORS 0, 16777215 PIXEL

        @ 012, 006 SAY oSay1 PROMPT "Cordialidade: " SIZE 060, 007 OF oDlgfor COLORS 0, 16777215 PIXEL
        //@ 025, 007 MSGET oGet1 VAR cGet1 SIZE 060, 010 OF oDlgfor COLORS 0, 16777215 PIXEL Picture '@E 999.99'
        @ 025, 006 MSCOMBOBOX oComboBo1 VAR nComboBo1 ITEMS {"1 - Otimo","2 - Regular","3 - Ruim"} SIZE 063, 010 OF oDlgfor COLORS 0, 16777215 PIXEL
        @ 012, 079 SAY oSay2 PROMPT "Negociacao: " SIZE 042, 007 OF oDlgfor COLORS 0, 16777215 PIXEL
        //@ 025, 077 MSGET oGet2 VAR cGet2 SIZE 060, 010 OF oDlgfor COLORS 0, 16777215 PIXEL Picture '@E 999.99'
        @ 025, 077 MSCOMBOBOX oComboBo2 VAR nComboBo2 ITEMS {"1 - Otimo","2 - Regular","3 - Ruim"} SIZE 063, 010 OF oDlgfor COLORS 0, 16777215 PIXEL
        @ 012, 148 SAY oSay3 PROMPT "Form. Pagam: " SIZE 053, 007 OF oDlgfor COLORS 0, 16777215 PIXEL
       // @ 025, 148 MSGET oGet3 VAR cGet3 SIZE 060, 010 OF oDlgfor COLORS 0, 16777215 PIXEL Picture '@E 999.99'
        @ 025, 148 MSCOMBOBOX oComboBo3 VAR nComboBo3 ITEMS {"1 - Otimo","2 - Regular","3 - Ruim"} SIZE 063, 010 OF oDlgfor COLORS 0, 16777215 PIXEL
        
        @ 081, 206 BUTTON oButton1 PROMPT "Confirmar" SIZE 037, 012 OF oDlgfor PIXEL ACTION (GrvFor(),oDlgfor:End())
        @ 081, 163 BUTTON oButton2 PROMPT "Fechar"    SIZE 037, 012 OF oDlgfor PIXEL ACTION (oDlgfor:End())    

    ACTIVATE MSDIALOG oDlgfor CENTERED

Return()

Static Function GrvFor()
        XNOTALV  := 0 
        XNOTDOC  := 0
        XNOTCOM  := 0

        if oComboBo1:NAT = 1
            XNOTALV := 100
        Elseif oComboBo1:NAT = 2
            XNOTALV := 50
        Elseif oComboBo1:NAT = 3
            XNOTALV := 0
        EndIf

        if oComboBo1:NAT = 1
            XNOTDOC := 100
        Elseif oComboBo1:NAT = 2
            XNOTDOC := 50
        Elseif oComboBo1:NAT = 3
            XNOTDOC := 0
        EndIf

        if oComboBo3:NAT = 1
            XNOTCOM := 100
        Elseif oComboBo3:NAT = 2
            XNOTCOM := 50
        Elseif oComboBo3:NAT = 3
            XNOTCOM := 0
        EndIf

		RecLock( "SA2" , .F. )
		    SA2->A2_XNOTALV := XNOTALV //cGet1
            SA2->A2_XNOTDOC := XNOTDOC
            SA2->A2_XNOTCOM := XNOTCOM
		MsUnLock()	

        //A2_XIQF    = IQF FORNECEDOR
        //A2_XIQFMED = IQF MEDIO
    
        MsgAlert("Registro Gravado com Sucesso!")

Return()
