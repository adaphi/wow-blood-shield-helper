local _,ns = ...
local config = CreateFrame("Frame")
ns.config = config
local currentcolor






local function changedCallback(restore)

 local newR, newG, newB, newA
 if restore then
   newR, newG, newB, newA = unpack(restore)
 else
   newA, newR, newG, newB = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB()
 end

 r, g, b, a = newR, newG, newB, newA
 currentcolor.colorSwatch:SetVertexColor(r,g,b,a)
 ns.colors[currentcolor.id] = {r,g,b,a}
 config:ChangeColors()
end

function config:ChangeColors()
	ns.frame.texture:SetTexture(unpack(ns.colors[1]))
	ns.frame.healtext:SetTextColor(unpack(ns.colors[2]))
	ns.frame.countdown:SetTextColor(unpack(ns.colors[4]))
	ns.frame.healtext2:SetTextColor(unpack(ns.colors[3]))
end

function config:ConfigColor_OnClick()

	currentcolor = self
	local r,g,b,a = unpack(ns.colors[self.id])
	ColorPickerFrame:SetColorRGB(r,g,b,a)
	ColorPickerFrame.hasOpacity, ColorPickerFrame.opacity = (a ~= nil), a
	ColorPickerFrame.previousValues = {r,g,b,a}
	ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc =
	changedCallback, changedCallback, changedCallback
	ColorPickerFrame:Hide()
	ColorPickerFrame:Show()

end

function config:ChangeState()
	ns.debugmode = self:GetChecked()
	BloodShieldHelper_S.debugmode = ns.debugmode
end


function config:Init()
	ns.colors = BloodShieldHelper_S.colors
	config.name = "Blood Shield Helper"

	local  ConfigColor1 = CreateFrame( "Button", nil, config )
	config.ConfigColor1 = ConfigColor1
	config.ConfigColor1.id = 1
	ConfigColor1:SetHeight(40)
	ConfigColor1:SetWidth(40)
	ConfigColor1:SetScript("OnClick", config.ConfigColor_OnClick)
	ConfigColor1:SetPoint( "TOPLEFT", 16, -16 )


	ConfigColor1.colorSwatch = ConfigColor1:CreateTexture(nil, "OVERLAY")
	ConfigColor1.colorSwatch:SetWidth(19)
	ConfigColor1.colorSwatch:SetHeight(19)
	ConfigColor1.colorSwatch:SetTexture("Interface\\ChatFrame\\ChatFrameColorSwatch")
	ConfigColor1.colorSwatch:SetPoint("LEFT")
	ConfigColor1.colorSwatch:SetVertexColor(unpack(ns.colors[1]))


	ConfigColor1.texture = ConfigColor1:CreateTexture(nil, "BACKGROUND")
	ConfigColor1.texture:SetWidth(16)
	ConfigColor1.texture:SetHeight(16)
	ConfigColor1.texture:SetTexture(1, 1, 1)
	ConfigColor1.texture:SetPoint("CENTER", ConfigColor1.colorSwatch)
	ConfigColor1.texture:Show()

	ConfigColor1.label = ConfigColor1:CreateFontString( nil, "ARTWORK", "GameFontHighlightSmall" )

	ConfigColor1.label:SetText( " |c00dfb802 Background color" )
	ConfigColor1.label:SetPoint( "LEFT" , ConfigColor1,15,0)

	ConfigColor1.label:Show()

	local  ConfigColor2 = CreateFrame( "Button", nil, config )
	config.ConfigColor2 = ConfigColor2
	config.ConfigColor2.id = 2
	ConfigColor2:SetHeight(40)
	ConfigColor2:SetWidth(40)
	ConfigColor2:SetScript("OnClick", config.ConfigColor_OnClick)
	ConfigColor2:SetPoint( "BOTTOMLEFT", ConfigColor1, 0, -25 )


	ConfigColor2.colorSwatch = ConfigColor2:CreateTexture(nil, "OVERLAY")
	ConfigColor2.colorSwatch:SetWidth(19)
	ConfigColor2.colorSwatch:SetHeight(19)
	ConfigColor2.colorSwatch:SetTexture("Interface\\ChatFrame\\ChatFrameColorSwatch")
	ConfigColor2.colorSwatch:SetPoint("LEFT")
	ConfigColor2.colorSwatch:SetVertexColor(unpack(ns.colors[2]))


	ConfigColor2.texture = ConfigColor2:CreateTexture(nil, "BACKGROUND")
	ConfigColor2.texture:SetWidth(16)
	ConfigColor2.texture:SetHeight(16)
	ConfigColor2.texture:SetTexture(1, 1, 1)
	ConfigColor2.texture:SetPoint("CENTER", ConfigColor2.colorSwatch)
	ConfigColor2.texture:Show()

	ConfigColor2.label = ConfigColor2:CreateFontString( nil, "ARTWORK", "GameFontHighlightSmall" )

	ConfigColor2.label:SetPoint( "LEFT" , ConfigColor2,15,0)
	ConfigColor2.label:SetText( " |c00dfb802 Color if minium Blood Shield size" )
	ConfigColor2.label:Show()

	local  ConfigColor3 = CreateFrame( "Button", nil, config )
	config.ConfigColor3 = ConfigColor3
	config.ConfigColor3.id = 3
	ConfigColor3:SetHeight(40)
	ConfigColor3:SetWidth(40)
	ConfigColor3:SetScript("OnClick", config.ConfigColor_OnClick)
	ConfigColor3:SetPoint( "BOTTOMLEFT", ConfigColor2, 0, -25  )


	ConfigColor3.colorSwatch = ConfigColor3:CreateTexture(nil, "OVERLAY")
	ConfigColor3.colorSwatch:SetWidth(19)
	ConfigColor3.colorSwatch:SetHeight(19)
	ConfigColor3.colorSwatch:SetTexture("Interface\\ChatFrame\\ChatFrameColorSwatch")
	ConfigColor3.colorSwatch:SetPoint("LEFT")
	ConfigColor3.colorSwatch:SetVertexColor(unpack(ns.colors[3]))


	ConfigColor3.texture = ConfigColor3:CreateTexture(nil, "BACKGROUND")
	ConfigColor3.texture:SetWidth(16)
	ConfigColor3.texture:SetHeight(16)
	ConfigColor3.texture:SetTexture(1, 1, 1)
	ConfigColor3.texture:SetPoint("CENTER", ConfigColor3.colorSwatch)
	ConfigColor3.texture:Show()

	ConfigColor3.label = ConfigColor3:CreateFontString( nil, "ARTWORK", "GameFontHighlightSmall" )
	ConfigColor3.label:SetPoint( "LEFT" , ConfigColor3,15,0)
	ConfigColor3.label:SetText( " |c00dfb802 Color if greater than minimum Blood Shield size" )
	ConfigColor3.label:Show()


	local  ConfigColor4 = CreateFrame( "Button", nil, config )
	config.ConfigColor4 = ConfigColor4
	config.ConfigColor4.id = 4
	ConfigColor4:SetHeight(40)
	ConfigColor4:SetWidth(40)
	ConfigColor4:SetScript("OnClick", config.ConfigColor_OnClick)
	ConfigColor4:SetPoint( "BOTTOMLEFT", ConfigColor3, 0, -25   )


	ConfigColor4.colorSwatch = ConfigColor4:CreateTexture(nil, "OVERLAY")
	ConfigColor4.colorSwatch:SetWidth(19)
	ConfigColor4.colorSwatch:SetHeight(19)
	ConfigColor4.colorSwatch:SetTexture("Interface\\ChatFrame\\ChatFrameColorSwatch")
	ConfigColor4.colorSwatch:SetPoint("LEFT")
	ConfigColor4.colorSwatch:SetVertexColor(unpack(ns.colors[4]))
	--print(unpack(ns.colors[4]))

	ConfigColor4.texture = ConfigColor4:CreateTexture(nil, "BACKGROUND")
	ConfigColor4.texture:SetWidth(16)
	ConfigColor4.texture:SetHeight(16)
	ConfigColor4.texture:SetTexture(1, 1, 1)
	ConfigColor4.texture:SetPoint("CENTER", ConfigColor4.colorSwatch)
	ConfigColor4.texture:Show()

	ConfigColor4.label = ConfigColor4:CreateFontString( nil, "ARTWORK", "GameFontHighlightSmall" )
	ConfigColor4.label:SetPoint( "LEFT" , ConfigColor4,15,0)
	ConfigColor4.label:SetText( " |c00dfb802 Timer color" )
	ConfigColor4.label:Show()

	local DebugMode = CreateFrame( "CheckButton", nil, config, "InterfaceOptionsCheckButtonTemplate" )
	config.DebugMode = DebugMode
	DebugMode.id = "DebugMode"
	DebugMode:SetPoint( "TOPLEFT", ConfigColor4,"BOTTOMLEFT" ,0, -16 )
	DebugMode:SetScript("onClick",config.ChangeState)
	DebugMode.Text:SetText( "Debug mode (printing out the real Blood Shield size after using Death Strike)" )
	if(BloodShieldHelper_S.debugmode) then
		DebugMode:SetChecked(1)
		ns.debugmode = 1
	end


 InterfaceOptions_AddCategory(config)




end
