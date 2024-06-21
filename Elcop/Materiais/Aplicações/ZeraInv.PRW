#include "rwmake.ch"        // incluido pelo assistente de conversao do AP6 IDE em 28/09/02
#include "topconn.ch"

User Function ZeraInv()        // incluido pelo assistente de conversao do AP6 IDE em 28/09/02

SetPrvt("TITULO,CDESC1,CDESC2,CDESC3,CSTRING,WNREL")
SetPrvt("LNEGESTR,ARETURN,NLASTKEY,CPERG,CTABTES,AREGISTROS")
SetPrvt("I,J,TAMANHO,CRODATXT,NCNTIMPR,NTIPO")
SetPrvt("CPRODUTO,NNIVEL,CPICTQUANT,CPICTPERDA,NX,NPOSCNT")
SetPrvt("NPOSOLD,NTOT_KILOS,NTOT_VAL,ASEM_ESTR,LI,M_PAG")
SetPrvt("CABEC1,CABEC2,WPESO,aLocais")

cString  := "SB7"
lNegEstr := GETMV("MV_NEGESTR")
nLastKey := 0
cPerg    := "ZERAIN"       
cTabTes  := " "

Pergunte(cPerg,.F.)

If !pergunte(cPerg,.t.)
   Return NIL
EndIf

Processa({|| Zerado ()}, "Processando ZERADOS...")
//Processa({|| ZeraLoc()}, "Processando ZERADOS Localizacao...")
//Processa({|| ZeraLote ()}, "Processando ZERADOS...")

Return

*******************************************************************************************
Static Function Zerado()

cQuery := " SELECT SB2.B2_COD,SB2.B2_LOCAL FROM "+RETSQLNAME("SB2")+" SB2,"+RETSQLNAME("SB1")+" SB1"
cQuery += " WHERE SB2.B2_COD=SB1.B1_COD AND SB2.B2_FILIAL='"+xFilial("SB2")+"' "
cQuery += " AND SB2.B2_LOCAL>='"+MV_PAR01+"' AND SB2.B2_LOCAL<='"+MV_PAR02+"' "
cQuery += " AND SB2.B2_COD NOT LIKE 'MODA%' "
//cQuery += " AND SB2.B2_LOCAL NOT IN ('98','30') "
cQuery += " GROUP BY SB2.B2_COD,SB2.B2_LOCAL "
cQuery += " ORDER BY SB2.B2_COD,SB2.B2_LOCAL "

TCQUERY cQuery NEW ALIAS "SB2A" 

ProcRegua(LastRec())
SB2A->(DBGOTOP())

While !SB2A->(EOF())

   IncProc()
        
   if !SB1->(dbseek(xFilial('SB1')+SB2A->b2_cod))
      SB2A->(DBskip())
      loop
   endif
 
   Reclock("SB7",.t.)
   SB7->B7_FILIAL  := XFILIAL("SB7")
   SB7->B7_COD     := SB2A->B2_COD
   SB7->B7_LOCAL   := SB2A->B2_LOCAL
   SB7->B7_QUANT   := 0
   SB7->B7_DATA    := MV_PAR03
   SB7->B7_DTVALID := MV_PAR03
   SB7->B7_DOC     := Dtos(MV_PAR03)
   SB7->B7_TIPO    := SB1->B1_TIPO 
   MSUNLOCK()    
   
   SB2A->(DBSKIP())
end
SB2A->(DBCLOSEAREA())

Return
*********************************************************************************

static Function zeraLote()
Local cQuery:=""

cQuery := " SELECT * FROM "+RETSQLNAME("SB8")+" SB8,"+RETSQLNAME("SB1")+" SB1"
cQuery += " WHERE SB8.B8_PRODUTO=SB1.B1_COD AND SB8.B8_FILIAL='"+xFilial("SB8")+"' "        // verificar se existe filial no sb8 pois vc não precisaria se preocupar com filial se existir no sb8 e não no sb1 essa linha não precisa zanardo
cQuery += " AND SB8.B8_LOCAL>='"+MV_PAR08+"' AND SB8.B8_LOCAL<='"+MV_PAR09+"' "
cQuery += " AND SB8.B8_PRODUTO NOT LIKE 'MODA%' "
cQuery += " AND SB8.B8_LOCAL NOT IN ('98')
cQuery += " AND SB8.D_E_L_E_T_  = ' ' "
cQuery += " AND SB8.B8_SALDO <> 0 "
//cQuery += " GROUP BY SB8.B8_PRODUTO,SB8.B8_LOCAL "   vc não vai dar group by, pois essa tabela é por lote        zanardo
cQuery += " ORDER BY SB8.B8_PRODUTO,SB8.B8_LOCAL "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),"TRBSB8",.T.,.T.)

dbselectarea("TRBSB8")
while !eof()

   if !SB1->(dbseek(xFilial('SB1')+TRBSB8->B8_PRODUTO))
      TRBSB8->(DBskip())                     
      loop
   endif

   	reclock("SB7",.T.)
   	B7_FILIAL := XFILIAL("SB7")
   	B7_COD  := B8_PRODUTO
   	B7_LOCAL := B8_LOCAL 
   	B7_TIPO  := B1_TIPO 
   	B7_DOC  := "ZERA08"
   	B7_QUANT := 0
   	B7_DATA  := MV_PAR07
   	B7_LOTECTL := B8_LOTECTL
   	B7_DTVALID := B8_DTVALID
   	msunlock()
           
	dbselectarea("TRBSB8")
   	dbskip()
enddo
TRBSB8->(DBCLOSEAREA())
return(.T.)

/*
Static Function ZeraLoc()

aLocais := {}

cQyery := " SELECT SDB.DB_PRODUTO,SDB.DB_LOCAL,SDB.DB_LOCALIZ FROM "+RETSQLNAME("SDB")+" SDB,"+RETSQLNAME("SB1")+" SB1"
cQyery += " WHERE SB1.B1_TIPO IN ('MP','PI','PA') "
cQyery += " GROUP BY SDB.DB_PRODUTO,SDB.DB_LOCAL,SDB.DB_LOCALIZ "
cQyery += " ORDER BY SDB.DB_PRODUTO,SDB.DB_LOCAL,SDB.DB_LOCALIZ "
TCQUERY cQyery NEW ALIAS "SDBA" 

ProcRegua(LastRec())

SDBA->(dbgotop())
while !SDBA->(eof())

   IncProc()
     
   If SDBA->DB_local < mv_par08 .or. SDBA->DB_local > mv_par09
      SDBA->(dbskip())
      loop
   endif
 
   if Substr(DB_PRODUTO,1,4) == "MODA"  // 	EMERSON
      SDBA->(dbskip())
      loop
   endif
         
   if !SB1->(dbseek(xFilial('SB1')+SDBA->DB_PRODUTO))  // Se nao encontrar no SB1
      SDBA->(DBskip())
      loop
   endif

   If sb1->b1_locpad $ "60*63*59" // Material de Manutencao
      SDBA->(DBskip())
      loop
   endif

   If sb1->b1_tipo $ "MC*CL"   // Material de Consumo ou Clips
      SDBA->(DBskip())
      loop
   endif

   If SDBA->DB_local $ "EE*EB*HB*25"  // EMBALAGENS NAO ZERAR
  	  SDBA->(DBskip())
      loop
   endif 
 
   Reclock("SB7",.t.)
   SB7->B7_FILIAL  := XFILIAL("SB7")
   SB7->B7_COD     := SDBA->DB_PRODUTO
   SB7->B7_LOCAL   := SDBA->DB_LOCAL
   SB7->B7_QUANT   := 0
   SB7->B7_DATA    := MV_PAR07
   SB7->B7_DTVALID := MV_PAR07
   SB7->B7_DOC     := 'ZERADO'
   SB7->B7_LOCALIZ := SDBA->DB_LOCALIZ
   SB7->B7_TIPO    := SB1->B1_TIPO 
   MSUNLOCK()    
   
   SDBA->(dbskip())
end 

SDBA->(DBCLOSEAREA())

Return
*/
