Ovale.defaut["PRIEST"] =
[[
# --- Spells & Abilities Definitions ---
Define(SHADOWFORM 15473)
Define(VAMPIRICTOUCH 48160)
Define(DEVOURINGPLAGUE 48300)
Define(SHADOWWORDPAIN 48125)
Define(MINDBLAST 48127)
Define(MINDFLAY 48156)
Define(SHADOWWORDDEATH 48158)
Define(SHADOWFIEND 34433)
Define(DISPERSION 47585)
Define(INNERFIRE 48168)
Define(POWERWORDSHIELD 48066)

# Buffs, Debuffs & Procs
Define(SHADOWWEAVING 15258)    # Shadow Weaving buff (stacks 1-5, +10% shadow damage)
Define(VAMPIRICEMBRACE 15286)
Define(WEAKENEDSOUL 6788)

# Talents
Define(TALENTSHADOWFORM 1941)
Define(TALENTDISPERSION 2248)
Define(TALENTVAMPIRICTOUCH 1947)

# Spell details for Ovale simulator
SpellInfo(VAMPIRICTOUCH duration=15)
SpellInfo(DEVOURINGPLAGUE duration=24)
SpellInfo(SHADOWWORDPAIN duration=18)
SpellInfo(MINDBLAST cd=8)
SpellInfo(SHADOWWORDDEATH cd=12)
SpellInfo(SHADOWFIEND cd=180)
SpellInfo(DISPERSION cd=75)

# Mind Flay is a channeled spell, 3 ticks
SpellInfo(MINDFLAY canStopChannelling=3)

SpellAddTargetDebuff(VAMPIRICTOUCH VAMPIRICTOUCH=15)
SpellAddTargetDebuff(DEVOURINGPLAGUE DEVOURINGPLAGUE=24)
SpellAddTargetDebuff(SHADOWWORDPAIN SHADOWWORDPAIN=18)

# --- UI Controls ---
AddListItem(mode raid "Raid / Dungeon" default)
AddListItem(mode level "Leveling / Solo")

AddCheckBox(inner "Maintain Inner Fire" checked)
AddCheckBox(embrace "Maintain Vampiric Embrace" checked)
AddCheckBox(fiend "Auto Shadowfiend (Mana/Burst)" checked)
AddCheckBox(swd "Use SW:Death on Movement" checked)

# --- Icons Layout ---

# 1. Main Rotation Icon
AddIcon help=main
{
	# Проверка поддержания Внутреннего огня (СПД и броня)
	if CheckBoxOn(inner) and BuffExpires(INNERFIRE 2) Spell(INNERFIRE)

	# Облик Тьмы (Shadowform)
	if TalentPoints(TALENTSHADOWFORM more 0) and BuffExpires(SHADOWFORM 0)
	{
		Spell(SHADOWFORM)
	}

	# Объятия вампира (самоотхил и отхил группы)
	if CheckBoxOn(embrace) and BuffExpires(VAMPIRICEMBRACE 2) Spell(VAMPIRICEMBRACE)

	# =========================================================
	# 1. LEVELING / SOLO (Квесты, гринд, прокачка 1-80)
	# =========================================================
	if List(mode level)
	{
		# Добивание Словом Тьмы: Смерть на <20% HP
		if TargetLifePercent(less 20) and Spell(SHADOWWORDDEATH)
		{
			Spell(SHADOWWORDDEATH)
		}

		# Взрыв разума по готовности
		if Spell(MINDBLAST) Spell(MINDBLAST)

		# Быстрое наложение Слова Тьмы: Боль
		if TargetDeadIn(more 5) and TargetDebuffExpires(SHADOWWORDPAIN 2 mine=1)
		{
			Spell(SHADOWWORDPAIN)
		}

		# Всепожирающая чума на жирных мобов
		if TargetDeadIn(more 10) and TargetDebuffExpires(DEVOURINGPLAGUE 2 mine=1) and Spell(DEVOURINGPLAGUE)
		{
			Spell(DEVOURINGPLAGUE)
		}

		# Прикосновение вампира
		if TargetDeadIn(more 10) and TargetDebuffExpires(VAMPIRICTOUCH 2 mine=1) and Spell(VAMPIRICTOUCH)
		{
			Spell(VAMPIRICTOUCH)
		}

		# Основной филлер — Пытка разума
		if Spell(MINDFLAY) Spell(MINDFLAY)
	}

	# =========================================================
	# 2. RAID / DUNGEON (Shadow Priest PvE FCFS)
	# =========================================================
	if List(mode raid)
	{
		# -----------------------------------------------------
		# SHADOW SPEC
		# -----------------------------------------------------
		if TalentPoints(TALENTVAMPIRICTOUCH more 0)
		{
			# ПРИОРИТЕТ 1: Первичное наложение Слова Тьмы: Боль СТРОГО под 5 стаков Shadow Weaving
			# В бою Pain обновляется автоматически от Mind Flay, перекастовывать вручную нельзя!
			if TargetDebuffExpires(SHADOWWORDPAIN 0 mine=1) and BuffPresent(SHADOWWEAVING stacks=5)
			{
				Spell(SHADOWWORDPAIN)
			}

			# ПРИОРИТЕТ 2: Поддержание Прикосновения вампира (Vampiric Touch)
			if TargetDebuffExpires(VAMPIRICTOUCH 1.5 mine=1) and TargetDeadIn(more 8)
			{
				Spell(VAMPIRICTOUCH)
			}

			# ПРИОРИТЕТ 3: Поддержание Всепожирающей чумы (Devouring Plague)
			if TargetDebuffExpires(DEVOURINGPLAGUE 1.5 mine=1) and TargetDeadIn(more 8)
			{
				Spell(DEVOURINGPLAGUE)
			}

			# ПРИОРИТЕТ 4: Взрыв разума (Mind Blast) по откату
			if Spell(MINDBLAST) Spell(MINDBLAST)

			# ПРИОРИТЕТ 5: Слово Тьмы: Смерть (на перебежках)
			if CheckBoxOn(swd) and Speed(more 0) and Spell(SHADOWWORDDEATH)
			{
				Spell(SHADOWWORDDEATH)
			}

			# ПРИОРИТЕТ 6: Базовый спам филлера — Пытка разума (Mind Flay)
			# Также служит для набора первых 5 стаков Shadow Weaving перед стартом SW:P
			Spell(MINDFLAY)
		}

		# -----------------------------------------------------
		# HOLY / DISCIPLINE / SMITE FALLBACK
		# -----------------------------------------------------
		if TalentPoints(TALENTVAMPIRICTOUCH 0)
		{
			if TargetDebuffExpires(SHADOWWORDPAIN 2 mine=1) Spell(SHADOWWORDPAIN)
			if Spell(MINDBLAST) Spell(MINDBLAST)
			Spell(MINDFLAY)
		}
	}
}

# 2. Off-GCD / Mana Management Icon
AddIcon size=small help=cd
{
	# Исчадие Тьмы (Shadowfiend) для регена маны и урона при просадке <60%
	if CheckBoxOn(fiend) and ManaPercent(less 60) and Spell(SHADOWFIEND)
	{
		Spell(SHADOWFIEND)
	}

	# Слияние с Тьмой (Dispersion) при глубоком ООМ (<15% маны)
	if InCombat(yes) and ManaPercent(less 15) and Spell(DISPERSION)
	{
		Spell(DISPERSION)
	}
}
]]
