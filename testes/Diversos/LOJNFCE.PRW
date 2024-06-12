//#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "LOJNFCE.CH"
#INCLUDE "AUTODEF.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "MATXDEF.CH"

Static aIDEnt	 	:= {}							// IDENT da tabela SPED000 para NFC-e e NF-e
Static aMVTSS	 	:= Nil
Static oLjNFCe	 	:= Nil
Static aICMSST	 	:= {}
Static aNFCeW02  	:= {}
Static aNFCeW17  	:= {}
Static aTotNaoFis	:= {0,0,0}						// [1]Reserva [2]Garantia Estendida [3]Servi็o
Static lEndFis   	:= GetNewPar("MV_SPEDEND",.F.) 	// Se estiver como F refere-se ao endere็o de Cobran็a se estiver T  ao  endere็o de Entrega.
Static lRetrNFCe 	:= .F.
Static oXML 	 	:= NIL 							// Utilizada para capturar dados da nfce
Static aMVTSS2	 	:= {}
Static aItensNFCe	:= Nil
Static lShowMsg		:= .T.							// Valida็ใo para exibir a mensagem de valida็ใo da versใo da NFC-e somente a primeira vez que acessar o sistema
Static aUrls		:= {"", {}}						// Array que cont้m o Ambiente da NFC-e e as Urls para gera็ใo do XML | { Ambiente NFC-e , Array com URLs }
Static cMsgConting	:= ""
Static aExcecaoCNF	:= {"00000000", "11111111", "22222222", "33333333",; //Rela็ใo de n๚meros que nใo sใo vแlidos na tag cNF de acordo com a SEFAZ
						"44444444", "55555555", "66666666", "77777777",;
						"88888888", "99999999", "12345678", "23456789",;
						"34567890", "45678901", "56789012", "67890123",;
						"78901234", "89012345", "90123456", "01234567" }

Static aRefxFis	:= {} 							// Valores de Refer๊ncia da MatxFis
Static lIsPafNfce   := ExistFunc("LjTipoPAF") .AND. LjTipoPAF(SLG->LG_CODIGO)$TIPO_PAF_NFCE // Fun็ใo para validar PAF-NFC-e
Static nModFsda		:= 0 //Conting๊ncia na modalidade 7 FSDA
Static lLJCUPXML	:= ExistBlock("LJCUPXML") // Ponto de entrada para adicionar informa็๕es especํficas no XML
Static lMvPosto		:= LjAtivoPCL()	// Verifica se esta ativo funcionalidade de Posto Combustivel e Lubrificantes (PCL)
Static lNT2023001	:= GetNewPar("MV_LJN2301", stod("20230401") ) > M->dDataBase	// Verifica se esta ativo as novas tags conforme NT 2023.001
Static cCstNT00123	:= "02-15-53-61"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบClass     ณLJNFCE         บAutor  ณVendas CRM     บ Data ณ  01/08/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบMetodos   ณ New()                                                      บฑฑ
ฑฑบ          ณ ClassName()                                                บฑฑ
ฑฑบ          ณ AddGrupo()                                                 บฑฑ
ฑฑบ          ณ DelGrupo()                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบObs.:     ณ A ideia dessa classe ้ de ter todos os grupos (de acordo   บฑฑ
ฑฑบ          ณ com o documento tecnico) da nfc-e instanciadas neste unico บฑฑ
ฑฑบ          ณ objeto por venda, para facilitar a impressใo da NFC-e      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA / SIGAFRT                                         บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Class LJNFCE

	Data aGrpA				//A. Dados da Nota Fiscal eletr๔nica
	Data aGrpB				//B. Identifica็ใo da Nota Fiscal eletr๔nica
	Data aGrpC				//C. Identifica็ใo do Emitente
	Data aGrpE				//E. Identifica็ใo do Destinatแrio
	Data aGrpH				//H. Detalhamento de Produtos e Servi็os da NF-e
	Data aGrpW				//W. Total da NF-e
	Data aGrpX				//X. Informa็๕es do Transporte da NF-e
	Data aGrpYA				//YA. Formas de Pagamento
	Data cClassName			//Nome da classe

	Method New()			//Metodo construtor
	Method ClassName()		//Nome da classe
	Method AddGrupo()		//Incluir grupo no objeto da NFCE
	Method DelGrupo()		//Exclui grupo no objeto da NFCE

EndClass

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบMetodo    ณNew            บAutor  ณVendas CRM     บ Data ณ  01/08/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Metodo construtor da classe LJNFCE                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL1 - Objeto da classe LJNFCE                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA / SIGAFRT                                         บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method New() Class LJNFCE

	Self:aGrpA	:= Nil	   		//A. Dados da Nota Fiscal eletr๔nica
	Self:aGrpB	:= Nil	  		//B. Identifica็ใo da Nota Fiscal eletr๔nica
	Self:aGrpC	:= Nil	   		//C. Identifica็ใo do Emitente
	Self:aGrpE	:= Nil	   		//E. Identifica็ใo do Destinatแrio
	Self:aGrpH	:= Nil	   		//H. Detalhamento de Produtos e Servi็os da NF-e
	Self:aGrpW	:= Nil			//W. Total da NF-e
	Self:aGrpX	:= Nil			//X. Informa็๕es do Transporte da NF-e
	Self:aGrpYA	:= {}			//YA. Formas de Pagamento
	Self:cClassName	:= "LJNFCE"	//Nome da classe

Return Self

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑบMetodo    ณClassName     บAutor  ณVendas CRM      บ Data ณ  01/08/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Metodo para retornar o nome da classe                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL1 - String com o nome da classe LJNFCE                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA / SIGAFRT                                         บฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ClassName() Class LJNFCE
Return Self:cClassName

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑบMetodo    ณAddGrupo      บAutor  ณVendas CRM      บ Data ณ  01/08/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Metodo adicionar o objeto (grupo) que compoem o objeto     บฑฑ
ฑฑ           ณ de NFC-e (LJNFCE)                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA / SIGAFRT                                         บฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method AddGrupo(oObjGrp) Class LJNFCE
	Local cClasse := oObjGrp:ClassName()

	Do Case
	Case cClasse == "LJNFCEPAG"
		aAdd(Self:aGrpYA, oObjGrp)

	End Case

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑบMetodo    ณDelGrupo      บAutor  ณVendas CRM      บ Data ณ  01/08/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Metodo para deletar o objeto (grupo) que compoem o objeto  บฑฑ
ฑฑ           ณ de NFC-e (LJNFCE)                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA / SIGAFRT                                         บฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method DelGrupo(cGrupo) Class LJNFCE

	cGrupo := UPPER(AllTrim(cGrupo))

	Do Case
	Case cGrupo == "LJNFCEPAG"
		Self:aGrpYA := {}

	End Case

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑบClass     ณLJNFCEPAG      บAutor  ณVendas CRM     บ Data ณ  01/08/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบMetodos   ณ New()                                                      บฑฑ
ฑฑบ          ณ ClassName()                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบObs.:     ณ Esta classe representa o grupo YA (de acordo com o doc.    บฑฑ
ฑฑบ          ณ tecnico) referente as formas/valores de pagamento          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA / SIGAFRT                                         บฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Class LJNFCEPAG
	
	Data cForma			//Forma de pagemento
	Data cValor			//Valor da forma de pagamento
	Data cAdmFin		//Administradora Financeira
	Data cIDCartao		//ID do cartใo
	Data cClassName		//Nome da classe

	Method New()		//Metodo construtor
	Method ClassName()	//Nome da classe

EndClass

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑบMetodo    ณNew            บAutor  ณVendas CRM     บ Data ณ  01/08/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Metodo construtor da classe LJNFCEPAG                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL1 - Objeto da classe LJNFCEPAG                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA / SIGAFRT                                         บฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method New(cForma, cValor, cAdmFin, cIdCartao) Class LJNFCEPAG

	Self:cForma		:= cForma
	Self:cValor		:= cValor
	Self:cAdmFin	:= cAdmFin
	Self:cIdCartao	:= cIdCartao
	Self:cClassName	:= "LJNFCEPAG"

Return Self

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑบMetodo    ณClassName     บAutor  ณVendas CRM      บ Data ณ  01/08/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Metodo para retornar o nome da classe                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL1 - String com o nome da classe LJNFCEPAG               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA / SIGAFRT                                         บฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ClassName() Class LJNFCEPAG
Return Self:cClassName

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณLjNfceGeraบAutor  ณVendas Cliente      บ Data ณ  16/04/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza todo o processo da NFC-e, aciona rotinas para:     บฑฑ
ฑฑบ          ณ Gerar XML, Envio do XML para TSS e Impressao DANFE         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณExpL := LjNfceGera( ExpC1, ExpC2, @ExpC3, ExpL1)			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ	ExpC1 - cL1Fil - Filial para posicionar SL1    			  บฑฑ
ฑฑบ				ExpC2 - cL1Num - Numero do Orcamento para posicionar SL1  บฑฑ
ฑฑบ				ExpC3 - @cChvNFCe - Guarda por referencia chave da NFCe   บฑฑ
ฑฑบ				ExpL1 - lReTrans - Sinaliza nova tentativa de envio NFCe  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL1 - Se realizou todo o processo: Envio+Impressao 		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Venda Assistida                                            บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function LjNFCeGera( cL1Fil		, cL1Num	, cChvNFCe	, lReTrans	,;
					 lDanfePad	, cMsgErro	, lNFCeTSS	, cProtNFCe	,;
					 cSituaNFCE	, cNovoDoc 	)
Local cXml 			:= ""
Local cXmlProt		:= ""
Local aAreaSL1		:= SL1->(GetArea())
Local aAreaSL2		:= SL2->(GetArea())
Local aAreaSL4		:= SL4->(GetArea())
Local nRet			:= -1
Local nRetImp		:= -1 												//Retorno da impressora
Local lPosiciona	:= .T.												//Sinaliza quando SL1 posicionado em registro diferente da Venda Atual, evitando Seek quando ja posicionado (houve situacao em ambiente de cliente onde o Seek falha quando ja posicionado)
Local lMVLJGRVON	:= SuperGetMV("MV_LJGRVON",,.T.)
Local lPOS			:= Iif(ExistFunc("STFIsPOS"), STFIsPOS(), .F.)		//indica se eh TOTVS PDV
Local aRetAux		:= {}
Local lTSSComOk		:= .F.
Local cEstSM0		:= IIf(!lEndFis, SM0->M0_ESTCOB, SM0->M0_ESTENT)
Local cL1Hora 		:= FwTimeUF(cEstSM0)[2]
Local cRetSEFAZ		:= ""												//protocolo de autoriza็ใo|codigo de resposta|descri็ใo da resposta do SEFAZ
Local lL1RETSFZ		:= SL1->(ColumnPos("L1_RETSFZ")) > 0				//campo o qual serแ gravado as informa็๕es de retorno da SEFAZ
Local oXMLProt		:= Nil												//objeto da classe TXMLManager o qual contem o XML de retorno da SEFAZ jแ instanciado	
Local lIsEnvOK		:= .T.
Local lLJ7111		:= ExistBlock("LJ7111")								//Verifica a existencia do P.E.
Local cTagCNF		:= ""												//C๓digo num้rico que comp๕e a Chave de Acesso. N๚mero aleat๓rio gerado pelo emitente para cada NF-e para evitar acessos indevidos da NF-e. 
Local oLOJGNFCE		:= Nil												//Armazena o Classe LOJGNFCE.
Local oLOJCNFCE		:= Nil												//Armazena o Classe LOJCNFCE.

// -- Remover apos dezembro de 2019.
Local dDtExist		:= CtoD("09/04/2019")								//Data utilizada na valida็ใo de fontes.	
Local lConsult		:= Iif(ExistFunc("LOJXNFCE") .AND. ExistFunc("LOJGNFCE"),GetApoInfo("LOJXNFCE.PRW")[4] >= dDtExist .AND. GetApoInfo("LOJGNFCE.PRW")[4] >= dDtExist,.F.)		//Valida็ใo para o uso de consulta de chave antes de inutiliza.

// --	Cancelamento / Inutiliza็ใo  
Local dDtInutPDV	:= CtoD("05/07/2019")								//Data utilizada na valida็ใo de fontes.	
Local lInutPDV		:= Iif(ExistFunc("LOJXNFCE") .AND. ExistFunc("LOJGNFCE") .AND. ExistFunc("LOJCNFCE") ,GetApoInfo("LOJXNFCE.PRW")[4] >= dDtInutPDV .AND. GetApoInfo("LOJGNFCE.PRW")[4] >= dDtInutPDV .AND. GetApoInfo("LOJCNFCE.PRW")[4] >= dDtInutPDV,.F.)		//Valida็ใo para o uso do cancelamento / inutiliza็ใo direto no PDV
// -- Remover apos dezembro de 2019.
 
Local dHVeraoI		:= SuperGetMV("MV_HVERAOI",.F.,CTOD('  /  /    '))
Local dHVeraoF		:= SuperGetMV("MV_HVERAOF",.F.,CTOD('  /  /    '))
Local lHverao 		:= .F.	
Local lPosLight		:= IsInCallStack("STBGrvBatch")	//-- Chamada pelo Totvs PDV? 
Local lPOS 			:= STFIsPOS() //Variavel que identifica se eh Totvs Pdv
Local cID			:= "" 	//Composicao do ID (chave interna para identifica็ใo do registro no TSS)
Local aRetConPrt 	:= {}	//Retorno do M้todo ConsultaProtocoloNfe

DEFAULT cL1Fil		:= ""	//L1_Filial para posiciona SL1
DEFAULT cL1Num		:= ""   //L1_Num para posiciona SL1
DEFAULT cChvNFCe    := ""   //Guarda chave para armazenar na SL1
DEFAULT lReTrans	:= .F.	//Sinaliza que esta retransmitindo para atualiza a Chave na SL1
DEFAULT lDanfePad	:= .T.	//mantido por questao de retrocompatibilidade
DEFAULT cMsgErro	:= ""
DEFAULT lNFCeTSS	:= .T. 	//Transmissใo por TSS
DEFAULT cProtNFCe 	:= "" 	//Protocolo nfc-e
DEFAULT cSituaNFCE	:= "" 	//Situa็ใo da NFCE
DEFAULT cNovoDoc	:= "" 	//Novo documento da NFCE

If lPOS
	/*
		Limpa as variaves estaticas do TSS para carregalas novamente
		antes do inicio da montagem do XML.
	*/
	LjNFCeClr(1)
	LjNFCeClr(2)
EndIf

//Verifica se  horแrio de verใo (compatibilidade com os demais modulos)
If !Empty(dHVeraoI) .And. !Empty(dHVeraoF) .And. dDataBase >= dHVeraoI .And. dDataBase <= dHVeraoF
	lHverao := .T.
EndIf
	
cL1Hora := FwTimeUF(cEstSM0,,lHverao)[2]

If Empty(cL1Hora)
	cL1Hora := Time()
EndIf

//iniciamos os vetores estaticos do LOJNFCE (al้m disso, verificamos a comunica็ใo com o servidor TSS)
If lNFCeTSS
	//Transmissใo de NFCE pelo TSS, sempre validem esse cenแrio, pode haver NFCE nใo transmitida pelo TSS
	If LjGetMVTSS()[1]	//verificamos se hแ conexใo com o servidor TSS
		// Verifica se pode emitir NFC-e com a versao configurada no TSS
		lTSSComOk := NT2016002()
		
		//Verifica se a UF permite emissao de NFC-e na modalidade 9-Conting๊cia Offline
		If lTSSComOk
			lTSSComOk := LjNFCeMod9()
		EndIf		
	Else
		cMsgErro := "Nใo hแ conexใo com o servidor TSS. Verifique as configura็๕es."
		lTSSComOk := .F.
	EndIf
Else
	//Transmissใo da NFCE pela lib de impressora, sempre validem esse cenแrio
	lTSSComOk := .T.
EndIf

If Len(cMsgErro)>0
	LjGrvLog(cL1Num, "Mensagem de Erro: ", cMsgErro)
EndIf

if lPosLight 
	STFMessage("STWFinisale3", "ALERT", "Coletando dados para emissใo da NFC-e")
	STFShowMessage( "STWFinisale3" )
endif

LjGrvLog(cL1Num,"Envio da NFC-e para o SEFAZ ",lTSSComOk)

If lTSSComOk	
		
	//Posiciona cabecalho da venda, demais tabelas(L2,L4) sao posicionadas na geracao do XML
	If ((SL1->L1_FILIAL + SL1->L1_NUM) <> ( cL1Fil+cL1Num ))
		lPosiciona := .F.
		DbSelectArea("SL1")
		SL1->(DbSetOrder(1))     // L1_FILIAL + L1_NUM
	EndIf
	
	If lPosiciona .OR. SL1->( DbSeek(cL1Fil+cL1Num) )

		//Blindagem NFC-e
		If LjBldValid(0,@cMsgErro, Substr(cChvNFCe,21,2) )

			cTagCNF := LjGeraCNF(SL1->L1_DOC)

			RecLock( "SL1", .F. )
			Replace SL1->L1_HORA with cL1Hora //Atualiza sempre a hora antes de transmitir para que nao ocorra problema de diferenca de limite de minutos
			SL1->( MsUnlock() )

			//Composicao do ID (chave interna para identifica็ใo do registro no TSS)
			cID := SL1->L1_SERIE+SL1->L1_DOC

			//obtem a chave eletronica da NFC-e
			cChvNFCe := LjChvNFCe(Nil, cTagCNF)
	
			LjGrvLog(cL1Num,"Chave eletronica obtida da NFC-e",cChvNFCe)

			//Monta XML na NFCe
			cXML := LjNFCeXML(cChvNFCe, @lIsEnvOK, Nil, cTagCNF)

			If lLJ7111 .And. lIsEnvOK //Ponto de entrada para a manipula็ใo do XML gerado// 
				LjGrvLog(cL1Num,"*** - Antes da execu็ใo do PE LJ7111 para a manipula็ใo do arquivo XML -  ***",cXML)
				cXML := Execblock( "LJ7111", .F., .F., { cXML } )
				LjGrvLog(cL1Num,"*** - Depois da execu็ใo do PE LJ7111 para a manipula็ใo do arquivo XML -  ***",cXML)
			EndIf

			//Mensagem de acompanhamento ao usuario para Totvs PDV
			if lPosLight
				STFMessage("STWFinisale3", "ALERT", "Transmitindo XML da NFC-e para o SEFAZ")
				STFShowMessage( "STWFinisale3" )
			endif

			LjGrvLog(cL1Num,"Valida็ใo da Nota - Nota sera enviada ?", lIsEnvOK)
			LjGrvLog(cL1Num,"CABECALHO XML",SubStr(cXML,1,len(cXML)-AT("<prod>",cXML)))
			LjGrvLog(cL1Num,"Transmitindo a NFC XML",SubStr(cXML,AT("<prod>",cXML)))
			LjGrvLog(cL1Num,"Transmitindo a NFC XML Completo",cXML)
	
			If lIsEnvOK
				//Comunica com TSS e transmite a Nota
				nRet := LjNFCeEnvia( @cXML, @cXMLProt, @cMsgErro,  lNFCeTSS, @cChvNFCe, @cProtNFCe, @cSituaNFCE, @cNovoDoc )
				
				//Consulto a chave das notas com retorno 0 ou -1, com isso conseguimos identificar se a venda foi autorizada e por alguma oscila็ใo na comunica็ใo com retorno negativo.
				If (nRet == 0 .OR. nRet == -1) .AND. lConsult .AND. !Empty(cChvNFCe) 
					
					oLOJGNFCE := LOJGNFCE():NEW()
					oLOJGNFCE:LjConsProtocoloNFCe(cID)
					aRetConPrt := oLOJGNFCE:aResultConsultaProtocoloNFCE
					LjGrvLog(Nil, "Executado M้todo ConsultaProtocoloNfe para verificar na SEFAZ o Status da NFC-e. NFC-e Consultada: [" +cID+ "]", {oLOJGNFCE:aResultTSS, aRetConPrt} )

					If oLOJGNFCE:aResultTSS[1] .AND. aRetConPrt[1]
						// -- Venda Transmitida e autorizada na sefaz, altero o nRet para 1 indicando que foi processado com sucesso.
						nRet := 1
						LjGrvLog(,"Documento recuperado com sucesso!")

						If Empty(cXml) .Or. Empty(cXmlProt)
							LjGrvLog(,"Recupera XML da NFCe")
							//Recupera XML da NFCe
							LjNFCeGet( @cXml, @cXmlProt )
						EndIf
					ElseIf !(oLOJGNFCE:aResultTSS[1])
						// -- Sem comunica็ใo com TSS
						LjGrvLog(,"Sem comunica็ใo com TSS, por esse motivo nใo serแ possivel consultar chave na SEFAZ.")
					ElseIf !(aRetConPrt[1]) .AND. oLOJGNFCE:aResultTSS[1]
						// -- Transmitida porem rejeitada.
						// -- Alteramos o nRet para venda rejeitada.
						nRet := -1
						LjGrvLog(,"Venda rejeitada, codigo: " + aRetConPrt[2] + " e descri็ใo: " + aRetConPrt[3])
						
						//Avisar o usuario do motivo retornado pelo TSS
						if lPosLight
							STFMessage("STWFinisale3", "POPUP", "Venda rejeitada, codigo: " + aRetConPrt[2] + " e descri็ใo: " + aRetConPrt[3])
							STFShowMessage( "STWFinisale3" )
						endif
					EndIf 
				EndIf 
			Else
				nRet := -1 //Erro na nota
			EndIf
			
			LjGrvLog(cL1Num,"NFC XML Completo apos a transmissao da Nota",cXML)
			LjGrvLog(cL1Num,"Apos Transmissao da Nota",nRet)
	
			Conout( "COMUNICACAO COM O TSS = " + cValToChar(nRet) )
		EndIf

	Else
		If !IsBlind()
			if lPosLight
				STFMessage("STWFinisale3", "ALERT", STR0001 + cL1Fil + STR0002 + cL1Num)
				STFShowMessage( "STWFinisale3" )
			else
				MsgStop(STR0001 + cL1Fil + STR0002 + cL1Num)	//"NFC-e LjNfceGera: Nao localizou registro na tabela SL1. L1_FILIAL:"   # //" - L1_NUM:"
			endif
		Else
			Conout(STR0001 + cL1Fil + STR0002 + cL1Num)		//"NFC-e LjNfceGera: Nao localizou registro na tabela SL1. L1_FILIAL:"   # //" - L1_NUM:"
			Help( ,, "NFCEORC404",, STR0001 + cL1Fil + STR0002 + cL1Num, 1, 0 )
		EndIf
	EndIf
EndIf

if lPosLight
	STFCleanInterfaceMessage()
endif

If lTSSComOk .AND. nRet == 1	//NFC-e processada com sucesso

	/*
	Se a nota foi transmitida na modalidade NORMAL, alimentamos o campo L1_RETSFZ com		
	N๚mero do Protocolo da NFC-e|C๓digo do status da resposta|Descri็ใo literal do status da resposta
	*/
	If lL1RETSFZ .AND. !Empty(cXMLProt)
		LJGrvLog(cL1Num, "XML retornado pela SEFAZ", cXMLProt)

		//converte o XML de retorno do SEFAZ em um objeto da classe TXML Manager
		aRetAux := LjXMLC2O(cXMLProt, "ns")
		If aRetAux[1]				
			oXMLProt := aRetAux[2]

			//As informacoes serao separadas por "|"
			cRetSEFAZ := oXMLProt:XPathGetNodeValue( "/ns:protNFe/ns:infProt/ns:nProt" ) + "|"	// N๚mero do Protocolo da NFC-e
			cRetSEFAZ += oXMLProt:XPathGetNodeValue( "/ns:protNFe/ns:infProt/ns:cStat" ) + "|"	// C๓digo do status da resposta
			cRetSEFAZ += oXMLProt:XPathGetNodeValue( "/ns:protNFe/ns:infProt/ns:xMotivo" )		// Descri็ใo literal do status da resposta

			FreeObj(oXMLProt)	//elimina o objeto da memoria
		Else
			LJGrvLog(cL1Num, "Falha ao converter o XML retornado pela SEFAZ")
		EndIf
	EndIf

	//Grava a chave
	LjGrvLog(cL1Num,"Atualiza a chave L1_KEYNFCE. Registro posicionado na SL1: " + SL1->L1_FILIAL+"|"+SL1->L1_NUM, cChvNFCe)
	If RecLock( "SL1", .F. )
		Replace SL1->L1_KEYNFCE with cChvNFCe
		
		If lL1RETSFZ .AND. !Empty(cRetSEFAZ)
			Replace SL1->L1_RETSFZ with cRetSEFAZ
		EndIf

		If NMODULO == 12
			Replace SL1->L1_SITUA with "T3" //T3=Processou a NFC-e (TSS)
		EndIf

		SL1->( MsUnlock() )

	Else
		LjGrvLog( cL1Num, "Falha ao reservar o registro para gravacao dos campos L1_KEYNFCE e/ou L1_RETSFZ" )
	EndIf

	if lPOS .And. !IsBlind()
		STFMessage(ProcName(), "ALERT", "Aguarde.. Imprimindo Danfinha...")
		STFShowMessage( ProcName() )
	endif
	LjGrvLog(cL1Num,"Iniciando Impressao da Danfe!")

	//Indica se a DANFE sera impressa		
	If lPos
		lDanfePad := STFShowMessage(ProcName(1))
	
		If ValType(lDanfePad) == "U"
			lDanfePad := !( isBlind() )
		Endif
	Else
		//A DANFE somente sera impressa se houver interface com usuario
		lDanfePad := !( isBlind() )
	EndIf
	
	If lNFCeTSS .AND. ( ExistFunc("U_LjRDnfNfce") .OR. ExistFunc("LjSCNfNFCe") ) //Tivemos problema devido ao IXBLOG, portanto chame como U_XXX
		
		If ExistFunc("LjSCNfNFCe")
			aRetAux := LjSCNfNFCe(cXML, cXMLProt, cChvNFCe, lDANFEPad, aItensNFCe, Substr(cChvNFCe,21,2) == "55" )
		Else
			aRetAux := U_LjRDnfNfce(cXML, cXMLProt, cChvNFCe, lDANFEPad, aItensNFCe, Substr(cChvNFCe,21,2) == "55" )
		EndIf

		If Len(aRetAux) > 0
			If ValType(aRetAux[1]) <> "L"
				aRetAux[1] = .T.
			EndIf
			
			nRetImp := Iif(aRetAux[1] , 0 , -1)

			If Len(aRetAux) > 1 .And. ValType(aRetAux[2]) == "C"
				cChvNFCe := aRetAux[2]
			EndIf
		Else
			nRetImp := -1
		EndIf
	Else

		If lNFCeTSS
			nRetImp := IIF( LjNFCeDANFE(cXml, cXmlProt,@cChvNFCe, lDanfePad, Substr(cChvNFCe,21,2) == "55"), 0, -1 )
		Else
			nRetImp := 0
			nRet 	:= 1 //LjDDanfeNFCe
		EndIf

	EndIf
	
	//Parametro que determina se a impressao do comprovante de NFC-e eh obrigatorio para poder concluir a venda.
	If SuperGetMV("MV_NFCEIMP",, 1) == 2 //Impressao do comprovante de NFC-e da venda: 1=Opcional; 2=Obrigatorio;
		If nRetImp == 0 
			nRet := 1 //Sucesso
		Else
			nRet := 0 //Problema
		EndIf
	EndIf
	
	LjGrvLog(cL1Num,"Resultado da impressao da Danfinha",nRetImp)
	LjGrvLog(cL1Num,"Chave eletronica da NFC-e",cChvNFCe)

	//Se houver Garantia Estendida na venda, realiza a impressใo do termo
	If nRet == 1 .AND. aTotNaoFis[2] > 0
		LjGrvLog(cL1Num,"Realiza as operacoes referente a Garantia Estendida",cChvNFCe)
		LjNFCeGE(3)
	EndIf

endif

if !lTSSComOk .or. nRet <> 1 
	/*
	nRet =  0	"NFC-e NAO houve comunicacao com o TSS"
	nRet = -1	"NFC-e Rejeitada
	*/
	
	lMsErroAuto := .T.
	
	If lInutPDV

		//Mensagem de acompanhamento ao usuario para Totvs PDV
		If lPosLight .and. !IsBlind()
			STFMessage(ProcName(), "ALERT", STR0162 ) //#"Transmitindo Inutiliza็ใo, aguarde!"
			STFShowMessage( ProcName() )
		EndIf
		
		// -- Inicio a inutiliza็ใo / Cancelamento enviando para o TSS direto pelo PDV
		oLOJCNFCE := LOJCNFCE():NEW()
		oLOJCNFCE:LjCancInut(SL1->(L1_SERIE+L1_DOC), Substring(cChvNFCe,21,2) )
		If oLOJCNFCE:aResultMetodo[1]
			LjGrvLog(cL1Num,"Inutiliza็ใo / Cancelamento Realizado direto pelo PDV DOC:" + SL1->L1_DOC + " Serie: " + SL1->L1_SERIE)
		Else
			LjGrvLog(cL1Num,"Nใo foi possivel Inutiliza / Cancelar a Nota direto pelo PDV, a Inutiliza็ใo / Cancelamento sera realizada pelo Job de cancelamentos.")
			LjGrvLog(cL1Num,"Motivo: " + oLOJCNFCE:aResultTSS[3])
		EndIf 

		//Limpa barra de status no Totvs PDV
		If lPosLight .and. !IsBlind()
			STFCleanInterfaceMessage()
		endif

	EndIf 

	//Verifica se o controle de cancelamento/inutilizacao de NFC-e sera pela tabela (SLX) ou sera pelo antigo tratamento (SL1)
	If !( SLX->(ColumnPos("LX_MODDOC")) > 0 .And. Iif(NMODULO==23,IF(lPOS,STBChkInut(),.T.),.T.) )
		//Com o novo conceito de incluir os dados do orcamento na SLX para que seja
		// feito o cancelamento/inutilizacao da numeracao da NFCE, este trecho somente
		// tem sentido quando nao existir o campo LX_MODDOC.
		//Com este novo tratamento o orcamento nao eh mais cancelado, ou seja, 
		//este continua disponivel para finalizar a venda novamente
		//e a numeracao da NFC-e apenas que eh inutilizada.  
		RecLock( "SL1", .F. )
		Replace SL1->L1_STORC with "A"
		Replace SL1->L1_NUMORIG with ""
		SL1->( MsUnlock() )
	EndIf
	
	//soh eh necessario gravar a chave, quando houver a transmissao para o TSS
	If nRet == 0
		LjGrvLog(cL1Num,"Limpa a Chave eletronica da NFC-e - Antes",cChvNFCe)
		cChvNFCe := ""
		LjGrvLog(cL1Num,"Limpa a Chave eletronica da NFC-e - Depois",cChvNFCe)
	EndIf
	
EndIf

//Quando retransmitindo a NFC-e, deve atualizar a chave e o L1_SITUA para processar GrvBatch
If nRet == 1 .AND. lReTrans
	LjGrvLog(cL1Num,"Vai atualizar a chave L1_KEYNFCE",cChvNFCe)
	LjGrvLog(cL1Num,"SL1 posicionado no EOF?",SL1->(EoF()))
	LjGrvLog(cL1Num,"Registro da SL1",SL1->L1_FILIAL+"|"+SL1->L1_NUM)
	RecLock( "SL1", .F. )
	Replace L1_KEYNFCE with cChvNFCe
	If !lMVLJGRVON
		Replace L1_SITUA with "RX"
	EndIf
	SL1->( MsUnlock() )
EndIf	


//Restaura Area                    
RestArea( aAreaSL1 )
RestArea( aAreaSL2 )
RestArea( aAreaSL4 )

// reseta as variaveis estaticas com os dados do TSS
LjNFCeClr(1)
LjNFCeClr(2)

LjGrvLog(cL1Num,"Retorno da funcao LjNFCeGera",nRet)

Return nRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณLjNfceEnviaบAutor ณVendas Cliente      บ Data ณ  16/04/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Envia Xml para o TSS via Web Service					      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ	ExpC1 - cXml - Parametro por referencia, a regra da Nfc-e บฑฑ  
ฑฑบ				estabele que deve ser considerado o Xml de retorno(Sefaz) บฑฑ
ฑฑบ				para gerar a Danfe.										  บฑฑ
ฑฑบ				ExpC2 - cXmlProt - Parametro por referencia,separara o    บฑฑ
ฑฑบ				protocolo de autorizacao da Nota, para tratar contingenciaบฑฑ
ฑฑบ				ExpL3 - lNFCETESS - Transmissใo por TSS                   บฑฑ
ฑฑบ				ExpC4 - cNFCeKey - Chave NFCe mobile                      บฑฑ
ฑฑบ				ExpC5 - cNFCeProt - Protocolo NFCe mobile                 บฑฑ
ฑฑบ				ExpC6 - cSituaNFCE - Status Transmissใo NFCe  mobile      บฑฑ
ฑฑบ				ExpC7 - cNovoDoc - Numero da NFCe Mobile                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL1 - Se conseguiu enviar para o TSS(WebService) 		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Venda Assistida                                            บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function LjNFCeEnvia( cXML, cXMLProt, cMsgErro ,lNFCeTSS, cNFCeKey, cNFCeProt, cSituaNFCE, cNovoDoc)

	Local cID			:= ""		//ID para facilitar localiza็ใo da nota no TSS
	Local nRet			:= -1		//Define retorno: -1 = Rejeicao (Quando rejeicao o numero da NFCe pode ser reutilizado), 0 = Nota Enviada mas nใo confirmada(lSucesso = .F.), deve-se realizar o cancelamento ou inutilizacao,  1 = Nota Enviada com Sucesso e Retorno do TSS lSucesso .T.
	Local cIdEnt		:= ""		//(Tabela:SPED001 do TSS)
	Local cURL			:= ""
	Local lEnvia		:= .T.
	Local lSucesso		:= .F.		//Sinaliza se NFC-e foi transmitida com sucesso
	Local lRejeicao		:= .F.		//Sinaliza se houve rejeicao
	Local lRet			:= .F.		//Retorno l๓gico
	Local lMobile 		:= IIF(ExistFunc("STFIsMobile") .AND. STFIsMobile(), .t. ,.F.)
	Local cDoc 			:= SL1->L1_DOC //Numero da NFCe
	Local cSerie 		:= SL1->L1_SERIE //Serie da NFCe
	Local cError 		:= ""	//Erro
	Local cWarning 		:= ""	//Aviso
	Local aNotas		:= {} 	//Array de Notas
	Local lTSSDemoOff 	:= .F.	//Parametro TSS demo (off-line)
	Local cMobNFCETSS 	:= "0"	//Tipo do TSS mobile
	Local aAreaSL1 		:= {}	//WorkArea SL1
	Local aAreaSL2 		:= {}	//WorkArea SL2
	Local aAreaSL4 		:= {}	//WorkArea SL4
	Local nNewRecno		:= 0	//Rehistro
	Local cCodErro		:= ""	//C๓digo do Erro
	Local cProcedim		:= ""	//Solu็ใo do procedimento para o usuแrio
	Local cModDoc		:= "65"	//-- Padrao Totvs PDV

	DEFAULT cXml 		:= ""
	DEFAULT cXmlProt 	:= ""
	DEFAULT cMsgErro	:= ""
	DEFAULT lNFCeTSS 	:= .T.
	DEFAULT cNFCeKey 	:= ""
	DEFAULT cNFCeProt	:= ""
	DEFAULT cNovoDoc	:= ""

	PRIVATE	oWS		 	:= nil		//deve ser private para utilizar o comando Type() para validar conteudo

	cMobNFCETSS	:= STFGetCfg("cMobNFCETSS", "0")
	lTSSDemoOff := IIF(ValType(cMobNFCETSS)="U", .F., cMobNFCETSS == "9")

	cID	 := SL1->L1_SERIE+SL1->L1_DOC //composicao do ID(chave interna para identifica็ใo do registro no TSS)

	if !Empty(SL1->L1_KEYNFCE) .and. Substr(SL1->L1_KEYNFCE,21,2) $ "55/65"
		cModDoc := Substr(SL1->L1_KEYNFCE,21,2)
	endif

	If lNFCeTSS

		cIdEnt := LjTSSIDENT( cModDoc )

		If lTSSDemoOff .AND. ValType(cIdEnt) == "U"
			cIdEnt := DtoS( Date() )
		EndIf

		If cIdEnt <> Nil
	
			While lEnvia
			
				lEnvia	:= .F.
				if cModDoc == "65"
					cURL   	:= PadR(GetNewPar("MV_NFCEURL","http://"),250)
				else
					cURL   	:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
				endif
			
				oWS													:= WSNFESBRA():new()
				oWS:_URL											:= AllTrim(cURL)+"/NFESBRA.apw"
				oWS:cUSERTOKEN										:= "TOTVS"
				oWS:cID_ENT											:= cIdEnt
				oWS:oWSREMESSA3ENVNOTAS								:= wsClassNew( "NFESBRA_REMESSA3ENVNOTAS" )
				oWS:oWSREMESSA3ENVNOTAS:oWSNOTAS					:= wsClassNew( "NFESBRA_ARRAYOFREMESSA3ENVNOTA" )
				oWS:oWSREMESSA3ENVNOTAS:oWSNOTAS:oWSREMESSA3ENVNOTA	:= {}
				aAdd( oWS:oWSREMESSA3ENVNOTAS:oWSNOTAS:oWSREMESSA3ENVNOTA, wsClassNew( "NFESBRA_REMESSA3ENVNOTA" ) )
				aTail( oWS:oWSREMESSA3ENVNOTAS:oWSNOTAS:oWSREMESSA3ENVNOTA ):cID		:= cID
				aTail( oWS:oWSREMESSA3ENVNOTAS:oWSNOTAS:oWSREMESSA3ENVNOTA ):cMODELO	:= cModDoc
				aTail( oWS:oWSREMESSA3ENVNOTAS:oWSNOTAS:oWSREMESSA3ENVNOTA ):cXML		:= cXml
			
			//Nใo ้ demo NFCe
				If !lTSSDemoOff
					lRet := oWS:REMESSA3()
				Else
					lRet := .T.
					lSucesso := .T.

					cXml 		:= cXML
					cXmlProt	:= cxm
				EndIf

				If ValType(lRet) <> "L" .OR. !lRet
					lRet := .F.
				
					If Empty( GetWscError(3) )
						cMsgErro := GetWscError(1)
					Else
						cMsgErro := GetWscError(3)
					EndIf
				
					If !IsBlind()
					//"NFC-e: Nใo foi possํvel transmitir NFC-e(Conexใo TSS)"  ## //"SIM" ## "NรO" //"Deseja tentar novamente?" // Timer de 30 segundos e caso passe o tempo nใo envie novamente
						If Aviso( STR0004, cMsgErro, {STR0006,STR0007},,,,,,30000,2) == 1
							lEnvia := .T.
						Else
							lEnvia := .F.
						EndIf
					Else
						conout(STR0004, cMsgErro)	//"NFC-e: Nใo foi possํvel transmitir NFC-e(Conexใo TSS)"
						Help( ,,"NFCETSS",, STR0004 + cMsgErro, 1, 0 )
					EndIf
					LjGrvLog( SL1->L1_NUM, "NFCETSS " + STR0004 + cMsgErro )
				EndIf

			EndDo
	
			If lRet	 .AND. !lTSSDemoOff
		         
			//Verifica se a transmissใo da NFC-e foi com Sucesso, quando ocorre erro, a (Propriedade foi adicionada na versใo 2.28)
				If Type("oWS:oWSREMESSA3RESULT:OWSNOTAS:OWSREMESSA3RETNOTA[1]:LSUCESSO") == "L"
					lSucesso := oWS:oWSREMESSA3RESULT:OWSNOTAS:OWSREMESSA3RETNOTA[1]:LSUCESSO
				Else
					If !IsBlind()
						MsgStop(STR0023)	//'NFC-e: TSS (TOTVS Service Sped) nใo possui a propriedade LSUCESSO. Verifique  a versใo do TSS(2.28 ou superior).'
					Else
						Conout(STR0023)		//'NFC-e: TSS (TOTVS Service Sped) nใo possui a propriedade LSUCESSO. Verifique  a versใo do TSS(2.28 ou superior).'
						Help( ,, "NFCETSSLSU",, STR0023, 1, 0 )
					EndIf
					
					LjGrvLog( SL1->L1_NUM, "NFCETSSLSU " + STR0023 )
				EndIf

				//Somente possui objeto de rejei็ใo quando ocorre erro(Exemplo: Schema XML, fuso horแrio)
				If Type("oWS:oWSREMESSA3RESULT:oWSNOTAS:oWSREMESSA3RETNOTA[1]:oWSREJEICAO") == "O"
	
					lRejeicao := .T.
					cCodErro := oWS:oWSREMESSA3RESULT:oWSNOTAS:oWSREMESSA3RETNOTA[1]:oWSREJEICAO:cCodigo
					cMsgErro := oWS:oWSREMESSA3RESULT:oWSNOTAS:oWSREMESSA3RETNOTA[1]:oWSREJEICAO:cDescricao
					cProcedim := ""
					
					If Len(Alltrim(cCodErro)) >= 2
						cProcedim := LjNfceMsPr(cCodErro)
					EndIf
				
					If !IsBlind()
						If !("Nota ja autorizada" $ cMsgErro) //Nใo deve mostrar a msg quando estแ autorizada, pois a nota esta OK (trocar pelo codigo)
							Aviso( STR0008+STR0010+cID, cMsgErro+cProcedim, {STR0009},3,,,,,30000,1)	//"NFC-e: Nใo foi possํvel transmitir NFC-e (Rejei็ใo TSS)"  ## "ID:" ## //"OK" //Timer de 30 segundos
						EndIf	
					Else
						Conout( STR0008 + STR0010 + cID, cMsgErro+cProcedim )			//"NFC-e: Nใo foi possํvel transmitir NFC-e (Rejei็ใo TSS)"  ## "ID:"
						Help( ,, "NFCEREJ",, STR0008 + STR0010 + cID + cMsgErro+cProcedim, 1, 0 )
					EndIf
					LjGrvLog( SL1->L1_NUM, "Rejei็ใo TSS: C๓digo " + cCodErro )
					LjGrvLog( SL1->L1_NUM, "Rejei็ใo TSS: Descri็ใo - " + cMsgErro )
	            
				ElseIf Type("oWS:oWSREMESSA3RESULT:oWSNOTAS") == "U" //Nใo retorna objeto da Nota quando ocorre erro
			
					lRejeicao := .T.
				
					If !IsBlind()
						Aviso( STR0011,"oWS:oWSREMESSA3RESULT:oWSNOTAS = Null",{"Ok"},3,,,,,30000,1)		//"NFC-e: Nใo foi possํvel transmitir NFC-e (Sem Objeto oWSNOTAS)" //Timer de 30 segundos
					Else
						conout( STR0011,"oWS:oWSREMESSA3RESULT:oWSNOTAS = Null")				//"NFC-e: Nใo foi possํvel transmitir NFC-e (Sem Objeto oWSNOTAS)"
						Help( ,, "NFCESEMNOT",, STR0008 + STR0010 + cID + "oWS:oWSREMESSA3RESULT:oWSNOTAS = Null", 1, 0 )
					EndIf

					LjGrvLog( SL1->L1_NUM, "NFCESEMNOT" + STR0008 + STR0010 + cID + "oWS:oWSREMESSA3RESULT:oWSNOTAS = Null" )
						
				Else
				//Atualiza XML, impressใo deve ser realizada com base no XML de Retorno
					cXML 		:= oWS:oWSREMESSA3RESULT:oWSNOTAS:OWSREMESSA3RETNOTA[1]:CXMLSIG
					cXMLProt	:= oWS:oWSREMESSA3RESULT:oWSNOTAS:OWSREMESSA3RETNOTA[1]:CXMLPROT
				
				//Valida a existencia do XML de retorno para nao ocasionar ERROR-LOG na impressao
					If Empty(cXML)
						lRejeicao 	:= .T.
						cMsgErro	:= "Nใo foi possํvel obter o XML de retorno"

						If !IsBlind()
							Aviso( "NFC-e: Nใo foi possํvel obter o XML de retorno. Verifique se a Entidade estแ configurada corretamente." + STR0010 + cID, cMsgErro, {"Ok"},3,,,,,30000,1)
						Else
							conout( "NFC-e: Nใo foi possํvel obter o XML de retorno. Verifique se a Entidade estแ configurada corretamente." + STR0010 + cID, cMsgErro)
							Help( ,, "NFCESEMXML",, "NFC-e: Nใo foi possํvel obter o XML de retorno. Verifique se a Entidade estแ configurada corretamente." + STR0010 + cID + cMsgErro, 1, 0 )
						EndIf

						LjGrvLog( SL1->L1_NUM, "NFCESEMXML" + "NFC-e: nใo foi possํvel obter o XML de retorno. Verifique se a Entidade estแ configurada corretamente." + STR0010 + cID + cMsgErro )

					EndIf
	
				EndIf
	
			EndIf
		EndIf

	Else
	//Transmissใo Lib Perif้rico
		If !lMobile .OR. ( GetPvProfString("Log", "LogEcf", "0", IIF(lMobile,  "", GetClientDir()) + "TOTVSAPI.INI") = "1")
			nHdltmp := FCREATE("NFCE_"+StrTran(Alltrim(cId),space(1),"_")+".xml")
			FWrite( nHdltmp, cXML)
			FClose(nHdltmp)
		EndIf
	
		cXmlProt := ""
	
		nHdltmp := 0
	
		oXML := NIL
		oXML := XmlParser(cXML, "_", @cError, @cWarning)
	
		If Empty(cError) .and. ValType(oXML) == "O"

			If !Empty(cSerie) .AND. Val(cSerie) <> Val(SL1->L1_SERIE)
				LjGrvLog(SL1->L1_NUM, "Erro na s้rie da NFCe")
				STFMessage("LjNFCeEnvia", "STOP", STR0044) //"Erro na s้rie da NFCe"
				STFShowMessage("LjNFCeEnvia")
				nRet := -1
			Else
			//Houve um incremento de numera็ใo de Nota, 
			//devido ao servi็o cair ap๓s a abertura do CF e o encerramento
				If Val(cDoc) > Val(SL1->L1_DOC)
					cNovoDoc := cDoc
				
					aNotas := { { "", SL1->L1_DOC}}
		
					aAreaSL1 := SL1->(GetArea())
					aAreaSL2 := SL2->(GetArea())
					aAreaSL4 := SL4->(GetArea())
				
					LjGrvLog(SL1->L1_NUM, " gerando numeracao inutilizada origem " + SL1->(L1_FILIAL+L1_NUM) + " doc " + SL1->L1_DOC + " doc ncfce " + cDoc)
				
					While Val(aNotas[1][2]) < Val(cDoc)
		
					//Implementar duplica็ใo do or็amento
				
					//Replicar tabelas da venda (SL1, SL2 e SL4), seu retorno ้ o recno do novo registro na tabela SL1
						If ExistFunc("F271GCopyVenda")

							nNewRecno := F271GCopyVenda(SL1->(L1_FILIAL+L1_NUM))
							SL1->(DBGoTo( nNewRecno ))
					
						//Altera campos chaves para o cancelamento da NFC-e (nota) atual que foi rejeitada (registro novo ["copia"])
							RecLock("SL1", .F.)
							SL1->L1_SITUA := "I8" //NFCe intulizada
							SL1->( MsUnLock() )

							LjGrvLog(SL1->L1_NUM, " gerando numeracao inutilizada " + SL1->(L1_FILIAL+L1_NUM) + " doc " + SL1->L1_DOC + " doc ncfce " + cDoc)

							aNotas := {}
							LjxDNota( SL1->L1_SERIE, 3, .F., 1, @aNotas )

						EndIf
					
					EndDo
				
					RestArea(aAreaSL1)
					RestArea(aAreaSL2)
					RestArea(aAreaSL4)

				//Joga a numera็ใo com zeros para seguir modelo do loja
					If Val(aNotas[1][2]) == Val(cDoc)
						cNovoDoc := aNotas[1][2]
					EndIf
					LjGrvLog(SL1->L1_NUM, " Gerado numeracao inutilizada origem " + SL1->(L1_FILIAL+L1_NUM) + " doc " + SL1->L1_DOC + " doc ncfce " + cDoc)
				
				EndIf

			EndIf

			If nRet == 0 .OR. nRet == 2 .OR. nRet == 3
				lRet := .T.
				lSucesso := .T.
				cSituaNFCE := Str(nRet,1)
			EndIf
		EndIf

		If oXML <> NIL
			oXML := FreeObj(oXML)
			oXML := NIL
		EndIf

	EndIf

	If lRejeicao
		nRet := -1
	ElseIf !lSucesso
		nRet := 0
	ElseIf lSucesso .AND. !lRejeicao
		nRet := 1
	EndIf
	
	LjGrvLog( SL1->L1_NUM, "XML RETORNO TSS " + cXML )
	
	If !empty(cMsgErro)
		LjGrvLog( SL1->L1_NUM, "Houve um erro " + cMsgErro )
	EndIf
	
Return nRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณLjNFCeDANFEบAutor ณVendas Cliente      บ Data ณ  16/04/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Imprime Danfe(Vulgo: Danfinha)						      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL1 - Se conseguiu Imprimir						 		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Venda Assistida                                            บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function LjNFCeDANFE( cXML	, cXMLProt, cChvNFCe, lDANFEPad,;
 							 lNFe 	)
	Local nX			:= 0
	Local nY			:= 0
	Local aFormas		:= {}
	Local lRet			:= .T. 								//Retorna se conseguiu transmitir a Nota, nใo deve retornar erro caso ocorra problema de impressao
	Local lCondensa		:= SuperGetMV("MV_LJCONDE",,.T.)
	Local cTexto		:= ""
	Local cCrLf			:= Chr(10)
	Local cTagCondIni	:= Iif(lCondensa, TAG_CONDEN_INI , "")
	Local cTagCondFim	:= IIf(lCondensa, TAG_CONDEN_FIM , "")
	Local cTracejado 	:= IIf(lCondensa, Replicate("-",56), Replicate("-",31))
	Local cLinha		:= TAG_CENTER_INI + cTagCondIni + cTracejado + cTagCondFim + TAG_CENTER_FIM + cCrLf
	Local cKeyQrCode	:= ""
	Local cTextoTemp	:= ""
	Local lContigen 	:= .T. 								//Sinaliza emissao em modo de contingencia
	Local cProtAuto		:= ""								//Chave de Autorizacao
	Local cAmbiente		:= ""
	Local cDtHoraAut	:= ""
	Local lL2TotImp		:= SL2->(ColumnPos ("L2_TOTIMP")) > 0
	Local nTotImpNCM	:= 0
	Local nTotVLRNCM	:= 0
	Local nItemQtde		:= 0
	Local nItemUnit		:= 0
	Local nItemTotal	:= 0
	Local nTotDesc		:= 0
	Local nTotAcresc	:= 0								//somatoria do acrescimo da venda (frete)
	Local nDecVRUNIT	:= TamSX3("L2_VRUNIT")[2]			//quantidade de casas decimais a serem impressas no campo VlUnit do DANFE
	Local cInscMun		:= ""
	Local aEmitNfce		:= {}								//dados do emitente
	Local aIdNfce		:= {}								//dados de Identificacao da Nfc-e
	Local aPagNfce		:= {}								//dados dos pagtos
	Local aTotal		:= {}								//Totais(NF,Desconto,ICMS...)
	Local nSaltoLn		:= SuperGetMV("MV_FTTEFLI",, 1)		// Linha pula entre comprovante
	Local lGuil			:= SuperGetMV("MV_FTTEFGU",, .T.)	// Ativa guilhotina
	Local lLj7084		:= .T.								// retorno do PE LJ7084
	Local lPOS			:= STFIsPOS()
	Local nContItImp	:= 0								//Contador de itens a serem impressos
	Local aInfCpl		:= {}								//vetor com as mensagens que possuem quebra de linha
	Local nInfCpl		:= 0								//quantidade de quebra de linhas
	Local nMVNFCEDES	:= SuperGetMV("MV_NFCEDES",, 0)		// Exibe ou nใo desconto por item na DANFE NFC-e
	Local lTSSDemoOff 	:= .F.								//Parametro TSS demo (off-line)
	Local cMobNFCETSS 	:= "0" 								//Tipo do TSS mobile
	Local cXMLFile 		:= "" 								//arquivo XML
	Local cL2ItemAnt	:= ""
	Local nRet			:= 0
	Local aMensagem		:= ""
	Local cImpressora	:= LjGetStation("IMPFISC")
	Local cPorta		:= LjGetStation("PORTIF")
	Local lContinua		:= .F.
	Local cVersao		:= ""
	Local lImpConting	:= .F.
	Local lClasImpNfce	:= ExistFunc("LNfceTemCo")
	Local oLojINfce		:= IIF( lClasImpNfce , LOJINFCE():New(), NIL ) 		
	Local lEpson		:= "EPSON" $ LJGetStation("IMPFISC")

	cMobNFCETSS			:= STFGetCfg("cMobNFCETSS", "0")
	lTSSDemoOff			:= IIF(ValType(cMobNFCETSS)="U", .F., cMobNFCETSS == "9")

	DEFAULT cXml 		:= ""
	DEFAULT cXmlProt	:= ""
	DEFAULT cChvNFCe	:= ""
	DEFAULT lDanfePad	:= .T.
	DEFAULT lNFe		:= .F.

//declaramos como PRIVATE, pois precisamos usar o TYPE para validar se determinadas tags existem nos objetos retornados pelo XMLParser
	Private oNFCe				//retorno do XML da NFCe funcao convertido para objeto
	Private oProt				//retorno do XML do protocolo de autorizacao convertido para objeto
	Private aDestNFCe	:= {}	//dados do destinatแrio
	Private aItemNFCe	:= {}	//dados dos itens

	BEGIN SEQUENCE

	//-----------------------------------------------------
	// Conversao XML da NFC-e e do Protocolo de Autorizacao
	//-----------------------------------------------------
		aRet := LjXMLNFCe(cXML)

		//Eventualmente o TSS nใo retorna o XML, gerando errorlog, possivel causa alto consumo das threads
		If aRet[1] .and. !Empty(cXML)
			oNFCe := aRet[2]
		Else
			BREAK
		EndIf
	
		aRet := LjXMLNFCe(cXMLProt)
		If aRet[1]
			oProt := aRet[2]
		Else
			BREAK
		EndIf
	
		/*
			Armazena a chave que estแ no arquivo XML, pois se o ERP enviar uma nota na modalidade NORMAL e o TSS ter entrado 
			em CONTINGENCIA de forma automatica, o elemento MODALIDADE da chave eletronica sera substituido pelo TSS	
		*/
		LjGrvLog(SL1->L1_NUM,"Chave eletronica da NFC-e - Antes",cChvNFCe)
		cChvNFCe := StrTran(oNFCe:_NFE:_INFNFE:_ID:TEXT, "NFe")	//Chave da NFC-e
		LjGrvLog(SL1->L1_NUM,"Chave eletronica da NFC-e - Depois",cChvNFCe)
		
		cVersao	:= AllTrim(oNFCe:_NFE:_INFNFE:_VERSAO:TEXT)

	//------------------------
	// Ponto de Entrada LJ7084
	//------------------------
	// Permite definir o que serแ realizado com os dados do DANFE
	// ex: customizar a impressao, e-mail, sms ou nao imprimir
	// .T. - apos a execucao do ponto de entrada, realiza a impressao padrao do DANFE
	// .F. - apos a execucao do ponto de entrada, NAO realiza a impressao padrao do DANFE
		If ExistBlock("LJ7084")
			LjGrvLog( NIL, "Antes da execu็ใo do PE LJ7084")
			lLj7084 := ExecBlock( "LJ7084", .F., .F., {oNFCe, oProt} )
			LjGrvLog( NIL, "Depois da execu็ใo do PE LJ7084", lLj7084)
			If ValType(lLj7084) <> "L"
				lLj7084 = .T.
			EndIf
		EndIf

	//--------------------------
	// Impressao padrao do DANFE
	//--------------------------
		If lDanfePad .AND. lLJ7084

		//----------------------------------------
		// Comunicacao com a impressora nao fiscal
		//----------------------------------------
			If !lPos .AND. nHdlECF == -1
				cImpressora	:= LJGetStation("IMPFISC")
				cPorta := "AUTO"

				If !IsBlind()
					LjMsgRun( "Aguarde. Abrindo a Impressora Nใo Fiscal...",, { || nHdlECF := INFAbrir( cImpressora,cPorta ) } )
				Else
					conout("Aguarde. Abrindo a Impressora...")
					nHdlECF := INFAbrir( cImpressora,cPorta )
				EndIf

				//Verifica se houve comunicacao com a impressora
				If nHdlECF == -1
					If !IsBlind()
						If ExistFunc("INFCon")	// LOJXECF.PRX
							// Se obrigar a impressao, verifica se a impressora estแ conectada
							lObrigaImp := LjObgCpVen(@aMensagem)

							If lObrigaImp
								
								lContinua := INFCon(.T.)	// Testa comunicacao com ECNF

								If !lContinua .And. Len(aMensagem) > 0
									Aviso( aMensagem[1], aMensagem[2], {aMensagem[3]} )
								EndIf
							EndIf
						EndIf
					Else
						conout("NFC-e: Nใo foi possํvel estabelecer comunica็ใo com a Impressora:" + cImpressora)
						//nao ha necessidade de retornar erro quando houver erro de impressora
					EndIf
					
					If !lContinua
						//aborta a impressao
						BREAK
					EndIf
				EndIf
			EndIf
		
		//Valida se existe nDecimais, variavel ้ Privete declarada no Loja701
			If Type("nDecimais") == "U"
				nDecimais := MsDecimais(1)				// Quantidade de casas decimais
			EndIf

			aFormas := LjDfRetFrm()

		//Verifica se conseguiu montar o objeto do XML e sinaliza nao contingencia 
			If Type("oProt:_PROTNFE:_INFPROT:_NPROT") == "O"
				cProtAuto 	:= AllTrim(oProt:_PROTNFE:_INFPROT:_NPROT:TEXT)
				lContigen	:= .F.

				If Type("oProt:_PROTNFE:_INFPROT:_DHRECBTO") == "O"
					cDtHoraAut := oProt:_PROTNFE:_INFPROT:_DHRECBTO:TEXT
					cProtAuto += " " + SubStr(cDtHoraAut,9,2) + "/" + SubStr(cDtHoraAut,6,2)  + "/" + SubStr(cDtHoraAut,1,4) 	//Data
					cProtAuto += " " + SubStr(cDtHoraAut,12,2) + ":" + SubStr(cDtHoraAut,15,2)  + ":" + SubStr(cDtHoraAut,18,2)  //Hora
				EndIf
			EndIf

		//------------------------------------------------------------
		//Separa objetos do XML para facilitar a manipulacao dos dados
		//------------------------------------------------------------
			aEmitNfce	:= oNfce:_NFE:_INFNFE:_EMIT 		//Emitente
		
		//Ambiente (Normal ou Homologa็ใo)
			cAmbiente := oNFCe:_NFE:_INFNFE:_IDE:_TPAMB:TEXT

		//Quando nใo informa CPF/CNPJ, nใo retorna o objeto _DEST
			If Type("oNfce:_NFE:_INFNFE:_DEST") == "O"
				aDestNfce	:= oNfce:_NFE:_INFNFE:_DEST 	//Destinatแrio
			EndIf
		
			aIdNfce		:= oNfce:_NFE:_INFNFE:_IDE			//Detalhe da NFC-e

			//Quando possui apenas um item, nใo retorna um Array de _PAG e sim os detalhes da Forma de Pagto, caso contrario retorna Array
			If cVersao >= "4.00"
				If Type("oNfce:_NFE:_INFNFE:_PAG:_DETPAG[1]") == "O"
					aPagNfce := oNfce:_NFE:_INFNFE:_PAG:_DETPAG
				Else
					aAdd(aPagNfce, oNfce:_NFE:_INFNFE:_PAG:_DETPAG)
				EndIf
			Else
				If Type("oNfce:_NFE:_INFNFE:_PAG[1]") == "O"
					aPagNfce := oNfce:_NFE:_INFNFE:_PAG
				Else
					aAdd(aPagNfce, oNfce:_NFE:_INFNFE:_PAG)
				EndIf
			EndIf

			//Quando possui apenas um item, nใo retorna um Array de _DET e sim os detalhes do produto, caso contrario retorna Array
			If Type("oNfce:_NFE:_INFNFE:_DET[1]") == "O"
				aItemNfce	:= oNfce:_NFE:_INFNFE:_DET
			Else
				aAdd( aItemNfce, oNfce:_NFE:_INFNFE:_DET )
			EndIf

			//Total da NF
			aTotal := oNfce:_NFE:_INFNFE:_TOTAL
			
			/*Verifica compatibilidade de Impressao: 4-DANFE Detalhada e 5-DANFE Resumida
				0=Sem gera็ใo de DANFE; 
				1=DANFE normal, Retrato; 
				2=DANFE normal, Paisagem; 
				3=DANFE Simplificado; 
				4=DANFE NFC-e; 
				5=DANFE NFC-e em mensagem eletr๔nica (o envio de mensagem eletr๔nica pode ser feita de forma simultโnea com a impressใo do DANFE; usar o tpImp=5 quando esta for a ๚nica forma de disponibiliza็ใo do DANFE).
				
				O parametro MV_NFTPIMP controla o preenchimento da TAG
			*/
			//Verifica compatibilidade de Impressao: 4-DANFE Detalhada e 5-DANFE Resumida
			If !aIdNfce:_TPIMP:TEXT $ iif(lNFe,"123","45")
				If !IsBlind()
					MsgStop(STR0014+aIdNfce:_TPIMP:TEXT)	//"Nfc-e: Tipo de Impressใo incompatํvel: "
				Else
					Conout(STR0014+aIdNfce:_TPIMP:TEXT)		//"Nfc-e: Tipo de Impressใo incompatํvel: "
				EndIf
			//aborta a rotina de impressao
				BREAK
			EndIf

		//
		// Divisใo I - Informa็๕es do Cabe็alho
		//
			If Type("aEmitNfce:_IM") == "O"
				cInscMun := " IM:"+aEmitNfce:_IM:TEXT
			EndIf
			cTexto += TAG_BMP_INI+TAG_BMP_FIM  //Logo da NFC-e, deve estar carregado na impressora(Utilizar Tool para carregar imagem)
			cTexto += cTagCondIni + AllTrim(aEmitNfce:_XNOME:TEXT) + cCrLf 						//Denomina็ใo do Emitente
			cTexto += AllTrim("CNPJ:" + aEmitNfce:_CNPJ:TEXT + " / IE:" + aEmitNfce:_IE:TEXT + cInscMun) + cCrLf	//CNPJ do Emitente //Inscri็ใo Estadual do Emitente
			cTexto += AllTrim(aEmitNfce:_ENDEREMIT:_XLGR:TEXT) + ;
				" Nr." + AllTrim(aEmitNfce:_ENDEREMIT:_NRO:TEXT) + "," + ;
				AllTrim(aEmitNfce:_ENDEREMIT:_XBAIRRO:TEXT) + "," + ;
				AllTrim(aEmitNfce:_ENDEREMIT:_XMUN:TEXT) + ", " + ;
				AllTrim(aEmitNfce:_ENDEREMIT:_UF:TEXT) + cTagCondFim + cCrLf		//Endere็o do Emitente
			cTexto += cLinha

		//
		// Divisใo II – Informa็๕es Fixas do DANFE NFC-e
		//		
			if lEpson
				cTexto += cCrLf + cLinha
			endif

			cTexto += TAG_CENTER_INI+cTagCondIni+"DANFE NFC-e - Documento Auxiliar" + cTagCondFim+TAG_CENTER_FIM + cCrLf
			cTexto += TAG_CENTER_INI+cTagCondIni+"da Nota Fiscal Eletr๔nica para Consumidor Final" + cTagCondFim+TAG_CENTER_FIM+ cCrLf
			
			//Mensagem nao deve ser apresentada para o Estado PR
			If !LjAnalisaLeg(78)[1]
			     cTexto += TAG_CENTER_INI+cTagCondIni+"Nใo permite aproveitamento de cr้dito de ICMS" + cTagCondFim+TAG_CENTER_FIM + cCrLf
			EndIf
			
			cTexto += cLinha

		//
		// Divisใo III – Informa็๕es de Detalhe da Venda
		// * a impressao dessa divisใo ้ opcional ou conforme definido por UF
		// 
			cTexto += cTagCondIni+TAG_NEGRITO_INI+"Codigo          Descricao       Qtd Un   VlUnit.  VlTotal"+TAG_NEGRITO_FIM+cTagCondFim+ cCrLf

			For nX := 1 to Len(aItemNfce)

				nContItImp++ //Contador de itens a serem impressos

				nItemQtde	:= Val(aItemNfce[nX]:_PROD:_QCOM:TEXT)
				nItemUnit 	:= Val(aItemNfce[nX]:_PROD:_VUNCOM:TEXT)
				nItemTotal	:= Val(aItemNfce[nX]:_PROD:_VPROD:TEXT)

			//Quando desconto, subtrai do valor do item
				If Type("aItemNfce["+AllTrim(Str(nX))+"]:_PROD:_VDESC") == "O"
					nTotDesc += Val(aItemNfce[nX]:_PROD:_VDESC:TEXT)
				EndIf

			//Acumulamos o acrescimo (Frete/Seguro/Despesa)
				If Type("aItemNfce["+AllTrim(Str(nX))+"]:_PROD:_VOUTRO") == "O"
					nTotAcresc += Val(aItemNfce[nX]:_PROD:_VOUTRO:TEXT)
				EndIf

				cTexto += TAG_CONDEN_INI
				cTexto += PADR(aItemNfce[nX]:_PROD:_CPROD:TEXT,15)		+ " "	//Codigo de Produto
			
			//Se a Descricao for maior que 12 caracteres, imprimimos a descricao em uma linha soh e os outros 
			// campos na linha seguinte, caso contrario, todas as informacoes sao impressas em uma linha unica
				If Len(aItemNfce[nX]:_PROD:_XPROD:TEXT) > 13
					cTexto += PADR(aItemNfce[nX]:_PROD:_XPROD:TEXT,40)	+ " "	//Descricao de Produto
					cTexto += Space(28)
				Else
					cTexto += PADR(aItemNfce[nX]:_PROD:_XPROD:TEXT,12)	+ " "	//Descricao de Produto
				EndIf
			
				cTexto += PADL(AllTrim(Str(nItemQtde)),6) 				+ " "					//Qtde
				cTexto += PADR(aItemNfce[nX]:_PROD:_UCOM:TEXT,2)		+ " "					//Unidade de Medida
				cTexto += PadL(AllTrim(Str(nItemUnit ,(21-nDecVRUNIT), nDecVRUNIT)),8)	+ " "	//Valor Unit.
				cTexto += PADL(AllTrim(Str(nItemTotal,18, 2)),8) 			  				+ "  "	//Valor Total
			
				If nMVNFCEDES == 1
					If Type("aItemNfce["+AllTrim(Str(nX))+"]:_PROD:_VDESC") == "O"
						cTexto += PADR("Desconto no Item " + aItemNfce[nX]:_PROD:_CPROD:TEXT, 29)
						cTexto += PADL("-" + AllTrim(Str(Val(aItemNfce[nX]:_PROD:_VDESC:TEXT),18, 2)),26)
					EndIf
				EndIf
			
				cTexto += TAG_CONDEN_FIM + cCRLF

				//Tratamento necessแrio pois dependendo tamanho das informa็๕es dos itens a serem impressos,
				//apos um determinado tamanho o texto nใo ้ impresso, gerenado o erro de DEBUG/TOTVSAPI na DLL.
				//para isso foi quebrada a impressใo em 50 itens.
				If nContItImp == 30  .AND. !lTSSDemoOff
					
					lImpConting := .F.
					If lClasImpNfce
						//Se retorno for falso, nใo houve impressใo em contingencia
						lImpConting := oLojINfce:ImpMsgCon(lContigen, @cTexto, @nRet)
					EndIf
					
					If !lImpConting
						If lPos							
							nRet := STWPrintTextNotFiscal(cTexto)
						Else
							nRet := INFTexto(cTexto)
						EndIf
					EndIf
					cTexto := ""
					nContItImp := 0
				EndIf

			Next nX
			cTexto += cLinha
			
		//
		// Divisใo IV – Informa็๕es de Total do DANFE NFC-e
		//
			cTexto += cTagCondIni+"Qtd. Total de Itens"+cTagCondFim + cTagCondIni + PADL( AllTrim( Str(Len(aItemNfce)) ),37 ) + cTagCondFim + cCrLf
			cTexto += cTagCondIni+"Valor Total R$"+cTagCondFim + cTagCondIni + PADL(AllTrim(Str(Val(aTotal:_ICMSTOT:_VNF:TEXT),18,2)),42) + cTagCondFim + cCrLf
		
			If nTotDesc > 0
				cTexto += cTagCondIni + "Valor Descontos R$" + cTagCondFim + cTagCondIni + PADL(AllTrim(Str(nTotDesc,18,2)),39) + cTagCondFim + cCrLf
			EndIf
		
			If nTotAcresc > 0
				cTexto += cTagCondIni + "Valor Acrescimos R$" + cTagCondFim + cTagCondIni + PADL(AllTrim(Str(nTotAcresc,18,2)),39) + cTagCondFim + cCrLf
			EndIf

			if lEpson
				cTexto += cCrLf
			endif

			cTexto += TAG_NORMAL_INI+TAG_NEGRITO_INI+"Forma de Pagamento                    Valor Pago"+TAG_NEGRITO_FIM+TAG_NORMAL_FIM + cCrLf
		
			For nX := 1 to Len(aPagNFCe)
							
				If (nY := aScan(aFormas,{|x| Alltrim(x[2]) == Alltrim(aPagNfce[nX]:_TPAG:TEXT) })) > 0
					cTexto += cTagCondIni+aFormas[nY][1] +;
						PADL( AllTrim(Str(Val(aPagNfce[nX]:_VPAG:TEXT),18,2)),39 )+ cTagCondFim + cCrLf
				Else
					cTexto += cTagCondIni + "OUTROS" +;
						PadL( AllTrim(Str(Val(aPagNfce[nX]:_VPAG:TEXT),18,2)),39 )+ cTagCondFim + cCrLf
				EndIf
			
			Next nX

		//
		// Divisใo V – Informa็๕es dos Tributos no DANFE NFC-e
		//
			If lL2TotImp
		
			//Totaliza Imposto
				DbSelectArea("SL2")
				SL2->(DbSeek(xFilial("SL2")+SL1->L1_NUM))
				cL2ItemAnt := ""

				While SL2->( !Eof() ) .AND. ( xFilial("SL2") + SL1->L1_NUM == SL2->L2_FILIAL + SL2->L2_NUM )
					If RTrim(cL2ItemAnt) <> RTrim(SL2->L2_ITEM)
						nTotImpNCM += SL2->L2_TOTIMP
						nTotVLRNCM += SL2->L2_VLRITEM
					EndIf
				
					cL2ItemAnt := SL2->L2_ITEM
					SL2->( dbSkip() )
				End

				cTexto += cLinha
				if lEpson
					cTexto += cCrLf
				endif
				cTexto += TAG_CONDEN_INI + Lj950ImpNC(nTotVLRNCM,nTotImpNCM,nDecimais, .T.) + TAG_CONDEN_FIM + cCrLf
		
			EndIf
			cTexto += cLinha
			
		//
		//Divisใo Va – Mensagem de Interesse do Contribuinte
		//Conte๚do da tag <infCpl> - Informa็๕es Complementares
		//
			If Type("oNfce:_NFE:_INFNFE:_INFADIC") == "O"
				cTexto += TAG_CENTER_INI + TAG_NEGRITO_INI

			//para que haja a quebra de linha durante a impressao, separamos cada linha por |
				aInfCpl := StrToKArr(oNfce:_NFE:_INFNFE:_INFADIC:_INFCPL:TEXT, "|")
				nInfCpl := Len( aInfCpl )	//quantidade de quebra de linhas
				For nY := 1 to nInfCpl
					cTexto += aInfCpl[nY]
					If nY <> nInfCpl
						cTexto += cCrLf
					EndIf
				Next

				cTexto += TAG_NEGRITO_FIM + TAG_CENTER_FIM + cCrLf
			EndIf
			cTexto += cLinha

		//
		// Divisใo VI – Mensagem Fiscal e Informa็๕es da Consulta via Chave de Acesso
		//
			If cAmbiente == "2"
				cTexto += TAG_CENTER_INI+ TAG_NEGRITO_INI +"EMITIDA EM AMBIENTE DE TESTE - SEM VALOR FISCAL" + TAG_NEGRITO_FIM + TAG_CENTER_FIM + cCrLf
			EndIf

			If lContigen
				cTexto += TAG_CENTER_INI+ TAG_NEGRITO_INI +"NFC-e EMITIDA EM CONTINGสNCIA" + TAG_NEGRITO_FIM + TAG_CENTER_FIM + cCrLf
			EndIf

			cTexto += cTagCondIni
			cTexto += "Numero:" + aIdNfce:_NNF:TEXT 								//N๚mero da NFC-e
			cTexto += " Serie:" + aIdNfce:_SERIE:TEXT 								//S้rie da NFC-e
			cTexto += " Emissao:"
			cTexto += " " + SubStr(aIdNfce:_DHEMI:TEXT,9,2) + "/" + SubStr(aIdNfce:_DHEMI:TEXT,6,2)  + "/" + SubStr(aIdNfce:_DHEMI:TEXT,1,4) 	//Data
			cTexto += " " + SubStr(aIdNfce:_DHEMI:TEXT,12,2) + ":" + SubStr(aIdNfce:_DHEMI:TEXT,15,2)  + ":" + SubStr(aIdNfce:_DHEMI:TEXT,18,2)  //Hora
			cTexto += cTagCondFim + cCrLf
			
			If lClasImpNfce
				oLojINfce:lConting := lContigen				
				oLojINfce:RetMsgCon(lContigen)
				If !Empty(AllTrim(oLojINfce:cMsgConting))
					cTexto += oLojINfce:cMsgConting
				EndIf
			EndIf
		
			cTexto += TAG_CENTER_INI+cTagCondIni+"Via Consumidor"+cTagCondFim+ TAG_CENTER_FIM + cCrLf
		
			cTexto += cLinha
			cTexto += TAG_CENTER_INI+cTagCondIni+" Consulte pela chave de acesso em: " + cTagCondFim+TAG_CENTER_FIM + cCrLf
		
			cTexto += TAG_CENTER_INI+cTagCondIni+ LjNFCeURL(cAmbiente, .T.) + cTagCondFim+TAG_CENTER_FIM + cCrLf
		
			cTexto += TAG_CENTER_INI+ "Chave de Acesso" + TAG_CENTER_FIM + cCrLf	//A frase “CHAVE DE ACESSO”, em caixa alta;

			cTexto += TAG_CENTER_INI+cTagCondIni
			cTexto += SubStr(cChvNFCe, 1,4) + " "
			cTexto += SubStr(cChvNFCe, 5,4) + " "
			cTexto += SubStr(cChvNFCe, 9,4) + " "
			cTexto += SubStr(cChvNFCe,13,4) + " "
			cTexto += SubStr(cChvNFCe,17,4) + " "
			cTexto += SubStr(cChvNFCe,21,4) + " "
			cTexto += SubStr(cChvNFCe,25,4) + " "
			cTexto += SubStr(cChvNFCe,29,4) + " "
			cTexto += SubStr(cChvNFCe,33,4) + " "
			cTexto += SubStr(cChvNFCe,37,4) + " "
			cTexto += SubStr(cChvNFCe,41,4)
			cTexto += cTagCondFim+TAG_CENTER_FIM	+ cCrLf
			cTexto += cLinha

		//
		// Divisใo VII – Informa็๕es sobre o Consumidor
		//
			cTexto += TAG_CENTER_INI+"Consumidor"+TAG_CENTER_FIM+ cCrLf
			cTexto += TAG_CENTER_INI+cTagCondIni
			If Empty(aDestNfce)
				cTexto += "Consumidor nao identificado" + cCrLf //Deve constar a palavra "CONSUMIDOR" centralizada e em caixa alta
			Else
				If Type("aDestNfce:_CNPJ") <> 'U'
					cTexto += "CNPJ:" + AllTrim(aDestNfce:_CNPJ:TEXT)
				ElseIf Type("aDestNfce:_CPF") <> 'U'
					cTexto += "CPF:" + AllTrim(aDestNfce:_CPF:TEXT)
				ElseIf Type("aDestNfce:_IDESTRANGEIRO") <> 'U'
					cTexto += "Id. Estrangeiro:" + AllTrim(aDestNfce:_IDESTRANGEIRO:TEXT)
				EndIf
			
				If Type("aDestNfce:_XNOME") <> 'U'
					cTexto += " Nome:" + AllTrim(aDestNfce:_XNOME:TEXT) + ' '
				EndIf

			//Verifica se possui endere็o			
				If Type("aDestNfce:_ENDERDEST") <> 'U'
					cTexto += " Endereco:" + AllTrim(aDestNfce:_ENDERDEST:_XLGR:TEXT) + ',' + AllTrim(aDestNfce:_ENDERDEST:_NRO:TEXT) + ' ' + AllTrim(aDestNfce:_ENDERDEST:_XBAIRRO:TEXT) + ' ' + aDestNfce:_ENDERDEST:_XMUN:TEXT + ' '
				EndIf

				cTexto += cCrLf
			EndIf
			cTexto += cTagCondFim+TAG_CENTER_FIM
			cTexto += cLinha

		//
		// Divisใo VIII – Informa็๕es da Consulta via QR Code
		//
			cKeyQRCode := LjNFCeQRCo(oNFCe, cAmbiente, lContigen)	//Obtem o QR-Code

			cTexto += TAG_CENTER_INI+cTagCondIni+"Consulta via leitor de QR Code"+cTagCondFim+TAG_CENTER_FIM + cCrLf
			cTexto += TAG_CENTER_INI+TAG_QRCODE_INI+cKeyQRCode+TAG_QRCODE_FIM+TAG_CENTER_FIM
			If !lContigen
				cTextoTemp := "ProtocoloAutorizacao:" + cProtAuto
				cTexto += cTagCondIni+ cTextoTemp + cTagCondFim + cCrLf
			EndIf
			cTexto += cLinha

		//Salta linha extra
			For nX := 1 to nSaltoLn
				cTexto += cCrLf
			Next nX

			If !lTSSDemoOff
				//----------------
				// Imprime o DANFE
				//----------------
				If SuperGetMV("MV_LJSTPRT",,1) == 2 .And. ExistBlock("LOJRNFCe") // Impressora Laser 

					If ExistFunc("LJSCRNFCE")			
						LJSCRNFCE(	oNFCe		, oProt		, nDecimais	, aFormas	,;
									cProtAuto	, lContigen	, cDtHoraAut, aEmitNfce	,;
									aDestNfce	, aIdNfce	, aPagNfce	, aItemNfce	,;
									aTotal		, cChvNFCe	, cInscMun  , aItensNFCe )
					ElseIf ExistBlock("LOJRNFCe")			
						U_LOJRNFCe(	oNFCe		, oProt		, nDecimais	, aFormas	,;
									cProtAuto	, lContigen	, cDtHoraAut, aEmitNfce	,;
									aDestNfce	, aIdNfce	, aPagNfce	, aItemNfce	,;
									aTotal		, cChvNFCe	, cInscMun  , aItensNFCe )
					EndIf
			
				Else //Imprime Nใo Fiscal
					LjGrvLog(SL1->L1_NUM,"Envia comando para a Impressora - Impressao da Danfinha",cTexto)
					If lPos
						lImpConting := .F.
						If lClasImpNfce
							//Se retorno for falso, nใo houve impressใo em contingencia
							lImpConting := oLojINfce:ImpMsgCon(lContigen, @cTexto, @nRet)
						EndIf
							
						If !lImpConting
							nRet := STWPrintTextNotFiscal(cTexto)
						EndIf
					Else
						LjGrvLog(SL1->L1_NUM,"Envia comando para a Impressora - Impressao da Danfinha",cTexto)
						
						lImpConting := .F.
						If lClasImpNfce
							//Se retorno for falso, nใo houve impressใo em contingencia
							lImpConting := oLojINfce:ImpMsgCon(lContigen, @cTexto, @nRet)
						EndIf
							
						If !lImpConting
							nRet := INFTexto(cTexto)	//Envia comando para a Impressora
						EndIf						
					EndIf
					LjGrvLog(SL1->L1_NUM,"Retorno da Impressao da Danfinha",nRet)
				EndIf
	
				//
				//Realiza o corte do papel, apos a impressao da DANFE
				//
				If lGuil
					cTexto := TAG_GUIL_INI+TAG_GUIL_FIM		//Corte de Papel
	
					If lPos
						nRet := STWPrintTextNotFiscal(cTexto)
					Else
						nRet := INFTexto(cTexto)	 //Envia comando para a Impressora
					EndIf
					LjGrvLog(SL1->L1_NUM,"Retorno do envio do comando de guilhotina para a impressora",nRet)
				EndIf
			Else
				cXML := StrTran(cXML, '<?xml version="1.0" encoding="UTF-8"?>', '')
				cXMLFile := cXML
			EndIf
	
		EndIf

	RECOVER
		lRet := .F.

	END SEQUENCE

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณLjNfceQrCo บAutor ณVendas Cliente      บ Data ณ  16/04/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera link para consulta da NFC-e via QrCode			      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpC1 - Link/Chave formatada						 		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Venda Assistida                                            บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function LjNfceQrCo( oNFCe, cAmbiente, lContigen )

Local cChNFe 		:= "chNFe="							//oNfce:_NFE:_INFNFE:_ID:TEXT
Local cnVersao		:= "&nVersao=" 						//Versao do QrCode
Local cTpAmb		:= "&tpAmb=" 						//oNfce:_NFE:_INFNFE:_IDE:_TPAMB:TEXT
Local cDest			:= ""								//oNfce:_NFE:_INFNFE:_DEST Documento de Identifica็ใo do Consumidor
Local cDhEmi		:= "&dhEmi="						//oNfce:_NFE:_INFNFE:_IDE:_DHEMI:TEXT
Local cvNF          := "&vNF="	   						//oNfce:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VNF:TEXT
Local cvICMS        := "&vICMS="						//oNfce:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VICMS:TEXT
Local cDigVal       := "&digVal="						//oNfce:_NFE:_SIGNATURE:_SIGNEDINFO:_REFERENCE:_DIGESTVALUE:TEXT
Local cIdToken      := "&cIdToken="						//Nใo definido qual serแ o padrใo
Local cHashQrCode   := "&cHashQRCode="					//Hash da concatenacao dos campos
Local cKeyQrCode	:= ""								//QrCode Formatado com URL
Local cToken		:= SuperGetMv( "MV_NFCETOK",, "" )	//Token fornecido ao cliente(por CNPJ) pelo Sefaz (32 posicoes), quando ambiente de homologacao o Token e formado com base no Cnpj
Local lTSSDemoOff 	:= .F.								//Parametro TSS demo (off-line)
Local cMobNFCETSS 	:= "0" 								//Tipo do TSS mobile
Local aGetMvTSS		:= {}

Default oNFCe		:= Nil
Default cAmbiente	:= ""
Default lContigen	:= .F.

PRIVATE aDestNfce	:= {}

cMobNFCETSS	:= STFGetCfg("cMobNFCETSS", "0")
lTSSDemoOff := IIF(ValType(cMobNFCETSS)="U", .F., cMobNFCETSS == "9")

//Obtemos a VERSAO da NFC-e do TSS
aGetMvTSS := LjGetMVTSS("MV_VERNFCE")
If aGetMvTSS[1]
	cMvVerNFCe := AllTrim( aGetMvTSS[2] )
EndIf

If Type("oNfce:_NFE:_INFNFE:_DEST") == "O"
	aDestNfce	:= oNfce:_NFE:_INFNFE:_DEST 		//Destinatแrio

	If Empty(aDestNfce)
		cDest := ""
	ElseIf Type("aDestNfce:_CNPJ") <> 'U'
		cDest := "&cDest=" + AllTrim(aDestNfce:_CNPJ:TEXT)
	ElseIf Type("aDestNfce:_CPF") <> 'U'
		cDest := "&cDest=" + AllTrim(aDestNfce:_CPF:TEXT)
	EndIf
EndIf

//Para o QR Code 2.0 (na Danfe 4.00) as tags sใo divididas somente por | "pipe".
If cMvVerNFCe >= "4.00"
	cChNFe 		:= ""	
	cnVersao 	:= "2" //QR Code 2.0
	cTpAmb		:= ""
	cDhEmi		:= SubStr(oNfce:_NFE:_INFNFE:_IDE:_DHEMI:TEXT, 9, 2) //QR Code 2.0 ้ enviado somente a data da transmissใo
	cvNF		:= ""
	cDigVal		:= ""
	cIdToken	:= ""
	cHashQRCode := ""
Else
	cDhEmi		+= LjAsc2Hex(oNfce:_NFE:_INFNFE:_IDE:_DHEMI:TEXT)
	cnVersao 	+= "100"
EndIf

cChNFe	+= SubStr(oNfce:_NFE:_INFNFE:_ID:TEXT,4,Len(oNfce:_NFE:_INFNFE:_ID:TEXT))
cTpAmb	+= cAmbiente
cvNF	+= oNfce:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VNF:TEXT
cvICMS	+= oNfce:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VICMS:TEXT
If !lTSSDemoOff
	cDigVal	+= LjAsc2Hex(oNfce:_NFE:_SIGNATURE:_SIGNEDINFO:_REFERENCE:_DIGESTVALUE:TEXT)
Else
	cDigVal	+= LjAsc2Hex("5ea2fab8521fdb16eadd13ee59aac501")// Demo de TSS NFCE
EndIf
cIdToken += SuperGetMv("MV_NFCEIDT" ,,"000001") //ID do token (CSC) disponibilizado pelo SEFAZ

If cMvVerNFCe >= "4.00"

	//Para o QR Code 2.0 deve desconsiderar os zeros nใo significativo parao o Id Token (CSC)
	cIdToken := cValToChar(Val(cIdToken))

	If !lContigen
		//Concatena todas as informacoes e extrai Hash(SHA1)		
		cHashQRCode += Upper(SHA1(cChNFe + "|" + cnVersao + "|" + cTpAmb + "|" + cIdToken + cToken))
		
		//QR Code 2.0 - NFC-e Online
		cKeyQRCode	:= LjNFCeURL(cAmbiente)	+ "p="	//URL da SEFAZ
		cKeyQrCode	+= cChNFe				+ "|"	//Chave de Acesso
		cKeyQrCode	+= cnVersao				+ "|"	//Versใo QR Code
		cKeyQrCode	+= cTpAmb				+ "|"	//Tipo do Ambiente
		cKeyQrCode	+= cIdToken				+ "|"	//Identificador CSC
		cKeyQrCode	+= cHashQRCode					//C๓digo HASH
	Else
		//Concatena todas as informacoes e extrai Hash(SHA1)
		cHashQRCode += Upper(SHA1(cChNFe + "|" + cnVersao + "|" + cTpAmb + "|" + cDhEmi + "|" + cvNF + "|" + cDigVal + "|" + cIdToken + cToken))

		//QR Code 2.0 - NFC-e Offline
		cKeyQRCode	:= LjNFCeURL(cAmbiente)	+ "p="	//URL da SEFAZ
		cKeyQrCode	+= cChNFe				+ "|"	//Chave de Acesso
		cKeyQrCode	+= cnVersao				+ "|"	//Versใo QR Code
		cKeyQrCode	+= cTpAmb				+ "|"	//Tipo do Ambiente
		cKeyQrCode	+= cDhEmi				+ "|"	//Data Emissใo
		cKeyQrCode	+= cvNF					+ "|"	//Valor Total
		cKeyQrCode	+= cDigVal				+ "|"	//Digest Value
		cKeyQrCode	+= cIdToken				+ "|"	//Identificador CSC
		cKeyQrCode	+= cHashQRCode					//C๓digo HASH
	EndIf
Else
	//Concatena todas as informacoes e extrai Hash(SHA1)
	cHashQRCode += Upper(SHA1(cChNFe+cnVersao+cTpAmb+cDest+cDhEmi+cvNF+cvICMS+cDigVal+cIdToken+cToken))

	//QR Code 1.0 - Online e Offline
	cKeyQRCode	:= LjNFCeURL(cAmbiente)
	cKeyQrCode	+= cChNFe
	cKeyQrCode	+= cnVersao
	cKeyQrCode	+= cTpAmb
	cKeyQrCode	+= cDest
	cKeyQrCode	+= cDhEmi
	cKeyQrCode	+= cvNF
	cKeyQrCode	+= cvICMS
	cKeyQrCode	+= cDigVal
	cKeyQrCode	+= cIdToken
	cKeyQrCode	+= cHashQRCode
EndIf

conout("QRCode: " + cKeyQRCode)

Return cKeyQrCode


//--------------------------
/*/{Protheus.doc} LjNFCeCanc
Realiza o pedido de cancelamento/inutiliza็ใo da NFC-e ao TSS.
O cancelamento/inutiliza็ใo ้ realizado de forma assํncrona
@param   cSerie	S้rie da nota fiscal
@param   cDoc	N๚mero da nota fiscal
@param   lNFCeTSS NFCe Transmitida por TSS
@author  Varejo
@version P11
@since   20/10/2014
@return  lRet	Indica se a nota foi enviada ao TSS
/*/
Function LjNFCeCanc( cSerie, cDoc, lNFCeTSS, cModelo )

	Local cXML 		:= ""
	Local cIDEnt	:= ""	//ID da entidade onde se deseja realizar o cancelamento
	Local cCNPJ		:= ""   //CNPJ da empresa
	Local cUFEnt	:= ""	//Estado de Cobran็a ou Entrega
	Local cURL		:= SuperGetMV("MV_NFCEURL",,"")
	Local nDoc		:= 0	//numero da nota no formato [N]
	Local nTamF2DOC := TamSX3("F2_DOC")[1]
	Local lRet		:= .F.	//indica se a nota foi enviada ao TSS
	Local cErro		:= ""
	Local cMvModNFCe:= ""	//Modalidade retornada do servidor TSS	
	Local aGetMvTSS := {}	//[1] executado com suceso [2] conteudo do parametro
	Local oWs 		:= Nil

	Default cSerie	:= ""
	Default cDoc	:= ""
	Default lNFCeTSS := .T.
	Default cModelo	:= "65"

	If lNFCeTSS
	
	//nota no formato [N]um้rico
		nDoc := Val( cDoc )
	
	//obtemos o ID da Entidade
		cIDEnt :=  LjTSSIDENT( cModelo )
	
	//Obtemos a e MODALIDADE do TSS
		aGetMvTSS := LjGetMVTSS("MV_MODNFCE","1")
		If aGetMvTSS[1]
			cMvModNFCe := SubStr( aGetMvTSS[2], 1, 1 )
			If cMvModNFCe == "2"
				cMvModNFCe := "9"
			EndIf
		EndIf
	
	//Se obteve as configura็๕es do TSS, prossegue com a opera็ใo
		If !Empty(cMvModNFCe)
	
		//tratamento para CNPJF e Estado de Entrega/Cobran็a
			cUFEnt	:= IIF( !lEndFis, SM0->M0_ESTCOB, SM0->M0_ESTENT )
			cCNPJ	:= SM0->M0_CGC

		//---
		// instanciamos o WSNFeSBRA
		//---
			oWs	:= WSNFeSBRA():New()
			oWs:cUserToken 		:= "TOTVS"
			oWs:cID_ENT    		:= cIDEnt
			oWS:_URL       		:= AllTrim(cURL)+"/NFeSBRA.apw"
			oWs:oWsNFe:oWsNotas	:= NFESBRA_ARRAYOFNFES():New()
	
		//alimenta o atributo oWsNFe:oWsNotas:oWSNFES com uma instancia do NFESBRA_NFES
			Aadd( oWs:oWsNFe:oWsNotas:oWSNFES, NFESBRA_NFES():New() )
	
		//alimenta o atributo cID
			Atail(oWs:oWsNFe:oWsNotas:oWSNFES):cID := cSerie + cDoc
	
			cXML := LjCodIBGE(cUFEnt) 					+ ;	// Codigo IBGE
			LjDataConv(DDATABASE,"YYMM") 		+ ;	// AAMM
			cCNPJ 								+ ; // CNPJ
			cModelo 							+ ;	// Modelo
			StrZero( Val(cSerie),3 ) 			+ ; // Serie
			StrZero( nDoc,9 ) 					+ ;	// Doc
			cMvModNFCe				 			+ ;	// Modalidade
			LjNumDecre( StrZero(Val(SubStr(StrZero(nDoc,nTamF2DOC),2,8)),8) ) //Doc na forma descrescente (8 digitos)

		//alimenta o atributo XML

			Atail(oWs:oWsNFe:oWsNotas:oWSNFES):cXML := 'Id="' + cXML + Modulo11(cXML) + '"'
	
		//execu็ใo do m้todo CancelaNotas
			lRet := oWs:CancelaNotas()
			If ValType(lRet) == "U" .OR. !lRet
				lRet := .F.
			
				If !Empty( GetWscError(3) )
					cErro := GetWscError(3)	//SOAP Fault Description
				Else
					cErro := GetWscError(1)	//Resumo do Erro
				EndIf
			Else
				If Len(oWs:OWSCANCELANOTASRESULT:OWSID:CSTRING) > 0 .And. ValType(oWs:OWSCANCELANOTASRESULT:OWSID:CSTRING[1]) == "C"
					If oWs:OWSCANCELANOTASRESULT:OWSID:CSTRING[1] <> ( cSerie + cDoc )
						lRet := .F.
						cErro := STR0024 + (cSerie + cDoc) + " <> " + oWs:OWSCANCELANOTASRESULT:OWSID:CSTRING[1]
					//"ID enviado e diferente do ID retornado: "				
					EndIf
				EndIf
			EndIf
		EndIf

	Else
	//Transmissใo Lib Perif้rico
		lRet := LjDNFCeCanc(cSerie, cDoc, lNFCeTSS)
	EndIf

//Mensagem de erro
	If !lRet
		If !IsBlind()
			Alert( cErro )
		EndIf
		LjGrvLog( cDoc, cErro )
	EndIf
	
	//Destroi o objeto para desalocar memoria
	If oWs <> Nil
		FreeObj(oWs)
		oWs := Nil
	EndIf
	
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  LjNfceImp   บAutor ณVendas Cliente      บ Data ณ  16/04/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Reimpressao da Danfe 									  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL1 - Se impressao foi realizada				 		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Venda Assistida                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LjNFCeImp( cL1Fil, cL1Num )

	Local cXml 		:= ""
	Local cXmlProt	:= ""
	Local lRet			:= .F.
	Local lPosiciona	:= .T.	//Sinaliza quando SL1 posicionado em registro diferente da Venda Atual, evitando Seek quando ja posicionado (houve situacao em ambiente de cliente onde o Seek falha quando ja posicionado)
	Local aRetAux		:= ""
	Local cChvNFCe	:= ""

	DEFAULT cL1Fil		:= ""
	DEFAULT cL1Num		:= ""
           
//Posiciona cabecalho da venda, demais tabelas(L2,L4) sao posicionadas na geracao do XML
	If ( (SL1->L1_FILIAL + SL1->L1_NUM) <> ( cL1Fil+cL1Num ) )
		lPosiciona := .F.
		DbSelectArea("SL1")
		SL1->( DbSetOrder(1) )     // L1_FILIAL + L1_NUM
	EndIf

	If lPosiciona .OR. SL1->( DbSeek(cL1Fil+cL1Num) )
		cChvNFCe := SL1->L1_KEYNFCE

	//Recupera XML da Nota
		lRet := IIF( LjNFCeGet( @cXml, @cXmlProt ),.T.,.F. )
		
		If lRet .And. ExistFunc("U_LjRDnfNfce") //Tivemos problema devido ao IXBLOG, portanto chame como U_XXX
			aRetAux := U_LjRDnfNfce( cXML, cXMLProt, cChvNFCe, .T.,aItensNFCe, Substr(cChvNFCe,21,2) == "55"  )
			If Len(aRetAux) > 0
				If ValType(aRetAux[1]) <> "L"
					aRetAux[1] = .T.
				EndIf
				lRet := aRetAux[1]
			Else
				lRet := .F.
			EndIf
		ElseIf lRet
		//Imprime a DANFE PADRAO
			If ExistFunc("LjSCNfNFCe")
				aRetAux := LjSCNfNFCe( cXML, cXMLProt, cChvNFCe, .T.,aItensNFCe, Substr(cChvNFCe,21,2) == "55"  )
				lRet := IIf (Len(aRetAux) > 0, IiF(ValType(aRetAux[1]) <> "L", .T., aRetAux[1]), .F.)
			Else
				LjNFCeDANFE( cXml, cXmlProt, Nil, .T. )
			Endif
		EndIf
	EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  LjNfceGet   บAutor ณVendas Cliente      บ Data ณ  16/04/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Recupera XML da NFCe via conexao com TSS					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL1 - Se impressao foi realizada				 		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Venda Assistida                                            บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function LjNfceGet( cXml		, cXmlProt	, cDoc		, cSerie	,;
 					lMsgAlert	, nTpXmlRet	, cModelo 	)

	Local	cID			:= ""		//ID para facilitar localiza็ใo da nota no TSS
	Local	cChaveNfce	:= ""
	Local	lRet		:= .F.
	Local 	cIdEnt		:= ""		//(Tabela:SPED001 do TSS)
	Local	cURL		:= ""
	Local	lEnvia		:= .T.
	Local 	nRegSL1 	:= 0

	PRIVATE	oWS		 	:= nil
	
	Default cDoc		:= ""
	Default cSerie		:= ""
	Default lMsgAlert 	:= .T.
	Default nTpXmlRet	:= 1 //Tipo de Protocolo de retorno que deve alimentar no parametro de referencia (cXmlProt)  (1=Protocolo NFe;  2=Protocolo NFe cancelada)
	Default cModelo		:= Substr(SL1->L1_KEYNFCE,21,2)

	If Empty(cDoc) .And. Empty(cSerie)
		nRegSL1 := SL1->(Recno())
		
		//SL1 deve estar posicionada        
		SL1->(dbGoTo(nRegSL1))
	      
		cID			:= SL1->L1_SERIE + SL1->L1_DOC
		cChaveNfce	:= AllTrim(SL1->L1_KEYNFCE)
		cModelo		:= Substr(cChaveNfce,21,2)
	Else
		cID	:= cSerie + cDoc
	EndIf

	if Empty(cModelo)
		cModelo := "65"
	endif
	
	cIDEnt := LjTSSIDENT( cModelo )

	If !Empty(cIDEnt)
	
		While lEnvia

			lEnvia	:= .F.
			cURL   	:= PadR(GetNewPar("MV_NFCEURL","http://"),250)
		
			oWS													:= WSNFESBRA():new()
			oWS:_URL											:= AllTrim(cURL)+"/NFESBRA.apw"
			oWS:cUSERTOKEN										:= "TOTVS"
			oWS:cID_ENT											:= cIdEnt
			oWS:nDIASPARAEXCLUSAO := 0
                                     
			oWS:oWSNFEID 										:= NFESBRA_NFES2():New()
			oWS:oWSNFEID:oWSNotas	 							:= NFESBRA_ARRAYOFNFESID2():New()
			aadd(oWS:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
			Atail(oWS:oWSNFEID:oWSNotas:oWSNFESID2):cID 		:= cId
		
			lRet := oWS:RETORNANOTAS()
		
			If lRet == Nil .OR. !lRet
				lRet := .F.
				If lMsgAlert
					If !IsBlind()
						lEnvia := IIF(Aviso(STR0022,IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0017,STR0018},3,STR0016)==1,.T.,.F.)			//"NFC-e: Nใo foi possํvel recuperar XML(Conexใo TSS)" ##//"SIM" //NรO ## //
					Else
						Conout(STR0022,IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))) //"NFC-e: Nใo foi possํvel recuperar XML(Conexใo TSS)"
					EndIf
				EndIf
			EndIf
		EndDo
		
	//Atualiza XML, impressใo deve ser realizada com base no XML de Retorno do TSS
		If lRet .And. Len(oWS:OWSRETORNANOTASRESULT:OWSNOTAS:OWSNFES3) > 0
			If nTpXmlRet == 1
				cXML 		:= oWS:OWSRETORNANOTASRESULT:OWSNOTAS:OWSNFES3[1]:OWSNFE:CXML
				cXMLProt	:= oWS:OWSRETORNANOTASRESULT:OWSNOTAS:OWSNFES3[1]:OWSNFE:CXMLPROT
			Else
				If oWS:OWSRETORNANOTASRESULT:OWSNOTAS:OWSNFES3[1]:OWSNFECANCELADA <> Nil
					cXML 		:= oWS:OWSRETORNANOTASRESULT:OWSNOTAS:OWSNFES3[1]:OWSNFECANCELADA:CXML
					cXMLProt	:= oWS:OWSRETORNANOTASRESULT:OWSNOTAS:OWSNFES3[1]:OWSNFECANCELADA:CXMLPROT
				EndIf
			EndIf
		Else
			lRet := .F.
			If lMsgAlert
				If !IsBlind()
					ApMsgInfo(STR0022,IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))) //"NFC-e: Nใo foi possํvel recuperar XML(Conexใo TSS)"
				Else
					Conout(STR0022,IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))) //"NFC-e: Nใo foi possํvel recuperar XML(Conexใo TSS)"
				EndIf		
			EndIf
		EndIf
	EndIf
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  LjconvType  บAutor ณVendas Cliente      บ Data ณ  16/04/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Converte Tipo Numerico/Data/String para padrao esperado no บฑฑ
ฑฑบ			   XML														  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpC1 - String com parte do XML							  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Venda Assistida                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LjconvType( xValor, nTam, nDec )

	Local cNovo		:= ""
	Local lLojxFunB	:= ExistFunc("LjDataConv")

	DEFAULT	nDec	:= 0

	do case
	case valType( xValor ) == "N"
		cNovo	:= allTrim( str( xValor, nTam, nDec ) )
	case valType( xValor ) == "D"
		If lLojxFunB
			cNovo := LjDataConv( xValor, "YYYYMMDD" )
		Else
			cNovo := FsDateConv( xValor, "YYYYMMDD" )
		EndIf
		cNovo	:= subStr( cNovo, 1, 4 ) + "-" + subStr( cNovo, 5, 2 ) + "-" + subStr( cNovo, 7 )
	case valType( xValor ) == "C"
		if nTam == nil
			xValor	:= allTrim( xValor )
		endif
		default	nTam	:= 60
		cNovo	:= allTrim( enCodeUtf8( noAcento( subStr( xValor, 1, nTam ) ) ) )
	endcase

return cNovo

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  LjNfceUrl   บAutor ณVendas Cliente      บ Data ณ  24/06/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna URL para consulta, conforme definido no Manual de  บฑฑ
ฑฑบ			   Padroes Tecnicos do DANFE-NFC-e e QR Code versao 3.1		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpC1 - String com URL para consulta da Danfe				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Venda Assistida                                            บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function LjNFCeURL(cMvAmbNFCe, lURLChave, lNFe)

Local cURL 	  		:= "URL de consulta nใo Definida"
Local cEstCob 		:= AllTrim( IIf(!lEndFis, SM0->M0_ESTCOB, SM0->M0_ESTENT) ) //Estado de cobranca do SIGAMAT.EMP porque e o estado onde o cliente Microsiga sera tributado, para validar qual endereco do Sefaz o Link deve apontar
Local cMvVerNFCe	:= ""
Local aGetMvTSS 	:= {}
Local oXml			:= NIL
Local cPath			:= "\autocom\nfce\"								// Diretorio do Arquivo xml ljnfceurls
Local cFile			:= "ljnfceurls.xml"								// Arquivo xml que cont้m todas as URLs referente a NFC-e
Local nX			:= 0								// Contador
Local aFileXML		:= {}								// Copia da Chave Producao ou Homologacao do arquvio UrlsNFCe.xml
Local nPosEst		:= 0								// Posi็ใo do Estado no array aFileXML

Default cMvAmbNFCe	:= ""
Default lURLChave	:= .F. 	//Se URL de Consulta por Digitacao da Chave
Default lNFe		:= .F.

//Obtemos a versao da NFC-e do TSS
aGetMvTSS := LjGetMVTSS("MV_VERNFCE")
If aGetMvTSS[1]
	cMvVerNFCe := AllTrim( aGetMvTSS[2] )
	
	//Atualiza parโmetro MV_VERNFCE para manter legado, apesar de considerar sempre a versใo do TSS		
	If AllTrim(cMvVerNFCe) <> AllTrim(SuperGetMv("MV_VERNFCE",, "4.00")) 
		PutMv("MV_VERNFCE" , cMvVerNFCe)
	EndIf
EndIf

if lNFe
	cURL := "www.nfe.fazenda.gov.br/portal ou no site da SEFAZ Autorizada"
	
elseif File(cPath + cFile)
	
	LjGrvLog(SL1->L1_NUM, "Utiliza a consulta de URLs NFC-e por arquivo XML.")
	
	If aUrls[1] <> cMvAmbNFCe
		
		LjUrlsXml(1, @oXML)
		
		aUrls[1] := cMvAmbNFCe
		
		If cMvAmbNFCe == "1"
			aFileXML := oXml:_UrlsNFCe:_Producao
		Else
			aFileXML := oXml:_UrlsNFCe:_Homologacao
		EndIf

		For nX := 1 to Len(aFileXML)
			aAdd(aUrls[2], {	aFileXML[nX]:_EstCob:TEXT	,;	// Estado
								aFileXML[nX]:_URL:TEXT		,;	// Url de Consulta
								aFileXML[nX]:_QrCode:TEXT	})	// Url do QrCode
		Next nX
	EndIf

	nPosEst := aScan(aUrls[2], { |x| x[1] == cEstCob} )
	If nPosEst > 0
		cUrl := IIf(lURLChave, aUrls[2][nPosEst][2], aUrls[2][nPosEst][3])
	EndIf
Else
	//URLs para Ambiente de Producao                
	If cMvAmbNFCe == "1"
		If cMvVerNFCe >= "4.00"
			If cEstCob == "AC"
				cUrl := IIF(lUrlChave,"http://www.sefaznet.ac.gov.br/nfce/consulta", "http://www.sefaznet.ac.gov.br/nfce/qrcode?") //URL definida no Documento do Projeto "www.sefaznet.ac.gov.br/nfe/NFe.jsp?opc=3"
			ElseIf cEstCob == "AL"
				cURL := IIf(lURLChave,"http://www.sefaz.al.gov.br/nfce/consulta", "http://nfce.sefaz.al.gov.br/QRCode/consultarNFCe.jsp?")
			ElseIf cEstCob == "AM"
				cUrl := IIf(lURLChave,"http://www.sefaz.am.gov.br/nfce/consulta", "http://sistemas.sefaz.am.gov.br/nfceweb/consultarNFCe.jsp?")
			ElseIf cEstCob == "AP"
				cURL := IIf(lURLChave,"http://www.sefaz.ap.gov.br/nfce/consulta", "https://www.sefaz.ap.gov.br/nfce/nfcep.php?")
			ElseIf cEstCob == "BA"
				cURL := IIf(lURLChave,"http://www.sefaz.ba.gov.br/nfce/consulta", "http://nfe.sefaz.ba.gov.br/servicos/nfce/modulos/geral/NFCEC_consulta_chave_acesso.aspx?")
			ElseIf cEstCob == "CE"
				cURL := IIf(lURLChave,"http://www.sefaz.ce.gov.br/nfce/consulta", "http://nfce.sefaz.ce.gov.br/pages/ShowNFCe.html?")
			ElseIf cEstCob == "DF"
				cURL := IIf(lURLChave,"http://www.fazenda.df.gov.br/nfce/consulta", "http://dec.fazenda.df.gov.br/ConsultarNFCe.aspx?")
			ElseIf cEstCob == "ES"
				cURL := IIf(lURLChave,"http://www.sefaz.es.gov.br/nfce/consulta", "http://app.sefaz.es.gov.br/ConsultaNFCe/qrcode.aspx?")
			ElseIf cEstCob == "GO"
				cURL := IIf(lURLChave,"http://www.sefaz.go.gov.br/nfce/consulta", "http://nfe.sefaz.go.gov.br/nfeweb/sites/nfce/danfeNFCe?")
			ElseIf cEstCob == "MA"
				cUrl := IIf(lURLChave,"http://www.sefaz.ma.gov.br/nfce/consulta", "http://www.nfce.sefaz.ma.gov.br/portal/consultarNFCe.jsp?")
			ElseIf cEstCob == "MG"
				cURL := IIf(lURLChave, "http://nfce.fazenda.mg.gov.br/portalnfce", "https://nfce.fazenda.mg.gov.br/portalnfce/sistema/qrcode.xhtml?")
			ElseIf cEstCob == "MS"
				cURL := IIf(lURLChave, "http://www.dfe.ms.gov.br/nfce/", "http://www.dfe.ms.gov.br/nfce/qrcode?")
			ElseIf cEstCob == "MT"
				cUrl := IIF(lUrlChave, "http://www.sefaz.mt.gov.br/nfce/consultanfce", "http://www.sefaz.mt.gov.br/nfce/consultanfce?")
			ElseIf cEstCob == "PA"
				cURL := IIf(lURLChave, "http://www.sefa.pa.gov.br/nfce/consulta", "https://appnfc.sefa.pa.gov.br/portal/view/consultas/nfce/nfceForm.seam?")
			ElseIf cEstCob == "PB"
				cURL := IIf(lURLChave, "http://www.receita.pb.gov.br/nfce/consulta", "http://www.receita.pb.gov.br/nfce?")
			ElseIf cEstCob == "PE"			
				cURL := IIf(lURLChave, "http://nfce.sefaz.pe.gov.br/nfce/consulta", "http://nfce.sefaz.pe.gov.br/nfce/consulta?")
			ElseIf cEstCob == "PI"
				cURL := IIf(lURLChave, "http://www.sefaz.pi.gov.br/nfce/consulta", "http://webas.sefaz.pi.gov.br/nfceweb/consultarNFCe.jsf?")
			ElseIf cEstCob == "PR"
				cURL := IIf(lURLChave, "http://www.fazenda.pr.gov.br/nfce/consulta", "http://www.fazenda.pr.gov.br/nfce/qrcode?")
			ElseIf cEstCob == "RJ"
				cURL := IIF(lUrlChave, "http://www.fazenda.rj.gov.br/nfce/consulta", "http://www4.fazenda.rj.gov.br/consultaNFCe/QRCode?")
			ElseIf cEstCob == "RN"			
				cURL := IIF(lUrlChave, "http://www.set.rn.gov.br/nfce/consulta", "http://nfce.set.rn.gov.br/consultarNFCe.aspx?")
			ElseIf cEstCob == "RO"
				cURL := IIF(lUrlChave, "http://www.sefin.ro.gov.br/nfce/consulta","http://www.nfce.sefin.ro.gov.br/consultanfce/consulta.jsp?")
			ElseIf cEstCob == "RR"
				cURL := IIf(lURLChave, "http://www.sefaz.rr.gov.br/nfce/consulta", "https://www.sefaz.rr.gov.br/nfce/servlet/qrcode?")
			ElseIf cEstCob == "RS"
				cURL := IIf(lURLChave, "http://www.sefaz.rs.gov.br/nfce/consulta", "https://www.sefaz.rs.gov.br/NFCE/NFCE-COM.aspx?")
			ElseIf cEstCob == "SE"
				cUrl := IIf(lURLChave, "http://www.sefaz.se.gov.br/nfce/consulta", "http://www.nfce.se.gov.br/portal/consultarNFCe.jsp?")
			ElseIf cEstCob == "SP"
				cURL := IIf(lURLChave, "https://www.nfce.fazenda.sp.gov.br/consulta", "https://www.nfce.fazenda.sp.gov.br/NFCeConsultaPublica/Paginas/ConsultaQRCode.aspx?")
			ElseIf cEstCob == "TO"
				cURL := IIf(lURLChave, "http://www.sefaz.to.gov.br/nfce/consulta", "http://apps.sefaz.to.gov.br/portal-nfce/qrcodeNFCe?")
			EndIf
		EndIf

	Else //URLs para Ambiente de Homologacao

		If cMvVerNFCe >= "4.00"
			If cEstCob == "AC"
				cUrl := IIF(lUrlChave, "http://www.sefaznet.ac.gov.br/nfce/consulta", "http://hml.sefaznet.ac.gov.br/nfce/qrcode?") //URL definida no Documento do Projeto "http://hml.sefaznet.ac.gov.br"
			ElseIf cEstCob == "AL"
				cURL := IIf(lURLChave, "http://www.sefaz.al.gov.br/nfce/consulta", "http://nfce.sefaz.al.gov.br/QRCode/consultarNFCe.jsp?")
			ElseIf cEstCob == "AM"
				cURL := IIf(lURLChave, "http://www.sefaz.am.gov.br/nfce/consulta", "http://homnfce.sefaz.am.gov.br/nfceweb/consultarNFCe.jsp?")
			ElseIf cEstCob == "AP"
				cURL := IIf(lURLChave, "http://www.sefaz.ap.gov.br/nfce/consulta", "https://www.sefaz.ap.gov.br/nfcehml/nfce.php?")
			ElseIf cEstCob == "BA"
				cURL := IIf(lURLChave, "http://hinternet.sefaz.ba.gov.br/nfce/consulta", "http://hnfe.sefaz.ba.gov.br/servicos/nfce/modulos/geral/NFCEC_consulta_chave_acesso.aspx?")
			ElseIf cEstCob == "CE"
				cURL := IIf(lURLChave, "http://www.sefaz.ce.gov.br/nfce/consulta", "http://nfceh.sefaz.ce.gov.br/pages/ShowNFCe.html?")
			ElseIf cEstCob == "DF"
				cURL := IIf(lURLChave, "http://www.fazenda.df.gov.br/nfce/consulta", "http://dec.fazenda.df.gov.br/ConsultarNFCe.aspx?")
			ElseIf cEstCob == "ES"
				cURL := IIf(lURLChave, "http://www.sefaz.es.gov.br/nfce/consulta", "http://homologacao.sefaz.es.gov.br/ConsultaNFCe/qrcode.aspx?")
			ElseIf cEstCob == "GO"
				cURL := IIf(lURLChave, "http://homolog.sefaz.go.gov.br/nfeweb/sites/nfce/danfeNFCe", "http://homolog.sefaz.go.gov.br/nfeweb/sites/nfce/danfeNFCe?")
			ElseIf cEstCob == "MA"
				cUrl := IIf(lURLChave, "http://www.sefaz.ma.gov.br/nfce/consulta", "http://www.hom.nfce.sefaz.ma.gov.br/portal/consultarNFCe.jsp?")
			ElseIf cEstCob == "MG"
				cURL := IIf(lURLChave, "http://hnfce.fazenda.mg.gov.br/portalnfce", "https://nfce.fazenda.mg.gov.br/portalnfce/sistema/qrcode.xhtml?")
			ElseIf cEstCob == "MS"
				cURL := IIf(lURLChave, "http://www.dfe.ms.gov.br/nfce/", "http://www.dfe.ms.gov.br/nfce/qrcode?")
			ElseIf cEstCob == "MT"
				cURL := IIf(lURLChave, "http://homologacao.sefaz.mt.gov.br/nfce/consultanfce", "http://homologacao.sefaz.mt.gov.br/nfce/consultanfce?")
			ElseIf cEstCob == "PA"
				cURL := IIf(lURLChave, "http://www.sefa.pa.gov.br/nfce/consulta", "https://appnfc.sefa.pa.gov.br/portal-homologacao/view/consultas/nfce/nfceForm.seam?")
			ElseIf cEstCob == "PB"
				cURL := IIf(lURLChave, "http://www.receita.pb.gov.br/nfcehom", "http://www.receita.pb.gov.br/nfcehom?")
			ElseIf cEstCob == "PE"
				cURL := IIf(lURLChave, "http://www.sefaz.pe.gov.br/nfce/consulta", "http://nfcehomolog.sefaz.pe.gov.br/nfce-web/consultarNFCe?")
			ElseIf cEstCob == "PI"
				cURL := IIf(lURLChave, "http://www.sefaz.pi.gov.br/nfce/consulta", "http://webas.sefaz.pi.gov.br/nfceweb-homologacao/consultarNFCe.jsf?")
			ElseIf cEstCob == "PR"
				cURL := IIf(lURLChave, "http://www.fazenda.pr.gov.br/nfce/consulta", "http://www.fazenda.pr.gov.br/nfce/qrcode?")
			ElseIf cEstCob == "RJ"
				cURL := IIF(lUrlChave, "http://www.fazenda.rj.gov.br/nfce/consulta", "http://www4.fazenda.rj.gov.br/consultaNFCe/QRCode?")
			ElseIf cEstCob == "RN"			
				cURL := IIF(lUrlChave, "http://www.set.rn.gov.br/nfce/consulta", "http://hom.nfce.set.rn.gov.br/consultarNFCe.aspx?")
			ElseIf cEstCob == "RO"
				cURL := IIF(lUrlChave, "http://www.sefin.ro.gov.br/nfce/consulta", "http://www.nfce.sefin.ro.gov.br/consultanfce/consulta.jsp?")
			ElseIf cEstCob == "RR"
				cURL :=	IIf(lURLChave, "http://www.sefaz.rr.gov.br/nfce/consulta", "http://200.174.88.103:8080/nfce/servlet/qrcode?")
			ElseIf cEstCob == "RS"
				cURL := IIf(lURLChave, "http://www.sefaz.rs.gov.br/nfce/consulta", "https://www.sefaz.rs.gov.br/NFCE/NFCE-COM.aspx?")
			ElseIf cEstCob == "SE"
				cUrl := IIf(lURLChave, "http://www.sefaz.se.gov.br/nfce/consulta", "http://www.hom.nfe.se.gov.br/portal/consultarNFCe.jsp?")
			ElseIf cEstCob == "SP"
				cURL := IIf(lURLChave, "https://www.homologacao.nfce.fazenda.sp.gov.br/consulta", "https://www.homologacao.nfce.fazenda.sp.gov.br/NFCeConsultaPublica/Paginas/ConsultaQRCode.aspx?")
			ElseIf cEstCob == "TO"
				cURL := IIf(lURLChave, "http://www.sefaz.to.gov.br/nfce/consulta", "http://apps.sefaz.to.gov.br/portal-nfce-homologacao/qrcodeNFCe?")
			EndIf
		EndIf

	EndIf
EndIf

Return cURL


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  |LjSX5FPgtoบ Autor ณVarejo				 บ Data ณ  10/04/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna um vetor com os codigos e as frmas de pagamento	  บฑฑ
ฑฑบ				utilizadas no XML da Nota Fiscal Eletronica de Consumidor บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpA1 - Vetor com codigos e Formas de Pagamento			  บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function LjSX5FPgto(cVersao,lIsNfe)
Local aFormas	:= {}	//vetor multidimensional, onde [1]=Codigo FP [2]=Sigla FP [3]=Descricao FP
Local aArea		:= GetArea()
Local nI		:= 0

Default cVersao := "4.00"
Default lIsNfe	:= .F.

Aadd(aFormas, {"01", "R$", ""})
Aadd(aFormas, {"02", "CH", ""})
Aadd(aFormas, {"03", "CC", ""})
Aadd(aFormas, {"04", "CD", ""})
Aadd(aFormas, {"05", "CR", ""})
If cVersao >= "4.00"
	Aadd(aFormas, {"15", "BOL", ""})
EndIf

If lIsNfe
	Aadd(aFormas, {"10","VA",""}) //VALE ALIMENTAวรO
	Aadd(aFormas, {"11","VR",""}) //VALE REFEIวรO 
	Aadd(aFormas, {"12","VP",""}) //VALE PRESENTE
	Aadd(aFormas, {"13","VC",""}) //VALE COMBUSTIVEL
	Aadd(aFormas, {"90","SPG","" }) //SEM PAGAMENTO
EndIf

DbSelectArea("SX5")
SX5->( DbSetOrder(1) )	//X5_FILIAL + X5_TABELA + X5_CHAVE
For nI := 1 to Len(aFormas)
	If SX5->( DbSeek(xFilial("SX5") + "24" + aFormas[nI][2]) )
		aFormas[nI][3] := AllTrim( X5Descri() )
	EndIf
Next

RestArea(aArea)

Return aFormas

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  |LjNFCeXML บ Autor	ณVarejo				 บ Data ณ  16/04/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFuncao responsavel em montar o XML que sera transmitido 	  บฑฑ
ฑฑบ			 | para o SEFAZ. Para cada bloco do XML, sera chamado uma	  บฑฑ
ฑฑบ			 | funcao distinta.											  บฑฑ
ฑฑบ			 |O XML esta de acordo com a NT2013.005 v1.03		  		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno	 ณcXML - XML layout 3.10 (NT2013.005 v1.03)   				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJNFCE		                                              บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function LjNFCeXML(cChvNFCe, lIsEnvOK, cMvModNFCe, cTagCNF)

	Local cXML			:= ""	//XML que sera transmitido ao SEFAZ
	Local cMvVerNFCe	:= ""
	Local aGetMvTSS 	:= {}

	Default cChvNFCe	:= ""
	Default lIsEnvOK	:= .T.
	Default cMvModNFCe 	:= ""
	Default cTagCNF 	:= LjGeraCNF(SL1->L1_DOC)
	
	//Obtemos a versao da NFC-e do TSS
	aGetMvTSS := LjGetMVTSS("MV_VERNFCE")
	If aGetMvTSS[1]
		cMvVerNFCe := AllTrim( aGetMvTSS[2] )
		
		//Atualiza parโmetro MV_VERNFCE para manter legado, apesar de considerar sempre a versใo do TSS		
		If AllTrim(cMvVerNFCe) <> AllTrim(SuperGetMv("MV_VERNFCE",, "4.00")) 
			PutMv("MV_VERNFCE" , cMvVerNFCe)
		EndIf
	EndIf
	
	cXML += '<?xml version="1.0" encoding="UTF-8"?>'

	//A. Dados da Nota Fiscal eletronica
	cXML += '<NFe xmlns="http://www.portalfiscal.inf.br/nfe">'
	cXML += '<infNFe versao="' + cMvVerNFCe + '" Id="NFe' + cChvNFCe + '">'

	//B. Identificacao da Nota Fiscal eletronica
	cXML += LjNFCeIde(cChvNFCe, cMvModNFCe, cTagCNF)

	//C. Identificacao do Emitente
	cXML += LjNFCeEmi()

	//E.Identificacao do Destinatario
	cXML += LjNFCeDes()

	//GA. Autoriza็ใo para obter XML - *implementacao futura
	//cXML += LjNFCeXAut()

	//H. Detalhamento de Produtos e Servi็os da NF-e
	cXML += LjNFCeDet()

	//W. Total da NF-e
	cXML += LjNFCeTot()

	//X. Informacoes do Transporte da NF-e
	cXML += LjNFCeTra()

	//YA. Formas de Pagamento
	cXML += LjNFCePag(.F.,NIL,@lIsEnvOK)

	//YB. Informa็๕es do Intermediador da Transa็ใo
	cXML += LjNFCeinfI()

	//Z. Informa็๕es Adicionais da NF-E
	cXML += LjNFCeInfA()

	cXML += '</infNFe>'

	/* O XML passado como parametro nao possui o fechamento da tag <NFe>, por isso a fechamos manualmente,
	pois sem ela, nao seria possivel realizar o parser para obter as informacoes do XML montado ate aqui */
	//ZX. Informa็๕es Suplementares da Nota Fiscal
	cXML += LjNFCeSupl(cXML + '</NFe>',cMvModNFCe)

	cXML += '</NFe>'

Return cXML


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  |LjNFCeIde บ Autor	ณVarejo				 บ Data ณ  16/04/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณAlimenta o bloco "B. Identificacao da NFe"				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno	 ณcXML - XML com o bloco B, layout 3.10 (NT2013.005 v1.03)    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJNFCE		                                              บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function LjNFCeIde( cChvNFCe, cMvModNFCe, cTagCNF )

Local cXML			:= ""
Local aGetMvTSS		:= ""
Local cMvAmbNFCe	:= ""
Local cTipoFrete	:= ""	//Tipo do Frete (Sem Frete/ CIF / FOB)
Local aAreaSF4		:= {}
Local cUFEmit		:= ""
Local cMvVerNFCe	:= ""
Local cIndPres		:= ""
Local cIntermed		:= ""

Default cMvModNFCe	:= ""
	
//Obtemos a versao da NFC-e do TSS
aGetMvTSS := LjGetMVTSS("MV_VERNFCE")
If aGetMvTSS[1]
	cMvVerNFCe := AllTrim(aGetMvTSS[2])
EndIf
	
If Empty(cMvModNFCe)
	//Obtemos a e MODALIDADE do TSS
	aGetMvTSS := LjGetMVTSS("MV_MODNFCE","1")
	If aGetMvTSS[1]
		cMvModNFCe := SubStr( aGetMvTSS[2], 1, 1 )
		If cMvModNFCe == "2"
			cMvModNFCe := "9"
		EndIf
	EndIf
EndIf

//Obtemos o AMBIENTE do TSS
aGetMvTSS := LjGetMVTSS("MV_AMBNFCE","2")
If aGetMvTSS[1]
	cMvAmbNFCe := SubStr( aGetMvTSS[2], 1, 1 )
EndIf

// Carregamos os dados de todos os itens da venda, pois sera necessario verificar se ha frete em algum item,
// pois se houver, sera considerada uma venda com Entrega em Domicilio
If ValType(aItensNFCe) == "U"
	LjHeaderIt()	//carrega os campos na primeira posicao do array
	LjColsItem(SL1->L1_FILIAL, SL1->L1_NUM)	//carrega os valores dos campos nas demais posicoes
EndIf

//obtemos o tipo do frete
cTipoFrete := LjTpFrete( SL1->L1_TPFRET )

//tratamento para CNPJF e Estado de Entrega/Cobran็a
cUFEmit	:= iIf( !lEndFis, SM0->M0_ESTCOB, SM0->M0_ESTENT )

aAreaSF4 := SF4->( GetArea() )

// Tratamento para o Indicador de Presen็a (IndPres)
// 1=Operacao Presencial ou 4-Entrega em Domicilio
If SL1->(Columnpos("L1_INDPRES")) > 0 .AND. !Empty(SL1->L1_INDPRES)
	cIndPres := SL1->L1_INDPRES
ElseIf cTipoFrete $ "C|F|T|R|D"
	cIndPres := "4"
Else
	cIndPres := "1"
EndIf

// Tratamento para o Intermediador (IndIntermed)
If NT2020006I() .AND. cIndPres $ "2,3,4,9"
	/*
		0=Opera็ใo sem intermediador (em site ou plataformapr๓pria)
		1=Opera็ใo em site ou plataforma de terceiros (intermediadores/marketplace)
	*/
	cIntermed := Lj7Intemd(cIndPres, SL1->L1_INTERMD)
EndIf

//
//	B - Identificacao da Nota Fiscal Eletronica
//
cXML += '<ide>'
cXML += 	'<cUF>' + LjCodIBGE( cUFEmit ) + '</cUF>'
cXML += 	'<cNF>' + cTagCNF + '</cNF>'
cXML += 	'<natOp>VENDA</natOp>'
			//Modelo da NFC-e: 65
cXML += 	'<mod>65</mod>'
cXML += 	'<serie>' + cValToChar( Val(SL1->L1_SERIE) ) + '</serie>'
cXML += 	'<nNF>' + cValToChar( Val(SL1->L1_DOC) ) + '</nNF>'
cXML += 	'<dhEmi>' + LjConvUTC(SL1->L1_EMISNF, SL1->L1_HORA) + '</dhEmi>'
			//Tipo de Operacao: 1=Saida
cXML += 	'<tpNF>1</tpNF>'
			//Local de destino da operacao: 1=Operacao Interna
cXML += 	'<idDest>1</idDest>'
cXML += 	'<cMunFG>' + AllTrim(SM0->M0_CODMUN) + '</cMunFG>'
			//Formato de Impressao do DANFE: 4=Impressao ou 5=Mensagem Eletronica
cXML += 	'<tpImp>4</tpImp>'
cXML += 	'<tpEmis>' + cMvModNFCe + '</tpEmis>'
cXML += 	'<cDV>' + SubStr( cChvNFCe, Len(cChvNFCe) ) + '</cDV>'
cXML += 	'<tpAmb>' + cMvAmbNFCe + '</tpAmb>'
			//Finalidade de emissao da NFC-e: 1=Normal
cXML += 	'<finNFe>1</finNFe>'
			//Indica operacao com Consumidor final: 1=Consumidor Final
cXML += 	'<indFinal>1</indFinal>'
			//Indica operacao Presencial: 1=Operacao Presencial ou 4-Entrega em Domicilio
cXML += 	'<indPres>' + cIndPres + '</indPres>'
			//Indica se existe Intermediador da Venda: 0=Opera็ใo sem intermediador (em site ou plataforma pr๓pria)
			//1=Opera็ใo em site ou plataforma de terceiros (intermediadores/marketplace)
If !Empty(cIntermed)
	cXML += '<indIntermed>' + cIntermed + '</indIntermed>'
EndIf
			//Processo de emissao da NFC-e: 0=Emissao de NF-e com aplicativo do contribuinte;
cXML += 	'<procEmi>0</procEmi>'
			//Versใo do aplicativo emissor de NFC-e.
cXML += 	'<verProc>12</verProc>'

//Preencher somente se tiver em CONTINGENCIA
If cMvModNFCe $ "5|9"
	cXML += '<dhCont>' + LjConvUTC(SL1->L1_EMISNF, SL1->L1_HORA) + '</dhCont>'
	cXML += '<xJust>ENTRADA EM CONTINGENCIA</xJust>'
EndIf
cXML += '</ide>'

//retiramos os acentos e codificamos o XML conforme as normas do UTF-8
If ExistFunc("LjRmvChEs")
	cXML := LjRmvChEs(cXML)
Else
	cXML :=  RmvChrEsp(cXML)
EndIf
cXML := EnCodeUTF8(cXML)

//Restauramos a area
RestArea( aAreaSF4)
	
Return cXML

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  |LjNFCeEmi บ Autor	ณVarejo				 บ Data ณ  16/04/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณAlimenta o bloco "C. Identifica็ใo do Emitente da NFe"	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno	 ณcXML - XML com o bloco C, layout 3.10 (NT2013.005 v1.03)    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJNFCE		                                              บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function LjNFCeEmi()

	Local cCompl	:= ""	//conteudo da tag xCpl
	Local cNro		:= ""	//conteudo da tag nro
	Local cLgr		:= ""	//conteudo da tag xLgr
	Local cFoneDest	:= ""	//conteudo da tag fone
	Local cXML		:= ""
	Local cCodReg	:= SuperGetMv( "MV_CODREG" ,, "1" )
	Local aEndCob	:= {}	//array com Logradouro[C], Numero[N], Numero[C] e Complemento[C] de Cobran็a
	Local aEndEnt	:= {}	//array com Logradouro[C], Numero[N], Numero[C] e Complemento[C] de Entrega
	Local aTelEmi	:= {}	//array com DDI[N], DDD[N] e Telefone[N]
	
	If ExistFunc("LjFiGetEnd")
		aEndEnt := LjFiGetEnd( SM0->M0_ENDENT, SM0->M0_ESTENT, .T. )
		aEndCob := LjFiGetEnd( SM0->M0_ENDCOB, SM0->M0_ESTCOB, .T. )
		aTelEmi := LjFiGetTel( SM0->M0_TEL )
	Else
		aEndEnt := FisGetEnd( SM0->M0_ENDENT, SM0->M0_ESTENT )
		aEndCob := FisGetEnd( SM0->M0_ENDCOB, SM0->M0_ESTCOB )
		aTelEmi := FisGetTel( SM0->M0_TEL )
	EndIf

	//tratamento para o Logradouro
	If lEndFis
		cLgr := aEndEnt[1]
	Else
		cLgr := aEndCob[1]
	EndIf
	cLgr := Left( AllTrim(cLgr), 60 )

	//tratamento para o Numero
	If lEndFis
		If aEndEnt[2] <> 0
			cNro := AllTrim( aEndEnt[3] )
		Else
			cNro += "SN"
		Endif
	Else
		If aEndCob[2] <> 0
			cNro := AllTrim( aEndCob[3] )
		Else
			cNro := "SN"
		EndIf
	EndIf

	//tratamento para Complemento
	If lEndFis
		If !Empty( SM0->M0_COMPENT )
			cCompl := SM0->M0_COMPENT
		Else
			cCompl := aEndEnt[4]
		EndIf
	Else
		If !Empty( SM0->M0_COMPCOB )
			cCompl := SM0->M0_COMPCOB
		Else
			cCompl := aEndCob[4]
		EndIf
	EndIf
	cCompl := AllTrim( cCompl )

	//tratamento para Telefone
	cFoneDest := IIF( aTelEmi[2] > 0, Left(cValToChar(aTelEmi[2]), 3), "") //Codigo da Area
	cFoneDest += IIF( aTelEmi[3] > 0, Left(cValToChar(aTelEmi[3]), 9), "") //Codigo do Telefone
	
	//no schema do XML, o fone deve ser maior que 6 e menor que 14
	cFoneDest := AllTrim(cFoneDest)
	If Len(cFoneDest) < 6 .OR. Len(cFoneDest) > 14
		cFoneDest := ""
	EndIf

	//
	// C. Identificacao do Emitente da Nota Fiscal Eletronica
	//
	cXML +=	'<emit>'
	cXML +=		'<CNPJ>' + AllTrim( SM0->M0_CGC ) + '</CNPJ>'
	cXML +=		'<xNome>' + AllTrim( SM0->M0_NOMECOM ) + '</xNome>'
	cXML +=		'<xFant>' + AllTrim( SM0->M0_NOME ) + '</xFant>'
	cXML +=		'<enderEmit>'
	cXML +=			'<xLgr>' + cLgr + '</xLgr>'
	cXML +=			'<nro>' + cNro+ '</nro>'

	//so informamos a tag <xCpl>, caso haja complemento
	If !Empty( cCompl )
		cXML +=		'<xCpl>' + cCompl + '</xCpl>'
	EndIf

	cXML +=			'<xBairro>' + AllTrim( Iif(!lEndFis, SM0->M0_BAIRCOB, SM0->M0_BAIRENT) ) + '</xBairro>'
	cXML +=			'<cMun>' + AllTrim( SM0->M0_CODMUN ) + '</cMun>'
	cXML +=			'<xMun>' + AllTrim( Iif(!lEndFis, SM0->M0_CIDCOB, SM0->M0_CIDENT) ) + '</xMun>'
	cXML +=			'<UF>' + AllTrim( Iif(!lEndFis, SM0->M0_ESTCOB, SM0->M0_ESTENT) ) + '</UF>'
	cXML +=			'<CEP>' + AllTrim( Iif(!lEndFis, SM0->M0_CEPCOB, SM0->M0_CEPENT) ) + '</CEP>'
	cXML +=			'<cPais>1058</cPais>'
	cXML +=			'<xPais>BRASIL</xPais>'

	If !Empty(cFoneDest)
		cXML +=		'<fone>' + cFoneDest + '</fone>' 		//DDD + Telefone
	EndIf

	cXML +=		'</enderEmit>'
	cXML +=		'<IE>' + AllTrim( SM0->M0_INSC )  + '</IE>'	//Somente algarismos
	
				//<cIEST></cIEST>
				//Rejeicao C18-10: NFC-e nao deve informar IE de Substituto Tributario

	//Inscricao Municipal
	if !Empty( AllTrim( SM0->M0_INSCM ) )
		cXML +=	'<IM>' + AllTrim( SM0->M0_INSCM ) + '</IM>'
		cXML +=	'<CNAE>' + AllTrim( SM0->M0_CNAE ) + '</CNAE>'
	endif

	cXML +=		'<CRT>' + cCodReg + '</CRT>'
	cXML +=	'</emit>'
	
	//retiramos os acentos e codificamos o XML conforme as normas do UTF-8
	If ExistFunc("LjRmvChEs")
		cXML := LjRmvChEs(cXML)
	Else
		cXML :=  RmvChrEsp(cXML)
	EndIf
	cXML := EnCodeUTF8(cXML)

Return cXML



// D. Identifica็ใo do Fisco Emitente da NF-e
// INSERIR COMENTARIO


/*/ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  |LjNFCeDes บ Autor	ณVarejo				 บ Data ณ  16/04/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณAlimenta o bloco "E. Identificacao do Destinatario da NFe"  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno	 ณcXML - XML com o bloco E, layout 3.10 (NT2013.005 v1.03)    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJNFCE		                                              บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿/*/
Static Function LjNFCeDes()

	Local cCliPad	:= SuperGetMV( "MV_CLIPAD" ,, "000001" )	//cliente padrao
	Local cLojaPad	:= SuperGetMV( "MV_LOJAPAD",, "01" )		//loja padrao
	Local aGetMvTSS	:= {}
	Local cMvAmbNFCe:= ""
	Local cXML		:= ""
	Local cCPFCNPJ	:= ""	//conteudo da tag CPNJ/CPF
	Local cNome		:= ""	//conteudo da tag xNome
	Local cCPais	:= ""	//conteudo da tag cPais
	Local cXPais	:= ""	//conteudo da tag xPais
	Local cFone		:= ""	//conteudo da tag fone
	Local aArea		:= {}
	Local aAreaSA1	:= {}
	Local aDest		:= {}	//array com as informa็๕es: [1]xLgr/[2]nro(N)/[3]nro(C)/[4]xCpl
	Local aFone		:= {}
	Local lPosCGCCli:= SL1->(ColumnPos("L1_CGCCLI")) > 0
	Local cCGCCli	:= ""
	Local cEmailForm:= ""	// Guarda o email cadastrado na SA1->A1_EMAil formatado

	aArea	:= GetArea()
	aAreaSA1:= SA1->( GetArea() )
	
	//Obtemos o AMBIENTE configurado no TSS
	aGetMvTSS := LjGetMVTSS("MV_AMBNFCE","2")
	If aGetMvTSS[1]
		cMvAmbNFCe := SubStr( aGetMvTSS[2], 1, 1 )
	EndIf
	
	//no Controle de Lojas, nesse momento o CPF/CNPJ digitado somente estแ em mem๓ria
	If NMODULO == 12 .AND. Type("M->LQ_CGCCLI") == "C"
		cCGCCli := AllTrim(M->LQ_CGCCLI)
	Else
		cCGCCli := AllTrim(SL1->L1_CGCCLI)
	EndIf
	
	If !Empty(AllTrim(cCGCCli))
	
		DbSelectArea("SA1")
		SA1->( dbSetOrder( 1 ) )

		If	SA1->(DbSeek(xFilial("SA1") + SL1->L1_CLIENTE + SL1->L1_LOJA)) ;
				.AND. ((AllTrim(SL1->L1_CLIENTE) + AllTrim(SL1->L1_LOJA)) <> (AllTrim(cCliPad) + AllTrim(cLojaPad))) ;
				.AND. !Empty(SA1->A1_CGC) .And. (AllTrim(SA1->A1_CGC) == AllTrim(cCGCCli))
	
			If lPosCGCCli .AND. (Len(cCGCCli) > 0 .AND. Len(cCGCCli) <= 14)
				cCPFCNPJ := cCGCCli
			Else
				cCPFCNPJ := AllTrim( SA1->A1_CGC )
			EndIf
	
			//Em ambiente de HOMOLOGACAO, o nome deve ser: NF-E EMITIDA EM AMBIENTE DE HOMOLOGACAO - SEM VALOR FISCAL
			If cMvAmbNFCe == "2"
				cNome := "NF-E EMITIDA EM AMBIENTE DE HOMOLOGACAO - SEM VALOR FISCAL"
			Else
				cNome := AllTrim( SA1->A1_NOME )
			EndIf
	
			//
			// X M L
			//
			cXML += "<dest>"
	
			If Len(cCPFCNPJ) < 14
				cXML += "<CPF>" + cCPFCNPJ + "</CPF>"
			Else
				cXML += "<CNPJ>" + cCPFCNPJ + "</CNPJ>"
			EndIf
	
			cXML += 	"<xNome>" + cNome + "</xNome>"
	
			//---------------------------------------------------------------------------------------------------------
			// A principio, as NFC-e serao emitidas como se o comprador estivesse presente no estabelecimento comercial
			//(indPres=1), ou seja, nao utilizaremos nenhuma tag referente a Entrega a Domicilio (indPres=4)
			//---------------------------------------------------------------------------------------------------------
			
			//Para vendas acima de R$10.000, ้ necessแrio informar o grupo <enderDest>.
			//Como sใo tags obrigat๓rias, antes de preenche-las, validamos se todos os campos estใo preenchidos
			If !Empty(SA1->A1_END) .AND. !Empty(SA1->A1_BAIRRO) .AND. !Empty(SA1->A1_EST) .AND. !Empty(SA1->A1_COD_MUN)
	
				//retorna [1]xLgr [2]nro(N) [3]nro(C) [4](xCpl), sendo que no A1_END, 
				//o n๚mero deve ser separado por virgula e o complemento por um espa็o em branco
				If ExistFunc("LjFiGetEnd")
					aDest := LjFiGetEnd( AllTrim(SA1->A1_END), Nil, .T. )
					aFone := LjFiGetTel(SA1->A1_DDI + SA1->A1_DDD + SA1->A1_TEL)
				Else
					aDest := FisGetEnd( AllTrim(SA1->A1_END) )
					aFone := FisGetTel(SA1->A1_DDI + SA1->A1_DDD + SA1->A1_TEL)
				EndIf
				
				//o valor da tag xLgr deve possuir mais de um caracter 
				If Len( aDest[1] ) < 2
					aDest[1] := "LOGRADOURO: " + aDest[1]
				Else
					aDest[1] := PadR( aDest[1], 60 )
				EndIf
			
				If Empty(aDest[3]) .OR. aDest[3] == "0"
					aDest[3] := "SN"
				EndIf
	
				//tag <cPais> e <xPais>
				If Empty( SA1->A1_PAIS )
					cCPais := "1058"
					cXPais := "BRASIL"
				Else
					cCPais := Alltrim( Posicione("SYA", 1, xFilial("SYA") + SA1->A1_PAIS, "YA_SISEXP") )
					cCPais := Iif( Empty(cCPais), "1058", cCPais)
					
					cXPais := AllTrim( Posicione("SYA", 1, xFilial( "SYA" ) + SA1->A1_PAIS, "YA_DESCR") )
					cXPais := Iif( Empty(cXPais), "BRASIL", cXPais )
				EndIf
	
				//tag <fone>
				cFone := IIF( aFone[1] > 0, Left(cValToChar(aFone[1]) ,3), "" ) // C๓digo do Pais
				cFone += IIF( aFone[2] > 0, Left(cValToChar(aFone[2]) ,3), "" ) // C๓digo da มrea
				cFone += IIF( aFone[3] > 0, Left(cValToChar(aFone[3]) ,9), "" ) // C๓digo do Telefone
	
				cXML += "<enderDest>"
				cXML += 	"<xLgr>" + AllTrim( aDest[1] ) + "</xLgr>"
				cXML += 	"<nro>" + AllTrim( aDest[3] ) + "</nro>"
				cXML += 	"<xBairro>" + AllTrim(SA1->A1_BAIRRO) + "</xBairro>"
				cXML += 	"<cMun>" + LjCodIBGE(SA1->A1_EST, SA1->A1_COD_MUN) + "</cMun>"
				cXML += 	"<xMun>" + AllTrim(SA1->A1_MUN) + "</xMun>"
				cXML += 	"<UF>" + AllTrim(SA1->A1_EST) + "</UF>"
				If !Empty(SA1->A1_CEP)
					cXML += "<CEP>" + AllTrim(SA1->A1_CEP) + "</CEP>"
				EndIf
				cXML += 	"<cPais>" + cCPais + "</cPais>"
				cXML += 	"<xPais>" + cXPais + "</xPais>"
				If !Empty(cFone)
					cXML +=	"<fone>" + Alltrim(cFone) + "</fone>"
				EndIf
				cXML += "</enderDest>"
			EndIf
	
			//No caso de NFC-e informar indIEDest=9(Nao Contribuinte) e nao informar a tag <IE> do destinatario
			cXML += 	"<indIEDest>9</indIEDest>"
	        
			//<ISUF></ISUF>
			//Rejeicao E18-10: NFC-e com Inscricao SUFRAMA
			
			//a tag <IM> eh um campo opcional, pode ser informado na NF-e conjugada
			
			If !Empty( SA1->A1_EMAIL )
				// Retorna email cadastrado na SA1->A1_EMAIL formatado
				cEmailForm := Lj7CnfMail(AllTrim( SA1->A1_EMAIL ))
				If !Empty(cEmailForm)
					cXML += "<email>" + cEmailForm + "</email>"				
					LjGrvLog(SL1->L1_NUM,"Lista de email(s) formatado(s) que sera(o) enviado(s) NO XML: ", cEmailForm)					
				EndIf	
			EndIf
	
			cXML += "</dest>"
	
		Else
				
			If lPosCGCCli .AND. !Empty(cCGCCli)
	
				cXML +=	"<dest>"
	
				If Len(cCGCCli) < 14
					cXML += "<CPF>" + cCGCCli + "</CPF>"
				Else
					cXML += "<CNPJ>" + cCGCCli + "</CNPJ>"
				Endif
	
				If cMvAmbNFCe == "2"
					cXML += "<xNome>NF-E EMITIDA EM AMBIENTE DE HOMOLOGACAO - SEM VALOR FISCAL</xNome>"
				EndIf
	
				cXML += 	"<indIEDest>9</indIEDest>"
	
				cXML += "</dest>"
	
			EndIf
	
		EndIf
	
		//retiramos os acentos e codificamos o XML conforme as normas do UTF-8
		If ExistFunc("LjRmvChEs")
			cXML := LjRmvChEs(cXML)
		Else
			cXML :=  RmvChrEsp(cXML)
		EndIf
		cXML := EnCodeUTF8(cXML)
	EndIf
	
	//restaura as areas
	RestArea(aArea)
	RestArea(aAreaSA1)

Return cXML


// F. Identificacao do Local de Retirada
// (Informar somente se diferente do endereco do remetente)


// G. Identificacao do Local de Entrega
// (Informar somente se diferente do endereco do destinatario)


/*/ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  |LjNFCeXAutบ Autor	ณVarejo				 บ Data ณ  16/04/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณAlimenta o bloco "GA. Autorizacao para obter XML".		  บฑฑ
ฑฑบ			  Pode-se informar ate 10 CPF/CNPJ, porem utilizamos somente 1บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno	 ณcXML - XML com o bloco GA, layout 3.10 (NT2013.005 v1.03)   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJNFCE		                                              บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿/*/
Static Function LjNFCeXAut()

	Local cXML 		 := ""
	Local lPosCgcCli := SL1->( ColumnPos("L1_CGCCLI") ) > 0

	// pode se informar ate 10 ocorrencias, porem utilizaremos somente uma
	If lPosCgcCli .AND. !Empty( SL1->L1_CGCCLI )
	
		//se o CPF/CNPJ ja existir no bloco E, ele ja esta autorizado a baixar o XML
		If AllTrim(SL1->L1_CGCCLI) <> AllTrim(SA1->A1_CGC)
			cXML += "<autXML>"
			
			If Len( AllTrim(SL1->L1_CGCCLI) ) < 14
				cXML += "<CPF>" + AllTrim(SL1->L1_CGCCLI) + "</CPF>"
			Else
				cXML += "<CNPJ>" + AllTrim(SL1->L1_CGCCLI) + "</CNPJ>"
			EndIf
	
			cXML += "</autXML>"
		EndIf
	EndIf

Return cXML

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  |LjNFCeDet บ Autor	ณVarejo				 บ Data ณ  16/04/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณAlimenta os blocos:										  บฑฑ
ฑฑบ			 |	- H. Detalhamento de Produtos e Servicos da NF-e          บฑฑ
ฑฑบ			 |	- I. Produtos e Servicos da NF-e						  บฑฑ
ฑฑบ			 |	- M. Tributos incidentes no Produto ou Servicos			  บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno	 ณcXML - XML com os blocos H|I|M v3.10 (NT2013.005 v1.03)  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJNFCE		                                              บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function LjNFCeDet()

Local cXML			:= ""
Local cCodBar		:= ""												// Codigo de barras
Local cCodGTIN		:= ""
Local cTpFrete		:= ""												// Tipo do Frete Sem Frete ou CIF ou FOB
Local cCRT 			:= AllTrim( SuperGetMV("MV_CODREG",,"1") )			// Codigo do Regime Tributario
Local nItem			:= 0												// Contador de item
Local aAreaSF4		:= {}
Local aAreaSB1		:={}
Local cCodProd 		:= ""
Local cDescriProd	:= ""
Local cSitTrib		:= ""
Local nQuant		:= 0
Local nVrUnit		:= 0
Local nDesconto		:= 0
Local nVlrItem		:= 0
Local nAliqICMS		:= 0												// Aliquota do ICMS
Local nAcrescimo	:= 0
Local lLj7013		:= ExistBlock("LJ7013")		    					// Indica se existe o ponto de entrada
Local aGetMvTSS		:= {}
Local cMvAmbNFCe	:= ""
Local lDescICM		:= SL2->(ColumnPos("L2_DESCICM")) > 0  .AND. SL2->(ColumnPos("L2_MOTDICM")) > 0
Local cMvCodBar		:= AllTrim( SuperGetMv("MV_CODBAR",,"N") )
Local lLJ7099		:= ExistBlock("LJ7099")								// Ponto de entrada para retorno de produto especifico (Grupo J)
Local cXMLGrupoJ	:= ""												// String no formato XML com informa็๕es de um produto especifico
Local lMvLjCEST		:= SuperGetMv("MV_LJCEST",,0) == 1					// Indica que o CEST sera enviado independente da Situacao Tributaria
Local cSitTribL2	:= "" 												// Situacao Tributaria, retirando do campo L2_CLASFIS via Substr(L2_CLASFIS,2,2) ou F4_SITTRIB
Local nPRedICM		:= 0  												// %Redu็ใo da Base do ICMS
Local cPosIpi		:= ""
Local cExNCM		:= ""
Local cOrigL2		:= ""
Local cL2ModBc		:= ""
Local nI			:= 0
Local nPosRecno		:= 0												// Posicao do campo R_E_C_N_O_ no array aItensNFCe
Local nPosTipo		:= 0												// Posicao do campo _TIPO no array aItensNFCe
Local cMvVerNFCe	:= ""
Local nValFrete		:= 0												// Valor do Frete contido no item
Local nValSeguro	:= 0												// Valor do Seguro contido no item
Local cCodISS		:= ""												// Codigo ISS
Local cStrAux		:= ""												// Variavel auxiliar
Local nX			:= 0												// Contador
/* Protecao para os campos */
Local lL2TotImp 	:= SL2->(ColumnPos("L2_TOTIMP")) > 0				// Verifica se existe o campo L2_TOTIMP (Lei da Transparencia)
Local lL2CEST		:= SL2->(ColumnPos("L2_CEST")) > 0					// Indica se o campo L2_CEST existe
Local lL2ClasFis	:= SL2->(ColumnPos("L2_CLASFIS")) > 0
Local lL2Predic		:= SL2->(ColumnPos("L2_PREDIC")) > 0
Local lImpEntTrb 	:= .F.												// Atribuido logo abaixo - utiliza a Nova Lei da Transparencia 
Local lL2CNAE		:= SL2->(ColumnPos("L2_CNAE")) > 0					// Verifica a existencia do campo L2_CNAE (usado para NFC-e com Servico [Nota Fแcil Manaus] com ISS)	
Local lL2FECP		:= SL2->(ColumnPos("L2_ALQFECP") > 0 .AND. ColumnPos("L2_VALFECP") > 0)	
Local lL2FECPST     := SL2->(ColumnPos("L2_ALQFCST") > 0 .AND. ColumnPos("L2_VFECPST") > 0)
Local cIndEscala    := "N" 												// Indicador de escala relevante
Local nCnpjFab      := 0 												// CNPJ do fabricante	
Local aRetLj7013	:= {}
/*
Array aProduto para armazenar informa็๕es de produto e nใo precisar ficar dando seek
[1] := Codigo
[2] := Descri็ใo
[3] := Valor da SB1 - B1_PRV1
[4] := B1_CODGTIN
[5] := B1_POSIPI
[6] := B1_EX_NCM
*/
Local aProdFlds		:= {"","",0,"","",""}
Local aProduto		:= {}
Local nTamB1Cod		:= TamSX3("B1_COD")[1]
Local lB1_CODGTIN	:= SB1->(ColumnPos("B1_CODGTIN")) > 0
Local lB5_2CODBAR	:= SB5->(ColumnPos("B5_2CODBAR")) > 0 				// Segundo C๓digo de Barras, para alimentar a Tag <cEANTrib>
Local cB52CodBar	:= '' 												// Codigo de barras da segunda unidade Tag <cEANTrib> 
Local nValICMS      := 0  												// Valor do ICMS
Local nBfcpant		:= 0  												// variavel para base do fecp st 
Local nAfcpant      := 0  												// variavel para aliquota do fecp st
Local nVfcpant		:= 0  												// variavel para valor do fecp st
Local lMediaST		:= SuperGetMV("MV_STMEDIA",,.F.)
Local lBI_CODGTIN	:= SBI->(ColumnPos("BI_CODGTIN")) > 0
Local lBI_POSIPI	:= SBI->(ColumnPos("BI_POSIPI")) > 0
Local lBI_EX_NCM	:= SBI->(ColumnPos("BI_EX_NCM")) > 0
Local aAreaSBI      := {} 
Local lPOS			:= STFIsPOS()										// Indica se eh TOTVS PDV
Local lLJBENSN		:= SuperGetMV("MV_LJBENSN",,.F.)					// Habilita o envio da tag cBenef para o Simples Nacional de acordo com o MV_CODREG
// ICMS Efetivo
Local nPRedBCEft	:= 0												// Percentual da Redu็ใo da Base de Cแlculo do ICMS
Local nVBCEfet		:= 0												// Valor da Base de Cแlculo do ICMS Efetivo
Local nPICMSEfet	:= 0												// Alํquota do ICMS Efetivo
Local nVICMSEfet	:= 0												// Valor do ICMS Efetivo
Local cMsgInfP      := ""
Local lUsaRastr2 	:= Empty(SuperGetMV("MV_ULTAQUI",,"")) .Or. GetApoInfo("LOJA701C.PRW")[4] < cToD("14/07/2021") // Verifica se irแ utilizar a fun็ใo SPEDRastro2. Caso configurado o parametro MV_ULTAQUI, pega as informa็๕es da MatxFis (Novo Cแlculo) ao inves de utilizar a antiga fun็ใo SPEDRastro2
Local cGrpComb		:= AllTrim( GetMV("MV_COMBUS") )					// Grupo de Produto de Combustivel/Lubrificantes
Local cMsgMonofa	:= ""												// Mensagem para a observacao do cupom sobre NT 001.2023
Local aMonof15		:= {}												// Guarda valores do CST 15
Local nVicmsMono	:= 0												// Guarda o valor do ICMS Mono do CST 53
Local lMonof53		:= .F.												// Identifica se trata esse registro do CTS53
Local lMonof61		:= .F.												// Identifica se trata esse registro do CTS61

Local nMonoBase		:= 0
Local nMonoAliq		:= 0
Local nMonoValor	:= 0

	nTamB1Cod := IIf(nModulo == 23 .And. !lPOS, TamSX3("BI_COD")[1] , TamSX3("B1_COD")[1] )
	
	//verifica se esta apto a utilizar a Nova Lei da Transparencia
	lImpEntTrb 	:=	SuperGetMv("MV_ENTETRB",.F.,.F.) .AND. SL2->(ColumnPos("L2_TOTFED")) > 0 .AND.;
	 				SL2->(ColumnPos("L2_TOTEST")) > 0 .AND. SL2->(ColumnPos("L2_TOTMUN")) > 0

	nPosRecno := aScan( aItensNFCe[1], {|x| x == "R_E_C_N_O_"} )
	nPosTipo := aScan( aItensNFCe[1], {|x| x == "_TIPO"} )

	aAreaSF4 := SF4->(GetArea())	
	
	If nModulo == 23 .And. !lPOS
		aAreaSBI := SBI->( GetArea() )
		
		SBI->(DbSetOrder(1)) //BI_FILIAL+B1_COD
		
		If !lBI_EX_NCM
			LjGrvLog( SL1->L1_NUM, "Campo BI_EX_NCM nใo esta criado na base atualize a base com o UPDDISTR")
			MsgAlert(STR0112 )	//"Campo BI_EX_NCM nใo esta criado na base atualize a base com o UPDDISTR"
		EndIf
		
		If !lBI_POSIPI
			LjGrvLog( SL1->L1_NUM, "Campo BI_POSIPI nใo esta criado na base atualize a base com o UPDDISTR")
			MsgAlert(STR0113)	//"Campo BI_POSIPI nใo esta criado na base atualize a base com o UPDDISTR"
		EndIf	
		
		If !lBI_CODGTIN
			LjGrvLog( SL1->L1_NUM, "Campo BI_CODGTIN nใo esta criado na base atualize a base com o UPDDISTR")
			MsgAlert(STR0114)	//"Campo BI_CODGTIN nใo esta criado na base atualize a base com o UPDDISTR"
		EndIf
	Else
		aAreaSB1 := SB1->( GetArea() )

		SB1->(DbSetOrder(1)) //B1_FILIAL+B1_COD
	EndIf
	
	//Obtemos o AMBIENTE configurado no TSS
	aGetMvTSS := LjGetMVTSS("MV_AMBNFCE","2")
	If aGetMvTSS[1]
		cMvAmbNFCe := SubStr( aGetMvTSS[2], 1, 1 )
	EndIf
	
	//Obtemos a versao da NFC-e do TSS
	aGetMvTSS := LjGetMVTSS("MV_VERNFCE")
	If aGetMvTSS[1]
		cMvVerNFCe := AllTrim(aGetMvTSS[2])
	EndIf

	// inicia o array estatico com os totalizadores de ICMS
	aNFCeW02 := aClone( LjNFCeWTOT("ICMSTOT") )

	// inicia o array estatico com os totalizadores de ISSQN
	aNFCeW17 := aClone( LjNFCeWTOT("ISSQNTOT") )

	For nI := 2 to Len(aItensNFCe) 

		SL2->( DbGoTo(aItensNFCe[nI][nPosRecno]) )
		
		If nModulo == 23 .And. !lPOS
			If SBI->(DbSeek(xFilial("SBI")+PadR(AllTrim(SL2->L2_PRODUTO),nTamB1Cod)))
				aProduto := {SBI->BI_COD,SBI->BI_DESC,SBI->BI_PRV,IIf(lBI_CODGTIN, SBI->BI_CODGTIN,""),IIf(lBI_POSIPI, SBI->BI_POSIPI,"") ,IIf(lBI_EX_NCM, SBI->BI_EX_NCM,"") }
				
			Else
				aProduto := aProdFlds
				LjGrvLog( SL1->L1_NUM, " Item " + SL2->L2_PRODUTO +;
				 			" nใo encontrado na tabela SBI. Verifique - [Indice 1 - Filial + Cod Produto]",;
				 			{xFilial("SBI")+PadR(AllTrim(SL2->L2_PRODUTO),nTamB1Cod)} )
			EndIf
		Else
			If SB1->(DbSeek(xFilial("SB1")+PadR(AllTrim(SL2->L2_PRODUTO),nTamB1Cod)))
				aProduto := {SB1->B1_COD,SB1->B1_DESC,SB1->B1_PRV1,IIf(lB1_CODGTIN, SB1->B1_CODGTIN,""),SB1->B1_POSIPI,SB1->B1_EX_NCM}
			Else
				aProduto := aProdFlds
				LjGrvLog( SL1->L1_NUM, " Item " + SL2->L2_PRODUTO +;
							" nใo encontrado na tabela SB1. Verifique - [Indice 1 - Filial + Cod Produto]",;
							{xFilial("SB1")+PadR(AllTrim(SL2->L2_PRODUTO),nTamB1Cod)} )
			EndIf
		EndIf
		
		//Tipo do Frete
		cTpFrete := LJTpFrete( SL1->L1_TPFRET )

		//posicionamos no TES do item da venda
		SF4->( DbSeek(xFilial("SF4") + SL2->L2_TES) )

		cCodProd 		:= SL2->L2_PRODUTO
		cDescriProd		:= SL2->L2_DESCRI
		nQuant 			:= SL2->L2_QUANT
		nDesconto		:= SL2->L2_VALDESC
		cSitTrib		:= SL2->L2_SITTRIB
		If lL2ClasFis .And. !Empty(SL2->L2_CLASFIS) .And. (Len(SL2->L2_CLASFIS) == 3) .And. !Empty(Substr(SL2->L2_CLASFIS,2,2))
			cSitTribL2	:= Substr(SL2->L2_CLASFIS,2,2)
		Else
			cSitTribL2	:= SF4->F4_SITTRIB
		EndIf 
		If lIsPafNfce .AND. !Empty(SL2->L2_VALACRS) .AND. Empty(SL2->L2_DESCPRO)
			nVrUnit			:= A410Arred(SL2->L2_PRCTAB * SL2->L2_QUANT, "L2_VLRITEM")
			nVlrItem		:= nVrUnit + SL2->L2_VALIPI - SL2->L2_VALDESC
			nAcrescimo		:= SL2->L2_DESPESA + SL2->L2_VALACRS
		Else
			nVrUnit			:= SL2->L2_VLRITEM
			nVlrItem		:= SL2->L2_VLRITEM + SL2->L2_VALIPI
			nAcrescimo		:= SL2->L2_DESPESA
		Endif 
		nValFrete		:= Iif(cTpFrete $ "C|F|T|R|D", SL2->L2_VALFRE, 0)
		nValSeguro		:= SL2->L2_SEGURO
		nPRedICM		:= LjConvType( 100 - IIF(lL2Predic .And. SL2->L2_PREDIC > 0, SL2->L2_PREDIC, SF4->F4_BASEICM), 15, 2 )//%Redu็ใo da Base do ICMS

		If lLj7013
			LjGrvLog(SL1->L1_NUM," Antes da execu็ใo do PE LJ7013")
			aRetLj7013 := ExecBlock("LJ7013",.F.,.F.,{cCodProd, cDescriProd, AllTrim(Str(nQuant)), AllTrim(Str(nVrUnit)), AllTrim(Str(nDesconto)), cSitTrib, AllTrim(Str(nVlrItem)), nI-1 })
			LjGrvLog(SL1->L1_NUM," Depois da execu็ใo do PE LJ7013", aRetLj7013)
			
			If ValType( aRetLj7013 ) == "A" .AND. Len( aRetLj7013 ) >= 7
				cCodProd 		:= aRetLj7013[1]
				cDescriProd		:= aRetLj7013[2]
				nQuant 			:= Val(aRetLj7013[3])
				nVrUnit			:= Val(aRetLj7013[4])
				nDesconto		:= Val(aRetLj7013[5])
				cSitTrib		:= aRetLj7013[6]
				nVlrItem		:= Val(aRetLj7013[7])
			EndIf
		EndIf
		
		/*
		Alํquota de ICMS:
		Aproveitamos o campo L2_SITTRIB que armazenava a legenda do ECF, por้m esse campo ้ do tipo Caracter,
		por isso realizamos a conversใo para num้rico, assim mantendo o padrใo de conversใo no momento da montagem do XML			
		*/
		nAliqICMS := LojRetFCP(cMvVerNFCe , "P")
		nValICMS  := LojRetFCP(cMvVerNFCe , "V")
		
		//contador de item
		nItem++		
		 
		If lB1_CODGTIN
			// https://www.gs1br.org/servicos-e-solucoes/cadastro-centralizado-de-gtin
			cCodGTIN := AllTrim(aProduto[4])
			LjGrvLog(SL2->L2_NUM," C๓digo GTIN do Produto ",cCodGTIN)
			
			If (cCodGTIN == "000000000000000"  .OR. cCodGTIN == "00000000000000") .And. cMvVerNFCe >= "4.00"
				cCodGTIN := "SEM GTIN"
			ElseIf !LjVldGTIN(cCodGTIN)
				cCodGTIN := ""
				LjGrvLog(SL2->L2_NUM," C๓digo GTIN do Produto Invแlido - Vide c๓digo GTIN no campo B1_CODGTIN")
			EndIf
		EndIf
		
		// verifica se o Codigo de Barras ้ valido
		cCodBar := AllTrim(SL2->L2_CODBAR)
		LjGrvLog(SL2->L2_NUM," C๓digo de Barras do Produto ",cCodBar)		
		
		If !LjVldGTIN(cCodBar)
			cCodBar := ""
			LjGrvLog(SL2->L2_NUM," C๓digo GTIN ou Barras do Produto nใo valido ou em branco",cCodBar)
		EndIf

		If lB5_2CODBAR .AND. ( !Empty(cCodGTIN) .OR. !Empty(cCodBar) )
			cB52CodBar := GetADVFVal("SB5","B5_2CODBAR",xFilial("SB5")+PadR(AllTrim(SL2->L2_PRODUTO),TamSX3("B1_COD")[1]),1,"")
			LjGrvLog(SL2->L2_NUM," C๓digo B5_2CODBAR <cEANTrib> do Produto ",cB52CodBar)
		Else
			cB52CodBar := ""	
		EndIf
		
		// Se ativo parโmetro MV_CODBAR imprime na DANFE c๓digo de barras no lugar do c๓digo do produto
		If cMvCodBar == "S" .AND. !Empty(AllTrim(SL2->L2_CODBAR))
			cCodProd := AllTrim(SL2->L2_CODBAR)
		Else
			cCodProd := AllTrim(SL2->L2_PRODUTO)
		EndIf

		//Acumuladores
		aNFCeW02[01] += SL2->L2_BASEICM
		aNFCeW02[02][1] += nValICMS

		//se houver desonera็ใo de ICMS, deve-se subtrair do valor total da venda
		cMsgInfP := ""
		If lDescICM
			aNFCeW02[02][2] += SL2->L2_DESCICM
			If SF4->F4_AGREG <> "S"
				aNFCeW02[14][1] -= SL2->L2_DESCICM
				cMsgInfP := "Valor do ICMS abatido: R$ " + Transform(SL2->L2_DESCICM,'@E 999,999.99')
			EndIf	
			If Len(aItensNFCe[nI]) >= 9
				aItensNFCe[nI][8] := SF4->F4_AGREG
			EndIf	
		EndIf
		//itens de servico nao devem ser totalizador no vProd, pois eles usam a tag vServ
		If aItensNFCe[nI][nPosTipo] <> "_ISSQN"
			aNFCeW02[05] += nVlrItem + nDesconto + SL2->L2_DESCPRO
		EndIf
		
		aNFCeW02[06] += nValFrete	
		aNFCeW02[07] += nValSeguro
		
		aNFCeW02[08][1] += nDesconto
		aNFCeW02[08][2] += SL2->L2_DESCPRO				
		aNFCeW02[13] 	+= nAcrescimo
		aNFCeW02[14][1] += (nVlrItem + nValFrete + nValSeguro + nAcrescimo)
		
				//
				// H. Detalhamento de Produtos e Servi็os da NF-e
				//
		
		cXML += "<det nItem='" + cValToChar(nItem) + "'>"	//maximo: 990 itens
				//
				//I. Produtos e Servicos da NF-e
				//
		cXML += 	"<prod>"
		cXML += 		"<cProd>" + AllTrim( cCodProd ) + "</cProd>"
		
		/*
		Tratamento para as Tags <cEAN> e <cEANTrib> na NFC-e 4.00
		Se no cadastro do produto conter apenas uma Unidade de medida (B1_UM) na nota preencher:
		B1_CODGTIN ou B1_CODBAR = Cean
		B5_2CODBAR = Ceantrib
		Se forem iguais preencher apenas B1_CODGTIN ou B1_CODBAR.
		
		Se no cadastro de produto conter duas Unidades de medida uma no produto (B1_UM) e outra no complemento de produto (B5_UMDIPI) preencher:
		B1_CODGTIN ou B1_CODBAR = Cean
		B5_2CODBAR = Ceantrib
		
		Se forem iguais serแ necessแrio preencher os dois campos B1_CODGTIN ou B1_CODBAR e B5_2CODBAR

		Caso seja SEM GTIN na duas TAGS basta preencher apenas.
		B1_CODGTIN = 000000000000000 (15 zeros)
		Serแ levado SEM GTIN para a Cean e Ceantrib
		*/

		If !Empty(cCodGTIN)
			cXML += 	'<cEAN>' + cCodGTIN + '</cEAN>'					
		ElseIf !Empty( cCodBar )			
			cXML += 	'<cEAN>' + cCodBar + '</cEAN>'
		Else			
			If cMvVerNFCe >= "4.00"
				cXML += 	'<cEAN>SEM GTIN</cEAN>'
			Else
				cXml += 	'<cEAN></cEAN>'
			EndIf
		EndIf

	
		If nItem == 1 .AND. cMvAmbNFCe == "2"
			cXML +=		"<xProd>NOTA FISCAL EMITIDA EM AMBIENTE DE HOMOLOGACAO - SEM VALOR FISCAL</xProd>"
		Else
			cXML +=		"<xProd>" + AllTrim(cDescriProd) + "</xProd>"
		EndIf

		/* Em alguns casos o NCN esta mandando em branco e rejeitando a NFC-e
		   Foi colocado essa protecao , porem o ideal ้ proteger na gravacao 
		   para nao deixar gravar em branco */
		cPosIpi := AllTrim( SL2->L2_POSIPI )
		If Empty(cPosIpi)			
			cPosIpi := AllTrim(aProduto[5])
		EndIf
		
		If Empty(cPosIpi)
			LjGrvLog( SL1->L1_NUM, "Campo L2_POSIPI e B1_POSIPI em branco, preencha caso seja necessแrio")
		EndIf

		cXML += 		"<NCM>" + cPosIpi + "</NCM>"		//informar NCM completa (8 posicoes) *implementacao futura(SEFAZ)

		If lL2CEST .AND. !Empty(SL2->L2_CEST) .AND. (cSitTribL2 == "60" .OR. lMvLjCEST)
			cXML += 	"<CEST>" + AllTrim(SL2->L2_CEST) + "</CEST>"
		Else
			LjGrvLog( SL1->L1_NUM, "Campo L2_CEST em branco, preencha caso seja necessแrio. Pode haver possํvel rejei็ใo da nota")
		EndIf
				
		If !(aItensNFCe[nI][nPosTipo] $ "_ISSQN|_RPS")
			/*
			 Legisla็ใo -> https://www.confaz.fazenda.gov.br/legislacao/convenios/2017/CV052_17, clausula 23
			 
			 NT. 2016_002_V1_60 JUNHO/2018 -> Indicador de Produ็ใo em escala relevante, 
			 conforme Clแusula 23 do Convenio ICMS 52/2017: 
			 S - Produzido em Escala Relevante;
			 N – Produzido em Escala NรO Relevante. 
			 Nota: preenchimento obrigat๓rio para produtos com 
			 NCM relacionado no Anexo XXVII do Convenio 52/2017
			*/			
			/*
			- Comentado trecho : devido a nใo obrigatoriedade e segundo a legisla็ใo ้ usado para a ind๚stria,
				caso necessแrio remover do comentแrios
			
			If cMvVerNFCe >= "4.00" .And. cCRT == "1" .And. !Empty(cPosIpi)
	            cXML +=     "<indEscala>" + cIndEscala + "</indEscala>"
	            
	            If cIndEscala == "N" //S๓ preenchido quando indEscala = N
	                cXML +=     "<CNPJFab>" + LjConvType( nCnpjFab, 14 ) + "</CNPJFab>" 
	            EndIf
	        EndIf        
	        */
	        
	        //<NVE></NVE>	//Codificacao opcional que detalha alguns NCM		

			cExNCM := AllTrim(aProduto[6])
			
			If !Empty(cExNCM)
				cXML += "<EXTIPI>" + cExNCM + "</EXTIPI>"  //Tabela de Incidencia do Imposto sobre Produtos Industrializados			
			Else
				LjGrvLog( SL1->L1_NUM, "Campo B1_EX_NCM em branco, preencha caso seja necessแrio. Pode haver possํvel rejei็ใo da nota")
			EndIf
		EndIf
		
		/*---------------------------------------------------------------------------------------------
			Por padrใo a tag cBenef ้ enviada somente para nใo optante do Simples Nacional
			Por้m caso haja altera็ใo na regra poderแ ser habilitado atrav้s do parametro MV_LJBENSN 
		----------------------------------------------------------------------------------------------*/
		If AliasInDic("F3K") //Protecao caso nao tenha a F3K
			If cCRT <> "1" .Or. (cCRT == "1" .And. lLJBENSN)
				LjCodBenef(@cXML, cCodProd, cSitTribL2)	//Preenche a tag cBenef
			EndIf
		EndIF

		cXML += 		"<CFOP>" + AllTrim( SL2->L2_CF ) + "</CFOP>"				//comeca com 1 ou 5
		cXML += 		"<uCom>" + AllTrim( SL2->L2_UM ) + "</uCom>"
		cXML += 		"<qCom>" + LjConvType( nQuant, 11, 4 ) + "</qCom>"
		If Empty(SL2->L2_VALACRS) 
			cXML += 	"<vUnCom>" + LjconvType(SL2->L2_PRCTAB + (SL2->L2_VALIPI/nQuant) , 21, 10 ) + "</vUnCom>"		//c?ulo: vUnCom = vProd / qCom
		Else 
			cXML += 	"<vUnCom>" + LjconvType((nVlrItem + SL2->L2_DESCPRO + nDesconto)/ nQuant, 21, 10 ) + "</vUnCom>"		//c?ulo: vUnCom = vProd / qCom
		Endif 
		cXML += 		"<vProd>" + LjConvType( nVlrItem + SL2->L2_DESCPRO + nDesconto, 13, 2 )+ "</vProd>"

		Do Case

			Case !Empty(cB52CodBar)
				cXML +=		'<cEANTrib>' + AllTrim(cB52CodBar) + '</cEANTrib>'
			Case !Empty(cCodGTIN)
				cXML +=		'<cEANTrib>' + cCodGTIN + '</cEANTrib>'
			Case !Empty(cCodBar)
				cXML +=		'<cEANTrib>' + cCodBar + '</cEANTrib>'
			OtherWise
				If cMvVerNFCe >= "4.00"
					cXML +=		'<cEANTrib>SEM GTIN</cEANTrib>'
				Else
					cXML +=		'<cEANTrib></cEANTrib>'
				EndIf	

		EndCase
	
		cXML += 		"<uTrib>" + AllTrim( SL2->L2_UM ) + "</uTrib>"
		cXML += 		"<qTrib>" + LjConvType( nQuant, 11, 4 ) + "</qTrib>"
		If Empty(SL2->L2_VALACRS)	
			cXML += 		"<vUnTrib>" + LjconvType(SL2->L2_PRCTAB + (SL2->L2_VALIPI/nQuant), 21, 10 ) + "</vUnTrib>"	//calculo: vUnTrib = vTrib / qTrib
		Else  
			cXML += 		"<vUnTrib>" + LjconvType( ( nVlrItem + SL2->L2_DESCPRO + nDesconto ) / nQuant, 21, 10 ) + "</vUnTrib>"	//calculo: vUnTrib = vTrib / qTrib
		EndIf 
		If nValFrete > 0
			cXML += 	"<vFrete>" + LjConvType( nValFrete, 15, 2 ) + "</vFrete>"
		EndIf

		If nValSeguro > 0
			cXML += 	"<vSeg>" + LjConvType( nValSeguro, 15, 2 ) + "</vSeg>"
		EndIf

		//a tag <vDesc> soh deve ser informada quando houver desconto na venda
		If SL2->L2_DESCPRO + nDesconto > 0
			cXML += 	'<vDesc>' + LjConvType( SL2->L2_DESCPRO + nDesconto, 15, 2 ) + '</vDesc>'
		EndIf

		// Adciona na tag <vOutro> o valor do Frete/Seguro/Despesa
		If nAcrescimo > 0
			cXML += 	'<vOutro>' + LjConvType( nAcrescimo, 15, 2 ) + '</vOutro>'
		EndIf

		// valor do item (vProd) compoe o valor total da NF-e (indTot=1)
		cXML += 		"<indTot>1</indTot>"
						
						//I07. Produtos e Servicos / Grupo Diversos
						//<nFCI></nFCI>		*implementacao futura
		
						//J. Produto Especifico
						//Somente um podera ser informado: Veiculo, Medicamentos, Armas, Combustivel:
						// JA. Detalhamento Especifico de Veiculos novos
						// K.  Detalhamento Especifico de Medicamento e de materias-primas farmaceuticas
						// L.  Detalhamento Especifico de Armamentos
						// LA. Detalhamento Especifico de Combustiveis
						// LB. Detalhamento Especifico para Operacao com Papel Imune
						
		/*
			Ponto de Entrada para retornar informa็๕es de um Produto Especifico (Grupo J)
			Deve retornar uma string no formato XML com as tags referente ao grupo informado
			Observa็ใo: somente um grupo especํfico pode ser informado por item
		*/
		If lLJ7099
			LjGrvLog( SL1->L1_NUM, "Antes da execu็ใo do P.E. LJ7099")
			cXMLGrupoJ := ExecBlock("LJ7099",.F.,.F.)
			LjGrvLog( SL1->L1_NUM, "Depois da execu็ใo do P.E. LJ7099",cXMLGrupoJ)
			If ValType( cXMLGrupoJ ) == "C"
				cXML += AllTrim(cXMLGrupoJ)
			EndIf

		/*
			A partir da implementacao das rotinas de posto de combustivel e lubrificante no Totvs PDV
			o Grupo J. Produto Especifico da LA. Detalhamento Especifico de Combustiveis 
			sera tratado pelo varejo.

			Se o produto pertencer a um do(s) grupo(s) parametrizado(s) no MV_COMBUS
			significa que pode deve ser um lubrificante ou abastecimento, mas caso tenha compilado o PE Lj7099
			serแ mantido o legado, o cliente fica responsavel por gerar as tags deste bloco como ja era feito.
		*/
		elseIf AllTrim(SB1->B1_GRUPO) $ cGrpComb

			cXML += GeraTagJLA(cSitTribL2)

		EndIf
	
		cXML +=		"</prod>"

					//
					//M. Tributos incidentes no Produto ou Servicos
					//
		cXML += 	"<imposto>"

		//Lei 12.741/12 (Lei da Transparencia)
		If lL2TotImp .And. SL2->L2_TOTIMP > 0 //So adiciona tag se valor maior que zero pois tag tambem nao sera criada no totalizador
			cXML += 	"<vTotTrib>" + LjConvType( SL2->L2_TOTIMP, 15, 2 ) + "</vTotTrib>"
			aNFCeW02[14][2][1] += SL2->L2_TOTIMP
		EndIf

		If lImpEntTrb
			aNFCeW02[14][2][2] += SL2->L2_TOTFED
			aNFCeW02[14][2][3] += SL2->L2_TOTEST
			aNFCeW02[14][2][4] += SL2->L2_TOTMUN
		EndIf

		If aItensNFCe[nI][nPosTipo] == "_ICMS"

						//
						//N. ICMS Normal e ST
						//
			cXML +=		"<ICMS>"

			cOrigL2 := SL2->L2_ORIGEM
			If Empty(cOrigL2)
				cOrigL2 := "0"
			EndIf

			cL2ModBc:= SL2->L2_MODBC
			If Empty(cL2ModBc)
				cL2ModBc := "0"
			EndIf

			If cCRT <> "1"	//1 - Simples Nacional

				Do Case
					//Legenda ECF: T - Integral
				Case cSitTribL2 == "00"	//CST = 00
					cXML += "<ICMS00>"
					cXML += 	"<orig>" + cOrigL2 + "</orig>"
					cXML += 	"<CST>" + cSitTribL2 + "</CST>"
					cXML += 	"<modBC>" + cL2ModBc + "</modBC>"
					cXML += 	"<vBC>" + LjConvType( SL2->L2_BASEICM, 15, 2 ) + "</vBC>"
					cXML += 	"<pICMS>" + LjConvType( nAliqICMS, 5, 2 ) + "</pICMS>"
					cXML += 	"<vICMS>" + LjConvType( nValICMS, 15, 2 ) + "</vICMS>"
					If lL2FECP .AND. cMvVerNFCe >= "4.00" .AND. SL2->L2_VALFECP > 0
						cXML += 	"<pFCP>" + LjConvType( SL2->L2_ALQFECP, 5, 2 ) + "</pFCP>"
						cXML += 	"<vFCP>" + LjConvType( SL2->L2_VALFECP, 15, 2 ) + "</vFCP>"//
						aNFCeW02[02][3] += SL2->L2_VALFECP
					EndIf
					cXML += "</ICMS00>"

					//Legenda ECF: T - Reducao BC
				Case cSitTribL2 == "20"	//CST = 20
					cXML += "<ICMS20>"
					cXML += 	"<orig>" + cOrigL2 + "</orig>"
					cXML += 	"<CST>" + cSitTribL2 + "</CST>"
					cXML += 	"<modBC>" + cL2ModBc + "</modBC>"
					cXML += 	"<pRedBC>" + nPRedICM + "</pRedBC>"
					cXML += 	"<vBC>" + LjConvType( SL2->L2_BASEICM, 15, 2 ) + "</vBC>"
					cXML +=		"<pICMS>" + LjConvType( nAliqICMS, 5, 2 ) + "</pICMS>"
					cXML += 	"<vICMS>" + LjConvType( nValICMS, 15, 2 ) + "</vICMS>"
					If lL2FECP .AND. cMvVerNFCe >= "4.00" .AND. SL2->L2_VALFECP > 0
						cXML += "<vBCFCP>" + LjConvType( SL2->L2_BASEICM , 15, 2 ) + "</vBCFCP>"
						cXML += "<pFCP>" + LjConvType( SL2->L2_ALQFECP, 5, 2 ) + "</pFCP>"
						cXML += "<vFCP>" + LjConvType( SL2->L2_VALFECP, 15, 2 ) + "</vFCP>"
						aNFCeW02[02][3] += SL2->L2_VALFECP
					EndIf
								//<!-- opcional -->
					If lDescICM .AND. SL2->L2_DESCICM > 0
						cXML +=	"<vICMSDeson>" + LjConvType( SL2->L2_DESCICM, 15, 2 ) + "</vICMSDeson>"
						cXML +=	"<motDesICMS>" + LjConvType( SL2->L2_MOTDICM, 2 , 0 ) + "</motDesICMS>"
					EndIf
					cXML += "</ICMS20>"
					
					//Legenda ECF: I|N - Isento e Nao Tributado
				Case cSitTribL2 $ "40|41"
					cXML += "<ICMS40>"
					cXML += 	"<orig>" + cOrigL2 + "</orig>"
					cXML += 	"<CST>" + cSitTribL2 + "</CST>"
					If lL2FECP .AND. cMvVerNFCe >= "4.00" .AND. SL2->L2_VALFECP > 0
                        cXML += "<vBCFCP>" + LjConvType( SL2->L2_BASEICM, 15, 2 ) + "</vBCFCP>"
                        cXML += "<pFCP>" + LjConvType( SL2->L2_ALQFECP, 5, 2 ) + "</pFCP>"
                        cXML += "<vFCP>" + LjConvType( SL2->L2_VALFECP, 15, 2 ) + "</vFCP>"
                        aNFCeW02[02][3] += SL2->L2_VALFECP
                    EndIf
									//<!-- opcional -->
					If lDescICM .AND. SL2->L2_DESCICM > 0
						cXML +=	"<vICMSDeson>" + LjConvType( SL2->L2_DESCICM, 15, 2 ) + "</vICMSDeson>"
						cXML +=	"<motDesICMS>" + LjConvType( SL2->L2_MOTDICM, 2 , 0 ) + "</motDesICMS>"
					EndIf
					
					//Para CST = 40 ou 41, nใo se deve totalizar os valores de <vBC> e <vICMS>
					aNFCeW02[01] -= SL2->L2_BASEICM
					aNFCeW02[02][1] -= nValICMS
					
					cXML += "</ICMS40>"

					//CST = 50 nao pode constar na NFC-e
					//Rejeicao N12-30: NFC-e com CST 50-Suspensao

					//CST = 51 nao pode constar na NFC-e
					//Rejeicao N12-40: NFC-e com CST 51-Diferimento
					
					//Legenda ECF: F - ICMS cobrado anteriormente por Substitui็ใo Tributแria
				Case cSitTribL2 == "60"	//CST = 60

					cXML += "<ICMS60>"
					cXML += 	"<orig>" + cOrigL2 + "</orig>"
					cXML += 	"<CST>" + cSitTribL2 + "</CST>"
									//Pode ser omitido quando a legislacao nao exigir a sua informacao
					cXML += 	"<vBCSTRet>" + LjconvType( SL2->L2_BRICMS, 15, 2 ) + "</vBCSTRet>"
					If cMvVerNFCe >= "4.00"
						If lL2FECPST
					    	cXML +=     "<pST>" + LjconvType( nAliqICMS + SL2->L2_ALQFECP, 15, 2 ) + "</pST>"					       
					   	Else
					       	cXML +=     "<pST>" + LjconvType( nAliqICMS, 15, 2 ) + "</pST>"
					   	EndIf
					EndIf
					cXML += 	"<vICMSSTRet>" + LjconvType( SL2->L2_ICMSRET, 15, 2 ) + "</vICMSSTRet>"

					If lL2FECPST .AND. cMvVerNFCe >= "4.00"
						If nModulo == 12 .And. SL2->L2_VFECPST == 0 // para preenchimento do Fecp ST deve busca a informa็ใo no documento de entrada.
							If lUsaRastr2
								SPEDRastro2(SL2->L2_NLOTE,SL2->L2_LOTECTL,SL2->L2_PRODUTO,,,,,lMediaST,,,,,,,,,,,,@nBfcpant,@nAfcpant,@nVfcpant,SL2->L2_LOCAL)	                       
							Else
								//Resgata os valores salvos da MatxFis
								nBfcpant := LjGetRefFis(SL2->L2_ITEM,"IT_BFCANTS")
								nAfcpant := LjGetRefFis(SL2->L2_ITEM,"IT_PFCANTS")
								nVfcpant := LjGetRefFis(SL2->L2_ITEM,"IT_VFCANTS")
							EndIf

	                        LjGrvLog(SL2->L2_NUM, "Informa็๕es de Fecp St pelo SpedRastro ")
	               		Else 
	                   		nBfcpant := SL2->L2_BRICMS
	                   		nAfcpant := SL2->L2_ALQFCST
	                   		nVfcpant := SL2->L2_VFECPST
	                   		LjGrvLog(SL2->L2_NUM, "Informa็๕es de Fecp St pela Tabela SL2 ")
	                	EndIf      
	                        
	              		If SL2->L2_VFECPST > 0 .Or. nVfcpant > 0
	                    	// Deve ser informada a alํquota do cแlculo do ICMS-ST, jแ incluso o FCP caso incida sobre a mercadoria                                              
	                        cXML +=     "<vBCFCPSTRet>" + LjconvType( nBfcpant , 15, 2 ) + "</vBCFCPSTRet>"
	                        cXML +=     "<pFCPSTRet>" + LjconvType( nAfcpant , 15, 2 ) + "</pFCPSTRet>"
	                        cXML +=     "<vFCPSTRet>" + LjconvType( nVfcpant , 15, 2 ) + "</vFCPSTRet>"
							
	                	EndIf						
	                                                                                                                                               
                        aNFCeW02[04][3] += IIf(SL2->L2_VFECPST > 0 , SL2->L2_VFECPST , nVfcpant )
                    EndIf

					//Tratamento implementado para atender o DECRETO Nบ 54.308, DE 6 DE NOVEMBRO DE 2018. (publicado no DOE n.บ 212, de 7 de novembro de 2018) ICMS Efetivo
					If AllTrim(SL1->L1_TIPOCLI) == "F"

						// s๓ grava valor na TAG pRedBCEfet (ICMS Efetivo) caso F4_BASEICM > 0
						// https://centraldeatendimento.totvs.com/hc/pt-br/articles/360035962614-MP-SIGALOJA-NFCe-Rejei%C3%A7%C3%A3o-906
						IF SF4->F4_BASEICM > 0 .Or. SL2->L2_BASEICM > 0
							nPRedBCEft	:= If(SF4->F4_BASEICM > 0 ,100 - ( ( SL2->L2_BASEICM * 100 ) / SL2->L2_VLRITEM ), 0)
							nVBCEfet	:= SL2->L2_BASEICM
							nPICMSEfet	:= Val( SL2->L2_SITTRIB )
							nVICMSEfet	:= nVBCEfet * ( nPICMSEfet / 100 )						
						Else	
							nPRedBCEft	:= 0
							nVBCEfet	:= SL2->L2_VLRITEM
							nPICMSEfet	:= Val( SL2->L2_SITTRIB )
							nVICMSEfet	:= nVBCEfet * ( nPICMSEfet / 100 )	
						EndIf
						
						cXML +=	"<pRedBCEfet>"	+ LjconvType( nPRedBCEft	, 15 , 2 ) + "</pRedBCEfet>"
						cXML +=	"<vBCEfet>" 	+ LjconvType( nVBCEfet		, 15 , 2 ) + "</vBCEfet>"
						cXML +=	"<pICMSEfet>"	+ LjconvType( nPICMSEfet	, 15 , 2 ) + "</pICMSEfet>"
						cXML +=	"<vICMSEfet>"	+ LjconvType( nVICMSEfet	, 15 , 2 ) + "</vICMSEfet>"
					EndIf

					cXML += "</ICMS60>"
						
					//Para CST = 60, nใo se deve agregar o valor retido a nota fiscal (F4_INCSOL=S),
					// pois o valor jแ foi cobrado antecipadamente. Se precisar agregar, o CST deve ser 10,30,70 ou 90

					//Tamb้m nใo se deve totalizar os valores de <vBC> e <vICMS>
					aNFCeW02[01] -= SL2->L2_BASEICM
					aNFCeW02[02][1] -= nValICMS

				Case cSitTribL2 == "90"	//CST = 90
					cXML += "<ICMS90>"
					cXML += 	"<orig>" + cOrigL2 + "</orig>"
					cXML += 	"<CST>" + cSitTribL2 + "</CST>"
									// <!-- opcional -->
					cXML += 	"<modBC>" + cL2ModBc + "</modBC>"
					cXML += 	"<vBC>" + LjConvType( SL2->L2_BASEICM, 15, 2 ) + "</vBC>"
					If lL2PREDIC
						cXML +=	"<pRedBC>" + LjConvType( SL2->L2_PREDIC, 15, 2 ) + "</pRedBC>"
					EndIf									
					cXML += 	"<pICMS>" + LjConvType( nAliqICMS, 5, 2 ) + "</pICMS>"
					cXML += 	"<vICMS>" + LjConvType( nValICMS, 15, 2 ) + "</vICMS>"
					If lL2FECP .AND. cMvVerNFCe >= "4.00" .AND. SL2->L2_VALFECP > 0
						cXML += "<vBCFCP>" + LjConvType( SL2->L2_BASEICM, 15, 2 ) + "</vBCFCP>"
						cXML += "<pFCP>" + LjConvType( SL2->L2_ALQFECP, 5, 2 ) + "</pFCP>"
						cXML += "<vFCP>" + LjConvType( SL2->L2_VALFECP, 15, 2 ) + "</vFCP>"
						aNFCeW02[02][3] += SL2->L2_VALFECP
					EndIf

					//Rejeicao: N12-34 - Grupo de tributa็ใo ICMS90, informando dados do ICMS-ST [nItem:nnn]

					// <!-- opcional -->
					If lDescICM .AND. SL2->L2_DESCICM > 0
						cXML +=	"<vICMSDeson>" + LjConvType( SL2->L2_DESCICM, 15, 2 ) + "</vICMSDeson>"
						cXML +=	"<motDesICMS>" + LjConvType( SL2->L2_MOTDICM, 2 , 0 ) + "</motDesICMS>"
					EndIf
					cXML += "</ICMS90>"

						/* Rejeicao N12-60: NFC-e com repasse de ICMS-ST retido anteriormente em opera็ใo interestadual 
						com repasse pelo Substituto Tributแrio (tag:ICMS/ICMSST) */	


				//Legenda ECF: F - NT 2023.001 Tributacao monofasica sobre combustiveis cobrada anteriormente
				Case cSitTribL2 $ M->cCstNT00123
					cXML += '<ICMS' + cSitTribL2 + '>'
						
						LjGetRefFis(SL2->L2_ITEM,"NF_ICMSDIF")
						
						cXML += '<orig>' + cOrigL2 + '</orig>'
						cXML += '<CST>' + cSitTribL2 + '</CST>'

						If(cSitTribL2 $ '02-15')
							
							//aImpMono := aClone(aIcms)
							cXML += '<qBCMono>'   + LjConvType( SL2->L2_BASEICM ,16,4) + '</qBCMono>'
							cXML += '<adRemICMS>' + LjConvType( nAliqICMS ,08,4) + '</adRemICMS>'
							cXML += '<vICMSMono>' + LjConvType( nValICMS ,16,2) + '</adRemICMS>'
							
							If cSitTribL2 $ '02'
								aMonof02[1] += SL2->L2_BASEICM
								aMonof02[2] += nAliqICMS
								aMonof02[3] += nValICMS

								aNFCeW02[15][1] += SL2->L2_BASEICM	//qBCMono
								aNFCeW02[15][2] += nValICMS			//vICMSMono

							Else
								aMonof15[1] += SL2->L2_BASEICM
								aMonof15[2] += nAliqICMS
								aMonof15[3] += nValICMS

							EndIf

							cMsgInfP := "[Item: " + SL2->L2_ITEM + " BC "+cValToChar(SL2->L2_BASEICM)+" (em litros); Alํquota: R$ "+;
											Alltrim(str(nAliqICMS,15,2))+"; ICMS mono: R$ "+;
											Alltrim(str(nValICMS,15,2))+"]"
						
						EndIf

						If(cSitTribL2 $ '15')
							
							//aImpMono := aClone(aICMSST)
							cXML += '<qBCMonoReten>'   + LjConvType( SL2->L2_BASEICM ,16,4) + '</qBCMonoReten>'
							cXML += '<adRemICMSReten>' + LjConvType( nAliqICMS ,08,4) + '</adRemICMSReten>'
							cXML += '<vICMSMonoReten>' + LjConvType( nValICMS ,16,2) + '</vICMSMonoReten>'

							aMonof15[4] += SL2->L2_BASEICM
							aMonof15[5] += nAliqICMS
							aMonof15[6] += nValICMS

							aNFCeW02[15][3] += SL2->L2_BASEICM	//qBCMonoReten
							aNFCeW02[15][4] += nValICMS			//vICMSMonoReten

							cMsgInfP += "[Item: " + SL2->L2_ITEM + "ICMS monofแsico sujeito a reten็ใo: BC "+cValToChar(aICMSST[05])+" (em litros); Alํquota: R$ "+Alltrim(str(aICMSST[06],15,2))+"; ICMS mono: R$ "+Alltrim(str(aICMS[07],15,2))+"]"
							If LjGetRefFis(SL2->L2_ITEM,"IT_BFCANTS") > 0
								cXML += '<pRedAdRem>'+ LjConvType(LjGetRefFis(SL2->L2_ITEM,"IT_BFCANTS"),5,2) +'</pRedAdRem>' // CD2_PREDBC
								cXML += '<motRedAdRem>'+ LjConvType(LjGetRefFis(SL2->L2_ITEM,"IT_PFCANTS")) +'</motRedAdRem>' // FT_MOTICMS
							EndIf
						
						EndIf

						If(cSitTribL2 $ '53')
							
							nVicmsMono := nValICMS
							If !Empty(MaFisRet(Nil, "NF_ICMSDIF"))
								nVicmsMono := nValICMS
							ElseIf Empty(MaFisRet(Nil, "NF_ICMSDIF")) .And. !Empty(nValICMS)
								nVicmsMono := nValICMS - MaFisRet(Nil, "NF_ICMSDIF")
							EndIf

							cXML += '<qBCMono>'		 + LjConvType(SL2->L2_BASEICM,16,4) + '</qBCMono>'
							cXML += '<adRemICMS>' 	 + LjConvType(nAliqICMS,8,4)	 + '</adRemICMS>'
							cXML += '<vICMSMonoOp>'  + LjConvType(nValICMS,16,2) + '</vICMSMonoOp>'
							cXML += '<pDif>'	 	 + LjConvType(CD2->CD2_PICMDF,8,4)	 + '</pDif>'	//Verificar chamada fiscal varejo
							cXML += '<vICMSMonoDif>' + LjConvType( LjGetRefFis(SL2->L2_ITEM,"NF_ICMSDIF"),16,2) + '</vICMSMonoDif>'
							cXML += '<vICMSMono>'	 + LjConvType(nVicmsMono,16,2)	 + '</vICMSMono>'

							aNFCeW02[15][1] += SL2->L2_BASEICM	//qBCMono

							cMsgInfP += "[Item: " + SL2->L2_ITEM + "ICMS monofแsico sobre combustํveis diferido conforme Conv๊nio ICMS 199/2022]"
							lMonof53 := .T.

						EndIf

						If(cSitTribL2 $ '61')

							nMonoBase := LjGetRefFis(SL2->L2_ITEM,"TG_IT_BASE","000059")
							nMonoAliq := LjGetRefFis(SL2->L2_ITEM,"TG_IT_ALIQUOTA","000059")
							nMonoValor:= LjGetRefFis(SL2->L2_ITEM,"TG_IT_VALOR","000059")

							cXML += '<qBCMonoRet>'	+ LjConvType( nMonoBase,16,4) + '</qBCMonoRet>'
							cXML += '<adRemICMSRet>' + LjConvType( nMonoAliq,08,4) + '</adRemICMSRet>'
							cXML += '<vICMSMonoRet>' + LjConvType( nMonoValor,16,2) + '</vICMSMonoRet>'

							aNFCeW02[15][5] := aNFCeW02[15][5] + nMonoBase	//vICMSMono
							aNFCeW02[15][6] := aNFCeW02[15][6] + nMonoValor	//vICMSMonoReten

							cMsgInfP += "[Item: " + SL2->L2_ITEM + "ICMS monofแsico sobre combustํveis cobrado anteriormente conforme Conv๊nio ICMS 199/2022]"
							lMonof61 := .T.

						EndIf

					cXML += '</ICMS' + cSitTribL2 + '>'

				End Case
				
			Else

				Do Case
				//Rejei็ใo N12a-20: Item com CSOSN indevido				
				Case SF4->F4_CSOSN $ "102|103|300|400"	//CST = 102, 103, 300 ou 400
					cXML += "<ICMSSN102>"
					cXML += 	"<orig>" + cOrigL2 + "</orig>"
					cXML += 	"<CSOSN>" + SF4->F4_CSOSN + "</CSOSN>"
					cXML += "</ICMSSN102>"
					
				Case SF4->F4_CSOSN == "500"	//CST = 500
					cXML += "<ICMSSN500>"
					cXML += 	"<orig>" + cOrigL2 + "</orig>"
					cXML += 	"<CSOSN>" + SF4->F4_CSOSN + "</CSOSN>"
								//O valor pode ser omitido quando a legislacao nao exigir a sua informacao
					cXML += 	"<vBCSTRet>" + LjConvType( SL2->L2_BRICMS, 15, 2 ) + "</vBCSTRet>"
					If cMvVerNFCe >= "4.00"
						If lL2FECPST
                        	cXML +=     "<pST>" + LjconvType( nAliqICMS + SL2->L2_ALQFECP, 15, 2 ) + "</pST>"                           
                       	Else
                           	cXML +=     "<pST>" + LjconvType( nAliqICMS, 15, 2 ) + "</pST>"
                       	EndIf
					EndIf
					cXML += 	"<vICMSSTRet>" + LjConvType( SL2->L2_ICMSRET, 15, 2 ) + "</vICMSSTRet>"					

					If lL2FECPST .AND. cMvVerNFCe >= "4.00" .AND. SL2->L2_VFECPST > 0
                        // Deve ser informada a alํquota do cแlculo do ICMS-ST, jแ incluso o FCP caso incida sobre a mercadoria                                                                                                                                                                                             
                        cXML +=     "<vBCFCPSTRet>" + LjconvType( SL2->L2_BRICMS , 15, 2 ) + "</vBCFCPSTRet>"
                        cXML +=     "<pFCPSTRet>"	+ LjconvType( SL2->L2_ALQFCST, 15, 2 ) + "</pFCPSTRet>"
                        cXML +=     "<vFCPSTRet>"	+ LjconvType( SL2->L2_VFECPST, 15, 2 ) + "</vFCPSTRet>"                         
                        aNFCeW02[04][3] += SL2->L2_VFECPST					

                    EndIf

					//Tratamento implementado para atender o DECRETO Nบ 54.308, DE 6 DE NOVEMBRO DE 2018. (publicado no DOE n.บ 212, de 7 de novembro de 2018) ICMS Efetivo
					If AllTrim(SL1->L1_TIPOCLI) == "F" .And. SF4->F4_BASEICM > 0
						nPRedBCEft	:= 100 - ( ( SL2->L2_BASEICM * 100 ) / SL2->L2_VLRITEM )					
						nVBCEfet	:= SL2->L2_BASEICM
						nPICMSEfet	:= Val( SL2->L2_SITTRIB )
						nVICMSEfet	:= nVBCEfet * ( npICMSEfet / 100 )
						
						cXML +=	"<pRedBCEfet>"	+ LjconvType( nPRedBCEft	, 15 , 2 ) + "</pRedBCEfet>"
						cXML +=	"<vBCEfet>" 	+ LjconvType( nVBCEfet		, 15 , 2 ) + "</vBCEfet>"
						cXML +=	"<pICMSEfet>"	+ LjconvType( nPICMSEfet	, 15 , 2 ) + "</pICMSEfet>"
						cXML +=	"<vICMSEfet>"	+ LjconvType( nVICMSEfet	, 15 , 2 ) + "</vICMSEfet>"
					EndIf

					cXML += "</ICMSSN500>"

					//Para CSOSN = 500, nใo se deve agregar o valor retido a nota fiscal (F4_INCSOL=S),
					// pois o valor jแ foi cobrado antecipadamente. Se precisar agregar, o CST deve ser 10,30,70 ou 90

					//Tamb้m nใo se deve totalizar os valores de <vBC> e <vICMS>
					aNFCeW02[01] -= SL2->L2_BASEICM
					aNFCeW02[02][1] -= nValICMS

				Case SF4->F4_CSOSN == "900"	//CST = 900
					cXML += "<ICMSSN900>"
					cXML += 	"<orig>" + cOrigL2 + "</orig>"
					cXML += 	"<CSOSN>" + SF4->F4_CSOSN + "</CSOSN>"
								//<!-- opcional -->
					cXML += 	"<modBC>" + cL2ModBc + "</modBC>"
					cXML += 	"<vBC>" + LjConvType( SL2->L2_BASEICM, 15, 2 ) + "</vBC>"
					cXML += 	"<pRedBC>" + nPRedICM + "</pRedBC>"
					cXML += 	"<pICMS>" + LjConvType( nAliqICMS, 5, 2 ) + "</pICMS>"
					cXML += 	"<vICMS>" + LjConvType( nValICMS, 15, 2 ) + "</vICMS>"
								//<!-- opcional -->

					//Rejei็ใo N12-34: Grupo de tributa็ใo ICMS900, informando dados do ICMS-ST

					//			 <!-- opcional -->
					//cXML := 	"<pCredSN><pCredSN>"
					//cXML := 	"<vCredICMSSN><vCredICMSSN>"
					cXML += "</ICMSSN900>"
				EndCase

			EndIf

			//***************************************************************************************************************************
			// Ponto de entrada para adicionar informa็๕es especํficas no XML que nใo seja atendida pelo padrใo.
			// Deve retornar uma string no formato XML com as tags referente ao grupo em questใo.
			// Observa็ใo: Somente pode ser adicionado as tags relacionadas aquele grupo em especํfico onde estแ sendo chamado este PE.
			//***************************************************************************************************************************
			If lLJCUPXML
				aParaPEXML := {"65", "ICMS"}
				LjGrvLog( SL1->L1_NUM, "Antes da execu็ใo do P.E. LJCUPXML", aParaPEXML)
				cAddXML := ExecBlock("LJCUPXML",.F.,.F., aParaPEXML )
				LjGrvLog( SL1->L1_NUM, "Retorno do P.E. LJCUPXML", cAddXML)
				If ValType( cAddXML ) == "C"
					cXML += AllTrim(cAddXML)
				EndIf
			EndIf

			cXML +=			"</ICMS>"

						// O. IPI
						// Rejeicao 01-10: NFC-e com grupo do IPI

						// P. II
						// Rejeicao P10-10: NFC-e com grupo do II

						// Q. PIS

						// R. PIS ST
						// Rejeicao R01-10: NFC-e com grupo do PIS-ST

						// S. COFINS

						// T. COFINS ST
						// Rejeicao T01-10: NFC-e com grupo da COFINS-ST

		Else
			// Tratamento para o  Codigo do ISS, pois ha situacoes que a informacao ja vem formatada (NN.NN)
			cCodISS := ""
			cStrAux := AllTrim( SL2->L2_CODISS )
			For nX := 1 to Len( cStrAux )
				If IsDigit( SubStr(cStrAux, nX, 1) )
					cCodISS += SubStr(cStrAux, nX, 1)
				EndIf
			Next
			cCodISS := SubStr(cCodISS, 1, 2) + "." + SubStr(cCodISS, 3, 2)
						// U. ISSQN
			cXML +=		"<ISSQN>"
			cXML +=			"<vBC>" + LjConvType(Iif(lIsPafNfce .AND. Empty(SL2->L2_BASEISS), SL2->L2_VLRITEM, SL2->L2_BASEISS), 15, 2) + "</vBC>"
			cXML +=			"<vAliq>" + LjConvType(SL2->L2_ALIQISS, 5, 2)+ "</vAliq>"
			cXML +=			"<vISSQN>" + LjConvType(SL2->L2_VALISS, 15, 2) + "</vISSQN>"
			cXML +=			"<cMunFG>" + AllTrim(SM0->M0_CODMUN) + "</cMunFG>"
			cXML +=			"<cListServ>" + cCodISS + "</cListServ>"
			cXML +=			"<indISS>" + SF4->F4_ISSST + "</indISS>"
			If lL2CNAE .AND. !Empty(SL2->L2_CNAE)
				cXML +=		"<cServico>" + AllTrim(Transform(SL2->L2_CNAE, "@R XXXX-X/XX")) + "</cServico>"
			EndIf
			cXML +=			"<indIncentivo>" + AllTrim( SuperGetMV("MV_INCEFIS",,"1") )+ "</indIncentivo>"
			cXML +=		"</ISSQN>"

			/* totalizadores para ISSQN */
			aNFCeW17[01] += nVlrItem + nDesconto + SL2->L2_DESCPRO
			aNFCeW17[02] += Iif(lIsPafNfce .AND. Empty(SL2->L2_BASEISS), SL2->L2_VLRITEM, SL2->L2_BASEISS)
			aNFCeW17[03] += SL2->L2_VALISS

		EndIf

		cXML +=		"</imposto>"
	
					// UA. Tributos Devolvidos (para o item da NFC-e)
	
					// V - Informacoes adicionais (para o item da NFC-e)
					If !Empty(cMsgInfP)
							cXML += "<infAdProd>" +cMsgInfP +"</infAdProd>"
					EndIf	
		cXML +=	"</det>"
	Next
	
	//retiramos os acentos e codificamos o XML conforme as normas do UTF-8
	If ExistFunc("LjRmvChEs")
		cXML := LjRmvChEs(cXML)
	Else
		cXML :=  RmvChrEsp(cXML)
	EndIf
	cXML := EnCodeUTF8(cXML)

	RestArea(aAreaSF4)
	If nModulo == 23 .And. !lPOS 
		RestArea(aAreaSBI)	
	Else
		RestArea(aAreaSB1)
	EndIf

Return cXML

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  |LjNFCeTot บ Autor	ณVarejo				 บ Data ณ  16/04/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณAlimenta o bloco "W. Total da NFC-e"	do XML que sera		  บฑฑ 
ฑฑบ			 | transmitido ao SEFAZ. *Totais referentes a ISSQN serao 	  บฑฑ 
ฑฑบ			 | implementados futuramente.	  							  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno	 ณcXML - XML com o bloco W do layout 3.10 (NT2013.005 v1.03)  บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJNFCE		                                              บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function LjNFCeTot()

	Local cXML			:= ""
	Local cMvVerNFCe	:= ""
	Local aGetMvTSS		:= {}
	
	//Obtemos a versao da NFC-e do TSS
	aGetMvTSS := LjGetMVTSS("MV_VERNFCE")
	If aGetMvTSS[1]
		cMvVerNFCe := AllTrim( aGetMvTSS[2] )
	EndIf

	cXML +=	"<total>"
	cXML += 	"<ICMSTot>"
	cXML += 		"<vBC>" + LjConvType(aNFCeW02[01], 15, 2 ) + "</vBC>"
	cXML += 		"<vICMS>" + LjConvType(aNFCeW02[02][1], 15, 2) + "</vICMS>"
	cXML += 		"<vICMSDeson>" + LjConvType(aNFCeW02[02][2], 15, 2) + "</vICMSDeson>"
	If cMvVerNFCe >= "4.00"		
		cXML +=		"<vFCP>" + LjConvType(aNFCeW02[02][3], 15, 2) + "</vFCP>"				
	EndIf
	cXML += 		"<vBCST>" + LjConvType(aNFCeW02[03], 15, 2) + "</vBCST>"
	cXML += 		"<vST>" + LjConvType(aNFCeW02[04][1], 15, 2) + "</vST>"
	If cMvVerNFCe >= "4.00"
		//Somente para Substituicao Tributaria
		cXML +=		"<vFCPST>0</vFCPST>"		
		cXML +=     "<vFCPSTRet>" + LjConvType(aNFCeW02[04][3], 15, 2) + "</vFCPSTRet>"  	
	EndIf

	cXML +=			"<qBCMono>" + LjConvType(aNFCeW02[15][1], 13, 2) + "</qBCMono>"
	cXML +=			"<vICMSMono>" + LjConvType(aNFCeW02[15][2], 13, 2) + "</vICMSMono>"
	cXML +=			"<qBCMonoReten>" + LjConvType(aNFCeW02[15][3], 13, 2) + "</qBCMonoReten>"
	cXML +=			"<vICMSMonoReten>" + LjConvType(aNFCeW02[15][4], 13, 2) + "</vICMSMonoReten>"
	cXML +=			"<qBCMonoRet>" + LjConvType(aNFCeW02[15][5], 13, 2) + "</qBCMonoRet>"
	cXML +=			"<vICMSMonoRet>" + LjConvType(aNFCeW02[15][6], 13, 2) + "</vICMSMonoRet>"

	//***************************************************************************************************************************
	// Ponto de entrada para adicionar informa็๕es especํficas no XML que nใo seja atendida pelo padrใo.
	// Deve retornar uma string no formato XML com as tags referente ao grupo em questใo.
	// Observa็ใo: Somente pode ser adicionado as tags relacionadas aquele grupo em especํfico onde estแ sendo chamado este PE.
	//***************************************************************************************************************************
	If lLJCUPXML
		aParaPEXML := {"65", "ICMSTOT"}
		LjGrvLog( SL1->L1_NUM, "Antes da execu็ใo do P.E. LJCUPXML", aParaPEXML)
		cAddXML := ExecBlock("LJCUPXML",.F.,.F., aParaPEXML )
		LjGrvLog( SL1->L1_NUM, "Retorno do P.E. LJCUPXML", cAddXML)
		If ValType( cAddXML ) == "C"
			cXML += AllTrim(cAddXML)
		EndIf
	EndIf

	cXML += 		"<vProd>" + LjConvType(aNFCeW02[05], 15, 2) + "</vProd>"
	cXML += 		"<vFrete>" + LjConvType(aNFCeW02[06], 15, 2) + "</vFrete>"
	cXML += 		"<vSeg>" + LjConvType(aNFCeW02[07], 15, 2) + "</vSeg>"
	cXML += 		"<vDesc>" + LjConvType( (aNFCeW02[08][1] + aNFCeW02[08][2]), 15, 2 ) + "</vDesc>"
	cXML += 		"<vII>0</vII>"
	cXML += 		"<vIPI>0</vIPI>"
	If cMvVerNFCe >= "4.00"
		//Somente para finNFe=4 (Devolucao)	
		cXML +=			"<vIPIDevol>0</vIPIDevol>"	
	EndIf
	cXML += 		"<vPIS>0</vPIS>"
	cXML += 		"<vCOFINS>0</vCOFINS>"
	cXML += 		"<vOutro>" + LjConvType( aNFCeW02[13], 15, 2) + "</vOutro>"
	cXML += 		"<vNF>" + LjConvType( aNFCeW02[14][1], 15, 2) + "</vNF>"
	If aNFCeW02[14][2][1] > 0
		cXML += 	"<vTotTrib>" + LjConvType( aNFCeW02[14][2][1], 15, 2) + "</vTotTrib>"
	EndIf
	cXML += 	"</ICMSTot>"

	// verifica se algum produto possui ISSQN (totalizador do vServ)
	If aNFCeW17[01] > 0
		cXML +=	"<ISSQNtot>"
		cXML +=		"<vServ>" + LjConvType( aNFCeW17[01], 15, 2 ) + "</vServ>"
		cXML +=		"<vBC>" + LjConvType( aNFCeW17[02], 15, 2 ) + "</vBC>"
		If aNFCeW17[03] > 0
			cXML +=		"<vISS>" + LjConvType( aNFCeW17[03], 15, 2 ) + "</vISS>"
		EndIF
		cXML +=		"<dCompet>" + SubStr( FWTimeStamp(5, SL1->L1_EMISNF), 1, 10 ) + "</dCompet>"
		cXML +=	"</ISSQNtot>"
	EndIf

	/*
					//W02. Total da NF-e / Retencao de Tributos
	cXML	+= 		"<retTrib>"	//facultativo
	cXML	+= 			"<vRetPIS>vRetPIS</vRetPIS>"
	cXML	+= 			"<vRetCOFINS>vRetCOFINS</vRetCOFINS>"
	cXML	+= 			"<vRetCSLL>vRetCSLL</vRetCSLL>"
	cXML	+= 			"<vBCIRRF>vBCIRRF</vBCIRRF>"
	cXML	+= 			"<vIRRF>vIRRF</vIRRF>"
	cXML	+= 			"<vBCRetPrev>vBCRetPrev</vBCRetPrev>"
	cXML	+= 			"<vRetPrev>vRetPrev</vRetPrev>"
	cXML	+= 		"</retTrib>"				
	*/

	cXML +=	"</total>"

Return cXML


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |LjNFCeTra บ Autor	ณVarejo				 บ Data ณ  16/04/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Alimenta o bloco "X. Informacoes do Transporte da NFC-e"	doบฑฑ
ฑฑบ			 |	XML que sera transmitido ao SEFAZ. *Entrega a Domicilio	  บฑฑ
ฑฑบ			 |	nao implementada.				  						  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno	 ณcXML - XML com o bloco X do layout 3.10 (NT2013.005 v1.03)  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJNFCE		                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LjNFCeTra()
	
Local cXML			:= ""
Local cTpFrete		:= ""
Local cModFrete		:= ""
Local cMvVerNFCe	:= ""
Local aGetMvTSS		:= {}
Local cTrspCGC		:= ""		// CNPJ/CPF da Transportadora
Local cTrspNome		:= ""
Local cTrspIE		:= ""
Local cTrspEnder	:= ""
Local cTrspMun		:= ""
Local cTrspUF		:= ""
Local lPOS			:= Iif(ExistFunc("STFIsPOS"), STFIsPOS(), .F.)	// Indica se eh TOTVS PDV
Local cCodTrsp		:= ""

//Obtemos a versao da NFC-e do TSS
aGetMvTSS := LjGetMVTSS("MV_VERNFCE")
If aGetMvTSS[1]
	cMvVerNFCe := AllTrim(aGetMvTSS[2])
EndIf

// Obtemos o Tipo do Frete
cTpFrete := LjTpFrete( SL1->L1_TPFRET )

// Obtemos a Modalidade do Frete
If cMvVerNFCe >= "4.00"
	If cTpFrete $ "C|R"
		cModFrete := "3"	//3=Transporte por conta do remetente
	ElseIf cTpFrete $ "F|D"
		cModFrete := "4"	//4=Transporte por conta do destinatแrio
	ElseIf cTpFrete $ "T"
		cModFrete := "2"	//2=Por conta de terceiros
	Else
		cModFrete := "9"	//9=Sem Ocorrencia de Transporte
	EndIf
Else
	If cTpFrete $ "C|F"
		cModFrete := "1"	//1=Por conta do destinatแrio/remetente
	Else
		cModFrete := "9"	//9=Sem frete
	EndIf
EndIf

cXML +=	"<transp>"

/*
Modalidade do Frete:
0=Por conta do emitente / 1=Por conta do destinatแrio/remetente / 2=Por conta de terceiros / 9=Sem frete
*/
cXML += 	"<modFrete>" + cModFrete + "</modFrete>"

If cModFrete $ "1234"
	If nModulo == 23 .AND. lPos
		cCodTrsp := STDGPBasket( "SL1" , "L1_TRANSP" )
	Else
		cCodTrsp := SL1->L1_TRANSP
	EndIf

	DbSelectArea("SA4")
	SA4->(DbSetOrder(1)) // A4_FILIAL + A4_COD
	SA4->(DbSeek(xFilial("SA4") + cCodTrsp))
	If !Empty(SA4->A4_COD)
		cTrspCGC 	:= LjConvType(AllTrim(SA4->A4_CGC), 14, 0)
		cTrspNome 	:= LjConvType(AllTrim(SA4->A4_NOME), 60, 0)
		cTrspIE 	:= LjConvType(AllTrim(SA4->A4_INSEST), 14, 0)
		cTrspEnder 	:= LjConvType(AllTrim(SA4->A4_END), 60, 0)
		cTrspMun 	:= LjConvType(AllTrim(SA4->A4_MUN), 60, 0)
		cTrspUF 	:= LjConvType(AllTrim(SA4->A4_EST), 2, 0)

		cXML += "<transporta>"
			// Todas as tags dentro do grupo <transporta> sao opcionais
			If !Empty(cTrspCGC)
				If Len(cTrspCGC) == 11
					cXML += 	"<CPF>" + cTrspCGC + "</CPF>"
				Else
					cXML += 	"<CNPJ>" + cTrspCGC + "</CNPJ>"
				EndIf
			EndIf	
			cXML += 	"<xNome>" + cTrspNome + "</xNome>"
			If !Empty(cTrspIE)
				cXML += 	"<IE>" + cTrspIE + "</IE>"
			EndIf
			cXML += 	"<xEnder>" + cTrspEnder + "</xEnder>"
			cXML += 	"<xMun>" + cTrspMun + "</xMun>"
			cXML += 	"<UF>" + cTrspUF + "</UF>"
		cXML += "</transporta>"
	EndIf
EndIf
	
/*
//Rejeicao X11-10: NFC-e com dados de Retencao do ICMS no Transporte (tag:retTransp)
cXML := "	<retTransp>	//facultativo
cXML := "		<vServ>vServ</vServ>
cXML := "		<vBCRet>vBCRet</vBCRet>
cXML := "		<pICMSRet>pICMSRet</pICMSRet>
cXML := "		<vICMSRet>vICMSRet</vICMSRet>
cXML := "		<CFOP>5351</CFOP>
cXML := "		<cMunFG>cMunFG</cMunFG>
cXML := "	</retTransp>

<--
cXML := "	<vol>
cXML := "		<qVol>qVol</qVol>
cXML := "		<esp>esp</esp>
cXML := "		<marca>marca</marca>
cXML := "		<nVol>nVol</nVol>
cXML := "		<pesoL>pesoL</pesoL>
cXML := "		<pesoB>pesoB</pesoB>
cXML := "		<lacres>
cXML := "			<nLacre>nLacre</nLacre>
cXML := "		</lacres>
cXML := "	</vol>
-->
*/

cXML += "</transp>"

Return cXML

//Y. Dados da Cobran็a
//-----------------------------------------------------------------------
/*/{Protheus.doc} LjNFCePag
Alimenta o bloco "YA - Formas de Pagamento" do XML que serแ transmitido a SEFAZ.

@author  Varejo
@since 	 16/04/2013
@version P12

@param 	 lIsNfe, L๓gico, Indica se o Documento Fiscal ้ NF-e
@param 	 aPagNfe, Array, Array passado por refer๊ncia que serแ alimentado com dados de pagamento da venda.
@param 	 lIsEnvOK, L๓gico, Indica se estแ ok para envio/transmissao do DOC
@param 	 cVerAmb, Caractere, Versใo de leiaute do Documento Eletr๔nico em uso no ambiente
@param 	 lIsNfCup, L๓gico, Indica se ้ NF-e Sobre Cupom

@return  cXML, Caractere, XML com o bloco YA
/*/
//-----------------------------------------------------------------------
Static Function LjNFCePag(lIsNfe,aPagNfe,lIsEnvOK,cVerAmb,lIsNfCup)

Local cXML			:= ""
Local cFormaCod		:= ""								//codigo da Forma de Pagamento, segundo os padroes da NFC-e
Local cL4Forma		:= ""								//valor do campo L4_FORMA sem espa็os
Local cL4FormaId	:= ""								//valor do campo L4_FORMAID sem espa็os
Local cL4Adminis	:= ""								//valor do campo L4_ADMINIS sem espa็os
Local nX			:= 0								//contador
Local aFormasPag	:= {}								//array com o codigo da Forma de Pagamento e seu respectivo valor
Local aAreaSL4		:= {}								//armazena a area da SL4
Local aCard			:= {}
Local lTagCard		:= .F.								//indica se envia a tag <card> para formas de pagamento CC/CD
Local nFatorNtF 	:= 1								//fator nใo fiscal
Local nTotalNF		:= 0								//total nใo fiscal
Local lMobile 		:= STFGetCfg("lMobile", .F.)		//valida versao mobile
Local aRecSL4		:= {} 								//Array dos Registros SL4 processados
Local nPosSL4		:= 0 								//Posicao do array SL4
Local nSum_vPag		:= 0
Local n_vTroco		:= 0
Local cMvVerNFCe	:= ""
Local aGetMvTSS		:= {}
Local lUsaTroco 	:= SuperGetMV("MV_LJTROCO",, .F.) 	//Verifica tratamento de troco
Local nLjTrDin  	:= SuperGetMV("MV_LJTRDIN",, 0) 	//Determina se utiliza troco para diferentes formas de pagamento
Local lAbatTroco	:= .T.
Local nL4Valor  	:= 0
Local nValTot		:= 0
Local cMsg			:= ""
Local nPagTot 		:= 0								//Armazena o Total de pagamentos da NFCE
Local nDifPag 		:= 0								//Armazena diferen็a entre Total de pagamentos - troco com o valor da Teg <vNF>
Local nPerc			:= 1								//Percentual do total da venda
Local aMVAMBNFCE	:= {}
Local cMVAMBNFCE	:= ""
Local cXPag			:= ""								// Tag xPag MT2020006 versใo 1.2
Local nPos			:= 0

Default lIsNfe		:= .F.
Default aPagNfe		:= {}
Default lIsEnvOK	:= .T.
Default cVerAmb 	:= ""
Default lIsNfCup	:= .F.

lMobile := IIF(lMobile == Nil, IIF(STFGetCfg("lMobile", .F.) == Nil,.F.,STFGetCfg("lMobile", .F.)),lMobile)

If lIsNfe
	cMvVerNFCe	:= cVerAmb

	If lIsNfCup
		nPerc := 1
	Else
		//Faz o cแlculo de rateio para notas que sใo faturadas parcialmente
		nPerc := SF2->F2_VALBRUT / ( SL1->L1_VLRTOT + SL1->L1_FRETE + SL1->L1_SEGURO + SL1->L1_DESPESA )
	EndIf

	If nPerc == 0
		nPerc := 1
	EndIf

Else
	//Obtemos a versao da NFC-e do TSS
	aGetMvTSS := LjGetMVTSS("MV_VERNFCE")
	If aGetMvTSS[1]
		cMvVerNFCe := AllTrim(aGetMvTSS[2])
	EndIf

	aMVAMBNFCE := LjGetMVTSS("MV_AMBNFCE","2")
	If aMVAMBNFCE[1]
		cMVAMBNFCE := SubStr( aMVAMBNFCE[2], 1, 1 )
	EndIf
EndIf

lTagCard := lIsNfe .Or. LjAnalisaLeg(68)[1] .OR. SuperGetMV("MV_NFCEGC",,.F.)

LjGrvLog(SL1->L1_NUM,"Monta a Tag Pagamento - Filial",cFilAnt)
					
aAreaSL4 := SL4->( GetArea() )
SL4->( DbSetOrder( 1 ) )

//Verifica se houve utiliza็ใo de NCC (05-Cr้dito Loja)
If SL1->L1_CREDITO > 0
	If SL1->L1_VLRLIQ == SL1->L1_CREDITO
		aAdd( aFormasPag, {"CR",((SL1->L1_CREDITO + SL1->L1_TROCO1) * nPerc), Nil,Nil,0,"S"} )
	Else
		aAdd( aFormasPag, {"CR",SL1->L1_CREDITO * nPerc, Nil,Nil,0,"S"} )
	EndIf
EndIf

//Se houve Retencao de PCC, o valor da venda sera maior que os pagamentos, pois o abatimento somente ้ feito financeiramente,
// por esse motivo ้ necessแrio incluir o valor abatido, pois senao os pagamentos nao baterao com o valor da venda.
If SL1->L1_ABTOPCC > 0
	aAdd( aFormasPag, {"PCC", SL1->L1_ABTOPCC, Nil, Nil, 0, "S"} )
EndIf

If SL4->( DbSeek( xFilial( "SL4" ) + SL1->L1_NUM ) )
	While SL4->( !EoF() ) .AND. SL4->L4_FILIAL + SL4->L4_NUM == SL1->L1_FILIAL + SL1->L1_NUM .AND. Empty( SL4->L4_ORIGEM )
		If lMobile
			//Se for mobile, verifica se o registro SL4 nใo foi processado anteriomente
			nPosSL4 := aScan(aRecSL4, { |r| r == SL4->(Recno()) })//Posicao do array SL4
			If nPosSL4 > 0			
				LjGrvLog(SL1->L1_NUM, "Pagamento ignorado pois jแ foi processado "+ SL4->L4_FORMA +;
				 			" Id " + SL4->L4_FORMAID+ " valor " + cValToChar(SL4->L4_VALOR), SL4->(Recno()) )
				SL4->( DbSkip() )
				Loop
			Else
				Aadd(aRecSL4, SL4->(Recno()))
			EndIf			
		EndIf
						
		If SL4->L4_VALOR > 0
			cL4Forma 	:= AllTrim(SL4->L4_FORMA)
			nL4Valor 	:= SL4->L4_VALOR
			cL4Adminis 	:= AllTrim(SL4->L4_ADMINIS)
			cL4FormaId	:= AllTrim(SL4->L4_FORMAID)

			If cMvVerNFCe >= "4.00"
                If ((nModulo == 23 .Or. lIsNfe) .And. (lUsaTroco .And. nLjTrDin <> 0))
                    n_vTroco += SL4->L4_TROCO
					If IsMoney(SL4->L4_FORMA)
						nL4Valor += SL4->L4_TROCO
					EndIf
                EndIf
            EndIf

			//se for utilizar a tag <card>, aglutinamos o valor da forma de pagamento por transa็ใo
			If cL4Forma $ "CC|CD" .AND. lTagCard
				nPos := aScan(aFormasPag, {|x| x[1] == cL4Forma .AND. x[4] == cL4FormaId})
			Else
				nPos := aScan(aFormasPag, {|x| x[1] == cL4Forma})
			Endif
			
			If nPos > 0
				aFormasPag[nPos][2] += nL4Valor * nPerc
				aFormasPag[nPos][6] := "N" //Pagamento a prazo
			Else
				aAdd( aFormasPag, {	cL4Forma, nL4Valor * nPerc, cL4Adminis,;
					 				Iif( cL4Forma $ "CC|CD" .AND. lTagCard, cL4FormaId, Nil), SL4->L4_TROCO * nPerc, "S" } )
			Endif
		EndIf
		SL4->( DbSkip() )
	EndDo
EndIf
		
//
//Tratamento para abater o TROCO
//
If SL1->L1_TROCO1 > 0
	n_vTroco := SL1->L1_TROCO1

	//ordenamos em ordem crescente, baseado no c๓digo da forma de pagamento da NFC-e
	aSort( aFormasPag, Nil, Nil, {|x,y| x[1] < y[1]} )
	
	lAbatTroco := cMvVerNFCe == "3.10" .Or. (cMvVerNFCe >= "4.00" .And. !lUsaTroco)

	While n_vTroco > 0 .And. lAbatTroco
		//priorizamos o abatimento na forma de pagamento R$, jแ que o troco ้ dessa mesma forma
		nPos := aScan( aFormasPag, {|x| x[1] == "R$" .AND. x[2] > 0} )
		If nPos == 0
			//se nใo houver pagamento em R$ (e nao for "CR", pois o aFormasPag jแ vem com o valor correto), abatemos o troco de outra forma de pagamento
			nPos := aScan( aFormasPag, {|x| x[1] <> "CR" .AND. x[2] >= n_vTroco} )
		EndIf

		If nPos > 0
			aFormasPag[nPos][2] -= n_vTroco
			aFormasPag[nPos][5] -= n_vTroco

			//se o valor da forma de pagamento for negativo, significa que hแ valor de troco
			If aFormasPag[nPos][2] < 0
				n_vTroco := aFormasPag[nPos][2] * -1
			Else
				n_vTroco -= n_vTroco
			EndIf				
		Else
			Exit
		EndIf
	EndDo
EndIf

// Caso tenha venda nใo fiscal
nTotalNF := aTotNaoFis[1] + aTotNaoFis[2] + aTotNaoFis[3] 
If nTotalNF > 0
	/*Faz a propor็ใo dos pagamentos em rela็ใo ao valor pago*/
	nFatorNtF := (nTotalNF + SL1->L1_FRETE) / (SL1->L1_VLRLIQ)
	For nX := 1 To Len(aFormasPag)
		aFormasPag[nX][2]	:= Round( aFormasPag[nX][2] - (aFormasPag[nX][2] * nFatorNtF), 2 )
		aFormasPag[nX][5]	:= Round( aFormasPag[nX][5] - (aFormasPag[nX][5] * nFatorNtF), 2 )
	Next nX
	
	n_vTroco :=  n_vTroco - (n_vTroco * nFatorNtF)
	
	//Quando tento vender somente um produto de ISS e hแ separa็ใo de ICMS e ISS (MV_LJPRDSV com .T.)
	If (aTotNaoFis[3] > 0) .And. (LJFatorFis( nTotalNF + SL1->L1_FRETE, SL1->L1_VLRLIQ ) == 0)	
		
		lIsEnvOK := .F. //Essa nota deve ser detectada como erro, pois nใo tem item fiscal
			
		cMsg := " Nใo hแ itens de ICMS, somente de ISS nessa nota,"+;
				"portanto a NFC-e nใo serแ transmitida - "+;
				"Desative, se possํvel, os parโmetros MV_LJPRDSV (preencha com .F.) e MV_NFCECNJ " +;
				"(preencha com .T.) para concluir a venda " +CHR(10)+CHR(13)+;
				"Caso contrแrio emita a Nota de RPS no m๓dulo Controle de Lojas"
		
		LjGrvLog(SL1->L1_NUM, cMsg)

		If !IsBlind()
			STFMessage("LjNFCePag1", "POPUP", cMsg)
			STFShowMessage("LjNFCePag1")
		Else
			Conout(cMsg)
		EndIf		
	EndIf
EndIf

LjGrvLog(SL1->L1_NUM,"Monta a Tag Pagamento - aFormasPag",aFormasPag)

/*
Protecao, para caso o pagamento vier diferente do valor da nota ajustar.
Ajusta o valor proporcionalizado na condi็ใo de pagamento em $
Necessario para evitar diferen็a de 0,01 centavos em determinadas situa็๕es
*/
aEval( aFormasPag, {|x| nSum_vPag+=Round(x[2],2) } )

IF lIsNfe
	nValTot := SF2->F2_VALFAT
Else
	If ValType(aNFCeW02) == "A"
		LjGrvLog(SL1->L1_NUM,"Monta a Tag Pagamento - aNFCeW02",aNFCeW02)
		If Len(aNFCeW02) > 13 .AND. ValType(aNFCeW02[14][1]) == "N"
			nValTot := aNFCeW02[14][1]
		EndIf
	Else
		LjGrvLog(SL1->L1_NUM,"Variavel Tag Pagamento Invalida",aNFCeW02)
	EndIf
EndIf

LjGrvLog(SL1->L1_NUM,"Informa็๕es de Pagamento - Valor Nota ",nValTot)
LjGrvLog(SL1->L1_NUM,"Informa็๕es de Pagamento - Valor Soma Pagamentos (SL4) ",nSum_vPag)

If lAbatTroco .And. (nValTot > 0) .And. (nSum_vPag <> 0) .And. (nSum_vPag <> nValTot)
	LjGrvLog(SL1->L1_NUM,"Tag Pagamento diferente",nSum_vPag)
	//Procura a forma de pagamento R$. Se nao achar procura por CH, senใo jogo na ultima forma
	nPos := aScan(aFormasPag, { |x| x[1] == "R$"} )
	If nPos == 0
		nPos := aScan(aFormasPag, { |x| x[1] == "CH"} )
	EndIf
	If nPos == 0
		nPos := Len(aFormasPag)
	EndIf
	
	aFormasPag[nPos][2] += ((nValTot + aFormasPag[nPos][5]) - nSum_vPag)
	
	LjGrvLog(SL1->L1_NUM,"Monta a Tag Pagamento - Ajuste de aFormasPag - "+; 
				"devido a arredondamento/truncamento dos valores",aFormasPag)		
EndIf

//
//YA. Formas de Pagamento
//
If cMvVerNFCe >= "4.00"
	cXML +=	'<pag>'
EndIf

For nX := 1 To Len(aFormasPag)

	//Pesquisa a sigla da forma de pagto para achar o respectivo c๓digo	
	cFormaCod := LjCdPagSef(aFormasPag[nX][3], aFormasPag[nX][1],cMvVerNFCe,lIsNfe,cMVAMBNFCE)

	If lIsNfe
		Aadd(aPagNfe,{cFormaCod,LjConvType( aFormasPag[nX][2], 15, 2 ),aFormasPag[nX][5],"2","","","",Iif(aFormasPag[nX,6] == "S","0","1"), ""})
	EndIf
		
	If aFormasPag[nX][2] > 0

		If cMvVerNFCe >= "4.00"
			cXML +=	'<detPag>'
		Else
			cXML +=	'<pag>'
		EndIf

		cXML +=	'<tPag>' + cFormaCod + '</tPag>'
		cXPag := LjxPag(cFormaCod, aFormasPag[nX][1], lIsNfe) 		
		
		If !Empty(cXPag)
			cXML += '<xPag>'+ cXPag+'</xPag>'
			If lIsNfe
				aPagNfe[Len(aPagNfe)][9] := cXPag
			Endif 
		Endif 

		cXML +=	'<vPag>' + LjConvType( aFormasPag[nX][2], 15, 2 ) + '</vPag>'
		
		nPagTot += ROUND(aFormasPag[nX][2],2)
										
		If aFormasPag[nX][1] $ "CC|CD" .AND. lTagCard
			aCard := LjNFCeCard( aFormasPag[nX][1], aFormasPag[nX][3], aFormasPag[nX][4] , lIsNfe)
			If Len(aCard) == 4
				cXML+=	'<card>'
				
				If aCard[1] == "1"
					cXML+=	'<tpIntegra>'+aCard[1]+'</tpIntegra>'
					cXML+=	'<CNPJ>' + aCard[2] + '</CNPJ>'
					cXML+=	'<tBand>' + aCard[3] + '</tBand>'
					cXML+=	'<cAut>' + aCard[4] + '</cAut>'
					
					If lIsNfe
						aPagNfe[Len(aPagNfe)][5] := aCard[2]
						aPagNfe[Len(aPagNfe)][7] := aCard[4]
					EndIf
				Else
					cXML+=	'<tpIntegra>'+aCard[1]+'</tpIntegra>'
					cXML+=	'<tBand>' + aCard[3] + '</tBand>'
				EndIf
				cXML+=	'</card>'
				
				If lIsNfe
					aPagNfe[Len(aPagNfe)][4] := aCard[1]
					aPagNfe[Len(aPagNfe)][6] := aCard[3]
				EndIf
			EndIf
		EndIf
				
		If cMvVerNFCe >= "4.00"
			cXML +=	'</detPag>'
		Else
			cXML +=	'</pag>'
		EndIf
	EndIf
Next nX
		
//Tratamento troco
If cMvVerNFCe >= "4.00" 
	If n_vTroco > 0 .And. (!lAbatTroco .Or. nModulo = 23)
			
		nPagTot := nPagTot - n_vTroco
		
		If !lIsNfe //Se for Nfe, nใo pode entrar aqui, pois, o array aNFCeW02, nใo estara carregado e provocarแ erro.
			nDifPag := Abs(aNFCeW02[14][1] - nPagTot)
		
			If nDifPag > 0 .AND. nDifPag <= 0.05 
				If aNFCeW02[14][1] > nPagTot
					n_vTroco := n_vTroco - nDifPag
				Else 
					n_vTroco := n_vTroco + nDifPag
				EndIf
			EndIf
		
		Endif

		cXML+=	'<vTroco>' + LjConvType( n_vTroco, 15, 2 ) + '</vTroco>'
		
	EndIf
	cXML +=	'</pag>'
EndIf
    	
LjGrvLog( SL1->L1_NUM, "XML da Tag Pagamento Montado", cXML )
    	
RestArea(aAreaSL4)

Return cXML

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  |LjConvUTC บ Autor	ณVarejo				 บ Data ณ  16/04/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณConverte para formato UTC (AAAA-MM-DDThh:mm:ssTZD)		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   |LjConvUTC( ExpD1, ExpC1 )									  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpD1 - Data no formato AAAAMMDD							  บฑฑ 
ฑฑบ			 ณExpC1 - Hora no formato hh:mm:ss							  บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno	 ณcRetCodBar - codigo de barras tratado						  บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJNFCE		                                              บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function LjConvUTC( dData, cHora )

	Local cUTC		:= ""	//data no padrao UTC
	Local cUFEmit	:= iIf( !lEndFis, SM0->M0_ESTCOB, SM0->M0_ESTENT )
	Local cTZD		:= SuperGetMV( "MV_NFCEUTC",, SubStr(FwGMTByUF(cUFEmit), 1, 6) )

	Default dData	:= DDATABASE
	Default cHora	:= Time()

	//Para a transmissใo da NFC-e, o horario informado deve ter hh:mm:ss
	If Len(cHora) == 5
		cHora := cHora + ":00"
	EndIf

	//Formacao da data no formato UTC (AAAA-MM-DDThh:mm:ssTZD)
	cUTC := SubStr( DtoS( dData ), 1, 4 ) + '-' +;	//AAAA
	SubStr( DtoS( dData ), 5, 2 ) + '-' 		+;	//MM
	SubStr( DtoS( dData ), 7, 2 )				+ ;	//DD
	'T' 										+ ;
	cHora										+ ;	//hh:mm:ss
	cTZD											//TZD

Return cUTC

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  |CodBarGTINบ Autor	ณVarejo				 บ Data ณ  16/04/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณValida e trata o codigo barras utilizado, ja que o SEFAZ 	  บฑฑ
ฑฑบ			 | pode rejeitar uma nota se o codigo de barras for invalido. บฑฑ
ฑฑบ			 | *A validacao do codigo de barras sera implementada 		  บฑฑ
ฑฑบ			 | futuramente, pois existem os tipos GTIN 8, 12, 13 ou 14	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   |CodBarGTIN( cCodBar )										  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcCodBar - codigo de barras								  บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno	 ณcRetCodBar - codigo de barras tratado						  บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJNFCE		                                              บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function LjVldGTIN(cCodBar)

	Local nTmCodBar	:= 0	//tamanho do codigo de barras
	Local nI		:= 0	//contador do for
	Local nIAux		:= 0
	Local cValAux	:= ""	//valor de cada digito do codigo de barra em Caracter
	Local nVal		:= 0	//valor de cada digito do codigo de barra
	Local nTotal	:= 0	//soma total dos digitos do codigo de barra
	Local nDigVerAux:= 0	//valor do ultimo digito que foi obtido
	Local cDigVerAux:= ""	//valor do digito verificador que foi obtido em Caracter
	Local cDigVer	:= ""	//ultimo digito do codigo de barras (verificador)
	Local lRet		:= .T.	//retorna se o codigo de barra eh valido ou nao

	Default cCodBar	:= ""

	cCodBar := AllTrim( cCodBar )
	nTmCodBar := Len( cCodBar )

	If nTmCodBar == 8 .OR. nTmCodBar = 13 .OR. nTmCodBar = 12 .OR. nTmCodBar = 14

	//retorna o ultimo digito do codigo de barras (verificador)
		cDigVer := Right(cCodBar, 1)
		If !IsDigit(cDigVer)
			lRet := .F.
		ElseIf cCodBar = Replicate( "0", nTmCodBar )
			lRet := .F.
		EndIf

		//Valida Prefixo GTIN, redu็ใo consideravel de rejei็ใo devido a cadastros incompletos
		if lRet .and. ExistFunc("LjGtinPref")
			lRet := LjGtinPref( Left(cCodBar,3) ) 
		endif
	
		If lRet

		//retorna o codigo de barras, exceto o ultimo digito (verificador)
			nTmCodBar := nTmCodBar-1
			cCodBar := SubStr(cCodBar, 1, nTmCodBar)

			For nI := nTmCodBar to 1 Step -1
		
				nIAux++

			//verifica se valor numerico
				cValAux := SubStr( cCodBar, nI, 1 )
			
				If IsDigit(cValAux)
					nVal := Val( cValAux )
				Else
					lRet := .F.
					Exit
				EndIf
			
			// se o contador for PAR, multiplicamos por 1 e somamos ao total
				If (nIAux % 2) == 0
					nTotal += nVal
			// se o contador for IMPAR, multiplicamos por 3 e somamos ao total
				Else
					nTotal += (nVal*3)
				EndIf

			Next nI

		// - Para obter o Digito Verificador -

		//dividimos o total por 10 e utilizamos a SOBRA para subtrair de 10
			nDigVerAux := ( 10 - (nTotal % 10) )

		//se o resultado for maior que 9, o digito atribuido sera 0
			If nDigVerAux > 9
				nDigVerAux := 0
			EndIf
		
		//verifica se o digito verificador ORIGINAL ้ igual ao obtido
			cDigVerAux := cValToChar(nDigVerAux)
			If cDigVerAux <> cDigVer
				lRet := .F.
			EndIf

		EndIf

	Else
		lRet := .F.
	EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณLjSetICMSTบAutor  ณVarejo				 บ Data ณ  16/04/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณAlimenta o vetor estatico criado nesse fonte, com os		  บฑฑ
ฑฑบ			 | dados retornados da MATXFIS (LOJA701C)					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณLjSetICMST( ExpA1 )										  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณaAuxICMSST												  บฑฑ
ฑฑบ			 ณ aICMSST[][1] Numero do item								  บฑฑ
ฑฑบ			 ณ aICMSST[][2] % da margem de valor Adicionado do ICMS ST	  บฑฑ
ฑฑบ			 ณ aICMSST[][3] % da Reducao de BC do ICMS ST				  บฑฑ
ฑฑบ			 ณ aICMSST[][4] $ da BC do ICMS ST							  บฑฑ
ฑฑบ			 ณ aICMSST[][5] % do imposto do ICMS ST					  	  บฑฑ
ฑฑบ			 ณ aICMSST[][6] $ do ICMS ST							  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJA701C		                                              บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function LjSetICMST(aAuxICMSST, nOperacao)
	
Local nPos := 0

Default aAuxICMSST	:= {}
Default nOperacao	:= 0	//0-adicionar 1-alterar ou excluir

If nOperacao == 0	// adicao
	Aadd( aICMSST, aClone(aAuxICMSST) )
Else
	If len(aAuxICMSST) > 0	// alteracao ou delecao
		nPos := Ascan( aICMSST, {|x| x[1] == aAuxICMSST[1]} )
		If nPos > 0
			aICMSST[nPos][2] := aClone( aAuxICMSST[2] )
		EndIf
	Else
		aICMSST		:= {}
	EndIf	
EndIf

//eliminamos o array da memoria
aSize( aAuxICMSST, 0 )
aAuxICMSST := Nil

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLjNFCeSetObj   บAutor  ณVarejo         บ Data ณ  01/08/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณCriar/Adiciona o objeto de grupos da NFC-e no objeto de NFCEบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณoGrp - Grupo a ser adcionado no objeto de NFCE              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FRTA271G		                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LjNFCeSetObj(oGrp)

	LjNFCENew() //Instancia o objeto static 'oLjNFCe' da NFC-e

	oLjNFCe:AddGrupo(oGrp) //Adiciona o grupo no objeto de NFC-e

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLjNFCENew    บAutor  ณVarejo           บ Data ณ  01/08/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณAlimenta objeto de NFCE utilizado para a impressใo e        บฑฑ
ฑฑบ			 |emissใo da NFC-e                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJNFCE		                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LjNFCENew()

	If oLjNFCe == NIL
		oLjNFCe := LJNFCE():New()
	EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLjNFCeSetObj   บAutor  ณVarejo         บ Data ณ  01/08/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณResponsavel por limpar o objeto da NFC-e                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณoGrp - Grupo a ser adcionado no objeto de NFCE              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FRTA271G		                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LjNFCeFree()

	If oLjNFCe <> Nil
		FreeObj(oLjNFCe)
		oLjNFCe := Nil
	EndIf

	If oXML <> Nil
		FreeObj(oXML)
		oXML := Nil
	EndIf

Return Nil

//-------------------------------------------------
/*/{Protheus.doc} LjTotNaoFi
Totaliza os valores dos itens nใo-fiscais, para que seja feita a proporcionaliza็ใo das formas de pagamento
@param aSeek	array de duas posi็๕es [1]-indica se serแ necessแrio posicionar no item [2]-indice 1 da SL2
@author Varejo
@version P11.8
@since   12/08/2014
@obs Atualmente s๓ ้ utilizado no SIGALOJA, pois o SIGAFRT jแ faz a proporcionaliza็ใo
@return  Nil
/*/
//-------------------------------------------------
Static Function LjTotNaoFi(aSeek, lItemGE, lItemServ)

	Local aArea		:= {}
	Local aSL2Area	:= {}
	Local nTmVlrItem:= 0
	Local cVlrItem	:= ""

	Default aSeek	:= {.F., {}}
	Default lItemGE := .F.
	Default lItemServ := Nil

	If Type("nDecimais") == "U"
		nDecimais := MsDecimais(1)
	EndIf
		
	If lItemServ == Nil
		lItemServ := LjIsTesISS(SL1->L1_NUM,SL2->L2_TES)
	EndIf

	//Usamos a fun็ใo GetSX3Cache ao inv้s de TamSX3, pois ela armazena o retorno em cache,
	//podendo ser chamada n vezes sem comprometer a performance
	nTmVlrItem:= GetSX3Cache("L2_VLRITEM", "X3_TAMANHO")

	If aSeek[1]
		aArea	:= GetArea()
		aSL2Area:= SL2->( GetArea() )

		DbSelectArea("SL2")
		SL2->( DbSetOrder(1) )	//L2_FILIAL + L2_NUM + L2_ITEM + L2_ITEM
		SL2->( DbSeek(aSeek[2][1] + aSeek[2][2] + aSeek[2][3] + aSeek[2][4]) )
	EndIf

	// SE FOR ITEM ENTREGA NAO FISCAL  
	If !Empty(SL2->L2_RESERVA) .AND. !(SL2->L2_ENTREGA == "2" .OR. EMPTY(SL2->L2_ENTREGA)) .AND. EMPTY(SL2->L2_PEDRES)
		aTotNaoFis[1] += a410Arred(SL2->L2_PRCTAB * SL2->L2_QUANT, "L2_VLRITEM") - SL2->L2_VALDESC - SL2->L2_DESCPRO

	// GARANTIA ESTENDIDA
	ElseIf !Empty(SL2->L2_GARANT)
		cVlrItem := Str( a410Arred(SL2->L2_VRUNIT * SL2->L2_QUANT, "L2_VLRITEM"), nTmVlrItem,nDecimais )
		LjNFCeGE( 1, {SL2->L2_PRODUTO, SL2->L2_DESCRI, cVlrItem, SL2->L2_NSERIE, SL2->L2_GARANT} )

	ElseIf lItemGE
		aTotNaoFis[2] += SL2->L2_PRCTAB - SL2->L2_VALDESC - SL2->L2_DESCPRO
		cVlrItem := Str( a410Arred(SL2->L2_VRUNIT * SL2->L2_QUANT, "L2_VLRITEM"), nTmVlrItem,nDecimais )
		LjNFCeGE( 2, {SL2->L2_PRODUTO, SL2->L2_DESCRI, cVlrItem, SL2->L2_NSERIE, Nil} )

	// SERVIวO - realizar implementa็ใo
	ElseIf lItemServ                                                                                                                         
		aTotNaoFis[3] += a410Arred(SL2->L2_PRCTAB * SL2->L2_QUANT, "L2_VLRITEM") - SL2->L2_VALDESC - SL2->L2_DESCPRO
	EndIf

	If aSeek[1]
		RestArea(aArea)
		RestArea(aSL2Area)
	EndIf

Return Nil


//-------------------------------------------------
/*/{Protheus.doc} LjNFCeGE
Realiza as opera็๕es referente a Garantia Estendida
@param nOpcao	indica qual opera็ใo deverแ ser realizada
@param aItemGE	dados do item garantido ou do tipo garantia estendida
@author Varejo
@version P11.8
@since   12/08/2014
@return  Nil
/*/
//-------------------------------------------------
Function LjNFCeGE(nOpcao, aItemGE)

	Local aAuxRelGar:= {}	//item garantido (possui um produto de garantia estendida vinculado)
	Local aAuxRelGer:= {}	//item de garantia estendida
	Local cImpRGer	:= SuperGetMV("MV_RELGART",,"U_LOJR600A") // Nome do fun็ใo que imprime Relat๓rio Gerencial
	Local nI		:= 0	//contador
	Local nAuxRelGer:= 0	//quantidade de itens garantidos por Garantia Estendida
	Local nAuxRelGar:= 0	//quantidade de itens de Garantia Estendida
	Local nNRMoeda	:= 1	//Conte๚do de nMoedaCor (Private do Loja701).
	Local lPOS 		:= STFIsPOS() 								//Pos?

	Default aItemGE	:= {}
	Default nOpcao	:= 0

	LjGrvLog(Nil,"Realiza as operacoes referente a Garantia Estendida",nOpcao)

	//adiciona o item garantido para que seja impresso no termo de garantia
	If nOpcao == 1
		aAuxRelGer := Aclone( LjxGetRGer() )
		Aadd( aAuxRelGer, aItemGE )
		LjxSetRGer( aAuxRelGer )

	//add o item de garantia estendida para que seja impresso no termo de garantia
	ElseIf nOpcao == 2
		aAuxRelGer := aClone( LjxGetRGer() )
		If Len(aAuxRelGer) > 0
		//verifica se o produto de GE ้ o igual ao item amarrado ao produto garantido
			If Atail(aAuxRelGer)[5] == aItemGE[1]
				aAuxRelGar := aClone( LjxGetRGar() )
				Aadd( aAuxRelGar, aItemGE )
				LjxSetRGar( aAuxRelGar )
			EndIf
		EndIf

	//realiza a impressใo do termo de Garantia Estendida
	ElseIf nOpcao == 3
	
		If ExistFunc(cImpRGer)
			aAuxRelGer := aClone( LjxGetRGer() )
			aAuxRelGar := aClone( LjxGetRGar() )

			nAuxRelGer := Len(aAuxRelGer)
			nAuxRelGar := Len(aAuxRelGar)
			
			If Type("nMoedaCor") <> "U"
				nNRMoeda  	:= nMoedaCor
			EndIf
        
			LjGrvLog(Nil,"Vai chamar a impressao da Garantia Estendida",cImpRGer)

			If nAuxRelGer == nAuxRelGar
				For nI := 1 to nAuxRelGer
					LjGrvLog(Nil,"Executa a impressao da Garantia Estendida",cImpRGer)
					&cImpRGer.(	aAuxRelGer[nI][1],;		//C๓digo do produto comum
									aAuxRelGer[nI][2],;		//Descri็ใo do produto comum
									aAuxRelGer[nI][3],;		//Valor do produto comum
									aAuxRelGer[nI][4],;		//N๚mero da s้rie do produto comum
									aAuxRelGar[nI][1],;		//C๓digo do produto garantia
									aAuxRelGar[nI][2],;		//Descri็ใo do produto garantia
									aAuxRelGar[nI][3],;		//Valor do produto garantia
									SA1->A1_NOME	,;			//Nome do cliente
									nNRMoeda,;					//N๚mero da moeda
									.F.,;						//Se ้ um servi็o financeiro
									lPOS )						//Se ้ um POS PDV
				Next nI
			EndIf
		EndIf

	EndIf

	LjGrvLog(Nil,"Fim da funcao de operacoes referente a Garantia Estendida")

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  LjNFCeInfA บ Autor	ณVarejo				 บ Data ณ  05/09/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Alimenta o bloco Z. Informa็ใo Adicional da NF-e 		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno	 ณcXML - XML com o bloco Z do layout 3.10 (NT2013.005 v1.03) บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJNFCE		                                              บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function LjNFCeInfA()

Local cXML			:= ""
Local nTamVar		:= 0
Local nGrupos		:= 0
Local nI			:= 0
Local nY			:= 0
//Local nSubGrupos	:= 0 
//Local nX			:= 0
Local lLj7085		:= ExistBlock("LJ7085")								//indica se o ponto de entrada estแ compilado
Local cMensagem		:= SuperGetMV("MV_LJFISMS",, "")
Local aInfAdic		:= {}
Local lImpEntTrb 	:=	SuperGetMv("MV_ENTETRB",.F.,.F.) .AND.  ;
						SL2->(ColumnPos("L2_TOTFED")) > 0 .AND. ;
						SL2->(ColumnPos("L2_TOTEST")) > 0 .AND. ;
						SL2->(ColumnPos("L2_TOTMUN")) > 0 				//verifica se esta apto a utilizar a Nova Lei da Transparencia
Local cLeiTransp	:= ""												//mensagem da nova Lei da Transparencia
Local cLeiFECP		:= ""												//Mensagem da Lei de Fundo de Combate e Erradia็ใo da Probreza
Local nValFECPtot	:= 0												//Valor total do FECP
Local lFECP 		:= ExistFunc("Lj950FECP") .AND. LjAnalisaLeg(74)[1]	//Indica se imprime o texto referente ao FECP
Local lTSSDemoOff	:= .F.												//Parametro TSS demo
Local cMobNFCETSS	:= "0"												//Tipo do TSS mobile
Local lL2FECP		:= SL2->( ColumnPos("L2_ALQFECP") > 0 .AND. ColumnPos("L2_VALFECP") > 0 )
Local aMsgInfo 		:= {}
Local aTitInfo		:= {"Preencheu", "CPF/CNPJ", "Consumidor:", "End:", "Placa:", "Km:",;
							"CPF/CNPJ Motorista:", "Nome do Motorista:", "Zera Km?:", "Med KM:",;
							"Km Ant:","Obs:"}
Local ixy			:= 0

cMobNFCETSS	:= STFGetCfg("cMobNFCETSS", "0")
lTSSDemoOff := IIF(ValType(cMobNFCETSS)="U", .F., cMobNFCETSS == "9")

If lLj7085
	aInfAdic := ExecBlock( "LJ7085", .F., .F. )
	If ValType(aInfAdic) <> "A"
		aInfAdic := { }
	EndIf
Else
	//macro-executa o parametro MV_LJMSGFIS
	If Substr(cMensagem,1,1)=="&"
		cMensagem := &( Substr(cMensagem,2,Len(cMensagem)) )
	EndIf
	cMensagem := AllTrim(cMensagem)
	
	If ExistFunc("STD7CPFGetReceipt")
		
		aMsgInfo := STD7CPFGetReceipt()

		//tratamento para menssagens no rodape do cupom pertinentes a rotina de posto
		If lMvPosto

			cMensagem += LjMsgPosto()
		
		else
			if !aMsgInfo[01]
				aMsgInfo := {}		
			endif
		
			For ixy:=2 to len(aMsgInfo)

				if !Empty(aMsgInfo[ixy])	
					cMensagem += aTitInfo[ixy] + " " + iif( ValType(aMsgInfo[ixy]) == "N",AllTrim( Str(aMsgInfo[ixy]) ),aMsgInfo[ixy]) + "/ "
				endif

			Next ixy

		endif
		cMensagem := AllTrim(cMensagem)

	EndIf

	//se o parametro tiver vazio, verifica a mensagem do campo LG_MSGCUP do Cadastro de Estacao
	If Empty(cMensagem)
		cMensagem := AllTrim(SLG->LG_MSGCUP)
	EndIf

	If lTSSDemoOff
		cMensagem := Upper("NFCe Demonstracao - Documento sem valor Fiscal") + " " + cMensagem
	EndIf

	If !Empty(cMensagem)
		aInfAdic := { {Nil, cMensagem} }
	EndIf

EndIf

//tratamento para nova Lei da Transparencia
If lImpEntTrb

	//Valida se existe nDecimais, variavel ้ Privete declarada no Loja701
	If Type("nDecimais") == "U"
		nDecimais := MsDecimais(1)	// Quantidade de casas decimais
	EndIf

	cLeiTransp := Lj950ImpNC( 	aNFCeW02[14][1]		, aNFCeW02[14][2][1], nDecimais			, .T.,;
								aNFCeW02[14][2][2]	, aNFCeW02[14][2][3], aNFCeW02[14][2][4])

	If !Empty(cLeiTransp)
		If Len( aInfAdic ) > 0
			//Se a posicao da tag infCpl estiver preenchida, concatenamos a mensagem da Lei dos Impostos
			// usamos o pipe para que haja a quebra de linha na impressao do DANFE
			cLeiTransp := Alltrim(cLeiTransp)
			If !Empty( aInfAdic[1][2] )
				aInfAdic[1][2] := aInfAdic[1][2] + "|" + cLeiTransp
			//senao adicionamos somente a mensagem da lei dos impostos a tag infCpl
			Else
				aInfAdic[1][2] := aInfAdic[1][2] + cLeiTransp
			EndIf
		Else
			aInfAdic := { {Nil, cLeiTransp} }
		EndIf
	EndIf

EndIf

//verifica se ้ obrigat๓rio o uso do FECP e se o array possui o seu valor (posicao [6])
If lFECP .AND. ( lL2FECP .OR. (Len(aICMSST) > 0 .AND. Len(aICMSST[1][2]) >= 6) )

	If lL2FECP
		nValFECPtot := aNFCeW02[02][3] //vFCP
	Else
		For nI := 1 to Len(aICMSST)
			nValFECPtot += aICMSST[nI][2][6]
		Next nI
	EndIf

	cLeiFECP := AllTrim( Lj950FECP(nValFECPtot) )

	If !Empty(cLeiFECP)
		If Len(aInfAdic) > 0
			If !Empty(aInfAdic[1][2])
				aInfAdic[1][2] := aInfAdic[1][2] + "|" + cLeiFECP
			Else
				aInfAdic[1][2] := aInfAdic[1][2] + cLeiFECP
			EndIf
		Else
			aInfAdic := { {Nil, cLeiFECP} }
		EndIf
	EndIf
EndIf

//os grupos sใo: infAdic / obsCont / obsFisco / procRef
nGrupos := Len(aInfAdic)
If nGrupos > 0 .AND. nGrupos <= 4
	cXML := "<infAdic>"

	For nI := 1 to nGrupos

		If nI == 1

			For nY := 1 to 2
			
				If ValType(aInfAdic[nI][nY]) == "C"
					nTamVar := Len( aInfAdic[nI][nY] )

				//--
				//Os trechos estใo comentados, pois vamos verificar quem deverแ preencher as tags:
				// <infAdFisco>, <obsCont>, <obsFisco> e <procRef>.
				// Caso seja o cliente, ele poderแ reaproveitar o ponto de entrada LJ7085
				//---

				/*
				//tamanho maximo para a tag infAdFisco			
				If nY == 1 .AND. nTamVar > 0 .AND. nTamVar <= 2000					
					cXML += "<infAdFisco>" + aInfAdic[nI][nY] + "</infAdFisco>"
				*/
								
				//tamanho maximo para a tag infCpl
					If nY == 2 .AND. nTamVar > 1 .AND. nTamVar <= 5000
						cXML +=	"<infCpl>" + aInfAdic[nI][nY] + iif(lIsPafNfce .AND. !Empty(SL1->L1_NUMORC) ,"DAV:"+SL1->L1_NUMORC,"") + "</infCpl>"
					Else
						Loop
					EndIf
				Else
					Loop
				EndIf
			Next

		Else
		/*
		nSubGrupos := Len( aInfAdic[nI] )		
		
		For nX := 1 to nSubGrupos

			For nY := 1 to 2
				If ValType(aInfAdic[nI][nX][nY]) <> "C"
					Exit
				EndIf
			Next

			Do Case
				Case nI == 2
					cXML += "<obsCont>"
					cXML += 	"<xCampo>" + aInfAdic[nI][nX][1] + "</xCampo>"
					cXML += 	"<xTexto>" + aInfAdic[nI][nX][2] + "</xTexto>"
					cXML += "</obsCont>"
		
				Case nI == 3
					cXML += "<obsFisco>"
					cXML += 	"<xCampo>" + aInfAdic[nI][nX][1] + "</xCampo>"
					cXML += 	"<xTexto>" + aInfAdic[nI][nX][2] + "</xTexto>"
					cXML += "</obsFisco>"

				Case nI == 4
					cXML += "<procRef>"
					cXML += 	"<nProc>" + aInfAdic[nI][nX][1] + "</nProc>"
					cXML += 	"<indProc>" + aInfAdic[nI][nX][2] + "</indProc>"
					cXML += "</procRef>"
			EndCase
		Next
		*/
		EndIf
	Next
	cXML +=	"</infAdic>"
EndIf

//Informa็๕es do Responsแvel T้cnico pela emissใo do DFe - NT 2018/002
If LjAnalisaLeg(88)[1]
	cXml += "<infRespTec>"
	cXml += "	<CNPJ>53113791000122</CNPJ>"
	cXml += "	<xContato>Renato Alves</xContato>"
	cXml += "	<email>resp_tecnico_dfe_varejo@totvs.com.br</email>"
	cXml += "	<fone>1120997271</fone>"
	cXml += "</infRespTec>"
EndIf

//retiramos os acentos e codificamos o XML conforme as normas do UTF-8
If ExistFunc("LjRmvChEs")
	cXML := LjRmvChEs(cXML)
Else
	cXML :=  RmvChrEsp(cXML)
EndIf
cXML := EnCodeUTF8(cXML)

Return cXML

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  LjCodIBGE บ Autor	ณVarejo				 บ Data ณ  24/09/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Retorna o C๓digo do Munํcipio do IBGE			 		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno	 ณcCodIBGE - C๓digo do Munํcipio perante o IBGE				  บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJNFCE		                                              บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function LjCodIBGE(cUF, cCodMun)

	Local cCodIBGE	:= ""	//c๓digo do municํpio do IBGE
	Local nPos		:= 0	//posi็ใo de um determinado elemento no array
	Local aUF		:= {}	//array com os c๓digos das UF

	Default cUF		:= ""
	Default cCodMun := ""

	If cUF <> "EX"
		Aadd( aUF, {"RO","11"} )
		Aadd( aUF, {"AC","12"} )
		Aadd( aUF, {"AM","13"} )
		Aadd( aUF, {"RR","14"} )
		Aadd( aUF, {"PA","15"} )
		Aadd( aUF, {"AP","16"} )
		Aadd( aUF, {"TO","17"} )
		Aadd( aUF, {"MA","21"} )
		Aadd( aUF, {"PI","22"} )
		Aadd( aUF, {"CE","23"} )
		Aadd( aUF, {"RN","24"} )
		Aadd( aUF, {"PB","25"} )
		Aadd( aUF, {"PE","26"} )
		Aadd( aUF, {"AL","27"} )
		Aadd( aUF, {"MG","31"} )
		Aadd( aUF, {"ES","32"} )
		Aadd( aUF, {"RJ","33"} )
		Aadd( aUF, {"SP","35"} )
		Aadd( aUF, {"PR","41"} )
		Aadd( aUF, {"SC","42"} )
		Aadd( aUF, {"RS","43"} )
		Aadd( aUF, {"MS","50"} )
		Aadd( aUF, {"MT","51"} )
		Aadd( aUF, {"GO","52"} )
		Aadd( aUF, {"DF","53"} )
		Aadd( aUF, {"SE","28"} )
		Aadd( aUF, {"BA","29"} )
	
		nPos := aScan( aUF, {|x| x[1] == cUF} )
		If nPos > 0
			cCodIBGE := aUF[nPos][2] + AllTrim(cCodMun)
		EndIf
	Else
		cCodIBGE := "99" + "99999"
	EndIf

Return cCodIBGE

//------------------------------------------------------------------------------
/*/{Protheus.doc} LjNFCeCard
Retorna os dados referentes a transa็ใo TEF, para que seja 
utilizado na tag <card> do grupo YA. Formas de Pagamento
@param cFormaPgto Sigla da forma de pagamento
@param cAdmFin 	C๓digo da administradora financeira
@param cIDCard	Se for Multi-TEF, utiliza o ID da transa็ใo
@author Varejo
@version P11.8
@since   08/10/2014
@return  aCard	Array com [1]CNPJ [2]C๓digo da Bandeira [3]C๓digo da Transa็ใo TEF
/*/
//------------------------------------------------------------------------------
Static Function LjNFCeCard(cFormaPgto, cAdmFin, cIDCard, lIsNfe)
Local aCard		:= {}					//retono da fun็ใo com os dados da transa็ใo
Local aArea		:= GetArea()			//armazena a area corrente
Local aAreaSA1	:= SA1->( GetArea() )	//armazena a area do SA1
Local nPos		:= 0					//posi็ใo de determinado elemento no array
Local nTamA1COD := TamSX3("A1_COD")[1]	//tamanho do campo A1_COD
Local nTamAECOD := TamSX3("AE_COD")[1]	//tamanho do campo AE_COD
Local cAutTEF	:= ""
Local cTpIntegra:= '2'
Local lFoundSA1	:= .F.
Local lIsSitef	:= .F.
Local lIsDiscado:= .F.
Local aAreaSL4	:= {}
Local cDESCADM	:= ""
Local cCodAdmin	:= ""

Default cFormaPgto	:= ""
Default cAdmFin		:= ""
Default cIDCard		:= ""
Default lIsNfe		:= .F.

//obtemos o codigo da administradora financeira conforme cadastrada no SA1
cCodAdmin := PadR( SubStr(cAdmFin,1,nTamAECOD), nTamA1COD )

DbSelectArea("SA1")
SA1->( DbSetOrder(1) )	//A1_FILIAL + A1_COD + A1_LOJA
lFoundSA1 := SA1->(MsSeek(xFilial("SA1") + cCodAdmin)) .AND. !Empty(SA1->A1_CGC)

//verifica se utiliza a DLL do CLISITEF
If lFoundSA1 .And. cTipTef <> "1"
	
	If !lIsNfe
		lIsSitef	:= (cTipTef == "6" .AND. Type("oTef") == "O" .AND.; 
						ValType(oTef:lTEFOk) == "L" .AND. oTef:lTEFOk .AND. Type("oTef:ARETCARTAO") == "A")
					
		lIsDiscado	:=	cTipTef == "4" .AND. Type("aTEFDados") == "A"
	EndIf

	If  (AllTrim(SL1->L1_VENDTEF) == "S") .Or. (SL1->L1_CARTAO > 0) .OR. (SL1->L1_VLRDEBI > 0) 
		aAreaSL4 := SL4->(GetArea())
		
		SL4->(DbSetOrder(1)) //L4_FILIAL + L4_NUM + L4_ORIGEM
		SL4->(DbSeek(SL1->L1_FILIAL+SL1->L1_NUM))
		
		While !SL4->(Eof()) .And. (SL4->(L4_FILIAL+L4_NUM) == SL1->(L1_FILIAL+L1_NUM))
				//o array de retorno deve ser de 1 dimensใo com 4 posi็๕es, qdo tenho mais 
				//que 1 parcela ele preenche com todos sendo que s๓ preciso de primeira parcela para enviar a Tag		
			If	AllTrim(Upper(SL4->L4_FORMA)) == AllTrim(Upper(cFormaPgto)) .And.;
				( (Empty(AllTrim(SL4->L4_FORMAID))) .Or. (AllTrim(SL4->L4_FORMAID) == AllTrim(cIDCard)) ) .And.;
				!Empty(AllTrim(SL4->L4_INSTITU)) .And. (!Empty(AllTrim(SL4->L4_AUTORIZ)) .Or. !Empty(AllTrim(SL4->L4_DOCTEF)))
				
				//indica que o TEF ้ integrado ao sistema, portanto serแ enviado todas os elementos do grupo <card>
				cTpIntegra := '1'
		
				//Tipo de Integra็ใo para pagamento - integrado
				Aadd( aCard, cTpIntegra )
		
				//CNPJ da Credenciadora de CD/CD
				Aadd( aCard, AllTrim(SA1->A1_CGC) )
		
				//Bandeira da Operadora de CC/CD
				iF NT2020006P() 
					Aadd( aCard,  LjRetTBand(SL4->L4_ADMINIS) )
				Else 
					Aadd( aCard,  LjRetTBand(SL4->L4_INSTITU) )
				Endif 
		
				//N๚mero de Autoriza็ใo da Opera็ใo
				cAutTEF := AllTrim(SL4->L4_AUTORIZ)
				If EmpTy(cAutTEF)
					cAutTEF := AllTrim(SL4->L4_NSUTEF)
					If EmpTy(cAutTEF)
						cAutTEF := AllTrim(SL4->L4_DOCTEF)
						If EmpTy(cAutTEF)
							cTpIntegra := '2'
						EndIf
					EndIf
				EndIf
			
				Aadd(aCard, cAutTEF)
			EndIf
			
			/*Saio da fun็ใo para que o retorno seja 4 conforme esperado, independente
			da quantidade de vezes do CC/CD e a fun็ใo que chama essa, faz um looping 
			por forma e por id do cartใo (quando MV_TEFMULT = .T. )*/
			If Len(aCard) > 0
				Exit
			EndIf
			
			SL4->(DbSkip())
		End
			
		RestArea(aAreaSL4)
	EndIf	

	If !lIsNfe .And. ((Len(aCard) == 0) .Or. (cTpIntegra == '2'))
		
		aCard := {}
		
		//verifica se utiliza a DLL do CLISITEF
		If lIsSitef
		
			//indica que o TEF ้ integrado ao sistema, portanto serแ enviado todas os elementos do grupo <card>
			cTpIntegra := '1'
		
			nPos := aScan( oTef:ARETCARTAO, {|x| x:CFORMA == cFormaPgto .AND. AllTrim(x:CIDCART) == AllTrim(cIDCard)} )
			If nPos > 0
				//Bandeira da Operadora de CC/CD
				cDESCADM := LjRetTBand(oTef:ARETCARTAO[nPos]:CDESCADM)
		
				//N๚mero de Autoriza็ใo da Opera็ใo
				cAutTef := oTef:ARETCARTAO[nPos]:CAUTORIZA
				If EmpTy(cAutTef)
					cAutTef := oTef:ARETCARTAO[nPos]:cNSUSITEF
					If EmpTy(cAutTef)
						cAutTef := oTef:ARETCARTAO[nPos]:cNsuAutor
						If EmpTy(cAutTef)
							cTpIntegra := '2'
						EndIf
					EndIf
				EndIf
			EndIf
		ElseIf NMODULO == 12 .AND. lIsDiscado
			/*Quando for MULTI-TEF, o L4_FORMAID ้ a pr๓pria posi็ใo do aDadosTEF,
			pois esse array serแ montado na mesma ordem que o ID do Cartao foi informado.
			Jแ quando NAO for MULTI-TEF, s๓ haverแ uma posi็ใo do aTEFDados.*/
			If Empty(cIDCard)
				nPos := 1
			Else //MV_TEFMULT habilitado
				nPos := Val(cIDCard)
			EndIf
		
			If nPos > 0
				//Bandeira da Operadora de CC/CD
				cTbBand := LjRetTBand(aTEFDados[nPos][18])
				If !Empty( cTbBand )
					cDESCADM := cTbBand
				Else
					cTpIntegra := '2'
				EndIf
		
				//N๚mero de Autoriza็ใo da Opera็ใo
				If Empty(aTEFDados[nPos][5])
					cTpIntegra := '2'
				EndIf
				
				cAutTEF := AllTrim(aTEFDados[nPos][5])
			EndIf
		EndIf
		
		If nPos > 0
			/*indica que o TEF ้ integrado ao sistema, portanto serแ
			 enviado todas os elementos do grupo <card>*/
			Aadd( aCard, cTpIntegra )
	
			//CNPJ da Credenciadora de CD/CD
			Aadd( aCard, AllTrim(SA1->A1_CGC) )
			
			//Bandeira da Operadora de CC/CD
			Aadd( aCard, cDESCADM )			
				
			//N๚mero de Autoriza็ใo da Opera็ใo
			Aadd( aCard, cAutTEF )
		EndIf
	EndIf
EndIf

If cTpIntegra == '2'

	aCard := {}

//Tipo de Integra็ใo para pagamento - nao integrado
	Aadd( aCard, cTpIntegra )

//CNPJ da Credenciadora de CD/CD
	Aadd( aCard, Nil )

//Bandeira da Operadora de CC/CD
	Aadd( aCard, LjRetTBand(cAdmFin) )

//N๚mero de Autoriza็ใo da Opera็ใo
	Aadd( aCard, Nil )

EndIf

//restauramos as areas
SA1->( RestArea(aAreaSA1) )
RestArea( aArea )

Return aCard

//------------------------
/*/{Protheus.doc} LjXMLNFCe
Atraves da funcao XMLParser, transforma um XML em um objeto
@cXML - conteudo do arquivo XML
@author  Varejo
@version P11
@since   16/01/2015
@return  aRet - [1]: indica se houve sucesso na conversao do arquivo XML / [2]: objeto convertido
/*/
//------------------------
Function LjXMLNFCe(cXML)

	Local aRet	 := Array(2)
	Local oXML				// objeto do XML convertido
	Local lRet	 := .T.		// indica se XMLParser foi executado com sucesso
	Local cAviso := ""
	Local cErro	 := ""

	oXML := XMLParser(cXML, "_", @cAviso, @cErro)

//Verifica se conseguiu montar o objeto do XML
	If !Empty(cAviso) .OR. !Empty(cErro)
		lRet := .F.

		If !IsBlind()
			If !Empty(cAviso)
				Aviso(STR0012,cAviso)	//"NFC-e: Aviso ao Converter XML"
			EndIf

			If !Empty(cErro)
				Aviso(STR0013,cErro)	//"NFC-e: Nใo conformidade ao Converter XML"
			EndIf
		Else
			If !Empty(cAviso)
				Conout(STR0012,cAviso)	//"NFC-e: Aviso ao Converter XML"
			EndIf

			If !Empty(cErro)
				conout(STR0013,cErro)	//"NFC-e: Nใo conformidade ao Converter XML"
			EndIf
		EndIf
	EndIf

	aRet[1] := lRet
	aRet[2] := oXML

Return aRet

/*/{Protheus.doc} Lj7NfceVer
Fun็ใo responsแvel por verificar se a versใo do parametro estแ correta
@lExecAuto - Se mostra mensagem ou nใo.
@author  Varejo
@version P11
@since   12/02/2015
@return  lRet / .T. -> Versใo atual ou superior / .F. -> Versใo antiga/descontinuada
/*/
Function Lj7NfceVer(lExecAuto)
	Local lRet			:= .T.
	Local cParamVersao	:= AllTrim(SuperGetMV("MV_VERNFCE",, "3.10")) //versใo da NFC-e no parametro
	Local cMsg			:= STR0027 + cParamVersao + STR0028 + "3.10|4.00" + STR0029 //#"Versใo '" ##"' da NFC-e foi descontinuada pela SEFAZ. Efetue a configura็ใo para versใo '" ###"' ou superior."

	Default lExecAuto	:= .F. //Se execauto nao exibe mensagem.

	If !(cParamVersao $ "3.10|4.00")
		lRet := .F.
		If lExecAuto
			ConOut(cMsg)
			Help( ,, "NFCEVERSAO",, cMsg, 1, 0 )
		Else
			MsgInfo(cMsg, STR0003) //Aten็ใo
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} LjChvNFCe
Fun็ใo responsแvel em chegar a chave eletronica da NFC-e
@author  Varejo
@version P11
@since   12/06/2015
@return  cChvNFCe
@obs	 Somente em casos de retransmissใo (casos especiais) de NFC-e que a chave deve ser reaproveitada
/*/
Function LjChvNFCe(cMvModNFCe, cTagCNF)

Local cCodIBGE		:= ""	//Codigo do IBGE referente a UF
Local cChvNFCe		:= ""	//Chave Eletronica da NFC-e
Local aGetMvTSS		:= {}	//[1] executado com suceso [2] conteudo do parametro

Default cMvModNFCe := ""

//Tratamento para CNPJ e Estado de Entrega/Cobran็a
If lEndFis
	cCodIBGE := LjCodIBGE( SM0->M0_ESTENT )
Else
	cCodIBGE := LjCodIBGE( SM0->M0_ESTCOB )
EndIf

// Caso vazio,obtemos a e MODALIDADE do TSS
If Empty(cMvModNFCe)
	aGetMvTSS := LjGetMVTSS("MV_MODNFCE", "1")
	If aGetMvTSS[1]
		cMvModNFCe := SubStr( aGetMvTSS[2], 1, 1 )
		If cMvModNFCe == "2"
			cMvModNFCe := "9"
		EndIf
	EndIf
EndIf

//valor da tag <Id="NFe'> e valor do campo SL1->L1_KEYNFCE
cChvNFCe :=	cCodIBGE +										;	// cUF
			SubStr( DtoS( SL1->L1_EMISNF ), 3, 2 ) +		;
			SubStr( DtoS( SL1->L1_EMISNF ), 5, 2 ) +		;	// AAMM
			AllTrim( SM0->M0_CGC ) + 						;	// CNPJ
			"65" +											;	// mod
			PadL( allTrim( SL1->L1_SERIE ), 3, "0" ) +		;	// serie
			StrZero( Val( SL1->L1_DOC ), 9 ) +				;	// nNF
			cMvModNFCe +									;	// tpEmis (modalidade)
			cTagCNF												// cNF

cChvNFCe += Modulo11( cChvNFCe )								// cDV

Return cChvNFCe

//----------------------------------------------------------------
/*/{Protheus.doc} LjNFCeGtID
Fun็ใo responsavel em retornar o status das NFC-e que estao no TSS,
baseado em alguns campos da tabela SPED050.
Os campos retornados de cada nota pelo TSS sใo:
"AMBIENTE", "MODALIDADE", "STATUS", "STATUSCANC" e "MODELO".
@param	 aNFCeID - vetor com as notas que serao consultadas (SERIE+DOC)
@author  Varejo
@version P11.8
@since   08/09/2015
@return	 aRetDados - vetor com o status de cada NFC-e
/*/
//----------------------------------------------------------------
Function LjNFCeGtID( aNFCeID, cModDoc )

Local cIDEnt		:= ""	//codigo da Entidade (IDENT da SPED001)
Local cNFCeID		:= ""	//SERIE+DOC que serao consultados (separados por ;)
Local cURLTSS		:= ""	//URL do servidor TOTVS SPED Services
Local cErro			:= ""	//armazena o erro se nao for possivel efetuar a consulta no TSS
Local nI			:= 0
Local nPosAmb		:= 0	//posicao do campo AMBIENTE no vetor retornado pelo TSS
Local nPosMod		:= 0	//posicao do campo MODALIDADE no vetor retornado pelo TSS
Local nPosStatus	:= 0	//posicao do campo STATUS no vetor retornado pelo TSS
Local nPosStCanc	:= 0	//posicao do campo STATUSCANC no vetor retornado pelo TSS
Local nPosModDoc	:= 0	//posicao do campo MODELO no vetor retornado pelo TSS
Local nPosStDPEC	:= 0	//posicao do campo STATUSDPEC no vetor retornado pelo TSS
Local lRetWS		:= .F.	//indica se o metodo do WS foi executado com sucesso
Local aAux			:= {}	//vetor auxiliar para armazenar o retorno de cada nota
Local aRetDados		:= {}	//vetor com o retorno dos dados das NFC-e
Local aNFEID		:= {}	//vetor com o retorno do TSS
Local oWs			:= Nil

Default aNFCeID		:= {}	//vetor com as NFEID (SERIE+DOC) que serao consultados
Default cModDoc		:= Substr(SL1->L1_KEYNFCE, 21,2)

// Obtem a URL do TSS
If cModDoc == "65"
	cURLTSS := AllTrim( GetNewPar("MV_NFCEURL","http://") )
Else
	cURLTSS	:= AllTrim( GetNewPar("MV_SPEDURL","http://") )
EndIf

// Obtem a Entidade do Servidor TSS
cIDEnt 	:= LjTSSIDENT(cModDoc)

//separamos cada NFEID por ponto e virgula ';'
For nI := 1 to Len( aNFCeID )
	cNFCeID += aNFCeID[nI]
	cNFCeID += ';'
Next

If cIDEnt <> Nil

	oWS								:= WSNFESBRA():New()
	oWS:_URL						:= cURLTSS + "/NFESBRA.apw"
	oWS:cUSERTOKEN					:= "TOTVS"
	oWS:cID_ENT						:= cIDEnt

	oWS:oWSNFEIDENTRADA:CID			:= cNFCeID
	oWS:oWSNFEIDENTRADA:CMODELO 	:= "NFE"	//apesar de ser NFE, obtemos a NFCE atraves do campo MODELO
	oWS:oWSNFEIDENTRADA:CSEPARATOR	:= ";"		//caracter separador de nota
	oWS:oWSNFEIDENTRADA:NTYPESEP 	:= 2

	/*
		Executa o metodo GETDADOSNFEID do webservice NFESBRA
	*/
	lRetWS := oWS:GETDADOSNFEID()

	/*
		Trata o retorno do metodo
	*/
	If ValType(lRetWS) <> "L" .OR. !lRetWS

		lRetWS := .F.

		If Empty( GetWscError(3) )
			cErro := GetWscError(1)
		Else
			cErro := GetWscError(3)
		EndIf

		If !isBlind()
			Alert(cErro)
		Else
			conout(cErro)
		EndIf

		LjGrvLog(Nil, "Erro ao executar o metodo GETDADOSNFEID: ", cErro)

	Else

		aNFEID := aClone(oWS:OWSGETDADOSNFEIDRESULT:OWSNFEIDSAI)
	
		//verifica se foi retornado algum dado
		If Len( aNFEID ) > 0

			// obtem a posicao dos campos que serao adicionados no array que sera retornado
			nPosAmb 	:= Ascan( aNFEID[1]:OWSCMPSTRUCT:OWSCAMPO, {|x| x:CCMPNAME == "AMBIENTE"} )
			nPosMod 	:= Ascan( aNFEID[1]:OWSCMPSTRUCT:OWSCAMPO, {|x| x:CCMPNAME == "MODALIDADE"} )
			nPosStatus 	:= Ascan( aNFEID[1]:OWSCMPSTRUCT:OWSCAMPO, {|x| x:CCMPNAME == "STATUS"} )
			nPosStCanc 	:= Ascan( aNFEID[1]:OWSCMPSTRUCT:OWSCAMPO, {|x| x:CCMPNAME == "STATUSCANC"} )
			nPosModDoc 	:= Ascan( aNFEID[1]:OWSCMPSTRUCT:OWSCAMPO, {|x| x:CCMPNAME == "MODELO"} )
			nPosStDPEC 	:= Ascan( aNFEID[1]:OWSCMPSTRUCT:OWSCAMPO, {|x| x:CCMPNAME == "STATUSDPEC"} )

			For nI := 1 to Len( aNFEID )

				// verifica se o modelo de documento ้ NFC-e
				If aNFEID[nI]:OWSCMPSTRUCT:OWSCAMPO[nPosModDoc]:CCMPVALUE == cModDoc

					// [1]-NFE_ID (L1_SERIE + L1_DOC)
					Aadd(aAux, aNFEID[nI]:CID)

					// [2]-AMBIENTE
					If nPosAmb > 0
						Aadd(aAux, aNFEID[nI]:OWSCMPSTRUCT:OWSCAMPO[nPosAmb]:CCMPVALUE)
					Else
						Aadd(aAux, "")
					EndIf

					// [3]-MODALIDADE
					If nPosMod > 0
						Aadd(aAux, aNFEID[nI]:OWSCMPSTRUCT:OWSCAMPO[nPosMod]:CCMPVALUE)
					Else
						Aadd(aAux, "")
					EndIf
				
					// [4]-STATUS
					If nPosStatus > 0
						Aadd(aAux, aNFEID[nI]:OWSCMPSTRUCT:OWSCAMPO[nPosStatus]:CCMPVALUE)
					Else
						Aadd(aAux, "")
					EndIf
				
					// [5]-STATUSCANC
					If nPosStCanc > 0
						Aadd(aAux, aNFEID[nI]:OWSCMPSTRUCT:OWSCAMPO[nPosStCanc]:CCMPVALUE)
					Else
						Aadd(aAux, "")
					EndIf				

					//[6]-STATUSDPEC
					If nPosStDPEC > 0
						Aadd(aAux, aNFEID[nI]:OWSCMPSTRUCT:OWSCAMPO[nPosStDPEC]:CCMPVALUE)
					Else
						Aadd(aAux, "")
					EndIf

				EndIf

				If Len(aAux) > 0
					//adiciona as informacoes no array que sera retornado
					Aadd(aRetDados, aClone(aAux))

					//limpa o array auxiliar
					aSize(aAux,0)
				EndIf

			Next

			// destroi o aNFEId e o aAux
			aSize(aNFEID,0)
			aNFEID := Nil
			aAux := Nil

		Else
			LjGrvLog( Nil, "Nao foi retornado nenhuma informacao sobre as notas")
		EndIf

	EndIf
	
	// destroi o objeto oWS
	If ValType(oWS) == "O"
		FreeObj(oWS)
		oWS := Nil
	EndIf

EndIf

Return aRetDados


//----------------------------------------------------------------
/*/{Protheus.doc} LjNFCeSupl
Alimenta o bloco "ZX. Informa็๕es Suplementares da Nota Fiscal"
@param	 cPreXML - arquivo XML gerado at้ o momento
@author  Varejo
@version P11.8
@since   30/09/2015
@return	 cXML - XML com o bloco ZX, layout 3.10 (NT2015.002)
/*/
//----------------------------------------------------------------
Static Function LjNFCeSupl( cPreXML,cMvModNFCe )

	Local cXML			:= ""	//XML retornado com o bloco ZX
	Local cURLQrCode 	:= ""	//link de consulta do QR-Code gerado antes do envio da NFC-e
	Local cURLCP		:= ""	//URL de consulta publica
	Local cMvAmbNFCe	:= ""	//Codigo do Ambiente
	Local aGetMvTSS		:= {}
	Local cMvVerNFCe	:= ""

	Default cMvModNFCe	:= ""
	Default cPreXML		:= ""

	LjGrvLog("", "XML usado para geracao da tag infNFeSupl", cPreXML )

	//Obtemos o AMBIENTE do TSS
	aGetMvTSS := LjGetMVTSS("MV_AMBNFCE","2")
	If aGetMvTSS[1]
		cMvAmbNFCe := SubStr( aGetMvTSS[2], 1, 1 )
	EndIf

	//Obtemos a versao da NFC-e do TSS
	aGetMvTSS := LjGetMVTSS("MV_VERNFCE")
	If aGetMvTSS[1]
		cMvVerNFCe := AllTrim(aGetMvTSS[2])
	EndIf

	//Caso vazio, obtemos a e MODALIDADE do TSS
	If Empty(cMvModNFCe)
		aGetMvTSS := LjGetMVTSS("MV_MODNFCE","1")
		If aGetMvTSS[1]
			cMvModNFCe := SubStr( aGetMvTSS[2], 1, 1 )
		EndIf
	Endif
	//obtemos o link de consulta do qr-code
	cURLQrCode := LJQRCODE_2(cPreXML, Nil, cMvVerNFCe, cMvModNFCe)
	
	//Obtem o link de consulta publica
	cURLCP := LjNFCeURL(cMvAmbNFCe, .T. /*lURLChave*/)

	cXML += '<infNFeSupl>'
	cXML += 	'<qrCode><![CDATA[' + cURLQrCode +']]></qrCode>'
	If cMvVerNFCe >= "4.00"
		cXML +=	'<urlChave>' + cURLCP + '</urlChave>'
	EndIf
	cXML += '</infNFeSupl>'

Return cXML


//------------------------------------------------
/*/{Protheus.doc} LJQRCODE_2
Retorna o link de consulta do QR-Code
@param	 cXML - arquivo XML da venda
@param	 cXMLSig - arquivo XML assinado pelo TSS
@author  Varejo
@version P11.8
@since   30/09/2015
@obs	 Substituira a funcao LjNFCeQRCo, pois oferece melhor desempenho, al้m de nใo precisar de variaveis Private.
		 Cuidado ao alterar algum X2Path, pois eles sao case sensitive
@return	 cURLQRCode - Link de consulta do QR-Code
/*/
//------------------------------------------------
Static Function LJQRCODE_2(cXML, cXMLSig, cMvVerNFCe, cMvModNFCe)

Local c_chNFe		:= ""	//parametro do qr-code - chave de acesso
Local c_nVersao		:= ""	//parametro do qr-code - versao do qr-code
Local c_tpAmb		:= ""	//parametro do qr-code - ambiente
Local c_cDest		:= ""	//parametro do qr-code - id do destinatario (cpf/cnpj/idestrangeiro)
Local c_dhEmi		:= ""	//parametro do qr-code - data de emissao
Local c_vNF			:= ""	//parametro do qr-code - valor da NF
Local c_vICMS		:= ""	//parametro do qr-code - valor do ICMS
Local c_digVal		:= ""	//parametro do qr-code - digest value
Local c_cHashQRC	:= ""	//parametro do qr-code - hash do qr-code
Local c_idToken		:= AllTrim( SuperGetMV("MV_NFCEIDT",,"") )
Local cCSC			:= AllTrim( SuperGetMV("MV_NFCETOK",,"") )
Local cXMLToSign	:= ""
Local cURLQRCode	:= ""	//URL para consulta atraves do QR-Code
Local oXML

Default cXML		:= ""	//XML da venda
Default cXMLSig 	:= ""	//XML assinado pelo TSS
Default cMvVerNFCe	:= ""
Default cMvModNFCe	:= ""

//instancia um objeto da classe TXML Manager
oXML := TXMLManager():New()

//executa o PARSE na string XML
lRetAux := oXML:Parse( cXML )
If !lRetAux
	If !Empty( oXML:Error() )
		LjGrvLog( SL1->L1_NUM, "ERRO AO EXECUTAR O METODO PARSE: ", oXML:Error() )
	ElseIf !Empty( oXML:Warning() )
		LjGrvLog( SL1->L1_NUM, "AVISO AO EXECUTAR O METODO PARSE: ", oXML:Warning() )
	EndIf
EndIf

//registramos o NAMESPACE do arquivo XML
If lRetAux
	lRetAux := oXML:XPathRegisterNS( "ns", "http://www.portalfiscal.inf.br/nfe" )
	If !lRetAux
		LjGrvLog( SL1->L1_NUM, "ERRO AO REGISTRAR O NAMESPACE: ", oXML:Error() )
	EndIf
EndIf

/*
	Parametros da URL do QR Code
*/

// Chave de Acesso da NFC-e
If lRetAux
	c_chNFe := oXML:XPathGetAtt( "/ns:NFe/ns:infNFe", "Id" )
	If Empty(c_chNFe)
		lRetAux := .F.
		LjGrvLog( SL1->L1_NUM, "Nใo foi possํvel obter o atributo Id" )
	Else
		If cMvVerNFCe >= "4.00"
			c_chNFe := StrTran(c_chNFe, "NFe")
		Else
			c_chNFe := "chNFe=" + StrTran(c_chNFe, "NFe")
		EndIf
	EndIf
EndIf

// Versใo do QR-Code
If cMvVerNFCe >= "4.00"
	c_nVersao := "2"	//QRCode 2.0
Else
	c_nVersao := "&nVersao=100"
EndIf


// Identifica็ใo do Ambiente (1–Produ็ใo ou 2–Homologa็ใo) e da URL do QR-Code
If lRetAux
	c_tpAmb := oXML:XPathGetNodeValue( "/ns:NFe/ns:infNFe/ns:ide/ns:tpAmb" )
	If Empty(c_tpAmb)
		lRetAux := .F.
		LjGrvLog( SL1->L1_NUM, "Nใo foi possํvel obter o valor da tag tpAmb" )
	Else
		If cMvVerNFCe >= "4.00"
			c_tpAmb := c_tpAmb
		Else
			cURLQRCode := LjNFCeURL(c_tpAmb)
			c_tpAmb := "&tpAmb=" + c_tpAmb
		EndIf
	EndIf
EndIf

// Documento de Identifica็ใo do Consumidor (CNPJ/CPF/ID Estrangeiro)
// Na hip๓tese do CONSUMIDOR NAO SE IDENTIFICAR, nใo existirแ o parโmetro cDest no qr-code
If lRetAux
	If oXML:XPathHasNode( "/ns:NFe/ns:infNFe/ns:dest/ns:CPF" )
		c_cDest := "&cDest=" + oXML:XPathGetNodeValue( "/ns:NFe/ns:infNFe/ns:dest/ns:CPF" )
	ElseIf oXML:XPathHasNode( "/ns:NFe/ns:infNFe/ns:dest/ns:CNPJ" )
		c_cDest := "&cDest=" + oXML:XPathGetNodeValue( "/ns:NFe/ns:infNFe/ns:dest/ns:CNPJ" )
	ElseIf oXML:XPathHasNode( "ns:NFe/ns:infNFe/ns:dest/ns:idEstrangeiro" )
		c_cDest := "&cDest=" + oXML:XPathGetNodeValue( "/ns:NFe/ns:infNFe/ns:dest/ns:idEstrangeiro" )
	EndIf
EndIf

// Data e Hora de Emissใo da NFC-e (em hexadecimal)
If lRetAux
	c_dhEmi := oXML:XPathGetNodeValue( "/ns:NFe/ns:infNFe/ns:ide/ns:dhEmi" )
	If Empty(c_dhEmi)
		lRetAux := .F.
		LjGrvLog( SL1->L1_NUM, "Nใo foi possํvel obter o valor da tag dhEmi" )
	Else
		If cMvVerNFCe >= "4.00"
			c_dhEmi := SubStr(c_dhEmi, 9, 2)
		Else
			c_dhEmi := "&dhEmi=" + LjASC2Hex(c_dhEmi)
		EndIf
	EndIf
EndIf

// Valor Total da NFC-e
If lRetAux
	c_vNF := oXML:XPathGetNodeValue( "/ns:NFe/ns:infNFe/ns:total/ns:ICMSTot/ns:vNF" )
	If Empty(c_vNF)
		lRetAux := .F.
		LjGrvLog( SL1->L1_NUM, "Nใo foi possํvel obter o valor da tag vNF" )
	Else
		If cMvVerNFCe >= "4.00"
			c_vNF := c_vNF
		Else
			c_vNF := "&vNF=" + c_vNF
		EndIf
	EndIf
EndIf

// Valor Total ICMS na NFC-e
If lRetAux
	c_vICMS := oXML:XPathGetNodeValue( "/ns:NFe/ns:infNFe/ns:total/ns:ICMSTot/ns:vICMS" )
	If Empty(c_vICMS)
		lRetAux := .F.
		LjGrvLog( SL1->L1_NUM, "Nใo foi possํvel obter o valor da tag vICMS" )
	Else
		c_vICMS := "&vICMS=" + c_vICMS
	EndIf
EndIf

// Digest Value da NFC-e
If lRetAux
//obtemos o XML que sera assinado <infNFe>
	cXMLToSign := LjGrupoXML(cXML, "infNFe")
	If Empty(cXMLToSign)
		lRetAux := .F.
		LjGrvLog( SL1->L1_NUM, "Nใo foi possํvel obter o grupo infNFe para gera็ใo do Digest Value" )
	Else
	//obtemos o digest value sobre o grupo infNFe
		c_digVal := LjDigVal(cXML, "infNFe", cXMLtoSign, "xmlns")
		If Empty( c_digVal )
			lRetAux := .F.
			LjGrvLog( SL1->L1_NUM, "Nใo foi possํvel obter o Digest Value" )
		Else
			If cMvVerNFCe >= "4.00"
				c_digVal := LjASC2Hex(c_digVal)
			Else
				c_digVal := "&digVal=" + LjASC2Hex(c_digVal)
			EndIf
		EndIf
	EndIf
EndIf

// Identificador do CSC – C๓digo de Seguran็a do Contribuinte
If lRetAux
	If Empty(c_idToken) .OR. Len(c_idToken) <> 6
		lRetAux := .F.
		LjGrvLog( SL1->L1_NUM, "Parโmetro MV_NFCEIDT ausente, nใo preenchido ou preenchido incorretamente" )
		Help( ,, "NFCEIDCSC",, "Parโmetro MV_NFCEIDT ausente, nใo preenchido ou preenchido incorretamente", 1, 0 )
	Else
		If cMvVerNFCe >= "4.00"
			c_idToken := c_idToken
		Else
			c_idToken := "&cIdToken=" + c_idToken
		EndIf
	EndIf
EndIf

//verifica se o CSC esta cadastrado no parametro MV_NFCETOK
If lRetAux
	If Empty(cCSC)
		lRet := .F.
		LjGrvLog( SL1->L1_NUM, "Parโmetro MV_NFCETOK ausente ou nใo preenchido" )
		Help( ,, "NFCECSC",, "Parโmetro MV_NFCETOK ausente ou nใo preenchido", 1, 0 )
	EndIf
EndIf

If lRetAux

	If cMvVerNFCe >= "4.00"

		c_idToken := cValToChar(Val(c_idToken))

		If cMvModNFCe == "1"
			//Concatena todas as informacoes e extrai Hash(SHA1)
			c_cHashQRC := Upper(SHA1(c_chNFe + "|" + c_nVersao + "|" + c_tpAmb + "|" + c_idToken + cCSC))
			
			//QR Code 2.0 - NFC-e Online
			cURLQRCode := LjNFCeURL(c_tpAmb) 	+ "p="	//URL da SEFAZ
			cURLQRCode += c_chNFe				+ "|"	//Chave de Acesso
			cURLQRCode += c_nVersao				+ "|"	//Versใo QR Code
			cURLQRCode += c_tpAmb				+ "|"	//Tipo do Ambiente
			cURLQRCode += c_idToken				+ "|"	//Identificador CSC
			cURLQRCode += c_cHashQRC					//C๓digo HASH
		Else
			//Concatena todas as informacoes e extrai Hash(SHA1)
			c_cHashQRC := Upper(SHA1(c_chNFe + "|" + c_nVersao + "|" + c_tpAmb + "|" + c_dhEmi + "|" + c_vNF + "|" + c_digVal + "|" + c_idToken + cCSC))

			//QR Code 2.0 - NFC-e Offline
			cURLQRCode := LjNFCeURL(c_tpAmb)	+ "p="	//URL da SEFAZ
			cURLQRCode += c_chNFe 				+ "|"	//Chave de Acesso
			cURLQRCode += c_nVersao 			+ "|"	//Versใo QR Code
			cURLQRCode += c_tpAmb 				+ "|"	//Tipo do Ambiente
			cURLQRCode += c_dhEmi 				+ "|"	//Data Emissใo
			cURLQRCode += c_vNF 				+ "|"	//Valor Total
			cURLQRCode += c_digVal 				+ "|"	//Digest Value
			cURLQRCode += c_idToken 			+ "|"	//Identificador CSC
			cURLQRCode += c_cHashQRC					//C๓digo HASH
		EndIf

	Else
		// Codigo Hash(SHA1) dos parametros do QR-Code
		c_cHashQRC := c_chNFe + c_nVersao + c_tpAmb + c_cDest + c_dhEmi + c_vNF + c_vICMS + c_digVal + c_idToken + cCSC
		c_cHashQRC := SHA1( c_cHashQRC )
		c_cHashQRC := "&cHashQRCode=" + Upper( c_cHashQRC )

		//Montamos o link de consulta do qr-code 
		cURLQRCode += c_chNFe
		cURLQRCode += c_nVersao
		cURLQRCode += c_tpAmb
		cURLQRCode += c_cDest
		cURLQRCode += c_dhEmi
		cURLQRCode += c_vNF
		cURLQRCode += c_vICMS
		cURLQRCode += c_digVal
		cURLQRCode += c_idToken
		cURLQRCode += c_cHashQRC
	EndIf

	LjGrvLog( SL1->L1_NUM, "QR-Code gerado pelo ERP: ", cURLQRCode )

EndIf

//destruimos a variavel do objeto TXML
oXML := Nil

Return cURLQRCode


//-----------------------------------------------------
/*/{Protheus.doc} LjGrupoXML
Retorna a string XML referente ao grupo (cGrupo)
@param	 cXML - arquivo XML da venda
@param	 cGrupo - grupo do XML que deverแ ser retornado
@author  Varejo
@version P11.8
@since   30/09/2015
@obs	 Essa fun็ใo pode ser removida, caso algum m้todo da classe TXMLManager nos atenda
@return	 cRetXML - XML do grupo (tag)
/*/
//-------------------------------------------------------
Static Function LjGrupoXML(cXML, cGrupo)

	Local cRetXML	:= ""
	Local nAt		:= 0

	Default cXML 	:= ""
	Default cGrupo 	:= ""

	If !Empty(cXML)

	/*	
	OBTEMOS O BLOCO DO XML QUE SERA ASSINADO
		tag: infNFe
		XML: <?xml version='1.0' encoding='UTF-8'?><NFe xmlns='http://www.portalfiscal.inf.br/nfe'><infNFe versao='3.10' Id='NFe'>...</infNFe></NFe>
		retorno: <infNFe versao='3.10' Id='NFe'>...</infNFe>	
	*/
	
	// IDENTIFICAMOS ONDE COMEวA A ABERTURA DA TAG (posicao indicada pelo pipe)
	// <?xml version='1.0' encoding='UTF-8'?><NFe xmlns='http://www.portalfiscal.inf.br/nfe'>|<infNFe...
		nAt := At( "<" + cGrupo, cXML )

	// REMOVEMOS DO XML TUDO QUE ANTECEDE A ABERTURA DA TAG
	// resultado: <infNFe versao='3.10' Id='NFe'>...</infNFe></NFe>
		cRetXML	:= SubStr( cXML, nAt )

	// IDENTIFICAMOS ONDE COMEวA O FECHAMENTO DA TAG (posicao indicada pelo pipe)
	// <infNFe versao='3.10' Id='NFe'>...|</infNFe></NFe>
		nAt := At( "</" + cGrupo + ">", cRetXML )
	
	// OBTEMOS O INICIO E FIM DA TAG
	// resultado: <infNFe versao='3.10' Id='NFe'>...</infNFe>
		cRetXML	:= SubStr( cRetXML, 1, nAt+Len(cGrupo)+2 )
    
	EndIf
	
Return cRetXML


//-----------------------------------------------------
/*/{Protheus.doc} LjDigVal
Calcula e retorna o digest value do XML
@param	 cXML - String XML da venda. Usado somente para obten็ใo do namespace
@param	 cTagtoSign - Tag do grupo a qual recebera o namespace
@param	 cXMLtoSign - String XML a ser assinado
@param	 cNomeNS - Identifica็ao do NameSpace do XML
@author  Varejo
@version P11.8
@since   30/09/2015
@obs	 Essa fun็ใo deve retornar o mesmo valor que sera calculado pelo TSS no momento da assinatura do arquivo XML,
		 para confer๊ncia, verifique a tag <DigestValue> do XML obtido atrav้s do campo SPED050.XML_SIG 
@return	 cDigVal - digest value do XML
/*/
//-------------------------------------------------------
Static Function LjDigVal(cXML, cTagtoSign, cXMLtoSign, cNomeNS)

	Local cDigVal		:= ""	//digest value que sera retornado
	Local cURLNS		:= ""	//URL do namespace que sera obtido no XML da venda
	Local nPos			:= 0
	Local lRetAux		:= .F.	//variavel auxiliar para os metodos da classe TXMLManager
	Local cEVPDigest	:= "EVPDigest"
	Local oXML			:= Nil	//objeto da classe TXMLManager

	Default cXML		:= ""
	Default cTagToSign	:= ""
	Default cXMLtoSign	:= ""
	Default cNomeNS		:= ""

//instancia um objeto da classe TXML Manager
	oXML := TXMLManager():New()

	lRetAux := oXML:Parse( cXML )
	If !lRetAux
		If !Empty( oXML:Error() )
			LjGrvLog( SL1->L1_NUM, "ERRO AO EXECUTAR O METODO PARSE: ", oXML:Error() )
		ElseIf !Empty( oXML:Warning() )
			LjGrvLog( SL1->L1_NUM, "AVISO AO EXECUTAR O METODO PARSE: ", oXML:Warning() )
		EndIf
	EndIf

	//obtemos a URL do NameSpace
	aNS := oXML:XPathGetRootNsList()
	nPos := Ascan( aNS, {|x| x[1] == cNomeNS} )
	If nPos > 0
		cURLNS := "'" + AllTrim( aNS[nPos][2] ) + "'"
	Else
		LjGrvLog( SL1->L1_NUM, "NAMESPACE nao encontrado: ", cNomeNS )
	EndIf
	
	/*
	ADICIONAMOS O NAMESPACE AO BLOCO DO XML QUE SERA ASSINADO
 	cXMLtoSign	: <infNFe versao='3.10' Id='NFe'>...</infNFe>
 	NameSpace	: xmlns='http://www.portalfiscal.inf.br/nfe'
 	retorno		: <infNFe xmlns='http://www.portalfiscal.inf.br/nfe' versao='3.10' Id='NFe'>...</infNFe>
	*/
	cXMLtoSign := StrTran( cXMLtoSign, "<"+cTagtoSign, "<"+cTagtoSign+" "+cNomeNS+"="+cURLNS )

	// canonizamos a string XML
	cXMLtoSign := oXML:CanonicalC14N( cXMLtoSign )
	
/*
	Protegemos a execu็ใo da fun็ใo EVPDigest, pois como o robopatch utiliza a primeira versใo da build para gerar os pacotes,
	esses pacotes podem nใo possuir essa fun็ใo, causando o erro "Invalid Type Function" em tempo de execu็ใo.
	Esse procedimento foi recomendado pela equpe de TEC.
*/
	If ExistFunc(cEVPDigest)
		LjGrvLog( SL1->L1_NUM, "XML para geracao do DigestValue: ", cXMLtoSign )
	
		// obtemos o Digest Value e o encodamos para a Base 64
		cDigVal := &cEVPDigest.(cXMLtoSign, 3/*SHA1*/)
		cDigVal := Encode64( cDigVal )
		LjGrvLog( SL1->L1_NUM, "Digest Value calculado pelo ERP: ", cDigVal )
	Else
		LjGrvLog( SL1->L1_NUM, "Fun็ใo EVPDigest nใo compilada no RPO. Por favor, atualize a build." )
	EndIf

	// destroi as variaveis
	aSize(aNS, 0)
	aNS := Nil
	oXML := Nil

Return cDigVal


//-----------------------------------------------------
/*/{Protheus.doc} LjGetMVTSS
Retorna os parametros da tabela SPED000 do TSS de determinada Entidade (IDENT)
@param	 cParametro - Parametro a ser retornado do servidor TSS
@param	 uDefValue - Valor padrใo, valido somente para NFCe enviada pela Lib do perif้rico
@author  Varejo
@version P11.8
@since   30/09/2015
@obs	 Nao utilizamos os parametros do ERP, pois nas situa็๕es em que o TSS entra em contigencia de forma automatica,
		 ele nao atualiza os parametros do ERP, causando divergencia na chave gerada pelo ERP e a chave que ้ gerada pelo TSS.
@return	 aRet - [1](L) retorno de execucao do WS [2](X) valor do parametro
/*/
//-------------------------------------------------------
Function LjGetMVTSS( cParametro, uDefValue )

	Local cURL		:= SuperGetMV("MV_NFCEURL",,"")	//URL do servidor TSS
	Local cIDEnt	:= ""							//IDENT configurado no servidor TSS
	Local cErro		:= ""
	Local aRet		:= {}							//array de duas posicoes: [1] execucao do WS [2] valor do parametro solicitado
	Local aAuxMvTSS := {}
	Local nI		:= 0							//contador
	Local nPos		:= 0
	Local lRetWS	:= .T.							//indica se o m้todo do WS foi executado com sucesso
	Local lContinua	:= .T.							//indica se havera uma nova tentativa de consulta em caso de falhaS
	Local oWS		:= Nil							//objeto do WS
	Local lNFCETESS 	:= STFGetCfg("lNFCeTSS", .T.) //NFCE TSS

	Default cParametro := ""
	Default uDefValue := ""

	lNFCETESS := If(ValType(lNFCETESS) <> "L", .T., lNFCETESS)

	// Se for do tipo UNKNOWN(U), significa que ainda nao houve uma consulta ao servidor TSS
	If ValType(aMVTSS) == "U" .and. lNFCETESS

		//retorna o IDENT configurado no servidor TSS
		cIDEnt := LjTSSIDENT("65")

		//se a IDENT foi retornado com sucesso
		If !Empty( cIDEnt )

			//instancia o WS responsavel por retornar as configura็๕es do TSS
			oWS := WSSPEDCfgNFe():New()
	
			oWS:cUSERTOKEN := "TOTVS"
			oWS:_URL := AllTrim(cURL) + "/SPEDCFGNFe.apw"
			oWS:cMODELO	:= "65"
			oWS:oWSENTSGETALLMV:cID := cIDEnt
			oWS:oWSENTSGETALLMV:cSEPARATOR := ''
			oWS:oWSENTSGETALLMV:nTYPESEP := 3	//somente as informacoes de uma entidade serao retornadas
		
			While lContinua
	
			//executa o m้todo do Web Services
				lRetWS := oWS:GetAllMVTSS()
			
			//tratamento para caso de erro de execucao do WS
				If ValType(lRetWS) == "U" .OR. !lRetWS
					lRetWS := .F.
	
					If !Empty( GetWscError(3) )
						cErro := GetWscError(3)	//SOAP Fault Description						
					Else
						cErro := GetWscError(1)	//Resumo do Erro
					EndIf					
				Else
					aAuxMvTSS := aClone( oWS:OWSGETALLMVTSSRESULT:OWSRETGETALLMV[1]:OWSMVSTRUCT:OWSRETMVGETALLMV )
					nLenMvTSS := Len(aAuxMvTSS)

				//iniciamos o array estatico
					aMvTSS := {}

					For nI := 1 to nLenMvTSS
						Aadd( aMvTSS, {aAuxMvTSS[nI]:cMVNAME, aAuxMvTSS[nI]:cMVVALUE} )
					Next
				EndIf
			
				If !lRetWS
				//Se houve falha na execucao do WS E tem interface de usuario, pode-se tentar novamente		
					If !IsBlind()
						nOpcao := Aviso("GetAllMVTSS - Erro ao executar o m้todo", cErro, {"Sim", "Nao"}, 3, "Tentar novamente?")
						If nOpcao == 1
							lContinua := .T.
						Else
							lContinua := .F.
						EndIf
					Else
						lContinua := .F.						
					EndIf
					LjGrvLog( Nil, "GetAllMVTSS - Erro ao executar o m้todo: ", cErro)
				
					If !lContinua
					//destruimos o array estatico
						If ValType( aMvTSS ) == "A"
							aSize( aMvTSS, 0 )
						EndIf
						aMvTSS := Nil
					EndIf
				Else
					lContinua := .F.
				EndIf
			EndDo
		Else
			lRetWS := .F.
		EndIf
	EndIf

	/* Obtemos o valor do parametro solicitado (cParametro),
	se nao for solicitado nenhum parametro, nao retornamos nenhum valor */
	If lRetWS .AND. !Empty( cParametro ) .and. lNFCETESS

		nPos := Ascan( aMvTSS, {|x| x[1] == cParametro} )
		If nPos > 0
			aRet := { lRetWS, aMvTSS[nPos][2] }
		Else
			cErro := "O parโmetro " + cParametro + " nใo foi retornado da Entidade " + cIDEnt +;
				". Execute a configura็ใo do servidor TSS atrav้s da rotina Controle de Lojas"

			If !isBlind()
				Aviso( "GetAllMVTSS - Parโmetro nใo localizado", cErro, {"OK"}, 3 )
			EndIf
			LjGrvLog(Nil, cErro , aMvTSS)

			aRet := { .F., "" }
		EndIf
	ElseIf !lNFCETESS
		If uDefValue <> NIL
			aRet := { .F., SuperGetMv(cParametro,,uDefValue) }
		Else
			aRet := { .F., SuperGetMv(cParametro) }
		EndIf
	Else
		aRet := { lRetWS, "" }
	EndIf

//destruicao das variaveis
	aSize( aAuxMvTSS, 0)
	aAuxMvTSS := Nil
	oWS := Nil
	
Return aRet

/*
	fun็๕es temporarias - serao removidas futuramente
*/
Function LjNFCeRetr()

	Local aNum			:= {}	//array com os orcamentos que serao retransmitidos
	Local nResposta		:= 2	//resposta default da fun็ใo Pergunta (2-Cancelar)
	Local cResultSet	:= GetNextAlias()	//alias do result set
	Local cCondSerie 	:= "% %"			//condicao da query referente ao campo L1_SERIE
	Local cCondChave	:= ""				//condicao da query referente ao campo L1_KEYNFCE
	Local cCondSAT		:= "% %"			//condicao da query referente ao campo L1_SERSAT
	Local cLastQuery	:= ""				//string com a query que serแ executada - para efeito de log
	
	nResposta := Aviso( STR0030				,;	//
	STR0031				+;
		CRLF				+;
		CRLF + STR0032		+;
		CRLF + STR0033		+;
		CRLF + STR0034		+;
		CRLF + STR0035		+;
		CRLF + STR0036		,;	//
	{STR0037, STR0038}	,;	//
	3					)	//

// indica que continua a opera็ใo
	If nResposta == 1
	
		If Pergunte("LJNFCERETR",.T.)
	
			//tratamento para Ambiente
			MV_PAR06 := cValToChar(MV_PAR06)
			If MV_PAR06 == "3"			//0-XML da nota fiscal de origem
				MV_PAR06 := "0"
			EndIf
		
			//tratamento para Modalidade
			MV_PAR07 := cValToChar(MV_PAR07)
			If MV_PAR07 == "3"			//0-XML da nota fiscal de origem
				MV_PAR07 := "0"
			ElseIf MV_PAR07 == "2"		//9-Contingencia Offline da NFC-e
				MV_PAR07 := "9"
			EndIf
	
			// condicao para a serie (se a serie nao foi informada nos parametros, trazemos todas as notas)
			If !Empty( MV_PAR01 )
				cCondSerie := "% AND SL1.L1_SERIE = '" + MV_PAR01 + "' %"
			EndIf
		
			//condicao para a chave da NFC-e (verifica se o campo L1_KEYNFCE estแ preechido)
			cCondChave := "% AND SL1.L1_KEYNFCE <> '"+Space(TamSX3("L1_KEYNFCE")[1])+"' %"
		
			//condicao para nao trazer vendas do tipo SAT (verifica se o campo L1_SERSAT NAO estแ preechido)
			cCondSAT := "% AND SL1.L1_SERSAT = '"+Space(TamSX3("L1_SERSAT")[1])+"' %"
		
			//obtem o Alias do Result Set
			cResultSet := GetNextAlias()
		
			/*	Executa a query		*/
			BEGINSQL Alias cResultSet
	
				column L1_EMISNF as DATE
	
				SELECT
				SL1.L1_FILIAL
				,SL1.L1_NUM
				FROM
				%table:SL1% SL1
				WHERE SL1.%notDel%
				AND SL1.L1_FILIAL = %xFilial:SL1%
				%exp:cCondSerie%
				AND SL1.L1_DOC BETWEEN %exp:MV_PAR02% AND %exp:MV_PAR03%
				AND SL1.L1_EMISNF BETWEEN %exp:MV_PAR04% AND %exp:MV_PAR05%
				AND SL1.L1_TPORC = 'E'
				%exp:cCondChave%
				//notas que estao no processo de cancelamento nao deverao ser retransmitidas				
				AND SL1.L1_SITUA NOT IN ('X0','X1','X2','X3')
				AND SL1.L1_STORC <> 'A'
				%exp:cCondSAT%
	
			ENDSQL

			//obtem a query executada para efeito de log
			cLastQuery := GetLastQuery()[2]
			LjGrvLog(Nil, "Query executada: ", cLastQuery)
		
			//posicionamos no inicio da tabela temporaria
			(cResultSet)->( DbGoTop() )
	
			//obtem os orcamentos que serao reprocessados
			While (cResultSet)->( !EoF() )
				Aadd( aNum, (cResultSet)->L1_NUM )
				(cResultSet)->( DbSkip() )
			EndDo
	
			//fecha a Result Set
			(cResultSet)->( DbCloseArea() )
	
			If Len(aNum) > 0
				Processa( {|| LjRetrNFCe(aNum, MV_PAR06, MV_PAR07) }, STR0030, STR0040, .T. )
			Else
				MsgAlert( STR0039, STR0030 )
			EndIf
		EndIf
	EndIf

Return Nil

//--------------------------------------------------
/*/{Protheus.doc} RmvChrEsp
Remove os caracteres invalidos da string para evitar erro de parser no XML
@param	 cString - String a ser validada
@author  Varejo
@version P11.8
@since   08/12/2015
@return	 cNewStr - String sem os caracteres especiais
/*/
//---------------------------------------------------
Function RmvChrEsp( cString )

	Local cChar		:= ""
	Local cNewStr	:= ""
	Local nSizeStr	:= 0
	Local nI		:= 0

	Default cString := ""

	If ExistFunc("LjRmvChEs")
		cNewString := LjRmvChEs(cString)
	Else
	//transforma em maiuscula e substitui caracteres com acentos
		cString := AllTrim( FwNoAccent(cString) )
	
	//tamanho da string
		nSizeStr := Len( cString )
	
		For nI := 1 to nSizeStr
			cChar := SubStr(cString, nI, 1)
			If cChar $ "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnoprqstuvwxyz0123456789=+-_/*?!,.:;()[]{}|\$<>' "
				cNewStr += cChar
			ElseIf cChar == Chr(13) .OR. cChar == CRLF
				cNewStr += "|"
			ElseIf SubStr(cString, nI-1, 1) == " "	//remove os espa็os a esquerda do caracter especial
				cNewStr := Rtrim(cNewStr)
			EndIf
		Next
	EndIf

Return cNewStr

//---------------------------------------------------
/*/{Protheus.doc} LjRetrNFCe
Remove os caracteres invalidos da string para 
evitar erro de parser no XML

@param1	 aNum 
@param2	 cOpcAmb
@param3	 cOpcMod
@author  Varejo
@version P11.8
@since   08/12/2015
@return	 Nil
/*/
//---------------------------------------------------
Function LjRetrNFCe(aNum, cOpcAmb, cOpcMod)

	Local cDocChv	:= ""	//chave da NFC-e
	Local cXML		:= ""	//XML da NFC-e
	Local cXMLProt	:= ""	//XML com o protocolo da NFC-e (retornado do SEFAZ)
	Local cErro		:= ""	//mensagem de erro da transmissao
	Local c_mod		:= ""	//tag mod (modelo do documento)
	Local c_tpEmis	:= ""	//tag tpEmis (modalidade)
	Local c_tpAmb	:= ""	//tag tpAmb (ambiente)
	Local c_cNF		:= ""	//Tag cNF
	Local lRetAux	:= .F.	//variavel de retorno auxiliar
	Local lXMLOk	:= .F.	//indica se conseguiu realizar o parser e obteve o Ambiente e Modalidade da nota original
	Local nRetorno	:= 0	//retorno enviado pelo TSS
	Local nI		:= 0
	Local nNumOrcs	:= 0 	//quantidade de or็amentos que serao processados
	Local nBarra	:= 0	//tamanho da barra de progresso
	Local oXML		:= TXMLManager():New()
	Local aGetMvTSS	:= {}
	Local cMvAmb	:= ""
	Local cMvMod	:= ""
	Local cTagCNF	:= ""  	//C๓digo num้rico que comp๕e a Chave de Acesso. N๚mero aleat๓rio gerado pelo emitente para cada NF-e para evitar acessos indevidos da NF-e. 

	Default aNum	:= {}
	Default cOpcAmb := "0"	//0-XML origem 1-Producao 2-Homologacao
	Default cOpcMod := "0"	//0-XML origem 1-Normal 9-Contingencia Offline da NFC-e

	//habilita o modo Retransmissao
	lRetrNFCe := .T.

	// quantidade de orcamentos que serao processados
	nNumOrcs := Len(aNum)

	/*	
	Se a quantidade for menor que 5, atribuimos 1 a barra de progresso,
	pois assim, a barra s๓ serแ incrementada no processamento do ultimo orcamento
	*/
	nBarra := nNumOrcs/5
	If nBarra < 1
		nBarra := 1
	EndIf

	/* para que sempre haja a progressao da barra, incrementamos 1 realizamos uma progressao */
	ProcRegua( (nBarra+1) )
	IncProc()

	DbSelectArea("SL1")
	SL1->( DbSetOrder(1) )	//L1_FILIAL + L1_NUM

	DbSelectArea("SF3")
	SF3->( DbSetOrder(1) )	//F3_FILIAL + F3_ENTRADA + F3_NFISCAL + F3_SERIE + F3_CLIEFOR + F3_LOJA

	For nI := 1 to nNumOrcs
	
		If nI%5 == 0 .OR. nI == nNumOrcs
			IncProc()	//incrementa a barra de progresso
		EndIf
	
		//posiciona no or็amento
		lRetAux := SL1->( DbSeek(xFilial("SL1") + aNum[nI]) )
	
		//obtem o arquivo XML da nota original
		lRetAux := LJNFCeGet(@cXML, @cXMLProt)
		If !lRetAux
			LjGrvLog( SL1->L1_NUM, "Erro ao obter o arquivo XML do servidor TSS" )
		Else
			If !Empty(cXMLProt)
				lRetAux := .F.
				LjGrvLog( SL1->L1_NUM, "A nota possui protocolo de autoriza็ใo, por isso nใo serแ retransmitida" )
			Else
				LjGrvLog( SL1->L1_NUM, "XML retornado do TSS", cXML )
			EndIf
		EndIf


		If lRetAux
		/*	OBTEMOS O XML DA NOTA FISCAL ORIGINAL	*/
			//executa o PARSE na string XML
			lXMLOk := oXML:Parse( cXML )
			If !lXMLOk
				LjGrvLog( SL1->L1_NUM, "ERRO AO EXECUTAR O METODO PARSE: ", oXML:LastError() )
			EndIf
		
			//registramos o NAMESPACE do arquivo XML
			If lXMLOk
				lXMLOk := oXML:XPathRegisterNS( "ns", "http://www.portalfiscal.inf.br/nfe" )
				If !lXMLOk
					LjGrvLog( SL1->L1_NUM, "ERRO AO REGISTRAR O NAMESPACE: ", oXML:LastError() )
				EndIf
			EndIf

			//obtemos o valor da tag mod (modelo do documento)
			If lXMLOk
				c_mod := oXML:XPathGetNodeValue( "/ns:NFe/ns:infNFe/ns:ide/ns:mod" )
				If Empty(c_mod) .OR. c_mod <> "65"
					lRetAux := .F.
					LjGrvLog(SL1->L1_NUM, "mod (modelo de documento) nao retornado ou invแlido: ", c_mod)
				EndIf
			EndIf
		
			//obtemos o valor da tag tpEmis (Modalidade) se o parser foi realizado com sucesso
			If lRetAux .AND. lXMLOk
				c_tpEmis := oXML:XPathGetNodeValue( "/ns:NFe/ns:infNFe/ns:ide/ns:tpEmis" )
				If Empty(c_tpEmis)
					lXMLOk := .F.
					LjGrvLog(SL1->L1_NUM, "tpEmis (modalidade) nใo retornado: ", c_tpEmis)
					//se a Modalidade for diferente de 1-Normal, entao ela deve ser 9-Contingencia Offline da NFC-e
				ElseIf !(c_tpEmis $ "1|9")
					LjGrvLog(SL1->L1_NUM, "tpEmis (modalidade) invแlido, portanto serแ substituido para 9: ", c_tpEmis)
					c_tpEmis := "9"
				EndIf
			EndIf
		
			//obtemos o valor da tag tpAmb (Ambiente) se o parser foi realizado com sucesso
			If lRetAux .AND. lXMLOk
				c_tpAmb := oXML:XPathGetNodeValue( "/ns:NFe/ns:infNFe/ns:ide/ns:tpAmb" )
				If Empty(c_tpAmb)
					lXMLOk := .F.
					LjGrvLog(SL1->L1_NUM, "tpAmb (ambiente) nใo retornado: ", c_tpAmb)
				EndIf
			EndIf

			//obtemos o valor da tag cNF se o parser foi realizado com sucesso
			If lRetAux .AND. lXMLOk
				c_cNF := oXML:XPathGetNodeValue( "/ns:NFe/ns:infNFe/ns:ide/ns:cNF" )
				If Empty(c_cNF)
					lXMLOk := .F.
					LjGrvLog(SL1->L1_NUM, "cNF nใo retornado: ", c_cNF)
				Else 
					cTagCNF := c_cNF
				EndIf
			EndIf
		EndIf
	
		If lRetAux
			/* Validacao do AMBIENTE */
			aGetMvTSS := LjGetMVTSS("MV_AMBNFCE")
			lRetAux	:= aGetMvTSS[1]
			If lRetAux
				cMvAmb := SubStr( aGetMvTSS[2], 1, 1 )
				If cOpcAmb == "0" .AND. c_tpAmb <> cMvAmb
					MsgStop( "O AMBIENTE da NFC-e: [" + c_tpAmb + "] difere do configurado no TSS [" + cMvAmb + "]" )
					LjGrvLog( SL1->L1_NUM, "O AMBIENTE da NFC-e: [" + c_tpAmb + "] difere do configurado no TSS [" + cMvAmb + "]" )
					lRetAux := .F.
	
				ElseIf cOpcAmb <> cMvAmb
					MsgStop( "O AMBIENTE selecionado: [" + cOpcAmb + "] difere do configurado no TSS [" + cMvAmb + "]")
					LjGrvLog(SL1->L1_NUM, "O AMBIENTE selecionado: " + cOpcAmb + ", difere do configurado no TSS: " + cMvAmb)
					lRetAux := .F.
				EndIf
			EndIf	
		EndIf
		
		If lRetAux
			//Ajusta a modalidade de acordo com o escolhido no pergunte
			If cOpcMod == "0" // Se escolheu 0, vai considerar o valor do XML da nota de origem
				cMvMod := c_tpEmis
			Else
				cMvMod := cOpcMod //Caso contrario pega a modalidade escolhida no pergunte
			EndIf 
			// verifica se a UF permite Conting๊ncia Offline
			If cMvMod == "9"
				lRetAux := LjNFCeMod9()
			EndIf
		EndIf
			
		If lRetAux
		/*	GERACAO DO NOVO XML DA NOTA FISCAL	*/
			cDocChv := LJChvNFCe(cMvMod,cTagCNF) 		// obtem a chave da NFC-e
			cXML 	:= LJNFCeXML(cDocChv,NIL,cMvMod,cTagCNF) // obtem o novo XML
		EndIf
		
		If lRetAux
			/* TRANSMISSAO DA NOVA NOTA FISCAL	*/
			nRetorno := LjNFCeEnvia( cXML, Nil, @cErro ) 		//retransmite o XML para o TSS
		
			If nRetorno == 1
				RecLock("SL1", .F.) // ATUALIZA O CAMPO L1_KEYNFCE
				Replace SL1->L1_KEYNFCE with cDocChv
				SL1->( MsUnlock() )
		
				// ATUALIZA O CAMPO F3_CHVNFE				
				If SF3->( DbSeek(xFilial("SF3") + DtoS(SL1->L1_EMISNF) + SL1->L1_DOC + SL1->L1_SERIE + SL1->L1_CLIENTE + SL1->L1_LOJA) )
					RecLock("SF3", .F.)
					Replace SF3->F3_CHVNFE with cDocChv
					SF3->( MsUnlock() )
				Else
					LjGrvLog( SL1->L1_NUM, "Documento/S้rie nใo localizado na tabela SF3: ", SL1->L1_DOC + "/" + SL1->L1_SERIE )
				EndIf
			Else
				LjGrvLog( SL1->L1_NUM, "Erro ao transmitir a NFC-e: ", cErro )
			EndIf

		EndIf
	
		// Reseta as variaveis estaticas
		LjNFCeClr(1)
		LjNFCeClr(2)

	Next

//fecha as tabelas
	SL1->( DbCloseArea() )
	SF3->( DbCloseArea() )

//destroi o objeto
	FreeObj(oXML)
	oXML := Nil

//desabilita o modo Retransmissao
	lRetrNFCe := .F.

Return Nil

//--------------------------------------------------------
/*{Protheus.doc} LjDfRetFrm
Carrega as formas de pagamento padrใo 

@author  Varejo
@version P11.8
@since   27/01/2016
@return	 
*/
//--------------------------------------------------------
Function LjDfRetFrm()
Local aFormas := {}

//Declaramos as Formas de Pagamento conforme NT2013.005 v1.03           
Aadd( aFormas, {"Dinheiro         ","01"} )
Aadd( aFormas, {"Cheque           ","02"} )
Aadd( aFormas, {"Cartao de Credito","03"} )
Aadd( aFormas, {"Cartao de Debito ","04"} )
Aadd( aFormas, {"Credito Loja     ","05"} )
Aadd( aFormas, {"Vale Alimentacao ","10"} )
Aadd( aFormas, {"Vale Refeicao    ","11"} )
Aadd( aFormas, {"Vale Presente    ","12"} )
Aadd( aFormas, {"Vale Combustivel ","13"} )
Aadd( aFormas, {"Boleto Bancario  ","15"} )
Aadd( aFormas, {"Sem Pagamento    ","90"} )
Aadd( aFormas, {"Outros           ","99"} )
Aadd( aFormas, {"PIX              ","17"} )
Aadd( aFormas, {"Pagto Digital    ","18"} )

Return aFormas

//------------------------
/*/{Protheus.doc} LjNFCeREmi
Chamada da rotina estแtica LjNFCeEmi
@author  Varejo
@version P11
@since   15/09/2015
@return  lRet	 - indica se houve sucesso na obten็ใo dos parโmetros
/*/
//------------------------

Function LjNFCeREmi()

Return LjNFCeEmi()


//----------------------------------------------------------------
/*/{Protheus.doc} LjDDanfeNFCe
Fun็ใo responsavel em imprimir o DANFE da NFCe nใo transmitida por TSS
@param	 cXml -  XML
@param	 cXmlProt -  Protocolo XML
@author  Varejo
@version P11.8
@since   15/02/2016
@return	 lRet - Sucesso/Erro
/*/
//----------------------------------------------------------------
Static Function LjDDanfeNFCe(cXml, cXmlProt)
	Default cXml := ""
	Default cXmlProt := ""
Return .T.

//----------------------------------------------------------------
/*/{Protheus.doc} LjDNFCeCanc
Fun็ใo responsavel em cancelar a NFCe nใo transmitida por TSS
@param	 cDoc -  XML
@param	 cNumSale -  Numero do Or็amento
@param	 lNFCeTSS -  Transmissใo Por TSS
@param	 cTipoCanc -  Tipo de Cancelamento
@param	 lInutiliza -  Inutiliza็ใo
@author  Varejo
@version P11.8
@since   15/02/2016
@return	 lRet - Sucesso/Erro
/*/
//----------------------------------------------------------------
Function LjDNFCeCanc(	cDoc		, cNumSale	, lNFCeTSS, cTipoCanc,;
 						lInutiliza	, cSerie	)
	Local nRet 		:= -1 //Retorno da rotina de cancelamento
	Local aArea 		:= GetArea()//WorkArea Atual
	Local cPDV 		:= "" //PDV
	Local cNFCeChv 	:= ""//Chave NFCe
	Local cNFCeProt 	:= "" //Protocolo da NFCe
	Local cNFCeJust 	:= "" //Justificativa da NFCe
	Local lRet 		:= .F. //Retorno
	Local lAberto 	:= .T. //NFCe Aberto
	Local lOnLine 	:= .T. //cancelamento on-line
	local nRet2 		:= 0 //Retorno2
	Local lEmitida	 := .f. //NFCe transmitida

	Default cDoc := ""
	Default cNumSale := ""
	Default lNFCeTSS := .F.
	Default cTipoCanc := ""
	Default lInutiliza := .F.
	Default	cSerie	:= IIf(STFIsPOS(),STFGetStat("SERIE"),LjGetStation("SERIE"))

	LjGrvLog( "DOC: "+cDoc+'/'+cSerie, "Numero " + cNumSale + " TipoCanc " + cTipoCanc  )  //Gera LOG

	cTipoCanc := ""

	If !Empty(cNumSale)
		SL1->(DbSetOrder(1)) //L1_FILIAL + L1_NUM
		If SL1->(Dbseek(xFilial("SL1") + cNumSale))
			cSerie := SL1->L1_SERIE
			cDoc := SL1->L1_DOC
		EndIf
	Else
		cPDV := STFGetStat("PDV")
		SL1->(DbSetorder(2)) //L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV
		SL1->(Dbseek(xFilial("SL1")  + Padr( cSerie, SL1->(TamSx3("L1_SERIE")[1]))+  Padr( cDoc, SL1->(TamSx3("L1_DOC")[1])) + Padr( cPDV, SL1->(TamSx3("L1_PDV")[1]))))
		cNumSale := SL1->L1_NUM
	EndIf

	If SL1->(Found())
		lOnLine := Left(SL1->L1_SITUA, 2) <> "D1"
		lEmitida := Left(SL1->L1_SITUA, 2) == "TX" .or. Left(SL1->L1_SITUA, 2) == "D8"
		cNFCeChv :=  SL1->L1_KEYNFCE
		If SL1->(ColumnPos("L1_PRONFCE")) > 0
			cNFCeProt := SL1->L1_PRONFCE
		EndIf


		If lInutiliza
			If Empty(cDoc)
				cDoc := SL1->L1_DOC
			EndIf
			If Empty(cSerie)
				cSerie := SL1->L1_SERIE
			EndIf
		
			If lEmitida
				nRet := -1
				STFMessage("LjDNFCeCanc", "STOP", STR0045) //"Or็amento transmitido para retaguarda, nใo ้ possํvel inutilizar"
				STFShowmessage( "LjDNFCeCanc")
				Return (nRet == 0)
			ElseIf Empty(cDoc) .OR. Empty(cSerie)
				nRet := -1
				STFMessage("LjDNFCeCanc", "STOP", STR0046) //"Or็amento sem numero e serie de NFCe. Inutiliza็ใo nใo realizada"
				STFShowmessage( "LjDNFCeCanc")
				Return (nRet == 0)
			EndIf
			cNFCeJust := STR0047 //"Inutilizacao por Rejeicao da NFCe"
		EndIf

		If nRet <> 0
		//Atualiza o status como cancelamento off-line (reenviar)
			If !lInutiliza
				If lOnLine
				
					If lEmitida
						cTipoCanc := "D8" //Reenviar cancelamento (nota enviada)
					Else
						cTipoCanc := "D9" //Reenviar cancelamento (nota NรO enviada)
					EndIf
					Reclock("SL1", .F.)
					SL1->L1_SITUA := cTipoCanc //Reenviar cancelamento (nota emitida)
					SL1->(MsUnLock())
					nRet := 0
				EndIf
			Else
	
				cTipoCanc := "I8" //Reenviar inutiliza็ใo (nota emitida)
				Reclock("SL1", .F.)
				SL1->L1_SITUA := cTipoCanc //Reenviar cancelamento (nota emitida)
				SL1->(MsUnLock())
				nRet := 0
				lInutiliza := .F.
			EndIf
		ElseIf nRet = 0
	
			If !lInutiliza
				If !lOnLine
					If lEmitida
						cTipoCanc := "D7"//Cancelamento offLine (confirmar cancelanento)
					Else
						cTipoCanc := "D7"//Cancelamento offLine (confirmar cancelanento)
					EndIf
				Else
					If lEmitida
						cTipoCanc := "DX" //Cancelamento online (confirmar cancelanento)
					Else
						cTipoCanc := "DC" //Reenviar cancelamento (confirmar cancelanento nota nใo enviada)
					EndIf
				EndIf
	
	
				Reclock("SL1", .F.)
				SL1->L1_SITUA := cTipoCanc //Cancelamento offLine (confirmar cancelanento)
				SL1->(MsUnLock())
			EndIf
		EndIf
		If nRet <> 0
//Torna a verificar o status da NFce
//Caso esteja em aberto, envia o cancelamento, e solicita o numero de serie e doc
			lAberto := STWPrinterStatus('5')  == 7
			cNumSale := ""
		Else
			lAberto := .F.
		EndIf
	Else
		lAberto := STWPrinterStatus('5')  == 7
		cNumSale := ""
	EndIf

	If lAberto
//Nใo localizado o or็amento
//Cancela o ultimo em aberto e deleta a venda
//Nota esta em aberto nใo ้ possํvel inutilizar
		If lInutiliza
			lInutiliza := .F.
		EndIf
		cDoc := space(SL1->(Tamsx3("L1_DOC")[1]))
		cSerie := space(SL1->(Tamsx3("L1_SERIE")[1]))
	//Cancelamento realizado
	
		If nRet == -14 .AND. lOnLine
		//Atualiza o status como cancelamento off-line (reenviar)
			nRet2 := nRet
			nRet := 0
			nRet := 0
	
		EndIf
	
		If nRet == 0 .AND. !Empty(cDoc) .AND. !Empty(cSerie)
			cPDV := STFGetStat("PDV")
			SL1->(DbSetorder(2)) //L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV
			If SL1->(Dbseek(xFilial("SL1") + Padr( cDoc, SL1->(TamSx3("L1_DOC")[1])) + cSerie + cPDV))
				cNumSale := SL1->L1_NUM
			EndIf
	
	
			If nRet2 = -14 //OnLine
				If lEmitida
					cTipoCanc := "D8" ////Reenviar cancelamento (nota emitida
				Else
					cTipoCanc := "D9" ////Reenviar cancelamento (nota nใo enviada e emitida)
				EndIf
			Else //nRet = 0
				If !lOnLine
					If lEmitida
						cTipoCanc := "D7"//Cancelamento offLine (confirmar cancelanento)
					Else
						cTipoCanc := "D7"//Cancelamento offLine (confirmar cancelanento)
					EndIf
				Else
					If lEmitida
						cTipoCanc := "DX" //Cancelamento online (confirmar cancelanento)
					Else
						cTipoCanc := "DC" //Reenviar cancelamento (confirmar cancelanento nota nใo enviada)
					EndIf
				EndIf
			EndIf
		
			If SL1->(Found())
				Reclock("SL1", .F.)
				SL1->L1_SITUA := cTipoCanc //Cancelamento offLine (confirmar cancelanento)
				SL1->(MsUnLock())
				LjGrvLog( "DOC: "+cDoc, "Cancela o Cupom na Impressora gravando o status" )  //Gera LOG
			Else
				LjGrvLog( "DOC: "+cDoc, "Cancela o Cupom na Impressora sem gravar o status" )  //Gera LOG
			EndIf
	

		Else
			cNumSale := ""
		EndIf
		
	EndIf

	RestArea(aArea)


	lRet := (nRet == 0)
Return lRet

//----------------------------------------------------------------
/*/{Protheus.doc} LjNFXInfo
Fun็ใo responsavel em retornar informa็๕es do XML
@param	 uData -  Dado
@param	 nInfo -  Codigo da Informa็ใo
@author  Varejo
@version P11.8
@since   15/02/2016
@return	 uRet - Valor da Informa็ใo
/*/
//----------------------------------------------------------------
Function LjNFXInfo(uData, nInfo)
	Local oValue := NIL //Valor

	Local aInfo := { "_NFE:_INFNFE:_IDE:_NNF"					, "_NFE:_INFNFE:_IDE:_SERIE"				, "_NFE:_INFNFE:_DEST:_CPF"					, "_NFE:_INFNFE:_DEST:_XNOME", ;
		"_NFE:_INFNFE:_DEST:_ENDERDEST:_XLGR"	, "_NFE:_INFNFE:_DEST:_ENDERDEST:_NRO"	, "_NFE:_INFNFE:_DEST:_ENDERDEST:_XBAIRRO"	,"_NFE:_INFNFE:_DEST:_ENDERDEST:_CMUN",;
		"_NFE:_INFNFE:_DEST:_ENDERDEST:_XMUN"		, "_NFE:_INFNFE:_DEST:_ENDERDEST:_UF"		, "_NFE:_INFNFE:_DEST:_ENDERDEST:_CEP"		, "_NFE:_INFNFE:_DEST:_CNPJ"					,;
		"_NFE:_INFNFE:_infAdic:_InfCpl"			, "_NFE:_INFNFE:_infAdic:_infAdFisco", "uData:_TPAG", "uData:_VPAG"}
	Local uRet := "" //Retorno
	
	Default uData := NIL
	Default nInfo := 0

	If nInfo > 0 .and. nInfo <= Len(aInfo)

	
		If Left(aInfo[nInfo], Len("uData")) == "uData" .AND. ValType(uData) == "O"
			oValue := XmlChildEx ( uData, Substr(aInfo[nInfo], Len("uData")+2) )
			If ValType(oValue) == "O"
				uRet := LjNFTrtS(oValue:TEXT)
				oValue := FreeObj(oValue)
			EndIf
	
		Else
			If Type("oXML:"+aInfo[nInfo]) <> "U"
				uRet := LjNFTrtS( &("oXML:"+aInfo[nInfo]+":TEXT"))
			EndIf
		EndIf
	EndIf

Return uRet
//----------------------------------------------------------------
/*/{Protheus.doc} LjNFXObj
Fun็ใo responsavel em retornar informa็๕es do XML em objeto
@param	 nTipo -  Tipo da Informa็ใo
@author  Varejo
@version P11.8
@since   15/02/2016
@return	 aRet - Valor da Informa็ใo
/*/
//----------------------------------------------------------------
Function LjNFXObj(nTipo)
	Local oRet := NIL //Objeto de retorno
	Local aRet := {} //Array de Retorno

	Default nTipo := 0

	Do Case
	Case nTipo == 1 //Itens
		oRet := XmlChildEx ( oXML:_NFE:_INFNFE, "_DET")
	Case nTipo == 2 //XML pagamento
		oRet := XmlChildEx ( oXML:_NFE:_INFNFE, "_PAG")
	EndCase

	If ValType(oRet) <> "A"
		aAdd(aRet, oRet)
	Else
		aRet := aClone(oRet)
	EndIf
Return aRet

//----------------------------------------------------------------
/*/{Protheus.doc} LjNFTrtS
Fun็ใo responsavel em retirar caracteres especiais nใo lido para Lib NFCE
@param	 cTexto -  Texto
@param	lValAll -  Valida Tudo
@author  Varejo
@version P11.8
@since   15/02/2016
@return	 cTexto - Texto convertido
/*/
//----------------------------------------------------------------
Static Function LjNFTrtS(cText,lValAll)
	Local aChar := {{"&", " "}, { '"', ""}, {"'", " "}, {"/", " "}, {"<", " "}, { ">", " "}} //array de String
	Local nC := 0 //Contador
	Local nTam  := Len(aChar) //Tamanho
	

	Default cText := ""
	Default lValAll := .T.
	
	If !lValAll
		aChar := {{"<", " "}, { ">", " "}} //array de String
		nTam  := Len(aChar) //Tamanho		
	EndIf
	
	If Len(cText) > 0 .AND. aScan(aChar, { |c| At(c[1],cText) > 0}) > 0
		For nC := 1 to nTam
			cText := StrTran(cText, aChar[nC, 01], aChar[nC, 02])
		Next nC
	EndIf

Return cText

//----------------------------------------------------------------
/*/{Protheus.doc} LJFatorFis
Fun็ใo responsavel em retornar o fator fiscal da venda.
Essa fun็ใo ้ praticamente uma c๓pia da LJ7FATRES. Sua cria็ใo
foi necessแria, jแ que o TOTVS PDV nใo possui o LOJA701C.
@param	 nVlrNaoFis - valor correspondente a parte Nao-Fiscal
@param	 nVlrTotal - valor correspondente ao total da venda
@return	 nFatorFis - fator correspondente a parte Fiscal da venda
@author  Varejo
@version P11.8
@since   24/03/2016
/*/
//------------------------------------------------------------------
Static Function LJFatorFis(nVlrNaoFis, nVlrTotal)

Local nFatorFis		:= 0	//fator Fiscal(retorno da funcao)
Local nFatorNFis	:= 0	//fator Nao-Fiscal

Default nVlrNaoFis	:= 0	//valor Nao-Fiscal
Default nVlrTotal	:= 0	//valor Total (Fiscal + Nao-Fiscal)

nFatorNFis := nVlrNaoFis / nVlrTotal
nFatorFis := 1 - nFatorNFis

Return nFatorFis

//----------------------------------------------------------------
/*/{Protheus.doc} LjTSSIDENT
Retorna o Codigo da Entidade.
@param	 cModelo 	Modelo do Documento Fiscal
@return	 cIDENT		Codigo da Entidade que sera retornado
@author  Varejo
@version P11.8
@since   19/04/2016
/*/
//------------------------------------------------------------------
Function LjTSSIDENT(cModelo, lAviso, lLJ783)

Local cIDENT		:= ""							// Codigo da Entidade que sera retornado
Local cURL   		:= ""							// URL de conexใo com o TSS
Local cErro			:= ""							// mensagem de erro do WS
Local nPos			:= 0
Local lRetWS		:= .T.							// verifica se o metodo do WS foi executado com sucesso
Local lTentar		:= .T.
Local lUsaGesEmp	:= IIF( ExistFunc("FWFilialName") .AND. ExistFunc("FWSizeFilial") .AND. FWSizeFilial() > 2, .T., .F. )
Local lEnvCodEmp	:= GetNewPar("MV_ENVCDGE",.F.)
Local aEndereco		:= {}							// array com Logradouro[C], Numero[N], Numero[C] e Complemento[C]
Local aTelefone 	:= {}							// array com DDI[N], DDD[N] e Telefone[N]
Local cFax			:= ""
Local cNomeFant		:= ""
Local oWS											// Objeto WS

Default cModelo		:= "65"							// NFC-e
Default lAviso		:= .T.
Default lLJ783		:= .F.  						// Verifica se a chamada foi feita pelo SIGALOJA	

LjGrvLog ("", "Modelo do Documento"		, cModelo)
LjGrvLog ("", "Grupo Empresa SM0"		, SM0->M0_CODIGO)
LjGrvLog( "", "Filial SM0"				, SM0->M0_CODFIL)
LjGrvLog( "", "Grupo Empresa cEmpAnt"	, cEmpAnt)
LjGrvLog( "", "Filial cFilAnt"			, cFilAnt)

If SM0->M0_CODFIL <> CFILANT
	LjGrvLog( "LOJNFCE", "SM0 NรO posicionada conforme CFILANT", SM0->M0_CODFIL )

	If !SM0->( DbSeek(CEMPANT + CFILANT) )		
		LjGrvLog( "LOJNFCE", "NรO foi possํvel posicionar SM0 conforme CFILANT", CFILANT)
	EndIf
EndIf

// Verificamos se o IDENT jแ foi obtido
If lLJ783  
	aIDEnt := {}
Else
	nPos := Ascan( aIDEnt, {|x| x[1] == cModelo} )
EndIf

// Se nใo achou o modelo de documento no array, precisamos obter sua entidade no TSS
If nPos == 0

	// Tratamento dos parametros do metodo do WS
	If ExistFunc("LjFiGetEnd")
		aEndereco := LjFiGetEnd(SM0->M0_ENDENT, Nil, .T.)	//LOJXFUNB.PRW
		aTelefone := LjFiGetTel(SM0->M0_TEL)
		cFax	  := LjFiGetTel(SM0->M0_FAX)[3]
	Else
		aEndereco := FisGetEnd(SM0->M0_ENDENT) 				//MATA950.PRW
		aTelefone := FisGetTel(SM0->M0_TEL)
		cFax	  := FisGetTel(SM0->M0_FAX)[3]
	EndIf

	If cModelo == "65"
		cURL := SuperGetMV("MV_NFCEURL",,"")
		cNomeFant := Alltrim(SM0->M0_NOME)
	Else
		cURL := SuperGetMV("MV_SPEDURL",,"")
	//Futuramente, verificar o impacto de passar essa mesma valida็ใo para NFC-e
		If lUsaGesEmp
			cNomeFant := FWFilialName()
		Else
			cNomeFant := Alltrim(SM0->M0_NOME)
		EndIf
	EndIf

	//Instancia o Web Services
	oWS := WsSPEDAdm():New()

	oWS:_URL 					:= AllTrim(cURL)+"/SPEDADM.apw"
	oWS:cUSERTOKEN				:= "TOTVS"

	oWS:oWSEMPRESA:cCNPJ        := IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cCPF         := IIF(SM0->M0_TPINSC==3,SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cIE          := SM0->M0_INSC
	oWS:oWSEMPRESA:cIM          := SM0->M0_INSCM
	oWS:oWSEMPRESA:cNOME        := SM0->M0_NOMECOM
	oWS:oWSEMPRESA:cFANTASIA    := cNomeFant
	oWS:oWSEMPRESA:cENDERECO    := aEndereco[1]
	oWS:oWSEMPRESA:cNUM         := aEndereco[3]
	oWS:oWSEMPRESA:cCOMPL       := aEndereco[4]
	oWS:oWSEMPRESA:cUF          := SM0->M0_ESTENT
	oWS:oWSEMPRESA:cCEP         := SM0->M0_CEPENT
	oWS:oWSEMPRESA:cCOD_MUN     := SM0->M0_CODMUN
	oWS:oWSEMPRESA:cCOD_PAIS    := "1058"
	oWS:oWSEMPRESA:cBAIRRO      := SM0->M0_BAIRENT
	oWS:oWSEMPRESA:cMUN         := SM0->M0_CIDENT
	oWS:oWSEMPRESA:cCEP_CP      := Nil
	oWS:oWSEMPRESA:cCP          := Nil
	oWS:oWSEMPRESA:cDDD         := Str(aTelefone[2],3)
	oWS:oWSEMPRESA:cFONE        := AllTrim( Str(aTelefone[3],15) )
	oWS:oWSEMPRESA:cFAX         := AllTrim( Str(cFax,15) )
	oWS:oWSEMPRESA:cEMAIL       := UsrRetMail(RetCodUsr())
	oWS:oWSEMPRESA:cNIRE        := SM0->M0_NIRE
	oWS:oWSEMPRESA:dDTRE        := SM0->M0_DTRE
	oWS:oWSEMPRESA:cNIT         := IIF(SM0->M0_TPINSC==1,SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cINDSITESP   := ""
	oWS:oWSEMPRESA:cID_MATRIZ   := ""
	
	//Exclusivo para NF-e
	If cModelo == "55" .AND. lUsaGesEmp .AND. lEnvCodEmp
		oWS:oWSEMPRESA:CIDEMPRESA:= FwGrpCompany()+FwCodFil()
	EndIf
	oWS:oWSOUTRASINSCRICOES:oWSInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()

	LjGrvLog("","Objeto oWS",oWS)

	//Tratamento do retorno do Web Services
	While lTentar

		lRetWS := oWs:ADMEMPRESAS()

		LjGrvLog( "", "Retorno da execucao do metodo ADMEMPRESAS:", lRetWS)

		//Tratamento do retorno do WS
		If ValType(lRetWS) == "U"
			lRetWS := .F.
		EndIf

		If lRetWS
			Aadd( aIDEnt, {cModelo, oWS:cADMEMPRESASRESULT} )
			lTentar := .F.	//para sair do While
		Else
			//Tratamento para obter o SOAP Fault do Web Services
			If Empty( GetWscError(3) )
				cErro := GetWscError(1)
			Else
				cErro := GetWscError(3)
			EndIf
		
			//Se houver interface de usuario, pergunta ao usuario se ele quer tentar novamente
			If !IsBlind()
				If lAviso
					//"NFC-e: Nใo foi possํvel transmitir NFC-e (Capturar C๓digo Entidade)" ## //"SIM" ## //NรO ## //"Deseja tentar novamente?"
					If Aviso("Nao foi possํvel obter o c๓digo da Entidade", cErro, {STR0017,STR0018}, 3, STR0016) == 2
						lTentar := .F.	//usuแrio escolheu nใo tentar novamente
					EndIf
				EndIf
			Else
				lTentar := .F.
				conout( "Nao foi possivel obter o c๓digo da Entidade", cErro)	//"NFC-e: Nใo foi possํvel transmitir NFC-e (Capturar C๓digo Entidade)"
				Help( ,, "NFCETSS",, "Nao foi possivel obter o c๓digo da Entidade" + cErro, 1, 0 )
			EndIf
			LjGrvLog( "", "Nao foi possivel obter o c๓digo da Entidade", cErro)
		EndIf
	EndDo

EndIf

// Obtemos o codigo da entidade (SPED001.IDENT) de acordo com o modelo de documento (55 NF-e ou 65 NFC-e)
If lRetWS
	// Se acabou de obter o IDENT, procuramos sua posi็ใo no array estatico
	If nPos == 0
		nPos := Ascan( aIDEnt, {|x| x[1] == cModelo} )
		LjGrvLog("","aIDEnt (Entidades Carregadas)", aIDEnt)
	EndIf

	If nPos > 0
		cIDENT := aIDEnt[nPos][2]
	EndIf
EndIf

LjGrvLog("","Entidade Retornada", cIDENT)
	
Return cIDENT

//----------------------------------------------------------------
/*/{Protheus.doc} LjEnviaNFe
Realiza a transmissao NF-e de saida.
@param	 cSerie 	Serie da nota
@param	 cNota	 	Numeo da nota
@return	 aRet
@author  Varejo
@version P11.8
@since   19/04/2016
/*/
//------------------------------------------------------------------
Function LjEnviaNFe(cSerie, cNota, cCliente, cLoja)
Local cRetorno		:= ""	//mensagem de retorno
Local cIDEnt		:= ""
Local cAmbiente		:= ""
Local cModalidade	:= ""
Local cVersao		:= ""
Local lRetorno		:= .F.
Local lEnd			:= .F.
Local aRet 			:= {} 	//Retorno da funcao
Local aArea			:= GetArea()
Local aSF2Area		:= SF2->( GetArea() )
Local cQuery		:= "" //-- Remover esse trecho depois que a TEC corrigir o problema data gravado com 0

Default cSerie		:= ""
Default cNota		:= ""
Default cCliente	:= ""
Default cLoja		:= ""

Private bFiltraBrw	:= {||}	//usado por compatibilidade por causa do fonte SPEDNFE.PRX

MV_PAR01 := cSerie
MV_PAR02 := cNota
MV_PAR03 := cNota

//---------------------------
// Obtem o codigo da entidade
//---------------------------
cIDEnt := LjTSSIDEnt("55")
If !Empty(cIDEnt)

	//------------------------------------
	// Obtem os parametros do servidor TSS
	//------------------------------------		
	//carregamos o array estatico com os parametros do TSS
	If LjCfgTSS("55")[1]
		cAmbiente	:= LjCfgTSS("55", "AMB")[2]
		cModalidade := LjCfgTSS("55", "MOD")[2]
		cVersao		:= LjCfgTSS("55", "VER")[2]

		//------------------------------
		// Realiza a transmissใo da NF-e
		//------------------------------
		conout( "[IDENT: " + cIDEnt+"] - Iniciando transmissao NF-e de saida! - " + Time() )
		
		//Remover esse trecho depois que a TEC corrigir o problema
		//-- Temporariamente ate resolver com o framework os campos datas serem gravados quando em branco com 0 
		if RealRdd() == "SQLITE"
			cQuery := "UPDATE "+ RetSqlName( "SF3" )
			cQuery += " SET F3_DTCANC = '" + space(8) + "' "
			cQuery += " WHERE F3_DTCANC = '00000000' "
			TCSQLExec(cQuery)
		
			cQuery := "UPDATE "+ RetSqlName( "SFT" )
			cQuery += " SET FT_DTCANC = '" + space(8) + "' "
			cQuery += " WHERE FT_DTCANC = '00000000' "	
			TCSQLExec(cQuery)
		Endif

		cRetorno := SpedNFeTrf(	"SF2"	, cSerie	, cNota			, cNota		,;
								cIDEnt	, cAmbiente	, cModalidade	, cVersao	,;
								@lEnd	, .F.		, .F.						)

		lRetorno := .T.

		conout( "[IDENT: " + cIDEnt+"] - Transmissao da NF-e de saida finalizada! - " + Time() )
		/*
		3 ULTIMOS PARAMETROS:
			lEnd - parametro nใo utilizado no SPEDNFeTrf
			lCte
			lAuto
		*/
	Else
		cRetorno += "Nใo foi possํvel obter o valor dos parโmetros do TSS." + CRLF
		cRetorno += "Por favor, realize a transmissใo atrav้s do M๓dulo FATURAMENTO." + CRLF
	EndIf
Else
	cRetorno += "Nใo foi possํvel obter o C๓digo da Entidade (IDENT) do servidor TSS." + CRLF
	cRetorno += "Por favor, realize a transmissใo atrav้s do M๓dulo FATURAMENTO." + CRLF
EndIf



//destroi o array para melhor gerenciamento de memoria
aSize(aIDEnt	, 0)
aSize(aMVTSS2	, 0)

//restaura as areas
RestArea(aSF2Area)
RestArea(aArea)

aRet := {lRetorno,cRetorno}

Return aRet

//----------------------------------------------------------------
/*/{Protheus.doc} LjCfgTSS
@param	 cModelo 	Modelo do Documento Fiscal
@param	 cParametro
@return	 aRet
@author  Varejo
@version P11.8
@since   19/04/2016
/*/
//------------------------------------------------------------------
Static Function LjCfgTSS( cModelo, cParametro )

	Local cURL		:= ""			//URL do servidor TSS
	Local nI		:= 0			//contador
	Local lRetWS	:= .T.			//indica se o m้todo do WS foi executado com sucesso
	Local oWs		:= Nil			//objeto do WS
	Local cErro		:= ""
	Local nPos		:= 0
	Local nPosAux	:= 0
	Local nOpcao	:= 0
	Local aAuxMVTSS := {}
	Local aRet		:= {}
	Local cIDEnt	:= ""

	Default cModelo		:= "65"		//NFC-e
	Default cParametro	:= ""

//
// verificamos se jแ hแ parametros para o modelo de documento solicitado
//
	nPos := Ascan( aMVTSS2, {|x| x[1] == cModelo} )

// Se nใo achou o modelo de documento no array, precisamos obter esse parametros do TSS
	If nPos == 0

	// Parametros que serao recuperados da SPED000
		Aadd( aAuxMVTSS, {"AMB", Nil} )
		Aadd( aAuxMVTSS, {"MOD", Nil} )
		Aadd( aAuxMVTSS, {"VER", Nil} )

	//retorna o IDENT configurado no servidor TSS
		If cModelo == "65"
			cURL := SuperGetMV("MV_NFCEURL",,"")
		ElseIf cModelo == "55"
			cURL := SuperGetMV("MV_SPEDURL",,"")
		EndIf

	// Obtemos o IDENT da tabela SPED001 do TSS
		cIDEnt := LjTSSIDENT(cModelo)	//LjNFCeIDEnt()

		If !Empty(cIDEnt)
		//instancia o WS responsavel por retornar as configura็๕es do TSS
			oWS := WSSPEDCfgNFe():New()

			oWS:cUSERTOKEN	:= "TOTVS"
			oWS:cID_ENT		:= cIDEnt
			oWS:_URL		:= AllTrim(cURL)+"/SPEDCFGNFe.apw"
			oWS:cModelo		:= cModelo

			For nI := 1 to Len(aAuxMVTSS)

				Do Case
				// retorna o AMBIENTE
				Case aAuxMVTSS[nI][1] == "AMB"
					oWS:nAmbiente	:= 0
					lRetWS 			:= oWS:CFGAMBIENTE()
					aAuxMVTSS[nI][2]:= oWS:cCfgAmbienteResult

				//retorna a MODALIDADE
				Case aAuxMVTSS[nI][1] == "MOD"
					oWS:nModalidade	:= 0
					lRetWS 			:= oWS:CFGModalidade()
					aAuxMVTSS[nI][2]:= oWS:cCfgModalidadeResult

				// retorna a VERSรO
				Case aAuxMVTSS[nI][1] == "VER"
					oWS:cVersao		:= "0.00"
					lRetWS 			:= oWS:CFGVersao()
					aAuxMVTSS[nI][2]:= oWS:cCfgVersaoResult
				EndCase
			
			//
			//tratamento para caso de erro de execucao do WS
			//
				If ValType(lRetWS) == "U" .OR. !lRetWS
					lRetWS := .F.
	
					If !Empty( GetWscError(3) )
						cErro := GetWscError(3)	//SOAP Fault Description
					Else
						cErro := GetWscError(1)	//Resumo do Erro
					EndIf
				
				// se hแ interface de usuario, pode-se tentar novamente	
					If !IsBlind()
						nOpcao := Aviso("GetAllMVTSS - Erro ao executar o m้todo", cErro, {"Sim", "Nao"}, 3, "Tentar novamente?")
					Else
					// caso contrแrio, jแ atribuimos a resposta "Nใo" 					
						nOpcao := 2
					EndIf
	
					If nOpcao == 1
					//voltamos o contador, pois obteremos todos os parametros novamente
						nI := 0
					Else
					//sai do loop
						Exit
					EndIf
				EndIf

			Next
		
		//
		// se obteve os parametros com sucesso, alimentamos o array estatico aMVTSS2
		//
			If lRetWS
			//adiciona o modelo de documento (NF-e ou NFC-e) ao array estatico
				Aadd( aMVTSS2, {cModelo, {}} )
			
			//busca pelo modelo adicionado anteriormente (necessario, pois pode haver outro modelo no array)
				nPos := aScan( aMVTSS2, {|x| x[1] == cModelo} )
			
			//descarrega os parametros e seus respectivos valores
				For nI := 1 to Len(aAuxMVTSS)
					Aadd( aMVTSS2[nPos][2], {aAuxMVTSS[nI][1], aAuxMVTSS[nI][2]} )
				Next
			Else
			//resetamos o array estatico
				aSize(aMvTSS2, 0)
				LjGrvLog( Nil, "GetAllMVTSS - Erro ao executar o m้todo: ", cErro)
			EndIf

		Else
			lRetWS := .F.	//erro ao obter o c๓digo da Entidade
		EndIf

	EndIf

//
// Obtemos o valor do parametro solicitado(cParametro) de acordo com o modelo de documento (55 NF-e ou 65 NFC-e)
// * se nao for solicitado nenhum parametro, somente carrega o array estatico
//
	If lRetWS
	// se acabou de carregar os parametros, procuramos o modelo no array estatico
		If nPos == 0
			nPos := Ascan( aMVTSS2, {|x| x[1] == cModelo} )
		EndIf

	// procuramos o valor do parametro de acordo com o modelo de documento
		nPosAux := Ascan( aMVTSS2[nPos][2], {|x| x[1] == cParametro} )
		If nPosAux > 0
			aRet := { lRetWS, aMvTSS2[nPos][2][nPosAux][2] }
		Else
		//nao achou o parametro no array estatico
			aRet := { lRetWS, Nil }
		EndIf
	Else
	//nao foi possivel obter os parametros
		aRet := { lRetWS, Nil }
	EndIf

Return aRet

//----------------------------------------------------------------
/*/{Protheus.doc} LjNFCePrtC
Impressao do comprovante de solicitacao de cancelamento da NFC-e.
Imprime um simples comprovante de Solicitacao de Cancelamento da NFC-e.
@param	 cPDV 		Numero do PDV
@param	 cDOC		Numero do Documento
@param	 cSerie		Numero de Serie do Documento
@param	 dData		Data da solicitacao do Cancelamento
@param	 cHora		Hora da solicitacao do Cancelamento
@return	 nRet		nRet = 0 (Sucesso na impressao);  nRet <> 0 (erro na impressao)
@author  Varejo
@version P11.8
@since   24/05/2016
/*/
//------------------------------------------------------------------
Function LjNFCePrtC(cPDV, cDoc, cSerie, dData, cHora)
Local nRet 			:= 0
Local nSaltoLn		:= SuperGetMV("MV_FTTEFLI",, 1)		// Linha pula entre comprovante
Local lGuil			:= SuperGetMV("MV_FTTEFGU",, .T.)	// Ativa guilhotina
Local lCondensa		:= SuperGetMV("MV_LJCONDE",,.F.)
Local cCrLf			:= Chr(10)
Local cTagCondIni	:= Iif(lCondensa, TAG_CONDEN_INI , "")
Local cTagCondFim	:= IIf(lCondensa, TAG_CONDEN_FIM , "")
Local cTracejado 	:= IIf(lCondensa, "--------------------------------------------------------", "-------------------------------")
Local cLinha		:= TAG_CENTER_INI + cTagCondIni + cTracejado + cTagCondFim + TAG_CENTER_FIM + cCrLf
Local cTexto 		:= ""
Local nX 			:= 0
Local lPOS 			:= ExistFunc("STFIsPOS") .AND. STFIsPOS() //Pos?
Local lClasImpNfce	:= ExistFunc("LNfceTemCo")
Local oLojINfce		:= NIL

Default dData 	:= DToC(dDatabase)
Default cHora	:= Time()

If lClasImpNfce
	oLojINfce:= LOJINFCE():New()
	nRet	 := oLojINfce:ImpCompCnc(@cPDV, @cDoc, @cSerie, @dData, @cHora)
Else

//-------------------------
// Dados da empresa
//-------------------------
	cTexto += cTagCondIni + AllTrim(SM0->M0_NOMECOM) + cCrLf 						//Denomina็ใo
	cTexto += AllTrim("CNPJ:" + SM0->M0_CGC + " / IE:" + SM0->M0_INSC) + cCrLf		//CNPJ //Inscri็ใo Estadual
	cTexto +=	AllTrim(SM0->M0_ENDENT) + ;											//Endereco
				AllTrim(SM0->M0_BAIRENT) + "," + ;
				AllTrim(SM0->M0_CIDENT) + ", " + ;
				AllTrim(SM0->M0_ESTENT) + cTagCondFim + cCrLf
	cTexto += cLinha

//-------------------------
// Cabecalho do Comprovante
//-------------------------
	cTexto += TAG_CENTER_INI + cTagCondIni + "NFC-e" + cTagCondFim + TAG_CENTER_FIM + cCrLf
	cTexto += TAG_CENTER_INI + cTagCondIni + "SOLICITACAO DE CANCELAMENTO" + cTagCondFim + TAG_CENTER_FIM + cCrLf
	cTexto += cLinha

//-------------------------
// Corpo do Comprovante
//-------------------------		
	cTexto += "PDV: " + PadR(cPDV,4) + "      Data: " + DToC(dData) + " Hora: " + cHora + cCrLf + cCrLf
	cTexto += "Enviada a solicita็ใo de cancelamento de NFC-e."+ cCrLf + cCrLf
	cTexto += "Numero: " + cDoc + " / Serie: " + cSerie + cCrLf + cCrLf
	cTexto += cLinha

//Salta linha extra
	For nX := 1 to nSaltoLn
		cTexto += cCrLf
	Next nX

	If lGuil
		cTexto += TAG_GUIL_INI+TAG_GUIL_FIM		//Corte de Papel
	EndIf

	If lPOS		
		nRet := STWPrintTextNotFiscal(cTexto)
	Else
		nRet := INFTexto(cTexto)  //Envia comando para a Impressora Nao-Fiscal
	Endif

	If nRet <> 0
		MsgStop("Ocorreu problema na impressใo do comprovante de Solicita็ใo de Cancelamento da NFC-e: " + cDoc + " / Serie: " + cSerie)
	EndIf
EndIf

Return nRet

//----------------------------------------------------------------
/*/{Protheus.doc} LjNFCeReImp
Realiza reimpressao NFCE/NF-e TOTVS PDV
@author  Varejo
@version P11.8
@param aInfCupom, array, array com dados do cupom nfc-e a ser reimpresso
@since   31/05/2016
/*/
//------------------------------------------------------------------
Function LjNFCeReImp(aInfCupom)
Local lPOS 			:= STFIsPOS() //Pos?
Local cLastFilial 	:= ""
Local cLastNum	 	:= ""
Local cLastSitua	:= ""
Local cXml	 		:= ""
Local cXmlProt	 	:= ""
Local lRet	 		:= .F.
Local cKeyNFCE		:= ""
Local aRetAux		:= {}
Local xMvLjTxNFe	:= SuperGetMV("MV_LJTXNFE",,0)
Local cMVLOJANF		:= AllTrim( SuperGetMV("MV_LOJANF", .F. ,"UNI") )
Local lMVFISNOTA	:= SuperGetMV("MV_FISNOTA", .F., .F.) .and. !Empty(cMVLOJANF) .and. cMVLOJANF <> "UNI"
Local lImpNFe		:= .F.

Default aInfCupom 	:=	{}

If lPOS
	
	cLastFilial 	:= Iif(Len(aInfCupom) == 4, aInfCupom[1], STDCSLastSale("L1_FILIAl"))
	cLastNum 		:= Iif(Len(aInfCupom) == 4, aInfCupom[2], STDCSLastSale("L1_NUM"))
	cLastSitua 		:= Iif(Len(aInfCupom) == 4, aInfCupom[3], STDCSLastSale("L1_SITUA"))
	cKeyNFCE 		:= Iif(Len(aInfCupom) == 4, aInfCupom[4], STDCSLastSale("L1_KEYNFCE"))

	If AllTrim(cLastSitua) $ "TX|00" .And. !Empty(cKeyNFCE)

		STFMessage(ProcName(), "ALERT", STR0154) //"Coletando dados, Aguarde..."
		STFShowMessage( ProcName() )

		DbSelectArea("SL1")
		SL1->( DbSetOrder(1) )     // L1_FILIAL + L1_NUM
	
		If 	SL1->( DbSeek(cLastFilial+cLastNum) )
			lRet := IIF( LjNFCeGet( @cXml, @cXmlProt ),.T.,.F. )
		EndIf
	
		If lRet
			
			lImpNFe := Substr(cKeyNFCE,21,2) == "55"
			
			If lImpNFe .and. lMVFISNOTA
				
				If xMvLjTxNFe == 2//-- Realiza Impressao quando autorizado em A4						
					LjDANFENFe( xMvLjTxNFe )
				Else
					//-- Se NFe e configurado para nao imprimir, ou seja foi enviado o XML e PDF no e-mail pelo TSS
					LjGrvLog(NIL,"Mv_LjTxNFe : Tem valor menor que 2 e nใo possue efeito")
				EndIf

			//Totvs PDV Emissao Danfinha
			else

					//Para nao realizar outra requisi็ใo ou gerar uma terceira funcao de retorno que atenda ao monitoramento da NF-e e impressao
					if ExistFunc("U_LjRDnfNfce")  //Tivemos problema devido ao IXBLOG, portanto chame como U_XXX
						aRetAux :=  U_LjRDnfNfce( cXml, cXmlProt, Nil, .T., aItensNFCe, lImpNFe )
						If Len(aRetAux) > 0
							If ValType(aRetAux[1]) <> "L"
								aRetAux[1] = .T.
							EndIf
							lRet := aRetAux[1]
						Else
							lRet := .F.
						EndIf
					else
						If ExistFunc("LjSCNfNFCe")
							aRetAux := LjSCNfNFCe( cXml, cXmlProt, Nil, .T., aItensNFCe, lImpNFe )	
							lRet := IIf (Len(aRetAux) > 0, IiF(ValType(aRetAux[1]) <> "L", .T., aRetAux[1]), .F.)
						Else 
							//Imprime a DANFE PADRAO (nao Fiscal)
							LjNFCeDANFE( cXml, cXmlProt, Nil, .T., lImpNFe )			
						Endif 
					endif

				endif

		EndIf

		STFMessage(ProcName(), "ALERT", iif( lRet, STR0155, STR0156) ) //#"Impressใo concluida do Danfe!" //#"Verifique a Impressora!"
		STFShowMessage( ProcName() )
	Else
		STFMessage(ProcName(), "STOP", STR0157) //"Nใo foi possํvel a reimpressใo - Documento Fiscal nใo finalizada ou com erro."
		STFShowMessage(ProcName())
		lRet := .F.
	EndIf

EndIf

Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} LjRetTBand
Retorna o c๓digo da bandeira usada na tag <tBand> no XML da
NFC-e para identificar a bandeira utilizada em uma venda TEF
@param	cBandeira - descri็ใo da bandeira	 
@return c_tBand - codigo da bandeira utilizada pelo SEFAZ
@author  Varejo
@version P11.8
@since   24/06/2016
/*/
//----------------------------------------------------------
Static Function LjRetTBand(cBandeira)

Local c_tBand		:= 	""	//codigo da bandeira utilizada pelo SEFAZ
Local cCodAdmFin 	:= 	""   
Local nTamAeCod 	:= 	TamSX3("AE_COD")[1]
Local lTabNt006 	:= SAE->(Columnpos("AE_CDBASF")) > 0 .AND. AliasInDic("MHW") 

Default cBandeira	:= 	""
		
cCodAdmFin := PadR(cBandeira, nTamAECOD)

DbSelectArea("SAE")
SAE->(DbSetOrder(1))//AE_FILIAL+AE_COD                                         

IF NT2020006P() .AND. lTabNt006 .AND.  SAE->(DbSeek(xFilial("SAE")+cCodAdmFin)) .AND. !Empty(SAE->AE_CDBASF)

	DbSelectArea("MHW")
	                                   
	MHW->(DbSetOrder(1))//MHW_FILIAL+MHW_CODIGO+MHW_CONTEU
	If MHW->(DbSeek(xFilial("MHW")+SAE->AE_CDBASF))
		c_tBand := MHW_CDNFCE
	EndIF

Else

	cBandeira := AllTrim(Upper(cBandeira))

	Do Case
	Case ( ("VISA" $ cBandeira) .OR. ("ELECTRON" $ cBandeira) )
		c_tBand := "01"
	Case ( ("MAESTRO" $ cBandeira) .OR. ("MASTERCARD" $ cBandeira) )
		c_tBand := "02"
	Case ( ("AMEX" $ cBandeira) .OR. ("EXPRESS" $ cBandeira) .Or. ("SOROCRED" $ cBandeira) )
		c_tBand := "03"
	Case ("DINERS CLUB" $ cBandeira)
		c_tBand := "05"	
	Case ("ELO" $ cBandeira)
		c_tBand := "06"	
	Case ("HIPERCARD" $ cBandeira)
		c_tBand := "07"	
	Case ("AURA" $ cBandeira)
		c_tBand := "08"		
	Case ("CABALAURA" $ cBandeira)
		c_tBand := "09"		
	Otherwise
		c_tBand := "99"
	EndCase
Endif 

Return c_tBand

//----------------------------------------------------------
/*/{Protheus.doc} LjAskImp
Pergunta se deseja tentar imprimir novamente caso ocorra algum erro durante a impressao.

@type function

@author  Varejo
@version P11.8
@since   24/06/2016

@param	nRetImp Retorno anterior da impresora	 
@return lRet - Retorna .T. se deve tentar imprimir novamente.
/*/
//----------------------------------------------------------
Function LjAskImp(nRetImp, lMsgAlert)
Local lRet 			:= .T.
Local lTenta 		:= .T.
Local nHdlECF		:= -1
Local cImpressora	:= LjGetStation("IMPFISC")
local cPorta		:= LjGetStation("PORTIF")
Local nContPerg		:= 1

Default lMsgAlert 	:= .T.

If nRetImp <> 0 .And. nRetImp <> 999
	
	If lMsgAlert
		MsgInfo(STR0048 + " " + STR0052; // "Ocorreu algum problema durante a impressใo. Serแ realizado 2 tentativas de comunica็ใo!"
		+ Chr(10)+Chr(13) + STR0053, STR0003) //"Verifique se a impressora esta LIGADA." ### "Aten็ใo"

		If INFTexto(".") <> 0 // Verifica se a impressora voltou a responder apos a msg acima 
			//Fecha a comunicacao com a impressora.
			INFFechar()
			
			While lTenta .And. nContPerg <= 3
			
				// Mesmo com parametro MV_NFCEIMP configurado para o Front ele nao foi implementado
				If nContPerg == 3
					MsgInfo(STR0055, STR0003) //"NFCE TRANSMITIDA COM SUCESSO!" ### Aten็ใo

					MsgInfo(STR0056+ Chr(10)+Chr(13) +; // "******************************************"
				 			 STR0057+ Chr(10)+Chr(13) +; // "ATENวรO: DESLIGUE E LIGUE A IMPRESSORA!"
				 	        STR0056) 						 // "******************************************"				
				EndIf
				
				//Abre a comunicacao com a impressora.
				LjMsgRun( STR0050,, { || nHdlECF := INFAbrir( cImpressora, cPorta ) } ) //"Aguarde. Comunicando com a Impressora Nใo Fiscal..."				
				
				If nHdlECF == -1
					If nContPerg <= 2
						MsgInfo(STR0051 + cImpressora; // "Nใo foi possํvel estabelecer comunica็ใo com a Impressora:"
						+ Chr(10)+Chr(13) + STR0054, STR0003) // "SERม REALIZADO NOVA TENTATIVA DE COMUNICAวรO." ### Aten็ใo
					EndIf
					lTenta := .T.
					lRet 	:= .F.
				Else
					lTenta := .F.
					lRet 	:= .T.
				EndIf
				
				// Atualiza contador
				nContPerg := nContPerg + 1
			End		
		EndIf		
	EndIf	
	/*Se ap๓s vแrias tentativas nใo for possํvel a impressใo do cupom (nfce)
	orientamos o operador a reiniciar o PDV. */ 
	If !lRet .And. nHdlECF == -1
		MsgInfo("******************************************"+ Chr(10)+Chr(13) +;
				 "REINICIE O PDV. APำS SERม NECESSมRIO"+ Chr(10)+Chr(13) +;
				 "UTILIZAR A ROTINA DE REIMPRIMIR NFC-E."+ Chr(10)+Chr(13) +;
				 "(F12+34) PARA REIMPRESSรO DO CUPOM." + Chr(10)+Chr(13) +; 
				 "******************************************", STR0003)
	EndIf	

EndIf
	
Return lRet


//----------------------------------------------------------
/*/{Protheus.doc} LjXMLC2O
Converte um XML no formato string para um objeto da classe TXMLManager

@type function

@author  Varejo
@version P11.8
@since   29/08/2016

@param	cXML XML no formato string que serแ convertido	 
@param	cAliasNS alias do NameSpace que serแ utilizado para extrair os n๓s e atributos do XML
@param	cNS NameSpace que sera utilizado para registro
@return aRet [1]indica se o Parser foi realizado com sucesso [2]objeto TXMLManager
/*/
//----------------------------------------------------------
Static Function LjXMLC2O(cXML, cAliasNS, cNS)

Local lRetAux		:= .F.
Local aRet			:= {}
Local oXMLAux		:= Nil

Default cXML		:= ""
Default cAliasNS	:= "xmlns"
Default cNS			:= "http://www.portalfiscal.inf.br/nfe"

If !Empty(cXML)
	//instancia um objeto da classe TXML Manager
	oXMLAux := TXMLManager():New()

	//executa o PARSE na string XML
	lRetAux := oXMLAux:Parse( cXML )

	//registramos o NAMESPACE do arquivo XML
	If lRetAux
		lRetAux := oXMLAux:XPathRegisterNS( cAliasNS, cNS )
		If !lRetAux
			LJGrvLog(Nil, "ERRO AO REGISTRAR O NAMESPACE", oXMLAux:Error() )
		EndIf
	Else
		If !Empty( oXMLAux:Error() )
			LJGrvLog(Nil, "ERRO AO EXECUTAR O METODO PARSE: ", oXMLAux:Error() )
		ElseIf !Empty( oXMLAux:Warning() )
			LJGrvLog(Nil, "ADVERTENCIA AO EXECUTAR O METODO PARSE: ", oXMLAux:Warning() )
		EndIf
	EndIf
EndIf

Aadd( aRet, lRetAux )
Aadd( aRet, oXMLAux )

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |LjRetNfce บAutor  ณVendas Cliente      บ Data ณ  24/08/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna um array com o XML das NFCe via conexao com TSS.	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ ExpA1 - Array com a relacao de NFC-e				 		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Venda Assistida                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LjRetNFCe(dDataDe, dDataAte, cSerieDe, cSerieAte, cDocDe, cDocAte, lLJ783)
Local cNfeIdDe		:= ""
Local cNfeIdAte		:= ""
Local lRet 			:= .F.
Local aRet			:= {}
Local cIdEnt		:= ""		//(Tabela:SPED001 do TSS)
Local cURL			:= ""
Local cWsError 		:= ""
Local nTamDoc 		:= TamSx3("L1_DOC")[1]
Local nTamSerie		:= TamSx3("L1_SERIE")[1]

Default cDocDe 		:= Replicate("0",nTamDoc)
Default cDocAte		:= Replicate("9",nTamDoc)
Default lLJ783		:= .F.  // Verifica se a chamada foi feita pelo SIGALOJA

PRIVATE	oWS		 	:= nil

cSerieDe 	:= PadR(cSerieDe , nTamSerie)
cSerieAte	:= PadR(cSerieAte, nTamSerie)
cDocDe 		:= PadR(cDocDe 	 , nTamDoc)
cDocAte		:= PadR(cDocAte	 , nTamDoc)
cNfeIdDe	:= cSerieDe+cDocDe
cNfeIdAte	:= cSerieAte+cDocAte

//Retorna a entidade correspondente a Empresa/Filial (SM0 Posicionada)
cIdEnt 		:= LjTSSIDENT("65", .F., lLJ783)

cURL   		:= PadR(GetNewPar("MV_NFCEURL","http://"),250)
	
If !Empty(cIDEnt)
	oWS						:= WSNFESBRA():new()
	oWS:_URL				:= AllTrim(cURL)+"/NFESBRA.apw"
	oWS:cUSERTOKEN			:= "TOTVS"
	oWS:cID_ENT				:= cIdEnt
	oWS:cIDINICIAL			:= cNfeIdDe
	oWS:cIDFINAL			:= cNfeIdAte
	oWS:dDATADE				:= dDataDe
	oWS:dDATAATE			:= dDataAte
	oWS:nDIASPARAEXCLUSAO	:= 0
	oWS:cCNPJDESTINICIAL 	:= ""
	oWS:cCNPJDESTFINAL 		:= ""
	
	lRet := oWS:RETORNAFX() //Metodo de Retorno do XML da Nfe autorizada no SEFAZ de origem por faixa de notas.
	
	If lRet == Nil .OR. !lRet
		
		//Resgata o erro ocorrido
		cWsError := GetWscError(3)
		If Empty(cWsError)
			cWsError := GetWscError(1)
		EndIf
		
		aRet := {"ERRO", "Ocorreu erro ao tentar resgatar os Documentos no TSS: " + cWsError}
	Else
		aRet := oWS:OWSRETORNAFXRESULT:OWSNOTAS:OWSNFES3
	EndIf

Else
	//Resgata o erro ocorrido
	cWsError := GetWscError(3)
	If Empty(cWsError)
		cWsError := GetWscError(1)
	EndIf
	
	aRet := {"ERRO", "Nใo foi possํvel resgatar a entidade correspondente a Empresa: [" + SM0->M0_CODIGO + "] Filial: [" + SM0->M0_CODFIL + "]" + Chr(13) + Chr(13) + cWsError}
EndIf

Return aRet

//----------------------------------------------------------
/*/{Protheus.doc} LjBldValid
Funcao para validar informa็๕es antes da transmissใo ao SEFAZ. (Blindagem NFC-e/SAT/MF-e)
@param		 
@return 
@author  Varejo
@version P11.8
@since   24/10/2016
/*/
//----------------------------------------------------------
Function LjBldValid(nTipoNota, cTexto, cTipoNota)

Default nTipoNota := 0			//0=NFCE,1=SAT,2=MFE,3=NFe
Default cTexto 	  := ""			//Retorno de texto
Default cTipoNota := "NFC-e"

//Estruturas:
cTexto += LjBldVlCab(nTipoNota)						//Cabe็alho
cTexto += LjBldVlItens(nTipoNota, cTipoNota)		//Itens
cTexto += LjBldVlPgt(nTipoNota, cTipoNota)			//Pagamento
cTexto += LjBldVlRodape(nTipoNota,,,, cTipoNota)	//Rodap้

If !Empty(cTexto)
	Aviso("Inconsist๊ncias " + cTipoNota, cTexto,{"OK"},3)
	LjGrvLog(cTipoNota, "Inconsist๊ncias: " + cTexto)
EndIf

Return Empty(cTexto)


//----------------------------------------------------------
/*/{Protheus.doc} LjBldVlCab
Funcao para validar informa็๕es do Cabe็alho antes da transmissใo ao SEFAZ. (Blindagem NFC-e/SAT/MF-e)
@param		nTipoNota
@return 
@author  Varejo
@version P11.8
@since   24/10/2016
/*/
//----------------------------------------------------------
Function LjBldVlCab(nTipoNota)

Local cTexto := ""			//Retorno de texto

Default nTipoNota := 0		//0=NFCE,1=SAT,2=MFE

Return cTexto


//----------------------------------------------------------
/*/{Protheus.doc} LjBldVlItens
Funcao para validar informa็๕es dos Itens antes da transmissใo ao SEFAZ. (Blindagem NFC-e/SAT/MF-e)
@param		nTipoNota		 
@param		cTipoNota
@return 
@author  Varejo
@version P11.8
@since   24/10/2016
/*/
//----------------------------------------------------------
Function LjBldVlItens(nTipoNota, cTipoNota)
Local cTexto 		:= ""						//Retorno de texto
Local aAreaSL2		:= SL2->(GetArea())		//Area SL2
Local aAreaSF4		:= SF4->(GetArea())		//Area SF4
Local cPosIpi		:= ""						//NCM do IPI, SL2 ou SB1
Local cOrigem		:= ""						//Origem do Produto
Local cSitTrib		:= ""						//Situa็ใo Tributแria
Local cCodIss		:= "" 					//Codigo do servi็o
Local cNumItem		:= ""						//N๚mero do Item
Local nTamPosIpi	:= 0						//Tamanho do NCM preenchido
Local nSitTrib		:= 0						//1=vindo da SL2;2=vindo da SF4
Local cSitTribL2	:= ""						//Retorno da Situa็ใo Tributแria
Local cAux			:= ""						//Variแvel auxiliar 1
Local cAux2			:= ""						//Variแvel auxiliar 2
Local cCodReg		:= SuperGetMv( "MV_CODREG" ,, "1" )	//C๓digo do regime tributแrio do emitente: 3=Regime Nacional; 1=Simples Nacional; 2=SN-Excesso de sub-limite de receita bruta.
Local aAreaSBx		:=	{}						//Area SBx 
Local cAlias		:= ""						//Alias SBx
Local lPOS			:= STFIsPOS()				//Indica se eh TOTVS PDV
Local lContinua		:= .T.						//Se satisfaz as condi็๕es de ser um item FISCAL
Local cPosIpBx		:= ""						//NCM SBx
Local cDescrBx		:= ""						//Descri็ใo Produto SBx
Local nTamPosIpBx	:= 0						//Posi็ใo do tamanho NCM gravado em SBx
Local lItemGE		:= .F.						//Se o produto ้ um item de garantia estendida
Local cPrefixo		:= ""						//Prefixo SBx
Local cTipoGE		:= SuperGetMV("MV_LJTPGAR",,"GE")	//Tipo do produto Garantia Estendida
Local lRet			:= .T.						//Retorno de While 
Local lItemISS		:= .F.						//indica se o item ้ do tipo Servico 
Local lMvNFCECNJ	:= .F.						//atribuido logo abaixo - Indica se esta apto a emitir NFC-e conjugada
Local lMvLJPRDSV	:= .F.						//atribuido logo abaixo - Indica se esta apto para emitir RPS

Default nTipoNota	:= 0						//0=NFCE,1=SAT,2=MFE
Default cTipoNota   := "NFC-e"

//verifica se possui os campos necessarios para emissao de NFC-e com RPS
lMvLJPRDSV := SuperGetMv("MV_LJPRDSV",,.F.) .AND. SL2->(ColumnPos("L2_VALISS")) > 0

//verifica se possui os campos necessarios para emissao de NFC-e com servico
lMvNFCECNJ := SuperGetMV("MV_NFCECNJ",,.F.) .AND. SL2->(ColumnPos("L2_BASEISS")) > 0 .AND. ;
SL2->(ColumnPos("L2_ALIQISS")) > 0 .AND. SL2->(ColumnPos("L2_VALISS")) > 0 .AND. SL2->(ColumnPos("L2_CODISS")) > 0

DbSelectArea("SL2")
SL2->(DbSeek(xFilial("SL2")+SL1->L1_NUM))
cL2ItemAnt := ""

If nModulo == 23 .AND. !lPos		//Front Loja
	DbSelectArea("SBI")
	aAreaSBx := SBI->( GetArea() )
	cAlias := "SBI"
	cPrefixo := "BI_"
	SBI->(DbSetOrder(2)) //BI_FILIAL + BI_TIPO + BI_COD
Else									//Venda Assistida ou Totvs PDV
	DbSelectArea("SB1")
	aAreaSBx := SB1->( GetArea() )
	cAlias := "SB1"
	cPrefixo := "B1_"
	SB1->(DbSetOrder(2)) //B1_FILIAL + B1_TIPO + B1_COD
EndIf

While SL2->( !Eof() ) .AND. ( xFilial("SL2") + SL1->L1_NUM == SL2->L2_FILIAL + SL2->L2_NUM )

	cPosIpBx 		:= ""
	cDescrBx 		:= ""
	nTamPosIpBx 	:= 0
	lRet			:= .T.
	
	(cAlias)->(DbSetOrder(2))		//Bx_FILIAL+Bx_TIPO+Bx_COD
	lItemGE 	:=  (cAlias)->( MsSeek(xFilial(cAlias) + cTipoGE + SL2->L2_PRODUTO) )
	lContinua 	:=	!lItemGE	.AND. ;		 									  	//item que nใo ้ Garantia Estendida
					((SL2->L2_ENTREGA == '1' .AND. !Empty(SL1->L1_ORCRES) ) ;	//item de or็amento filho de Retira Posterior
					.OR. SL2->L2_ENTREGA == '2' .OR. Empty(SL2->L2_ENTREGA) )	//item de or็amento Retira

	/* Tratamento para NFC-e Conjugada ou RPS*/
	If lMvLJPRDSV .OR. lMvNFCECNJ

		lItemISS := LjIsTESISS(SL1->L1_NUM,SL2->L2_TES)

		If lItemISS // se o item for do tipo Servico

			If lMVLJPRDSV	// Tratamento para RPS
				// No SIGAFRT, somente sera RPS se o orcamento for importado
				If NMODULO == 23
					lITemISS := !Empty(SL1->L1_NUMORIG) .Or. (ExistFunc("Lj7RPSNew") .And. Lj7RPSNew())
				EndIf
	
				//se for item servico (RPS), ele nao ้ considerado na NFC-e
				If lItemISS
					lContinua := .F.
				EndIf
			
			Else // NFC-e Conjugada (ICMS + ISSQN)
				lItemISS := .T.
			EndIf
		EndIf

	EndIf

	If lContinua	//Eu s๓ valido se satisfazer as condi็๕es acima
	
		cNumItem := SL2->L2_ITEM

		//Pesquisa SB1/SBI:
		//NCM (NFC-e/SAT/MF-e) e Descri็ใo do Produto para valida็ใo SAT
		(cAlias)->(DbSetOrder(1))		//Bx_FILIAL+Bx_COD
		If (cAlias)->(DbSeek(xFilial(cAlias)+SL2->L2_PRODUTO))	//Preciso fazer a pesquisa tamb้m para analisar a descri็ใo do produto
			If cAlias = "SBI"
				cPosIpBx := AllTrim(SBI->BI_POSIPI)
				cDescrBx := Alltrim(SBI->BI_DESC)
			Else
				cPosIpBx := AllTrim(SB1->B1_POSIPI)
				cDescrBx := Alltrim(SB1->B1_DESC)
			EndIf
			nTamPosIpBx := Len(cPosIpi) 
		Else
			cTexto += "L2_PRODUTO, Item " + cNumItem + ": Produto " + Alltrim(SL2->L2_PRODUTO) + " nใo encontrado no cadastro de produtos.";
					+ "Favor efetuar o cadastro." + Chr(13)+Chr(10)
			lRet := .F.
		EndIf

		If lRet 	//Se encontrou o produto

			//TES: F4_CF (CFOP) -> por que o 512 ainda estแ no cadastro?
			If Len(Alltrim(SL2->L2_CF)) < 4
				cTexto += "L2_CF, Item " + cNumItem + ": CFOP " + Alltrim(SL2->L2_CF) + " precisa ter 4 dํgitos. Favor alterar no Cadastro de Tipos de Entrada/Saํda, c๓digo " + SL2->L2_TES ;
							+", aba Impostos, campo C๓d. Fiscal (L4_CF)." + Chr(13)+Chr(10)
			EndIf
			
			// Se for Servico, nao valida ORIGEM e SITUACAO TRIBUTARIA
			If !lItemISS
				If SL2->(ColumnPos("L2_CLASFIS")) > 0 .AND. !Empty(SL2->L2_CLASFIS) .And. Len(SL2->L2_CLASFIS) == 3 .And. !Empty(Substr(SL2->L2_CLASFIS,2,2))
					nSitTrib	:= 1
					cSitTribL2 := SL2->L2_CLASFIS
				Else	//para Totvspdv L2_CLASFIS Nใo ้ preenchido no totvspdv
					nSitTrib	:= 2
					//posicionamos no TES do item da venda
					If SF4->( DbSeek(xFilial("SF4") + SL2->L2_TES) )
						cSitTribL2 := SL2->L2_ORIGEM+SF4->F4_SITTRIB
					Else
						cTexto += "L2_TES, Item " + cNumItem + ": Tipo de Saํda " + Iif(Empty(SL2->L2_TES),"<em branco>",SL2->L2_TES) + " nใo encontrada no cadastro." ;
									+ Chr(13)+Chr(10)
						cSitTribL2 := SL2->L2_ORIGEM+"  "
					EndIf 
				EndIf

				cOrigem 	:= Substr(cSitTribL2,1,1)
				cSitTrib	:= Substr(cSitTribL2,2,2)

				//TES: B1_ORIGEM (Origem do produto), gravado na primeira posi็ใo de L2_CLASFIS
				If Empty(cOrigem) .OR. !(cOrigem $ "0/1/2/3/4/5/6/7/8")		//Substituํmos por valores fixos
					cTexto += cPrefixo + "ORIGEM, Item " + cNumItem + ": Origem " + Iif(Empty(cOrigem),"<em branco>",cOrigem) + " nใo encontrada no cadastro. Favor alterar no Cadastro de Produtos, c๓digo " + Alltrim(SL2->L2_PRODUTO) ;
								+ ", aba Impostos, e preencher o campo Origem (B1_ORIGEM)." + Chr(13)+Chr(10)
				EndIf

				//TES: F4_SITTRIB (Situa็ใo Tributแria)
				If !Empty(cSitTrib) .AND. !(cSitTrib $ "00/20/30/40/41/60/70/90/02/15/53/61") .And. !lLJCUPXML
					cTexto += IIf(nSitTrib=1,"L2_CLASFIS","F4_SITTRIB")+", Item " + cNumItem + ": Situa็ใo Tributแria " + Iif(Empty(cSitTrib),"<em branco>",cSitTrib) + " nใo disponํvel para " + cTipoNota + ". Favor alterar no Cadastro de Tipos de Entrada/Saํda, c๓digo " + Alltrim(SL2->L2_TES) ;
								+ ", aba Impostos, e preencher o campo Sit. Trib. ICM (F4_SITTRIB), ou verifique se ้ possํvel emitir NF-e." +Chr(13)+Chr(10)
				EndIf

			EndIf

			//C๓pia de LjNFCeDet()
			//Produto: B1_POSIPI (NCM)
			//Leio o NCM da SL2
			cPosIpi := AllTrim( SL2->L2_POSIPI )
			cCodIss	:= Alltrim(	SL2->L2_CODISS )
			nTamPosIpi := Len(cPosIpi)
			If Empty(cCodIss)
				If Empty(cPosIpi)
					//Leio o NCM da SB1/SBI
					cPosIpi := cPosIpBx
					nTamPosIpi := nTamPosIpBx
					If Empty(cPosIpi)
						cTexto += cPrefixo+STR0080/*"POSIPI, Item "*/ + cNumItem + STR0081/*": NCM "*/ + Alltrim(cPosIpi) + STR0082/*" nใo cadastrado. Favor alterar no Cadastro de Produtos, c๓digo "*/ + Alltrim(SL2->L2_PRODUTO) ;
								+STR0083/*", aba Impostos, e preencher o campo POS.IPI/NCM (B1_POSIPI)."*/ + Chr(13)+Chr(10)
					ElseIf nTamPosIpi <> 2 .AND. nTamPosIpi <> 8
						cTexto += cPrefixo+STR0080/*"POSIPI, Item "*/ + cNumItem + STR0081/*": NCM "*/ + Alltrim(cPosIpi) + STR0084/*" invแlido. O NCM deverแ ser preenchido em 2 ou 8 caracteres. Favor alterar no Cadastro de Produtos, c๓digo "*/ + Alltrim(SL2->L2_PRODUTO) ;
								+STR0083/*", aba Impostos, e preencher o campo POS.IPI/NCM (B1_POSIPI)."*/+ Chr(13)+Chr(10)
					EndIf				
				ElseIf nTamPosIpi <> 2 .AND. nTamPosIpi <> 8
					cTexto += cPrefixo + "POSIPI, Item " + cNumItem + ": NCM " + Alltrim(cPosIpi) + " deverแ ser preenchido em 2 ou 8 caracteres. Favor alterar no Cadastro de Produtos, c๓digo " + Alltrim(SL2->L2_PRODUTO) ;
							+", aba Impostos, e preencher o campo POS.IPI/NCM (B1_POSIPI)."+ Chr(13)+Chr(10)
				EndIf
			EndIf
			
			//Valida็๕es SAT/MFE
			If (nTipoNota == 1 .Or. nTipoNota == 2)	//SAT/MFE
	
				//B1_DESC descri็ใo do produto nใo deve conter caracteres especiais
				cAux := cDescrBx						//Descri็ใo do Produto SB1/SBI
				cAux2 := Alltrim(LjNFTrtS(cAux, .F.))	//Fun็ใo do Lojnfce.prw

				IF cAux <> cAux2
					cTexto += cPrefixo + "DESC, Item " + cNumItem + ": Descri็ใo do Produto " + Alltrim(cAux) + " estแ com caracteres especiais. Favor alterar no Cadastro de Produtos, c๓digo " + SL2->L2_PRODUTO ;
							+ Chr(13)+Chr(10)
				EndIf	
	
				//SL2 estแ ligada no SF4?
				If SF4->( DbSeek(xFilial("SF4") + SL2->L2_TES) )
		
					//F4_PISCOF (PIS/COFINS) 		//1 a 4
					cAux := SF4->F4_PISCOF
					If Empty(cAux) .OR. !(cAux $ "1/2/3/4")
						cTexto += "F4_PISCOF, Item " + cNumItem + ": PIS/COFINS " + Iif(Empty(cAux),"<em branco>",cAux) + " nใo encontrado no cadastro. Favor alterar no Cadastro de Tipos de Entrada/Saํda, c๓digo " + SL2->L2_TES ;
									+", aba Impostos, e preencher o campo PIS/COFINS (F4_PISCOF)."+ Chr(13)+Chr(10)
					EndIf
	
					//F4_PISCRED (Cred. PIS/COF)	//1 a 5
					cAux := SF4->F4_PISCRED
					If Empty(cAux) .OR. !(cAux $ "1/2/3/4/5")
						cTexto += "F4_PISCRED, Item " + cNumItem + ": Cred. PIS/COF " + Iif(Empty(cAux),"<em branco>",cAux) + " nใo encontrado no cadastro. Favor alterar no Cadastro de Tipos de Entrada/Saํda, c๓digo " + SL2->L2_TES ;
									+", aba Impostos, e preencher o campo Cred. PIS/COF (F4_PISCRED)."+ Chr(13)+Chr(10)
					EndIf
	
					If cCodReg = "3"		//Regime Nacional
						//F4_CSTPIS (Sit. Trib. PIS)	//01 a 09, e 99, desde que MV_CODREG = 3
						cAux := SF4->F4_CSTPIS
						If Empty(cAux)
							cTexto += "F4_CSTPIS, Item " + cNumItem + ": Sit. Trib. PIS " + Iif(Empty(cAux),"<em branco>",cAux) + " nใo preenchida. Favor alterar no Cadastro de Tipos de Entrada/Saํda, c๓digo " + SL2->L2_TES ;
										+", aba Outros, campo SIT.Trib.PIS, e escolher o c๓digo entre 01 e 09, e 99."+ Chr(13)+Chr(10)
						Elseif !(cAux $ "01/02/03/04/05/06/07/08/09/99")
							cTexto += "F4_CSTPIS, Item " + cNumItem + ": Sit. Trib. PIS " + Iif(Empty(cAux),"<em branco>",cAux) + " nใo disponํvel para " + cTipoNota + ". Favor alterar no Cadastro de Tipos de Entrada/Saํda, c๓digo " + SL2->L2_TES ;
										+", aba Outros, campo SIT.Trib.PIS, e escolher o c๓digo entre 01 e 09, e 99."+ Chr(13)+Chr(10)
						EndIf
	
						//F4_CSTCOF (Sit. Trib. COF)	//01 a 09, e 99, desde que MV_CODREG = 3
						cAux := SF4->F4_CSTCOF
						If Empty(cAux)
							cTexto += "F4_CSTCOF, Item " + cNumItem + ": Sit. Trib. COF " + Iif(Empty(cAux),"<em branco>",cAux) + " nใo preenchida. Favor alterar no Cadastro de Tipos de Entrada/Saํda, c๓digo " + SL2->L2_TES ;
										+", aba Outros, campo SIT.Trib.COF, e escolher o c๓digo entre 01 e 09, e 99."+ Chr(13)+Chr(10)
						Elseif !(cAux $ "01/02/03/04/05/06/07/08/09/99")
							cTexto += "F4_CSTCOF, Item " + cNumItem + ": Sit. Trib. COF " + Iif(Empty(cAux),"<em branco>",cAux) + " nใo disponํvel para " + cTipoNota + ". Favor alterar no Cadastro de Tipos de Entrada/Saํda, c๓digo " + SL2->L2_TES ;
										+", aba Outros, campo SIT.Trib.COF, e escolher o c๓digo entre 01 e 09, e 99."+ Chr(13)+Chr(10)
						EndIf
					EndIf
	
				EndIf
			Else //Validacoes NFCe
            	If SF4->(dbSeek(xFilial("SF4") + SL2->L2_TES))
					If cCodReg == "1" //Regime Simples Nacional                   
            			If SF4->F4_ICM == "S"
                        	cAux := SF4->F4_ICM 
                        	cTexto += "F4_ICM, Item " + cNumItem + ": com conte๚do " + cAux + ". Para empresas do tipo Simples Nacional essa configura็ใo nใo ้ permitida. Favor alterar no Cadastro de Tipos de Entrada/Saํda, c๓digo " + SL2->L2_TES ;
                        	+", aba Impostos, campo Calcula ICMS, e escolher a op็ใo Nao."+ Chr(13)+Chr(10)
                   		ElseIf Empty(SF4->F4_CSOSN)                            
                        	cTexto += "F4_CSOSN, Item " + cNumItem + ": com conte๚do " + "<em branco>" + ". Para empresas do tipo Simples Nacional essa configura็ใo ้ necessแria. Favor alterar no Cadastro de Tipos de Entrada/Saํda, c๓digo " + SL2->L2_TES ;
                        	+", aba Outros, campo Cod Sit SN, e inserir o c๓digo de acordo com a situa็ใo da opera็ใo do ICMS."+ Chr(13)+Chr(10)
                        EndIf                        
               		EndIf
               		
               		If AllTrim(SF4->F4_ISS) == "S"
                        If Empty(SF4->F4_ISSST)
                        	cTexto += " Conte๚do do campo F4_ISSST invแlido. Para efetiva็ใo da venda preencha esse campo" +;
                        			" com um conte๚do vแlido, conforme Cadastro de TES - Tipo de Entrada e Saํda" + CHR(13) + CHR(10)                        	                        	
                  		EndIf
                  	EndIf
           		EndIf	
			EndIf
		EndIf
	EndIf

	SL2->(DbSkip())	
EndDo

RestArea( aAreaSL2 )
RestArea( aAreaSF4 )
RestArea( aAreaSBx )

Return cTexto

//-----------------------------------------------------------------------
/*/{Protheus.doc} LjBldVlPgt
Funcao para validar informa็๕es do Pagamento antes da transmissใo ao SEFAZ. (Blindagem NFC-e/SAT/MF-e)

@author  Alberto Deviciente
@since 	 04/11/2021
@version P12

@param 	 nTipoNota, Num้rico, Tipo de Nota (0=NFCE, 1=SAT, 2=MFe)
@param 	 cTipoNota, Caractere, Tipo de Nota ("NFC-e", "SAT", "MF-e")

@return  cTexto, Caractere, Texto descritivo da inconsist๊ncia.
/*/
//-----------------------------------------------------------------------
Function LjBldVlPgt(nTipoNota, cTipoNota)
Local cTexto 		:= ""					//Retorno de texto
Local aArea			:= GetArea()
Local aAreaSAE 		:= {}
Local aAreaSL4 		:= {}
Local cFormPg       := "CC,CD" //Formas de pagamento que exigem informar a tag <cAdmC> (Credenciadora de cartใo de d้bito ou cr้dito) para o SAT / MF-e
Local cCodAdmFin	:= ""

Default nTipoNota	:= 0					//0=NFCE,1=SAT/2=MFE
Default cTipoNota   := "NFC-e"

// Valida็ใo para MF-e (Cearแ)
If nTipoNota == 2 //2=MFE
	aAreaSAE := SAE->(GetArea())
	aAreaSL4 := SL4->(GetArea())
	
	DbSelectArea("SAE")
	SAE->(DbSetOrder(1)) //AE_FILIAL+AE_COD

	DbSelectArea("SL4")
	SL4->(DbSetOrder(1)) //L4_FILIAL+L4_NUM+L4_ORIGEM

	If SL4->(DbSeek(xFilial("SL4")+SL1->L1_NUM))
		While SL4->(!EoF()) .And. SL4->L4_FILIAL+SL4->L4_NUM == xFilial("SL4")+SL1->L1_NUM
			If AllTrim(SL4->L4_FORMA) $ cFormPg .And. !Empty(SL4->L4_ADMINIS)
				cCodAdmFin := Left(SL4->L4_ADMINIS, TamSx3("AE_COD")[1])
				//Verifica se o campo AE_SAT estแ alimentado. Nele fica a informa็ใo da tag <cAdmC> do SAT/MF-e
				If SAE->(DbSeek(xFilial("SAE") + cCodAdmFin))
					If Empty(AllTrim(SAE->AE_SAT))
						cTexto += "ษ necessแrio que o campo AE_SAT esteja preenchido para forma(s) de pagamento " + cFormPg + ". Favor alterar no Cadastro de Administradora Financeira, c๓digo " + cCodAdmFin ;
								+", e preencher o campo: Cred. SAT (AE_SAT)."+ Chr(13)+Chr(10)
						Exit
					EndIf		
				EndIf

			EndIf
			SL4->(DbSkip())
		End
	EndIf

	RestArea(aAreaSAE)
	RestArea(aAreaSL4)
EndIf

RestArea(aArea)

Return cTexto

//----------------------------------------------------------
/*/{Protheus.doc} LjBldVlRodape
Funcao para validar informa็๕es do Rodap้ antes da transmissใo ao SEFAZ. (Blindagem NFC-e/SAT/MF-e)
@param		 
@return 
@author  Varejo
@version P11.8
@since   24/10/2016
/*/
//----------------------------------------------------------
Function LjBldVlRodape(nTipoNota, lFrete, cCliente, cLoja, cTipoNota, cTransp)

Local cTexto 		:= ""									//Retorno de texto
Local cEstSM0		:= IIf(!lEndFis, SM0->M0_ESTCOB, SM0->M0_ESTENT)
Local nPos			:= 0									//Posi็ใo do array
Local lLj950ImpCpf	:= ExistFunc("Lj950ImpCpf")				//Verifica se existe a fun็ใo que limita o valor do cliente nใo identificado
Local aValLim    	:= IIf( ExistFunc("Lj950UFVal"), Lj950UFVal(), {} )	//Array de valor do limite por UF
Local aRetAux		:= {}

Default nTipoNota	:= 0									//0=NFCE,1=SAT/2=MFE
Default lFrete		:= .F.														//indica se a venda ้ Entrega a Domํcilio (com Frete informado)
Default cCliente	:= ""
Default cLoja		:= ""
Default cTipoNota   := "NFC-e"
Default cTransp		:= ""

// Valida็๕es SAT/MFE
If nTipoNota == 1 .Or. nTipoNota == 2	
	If lLj950ImpCpf .AND. SL1->L1_VLRTOT >= 10000 //Se cliente padrใo e limite de cliente nใo identificado
		cTexto += "L1_VLRTOT: Foi ultrapassado o valor limite do total do " + cTipoNota + "(10.000,00)! Favor utilizar a NF-e.";
				+ Chr(13)+Chr(10)
	EndIf

// Valida็๕es NFC-e
Else
	// procuramos o Estado em questao no array com os valores limites para cada UF  
	nPos := Ascan(aValLim,{|x| x[1] == cEstSM0})

	// se nใo for encontrado, usamos o valor limite de R$ duzentos mil, ate que os valores limites da UF sejam adicionados na funcao Lj950UFVal(LOJA950.PRW)
	If nPos < 1
		AAdd( aValLim, {"*", 200000, 0, 0} )
		nPos := Len(aValLim) 
	EndIf

	// o valor da venda ultrapassou o valor limite para emissao de NFC-e
	If SL1->L1_VLRTOT > aValLim[nPos][2] 
			cTexto += "L1_VLRTOT: Foi ultrapassado o valor total limite de (" + Alltrim(Transform(aValLim[nPos][2], "@E 999,999,999.99")) + ") estabelecido pela SEFAZ para venda com " + cTipoNota + "!";
			+ CRLF + "Favor utilizar a NF-e." + CRLF

	// o valor da venda obriga informar o endereco do destinatario OU entrega a domicilio - <enderDest> 
	ElseIf lFrete /* .OR. SL1->L1_VLRTOT > aValLim[nPos][3] */

		//verifica se algum campo necessario do SA1 nao esta preenchido
		aRetAux := LjVEndDest( cCliente, cLoja )

		If !aRetAux[1]
			cTexto := 'Identificamos que o cliente: ' + AllTrim(aRetAux[2][1]) + "-" +  AllTrim(aRetAux[2][2]) + ": " + AllTrim(aRetAux[2][3])
			cTexto += ' nใo possui essas informa็๕es em seu cadastro:' + CRLF
			cTexto += aRetAux[3]	//campos nao preenchidos
			cTexto += 'Por favor, atualize o cadastro desse cliente, pois essas informa็๕es sใo obrigat๓rias para uma venda com '
			If lFrete
				cTexto += "Entrega a Domํcilio."
			Else
				cTexto += "valor superior a R$ " + AllTrim(Transform(aValLim[nPos][2], "@E 999,999,999.99") )
			EndIf
		ElseIf Empty(cTransp)
			cTexto := STR0152 + CRLF	//"Identificamos que foi informado valor de frete e nใo foi informada a transportadora!"
			cTexto += STR0153			//"Por favor, informe a transportadora."
			
		EndIf
	EndIf
EndIf

Return cTexto


/*/{Protheus.doc} LjAutoNFe
Faz a impressao do DANFE NF-e usando os rdmakes DANFEII e DANFEIII
@type		function
@param		cDoc, Numero do documento fiscal
@param		cSerie, Serie do documento fiscal
@param		cCliente, Codigo do Cliente
@param		cLoja, Codigo da Loja
@author  	Varejo
@version 	P12
@since   	20/11/2016
@return  	Nil
@obs		Como parametros, usamos os campos da chave unica
/*/
Function LjAutoNFe(cDoc, cSerie, cCliente, cLoja)
Local xMvLjTxNFe	:= 0					//[0]NAO transmite NF-e [1]Transmite NF-e [2]Transmite E imprime o DANFE NF-e
Local aArea			:= {}
Local aSF2Area		:= {}
Local lPOS			:= STFIsPOS()			//indica se eh TOTVS PDV
Local aRetSFZ		:= {}
Local aRetTSS		:= {}
Local cRetTSS		:= ""
Local cMsgTSS		:= ""
Local dDtInutPDV	:= CtoD("05/07/2019")	//Data utilizada na valida็ใo de fontes.	
Local lInutPDV		:= Iif(ExistFunc("LOJXNFCE") .AND. ExistFunc("LOJGNFCE") .AND. ExistFunc("LOJCNFCE") ,GetApoInfo("LOJXNFCE.PRW")[4] >= dDtInutPDV .AND. GetApoInfo("LOJGNFCE.PRW")[4] >= dDtInutPDV .AND. GetApoInfo("LOJCNFCE.PRW")[4] >= dDtInutPDV,.F.)		//Valida็ใo para o uso do cancelamento / inutiliza็ใo direto no PDV
Local lSefazOk		:= .F.					// Indica se o status da transmissใo esta Ok
Local lContinua 	:= .F.
Local aAreaSL1		:= {}

Default cDoc		:= ''
Default cSerie		:= ''
Default cCliente	:= ''
Default cLoja		:= ''

/*
- Conversao do valor do parametro MV_LJTXNFE -
A principio, esse parametro foi criado com o tipo Logico,
porem foi transformado em numerico para aumentar o numero de opcoes.
*/
xMvLjTxNFe := SuperGetMV("MV_LJTXNFE",,0)
If ValType(xMvLjTxNFe) == "L"
	If xMvLjTxNFe
		xMvLjTxNFe := 1	//Somente realiza a transmissao da NF-e
	Else
		xMvLjTxNFe := 0
	EndIf
	LjGrvLog( SL1->L1_NUM, "Houve a conversao do parametro MV_LJTXNFE", xMvLjTxNFe )

	if lPOS
		STFMessage("STWFINISHSALE", "ALERT", STR0158 )
		STFShowMessage( "STWFINISHSALE" )
	endif

EndIf

// Processo de transmissao de NF-e pelo SIGALOJA habilitado
If xMvLjTxNFe > 0

	// obtem a Area do Alias corrente a da SF2
	aArea := GetArea()
	aSF2Area := SF2->( GetArea() )
		
	DbSelectArea("SF2")
	SF2->( DbSetOrder(1) )	//F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA
	If SF2->( DbSeek( xFilial("SF2") + cDoc + cSerie + cCliente + cLoja) )
			
		//Verifica se ้ esp้cie SPED (NF-e)
		lContinua := AllTrim(SF2->F2_ESPECIE) == "SPED"

		If lContinua
			if lPos
				STFMessage(ProcName(), "ALERT", STR0159 ) //"Transmitindo NF-e a SEFAZ!"
				STFShowMessage( ProcName() )
			endif
			
			LjGrvLog(SL1->L1_NUM, "Iniciando processo de transmissao da NF-e", SF2->F2_DOC)
		
			//faz a transmissao da NF-e para o TSS
			aRetSFZ := LjEnviaNFe(SF2->F2_SERIE, SF2->F2_DOC, SF2->F2_CLIENTE, SF2->F2_LOJA)

			If lPos
				STFMessage(ProcName(), "ALERT", STR0160 ) //"Transmissใo NF-e concluido!"
				STFShowMessage( ProcName() )
			endif

			LjGrvLog(SL1->L1_NUM, "Processo de transmissao da NF-e concluido", SF2->F2_DOC + '/' + SF2->F2_SERIE)			

			If lPos
				//Verifica se houve um retorno positivo do TSS para imprimir a Danfe
				// se o DANFE foi impresso ou o status da nota nao eh mais (T)ransmitida
				aRetTSS :=  StrToKarr(SL1->L1_RETSFZ,"|")
				If len(aRetTSS) > 2
					cRetTSS := aRetTSS[02]
					cMsgTSS := aRetTSS[03]  
				else 
					cRetTSS := aRetTSS[01]
					cMsgTSS := iif(len(aRetTSS) > 1, aRetTSS[02], "")
				endif

				lSefazOk := !LjRetStatusSEFAZ(cRetTSS,cMsgTSS) $ "A"

			ElseIf aRetSFZ[01] .AND. SF2->F2_FIMP == "T"
				lSefazOk := .T.
			EndIf	

			//Verifica se transmissใo ocorreu com sucesso para verificar autoriza็ใo da SEFAZ
			if lSefazOk
				
				LjDANFENFe(xMvLjTxNFe, cDoc, cSerie)
				LjGrvLog(SL1->L1_NUM, "Transmissao da NF-e autorizada", SF2->F2_DOC + '/' + SF2->F2_SERIE)
				
				If xMvLjTxNFe == 1
					aAreaSL1 := SL1->(GetArea())
					SL1->(DbSetOrder(1)) //L1_FILIAL + L1_NUM
						If SL1->(DBSeek(SL1->L1_FILIAL+SL1->L1_ORCRES))						
							If (SL1->L1_ORIGEM = 'N' .AND. !Empty(SL1->L1_UMOV)) .AND. ExistFunc("RmiExeGat") .AND. ExistFunc("SHPStatus")
								SHPStatus("order_delivered")
							EndIf				
						EndIf
					RestArea(aAreaSL1)
				EndIf
			else //-- Se for Rejeito de Schema informar ao usuario

				LjGrvLog(SL1->L1_NUM, "Rejei็ใo na transmissao da NF-e", SF2->F2_DOC + '/' + SF2->F2_SERIE)			

				//-- Sera ativado apenas para Totvs PDV com NF-e, pois no SIGALOJA
				//-- ja existe o processo de inutiliza็ใo on-line					
				if lPos .and. lInutPDV 

					//Verifica se a nota foi denegada	
					if ExistFunc("LjCodDeneg") .and. (cRetTSS $ LjCodDeneg(1)[01])
						STFMessage(ProcName(), "ALERT", STR0161 ) //#"Escriturando Nota Fiscal Denegada"
						STFShowMessage( ProcName() )

						LjNFeDeneg()
					else
						//inutiliza็ใo
						STFMessage(ProcName(), "ALERT", STR0162 ) //#"Transmitindo Inutiliza็ใo, aguarde!"
						STFShowMessage( ProcName() )

						// -- Inicio a inutiliza็ใo / Cancelamento enviando para o TSS direto pelo PDV
						oLOJCNFCE := LOJCNFCE():NEW()
						oLOJCNFCE:LjCancInut(SL1->(L1_SERIE+L1_DOC), Substring(SL1->L1_KEYNFCE,21,2) )
						if oLOJCNFCE:aResultMetodo[1]
							LjGrvLog(SL1->L1_NUM,"Inutiliza็ใo / Cancelamento Realizado direto pelo PDV DOC:" + SL1->L1_DOC + " Serie: " + SL1->L1_SERIE)

						else
							LjGrvLog(SL1->L1_NUM,"Nใo foi possivel Inutiliza / Cancelar a Nota direto pelo PDV, a Inutiliza็ใo / Cancelamento sera realizada pelo Job de cancelamentos.")
							LjGrvLog(SL1->L1_NUM,"Motivo: " + oLOJCNFCE:aResultTSS[3])
						endif 

						//Verifica se o controle de cancelamento/inutilizacao de NFC-e sera pela tabela (SLX) ou sera pelo antigo tratamento (SL1)
						if !( SLX->(ColumnPos("LX_MODDOC")) > 0 .And. STBChkInut() )
							//Agora com o novo conceito de incluir os dados do orcamento na SLX para que seja feito o cancelamento/inutilizacao da numeracao da NFCE, 
							//este trecho somente tem sentido quando nao existir o campo LX_MODDOC.
							//Com este novo tratamento o orcamento nao eh mais cancelado, ou seja, este continua disponivel para finalizar a venda novamente
							//e a numeracao da NFC-e apenas que eh inutilizada.  
							RecLock( "SL1" )
								Replace SL1->L1_STORC with "A"
								Replace SL1->L1_NUMORIG with ""
							SL1->( MsUnlock() )
				
						endif
							
					endif

					STFMessage(ProcName(), "ALERT", STR0061 + ", Retransmita Novamente!" )
					STFShowMessage( ProcName() )
				else
					//#"Erro ao transmitir a NF-e." #"Verifique o motivo na rotina Monitor, fa็a o ajuste e retransmita a NF-e."
					MsgStop(STR0061 + CRLF + STR0062, "ERR_TX_NFE")
				endif
				LjGrvLog(SL1->L1_NUM, STR0061 , SF2->F2_FIMP)

			endif
		endif

	Else
		LjGrvLog(SL1->L1_NUM, "O Documento: ["+ cDoc +"] / Serie: ["+ cSerie +"] nao esta apto para transmissao")
	EndIf

	RestArea(aSF2Area)
	RestArea(aArea)

EndIf

LjNFCeClr(1) 
LjNFCeClr(2)

Return Nil


/*/{Protheus.doc} LjDANFENFe
Prepara os objetos de impressao e realiza a impressao do DANFE NF-e
@type		function
@author  	Varejo
@version 	P12
@since   	20/11/2016
@return  	Nil
@obs     	Baseada na funcao SPEDDANFE() (SPEDNFE.PRX)
/*/
Static Function LjDANFENFe(xMvLjTxNFe, cDoc, cSerie)
Local cFilePrint	:= ""	//nome do arquivo de impressao do DANFE
Local cChave		:= ""	//valor da chave pesquisada no Profile do usuario
Local cIDEnt		:= ""	//codigo da entidade do servidor TSS
Local cSession		:= GetPrinterSession()
Local lRetAux		:= .T.
Local oDANFE		:= Nil	//objeto da classe FwMsPrinter
Local oSetup		:= Nil	//objeto da classe FwPrintSetup
Local oProcess		:= Nil	//objeto da classe MsNewProcess

Local nFlags		:= 0	//indica quais opcoes estarao disponiveis na configuracao da impressao
Local nDestination	:= 1	//SERVER
Local nOrientation	:= 1	//PORTRAIT
Local nPrintType	:= 6	//PDF
Local aDevice		:= {}
Local lPOS			:= STFIsPOS()	//indica se eh TOTVS PDV
Local aImpSmart		:= {}

Default xMvLjTxNFe	:= 2 
Default cDoc 		:= ""
Default cSerie 		:= ""

//Entidade configurada no servidor TSS
cIDEnt := LjTSSIDEnt("55")

Do case
	case xMvLjTxNFe == 1
		If lPos
			LjProcDNFe(oProcess, cIDEnt, oDANFE, oSetup, cFilePrint, xMvLjTxNFe)
		EndIf

	case xMvLjTxNFe == 2
	
		//Nome do arquivo que sera impresso: DANFE_ + ENTIDADE + AAAAMMSS + HHMMSS   
		cFilePrint := "DANFE_" + cIDEnt + DtoS(MSDate()) + StrTran(Time(),":","")
	
		//
		// Configuracoes de Impressao baseada no Profile
		//
		cChave := FWGetProfString(cSession, "LOCAL", "CLIENT", .T.)//Usuario tem que alterar manualmente para impressora padrao "SERVER"
		If cChave <> "CLIENT"	
			nDestination := 2	//CLIENT
		EndIf
	
		cChave := FWGetProfString(cSession, "ORIENTATION", "PORTRAIT", .T.)
		If cChave <> "PORTRAIT"
			nOrientation := 2	//LANDSCAPE
		EndIf
	
		aDevice := {"DISCO","SPOOL","EMAIL","EXCEL","HTML","PDF"}
		cChave := FWGetProfString(cSession, "PRINTTYPE", "SPOOL", .T.)
		If Empty(cChave)
			cChave := "PDF"
		EndIf
		nPrintType := aScan( aDevice, {|x| x == cChave} )
	
		//
		// FWPrintSetup
		//
		nFlags := PD_ISTOTVSPRINTER + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN // indica quais opcoes estarao disponiveis
		oSetup := FWPrintSetup():New(nFlags, "DANFE")
	
		oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
		oSetup:SetPropert(PD_ORIENTATION , nOrientation)
		oSetup:SetPropert(PD_DESTINATION , nDestination)
		oSetup:SetPropert(PD_MARGIN      , {60,60,60,60})
		oSetup:SetPropert(PD_PAPERSIZE   , 2)
		oSetup:CQTDCOPIA := "01"
	
		//
		// FWMsPrinter
		//
		oDANFE := FWMSPrinter():New(cFilePrint, nPrintType /*IMP_PDF*/, .F. /*lAdjustToLegacy*/, /*cPathInServer*/, .T.) 
	
		oDANFE:SetCopies( Val(oSetup:CQTDCOPIA) )
		
		If GetRemoteType() <> REMOTE_LINUX
			//Carrega as Impressoras do Smartclient para facilitar a impressao sem escolha
			aImpSmart := GetImpWindows(.F.)
			
			//Seta a impressora padrao Windows
			if !Empty(aImpSmart)
				oDANFE:nDevice := IMP_SPOOL
				oSetup:aOptions[PD_VALUETYPE] := aImpSmart[01]
			endif
		EndIf
	
		//
		// Ponto de Entrada para customizar os objetos de impressao
		//
		If ExistBlock( "SPNFESETUP" )
			Execblock( "SPNFESETUP" , .F. , .F. , {oDANFE, oSetup} )
		Else		
			// Interface para o usuario configurar os parametros de impressao
			lRetAux := oSetup:Activate() == PD_OK
			oDANFE:SetCopies( Val(oSetup:CQTDCOPIA) )
		EndIf
	
		If lRetAux
	
			//
			// Atualiza os parametros no Profile
			//
			FwWriteProfString( cSession, "LOCAL"      , If(oSetup:GetProperty(PD_DESTINATION)==1 ,"SERVER"    ,"CLIENT"    ), .T. )
			FwWriteProfString( cSession, "PRINTTYPE"  , If(oSetup:GetProperty(PD_PRINTTYPE)==2   ,"SPOOL"     ,"PDF"       ), .T. )
			FwWriteProfString( cSession, "ORIENTATION", If(oSetup:GetProperty(PD_ORIENTATION)==1 ,"PORTRAIT"  ,"LANDSCAPE" ), .T. )
	
			if lPos
				LjProcDNFe(oProcess, cIDEnt, oDANFE, oSetup, cFilePrint, xMvLjTxNFe)			
			else
				// Realiza a impressao do DANFE NF-e e tambem controla as duas barras de progresso
				oProcess := MsNewProcess():New( { || LjProcDNFe(oProcess, cIDEnt, oDANFE, oSetup,;
																cFilePrint, xMvLjTxNFe, cDoc, cSerie) } , STR0075 , STR0041+"..." , .T. ) //#"Imprimindo DANFE NF-e" #"Aguarde"
				oProcess:Activate()
			endif
	
		endif
	
	case xMvLjTxNFe == 3 //Impressao Danfinha - NF-e Reduzida
		if lPos
			LjProcDNFe(oProcess, cIDEnt, oDANFE, oSetup, cFilePrint, xMvLjTxNFe)
		else
			//-- Realiza a impressao do DANFE NF-e e tambem controla as duas barras de progresso
			oProcess := MsNewProcess():New( { || LjProcDNFe(oProcess, cIDEnt, oDANFE, oSetup, cFilePrint, xMvLjTxNFe, cDoc, cSerie) } )
			oProcess:Activate()
		endif
endcase

FreeObj(oProcess)
Process := Nil
Return Nil


/*/{Protheus.doc} LjProcDNFe
Faz a impressao do DANFE NF-e usando os rdmakes DANFEII e DANFEIII
@type		function
@param		oProcess, objeto que controla a barra de progresso
@param		cIDEnt, entidade do servidor TSS
@param		oDANFE, objeto da classe FWMSPrinter
@param		oSetup, objeto da classe FWPrintSetup
@param		cFilePrint, nome do arquivo que sera impresso
@author  	Varejo
@version 	P12
@since   	20/11/2016
@return  	Nil
/*/
Static Function LjProcDNFe( oProcess, cIDEnt, oDANFE, oSetup, cFilePrint, xMvLjTxNFe, cDoc, cSerie )

Local nI 			:= 0
Local nX			:= 0
Local nTentativa	:= 5
Local nIntervalo	:= 5	//em segundos
Local lLoja			:= .T.	//indica que ้ SIGALOJA (usado no DANFEII e DANFEIII)
Local lExistNFe		:= .F.	//indica se o DANFE NF-e foi impresso
Local cMvLjTNInt	:= SuperGetMV("MV_LJTNINT",,"5;5")
Local aMvLjTNInt	:= {}	//[1] Numero de Tentativas [2]Intervalo em segundos entre eals
Local cRdMake		:= ""	//Verifica qual RdMake a ser impresso
Local aInfMonNFe	:= {}
Local cAutoriza		:= ""
Local cChaveNFe		:= ""
Local HAutNFe		:= ""
Local DAutNFe		:= ""
Local cCodRetNFE	:= ""
Local cMsgRetNFE	:= ""
Local cRetSFZ		:= ""
Local cXmlProt		:= ""
Local aNotas		:= {}
Local lPOS			:= STFIsPOS()	//indica se eh TOTVS PDV
Local nPausa		:= 1			//Indica o tempo de pausa para nova consulta, evitar consulta consecultivas
Local cXmlFsda		:= ""	//XML da conting๊ncia na modalidade 7 FSDA

Default oProcess	:= Nil
Default oDANFE		:= Nil
Default oSetup		:= Nil
Default cFilePrint	:= ""
Default xMvLjTxNFe	:= 2	//Mantem a op็ใo padrใo do processo do Sigaloja - Danfe A4  
Default cDoc		:= ""
Default cSerie		:= ""

/*
|| Se os parโmetros cDoc e cSerie estiverem sido informados o tratamento ้ feito com base neles, 
|| e nใo pela SL1, para evitar de sempre imprimir o DANFE referente a primeira nota,
|| pois existem casos de uma venda gerar mais de uma NF-e, 
|| por้m na SL1 fica gravado s๓ a numera็ใo do primeiro documento.
*/
If Empty(cDoc + cSerie)
	 cDoc	:= SL1->L1_DOC
	 cSerie := SL1->L1_SERIE
EndIf

/*
MV_LJTNINT
Indica o numero de tentativas e o intervalo em segundos entre elas. Devem ser separadas por ;
*/
aMvLjTNInt := StrTokArr( AllTrim(cMvLjTNInt), ";" )
If Len(aMvLjTNInt) >= 2
	//configura Numero de Tentativas e Intervalo entre cada uma
	nTentativa := Val(aMvLjTNInt[1])
	nIntervalo := Val(aMvLjTNInt[2])
ElseIf Len(aMvLjTNInt) = 1
	//configura somente o Numero de Tentativas
	nTentativa := Val(aMvLjTNInt[1])
	nIntervalo := 5	// valor padrao
EndIf

If ValType(MV_PAR07) <> "D"
	MV_PAR07 := ""
	MV_PAR08 := ""
EndIf

//DANFE modo Retrato - DANFEII.PRW
cRdMake := iif( ExistFunc("U_PRTNFESEF"), "U_PRTNFESEF", "PRTNFESEF")

//o parametro Mv_LjTxNFe = 3 gera error log por nao existir o objeto de impressao A4
If Type("oSetup") == "O" .and. oSetup:GetProperty(PD_ORIENTATION) <> 1
		//DANFE modo Paisagem - DANFEIII.PRW			
	cRdMake := iif( ExistFunc("U_DANFE_P1"), "U_DANFE_P1", "DANFE_P1")
EndIf

if ExistFunc(cRdMake)
	if lPos
		STFCleanInterfaceMessage()
		STFMessage("STWFINISHSALE", "ALERT", STR0163 ) //#"Monitorando Retorno da NF-e na SEFAZ!"
		STFShowMessage( "STWFINISHSALE" )
	else
		//atribui o valor maximo da primeira barra de progresso
		oProcess:SetRegua1( nTentativa )
	endif

	//-- No controle de autrizacao utlizando retorno do TSS com a grava็ใpo no campo L1_RETSFZ, 
	//-- assim evitando que o usuario tenha que esperar terminar o tempo quando tiver um retorno de negativa na autorizacao pela SEFAZ 
	aNotas := {}
	aadd(aNotas, cSerie)
	aadd(aNotas, cDoc)
	aadd(aNotas, cDoc)
	

	For nI := 1 to nTentativa
		if lPos		
			STFMessage("STWFINISHSALE", "ALERT", STR0164 + " [" + StrZero(nI,3) + " de " + StrZero(nTentativa,3) + "] " ) //#"Consultando Retorno SEFAZ "
			STFShowMessage( "STWFINISHSALE" )
		else
			//incrementa a primeira barra de progresso
			oProcess:IncRegua1(STR0064 + cValToChar(nI) + " / " + cValToChar(nTentativa))	//"Tentativa "
		
			//atribui o valor maximo da segunda barra de progresso
			oProcess:SetRegua2( nIntervalo )
	
			If oProcess:lEnd
				MsgInfo(STR0066, "DANFE CANCELADA")	//"Impressใo do DANFE cancelada pelo usuแrio"
				Exit
			EndIf
		endif

		//-- Analise de Autorizacao
		
		//-- Retorno vetor de 2 posicoes: 
		//--[1] 1= aprovado; 2=nao aprovado; 3=Aguardando
        aInfMonNFe := ProcMonitorDoc(cIdEnt , AllTrim( SuperGetMv("MV_SPEDURL",,"") )   ,; 
        		 					 aNotas , 1 /*nTpMonitor*/                          , "55" /*cModelo*/, .F. /*lCte*/, @cRetSFZ)
		nX := len(aInfMonNFe)

		if nX == 0
        	LjGrvLog(SL1->L1_NUM, I18n("LOJNFCE: SEFAZ nใo retorno nada, na fun็ใo ProcMonitorDoc() - Tentativa: #1", {nI}), aNotas)
            LjGrvLog(SL1->L1_NUM, "LOJNFCE: Aviso da ProcMonitorDoc()", cRetSFZ)
			//-- Normalmente quando o TSS esta desatualizado (exemplo as tags novas)
			//-- ou erro na tag tipo com problema tipo aspas
			Loop
		endif

		cAutoriza   := aInfMonNFe[nX][17][01]
		cChaveNFe   := Substr(aInfMonNFe[nX][17][02], At('Id="NFe',aInfMonNFe[nX][17][02])+7, 44 )
		DAutNFe		:= aInfMonNFe[nX][17][06]
		HAutNFe		:= aInfMonNFe[nX][17][05]
		cXmlFsda	:= aInfMonNFe[nX][17][02]

		nModFsda := IIF(Len(aInfMonNFe[nX]) >= 8 .AND. ValType(aInfMonNFe[nX][08]) == "N", aInfMonNFe[nX][08], 0)

		//-- Pego em simulacao que se tiver com doc/serie retroativos e autorizados no TSS
		//-- nao gerar erro de duplicidade de nota simplesmente finaliza a venda normalmente com 
		//-- com o protocolo da nota anterior ficando itens divergente do XML autorizado na SEFAZ
		if !Empty(cAutoriza) .and. DAutNFe <> Date()
			cCodRetNFE	:= "539"
			cMsgRetNFE	:= "Rejei็ใo 539: Duplicidade de NF-e, com diferen็a na Chave de Acesso"
			
		elseif Left( aInfMonNFe[nX][09], 3) == "002"
			cCodRetNFE	:= "999"
			cMsgRetNFE	:= aInfMonNFe[nX][09]
		
			//-- Quando nao tem retorno pelo TSS, muito provavel que foi negado por uma valida็ใo de schema
			SPEDNFEXML(cIdEnt, ( cDoc + cSerie ), 2 /*nTipo*/, .F. /*lUsaColab*/, "55" /*cModelo*/)
			
		else
			cCodRetNFE	:= aInfMonNFe[nX][05]
			cMsgRetNFE	:= AllTrim(aInfMonNFe[nX][06])
		
			if len(aInfMonNFe[nX]) >= 9 .and. !Empty(aInfMonNFe[nX][09])
				cMsgRetNFE	:= AllTrim(aInfMonNFe[nX][09])
			endif

		endif

		LjGrvLog( SL1->L1_NUM," LOJNFCE:LjProcDNFe: Retorno SEFAZ ", cCodRetNFE + "  " + SL1->L1_DOC +"/" + SL1->L1_SERIE )  //Gera LOG
	
		if !Empty(cCodRetNFE) .or. !Empty(cMsgRetNFE)
			cRetSFZ := cAutoriza + "|" + cCodRetNFE + "|" + cMsgRetNFE
		else
			cRetSFZ := ""
		endif

		if SL1->L1_DOC + SL1->L1_SERIE == cDoc + cSerie .AND. SL1->L1_KEYNFCE <> cChaveNFe .or. SL1->L1_RETSFZ <> cRetSFZ
			RecLock("SL1")
				SL1->L1_KEYNFCE := cChaveNFe
				SL1->L1_RETSFZ	:= cRetSFZ
			SL1->( MsUnLock() )
		endif

		//grava a chave para transmitir para a retaguarda
		SF2->( DbSetOrder(1) )
		If SF2->( DbSeek( xFilial("SF2") + cDoc + cSerie ) ) .and. !Empty(cChaveNFe) .and. SF2->F2_CHVNFE <> cChaveNFe
	
			RecLock("SF2")
				SF2->F2_CHVNFE := cChaveNFe
			SF2->( MsUnLock() )
	
		Endif

		// verifica se houve erro de schema da SEFAZ
		if LjRetStatusSEFAZ(cCodRetNFE, cMsgRetNFE) $ "R"

			LjGrvLog( SL1->L1_NUM," LOJNFCE:LjProcDNFe: Retorno SEFAZ 2 Validacao ", cCodRetNFE + "  " + SL1->L1_DOC +"/" + SL1->L1_SERIE )  //Gera LOG
			Aviso("Codigo Erro da SEFAZ", cMsgRetNFE, {"OK"})

		elseif LjRetStatusSEFAZ(cCodRetNFE) $ "P" .AND. nModFsda <> 7
			LjGrvLog( SL1->L1_NUM," LOJNFCE:LjProcDNFe: cAutoriza esta vazio nao imprime Danfinha!", SL1->L1_DOC +"/" + SL1->L1_SERIE )  //Gera LOG

		endif

		//-- Chama funcao para retorno em string
		if ExistFunc("LjCodDeneg") .and. cCodRetNFE $ LjCodDeneg(1)[01]

			LjGrvLog( SL1->L1_NUM,"LOJNFCE:LjProcDNFe: NOTA DENEGADA! Doc: ", SL1->L1_DOC + "/" + SL1->L1_SERIE )  //Gera LOG
			Conout("LOJNFCE:LjProcDNFe: NOTA DENEGADA! Doc: " + SL1->L1_FILIAL + "/" + SL1->L1_DOC + "-" + SL1->L1_SERIE + " " + Time() )

		endif

		//-- Se for Autorizado ou Rejeitacao de Schema, tem que sair para nao ficar no LOOP
		if LjRetStatusSEFAZ(cCodRetNFE,cMsgRetNFE) == "R"
	
			if lPos
				STFMessage("STWFINISHSALE", "ALERT", "DANFE nao Autorizado pela SEFAZ!" )
				STFShowMessage( "STWFINISHSALE" )
			else
				MsgAlert("DANFE nao Autorizado pela SEFAZ!")
			endif

			LjGrvLog( SL1->L1_NUM,"LOJNFCE:LjProcDNFe: DANFE nao Autorizado pela SEFAZ!", SL1->L1_DOC +"/" + SL1->L1_SERIE )  //Gera LOG

			//-- Sai do Loop Autorizacao
			Exit
		
		elseif (LjRetStatusSEFAZ(cCodRetNFE) == "A") .OR. (nModFsda == 7 .AND. !Empty(cXmlFsda))

			//
			// Bloco de Impressao
			//
			if lPos
				STFMessage("STWFINISHSALE", "ALERT", STR0165 ) //"Aguarde.. Imprimindo DANFE NF-e ..."
				STFShowMessage( "STWFINISHSALE" )
			endif

			LjGrvLog( SL1->L1_NUM,"LOJNFCE:LjProcDNFe: DANFE Autorizado pela SEFAZ!", SL1->L1_DOC +"/" + SL1->L1_SERIE )  //Gera LOG

			//-- Realiza Impressao quando autorizado em A4
			if xMvLjTxNFe == 2

				LjGrvLog( SL1->L1_NUM," Realiza a impressใo do DANFE",  )

				If cRdMake == "U_PRTNFESEF"
					lExistNFe := U_PrtNFeSEF(cIDEnt, Nil, Nil, oDANFE, oSetup, cFilePrint, lLoja)
				ElseIf cRdMake == "U_DANFE_P1"
					lExistNFe := U_DANFE_P1(cIDEnt, Nil, Nil, oDANFE, oSetup, lLoja)
				Else
					lExistNFe := U_PrtNFeSEF(cIDEnt, lLoja)
				EndIf
	
			//-- Emissao na impressora nao fiscal (Danfinha)
			elseif xMvLjTxNFe == 3
				
				cXmlProt := '<protNFe xmlns="http://www.portalfiscal.inf.br/nfe" versao="4.00"><infProt><tpAmb>2</tpAmb><verAplic>GO4.0</verAplic>'
				cXmlProt += '<chNFe>' + cChaveNFe + '</chNFe><dhRecbto>' + Transform(dtos(DAutNFe), "@R 9999-99-99")+"T"+HAutNFe + '</dhRecbto><nProt>' + cAutoriza + '</nProt>'
				cXMLProt += '<digVal>OSlFyu3mQYgmhZWEXP1kwu3BXTI=</digVal><cStat>' + cCodRetNFE + '</cStat><xMotivo>' + cMsgRetNFE + '</xMotivo></infProt></protNFe>'

				if ExistFunc("U_LjRDnfNfce")  //Tivemos problema devido ao IXBLOG, portanto chame como U_XXX

					lExistNFe := U_LjRDnfNfce( aInfMonNFe[nX][17][02], cXMLProt, cChaveNFe, .T., Nil, Substr(cChaveNFe,21,2) == "55" )
			
				else
					lExistNFe := LjNFCeDANFE( aInfMonNFe[nX][17][02], cXMLProt, cChaveNFe, .T., Nil, Substr(cChaveNFe,21,2) == "55" )
			
				endif

			endif

			//-- Sai do Loop Apos Autorizacao
			Exit

		ElseIf nI == nTentativa

			if lPos
				//Pergunta para evitar o numero de inutiliza็๕es e problemas com cartoes
				STFMessage("STWFINISHSALE", "YESNO", STR0067 + chr(10) + chr(13) + "Deseja tentar novamente?")   
				if STFShowMessage("STWFINISHSALE")

					LjGrvLog( SL1->L1_NUM,"LOJNFCE:LjProcDNFe: Usuario optou em tentar novamente verificar retorno na SEFAZ: ", SL1->L1_DOC +"/" + SL1->L1_SERIE )  //Gera LOG
					nI := 0
					Loop
				endif
			else
				MsgAlert(STR0067, "RETORNO SEFAZ") //"A impressใo do DANFE nใo foi realizada, pois ainda nao houve retorno da SEFAZ."
			endif

			LjGrvLog( SL1->L1_NUM,"LOJNFCE:LjProcDNFe: " + STR0067, SL1->L1_DOC +"/" + SL1->L1_SERIE )  //Gera LOG
			Exit //se a NF-e nao foi autorizada, abortamos o processo

		endif

		if lPos
			Sleep( nPausa * 1000 )
		else
			For nX := nIntervalo to 1 Step -1

				oProcess:IncRegua2( STR0065 + cValtoChar(nX) + "s" ) //"Tentando novamente em "			
				Sleep( nPausa *1000 )

			Next nX

		endif

	Next nI

Else
	MsgAlert(STR0104 + IIF(cRdMake == "U_PRTNFESEF", "DANFEII.PRW", "DANFEIII.PRW")+ STR0105, "ERRO DANFE") 
	//"O rdmake " ##" nใo estแ presente no reposit๓rio. Portanto, a impressใo da DANFE nใo serแ realizada."
EndIf

Return Nil


/*/{Protheus.doc} LjTpFrete
Retorna o tipo do Frete (CIF ou FOB)
@type		function
@param		cTpFrete Tipo do Frete
@author  	michael.gabriel
@version 	P11.80
@since   	30/05/2017
@return  	cTipoFrete
/*/
Static Function LjTpFrete( cTpFret )

Local cTipoFrete	:= ""
Local nPosHeader	:= 0	// posicao do campo L2_VALFRE no "aHeader" presente no aItensNFCe
Local nPosCols		:= 0	// posicao do item o qual contem um valor de frete (L2_VALFRETE)

Default cTpFret		:= ""

// verifica se os itens ja estao carregados
If Len(aItensNFCe) > 1

	//procura a posicao do campo L2_VALFRE no "aHeader"	
	nPosHeader := aScan( aItensNFCe[1], {|x| x == "L2_VALFRE"} )
	//verifica se algum item possui valor de frete
	If nPosHeader > 0	
		nPosCols := aScan( aItensNFCe, {|x| x[nPosHeader] > 0}, 2 )
	EndIf

EndIf

// Se houver algum item com frete
// Ou aso a venda nใo possua valor de frete mas o tipo for CIF ou pago pelo Rementente a TAG <transp> deve ser gerada
If nPosCols > 0 .OR. ( nPosCols == 0 .AND. AllTrim(cTpFret) $ "C/R" )
	If cTpFret $ "S|0"
		cTipoFrete := "S"	//Sem Frete
	ElseIf cTpFret $ "C|1"
		cTipoFrete := "C"	//CIF
	ElseIf cTpFret $ "F|2"
		cTipoFrete := "F"	//FOB
	ElseIf cTpFret $ "T|3"
		cTipoFrete := "T"	//Terceiros
	ElseIf cTpFret $ "R|4"
		cTipoFrete := "R"	//Pr๓prio Remetente
	ElseIf cTpFret $ "D|5"
		cTipoFrete := "D"	//Pr๓prio Destinatแrio
	EndIf
Else
	cTipoFrete := "S" 
EndIf

Return cTipoFrete


/*/{Protheus.doc} LjVEndDest
Valida se os dados do cadastro do cliente esta apto para gerar a tag <enderDest>
@type		function
@param		lFrete Indica se Entrega a Domicilio
@param		cCliente Codigo do Cliente a ser validado
@param		cLoja Codigo da Loja a ser validado
@author  	michael.gabriel
@version 	P11.80
@since   	31/05/2017
@return  	cTexto
/*/
Static Function LjVEndDest( cCliente, cLoja )

Local cX3Titulo		:= ""	//titulo do campo no SX3
Local cCamposErr	:= ""	//campos que nao estao preenchidos
Local nI			:= 0
Local aSA1			:= {}
Local aAreaSA1		:= SA1->( GetArea() )
Local aRet			:= {.T., {}, ""}	//[1](L):Informacao Validada [2](A):Codigo e Loja [3](C):campos nao preenchidos

Default cCliente	:= ""
Default cLoja		:= ""

If SA1->( DbSeek(xFilial("SA1") + cCliente + cLoja) )

	Aadd( aSA1, {SA1->A1_END		, "A1_END"		} )
	Aadd( aSA1, {SA1->A1_BAIRRO		, "A1_BAIRRO"	} )
	Aadd( aSA1, {SA1->A1_EST		, "A1_EST"		} )
	Aadd( aSA1, {SA1->A1_COD_MUN	, "A1_COD_MUN"	} )

	//verificamos se todos os campos necessarios para a tag <enderDest> estใo preenchidos
	For nI := 1 to Len(aSA1)
		If Empty( aSA1[nI][1] )
			cX3Titulo := AllTrim( GetSX3Cache(aSA1[nI][2], "X3_TITULO") )
			cCamposErr += "* " + cX3Titulo + " (" + aSA1[nI][2] + ")" + CRLF
		EndIf
	Next
EndIf

//verifica se algum campo necessario do SA1 nao esta preenchido
If !Empty(cCamposErr)
	aRet[1] := .F.	
	aRet[2] := {SA1->A1_COD, SA1->A1_LOJA, SA1->A1_NOME}
	aRet[3] := cCamposErr 
EndIf

RestArea(aAreaSA1)
aSize(aSA1, 0)

Return aRet

/*/{Protheus.doc} LjColsItem
Carrega o array estatico aItensNFCe com os itens que estarao presentes no arquivo eletronico
@param   cL1Filial Filial do Orcamento
@param   cL1Num	Numero do Orcamento
@type		function
@author  	michael.gabriel
@version 	P11.80
@since   	05/06/2017
/*/
Static Function LjColsItem( cL1Filial, cL1Num , lIsNfe)
Local cTipoItem		:= "_ICMS"							// tipo do item (ICMS ou ISSQN)
Local cAliasSBx		:= ""
Local cUltItem		:= "" 								// ultimo item processado
Local lSIGALOJA		:= NMODULO == 12					// verifica se o m๓dulo ้ SIGALOJA, pois no SIGAFRT nใo ้ necessแrio proporcionalizar as formas de pagamento
Local lPOS			:= Iif(ExistFunc("STFIsPOS"), STFIsPOS(), .F.)
Local lItemGE		:= .F.								// indica se o item ้ do tipo Garantia Estendida
Local lItemSF		:= .F.								// indica se o item ้ do tipo Servi็o Financeiro
Local aAreaSBx		:= {}								// armazena a area do cadastro de produto (SB1 ou SBI)
Local aAreaSL2		:= SL2->(GetArea())					// armazena a area do SL2
// variaveis relacionadas a Dicionario de Dados
Local cMvLjTpGar	:= SuperGetMV("MV_LJTPGAR",,"GE")	//Tipo do produto Garantia Estendida
Local cMvLjTpSF		:= SuperGetMV("MV_LJTPSF",,"SF")			//Tipo do produto Servi็o financeiro
Local nTmB1Tipo		:= 0
Local lMvLjPrdSv	:= SuperGetMv("MV_LJPRDSV",,.F.)	// verifica se esta ativa a implementacao de venda com itens de "produto" e itens de "servico" em Notas Separadas
Local lMvNFCeCnj	:= SuperGetMV("MV_NFCECNJ",,.F.)	// indica se usa NFC-e conjugada
Local lCamposISS	:= .F.								// veririca se existe os campos para trabalhar com ISS
Local lItemRps		:= .F.
Local lDescICM		:= SL2->(ColumnPos("L2_DESCICM")) > 0  

Default cL1Filial	:= ""
Default cL1Num		:= ""
Default lIsNfe		:= .F.

If NMODULO == 23 .AND. !lPos
	aAreaSBx := SBI->( GetArea() )
	cAliasSBx := "SBI"
	SBI->( DbSetOrder(2) ) //BI_FILIAL + BI_TIPO + BI_COD
Else
	aAreaSBx := SB1->( GetArea() )
	cAliasSBx := "SB1"
	SB1->( DbSetOrder(2) ) //B1_FILIAL + B1_TIPO + B1_COD
EndIf

//verifica se existe os campos para trabalhar com ISS
lCamposISS :=	SL2->(ColumnPos("L2_BASEISS")) > 0 .AND. SL2->(ColumnPos("L2_ALIQISS")) > 0 .AND. ;
				SL2->(ColumnPos("L2_VALISS")) > 0 .AND. SL2->(ColumnPos("L2_CODISS")) > 0

LjGrvLog( cL1Num, "MV_LJPRDSV - RPS: ", lMvLJPRDSV )
LjGrvLog( cL1Num, "MV_NFCECNJ - NFC-e Conjugada: ", lMvNFCeCnj )
LjGrvLog( cL1Num, "SL2 possui os campos ALIQISS/BASEISS/VALISS/CODISS", lCamposISS )

//Tratamento para o campo B1_TIPO
nTmB1Tipo := GetSx3Cache("B1_TIPO","X3_TAMANHO")
cMvLjTpGar := PadR(cMvLjTpGar, nTmB1Tipo)
cMvLjTpSF := PadR(cMvLjTpSF, nTmB1Tipo)

SL2->( DbSetOrder(1) )	//L2_FILIAL + L2_NUM
If SL2->( DbSeek(cL1Filial + cL1Num) )

	While SL2->(!EoF()) .AND. SL2->L2_FILIAL + SL2->L2_NUM == cL1Filial + cL1Num

		If SL2->L2_SITUA == "05"
			LjGrvLog( SL1->L1_NUM, "Item: |" + SL2->L2_ITEM + "| Produto |" + SL2->L2_PRODUTO + "| IT IGNORADO: EXCLUIDO" )
			SL2->( DbSkip() )
			Loop
		ElseIf Rtrim(cUltItem) == RTrim(SL2->L2_ITEM)			
			LjGrvLog( SL1->L1_NUM, "Item: |" + SL2->L2_ITEM + "| Produto |" + SL2->L2_PRODUTO + "| IT IGNORADO: JA PROCESSADO" )
			SL2->( DbSkip() )
			Loop
		EndIf

		//Verifica se o item ้ do tipo Servico
		If lCamposISS .AND. (lMvLjPrdSv .OR. lMvNFCeCnj)
			cTipoItem := LJTipoItem()
		EndIf
		
		If cTipoItem == "_RPS"
			lItemRps := .T.
			LJTotNaoFi( Nil, Nil, lItemRps)
			SL2->( DbSkip() )
			Loop
		Else
			lItemRps := .F.
		EndIf

		lItemGE := &(cAliasSBx)->( MsSeek(xFilial(cAliasSBx) + cMvLjTpGar + SL2->L2_PRODUTO) )

		If !lItemGE
			lItemSF := &(cAliasSBx)->( MsSeek(xFilial(cAliasSBx) + cMvLjTpSF + SL2->L2_PRODUTO) )
		EndIf

		If !lItemGE .AND. ;									  		//item que nใo ้ Garantia Estendida
		!lItemSF .AND. ; 									  		//item que nใo ้ Servi็o Financeiro
		( (SL2->L2_ENTREGA == '1' .AND. !Empty(SL1->L1_ORCRES) ) ;	//item de or็amento filho de Retira Posterior
		.OR. SL2->L2_ENTREGA == '2' .OR. Empty(SL2->L2_ENTREGA) )	//item de or็amento Retira

			Aadd( aItensNFCe, { cTipoItem		,;	//tipo do item (ICMS ou ISSQN)
							 	SL2->L2_FILIAL	,;
							 	SL2->L2_NUM		,;
							 	SL2->L2_ITEM	,;
							 	SL2->L2_PRODUTO	,;
							 	SL2->L2_VALFRE	,;
							 	SL2->( Recno() ),;
								""				,; 	//Campo F4_AGREG - para desonera็ใo
								IIf(lDescICM ,SL2->L2_DESCICM,0)})   //Campo com o valor do item da desonera็ใo

			If lPos .OR. ( ( lSIGALOJA .Or. lIsNfe ) .AND. !Empty(SL2->L2_GARANT) )
				LjTotNaoFi( Nil, lItemGE, lItemRps )
			EndIf

			// ultimo item processado
			cUltItem := SL2->L2_ITEM
		Else
			LjTotNaoFi(Nil, lItemGE)
		EndIf

		SL2->( DbSkip() )
	End
EndIf

RestArea(aAreaSBx)
RestArea(aAreaSL2)

Return Nil


/*/{Protheus.doc} LjTipoItem
Identifica o tipo do item (ICMS, ISSQN ou RPS)
@type		function
@author  	michael.gabriel
@version 	P11.80
@since   	05/06/2017
@return  	cRet Retorna o tipo do item
/*/
Static Function LjTipoItem()

Local cRet			:= "_ICMS"
Local lMvLjPrdSv	:= SuperGetMv("MV_LJPRDSV",,.F.)	// verifica se esta ativa a implementacao de venda com itens de "produto" e itens de "servico" em Notas Separadas
Local lMvNFCeCnj	:= SuperGetMV("MV_NFCECNJ",,.F.)	// indica se usa NFC-e conjugada
Local lItemISS		:= .F.

/*
	Tratamento para RPS ou NFC-e Conjugada
*/
If lMvLjPrdSv .OR. lMvNFCeCnj

	lItemISS := LjIsTESISS(SL1->L1_NUM, SL2->L2_TES)

	If lItemISS
		// tratamento para RPS
		If lMVLJPRDSV

			// no SIGAFRT, somente ้ possํvel vender servico (RPS) com orcamentos importados
			If NMODULO == 23
				lITemISS := !Empty(SL1->L1_NUMORIG)  .Or. (ExistFunc("Lj7RPSNew") .And. Lj7RPSNew())
			EndIf

			// se for Item com RPS, ele nao ้ considerado na NFC-e
			If lItemISS
				cRet := "_RPS"
			Else
				LjGrvLog( SL1->L1_NUM, "Item: |" + SL2->L2_ITEM + "| Produto |" + SL2->L2_PRODUTO + "| ERRO: RPS COM ORCAMENTO NAO IMPORTADO")
			EndIf

		// tratamento para NFC-e conjugada (ICMS + ISSQN)
		ElseIf lMvNFCeCnj
			lItemISS := .T.
			cRet := "_ISSQN"

		// considera item de ICMS
		Else
			LjGrvLog( SL1->L1_NUM, "Item: |" + SL2->L2_ITEM + "| Produto |" + SL2->L2_PRODUTO + "| ERRO: SERVICO SEM RPS OU NFC-E CONJUGADA")
		EndIf
	EndIf

EndIf

LjGrvLog( SL1->L1_NUM, "Item: |" + SL2->L2_ITEM + "| Produto |" + SL2->L2_PRODUTO + "| _status: " + cRet)

Return cRet


/*/{Protheus.doc} LjHeaderIt
Carrega os campos que farao parte do array estatico aItensNFCe
@type		function
@author  	michael.gabriel
@version 	P11.80
@since   	05/06/2017
@return  	aItensNFCe
@obs		Ao alterar os campos dessa funcao, deve se alterar a funcao LjColsItem
/*/
Static Function LjHeaderIt()

Local aAux := {} 

aAux := {{"_TIPO"	,;	//usado somente para identificacao do tipo do produto
		"L2_FILIAL"	,;
		"L2_NUM"	,;
		"L2_ITEM"	,;
		"L2_PRODUTO",;
		"L2_VALFRE"	,;
		"R_E_C_N_O_",;
		"F4_AGREG"  ,;
		"L2_DESCICM"}}

// alimentamos o array estatico aItensNFCe
aItensNFCe := aClone(aAux)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} LjObgCpVen
Valida a obrigatoriedade da impressใo do comprovante de venda NFC-e.
@author  eduardo.sales
@since   27/12/2017
@version P12
/*/
//-------------------------------------------------------------------
Function LjObgCpVen(aMensagem)

Local lRet			:= .F.
Local cMVNFCEIMP	:= SuperGetMV("MV_NFCEIMP",,1)

Default aMensagem	:= {}

If cMVNFCEIMP == 2
	aMensagem := Array(3)
	aMensagem[1] := STR0101	// "Finaliza็ใo de Venda nใo realizada."
	aMensagem[2] := STR0102 + Chr(10) + STR0103	// "Verifique se a impressora estแ ligada e conectada." + "O parโmetro MV_NFCEIMP estแ configurado com 2, o que obriga a impressใo da NFC-e."
	aMensagem[3] := STR0009 // "OK"

	lRet := .T.
EndIf

Return lRet

/*/
{Protheus.doc} LjNFCeWTot
Alimenta o array estatico aNFCeW02 basaeado no leiaute da NT
@type		function
@param   	cGrupoTot  - Grupo Totalizador
@author  	michael.gabriel
@version 	P11.80
@since   	23/06/2017
/*/
Static Function LjNFCeWTot(cGrupoTot)

Local aGrupoTot := {}

Default cGrupoTot := "ICMSTOT"

If cGrupoTot == "ICMSTOT"
	//ICMSTot
	aGrupoTot := Array(15)

	aGrupoTot[01] := 0			//vBC - W03
	aGrupoTot[02] := Array(6)
	aGrupoTot[02][1] := 0		//vICMS - W04
	aGrupoTot[02][2] := 0		//vICMSDeson - W04a
	aGrupoTot[02][3] := 0		//vFCP- W04b
	aGrupoTot[02][4] := 0		//vFCPUFDest - W04c
	aGrupoTot[02][5] := 0		//vICMSUFDest - W04e
	aGrupoTot[02][6] := 0		//vICMSUFRemet - W04g
	aGrupoTot[03] := 0			//vBCST - W05
	aGrupoTot[04] := Array(3)	
	aGrupoTot[04][1] := 0		//vST - W06
	aGrupoTot[04][2] := 0		//vFCPST - W06a
	aGrupoTot[04][3] := 0		//vFCPSTRet - W06b
	aGrupoTot[05] := 0			//vProd - W07
	aGrupoTot[06] := 0			//vFrete - W08
	aGrupoTot[07] := 0			//vSeg - W09
	aGrupoTot[08] := Array(2)
	aGrupoTot[08][1] := 0		//vDesc item - W10	
	aGrupoTot[08][2] := 0		//vDesc proporcional - W10
	aGrupoTot[09] := 0			//vII -W11
	aGrupoTot[10] := Array(2)
	aGrupoTot[10][1] := 0		//vIPI - W12
	aGrupoTot[10][2] := 0		//vIPIDevol - W12a
	aGrupoTot[11] := 0			//vPIS -W13
	aGrupoTot[12] := 0			//vCOFINS - W14
	aGrupoTot[13] := 0			//vOutro - W15
	aGrupoTot[14] := Array(2)
	aGrupoTot[14][1] := 0		//vNF - W16
	aGrupoTot[14][2] := Array(4)	
	aGrupoTot[14][2][1]	:= 0 	//vTotTrib - W16a
	aGrupoTot[14][2][2]	:= 0
	aGrupoTot[14][2][3]	:= 0
	aGrupoTot[14][2][4]	:= 0
	aGrupoTot[15] := Array(6)	//Grupo W - NT 001.2023
	aGrupoTot[15][1]	:= 0 	//qBCMono – Valor total da quantidade tributada do ICMS monofasico proprio;
	aGrupoTot[15][2]	:= 0	//vICMSMono – Valor total do ICMS monofasico proprio;
	aGrupoTot[15][3]	:= 0	//qBCMonoReten – Valor total da quantidade tributada do ICMS monofasico sujeito a retencao;
	aGrupoTot[15][4]	:= 0	//vICMSMonoReten – Valor total do ICMS monofasico sujeito a retencao;
	aGrupoTot[15][5]	:= 0	//qBCMonoRet – Valor total da quantidade tributada do ICMS monofasico retido anteriormente;
	aGrupoTot[15][6]	:= 0	//vICMSMonoRet – Valor total do ICMS monofasico retido anteriormente.

Else
	//ISSQNTot
	aGrupoTot := Array(5)

	aGrupoTot[01] := 0		//vServ - W18	
	aGrupoTot[02] := 0		//vBC - W19
	aGrupoTot[03] := 0		//vISS - W20
	aGrupoTot[04] := 0		//vPIS - W21
	aGrupoTot[05] := Array(8)
	aGrupoTot[05][1] := 0	//vCOFINS - W22
	aGrupoTot[05][2] := 0	//dCompet - W22a
	aGrupoTot[05][3] := 0	//vDeducao - W22b
	aGrupoTot[05][4] := 0	//vOutro - W22c
	aGrupoTot[05][5] := 0	//vDescIncond - W22d
	aGrupoTot[05][6] := 0	//vDescCond - W22e
	aGrupoTot[05][7] := 0	//vISSRet - W22f
	aGrupoTot[05][8] := 0	//cRegTrib - W22g
EndIf

Return aGrupoTot


/*/
{Protheus.doc} NT2016002
Valida a versao da NFC-e retornada do TSS
@type		function
@author  	michael.gabriel
@version 	P11.80
@since   	22/06/2017
@return  	lRet
/*/
Static Function NT2016002()

Local cMensagem		:= ""
Local cMvAmbNFCe	:= ""
Local cMvVerNFCe	:= ""
Local lRet			:= .F.
Local aGetMvTSS		:= {}

//Obtemos a VERSAO da NFC-e do TSS
aGetMvTSS := LjGetMVTSS("MV_VERNFCE")
If aGetMvTSS[1]
	cMvVerNFCe := AllTrim(aGetMvTSS[2])
EndIf
	
//Obtemos o AMBIENTE da NFC-e do TSS
aGetMvTSS := LjGetMVTSS("MV_AMBNFCE","1")
If aGetMvTSS[1]
	cMvAmbNFCe := SubStr(aGetMvTSS[2], 1, 1)
EndIf

If Empty(cMvVerNFCe)
	cMensagem := "Versใo da NFC-e nใo configurada."
	cMensagem += (CRLF + "Por favor, altere a Versใo da NFC-e no servidor TSS:")
	cMensagem += (CRLF + "Venda Assistida (LOJA701) > A็๕es Relacionadas > NFC-e > Parโmetros > Versใo NFC-e")

ElseIf cMvVerNFCe >= "4.00"
	lRet := .T.

ElseIf cMvVerNFCe == "3.10"
	lRet := .T.

Else
	cMensagem := "Versใo de NFC-e invแlida."
	cMensagem += (CRLF + "Por favor, altere a versใo da NFC-e no servidor TSS:")
	cMensagem += (CRLF + "Venda Assistida (LOJA701) > A็๕es Relacionadas > NFC-e > Parโmetros > Versใo NFC-e")
EndIf

If !lRet .AND. !isBlind()
	Aviso( "NT 2016.002", cMensagem, {"Ok, Entendi"}, 2 )
EndIf

Return lRet


/*/
{Protheus.doc} LjNFCeMod9
Verifica se a UF permite emissao de NFC-e em Contingencia
@type		function
@author  	michael.gabriel
@version 	P11.80
@since   	22/06/2017
@return  	lRet
/*/
Static Function LjNFCeMod9()

Local cMvModNFCe:= ""	//Modalidade de Operacao do NFC-e
Local cMsgErro	:= ""
Local lRet		:= .T.
Local aAnaliLeg := {}
Local aGetMvTSS	:= {}
			
//Verifica se a UF permite emissao de NFC-e na modalidade 9-Conting๊cia Offline
aAnaliLeg := LjAnalisaLeg(76)

If aAnaliLeg[1]

	aGetMvTSS := LjGetMVTSS("MV_MODNFCE")
	If aGetMvTSS[1]
		cMvModNFCe := SubStr( aGetMvTSS[2], 1, 1 )
		If cMvModNFCe == "2"
			cMvModNFCe := "9"
		EndIf

		If cMvModNFCe == "9"
			lRet := .F.

			cMsgErro := "A VENDA NAO SERม CONCLUอDA. Sem conexใo para emissใo de Nota Fiscal(NFC-e)." + Replicate(CRLF,2)
			cMsgErro += "Solu็ใo: " + aAnaliLeg[5] + Replicate(CRLF,2)
			cMsgErro += "Entre em contato com o Administrador do Sistema"

			Aviso("", cMsgErro, {"Ok, Entendi"}, 3)
			LjGrvLog("", "Mensagem de Erro:", cMsgErro)
		EndIf
	Else
		lRet := .F.
	EndIf
EndIf			

Return lRet


/*/
{Protheus.doc} LjNFCeClr
Reseta as variaveis estaticas usadas na montagem do XML e na transmissao
@type		function
@author  	michael.gabriel
@version 	P11.80
@since   	23/06/2017
/*/
Function LjNFCeClr( nOpcao )

Default nOpcao := 1

//variaveis usadas at้ o fim da transmissao
If nOpcao == 1

	//resetamos a variavel com as Entidades carregadas
	If ValType( aIDEnt ) == "A"
		aSize( aIDEnt, 0 )
	EndIf

	//destruimos a variavel estatica com os valores do parametros do TSS
	If ValType( aMvTSS ) == "A"
		aSize( aMvTSS, 0 )
		aMvTSS := Nil
	EndIf

	//resetamos as variaveis estaticas do fonte LOJXFUNG.PRW
	LjxSetRGer()
	LjxSetRGar()

	//resetamos o vetor de totalizador nใo fiscal
	aTotNaoFis := {0,0,0}
//variaveis usadas at้ a montagem do XML
ElseIf nOpcao == 2

	If ValType( aNFCeW02 ) == "A"
		aSize( aNFCeW02, 0 )
	EndIf

	If ValType( aNFCeW17 ) == "A"
		aSize( aNFCeW17, 0 )
	EndIf

	If ValType( aICMSST ) == "A"
		aSize( aICMSST, 0 )
	EndIf
	
	If ValType( aItensNFCe ) == "A"
		aSize( aItensNFCe, 0 )
		aItensNFCe := Nil
	EndIf

	If ValType( aRefxFis ) == "A"
		LjSetRefFis({}) // Reseta o array aRefxFis
	EndIf
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} LjAbrImp
Valida a conexใo com a impressora 
@author  eduardo.sales
@since   12/04/2018
@version P12
/*/
//-------------------------------------------------------------------
Function LjAbrImp()

Local cEstacao		:= LjGetStation("CODIGO")
Local cImpressora	:= LjGetStation("IMPFISC") 
Local cPorta		:= LjGetStation("PORTIF")
Local cPdv			:= LjGetStation("PDV")
Local nHandle		:= 0
Local lRet			:= .F.
Local cCrLf			:= Chr(10)
Local cMensagem		:= ""

nHandle := INFAbrir(cImpressora, cPorta)

If nHandle == 0
	lRet := .T.
Else
	cMensagem := "Nใo foi possํvel conectar com a Impressora Nใo-Fiscal:"
	cMensagem += cCrLf + "- Modelo: " + cImpressora
	cMensagem += cCrLf + "- PDV: " + cPdv
	cMensagem += cCrLf + "- Esta็ใo: " + cEstacao
	cMensagem += cCrLf + cCrLf + "Verifique se a impressora estแ conectada ou se o atalho do SmartClient estแ devidamente configurado com o n๚mero de esta็ใo correta."
	
	MsgAlert(cMensagem, STR0003)
EndIf

Return lRet



//----------------------------------------------------------------------
/*/{Protheus.doc} LjNfceMsPr - Mensagem de Procedimentos ao Usuแrio
Orienta o usuแrio como proceder antes de ligar para o suporte: BLINDAGEM
@author  marisa.cruz
@since   03/05/2018
@version P12
/*/
//----------------------------------------------------------------------
Static Function LjNfceMsPr(cCodErro)

Local cMsg 		:= ""
Local cCrLf		:= Chr(10)

Default cCodErro := ""	//C๓digo do Erro da Rejei็ใo TSS

Do Case
Case cCodErro = "703"	;//"Rejeicao: Data-Hora de Emissao posterior ao horario de recebimento"
	.OR. ;
	cCodErro = "704"	//"Rejeicao: NFC-e com Data-Hora de emissao atrasada"

	cMsg := STR0108 + cCrLf + cCrLf		//"P R O C E D I M E N T O S"
	
	cMsg += STR0109 + cCrLf +;	//"- Verifique o parโmetro MV_NFCEUTC: O fuso horแrio estแ correspondente ao local fํsico, onde se encontra o Servidor TSS?" 
		 STR0110 + cCrLf +;		//"- Verifique se a data e hora desta esta็ใo (PDV) estใo corretos."
		  cCrLf +;
		 STR0111	//"Link do TDN - Desvendando o NFC-e: http://tdn.totvs.com/pages/releaseview.action?pageId=210055818"

EndCase

//Se houver mensagem, deixar dois espa็os em branco antes dos procedimentos para a exibi็ใo da mensagem
If !Empty(cMsg)
	cMsg := cCrLf + cCrLf + cMsg
EndIf

Return cMsg

//----------------------------------------------------------------------
/*/{Protheus.doc} LjNfceMsg
Mensagem de aviso da desativa็ใo da NFC-e 3.10
@author  eduardo.sales
@since   06/07/2018
@version P12
/*/
//----------------------------------------------------------------------
Function LjNfceMsg()

Local aGetMvTSS		:= {}
Local cMvVerNFCe	:= ""
Local cMsg			:= ""
Local dDate			:= CtoD("")										// Date()
Local dDtVerNfce	:= CtoD("30/09/2018")							// Data vigente para a NFC-e 3.10

dDate := Date()
	
// Obtem a VERSAO da NFC-e do TSS
aGetMvTSS := LjGetMVTSS("MV_VERNFCE")
If aGetMvTSS[1]
	cMvVerNFCe := AllTrim(aGetMvTSS[2])
EndIf

If cMvVerNFCe == "3.10"
	If dDate > dDtVerNfce
		cMsg := "Foi identificado que a versใo do Cupom Fiscal Eletronico(NFC-e) estแ desatualizada." + CHR(10) + CHR(13)
		cMsg += "Versใo da NFC-e utilizada: 3.10" + CHR(10)
		cMsg += "Versใo da NFC-e em vigor: 4.00" + CHR(10) + CHR(13)
		cMsg += "Favor atualizar a versใo do Cupom Fiscal Eletronico (NFC-e) caso contrแrio nใo serแ possํvel realizar vendas." + CHR(10) + CHR(13)
		cMsg += "Para mais informa็๕es consulte a documenta็ใo da NFC-e 4.0: http://tdn.totvs.com/pages/viewpage.action?pageId=329034164"
	ElseIf lShowMsg
		cMsg := "Foi identificado que o Cupom Fiscal Eletronico (NFC-e) estแ utilizando a versใo 3.10." + CHR(10) + CHR(13)
		cMsg += "A partir de 01/10/2018 serแ obrigat๓rio a utiliza็ใo da versใo 4.00 da NFC-e, pois em vers๕es anteriores ocorrerแ rejei็๕es na SEFAZ." + CHR(10) + CHR(13)
		cMsg += "Caso a versใo da NFC-e nใo seja atualizada at้ esta data, nใo serแ possํvel realizar vendas!" + CHR(10) + CHR(13)
		cMsg += "Para mais informa็๕es consulte a documenta็ใo da NFC-e 4.0: http://tdn.totvs.com/pages/viewpage.action?pageId=329034164"

		lShowMsg := .F.
	EndIf
EndIf

Return cMsg

//----------------------------------------------------------------------
/*/{Protheus.doc} LjGetPgNfe

Captura dos valores para incluir na NF-e, chamada pelo NFESEFAZ
@return  aRet, array, padrใo conforme TSS {cForma,Valor,Troco,Tp Integra, CGC Adm Cartao, Cod Bandeira, Autoriza็ใo TEF,cIndPag}
@author  julio.nery
@since   26/07/2018
@version P12
/*/
//----------------------------------------------------------------------
Function LjGetPgNfe(cVerAmb)
Local aRet		:= { .F. , {} }
Local aArea		:= {}
Local aDados	:= {}
Local nX		:= 0
Local cIdLog	:= "PAGTOS_NFE_LOJA"
Local aOrcs		:= {} 		//Array onde guarda a rela็ใo de Or็amentos que estใo atrelados ao mesmo DOC e SERIE, caso seja feito o faturado aglutinado de mais de 1 pedido
Local lIsNfCup	:= !Empty(SF2->F2_NFCUPOM) //Indica se ้ NF Sobre Cupom

Default	cVerAmb := "3.10"

LjGrvLog( cIdLog, "Inicio da Fun็ใo LjGetPgNfe - para obter pagamentos na transmissใo da NF-e de itens do LOJA" )

aTotNaoFis := {0,0,0}

Aadd(aArea,GetArea())

DbSelectArea("SL1")
DbSelectArea("SL2")
DbSelectArea("SL4")
DbSelectArea("SB1")
DbSelectArea("SBI")
DbSelectArea("SF2")

Aadd(aArea,SL1->(GetArea()))
Aadd(aArea,SL2->(GetArea()))
Aadd(aArea,SL4->(GetArea()))
Aadd(aArea,SB1->(GetArea()))
Aadd(aArea,SBI->(GetArea()))
Aadd(aArea,SF2->(GetArea()))

//Jแ vem posicionado do NFESEFAZ na SF2 
//Busca os Or็amentos que estใo atrelados a Nota (NF-e), seja por faturamento parcial ou Nota Sobre Cupom
aOrcs := LjOrcXDoc()

SL1->(DbSetOrder(1)) //L1_FILIAL+L1_NUM

For nX:=1 To Len(aOrcs)
	
	//Posiciona no Or็amento
	SL1->(DbSeek(xFilial('SL1') + aOrcs[nX]))

	LjGrvLog( cIdLog, " Inicio da captura dos dados de pagamentos nas tabelas SL1/SL2/SL4")
	LjGrvLog( cIdLog, " Antes da execu็ใo do LjHeaderIt - inicializa็ใo de algumas variแveis")
	LjHeaderIt()	//carrega os campos na primeira posicao do array
	LjGrvLog( cIdLog, " Depois da execu็ใo do LjHeaderIt ")
	
	LjGrvLog( cIdLog, " Antes da execu็ใo do LjColsItem ")
	LjColsItem( SL1->L1_FILIAL, SL1->L1_NUM , .T.)
	LjGrvLog( cIdLog, " Depois da execu็ใo do LjColsItem ")
	
	LjGrvLog( cIdLog, " Antes da execu็ใo do LjNFCePag ")
	LjNFCePag( .T. , @aDados, Nil, cVerAmb, lIsNfCup )
	LjGrvLog( cIdLog, " Depois da execu็ใo do LjNFCePag ")
	
	/* Zero todas as variแveis usadas	*/	
	
	If AllTrim(SF2->F2_ESPECIE) <> "NFCE" .OR. !Empty(SF2->F2_NFCUPOM)
		aItensNFCe := NIL
	EndIf
	
	aTotNaoFis := {0,0,0}
	
	LjGrvLog( cIdLog, " Final da captura dos dados de pagamentos - aDados ", aDados)

Next nX

If Len(aDados) > 0
	LjGrvLog( cIdLog, " Dados de pagamentos encontrados ")
	aRet[1] := .T.
	aRet[2] := aDados
EndIf

For nX:= Len(aArea) to 1 Step -1
	RestArea(aArea[nX])
Next nX

LjGrvLog( cIdLog, "Final da Fun็ใo LjGetPgNfe - para obter pagamentos na transmissใo da NF-e de itens do LOJA" )

Return aRet

//----------------------------------------------------------------------
/*/{Protheus.doc} LjNfcIndPg

Verifica o c๓digo de IndPag para NFC-e e NF-e
@return  cIndPag, string, retorna o indicador de pagamento
@author  julio.nery
@since   27/07/2018
@version P12
/*/
//----------------------------------------------------------------------
Static Function LjNfcIndPg(nRegSL4)
Local cIndPag := ""

do case
	case nRegSL4 == 1
		cIndPag	:= "0"	//0 = A Vista
	case nRegSL4 <= 0
		cIndPag	:= "2"	//2 = Outros
	otherwise
		cIndPag	:= "1"	//1 = A Prazo
endcase

Return cIndPag
//----------------------------------------------------------------------
/*/{Protheus.doc} LojRetFCP
Componente para retornar a aliquota/valor de FECP sem a majoracao.
@author  Rene Julian
@since   17/07/2018
@version P12
/*/
//----------------------------------------------------------------------
Static Function LojRetFCP(cVerNFE ,cTipo )
Local nRet       := 0
Local lVldCampos := IIf(SL2->(ColumnPos("L2_VALFECP")) > 0 .And. SL2->(ColumnPos("L2_ALQFECP")) > 0   , .T. , .F.)
Local cSitTrib   := ""

Default cVerNFE := "3.0"
Default cTipo   := ""   // P : Percentual / V : Valor 

If cTipo == "V"
	If cVerNFE >= "4.0" .And. lVldCampos 
		nRet := SL2->L2_VALICM - SL2->L2_VALFECP 
	Else
		nRet := SL2->L2_VALICM
	EndIf 
ElseIf cTipo == "P"
	cSitTrib := SL2->L2_SITTRIB
	If cVerNFE >= "4.0" .And. lVldCampos 
		If IsDigit( SubStr(cSitTrib, 1,1) )
			nRet := Val(cSitTrib) - SL2->L2_ALQFECP
		Else
			nRet := Val( SubStr(cSitTrib, 2, 2) + "." + SubStr(cSitTrib, 4, 2) ) - SL2->L2_ALQFECP
		EndIf
	Else
		If IsDigit( SubStr(cSitTrib, 1,1) )
			nRet := Val(cSitTrib)
		Else
			nRet := Val( SubStr(cSitTrib, 2, 2) + "." + SubStr(cSitTrib, 4, 2) )
		EndIf
	EndIf 
EndIf

Return nRet 

//----------------------------------------------------------------------
/*/{Protheus.doc} LjMonitora
Faz a consulta/monitoramento do documento no TSS e atualiza o STATUS do documento nas tabelas do TSS.

@param   cDoc	 N๚mero do Documento Fiscal
@param   cSerie	 S้rie do Documento Fiscal
@param   cModelo Modelo do Documento Fiscal
@author  Alberto Deviciente
@since   18/10/2018
@version P12
@return  L๓gico, Indica se executou com sucesso o Monitoramento do Documento Eletronico
/*/
//----------------------------------------------------------------------
Function LjMonitora( cDoc, cSerie, cModelo, cCodRetNF, cMsgRetNF )
Local lRet 			:= .F.
Local cIdEnt		:= ""
Local oWS			:= Nil
Local cMsgErro 		:= ""
Local oRetornoNF	:= {}
Local cURL			:= ""
	
If cModelo == "65"	//NFC-e
	cURL := SuperGetMV("MV_NFCEURL",,"")
ElseIf cModelo == "55" //NF-e
	cURL := SuperGetMV("MV_SPEDURL",,"")
EndIf

LjGrvLog( cDoc, "Efetua o monitoramento para atualizar o STATUS nas tabelas do TSS. DOC: ["+cDoc+"] Serie: ["+cSerie+"] Modelo: ["+cModelo+"] Entidade: ["+cIDEnt+"] URL: ["+cURL+"]" )

cIDEnt := LjTSSIDENT(cModelo)

If !Empty(cIdEnt)

	//Instancia o Web Service do TSS
	oWs:= WsNFeSBra():New()
	oWs:cUserToken  := "TOTVS"
	oWs:cID_ENT     := cIdEnt
	oWs:_URL        := AllTrim(cURL)+"/NFeSBRA.apw"
	oWs:cIdInicial 	:= cSerie + cDoc
	oWs:cIdFinal 	:= cSerie + cDoc
	oWs:cModelo 	:= cModelo
	
	lRet := oWs:MonitorFaixa()

	If ValType(lRet) <> "L"
		lRet := .F.
	EndIf
	
	LjGrvLog( cDoc, "Retorno do metodo MonitorFaixa do TSS. DOC: ["+cDoc+"] Serie: ["+cSerie+"] Modelo: ["+cModelo+"] Entidade: ["+cIDEnt+"]:", lRet )
	
	If !lRet
		cMsgErro := "Erro ao consumir o metodo MonitorFaixa para o DOC: ["+cDoc+"] Serie: ["+cSerie+"]: " + IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
		LjGrvLog( cDoc, cMsgErro )
		ConOut( cMsgErro )
		If !IsBlind()
			Aviso("SPED",cMsgErro,{"Ok"},3)
		EndIf
	Else
		If Len(OWS:OWSMONITORFAIXARESULT:OWSMONITORNFE) > 0
			oRetornoNF 	:= aTail(OWS:OWSMONITORFAIXARESULT:OWSMONITORNFE[1]:OWSERRO:OWSLOTENFE)
			cCodRetNF 	:= oRetornoNF:CCODRETNFE
			cMsgRetNF 	:= oRetornoNF:CMSGRETNFE
		EndIf
	EndIf
Else
	cMsgErro := "Nao foi possivel obter o c๓digo da Entidade para o modelo de documento: " + cModelo
	lRet := .F.
	LjGrvLog( cDoc, cMsgErro )
	ConOut( cMsgErro )
	If !IsBlind()
		Aviso("SPED",cMsgErro,{"Ok"},3)
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LjUrlsXml
Fun็ใo que retorna o conteudo do XML ljnfceurls.xml

@param   nTipo 0 solicita็ใo do PDV, 1 para solicita็ใo do LOJA
@param   oXml contendo o conteudo do xml quando utilizado o nTipo = 1
@author  Eduardo Sales
@since   19/02/2019
@version P12
@return  Array, Retorna o conte๚do do XML ljnfceurls.xml
/*/
//-------------------------------------------------------------------
Function LjUrlsXml(nTipo, oXml)

Local cErro		:= ""
Local cAviso	:= ""
Local cFile		:= "\autocom\nfce\LjNFCeUrls.xml"	// Arquivo xml que cont้m todas as URLs referente a NFC-e
Local nHandle	:= 0
Local nSize		:= 0
Local cBuffer	:= ""
Local nRead		:= 0
Local aRet		:= {}

Default nTipo	:= 0

If nTipo == 0
	nHandle	:= FOpen(cFile)
	If nHandle >= 0
		nSize := FSeek(nHandle, 0, 2)
		FSeek(nHandle, 0)
		cBuffer := Space(nSize)
		nRead 	:= FRead(nHandle, @cBuffer, nSize)
		FClose(nHandle)
		aAdd(aRet, cBuffer)
	EndIf
Else
	oXml := XmlParserFile( cFile, "_", @cErro, @cAviso )

	If oXml == NIL
		MsgStop(STR0151)	// "Falha na captura dos dados do XML!"
	EndIf
EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LjNFeDeneg
Fun็ใo que escritura nota Denegada para retaguarda

@author  Anderson Machado
@since   10/01/2018
@version P12
@return  
/*/
//-------------------------------------------------------------------
Static Function LjNFeDeneg()
Local aAreaSL1 	:= {}
Local aAreaSL2 	:= {}
Local aAreaSL4 	:= {}
Local aCpAreaSL1:= {}
Local aCpAreaSL2:= {}
Local aCpAreaSL4:= {}

//-- Copia or็amento STDDblOrc
if !ExistFunc("STDDblOrc")
	LjGrvLog( "NOTA DENEGADO", "Favor atualizar o fonte STDRecoverySale, nใo foi possivel escriturar nota DENEGADA!!! Doc/Serie:"+ SL1->L1_DOC+"/"+SL1->L1_SERIE)

else
	LjGrvLog( "NOTA DENEGADO", "Duplicando a venda para cancelamento e escritura็ใo fiscal.")
	LjGrvLog( "NOTA DENEGADO", "Venda original: " + SL1->L1_NUM)

	aAreaSL1 := SL1->(GetArea())
	aAreaSL2 := SL2->(GetArea())
    aAreaSL4 := SL4->(GetArea())

	STDDblOrc()
	LjGrvLog( "NOTA DENEGADO", "Venda copiada para o orcamento: " + SL1->L1_NUM)

	//-- Guarda posi็ใo do or็amento novo (c๓pia)
	aCpAreaSL1	:= SL1->(GetArea())
	aCpAreaSL2	:= SL2->(GetArea())
	aCpAreaSL4	:= SL4->(GetArea())

	LjGrvLog( "NOTA DENEGADO", "Cancelando a venda copiada para escritura็ใo: " + SL1->L1_NUM)
	RecLock("SL1")
		SL1->L1_STORC := "A" //-- Solicita Cancelamento imediato devido NFe Denegado
		SL1->L1_SITUA := "00"
	SL1->( MsUnLock() )

	LjGrvLog( "NOTA DENEGADA", "Solicita cancelamento no Back Office: " + SL1->L1_NUM )  //Gera LOG
	STDCSRequestCancel( SL1->L1_NUM,,,"")

	//-- Retorna posi็ใo do or็amento original			
	RestArea(aAreaSL4)
	RestArea(aAreaSL2)
	RestArea(aAreaSL1)

	//-- Restorna a copia para da proceguimento na nova finaliza็ใo
	LjGrvLog( "NOTA DENEGADO", "Posicionando no ora็amento original para nova finaliza็ใo correta: " + SL1->L1_NUM)

EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} LjGeraCNF
Gera o c๓digo num้rico da tag <cNF> que comp๕e a Chave de Acesso. 
ษ um n๚mero aleat๓rio de 8 posi็๕es gerado pelo emitente para cada NF-e para evitar acessos indevidos da NF-e.

@type  	 Function
@author  JMM
@since	 05/10/2020
@version P12

@param 	cNumDoc, Caractere, N๚mero do DOC

@return cRet, Caractere, C๓digo num้rico aleat๓rio de 8 posi็๕es referente a tag cNF que comp๕e a Chave de Acesso.

@obs	Regras de valida็ใo da tag <cNF> conforme Nota T้cnica 2019.001:
		- cNF nใo pode ser igual a 00000000, 11111111, 22222222, 33333333, 44444444, 55555555, 66666666, 77777777, 88888888, 99999999, 12345678, 23456789, 34567890, 45678901, 56789012, 67890123, 78901234, 89012345, 90123456, 01234567.
		- cNF nใo pode ser igual a nNF (id: B08).
		https://tdn.totvs.com/pages/viewpage.action?pageId=318604074
/*/
//-------------------------------------------------------------------
Static Function LjGeraCNF(cNumDoc)
Local cRet		:= ""
Local lNumeroOk	:= .F.
Local cFunc     := "Random" 		//Nova funcao da TEC que gera o n๚mero aleat๓rio de forma mais segura, al้m de utilizar uma precisใo maior do que a fun็ใo RANDOMIZE
Local lRandom 	:= ExistFunc(cFunc) //Verifica se a fun็ใo existe, pois a mesma s๓ estแ disponํvel a partir da build 19.3.1.x do AppServer

cNumDoc := cValToChar( Val(cNumDoc) )

While !lNumeroOk
	If lRandom
		//Usa a nova fun็ใo Random
		cRet := Alltrim(Str(&cFunc.( 10000000, 99999999 )))
	Else
		cRet := Alltrim(Str(Randomize( 10000000, 99999999 )))
	EndIf

	lNumeroOk := AScan(aExcecaoCNF,cRet) == 0 .And. cNumDoc <> cRet
EndDo

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LjCodBenef
Fun็ใo responsแvel por preencher a tag cBenef

@author  eduardo.sales
@since   23/11/2020
@version P12
@return  cXML - XML com a tag cBenef preenchida
/*/
//-------------------------------------------------------------------
Static Function LjCodBenef(cXML, cCodProd, cSitTribL2)

Local cMVMTCLF3K	:= SuperGetMV("MV_MTCLF3K",,"0")
Local cGrpProd		:= ""

If cMVMTCLF3K == "0"
	DbSelectArea("F3K")
	If !(Empty(F3K->(IndexKey(2))))	//Verificar se hแ ordem 2 de F3K cadastrado na SIX
		F3K->(dbSetOrder(2)) // F3K_FILIAL + F3K_PROD + F3K_CFOP + F3K_CST
		If F3K->(DbSeek(xFilial("F3K") + PadR(cCodProd, TamSX3("L2_PRODUTO")[1]) + SL2->L2_CF + cSitTribL2 ))
			cXML += "<cBenef>" + F3K->F3K_CODAJU + "</cBenef>"
		EndIf
	EndIf
ElseIf cMVMTCLF3K == "1"
	DbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	If SB1->(DbSeek(xFilial("SB1") + PadR(cCodProd, TamSX3("L2_PRODUTO")[1])))
		cGrpProd := SB1->B1_GRTRIB
		DbSelectArea("F3K")
		If !(Empty(F3K->(IndexKey(2))))	//Verificar se hแ ordem 2 de F3K cadastrado na SIX
			F3K->(dbSetOrder(3)) // F3K_FILIAL + F3K_GRPLAN + F3K_CFOP + F3K_CST
			If F3K->(DbSeek(xFilial("F3K") + PadR(cGrpProd, TamSX3("F3K_GRPLAN")[1]) + SL2->L2_CF + cSitTribL2 ))
				cXML += "<cBenef>" + F3K->F3K_CODAJU + "</cBenef>"
			EndIf
		EndIf
	EndIf
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} LjCdPagSef
Fun็ใo responsแvel por retornar o conteudo para preenchimento
da tag <tPag>
@param cAdmFin, String, Codigo de Adm financeira
@param cL4Forma, String, Forma de pagamento
@param cMvVerNFCe, String, Versใo da NFC-e 
@param lIsNfe, Logico, Indica se ้ uma NF-e
@param cMVAMBNFCE, String, Ambiente NFC-e
@author  eduardo.sales
@since   11/03/2021
@version P12
@return  cFormaCod - Forma de pagamento para a tag <tPag>
/*/
//-------------------------------------------------------------------
Static Function LjCdPagSef(cAdmFin, cL4Forma,cMvVerNFCe,lIsNfe,cMVAMBNFCE)

Local nTamAECOD 	:= TamSX3("AE_COD")[1]	//tamanho do campo AE_COD
Local nTamConteu	:= 0					//tamanho do campo MHW_CONTEU
Local cCodPgSF		:= ""
Local cFormaCod		:= ""
Local aFormas		:= {}
Local nPos			:= 0

Default cAdmFin 	:= ""
Default cL4Forma 	:= ""

If !NT2020006P() .OR. SAE->(Columnpos("AE_CDPGSF")) == 0 .OR. MHW->(Columnpos("MHW_CONTEU")) == 0

	aFormas := LjSX5FPgto(cMvVerNFCe,lIsNfe)

	nPos := aScan( aFormas, {|x| Alltrim(x[2]) == Alltrim(cL4Forma)} )
	If nPos > 0
		cFormaCod := aFormas[nPos][1]
	Else
		cFormaCod := "99"
	EndIf

Else

	nTamConteu 	:= TamSX3("MHW_CONTEU")[1]	//tamanho do campo MHW_CONTEU
	cAdmFin 	:= PadR(cAdmFin, nTamAECOD)
	cL4Forma 	:= PadR(cL4Forma,nTamConteu)
	
	DbSelectArea("SAE")
	SAE->(DbSetOrder(1))//AE_FILIAL+AE_COD                                                                                                                                                
	If  SAE->(DbSeek(xFilial("SAE")+cAdmFin)) .And. !Empty(SAE->AE_CDPGSF) .And. Alltrim(SAE->AE_TIPO) == Alltrim(cL4Forma)
		cCodPgSF := SAE->AE_CDPGSF
		If !Empty(cCodPgSF)
			DbSelectArea("MHW")                                                                                                                                
			MHW->(DbSetOrder(1))//MHW_FILIAL+MHW_CODIGO+MHW_CONTEU
			If MHW->(DbSeek(xFilial("MHW")+cCodPgSF))
				cFormaCod := MHW_CDNFCE
			EndIF
		EndIf
	Else
		DbSelectArea("MHW")
		MHW->(DbSetOrder(2))//MHW_FILIAL+MHW_CONTEU                                                                                                                                           
		If MHW->(DbSeek(xFilial("MHW")+cL4Forma))
			cFormaCod := MHW_CDNFCE
		EndIF
	EndIf
	If Empty(cFormaCod)
		cFormaCod:= "99"
	EndIf	


	If Empty(cFormaCod)
		Alert(STR0168 + cAdmFin + STR0169)//"Nใo foi possํvel encontrar o vํnculo com a forma de pagamento da SEFAZ, por gentileza, revise sua administradora financeira no campo 'Cod.Pg.Sefaz(AE_CDPGSF)'"
	EndIf 
	
EndIf 

Return cFormaCod

//-----------------------------------------------------------------------
/*/{Protheus.doc} NT2020006
Retorna a data de inํcio quando entra em vigor a valida็ใo do meio de pagamento
da NT006 versใo 1.2 cadastrado no parโmetro "MV_NT2006P", valor default ้ 01/09/2021
@return	date, data de inicio da vigencia da valida็ใo do meio de pagamento
@author caio.okamoto
@since  07/06/2021
/*/
//-----------------------------------------------------------------------
Static Function NT2020006P()
Return Date() >= cToD(SuperGetMv("MV_NT2006P",.F.,"01/09/2021"))

//-----------------------------------------------------------------------
/*/{Protheus.doc} NT2020006
Retorna de acordo com o indicador de presen็a indica se pode ser informado
o indIntermed

@param  cIndPres, String, indicado de presen็a
@param  cAmbiente, String, Numero do ambiente (1-producao/2-homologacao)
@return	lRet, boleano, se ้ necessario informar o IndIntermed ou nใo
@author eduardo.sales
@since  11/03/2021
/*/
//-----------------------------------------------------------------------
Static Function NT2020006I()
return Date() >= cToD(SuperGetMv("MV_NT2006I",.F.,"05/04/2021"))


//-----------------------------------------------------------------------
/*/{Protheus.doc} LjNFCeinfI
Retorna informa็ใoes referente ao grupo  YB. Informa็๕es do Intermediador da Transa็ใo

@return	infIntermed, caracter, TAG infIntermed
@author Lucas Novais (lnovias)
@since  19/03/2021
/*/
//-----------------------------------------------------------------------
Static Function LjNFCeinfI()
Local cInfIntermed	:= ""

If NT2020006I() .AND. SL1->(FieldPos("L1_INDPRES")) > 0 .AND. SL1->L1_INDPRES $ "2,3,4,9" .AND. SL1->(FieldPos("L1_INTERMD")) > 0 .And. !Empty(SL1->L1_INTERMD)
	If AliasInDic("A1U")
		DbSelectArea("A1U")
		A1U->(DbSetOrder(1)) //A1U_FILIAL+A1U_CODIGO
		If A1U->(DbSeek(xFilial("A1U") + SL1->L1_INTERMD))
			
			cInfIntermed +="<infIntermed>"
				cInfIntermed += "<CNPJ>" + A1U->A1U_CGC +"</CNPJ>"
				cInfIntermed += "<idCadIntTran>" + Alltrim(A1U->A1U_NOME) + "</idCadIntTran>"
			cInfIntermed +="</infIntermed>"

		EndIf
	EndIf
EndIf

return cInfIntermed

//-----------------------------------------------------------------------
/*/{Protheus.doc} LjxPag
Retorna a tag xPag preenchida caso seja elegivel  (NT 006 versใo 1.2)
Regra NT006 :"Descri็ใo do meio de pagamento. Preencher informando o
				meio de pagamento utilizado quando o c๓digo do
				meio de pagamento for informado como 99-outros."

@param  cCodFrmSEF, caractere, Codigo da Forma de Pagamento SEFAZ tPag
@param  cCodFrmSX5, caractere, C๓digo da Forma de Pagamento da SX5 
@return	cTagxPag, caractere, Retorna a tag xPag  
@author caio.okamoto
@since  10/05/2021
/*/
//-----------------------------------------------------------------------
Static Function LjxPag(cCodFrmSEF,cCodFrmSX5, lIsNfe)
Local cXPag 	:= ""
Local aRetSx5 	:= {}


If NT2020006P() .AND. cCodFrmSEF == '99'
	If cCodFrmSX5 == "PCC" .AND. lIsNfe   //PCC=Pis/Cofins/CSLL
		cXPag	:= "RETENCOES"
	Else
		aRetSx5 := FWGetSX5 ('24', PadR(cCodFrmSX5,TamSX3("X5_CHAVE")[1]))
		If Len(aRetSx5)>0 
			cXPag:= aRetSx5[1][4]
		Endif 
	EndIf
Endif

LjGrvLog( Nil,"NT2020006P",NT2020006P())
LjGrvLog( Nil,"cCodFrmSEF",cCodFrmSEF)
LjGrvLog( Nil,"cCodFrmSX5",cCodFrmSX5)
LjGrvLog( Nil,"cXPag",cXPag)

Return cXPag

/*/{Protheus.doc} LjSetRefFis
Carrega o array estแtico aRefxFis com dados da MatxFis.

@author  joao.marcos
@since   08/07/2021
@version P12

@param 	 aRefFis, array, Valores de referecnia da MatxFis a serem setados na variแvel estแtica aRefxFis

@return  Nil, Nulo
/*/
Function LjSetRefFis(aRefFis)
	aRefxFis := aClone(aRefFis)
Return

/*/{Protheus.doc} LjGetRefFis
Retorna os valores salvos no array aRefxFis com as informa็๕es da MatxFis.

@author  joao.marcos
@since   08/07/2021
@version P12

@param	 cItem, caracter, numero do item
@param 	 cMtxFisRef, caracter, referencia da MatxFis
@param   cIDTrib, caracter, referencia do configurador de Tributos

@return nRet, numerico, Valor da Refer๊ncia da MatxFis

@example LjGetRefFis(SL2->L2_ITEM,"IT_BFCANTS")

		Consultar Tributos Genericos
		 LjGetRefFis(SL2->L2_ITEM,"TG_IT_BASE")
		 LjGetRefFis(SL2->L2_ITEM,"TG_IT_ALIQUOTA")
		 LjGetRefFis(SL2->L2_ITEM,"TG_IT_VALOR")
/*/
Function LjGetRefFis(cItem, cMtxFisRef, cIDTrib)
Local nRet		:= 0
Local nPos		:= 0
Local nTG		:= 0

Local aTgItem	:= {}

DEFAULT cIDTrib		:= ""

//Verifica se a chamada e para consultar o Tributo Generico
if Left(cMtxFisRef,3) == "TG_"

	//Obt้m todos os tributos gen้ricos
	aTgItem := MaFisRet( Val(cItem),"IT_TRIBGEN")
	nPos := len(aTgItem)

	if nPos > 0

		//Identifica posicao do tributo, caso tenha sido referenciado no parametro
		nPos := Ascan(aTgItem, {|x| x[TG_IT_IDTRIB] == cIDTrib} )

		//Pesquisar um tributo em especifico ou apenas o primeiro?
		if Empty(cIDTrib)
			nPos := 1
		endif

		//Inicialmente a implementacao preve os valores basicos, utilizados para a NT 001.2023
		//que se aplica a legislacao de tributacao monofasica para postos de combustivel.
		do case
		case nPos == 0

		case cMtxFisRef == "TG_IT_BASE"
			nRet := aTgItem[nPos][TG_IT_BASE]
			
		case cMtxFisRef == "TG_IT_ALIQUOTA"
			nRet := aTgItem[nPos][TG_IT_ALIQUOTA]

		case cMtxFisRef == "TG_IT_VALOR"
			nRet := aTgItem[nPos][TG_IT_VALOR]

		endcase
	
	endif

else
	nPos := Ascan(aRefxFis, {|x| AllTrim(x[1]) + x[2] == AllTrim(cItem) + AllTrim(cMtxFisRef) } )

	If nPos > 0
		nRet := aRefxFis[nPos][3]
	EndIf

endif
Return nRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} LjGetContr
Funcao realiza a Consulta do Contribuinte junto a SEFAZ.

@author  Alberto Deviciente
@since 	 27/07/2021
@version P12.1.27

@param 	 cStatus, Caractere, Situa็ใo do Contibuinte (parโmetro passado por Refer๊ncia).
@param 	 cIE, Caractere, Inscri็ใo Estadual.
@param 	 cUF, Caractere, Unidade Federativa (Estado).
@param 	 cCliCod, Caractere, C๓digo do Cliente
@param 	 cCliLoja, Caractere, Loja do Cliente

@return  oRetContri, Objeto, Objeto contendo os dados retornados na Consulta do Contribuinte
/*/
//-----------------------------------------------------------------------
Function LjGetContr(cStatus,cIE,cUF,cCliCod,cCliLoja)
Local aArea 	:= GetArea()
Local aAreaSA1 	:= SA1->(GetArea())
Local cURL     	:= ""
Local cIdEnt    := ""
Local nX	    := 0
Local oRetContri:= Nil //Retorna o objeto com as informa็๕es do Contrinuinte Consultado na SEFAZ
Local cMsgRetWs := ""

Default cStatus := ""
Default cIE		:= ""
Default cUF		:= ""
Default cCliCod	:= ""
Default cCliLoja:= ""

Private oWsNFeSBra:= Nil //Deve ser Private, senใo nใo carrega as informa็๕es de retorno do WS

cURL := SuperGetMV("MV_SPEDURL",,"")
If Empty(cURL)
	cURL := SuperGetMV("MV_NFCEURL",,"")
EndIf
cURL := PadR(cURL,250)

cIDEnt := LjTSSIDEnt("55")
If Empty(cIDEnt)
	cIDEnt := LjTSSIDEnt("65")
Endif

If !Empty(cCliCod) .And. !Empty(cCliLoja)
	DbSelectArea("SA1")
	SA1->( DbSetOrder(1) )	//A1_FILIAL + A1_COD + A1_LOJA
	If SA1->(MsSeek(xFilial("SA1")+cCliCod+cCliLoja)) .And. SA1->A1_PESSOA = "J" //J=Juridica
		cUF := SA1->A1_EST
		cIE	:= SA1->A1_INSCR
	EndIf
EndIf

//------------------------------------------------------------------------------------------------------------
// Se nใo existir Inscri็ใo Estadual informada, retona a Situa็ใo do contribuinte como (1 – habilitado)
// Pois somente ocorre a denega็ใo por irregularidade do destinatแrio se a Inscri็ใo Estadual do destinatแrio 
// for informada na NF-e e se o destinatแrio for Pessoa Jurํdica.
//------------------------------------------------------------------------------------------------------------
If Empty(cIE)
	cStatus := "1" //1 – habilitado
EndIf

LjGrvLog(Nil, "Consulta do Contribuinte (Cliente) junto a SEFAZ. URL TSS:", cURL)
LjGrvLog(Nil, "Consulta do Contribuinte (Cliente) junto a SEFAZ. Entidade TSS:", cIDEnt)
LjGrvLog(Nil, "Consulta do Contribuinte (Cliente) junto a SEFAZ. UF a ser consultada:", cUF)
LjGrvLog(Nil, "Consulta do Contribuinte (Cliente) junto a SEFAZ. IE a ser consultada:", cIE)

If !Empty(cIDEnt) .And. !Empty(cIE) .And. !Empty(cUF)
	oWsNFeSBra:= WsNFeSBra():New()
	oWsNFeSBra:cUserToken	:= "TOTVS"
	oWsNFeSBra:cID_ENT		:= cIdEnt
	oWsNFeSBra:cUF			:= cUF
	oWsNFeSBra:cCNPJ		:= ""
	oWsNFeSBra:cCPF			:= ""
	oWsNFeSBra:cIE			:= Alltrim(cIE)
	oWsNFeSBra:_URL        	:= AllTrim(cURL)+"/NFeSBRA.apw"

	If oWsNFeSBra:CONSULTACONTRIBUINTE()
		
		LjGrvLog(Nil, "Consulta do Contribuinte (Cliente) realizada")
		
		If Type("oWsNFeSBra:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE") <> "U"
			If ( Len(oWsNFeSBra:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE) > 0 )
				nX := Len(oWsNFeSBra:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE)

				oRetContri	:= oWsNFeSBra:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]
				cStatus 	:= oRetContri:cSituacao //Situa็ใo do contribuinte: (0 – nใo habilitado / 1 – habilitado)
				
				LjGrvLog(Nil, "Consulta do Contribuinte (Cliente). Situa็ใo do Contribuinte (Cliente)", cStatus)
			EndIf
		EndIf
	Else
		cMsgRetWs := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
		Aviso("SPED",cMsgRetWs,{"OK"},3)
		LjGrvLog(Nil, "Consulta do Contribuinte (Cliente). Retorno WS:", cMsgRetWs)
	EndIf

	//Destroi o objeto oWsNFeSBra
	If ValType(oWsNFeSBra) == "O"
		FreeObj(oWsNFeSBra)
		oWsNFeSBra := Nil
	EndIf
EndIf

RestArea(aAreaSA1)
RestArea(aArea)

Return oRetContri

//-----------------------------------------------------------------------
/*/{Protheus.doc} LjCnsContr
Fun็ใo que monta a tela para realizar a consulta do contribuinte na SEFAZ

@author  Alberto Deviciente
@since 	 27/07/2021
@version P12.1.27

@param 	 cCliCod, Caractere, C๓digo do Cliente
@param 	 cCliLoja, Caractere, Loja do Cliente

@return  Nil, Nulo
/*/
//-----------------------------------------------------------------------
Function LjCnsContr(cCliCod,cCliLoja)
Local oDlgContr	:= Nil
Local oFont		:= Nil
Local oUF		:= Nil
Local oIE		:= Nil
Local cUF		:= Space(2)
Local cIE		:= Space(14)

Default cCliCod	:= ""
Default cCliLoja:= ""

If !Empty(cCliCod) .And. !Empty(cCliLoja)
	//Se o cliente da venda for diferente do padrใo, jแ inicia os campos com as informa็๕es de UF e IE do cliente da venda
	If AllTrim(SuperGetMV("MV_CLIPAD",,"000001"))+AllTrim(SuperGetMV("MV_LOJAPAD",,"01" )) <> AllTrim(cCliCod)+AllTrim(cCliLoja)
		DbSelectArea("SA1")
		SA1->( DbSetOrder(1) )	//A1_FILIAL + A1_COD + A1_LOJA
		If SA1->(MsSeek(xFilial("SA1")+cCliCod+cCliLoja)) .And. SA1->A1_PESSOA = "J" //J=Juridica
			cUF := SA1->A1_EST
			cIE	:= SA1->A1_INSCR
		EndIf
	EndIf
EndIf

//---------------------------------------------------------------
// Guarda as tecla de atalho que estใo ativas no Venda Assistida
//---------------------------------------------------------------
LJ7F_Salva(.T.)

//--------------------------------------
// Desabilita SetKeys do Venda Assistida
//--------------------------------------
Lj7SetKeys(.F.)

DEFINE FONT oFont BOLD

DEFINE MSDIALOG oDlgContr TITLE STR0170 FROM 0,0 TO 140,305 PIXEL OF GetWndDefault() //"Consulta Contribuinte"

TSay():New(005,005,{|| STR0171 },oDlgContr,,oFont,,,,.T.,,,100,20) //"Informe os dados para a consulta"

TGroup():New(015,003,oDlgContr:nClientHeight/2-31,oDlgContr:nClientWidth/2-4,"",oDlgContr,,,.T.,.F. )

TSay():New(023,010,{|| STR0172 },oDlgContr,,,,,,.T.,,,100,20) //"Estado (UF):"
oUF := TGet():New(021,050,{|u|If(PCount()==0,cUF,cUF:=u)},oDlgContr,020, 009,"@!",{|| Empty(cUF) .Or. ExistCpo("SX5","12"+cUF) },0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"12",cUF,,,, )

TSay():New(037,010,{|| STR0173 },oDlgContr,,,,,,.T.,,,100,20) //"Inscr. Estadual:"
oIE := TGet():New(035,050,{|u|If(PCount()==0,cIE,cIE:=u)},oDlgContr,050, 009,"99999999999999",{|| .T. },0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cIE,,,, )

TButton():New( 056, 112, STR0174, oDlgContr, {|| iIf(LjVlInfCtr(oUF,cUF,oIE,cIE), (LjShowContr(cIE,cUF),oDlgContr:End()), Nil) }, 40, 10, Nil, Nil, .F., .T., .F., Nil, .F., Nil, Nil, .F. ) //"Consultar"

ACTIVATE DIALOG oDlgContr CENTERED

//------------------------------------
// Habilita SetKeys do Venda Assistida
//------------------------------------
Lj7SetKeys(.T.)

//-------------------------------------------------------------------
// Restaura as tecla de atalho que estavam ativas no Venda Assistida
//-------------------------------------------------------------------
Lj7F_Salva(.F., .T.)

Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} LjShowContr
Exibe interface com resultado da consulta do contribuinte junto a SEFAZ.

@author  Alberto Deviciente
@since 	 27/07/2021
@version P12.1.27

@param 	 cIE, Caractere, Inscri็ใo Estadual.
@param 	 cUF, Caractere, Unidade Federativa (Estado).

@return  Nil, Nulo
/*/
//-----------------------------------------------------------------------
Static Function LjShowContr(cIE,cUF)
Local cRazSoci 	:= ""
Local cRegApur  := ""
Local cCnpj		:= ""
Local cCpf	    := ""
Local cSituacao := ""
Local cPictCNPJ	:= ""
Local dIniAtiv  := cToD("")
Local dAtualiza	:= cToD("")
Local oFont 	:= Nil
Local oDlgContr	:= Nil
Local oRetContri:= Nil 	//Retorna o objeto com as informa็๕es do Contrinuinte Consultado na SEFAZ
Local nClrTxtSit:= 0 	//Cor do Texto referente a situa็ใo do Cliente

CursorWait()

//Consulta Situa็ใo do contribuinte junto a SEFAZ
oRetContri := LjGetContr(Nil,cIE,cUF)

CursorArrow()

If ValType(oRetContri) == "O"

	If ValType(oRetContri:dInicioAtividade) <> "U"
		dIniAtiv  := oRetContri:dInicioAtividade
	EndIf
	cRazSoci  	:= oRetContri:cRazaoSocial
	cRegApur  	:= oRetContri:cRegimeApuracao
	cCnpj	  	:= oRetContri:cCNPJ
	cCpf	  	:= oRetContri:cCPF
	cIE       	:= oRetContri:cIE
	cUf	    	:= oRetContri:cUF
	cSituacao 	:= oRetContri:cSituacao

	If ValType(oRetContri:dUltimaSituacao) <> "U"
		dAtualiza := oRetContri:dUltimaSituacao
	EndIf
	
	If cSituacao == "1"
		cSituacao := "1" + " - " + STR0175	//"1 - Habilitado"
		nClrTxtSit:= CLR_GREEN
	ElseIf cSituacao == "0"
		cSituacao := "0" + " - " + STR0176	//"0 - Nใo Habilitado"
		nClrTxtSit:= CLR_HRED
	EndIf

	If ( !Empty(cCnpj) )
		cCnpj		:= cCnpj
		cPictCNPJ	:= "@R 99.999.999/9999-99"
	Else
		cCnpj		:= cCpf
		cPictCNPJ	:= "@R 999.999.999-99"
	EndIf

	DEFINE FONT oFont BOLD

	DEFINE MSDIALOG oDlgContr TITLE STR0177 FROM 0,0 TO 200,550 PIXEL OF GetWndDefault() //"Retorno da Consulta Contribuinte junto เ SEFAZ"

	TGroup():New(003,003,oDlgContr:nClientHeight/2-33,oDlgContr:nClientWidth/2-4,"",oDlgContr,,,.T.,.F. )

	TSay():New(008,010,{|| STR0178			},oDlgContr,,oFont,,,,.T.,,,200,20) 		//"Razใo Social:"
	TSay():New(008,048,{|| cRazSoci		 	},oDlgContr,,	  ,,,,.T.,,,225,20)

	TSay():New(020,010,{|| STR0179			},oDlgContr,,oFont,,,,.T.,,,200,20)			//"Inํcio das Atividades:"
	TSay():New(020,072,{|| DtoC(dIniAtiv) 	},oDlgContr,,	  ,,,,.T.,,,200,20)

	TSay():New(020,150,{|| STR0180			},oDlgContr,,oFont,,,,.T.,,,200,20) 		//"UF:"
	TSay():New(020,159,{|| cUf			 	},oDlgContr,,	  ,,,,.T.,,,200,20)

	TSay():New(032,010,{|| STR0181			},oDlgContr,,oFont,,,,.T.,,,200,20) 		//"CNPJ/CPF:"
	TSay():New(032,040,{|| cCnpj		 	},oDlgContr,cPictCNPJ,,,,,.T.,,,200,20)

	TSay():New(032,150,{|| STR0182			},oDlgContr,,oFont,,,,.T.,,,200,20) 		//"IE:"
	TSay():New(032,159,{|| cIE			 	},oDlgContr,,	  ,,,,.T.,,,200,20)

	TSay():New(044,010,{|| STR0183			},oDlgContr,,oFont,,,,.T.,,,200,20) 		//"Regime:"
	TSay():New(044,035,{|| cRegApur		 	},oDlgContr,,	  ,,,,.T.,,,200,20)

	TSay():New(056,010,{|| STR0184			},oDlgContr,,oFont,,,,.T.,,,200,20) 		//"Situa็ใo:"
	TSay():New(056,038,{|| cSituacao	 	},oDlgContr,,oFont,,,,.T.,nClrTxtSit,,200,20)

	TSay():New(068,010,{|| STR0185			},oDlgContr,,oFont,,,,.T.,,,200,20) 		//"Atualizado em:"
	TSay():New(068,055,{|| DtoC(dAtualiza) 	},oDlgContr,,	  ,,,,.T.,,,200,20)

	TButton():New( 085, 128, "Ok", oDlgContr, {||oDlgContr:End()}, 40, 10, Nil, Nil, .F., .T., .F., Nil, .F., Nil, Nil, .F. )

	ACTIVATE DIALOG oDlgContr CENTERED

EndIf

Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} LjVlInfCtr
Realiza a valida็ใo das informa็๕es digitadas na Tela de Consulta do Contribuinte.

@author  Alberto Deviciente
@since 	 27/07/2021
@version P12.1.27

@param 	 oUF, Objeto, Objeto Get do campo "Estado"
@param 	 cUF, Caractere, Unidade Federativa (Estado).
@param 	 oIE, Objeto, Objeto Get do campo "Inscr. Estadual"
@param 	 cIE, Caractere, Inscri็ใo Estadual.


@return  Nil, Nulo
/*/
//-----------------------------------------------------------------------
Static Function LjVlInfCtr(oUF,cUF,oIE,cIE)
Local lRet 	:= .T.

If Empty(cUF)
	MsgAlert(STR0186) //"Informe o campo 'Estado'!"
	oUF:SetFocus()
	lRet := .F.
EndIf
If lRet .And. !ExistCpo("SX5","12"+cUF)
	oUF:SetFocus()
	lRet := .F.
EndIf

If lRet .And. Empty(cIE)
	MsgAlert(STR0187) //"Informe o campo 'Inscr. Estadual'!"
	oIE:SetFocus()
	lRet := .F.
EndIf
If lRet .And. !IE(cIE,cUF) //Valida a Inscri็ใo Estadual informada
	oIE:SetFocus()
	lRet := .F.
EndIf

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} LjVldContr
Realiza a valida็ใo do Contribuinte junto a SEFAZ, para verificar se existe 
alguma restri็ใo antes de transmitir a NF-e, evitando assim, que ocorra erro de Nota Denegada.

@author  Alberto Deviciente
@since 	 27/07/2021
@version P12.1.27

@param 	 cCliCod, Caractere, C๓digo do Cliente
@param 	 cCliLoja, Caractere, Loja do Cliente
@param 	 cMsg, Caractere, Mensagem sobre a situa็ใo do Cliente (Parโmetro passado por Refer๊ncia)

@return  lRet, L๓gico, (.T.) = Permite transmitir a NF-e / (.F.) Nใo Permite
/*/
//-----------------------------------------------------------------------
Function LjVldContr(cCliCod,cCliLoja,cMsg)
Local lRet 			:= .T.
Local cSitContri	:= "" //Situa็ใo do Contribuite para o qual serแ transmitida a NF-e
Local nVLDCTRB 		:= SuperGetMV("MV_VLDCTRB",, 0) //0=Desligada a Verifica็ใo, mantendo o funcionamento Legado

Default cMsg 	:= ""

LjGrvLog(Nil, "Configura็ใo da Consulta do Contribuinte (Cliente) junto a SEFAZ", nVLDCTRB)

If nVLDCTRB > 0
	LjGetContr(@cSitContri,Nil,Nil,cCliCod,cCliLoja)

	LjGrvLog(Nil, "Resultado da Consulta do Contribuinte (Cliente) junto a SEFAZ. Cliente: " + cCliCod + "| Loja: " + cCliLoja, cSitContri)

	//Caso o Contribuite nใo esteja Habilitado, ou seja, com alguma Restri็ใo na SEFAZ
	If cSitContri == "0" //0 – nใo habilitado
		lRet := .F.
		cMsg := STR0188 //"Nใo serแ possํvel transmitir a Nota Fiscal Eletr๔nica, pois o cliente possui restri็ใo junto เ SEFAZ."
		If nVLDCTRB == 1 //1=Pergunta de Deseja Continuar, mesmo com Restri็ใo do Contribuinte
			lRet 	:= MsgNoYes(cMsg + CHR(10)+CHR(13)+CHR(10)+CHR(13) + STR0189) //"Deseja prosseguir com a finaliza็ใo da venda mesmo assim?"
		ElseIf nVLDCTRB == 2 //2=Bloqueia e nใo permite Continuar a finaliza็ใo da venda.
			lRet	:= .F.
		EndIf
	EndIf
EndIf

LjGrvLog(Nil, "Retorno da Consulta do Contribuinte (Cliente) junto a SEFAZ", lRet)

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} Lj7Intemd
Retorna o se atransa็ใo tem Intermediador - 0-Sem Intermediador / 1-Com Itermedidor 

@author  Gilmar Costa
@since 	 21/01/2022
@version P12.1.27

@param 	 cIndPrese, Caractere, Indicador de Presen็a
@param 	 cL1Intermd, Caractere, C๓digo do Intermediador

@return  cVlIntermd, Caractere = 0-Sem Intermediador / 1-Com Itermedidor
/*/
//-----------------------------------------------------------------------
Function Lj7Intemd(cIndPrese, cL1Intermd)
Local cTpIntermd 	:= "1"

Default cIndPrese 	:= "1"   // Indicador de Presen็a
Default cL1Intermd	:= ""	 // C๓digo do Intermedoador

	/*
	Conform passado pela Consultoria Tributแria, em 20/01/2022, para emissใo de NFCe,
	 ้ posssํvel utilizar sem possibilidade de haver rejei็ao, somente as op็๕es "1" e "4".

	cIndPrese 						= "4" 	1=Opera็ใo presencial;
											2=Opera็ใo nใo presencial, pela Internet;
											3=Opera็ใo nใo presencial, Teleatendimento;
											4=NFC-e em opera็ใo com entrega a domicํlio;
											9=Opera็ใo nใo presencial, outros. 

	Empty(SL1->L1_INTERMD)			= Campo informado no cabe็a็ho da venda(LQ_INTERMD);
											SLQ->LQ_ITERMD
											SL1->L1_ITERMD
											A1U->A1U_CODIGO											
	*/
	// 4=NFC-e em opera็ใo com entrega a domicํlio;
	If cIndPrese == "4" .AND. Empty(cL1Intermd)
		cTpIntermd := "0"	//0=Opera็ใo sem intermediador (em site ou plataformapr๓pria)
	Else
		cTpIntermd := "1"	//1=Opera็ใo em site ou plataforma de terceiros (intermediadores/marketplace)
	EndIf

Return cTpIntermd

//-----------------------------------------------------------------------
/*/{Protheus.doc} Lj7CnfMail
Retorna o email cadastrado na SA1->A1_EMAIL, formatado de acordo as regras

@author  Gilmar Costa
@since 	 27/01/2022
@version P12.1.27

@param 	 cEmailSA1, Caractere, email cadastrado na SA1

@return  cEmailForm, Caractere, email formatado
/*/
//-----------------------------------------------------------------------
Function Lj7CnfMail(cEmailSA1)
Local cEmailForm	:= ""   // Guarda os emails que serใo retornados
Local cEmailRet 	:= ""	// Conte๚do que serแ retornado devidanente tratado/formatado
Local nX			:=	0	// Controle do For/Next
Local cCaracter		:= ""	// Caracterer que serแ comparado com o caractere da string
Local aArray		:= {} 	// Guarda as posi็๕es de separa็ใo dos emails

Default cEmailSA1 	:= "" 	// Conte๚do do campo SA1->A1_EMAIL

/* VALIDAวีES:
	Para NFC-e, nใo ้ permitido o envio da TAG <email></email> maior que 60 caracteres.	
*/

For nX := 1 to Len(cEmailSA1)
	cCaracter := Substr(cEmailSA1,nX,1)
	If cCaracter$" ,|+*/"
		// Altera o caracter de separa็ใo para envio do email
		cCaracter := ";"
	EndIf

	// Tratamento para multiplos emails
	If cCaracter == ";"		
		LjGrvLog(SL1->L1_NUM,"Adicionou email: ", cEmailForm)	
		Aadd(aArray,{nX, cEmailForm})
		cEmailForm := ""
	EndIf

	// Adiciona o caractere da String
	cEmailForm += cCaracter

	// Como nใo ้ permitido enviar no XML mais que 60 cacteres, o tratamento encerra aqui
	If nX == 61
		LjGrvLog(SL1->L1_NUM,"Atingiu limite de 60 aracteres: ", cEmailForm)		
		// Se nX > 60 e Len(aArray) == 0, significa que o email cadastrado na SA1 estแ com tamanho invแlido para gerar XML (mmaior que 60 caracteres)
		If Len(aArray) == 0
			LjGrvLog(SL1->L1_NUM,"email cadastrado com mais de 60 caracteres: ", cEmailForm)	
			cEmailForm := ""
		EndIf	
		Exit
	EndIf	

Next nX

// Casa tenha multiplos emails na SA1->A1_EMAIL
If Len(aArray) > 0
	For nX := 1 to  Len(aArray)
		cEmailRet += aArray[nx][2]
	Next nX	
Else
	// Somente um email na SA1->A1_EMAIL
	cEmailRet := cEmailForm	 
EndIf

Return cEmailRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} LjOrcXDoc
Busca os Or็amentos que estใo atrelados a Nota (NF-e), seja por faturamento parcial ou Nota Sobre Cupom

@author  Alberto Deviciente
@since 	 27/10/2022
@version P12

@return  Array, Rela็ใo de or็amentos que estใo atrelados a Nota (NF-e).
/*/
//-----------------------------------------------------------------------
Static Function LjOrcXDoc()
Local aRet 		:= {}
Local nTamSerie	:= TamSX3("F2_SERIE")[1]
Local cSerNfCup	:= SubStr(SF2->F2_NFCUPOM,1,nTamSerie)
Local cDocNfCup	:= SubStr(SF2->F2_NFCUPOM,nTamSerie+1,TamSX3("F2_DOC")[1])

SL1->(dbsetorder(2)) //L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV

//Jแ vem posicionado do NFESEFAZ na SF2 
If SL1->(DbSeek(xFilial('SL1') + SF2->F2_SERIE + SF2->F2_DOC))
	//Busca todos os or็amentos que tem o mesmo numero de DOC/SERIE, pois no Faturamento da Nota pode acontecer de ser aglutinado 2 ou mais pedidos de orcamentos/vendas diferentes
	While SL1->(!EOF()) .And. SL1->L1_FILIAL+SL1->L1_SERIE+SL1->L1_DOC == xFilial('SL1')+SF2->F2_SERIE+SF2->F2_DOC
		If AllTrim(SL1->L1_SITUA) <> "FR"
			aAdd( aRet, SL1->L1_NUM )
		EndIf
		SL1->(DbSkip())
	End
	
	//Verifica se ้ Nota Sobre Cupom
	If !Empty(SF2->F2_NFCUPOM)
		SF2->(DbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
		If SF2->(DbSeek(xFilial('SF2')+cDocNfCup+cSerNfCup)) .And. AllTrim(SF2->F2_NFCUPOM) == "MDL-RECORDED"
			//Se for Nota Sobre varios Cupons
			MDL->(DbSetOrder(1)) //MDL_FILIAL+MDL_NFCUP+MDL_SERIE+MDL_CUPOM+MDL_SERCUP
			If MDL->(DbSeek(xFilial('MDL')+cDocNfCup+cSerNfCup))
				//Busca todos os or็amentos que pertencem a mesma Nota Sobre Cupom
				While MDL->(!EOF()) .And. MDL->MDL_FILIAL+MDL->MDL_NFCUP+MDL->MDL_SERIE == xFilial('MDL')+cDocNfCup+cSerNfCup
					
					SL1->(DbSetOrder(2)) //L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV
					If SL1->(DbSeek(xFilial('SL1')+PadR(MDL->MDL_SERCUP,nTamSerie)+MDL->MDL_CUPOM))
						If aScan( aRet, SL1->L1_NUM ) == 0 .And. AllTrim(SL1->L1_SITUA) <> "FR"
							aAdd( aRet, SL1->L1_NUM )
						EndIf
					EndIf
					MDL->(DbSkip())
				End
			EndIf

		EndIf
	EndIf

Else
	// Tratamento para caso a venda tenha gerado mais de uma NF-e, busca o Doc pela SL2
	SL2->(DbSetOrder(3)) //L2_FILIAL+L2_SERIE+L2_DOC+L2_PRODUTO
	If SL2->(DbSeek(xFilial('SL2') + SF2->F2_SERIE + SF2->F2_DOC))
		aAdd( aRet, SL2->L2_NUM )
	EndIf
EndIf

aSort(aRet)

Return aRet


/*/{Protheus.doc} LjGetModNf
	Retorna o conte๚do da variavel nModFsda
	@type  Function
	@author Varejo
	@since 10/03/2023
	@version 12
	@return nModFsda, numerico, retorna a modalidade que foi impressa a NF-e
	/*/
Function LjGetModNf()
Return nModFsda


//-----------------------------------------------------------------------
/*/{Protheus.doc} GeraTagJLA
Retorna a tag Comb preenchida conforme caso elegivel (NT 2016/002 versใo 1.00)
no caso da NFCe.
Regra NT2016/001 v1: conforme link do TDN, preenchendo as tags:
		cProdANP, UFCons, nBico, nTanque, vEncIni e vEncFin
		https://tdn.totvs.com/pages/releaseview.action?pageId=219693914#tabs-nfce
@param  nItem,cSitTrib
@return	cTag
@author anderson.machado
@since  01/01/2021
/*/
//-----------------------------------------------------------------------
Static Function GeraTagJLA(cSitTrib)
Local cXML 		:= ""
Local cEncIni	:= ""
Local cEncFim	:= ""
Local lNewCSTNT	:= ( cSitTrib $ M->cCstNT00123 )

MID->( DbSeek( xFilial("MID") + SL2->L2_MIDCOD ) )
MHZ->( DbSeek( xFilial("MHZ") + MID->MID_CODTAN ) )

cXML += "<comb>"

if MHZ->( Found() ) .and. !Empty(MHZ->MHZ_CODANP)
	cXML +=	"<cProdANP>" + Alltrim(MHZ->MHZ_CODANP) + "</cProdANP>"
	cXML +=	"<descANP>" + noAcento( Alltrim(MHZ->MHZ_DESANP) ) + "</descANP>"

elseif SB5->( DbSeek( xFilial("SB5") + SL2->L2_PRODUTO ) )
	SB1->( DbSeek( xFilial("SB1") + SL2->L2_PRODUTO ) )
	F0G->( DbSeek( xFilial("FG0") + SB1->B1_CEST ) )

	cXML +=	"<cProdANP>" + Alltrim( Alltrim(SB5->B5_CODANP) ) + "</cProdANP>"
	cXML +=	"<descANP>" + noAcento( noAcento( Alltrim(F0G->F0G_DESCRI) ) ) + "</descANP>"

endif

cXML += 	"<UFCons>" + SM0->M0_ESTCOB + "</UFCons>"	// Por ser varejo o consumo e no estado da venda

// Posicionar na MID (abastecimentos), MHZ (Tanques)
if !Empty(SL2->L2_MIDCOD)

	//-- Apesar do Manual da SEFAZ informar que sao 3, o protheus esta rejeitando informando que sao 2 
	cEncIni := AllTrim( Str( MID->MID_ENCINI,25,2 ) )
	nPos 	:= At(".",cEncIni)
	cEncIni := Left(cEncIni,nPos-1) + Substr(cEncIni,nPos+1,2)

	//-- Neste campo grava apenas 2 casas decimais, mas o XML espera 3 casas. Protheus esta rejeitando informando que o tamanho e 9 e nao 15
	cEncFim := AllTrim( Str( MID->MID_ENCFIN,25,2 ) )
	nPos 	:= At(".",cEncFim)
	cEncFim := Left(cEncFim,nPos-1) + Substr(cEncFim,nPos+1,2)

	cXML += "<encerrante>"

		cXML += "<nBico>" + AllTrim(SL2->L2_MICCOD) + "</nBico>"
		cXML += "<nTanque>" + SL2->L2_LOCAL + "</nTanque>"
		cXML += "<vEncIni>" + cEncIni + "</vEncIni>"
		cXML += "<vEncFin>" + cEncFim + "</vEncFin>"

	cXML += "</encerrante>"

	/*
		NF-e e NFC-e: Nota T้cnica 2023.001 – Tributa็ใo Monofแsica sobre Combustํveis

		Grupo Indicador da origem do Combustํvel, o campo deve ser preenchido nas opera็๕es com:
 			- Biodiesel B100
 			- ำleo Diesel B
 			- GLP/GLGN

		Para identificar as UFs do produtor ou do importador dos produtos utilizados na mistura.

		Tamb้m tem a necessidade de se informar se o produto ้ nacional ou importado.

		A partir de 01/06/2023 alguns estados passaram a solicitar as informa็๕es para gasoline e etanol tambem.
 	*/
	if lNT2023001 .and. lNewCSTNT

		if MID->MID_PBIO > 0
			cXML +=	"<pBio>" + AllTrim( Str(MID->MID_PBIO,9,4) ) + "</pBio>"
		endif

		//O campo tem a finalidade de auxiliar no cแlculo do volume do Biodiesel B100 a ser misturado com
		// ำleo Diesel A, nas opera็๕es com Biodiesel Puro, ou do volume do Biodiesel B100 misturado nas 
		//opera็๕es com ำleo Diesel B.
		if !Empty(MID->MID_UFORIG) .and. MID->MID_PORIG > 0
			cXML += "<origComb>"
		
				//Indicador de importa็ใo - 0=Nacional; 1=Importado;
				cXML += "<indImport>" + AllTrim( MID->MID_INDIMP ) + "</indImport>"

				//C๓digo da UF - Informar UF de origem do produtor ou do importador.
				// Utilizar a tabela do IBGE, ex. SP=35, RS=43, etc.
				cXML += "<cUFOrig>" + LjCodIBGE(MID->MID_UFORIG) + "</cUFOrig>"

				//Percentual originแrio para a UF - Informar em n๚mero decimal o percentual originแrio da UF.
				// Esse valor serแ obtido atrav้s dos Anexos de Combustํveis previstos em Ato Cotepe.
				// Valores de 0 a 100.
				cXML += "<pOrig>" +  AllTrim( Str(MID->MID_PORIG,9,4) ) + "</pOrig>"

			cXML += "</origComb>
	
		endif
	
	endif

endif

cXML += "</comb>"
Return cXML


//-----------------------------------------------------------------------
/*/{Protheus.doc} LjMsgPosto
Retorna texto com mensagens padroes referente a rotina de posto,
se ativa.

@param 
@return	cTag
@author anderson.machado
@since  01/01/2021
/*/
//-----------------------------------------------------------------------
Function LjMsgPosto(lLoja)
Local cMsg 	:= ""
Local aDados:= {}
Local nQtd 	:= 0
Local ix 	:= 0
Local oModelCesta := Nil

Default lLoja := .F.

if lMvPosto

	//Venda do SigaLoja
	if lLoja
	
	else
		// Dados do Veiculo
		aDados := STD7CPFGetReceipt()

		if !Empty( aDados[02] )	// CPF

			//LGPD
			if len(aDados[02]) == 11
				cMsg += " CPF:" + "***.***." + Transform( substr(aDados[02],7,5),"@R 999-99")
			else
				cMsg += " CNPJ: **.***." + Substr(aDados[02],6,3) + "/****-" + Right(aDados[02],2)
			endif
			
		endif

		if !Empty( aDados[03] )	// NOME
			cMsg += " NOME:" + Alltrim( aDados[03] )
		endif

		if !Empty( aDados[04] )	// END
			cMsg += " END:" + Alltrim( aDados[04] )
		endif

		if !Empty( aDados[05] )	// PLACA
			cMsg += " PLACA:" + Alltrim( aDados[05] )
		endif

		if !Empty( aDados[07] )	// CPF MOTORISTA

			if len(aDados[07]) == 11
				cMsg += " CPF MOT:" + Transform(aDados[07], "@R 999.999.999-99") //LGPD
			else
				cMsg += " CNPJ MOT:" + Transform(aDados[07], "@R 99.999.999/9999-99") //LGPD
			endif

		endif

		if !Empty( aDados[08] )	// CPF MOTORISTA
			cMsg += " NOME MOT:" + Alltrim( aDados[08] )
		endif

		if aDados[06] > 0
			cMsg += " AT:" + AllTrim( Transform( aDados[06], "@E 9999999") )
		endif

		if aDados[11] > 0
			cMsg	+= " ANT:" + AllTrim(Transform(aDados[11], "@E 9999999"))
			cMsg	+= " ROD:" + AllTrim(Transform((aDados[06] - aDados[11]), "@E 999999") )
			cMsg	+= " MED:" + AllTrim(Transform(aDados[10], "@E 999.9") )
		endif

		if !Empty( aDados[12] )	// OBSERVAวรO
			cMsg += " OBS:" + Alltrim( aDados[12] )
		endif

		//Dados do Abastecimento
		MID->( DbSetOrder(1) )

		oModelCesta := STDGPBModel()	//Model da cesta
		oModelCesta := oModelCesta:GetModel("SL2DETAIL")
		nQtd := oModelCesta:Length()

		for ix :=1 to nQtd

			oModelCesta:GoLine(ix)
			if !oModelCesta:IsDeleted(ix) .and. !Empty( oModelCesta:GetValue("L2_MIDCOD",ix) )

				if MID->( DbSeek( xFilial("MID") + oModelCesta:GetValue("L2_MIDCOD",ix) ) )
					cMsg += " [ ITEM: " + AllTrim(oModelCesta:GetValue("L2_MIDCOD",ix) )
					cMsg += " EI:" + AllTrim( Transform( MID->MID_ENCINI, X3PICTURE("MID_ENCINI") ) )
					cMsg += " EF:" + AllTrim( Transform( MID->MID_ENCFIN, X3PICTURE("MID_ENCFIN") ) ) + " ] "
				endif

			endif

		next ix

	endif

endif
Return cMsg
