
--IncludeFile("Lib\\AntiGapcloser.lua")
IncludeFile("Lib\\SDK.lua")

class "NechritoRiven"

function OnLoad()

  if GetChampName(GetMyChamp()) ~= "Riven"
  then return end

NechritoRiven:__init()
end

function NechritoRiven:__init()

  SetLuaCombo(true)
  SetLuaHarass(true)
  SetLuaLaneClear(true)
  --AntiGap = AntiGapcloser(nil)


self.Q = Spell({Slot = 0,
                Range = 260,
                })
self.Q.Count = 1

self.W = Spell({Slot = 1,
                Range = 225
})

self.E = Spell({Slot = 2,
                Range = 325,
              })

self.R = Spell({Slot = 3,
                SpellType = Enum.SpellType.SkillShot,
                Range = 1100,
                SkillShotType = Enum.SkillShotType.Line,
                Collision = false,
                Width = 160,
                Delay = 0.25,
                Speed = 1600,
              })


              self.targettedSpells =
            	{
                "MonkeyKingSpinToWin",
                "KatarinaRTrigger",
                "HungeringStrike",
                "RengarPassiveBuffDashAADummy",
                "RengarPassiveBuffDash",
                "BraumBasicAttackPassiveOverride",
                "gnarwproc",
                "hecarimrampattack",
                "illaoiwattack",
                "JaxEmpowerTwo",
                "JayceThunderingBlow",
                "RenektonSuperExecute",
                "vaynesilvereddebuff"
            	}

              self.avoidableSpells =
              {
                "MonkeyKingQAttack",
                "FizzPiercingStrike",
                "IreliaEquilibriumStrike",
                "RengarQ",
                "GarenQAttack",
                "GarenRPreCast",
                "PoppyPassiveAttack",
                "viktorqbuff",
                "FioraEAttack",
                "TeemoQ"
              }

              self.FlashRange = 425 + 70 + self.W.Range
              self.EngangeRange = self.E.Range
              self.Q.LastCastTick = 0
              self.W.LastCastTick = 0
              self.E.LastCastTick = 0

  AddEvent(Enum.Event.OnTick, function(...) self:OnTick(...) end)
  AddEvent(Enum.Event.OnUpdateBuff, function(...) self:OnUpdateBuff(...) end)
  AddEvent(Enum.Event.OnProcessSpell, function(...) self:OnProcessSpell(...) end)

  AddEvent(Enum.Event.OnRemoveBuff, function(...) self:OnRemoveBuff(...) end)
  AddEvent(Enum.Event.OnDraw, function(...) self:OnDraw(...) end)
  AddEvent(Enum.Event.OnAfterAttack, function(...) self:OnAfterAttack(...) end)
  AddEvent(Enum.Event.OnDrawMenu, function(...) self:OnDrawMenu(...) end)

  self:MenuValueDefault()
   __PrintTextGame("<b><font color=\"#C70039\">Nechrito Riven</font></b> <font color=\"#ffffff\">Loaded. Enjoy the mayhem</font>")
end

function NechritoRiven:MenuValueDefault()

  self.menu = "Nechrito Riven"

  self.menu_BurstKey = self:MenuKeyBinding("Burst", 84)

  self.menu_ComboFlash = self:MenuBool("Auto Flash Execute", true)
  self.menu_ComboTiamat = self:MenuBool("Use Tiamat", true)
  self.menu_ComboR = self:MenuBool("Use R", true)


  self.menu_DrawReady = self:MenuBool("Only Draw When Ready", true)
  self.menu_DrawEngageRange = self:MenuBool("Draw Engage Range", true)
  self.menu_AutoQ = self:MenuBool("Keep Q Active", true)
end

function NechritoRiven:OnDrawMenu()

if not Menu_Begin(self.menu) then return end

self.menu_BurstKey = Menu_KeyBinding("Burst", self.menu_BurstKey, self.menu)


if (Menu_Begin("Combo")) then

  self.menu_ComboFlash = Menu_Bool("Auto Flash Execute", self.menu_ComboFlash, self.menu)
  self.menu_ComboTiamat = Menu_Bool("Use Tiamat", self.menu_ComboTiamat, self.menu)
  self.menu_ComboR = Menu_Bool("Use R", self.menu_ComboR, self.menu)

  Menu_End()
end
if (Menu_Begin("Drawings")) then
  self.menu_DrawEngageRange = Menu_Bool("Draw Engage Range", self.menu_DrawEngageRange, self.menu)
  Menu_End()

end

  self.menu_AutoQ = Menu_Bool("Keep Q Active", self.menu_AutoQ, self.menu)

  Menu_End()
end

function NechritoRiven:OnDraw()

  local pos = Vector(myHero)
  if GetKeyPress(self.menu_BurstKey) > 0 then
    DrawCircleGame(pos.x, pos.y, pos.z, self.FlashRange, Lua_ARGB(255, 240,230,140))

  elseif self.menu_DrawEngageRange and self.E:IsReady() then
      DrawCircleGame(pos.x, pos.y, pos.z, self.EngangeRange, Lua_ARGB(255, 0, 204, 255))
    end
end

function NechritoRiven:OnTick()
myHero = GetMyHero()

if IsDead(myHero.Addr)
  or myHero.IsRecall
  or IsTyping()
  or not IsRiotOnTop()
  then return end

  if self.R:IsReady() and self.menu_ComboR then
    self.EngangeRange = self.E.Range + GetAttackRange(GetMyHero()) + 230
  else
    self.EngangeRange = self.E.Range + GetAttackRange(GetMyHero()) + 150
  end

--[[ BUG: THIS DOESNT WORK. (CORE ISSUE)
    if #self:GetEnemies(900) > 0 then
      __PrintTextGame("EVADE DISABLED")
      SetEvade(false)
    else
      __PrintTextGame("EVADE ENABLED")
      SetEvade(true)
    end
]]
  if GetKeyPress(self.menu_BurstKey) > 0 then
    if Orbwalker:CanMove() then
      Orbwalker:Move(Vector(GetMousePosX(), GetMousePosY(), GetMousePosZ()))
    end

    self:Burst()
else
  SetEvade(true)
end

  if GetOrbMode() == 1
  and self:GetFlashIndex() > -1
  and CanCast(self:GetFlashIndex()) then

    for k, v in pairs(self:GetEnemies(self.FlashRange)) do

      if GetDistance(Vector(v), Vector(myHero)) >= 500 and self:ComboDamage(v) > GetRealHP(v, 1)
      then
        local myPos = Vector(myHero)
        local targetPos = Vector(v)
        local flashPos = targetPos + (targetPos - myPos):Normalized() * -100
        CastSpellToPos(flashPos.x, flashPos.z, self:GetFlashIndex())
      end
    end
  end

  if self.Q:IsReady()
  and self.menu_AutoQ
  and self.Q.LastCastTick
  and GetTickCount() - self.Q.LastCastTick < 3650
  and GetTickCount() - self.Q.LastCastTick > 3500
  and self.Q.Count ~= 1 then
    self.Q:Cast(Vector(GetMousePosX(), GetMousePosY(), GetMousePosZ()))
  end

  if GetBuffByName(myHero.Addr, "rivenwindslashready") > 0 then
    self.R.WindslashReady = true
  else
    self.R.WindslashReady = false
  end

  if GetBuffByName(myHero.Addr, "RivenFengShuiEngine") > 0 then
    self.R.AttackRangeBoost = true
  else
    self.R.AttackRangeBoost = false
  end

  if self.R.WindslashReady then
    for k, v in pairs(self:GetEnemies(self.R.Range)) do
      if self:RealDamage(v, self.R:GetDamage(v)) > GetRealHP(v, 1) or v.HP / v.MaxHP * 100 <= 35 then
        self:CastR(v)
      end
    end
  end

  if GetOrbMode() == 1 then

    for k, v in pairs(self:GetEnemies(self.EngangeRange)) do
    if self.E:IsReady() then
        self:CastE(v)

        if self.R:IsReady() and not self.R.WindslashReady then
          self:CastR(v)
       end
    end
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

function NechritoRiven:ComboDamage(target)
  local dmg = 0
  if self.R:IsReady() then
    dmg = dmg + self.R:GetDamage(target)
  end

  if self.W:IsReady() then
    dmg = dmg + self.W:GetDamage(target)
  end

  if self.Q:IsReady() then
    local count = 4 - self.Q.Count
    dmg = dmg + self.Q:GetDamage(target) * count
  end

  dmg = self:RealDamage(target, dmg)
  return dmg
end

function NechritoRiven:OnUpdateBuff(source, unit, buff, stacks)
  if not unit.IsMe then return end


  if buff.Name == "RivenFeint" then
    self.E.LastCastTick = GetTickCount()
  end
end

function NechritoRiven:OnRemoveBuff(unit, buff)
  if not unit.IsMe then return end


end

function NechritoRiven:GetFlashIndex()
	if GetSpellIndexByName("SummonerFlash") > -1 then
		return GetSpellIndexByName("SummonerFlash")
  end
	return -1
end

function NechritoRiven:GetTiamat()
	if GetSpellIndexByName("ItemTiamatCleave") > -1 then
		return GetSpellIndexByName("ItemTiamatCleave")
  end

  if GetSpellIndexByName("ItemTitanicHydraCleave") > -1 then
    return GetSpellIndexByName("ItemTitanicHydraCleave")
  end

	return -1
end

function NechritoRiven:Burst()

  local range = self.FlashRange - 425
  if self:GetFlashIndex() > -1
  and CanCast(self:GetFlashIndex()) then
    range = range + 425
  end

  local selected = GetTargetSelected()
  local target = GetUnit(selected)
  if target == 0 then
    target = GetTarget(range)
   end


  if target and GetDistance(Vector(myHero), Vector(target)) <= range then

    if Orbwalker:CanAttack() then
      Orbwalker:Attack(target)
    end

    if self.E:IsReady() then
      self.E:Cast(target)
    end

    if self.R:IsReady() and not self.R.WindslashReady then
      self:CastR(target)
    end

    if self:GetFlashIndex() > -1
    and CanCast(self:GetFlashIndex())
    and self.W:IsReady() then
      self:FlashW(target)
    end
  end
end

function NechritoRiven:FlashW(target)
  local targetPos = Vector(target)
  local myPos = Vector(myHero)
  local flashPos = targetPos + (targetPos - myPos):Normalized() * -180

  if self.R.AttackRangeBoost or self.R:IsReady() then
    self.W:Cast(myHero)
    DelayAction(function() CastSpellToPos(flashPos.x, flashPos.z, self:GetFlashIndex()) end, 0.2)
  else
    CastSpellToPos(flashPos.x, flashPos.z, self:GetFlashIndex())
    self.W:Cast(myHero)
  end
end

function NechritoRiven:CastTiamat()
  if self:GetTiamat() > -1 and self.menu_ComboTiamat then
  local myPos = Vector(myHero)
  CastSpellToPos(myPos.x, myPos.z, self:GetTiamat())
  end
end

function NechritoRiven:OnAfterAttack(unit, target)

  if target.IsDead
  or GetTickCount() - self.Q.LastCastTick <= 400
  or not target.IsValid then return end

  if GetKeyPress(self.menu_BurstKey) > 0  then

    if self.R:IsReady() then
      self:CastR(target)

      if self.R.WindslashReady then
          DelayAction(function() self:CastQ(target) end, 0.25)
        end
    elseif self.Q:IsReady() then
      self:CastQ(target)
    end

  end

  if GetOrbMode() == 1 then

    if self.R:IsReady() then

      if not self.R.WindslashReady and self.menu_ComboR then
        self.R:Cast(myHero)
        DelayAction(function() self.W:Cast(myHero) end, 0.275)
      end

      if self.Q.Count == 3
      and GetHealthPoint(target) / GetHealthPointMax(target) * 100 <= 50 then
        self:CastR(target)
        DelayAction(function() self.Q:Cast(Vector(target)) end, 0.3)
      end
    end

    if self.W:IsReady() and GetTickCount() - self.E.LastCastTick < 600 then
      self:CastW(target)
    end

    if self.Q:IsReady() then
        self:CastQ(target)
        if self.W:IsReady() then
          DelayAction(function() self.W:Cast(myHero) end, 0.5)
        end
    end

  elseif GetOrbMode() == 3 then

    if self.E:IsReady() and self.Q.Count == 3 then
      self.E:Cast(Vector(GetMousePosX(), GetMousePosY(), GetMousePosZ()))
      self.W:Cast(myHero)
      DelayAction(function() self:CastQ(target) end, 0.2)



    elseif self.Q:IsReady() then
      self:CastQ(target)
    end

elseif GetOrbMode() == 4 then
    if IsJungleMonster(target.Addr) then

      if self.Q:IsReady() then
          self:CastQ(target)

      elseif self.W:IsReady() and GetDistance(Vector(target), Vector(myHero)) <= self.W.Range then
          self:CastW(target)
        end

    elseif #self:GetEnemies(2000) <= 0 then
      if self.Q:IsReady() then
        for k, v in pairs(self:EnemyMinionsTbl(500)) do
          local minion = GetUnit(v)
          if minion.NetworkId ~= target.NetworkId  then
            self:CastQ(minion)
          end
        end
      end

     end
  end
end

function NechritoRiven:OnProcessSpell(unit, spell)
  if unit.IsMe then
    if spell.Name == "RivenTriCleave" then
      self.Q.LastCastTick = GetTickCount()

      self.Q.Count = self.Q.Count + 1

      if self.Q.Count > 3 then
          self.Q.Count = 1
      end


    elseif spell.Name == "RivenMartyr" then
        self.W.LastCastTick = GetTickCount()

    elseif spell.Name == "RivenIzunaBlade" and self.Q:IsReady() then
      for k, v in pairs(self:GetEnemies(GetAttackRange(myHero) + 200)) do
        DelayAction(function() self.Q:Cast(v) end, 0.15)
      end
    end
  elseif self.E:IsReady()
  and unit.IsEnemy
   and IsChampion(unit.Addr) then

    if table.contains(self.targettedSpells, spell.Name) or table.contains(self.avoidableSpells, spell.Name) then
      __PrintTextGame("Avoiding Spell: " .. spell.Name)

        self.E:Cast(Vector(GetMousePosX(), GetMousePosY(), GetMousePosZ()))

        if GetDistance(Vector(unit), Vector(myHero)) <= self.W.Range then
          self:CastW(unit)
        end
    end
  end

end

function NechritoRiven:Reset()
  Orbwalker:Move(Vector(GetMousePosX(), GetMousePosY(), GetMousePosZ()))
  Orbwalker:AllowMovement(true)
  Orbwalker:AllowAttack(true)
  Orbwalker:ResetAutoAttackTimer()
end

function NechritoRiven:CastQ(target)
  local delay = math.min(60/1000, GetLatency()/1000)
  local coreDelay =  0.2 - (0.01 * GetLevel(myHero.Addr))
  delay = delay + coreDelay
  __PrintTextGame(delay * 1000)

  if self:GetTiamat() > -1 and CanCast(self:GetTiamat()) and self.Q.Count == 3 then
      self:CastTiamat()
      DelayAction(function() CastSpellTarget(target.Addr, _Q) end,  GetLatency()/1000)
  else
      CastSpellTarget(target.Addr, _Q)
  end

  Orbwalker:AllowMovement(false)
  Orbwalker:AllowAttack(false)
  DelayAction(function() self:Reset() end, delay)
end

function NechritoRiven:EnemyMinionsTbl(range)
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

function NechritoRiven:CastW(target)

  self.W:Cast(target)

end

function NechritoRiven:CastR(target)

  if not self.menu_ComboR and GetOrbMode() == 1 then return end

  if self.R.WindslashReady then
  local castPosX, castPosZ, unitPosX, unitPosZ, hitChance, _aoeTargetsHitCount =
  GetPredictionCore(target.Addr, 0, self.R.Delay, self.R.Width / 2, self.R.Range, self.R.Speed, myHero.x, myHero.z, false, false)

  if hitChance >= 4 then
      local castPos = Vector(castPosX, myHero.y, castPosZ)
      if self:GetTiamat() > -1 and CanCast(self:GetTiamat()) then
        self:CastTiamat()
        DelayAction(function() self.R:Cast(castPos) end, 0.25)
      end
      self.R:Cast(castPos)
      Orbwalker:ResetAutoAttackTimer()
    end
  else
    self.R:Cast(myHero)
  end
end

function NechritoRiven:CastE(target)

    self.E:Cast(target)
end

function NechritoRiven:GetWallPosition(target, range)
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

function NechritoRiven:RotateAroundPoint(v1,v2, angle)
     cos, sin = math.cos(angle), math.sin(angle)
     x = ((v1.x - v2.x) * cos) - ((v2.z - v1.z) * sin) + v2.x
     z = ((v2.z - v1.z) * cos) + ((v1.x - v2.x) * sin) + v2.z
    return Vector(x, v1.y, z or 0)
end

function NechritoRiven:GetHeroes()
	SearchAllChamp()
	local t = pObjChamp
	return t
end

function NechritoRiven:GetEnemies(range)
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

function NechritoRiven:RealDamage(target, damage)

		if target.HasBuff("KindredRNoDeathBuff") then
			return 0
		end

		local pbuff = GetBuff(GetBuffByName(target, "UndyingRage"))

		if target.HasBuff("UndyingRage") and pbuff.EndT > GetTimeGame() + 0.3  then
			return 0
		end

		local pbuff2 = GetBuff(GetBuffByName(target, "ChronoShift"))
		if target.HasBuff("ChronoShift") and pbuff2.EndT > GetTimeGame() + 0.3 then
			return 0
		end

		if target.HasBuff("JudicatorIntervention")
    or target.HasBuff("FioraW")
    or target.HasBuff("ShroudofDarkness")
    or target.HasBuff("SivirShield") then
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

function NechritoRiven:MenuBool(stringKey, bool)
	return ReadIniBoolean(self.menu, stringKey, bool)
end

function NechritoRiven:MenuSliderInt(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function NechritoRiven:MenuSliderFloat(stringKey, valueDefault)
	return ReadIniFloat(self.menu, stringKey, valueDefault)
end

function NechritoRiven:MenuComboBox(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function NechritoRiven:MenuKeyBinding(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end
