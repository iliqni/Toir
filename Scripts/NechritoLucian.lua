--IncludeFile("Lib\\AntiGapcloser.lua")
IncludeFile("Lib\\SDK.lua")

class "NechritoLucian"

function OnLoad()

  if GetChampName(GetMyChamp()) ~= "Lucian"
  then return end

NechritoLucian:__init()
end

function NechritoLucian:__init()

  SetLuaCombo(true)
  SetLuaHarass(true)
  SetLuaLaneClear(true)

  --AntiGap = AntiGapcloser(nil)

self.Q = Spell({Slot = 0,
                SpellType = Enum.SpellType.SkillShot,
                Range = 650,
                SkillShotType = Enum.SkillShotType.Line,
                Collision = false,
                Width = 65,
                Delay = 400,
                Speed = 2400
                })


self.W = Spell({Slot = 1,
                Range = 900,
                SkillShotType = Enum.SkillShotType.Circle,
                Collision = false,
                Width = 80,
                Delay = 250,
                Speed = 1600
})

self.E = Spell({Slot = 2,
                SpellType = Enum.SpellType.SkillShot,
                Range = 425,
                dashPositions = {}
        })

        condemnTable = {}

self.R = Spell({Slot = 3,
                SpellType = Enum.SpellType.SkillShot,
                Range = 1200,
                SkillShotType = Enum.SkillShotType.Line,
                Collision = true,
                Width = 110,
                Delay = 250,
                Speed = math.huge
              })

  AddEvent(Enum.Event.OnTick, function(...) self:OnTick(...) end)
  AddEvent(Enum.Event.OnRemoveBuff, function(...) self:OnRemoveBuff(...) end)
  AddEvent(Enum.Event.OnDraw, function(...) self:OnDraw(...) end)
  AddEvent(Enum.Event.OnAfterAttack, function(...) self:OnAfterAttack(...) end)
  AddEvent(Enum.Event.OnDrawMenu, function(...) self:OnDrawMenu(...) end)

  self:MenuValueDefault()
   __PrintTextGame("<b><font color=\"#C70039\">Nechrito Lucian</font></b> <font color=\"#ffffff\">Loaded. Enjoy the mayhem</font>")
end

function NechritoLucian:MenuValueDefault()

  self.menu = "Nechrito Lucian"

  self.menu_Qhit = self:MenuSliderInt("Q If Minion Hit >=", 3)
  self.menu_Qks = self:MenuBool("Killsteal", true)
  self.menu_Qcombo = self:MenuBool("Combo", true)
  self.menu_Qharass = self:MenuBool("Harass", true)
  self.menu_Qlasthit = self:MenuBool("Lasthit", true)
  self.menu_Qjungle = self:MenuBool("Jungle", true)

  self.menu_Qks = self:MenuBool("Killsteal", true)
  self.menu_Wmana = self:MenuSliderInt("Minimum Mana % To Use", 40)
  self.menu_Wcombo = self:MenuBool("Combo", true)
  self.menu_Wharass = self:MenuBool("Harass", true)
  self.menu_Wlasthit = self:MenuBool("Lasthit", true)
  self.menu_Wjungle = self:MenuBool("Jungle", true)

  self.menu_Epos = self:MenuComboBox("Position ", 0)
  --self.menu_Eantigapclose = self:MenuBool("AntiGapCloser", true)
  self.menu_Ecombo = self:MenuBool("Combo", true)
  self.menu_Eharass = self:MenuBool("Harass", false)
  self.menu_Ejungle = self:MenuBool("Jungle", false)
  self.menu_Elane = self:MenuBool("Lane", false)

  self.menu_Rweaving = self:MenuBool("Use R In Combo", true)
  self.menu_Rks = self:MenuSliderInt("Killsteal", true)

  self.menu_DrawReady = self:MenuBool("Only Draw When Ready", true)
  self.menu_DrawQEx = self:MenuBool("Draw Q Extended Range", false)
  self.menu_DrawDebug = self:MenuBool("Draw Debug", false)
end

function NechritoLucian:OnDrawMenu()

if not Menu_Begin(self.menu) then return end

if (Menu_Begin("Q Settings")) then
  self.menu_Qhit = Menu_SliderInt("Q If Minion Hit >=", self.menu_Qhit, 0, 7, self.menu)
  self.menu_Qks = Menu_Bool("Killsteal", self.menu_Qks, self.menu)
  self.menu_Qcombo = Menu_Bool("Combo", self.menu_Qcombo, self.menu)
  self.menu_Qharass = Menu_Bool("Harass", self.menu_Qharass, self.menu)
  self.menu_Qlane = Menu_Bool("Lane", self.menu_Qlasthit, self.menu)
  self.menu_Qjungle = Menu_Bool("Jungle", self.menu_Qjungle, self.menu)
  Menu_End()
end

if (Menu_Begin("W Settings")) then
  self.menu_Wmana = Menu_SliderInt("Minimum Mana % To Use", self.menu_Wmana, 0, 100, self.menu)
  self.menu_Wks = Menu_Bool("Killsteal", self.menu_Wks, self.menu)
  self.menu_Wcombo = Menu_Bool("Combo", self.menu_Wcombo, self.menu)
  self.menu_Wharass = Menu_Bool("Harass", self.menu_Wharass, self.menu)
  self.menu_Wlane = Menu_Bool("Lane", self.menu_Wlane, self.menu)
  self.menu_Wjungle = Menu_Bool("Jungle", self.menu_Wjungle, self.menu)
  Menu_End()
end

if (Menu_Begin("E Settings")) then
  self.menu_Epos = Menu_ComboBox("Position ", self.menu_Epos, "Automatic\0Mouse\0\0", self.menu)
  self.menu_Ecombo = Menu_Bool("Combo", self.menu_Ecombo, self.menu)
  self.menu_Eharass = Menu_Bool("Harass", self.menu_Eharass, self.menu)
  self.menu_Elane = Menu_Bool("Lane", self.menu_Elane, self.menu)
  self.menu_Ejungle = Menu_Bool("Jungle", self.menu_Ejungle, self.menu)
  Menu_End()
end

if (Menu_Begin("R Settings")) then
  self.menu_Rks = Menu_Bool("Killsteal", self.menu_Rks, self.menu)
  self.menu_Rweaving = Menu_Bool("Use R In Combo", self.menu_Rweaving, self.menu)
  Menu_End()
end

if (Menu_Begin("Drawings")) then
  self.menu_DrawReady = Menu_Bool("Only Draw When Ready", self.menu_DrawReady, self.menu)
  self.menu_DrawQEx = Menu_Bool("Draw QEx", self.menu_DrawQEx, self.menu)
  self.menu_DrawDebug = Menu_Bool("Draw Debug", self.menu_DrawDebug, self.menu)
end
  Menu_End()
end

function NechritoLucian:OnDraw()

  local pos = Vector(myHero)

    if self.menu_DrawDebug and GetOrbMode() == 1 then
      if self.E.dashPositions ~= nil then
        for k, v in pairs(self.E.dashPositions) do
          DrawCircleGame(v.x, v.y, v.z, 60, Lua_ARGB(255, 0, 204, 255))
        end
      end
  end

  if self.menu_DrawReady and not self.Q:IsReady() then return end

  if self.menu_DrawQEx then
      DrawCircleGame(pos.x, pos.y, pos.z, self.Q.Range + 400, Lua_ARGB(255, 0, 204, 255))
  end
end

function NechritoLucian:OnTick()
myHero = GetMyHero()

if (IsDead(myHero.Addr)
or myHero.IsRecall
or IsTyping()
or IsDodging())
or not IsRiotOnTop()
then return end

Orbwalker:AllowAttack(GetBuffByName(myHero.Addr, "LucianR") == 0)

self.Q.Delay = (0.409 - (0.009 * GetLevel(myHero.Addr))) * 1000

  if GetOrbMode() == 0 and self.E.dashPositions ~= nil then
      self.E.dashPositions = {}
  end

  if self.Q:IsReady() then
    for k, v in pairs(self:GetEnemies(self.Q.Range + 400)) do
      self:CastQEx(v)
    end
  end

--[[
  target, enpos = AntiGap:AntiGapInfo()

  if target ~= nil then

    if self.E:IsReady() and GetDistance(Vector(myHero), Vector(target)) <= self.E.Range and self.menu_Eantigapclose then
              CastSpellTarget(target.Addr, _E)
      return

   elseif self.Q:IsReady() and self.menu_Qantigapclose then
      pos = Vector(myHero) + (Vector(myHero) - Vector(endPos)):Normalized() * self.Q.Range
      self.Q.tumblePosition = pos
      self.Q:Cast(pos)
    end
  end
]]

end

function NechritoLucian:OnRemoveBuff(unit, buff)
    if unit.IsMe and buff.Name == "LucianR" then
      Orbwalker:ResetAutoAttackTimer()
    end
end

function NechritoLucian:OnAfterAttack(unit, target)

  if GetOrbMode() == 4 and #self:GetEnemies(1900) > 0 then return end

  if self.E:IsReady() then
    if GetOrbMode() == 1 and self.menu_Ecombo
    or GetOrbMode() == 3 and self.menu_Eharass
    or GetOrbMode() == 4 and self.menu_Elane
    then
        self:CastE(target)
        return
    end
  elseif self.Q:IsReady() then
    if GetOrbMode() == 1 and self.menu_Qcombo
    or GetOrbMode() == 3 and self.menu_Qharass
    or GetOrbMode() == 4 and self.menu_Qlane
    then
        self:CastQ(target)
        return
    end
  elseif self.W:IsReady() then
    if GetOrbMode() == 1 and self.menu_Wcombo
    or GetOrbMode() == 3 and self.menu_Wharass
    or GetOrbMode() == 4 and self.menu_Wlane
    then
        self:CastW(target)
        return
    end

  -- R In Combo Logic
  elseif (self.R:IsReady()
  and GetOrbMode() == 1
  and self.menu_Rweaving
  and not self.Q:IsReady()
  and not self.W:IsReady()
  and not self.E:IsReady())
  then
      self:CastR(target)
    end
  -- Jungle
if (IsJungleMonster(target.Addr) and GetOrbMode() == 4) then

    if (self.E:IsReady() and self.menu_Ejungle) then
      self:CastE(target)
    elseif(self.Q:IsReady() and self.menu_Qjungle) then
        self:CastQ(target)
      elseif(self.W:IsReady() and self.menu_Wjungle) then
          self:CastW(target)
        end
  end

end

function NechritoLucian:CastQ(target)

    if GetDistance(Vector(target), Vector(myHero)) < self.Q.Range then
      CastSpellTarget(target.Addr, _Q)
    end
end

function NechritoLucian:EnemyMinionsTbl(range)
    GetAllUnitAroundAnObject(myHero.Addr, range)
    local result = {}
    for i, obj in pairs(pUnit) do
        if obj ~= 0  then
            local minions = GetUnit(obj)
            if IsEnemy(minions.Addr) and not IsDead(minions.Addr) and not IsInFog(minions.Addr) and (GetType(minions.Addr) == 1 or GetType(minions.Addr) == 2) then
                table.insert(result, minions.Addr)
            end
        end
    end
    return result
end

function NechritoLucian:CastQEx(target)
  local myPos = Vector(myHero)

  for k, v in ipairs(self:EnemyMinionsTbl(self.Q.Range)) do
    if v ~= nil then
    local minion = GetUnit(v)

      local minionPos = Vector(minion)
      local endPos = myPos:Extended(minionPos, 900)

      if GetDistance(endPos, Vector(target)) < self.Q.Width * 0.5
      then
          CastSpellTarget(minion.Addr, _Q)
        end
    end
  end
end

function NechritoLucian:CastW(target)
  if myHero.MP / myHero.MaxMP * 100 < self.menu_Wmana then return end

    self.W:Cast(target)
end

function NechritoLucian:CastR(target)

  local castPosX, castPosZ, unitPosX, unitPosZ, hitChance, _aoeTargetsHitCount =
  GetPredictionCore(target.Addr, 0, self.R.Delay, self.R.Width / 2, self.R.Range, self.R.Speed, myHero.x, myHero.z, false, false)

  if hitChance >= 4 then
      local castPos = Vector(castPosX, myHero.y, castPosZ)

      self.R:Cast(castPos)
    end
end

function NechritoLucian:CastE(target)

  local castPos = nil
  self.E.dashPositions = {}
  local playerPos = Vector(myHero)

  local kitePos = self:GetKitePosition(target)

  if self.menu_Epos == 1 then
    local mousePos =Vector(GetMousePosX(), GetMousePosY(), GetMousePosZ())
    local final = playerPos:Extended(mousePos, 500)
    castPos = final

  elseif GetDistance(Vector(target)) > GetTrueAttackRange() + 60 then
          castPos = Vector(target)
  elseif kitePos ~= nil then
      castPos = kitePos
    end

    if castPos == nil then return end

    self.E:Cast(castPos)
end

function NechritoLucian:GetWallPosition(target, range)
    range = range or 400

    for i= 0, 360, 45 do
        angle = i * (math.pi/180)
        targetPosition = Vector(GetPos(target))
        targetRotated = Vector(targetPosition.x + range, targetPosition.y, targetPosition.z)
        pos = Vector(self:RotateAroundPoint(targetRotated, targetPosition, angle))

        if IsWall(pos.x, pos.y, pos.z) and GetDistance(pos) < range then
            return pos
        end
    end
end

function NechritoLucian:GetKitePosition(target)
  self.E.dashPositions = {}

  for i = 0, 360, 22.5 do

    if i >= 360 then
      return Vector(GetMousePosX(), GetMousePosY(), GetMousePosZ())
    end

    local angle = i * (math.pi/180)

    local myPos = Vector(myHero)
    local tPos = Vector(target)

    local rot = self:RotateAroundPoint(tPos, myPos, angle)
    local pos = myPos + (myPos - rot):Normalized() * 150

     table.insert(self.E.dashPositions, pos)

     local dist = GetDistance(Vector(target), pos)
     if dist < 690 and dist > 480 then
     return pos end
   end
    return nil
  end

function NechritoLucian:RotateAroundPoint(v1,v2, angle)
     cos, sin = math.cos(angle), math.sin(angle)
     x = ((v1.x - v2.x) * cos) - ((v2.z - v1.z) * sin) + v2.x
     z = ((v2.z - v1.z) * cos) + ((v1.x - v2.x) * sin) + v2.z
    return Vector(x, v1.y, z or 0)
end

function NechritoLucian:GetHeroes()
	SearchAllChamp()
	local t = pObjChamp
	return t
end

function NechritoLucian:GetEnemies(range)
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

function NechritoLucian:RealDamage(target, damage)

		if target.HasBuff("KindredRNoDeathBuff") then
			return 0
		end

		local pbuff = GetBuff(GetBuffByName(target, "UndyingRage"))

		if target.HasBuff("UndyingRage") and pbuff.EndT > GetTimeGame() + 0.3  then
			return 0
		end

		if target.HasBuff("JudicatorIntervention") then
			return 0
		end

		local pbuff2 = GetBuff(GetBuffByName(target, "ChronoShift"))
		if target.HasBuff("ChronoShift") and pbuff2.EndT > GetTimeGame() + 0.3 then
			return 0
		end

		if target.HasBuff("FioraW") then
			return 0
		end

		if target.HasBuff("ShroudofDarkness") then
			return 0
		end

		if target.HasBuff("SivirShield") then
			return 0
		end

		if target.HasBuff("Moredkaiser") then
			damage = damage - target.MP
		end

		if myHero.HasBuff("SummonerExhaust") then
			damage = damage * 0.6;
		end

		if target.HasBuff("BlitzcrankManaBarrierCD") and target.HasBuff("ManaBarrier") then
			damage = damage - target.MP / 2
		end

		if target.HasBuff("GarenW") then
			damage = damage * 0.7;
		end

		if target.HasBuff("ferocioushowl") then
			damage = damage * 0.7;
		end

		return damage
end

function NechritoLucian:MenuBool(stringKey, bool)
	return ReadIniBoolean(self.menu, stringKey, bool)
end

function NechritoLucian:MenuSliderInt(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function NechritoLucian:MenuSliderFloat(stringKey, valueDefault)
	return ReadIniFloat(self.menu, stringKey, valueDefault)
end

function NechritoLucian:MenuComboBox(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function NechritoLucian:MenuKeyBinding(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end
