IncludeFile("Lib\\SDK.lua")

class "NechritoVayne"

function OnLoad()

  if GetChampName(GetMyChamp()) ~= "Vayne"
  then return end

NechritoVayne:__init()
end

function NechritoVayne:__init()

self.Q = Spell({Slot = 0,
                SpellType = Enum.SpellType.SkillShot,
                Range = 300,})

self.W = Spell({Slot = 1,
                SpellType = Enum.SpellType.Active})

self.E = Spell({Slot = 2,
                SpellType = Enum.SpellType.Targetted,
                Range = 550
        })

self.R = Spell({Slot = 3, SpellType = Enum.SpellType.Active, Invisible = false, InvisTick = 0})

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

  AddEvent(Enum.Event.OnUpdate, function(...) self:OnUpdate(...) end)
  AddEvent(Enum.Event.OnUpdateBuff, function(...) self:OnUpdateBuff(...) end)
  AddEvent(Enum.Event.OnRemoveBuff, function(...) self:OnRemoveBuff(...) end)
  AddEvent(Enum.Event.OnDraw, function(...) self:OnDraw(...) end)
  AddEvent(Enum.Event.OnAfterAttack, function(...) self:OnAfterAttack(...) end)
  AddEvent(Enum.Event.OnBeforeAttack, function(...) self:OnBeforeAttack(...) end)
  AddEvent(Enum.Event.OnProcessSpell, function(...) self:OnProcessSpell(...) end)
  AddEvent(Enum.Event.OnDrawMenu, function(...) self:OnDrawMenu(...) end)
  Orbwalker:RegisterPreAttackCallback(function(...)  self:OnPreAttack(...) end)

  self:MenuValueDefault()

   __PrintTextGame("<b><font color=\"#C70039\">Nechrito Vayne</font></b> <font color=\"#ffffff\">Loaded</font>")
   __PrintTextGame("<b><font color=\"#C70039\">Nechrito Vayne</font></b> <font color=\"#ffffff\">Don't forget to: CTRL + NUMPAD 1</font>")
end

function NechritoVayne:MenuValueDefault()

  self.menu = "Nechrito Vayne"

  self.menu_QtoEPos = self:MenuBool("Q To E Position If Possible", true)
  self.menu_Qcombo = self:MenuBool("Use Q In Combo", true)
  self.menu_Qharass = self:MenuBool("Use Q In Harass", true)
  self.menu_Qlasthit = self:MenuBool("Use Q To Lasthit", true)
  self.menu_Qjungle = self:MenuBool("Use Q In Jungle", true)

  self.menu_Wfocus = self:MenuBool("Focus Target With W Stacks", true)

  self.menu_Eflash = self:MenuBool("Smart Flash Insec (Flash E)", true)
  self.menu_Einterrupt = self:MenuBool("Interrupt Spells", true)
  self.menu_Ecombo = self:MenuBool("Use E In Combo", true)
  self.menu_Eharass = self:MenuBool("Use E In Harass", false)
  self.menu_Ejungle = self:MenuBool("Use E In Jungle", false)

  self.menu_Rcount = self:MenuSliderInt("Use R If >= X Enemies Nearby", 3)
  self.menu_Rkillable = self:MenuSliderInt("Only R When Killable By X Autoattacks", 5)
  self.menu_Rdelay = self.MenuSliderInt("Time Until Attack After Stealth", 0)

  self.menu_DrawReady = self:MenuBool("Only Draw When Ready", true)
  self.menu_DrawE = self:MenuBool("Draw E Range", false)
  self.menu_DrawCondemn = self:MenuBool("Draw Condemn (Debug)", true)

end

function NechritoVayne:OnDrawMenu()

if not Menu_Begin(self.menu) then return end

if (Menu_Begin("Q Settings")) then
  self.menu_QtoEPos = Menu_Bool("Q To E Position If Possible", self.menu_QtoEPos, self.menu)
  self.menu_Qcombo = Menu_Bool("Use Q In Combo", self.menu_Qcombo, self.menu)
  self.menu_Qharass = Menu_Bool("Use Q In Harass", self.menu_Qharass, self.menu)
  self.menu_Qlasthit = Menu_Bool("Use Q To Lasthit", self.menu_Qlasthit, self.menu)
  self.menu_Qjungle = Menu_Bool("Use Q In Jungle", self.menu_Qjungle, self.menu)
  Menu_End()
end

if (Menu_Begin("W Settings")) then
  self.menu_Wfocus = Menu_Bool("Focus Target With W Stacks", self.menu_Wfocus, self.menu)
  Menu_End()
end

if (Menu_Begin("E Settings")) then
  self.menu_Eflash = Menu_Bool("Smart Flash Insec (Flash E)", self.menu_Eflash, self.menu)
  self.menu_Einterrupt = Menu_Bool("Interrupt Spells", self.menu_Einterrupt, self.menu)
  self.menu_Ecombo = Menu_Bool("Use E In Combo", self.menu_Ecombo, self.menu)
  self.menu_Eharass = Menu_Bool("Use E In Harass", self.menu_Eharass, self.menu)
  self.menu_Ejungle = Menu_Bool("Use E In Jungle (ALL MOBS, TEMPORARY)", self.menu_Ejungle, self.menu)
  Menu_End()
end

if (Menu_Begin("R Settings")) then
  self.menu_Rcount = Menu_SliderInt("Use R If >= X Enemies Nearby", self.menu_Rcount, 0, 5, self.menu)
  self.menu_Rkillable = Menu_SliderInt("Only R When Killable By X Autoattacks", self.menu_Rkillable, 1, 10, self.menu)
  self.menu_Rdelay = Menu_SliderInt("Time Until Attack After Stealth", self.menu_Rdelay, 0, 1000)
  Menu_End()
end

if (Menu_Begin("Drawings")) then
  self.menu_DrawReady = Menu_Bool("Only Draw When Ready", self.menu_DrawReady, self.menu)
  self.menu_DrawE = Menu_Bool("Draw E Range", self.menu_DrawE, self.menu)
  self.menu_DrawCondemn = Menu_Bool("Draw Condemn (Debug)", self.menu_DrawCondemn, self.menu)
  Menu_End()
end

end

function NechritoVayne:OnDraw()

  if (self.menu_DrawE) then
      if (self.menu_DrawReady and not self.E:IsReady()) then return end
      pos = Vector(myHero)
      DrawCircleGame(pos.x, pos.y, pos.z, self.E.Range, Lua_ARGB(255, 0, 204, 255))
  end
end

function NechritoVayne:OnUpdate()

myHero = GetMyHero()

if (IsDead(myHero.Addr)
or myHero.IsRecall
or IsTyping()
or IsDodging())
then return end

SetLuaCombo(true)
SetLuaHarass(true)
SetLuaLaneClear(true)

  if (self.R:IsReady()
  and GetOrbMode() == 1)
  then
    if (CountEnemyChampAroundObject(myHero.Addr, 1000) >= self.menu_Rcount) then
      for k,v in pairs(self:GetEnemies()) do
        unit = GetAIHero(v)
        if (unit.HP < (myHero.CalcDamage(unit.Addr, myHero.TotalDmg) * self.menu_Rkillable) and GetDistance(Vector(unit), Vector(myHero)) <= 1000) then
          self.R:Cast(unit)
        end
      end
    end
  end

  if (self.E:IsReady()
  and GetOrbMode() == 1 and self.menu_Ecombo)
  or (GetOrbMode() == 3 and self.menu_Eharass)
  then
    self:Condemn()
  end

  if (self:GetFlashIndex() > -1 and self.menu_Eflash and self.E:IsReady()) then
      self:FlashE()
  end

end

function NechritoVayne:OnProcessSpell(unit, spell)
	if   unit
   and unit.IsEnemy
   and self.menu_Einterrupt
   and self.listSpellInterrup[spell.Name]
   and self.OnInterruptableSpell
   and IsValidTarget(unit, self.E.range)
   then
     __PrintTextGame("VAYNE INTERRUPTING WITH E")
			self.E:Cast(unit)
	end
end

function NechritoVayne:FlashE()

  for k,v in pairs(self:GetEnemies()) do
    unit = GetAIHero(v)

    if (IsValidTarget(unit, 600)) then
      GetAllObjectAroundAnObject(unit.Addr, 500)
      for k,v in pairs(pObject) do

        if IsTurret(v) and IsAlly(v) and not IsDead(v) then
          turretPos = Vector(GetPos(v))
          targetPos = Vector(unit)
          insecPos = Vector(targetPos + (targetPos - turretPos):Normalized() * 150)

          playerPos = Vector(myHero)
          DrawCircleGame(insecPos.x, insecPos.y, insecPos.z,  50, Lua_ARGB(255, 0, 255, 0))
          DrawCircleGame(playerPos.x, playerPos.y, playerPos.z,  425, Lua_ARGB(255, 255, 255, 0))

          if (GetDistance(Vector(myHero), insecPos) > 425) then return end

            CastSpellTarget(unit.Addr, _E)
            DelayAction(function() CastSpellToPos(insecPos.x, insecPos.z, self:GetFlashIndex()) end, 0.15)
          end
        end
    end
  end
end

function NechritoVayne:GetFlashIndex()
	if GetSpellIndexByName("SummonerFlash") > -1 then
		return GetSpellIndexByName("SummonerFlash")
  end
	return -1
end

function NechritoVayne:Condemn()

  for k,v in pairs(self:GetEnemies()) do
    unit = GetAIHero(v)

    if (IsValidTarget(unit, 1500)) then

      targetPos = Vector(unit)
      path = Vector(unit.GetPath(0))

      time = unit.MoveSpeed * 0.425

      posAfterTime = targetPos + (targetPos - path):Normalized() * time -- Target position in 425ms

      for i = 15, 475, 75 do
        final = Vector(posAfterTime + (posAfterTime - Vector(myHero)):Normalized() * i)
        finalT = Vector(targetPos + (targetPos - Vector(myHero)):Normalized() * i)

        if time == 0 then
          finalT = final
        end

        if IsWall(final.x, final.y, final.z) and IsWall(finalT.x, finalT.y, finalT.z) and IsValidTarget(unit, self.E.Range) then

          CastSpellTarget(unit.Addr, _E)

          if (self.menu_DrawCondemn) then
            DrawCircleGame(finalT.x, finalT.y, finalT.z, 100, Lua_ARGB(255, 0, 255, 0))
            DrawCircleGame(final.x, final.y, final.z,    80, Lua_ARGB(255, 0, 255, 0))
          end


        elseif (self.menu_DrawCondemn) then
          DrawCircleGame(finalT.x, finalT.y, finalT.z, i / 10, Lua_ARGB(255, 255, 0, 0))
          DrawCircleGame(final.x, final.y, final.z,    i / 10, Lua_ARGB(255, 255, 0, 0))
        end
      end
    end
  end
end

function NechritoVayne:OnUpdateBuff(source, unit, buff, stacks)

  if string.lower(buff.Name) == "vaynetumblefade" and unit.IsMe then
    self.R.Invisible = true
    self.R.InvisTick = GetTickCount()
  end
end

function NechritoVayne:OnRemoveBuff(unit, buff)

  if string.lower(buff.Name) == "vaynetumblefade" and unit.IsMe then
    self.R.Invisible = false
  end
end

function NechritoVayne:OnPreAttack(args)

  if not self.R.Invisible then return end

  if (GetTickCount() - self.R.InvisTick <= self.menu_Rdelay) then
    args.Process = false
  end
end

function NechritoVayne:OnBeforeAttack(target)

 if (GetOrbMode() ~= 1 and GetOrbMode() ~= 3)
 then return end

 for k,v in pairs(self:GetEnemies()) do
   t = GetAIHero(v)
   if (target ~= t and GetBuffStack(t.Addr, "VayneSilveredDebuff") >= 2) then
      Orbwalker:ForceTarget(t)
      --SetForcedTarget(obj)
   end
 end
end

function NechritoVayne:OnAfterAttack(unit, target)

  if (IsJungleMonster(target.Addr) and GetOrbMode() == 4) then

      if(self.Q:IsReady() and self.menu_Qjungle) then
        self:CastQ(target, true)
    end

    if (self.E:IsReady() and self.menu_Ejungle) then
        CastSpellTarget(target.Addr, _E)
    end
  end

if not (self.Q:IsReady()) then return end

targ = GetAIHero(target)

if (GetOrbMode() == 1 and self.menu_Qcombo) then -- Combo
    self:CastQ(targ, self.menu_QtoEPos)
end

if (GetOrbMode() == 3 and self.menu_Qharass) then -- Harass
  self:CastQ(targ, false)
end

  if (GetOrbMode() == 4 or GetOrbMode() == 2
  and target ~= nil
  and self.menu_Qlasthit)
--  and myHero.CalcDamage(target, myHero.TotalDmg) > target.HP)
  then -- Laneclear

    self:GetAAQTarget(unit)
  end
end

function NechritoVayne:GetAAQTarget(target)

  for i, minions in ipairs(MinionManager.Enemy) do
      if (minions) then
          minion = GetUnit(minions)

          if minion.IsDead == false and minion.Addr ~= target.Addr and GetDistance(Vector(minion), Vector(myHero)) <= 800 then
              if (myHero.CalcDamage(minion, myHero.TotalDmg) + self.Q:GetDamage(minion) > minion.HP)
              then
                  self:CastQ(minion, false)
              end
          end
      end
  end
end

function NechritoVayne:CastQ(target, force)

  wallPos = self:GetWallPosition(target, 130)

  if (wallPos) then
      self.Q:Cast(wallPos)
  end

  qToEPos = self:GetWallPosition(target, 200)

  if (qToEPos
  and self.E:IsReady()
  and force) then

  tPos = Vector(target)
  newPos = Vector(tPos + (tPos - qToEPos):Normalized() * 100)

  if (GetDistance(Vector(myHero), newPos) < self.Q.Range) then
       self.Q:Cast(newPos)
    end
  else
  kitePos = self:GetKitePosition(target, 400)
  self.Q:Cast(kitePos)
  end
end

function NechritoVayne:RotateAroundPoint(v1,v2, angle)
    local cos, sin = math.cos(angle), math.sin(angle)
    local x = ((v1.x - v2.x) * cos) - ((v2.z - v1.z) * sin) + v2.x
    local z = ((v2.z - v1.z) * cos) + ((v1.x - v2.x) * sin) + v2.z
    return Vector(x, v1.y, z or 0)
end

function NechritoVayne:GetWallPosition(target, range)
    range = range or 400

    for i=0, 360, 20 do
        local angle = i * math.pi/180
        local pos = Vector(self:RotateAroundPoint(Vector(target.x + range, target.y, target.z + range), target, angle))
        if IsWall(pos.x, pos.y, pos.z) then
            return pos
        end
    end
end

function NechritoVayne:GetKitePosition(target, range)
  range = range or 400

  for i = 0, 360, 20 do
    angle = i * math.pi / 180
    pos = self:RotateAroundPoint(Vector(target.x + range, target.y, target.z), target, angle)

    if (self:EnemyHeroesAroundPosition(pos, range) == 0) then
      return pos
    end
  end
end

function NechritoVayne:EnemyHeroesAroundPosition (position, range)
  local n = 0
  GetAllUnitAroundAnObject(myHero.Addr, 1000) -- Not optimised

  for k, v in pairs(pUnit) do
      unit = GetAIHero(v)
      if GetType(unit) == 0
      and IsValidTarget(unit, 600)
      and IsEnemy(unit) then
        local objectPos = Vector(unit)
          if (GetDistance(position, objectPos) <= range) then
            n = n + 1
          end
      end
  end
  return n
end

function NechritoVayne:GetHeroes()
	SearchAllChamp()
	local t = pObjChamp
	return t
end

function NechritoVayne:GetEnemies()
	t = {}

	for k,v in pairs(self:GetHeroes()) do
		if IsEnemy(v) and IsChampion(v) then
			table.insert(t, v)
		end
	end
	return t
end

function NechritoVayne:MenuBool(stringKey, bool)
	return ReadIniBoolean(self.menu, stringKey, bool)
end

function NechritoVayne:MenuSliderInt(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function NechritoVayne:MenuSliderFloat(stringKey, valueDefault)
	return ReadIniFloat(self.menu, stringKey, valueDefault)
end

function NechritoVayne:MenuComboBox(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function NechritoVayne:MenuKeyBinding(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end
