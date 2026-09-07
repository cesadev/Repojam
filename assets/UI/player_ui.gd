extends Control


# ============================================================
# REFERÊNCIAS AOS LABELS
# ============================================================

@onready var meta_label = $Meta
@onready var fase_label = $Fase


# ============================================================
# ATUALIZAR META
# ============================================================

func atualizar_meta(valor_atual: int, valor_meta: int):

	meta_label.text = str(valor_atual) + " / " + str(valor_meta)


# ============================================================
# ATUALIZAR FASE
# ============================================================

func atualizar_fase(fase_atual: int, total_fases: int):

	fase_label.text = str(fase_atual) + " / " + str(total_fases)
