#INCLUDE "MNTA325.ch"
#Include "Protheus.ch"
#Include 'FWMVCDef.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA325
Cadastro de tipos de status da Ordem de Serviço

@author Gustavo Henrique Voigt

@since 24/10/2019

@return Nil
/*/
//----------------------------------------------------------------------
Function MNTA325()

   Local oBrowse

   oBrowse := FWMBrowse():New()
   oBrowse:SetAlias( 'TQW' )
   oBrowse:SetDescription( STR0001 ) // 'Tipo de Status'
   oBrowse:SetMenuDef( 'MNTA325' )
   oBrowse:Activate()

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do Menu (padrão MVC).

@author Gustavo Henrique Voigt

@since 24/10/2019

@return FwMvcMenu( 'Mnta325' )
/*/
//-----------------------------------------------------------------------
Static Function MenuDef()

Return FwMvcMenu( 'Mnta325' ) // No momento ainda não possui 'Pesquisar'

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do Modelo (padrão MVC).

@author Gustavo Henrique Voigt

@since 24/10/2019

@return oModel, objeto, Modelo MVC
/*/
//-----------------------------------------------------------------------
Static Function ModelDef()

   Local oModel
   Local oStrumTQW := FWFormStruct(1, 'TQW')

   oModel := MPFormModel():New( 'MNTA325' )

   /*Forçar validação do campo devido à erro de dicionário.
   Função Pertence(), MNTA325CKTS e MNT325CKTC() são ignoradas.
   
   Foi necessário tornar obrigatório devido a possibilidade de cadastro vazio,
   sendo assim, a primary key se tornava vazia e caso cadastrasse novamente vazio
   gerava errorlog */
   oStrumTQW:SetProperty('TQW_TIPOST', MODEL_FIELD_VALID, {|oModel| Mnta325Vld('TQW_TIPOST', oModel)})
   oStrumTQW:SetProperty('TQW_TIPOST', MODEL_FIELD_OBRIGAT, .T.)
   oStrumTQW:SetProperty('TQW_CORSTA', MODEL_FIELD_VALID, {|oModel| Mnta325Vld('TQW_CORSTA', oModel)})
   oStrumTQW:SetProperty('TQW_CORSTA', MODEL_FIELD_OBRIGAT, .T.)
   oStrumTQW:SetProperty('TQW_STATUS', MODEL_FIELD_OBRIGAT, .T.)
   oStrumTQW:SetProperty('TQW_DESTAT', MODEL_FIELD_OBRIGAT, .T.)

   oModel:AddFields('MNTA325_TQW', Nil, oStrumTQW)
   oModel:SetDescription( STR0001 ) // 'Tipo de Status'

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da View (padrão MVC).

@author Gustavo Henrique Voigt

@since 24/10/2019

@return oView, objeto, View MVC
/*/
//-----------------------------------------------------------------------
Static Function ViewDef()

   Local oModel := FWLoadModel( 'MNTA325' )
   Local oStruvTQW := FWFormStruct(2, 'TQW')
   Local oView

   oView := FWFormView():New()
   oView:SetModel( oModel )
   oView:AddField('MNTA325_TQW', oStruvTQW)
   oView:CreateHorizontalBox('MASTER', 100)
   oView:SetOwnerView('MNTA325_TQW', 'MASTER')

   //Inclusão de itens nas Ações Relacionadas de acordo com O NGRightClick
	NGMVCUserBtn(oView)

Return oView

//---------------------------------------------------------------------
/*/{Protheus.doc} Mnt325Per
Verificar inserção de valor nos campos especificados, eliminando espaços em branco. Assim como a;
validação por meio do ExistChav() dos campos.

@param nField, numérico, valor para identificação (1 para tipo, 2 para cor).
@param oModel, objeto, model do mnta325.

@author Gustavo Henrique Voigt

@since 24/10/2019


@return lRet, lógico, retorna valor lógico.
/*/
//-----------------------------------------------------------------------
Function Mnta325Vld( cField, oModel)

   Local lRet := .T. 

   If cField == 'TQW_TIPOST'
      If !(Alltrim(oModel:GetValue(cField)) $ '1/2/3/4/5/6/7')

         Help(' ', 1, STR0004,, STR0012, 3, 1,,,,,, ; // 'NÃO CONFORMIDADE' 'Valor de campo inválido.'
         {STR0003}) // 'Informe um tipo de status válido.'

         lRet := .F.

      ElseIf !ExistChav('TQW', oModel:GetValue(cField), 3)
         
         lRet := .F.

      EndIf  

   ElseIf cField == 'TQW_CORSTA'
      If !(Alltrim(oModel:GetValue( cField )) $ '1/2/3/4/5/6/7/8/9/10')

         Help(' ', 1, STR0004,, STR0012, 3, 1,,,,,, ; // 'NÃO CONFORMIDADE' 'Valor de campo inválido.'
         {STR0006}) // 'Informe uma cor válida.'
      
         lRet := .F.
      
      ElseIf !ExistChav('TQW', oModel:GetValue( cField ), 4)

         lRet := .F.

      EndIf 

   EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MNT325CKTS
Valida o tipo de status informado ( Usado no valid do campo )

@author  Elisangela Costa
@since   27/11/07
@version P11/P12
@return  Lógico, define se o status poderá ser utilizado
/*/
//-------------------------------------------------------------------
Function MNT325CKTS()

   Local lACHOU := .F., cCODSTA         
   dbSelectArea("TQW")
   nINDTQW := IndexOrd()
   nRECTQW := Recno()

   dbSetOrder(03)
   dbSeek(xFilial("TQW")+M->TQW_TIPOST,.T.)
   While !Eof() .And. TQW->TQW_FILIAL == xFilial("TQW") .And. Alltrim(TQW->TQW_TIPOST) == Alltrim(M->TQW_TIPOST);
   .And. !lACHOU
         
      If ALTERA .And. Recno() == nRECTQW
         dbSkip()
         Loop
      EndIf 
      lACHOU := .T.
      cCODSTA := TQW->TQW_STATUS
      
      dbSelectArea("TQW")
      dbSkip()
   End              
   dbSelectArea("TQW")
   dbSetOrder(nINDTQW)
   dbGoto(nRECTQW)

   If lACHOU
      MsgInfo(STR0002+" "+Alltrim(cCODSTA)+"."+CHR(13)+; //"Tipo de status já cadastrado para o Status"
            STR0003,STR0004)  //"Informe outro tipo de status."###"NÃO CONFORMIDADE"
      Return .F.
   EndIf 

Return .T.   

//-------------------------------------------------------------------
/*/{Protheus.doc} MNT325CKTC
Valida a cor informada ( Utilizada no valid de campo )

@author  Elisangela Costa 
@since   27/11/07
@version P11/P12
@return  Lógico, define se a cor informada é válida.
/*/
//-------------------------------------------------------------------
Function MNT325CKTC()

   Local lACHOU := .F., cCODSTA         
   dbSelectArea("TQW")
   nINDTQW := IndexOrd()
   nRECTQW := Recno()

   dbSetOrder(04)
   dbSeek(xFilial("TQW")+M->TQW_CORSTA,.T.)
   While !Eof() .And. TQW->TQW_FILIAL == xFilial("TQW") .And. Alltrim(TQW->TQW_CORSTA) == Alltrim(M->TQW_CORSTA) ;
   .And. !lACHOU
         
      If ALTERA .And. Recno() == nRECTQW
         dbSkip()
         Loop
      EndIf 
      lACHOU := .T.
      cCODSTA := TQW->TQW_STATUS
      
      dbSelectArea("TQW")
      dbSkip()
   End              
   dbSelectArea("TQW")
   dbSetOrder(nINDTQW)
   dbGoto(nRECTQW)

   If lACHOU
      MsgInfo(STR0005+" "+Alltrim(cCODSTA)+"."+CHR(13)+; //"Cor do status já cadastrado para o Status"
            STR0006,STR0004)  //"Informe outra cor para o status."###"NÃO CONFORMIDADE"
      Return .F.
   EndIf 

Return .T. 
