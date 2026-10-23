Ovale.defaut["SHAMAN"] =
[[
# --- Spells & Abilities Definitions ---
# Elemental / Common Spells
Define(LIGHTNINGBOLT 49238)
Define(CHAINLIGHTNING 49271)
Define(LAVABURST 60043)
Define(FLAMESHOCK 49233)
Define(EARTHSHOCK 49231)
Define(FROSTSHOCK 49236)
Define(THUNDERSTORM 59159)
Define(ELEMENTALMASTERY 16166)

# Enhancement Spells
Define(STORMSTRIKE 17364)
Define(LAVALASH 60103)
Define(FIRENOVA 61657)
Define(FERALSPIRIT 51533)
Define(SHAMANISTICRAGE 30823)

# Shields
Define(LIGHTNINGSHIELD 49281)
Define(WATERSHIELD 57960)

# Healing fallback
Define(HEALINGWAVE 49273)

# Buffs, Debuffs & Procs
Define(MAELSTROMWEAPON 53817)   # Maelstrom Weapon (stacks 1-5)
Define(STORMSTRIKEDEBUFF 17364) # +20% nature damage charges
Define(CLEARCASTING 16246)

# Talents
Define(TALENTLAVABURST 2073)
Define(TALENTSTORMSTRIKE 901)
Define(TALENTFERALSPIRIT 2263)

# Spell details for Ovale simulator
SpellInfo(LAVABURST cd=8)
SpellInfo(STORMSTRIKE cd=8)
SpellInfo(LAVALASH cd=6)
SpellInfo(FIRENOVA cd=3)
SpellInfo(CHAINLIGHTNING cd=3)
SpellInfo(FLAMESHOCK duration=18 cd=6 sharedcd=shock)
SpellInfo(EARTHSHOCK cd=6 sharedcd=shock)
SpellInfo(FROSTSHOCK cd=6 sharedcd=shock)
SpellInfo(FERALSPIRIT cd=180)
SpellInfo(SHAMANISTICRAGE cd=60)
SpellInfo(ELEMENTALMASTERY cd=180)

SpellAddTargetDebuff(FLAMESHOCK FLAMESHOCK=18)
SpellAddTargetDebuff(STORMSTRIKE STORMSTRIKEDEBUFF=12)

# --- UI Controls ---
AddListItem(mode raid "Raid / Dungeon" default)
AddListItem(mode level "Leveling / Solo")

AddListItem(shield lightning "Lightning Shield" default)
AddListItem(shield water "Water Shield (Mana Regen)")

AddListItem(aoe single "Single Target" default)
AddListItem(aoe aoe "AOE / Multi-Target")

AddCheckBox(cl "Use Chain Lightning (Single Target)" checked)
AddCheckBox(burst "Auto Feral Spirit / Ele Mastery" checked)
AddCheckBox(heal "Heal on 5 Maelstrom Stacks" checked)

# --- Icons Layout ---

# 1. Main Action Icon
AddIcon help=main
{
	# Проверка поддержания активного щита
	if List(shield lightning) and BuffExpires(LIGHTNINGSHIELD 2) Spell(LIGHTNINGSHIELD)
	if List(shield water) and BuffExpires(WATERSHIELD 2) Spell(WATERSHIELD)

	# =========================================================
	# 1. LEVELING / SOLO (Квесты, гринд, прокачка)
	# =========================================================
	if List(mode level)
	{
		# Экстренное мгновенное исцеление Энха при 5 стаках Водоворота
		if CheckBoxOn(heal) and LifePercent(less 50) and BuffPresent(MAELSTROMWEAPON stacks=5)
		{
			Spell(HEALINGWAVE)
		}

		# Энх: мгновенная Молния на 5 стаках Водоворота
		if BuffPresent(MAELSTROMWEAPON stacks=5)
		{
			Spell(LIGHTNINGBOLT)
		}

		# Элем: Выброс лавы strictly под Огненный шок
		if TargetDebuffPresent(FLAMESHOCK mine=1) and Spell(LAVABURST)
		{
			Spell(LAVABURST)
		}

		# Удары ближнего боя Энха
		if Spell(STORMSTRIKE) Spell(STORMSTRIKE)
		if Spell(LAVALASH) Spell(LAVALASH)

		# Поддержание Огненного шока
		if TargetDeadIn(more 6) and TargetDebuffExpires(FLAMESHOCK 2 mine=1) and Spell(FLAMESHOCK)
		{
			Spell(FLAMESHOCK)
		}

		# Земной шок на добивание / прерывание
		if TargetDebuffPresent(FLAMESHOCK mine=1) and Spell(EARTHSHOCK)
		{
			Spell(EARTHSHOCK)
		}

		# Базовый филлер дальнего боя
		Spell(LIGHTNINGBOLT)
	}

	# =========================================================
	# 2. RAID / DUNGEON
	# =========================================================
	if List(mode raid)
	{
		# -----------------------------------------------------
		# ELEMENTAL SPEC (Шаман стихий)
		# -----------------------------------------------------
		if TalentPoints(TALENTLAVABURST more 0)
		{
			# Бурст: Покорение стихий
			if CheckBoxOn(burst) and Spell(ELEMENTALMASTERY) Spell(ELEMENTALMASTERY)

			# ПРИОРИТЕТ 1: Огненный шок (Flame Shock) — база для 100% крита Лавы
			if TargetDebuffExpires(FLAMESHOCK 1.5 mine=1) and Spell(FLAMESHOCK)
			{
				Spell(FLAMESHOCK)
			}

			# ПРИОРИТЕТ 2: Выброс лавы (Lava Burst) строго по откату
			if TargetDebuffPresent(FLAMESHOCK mine=1) and Spell(LAVABURST)
			{
				Spell(LAVABURST)
			}

			# ПРИОРИТЕТ 3: Цепная молния (в АОЕ или если включена в соло)
			if (List(aoe aoe) or CheckBoxOn(cl)) and Spell(CHAINLIGHTNING) and ManaPercent(more 30)
			{
				Spell(CHAINLIGHTNING)
			}

			# ПРИОРИТЕТ 4: Филлер — Молния (Lightning Bolt)
			Spell(LIGHTNINGBOLT)
		}

		# -----------------------------------------------------
		# ENHANCEMENT SPEC (Совершенствование / Энх)
		# -----------------------------------------------------
		if TalentPoints(TALENTSTORMSTRIKE more 0)
		{
			# Бурст: Волки (Feral Spirit)
			if CheckBoxOn(burst) and Spell(FERALSPIRIT) Spell(FERALSPIRIT)

			# ПРИОРИТЕТ 1: Молния при 5 стаках Оружия Водоворота (Maelstrom Weapon)
			if BuffPresent(MAELSTROMWEAPON stacks=5)
			{
				Spell(LIGHTNINGBOLT)
			}

			# ПРИОРИТЕТ 2: Удар бури (Stormstrike)
			if Spell(STORMSTRIKE) Spell(STORMSTRIKE)

			# ПРИОРИТЕТ 3: Огненный шок (если спал)
			if TargetDebuffExpires(FLAMESHOCK 1.5 mine=1) and Spell(FLAMESHOCK)
			{
				Spell(FLAMESHOCK)
			}

			# ПРИОРИТЕТ 4: Земной шок (Earth Shock под дебафф Stormstrike)
			if TargetDebuffPresent(FLAMESHOCK mine=1) and Spell(EARTHSHOCK)
			{
				Spell(EARTHSHOCK)
			}

			# ПРИОРИТЕТ 5: Вскипание лавы (Lava Lash)
			if Spell(LAVALASH) Spell(LAVALASH)

			# ПРИОРИТЕТ 6: Кольцо огня (Fire Nova)
			if Spell(FIRENOVA) and ManaPercent(more 25)
			{
				Spell(FIRENOVA)
			}

			# ПРИОРИТЕТ 7: Молния при 3-4 стаках Водоворота (только при простое других скилов)
			if BuffPresent(MAELSTROMWEAPON stacks=3) and Spell(STORMSTRIKE) == nil and Spell(LAVALASH) == nil
			{
				Spell(LIGHTNINGBOLT)
			}
		}

		# -----------------------------------------------------
		# RESTORATION / FALLBACK
		# -----------------------------------------------------
		if TalentPoints(TALENTLAVABURST 0) and TalentPoints(TALENTSTORMSTRIKE 0)
		{
			if TargetDebuffExpires(FLAMESHOCK 1.5 mine=1) and Spell(FLAMESHOCK) Spell(FLAMESHOCK)
			Spell(LIGHTNINGBOLT)
		}
	}
}

# 2. Off-GCD / Utility Icon (Shamanistic Rage & Buffs)
AddIcon size=small help=cd
{
	# Шаманская ярость (Энх) при просадке маны ниже 40% или для снижения урона
	if TalentPoints(TALENTSTORMSTRIKE more 0) and ManaPercent(less 40) and Spell(SHAMANISTICRAGE)
	{
		Spell(SHAMANISTICRAGE)
	}

	# Гром и молния (Элем) при нехватке маны
	if TalentPoints(TALENTLAVABURST more 0) and ManaPercent(less 30) and Spell(THUNDERSTORM)
	{
		Spell(THUNDERSTORM)
	}
}
]]
