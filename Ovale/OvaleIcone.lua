local Masque = LibStub("Masque", true) or LibStub("LibButtonFacade", true)
local L = LibStub("AceLocale-3.0"):GetLocale("Ovale")

local PlaySoundFile = PlaySoundFile
local GameTooltip = GameTooltip
local string_format = string.format
local next = next

local RANGE_INDICATOR = "●"

local function HasExternalCooldownCounter()
	return _G["OmniCC"] ~= nil or _G["tullaCC"] ~= nil
end

local function Update(self, element, minAttente, actionTexture, actionInRange, actionCooldownStart, actionCooldownDuration, actionUsable, actionShortcut, actionIsCurrent, actionEnable, spellName, actionTarget)
	self.spellName = spellName

	if (minAttente ~= nil and actionTexture) then
		if (actionTexture ~= self.actionCourante or self.ancienneAttente == nil or (minAttente ~= Ovale.maintenant and minAttente > self.ancienneAttente + 0.01) or (minAttente < self.finAction - 0.01)) then
			if (actionTexture ~= self.actionCourante or self.ancienneAttente == nil or (minAttente ~= Ovale.maintenant and minAttente > self.ancienneAttente + 0.01)) then
				self.debutAction = Ovale.maintenant
				self.actionCourante = actionTexture
				self.finAction = minAttente
			end

			if (minAttente == Ovale.maintenant) then
				self.cd:Hide()
			else
				self.lastSound = nil
				self.cd:Show()
				self.cd:SetCooldown(self.debutAction, self.finAction - self.debutAction)
			end
			self.ancienneAttente = minAttente

			self.icone:Show()
			self.icone:SetTexture(actionTexture)

			if (actionUsable) then
				self.icone:SetAlpha(1.0)
			else
				self.icone:SetAlpha(0.35)
			end

			local red = false
			if (minAttente > actionCooldownStart + actionCooldownDuration + 0.01 and minAttente > Ovale.maintenant and minAttente > Ovale.attenteFinCast) then
				self.icone:SetVertexColor(0.8, 0.2, 0.2)
				red = true
			else
				self.icone:SetVertexColor(1, 1, 1)
			end

			if element and element.params and element.params.sound and not self.lastSound then
				local delay = self.soundtime or 0.5
				if Ovale.maintenant >= minAttente - delay then
					self.lastSound = element.params.sound
					PlaySoundFile(self.lastSound)
				end
			end

			if minAttente > Ovale.maintenant and Ovale.db.profile.apparence.highlightIcon and not red then
				local lag = 0.6
				local newShouldClick = (minAttente < Ovale.maintenant + lag)
				if self.shouldClick ~= newShouldClick then
					self:SetChecked(newShouldClick and 1 or 0)
					self.shouldClick = newShouldClick
				end
			elseif self.shouldClick then
				self.shouldClick = false
				self:SetChecked(0)
			end

			if (Ovale.db.profile.apparence.numeric and minAttente > Ovale.maintenant and not HasExternalCooldownCounter()) then
				self.remains:SetText(string_format("%.1f", minAttente - Ovale.maintenant))
				self.remains:Show()
			else
				self.remains:Hide()
			end

			if (Ovale.db.profile.apparence.raccourcis and actionShortcut) then
				self.shortcut:Show()
				self.shortcut:SetText(actionShortcut)
			else
				self.shortcut:Hide()
				self.shortcut:SetText("")
			end

			if (actionInRange == 1) then
				self.aPortee:SetVertexColor(0.6, 0.6, 0.6)
				self.aPortee:Show()
			elseif (actionInRange == 0) then
				self.aPortee:SetVertexColor(1.0, 0.1, 0.1)
				self.aPortee:Show()
			else
				self.aPortee:Hide()
			end

			if actionTarget == "focus" then
				self.focusText:Show()
			else
				self.focusText:Hide()
			end

			self:Show()
		end
	else
		self.icone:Hide()
		self.aPortee:Hide()
		self.shortcut:Hide()
		self.remains:Hide()
		self.focusText:Hide()
		if Ovale.db.profile.apparence.hideEmpty then
			self:Hide()
		else
			self:Show()
		end
		if self.shouldClick then
			self:SetChecked(0)
			self.shouldClick = false
		end
	end

	return minAttente, element
end

local function SetSkinGroup(self, _skinGroup)
	self.skinGroup = _skinGroup
	if self.skinGroup then
		if self.skinGroup.AddButton then
			self.skinGroup:AddButton(self, {
				Icon = self.icone,
				Cooldown = self.cd,
				HotKey = self.shortcut,
				Count = self.aPortee,
				Name = self.remains,
				Normal = self.normalTexture,
			})
		end
	end
end

local function SetSize(self, width, height)
	self:SetWidth(width)
	self:SetHeight(height)
	self.icone:SetSize(width, height)
	self.shortcut:SetWidth(width)
	self.remains:SetWidth(width)

	if not Masque then
		self.normalTexture:SetWidth(width)
		self.normalTexture:SetHeight(height)
		if self.customBorder then
			self.customBorder:SetSize(width + 2, height + 2)
		end
	end
end

local function SetHelp(self, help)
	self.help = help
end

function OvaleIcone_OnClick(self)
	Ovale:ToggleOptions()
	self:SetChecked(0)
end

function OvaleIcone_OnEnter(self)
	if self.help or next(Ovale.casesACocher) or (Ovale.listes and next(Ovale.listes)) or self.spellName then
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
		if self.help then
			GameTooltip:SetText(L[self.help] or self.help)
		end
		if self.spellName then
			GameTooltip:AddLine(self.spellName, 0.5, 1, 0.75)
		end
		if next(Ovale.casesACocher) or (Ovale.listes and next(Ovale.listes)) then
			GameTooltip:AddLine(L["Cliquer pour afficher/cacher les options"], 1, 1, 1)
		end
		GameTooltip:Show()
	end
end

function OvaleIcone_OnLeave(self)
	GameTooltip:Hide()
end

function OvaleIcone_OnLoad(self)
	local name = self:GetName()
	self.icone = _G[name.."Icon"]
	self.shortcut = _G[name.."HotKey"]
	self.remains = _G[name.."Name"]
	self.aPortee = _G[name.."Count"]
	self.cd = _G[name.."Cooldown"]
	self.normalTexture = _G[name.."NormalTexture"]

	-- Настройка обрезки полей иконки (Zoom)
	if self.icone then
		self.icone:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		self.icone:ClearAllPoints()
		self.icone:SetAllPoints(self)
	end

	-- Отключение громоздкой стандартной рамки кнопок
	if self.normalTexture then
		self.normalTexture:SetTexture("")
		self.normalTexture:Hide()
	end

	-- Нативная тонкая 1px рамка (для работы без Masque)
	if not Masque and not self.customBorder then
		local border = CreateFrame("Frame", nil, self)
		border:SetPoint("TOPLEFT", self, "TOPLEFT", -1, 1)
		border:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 1, -1)
		border:SetBackdrop({
			edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
			edgeSize = 1,
		})
		border:SetBackdropBorderColor(0, 0, 0, 1)
		self.customBorder = border
	end

	-- Настройка индикатора дистанции
	if self.aPortee then
		self.aPortee:ClearAllPoints()
		self.aPortee:SetPoint("TOPRIGHT", self, "TOPRIGHT", -1, -2)
		self.aPortee:SetText(RANGE_INDICATOR)
	end

	-- Улучшение читаемости шрифта бинда
	if self.shortcut then
		self.shortcut:ClearAllPoints()
		self.shortcut:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 1, 1)
		local fontPath, fontSize = self.shortcut:GetFont()
		if fontPath then
			self.shortcut:SetFont(fontPath, fontSize or 11, "OUTLINE")
		end
	end

	-- Улучшение читаемости таймера
	if self.remains then
		self.remains:ClearAllPoints()
		self.remains:SetPoint("CENTER", self, "CENTER", 0, 0)
		local fontPath, fontSize = self.remains:GetFont()
		if fontPath then
			self.remains:SetFont(fontPath, 14, "OUTLINE")
		end
		self.remains:SetTextColor(1, 1, 0.2)
	end

	-- Метка Focus
	self.focusText = self:CreateFontString(nil, "OVERLAY")
	self.focusText:SetFontObject("GameFontNormalSmall")
	local fontPath, fontSize = self.focusText:GetFont()
	if fontPath then
		self.focusText:SetFont(fontPath, 9, "OUTLINE")
	end
	self.focusText:SetPoint("TOPLEFT", self, "TOPLEFT", 1, -1)
	self.focusText:SetTextColor(0.2, 0.8, 1)
	self.focusText:SetText(L["Focus"])
	self.focusText:Hide()

	self:RegisterForClicks("LeftButtonUp")
	self.SetSkinGroup = SetSkinGroup
	self.Update = Update
	self.SetSize = SetSize
	self.SetHelp = SetHelp

	if Ovale.db.profile.apparence.clickThru then
		self:EnableMouse(false)
	end
end