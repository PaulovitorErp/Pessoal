/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao	 � LJ350Imp �Autora � Solange Zanardi       � Data � 04/02/04 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Impressao do Relat�rio com Criticas de Fechamento          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � LJ350Imp()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Uso       � LOJA350 - Fechamento autom�tico                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function LJ350Imp()

//�������������������������������������������������������������������Ŀ
//�As arrays aVendas, aSangrias, aDigitado possuem o seguinte formato:�
//�                                                                   �
//�{ cForma, cDescForma, nValorForma }                                �
//�                                                                   �
//�cForma         	= Codigo da forma de pagamento (Tabela 24)        �
//�cDescForma 		= Descricao da forma de Pagamento                 �
//�nValor           = Valor total desta forma de pagamento            �
//�                                                                   �
//�Em todas as arrays as formas de pagamento s�o enviadas na          �
//�mesma sequ�ncia.                                                   �
//���������������������������������������������������������������������

Local _aVendas 		:= ParamIXB[1]       //Dados das Vendas do Caixa
Local _aSangrias	:= ParamIXB[2]       //Sangrias efetuadas antes do processo de sangramento final
Local _aDigitado	:= ParamIXB[3]		 //Dados Digitados pelo operador
Local _nTotVend		:= ParamIXB[4]		 //Contador da aVendas
Local _nTotSang		:= ParamIXB[5]       //Contador da aSangrias
Local _nTotDigi		:= ParamIXB[6]       //Contador da aDigitado
Local _nTroco		:= ParamIXB[7]       //Valor de troco vindo do Resumo de Caixa

/* Se precisar utilizar no relat�rio j� est�o dispon�veis os mesmos dados do Resumo de Caixa
Local _aTotVen		:= ParamIXB[8]       //Array vinda do Resumo de Caixa com os totais de venda
Local _aTotSan		:= ParamIXB[9]		 //Array vinda do Resumo de Caixa com os totais de sangria pos fechamento
Local _nTotCredito	:= ParamIXB[10]		 //Contador da aTotVen	
Local _nTotDebito	:= ParamIXB[11]      //Contador da aTotSan
Local _nSaldFinal	:= ParamIXB[12]      //Salfo Final considerando troco
*/

Local _oPrint, _oFont
Local _nSalto
Local _nColFim 		:= 0
Local _nColIni 		:= 0
Local _nLin			:= 0
Local _nI 			:= 1
Local _cSimb		:= Substr(Alltrim(IIf(Empty(GetMV("MV_SIMB1")),"R$",GetMV("MV_SIMB1"))),1,2)
Local _cPicture 	:= PesqPict("SLT","LT_VLRDIG",20)
Local _cPicture2 	:= "@E 9,999,999.99"
Local _nDigitado 	:= _nApurado := _nDiverg := _nSangrias := _nSaldDiverg := 0
Local _cCaixa 		:=  SLT->LT_OPERADO  
Local _dData        :=  SLT->LT_DTFECHA


//Setando par�metros de impress�o
_oFont  := TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)
_oPrint := TMSPrinter():New( "Conferencia de Caixa" )

If !_oPrint:IsPrinterActive()
	_oPrint:Setup()																// Escolhe a impressora
Endif

If !_oPrint:IsPrinterActive()
	Aviso("Confer�ncia de Caixa","N�o foi poss�vel imprimir o relat�rio, pois n�o h� nenhuma impressora conectada.",{"Ok"})
	Return(Nil)
EndIf

//�����������������������������������������������������������Ŀ
//�Caixa               			"MV_PAR01"                    �
//�Fechamento    				"MV_PAR02"                    �
//�������������������������������������������������������������
//Pergunte("LOJ350",.F.)

_oPrint:SetPortrait()

_nColInI  := 50		// Coluna inIcial                      
_nColFim  := 1600	// Coluna final
_nSalto   := 40		// Salto de uma linha a outra

// InIcia a impressao da pagina
_oPrint:StartPage()

// Imprime o cabecalho
_oPrint:Say( 110, 100, PadC("CONFERENCIA DE CAIXAS",65), _oFont )
_oPrint:Line( 150, _nColInI, 150, _nColFim )

//_oPrint:Say( 170, 100, "Caixa :" + PadR(MV_PAR01,20) )
//_oPrint:Say( 170, 100, "Caixa :" + PadR(cValtoChar(U_CAIXA()) ) )
_oPrint:Say( 170, 100, "Caixa :" + _cCaixa )
_oPrint:Say( 210, 100, "Data  :" + PadR(Dtoc(_dData),20) )

_oPrint:Line( 300, _nColInI, 300, _nColFim )
_oPrint:Say ( 320, 100, PadR("Fundo de Troco",25)+" "+Replicate(".",15)+" "+PadL(Transform(_nTroco,_cPicture),25) )
_oPrint:Line( 400, _nColInI, 400, _nColFim )

//���������������������������Ŀ
//�Imprime Vendas             �
//�����������������������������
_oPrint:Say ( 420, 100, PadR("Vendas",25)+" "+Replicate(" ",15)+" "+PadL(Transform(_nTotVend,_cPicture),25) )

_nLin := 470

For _nI :=1 To Len(_aVendas)
	_oPrint:Say( _nLin, 100, PadR(_aVendas[_nI][2],25)+;
						   " "+Replicate(".",15)+;
						   " "+PadL(Transform(_aVendas[_nI][3],_cPicture),25) )
	_nLin += _nSalto
Next      
_nLin += _nSalto
_oPrint:Line( _nLin, _nColInI, _nLin, _nColFim )
_nLin += _nSalto

//���������������������������Ŀ
//�Imprime Sangrias           �
//�����������������������������
_oPrint:Say( _nLin, 100, PadR("Sangrias",25)+" "+Replicate(" ",15)+" "+PadL(Transform(_nTotSang,_cPicture),25) )
_nLin += (_nSalto + 10)

For _nI :=1 To Len(_aSangrias)
	_oPrint:Say( _nLin, 100, PadR(_aSangrias[_nI][2],25)+;
						   " "+Replicate(".",15)+;
						   " "+PadL(Transform(_aSangrias[_nI][3],_cPicture),25) )
	_nLin += _nSalto
Next
_nLin += _nSalto
_oPrint:Line( _nLin, _nColInI, _nLin, _nColFim )
_nLin += _nSalto

//���������������������������Ŀ
//�Imprime Confer�ncias       �
//�����������������������������
_oPrint:Say( _nLin, 100, PadR("Confer�ncia",25)+" "+Replicate(" ",15)+" "+PadL(Transform(_nTotDigi,_cPicture),25) )
_nLin += (_nSalto + 10)
_oPrint:Say( _nLin, 100, PadR(" ",25)+" "+PadL("Digitado",12)+"  "+PadL("Apurado",12)+"  "+PadL("Divergente",12) )
_nLin += (_nSalto + 10)

For _nI :=1 To Len(_aDigitado)

	_nDigitado 	:= _aDigitado[_nI][3]					//Valor Digitado
	_nSangrias  := _aSangrias[_nI][3]					//Valor das Sangrias antes da sangramento final
	_nApurado  	:= (_aVendas[_nI][3] - _nSangrias ) + Iif(Alltrim(Upper(_aVendas[_nI][1])) == Alltrim(Upper(_cSimb)), _nTroco, 0 ) 	//Valor Calculado (somo o troco com o dinheiro)
	_nDiverg   	:= _nDigitado - (_nApurado) 			//Divergencias
	_nSaldDiverg += _nDiverg							//Total Divergente

	_oPrint:Say( _nLin, 100,PadR(_aDigitado[_nI][2],25)					+" "+;
							PadL(Transform(_nDigitado,_cPicture2),12)	+"  "+;
							PadL(Transform(_nApurado ,_cPicture2),12)	+"  "+;
						   	PadL(Transform(_nDiverg  ,_cPicture2),12) )			   
	_nLin += _nSalto
Next

//���������������������������Ŀ
//�Totais                     �
//�����������������������������
_nLin += _nSalto
_oPrint:Line( _nLin, _nColInI, _nLin, _nColFim )
_nLin += _nSalto
_oPrint:Say( _nLin, 100, PadR("Total Divergente",25)+" "+Replicate(" ",15)+" "+PadL(Transform(_nSaldDiverg,_cPicture),25) ) 
_nLin += _nSalto
_nLin += _nSalto

// Monta a borda de fora pois neste momento sabemos qual a linha final
_oPrint:Line( 100, _nColInI, 100, _nColFim )
_oPrint:Line( _nLin, _nColInI, _nLin, _nColFim )
_oPrint:Line( 100, _nColInI, _nLin, _nColInI )
_oPrint:Line( 100, _nColFim, _nLin, _nColFim )

_oPrint:EndPage()

_oPrint:Preview()

Return(Nil)



