#Include 'Protheus.ch'

#Define _nQtdHor 24
#Define _nQtdTHor 26

//Valores do Shape Default

#Define _cGradient "1,0,0,0,0,0.0,#ffffff"
#Define _cHover "1,0,0,0,0,0.0,#000099120"
#Define _cPenWid "1"
#Define _cPenCol "#DCDCDC"
#Define _cCanMov "0"
#Define _cCanMar "1"
#Define _cContei "0"

//------------------------------
// Força a publicação do fonte
//------------------------------
Function TNGAG()
Return
//---------------------------------------------------------------------
/*/{Protheus.doc} TNGAG
Classe utilizada para montar horário detalhado em TPaintPanel

@type class

@source TNGAG.prw

@author Bruno Lobo
@since 10/09/2014
/*/
//---------------------------------------------------------------------
Class TNGAG From TPanel

	//Propriedades
	DATA oTPanel	AS OBJECT //Objeto principal TPaintPanel
	DATA oWnd		AS OBJECT //Janela Pai
	DATA cAliasShp	AS STRING
	DATA nID		AS INTEGER INIT 0
	DATA nWidth		AS INTEGER INIT 0
	DATA nHeight	AS INTEGER INIT 0
	DATA nWidPL		AS INTEGER INIT 0
	DATA nTopPl		AS INTEGER INIT 0
	DATA nHeiCpo	AS INTEGER INIT 0
	DATA nPosMed	AS INTEGER INIT 0
	DATA nTotShp	AS INTEGER INIT 0
	DATA nShpMin	AS INTEGER INIT 0
	DATA oTempTable AS OBJECT

	//Metodo construtor
	Method New( oWnd ) CONSTRUCTOR

	//Metodos
	Method CriateScr()
	Method HalfBox()
	Method ChangeShape()
	Method TrbShp()
	Method SetGradShp()
	Method SetDescriShp()
	Method SetToolTipShp()
	Method SumId()
	Method GetId()
	Method GetIdHora()
	Method GetLeft()
	Method GetWidth()
	Method GetHeith()
	Method GetText()
	Method GetTextRef()
	Method GetHora()
	Method GetHoraShp()
	Method GetHoraRef()
	Method DelBox()
	Method DelTempTbl()

EndClass
//---------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da classe TNGAG

@author Bruno Lobo
@since 10/09/2014

@param oWnd, Janela onde o objeto será criado
@param nWidPL, Largura do painel.
@param nTopPl, Altura do painel.
@param nQtdMin, Quantidade de shapes por linha
@param bLClick, clique com o botão esquerdo do mouse
@param bRClick, Clique da direita

@return Objeto, Objeto da Classe
/*/
//---------------------------------------------------------------------
Method New( oWnd, nWidPL, nTopPl, nQtdMin , bLClick , bRClick ) Class TNGAG
	:New(0, 0, Nil, oWnd, Nil, Nil, Nil, Nil, CLR_WHITE, 0, 0, .F., .F.)

	Local cHex		:= NGRGBHEX( ConvRGB( NGColor()[2] ) )

	::Align	:= CONTROL_ALIGN_ALLCLIENT
	::oWnd		:= oWnd
	::nWidPL	:= nWidPL
	::nTopPl	:= nTopPl
	::nPosMed	:= 1
	::nID		:= 0
	::nTotShp	:= 60 / nQtdMin
	::nShpMin	:= nQtdMin

	::TrbShp()//Cria trb para gravação dos shapes alteraveis

	// Cria o objeto principal
	::oTPanel := TPaintPanel():New( 0 , 0 , 300 , 200 , ::oWnd )
		::oTPanel:Align := CONTROL_ALIGN_ALLCLIENT

		::nWidth	:= ::oTPanel:nClientWidth //Largura total da tela
		::nHeight	:= ::oTPanel:nClientHeight // Altura total da tela
		::nHeiCpo	:= Round( ((::nHeight - ( ::nTopPl + 29 ) ) / _nQtdTHor ) , 1 ) //Altura do campos

		::oTPanel:addShape( "id="+::SumId()+";type=1;"+;
							"left=0;top=2;width="+cValToChar(::nWidth)+";height="+cValToChar(::nHeight)+";"+;
							"gradient=1,0,0,0,40,0.0,#"+cHex+";pen-width=" + _cPenWid + ";" + "pen-color=#D8E4F4;can-move=" + _cCanMov + ";" + "can-mark=0;is-container=1;" )

		//--------------------------------------------------------------------------------------------------
		// Define os blocos de codigo com eventos de Mouse
		//--------------------------------------------------------------------------------------------------
		// EVENTO DE RELEASE(SOLTAR) BOTÃO ESQUERDO DO MOUSE APÓS ARRASTO DO SHAPE::oTPanel:blClicked := {|x,y| alert("Release(Soltar)botão esquerdo - x:"+; strZero(x,5)+' - y:'+strZero(y,5)+; " - ShapeAtu:"+strZero(::oTPanel:ShapeAtu,3)+; " - FrameAtu:"+strZero(::oTPanel:FrameAtu,3) ) }

		// EVENTO DE CLIQUE COM BOTÃO DIREITO DO MOUSE
		::oTPanel:brClicked := bRClick//{|| GetPropShp( ::oTPanel:ShapeAtu ) }
		// Evento de clique com botão esquedo do mouse
		::oTPanel:blClicked := bLClick

Return Self
//---------------------------------------------------------------------
/*/{Protheus.doc} CriateScr
Cria parte estatica da tela.

@type method

@source TNGAG.prw

@param aTurnos, Array, Array com os turnos.

@sample CriateScr( aTurnos )

@return Nulo, Sempre nulo.

@author Bruno Lobo
@since 10/09/2014
/*/
//---------------------------------------------------------------------
Method CriateScr( aTurnos ) Class TNGAG

	Local oCalend
	Local nHeiHr 	:= ::nTopPl
	Local n1, nX
	Local cTextIdShp := ""
	Local lHint := .F.
	Local aHora 	:= { "00:00", "01:00", "02:00", "03:00", "04:00", "05:00", "06:00", "07:00", "08:00", "09:00", "10:00", "11:00",;
							"12:00", "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00", "23:00" }

	Default aTurnos := {}

	//----------------------------
	//	Painel de horarios
	//----------------------------
	For n1 := 1 To _nQtdHor

		If n1 == 1 .Or. n1 == 13
			If n1 == 1

				If Len( aTurnos[ 1 , 1 ] ) > 48 //Se possui mais de 48 caract. ñ colocar o turno, pois vai passar do limite
					cPeriodo := aTurnos[ 1 , 1 ]
					lHint := .T.
				Else
					If !Empty( aTurnos[ 1 , 1 ] )
						cPeriodo := "Manhã - " + aTurnos[ 1 , 1 ]
					Else
						cPeriodo := ""
					EndIf
				EndIf

			ElseIf n1 == 13

				If Len( aTurnos[ 1 , 2 ] ) > 48 //Se possui mais de 48 caract. ñ colocar o turno, pois vai passar do limite
					cPeriodo 	:= aTurnos[ 1 , 2 ]
					lHint := .T.
				Else
					If !Empty( aTurnos[ 1 , 2 ] )
						cPeriodo 	:= "Tarde - " + aTurnos[ 1 , 2 ]
					Else
						cPeriodo := ""
					EndIf
				EndIf

			EndIf
			::oTPanel:addShape( "id="+::SumId()+";type=1;"+;
						"left="+cValToChar(2)+";top="+cValToChar(nHeiHr)+";width="+cValToChar(::nWidPL)+";height="+cValToChar(::nHeiCpo)+";"+;
						"gradient=1,0,0,0,30,0,#DDEAFB,0.5,#C9DAF4,1.0,#D8E4F4;pen-width=" + _cPenWid + ";pen-color=" + _cPenCol + ";can-move=" + _cCanMov + ";" + "can-mark=0;is-container=1;" )

			cTextIdShp := ::SumId()
			::oTPanel:addShape( "id="+cTextIdShp+";type=7;"+;
									"left="+cValToChar(2)+";top="+cValToChar(nHeiHr+6)+";width="+cValToChar(::nWidPL)+";height="+cValToChar(::nHeiCpo)+";"+;
									"font=arial,07,0,0,1;text="+cPeriodo+";pen-color=#434657;pen-width=2;"+;
									"gradient=1,0,0,0,0,0,#434657;" )
			If lHint
				::oTPanel:SetToolTip( Val(cTextIdShp), cPeriodo )
			EndIf
			nHeiHr := nHeiHr+::nHeiCpo
		EndIf

		cPeriodo := aHora[n1]
		::oTPanel:addShape( "id="+::SumId()+";type=1;"+;
								"left="+cValToChar(2)+";top="+cValToChar(nHeiHr)+";width="+cValToChar(::nWidPL)+";height="+cValToChar(::nHeiCpo)+";"+;
								"gradient=1,0,0,0,0,1.0,#FFFFFF;pen-width=" + _cPenWid + ";pen-color=" + _cPenCol + ";can-move=" + _cCanMov + ";" + "can-mark=0;is-container=1;" )

		::oTPanel:addShape( "id="+::SumId()+";type=7;"+;
								"left="+cValToChar(100)+";top="+cValToChar(nHeiHr+6)+";width="+cValToChar(40)+";height="+cValToChar(::nHeiCpo)+";"+;
								"font=arial,07,0,0,1;text="+cPeriodo+";pen-color=#434657;pen-width=2;"+;
								"gradient=0,0,0,0,0,0,#DCDCDC;" )

		nHeiHr += ::nHeiCpo
	Next n1

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} HalfBox
Adiciona uma caixa (Shape)

@type method

@source TNGAG.prw

@param

@sample HalfBox()

@return Nulo, Sempre nulo.

@author Bruno Lobo
@since 10/09/2014
/*/
//---------------------------------------------------------------------
Method HalfBox() Class TNGAG

	Local nWidF
	Local nLeft
	Local nRegua, nHoriz, nVert, nAgMed
	Local nQtdShp		:= ::nTotShp
	Local nWidAg		:= ( ::nWidth - ( ::nWidPl + 2 ) ) / nQtdShp
	Local cHora
	Local oBtnMed1, oBtnMed2

	//----------------------------
	//	Agenda
	//----------------------------
	nLeftHr := nLeft := ::nWidPL + 2
	For nAgMed := 1 To 2
		nTopPer := If( nAgMed == 2, ( ::nHeiCpo * 13 ) + ::nTopPl , ::nTopPl )
		nTop	 := If( nAgMed == 2, ( ::nHeiCpo * 14 ) + ::nTopPl , ::nHeiCpo + ::nTopPl )

		::oTPanel:addShape( "id="+::SumId()+";type=1;"+;
								"left="+cValToChar(nLeft)+";top="+cValToChar(nTopPer)+";width="+cValToChar(::nWidth)+";height="+cValToChar(::nHeiCpo)+";"+;
								"gradient=1,0,0,0,30,0,#DDEAFB,0.5,#C9DAF4,1.0,#D8E4F4;pen-width=" + _cPenWid + ";pen-color=" + _cPenCol + ";can-move=" + _cCanMov + ";" + "can-mark=0;is-container=1;" )

		For nVert := 1 To 12
			For nHoriz := 1 To nQtdShp

				cIdAge := ::SumId()

				//Monta a Hora a ser gravada
				If nAgMed == 2
					cHora := StrZero( nVert + 11 , 2 ) + ":" + StrZero( ( nHoriz - 1 ) * ::nShpMin , 2 )
				Else
					cHora := StrZero( nVert - 1 , 2 ) + ":" + StrZero( ( nHoriz - 1 ) * ::nShpMin , 2 )
				EndIf

				::oTPanel:addShape( "id="+cIdAge+";type=1;"+;
										"left="+cValToChar(nLeftHr)+";top="+cValToChar(nTop)+";width="+cValToChar(nWidAg)+";height="+cValToChar(::nHeiCpo)+";"+;
										"gradient=" + _cGradient + ";gradient-hover=" + _cHover + ";pen-width=" + _cPenWid + ";pen-color=" + _cPenCol + ";can-move=" + _cCanMov + ";can-mark=" + _cCanMar + ";is-container=" + _cContei + ";" )

				RecLock( ::cAliasShp, .T. )
					(::cAliasShp)->(ID)		:= cIdAge
					(::cAliasShp)->(TYPE)	:= "1"
					(::cAliasShp)->(PLEFT)	:= cValToChar(nLeftHr)
					(::cAliasShp)->(POSTOP)	:= cValToChar(nTop)
					(::cAliasShp)->(WIDTH)	:= cValToChar(nWidAg)
					(::cAliasShp)->(HEITH)	:= cValToChar(::nHeiCpo)
					(::cAliasShp)->(GRAD)	:= _cGradient
					(::cAliasShp)->(HOVER)	:= _cHover
					(::cAliasShp)->(PENWID)	:= _cPenWid
					(::cAliasShp)->(PENCLR)	:= _cPenCol
					(::cAliasShp)->(FONT)	:= "arial,10,0,0,3"
					(::cAliasShp)->(CANMOV)	:= _cCanMov
					(::cAliasShp)->(CANMRK)	:= _cCanMar
					(::cAliasShp)->(ISCONT)	:= _cContei
					(::cAliasShp)->(HORA)	:= cHora
					(::cAliasShp)->(HORAREL):= cHora
				(::cAliasShp)->(MsUnLock())

				nLeftHr := nLeftHr + nWidAg

			Next nHoriz
			nLeftHr := nLeft
			nTop := nTop+::nHeiCpo
		Next nVert
	Next nAgMed

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} ChangeShape
Deleta o Shape selecionado e recria com as informações atualizadas.

@type method

@source TNGAG.prw

@param nId			, Numerico, Último ID utilizado
@param cType		, Caracter
@param cLeft		, Caracter, Distancia do shape ate a esquerda
@param cTop			, Caracter, Distancia do shape ate o topo
@param cWidth		, Caracter, Largura do shape
@param cHeigth		, Caracter, Altura do shape
@param cFont		, Caracter, Fonte do shape
@param cText		, Caracter, Texto do shape
@param cPenClr		, Caracter, Cor do texto
@param cPenWid		, Caracter, Tamanho da caixa do texto
@param cGradiente	, Caracter, Cor de fundo do shape
@param cCanMov		, Caracter,
@param cCanMrk		, Caracter,
@param cContainer	, Caracter
@param nIdOld		, Numerico

@sample ChangeShape( nId , cType, cLeft, cTop, cWidth, cHeigth, cFont, cText, cPenClr, cPenWid, cGradiente, cCanMov, cCanMrk, cContainer , nIdOld )

@return Nulo, Sempre nulo.

@author Bruno Lobo
@since 10/09/2014
/*/
//---------------------------------------------------------------------
Method ChangeShape( nId , cType, cLeft, cTop, cWidth, cHeigth, cFont,;
					cText, cPenClr, cPenWid, cGradiente, cCanMov, cCanMrk,;
					cContainer , nIdOld ) Class TNGAG

	Default nIdOld := 0

	If nIdOld == 0
		::oTPanel:DeleteItem ( nId )
	Else
		::oTPanel:DeleteItem ( nIdOld )
	EndIf

	::oTPanel:addShape( "id="+cValToChar(nId)+";"+;
							"type="+cType+";"+;
							"left="+cLeft+";"+;
							"top="+cTop+";"+;
							"width="+cWidth+";"+;
							"height="+cHeigth+";"+;
							"pen-color="+cPenClr+";"+;
							"pen-width="+cPenWid+";"+;
							"gradient="+cGradiente+";"+;
							If( cType == "7",;
								"font="+cFont+";"+;
								"text="+cText+";",;
								"gradient-hover=" + _cHover + ";" +;
								"can-move="+cCanMov+";"+;
								"can-mark="+cCanMrk+";"+;
								"is-container="+cContainer+";"))

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} TrbShp
Monta trb para gravação das propriedades do shape

@type method

@source TNGAG.prw

@param

@sample TrbShp()

@return Nulo, Sempre nulo.

@author Bruno Lobo
@since 10/09/2014
/*/
//---------------------------------------------------------------------
Method TrbShp() Class TNGAG

	::cAliasShp 	:= GetNextAlias()
	aTrbShp		:= {}
	aIndShp		:= {}

	aAdd( aTrbShp, { "CODMED",	"N", 04,  0 } ) // Codigo do médico
	aAdd( aTrbShp, { "HORA",	"C", 05,  0 } ) // Horário do médico
	aAdd( aTrbShp, { "HORAREL",	"C", 05,  0 } ) // Horário do agendamento
	aAdd( aTrbShp, { "ID",		"C", 04,  0 } ) // ID do Shape
	aAdd( aTrbShp, { "IDPAI",	"C", 04,  0 } ) // ID do Shape Pai
	aAdd( aTrbShp, { "IDREF",	"C", 04,  0 } ) // ID do Shape Referencia
	aAdd( aTrbShp, { "IDOLD",	"C", 04,  0 } ) // ID do Shape
	aAdd( aTrbShp, { "TYPE",	"C", 01,  0 } ) // Tipo do Shape
	aAdd( aTrbShp, { "PLEFT",	"C", 04,  0 } ) // Posição a esquerda
	aAdd( aTrbShp, { "POSTOP",	"C", 04,  0 } ) // Posição ao topo
	aAdd( aTrbShp, { "WIDTH",	"C", 04,  0 } ) // Largura do Shape
	aAdd( aTrbShp, { "HEITH",	"C", 04,  0 } ) // Altura do Shape
	aAdd( aTrbShp, { "GRAD",	"C", 55,  0 } ) // Efeito gradiente
	aAdd( aTrbShp, { "HOVER",	"C", 55,  0 } ) // Efeito gradiente quando selecionado pelo ponteiro do mouse
	aAdd( aTrbShp, { "TOOLTP",	"C", 50,  0 } ) // Tooltip/Hint apresentado quando selecionado pelo ponteiro do mouse
	aAdd( aTrbShp, { "PENWID",	"C", 04,  0 } ) // Largura do traço
	aAdd( aTrbShp, { "PENCLR",	"C", 07,  0 } ) // Cor do traço
	aAdd( aTrbShp, { "CANMOV",	"C", 01,  0 } ) // Permite movimentar o Shape 1 ou não 2
	aAdd( aTrbShp, { "CANMRK",	"C", 01,  0 } ) // Permite movimentar dentro do container de origem
	aAdd( aTrbShp, { "ISCONT",	"C", 01,  0 } ) // Indica se o Shape é container
	aAdd( aTrbShp, { "TEXT",	"C", 50,  0 } ) // Apenas TEXT - Texto a ser apresentado
	aAdd( aTrbShp, { "TXTHINT",	"C", 01,  0 } ) // Indica que o texto sera apresentado como dica (Hint)
	aAdd( aTrbShp, { "FONT",	"C", 10,  0 } ) // Apenas TEXT - Fonte definida para o Shape
	aAdd( aTrbShp, { "LARGE",	"C", 04,  0 } ) // Apenas LINE - Altura da linha
	aAdd( aTrbShp, { "FROMLF",	"C", 04,  0 } ) // Apenas LINE/TRACE - Posição inicial a esquerda
	aAdd( aTrbShp, { "FROMTP",	"C", 04,  0 } ) // Apenas LINE/TRACE - Posição inicial ao topo
	aAdd( aTrbShp, { "TOLF",	"C", 04,  0 } ) // Apenas LINE/TRACE - Posição final a esquerda
	aAdd( aTrbShp, { "TOTP",	"C", 04,  0 } ) // Apenas LINE/TRACE - Posição final ao topo
	aAdd( aTrbShp, { "STANG",	"C", 04,  0 } ) // Apenas ARC - Ângulo Inicial
	aAdd( aTrbShp, { "SWLEN",	"C", 04,  0 } ) // Apenas ARC - Ângulo em graus
	aAdd( aTrbShp, { "POLYG",	"C", 12,  0 } ) // Apenas POLYGON - Indica os pontos para desenhar o poligono
	aAdd( aTrbShp, { "IMGFIL",	"C", 100, 0 } ) // Apenas IMAGE - Caminho fisico para o arquivo

	aAdd( aIndShp, "ID" )
	aAdd( aIndShp, "IDPAI" )
	aAdd( aIndShp, "HORA" )

	::oTempTable := FWTemporaryTable():New( ::cAliasShp , aTrbShp )
		::oTempTable:AddIndex( "ID", {"ID"} )
		::oTempTable:AddIndex( "IDPAI", {"IDPAI"} )
		::oTempTable:AddIndex( "HORA", {"HORA"} )
		::oTempTable:Create()

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} SetGradShp
Retorna as propriedades do shape

@type method

@source TNGAG.prw

@param nId			, Numerico, Último ID utilizado
@param [cGradiente]	, Caracter, Cor de fundo do shape
@param [cLeft]		, Caracter, Distancia do shape ate a esquerda
@param [cWidth]		, Caracter, Largura do shape
@param [cHeith]		, Caracter, Altura do shape
@param [nIdGer]		, Numerico, Novo Id gerado
@param [nTmpId]		, Numerico, Id temporário.

@sample SetGradShp( nId , cGradient , cLeft , cWidth , cHeith , nIdGer , nTmpId )

@return Nulo, Sempre nulo.

@author Bruno Lobo
@since 10/09/2014
/*/
//---------------------------------------------------------------------
Method SetGradShp( nId , cGradient , cLeft , cWidth , cHeith , nIdGer , nTmpId ) Class TNGAG

	Default cGradient 	:= ""
	Default cWidth		:= ""
	Default cLeft		:= ""
	Default cHeith		:= ""
	Default nIdGer		:= 0

	dbSelectArea( ::cAliasShp )
	dbSetOrder( 1 )
	dbSeek( cValToChar( nId ) )

	If Empty( cGradient )
		cGradient := (::cAliasShp)->(GRAD)
	EndIf
	If Empty( cWidth )
		cWidth := (::cAliasShp)->(WIDTH)
	EndIf
	If Empty( cLeft )
		cLeft := (::cAliasShp)->(PLEFT)
	EndIf
	If Empty( cHeith )
		cHeith := (::cAliasShp)->(HEITH)
	EndIf
	If nIdGer == 0
		nIdGer := nId
	EndIf

	//Atualiza o Shape
	RecLock( ::cAliasShp , .F. )
		(::cAliasShp)->(GRAD) := cGradient
		(::cAliasShp)->(WIDTH) := cWidth
		(::cAliasShp)->(PLEFT) := cLeft
		If nIdGer <> nId
			(::cAliasShp)->(ID) := cValToChar( nIdGer )
			(::cAliasShp)->(IDOLD) := cValToChar( nId )
		EndIf
		If nTmpId <> 0
			(::cAliasShp)->(IDREF) := cValToChar( nTmpId )
		EndIf
	( ::cAliasShp )->( MsUnLock() )

	::ChangeShape( nIdGer , (::cAliasShp)->(TYPE), cLeft, (::cAliasShp)->(POSTOP), cWidth, (::cAliasShp)->(HEITH),;
	 				(::cAliasShp)->(FONT), (::cAliasShp)->(TEXT), (::cAliasShp)->(PENCLR), (::cAliasShp)->(PENWID), cGradient,;
	 				(::cAliasShp)->(CANMOV), (::cAliasShp)->(CANMRK), (::cAliasShp)->(ISCONT) , If(nIdGer <> nId, nId , ) )

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} SetDescriShp
Retorna as propriedades do shape

@type method

@source TNGAG.prw

@param nId	, Numerico, Último ID utilizado
@param cText, Caracter, Texto do shape selecionado
@param cHora, Caracter, Horario do shape selecionado

@sample SetDescriShp( nId , cText , cHora )

@return Nulo, Sempre nulo.

@author Bruno Lobo
@since 10/09/2014
/*/
//---------------------------------------------------------------------
Method SetDescriShp( nId , cText , cHora ) Class TNGAG

	Local nLeft, nTop, nWidth, nHeight
	Local cIdTxt := ::SumId()

	dbSelectArea( ::cAliasShp )
	dbSetOrder( 1 )
	dbSeek( cValToChar( nId ) )
	nLeft	:= Val( (::cAliasShp)->(PLEFT) )
	nTop	:= Val( (::cAliasShp)->(POSTOP) ) + 4
	nWidth	:= Len( cText ) * 8 //Val( (::cAliasShp)->(WIDTH) )
	nHeight	:= Val( (::cAliasShp)->(HEITH) )

	::oTPanel:addShape( "id="+cIdTxt+";type=7;"+;
							"left="+cValToChar( nLeft )+";top="+cValToChar( nTop )+";width="+cValToChar( nWidth )+";height="+cValToChar( nHeight )+";"+;
							"font=arial,08,0,0,3;"+"text=" + cText + ";pen-color=#000000;pen-width=2;"+;
							"gradient=1,0,0,0,0,0,#434657;" )

	RecLock( ::cAliasShp, .T. )
		(::cAliasShp)->(ID)		:= cIdTxt
		(::cAliasShp)->(IDPAI)	:= cValToChar( nId )
		(::cAliasShp)->(TYPE)	:= "7"
		(::cAliasShp)->(PLEFT)	:= cValToChar(nLeft)
		(::cAliasShp)->(POSTOP)	:= cValToChar(nTop)
		(::cAliasShp)->(WIDTH)	:= cValToChar(nWidth)
		(::cAliasShp)->(HEITH)	:= cValToChar(nHeight)
		(::cAliasShp)->(GRAD)	:= "1,0,0,0,0,0,#434657"
		(::cAliasShp)->(PENWID)	:= "2"
		(::cAliasShp)->(PENCLR)	:= "#434657"
		(::cAliasShp)->(FONT)	:= "arial,10,0,0,3"
		(::cAliasShp)->(CANMOV)	:= "0"
		(::cAliasShp)->(CANMRK)	:= "0"
		(::cAliasShp)->(ISCONT)	:= "1"
		(::cAliasShp)->(TEXT)	:= cText
		(::cAliasShp)->(HORA)	:= cHora
		(::cAliasShp)->(HORAREL):= cHora
	(::cAliasShp)->(MsUnLock())

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} SumId
Soma os Ids

@type method

@source TNGAG.prw

@param

@sample SumId()

@return Caracter, Valor do Próximo ID

@author Bruno Lobo
@since 10/09/2014
/*/
//---------------------------------------------------------------------
Method SumId() Class TNGAG
Return cValToChar( ::nID++ )
//---------------------------------------------------------------------
/*/{Protheus.doc} GetId
Soma os Ids

@type method

@source TNGAG.prw

@param

@sample GetId()

@return Objeto, Id do shape atual.

@author Bruno Lobo
@since 10/09/2014
/*/
//---------------------------------------------------------------------
Method GetId() Class TNGAG
Return ::oTPanel:ShapeAtu

//---------------------------------------------------------------------
/*/{Protheus.doc} GetIdHora
Retorna o Id do horario selecionado.

@type method

@source TNGAG.prw

@param cHora, Caracter, Horario selecionado

@sample GetIdHora( "12:10" )

@return Caracter, Id do shape atual.

@author Bruno Lobo
@since 10/09/2014
/*/
//---------------------------------------------------------------------
Method GetIdHora( cHora ) Class TNGAG

	Local cId := -1
	//Verifica se o horário é divisor de 5
	//Para buscar a quantidade de horas correta
	//--------------------------------------------------------
	nResto := HTOM( cHora ) % 5
	cHora := MTOH( HTOM( cHora ) - nResto )
	//--------------------------------------------------------

	dbSelectArea( ::cAliasShp )
	dbSetOrder( 3 )
	If dbSeek( cHora )
		cId := Val( ( ::cAliasShp )->( ID ) )
	EndIf

Return cId
//---------------------------------------------------------------------
/*/{Protheus.doc} GetWidth
Retorna a largura do shape.

@type method

@source TNGAG.prw

@param cId, Caracter, Id do shape

@sample GetWidth( "120" )

@return Caracter, Id do shape.

@author Bruno Lobo
@since 10/09/2014
/*/
//---------------------------------------------------------------------
Method GetWidth( cId ) Class TNGAG

	Local cWidth := ""

	dbSelectArea( ::cAliasShp )
	dbSetOrder( 1 )
	If dbSeek( cId )
		cWidth := (::cAliasShp)->(WIDTH)
	EndIf

Return cWidth
//---------------------------------------------------------------------
/*/{Protheus.doc} GetLeft
Indica a posição atual a esquerda do shape.

@type method

@source TNGAG.prw

@param cId, Caracter, Id do shape

@sample GetWidth( "120" )

@return Caracter, Distancia a esquerda.

@author Bruno Lobo
@since 10/09/2014
/*/
//---------------------------------------------------------------------
Method GetLeft( cId ) Class TNGAG

	Local cLeft := ""

	dbSelectArea( ::cAliasShp )
	dbSetOrder( 1 )
	If dbSeek( cId )
		cLeft := (::cAliasShp)->(PLEFT)
	EndIf

Return cLeft
//---------------------------------------------------------------------
/*/{Protheus.doc} GetHeith
Indica a posição atual ao topo do shape.

@type method

@source TNGAG.prw

@param cId, Caracter, Id do shape

@sample GetWidth( "120" )

@return Caracter, Distancia ao topo.

@author Bruno Lobo
@since 10/09/2014
/*/
//---------------------------------------------------------------------
Method GetHeith( cId ) Class TNGAG

	Local cHeith := ""

	dbSelectArea( ::cAliasShp )
	dbSetOrder( 1 )
	If dbSeek( cId )
		cHeith := (::cAliasShp)->(HEITH)
	EndIf

Return cHeith
//---------------------------------------------------------------------
/*/{Protheus.doc} DelBox
Deleta todas as informações do Box e recria

@type method

@source TNGAG.prw

@param

@sample DelBox()

@return Nulo, Sempre nulo.

@author Bruno Lobo
@since 10/09/2014
/*/
//---------------------------------------------------------------------
Method DelBox() Class TNGAG

	Local cID
	Local aAreaTRB

	dbSelectArea( ::cAliasShp )
	dbSetOrder( 1 )
	dbGoTop()
	While ( ::cAliasShp )->( !Eof() )

		aAreaTRB := ( ::cAliasShp )->( GetArea() )
		cID := ( ::cAliasShp )->( ID )

		::SetGradShp( Val( cID ) , _cGradient , , cValToChar( ( ::nWidth - ( ::nWidPl + 2 ) ) / ::nTotShp ) )

		dbSelectArea( ::cAliasShp )
		dbSetOrder( 2 )
		dbSeek( cID )
		While ( ::cAliasShp )->( !Eof() ) .And. (::cAliasShp)->( IDPAI ) == cID

			::oTPanel:DeleteItem( Val( ( ::cAliasShp )->( ID ) ) )

			RecLock( ::cAliasShp , .F. )
			( ::cAliasShp )->( dbDelete() )
			( ::cAliasShp )->( MsUnLock() )

			( ::cAliasShp )->( dbSkip() )
		End
		RestArea( aAreaTRB )

		( ::cAliasShp )->( dbSkip() )

	End

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} GetText
Texto do shape.

@type method

@source TNGAG.prw

@param cId, Caracter, Id do shape

@sample GetText( "200" )

@return Caractere, Texto do shape.

@author Bruno Lobo
@since 10/09/2014
/*/
//---------------------------------------------------------------------
Method GetText( cId ) Class TNGAG

	Local cText := ""

	dbSelectArea( ::cAliasShp )
	dbSetOrder( 2 )
	If dbSeek( cId )
		cText := (::cAliasShp)->(TEXT)
	EndIf

Return cText
//---------------------------------------------------------------------
/*/{Protheus.doc} GetTextRef
Texto do shape que esta como referencia.

@type method

@source TNGAG.prw

@param cId, Caracter, Id do shape

@sample GetText( "200" )

@return Caractere, Texto do shape.

@author Bruno Lobo
@since 10/09/2014
/*/
//---------------------------------------------------------------------
Method GetTextRef( cId ) Class TNGAG

	Local cText := ""
	dbSelectArea( ::cAliasShp )
	dbSetOrder( 2 )
	If dbSeek( cId )
		cText := (::cAliasShp)->(TEXT)
	Else
		dbSelectArea( ::cAliasShp )
		dbSetOrder( 1 )
		If dbSeek( cId ) .And. !Empty( (::cAliasShp)->(IDREF) )
			dbSelectArea( ::cAliasShp )
			dbSetOrder( 2 )
			If dbSeek( (::cAliasShp)->(IDREF) )
				cText := (::cAliasShp)->(TEXT)
			EndIf
		EndIf
		dbSetOrder( 2 )
		dbSeek( cId )
	EndIf

Return cText
//---------------------------------------------------------------------
/*/{Protheus.doc} GetHora
Horario do shape.

@type method

@source TNGAG.prw

@param cId, Caracter, Id do shape

@sample GetHora( "200" )

@return Caractere, Texto do shape.

@author Bruno Lobo
@since 10/09/2014
/*/
//---------------------------------------------------------------------
Method GetHora( cId ) Class TNGAG

	Local cHora := ""

	dbSelectArea( ::cAliasShp )
	dbSetOrder( 1 )
	If dbSeek( cId )
		cHora := (::cAliasShp)->(HORA)
	EndIf

Return cHora
//---------------------------------------------------------------------
/*/{Protheus.doc} GetHoraShp
Horario do shape.

@type method

@source TNGAG.prw

@param cId, Caracter, Id do shape

@sample GetHoraShp( "200" )

@return Caractere, Texto do shape.

@author Bruno Lobo
@since 10/09/2014
/*/
//---------------------------------------------------------------------
Method GetHoraShp( cId ) Class TNGAG

	Local cHora := ""

	dbSelectArea( ::cAliasShp )
	dbSetOrder( 1 )
	If dbSeek( cId )
		cHora := (::cAliasShp)->(HORAREL)
	EndIf

Return cHora
//---------------------------------------------------------------------
/*/{Protheus.doc} GetHoraRef
Horario do shape que esta como referencia.

@type method

@source TNGAG.prw

@param cId, Caracter, Id do shape

@sample GetHoraRef( "200" )

@return Caractere, Texto do shape.

@author Bruno Lobo
@since 10/09/2014
/*/
//---------------------------------------------------------------------
Method GetHoraRef( cId ) Class TNGAG

	Local cHora := ""

	dbSelectArea( ::cAliasShp )
	dbSetOrder( 1 )
	If dbSeek( cId )
		cHora := (::cAliasShp)->(HORA)
		If !Empty( (::cAliasShp)->(IDREF) )
			If dbSeek( (::cAliasShp)->(IDREF) )
				cHora := (::cAliasShp)->(HORA)
			EndIf
			dbSeek( cId )
		EndIf
	EndIf

Return cHora
//---------------------------------------------------------------------
/*/{Protheus.doc} SetToolTipShp
Balao de ajuda, ao posicionar o mouse sobre algum agendamento vai ser
apresentado um balao com alguns detalhes.

@type method

@source TNGAG.prw

@param nId		, Numerico, Id do shape
@param cMensage	, Caracter, Texto que vai ser apresentado.

@sample SetToolTipShp( 20, "Texto" )

@return Nulo, Sempre nulo.

@author Bruno Lobo
@since 10/09/2014
/*/
//---------------------------------------------------------------------
Method SetToolTipShp( nId , cMensage ) Class TNGAG

	::oTPanel:SetToolTip( nId , cMensage )

Return
