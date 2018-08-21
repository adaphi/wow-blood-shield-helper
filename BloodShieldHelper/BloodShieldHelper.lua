
local _,ns = ...
local f=CreateFrame("Frame", "BloodShieldHelperFrame", UIParent)
ns.frame = f

local curhealth, curmax, pguid
local healthvals = {}

local e_time=0
local lastupdate = 0
local curtime
local icounter=1

local isBloodSpec=false
local isActive=false
local isTimerActive=false

BloodShieldHelper_S = {}

local function round(num, idp)
		local mult = 10^(idp or 0)
		return math.floor(num * mult + 0.5) / mult
end

function f:CalcHeal(lat)
	local curtimer = curtime
	local dmg = 0
	local first = true
	local dmgwipe = 0
	local dmgwipe_t = 0

	for i,v in pairs(healthvals) do
		if (curtimer-v[1]+lat<=5) then
			dmg = dmg +v[2]

			if (first==true  and v[2] >0) then
				dmgwipe = v[2]
				dmgwipe_t = 5-(curtimer-v[1])
				first = false
			end
		else
			healthvals[i] = nil
		end
	end
	first = true

	local heal = dmg*0.25
	local heal2 = (dmg-dmgwipe)*0.25

	f:UpdateHealText(heal, heal2, dmgwipe_t)
end

function f:UpdateHealText(heal, nextheal, dmgtimer)
	local mheal = curmax*0.07
	local mrating, _ = GetMasteryEffect()
	local vrating = 100+GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE)

	if (heal>mheal) then
		f.healtext:SetTextColor(unpack(ns.colors[3]))
		f.healtext:SetText(floor(heal*mrating*vrating/10000))
		if (nextheal>mheal) then
			f.healtext2:SetTextColor(unpack(ns.colors[3]))
			f.healtext2:SetText(floor(nextheal*mrating*vrating/10000))
		else
			f.healtext2:SetTextColor(unpack(ns.colors[2]))
			f.healtext2:SetText(floor(mheal*mrating*vrating/10000))
		end
		f.countdown:SetText(round(dmgtimer,1))
	else
		f.healtext:SetTextColor(unpack(ns.colors[2]))
		f.healtext:SetText(floor(mheal*mrating*vrating/10000))
		f.countdown:SetText("")
		f.healtext2:SetText("")
	end
end

function f:Timer(e)
	e_time = e_time+e
	if (e_time-lastupdate > 0.1) then
		f:CalcHeal(0)
		lastupdate = e_time
	end
end

function f:CheckSpecialization()
	-- Check for blood spec
	return GetSpecialization() == 1
end

function f:HandleEvent(event,...)
	local arg = ...
	if (event == "PLAYER_ENTERING_WORLD") then
		curmax = UnitHealthMax("player")
		f:UpdateHealText(0, 0, 0)

	elseif (event == "UNIT_MAXHEALTH" and arg == "player") then
		curmax = UnitHealthMax("player")
		if not(isTimerActive) then
			f:UpdateHealText(0, 0, 0)
		end

	elseif (event == "COMBAT_LOG_EVENT_UNFILTERED") then
		f:HandleCombatLogEvent()

	elseif (event=="PLAYER_REGEN_ENABLED") then
		f:DisableTimer()
		if not(ns.forceshow) then
			f:Deactivate()
		end

	elseif (event=="PLAYER_REGEN_DISABLED") then
		f:Activate()
		f:EnableTimer()

	elseif (event=="PLAYER_TALENT_UPDATE") then
		isBloodSpec = f:CheckSpecialization()
		if (isBloodSpec and ns.forceshow) then
			f:Activate()
		else
			f:Deactivate()
		end

	elseif (event == "ADDON_LOADED" and arg == "BloodShieldHelper") then
		local _,eclass = UnitClass("player")
		if (eclass and eclass~="DEATHKNIGHT") then
			f:UnregisterEvent("PLAYER_TALENT_UPDATE")
			f:UnregisterEvent("PLAYER_REGEN_DISABLED")
			f:UnregisterEvent("PLAYER_REGEN_ENABLED")
			f:UnregisterEvent("ADDON_LOADED")
			return
		end
		f:Init()
	end
end

function f:HandleCombatLogEvent()
	local tstamp, eventname, _, sguid, _, _, _, tguid, _, _, _, arg12, arg13, _, arg15, arg16 = CombatLogGetCurrentEventInfo()
	local dmgtaken
	curtime=tstamp
	if (tguid==pguid and (eventname=="SWING_DAMAGE" or eventname=="RANGE_DAMAGE" or eventname=="SPELL_DAMAGE" or eventname=="SPELL_PERIODIC_DAMAGE" or eventname=="SPELL_BUILDING_DAMAGE" or eventname=="ENVIRONMENTAL_DAMAGE" )) then

		if (eventname=="SWING_DAMAGE") then
			dmgtaken=arg12
		elseif (eventname=="ENVIRONMENTAL_DAMAGE") then
			dmgtaken=arg13
		else
			dmgtaken=arg15
		end

		healthvals[icounter] = {}
		healthvals[icounter][1] = curtime
		healthvals[icounter][2] = dmgtaken
		icounter=icounter+1
		f:CalcHeal(0)

	elseif (ns.debugmode and sguid==pguid and eventname=="SPELL_AURA_APPLIED" and arg12==77535) then
		print("Blood Shield: "..arg16)
	end
end

function f:Init()
	if not(BloodShieldHelper_S.colors) then
		BloodShieldHelper_S.colors = {}
		BloodShieldHelper_S.colors[1] ={0.0,0.0,0.0,1.0}
		BloodShieldHelper_S.colors[2] ={1.0,0.0,0.0,1.0}
		BloodShieldHelper_S.colors[3] ={0.0,1.0,0.0,1.0}
		BloodShieldHelper_S.colors[4] ={0.93,0.76,0.0,1.0}
	end

	isBloodSpec = f:CheckSpecialization()

	ns.config:Init()

	f:SetFrameStrata("MEDIUM")
	f:SetWidth(70)
	f:SetHeight(40)

	local t = f:CreateTexture(nil,"BACKGROUND")
	t:SetColorTexture(unpack(ns.colors[1]))
	t:SetWidth(70)
	t:SetHeight(40)

	t:SetPoint("CENTER",f)
	f.texture = t

	local font = f:CreateFontString( nil, "OVERLAY", "GameFontNormal" )
	font:SetPoint("TOPRIGHT", f,"TOPRIGHT", 0, -5)
	font:SetTextColor(unpack(ns.colors[2]))
	f.healtext = font

	local font2 = f:CreateFontString( nil, "OVERLAY", "GameFontNormal" )
	font2:SetPoint("BOTTOMLEFT", f,"BOTTOMLEFT", 0, 5)
	font2:SetTextColor(unpack(ns.colors[4]))
	f.countdown = font2

	local font3 = f:CreateFontString( nil, "OVERLAY", "GameFontNormal" )
	font3:SetPoint("BOTTOMRIGHT", f,"BOTTOMRIGHT", 0, 5)
	font3:SetTextColor(unpack(ns.colors[3]))
	f.healtext2 = font3

	if (BloodShieldHelper_S.position) then
		f:SetPoint(unpack(BloodShieldHelper_S.position))
	else
		f:SetPoint("CENTER",0,0)
	end

	f:EnableMouse(true)
	f:RegisterForDrag("LeftButton")
	f:SetMovable(true)
	f:SetScript("OnDragStart", function(self) if IsShiftKeyDown() then self:StartMoving() end end)
	f:SetScript("OnDragStop", function(self) self:StopMovingOrSizing(); local a,b,c,d,e = self:GetPoint(); if (b~=nil) then b=b:GetName(); end; BloodShieldHelper_S.position = {a,b,c,d,e} end)
	f:Hide()

	if (BloodShieldHelper_S.forceshow) then
		f:Activate()
	end

	f:UnregisterEvent("ADDON_LOADED")
end

function f:Activate()
	if not isBloodSpec or isActive then
		return
	end

	if not(pguid) then
		pguid = UnitGUID("player")
	end

	curmax = UnitHealthMax("player")

	f:RegisterEvent("UNIT_HEALTH")
	f:RegisterEvent("UNIT_MAXHEALTH")
	f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

	f:Show()
	isActive = true
end

function f:Deactivate()
	if not isActive then
		return
	end
	f:UnregisterEvent("UNIT_HEALTH")
	f:UnregisterEvent("UNIT_MAXHEALTH")
	f:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

	f:DisableTimer()

	f:Hide()
	isActive = false
end

function f:EnableTimer()
	f:SetScript("OnUpdate", f.Timer)
	isTimerActive=true
end

function f:DisableTimer()
	icounter=1
	wipe(healthvals)
	f:SetScript("OnUpdate", nil)
	isTimerActive=false
end

f:RegisterEvent("ADDON_LOADED")

f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_TALENT_UPDATE")
f:RegisterEvent("PLAYER_REGEN_DISABLED")
f:RegisterEvent("PLAYER_REGEN_ENABLED")

f:SetScript("OnEvent", f.HandleEvent)
