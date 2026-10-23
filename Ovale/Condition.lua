local LBCT = LibStub("LibBabble-CreatureType-3.0"):GetLookupTable()
local UnitBuff = UnitBuff
local UnitDebuff = UnitDebuff
local UnitClass = UnitClass
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitLevel = UnitLevel
local UnitGUID = UnitGUID
local GetTime = GetTime
local math_ceil = math.ceil
local math_floor = math.floor

local runeType = { blood = 1, unholy = 2, frost = 3, death = 4 }
local totemType = { fire = 1, earth = 2, water = 3, air = 4 }

local fearSpellIdList = { 5782, 5484, 5246, 8122 }
local fearSpellList = nil

local stunSpellIdList = { 5211, 44415, 6409, 22427, 853, 408, 12798, 46968 }
local stunSpellList = nil

local incapacitateSpellIdList = { 6770, 12540, 20066 }
local incapacitateSpellList = nil

local rootSpellIdList = { 23694, 339, 122, 47168 }
local rootSpellList = nil

local function buildRootSpellList()
	if (rootSpellList) then return end
	rootSpellList = {}
	for k, v in pairs(rootSpellIdList) do
		local name = Ovale:GetSpellInfoOrNil(v)
		if name then rootSpellList[name] = true end
	end
end

local function buildStunSpellList()
	if (stunSpellList) then return end
	stunSpellList = {}
	for k, v in pairs(stunSpellIdList) do
		local name = Ovale:GetSpellInfoOrNil(v)
		if name then stunSpellList[name] = true end
	end
end

local function buildIncapacitateSpellList()
	if (incapacitateSpellList) then return end
	incapacitateSpellList = {}
	for k, v in pairs(incapacitateSpellIdList) do
		local name = Ovale:GetSpellInfoOrNil(v)
		if name then incapacitateSpellList[name] = true end
	end
end

local function buildFearSpellList()
	if (fearSpellList) then return end
	fearSpellList = {}
	for k, v in pairs(fearSpellIdList) do
		local name = Ovale:GetSpellInfoOrNil(v)
		if name then fearSpellList[name] = true end
	end
end

local function isDebuffInList(list)
	local i = 1
	while (true) do
		local name = UnitDebuff("player", i)
		if (not name) then break end
		if (list[name]) then return true end
		i = i + 1
	end
	return false
end

local function avecHate(temps, hate)
	if not temps then temps = 0 end
	if (not hate) then
		return temps
	elseif (hate == "spell") then
		return temps / (1 + Ovale.spellHaste / 100)
	elseif (hate == "melee") then
		return temps / (1 + Ovale.meleeHaste / 100)
	else
		return temps
	end
end

local function compare(a, comparison, b)
	if (comparison == "more") then
		if (not b or (a ~= nil and a > b)) then
			return 0
		else
			return nil
		end
	else
		if (not a or (b ~= nil and a < b)) then
			return 0
		else
			return nil
		end
	end
end

local function testbool(a, condition)
	if (condition == "yes" or not condition) then
		if (a) then return 0 else return nil end
	else
		if (not a) then return 0 else return nil end
	end
end

local function getTarget(condition)
	if (not condition) then
		return "target"
	else
		return condition
	end
end

local function addTime(time1, duration)
	if not time1 then return nil else return time1 + duration end
end

local lastEnergyValue = nil
local lastEnergyTime

local function GetManaTime(mana, withBerserker)
	local _, className = UnitClass("player")
	if (className == "ROGUE" or (className == "DRUID" and GetShapeshiftForm(true) == 3)) then
		local current = Ovale.state.mana
		if current ~= lastEnergyValue then
			lastEnergyValue = current
			lastEnergyTime = Ovale.currentTime
		end
		local rate = 10
		if (className == "ROGUE") then
			local rush = Ovale:GetSpellInfoOrNil(13750)
			if rush and UnitBuff("player", rush) then
				rate = rate * 2
			end
		elseif withBerserker then
			local berserk = Ovale:GetSpellInfoOrNil(50334)
			if berserk and UnitBuff("player", berserk) then
				mana = mana / 2
			end
		end
		local limit = math_ceil((mana - lastEnergyValue) / rate + lastEnergyTime)
		return limit
	else
		if Ovale.state.mana >= mana then
			return Ovale.currentTime - 1
		else
			return nil
		end
	end
end

local function GetTargetAura(condition, filter, target)
	if (not target) then target = condition.target end
	if (not target) then target = "target" end

	local stacks = condition.stacks or 1
	local spellId = condition[1]
	local aura = Ovale:GetAura(target, filter, spellId)

	if (not condition.mine or aura.mine) and aura.stacks >= stacks then
		local ending
		if condition.forceduration then
			local sname = Ovale:GetSpellInfoOrNil(spellId)
			if sname and Ovale.spellInfo[sname] and Ovale.spellInfo[sname].duration then
				ending = aura.start + Ovale.spellInfo[sname].duration
			else
				ending = aura.start + condition.forceduration
			end
		else
			ending = aura.ending
		end
		return aura.start, ending
	else
		return 0, 0
	end
end

local lastSaved
local savedHealth
local targetGUID
local lastSPD = 0.0001

local function getTargetDead()
	local second = math_floor(Ovale.maintenant)
	if targetGUID ~= UnitGUID("target") then
		lastSaved = nil
		targetGUID = UnitGUID("target")
		savedHealth = {}
	end
	local newHealth = UnitHealth("target")
	if UnitHealthMax("target") == 1 then
		return Ovale.maintenant + 10000
	end
	if second ~= lastSaved and targetGUID then
		lastSaved = second
		local mod10 = second % 10
		local prevHealth = savedHealth[mod10]
		savedHealth[mod10] = newHealth
		if prevHealth and prevHealth > newHealth then
			lastSPD = 10 / (prevHealth - newHealth)
		end
	end
	return Ovale.maintenant + newHealth * lastSPD
end

Ovale.conditions = {
	ArmorSetParts = function(condition)
		local nombre = 0
		if (OvaleEquipement and OvaleEquipement.nombre and OvaleEquipement.nombre[condition[1]]) then
			nombre = OvaleEquipement.nombre[condition[1]]
		end
		return compare(nombre, condition[2], condition[3])
	end,
	BuffDuration = function(condition)
		local spell = Ovale:GetSpellInfoOrNil(condition[1])
		if not spell then return nil end
		local name, rank, icon, count, debuffType, duration = UnitBuff("player", spell)
		if not name then return nil end
		return compare(duration, condition[2], condition[3])
	end,
	BuffExpires = function(condition)
		local start, ending = GetTargetAura(condition, "HELPFUL", "player")
		local timeBefore = avecHate(condition[2], condition.haste)
		return addTime(ending, -timeBefore)
	end,
	BuffGain = function(condition)
		local spell, rank, icon = Ovale:GetSpellInfoOrNil(condition[1])
		if (spell) then
			if (not Ovale.buff[spell]) then
				return 0
			end
			local timeGain = Ovale.buff[spell].gain
			if (not timeGain or Ovale.buff[spell].icon ~= icon) then
				timeGain = 0
			end
			return timeGain + (condition[2] or 0)
		end
		return 0
	end,
	BuffPresent = function(condition)
		local start, ending = GetTargetAura(condition, "HELPFUL", "player")
		local timeBefore = avecHate(condition[2], condition.haste)
		return start, addTime(ending, -timeBefore)
	end,
	Casting = function(condition)
		local spell, rank, name, icon, start, ending = UnitCastingInfo("player")
		if (not spell) then return nil end
		if Ovale:GetSpellInfoOrNil(condition[1]) == spell then
			return start/1000, ending/1000
		else
			return nil
		end
	end,
	CastTime = function(condition)
		local name, rank, icon, cost, isFunnel, powerType, castTime = Ovale:GetSpellInfoOrNil(condition[1])
		if not castTime then return nil end
		return compare(castTime/1000, condition[2], condition[3])
	end,
	CheckBoxOff = function(condition)
		for k, v in pairs(condition) do
			if (Ovale:IsChecked(v)) then return nil end
		end
		return 0
	end,
	CheckBoxOn = function(condition)
		for k, v in pairs(condition) do
			if (not Ovale:IsChecked(v)) then return nil end
		end
		return 0
	end,
	ComboPoints = function(condition)
		local points = Ovale.state.combo
		return compare(points, condition[1], condition[2])
	end,
	Counter = function(condition)
		return compare(Ovale.counter[condition[1]], condition[2], condition[3])
	end,
	DebuffExpires = function(condition)
		local start, ending = GetTargetAura(condition, "HARMFUL", "player")
		local tempsMax = avecHate(condition[2], condition.haste)
		return addTime(ending, -tempsMax)
	end,
	DebuffPresent = function(condition)
		local start, ending = GetTargetAura(condition, "HARMFUL", "player")
		local timeBefore = avecHate(condition[2], condition.haste)
		return start, addTime(ending, -timeBefore)
	end,
	EffectiveMana = function(condition)
		local limit = GetManaTime(condition[2], true)
		if condition[1] == "more" then
			return limit, nil
		else
			return 0, limit
		end
	end,
	EndCastTime = function(condition)
		local name, rank, icon, cost, isFunnel, powerType, castTime = Ovale:GetSpellInfoOrNil(condition[1])
		if not name then return nil end
		local actionCooldownStart, actionCooldownDuration = Ovale:GetComputedSpellCD(name)
		local startCast = actionCooldownStart + actionCooldownDuration
		if startCast < Ovale.currentTime then
			startCast = Ovale.currentTime
		end
		return startCast + (castTime or 0)/1000
	end,
	Glyph = function(condition)
		local present = false
		for i = 1, GetNumGlyphSockets() do
			local enabled, glyphType, glyphSpellID = GetGlyphSocketInfo(i)
			if (glyphSpellID == condition[1]) then
				present = true
				break
			end
		end
		return testbool(present, condition[2])
	end,
	HasFullControl = function(condition)
		return testbool(HasFullControl(), condition[1])
	end,
	HasShield = function(condition)
		local _, _, id = string.find(GetInventoryItemLink("player", GetInventorySlotInfo("SecondaryHandSlot")) or "", "(item:%d+:%d+:%d+:%d+)")
		if (not id) then return testbool(false, condition[1]) end
		local _, _, _, _, _, _, _, _, itemLoc = GetItemInfo(id)
		return testbool(itemLoc == "INVTYPE_SHIELD", condition[1])
	end,
	InCombat = function(condition)
		return testbool(Ovale.enCombat, condition[1])
	end,
	ItemCount = function(condition)
		return compare(GetItemCount(condition[1]), condition[2], condition[3])
	end,
	IsFeared = function(condition)
		buildFearSpellList()
		return testbool(not HasFullControl() and isDebuffInList(fearSpellList), condition[1])
	end,
	IsIncapacitated = function(condition)
		buildIncapacitateSpellList()
		return testbool(not HasFullControl() and isDebuffInList(incapacitateSpellList), condition[1])
	end,
	IsRooted = function(condition)
		buildRootSpellList()
		return testbool(isDebuffInList(rootSpellList), condition[1])
	end,
	IsStunned = function(condition)
		buildStunSpellList()
		return testbool(not HasFullControl() and isDebuffInList(stunSpellList), condition[1])
	end,
	Level = function(condition)
		return compare(UnitLevel("player"), condition[1], condition[2])
	end,
	LifePercent = function(condition)
		return compare(UnitHealth("player") / UnitHealthMax("player"), condition[1], condition[2] / 100)
	end,
	List = function(condition)
		if (condition[1]) then
			if (Ovale:GetListValue(condition[1]) == condition[2]) then
				return 0
			end
		end
		return nil
	end,
	Mana = function(condition)
		local limit = GetManaTime(condition[2], false)
		if condition[1] == "more" then
			return limit, nil
		else
			return 0, limit
		end
	end,
	ManaPercent = function(condition)
		return compare(UnitPower("player") / UnitPowerMax("player"), condition[1], condition[2] / 100)
	end,
	OtherDebuffExpires = function(condition)
		Ovale:EnableOtherDebuffs()
		local otherDebuff = Ovale.otherDebuffs[GetSpellInfo(condition[1])]
		if otherDebuff then
			local timeBefore = condition[2] or 0
			local maxTime = condition[3] or 10
			local minTime
			for k, v in pairs(otherDebuff) do
				local diff = v
				if Ovale.maintenant - maxTime > diff then
					otherDebuff[k] = nil
				elseif k ~= UnitGUID("target") and (not minTime or diff < minTime) then
					minTime = diff
				end
			end
			if not minTime then return nil end
			minTime = minTime - timeBefore
			return minTime
		end
		return nil
	end,
	OtherDebuffPresent = function(condition)
		Ovale:EnableOtherDebuffs()
		local otherDebuff = Ovale.otherDebuffs[GetSpellInfo(condition[1])]
		if otherDebuff then
			local maxTime = 0
			local suppTime = condition[3] or 10
			for target, expireTime in pairs(otherDebuff) do
				if target ~= UnitGUID("target") then
					if Ovale.maintenant - suppTime > expireTime then
						otherDebuff[target] = nil
					elseif expireTime > maxTime then
						maxTime = expireTime
					end
				end
			end
			if maxTime > 0 then
				local timeBefore = condition[2] or 0
				return 0, addTime(maxTime, -timeBefore)
			else
				return nil
			end
		end
		return nil
	end,
	PetPresent = function(condition)
		local present = UnitExists("pet") and not UnitIsDead("pet")
		return testbool(present, condition[1])
	end,
	Runes = function(condition)
		local rType = runeType[condition[1]]
		local nombre = 0
		local nombreCD = 0
		local maxCD = nil
		local minCD = nil
		for i = 1, 6 do
			local rune = Ovale.state.rune[i]
			if rune.type == rType or (rune.type == 4 and not condition.nodeath) then
				if (rune.cd == 0) then
					nombre = nombre + 1
				else
					nombreCD = nombreCD + 1
					if (maxCD == nil or rune.cd > maxCD) then maxCD = rune.cd end
					if (minCD == nil or rune.cd < minCD) then minCD = rune.cd end
				end
			end
		end
		local wanted = condition[2]
		if (nombre >= wanted) then
			return 0
		elseif (nombre + nombreCD < wanted) then
			return nil
		elseif (wanted == nombre + 1) then
			return minCD
		else
			return maxCD
		end
	end,
	Speed = function(condition)
		return compare(GetUnitSpeed("player") * 100 / 7, condition[1], condition[2])
	end,
	Stance = function(condition)
		if (GetShapeshiftForm(true) == condition[1]) then
			return 0
		else
			return nil
		end
	end,
	Stealthed = function(condition)
		return testbool(IsStealthed(), condition[1])
	end,
	TalentPoints = function(condition)
		if (not Ovale.listeTalentsRemplie) then
			Ovale:RemplirListeTalents()
			return nil
		end
		return compare(Ovale.pointsTalent[condition[1]], condition[2], condition[3])
	end,
	TargetDispellableBuffPresent = function(condition)
		return nil
	end,
	TargetBuffPresent = function(condition)
		local start, ending = GetTargetAura(condition, "HELPFUL")
		local tempsMin = avecHate(condition[2], condition.haste)
		return start, addTime(ending, -tempsMin)
	end,
	TargetClass = function(condition)
		local loc, noloc = UnitClass("target")
		return testbool(noloc == condition[1], condition[2])
	end,
	TargetClassification = function(condition)
		local classification = UnitClassification("target")
		if (classification == "rareelite") then
			classification = "elite"
		elseif (classification == "rare") then
			classification = "normal"
		end
		if (condition[1] == classification) then
			return 0
		else
			return nil
		end
	end,
	TargetCreatureType = function(condition)
		for _, v in pairs(condition) do
			if (UnitCreatureType("target") == LBCT[v]) then
				return 0
			end
		end
		return nil
	end,
	TargetDeadIn = function(condition)
		local deadAt = getTargetDead()
		if condition[1] == "more" then
			return 0, addTime(deadAt, -condition[2])
		else
			return addTime(deadAt, -condition[2]), nil
		end
	end,
	TargetDebuffExpires = function(condition)
		local start, ending = GetTargetAura(condition, "HARMFUL")
		local tempsMax = avecHate(condition[2], condition.haste)
		return addTime(ending, -tempsMax)
	end,
	TargetDebuffPresent = function(condition)
		local start, ending = GetTargetAura(condition, "HARMFUL")
		local tempsMin = avecHate(condition[2], condition.haste)
		return start, addTime(ending, -tempsMin)
	end,
	TargetInRange = function(condition)
		return testbool(IsSpellInRange(Ovale:GetSpellInfoOrNil(condition[1]), getTarget(condition.target)) == 1, condition[2])
	end,
	TargetIsCasting = function(condition)
		return testbool(UnitCastingInfo(getTarget(condition.target)), condition[1])
	end,
	TargetLife = function(condition)
		local target = getTarget(condition.target)
		return compare(UnitHealth(target), condition[1], condition[2])
	end,
	TargetLifePercent = function(condition)
		local target = getTarget(condition.target)
		return compare(UnitHealth(target) / UnitHealthMax(target), condition[1], condition[2] / 100)
	end,
	TargetMana = function(condition)
		local target = getTarget(condition.target)
		return compare(UnitPower(target), condition[1], condition[2])
	end,
	TargetRelativeLevel = function(condition)
		local difference
		if (UnitLevel("target") == -1) then
			difference = 3
		else
			difference = UnitLevel("target") - UnitLevel("player")
		end
		return compare(difference, condition[1], condition[2])
	end,
	TargetTargetIsPlayer = function(condition)
		return testbool(UnitIsUnit("player", "targettarget"), condition[1])
	end,
	Threat = function(condition)
		local isTanking, status, threatpct = UnitDetailedThreatSituation("player", getTarget(condition.target))
		return compare(threatpct, condition[1], condition[2])
	end,
	TimeInCombat = function(condition)
		if condition[1] == "more" then
			return Ovale.combatStartTime + condition[2]
		else
			return 0, Ovale.combatStartTime + condition[2]
		end
	end,
	TotemExpires = function(condition)
		local haveTotem, totemName, startTime, duration = GetTotemInfo(totemType[condition[1]])
		if not startTime then return 0 end
		if (condition.totem and Ovale:GetSpellInfoOrNil(condition.totem) ~= totemName) then
			return 0
		end
		return addTime(startTime + duration, -(condition[2] or 0))
	end,
	Tracking = function(condition)
		local what = Ovale:GetSpellInfoOrNil(condition[1])
		local numTrackingTypes = GetNumTrackingTypes()
		local present = false
		for i = 1, numTrackingTypes do
			local name, texture, active = GetTrackingInfo(i)
			if name == what then
				present = (active == 1)
				break
			end
		end
		return testbool(present, condition[2])
	end,
	WeaponEnchantExpires = function(condition)
		local hasMainHandEnchant, mainHandExpiration, mainHandCharges, hasOffHandEnchant, offHandExpiration = GetWeaponEnchantInfo()
		if (condition[1] == "mainhand") then
			if (not hasMainHandEnchant) then return 0 end
			mainHandExpiration = mainHandExpiration / 1000
			if ((condition[2] or 0) >= mainHandExpiration) then
				return 0
			else
				return Ovale.maintenant + mainHandExpiration - condition[2]
			end
		else
			if (not hasOffHandEnchant) then return 0 end
			offHandExpiration = offHandExpiration / 1000
			if ((condition[2] or 0) >= offHandExpiration) then
				return 0
			else
				return Ovale.maintenant + offHandExpiration - condition[2]
			end
		end
	end
}