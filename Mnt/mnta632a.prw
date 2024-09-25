#include 'protheus.ch'
#include 'mnta632.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA632A
Abre historico do contador da bomba selecionada

@author Vitor Emanuel Batista
@since 29/09/2009
@obs refeito por Maria Elisandra de Paula em 04/02/2021
@return Nil
/*/
//---------------------------------------------------------------------
Function MNTA632A()

	Local aNGBEGINPRM := NGBEGINPRM(,"MNTA632",Nil,.T.)
	Local aInd        := {}
    Local cCond       := "TTV->TTV_FILIAL == '"+xFilial("TTV")+"' .AND. TTV->TTV_POSTO  == '"+TQJ->TQJ_CODPOS+"' .AND. " +;
                        "TTV->TTV_LOJA   == '"+TQJ->TQJ_LOJA+"' .AND. TTV->TTV_TANQUE == '"+TQJ->TQJ_TANQUE+"' .AND. " +; 
                        "TTV->TTV_BOMBA  == '"+TQJ->TQJ_BOMBA+"' "
	Local cFunBkp     := FunName()

    Private aRotina   := MenuDef()
    Private cCadastro := OemtoAnsi(STR0005) //"Histórico do Contador da Bomba"

	SetFunName( 'MNTA632A' )

	dbSelectarea('TTV')
	dbSetOrder(1)

	bFiltraBrw := {|| FilBrowse( 'TTV', @aInd, @cCond, .T. ) }
	Eval( bFiltraBrw )

	mBrowse( 6, 1, 22, 75, 'TTV' )

	aEval( aInd, {|x| Ferase(x[1] + OrdBagExt() ) } )
	ENDFILBRW('TTV', aInd )
	NGRETURNPRM( aNGBEGINPRM )

	SetFunName( cFunBkp )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Retorna menu funcional da rotina

@author Vitor Emanuel Batista
@since 29/09/2009
@obs refeito por Maria Elisandra de Paula em 04/02/2021
@return Nil
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aReturn := { { STR0002 ,"AxPesqui"   , 0 , 1},; //"Pesquisar"###
		        		{ STR0004 ,"NGCAD01"    , 0 , 2},; //"Visualizar"
    				    { STR0013 ,"MNTA632CAN" , 0 , 5}} //"Canc. Quebra"

Return aReturn 
