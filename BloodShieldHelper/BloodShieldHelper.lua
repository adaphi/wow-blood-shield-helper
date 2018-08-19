
local _,ns = ...
local f=CreateFrame("Frame","BloodShieldHelperFrame",UIParent)
ns.frame = f
local umh,netstat = UnitHealthMax,GetNetStats
local curmax,pguid
local healthvals = {}
local curhealth
local e_time=0
local lastupdate = 0
local curtime
local icounter=1
local active=false
BloodShieldHelper_S = {}





local function round(num, idp)
		local mult = 10^(idp or 0)
		return math.floor(num * mult + 0.5) / mult
end

function f:calcheal(lat)
	local curtimer = curtime
	local dmg = 0
	local first = true
	local dmgwipe = 0
	local dmgwipe_t =0
	--print("calc")
	for i,v in pairs(healthvals) do
		if(curtimer-v[1]+lat<=5) then
			dmg = dmg +v[2]

			if(first==true  and v[2] >0) then
				dmgwipe = v[2]
				dmgwipe_t = 5-(curtimer-v[1])
				first = false
			end
		else
			healthvals[i] = nil

		end
	end
	first = true

	local heal = dmg*0.29
	local heal2 = (dmg-dmgwipe)*0.29

	local mheal = curmax*0.07
	local mrating = (GetCombatRatingBonus(26)+8)*6.25

	if(heal>mheal) then

		f.healtext:SetTextColor(unpack(ns.colors[3]))
		f.healtext:SetText(floor(heal*mrating/100))
		if(heal2>mheal) then
			f.healtext2:SetTextColor(unpack(ns.colors[3]))
			f.healtext2:SetText(floor(heal2*mrating/100))
		else
			f.healtext2:SetTextColor(unpack(ns.colors[2]))
			f.healtext2:SetText(floor(mheal*mrating/100))
		end


		f.countdown:SetText(round(dmgwipe_t,1))
	else
		f.healtext:SetTextColor(unpack(ns.colors[2]))
		f.healtext:SetText(floor(mheal*mrating/100))
		f.countdown:SetText(round(dmgwipe_t,1))
		f.healtext2:SetText("")

	end
end

function f:timer(e)
	e_time = e_time+e
	if(e_time-lastupdate > 0.1) then
		f:calcheal(0)

		lastupdate = e_time
	end

end




function f:eventhandler(event,...)
	local arg = ...
	if(event == "UNIT_MAXHEALTH" and arg == "player") then
		curmax = umh("player")

	elseif(event == "COMBAT_LOG_EVENT_UNFILTERED") then


		local tstamp,flags,_,sguid,_,_,_,tguid,_,_,_,amount,amount2,_,amount3,amount4 = ...
		curtime=tstamp
		local dmgtaken
		if(tguid==pguid and (flags=="SWING_DAMAGE" or flags=="RANGE_DAMAGE" or flags=="SPELL_DAMAGE" or flags=="SPELL_PERIODIC_DAMAGE" or flags=="SPELL_BUILDING_DAMAGE" or flags=="ENVIRONMENTAL_DAMAGE" )) then

			if(flags=="SWING_DAMAGE") then
				dmgtaken=amount

			elseif(flags=="ENVIRONMENTAL_DAMAGE") then
				dmgtaken=amount2
			else
				dmgtaken=amount3

			end
			healthvals[icounter] = {}
			healthvals[icounter][1] = curtime
			healthvals[icounter][2] = dmgtaken
			icounter=icounter+1
			f:calcheal(0)

		elseif(ns.debugmode and sguid==pguid and flags=="SPELL_AURA_APPLIED" and amount==77535) then

			print("Blood Shield: "..amount4)
		end
	elseif(event=="PLAYER_REGEN_ENABLED") then
		f:Deactivate()

	elseif(event=="PLAYER_REGEN_DISABLED") then
		if(active==true) then
			f:Activate()
		end
	elseif(event=="PLAYER_TALENT_UPDATE") then

		local _, _, _, _, pointsSpent = GetTalentTabInfo(1)

		if(pointsSpent>30) then
			active = true
			--f:Activate()
		else
			active = false
			--f:Deactivate()
		end
	elseif(event == "ADDON_LOADED" and arg == "BloodShieldHelper") then
		local _,eclass = UnitClass("player")
		if(eclass and eclass~="DEATHKNIGHT") then
			f:UnregisterEvent("PLAYER_TALENT_UPDATE")
			f:UnregisterEvent("PLAYER_REGEN_DISABLED")
			f:UnregisterEvent("PLAYER_REGEN_ENABLED")
			f:UnregisterEvent("ADDON_LOADED")
			return
		end


		if not(BloodShieldHelper_S.colors) then
			BloodShieldHelper_S.colors = {}
			BloodShieldHelper_S.colors[1] ={0.0,0.0,0.0,1.0}
			BloodShieldHelper_S.colors[2] ={1.0,0.0,0.0,1.0}
			BloodShieldHelper_S.colors[3] ={0.0,1.0,0.0,1.0}
			BloodShieldHelper_S.colors[4] ={0.93,0.76,0.0,1.0}
		end

		ns.config:Init()


		f:SetFrameStrata("MEDIUM")
		f:SetWidth(70)
		f:SetHeight(40)
		--f:SetBackdrop( {
		 -- bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
		--  insets = { left = 0, right = 0, top = 0, bottom = 0 }
		--})

		local t = f:CreateTexture(nil,"BACKGROUND")
		--t:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background-Dark")
		t:SetTexture(unpack(ns.colors[1]))
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


		if(BloodShieldHelper_S.position) then
			f:SetPoint(unpack(BloodShieldHelper_S.position))
		else
			f:SetPoint("CENTER",0,0)
		end


		f:EnableMouse(true)
		f:RegisterForDrag("LeftButton")
		f:SetMovable(true)
		f:SetScript("OnDragStart", function(self) if IsShiftKeyDown() then self:StartMoving() end end)
		f:SetScript("OnDragStop", function(self) self:StopMovingOrSizing(); local a,b,c,d,e = self:GetPoint(); if(b~=nil) then b=b:GetName(); end; BloodShieldHelper_S.position = {a,b,c,d,e} end)
		f:Hide()


		f:UnregisterEvent("ADDON_LOADED")

	end
end

function f:Activate()
	if not(pguid) then
		pguid = UnitGUID("player")

	end

	f:RegisterEvent("UNIT_HEALTH")
	f:RegisterEvent("UNIT_MAXHEALTH")
	f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	f:SetScript("OnUpdate", f.timer)
	curmax = umh("player")
	f:Show()
end

function f:Deactivate()

	f:UnregisterEvent("")
	f:UnregisterEvent("")
	f:UnregisterEvent("")
	f:SetScript("OnUpdate", nil)
	icounter=1
	wipe(healthvals)
	f:Hide()
end


f:RegisterEvent("ADDON_LOADED")

f:RegisterEvent("PLAYER_TALENT_UPDATE")
f:RegisterEvent("PLAYER_REGEN_DISABLED")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:SetScript("OnEvent",f.eventhandler)
