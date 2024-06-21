#Include "TOTVS.ch"

/*/{Protheus.doc} F380CPOS
Ponto de entrada para adição de novas colunas no browse de marcação de conciliação.

paramixb: [1] aCampos - Campos padrões do browse/tabela temporária

@type       Function
@author     TOTVS
@since      15/10/2020
return     aCampos, array, array dos campos que estarão presentes no browse.
/*/
User Function F380CPOS()
    
Local   aCampos := {{"E5_OK",,          "Rec."          },;
                    {"E5_DTDISPO",,     "DT Disponivel" },;
                    {"E5_RECPAG",,      "Rec/Pag"       },;
                    {"E5_VALOR",,       "Vlr. Movimen.",PesqPict("SE5","E5_VALOR",19)},;
                    {"E5_PARCELA",,     "Parcela"       },;
                    {"E5_BENEF",,       "Beneficiario"  },;
                    {"E5_PREFIXO",,     "Prefixo"       },;
                    {"E5_TIPO",,        "Tipo"          },;
                    {"E5_NUMERO",,      "Numero"        },;
                    {"E5_HISTOR",,      "Historico"     },;
                    {"E5_DOCUMEN",,     "Documento"     },;
                    {"E5_NATUREZ",,     "Natureza"      },;
                    {"E5_FILIAL",,      "Filial"        },;
                    {"E5_BANCO",,       "Banco"         },;
                    {"E5_AGENCIA",,     "Agencia"       },;
                    {"E5_CONTA",,       "Conta"         },;
                    {"E5_NUMCHEQ",,     "Num. Cheque"   },;
                    {"E5_CREDITO",,     "Cta Credito"   },;
                    {"E5_MOEDA",,       "Numerario"     },;
                    {"E5_VENCTO",,      "Vencimento"    },;
                    {"E5_DATA",,        "DT Movimento"  },;
                    {"E5_CLIFOR",,      "Cli/For"       },;
                    {"E5_LOJA",,        "Loja"          },;
                    {"E5_MOTBX",,       "Motivo Baixa"  } } // Novo campo adicionado
Return aCampos
