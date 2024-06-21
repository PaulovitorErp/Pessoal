#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"





User Function MNTA7161()
   
Local lRetorno := .T.

Local aRegistros := PARAMIXB[1]

Local cCodLayout := PARAMIXB[2]

Local nTotal := 0

Local aDados := {}

Local nPos

Local cNumAbast

Local cPlaca


      
   
   if cCodLayout=="000006" 
        For nTotal := 1 to len(aRegistros)  
       nPos := aRegistros[4][1]
       cNumAbast := aRegistros[9][1]
       cPlaca :=aRegistros[5][1]
   //  aDados[nTotal] := (aRegistros[4][1],aRegistros[9][1],aRegistros[5][1])
        aDados[1]["hora"] := nPos
        aDados[2]["Abastecimento"] := cNumAbast
        aDados[3]["Placa"] := cPlaca

     Next  nTotal++
endif
     /*
     DbSelectArea('TR6')
     TR6->(DbSetOrder(1))
		if TR6->(DbSeek(cNumAbast))
			if alltrim(TR6->TR6_PLACA) = alltrim(aRegistros[5][1]) 
				if TR6->TR6_HRABAS ==aRegistros[4][1]
                     MsgAlert("Registro duplicado"+aRegistros[5][1]+"registros")
					lRetorno := .F.
				endif
                 endif
                  endif
                   endif
                   */
Return lRetorno



/*   aDados[1] := TR6->TR6_VLTOT
          aDados[1] := TR6->TR6_DTABAS
          aDados[1] := TR6->TR6_HRABAS
          aDados[1] := TR6->TR6_PLACA
          aDados[1] := TR6->TR6_TIPCOM
          aDados[1] := TR6->TR6_KMABAS
          aDados[1] := TR6->TR6_CNPJ
          aDados[1] := TR6->TR6_NUMABA         
          aDados[1] := TR6->TR6_CPFMOT
          aDados[1] := TR6->TR6_CONVEN*/