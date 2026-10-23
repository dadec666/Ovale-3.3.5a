Ovale.defaut["PALADIN"] =
[[
# --- Spells & Buffs Definitions ---
Define(JUDGEMENTOFWISDOM 53408)
Define(JUDGEMENTOFLIGHT 20271)
Define(CRUSADERSTRIKE 35395)
Define(DIVINESTORM 53385)
Define(CONSECRATION 48819)
Define(EXORCISM 48801)
Define(HAMMEROFWRATH 48806)
Define(HOLYWRATH 48817)
Define(DIVINEPLEA 54428)
Define(AVENGINGWRATH 31884)
Define(FLASHOFLIGHT 48785)
Define(SACREDSHIELD 53601)

# Seals
Define(SEALOFCOMMAND 20375)
Define(SEALOFVENGEANCE 31801)
Define(SEALORCORRUPTION 53736)

# Buffs & Procs
Define(ARTOFWAR 59578)              # Instant Exorcism / Flash of Light
Define(SACREDRETRIBUTION 70764)     # T10 2pc reset Divine Storm cooldown proc
Define(JUDGEMENTSOFTHEWISE 31878)   # Mana regen buff
Define(FORBEARANCE 25771)

# Talents
Define(TALENTCRUSADERSTRIKE 1825)
Define(TALENTDIVINESTORM 1827)
Define(TALENTHOLYSHOCK 1433)

# Spell details for Ovale simulator
SpellInfo(CRUSADERSTRIKE cd=4)
SpellInfo(DIVINESTORM cd=10)
SpellInfo(JUDGEMENTOFWISDOM cd=8)
SpellInfo(JUDGEMENTOFLIGHT cd=8)
SpellInfo(CONSECRATION cd=8)
SpellInfo(EXORCISM cd=15)
SpellInfo(HAMMEROFWRATH cd=6)
SpellInfo(HOLYWRATH cd=30)
SpellInfo(DIVINEPLEA cd=60)
SpellInfo(AVENGINGWRATH cd=120)

# --- UI Controls ---
AddListItem(mode raid "Raid / Dungeon" default)
AddListItem(mode level "Leveling / Solo")

AddListItem(t10 not10 "Standard / Pre-T10" default)
AddListItem(t10 t10 "T10 2pc / 4pc Equipped")

AddListItem(seal vengeance "Seal of Vengeance / Corruption" default)
AddListItem(seal command "Seal of Command (AOE/Leveling)")

AddListItem(judge wisdom "Judgement of Wisdom" default)
AddListItem(judge light "Judgement of Light")

AddCheckBox(plea "Maintain Divine Plea" checked)
AddCheckBox(heal "Heal on Art of War" checked)
AddCheckBox(wings "Auto Avenging Wrath" checked)

# --- Icons Layout ---

# 1. Main Action Icon
AddIcon help=main
{
	# Проверка поддержания активной печати
	if List(seal vengeance) and BuffExpires(SEALOFVENGEANCE 3) and BuffExpires(SEALORCORRUPTION 3)
	{
		Spell(SEALOFVENGEANCE)
	}
	if List(seal command) and BuffExpires(SEALOFCOMMAND 3)
	{
		Spell(SEALOFCOMMAND)
	}

	# Поддержание Священной клятвы (Divine Plea) по КД для регенерации маны
	if CheckBoxOn(plea) and Spell(DIVINEPLEA) Spell(DIVINEPLEA)

	# =========================================================
	# 1. LEVELING / SOLO (Квесты, открытый мир, гринд)
	# =========================================================
	if List(mode level)
	{
		# Экстренное мгновенное самоисцеление при <50% HP через прок Искусства войны
		if CheckBoxOn(heal) and LifePercent(less 50) and BuffPresent(ARTOFWAR)
		{
			Spell(FLASHOFLIGHT)
		}

		# Добивание Молотом гнева на <20%
		if TargetLifePercent(less 20) and Spell(HAMMEROFWRATH)
		{
			Spell(HAMMEROFWRATH)
		}

		# Удар воина Света (быстрый 4с КД)
		if Spell(CRUSADERSTRIKE) Spell(CRUSADERSTRIKE)

		# Божественная буря
		if Spell(DIVINESTORM) Spell(DIVINESTORM)

		# Правосудие для регена маны
		if List(judge wisdom) and Spell(JUDGEMENTOFWISDOM) Spell(JUDGEMENTOFWISDOM)
		if List(judge light) and Spell(JUDGEMENTOFLIGHT) Spell(JUDGEMENTOFLIGHT)

		# Мгновенный Экзорцизм по проку Art of War
		if BuffPresent(ARTOFWAR) and Spell(EXORCISM) Spell(EXORCISM)

		# Освящение (только если моб живет дольше 5с и запас маны > 30%)
		if TargetDeadIn(more 5) and ManaPercent(more 30) and Spell(CONSECRATION) Spell(CONSECRATION)

		# Гнев небес против нежити и демонов
		if (TargetCreatureType(Undead) or TargetCreatureType(Demon)) and Spell(HOLYWRATH)
		{
			Spell(HOLYWRATH)
		}
	}

	# =========================================================
	# 2. RAID / DUNGEON (Эндгейм боссы, строгий FCFS)
	# =========================================================
	if List(mode raid)
	{
		# -----------------------------------------------------
		# RETRIBUTION SPEC
		# -----------------------------------------------------
		if TalentPoints(TALENTDIVINESTORM more 0)
		{
			# Бурст: Крылья (Avenging Wrath)
			if CheckBoxOn(wings) and Spell(AVENGINGWRATH) Spell(AVENGINGWRATH)

			# ПРИОРИТЕТ 1: Божественная буря под сброс кулдауна от 2хТ10
			if List(t10 t10) and (BuffPresent(SACREDRETRIBUTION) or Spell(DIVINESTORM))
			{
				Spell(DIVINESTORM)
			}

			# ПРИОРИТЕТ 2: Фаза казни (<20% HP) - Молот гнева
			if TargetLifePercent(less 20) and Spell(HAMMEROFWRATH)
			{
				Spell(HAMMEROFWRATH)
			}

			# ПРИОРИТЕТ 3: Правосудие (Judgement) - поддержание 8-секундного баффа спешки и регена
			if List(judge wisdom) and Spell(JUDGEMENTOFWISDOM) Spell(JUDGEMENTOFWISDOM)
			if List(judge light) and Spell(JUDGEMENTOFLIGHT) Spell(JUDGEMENTOFLIGHT)

			# ПРИОРИТЕТ 4: Удар воина Света (Crusader Strike)
			if Spell(CRUSADERSTRIKE) Spell(CRUSADERSTRIKE)

			# ПРИОРИТЕТ 5: Божественная буря (для экипировки без 2хТ10)
			if List(t10 not10) and Spell(DIVINESTORM) Spell(DIVINESTORM)

			# ПРИОРИТЕТ 6: Освящение (Consecration)
			if Spell(CONSECRATION) Spell(CONSECRATION)

			# ПРИОРИТЕТ 7: Экзорцизм под прок Искусства войны
			if BuffPresent(ARTOFWAR) and Spell(EXORCISM) Spell(EXORCISM)

			# ПРИОРИТЕТ 8: Гнев небес (Holy Wrath) против нежити/демонов (актуально в ЦЛК)
			if (TargetCreatureType(Undead) or TargetCreatureType(Demon)) and Spell(HOLYWRATH)
			{
				Spell(HOLYWRATH)
			}
		}

		# -----------------------------------------------------
		# PROTECTION / GENERIC FALLBACK
		# -----------------------------------------------------
		if TalentPoints(TALENTDIVINESTORM 0)
		{
			if List(judge wisdom) and Spell(JUDGEMENTOFWISDOM) Spell(JUDGEMENTOFWISDOM)
			if List(judge light) and Spell(JUDGEMENTOFLIGHT) Spell(JUDGEMENTOFLIGHT)
			if Spell(CRUSADERSTRIKE) Spell(CRUSADERSTRIKE)
			if Spell(CONSECRATION) Spell(CONSECRATION)
			if BuffPresent(ARTOFWAR) and Spell(EXORCISM) Spell(EXORCISM)
		}
	}
}

# 2. Off-GCD / Utility Icon
AddIcon size=small help=cd
{
	# Поддержание Священного щита (Sacred Shield), если взят в талантах
	if TargetBuffExpires(SACREDSHIELD 1 mine=1) and Spell(SACREDSHIELD) Spell(SACREDSHIELD)
}
]]
