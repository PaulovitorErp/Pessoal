#INCLUDE "MNTA689.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA689()
Percentuais de desgastes limitantes por componente
@author Evaldo Cevinscki Jr.
@since 27/05/2010
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Function MNTA689(cCodBem)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Guarda conteudo e declara variaveis padroes ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aNGBEGINPRM := NGBEGINPRM()

Local nAltura   	:= (GetScreenRes()[2]*0.6)
Local nLargura  	:= (GetScreenRes()[1]/2)
Local oFont14N		:= TFont():New("Arial",,14,,.T.,,,,.F.,.F.)
Local nOpca			:= 0
Local lCarregou   := .f.
Local lWhenCamp	:= If(Inclui .or. Altera, .t.,.f.)

Private oScrollBox
Private aSize := MsAdvSize(,.f.,430), aObjects := {}
Private aCampos := {}
Private nOpc := 0

If Inclui
	MsgStop(STR0001,STR0002) //"Opção indisponível para inclusão!"###"ATENÇÃO"
	Return
Endif

If IsInCallStack('NG120FOLD')
	aCampos := {"M->TF_PADRAO","STF->TF_PADRAO",;
					"STF->TF_CODBEM","STF->TF_SERVICO",;
					"STF->TF_SEQRELA","ST9->T9_CODFAMI","ST9->T9_TIPMOD"}
					nOpc := 1
ElseIf FunName() == "MNTA080"
	aCampos := {"M->T9_PADRAO","ST9->T9_PADRAO",;
					"ST9->T9_CODBEM",,,"ST9->T9_CODFAMI","ST9->T9_TIPMOD"}
					nOpc := 2
EndIf

//se for alterar o campo padrao para 's' traz dados da manutenção padrao
If Altera .AND. &(aCampos[1]) == 'S' .AND. &(aCampos[2]) == 'N'
	DbSelectArea("TVK")
	DbSetOrder(1)
	If !DbSeek(xFilial("TVK")+&(aCampos[3])+If(nOpc == 1,&(aCampos[4])+&(aCampos[5]),Space(Len(TVK->TVK_SERVIC))+Space(Len(TVK->TVK_SEQREL))))
		DbSelectArea("ST9")
		DbSetOrder(1)
		DbSeek(xFilial("ST9")+&(aCampos[3]))

		DbSelectArea("TVI")
		DbSetOrder(1)
		If DbSeek(xFilial("TVI")+&(aCampos[6])+&(aCampos[7])+If(nOpc == 1,&(aCampos[4]),Space(Len(TVK->TVK_SERVIC))))
			M->TVK_ELOPAV := IIF(TVI->TVI_ELOPAV <> 0,TVI->TVI_ELOPAV,0)
			M->TVK_BUCPAV	:= IIF(TVI->TVI_BUCPAV <> 0,TVI->TVI_BUCPAV,0)
			M->TVK_SAPPAV := IIF(TVI->TVI_SAPPAV <> 0,TVI->TVI_SAPPAV,0)
			M->TVK_RDDPAV	:= IIF(TVI->TVI_RDDPAV <> 0,TVI->TVI_RDDPAV,0)
			M->TVK_RDTPAV := IIF(TVI->TVI_RDTPAV <> 0,TVI->TVI_RDTPAV,0)
			M->TVK_ELOPOS	:= IIF(TVI->TVI_ELOPOS <> 0,TVI->TVI_ELOPOS,0)
			M->TVK_BUCPOS	:= IIF(TVI->TVI_BUCPOS <> 0,TVI->TVI_BUCPOS,0)
			M->TVK_SAPPOS	:= IIF(TVI->TVI_SAPPOS <> 0,TVI->TVI_SAPPOS,0)
			M->TVK_RDDPOS	:= IIF(TVI->TVI_RDDPOS <> 0,TVI->TVI_RDDPOS,0)
			M->TVK_RDTPOS	:= IIF(TVI->TVI_RDTPOS <> 0,TVI->TVI_RDTPOS,0)
			M->TVK_RE1PAV	:= IIF(TVI->TVI_RE1PAV <> 0,TVI->TVI_RE1PAV,0)
			M->TVK_RE2PAV	:= IIF(TVI->TVI_RE2PAV <> 0,TVI->TVI_RE2PAV,0)
			M->TVK_RE3PAV	:= IIF(TVI->TVI_RE3PAV <> 0,TVI->TVI_RE3PAV,0)
			M->TVK_RE4PAV	:= IIF(TVI->TVI_RE4PAV <> 0,TVI->TVI_RE4PAV,0)
			M->TVK_RE5PAV	:= IIF(TVI->TVI_RE5PAV <> 0,TVI->TVI_RE5PAV,0)
			M->TVK_RE6PAV	:= IIF(TVI->TVI_RE6PAV <> 0,TVI->TVI_RE6PAV,0)
			M->TVK_RE7PAV	:= IIF(TVI->TVI_RE7PAV <> 0,TVI->TVI_RE7PAV,0)
			M->TVK_RE8PAV	:= IIF(TVI->TVI_RE8PAV <> 0,TVI->TVI_RE8PAV,0)
			M->TVK_RDMPAV	:= IIF(TVI->TVI_RDMPAV <> 0,TVI->TVI_RDMPAV,0)
			M->TVK_RS1PAV	:= IIF(TVI->TVI_RS1PAV <> 0,TVI->TVI_RS1PAV,0)
			M->TVK_RS2PAV	:= IIF(TVI->TVI_RS2PAV <> 0,TVI->TVI_RS2PAV,0)
			M->TVK_RE1POS	:= IIF(TVI->TVI_RE1POS <> 0,TVI->TVI_RE1POS,0)
			M->TVK_RE2POS	:= IIF(TVI->TVI_RE2POS <> 0,TVI->TVI_RE2POS,0)
			M->TVK_RE3POS	:= IIF(TVI->TVI_RE3POS <> 0,TVI->TVI_RE3POS,0)
			M->TVK_RE4POS	:= IIF(TVI->TVI_RE4POS <> 0,TVI->TVI_RE4POS,0)
			M->TVK_RE5POS	:= IIF(TVI->TVI_RE5POS <> 0,TVI->TVI_RE5POS,0)
			M->TVK_RE6POS	:= IIF(TVI->TVI_RE6POS <> 0,TVI->TVI_RE6POS,0)
			M->TVK_RE7POS	:= IIF(TVI->TVI_RE7POS <> 0,TVI->TVI_RE7POS,0)
			M->TVK_RE8POS	:= IIF(TVI->TVI_RE8POS <> 0,TVI->TVI_RE8POS,0)
			M->TVK_RDMPOS	:= IIF(TVI->TVI_RDMPOS <> 0,TVI->TVI_RDMPOS,0)
			M->TVK_RS1POS	:= IIF(TVI->TVI_RS1POS <> 0,TVI->TVI_RS1POS,0)
			M->TVK_RS2POS	:= IIF(TVI->TVI_RS2POS <> 0,TVI->TVI_RS2POS,0)
			M->TVK_SERELO	:= IIF(Empty(TVI->TVI_SERELO),Space(Len(TVI->TVI_SERELO)),TVI->TVI_SERELO)
			M->TVK_SERBUC	:= IIF(Empty(TVI->TVI_SERBUC),Space(Len(TVI->TVI_SERBUC)),TVI->TVI_SERBUC)
			M->TVK_SERSAP	:= IIF(Empty(TVI->TVI_SERSAP),Space(Len(TVI->TVI_SERSAP)),TVI->TVI_SERSAP)
			M->TVK_SERSAP	:= IIF(Empty(TVI->TVI_SERRDD),Space(Len(TVI->TVI_SERRDD)),TVI->TVI_SERRDD)
			M->TVK_SERRDT	:= IIF(Empty(TVI->TVI_SERRDT),Space(Len(TVI->TVI_SERRDT)),TVI->TVI_SERRDT)
			M->TVK_SERRS1	:= IIF(Empty(TVI->TVI_SERRS1),Space(Len(TVI->TVI_SERRS1)),TVI->TVI_SERRS1)
			M->TVK_SERRS2	:= IIF(Empty(TVI->TVI_SERRS2),Space(Len(TVI->TVI_SERRS2)),TVI->TVI_SERRS2)
			M->TVK_SERRE1	:= IIF(Empty(TVI->TVI_SERRE1),Space(Len(TVI->TVI_SERRE1)),TVI->TVI_SERRE1)
			M->TVK_SERRE2	:= IIF(Empty(TVI->TVI_SERRE2),Space(Len(TVI->TVI_SERRE2)),TVI->TVI_SERRE2)
			M->TVK_SERRE3	:= IIF(Empty(TVI->TVI_SERRE3),Space(Len(TVI->TVI_SERRE3)),TVI->TVI_SERRE3)
			M->TVK_SERRE4	:= IIF(Empty(TVI->TVI_SERRE4),Space(Len(TVI->TVI_SERRE4)),TVI->TVI_SERRE4)
			M->TVK_SERRE5	:= IIF(Empty(TVI->TVI_SERRE5),Space(Len(TVI->TVI_SERRE5)),TVI->TVI_SERRE5)
			M->TVK_SERRE6	:= IIF(Empty(TVI->TVI_SERRE6),Space(Len(TVI->TVI_SERRE6)),TVI->TVI_SERRE6)
			M->TVK_SERRE7	:= IIF(Empty(TVI->TVI_SERRE7),Space(Len(TVI->TVI_SERRE7)),TVI->TVI_SERRE7)
			M->TVK_SERRE8	:= IIF(Empty(TVI->TVI_SERRE8),Space(Len(TVI->TVI_SERRE8)),TVI->TVI_SERRE8)
			M->TVK_SERRDM	:= IIF(Empty(TVI->TVI_SERRDM),Space(Len(TVI->TVI_SERRDM)),TVI->TVI_SERRDM)
			lCarregou := .t.
		Endif
	Endif
Endif

If !lCarregou
	DbSelectArea("TVK")
	DbSetOrder(1)
	DbSeek(xFilial("TVK")+&(aCampos[3])+If(nOpc == 1,&(aCampos[4])+&(aCampos[5]),Space(Len(TVK->TVK_SERVIC))+Space(Len(TVK->TVK_SEQREL))))
	M->TVK_ELOPAV	:= IIF(TVK->TVK_ELOPAV <> 0,TVK->TVK_ELOPAV,0)
	M->TVK_BUCPAV	:= IIF(TVK->TVK_BUCPAV <> 0,TVK->TVK_BUCPAV,0)
	M->TVK_SAPPAV	:= IIF(TVK->TVK_SAPPAV <> 0,TVK->TVK_SAPPAV,0)
	M->TVK_RDDPAV	:= IIF(TVK->TVK_RDDPAV <> 0,TVK->TVK_RDDPAV,0)
	M->TVK_RDTPAV	:= IIF(TVK->TVK_RDTPAV <> 0,TVK->TVK_RDTPAV,0)
	M->TVK_ELOPOS	:= IIF(TVK->TVK_ELOPOS <> 0,TVK->TVK_ELOPOS,0)
	M->TVK_BUCPOS	:= IIF(TVK->TVK_BUCPOS <> 0,TVK->TVK_BUCPOS,0)
	M->TVK_SAPPOS	:= IIF(TVK->TVK_SAPPOS <> 0,TVK->TVK_SAPPOS,0)
	M->TVK_RDDPOS	:= IIF(TVK->TVK_RDDPOS <> 0,TVK->TVK_RDDPOS,0)
	M->TVK_RDTPOS	:= IIF(TVK->TVK_RDTPOS <> 0,TVK->TVK_RDTPOS,0)
	M->TVK_RE1PAV	:= IIF(TVK->TVK_RE1PAV <> 0,TVK->TVK_RE1PAV,0)
	M->TVK_RE2PAV	:= IIF(TVK->TVK_RE2PAV <> 0,TVK->TVK_RE2PAV,0)
	M->TVK_RE3PAV	:= IIF(TVK->TVK_RE3PAV <> 0,TVK->TVK_RE3PAV,0)
	M->TVK_RE4PAV	:= IIF(TVK->TVK_RE4PAV <> 0,TVK->TVK_RE4PAV,0)
	M->TVK_RE5PAV	:= IIF(TVK->TVK_RE5PAV <> 0,TVK->TVK_RE5PAV,0)
	M->TVK_RE6PAV	:= IIF(TVK->TVK_RE6PAV <> 0,TVK->TVK_RE6PAV,0)
	M->TVK_RE7PAV	:= IIF(TVK->TVK_RE7PAV <> 0,TVK->TVK_RE7PAV,0)
	M->TVK_RE8PAV	:= IIF(TVK->TVK_RE8PAV <> 0,TVK->TVK_RE8PAV,0)
	M->TVK_RDMPAV	:= IIF(TVK->TVK_RDMPAV <> 0,TVK->TVK_RDMPAV,0)
	M->TVK_RS1PAV	:= IIF(TVK->TVK_RS1PAV <> 0,TVK->TVK_RS1PAV,0)
	M->TVK_RS2PAV	:= IIF(TVK->TVK_RS2PAV <> 0,TVK->TVK_RS2PAV,0)
	M->TVK_RE1POS	:= IIF(TVK->TVK_RE1POS <> 0,TVK->TVK_RE1POS,0)
	M->TVK_RE2POS	:= IIF(TVK->TVK_RE2POS <> 0,TVK->TVK_RE2POS,0)
	M->TVK_RE3POS	:= IIF(TVK->TVK_RE3POS <> 0,TVK->TVK_RE3POS,0)
	M->TVK_RE4POS	:= IIF(TVK->TVK_RE4POS <> 0,TVK->TVK_RE4POS,0)
	M->TVK_RE5POS	:= IIF(TVK->TVK_RE5POS <> 0,TVK->TVK_RE5POS,0)
	M->TVK_RE6POS	:= IIF(TVK->TVK_RE6POS <> 0,TVK->TVK_RE6POS,0)
	M->TVK_RE7POS	:= IIF(TVK->TVK_RE7POS <> 0,TVK->TVK_RE7POS,0)
	M->TVK_RE8POS	:= IIF(TVK->TVK_RE8POS <> 0,TVK->TVK_RE8POS,0)
	M->TVK_RDMPOS	:= IIF(TVK->TVK_RDMPOS <> 0,TVK->TVK_RDMPOS,0)
	M->TVK_RS1POS	:= IIF(TVK->TVK_RS1POS <> 0,TVK->TVK_RS1POS,0)
	M->TVK_RS2POS	:= IIF(TVK->TVK_RS2POS <> 0,TVK->TVK_RS2POS,0)
	M->TVK_SERELO	:= IIF(Empty(TVK->TVK_SERELO),Space(Len(TVK->TVK_SERELO)),TVK->TVK_SERELO)
	M->TVK_SERBUC	:= IIF(Empty(TVK->TVK_SERBUC),Space(Len(TVK->TVK_SERBUC)),TVK->TVK_SERBUC)
	M->TVK_SERSAP	:= IIF(Empty(TVK->TVK_SERSAP),Space(Len(TVK->TVK_SERSAP)),TVK->TVK_SERSAP)
	M->TVK_SERSAP	:= IIF(Empty(TVK->TVK_SERRDD),Space(Len(TVK->TVK_SERRDD)),TVK->TVK_SERRDD)
	M->TVK_SERRDT	:= IIF(Empty(TVK->TVK_SERRDT),Space(Len(TVK->TVK_SERRDT)),TVK->TVK_SERRDT)
	M->TVK_SERRS1	:= IIF(Empty(TVK->TVK_SERRS1),Space(Len(TVK->TVK_SERRS1)),TVK->TVK_SERRS1)
	M->TVK_SERRS2	:= IIF(Empty(TVK->TVK_SERRS2),Space(Len(TVK->TVK_SERRS2)),TVK->TVK_SERRS2)
	M->TVK_SERRE1	:= IIF(Empty(TVK->TVK_SERRE1),Space(Len(TVK->TVK_SERRE1)),TVK->TVK_SERRE1)
	M->TVK_SERRE2	:= IIF(Empty(TVK->TVK_SERRE2),Space(Len(TVK->TVK_SERRE2)),TVK->TVK_SERRE2)
	M->TVK_SERRE3	:= IIF(Empty(TVK->TVK_SERRE3),Space(Len(TVK->TVK_SERRE3)),TVK->TVK_SERRE3)
	M->TVK_SERRE4	:= IIF(Empty(TVK->TVK_SERRE4),Space(Len(TVK->TVK_SERRE4)),TVK->TVK_SERRE4)
	M->TVK_SERRE5	:= IIF(Empty(TVK->TVK_SERRE5),Space(Len(TVK->TVK_SERRE5)),TVK->TVK_SERRE5)
	M->TVK_SERRE6	:= IIF(Empty(TVK->TVK_SERRE6),Space(Len(TVK->TVK_SERRE6)),TVK->TVK_SERRE6)
	M->TVK_SERRE7	:= IIF(Empty(TVK->TVK_SERRE7),Space(Len(TVK->TVK_SERRE7)),TVK->TVK_SERRE7)
	M->TVK_SERRE8	:= IIF(Empty(TVK->TVK_SERRE8),Space(Len(TVK->TVK_SERRE8)),TVK->TVK_SERRE8)
	M->TVK_SERRDM	:= IIF(Empty(TVK->TVK_SERRDM),Space(Len(TVK->TVK_SERRDM)),TVK->TVK_SERRDM)
Endif

/*Declaração de Variaveis Private dos Objetos*/
SetPrvt("oDlg1","oPanel1","oSay1","oSay2","oSay3","oSay4","oSay5","oSay6","oSay7","oSay8","oSay9","oSay10")
SetPrvt("oSay12","oSay13","oSay14","oSay15","oSay16","oGet1","oGet2","oCBox1","oGet3","oGet4","oGet5")
SetPrvt("oGet7","oGet8","oGet9","oGet10","oGet11","oGet12","oGet13","oGet14","oGet15","oGet16","oGet17")
SetPrvt("oGet19","oGet20")

Define MsDialog oDlg1 Title STR0003 From 0,0 To nAltura,nLargura Of oMainWnd Pixel COLOR CLR_BLACK,CLR_WHITE  //"Percentual de Desgaste Limitante por Componente"
oDlg1:lMaximized := .T.
Aadd(aObjects,{150,10,.T.,.T.}) // Indica dimensoes x e y e indica que redimensiona x e y
Aadd(aObjects,{200,30,.T.,.T.}) // Indica dimensoes x e y e indica que redimensiona x e y e assume que retorno sera em linha final coluna final (.F.)

aSize:=MsAdvSize()
aInfo:={aSize[1],aSize[2],aSize[3],aSize[4],3,3}
aPosObj:=MsObjSize(aInfo,aObjects,.T.)

oPanel1   		:= TScrollBox():new(oDlg1, 003,003, aPosObj[2,3]-aPosObj[2,1] - 20, ((aPosObj[2,4]) / 2) + 10 , .T., .T., .T.)
oPanel1:Align 	:= CONTROL_ALIGN_ALLCLIENT

oSay4      := TSay():New( 010,012,{||STR0004},oPanel1,,oFont14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,032,008) //"Conjuntos"
oSay5      := TSay():New( 010,154,{||STR0005},oPanel1,,oFont14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,070,008) //"Controles"

oSay7      := TSay():New( 025,112,{||STR0006},oPanel1,,oFont14N,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,026,008) //"%Aviso"
oSay8      := TSay():New( 025,156,{||STR0007},oPanel1,,oFont14N,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,035,008) //"%Gerar O.S."
oSay9      := TSay():New( 025,196,{||STR0008},oPanel1,,oFont14N,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,024,008) //"Serviço"

oSay10     := TSay():New( 039,012,{||STR0009},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)           //"Elos"
oSay11     := TSay():New( 052,012,{||STR0010},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008) //"Buchas"
oSay12     := TSay():New( 065,012,{||STR0011},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008) //"Sapatas"
oSay13     := TSay():New( 078,012,{||STR0012},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,056,008) //"Rodas Guias Dianteira"
oSay14     := TSay():New( 091,012,{||STR0013},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,052,008) //"Rodas Guias Traseira"
oSay15     := TSay():New( 104,012,{||STR0014},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,052,008) //"Roletes Superior 1º"
oSay16     := TSay():New( 117,012,{||STR0015},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,048,008) //"Roletes Superior 2º"
oSay17     := TSay():New( 130,012,{||STR0016},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008) //"Roletes de Esteira 1º"
oSay18     := TSay():New( 143,012,{||STR0017},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008) //"Roletes de Esteira 2º"
oSay19     := TSay():New( 156,012,{||STR0018},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008) //"Roletes de Esteira 3º"
oSay20     := TSay():New( 169,012,{||STR0019},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008) //"Roletes de Esteira 4º"
oSay21     := TSay():New( 182,012,{||STR0020},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008) //"Roletes de Esteira 5º"
oSay22     := TSay():New( 195,012,{||STR0021},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008) //"Roletes de Esteira 6º"
oSay23     := TSay():New( 208,012,{||STR0022},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008) //"Roletes de Esteira 7º"
oSay24     := TSay():New( 221,012,{||STR0023},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008) //"Roletes de Esteira 8º"
oSay25     := TSay():New( 234,012,{||STR0024},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008) //"Rodas Motrizes"

//Elos
oGet3      := TGet():New( 037,112,{|u| If(PCount()>0,M->TVK_ELOPAV:=u,M->TVK_ELOPAV)},oPanel1,024,008,'@E 99.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"","M->TVK_ELOPAV",,,,.t.)
oGet4      := TGet():New( 037,153,{|u| If(PCount()>0,M->TVK_ELOPOS:=u,M->TVK_ELOPOS)},oPanel1,024,008,'@E 99.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"","M->TVK_ELOPOS",,,,.t.)
oGet5      := TGet():New( 037,195,{|u| If(PCount()>0,M->TVK_SERELO:=u,M->TVK_SERELO)},oPanel1,040,008,'@!',{|| If(!Empty(M->TVK_SERELO),EXISTCPO("ST4",M->TVK_SERELO),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"ST4","M->TVK_SERELO",,,,.t.)
//Buchas
oGet6      := TGet():New( 050,112,{|u| If(PCount()>0,M->TVK_BUCPAV:=u,M->TVK_BUCPAV)},oPanel1,024,008,'@E 99.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"","M->TVK_BUCPAV",,,,.t.)
oGet7      := TGet():New( 050,153,{|u| If(PCount()>0,M->TVK_BUCPOS:=u,M->TVK_BUCPOS)},oPanel1,024,008,'@E 99.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"","M->TVK_BUCPOS",,,,.t.)
oGet8      := TGet():New( 050,195,{|u| If(PCount()>0,M->TVK_SERBUC:=u,M->TVK_SERBUC)},oPanel1,040,008,'@!',{|| If(!Empty(M->TVK_SERBUC),EXISTCPO("ST4",M->TVK_SERBUC),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"ST4","M->TVK_SERBUC",,,,.t.)
//Sapatas
oGet9      := TGet():New( 063,112,{|u| If(PCount()>0,M->TVK_SAPPAV:=u,M->TVK_SAPPAV)},oPanel1,024,008,'@E 99.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"","M->TVK_SAPPAV",,,,.t.)
oGet10     := TGet():New( 063,153,{|u| If(PCount()>0,M->TVK_SAPPOS:=u,M->TVK_SAPPOS)},oPanel1,024,008,'@E 99.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"","M->TVK_SAPPOS",,,,.t.)
oGet11     := TGet():New( 063,195,{|u| If(PCount()>0,M->TVK_SERSAP:=u,M->TVK_SERSAP)},oPanel1,040,008,'@!',{|| If(!Empty(M->TVK_SERSAP),EXISTCPO("ST4",M->TVK_SERSAP),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"ST4","M->TVK_SERSAP",,,,.t.)
//Rodas guia dianteira
oGet12     := TGet():New( 076,112,{|u| If(PCount()>0,M->TVK_RDDPAV:=u,M->TVK_RDDPAV)},oPanel1,024,008,'@E 99.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"","M->TVK_RDDPAV",,,,.t.)
oGet13     := TGet():New( 076,153,{|u| If(PCount()>0,M->TVK_RDDPOS:=u,M->TVK_RDDPOS)},oPanel1,024,008,'@E 99.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"","M->TVK_RDDPOS",,,,.t.)
oGet14     := TGet():New( 076,195,{|u| If(PCount()>0,M->TVK_SERSAP:=u,M->TVK_SERSAP)},oPanel1,040,008,'@!',{|| If(!Empty(M->TVK_SERSAP),EXISTCPO("ST4",M->TVK_SERSAP),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"ST4","M->TVK_SERSAP",,,,.t.)
//Rodas guia traseira
oGet15     := TGet():New( 089,112,{|u| If(PCount()>0,M->TVK_RDTPAV:=u,M->TVK_RDTPAV)},oPanel1,024,008,'@E 99.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"","M->TVK_RDTPAV",,,,.t.)
oGet16     := TGet():New( 089,153,{|u| If(PCount()>0,M->TVK_RDTPOS:=u,M->TVK_RDTPOS)},oPanel1,024,008,'@E 99.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"","M->TVK_RDTPOS",,,,.t.)
oGet17     := TGet():New( 089,195,{|u| If(PCount()>0,M->TVK_SERRDT:=u,M->TVK_SERRDT)},oPanel1,040,008,'@!',{|| If(!Empty(M->TVK_SERRDT),EXISTCPO("ST4",M->TVK_SERRDT),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"ST4","M->TVK_SERRDT",,,,.t.)
//Roletes superior 1o
oGet18     := TGet():New( 102,112,{|u| If(PCount()>0,M->TVK_RS1PAV:=u,M->TVK_RS1PAV)},oPanel1,024,008,'@E 99.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"","M->TVK_RS1PAV",,,,.t.)
oGet19     := TGet():New( 102,153,{|u| If(PCount()>0,M->TVK_RS1POS:=u,M->TVK_RS1POS)},oPanel1,024,008,'@E 99.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"","M->TVK_RS1POS",,,,.t.)
oGet20     := TGet():New( 102,195,{|u| If(PCount()>0,M->TVK_SERRS1:=u,M->TVK_SERRS1)},oPanel1,040,008,'@!',{|| If(!Empty(M->TVK_SERRS1),EXISTCPO("ST4",M->TVK_SERRS1),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"ST4","M->TVK_SERRS1",,,,.t.)
//Roletes superior 2o
oGet21     := TGet():New( 115,112,{|u| If(PCount()>0,M->TVK_RS2PAV:=u,M->TVK_RS2PAV)},oPanel1,024,008,'@E 99.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"","M->TVK_RS2PAV",,,,.t.)
oGet22     := TGet():New( 115,153,{|u| If(PCount()>0,M->TVK_RS2POS:=u,M->TVK_RS2POS)},oPanel1,024,008,'@E 99.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"","M->TVK_RS2POS",,,,.t.)
oGet23     := TGet():New( 115,195,{|u| If(PCount()>0,M->TVK_SERRS2:=u,M->TVK_SERRS2)},oPanel1,040,008,'@!',{|| If(!Empty(M->TVK_SERRS2),EXISTCPO("ST4",M->TVK_SERRS2),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"ST4","M->TVK_SERRS2",,,,.t.)
//Roletes de esteira 1o
oGet24     := TGet():New( 128,112,{|u| If(PCount()>0,M->TVK_RE1PAV:=u,M->TVK_RE1PAV)},oPanel1,024,008,'@E 99.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"","M->TVK_RE1PAV",,,,.t.)
oGet25     := TGet():New( 128,153,{|u| If(PCount()>0,M->TVK_RE1POS:=u,M->TVK_RE1POS)},oPanel1,024,008,'@E 99.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"","M->TVK_RE1POS",,,,.t.)
oGet26     := TGet():New( 128,195,{|u| If(PCount()>0,M->TVK_SERRE1:=u,M->TVK_SERRE1)},oPanel1,040,008,'@!',{|| If(!Empty(M->TVK_SERRE1),EXISTCPO("ST4",M->TVK_SERRE1),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"ST4","M->TVK_SERRE1",,,,.t.)
//Roletes de esteira 2o
oGet27     := TGet():New( 141,112,{|u| If(PCount()>0,M->TVK_RE2PAV:=u,M->TVK_RE2PAV)},oPanel1,024,008,'@E 99.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"","M->TVK_RE2PAV",,,,.t.)
oGet28     := TGet():New( 141,153,{|u| If(PCount()>0,M->TVK_RE2POS:=u,M->TVK_RE2POS)},oPanel1,024,008,'@E 99.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"","M->TVK_RE2POS",,,,.t.)
oGet29     := TGet():New( 141,195,{|u| If(PCount()>0,M->TVK_SERRE2:=u,M->TVK_SERRE2)},oPanel1,040,008,'@!',{|| If(!Empty(M->TVK_SERRE2),EXISTCPO("ST4",M->TVK_SERRE2),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"ST4","M->TVK_SERRE2",,,,.t.)
//Roletes de esteira 3o
oGet30     := TGet():New( 154,112,{|u| If(PCount()>0,M->TVK_RE3PAV:=u,M->TVK_RE3PAV)},oPanel1,024,008,'@E 99.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"","M->TVK_RE3PAV",,,,.t.)
oGet31     := TGet():New( 154,153,{|u| If(PCount()>0,M->TVK_RE3POS:=u,M->TVK_RE3POS)},oPanel1,024,008,'@E 99.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"","M->TVK_RE3POS",,,,.t.)
oGet32     := TGet():New( 154,195,{|u| If(PCount()>0,M->TVK_SERRE3:=u,M->TVK_SERRE3)},oPanel1,040,008,'@!',{|| If(!Empty(M->TVK_SERRE3),EXISTCPO("ST4",M->TVK_SERRE3),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"ST4","M->TVK_SERRE3",,,,.t.)
//Roletes de esteira 4o
oGet33     := TGet():New( 167,112,{|u| If(PCount()>0,M->TVK_RE4PAV:=u,M->TVK_RE4PAV)},oPanel1,024,008,'@E 99.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"","M->TVK_RE4PAV",,,,.t.)
oGet34     := TGet():New( 167,153,{|u| If(PCount()>0,M->TVK_RE4POS:=u,M->TVK_RE4POS)},oPanel1,024,008,'@E 99.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"","M->TVK_RE4POS",,,,.t.)
oGet35     := TGet():New( 167,195,{|u| If(PCount()>0,M->TVK_SERRE4:=u,M->TVK_SERRE4)},oPanel1,040,008,'@!',{|| If(!Empty(M->TVK_SERRE4),EXISTCPO("ST4",M->TVK_SERRE4),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"ST4","M->TVK_SERRE4",,,,.t.)
//Roletes de esteira 5o
oGet36     := TGet():New( 180,112,{|u| If(PCount()>0,M->TVK_RE5PAV:=u,M->TVK_RE5PAV)},oPanel1,024,008,'@E 99.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"","M->TVK_RE5PAV",,,,.t.)
oGet37     := TGet():New( 180,153,{|u| If(PCount()>0,M->TVK_RE5POS:=u,M->TVK_RE5POS)},oPanel1,024,008,'@E 99.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"","M->TVK_RE5POS",,,,.t.)
oGet38     := TGet():New( 180,195,{|u| If(PCount()>0,M->TVK_SERRE5:=u,M->TVK_SERRE5)},oPanel1,040,008,'@!',{|| If(!Empty(M->TVK_SERRE5),EXISTCPO("ST4",M->TVK_SERRE5),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"ST4","M->TVK_SERRE5",,,,.t.)
//Roletes de esteira 6o
oGet39     := TGet():New( 193,112,{|u| If(PCount()>0,M->TVK_RE6PAV:=u,M->TVK_RE6PAV)},oPanel1,024,008,'@E 99.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"","M->TVK_RE6PAV",,,,.t.)
oGet40     := TGet():New( 193,153,{|u| If(PCount()>0,M->TVK_RE6POS:=u,M->TVK_RE6POS)},oPanel1,024,008,'@E 99.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"","M->TVK_RE6POS",,,,.t.)
oGet41     := TGet():New( 193,195,{|u| If(PCount()>0,M->TVK_SERRE6:=u,M->TVK_SERRE6)},oPanel1,040,008,'@!',{|| If(!Empty(M->TVK_SERRE6),EXISTCPO("ST4",M->TVK_SERRE6),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"ST4","M->TVK_SERRE6",,,,.t.)
//Roletes de esteira 7o
oGet42     := TGet():New( 206,112,{|u| If(PCount()>0,M->TVK_RE7PAV:=u,M->TVK_RE7PAV)},oPanel1,024,008,'@E 99.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"","M->TVK_RE7PAV",,,,.t.)
oGet43     := TGet():New( 206,153,{|u| If(PCount()>0,M->TVK_RE7POS:=u,M->TVK_RE7POS)},oPanel1,024,008,'@E 99.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"","M->TVK_RE7POS",,,,.t.)
oGet44     := TGet():New( 206,195,{|u| If(PCount()>0,M->TVK_SERRE7:=u,M->TVK_SERRE7)},oPanel1,040,008,'@!',{|| If(!Empty(M->TVK_SERRE7),EXISTCPO("ST4",M->TVK_SERRE7),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"ST4","M->TVK_SERRE7",,,,.t.)
//Roletes de esteira 8o
oGet45     := TGet():New( 219,112,{|u| If(PCount()>0,M->TVK_RE8PAV:=u,M->TVK_RE8PAV)},oPanel1,024,008,'@E 99.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"","M->TVK_RE8PAV",,,,.t.)
oGet46     := TGet():New( 219,153,{|u| If(PCount()>0,M->TVK_RE8POS:=u,M->TVK_RE8POS)},oPanel1,024,008,'@E 99.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"","M->TVK_RE8POS",,,,.t.)
oGet47     := TGet():New( 219,195,{|u| If(PCount()>0,M->TVK_SERRE8:=u,M->TVK_SERRE8)},oPanel1,040,008,'@!',{|| If(!Empty(M->TVK_SERRE8),EXISTCPO("ST4",M->TVK_SERRE8),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"ST4","M->TVK_SERRE8",,,,.t.)
//Rodas Motrizes
oGet48     := TGet():New( 232,112,{|u| If(PCount()>0,M->TVK_RDMPAV:=u,M->TVK_RDMPAV)},oPanel1,024,008,'@E 99.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"","M->TVK_RDMPAV",,,,.t.)
oGet49     := TGet():New( 232,153,{|u| If(PCount()>0,M->TVK_RDMPOS:=u,M->TVK_RDMPOS)},oPanel1,024,008,'@E 99.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"","M->TVK_RDMPOS",,,,.t.)
oGet50     := TGet():New( 232,195,{|u| If(PCount()>0,M->TVK_SERRDM:=u,M->TVK_SERRDM)},oPanel1,040,008,'@!',{|| If(!Empty(M->TVK_SERRDM),EXISTCPO("ST4",M->TVK_SERRDM),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| lWhenCamp },.F.,.F.,,.F.,.F.,"ST4","M->TVK_SERRDM",,,,.t.)

Activate MsDialog oDlg1 Centered On Init EnchoiceBar(oDlg1,{||nOpca:=1,oDlg1:End()},{||nOpca:=0,oDlg1:End()})

If nOpca == 1
	MNT689GRV(cCodBem)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorna conteudo de variaveis padroes       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
NGRETURNPRM(aNGBEGINPRM)
Return .t.
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT689GRV()
Gravacao da especificacao do material rodante
@author Evaldo Cevinscki Jr.
@since 27/05/2010
@version P11
@return Nil
/*/
//-------------------------------------------------------------------
Function MNT689GRV(cCodBem,cServ,cSeqRel)

DbSelectArea("TVK")
DbSetOrder(1)
If !DbSeek(xFilial("TVK")+cCodBem+If(nOpc == 1,M->TF_SERVICO+M->TF_SEQRELA,Space(Len(TVK->TVK_SERVIC))+Space(Len(TVK->TVK_SEQREL))))   //M->TF_SERVICO+M->TF_SEQRELA)
	Reclock("TVK",.t.)
Else
	Reclock("TVK",.f.)
EndIf
TVK->TVK_FILIAL	:= xFilial("TVK")
TVK->TVK_CODBEM	:=	cCodBem
TVK->TVK_SERVIC	:= If(nOpc == 1,M->TF_SERVICO,Space(Len(TVK->TVK_SERVIC)))
TVK->TVK_SEQREL	:=	If(nOpc == 1,M->TF_SEQRELA,Space(Len(TVK->TVK_SEQREL)))
TVK->TVK_ELOPAV	:=	M->TVK_ELOPAV
TVK->TVK_BUCPAV	:=	M->TVK_BUCPAV
TVK->TVK_SAPPAV	:=	M->TVK_SAPPAV
TVK->TVK_RDDPAV	:=	M->TVK_RDDPAV
TVK->TVK_RDTPAV	:=	M->TVK_RDTPAV
TVK->TVK_ELOPOS	:=	M->TVK_ELOPOS
TVK->TVK_BUCPOS	:=	M->TVK_BUCPOS
TVK->TVK_SAPPOS	:=	M->TVK_SAPPOS
TVK->TVK_RDDPOS	:=	M->TVK_RDDPOS
TVK->TVK_RDTPOS	:=	M->TVK_RDTPOS
TVK->TVK_RE1PAV	:=	M->TVK_RE1PAV
TVK->TVK_RE2PAV	:=	M->TVK_RE2PAV
TVK->TVK_RE3PAV	:=	M->TVK_RE3PAV
TVK->TVK_RE4PAV	:=	M->TVK_RE4PAV
TVK->TVK_RE5PAV	:=	M->TVK_RE5PAV
TVK->TVK_RE6PAV	:=	M->TVK_RE6PAV
TVK->TVK_RE7PAV	:=	M->TVK_RE7PAV
TVK->TVK_RE8PAV	:=	M->TVK_RE8PAV
TVK->TVK_RDMPAV	:=	M->TVK_RDMPAV
TVK->TVK_RS1PAV	:=	M->TVK_RS1PAV
TVK->TVK_RS2PAV	:=	M->TVK_RS2PAV
TVK->TVK_RE1POS	:=	M->TVK_RE1POS
TVK->TVK_RE2POS	:=	M->TVK_RE2POS
TVK->TVK_RE3POS	:=	M->TVK_RE3POS
TVK->TVK_RE4POS	:=	M->TVK_RE4POS
TVK->TVK_RE5POS	:=	M->TVK_RE5POS
TVK->TVK_RE6POS	:=	M->TVK_RE6POS
TVK->TVK_RE7POS	:=	M->TVK_RE7POS
TVK->TVK_RE8POS	:=	M->TVK_RE8POS
TVK->TVK_RDMPOS	:=	M->TVK_RDMPOS
TVK->TVK_RS1POS	:=	M->TVK_RS1POS
TVK->TVK_RS2POS	:=	M->TVK_RS2POS
TVK->TVK_SERELO	:=	M->TVK_SERELO
TVK->TVK_SERBUC	:=	M->TVK_SERBUC
TVK->TVK_SERSAP	:=	M->TVK_SERSAP
TVK->TVK_SERRDD	:=	M->TVK_SERSAP
TVK->TVK_SERRDT	:=	M->TVK_SERRDT
TVK->TVK_SERRS1	:=	M->TVK_SERRS1
TVK->TVK_SERRS2	:=	M->TVK_SERRS2
TVK->TVK_SERRE1	:=	M->TVK_SERRE1
TVK->TVK_SERRE2	:=	M->TVK_SERRE2
TVK->TVK_SERRE3	:=	M->TVK_SERRE3
TVK->TVK_SERRE4	:=	M->TVK_SERRE4
TVK->TVK_SERRE5	:=	M->TVK_SERRE5
TVK->TVK_SERRE6	:=	M->TVK_SERRE6
TVK->TVK_SERRE7	:=	M->TVK_SERRE7
TVK->TVK_SERRE8	:=	M->TVK_SERRE8
TVK->TVK_SERRDM	:=	M->TVK_SERRDM
TVK->(MsUnLock())

Return .t.