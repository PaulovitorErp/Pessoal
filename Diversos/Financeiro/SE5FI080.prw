#INCLUDE "PROTHEUS.CH"
 
User Function SE5FI080()
 
Local cCamposE5 := ParamIxb[1]
Local oSubModel := ParamIxb[2]
 
//------------------------------------------------------------------------
//-- Gravação do registro principal da baixa (SE5 e FK2)
If oSubModel:cID == "FK2DETAIL"
    If "DEB" $ oSubModel:GetValue("FK2_MOTBX")
        //-- SE5
        cCamposE5 += ",{"
        cCamposE5 += " 'E5_NATUREZ','Campo customizado.' "
        cCamposE5 += "} "
 
        //--FK2
        oSubModel:SetValue("FK2_CUSTOM","Campo customizado.")
    EndIf
EndIf
