IncludeFile("Lib\\SDK.lua")

class "NechritoTristana"

function NechritoTristana:__init()

  if GetChampName(GetMyChamp()) ~= "Tristana"
  then return end

self.Q = Spell({Slot = 0,
                SpellType = Enum.SpellType.Active})

self.W = Spell({Slot = 1,
                SpellType = Enum.SpellType.SkillShot,
                SkillShotType = Enum.SkillShotType.Circle,
                Range = 900,
                Collision = false,
                Radius = 60})

self.E = Spell({Slot = 2,
                SpellType = Enum.SpellType.Targetted,
                Range = GetTrueAttackRange()
        })

self.R = Spell({Slot = 3,
                SpellType = Enum.SpellType.Targetted,
                Range = GetTrueAttackRange()})

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
AddEvent(Enum.Event.OnDraw, function(...) self:OnDraw(...) end)
AddEvent(Enum.Event.OnAfterAttack, function(...) self:OnAfterAttack(...) end)
AddEvent(Enum.Event.OnBeforeAttack, function(...) self:OnBeforeAttack(...) end)
AddEvent(Enum.Event.OnProcessSpell, function(...) self:OnProcessSpell(...) end)
AddEvent(Enum.Event.OnDrawMenu, function(...) self:OnDrawMenu(...) end)

self:MenuValueDefault()

 __PrintTextGame("<b><font color=\"#C70039\">Nechrito Tristana</font></b> <font color=\"#ffffff\">Loaded. Enjoy the mayhem</font>")
end

function NechritoTristana:MenuValueDefault()

  self.menu = "Nechrito Tristana"

  self.menu_Qcombo = self:MenuBool("Use Q In Combo", true)
  self.menu_Qharass = self:MenuBool("Use Q In Harass", false)
  self.menu_Qlaneclear = self:MenuBool("Use Q In LaneClear", true)
  self.menu_Qjungle = self:MenuBool("Use Q In Jungle", true)


  self.menu_Efocus = self:MenuBool("Focus Enemy With E", true)
  self.menu_Ecombo = self:MenuBool("Use E In Combo", true)
  self.menu_Eharass = self:MenuBool("Use E In Harass", false)
  self.menu_Elaneclear = self:MenuBool("Use E In LaneClear", true)
  self.menu_Ejungle = self:MenuBool("Use E In Jungle", true)

  self.menu_EwhiteList = function()
        local result = {}

        for i = 1, #HeroManager.Enemy do
          local enemy = GetAIHero(HeroManager.Enemy[i])
          result[#result + 1] =
          {
            CharName = enemy.CharName,
            Menu = self:MenuBool("Harass: " .. enemy.CharName, true)
          }
    end
    return result
  end

  self.menu_whitelistComboOnly = self:MenuBool("Combo Only", true)

  self.menu_Rkill = self:MenuBool("OneShot (E + R)", true)
  self.menu_Rinterrupt = self:MenuBool("Interrupt Spells With R", true)

  self.menu_DrawReady = self:MenuBool("Only Draw When Ready", true)
  self.menu_DrawW = self:MenuBool("Draw W Range", false)

  self.menu_SkinEnable = self:MenuBool("Enalble Mod Skin", false)
	self.menu_SkinIndex = self:MenuSliderInt("Skin", 11)

end

function NechritoTristana:Whitelist(unit)

  local WhiteListT = self.menu_EwhiteList()

        for j = 1, #WhiteListT do
          local index = 0

        if WhiteListT[j].CharName == unit.CharName then
            index = j
          end

      if index ~= 0 then
        return WhiteListT[index].Menu
      end
    end
  return false

end

function NechritoTristana:OnDrawMenu()
	if not Menu_Begin(self.menu) then return end

  if Menu_Begin("Q Settings") then
      self.menu_Qcombo = Menu_Bool("Use Q In Combo", self.menu_Qcombo, self.menu)
      self.menu_Qharass = Menu_Bool("Use Q In Harass", self.menu_Qharass, self.menu)
      self.menu_Qlaneclear = Menu_Bool("Use Q In LaneClear", self.menu_Qlaneclear, self.menu)
      self.menu_Qjungle = Menu_Bool("Use Q In Jungle", self.menu_Qjungle, self.menu)
    Menu_End()
  end

  if (Menu_Begin("E Settings")) then
      self.menu_Efocus = Menu_Bool("Focus Enemy With E", self.menu_Efocus, self.menu)
      self.menu_Ecombo = Menu_Bool("Use E In Combo", self.menu_Ecombo, self.menu)
      self.menu_Eharass = Menu_Bool("Use E In Harass", self.menu_Eharass, self.menu)
      self.menu_Elaneclear = Menu_Bool("Use E In LaneClear", self.menu_Elaneclear, self.menu)
      self.menu_Ejungle = Menu_Bool("Use E In Jungle", self.menu_Ejungle, self.menu)
      Menu_End()
  end

  if Menu_Begin("R Settings") then
      self.menu_Rkill = Menu_Bool("OneShot (E + R)", self.menu_Rkill, self.menu)
      self.menu_Rinterrupt = Menu_Bool("Interrupt Spells With R", self.menu_Rinterrupt, self.menu)
    Menu_End()
  end

  if Menu_Begin("Whitelist") then
    self.menu_whitelistComboOnly = Menu_Bool("Ignore During Combo", self.menu_whitelistComboOnly, self.menu)

     local WhiteListT = self.menu_EwhiteList()

      for i = 1, #HeroManager.Enemy do
        local enemy = HeroManager.Enemy[i]

          for j = 1, #WhiteListT do
            local index = 0
              if WhiteListT[j].CharName == GetChampName(enemy) then
                  index = j
                end

               if index ~= 0 then
                 WhiteListT[index].Menu = Menu_Bool("Harass: " .. GetChampName(enemy), WhiteListT[index].Menu, self.menu)
               end
            end
         end
        Menu_End()
      end

  if (Menu_Begin("Drawings")) then
    self.menu_DrawReady = Menu_Bool("Only Draw When Ready", self.menu_DrawReady, self.menu)
    self.menu_DrawW = Menu_Bool("Draw W Range", self.menu_DrawW, self.menu)
    Menu_End()
  end

  self.menu_SkinEnable = Menu_Bool("Enalble Mod Skin", self.menu_SkinEnable, self.menu)
  self.menu_SkinIndex = Menu_SliderInt("Set Skin", self.menu_SkinIndex, 0, 25, self.menu)

end

function NechritoTristana:OnDraw()

  if (self.menu_DrawW) then
      if (self.menu_DrawReady and not self.W:IsReady()) then return end
      pos = Vector(myHero)
      DrawCircleGame(pos.x, pos.y, pos.z, self.W.Range, Lua_ARGB(255, 0, 204, 255))
  end
end

function NechritoTristana:OnUpdate()

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

    for k,v in pairs(self:GetEnemies(GetTrueAttackRange())) do

      if GetOrbMode() == 1 and self.menu_Rkill then

        if  self.R:GetDamage(v) + self:GetEDmg(v) > v.HP
        and self.E:GetDamage(v) < v.HP
        and self.R:CanCast(v) then
          CastSpellTarget(v.Addr, _R)
          end
        end

        if ((GetOrbMode() == 1 and self.menu_Qcombo)
        or  (GetOrbMode() == 3 and self.menu_Qharass))
        then
          self.Q:Cast(v)
        end

        if not self.E:IsReady() then return end

        if (GetOrbMode() == 1 and self.menu_Ecombo)
        or (GetOrbMode() == 3 and self.menu_Eharass)
        then

          if IsValidTarget(v, GetTrueAttackRange()) then

              if self:Whitelist(v) and self.menu_whitelistComboOnly and GetOrbMode() ~= 1 then return end

              CastSpellTarget(v.Addr, _E)
          end
        end
      end
end

function NechritoTristana:OnAfterAttack(unit, target)

  if not unit.IsMe then return end

if (IsJungleMonster(target.Addr) and GetOrbMode() == 4) then

    if self.menu_Ejungle  then
      CastSpellTarget(target.Addr, _E)
    end

    if self.menu_Qjungle then
      self.Q:Cast(target)
    end
end

    if (GetOrbMode() == 4) then

    		if IsTurret(target.Addr)
         then
           if self.menu_Elaneclear then
    			     CastSpellTarget(target.Addr, _E)
          end

          if self.menu_Qlaneclear then
            self.Q:Cast(target)
          end
        end

        for i, minions in ipairs(MinionManager.Enemy) do
            if (minions) then
                minion = GetUnit(minions)

                if minion.IsDead == false
                and GetDistance(Vector(minion), Vector(myHero)) <= 800 then
                -- TODO: ADD LOGIC

                end
            end
        end
    end
end

function NechritoTristana:OnBeforeAttack(target)

  if GetOrbMode() == 3 then
    for k,v in pairs(self:GetEnemies(GetTrueAttackRange())) do

      if v.HasBuff("tristanaecharge") then
          Orbwalker:ForceTarget(t)
      end
    end
  end

  if (GetOrbMode() == 4 and self.menu_Efocus) then

    for i, minions in ipairs(MinionManager.Enemy) do
        if (minions) then
            minion = GetUnit(minions)
            if minion.IsDead == false
            and GetDistance(Vector(minion), Vector(myHero)) <= GetTrueAttackRange()
            and (minion.HasBuff("tristanaecharge") or minion.HasBuff("tristanaechargesound")) then
              Orbwalker:ForceTarget(minion)
        end
      end
    end
  end
end

function NechritoTristana:OnProcessSpell(unit, spell)
  if   unit
   and unit.IsEnemy
   and self.menu_Einterrupt
   and self.listSpellInterrup[spell.Name]
   and self.OnInterruptableSpell
   and IsValidTarget(unit, self.R.Range)
   then
     __PrintTextGame("Tristana INTERRUPTING WITH E")
			self.R:Cast(unit)
	end
end

function NechritoTristana:GetEDmg(target) -- Got this from CTTBOT
	if not target.HasBuff("tristanaecharge") then
		return 0
	end

	return self.E:GetDamage(target) + self.E:GetDamage(target) * 0.3 * (GetBuffStack(target.Addr, "tristanaecharge"))
end

function NechritoTristana:GetEnemies(range)
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

function NechritoTristana:GetHeroes()
	SearchAllChamp()
	local t = pObjChamp
	return t
end

function NechritoTristana:MenuBool(stringKey, bool)
	return ReadIniBoolean(self.menu, stringKey, bool)
end

function NechritoTristana:MenuSliderInt(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function NechritoTristana:MenuSliderFloat(stringKey, valueDefault)
	return ReadIniFloat(self.menu, stringKey, valueDefault)
end

function NechritoTristana:MenuComboBox(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function NechritoTristana:MenuKeyBinding(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

if _G["Nechrito" .. myHero.CharName] then
        DelayAction(function()
                _G["Nechrito" .. myHero.CharName]()
        end, 0.5)
end
