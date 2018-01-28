IncludeFile("Lib\\SDK.lua")

class "NechritoVayne"

function OnLoad()

  if GetChampName(GetMyChamp()) ~= "Vayne"
  then return end

NechritoVayne:__init()
end

function NechritoVayne:__init()

  myHero = GetMyHero()

self.Q = Spell({Slot = 0,
                SpellType = Enum.SpellType.SkillShot,
                Range = 300,
                tumblePosition = nil})

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

  AddEvent(Enum.Event.OnTick, function(...) self:OnTick(...) end)
  AddEvent(Enum.Event.OnUpdateBuff, function(...) self:OnUpdateBuff(...) end)
  AddEvent(Enum.Event.OnRemoveBuff, function(...) self:OnRemoveBuff(...) end)
  AddEvent(Enum.Event.OnDraw, function(...) self:OnDraw(...) end)
  AddEvent(Enum.Event.OnAfterAttack, function(...) self:OnAfterAttack(...) end)
  AddEvent(Enum.Event.OnBeforeAttack, function(...) self:OnBeforeAttack(...) end)
  AddEvent(Enum.Event.OnProcessSpell, function(...) self:OnProcessSpell(...) end)
  AddEvent(Enum.Event.OnDrawMenu, function(...) self:OnDrawMenu(...) end)
  Orbwalker:RegisterPreAttackCallback(function(...)  self:OnPreAttack(...) end)

  self:MenuValueDefault()

   __PrintTextGame("<b><font color=\"#C70039\">Nechrito Vayne</font></b> <font color=\"#ffffff\">Loaded. Enjoy the mayhem</font>")
end

function NechritoVayne:MenuValueDefault()

  self.menu = "Nechrito Vayne"

  self.menu_QtoEPos = self:MenuBool("Q To E Position If Possible", true)
  self.menu_Qcombo = self:MenuBool("Use Q In Combo", true)
  self.menu_Qharass = self:MenuBool("Use Q In Harass", true)
  self.menu_Qlasthit = self:MenuBool("Use Q To Lasthit", true)
  self.menu_Qjungle = self:MenuBool("Use Q In Jungle", true)

  self.menu_Wfocus = self:MenuBool("Focus Target With W Stacks", true)

  self.menu_Eflash = self:MenuKeyBinding("Smart Flash Insec", 84)
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

  self.menu_SkinEnable = self:MenuBool("Enalble Mod Skin", false)
	self.menu_SkinIndex = self:MenuSliderInt("Skin", 11)

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
  self.menu_Eflash = Menu_KeyBinding("Smart Flash Insec (Press T AND Combo)", self.menu_Eflash, self.menu)
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

self.menu_SkinEnable = Menu_Bool("Enalble Mod Skin", self.menu_SkinEnable, self.menu)
self.menu_SkinIndex = Menu_SliderInt("Set Skin", self.menu_SkinIndex, 0, 11, self.menu)

end

function NechritoVayne:OnDraw()

  if (self.menu_DrawE) then
      if (self.menu_DrawReady and not self.E:IsReady()) then return end
      pos = Vector(myHero)
      DrawCircleGame(pos.x, pos.y, pos.z, self.E.Range, Lua_ARGB(255, 0, 204, 255))
  end

  if (self.Q.tumblePosition ~= nil) then
    DrawCircleGame(self.Q.tumblePosition.x, self.Q.tumblePosition.y, self.Q.tumblePosition.z, 60, Lua_ARGB(255, 0, 204, 255))
  end
end

function NechritoVayne:OnTick()

if (IsDead(myHero.Addr)
or myHero.IsRecall
or IsTyping()
or IsDodging())
then return end

SetLuaCombo(true)
SetLuaHarass(true)
SetLuaLaneClear(true)

if self.menu_SkinEnable then
  ModSkin(self.menu_SkinIndex)
end

  if (self.R:IsReady()
  and GetOrbMode() == 1)
  then
    if (CountEnemyChampAroundObject(myHero.Addr, 1000) >= self.menu_Rcount) then
      for k,v in pairs(self:GetEnemies(1000)) do
        if (v.HP < (myHero.CalcDamage(v.Addr, myHero.TotalDmg) * self.menu_Rkillable) and GetDistance(Vector(v), Vector(myHero)) <= 1000) then
          self.R:Cast(v)
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

  if (self:GetFlashIndex() > -1
  and GetKeyPress(self.menu_Eflash) > 0
  and self.E:IsReady()
  and CanCast(self:GetFlashIndex()))
  then
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

  for k,v in pairs(self:GetEnemies(1000)) do

    if (IsValidTarget(v, 600)) then

      targetPos = Vector(v)
      playerPos = Vector(myHero)

      DrawCircleGame(playerPos.x, playerPos.y, playerPos.z,  425, Lua_ARGB(255, 255, 255, 0))

      wallPos = self:GetWallPosition(v, 430)

      if (wallPos) then -- Insec to wall

        insecPos = targetPos + (targetPos - wallPos):Normalized() * 200

        DrawCircleGame(insecPos.x, insecPos.y, insecPos.z,  50, Lua_ARGB(255, 0, 255, 0))

        if (GetDistance(insecPos, playerPos) <= 425) then
          CastSpellTarget(v.Addr, _E)
          DelayAction(function() CastSpellToPos(insecPos.x, insecPos.z, self:GetFlashIndex()) end, 0.1)
        end

      else -- Will try to insec enemy into turret

        GetAllObjectAroundAnObject(v.Addr, 500)
        for k,v in pairs(pObject) do

          if IsTurret(v) and IsAlly(v) and not IsDead(v) then
            turretPos = Vector(GetPos(v))

            insecPos = Vector(targetPos + (targetPos - turretPos):Normalized() * 150)

            DrawCircleGame(insecPos.x, insecPos.y, insecPos.z,  50, Lua_ARGB(255, 0, 255, 0))

            if (GetDistance(Vector(myHero), insecPos) > 425) then return end

              CastSpellTarget(v.Addr, _E)
              DelayAction(function() CastSpellToPos(insecPos.x, insecPos.z, self:GetFlashIndex()) end, 0.1)
            end
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

  for k,v in pairs(self:GetEnemies(1000)) do

    if (IsValidTarget(v, 1500)) then

      targetPos = Vector(v)
      path = Vector(v.GetPath(0))

      time = v.MoveSpeed * 0.425

      posAfterTime = targetPos + (targetPos - path):Normalized() * time -- Target position in 425ms

      for i = 15, 475, 75 do
        final = Vector(posAfterTime + (posAfterTime - Vector(myHero)):Normalized() * i)
        finalT = Vector(targetPos + (targetPos - Vector(myHero)):Normalized() * i)

        if time == 0 then
          finalT = final
        end

        if IsWall(final.x, final.y, final.z) and IsWall(finalT.x, finalT.y, finalT.z) and IsValidTarget(v, self.E.Range) then

          CastSpellTarget(v.Addr, _E)

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

 for k,v in pairs(self:GetEnemies(1000)) do
   if (target ~= v and GetBuffStack(v.Addr, "VayneSilveredDebuff") >= 2) then
      Orbwalker:ForceTarget(v)
   end
 end
end

function NechritoVayne:OnAfterAttack(unit, target)

  if (IsJungleMonster(target.Addr) and GetOrbMode() == 4) then

      if(self.Q:IsReady() and self.menu_Qjungle) then
        self:CastQ(target, false)
    end

    if (self.E:IsReady() and self.menu_Ejungle) then
        CastSpellTarget(target.Addr, _E)
    end
  end

if not (self.Q:IsReady()) then return end

if (GetOrbMode() == 1 and self.menu_Qcombo) then -- Combo
    self:CastQ(target, self.menu_QtoEPos)
end

if (GetOrbMode() == 3 and self.menu_Qharass) then -- Harass
  self:CastQ(target, false)
end

  if (GetOrbMode() == 4 or GetOrbMode() == 2)
  and target ~= nil
  and self.menu_Qlasthit
  then -- Laneclear

    self:GetAAQTarget()
  end
end

function NechritoVayne:GetAAQTarget()

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
                  self:CastQ(minion, false)
              end
          end
      end
  end
end

function NechritoVayne:CastQ(target, force)

  wallPos = self:GetWallPosition(target, 140)

  if (wallPos) then
      self.Q:Cast(wallPos)
  end

  qToEPos = self:GetWallPosition(target, 200)

  if (qToEPos
  and self.E:CanCast(target)
  and force) then

  tPos = Vector(target)
  newPos = Vector(tPos + (tPos - qToEPos):Normalized() * 100)

  if (GetDistance(Vector(myHero), newPos) < self.Q.Range) then
       self.Q:Cast(newPos)
    end
  else

    kitePos = self:GetKitePosition(target, 410)

    if kitePos ~= nil then
      self.Q:Cast(kitePos)
    end
  end
end

function NechritoVayne:GetWallPosition(target, range)
    range = range or 400

    for i= 0, 360, 45 do
        angle = i * math.pi/180
        targetPosition = Vector(GetPos(target))
        targetRotated = Vector(targetPosition.x + range, targetPosition.y, targetPosition.z)
        pos = Vector(self:RotateAroundPoint(targetRotated, targetPosition, angle))

        if IsWall(pos.x, pos.y, pos.z) and GetDistance(Vector(myHero), pos) < range then
            return pos
        end
    end
end

function NechritoVayne:GetKitePosition(target, range)

  for i = 0, 360, 20 do
    angle = i * (math.pi/180)

    targetPosition = Vector(target)
    rot = Vector(targetPosition.x + range, targetPosition.y, targetPosition.z)

    pos = self:RotateAroundPoint(Vector(myHero), rot, angle)
    pos = Vector(myHero) + (Vector(myHero) - pos):Normalized() * self.Q.Range

    dist = GetDistance(targetPosition, pos)

    if dist < range
    or dist > GetTrueAttackRange() + 65 then --__PrintTextGame("NOT VALID")

    else
    --  __PrintTextGame(dist)
     self.Q.tumblePosition = pos
     return pos end
  end
  return nil
end

function NechritoVayne:RotateAroundPoint(v1,v2, angle)
     cos, sin = math.cos(angle), math.sin(angle)
     x = ((v1.x - v2.x) * cos) - ((v2.z - v1.z) * sin) + v2.x
     z = ((v2.z - v1.z) * cos) + ((v1.x - v2.x) * sin) + v2.z
    return Vector(x, v1.y, z or 0)
end

function NechritoVayne:GetHeroes()
	SearchAllChamp()
	local t = pObjChamp
	return t
end

function NechritoVayne:GetEnemies(range)
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
