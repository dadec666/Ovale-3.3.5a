Ovale.defaut["ROGUE"] =
[[
# --- Spells & Abilities Definitions ---
Define(SINISTERSTRIKE 48638)
Define(MUTILATE 48666)
Define(SLICEANDDICE 6774)
Define(ENVENOM 57993)
Define(EVISCERATE 48668)
Define(RUPTURE 48672)
Define(HUNGERFORBLOOD 51662)
Define(KILLINGSPREE 51690)
Define(BLADEFLURRY 13877)
Define(ADRENALINERUSH 13750)
Define(TRICKSOFTRETRADE 57934)
Define(STEALTH 1784)
Define(AMBUSH 48691)
Define(CHEAPSHOT 1833)

# Buffs, Debuffs & Procs
Define(ENVENOMBUFF 57993)
Define(STEALTHED 1784)

# Bleed Debuffs on Target (needed for Hunger for Blood)
Define(DEBUFFBLEED 48672) # Rupture / Rake / Lacerate / Deep Wounds

# Talents
Define(TALENTMUTILATE 1865)
Define(TALENTHUNGERFORBLOOD 2072)
Define(TALENTKILLINGSPREE 2070)
Define(TALENTADRENALINERUSH 284)

# Spell details for Ovale simulator
SpellInfo(SLICEANDDICE duration=9)
SpellInfo(RUPTURE duration=8)
SpellInfo(HUNGERFORBLOOD duration=60 cd=0)
SpellInfo(KILLINGSPREE cd=120)
SpellInfo(BLADEFLURRY cd=120)
SpellInfo(ADRENALINERUSH cd=180)
SpellInfo(TRICKSOFTRETRADE cd=30)

SpellAddTargetDebuff(RUPTURE RUPTURE=16)

# --- UI Controls ---
AddListItem(mode raid "Raid / Dungeon" default)
AddListItem(mode level "Leveling / Solo")

AddListItem(finisher eviscerate "Combat: Eviscerate Priority (High ArP / T10)" default)
AddListItem(finisher rupture "Combat: Rupture Priority (Low Gear)")

AddCheckBox(snd "Maintain Slice and Dice" checked)
AddCheckBox(hfb "Maintain Hunger for Blood" checked)
AddCheckBox(burst "Auto Killing Spree / Adrenaline Rush" checked)
AddCheckBox(tricks "Suggest Tricks of the Trade" checked)

# --- Icons Layout ---

# 1. Main Rotation Icon
AddIcon help=main
{
	# Хитрости военного дела (Tricks of the Trade) по откату
	if CheckBoxOn(tricks) and Spell(TRICKSOFTRETRADE) and Mana(more 15)
	{
		Spell(TRICKSOFTRETRADE)
	}

	# =========================================================
	# 1. LEVELING / SOLO (Квесты, гринд, прокачка 1-80)
	# =========================================================
	if List(mode level)
	{
		# Если персонаж в незаметности
		if Stealthed(yes)
		{
			if Spell(AMBUSH) and Mana(more 60) Spell(AMBUSH)
			if Spell(CHEAPSHOT) and Mana(more 40) Spell(CHEAPSHOT)
		}

		# Поддержание Мясорубки хотя бы на 1 комбо-поинте
		if CheckBoxOn(snd) and BuffExpires(SLICEANDDICE 2) and ComboPoints(more 0) and Mana(more 25)
		{
			Spell(SLICEANDDICE)
		}

		# Быстрое добивание Потрошением на 3-5 комбо-поинтах
		if ComboPoints(more 2) and Mana(more 35)
		{
			Spell(EVISCERATE)
		}

		# Генераторы комбо-очков
		if TalentPoints(TALENTMUTILATE more 0) and Mana(more 60) Spell(MUTILATE)
		if Mana(more 45) Spell(SINISTERSTRIKE)
	}

	# =========================================================
	# 2. RAID / DUNGEON
	# =========================================================
	if List(mode raid)
	{
		# -----------------------------------------------------
		# ASSASSINATION SPEC (Мутирога)
		# -----------------------------------------------------
		if TalentPoints(TALENTHUNGERFORBLOOD more 0)
		{
			# Стартовый запуск Мясорубки (в бою далее обновляется сама от Envenom)
			if BuffExpires(SLICEANDDICE 0) and ComboPoints(more 0) and Mana(more 25)
			{
				Spell(SLICEANDDICE)
			}

			# Поддержание Жажды убийства (Hunger for Blood, +8% постоянного урона)
			if CheckBoxOn(hfb) and BuffExpires(HUNGERFORBLOOD 4) and Mana(more 15)
			{
				Spell(HUNGERFORBLOOD)
			}

			# ФИНИШЕР: Отравление (Envenom) на 4-5 комбо-поинтах
			# Пулинг энергии: ждем хотя бы 60-70 энергии перед нажатием, чтобы не простаивать под баффом
			if ComboPoints(more 3) and (Mana(more 65) or BuffExpires(ENVENOMBUFF 0.5))
			{
				Spell(ENVENOM)
			}

			# ГЕНЕРАТОР: Расправа (Mutilate) для набора комбо-поинтов
			if ComboPoints(less 4) and Mana(more 55)
			{
				Spell(MUTILATE)
			}
		}

		# -----------------------------------------------------
		# COMBAT SPEC (Комбатрога)
		# -----------------------------------------------------
		if TalentPoints(TALENTKILLINGSPREE more 0) or TalentPoints(TALENTADRENALINERUSH more 0)
		{
			# ПРИОРИТЕТ 1: 100% аптайм Мясорубки (Slice and Dice)
			if CheckBoxOn(snd) and BuffExpires(SLICEANDDICE 2) and ComboPoints(more 0) and Mana(more 25)
			{
				Spell(SLICEANDDICE)
			}

			# ПРИОРИТЕТ 2: Финишеры на 5 комбо-поинтах
			if ComboPoints(more 4)
			{
				# Рваная рана (если включен режим Rupture и она спадает)
				if List(finisher rupture) and TargetDebuffExpires(RUPTURE 2 mine=1) and TargetDeadIn(more 8) and Mana(more 25)
				{
					Spell(RUPTURE)
				}

				# Потрошение (основной финишер комбата под Т10 / АрП)
				if Mana(more 35)
				{
					Spell(EVISCERATE)
				}
			}

			# ПРИОРИТЕТ 3: Генератор комбо-очков — Коварный удар (Sinister Strike)
			if ComboPoints(less 5) and Mana(more 40)
			{
				Spell(SINISTERSTRIKE)
			}
		}

		# -----------------------------------------------------
		# SUBTLETY / GENERIC FALLBACK
		# -----------------------------------------------------
		if TalentPoints(TALENTHUNGERFORBLOOD 0) and TalentPoints(TALENTKILLINGSPREE 0)
		{
			if BuffExpires(SLICEANDDICE 2) and ComboPoints(more 0) Spell(SLICEANDDICE)
			if ComboPoints(more 4) Spell(EVISCERATE)
			Spell(SINISTERSTRIKE)
		}
	}
}

# 2. Off-GCD / Cooldowns Icon
AddIcon size=small help=cd
{
	# Бурсты Комбата
	if TalentPoints(TALENTKILLINGSPREE more 0)
	{
		# Шквал клинков (Blade Flurry)
		if CheckBoxOn(burst) and Spell(BLADEFLURRY) Spell(BLADEFLURRY)

		# Выброс адреналина (не жмем одновременно с Чередой)
		if CheckBoxOn(burst) and Mana(less 40) and Spell(ADRENALINERUSH)
		{
			Spell(ADRENALINERUSH)
		}

		# Череда убийств (Killing Spree) — строго при энергии < 35, чтобы не терять реген
		if CheckBoxOn(burst) and Mana(less 35) and BuffExpires(ADRENALINERUSH 0) and Spell(KILLINGSPREE)
		{
			Spell(KILLINGSPREE)
		}
	}
}
]]
