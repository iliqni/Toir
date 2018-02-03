--IncludeFile("Lib\\AntiGapcloser.lua")
IncludeFile("Lib\\SDK.lua")

class "NechritoDraven"

function OnLoad()

  if GetChampName(GetMyChamp()) ~= "Draven"
  then return end

NechritoDraven:__init()
end

function NechritoDraven:__init()

  SetLuaCombo(true)
  SetLuaHarass(true)
  SetLuaLaneClear(true)

  --AntiGap = AntiGapcloser(nil)

self.Q = Spell({Slot = 0,
                SpellType = Enum.SpellType.SkillShot,
                AxePositions = {},
                LatestAxeCreateTick = 0
                })
self.Q.AxePositions = {}

self.W = Spell({Slot = 1,
                SpellType = Enum.SpellType.Active})

self.E = Spell({Slot = 2,
                SpellType = Enum.SpellType.SkillShot,
                Range = 950,
                SkillShotType = Enum.SkillShotType.Line,
                Collision = false,
                Width = 100,
                Delay = 250,
                Speed = 1400
        })

self.R = Spell({Slot = 3,
                SpellType = Enum.SpellType.SkillShot,
                Range = 5000,
                SkillShotType = Enum.SkillShotType.Line,
                Collision = false,
                Width = 160,
                Delay = 400,
                Speed = 2000
        })

self.listSpellInterrup =
{
["KatarinaR"] = true,
["AlZaharNetherGrasp"] = true,
["TwistedFateR"] = true,
["VelkozR"] = true,
["InfiniteDuress"] = true,
["JhinR"] = true,
["CaitlynAceintheHole"] = true,
["UrgotSwap2"] = true,
["LucianR"] = true,
["GalioIdolOfDurand"] = true,
["MissFortuneBulletTime"] = true,
["XerathLocusPulse"] = true,
}

  AddEvent(Enum.Event.OnTick, function(...) self:OnTick(...) end)
  AddEvent(Enum.Event.OnCreateObject, function(...) self:OnCreateObject(...) end)
  AddEvent(Enum.Event.OnDeleteObject, function(...) self:OnDeleteObject(...) end)
  AddEvent(Enum.Event.OnDraw, function(...) self:OnDraw(...) end)
  AddEvent(Enum.Event.OnBeforeAttack, function(...) self:OnBeforeAttack(...) end)
  AddEvent(Enum.Event.OnProcessSpell, function(...) self:OnProcessSpell(...) end)
  AddEvent(Enum.Event.OnDrawMenu, function(...) self:OnDrawMenu(...) end)
  self:MenuValueDefault()

   __PrintTextGame("<b><font color=\"#C70039\">Nechrito Draven</font></b> <font color=\"#ffffff\">Loaded. Enjoy the mayhem</font>")
end

function NechritoDraven:MenuValueDefault()

  self.menu = "Nechrito Draven"

  self.menu_QcatchMode = self:MenuComboBox("Catch Mode ", 0)
  self.menu_Qdistance = self:MenuSliderInt("Catch Range (From Cursor)", 600)
  self.menu_Qcombo = self:MenuBool("Combo", true)
  self.menu_Qharass = self:MenuBool("Harass", true)
  self.menu_Qlasthit = self:MenuBool("Lasthit", true)
  self.menu_Qjungle = self:MenuBool("Jungle", true)

  self.menu_WtooFarAway = self:MenuBool("Use W To Catch Axe", true)

  self.menu_Einterrupt = self:MenuBool("Interrupt Spells", true)
  --self.menu_Eantigapclose = self:MenuBool("AntiGapCloser", true)
  self.menu_Ecombo = self:MenuBool("Combo", true)
  self.menu_Eharass = self:MenuBool("Harass", false)

  self.menu_Rcombo = self:MenuBool("Use In Combo", true)

  self.menu_DrawReady = self:MenuBool("Only Draw When Ready", true)
  self.menu_DrawE = self:MenuBool("Draw E Range", false)
  self.menu_DrawQPos = self:MenuBool("Draw Q Position (Debug)", false)

  self.menu_SkinEnable = self:MenuBool("Enalble Mod Skin", false)
	self.menu_SkinIndex = self:MenuSliderInt("Skin", 12)

end

function NechritoDraven:OnDrawMenu()

if not Menu_Begin(self.menu) then return end

if (Menu_Begin("Q Settings")) then
  self.menu_QcatchMode = Menu_ComboBox("Catch Mode ", self.menu_QcatchMode, "Always\0Combo Only\0 Disabled\0\0", self.menu)
  self.menu_Qdistance = Menu_SliderInt("Catch Range (From Cursor)", self.menu_Qdistance, 300, 1000)
  self.menu_Qcombo = Menu_Bool("Combo", self.menu_Qcombo, self.menu)
  self.menu_Qharass = Menu_Bool("Harass", self.menu_Qharass, self.menu)
  self.menu_Qlasthit = Menu_Bool("Lasthit", self.menu_Qlasthit, self.menu)
  self.menu_Qjungle = Menu_Bool("Jungle", self.menu_Qjungle, self.menu)
  Menu_End()
end

if (Menu_Begin("W Settings")) then
  self.menu_WtooFarAway = Menu_Bool("Use W To Catch Axe", self.menu_WtooFarAway, self.menu)
  Menu_End()
end

if (Menu_Begin("E Settings")) then
  self.menu_Einterrupt = Menu_Bool("Interrupt Spells", self.menu_Einterrupt, self.menu)
  --self.menu_Eantigapclose = Menu_Bool("AntiGapCloser", self.menu_Eantigapclose, self.menu)
  self.menu_Ecombo = Menu_Bool("Combo", self.menu_Ecombo, self.menu)
  self.menu_Eharass = Menu_Bool("Harass", self.menu_Eharass, self.menu)
  Menu_End()
end

if (Menu_Begin("R Settings")) then
    self.menu_Rcombo = Menu_Bool("Use In Combo", self.menu_Rcombo, self.menu)
    Menu_End()
end

if (Menu_Begin("Drawings")) then
  self.menu_DrawReady = Menu_Bool("Only Draw When Ready", self.menu_DrawReady, self.menu)
  self.menu_DrawE = Menu_Bool("Draw E Range", self.menu_DrawE, self.menu)
  self.menu_DrawQPos = Menu_Bool("Draw Q Position (Debug)", self.menu_DrawQPos, self.menu)
  Menu_End()
end

self.menu_SkinEnable = Menu_Bool("Enalble Mod Skin", self.menu_SkinEnable, self.menu)
self.menu_SkinIndex = Menu_SliderInt("Set Skin", self.menu_SkinIndex, 0, 15, self.menu)

  Menu_End()

end

function NechritoDraven:OnDraw()

  if self.menu_DrawE then
      if self.menu_DrawReady and not self.E:IsReady() then return end

      pos = Vector(myHero)
      DrawCircleGame(pos.x, pos.y, pos.z, self.E.Range, Lua_ARGB(255, 0, 204, 255))
  end

  if self.menu_DrawQPos and self.Q.AxePositions ~= nil then
    for k, v in pairs(self.Q.AxePositions) do
      local pos = Vector(v)
      DrawCircleGame(pos.x, pos.y, pos.z, 110, Lua_ARGB(255, 0, 204, 255))
    end
  end
end

function NechritoDraven:OnTick()

if (IsDead(myHero.Addr)
or myHero.IsRecall
or IsTyping()
or IsDodging())
or not IsRiotOnTop()
then return end

if self.menu_SkinEnable then
  ModSkin(self.menu_SkinIndex)
end

  if (self.R:IsReady()
  and GetOrbMode() == 1)
  then
    for k,v in pairs(self:GetEnemies(1000)) do
      if v.HP < self.R:GetDamage(v) + myHero.CalcDamage(v, myHero.TotalDmg) then
          self.R:Cast(v)
      end
    end
  end

--[[
  target, enpos = AntiGap:AntiGapInfo()

  if target ~= nil then

    if self.E:IsReady() and GetDistance(Vector(myHero), Vector(target)) <= 1000 and self.menu_Eantigapclose then
              CastSpellTarget(target.Addr, _E)
      return
     end
  end
]]
  if (self.E:IsReady()
  and GetOrbMode() == 1 and self.menu_Ecombo)
  or (GetOrbMode() == 3 and self.menu_Eharass)
  then
    for k,v in pairs(self:GetEnemies(self.E.Range + 70)) do
        self.E:Cast(v)
    end
  end

  local mousePos = Vector(GetMousePosX(), GetMousePosY(), GetMousePosZ())
  local axe = self:GetBestAxe()
  if axe == nil  then
    SetOrbwalkingPoint(mousePos.x, mousePos.z)
     return end

  local axePos = Vector(axe)

  if self.W:IsReady()
  and self.menu_WtooFarAway
  and GetDistance(axePos) / (myHero.MoveSpeed * 1000) < self.Q.LatestAxeCreateTick - GetTickCount() then
    __PrintTextGame(GetDistance(axePos) / (myHero.MoveSpeed * 1000))
      self.W:Cast(myHero)
  end

  if self.menu_QcatchMode == 2 then return end

  if self.menu_QcatchMode == 0
  or self.menu_QcatchMode == 1 and GetOrbMode() == 1 then

    if GetDistance(axePos) > 100 then
      SetOrbwalkingPoint(axePos.x, axePos.z)
    else
      SetOrbwalkingPoint(mousePos.x, mousePos.z)
    end
  end
end

function NechritoDraven:GetBestAxe()

  local axeDist = 0
  local axe = nil
  local mousePos = Vector(GetMousePosX(), GetMousePosY(), GetMousePosZ())

  for k, v in pairs(self.Q.AxePositions) do
    if GetDistance(Vector(v), mousePos) < self.menu_Qdistance then
        local distToAxe = GetDistance(Vector(v))
        if (distToAxe < axeDist and axeDist > 0)
        or axeDist == 0 then
          axeDist = distToAxe
          axe = v
        end
    end
  end
  return axe
end

function NechritoDraven:OnProcessSpell(unit, spell)
	if   unit
   and unit.IsEnemy
   and self.menu_Einterrupt
   and self.listSpellInterrup[spell.Name]
   and self.OnInterruptableSpell
   and IsValidTarget(unit, self.E.Range)
   then
			self.E:Cast(unit)
	end
end

function NechritoDraven:OnCreateObject(unit)
  if GetDistance(Vector(unit)) > 2000 then return end

  if string.find(unit.Name, "reticle_self") then
      self.Q.LatestAxeCreateTick = GetTickCount()

      table.insert(self.Q.AxePositions, unit)
  end
end

function NechritoDraven:OnDeleteObject(unit)
  if GetDistance(Vector(unit)) > 2000 or self.Q.AxePositions == nil then return end

      for k, v in pairs(self.Q.AxePositions) do
        if v.Addr ~= unit.Addr then return end

     table.remove(self.Q.AxePositions, k)
  end
end

function NechritoDraven:OnBeforeAttack(target)

  if (IsJungleMonster(target.Addr) and GetOrbMode() == 4) then

      if(self.Q:IsReady() and self.menu_Qjungle) then
        self.Q:Cast(target)
    end
  end

if not (self.Q:IsReady()) then return end

if (GetOrbMode() == 1 and self.menu_Qcombo) then -- Combo
      self.Q:Cast(target)
end

if (GetOrbMode() == 3 and self.menu_Qharass) then -- Harass
    self.Q:Cast(target)
end

  if (GetOrbMode() == 4 or GetOrbMode() == 2)
  and target ~= nil
  and self.menu_Qlasthit
  then -- Laneclear

    self:GetAAQTarget()
  end
end

function NechritoDraven:GetAAQTarget()

lastT = Orbwalker:GetOrbwalkingTarget()
  for i, minions in ipairs(MinionManager.Enemy) do
      if (minions) then
          minion = GetUnit(minions)

          if minion.IsDead == false
          and GetDistance(Vector(minion), Vector(myHero)) <= 800
          and lastT.Addr ~= minion.Addr
          then

              if (myHero.CalcDamage(minion.Addr, myHero.TotalDmg) + self.Q:GetDamage(minion) > minion.HP
              and myHero.CalcDamage(minion.Addr, myHero.TotalDmg) < minion.HP)
              then
                    self.Q:Cast(minion)
              end
          end
      end
  end
end

function NechritoDraven:GetHeroes()
	SearchAllChamp()
	local t = pObjChamp
	return t
end

function NechritoDraven:GetEnemies(range)
  local t = {}
  local h = self:GetHeroes()
  for k, v in pairs(h) do
    if v ~= 0 then
      local hero = GetAIHero(v)
      if hero.IsEnemy
      and hero.IsValid
       and hero.Type == 0
        and (not range or range > GetDistance(hero)) then
        table.insert(t, hero)
      end
    end
  end
  return t
end

function NechritoDraven:MenuBool(stringKey, bool)
	return ReadIniBoolean(self.menu, stringKey, bool)
end

function NechritoDraven:MenuSliderInt(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function NechritoDraven:MenuSliderFloat(stringKey, valueDefault)
	return ReadIniFloat(self.menu, stringKey, valueDefault)
end

function NechritoDraven:MenuComboBox(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function NechritoDraven:MenuKeyBinding(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end
