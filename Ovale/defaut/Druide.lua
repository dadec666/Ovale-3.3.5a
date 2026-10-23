Ovale.defaut["DRUID"] =
[[
# --- Spells & Abilities Definitions ---
# Feral (Cat)
Define(MANGLECAT 48566)
Define(SHRED 48572)
Define(RAKE 48574)
Define(RIP 49800)
Define(SAVAGEROAR 52610)
Define(FEROCIOUSBITE 48577)
Define(TIGERSFURY 50213)
Define(BERSERK 50334)
Define(FAERIEFIREFAT 16857)

# Balance (Owl)
Define(STARFIRE 48465)
Define(WRATH 48461)
Define(MOONFIRE 48463)
Define(INSECTSWARM 48468)
Define(STARFALL 53201)
Define(FORCEOFNATURE 33831)
Define(FAERIEFIRE 770)

# Forms
Define(CATFORM 768)
Define(MOONKINFORM 24858)
Define(BEARFORM 9634)

# Buffs, Debuffs & Procs
Define(CLEARCASTING 16870)     # Omen of Clarity proc
Define(LUNARECLIPSE 48518)     # +40% Starfire crit
Define(SOLARECLIPSE 48517)     # +40% Wrath damage
Define(MANGLEDEBUFF 33876)     # Trauma / Mangle +30% bleed damage

# Talents
Define(TALENTFORCEOFNATURE 1819)
Define(TALENTBERSERK 2244)
Define(TALENTSTARFALL 1821)

# Spell details for Ovale simulator
SpellInfo(RIP duration=12)
SpellInfo(RAKE duration=9)
SpellInfo(SAVAGEROAR duration=14)
SpellInfo(MOONFIRE duration=12)
SpellInfo(INSECTSWARM duration=12)
SpellInfo(STARFALL cd=90)
SpellInfo(FORCEOFNATURE cd=180)
SpellInfo(TIGERSFURY cd=30)
SpellInfo(BERSERK cd=180)
SpellInfo(FAERIEFIREFAT cd=6)
SpellInfo(FAERIEFIRE cd=6)

SpellAddTargetDebuff(RIP RIP=12)
SpellAddTargetDebuff(RAKE RAKE=9)
SpellAddTargetDebuff(MOONFIRE MOONFIRE=12)
SpellAddTargetDebuff(INSECTSWARM INSECTSWARM=12)

# --- UI Controls ---
AddListItem(mode raid "Raid / Dungeon" default)
AddListItem(mode level "Leveling / Solo")

AddCheckBox(faerie "Maintain Faerie Fire" checked)
AddCheckBox(burst "Auto Berserk / Starfall" checked)
AddCheckBox(treants "Auto Force of Nature" checked)

# --- Icons Layout ---

# 1. Main Action Icon
AddIcon help=main
{
	# =========================================================
	# 1. FERAL CAT ROTATION (Форма кошки)
	# =========================================================
	if Stance(3) # Cat Form
	{
		# Бафф Волшебного огня (броня цели и бесплатный триггер Omen of Clarity)
		if CheckBoxOn(faerie) and TargetDebuffExpires(FAERIEFIREFAT 2) and TargetDebuffExpires(FAERIEFIRE 2)
		{
			Spell(FAERIEFIREFAT)
		}

		# -----------------------------------------------------
		# LEVELING / SOLO (Квесты, быстрые мобы)
		# -----------------------------------------------------
		if List(mode level)
		{
			# Поддержание Дикого рева хотя бы на 1 комбо-поинте
			if BuffExpires(SAVAGEROAR 2) and ComboPoints(more 0)
			{
				Spell(SAVAGEROAR)
			}

			# Быстрый Укус на 4-5 комбо-поинтах
			if ComboPoints(more 3) and Mana(more 35)
			{
				Spell(FEROCIOUSBITE)
			}

			# Глубокая рана на мобов жирнее 6 сек
			if TargetDeadIn(more 6) and TargetDebuffExpires(RAKE 2 mine=1) and Mana(more 35)
			{
				Spell(RAKE)
			}

			# Бесплатный Shred под клиркаст
			if BuffPresent(CLEARCASTING) Spell(SHRED)

			# Филлер: Увечье (если цель лицом) или Полоснуть
			if Mana(more 40)
			{
				Spell(MANGLECAT)
			}
		}

		# -----------------------------------------------------
		# RAID / DUNGEON (Эндгейм ротация кота)
		# -----------------------------------------------------
		if List(mode raid)
		{
			# ПРИОРИТЕТ 1: Дикий рёв (Savage Roar) - основа всего урона (+30%)
			if BuffExpires(SAVAGEROAR 1.5) and ComboPoints(more 0)
			{
				Spell(SAVAGEROAR)
			}

			# ПРИОРИТЕТ 2: Поддержание Разорвать (Rip) на 5 комбо-поинтах
			if ComboPoints(more 4) and TargetDebuffExpires(RIP 2.0 mine=1) and TargetDeadIn(more 10)
			{
				Spell(RIP)
			}

			# ПРИОРИТЕТ 3: Свирепый укус (Bite) строго в безопасные окна (когда Rip и Roar висят долго)
			if ComboPoints(more 4) and TargetDebuffExpires(RIP 8 mine=1) and BuffExpires(SAVAGEROAR 8) and Mana(more 35)
			{
				Spell(FEROCIOUSBITE)
			}

			# ПРИОРИТЕТ 4: Поддержание дебаффа Увечья / Травмы (+30% к блидам)
			if TargetDebuffExpires(MANGLEDEBUFF 0) and Spell(MANGLECAT) and Mana(more 35)
			{
				Spell(MANGLECAT)
			}

			# ПРИОРИТЕТ 5: Поддержание Глубокой раны (Rake)
			if TargetDebuffExpires(RAKE 1.5 mine=1) and Mana(more 35)
			{
				Spell(RAKE)
			}

			# ПРИОРИТЕТ 6: Бесплатный Полоснуть (Shred) под прок Omen of Clarity
			if BuffPresent(CLEARCASTING) Spell(SHRED)

			# ПРИОРИТЕТ 7: Филлер для набора комбо-поинтов - Полоснуть (Shred)
			if Mana(more 42)
			{
				Spell(SHRED)
			}
		}
	}

	# =========================================================
	# 2. BALANCE ROTATION (Форма лунного совуха)
	# =========================================================
	if Stance(5) or TalentPoints(TALENTSTARFALL more 0) # Moonkin Form / Balance Spec
	{
		# Звездопад по КД
		if CheckBoxOn(burst) and Spell(STARFALL) Spell(STARFALL)

		# Волшебный огонь на боссе (+3% меткости рейду)
		if CheckBoxOn(faerie) and TargetDebuffExpires(FAERIEFIRE 2) Spell(FAERIEFIRE)

		# -----------------------------------------------------
		# ФАЗА ЛУННОГО ЗАТМЕНИЯ (+40% крита Звездного огня)
		# -----------------------------------------------------
		if BuffPresent(LUNARECLIPSE)
		{
			Spell(STARFIRE)
		}

		# -----------------------------------------------------
		# ФАЗА СОЛНЕЧНОГО ЗАТМЕНИЯ (+40% урона Гнева)
		# -----------------------------------------------------
		if BuffPresent(SOLARECLIPSE)
		{
			Spell(WRATH)
		}

		# -----------------------------------------------------
		# ВНЕ ЗАТМЕНИЯ (Поддержание DoT и триггер проков)
		# -----------------------------------------------------
		if TargetDebuffExpires(INSECTSWARM 1.5 mine=1) and TargetDeadIn(more 8)
		{
			Spell(INSECTSWARM)
		}

		if TargetDebuffExpires(MOONFIRE 1.5 mine=1) and TargetDeadIn(more 8)
		{
			Spell(MOONFIRE)
		}

		# Если спало Лунное затмение — спамим Звездный огонь для вызова Солнечного
		# Если спало Солнечное затмение — спамим Гнев для вызова Лунного
		Spell(WRATH)
	}
}

# 2. Off-GCD / Cooldowns Icon
AddIcon size=small help=cd
{
	# Бурсты кота (Тигриное неистовство и Берсерк)
	if Stance(3)
	{
		# Тигриное неистовство жмем строго при малом запасе энергии (<35), чтобы не терять реген
		if Mana(less 35) and Spell(TIGERSFURY) Spell(TIGERSFURY)

		# Берсерк под полный столб энергии
		if CheckBoxOn(burst) and Mana(more 80) and BuffExpires(TIGERSFURY 0) and Spell(BERSERK)
		{
			Spell(BERSERK)
		}
	}

	# Бурсты совы: Деревья (Force of Nature)
	if CheckBoxOn(treants) and Spell(FORCEOFNATURE) Spell(FORCEOFNATURE)
}
]]
