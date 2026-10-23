Ovale.defaut["DEATHKNIGHT"] =
[[
# --- Spells & Abilities ---
Define(ICYTOUCH 49909)
Define(PLAGUESTRIKE 49921)
Define(OBLITERATE 51425)
Define(DEATHSTRIKE 49924)
Define(HEARTSTRIKE 55050)
Define(BLOODSTRIKE 49930)
Define(SCOURGESTRIKE 55271)
Define(FROSTSTRIKE 55268)
Define(DEATHCOIL 49895)
Define(HOWLINGBLAST 51411)
Define(PESTILENCE 50842)
Define(BLOODBOIL 49941)
Define(DEATHANDDECAY 49938)
Define(HORNOFWINTER 57623)
Define(EMPOWERWEAPON 47568)
Define(UNBREAKABLEARMOR 51271)
Define(BLOODTAP 45529)
Define(SUMMONGARGOYLE 49206)
Define(ARMYOFTHEDEAD 42650)

# Buffs, Debuffs & Procs
Define(FROSTFEVER 55095)
Define(BLOODPLAGUE 55078)
Define(KILLINGMACHINE 51124)  # 100% crit Frost Strike / Howling Blast
Define(FREEZINGFOG 59052)     # Rime proc (Free Howling Blast)
Define(SUDDENDEOM 49530)      # Free Death Coil (Unholy)

# Talents
Define(TALENTHEARTSTRIKE 1939)
Define(TALENTHOWLINGBLAST 1968)
Define(TALENTSUMMONGARGOYLE 2007)

# Spell details for Ovale simulator
SpellInfo(ICYTOUCH cd=0)
SpellInfo(PLAGUESTRIKE cd=0)
SpellInfo(PESTILENCE cd=0)
SpellInfo(HOWLINGBLAST cd=8)
SpellInfo(UNBREAKABLEARMOR cd=60)
SpellInfo(DEATHANDDECAY cd=30)
SpellInfo(SUMMONGARGOYLE cd=180)
SpellInfo(BLOODTAP cd=60)
SpellInfo(EMPOWERWEAPON cd=300)

SpellAddTargetDebuff(ICYTOUCH FROSTFEVER=15)
SpellAddTargetDebuff(PLAGUESTRIKE BLOODPLAGUE=15)
SpellAddTargetDebuff(PESTILENCE FROSTFEVER=15 BLOODPLAGUE=15)

# --- UI Controls ---
AddListItem(mode raid "Raid / Dungeon" default)
AddListItem(mode level "Leveling / Solo")

AddListItem(aoe single "Single Target" default)
AddListItem(aoe aoe "AOE / Packs")

AddCheckBox(horn "Maintain Horn of Winter" checked)
AddCheckBox(dnd "Death and Decay" checked)
AddCheckBox(gargoyle "Summon Gargoyle" checked)

# --- Icons Layout ---

# 1. Main Action Icon
AddIcon help=main
{
	# Бафф Зимнего горна (если нет шаманского тотема или бафф спал)
	if CheckBoxOn(horn) and BuffExpires(HORNOFWINTER 2) Spell(HORNOFWINTER)

	# =========================================================
	# 1. LEVELING / SOLO (55-80, фарм, квесты)
	# =========================================================
	if List(mode level)
	{
		# Самоисцеление через Удар смерти при просадке ХП
		if LifePercent(less 65) and Runes(frost 1) and Runes(unholy 1)
		{
			Spell(DEATHSTRIKE)
		}

		# Быстрое наложение болезней
		if TargetDebuffExpires(FROSTFEVER 2 mine=1) and Runes(frost 1) Spell(ICYTOUCH)
		if TargetDebuffExpires(BLOODPLAGUE 2 mine=1) and Runes(unholy 1) Spell(PLAGUESTRIKE)

		# Слив рун в базовые мощные удары
		if Runes(frost 1) and Runes(unholy 1)
		{
			if TalentPoints(TALENTHOWLINGBLAST more 0) Spell(OBLITERATE)
			if TalentPoints(TALENTSUMMONGARGOYLE more 0) Spell(SCOURGESTRIKE)
			Spell(DEATHSTRIKE)
		}

		# Слив рун крови
		if Runes(blood 1)
		{
			if TalentPoints(TALENTHEARTSTRIKE more 0) Spell(HEARTSTRIKE)
			Spell(BLOODSTRIKE)
		}

		# Слив силы рун (Runic Power)
		if Mana(more 40)
		{
			if TalentPoints(TALENTHOWLINGBLAST more 0) Spell(FROSTSTRIKE)
			Spell(DEATHCOIL)
		}

		# Обновление Горна при простое
		Spell(HORNOFWINTER)
	}

	# =========================================================
	# 2. RAID / DUNGEON
	# =========================================================
	if List(mode raid)
	{
		# -----------------------------------------------------
		# UNHOLY SPEC
		# -----------------------------------------------------
		if TalentPoints(TALENTSUMMONGARGOYLE more 0)
		{
			# Первичное наложение болезней
			if TargetDebuffExpires(FROSTFEVER 0 mine=1) and Runes(frost 1) Spell(ICYTOUCH)
			if TargetDebuffExpires(BLOODPLAGUE 0 mine=1) and Runes(unholy 1) Spell(PLAGUESTRIKE)

			# Обновление болезней через Мор перед спадением
			if (TargetDebuffExpires(FROSTFEVER 2.5 mine=1) or TargetDebuffExpires(BLOODPLAGUE 2.5 mine=1)) and Runes(blood 1)
			{
				Spell(PESTILENCE)
			}

			# Призыв горгульи
			if CheckBoxOn(gargoyle) and Spell(SUMMONGARGOYLE) and Mana(more 60)
			{
				Spell(SUMMONGARGOYLE)
			}

			# Смерть и разложение по КД под босса
			if CheckBoxOn(dnd) and Runes(unholy 1) and Runes(frost 1) and Runes(blood 1) and Spell(DEATHANDDECAY)
			{
				Spell(DEATHANDDECAY)
			}

			# АОЕ режим
			if List(aoe aoe)
			{
				if Runes(blood 1) Spell(BLOODBOIL)
			}

			# Удар Плети (Scourge Strike) при наличии Unholy/Frost/Death рун
			if Runes(unholy 1) and Runes(frost 1)
			{
				Spell(SCOURGESTRIKE)
			}

			# Слив рун крови в Кровавый удар для генерации рун смерти
			if Runes(blood 1)
			{
				Spell(BLOODSTRIKE)
			}

			# Лик смерти по проку Sudden Doom или кап РП
			if BuffPresent(SUDDENDEOM) or Mana(more 80)
			{
				Spell(DEATHCOIL)
			}

			# Базовый сброс РП
			if Mana(more 40) Spell(DEATHCOIL)
		}

		# -----------------------------------------------------
		# FROST SPEC
		# -----------------------------------------------------
		if TalentPoints(TALENTHOWLINGBLAST more 0)
		{
			# Наложение болезней
			if TargetDebuffExpires(FROSTFEVER 0 mine=1) and Runes(frost 1) Spell(ICYTOUCH)
			if TargetDebuffExpires(BLOODPLAGUE 0 mine=1) and Runes(unholy 1) Spell(PLAGUESTRIKE)

			# Бесплатный Воющий ветер под прок Инея (Rime)
			if BuffPresent(FREEZINGFOG)
			{
				Spell(HOWLINGBLAST)
			}

			# Ледяной удар под прок Машины для убийств (100% крит)
			if BuffPresent(KILLINGMACHINE) and Mana(more 32)
			{
				Spell(FROSTSTRIKE)
			}

			# Уничтожение (Obliterate) - основной урон ветки
			if Runes(frost 1) and Runes(unholy 1)
			{
				Spell(OBLITERATE)
			}

			# Обновление болезней через Мор или сброс рун крови Кровавым ударом
			if (TargetDebuffExpires(FROSTFEVER 2 mine=1) or TargetDebuffExpires(BLOODPLAGUE 2 mine=1)) and Runes(blood 1)
			{
				Spell(PESTILENCE)
			}

			if Runes(blood 1)
			{
				Spell(BLOODSTRIKE)
			}

			# Слив силы рун в Ледяной удар
			if Mana(more 40)
			{
				Spell(FROSTSTRIKE)
			}
		}

		# -----------------------------------------------------
		# BLOOD SPEC
		# -----------------------------------------------------
		if TalentPoints(TALENTHEARTSTRIKE more 0)
		{
			if TargetDebuffExpires(FROSTFEVER 0 mine=1) and Runes(frost 1) Spell(ICYTOUCH)
			if TargetDebuffExpires(BLOODPLAGUE 0 mine=1) and Runes(unholy 1) Spell(PLAGUESTRIKE)

			# Обновление болезней через Мор
			if (TargetDebuffExpires(FROSTFEVER 2 mine=1) or TargetDebuffExpires(BLOODPLAGUE 2 mine=1)) and Runes(blood 1)
			{
				Spell(PESTILENCE)
			}

			# Удар смерти (Death Strike) для конвертации рун в руны смерти
			if Runes(frost 1) and Runes(unholy 1)
			{
				Spell(DEATHSTRIKE)
			}

			# Удар сердца (Heart Strike)
			if Runes(blood 1)
			{
				Spell(HEARTSTRIKE)
			}

			# Слив РП в Лик смерти
			if Mana(more 40)
			{
				Spell(DEATHCOIL)
			}
		}
	}
}

# 2. Off-GCD / Cooldowns
AddIcon size=small help=cd
{
	# Кровоотвод при нехватке руны Крови
	if Runes(blood 0) and Spell(BLOODTAP) Spell(BLOODTAP)

	# Несокрушимая броня во фросте под прок руны
	if TalentPoints(TALENTHOWLINGBLAST more 0) and Spell(UNBREAKABLEARMOR) and Runes(frost 1)
	{
		Spell(UNBREAKABLEARMOR)
	}

	# Усиление рунического оружия при полном исчерпании всех рун
	if Runes(blood 0) and Runes(frost 0) and Runes(unholy 0) and Spell(EMPOWERWEAPON)
	{
		Spell(EMPOWERWEAPON)
	}
}
]]
