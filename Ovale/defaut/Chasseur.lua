Ovale.defaut["HUNTER"] =
[[
# --- Spells & Abilities ---
Define(SERPENTSTING 49001)
Define(CHIMERASHOT 53209)
Define(AIMEDSHOT 49050)
Define(EXPLOSIVESHOT 60053)
Define(BLACKARROW 63670)
Define(KILLSHOT 61006)
Define(STEADYSHOT 49052)
Define(ARCANESHOT 49045)
Define(VOLLEY 58434)
Define(HUNTERSMARK 53338)
Define(KILLCOMMAND 34026)
Define(RAPIDFIRE 3045)
Define(BESTIALWRATH 19574)
Define(READINESS 23989)
Define(SILENCINGSHOT 34490)

# Aspects
Define(ASPECTDRAGONHAWK 61840)
Define(ASPECTVIPER 34074)

# Buffs & Procs
Define(LOCKANDLOAD 56453)      # Lock and Load proc (Survival)
Define(RAPIDRECUPERATION 53232)
Define(FIRE 82926)

# Talents
Define(TALENTCHIMERASHOT 2121)
Define(TALENTEXPLOSIVESHOT 2145)
Define(TALENTBESTIALWRATH 1382)

# Spell details for Ovale simulator
SpellInfo(CHIMERASHOT cd=10)
SpellInfo(AIMEDSHOT cd=10)
SpellInfo(EXPLOSIVESHOT cd=6)
SpellInfo(BLACKARROW cd=30)
SpellInfo(KILLSHOT cd=15)
SpellInfo(STEADYSHOT cd=0)
SpellInfo(ARCANESHOT cd=6)
SpellInfo(SERPENTSTING duration=21)
SpellInfo(BLACKARROW duration=15)
SpellInfo(RAPIDFIRE cd=180)
SpellInfo(BESTIALWRATH cd=120)
SpellInfo(READINESS cd=180)

SpellAddTargetDebuff(SERPENTSTING SERPENTSTING=21)
SpellAddTargetDebuff(BLACKARROW BLACKARROW=15)
SpellAddTargetDebuff(EXPLOSIVESHOT EXPLOSIVESHOT=2)

# --- UI Controls ---
AddListItem(mode raid "Raid / Dungeon" default)
AddListItem(mode level "Leveling / Solo")

AddListItem(arcanemode noarcane "MM: Skip Arcane Shot (Armor Pen)" default)
AddListItem(arcanemode usearcane "MM: Use Arcane Shot (Low Gear)")

AddCheckBox(aspects "Auto Manage Aspects (Viper/Hawk)" checked)
AddCheckBox(mark "Maintain Hunter's Mark" checked)
AddCheckBox(burst "Auto Rapid Fire / Bestial Wrath" checked)

# --- Icons Layout ---

# 1. Main Rotation Icon
AddIcon help=main
{
	# Управление духами: переход в Дух гадюки при OOM и возврат в Дракондора
	if CheckBoxOn(aspects)
	{
		if ManaPercent(less 15) and BuffExpires(ASPECTVIPER 0) Spell(ASPECTVIPER)
		if ManaPercent(more 85) and BuffExpires(ASPECTDRAGONHAWK 0) Spell(ASPECTDRAGONHAWK)
	}

	# Поддержание Метки охотника на боссе
	if CheckBoxOn(mark) and TargetDebuffExpires(HUNTERSMARK 0) Spell(HUNTERSMARK)

	# =========================================================
	# 1. LEVELING / SOLO (Квесты, гринд, БМ / ММ кач)
	# =========================================================
	if List(mode level)
	{
		# Фаза казни (<20% HP) - Убийственный выстрел
		if TargetLifePercent(less 20) and Spell(KILLSHOT) Spell(KILLSHOT)

		# Мгновенные укусы и выстрелы для быстрого убийства
		if TargetDeadIn(more 6) and TargetDebuffExpires(SERPENTSTING 2 mine=1) Spell(SERPENTSTING)
		if Spell(ARCANESHOT) Spell(ARCANESHOT)
		if Spell(AIMEDSHOT) Spell(AIMEDSHOT)
		if Spell(CHIMERASHOT) Spell(CHIMERASHOT)
		if Spell(EXPLOSIVESHOT) Spell(EXPLOSIVESHOT)

		# Филлер - Верный выстрел
		Spell(STEADYSHOT)
	}

	# =========================================================
	# 2. RAID / DUNGEON
	# =========================================================
	if List(mode raid)
	{
		# -----------------------------------------------------
		# MARKSMANSHIP SPEC (ММ)
		# -----------------------------------------------------
		if TalentPoints(TALENTCHIMERASHOT more 0)
		{
			# ПРИОРИТЕТ 1: Фаза казни (<20% HP)
			if TargetLifePercent(less 20) and Spell(KILLSHOT) Spell(KILLSHOT)

			# ПРИОРИТЕТ 2: Поддержание Укуса змеи (база для урона Химеры)
			if TargetDebuffExpires(SERPENTSTING 0 mine=1) Spell(SERPENTSTING)

			# ПРИОРИТЕТ 3: Выстрел химеры (Chimera Shot)
			if Spell(CHIMERASHOT) Spell(CHIMERASHOT)

			# ПРИОРИТЕТ 4: Прицельный выстрел (Aimed Shot)
			if Spell(AIMEDSHOT) Spell(AIMEDSHOT)

			# ПРИОРИТЕТ 5: Чародейский выстрел (только если включен для лоу-гира)
			if List(arcanemode usearcane) and Spell(ARCANESHOT) Spell(ARCANESHOT)

			# ПРИОРИТЕТ 6: Филлер - Верный выстрел
			Spell(STEADYSHOT)
		}

		# -----------------------------------------------------
		# SURVIVAL SPEC (Сурв)
		# -----------------------------------------------------
		if TalentPoints(TALENTEXPLOSIVESHOT more 0)
		{
			# ПРИОРИТЕТ 1: Фаза казни (<20% HP)
			if TargetLifePercent(less 20) and Spell(KILLSHOT) Spell(KILLSHOT)

			# ПРИОРИТЕТ 2: Разрывной выстрел (Explosive Shot)
			if TargetDebuffExpires(EXPLOSIVESHOT 0.2 mine=1) and Spell(EXPLOSIVESHOT)
			{
				Spell(EXPLOSIVESHOT)
			}

			# ПРИОРИТЕТ 3: Черная стрела (Black Arrow)
			if Spell(BLACKARROW) Spell(BLACKARROW)

			# ПРИОРИТЕТ 4: Укус змеи
			if TargetDebuffExpires(SERPENTSTING 1.5 mine=1) Spell(SERPENTSTING)

			# ПРИОРИТЕТ 5: Прицельный выстрел
			if Spell(AIMEDSHOT) Spell(AIMEDSHOT)

			# ПРИОРИТЕТ 6: Верный выстрел
			Spell(STEADYSHOT)
		}

		# -----------------------------------------------------
		# BEAST MASTERY SPEC (БМ)
		# -----------------------------------------------------
		if TalentPoints(TALENTBESTIALWRATH more 0)
		{
			if TargetLifePercent(less 20) and Spell(KILLSHOT) Spell(KILLSHOT)
			if TargetDebuffExpires(SERPENTSTING 0 mine=1) Spell(SERPENTSTING)
			if Spell(ARCANESHOT) Spell(ARCANESHOT)
			if Spell(AIMEDSHOT) Spell(AIMEDSHOT)
			Spell(STEADYSHOT)
		}
	}
}

# 2. Off-GCD / Utility Icon (Pet commands & Bursts)
AddIcon size=small help=cd
{
	# Глушащий выстрел у ММ (вне GCD, нажимается по кулдауну)
	if TalentPoints(TALENTCHIMERASHOT more 0) and Spell(SILENCINGSHOT) Spell(SILENCINGSHOT)

	# Команда "Взять!" по КД
	if PetPresent(yes) and Spell(KILLCOMMAND) Spell(KILLCOMMAND)

	# Бурсты (Быстрая стрельба / Озверин)
	if CheckBoxOn(burst)
	{
		if Spell(RAPIDFIRE) Spell(RAPIDFIRE)
		if TalentPoints(TALENTBESTIALWRATH more 0) and Spell(BESTIALWRATH) Spell(BESTIALWRATH)
		if Spell(READINESS) and BuffExpires(RAPIDFIRE 0) Spell(READINESS)
	}
}
]]
