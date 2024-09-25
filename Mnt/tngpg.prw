// ######################################################################################
// Projeto: Framework para Planta Gráfica
// Modulo : SIGAMNT - Manutenção de Ativos
// Fonte  : TNGPG - Planta Gráfica
// ---------+-----------------------+--------------------------------------------------------
// Data     | Autor                 | Descrição
// ---------+-----------------------+--------------------------------------------------------
// 09/09/10 | Vitor Emanuel Batista | Correção para Builds superiores a 7.00.100812P-20100901
// ------------------------------------------------------------------------------------------
// 15/11/10 | Vitor Emanuel Batista | Criado metodos CreateBalloon e DestroyBalloon
//          |                       | Implementado Restrição de acesso (MNTA904)
// ------------------------------------------------------------------------------------------
// 11/03/11 | Vitor Emanuel Batista | Não permite mover objeto completamente para fora da tela
//          |                       | Incluído CSS para as classes TButton e TTree
// ------------------------------------------------------------------------------------------
// 22/03/11 | Vitor Emanuel Batista | Implementado parâmetro MV_NGALMUL para tratar a Planta
//          |                       | Grafica de forma Multi-Filial, quando a TAF for exclusiva.
// ------------------------------------------------------------------------------------------
// 06/04/11 | Vitor Emanuel Batista | Corrigido problema que ocorria em servidores Linux, não
//          |                       | sendo apresentadas as imagens na Planta.
// ------------------------------------------------------------------------------------------
// 13/04/11 | Vitor Emanuel Batista | Corrigido problemas com movimentações de shape, SetFocos
//          |                       | na Árvore Lógica, Recortar/Colar e descrição do Bem.
// ------------------------------------------------------------------------------------------
// 03/10/11 | Vitor Emanuel Batista | Correção contínua do código fonte. Melhorado atualização
//          |                       | do processo de inicialização da planta gráfica.
//          |                       | Correção de métodos CreateBalloon e DestroyBallon.
//          |                       | Valida se usuário fez alguma alteração na planta para
//          |                       | perguntar se deseja salvar ao sair.
//          |                       | Correção de redimensionamento da Dialog na versão 11.
//          |                       | Implementado métodos SetImageFocus e ResizeFocus para
//          |                       | redimensionar imagens pelo mouse.
// ------------------------------------------------------------------------------------------
// 18/10/11 | Roger Rodrigues       | Clicks da direita alterados para seguir restrição da
//          |                       | rotina de Restrição A.L.
// ------------------------------------------------------------------------------------------
// 14/12/12 | Vitor Emanuel Batista | Retirado utilização da função MethIsMemberOf, não ocorrendo
//          |                       | erro.log Invalid function type. Please check RPO file:METHISMEMBEROF
// ------------------------------------------------------------------------------------------
// 22/04/13 | Antonio Hardt da Mota | Feito tratamento para as variaveis que contem o diretorio de uma imagem
//          |                       | para adicionar ou retirar "l:" no início do caminho quando for Linux,
//          |                       | alem de ajuste das barras.
//          |                       | Ajustado Também para que o nome da imagem fique em caixa alta na extração
//          |                       | pela função ExportImage para que seja apresentada corretamente na rotina de Painel de Gestão.
// ------------------------------------------------------------------------------------------
// 05/07/13 | Vitor Emanuel Batista | Melhora na performance da abertura da Planta, utilizando controle de imagens já
//          |                       | exportadas para a pasta temporária do Client do usuário.
//          |                       | Implementação de Resize de Shape para imagem .PNG sem perda de transparencia (superior a 7.00.111010P)
// ------------------------------------------------------------------------------------------
// 23/09/13 | Antonio Hardt da Mota | Ajustada função CreateShapeOfTree para retirar o "l:" do diretorio da imagem quando estiver sendo
//          |                       | utilizado ambiente em Linux.
// ------------------------------------------------------------------------------------------
// 30/10/13 | Lucas Guszak			 | A apresentação da consulta especial da arvore lógica foi reestruturada
//          |                       | para somente apresentar os itens cabiveis ao nível selecionado.
//          |                       | Já a consulta de bens passa a apresentar somente os bens que não estão
//          |                       | na árvore lógica e os que estão contidos no mesmo nível da planta gráfica.
// ------------------------------------------------------------------------------------------
// 27/11/13 | Lucas Guszak			 | Alterado parâmetro da função MethIsMemberOf, não ocorrendo
//          |                       | erro.log Invalid function type. Please check RPO file:METHISMEMBEROF
// ------------------------------------------------------------------------------------------
// 04/02/14 | Elynton Fellipe Bazzo | Desenvolvimento de Funcionalidade para importação de bens na Planta Gráfica
// ------------------------------------------------------------------------------------------
// 25/02/14 | André F. Joriatti     | Melhorias de tela conforme Documentação S.S.: 019610
// ------------------------------------------------------------------------------------------
// 02/07/14 | Guilherme Benkendorf  | Implementação do Módulo de Medicina e Segurança do Tra-
//          |                       | balho (SIGAMDT) a Planta Grafica. Dividino funcionali-
//          |                       | dades através da variavel __nModPG (indica o modulo a
//          |                       | ser trabalho 19/35/56).
// ---------------------------------------------------------------------------------------------------------------
// 17/09/14 | Gabriel Werlich		| Implementação da Planta Grafica para o  Módulo de Gestão Ambiental(SIGASGA).
// ---------------------------------------------------------------------------------------------------------------
// 15/01/15 | Bruno Lobo de Souza   | Efetuada a deleção do TRB (_cTrbTree) após o uso.
// ---------------------------------------------------------------------------------------------------------------
// 18/05/15 | Éwerton Cercal        | Alterada condições da query do evento 013, sobre a tabela TPL, na função
//          |                       | ExecuteEvent.
// ---------------------------------------------------------------------------------------------------------------
// 20/06/16 | Tainã Cardoso         | Ajustado a função de recortar e colocar uma imagem na Planta.
// ---------------------------------------------------------------------------------------------------------------
// 30/06/16 | Diego Oliveira        | Readequação da tela de importação de Bens e na inclusão de Bens para P12.
// ---------------------------------------------------------------------------------------------------------------

#INCLUDE "TNGPG.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "DbTree.ch"
/*
MELHORIAS
--------------------------
André F. Joriatti
A lista de melhorias da planta foi unificada no documento "Melhorias_Planta_Gráfica.docx"
que se encontra anexado na S.S.: 019799
*/

//---------------------------------------------------
// Versao minima para a utilizacao da Planta Grafica
//---------------------------------------------------
#DEFINE MIN_BUILD_VERSION "7.00.100601A-20100707"

#DEFINE __aObjBox_TScroll__ 01
#DEFINE __aObjBox_TBitmap__ 01 //Posicao do Bitmap na array aObjBox
#DEFINE __aObjBox_TSay__    02 //Posicao do Say na array aObjBox
#DEFINE __aObjBox_TipImg__  03 //Tipo de Imagem. 1=RPO / 2=Imagem

//---------------------------
// Posicoes da array aAllImg
//---------------------------
#DEFINE __aAllImg_TipImg__  01
#DEFINE __aAllImg_Imagem__  02
#DEFINE __aAllImg_DirImg__  03
#DEFINE __aAllImg_Largura__ 04
#DEFINE __aAllImg_Altura__  05

//--------------------------
// Posicoes da array aShape
//--------------------------
#DEFINE __aShape_PlanSup__  01
#DEFINE __aShape_IdShape__  02
#DEFINE __aShape_IndCod__   03
#DEFINE __aShape_Codigo__   04
#DEFINE __aShape_Descri__   05
#DEFINE __aShape_PosX__     06
#DEFINE __aShape_PosY__     07
#DEFINE __aShape_LargIni__  08
#DEFINE __aShape_Largura__  09
#DEFINE __aShape_Altura__   10
#DEFINE __aShape_AltIni__   11
#DEFINE __aShape_TipoImg__  12
#DEFINE __aShape_Image__    13
#DEFINE __aShape_ImgIni__   14
#DEFINE __aShape_NivSup__   15
#DEFINE __aShape_Cargo__    16
#DEFINE __aShape_Movement__ 17
#DEFINE __aShape_Blocked__  18
#DEFINE __aShape_Planta__   19
#DEFINE __aShape_Alertas__  20
#DEFINE __aShape_Visivel__  21
#DEFINE __aShape_Permit__   22
#DEFINE __aShape_Filial__   23
#DEFINE __aShape_Caract__	24

//-------------------------------
// Tamanho total da array aShape
//-------------------------------
#DEFINE __Len_aShape__ 24

//---------------------------------------------
// Posicoes da sub-array em __aShape_Alertas__
//---------------------------------------------
#DEFINE __aShape_aAlerta_IdShape__  01
#DEFINE __aShape_aAlerta_Evento__   02
#DEFINE __aShape_aAlerta_Funcao__   03
#DEFINE __aShape_aAlerta_Ativo__    04
#DEFINE __aShape_aAlerta_Visible__  05
#DEFINE __aShape_aAlerta_Blinker__  06
#DEFINE __aShape_aAlerta_ClrHex__   07
#DEFINE __aShape_aAlerta_Culpados__ 08

//---------------------------------------------
// Posicoes da array aTableRef
//---------------------------------------------
#DEFINE __aTable_Shape_Imagem__	01
#DEFINE __aTable_Shape_TpImg__ 	02
#DEFINE __aTable_Shape_PosX__ 	03
#DEFINE __aTable_Shape_PosY__ 	04
#DEFINE __aTable_Shape_Ordem__ 	05
#DEFINE __aTable_Shape_MovBlo__	06
#DEFINE __aTable_Shape_CodCon__	07
#DEFINE __aTable_Shape_IndCon__	08
#DEFINE __aTable_Shape_NomNiv__	09
#DEFINE __aTable_Shape_Planta__	10
#DEFINE __aTable_Shape_NivSup__	11
#DEFINE __aTable_Shape_CodNiv__	12
#DEFINE __aTable_Shape_TamX__  	13
#DEFINE __aTable_Shape_TamY__  	14
#DEFINE __aTable_Shape_Caract__	15

//----------------------------
// Posicoes da array aAlertas
//----------------------------
#DEFINE __aAlertas_Habili__  01
#DEFINE __aAlertas_Evento__  02
#DEFINE __aAlertas_Funcao__  03
#DEFINE __aAlertas_ClrHex__  04
#DEFINE __aAlertas_Blinker__ 05
#DEFINE __aAlertas_Tipo__    06

//---------------------------
// Posicoes da array aFilter
//---------------------------
#DEFINE __aFilter_Planta__  01
#DEFINE __aFilter_Familia__ 02
#DEFINE __aFilter_CC__      03
#DEFINE __aFilter_CT__      04
#DEFINE __aFilter_Resp__    05
#DEFINE __aFilter_Eventos__ 06
#DEFINE __aFilter_Func__    07
#DEFINE __aFilter_Tare__    08
#DEFINE __aFilter_Residuo__ 09
#DEFINE __aFilter_Classe__  10
#DEFINE __aFilter_TipGer__ 11

//---------------------------------------
// Posicoes da array aMenuPopUp(Linhas)
//---------------------------------------
#DEFINE __aMenuPopUp_Loc__  01
#DEFINE __aMenuPopUp_Bem__  02
#DEFINE __aMenuPopUp_Res__  03
#DEFINE __aMenuPopUp_Asp__  04
#DEFINE __aMenuPopUp_Pto__  05

//---------------------------------------
// Posicoes da array aMenuPopUp(Colunas)
//---------------------------------------
#DEFINE __aMenuPopUp_Len__  03
#DEFINE __aMenuPopUp_Objeto__  01
#DEFINE __aMenuPopUp_Tipo__  02
#DEFINE __aMenuPopUp_Operacao__  03

//----------------------------------
// Define utilizados pelo FwBalloon
//----------------------------------
#DEFINE FW_BALLOON_INFORMATION	   03
#DEFINE BALLOON_POS_BOTTOM_RIGTH   06
#DEFINE BALLOON_POS_LEFT_TOP       07
#DEFINE BALLOON_POS_LEFT_MIDDLE    08
#DEFINE BALLOON_POS_LEFT_BOTTOM    09
#DEFINE BALLOON_POS_RIGTH_TOP      10

//-----------------------------------------------
// Define utilizados pelo Foco do shape (Edição)
//-----------------------------------------------
#DEFINE FOCUS_SHAPE_DAD 01
#DEFINE FOCUS_TOP_LEFT  02
#DEFINE FOCUS_TOP_RIGHT 03
#DEFINE FOCUS_BOTTOM_LEFT  04
#DEFINE FOCUS_BOTTOM_RIGHT  05

//-----------------------------------------------------------
// Indica o tipo de barra utilizado pelo Sistema Operacional
//-----------------------------------------------------------
#DEFINE __cBARRAS__ If( GetRemoteType() == REMOTE_QT_LINUX ,"/","\")

//------------------------------------------------------
// Caminho completo do diretorio temporario, utilizado
// para armazenar as imagens da planta
//------------------------------------------------------
#DEFINE __cDirectory__ Lower(GetTempPath()+"TNGPG") //+cValToChar(ThreadId())+__cBARRAS__

#DEFINE __cHora Substr(Time(),1,5)

//----------------------------------------------------
// Variavel que identifica o tamanho do campo Filial
//----------------------------------------------------
#DEFINE __nSizeFil If(FindFunction("FWSizeFilial"),FwSizeFilial(),Len(SM0->M0_CODFIL))

//-----------------------------------
// Campo utilizado no Evento de S.S.
//-----------------------------------
#DEFINE __TQ3PESQ   NGCADICBASE("TQ3_PESQST","A","TQ3",.F.)

//-----------------------------------------------------
//  Variável para verificação se o binário suporta o método SetReleaseButton
//-----------------------------------------------------
#DEFINE lReleaseB If( GetBuild() >= "7.00.111010P-20111223", .T., .F. )

//------------------------------
// Totais de opcoes no ComboBox
//------------------------------
Static __TotalOptionBox__  := 0

//----------------------------------------
// Valores utilizados ao movimentar shape
//----------------------------------------
Static __nMovX := 0
Static __nMovY := 0

//--------------------------------
// Valor do ultimo Zoom da planta
//--------------------------------
Static __nZoom := 100

//-----------------------------------------------------
// Id do Shape Auxiliar para o funcionamento do clique
//-----------------------------------------------------
Static __nIdAux := 0

//-----------------------------------------------------
// TRB da Tree apresentada no lado esquerdo da rotina
//-----------------------------------------------------
Static __cTrbTree
Static __cArqTree

//-----------------------------------------------------
// Declara a TRB que sera utlilizada na consulta especial
//-----------------------------------------------------
Static __cTrbNivF3 := GetNextAlias()

//-----------------------------------------------------
// Array utilizado na importação de bens via C.C.
//-----------------------------------------------------
Static aBensPG 	:= {}

Static __nModPG := IIf( nModulo == 95, 19, nModulo )

//------------------------------
// Força a publicação do fonte
//------------------------------
Function ____TNGPG()
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TNGPG
Classe grafica integrada com a Arvore Logica, para desenvolvimento de
Plantas Graficas em Modo de Edicao e fazer o controle dela em Modo de
Visualizacao

@author Vitor Emanuel Batista
@since 04/03/2010
@build 7.00.100601A-20100707
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Class TNGPG From TPanel

	DATA lEditMode  	AS BOOLEAN	INIT .T.		//Indica se esta em modo de edicao
	DATA nId        	AS INTEGER	INIT 0 			//Indica o ultimo Id inserido no tPaintPanel
	DATA oTPanel    	AS OBJECT 					//Objeto principal TPaintPanel
	DATA oPnlMenu   	AS OBJECT 					//Menu - Panel pai lateral esquerdo
	DATA oCBoxMenu  	AS OBJECT 					//Combobox
	DATA oImgAtu    	AS OBJECT 					//TBitmap em foco
	DATA oMenuBem   	AS OBJECT 					//Clique da direita do Shape para Bens
	DATA oMenuRis   	AS OBJECT 					//Clique da direita do Shape para Risco
	DATA oMenuFun   	AS OBJECT 					//Clique da direita do Shape para Risco
	DATA oMenuTar   	AS OBJECT 					//Clique da direita do Shape para Risco
	DATA oMenuRes   	AS OBJECT 					//Clique da direita do Shape para Resíduos
	DATA oMenuAsp	  	AS OBJECT 					//Clique da direita do Shape para Aspectos
	DATA oMenuPto  		AS OBJECT 					//Clique da direita do Shape para Aspectos
	DATA oMenuIlu   	AS OBJECT 					//Clique da direita do Shape para Ilustracoes
	DATA oMenuPg    	AS OBJECT 					//Clique da direita sobre a Planta Grafica / Linhas
	DATA oMenuShape 	AS OBJECT 					//Clique da direita do Tree em uma Localizacao
	DATA oMenuLoc   	AS OBJECT 					//Clique da direita do Tree em uma Localizacao
	DATA oGetZoom   	AS OBJECT 					//Get contendo valor do zoom em porcentagem
	DATA oWnd      		AS OBJECT 					//Janela Pai
	DATA oSplitter  	AS OBJECT 					//Divisao das imagens com Tree
	DATA oTree    		AS OBJECT 					//Objeto Tree
	DATA oZoom  		AS OBJECT 					//Objeto Slider para Zoom
	DATA oBlackPnl  	AS OBJECT 					//Panel preto com transparencia
	DATA oRep      		AS OBJECT 					//Objeto do tipo Repository
	DATA oTimer     	AS OBJECT 					//Timer para a atualizacao automatica
	DATA aLinhas    	AS ARRAY 	INIT {} 		//Array contendo Id dos shapes de linha
	DATA aImgBox    	AS ARRAY 	INIT {} 		//Array contendo todas as imagens do Box
	DATA aAllImg    	AS ARRAY 	INIT {} 		//Array contendo todas as imagens criadas pela Planta Grafica
	DATA aObjBox    	AS ARRAY 	INIT {} 		//Array contendo todas as opcoes do combobox de Imagens
	DATA cImgAtu    	AS STRING 					//Indica o nome da imagem atual em foco
	DATA cTipImg    	AS STRING 					//Indica o tipo de imagem atual em foco
	DATA cTrbTree   	AS STRING 					//Indica a tabela temporaria do Tree
	DATA cCargoAtu  	AS STRING 					//Indica o item do Tree em foco
	DATA cPlantaAtu 	AS STRING 					//Indica o planta do Tree em foco
	DATA cCodNiv    	AS STRING 					//Indica o ultimo codigo inserido no Tree
	DATA cFilAnt    	AS STRING 					//Indica a Filial que foi aberta a Planta Grafica
	DATA aShape     	AS ARRAY 					//Array contendo todos os shapes em tela
	DATA nCutShape  	AS INTEGER 					//Array utilizado no Copiar e Colar
	DATA lIsMoving  	AS BOOLEAN					//Indica se imagem esta em movimento
	DATA cMovement  	AS STRING 	INIT "000" 		//Indica a quantidade de movimentos de shapes
	DATA nZoom  		AS INTEGER	INIT 100 		//Valor do Get oGetZoom
	DATA aZoom      	AS ARRAY 	INIT {} 		//Array contendo valores de zoom de cada planta
	DATA aFilter    	AS ARRAY 	INIT {} 		//Array contedo filtros de cada planta
	DATA aFilial    	AS ARRAY 	INIT {} 		//Array contendo as filiais utilizadas pela Planta
	DATA oBalloon   	AS OBJECT 					//Objeto da classe FWBalloon mostrado na visualizacao de um Bem ou Localizacao
	DATA nMaxCodNiv 	AS INTEGER 	INIT 0 			//Quantia de itens na TAF na abertura da planta gráfica
	DATA lModified  	AS BOOLEAN 	INIT .T. 		//Identifica se houve alterações para mostrar mensagem de salvar planta
	DATA aImageFocus    AS ARRAY 	INIT {} 		//Array contendo informações sobre o shape em foco
	DATA aMenuPopUp 	AS ARRAY 	INIT {} 		//Array contendo os itens de menu do click da direita
	DATA nPYShapeAtu 	AS INTEGER 	INIT 0
	DATA nPXShapeAtu 	AS INTEGER 	INIT 0
	DATA oPYShapeAtu 	AS OBJECT
	DATA oPXShapeAtu 	AS OBJECT

	Method New(oWnd,lEditMode) CONSTRUCTOR
	Method Activate()
	Method LoadPg()

	Method EraseImage()
	Method ClearCache()

	Method Zoom(nZoom)
	Method SavePg()
	Method InsertLibrary()

	Method SetLinhas()
	Method SetId()
	Method SetMovement()
	Method SetBlackPnl(lVisible)

	Method MenuItens()
	Method GetArrInfoBox()
	Method GetArrImgBox()

	Method GetShapeAtu()
	Method GetPosShape(nShapeAtu)
	Method GetDirectory()

	Method HideMenu()
	Method HideImagesBox(nLessOption)

	Method LeftClicked(nPosX,nPosY)
	Method RightClicked(nPosX,nPosY)
	Method ActiveClickTree(o,x,y)

	Method SetCanMoveAll(lMove,lPlanta)
	Method InsertImage(nPosX,nPosY,cImgAtu)
	Method SelectImage(oBmp)
	Method CreateImagesBox()
	Method CreateMenu()
	Method CreateBarMenu()

	Method SetImageFocus(lFocus)
	Method ResizeFocus(nShapeAtu)

	Method PasteShape(nPosX,nPosY)
	Method CutShape(nShapeAtu)
	Method DeleteShape(nShapeAtu,lShape)

	Method ResizeAlert(nPosShape)
	Method ResizeImage(nShapeAtu,nLargura,nAltura)
	Method ExportImage(cTipoImg,cImage,cDirectory)

	//Method SendBack(nShapeAtu)
	//Method BlockMove(nShapeAtu)
	Method PropertyShape(nShapeAtu)

	Method MaxCodNiv()
	Method UltCodNiv()
	Method GetNivSup(nPosX,nPosY,nLessId)
	Method CreateTree()
	Method CreateShapeOfTree()
	Method InsertLocTree()
	Method AlterLocTree()
	Method InsertTree(nShapeAtu)
	Method SetTpTree(cPgTipo)
	Method DeleteItem()
	Method SetOptionTree(cCargo)
	Method ModifyLocation(nPosShape)
	Method DoubleClickTree(cCargo)

	Method OperRisTree(nOpcRis)
	Method OperFunTar(nOpc, cOpe)
	Method SgaAspOpr(nOpc)
	Method SgaResOpr(nOpc)

	Method ConfigFilter()
	Method ConfigAlerts()
	Method ImportBens()
	Method ConfigTimer()
	Method Legend()

	Method GetArrAlerts(cCargo)
	Method Update()
	Method UpdateAlert(nPosShape)
	Method GetArrEvents()
	Method ExecuteEvent(cEvent)

	Method CreateBalloon(nPosShape)
	Method DestroyBalloon()
	Method InsertBlinker(nId)

EndClass

//---------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da classe TNGPG

@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Method New(oWnd,lEditMode) Class tNGPG
	:New(0,0,,oWnd,,,,,CLR_WHITE,0,0,.F.,.F.)

	Default lEditMode := .T.
	//Default oWnd := GetWndDefault()

	::oWnd      := oWnd
	::lEditMode := lEditMode
	::nId       := 0
	::cImgAtu   := ""
	::aLinhas   := {}
	::aShape    := {}
	::aImgBox   := {}
	::aAllImg   := {}
	::aZoom     := {}
	::aFilter   := {}
	::lIsMoving := .F.
	::cCargoAtu := "001LOC"
	::cCodNiv   := "001"
	::cMovement := "001"
	::nMaxCodNiv:= 0
	::nZoom     := 100
	::lModified := .F.
	::aImageFocus := {}
	::aMenuPopUp:= Array(5,0)
	If !Empty(oWnd)
		::Align   := CONTROL_ALIGN_ALLCLIENT
		::nHeight := 454*2
		::nWidth  := 629*2
	EndIf

	//--------------------------------------
	// Abre empresa - UTILIZADO PARA TESTES
	//--------------------------------------
	AbreEmpresa(::Owner())

	//--------------------------------------------
	// Retorna as filiais para montagem da planta
	//--------------------------------------------
	::aFilial := RetFiliais(::lEditMode)

	//----------------------------------------------------
	// Objeto utilizado para exportação de imagens do
	// repositório de imagens para um diretório qualquer
	//----------------------------------------------------
	::oRep := TBmpRep():New(-10000000,-10000000,1,1,,,Self)
		::oRep:Hide()

	//--------------------------------------------
	// Esconde Planta Grafica que esta em criacao
	//--------------------------------------------
	::Hide() //NAO RETIRAR!

Return Self

//---------------------------------------------------------------------
/*/{Protheus.doc} Activate
Método para ativar a planta gráfica

@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Method Activate() Class TNGPG
	Local oDlg, oSay, oMeter, oPnlBottom, oScrollBox
	Local nZoom := 100
	Local bInit := {|| ::LoadPg()}
	Local oPnlOpcoes    := Nil
	Local oFontSayCoord := Nil
	Private _oPgSay, _oPgMeter

	::cCodNiv   := ::UltCodNiv()
	::nMaxCodNiv:= ::MaxCodNiv()
	::cMovement := ::cCodNiv

	If !::lEditMode
		//Timer para a atualização automática
		::oTimer := TTimer():New(30*60000, {|| (::SetBlackPnl(.T.),MsgRun( STR0001 , STR0002 , { ||Self:Update()}),::SetBlackPnl(.F.))}, ::oWnd ) //"Atualizando informações..."###"Aguarde"
		   ::oTimer:lActive := .F.
		   ::oTimer:lLiveAny:= .F.
	EndIf

	oScrollBox := TScrollBox():New(Self,0,0,0,0,.T.,.T.,.T.) //TScrollArea():New(oPnlCenter,01,01,100,100,.F.,.F.,.F.) //
		oScrollBox:Align := CONTROL_ALIGN_ALLCLIENT
		oScrollBox:nClrPane := CLR_WHITE
		::oTPanel := tPaintPanel():New(0,0,::nWidth/2,::nHeight/2,oScrollBox)
			::oTPanel:SetBlinker(500)

			//Dispara no release do botão do mouse, mesmo estando este dentro no mesmo Container de origem do click do mouse.
			If lReleaseB
				::oTPanel:SetReleaseButton(.T.)
			EndIf

			//Cria shape Auxiliar para o funcionamento do clique
			__nIdAux := ::SetId()
			::oTPanel:addShape("id="+cValToChar(__nIdAux)+";type=6;gradient=1,0,0,0,0,0.0,#000000;pen-width=0;"+;
									"pen-color=#000000;can-move=0;can-mark=0;large=0;from-left=0;from-top=0;to-left=0;to-top=0;")
			::oTPanel:SetVisible(__nIdAux,.F.)

			//Cria Container
			::oTPanel:addShape("id="+cValToChar(::SetId())+";type=1;left=0;top=0;width="+cValToChar(::oTPanel:nWidth)+";height="+cValToChar(::oTPanel:nHeight)+";"+;
			                "gradient=1,0,0,0,0,0.0,#FFFFFF;pen-width=1;pen-color=#ffffff;can-move=0;can-mark=0;is-container=" + If(lReleaseB,'0','1') + ";")

			::oTPanel:blClicked := {|nPosX,nPosY| ::LeftClicked(nPosX,nPosY)}
			::oTPanel:bRClicked := {|nPosX,nPosY| ::RightClicked(nPosX,nPosY)}

	//Objetos de controle de Zoom
	If !::lEditMode
		If GetBuild() >= "7.00.100812P-20100901" //Build com correcao da classe tSlider
			oPnlBottom := TPanel():New(0,0,,Self,,,,,RGB(238,237,221),0,10,.F.,.F.)
				oPnlBottom:Align := CONTROL_ALIGN_BOTTOM

			If __nModPG <> 56

				oZoomBtn := TBtnBmp2():New( 0,0,24,24,"NG_PG_ZOOM_MAIS",,,,{|| If(__nZoom+10 <= 200,::oZoom:SetValue(__nZoom+10),Nil) },oPnlBottom,,,.T. )
				oZoomBtn:Align := CONTROL_ALIGN_RIGHT
				oZoomBtn:cToolTip := "Zoom +"
				::oZoom := TSlider():New( 01,01,oPnlBottom,{|nZoom| If(!Empty(::cPlantaAtu) .And. __nZoom != nZoom,(oPnlBottom:SetFocus(),Self:Zoom(nZoom)),Nil)},85,5,"Zoom")
					::oZoom:Align := CONTROL_ALIGN_RIGHT
					::oZoom:SetInterval(10)
					::oZoom:SetRange(10,200)
					::oZoom:SetValue(100)
					::oZoom:lOutGet := .t.

				oZoomBtn := TBtnBmp2():New( 0,0,24,24,"NG_PG_ZOOM_MENOS",,,,{|| If(__nZoom-10 >- 10,::oZoom:SetValue(__nZoom-10),Nil)},oPnlBottom,,,.T. )
					oZoomBtn:Align := CONTROL_ALIGN_RIGHT
					oZoomBtn:cToolTip := "Zoom -"

				@ 01,01 MsGet ::oGetZoom Var nZoom Of oPnlBottom Picture "999%" Valid ::oZoom:SetValue(nZoom) When (nZoom := Self:nZoom) Pixel
					::oGetZoom:Align := CONTROL_ALIGN_RIGHT
					::oGetZoom:SetFocus()
			EndIf

		Else
			If __nModPG <> 56
			oPnlBottom := TPanel():New(0,0,,Self,,,,,RGB(238,237,221),0,12,.F.,.F.)
				oPnlBottom:Align := CONTROL_ALIGN_BOTTOM
				oZoomBtn := TBtnBmp2():New( 0,0,24,24,"NG_PG_ZOOM_MAIS",,,,{|| ::Zoom(::nZoom+10)},oPnlBottom,,,.T. )
				oZoomBtn:Align := CONTROL_ALIGN_RIGHT
				oZoomBtn:cToolTip := "Zoom +"
				::oZoom := TSlider():New( 01,01,oPnlBottom,{|nZoom| If(!Empty(::cPlantaAtu),(oPnlBottom:SetFocus(),Self:Zoom(nZoom)),Nil)},85,5,"Zoom")
					::oZoom:Disable() //Desabilitado ate que o bChange funcione
					::oZoom:Align := CONTROL_ALIGN_RIGHT
					::oZoom:SetInterval(10)
					::oZoom:SetRange(10,200)
					::oZoom:SetValue(100)
					::oZoom:lOutGet := .t.

				oZoomBtn := TBtnBmp2():New( 0,0,24,24,"NG_PG_ZOOM_MENOS",,,,{|| ::Zoom(::nZoom-10)},oPnlBottom,,,.T. )
					oZoomBtn:Align := CONTROL_ALIGN_RIGHT
					oZoomBtn:cToolTip := "Zoom -"

				@ 01,01 MsGet ::oGetZoom Var nZoom Of oPnlBottom Picture "999%" Valid Self:Zoom(nZoom) When (nZoom := Self:nZoom) Pixel
					::oGetZoom:Align := CONTROL_ALIGN_RIGHT
					::oGetZoom:SetFocus()
			EndIf
		EndIf
	EndIf

	// Rodapé da tela para indicar coordenadas de
	If ::lEditMode
		oPnlOpcoes := tPanel():New( 0,100,,Self,,,,,,,12,, )
	Else
		oPnlOpcoes := oPnlBottom
	EndIf

		oPnlOpcoes:Align    := CONTROL_ALIGN_BOTTOM
		oPnlOpcoes:nClrPane := CLR_WHITE

		oFontSayCoord := tFont():New( "Verdana",,-11,.T. )

			// Campos para indicar posição X e Y do Shape selecionado
			@ 004,133 Say "Posição X: " Of oPnlOpcoes Pixel Font oFontSayCoord // "Posição X: "
			@ 002,165 MSGet ::oPXShapeAtu Var ::nPXShapeAtu Picture "@E 9,999,999.99" Size 040,006 Of ;
				oPnlOpcoes Pixel HasButton When .F.

			@ 004,215 Say "Posição Y: " Of oPnlOpcoes Pixel Font oFontSayCoord // "Posição X: "
			@ 002,245 MSGet ::oPYShapeAtu Var ::nPYShapeAtu Picture "@E 9,999,999.99" Size 040,006 Of ;
				oPnlOpcoes Pixel HasButton When .F.
	//-------------------------------------------------
	// Cria Splash para carregar toda a Planta Gráfica
	//-------------------------------------------------
	Define Dialog oDlg From 5,5 To 415,690 COLOR CLR_BLACK,CLR_WHITE STYLE nOr(DS_SYSMODAL,WS_MAXIMIZEBOX,WS_POPUP) Pixel
		oBmp := TBitmap():New(0,0,411,647,,"NG_PG_INITPG",.T.,,,,.F.,.F.,,,.F.,,.F.,,.F.)
			oBmp:lTransparent := .F.
			oBmp:Align := CONTROL_ALIGN_ALLCLIENT
		nMeter := 0

		_nTotalMeter := If(::lEditMode,4,3) + ::nMaxCodNiv
		_nIncMeter   := 0

		_oPgSay   := TSay():New(180,130,{|| STR0351},oBmp,,,,,,.T.,CLR_RED,CLR_WHITE,200,20) //'Iniciando programa...'
		_oPgMeter := TMeter():New(194,128,{|u|if(Pcount()>0,nMeter:=u,nMeter)},100,oBmp,100,8,,.T.)
			_oPgMeter:SetTotal(_nTotalMeter)
			_oPgMeter:Set(++_nIncMeter)

		TSay():New(198,310,{||},oBmp,,TFont():New(,,12),,,,.T.,CLR_WHITE,CLR_WHITE,200,20)
	ACTIVATE DIALOG oDlg ON INIT (Eval(bInit),oDlg:End()) CENTERED

	//--------------------------------------
	// Exibe Planta Gráfica que está pronta
	//--------------------------------------
	::Show() //NAO RETIRAR!

	//Tira o foco do shape em movimento
	::oTPanel:SetPosition(__nIdAux,0,0)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} LoadPg
Método que carrega toda a planta e seus componentes

@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Method LoadPg() Class TNGPG

	Local bDelCTRL_D := Nil
	//----------------------------------
	// Valida se Build esta atualizada
	//----------------------------------
	If GetBuild() < MIN_BUILD_VERSION
		MsgStop(	STR0003 + Chr(13)+Chr(10) + ; //"Foi detectada uma incompatibilidade na versão da Build do Protheus."
					STR0004 + Chr(13)+Chr(10) + ; //"Favor atualizar Protheus Server e Protheus Remote."
					STR0005 + MIN_BUILD_VERSION) // #  //"Versão mínima necessária:"
		Final(STR0006) //"Incompatibilidade com a versão da Build."
	EndIf

	If ::lEditMode
		::SetLinhas() //Cria Linhas em Modo de Edicao
	EndIf

	//----------------------------------
	// Carrega com a Filial corrente
	//----------------------------------
	::cFilAnt   := cFilAnt

	//-----------------------------------------------------------
	// Insere Bibliotecas Graficas Padrões nas tabelas TU0 e TU1
	//-----------------------------------------------------------
	::InsertLibrary()

	::CreateBarMenu() //Cria Menu Superior
	::CreateMenu() //Cria Menus PopUp
	::MenuItens() //Cria Menu Lateral contendo a Arvore logica e as Bibliotecas Graficas
	::CreateTree() //Cria Arvore Logica

	//----------------------------------
	// Indica qual a Planta posicionada
	//----------------------------------
	::cPlantaAtu:= "001"

	If ::lEditMode
		SETKEY(K_CTRL_S,{|| (::SetBlackPnl(.T.),Processa( { || Self:SavePg() },STR0007 , STR0002),::SetBlackPnl(.F.))}) //"Salvando informações..."##"Aguarde"
		SETKEY(K_CTRL_E,{|| ::ConfigAlerts()})
		//SETKEY(K_CTRL_Z,{|| alert("Em construçao... ")})
		bDelCTRL_D := { || (::SetBlackPnl(.T.),If(MsgYesNo(STR0022+AllTrim(::oTree:GetPrompt())),::DeleteItem(),Nil),::SetBlackPnl(.F.)) }
		SETKEY(K_CTRL_D,bDelCTRL_D)
	Else
		::SetCanMoveAll(.F.,.F.)
		::Update()

		SETKEY(K_CTRL_F,{|| ::ConfigFilter()})
		SETKEY(K_CTRL_A,{|| ::ConfigTimer()})
		SETKEY(VK_F5,{|| (::SetBlackPnl(.T.),MsgRun( STR0001 , STR0002 , { ||Self:Update()}),::SetBlackPnl(.F.))})//"Atualizando informações..."##"Aguarde"
		//SETKEY(K_CTRL_L,{|| ::LegendAlert()})
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} CreateBarMenu
Método que cria menu superior completo

@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Method CreateBarMenu() Class TNGPG

	Local oTMenuBar
	Local oArquivo, oFerramentas, oVisualizar, oAjuda

	//-------------------------
	// Monta um Menu Suspenso
	//-------------------------
	oTMenuBar := TMenuBar():New(Self)
		oTMenuBar:SetCss("QMenuBar{background-color:#3b5998;color:#ffffff;}")
		oTMenuBar:Align     := CONTROL_ALIGN_TOP
		oTMenuBar:nClrPane  := RGB(59,89,152)
		oTMenuBar:bRClicked := {||}

		oArquivo     := TMenu():New(0,0,0,0,.T.,,Self)
		oFerramentas := TMenu():New(0,0,0,0,.T.,,Self)
		oVisualizar  := TMenu():New(0,0,0,0,.T.,,Self)
		oAjuda       := TMenu():New(0,0,0,0,.T.,,Self)

		oTMenuBar:AddItem( STR0352 , oArquivo, .T.) //'&Arquivo'
		oTMenuBar:AddItem( STR0353 , oVisualizar, .T.) //'&Visualizar'
		oTMenuBar:AddItem( STR0354 , oFerramentas, .T.) //'&Ferramentas'
		oTMenuBar:AddItem( STR0355 , oAjuda, .T.) //'Aj&uda'

	//----------------------
	// Cria Itens do Menu
	//----------------------
	If ::lEditMode
		oArquivo:Add(TMenuItem():New(Self,STR0356,,,,{|| Processa( { || ::SavePg() },STR0007 , STR0002)},,'SALVAR',,,,,,,.T.))//'&Salvar...      Ctrl+S'##"Salvando informações..."##"Aguarde"
	EndIf
	oArquivo:Add(TMenuItem():New(Self,STR0357,,,,{|| (If(::lEditMode .And. ::lModified .And. MsgYesNo(STR0358),Processa({ || ::SavePg(.T.) }, STR0007 , STR0002),), /*NGDELETRB(__cTrbTree, __cArqTree )*/__cArqTree:Delete(),::Owner():End())},,'FINAL',,,,,,,.T.)) //'Sai&r'#"Deseja salvar as alterações realizadas?"#"Salvando informações..."#"Aguarde"

	If ::lEditMode

		oFerramentas:Add(TMenuItem():New(Self,STR0359,,,,{|| ::ConfigAlerts()},,' ',,,,,,,.T.)) //'&Eventos      Ctrl+E'

		If __nModPG == 19
			oFerramentas:Add(TMenuItem():New(Self,STR0410,,,,{|| ::ImportBens()},,' ',,,,,,,.T.))//"Importar Bens"
		EndIf
	Else
		oFerramentas:Add(TMenuItem():New(Self,STR0360,,,,{|| ::ConfigFilter()},,"FILTRO",,,,,,,.T.))//'&Filtros               Ctrl+F'
		oFerramentas:Add(TMenuItem():New(Self,STR0361,,,,{|| ::ConfigTimer()},,'CLOCK01',,,,,,,.T.))//'&Atualização      Ctrl+A'
	EndIf

	oVisualizar:Add(TMenuItem():New(Self,STR0362 ,,,,{|| ::Legend()},,'ng_ico_legenda',,,,,,,.T.))//'&Legenda'

	oAjuda:Add(TMenuItem():New(Self,STR0399,,,,{|| ::ClearCache()},,'sduerase',,,,,,,.T.)) //'Limpar cache'
	oAjuda:Add(TMenuItem():New(Self,STR0363,,,,{|| HelProg()},,'RPMPERG',,,,,,,.T.))//'&Sobre...        F1'

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuItens
Método que cria menu lateral completo

@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Method MenuItens() CLASS TNGPG
	Local oPnlShow, oSplitter, oPanel
	Local aItens := ::GetArrInfoBox()
	Local cCombo := If(Len(aItens)>0,aItens[1],"")

	//Panel Principal do Menu de Objetos
	::oPnlMenu := TPanel():New(0,0,,Self,,,,,,130,0,.F.,.F.)
		::oPnlMenu:Align := CONTROL_ALIGN_LEFT

		//Botao para esconder a Arvore Logica e a Biblioteca Grafica
		oPnlShow := TButton():New( 002, 002, "<",Self,{|x,y| (oPnlShow:cTitle := If(oPnlShow:cTitle == ">","<",">"),::HideMenu())},;
                   5,10,,,.F.,.T.,.F.,,.F.,,,.F. )
			oPnlShow:Align := CONTROL_ALIGN_LEFT
			oPnlShow:SetCSS(	"QPushButton{ background-color: #F4F4F4; color: #BEBEBE; font-size: 8px; border: 1px solid #D3D3D3; } " +;
								"QPushButton:Focus{ background-color: #FFFAFA; } " +;
								"QPushButton:Hover{ background-color: #F4F4F4; color: #000000; border: 1px solid #D3D3D3; } ")

		If ::lEditMode
			//Cria combobox contendo todas as opcoes da Biblioteca Grafica
			::oCBoxMenu := TComboBox():New(0,0,,aItens,100,20,::oPnlMenu,,,,,,.T.,,,,,,,,,'cCombo')
				::oCBoxMenu:nAt := 1
				::oCBoxMenu:bSetGet := {|u| If(PCount()>0,cCombo := u,cCombo)}
	  			::oCBoxMenu:bChange := {|| ::HideImagesBox(::oCBoxMenu:nAt)}
				::oCBoxMenu:Align   := CONTROL_ALIGN_TOP
				::oCBoxMenu:bHelp   := { || ShowHelpCpo(STR0394, ; //"Biblioteca Grafica"
												{STR0395},5,; //"A bliblioteca é responsável por facilitar, agilizar e organizar as imagens cadastradas no sistema."
												{},5)  }
		EndIf

		// splitter contendo a tree
		::oSplitter := tSplitter():New( 0,0,::oPnlMenu,150,150,1)
			::oSplitter:Align := CONTROL_ALIGN_ALLCLIENT

		//Cria splitter contendo a Arvore Logica e as Bibliotecas Graficas
		If ::lEditMode
			oPanel := TPanel():New(0,0,,::oSplitter,,,,,,0,300,.F.,.F.)
				oPanel:Align := CONTROL_ALIGN_TOP
			::CreateImagesBox(oPanel)
		EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} CreateTree
Método que cria toda a Arvore logica

@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Method CreateTree() Class TNGPG

	Local lMeter  := Type("_oPgMeter") == "O" .And. Type("_oPgSay") == "O"

	Local cPlantaOld
	Local cFolderA, cFolderB
	Local cAliasQry, cQuery
	Local nFil, cCargoPai
	Local cDescri, cIndCod

	Local aCampos := {}
	Local aIndex  := {}

	Local lRefTAF := .T.
	Local cCargo  := 'LOC'
	Local cCodEst := '001'
	Local cPai    := "001"
	Local cDesc   := " "

	Local lRateio := NGCADICBASE('TAF_RATEIO','D','TAF',.F.)
	Local lEtapa  := NGCADICBASE('TAF_ETAPA' ,'D','TAF',.F.)
	Local lCodAmb := NGCADICBASE('TAF_CODAMB','D','TAF',.F.)
	Local lDepto  := NGCADICBASE('TAF_DEPTO' ,'D','TAF',.F.)

	Private aVetInr   := {}
	Private nMaxNivel := 1

	If lMeter
		_oPgSay:SetText(STR0008) //"Montando Árvore Lógica..."
		_oPgMeter:Set(++_nIncMeter)
	EndIf

	aCampos 	:= fMontaTrb(.T.)
	aIndex 		:= fMontaTrb(.F.)
	::cTrbTree	:= GetNextAlias()

	__cTrbTree := ::cTrbTree
	__cArqTree := NGFwTmpTbl(::cTrbTree,aCampos,aIndex)

	::oTree := dbTree():New(0, 0,170,205, ::oSplitter,,,.T.)
		::oTree:SetCss("Q3ListView{ border: 2px solid #DFDFDF; }")
		::oTree:Align     := CONTROL_ALIGN_BOTTOM
		::oTree:bChange   := {|| ::SetOptionTree()}
		::oTree:bRClicked := {|o,x,y| ::ActiveClickTree(o,x,y) }
		::oTree:bLDblClick:= {|o,x,y| ::DoubleClickTree() }

		::oTree:Reset()
		::oTree:BeginUpdate()

	For nFil := 1 To Len(::aFilial)
		cFilAnt := ::aFilial[nFil]
		dbSelectArea("TAF")
		dbSetOrder(1)
		dbSeek(xFilial('TAF')+'001'+'000')
		cDesc   := TAF->TAF_NOMNIV

		If lMeter
			_oPgMeter:Set(++_nIncMeter)
			_oPgMeter:Refresh()
		EndIf

		//DbAddTree ::oTree Prompt cDesc Opened Resource "PREDIO", "PREDIO" Cargo cPai+cCargo
		::oTree:AddTreeItem(cDesc,"PREDIO",,cPai+"LOC"+cFilAnt)

		RecLock(::cTrbTree,.T.)
		(::cTrbTree)->FILIAL  := cFilAnt
		(::cTrbTree)->CODEST  := cCodEst
		(::cTrbTree)->CODPRO  := '001' //TAF->TAF_CODNIV
		(::cTrbTree)->DESCRI  := cDesc
		(::cTrbTree)->NIVSUP  := '000' //TAF->TAF_NIVSUP
		(::cTrbTree)->RESPONS := TAF->TAF_MAT
		(::cTrbTree)->TIPO    := '2'
		(::cTrbTree)->CODTIPO := TAF->TAF_CODCON
		(::cTrbTree)->RESPONS := TAF->TAF_MAT
		(::cTrbTree)->CC      := TAF->TAF_CCUSTO
		(::cTrbTree)->CENTRAB := TAF->TAF_CENTRA
		(::cTrbTree)->NIVEL   := 0
		(::cTrbTree)->CARGO   := 'LOC'
		(::cTrbTree)->ORDEM   := ::SetMovement() //'001'
		(::cTrbTree)->PLANTA  := "1"
		(::cTrbTree)->TIPIMG  := TAF->TAF_TIPIMG
		(::cTrbTree)->IMAGEM  := TAF->TAF_IMAGEM
		(::cTrbTree)->POSX    := TAF->TAF_POSX
		(::cTrbTree)->POSY    := TAF->TAF_POSY
		(::cTrbTree)->TAMX    := TAF->TAF_TAMX
		(::cTrbTree)->TAMY    := TAF->TAF_TAMY
		(::cTrbTree)->MOVBLO  := TAF->TAF_MOVBLO
		(::cTrbTree)->PGSUP   := ::cPlantaAtu
		(::cTrbTree)->PERMISS := .T.

		If __nModPG == 19
			(::cTrbTree)->MODMNT  := TAF->TAF_MODMNT
			(::cTrbTree)->EVENTO  := TAF->TAF_EVENTO
		ElseIf __nModPG == 35
			(::cTrbTree)->MODMDT  := TAF->TAF_MODMDT
			(::cTrbTree)->EVEMDT  := TAF->TAF_EVEMDT
		ElseIf __nModPG == 56
			(::cTrbTree)->MODSGA  := TAF->TAF_MODSGA
			(::cTrbTree)->EVESGA  := TAF->TAF_EVESGA
		EndIf

		If lCodAmb
			(::cTrbTree)->CODAMB:= TAF->TAF_CODAMB
		EndIf
		If lDepto
			(::cTrbTree)->DEPTO   := TAF->TAF_DEPTO
		EndIf
			//-----------------------------
			//Valor do Zoom para a Planta
			//-----------------------------
		aAdd(::aZoom,{"001"+cFilAnt,100})

			//----------------------------------------------
			//Variavel que indica a posicao da planta atual
			//----------------------------------------------
		::cPlantaAtu := "001"

			//-------------------------------
			//Cria Shape de acordo com Tree
			//-------------------------------
		::CreateShapeOfTree()

		dbSelectArea('TAF')
		dbSetOrder(1)
		dbSeek(xFilial('TAF')+cCodEst+cPai)
		ProcRegua(RecCount()*2)
		While !TAF->(Eof()) .And. TAF->TAF_FILIAL == xFilial('TAF') .And.;
				TAF->TAF_NIVSUP == cPai

			If lMeter
				_oPgMeter:Set(++_nIncMeter)
				_oPgMeter:Refresh()
			EndIf

			If ( __nModPG == 19 .And. Empty( TAF->TAF_MODMNT ) ) .Or. ( __nModPG == 35 .And. Empty( TAF->TAF_MODMDT ) ).Or. ( __nModPG == 56 .And. Empty( TAF->TAF_MODSGA ) )
				TAF->(dbSkip())
				Loop
			EndIf

			If !(TAF->TAF_INDCON $ "0/1/2") .And. ( __nModPG == 35 .And. !(TAF->TAF_INDCON $ "3/4/7") ) .And. ( __nModPG == 56 .And. !(TAF->TAF_INDCON $ "A/B/C") )
				TAF->(dbSkip())
				Loop
			EndIf

			If __nModPG == 19
				If TAF->TAF_INDCON == '1' //Verifica se Bem esta Ativo
					dbSelectArea("ST9")
					dbSetOrder(1)
					If !dbSeek(xFilial("ST9")+TAF->TAF_CODCON) .Or. ST9->T9_SITBEM <> "A"
						TAF->(dbSkip())
						Loop
					EndIf
				EndIf

					//-----------------------------------------------------------------
					// Verifica se o usuario pode visualizar o Bem na Arvore e Planta
					//-----------------------------------------------------------------
				lPermission := ::lEditMode .Or. !FindFunction("NGValidTUA") .Or. NGValidTUA("TAF")
				If (TAF->TAF_INDCON == '1' .Or. TAF->TAF_PLANTA == '1') .And. !lPermission
					TAF->(dbSkip())
					Loop
				EndIf
			EndIf

			fDefEstTree( @cCargo, , @cFolderA, @cFolderB, .F.,,::lEditMode )

			dbSelectArea(::cTrbTree)
			dbSetOrder(2)
			RecLock(::cTrbTree,.T.)
			(::cTrbTree)->FILIAL  := cFilAnt
			(::cTrbTree)->CODEST  := cCodEst
			(::cTrbTree)->CODPRO  := TAF->TAF_CODNIV
			(::cTrbTree)->DESCRI  := TAF->TAF_NOMNIV
			(::cTrbTree)->NIVSUP  := TAF->TAF_NIVSUP
			(::cTrbTree)->RESPONS := TAF->TAF_MAT
			(::cTrbTree)->TIPO    := TAF->TAF_INDCON
			(::cTrbTree)->CODTIPO := TAF->TAF_CODCON
			(::cTrbTree)->RESPONS := TAF->TAF_MAT
			(::cTrbTree)->CC      := TAF->TAF_CCUSTO
			(::cTrbTree)->CENTRAB := TAF->TAF_CENTRA
			(::cTrbTree)->NIVEL   := 1
			(::cTrbTree)->CARGO   := cCargo
			(::cTrbTree)->ORDEM   := TAF->TAF_ORDEM
			(::cTrbTree)->PLANTA  := TAF->TAF_PLANTA
			(::cTrbTree)->TIPIMG  := TAF->TAF_TIPIMG
			(::cTrbTree)->IMAGEM  := TAF->TAF_IMAGEM
			(::cTrbTree)->POSX    := TAF->TAF_POSX
			(::cTrbTree)->POSY    := TAF->TAF_POSY
			(::cTrbTree)->TAMX    := TAF->TAF_TAMX
			(::cTrbTree)->TAMY    := TAF->TAF_TAMY
			(::cTrbTree)->MOVBLO  := TAF->TAF_MOVBLO
			(::cTrbTree)->PGSUP   := ::cPlantaAtu
			(::cTrbTree)->PERMISS := If( __nModPG == 19, lPermission, .T. )

			If __nModPG == 19
				(::cTrbTree)->MODMNT  := TAF->TAF_MODMNT
				(::cTrbTree)->EVENTO  := TAF->TAF_EVENTO
			ElseIf __nModPG == 35
				(::cTrbTree)->MODMDT  := TAF->TAF_MODMDT
				(::cTrbTree)->EVEMDT  := TAF->TAF_EVEMDT
			ElseIf __nModPG == 56
				(::cTrbTree)->MODSGA  := TAF->TAF_MODSGA
				(::cTrbTree)->EVESGA  := TAF->TAF_EVESGA
			EndIf

			If lCodAmb
				(::cTrbTree)->CODAMB:= TAF->TAF_CODAMB
			EndIf
			If lDepto
				(::cTrbTree)->DEPTO   := TAF->TAF_DEPTO
			EndIf

			dbSelectArea("TAF")
			dbSkip()
		EndDo

		If __nModPG == 56
			LoadSgaNiv( @Self, cPai, 1 ) // Carrega niveis/itens de SGA
		EndIf

		_oPgSay:SetText("Vinculando representação gráfica...")
		_oPgSay:Refresh()

		nNivel   	:= 1
		nMaxNivel	:= 1

		dbSelectArea(::cTrbTree)
		dbSetOrder(5)
		While nNivel <= nMaxNivel
            dbSeek(cCodEst+Str(nNivel,2,0))
			While !(::cTrbTree)->(Eof()) .And. nNivel == (::cTrbTree)->NIVEL

				If lMeter .And. (::cTrbTree)->NIVSUP <> cPai
					_oPgMeter:Set(++_nIncMeter)
					_oPgMeter:Refresh()
				EndIf

				If (::cTrbTree)->FILIAL != xFilial("TAF")
					dbSkip()
					Loop
				EndIf

				nRecTrb:= (::cTrbTree)->(Recno())
				cFilho := (::cTrbTree)->CODPRO

				::cPlantaAtu := (::cTrbTree)->PGSUP

				lRefTAF := !( (::cTrbTree)->TIPO $ "A/B/C" ) // Verifica se os dados serao provenientes da TAF

				If lRefTAF // Se nao e' algum item de fora da TAF

					dbSelectArea('TAF')
					dbSetOrder(2)
					dbSeek(xFilial('TAF')+cCodEst+cFilho)

					nRecTAF  	:= TAF->(Recno())

					If TAF->TAF_PLANTA == "1"
						::cPlantaAtu := TAF->TAF_CODNIV
						aAdd(::aZoom,{TAF->TAF_CODNIV+cFilAnt,100})
					EndIf

					dbSelectArea("TAF")
					dbSetOrder(1)
					dbSeek(xFilial("TAF")+cCodEst+cFilho)
					While !TAF->(Eof()) .And. TAF->TAF_FILIAL == xFilial("TAF") .And.;
							TAF->TAF_NIVSUP == cFilho

						If ( __nModPG == 19 .And. Empty( TAF->TAF_MODMNT ) ) .Or. ( __nModPG == 35 .And. Empty( TAF->TAF_MODMDT ) ) .Or. ( __nModPG == 56 .And. Empty( TAF->TAF_MODSGA ) )
							TAF->(dbSkip())
							Loop
						EndIf

						If !(TAF->TAF_INDCON $ "0/1/2") .And. ( __nModPG == 35 .And. !(TAF->TAF_INDCON $ "3/4/7") ) .And. ( __nModPG == 56 .And. !(TAF->TAF_INDCON $ "A/B/C") )
							TAF->(dbSkip())
							Loop
						EndIf

						If __nModPG == 19
							If TAF->TAF_INDCON == "1" //Verifica se Bem esta Ativo
								dbSelectArea("ST9")
								dbSetOrder(1)
								If !dbSeek(xFilial("ST9")+TAF->TAF_CODCON) .Or. ST9->T9_SITBEM <> "A"
									TAF->(dbSkip())
									Loop
								EndIf
							EndIf

								//-----------------------------------------------------------------
								// Verifica se o usuario pode visualizar o Bem na Arvore e Planta
								//-----------------------------------------------------------------
							lPermission := ::lEditMode .Or. !FindFunction("NGValidTUA") .Or. NGValidTUA("TAF")
							If (TAF->TAF_INDCON == '1' .Or. TAF->TAF_PLANTA == '1') .And. !lPermission
								TAF->(dbSkip())
								Loop
							EndIf
						EndIf

						fDefEstTree( @cCargo, , @cFolderA, @cFolderB, .F., , ::lEditMode )

						RecLock(::cTrbTree,.T.)
						(::cTrbTree)->FILIAL  := cFilAnt
						(::cTrbTree)->CODEST  := cCodEst
						(::cTrbTree)->CODPRO  := TAF->TAF_CODNIV
						(::cTrbTree)->DESCRI  := TAF->TAF_NOMNIV
						(::cTrbTree)->NIVSUP  := TAF->TAF_NIVSUP
						(::cTrbTree)->RESPONS := TAF->TAF_MAT
						(::cTrbTree)->TIPO    := TAF->TAF_INDCON
						(::cTrbTree)->CODTIPO := TAF->TAF_CODCON
						(::cTrbTree)->RESPONS := TAF->TAF_MAT
						(::cTrbTree)->CC      := TAF->TAF_CCUSTO
						(::cTrbTree)->CENTRAB := TAF->TAF_CENTRA
						(::cTrbTree)->NIVEL   := nNivel+1
						(::cTrbTree)->CARGO   := cCargo
						(::cTrbTree)->ORDEM   := TAF->TAF_ORDEM
						(::cTrbTree)->PLANTA  := TAF->TAF_PLANTA
						(::cTrbTree)->TIPIMG  := TAF->TAF_TIPIMG
						(::cTrbTree)->IMAGEM  := TAF->TAF_IMAGEM
						(::cTrbTree)->POSX    := TAF->TAF_POSX
						(::cTrbTree)->POSY    := TAF->TAF_POSY
						(::cTrbTree)->TAMX    := TAF->TAF_TAMX
						(::cTrbTree)->TAMY    := TAF->TAF_TAMY
						(::cTrbTree)->MOVBLO  := TAF->TAF_MOVBLO
						(::cTrbTree)->PGSUP   := ::cPlantaAtu
						(::cTrbTree)->PERMISS := If( __nModPG == 19, lPermission, .T. )

						If __nModPG == 19
							(::cTrbTree)->MODMNT  := TAF->TAF_MODMNT
							(::cTrbTree)->EVENTO  := TAF->TAF_EVENTO
						ElseIf __nModPG == 35
							(::cTrbTree)->MODMDT  := TAF->TAF_MODMDT
							(::cTrbTree)->EVEMDT  := TAF->TAF_EVEMDT
						ElseIf __nModPG == 56
							(::cTrbTree)->MODSGA  := TAF->TAF_MODSGA
							(::cTrbTree)->EVESGA  := TAF->TAF_EVESGA
						EndIf

						If lCodAmb
							(::cTrbTree)->CODAMB:= TAF->TAF_CODAMB
						EndIf
						If lDepto
							(::cTrbTree)->DEPTO   := TAF->TAF_DEPTO
						EndIf

						nMaxNivel := nNivel+1

						dbSelectArea("TAF")
						dbSkip()

					EndDo
                Else
                	nRecTAF := 0
				Endif

				(::cTrbTree)->(dbGoto(nRecTrb))
				TAF->(dbGoTo(nRecTAF))

				If __nModPG == 56 .And. (::cTrbTree)->TIPO == "2"
					LoadSgaNiv( @Self, cFilho, nNivel ) //Carrega itens filhos do nivel atual, ou seja, nNivel + 1
					(::cTrbTree)->(dbGoto(nRecTrb))
					TAF->(dbGoTo(nRecTAF))
				Endif

				fDefEstTree( @cCargo, @cCargoPai, @cFolderA, @cFolderB, !lRefTAF, .T., ::lEditMode )

				::cPlantaAtu := (::cTrbTree)->PGSUP

				//-------------------------------
				//Cria Shape de acordo com Tree
				//-------------------------------
				::CreateShapeOfTree( lRefTAF )

				cIndCod := If( lRefTAF, TAF->TAF_INDCON, (::cTrbTree)->TIPO)

				If (cIndCod != "0" .Or. ::lEditMode) .And. (::cTrbTree)->PERMISS
					::oTree:TreeSeek((::cTrbTree)->NIVSUP+cCargoPai+cFilAnt)
					::oTree:AddItem((::cTrbTree)->DESCRI,(::cTrbTree)->CODPRO+cCargo+cFilAnt,cFolderA,cFolderB,,, 2)
				EndIf

				dbSelectArea(::cTrbTree)
				dbSkip()

			EndDo

		   	nNivel++
		EndDo

		If lMeter .And. nFil == Len(::aFilial)
			_oPgSay:SetText("Finalizando processamento...")
			_oPgSay:Refresh()
			_oPgMeter:Set(_nTotalMeter+1)
			_oPgMeter:Refresh()
		EndIf

		dbSelectArea(::cTrbTree)
		dbSetOrder(5)
		If (::cTrbTree)->(RecCount()) > 0
			While nMaxNivel >= 1
                dbSeek("001"+Str(nMaxNivel,2,0))
				While (::cTrbTree)->NIVEL == nMaxNivel

					If (::cTrbTree)->TIPO == '2'
						::oTree:TreeSeek((::cTrbTree)->CODPRO+'LOC'+cFilAnt)
						::oTree:PtCollapse()
					EndIf

					(::cTrbTree)->(dbSkip())
				End
				nMaxNivel--
			EndDo
		EndIf

		::cPlantaAtu := ""
		::oTree:EndUpdate()
		::oTree:EndTree()
		::oTree:TreeSeek("001LOC"+cFilAnt)//::SetOptionTree("001LOC"+cFilAnt) //Seta para a raiz
		::oTree:PtCollapse() //Fecha a Arvore

	Next nFil

	// Posiciona no primeiro item da Árvore Lógica
	::SetOptionTree("001LOC"+::cFilAnt)

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} UltCodNiv
Retorna o último código de nível utilizado na TAF

@author Vitor Emanuel Batista
@since 05/10/2011
@version MP10
@return cUltCodNiv Código caracter
/*/
//---------------------------------------------------------------------
Method UltCodNiv() Class TNGPG

	Local cUltCodNiv := "001"
	Local cAliasQry	 := GetNextAlias()
	Local cQuery

	cQuery := " SELECT MAX(TAF_CODNIV) AS cCodMax FROM "+RetSqlName("TAF")
	cQuery += " WHERE TAF_FILIAL = '"+xFilial("TAF")+"' AND D_E_L_E_T_ <> '*'"
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	dbSelectArea(cAliasQry)
	dbGoTop()
	If !Empty((cAliasQry)->cCodMax)
		cUltCodNiv := (cAliasQry)->cCodMax
	EndIf
	(cAliasQry)->(dbCloseArea())

Return cUltCodNiv

//---------------------------------------------------------------------
/*/{Protheus.doc} MaxCodNiv
Retorna o valor númerico da quantidade de itens na TAF a serem carregadas

@author Vitor Emanuel Batista
@since 05/10/2011
@version MP10
@return nTotal Valor numérico
/*/
//---------------------------------------------------------------------
Method MaxCodNiv() Class TNGPG
	Local nX
	Local nTotal := 1
	Local cAliasQry := GetNextAlias()
	Local cQuery
	Local cAllFil := ""

	For nX := 1 To Len(::aFilial)
		If nX > 1
			cAllFil += ','
		EndIf
		cAllFil += ValToSql(::aFilial[nX])
	Next nX

	cQuery := " SELECT COUNT(*) AS TOTAL FROM "+RetSqlName("TAF")
	cQuery += " WHERE TAF_FILIAL IN ("+cAllFil+") AND D_E_L_E_T_ <> '*'"
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	dbSelectArea(cAliasQry)
	nTotal := (cAliasQry)->TOTAL
	(cAliasQry)->(dbCloseArea())

Return nTotal

//---------------------------------------------------------------------
/*/{Protheus.doc} SetId
Método que faz controle de ID's sobre os shapes criados na planta

@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return nId Id disponivel para AddShape
/*/
//---------------------------------------------------------------------
Method SetId() Class TNGPG
Return ++::nId

//---------------------------------------------------------------------
/*/{Protheus.doc} SetMovement
Método que faz controle sobre as movimentacoes feitas nos shapes

@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return cMovement Numero do movimento do shape
/*/
//---------------------------------------------------------------------
Method SetMovement() Class TNGPG
Return ::cMovement := If(FindFunction("Soma1Old"),Soma1Old(AllTrim(::cMovement)),Soma1(AllTrim(::cMovement)))

//---------------------------------------------------------------------
/*/{Protheus.doc} GetArrInfoBox
Método que verifica todas as opcoes disponiveis na biblioteca grafica

@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return aItens Array contendo bibliotecas de imagens cadastrada na TU0
/*/
//---------------------------------------------------------------------
Method GetArrInfoBox() Class TNGPG
	Local aItens := {}

	dbSelectArea("TU0")
	dbSetOrder(2)
	dbSeek(xFilial("TU0"))
	While TU0->( !Eof() ) .And. xFilial("TU0") == TU0->TU0_FILIAL
		// Não exibe biblioteca das imagens do Riscos Ambientais se não for do módulo de MDT
		If ( __nModPG <> 35 .And. fChkRegTU1( TU0->TU0_OPCAO ) )
			TU0->( dbSkip() )
			Loop
		EndIf

		If TU0->TU0_VISIBL != "2"
			aAdd(aItens,AllTrim(TU0->TU0_DESCRI))
		EndIf
		dbSkip()
	EndDo

	__TotalOptionBox__ := Len(aItens)

Return aItens

//---------------------------------------------------------------------
/*/{Protheus.doc} HideMenu
Método que esconde Menu Lateral Esquerdo, contendo a Arvore Logica e
biblioteca de imagens

@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Method HideMenu() Class TNGPG

	If ::oPnlMenu:lVisible
		::oPnlMenu:Hide()
	Else
		::oPnlMenu:Show()
	EndIf
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} SetBlackPnl
Método que cria painel escuro transparente, utilizado ao exibir novas
dialogs sobre a Planta

@param lVisible Indica se deve mostrar o painel ou nao
@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Method SetBlackPnl(lVisible) class TNGPG
	Default lVisible := .T.

	If ValType(::oBlackPnl) != "O"
		::oBlackPnl := TPanel():New(0,0,,Self,,,,,SetTransparentColor(CLR_BLACK,70),::nWidth,::nHeight,.F.,.F.)
			::oBlackPnl:Hide()
	EndIf

	If lVisible
		::oBlackPnl:nWidth  := ::nWidth
		::oBlackPnl:nHeight := ::nHeight
		::oBlackPnl:Show()
	Else
		::oBlackPnl:Hide()
	EndIf
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} SetLinhas
Método que cria linhas na planta no Modo de Edicao

@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Method SetLinhas() Class TNGPG
	Local nX
	Local nFirst := 0

	If Len(::aLinhas) == 0

		For nX := 1 To 100
			nFirst += 15
			::oTPanel:addShape("id="+cValToChar(::SetId())+";type=6;gradient=1,0,0,0,0,0.0,#e1e1e1;pen-width=1;"+;
			                "pen-color=#e1e1e1;large=0;from-left=1;from-top="+cValToChar(nFirst)+";"+;
			                "to-left="+cValToChar(::oTPanel:nWidth*2)+";to-top="+cValToChar(nFirst)+";is-container=" + If(lReleaseB,'0','1') + ";")
			aAdd(::aLinhas,::nId)
			::oTPanel:addShape("id="+cValToChar(::SetId())+";type=6;gradient=1,0,0,0,0,0.0,#e1e1e1;pen-width=1;"+;
			                "pen-color=#e1e1e1;large=0;from-left="+cValToChar(nFirst)+";from-top=1;"+;
			                "to-left="+cValToChar(nFirst)+";to-top="+cValToChar(::oTPanel:nHeight)+";is-container=" + If(lReleaseB,'0','1') + ";")
			aAdd(::aLinhas,::nId)
		Next nX
	Else
		For nX := 1 To Len(::aLinhas)
			::oTPanel:SetVisible(::aLinhas[nX],lShow)
		Next nX
	EndIf
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} GetArrImgBox
Método que verifica e retorna todas as imagens disponiveis na biblioteca
de imagens (TU0 e TU1)

@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Method GetArrImgBox() Class TNGPG

	Local aImages := {} //Array(__TotalOptionBox__,0)
	Local lMeter  := Type("_oPgMeter") == "O" .And. Type("_oPgSay") == "O"
	Local cDirImg
	Local nAllImg
	Local oBmp

	If lMeter
		_oPgSay:SetText(STR0009) //"Consultando Biblioteca Gráfica..."
		_oPgMeter:Set(++_nIncMeter)
		_oPgMeter:Refresh()
	EndIf

	dbSelectArea("TU0")
	dbSetOrder(2)
	dbSeek(xFilial("TU0"))
	While !Eof() .And. xFilial("TU0") == TU0->TU0_FILIAL
		// Não exibe biblioteca das imagens do Riscos Ambientais se não for do módulo de MDT
		If ( __nModPG <> 35 .And. fChkRegTU1( TU0->TU0_OPCAO )  )
			TU0->( dbSkip() )
			Loop
		EndIf

		If TU0->TU0_VISIBL != "2"
			aAdd(aImages,{})
			dbSelectArea("TU1")
			dbSetOrder(1)
			dbSeek(xFilial("TU1")+TU0->TU0_OPCAO)
			While !Eof() .And. xFilial("TU1") == TU1->TU1_FILIAL .And. TU1->TU1_OPCAO == TU0->TU0_OPCAO
				If TU1->TU1_VISIBL != "2"
					cDirImg := ::ExportImage(TU1->TU1_TIPIMG,TU1->TU1_IMAGEM)
					If !Empty(cDirImg)
						//Verifica o tamanho da imagem
						oBmp := TBitmap():New(0,0,0,0,,,.F.,GetWndDefault(),,,,.F.,,,,,.T.)
							oBmp:Hide()
						If oBmp:Load(,cDirImg)
							oBmp:nClrPane := CLR_WHITE
							oBmp:lAutoSize    := .T.
							oBmp:lTransparent := .T.
							oBmp:Refresh()
							nLargura := oBmp:nClientWidth
							nAltura  := oBmp:nClientHeight

							aAdd(aTail(aImages),{cDirImg,AllTrim(TU1->TU1_TOOLTI),AllTrim(TU1->TU1_DESCRI),TU1->TU1_TIPIMG})

							aAdd(::aAllImg,Array(5))
							nAllImg := Len(::aAllImg)
							::aAllImg[nAllImg][__aAllImg_TipImg__]  := TU1->TU1_TIPIMG
							::aAllImg[nAllImg][__aAllImg_Imagem__]  := TU1->TU1_IMAGEM
							::aAllImg[nAllImg][__aAllImg_DirImg__]  := cDirImg
							::aAllImg[nAllImg][__aAllImg_Largura__] := nLargura
							::aAllImg[nAllImg][__aAllImg_Altura__]  := nAltura
						EndIf
						oBmp:Free()

					EndIf
				EndIf
				dbSelectArea("TU1")
				dbSkip()
			EndDo
		EndIf
		dbSelectArea("TU0")
		dbSkip()
	EndDo

Return aImages

//---------------------------------------------------------------------
/*/{Protheus.doc} ExportImage
Método que exporta uma imagem da biblioteca para um diretorio

@param cTipouImg Idendifica se a imagem é do RPO ou do Cadastrode Imagens
@param cImagem Nome da imagem e extensão
@param cDirectory Indica o caminho que a imagem será exportada
@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Method ExportImage(cTipoImg,cImage,cDirectory) Class TNGPG
	Local cImageTo
//	Local oBmp

	Default cDirectory := ::GetDirectory()

	cImageTo := AllTrim(cDirectory+Trim(cImage))

	If File(cImageTo)
		Return cImageTo
	EndIf

	If !ExistDir(cDirectory)
		MakeDir(cDirectory)
	EndIf

	If !File(cImageTo)

		If cTipoImg != "2" //Extrair imagem do RPO
			If !Resource2File(Trim(cImage),cImageTo)
				cImageTo := ""
			EndIf
		Else //Extrair do RPO de imagem
			nPonto := At(".",cImage)-1

			//Verifica se a imagem não foi criada no mesmo instante por outra thread
			If !File( cImageTo)
				::oRep:Extract(Substr(cImage,1,nPonto),cImageTo,,.T.,.T.)

				//Caso o caminho da extensão fique errado, renomeia
				If !File( cImageTo) .And. File( cDirectory + Substr(cImage,1,nPonto) + ".JPG" )
					FRename( cDirectory + Substr(cImage,1,nPonto) + ".JPG", cImageTo )
				EndIf
			EndIf

		EndIf
	EndIf
Return lower(cImageTo)

/*Method BlockMove(nShapeAtu) Class TNGPG
	Local nPosShape

	Default nShapeAtu := ::GetShapeAtu()

	nPosShape := ::GetPosShape(nShapeAtu)

	If nPosShape > 0
		::oTPanel:SetCanMove(::aShape[nPosShape][__aShape_IdShape__],::aShape[nPosShape][__aShape_Blocked__])
		::aShape[nPosShape][__aShape_Blocked__] := !::aShape[nPosShape][__aShape_Blocked__]
	EndIf

Return*/

/*Method SendBack(nShapeAtu) Class TNGPG
	Local nPosShape, nShape
	Local aSortShape  := aSort(aClone(::aShape),,,{|x,y| x[__aShape_Movement__] > x[__aShape_Movement__]  })

	Default nShapeAtu := ::GetShapeAtu()

	nPosShape := ::GetPosShape(nShapeAtu)
	//::aShape[nPosShape][__aShape_Movement__] := aSortShape[1][__aShape_Movement__] - 1
//#DEFINE __aShape_PosX__     06
//#DEFINE __aShape_PosY__     07
	//::oTPanel:SetVisible(nShapeAtu,
	For nShape := 1 To Len(aSortShape)
		If nShapeAtu != aSortShape[nShape][__aShape_IdShape__] .And. ::cPlantaAtu == aSortShape[nShape][__aShape_PlanSup__]
			::oTPanel:SetPosition(aSortShape[nShape][__aShape_IdShape__],aSortShape[nShape][__aShape_PosX__],aSortShape[nShape][__aShape_PosY__])
			//::oTPanel:SetVisible(aSortShape[nShape][__aShape_IdShape__],.F.)
		EndIf
	Next nShape

	/*For nShape := 1 To Len(aSortShape)
		If nShapeAtu != aSortShape[nShape][__aShape_IdShape__] .And. ::cPlantaAtu == aSortShape[nShape][__aShape_PlanSup__]
			::oTPanel:SetVisible(aSortShape[nShape][__aShape_IdShape__],.T.)
		EndIf
	Next nShape
Return*/

//---------------------------------------------------------------------
/*/{Protheus.doc} SetImageFocus
Insere ou exclui o foco no shape selecionado

@param lFocus Indica se habilitará o Foco
@param nShapeAtu ShapeAtu para se criar o Foco
@author Vitor Emanuel Batista
@since 06/10/2011
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Method SetImageFocus(lFocus,nShapeAtu) Class TNGPG

	Default nShapeAtu := ::GetShapeAtu()

	If ::lEditMode

		nPosShape := ::GetPosShape(nShapeAtu)

		If Len(::aImageFocus) > 0
			If !lFocus
				::oTPanel:SetVisible(::aImageFocus[FOCUS_TOP_LEFT],.F.)
				::oTPanel:SetVisible(::aImageFocus[FOCUS_TOP_RIGHT],.F.)
				::oTPanel:SetVisible(::aImageFocus[FOCUS_BOTTOM_LEFT],.F.)
				::oTPanel:SetVisible(::aImageFocus[FOCUS_BOTTOM_RIGHT],.F.)
			Else
				::oTPanel:DeleteItem(::aImageFocus[FOCUS_TOP_LEFT])
				::oTPanel:DeleteItem(::aImageFocus[FOCUS_TOP_RIGHT])
				::oTPanel:DeleteItem(::aImageFocus[FOCUS_BOTTOM_LEFT])
				::oTPanel:DeleteItem(::aImageFocus[FOCUS_BOTTOM_RIGHT])
				::aImageFocus := {}
			EndIf
		EndIf

		If nPosShape > 0 .And. lFocus .And. !::aShape[nPosShape][__aShape_Blocked__]
			::aImageFocus := Array(5)
			::aImageFocus[FOCUS_SHAPE_DAD]   := nShapeAtu
			::aImageFocus[FOCUS_TOP_LEFT]    := ::SetId()
			::aImageFocus[FOCUS_TOP_RIGHT]   := ::SetId()
			::aImageFocus[FOCUS_BOTTOM_LEFT] := ::SetId()
			::aImageFocus[FOCUS_BOTTOM_RIGHT]:=  ::SetId()
			nPosX    := ::aShape[nPosShape][__aShape_PosX__]
			nPosY    := ::aShape[nPosShape][__aShape_PosY__]
			nLargura := ::aShape[nPosShape][__aShape_Largura__]
			nAltura  := ::aShape[nPosShape][__aShape_Altura__]

			::oTPanel:addShape("id="+cValToChar(::aImageFocus[FOCUS_TOP_LEFT])+";type=1;left="+cValToChar(nPosX-5)+";top="+cValToChar(nPosY-5)+;
							";width=5;height=5;pen-width=1;"+;
							"gradient=1,0,0,0,180,0.0,#FFFFFF;pen-color=#000000;can-mark=1;can-move=1;can-deform=1;is-container=" + If(lReleaseB,'0','1') + ";")

			::oTPanel:addShape("id="+cValToChar(::aImageFocus[FOCUS_TOP_RIGHT])+";type=1;left="+cValToChar(nPosX+nLargura)+";top="+cValToChar(nPosY-5)+;
							";width=5;height=5;pen-width=1;"+;
							"gradient=1,0,0,0,180,0.0,#FFFFFF;pen-color=#000000;can-mark=1;can-move=1;can-deform=1;is-container=" + If(lReleaseB,'0','1') + ";")

			::oTPanel:addShape("id="+cValToChar(::aImageFocus[FOCUS_BOTTOM_LEFT])+";type=1;left="+cValToChar(nPosX-5)+";top="+cValToChar(nPosY+nAltura)+;
							";width=5;height=5;pen-width=1;"+;
							"gradient=1,0,0,0,180,0.0,#FFFFFF;pen-color=#000000;can-mark=1;can-move=1;can-deform=1;is-container=" + If(lReleaseB,'0','1') + ";")

			::oTPanel:addShape("id="+cValToChar(::aImageFocus[FOCUS_BOTTOM_RIGHT])+";type=1;left="+cValToChar(nPosX+nLargura)+";top="+cValToChar(nPosY+nAltura)+;
							";width=5;height=5;pen-width=1;"+;
							"gradient=1,0,0,0,180,0.0,#FFFFFF;pen-color=#000000;can-mark=1;can-move=1;can-deform=1;is-container=" + If(lReleaseB,'0','1') + ";")

		EndIf

		//Tira o foco do shape em movimento
		//::oTPanel:SetPosition(__nIdAux,0,0)
	EndIf
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} ResizeFocus
Faz resize da imagem de acordo com a movimentação do Focus

@param nShapeAtu ShapeAtu que será feito Resize
@author Vitor Emanuel Batista
@since 06/10/2011
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Method ResizeFocus(nShapeAtu) Class TNGPG
	Local nPosY, nPosX, nDifX, nDifY
	Local nAltura, nLargura, nPosShape

	Default nShapeAtu := ::GetShapeAtu()

	nPosShape := ::GetPosShape(::aImageFocus[FOCUS_SHAPE_DAD])

	If nPosShape > 0
		nPosX    := ::aShape[nPosShape][__aShape_PosX__]
		nPosY    := ::aShape[nPosShape][__aShape_PosY__]
		nLargura := ::aShape[nPosShape][__aShape_Largura__]
		nAltura  := ::aShape[nPosShape][__aShape_Altura__]


		//2------3
		//|      |
		//|      |
		//4------5
		If nShapeAtu == ::aImageFocus[FOCUS_TOP_LEFT]
			nLargura := nLargura + (nPosX - ::oTPanel:LeftAtu)
			nAltura  := nAltura+ (nPosY - ::oTPanel:TopAtu)
			nPosX := ::oTPanel:LeftAtu
			nPosY := ::oTPanel:TopAtu
		ElseIf nShapeAtu == ::aImageFocus[FOCUS_TOP_RIGHT]
			nDifX := ( ::oTPanel:LeftAtu - (nPosX+nLargura+4))
			nDifY := (nPosY - (::oTPanel:TopAtu+4))
			nLargura += nDifX
			nAltura  += nDifY
			nPosY    -= nDifY
		ElseIf nShapeAtu == ::aImageFocus[FOCUS_BOTTOM_LEFT]
			nDifY := ( ::oTPanel:TopAtu - (nPosY+nAltura+4))
			nDifX := (nPosX - (::oTPanel:LeftAtu+4))
			nLargura += nDifX
			nAltura  += nDifY
			nPosX    -= nDifX
		ElseIf nShapeAtu == ::aImageFocus[FOCUS_BOTTOM_RIGHT]
			nAltura := ::oTPanel:TopAtu -  nPosY
			nLargura:= ::oTPanel:LeftAtu -  nPosX
		EndIf

		If nAltura > 0 .And. nLargura > 0 .And. (::aShape[nPosShape][__aShape_Largura__] <> nLargura .Or. ;
			nAltura  <> ::aShape[nPosShape][__aShape_Altura__]) .And. (nPosY+nAltura >0 .And. nPosX+nLargura > 0)
			::aShape[nPosShape][__aShape_PosX__] := nPosX
			::aShape[nPosShape][__aShape_PosY__] := nPosY
			::ResizeImage(::aImageFocus[FOCUS_SHAPE_DAD],nLargura,nAltura)
			dbSelectArea(::cTrbTree)
			dbSetOrder(2)
			If dbSeek("001"+Substr(::aShape[nPosShape][__aShape_Cargo__],1,3)+cFilAnt)
				RecLock(::cTrbTree,.F.)
				(::cTrbTree)->POSX    := nPosX
				(::cTrbTree)->POSY    := nPosY
				(::cTrbTree)->TAMX    := nLargura
				(::cTrbTree)->TAMY    := nAltura
				MsUnLock()
			EndIf

			::ModifyLocation(nPosShape)

			//-----------------------------------------------------------------
			// Identifica que a planta teve alterações e necessita ser salva
			//-----------------------------------------------------------------
			::lModified := .T.
		EndIf
	EndIf
Return
//---------------------------------------------------------------------
/*/{Protheus.doc} CreateImagesBox
Método que cria todas as bibliotecas e suas respectivas imagens

@param oPanel Panel pai
@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Method CreateImagesBox(oPanel) Class TNGPG
	Local oBmp
	Local nOption, nY
	Local nTop,nLeft
	Local lMeter := Type("_oPgMeter") == "O" .And. Type("_oPgSay") == "O"

	If ::lEditMode
		::aImgBox := ::GetArrImgBox()
		::aObjBox := Array(__TotalOptionBox__)

		If lMeter
			_oPgSay:SetText(STR0010) //"Montando Biblioteca Gráfica..."
			_oPgMeter:Set(++_nIncMeter)
			_oPgMeter:Refresh()
		EndIf

		For nOption := 1 To Len(::aImgBox)

			::aObjBox[nOption] := Array(2)
			::aObjBox[nOption][2] := Array(Len(::aImgBox[nOption]),3)

			//Panel contendo todos os objetos
			::aObjBox[nOption][__aObjBox_TScroll__] := TScrollBox():New(oPanel,0,0,200,200,.T.,.F.,.T.)
				::aObjBox[nOption][__aObjBox_TScroll__]:Align := CONTROL_ALIGN_ALLCLIENT

			nTop := -40
			nLeft:= 80

			For nY := 1 To Len(::aImgBox[nOption])

				If nY % 2 > 0
					nTop  += 45
				EndIf

				nLeft := If(nLeft == 10,80,10)
				::aObjBox[nOption][2][nY][__aObjBox_TBitmap__]  := TBitmap():New(nTop,nLeft,35,35,,::aImgBox[nOption][nY][1],.T.,::aObjBox[nOption][__aObjBox_TScroll__],{|| },,.F.,.F.,,,.F.,,.T.,,.F.)
					::aObjBox[nOption][2][nY][__aObjBox_TBitmap__]:blClicked := &("{|| Self:SelectImage("+cValToChar(nOption)+","+cValToChar(nY)+")}")
					::aObjBox[nOption][2][nY][__aObjBox_TBitmap__]:nClrPane  := CLR_WHITE
					::aObjBox[nOption][2][nY][__aObjBox_TBitmap__]:cToolTip  := ::aImgBox[nOption][nY][2]
					::aObjBox[nOption][2][nY][__aObjBox_TBitmap__]:lTransparent := .T.
					::aObjBox[nOption][2][nY][__aObjBox_TBitmap__]:lStretch  := .T.
					::aObjBox[nOption][2][nY][__aObjBox_TBitmap__]:nHeight := 69
					::aObjBox[nOption][2][nY][__aObjBox_TBitmap__]:nWidth  := 69

				::aObjBox[nOption][2][nY][__aObjBox_TSay__] := TSay():New(nTop+35,nLeft-6,&("{|| '"+Space(16-Len(Trim(::aImgBox[nOption][nY][3])))+::aImgBox[nOption][nY][3]+"' }"),;
																					::aObjBox[nOption][__aObjBox_TScroll__],,/*oFont*/,,,,.T.,CLR_RED,CLR_WHITE,45,0)
					::aObjBox[nOption][2][nY][__aObjBox_TSay__]:blClicked := &("{|| Self:SelectImage("+cValToChar(nOption)+","+cValToChar(nY)+")}")
					::aObjBox[nOption][2][nY][__aObjBox_TipImg__] := ::aImgBox[nOption][nY][4]
			Next nY
		Next nOption

		::HideImagesBox(1)
	EndIf
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} ResizeImage
Método que redimensiona imagem selecionada para um tamanho especificado

@param nShapeAtu Id do shape que sera redimensionado
@param nLargura Largura escolhida para o redimensionamento
@param nAltura Altura escolhida para o redimensionamento
@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Method ResizeImage(nShapeAtu,nLargura,nAltura) Class TNGPG
	Local nPosShape := ::GetPosShape(nShapeAtu)
	Local oBmp
	Local cImage, cDescri, cSetMark
	Local nIdShape, nPosX, nPosY
	Local cImageShape

	If nPosShape > 0
		nIdShape := ::aShape[nPosShape][__aShape_IdShape__]
		cImage   := ::aShape[nPosShape][__aShape_ImgIni__]
		nPosX    := ::aShape[nPosShape][__aShape_PosX__]
		nPosY    := ::aShape[nPosShape][__aShape_PosY__]
		cDescri  := ::aShape[nPosShape][__aShape_Descri__]
		nLargIni := ::aShape[nPosShape][__aShape_LargIni__]
		nAltIni  := ::aShape[nPosShape][__aShape_AltIni__]

		If nLargura == 0 .Or. nAltura == 0
			MsgStop(STR0347+Trim(cImage)+") inválido.") //"Tamanho da imagem ("
			return
		EndIf

		// Verifica se método SetImageSize existe na classe (superior a 7.00.111010P)
		// Retirado metodo MethIsMemberOf. Verificacao

		// If MethIsMemberOf(self:oTPanel,"SetImageSize")
		If GetBuild() >= "7.00.120420A-20120726"
			::aShape[nPosShape][__aShape_Image__]   := cImage
			::aShape[nPosShape][__aShape_Largura__] := nLargura
			::aShape[nPosShape][__aShape_Altura__]  := nAltura

			//Possibilita o Resize de imagem .PNG sem perda de transparencia
			::oTPanel:SetImageSize(nIdShape,nLargura,nAltura)

		Else

			If (::aShape[nPosShape][__aShape_IndCod__] == "0" .And. !::lEditMode) .Or. !(::cTrbTree)->PERMISS
				cSetMark := "can-mark=0;"
			Else
				cSetMark := "can-mark=1;"
			EndIf

			If ::aShape[nPosShape][__aShape_Largura__] != nLargura .And. ::aShape[nPosShape][__aShape_Altura__] != nAltura
				If nLargura != nLargIni .Or. nAltura != nAltIni

					cImageShape := Substr(cImage,1,rAt(".",cImage)-1)
					cImageShape := Lower(cImageShape+cValToChar(nAltura)+"_"+cValToChar(nLargura)+".BMP")
					cImageShape := RemoveLinux(cImageShape)

					If !File(cImageShape)
						oBmp := TBitmap():New(0,0,0,0,,,.T.,,,,,.F.,,,,,.T.)
						oBmp:Hide()
						If oBmp:Load(,cImage)
							oBmp:lStretch:= .T.
							oBmp:lTransparent := .T.
							oBmp:nHeight := nAltura
							oBmp:nWidth  := nLargura
							oBmp:nClrPane := CLR_WHITE

							If !oBmp:SaveAsBmp(cImageShape)
								MsgStop(STR0011 + "("+AllTrim(cImage)+")") //"Ocorreu um erro inesperado ao tentar salvar a imagem informada."
							EndIf
						Else
							MsgStop(STR0012 + "("+AllTrim(cImage)+")") //"Ocorreu um erro inesperado ao carregar a imagem informada."
						EndIf


						If File(cImageShape)
							::aShape[nPosShape][__aShape_Image__]   := cImage
							::aShape[nPosShape][__aShape_Largura__] := nLargura
							::aShape[nPosShape][__aShape_Altura__]  := nAltura

							::oTPanel:DeleteItem(nIdShape)
							::oTPanel:addShape("id="+cValToChar(nIdShape)+";type=8;left="+cValToChar(nPosX)+";top="+cValToChar(nPosY)+";tooltip="+Trim(cDescri)+;
											   ";width="+cValToChar(nLargura)+";height="+cValToChar(nAltura)+";image-file="+lower(cImageShape)+";can-move=1;can-deform=1;is-container=" + If(lReleaseB,'0','1') + ";"+cSetMark)
						EndIf
						oBmp:Free()
					EndIf

				ElseIf ::aShape[nPosShape][__aShape_Largura__] != nLargIni .Or. ::aShape[nPosShape][__aShape_Altura__]  != nAltIni
					cImageShape := lower(::aShape[nPosShape][__aShape_ImgIni__])

					cImageShape := RemoveLinux(cImageShape)

					::oTPanel:DeleteItem(nShapeAtu)
					::oTPanel:addShape("id="+cValToChar(nShapeAtu)+";type=8;left="+cValToChar(::aShape[nPosShape][__aShape_PosX__])+";top="+cValToChar(::aShape[nPosShape][__aShape_PosY__])+";tooltip="+Trim(cDescri)+;
									   ";width="+cValToChar(nLargura)+";height="+cValToChar(nAltura)+";image-file="+lower(cImageShape)+";"+cSetMark+"can-move=1;can-deform=1;is-container=" + If(lReleaseB,'0','1') + ";"+cSetMark)
					::aShape[nPosShape][__aShape_Image__] := ::aShape[nPosShape][__aShape_ImgIni__]
					::aShape[nPosShape][__aShape_Largura__] := nLargura
					::aShape[nPosShape][__aShape_Altura__]  := nAltura
				EndIf
			EndIf
		EndIf

		//Bloqueia a movimentacao
		If ::aShape[nPosShape][__aShape_Blocked__] .Or. !::lEditMode
			::oTPanel:SetCanMove(nShapeAtu,.F.)
		EndIf

	EndIf

	//Tira o foco do shape em movimento
	::oTPanel:SetPosition(__nIdAux,0,0)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} HideImagesBox
Método que mostra ScrollBox contendo as imagens de acordo com a opcao
escolhida na biblioteca grafica

@param nLessOption Opcao da biblioteca para não ser escondida
@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Method HideImagesBox(nLessOption) Class TNGPG
	Local nOption

	For nOption := 1 To Len(::aImgBox)
		If nOption == nLessOption
			::aObjBox[nOption][__aObjBox_TScroll__]:Show()
		Else
			::aObjBox[nOption][__aObjBox_TScroll__]:Hide()
		EndIf
	Next nX

	::SelectImage()
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} SelectImage
Método que coloca ou retira foco sobre a imagem da biblioteca grafica
em Modo de Edicao

@param nOption Opção da biblioteca gráfica
@param nImage Imagem selecionada
@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Method SelectImage(nOption,nImage) Class TNGPG

	If ::lEditMode
		If ValType(::oImgAtu) == "O"
			::oImgAtu:nClrPane  := SetTransparentColor(CLR_WHITE,0)
			::oImgAtu := Nil
		EndIf

		If ValType(nOption) == "N" .And. ValType(nImage) == "N" .And. ::cImgAtu != ::aObjBox[nOption][2][nImage][__aObjBox_TBitmap__]:cBmpFile
			::oImgAtu := ::aObjBox[nOption][2][nImage][__aObjBox_TBitmap__]
			::oImgAtu:nClrPane  := SetTransparentColor(CLR_BLUE,30)
			::cImgAtu := ::oImgAtu:cBmpFile
			::cTipImg := ::aObjBox[nOption][2][nImage][__aObjBox_TipImg__]
			::SetCanMoveAll(.F.) //Desabilita CanMove de todos os Shapes na planta
		Else
			::cImgAtu := ""
			::cTipImg := ""
			::SetCanMoveAll(.T.) //Habilita CanMove de todos os Shapes na planta
		EndIf
	EndIf
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} LeftClicked
Método que adiciona imagens na planta ou atualiza posicao ao movimentar
shape pela planta pelo DragDrop

@param nPosX Posição em X para adicionar a imagem
@param nPosY nPosY Posição em Y para adicionar a imagem
@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Method LeftClicked(nPosX,nPosY) Class TNGPG
	Local nPosShape
	Local nShapeAtu
	Local nPosX, nPosY

	//Destroi com o FWBalloon
	::DestroyBalloon()
	//----------------------------------------------------------
	// atualza os campos que exibem a posição clicada na tela
	//----------------------------------------------------------
	::nPYShapeAtu := nPosY
	::nPXShapeAtu := nPosX

	::oPYShapeAtu:CtrlRefresh()
	::oPXShapeAtu:CtrlRefresh()

	If !Empty(::cImgAtu)
		::InsertImage(nPosX,nPosY,::cImgAtu,::cTipImg)
		::SelectImage()

		//Tira o foco do shape em movimento
		::oTPanel:SetPosition(__nIdAux,0,0)
	Else

		nShapeAtu := ::GetShapeAtu()
		nPosShape := ::GetPosShape(nShapeAtu)

		If nPosShape > 0
			If ::lEditMode
				If !::aShape[nPosShape][__aShape_Blocked__]
					If ::lIsMoving
						::lIsMoving := .F.

						nPosX := ::oTPanel:LeftAtu - (__nMovX - ::aShape[nPosShape][__aShape_PosX__])
						nPosY := ::oTPanel:TopAtu - (__nMovY - ::aShape[nPosShape][__aShape_PosY__])

						__nMovX := 0
						__nMovY := 0

						//---------------------------------------------
						// Valida se shape sairá completamente da tela
						//---------------------------------------------
						If nPosX + ::aShape[nPosShape][__aShape_Largura__] <= 0 .Or. ;
							nPosY + ::aShape[nPosShape][__aShape_Altura__] <= 0 .Or. ;
							nPosX >= ::oTPanel:nWidth .Or. ;
							nPosY >= ::oTPanel:nHeight
							//Modifica a localizacao
							::ModifyLocation(nPosShape)

							//Coloca Foco no shape selecionado
							::SetImageFocus(.T.,nShapeAtu)

							//Tira o foco do shape em movimento
							::oTPanel:SetPosition(__nIdAux,0,0)
							Return
						Else
							::aShape[nPosShape][__aShape_PosX__] := nPosX
							::aShape[nPosShape][__aShape_PosY__] := nPosY
						EndIf

						dbSelectArea(::cTrbTree)
						dbSetOrder(2)
						If dbSeek("001"+Substr(::aShape[nPosShape][__aShape_Cargo__],1,3)+cFilAnt)
							RecLock(::cTrbTree,.F.)
							(::cTrbTree)->POSX  := ::aShape[nPosShape][__aShape_PosX__]
							(::cTrbTree)->POSY  := ::aShape[nPosShape][__aShape_PosY__]
							(::cTrbTree)->ORDEM := ::SetMovement()
							MsUnLock(::cTrbTree)
							::aShape[nPosShape][__aShape_Movement__] := (::cTrbTree)->ORDEM

							If (::cTrbTree)->PLANTA != "1"
								::oTree:TreeSeek(::aShape[nPosShape][__aShape_Cargo__] )
							EndIf

						EndIf

						//Modifica a localizacao
						::ModifyLocation(nPosShape)

						//-----------------------------------------------------------------
						// Identifica que a planta teve alterações e necessita ser salva
						//-----------------------------------------------------------------
						::lModified := .T.

						//Coloca Foco no shape selecionado
						::SetImageFocus(.T.,nShapeAtu)

						//Tira o foco do shape em movimento
						::oTPanel:SetPosition(__nIdAux,0,0)
					Else

						__nMovX := ::oTPanel:LeftAtu
						__nMovY := ::oTPanel:TopAtu

						::lIsMoving := .T.

						::SetImageFocus(.F.)
					EndIf
				Else
					::SetImageFocus(.F.)
				EndIf
			Else
				//Seta item na arvore
				If !Empty(::aShape[nPosShape][__aShape_Cargo__])
					::SetOptionTree(::aShape[nPosShape][__aShape_Cargo__])
					::oTree:SetFocus()
					::CreateBalloon(nPosShape,nPosX,nPosY)
				EndIf
			EndIf
		Else

			If ::lEditMode
				If Len(::aImageFocus) > 0 .And. (nShapeAtu == ::aImageFocus[FOCUS_TOP_LEFT] .Or. ;
					nShapeAtu == ::aImageFocus[FOCUS_TOP_RIGHT] .Or. nShapeAtu == ::aImageFocus[FOCUS_BOTTOM_LEFT] .Or.;
					nShapeAtu == ::aImageFocus[FOCUS_BOTTOM_RIGHT])
					If ::lIsMoving
						::lIsMoving := .F.

						::ResizeFocus(nShapeAtu)

						//Coloca Foco no shape selecionado
						::SetImageFocus(.T.,::aImageFocus[FOCUS_SHAPE_DAD])

						//Tira o foco do shape em movimento
						::oTPanel:SetPosition(__nIdAux,0,0)
					Else
						::lIsMoving := .T.

					EndIf
				Else
					::lIsMoving := .F.
					::SetImageFocus(.F.)
				EndIf

			EndIf

		EndIf

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} CreateBalloon
Metodo que cria Balao informativo do Bem ou da Localizacao que foi
dado Foco

@param nPosShape Posicao do shape na array aShape
@param nPosX Posicao em X clicado na tela
@param nPosY Posicao em Y clicado na tela
@author Vitor Emanuel Batista
@since 15/11/2010
@version MP10
@return oBalloon Objeto FWBalloon
/*/
//---------------------------------------------------------------------
Method CreateBalloon(nPosShape,nPosX,nPosY) Class TNGPG
	Local nPosX, nPosY
	Local cTitle  := ""
	Local cDescri := ""
	Local nType   := 1
	Local nTamY   := 080
	Local nTamX   := 220

	//Destroi com o FWBalloon se ja estiver criado
	::DestroyBalloon()

	If nPosShape > 0 .And. nPosShape <= Len(::aShape)
		If ::aShape[nPosShape][__aShape_IndCod__] == "1"
			If __nModPG == 19
				NGIFDBSEEK("ST9",::aShape[nPosShape][__aShape_Codigo__],1)
				cTitle  := STR0048 //"Bem"
				cDescri := STR0386 + AllTrim(ST9->T9_CODBEM)+CRLF //"Codigo: "
				cDescri += STR0387 + AllTrim(ST9->T9_NOME)+CRLF //"Nome: "
				cDescri += STR0388 + AllTrim(ST9->T9_CODFAMI)+CRLF //"Família: "
				cDescri += STR0387 + AllTrim(NGSEEK("ST6",ST9->T9_CODFAMI,1,"T6_NOME"))+CRLF //"Nome: "
				If !Empty(ST9->T9_TIPMOD)
					cDescri += STR0389 + AllTrim(ST9->T9_TIPMOD)+CRLF //"Tipo Modelo: "
					cDescri += STR0390 + AllTrim(NGSEEK("TQR",ST9->T9_TIPMOD,1,"TQR_DESMOD"))+CRLF //"Descrição: "
					nTamY+=30
				EndIf
				cDescri += STR0391 + AllTrim(ST9->T9_CCUSTO)+CRLF //"Centro Custo: "
				cDescri += STR0390 + AllTrim(NGSEEK("CTT",ST9->T9_CCUSTO,1,"CTT_DESC01")) //"Descrição: "
				nTamY += 40
				If !Empty(ST9->T9_CENTRAB)
					cDescri += CRLF + STR0392 + AllTrim(ST9->T9_CENTRAB)+CRLF //"Centro Trab.: "
					cDescri += STR0390 + AllTrim(NGSEEK("SHB",ST9->T9_CENTRAB,1,"HB_NOME"))+CRLF //"Descrição: "
					nTamY+=30
				EndIf

			ElseIf __nModPG == 35
				NGIFDBSEEK("TN0",::aShape[nPosShape][__aShape_Codigo__],1)
				cTitle  := STR0414 //"Risco"
				cDescri := STR0386 + AllTrim(TN0->TN0_NUMRIS)+CRLF //"Codigo: "
				cDescri += STR0387 + AllTrim(NGSeek("TMA", TN0->TN0_AGENTE, 1, "TMA_NOMAGE") )+CRLF //"Nome: "
				cDescri += STR0415 + Alltrim(DTOC(TN0->TN0_DTAVAL))+CRLF//"Data Avaliação: "
				If NGSeek("TMA", TN0->TN0_NUMRIS, 1, "TMA_GRISCO") $ "123"
					cDescri += STR0416 + Alltrim(TN0->TN0_QTAGEN)+CRLF//"Quantidade: "
					nTamY += 10
				EndIf
				nTamY += 20
			EndIf
		ElseIf ::aShape[nPosShape][__aShape_IndCod__] == "2" .And. ::aShape[nPosShape][__aShape_Planta__] == "2"
			dbSelectArea(::cTrbTree)
			dbSetOrder(2)
			dbSeek("001"+Substr(::aShape[nPosShape][__aShape_Cargo__],1,3)+cFilAnt)
			cTitle  := STR0049 //"Localização"
			cDescri := STR0417 + AllTrim((::cTrbTree)->CODPRO)+CRLF //"Código: "
			cDescri += STR0387 + AllTrim((::cTrbTree)->DESCRI) //"Nome: "
			If !Empty((::cTrbTree)->RESPONS)
				cDescri += CRLF+ STR0393 + AllTrim((::cTrbTree)->RESPONS) //"Responsável: "
				cDescri += CRLF+ STR0387 + AllTrim(NGSEEK("QAA",(::cTrbTree)->RESPONS,1,"QAA->QAA_NOME")) //"Nome: "
				nTamY+=30
			EndIf
			If !Empty((::cTrbTree)->CC)
				cDescri += CRLF+STR0391 + AllTrim((::cTrbTree)->CC) //"Centro Custo: "
				cDescri += CRLF+STR0390 + AllTrim(NGSEEK("CTT",(::cTrbTree)->CC,1,"CTT->CTT_DESC01")) //"Descrição: "
				nTamY+=30
			EndIf
			If !Empty((::cTrbTree)->CENTRAB)
				cDescri += CRLF+STR0392 + AllTrim((::cTrbTree)->CENTRAB) //"Centro Trab.: "
				cDescri += CRLF+STR0390 + AllTrim(NGSEEK("SHB",(::cTrbTree)->CENTRAB,1,"SHB->HB_NOME")) //"Descrição: "
				nTamY+=30
			EndIf

		ElseIf ::aShape[nPosShape][__aShape_IndCod__] == "A"
			NGIFDBSEEK("TAX",AllTrim(::aShape[nPosShape][__aShape_Codigo__]),1)
			cTitle  := STR0455 //"Resíduo"
			cDescri := STR0386 + AllTrim(TAX->TAX_CODRES)+CRLF //"Codigo: "
			cDescri += STR0387 + AllTrim(NGSeek("SB1",TAX->TAX_CODRES,1,"SB1->B1_DESC"))+CRLF //"Nome: "
			cDescri += STR0456 + AllTrim(NGSeek("TCS",TAX->TAX_CLASSE,1,"TCS->TCS_DESCRI"))+CRLF  //"Classe: "
			cDescri += STR0457 + X3Combo("TAX_ESTADO", TAX->TAX_ESTADO)+CRLF //"Estado: "
			cDescri += STR0458 + X3Combo("TAX_TPGERA", TAX->TAX_TPGERA) //"Tp. Ger: "

			nTamY += 40

		ElseIf ::aShape[nPosShape][__aShape_IndCod__] == "B"
			NGIFDBSEEK("TA4",AllTrim(::aShape[nPosShape][__aShape_Codigo__]),1)
			cTitle  := STR0459 //"Aspecto"
			cDescri := STR0386 + AllTrim(TA4->TA4_CODASP)+CRLF //"Codigo: "
			cDescri += STR0387 + AllTrim(TA4->TA4_DESCRI)+CRLF //"Nome: "

			nTamY += 40

		ElseIf ::aShape[nPosShape][__aShape_IndCod__] == "C"
			NGIFDBSEEK("TDB",::aShape[nPosShape][__aShape_NivSup__]+AllTrim(::aShape[nPosShape][__aShape_Codigo__]),1)
			cTitle  := STR0460 //"Ponto Coleta"
			cDescri := STR0386 + AllTrim(TDB->TDB_CODIGO)+CRLF //"Codigo: "
			cDescri += STR0461 + AllTrim(TDB->TDB_DESCRI)+CRLF //"Descrição: "

			nTamY += 40

		EndIf

		//Posicoes na tela
		//------------
		//|1   2    3|
		//|4   5    6|
		//|7   8    9|
		//------------

		If !Empty(cTitle) .And. !Empty(cDescri)
			If nPosY-nTamY < 0 .And. nPosX-200 < 0 //1
				nType := BALLOON_POS_LEFT_TOP
				nPosY -= 20
			ElseIf nPosY+nTamY <= Self:oTPanel:nHeight .And. nPosX-nTamX < 0 //4
				nType := BALLOON_POS_LEFT_MIDDLE
				nPosY -= nTamY/2
			ElseIf nPosY+nTamY > Self:oTPanel:nHeight .And. nPosX-200 < 0 //7
				nType := BALLOON_POS_LEFT_BOTTOM
				nPosY -= nTamY-30
			ElseIf nPosY+nTamY > Self:oTPanel:nHeight // 8 e 9
				nTamY+=60
				nType := BALLOON_POS_BOTTOM_RIGTH
				nPosX -= nTamX-30
				nPosY -= nTamY
			Else //If nPosY-nTamY > 0 .And. nPosX+nTamX < Self:oTPanel:nWidth //3
				nType := BALLOON_POS_RIGTH_TOP
				nPosX -= 220
				nPosY -= 20
			EndIf

			::oBalloon := FWBalloon():New(nPosY,nPosX,nTamX,nTamY,Self:oTPanel,cTitle,cDescri,FW_BALLOON_INFORMATION,nType)
		EndIf

	EndIf

Return ::oBalloon

//---------------------------------------------------------------------
/*/{Protheus.doc} DestroyBalloon
Metodo que destroi Balao informativo

@author Vitor Emanuel Batista
@since 15/11/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Method DestroyBalloon() Class TNGPG

	If ValType(::oBalloon) == "O"
		::oBalloon:Close()
	EndIf

Return


//---------------------------------------------------------------------
/*/{Protheus.doc} ModifyLocation
Método que atualiza a localizacao do Shape e do Tree

@param nPosShape Posicao do shape na array aShape
@author Vitor Emanuel Batista
@since 05/05/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Method ModifyLocation(nPosShape) Class TNGPG

	Local nPosX   := ::aShape[nPosShape][__aShape_PosX__]
	Local nPosY   := ::aShape[nPosShape][__aShape_PosY__]
	Local nShapeAtu := ::aShape[nPosShape][__aShape_IdShape__]
	Local cCargo  := ::aShape[nPosShape][__aShape_Cargo__]
	Local cDescri := ::aShape[nPosShape][__aShape_Descri__]
	Local cPlanta := ::aShape[nPosShape][__aShape_PlanSup__]
	Local cNivSup := ::GetNivSup(nPosX,nPosY,nShapeAtu)
	Local nPosShpSup

	If __nModPG == 35 .And. Substr(cCargo,4,3) == "RIS"
		dbSelectArea(::cTrbTree)
		dbSetOrder(2)
		dbSeek("001"+Substr(cCargo,1,3)+cFilAnt)
		cNivSup := (::cTrbTree)->NIVSUP
	EndIf

	If Substr(::aShape[nPosShape][__aShape_Cargo__] ,1,3) != "001"

		//Seta posicao para o Shape
		::oTPanel:SetPosition(nShapeAtu,::aShape[nPosShape][__aShape_PosX__],::aShape[nPosShape][__aShape_PosY__] )

		::aShape[nPosShape][__aShape_Movement__] := ::SetMovement()
		dbSelectArea(::cTrbTree)
		dbSetOrder(2)
		If dbSeek("001"+Substr(cCargo,1,3)+cFilAnt)
			RecLock(::cTrbTree,.F.)
			(::cTrbTree)->PGSUP  := cPlanta
			(::cTrbTree)->NIVSUP := Substr(cNivSup,1,3)
			(::cTrbTree)->POSX   := nPosX
			(::cTrbTree)->POSY   := nPosY
			(::cTrbTree)->ORDEM  := ::aShape[nPosShape][__aShape_Movement__]
			MsUnLock(::cTrbTree)
		EndIf

		//Se Item foi alterado de localizacao (Nivel Superior)
		If ::aShape[nPosShape][__aShape_NivSup__] != Substr(cNivSup,1,3)
			::aShape[nPosShape][__aShape_NivSup__] := Substr(cNivSup,1,3)

			If ::oTree:TreeSeek(cCargo)
				::oTree:DelItem()
				If ::oTree:TreeSeek(cNivSup)
					//-------------------------------------------
					// Faz bloqueio da movimentação do shape pai
					//-------------------------------------------
					nPosShpSup := aScan(::aShape,{|aShape| aShape[__aShape_Cargo__] == cNivSup})
					If nPosShpSup > 0
						::aShape[nPosShpSup][__aShape_Blocked__] := .T.
						::oTPanel:SetCanMove(::aShape[nPosShpSup][__aShape_IdShape__],.F.)
					EndIf

					If	::aShape[nPosShape][__aShape_IndCod__] == "0" // Ilustração
						::oTree:AddItem(cDescri,cCargo,'ico_planta_ilustracao.png','ico_planta_ilustracao.png',,, 2)
					ElseIf ::aShape[nPosShape][__aShape_IndCod__] == "1"
						If __nModPG == 19
							::oTree:AddItem(cDescri,cCargo,"ENGRENAGEM","ENGRENAGEM",,,2)
						ElseIf __nModPG == 35
							::oTree:AddItem(cDescri,cCargo,"ng_ico_ris_planta","ng_ico_ris_planta",,,2)
						ElseIf __nModPG == 56
							If ::aShape[nPosShape][__aShape_IndCod__] == "A"// Resíduo
								::oTree:AddItem(cDescri,cCargo,"NG_ICO_RESIDUO","NG_ICO_RESIDUO",,,2)
							ElseIf ::aShape[nPosShape][__aShape_IndCod__] == "B" // Aspecto
								::oTree:AddItem(cDescri,cCargo,"NG_ICO_ASPECTO","NG_ICO_ASPECTO",,,2)
							ElseIf ::aShape[nPosShape][__aShape_IndCod__] == "C" // Aspecto
								::oTree:AddItem(cDescri,cCargo,"NG_ICO_PCOLETA","NG_ICO_PCOLETA",,,2)
							EndIf
						EndIf
					ElseIf ::aShape[nPosShape][__aShape_IndCod__] == "2" // Localização
						If ::aShape[nPosShape][__aShape_Planta__] == "1" //Planta
							::oTree:AddItem(cDescri,cCargo,'ico_planta_fecha','ico_planta_abre',,, 2)
						Else
							::oTree:AddItem(cDescri,cCargo,'ico_planta_local','ico_planta_local',,, 2)
						EndIf
					EndIf
				EndIf
			EndIf
			::oTree:TreeSeek(cCargo)
			::oTree:SetFocus()
		EndIf
	EndIf

	//Tira o foco do shape em movimento
	::oTPanel:SetPosition(__nIdAux,0,0)
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} RightClicked
Método que ativa Menu PopUp sobre o shape selecionado

@param nPosX Posicao em X clicado na tela
@param nPosY Posicao em Y clicado na tela
@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Method RightClicked(nPosX,nPosY) Class TNGPG
	Local nPosShape := 0, i
	Local lActive   := .T.
	Local aCaract := {}

	::lIsMoving := .F.

	If !Empty(::cImgAtu)
		::SelectImage()
	Else
		nPosShape := ::GetPosShape(::GetShapeAtu())
	EndIf

		//Destroi com o FWBalloon no modo visualizacao
	If !::lEditMode
		::DestroyBalloon()
	EndIf

		//Tira o foco do shape em movimento
	::oTPanel:SetPosition(__nIdAux,0,0)

		//Seta foco em outro objeto para a atualizacao do When dos cliques
	::oSplitter:SetFocus()

	If nPosShape > 0 .And. ::aShape[nPosShape][__aShape_Permit__]
			//Seta item na arvore
		If !Empty(::aShape[nPosShape][__aShape_Cargo__])

			::cCargoAtu := ::aShape[nPosShape][__aShape_Cargo__]
			::oTree:TreeSeek(::cCargoAtu)
			::oTree:SetFocus()

			If !::lEditMode
				dbSelectArea("TAF")
				dbSetOrder(2)
				dbSeek(xFilial("TAF")+'001'+Substr(::aShape[nPosShape][__aShape_Cargo__],1,3))

				If ::aShape[nPosShape][__aShape_IndCod__] == "1"

					If __nModPG == 19//Bem

						dbSelectArea("ST9")
						dbSetOrder(1)
						dbSeek(xFilial("ST9")+::aShape[nPosShape][__aShape_Codigo__])
											
						For i:=1 to Len(::aMenuPopUp[__aMenuPopUp_Bem__])
								
							lActive := MNT902REST( ST9->T9_CODBEM, ::aMenuPopUp[__aMenuPopUp_Bem__][i][__aMenuPopUp_Tipo__],;
								::aMenuPopUp[__aMenuPopUp_Bem__][i][__aMenuPopUp_Operacao__], .F., .F. )

							::aMenuPopUp[__aMenuPopUp_Bem__][i][__aMenuPopUp_Objeto__]:lActive := lActive

						Next i
						
						::oMenuBem:Activate(nPosX,nPosY,::oTPanel)

					ElseIf __nModPG == 35 //Risco
						dbSelectArea("TN0")
						dbSetOrder(1)
						dbSeek(xFilial("TN0")+::aShape[nPosShape][__aShape_Codigo__])
						::oMenuRis:Activate(nPosX,nPosY,::oTPanel)
					EndIf
				ElseIf ::aShape[nPosShape][__aShape_IndCod__] == "2"

					For i:=1 to Len(::aMenuPopUp[__aMenuPopUp_Loc__])
							
						lActive := MNT902REST( SubStr( ::cCargoAtu, 1, 3 ), ::aMenuPopUp[__aMenuPopUp_Loc__][i][__aMenuPopUp_Tipo__],;
							::aMenuPopUp[__aMenuPopUp_Loc__][i][__aMenuPopUp_Operacao__], .F. )

						::aMenuPopUp[__aMenuPopUp_Loc__][i][__aMenuPopUp_Objeto__]:lActive := lActive

					Next i

					::oMenuLoc:Activate(nPosX,nPosY,::oTPanel)

				ElseIf ::aShape[nPosShape][__aShape_IndCod__] == "A" // Residuo

					If Len(::aShape[nPosShape][__aShape_Caract__]) > 0
						aCaract := ::aShape[nPosShape][__aShape_Caract__]
					Else
						aCaract := {""}
					Endif

					dbSelectArea("TAX")
					dbSetOrder(1)
					dbSeek(xFilial("TAX")+::aShape[nPosShape][__aShape_Codigo__])

					dbSelectArea("TAV")
					dbSetOrder(1) // TAV_FILIAL+TAV_CODRES+TAV_CODEST+TAV_CODNIV+TAV_SEQUEN
					dbSeek(xFilial("TAV") + Padr(::aShape[nPosShape][__aShape_Codigo__], Len(TAV->TAV_CODRES)) + "001" + ::aShape[nPosShape][__aShape_NivSup__] + aCaract[1] )

					::oMenuRes:Activate(nPosX,nPosY,::oTPanel)

				ElseIf ::aShape[nPosShape][__aShape_IndCod__] == "B" // Aspecto

					If Len(::aShape[nPosShape][__aShape_Caract__]) > 0
						aCaract := ::aShape[nPosShape][__aShape_Caract__]
					Else
						aCaract := {""}
					Endif

					dbSelectArea("TA4")
					dbSetOrder(1)
					dbSeek(xFilial("TA4")+AllTrim(::aShape[nPosShape][__aShape_Codigo__]))

					dbSelectArea("TAG")
					dbSetOrder(1) // TAG_FILIAL+TAG_CODASP+TAG_CODEST+TAG_CODNIV+TAG_SEQUEN
					dbSeek(xFilial("TAG") + Padr(::aShape[nPosShape][__aShape_Codigo__], Len(TAG->TAG_CODASP)) + "001" + ::aShape[nPosShape][__aShape_NivSup__] + aCaract[1] )

					::oMenuAsp:Activate(nPosX,nPosY,::oTPanel)

				ElseIf ::aShape[nPosShape][__aShape_IndCod__] == "C" // Ponto de Coleta

					dbSelectArea("TDB")
					dbSetOrder(1)
					dbSeek(xFilial("TDB")+::aShape[nPosShape][__aShape_NivSup__]+ Padr(::aShape[nPosShape][__aShape_Codigo__],Len(TDB->TDB_CODIGO)))

					::oMenuPto:Activate(nPosX,nPosY,::oTPanel)

				EndIf

			Else

				If ::aShape[nPosShape][__aShape_IndCod__] == "1" .And. __nModPG == 35 //MDT - Risco
					dbSelectArea("TN0")
					dbSetOrder(1)
					dbSeek(xFilial("TN0")+::aShape[nPosShape][__aShape_Codigo__])
					::oMenuRis:Activate(nPosX,nPosY,::oTPanel)
				Else
					/*
					Adicionado verificação de habilitar o recortar/colar imagem
					pois o bloque de código bWhen da classe não é executado
					caso mude as posições dos botões favor verificar validação abaixo
					*/
					If Substr(::cCargoAtu,4,3) != "LOC" .And. Substr(::cCargoAtu,4,3) != "RIS"
						::oMenuShape:aItems[1]:lActive := .T.
					EndIf

					::oMenuShape:nLeft  := nPosX
					::oMenuShape:nRight:= nPosY
					::oMenuShape:Activate(nPosX,nPosY,::oTPanel)
				EndIf
			EndIf

		EndIf

	Else
		If ::lEditMode
			::cCargoAtu := ::cPlantaAtu
			::oTree:TreeSeek(::cCargoAtu)
			::oTree:SetFocus()

			/*
			Adicionado verificação de habilitar o recortar/colar imagem
			pois o bloque de código bWhen da classe não é executado
			caso mude as posições dos botões favor verificar validação abaixo
			*/

			If ValType(::nCutShape)=="N"
				::oMenuPg:aItems[1]:lActive := .T.
			EndIf

			::oMenuPg:nLeft  := nPosX
			::oMenuPg:nRight:= nPosY
			::oMenuPg:Activate(nPosX,nPosY,::oTPanel)
		EndIf
	EndIf


Return

//---------------------------------------------------------------------
/*/{Protheus.doc} ActiveClickTree
Método que ativa Menu PopUp para o item selecionado na Arvore

@param oTree Objeto Tree clicado
@param nPosX Posicao em X clicado no Tree
@param nPosY Posicao em Y clicado no Tree
@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Method ActiveClickTree(oTree,nPosX,nPosY) Class TNGPG

	Local i
	Local lActive	:= .T.
	Local cCargo 	:= oTree:GetCargo()
	Local cTipo  	:= Substr(oTree:GetCargo(),4,3)
	Local aCaract 	:= {}

	If cTipo == "LOC"
		If !::lEditMode
			dbSelectArea("TAF")
			dbSetOrder(2)
			dbSeek(xFilial("TAF")+'001'+SubStr(cCargo,1,3))
		EndIf
			
		For i:=1 to Len(::aMenuPopUp[__aMenuPopUp_Loc__])
				
			lActive := MNT902REST( SubStr( cCargo, 1, 3 ), ::aMenuPopUp[__aMenuPopUp_Loc__][i][__aMenuPopUp_Tipo__],;
				::aMenuPopUp[__aMenuPopUp_Loc__][i][__aMenuPopUp_Operacao__], .F. )

			::aMenuPopUp[__aMenuPopUp_Loc__][i][__aMenuPopUp_Objeto__]:lActive := lActive

		Next i

		If __nModPG <> 35 .Or. ::lEditMode
			::oMenuLoc:Activate(nPosX-30,nPosY-115,Self)
		EndIf

	ElseIf cTipo == "BEM"

		nPosShape := aScan(::aShape,{|aShape| aShape[__aShape_Cargo__] == cCargo})
		If nPosShape > 0
			::oTPanel:ShapeAtu := ::aShape[nPosShape][__aShape_IdShape__]
			If !::lEditMode
				dbSelectArea("ST9")
				dbSetOrder(1)
				dbSeek(xFilial("ST9")+::aShape[nPosShape][__aShape_Codigo__])

				dbSelectArea("TAF")
				dbSetOrder(2)
				dbSeek(xFilial("TAF")+'001'+Substr(::aShape[nPosShape][__aShape_Cargo__],1,3))

			EndIf

			For i:=1 to Len(::aMenuPopUp[__aMenuPopUp_Bem__])
					
				lActive := MNT902REST( ::aShape[nPosShape,__aShape_Codigo__], ::aMenuPopUp[__aMenuPopUp_Bem__][i][__aMenuPopUp_Tipo__],;
					::aMenuPopUp[__aMenuPopUp_Bem__][i][__aMenuPopUp_Operacao__], .F., .F. )

				::aMenuPopUp[__aMenuPopUp_Bem__][i][__aMenuPopUp_Objeto__]:lActive := lActive

			Next i

			::oMenuBem:Activate(nPosX-30,nPosY-115,Self)

		EndIf

	ElseIf cTipo == "RIS"

		nPosShape := aScan(::aShape,{|aShape| aShape[__aShape_Cargo__] == cCargo})
		If nPosShape > 0
			::oTPanel:ShapeAtu := ::aShape[nPosShape][__aShape_IdShape__]
			If !::lEditMode
				dbSelectArea("TN0")
				dbSetOrder(1)
				dbSeek(xFilial("TN0")+::aShape[nPosShape][__aShape_Codigo__])

				dbSelectArea("TAF")
				dbSetOrder(2)
				dbSeek(xFilial("TAF")+'001'+Substr(::aShape[nPosShape][__aShape_Cargo__],1,3))

			EndIf
		Else
			dbSelectArea("TAF")
			dbSetOrder(2)
			dbSeek(xFilial("TAF")+'001'+Substr(cCargo,1,3))

			dbSelectArea("TN0")
			dbSetOrder(1)
			dbSeek(xFilial("TN0")+PADR( TAF->TAF_CODCON, Len( TN0->TN0_NUMRIS ) ) )

		EndIf
		::oMenuRis:Refresh()
		::oMenuRis:Activate(nPosX-30,nPosY-115,Self)

	ElseIf cTipo == "FUN"

		If ::lEditMode
			::oMenuFun:Activate(nPosX-30,nPosY-115,Self)
		EndIf

	ElseIf cTipo == "TAR"

		If ::lEditMode
			::oMenuTar:Activate(nPosX-30,nPosY-115,Self)
		EndIf

	ElseIf cTipo == "ILU"

		If ::lEditMode
			nPosShape := aScan(::aShape,{|aShape| aShape[__aShape_Cargo__] == cCargo})
			If nPosShape > 0
				::oTPanel:ShapeAtu := ::aShape[nPosShape][__aShape_IdShape__]
				::oMenuIlu:Activate(nPosX-30,nPosY-115,Self)
			EndIf
		EndIf

	ElseIf cTipo == "RES"

		dbSelectArea(::cTrbTree)
		dbSetOrder(2)
		If dbSeek('001'+Substr(cCargo,1,3)+cFilAnt)

			dbSelectArea("TAX")
			dbSetOrder(1)
			dbSeek(xFilial("TAX")+AllTrim((::cTrbTree)->CODTIPO))

			dbSelectArea("TAV")
			dbSetOrder(1)
			dbSeek(xFilial("TAV") + Padr(TAX->TAX_CODRES, Len(TAV->TAV_CODRES)) + "001" + (::cTrbTree)->NIVSUP + AllTrim((::cTrbTree)->SEQUEN) )

			If ( nPosShape := aScan(::aShape,{|aShape| aShape[__aShape_Cargo__] == cCargo}) ) > 0
				::oTPanel:ShapeAtu := ::aShape[nPosShape][__aShape_IdShape__]
			Endif

			If ::lEditMode
				For i := 1 to Len(::aMenuPopUp[__aMenuPopUp_Res__])
					::aMenuPopUp[__aMenuPopUp_Res__][i][__aMenuPopUp_Objeto__]:lActive := ( nPosShape > 0 )
				Next i
			Else
				lActive := SgUserFmr(TAV->TAV_CODNIV)
				For i := 1 to Len(::aMenuPopUp[__aMenuPopUp_Res__])
					::aMenuPopUp[__aMenuPopUp_Res__][i][__aMenuPopUp_Objeto__]:lActive := lActive
				Next i
			Endif

			::oMenuRes:Activate(nPosX-30,nPosY-115,Self)

		Endif

	ElseIf cTipo == "ASP"

		dbSelectArea(::cTrbTree)
		dbSetOrder(2)
		If dbSeek('001'+Substr(cCargo,1,3)+cFilAnt)

			dbSelectArea("TA4")
			dbSetOrder(1)
			dbSeek(xFilial("TA4")+AllTrim((::cTrbTree)->CODTIPO))

			dbSelectArea("TAG")
			dbSetOrder(1)
			dbSeek(xFilial("TAG") + Padr(TA4->TA4_CODASP, Len(TAG->TAG_CODASP)) + "001" + (::cTrbTree)->NIVSUP + AllTrim((::cTrbTree)->SEQUEN) )

			If ::lEditMode
				If ( nPosShape := aScan(::aShape,{|aShape| aShape[__aShape_Cargo__] == cCargo}) ) > 0
					::oTPanel:ShapeAtu := ::aShape[nPosShape][__aShape_IdShape__]
				Endif

			For i := 1 to Len(::aMenuPopUp[__aMenuPopUp_Asp__])
					::aMenuPopUp[__aMenuPopUp_Asp__][i][__aMenuPopUp_Objeto__]:lActive := ( nPosShape > 0 )
			Next i

			EndIf
			::oMenuAsp:Activate(nPosX-30,nPosY-115,Self)

		Endif

	ElseIf cTipo == "PTO"

		dbSelectArea(::cTrbTree)
		dbSetOrder(2)
		If dbSeek('001'+Substr(cCargo,1,3)+cFilAnt)

			dbSelectArea("TDB")
			dbSetOrder(1)
			dbSeek(xFilial("TDB") + AllTrim((::cTrbTree)->NIVSUP) + AllTrim((::cTrbTree)->CODTIPO))

			If !::lEditMode
				lActive := SgUserFmr(TDB->TDB_DEPTO)
			For i := 1 to Len(::aMenuPopUp[__aMenuPopUp_Pto__])
					::aMenuPopUp[__aMenuPopUp_Pto__][i][__aMenuPopUp_Objeto__]:lActive := lActive
			Next i
			Else
				If ( nPosShape := aScan(::aShape,{|aShape| aShape[__aShape_Cargo__] == cCargo}) ) > 0
					::oTPanel:ShapeAtu := ::aShape[nPosShape][__aShape_IdShape__]
				Endif

				For i := 1 to Len(::aMenuPopUp[__aMenuPopUp_Asp__])
						::aMenuPopUp[__aMenuPopUp_Asp__][i][__aMenuPopUp_Objeto__]:lActive := ( nPosShape > 0 )
				Next i
			EndIf

			::oMenuPto:Activate(nPosX-30,nPosY-115,Self)

		Endif

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} CutShape
Método que recorta shape, habilitando a opcao PasteShape

@param nShapeAtu Id do shape a ser cortado
@author Vitor Emanuel Batista
@since 10/05/2010
@version MP10
@return Nil
@obs Opcao disponivel somente para ShapeAtu de Ilustracao e Bem
/*/
//---------------------------------------------------------------------
Method CutShape(nShapeAtu) Class TNGPG
	Local nPosShape

	Default nShapeAtu := ::GetShapeAtu()

	nPosShape := ::GetPosShape(nShapeAtu)

	If nPosShape > 0
		::nCutShape := nPosShape
	EndIf
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} PasteShape
Método que cola shape recortado, possibilitando ao item recortado ser
movimentado entre plantas ou localizacoes diferentes

@param nPosX Posicao em X para ser colado o shape
@param nPosY Posicao em Y para ser colado o shape
@author Vitor Emanuel Batista
@since 10/05/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Method PasteShape(nPosX,nPosY) Class TNGPG
	Local nPosShape

	If ValType(::nCutShape) == "N"
		nPosShape := ::nCutShape

		::aShape[nPosShape][__aShape_PosX__]    := nPosX
		::aShape[nPosShape][__aShape_PosY__]    := nPosY
		::aShape[nPosShape][__aShape_PlanSup__] := ::cPlantaAtu

		//Modifica a localizacao
		::ModifyLocation(nPosShape)
		::oTPanel:SetVisible(::aShape[nPosShape][__aShape_IdShape__],.T.)

		//Coloca Foco no shape selecionado
		::SetImageFocus(.T.,::aShape[nPosShape][__aShape_IdShape__])

		::nCutShape := Nil
	EndIf
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} DeleteShape
Método que exclui shape especifico na planta, de acordo com o ShapeAtu

@param nShapeAtu Id do shape a ser excluido
@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Method DeleteShape(nShapeAtu, lShape) Class TNGPG

	Local nPosShape
	Local cCargo
	Local cTipo
	Local lDelTree := .F.

	Default nShapeAtu := ::GetShapeAtu()
	Default lShape    := .T.

	nPosShape := ::GetPosShape(nShapeAtu)

	If nPosShape > 0 .Or. !lShape

		If lShape
			cCargo := ::aShape[nPosShape][__aShape_Cargo__]
			cTipo  := ::aShape[nPosShape][__aShape_IndCod__]
		Else
			cCargo := ::oTree:GetCargo()
			cTipo  := SubStr( cCargo , 4, 3 )
		EndIf

		::oTPanel:DeleteItem(nShapeAtu) //Deleta a imagem do Shape

		If !Empty(cCargo) .And. ::oTree:TreeSeek(cCargo)

			If cTipo == "0" .Or. MsgYesNo(STR0013) //"Deseja excluir item da Árvore também?"
				lDelTree := ::DeleteItem()
			ElseIf ( cTipo == "1" .Or. cTipo == "RIS" ) .And. __nModPG == 35
				::oTree:ChangeBmp( "ng_ico_risco","ng_ico_risco","ng_ico_risco","ng_ico_risco",cCargo )
			ElseIf ( cTipo == "A" .Or. cTipo == "RES" )
				::oTree:ChangeBmp( "NG_ICO_RESIDUO","NG_ICO_RESIDUO","NG_ICO_RESIDUO","NG_ICO_RESIDUO",cCargo )
			ElseIf ( cTipo == "B" .Or. cTipo == "ASP" )
				::oTree:ChangeBmp( "NG_ICO_ASPECTO","NG_ICO_ASPECTO","NG_ICO_ASPECTO","NG_ICO_ASPECTO",cCargo )
			ElseIf ( cTipo == "C" .Or. cTipo == "PTO" )
				::oTree:ChangeBmp( "NG_ICO_PCOLETA","NG_ICO_PCOLETA","NG_ICO_PCOLETA","NG_ICO_PCOLETA",cCargo )
			ElseIf cTipo == "1" .And. __nModPG <> 35 .And. __nModPG <> 56
				::oTree:ChangeBmp( 'ENGRENAGEM', 'ENGRENAGEM', 'ENGRENAGEM', 'ENGRENAGEM', cCargo )
			EndIf

			//----------------------------------------
			// Se estiver excluindo o Shape recortado
			//----------------------------------------
			If nPosShape == ::nCutShape
				::nCutShape := Nil
			EndIf

			If !lDelTree
				cCargo  := ::oTree:GetCargo()
				If !Empty(cCargo)
					dbSelectArea(::cTrbTree)
					dbSetOrder(2)
					dbSeek('001'+Substr(cCargo,1,3)+cFilAnt)
					If Found()
						RecLock(::cTrbTree,.F.)
						(::cTrbTree)->TIPIMG  := ""
						(::cTrbTree)->IMAGEM  := ""
						(::cTrbTree)->POSX    := 0
						(::cTrbTree)->POSY    := 0
						(::cTrbTree)->TAMX    := 0
						(::cTrbTree)->TAMY    := 0
						(::cTrbTree)->MOVBLO  := "2"
						MsUnLock(::cTrbTree)
					EndIf
				EndIf
				If nPosShape > 0
					aDel( ::aShape, nPosShape )
					aSize( ::aShape, Len( ::aShape ) - 1 )
				EndIf
			EndIf
		EndIf

		//-----------------------------------------------------------------
		// Identifica que a planta teve alterações e necessita ser salva
		//-----------------------------------------------------------------
		::lModified := .T.

	EndIf

	//Tira Foco do shape selecionado
	::SetImageFocus(.F.)
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} CreateMenu
Método que cria Menu PopUp para o Modo Edicao e Visualizacao

@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Method CreateMenu() Class TNGPG

	Local oOS,oSS, oMan, oPaste, oMove
	Local oIncLoc, oAltLoc, oExcLoc
	Local oOSCor, oOSPre, oOSLib, oOSRet, oFmr, oFmrPI, oFmrRI
	Local oSSInc, oSSDis, oSSFin, oSSSat, oAsp, oFmrPto
	Local oOSCorL, oOSLibL, oOSRetL
	Local oSSIncL, oSSDisL, oSSFinL, oSSSatL
	Local oOCR, oFmrR, oDesemp, oFmrP
	Local oResL, oFmrL, oDesempL

	Local nX, cRes, cLoc, cDeptoTNG
	Local oResPp, oAspPp, oPtoPp
	Local aSMenu := {}
	Local cDepto	:= Space(Len(TAF->TAF_CODNIV))
	Local lFacilit := FindFunction("MNTINTFAC") .and. MNTINTFAC()

	If ::lEditMode

		Menu ::oMenuShape PopUp Of Self
			If __nModPG <> 56
				MenuItem oMove Prompt STR0014 Of ::oMenuShape Action ::CutShape() Resource "RECORTAR" //"Recortar"
					oMove:bWhen  := {|| Substr(::cCargoAtu,4,3) != "LOC" .And. Substr(::cCargoAtu,4,3) != "RIS"}
				MenuItem oPaste Prompt STR0015 Of ::oMenuShape Action ::PasteShape(::oMenuShape:nLeft,::oMenuShape:nRight) Resource "S4WB007N" //"Colar"
					oPaste:bWhen := {|| ValType(::nCutShape)=="N"}
			Endif
			MenuItem STR0016 + STR0412 Of ::oMenuShape Action (::SetBlackPnl(.T.),If(MsgYesNo(STR0017),::DeleteShape(),Nil),::SetBlackPnl(.F.)) Resource "CANCEL" //"Excluir"###"Tem certeza de que deseja excluir este item?"
			//MenuItem "Enviar para Trás"		Of ::oMenuShape Action ::SendBack() When .F.
			MenuItem STR0018				Of ::oMenuShape Action ::PropertyShape() //"Propriedades"
		EndMenu

		Menu ::oMenuPg PopUp Of Self
			If __nModPG <> 56
				MenuItem oPaste Prompt STR0015 Of ::oMenuPg Action ::PasteShape(::oMenuPg:nLeft,::oMenuPg:nRight) Resource "S4WB007N" //"Colar"
					oPaste:bWhen := {|| ValType(::nCutShape)=="N"}
			Endif
		EndMenu

		Menu ::oMenuLoc PopUp of Self
			MenuItem oIncLoc Prompt STR0019 Of ::oMenuLoc Action ::InsertLocTree() Resource "BMPINCLUIR" //"Incluir Localização"
			MenuItem oAltLoc Prompt STR0020 Of ::oMenuLoc Action ::AlterLocTree() Resource "BPMSDOCA" //"Alterar Localização"
			MenuItem oExcLoc Prompt STR0021 Of ::oMenuLoc Action (::SetBlackPnl(.T.),If(MsgYesNo(STR0022+AllTrim(::oTree:GetPrompt())),::DeleteItem(),Nil),::SetBlackPnl(.F.)) Resource "BPMSDOCE" //"Excluir Localização"###"Deseja realmente deletar a Localização: "

			If __nModPG == 35
				MenuItem Replicate("_",22) DISABLED Of ::oMenuLoc
				MenuItem STR0418 Of ::oMenuLoc Action ::OperFunTar( 3 , "FUN" ) Resource "ng_ico_incfun2" //"Incluir Função"
				MenuItem STR0419 Of ::oMenuLoc Action ::OperFunTar( 3 , "TAR" ) Resource "ng_ico_inctar2" //"Incluir Tarefa"
				MenuItem STR0420 Of ::oMenuLoc Action ::OperRisTree(3) Resource "ng_ico_incris2" //"Incluir Risco"
			EndIf

		EndMenu

		Menu ::oMenuIlu PopUp Of Self
			MenuItem STR0016 Of ::oMenuIlu Action (::SetBlackPnl(.T.),If(MsgYesNo(STR0017),::DeleteItem(),Nil),::SetBlackPnl(.F.))  Resource "CANCEL" //"Excluir"##"Tem certeza de que deseja excluir este item?"
			MenuItem STR0018 Of ::oMenuIlu Action ::PropertyShape() //"Propriedades"
		EndMenu

		If __nModPG == 19
			Menu ::oMenuBem PopUp Of Self
				MenuItem STR0016 Of ::oMenuBem Action (::SetBlackPnl(.T.),If(MsgYesNo(STR0017),::DeleteItem(),Nil),::SetBlackPnl(.F.)) Resource "CANCEL"//"Excluir"##"Tem certeza de que deseja excluir este item?"
				MenuItem STR0018 Of ::oMenuBem Action ::PropertyShape() //"Propriedades"
			EndMenu

		ElseIf __nModPG == 35

			//Função
			Menu ::oMenuFun PopUp Of Self
				MenuItem STR0421 Of ::oMenuFun Action ::OperFunTar( 4 , "FUN" ) Resource "ng_ico_altfun2" //"Alterar Função"
				MenuItem STR0424 Of ::oMenuFun Action ::OperFunTar( 5 , "FUN" ) Resource "ng_ico_altfun2" //"Excluir Função"
				MenuItem STR0419 Of ::oMenuFun Action ::OperFunTar( 3 , "TAR" ) Resource "ng_ico_inctar2" //"Incluir Tarefa"
				MenuItem STR0420 Of ::oMenuFun Action ::OperRisTree( 3 ) Resource "ng_ico_incris2" //"Visualizar Risco"
			EndMenu

			//Tarefa
			Menu ::oMenuTar PopUp Of Self
				MenuItem STR0422 Of ::oMenuTar Action ::OperFunTar( 4 , "TAR" ) Resource "ng_ico_alttar2" //"Alterar Tarefa"
				MenuItem STR0425 Of ::oMenuTar Action ::OperFunTar( 5 , "TAR" ) Resource "ng_ico_exctar2" //"Excluir Tarefa"
				MenuItem STR0420 Of ::oMenuTar Action ::OperRisTree( 3 ) Resource "ng_ico_incris2" //"Visualizar Risco"
			EndMenu

         //Risco
			Menu ::oMenuRis PopUp Of Self
				MenuItem STR0427 Of ::oMenuRis Action ::OperRisTree(2) Resource "ng_ico_visris2" //"Visualizar Risco"
				MenuItem STR0423 Of ::oMenuRis Action ::OperRisTree(4) Resource "ng_ico_altris2" //"Alterar Risco"
				MenuItem STR0426 Of ::oMenuRis Action ::OperRisTree(5) Resource "ng_ico_excris2" //"Excluir Risco"
				MenuItem STR0428 Of ::oMenuRis Action (::OperRisTree( 4 , .T. )) Resource "ng_ico_relris2" //"Relac. Risco"
				MenuItem Replicate("_",22) DISABLED Of ::oMenuRis
				MenuItem STR0016 Of ::oMenuRis Action (::SetBlackPnl(.T.),If(MsgYesNo(STR0017),::DeleteShape(,.F.),Nil),::SetBlackPnl(.F.)) Resource "CANCEL"//"Excluir"##"Tem certeza de que deseja excluir este item?"
				MenuItem STR0018 Of ::oMenuRis Action ::PropertyShape() //"Propriedades"
			EndMenu

		ElseIf __nModPG == 56

			Menu ::oMenuRes PopUp Of Self
				MenuItem STR0462 Of ::oMenuRes Action (::SetBlackPnl(.T.),If(MsgYesNo(STR0463),::SgaResOpr(5),Nil),::SetBlackPnl(.F.)) Resource "CANCEL"//"Excluir"##"Tem certeza de que deseja excluir este item?"
				MenuItem oResPp Prompt STR0018 Of ::oMenuRes Action ::PropertyShape() //"Propriedades"
			EndMenu

			Menu ::oMenuAsp PopUp Of Self
				MenuItem STR0462 Of ::oMenuAsp Action (::SetBlackPnl(.T.),If(MsgYesNo(STR0463),::SgaAspOpr(5),Nil),::SetBlackPnl(.F.)) Resource "CANCEL"//"Excluir"##"Tem certeza de que deseja excluir este item?"
				MenuItem oAspPp Prompt STR0018 Of ::oMenuAsp Action ::PropertyShape() //"Propriedades"
			EndMenu

			Menu ::oMenuPto PopUp Of Self
				MenuItem STR0016 Of ::oMenuPto Action (::SetBlackPnl(.T.),If(MsgYesNo(STR0017),::DeleteItem(),Nil),::SetBlackPnl(.F.)) Resource "CANCEL"//"Excluir"##"Tem certeza de que deseja excluir este item?"
				MenuItem oPtoPp Prompt STR0018 Of ::oMenuPto Action ::PropertyShape() //"Propriedades"
			EndMenu

			aAdd(::aMenuPopUp[__aMenuPopUp_Res__], fRetArrMenus(oResPp, "", ""))
			aAdd(::aMenuPopUp[__aMenuPopUp_Asp__], fRetArrMenus(oAspPp, "", ""))
			aAdd(::aMenuPopUp[__aMenuPopUp_Pto__], fRetArrMenus(oPtoPp, "", ""))

		EndIf

	Else
		If __nModPG == 19

			aSMenu := NGRIGHTCLICK("MNTA907")

			Menu ::oMenuBem PopUp Of Self
				MenuItem STR0023 Of ::oMenuBem Action (::SetBlackPnl(.T.),MNTA080CAD( 'ST9' , ST9->( Recno() ) , 4 ),::SetBlackPnl(.F.)) //"Cadastro do Bem"
				MenuItem STR0024 Of ::oMenuBem Action (::SetBlackPnl(.T.),MNTC085(ST9->T9_CODBEM),::SetBlackPnl(.F.)) //"Curva da Banheira"
				MenuItem oOS Prompt STR0025 Of ::oMenuBem //"Ordem de Serviço"


					MenuItem oOSCor Prompt STR0026 Of oOS Action (::SetBlackPnl(.T.),MNTA420('B',ST9->T9_CODBEM),::UpdateAlert(),::SetBlackPnl(.F.)) //"O.S Corretiva"
					MenuItem oOSPre Prompt STR0027 Of oOS Action (::SetBlackPnl(.T.),MNTA410(ST9->T9_CODBEM),::UpdateAlert(),::SetBlackPnl(.F.)) //"O.S Manual"
					oOS:AddSeparator()
					MenuItem STR0028 Of oOS Action (::SetBlackPnl(.T.),MNC600ORD(ST9->T9_CODBEM),::SetBlackPnl(.F.)) //"Consulta"
					MenuItem STR0029 Of oOS Action (::SetBlackPnl(.T.),MNA080CON(ST9->T9_CODBEM),::SetBlackPnl(.F.)) //"Histórico"
					oOS:AddSeparator()
					MenuItem oOSLib Prompt STR0030 Of oOS Action (::SetBlackPnl(.T.),MNTA490('B',ST9->T9_CODBEM),::UpdateAlert(),::SetBlackPnl(.F.)) //"Liberação"
					MenuItem oOSRet Prompt STR0031 Of oOS Action (::SetBlackPnl(.T.),MNTA435("B"+ST9->T9_CODBEM,2),::UpdateAlert(),::SetBlackPnl(.F.)) //"Retorno"

				MenuItem oSS Prompt STR0032 Of ::oMenuBem //"Solicitação de Serviço"

					MenuItem oSSInc Prompt STR0033 Of oSS Action (::SetBlackPnl(.T.),MNTA280('B',ST9->T9_CODBEM),::UpdateAlert(),::SetBlackPnl(.F.)) //"Abertura"
				If lFacilit
					MenuItem oSSDis Prompt STR0034 Of oSS Action (::SetBlackPnl(.T.),MNTA296(,,"B",ST9->T9_CODBEM),::UpdateAlert(),::SetBlackPnl(.F.)) //"Distribuição"
					MenuItem oSSFin Prompt STR0464 Of oSS Action (::SetBlackPnl(.T.),MNTA291(,,"B",ST9->T9_CODBEM),::UpdateAlert(),::SetBlackPnl(.F.)) //"Atendimento"
				Else
					MenuItem oSSDis Prompt STR0034 Of oSS Action (::SetBlackPnl(.T.),MNTA295('B',ST9->T9_CODBEM),::UpdateAlert(),::SetBlackPnl(.F.)) //"Distribuição"
					MenuItem oSSFin Prompt STR0035 Of oSS Action (::SetBlackPnl(.T.),MNTA290('B',ST9->T9_CODBEM),::UpdateAlert(),::SetBlackPnl(.F.)) //"Fechamento"
				Endif
					MenuItem oSSSat Prompt STR0036 Of oSS Action (::SetBlackPnl(.T.),MNTA305('B',ST9->T9_CODBEM),::UpdateAlert(),::SetBlackPnl(.F.)) //"Satisfação"

				MenuItem oMan Prompt STR0037	Of ::oMenuBem //"Manutenção"

					MenuItem STR0038 Of oMan Action (::SetBlackPnl(.T.),MNC600CON(ST9->T9_CODBEM),::SetBlackPnl(.F.)) //"Manutenção do Bem"
					MenuItem STR0039 Of oMan Action (::SetBlackPnl(.T.),MNTC090(ST9->T9_CODBEM,.T.),::SetBlackPnl(.F.)) //"Estrutura de Bens"
			EndMenu

			//------------------------------------------
			// Adiciona Itens do Controle de Restricao
			//------------------------------------------
			aAdd(::aMenuPopUp[__aMenuPopUp_Bem__], fRetArrMenus(oOSCor, "O", "C"))
			aAdd(::aMenuPopUp[__aMenuPopUp_Bem__], fRetArrMenus(oOSPre, "O", "P"))
			aAdd(::aMenuPopUp[__aMenuPopUp_Bem__], fRetArrMenus(oOSLib, "O", "L"))
			aAdd(::aMenuPopUp[__aMenuPopUp_Bem__], fRetArrMenus(oOSRet, "O", "R"))
			aAdd(::aMenuPopUp[__aMenuPopUp_Bem__], fRetArrMenus(oSSInc, "S", "I"))
			aAdd(::aMenuPopUp[__aMenuPopUp_Bem__], fRetArrMenus(oSSDis, "S", "D"))
			aAdd(::aMenuPopUp[__aMenuPopUp_Bem__], fRetArrMenus(oSSFin, "S", "F"))
			aAdd(::aMenuPopUp[__aMenuPopUp_Bem__], fRetArrMenus(oSSSat, "S", "S"))

			//Adiciona clique da direita personalizaveis
			If Len(aSMenu) > 0
				MENUITEM Replicate("_",22) DISABLED Of ::oMenuBem
				For nX := 1 to Len(aSMENU)
					oItem := TMenuItem():New(::oMenuBem,aSMenu[nX][1],,,,&("{|| "+aSMenu[nX][2]+"}"),,,,,,,,,.T.)
					::oMenuBem:Add(oItem)
				Next nX
			EndIf

			Menu ::oMenuLoc PopUp Of Self
				MenuItem oOS Prompt STR0025 Of ::oMenuLoc //"Ordem de Serviço"

					MenuItem oOSCorL Prompt STR0026 Of oOS Action (::SetBlackPnl(.T.),MNTA420('L',TAF->TAF_CODNIV),::UpdateAlert(),::SetBlackPnl(.F.)) //"O.S Corretiva"
					oOS:AddSeparator()
					MenuItem oOSLibL Prompt STR0030 Of oOS Action (::SetBlackPnl(.T.),MNTA490('L',TAF->TAF_CODNIV),::UpdateAlert(),::SetBlackPnl(.F.)) //"Liberação"
					MenuItem oOSRetL Prompt STR0031 Of oOS Action (::SetBlackPnl(.T.),MNTA435('L' + Padr( TAF->TAF_CODNIV, FwTamSX3( 'TJ_CODBEM' )[ 1 ] ),2),::UpdateAlert(),::SetBlackPnl(.F.)) //"Retorno"

				MenuItem oSS Prompt STR0032 Of ::oMenuLoc //"Solicitação de Serviço"

					MenuItem oSSIncL Prompt STR0033 Of oSS Action (::SetBlackPnl(.T.),MNTA280('L',TAF->TAF_CODNIV),::UpdateAlert(),::SetBlackPnl(.F.)) //"Abertura"
				If lFacilit
					MenuItem oSSDisL Prompt STR0034 Of oSS Action (::SetBlackPnl(.T.),MNTA296(,,"L",TAF->TAF_CODNIV),::UpdateAlert(),::SetBlackPnl(.F.)) //"Distribuição"
					MenuItem oSSFinL Prompt "Atendimento" Of oSS Action (::SetBlackPnl(.T.),MNTA291(,,"L",TAF->TAF_CODNIV),::UpdateAlert(),::SetBlackPnl(.F.))
				Else
					MenuItem oSSDisL Prompt STR0034 Of oSS Action (::SetBlackPnl(.T.),MNTA295("L",TAF->TAF_CODNIV),::UpdateAlert(),::SetBlackPnl(.F.)) //"Distribuição"
					MenuItem oSSFinL Prompt STR0035 Of oSS Action (::SetBlackPnl(.T.),MNTA290("L",TAF->TAF_CODNIV),::UpdateAlert(),::SetBlackPnl(.F.)) //"Fechamento"
				Endif
					MenuItem oSSSatL Prompt STR0036 Of oSS Action (::SetBlackPnl(.T.),MNTA305('L',TAF->TAF_CODNIV),::UpdateAlert(),::SetBlackPnl(.F.)) //"Satisfação"

			EndMenu

			//------------------------------------------
			// Adiciona Itens do Controle de Restricao
			//------------------------------------------
			aAdd(::aMenuPopUp[__aMenuPopUp_Loc__], fRetArrMenus(oOSCorL, "O", "C"))
			aAdd(::aMenuPopUp[__aMenuPopUp_Loc__], fRetArrMenus(oOSLibL, "O", "L"))
			aAdd(::aMenuPopUp[__aMenuPopUp_Loc__], fRetArrMenus(oOSRetL, "O", "R"))
			aAdd(::aMenuPopUp[__aMenuPopUp_Loc__], fRetArrMenus(oSSIncL, "S", "I"))
			aAdd(::aMenuPopUp[__aMenuPopUp_Loc__], fRetArrMenus(oSSDisL, "S", "D"))
			aAdd(::aMenuPopUp[__aMenuPopUp_Loc__], fRetArrMenus(oSSFinL, "S", "F"))
			aAdd(::aMenuPopUp[__aMenuPopUp_Loc__], fRetArrMenus(oSSSatL, "S", "S"))
			//Adiciona clique da direita personalizaveis
			If Len(aSMenu) > 0
				MENUITEM "______________________" DISABLED Of ::oMenuLoc
				For nX := 1 to Len(aSMENU)
					oItem := TMenuItem():New(::oMenuLoc,aSMenu[nX][1],,,,&("{|| "+aSMenu[nX][2]+"}"),,,,,,,,,.T.)
					::oMenuLoc:Add(oItem)
				Next nX
			EndIf
		ElseIf __nModPG == 35
			Menu ::oMenuRis PopUp Of Self
				MenuItem STR0427 Of ::oMenuRis Action ::OperRisTree(2) Resource "ng_ico_visris2" //"Visualizar Risco"
				MenuItem STR0428 Of ::oMenuRis Action (MDT181REL( 4 , .T. )) Resource "ng_ico_relris2" //"Relac. Risco"
			EndMenu

		ElseIf __nModPG == 56

			Menu ::oMenuLoc PopUp Of Self

				MenuItem oFmrL Prompt STR0467 Of ::oMenuLoc //"FMR"
					MenuItem STR0475 Of oFmrL Action (::SetBlackPnl(.T.),SGAA500(GetAFmrRes()),::UpdateAlert(),::SetBlackPnl(.F.))) //"Não Conformes"
					MenuItem STR0470 Of oFmrL Action (::SetBlackPnl(.T.),SGAA510(GetAFmrPla()),::UpdateAlert(),::SetBlackPnl(.F.)) //"Logística de Retirada"
			EndMenu

			Menu ::oMenuRes PopUp Of Self
				MenuItem STR0465 Of ::oMenuRes Action SGADFR140(),::SetBlackPnl(.F.)) //"Cadastro"

				//MenuItem oOCR Prompt "Ocorrências" Of ::oMenuRes // "Ocorrências"
				MenuItem STR0466	Of ::oMenuRes Action (::SetBlackPnl(.T.),SgaOprOcr(),::UpdateAlert(),::SetBlackPnl(.F.)) //"Incluir Ocorrência"

				MenuItem oFmrR Prompt STR0467 Of ::oMenuRes //"Fmr"
					MenuItem oFmrRI Prompt STR0468 Of oFmrR Action (::SetBlackPnl(.T.),SgaOprFMR(GetIncAFmr()),::UpdateAlert(),::SetBlackPnl(.F.)) //"Incluir FMR"
					MenuItem STR0469 	Of oFmrR Action (::SetBlackPnl(.T.),SGAA500(GetAFmrRes()),::UpdateAlert(),::SetBlackPnl(.F.))) //"FMRs Não Conformes"
					MenuItem STR0470	Of oFmrR Action (::SetBlackPnl(.T.),SGAA510(GetAFmrLoc()),::UpdateAlert(),::SetBlackPnl(.F.)) //"Logística de Retirada"
			EndMenu

			Menu ::oMenuAsp PopUp Of Self
				MenuItem STR0465 Of ::oMenuAsp Action Sg030Pro("TA4",TA4->(Recno()),4,{TAG->TAG_CODASP}),::SetBlackPnl(.F.)) //"Cadastro"

				MenuItem oDesemp Prompt STR0471 Of ::oMenuAsp //"Desempenhos"
					MenuItem STR0472 Of oDesemp Action (::SetBlackPnl(.T.),SGAA112(GetDesempA()),::UpdateAlert(),::SetBlackPnl(.F.)) //"Aprovação em Lote"
					MenuItem STR0473 Of oDesemp Action (::SetBlackPnl(.T.),SGAA111(.F.,GetDesempA()),::UpdateAlert(),::SetBlackPnl(.F.)) //"Copia em Lote"
					MenuItem STR0474 Of oDesemp Action (::SetBlackPnl(.T.),SGAC150(),::UpdateAlert(),::SetBlackPnl(.F.)) //"Consulta Histórico"
			EndMenu

			Menu ::oMenuPto PopUp Of Self
				MenuItem STR0465 Of ::oMenuPto Action SGA490ALT("TDB",TDB->(Recno()),4),::SetBlackPnl(.F.)) //"Cadastro"

				MenuItem oFmrP Prompt STR0467 Of ::oMenuPto //"FMR"
					MenuItem oFmrPI Prompt STR0468 Of oFmrP Action (::SetBlackPnl(.T.),SgaOprFMR(GetPtoFmr()),::UpdateAlert(),::SetBlackPnl(.F.)) //"Incluir FMR"
					MenuItem STR0469 	Of oFmrP Action (::SetBlackPnl(.T.),SGAA500(GetFmrPNT4()),::UpdateAlert(),::SetBlackPnl(.F.))) //"FMRs Não Conformes"
					MenuItem STR0470	Of oFmrP Action (::SetBlackPnl(.T.),SGAA510(GetFMRPNT7()),::UpdateAlert(),::SetBlackPnl(.F.)) //"Logística de Retirada"
			EndMenu

			aAdd(::aMenuPopUp[__aMenuPopUp_Res__], fRetArrMenus(oFmrRI, "", ""))
			aAdd(::aMenuPopUp[__aMenuPopUp_Pto__], fRetArrMenus(oFmrPI, "", ""))

		EndIf
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} InsertImage
Método que insere imagem da biblioteca para a Planta Grafica

@param nPosX Posicao em X da imagem na Planta
@param nPosY Posicao em Y da imagem na Planta
@param cImgAtu Nome da imagem com a extensão
@param cTipImg Tipo da Imagem (Diretorio/Compilada)
@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return nId Id do shape adicionado
/*/
//---------------------------------------------------------------------
Method InsertImage(nPosX,nPosY,cImgAtu,cTipImg) Class TNGPG
	Local oBmp
	Local nPosShape
	Local nLargura, nAltura, nLargIni, nAltIni
	Local cCodNiv

	//Verifica o tamanho da imagem
	oBmp := TBitmap():New(00,00,0,0,,,.T.,,,,,.F.,,,,,.T.)
		oBmp:Hide()

	If oBmp:Load(,::cImgAtu)
		oBmp:nClrPane := CLR_WHITE
		oBmp:lAutoSize := .T.
		oBmp:lTransparent := .T.
		nLargura := oBmp:nClientWidth
		nAltura  := oBmp:nClientHeight
		nLargIni := nLargura
		nAltIni  := nAltura

		::cImgAtu := RemoveLinux(::cImgAtu)

		::oTPanel:addShape("id="+cValToChar(::SetId())+";type=8;left="+cValToChar(nPosX)+";top="+cValToChar(nPosY)+;
						   ";width="+cValToChar(nLargura)+";height="+cValToChar(nAltura)+";image-file="+lower(::cImgAtu)+";can-mark=1;can-move=1;can-deform=1;is-container=" + If(lReleaseB,'0','1') + ";")

		cCodNiv := ::cCodNiv
		If FindFunction("Soma1Old")
			::cCodNiv := Soma1Old(AllTrim(::cCodNiv))
		Else
			::cCodNiv := Soma1(AllTrim(::cCodNiv))
		EndIf

		::cImgAtu := InsertLinux(::cImgAtu)

		If __nModPG == 35
			Private cImgRisco := ::cImgAtu
		EndIf

		aAdd(::aShape,Array(__Len_aShape__))
		nPosShape := Len(::aShape)
		::aShape[nPosShape][__aShape_PlanSup__]  := ::cPlantaAtu
		::aShape[nPosShape][__aShape_IdShape__] := ::nId
		::aShape[nPosShape][__aShape_PosX__]    := nPosX
		::aShape[nPosShape][__aShape_PosY__]    := nPosY
		::aShape[nPosShape][__aShape_Largura__] := nLargura
		::aShape[nPosShape][__aShape_Altura__]  := nAltura
		::aShape[nPosShape][__aShape_LargIni__] := nLargIni
		::aShape[nPosShape][__aShape_AltIni__]  := nAltIni
		::aShape[nPosShape][__aShape_Image__]   := ::cImgAtu
		::aShape[nPosShape][__aShape_ImgIni__]  := ::cImgAtu
		::aShape[nPosShape][__aShape_Movement__]:= ::SetMovement()
		::aShape[nPosShape][__aShape_Blocked__] := .F.
		::aShape[nPosShape][__aShape_Codigo__]  := Space(3)//::cCodNiv
		::aShape[nPosShape][__aShape_Descri__]  := Space(Len(TAF->TAF_NOMNIV))
		::aShape[nPosShape][__aShape_IndCod__]  := "3"
		::aShape[nPosShape][__aShape_Planta__]  := "2"
		::aShape[nPosShape][__aShape_TipoImg__] := cTipImg
		::aShape[nPosShape][__aShape_NivSup__]  := If(__nModPG == 35, (::cTrbTree)->NIVSUP, ::GetNivSup(nPosX,nPosY,::nId))
		::aShape[nPosShape][__aShape_Alertas__] := {}
		::aShape[nPosShape][__aShape_Visivel__] := .T.
		::aShape[nPosShape][__aShape_Permit__]  := .T.
		::aShape[nPosShape][__aShape_Filial__]  := cFilAnt
		::aShape[nPosShape][__aShape_Caract__]  := {}

		If !::PropertyShape(.T.,::aShape[nPosShape][__aShape_IdShape__])
			::DeleteShape(::aShape[nPosShape][__aShape_IdShape__])
			aDel( ::aShape, nPosShape )
			aSize( ::aShape, Len( ::aShape ) - 1 )
			::cCodNiv := cCodNiv
		Else

			//Bloqueia objetor pai
			If (nPos := aScan(::aShape,{|x| x[__aShape_Cargo__] == ::aShape[nPosShape][__aShape_NivSup__]})) > 0
				::oTPanel:SetCanMove(::aShape[nPos][__aShape_IdShape__],.F.)
				::aShape[nPos][__aShape_Blocked__] := .T.
				dbSelectArea(::cTrbTree)
				dbSetOrder(2)
				If dbSeek('001'+Substr(::aShape[nPos][__aShape_Cargo__],1,3)+cFilAnt) .And. (::cTrbTree)->MOVBLO != "1"
					RecLock(::cTrbTree,.F.)
					(::cTrbTree)->MOVBLO := "1"
					MsUnLock(::cTrbTree)
				EndIf
			EndIf
		EndIf
	Else
		MsgStop(STR0040) //"Não foi possível adicionar a imagem selecionada na Planta."
	EndIf
	oBmp:Free()
Return ::nId

//---------------------------------------------------------------------
/*/{Protheus.doc} InsertTree
Método que insere ou altera item na Arvore Logica

@param nShapeAtu Id do shape
@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Method InsertTree(nShapeAtu) Class TNGPG

	Local nNivRis
	Local cCodigo, cDescri, cCarRis

	Default nShapeAtu := ::GetShapeAtu()

	Private nNivelIT		// Variaveis utilizadas no metodo SetTpTree
	Private nPosShapeIT	// Variaveis utilizadas no metodo SetTpTree

	nPosShapeIT := ::GetPosShape(nShapeAtu)

	If nPosShapeIT > 0

		cCodigo := ::aShape[nPosShapeIT][__aShape_Codigo__]
		cDescri := ::aShape[nPosShapeIT][__aShape_Descri__]
		cNivSup := ::aShape[nPosShapeIT][__aShape_NivSup__]

		dbSelectArea(::cTrbTree)
		dbSetOrder(2)
		dbSeek('001'+Substr(cNivSup,1,3)+cFilAnt)
		nNivelIT := (::cTrbTree)->NIVEL

		If ::aShape[nPosShapeIT][__aShape_IndCod__] == "0" // Ilustracao
			cLocal := Substr(cCodigo,1,3)
			dbSelectArea(::cTrbTree)
			dbSetOrder(2)
			If dbSeek("001"+Substr(cCodigo,1,3)+cFilAnt)
				If !Empty((::cTrbTree)->DELETADO)
					::oTree:AddItem(cDescri,cLocal+"ILU"+cFilAnt,'ico_planta_ilustracao.png','ico_planta_ilustracao.png',,, 2)
				EndIf
				::oTree:ChangePrompt(cDescri,cLocal+"ILU"+cFilAnt)
				RecLock(::cTrbTree,.F.)
			Else
				::oTree:AddItem(cDescri,cLocal+"ILU"+cFilAnt,'ico_planta_ilustracao.png','ico_planta_ilustracao.png',,, 2)
				RecLock(::cTrbTree,.T.)
			EndIf

			::aShape[nPosShapeIT][__aShape_Cargo__] := cLocal+"ILU"+cFilAnt
			(::cTrbTree)->FILIAL  := cFilAnt
			(::cTrbTree)->CODEST  := '001' //cCodEst
			(::cTrbTree)->CODPRO  := cLocal
			(::cTrbTree)->DESCRI  := cDescri
			(::cTrbTree)->NIVSUP  := cNivSup
			(::cTrbTree)->DOCFIL  := ""
			(::cTrbTree)->TIPO    := '0'
			If __nModPG == 19
				(::cTrbTree)->MODMNT  := 'X'
			ElseIf __nModPG == 35
				(::cTrbTree)->MODMDT  := 'X'
			ElseIf __nModPG == 56
				(::cTrbTree)->MODSGA  := 'X'
			EndIf
			(::cTrbTree)->ORDEM   := ::aShape[nPosShapeIT][__aShape_Movement__]
			(::cTrbTree)->NIVEL   := nNivelIT+1
			(::cTrbTree)->CARGO   := "ILU"
			(::cTrbTree)->PLANTA  := "2"
			(::cTrbTree)->TIPIMG  := ::aShape[nPosShapeIT][__aShape_TipoImg__]
			(::cTrbTree)->IMAGEM  := Substr(::aShape[nPosShapeIT][__aShape_ImgIni__],Rat(__cBARRAS__,::aShape[nPosShapeIT][__aShape_ImgIni__])+1,Len(::aShape[nPosShapeIT][__aShape_ImgIni__]))
			(::cTrbTree)->POSX    := ::aShape[nPosShapeIT][__aShape_PosX__]
			(::cTrbTree)->POSY    := ::aShape[nPosShapeIT][__aShape_PosY__]
			(::cTrbTree)->TAMX    := ::aShape[nPosShapeIT][__aShape_Largura__]
			(::cTrbTree)->TAMY    := ::aShape[nPosShapeIT][__aShape_Altura__]
			(::cTrbTree)->MOVBLO  := If(::aShape[nPosShapeIT][__aShape_Blocked__],"1","2")
			(::cTrbTree)->PGSUP   := ::cPlantaAtu
			(::cTrbTree)->DELETADO:= ""
			MsUnLock(::cTrbTree)
			::oTree:TreeSeek(cLocal+"ILU"+cFilAnt)

		ElseIf ::aShape[nPosShapeIT][__aShape_IndCod__] == "1" // Bem/Risco

			If __nModPG == 19

				dbSelectArea(::cTrbTree)
				dbSetOrder(3)
				If dbSeek("1"+cCodigo)
					cLocal := (::cTrbTree)->CODPRO
					If !Empty((::cTrbTree)->DELETADO)
						If FindFunction("Soma1Old")
							::cCodNiv := Soma1Old(AllTrim(::cCodNiv))
						Else
							::cCodNiv := Soma1(AllTrim(::cCodNiv))
						EndIf

						cLocal  := ::cCodNiv

						::oTree:AddItem(cDescri,cLocal+'BEM'+cFilAnt,"ng_ico_bem_planta","ng_ico_bem_planta",,,2)
					EndIf

					RecLock(::cTrbTree,.F.)
				Else

					If FindFunction("Soma1Old")
						::cCodNiv := Soma1Old(AllTrim(::cCodNiv))
					Else
						::cCodNiv := Soma1(AllTrim(::cCodNiv))
					EndIf

					cLocal  := ::cCodNiv
					::oTree:AddItem(cDescri,cLocal+'BEM'+cFilAnt,"ng_ico_bem_planta","ng_ico_bem_planta",,,2)
					RecLock(::cTrbTree,.T.)
				EndIf

				::aShape[nPosShapeIT][__aShape_Cargo__]  := cLocal+'BEM'+cFilAnt
				(::cTrbTree)->FILIAL  := cFilAnt
				(::cTrbTree)->CODEST	  := '001' //cCodEst
				(::cTrbTree)->CODPRO	  := cLocal
				(::cTrbTree)->DESCRI	  := cDescri
				(::cTrbTree)->NIVSUP	  := cNivSup
				(::cTrbTree)->TIPO    := '1'
				(::cTrbTree)->CODTIPO := cCodigo
				(::cTrbTree)->MODMNT  := 'X'
				(::cTrbTree)->ORDEM   := ::aShape[nPosShapeIT][__aShape_Movement__]
				(::cTrbTree)->CARGO   := "BEM"
				(::cTrbTree)->NIVEL   := nNivelIT+1
				(::cTrbTree)->PLANTA  := "2"
				(::cTrbTree)->TIPIMG  := ::aShape[nPosShapeIT][__aShape_TipoImg__]
				(::cTrbTree)->IMAGEM  := Substr(::aShape[nPosShapeIT][__aShape_ImgIni__],Rat(__cBARRAS__,::aShape[nPosShapeIT][__aShape_ImgIni__])+1,Len(::aShape[nPosShapeIT][__aShape_ImgIni__]))
				(::cTrbTree)->POSX    := ::aShape[nPosShapeIT][__aShape_PosX__]
				(::cTrbTree)->POSY    := ::aShape[nPosShapeIT][__aShape_PosY__]
				(::cTrbTree)->TAMX    := ::aShape[nPosShapeIT][__aShape_Largura__]
				(::cTrbTree)->TAMY    := ::aShape[nPosShapeIT][__aShape_Altura__]
				(::cTrbTree)->MOVBLO  := If(::aShape[nPosShapeIT][__aShape_Blocked__],"1","2")
				(::cTrbTree)->PGSUP   := ::cPlantaAtu
				(::cTrbTree)->DELETADO:= ""

				MsUnLock(::cTrbTree)
				If ::oTree:TreeSeek(cLocal+'BEM'+cFilAnt)

					// Bem ainda não está na Planta
					If ::aShape[nPosShapeIT][__aShape_Altura__] == 0 .And. ::aShape[nPosShapeIT][__aShape_Largura__] == 0
						::oTree:ChangeBmp( "ENGRENAGEM","ENGRENAGEM","ENGRENAGEM","ENGRENAGEM",cLocal+'BEM'+cFilAnt )
					Else // Bem já está na Planta
						::oTree:ChangeBmp( "ng_ico_bem_planta","ng_ico_bem_planta","ng_ico_bem_planta","ng_ico_bem_planta",cLocal+'BEM'+cFilAnt )
					EndIf
				EndIf

			ElseIf __nModPG == 35

				dbSelectArea(::cTrbTree)
				dbSetOrder(2)
				dbSeek('001'+cNivAtual+cFilAnt)

				dbSelectArea( ::cTrbTree )
				dbSetOrder( 2 ) //CODEST+CODPRO+FILIAL
				While AllTrim((__cTrbTree)->CARGO) $ "ILU/RIS" .And. !Empty((::cTrbTree)->CARGO)

					dbSelectArea(::cTrbTree)
					dbSetOrder( 2 ) //CODEST+CODPRO+FILIAL
					dbSeek( (::cTrbTree)->CODEST+(::cTrbTree)->NIVSUP + cFilAnt )
				End

				nNivRis := (::cTrbTree)->NIVEL
				cNivSup := (::cTrbTree)->CODPRO
				cCarRis := AllTrim((::cTrbTree)->CARGO)
				dbSelectArea(::cTrbTree)
				dbSetOrder(3)
				If dbSeek("7"+cCodigo)
					cLocal := (::cTrbTree)->CODPRO

					If !Empty((::cTrbTree)->DELETADO)
						If FindFunction("Soma1Old")
							::cCodNiv := Soma1Old(AllTrim(::cCodNiv))
						Else
							::cCodNiv := Soma1(AllTrim(::cCodNiv))
						EndIf

						cLocal  := ::cCodNiv
						::oTree:TreeSeek(cNivSup+cCarRis+cFilAnt)
						::oTree:AddItem(cDescri,cLocal+'RIS'+cFilAnt,"ng_ico_ris_planta","ng_ico_ris_planta",,,2)
					EndIf

					RecLock(::cTrbTree,.F.)
				Else

					If FindFunction("Soma1Old")
						::cCodNiv := Soma1Old(AllTrim(::cCodNiv))
					Else
						::cCodNiv := Soma1(AllTrim(::cCodNiv))
					EndIf

					cLocal  := ::cCodNiv
					::oTree:TreeSeek(cNivSup+cCarRis+cFilAnt)
					::oTree:AddItem(cDescri,cLocal+'RIS'+cFilAnt,"ng_ico_ris_planta","ng_ico_ris_planta",,,2)
					RecLock(::cTrbTree,.T.)
				EndIf

				::aShape[nPosShapeIT][__aShape_Cargo__]  := cLocal+'RIS'+cFilAnt
				(::cTrbTree)->FILIAL  := cFilAnt
				(::cTrbTree)->CODEST	  := '001'
				(::cTrbTree)->CODPRO	  := cLocal
				(::cTrbTree)->DESCRI	  := cDescri
				(::cTrbTree)->NIVSUP	  := cNivSup
				(::cTrbTree)->TIPO    := '7'
				(::cTrbTree)->CODTIPO := cCodigo
				If __nModPG == 19
					(::cTrbTree)->MODMNT  := 'X'
				ElseIf __nModPG == 35
					(::cTrbTree)->MODMDT  := 'X'
				ElseIf __nModPG == 56
					(::cTrbTree)->MODSGA  := 'X'
				EndIf
				(::cTrbTree)->ORDEM   := ::aShape[nPosShapeIT][__aShape_Movement__]
				(::cTrbTree)->CARGO   := "RIS"
				(::cTrbTree)->NIVEL   := nNivRis+1
				(::cTrbTree)->PLANTA  := "2"
				(::cTrbTree)->TIPIMG  := ::aShape[nPosShapeIT][__aShape_TipoImg__]
				(::cTrbTree)->IMAGEM  := Substr(::aShape[nPosShapeIT][__aShape_ImgIni__],Rat(__cBARRAS__,::aShape[nPosShapeIT][__aShape_ImgIni__])+1,Len(::aShape[nPosShapeIT][__aShape_ImgIni__]))
				(::cTrbTree)->POSX    := ::aShape[nPosShapeIT][__aShape_PosX__]
				(::cTrbTree)->POSY    := ::aShape[nPosShapeIT][__aShape_PosY__]
				(::cTrbTree)->TAMX    := ::aShape[nPosShapeIT][__aShape_Largura__]
				(::cTrbTree)->TAMY    := ::aShape[nPosShapeIT][__aShape_Altura__]
				(::cTrbTree)->MOVBLO  := If(::aShape[nPosShapeIT][__aShape_Blocked__],"1","2")
				(::cTrbTree)->PGSUP   := ::cPlantaAtu
				(::cTrbTree)->DELETADO:= ""

				MsUnLock(::cTrbTree)
				If ::oTree:TreeSeek(cLocal+'RIS'+cFilAnt)

					// Risco ainda não está na Planta
					If ::aShape[nPosShapeIT][__aShape_Altura__] == 0 .And. ::aShape[nPosShapeIT][__aShape_Largura__] == 0
						::oTree:ChangeBmp( "ng_ico_risco","ng_ico_risco","ng_ico_risco","ng_ico_risco",cLocal+'RIS'+cFilAnt )
					Else // Risco já está na Planta
						::oTree:ChangeBmp( "ng_ico_ris_planta","ng_ico_ris_planta","ng_ico_ris_planta","ng_ico_ris_planta",cLocal+'RIS'+cFilAnt )
					EndIf
				EndIf
         	EndIf

		ElseIf ::aShape[nPosShapeIT][__aShape_IndCod__] == "2" .And. ::aShape[nPosShapeIT][__aShape_Planta__] == "2"// Localizacao

			dbSelectArea(::cTrbTree)
			dbSetOrder(2)
			If dbSeek("001"+Substr(cCodigo,1,3)+cFilAnt) .And. Empty((::cTrbTree)->DELETADO)

				cLocal := cCodigo

				If cLocal == "001"
					::aShape[nPosShapeIT][__aShape_NivSup__] := "000"
					cNivSup := "000"
				EndIf
				::oTree:ChangePrompt(cDescri,cLocal+'LOC'+cFilAnt)

				RecLock(::cTrbTree,.F.)

				//::oTree:AddItem(cDescri,cLocal+'LOC','ico_planta_local2','ico_planta_local2',,, 2)
				::aShape[nPosShapeIT][__aShape_Cargo__]  := cLocal+'LOC'+cFilAnt
				(::cTrbTree)->FILIAL  := cFilAnt
				(::cTrbTree)->CODEST  := '001' //cCodEst
				(::cTrbTree)->CODPRO  := cLocal
				(::cTrbTree)->DESCRI  := cDescri
				(::cTrbTree)->NIVSUP  := cNivSup
				(::cTrbTree)->DOCFIL  := ""
				(::cTrbTree)->TIPO    := '2'
				If __nModPG == 19
					(::cTrbTree)->MODMNT  := 'X'
				ElseIf __nModPG == 35
					(::cTrbTree)->MODMDT  := 'X'
				ElseIf __nModPG == 56
					(::cTrbTree)->MODSGA  := 'X'
				EndIf
				(::cTrbTree)->ORDEM   := ::aShape[nPosShapeIT][__aShape_Movement__]
				(::cTrbTree)->NIVEL   := nNivelIT+1
				(::cTrbTree)->CARGO   := "LOC"
				(::cTrbTree)->PLANTA  := "2"
				(::cTrbTree)->TIPIMG  := ::aShape[nPosShapeIT][__aShape_TipoImg__]
				(::cTrbTree)->IMAGEM  := Substr(::aShape[nPosShapeIT][__aShape_ImgIni__],Rat(__cBARRAS__,::aShape[nPosShapeIT][__aShape_ImgIni__])+1,Len(::aShape[nPosShapeIT][__aShape_ImgIni__]))
				(::cTrbTree)->POSX    := ::aShape[nPosShapeIT][__aShape_PosX__]
				(::cTrbTree)->POSY    := ::aShape[nPosShapeIT][__aShape_PosY__]
				(::cTrbTree)->TAMX    := ::aShape[nPosShapeIT][__aShape_Largura__]
				(::cTrbTree)->TAMY    := ::aShape[nPosShapeIT][__aShape_Altura__]
				(::cTrbTree)->MOVBLO  := If(::aShape[nPosShapeIT][__aShape_Blocked__],"1","2")
				(::cTrbTree)->PGSUP   := ::cPlantaAtu
				(::cTrbTree)->DELETADO:= ""
				MsUnLock(::cTrbTree)

				::oTree:TreeSeek(cLocal+"LOC"+cFilAnt)
			Else
				MsgStop(STR0041) //"Um erro inesperado ocorreu ao criar item na estrutura"
			EndIf

		ElseIf ::aShape[nPosShapeIT][__aShape_IndCod__] == "2" .And. ::aShape[nPosShapeIT][__aShape_Planta__] == "1"//Planta

			cLocal := cCodigo

			If cLocal == "001"
				::aShape[nPosShapeIT][__aShape_NivSup__] := "000"
				cNivSup := "000"
			EndIf
			dbSelectArea(::cTrbTree)
			dbSetOrder(2)
			If dbSeek("001"+Substr(cCodigo,1,3)+cFilAnt)
				If !Empty((::cTrbTree)->DELETADO)
					::oTree:AddItem(cDescri,cLocal+"LOC"+cFilAnt,'ico_planta_fecha','ico_planta_abre',,, 2)
				EndIf
				::oTree:ChangePrompt(cDescri,cLocal+"LOC"+cFilAnt)
				RecLock(::cTrbTree,.F.)
			Else
				::oTree:AddItem(cDescri,cLocal+"LOC"+cFilAnt,'ico_planta_fecha','ico_planta_abre',,, 2)
				RecLock(::cTrbTree,.T.)
			EndIf

			::aShape[nPosShapeIT][__aShape_Cargo__]   := cLocal+"LOC"+cFilAnt
			(::cTrbTree)->FILIAL  := cFilAnt
			(::cTrbTree)->CODEST  := '001' //cCodEst
			(::cTrbTree)->CODPRO  := cLocal
			(::cTrbTree)->DESCRI  := cDescri
			(::cTrbTree)->NIVSUP  := cNivSup
			(::cTrbTree)->DOCFIL  := ""
			(::cTrbTree)->TIPO    := '2'
			If __nModPG == 19
				(::cTrbTree)->MODMNT  := 'X'
			ElseIf __nModPG == 35
				(::cTrbTree)->MODMDT  := 'X'
			ElseIf __nModPG == 56
				(::cTrbTree)->MODSGA  := 'X'
			EndIf
			(::cTrbTree)->ORDEM   := ::aShape[nPosShapeIT][__aShape_Movement__]
			(::cTrbTree)->NIVEL   := nNivelIT+1
			(::cTrbTree)->CARGO   := "LOC"
			(::cTrbTree)->PLANTA  := "1"
			(::cTrbTree)->TIPIMG  := ::aShape[nPosShapeIT][__aShape_TipoImg__]
			(::cTrbTree)->IMAGEM  := Substr(::aShape[nPosShapeIT][__aShape_ImgIni__],Rat(__cBARRAS__,::aShape[nPosShapeIT][__aShape_ImgIni__])+1,Len(::aShape[nPosShapeIT][__aShape_ImgIni__]))
			(::cTrbTree)->POSX    := ::aShape[nPosShapeIT][__aShape_PosX__]
			(::cTrbTree)->POSY    := ::aShape[nPosShapeIT][__aShape_PosY__]
			(::cTrbTree)->TAMX    := ::aShape[nPosShapeIT][__aShape_Largura__]
			(::cTrbTree)->TAMY    := ::aShape[nPosShapeIT][__aShape_Altura__]
			(::cTrbTree)->MOVBLO  := If(::aShape[nPosShapeIT][__aShape_Blocked__],"1","2")
			(::cTrbTree)->PGSUP   := ::cPlantaAtu
			(::cTrbTree)->DELETADO:= ""
			MsUnLock(::cTrbTree)

		ElseIf ::aShape[nPosShapeIT][__aShape_IndCod__] == "A"

			::SetTpTree("A")

		ElseIf ::aShape[nPosShapeIT][__aShape_IndCod__] == "B"

			::SetTpTree("B")

		ElseIf ::aShape[nPosShapeIT][__aShape_IndCod__] == "C"

			::SetTpTree("C")

		EndIf

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} SetTpTree
Grava os itens do Shape para a Tabela Temporária.

@author Gabriel Werlich
@since 15/08/2014
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Method SetTpTree( cPgTipo ) Class TNGPG

	Local aInfoTp, cCargo, cImgIco

	Local aTpCargos	:= GetInfoTp()
	Local cSequen  	:= ""

	Local cCodigo := ::aShape[nPosShapeIT][__aShape_Codigo__]
	Local cDescri := ::aShape[nPosShapeIT][__aShape_Descri__]
	Local cNivSup := ::aShape[nPosShapeIT][__aShape_NivSup__]

	If Len(::aShape[nPosShapeIT][__aShape_Caract__]) > 0
		cSequen := ::aShape[nPosShapeIT][__aShape_Caract__][1]
	EndIf

	aInfoTp	:= RetInfoTp( aTpCargos, cPgTipo )
	cCargo 	:= aInfoTp[2]
	cImgIco 	:= aInfoTp[3]

	dbSelectArea(::cTrbTree)
	dbSetOrder(3)
	If dbSeek( cPgTipo + Padr(cCodigo, Len((::cTrbTree)->CODTIPO)) + cNivSup + cSequen )

		cLocal := (::cTrbTree)->CODPRO

		If !Empty((::cTrbTree)->DELETADO)
			If FindFunction("Soma1Old")
				::cCodNiv := Soma1Old( AllTrim(::cCodNiv) )
			Else
				::cCodNiv := Soma1( AllTrim(::cCodNiv) )
			EndIf

			cLocal  := ::cCodNiv
			::oTree:AddItem(cDescri,cLocal+cCargo+cFilAnt,cImgIco,cImgIco,,,2)
		EndIf

		RecLock(::cTrbTree,.F.)

	Else

		If FindFunction("Soma1Old")
			::cCodNiv := Soma1Old( AllTrim(::cCodNiv) )
		Else
			::cCodNiv := Soma1( AllTrim(::cCodNiv) )
		EndIf

		cLocal := ::cCodNiv
		::oTree:AddItem( cDescri, cLocal + cCargo + cFilAnt, cImgIco, cImgIco, , , 2 )
		RecLock(::cTrbTree,.T.)

	EndIf

	::aShape[nPosShapeIT][__aShape_Cargo__]  := cLocal+cCargo+cFilAnt
	(::cTrbTree)->FILIAL		:= cFilAnt
	(::cTrbTree)->CODEST		:= "001"
	(::cTrbTree)->CODPRO		:= cLocal
	(::cTrbTree)->DESCRI		:= cDescri
	(::cTrbTree)->NIVSUP		:= cNivSup
	(::cTrbTree)->TIPO		:= cPgTipo
	(::cTrbTree)->CODTIPO	:= cCodigo
	(::cTrbTree)->ORDEM  	:= ::aShape[nPosShapeIT][__aShape_Movement__]
	(::cTrbTree)->CARGO  	:= cCargo
	(::cTrbTree)->NIVEL  	:= nNivelIT+1
	(::cTrbTree)->PLANTA 	:= "2"
	(::cTrbTree)->TIPIMG 	:= ::aShape[nPosShapeIT][__aShape_TipoImg__]
	(::cTrbTree)->POSX   	:= ::aShape[nPosShapeIT][__aShape_PosX__]
	(::cTrbTree)->POSY   	:= ::aShape[nPosShapeIT][__aShape_PosY__]
	(::cTrbTree)->TAMX   	:= ::aShape[nPosShapeIT][__aShape_Largura__]
	(::cTrbTree)->TAMY   	:= ::aShape[nPosShapeIT][__aShape_Altura__]
	(::cTrbTree)->MOVBLO 	:= If(::aShape[nPosShapeIT][__aShape_Blocked__],"1","2")
	(::cTrbTree)->PGSUP  	:= ::cPlantaAtu
	(::cTrbTree)->DELETADO	:= ""

	If !Empty(cSequen)
   	(::cTrbTree)->SEQUEN	:= cSequen
   Endif

   (::cTrbTree)->IMAGEM 	:= Substr(	::aShape[nPosShapeIT][__aShape_ImgIni__],;
															Rat(__cBARRAS__, ::aShape[nPosShapeIT][__aShape_ImgIni__]) + 1,;
															Len( ::aShape[nPosShapeIT][__aShape_ImgIni__] ))

   If __nModPG == 19
		(::cTrbTree)->MODMNT  := "X"
	ElseIf __nModPG == 35
		(::cTrbTree)->MODMDT  := "X"
	ElseIf __nModPG == 56
		(::cTrbTree)->MODSGA  := "X"
	EndIf

	MsUnLock(::cTrbTree)

	If ::oTree:TreeSeek( cLocal + cCargo + cFilAnt )
		::oTree:ChangeBmp( cImgIco, cImgIco, cImgIco, cImgIco, cLocal + cCargo + cFilAnt )
		::oTree:ChangePrompt( cDescri, cLocal + cCargo + cFilAnt )
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} DeleteItem
Método que exclui item posicionado na Tree

@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Method DeleteItem() Class TNGPG

	Local cCargo  := ::oTree:GetCargo()
	Local cLocal  := Substr(cCargo,1,3)
	Local aDelete := {}
	Local nX := 1, nLenSon := 1
	Local nPosShape, nShapeAtu
	Local cPai

	If !Empty(cCargo)

		dbSelectArea(::cTrbTree)
		dbSetOrder(2)
		If dbSeek("001"+cLocal+cFilAnt)

			aAdd(aDelete,(::cTrbTree)->CODPRO)

			//Verifica se existe O.S ou SS para a localizacao
			If !ValDelItem(::cTrbTree)
				Return .F.
			EndIf

			dbSelectArea(::cTrbTree)
			dbSetOrder(1)
			While nX <= nLenSon

				cPai := aDelete[nX]
				dbSeek('001'+cPai+cFilAnt)
				While !Eof() .And. (::cTrbTree)->NIVSUP == cPai

					If Empty((::cTrbTree)->DELETADO)

						If !ValDelItem(::cTrbTree)
							Return .F.
						EndIf

						aAdd(aDelete,(::cTrbTree)->CODPRO)
						nLenSon++
					EndIf

					dbSelectArea(::cTrbTree)
					dbSkip()
				EndDo
				nX++
			EndDo

			dbSelectArea(::cTrbTree)
			dbSetOrder(2)
			For nX := Len(aDelete) To 1 Step -1
				dbSeek("001"+aDelete[nX]+cFilAnt)
				RecLock(::cTrbTree,.F.)
				If aDelete[nX] != "001"
					(::cTrbTree)->DELETADO := 'X'
					 If __nModPG <> 56
					If ::oTree:TreeSeek((::cTrbTree)->CODPRO+AllTrim((::cTrbTree)->CARGO)+cFilAnt)
						::oTree:DelItem()
					EndIf
					 Else
						If ::oTree:TreeSeek((::cTrbTree)->CODPRO+Substr(cCargo,4,3)+cFilAnt)
							::oTree:DelItem()
				EndIf
					EndIf

				EndIf
				(::cTrbTree)->TIPIMG  := ""
				(::cTrbTree)->IMAGEM  := ""
				(::cTrbTree)->POSX    := 0
				(::cTrbTree)->POSY    := 0
				(::cTrbTree)->TAMX    := 0
				(::cTrbTree)->TAMY    := 0
				(::cTrbTree)->MOVBLO  := "2"
				MsUnLock(::cTrbTree)

				nPosShape := aScan(::aShape,{|aShape| Substr(aShape[__aShape_Cargo__],1,3) == aDelete[nX] .And. aShape[__aShape_Filial__] == cFilAnt})
				If nPosShape > 0
					nShapeAtu := ::aShape[nPosShape][__aShape_IdShape__]
					::oTPanel:DeleteItem(nShapeAtu)
					aDel( ::aShape, nPosShape )
					aSize( ::aShape, Len( ::aShape ) - 1 )
				EndIf
			Next nLenSon

			//-----------------------------------------------------------------
			// Identifica que a planta teve alterações e necessita ser salva
			//-----------------------------------------------------------------
			::lModified := .T.
		EndIf
	EndIf

	::SetOptionTree(::oTree:GetCargo())
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} ValDelItem
Faz a validação paraSGA, se é possível ou não deletar um item da planta.

@param cTrbTree Alias temporaria utilizada pela Tree
@author Gabriel Werlich
@since 12/08/2014
@version MP10
@return .T. ou .F.
/*/
//---------------------------------------------------------------------
Static Function ValDelItem(cTrbTree)

	Local lValOk := .T.

	If cValToChar(__nModPG) $ "19/56"
		lValOk := VerifOSLoc(cTrbTree) // Verifica se existe O.S ou SS para a localizacao
	Endif

	If __nModPG == 56 .And. lValOk
		lValOk := SgaValItem(cTrbTree)
	Endif

Return lValOk

//---------------------------------------------------------------------
/*/{Protheus.doc} SgaValItem
Verifica se o item de SGA pode ser deletado, faz a verificação através do SX9

@param cTrbTree Alias temporaria utilizada pela Tree
@author Gabriel Werlich
@since 12/08/2014
@version MP11
@return .T. ou .F.
/*/
//---------------------------------------------------------------------
Static Function SgaValItem(cTrbTree)

	Local aTable := GetTableF3( (cTrbTree)->TIPO )
	Local lValOk := .T.
	Local cSeek, nOrdem

	If !Empty(aTable[1])

		If((cTrbTree)->TIPO) == "2"
			cSeek	:= "001"+(cTrbTree)->CODPRO
			nOrdem	:= 2
		ElseIf ((cTrbTree)->TIPO) == "C"
			nOrdem	:= 1
			cSeek	:= (cTrbTree)->NIVSUP+(cTrbTree)->CODTIPO
		Else
			nOrdem	:= 1
			cSeek	:= (cTrbTree)->CODTIPO
		EndIf

		dbSelectArea(aTable[1])
		dbSetOrder(nOrdem)
		If dbSeek(xFilial(aTable[1])+AllTrim( cSeek ) )
			lValOk := NGVALSX9( aTable[2] , aTable[3] , .T. )
		Endif
	Endif

Return lValOk


/*


*/
//---------------------------------------------------------------------
/*/{Protheus.doc} VerifOSLoc
Funcao que verifica se Localizacao podera ser excluida verificando se
existe Ordem de Serviço ou Solicitação de serviço para ela

@param cTrbTree Alias temporaria utilizada pela Tree
@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return .T. ou .F.
/*/
//---------------------------------------------------------------------
Static Function VerifOSLoc(cTrbTree)

	If AllTrim((cTrbTree)->CARGO) == "LOC"
		dbSelectArea("STJ")
		dbSetOrder(2)
		If dbSeek(xFilial("STJ")+"L"+(cTrbTree)->CODPRO)
			MsgStop(STR0042+CHR(13)+CHR(10)+STR0043+STJ->TJ_ORDEM,STR0348) //"Esse Item não pode ser excluído pois existe Ordem de Serviço relacionada ao mesmo."###"Ordem: " //"Atenção!"
			Return .F.
		EndIf

		dbSelectArea("STS")
		dbSetOrder(2)
		If dbSeek(xFilial("STS")+"L"+(cTrbTree)->CODPRO)
			MsgStop(STR0044+CHR(13)+CHR(10)+STR0043+STS->TS_ORDEM,STR0348) //###### //"Esse Item não pode ser excluído pois existe Histórico de Manutenção relacionado ao mesmo." //"Ordem: "##"Atenção!"
			Return .F.
		EndIf

		dbSelectArea("TQB")
		dbSetOrder(13)
		If dbSeek(xFilial("TQB")+"L"+(cTrbTree)->CODPRO)
			MsgStop(STR0045+CHR(13)+CHR(10)+STR0046+TQB->TQB_SOLICI,STR0348) //###### //"Esse Item não pode ser excluído pois existe Solicitação de Serviço relacionado ao mesmo."###"Solicitação: ""Atenção!"
			Return .F.
		EndIf
	EndIf
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} VerifRis
Funcao que verifica se Localizacao podera ser excluida verificando se
existe Riscos ambientais cadastrados para ela

@param cTrbTree Alias temporaria utilizada pela Tree
@author Guilherme Benkendorf
@since 27/06/2014
@version MP11
@return lRet .T./.F.
/*/
//---------------------------------------------------------------------
Static Function VerifRis(cTRBTree)
	Local lRet := .T.
	Local aAreaRis := GetArea()

	If AllTrim((cTrbTree)->CARGO) == "RIS"
		dbSelectArea( "TN0" )
		dbSetOrder( 1 )//TN0_FILIAL+TN0_NUMRIS
		dbSeek( xFilial( "TN0" ) + SubStr( (cTrbTree)->CODTIPO, 1 , Len(TN0->TN0_NUMRIS) ) )
		lRet := Mdt180Vlf( 5 )
	EndIf

	RestArea( aAreaRis )

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} PropertyShape
Método que monta tela para se informar ou alterar informacoes sobre um
item selecionado na Planta

@param lInclui Indica se é inclusão do item
@param nShapeAtu Id do shape a ser incluído/alterado
@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return lConfirm Indica se confirmou ou cancelou a tela
/*/
//---------------------------------------------------------------------
Method PropertyShape(lInclui,nShapeAtu) Class TNGPG

	Local oDlg, oSayCod, oSayDesc, oCodigo, oDescri, oTipo, oGroup, oPorcent, oConfirm, oCancel

	Local nLargura, nAltura, nLargIni, nAltIni
	Local cDescri, cLocPai
	Local cF3 := "ST9NIV"

	Local lConfirm   := .F.
	Local lConfirIma := .T.
	Local lCheck     := .F.
	Local cWhenPor   := ".T."

	Local nPorcent := 100
	Local cCodNiv  := ::cCodNiv

	Local aItems     := { "0=" + STR0047, "1=" + STR0048, "2=" + STR0049, "3=" + STR0050 } //"Ilustração"###"Bem"###"Localização"###"Planta Gráfica"
	Local bHpPrShape := { || ShowHelpCpo(STR0052, {STR0364,aItems[1],aItems[2],aItems[3],aItems[4]},5,{},5)  } //"Tipo de Imagem"###//"Indica o tipo de imagem representado na planta."
	Local cCodigo    := Space(Len(ST9->T9_CODBEM))
	Local cPictDesc  := ""

	Default lInclui   := .F.
	Default nShapeAtu := ::GetShapeAtu()

	Private _cPgTipo, _oF3Tipo
	Private cRetRisco 	:= ""
	Private _oPgF3		:= Self
	Private _bPGF3Loc	:= {|| MNTPGF3LOC() }
	Private cNivAtual	:= SubStr( ::oTree:GetCargo(), 1, 3 )
	Private cPaiSelect	:= (__cTrbTree)->NIVSUP
	Private cTipoAtual	:= (__cTrbTree)->TIPO
	Private aGetTrbTre	:= (__cTrbTree)->(GetArea())
	Private cPlantaSup	:= If( (__cTrbTree)->TIPO == '2' .And. (__cTrbTree)->PLANTA == '1', cNivAtual, (__cTrbTree)->PGSUP )

	//--------------------------------------
	// Variáveis utilizadas na consulta F3
	//--------------------------------------
	Private cMntGenFun := "NGSUBNIV()"
	Private cMntGenRet := "Eval(_bPGF3Loc)"
	//MDTGEN
	Private cMdtGenFun := "MDTSXBPG()"
	Private cMdtGenRet := "Eval( { || cRetRisco } )"

	If lInclui
		DbSelectArea(__cTrbTree)
		DbSetOrder(2)
		If DbSeek("001"+cPlantaSup+cFilAnt)
			cNivSelect := (__cTrbTree)->CODPRO //Recebe o valor do nivel posicionado
			cPaiSelect := (__cTrbTree)->NIVSUP //Recebe o pai do nivel selecionado
			cTipoAtual := (__cTrbTree)->TIPO
			aGetTrbTre := (__cTrbTree)->(GetArea())
		EndIf
	EndIf

	If __nModPG == 35

		aItems     := { "0=" + STR0047, "1=" + STR0414, "2=" + STR0049, "3=" + STR0050 } //"Ilustração"###"Risco"###"Localização"###"Planta Gráfica"
		bHpPrShape := { || ShowHelpCpo(STR0052, {STR0364,aItems[1],aItems[2],aItems[3],aItems[4]},5,{},5)  } //"Tipo de Imagem"###//"Indica o tipo de imagem representado na planta."
		cWhenPor   := "_cPgTipo != '1'"

		lConfirIma := fValImageInc(::oTree, __cTrbTree, ::cImgAtu)

	ElseIf __nModPG == 56

		Private cDepto490 := If((__cTrbTree)->TIPO <> '2', cPaiSelect, cNivAtual)

		aItems 	  := {"0=" + STR0047, "A=" + STR0455, "2=" + STR0049, "3=" + STR0050, "B=" + STR0459, "C=" + STR0460} //"Ilustração"###"Residuo"###"Localização"###"Planta Gráfica"###"Aspecto"###"Ponto Coleta"
		bHpPrShape := { || ShowHelpCpo(STR0052, {STR0364,aItems[1],aItems[2],aItems[3],aItems[4],aItems[5],aItems[6]},5,{},5)  } //"Tipo de Imagem"###//"Indica o tipo de imagem representado na planta."
		cPictDesc  := "@!"

	EndIf

	nPosShape := ::GetPosShape(nShapeAtu)

	If Empty((__cTrbTree)->IMAGEM) .And. cTipoAtual $ "7/A/B/C" // Risco|Residuo|Aspecto|Ponto Coleta
		MsgInfo( "Não há imagem vinculada na Planta." , "Atenção" )//"Não há imagem vinculada na Planta."###//"Atenção" STR0445, STR0348
		Return lConfirm
	EndIf

	If nPosShape > 0 .And. lConfirIma

		nLargura := ::aShape[nPosShape][__aShape_Largura__]
		nAltura  := ::aShape[nPosShape][__aShape_Altura__]
		nLargIni := ::aShape[nPosShape][__aShape_LargIni__]
		nAltIni  := ::aShape[nPosShape][__aShape_AltIni__]
		::oTree:TreeSeek(::aShape[nPosShape][__aShape_NivSup__])
		cLocPai  := ::oTree:GetPrompt()
		::cImgAtu:= ::aShape[nPosShape][__aShape_Image__]
		If !Empty(::aShape[nPosShape][__aShape_Cargo__])
			::oTree:TreeSeek(::aShape[nPosShape][__aShape_Cargo__])
		EndIf

			//Verifica se há informações de largura para efetuar o cálculo, sem informações quando realizada Imp. Bens
		If !Empty(::aShape[nPosShape][__aShape_LargIni__])
			nPorcent := (nLargura / nLargIni ) * 100
		EndIf

		::SetBlackPnl(.T.)
		If !Empty(::aShape[nPosShape][__aShape_Image__])
			Define Dialog oDlg From 5,5 To 350,455 Of Self COLOR CLR_BLACK,CLR_WHITE STYLE nOr(DS_SYSMODAL,WS_MAXIMIZEBOX,WS_POPUP) Pixel
				oDlg:lEscClose := .F.

				oTPanel := TPaintPanel():New(0,0,0,0,oDlg,.F.)
					oTPanel:Align := CONTROL_ALIGN_ALLCLIENT

					//Container do Fundo
					oTPanel:addShape(	"id="+cValToChar(::SetId())+";type=1;left=0;top=0;width=460;height=375;"+;
										"gradient=1,0,0,0,180,0.0,#FFFFFF;pen-color=#FFFFFF;can-move=0;can-mark=0;is-container=" + If(lReleaseB,'0','1') + ";")
					//Gradiente
					oTPanel:addShape( "id="+cValToChar(::SetId())+";type=1;left=1;top=1;width=456;height=370;"+;
									  "gradient=1,0,0,0,380,0.0,#FFFFFF,0.1,#FDFBFD,1.0,#CDD1D4;pen-width=0;pen-color=#FFFFFF;can-move=0;can-mark=0;is-container=" + If(lReleaseB,'0','1') + ";")

					@ 13,20 Say STR0051 Of oTPanel Pixel //"Localização Pai"
					@ 11,60 MsGet cLocPai Picture "@!" SIZE 150,09 Of oTPanel When AllwaysFalse() Pixel

					@ 29,21 Say STR0052 COLOR CLR_HBLUE Of oTPanel Pixel //"Tipo Imagem"
					@ 26,60 Combobox oTipo	Var _cPgTipo Items aItems Size 69,50 Of oTPanel When lInclui;
											On Change AlterSayType(_cPgTipo,aItems,oSayCod,oSayDesc,oCodigo,@cCodigo,oDescri,@cDescri,cCodNiv);
											Valid ValInsertImg(_cPgTipo, ::cImgAtu, @oTipo) Pixel
					oTipo:bHelp := bHpPrShape

					@ 47,21 Say oSayCod Var STR0047+Space(4) COLOR CLR_HBLUE Of oTPanel Pixel //"Ilustração"

					If __nModPG == 56
						cF3 := GetTableF3(_cPgTipo)[1]
					EndIf

					@ 44,60 MsGet oCodigo Var cCodigo Picture "@!" F3 cF3 Valid ValidCpo(Self,_cPgTipo,cCodigo,@cDescri) SIZE 65,09 Of oTPanel;
						When _cPgTipo != "0" .And. lInclui Pixel HASBUTTON

					@ 61,22 Say oSayDesc Var STR0053 Of oTPanel Pixel //"Descrição"
					@ 57,60 MsGet oDescri Var cDescri Picture cPictDesc SIZE 150,09 Of oTPanel When !( _cPgTipo $ "1/A/B" ) Pixel
					oDescri:bHelp := { || ShowHelpCpo(NoAcento(AnsiToOem(STR0053)), ;
						{STR0366},5,; //"Indica a descrição da imagem."
						{},5)  }

					oGroup := TGroup():New(75,20,130,210,STR0054,oTPanel,CLR_BLACK,CLR_BLACK,.T.) //'Dimensão da Imagem'

						@ 90,35 Say STR0055 COLOR CLR_HBLUE Of oGroup Pixel //"Porcentagem"
						@ 88,75 MsGet oPorcent Var nPorcent Valid NaoVazio(nPorcent) Picture "@E 999,999.99%" on Change ChangePorc(nPorcent,nLargIni, nAltIni,@nLargura,@nAltura);
											 SIZE 50,09 Of oTPanel When &cWhenPor Pixel HASBUTTON
							oPorcent:bHelp := { || ShowHelpCpo(STR0055, ;
												{STR0367},5,; //"Indica um valor em porcentagem para o redimensionamento proporcional da imagem escolhida."
												{},0)  }

						@ 103,35 Say STR0056 Of oGroup Pixel //"Largura (Pixel)"
						@ 101,75 MsGet nLargura Valid NaoVazio(nLargura) Picture "@E 999.99" On Change fChgeSZShape( ( nLargIni * nAltIni ),@nPorcent,( nLargura * nAltura ) ) SIZE 15,09 Of oTPanel When &cWhenPor Pixel HASBUTTON

						@ 116,35 Say STR0057 Of oGroup Pixel //"Altura (Pixel)"
						@ 114,75 MsGet nAltura Valid NaoVazio(nAltura) Picture "@E 999.99" On Change fChgeSZShape( ( nLargIni * nAltIni ),@nPorcent,( nLargura * nAltura ) ) SIZE 15,09 Of oTPanel When &cWhenPor Pixel HASBUTTON

					oCheck := TCheckBox():New(130,20,STR0058,{||lCheck},oDlg,100,10) //'Bloquear Movimentação'

						oCheck:bLClicked   := {|| lCheck:=!lCheck }
						oCheck:bHelp := { || ShowHelpCpo(STR0059, ; //"Bloquear Movimen."
											{STR0060,; //"Indica se a imagem selecionada poderá se movimentar em modo de Edição dentro da Planta."
											STR0061,; //"Caso contrário a imagem ficará estática."
											STR0062},5)  }				 //"Será possível também Bloquear e Desbloquear utilizando o clique da direita sobre a imagem após a inclusão na Planta."

					@ 165,125 Button oConfirm Prompt STR0063 Size 38,12 Action (If(ValidProperty(_cPgTipo,cCodigo,cDescri,::cImgAtu) .And. ValInsertImg(_cPgTipo, ::cImgAtu, @oTipo, .T.),; //"Confirmar"
																											(lConfirm := .T.,oDlg:End()),)) Of oTPanel Pixel  Message "Ok - <Ctrl-O>"
						oConfirm:SetCss(CSSButton(.T.))
					@ 165,170 Button oCancel Prompt STR0064 Message STR0065 Size 38,12 Action (lConfirm := .F.,oDlg:End()) Of oTPanel Pixel //"Cancelar"###"Cancelar - <Ctrl-X>"
						oCancel:SetCss(CSSButton())

					If  ::aShape[nPosShape][__aShape_IndCod__] == "2" .And. ::aShape[nPosShape][__aShape_Planta__] == "1"
						_cPgTipo  := "3"
					Else
						_cPgTipo  := ::aShape[nPosShape][__aShape_IndCod__]
					EndIf

				AlterSayType(_cPgTipo,aItems,oSayCod,oSayDesc,oCodigo,@cCodigo,oDescri,@cDescri,cCodNiv)

				cCodigo  := ::aShape[nPosShape][__aShape_Codigo__]

				//----------------------------------------------------
				// Se o shape for do tipo Bem, busca descrição da ST9
				//----------------------------------------------------
				If _cPgTipo == "1" .And. __nModPG == 19
					cDescri  := NGSEEK("ST9",cCodigo,1,"ST9->T9_NOME")
				ElseIf _cPgTipo == "1" .And. __nModPG == 35
					cDescri  := NGSEEK("TMA", NGSEEK("TN0",cCodigo,1,"TN0->TN0_AGENTE"), 1, "TMA_NOMAGE" )
				ElseIf _cPgTipo == "A" .And. __nModPG == 56
					cDescri  := NGSEEK("SB1",cCodigo,1,"SB1->B1_DESC")
				ElseIf _cPgTipo == "B" .And. __nModPG == 56
					cDescri  := NGSEEK("TA4",cCodigo,1,"TA4->TA4_DESCRI")
			  //	ElseIf _cPgTipo == "C" .And. __nModPG == 56
					//cDescri  := NGSEEK("TDB",::aShape[nPosShape][__aShape_NivSup__] + AllTrim(cCodigo),1,"TDB->TDB_DESCRI")
				Else
					cDescri  := ::aShape[nPosShape][__aShape_Descri__]
				EndIf

				lCheck   := ::aShape[nPosShape][__aShape_Blocked__]

				If lInclui
					oTipo:SetFocus()
				ElseIf _cPgTipo != "1"
					oDescri:SetFocus()
				Else
					oPorcent:SetFocus()
				EndIf

				_oF3Tipo := @oTipo // copiando o oTipo

			ACTIVATE DIALOG oDlg ON INIT (SetKey(K_CTRL_O,oConfirm:bAction),;
								  					SetKey(K_CTRL_X,oCancel:bAction)) CENTERED
		Else
			MsgInfo(STR0519) //"Não é permitido alterar a propriedade de um Bem inserido através da Importação de Bens."
		EndIf

		If lConfirm

			If _cPgTipo == "1"
				::aShape[nPosShape][__aShape_Descri__]  := If(__nModPG == 35, cCodigo + " - " + cDescri, cCodigo + cDescri)
			Else
				::aShape[nPosShape][__aShape_Descri__]  := cDescri
			EndIf

	  		::ResizeImage(nShapeAtu,nLargura,nAltura)
			::aShape[nPosShape][__aShape_Filial__]  := cFilAnt
			::aShape[nPosShape][__aShape_Largura__] := nLargura
			::aShape[nPosShape][__aShape_Altura__]  := nAltura
			If __nModPG == 56
				::aShape[nPosShape][__aShape_Codigo__]  := Padr( cCodigo, Len((__cTrbTree)->CODTIPO))
			Else
				::aShape[nPosShape][__aShape_Codigo__]  := cCodigo
			Endif
			::aShape[nPosShape][__aShape_IndCod__]  := If(_cPgTipo == '3', '2', _cPgTipo)
			::aShape[nPosShape][__aShape_Planta__]  := If(_cPgTipo == '3', '1', '2')
			::aShape[nPosShape][__aShape_Blocked__] := lCheck

			If ::aShape[nPosShape][__aShape_Codigo__] == "001"
				::aShape[nPosShape][__aShape_NivSup__] := "000"
			EndIf

			If __nModPG == 56 .And. ( _cPgTipo $ "A/B" ) .And. lInclui // Residuo ## Aspecto
				::aShape[nPosShape][__aShape_Caract__] := { SgaUltSeq(::aShape, _cPgTipo, ::aShape[nPosShape][__aShape_Codigo__], ::aShape[nPosShape][__aShape_NivSup__]) }
			EndIf

			//Bloqueia/Desbloqueia Movimentacao do Shape
			::oTPanel:SetCanMove(nShapeAtu,!lCheck)
			::oTPanel:SetToolTip(nShapeAtu,Trim(cDescri))
			::InsertTree(::aShape[nPosShape][__aShape_IdShape__])

			//Coloca Foco no shape selecionado
			::SetImageFocus(.T.,nShapeAtu)

			//-----------------------------------------------------------------
			// Identifica que a planta teve alterações e necessita ser salva
			//-----------------------------------------------------------------
			::lModified := .T.
		EndIf

		::SetBlackPnl(.F.)
	EndIf

	::oTree:SetFocus()

Return lConfirm

//---------------------------------------------------------------------
/*/{Protheus.doc} GetTableF3
Verifica as tabelas de acordo com o cTipo
(Planta Gráfica/Localização/Resíduo/Aspecto/Ponto Coleta)
e retorna as tabelas relacionadas.

cTableF3 = Tabela utilizada
cTableRel = Tabelas relacionadas
aNao = Tabelas que não serão consideras na exclusão da tabela em questão

@param cTipo Indica o tipo de item adicionado na planta.
@author Gabriel Werlich
@since 04/03/2010
@version MP10
@return .T. ou .F.
/*/
//---------------------------------------------------------------------
Static Function GetTableF3(cTipo)

	Local cTableF3	:= ""
	Local cTableRel	:= ""
	Local aNao := {}

	Do Case
		Case cTipo == "2" .Or. cTipo == "3"
			cTableF3 := "TAF"
			aNao := {"TAK"}

		Case cTipo == "A"
			cTableF3	:= "TAX"
			cTableRel := "TAV"

			aNao    	:= {"TAV","TAZ","TF1","TF2","TB7","TH0"}

		Case cTipo == "B"
			cTableF3	:= "TA4"
			cTableRel := "TAG"
			aNao    	:= {"TA9","TAG","TAJ"}

		Case cTipo == "C"
			cTableF3 := "TDB"

		Case cTipo == "D"
			cTableF3 := "TBB"

	EndCase

	If Empty(cTableRel)
		cTableRel := cTableF3
	Endif

Return { cTableF3, cTableRel, aNao }

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidProperty
Função que valida dados preenchidos na Dialog do metodo PropertyShape

@param cPgTipo Indica o tipo de item adicionado n planta
@param cCodigo Código do item
@param cDescri Descrição do item
@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return .T. ou .F.
/*/
//---------------------------------------------------------------------
Static Function ValidProperty(cPgTipo,cCodigo,cDescri)
	If cPgTipo == "0"
		If Empty(cDescri)
			Help(" ",1,"OBRIGAT",,Space(60),3)
			Return .F.
		EndIf
	ElseIf Empty(cCodigo)
		Help(" ",1,"OBRIGAT",,Space(60),3)
		Return .F.
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidCpo
Função que valida campo Codigo da Dialog do metodo PropertyShape

@param oPG Objeto TNGPG
@param _cPgTipo Tipo de item adicionado
@param cCodigo Código do item
@param cDescri Descrição do item
@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return lRet Indica que conteúdo do campo está correto
/*/
//---------------------------------------------------------------------
Static Function ValidCpo(oPG,_cPgTipo,cCodigo,cDescri)
	Local lRet   := .F.
	Local aArea := {}

	cDescri := Space(Len(TAF->TAF_NOMNIV))
	If Empty(cCodigo)
		Return .T.
	EndIf

	If _cPgTipo == "0"
		lRet := .T.
	ElseIf _cPgTipo == "1"
		If __nModPG == 19
			dbSelectArea("ST9")
			dbSetOrder(1)
			If dbSeek(xFilial("ST9")+cCodigo)
				If ST9->T9_SITBEM != "A"
					MsgStop(STR0066 + AllTrim(cCodigo) + STR0067) //"Bem "###" está Inativo ou foi transferido."
					lRet := .F.
				Else
					dbSelectArea(oPG:cTrbTree)
					dbSetOrder(3)
					If dbSeek("1"+cCodigo) .And. !Empty((oPG:cTrbTree)->IMAGEM) .And. Empty((oPG:cTrbTree)->DELETADO)
						MsgStop(STR0066 + AllTrim(cCodigo) + STR0068) //"Bem já está cadastrado na Estrutura"
						lRet := .F.
					ElseIf dbSeek("1"+cCodigo) .And. cTipoAtual $ "2/3" .And. (__cTrbTree)->PGSUP != cPlantaSup .And. Empty((oPG:cTrbTree)->DELETADO)
						MsgStop(STR0401) //"Somente bens que estão contidos no nível selecionado ou que ainda não foram cadastrados poderão ser representados graficamente."
						lRet := .F.
					Else
						cDescri := ST9->T9_NOME
						lRet := .T.
					EndIf
				EndIf
			Else
				Help(" ",1,"REGNOIS")
			EndIf
		ElseIf __nModPG == 35
			//Busca os Riscos conforme a estrutura da Árvore.
			aRiscos := fBuscaRisco()
			If aScan( aRiscos, { | x | Alltrim( UPPER( x[1] ) ) == Alltrim( UPPER( cCodigo ) ) } ) > 0
				dbSelectArea(oPG:cTrbTree)
				dbSetOrder(3)
				If dbSeek("7"+cCodigo) .And. !Empty((oPG:cTrbTree)->IMAGEM) .And. Empty((oPG:cTrbTree)->DELETADO)
					MsgStop(STR0414 +" "+ AllTrim(cCodigo) + STR0068) //"Risco"###" já está cadastrado na Estrutura"
					lRet := .F.
				Else
					cDescri := NGSEEK( "TMA", NGSeek("TN0", cCodigo, 1, "TN0_AGENTE") , 1, "TMA_NOMAGE" )
					lRet := .T.
				EndIf
			Else
				Help(" ",1,"REGNOIS")
			EndIf

		EndIf

	ElseIf _cPgTipo $ "2/3"

		dbSelectArea(oPG:cTrbTree)
		dbSetOrder(2)
		If dbSeek("001"+Substr(cCodigo,1,3)+cFilAnt) .And. (oPG:cTrbTree)->TIPO $ "2/3" .And. Empty((oPG:cTrbTree)->DELETADO)
			If !Empty((oPG:cTrbTree)->IMAGEM)
				MsgStop(STR0069 + AllTrim(cCodigo) + STR0068) //"Localização "##" já está cadastrada na Estrutura"
				lRet := .F.
			ElseIf (oPG:cTrbTree)->CODPRO == cNivAtual  .And. (oPG:cTrbTree)->PLANTA == "1"
				MsgStop(STR0403) //"Não pode ser atribuido representação gráfica ao nível principal."
				lRet := .F.
			ElseIf (__cTrbTree)->PGSUP != cPlantaSup
				MsgStop(STR0402)//"Somente itens que estão contidos na planta gráfica poderam ser representados graficamente."
				lRet := .F.
			Else
				cDescri := (oPG:cTrbTree)->DESCRI
				lRet := .T.
			EndIf
		Else
			Help(" ",1,"REGNOIS")
		EndIf

	ElseIf _cPgTipo == "A"

		If ExistCpo("TAX", cCodigo)
			cDescri := NGSEEK( "SB1", cCodigo , 1, "B1_DESC" )
			lRet    := .T.
		EndIf

	ElseIf _cPgTipo == "B"

		If ExistCpo("TA4", cCodigo)
			cDescri := NGSeek("TA4", cCodigo, 1, "TA4_DESCRI")
			lRet    := .T.
		EndIf

	ElseIf _cPgTipo == "C"

		aAdd(aArea,GetArea())
		aAdd(aArea,(oPG:cTrbTree)->(Getarea()))

		dbSelectArea(oPG:cTrbTree)
		dbSetOrder(3)
		If dbSeek( _cPgTipo + Padr(cCodigo, Len((oPG:cTrbTree)->CODTIPO)) + cDepto490 ) .And. Empty((oPG:cTrbTree)->DELETADO) .And. !Empty((oPG:cTrbTree)->IMAGEM)
			Help(" ",1,"JAEXISTINF")
		Else
			aAdd(aArea,TDB->(GetArea()))
			dbSelectArea("TDB")
			dbSetOrder(1)
			If dbSeek(xFilial("TDB")+cDepto490+cCodigo)
				cDescri := TDB_DESCRI
				lRet    := .T.
			Else
				lRet := MsgYesNo(STR0476) //"Ponto de coleta não encontrado. Deseja incluí-lo?"
			Endif
			RestArea(aArea[3])
		Endif
		RestArea(aArea[2])
		RestArea(aArea[1])

	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} ChangePorc
Função que calcula a Largura e Altura de acordo com porcentagem

@param nPorcent Porcentagem do tamanho real da imagem
@param nLargIni Largura atual da imagem
@param nAltIni Altura atual da imagem
@param nLargura Largura nova da imagem (parametro passado como referencia)
@param nAltura Altura nova da imagem (parametro passado como referencia)
@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return .T.
/*/
//---------------------------------------------------------------------
Static Function ChangePorc(nPorcent,nLargIni, nAltIni,nLargura,nAltura)

	nLargura := nLargIni * (nPorcent/100)
	nAltura  := nAltIni * (nPorcent/100)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} AlterSayType
Função que altera Say do Codigo da Dialog do metodo PropertyShape

@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return .T.
/*/
//---------------------------------------------------------------------
Static Function AlterSayType(_cPgTipo,aItems,oSayCod,oSayDesc,oCodigo,cCodigo,oDescri,cDescri,cCodNiv)

	Local aF3		:= {}
	Local aSpace	:= {}
	Local nPosItem  := 0

	If __nModPG == 19

		aF3    := {"","ST9NIV","MNTGEN","MNTGEN"}
		aSpace := {"",Space(Len(ST9->T9_CODBEM)),Space(Len(TAF->TAF_CODNIV)),Space(Len(TAF->TAF_CODNIV))}

	ElseIf __nModPG == 35

		aF3    := {"","MDTGEN","MNTGEN","MNTGEN"}
		aSpace := {"",Space(Len(TN0->TN0_NUMRIS)),Space(Len(TAF->TAF_CODNIV)),Space(Len(TAF->TAF_CODNIV))}

	ElseIf __nModPG == 56

		aF3   		:= {	"", "TAX", "MNTGEN", "MNTGEN", "TA4", "TDB"	}
		aSpace		:= {	"",;
								Space(Len(TAX->TAX_CODRES)),;
								Space(Len(TAF->TAF_CODNIV)),;
								Space(Len(TAF->TAF_CODNIV)),;
								Space(Len(TA4->TA4_CODASP)),;
								Space(Len(TDB->TDB_CODIGO)),;
							}
		nPosItem := GetTipoItm(_cPgTipo)
	EndIf

	If Empty(nPosItem)
		nPosItem := Val(_cPgTipo) + 1
	Endif

	oSayCod:SetText(Substr(aItems[nPosItem],3,Len(aItems[nPosItem])))
	oCodigo:cF3 := aF3[nPosItem]
	cCodigo  := aSpace[nPosItem]

	cDescri  := Space(Len(TAF->TAF_NOMNIV))

	If _cPgTipo == "0"
		cCodigo := cCodNiv
		oDescri:SetFocus()
	EndIf

	oSayCod:nClrText  := CLR_BLACK
	oSayDesc:nClrText := CLR_HBLUE

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} GetTipoItm
Retorna qual é o tipo do item passado por paramêtro.

@param cTipo
@author Gabriel Werlich
@since 04/03/2010
@version MP10
@return nItem
/*/
//---------------------------------------------------------------------
Static Function GetTipoItm(cTipo)

	Local nItem := 0

	Do Case
		Case cTipo == "A"
			nItem := 2
		Case cTipo == "B"
			nItem := 5
		Case cTipo == "C"
			nItem := 6
		Case cTipo == "D"
			nItem := 7
	EndCase

Return nItem

//---------------------------------------------------------------------
/*/{Protheus.doc} GetNivSup
Método que retorna o Nivel superior para uma posicao X e Y na Planta

@param nPosX Posicao em X na Planta Grafica
@param nPosY Posicao em Y na Planta Grafica
@param nLessId Desconsidera um codigo de Id na verificacao
@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return cCargo
/*/
//---------------------------------------------------------------------
Method GetNivSup(nPosX,nPosY,nLessId) Class TNGPG
	Local nX
	Local nDeLargura, nDeAltura
	Local nAteLargura, nAteAltura
	Local cMovement := "", cAteMovement

	Local nLargura := nAltura := 0
	Local cCargo   := ::cPlantaAtu

	Default nLessId := 0

	For nX := 1 to Len(::aShape)
		If ::cPlantaAtu == ::aShape[nX][__aShape_PlanSup__] .And. cFilAnt == ::aShape[nX][__aShape_Filial__]
			If ::aShape[nX][__aShape_IdShape__] != nLessId .And. ::aShape[nX][__aShape_IndCod__] == "2" .And.;//Localizacao
				::aShape[nX][__aShape_Planta__]  == "2"

				nDeLargura := ::aShape[nX][__aShape_PosX__]
				nDeAltura  := ::aShape[nX][__aShape_PosY__]
				nAteLargura:= ::aShape[nX][__aShape_PosX__]+::aShape[nX][__aShape_Largura__]
				nAteAltura := ::aShape[nX][__aShape_PosY__]+::aShape[nX][__aShape_Altura__]
				cAteMovement  := ::aShape[nX][__aShape_Movement__]
				//Se a Imagem esta dentro de uma localizacao
				If nPosX >= nDeLargura .And. nPosY >= nDeAltura .And. nPosX <= nAteLargura .And. nPosY <= nAteAltura
					//Se esta localizacao esta dentro de outra
					If cAteMovement > cMovement//nLargura < nDeLargura .And. nAltura < nDeAltura
						cMovement := cAteMovement
						cCargo   := ::aShape[nX][__aShape_Cargo__]
						nLargura := ::aShape[nX][__aShape_PosX__]
						nAltura  := ::aShape[nX][__aShape_PosY__]
					EndIf

				EndIf
			EndIf
		EndIf

	Next nX

Return cCargo

//---------------------------------------------------------------------
/*/{Protheus.doc} SetCanMoveAll
Método que retorna o Nivel superior para uma posicao X e Y na Planta

@param lMove .T. Permite movimentar / .F. Bloqueia
@param lPlanta Indica se afetara somente a planta em foco
@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Method SetCanMoveAll(lMove,lPlanta) Class TNGPG
	Local nX

	Default lMove   := .T.
	Default lPlanta := .T.

	For nX := 1 To Len(::aShape)
		If !::aShape[nX][__aShape_Blocked__] .And. (!lPlanta .Or. ::cPlantaAtu == ::aShape[nX][__aShape_PlanSup__])
			::oTPanel:SetCanMove(::aShape[nX][__aShape_IdShape__],lMove)
		EndIf
	Next nX
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} GetDirectory
Método que retorna o diretorio de arquivos utilizado pela Thread

@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return __cDirectory__ DEFINE do diretorio
/*/
//---------------------------------------------------------------------
Method GetDirectory() Class TNGPG
	Local cDirectory := __cDirectory__

	cDirectory += __cBARRAS__

Return InsertLinux(cDirectory)

//---------------------------------------------------------------------
/*/{Protheus.doc} GetShapeAtu
Método que retorna o Id ultimo shape selecionado

@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return ShapeAtu
/*/
//---------------------------------------------------------------------
Method GetShapeAtu() Class tNGPG
Return ::oTPanel:ShapeAtu

//---------------------------------------------------------------------
/*/{Protheus.doc} GetPosShape
Método que retorna a Posicao na Array aShape de um Id informado

@param nShapeAtu Id do shape em foco
@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return nPosShape
/*/
//---------------------------------------------------------------------
Method GetPosShape(nShapeAtu) Class tNGPG
	Local nPosShape := aScan(::aShape,{|aShape| aShape[__aShape_IdShape__] == nShapeAtu})
	Local nX

	If nPosShape == 0 .And. !::lEditMode
		nPosShape := aScan(::aShape,{|aShape| ScanPosAlert(aShape,nShapeAtu) })
	EndIf

Return nPosShape

//---------------------------------------------------------------------
/*/{Protheus.doc} ScanPosAlert
Método que verifica se ShapeAtu é um shape de Alerta na array aShape

@param nShapeAtu Id do shape em foco
@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return lRet
/*/
//---------------------------------------------------------------------
Static Function ScanPosAlert(aShape,nShapeAtu)
	Local lRet := .F.
	If Len(aShape[__aShape_Alertas__]) > 0
		lRet := 	(aShape[__aShape_Alertas__][1][__aShape_aAlerta_Visible__] .And. aShape[__aShape_Alertas__][1][__aShape_aAlerta_IdShape__] == nShapeAtu) .Or.;
					(aShape[__aShape_Alertas__][2][__aShape_aAlerta_Visible__] .And. aShape[__aShape_Alertas__][2][__aShape_aAlerta_IdShape__] == nShapeAtu) .Or.;
					(aShape[__aShape_Alertas__][3][__aShape_aAlerta_Visible__] .And. aShape[__aShape_Alertas__][3][__aShape_aAlerta_IdShape__] == nShapeAtu) .Or.;
					(aShape[__aShape_Alertas__][4][__aShape_aAlerta_Visible__] .And. aShape[__aShape_Alertas__][4][__aShape_aAlerta_IdShape__] == nShapeAtu) .Or.;
					(aShape[__aShape_Alertas__][5][__aShape_aAlerta_Visible__] .And. aShape[__aShape_Alertas__][5][__aShape_aAlerta_IdShape__] == nShapeAtu)
	EndIf
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} CreateShapeOfTree
Método que cria Shape de acordo com dados da TAF

@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Method CreateShapeOfTree(lRefTAF) Class TNGPG

	Local aArea := GetArea()
	Local lRisco := __nModPG == 35 .And. TAF->TAF_INDCON == "7"

	Local nAltura, nLargura, nId, cImageShape
	Local cDirImg, cSetMark, aTableRef

	Local aCargo  := {}
	Local nAllImg := 0
	Local lOk := .F.

	Default lRefTAF := .T.

	If __nModPG == 19 .Or. __nModPG == 35
		aCargo  := { {"0","ILU"},{"1","BEM"},{"2","LOC"},{"3","PLAN"} }
	ElseIf __nModPG == 56
		aCargo  := GetInfoTp()
	EndIf

	aTableRef := GetRefTab(lRefTAF, Self)

	If !Empty(aTableRef[__aTable_Shape_Imagem__])

		If (nAllImg := aScan(::aAllImg,{|x| x[__aAllImg_TipImg__]+x[__aAllImg_Imagem__] == aTableRef[__aTable_Shape_TpImg__]+aTableRef[__aTable_Shape_Imagem__]})) == 0

			cDirImg := ::ExportImage(aTableRef[__aTable_Shape_TpImg__],aTableRef[__aTable_Shape_Imagem__])
			oBmp := TBitmap():New(00,00,0,0,,,.T.,,,,,.F.,,,,,.T.)
				oBmp:Hide()

			If oBmp:Load(,cDirImg)
				lOk := .T.
				oBmp:lAutoSize := .T.
				oBmp:lTransparent := .T.
				nLargura := oBmp:nClientWidth
				nAltura  := oBmp:nClientHeight

				aAdd(::aAllImg,Array(5))
				nAllImg := Len(::aAllImg)
				::aAllImg[nAllImg][__aAllImg_TipImg__]  := aTableRef[__aTable_Shape_TpImg__]
				::aAllImg[nAllImg][__aAllImg_Imagem__]  := aTableRef[__aTable_Shape_Imagem__]
				::aAllImg[nAllImg][__aAllImg_DirImg__]  := cDirImg
				::aAllImg[nAllImg][__aAllImg_Largura__] := nLargura
				::aAllImg[nAllImg][__aAllImg_Altura__]  := nAltura

			EndIf

			oBmp:Free()
		Else
			lOk := .T.
			cDirImg  := ::aAllImg[nAllImg][__aAllImg_DirImg__]
			nLargura := ::aAllImg[nAllImg][__aAllImg_Largura__]
			nAltura  := ::aAllImg[nAllImg][__aAllImg_Altura__]
		EndIf

		If nAllImg > 0

			aAdd(::aShape,Array(__Len_aShape__))

			nPosShape	:= Len(::aShape)
			nId 			:= ::SetId()

			::aShape[nPosShape][__aShape_PlanSup__] := ::cPlantaAtu
			::aShape[nPosShape][__aShape_IdShape__] := nId
			::aShape[nPosShape][__aShape_PosX__]    := aTableRef[__aTable_Shape_PosX__]
			::aShape[nPosShape][__aShape_PosY__]    := aTableRef[__aTable_Shape_PosY__]
			::aShape[nPosShape][__aShape_Largura__] := 0 //TAF->TAF_TAMX
			::aShape[nPosShape][__aShape_Altura__]  := 0 //TAF->TAF_TAMY
			::aShape[nPosShape][__aShape_LargIni__] := nLargura //TAF->TAF_TAMX
			::aShape[nPosShape][__aShape_AltIni__]  := nAltura //TAF->TAF_TAMY
			::aShape[nPosShape][__aShape_Image__]   := cDirImg
			::aShape[nPosShape][__aShape_ImgIni__]  := cDirImg
			::aShape[nPosShape][__aShape_Movement__]:= aTableRef[__aTable_Shape_Ordem__] //::cMovement
			::aShape[nPosShape][__aShape_Blocked__] := aTableRef[__aTable_Shape_MovBlo__] == "1"
			::aShape[nPosShape][__aShape_IndCod__]  := If(aTableRef[__aTable_Shape_IndCon__] == "7" .And. __nModPG == 35, "1", aTableRef[__aTable_Shape_IndCon__])
			::aShape[nPosShape][__aShape_Descri__]  := aTableRef[__aTable_Shape_NomNiv__]
			::aShape[nPosShape][__aShape_Planta__]  := aTableRef[__aTable_Shape_Planta__]
			::aShape[nPosShape][__aShape_TipoImg__] := aTableRef[__aTable_Shape_TpImg__]
			::aShape[nPosShape][__aShape_NivSup__]  := aTableRef[__aTable_Shape_NivSup__]

			If cValToChar(__nModPg) $ "19/35"
				::aShape[nPosShape][__aShape_Codigo__]  := If(aTableRef[__aTable_Shape_IndCon__] $ "1/7",aTableRef[__aTable_Shape_CodCon__],aTableRef[__aTable_Shape_CodNiv__])
				::aShape[nPosShape][__aShape_Cargo__]   := aTableRef[__aTable_Shape_CodNiv__] + If( lRisco, "RIS", aCargo[Val(aTableRef[__aTable_Shape_IndCon__])+1][2])+cFilAnt
			ElseIf __nModPg == 56
				::aShape[nPosShape][__aShape_Codigo__]  :=  If(aTableRef[__aTable_Shape_IndCon__] $ "A/B/C/D", aTableRef[__aTable_Shape_CodCon__], aTableRef[__aTable_Shape_CodNiv__])
				::aShape[nPosShape][__aShape_Cargo__]   := aTableRef[__aTable_Shape_CodNiv__] + RetInfoTp( aCargo, aTableRef[__aTable_Shape_IndCon__] )[2]+cFilAnt
			EndIf

			::aShape[nPosShape][__aShape_Alertas__] := {}
			::aShape[nPosShape][__aShape_Visivel__] := .T.
			::aShape[nPosShape][__aShape_Permit__]  := (::cTrbTree)->PERMISS
			::aShape[nPosShape][__aShape_Filial__]  := cFilAnt

			If (::aShape[nPosShape][__aShape_IndCod__] == "0" .And. !::lEditMode) .Or. !(::cTrbTree)->PERMISS
				cSetMark := "can-mark=0;"
			Else
				cSetMark := "can-mark=1;"
			EndIf

			::aShape[nPosShape][__aShape_Caract__]  := aClone(aTableRef[__aTable_Shape_Caract__])

			cImageShape := ::aShape[nPosShape][__aShape_ImgIni__]
			cImageShape := RemoveLinux(cImageShape)

			::oTPanel:addShape( "id="+cValToChar(nId)+";type=8;left="+cValToChar(::aShape[nPosShape][__aShape_PosX__])+";top="+cValToChar(::aShape[nPosShape][__aShape_PosY__])+;
							    ";width="+cValToChar(nLargura)+";height="+cValToChar(nAltura)+";image-file="+lower(cImageShape)+";can-move=1;can-deform=1;is-container=" + If(lReleaseB,'0','1') + ";"+;
								"tooltip="+AllTrim(aTableRef[__aTable_Shape_NomNiv__])+";"+cSetMark)

			//Define na array de controle o tamanho do Shape
	  		::ResizeImage(nId,aTableRef[__aTable_Shape_TamX__],aTableRef[__aTable_Shape_TamY__])

			//Bloqueia a movimentacao
			If ::aShape[nPosShape][__aShape_Blocked__]
				::oTPanel:SetCanMove(nId,.F.)
			EndIf

		EndIf
	EndIf
	RestArea(aArea)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} GetInfoTp
Retorna um array contendo os itens de SGA.

@author Gabriel Augusto Werlich
@since 04/08/2014
@version MP11
@return aTableRef
/*/
//---------------------------------------------------------------------
Static Function GetInfoTp()
Return { {"0","ILU"},{"A","RES","NG_ICO_RESIDUO"},{"2","LOC"},{"3","PLAN"},{"B","ASP","NG_ICO_ASPECTO"},{"C","PTO","NG_ICO_PCOLETA"} }

//---------------------------------------------------------------------
/*/{Protheus.doc} GetRefTab
Define estrutura de construção do shape a partir de uma determinada tabela.

@author Gabriel Augusto Werlich
@since 04/08/2014
@version MP11
@return aTableRef
/*/
//---------------------------------------------------------------------
Static Function GetRefTab(lRefTAF, oPgClass)

	Local aTableRef	:= {}
	Local aCaract  	:= {}

	Default lRefTAF := .T.

	If lRefTAF

		aTableRef := {	TAF->TAF_IMAGEM,;	//1
				 			TAF->TAF_TIPIMG,;	//2
				 			TAF->TAF_POSX,; 	//3
				 			TAF->TAF_POSY,;	//4
				 			TAF->TAF_ORDEM,;	//5
				 			TAF->TAF_MOVBLO,;	//6
				 			TAF->TAF_CODCON,;	//7
				 			TAF->TAF_INDCON,;	//8
				 			TAF->TAF_NOMNIV,;	//9
				 			TAF->TAF_PLANTA,;	//10
				 			TAF->TAF_NIVSUP,;	//11
				 			TAF->TAF_CODNIV,;	//12
				 			TAF->TAF_TAMX,; 	//13
				 			TAF->TAF_TAMY,; 	//14
				 			{},;
				 		}

	Else

		If __nModPG == 56
			If !Empty((oPGClass:cTrbTree)->SEQUEN)
				aCaract := { (oPGClass:cTrbTree)->SEQUEN }
			Endif
		Endif

		aTableRef := {	(oPgClass:cTrbTree)->IMAGEM,;	//1
				 			(oPgClass:cTrbTree)->TIPIMG,;	//2
				 			(oPgClass:cTrbTree)->POSX,; 	//3
				 			(oPgClass:cTrbTree)->POSY,;		//4
				 			(oPgClass:cTrbTree)->ORDEM,;	//5
				 			(oPgClass:cTrbTree)->MOVBLO,;	//6
				 			(oPgClass:cTrbTree)->CODTIPO,;	//7
				 			(oPgClass:cTrbTree)->TIPO,;		//8
				 			(oPgClass:cTrbTree)->DESCRI,;	//9
				 			(oPgClass:cTrbTree)->PLANTA,;	//10
				 			(oPgClass:cTrbTree)->NIVSUP,;	//11
				 			(oPgClass:cTrbTree)->CODPRO,;	//12
				 			(oPgClass:cTrbTree)->TAMX,; 	//13
				 			(oPgClass:cTrbTree)->TAMY,; 	//14
				 			aClone(aCaract);
					 	}

	EndIf

Return aTableRef

//---------------------------------------------------------------------
/*/{Protheus.doc} RetInfoTp
Função para buscar o cCargo a partir de array.

@author Gabriel Augusto Werlich
@since 26/06/2014
@version MP11
@return cCargo
/*/
//---------------------------------------------------------------------
Static Function RetInfoTp( aCargo, cIndCon )

	Local aInfoTp := {}

	If !Empty(cIndCon).And. (nPosCargo := aScan( aCargo, {|x| x[1] == cIndCon } )) > 0
		aInfoTp := aClone( aCargo[nPosCargo] )
	Endif

Return aInfoTp

//---------------------------------------------------------------------
/*/{Protheus.doc} SavePg
Método que salva informacoes feitas na Planta Grafica e Arvore Logica

@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Method SavePg(lFinal) Class TNGPG

	Local aAreaTree := (::oTree:cArqTree)->(GetArea())

	Local lIncTAF   := .F. // DEFINE SE ESTÁ REALIZANDO A INCLUSÃO DE UM NOVO REGISTRO NA ÁRVORE(TAF).
	Local lAltTAF   := .F. // DEFINE SE ESTÁ ALTERANDO DE LOCAL UM ITEM JÁ EXISTENTE NA ÁRVORE(TAF).
	Local nFld, nPosShape, nPosNivSup
	Local aRegExc, aRecNiv, aTrbArea
	Local lRateio := NGCADICBASE('TAF_RATEIO','D','TAF',.F.)
	Local lEtapa  := NGCADICBASE('TAF_ETAPA','D','TAF',.F.)
	Local lCodAmb := NGCADICBASE('TAF_CODAMB','D','TAF',.F.)
	Local lDepto  := NGCADICBASE('TAF_DEPTO' ,'D','TAF',.F.)
	Local cEvento := ""
	Local cCCusto := ""
	Local cCentra := ""
	Local cOrdem  := "000"
	Local cHora
	Local cTipoGrv
	Local cAliasQry
	Local cSvNivSup := ""
	Local aNewCod   := {}
	Local aRetTC    := {}

	//Guarda bloco de codigo das telhas de atalho
	Local aKeys := GetKeys()

	Default lFinal := .F.

	Private cSvLocal := "000"

	//Limpa tecla de atalhos para nao poderem ser executados
	RestKeys(,.T.)

	If ::lEditMode

		If __nModPG == 56
			dbSelectArea("TAF")
			dbSetOrder(2)
			If dbSeek(xFilial("TAF"))
				cAliasQry := GetNextAlias()
				cQuery := " SELECT MAX(TAF.TAF_CODNIV) cCodMax FROM "+RetSqlName("TAF")+" TAF "
				cQuery += " WHERE TAF.TAF_FILIAL = '"+xFilial("TAF")+"' AND TAF.D_E_L_E_T_ <> '*'"
				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

				dbSelectArea(cAliasQry)
				dbGoTop()
				If !Eof()
					cSvLocal := (cAliasQry)->cCodMax
				EndIf
				(cAliasQry)->(dbCloseArea())
			EndIf
		Endif

		aRegExc  := {}
		aRecNiv  := {}
		cHora    := Substr(Time(),1,5)
		cTipoGrv := "0/1/2"

		If __nModPG == 35
			cTipoGrv += "/3/4/7"
		ElseIf __nModPG == 56
			cTipoGrv := "0/2"
		Endif

		dbSelectArea(::cTrbTree)
		dbSetOrder(5)
		dbGoTop()
		ProcRegua(Reccount())
		While (::cTrbTree)->(!Eof())

			IncProc()

			If !( (::cTrbTree)->TIPO $ cTipoGrv )
				dbSelectArea(::cTrbTree)
				dbSkip()
				Loop
			EndIf

			//Reordena campo TAF_ORDEM
			cOrdem := If(FindFunction("Soma1Old"),Soma1Old(AllTrim(cOrdem)),Soma1(AllTrim(cOrdem)))
			cSvNivSup := (::cTrbTree)->NIVSUP

				//Evento da Planta Grafica
			If (::cTrbTree)->PLANTA == '1'
				If __nModPG == 19
					cEvento := (::cTrbTree)->EVENTO
				ElseIf __nModPG == 35
					cEvento := (::cTrbTree)->EVEMDT
				ElseIf __nModPG == 56
					cEvento := (::cTrbTree)->EVESGA
				EndIf
			EndIf

			dbSelectArea('TAF')
			dbSetOrder(2)
			If dbSeek(xFilial('TAF')+ (::cTrbTree)->CODEST+ (::cTrbTree)->CODPRO)

				lIncTAF := .F.

				If FindFunction( 'MntUpdTAF' ) .And. TAF->TAF_INDCON == '1'

					lAltTAF := MntUpdTAF( { TAF->TAF_CODEST, TAF->TAF_NIVSUP, TAF->TAF_FILIAL },;
				 					{ (::cTrbTree)->CODEST, (::cTrbTree)->NIVSUP, (::cTrbTree)->FILIAL }, ::cTrbTree )

				Else

					lAltTAF := .F.

				EndIf

				RecLock('TAF',.F.)
				If !Empty( (::cTrbTree)->DELETADO )
					dbDelete()
					MsUnLock('TAF')

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Exclui Bem/Localizacao na Restricao de Acesso ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If FindFunction("NGDeleteTUB")
						NGDeleteTUB()
					EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Exclui Bem/Localizacao na Restricao de Acesso ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If FindFunction("NGDeleteTUB")
						NGDeleteTUB()
					EndIf

						//Grava Exclusao do Item na tabela de Historico de Movimentacao
					If (::cTrbTree)->TIPO != "0" //Ilustracao
						If AliasInDic("TCJ")
							dbSelectArea("TCJ")
							dbSetOrder(1)
							If !dbSeek(xFilial("TCJ")+(::cTrbTree)->CODPRO+(::cTrbTree)->NIVSUP+'E'+DTOS(dDataBase)+cHora)
								RecLock("TCJ",.T.)
								TCJ->TCJ_FILIAL := xFilial("TCJ")
								TCJ->TCJ_CODNIV := (::cTrbTree)->CODPRO
								TCJ->TCJ_DESNIV := (::cTrbTree)->DESCRI
								TCJ->TCJ_NIVSUP := (::cTrbTree)->NIVSUP
								TCJ->TCJ_DATA   := dDataBase
								TCJ->TCJ_HORA   := cHora
								TCJ->TCJ_TIPROC := "E" //Exclusao
								IF NGCADICBASE("TCJ_MODSGA","D","TCJ",.f.)
									TCJ->TCJ_NIVEL := (::cTrbTree)->NIVEL
									If __nModPG == 56
										TCJ->TCJ_MODSGA:= "X"
									ElseIf __nModPG == 35
										TCJ->TCJ_MODMDT:= "X"
									ElseIf __nModPG == 19
										TCJ->TCJ_MODMNT:= "X"
									EndIf
								Endif
								MsUnLock("TCJ")
							EndIf
						EndIf
					EndIf

					dbSelectArea(::cTrbTree)
					dbSkip()
					Loop
				EndIf

					//Grava Alteracao da Ordem do Item na tabela de Historico de Movimentacao
				If TAF->TAF_NIVSUP != (::cTrbTree)->NIVSUP .And. (::cTrbTree)->TIPO != "0" //Ilustracao
					If AliasInDic("TCJ")
						dbSelectArea("TCJ")
						dbSetOrder(1)
						If !dbSeek(xFilial("TCJ")+(::cTrbTree)->CODPRO+(::cTrbTree)->NIVSUP+'O'+DTOS(dDataBase)+cHora)
							RecLock("TCJ",.T.)
							TCJ->TCJ_FILIAL := xFilial("TCJ")
							TCJ->TCJ_CODNIV := (::cTrbTree)->CODPRO
							TCJ->TCJ_DESNIV := (::cTrbTree)->DESCRI
							TCJ->TCJ_NIVSUP := (::cTrbTree)->NIVSUP
							TCJ->TCJ_DATA   := dDataBase
							TCJ->TCJ_HORA   := cHora
							TCJ->TCJ_TIPROC := "O" //Alteracao da ordem
							IF NGCADICBASE("TCJ_MODSGA","D","TCJ",.f.)
								TCJ->TCJ_NIVEL := (::cTrbTree)->NIVEL
								If __nModPG == 56
									TCJ->TCJ_MODSGA:= "X"
								ElseIf __nModPG == 35
									TCJ->TCJ_MODMDT:= "X"
								ElseIf __nModPG == 19
									TCJ->TCJ_MODMNT:= "X"
								EndIf
							Endif
							MsUnLock("TCJ")
						EndIf
					EndIf
				EndIf

				TAF->TAF_CODNIV := (::cTrbTree)->CODPRO
				TAF->TAF_ORDEM  := cOrdem//(::cTrbTree)->ORDEM
			Else
				If !Empty( (::cTrbTree)->DELETADO )
					aAdd(aRegExc, (::cTrbTree)->CODPRO)
					dbSelectArea(::cTrbTree)
					dbSkip()
					Loop
				EndIf

				If __nModPG == 56

					// Verifica se o nivel superior do item foi alterado
					If ( nPosNivSup := aScan(aNewCod, {|x| x[2] == (::cTrbTree)->NIVSUP}) ) > 0
						cSvNivSup := aNewCod[nPosNivSup][3]

						If !lFinal // Altera a tabela temporaria caso nao esteja saindo da rotina
							dbSelectArea(::cTrbTree)
							RecLock(::cTrbTree,.F.)
							(::cTrbTree)->NIVSUP := cSvNivSup
							MsUnlock(::cTrbTree)
						Endif

					EndIf

					// Gera nova ordem para o item atual
					If FindFunction("Soma1Old")
						cSvLocal := Soma1Old(AllTrim(cSvLocal))
					Else
						cSvLocal := Soma1(AllTrim(cSvLocal))
					EndIf

					// Caso a ordem gerada seja diferente da atual
					If cSvLocal <> (::cTrbTree)->CODPRO
						aAdd( aNewCod, { (::cTrbTree)->(Recno()), (::cTrbTree)->CODPRO, cSvLocal, 0, 0 } )

						// Verifica se existe representacao na Tree para o item
						dbSelectArea(::oTree:cArqTree)
						dbSetOrder(4)
						If dbSeek((::cTrbTree)->CODPRO+AllTrim((::cTrbTree)->CARGO)+cFilAnt)
							aNewCod[Len(aNewCod)][4] := (::oTree:cArqTree)->(Recno())
						Endif
						dbSelectArea(::cTrbTree)
					Endif

					// Verifica se existe shape para o item
					If nPosNivSup > 0 .Or. ( cSvLocal <> (::cTrbTree)->CODPRO .And. ( nPosShape := aScan( ::aShape,{|aShape| aShape[__aShape_Cargo__] == (::cTrbTree)->CODPRO+AllTrim((::cTrbTree)->CARGO)+cFilAnt} ) ) > 0 )
						aNewCod[Len(aNewCod)][5] := nPosShape
					Endif

				Else

					cSvLocal := (::cTrbTree)->CODPRO

				Endif

				//Grava Inclusao do Item na tabela de Historico de Movimentacao
				If (::cTrbTree)->TIPO != "0" //Ilustracao
					If AliasInDic("TCJ")

						dbSelectArea("TCJ")
						dbSetOrder(1)
						If ( cSvLocal <> (::cTrbTree)->CODPRO .Or. cSvNivSup <> (::cTrbTree)->NIVSUP ) .And. ;
								dbSeek(xFilial("TCJ")+(::cTrbTree)->CODPRO+(::cTrbTree)->NIVSUP+'N'+DTOS(dDataBase)+cHora)

							RecLock("TCJ",.F.)
							dbDelete()
							MsUnLock("TCJ")
						Endif

						dbSelectArea("TCJ")
						If !dbSeek(xFilial("TCJ")+cSvLocal+cSvNivSup+'N'+DTOS(dDataBase)+cHora)
							RecLock("TCJ",.T.)
							TCJ->TCJ_FILIAL := xFilial("TCJ")
							TCJ->TCJ_CODNIV := cSvLocal
							TCJ->TCJ_DESNIV := (::cTrbTree)->DESCRI
							TCJ->TCJ_NIVSUP := cSvNivSup
							TCJ->TCJ_DATA   := dDataBase
							TCJ->TCJ_HORA   := cHora
							TCJ->TCJ_TIPROC := "N" //Inclusao

							IF NGCADICBASE("TCJ_MODSGA","D","TCJ",.f.)
								TCJ->TCJ_NIVEL := (::cTrbTree)->NIVEL
								If __nModPG == 56
									TCJ->TCJ_MODSGA:= "X"
								ElseIf __nModPG == 35
									TCJ->TCJ_MODMDT:= "X"
								ElseIf __nModPG == 19
									TCJ->TCJ_MODMNT:= "X"
								EndIf
							Endif

							MsUnLock("TCJ")

						EndIf

					EndIf
				EndIf

				lIncTAF := .T.
				RecLock("TAF",.T.)
				TAF->TAF_CODNIV := cSvLocal
				TAF->TAF_ORDEM  := cOrdem
				TAF->TAF_CCUSTO := (::cTrbTree)->CC
				TAF->TAF_CENTRA := (::cTrbTree)->CENTRAB

			EndIf

			TAF->TAF_FILIAL := xFilial("TAF")
			TAF->TAF_CODEST := (::cTrbTree)->CODEST
			TAF->TAF_NOMNIV := (::cTrbTree)->DESCRI
			TAF->TAF_NIVEL  := (::cTrbTree)->NIVEL
			TAF->TAF_MAT    := (::cTrbTree)->RESPONS
			TAF->TAF_INDCON := (::cTrbTree)->TIPO
			TAF->TAF_CODCON := (::cTrbTree)->CODTIPO
			TAF->TAF_NIVSUP := cSvNivSup

			If __nModPG == 56
				TAF->TAF_MODSGA := (::cTrbTree)->MODSGA
			ElseIf __nModPG == 19
				TAF->TAF_MODMNT := (::cTrbTree)->MODMNT
			ElseIf __nModPG == 35
				TAF->TAF_MODMDT := (::cTrbTree)->MODMDT
			Endif

			If lEtapa
				TAF->TAF_ETAPA  := (::cTrbTree)->ETAPA
			EndIf
			If lRateio
				TAF->TAF_RATEIO  := (::cTrbTree)->RATEIO
			EndIf
			If lCodAmb
				TAF->TAF_CODAMB  := (::cTrbTree)->CODAMB
			EndIf
			If lDepto
				TAF->TAF_DEPTO  := (::cTrbTree)->DEPTO
			EndIf
			TAF->TAF_PLANTA := (::cTrbTree)->PLANTA
			TAF->TAF_TIPIMG := (::cTrbTree)->TIPIMG
			TAF->TAF_IMAGEM := (::cTrbTree)->IMAGEM
			TAF->TAF_POSX   := (::cTrbTree)->POSX
			TAF->TAF_POSY   := (::cTrbTree)->POSY
			TAF->TAF_TAMX   := (::cTrbTree)->TAMX
			TAF->TAF_TAMY   := (::cTrbTree)->TAMY
			TAF->TAF_MOVBLO := (::cTrbTree)->MOVBLO
			If __nModPG == 19
				TAF->TAF_EVENTO := cEvento
			ElseIf __nModPG == 35
				TAF->TAF_EVEMDT := cEvento
				TAF->TAF_CCUSTO := (::cTrbTree)->CC
			ElseIf __nModPG == 56
				TAF->TAF_EVESGA := cEvento
			EndIf
			TAF->(MsUnLock())

			If __nModPG == 19
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Inclui Bem/Localizacao na Restricao de Acesso ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lIncTAF .And. FindFunction("NGInsertTUB")
					NGInsertTUB()
				EndIf

				// ALTERA C.C. E C.T. DO BEM DE ACORDO COM A LOCALIZÇÃO DO PAI
				cCCusto := (::cTrbTree)->CC
				cCentra := (::cTrbTree)->CENTRAB

				// SOMENTE ACIONADA QUANDO FOR INCLUSÃO DE UM NOVO REGISTRO OU ALTERAÇÃO DE LOCAL DE BEM NA ÁRVORE.
				If ( lIncTAF .Or. lAltTAF ) .And. TAF->TAF_INDCON == '1'

					If FindFunction( 'MntUpdCC' )

						// ATUALIZA O C.C. E C.T. DO BEM PAI E SEUS FILHOS CONFORME INFORMAÇÕES DA LOCALIZAÇÃO DO PAI.
						aRetTC := aClone( MntUpdCC( TAF->TAF_CODCON, TAF->TAF_FILIAL + TAF->TAF_CODEST +;
							TAF->TAF_NIVSUP ) )

						// ALTERA C.C. E C.T. DO BEM DE ACORDO COM A LOCALIZÇÃO DO PAI
						cCCusto := IIf( Empty( aRetTC[1] ), cCCusto, aRetTC[1] )
						cCentra := IIf( Empty( aRetTC[2] ), cCentra, aRetTC[2] )

					Else

						dbSelectArea("ST9")
						dbSetOrder(1)
						If dbSeek(xFilial("ST9")+TAF->TAF_CODCON)
							cCCusto  := ST9->T9_CCUSTO
							cCentra  := ST9->T9_CENTRAB
							If ST9->T9_MOVIBEM != 'N' //Permite movimentacao de CC
								aTrbArea := (::cTrbTree)->(GetArea())
								dbSelectArea(::cTrbTree)
								dbSetOrder(2)
								If dbSeek("001"+TAF->TAF_NIVSUP+cFilAnt)
									cCCusto := (::cTrbTree)->CC
									cCentra := (::cTrbTree)->CENTRAB
								EndIf
								If !Empty(cCCusto) .And. (ST9->T9_CCUSTO != cCCusto .Or. ST9->T9_CENTRAB != cCentra)
									NGRETCC(ST9->T9_CODBEM,dDataBase,cCCusto,cCentra,__cHora,"D","",.F.)
										//Deleta TPN "temporaria" criada anteriormente
									dbSelectArea("TPN")
									dbSetOrder(1)
									dbSeek(xFilial("TPN")+ST9->T9_CODBEM+DTOS(dDataBase)+__cHora)
									dbSkip(-1)
									If !Eof() .And. xFilial("TPN") == TPN->TPN_FILIAL .And. TPN->TPN_CODBEM == ST9->T9_CODBEM .And. ;
											cCCusto == TPN->TPN_CCUSTO .And. cCentra == TPN->TPN_CTRAB
										dbSkip()
										RecLock("TPN",.F.)
										dbDelete()
										MsUnLock()
									EndIf
								EndIf
								If Empty(cCCusto)
									cCCusto := ST9->T9_CCUSTO
									cCentra := ST9->T9_CENTRAB
								Endif
								RestArea(aTrbArea)
							EndIf
						EndIf

					EndIf

				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Altera Bem/Localizacao na Restricao de Acesso ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !lIncTAF
					If FindFunction("NGAlterTUB")
						NGAlterTUB(cCCusto,cCentra)
					EndIf

					If TAF->TAF_INDCON == '2' .And. (cCCusto != TAF->TAF_CCUSTO .Or. cCentra != TAF->TAF_CENTRA)
						RecLock("TAF",.F.)
						TAF->TAF_CCUSTO := cCCusto
						TAF->TAF_CENTRA := cCentra
						MsUnLock()
					EndIf
				EndIf
			EndIf

			dbSelectArea(::cTrbTree)
			dbSkip()
		EndDo

		If __nModPG == 56
			SgaSavePG(::cTrbTree, lFinal, @aNewCod, ::oTree, @::aShape)
		Endif

		For nFld := 1 To Len(aNewCod)

			// Posiciona no registro com nova ordem
			dbSelectArea(::cTrbTree)
			dbGoTo(aNewCod[nFld][1])

			If !Eof()

				nPosShape := 0

				// Caso for uma planta
				If (::cTrbTree)->PLANTA == "1"
					// Verifica os shapes filhos do item (Planta)
					While ( nPosShape := aScan( ::aShape, {|aShape| aShape[__aShape_PlanSup__] == aNewCod[nFld][2] }, nPosShape ) ) > 0
						::aShape[nPosShape][__aShape_PlanSup__] := aNewCod[nFld][3]
					End
				Endif

				// Altera codigo com nova ordem
				RecLock(::cTrbTree,.F.)
				(::cTrbTree)->CODPRO := aNewCod[nFld][3]
				MsUnlock(::cTrbTree)

				// Verifica se ha registro no Tree para ser alterado
				If aNewCod[nFld][4] > 0
					dbSelectArea(::oTree:cArqTree)
					dbGoTo(aNewCod[nFld][4])
					If !Eof()
						RecLock((::oTree:cArqTree),.F.)
						(::oTree:cArqTree)->T_CARGO := (::cTrbTree)->CODPRO+AllTrim((::cTrbTree)->CARGO)+cFilAnt
						MsUnlock((::oTree:cArqTree))
					Endif
				Endif

				// Verifica se ha shape para ser alterado
				If !Empty(aNewCod[nFld][5])
					::aShape[aNewCod[nFld][5]][__aShape_Cargo__]   := (::cTrbTree)->CODPRO+AllTrim((::cTrbTree)->CARGO)+cFilAnt
					::aShape[aNewCod[nFld][5]][__aShape_NivSup__]  := (::cTrbTree)->NIVSUP
				Endif

			Endif

		Next nFld

	EndIf

	RestArea(aAreaTree)

	//-----------------------------------------------------------------
	// Identifica que a planta foi salva e não houve mais alterações
	//-----------------------------------------------------------------
	::lModified := .F.

	//Restaura teclas de atalho
	RestKeys(aKeys,.T.)
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} InsertLocTree
Método que insere uma nova Localizacao na Arvore Logica

@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Method InsertLocTree() Class TNGPG

	Local oDlg, oCheck
	Local nNivel  := 0
	Local i
	Local cCodAnt := ::cCodNiv
	Local lGrava  := .F.
	Local lRateio := NGCADICBASE('TAF_RATEIO','D','TAF',.F.)
	Local lEtapa  := NGCADICBASE('TAF_ETAPA','D','TAF',.F.)
	Local lCodAmb := NGCADICBASE('TAF_CODAMB','D','TAF',.F.)
	Local lDepto  := NGCADICBASE('TAF_DEPTO','D','TAF',.F.)
	Local cCodEst := "001"
	Local aNao    := {}
	Local aChoice := {}
	Local cCodLevel := SubStr( ::oTree:GetCargo(), 1, 3 )
	//Local lPlanta  := .F.
	Private aGets  := Array(0)
	Private aTela  := Array(0,0)

	aAdd( aNao , "TAF_CODEST" )
	aAdd( aNao , "TAF_NIVEL"	)
	aAdd( aNao , "TAF_INDCON" )
	aAdd( aNao , "TAF_CODCON" )
	aAdd( aNao , "TAF_NIVSUP" )
	aAdd( aNao , "TAF_ORDEM"	)
	If __nModPG == 35
		aAdd( aNao , "TAF_CENTRA" )
		aAdd( aNao , "TAF_NOMTRA" )
		If lEtapa
			aAdd( aNao , "TAF_ETAPA" )
		EndIf
	EndIf

	aChoice := NGCAMPNSX3("TAF",aNao)
	aAdd(aChoice,"TAF_PLANTA")

	dbSelectArea(::cTrbTree)
	dbSetOrder(2)
	dbSeek(cCodEst+Substr(cCodLevel,1,3)+cFilAnt)
	nNivel := (::cTrbTree)->NIVEL

	SetInclui()

	If FindFunction("Soma1Old")
		::cCodNiv := Soma1Old(AllTrim(::cCodNiv))
	Else
		::cCodNiv := Soma1(AllTrim(::cCodNiv))
	EndIf

	cLocal := ::cCodNiv

	dbSelectArea( "TAF" )
	RegToMemory( "TAF", .T. )

	::SetBlackPnl(.T.)
	Define MsDialog oDlg From 0,0 To 250,650 Title STR0070 COLOR CLR_BLACK,CLR_WHITE Pixel	 //"Incluir Identificação"

		oEnc01 := MsMGet():New("TAF",1,3,,,,aChoice,Nil,,3)
			oEnc01:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	Activate MsDialog oDlg ON INIT EnchoiceBar(oDlg,{|| If(!Obrigatorio(aGets,aTela) .Or. !MNT902VlId( 3,::oTree,::cTrbTree ),lGrava := .f.,(lGrava:=.t.,oDlg:End()))},{|| lGrava := .f.,oDlg:End()}) Centered

	If lGrava
		dbSelectArea(::oTree:cArqTree)
		If M->TAF_PLANTA == "1"
			::oTree:AddItem(M->TAF_NOMNIV,::cCodNiv+'LOC'+cFilAnt,'ico_planta_fecha','ico_planta_abre',,, 2)
		Else
			::oTree:AddItem(M->TAF_NOMNIV,::cCodNiv+'LOC'+cFilAnt,'ico_planta_local','ico_planta_local',,, 2)
		EndIf

		dbSelectArea(::cTrbTree)
		RecLock(::cTrbTree,.T.)
		(::cTrbTree)->FILIAL  := cFilAnt
		(::cTrbTree)->CODEST  := cCodEst
		(::cTrbTree)->CODPRO  := ::cCodNiv
		(::cTrbTree)->DESCRI  := M->TAF_NOMNIV
		(::cTrbTree)->NIVSUP  := SubStr( ::oTree:GetCargo(), 1, 3 )
		(::cTrbTree)->RESPONS := M->TAF_MAT
		(::cTrbTree)->CC      := M->TAF_CCUSTO
		(::cTrbTree)->CENTRAB := M->TAF_CENTRA
		(::cTrbTree)->DOCFIL  := ""
		(::cTrbTree)->TIPO    := '2'
		If __nModPG == 19
			(::cTrbTree)->MODMNT  := 'X'
		ElseIf __nModPG == 35
			(::cTrbTree)->MODMDT  := 'X'
		ElseIf __nModPG == 56
			(::cTrbTree)->MODSGA  := 'X'
		EndIf
		(::cTrbTree)->ORDEM	 := ::cCodNiv
		(::cTrbTree)->NIVEL   := nNivel+1
		(::cTrbTree)->CARGO   := "LOC"
		(::cTrbTree)->PLANTA  := M->TAF_PLANTA
		(::cTrbTree)->PGSUP   := ::cPlantaAtu
		If lEtapa
			(::cTrbTree)->ETAPA   := M->TAF_ETAPA
		EndIf
		If lRateio
			(::cTrbTree)->RATEIO  := M->TAF_RATEIO
		EndIf
		If lCodAmb
			(::cTrbTree)->CODAMB  := M->TAF_CODAMB
		EndIf
		If lDepto
			(::cTrbTree)->DEPTO   := M->TAF_DEPTO
		EndIf
		MsUnLock(::cTrbTree)

		//-----------------------------------------------------------------
		// Identifica que a planta teve alterações e necessita ser salva
		//-----------------------------------------------------------------
		::lModified := .T.

		::InsertLocTree()

	Else
		::cCodNiv := cCodAnt
	EndIf

	::SetBlackPnl(.F.)
Return lGrava

//---------------------------------------------------------------------
/*/{Protheus.doc} AlterLocTree
Método que altera uma nova Localizacao na Arvore Logica

@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return lGrava Indica se alterou item
/*/
//---------------------------------------------------------------------
Method AlterLocTree() Class TNGPG

	Local oDlg
	//Local nNivel  := 0
	Local i
	Local cCodAnt := ::cCodNiv
	Local lGrava  := .F.
	//Local lPlanta := (::cTrbTree)->PLANTA == "1"
	Local lRateio := NGCADICBASE('TAF_RATEIO','D','TAF',.F.)
	Local lEtapa  := NGCADICBASE('TAF_ETAPA' ,'D','TAF',.F.)
	Local lCodAmb := NGCADICBASE('TAF_CODAMB','D','TAF',.F.)
	Local lDepto  := NGCADICBASE('TAF_DEPTO' ,'D','TAF',.F.)
	Local cCodEst := "001"
	Local aNao    := {}
	Local aChoice := {}
	Local aRelac  := {}
	Local cCodLevel := SubStr( ::oTree:GetCargo(), 1, 3 )
	Local nPosShape
	Local cLocal := SubStr( ::oTree:GetCargo(), 1, 3 )

	Private aGets  := Array(0)
	Private aTela  := Array(0,0)

	aAdd( aNao , "TAF_CODEST" )
	aAdd( aNao , "TAF_NIVEL"	)
	aAdd( aNao , "TAF_INDCON" )
	aAdd( aNao , "TAF_CODCON" )
	aAdd( aNao , "TAF_NIVSUP" )
	aAdd( aNao , "TAF_ORDEM"	)
	If __nModPG == 35
		aAdd( aNao , "TAF_CENTRA" )
		aAdd( aNao , "TAF_NOMTRA" )
		If lEtapa
			aAdd( aNao , "TAF_ETAPA" )
		EndIf
	EndIf
	aChoice := 	NGCAMPNSX3("TAF",aNao)

	If cLocal != "001"
		aAdd(aChoice,"TAF_PLANTA")
	EndIf

	dbSelectArea(::cTrbTree)
	dbSetOrder(2)
	If dbSeek(cCodEst+Substr(cCodLevel,1,3)+cFilAnt)

		aADD( aRelac, {"TAF_NOMNIV",::cTrbTree+"->DESCRI"		} )
		aADD( aRelac, {"TAF_CODNIV","'"+cLocal+"'"				} )
		aADD( aRelac, {"TAF_MAT"   ,::cTrbTree+"->RESPONS"	} )
		If __nModPG <> 35
			aADD( aRelac, {"TAF_CENTRA",::cTrbTree+"->CENTRAB"} )
			If lEtapa
				aADD( aRelac, {"TAF_ETAPA",::cTrbTree+"->ETAPA"	} )
	 		EndIf
	 		If lRateio
	 			aAdd(aRelac,{"TAF_RATEIO",::cTrbTree+"->RATEIO"		} )
	 		Endif
	 	EndIf
		aADD( aRelac, {"TAF_CCUSTO",::cTrbTree+"->CC"			} )
		aAdd(aRelac,{"TAF_PLANTA",::cTrbTree+"->PLANTA"			} )
		If lCodAmb
			aAdd(aRelac,{"TAF_CODAMB",::cTrbTree+"->CODAMB"		} )
		Endif
		If lDepto
			aAdd(aRelac,{"TAF_DEPTO" ,::cTrbTree+"->DEPTO"		   } )
	EndIf
	EndIf

	::SetBlackPnl(.T.)
	SetAltera()
	Define MsDialog oDlg From 0,0 To 250,650 Title STR0071 COLOR CLR_BLACK,CLR_WHITE Pixel //"Alterar Identificação"

		dbSelectArea("TAF")
		dbSetOrder(2)
		dbSeek(xFilial("TAF")+'001'+cLocal)
		RegToMemory("TAF",.F.)
		oEnc01 := MsMGet():New("TAF",1,4,,,,aChoice,Nil,,3)
			oEnc01:oBox:Align := CONTROL_ALIGN_ALLCLIENT

		For i := 1 To Len(aRELAC)
			cCampo := "M->" + aRELAC[i][1]
			cRelac := aRELAC[i][2]
			&cCampo. := &cRelac
		Next i

		dbSelectArea("CTT")
		dbSetOrder(1)
		If dbSeek(xFilial("CTT")+(::cTrbTree)->CC)
			M->TAF_NOMCC := CTT->CTT_DESC01
		Else
			M->TAF_NOMCC := Space(Len(CTT->CTT_DESC01))
		EndIf

		dbSelectArea("SHB")
		dbSetOrder(1)
		If dbSeek(xFilial("SHB")+(::cTrbTree)->CENTRAB)
			M->TAF_NOMTRA := SHB->HB_NOME
		Else
			M->TAF_NOMTRA := Space(Len(SHB->HB_NOME))
		EndIf

		If lCodAmb
			M->TAF_NOMAMB := NGSeek( "TNE", (::cTrbTree)->CODAMB, 1, "TNE_NOME" )
		Endif

		If lDepto
			M->TAF_DESCDP := NGSeek( "SQB", (::cTrbTree)->DEPTO , 1, "SQB->QB_DESCRIC" )
		EndIf

	Activate MsDialog oDlg ON INIT EnchoiceBar(oDlg,{|| If(!Obrigatorio(aGets,aTela) .Or. !MNT902VlId( 4,::oTree,::cTrbTree ),lGrava := .f.,(lGrava:=.t.,oDlg:End()))},{|| lGrava := .f.,oDlg:End()}) Centered

	If lGrava
		dbSelectArea(::oTree:cArqTree)
		::oTree:ChangePrompt(M->TAF_NOMNIV,cLocal+"LOC")
		dbSelectArea(::cTrbTree)
		dbSetOrder(2)
		If dbSeek(cCodEst+cLocal+cFilAnt)
			If cLocal != "001" //Nao altera imagem se for o codigo da estrutura
				If M->TAF_PLANTA == "1"
					::oTree:ChangeBmp('ico_planta_fecha','ico_planta_abre')
				Else
					::oTree:ChangeBmp('ico_planta_local','ico_planta_local')
				EndIf
			EndIf
			RecLock(::cTrbTree,.F.)
			(::cTrbTree)->DESCRI  := M->TAF_NOMNIV
			(::cTrbTree)->RESPONS := M->TAF_MAT
			(::cTrbTree)->CC      := M->TAF_CCUSTO
			(::cTrbTree)->CENTRAB := M->TAF_CENTRA
			(::cTrbTree)->DOCFIL  := ""
			(::cTrbTree)->PLANTA  := M->TAF_PLANTA
			If __nModPG == 19
				(::cTrbTree)->MODMNT  := 'X'
			ElseIf __nModPG == 35
				(::cTrbTree)->MODMDT  := 'X'
			ElseIf __nModPG == 56
				(::cTrbTree)->MODSGA  := 'X'
			EndIf
			If lEtapa
				(::cTrbTree)->ETAPA := M->TAF_ETAPA
			EndIf
			If lRateio
				(::cTrbTree)->RATEIO  := M->TAF_RATEIO
			EndIf
			If lCodAmb
				(::cTrbTree)->CODAMB  := M->TAF_CODAMB
			Endif
			If lDepto
				(::cTrbTree)->DEPTO   := M->TAF_DEPTO
			EndIf
			MsUnLock(::cTrbTree)

			dbSelectArea(::oTree:cArqTree)
			dbSetOrder(4)
			dbSeek((::cTrbTree)->CODPRO+AllTrim((::cTrbTree)->CARGO))
			(::oTree:cArqTree)->T_CARGO := cLocal+"LOC"+cFilAnt
		EndIf
		::SetOptionTree(cLocal+"LOC"+cFilAnt)
		::oTree:Refresh()
		::oTree:SetFocus()


		If (nPosShape := aScan(::aShape,{|aShape| aShape[__aShape_Cargo__] == cLocal+"LOC"+cFilAnt})) > 0
			::aShape[nPosShape][__aShape_Descri__] := M->TAF_NOMNIV
			::aShape[nPosShape][__aShape_Planta__] := M->TAF_PLANTA
			::oTPanel:SetToolTip(::aShape[nPosShape][__aShape_IdShape__],Trim(M->TAF_NOMNIV))
		EndIf

		//-----------------------------------------------------------------
		// Identifica que a planta teve alterações e necessita ser salva
		//-----------------------------------------------------------------
		::lModified := .T.

	Else
		::cCodNiv := cCodAnt
	EndIf
	::SetBlackPnl(.F.)
Return lGrava

//---------------------------------------------------------------------
/*/{Protheus.doc} DoubleClickTree

@param cCargo Identificacao do item no dbTree
@return Nil
@author Vitor Emanuel Batista
@since 17/11/2010
@version MP10
/*/
//---------------------------------------------------------------------
Method DoubleClickTree(cCargo) Class TNGPG
	Local nPosShape

	Default cCargo := ::oTree:GetCargo()

	nPosShape := aScan(::aShape,{|aShape| aShape[__aShape_Cargo__] == cCargo})

	If nPosShape > 0 .And. nPosShape <= Len(::aShape)
		nPosX := ::aShape[nPosShape][__aShape_PosX__] + ::aShape[nPosShape][__aShape_Largura__]/2
		nPosY := ::aShape[nPosShape][__aShape_PosY__] + ::aShape[nPosShape][__aShape_Altura__]/2

		::CreateBalloon(nPosShape,nPosX,nPosY)
	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} InsertBlinker

Method criado para que antes de fazer o InsertBlinker delete o mesmo.

Isso ocorre por que a lógica do programa faz com que ele de alguns InsertBlinkers
repetidos e quando for deletar é necessário deletar o numero de vezes em que o Insert
foi feito. Exemplo um Blinker foi criado e depois ele recebeu um Insert, será necessário
fazer dois Deletes, um pela criação e outro pelo insert.

Esse tratamento se faz necessário até o Frame corrigir a situação que deverá ser tratada na
SS TWGG50

@param nId - Id do blinker a ser inserido
@since 07/10/2016
@version MP12
@return Nil
/*/
//---------------------------------------------------------------------
Method InsertBlinker(nId) Class TNGPG

	::oTPanel:DeleteBlinker( nId )
	::oTPanel:InsertBlinker( nId )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} SetOptionTree
Método que seta uma opcao na Arvore Logica, alterando visao na Planta

@param cCargo Identificacao do Item na Tree
@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Method SetOptionTree(cCargo) Class TNGPG
	Local nPosShape, nX
	Local lTrocaPg := .F.
	Local lVisible
	Local cFilOld := cFilAnt

	Default cCargo := ::oTree:GetCargo()

	//Destroi com o FWBalloon
	::DestroyBalloon()

	//Tira Foco do shape selecionado
	::SetImageFocus(.F.)

	If Empty(cCargo)
		Return
	EndIf

	//------------------------------------------------
	// Identifica de qual filial que se esta clicando
	//------------------------------------------------
	cFilAnt := SubStr(cCargo,7,__nSizeFil)

	::cCargoAtu := cCargo
	dbSelectArea(::cTrbTree)
	dbSetOrder(2)
	If dbSeek('001'+Substr(cCargo,1,3)+cFilAnt)
		::oTree:TreeSeek(cCargo)
		If (::cTrbTree)->PLANTA == "1"
			If Substr(cCargo,1,3) != ::cPlantaAtu .Or. cFilOld != cFilAnt
				::cPlantaAtu := Substr(cCargo,1,3)
				lTrocaPg := .T.
			EndIf
		ElseIf (::cTrbTree)->PGSUP != ::cPlantaAtu .Or. cFilOld != cFilAnt
			::cPlantaAtu := (::cTrbTree)->PGSUP
			lTrocaPg := .T.
		EndIf

		If lTrocaPg

			For nPosShape := 1 to Len(::aShape)
				lVisible := ::aShape[nPosShape][__aShape_PlanSup__] == ::cPlantaAtu .And. ::aShape[nPosShape][__aShape_Visivel__] .And. ;
								::aShape[nPosShape][__aShape_Filial__] == cFilAnt
				::oTPanel:SetVisible(::aShape[nPosShape][__aShape_IdShape__],lVisible)
				For nX := 1 To Len(::aShape[nPosShape][__aShape_Alertas__])

					If ::aShape[nPosShape][__aShape_Alertas__][nX][__aShape_aAlerta_Visible__]
						If ::aShape[nPosShape][__aShape_Alertas__][nX][__aShape_aAlerta_Blinker__]
							If lVisible
								::InsertBlinker( ::aShape[nPosShape][__aShape_Alertas__][nX][__aShape_aAlerta_IdShape__] )
							Else
								::oTPanel:DeleteBlinker(::aShape[nPosShape][__aShape_Alertas__][nX][__aShape_aAlerta_IdShape__])
							EndIf
						EndIf
						::oTPanel:SetVisible(::aShape[nPosShape][__aShape_Alertas__][nX][__aShape_aAlerta_IdShape__],lVisible)
					EndIf
				Next nX
			Next nPosShape

			If __nModPG <> 56
				If !::lEditMode
					//Ajusta planta de acordo com o Zoom
					nPosPlanta := aScan(::aZoom,{|x| x[1] == ::cPlantaAtu+cFilAnt})
					::nZoom := ::aZoom[nPosPlanta][2]

					::oTPanel:nWidth  /= __nZoom / 100
					::oTPanel:nHeight /= __nZoom / 100
					::oTPanel:nWidth  *= ::nZoom / 100
					::oTPanel:nHeight *= ::nZoom / 100
					__nZoom := ::nZoom
					::oZoom:SetValue(::nZoom)
					::oGetZoom:SetFocus()
					::oGetZoom:CtrlRefresh()
					::oTPanel:SetFocus()
				EndIf
			EndIf

		EndIf
	EndIf

	::oTree:SetFocus()
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} Destroy
Método que exclui todas as imagens utilizadas pela Planta Grafica

@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Method EraseImage() Class TNGPG

	Local aFiles := {} // O array receberá os nomes dos arquivos e do diretório
	Local nX
	Local cDirectory := ::GetDirectory()

	cFilAnt := ::cFilAnt

	If ExistDir(cDirectory)
		ADir(cDirectory+"*.*", aFiles)

		// Exibe dados dos arquivos
		For nX := 1 to Len( aFiles )
		  FErase(cDirectory+aFiles[nX])
		Next nX

		DirRemove(cDirectory)
	EndIf
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} ClearCache
Método para limpar cache / apagar imagens da pasta temporária do Client

@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------

Method ClearCache() Class TNGPG

	Local oDlg, oTPanel
	Local oConfirm, oCancel, oHabili, oExit
	Local lConfirm := .F.
	Local oFont := TFont():New('Verdana',,-12,.T.)

	//Guarda bloco de codigo das telhas de atalho
	Local aKeys := GetKeys()

	//Limpa tecla de atalhos para nao poderem ser executados
	RestKeys(,.T.)

	//Habilita Panel preto transparente
	::SetBlackPnl(.T.)

		//Destroi com o FWBalloon se ja estiver criado
	::DestroyBalloon()

	Define Dialog oDlg From 5,5 To 120,355 Of Self COLOR CLR_BLACK,CLR_WHITE STYLE nOr(DS_SYSMODAL,WS_MAXIMIZEBOX,WS_POPUP) Pixel
		oDlg:lEscClose := .F.


		oTPanel := TPaintPanel():New(0,0,0,0,oDlg,.F.)
			oTPanel:Align := CONTROL_ALIGN_ALLCLIENT
   		oTPanel:bLClicked := {||}


			//Container do Fundo
			oTPanel:addShape( "id="+cValToChar(::SetId())+";type=1;left=0;top=0;width=360;height=145;"+;
							  "gradient=1,0,0,0,080,0.0,#FFFFFF;pen-color=#FFFFFF;can-move=0;can-mark=0;is-container=" + If(lReleaseB,'0','1') + ";")
			//Gradiente
			oTPanel:addShape(	"id="+cValToChar(::SetId())+";type=1;left=1;top=1;width=356;height=140;"+;
								"gradient=1,0,0,0,180,0.0,#FFFFFF,0.1,#FDFBFD,1.0,#CDD1D4;pen-width=0;pen-color=#FFFFFF;can-move=0;can-mark=0;is-container=" + If(lReleaseB,'0','1') + ";")

			oExit := TBtnBmp2():New( 05,340,10,10,'br_cancel',,,,{|| (lConfirm := .F.,oDlg:End())},oDlg,,,.T. )

		//TBtnBmp2():New(10,(oDlg:nWidth)-20,17,17,'ng_ico_help',,,,;
				//{|| FWBalloon():New(30,0,350,130,oTPanel,'Titulo','Descrição',3,3)},oTPanel)


			If ::lEditMode
				@ 10,010 Say STR0396 + CRLF + STR0397 Of oTPanel Size 160,150 FONT oFont COLOR CLR_HRED Pixel //"Este procedimento irá fechar a rotina sem salvar as últimas alterações, além de apagar todos os arquivos temporários relacionados a Planta Gráfica do seu computador." ## "Deseja confirmar?"
			Else
				@ 10,010 Say STR0398 + CRLF + CRLF + STR0397 Of oTPanel Size 160,150 FONT oFont COLOR CLR_HRED Pixel //"Este procedimento irá fechar a rotina e apagar todos os arquivos temporários relacionados a Planta Gráfica do seu computador." ## "Deseja confirmar?"
			EndIf


			@ 050,085 Button oConfirm Prompt STR0063 Message "Ok - <Ctrl-O>" Size 38,12 Action (lConfirm := .T.,oDlg:End()) Of oTPanel Pixel //"Confirmar"
				oConfirm:SetCss(CSSButton(.T.))
			@ 050,130 Button oCancel Prompt STR0064 Message STR0065 Size 38,12 Action (lConfirm := .F.,oDlg:End()) Of oTPanel Pixel //"Cancelar"##"Cancelar - <Ctrl-X>"
				oCancel:SetCss(CSSButton())
				oCancel:SetFocus()

	ACTIVATE DIALOG oDlg ON INIT (SetKey(K_CTRL_O,oConfirm:bAction),;
											SetKey(K_CTRL_X,oCancel:bAction)) CENTERED

	If lConfirm
		::EraseImage()
		::Owner():End()
	EndIf

	//Restaura teclas de atalho
	RestKeys(aKeys,.T.)

	//Desabilita Panel preto transparente
	::SetBlackPnl(.F.)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} Zoom
Método que aplica certa quantidade de Zoom sobre a Planta em Foco

@param nZoom Porcentagem de zoom sobre a planta
@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return Nil
@obs Zoom disponivel de 10% até 200%
/*/
//---------------------------------------------------------------------
Method Zoom(nZoom) Class TNGPG
	Local nPosShape, nX, nPosPlanta
	Local nLargura, nAltura
	Local lRet := .F.
	Local aResizeAlert := {}

	//Destroi com o FWBalloon se ja estiver criado
	::DestroyBalloon()

	::oZoom:Disable()
	If nZoom >= 10 .And. nZoom <= 200
		lRet := .T.
		If __nZoom != nZoom
			::oZoom:SetValue(nZoom)
			::oTPanel:SetUpdatesEnabled(.F.)
			::SetBlackPnl(.T.)
			::oTPanel:nWidth  /= __nZoom / 100
			::oTPanel:nHeight /= __nZoom / 100
			::oTPanel:nWidth  *= nZoom / 100
			::oTPanel:nHeight *= nZoom / 100

			For nPosShape := 1 to Len(::aShape)
				If ::cPlantaAtu == ::aShape[nPosShape][__aShape_PlanSup__] .And. ::aShape[nPosShape][__aShape_Filial__] == cFilAnt
					::aShape[nPosShape][__aShape_PosX__] /= __nZoom / 100
					::aShape[nPosShape][__aShape_PosY__] /= __nZoom / 100
					::aShape[nPosShape][__aShape_PosX__] *= nZoom / 100
					::aShape[nPosShape][__aShape_PosY__] *= nZoom / 100
					nLargura := ::aShape[nPosShape][__aShape_Largura__] / (__nZoom / 100)
					nAltura  := ::aShape[nPosShape][__aShape_Altura__]  / (__nZoom / 100)
					nLargura := nLargura * nZoom / 100
					nAltura  := nAltura  * nZoom / 100
					//Redimensiona a imagem
					::ResizeImage(::aShape[nPosShape][__aShape_IdShape__],nLargura,nAltura)
					aAdd(aResizeAlert,nPosShape)
				EndIf
			Next nPosShape
			::nZoom := nZoom
			__nZoom := nZoom
			::SetBlackPnl(.F.)
			::oTPanel:SetUpdatesEnabled(.T.)
			::oGetZoom:SetFocus()
			::oGetZoom:CtrlRefresh()

			nPosPlanta := aScan(::aZoom,{|x| x[1] == ::cPlantaAtu+cFilAnt})
			::aZoom[nPosPlanta][2] := nZoom
		EndIf
	EndIf

	For nX := 1 To Len(aResizeAlert)
		::ResizeAlert(aResizeAlert[nX])
	Next nX

	::oZoom:Enable()
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} ConfigFilter
Método que exibe Dialog para configurar Filtro sobre a Planta em Foco

@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Method ConfigFilter() Class TNGPG

	Local oDlg, oTPanel, oFiltros, oEventos
	Local oFamilia, oCC, oCT, oResp, o
	Local oConfirm, oCancel
	Local nPosShape, nPosFil, nX, nLin, nAlerta
	Local lChk1 := lChk2 := lChk3 := lChk4:= lChk5 := .F.
	Local aAlertas := ::GetArrAlerts('001'+cFilAnt)
	Local aEventos := ::GetArrEvents()
	Local aAreaRes := {}
	Local cEvento
	Local lConfirm := .F.
	Local lFamilia, lCCusto, lCentrab, lResp, lDepto
	Local lFuncao, lTarefa
	Local lSeekCod
	Local lDeptoTAF := NGCADICBASE( "TAF_DEPTO" , "A" , "TAF" , .F. )

	Local aCodFami := {"ALL"}
	Local aCodCC   := {"ALL"}
	Local aCodDepto:= {"ALL"}
	Local aCodCT   := {"ALL"}
	Local aCodResp := {"ALL"}
	Local aCodFun  := {"ALL"}
	Local aCodTar  := {"ALL"}
	Local aCodResiduo  := {"ALL"}
	Local aCodClasse  := {"ALL"}
	Local aCodTipGer  := {"ALL"}

	Local aFamilia := {"TODAS"}
	Local cFamilia := aFamilia[1]

	Local aCC := {"TODOS"}
	Local cCC := aCC[1]

	Local aDepto := {"TODOS"}
	Local cDepto := aCC[1]

	Local aCT := {"TODOS"}
	Local cCT := aCT[1]

	Local aCF := {"TODOS"}
	Local cCF := aCF[1]

	Local aCTar:= {"TODOS"}
	Local cCTar:= aCTar[1]

	Local aResp := {"TODOS"}
	Local cResp := aCT[1]

	Local aResiduo:= {"TODAS"}
	Local cResiduo := aResiduo[1]

	Local aClasse:= {"TODAS"}
	Local cClasse := aClasse[1]

	Local aTipGer:= {"TODAS"}
	Local cTipGer := aTipGer[1]

	//Guarda bloco de codigo das telhas de atalho
	Local aKeys := GetKeys()

	//Limpa tecla de atalhos para nao poderem ser executados
	RestKeys(,.T.)

	//Habilita Panel preto transparente
	::SetBlackPnl(.T.)

	//Destroi com o FWBalloon se ja estiver criado
	::DestroyBalloon()

	//Busca dados da Familia, Centro de Custo e Centro de Trabalho de todos os Bens da Planta Atual
	For nPosShape := 1 To Len(::aShape)
		If ::aShape[nPosShape][__aShape_PlanSup__] == ::cPlantaAtu .And. ;
			::aShape[nPosShape][__aShape_IndCod__] $ "1/A"

			If __nModPG == 19
				dbSelectARea("ST9")
				dbSetOrder(1)
				If dbSeek(xFilial("ST9")+::aShape[nPosShape][__aShape_Codigo__])
					If aScan(aCodFami,{|x| x == ST9->T9_CODFAMI}) == 0
						aAdd(aFamilia,AllTrim(ST9->T9_CODFAMI) + "=" + AllTrim(NGSEEK("ST6",ST9->T9_CODFAMI,1,"ST6->T6_NOME")))
						aAdd(aCodFami,ST9->T9_CODFAMI)
					EndIf
					If aScan(aCodCC,{|x| x == ST9->T9_CCUSTO}) == 0
						aAdd(aCC,AllTrim(ST9->T9_CCUSTO) + "=" + AllTrim(NGSEEK("CTT",ST9->T9_CCUSTO,1,"CTT->CTT_DESC01")))
						aAdd(aCodCC,ST9->T9_CCUSTO)
					EndIf
					If aScan(aCodCT,{|x| x == ST9->T9_CENTRAB}) == 0 .And. !Empty(ST9->T9_CENTRAB)
						aAdd(aCT,AllTrim(ST9->T9_CENTRAB) + "=" + AllTrim(NGSEEK("SHB",ST9->T9_CENTRAB,1,"SHB->HB_NOME")))
						aAdd(aCodCT,ST9->T9_CENTRAB)
					EndIf
				EndIf
				//Responsavel
				dbSelectArea("TAF")
				dbSetOrder(2)
				If dbSeek(xFilial("TAF")+'001'+::aShape[nPosShape][__aShape_NivSup__]) .And. !Empty(TAF->TAF_MAT)
					dbSelectArea("QAA")
					dbSetOrder(1)
					If dbSeek(xFilial("QAA")+TAF->TAF_MAT)
						If aScan(aCodResp,{|x| x == TAF->TAF_MAT}) == 0
							aAdd(aResp,AllTrim(TAF->TAF_MAT) + "=" + AllTrim(QAA->QAA_NOME))
							aAdd(aCodResp,TAF->TAF_MAT)
						EndIf
					EndIf
				EndIf

			ElseIf __nModPG == 35

				dbSelectARea("TN0")
				dbSetOrder(1)
				If dbSeek(xFilial("TN0")+::aShape[nPosShape][__aShape_Codigo__])
					If aScan(aCodCC,{|x| x == TN0->TN0_CC}) == 0
						aAdd(aCC,If( Alltrim(TN0->TN0_CC)=="*","*",AllTrim(TN0->TN0_CC) + "=" + AllTrim(NGSEEK("CTT",TN0->TN0_CC,1,"CTT->CTT_DESC01"))))
						aAdd(aCodCC,TN0->TN0_CC)
					EndIf
					If aScan(aCodFun,{|x| x == TN0->TN0_CODFUN}) == 0
						aAdd(aCF,If( Alltrim(TN0->TN0_CODFUN)=="*", "*",AllTrim(TN0->TN0_CODFUN) + "=" + AllTrim(NGSEEK("SRJ",TN0->TN0_CODFUN,1,"SRJ->RJ_DESC"))))
						aAdd(aCodFun,TN0->TN0_CODFUN)
					EndIf
					If aScan(aCodTar,{|x| x == TN0->TN0_CODTAR}) == 0
						aAdd(aCTar,If( Alltrim(TN0->TN0_CODTAR)=="*","*",AllTrim(TN0->TN0_CODTAR) + "=" + AllTrim(NGSEEK("TN5",TN0->TN0_CODTAR,1,"TN5->TN5_NOMTAR"))))
						aAdd(aCodTar,TN0->TN0_CODTAR)
					EndIf
					If lDeptoTAF
						If aScan(aCodDepto,{|x| x == TN0->TN0_DEPTO}) == 0
							aAdd(aCC,If( Alltrim(TN0->TN0_DEPTO)=="*","*",AllTrim(TN0->TN0_DEPTO) + "=" + AllTrim(NGSEEK("SQB",TN0->TN0_DEPTO,1,"SQB->QB_DESCRIC"))))
							aAdd(aCodCC,TN0->TN0_DEPTO)
				EndIf
					EndIf
				EndIf

				// Responsavel
				// Como no arvore de MDT nem todos os itens sao cadastrados no aShape
				// Foi necessario verificar a localização do referente ao Risco e
				// buscar os Responsaveis
				aAreaRes := GetArea()
				dbSelectArea("TAF")
				dbSetOrder( 2 ) //TAF_FILIAL+TAF_CODEST+TAF_CODNIV
				dbSeek( xFilial( "TAF" ) + "001" + SubStr( ::aShape[nPosShape][__aShape_Cargo__],1,3) )
				While TAF->( !Eof() ) .And. xFilial( "TAF" ) == TAF->TAF_FILIAL .And. TAF->TAF_INDCON <> "2"

					dbSelectArea("TAF")
					dbSetOrder( 2 ) //TAF_FILIAL+TAF_CODEST+TAF_CODNIV
					dbSeek( xFilial( "TAF" ) + "001" + TAF->TAF_NIVSUP )

				End

				dbSelectArea("QAA")
				dbSetOrder(1)
				If dbSeek(xFilial("QAA")+TAF->TAF_MAT)
					If aScan(aCodResp,{|x| x == TAF->TAF_MAT}) == 0
						aAdd(aResp,AllTrim(TAF->TAF_MAT) + "=" + AllTrim(QAA->QAA_NOME))
						aAdd(aCodResp,TAF->TAF_MAT)
					EndIf
				EndIf
				RestArea( aAreaRes )

			ElseIf __nModPG == 56

				If ::aShape[nPosShape][__aShape_PlanSup__] == ::cPlantaAtu .And. ;
					::aShape[nPosShape][__aShape_IndCod__] == "A"

					dbSelectARea("TAX")
					dbSetOrder(1)
					If dbSeek(xFilial("TAX")+::aShape[nPosShape][__aShape_Codigo__])
						If aScan(aCodResiduo,{|x| x == TAX->TAX_CODRES}) == 0
							aAdd(aResiduo,AllTrim(TAX->TAX_CODRES) + "=" + AllTrim(NGSeek("SB1",TAX->TAX_CODRES,1,"SB1->B1_DESC")))
							aAdd(aCodResiduo,TAX->TAX_CODRES)
						EndIf
						If aScan(aCodClasse,{|x| x == TAX->TAX_CLASSE}) == 0
							aAdd(aClasse,AllTrim(TAX->TAX_CLASSE) + "=" + AllTrim(NGSEEK("TCS",TAX->TAX_CLASSE,1,"TCS->TCS_DESCRI")))
							aAdd(aCodClasse,TAX->TAX_CLASSE)
						EndIf
						If aScan(aCodTipGer,{|x| x == TAX->TAX_TPGERA}) == 0 .And. !Empty(TAX->TAX_TPGERA)
							aAdd(aTipGer,AllTrim(TAX->TAX_TPGERA) + "=" + X3Combo("TAX_TPGERA", TAX->TAX_TPGERA))
							aAdd(aCodTipGer,TAX->TAX_TPGERA)
						EndIf
					EndIf

				EndIf
			EndIf
		EndIf
	Next nPosShape

	//Se ja ha filtros para a planta, carrega dados
	If (nPosFil := aScan(::aFilter,{|x| x[__aFilter_Planta__] == ::cPlantaAtu })) > 0
		cFamilia := ::aFilter[nPosFil][__aFilter_Familia__]
		cCC      := ::aFilter[nPosFil][__aFilter_CC__]
		cCT      := ::aFilter[nPosFil][__aFilter_CT__]
		cResp    := ::aFilter[nPosFil][__aFilter_Resp__]

		//SIGAMDT
		cCF      := ::aFilter[nPosFil][__aFilter_Func__]
		cCTar    := ::aFilter[nPosFil][__aFilter_Tare__]

		//SIGASGA
		cResiduo	:= ::aFilter[nPosFil][__aFilter_Residuo__]
		cClasse	:= ::aFilter[nPosFil][__aFilter_Classe__]
		cTipGer	:= ::aFilter[nPosFil][__aFilter_TipGer__]


		lChk1    := ::aFilter[nPosFil][__aFilter_Eventos__][1]
		lChk2    := ::aFilter[nPosFil][__aFilter_Eventos__][2]
		lChk3    := ::aFilter[nPosFil][__aFilter_Eventos__][3]
		lChk4    := ::aFilter[nPosFil][__aFilter_Eventos__][4]
		lChk5    := ::aFilter[nPosFil][__aFilter_Eventos__][5]
	EndIf

	//Ordena alfabeticamente dados dos combobox
	aSort(aFamilia,2,,{|x,y| y > x})
	aSort(aCC,2,,{|x,y| y > x})
	aSort(aCT,2,,{|x,y| y > x})
	aSort(aResp,2,,{|x,y| y > x})
	// SIGAMDT
	aSort(aCF,2,,{|x,y| y > x})
	aSort(aCTar,2,,{|x,y| y > x})
	// SIGASGA
	aSort(aResiduo,2,,{|x,y| y > x})
	aSort(aClasse,2,,{|x,y| y > x})
	aSort(aTipGer,2,,{|x,y| y > x})

	Define Dialog oDlg From 5,5 To 250,570 Of Self COLOR CLR_BLACK,CLR_WHITE STYLE nOr(DS_SYSMODAL,WS_MAXIMIZEBOX,WS_POPUP) Pixel
		//oDlg:lEscClose := .F.

		oTPanel := TPaintPanel():New(0,0,0,0,oDlg,.F.)
			oTPanel:Align := CONTROL_ALIGN_ALLCLIENT
   		oTPanel:bLClicked := {||}

			//Container do Fundo
			oTPanel:addShape( "id="+cValToChar(::SetId())+";type=1;left=0;top=0;width=575;height=275;"+;
							  "gradient=1,0,0,0,180,0.0,#FFFFFF;pen-color=#FFFFFF;can-move=0;can-mark=0;is-container=" + If(lReleaseB,'0','1') + ";")
			//Gradiente
			oTPanel:addShape( "id="+cValToChar(::SetId())+";type=1;left=1;top=1;width=571;height=270;"+;
							  "gradient=1,0,0,0,380,0.0,#FFFFFF,0.1,#FDFBFD,1.0,#CDD1D4;pen-width=0;pen-color=#FFFFFF;can-move=0;can-mark=0;is-container=" + If(lReleaseB,'0','1') + ";")

			oExit := TBtnBmp2():New( 05,560,10,10,'br_cancel',,,,{|| (lConfirm := .F.,oDlg:End())},oDlg,,,.T. )

			oFiltros := TGroup():New(020,010,100,180,STR0368,oTPanel,CLR_BLACK,CLR_BLACK,.T.) //'Filtros'

			If __nModPG == 19

				@ 35,015 Say STR0072 Of oTPanel COLOR CLR_HBLUE Pixel //"Família"
				@ 33,055 Combobox oFamilia Var cFamilia Items aFamilia Size 120,50 Of oTPanel Pixel

				@ 50,015 Say STR0073 Of oTPanel COLOR CLR_HBLUE Pixel //"Centro Custo"
				@ 48,055 Combobox oCC Var cCC Items aCC Size 120,50 Of oTPanel Pixel

				@ 65,015 Say STR0074 Of oTPanel COLOR CLR_HBLUE Pixel //"Centro Trabalho"
				@ 63,055 Combobox oCT Var cCT Items aCT Size 120,50 Of oTPanel Pixel

				@ 80,015 Say STR0075 Of oTPanel COLOR CLR_HBLUE Pixel //"Responsável"
				@ 78,055 Combobox oResp Var cResp Items aResp Size 120,50 Of oTPanel Pixel

			ElseIf __nModPG == 35

				@ 35,015 Say STR0073 Of oTPanel COLOR CLR_HBLUE Pixel //"Centro Custo"
				@ 33,055 Combobox oCC Var cCC Items aCT Size 120,50 Of oTPanel Pixel

				@ 50,015 Say STR0429 Of oTPanel COLOR CLR_HBLUE Pixel //"Função"
				@ 48,055 Combobox oFun Var cCF Items aCF Size 120,50 Of oTPanel Pixel

				@ 65,015 Say STR0430 Of oTPanel COLOR CLR_HBLUE Pixel //"Tarefa"
				@ 63,055 Combobox oTa Var cCTar Items aCTar Size 120,50 Of oTPanel Pixel

				@ 80,015 Say STR0075 Of oTPanel COLOR CLR_HBLUE Pixel //"Responsável"
				@ 78,055 Combobox oResp Var cResp Items aResp Size 120,50 Of oTPanel Pixel

			ElseIf __nModPG == 56

				@ 35,015 Say STR0455 Of oTPanel COLOR CLR_HBLUE Pixel //"Resíduo"
				@ 33,055 Combobox oResiduo Var cResiduo Items aResiduo Size 120,50 Of oTPanel Pixel

				@ 50,015 Say STR0478 Of oTPanel COLOR CLR_HBLUE Pixel //"Classe"
				@ 48,055 Combobox oPGClasse Var cClasse Items aClasse Size 120,50 Of oTPanel Pixel

				@ 65,015 Say STR0477 Of oTPanel COLOR CLR_HBLUE Pixel //"Tipo Geração"
				@ 63,055 Combobox oTipGer Var cTipGer Items aTipGer Size 120,50 Of oTPanel Pixel
			EndIf

			oEventos := TGroup():New(020,185,100,280,STR0369,oTPanel,CLR_BLACK,CLR_BLACK,.T.)

			nLin := 30
			For nX := 1 To Len(aAlertas)
				If aAlertas[nX][__aAlertas_Habili__]

					nPosEvento := aScan(aEventos,{|x| x[1] == aAlertas[nX][__aAlertas_Evento__]})
					cEvento := aAlertas[nX][__aAlertas_Evento__]

					If nPosEvento > 0
						cEvento := aEventos[nPosEvento][2]
					EndIf

					o := TCheckBox():New(nLin,190,cEvento,&("{|| lChk"+cValToChar(nX)+"}"),oTPanel,100,10)
					o:bLClicked := &("{|| lChk"+cValToChar(nX)+" := !lChk"+cValToChar(nX)+"}")
					nLin += 13

				EndIf
			Next nX

			@ 110,195 Button oConfirm Prompt STR0063 Message "Ok - <Ctrl-O>" Size 38,12 Action (lConfirm := .T.,oDlg:End()) Of oTPanel Pixel //"Confirmar"
				oConfirm:SetCss(CSSButton(.T.))
			@ 110,240 Button oCancel Prompt STR0064 Message STR0065 Size 38,12 Action (lConfirm := .F.,oDlg:End()) Of oTPanel Pixel //"Cancelar"##"Cancelar - <Ctrl-X>"
				oCancel:SetCss(CSSButton())

	ACTIVATE DIALOG oDlg ON INIT (SetKey(K_CTRL_O,oConfirm:bAction),;
											SetKey(K_CTRL_X,oCancel:bAction)) CENTERED

	If lConfirm

		If nPosFil == 0
			aAdd(::aFilter,Array(11))
			nPosFil := Len(::aFilter)
			::aFilter[nPosFil][__aFilter_Planta__]  := ::cPlantaAtu
			::aFilter[nPosFil][__aFilter_Eventos__] := Array(5)
		EndIf

		::aFilter[nPosFil][__aFilter_Familia__] := cFamilia
		::aFilter[nPosFil][__aFilter_CC__]      := cCC
		::aFilter[nPosFil][__aFilter_CT__]      := cCT
		::aFilter[nPosFil][__aFilter_Resp__]    := cResp
		::aFilter[nPosFil][__aFilter_Func__]    := cCF
		::aFilter[nPosFil][__aFilter_Tare__]    := cCTar
		::aFilter[nPosFil][__aFilter_Residuo__] := cResiduo
		::aFilter[nPosFil][__aFilter_Classe__]  := cClasse
		::aFilter[nPosFil][__aFilter_TipGer__]  := cTipGer
		::aFilter[nPosFil][__aFilter_Eventos__][1] := lChk1
		::aFilter[nPosFil][__aFilter_Eventos__][2] := lChk2
		::aFilter[nPosFil][__aFilter_Eventos__][3] := lChk3
		::aFilter[nPosFil][__aFilter_Eventos__][4] := lChk4
		::aFilter[nPosFil][__aFilter_Eventos__][5] := lChk5


		For nPosShape := 1 To Len(::aShape)
			If ::aShape[nPosShape][__aShape_PlanSup__] == ::cPlantaAtu .And. ;
					::aShape[nPosShape][__aShape_IndCod__] $ "1/A"

				If __nModPG == 19
					dbSelectARea("ST9")
					dbSetOrder(1)
					lSeekCod := dbSeek(xFilial("ST9")+::aShape[nPosShape][__aShape_Codigo__])
				ElseIf __nModPG == 35
					dbSelectARea("TN0")
					dbSetOrder( 1 ) //TN0_FILIAL+TN0_NUMRIS
					lSeekCod := dbSeek(xFilial("TN0")+::aShape[nPosShape][__aShape_Codigo__])
				ElseIf __nModPG == 56
					dbSelectARea("TAX")
					dbSetOrder( 1 ) //TAX_CODRES
					lSeekCod := dbSeek(xFilial("TAX")+::aShape[nPosShape][__aShape_Codigo__])
				EndIf

				If lSeekCod

					lEvento := !lChk1 .Or. (lChk1 .And. ::aShape[nPosShape][__aShape_Alertas__][1][__aShape_aAlerta_Visible__])
					lEvento := lEvento .And. (!lChk2 .Or. !::aShape[nPosShape][__aShape_Alertas__][2][__aShape_aAlerta_Ativo__] .Or. (lChk2 .And. ::aShape[nPosShape][__aShape_Alertas__][2][__aShape_aAlerta_Visible__]))
					lEvento := lEvento .And. (!lChk3 .Or. !::aShape[nPosShape][__aShape_Alertas__][2][__aShape_aAlerta_Ativo__] .Or. (lChk3 .And. ::aShape[nPosShape][__aShape_Alertas__][3][__aShape_aAlerta_Visible__]))
					lEvento := lEvento .And. (!lChk4 .Or. !::aShape[nPosShape][__aShape_Alertas__][2][__aShape_aAlerta_Ativo__] .Or. (lChk4 .And. ::aShape[nPosShape][__aShape_Alertas__][4][__aShape_aAlerta_Visible__]))
					lEvento := lEvento .And. (!lChk5 .Or. !::aShape[nPosShape][__aShape_Alertas__][2][__aShape_aAlerta_Ativo__] .Or. (lChk5 .And. ::aShape[nPosShape][__aShape_Alertas__][5][__aShape_aAlerta_Visible__]))

					If __nModPG == 19

						lFamilia := AllTrim(ST9->T9_CODFAMI) == AllTrim(cFamilia) .Or. cFamilia == aFamilia[1]
						lCCusto  := AllTrim(ST9->T9_CCUSTO) == AllTrim(cCC) .Or. cCC == aCC[1]
						lCentrab := AllTrim(ST9->T9_CENTRAB) == AllTrim(cCT) .Or. cCT == aCT[1]
						lResp    := cResp == aResp[1] .Or. cResp == AllTrim(NGSEEK("TAF",'001'+::aShape[nPosShape][__aShape_NivSup__],2,"TAF->TAF_MAT"))

						::aShape[nPosShape][__aShape_Visivel__] := lFamilia .And. lCCusto .And. lCentrab .And. lEvento .And. lResp

					ElseIf __nModPG == 35

						lFuncao := AllTrim(TN0->TN0_CODFUN) == AllTrim(cCF) .Or. cCF == aCF[1]
						lTarefa := AllTrim(TN0->TN0_CODTAR) == AllTrim(cCTar) .Or. cCTar == aCTar[1]
						lCCusto := AllTrim(TN0->TN0_CC) == AllTrim(cCC) .Or. cCC == aCC[1]
						If lDeptoTAF
							lDepto  := AllTrim(TN0->TN0_DEPTO) == AllTrim(cDepto) .Or. cDepto == aDepto[1]
						EndIf
						lResp   := cResp == aResp[1] .Or. cResp == AllTrim(NGSEEK("TAF",'001'+::aShape[nPosShape][__aShape_NivSup__],2,"TAF->TAF_MAT"))

						::aShape[nPosShape][__aShape_Visivel__] := lFuncao .And. lTarefa .And. lCCusto .And. lEvento .And. lResp .And. If(lDeptoTAF,lDepto,.T.)

					ElseIf __nModPG == 56

						lResiduo := AllTrim(TAX->TAX_CODRES) == AllTrim(cResiduo) .Or. cResiduo == aResiduo[1]
						lClasse  := AllTrim(TAX->TAX_CLASSE) == AllTrim(cClasse) .Or. cClasse == aClasse[1]
						lTipGer := AllTrim(TAX->TAX_TPGERA) == AllTrim(cTipGer) .Or. cTipGer == aTipGer[1]

						::aShape[nPosShape][__aShape_Visivel__] := lResiduo .And. lClasse .And. lTipGer .And. lEvento

					EndIf

					::oTPanel:SetVisible(::aShape[nPosShape][__aShape_IdShape__],::aShape[nPosShape][__aShape_Visivel__])

					For nAlerta := 1 To Len(::aShape[nPosShape][__aShape_Alertas__])
						If ::aShape[nPosShape][__aShape_Alertas__][nAlerta][__aShape_aAlerta_Visible__]
							If ::aShape[nPosShape][__aShape_Alertas__][nAlerta][__aShape_aAlerta_Blinker__]
								If !::aShape[nPosShape][__aShape_Visivel__]
									::oTPanel:DeleteBlinker(::aShape[nPosShape][__aShape_Alertas__][nAlerta][__aShape_aAlerta_IdShape__])
								Else
									::InsertBlinker(::aShape[nPosShape][__aShape_Alertas__][nAlerta][__aShape_aAlerta_IdShape__])
								EndIf
							EndIf
							::oTPanel:SetVisible(::aShape[nPosShape][__aShape_Alertas__][nAlerta][__aShape_aAlerta_IdShape__],::aShape[nPosShape][__aShape_Visivel__])
						EndIf
					Next nAlerta
				EndIf
			EndIf
		Next nX

	EndIf

	//Restaura teclas de atalho
	RestKeys(aKeys,.T.)

	//Desabilita Panel preto transparente
	::SetBlackPnl(.F.)
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} ConfigTimer
Método que exibe Dialog para configurar a Atualizacao Automatica

@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Method ConfigTimer() Class TNGPG
	Local oDlg, oTPanel
	Local oConfirm, oCancel, oHabili, oExit
	Local lConfirm := .F.
	Local nTimer := ::oTimer:nInterval / 60000
	Local lHabili := ::oTimer:lActive

	//Guarda bloco de codigo das telhas de atalho
	Local aKeys := GetKeys()

	//Limpa tecla de atalhos para nao poderem ser executados
	RestKeys(,.T.)

	//Habilita Panel preto transparente
	::SetBlackPnl(.T.)

		//Destroi com o FWBalloon se ja estiver criado
	::DestroyBalloon()

	Define Dialog oDlg From 5,5 To 100,350 Of Self COLOR CLR_BLACK,CLR_WHITE STYLE nOr(DS_SYSMODAL,WS_MAXIMIZEBOX,WS_POPUP) Pixel
		//oDlg:lEscClose := .F.

		oTPanel := TPaintPanel():New(0,0,0,0,oDlg,.F.)
			oTPanel:Align := CONTROL_ALIGN_ALLCLIENT
   		oTPanel:bLClicked := {||}

			//Container do Fundo
			oTPanel:addShape( "id="+cValToChar(::SetId())+";type=1;left=0;top=0;width=355;height=125;"+;
							  "gradient=1,0,0,0,080,0.0,#FFFFFF;pen-color=#FFFFFF;can-move=0;can-mark=0;is-container=" + If(lReleaseB,'0','1') + ";")
			//Gradiente
			oTPanel:addShape( "id="+cValToChar(::SetId())+";type=1;left=1;top=1;width=351;height=120;"+;
							  "gradient=1,0,0,0,180,0.0,#FFFFFF,0.1,#FDFBFD,1.0,#CDD1D4;pen-width=0;pen-color=#FFFFFF;can-move=0;can-mark=0;is-container=" + If(lReleaseB,'0','1') + ";")

			oExit := TBtnBmp2():New( 05,340,10,10,'br_cancel',,,,{|| (lConfirm := .F.,oDlg:End())},oDlg,,,.T. )

			@ 15,015 Say STR0076 Of oTPanel COLOR CLR_HBLUE Pixel //"Atualização (minutos)"
			@ 13,075 MsGet nTimer Picture "999" SIZE 030,09 Of oTPanel Valid NaoVazio(nTimer) When lHabili Pixel HASBUTTON
			oHabili := TCheckBox():New(30,15,STR0370,{||lHabili},oDlg,50,10,,,,,,,,.T.,,,) //'Habilitar'
				oHabili:bLClicked := {|| lHabili:=!lHabili }

			@ 040,085 Button oConfirm Prompt STR0063 Message "Ok - <Ctrl-O>" Size 38,12 Action (lConfirm := .T.,oDlg:End()) Of oTPanel Pixel //"Confirmar"
				oConfirm:SetCss(CSSButton(.T.))
			@ 040,130 Button oCancel Prompt STR0064 Message STR0065 Size 38,12 Action (lConfirm := .F.,oDlg:End()) Of oTPanel Pixel //"Cancelar"##"Cancelar - <Ctrl-X>"
				oCancel:SetCss(CSSButton())

	ACTIVATE DIALOG oDlg ON INIT (SetKey(K_CTRL_O,oConfirm:bAction),;
											SetKey(K_CTRL_X,oCancel:bAction)) CENTERED

	If lConfirm
		::oTimer:lActive   := lHabili
		::oTimer:nInterval := nTimer * 60000
	EndIf

	//Restaura teclas de atalho
	RestKeys(aKeys,.T.)

	//Desabilita Panel preto transparente
	::SetBlackPnl(.F.)
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} GetArrAlerts
Método que retorna array contendo a configuracao dos alertas

@param cCargo Cargo da Tree
@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return aAlertas
/*/
//---------------------------------------------------------------------
Method GetArrAlerts(cCargo) class TNGPG

	Local nX, nY
	Local aAlertas
	Local cPgEvento, cStrAlert

	dbSelectArea(::cTrbTree)
	dbSetOrder(2)
	dbSeek("001"+cCargo)
	If __nModPG == 19
		cPgEvento := (::cTrbTree)->EVENTO
	ElseIf __nModPG == 35
		cPgEvento := (::cTrbTree)->EVEMDT
	ElseIf __nModPG == 56
		cPgEvento := (::cTrbTree)->EVESGA
	EndIf

	// cPgEvento := "001;teste;FFFFFF;1|;;;|;;;|;;;|;;;|"
	// cPgEvento := "001;teste;FFFFFF;1;1|;;;;|;;;;|;;;;|;;;;|" ## SGA

	If Empty(cPgEvento)
		aAlertas := {}

		//aAdd(aAlertas,{HABILITADO,EVENTO,FUNCAO,COR,BLINKER,TIPO})
		aAdd(aAlertas,{.F.,'000',Space(10),'FFFFFF',.T.,""})
		aAdd(aAlertas,{.F.,'000',Space(10),'FF00F1',.T.,""})
		aAdd(aAlertas,{.F.,'000',Space(10),'FF0000',.T.,""})
		aAdd(aAlertas,{.F.,'000',Space(10),'000CCC',.T.,""})
		aAdd(aAlertas,{.F.,'000',Space(10),'FFFF00',.T.,""})

	Else
		aAlertas := Array(5,6)
		For nX := 1 To 5

			nAt 		:= At('|',cPgEvento)
			cString 	:= Substr(cPgEvento,1,nAt)
			cPgEvento	:= Substr(cPgEvento,nAt+1,Len(cPgEvento)-nAt)
			nAt 		:= At(';',cString)

			If (aAlertas[nX][__aAlertas_Habili__] := nAt-1 > 0)
				For nY := 2 To 6

					If Len(cString) > 0
						nAt       := If(nAt == 0, Len(cString), nAt)
						cStrAlert := Substr(cString,1,nAt-1)
					Else
						cStrAlert := ""
					Endif

					If nY == 5
						aAlertas[nX][nY] := cStrAlert == '1'
					Else
						aAlertas[nX][nY] := cStrAlert
					EndIf

					cString	:= Substr(cString, nAt+1, Len(cString)-nAt)
					nAt    	:= At(';',cString)
				Next nY
			Else
				aAlertas[nX][__aAlertas_Evento__]  := '000'
				aAlertas[nX][__aAlertas_Funcao__]  := Space(10)
				aAlertas[nX][__aAlertas_ClrHex__]  := 'FFFFFF'
				aAlertas[nX][__aAlertas_Blinker__] := .T.
				aAlertas[nX][__aAlertas_Tipo__]    := ""
			EndIf
		Next nX

	EndIf

Return aAlertas

//---------------------------------------------------------------------
/*/{Protheus.doc} GetArrEvents
Método que retorna array contendo todas as opcoes de eventos

@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return aEventos
/*/
//---------------------------------------------------------------------
Method GetArrEvents(cType) Class TNGPG

	Local aEventos := {}

	Default cType := ""

	If __nModPG == 19

		aEventos := {	{"000",STR0077},; //"Específico"
							{"001",STR0026},; //"O.S Corretiva"
							{"002",STR0078},; //"O.S Corretiva Pendente"
							{"003",STR0079},; //"O.S Corretiva Liberada"
							{"004",STR0080},; //"O.S Corretiva Atrasada"
							{"005",STR0081},; //"O.S Preventiva"
							{"006",STR0082},; //"O.S Preventiva Pendente"
							{"007",STR0083},; //"O.S Preventiva Liberada"
							{"008",STR0084},; //"O.S Preventiva Atrasada"
							{"009",STR0085},; //"Solicitação de Serviço Aberta"
							{"010",STR0086},; //"S.S Aguardando Análise"
							{"011",STR0087},; //"S.S Distribuída"
							{"012",STR0385},; //"O.S gerada por uma S.S"
							{"013",STR0088},; //"S.S com Atraso Cadastrado"
							{"014",STR0089},; //"S.S s/ resposta de Pesq. Satisf."
							{"015",STR0090},; //"O.S de Lubrificação"
							{"016",STR0091}} //"O.S de Lubrificação Atrasada"


	ElseIf __nModPG == 35

		aEventos := {	{"000",STR0077},; //"Específico"
							{"001",STR0431},;//"EPI não Entregue"
							{"002",STR0432},;//"EPI Vencido"
							{"003",STR0433},;//"EPI C.A. Vencido"
							{"004",STR0434},;//"Exames Vencidos"
							{"005",STR0435},;//"Plano Ação Vencidos"
							{"006",STR0436},;//"Laudo Vencido"
							{"007",STR0437}} //"Laudo a Vencer"

	ElseIf __nModPG == 56

		If cType == "A"
			aEventos := {	{"000",STR0077},; //"Específico"
								{"001",STR0480},; //"Ocorrências de Resíduo Pendentes"
								{"002",STR0481},; //"Ocorrências de Resíduo Em Carga"
								{"003",STR0482},; //"FMR em Ponto Coleta"
								{"004",STR0483},; //"FMR em Área de Pesagem"
								{"005",STR0484},; //"FMR em Armazém"
								{"006",STR0485},; //"FMR Não Conforme"
								{"007",STR0486}} //"FMR Reaberta"
		Endif

		If cType == "B"
			aEventos := {	{"008",STR0077},; //"Específico"
								{"009",STR0487},;
								{"010",STR0488}}
		Endif

		If cType == "C"
			aEventos := {	{"011",STR0077},; //"Específico"
								{"012",STR0489},; //"FMR em Ponto de Coleta"
								{"013",STR0490},; //"FMR em Área de Pesagem"
								{"014",STR0491},; //"FMR em Armazém"
								{"015",STR0492},; //"FMR Não Conforme"
								{"016",STR0493}} //"FMR Reaberta"
		Endif

	EndIf

Return aEventos

//---------------------------------------------------------------------
/*/{Protheus.doc} ConfigAlerts
Método que exibe Dialog para config. os Alertas sobre a Planta em Foco

@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Method ConfigAlerts() Class TNGPG

	Local oDlg, oTPanel, oFuncao, oTColor, oHabilitado, oConfirm, oCancel, oAplicar, oExit, oTipoEvt
	Local lConfirm   := .F.
	Local cEvento    //:= aItemsCBox[1]
	Local aPosicao   := {"1="+STR0092,"2="+STR0093,"3="+STR0094,"4="+STR0095,"5="+STR0096} //"Primeira"###"Segunda"###"Terceira"###"Quarta"###"Quinta"
	Local cFuncao    := Space(14)
	Local cPosicao   := '1'
	Local cTipoEvt := ""
	Local aAlertas   := ::GetArrAlerts('001'+cFilAnt) //(::cPlantaAtu) - Retirado para melhoria futura
	Local aRGB := {}
	Local lHabilitado:= .T.
	local lBlinker   := .T.
	Local nOldAt     := 1
	Local cPgEvento
	Local nX
	Local aEventos
	Local nTamEvent
	Local nLineObj := 14
	Local nAltDlg := 350

	Local nAtOld := 1

	//Guarda bloco de codigo das telhas de atalho
	Local aKeys := GetKeys()

	Private _oPosicao
	Private _oEvento
	Private aTiposEvt  := {}
	Private aItemsCBox := {}

	//Limpa tecla de atalhos para nao poderem ser executados
	RestKeys(,.T.)

	//Habilita Panel preto transparente
	::SetBlackPnl(.T.)

	//Destroi com o FWBalloon se ja estiver criado
	::DestroyBalloon()

	cEvento := aAlertas[1][__aAlertas_Evento__]

	If __nModPG == 56
		aTiposEvt := {"A="+STR0455,"B="+STR0459,"C="+STR0460}
		aEventos  := ::GetArrEvents(If(Empty(aAlertas[1][__aAlertas_Tipo__]),"A",aAlertas[1][__aAlertas_Tipo__]))
		nAltDlg   += 20
		nTamEvent := 5
	Else
		aEventos  := ::GetArrEvents()
		nTamEvent := 4
	Endif

	For nX := 1 To Len(aEventos)
		aAdd(aItemsCBox,aEventos[nX][1]+"="+aEventos[nX][2])
	Next nX

	Define Dialog oDlg From 5,5 To nAltDlg,560 Of Self COLOR CLR_BLACK,CLR_WHITE STYLE nOr(DS_SYSMODAL,WS_MAXIMIZEBOX,WS_POPUP) Pixel
		oDlg:lEscClose := .F.

		oTPanel := TPaintPanel():New(0,0,0,0,oDlg,.F.)
			oTPanel:Align := CONTROL_ALIGN_ALLCLIENT
   		oTPanel:bLClicked := {|| If(ValidAlert(oDlg,aAlertas,_oPosicao,oTPanel:ShapeAtu,@nAtOld),ClickAlerta(oTPanel:ShapeAtu,aAlertas,@nOldAt,@cPosicao,@cEvento,@cFuncao,@lHabilitado,@lBlinker,oTColor,@cTipoEvt),Nil)}

			//Container do Fundo
			oTPanel:addShape(	"id="+cValToChar(::SetId())+";type=1;left=0;top=0;width=565;height=" + cValToChar(nAltDlg+25) + ";"+;
								"gradient=1,0,0,0,180,0.0,#FFFFFF;pen-color=#FFFFFF;can-move=0;can-mark=0;is-container=" + If(lReleaseB,'0','1') + ";")
			//Gradiente
			oTPanel:addShape(	"id="+cValToChar(::SetId())+";type=1;left=1;top=1;width=561;height=" + cValToChar(nAltDlg+20) +";"+;
								"gradient=1,0,0,0,380,0.0,#FFFFFF,0.1,#FDFBFD,1.0,#CDD1D4;pen-width=0;pen-color=#FFFFFF;can-move=0;can-mark=0;is-container=" + If(lReleaseB,'0','1') + ";")

			//Configuracao do Blinker
			oTPanel:setBlinker(500)

			oExit := TBtnBmp2():New( 05,550,10,10,'br_cancel',,,,{|| (lConfirm := .F.,oDlg:End())},oDlg,,,.T. )

			@ nLineObj+2,015 Say STR0097 Of oTPanel COLOR CLR_HBLUE Pixel //"Posição:"
			@ nLineObj,055 Combobox _oPosicao Var cPosicao Items aPosicao When Len(aPosicao) > 0 Size 50,50 Of oTPanel ;
											On Change If(ValidAlert(oDlg,aAlertas,_oPosicao,_oPosicao:nAt,@nAtOld),(ChangePosition(aAlertas,_oPosicao:nAt,@nOldAt,@cPosicao,@cEvento,@cFuncao,@lHabilitado,@lBlinker,oTColor,@cTipoEvt),;
															PreviewAlert(oTPanel,aAlertas)),Nil) Pixel
				_oPosicao:nHeight	:= 25
				_oPosicao:nWidth	:= 150
				_oPosicao:nAt		:= 1
				_oPosicao:bHelp	:= { || ShowHelpCpo(NoAcento(AnsiToOem(STR0097)), ;
				 					{STR0371,"1="+STR0092,"2="+STR0093,"3="+STR0094,"4="+STR0095,"5="+STR0096},6)} //"Indica a posição no Alerta que se estará alterando."
			//@ 29,055 MsGet _oPosicao Var cPosicao Picture "9" Of oTPanel SIZE 10,09 Pixel

			nLineObj += 15

			oHabilitado := TCheckBox():New(nLineObj+2,190,STR0373,{||lHabilitado},oTPanel,50,10) //'Habilitado'
				lHabilitado := aAlertas[1][__aAlertas_Habili__]
				oHabilitado:bLClicked   := {|| (If(lBlinker.And.lHabilitado,oTPanel:DeleteBlinker(_oPosicao:nAt),),;
															If(lHabilitado,oTPanel:DeleteItem(_oPosicao:nAt),Nil),;
															aAlertas[_oPosicao:nAt][__aAlertas_Habili__] := lHabilitado := !lHabilitado,;
															PreviewAlert(oTPanel,aAlertas,_oPosicao:nAt)) }

			oBlinker := TCheckBox():New(nLineObj+2,230,STR0374,{|| lBlinker},oTPanel,100,10) //'Piscar'
				lBlinker := aAlertas[1][__aAlertas_Blinker__]
				oBlinker:bWhen     := {|| lHabilitado}
				oBlinker:bLClicked := {|| (aAlertas[_oPosicao:nAt][__aAlertas_Blinker__] := lBlinker := !lBlinker,PreviewAlert(oTPanel,aAlertas)) }

			If !Empty(aTiposEvt)

				Private oPGClass := Self

				cTipoEvt := If(Empty(aAlertas[1][__aAlertas_Tipo__]),SubStr(aTiposEvt[1],1,1),aAlertas[1][__aAlertas_Tipo__])

				@ nLineObj+2,015 Say "Tipo" Of oTPanel COLOR CLR_HBLUE  Pixel //"Posição:"
				@ nLineObj,055 Combobox oTipoEvt Var cTipoEvt Items aTiposEvt Size 20,60 Of oTPanel ;
												On Change SetTipoEvt(@cEvento, oPGClass:GetArrEvents(cTipoEvt)) When lHabilitado Pixel
					oTipoEvt:bHelp := { || ShowHelpCpo(NoAcento(AnsiToOem(STR0097)), ;
					 								{STR0494},1)} //"Indica o tipo do evento que se estará alterando."

				nLineObj += 15

			Endif

			@ nLineObj+2,015 Say STR0098 Of oTPanel COLOR CLR_HBLUE Pixel //"Evento:"
			@ nLineObj,055 Combobox _oEvento Var cEvento Items aItemsCBox Size 50,50 Of oTPanel ;
									On Change (	aAlertas[_oPosicao:nAt][2] := cEvento,;
												aAlertas[_oPosicao:nAt][6] := cTipoEvt,;
												PreviewAlert(oTPanel,aAlertas)) When lHabilitado Pixel
				_oEvento:nHeight := 25
				_oEvento:nWidth  := 215
				_oEvento:nAt		:= Val(aAlertas[1][__aAlertas_Evento__])+1
				_oEvento:bHelp	:= { || ShowHelpCpo(STR0098, ;
				 								{STR0372},1)} //"Evento que será executado no Visualizacao da Planta Gráfica, exibindo a posição do Alerta caso o resultado do evento seja verdadeiro."

			nLineObj += 15

			@ nLineObj+2,015 Say STR0099 Of oTPanel Pixel //"Função:"
			@ nLineObj,055 MsGet oFuncao Var cFuncao Picture "@!" Of oTPanel SIZE 70,09 Valid Vazio(cFuncao) .Or. NGFUNCRPO(cFuncao) When lHabilitado Pixel
				cFuncao := aAlertas[1][__aAlertas_Funcao__]
				oFuncao:bHelp := { || ShowHelpCpo(NoAcento(AnsiToOem(STR0099)), ;
				 					{STR0375},1)} //"Função de usuário retornando lógica SQL para incrementar a condição específicada do Evento."

			nLineObj += 16

			oTColor := tColorTriangle():New(nLineObj,013,oTPanel,150,080)
				aRGB := NGHEXRGB(aAlertas[1][__aAlertas_ClrHex__])
				oTColor:SetColorIni( RGB(aRGB[1],aRGB[2],aRGB[3]) )
				oTColor:bWhen := {|| lHabilitado}

			//oGroup := TGroup():New(40,170,150,270,'Preview',oTPanel,CLR_BLACK,CLR_BLACK,.T.)
			nLineObj += 105

			@ nLineObj,140 Button oAplicar Prompt STR0100 Size 38,12 Action If(ValidAlert(oDlg,aAlertas,_oPosicao,0,@nAtOld),(aAlertas[_oPosicao:nAt][4] := NGRGBHEX(ConvRGB(oTColor:RetColor())),PreviewAlert(oTPanel,aAlertas)),Nil) Of oTPanel Pixel //"Aplicar"
				oAplicar:SetCss(CSSButton())
			@ nLineObj,185 Button oConfirm Prompt STR0063 Message "Ok - <Ctrl-O>" Size 38,12 Action If(ValidAlert(oDlg,aAlertas,_oPosicao,0,@nAtOld),(ChangePosition(aAlertas,_oPosicao:nAt,@nOldAt,@cPosicao,@cEvento,@cFuncao,@lHabilitado,@lBlinker,oTColor,cTipoEvt),; //"Confirmar"
																			(lConfirm := .T.,oDlg:End()) ),Nil) Of oTPanel Pixel
				oConfirm:SetCss(CSSButton(.T.))
			@ nLineObj,230 Button oCancel Prompt STR0064 Message STR0065 Size 38,12 Action (lConfirm := .F.,oDlg:End()) Of oTPanel Pixel //"Cancelar"##"Cancelar - <Ctrl-X>"
				oCancel:SetCss(CSSButton())

			PreviewAlert(oTPanel,aAlertas)
	ACTIVATE DIALOG oDlg ON INIT (SetKey(K_CTRL_O,oConfirm:bAction),;
											SetKey(K_CTRL_X,oCancel:bAction)) CENTERED

	If lConfirm

		cPgEvento := ""
		For nX := 1 To Len(aAlertas)
			If aAlertas[nX][__aAlertas_Habili__]
				cPgEvento += aAlertas[nX][__aAlertas_Evento__]+";"+aAlertas[nX][__aAlertas_Funcao__]+";"+;
								aAlertas[nX][__aAlertas_ClrHex__]+";"+If(aAlertas[nX][__aAlertas_Blinker__],"1","2")
				If !Empty(cTipoEvt)
					cPgEvento += ";" + aAlertas[nX][__aAlertas_Tipo__]
				Endif
				cPgEvento += "|"
			Else
				cPgEvento += Replicate(";",nTamEvent-1) + "|"
			EndIf
		Next nX

		dbSelectArea(::cTrbTree)
		dbSetOrder(2)
		dbSeek('001001'+cFilAnt)
		RecLock(::cTrbTree,.F.)
		If __nModPG == 19
			(::cTrbTree)->EVENTO := cPgEvento
		ElseIf __nModPG == 35
			(::cTrbTree)->EVEMDT := cPgEvento
		ElseIf __nModPG == 56
			(::cTrbTree)->EVESGA := cPgEvento
		EndIf
		MsUnLock()

		//-----------------------------------------------------------------
		// Identifica que a planta teve alterações e necessita ser salva
		//-----------------------------------------------------------------
		::lModified := .T.
	EndIf

	//Restaura teclas de atalho
	RestKeys(aKeys,.T.)

	//Desabilita Panel preto transparente
	::SetBlackPnl(.F.)
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidAlert
Função para validar tela de Alertas

@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return .T. ou .F.
/*/
//---------------------------------------------------------------------
Static Function ValidAlert(oDlg,aAlertas,oPosicao,nAt,nAtOld)
	Local nX

	If !(nAt >= 0 .And. nAt <= 5)
		Return .F.
	EndIf

	If aAlertas[nAtOld][__aAlertas_Habili__] .And. nAtOld != nAt
		For nX := 1 To Len(aAlertas)

			If nX != nAtOld .And. aAlertas[nX][__aAlertas_Habili__] .And. ;
				aAlertas[nX][__aAlertas_Evento__] == aAlertas[nAtOld][__aAlertas_Evento__] .And. ;
				aAlertas[nX][__aAlertas_Funcao__] == aAlertas[nAtOld][__aAlertas_Funcao__] .And. ;
				aAlertas[nX][__aAlertas_Tipo__] == aAlertas[nAtOld][__aAlertas_Tipo__]

				MsgStop(STR0376,STR0348) //"Já existe um Alerta com esta mesma configuração."##"Atenção"

				oPosicao:Select(nAtOld)
				oDlg:SetFocus()
				Return .F.
			EndIf
		Next nX
	EndIf

	If nAt != 0
		nAtOld := nAt
	endIf
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} ClickAlerta
Função usada na configuração do Alerta para fazer alterações de
variáveis em tela

@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function ClickAlerta(nShapeAtu,aAlertas,nOldAt,cPosicao,cEvento,cFuncao,lHabilitado,lBlinker,oTColor,cTipoEvt)

	If nShapeAtu >= 1 .And. nShapeAtu <= 5
		ChangePosition(aAlertas,nShapeAtu,@nOldAt,@cPosicao,@cEvento,@cFuncao,@lHabilitado,@lBlinker,oTColor,@cTipoEvt)
	EndIf

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} ChangePosition

@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function ChangePosition(aAlertas,nAt,nOldAt,cPosicao,cEvento,cFuncao,lHabilitado,lBlinker,oTColor,cTipoEvt)

	oTColor:SetFocus()
	_oPosicao:SetFocus()
	aAlertas[nOldAt][__aAlertas_Habili__]  := lHabilitado
	aAlertas[nOldAt][__aAlertas_Evento__]  := cEvento
	aAlertas[nOldAt][__aAlertas_Funcao__]  := cFuncao
	aAlertas[nOldAt][__aAlertas_ClrHex__]  := NGRGBHEX(ConvRGB(oTColor:RetColor()))
	aAlertas[nOldAt][__aAlertas_Blinker__] := lBlinker
	aAlertas[nOldAt][__aAlertas_Tipo__]    := cTipoEvt

	If nOldAt != nAt

		cPosicao		:= cValToChar(nAt)
		lHabilitado	:= aAlertas[nAt][__aAlertas_Habili__] := .T.
		cFuncao		:= aAlertas[nAt][__aAlertas_Funcao__]
		aRGB			:= NGHEXRGB(aAlertas[nAt][__aAlertas_ClrHex__])
		lBlinker		:= aAlertas[nAt][__aAlertas_Blinker__]
		cTipoEvt		:= aAlertas[nAt][__aAlertas_Tipo__]

		If !Empty(aTiposEvt)
			If Empty(cTipoEvt)
				aAlertas[nAt][__aAlertas_Tipo__]   := cTipoEvt := SubStr(aTiposEvt[1],1,1)

				aItemsCBox      := GetCbxEvt(oPGClass:GetArrEvents(cTipoEvt))
				_oEvento:aItems := aClone(aItemsCBox)

				aAlertas[nAt][__aAlertas_Evento__] := cEvento := SubStr(aItemsCBox[1],1,At("=",aItemsCBox[1])-1)
			Else
				aItemsCBox      := GetCbxEvt(oPGClass:GetArrEvents(cTipoEvt))
				_oEvento:aItems := aClone(aItemsCBox)
				cEvento			:= aAlertas[nAt][__aAlertas_Evento__]
			Endif
		Else
			cEvento := aAlertas[nAt][__aAlertas_Evento__]
		Endif

		oTColor:SetColor(RGB(aRGB[1],aRGB[2],aRGB[3]))
		oTColor:SetColorIni(RGB(aRGB[1],aRGB[2],aRGB[3]))
		nOldAt := nAt

	EndIf
	oTColor:SetFocus()
	_oEvento:SetFocus()
	_oPosicao:SetFocus()
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} PreviewAlert

@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function PreviewAlert(oTPanel,aAlertas,nId)

	Local nX
	Local nQuant := 0
	Local nStartAngle := 360
	Local nSweepLength
	Local aItemsPrv := {}

	Default nId := 0

	For nX := 1 To Len(aAlertas)
		If aAlertas[nX][1]
			nQuant++
		EndIf
   Next nX

	aItemsPrv := aClone(aItemsCBox)

	nSweepLength := If(nQuant==5,90,360/nQuant)
	For nX := 1 To Len(aAlertas)
		If aAlertas[nX][1]
			If !Empty(aAlertas[nX][__aAlertas_Tipo__])
				aItemsPrv := GetCbxEvt(oPGClass:GetArrEvents(aAlertas[nX][__aAlertas_Tipo__]))
			Endif

			cToolTip := cValToChar(nX)+" - "+SubStr(aItemsPrv[aScan(aItemsPrv,{|x| SubStr(x,1,3) == aAlertas[nX][2] })],5,30)

			If nId != nX
				oTPanel:DeleteItem(nX)
			EndIf
			If nX != Len(aAlertas) .Or. nQuant < 5
				oTPanel:addShape("id="+Str(nX)+";type=4;start-angle="+Str(nStartAngle)+";sweep-length="+Str(nSweepLength)+;
										";left=345;top=100;width=186;height=186;gradient=2,93,93,103,-1,0.76,#"+aAlertas[nX][__aAlertas_ClrHex__]+;
										",1.0,#000000;pen-color=#000000;tooltip="+cToolTip+";can-move=0;is-container=" + If(lReleaseB,'1','0') + ";can-mark=1;")
				nStartAngle  -= nSweepLength
			Else
				oTPanel:addShape("id="+Str(nX)+";type=4;start-angle=0;sweep-length=360"+;
										";left=390;top=145;width=100;height=100;gradient=2,40,40,103,-1,0.76,#"+aAlertas[nX][__aAlertas_ClrHex__]+;
										",1.0,#000000;pen-color=#000000;tooltip="+cToolTip+";can-move=0;is-container=" + If(lReleaseB,'1','0') + ";can-mark=1;")
			EndIf

			If aAlertas[nX][5]
				oTPanel:InsertBlinker(nX)
			Else
				oTPanel:DeleteBlinker(nX)
			EndIf
		EndIf
   Next nX
   oTPanel:SetFocus()

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} SetTipoEvt
Seta o tipo do evento

@author Gabriel Werlich
@since 04/03/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function SetTipoEvt(cEvento, aEventos)

	aItemsCBox := GetCbxEvt(aEventos)

	_oEvento:aItems := aClone(aItemsCBox)
	cEvento     	:= aEventos[1][1]

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} GetCbxEvt
Preenhe o array aItemsCBox conforme o tipo de evento.

@author Gabriel Werlich
@since 04/03/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function GetCbxEvt(aEventos)

	Local aItemsCbox := {}
	Local nX

	For nX := 1 To Len(aEventos)
		aAdd(aItemsCBox,aEventos[nX][1]+"="+aEventos[nX][2])
	Next nX

Return aItemsCBox

//---------------------------------------------------------------------
/*/{Protheus.doc} Legend
Método que exibe Dialog com todas as opcoes de Legenda para os Alertas

@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Method Legend() Class TNGPG
	Local oTPanel, oDlg, oExit, oBmp
	Local aAlertas := ::GetArrAlerts('001'+cFilAnt)
	Local aEventos := {}
	Local nX
	Local nDlgAlt := If(::lEditMode,230,440)
	// Variaveis de tabalho para os objetos do TGroup
	Local nPosGp1 := 120
	Local nPosGp2I:= 130
	Local nPosGp2F:= 215
	Local nTop    := 270
	//Guarda bloco de codigo das telhas de atalho
	Local aKeys := GetKeys()
	Local nLineLeg := 15

	If __nModPG == 35
		nDlgAlt += 60
		If !::lEditMode
			nPosGp2I+= 30
			nTop    += 60
		EndIf
		nPosGp1   += 30
		nPosGp2F  += 30
	ElseIf __nModPG == 56
		nDlgAlt  += 45
		If !::lEditMode
			nPosGp2I += 15
			nTop    += 47
		EndIf
		nPosGp1  += 20
		nPosGp2F += 31
	EndIf

	//Limpa tecla de atalhos para nao poderem ser executados
	RestKeys(,.T.)

	//Habilita Panel preto transparente
	::SetBlackPnl(.T.)

	Define Dialog oDlg From 5,5 To nDlgAlt,360 Of Self COLOR CLR_BLACK,CLR_WHITE STYLE nOr(DS_SYSMODAL,WS_MAXIMIZEBOX,WS_POPUP) Pixel

		oTPanel := TPaintPanel():New(0,0,0,0,oDlg,.F.)
			oTPanel:Align := CONTROL_ALIGN_ALLCLIENT

			//Container do Fundo
			oTPanel:addShape(	"id="+cValToChar(::SetId())+";type=1;left=0;top=0;width=365;height="+Str(nDlgAlt+25)+";"+;
								"gradient=1,0,0,0,180,0.0,#FFFFFF;pen-color=#FFFFFF;can-move=0;can-mark=0;is-container=" + If(lReleaseB,'0','1') + ";")
			//Gradiente
			oTPanel:addShape(	"id="+cValToChar(::SetId())+";type=1;left=1;top=1;width=361;height="+Str(nDlgAlt+20)+";"+;
								"gradient=1,0,0,0,380,0.0,#FFFFFF,0.1,#FDFBFD,1.0,#CDD1D4;pen-width=0;pen-color=#FFFFFF;tooltip=Configuração de Eventos e Alertas;can-move=0;can-mark=0;is-container=" + If(lReleaseB,'0','1') + ";")

		//oExit := TButton():New( 002, 002, "<",oDlg,{|x,y| },26,26,,,.F.,.T.,.F.,,.F.,,,.F. )
		oExit := TBtnBmp2():New( 05,350,10,10,'br_cancel',,,,{|| oDlg:End()},oDlg,,,.T. )
			//oExit:Align := CONTROL_ALIGN_RIGHT
			//oExit:SetCSS("QPushButton:hover {background-image: url(br_vermelho.png); }")

		TGroup():New(05,05,nPosGp1,175,STR0377,oTPanel,CLR_BLACK,CLR_BLACK,.T.) //"Árvore Lógica"

		oBmp := TBitmap():New(nLineLeg,10,0,0,"PREDIO",,.T.,oTPanel,,,.F.,.F.,,,.F.,,.T.,,.F.)
		oBmp:lAutoSize := .T.

		TSay():New(nLineLeg+3,30,{|| STR0378},oTPanel,,,,,,.T.,CLR_BLACK,,200,20) //'Empresa Principal'

		nLineLeg += 15

		If __nModPG == 19
			oBmp := TBitmap():New(nLineLeg,11,0,0,"ENGRENAGEM",,.T.,oTPanel,,,.F.,.F.,,,.F.,,.T.,,.F.)
			oBmp:lAutoSize := .T.

			TSay():New(nLineLeg+3,30,{|| STR0379},oTPanel,,,,,,.T.,CLR_BLACK,,200,20) //'Bem'

			nLineLeg += 15

			oBmp := TBitmap():New(nLineLeg,10,0,0,'ng_ico_bem_planta',,.T.,oTPanel,,,.F.,.F.,,,.F.,,.T.,,.F.)
			oBmp:lAutoSize := .T.

			TSay():New(nLineLeg+4,30,{|| STR0413},oTPanel,,,,,,.T.,CLR_BLACK,,200,20) //'Bem na Planta'

			nLineLeg += 15

		ElseIf __nModPG == 35
			oBmp := TBitmap():New(nLineLeg,11,0,0,"ng_ico_risco",,.T.,oTPanel,,,.F.,.F.,,,.F.,,.T.,,.F.)
				oBmp:lAutoSize := .T.

			TSay():New(nLineLeg+3,30,{|| STR0414},oTPanel,,,,,,.T.,CLR_BLACK,,200,20) //'Risco'

			nLineLeg += 15

			oBmp := TBitmap():New(nLineLeg,11,0,0,"ng_ico_ris_planta",,.T.,oTPanel,,,.F.,.F.,,,.F.,,.T.,,.F.)
				oBmp:lAutoSize := .T.

			TSay():New(nLineLeg+4,30,{|| STR0438},oTPanel,,,,,,.T.,CLR_BLACK,,200,20) //'Risco na Planta'

			nLineLeg += 15

		ElseIf __nModPG == 56

			TSay():New(nLineLeg+3,30,{|| STR0455},oTPanel,,,,,,.T.,CLR_BLACK,,200,20)
			oBmp := TBitmap():New(nLineLeg,11,0,0,"NG_ICO_RESIDUO",,.T.,oTPanel,,,.F.,.F.,,,.F.,,.T.,,.F.)
			oBmp:lAutoSize := .T.

			nLineLeg += 15

			TSay():New(nLineLeg+3,30,{|| STR0459},oTPanel,,,,,,.T.,CLR_BLACK,,200,20) //"Aspecto"
			oBmp := TBitmap():New(nLineLeg,11,0,0,"NG_ICO_ASPECTO",,.T.,oTPanel,,,.F.,.F.,,,.F.,,.T.,,.F.)
			oBmp:lAutoSize := .T.

			nLineLeg += 15

			TSay():New(nLineLeg+3,30,{|| STR0460},oTPanel,,,,,,.T.,CLR_BLACK,,200,20)
			oBmp := TBitmap():New(nLineLeg,11,0,0,"NG_ICO_PCOLETA",,.T.,oTPanel,,,.F.,.F.,,,.F.,,.T.,,.F.)
			oBmp:lAutoSize := .T.

			nLineLeg += 15

		EndIf

		oBmp := TBitmap():New(nLineLeg,10,0,0,'ico_planta_fecha',,.T.,oTPanel,,,.F.,.F.,,,.F.,,.T.,,.F.)
			oBmp:lAutoSize := .T.

		TSay():New(nLineLeg+4,30,{|| STR0380},oTPanel,,,,,,.T.,CLR_BLACK,,200,20) //'Planta Gráfica (Fechada)'

		nLineLeg += 15

		oBmp := TBitmap():New(nLineLeg,10,0,0,'ico_planta_abre',,.T.,oTPanel,,,.F.,.F.,,,.F.,,.T.,,.F.)
		oBmp:lAutoSize := .T.

		TSay():New(nLineLeg+4,30,{|| STR0381},oTPanel,,,,,,.T.,CLR_BLACK,,200,20) //'Planta Gráfica (Aberta)'

		nLineLeg += 15

		oBmp := TBitmap():New(nLineLeg,10,0,0,'ico_planta_local',,.T.,oTPanel,,,.F.,.F.,,,.F.,,.T.,,.F.)
		oBmp:lAutoSize := .T.

		TSay():New(nLineLeg+4,30,{|| STR0382},oTPanel,,,,,,.T.,CLR_BLACK,,200,20) //'Localização'

		nLineLeg += 15

		oBmp := TBitmap():New(nLineLeg,10,0,0,'ico_planta_ilustracao',,.T.,oTPanel,,,.F.,.F.,,,.F.,,.T.,,.F.)
		oBmp:lAutoSize := .T.

		TSay():New(nLineLeg+4,30,{|| STR0383},oTPanel,,,,,,.T.,CLR_BLACK,,200,20) //'Ilustração'

		nLineLeg += 15

		If __nModPG == 35
			oBmp := TBitmap():New(nLineLeg,11,0,0,"FOLDER14",,.T.,oTPanel,,,.F.,.F.,,,.F.,,.T.,,.F.)
				oBmp:lAutoSize := .T.

			TSay():New(nLineLeg+4,30,{|| STR0429},oTPanel,,,,,,.T.,CLR_BLACK,,200,20) //'Função'

			nLineLeg += 15

			oBmp := TBitmap():New(nLineLeg,11,0,0,"FOLDER12",,.T.,oTPanel,,,.F.,.F.,,,.F.,,.T.,,.F.)
				oBmp:lAutoSize := .T.

			TSay():New(nLineLeg+4,30,{|| STR0430},oTPanel,,,,,,.T.,CLR_BLACK,,200,20) //'Tarefa'
		EndIf

		If !::lEditMode
			TGroup():New(nPosGp2I,05,nPosGp2F,175,STR0384,oTPanel,CLR_BLACK,CLR_BLACK,.T.) //"Alertas"
			aEventos := ::GetArrEvents()
			For nX := 1 To Len(aAlertas)
				If aAlertas[nX][__aAlertas_Habili__]
					If !Empty(aAlertas[nX][__aAlertas_Tipo__])
						aEventos := ::GetArrEvents(aAlertas[nX][__aAlertas_Tipo__])
					Endif
					cEvento := aAlertas[nX][__aAlertas_Evento__]
					nPosEvento := aScan(aEventos,{|x| x[1] == cEvento})
					If nPosEvento > 0
						cEvento += " - " + aEventos[nPosEvento][2]
					EndIf

					oTPanel:addShape("id="+cValToChar(::SetId())+";type=4;start-angle=0;sweep-length=360"+;
											";left=30;top="+Str(nTop)+";width=20;height=20;gradient=2,40,40,70,-1,0.76,#"+aAlertas[nX][__aAlertas_ClrHex__]+;
											",1.0,#000000;pen-color=#000000;tooltip="+cEvento+";can-move=0;is-container=" + If(lReleaseB,'1','0') + ";can-mark=0;")

					oTPanel:addShape("id="+cValToChar(::SetId())+";type=7;left=60;top="+Str(nTop+3)+";width=250;height=30;"+;
										 "text="+cEvento+";tooltip="+cEvento+";font=Verdana,08,0,0,1;pen-color=#000000;pen-width=1;is-container=" + If(lReleaseB,'1','0') + ";")

					nTop += 35
				EndIf
			Next nX
		EndIf
	ACTIVATE DIALOG oDlg CENTERED

	//Restaura teclas de atalho
	RestKeys(aKeys,.T.)

	//Desabilita Panel preto transparente
	::SetBlackPnl(.F.)
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} ResizeAlert
Método que faz redimensionamento sobre um alerta

@param nPosShape Posição do shape na array aShape
@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Method ResizeAlert(nPosShape) Class TNGPG
	Local nId, nAlerta, nStartAngle, nSweepLength
	Local nQuant := 0
	Local cToolTip
	Local aAlertas := ::aShape[nPosShape][__aShape_Alertas__]

	//Posicao do alerta sobre a imagem (Centralizado)
	Local nLeft
	Local nTop

	For nAlerta := 1 To Len(aAlertas)
		If aAlertas[nAlerta][__aShape_aAlerta_Ativo__]
			nQuant++
		EndIf
	Next nAlerta

	nStartAngle  := 360
	nSweepLength := If(nQuant==5,90,360/nQuant)

	For nAlerta := 1 To Len(aAlertas)
		If aAlertas[nAlerta][__aShape_aAlerta_Ativo__]

			nId := aAlertas[nAlerta][__aShape_aAlerta_IdShape__]

			cToolTip := ""

			If aAlertas[nAlerta][__aShape_aAlerta_Blinker__]
				::oTPanel:DeleteBlinker(nId)
			EndIf
			::oTPanel:DeleteItem(nId)

			nLeft := ::aShape[nPosShape][__aShape_PosX__] + (::aShape[nPosShape][__aShape_Largura__]/2)-7
			nTop  := ::aShape[nPosShape][__aShape_PosY__] + (::aShape[nPosShape][__aShape_Altura__]/2)-7
			If nAlerta != Len(aAlertas) .Or. nQuant < 5
				::oTPanel:addShape("id="+Str(nId)+";type=4;start-angle="+Str(nStartAngle)+";sweep-length="+Str(nSweepLength)+;
										";left="+Str(nLeft)+";top="+Str(nTop)+;
										";width=15;height=15;gradient=2,7,7,8,-1,0.76,#"+aAlertas[nAlerta][__aShape_aAlerta_ClrHex__]+;
										",1.0,#000000;pen-color=#000000;tooltip="+cToolTip+";can-move=0;is-container=" + If(lReleaseB,'1','0') + ";can-mark=1;")
				nStartAngle  -= nSweepLength
			Else
				::oTPanel:addShape("id="+Str(nId)+";type=4;start-angle=0;sweep-length=360"+;
										";left="+Str(nLeft+3)+";top="+Str(nTop+3.5)+;
										";width=8;height=8;gradient=2,40,40,103,-1,0.76,#"+aAlertas[nAlerta][__aShape_aAlerta_ClrHex__]+;
										",1.0,#000000;pen-color=#000000;tooltip="+cToolTip+";can-move=0;is-container=" + If(lReleaseB,'1','0') + ";can-mark=1;")
			EndIf

			If !::aShape[nPosShape][__aShape_Visivel__] .Or. ::aShape[nPosShape][__aShape_PlanSup__] != ::cPlantaAtu .Or. ;
				!aAlertas[nAlerta][__aShape_aAlerta_Visible__]
				If aAlertas[nAlerta][__aShape_aAlerta_Blinker__]
					::oTPanel:DeleteBlinker(nId)
				EndIf
				::oTPanel:SetVisible(nId,.F.)
			Else
				If aAlertas[nAlerta][__aShape_aAlerta_Blinker__]
					::InsertBlinker(nId)
				EndIf
				::oTPanel:SetVisible(nId,.T.)
			EndIf

		EndIf
	Next nAlerta
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} Update
Método que faz a atualização de toda a planta Grafica

@author Vitor Emanuel Batista
@since 12/05/2010
@version MP10
@return Nil
@obs Atualiza somente em modo Edição
/*/
//---------------------------------------------------------------------
Method Update() Class TNGPG

	Local lMeter := Type("_oPgMeter") == "O" .And. Type("_oPgSay") == "O"
	Local nPosShape
	Local cFilOld

	//---------------------------------------------
	// Guarda bloco de codigo das telhas de atalho
	//---------------------------------------------
	Local aKeys := GetKeys()

	//--------------------------------------------------------
	// Limpa tecla de atalhos para nao poderem ser executados
	//--------------------------------------------------------
	RestKeys(Nil,.T.)

	If ValType(::oMenuLoc) == "O"
		::oMenuLoc:Hide()
	EndIf

	If ValType(::oMenuBem) == "O"
		::oMenuBem:Hide()
	EndIf

	If ValType(::oMenuRis) == "O"
		::oMenuRis:Hide()
	EndIf

	If ValType(::oMenuFun) == "O"
		::oMenuFun:Hide()
	EndIf

	If ValType(::oMenuTar) == "O"
		::oMenuTar:Hide()
	EndIf


	If !::lEditMode

		If lMeter
			_oPgSay:SetText(STR0101) //"Analisando e criando Alertas..."
			_oPgMeter:Set(++_nIncMeter)
			_oPgMeter:Refresh()
		EndIf

		//------------------------
		// Guarda filial corrente
		//------------------------
		cFilOld := cFilAnt

		For nPosShape := 1 To Len(::aShape)
			If ::aShape[nPosShape][__aShape_Permit__]
				cFilAnt := ::aShape[nPosShape][__aShape_Filial__]
				::UpdateAlert(nPosShape)
			EndIf
		Next nPosShape

		cFilAnt := cFilOld

	EndIf

	//------------------------------------------
	// Força a atualização da Tela (Temporario)
	//------------------------------------------
	cFilAnt := ""
	::SetOptionTree()

	//Restaura teclas de atalho
	RestKeys(aKeys,.T.)
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} UpdateAlert
Método que faz a atualização do alerta de um Shape em especifico

@param nPosShape Posição na array aShape
@author Vitor Emanuel Batista
@since 12/05/2010
@version MP10
@return Nil
@obs Atualiza somente em modo Edição
/*/
//---------------------------------------------------------------------
Method UpdateAlert(nPosShape) Class TNGPG

	Local nAlerta, nId
	Local nQuant := 0
	Local nStartAngle
	Local nSweepLength
	Local aAlertas
	Local cFilAtu

	//Posicao do alerta sobre a imagem (Centralizado)
	Local nLeft
	Local nTop

	Default nPosShape := ::GetPosShape(::GetShapeAtu())

	If nPosShape > 0

		If ::aShape[nPosShape][__aShape_IndCod__] != "0"

			If Len(::aShape[nPosShape][__aShape_Alertas__]) == 0
				cFilAtu  := ::aShape[nPosShape][__aShape_Filial__]
				aAlertas := ::GetArrAlerts('001'+cFilAtu)

				nQuant := 0

				For nAlerta := 1 To Len(aAlertas)
					If aAlertas[nAlerta][__aAlertas_Habili__]
						nQuant++
					EndIf
			   Next nAlerta

				::aShape[nPosShape][__aShape_Alertas__] := Array(Len(aAlertas),8)

				nStartAngle  := 360
				nSweepLength := If(nQuant==5,90,360/nQuant)

				For nAlerta := 1 To Len(aAlertas)
					If aAlertas[nAlerta][__aAlertas_Habili__] .And. ;
							(Empty(aAlertas[nAlerta][__aAlertas_Tipo__]) .Or. (::aShape[nPosShape][__aShape_IndCod__] == aAlertas[nAlerta][__aAlertas_Tipo__]))

						nId := ::SetId()
						::aShape[nPosShape][__aShape_Alertas__][nAlerta][__aShape_aAlerta_IdShape__] := nId
						::aShape[nPosShape][__aShape_Alertas__][nAlerta][__aShape_aAlerta_Evento__]  := aAlertas[nAlerta][__aAlertas_Evento__]
						::aShape[nPosShape][__aShape_Alertas__][nAlerta][__aShape_aAlerta_Funcao__]  := aAlertas[nAlerta][__aAlertas_Funcao__]
						::aShape[nPosShape][__aShape_Alertas__][nAlerta][__aShape_aAlerta_Ativo__]   := .T.
						::aShape[nPosShape][__aShape_Alertas__][nAlerta][__aShape_aAlerta_Visible__] := .F.
						::aShape[nPosShape][__aShape_Alertas__][nAlerta][__aShape_aAlerta_Blinker__] := aAlertas[nAlerta][__aAlertas_Blinker__]
						::aShape[nPosShape][__aShape_Alertas__][nAlerta][__aShape_aAlerta_ClrHex__]  := aAlertas[nAlerta][__aAlertas_ClrHex__]
						::aShape[nPosShape][__aShape_Alertas__][nAlerta][__aShape_aAlerta_Culpados__]:= {}

						cToolTip := ""
						nLeft := ::aShape[nPosShape][__aShape_PosX__] + (::aShape[nPosShape][__aShape_Largura__]/2)-7
						nTop  := ::aShape[nPosShape][__aShape_PosY__] + (::aShape[nPosShape][__aShape_Altura__]/2)-7

						If nAlerta != Len(aAlertas) .Or. nQuant < 5
							::oTPanel:addShape("id="+Str(nId)+";type=4;start-angle="+Str(nStartAngle)+";sweep-length="+Str(nSweepLength)+;
													";left="+Str(nLeft)+";top="+Str(nTop)+;
													";width=15;height=15;gradient=2,7,7,8,-1,0.76,#"+aAlertas[nAlerta][__aAlertas_ClrHex__]+;
													",1.0,#000000;pen-color=#000000;tooltip="+cToolTip+";can-move=0;is-container=" + If(lReleaseB,'1','0') + ";can-mark=1;")
							nStartAngle  -= nSweepLength
						Else
							::oTPanel:addShape("id="+Str(nId)+";type=4;start-angle=0;sweep-length=360"+;
													";left="+Str(nLeft+3)+";top="+Str(nTop+3.5)+;
													";width=8;height=8;gradient=2,40,40,103,-1,0.76,#"+aAlertas[nAlerta][__aAlertas_ClrHex__]+;
													",1.0,#000000;pen-color=#000000;tooltip="+cToolTip+";can-move=0;is-container=" + If(lReleaseB,'1','0') + ";can-mark=1;")
						EndIf

						//Inicializa Shape como invisivel
						::oTPanel:SetVisible(nId,.F.)

					Else
						::aShape[nPosShape][__aShape_Alertas__][nAlerta][__aShape_aAlerta_Ativo__]   := .F.
						::aShape[nPosShape][__aShape_Alertas__][nAlerta][__aShape_aAlerta_Visible__] := .F.
					EndIf
			   Next nAlerta

			EndIf

			::ExecuteEvent(nPosShape)
		EndIf

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} ExecuteEvent
Método que executa os eventos cadastrados para um shape

@param nPosShape Posição na array aShape
@author Vitor Emanuel Batista
@since 12/05/2010
@version MP10
@return Nil
@obs Atualiza somente em modo Edição
/*/
//---------------------------------------------------------------------
Method ExecuteEvent(nPosShape) Class TNGPG

	Local cQuery, cQryRisFun
	Local cEvento, cFuncao, cCargo, cNivSup
	Local nId,nY, nX, nPar, nAlerta
	Local lBlinker
	Local cTipoEvt
	Local bError
	Local aAtuAlerta
	Local cAliasQry  := GetNextAlias()
	Local lRet       := .F.
	Local lAtuDad    := .F.
	Local lUPDMDT69  := NGCADICBASE( "TN3_GENERI", "A", "TN3", .F. ) //Analisa se o UPDMDT69 foi aplicado
	Local lDepto     := NGCADICBASE('TAF_DEPTO','D','TAF',.F.)
	Local nNG2PVLA   := SuperGetMv("MV_NG2PVLA",.F.,"30")

	Default nPosShape := ::GetPosShape(::GetShapeAtu())

	aAtuAlerta := Array(Len(::aShape[nPosShape][__aShape_Alertas__]))

	For nAlerta := 1 To Len(::aShape[nPosShape][__aShape_Alertas__])
		If ::aShape[nPosShape][__aShape_Alertas__][nAlerta][__aShape_aAlerta_Ativo__]

			cTipoEvt := ::aShape[nPosShape][__aShape_IndCod__]
			cTipo   := If(cTipoEvt == "1","B","L")
			cCodigo := ::aShape[nPosShape][__aShape_Codigo__]
			cCargo  := Substr(::aShape[nPosShape][__aShape_Cargo__],1,3)
			cEvento := ::aShape[nPosShape][__aShape_Alertas__][nAlerta][__aShape_aAlerta_Evento__]
			cFuncao := ::aShape[nPosShape][__aShape_Alertas__][nAlerta][__aShape_aAlerta_Funcao__]
			nId     := ::aShape[nPosShape][__aShape_Alertas__][nAlerta][__aShape_aAlerta_IdShape__]
			lBlinker:= ::aShape[nPosShape][__aShape_Alertas__][nAlerta][__aShape_aAlerta_Blinker__]

			dbSelectArea("TAF")
			dbSetOrder(2)
			dbSeek(xFilial("TAF")+'001'+cCargo)

			If __nModPG == 19
				If cTipo == "B"
					dbSelectArea("ST9")
					dbSetOrder(1)
					dbSeek(xFilial("ST9")+cCodigo)
				EndIf

				If cEvento == "001" //O.S CORRETIVA
					cQuery := " SELECT COUNT(*) TOTAL FROM "+RetSqlName("STJ")
					cQuery += " WHERE TJ_FILIAL = '"+xFilial("STJ")+"' AND D_E_L_E_T_ <> '*' AND"
					cQuery += "       TJ_PLANO  = '000000'  AND TJ_TERMINO = 'N' AND (TJ_SITUACA = 'P' OR TJ_SITUACA = 'L') AND"
					cQuery += "       TJ_TIPOOS = "+ValToSql(cTipo)+" AND TJ_CODBEM = "+ValToSql(cCodigo)+" AND"
					cQuery += "       TJ_LUBRIFI <> 'S'"
				ElseIf cEvento == "002" //O.S CORRETIVA PENDENTE
					cQuery := " SELECT COUNT(*) TOTAL FROM "+RetSqlName("STJ")
					cQuery += " WHERE TJ_FILIAL = '"+xFilial("STJ")+"' AND D_E_L_E_T_ <> '*' AND"
					cQuery += "       TJ_PLANO  = '000000'  AND TJ_TERMINO = 'N' AND TJ_SITUACA = 'P' AND"
					cQuery += "       TJ_TIPOOS = "+ValToSql(cTipo)+" AND TJ_CODBEM = "+ValToSql(cCodigo)+" AND"
					cQuery += "       TJ_LUBRIFI <> 'S'"
				ElseIf cEvento == "003" //O.S CORRETIVA LIBERADA
					cQuery := " SELECT COUNT(*) TOTAL FROM "+RetSqlName("STJ")
					cQuery += " WHERE TJ_FILIAL = '"+xFilial("STJ")+"' AND D_E_L_E_T_ <> '*' AND"
					cQuery += "       TJ_PLANO  = '000000'  AND TJ_TERMINO = 'N' AND TJ_SITUACA = 'L' AND"
					cQuery += "       TJ_TIPOOS = "+ValToSql(cTipo)+" AND TJ_CODBEM = "+ValToSql(cCodigo)+" AND"
					cQuery += "       TJ_LUBRIFI <> 'S'"
				ElseIf cEvento == "004" //O.S CORRETIVA ATRASADA
					cQuery := " SELECT COUNT(*) TOTAL FROM "+RetSqlName("STJ")
					cQuery += " WHERE TJ_FILIAL = '"+xFilial("STJ")+"' AND D_E_L_E_T_ <> '*' AND"
					cQuery += "       TJ_PLANO  = '000000'  AND TJ_TERMINO = 'N' AND (TJ_SITUACA = 'P' OR TJ_SITUACA = 'L') AND"
					cQuery += "       TJ_DTMPFIM < "+ValToSql(dDataBase)+" AND"
					cQuery += "       TJ_TIPOOS = "+ValToSql(cTipo)+" AND TJ_CODBEM = "+ValToSql(cCodigo)+" AND"
					cQuery += "       TJ_LUBRIFI <> 'S'"
				ElseIf cEvento == "005" //O.S PREVENTIVA
					cQuery := " SELECT COUNT(*) TOTAL FROM "+RetSqlName("STJ")
					cQuery += " WHERE TJ_FILIAL = '"+xFilial("STJ")+"' AND D_E_L_E_T_ <> '*' AND"
					cQuery += "       TJ_PLANO  > '000000'  AND TJ_TERMINO = 'N' AND (TJ_SITUACA = 'P' OR TJ_SITUACA = 'L') AND"
					cQuery += "       TJ_TIPOOS = "+ValToSql(cTipo)+" AND TJ_CODBEM = "+ValToSql(cCodigo)+" AND"
					cQuery += "       TJ_LUBRIFI <> 'S'"
				ElseIf cEvento == "006" //O.S PREVENTIVA PENDENTE
					cQuery := " SELECT COUNT(*) TOTAL FROM "+RetSqlName("STJ")
					cQuery += " WHERE TJ_FILIAL = '"+xFilial("STJ")+"' AND D_E_L_E_T_ <> '*' AND"
					cQuery += "       TJ_PLANO  > '000000'  AND TJ_TERMINO = 'N' AND TJ_SITUACA = 'P' AND"
					cQuery += "       TJ_TIPOOS = "+ValToSql(cTipo)+" AND TJ_CODBEM = "+ValToSql(cCodigo)+" AND"
					cQuery += "       TJ_LUBRIFI <> 'S'"
				ElseIf cEvento == "007" //O.S PREVENTIVA LIBERADA
					cQuery := " SELECT COUNT(*) TOTAL FROM "+RetSqlName("STJ")
					cQuery += " WHERE TJ_FILIAL = '"+xFilial("STJ")+"' AND D_E_L_E_T_ <> '*' AND"
					cQuery += "       TJ_PLANO  > '000000'  AND TJ_TERMINO = 'N' AND TJ_SITUACA = 'L' AND"
					cQuery += "       TJ_TIPOOS = "+ValToSql(cTipo)+" AND TJ_CODBEM = "+ValToSql(cCodigo)+" AND"
					cQuery += "       TJ_LUBRIFI <> 'S'"
				ElseIf cEvento == "008" //O.S PREVENTIVA ATRASADA
					cQuery := " SELECT COUNT(*) TOTAL FROM "+RetSqlName("STJ")
					cQuery += " WHERE TJ_FILIAL  = '"+xFilial("STJ")+"' AND D_E_L_E_T_ <> '*' AND"
					cQuery += "       TJ_PLANO   > '000000'  AND TJ_TERMINO = 'N' AND (TJ_SITUACA = 'P' OR TJ_SITUACA = 'L') AND"
					cQuery += "       TJ_DTMPFIM < "+ValToSql(dDataBase)+" AND"
					cQuery += "       TJ_TIPOOS  = "+ValToSql(cTipo)+" AND TJ_CODBEM = "+ValToSql(cCodigo)+" AND"
					cQuery += "       TJ_LUBRIFI <> 'S'"
				ElseIf cEvento == "009" //SOLICITACAO DE SERVICO ABERTA
					cQuery := " SELECT COUNT(*) TOTAL FROM "+RetSqlName("TQB")
					cQuery += " WHERE TQB_FILIAL = '"+xFilial("TQB")+"' AND D_E_L_E_T_ <> '*' AND"
					cQuery += "       (TQB_SOLUCA = 'A' OR TQB_SOLUCA = 'D') AND"
					cQuery += "       TQB_TIPOSS = "+ValToSql(cTipo)+" AND TQB_CODBEM = "+ValToSql(cCodigo)
				ElseIf cEvento == "010" //S.S AGUARDANDO ANALISE
					cQuery := " SELECT COUNT(*) TOTAL FROM "+RetSqlName("TQB")
					cQuery += " WHERE TQB_FILIAL = '"+xFilial("TQB")+"' AND D_E_L_E_T_ <> '*' AND"
					cQuery += "       TQB_SOLUCA = 'A' AND"
					cQuery += "       TQB_TIPOSS = "+ValToSql(cTipo)+" AND TQB_CODBEM = "+ValToSql(cCodigo)
				ElseIf cEvento == "011" //S.S DISTRIBUIDA
					cQuery := " SELECT COUNT(*) TOTAL FROM "+RetSqlName("TQB")
					cQuery += " WHERE TQB_FILIAL = '"+xFilial("TQB")+"' AND D_E_L_E_T_ <> '*' AND"
					cQuery += "       TQB_SOLUCA = 'D' AND"
					cQuery += "       TQB_TIPOSS = "+ValToSql(cTipo)+" AND TQB_CODBEM = "+ValToSql(cCodigo)
				ElseIf cEvento == "012" //O.S GERADA PELA S.S
					cQuery := " SELECT COUNT(*) TOTAL FROM "+RetSqlName("TQB")+" TQB"
					cQuery += " INNER JOIN "+RetSqlName("TT7")+" TT7 ON TT7_FILIAL = '"+xFilial("TT7")+"' AND "
					cQuery += "         TT7_SOLICI = TQB_SOLICI AND TT7.D_E_L_E_T_ <> '*'"
					cQuery += " WHERE TQB_FILIAL = '"+xFilial("TQB")+"' AND TQB.D_E_L_E_T_ <> '*' AND"
					cQuery += "       (TQB_SOLUCA = 'A' OR TQB_SOLUCA = 'D') AND"
					cQuery += "       TQB_TIPOSS = "+ValToSql(cTipo)+" AND TQB_CODBEM = "+ValToSql(cCodigo)
				ElseIf cEvento == "013" //SS COM ATRASO CADASTRADO
					cQuery := " SELECT COUNT(*) TOTAL FROM "+RetSqlName("TQB")+" TQB"
					cQuery += " INNER JOIN "+RetSqlName("TT7")+" TT7 ON TT7_FILIAL = '"+xFilial("TT7")+"' AND "
					cQuery += "         TT7_SOLICI = TQB_SOLICI AND TT7.D_E_L_E_T_ <> '*'"
					cQuery += " INNER JOIN "+RetSqlName("TPL")+" TPL ON TPL_FILIAL = '"+xFilial("TPL")+"' AND "
					cQuery += "         TPL_ORDEM = TT7_ORDEM AND TPL.D_E_L_E_T_ <> '*'"
					cQuery += " WHERE TQB_FILIAL = '"+xFilial("TQB")+"' AND TQB.D_E_L_E_T_ <> '*' AND"
					cQuery += "       (TQB_SOLUCA = 'A' OR TQB_SOLUCA = 'D') AND"
					cQuery += "       TQB_TIPOSS = "+ValToSql(cTipo)+" AND TQB_CODBEM = "+ValToSql(cCodigo)
				ElseIf cEvento == "014" //S.S SEM RESPOSTA DE PESQUISA DE SATISFACAO
					cQuery := " SELECT COUNT(*) AS TOTAL FROM "+RetSqlName("TQB")+" TQB"
					If __TQ3PESQ
						cQuery += " JOIN "+RetSqlName("TQ3")+" TQ3 ON TQ3.TQ3_CDSERV = TQB.TQB_CDSERV"
					EndIf
					cQuery += " WHERE TQB_FILIAL = "+ValToSql(xFilial("TQB"))+" AND TQB.D_E_L_E_T_ <> '*' AND"
					If __TQ3PESQ
						cQuery += " TQ3_FILIAL = "+ValToSql(xFilial("TQ3"))+" AND TQ3.D_E_L_E_T_ <> '*' AND"
						cQuery += " TQ3.TQ3_PESQST = '1' AND "
					EndIf
					cQuery += "       TQB_SOLUCA = 'E' AND (TQB_PSAP = '' OR TQB_PSAN ='') AND"
					cQuery += "       TQB_TIPOSS = 'B' AND TQB_CODBEM = "+ValToSql(cCodigo)
				ElseIf cEvento == "015" //O.S. DE LUBRIFICACAO
					cQuery := " SELECT COUNT(*) TOTAL FROM "+RetSqlName("STJ")+" STJ"
					cQuery += " INNER JOIN "+RetSqlName("ST4")+" ST4 ON T4_SERVICO = TJ_SERVICO AND "
					cQuery += "       T4_LUBRIFI = 'S' AND ST4.D_E_L_E_T_ <> '*'
					cQuery += " WHERE TJ_FILIAL = '"+xFilial("STJ")+"' AND STJ.D_E_L_E_T_ <> '*' AND"
					cQuery += "       TJ_TERMINO = 'N' AND (TJ_SITUACA = 'P' OR TJ_SITUACA = 'L') AND"
					cQuery += "       TJ_TIPOOS = "+ValToSql(cTipo)+" AND TJ_CODBEM = "+ValToSql(cCodigo)
				ElseIf cEvento == "016" //O.S. DE LUBRIFICACAO ATRASADA
					cQuery := " SELECT COUNT(*) TOTAL FROM "+RetSqlName("STJ")+" STJ"
					cQuery += " INNER JOIN "+RetSqlName("ST4")+" ST4 ON T4_SERVICO = TJ_SERVICO AND "
					cQuery += "       T4_LUBRIFI = 'S' AND ST4.D_E_L_E_T_ <> '*'
					cQuery += " WHERE TJ_FILIAL = '"+xFilial("STJ")+"' AND STJ.D_E_L_E_T_ <> '*' AND"
					cQuery += "       TJ_TERMINO = 'N' AND (TJ_SITUACA = 'P' OR TJ_SITUACA = 'L') AND"
					cQuery += "       TJ_TIPOOS = "+ValToSql(cTipo)+" AND TJ_CODBEM = "+ValToSql(cCodigo)+" AND"
					cQuery += "       TJ_DTMPFIM < "+ValToSql(dDataBase)
				EndIf
			ElseIf __nModPG == 35
					//--------------------------------------------------------------------
					// cQryRisFun - String com a busca dos funcionarios expostos ao risco
					//--------------------------------------------------------------------
					cQryRisFun := " INNER JOIN "+RetSqlName("TN0")+" TN0 ON"

					cQryRisFun += "	 							( TN0.TN0_CODFUN = SRA.RA_CODFUNC OR LTRIM(RTRIM(TN0.TN0_CODFUN)) = '*' ) AND"
					cQryRisFun += " 							( TN0.TN0_CC = SRA.RA_CC OR LTRIM(RTRIM(TN0.TN0_CC)) = '*' ) AND"
					If lDepto
						cQryRisFun += " 							( TN0.TN0_DEPTO = SRA.RA_DEPTO OR LTRIM(RTRIM(TN0.TN0_DEPTO)) = '*' ) AND"
					EndIf
					cQryRisFun += " 							( TN0.TN0_CODTAR IN ( SELECT TN6.TN6_CODTAR FROM "+RetSqlName("TN6")+" TN6 WHERE "
					cQryRisFun += "																			TN6.TN6_MAT = SRA.RA_MAT AND"
					cQryRisFun += " 																			TN0.TN0_DTRECO >= TN6.TN6_DTINIC AND"
					cQryRisFun += " 																			( TN0.TN0_DTRECO <= TN6.TN6_DTTERM OR TN6.TN6_DTTERM = '' ) AND"
					cQryRisFun += " 																			TN6.TN6_FILIAL = "+ValToSql(xFilial("TN6"))+" AND"
					cQryRisFun += "																			TN6.D_E_L_E_T_ <> '*' )"
					cQryRisFun += " 							OR LTRIM(RTRIM(TN0.TN0_CODTAR)) = '*' ) AND"
					cQryRisFun += " 							TN0.TN0_DTELIM =  '' AND"
					cQryRisFun += " 							TN0.TN0_NUMRIS =  "+ValToSql(Alltrim(cCodigo))+" AND"
					cQryRisFun += " 							TN0.TN0_FILIAL =  "+ValToSql(xFilial("TN0"))+" AND"
					cQryRisFun += " 							TN0.D_E_L_E_T_ <> '*'"

				If cEvento == "001" //EPI NÃO ENTREGUE
					cQuery := " SELECT SUM(ALS.TOTAL) AS TOTAL FROM  ("
					//-- EPI's Obrigatorios Nao Entregues
					cQuery += " SELECT COUNT(DISTINCT(RA_MAT)) AS TOTAL FROM "+RetSqlName("SRA")+" SRA"
					// Busca os funcionarios expostos ao Risco
					cQuery += cQryRisFun
					// Verifica os EPI's obrigatorios necessarios para o risco
					cQuery += " INNER JOIN "+RetSqlName("TNX")+" TNX ON"
					cQuery += " 										TNX.TNX_NUMRIS = TN0.TN0_NUMRIS AND"
					cQuery += " 										TNX.D_E_L_E_T_ <> '*' AND"
					cQuery += " 										TNX.TNX_TIPO = '1' AND TNX.TNX_TIPO <> '' AND"
					cQuery += " 										TNX.TNX_FILIAL = "+ValToSql(xFilial("TNX"))+" AND"
					// Verifica a entrega do EPI para o funcionário.
					cQuery += " 										TNX.TNX_EPI NOT IN ( SELECT TNF.TNF_CODEPI FROM "+RetSqlName("TNF")+" TNF WHERE
					cQuery += "																		TNF.TNF_MAT = SRA.RA_MAT AND TNF.TNF_FILIAL = "+ValToSql(xFilial("TNF"))+" AND  TNF.D_E_L_E_T_ <> '*')"
					// Analisa o fornecedor deste EPI, onde não seja generico
					cQuery += " INNER JOIN "+RetSqlName("TN3")+" TN3 ON"
					cQuery += " 										TN3.TN3_CODEPI = TNX.TNX_EPI AND"
					cQuery += " 										TN3.TN3_FILIAL = " + ValToSql(xFilial("TN3")) + " AND"
					cQuery += " 										TN3.D_E_L_E_T_ <> '*' AND"
					cQuery += " 										TN3.TN3_GENERI =  '1'"
					cQuery += " WHERE SRA.RA_SITFOLH <> 'D' AND SRA.RA_FILIAL = "+ValToSql(xFilial("SRA"))+" AND SRA.D_E_L_E_T_ <> '*'"

					cQuery += " UNION"

					//-- EPI's Alternativos Nao Entregues
					cQuery += " SELECT COUNT(DISTINCT(TBL.MATRICULA)) AS TOTAL FROM ("
					cQuery += " SELECT COUNT(DISTINCT(SRA.RA_MAT)) AS MATRICULA FROM "+RetSqlName("SRA")+" SRA
					// Busca os funcionarios expostos ao Risco
					cQuery += cQryRisFun
					// Verifica os EPI's alternativos necessarios para o risco
					cQuery += " INNER JOIN "+RetSqlName("TNX")+" TNX ON"
					cQuery += " 										TNX.TNX_NUMRIS = TN0.TN0_NUMRIS AND"
					cQuery += "										TNX.TNX_FILIAL = "+ValToSql(xFilial("TNX"))+" AND"
					cQuery += " 										TNX.TNX_TIPO = '2' AND TNX.TNX_TIPO <> '' AND"
					cQuery += " 										TNX.D_E_L_E_T_ <> '*'"
					// Analisa o fornecedor deste EPI, onde não seja generico
					cQuery += " INNER JOIN "+RetSqlName("TN3")+" TN3 ON"
					cQuery += " 										TN3.TN3_CODEPI = TNX.TNX_EPI AND"
					cQuery += "										TN3.TN3_FILIAL = "+ValToSql(xFilial("TN3"))+" AND"
					cQuery += " 										TN3.TN3_GENERI =  '1' AND"
					cQuery += " 										TN3.D_E_L_E_T_ <> '*'"
					// Verifica a entrega do EPI para o funcionário.
					cQuery += " LEFT JOIN "+RetSqlName("TNF")+" TNF ON"
					cQuery += " 										TNF.TNF_MAT = SRA.RA_MAT AND"
					cQuery += " 										TNF.TNF_CODEPI = TNX.TNX_EPI AND"
					cQuery += "										TNF.TNF_FILIAL = "+ValToSql(xFilial("TNF"))+" AND"
					cQuery += "										TNF.TNF_FORNEC = TN3.TN3_FORNEC AND"
					cQuery += " 										TNF.TNF_LOJA = TN3.TN3_LOJA AND"
					cQuery += " 										TNF.D_E_L_E_T_ <> '*'"
					cQuery += " WHERE SRA.RA_SITFOLH <> 'D' AND SRA.RA_FILIAL = "+ValToSql(xFilial("SRA"))+" AND SRA.D_E_L_E_T_ <> '*'"
					cQuery += " GROUP BY SRA.RA_MAT,TNX.TNX_FAMIL"
					cQuery += " HAVING COUNT(DISTINCT(TNF.TNF_CODEPI)) = 0"
					cQuery += " ) AS TBL
					 //Contabiliza EPI Generico
					If NGCADICBASE("TN3_GENERI","D","TN3",.F.)
						cQuery += " UNION"
						//-- EPI's Alternativos Nao Entregues Genéricos
						cQuery += " SELECT COUNT(DISTINCT(TBL.MATRICULA)) AS TOTAL FROM (
						cQuery += " SELECT COUNT(DISTINCT(SRA.RA_MAT)) AS MATRICULA FROM "+RetSqlName("SRA")+" SRA
						// Busca os funcionarios expostos ao Risco
						cQuery += cQryRisFun
						// Verifica os EPI's obrigatorios necessarios para o risco
						cQuery += " INNER JOIN "+RetSqlName("TNX")+" TNX ON
						cQuery += " 						TNX.TNX_NUMRIS = TN0.TN0_NUMRIS AND
						cQuery += "						TNX.TNX_FILIAL = "+ValToSql(xFilial("TNX"))+" AND"
						cQuery += " 						TNX.TNX_TIPO = '1' AND TNX.TNX_TIPO <> '' AND"
						cQuery += " 						TNX.D_E_L_E_T_ <> '*'"
						// Analisa o fornecedor deste EPI, sendo eles genericos
						cQuery += " INNER JOIN "+RetSqlName("TN3")+" TN3 ON
						cQuery += " 						TN3.TN3_CODEPI = TNX.TNX_EPI AND
						cQuery += "						TN3.TN3_FILIAL = "+ValToSql(xFilial("TN3"))+" AND"
						cQuery += " 						TN3.TN3_GENERI =  '2' AND"
						cQuery += " 						TN3.D_E_L_E_T_ <> '*'"
						// Considera EPIs cadastrados como genericos, na TL0.
						cQuery += " INNER JOIN "+RetSqlName("TL0")+" TL0 ON
						cQuery += " 						TL0.TL0_EPIGEN = TNX.TNX_EPI AND
						cQuery += "						TL0.TL0_FILIAL = "+ValToSql(xFilial("TL0"))+" AND"
						cQuery += " 						TL0.D_E_L_E_T_ <> '*'
						// Verifica a entrega do EPI para o funcionário.
						cQuery += " LEFT JOIN "+RetSqlName("TNF")+" TNF ON
						cQuery += " 						TNF.TNF_MAT = SRA.RA_MAT AND
						cQuery += " 						TNF.TNF_CODEPI = TL0.TL0_EPIFIL AND
						cQuery += " 						TNF.TNF_FORNEC = TL0.TL0_FORNEC AND
						cQuery += " 						TNF.TNF_LOJA   = TL0.TL0_LOJA AND
						cQuery += "						TNF.TNF_FILIAL = "+ValToSql(xFilial("TNF"))+" AND"
						cQuery += " 						TNF.D_E_L_E_T_ <> '*'
						cQuery += " WHERE SRA.RA_SITFOLH <> 'D' AND SRA.RA_FILIAL = "+ValToSql(xFilial("SRA"))+" AND SRA.D_E_L_E_T_ <> '*'"
						cQuery += " GROUP BY SRA.RA_MAT,TL0.TL0_EPIGEN
						cQuery += " HAVING COUNT(DISTINCT(TNF.TNF_CODEPI)) = 0
						cQuery += " ) AS TBL
					EndIf
					cQuery += " ) AS ALS"
				ElseIf cEvento == "002" //EPI VENCIDO
					cQuery := " SELECT SUM(ALS.TOTAL) AS TOTAL FROM  ("
					//-- EPI's Obrigatorios Nao Entregues
					cQuery += " SELECT COUNT(DISTINCT(RA_MAT)) AS TOTAL FROM "+RetSqlName("SRA")+" SRA"
					// Busca os funcionarios expostos ao Risco
					cQuery += cQryRisFun
					// Verifica os EPI's obrigatorios necessarios para o risco
					cQuery += " INNER JOIN "+RetSqlName("TNX")+" TNX ON"
					cQuery += " 										TNX.TNX_NUMRIS = TN0.TN0_NUMRIS AND"
					cQuery += " 										TNX.D_E_L_E_T_ <> '*' AND TNX.TNX_TIPO <> '' AND"
					cQuery += " 										TNX.TNX_TIPO = '1' AND"
					cQuery += " 										TNX.TNX_FILIAL = "+ValToSql(xFilial("TNX"))+" AND"
					// Verifica a entrega do EPI para o funcionário.
					cQuery += " 										TNX.TNX_EPI IN ( SELECT TNF.TNF_CODEPI FROM "+RetSqlName("TNF")+" TNF"
					cQuery += "																	INNER JOIN " + RetSQLName("TN3") + " TN3 ON"
					cQuery += "																	TNF.TNF_CODEPI = TN3.TN3_CODEPI AND TNF.TNF_FORNEC = TN3.TN3_FORNEC AND"
					cQuery += " 																TNF.TNF_LOJA = TN3.TN3_LOJA AND TNF.TNF_DTENTR <= TN3.TN3_DTVENC AND"
					cQuery += "																	TN3.TN3_GENERI =  '1' AND TN3.TN3_DTVENC <> '' AND TN3.D_E_L_E_T_ <> '*'"
					cQuery += "																	WHERE TNF.TNF_MAT = SRA.RA_MAT AND TNF.TNF_FILIAL = "+ValToSql(xFilial("TNF"))+" AND  TNF.D_E_L_E_T_ <> '*')"
					cQuery += " WHERE SRA.RA_SITFOLH <> 'D' AND SRA.RA_FILIAL = "+ValToSql(xFilial("SRA"))+" AND SRA.D_E_L_E_T_ <> '*'"

					cQuery += " UNION"

					//-- EPI's Alternativos Nao Entregues
					cQuery += " SELECT COUNT(DISTINCT(TBL.MATRICULA)) AS TOTAL FROM ("
					// Busca os funcionarios expostos ao Risco
					cQuery += " SELECT COUNT(DISTINCT(SRA.RA_MAT)) AS MATRICULA FROM "+RetSqlName("SRA")+" SRA"
					cQuery += cQryRisFun
					// Verifica os EPI's alternativos necessarios para o risco
					cQuery += " INNER JOIN "+RetSqlName("TNX")+" TNX ON"
					cQuery += " 										TNX.TNX_NUMRIS = TN0.TN0_NUMRIS AND"
					cQuery += "										TNX.TNX_FILIAL = "+ValToSql(xFilial("TNX"))+" AND"
					cQuery += " 										TNX.TNX_TIPO = '2' AND TNX.TNX_TIPO <> '' AND"
					cQuery += " 										TNX.D_E_L_E_T_ <> '*'"
					// Analisa o fornecedor deste EPI, onde não seja generico
					cQuery += " INNER JOIN "+RetSqlName("TN3")+" TN3 ON"
					cQuery += " 										TN3.TN3_CODEPI = TNX.TNX_EPI AND"
					cQuery += "										TN3.TN3_FILIAL = "+ValToSql(xFilial("TN3"))+" AND"
					cQuery += " 										TN3.TN3_GENERI =  '1' AND"
					cQuery += " 										TN3.D_E_L_E_T_ <> '*'"
					// Verifica a entrega do EPI para o funcionário.
					cQuery += " LEFT JOIN "+RetSqlName("TNF")+" TNF ON"
					cQuery += " 										TNF.TNF_MAT = SRA.RA_MAT AND"
					cQuery += " 										TNF.TNF_CODEPI = TNX.TNX_EPI AND"
					cQuery += "										TNF.TNF_FILIAL = "+ValToSql(xFilial("TNF"))+" AND"
					cQuery += "										TNF.TNF_FORNEC = TN3.TN3_FORNEC AND"
					cQuery += " 										TNF.TNF_LOJA = TN3.TN3_LOJA AND"
					cQuery += "										TNF.TNF_DTENTR <= TN3.TN3_DTVENC AND "
					cQuery += " 										TN3.TN3_DTVENC <> '' AND TNF.D_E_L_E_T_ <> '*'"
					cQuery += " WHERE SRA.RA_SITFOLH <> 'D' AND SRA.RA_FILIAL = "+ValToSql(xFilial("SRA"))+" AND SRA.D_E_L_E_T_ <> '*'"
					cQuery += " GROUP BY SRA.RA_MAT,TNX.TNX_FAMIL"
					cQuery += " HAVING COUNT(DISTINCT(TNF.TNF_CODEPI)) = 0"
					cQuery += " ) AS TBL
					 //Contabiliza EPI Generico
					If NGCADICBASE("TN3_GENERI","D","TN3",.F.)
						cQuery += " UNION"
						//-- EPI's Alternativos Nao Entregues Genéricos
						cQuery += " SELECT COUNT(DISTINCT(TBL.MATRICULA)) AS TOTAL FROM (
						cQuery += " SELECT COUNT(DISTINCT(SRA.RA_MAT)) AS MATRICULA FROM "+RetSqlName("SRA")+" SRA
						// Busca os funcionarios expostos ao Risco
						cQuery += cQryRisFun
						// Verifica os EPI's obrigatorios necessarios para o risco
						cQuery += " INNER JOIN "+RetSqlName("TNX")+" TNX ON
						cQuery += " 						TNX.TNX_NUMRIS = TN0.TN0_NUMRIS AND
						cQuery += "						TNX.TNX_FILIAL = "+ValToSql(xFilial("TNX"))+" AND"
						cQuery += " 						TNX.TNX_TIPO = '1' AND TNX.TNX_TIPO <> '' AND"
						cQuery += " 						TNX.D_E_L_E_T_ <> '*'"
						// Analisa o fornecedor deste EPI, sendo eles genericos
						cQuery += " INNER JOIN "+RetSqlName("TN3")+" TN3 ON
						cQuery += " 						TN3.TN3_CODEPI = TNX.TNX_EPI AND
						cQuery += "						TN3.TN3_FILIAL = "+ValToSql(xFilial("TN3"))+" AND"
						cQuery += " 						TN3.TN3_GENERI =  '2' AND"
						cQuery += " 						TN3.D_E_L_E_T_ <> '*'"
						// Considera EPIs cadastrados como genericos, na TL0.
						cQuery += " INNER JOIN "+RetSqlName("TL0")+" TL0 ON
						cQuery += " 						TL0.TL0_EPIGEN = TNX.TNX_EPI AND
						cQuery += "						TL0.TL0_FILIAL = "+ValToSql(xFilial("TL0"))+" AND"
						cQuery += " 						TL0.D_E_L_E_T_ <> '*'
						// Verifica a entrega do EPI para o funcionário.
						cQuery += " LEFT JOIN "+RetSqlName("TNF")+" TNF ON
						cQuery += " 						TNF.TNF_MAT = SRA.RA_MAT AND
						cQuery += " 						TNF.TNF_CODEPI = TL0.TL0_EPIFIL AND
						cQuery += " 						TNF.TNF_FORNEC = TL0.TL0_FORNEC AND
						cQuery += " 						TNF.TNF_LOJA   = TL0.TL0_LOJA AND
						cQuery += "						TNF.TNF_FILIAL = "+ValToSql(xFilial("TNF"))+" AND"
						cQuery += "						TNF.TNF_DTENTR <= TN3.TN3_DTVENC AND "
						cQuery += " 						TN3.TN3_DTVENC <> '' AND TNF.D_E_L_E_T_ <> '*'"
						cQuery += " WHERE SRA.RA_SITFOLH <> 'D' AND SRA.RA_FILIAL = "+ValToSql(xFilial("SRA"))+" AND SRA.D_E_L_E_T_ <> '*'"
						cQuery += " GROUP BY SRA.RA_MAT,TL0.TL0_EPIGEN
						cQuery += " HAVING COUNT(DISTINCT(TNF.TNF_CODEPI)) = 0
						cQuery += " ) AS TBL
					EndIf
					cQuery += " ) AS ALS"
				ElseIf cEvento == "003" //EPI C.A. VENCIDO
					cQuery := " SELECT SUM(ALS.TOTAL) AS TOTAL FROM  ("
					//-- EPI's Obrigatorios Nao Entregues
					cQuery += " SELECT COUNT(DISTINCT(RA_MAT)) AS TOTAL FROM "+RetSqlName("SRA")+" SRA"
					// Busca os funcionarios expostos ao Risco
					cQuery += cQryRisFun
					// Verifica os EPI's obrigatorios necessarios para o risco
					cQuery += " INNER JOIN "+RetSqlName("TNX")+" TNX ON"
					cQuery += " 										TNX.TNX_NUMRIS = TN0.TN0_NUMRIS AND"
					cQuery += " 										TNX.D_E_L_E_T_ <> '*' AND"
					cQuery += " 										TNX.TNX_TIPO = '1' AND TNX.TNX_TIPO <> '' AND"
					cQuery += " 										TNX.TNX_FILIAL = "+ValToSql(xFilial("TNX"))+" AND"
					// Verifica a entrega do EPI para o funcionário.
					cQuery += " 										TNX.TNX_EPI IN ( SELECT TNF.TNF_CODEPI FROM "+RetSqlName("TNF")+" TNF"
					cQuery += "																		INNER JOIN " + RetSQLName("TN3") + " TN3 ON"
					cQuery += "																			TNF.TNF_CODEPI = TN3.TN3_CODEPI AND TNF.TNF_FORNEC = TN3.TN3_FORNEC AND"
					cQuery += " 																			TNF.TNF_LOJA = TN3.TN3_LOJA AND TNF.TNF_DTENTR > TN3.TN3_DTVENC AND"
					cQuery += "																			TN3.TN3_GENERI =  '1' AND TN3.TN3_DTVENC <> '' AND TN3.D_E_L_E_T_ <> '*'"
					cQuery += "																		WHERE TNF.TNF_MAT = SRA.RA_MAT AND TNF.TNF_FILIAL = "+ValToSql(xFilial("TNF"))+" AND  TNF.D_E_L_E_T_ <> '*')"
					cQuery += " WHERE SRA.RA_SITFOLH <> 'D' AND SRA.RA_FILIAL = "+ValToSql(xFilial("SRA"))+" AND SRA.D_E_L_E_T_ <> '*'"

					cQuery += " UNION"

					//-- EPI's Alternativos Nao Entregues
					cQuery += " SELECT COUNT(DISTINCT(TBL.MATRICULA)) AS TOTAL FROM ("
					// Busca os funcionarios expostos ao Risco
					cQuery += " SELECT COUNT(DISTINCT(SRA.RA_MAT)) AS MATRICULA FROM "+RetSqlName("SRA")+" SRA"
					cQuery += cQryRisFun
					// Verifica os EPI's alternativos necessarios para o risco
					cQuery += " INNER JOIN "+RetSqlName("TNX")+" TNX ON"
					cQuery += " 										TNX.TNX_NUMRIS = TN0.TN0_NUMRIS AND"
					cQuery += "										TNX.TNX_FILIAL = "+ValToSql(xFilial("TNX"))+" AND"
					cQuery += " 										TNX.TNX_TIPO = '2' AND TNX.TNX_TIPO <> '' AND"
					cQuery += " 										TNX.D_E_L_E_T_ <> '*'"
					// Analisa o fornecedor deste EPI, onde não seja generico
					cQuery += " INNER JOIN "+RetSqlName("TN3")+" TN3 ON"
					cQuery += " 										TN3.TN3_CODEPI = TNX.TNX_EPI AND"
					cQuery += "										TN3.TN3_FILIAL = "+ValToSql(xFilial("TN3"))+" AND"
					cQuery += " 										TN3.TN3_GENERI =  '1' AND"
					cQuery += " 										TN3.D_E_L_E_T_ <> '*'"
					// Verifica a entrega do EPI para o funcionário.
					cQuery += " LEFT JOIN "+RetSqlName("TNF")+" TNF ON"
					cQuery += " 										TNF.TNF_MAT = SRA.RA_MAT AND"
					cQuery += " 										TNF.TNF_CODEPI = TNX.TNX_EPI AND"
					cQuery += "										TNF.TNF_FILIAL = "+ValToSql(xFilial("TNF"))+" AND"
					cQuery += "										TNF.TNF_FORNEC = TN3.TN3_FORNEC AND"
					cQuery += " 										TNF.TNF_LOJA = TN3.TN3_LOJA AND"
					cQuery += "										TNF.TNF_DTENTR > TN3.TN3_DTVENC AND"
					cQuery += " 										TNF.D_E_L_E_T_ <> '*'"
					cQuery += " WHERE SRA.RA_SITFOLH <> 'D' AND SRA.RA_FILIAL = "+ValToSql(xFilial("SRA"))+" AND SRA.D_E_L_E_T_ <> '*'"
					cQuery += " GROUP BY SRA.RA_MAT,TNX.TNX_FAMIL"
					cQuery += " HAVING COUNT(DISTINCT(TNF.TNF_CODEPI)) = 0"
					cQuery += " ) AS TBL
					 //Contabiliza EPI Generico
					If NGCADICBASE("TN3_GENERI","D","TN3",.F.)
						cQuery += " UNION"
						//-- EPI's Alternativos Nao Entregues Genéricos
						cQuery += " SELECT COUNT(DISTINCT(TBL.MATRICULA)) AS TOTAL FROM (
						cQuery += " SELECT COUNT(DISTINCT(SRA.RA_MAT)) AS MATRICULA FROM "+RetSqlName("SRA")+" SRA
						// Busca os funcionarios expostos ao Risco
						cQuery += cQryRisFun
						// Verifica os EPI's obrigatorios necessarios para o risco
						cQuery += " INNER JOIN "+RetSqlName("TNX")+" TNX ON
						cQuery += " 						TNX.TNX_NUMRIS = TN0.TN0_NUMRIS AND
						cQuery += "						TNX.TNX_FILIAL = "+ValToSql(xFilial("TNX"))+" AND"
						cQuery += " 						TNX.TNX_TIPO = '1' AND TNX.TNX_TIPO <> '' AND"
						cQuery += " 						TNX.D_E_L_E_T_ <> '*'"
						// Analisa o fornecedor deste EPI, sendo eles genericos
						cQuery += " INNER JOIN "+RetSqlName("TN3")+" TN3 ON
						cQuery += " 						TN3.TN3_CODEPI = TNX.TNX_EPI AND
						cQuery += "						TN3.TN3_FILIAL = "+ValToSql(xFilial("TN3"))+" AND"
						cQuery += " 						TN3.TN3_GENERI =  '2' AND"
						cQuery += " 						TN3.D_E_L_E_T_ <> '*'"
						// Considera EPIs cadastrados como genericos, na TL0.
						cQuery += " INNER JOIN "+RetSqlName("TL0")+" TL0 ON"
						cQuery += " 						TL0.TL0_EPIGEN = TNX.TNX_EPI AND"
						cQuery += "						TL0.TL0_FILIAL = "+ValToSql(xFilial("TL0"))+" AND"
						cQuery += " 						TL0.D_E_L_E_T_ <> '*'"
						// Verifica a entrega do EPI para o funcionário.
						cQuery += " LEFT JOIN "+RetSqlName("TNF")+" TNF ON"
						cQuery += " 						TNF.TNF_MAT = SRA.RA_MAT AND"
						cQuery += " 						TNF.TNF_CODEPI = TL0.TL0_EPIFIL AND"
						cQuery += " 						TNF.TNF_FORNEC = TL0.TL0_FORNEC AND"
						cQuery += " 						TNF.TNF_LOJA   = TL0.TL0_LOJA AND"
						cQuery += "						TNF.TNF_FILIAL = "+ValToSql(xFilial("TNF"))+" AND"
						cQuery += "						TNF.TNF_DTENTR > TN3.TN3_DTVENC AND"
						cQuery += " 						TNF.D_E_L_E_T_ <> '*'
						cQuery += " WHERE SRA.RA_SITFOLH <> 'D' AND SRA.RA_FILIAL = "+ValToSql(xFilial("SRA"))+" AND SRA.D_E_L_E_T_ <> '*'"
						cQuery += " GROUP BY SRA.RA_MAT,TL0.TL0_EPIGEN
						cQuery += " HAVING COUNT(DISTINCT(TNF.TNF_CODEPI)) = 0
						cQuery += " ) AS TBL
					EndIf
					cQuery += " ) AS ALS"
				ElseIf cEvento == "004" //EXAMES VENCIDOS
					cQuery := " SELECT COUNT(DISTINCT(SRA.RA_MAT)) AS TOTAL FROM "+RetSqlName("SRA")+" SRA"
					// Busca os funcionarios expostos ao Risco
					cQuery += cQryRisFun
					cQuery += " INNER JOIN "+RetSqlName("TN2")+" TN2 ON TN2.TN2_NUMRIS = TN0.TN0_NUMRIS AND"
					cQuery += " 										TN2.TN2_FILIAL = "+ValToSql(xFilial("TN2"))+" AND"
					cQuery += " 										TN2.D_E_L_E_T_ <> '*'"
					cQuery += " INNER JOIN "+RetSqlName("TM5")+" TM5 ON TM5.TM5_EXAME = TN2.TN2_EXAME AND"
					cQuery += " 	 									TM5.TM5_MAT   = SRA.RA_MAT AND"
					cQuery += " 										TM5.TM5_FILIAL = "+ValToSql(xFilial("TM5"))+" AND"
					cQuery += " 										TM5.TM5_DTPROG < " + ValToSql(DTOS( dDataBase ))+" AND"
					cQuery += " 										TM5.TM5_DTPROG <> '' "
					cQuery += " WHERE SRA.RA_SITFOLH <> 'D' AND SRA.RA_FILIAL = "+ValToSql(xFilial("SRA"))+" AND SRA.D_E_L_E_T_ <> '*'"
				ElseIf cEvento == "005" //PLANO AÇÃO VENCIDOS
					cQuery := " SELECT COUNT(DISTINCT(SRA.RA_MAT)) AS TOTAL FROM "+RetSqlName("SRA")+" SRA"
					// Busca os funcionarios expostos ao Risco
					cQuery += cQryRisFun
					cQuery += " INNER JOIN " + RetSqlName("TNJ") + " TNJ ON TNJ.TNJ_NUMRIS = TN0.TN0_NUMRIS AND"
					cQuery += " 																	 TNJ.TNJ_FILIAL = "+ValToSql(xFilial("TNJ"))+" AND"
					cQuery += " 																	 TNJ.D_E_L_E_T_ <> '*'"
					cQuery += " INNER JOIN " + RetSQLName("TAA") + " TAA ON TAA.TAA_CODPLA = TNJ.TNJ_CODPLA AND"
					cQuery += " 																TAA.TAA_FILIAL = "+ValToSql( xFilial("TAA") )+" AND"
					cQuery += "																	TAA.TAA_DTFIPR < " + ValToSql(DTOS( dDataBase )) + " AND"
					cQuery += "																	TAA.TAA_DTFIPR <> '' AND TAA.D_E_L_E_T_ <> '*'"
					cQuery += " WHERE SRA.RA_SITFOLH <> 'D' AND SRA.RA_FILIAL = "+ValToSql(xFilial("SRA"))+" AND SRA.D_E_L_E_T_ <> '*'"
				ElseIf cEvento == "006" //LAUDO VENCIDO
					cQuery := " SELECT COUNT(DISTINCT(SRA.RA_MAT)) AS TOTAL FROM "+RetSqlName("SRA")+" SRA"
					// Busca os funcionarios expostos ao Risco
					cQuery += cQryRisFun
					cQuery += " INNER JOIN " + RetSqlName("TO1") + " TO1 ON TO1.TO1_NUMRIS = TN0.TN0_NUMRIS AND"
					cQuery += " 																	 TO1.TO1_FILIAL = "+ValToSql(xFilial("TO1"))+" AND"
					cQuery += " 																	 TO1.D_E_L_E_T_ <> '*'"
					cQuery += " INNER JOIN " + RetSqlName("TO0") + " TO0 ON TO0.TO0_LAUDO = TO1.TO1_LAUDO AND"
					cQuery += " 																	 TO0.TO0_FILIAL = "+ValToSql(xFilial("TO0"))+" AND"
					cQuery += "																	 TO0.TO0_DTVALI < "+ValToSql(DTOS( dDataBase ))+" AND TO0.TO0_DTVALI <> '' AND"
					cQuery += " 																	 TO0.D_E_L_E_T_ <> '*'"
					cQuery += " WHERE SRA.RA_SITFOLH <> 'D' AND SRA.RA_FILIAL = "+ValToSql(xFilial("SRA"))+" AND SRA.D_E_L_E_T_ <> '*'"
				ElseIf cEvento == "007" //LAUDO A VENCER
					nPrzLaudo := Val(nNG2PVLA)
					// Busca os funcionarios expostos ao Risco
					cQuery := " SELECT COUNT(DISTINCT(SRA.RA_MAT)) AS TOTAL FROM "+RetSqlName("SRA")+" SRA"
					cQuery += cQryRisFun
					cQuery += " INNER JOIN " + RetSqlName("TO1") + " TO1 ON TO1.TO1_NUMRIS = TN0.TN0_NUMRIS AND"
					cQuery += " 																	 TO1.TO1_FILIAL = "+ValToSql(xFilial("TO1"))+" AND"
					cQuery += " 																	 TO1.D_E_L_E_T_ <> '*'"
					cQuery += " INNER JOIN " + RetSqlName("TO0") + " TO0 ON TO0.TO0_LAUDO = TO1.TO1_LAUDO AND"
					cQuery += " 																	 TO0.TO0_FILIAL = "+ValToSql(xFilial("TO0"))+" AND"
					cQuery += "																	 	 TO0.TO0_DTVALI > "+ValToSql(DTOS( dDataBase ))+" AND"
					cQuery += " 																	 TO0.TO0_DTVALI <= "+ValToSql(DTOS(dDataBase + nPrzLaudo))+" AND TO0.TO0_DTVALI <> '' AND"
					cQuery += " 																	 TO0.D_E_L_E_T_ <> '*'"
					cQuery += " WHERE SRA.RA_SITFOLH <> 'D' AND SRA.RA_FILIAL = "+ValToSql(xFilial("SRA"))+" AND SRA.D_E_L_E_T_ <> '*'"
				EndIf
			ElseIf __nModPG == 56

				cNivSup := ::aShape[nPosShape][__aShape_NivSup__]

				If cTipoEvt == "A"
					If cEvento == "001" //Ocorrencias de resíduos pendentes
						cQuery := " SELECT COUNT(TB0_CODOCO) TOTAL FROM "+RetSqlName("TB0") + " TB0"
						cQuery += " INNER JOIN " + RetSqlName("TBJ") + " TBJ ON TBJ.TBJ_CODOCO = TB0.TB0_CODOCO AND"
						cQuery += " 																	 TBJ.TBJ_FILIAL = "+ValToSql(xFilial("TBJ"))+" AND"
						cQuery += " 																	 TBJ.TBJ_CODEST = '001' AND"
						cQuery += " 																	 TBJ.TBJ_CODNIV = "+ValToSql(cNivSup)+" AND"
						cQuery += " 																	 TBJ.D_E_L_E_T_ <> '*'"
						cQuery += " WHERE TB0.TB0_FILIAL = "+ValToSql(xFilial("TB0"))+" AND TB0.D_E_L_E_T_ <> '*' AND"
						cQuery += "       TB0.TB0_CODRES = "+ValToSql(cCodigo)+" AND"
						cQuery += "       TB0.TB0_QTDDES = 0"
					ElseIf cEvento == "002" // Ocorrências de resíduo em carga
						cQuery := " SELECT COUNT(TB0_CODOCO) TOTAL FROM "+RetSqlName("TB0") + " TB0"
						cQuery += " INNER JOIN " + RetSqlName("TBJ") + " TBJ ON TBJ.TBJ_CODOCO = TB0.TB0_CODOCO AND"
						cQuery += " 																	 TBJ.TBJ_FILIAL = "+ValToSql(xFilial("TBJ"))+" AND"
						cQuery += " 																	 TBJ.TBJ_CODEST = '001' AND"
						cQuery += " 																	 TBJ.TBJ_CODNIV = "+ValToSql(cNivSup)+" AND"
						cQuery += " 																	 TBJ.D_E_L_E_T_ <> '*'"
						cQuery += " WHERE TB0.TB0_FILIAL = "+ValToSql(xFilial("TB0"))+" AND TB0.D_E_L_E_T_ <> '*' AND"
						cQuery += "       TB0.TB0_CODRES = "+ValToSql(cCodigo)+" AND"
						cQuery += "       TB0.TB0_QTDRED < TB0.TB0_QTDDES"
					ElseIf cEvento == "003" // FMR em Ponto de Coleta
						cQuery := " SELECT COUNT(TDC_CODFMR) TOTAL FROM "+RetSqlName("TDC") + " TDC"
						cQuery += " WHERE TDC.TDC_FILIAL = "+ValToSql(xFilial("TDC"))+" AND TDC.D_E_L_E_T_ <> '*' AND"
						cQuery += "       TDC.TDC_CODRES = "+ValToSql(cCodigo)+" AND"
						cQuery += "       TDC.TDC_DEPTO  = "+ValToSql(cNivSup)+" AND"
						cQuery += "       TDC.TDC_STATUS = '1'"
					ElseIf cEvento == "004" // FMR em Area de Pesagem
						cQuery := " SELECT COUNT(TDC_CODFMR) TOTAL FROM "+RetSqlName("TDC") + " TDC"
						cQuery += " WHERE TDC.TDC_FILIAL = "+ValToSql(xFilial("TDC"))+" AND TDC.D_E_L_E_T_ <> '*' AND"
						cQuery += "       TDC.TDC_CODRES = "+ValToSql(cCodigo)+" AND"
						cQuery += "       TDC.TDC_DEPTO  = "+ValToSql(cNivSup)+" AND"
						cQuery += "       TDC.TDC_STATUS = '2'"
					ElseIf cEvento == "005" // FMR em Armazem
						cQuery := " SELECT COUNT(TDC_CODFMR) TOTAL FROM "+RetSqlName("TDC") + " TDC"
						cQuery += " WHERE TDC.TDC_FILIAL = "+ValToSql(xFilial("TDC"))+" AND TDC.D_E_L_E_T_ <> '*' AND"
						cQuery += "       TDC.TDC_CODRES = "+ValToSql(cCodigo)+" AND"
						cQuery += "       TDC.TDC_DEPTO  = "+ValToSql(cNivSup)+" AND"
						cQuery += "       TDC.TDC_STATUS = '3'"
					ElseIf cEvento == "006" // FMR Nao Conforme
						cQuery := " SELECT COUNT(TDC_CODFMR) TOTAL FROM "+RetSqlName("TDC") + " TDC"
						cQuery += " WHERE TDC.TDC_FILIAL = "+ValToSql(xFilial("TDC"))+" AND TDC.D_E_L_E_T_ <> '*' AND"
						cQuery += "       TDC.TDC_CODRES = "+ValToSql(cCodigo)+" AND"
						cQuery += "       TDC.TDC_DEPTO  = "+ValToSql(cNivSup)+" AND"
						cQuery += "       TDC.TDC_STATUS = '4'"
					ElseIf cEvento == "007" // FMR Reaberta
						cQuery := " SELECT COUNT(TDC_CODFMR) TOTAL FROM "+RetSqlName("TDC") + " TDC"
						cQuery += " WHERE TDC.TDC_FILIAL = "+ValToSql(xFilial("TDC"))+" AND TDC.D_E_L_E_T_ <> '*' AND"
						cQuery += "       TDC.TDC_CODRES = "+ValToSql(cCodigo)+" AND"
						cQuery += "       TDC.TDC_DEPTO  = "+ValToSql(cNivSup)+" AND"
						cQuery += "       TDC.TDC_STATUS = '6'"
					Endif
				ElseIf cTipoEvt == "B"
					If cEvento == "009" //Aspecto Sem Avaliação
						cQuery := " SELECT "
						cQuery += " CASE WHEN COUNT(TAB_ORDEM) > 0 THEN 0 ELSE 1 END AS TOTAL "
						cQuery += " FROM "+RetSqlName("TA4") + " TA4"
						cQuery += " INNER JOIN " + RetSqlName("TAB") + " TAB ON TAB.TAB_CODASP = TA4.TA4_CODASP AND "
						cQuery += " 																	 TAB.TAB_FILIAL = "+ValToSql(xFilial("TAB"))+" AND "
						cQuery += " 																	 TAB.TAB_CODEST = '001' AND "
						cQuery += " 																	 TAB.TAB_CODNIV = "+ValToSql(cNivSup)+" AND "
						cQuery += " 																	 TAB.D_E_L_E_T_ <> '*' "
						cQuery += " WHERE TA4.TA4_FILIAL = "+ValToSql(xFilial("TA4"))+" AND "
						cQuery += "       TA4.D_E_L_E_T_ <> '*' AND "
						cQuery += "       TA4.TA4_CODASP = "+ValToSql(cCodigo)
					ElseIf cEvento == "010" // Desempenhos Pendentes
						cQuery := " SELECT COUNT(TAB_ORDEM) TOTAL FROM "+RetSqlName("TAB") + " TAB"
						cQuery += " WHERE TAB.TAB_FILIAL = "+ValToSql(xFilial("TAB"))+" AND TAB.D_E_L_E_T_ <> '*' AND"
						cQuery += "       TAB.TAB_CODASP = "+ValToSql(cCodigo)+" AND"
						cQuery += "       TAB.TAB_CODEST = '001' AND"
						cQuery += "       TAB.TAB_CODNIV = "+ValToSql(cNivSup)+" AND"
						cQuery += "       TAB.TAB_SITUAC = '1'"
					Endif
				ElseIf cTipoEvt == "C"
					If cEvento == "012" // FMR em Ponto de Coleta
						cQuery := " SELECT COUNT(TDC_CODFMR) TOTAL FROM "+RetSqlName("TDC") + " TDC"
						cQuery += " WHERE TDC.TDC_FILIAL = "+ValToSql(xFilial("TDC"))+" AND TDC.D_E_L_E_T_ <> '*' AND"
						cQuery += "       TDC.TDC_CODPNT = "+ValToSql(cCodigo)+" AND"
						cQuery += "       TDC.TDC_DEPTO  = "+ValToSql(cNivSup)+" AND"
						cQuery += "       TDC.TDC_STATUS = '1'"
					ElseIf cEvento == "013" // FMR em Area de Pesagem
						cQuery := " SELECT COUNT(TDC_CODFMR) TOTAL FROM "+RetSqlName("TDC") + " TDC"
						cQuery += " WHERE TDC.TDC_FILIAL = "+ValToSql(xFilial("TDC"))+" AND TDC.D_E_L_E_T_ <> '*' AND"
						cQuery += "       TDC.TDC_CODPNT = "+ValToSql(cCodigo)+" AND"
						cQuery += "       TDC.TDC_DEPTO  = "+ValToSql(cNivSup)+" AND"
						cQuery += "       TDC.TDC_STATUS = '2'"
					ElseIf cEvento == "014" // FMR em Armazem
						cQuery := " SELECT COUNT(TDC_CODFMR) TOTAL FROM "+RetSqlName("TDC") + " TDC"
						cQuery += " WHERE TDC.TDC_FILIAL = "+ValToSql(xFilial("TDC"))+" AND TDC.D_E_L_E_T_ <> '*' AND"
						cQuery += "       TDC.TDC_CODPNT = "+ValToSql(cCodigo)+" AND"
						cQuery += "       TDC.TDC_DEPTO  = "+ValToSql(cNivSup)+" AND"
						cQuery += "       TDC.TDC_STATUS = '3'"
					ElseIf cEvento == "015" // FMR Nao Conforme
						cQuery := " SELECT COUNT(TDC_CODFMR) TOTAL FROM "+RetSqlName("TDC") + " TDC"
						cQuery += " WHERE TDC.TDC_FILIAL = "+ValToSql(xFilial("TDC"))+" AND TDC.D_E_L_E_T_ <> '*' AND"
						cQuery += "       TDC.TDC_CODPNT = "+ValToSql(cCodigo)+" AND"
						cQuery += "       TDC.TDC_DEPTO  = "+ValToSql(cNivSup)+" AND"
						cQuery += "       TDC.TDC_STATUS = '4'"
					ElseIf cEvento == "016" // FMR Reaberta
						cQuery := " SELECT COUNT(TDC_CODFMR) TOTAL FROM "+RetSqlName("TDC") + " TDC"
						cQuery += " WHERE TDC.TDC_FILIAL = "+ValToSql(xFilial("TDC"))+" AND TDC.D_E_L_E_T_ <> '*' AND"
						cQuery += "       TDC.TDC_CODPNT = "+ValToSql(cCodigo)+" AND"
						cQuery += "       TDC.TDC_DEPTO  = "+ValToSql(cNivSup)+" AND"
						cQuery += "       TDC.TDC_STATUS = '6'"
					Endif
				Endif
			EndIf

			If cEvento == "000"
				cQuery := ""
			EndIf

			bError := ErrorBlock( { |oError| MyError(oError)} )
			BEGIN SEQUENCE

				If !Empty(cFuncao)
					nPar := At('(',cFuncao)
					cFuncao := AllTrim(Upper(Substr(cFuncao,1,If(nPar==0,Len(cFuncao),nPar-1))))
					If !FindFunction(cFuncao)
						BREAK
					EndIf

					cConteudo := &(cFuncao+"()")

					If ValType(cConteudo) != "C"
						BREAK
					EndIf

					cQuery += cConteudo

				ElseIf cEvento == "000"
					//Alert("Evento "+cEvento+" está com função em branco.")
					BREAK
				EndIf

				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
			RECOVER
				lRet := .F.
			END SEQUENCE

			//Restaurando bloco de erro do sistema
			ErrorBlock( bError )

			If Select(cAliasQry) > 0
				lRet := (cAliasQry)->TOTAL > 0
				(cAliasQry)->(dbCloseArea())
			EndIf

			//Se o evento for True ou tiver culpados para este evento
			lRet := lRet .Or. Len(::aShape[nPosShape][__aShape_Alertas__][nAlerta][__aShape_aAlerta_Culpados__]) > 0

			//Adiciona na array posicao de estado anterior e atual
			aAtuAlerta[nAlerta] := {::aShape[nPosShape][__aShape_Alertas__][nAlerta][__aShape_aAlerta_Visible__] , lRet}

			If !lAtuDad
				lAtuDad := aAtuAlerta[nAlerta][1] != aAtuAlerta[nAlerta][2] //Se forem diferentes os estados, devera atualizar todas as Plantas
			EndIf

			::aShape[nPosShape][__aShape_Alertas__][nAlerta][__aShape_aAlerta_Visible__] := lRet

			If !lRet .Or. ::aShape[nPosShape][__aShape_PlanSup__] != ::cPlantaAtu .Or. !::aShape[nPosShape][__aShape_Visivel__]
				If lBlinker
					::oTPanel:DeleteBlinker(nId)
				EndIf
				::oTPanel:SetVisible(nId,.F.)
			Else
				If lBlinker
					::InsertBlinker(nId)
				EndIf
				::oTPanel:SetVisible(nId,.T.)
			EndIf
		EndIf
	Next nAlerta

	If lAtuDad
		dbSelectArea(::cTrbTree)
		dbSetOrder(2)
		dbSeek("001"+cCargo+cFilAnt)
		aAtuDad := {}
		If (::cTrbTree)->CODPRO != (::cTrbTree)->PGSUP
			aAdd(aAtuDad,(::cTrbTree)->PGSUP)
			While aTail(aAtuDad) != "001"
				If dbSeek("001"+aTail(aAtuDad)) .And. (::cTrbTree)->CODPRO != (::cTrbTree)->PGSUP
					aAdd(aAtuDad,(::cTrbTree)->PGSUP)
				Else
					Exit
				EndIf
			EndDo
		EndIf

		For nX := 1 To Len(aAtuDad)
			nPosShape := aScan(::aShape,{|aShape| Substr(aShape[__aShape_Cargo__],1,3) == AllTrim(aAtuDad[nX]) .And. aShape[__aShape_Filial__] == cFilAnt})
			If nPosShape > 0
				For nY := 1 To Len(aAtuAlerta)
					If ValType(aAtuAlerta) == "A" .And. ::aShape[nPosShape][__aShape_Alertas__][nY][__aShape_aAlerta_Ativo__]
						nId      := ::aShape[nPosShape][__aShape_Alertas__][nY][__aShape_aAlerta_IdShape__]
						lBlinker := ::aShape[nPosShape][__aShape_Alertas__][nY][__aShape_aAlerta_Blinker__]
						lVisible := ::aShape[nPosShape][__aShape_Alertas__][nY][__aShape_aAlerta_Visible__]
						nPos := aScan(::aShape[nPosShape][__aShape_Alertas__][nY][__aShape_aAlerta_Culpados__],{|x| x == cCargo})
						If nPos == 0
							If aAtuAlerta[nY][1] != aAtuAlerta[nY][2] .And. aAtuAlerta[nY][2]
								aAdd(::aShape[nPosShape][__aShape_Alertas__][nY][__aShape_aAlerta_Culpados__],cCargo)
								lVisible := .T.
							EndIf
						Else
							If aAtuAlerta[nY][1] != aAtuAlerta[nY][2] .And. !aAtuAlerta[nY][2]
								aDel( ::aShape[nPosShape][__aShape_Alertas__][nY][__aShape_aAlerta_Culpados__], nPos )
								aSize( ::aShape[nPosShape][__aShape_Alertas__][nY][__aShape_aAlerta_Culpados__], Len( ::aShape[nPosShape][__aShape_Alertas__][nY][__aShape_aAlerta_Culpados__] ) - 1 )
								If Len(::aShape[nPosShape][__aShape_Alertas__][nY][__aShape_aAlerta_Culpados__]) == 0
									lVisible := .F.
								EndIf
							ElseIf aAtuAlerta[nY][1] != aAtuAlerta[nY][2] .And. aAtuAlerta[nY][2]
								aAdd(::aShape[nPosShape][__aShape_Alertas__][nY][__aShape_aAlerta_Culpados__],cCargo)
								lVisible := .T.
							EndIf
						EndIf
						::aShape[nPosShape][__aShape_Alertas__][nY][__aShape_aAlerta_Visible__] := lVisible

						If ::cPlantaAtu == ::aShape[nPosShape][__aShape_PlanSup__]
							If !lVisible
								If lBlinker
									::oTPanel:DeleteBlinker(nId)
								EndIf
								::oTPanel:SetVisible(nId,.F.)
							Else
								If lBlinker
									::InsertBlinker(nId)
								EndIf
								::oTPanel:SetVisible(nId,.T.)
							EndIf
						EndIf
					EndIf
				Next nY
			EndIf
		Next nX

	EndIf

Return

Static Function MyError(oError)
	BREAK
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} InsertLibrary
Carga automatica das Bibliotecas e imagens padroes

@author Vitor Emanuel Batista
@since 11/05/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Method InsertLibrary() Class TNGPG
	Local nX, nY
	Local nTamCpo := Len( TU0->TU0_OPCAO )
	Local cCodNR  := PADR( "NR09", nTamCpo )
	Local cCodSGA := PADR( "SGA", nTamCpo, "0" )
	Local cQry, cAlsImg
	Local aGrupo := {	{"000001",STR0108,"1","1"},; //"Mobília"
								{"000002",STR0109,"1","1"},; //"Equip. Industrial"
								{"000003",STR0110,"1","1"},; //"Equip. Escritório"
								{"000004",STR0111,"1","1"}} //"Sanitário"

	Local aPng := {}

	aAdd(aPng,{"000001","1","NG_PG_ARQUIVO_01.PNG",STR0112,STR0113,"1","1"}) //"Arq. 01"###"Arquivo"
	aAdd(aPng,{"000001","1","NG_PG_ARQUIVO_02.PNG",STR0114,STR0113,"1","1"}) //"Arq. 02"
	aAdd(aPng,{"000001","1","NG_PG_ARQUIVO_03.PNG",STR0115,STR0113,"1","1"}) //"Arq. 03"
	aAdd(aPng,{"000001","1","NG_PG_ARQUIVO_04.PNG",STR0116,STR0113,"1","1"}) //"Arq. 04"
	aAdd(aPng,{"000001","1","NG_PG_BAIADUPLA_01.PNG",STR0117,STR0118,"1","1"}) //"Baia Dup."###"Baia Dupla"
	aAdd(aPng,{"000001","1","NG_PG_BAIADUPLA_02.PNG",STR0119,STR0120,"1","1"}) //"Baia Dup. Meio"###"Baia Dupla Meio"
	aAdd(aPng,{"000001","1","NG_PG_BANQUETA_01.PNG",STR0121,"Banqueta - Direita","1","1"}) //"Banq. Dir."
	aAdd(aPng,{"000001","1","NG_PG_BANQUETA_02.PNG",STR0123,STR0124,"1","1"}) //###"Banq. Bai."###"Banqueta - Baixo"
	aAdd(aPng,{"000001","1","NG_PG_BANQUETA_03.PNG",STR0125,STR0126,"1","1"}) //"Banq. Esq."###"Banqueta - Esquerda"
	aAdd(aPng,{"000001","1","NG_PG_BANQUETA_04.PNG",STR0127,STR0128,"1","1"}) //"Banq. Cim."###"Banqueta - Cima"
	aAdd(aPng,{"000001","1","NG_PG_BANCO.PNG",STR0129,STR0130,"1","1"}) //"Banq. Red."###"Banqueta Redonda"
	aAdd(aPng,{"000001","1","NG_PG_BAIADUPLA_03.PNG",STR0131,STR0118,"1","1"}) //"Baia Dupla 03"###"Baia Dupla"
	aAdd(aPng,{"000001","1","NG_PG_BAIADUPLA_04.PNG",STR0132,STR0118,"1","1"}) //"Baia Dupla 04"###"Baia Dupla"
	aAdd(aPng,{"000001","1","NG_PG_CADEIRA_01.PNG",STR0133,STR0134,"1","1"}) //"Cadeira 01"###"Cadeira"
	aAdd(aPng,{"000001","1","NG_PG_CADEIRA_02.PNG",STR0135,STR0134,"1","1"}) //"Cadeira 02"
	aAdd(aPng,{"000001","1","NG_PG_CADEIRA_03.PNG",STR0136,STR0134,"1","1"}) //"Cadeira 03"
	aAdd(aPng,{"000001","1","NG_PG_CADEIRA_04.PNG",STR0137,STR0134,"1","1"}) //"Cadeira 04"
	aAdd(aPng,{"000001","1","NG_PG_CONJUNTO_01.PNG",STR0138,STR0139,"1","1"}) //"Conjunto 01"###"Conjunto"
	aAdd(aPng,{"000001","1","NG_PG_CONJUNTO_02.PNG",STR0140,STR0139,"1","1"}) //"Conjunto 02"
	aAdd(aPng,{"000001","1","NG_PG_CONJUNTO_03.PNG",STR0141,STR0139,"1","1"}) //"Conjunto 03"
	aAdd(aPng,{"000001","1","NG_PG_CONJUNTO_04.PNG",STR0142,STR0139,"1","1"}) //"Conjunto 04"
	aAdd(aPng,{"000001","1","NG_PG_ESTANTE_01.PNG",STR0143,STR0144,"1","1"}) //"Estante 01"###"Estante"
	aAdd(aPng,{"000001","1","NG_PG_ESTANTE_02.PNG",STR0145,STR0144,"1","1"}) //"Estante 02"
	aAdd(aPng,{"000001","1","NG_PG_ESTANTE_03.PNG",STR0146,STR0144,"1","1"}) //"Estante 03"
	aAdd(aPng,{"000001","1","NG_PG_ESTANTE_04.PNG",STR0147,STR0144,"1","1"}) //"Estante 04"
	aAdd(aPng,{"000001","1","NG_PG_MESAGRANDE_01.PNG",STR0148,STR0149,"1","1"}) //"Mesa Grande 01"###"Mesa Grande"
	aAdd(aPng,{"000001","1","NG_PG_MESAGRANDE_02.PNG",STR0150,STR0149,"1","1"}) //"Mesa Grande 02"
	aAdd(aPng,{"000001","1","NG_PG_MESAMEDIA_01.PNG",STR0151,STR0152,"1","1"}) //"Mesa Media 01"###"Mesa Media"
	aAdd(aPng,{"000001","1","NG_PG_MESAMEDIA_02.PNG",STR0153,STR0152,"1","1"}) //"Mesa Media 02"
	aAdd(aPng,{"000001","1","NG_PG_MESAPEQUENA_01.PNG",STR0154,STR0155,"1","1"}) //"Mesa Pequena 01"###"Mesa Pequna"
	aAdd(aPng,{"000001","1","NG_PG_MESAPEQUENA_02.PNG",STR0156,STR0155,"1","1"}) //"Mesa Pequena 02"
	aAdd(aPng,{"000001","1","NG_PG_CADEIRAGIRO_01.PNG",STR0157,STR0158,"1","1"}) //"Cadeira Giro.01"###"Cadeira Giratoria"
	aAdd(aPng,{"000001","1","NG_PG_CADEIRAGIRO_02.PNG",STR0159,STR0158,"1","1"}) //"Cadeira Giro.02"
	aAdd(aPng,{"000001","1","NG_PG_CADEIRAGIRO_03.PNG",STR0160,STR0158,"1","1"}) //"Cadeira Giro.03"
	aAdd(aPng,{"000001","1","NG_PG_CADEIRAGIRO_04.PNG",STR0161,STR0158,"1","1"}) //"Cadeira Giro.04"
	aAdd(aPng,{"000001","1","NG_PG_CANTOGRANDE_01.PNG",STR0162,STR0163,"1","1"}) //"Mesa Canto G.01"###"Mesa de canto Redondo Grande"
	aAdd(aPng,{"000001","1","NG_PG_CANTOGRANDE_02.PNG",STR0164,STR0163,"1","1"}) //"Mesa Canto G.02"
	aAdd(aPng,{"000001","1","NG_PG_CANTOGRANDE_03.PNG",STR0165,STR0163,"1","1"}) //"Mesa Canto G.03"
	aAdd(aPng,{"000001","1","NG_PG_CANTOGRANDE_04.PNG",STR0166,STR0163,"1","1"}) //"Mesa Canto G.04"
	aAdd(aPng,{"000001","1","NG_PG_CANTOPEQUENO_01.PNG",STR0167,STR0168,"1","1"}) //"Mesa Canto P.01"###"Mesa de canto Redondo Pequeno"
	aAdd(aPng,{"000001","1","NG_PG_CANTOPEQUENO_02.PNG",STR0169,STR0168,"1","1"}) //"Mesa Canto P.02"
	aAdd(aPng,{"000001","1","NG_PG_CANTOPEQUENO_03.PNG",STR0170,STR0168,"1","1"}) //"Mesa Canto P.03"
	aAdd(aPng,{"000001","1","NG_PG_CANTOPEQUENO_04.PNG",STR0350,STR0168,"1","1"}) //"Mesa Canto P.04"
	aAdd(aPng,{"000001","1","NG_PG_MESAOVAL_01.PNG",STR0171,STR0172,"1","1"}) //"Mesa Oval 01"###"Mesa Oval"
	aAdd(aPng,{"000001","1","NG_PG_MESAOVAL_02.PNG",STR0173,STR0172,"1","1"}) //"Mesa Oval 02"
	aAdd(aPng,{"000001","1","NG_PG_MESAOVAL_03.PNG",STR0174,STR0172,"1","1"}) //"Mesa Oval 03"
	aAdd(aPng,{"000001","1","NG_PG_MESAOVAL_04.PNG",STR0175,STR0172,"1","1"}) //"Mesa Oval 04"
	aAdd(aPng,{"000001","1","NG_PG_MESAQUADRADA.PNG",STR0176,STR0172,"1","1"}) //"Mesa Quadrada"
	aAdd(aPng,{"000001","1","NG_PG_MESAREDONDA.PNG",STR0177,STR0177,"1","1"}) //"Mesa Redonda"
	aAdd(aPng,{"000001","1","NG_PG_SOFADUPLO_01.PNG",STR0178,STR0179,"1","1"}) //"Sofa Dup. Dir."###"Sofa Duplo"
	aAdd(aPng,{"000001","1","NG_PG_SOFADUPLO_02.PNG",STR0180,STR0179,"1","1"}) //"Sofa Dup. Bai."
	aAdd(aPng,{"000001","1","NG_PG_SOFADUPLO_03.PNG",STR0181,STR0179,"1","1"}) //"Sofa Dup. Esq."
	aAdd(aPng,{"000001","1","NG_PG_SOFADUPLO_04.PNG",STR0182,STR0179,"1","1"}) //"Sofa Dup. Cim."
	aAdd(aPng,{"000001","1","NG_PG_SOFATRIPLO_01.PNG",STR0183,STR0184,"1","1"}) //"Sofa Trip. Esq."###"Sofa Triplo"
	aAdd(aPng,{"000001","1","NG_PG_SOFATRIPLO_02.PNG",STR0185,STR0184,"1","1"}) //"Sofa Trip. Cim."
	aAdd(aPng,{"000001","1","NG_PG_SOFATRIPLO_03.PNG",STR0186,STR0184,"1","1"}) //"Sofa Trip. Dir."
	aAdd(aPng,{"000001","1","NG_PG_SOFATRIPLO_04.PNG",STR0187,STR0184,"1","1"}) //"Sofa Trip. Bai."
	aAdd(aPng,{"000001","1","NG_PG_MESACANTO_01.PNG",STR0188,STR0189,"1","1"}) //"Sup. Canto 01"###"Superficie de Canto"
	aAdd(aPng,{"000001","1","NG_PG_MESACANTO_02.PNG",STR0190,STR0189,"1","1"}) //"Sup. Canto 02"
	aAdd(aPng,{"000001","1","NG_PG_MESACANTO_03.PNG",STR0191,STR0189,"1","1"}) //"Sup. Canto 03"
	aAdd(aPng,{"000001","1","NG_PG_MESACANTO_04.PNG",STR0192,STR0189,"1","1"}) //"Sup. Canto 04"
	aAdd(aPng,{"000002","1","NG_PG_BANCADA_IND_01.PNG",STR0193,STR0194,"1","1"}) //"Banca Trab."###"Banca de Trabalho"
	aAdd(aPng,{"000002","1","NG_PG_BANCADA_IND_02.PNG",STR0195,STR0194,"1","1"}) //"Bancada 02"
	aAdd(aPng,{"000002","1","NG_PG_CXFERRAMENTA_01.PNG",STR0196,STR0197,"1","1"}) //"Caixa Ferram."###"Caixa de Ferramentas"
	aAdd(aPng,{"000002","1","NG_PG_CXFERRAMENTA_02.PNG",STR0198,STR0197,"1","1"}) //"Cx. Ferramenta"
	aAdd(aPng,{"000002","1","NG_PG_PLATAFORMA_01.PNG",STR0199,STR0200,"1","1"}) //"Carrinho Plata."###"Carrinho de Plataforma"
	aAdd(aPng,{"000002","1","NG_PG_PLATAFORMA_02.PNG",STR0201,STR0202,"1","1"}) //"Plataforma 02"###"Plataforma"
	aAdd(aPng,{"000002","1","NG_PG_COMPRESSOR_01.PNG",STR0203,STR0203,"1","1"}) //"Compressor"
	aAdd(aPng,{"000002","1","NG_PG_COMPRESSOR_02.PNG",STR0204,STR0203,"1","1"}) //"Compressor 02"
	aAdd(aPng,{"000002","1","NG_PG_FURADEIRA_01.PNG",STR0205,STR0206,"1","1"}) //"Furadeira Banc."###"Furadeira de Bancada"
	aAdd(aPng,{"000002","1","NG_PG_FURADEIRA_02.PNG",STR0207,STR0208,"1","1"}) //"Furadeira 02"###"Furadeira"
	aAdd(aPng,{"000002","1","NG_PG_FRESA_HORIZ_01.PNG",STR0209,STR0210,"1","1"}) //"Fresadora Hori."###"Fresador Horizontal"
	aAdd(aPng,{"000002","1","NG_PG_FRESA_HORIZ_02.PNG",STR0211,STR0210,"1","1"}) //"Fresa Hori 02"
	aAdd(aPng,{"000002","1","NG_PG_FRESA_REVOLV_01.PNG",STR0212,STR0213,"1","1"}) //"Fresadora Revo."###"Fresadora Revolver"
	aAdd(aPng,{"000002","1","NG_PG_FRESA_REVOLV_02.PNG",STR0214,STR0213,"1","1"}) //"Fresa revolv 02"
	aAdd(aPng,{"000002","1","NG_PG_FRESA_VERTIC_01.PNG",STR0215,STR0216,"1","1"}) //"Fresadora Vert."###"Fresadora Vertical"
	aAdd(aPng,{"000002","1","NG_PG_FRESA_VERTIC_02.PNG",STR0217,STR0218,"1","1"}) //"Fresa Vertic.02"###"Fresa Vertical"
	aAdd(aPng,{"000002","1","NG_PG_GERADOR_01.PNG",STR0219,STR0220,"1","1"}) //"Gerador 01"###"Gerador"
	aAdd(aPng,{"000002","1","NG_PG_GERADOR_02.PNG",STR0221,STR0220,"1","1"}) //"Gerdador 02"
	aAdd(aPng,{"000002","1","NG_PG_MAQ_CORTE_01.PNG",STR0222,STR0223,"1","1"}) //"Maquina Cort."###"Maquina de Cortar"
	aAdd(aPng,{"000002","1","NG_PG_MAQ_CORTE_02.PNG",STR0224,STR0225,"1","1"}) //"Maq. Corte 02"###"Maquina de Corte"
	aAdd(aPng,{"000002","1","NG_PG_MAQ_SERRAR_01.PNG",STR0226,STR0227,"1","1"}) //"Maquina Serr."###"Maquina de Serrar"
	aAdd(aPng,{"000002","1","NG_PG_MAQ_SERRAR_02.PNG",STR0228,STR0227,"1","1"}) //"Maq. Serrar 02"###"Maquina de Serrar"
	aAdd(aPng,{"000002","1","NG_PG_MAQ_DOBRA_01.PNG",STR0229,STR0230,"1","1"}) //"Maquina Dobr."###"Maquina Dobradeira"
	aAdd(aPng,{"000002","1","NG_PG_MAQ_DOBRA_02.PNG",STR0231,STR0232,"1","1"}) //"Maq. Dobra 02"###"Maquina de Dobra"
	aAdd(aPng,{"000002","1","NG_PG_MAQ_FURAR_01.PNG",STR0233,STR0234,"1","1"}) //"Maquina Fura."###"Maquina Furadeira"
	aAdd(aPng,{"000002","1","NG_PG_MAQ_FURAR_02.PNG",STR0235,STR0236,"1","1"}) //"Maq. Furar 02"###"Maquina de Furar"
	aAdd(aPng,{"000002","1","NG_PG_MAQ_LIMAR_01.PNG",STR0237,STR0238,"1","1"}) //"Maquina Lima."###"Maquina Limadora"
	aAdd(aPng,{"000002","1","NG_PG_MAQ_LIMAR_02.PNG",STR0239,STR0240,"1","1"}) //"Maq. Limar 02"###"Maquina de Limar"
	aAdd(aPng,{"000002","1","NG_PG_PRELOMANUAL_01.PNG",STR0241,STR0241,"1","1"}) //"Prelo Manual"
	aAdd(aPng,{"000002","1","NG_PG_PRELOMANUAL_02.PNG",STR0241,STR0241,"1","1"}) //"Prelo Manual"
	aAdd(aPng,{"000002","1","NG_PG_RETIFICA_SUP_01.PNG",STR0242,STR0243,"1","1"}) //"Retifi. Superf."###"Retificador de Superficie"
	aAdd(aPng,{"000002","1","NG_PG_SERRA_HORIZ_01.PNG",STR0244,STR0245,"1","1"}) //"Serra Fita. H."###"Serra de Fita Horizontal"
	aAdd(aPng,{"000002","1","NG_PG_SERRA_HORIZ_02.PNG",STR0246,STR0247,"1","1"}) //"Serra Horiz. 02"###"Serra Horizontal"
	aAdd(aPng,{"000002","1","NG_PG_SERRA_VERT_01.PNG",STR0248,STR0249,"1","1"}) //"Serra Fita. V."###"Serra de Fita Vertical"
	aAdd(aPng,{"000002","1","NG_PG_SERRA_VERT_02.PNG",STR0250,STR0251,"1","1"}) //"Serra Vert. 02"###"Serra Vertical"
	aAdd(aPng,{"000002","1","NG_PG_SOLDA_MIG_01.PNG",STR0252,STR0253,"1","1"}) //"Solda. MIG"###"Soldador MIG"
	aAdd(aPng,{"000002","1","NG_PG_SOLDA_MIG_02.PNG",STR0254,STR0255,"1","1"}) //"Solda MIG 02"###"Solda MIG"
	aAdd(aPng,{"000002","1","NG_PG_SOLDA_TIG_01.PNG",STR0256,STR0257,"1","1"}) //"Solda. TIG"###"Soldador TIG"
	aAdd(aPng,{"000002","1","NG_PG_SOLDA_TIG_02.PNG",STR0258,STR0259,"1","1"}) //"Solda TIG 02"###"Solda TIG"
	aAdd(aPng,{"000002","1","NG_PG_TORNOCENTRO_01.PNG",STR0260,STR0260,"1","1"}) //"Torno CNC"
	aAdd(aPng,{"000002","1","NG_PG_TORNOCENTRO_02.PNG",STR0260,STR0260,"1","1"}) //"Torno Centro 02"###"Torno Centro"
	aAdd(aPng,{"000002","1","NG_PG_TORNOCNC_01.PNG",STR0260,STR0260,"1","1"})
	aAdd(aPng,{"000002","1","NG_PG_TORNOCNC_02.PNG",STR0263,STR0260,"1","1"}) //"Torno CNC 02"
	aAdd(aPng,{"000003","1","NG_PG_AR_01.PNG",STR0264,STR0265,"1","1"}) //"Cond. Ar. Cim."###"Condicionador de Ar"
	aAdd(aPng,{"000003","1","NG_PG_AR_02.PNG",STR0266,STR0265,"1","1"}) //"Cond. Ar. Dir."
	aAdd(aPng,{"000003","1","NG_PG_AR_03.PNG",STR0267,STR0265,"1","1"}) //"Cond. Ar. Bai."
	aAdd(aPng,{"000003","1","NG_PG_AR_04.PNG",STR0268,STR0265,"1","1"}) //"Cond. Ar. Esq."
	aAdd(aPng,{"000003","1","NG_PG_COPIADORA_G_01.PNG",STR0269,STR0269,"1","1"}) //"Copiadora"
	aAdd(aPng,{"000003","1","NG_PG_COPIADORA_P_01.PNG",STR0270,STR0271,"1","1"}) //"Copia. Mesa"###"Copiadora de Mesa"
	aAdd(aPng,{"000003","1","NG_PG_EXTINTOR.PNG",STR0272,STR0272,"1","1"}) //"Extintor"
	aAdd(aPng,{"000003","1","NG_PG_FAX_01.PNG","FAX","FAX","1","1"}) //"FAX"
	aAdd(aPng,{"000003","1","NG_PG_HUB.PNG","HUB","HUB","1","1"}) //"HUB"
	aAdd(aPng,{"000003","1","NG_PG_IMPRESSORA_01.PNG",STR0275,STR0276,"1","1"}) //"Impress. Dir."###"Impressora"
	aAdd(aPng,{"000003","1","NG_PG_IMPRESSORA_02.PNG",STR0277,STR0276,"1","1"}) //"Impress. Bai."
	aAdd(aPng,{"000003","1","NG_PG_IMPRESSORA_03.PNG",STR0278,STR0276,"1","1"}) //"Impress. Esq."
	aAdd(aPng,{"000003","1","NG_PG_IMPRESSORA_04.PNG",STR0279,STR0276,"1","1"}) //"Impress. Cim."
	aAdd(aPng,{"000003","1","NG_PG_PABX.PNG",STR0280,STR0281,"1","1"}) //"Centr. PABX"###"Central de Telefone PABX"
	aAdd(aPng,{"000003","1","NG_PG_PROJETOR.PNG",STR0282,STR0282,"1","1"}) //"Projetor"
	aAdd(aPng,{"000003","1","NG_PG_PROJETOR_SUSP..PNG",STR0283,STR0284,"1","1"}) //"Projet. Susp."###"Projetor Suspenso"
	aAdd(aPng,{"000003","1","NG_PG_SCANER_01.PNG","Scanner","Scanner","1","1"}) //"Scanner Cim."###"Scanner"
	aAdd(aPng,{"000003","1","NG_PG_SCANER_02.PNG","Scanner","Scanner","1","1"}) //"Scanner Dir."
	aAdd(aPng,{"000003","1","NG_PG_TELEFONE_01.PNG",STR0288,STR0288,"1","1"}) //"Telef. Cim."
	aAdd(aPng,{"000003","1","NG_PG_TELEFONE_02.PNG",STR0289,STR0289,"1","1"}) //"Telef. Dir."
	aAdd(aPng,{"000003","1","NG_PG_TORREPC_01.PNG",STR0290,STR0291,"1","1"}) //"Torre PC 01"###"Torre P.C."
	aAdd(aPng,{"000003","1","NG_PG_BEBEDOURO_01.PNG",STR0292,STR0293,"1","1"}) //"Bebedouro 01"###"Bebedouro"
	aAdd(aPng,{"000003","1","NG_PG_BEBEDOURO_02.PNG",STR0294,STR0293,"1","1"}) //"Bebedouro 02"
	aAdd(aPng,{"000003","1","NG_PG_BEBEDOURO_03.PNG",STR0295,STR0293,"1","1"}) //"Bebedouro 03"
	aAdd(aPng,{"000003","1","NG_PG_BEBEDOURO_04.PNG",STR0296,STR0293,"1","1"}) //"Bebedouro 04"
	aAdd(aPng,{"000003","1","NG_PG_COPIADORA_G_02.PNG",STR0297,STR0298,"1","1"}) //"Copiadora G. 02"###"Copiadora Grande"
	aAdd(aPng,{"000003","1","NG_PG_COPIADORA_G_03.PNG",STR0299,STR0298,"1","1"}) //"Copiadora G. 03"
	aAdd(aPng,{"000003","1","NG_PG_COPIADORA_G_04.PNG",STR0300,STR0298,"1","1"}) //"Copiadora G. 04"
	aAdd(aPng,{"000003","1","NG_PG_COPIADORA_P_02.PNG",STR0301,STR0302,"1","1"}) //"Copiadora N. 02"###"Copiadora Pequena"
	aAdd(aPng,{"000003","1","NG_PG_COPIADORA_P_03.PNG",STR0303,STR0302,"1","1"}) //"Copiadora N. 03"
	aAdd(aPng,{"000003","1","NG_PG_COPIADORA_P_04.PNG",STR0304,STR0302,"1","1"}) //"Copiadora N. 04"
	aAdd(aPng,{"000003","1","NG_PG_LCD_01.PNG","TV LCD 01","TV LCD","1","1"})
	aAdd(aPng,{"000003","1","NG_PG_LCD_02.PNG","TV LCD 02","TV LCD","1","1"})
	aAdd(aPng,{"000003","1","NG_PG_LCD_03.PNG","TV LCD 03","TV LCD","1","1"})
	aAdd(aPng,{"000003","1","NG_PG_LCD_04.PNG","TV LCD 04","TV LCD","1","1"})
	aAdd(aPng,{"000003","1","NG_PG_MONITOR_01.PNG",STR0305,STR0306,"1","1"}) //"Monitor 01"###"Monitor"
	aAdd(aPng,{"000003","1","NG_PG_MONITOR_02.PNG",STR0307,STR0306,"1","1"}) //"Monitor 02"
	aAdd(aPng,{"000003","1","NG_PG_MONITOR_03.PNG",STR0308,STR0306,"1","1"}) //"Monitor 03"
	aAdd(aPng,{"000003","1","NG_PG_MONITOR_04.PNG",STR0309,STR0306,"1","1"}) //"Monitor 04"
	aAdd(aPng,{"000003","1","NG_PG_RACK.PNG","Rack","Rack","1","1"}) //"Rack"
	aAdd(aPng,{"000003","1","NG_PG_TECLADO_01.PNG",STR0311,STR0312,"1","1"}) //"Teclado 01"###"Teclado"
	aAdd(aPng,{"000003","1","NG_PG_TECLADO_02.PNG",STR0313,STR0312,"1","1"}) //"Teclado 02"
	aAdd(aPng,{"000003","1","NG_PG_TORREPC_02.PNG",STR0314,STR0315,"1","1"}) //"Torre PC. 02"###"Torre PC."
	aAdd(aPng,{"000003","1","NG_PG_FAX_02.PNG",STR0316,STR0273,"1","1"}) //"Fax 02"###"Fax"
	aAdd(aPng,{"000003","1","NG_PG_FAX_03.PNG","Fax","Fax","1","1"}) //"Fax 03"
	aAdd(aPng,{"000003","1","NG_PG_FAX_04.PNG","Fax","Fax","1","1"}) //"Fax 04"
	aAdd(aPng,{"000003","1","NG_PG_TECLADO_03.PNG",STR0319,STR0312,"1","1"}) //"Teclado 03"
	aAdd(aPng,{"000003","1","NG_PG_TECLADO_04.PNG",STR0320,STR0312,"1","1"}) //"Teclado 04"
	aAdd(aPng,{"000004","1","NG_PG_MICTORIO01.PNG",STR0321,STR0322,"1","1"}) //"Mictorio 01"###"Mictorio"
	aAdd(aPng,{"000004","1","NG_PG_MICTORIO02.PNG",STR0323,STR0322,"1","1"}) //"Mictorio 02"
	aAdd(aPng,{"000004","1","NG_PG_MICTORIO03.PNG",STR0324,STR0322,"1","1"}) //"Mictorio 03"
	aAdd(aPng,{"000004","1","NG_PG_MICTORIO04.PNG",STR0325,STR0322,"1","1"}) //"Mictorio 04"
	aAdd(aPng,{"000004","1","NG_PG_PIA_QUADRADA01.PNG",STR0326,STR0326,"1","1"}) //"Pia Quadrada 01"
	aAdd(aPng,{"000004","1","NG_PG_PIA_QUADRADA02.PNG",STR0327,STR0327,"1","1"}) //"Pia Quadrada 02"
	aAdd(aPng,{"000004","1","NG_PG_PIA_QUADRADA03.PNG",STR0328,STR0328,"1","1"}) //"Pia Quadrada 03"
	aAdd(aPng,{"000004","1","NG_PG_PIA_QUADRADA04.PNG",STR0329,STR0329,"1","1"}) //"Pia Quadrada 04"
	aAdd(aPng,{"000004","1","NG_PG_PIA_REDONDA01.PNG",STR0330,STR0330,"1","1"}) //"Pia Redonda 01"
	aAdd(aPng,{"000004","1","NG_PG_PIA_REDONDA02.PNG",STR0331,STR0331,"1","1"}) //"Pia Redonda 02"
	aAdd(aPng,{"000004","1","NG_PG_PIA_REDONDA03.PNG",STR0332,STR0332,"1","1"}) //"Pia Redonda 03"
	aAdd(aPng,{"000004","1","NG_PG_PIA_REDONDA04.PNG",STR0333,STR0333,"1","1"}) //"Pia Redonda 04"
	aAdd(aPng,{"000004","1","NG_PG_SANITARIO_01.PNG",STR0334,STR0334,"1","1"}) //"Sanitario 01"
	aAdd(aPng,{"000004","1","NG_PG_SANITARIO_02.PNG",STR0335,STR0335,"1","1"}) //"Sanitario 02"
	aAdd(aPng,{"000004","1","NG_PG_SANITARIO_03.PNG",STR0336,STR0336,"1","1"}) //"Sanitario 03"
	aAdd(aPng,{"000004","1","NG_PG_SANITARIO_04.PNG",STR0337,STR0337,"1","1"}) //"Sanitario 04"
	aAdd(aPng,{"000004","1","NG_PG_SANITARIO_PAREDE01.PNG",STR0338,STR0339,"1","1"}) //"Sanitarrio.P 01"###"Sanitarrio de parede 01."
	aAdd(aPng,{"000004","1","NG_PG_SANITARIO_PAREDE02.PNG",STR0340,STR0341,"1","1"}) //"Sanitarrio.P 02"###"Sanitarrio de parede 02."
	aAdd(aPng,{"000004","1","NG_PG_SANITARIO_PAREDE03.PNG",STR0342,STR0343,"1","1"}) //"Sanitarrio.P 03"###"Sanitarrio de parede 03."
	aAdd(aPng,{"000004","1","NG_PG_SANITARIO_PAREDE04.PNG",STR0344,STR0345,"1","1"}) //"Sofa Dup. Dir."###"Sofa Duplo"
	aAdd(aPng,{"000001","1","NG_PG_SOFADUPLO_02.PNG",STR0180,STR0179,"1","1"}) //"Sofa Dup. Bai."
	aAdd(aPng,{"000001","1","NG_PG_SOFADUPLO_03.PNG",STR0181,STR0179,"1","1"}) //"Sofa Dup. Esq."
	aAdd(aPng,{"000001","1","NG_PG_SOFADUPLO_04.PNG",STR0182,STR0179,"1","1"}) //"Sofa Dup. Cim."
	aAdd(aPng,{"000001","1","NG_PG_SOFATRIPLO_01.PNG",STR0183,STR0184,"1","1"}) //"Sofa Trip. Esq."###"Sofa Triplo"
	aAdd(aPng,{"000001","1","NG_PG_SOFATRIPLO_02.PNG",STR0185,STR0184,"1","1"}) //"Sofa Trip. Cim."
	aAdd(aPng,{"000001","1","NG_PG_SOFATRIPLO_03.PNG",STR0186,STR0184,"1","1"}) //"Sofa Trip. Dir."
	aAdd(aPng,{"000001","1","NG_PG_SOFATRIPLO_04.PNG",STR0187,STR0184,"1","1"}) //"Sofa Trip. Bai."
	aAdd(aPng,{"000001","1","NG_PG_MESACANTO_01.PNG",STR0188,STR0189,"1","1"}) //"Sup. Canto 01"###"Superficie de Canto"
	aAdd(aPng,{"000001","1","NG_PG_MESACANTO_02.PNG",STR0190,STR0189,"1","1"}) //"Sup. Canto 02"
	aAdd(aPng,{"000001","1","NG_PG_MESACANTO_03.PNG",STR0191,STR0189,"1","1"}) //"Sup. Canto 03"
	aAdd(aPng,{"000001","1","NG_PG_MESACANTO_04.PNG",STR0192,STR0189,"1","1"}) //"Sup. Canto 04"
	aAdd(aPng,{"000002","1","NG_PG_BANCADA_IND_01.PNG",STR0193,STR0194,"1","1"}) //"Banca Trab."###"Banca de Trabalho"
	aAdd(aPng,{"000002","1","NG_PG_BANCADA_IND_02.PNG",STR0195,STR0194,"1","1"}) //"Bancada 02"
	aAdd(aPng,{"000002","1","NG_PG_CXFERRAMENTA_01.PNG",STR0196,STR0197,"1","1"}) //"Caixa Ferram."###"Caixa de Ferramentas"
	aAdd(aPng,{"000002","1","NG_PG_CXFERRAMENTA_02.PNG",STR0198,STR0197,"1","1"}) //"Cx. Ferramenta"
	aAdd(aPng,{"000002","1","NG_PG_PLATAFORMA_01.PNG",STR0199,STR0200,"1","1"}) //"Carrinho Plata."###"Carrinho de Plataforma"
	aAdd(aPng,{"000002","1","NG_PG_PLATAFORMA_02.PNG",STR0201,STR0202,"1","1"}) //"Plataforma 02"###"Plataforma"
	aAdd(aPng,{"000002","1","NG_PG_COMPRESSOR_01.PNG",STR0203,STR0203,"1","1"}) //"Compressor"
	aAdd(aPng,{"000002","1","NG_PG_COMPRESSOR_02.PNG",STR0204,STR0203,"1","1"}) //"Compressor 02"
	aAdd(aPng,{"000002","1","NG_PG_FURADEIRA_01.PNG",STR0205,STR0206,"1","1"}) //"Furadeira Banc."###"Furadeira de Bancada"
	aAdd(aPng,{"000002","1","NG_PG_FURADEIRA_02.PNG",STR0207,STR0208,"1","1"}) //"Furadeira 02"###"Furadeira"
	aAdd(aPng,{"000002","1","NG_PG_FRESA_HORIZ_01.PNG",STR0209,STR0210,"1","1"}) //"Fresadora Hori."###"Fresador Horizontal"
	aAdd(aPng,{"000002","1","NG_PG_FRESA_HORIZ_02.PNG",STR0211,STR0210,"1","1"}) //"Fresa Hori 02"
	aAdd(aPng,{"000002","1","NG_PG_FRESA_REVOLV_01.PNG",STR0212,STR0213,"1","1"}) //"Fresadora Revo."###"Fresadora Revolver"
	aAdd(aPng,{"000002","1","NG_PG_FRESA_REVOLV_02.PNG",STR0214,STR0213,"1","1"}) //"Fresa revolv 02"
	aAdd(aPng,{"000002","1","NG_PG_FRESA_VERTIC_01.PNG",STR0215,STR0216,"1","1"}) //"Fresadora Vert."###"Fresadora Vertical"
	aAdd(aPng,{"000002","1","NG_PG_FRESA_VERTIC_02.PNG",STR0217,STR0218,"1","1"}) //"Fresa Vertic.02"###"Fresa Vertical"
	aAdd(aPng,{"000002","1","NG_PG_GERADOR_01.PNG",STR0219,STR0220,"1","1"}) //"Gerador 01"###"Gerador"
	aAdd(aPng,{"000002","1","NG_PG_GERADOR_02.PNG",STR0221,STR0220,"1","1"}) //"Gerdador 02"
	aAdd(aPng,{"000002","1","NG_PG_MAQ_CORTE_01.PNG",STR0222,STR0223,"1","1"}) //"Maquina Cort."###"Maquina de Cortar"
	aAdd(aPng,{"000002","1","NG_PG_MAQ_CORTE_02.PNG",STR0224,STR0225,"1","1"}) //"Maq. Corte 02"###"Maquina de Corte"
	aAdd(aPng,{"000002","1","NG_PG_MAQ_SERRAR_01.PNG",STR0226,STR0227,"1","1"}) //"Maquina Serr."###"Maquina de Serrar"
	aAdd(aPng,{"000002","1","NG_PG_MAQ_SERRAR_02.PNG",STR0228,STR0227,"1","1"}) //"Maq. Serrar 02"###"Maquina de Serrar"
	aAdd(aPng,{"000002","1","NG_PG_MAQ_DOBRA_01.PNG",STR0229,STR0230,"1","1"}) //"Maquina Dobr."###"Maquina Dobradeira"
	aAdd(aPng,{"000002","1","NG_PG_MAQ_DOBRA_02.PNG",STR0231,STR0232,"1","1"}) //"Maq. Dobra 02"###"Maquina de Dobra"
	aAdd(aPng,{"000002","1","NG_PG_MAQ_FURAR_01.PNG",STR0233,STR0234,"1","1"}) //"Maquina Fura."###"Maquina Furadeira"
	aAdd(aPng,{"000002","1","NG_PG_MAQ_FURAR_02.PNG",STR0235,STR0236,"1","1"}) //"Maq. Furar 02"###"Maquina de Furar"
	aAdd(aPng,{"000002","1","NG_PG_MAQ_LIMAR_01.PNG",STR0237,STR0238,"1","1"}) //"Maquina Lima."###"Maquina Limadora"
	aAdd(aPng,{"000002","1","NG_PG_MAQ_LIMAR_02.PNG",STR0239,STR0240,"1","1"}) //"Maq. Limar 02"###"Maquina de Limar"
	aAdd(aPng,{"000002","1","NG_PG_PRELOMANUAL_01.PNG",STR0241,STR0241,"1","1"}) //"Prelo Manual"
	aAdd(aPng,{"000002","1","NG_PG_PRELOMANUAL_02.PNG",STR0241,STR0241,"1","1"}) //"Prelo Manual"
	aAdd(aPng,{"000002","1","NG_PG_RETIFICA_SUP_01.PNG",STR0242,STR0243,"1","1"}) //"Retifi. Superf."###"Retificador de Superficie"
	aAdd(aPng,{"000002","1","NG_PG_SERRA_HORIZ_01.PNG",STR0244,STR0245,"1","1"}) //"Serra Fita. H."###"Serra de Fita Horizontal"
	aAdd(aPng,{"000002","1","NG_PG_SERRA_HORIZ_02.PNG",STR0246,STR0247,"1","1"}) //"Serra Horiz. 02"###"Serra Horizontal"
	aAdd(aPng,{"000002","1","NG_PG_SERRA_VERT_01.PNG",STR0248,STR0249,"1","1"}) //"Serra Fita. V."###"Serra de Fita Vertical"
	aAdd(aPng,{"000002","1","NG_PG_SERRA_VERT_02.PNG",STR0250,STR0251,"1","1"}) //"Serra Vert. 02"###"Serra Vertical"
	aAdd(aPng,{"000002","1","NG_PG_SOLDA_MIG_01.PNG",STR0252,STR0253,"1","1"}) //"Solda. MIG"###"Soldador MIG"
	aAdd(aPng,{"000002","1","NG_PG_SOLDA_MIG_02.PNG",STR0254,STR0255,"1","1"}) //"Solda MIG 02"###"Solda MIG"
	aAdd(aPng,{"000002","1","NG_PG_SOLDA_TIG_01.PNG",STR0256,STR0257,"1","1"}) //"Solda. TIG"###"Soldador TIG"
	aAdd(aPng,{"000002","1","NG_PG_SOLDA_TIG_02.PNG",STR0258,STR0259,"1","1"}) //"Solda TIG 02"###"Solda TIG"
	aAdd(aPng,{"000002","1","NG_PG_TORNOCENTRO_01.PNG",STR0260,STR0260,"1","1"}) //"Torno CNC"
	aAdd(aPng,{"000002","1","NG_PG_TORNOCENTRO_02.PNG",STR0260,STR0260,"1","1"}) //"Torno Centro 02"###"Torno Centro"
	aAdd(aPng,{"000002","1","NG_PG_TORNOCNC_01.PNG",STR0260,STR0260,"1","1"})
	aAdd(aPng,{"000002","1","NG_PG_TORNOCNC_02.PNG",STR0263,STR0260,"1","1"}) //"Torno CNC 02"
	aAdd(aPng,{"000003","1","NG_PG_AR_01.PNG",STR0264,STR0265,"1","1"}) //"Cond. Ar. Cim."###"Condicionador de Ar"
	aAdd(aPng,{"000003","1","NG_PG_AR_02.PNG",STR0266,STR0265,"1","1"}) //"Cond. Ar. Dir."
	aAdd(aPng,{"000003","1","NG_PG_AR_03.PNG",STR0267,STR0265,"1","1"}) //"Cond. Ar. Bai."
	aAdd(aPng,{"000003","1","NG_PG_AR_04.PNG",STR0268,STR0265,"1","1"}) //"Cond. Ar. Esq."
	aAdd(aPng,{"000003","1","NG_PG_COPIADORA_G_01.PNG",STR0269,STR0269,"1","1"}) //"Copiadora"
	aAdd(aPng,{"000003","1","NG_PG_COPIADORA_P_01.PNG",STR0270,STR0271,"1","1"}) //"Copia. Mesa"###"Copiadora de Mesa"
	aAdd(aPng,{"000003","1","NG_PG_EXTINTOR.PNG",STR0272,STR0272,"1","1"}) //"Extintor"
	aAdd(aPng,{"000003","1","NG_PG_FAX_01.PNG","FAX","FAX","1","1"}) //"FAX"
	aAdd(aPng,{"000003","1","NG_PG_HUB.PNG","HUB","HUB","1","1"}) //"HUB"
	aAdd(aPng,{"000003","1","NG_PG_IMPRESSORA_01.PNG",STR0275,STR0276,"1","1"}) //"Impress. Dir."###"Impressora"
	aAdd(aPng,{"000003","1","NG_PG_IMPRESSORA_02.PNG",STR0277,STR0276,"1","1"}) //"Impress. Bai."
	aAdd(aPng,{"000003","1","NG_PG_IMPRESSORA_03.PNG",STR0278,STR0276,"1","1"}) //"Impress. Esq."
	aAdd(aPng,{"000003","1","NG_PG_IMPRESSORA_04.PNG",STR0279,STR0276,"1","1"}) //"Impress. Cim."
	aAdd(aPng,{"000003","1","NG_PG_PABX.PNG",STR0280,STR0281,"1","1"}) //"Centr. PABX"###"Central de Telefone PABX"
	aAdd(aPng,{"000003","1","NG_PG_PROJETOR.PNG",STR0282,STR0282,"1","1"}) //"Projetor"
	aAdd(aPng,{"000003","1","NG_PG_PROJETOR_SUSP..PNG",STR0283,STR0284,"1","1"}) //"Projet. Susp."###"Projetor Suspenso"
	aAdd(aPng,{"000003","1","NG_PG_SCANER_01.PNG","Scanner","Scanner","1","1"}) //"Scanner Cim."###"Scanner"
	aAdd(aPng,{"000003","1","NG_PG_SCANER_02.PNG","Scanner","Scanner","1","1"}) //"Scanner Dir."
	aAdd(aPng,{"000003","1","NG_PG_TELEFONE_01.PNG",STR0288,STR0288,"1","1"}) //"Telef. Cim."
	aAdd(aPng,{"000003","1","NG_PG_TELEFONE_02.PNG",STR0289,STR0289,"1","1"}) //"Telef. Dir."
	aAdd(aPng,{"000003","1","NG_PG_TORREPC_01.PNG",STR0290,STR0291,"1","1"}) //"Torre PC 01"###"Torre P.C."
	aAdd(aPng,{"000003","1","NG_PG_BEBEDOURO_01.PNG",STR0292,STR0293,"1","1"}) //"Bebedouro 01"###"Bebedouro"
	aAdd(aPng,{"000003","1","NG_PG_BEBEDOURO_02.PNG",STR0294,STR0293,"1","1"}) //"Bebedouro 02"
	aAdd(aPng,{"000003","1","NG_PG_BEBEDOURO_03.PNG",STR0295,STR0293,"1","1"}) //"Bebedouro 03"
	aAdd(aPng,{"000003","1","NG_PG_BEBEDOURO_04.PNG",STR0296,STR0293,"1","1"}) //"Bebedouro 04"
	aAdd(aPng,{"000003","1","NG_PG_COPIADORA_G_02.PNG",STR0297,STR0298,"1","1"}) //"Copiadora G. 02"###"Copiadora Grande"
	aAdd(aPng,{"000003","1","NG_PG_COPIADORA_G_03.PNG",STR0299,STR0298,"1","1"}) //"Copiadora G. 03"
	aAdd(aPng,{"000003","1","NG_PG_COPIADORA_G_04.PNG",STR0300,STR0298,"1","1"}) //"Copiadora G. 04"
	aAdd(aPng,{"000003","1","NG_PG_COPIADORA_P_02.PNG",STR0301,STR0302,"1","1"}) //"Copiadora N. 02"###"Copiadora Pequena"
	aAdd(aPng,{"000003","1","NG_PG_COPIADORA_P_03.PNG",STR0303,STR0302,"1","1"}) //"Copiadora N. 03"
	aAdd(aPng,{"000003","1","NG_PG_COPIADORA_P_04.PNG",STR0304,STR0302,"1","1"}) //"Copiadora N. 04"
	aAdd(aPng,{"000003","1","NG_PG_LCD_01.PNG","TV LCD 01","TV LCD","1","1"})
	aAdd(aPng,{"000003","1","NG_PG_LCD_02.PNG","TV LCD 02","TV LCD","1","1"})
	aAdd(aPng,{"000003","1","NG_PG_LCD_03.PNG","TV LCD 03","TV LCD","1","1"})
	aAdd(aPng,{"000003","1","NG_PG_LCD_04.PNG","TV LCD 04","TV LCD","1","1"})
	aAdd(aPng,{"000003","1","NG_PG_MONITOR_01.PNG",STR0305,STR0306,"1","1"}) //"Monitor 01"###"Monitor"
	aAdd(aPng,{"000003","1","NG_PG_MONITOR_02.PNG",STR0307,STR0306,"1","1"}) //"Monitor 02"
	aAdd(aPng,{"000003","1","NG_PG_MONITOR_03.PNG",STR0308,STR0306,"1","1"}) //"Monitor 03"
	aAdd(aPng,{"000003","1","NG_PG_MONITOR_04.PNG",STR0309,STR0306,"1","1"}) //"Monitor 04"
	aAdd(aPng,{"000003","1","NG_PG_RACK.PNG","Rack","Rack","1","1"}) //"Rack"
	aAdd(aPng,{"000003","1","NG_PG_TECLADO_01.PNG",STR0311,STR0312,"1","1"}) //"Teclado 01"###"Teclado"
	aAdd(aPng,{"000003","1","NG_PG_TECLADO_02.PNG",STR0313,STR0312,"1","1"}) //"Teclado 02"
	aAdd(aPng,{"000003","1","NG_PG_TORREPC_02.PNG",STR0314,STR0315,"1","1"}) //"Torre PC. 02"###"Torre PC."
	aAdd(aPng,{"000003","1","NG_PG_FAX_02.PNG",STR0316,STR0273,"1","1"}) //"Fax 02"###"Fax"
	aAdd(aPng,{"000003","1","NG_PG_FAX_03.PNG","Fax","Fax","1","1"}) //"Fax 03"
	aAdd(aPng,{"000003","1","NG_PG_FAX_04.PNG","Fax","Fax","1","1"}) //"Fax 04"
	aAdd(aPng,{"000003","1","NG_PG_TECLADO_03.PNG",STR0319,STR0312,"1","1"}) //"Teclado 03"
	aAdd(aPng,{"000003","1","NG_PG_TECLADO_04.PNG",STR0320,STR0312,"1","1"}) //"Teclado 04"
	aAdd(aPng,{"000004","1","NG_PG_MICTORIO01.PNG",STR0321,STR0322,"1","1"}) //"Mictorio 01"###"Mictorio"
	aAdd(aPng,{"000004","1","NG_PG_MICTORIO02.PNG",STR0323,STR0322,"1","1"}) //"Mictorio 02"
	aAdd(aPng,{"000004","1","NG_PG_MICTORIO03.PNG",STR0324,STR0322,"1","1"}) //"Mictorio 03"
	aAdd(aPng,{"000004","1","NG_PG_MICTORIO04.PNG",STR0325,STR0322,"1","1"}) //"Mictorio 04"
	aAdd(aPng,{"000004","1","NG_PG_PIA_QUADRADA01.PNG",STR0326,STR0326,"1","1"}) //"Pia Quadrada 01"
	aAdd(aPng,{"000004","1","NG_PG_PIA_QUADRADA02.PNG",STR0327,STR0327,"1","1"}) //"Pia Quadrada 02"
	aAdd(aPng,{"000004","1","NG_PG_PIA_QUADRADA03.PNG",STR0328,STR0328,"1","1"}) //"Pia Quadrada 03"
	aAdd(aPng,{"000004","1","NG_PG_PIA_QUADRADA04.PNG",STR0329,STR0329,"1","1"}) //"Pia Quadrada 04"
	aAdd(aPng,{"000004","1","NG_PG_PIA_REDONDA01.PNG",STR0330,STR0330,"1","1"}) //"Pia Redonda 01"
	aAdd(aPng,{"000004","1","NG_PG_PIA_REDONDA02.PNG",STR0331,STR0331,"1","1"}) //"Pia Redonda 02"
	aAdd(aPng,{"000004","1","NG_PG_PIA_REDONDA03.PNG",STR0332,STR0332,"1","1"}) //"Pia Redonda 03"
	aAdd(aPng,{"000004","1","NG_PG_PIA_REDONDA04.PNG",STR0333,STR0333,"1","1"}) //"Pia Redonda 04"
	aAdd(aPng,{"000004","1","NG_PG_SANITARIO_01.PNG",STR0334,STR0334,"1","1"}) //"Sanitario 01"
	aAdd(aPng,{"000004","1","NG_PG_SANITARIO_02.PNG",STR0335,STR0335,"1","1"}) //"Sanitario 02"
	aAdd(aPng,{"000004","1","NG_PG_SANITARIO_03.PNG",STR0336,STR0336,"1","1"}) //"Sanitario 03"
	aAdd(aPng,{"000004","1","NG_PG_SANITARIO_04.PNG",STR0337,STR0337,"1","1"}) //"Sanitario 04"
	aAdd(aPng,{"000004","1","NG_PG_SANITARIO_PAREDE01.PNG",STR0338,STR0339,"1","1"}) //"Sanitarrio.P 01"###"Sanitarrio de parede 01."
	aAdd(aPng,{"000004","1","NG_PG_SANITARIO_PAREDE02.PNG",STR0340,STR0341,"1","1"}) //"Sanitarrio.P 02"###"Sanitarrio de parede 02."
	aAdd(aPng,{"000004","1","NG_PG_SANITARIO_PAREDE03.PNG",STR0342,STR0343,"1","1"}) //"Sanitarrio.P 03"###"Sanitarrio de parede 03."
	aAdd(aPng,{"000004","1","NG_PG_SANITARIO_PAREDE04.PNG",STR0344,STR0345,"1","1"}) //"Sanitarrio.P 04"###"Sanitarrio de parede 04."

	If __nModPG == 35

		cQry := " SELECT COUNT( * ) AS TOTAL FROM " + RetSQLName( "TU1" ) + " TU1 "
		cQry += " WHERE TU1.TU1_IMAGEM = " + ValToSQL( "ng_ico_ris_aci_1.png" ) + " AND "
		cQry += " TU1.TU1_FILIAL = " + ValToSQL( xFilial("TU1") ) + " AND "
		cQry += " TU1.TU1_PROPRI = '1' AND TU1.D_E_L_E_T_ <> '*'"

		cAlsImg := GetNextAlias()

		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAlsImg, .F., .T.)

		dbSelectArea( cAlsImg )
		If (cAlsImg)->TOTAL == 0
			aAdd(aGrupo, {cCodNR,STR0449,"1","1"} )//Riscos

			aAdd(aPng,{cCodNR,"1","ng_ico_ris_aci_1.png",STR0446,STR0450,"1","1"}) //"Grau 1"###"Risco Acidente"
			aAdd(aPng,{cCodNR,"1","ng_ico_ris_aci_2.png",STR0447,STR0450,"1","1"}) //"Grau 2"###"Risco Acidente"
			aAdd(aPng,{cCodNR,"1","ng_ico_ris_aci_3.png",STR0448,STR0450,"1","1"}) //"Grau 3"###"Risco Acidente"

			aAdd(aPng,{cCodNR,"1","ng_ico_ris_bio_1.png",STR0446,STR0451,"1","1"}) //""Grau 1""###"Risco Biológico"
			aAdd(aPng,{cCodNR,"1","ng_ico_ris_bio_2.png",STR0447,STR0451,"1","1"}) //""Grau 2""###"Risco Biológico"
			aAdd(aPng,{cCodNR,"1","ng_ico_ris_bio_3.png",STR0448,STR0451,"1","1"}) //""Grau 3""###"Risco Biológico"

			aAdd(aPng,{cCodNR,"1","ng_ico_ris_erg_1.png",STR0446,STR0452,"1","1"}) //""Grau 1""###"Risco Ergométrico"
			aAdd(aPng,{cCodNR,"1","ng_ico_ris_erg_2.png",STR0447,STR0452,"1","1"}) //""Grau 2""###"Risco Ergométrico"
			aAdd(aPng,{cCodNR,"1","ng_ico_ris_erg_3.png",STR0448,STR0452,"1","1"}) //""Grau 3""###"Risco Ergométrico"

			aAdd(aPng,{cCodNR,"1","ng_ico_ris_fis_1.png",STR0446,STR0453,"1","1"}) //""Grau 1""###"Risco Físico"
			aAdd(aPng,{cCodNR,"1","ng_ico_ris_fis_2.png",STR0447,STR0453,"1","1"}) //""Grau 2""###""Risco Físico"
			aAdd(aPng,{cCodNR,"1","ng_ico_ris_fis_3.png",STR0448,STR0453,"1","1"}) //""Grau 3""###"Risco Físico"

			aAdd(aPng,{cCodNR,"1","ng_ico_ris_qui_1.png",STR0446,STR0454,"1","1"}) //""Grau 1""###"Risco Químico"
			aAdd(aPng,{cCodNR,"1","ng_ico_ris_qui_2.png",STR0447,STR0454,"1","1"}) //""Grau 2""###"Risco Químico"
			aAdd(aPng,{cCodNR,"1","ng_ico_ris_qui_3.png",STR0448,STR0454,"1","1"}) //""Grau 3""###"Risco Químico"
		EndIf

		(cAlsImg)->( dbCloseArea() )
	EndIf

	If __nModPG == 56

		cQry := " SELECT COUNT( * ) AS TOTAL FROM " + RetSQLName( "TU1" ) + " TU1 "
		cQry += " WHERE TU1.TU1_IMAGEM = " + ValToSQL( "NG_PG_PCOLETA.png" ) + " AND "
		cQry += " TU1.TU1_FILIAL = " + ValToSQL( xFilial("TU1") ) + " AND "
		cQry += " TU1.TU1_PROPRI = '1' AND TU1.D_E_L_E_T_ <> '*'"

		cAlsImg := GetNextAlias()

		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAlsImg, .F., .T.)

		dbSelectArea( cAlsImg )
		If (cAlsImg)->TOTAL == 0

			cCodSGA := Soma1Old(cCodSGA)

			aAdd(aGrupo, {cCodSGA,STR0495,"1","1"} ) //"Resíduos Gerais"
			aAdd(aPng,{cCodSGA,"1","NG_PG_RES_INDUSTRIAL.png",STR0496,STR0496,"1","1"})//"Industrial"
			aAdd(aPng,{cCodSGA,"1","NG_PG_RES_ORGANICO.png",STR0497,STR0497,"1","1"})//"Orgânico"
			aAdd(aPng,{cCodSGA,"1","NG_PG_RES_PERIGOSO.png",STR0498,STR0498,"1","1"})//"Perigoso"
			aAdd(aPng,{cCodSGA,"1","NG_PG_RES_RADIOATIVO.png",STR0499,STR0499,"1","1"})//"Radioativo"
			aAdd(aPng,{cCodSGA,"1","NG_PG_RES_RSS.png",STR0501,STR0501,"1","1"}) //"Serviço Saúde"
			aAdd(aPng,{cCodSGA,"1","NG_PG_RES_URBANO.png",STR0502,STR0502,"1","1"})//"Urbano"

			cCodSGA := Soma1Old(cCodSGA)

			aAdd(aGrupo, {cCodSGA,STR0503,"1","1"} ) //"Resíduos Específicos"
			aAdd(aPng,{cCodSGA,"1","NG_PG_RES_METAL.png",STR0505,STR0505,"1","1"})//"Metal"
			aAdd(aPng,{cCodSGA,"1","NG_PG_RES_OLEO.png",STR0506,STR0506,"1","1"}) //"Óleo"
			aAdd(aPng,{cCodSGA,"1","NG_PG_RES_PAPEL.png",STR0507,STR0507,"1","1"})//"Papel"
			aAdd(aPng,{cCodSGA,"1","NG_PG_RES_PNEU.png",STR0508,STR0508,"1","1"})//"Pneu"
			aAdd(aPng,{cCodSGA,"1","NG_PG_RES_BATERIA.png",STR0517,STR0517,"1","1"})//"Bateria"

			cCodSGA := Soma1Old(cCodSGA)

			aAdd(aGrupo, {cCodSGA,STR0460,"1","1"} )//"Pontos de Coleta"
			aAdd(aPng,{cCodSGA,"1","NG_ICO_PCOLETA.png",STR0479,STR0479,"1","1"}) //"Pt. Coleta"

			cCodSGA := Soma1Old(cCodSGA)

			aAdd(aGrupo, {cCodSGA,STR0516,"1","1"} )//"Aspectos"
			aAdd(aPng,{cCodSGA,"1","NG_PG_ASP_ELETRICO.png",STR0504,STR0504,"1","1"}) //"Elétricos"
			aAdd(aPng,{cCodSGA,"1","NG_PG_ASP_ATMOSFERICO.png",STR0513,STR0513,"1","1"}) //"Atmosféricos"
			aAdd(aPng,{cCodSGA,"1","NG_PG_ASP_RUIDOS.png",STR0514,STR0514,"1","1"}) //"Ruídos"
			aAdd(aPng,{cCodSGA,"1","NG_PG_ASP_LIQUIDOS.png",STR0515,STR0515,"1","1"}) //"Líquidos"

		EndIf

		(cAlsImg)->( dbCloseArea() )
	EndIf

	dbSelectArea("TU0")
	dbSetOrder(1)
	ProcRegua(Len(aGrupo))
	For nX := 1 to Len(aGrupo)
		IncProc(STR0346) //"Processando registros"
		If !dbSeek(xFilial("TU0")+aGRupo[nX][1])
			RecLock("TU0",.T.)
			TU0->TU0_FILIAL:= xFilial("TU0")
			TU0->TU0_OPCAO := aGrupo[nX][1]
			TU0->TU0_DESCRI:= AllTrim(aGrupo[nX][2])
			TU0->TU0_VISIBL:= aGrupo[Nx][3]
			TU0->TU0_PROPRI:= aGrupo[nX][4]
			MsUnlock("TU0")
		EndIf
	Next nX

	dbSelectArea("TU1")
	dbSetOrder(1)
	ProcRegua(Len(aPng))
	For nY := 1 to Len(aPng)
		IncProc(STR0346) //"Processando registros"
		If !dbSeek(xFilial("TU1")+aPng[nY][1]+aPng[nY][2]+aPng[nY][3])
			RecLock("TU1",.T.)
			TU1->TU1_FILIAL := xFilial("TU1")
			TU1->TU1_OPCAO := aPng[nY][1]
			TU1->TU1_TIPIMG:= aPng[nY][2]
			TU1->TU1_IMAGEM:= aPng[nY][3]
			TU1->TU1_DESCRI:= AllTrim(aPng[nY][4])
			TU1->TU1_TOOLTI:= AllTrim(aPng[nY][5])
			TU1->TU1_VISIBL:= aPng[nY][6]
			TU1->TU1_PROPRI:= aPng[nY][7]
			MsUnlock("TU1")
		EndIf
	Next nY

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTPGF3LOC
Função que retorna o código da seleção (F3)

@author Wagner S. de Lacerda
@since 16/04/2010
@version MP10
@return Nil
@obs Retorno da consulta padrão MNTGEN
/*/
//---------------------------------------------------------------------
Static Function MNTPGF3LOC()

	Local cCodPro	:= (_oPgF3:cTrbTree)->CODPRO
	Local cRet		:= cCodPro

	If (_oPgF3:cTrbTree)->TIPO == "1"
		_cPgTipo := "1"
		Eval(_oF3Tipo:bChange)
		cRet := (_oPgF3:cTrbTree)->CODTIPO
	ElseIf (_oPgF3:cTrbTree)->TIPO == "2" .AND. (_oPgF3:cTrbTree)->PLANTA == "1" //sim
		_cPgTipo := "3"
		Eval(_oF3Tipo:bChange)
	ElseIf (_oPgF3:cTrbTree)->TIPO == "2"
		_cPgTipo := "2"
		Eval(_oF3Tipo:bChange)
	EndIf

Return cRet

//---------------------------------------------------------------------
/*/{Protheus.doc} AbreEmpresa
Função para abrir a empresa 99 e filial 01

@author Vitor Emanuel Batista
@since 04/03/2010
@version MP10
@return Nil
@obs Função utilizada exclusivamente para testes
/*/
//---------------------------------------------------------------------
Static Function AbreEmpresa(oWnd)
	Local lOpen  := .F.
	Local cModPG := If( __nModPG == 19, "MNT", If( __nModPG == 35, "MDT", "SGA" ) )
	Local aTable := {}

	//Abre tabelas necessarias
	If Type("oMainWnd")!="O"

		Private cAcesso := ""
		Private cPaisLoc:= ""

		PtSetTheme("MDI")
	  	//SetStyle(5)

	  	PUBLIC oMainWnd := oWnd
		PUBLIC cEmpAnt  := '99' //'T2'
		PUBLIC cFilAnt  := '01' //'L MG 01 '

		PUBLIC __TTSINUSE  := .T.
		PUBLIC __TTSPUSH   := {}
		PUBLIC __CLOGSIGA  := ""

		RPCSetType(3) //Nao utiliza licensa

		//Abre empresa/filial/modulo/arquivos
		RPCSetEnv(cEmpAnt,cFilAnt,"","",cModPG,"",aTable)

		lOpen := .T.
	EndIf

Return lOpen

//---------------------------------------------------------------------
/*/{Protheus.doc} GetKeys
Carregar aKeys com as Teclas de Entrada

@author Vitor Emanuel Batista
@since 14/05/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function GetKeys()

	Local aKeys := Array( 18 )

	aKeys[01] := SetKey( VK_F2    , NIL )
	aKeys[02] := SetKey( VK_F3    , NIL )
	aKeys[03] := SetKey( VK_F4    , NIL )
	aKeys[04] := SetKey( VK_F5    , NIL )
	aKeys[05] := SetKey( VK_F6    , NIL )
	aKeys[06] := SetKey( VK_F7    , NIL )
	aKeys[07] := SetKey( VK_F8    , NIL )
	aKeys[08] := SetKey( VK_F9    , NIL )
	aKeys[09] := SetKey( VK_F10   , NIL )
	aKeys[10] := SetKey( VK_F11   , NIL )
	aKeys[11] := SetKey( VK_F12   , NIL )
	aKeys[12] := SetKey( K_CTRL_O , NIL )
	aKeys[13] := SetKey( K_CTRL_X	 , NIL )
	aKeys[14] := SetKey( K_CTRL_S	 , NIL )
	aKeys[15] := SetKey( K_CTRL_F	 , NIL )
	aKeys[16] := SetKey( K_CTRL_L	 , NIL )
	aKeys[17] := SetKey( K_CTRL_A , NIL )
	aKeys[18] := SetKey( K_CTRL_E , NIL )

Return( aClone( aKeys ) )

//---------------------------------------------------------------------
/*/{Protheus.doc} RestKeys
Restaurar as Teclas de Entrada Obtidas Atraves da GetKeys()

@param aKeys Vetor com o conteudo das teclas
@param lSetKey Chama SetKey independete se tem conteúdo no aKeys
@author Vitor Emanuel Batista
@since 14/05/2010
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function RestKeys( aKeys , lSetKey )

	DEFAULT aKeys	:= Array( 18 )
	DEFAULT lSetKey	:= .F.

	IF( !Empty( aKeys[01] ) .Or. lSetKey , SetKey( VK_F2    , aKeys[01]  ) , NIL )
	IF( !Empty( aKeys[02] ) .Or. lSetKey , SetKey( VK_F3    , aKeys[02]  ) , NIL )
	IF( !Empty( aKeys[03] ) .Or. lSetKey , SetKey( VK_F4    , aKeys[03]  ) , NIL )
	IF( !Empty( aKeys[04] ) .Or. lSetKey , SetKey( VK_F5    , aKeys[04]  ) , NIL )
	IF( !Empty( aKeys[05] ) .Or. lSetKey , SetKey( VK_F6    , aKeys[05]  ) , NIL )
	IF( !Empty( aKeys[06] ) .Or. lSetKey , SetKey( VK_F7    , aKeys[06]  ) , NIL )
	IF( !Empty( aKeys[07] ) .Or. lSetKey , SetKey( VK_F8    , aKeys[07]  ) , NIL )
	IF( !Empty( aKeys[08] ) .Or. lSetKey , SetKey( VK_F9    , aKeys[08]  ) , NIL )
	IF( !Empty( aKeys[09] ) .Or. lSetKey , SetKey( VK_F10   , aKeys[09]  ) , NIL )
	IF( !Empty( aKeys[10] ) .Or. lSetKey , SetKey( VK_F11   , aKeys[10]  ) , NIL )
	IF( !Empty( aKeys[11] ) .Or. lSetKey , SetKey( VK_F12   , aKeys[11]  ) , NIL )
	IF( !Empty( aKeys[12] ) .Or. lSetKey , SetKey( K_CTRL_O , aKeys[12]  ) , NIL )
	IF( !Empty( aKeys[13] ) .Or. lSetKey , SetKey( K_CTRL_X , aKeys[13]  ) , NIL )
	IF( !Empty( aKeys[14] ) .Or. lSetKey , SetKey( K_CTRL_S , aKeys[14]  ) , NIL )
	IF( !Empty( aKeys[15] ) .Or. lSetKey , SetKey( K_CTRL_F , aKeys[15]  ) , NIL )
	IF( !Empty( aKeys[16] ) .Or. lSetKey , SetKey( K_CTRL_L , aKeys[16]  ) , NIL )
	IF( !Empty( aKeys[17] ) .Or. lSetKey , SetKey( K_CTRL_A , aKeys[17]  ) , NIL )
	IF( !Empty( aKeys[18] ) .Or. lSetKey , SetKey( K_CTRL_E , aKeys[18]  ) , NIL )

Return( NIL )

//---------------------------------------------------------------------
/*/{Protheus.doc} CSSButton
Função que retorna CSS personalizado para a classe TButton

@param lFocal Indica que o botao sera Focal
@author Vitor Emanuel Batista
@since 11/03/2011
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Function CSSButton(lFocal)
	Local cButton := ""

	Default lFocal := .F.

	lImg := Len(GetResArray("fwstd_btn_focal.png")) > 0

	cButton := "QPushButton { font: bold }"

	If lImg
		If lFocal
			cButton += "QPushButton { border-image: url(rpo:fwstd_btn_focal.png) 3 3 3 3 stretch }"
			cButton += "QPushButton { color: #FFFFFF } "
		Else
			cButton += "QPushButton { border-image: url(rpo:fwstd_btn_nml.png) 3 3 3 3 stretch }"
			cButton += "QPushButton { color: #024670 } "
		EndIf
	Else
		cButton += "QPushButton { color: #024670 } "
	EndIf
	cButton += "QPushButton { border-top-width: 3px }"
	cButton += "QPushButton { border-left-width: 3px }"
	cButton += "QPushButton { border-right-width: 3px }"
	cButton += "QPushButton { border-bottom-width: 3px }"

	If lImg
		cButton += "QPushButton:pressed { color: #FFFFFF } "
		If lFocal
			cButton += "QPushButton:pressed { border-image: url(rpo:fwstd_btn_focal_dld.png) 3 3 3 3 stretch }"
		Else
			cButton += "QPushButton:pressed { border-image: url(rpo:fwstd_btn_prd.png) 3 3 3 3 stretch }"
		EndIf
	EndIf

	cButton += "QPushButton:pressed { border-top-width: 3px }"
	cButton += "QPushButton:pressed { border-left-width: 3px }"
	cButton += "QPushButton:pressed { border-right-width: 3px }"
	cButton += "QPushButton:pressed { border-bottom-width: 3px }"
Return cButton

//---------------------------------------------------------------------
/*/{Protheus.doc} RetFiliais
Função que retorna as filiais para montem da Planta Gráfica no modo
Visualização.

@author Vitor Emanuel Batista
@since 22/03/2011
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function RetFiliais(lEditMode)
	Local aArea := SM0->(GetArea())
	Local aFilial := {cFilAnt}

	If NGSX2MODO("TAF") == "E" .And. !lEditMode .And. GetNewPar("MV_NGALMUL","0") == "1"

		dbSelectArea("SM0")
		dbSetOrder(1)
		dbSeek(cEmpAnt)
		While !Eof() .And. cEmpAnt == SM0->M0_CODIGO

			dbSelectArea("TAF")
			dbSetOrder(1)
			If cFilAnt != SubStr(xFilial("TAF",SM0->M0_CODFIL),1,__nSizeFil) .And. dbSeek(SubStr(xFilial("TAF",SM0->M0_CODFIL),1,__nSizeFil))
				aAdd(aFilial,SubStr(xFilial("TAF",SM0->M0_CODFIL),1,__nSizeFil))
			EndIf

			dbSelectArea("SM0")
			dbSkip()
		EndDo
	EndIf

	//---------------------------------------
	// Ordena de forma crescente pelo codigo
	//---------------------------------------
	aSort(aFilial)

	RestArea(aArea)
Return aFilial
//---------------------------------------------------------------------
/*/{Protheus.doc} fRetArrMenus
Função que Grava os itens de PopUp para posterior verificacao de
Permissao.

@author Roger Rodrigues
@since 26/05/2011
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fRetArrMenus(oObjeto, cTipo, cOperac)
Local aArray := Array(__aMenuPopUp_Len__)

aArray[__aMenuPopUp_Objeto__]   := oObjeto
aArray[__aMenuPopUp_Tipo__]     := cTipo
aArray[__aMenuPopUp_Operacao__] := cOperac

Return aArray

//---------------------------------------------------------------------
/*/{Protheus.doc} InsertLinux
Função que adiciona "l:" ao inicio de um diretório quando for necessário
para o Linux.

@author Antonio Hardt da Mota
@since 22/04/2013
@version MP11
@return cDir
/*/
//---------------------------------------------------------------------
Static Function InsertLinux(cDir)

	//Verifica se é linux para tratar o caminho
	If GetRemoteType() == REMOTE_QT_LINUX .and. At(":",cDir)==0
		cDir := "l:" + cDir   //Adiciona "l:" ao inicio do caminho
	EndIf

Return cDir

//---------------------------------------------------------------------
/*/{Protheus.doc} RemoveLinux
Função que retira o "l:" do inicio de um diretório quando for necessário
para o Linux.

@author Antonio Hardt da Mota
@since 22/04/2013
@version MP11
@return cDir
/*/
//---------------------------------------------------------------------
Static Function RemoveLinux(cDir)

	//Verifica se é linux para tratar o caminho
	If GetRemoteType() == REMOTE_QT_LINUX .And. 'l:' $ cDir
		cDir :=SubStr(cDir,3)//Remove o "l:" do inicio do caminho
	EndIf

Return cDir

//---------------------------------------------------------------------
/*/{Protheus.doc} fMontaTrb
Preenche os arrays com os campos e indices da TRB.

@param lCampo - Indica se sera retornado o array de campos
@author Lucas Guszak
@since 29/10/2013
@version MP11
@return aValores
/*/
//---------------------------------------------------------------------
Static Function fMontaTrb(lCampo)

	Local nTamTipo 	:= If( __nModPG == 56, TamSX3("TAX_CODRES")[1], 15)
	Local nTamAmb 	:= TamSX3("TNE_CODAMB")[1]
	Local nTamRes 	:= TamSX3("QAA_MAT")[1]
	Local nTamDpt 	:= TamSX3("QB_DEPTO")[1]
	Local aValores 	:= {}
	Local lRateio 	:= NGCADICBASE('TAF_RATEIO','D','TAF',.F.)
	Local lEtapa  	:= NGCADICBASE('TAF_ETAPA' ,'D','TAF',.F.)
	Local lCodAmb 	:= NGCADICBASE('TAF_CODAMB','D','TAF',.F.)
	Local lDepto 	:= NGCADICBASE('TAF_DEPTO' ,'D','TAF',.F.)
	Default lCampo 	:= .T.

	If lCampo
		aAdd(aValores,{"FILIAL"   , "C", __nSizeFil, 0})
		aAdd(aValores,{"CODEST"   , "C", 03, 0})
		aAdd(aValores,{"CODPRO"   , "C", 03, 0})
		aAdd(aValores,{"DESCRI"   , "C", 56, 0})
		aAdd(aValores,{"NIVSUP"   , "C", 03, 0})
		aAdd(aValores,{"RESPONS"  , "C", nTamRes, 0})
		aAdd(aValores,{"TIPO"     , "C", 01, 0})
		aAdd(aValores,{"CODTIPO"  , "C", Max(nTamTipo, 16), 0})
		aAdd(aValores,{"CC"       , "C", TAMSX3("CTT_CUSTO")[1], 0})
		aAdd(aValores,{"CENTRAB"  , "C", 06, 0})
		aAdd(aValores,{"DOCFIL"   , "C", 02, 0})
		aAdd(aValores,{"MODSGA"   , "C", 01, 0})
		aAdd(aValores,{"MODMNT"   , "C", 01, 0})
		aAdd(aValores,{"MODMDT"   , "C", 01, 0})
		aAdd(aValores,{"ORDEM"    , "C", 03, 0})
		aAdd(aValores,{"DELETADO" , "C", 01, 0})
		aAdd(aValores,{"NIVEL"    , "N", 02, 0})
		aAdd(aValores,{"CARGO"    , "C", 06, 0})
		aAdd(aValores,{"PLANTA"   , "C", 01, 0})
		aAdd(aValores,{"TIPIMG"   , "C", 01, 0})
		aAdd(aValores,{"IMAGEM"   , "C", 25, 0})
		aAdd(aValores,{"POSX"     , "N", 04, 0})
		aAdd(aValores,{"POSY"     , "N", 04, 0})
		aAdd(aValores,{"TAMX"     , "N", 07, 2})
		aAdd(aValores,{"TAMY"     , "N", 07, 2})
		aAdd(aValores,{"MOVBLO"   , "C", 01, 0})
		aAdd(aValores,{"PGSUP"    , "C", 03, 0})

		If __nModPG == 19
			aAdd(aValores,{"EVENTO"   ,"C", 150, 0})
		ElseIf __nModPG == 35
			aAdd(aValores,{"EVEMDT"   ,"C", 150, 0})
		ElseIf __nModPG == 56
			aAdd(aValores,{"EVESGA"   ,"C", 150, 0})
			aAdd(aValores,{"SEQUEN"   ,"C", 003, 0})
		EndIf

		aAdd(aValores,{"PERMISS"  , "L", 01, 0})

		If lRateio
			aAdd(aValores,{"RATEIO"   ,"C", 01, 0})
		Endif

		If lEtapa
			aAdd(aValores,{"ETAPA"    ,"C", 01, 0})
		EndIf

		If lCodAmb
			aAdd(aValores,{"CODAMB"   , "C", nTamAmb, 0})
		EndIf

		If lDepto
			aAdd(aValores,{"DEPTO"    , "C", nTamDpt, 0})
		EndIf

	Else

		aValores := {{"CODEST","NIVSUP"},;
					 {"CODEST","CODPRO","FILIAL","ORDEM"},;
				     {"TIPO","CODTIPO","NIVSUP"},;
				     {"CODEST","NIVSUP","ORDEM"},;
				     {"CODEST","NIVEL","ORDEM"},;
				     {"CODEST","PGSUP"}}

		If lCodAmb
			aAdd(aValores, {"CC", "CODAMB", "FILIAL"})
		Else
			aAdd(aValores, {"CC", "FILIAL"})
		EndIf

		If __nModPG == 56
			aAdd(aValores[3], "SEQUEN") // Adiciona campo especifico de sequencia ()
		Endif

	EndIf

Return aValores

//---------------------------------------------------------------------
/*/{Protheus.doc} NGFILTST9()
Filtra os bens da consulta padrao, somente serao apresentados os bens que
ainda não foram cadastrados na Tree.

@param cCodigoST9 - Codigo do bem na consulta padrao
@author Lucas Guszak
@since 30/10/2013
@version MP11
@return lMostra
/*/
//---------------------------------------------------------------------
Function NGFILTST9(cCodigoST9)

	Local aAreaTemF := GetArea()

	Local lMostra := .T.

	dbSelectArea(__cTrbTree)
	dbSetOrder(3)
	If dbSeek("1"+cCodigoST9) .And. Empty((__cTrbTree)->DELETADO)
		If (__cTrbTree)->PGSUP != cPlantaSup
			lMostra := .F.
		EndIf
	EndIf

	RestArea(aAreaTemF)

Return lMostra

//---------------------------------------------------------------------
/*/{Protheus.doc}  NGSUBNIV()
Filtra Trb, contem somente os itens que podem ser represtados graficamente
através do nivel selecionado na Tree.

@author Lucas Guszak
@since 30/10/2013
@version MP11
@return
/*/
//---------------------------------------------------------------------
Function NGSUBNIV()

	//Verifica se existem niveis abaixo da planta superior
	DbSelectArea(__cTrbTree)
	DbSetOrder(1)
	If !DbSeek("001"+cPlantaSup)
		MsgAlert(STR0400)//"Somente poderão ser inclusas representações gráficas de ilustrações e bens para o último nível sendo uma planta."
		RestArea(aGetTrbTre)
		Return .F.
	EndIf

	//Verifica a existencia da TRB
	If Select(__cTrbNivF3) == 0

		//Recebe os mesmos campos do que a Tree do __cTrbTree
		aCampos := fMontaTrb(.T.)

		//Recebe os mesmos indices do que a Tree do __cTrbTree
		aIndex	:= fMontaTrb(.F.)

		//Atribui um alias para a TRB da consulta especial
		__cTrbNivF3 := GetNextAlias()

		// Cria TRB que ira conter os itens da consulta especial
		oArqNiv   := NGFwTmpTbl(__cTrbNivF3,aCampos,aIndex)

	Else

		//Posiciona na TRB da consulta
		dbSelectArea(__cTrbNivF3)

		//Limpa a trb, preparando-a para uma nova consulta
		ZAP

	EndIf

	//Restaura a Tree Geral
	RestArea(aGetTrbTre)

	//Grava na TRB as informçoes referentes a planta superior
	FGRVTRBNIV()

	//Adiciona somente os itens que são filhos da planta superior
	DbSelectArea(__cTrbTree)

	//Ordena pelo codigo da planta superior
	DbSetOrder(6)

	//Posiciona na tabela conforme o codigo da planta superior
	If DbSeek("001"+cPlantaSup)

		//Enquanto a planta superior for igual ao codigo da planta
		While !eof() .And. (__cTrbTree)->PGSUP == cPlantaSup

			//Grava os niveis abaixo ao da planta
			FGRVTRBNIV()

			//Proximo registro da tree geral
			(__cTrbTree)->(DbSkip())

		End

	EndIf

Return NGTAFMNT2(__cTrbNivF3,cPaiSelect,__cTrbTree)

//---------------------------------------------------------------------
/*/{Protheus.doc} fGrvTrbNiv()
Grava na Trb da consulta padrão especial.

@author Lucas Guszak
@since 30/10/2013
@version MP11
@return
/*/
//---------------------------------------------------------------------
Static Function FGRVTRBNIV()

	Local lRateio := NGCADICBASE('TAF_RATEIO','D','TAF',.F.)
	Local lEtapa  := NGCADICBASE('TAF_ETAPA','D','TAF',.F.)
	Local lCodAmb := NGCADICBASE('TAF_CODAMB','D','TAF',.F.)
	Local lDepto  := NGCADICBASE('TAF_DEPTO' ,'D','TAF',.F.)

	RecLock(__cTrbNivF3,.T.)
	(__cTrbNivF3)->FILIAL	:= (__cTrbTree)->FILIAL
	(__cTrbNivF3)->CODEST	:= (__cTrbTree)->CODEST
	(__cTrbNivF3)->CODPRO	:= (__cTrbTree)->CODPRO
	(__cTrbNivF3)->DESCRI	:= (__cTrbTree)->DESCRI
	(__cTrbNivF3)->NIVSUP	:= (__cTrbTree)->NIVSUP
	(__cTrbNivF3)->RESPONS	:= (__cTrbTree)->RESPONS
	(__cTrbNivF3)->TIPO		:= (__cTrbTree)->TIPO
	(__cTrbNivF3)->CODTIPO	:= (__cTrbTree)->CODTIPO
	(__cTrbNivF3)->CC			:= (__cTrbTree)->CC
	(__cTrbNivF3)->CENTRAB	:= (__cTrbTree)->CENTRAB
	(__cTrbNivF3)->DOCFIL	:= (__cTrbTree)->DOCFIL
	(__cTrbNivF3)->MODSGA	:= (__cTrbTree)->MODSGA
	(__cTrbNivF3)->MODMNT	:= (__cTrbTree)->MODMNT
	(__cTrbNivF3)->MODMDT	:= (__cTrbTree)->MODMDT
	(__cTrbNivF3)->ORDEM	:= (__cTrbTree)->ORDEM
	(__cTrbNivF3)->DELETADO	:= (__cTrbTree)->DELETADO
	(__cTrbNivF3)->NIVEL	:= (__cTrbTree)->NIVEL
	(__cTrbNivF3)->CARGO	:= (__cTrbTree)->CARGO
	(__cTrbNivF3)->PLANTA	:= (__cTrbTree)->PLANTA
	(__cTrbNivF3)->TIPIMG	:= (__cTrbTree)->TIPIMG
	(__cTrbNivF3)->IMAGEM	:= (__cTrbTree)->IMAGEM
	(__cTrbNivF3)->POSX		:= (__cTrbTree)->POSX
	(__cTrbNivF3)->POSY		:= (__cTrbTree)->POSY
	(__cTrbNivF3)->TAMX		:= (__cTrbTree)->TAMX
	(__cTrbNivF3)->TAMY		:= (__cTrbTree)->TAMY
	(__cTrbNivF3)->MOVBLO	:= (__cTrbTree)->MOVBLO
	(__cTrbNivF3)->PGSUP	:= (__cTrbTree)->PGSUP
	If __nModPG == 19
		(__cTrbNivF3)->EVENTO	:= (__cTrbTree)->EVENTO
	ElseIf __nModPG == 35
		(__cTrbNivF3)->EVEMDT	:= (__cTrbTree)->EVEMDT
	EndIf
	(__cTrbNivF3)->PERMISS	:= (__cTrbTree)->PERMISS
	If lRateio
		(__cTrbNivF3)->RATEIO	:= (__cTrbTree)->RATEIO
	Endif
	If lEtapa
		(__cTrbNivF3)->ETAPA	:= (__cTrbTree)->ETAPA
	EndIf
	If lCodAmb
		(__cTrbNivF3)->CODAMB:= (__cTrbTree)->CODAMB
	EndIf
	If lDepto
		(__cTrbNivF3)->DEPTO	:= (__cTrbTree)->DEPTO
	EndIf
	MsUnlock(__cTrbNivF3)

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} ImportBens()
Monta um MarkBrowse com informações referente a importação dos bens
por centro de custo.

@author Elynton Fellipe Bazzo
@since 04/02/2014
@return .T.
/*/
//---------------------------------------------------------------------
Method ImportBens() Class TNGPG

	Local oPanelInf, oMark
	Local aArea		:= GetArea()
	Local lInverte	:= .F.
	Local cTipo		:= Substr(::oTree:GetCargo(),4,3)

	If cTipo == "LOC" // Se o objeto selecionado for uma LOCALIZAÇÃO.

		Private cTRBBEM := GetNextAlias()
		Private oArqTrab2
		Private oNomCCusto
		Private lPrimTRB 	:= .F. // Variável que controla a TRB.
		Private cMarca 		:= GetMark()
		Private oMarkPG
		Private cCCusto 	:= Space( Len( CTT->CTT_CUSTO ))  // Codigo do Centro de Custo
		Private cNomeCCusto := Space( Len( CTT->CTT_DESC01 )) // Nome do Centro de Custo

		aDBF2 := {}
			aAdd(aDBF2,{"OK"   	 	, "C", 02, 0})
			aAdd(aDBF2,{"TRB_BEM"	, "C", 16, 0})
			aAdd(aDBF2,{"TRB_NOMBEM", "C", 40, 0})
			aAdd(aDBF2,{"TRB_SITBEM", "C", 01, 0})

		//Cria TRB
		oArqTrab2 := NGFwTmpTbl(cTRBBEM,aDBF2,{{ "TRB_BEM" }})

		aTRB1 := {}
			aAdd(aTRB1,{"OK"   		, NIL, " "	   ,	 })
			aAdd(aTRB1,{"TRB_BEM"	, NIL, STR0404 ,"@!" }) //"Bem"
			aAdd(aTRB1,{"TRB_NOMBEM", NIL, STR0405 ,"@!" }) //"Nome do Bem"

		DEFINE MSDIALOG oDlg FROM 0,0 To 400,650 TITLE STR0406 OF oMainWnd PIXEL //"Importação de Bens"

			//Painel de Campos
			oPanelInf := TPanel():New(00,00,,oDlg,,,,,,0,0,.F.,.F.)
			oPanelInf:Align := CONTROL_ALIGN_ALLCLIENT

			@ 11,004 Say OemToAnsi( STR0407 ) Size 37,7 Of oPanelInf Pixel //"Centro Custo"

			@ 10,043 MsGet cCCusto Size 115,08 Of oPanelInf Pixel Picture "@!" Valid ExistCpo( "CTT", cCCusto ) .And. TNGPGTRB( cCCusto,aBensPG );
																												 F3 "CTT" HasButton // Campo "C.C"

			@ 11,158 Say OemToAnsi( STR0408 ) Size 34,7 Of oPanelInf Pixel //"Nome"

			@ 10,176 MsGet oNomCCusto Var SubStr(cNomeCCusto,1,28) Size 147,08 Of oPanelInf Pixel When .F. // Campo "Nome"

			//Monta o objeto gráfico tipo "Grid" contemplando a opção de  marcação.
			oMarkPG := MsSelect():NEW((cTRBBEM),"OK",,aTRB1,@lInverte,@cMarca,{50,00,189,343},,,oPanelInf,,)
			oMarkPG:bMARK := {|| AllwaysTrue()} //Grava marca em todos os registros validos.
			oMarkPG:oBrowse:lHASMARK	:= .T.
			oMarkPG:oBrowse:lCANALLMARK	:= .T.
			oMarkPG:oBrowse:bALLMARK	:= {|| TNGPGINV( cMarca ) } // Chamada da função que executa no duplo clique em um elemento no browse.
			oMarkPG:oBrowse:ALIGN       := CONTROL_ALIGN_BOTTOM

			Dbselectarea(cTRBBEM)
			DbGotop()
		Activate MsDialog oDlg ON INIT EnchoiceBar( oDlg, {|| MNTGRVTRB( Self ), oDlg:End() }, {|| oDlg:End() }) Centered

		Dbselectarea(cTRBBEM)
		oArqTrab2:Delete() //Deleta Tabela Temporária Browse.

	Else

		MsgAlert( STR0411 ) //"A importação não poderá ser realizada para um bem. Favor selecionar uma localização."

	EndIf

	RestArea( aArea ) // Retorna à area de trabalho.

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} OperRisTree()

Metodo para operações do risco, sejam elas, inclusão, alteração ou ex-
clusão.

@param
@author Guilherme Benkendorf
@since 26/06/2014
@return .T.
/*/
//---------------------------------------------------------------------
Method OperRisTree( nOpcRis, lRelRis ) Class TNGPG
	Local cCodEst  := "001"
	Local cLocal   := SubStr( ::oTree:GetCargo(), 1, 3 )
	Local cTipo	   := Substr(::oTree:GetCargo(),4,3)
	Local cDescri  := ""
	Local aAreaRis := GetArea()
	Local lExclui  := .F.
	Local lCodAmb  := NGCADICBASE('TAF_CODAMB','D','TAF',.F.)

	Default lRelRis := .F.

	::SetBlackPnl(.T.)

	dbSelectArea(::cTRBTree)
	dbSetOrder( 2 )// CODEST+CODPRO+FILIAL+ORDEM
	dbSeek(cCodEst+cLocal+cFilAnt)
	//Posiciona o Risco
	dbSelectArea( "TN0" )
	dbSetOrder( 1 )//TN0_FILIAL+TN0_NUMRIS
	dbSeek( xFilial( "TN0" ) + SubStr( (::cTRBTree)->CODTIPO, 1 , Len(TN0->TN0_NUMRIS) ) )

	If lRelRis
		MDT181REL(4)
	Else

		If ValRisMNT902( nOpcRis, ::oTree, ::cTRBTree )

			If nOpcRis == 5 .And. MsgYesNo(STR0017) .And. VerifRis(::cTRBTree) //"Tem certeza de que deseja excluir este item?"
				lExclui := .T.
				cNumRis := TN0->TN0_NUMRIS
			EndIf

			aRotSetOpc( "TN0" , 0 , nOpcRis )

			If ( lExclui .Or. nOpcRis <> 5 ) .And. D180INCL("TN0",TN0->(Recno()),nOpcRis,::cTRBTree) > 0
				//Faz a Exclusão da Arvore ( TAF )
				If lExclui
					::DeleteItem()
					dbSelectArea( "TAF" )
					dbSetOrder( 10 )//TAF_FILIAL+TAF_INDCON+TAF_CODCON+TAF_MODMNT+TAF_MODMDT+TAF_MODSGA
					If dbSeek( xFilial( "TAF" ) + "7" + PADR( cNumRis, Len(TAF->TAF_CODCON) ) + " X " )
						TAF->( RecLock( "TAF", .F. ) )
						TAF->( dbDelete() )
						TAF->( MsUnLock() )
					EndIf
				EndIf

				If nOpcRis == 3
					cNumRis := TN0->TN0_NUMRIS
					dbSelectArea( "TAF" )
					dbSetOrder( 10 )//TAF_FILIAL+TAF_INDCON+TAF_CODCON+TAF_MODMNT+TAF_MODMDT+TAF_MODSGA
					// Inclui nivel na arvore logica quando nao foi ja adcionada a estrutura e a data de avalicao deve estar preenchida
					If dbSeek( xFilial( "TAF" ) + "7" + PADR( TN0->TN0_NUMRIS, Len(TAF->TAF_CODCON) ) + " X " )

						//Incluindo o Risco na estrutura temporaria da Arvore

						dbSelectArea(::cTrbTree)
						RecLock(::cTrbTree,.T.)
						(::cTrbTree)->FILIAL  := cFilAnt
						(::cTrbTree)->CODEST  := cCodEst
						(::cTrbTree)->CODPRO  := TAF->TAF_CODNIV
						(::cTrbTree)->DESCRI  := TAF->TAF_NOMNIV
						(::cTrbTree)->NIVSUP  := TAF->TAF_NIVSUP
						(::cTRBTree)->CODTIPO := cNumRis
						(::cTrbTree)->RESPONS := TAF->TAF_MAT
						(::cTrbTree)->CC      := TAF->TAF_CCUSTO
						(::cTrbTree)->CENTRAB := TAF->TAF_CENTRA
						(::cTrbTree)->DOCFIL  := ""
						(::cTrbTree)->TIPO    := TAF->TAF_INDCON
						If __nModPG == 19
							(::cTrbTree)->MODMNT  := TAF->TAF_MODMNT
						ElseIf __nModPG == 35
							(::cTrbTree)->MODMDT  := TAF->TAF_MODMDT
						ElseIf __nModPG == 56
							(::cTrbTree)->MODSGA  := TAF->TAF_MODSGA
						EndIf
						(::cTrbTree)->ORDEM	 := TAF->TAF_ORDEM
						(::cTrbTree)->NIVEL   := TAF->TAF_NIVEL
						(::cTrbTree)->CARGO   := "RIS"
						(::cTrbTree)->PLANTA  := TAF->TAF_PLANTA
						(::cTrbTree)->PGSUP   := ::cPlantaAtu
						MsUnLock(::cTrbTree)

						// Incluindo o Risco no objeto da Arvore
						cDescri  := TN0->TN0_NUMRIS + " - " + NGSEEK("TMA", TN0->TN0_AGENTE, 1, "TMA_NOMAGE" )

						::oTree:TreeSeek(cLocal+cTipo+cFilAnt)
						::oTree:AddItem(cDescri,TAF->TAF_CODNIV+'RIS'+cFilAnt,'ng_ico_risco','ng_ico_risco',,, 2)
					EndIf
				EndIf
			EndIF
			If nOpcRis <> 2
				//-----------------------------------------------------------------
				// Identifica que a planta teve alterações e necessita ser salva
				//-----------------------------------------------------------------
				::lModified := .T.
			EndIf
		EndIf

	EndIf

::SetBlackPnl(.F.)

RestArea( aAreaRis )

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} OperFunTar()

Metodo para operações da função e tarefa, sejam elas, inclusão, alteração
ou exclusão.

@param nOpc - Tipo de operação
@param cOpe - Indica se é Função ou Tarefa ("FUN"/"TAR")
@author Guilherme Benkendorf
@since 02/07/2014
@return .T.
/*/
//---------------------------------------------------------------------
Method OperFunTar( nOpc, cOpe ) Class TNGPG

If MNT902OREL( nOpc , cOpe, ::oTree, ::cTrbTree )
	If nOpc == 3 .Or. nOpc == 4
		RecLock(::cTrbTree,.F.)
		(::cTrbTree)->PLANTA  := "2"
		(::cTrbTree)->PGSUP   := ::cPlantaAtu
		MsUnLock()
		If FindFunction("Soma1Old")
			::cCodNiv := Soma1Old(AllTrim(::cCodNiv))
		Else
			::cCodNiv := Soma1(AllTrim(::cCodNiv))
		EndIf
	ElseIf nOpc == 5
		If MsgYesNo(STR0017)//"Tem certeza de que deseja excluir este item?"
			::DeleteItem()
		EndIf
	EndIf
	//-----------------------------------------------------------------
	// Identifica que a planta teve alterações e necessita ser salva
	//-----------------------------------------------------------------
	::lModified := .T.
EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} SgaResOpr( cCCusto )
Verifica se é possível excluir o resíduo da planta.

@author Gabriel Werlich
@since 04/02/2014
/*/
//---------------------------------------------------------------------
Method SgaResOpr( nOpc ) Class TNGPG

	Local lValOk		:= .T.
	Local cMsgErro	:= ""

	If TAV->(Eof())
		Return .T.
	Endif

	dbSelectArea("TBJ")
	dbSetOrder(1) // TBJ_FILIAL+TBJ_CODOCO+TBJ_CODEST+TBJ_CODNIV

	dbSelectArea("TB0")
	dbSetOrder(2) // TB0_FILIAL+TB0_CODRES
	dbSeek(xFilial("TB0") + TAV->TAV_CODRES )
	While !Eof() .And. TB0->TB0_FILIAL == xFilial("TB0") .And. TAV->TAV_CODRES == TB0->TB0_CODRES

		If TBJ->( dbSeek( xFilial("TBJ") + TB0->TB0_CODOCO + "001" + TAV->TAV_CODNIV ) )
			cMsgErro := STR0509 //"Existem ocorrências de resíduo vinculadas ao resíduo."
			lValOk := .F.
			Exit
		Endif

		dbSelectArea("TBJ")
		dbSkip()
	End

	If lValOk
		dbSelectArea("TDC")
		dbSetOrder(3) // TDC_FILIAL+TDC_CODRES+TDC_DEPTO+TDC_STATUS
		If dbSeek(xFilial("TDC") + TAV->TAV_CODRES + TAV->TAV_CODNIV )
			cMsgErro := STR0510//"Existem FMRs vinculadas ao resíduo."
			lValOk := .F.
		Endif
	Endif

	If !lValOk
		ShowHelpDlg( STR0348, {cMsgErro}, 1, {STR0511}, 1 ) //"Verifique a tabela relacionada."
		Return .F.
	Endif

	If lValOk
		::DeleteItem()
	Endif

Return lValOk

//---------------------------------------------------------------------
/*/{Protheus.doc} SgaAspOpr( cCCusto )
Verifica se é possível excluir o aspecto da planta.

@author Gabriel Werlich
@since 04/02/2014
/*/
//---------------------------------------------------------------------
Method SgaAspOpr( nOpc ) Class TNGPG

	Local lValOk		:= .T.
	Local cMsgErro		:= ""

	If TAG->(Eof())
		Return .T.
	Endif

	dbSelectArea("TAB")
	dbSetOrder(6) // TAB_FILIAL+TAB_CODEST+TAB_CODNIV+TAB_CODASP+TAB_CODIMP
	If dbSeek(xFilial("TAB") + "001" + TAG->TAG_CODNIV + TAG->TAG_CODASP )
		cMsgErro := STR0512 //"Existem avaliações de desempenho vinculados ao aspecto."
		lValOk := .F.
	Endif

	If !lValOk
		ShowHelpDlg( STR0348 , {cMsgErro}, 1, {STR0511}, 1 ) //"Verifique a tabela relacionada."
		Return .F.
	Endif

	If lValOk
		::DeleteItem()
	Endif

Return lValOk

//---------------------------------------------------------------------
/*/{Protheus.doc} TNGPGTRB( cCCusto )
Função que executa o Gatilho preenchendo o nome do Centro de Custo e
carrega os valores na TRB.

@author Elynton Fellipe Bazzo
@since 04/02/2014
/*/
//---------------------------------------------------------------------
Static Function TNGPGTRB( cCCusto,aBensPG )

	Local lBemTAF := .T. //Variável que verifica se o bem está relacionado ao CC ou a uma localização.

	dbSelectArea( "CTT" )
	dbSetOrder( 01 )
	CTT->(dbSeek( xFilial( "CTT" )+cCCusto ))
	cNomeCCusto := CTT->CTT_DESC01 //Atribui o nome do Centro de Custo à variável.
	oNomCCusto:Refresh() //Atualiza o objeto.

	If lPrimTRB // Se foi carregada a TRB no mínimo uma vez.

   		If Type ("oArqTrab2") == "O"
   			Dbselectarea(cTRBBEM)
   			oArqTrab2:Delete()
   		EndIf
   		//Vou recriar a TRB.
   		aDBF2 := {}
			aAdd(aDBF2,{"OK"   	 	, "C", 02, 0})
			aAdd(aDBF2,{"TRB_BEM"	, "C", 16, 0})
			aAdd(aDBF2,{"TRB_NOMBEM", "C", 40, 0})
			aAdd(aDBF2,{"TRB_SITBEM", "C", 01, 0})

		//Cria TRB
		oArqTrab2 := NGFwTmpTbl(cTRBBEM,aDBF2,{{ "TRB_BEM" }})

		aTRB1 := {}
			aAdd(aTRB1,{"OK"   		, NIL, " "	   ,	 })
			aAdd(aTRB1,{"TRB_BEM"	, NIL, STR0404 ,"@!" }) //"Bem"
			aAdd(aTRB1,{"TRB_NOMBEM", NIL, STR0405 ,"@!" }) //"Nome do Bem"
	EndIf

	dbSelectArea( "ST9" )
	dbSetOrder( 02 ) //T9_FILIAL+T9_CCUSTO+T9_CENTRAB+T9_CODFAMI+T9_CODBEM
	dbSeek( xFilial( "ST9" ) + cCCusto )
	While !Eof() .And. xFilial( "ST9" ) == ST9->T9_FILIAL .And. ST9->T9_CCUSTO == cCCusto

		dbSelectArea( "TAF" )
		dbSetOrder( 06 ) //TAF_FILIAL+TAF_MODMNT+TAF_INDCON+TAF_CODCON
		If !dbSeek( xFilial( "TAF" ) + "X" + "1" + ST9->T9_CODBEM )
				dbSelectArea(cTRBBEM)
				dbSetOrder( 01 )
				// Se o bem estiver Ativo no sistema e ainda não foi adicionado em uma localização.
				If !dbSeek( ST9->T9_CODBEM ) .And. ST9->T9_SITBEM == "A" .And. AScan( aBensPG,{|x| x[1] == ST9->T9_CODBEM}) == 0
					RecLock( cTRBBEM, .T. )
					(cTRBBEM)->OK 			:= cMarca
					(cTRBBEM)->TRB_BEM		:= ST9->T9_CODBEM //Código do Bem.
					(cTRBBEM)->TRB_NOMBEM	:= ST9->T9_NOME //Nome do Bem.
					(cTRBBEM)->TRB_SITBEM	:= ST9->T9_SITBEM //Situação do Bem.
					(cTRBBEM)->(MsUnlock())
					lPrimTRB := .T. //verifica se a TRB foi carregada.
					lBemTAF  := .F. //se existe bem relacionado ao CC ou a uma localização.
				EndIf
		EndIf

	    dbSelectArea( "ST9" )
	    dbSkip()
	End While // Fim do While

	If lBemTAF //se não existe bem está relacionado ao CC ou a uma localização.
		MsgAlert( STR0409 ) //"Não existe bem relacionado a uma localização ou vincunlado ao centro de custo informado."
		Return .F.
	EndIf

	DbSelectArea(cTRBBEM)
	DbGoTop()
	oMarkPG:oBrowse:Refresh()

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} TNGPGINV( cMarca )
Inverte a marcação do browse, ao clicar em todos os bens do markbrowse.

@author Elynton Fellipe Bazzo
@since 04/02/2014
@return .T.
/*/
//---------------------------------------------------------------------
Static Function TNGPGINV( cMarca )

	Local aArea := GetArea()

	DbSelectArea(cTRBBEM)
	Dbgotop()
	While !EoF()
		(cTRBBEM)->OK := IF( (cTRBBEM)->OK == "  ", cMarca, "  " )
		dbSelectArea(cTRBBEM)
		dbSkip()
	End While

	oMarkPG:oBrowse:Refresh( .T. ) // Atualiza o objeto.

	RestArea( aArea )

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MNTGRVTRB()
Função que carrega os valores na TRB.

@author Elynton Fellipe Bazzo
@since 04/02/2014
@return aBensPG
/*/
//---------------------------------------------------------------------
Static Function MNTGRVTRB(oPlanta)

	Local nX
	Local nPosShape  := 0
	Local aNovoShape := {}
	Local cCodLoc	 := SubStr( oPlanta:oTree:GetCargo(),1,3 )

	DbSelectArea(cTRBBEM)
	DbGoTop()
	While !EoF() //Percorre a TRB verificando os bens que estão no arq. temporário.

		If !Empty( (cTRBBEM)->OK ) // Se tiver conteúdo.

			aAdd( aBensPG,{ (cTRBBEM)->TRB_BEM,(cTRBBEM)->TRB_NOMBEM } ) //Adiciona os bens selecionados no array.

			nX := Len( aBensPG )

			aNovoShape := Array( __Len_aShape__ )

			aAdd( oPlanta:aShape,aNovoShape )

			nPosShape := Len( oPlanta:aShape )

			oPlanta:aShape[nPosShape][__aShape_Descri__]  := aBensPG[nX][1]+aBensPG[nX][2]
			oPlanta:aShape[nPosShape][__aShape_Filial__]  := cFilAnt
			oPlanta:aShape[nPosShape][__aShape_Codigo__]  := aBensPG[nX][1]
			oPlanta:aShape[nPosShape][__aShape_IndCod__]  := '1'
			oPlanta:aShape[nPosShape][__aShape_Planta__]  := '2'

			// Campos não usados para este caso, porém de preenchimento obrigatório
			oPlanta:aShape[nPosShape][__aShape_TipoImg__] := ""
			oPlanta:aShape[nPosShape][__aShape_ImgIni__]  := ""
			oPlanta:aShape[nPosShape][__aShape_PosX__]    := 0
			oPlanta:aShape[nPosShape][__aShape_PosY__]    := 0
			oPlanta:aShape[nPosShape][__aShape_Largura__] := 0
			oPlanta:aShape[nPosShape][__aShape_Altura__]  := 0
			oPlanta:aShape[nPosShape][__aShape_Blocked__] := .F.
			oPlanta:aShape[nPosShape][__aShape_Alertas__] := {}

			If oPlanta:aShape[nPosShape][__aShape_Codigo__] == "001"
				oPlanta:aShape[nPosShape][__aShape_NivSup__] := "000"
			Else
				oPlanta:aShape[nPosShape][__aShape_NivSup__] := cCodLoc
			EndIf

			oPlanta:aShape[nPosShape][__aShape_IdShape__] := oPlanta:SetId()

			oPlanta:InsertTree( oPlanta:aShape[nPosShape][__aShape_IdShape__] )

			oPlanta:oTree:TreeSeek( cCodLoc+'LOC'+cFilAnt )

		EndIf

		DbSelectArea(cTRBBEM)
		DbSkip()

	End While

	//-----------------------------------------------------------------
	// Identifica que a planta teve alterações e necessita ser salva
	//-----------------------------------------------------------------
	oPlanta:lModified := .T.

Return aBensPG

//---------------------------------------------------------------------
/*/{Protheus.doc} fChgeSZShape
Calcula percentagem do shape baseado na razão de área inicial por área final

@param Integer nAreaIni: área inicial do shape
@param Integer nPorcent: variável por referência (percentagem)
@param Integer nAreaAtu: área final do shape

@author André Felipe Joriatti
@since 21/02/2014
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------

Static Function fChgeSZShape( nAreaIni,nPorcent,nAreaAtu )

	nPorcent := ( nAreaAtu * 100 ) / nAreaIni

Return Nil
//---------------------------------------------------------------------
/*/{Protheus.doc} MDTSXBPG
Função para a consulta padrão do risco

@author Guilherme Benkendorf
@since 05/06/2014
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDTSXBPG()

	Local oDlgRis
	Local oPnlPesq
	Local oPnlRis

	Local oComboRis
	Local oGetRis
	Local oButRis
	Local oGroupRis
	Local bConfirm
	Local bCancel

	Local lRet := .F.

	Local cTitRis := AllTrim(NGRETTITULO("TN0_NUMRIS"))
	Local cResult := Space( 60 )
	Local cKeyRis := ""

	Local aRiscos := {}
	Local aColLis := {}
	Local aCamLis := { "TN0_NUMRIS" , "TMA_AGENTE", "TN0_DTAVAL" }
	Local aArea   := GetArea()

	Local nx := 0
	//-----------------------------------------
	//Busca os Riscos que poderam ser exibidos
	//-----------------------------------------
	aRiscos := fBuscaRisco()

	//------------------------------------------
	//Define o cabeçalho do FWBrowse
	//------------------------------------------
	For nX := 1 To Len(aCamLis)//Percorre array de campos para o listbox
		aAdd( aColLis , fFieldCol("{|| aRiscos[oList:At()]["+cValToChar(nX)+"] }", aRiscos, aCamLis[nX]) )
	Next nX

	//Define propriedades do EnchoiceBar
	bConfirm := {|| lRet:= .T., cRetRisco := If( Len(aRiscos) > 0 , aRiscos[oList:At()][1], cRetRisco )  , oDlgRis:End() }
	bCancel  := {|| lRet:= .F., oDlgRis:End() }

	Define MsDialog oDlgRis From 0,0 To 450,550 Title STR0414 COLOR CLR_BLACK,CLR_WHITE Pixel //"Risco"

		oPnlPesq := TPanel():New(0,0,,oDlgRis,,,,,,0,40,.F.,.F.)
			oPnlPesq:Align := CONTROL_ALIGN_TOP

		oPnlRis := TPanel():New(0,0,,oDlgRis,,,,,,0,0,.F.,.F.)
			oPnlRis:Align := CONTROL_ALIGN_ALLCLIENT

		oGroupRis := TGroup():New(02,04,38,200,STR0439,oPnlPesq,,,.T.)//"Pesquisar"

		oComboRis := TComboBox():New( 10, 10, {|u| if( Pcount()>0, cKeyRis:= u, cKeyRis ) }, { cTitRis , STR0408},; //"Nome"
												 185, 10, oPnlPesq, ,{|| fOrderRis( @oComboRis ,@oList, @aRiscos ) },/*bValid*/,/*nClrBack*/,CLR_BLACK,;
												 .T., /*oFont*/, , ,/*bWhen*/, , , , , cKeyRis, /*cLabelText*/ ,/*nLabelPos*/, /*oLabelFont*/, CLR_BLACK  )

		//Campo de busca
		oGetRis := TGet():New( 24, 10, {|u| if( Pcount()>0, cResult:= u, cResult ) }, oPnlPesq, 185, 7, "@!",;
	 										/*bValid*/, CLR_BLACK, /*nClrBack*/, /*oFont*/, , , .T., , , {||  },;
	 										, , /*bChange*/,/*lReadOnly*/,/*lPassword*/ , , cResult, , , , /*lHasButton*/,;
	 										/*lNoButton*/, /*cLabelText*/ ,/*nLabelPos*/, /*oLabelFont*/, /*nLabelColor*/  )
	 	oButRis := TButton():New( 23 , 205, STR0439, oPnlPesq, {|| fPesqRisco( @cResult , @oComboRis ,@oList, @aRiscos ) },;
												30, 12,	, /*oFont*/, , .T., , , , {||  }, , )//Pesquisar

		//Cria um browse de listagem
		oList := FwBrowse():New()
			oList:SetDataArray()//Define que a utilizacao é por array
			oList:SetArray(aRiscos)//Define o array a ser utilizado
			oList:SetColumns(aColLis)//Define as colunas preestabelecidas
			oList:SetOwner(oPnlRis)//Define o objeto pai
			oList:DisableReport()//Desabilita botao de impressao
			oList:DisableConfig()//Desabilita botao de configuracao
			oList:SetDoubleClick( bConfirm )
			oList:Activate()//Ativa o browse

	Activate MsDialog oDlgRis ON INIT EnchoiceBar( oDlgRis, bConfirm , bCancel , , ) Centered

	RestArea( aArea )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fBuscaRisco
Define objeto das colunas

@return .T.

@sample
fBuscaRisco( aRiscos )

@author Guilherme Benkendorf
@since 10/06/2014
/*/
//---------------------------------------------------------------------
Static Function fBuscaRisco()

	Local aAreaRis:= GetArea()
	Local cNiv   := (__cTrbTree)->CODPRO
	Local cCusto := (__cTrbTree)->CC
	Local cCodAmb:= (__cTrbTree)->CODAMB
	Local aRiscos:= {}

	Local cCodTAF:= "TAF->TAF_INDCON <> '3' .And. TAF->TAF_INDCON <> '4'"
	Local aArea  := {}

	Local cFuncao, cTarefa, cNivAux, cGrau, cGrupo, cDepto
	Local nFun   := TamSX3("RJ_FUNCAO")[1]
	Local nTar   := TamSX3("TN5_CODTAR")[1]
	Local nCus   := TamSX3("CTT_CUSTO")[1]
	Local nDpt   := TamSX3("QB_DEPTO")[1]
	Local nX , nGrau

	Local lDepto  := NGCADICBASE('TAF_DEPTO' ,'D','TAF',.F.)

	Local aAuxTree := {}
	//Imagens adicionadas no UPDMDTA3. Será verificado os riscos correspondentes ao Grupo do Agente do Risco.
	//TMA_GRISCO : 1=Fisico;2=Quimico;3=Biologico;4=Ergonomico;5=Acidente;6=Mecanico;7=Perigosos
	Local aPngRis := {}
	aPngRis := fGetPngRis()

	If lDepto
		cDepto := (__cTrbTree)->DEPTO
	EndIf

	For nX := 1 To Len( aPngRis )
		nGrau := aScan( aPngRis[nX], { |y| Alltrim( UPPER( y ) ) $ Alltrim( UPPER( cImgRisco ) ) } )
		If nGrau > 0
			cGrau  := cValToChar( nGrau )
			//Quando for Grupo Ergonomico, Tambem considera o grupo Mecanico
			cGrupo := If( nX == 5 , "5/6" , cValToChar( nX ) )
			Exit
		EndIf
	Next nX

	DbSelectArea(__cTrbTree)
	DbSetOrder( 2 )
	If DbSeek("001"+cNivAtual+cFilAnt)

		dbSelectArea( __cTrbTree )
		dbSetOrder( 2 ) //CODEST+CODPRO+FILIAL
		While (AllTrim((__cTrbTree)->CARGO) $ "ILU/RIS") .And. !Empty((__cTrbTree)->CARGO)

			dbSelectArea(__cTrbTree)
			dbSetOrder( 2 ) //CODEST+CODPRO+FILIAL
			dbSeek( (__cTrbTree)->CODEST+(__cTrbTree)->NIVSUP + cFilAnt )
		End

		cNiv   := (__cTrbTree)->CODPRO

		//Verifica se a operação esta sendo feita diretamente em uma funçao ou tarefa
		//Se não for define que funcao ou tarefa são todos (*)
		cFuncao :=  PADR( If( (__cTrbTree)->TIPO == "3", (__cTrbTree)->CODTIPO, "*"  ), nFun )
		cTarefa :=  PADR( If( (__cTrbTree)->TIPO == "4", (__cTrbTree)->CODTIPO, "*"  ), nTar )
		//Busca a localizao
		While (__cTrbTree)->( !Eof() ) .And. (__cTrbTree)->TIPO <> "2"
			(__cTrbTree)->( dbSetOrder( 2 ) )
			(__cTrbTree)->( dbSeek( "001" + (__cTrbTree)->NIVSUP ) )
			If (__cTrbTree)->TIPO <> "2"
				cFuncao :=  PADR( If( (__cTrbTree)->TIPO == "3", Alltrim((__cTrbTree)->CODTIPO), "*"  ), nFun )
			EndIf
		EndDo
		//Ao encontrar a localização, define centro de custo de codigo do ambiente fisico
		cCusto := (__cTrbTree)->CC
		cCodAmb:= (__cTrbTree)->CODAMB
		If lDepto
			cDepto := If( Empty( (__cTrbTree)->DEPTO ) , PADR( "*", nDpt ) , (__cTrbTree)->DEPTO )
		EndIf
		//Adiciona no array a chave para busca do risco.
		//Caso for o primeiro nivel, o centro de custo é para todos(*)
		aAdd( aAuxTree, { If(cNiv=="001",PADR( "*", nCus ),cCusto), cCodAmb, cFuncao, cTarefa } )
		If lDepto
			aAdd( aAuxTree[Len(aAuxTree)] , If(cNiv=="001",PADR( "*", nDpt ),cDepto) )
		EndIf
	EndIf

	//-----------------------------------------------------
	// Busca os riscos conforme aAuxTree
	// Ordena o array conforme o indice 5 da TN0
	//-----------------------------------------------------
	ASort(aAuxTree, , , {| x , y | x[1] < y[1] .And. x[3] < y[3] .And. x[4] < y[4]})
	For nX := 1 To Len( aAuxTree )
		dbSelectArea( "TN0" )
		dbSetOrder( 5 ) //TN0_FILIAL+TN0_CC+TN0_CODFUN+TN0_CODTAR+TN0_DEPTO
		dbSeek( xFilial("TN0") + aAuxTree[ nX ][ 1 ] + aAuxTree[ nX ][ 3 ] + aAuxTree[ nX ][ 4 ] + If(lDepto,(aAuxTree[ nX ][ 5 ]),"") )
		While TN0->( !Eof() ) .And.  TN0->TN0_FILIAL == xFilial("TN0")   .And.;
												TN0->TN0_CC     == aAuxTree[ nX ][ 1 ] .And.;
												TN0->TN0_CODFUN == aAuxTree[ nX ][ 3 ] .And.;
												TN0->TN0_CODTAR == aAuxTree[ nX ][ 4 ] .And.;
												If( lDepto,(TN0->TN0_DEPTO  == aAuxTree[ nX ][ 5 ]),.T.)
			// Os riscos devem ser do mesmo Codigo de ambiente e do mesmo grau da Imagens selecionada.
			// Onde a data de Avaliação deve estar preenchida e de eliminação não deve estar.
			If TN0->TN0_CODAMB <> aAuxTree[ nx ][ 2 ] .Or. TN0->TN0_GRAU <> cGrau .Or. !Empty( TN0->TN0_DTELIM )
				TN0->( dbSkip() )
				Loop
			EndIf
         // Verifica o grupo de risco conforme imagem selecionada.
			dbSelectArea( "TMA" )
			dbSetOrder( 1 ) //TMA_FILIAL+TMA_AGENTE
			dbSeek( xFilial( "TMA" ) + TN0->TN0_AGENTE )
			If !( TMA->TMA_GRISCO $ cGrupo )
				TN0->( dbSkip() )
				Loop
			EndIf

			aAdd( aRiscos, { TN0->TN0_NUMRIS, TMA->TMA_NOMAGE , TN0->TN0_DTAVAL } )

			TN0->( dbSkip() )
			Loop
		EndDo
	Next nX

	RestArea( aAreaRis )

Return aRiscos
//---------------------------------------------------------------------
/*/{Protheus.doc} fFieldCol
Define objeto das colunas

@param cData , Caractere, Valor do campo
@param aRiscos ,Array, Array de Riscos
@param cCampo, Campo, Nome do campo

@return .T.

@sample
fFieldCol()

@author Guilherme Benkendorf
@since 09/06/2014
/*/
//---------------------------------------------------------------------
Static Function fFieldCol( cData, aRiscos, cCampo )

	Local oColuna
	Local aTamCpo := TamSX3( cCampo )
	Local cTitulo := AllTrim( Posicione( 'SX3' , 2 , cCampo , 'X3Titulo()' ) )

	//Adiciona as colunas do markbrowse
	oColuna := FWBrwColumn():New() //Cria objeto
	oColuna:SetAlign( IIf( GetSx3Cache( cCampo, 'X3_TIPO' ) == "N", CONTROL_ALIGN_RIGHT, CONTROL_ALIGN_LEFT ) ) //Define alinhamento
	oColuna:SetData( &(cData) ) //Define valor

	oColuna:SetEdit( .F. ) //Indica se é editavel
	oColuna:SetTitle( IIf("CHAVE" $ UPPER( cTitulo ), STR0004, cTitulo  ) ) //Define titulo###"Código"
	oColuna:SetType( GetSx3Cache( cCampo, 'X3_TIPO' ) ) //Define tipo
	oColuna:SetSize( aTamCpo[1] + aTamCpo[2] ) //Define tamanho
	oColuna:SetPicture( X3Picture(cCampo) ) //Define picture

Return oColuna
//---------------------------------------------------------------------
/*/{Protheus.doc} fOrderRis
Define Ordem na listagem de riscos.

@return .T.

@sample
fOrderRis( oCombo, @oListRis, @aRiscos )

@author Guilherme Benkendorf
@since 09/06/2014
/*/
//---------------------------------------------------------------------
Static Function fOrderRis( oCombo, oListRis, aRiscos )
	Local nIndRis := oCombo:nAt

	ASort(aRiscos , , , {| x , y | x[nIndRis] < y[nIndRis]})

	//Executa a atualização das informações no Browse.
	oListRis:Refresh( .T. )

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fPesqRisco
Define Ordem na listagem de riscos.

@return .T.

@sample
fPesqRisco( @cPesquisa, oCombo ,@oList, aRiscos )

@author Guilherme Benkendorf
@since 09/06/2014
/*/
//---------------------------------------------------------------------
Static Function fPesqRisco( cPesquisa, oCombo ,oList, aRiscos )
	Local nIndRis := oCombo:nAt
	Local nPosRis := aScan( aRiscos, {|x| UPPER( Alltrim( cPesquisa ) ) == UPPER( Alltrim ( x[nIndRis] ) ) } )

	If nPosRis > 0
		oList:Goto( nPosRis )
		oList:Refresh( .F. )
	Else
		MsgStop(STR0348, STR0440 )//"Atenção"###"Risco não localizado"
		cPesquisa := Space( 60 )
	EndIf

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fDefEstTree
Define a Estrutura da Arvore.

@return Nil

@sample
fDefEstTree( @cCargo, @cCargoPai, @cFolderA, @cFolderB, .T., , ::lEditMode )

@author Guilherme Benkendorf
@since 11/06/2014
/*/
//---------------------------------------------------------------------
Static Function fDefEstTree( cCargo, cCargoPai, cFolderA, cFolderB, lTRB, lPai, lEditMode )
	Local aAreaTRB := (__cTrbTree)->( GetArea())
	Local aAreaTAF := TAF->( GetArea() )

  Default cCargo   := ""
  Default cCargoPai:= ""
  Default cFolderA := ""
  Default cFolderB := ""
  Default lTRB     := .F.
  Default lPai     := .F.
  Default lEditMode:= .F.

	If lTRB
		If (__cTrbTree)->TIPO == '0'
			cCargo := 'ILU'
			cFolderA := 'ico_planta_ilustracao.png'
			cFolderB := 'ico_planta_ilustracao.png'
		ElseIf (__cTrbTree)->TIPO == '1'
			cCargo   := 'BEM'
				// Imagem diferente para bem que não estiver no desenho da planta
			If !Empty( (__cTrbTree)->IMAGEM ) .And. lEditMode
				cFolderA := "ng_ico_bem_planta"
				cFolderB := "ng_ico_bem_planta"
			Else
				cFolderA := "ENGRENAGEM"
				cFolderB := "ENGRENAGEM"
			EndIf
		ElseIf (__cTrbTree)->TIPO == '2'
			cCargo := 'LOC'
			If (__cTrbTree)->PLANTA == "1"
				cFolderA := 'ico_planta_fecha'
				cFolderB := 'ico_planta_abre'
			Else
				cFolderA := 'ico_planta_local'
				cFolderB := 'ico_planta_local'
			EndIf
		ElseIf (__cTrbTree)->TIPO == '3'
			cCargo := 'FUN'
			cFolderA := 'FOLDER14'
			cFolderB := 'FOLDER15'
		ElseIf (__cTrbTree)->TIPO == '4'
			cCargo 	:= 'TAR'
			cFolderA := 'FOLDER12'
			cFolderB := 'FOLDER13'
		ElseIf (__cTrbTree)->TIPO == '7' //Risco
			cCargo := 'RIS'
				// Imagem diferente para bem que não estiver no desenho da planta
			If !Empty( (__cTrbTree)->IMAGEM ) .And. lEditMode
				cFolderA := "ng_ico_ris_planta"
				cFolderB := "ng_ico_ris_planta"
			Else
				cFolderA := 'ng_ico_risco'
				cFolderB := 'ng_ico_risco'
			EndIf
		ElseIf(__cTrbTree)->TIPO == 'A'
			cCargo 	:= 'RES'
			cFolderA := 'NG_ICO_RESIDUO'
			cFolderB := 'NG_ICO_RESIDUO'
		ElseIf (__cTrbTree)->TIPO == 'B'
			cCargo 	:= 'ASP'
			cFolderA := 'NG_ICO_ASPECTO'
			cFolderB := 'NG_ICO_ASPECTO'
		ElseIf (__cTrbTree)->TIPO == 'C'
			cCargo 	:= 'PTO'
			cFolderA := 'NG_ICO_PCOLETA'
			cFolderB := 'NG_ICO_PCOLETA'
		EndIf

		If lPai
			If __nModPG == 35
				dbSelectArea(__cTrbTree)
				dbSetOrder(2)
				dbSeek('001'+(__cTrbTree)->NIVSUP+cFilAnt)
				fDefEstTree( @cCargoPai, , , ,lTRB  )
			Else
				cCargoPai := "LOC"
			EndIf
		EndIf

	Else

		If TAF->TAF_INDCON == '0'
			cCargo := 'ILU'
			cFolderA := 'ico_planta_ilustracao.png'
			cFolderB := 'ico_planta_ilustracao.png'
		ElseIf TAF->TAF_INDCON == '1'
			cCargo   := 'BEM'
				// Imagem diferente para bem que não estiver no desenho da planta
			If !Empty( TAF->TAF_IMAGEM ) .And. lEditMode
				cFolderA := "ng_ico_bem_planta"
				cFolderB := "ng_ico_bem_planta"
			Else
				cFolderA := "ENGRENAGEM"
				cFolderB := "ENGRENAGEM"
			EndIf
		ElseIf TAF->TAF_INDCON == '2'
			cCargo := 'LOC'
			If TAF->TAF_PLANTA == "1"
				cFolderA := 'ico_planta_fecha'
				cFolderB := 'ico_planta_abre'
			Else
				cFolderA := 'ico_planta_local'
				cFolderB := 'ico_planta_local'
			EndIf
		ElseIf TAF->TAF_INDCON == '3'
			cCargo := 'FUN'
			cFolderA := 'FOLDER14'
			cFolderB := 'FOLDER15'
		ElseIf TAF->TAF_INDCON == '4'
			cCargo 	:= 'TAR'
			cFolderA := 'FOLDER12'
			cFolderB := 'FOLDER13'
		ElseIf TAF->TAF_INDCON == '7'
			cCargo := 'RIS'
			// Imagem diferente para bem que não estiver no desenho da planta
			If !Empty( TAF->TAF_IMAGEM ) .And. lEditMode
				cFolderA := "ng_ico_ris_planta"
				cFolderB := "ng_ico_ris_planta"
			Else
				cFolderA := 'ng_ico_risco'
				cFolderB := 'ng_ico_risco'
			EndIf
		EndIf

		If lPai
			If __nModPG == 35
				dbSelectArea("TAF")
				dbSetOrder(2)
				dbSeek(cFilAnt+'001'+TAF->TAF_NIVSUP)
				fDefEstTree( @cCargoPai, , , ,lTRB  )
			Else
				cCargoPai := "LOC"
			EndIf
		EndIf

	EndIf

	RestArea( aAreaTRB )
	RestArea( aAreaTAF )

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} ValInsertImg
Efetua a validação na inserçao da imagem.

@return lRet

@sample
ValInsertImg(::cImgAtu)

@author Guilherme Benkendorf
@since 11/06/2014
/*/
//---------------------------------------------------------------------
Static Function ValInsertImg( _cPgTipo , cImgAtu, oTipo, lConfirm )
	Local lRet    := .T.

	Default lConfirm := .F.

	If __nModPG == 35
		If _cPgTipo == "1"
			//Caso a imagem nao corresponder a biblioteca de Riscos
			If !( Alltrim( UPPER("ng_ico_ris_") ) $ Alltrim(UPPER(cImgAtu) ) )
				lRet := .F.
				ShowHelpDlg( "", {STR0441}, 2, {STR0442}, 2 )//"Imagem inválida para a inclusão de Risco Ambiental."###"Para incluir um risco a imagem deve ser correspondente ao do Risco Ambiental."
            // Seleciona o tipo 0=Ilustração
				oTipo:Select(0)
				oTipo:VarPut('0')
			EndIf
		EndIf

		If lConfirm .And. _cPgTipo <> "1"
			//Caso a imagem for da biblioteca de Riscos
			If ( Alltrim( UPPER("ng_ico_ris_") ) $ Alltrim(UPPER(cImgAtu) ) )
				lRet := .F.
				ShowHelpDlg( "", {STR0443}, 2, {STR0444}, 2 )//"Imagem inválida. Imagem correspondente a inclusão de Risco Ambiental."###"Selecione outra imagem para esta operação."
			EndIf
		EndIf

		oTipo:Refresh()

	EndIf

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fGetPngRis
Define a Estrutura do array de imagens do risco.

@return aPngRis Array com as imagens a serem verificadas.

@sample
aArray := fGetPngRis()

@author Guilherme Benkendorf
@since 11/06/2014
/*/
//---------------------------------------------------------------------
Static Function fGetPngRis()
	Local aPngRis := {}

	aAdd( aPngRis, { "ng_ico_ris_fis_1.png","ng_ico_ris_fis_2.png","ng_ico_ris_fis_3.png" } )
	aAdd( aPngRis, { "ng_ico_ris_qui_1.png","ng_ico_ris_qui_2.png","ng_ico_ris_qui_3.png" } )
	aAdd( aPngRis, { "ng_ico_ris_bio_1.png","ng_ico_ris_bio_2.png","ng_ico_ris_bio_3.png" } )
	aAdd( aPngRis, { "ng_ico_ris_erg_1.png","ng_ico_ris_erg_2.png","ng_ico_ris_erg_3.png" } )
	aAdd( aPngRis, { "ng_ico_ris_aci_1.png","ng_ico_ris_aci_2.png","ng_ico_ris_aci_3.png" } )

Return aPngRis
//---------------------------------------------------------------------
/*/{Protheus.doc} fValidCod
Valida cadastro de código da TU0. Através da TU1.

@return lRet := .T./.F.

@sample Valid fValidCod(cCodigo)
@param cCodigo
@author Guilherme Benkendorf
@since 25/06/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fChkRegTU1(cCodigo)
	Local aPng := fGetPngRis()
	Local nX
	Local lRet
	Local aArea := GetArea()

	dbSelectArea("TU1")
	dbSetOrder(1)
	For nX := 1 to Len(aPng)
		lRet := dbSeek(xFilial("TU1") + cCodigo + PADR( "1", Len(TU1->TU1_TIPIMG) ) + PADR( aPng[nX][1], Len( TU1->TU1_IMAGEM ) ) )
		If !lRet
			Exit
		EndIf
	Next nX

	RestArea( aArea )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fValImageInc
Valida a imagem inclusa na planta.

@return lRet := .T./.F.

@sample Valid fValidCod(cCodigo)
@param oTree - Objeto da Arvore
@param cTRB  - Tabela temporaria da Arvore
@author Guilherme Benkendorf
@since 07/07/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fValImageInc(oTree , cTRB, cImgRisco)
Local nX, nPos
Local aAuxTrbTre := (cTRB)->(GetArea())
Local aPngRis := {}
Local lRet := .T.

aPngRis := fGetPngRis()

For nX := 1 To Len( aPngRis )
	nPos := aScan( aPngRis[nX], { |y| Alltrim( UPPER( y ) ) $ Alltrim( UPPER( cImgRisco ) ) } )
	If nPos > 0
		Exit
	EndIf
Next nX

If nPos > 0
	// Valida a Inclusao da Imagem
	dbSelectArea(cTRB)
	dbSetOrder( 2 )// CODEST+CODPRO+FILIAL+ORDEM
	dbSeek("001"+cNivAtual+cFilAnt)

	lRet := ValRisMNT902( 3 , oTree, cTRB )
EndIf

RestArea( aAuxTrbTre )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} GetAFmrRes
Função utilizada para planta gráfica no módulo de SGA.
Retorna o Array contendo os campos necessários para a rotina de Cadastros de Fmrs(SGAA500)


@author Gabriel Augusto Werlich
@since 03/07/2014
@version MP11
@return aFiltroFmr
/*/
//---------------------------------------------------------------------
Static Function GetAFmrRes()
Return {{"TDC_DEPTO",TAF->TAF_CODNIV},{"TDC_STATUS","4"}}

//---------------------------------------------------------------------
/*/{Protheus.doc} GetIncAFmr
Função utilizada para planta gráfica no módulo de SGA.
Retorna o Array contendo os campos que serão preenchidos ao acessar
a rotina de Cadastro de FMR, através do "Incluir FMR" na planta gráfica.

@author Gabriel Augusto Werlich
@since 04/07/2014
@version MP11
@return aIncluiFmr
/*/
//---------------------------------------------------------------------
Static Function GetIncAFmr()
Return {{"TDC_DEPTO",TAV->TAV_CODNIV},{"TDC_CODRES",TAV->TAV_CODRES}}

//---------------------------------------------------------------------
/*/{Protheus.doc} GetAFmrPla
Função utilizada para planta gráfica no módulo de SGA.
Retorna o Array para a rotina de Logística de Retirada(SGAA510).

@author Gabriel Augusto Werlich
@since 07/07/2014
@version MP11
@return aFiltroFmr
/*/
//---------------------------------------------------------------------
Static Function GetAFmrPla()
Return {{"TDC_DEPTO",TAF->TAF_CODNIV}}

//---------------------------------------------------------------------
/*/{Protheus.doc} GetAFmrLoc
Retorna o Array contendo os campos necessários para a rotina de Logística de Retirada(SGAA510).

@author Gabriel Augusto Werlich
@since 03/07/2014
@version MP11
@return aFiltroFmr
/*/
//---------------------------------------------------------------------
Static Function GetAFmrLoc()
Return {{"TDC_CODRES",TAV->TAV_CODRES}}

//---------------------------------------------------------------------
/*/{Protheus.doc} GetDesempA
Retorna o Array contendo os campos da estrutura de filtro para rotina de Aspectos(SGAA030).

@author Gabriel Augusto Werlich
@since 03/07/2014
@version MP11
@return aFiltroFmr
/*/
//---------------------------------------------------------------------
Static Function GetDesempA()
Return {{"TAB_CODASP",TAG->TAG_CODASP},{"TAB_CODNIV",TAG->TAG_CODNIV}}

//---------------------------------------------------------------------
/*/{Protheus.doc} SGADFR140
Responsável pelas operações do cadastro Definição de Resíduo(SGAA140).

@author Gabriel Augusto Werlich
@since 21/07/2014
@version MP11
@return
/*/
//---------------------------------------------------------------------
Static Function SGADFR140()

	Local aVar := Array(2)

	aVar[1] := If(Type("Inclui") == "L", Inclui, .T.)
	aVar[2] := If(Type("Altera") == "L", Altera, .T.)

	aRotSetOpc("TAX",TAX->(Recno()),4)

	Sg140Pro("TAX",TAX->(Recno()),4,{TAV->TAV_CODNIV})

	Inclui := aVar[1]
	Altera := aVar[2]

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} SgaOprOcr
Função que passa os paramêtros para a rotina de Ocorrências (SGAA150)
@author Gabriel Augusto Werlich
@since 21/07/2014
@version MP11
@return
/*/
//---------------------------------------------------------------------
Static Function SgaOprOcr()

	Local aVar := Array(2)

	aVar[1] := If(Type("Inclui") == "L", Inclui, .T.)
	aVar[2] := If(Type("Altera") == "L", Altera, .T.)

	aRotSetOpc("TB0",TB0->(Recno()),3)

	Sg150Pro("TB0",TB0->(Recno()),3,TAV->TAV_CODRES,0,TAV->TAV_CODNIV)

	Inclui := aVar[1]
	Altera := aVar[2]

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} SgaOprFMR
Função utilizada para a chamada da tela de Inclusão de FMR, preenchendos alguns dados
através do array passado por paramêtro.

@author Gabriel Augusto Werlich
@since 21/07/2014
@version MP11
@return
/*/
//---------------------------------------------------------------------
Static Function SgaOprFMR(aDadosFmr)

	SG510ALT("TDC",TDC->(Recno()),3, aDadosFmr)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} GetIncAFmr
Retorna o Array contendo os campos que serão preenchidos ao acessar
a rotina de Cadastro de FMR, através do "Incluir FMR" na planta gráfica.

@author Gabriel Augusto Werlich
@since 04/07/2014
@version MP11
@return aIncluiFmr
/*/
//---------------------------------------------------------------------
Static Function GetPtoFmr()
Return {{"TDC_DEPTO",TDB->TDB_DEPTO},{"TDC_CODPNT",TDB->TDB_CODIGO}}

//---------------------------------------------------------------------
/*/{Protheus.doc} GetFmrPNT4
Retorna o Array contendo o valor dos campos em um array para a rotina de Cadastros de Fmrs(SGAA500)

@author Gabriel Augusto Werlich
@since 03/07/2014
@version MP11
@return aFiltroFmr
/*/
//---------------------------------------------------------------------
Static Function GetFmrPNT4()
Return {{"TDC_CODPNT",TDB->TDB_CODIGO},{"TDC_DEPTO",TDB->TDB_DEPTO},{"TDC_STATUS","4"}}

//---------------------------------------------------------------------
/*/{Protheus.doc} GetFMRPNT7
Função utilizada para planta gráfica no módulo de SGA.
Retorna o Array contendo os campos de Localização do nivel posicionado,
e o status = 7, para a rotina de Logística de Retirada(SGAA510).

@author Gabriel Augusto Werlich
@since 07/07/2014
@version MP11
@return aFiltroFmr
/*/
//---------------------------------------------------------------------
Static Function GetFMRPNT7()
Return {{"TDC_CODPNT",TDB->TDB_CODIGO},{"TDC_DEPTO",TDB->TDB_DEPTO}}

//---------------------------------------------------------------------
/*/{Protheus.doc} LoadSgaNiv
Carrega as informações de acordo com as localizações
somente para o módulo de SGA(Itens: Resíduo/Aspectos/Pontos de Coleta).

@author Gabriel Augusto Werlich
@since 25/07/2014
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function LoadSgaNiv( oPGClass, cNivelAtu, nNivel )

	Local aArea     := GetArea()
	Local aAreaTree := (oPGClass:cTrbTree)->(GetArea())

	Local lMeter  := Type("_oPgMeter") == "O" .And. Type("_oPgSay") == "O"

	Local nTamDesc := Len((oPGClass:cTrbTree)->DESCRI)

	dbSelectArea("TAV")
	dbSetOrder(2)
	dbSeek( xFilial("TAV") + "001" + cNivelAtu )

	ProcRegua(0)

	While !TAV->(Eof()) .And. TAV->TAV_FILIAL == xFilial("TAV") .And. TAV->TAV_CODNIV == cNivelAtu

		If lMeter
			_oPgMeter:Set(++_nIncMeter)
			_oPgMeter:Refresh()
		EndIf

		If FindFunction("Soma1Old")
			oPGClass:cCodNiv := Soma1Old(AllTrim(oPGClass:cCodNiv))
		Else
			oPGClass:cCodNiv := Soma1(AllTrim(oPGClass:cCodNiv))
		EndIf

		dbSelectArea(oPGClass:cTrbTree)
		dbSetOrder(2)
		RecLock(oPGClass:cTrbTree,.T.)
		(oPGClass:cTrbTree)->FILIAL 	:= cFilAnt
		(oPGClass:cTrbTree)->CODEST 	:= "001"
		(oPGClass:cTrbTree)->CODPRO 	:= oPGClass:cCodNiv
		(oPGClass:cTrbTree)->DESCRI 	:= SubStr(Posicione("SB1",1,xFilial("SB1")+TAV->TAV_CODRES,"SB1->B1_DESC"),1,nTamDesc)
		(oPGClass:cTrbTree)->NIVSUP 	:= cNivelAtu
		(oPGClass:cTrbTree)->RESPONS	:= ""
		(oPGClass:cTrbTree)->TIPO   	:= "A"
		(oPGClass:cTrbTree)->CODTIPO	:= TAV->TAV_CODRES
		(oPGClass:cTrbTree)->MODSGA 	:= "X"
		(oPGClass:cTrbTree)->CC     	:= ""
		(oPGClass:cTrbTree)->CENTRAB	:= ""
		(oPGClass:cTrbTree)->NIVEL  	:= nNivel+1
		(oPGClass:cTrbTree)->CARGO  	:= "RES"
		(oPGClass:cTrbTree)->ORDEM  	:= oPGClass:SetMovement()
		(oPGClass:cTrbTree)->PLANTA 	:= TAV->TAV_PLANTA
		(oPGClass:cTrbTree)->TIPIMG 	:= TAV->TAV_TIPIMG
		(oPGClass:cTrbTree)->IMAGEM 	:= TAV->TAV_IMAGEM
		(oPGClass:cTrbTree)->POSX   	:= TAV->TAV_POSX
		(oPGClass:cTrbTree)->POSY   	:= TAV->TAV_POSY
		(oPGClass:cTrbTree)->TAMX   	:= TAV->TAV_TAMX
		(oPGClass:cTrbTree)->TAMY   	:= TAV->TAV_TAMY
		(oPGClass:cTrbTree)->MOVBLO 	:= TAV->TAV_MOVBLO
		(oPGClass:cTrbTree)->PGSUP  	:= oPGClass:cPlantaAtu
		(oPGClass:cTrbTree)->SEQUEN 	:= TAV->TAV_SEQUEN
		(oPGClass:cTrbTree)->PERMISS	:= .T.
		(oPGClass:cTrbTree)->(MsUnLock())

		nMaxNivel := Max(nMaxNivel, nNivel+1)

		dbSelectArea("TAV")
		dbSkip()

	EndDo

	dbSelectArea("TAG")
	dbSetOrder(2)
	dbSeek( xFilial("TAG") + "001" + cNivelAtu )

	While !TAG->(Eof()) .And. TAG->TAG_FILIAL == xFilial("TAG") .And. TAG->TAG_CODNIV == cNivelAtu

		If lMeter
			_oPgMeter:Set(++_nIncMeter)
			_oPgMeter:Refresh()
		EndIf

		If FindFunction("Soma1Old")
			oPGClass:cCodNiv := Soma1Old(AllTrim(oPGClass:cCodNiv))
		Else
			oPGClass:cCodNiv := Soma1(AllTrim(oPGClass:cCodNiv))
		EndIf

		dbSelectArea(oPGClass:cTrbTree)
		dbSetOrder(2)
		RecLock(oPGClass:cTrbTree,.T.)
		(oPGClass:cTrbTree)->FILIAL 	:= cFilAnt
		(oPGClass:cTrbTree)->CODEST 	:= "001"
		(oPGClass:cTrbTree)->CODPRO 	:= oPGClass:cCodNiv
		(oPGClass:cTrbTree)->DESCRI 	:= SubStr(Posicione("TA4",1,xFilial("TA4")+TAG->TAG_CODASP,"TA4->TA4_DESCRI"),1,nTamDesc)
		(oPGClass:cTrbTree)->NIVSUP 	:= cNivelAtu
		(oPGClass:cTrbTree)->RESPONS	:= ""
		(oPGClass:cTrbTree)->TIPO   	:= "B"
		(oPGClass:cTrbTree)->CODTIPO	:= TAG->TAG_CODASP
		(oPGClass:cTrbTree)->MODSGA 	:= "X"
		(oPGClass:cTrbTree)->CC     	:= ""
		(oPGClass:cTrbTree)->CENTRAB	:= ""
		(oPGClass:cTrbTree)->NIVEL  	:= nNivel+1
		(oPGClass:cTrbTree)->CARGO  	:= "ASP"
		(oPGClass:cTrbTree)->ORDEM  	:= oPGClass:SetMovement()
		(oPGClass:cTrbTree)->PLANTA 	:= TAG->TAG_PLANTA
		(oPGClass:cTrbTree)->TIPIMG 	:= TAG->TAG_TIPIMG
		(oPGClass:cTrbTree)->IMAGEM 	:= TAG->TAG_IMAGEM
		(oPGClass:cTrbTree)->POSX   	:= TAG->TAG_POSX
		(oPGClass:cTrbTree)->POSY   	:= TAG->TAG_POSY
		(oPGClass:cTrbTree)->TAMX   	:= TAG->TAG_TAMX
		(oPGClass:cTrbTree)->TAMY   	:= TAG->TAG_TAMY
		(oPGClass:cTrbTree)->MOVBLO 	:= TAG->TAG_MOVBLO
		(oPGClass:cTrbTree)->PGSUP  	:= oPGClass:cPlantaAtu
		(oPGClass:cTrbTree)->SEQUEN 	:= TAG->TAG_SEQUEN
		(oPGClass:cTrbTree)->PERMISS	:= .T.
		(oPGClass:cTrbTree)->(MsUnLock())

		nMaxNivel := Max(nMaxNivel, nNivel+1)

		dbSelectArea("TAG")
		dbSkip()

	EndDo

	dbSelectArea("TDB")
	dbSetOrder(2) //TDB_FILIAL+TDB_DEPTO+TDB_CODIGO
	dbSeek( xFilial("TDB") + cNivelAtu )

	While !TDB->(Eof()) .And. TDB->TDB_FILIAL == xFilial("TDB") .And. TDB->TDB_DEPTO == cNivelAtu

		If lMeter
			_oPgMeter:Set(++_nIncMeter)
			_oPgMeter:Refresh()
		EndIf

		If FindFunction("Soma1Old")
			oPGClass:cCodNiv := Soma1Old(AllTrim(oPGClass:cCodNiv))
		Else
			oPGClass:cCodNiv := Soma1(AllTrim(oPGClass:cCodNiv))
		EndIf

		dbSelectArea(oPGClass:cTrbTree)
		dbSetOrder(2)
		RecLock(oPGClass:cTrbTree,.T.)
		(oPGClass:cTrbTree)->FILIAL 	:= cFilAnt
		(oPGClass:cTrbTree)->CODEST 	:= "001"
		(oPGClass:cTrbTree)->CODPRO 	:= oPGClass:cCodNiv
		(oPGClass:cTrbTree)->DESCRI 	:= SubStr(TDB->TDB_DESCRI,1,nTamDesc)
		(oPGClass:cTrbTree)->NIVSUP 	:= cNivelAtu
		(oPGClass:cTrbTree)->RESPONS	:= ""
		(oPGClass:cTrbTree)->TIPO   	:= "C"
		(oPGClass:cTrbTree)->CODTIPO	:= TDB->TDB_CODIGO
		(oPGClass:cTrbTree)->MODSGA 	:= "X"
		(oPGClass:cTrbTree)->CC     	:= ""
		(oPGClass:cTrbTree)->CENTRAB	:= ""
		(oPGClass:cTrbTree)->NIVEL  	:= nNivel+1
		(oPGClass:cTrbTree)->CARGO  	:= "PTO"
		(oPGClass:cTrbTree)->ORDEM  	:= oPGClass:SetMovement()
		(oPGClass:cTrbTree)->PLANTA 	:= TDB->TDB_PLANTA
		(oPGClass:cTrbTree)->TIPIMG 	:= TDB->TDB_TIPIMG
		(oPGClass:cTrbTree)->IMAGEM 	:= TDB->TDB_IMAGEM
		(oPGClass:cTrbTree)->POSX   	:= TDB->TDB_POSX
		(oPGClass:cTrbTree)->POSY   	:= TDB->TDB_POSY
		(oPGClass:cTrbTree)->TAMX   	:= TDB->TDB_TAMX
		(oPGClass:cTrbTree)->TAMY   	:= TDB->TDB_TAMY
		(oPGClass:cTrbTree)->MOVBLO 	:= TDB->TDB_MOVBLO
		(oPGClass:cTrbTree)->PGSUP  	:= oPGClass:cPlantaAtu
		(oPGClass:cTrbTree)->PERMISS	:= .T.
		(oPGClass:cTrbTree)->(MsUnLock())

		nMaxNivel := Max(nMaxNivel, nNivel+1)

		dbSelectArea("TDB")
		dbSkip()

	EndDo

	RestArea(aAreaTree)
	RestArea(aArea)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} SgaSavePG
Salva informações feitas na Planta Grafíca para o módulo de SGA (Itens: Resíduo/Aspectos/Pontos de Coleta).

@author Gabriel Augusto Werlich
@since 25/07/2014
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function SgaSavePG(cTrbTree, lFinal, aNewCod, oTree, aShape)

	Local nPosNivSup, cSvNivSup
	Local nPosShape

	Local aArea := GetArea()
	Local aAreaTRB := (cTrbTree)->(GetArea())
	Local aAreaTree := (oTree:cArqTree)->(GetArea())
	Local cSvLocal := "000"

	Default aNewCod := {}

	If !lFinal
		dbSelectArea("TAF")
		dbSetOrder(2)
		If dbSeek(xFilial("TAF"))
			cAliasQry := GetNextAlias()
			cQuery := " SELECT MAX(TAF.TAF_CODNIV) cCodMax FROM "+RetSqlName("TAF")+" TAF "
			cQuery += " WHERE TAF.TAF_FILIAL = '"+xFilial("TAF")+"' AND TAF.D_E_L_E_T_ <> '*'"
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

			dbSelectArea(cAliasQry)
			dbGoTop()
			If !Eof()
				cSvLocal := (cAliasQry)->cCodMax
			EndIf
			(cAliasQry)->(dbCloseArea())
		EndIf
	Endif

	dbSelectArea(cTrbTree)
	dbSetOrder(3) //"TIPO+CODTIPO+NIVSUP"
	dbSeek("A")
	While !Eof() .And. (cTrbTree)->TIPO == "A"

		cSvNivSup := (cTrbTree)->NIVSUP

		If ( nPosNivSup := aScan(aNewCod, {|x| x[2] == (cTrbTree)->NIVSUP} ) ) > 0
			cSvNivSup := aNewCod[nPosNivSup][3]

			If !lFinal
				dbSelectArea(cTrbTree)
				RecLock(cTrbTree,.F.)
				(cTrbTree)->NIVSUP := cSvNivSup
				MsUnlock(cTrbTree)
			Endif

		EndIf

		dbSelectArea("TAV")
		dbSetOrder(1)
		If dbSeek(xFilial("TAV")+Padr((cTrbTree)->CODTIPO, Len(TAV->TAV_CODRES))+(cTrbTree)->CODEST+cSvNivSup+(cTrbTree)->SEQUEN)
			RecLock("TAV",.F.)

			If !Empty((cTrbTree)->DELETADO)
				dbDelete()
			Else
				TAV->TAV_PLANTA := (cTrbTree)->PLANTA
				TAV->TAV_TIPIMG := (cTrbTree)->TIPIMG
				TAV->TAV_IMAGEM := (cTrbTree)->IMAGEM
				TAV->TAV_POSX   := (cTrbTree)->POSX
				TAV->TAV_POSY   := (cTrbTree)->POSY
				TAV->TAV_TAMX   := (cTrbTree)->TAMX
				TAV->TAV_TAMY   := (cTrbTree)->TAMY
				TAV->TAV_MOVBLO := (cTrbTree)->MOVBLO
				TAV->TAV_SEQUEN := (cTrbTree)->SEQUEN
			EndIf

			TAV->(MsUnLock())

		ElseIf !Empty((cTrbTree)->CODTIPO)

			RecLock("TAV",.T.)
			TAV->TAV_FILIAL := xFilial("TAV")
			TAV->TAV_CODEST := (cTrbTree)->CODEST
			TAV->TAV_CODNIV := cSvNivSup
			TAV->TAV_CODRES := Padr((cTrbTree)->CODTIPO, Len(TAV->TAV_CODRES))
			TAV->TAV_PLANTA := (cTrbTree)->PLANTA
			TAV->TAV_TIPIMG := (cTrbTree)->TIPIMG
			TAV->TAV_IMAGEM := (cTrbTree)->IMAGEM
			TAV->TAV_POSX   := (cTrbTree)->POSX
			TAV->TAV_POSY   := (cTrbTree)->POSY
			TAV->TAV_TAMX   := (cTrbTree)->TAMX
			TAV->TAV_TAMY   := (cTrbTree)->TAMY
			TAV->TAV_MOVBLO := (cTrbTree)->MOVBLO
			TAV->TAV_SEQUEN := (cTrbTree)->SEQUEN
			TAV->(MsUnLock())

		EndIf

		If !lFinal

			// Gera nova ordem para o item atual
			If FindFunction("Soma1Old")
				cSvLocal := Soma1Old(AllTrim(cSvLocal))
			Else
				cSvLocal := Soma1(AllTrim(cSvLocal))
			EndIf

			// Caso a ordem gerada seja diferente da atual
			If cSvLocal <> (cTrbTree)->CODPRO
				aAdd( aNewCod, { (cTrbTree)->(Recno()), (cTrbTree)->CODPRO, cSvLocal, 0, 0 } )

				// Verifica se existe representacao na Tree para o item
				dbSelectArea(oTree:cArqTree)
				dbSetOrder(4)
				If dbSeek((cTrbTree)->CODPRO+AllTrim((cTrbTree)->CARGO)+cFilAnt)
					aNewCod[Len(aNewCod)][4] := (oTree:cArqTree)->(Recno())
				Endif
				dbSelectArea(cTrbTree)
			Endif

			// Verifica se existe shape para o item
			If nPosNivSup > 0 .Or. ( cSvLocal <> (cTrbTree)->CODPRO .And. ( nPosShape := aScan( aShape,{|aShape| aShape[__aShape_Cargo__] == (cTrbTree)->CODPRO+AllTrim((cTrbTree)->CARGO)+cFilAnt} ) ) > 0 )
				aNewCod[Len(aNewCod)][5] := nPosShape
			Endif

		Endif

		dbSelectarea(cTrbTree)
		dbSkip()
	End

	dbSelectArea(cTrbTree)
	dbSetOrder(3) //"TIPO+CODTIPO+NIVSUP"
	dbSeek("B")
	While !Eof() .And. (cTrbTree)->TIPO == "B"

		cSvNivSup := (cTrbTree)->NIVSUP

		If ( nPosNivSup := aScan(aNewCod, {|x| x[2] == (cTrbTree)->NIVSUP }) ) > 0
			cSvNivSup := aNewCod[nPosNivSup][3]

			If !lFinal
				dbSelectArea(cTrbTree)
				RecLock(cTrbTree,.F.)
				(cTrbTree)->NIVSUP := cSvNivSup
				MsUnlock(cTrbTree)
			Endif

		EndIf

		dbSelectArea("TAG")
		dbSetOrder(1)
		If dbSeek(xFilial("TAG")+Padr((cTrbTree)->CODTIPO, Len(TAG->TAG_CODASP))+(cTrbTree)->CODEST+cSvNivSup+(cTrbTree)->SEQUEN)
			RecLock("TAG",.F.)

			If !Empty((cTrbTree)->DELETADO)
				dbDelete()
			Else
				TAG->TAG_PLANTA := (cTrbTree)->PLANTA
				TAG->TAG_TIPIMG := (cTrbTree)->TIPIMG
				TAG->TAG_IMAGEM := (cTrbTree)->IMAGEM
				TAG->TAG_POSX   := (cTrbTree)->POSX
				TAG->TAG_POSY   := (cTrbTree)->POSY
				TAG->TAG_TAMX   := (cTrbTree)->TAMX
				TAG->TAG_TAMY   := (cTrbTree)->TAMY
				TAG->TAG_MOVBLO := (cTrbTree)->MOVBLO
				TAG->TAG_SEQUEN := (cTrbTree)->SEQUEN
			EndIf

			TAG->(MsUnLock())

		ElseIf !Empty((cTrbTree)->CODTIPO)

			RecLock("TAG",.T.)
			TAG->TAG_FILIAL := xFilial("TAG")
			TAG->TAG_CODEST := (cTrbTree)->CODEST
			TAG->TAG_CODNIV := cSvNivSup
			TAG->TAG_CODASP := Padr((cTrbTree)->CODTIPO, Len(TAG->TAG_CODASP))
			TAG->TAG_PLANTA := (cTrbTree)->PLANTA
			TAG->TAG_TIPIMG := (cTrbTree)->TIPIMG
			TAG->TAG_IMAGEM := (cTrbTree)->IMAGEM
			TAG->TAG_POSX   := (cTrbTree)->POSX
			TAG->TAG_POSY   := (cTrbTree)->POSY
			TAG->TAG_TAMX   := (cTrbTree)->TAMX
			TAG->TAG_TAMY   := (cTrbTree)->TAMY
			TAG->TAG_MOVBLO := (cTrbTree)->MOVBLO
			TAG->TAG_SEQUEN := (cTrbTree)->SEQUEN
			TAG->(MsUnLock())
		EndIf

		If !lFinal

			// Gera nova ordem para o item atual
			If FindFunction("Soma1Old")
				cSvLocal := Soma1Old(AllTrim(cSvLocal))
			Else
				cSvLocal := Soma1(AllTrim(cSvLocal))
			EndIf

			// Caso a ordem gerada seja diferente da atual
			If cSvLocal <> (cTrbTree)->CODPRO
				aAdd( aNewCod, { (cTrbTree)->(Recno()), (cTrbTree)->CODPRO, cSvLocal, 0, 0 } )

				// Verifica se existe representacao na Tree para o item
				dbSelectArea(oTree:cArqTree)
				dbSetOrder(4)
				If dbSeek((cTrbTree)->CODPRO+AllTrim((cTrbTree)->CARGO)+cFilAnt)
					aNewCod[Len(aNewCod)][4] := (oTree:cArqTree)->(Recno())
				Endif
				dbSelectArea(cTrbTree)
			Endif

			// Verifica se existe shape para o item
			If nPosNivSup > 0 .Or. ( cSvLocal <> (cTrbTree)->CODPRO .And. ( nPosShape := aScan( aShape,{|aShape| aShape[__aShape_Cargo__] == (cTrbTree)->CODPRO+AllTrim((cTrbTree)->CARGO)+cFilAnt} ) ) > 0 )
				aNewCod[Len(aNewCod)][5] := nPosShape
			Endif

		Endif

		dbSelectArea(cTrbTree)
		dbSkip()

	End

	dbSelectArea(cTrbTree)
	dbSetOrder(3) //"TIPO+CODTIPO+NIVSUP"
	dbSeek("C")
	While !Eof() .And. (cTrbTree)->TIPO == "C"

		cSvNivSup := (cTrbTree)->NIVSUP

		If ( nPosNivSup := aScan(aNewCod, {|x| x[2] == (cTrbTree)->NIVSUP }) ) > 0
			cSvNivSup := aNewCod[nPosNivSup][3]

			If !lFinal
				dbSelectArea(cTrbTree)
				RecLock(cTrbTree,.F.)
				(cTrbTree)->NIVSUP := cSvNivSup
				MsUnlock(cTrbTree)
			Endif

		EndIf

		dbSelectArea("TDB")
		dbSetOrder(1)
		If dbSeek(xFilial("TDB")+cSvNivSup+Padr((cTrbTree)->CODTIPO, Len(TDB->TDB_CODIGO)))
			RecLock("TDB",.F.)

			If !Empty((cTrbTree)->DELETADO)
				dbDelete()
			Else
		  		TDB->TDB_DESCRI := (cTrbTree)->DESCRI
				TDB->TDB_PLANTA := (cTrbTree)->PLANTA
				TDB->TDB_TIPIMG := (cTrbTree)->TIPIMG
				TDB->TDB_IMAGEM := (cTrbTree)->IMAGEM
				TDB->TDB_POSX   := (cTrbTree)->POSX
				TDB->TDB_POSY   := (cTrbTree)->POSY
				TDB->TDB_TAMX   := (cTrbTree)->TAMX
				TDB->TDB_TAMY   := (cTrbTree)->TAMY
				TDB->TDB_MOVBLO := (cTrbTree)->MOVBLO
			EndIf

			TDB->(MsUnLock())

		ElseIf !Empty((cTrbTree)->CODTIPO)

			RecLock("TDB",.T.)
			TDB->TDB_FILIAL := xFilial("TDB")
			TDB->TDB_DEPTO  := cSvNivSup
			TDB->TDB_CODIGO := Padr((cTrbTree)->CODTIPO, Len(TDB->TDB_CODIGO))
			TDB->TDB_DESCRI := Padr((cTrbTree)->DESCRI,Len(TDB->TDB_DESCRI))
			TDB->TDB_PLANTA := (cTrbTree)->PLANTA
			TDB->TDB_TIPIMG := (cTrbTree)->TIPIMG
			TDB->TDB_IMAGEM := (cTrbTree)->IMAGEM
			TDB->TDB_POSX   := (cTrbTree)->POSX
			TDB->TDB_POSY   := (cTrbTree)->POSY
			TDB->TDB_TAMX   := (cTrbTree)->TAMX
			TDB->TDB_TAMY   := (cTrbTree)->TAMY
			TDB->TDB_MOVBLO := (cTrbTree)->MOVBLO
			TDB->(MsUnLock())
		EndIf

		If !lFinal

			// Gera nova ordem para o item atual
			If FindFunction("Soma1Old")
				cSvLocal := Soma1Old(AllTrim(cSvLocal))
			Else
				cSvLocal := Soma1(AllTrim(cSvLocal))
			EndIf

			// Caso a ordem gerada seja diferente da atual
			If cSvLocal <> (cTrbTree)->CODPRO
				aAdd( aNewCod, { (cTrbTree)->(Recno()), (cTrbTree)->CODPRO, cSvLocal, 0, 0 } )

				// Verifica se existe representacao na Tree para o item
				dbSelectArea(oTree:cArqTree)
				dbSetOrder(4)
				If dbSeek((cTrbTree)->CODPRO+AllTrim((cTrbTree)->CARGO)+cFilAnt)
					aNewCod[Len(aNewCod)][4] := (oTree:cArqTree)->(Recno())
				Endif
				dbSelectArea(cTrbTree)
			Endif

			// Verifica se existe shape para o item
			If nPosNivSup > 0 .Or. ( cSvLocal <> (cTrbTree)->CODPRO .And. ( nPosShape := aScan( aShape,{|aShape| aShape[__aShape_Cargo__] == (cTrbTree)->CODPRO+AllTrim((cTrbTree)->CARGO)+cFilAnt} ) ) > 0 )
				aNewCod[Len(aNewCod)][5] := nPosShape
			Endif

		Endif

		dbSelectArea(cTrbTree)
		dbSkip()

	End

	RestArea(aAreaTRB)
	RestArea(aArea)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} SgaUltSeq
Procura ultima sequencia do shape com o mesmo IndCod

@author Gabriel Augusto Werlich
@since 25/07/2014
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function SgaUltSeq(aShape, cIndCon, cCodigo, cNivSup)

	Local nPosSeq := 0
	Local cSequen := "000"

	While ( nPosSeq := aScan(aShape,{ |x|	x[__aShape_IndCod__] == cIndCon 		.And. ;
														!Empty(x[__aShape_Caract__])    		.And. ;
														x[__aShape_Codigo__] == cCodigo 		.And. ;
														x[__aShape_NivSup__] == cNivSup 		.And. ;
														x[__aShape_Caract__][1] > cSequen }  	  ,;
														 nPosSeq + 1) ) > 0

		cSequen := aShape[nPosSeq][__aShape_Caract__][1]
	EndDo

Return Soma1Old(cSequen)

//---------------------------------------------------------------------
/*/{Protheus.doc} SgUserFmr
Permite que seja incluida uma FMR, apenas se conter um
usuario participante da localização que está tentando incluir.

@author Gabriel Augusto Werlich
@since 25/07/2014
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function SgUserFmr(cCodNiv)

	Local aArea   	:= GetArea()
	Local aAreaQAA		:= QAA->(GetArea())

	Local lOk := .F.

	dbSelectArea("QAA")
	dbSetOrder(6)
	If dbSeek(Trim(Upper(cUserName)))
		dbSelectArea("TAK")
		dbSetOrder(1)
		lOk := dbSeek(xFilial("TAK")+"001"+cCodNiv+QAA->QAA_MAT)
	Endif

	RestArea(aAreaQAA)
	RestArea(aArea)

Return lOk
