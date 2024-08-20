#INCLUDE 'TOTVS.CH'

/*
========================================================================================================================
Programa--------------: crma290x
Autor-----------------: Erivaldo Oliveira 
Data da Criação-------: 16/03/2020
========================================================================================================================
Descricao-------------: Na exclusao das Etapas, deleta AIJ e volta stagio no AD1_Stage. 
========================================================================================================================						   
Uso-------------------: CRM
========================================================================================================================
Parametros------------: Nenhum
========================================================================================================================
Retorno---------------: Nenhum
========================================================================================================================
*/

User Function crma180()
Local cIdPonto		:= Paramixb[2]
Local cIdModel		:= Paramixb[3]
Local oModel		:= FWLoadModel(cIdModel)
Local cchave		:= Substr(AOF->AOF_CHAVE,1,6)
Local cstage1		:= ""
Local cstageat		:= ""
Local cstagepro		:= ""		
Local lRetorno		:= .T.
Local crevisa		:= ""
Local cproven		:= ""
Local nfaz			:= ""
Local cUpd			:= ""
Local caofatu		:= aof->aof_xclass
Local xalias		:= getnextalias()
Local lcontinua		:= .t.
Local aqry			:= {}
Local cproxcod		:= ''
Local aFields		:= {}
Local nX
Local cchvreg		:= ""
Local cDescri		:= ""

If (cIdPonto == 'FORMCOMMITTTSPOS' .and. nCRM180MOp == 3 .and. m->aof_xclass == '2')

	If MsgYesNo("Gostaria de incluir tarefa de ligaçao ? ")

		beginsql alias xalias
			select * 
			from %table:aof% aof
			where aof.aof_filial = %exp:xfilial('aof')%
			and aof.aof_codigo = %exp:aof->aof_codigo%
			and aof.%notdel%
		endsql
		
		cproxcod := soma1((xalias)->aof_codigo)
		
		DbSelectArea("SX3")
		DbSetOrder(1)
		SX3->(DbSeek("AOF"))
		
		While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "AOF"
			
			If SX3->X3_CONTEXT <> "V" .and. (SX3->X3_CAMPO <> 'AOF_CODIGO' .and. ;
				SX3->X3_CAMPO <> 'AOF_DTCAD' .and. SX3->X3_CAMPO <> 'AOF_DESCRI' .and. ;
				SX3->X3_CAMPO <> 'AOF_XCLASS' .and. SX3->X3_CAMPO <> 'AOF_XAVTAR' .and. ;
				SX3->X3_CAMPO <> 'AOF_DTCAD' .and. SX3->X3_CAMPO <> 'AOF_DTINIC' .and. ;
				SX3->X3_CAMPO <> 'AOF_DTFIM' .and. SX3->X3_CAMPO <> 'AOF_DTCONC' .and. ;
				SX3->X3_CAMPO <> 'AOF_DTLEMB' .and. SX3->X3_CAMPO <> 'AOF_DTAEMA' .and. ;
				SX3->X3_CAMPO <> 'AOF_LNKIMG' ) 
				If X3Uso(SX3->X3_USADO)
					AADD(aFields,SX3->X3_CAMPO)
				EndIf            
		    endif
			SX3->(DbSkip())
	
		Enddo 			

		MSGINFO(cDescri)
		cDescri := MSMM(AOF->AOF_DESCRI,,,Space(250),3,1,.T.,"AOF","AOF_DESCRI")
		MSGINFO(cDescri)

		Reclock("aof",.T.)
		aof->aof_filial := (xalias)->aof_filial
		aof->aof_codigo := cproxcod
		aof->aof_xclass := '1'
		aof->aof_xavtar := 'Sucesso de atendimento'
		aof->aof_dtcad  := stod((xalias)->aof_dtcad)
		aof->aof_dtinic := stod((xalias)->aof_dtinic)
		aof->aof_dtfim  := stod((xalias)->aof_dtfim)
		aof->aof_dtconc := stod((xalias)->aof_dtconc)
		aof->aof_dtlemb := stod((xalias)->aof_dtlemb)
		aof->aof_dtaema := stod((xalias)->aof_dtaema)
		aof->aof_descri := cDescri

		For nX := 1 to Len(aFields)
			
			if !aFields[nx] $ "aof_filial/aof_codigo/aof_xclass/aof_xavtar/aof_descri/aof_dtlemb/aof_dtaema/aof_lnkimg"
				
				&("aof->"+aFields[nx]) := &("(xalias)->"+aFields[nx])				
			
			endif
			
		Next nx

		aof->(MsUnlock())
		
		cchvreg := alltrim((xalias)->aof_filial)+alltrim((xalias)->aof_codigo)
		
		Reclock("ao4",.T.)
		ao4->ao4_filial := substr(aof->aof_filial,1,2) 
		ao4->ao4_entida := 'AOF'
		ao4->ao4_chvreg := alltrim(aof->aof_filial)+cproxcod		
		ao4->ao4_codusr := retcodusr()		
		ao4->ao4_ctrltt := .T.		
		ao4->ao4_pervis := .F.
		ao4->ao4_peredt := .F.
		ao4->ao4_perexc := .F.
		ao4->ao4_percom := .F.
		ao4->ao4_nvestn := 0
		ao4->ao4_propri := .F.
		ao4->ao4_tpaces := '1'
		ao4->ao4_priori := '0'																	
		ao4->(msunlock())
		
		(xalias)->(dbclosearea())
		
		Msginfo('Tarefa incluída.')

	Endif
	
Endif

If valtype(omodel) == "O"

  	If cIdPonto == 'MODELPOS' .and. nCRM180MOp == 5 //Variavel da rotina padrao, que define a operação.
  	
		DbSelectArea("AD1")
		DbSetOrder(1)
		
		DbSelectArea("AIJ")
		DbSetOrder(1)

		If AD1->(DbSeek(xFilial("AD1")+cchave))
			
			If (( ad1->ad1_stage <> '000001' .and. ad1->ad1_stage <> '000004' .and. "Atende" $ aof->aof_xavtar) .or. ;
			 	( ad1->ad1_stage <> '000001' .and. ad1->ad1_stage <> '000004' .and. "Aceita" $ aof->aof_xavtar)) 

	   			
	   			cstageatu := ad1->ad1_stage			//Stagio atual	
	   			cstage1 := tira1(ad1->ad1_stage)	//Stagio menos 1
	
				cstagepro	:= soma1(cstageatu)
				
	   			crevisa	:= AD1->AD1_REVISA
	   			cproven := AD1->AD1_PROVEN

	  			
	   			beginsql alias xalias
		   			select aof_xclass
		   			from %table:aof% aof
		   			where aof.aof_filial = %exp:xfilial("aof")% and
		   			aof.aof_chave = %exp:cchave% and
		   			aof.%notdel%
	   			endsql

	   			aqry := getlastquery()
	   			memowrite(gettemppath()+'crma180x.txt',aqry[2])
	   			
	   			while !(xalias)->(eof())
	   				if val((xalias)->aof_xclass) > val(caofatu)
	   					MsgStop("Nao é possivel excluir essa etapa, sem excluir a etapa posterior a essa.")
	   					lcontinua := .f.
	   					(xalias)->(dbclosearea())
	   					return(lcontinua)
	   				endif
	   				(xalias)->(dbskip())
	   			enddo
				
				If select((xalias)) > 0
					(xalias)->(dbclosearea())
				endif
				
				reclock("AD1",.f.)
				ad1->ad1_stage := cstage1
				AD1->(MsUnlock())
	   				
	   			DbSelectArea("AIJ")
	   			DbSetOrder(1)
	   				
	   			//Deleta AIJ	
	   			If AIJ->(DbSeek(xfilial("AIJ")+cchave+crevisa+cproven+cstageatu))
	   				
	   				RecLock("AIJ",.f.)
	   				DBDELETE()   					
	   				AIJ->(MsUnlock())
	   					
	   			Else
	   					
	   				Msginfo("nao encontrou AIJ")
	   				
	   			Endif
	   		
	   		Endif

	   		If (aof->aof_xclass == '1' .and. "Sucesso" $ aof->aof_xavtar ;
	   			.and. (ad1->ad1_xoport <> '1' .and. ad1->ad1_xoport <> '2')) 
							
	   			cstageatu := ad1->ad1_stage			//Stagio atual	
	   			cstage1 := tira1(ad1->ad1_stage)	//Stagio menos 1
				
				cstagepro	:= soma1(cstageatu)
				
	   			crevisa	:= AD1->AD1_REVISA
	   			cproven := AD1->AD1_PROVEN

	   			beginsql alias xalias
		   			select aof_xclass
		   			from %table:aof% aof
		   			where aof.aof_filial = %exp:xfilial("aof")% and
		   			aof.aof_chave = %exp:cchave% and
		   			aof.%notdel%
	   			endsql
	   			
	   			aqry := getlastquery()
	   			memowrite(gettemppath()+'crma180b.txt',aqry[2])
	   			
	   			while !(xalias)->(eof())
	   				if val((xalias)->aof_xclass) > val(caofatu)
	   					MsgStop("Nao é possivel excluir essa etapa, sem excluir a etapa posterior a essa.")
	   					lcontinua := .f.
	   					(xalias)->(dbclosearea())
	   					return(lcontinua)
	   				endif
	   				(xalias)->(dbskip())
	   			enddo

	   			If select((xalias)) > 0
					(xalias)->(dbclosearea())
				endif

				reclock("AD1",.f.)
				ad1->ad1_stage := cstage1
				AD1->(MsUnlock())
	   				
   	   			DbSelectArea("AIJ")
	   			DbSetOrder(1)
	   				
	   			//Deleta AIJ	
	   			If AIJ->(DbSeek(xfilial("AIJ")+cchave+crevisa+cproven+cstageatu))
	   				RecLock("AIJ",.f.)
	   				DBDELETE()   					
	   				AIJ->(MsUnlock())
	   			Else
	   				Msginfo("nao encontrou AIJ")
	   			Endif
	   		
	   		Endif

	   		
	   		If ((aof->aof_xclass == '4' .and. "Semi novos" $ aof->aof_xavtar) .or. ;
				(aof->aof_xclass == '4' .and. "Peças" $ aof->aof_xavtar) .or. ;
				(aof->aof_xclass == '4' .and. "Simples" $ aof->aof_xavtar) .or. ;
				(aof->aof_xclass == '4' .and. "Novo" $ aof->aof_xavtar) .or. ;
				(aof->aof_xclass == '4' .and. "Reformado" $ aof->aof_xavtar) .or. ;
				(aof->aof_xclass == '4' .and. "Aquisição" $ aof->aof_xavtar)) 				
							
	   			cstageatu := ad1->ad1_stage			//Stagio atual	
	   			cstage1 := tira1(ad1->ad1_stage)	//Stagio menos 1
				
				cstagepro	:= soma1(cstageatu)
				
	   			crevisa	:= AD1->AD1_REVISA
	   			cproven := AD1->AD1_PROVEN

	   			beginsql alias xalias
		   			select aof_xclass
		   			from %table:aof% aof
		   			where aof.aof_filial = %exp:xfilial("aof")% and
		   			aof.aof_chave = %exp:cchave% and
		   			aof.%notdel%
	   			endsql
	   			
	   			aqry := getlastquery()
	   			memowrite(gettemppath()+'crma180b.txt',aqry[2])
	   			
	   			while !(xalias)->(eof())
	   				if val((xalias)->aof_xclass) > val(caofatu)
	   					MsgStop("Nao é possivel excluir essa etapa, sem excluir a etapa posterior a essa.")
	   					lcontinua := .f.
	   					(xalias)->(dbclosearea())
	   					return(lcontinua)
	   				endif
	   				(xalias)->(dbskip())
	   			enddo

				If select((xalias)) > 0
					(xalias)->(dbclosearea())
				endif

				reclock("AD1",.f.)
				ad1->ad1_stage := cstage1
				AD1->(MsUnlock())
	   				
   	   			DbSelectArea("AIJ")
	   			DbSetOrder(1)
	   				
	   			//Deleta AIJ	
	   			If AIJ->(DbSeek(xfilial("AIJ")+cchave+crevisa+cproven+cstageatu))
	   				RecLock("AIJ",.f.)
	   				DBDELETE()   					
	   				AIJ->(MsUnlock())
	   					
	   			Else
	   					
	   				Msginfo("nao encontrou AIJ")
	   				
	   			Endif
	   		
	   		Endif
	   		
	   		//So volta stagio 000004, quando descricao continver "Atende"
			If (aof->aof_xclass == '5' .and. "Atende" $ aof->aof_xavtar) 
			
	   			cstageatu := ad1->ad1_stage			//Stagio atual	
	   			cstage1 := tira1(ad1->ad1_stage)	//Stagio menos 1
				
				cstagepro	:= soma1(cstageatu)
				
	   			crevisa	:= AD1->AD1_REVISA
	   			cproven := AD1->AD1_PROVEN

	   			beginsql alias xalias
		   			select aof_xclass
		   			from %table:aof% aof
		   			where aof.aof_filial = %exp:xfilial("aof")% and
		   			aof.aof_chave = %exp:cchave% and
		   			aof.%notdel%
	   			endsql
	   			
	   			while !(xalias)->(eof())
	   				if val((xalias)->aof_xclass) > val(caofatu)
	   					MsgStop("Nao é possivel excluir essa etapa, sem excluir a etapa posterior a essa.")
	   					lcontinua := .f.
	   					(xalias)->(dbclosearea())
	   					return(lcontinua)
	   				endif
	   				(xalias)->(dbskip())
	   			enddo
	   			
				If select((xalias)) > 0
					(xalias)->(dbclosearea())
				endif
  			

				reclock("AD1",.f.)
				ad1->ad1_stage := cstage1
				AD1->(MsUnlock())
	   				
	   			DbSelectArea("AIJ")
	   			DbSetOrder(1)
	   				
	   			//Deleta AIJ	
	   			If AIJ->(DbSeek(xfilial("AIJ")+cchave+crevisa+cproven+cstageatu))
	   				
	   				RecLock("AIJ",.f.)
	   				DBDELETE()   					
	   				AIJ->(MsUnlock())
	   					
	   			Else
	   					
	   				Msginfo("nao encontrou AIJ")
	   				
	   			Endif
	   		
	   		Endif

	   		
   		Else

   			msginfo("nao encontrou AD1 : "+xFilial("AD1")+cchave)

   		Endif

   	Endif

   	//Entrou nas opcoes personalizadas...
   	If type("aEtapas") <> "U"
   	
	  	If cIdPonto == 'MODELPOS' .and. nCRM180MOp == 3 .and. len(aEtapas)  > 0//Variavel da rotina padrao, que define a operação.
		
			cUpd := " update "+ RetSqlName("AD1")
			cUpd += " SET 
			cUpd += " 	 AD1_STAGE = '"+aetapas[1][2]+"'"
			cUpd += " where "
			cUpd += "    D_E_L_E_T_ <> '*'"
			cUpd += "    AND AD1_FILIAL = '"+XFILIAL("AD1")+"'"
			cUpd += "    AND AD1_NROPOR = '"+aetapas[2][2]+"'"
			
			if TCSqlExec(cUpd) < 0
				MSGINFO("TCSQLError() " + TCSQLError())
			else
				reclock("AIJ",.T.)
				aij->aij_filial	:= aEtapas[3][2]
				aij->aij_nropor	:= aEtapas[4][2]
				aij->aij_revisa := aEtapas[5][2]
				aij->aij_proven := aEtapas[6][2]
				aij->aij_stage  := aEtapas[7][2]
				aij->aij_dtinic := aEtapas[8][2]
				aij->aij_hrinic := aEtapas[9][2]
				aij->aij_histor := aEtapas[10][2]
				AIJ->(MsUnlock())
			endif
		
		Endif

	Endif
	
Endif

Return(lRetorno)