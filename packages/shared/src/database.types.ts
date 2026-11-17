export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.18"
  }
  public: {
    Tables: {
      aparelhos: {
        Row: {
          apagado_em: string | null
          atualizado_em: string
          criado_em: string
          fazenda_id: string
          id: string
          nome: string
          plataforma: string
          revogado_em: string | null
          revogado_por: string | null
          usuario_id: string
        }
        Insert: {
          apagado_em?: string | null
          atualizado_em?: string
          criado_em?: string
          fazenda_id: string
          id?: string
          nome: string
          plataforma?: string
          revogado_em?: string | null
          revogado_por?: string | null
          usuario_id?: string
        }
        Update: {
          apagado_em?: string | null
          atualizado_em?: string
          criado_em?: string
          fazenda_id?: string
          id?: string
          nome?: string
          plataforma?: string
          revogado_em?: string | null
          revogado_por?: string | null
          usuario_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "aparelhos_fazenda_id_fkey"
            columns: ["fazenda_id"]
            isOneToOne: false
            referencedRelation: "fazendas"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "aparelhos_revogado_por_fkey"
            columns: ["revogado_por"]
            isOneToOne: false
            referencedRelation: "perfis"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "aparelhos_usuario_id_fkey"
            columns: ["usuario_id"]
            isOneToOne: false
            referencedRelation: "perfis"
            referencedColumns: ["id"]
          },
        ]
      }
      contas: {
        Row: {
          apagado_em: string | null
          atualizado_em: string
          criado_em: string
          dono_id: string
          id: string
          nome: string
        }
        Insert: {
          apagado_em?: string | null
          atualizado_em?: string
          criado_em?: string
          dono_id?: string
          id?: string
          nome: string
        }
        Update: {
          apagado_em?: string | null
          atualizado_em?: string
          criado_em?: string
          dono_id?: string
          id?: string
          nome?: string
        }
        Relationships: [
          {
            foreignKeyName: "contas_dono_id_fkey"
            columns: ["dono_id"]
            isOneToOne: false
            referencedRelation: "perfis"
            referencedColumns: ["id"]
          },
        ]
      }
      fazendas: {
        Row: {
          apagado_em: string | null
          atualizado_em: string
          conta_id: string
          criado_em: string
          id: string
          municipio: string | null
          nome: string
          uf: string | null
        }
        Insert: {
          apagado_em?: string | null
          atualizado_em?: string
          conta_id: string
          criado_em?: string
          id?: string
          municipio?: string | null
          nome: string
          uf?: string | null
        }
        Update: {
          apagado_em?: string | null
          atualizado_em?: string
          conta_id?: string
          criado_em?: string
          id?: string
          municipio?: string | null
          nome?: string
          uf?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "fazendas_conta_id_fkey"
            columns: ["conta_id"]
            isOneToOne: false
            referencedRelation: "contas"
            referencedColumns: ["id"]
          },
        ]
      }
      pendencias_sincronizacao: {
        Row: {
          criado_em: string
          dados_aparelho: Json
          dados_servidor: Json | null
          enviado_por: string | null
          fazenda_id: string | null
          id: string
          operacao: string
          registro_id: string
          resolucao: string | null
          resolvido_em: string | null
          resolvido_por: string | null
          tabela: string
          tipo: string
        }
        Insert: {
          criado_em?: string
          dados_aparelho: Json
          dados_servidor?: Json | null
          enviado_por?: string | null
          fazenda_id?: string | null
          id?: string
          operacao: string
          registro_id: string
          resolucao?: string | null
          resolvido_em?: string | null
          resolvido_por?: string | null
          tabela: string
          tipo: string
        }
        Update: {
          criado_em?: string
          dados_aparelho?: Json
          dados_servidor?: Json | null
          enviado_por?: string | null
          fazenda_id?: string | null
          id?: string
          operacao?: string
          registro_id?: string
          resolucao?: string | null
          resolvido_em?: string | null
          resolvido_por?: string | null
          tabela?: string
          tipo?: string
        }
        Relationships: [
          {
            foreignKeyName: "pendencias_sincronizacao_enviado_por_fkey"
            columns: ["enviado_por"]
            isOneToOne: false
            referencedRelation: "perfis"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "pendencias_sincronizacao_fazenda_id_fkey"
            columns: ["fazenda_id"]
            isOneToOne: false
            referencedRelation: "fazendas"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "pendencias_sincronizacao_resolvido_por_fkey"
            columns: ["resolvido_por"]
            isOneToOne: false
            referencedRelation: "perfis"
            referencedColumns: ["id"]
          },
        ]
      }
      perfis: {
        Row: {
          atualizado_em: string
          criado_em: string
          id: string
          nome: string
        }
        Insert: {
          atualizado_em?: string
          criado_em?: string
          id: string
          nome?: string
        }
        Update: {
          atualizado_em?: string
          criado_em?: string
          id?: string
          nome?: string
        }
        Relationships: []
      }
      teste_animais: {
        Row: {
          apagado_em: string | null
          atualizado_em: string
          brinco: string | null
          criado_em: string
          criado_por: string | null
          fazenda_id: string
          id: string
          nome: string | null
          versao: number
        }
        Insert: {
          apagado_em?: string | null
          atualizado_em?: string
          brinco?: string | null
          criado_em?: string
          criado_por?: string | null
          fazenda_id: string
          id: string
          nome?: string | null
          versao?: number
        }
        Update: {
          apagado_em?: string | null
          atualizado_em?: string
          brinco?: string | null
          criado_em?: string
          criado_por?: string | null
          fazenda_id?: string
          id?: string
          nome?: string | null
          versao?: number
        }
        Relationships: [
          {
            foreignKeyName: "teste_animais_criado_por_fkey"
            columns: ["criado_por"]
            isOneToOne: false
            referencedRelation: "perfis"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "teste_animais_fazenda_id_fkey"
            columns: ["fazenda_id"]
            isOneToOne: false
            referencedRelation: "fazendas"
            referencedColumns: ["id"]
          },
        ]
      }
      vinculos: {
        Row: {
          apagado_em: string | null
          atualizado_em: string
          criado_em: string
          criado_por: string | null
          fazenda_id: string
          id: string
          papel: Database["public"]["Enums"]["papel_vinculo"]
          usuario_id: string
        }
        Insert: {
          apagado_em?: string | null
          atualizado_em?: string
          criado_em?: string
          criado_por?: string | null
          fazenda_id: string
          id?: string
          papel: Database["public"]["Enums"]["papel_vinculo"]
          usuario_id: string
        }
        Update: {
          apagado_em?: string | null
          atualizado_em?: string
          criado_em?: string
          criado_por?: string | null
          fazenda_id?: string
          id?: string
          papel?: Database["public"]["Enums"]["papel_vinculo"]
          usuario_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "vinculos_criado_por_fkey"
            columns: ["criado_por"]
            isOneToOne: false
            referencedRelation: "perfis"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "vinculos_fazenda_id_fkey"
            columns: ["fazenda_id"]
            isOneToOne: false
            referencedRelation: "fazendas"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "vinculos_usuario_id_fkey"
            columns: ["usuario_id"]
            isOneToOne: false
            referencedRelation: "perfis"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      sincronizar_teste_animal: {
        Args: { p_dados?: Json; p_id: string; p_operacao: string }
        Returns: Json
      }
    }
    Enums: {
      papel_vinculo: "gestor" | "funcionario"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends (DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never) = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends (PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never) = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {
      papel_vinculo: ["gestor", "funcionario"],
    },
  },
} as const
