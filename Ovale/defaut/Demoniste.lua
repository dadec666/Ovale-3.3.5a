Ovale.defaut["WARLOCK"] =
[[
# --- Spells & Buffs Definitions ---
Define(SHADOWBOLT 47809)
Define(INCINERATE 47838)
Define(SOULFIRE 47825)
Define(IMMOLATE 47811)
Define(CORRUPTION 47813)
Define(CURSEOFDOOM 47867)
Define(CURSEOFAGONY 47864)
Define(CURSEOFELEMENTS 47865)
Define(CHAOSBOLT 59172)
Define(CONFLAGRATE 17962)
Define(HAUNT 59164)
Define(UNSTABLEAFFLICTION 47843)
Define(DRAINSOUL 47855)
Define(DRAINLIFE 47857)
Define(LIFETAP 57946)
Define(SHADOWBURN 47827)
Define(METAMORPHOSIS 47241)
Define(IMMOLATIONAURA 50589)
Define(SHADOWFLAME 61290)
Define(DEMONICEMPOWERMENT 47193)

# Buffs & Procs
Define(MOLTENCORE 71165)       # Molten Core (3 charges)
Define(DECIMATION 63167)       # Decimation (<35% execute)
Define(GLYPHOFLIFETAP 63321)   # Glyph of Life Tap buff
Define(SHADOWTRANCE 17941)     # Nightfall / Shadow Trance instant Shadow Bolt

# Talents
Define(TALENTDEMONICEMPOWERMENT 1880)
Define(TALENTMETAMORPHOSIS 1887)
Define(TALENTHAUNT 1960)
Define(TALENTCHAOSBOLT 1888)

# Spell details for Ovale simulator
SpellInfo(IMMOLATE duration=15)
SpellInfo(CORRUPTION duration=18)
SpellInfo(CURSEOFDOOM duration=60)
SpellInfo(CURSEOFAGONY duration=24)
SpellInfo(HAUNT duration=12)
SpellInfo(UNSTABLEAFFLICTION duration=15)
SpellInfo(SHADOWFLAME duration=6 cd=12)
SpellInfo(CONFLAGRATE cd=10)
SpellInfo(CHAOSBOLT cd=12)
SpellInfo(SHADOWBURN cd=15)
SpellInfo(METAMORPHOSIS cd=180)
SpellInfo(DEMONICEMPOWERMENT cd=60)
SpellInfo(IMMOLATIONAURA cd=30)

SpellAddTargetDebuff(IMMOLATE IMMOLATE=15)
SpellAddTargetDebuff(CORRUPTION CORRUPTION=18)
SpellAddTargetDebuff(CURSEOFDOOM CURSEOFDOOM=60)
SpellAddTargetDebuff(CURSEOFAGONY CURSEOFAGONY=24)
SpellAddTargetDebuff(HAUNT HAUNT=12)
SpellAddTargetDebuff(UNSTABLEAFFLICTION UNSTABLEAFFLICTION=15)

# --- UI Controls ---
AddListItem(mode raid "Raid / Dungeon" default)
AddListItem(mode level "Leveling / Solo")

AddListItem(curse doom "Curse of Doom" default)
AddListItem(curse agony "Curse of Agony")
AddListItem(curse elements "Curse of the Elements")

AddListItem(position ranged "Ranged Position" default)
AddListItem(position melee "Melee / Close Range")

AddCheckBox(meta "Auto Metamorphosis" checked)
AddCheckBox(petemp "Demonic Empowerment" checked)
AddCheckBox(lifetap "Maintain Life Tap Buff" checked)
AddCheckBox(drain "Execute Drain Soul" checked)

# --- Icons Layout ---

# 1. Main Rotation (Соло-цель)
AddIcon help=main
{
	# =========================================================
	# ВЕТКА: LEVELLING / SOLO (Прокачка, квесты, фарм)
	# =========================================================
	if List(mode level)
	{
		# Добивание моба Похищением души ради осколков и маны от таланта Improved Drain Soul
		if CheckBoxOn(drain) and TargetLifePercent(less 25)
		{
			Spell(DRAINSOUL)
		}

		# Быстрое добивание Ожогом Тьмы, если способность изучена
		if TargetLifePercent(less 20) and Spell(SHADOWBURN)
		{
			Spell(SHADOWBURN)
		}

		# Безопасный жизнеотвод вне критического здоровья
		if ManaPercent(less 40) and LifePercent(more 50)
		{
			Spell(LIFETAP)
		}

		# Экзекут Ожогом души под прок Истребления
		if BuffPresent(DECIMATION)
		{
			Spell(SOULFIRE)
		}

		# Мгновенная Стрела Тьмы по проку Сумерек (Nightfall)
		if BuffPresent(SHADOWTRANCE)
		{
			Spell(SHADOWBOLT)
		}

		# Слив прока Огненных недр в Испепеление
		if BuffPresent(MOLTENCORE)
		{
			Spell(INCINERATE)
		}

		# Базовые DoT (только если моб живет дольше 6 секунд)
		if TargetDeadIn(more 6)
		{
			if TargetDebuffExpires(CORRUPTION 2 mine=1) Spell(CORRUPTION)
			if TargetDebuffExpires(CURSEOFAGONY 3 mine=1) Spell(CURSEOFAGONY)
			if TargetDeadIn(more 10) and TargetDebuffExpires(IMMOLATE 2 mine=1) Spell(IMMOLATE)
		}

		# Основной филлер при каче
		Spell(SHADOWBOLT)
	}

	# =========================================================
	# ВЕТКА: RAID / DUNGEON (Эндгейм боссы и рейды)
	# =========================================================
	if List(mode raid)
	{
		# Бафф символа жизнеотвода (СПД)
		if CheckBoxOn(lifetap) and BuffExpires(GLYPHOFLIFETAP 2) Spell(LIFETAP)

		# ------------------------------
		# 1. DEMONOLOGY
		# ------------------------------
		if TalentPoints(TALENTMETAMORPHOSIS more 0)
		{
			if CheckBoxOn(meta) and Spell(METAMORPHOSIS) Spell(METAMORPHOSIS)

			if List(position melee)
			{
				if BuffPresent(METAMORPHOSIS) and Spell(IMMOLATIONAURA) Spell(IMMOLATIONAURA)
				if Spell(SHADOWFLAME) Spell(SHADOWFLAME)
			}

			if TargetDebuffExpires(IMMOLATE 2.0 mine=1) Spell(IMMOLATE)
			if TargetDebuffExpires(CORRUPTION 2.0 mine=1) Spell(CORRUPTION)

			if List(curse elements) and TargetDebuffExpires(CURSEOFELEMENTS 3) Spell(CURSEOFELEMENTS)
			if List(curse doom) and TargetDebuffExpires(CURSEOFDOOM 0 mine=1) and TargetDeadIn(more 60) Spell(CURSEOFDOOM)
			if List(curse agony) and TargetDebuffExpires(CURSEOFAGONY 2 mine=1) and TargetDebuffExpires(CURSEOFDOOM 0 mine=1) Spell(CURSEOFAGONY)
			if List(curse doom) and TargetDebuffExpires(CURSEOFDOOM 0 mine=1) and TargetDeadIn(less 60) and TargetDebuffExpires(CURSEOFAGONY 2 mine=1) Spell(CURSEOFAGONY)

			# Фаза казни (<35% HP или активный прок)
			if BuffPresent(DECIMATION) or TargetLifePercent(less 35)
			{
				Spell(SOULFIRE)
			}

			if BuffPresent(MOLTENCORE)
			{
				Spell(INCINERATE)
			}

			Spell(SHADOWBOLT)
		}

		# ------------------------------
		# 2. AFFLICTION
		# ------------------------------
		if TalentPoints(TALENTHAUNT more 0)
		{
			if TargetLifePercent(less 25)
			{
				if TargetDebuffExpires(SHADOWBOLT 3) and TargetDebuffExpires(HAUNT 3) Spell(HAUNT)
				if TargetDebuffExpires(CORRUPTION 2 mine=1) Spell(CORRUPTION)
				if TargetDebuffExpires(UNSTABLEAFFLICTION 2 mine=1) Spell(UNSTABLEAFFLICTION)
				Spell(DRAINSOUL)
			}

			if BuffPresent(SHADOWTRANCE) Spell(SHADOWBOLT)
			if TargetDebuffExpires(HAUNT 2.5 mine=1) Spell(HAUNT)
			if TargetDebuffExpires(UNSTABLEAFFLICTION 2.0 mine=1) Spell(UNSTABLEAFFLICTION)
			if TargetDebuffExpires(CORRUPTION 2.0 mine=1) Spell(CORRUPTION)

			if List(curse elements) and TargetDebuffExpires(CURSEOFELEMENTS 3) Spell(CURSEOFELEMENTS)
			if List(curse agony) and TargetDebuffExpires(CURSEOFAGONY 2 mine=1) Spell(CURSEOFAGONY)
			if List(curse doom) and TargetDebuffExpires(CURSEOFDOOM 0 mine=1) and TargetDeadIn(more 60) Spell(CURSEOFDOOM)

			Spell(SHADOWBOLT)
		}

		# ------------------------------
		# 3. DESTRUCTION
		# ------------------------------
		if TalentPoints(TALENTCHAOSBOLT more 0)
		{
			if TargetDebuffExpires(IMMOLATE 2.0 mine=1) Spell(IMMOLATE)
			if TargetDebuffPresent(IMMOLATE mine=1) and Spell(CONFLAGRATE) Spell(CONFLAGRATE)
			if Spell(CHAOSBOLT) Spell(CHAOSBOLT)

			if List(curse elements) and TargetDebuffExpires(CURSEOFELEMENTS 3) Spell(CURSEOFELEMENTS)
			if List(curse doom) and TargetDebuffExpires(CURSEOFDOOM 0 mine=1) and TargetDeadIn(more 60) Spell(CURSEOFDOOM)
			if List(curse agony) and TargetDebuffExpires(CURSEOFAGONY 2 mine=1) and TargetDebuffExpires(CURSEOFDOOM 0 mine=1) Spell(CURSEOFAGONY)

			if TargetDebuffExpires(CORRUPTION 2 mine=1) Spell(CORRUPTION)

			Spell(INCINERATE)
		}

		# Универсальный fallback для рейдов, если спек гибридный без ключевых талантов
		if TargetDebuffExpires(CORRUPTION 2 mine=1) Spell(CORRUPTION)
		if TargetDebuffExpires(IMMOLATE 2 mine=1) Spell(IMMOLATE)
		Spell(SHADOWBOLT)
	}
}

# 2. Off-GCD / Cooldowns
AddIcon size=small help=cd
{
	if CheckBoxOn(petemp) and Spell(DEMONICEMPOWERMENT) and PetPresent(yes) Spell(DEMONICEMPOWERMENT)
	if ManaPercent(less 20) and LifePercent(more 30) Spell(LIFETAP)
}
]]
