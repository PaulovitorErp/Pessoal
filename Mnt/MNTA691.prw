#INCLUDE "MNTA691.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'

#DEFINE _nVERSAO 001 //Versao do fonte
//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA691()
 Especificacao de Material Rodante, chamado atraves do
MNTA170 no click da direita do mouse         
@author Marcos Wagner Junior	
@since 09/09/2010
@version P11
@return Nil
/*/
//-------------------------------------------------------------------
Function MNTA691(cCodFam,cTipMod) 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Guarda conteudo e declara variaveis padroes ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)

Local nAltura   	:= (GetScreenRes()[2]*0.7)
Local nLargura  	:= (GetScreenRes()[1]/1.5)  
Local oFont14N		:= TFont():New("Arial",,14,,.T.,,,,.F.,.F.)
Local nOpca			:= 0 
Private nLarg,nSecs,nEloEsq,nBucEsq,nSapEsq,nRdDEsq,nRdTEsq,nEloDir,nBucDir,nSapDir,nRdDDir,nRdTDir
Private nRE1Esq,nRE2Esq,nRE3Esq,nRE4Esq,nRE5Esq,nRE6Esq,nRE7Esq,nRE8Esq,nRdMEsq,nRS1Esq,nRS2Esq,nRE1Dir,nRE2Dir
Private nRE3Dir,nRE4Dir,nRE5Dir,nRE6Dir,nRE7Dir,nRE8Dir,nRdMDir,nRS1Dir,nRS2Dir,nPcsElo
Private cUMElo,cUMBuc,cUMSap,cUMDia,cUMTra,cUMRS1,cUMRS2,cUMRE1,cUMRE2,cUMRE3,cUMRE4,cUMRE5,cUMRE6,cUMRE7,cUMRE8		
Private cUMRdM,cBox1,cBox2,cBox3,cBox4,cBox5,cBox6,cBox7,cBox8,cBox9,cBox10,cBox11		                           
Private oScrollBox
Private aSize := MsAdvSize(,.f.,430), aObjects := {}

If Inclui
	MsgStop(STR0001,STR0038) //"Opção indisponível para inclusão!"###"ATENÇÃO"
	Return
Endif

DbSelectArea("TVH")
DbSetOrder(1)
DbSeek(xFilial("TVH")+cCodFam+cTipMod)

nLarg 	:= IIF(TVH->TVH_LARSAP <> 0,TVH->TVH_LARSAP,0)	
nSecs	:= IIF(TVH->TVH_NUMSEC <> 0,TVH->TVH_NUMSEC,0)
nEloEsq := IIF(TVH->TVH_ELOESQ <> 0,TVH->TVH_ELOESQ,0)
nBucEsq	:= IIF(TVH->TVH_BUCESQ <> 0,TVH->TVH_BUCESQ,0) 
nSapEsq := IIF(TVH->TVH_SAPESQ <> 0,TVH->TVH_SAPESQ,0)	
nRdDEsq	:= IIF(TVH->TVH_RDDESQ <> 0,TVH->TVH_RDDESQ,0) 
nRdTEsq := IIF(TVH->TVH_RDTESQ <> 0,TVH->TVH_RDTESQ,0)
nEloDir	:= IIF(TVH->TVH_ELODIR <> 0,TVH->TVH_ELODIR,0)	
nBucDir	:= IIF(TVH->TVH_BUCDIR <> 0,TVH->TVH_BUCDIR,0)
nSapDir	:= IIF(TVH->TVH_SAPDIR <> 0,TVH->TVH_SAPDIR,0)
nRdDDir	:= IIF(TVH->TVH_RDDDIR <> 0,TVH->TVH_RDDDIR,0)
nRdTDir	:= IIF(TVH->TVH_RDTDIR <> 0,TVH->TVH_RDTDIR,0) 
nRE1Esq	:= IIF(TVH->TVH_RE1ESQ <> 0,TVH->TVH_RE1ESQ,0)	
nRE2Esq	:= IIF(TVH->TVH_RE2ESQ <> 0,TVH->TVH_RE2ESQ,0) 
nRE3Esq	:= IIF(TVH->TVH_RE3ESQ <> 0,TVH->TVH_RE3ESQ,0)	
nRE4Esq	:= IIF(TVH->TVH_RE4ESQ <> 0,TVH->TVH_RE4ESQ,0)
nRE5Esq	:= IIF(TVH->TVH_RE5ESQ <> 0,TVH->TVH_RE5ESQ,0)	
nRE6Esq	:= IIF(TVH->TVH_RE6ESQ <> 0,TVH->TVH_RE6ESQ,0)
nRE7Esq	:= IIF(TVH->TVH_RE7ESQ <> 0,TVH->TVH_RE7ESQ,0)
nRE8Esq	:= IIF(TVH->TVH_RE8ESQ <> 0,TVH->TVH_RE8ESQ,0)
nRdMEsq	:= IIF(TVH->TVH_RDMESQ <> 0,TVH->TVH_RDMESQ,0)	
nRS1Esq	:= IIF(TVH->TVH_RS1ESQ <> 0,TVH->TVH_RS1ESQ,0)
nRS2Esq	:= IIF(TVH->TVH_RS2ESQ <> 0,TVH->TVH_RS2ESQ,0)	
nRE1Dir	:= IIF(TVH->TVH_RE1DIR <> 0,TVH->TVH_RE1DIR,0)	
nRE2Dir	:= IIF(TVH->TVH_RE2DIR <> 0,TVH->TVH_RE2DIR,0)
nRE3Dir	:= IIF(TVH->TVH_RE3DIR <> 0,TVH->TVH_RE3DIR,0)
nRE4Dir	:= IIF(TVH->TVH_RE4DIR <> 0,TVH->TVH_RE4DIR,0)	
nRE5Dir	:= IIF(TVH->TVH_RE5DIR <> 0,TVH->TVH_RE5DIR,0)
nRE6Dir	:= IIF(TVH->TVH_RE6DIR <> 0,TVH->TVH_RE6DIR,0)	
nRE7Dir	:= IIF(TVH->TVH_RE7DIR <> 0,TVH->TVH_RE7DIR,0)
nRE8Dir	:= IIF(TVH->TVH_RE8DIR <> 0,TVH->TVH_RE8DIR,0)	
nRdMDir	:= IIF(TVH->TVH_RDMDIR <> 0,TVH->TVH_RDMDIR,0)
nRS1Dir	:= IIF(TVH->TVH_RS1DIR <> 0,TVH->TVH_RS1DIR,0)	
nRS2Dir	:= IIF(TVH->TVH_RS2DIR <> 0,TVH->TVH_RS2DIR,0)	
nPcsElo	:= IIF(TVH->TVH_NUMPEC <> 0,TVH->TVH_NUMPEC,0)	
cUMElo	:= IIF(Empty(TVH->TVH_UMELO),Space(Len(TVH->TVH_UMELO)),TVH->TVH_UMELO)	
cUMBuc	:= IIF(Empty(TVH->TVH_UMBUC),Space(Len(TVH->TVH_UMBUC)),TVH->TVH_UMBUC)
cUMSap	:= IIF(Empty(TVH->TVH_UMSAP),Space(Len(TVH->TVH_UMSAP)),TVH->TVH_UMSAP)
cUMDia	:= IIF(Empty(TVH->TVH_UMRDD),Space(Len(TVH->TVH_UMRDD)),TVH->TVH_UMRDD)
cUMTra	:= IIF(Empty(TVH->TVH_UMRDT),Space(Len(TVH->TVH_UMRDT)),TVH->TVH_UMRDT)
cUMRS1	:= IIF(Empty(TVH->TVH_UMRS1),Space(Len(TVH->TVH_UMRS1)),TVH->TVH_UMRS1)
cUMRS2	:= IIF(Empty(TVH->TVH_UMRS2),Space(Len(TVH->TVH_UMRS2)),TVH->TVH_UMRS2) 
cUMRE1	:= IIF(Empty(TVH->TVH_UMRE1),Space(Len(TVH->TVH_UMRE1)),TVH->TVH_UMRE1)
cUMRE2	:= IIF(Empty(TVH->TVH_UMRE2),Space(Len(TVH->TVH_UMRE2)),TVH->TVH_UMRE2)	
cUMRE3	:= IIF(Empty(TVH->TVH_UMRE3),Space(Len(TVH->TVH_UMRE3)),TVH->TVH_UMRE3)
cUMRE4	:= IIF(Empty(TVH->TVH_UMRE4),Space(Len(TVH->TVH_UMRE4)),TVH->TVH_UMRE4)
cUMRE5	:= IIF(Empty(TVH->TVH_UMRE5),Space(Len(TVH->TVH_UMRE5)),TVH->TVH_UMRE5)
cUMRE6	:= IIF(Empty(TVH->TVH_UMRE6),Space(Len(TVH->TVH_UMRE6)),TVH->TVH_UMRE6)
cUMRE7	:= IIF(Empty(TVH->TVH_UMRE7),Space(Len(TVH->TVH_UMRE7)),TVH->TVH_UMRE7)
cUMRE8	:= IIF(Empty(TVH->TVH_UMRE8),Space(Len(TVH->TVH_UMRE8)),TVH->TVH_UMRE8)
cUMRdM	:= IIF(Empty(TVH->TVH_UMRDM),Space(Len(TVH->TVH_UMRDM)),TVH->TVH_UMRDM)
cBox1	:= IIF(Empty(TVH->TVH_TIPEST),STR0002,If(TVH->TVH_TIPEST == "1",STR0002,STR0003))   //"Selada"###"Selada"###"Selada e Lubrificada"
cBox2	:= IIF(Empty(TVH->TVH_GIRADA),STR0004,If(TVH->TVH_GIRADA == "1",STR0004,STR0005))   //"Sim"###"Sim"###"Não"
cBox3	:= IIF(Empty(TVH->TVH_GARSIM),STR0004,If(TVH->TVH_GARSIM == "1",STR0004,STR0005))   //"Sim"###"Sim"###"Não"
cBox4	:= IIF(Empty(TVH->TVH_FLARE1),STR0006,If(TVH->TVH_FLARE1 == "1",STR0006,STR0007))   //"Simples"###"Simples"###"Dupla"
cBox5	:= IIF(Empty(TVH->TVH_FLARE2),STR0006,If(TVH->TVH_FLARE2 == "1",STR0006,STR0007))   //"Simples"###"Simples"###"Dupla"
cBox6	:= IIF(Empty(TVH->TVH_FLARE3),STR0006,If(TVH->TVH_FLARE3 == "1",STR0006,STR0007))   //"Simples"###"Simples"###"Dupla"
cBox7	:= IIF(Empty(TVH->TVH_FLARE4),STR0006,If(TVH->TVH_FLARE4 == "1",STR0006,STR0007))   //"Simples"###"Simples"###"Dupla"
cBox8	:= IIF(Empty(TVH->TVH_FLARE5),STR0006,If(TVH->TVH_FLARE5 == "1",STR0006,STR0007))   //"Simples"###"Simples"###"Dupla"
cBox9	:= IIF(Empty(TVH->TVH_FLARE6),STR0006,If(TVH->TVH_FLARE6 == "1",STR0006,STR0007))   //"Simples"###"Simples"###"Dupla"
cBox10	:= IIF(Empty(TVH->TVH_FLARE7),STR0006,If(TVH->TVH_FLARE7 == "1",STR0006,STR0007))   //"Simples"###"Simples"###"Dupla"
cBox11	:= IIF(Empty(TVH->TVH_FLARE8),STR0006,If(TVH->TVH_FLARE8 == "1",STR0006,STR0007))   //"Simples"###"Simples"###"Dupla"


 
/*Declaração de Variaveis Private dos Objetos*/
SetPrvt("oDlg1","oPanel1","oSay1","oSay2","oSay3","oSay4","oSay5","oSay6","oSay7","oSay8","oSay9","oSay10")
SetPrvt("oSay12","oSay13","oSay14","oSay15","oSay16","oGet1","oGet2","oCBox1","oGet3","oGet4","oGet5")
SetPrvt("oGet7","oGet8","oGet9","oGet10","oGet11","oGet12","oGet13","oGet14","oGet15","oGet16","oGet17")
SetPrvt("oGet19","oGet20")

Define MsDialog oDlg1 Title STR0008 From 0,0 To nAltura,nLargura Of oMainWnd Pixel COLOR CLR_BLACK,CLR_WHITE  //"Especificação Material Rodante"
oDlg1:lMaximized := .T.
Aadd(aObjects,{150,10,.T.,.T.}) // Indica dimensoes x e y e indica que redimensiona x e y
Aadd(aObjects,{200,30,.T.,.T.}) // Indica dimensoes x e y e indica que redimensiona x e y e assume que retorno sera em linha final coluna final (.F.)

aSize:=MsAdvSize()
aInfo:={aSize[1],aSize[2],aSize[3],aSize[4],3,3}
aPosObj:=MsObjSize(aInfo,aObjects,.T.)

oPanel1   		:= TScrollBox():new(oDlg1, 003,003, aPosObj[2,3]-aPosObj[2,1] - 20, ((aPosObj[2,4]) / 2) + 10 , .T., .T., .T.)
oPanel1:Align 	:= CONTROL_ALIGN_ALLCLIENT 

oSay1      := TSay():New( 020,012,{||STR0009},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,044,008) //"Largura Sapatas"
oSay2      := TSay():New( 020,152,{||STR0010},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,048,008) //"Número de Seções"
oSay3      := TSay():New( 034,012,{||STR0011},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,040,008) //"Tipo de Esteira"

oSay4      := TSay():New( 050,012,{||STR0012},oPanel1,,oFont14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,032,008) //"Conjuntos"
oSay5      := TSay():New( 050,112,{||STR0013},oPanel1,,oFont14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,070,008) //"Dimensões Iniciais"
oSay6      := TSay():New( 050,250,{||STR0014},oPanel1,,oFont14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,070,008) //"Outras Informações"

oSay7      := TSay():New( 065,112,{||STR0015},oPanel1,,oFont14N,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,026,008) //"Esquerda"
oSay8      := TSay():New( 065,156,{||STR0016},oPanel1,,oFont14N,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,024,008) //"Direita"
oSay9      := TSay():New( 065,198,{||STR0017},oPanel1,,oFont14N,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,024,008) //"Unidade"

oSay10     := TSay():New( 079,012,{||STR0018},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)           //"Elos"
oSay26     := TSay():New( 079,250,{||STR0019},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,070,008) //"Número de Peças"

oSay11     := TSay():New( 092,012,{||STR0020},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008) //"Buchas"
oSay27     := TSay():New( 092,250,{||STR0021},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008) //"Giradas"

oSay12     := TSay():New( 105,012,{||STR0022},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008) //"Sapatas"
oSay28     := TSay():New( 105,250,{||STR0023},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,050,008) //"Garra Simples"

oSay13     := TSay():New( 118,012,{||STR0024},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,056,008) //"Rodas Guias Dianteira"
oSay14     := TSay():New( 131,012,{||STR0025},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,052,008) //"Rodas Guias Traseira"
oSay15     := TSay():New( 144,012,{||STR0026},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,052,008) //"Roletes Superior 1º"
oSay16     := TSay():New( 157,012,{||STR0027},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,048,008) //"Roletes Superior 2º"
oSay17     := TSay():New( 170,012,{||STR0028},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008) //"Roletes de Esteira 1º"
oSay29     := TSay():New( 170,250,{||STR0029},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008) //"Flange"

oSay18     := TSay():New( 183,012,{||STR0030},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008) //"Roletes de Esteira 2º"
oSay30     := TSay():New( 183,250,{||STR0029},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008) //"Flange"

oSay19     := TSay():New( 196,012,{||STR0031},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008) //"Roletes de Esteira 3º"
oSay31     := TSay():New( 196,250,{||STR0029},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008) //"Flange"

oSay20     := TSay():New( 209,012,{||STR0032},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008) //"Roletes de Esteira 4º"
oSay32     := TSay():New( 209,250,{||STR0029},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008) //"Flange"

oSay21     := TSay():New( 222,012,{||STR0033},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008) //"Roletes de Esteira 5º"
oSay33     := TSay():New( 222,250,{||STR0029},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008) //"Flange"

oSay22     := TSay():New( 235,012,{||STR0034},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008) //"Roletes de Esteira 6º"
oSay34     := TSay():New( 235,250,{||STR0029},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008) //"Flange"

oSay23     := TSay():New( 248,012,{||STR0035},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008) //"Roletes de Esteira 7º"
oSay35     := TSay():New( 248,250,{||STR0029},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008) //"Flange"

oSay24     := TSay():New( 261,012,{||STR0036},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008) //"Roletes de Esteira 8º"
oSay36     := TSay():New( 261,250,{||STR0029},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008) //"Flange"

oSay25     := TSay():New( 274,012,{||STR0037},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008) //"Rodas Motrizes"

oGet1      := TGet():New( 020,056,{|u| If(PCount()>0,nLarg:=u,nLarg)},oPanel1,060,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nLarg",,,,.t.)
oGet2      := TGet():New( 020,200,{|u| If(PCount()>0,nSecs:=u,nSecs)},oPanel1,060,008,'@E 999'   ,{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nSecs",,,,.t.)

oCBox1     := TComboBox():New( 034,056,{|u| If(PCount()>0,cBox1:=u,cBox1)},{STR0002,STR0003},068,010,oPanel1,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,,cBox1 ) //"Selada"###"Selada e Lubrificada"

//Elos
oGet3      := TGet():New( 077,112,{|u| If(PCount()>0,nEloEsq:=u,nEloEsq)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nEloEsq",,,,.t.)
oGet4      := TGet():New( 077,153,{|u| If(PCount()>0,nEloDir:=u,nEloDir)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nEloDir",,,,.t.)
oGet5      := TGet():New( 077,195,{|u| If(PCount()>0,cUMElo:=u,cUMElo)},oPanel1,024,008,'@!',{|| If(!Empty(cUMElo),EXISTCPO("SAH",cUMElo),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SAH","cUMElo",,,,.t.)
oGet51     := TGet():New( 077,295,{|u| If(PCount()>0,nPcsElo:=u,nPcsElo)},oPanel1,024,008,'@E 9999',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nPcsElo",,,,.t.)
//Buchas
oGet6      := TGet():New( 090,112,{|u| If(PCount()>0,nBucEsq:=u,nBucEsq)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nBucEsq",,,,.t.)
oGet7      := TGet():New( 090,153,{|u| If(PCount()>0,nBucDir:=u,nBucDir)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nBucDir",,,,.t.)
oGet8      := TGet():New( 090,195,{|u| If(PCount()>0,cUMBuc:=u,cUMBuc)},oPanel1,024,008,'@!',{|| If(!Empty(cUMBuc),EXISTCPO("SAH",cUMBuc),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SAH","cUMBuc",,,,.t.) 
oCBox2     := TComboBox():New( 090,295,{|u| If(PCount()>0,cBox2:=u,cBox2)},{STR0004,STR0005},030,010,oPanel1,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,, ) //"Sim"###"Não"
//Sapatas
oGet9      := TGet():New( 103,112,{|u| If(PCount()>0,nSapEsq:=u,nSapEsq)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nSapEsq",,,,.t.)
oGet10     := TGet():New( 103,153,{|u| If(PCount()>0,nSapDir:=u,nSapDir)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nSapDir",,,,.t.)
oGet11     := TGet():New( 103,195,{|u| If(PCount()>0,cUMSap:=u,cUMSap)},oPanel1,024,008,'@!',{|| If(!Empty(cUMSap),EXISTCPO("SAH",cUMSap),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SAH","cUMSap",,,,.t.)
oCBox3     := TComboBox():New( 103,295,{|u| If(PCount()>0,cBox3:=u,cBox3)},{STR0004,STR0005},030,010,oPanel1,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,, ) //"Sim"###"Não"
//Rodas guia dianteira
oGet12     := TGet():New( 116,112,{|u| If(PCount()>0,nRdDEsq:=u,nRdDEsq)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nRdDEsq",,,,.t.)
oGet13     := TGet():New( 116,153,{|u| If(PCount()>0,nRdDDir:=u,nRdDDir)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nRdDDir",,,,.t.)
oGet14     := TGet():New( 116,195,{|u| If(PCount()>0,cUMDia:=u,cUMDia)},oPanel1,024,008,'@!',{|| If(!Empty(cUMDia),EXISTCPO("SAH",cUMDia),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SAH","cUMDia",,,,.t.)
//Rodas guia traseira
oGet15     := TGet():New( 129,112,{|u| If(PCount()>0,nRdTEsq:=u,nRdTEsq)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nRdTEsq",,,,.t.)
oGet16     := TGet():New( 129,153,{|u| If(PCount()>0,nRdTDir:=u,nRdTDir)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nRdTDir",,,,.t.)
oGet17     := TGet():New( 129,195,{|u| If(PCount()>0,cUMTra:=u,cUMTra)},oPanel1,024,008,'@!',{|| If(!Empty(cUMTra),EXISTCPO("SAH",cUMTra),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SAH","cUMTra",,,,.t.)
//Roletes superior 1o
oGet18     := TGet():New( 142,112,{|u| If(PCount()>0,nRS1Esq:=u,nRS1Esq)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nRS1Esq",,,,.t.)
oGet19     := TGet():New( 142,153,{|u| If(PCount()>0,nRS1Dir:=u,nRS1Dir)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nRS1Dir",,,,.t.)
oGet20     := TGet():New( 142,195,{|u| If(PCount()>0,cUMRS1:=u,cUMRS1)},oPanel1,024,008,'@!',{|| If(!Empty(cUMRS1),EXISTCPO("SAH",cUMRS1),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SAH","cUMRS1",,,,.t.)
//Roletes superior 2o
oGet21     := TGet():New( 155,112,{|u| If(PCount()>0,nRS2Esq:=u,nRS2Esq)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nRS2Esq",,,,.t.)
oGet22     := TGet():New( 155,153,{|u| If(PCount()>0,nRS2Dir:=u,nRS2Dir)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nRS2Dir",,,,.t.)
oGet23     := TGet():New( 155,195,{|u| If(PCount()>0,cUMRS2:=u,cUMRS2)},oPanel1,024,008,'@!',{|| If(!Empty(cUMRS2),EXISTCPO("SAH",cUMRS2),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SAH","cUMRS2",,,,.t.)
//Roletes de esteira 1o
oGet24     := TGet():New( 168,112,{|u| If(PCount()>0,nRE1Esq:=u,nRE1Esq)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nRE1Esq",,,,.t.)
oGet25     := TGet():New( 168,153,{|u| If(PCount()>0,nRE1Dir:=u,nRE1Dir)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nRE1Dir",,,,.t.)
oGet26     := TGet():New( 168,195,{|u| If(PCount()>0,cUMRE1:=u,cUMRE1)},oPanel1,024,008,'@!',{|| If(!Empty(cUMRE1),EXISTCPO("SAH",cUMRE1),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SAH","cUMRE1",,,,.t.)
oCBox4     := TComboBox():New( 168,295,{|u| If(PCount()>0,cBox4:=u,cBox4)},{STR0006,STR0007},030,010,oPanel1,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,, ) //"Simples"###"Dupla"
//Roletes de esteira 2o
oGet27     := TGet():New( 181,112,{|u| If(PCount()>0,nRE2Esq:=u,nRE2Esq)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nRE2Esq",,,,.t.)
oGet28     := TGet():New( 181,153,{|u| If(PCount()>0,nRE2Dir:=u,nRE2Dir)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nRE2Dir",,,,.t.)
oGet29     := TGet():New( 181,195,{|u| If(PCount()>0,cUMRE2:=u,cUMRE2)},oPanel1,024,008,'@!',{|| If(!Empty(cUMRE2),EXISTCPO("SAH",cUMRE2),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SAH","cUMRE2",,,,.t.)
oCBox5     := TComboBox():New( 181,295,{|u| If(PCount()>0,cBox5:=u,cBox5)},{STR0006,STR0007},030,010,oPanel1,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,, ) //"Simples"###"Dupla"
//Roletes de esteira 3o
oGet30     := TGet():New( 194,112,{|u| If(PCount()>0,nRE3Esq:=u,nRE3Esq)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nRE3Esq",,,,.t.)
oGet31     := TGet():New( 194,153,{|u| If(PCount()>0,nRE3Dir:=u,nRE3Dir)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nRE3Dir",,,,.t.)
oGet32     := TGet():New( 194,195,{|u| If(PCount()>0,cUMRE3:=u,cUMRE3)},oPanel1,024,008,'@!',{|| If(!Empty(cUMRE3),EXISTCPO("SAH",cUMRE3),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SAH","cUMRE3",,,,.t.)
oCBox6     := TComboBox():New( 194,295,{|u| If(PCount()>0,cBox6:=u,cBox6)},{STR0006,STR0007},030,010,oPanel1,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,, ) //"Simples"###"Dupla"
//Roletes de esteira 4o
oGet33     := TGet():New( 207,112,{|u| If(PCount()>0,nRE4Esq:=u,nRE4Esq)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nRE4Esq",,,,.t.)
oGet34     := TGet():New( 207,153,{|u| If(PCount()>0,nRE4Dir:=u,nRE4Dir)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nRE4Dir",,,,.t.)
oGet35     := TGet():New( 207,195,{|u| If(PCount()>0,cUMRE4:=u,cUMRE4)},oPanel1,024,008,'@!',{|| If(!Empty(cUMRE4),EXISTCPO("SAH",cUMRE4),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SAH","cUMRE4",,,,.t.)
oCBox7     := TComboBox():New( 207,295,{|u| If(PCount()>0,cBox7:=u,cBox7)},{STR0006,STR0007},030,010,oPanel1,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,, ) //"Simples"###"Dupla"
//Roletes de esteira 5o
oGet36     := TGet():New( 220,112,{|u| If(PCount()>0,nRE5Esq:=u,nRE5Esq)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nRE5Esq",,,,.t.)
oGet37     := TGet():New( 220,153,{|u| If(PCount()>0,nRE5Dir:=u,nRE5Dir)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nRE5Dir",,,,.t.)
oGet38     := TGet():New( 220,195,{|u| If(PCount()>0,cUMRE5:=u,cUMRE5)},oPanel1,024,008,'@!',{|| If(!Empty(cUMRE5),EXISTCPO("SAH",cUMRE5),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SAH","cUMRE5",,,,.t.)
oCBox8     := TComboBox():New( 220,295,{|u| If(PCount()>0,cBox8:=u,cBox8)},{STR0006,STR0007},030,010,oPanel1,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,, ) //"Simples"###"Dupla"
//Roletes de esteira 6o
oGet39     := TGet():New( 233,112,{|u| If(PCount()>0,nRE6Esq:=u,nRE6Esq)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nRE6Esq",,,,.t.)
oGet40     := TGet():New( 233,153,{|u| If(PCount()>0,nRE6Dir:=u,nRE6Dir)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nRE6Dir",,,,.t.)
oGet41     := TGet():New( 233,195,{|u| If(PCount()>0,cUMRE6:=u,cUMRE6)},oPanel1,024,008,'@!',{|| If(!Empty(cUMRE6),EXISTCPO("SAH",cUMRE6),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SAH","cUMRE6",,,,.t.)
oCBox9     := TComboBox():New( 233,295,{|u| If(PCount()>0,cBox9:=u,cBox9)},{STR0006,STR0007},030,010,oPanel1,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,, ) //"Simples"###"Dupla"
//Roletes de esteira 7o
oGet42     := TGet():New( 246,112,{|u| If(PCount()>0,nRE7Esq:=u,nRE7Esq)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nRE7Esq",,,,.t.)
oGet43     := TGet():New( 246,153,{|u| If(PCount()>0,nRE7Dir:=u,nRE7Dir)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nRE7Dir",,,,.t.)
oGet44     := TGet():New( 246,195,{|u| If(PCount()>0,cUMRE7:=u,cUMRE7)},oPanel1,024,008,'@!',{|| If(!Empty(cUMRE7),EXISTCPO("SAH",cUMRE7),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SAH","cUMRE7",,,,.t.)
oCBox10    := TComboBox():New( 246,295,{|u| If(PCount()>0,cBox10:=u,cBox10)},{STR0006,STR0007},030,010,oPanel1,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,, ) //"Simples"###"Dupla"
//Roletes de esteira 8o
oGet45     := TGet():New( 259,112,{|u| If(PCount()>0,nRE8Esq:=u,nRE8Esq)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nRE8Esq",,,,.t.)
oGet46     := TGet():New( 259,153,{|u| If(PCount()>0,nRE8Dir:=u,nRE8Dir)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nRE8Dir",,,,.t.)
oGet47     := TGet():New( 259,195,{|u| If(PCount()>0,cUMRE8:=u,cUMRE8)},oPanel1,024,008,'@!',{|| If(!Empty(cUMRE8),EXISTCPO("SAH",cUMRE8),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SAH","cUMRE8",,,,.t.)
oCBox11    := TComboBox():New( 259,295,{|u| If(PCount()>0,cBox11:=u,cBox11)},{STR0006,STR0007},030,010,oPanel1,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,, ) //"Simples"###"Dupla"
//Rodas Motrizes
oGet48     := TGet():New( 272,112,{|u| If(PCount()>0,nRdMEsq:=u,nRdMEsq)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nRdMEsq",,,,.t.)
oGet49     := TGet():New( 272,153,{|u| If(PCount()>0,nRdMDir:=u,nRdMDir)},oPanel1,024,008,'@E 999.99',{|| Positivo() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nRdMDir",,,,.t.)
oGet50     := TGet():New( 272,195,{|u| If(PCount()>0,cUMRdM:=u,cUMRdM)},oPanel1,024,008,'@!',{|| If(!Empty(cUMRdM),EXISTCPO("SAH",cUMRdM),.t.) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SAH","cUMRdM",,,,.t.)

Activate MsDialog oDlg1 Centered On Init EnchoiceBar(oDlg1,{||nOpca:=1,oDlg1:End()},{||nOpca:=0,oDlg1:End()})

If nOpca == 1
	MNT691GRV(cCodFam,cTipMod)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorna conteudo de variaveis padroes       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
NGRETURNPRM(aNGBEGINPRM)
Return .t.
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT691GRV()
Gravacao da especificacao do material rodante          
@author Marcos Wagner Junior	
@since 09/09/2010
@version P11
@return Nil
/*/
//-------------------------------------------------------------------
Function MNT691GRV(cCodFam,cTipMod)

DbSelectArea("TVH")
DbSetOrder(1)
If !DbSeek(xFilial("TVH")+cCodFam+cTipMod) 
	Reclock("TVH",.t.)
Else
	Reclock("TVH",.f.)	
EndIf                       
TVH->TVH_FILIAL	:= xFilial("TVH")
TVH->TVH_CODFAM	:=	cCodFam
TVH->TVH_TIPMOD	:= cTipMod
TVH->TVH_LARSAP	:=	nLarg 
TVH->TVH_NUMSEC	:=	nSecs
TVH->TVH_ELOESQ	:=	nEloEsq 
TVH->TVH_BUCESQ	:=	nBucEsq
TVH->TVH_SAPESQ	:=	nSapEsq 
TVH->TVH_RDDESQ	:=	nRdDEsq
TVH->TVH_RDTESQ	:=	nRdTEsq 
TVH->TVH_ELODIR	:=	nEloDir
TVH->TVH_BUCDIR	:=	nBucDir
TVH->TVH_SAPDIR	:=	nSapDir
TVH->TVH_RDDDIR	:=	nRdDDir
TVH->TVH_RDTDIR	:=	nRdTDir
TVH->TVH_RE1ESQ	:=	nRE1Esq
TVH->TVH_RE2ESQ	:=	nRE2Esq
TVH->TVH_RE3ESQ	:=	nRE3Esq
TVH->TVH_RE4ESQ	:=	nRE4Esq
TVH->TVH_RE5ESQ	:=	nRE5Esq
TVH->TVH_RE6ESQ	:=	nRE6Esq
TVH->TVH_RE7ESQ	:=	nRE7Esq
TVH->TVH_RE8ESQ	:=	nRE8Esq
TVH->TVH_RDMESQ	:=	nRdMEsq
TVH->TVH_RS1ESQ	:=	nRS1Esq
TVH->TVH_RS2ESQ	:=	nRS2Esq
TVH->TVH_RE1DIR	:=	nRE1Dir
TVH->TVH_RE2DIR	:=	nRE2Dir
TVH->TVH_RE3DIR	:=	nRE3Dir
TVH->TVH_RE4DIR	:=	nRE4Dir
TVH->TVH_RE5DIR	:=	nRE5Dir
TVH->TVH_RE6DIR	:=	nRE6Dir
TVH->TVH_RE7DIR	:=	nRE7Dir
TVH->TVH_RE8DIR	:=	nRE8Dir
TVH->TVH_RDMDIR	:=	nRdMDir
TVH->TVH_RS1DIR	:=	nRS1Dir
TVH->TVH_RS2DIR	:=	nRS2Dir
TVH->TVH_NUMPEC	:=	nPcsElo
TVH->TVH_UMELO		:=	cUMElo
TVH->TVH_UMBUC		:=	cUMBuc
TVH->TVH_UMSAP		:=	cUMSap
TVH->TVH_UMRDD		:=	cUMDia
TVH->TVH_UMRDT		:=	cUMTra
TVH->TVH_UMRS1		:=	cUMRS1
TVH->TVH_UMRS2		:=	cUMRS2
TVH->TVH_UMRE1		:=	cUMRE1
TVH->TVH_UMRE2		:=	cUMRE2
TVH->TVH_UMRE3		:=	cUMRE3
TVH->TVH_UMRE4		:=	cUMRE4
TVH->TVH_UMRE5		:=	cUMRE5
TVH->TVH_UMRE6		:=	cUMRE6
TVH->TVH_UMRE7		:=	cUMRE7
TVH->TVH_UMRE8		:=	cUMRE8
TVH->TVH_UMRDM		:=	cUMRdM
TVH->TVH_TIPEST	:=	IF(cBox1 == STR0002,"1","2")   //"Selada"
TVH->TVH_GIRADA	:=	IF(cBox2 == STR0004,"1","2")   //"Sim"
TVH->TVH_GARSIM	:=	IF(cBox3 == STR0004,"1","2")   //"Sim"
TVH->TVH_FLARE1	:=	IF(cBox4 == STR0006,"1","2")   //"Simples"
TVH->TVH_FLARE2	:=	IF(cBox5 == STR0006,"1","2")   //"Simples"
TVH->TVH_FLARE3	:=	IF(cBox6 == STR0006,"1","2")   //"Simples"
TVH->TVH_FLARE4	:=	IF(cBox7 == STR0006,"1","2")   //"Simples"
TVH->TVH_FLARE5	:=	IF(cBox8 == STR0006,"1","2")   //"Simples"
TVH->TVH_FLARE6	:=	IF(cBox9 == STR0006,"1","2")   //"Simples"
TVH->TVH_FLARE7	:=	IF(cBox10== STR0006,"1","2")   //"Simples"
TVH->TVH_FLARE8	:=	IF(cBox11== STR0006,"1","2")   //"Simples"
TVH->(MsUnLock())	   

Return .t.
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT691PAD()
Carrega as informacoes do Material Rodante para o Bem            
@author Marcos Wagner Junior	
@since 09/09/2010
@version P11
@return Nil
/*/
//-------------------------------------------------------------------
Function MNT691PAD()
Local x1, y, yy
Local aOldArea := GetArea()

If (Inclui .AND. M->T9_PADRAO == 'S') .OR. (Altera .AND. M->T9_PADRAO == 'S')
	DbSelectArea("TVH")
	DbSetOrder(1)
	If DbSeek(xFilial("TVH")+M->T9_CODFAMI+M->T9_TIPMOD) 
	
		DbSelectArea("TV5")
		DbSetOrder(1)
		If !DbSeek(xFilial("TV5")+M->T9_CODBEM)
			RecLock("TV5",.t.)
			For yy := 1 To FCount()
				If FieldName(yy) <> 'TV5_CODBEM'
					x1 := "TVH->"+StrTran(FieldName(yy),'TV5','TVH')
					y  := "TV5->"+FieldName(yy)
					Replace &y. with &x1.
				Else
					TV5->TV5_CODBEM := M->T9_CODBEM
				Endif
			Next yy
			TV5->(MsUnLock())
		Endif

	EndIf
Endif

RestArea(aOldArea)

Return .t.