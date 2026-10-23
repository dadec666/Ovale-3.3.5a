Ovale.defaut["MAGE"] =
[[
# --- Spells & Abilities Definitions ---
Define(ARCANEBLAST 42897)
Define(ARCANEMISSILES 42846)
Define(ARCANEBARRAGE 44425)
Define(FIREBALL 42833)
Define(PYROBLAST 42891)
Define(LIVINGBOMB 55360)
Define(SCORCH 42859)
Define(FROSTBOLT 42842)
Define(ICELANCE 42914)
Define(DEEPFREEZE 44572)
Define(FROSTFIREBOLT 47610)
Define(EVOCATION 12051)
Define(MANAGEM 42985)
Define(MIRRORIMAGE 55342)
Define(ICYVEINS 12472)
Define(ARCANEPOWER 12042)
Define(COMBUSTION 11129)
Define(PRESENCEOFMIND 12043)

# Armors & Buffs
Define(MOLTENARMOR 43046)
Define(MAGEARMOR 43024)
Define(ICEARMOR 43008)

# Buffs, Debuffs & Procs
Define(ARCANEBLASTDEBUFF 36032) # Stacks of Arcane Blast (1-4)
Define(MISSILEBARRAGE 44401)    # Fast Arcane Missiles proc
Define(HOTSTREAK 48108)         # Instant Pyroblast proc
Define(FIREBALLORB 54354)       # Improved Scorch / Shadow and Flame debuff (+5% crit)
Define(FINGERSOFFROST 44544)    # Fingers of Frost (charges)
Define(BRAINFREEZE 44549)       # Fireball! proc in Frost

# Talents
Define(TALENTARCANEBARRAGE 2234)
Define(TALENTLIVINGBOMB 2236)
Define(TALENTDEEPFREEZE 2240)

# Spell details for Ovale simulator
SpellInfo(ARCANEBARRAGE cd=3)
SpellInfo(LIVINGBOMB duration=12)
SpellInfo(DEEPFREEZE cd=30)
SpellInfo(SCORCH duration=30)
SpellInfo(EVOCATION cd=240)
SpellInfo(ARCANEPOWER cd=120)
SpellInfo(ICYVEINS cd=144)
SpellInfo(MIRRORIMAGE cd=180)
SpellInfo(COMBUSTION cd=120)

SpellAddTargetDebuff(LIVINGBOMB LIVINGBOMB=12)
SpellAddTargetDebuff(SCORCH FIREBALLORB=30)

# --- UI Controls ---
AddListItem(mode raid "Raid / Dungeon" default)
AddListItem(mode level "Leveling / Solo")

AddListItem(armor molten "Molten Armor (Crit)" default)
AddListItem(armor mage "Mage Armor (Mana Regen)")

AddCheckBox(scorch "Maintain Scorch / +5% Crit" checked)
AddCheckBox(burst "Auto Cooldowns (Icy Veins / AP)" checked)
AddCheckBox(gem "Use Mana Gem on Mana Drop" checked)

# --- Icons Layout ---

# 1. Main Rotation Icon
AddIcon help=main
{
	# Проверка поддержания доспеха
	if List(armor molten) and BuffExpires(MOLTENARMOR 3) Spell(MOLTENARMOR)
	if List(armor mage) and BuffExpires(MAGEARMOR 3) Spell(MAGEARMOR)

	# =========================================================
	# 1. LEVELING / SOLO (Квесты, открытый мир, Фрост кач)
	# =========================================================
	if List(mode level)
	{
		# Прилив сил при глубокой просадке маны
		if ManaPercent(less 20) and InCombat(no) and Spell(EVOCATION)
		{
			Spell(EVOCATION)
		}

		# Добивание Глубокой заморозкой под прок Пальцев
		if BuffPresent(FINGERSOFFROST) and Spell(DEEPFREEZE) Spell(DEEPFREEZE)

		# Мгновенная Стрела смещения стужи под прок Заморозки мозгов
		if BuffPresent(BRAINFREEZE) and Spell(FROSTFIREBOLT) Spell(FROSTFIREBOLT)

		# Ледяное копье под прок Ледяных пальцев на ходу
		if BuffPresent(FINGERSOFFROST) and Speed(more 0) Spell(ICELANCE)

		# Мгновенная Глыба огня под прок Hot Streak (если вкачан Фаер)
		if BuffPresent(HOTSTREAK) Spell(PYROBLAST)

		# Базовый спам Ледяной стрелы
		Spell(FROSTBOLT)
	}

	# =========================================================
	# 2. RAID / DUNGEON
	# =========================================================
	if List(mode raid)
	{
		# -----------------------------------------------------
		# ARCANE SPEC (Тайная магия)
		# -----------------------------------------------------
		if TalentPoints(TALENTARCANEBARRAGE more 0)
		{
			# Бурсты Аркана
			if CheckBoxOn(burst)
			{
				if Spell(MIRRORIMAGE) Spell(MIRRORIMAGE)
				if Spell(ARCANEPOWER) Spell(ARCANEPOWER)
				if Spell(ICYVEINS) Spell(ICYVEINS)
				if BuffPresent(ARCANEPOWER) and Spell(PRESENCEOFMIND) Spell(PRESENCEOFMIND)
			}

			# Слив 4 стаков Arcane Blast в прокачанные стрелы
			if DebuffExpires(ARCANEBLASTDEBUFF 0 stacks=4) and BuffPresent(MISSILEBARRAGE)
			{
				Spell(ARCANEMISSILES)
			}

			# Слив 4 стаков при отсутствии прока стрел (если мана начинает проседать)
			if DebuffExpires(ARCANEBLASTDEBUFF 0 stacks=4) and ManaPercent(less 60) and Spell(ARCANEBARRAGE)
			{
				Spell(ARCANEBARRAGE)
			}

			# Набор стаков Чародейской вспышки
			Spell(ARCANEBLAST)
		}

		# -----------------------------------------------------
		# FIRE SPEC (Огонь / ТТВ)
		# -----------------------------------------------------
		if TalentPoints(TALENTLIVINGBOMB more 0)
		{
			# Бурст: Зеркальное изображение и Возгорание
			if CheckBoxOn(burst)
			{
				if Spell(MIRRORIMAGE) Spell(MIRRORIMAGE)
				if Spell(COMBUSTION) Spell(COMBUSTION)
			}

			# ПРИОРИТЕТ 1: Мгновенная Глыба огня под прок Hot Streak
			if BuffPresent(HOTSTREAK) Spell(PYROBLAST)

			# ПРИОРИТЕТ 2: Живая бомба (СТРОГО после детонации предыдущей)
			if TargetDebuffExpires(LIVINGBOMB 0 mine=1) and TargetDeadIn(more 12)
			{
				Spell(LIVINGBOMB)
			}

			# ПРИОРИТЕТ 3: Поддержание дебаффа на +5% крита (Scorch), если нет лока/совы
			if CheckBoxOn(scorch) and TargetDebuffExpires(FIREBALLORB 2) and Spell(SCORCH)
			{
				Spell(SCORCH)
			}

			# ПРИОРИТЕТ 4: Основной филлер - Огненный шар (или Стрела ледяного огня)
			Spell(FIREBALL)
		}

		# -----------------------------------------------------
		# FROST SPEC (Лед)
		# -----------------------------------------------------
		if TalentPoints(TALENTDEEPFREEZE more 0)
		{
			if BuffPresent(FINGERSOFFROST) and Spell(DEEPFREEZE) Spell(DEEPFREEZE)
			if BuffPresent(BRAINFREEZE) and Spell(FROSTFIREBOLT) Spell(FROSTFIREBOLT)
			if BuffPresent(FINGERSOFFROST) and Speed(more 0) Spell(ICELANCE)
			Spell(FROSTBOLT)
		}
	}
}

# 2. Off-GCD / Mana Management Icon
AddIcon size=small help=cd
{
	# Камень маны при просадке ниже 75%
	if CheckBoxOn(gem) and ManaPercent(less 75) and Item(MANAGEM)
	{
		Item(MANAGEM)
	}

	# Прилив сил во время боя при сильной просадке маны
	if InCombat(yes) and ManaPercent(less 25) and Spell(EVOCATION)
	{
		Spell(EVOCATION)
	}
}
]]
