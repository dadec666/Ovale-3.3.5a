Ovale.defaut["WARRIOR"] =
[[
# --- Spells & Abilities ---
Define(BLOODTHIRST 23881)
Define(WHIRLWIND 1680)
Define(MORTALSTRIKE 12294)
Define(SLAM 47475)
Define(EXECUTE 47471)
Define(OVERPOWER 7384)
Define(REND 47465)
Define(BLADESTORM 46924)
Define(VICTORYRUSH 34428)
Define(HEROICSTRIKE 47450)
Define(CLEAVE 47440)
Define(SHIELDSLAM 47488)
Define(REVENGE 57823)
Define(DEVASTATE 47498)
Define(THUNDERCLAP 47502)
Define(SHOCKWAVE 46968)

# Shouts & Buffs
Define(BATTLESHOUT 47436)
Define(COMMANDINGSHOUT 47440)
Define(DEATHWISH 12292)
Define(RECKLESSNESS 1719)
Define(SWEEPINGSTRIKES 12328)
Define(ENRAGEDREGENERATION 55694)
Define(BLOODRAGE 2687)

# Procs & Buff Tracking
Define(BLOODSURGE 46916)      # Instant Slam proc (Fury)
Define(TASTEFOREBLOOD 56638)  # Overpower trigger from Rend (Arms)
Define(SUDDENDEATH 52437)     # Execute trigger in Arms
Define(SLAMMING 47475)

# Talents
Define(TALENTBLOODTHIRST 1640)
Define(TALENTMORTALSTRIKE 1560)
Define(TALENTSHOCKWAVE 1668)
Define(TALENTBLADESTORM 1860)

# Spell details for Ovale simulator
SpellInfo(BLOODTHIRST cd=4)
SpellInfo(WHIRLWIND cd=8)
SpellInfo(MORTALSTRIKE cd=4)
SpellInfo(BLADESTORM cd=90)
SpellInfo(SLAM cd=0)
SpellInfo(OVERPOWER cd=5)
SpellInfo(SHIELDSLAM cd=6)
SpellInfo(REVENGE cd=5)
SpellInfo(SHOCKWAVE cd=20)
SpellInfo(REND duration=15)
SpellInfo(BATTLESHOUT duration=120)
SpellInfo(COMMANDINGSHOUT duration=120)

SpellAddTargetDebuff(REND REND=15)

# --- UI Controls ---
AddListItem(mode raid "Raid / Dungeon" default)
AddListItem(mode level "Leveling / Solo")

AddListItem(shout battle "Battle Shout" default)
AddListItem(shout command "Commanding Shout")

AddListItem(cleave single "Single Target (Heroic Strike)" default)
AddListItem(cleave aoe "AOE / Cleave (Cleave)")

AddCheckBox(burst "Auto Death Wish / Cooldowns" checked)
AddCheckBox(bladestorm "Auto Bladestorm" checked)
AddCheckBox(vrush "Victory Rush on Kill" checked)

# --- Icons Layout ---

# 1. Main Rotation Icon (GCD Abilities)
AddIcon help=main
{
	# Проверка поддержания крика (силы атаки или ХП)
	if List(shout battle) and BuffExpires(BATTLESHOUT 3) Spell(BATTLESHOUT)
	if List(shout command) and BuffExpires(COMMANDINGSHOUT 3) Spell(COMMANDINGSHOUT)

	# =========================================================
	# 1. LEVELING / SOLO (Квесты, гринд, прокачка 1-80)
	# =========================================================
	if List(mode level)
	{
		# Бесплатный Победный раж после каждого убийства
		if CheckBoxOn(vrush) and Spell(VICTORYRUSH) Spell(VICTORYRUSH)

		# Добивание Казнью на <20%
		if TargetLifePercent(less 20) and Mana(more 15) Spell(EXECUTE)

		# Превосходство по проку Вкуса крови или уклонению цели
		if Spell(OVERPOWER) Spell(OVERPOWER)

		# Рваная рана для запуска тиков Вкуса крови
		if TargetDeadIn(more 6) and TargetDebuffExpires(REND 2 mine=1) and Mana(more 10)
		{
			Spell(REND)
		}

		# Удар по специализации
		if TalentPoints(TALENTBLOODTHIRST more 0) and Spell(BLOODTHIRST) and Mana(more 20) Spell(BLOODTHIRST)
		if TalentPoints(TALENTMORTALSTRIKE more 0) and Spell(MORTALSTRIKE) and Mana(more 30) Spell(MORTALSTRIKE)

		# Прок мгновенного Мощного удара
		if BuffPresent(BLOODSURGE) Spell(SLAM)

		# Базовое сбрасывание ярости
		if Mana(more 45) and Spell(WHIRLWIND) Spell(WHIRLWIND)
	}

	# =========================================================
	# 2. RAID / DUNGEON
	# =========================================================
	if List(mode raid)
	{
		# -----------------------------------------------------
		# ARMS SPEC
		# -----------------------------------------------------
		if TalentPoints(TALENTMORTALSTRIKE more 0)
		{
			# Поддержание Рваной раны (Rend) - фундамент Arms ветки
			if TargetDebuffExpires(REND 2.0 mine=1) and Mana(more 10) Spell(REND)

			# Казнь под прок Внезапной смерти (Sudden Death)
			if BuffPresent(SUDDENDEATH) and Mana(more 15) Spell(EXECUTE)

			# Вихрь клинков (Bladestorm) по КД
			if CheckBoxOn(bladestorm) and Spell(BLADESTORM) and Mana(more 25) Spell(BLADESTORM)

			# Превосходство под прок Taste for Blood
			if (BuffPresent(TASTEFOREBLOOD) or Spell(OVERPOWER)) and Mana(more 5) Spell(OVERPOWER)

			# Смертельный удар (Mortal Strike)
			if Spell(MORTALSTRIKE) and Mana(more 30) Spell(MORTALSTRIKE)

			# Добивание на фазе <20% HP
			if TargetLifePercent(less 20) and Mana(more 30) Spell(EXECUTE)

			# Мощный удар под прок Slamming / Bloodsurge
			if BuffPresent(BLOODSURGE) Spell(SLAM)

			# Слив избыточной ярости при простоях
			if Mana(more 40) and Spell(THUNDERCLAP) Spell(THUNDERCLAP)
		}

		# -----------------------------------------------------
		# FURY SPEC
		# -----------------------------------------------------
		if TalentPoints(TALENTBLOODTHIRST more 0)
		{
			# Бурст: Жажда смерти
			if CheckBoxOn(burst) and Spell(DEATHWISH) Spell(DEATHWISH)

			# ПРИОРИТЕТ 1: Кровожадность (Bloodthirst) - основной генератор
			if Spell(BLOODTHIRST) and Mana(more 20) Spell(BLOODTHIRST)

			# ПРИОРИТЕТ 2: Вихрь (Whirlwind)
			if Spell(WHIRLWIND) and Mana(more 25) Spell(WHIRLWIND)

			# ПРИОРИТЕТ 3: Мгновенный Мощный удар под прок Прилива крови
			if BuffPresent(BLOODSURGE) and Mana(more 15) Spell(SLAM)

			# ПРИОРИТЕТ 4: Казнь (Execute) строго при простое кулдаунов и проке
			if TargetLifePercent(less 20) and Mana(more 30) and TargetDebuffExpires(BLOODTHIRST 1) and TargetDebuffExpires(WHIRLWIND 1)
			{
				Spell(EXECUTE)
			}
		}

		# -----------------------------------------------------
		# PROTECTION SPEC
		# -----------------------------------------------------
		if TalentPoints(TALENTSHOCKWAVE more 0)
		{
			if Spell(SHIELDSLAM) and Mana(more 20) Spell(SHIELDSLAM)
			if Spell(REVENGE) and Mana(more 5) Spell(REVENGE)
			if Spell(SHOCKWAVE) and Mana(more 15) Spell(SHOCKWAVE)
			if TargetDebuffExpires(THUNDERCLAP 3) and Spell(THUNDERCLAP) and Mana(more 20) Spell(THUNDERCLAP)
			if Spell(DEVASTATE) and Mana(more 15) Spell(DEVASTATE)
		}
	}
}

# 2. Off-GCD / Next-Melee Action (Heroic Strike / Cleave)
AddIcon size=small help=offgcd
{
	# Очередь Удар героя / Рассекающий удар (строго при избытке ярости)
	if List(cleave single) and Mana(more 45)
	{
		Spell(HEROICSTRIKE)
	}
	if List(cleave aoe) and Mana(more 45)
	{
		Spell(CLEAVE)
	}

	# Кровавая ярость при просадке ярости в бою
	if InCombat(yes) and Mana(less 20) and Spell(BLOODRAGE)
	{
		Spell(BLOODRAGE)
	}
}
]]
