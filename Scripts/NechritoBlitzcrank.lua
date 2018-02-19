--IncludeFile("Lib\\AntiGapcloser.lua")
IncludeFile("Lib\\SDK.lua")

class "NechritoBlitzcrank"

function OnLoad()

  if GetChampName(GetMyChamp()) ~= "Blitzcrank"
  then return end

NechritoBlitzcrank:__init()
end

function NechritoBlitzcrank:__init()

  SetLuaCombo(true)
  SetLuaHarass(true)
  SetLuaLaneClear(true)

  --AntiGap = AntiGapcloser(nil)

self.Q = Spell({Slot = 0,
                SpellType = Enum.SpellType.SkillShot,
                Range = 950,
                SkillShotType = Enum.SkillShotType.Line,
                Collision = true,
                Width = 90,
                Delay = 0.250,
                Speed = 1750,
                flashPositions = {}
                })


self.W = Spell({Slot = 1,
                Range = 900,
                SpellType = Enum.SpellType.Active})

self.E = Spell({Slot = 2,
                SpellType = Enum.SpellType.Active})

self.R = Spell({Slot = 3,
                Radius = 600})

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
                ["BlitzcrankR"] = true,
                ["GalioIdolOfDurand"] = true,
                ["MissFortuneBulletTime"] = true,
                ["XerathLocusPulse"] = true,
                }

  AddEvent(Enum.Event.OnProcessSpell, function(...) self:OnProcessSpell(...) end)
  AddEvent(Enum.Event.OnTick, function(...) self:OnTick(...) end)
  AddEvent(Enum.Event.OnDraw, function(...) self:OnDraw(...) end)
  AddEvent(Enum.Event.OnDrawMenu, function(...) self:OnDrawMenu(...) end)
  Orbwalker:RegisterPreAttackCallback(function(...)  self:OnPreAttack(...) end)

  self:MenuValueDefault()
   __PrintTextGame("<b><font color=\"#C70039\">Nechrito Blitzcrank</font></b> <font color=\"#ffffff\">Loaded. Enjoy the mayhem</font>")
end

function NechritoBlitzcrank:MenuValueDefault()

  self.menu = "Nechrito Blitzcrank"

  self.menu_Qflash = self:MenuKeyBinding("Smart Flash Q", 84)
  self.menu_Qauto = self:MenuBool("Automatic Q", true)
  self.menu_Qcombo = self:MenuBool("Combo", true)
  self.menu_Qharass = self:MenuBool("Harass", true)

  self.menu_Wslowed = self:MenuBool("Auto W If Slowed", true)

  --self.menu_Eantigapclose = self:MenuBool("AntiGapCloser", true)
  self.menu_Ecombo = self:MenuBool("Combo", true)
  self.menu_Eharass = self:MenuBool("Harass", true)
  self.menu_Ejungle = self:MenuBool("Jungle", false)

  self.menu_Rweaving = self:MenuBool("Use R In Combo", true)

  self.menu_DrawReady = self:MenuBool("Only Draw When Ready", true)
  self.menu_DrawQ = self:MenuBool("Draw Q Range", false)
  self.menu_DrawDebug = self:MenuBool("Draw Debug", false)
end

function NechritoBlitzcrank:OnDrawMenu()

if not Menu_Begin(self.menu) then return end

if (Menu_Begin("Q Settings")) then
  self.menu_Qflash = Menu_KeyBinding("Smart Flash Q", self.menu_Qflash, self.menu)
  self.menu_Qauto = Menu_Bool("Automatic Q", self.menu_Qauto, self.menu)
  self.menu_Qcombo = Menu_Bool("Combo", self.menu_Qcombo, self.menu)
  self.menu_Qharass = Menu_Bool("Harass", self.menu_Qharass, self.menu)
  Menu_End()
end

if (Menu_Begin("W Settings")) then
  self.menu_Wslowed = Menu_Bool("Auto W If Slowed", self.menu_Wslowed, self.menu)
  Menu_End()
end

if (Menu_Begin("E Settings")) then
  self.menu_Ecombo = Menu_Bool("Combo", self.menu_Ecombo, self.menu)
  self.menu_Eharass = Menu_Bool("Harass", self.menu_Eharass, self.menu)
  self.menu_Ejungle = Menu_Bool("Jungle", self.menu_Ejungle, self.menu)
  Menu_End()
end

if (Menu_Begin("R Settings")) then
  self.menu_Rweaving = Menu_Bool("Use R In Combo", self.menu_Rweaving, self.menu)
  Menu_End()
end

if (Menu_Begin("Drawings")) then
  self.menu_DrawReady = Menu_Bool("Only Draw When Ready", self.menu_DrawReady, self.menu)
  self.menu_DrawQ = Menu_Bool("Draw Q", self.menu_DrawQ, self.menu)
  self.menu_DrawDebug = Menu_Bool("Draw Debug", self.menu_DrawDebug, self.menu)
end
  Menu_End()
end

function NechritoBlitzcrank:OnDraw()

  local pos = Vector(myHero)

    if self.menu_DrawDebug
    and GetKeyPress(self.menu_Qflash) > 0
    and self.Q.flashPositions ~= nil then
      for k, v in pairs(self.Q.flashPositions) do
        DrawCircleGame(v.x, v.y, v.z, 60, Lua_ARGB(255, 0, 204, 255))
      end
  end

  if self.menu_DrawReady and not self.Q:IsReady() then return end

  if self.menu_DrawQ then
      DrawCircleGame(pos.x, pos.y, pos.z, self.Q.Range + 400, Lua_ARGB(255, 0, 204, 255))
  end
end

function NechritoBlitzcrank:OnTick()
myHero = GetMyHero()

if (IsDead(myHero.Addr)
or myHero.IsRecall
or IsTyping()
or IsDodging())
or not IsRiotOnTop()
then return end

if GetKeyPress(self.menu_Qflash) > 0 and GetOrbMode() == 0 and Orbwalker:CanMove() then
      local mousePos = Vector(GetMousePosX(), GetMousePosY(), GetMousePosZ())
      Orbwalker:Move(mousePos)
end

if self.menu_Qflash
and self.Q:IsReady()
and self:GetFlashIndex() > -1
and GetKeyPress(self.menu_Qflash) > 0
and CanCast(self:GetFlashIndex()) then
    for k, target in pairs(self:GetEnemies(self.Q.Range)) do

      local flashPosition, castPosition = self:GetFlashQPos(target)

      if flashPosition ~= nil then
        CastSpellToPos(flashPosition.x, flashPosition.z, self:GetFlashIndex())
        DelayAction(function() self.Q:Cast(castPosition) end, 0.1)
    end
  end
end

  if GetKeyPress(self.menu_Qflash) == 0 and self.Q.flashPositions ~= nil then
      self.Q.flashPositions = {}
  end

    if self.Q:IsReady() then
      if self.menu_Qauto
      or GetOrbMode() == 1 and self.menu_Qcombo
      or GetOrbMode() == 3 and self.menu_Qharass
      then
        for k, v in pairs(self:GetEnemies(self.Q.Range)) do
          self:CastQ(v)
        end
      end
    elseif self.W:IsReady() and #self:GetEnemies(800) > 0 then

      if GetBuffByName(myHero.Addr, "slow") ~= 0 and self.menu_Wslowed
      or GetOrbMode() == 1 and self.menu_Wcombo
      then
        self:CastW()
    end

    -- R In Combo Logic
    if self.R:IsReady()
    and #self:GetEnemies(600) > 0
    and GetOrbMode() == 1
    and self.menu_Rweaving
    then
        self:CastR()
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

function NechritoBlitzcrank:OnProcessSpell(unit, spell)
	 if  unit
   and unit.IsEnemy
   and self.listSpellInterrup[spell.Name]
   and self.OnInterruptableSpell
   and IsValidTarget(unit, self.Q.Range)
   then
			self.Q:Cast(unit)
	end
end

function NechritoBlitzcrank:OnPreAttack(args)
  if not self.E:IsReady() then return end

  if GetOrbMode() == 1 and self.menu_Ecombo
  or GetOrbMode() == 3 and self.menu_Eharass
  or GetOrbMode() == 4 and IsJungleMonster(args.Target.Addr) and self.menu_Ejungle then
    self:CastE()
  end
end

function NechritoBlitzcrank:CastQ(target)

  local myPos = Vector(myHero)
  local castPosX, castPosZ, unitPosX, unitPosZ, hitChance, _aoeTargetsHitCount =
  GetPredictionCore(target.Addr, 0, self.Q.Delay, self.Q.Width, self.Q.Range, self.Q.Speed,
   myPos.x, myPos.z, false, true, 1, 0, 2, 5, 5, 5)

  if hitChance >= 4 then
      local castPos = Vector(castPosX, target.y, castPosZ)
      self.Q:Cast(castPos)
    end
end

function NechritoBlitzcrank:GetFlashIndex()
	if GetSpellIndexByName("SummonerFlash") > -1 then
		return GetSpellIndexByName("SummonerFlash")
  end
	return -1
end

function NechritoBlitzcrank:CastW()
  self.W:Cast(myHero)
end

function NechritoBlitzcrank:CastR()
self.R:Cast(myHero)
end

function NechritoBlitzcrank:CastE()
  self.E:Cast(myHero)
end

function NechritoBlitzcrank:GetFlashQPos(target)
  self.Q.flashPositions = {}

  for i = 0, 360, 22.5 do

    local angle = i * (math.pi/180)

    local myPos = Vector(myHero)
    local tPos = Vector(target)

    local rot = self:RotateAroundPoint(tPos, myPos, angle)
    local flashPosition = myPos + (myPos - rot):Normalized() * 425

     table.insert(self.Q.flashPositions, flashPosition)

     local castPosX, castPosZ, unitPosX, unitPosZ, hitChance, _aoeTargetsHitCount =
     GetPredictionCore(target.Addr, 0, self.Q.Delay, self.Q.Width, self.Q.Range, self.Q.Speed,
      flashPosition.x, flashPosition.z, false, true, 1, 0, 1, 2, 5, 5)

     local castPosition = Vector(castPosX, myHero.y, castPosZ)

     if hitChance >= 4 then return flashPosition, castPosition end
   end
    return nil
  end

function NechritoBlitzcrank:RotateAroundPoint(v1,v2, angle)
     cos, sin = math.cos(angle), math.sin(angle)
     x = ((v1.x - v2.x) * cos) - ((v2.z - v1.z) * sin) + v2.x
     z = ((v2.z - v1.z) * cos) + ((v1.x - v2.x) * sin) + v2.z
    return Vector(x, v1.y, z or 0)
end

function NechritoBlitzcrank:GetHeroes()
	SearchAllChamp()
	local t = pObjChamp
	return t
end

function NechritoBlitzcrank:GetEnemies(range)
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

function NechritoBlitzcrank:RealDamage(target, damage)

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

function NechritoBlitzcrank:MenuBool(stringKey, bool)
	return ReadIniBoolean(self.menu, stringKey, bool)
end

function NechritoBlitzcrank:MenuSliderInt(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function NechritoBlitzcrank:MenuSliderFloat(stringKey, valueDefault)
	return ReadIniFloat(self.menu, stringKey, valueDefault)
end

function NechritoBlitzcrank:MenuComboBox(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function NechritoBlitzcrank:MenuKeyBinding(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end
