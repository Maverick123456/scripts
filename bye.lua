_G.UPDATE_RIVEN_BME = false

if myHero.charName ~= "Riven" then return end

_G.version               = "1.53"
local version = "1.53"

local menu = nil
-------Variables-------
local myPlayer                                               =  GetMyHero()
local Passive, temUltimate, UsandoHP                         =  false, false, false
local TickTack, qTick, lTick, rTick, jTick, shieldTick       =  0, 0 ,0, 0, 0, 0
local Target                                                 =  nil
local lastAttack, lastWindUpTime, lastAttackCD, lastAniQ     =  0, 0, 0, 0
local IgniteSpell                                            =  {spellSlot = "SummonerDot", slot = nil, range = 600, ready = false}
local BarreiraSpell                                          =  {spellSlot = "SummonerBarrier", slot = nil, range = 0, ready = false}
local SmiteSpell                                             =  {spellSlot = "Smite", slot = nil, range = 0, ready = false}
local qCount, countTick                                      =  0, 0
local lockIgnite                                             =  false
-------BENCHMARK Variables-------
local PassiveIndicator, temSlow                              =  0, false
local tock                                                   =  0
local vp, Jungle, enemyMinions                               =  nil, nil, nil
local teveAA                                                 =  false
local Jungle                                                  = nil
local JungleLaneMinion                                       = nil
--------------------------------
local LOADED                                                 = false
local ts                                                     = nil
local enemyMinions1      =   minionManager(MINION_ENEMY, 875, myPlayer, MINION_SORT_HEALTH_ASC)
local Jungle                 = minionManager(MINION_JUNGLE, 550, myPlayer, MINION_SORT_MAXHEALTH_DEC)
local minionLane         =    nil
--------------------------------






-----Combos
local lockE = false


function OnLoad()
 LoadFullMenu()
end
--------------------------

function _AutoupdaterMsg(msg)
    print("<font color=\"#00F7EC\"><b>Riven, Boost My Elo:</b></font> <font color=\"#FFFFFF\">"..msg..".</font>") 
end

function UpdateScript()
-- this is easily overridden just fyi, make sure you have important init stuff in kek4
--if not LOADED then return end
local UPDATE_HOST           = "jus-bol.com"
local UPDATE_PATH           = "/scripts/RivenPaid/script/rivenmyelo.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH      = SCRIPT_PATH.."rivenmyelo.lua"
local UPDATE_URL            = "http://"..UPDATE_HOST..UPDATE_PATH

if UPDATE_RIVEN_BME then

    local ServerData = GetWebResult(UPDATE_HOST, "/scripts/RivenPaid/version/RivenPaid.version")
    if ServerData then
        ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil
        if ServerVersion then
            if tonumber(version) < ServerVersion then
                _AutoupdaterMsg("New version available"..ServerVersion)
                _AutoupdaterMsg("Updating from jus-bol.com, please dont press F9")
                DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () _AutoupdaterMsg("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 3)
            else
               _AutoupdaterMsg("You have got the latest version ("..ServerVersion..")")
            end
        end
    else
        _AutoupdaterMsg("Error downloading version info! (jus-bol.com)")
    end
end
end

-- local x, y, y2  = 0 ,0, 0
-- function GetPositionToText()
--   if not _ENV[r({107,101,107,118,97,108,56,51,52})] then return end -- this is easily overridden just fyi, make sure you have important init stuff in kek4
--   local gameSettings  = GetGameSettings()
--   local x             = gameSettings.General.Width  
--   local y             = gameSettings.General.Height
--   local realY         = nil       
--   local hud           = ReadIni(GAME_PATH .. "DATA\\menu\\hud\\hud" .. x .. "x" .. y .. ".ini")
--   local hudScale      = hud.Globals.GlobalScale
--     if hud and hudScale then
--       realY = (y/1080)*hudScale
--     else
--       realY = (y/1080)
--     end
--     return x, realY, y 
-- end

function LoadFullMenu()
--if not _G[c({106,100,107,110,109,118})] then return end    
    menu = scriptConfig("Riven by Jus", "RivenOmfg")    
    MenuCombo() --skills and combo key
    --MenuSpell() --multi skill / OnProcessSpell settings
    MenuExtraCombo()    --NoAACombo, items in combo, ignite if killable
    MenuExtraComboOthers()
    MenuExtraComboRange()
    MenuExtraComboBuff()
    MenuFarm()  --farm sttuff       
    MenuExtra() --potions/barrier
    MenuDraw()  --draw ranges   
    MenuSystem()--orbwalk/sida/mma
    Others()    --others
    PermaMenu()
    --x, y, y2 = GetPositionToText()
    --GetTargetTable()    
    LOADED = true   
    UpdateScript()
end


function Spell()
  local summonerTable = {SUMMONER_1, SUMMONER_2}
  local spells_   = {IgniteSpell, BarreiraSpell, SmiteSpell}
  for i=1, #summonerTable do
    for a=1, #spells_ do
      if myPlayer:GetSpellData(summonerTable[i]).name:find(spells_[a].spellSlot) then 
        spells_[a].slot = summonerTable[i]
      end
    end
  end
end

function Others()   
    menu:addParam("Version", "Version Info:", SCRIPT_PARAM_INFO, version)
    Spell()
    --vp                     = VPrediction()    
    menu.combo.key         = false
    menu.combo.skills.r    = true
    ts                     = TargetSelector(TARGET_LOW_HP, 1000 , DAMAGE_PHYSICAL)
    
    ts.name                = "Riven TS"
    menu:addTS(ts)
    PrintChat("<font color=\"#00F7EC\"><b>Riven, Boost My Elo by</b></font><font color=\"#FFFFFF\"><b> Jus </b></font><font color=\"#00F7EC\"><b> loaded.</b></font> ")
end

function MenuCombo()
    menu:addSubMenu("[Combo System]", "combo")
    menu.combo:addSubMenu("[Skills Settings]", "skills")
    menu.combo.skills:addParam("q", "Use (Q) in Combo", SCRIPT_PARAM_ONOFF, true)
    menu.combo.skills:addParam("w", "Use (W) in Combo", SCRIPT_PARAM_ONOFF, true)
    menu.combo.skills:addParam("e", "Use (E) in Combo", SCRIPT_PARAM_ONOFF, true)
    menu.combo.skills:addParam("r", "Use (R) in Combo", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("S"))   
    menu.combo:addParam("key", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
    --menu.combo:addParam("key2", "test", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("J"))
end

-- function MenuSpell()
--     menu.combo:addSubMenu("[Multi-Skill System]", "multi")
--     menu.combo.multi:addParam("qe", "Try (Q-E) in Combo", SCRIPT_PARAM_ONOFF, true)
--     menu.combo.multi:addParam("ew", "Try (E-W) in Combo", SCRIPT_PARAM_ONOFF, true)
--     menu.combo.multi:addParam("qr", "Try (Q-R) in Combo", SCRIPT_PARAM_ONOFF, true)
--     menu.combo.multi:addParam("er", "Try (E-R) in Combo", SCRIPT_PARAM_ONOFF, true)
-- end

function MenuExtraCombo()
  menu:addSubMenu("[Extra Combo System]", "comboextra")
  -- menu.comboextra:addParam("", "[Triple Q-AA Settings]", SCRIPT_PARAM_INFO, "")
  -- --menu.comboextra:addParam("mode", "Delay Mode:", SCRIPT_PARAM_LIST, 2, { "Manual", "Auto"})
  -- --menu.comboextra:addParam("delay", "Manual Mode Delay:", SCRIPT_PARAM_SLICE, 1, 0, 4, 0)
  -- menu.comboextra:addParam("speed", "Try Speed up Q-AA", SCRIPT_PARAM_ONOFF, true)
  menu.comboextra:addParam("", "", SCRIPT_PARAM_INFO, "")
  menu.comboextra:addParam("", "[(W) Settings]", SCRIPT_PARAM_INFO, "")
  menu.comboextra:addParam("items", "Use Items after (W)", SCRIPT_PARAM_ONOFF, true)
  menu.comboextra:addParam("autow", "Auto (W) if # enemys >=", SCRIPT_PARAM_SLICE, 2, 1, 4, 0)
  menu.comboextra:addParam("", "", SCRIPT_PARAM_INFO, "")
  menu.comboextra:addParam("", "[Ultimate Settings]", SCRIPT_PARAM_INFO, "")
  menu.comboextra:addParam("", "-First (R) Settings-", SCRIPT_PARAM_INFO, "")
  menu.comboextra:addParam("firstRmode", "Settings mode:", SCRIPT_PARAM_LIST, 2, {"# Enemys", "Main Health", "Range", "ALL"})
  menu.comboextra:addParam("autostartRnumber", "(R) if enemys # >=", SCRIPT_PARAM_SLICE, 1, 1, 4, 0)    
  menu.comboextra:addParam("autostartRhealth", "Main Target Health", SCRIPT_PARAM_SLICE, 65, 10, 100, 0)    
  menu.comboextra:addParam("autostartRrange", "Range to Main Target", SCRIPT_PARAM_SLICE, 400, 125, 550, 0)
  menu.comboextra:addParam("", "-Second (R) Settings-", SCRIPT_PARAM_INFO, "")
  menu.comboextra:addParam("secondRmode", "Mode:", SCRIPT_PARAM_LIST, 2, {"Max Damage", "To Kill"} )
  menu.comboextra:addParam("ksultimate", "Try KS with (R)", SCRIPT_PARAM_ONOFF, true)
  --menu.comboextra:addParam("nKsultimate", "Use KS (R) if # enemys >=", SCRIPT_PARAM_SLICE, 2, 1, 4, 0)
  --menu.comboextra:addParam("ultlogic", "Use (R) Team fight logic", SCRIPT_PARAM_ONOFF, true)
  -- menu.comboextra:addParam("", "", SCRIPT_PARAM_INFO, "")    
  -- menu.comboextra:addParam("", "[Force Passive Settings]", SCRIPT_PARAM_INFO, "")
  -- menu.comboextra:addParam("q", "Packet Passive with (Q)", SCRIPT_PARAM_ONOFF, false)
  -- menu.comboextra:addParam("w", "Packet Passive with (W)", SCRIPT_PARAM_ONOFF, false)
  -- menu.comboextra:addParam("e", "Packet Passive with (E)", SCRIPT_PARAM_ONOFF, false)
end

function MenuExtraComboOthers()
    menu.comboextra:addSubMenu("[Others Settings]", "others")
    menu.comboextra.others:addParam("", "[General Settings]", SCRIPT_PARAM_INFO, "")
    menu.comboextra.others:addParam("smart", "Use Smart Combo", SCRIPT_PARAM_ONOFF, false)    
    menu.comboextra.others:addParam("ignite", "Use Smart Ignite", SCRIPT_PARAM_ONOFF, true)
    menu.comboextra.others:addParam("targetrange", "Range to Auto Target", SCRIPT_PARAM_SLICE, 820, 550, 1000, 0)
    --menu.comboextra.others:addParam("aarange", "Advanced Calc to AA", SCRIPT_PARAM_ONOFF, true)
    menu.comboextra.others:addParam("combatAssist", "Use Combat Assist", SCRIPT_PARAM_ONOFF, false)
    menu.comboextra.others:addParam("evadeeE", "Try Evade with (E)", SCRIPT_PARAM_ONOFF, false)
end

function MenuExtraComboRange()
    menu.comboextra:addSubMenu("[Custom Ranges]", "range")    
    menu.comboextra.range:addParam("useNew", "Range Mode (gap closer)", SCRIPT_PARAM_LIST, 1, { "E", "Q", "Custom" })
    menu.comboextra.range:addParam("", "- (Q) Settings -", SCRIPT_PARAM_INFO, "")
    menu.comboextra.range:addParam("startq", "Range to Engage", SCRIPT_PARAM_SLICE, 550, 275, 825, 0)
    menu.comboextra.range:addParam("", "- (W) Settings -", SCRIPT_PARAM_INFO, "")   
    menu.comboextra.range:addParam("startw", "Range to Stun", SCRIPT_PARAM_SLICE, 280, 150, 285, 0)
    menu.comboextra.range:addParam("", "- (E) Settings -", SCRIPT_PARAM_INFO, "") 
    menu.comboextra.range:addParam('starte1', "Range to Engage", SCRIPT_PARAM_SLICE, 425, 250, 500, 0)
end

function MenuExtraComboBuff()
  menu.comboextra:addSubMenu("[Custom Delays to Buff]", "buff")
  menu.comboextra.buff:addParam("use", "Use Custom Delays", SCRIPT_PARAM_ONOFF, false)
  menu.comboextra.buff:addParam("q", "(Q) delay (s) to next cast", SCRIPT_PARAM_SLICE, 1, 1, 4, 0)  
  menu.comboextra.buff:addParam("r", "(R) delay (s) to second cast", SCRIPT_PARAM_SLICE, 13, 1, 14, 0)
end

function MenuFarm()
    menu:addSubMenu("[Farm System]", "farm")
    menu.farm:addParam("lasthit", "Last Hit Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
    menu.farm:addParam("lineclear", "Lane/Jungle Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
    --menu.farm:addParam("clearjungle", "Jungle Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
    --menu.farm:addParam("shieldfarm", "Last hit with Shield", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("G"))
    menu.farm:addSubMenu("[Extra Settings]", "extrafarm")
    menu.farm.extrafarm:addParam("lanesettings", "[Lane/JungleClear]", SCRIPT_PARAM_INFO, "")
    menu.farm.extrafarm:addParam("lanemode", "Lane/Jungle Mode", SCRIPT_PARAM_LIST, 2, { "Free Walk", "Auto Walk"})
    menu.farm.extrafarm:addParam("qlane", "Use (Q)", SCRIPT_PARAM_ONOFF, true)
    menu.farm.extrafarm:addParam("wlane", "Use (W)", SCRIPT_PARAM_ONOFF, true)
    menu.farm.extrafarm:addParam("elane", "Use (E)", SCRIPT_PARAM_ONOFF, true)    
    -- menu.farm.extrafarm:addParam("junglemode", "Jungle Mode:", SCRIPT_PARAM_LIST, 2, { "Free Walk", "Auto Walk"})
    -- menu.farm.extrafarm:addParam("jungles", "[Jungle Skills]", SCRIPT_PARAM_INFO, "")
    -- menu.farm.extrafarm:addParam("q", "Use (Q) in Jungle", SCRIPT_PARAM_ONOFF, true)
    -- menu.farm.extrafarm:addParam("w", "Use (w) in Jungle", SCRIPT_PARAM_ONOFF, true)
    -- menu.farm.extrafarm:addParam("e", "Use (E) in Jungle", SCRIPT_PARAM_ONOFF, true)
    menu.farm.extrafarm:addParam("smiteJ", "Use Smite", SCRIPT_PARAM_ONOFF, true)
    menu.farm.extrafarm:addParam("", "", SCRIPT_PARAM_INFO, "")
    -- menu.farm.extrafarm:addParam("", "[Delay To Cast]", SCRIPT_PARAM_INFO, "")
    -- menu.farm.extrafarm:addParam("qdelay", "(Q) delay", SCRIPT_PARAM_SLICE, 0, 0, 1, 1)
    -- menu.farm.extrafarm:addParam("wdelay", "(W) delay", SCRIPT_PARAM_SLICE, 0, 0, 1, 1)
    -- menu.farm.extrafarm:addParam("edelay", "(E) delay", SCRIPT_PARAM_SLICE, 1, 0, 1, 1)
    menu.farm.extrafarm:addParam("delay", "Extra Delay to Hit Minions", SCRIPT_PARAM_SLICE, 360, -300, 2000, 0)
end

function MenuExtra()
    menu:addSubMenu("[Others System]", "extra")
    menu.extra:addParam("systemextra", "Use Extra System", SCRIPT_PARAM_ONOFF, true)
    menu.extra:addParam("hp", "Auto HP Potion if Health < %", SCRIPT_PARAM_SLICE, 70, 0, 90, 0)
    menu.extra:addParam("elixirhp", "Auto Elixir if Health < %", SCRIPT_PARAM_SLICE, 70, 0, 90, 0)
    menu.extra:addParam("barrier", "Auto Barrier if Health < %", SCRIPT_PARAM_SLICE, 40, 0, 90, 0)
    menu.extra:addParam("eTurret", "Auto (E) if get Aggro by Turret", SCRIPT_PARAM_ONOFF, true)
    menu.extra:addParam("", "", SCRIPT_PARAM_INFO, "")    
    menu.extra:addParam("jump", "Jump Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
    menu.extra:addParam("run", "Run Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
    menu.extra:addParam("", "[Harass Settings]", SCRIPT_PARAM_INFO, "")
    menu.extra:addParam("harassMode", "Harass Mode:", SCRIPT_PARAM_LIST, 1, {"Q", "E"})   
    menu.extra:addParam("hQ", "Use (Q) in Harass", SCRIPT_PARAM_ONOFF, true)
    menu.extra:addParam("hW", "Use (W) in Harass", SCRIPT_PARAM_ONOFF, true)
    menu.extra:addParam("hE", "Use (E) in Harass", SCRIPT_PARAM_ONOFF, true)
    menu.extra:addParam("harass", "Harass Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("M"))
end

function MenuDraw()
    menu:addSubMenu("[Draw System]", "draw")        
    menu.draw:addParam("Q", "Draw (Q) range", SCRIPT_PARAM_ONOFF, false)
    menu.draw:addParam("W", "Draw (W) range", SCRIPT_PARAM_ONOFF, true)
    menu.draw:addParam("E", "Draw (E) range", SCRIPT_PARAM_ONOFF, true)
    menu.draw:addParam("R", "Draw (R) range", SCRIPT_PARAM_ONOFF, false)   
    menu.draw:addParam("spots", "[Draw Jump Spots]", SCRIPT_PARAM_ONOFF, false)
    menu.draw:addParam("castpos", "Cast Position Circle", SCRIPT_PARAM_ONOFF, false)
    menu.draw:addParam("from", "Destination Circle", SCRIPT_PARAM_ONOFF, false)   
    menu.draw:addParam("", "[Others]", SCRIPT_PARAM_INFO, "")
    menu.draw:addParam("passivecount", "Draw Passive Count", SCRIPT_PARAM_ONOFF, false)
    menu.draw:addParam("qtimer", "(Q) Timer", SCRIPT_PARAM_ONOFF, true)
    menu.draw:addParam("", "- Target Draw -", SCRIPT_PARAM_INFO, "")
    menu.draw:addParam("target", "Draw Target", SCRIPT_PARAM_ONOFF, true)
    menu.draw:addParam("targeteng", "(Q) Engage Range", SCRIPT_PARAM_ONOFF, true)
    menu.draw:addParam("targettext", "Draw Text in Target", SCRIPT_PARAM_ONOFF, true)
    --menu.draw:addParam("damageWithR", "Advanced Calc with (R) bonus", SCRIPT_PARAM_ONOFF, false)
    menu.draw:addParam("refreshtime", "Refresh Time (s) Text", SCRIPT_PARAM_SLICE, 1, 1, 5, 0)
    menu.draw:addParam("", "- Minions Draw -", SCRIPT_PARAM_INFO, "")
    menu.draw:addParam("minionL", "Draw Last Hit Minion", SCRIPT_PARAM_ONOFF, true)
    menu.draw:addParam("minionJ", "Draw Jungle Minion", SCRIPT_PARAM_ONOFF, true)
    menu.draw:addParam("minionC", "Draw Lane Minion", SCRIPT_PARAM_ONOFF, true)
end


function MenuSystem()
  menu:addSubMenu("[General System]", "system")
  menu.system:addParam("", "[Orbwalk Settings]", SCRIPT_PARAM_INFO, "")
  menu.system:addParam("orb", "Enable Jus Orbwalk", SCRIPT_PARAM_ONOFF, true)
  --menu.system:addParam("orbsens", "Jus's Orb Sensitivity", SCRIPT_PARAM_SLICE, 1, 1, 5, 0)
  menu.system:addParam("sida", "Enable Reborn/MMA support", SCRIPT_PARAM_ONOFF, true)
  --menu.system:addParam("evadeee", "Use Evadeee support", SCRIPT_PARAM_ONOFF, true)
 -- menu.system:addParam("selector", "Use Selector support (need Reload)", SCRIPT_PARAM_ONOFF, false)
  menu.system:addParam("tsMode", "Target Mode:", SCRIPT_PARAM_LIST, 2 , { "Built In", "Target Selector"} )
  menu.system:addParam("", "[Packet Settings]", SCRIPT_PARAM_INFO, "")
  menu.system:addParam("packet", "Use Packet", SCRIPT_PARAM_ONOFF, true)
  menu.system:addParam("pType", "Animation Cancel Mode", SCRIPT_PARAM_LIST, 3, {"Dance", "Laugh", "Movement"})
  --menu.system:addParam("autoPacket", "Detect (AA) with Packet", SCRIPT_PARAM_ONOFF, false)
  --menu.system:addParam('mov', "Use Movement", SCRIPT_PARAM_ONOFF, false)
  menu.system:addParam("noface", "Try exploit (Q) in Smart Combo", SCRIPT_PARAM_ONOFF, false) -- add packet cast in Q in smart combo.
  --menu.system:addSubMenu("[VPrediction Settings]", "vpred")
  -- menu.system.vpred:addParam("use", "Use VPrediction", SCRIPT_PARAM_ONOFF, false)
  -- --menu.system.vpred:addParam("qpred", "(Q) with VPrediction", SCRIPT_PARAM_ONOFF, true)
  -- --menu.system.vpred:addParam("qhitchance", "(Q) Hit Chance", SCRIPT_PARAM_SLICE, 2, 0, 5, 0)
  -- menu.system.vpred:addParam("rpred", "(R) with VPrediction", SCRIPT_PARAM_ONOFF, false)
  -- menu.system.vpred:addParam("rhitchance", "(R) Hit Chance", SCRIPT_PARAM_SLICE, 2, 0, 5, 0)
  -- menu.system.vpred:addParam("rlogic", "Use (R) VPred Teamfight Logic", SCRIPT_PARAM_ONOFF, false)    
end

-- function OnUnload()
--  --if not _ENV[r({107,101,107,118,97,108,56,51,52})] then return end -- this is easily overridden just fyi, make sure you have important init stuff in kek4
--   if menu.system.selector then useSelector = true end
--   if not menu.system.selector then useSelector = false end
-- end

function PermaMenu()
    menu.combo.skills:permaShow("r")
end

function GetCustomRange(spell)
  local userange  = menu.comboextra.range.useNew
  local nQ    = 550
  local nW    = 125
  local nE    = 425
  if userange == 3 then
    -- local startq_  = menu.comboextra.range.startq
    -- local startw_  = menu.comboextra.range.startw
    -- local starte_  = menu.comboextra.range.starte
    if spell == _Q then return menu.comboextra.range.startq end
    if spell == _W then return menu.comboextra.range.startw end
    if spell == _E then return menu.comboextra.range.starte1 end
  elseif userange == 2 then   
    if spell == _Q then return nQ end
    if spell == _W then return nW end
    if spell == _E then return nE end   
  elseif userange == 1 then
    if spell == _Q and myPlayer:CanUseSpell(_E) == NOTLEARNED or myPlayer:CanUseSpell(_E) == COOLDOWN or not menu.combo.e then return nQ elseif spell == _Q then return 275 end
    if spell == _W then return nW end
    if spell == _E and myPlayer:CanUseSpell(_Q) == COOLDOWN then return nQ elseif spell == _E and myPlayer:CanUseSpell(_Q) == READY then return nE end
  end
end

function GetBuffDelay(spell)
  local use_  = menu.comboextra.buff.use
  if use_ then
    if spell == _Q then return (menu.comboextra.buff.q*1000) + GetLatency()/2 end
    if spell == _R then return (menu.comboextra.buff.r*1000) + GetLatency()/2 end
  else
    if spell == _Q then return 1000 + GetLatency()/2 end
    if spell == _R then return 13000 + GetLatency()/2 end
  end
end

function getTrueRange()
     return myPlayer.range + GetDistance(myPlayer.minBBox)
end

function EnemyInRange(enemy, range)
         if ValidBBoxTarget(enemy, range) then
                return true
        end
    return false
 end

function getHitBoxRadius(hero_)
    return GetDistance(hero_.minBBox, hero_.maxBBox)/2
end

function ThisIsReal(myTarget) -- < myPlayer.range    
    local range = GetDistance(myTarget) - getHitBoxRadius(myTarget) - getHitBoxRadius(myPlayer)
    return range
end

function RangeWithUltimate()
    local myRange = myPlayer.range
    if temUltimate then
        return myRange + 75
    else
        return myRange
    end
    return myRange
end

-- local function DelayCalc()
--  local mode    = menu.comboextra.mode
--  local mDelay  = menu.comboextra.delay
--  if mode == 1 then
--    return mDelay
--  end
--  if mode == 2 then
--    local Total = (1/myPlayer.attackSpeed) - GetLatency()/2000 --seconds
--    return Total
--  end
-- end

local packetTick = 0
local lockPacket = false

function PacketCast(spell, param1, param2)
        if spell ~= nil then
                
                if param1 ~= nil and param2 ~= nil then
                        Packet("S_CAST", {spellId = spell, toX = param1, toY = param2, fromX = param1, fromY = param2}):send()
                elseif param1 ~= nil and param2 == nil then
                        Packet("S_CAST", {spellId = spell, targetNetworkId = param}):send()
                elseif param1 == nil and param2 == nil then
                        Packet("S_CAST", {spellId = spell}):send()
                end
                --Animation Cancel
                -- if spell == _Q or spell == _W or spell == _E or spell == _R then
                --         DelayAction(function() Emote() end, 0)
                -- end
                -- if spell == hydraslot or spell == tiaslot then
                --         if wready then DelayAction(function() PacketCast(_W) end, 0) end
                -- end
        end
end
local newPos = nil
function SendQ()

        -- if Target ~= nil and ThisIsReal(Target) <= myPlayer.range then
        --   PacketCast(_Q, myPlayer.x, myPlayer.z) 
        --   print("me")
        if Target ~= nil then
          CastSpell(_Q, Target.visionPos.x, Target.visionPos.z)
          --lastAttackCD = 0
          Packet('S_MOVE', { type = 3, x = Target.visionPos.x, y = Target.visionPos.z, targetNetworkId = Target.networkID}):send()

                --local delay = .22 + GetLatency()/2000
                --local pos = vp:GetPredictedPos(Target, 0.21)
                --newPos    =   Target + (Vector(myPlayer) - Target):normalized()* ((ThisIsReal(Target)+myPlayer.range)*-1)
               --print('teste vector')
                --PacketCast(_Q, Target.visionPos.x, Target.visionPos.z)
                --print(' Send Q')

                --newPos = nil

        end
end


--_G.Packet.headers.S2C_PlayVOAudioEvent = 0x44
function OnRecvPacket(p)
  
  --if p.header == Packet.headers.S2C_PlayVOAudioEvent then p:Block() end
  if not menu.combo.key or not menu.system.packet or not Target then return end

  if p.header == 0x64 then
    --print(DumpPacketData(p))    
    p.pos = 1
    if p:DecodeF() ~= Target.networkID then return end -- target
   -- print(DumpPacketData(p))

    local type = p:Decode1() -- type
    p.pos = p.pos + 4
    if p:DecodeF() ~= myHero.networkID then return end -- source
   
    if type == 0x0C then SendQ()
    elseif type == 0x04 and menu.extra.systemextra then CastCommonItem(Target) 
    end
    return -- I do this because multiple if statement for p.header looks better then if/elseif/elseif...
  end
  
  --if p.header == 0x86 and GetDistance(Target) <= myPlayer.range then Packet('S_MOVE', { type = 3, x = Target.visionPos.x, y = Target.visionPos.z, targetNetworkId = Target.networkID}):send() return end

end

-- function OnRecvPacket(p)
--   if not _G[c({106,100,107,110,109,118})] then return end
--   if not menu.system.packet or not menu.combo.key or not Target then return end
--   local dumpP = Packet(p)
--   if p.header == 0x64 then 
--     print(DumpPacketData(p))
--     p.pos = 1
--     if p:DecodeF() ~= Target.networkID then print('no Target ID') return end -- target
--     local type = p:Decode1() -- type
--     if p:DecodeF() ~= myHero.networkID  then print('no myHero ID') return end -- source
   
--     if type == 0x0C then SendQ()
--     elseif type == 0x04 and menu.extra.systemextra then CastCommonItem(Target) 
--     end
--     return -- I do this because multiple if statement for p.header looks better then if/elseif/elseif...
--   end
  
--   if p.header == 0x86 and ThisIsReal(Target) <= myPlayer.range then Packet('S_MOVE', { type = 3, x = Target.visionPos.x, y = Target.visionPos.z, targetNetworkId = Target.networkID}):send() return end

-- end

-- function OnRecvPacket(p)

-- if not _G[c({106,100,107,110,109,118})] then return end
-- if not menu.system.packet then return end

-- --local dp = Packet(p)
-- --   if minionLane ~= nil then
-- --    if p.header == 0x64 then
-- --     print(DumpPacket(p)) 
-- --   end 
-- -- end
--   if menu.combo.key and Target ~= nil then
--     if dp:containsFloat(myPlayer.networkID) then
--       if dp.header == 0x64 then 
--         --print(DumpPacket(p))   -- pos 4 == 40, pos 5 = 0x0C(12)     
--         dp.pos = 5
--         --print('teste')
--         --local Source = p:DecodeF() -- go to pos 5, because DecodeF get 4 pos
--         local AaPacket = dp:Decode1()
--         --if Source == myPlayer.networkID then
--           --p.pos = 5   -- ok
--           --local AaPacket = p:Decode1() --ok       
--           if AaPacket == 0x0C then 
--             SendQ()

--           elseif AaPacket == 0x04 then
--             if menu.extra.systemextra then CastCommonItem(Target) end
--           end
--         --end

      
--     --end
  
--       elseif p.header == 0x56 then          
--         if ThisIsReal(Target) <= myPlayer.range then
--           Packet('S_MOVE', { type = 3, x = Target.networkID, y = Target.networkID, targetNetworkId = Target.networkID}):send()
--           --print('teste AA send')
--         end
--       end
--     end
--   end

-- end

 -- if ValidTarget(Target) and dp:containsFloat(myPlayer.networkID) and
 --   dp:containsFloat(Target.networkID) and p.header ~= 0xC3 and p.header ~= 0x60 and p.header ~= 0xFE and p.header ~= 0x86 and p.header ~= 0xBF and p.header ~= 0xB4 and p.header ~= 0xB6 then
 --     print("1) DumpPacket") 
 --     print(DumpPacket(p)) 
 -- end
--and dp:containsFloat(myPlayer.networkID) 

 --   local p = CLoLPacket(0x64)
 -- p:EncodeF(myHero.networkID)
 -- p:Encode1(12) -- 2 dodge, 3 crit, 4 phys, 5 miss, 6 phys?, 7 phys?, 8 invunerable, 9, 10 dodge, 11 crit
 -- p:EncodeF(myHero.networkID)
 -- p:EncodeF(myHero.networkID)
 -- p:EncodeF(100)
 -- RecvPacket(p)

  

 --  if ValidTarget(Target) and dp:containsFloat(myPlayer.networkID) and dp:containsFloat(Target.networkID) and 
 --  p.header == 0x64 then
 -- -- print('header found')
 --  --print(DumpPacket(p))   

 --    --  print('pos 1 found')
 --     --  p.pos = 1
 --     -- if p:Decode1() == 0x0C then
 --     --   --print('pos 3 found:spell')
 --     --   myPlayer:Attack(Target)
 --     -- end           
 --     --  if p:Decode1() == 0x04 or p:Decode1() == 0x14 then 
 --     --      --print(DumpPacket(p))          
 --     --      SendQ()
 --     --  end
 --     --  --if p:Decode1() ~= 0x0C then
 --     --    print(DumpPacket(p))
 --     --  --end
 --     p.pos = 5
 --     if p:Decode1() == 0x0C then
 --        SendQ()        
 --      end   
   
 --  --print(DumpPacket(p)) -- 0xFE --0x64 -- 0xC3
 --  --print('teste')
  --CastQ(Target) 
  --end



blackTick = 0

local myBuff = 0
function OnSendPacket(p)

if not menu.system.packet then return end
--if not Target ~= nil then return end
local pType_  =   menu.system.pType
--if p:DecodeF() == myHero.networkID then print(DumpPacket(p)) end

 --    local dp = Packet(p)
 -- if ValidTarget(Target) and dp:containsFloat(myPlayer.networkID) and dp:containsFloat(Target.networkID) then print(DumpPacket(p)) end
   
  -- if p.header == 0xC0 then print("OnRecvPacket: 0xC0") end
  -- if p.header == 0x33 then print("OnRecvPacket: 0x33") end
  --if p.header == 0x71 or p.header == 0x9A then print("hum") end
  --   if p.header == Packet.headers.PKT_Basic_Attack_Pos then print("RECV: Packet.headers.PKT_Basic_Attack") end
  -- if p.header ==Packet.headers.PKT_Basic_Attack then print("RECV: Packet.headers.PKT_Basic_Attack") end
  --   local isJump_   =   menu.extra.jumpif not _ENV[r({107,101,107,118,97,108,56,51,52})] then return end
    --if isJump_ then return end
    --local myPacket  =   Packet(p)

    -- if menu.combo.key and Target ~= nil and myPlayer:CanUseSpell(_Q) ~= READY and ThisIsReal(Target) <= myPlayer.range then
    --       --if myPacket:get('name') == 'S_MOVE' and myPacket:get('type') == 2 then myPacket:Block() print('blocking') end
    --       myPlayer:Attack(Target)
    --     end
    --local delay_  =   menu.combo.extracombo.smart
    -- local qForce  =   menu.comboextra.q
    -- local wForce  =   menu.comboextra.w
    -- local eForce  =   menu.comboextra.e 
   -- local useP_   =   menu.system.packet
        --myPacket:get('name') == 'S_CAST' and myPacket:get('spellId') == _Q
    --local table   =   {_Q, _W, _E}    
    --local pTick   =   qTick
    --print(DumpPacket(p))
    if p.header == 0x99 then
      p.pos = 1
      if not p:DecodeF() == myHero.networkID then return end
      local spell = p:Decode1()
      if not spell == 0x00 then return end
      --print('test p 1')
      --if myPacket:get('spellId') == _Q then
        --print('test p 2')
        qTick = GetTickCount() - GetLatency() / 2

        if pType_ == 3 and Target ~= nil then
          local newPos = Target + (Vector(myPlayer) - Target):normalized()*(GetDistance(Target)+50)
          Packet('S_MOVE', {toX = newPos.x, toY = newPos.z, fromX = newPos.x, fromY = newPos.z }):send() --spell.startPos.x 
          --if menu.combo.key then Packet('S_MOVE', { type = 3, x = Target.visionPos.x, y = Target.visionPos.z, targetNetworkId = Target.networkID}):send() end
        elseif pType_ == 1 then
            DelayAction(function()                 
            p = CLoLPacket(0x65)
            p:EncodeF(myPlayer.networkID)
            p:Encode1(0)
            p.dwArg1 = 0
            p.dwArg2 = 0
            SendPacket(p) end,
            0.15)
        elseif pType_ == 2 then
            DelayAction(function() 
            p = CLoLPacket(0x47)
            p:EncodeF(myPlayer.networkID)
            p:Encode1(2)
            p.dwArg1 = 1
            p.dwArg2 = 0
            SendPacket(p) end,
            0.1)
        end



        
         --DelayAction(function() 
                       -- if ValidTarget(Target) and TargetIsValid(Target) and ThisIsReal(Target) <= myPlayer.range then 
                       --   myPlayer:Attack(Target) 
                       -- end 
                   --  end, 
                   -- (1/myPlayer.attackSpeed) + GetLatency()/2000)         
      --end
      -- for i=1, #table do        
      --     if myPacket:get('spellId') == table[i] and ValidTarget(Target) and TargetIsValid(Target) then           
      --       if table[i] == _Q and qForce then                          
      --           --local del   = DelayCalc()                                           
      --               if ThisIsReal(Target) <= myPlayer.range and GetTickCount() + GetLatency()/2 < pTick - (lastWindUpTime - GetLatency()/2) then  --700                                               
      --                   myPacket:block()
      --                   --myPlayer:Attack(Target)                    
      --               end
      --         end
      --         if table[i] == _W and wForce and Passive then
      --           if ThisIsReal(Target) <= myPlayer.range then                                                 
      --                 myPacket:block()                    
      --             end
      --         end
      --         if table[i] == _E and eForce and Passive then
      --           if ThisIsReal(Target) <= myPlayer.range then                                                 
      --                 myPacket:block()                    
      --             end
      --         end
      --       end
      --   end
    end
  -- packetTable = {Packet.headers.PKT_Basic_Attack, Packet.headers.PKT_Basic_Attack_Pos, "0xC0", "0x33"}
  -- for i=1, #packetTable do
  --   if p.header == packetTable[i] then
  --     print("OnSendPacket: "..tostring(packetTable[i]))
  --   end
  -- end
  -- if p.header == Packet.headers.PKT_Basic_Attack_Pos then print("SEND: Packet.headers.PKT_Basic_Attack") end
  -- if p.header ==Packet.headers.PKT_Basic_Attack then print("SEND: Packet.headers.PKT_Basic_Attack") end
  --  if p.header == 0xC0 and ValidTarget(Target) then print("OnSendPacket: 0xC0") end
  -- if p.header == 0x33 and ValidTarget(Target) then print("OnSendPacket: 0x33") end
 -- if ValidTarget(Target) and GetDistance(Target) <= myPlayer.range then print("RECV: "..tostring(p.header)) end

end

function OnGainBuff(unit, buff)
    if unit ~= nil and unit.isMe then
      --print(buff.name)
        if buff.name:lower():find("rivenpassiveaaboost") then Passive       = true PassiveIndicator = 1 if myBuff == 0 then myBuff = 1 end end --passives = passives + 1 end
        if buff.name:lower():find("rivenwindslashready") then temUltimate   = true end
        if buff.name:lower():find("regenerationpotion")  then UsandoHP      = true end
        --if buff.type == 14 then temSlow = true end
    end
end

function OnUpdateBuff(unit, buff)    
    if unit ~= nil and unit.isMe then
      --print(buff.name)
        if buff.name:lower():find("rivenpassiveaaboost") then
          PassiveIndicator = buff.stack 
          myBuff = myBuff + 1
         -- print(myBuff)
        end
    end
end

function OnLoseBuff(unit, buff)
    if unit ~= nil and unit.isMe then
     -- print(buff.name)
        if buff.name:lower():find("rivenpassiveaaboost") then Passive       = false myBuff = 0       
            if buff.stack == 0 or buff.stack == nil then PassiveIndicator = 0 end end
        if buff.name:lower():find("rivenwindslashready") then temUltimate   = false end
        if buff.name:lower():find("regenerationpotion")  then UsandoHP      = false end
        --if buff.type == 14 then temSlow = false end
    end
end

-- items
local Items = {
["Brtk"]        =       {ready = false, range = 450, SlotId = 3153, slot = nil},
["Bc"]          =       {ready = false, range = 450, SlotId = 3144, slot = nil},
["Rh"]          =       {ready = false, range = 385, SlotId = 3074, slot = nil},
["Tiamat"]      =       {ready = false, range = 385, SlotId = 3077, slot = nil},
["Hg"]          =       {ready = false, range = 385, SlotId = 3146, slot = nil},
["Yg"]          =       {ready = false, range = 450, SlotId = 3142, slot = nil},
["RO"]          =       {ready = false, range = 400, SlotId = 3143, slot = nil},
["SD"]          =       {ready = false, range = 275, SlotId = 3131, slot = nil},
["MU"]          =       {ready = false, range = 200, SlotId = 3042, slot = nil} }

local HP_MANA     = { ["Hppotion"] = {SlotId = 2003, ready = false, slot = nil}, ["Elixir"] = {SlotId = 2037, ready = false, slot = nil} }
local FoundItems  = {}

-- cast items
local function CheckItems(tabela)
    for ItemIndex, Value in pairs(tabela) do
        Value.slot = GetInventorySlotItem(Value.SlotId)
            if Value.slot ~= nil and (myPlayer:CanUseSpell(Value.slot) == READY) then
            FoundItems[#FoundItems+1] = ItemIndex
        end
    end
end

function CastCommonItem(myTarget)

    local items_suv =   menu.extra.systemextra
    if not items_suv then return end
    CheckItems(Items)
    if #FoundItems ~= 0 then
        for i, Items_ in pairs(FoundItems) do
            if myTarget ~= nil and TargetIsValid(myTarget) then                                      
                if GetDistance(myTarget) <= Items[Items_].range then                    
                    if Items_ == "Brtk" or Items_ == "Bc" then
                       CastSpell(Items[Items_].slot, myTarget)
                    end
                    if (Items_ == "Yg") or (Items_ == "SD") or (Items_ == "RO") or (Items_ == "MU") or Items_ == "Rh" or Items_ == "Tiamat" then
                        CastSpell(Items[Items_].slot)                    
                    end                    
                end
            elseif myTarget ~= nil and myTarget.type == 'obj_AI_Minion' and Items_ == "Rh" or Items_ == "Tiamat" and GetDistance(myTarget) <= Items[Items_].range then
              CastSpell(Items[Items_].slot)
            end
            FoundItems[i] = nil
        end    
    end
end
 
function CastSurviveItem()

    local items_suv =   menu.extra.systemextra
    if not items_suv then return end
    CheckItems(HP_MANA)    
    local hp_                       = menu.extra.hp   
    local barrier_                  = menu.extra.barrier
    local elixirhp_                 = menu.extra.elixirhp
    local myPlayerhp_               = (myPlayer.health / myPlayer.maxHealth *100)
    if #FoundItems ~= 0 then        
        for i, HP_MANA_ in pairs(FoundItems) do
            if HP_MANA_ == "Hppotion" and myPlayerhp_ <= hp_ and not InFountain() and not UsandoHP then
               CastSpell(HP_MANA[HP_MANA_].slot)
            end
            if HP_MANA_ == "Elixir" and myPlayerhp_ <= elixirhp_ and not InFountain() then
               CastSpell(HP_MANA[HP_MANA_].slot)
            end
            FoundItems[i] = nil
        end
        if BarreiraSpell.slot ~= nil and myPlayerhp_ <= barrier_ and not InFountain() then
            CastSpell(BarreiraSpell.slot)
        end
    end
end

-- E.   Q. W A  Q .A. Q leave
-- E+Q get near the target
-- W
-- stun
-- A Q A
-- harass
-- Q leave there

local function HarassEnemy(myTarget)
  local myOrb          =    menu.system.orb
  if myOrb then OrbWalk(myTarget) end
  if not ValidTarget(myTarget) then return end    
  local hQ_            =    menu.extra.hQ
  local hW_            =    menu.extra.hW
  local hE_            =    menu.extra.hE
  local harassMode_    =    menu.extra.harassMode
  if hQ_ then CastQ(myTarget) end
  if hW_ then CastW(myTarget) end
  if hE_ then CastE(myTarget) end
  -- if harassMode_ == 1 then
  --   if hQ_ and GetDistance(myTarget) <= 550 then
  --     CastSpell(_Q, myTarget.x, myTarget.z)    
  --   elseif hW_ and ThisIsReal(myTarget) <= myPlayer.range then      
  --     CastSpell(_W)
  --   elseif hQ_ then
  --     CastSpell(_Q, myTarget.x, myTarget.z) 
  --   end      
  -- --if hQ_ then CastSpell(_Q, myTarget.x, myTarget.z) end
  --   if hE_ then CastSpell(_E, myTarget.x, myTarget.z) end
  -- elseif harassMode_ == 2 then
  --   if hE_ and GetDistance(myTarget) <= 425 and CastSpell(_E, myTarget.x, myTarget.z) then
  --   elseif hQ_ and GetDistance(myTarget) <= 275 and CastSpell(_Q, myTarget.x, myTarget.z) then
  --   elseif hW_ and GetDistance(myTarget) <= 282 then
  --     CastSpell(_W)       
  --   end    
  -- end        
end

--local LockQ = false

-- function PredCastQ(myTarget)
-- if lockQ then return end
--   local useq      =   menu.combo.skills.q
--   local mode_     =   menu.comboextra.mode  
--   local qpred_  = menu.system.vpred.qpred
--   local qChance_  = menu.system.vpred.qhitchance
--   if useq and qpred_ then   
--     if GetDistance(myTarget) <= GetCustomRange(_Q) then     
--       local AOECastPosition, MainTargetHitChance, nTargets = vp:GetCircularAOECastPosition(myTarget, 0.21, 120, GetCustomRange(_Q), 1000, myPlayer)
      


--       if menu.comboextra.range.useNew == 2 or 3 then

        
--         if ThisIsReal(myTarget) > myPlayer.range then
--           if MainTargetHitChance >= qChance_ and GetTickCount() + GetLatency()/2 > qTick + GetBuffDelay(_Q) then
--            CastSpell(_Q, AOECastPosition.x, AOECastPosition.z)
--           end
--            --print('teste')
--           -- elseif MainTargetHitChance >= 1 and not temParticula then
--           --   CastSpell(_Q, AOECastPosition.x, AOECastPosition.z)
--         -- elseif myPlayer:CanUseSpell(_E) ~= READY or myPlayer:CanUseSpell(_E) == NOTLEARNED and not lockQ then
--         --     CastSpell(_Q, AOECastPosition.x, AOECastPosition.z)
--         --     if ThisIsReal(myTarget)  <= myPlayer.range then
--         --       lockQ = true
--         --     else
--         --       lockQ = false
--         --     end   
--         end

--       elseif menu.comboextra.range.useNew == 1 then

     
--         if ThisIsReal(myTarget) > myPlayer.range then
--           if MainTargetHitChance >= qChance_ and GetTickCount() + GetLatency()/2 > qTick + GetBuffDelay(_Q) then
--            CastSpell(_Q, AOECastPosition.x, AOECastPosition.z)

--           end
--            --print('teste')
--           -- elseif MainTargetHitChance >= 1 and not temParticula then
--           --   CastSpell(_Q, AOECastPosition.x, AOECastPosition.z)
--         -- elseif myPlayer:CanUseSpell(_E) ~= READY or myPlayer:CanUseSpell(_E) == NOTLEARNED and not lockQ then
--         --     CastSpell(_Q, AOECastPosition.x, AOECastPosition.z)
--         --     if ThisIsReal(myTarget)  <= myPlayer.range then
--         --       lockQ = true
--         --     else
--         --       lockQ = false
--         --     end     
--         end
--       end

--       --end
--     -- elseif myPlayer:CanUseSpell(_E) ~= READY and GetDistance(myTarget) <= 550 then
--     --   local AOECastPosition, MainTargetHitChance, nTargets = vp:GetCircularAOECastPosition(myTarget, 0.21, 120, GetCustomRange(_Q), math.huge, myPlayer)
--     --   if MainTargetHitChance >= 1 then
--     --     CastSpell(_Q, AOECastPosition.x, AOECastPosition.z)
--     --   end
--     -- elseif temUltimate and GetDistance(myTarget) <= 550 then
--     --   local AOECastPosition, MainTargetHitChance, nTargets = vp:GetCircularAOECastPosition(myTarget, 0.21, 120, GetCustomRange(_Q), math.huge, myPlayer)
--     --   if MainTargetHitChance >= 1 then
--     --     CastSpell(_Q, AOECastPosition.x, AOECastPosition.z)
--     --   end
--     end
--   end
-- end

function CastQ(myTarget)  
  local useq      =   menu.combo.skills.q
  local mode_     =   menu.comboextra.mode   
  --if lockQ then return end 
  --local qpred_  = menu.system.vpred.qpred    
  --if qpred_ then PredCastQ(myTarget) return end
  if useq then

    if GetDistance(myTarget) > myPlayer.range and GetDistance(myTarget) <= GetCustomRange(_Q) then       
    --if GetDistance(myTarget) <= GetCustomRange(_Q) then
      --if menu.comboextra.range.useNew == 2 or 3 then
        --qTick = GetTickCount() + GetLatency() / 2        
        if GetTickCount() + GetLatency()/2 > qTick + GetBuffDelay(_Q) and myTarget ~= nil then
          CastSpell(_Q, myTarget.visionPos.x, myTarget.visionPos.z)
          --Packet('S_MOVE', { type = 3, x = myTarget.visionPos.x, y = myTarget.visionPos.z, targetNetworkId = myTarget.networkID}):send()     
        end
    elseif GetDistance(myTarget) <= myPlayer.range and myTarget ~= nil then
      Packet('S_MOVE', { type = 3, x = myTarget.visionPos.x, y = myTarget.visionPos.z, targetNetworkId = myTarget.networkID}):send()
      -- if not Passive then
      --   SendQ()
      -- end
    end

      --elseif menu.comboextra.range.useNew == 1 then
        -- if GetTickCount() + GetLatency()/2 > qTick + GetBuffDelay(_Q) then
        --   CastSpell(_Q, myTarget.visionPos.x, myTarget.visionPos.z)                
        -- end
      --end

      --end
    -- elseif myPlayer:CanUseSpell(_E) ~= READY and GetDistance(myTarget) <= 550 then      
    --   CastSpell(_Q, myTarget.visionPos.x, myTarget.visionPos.z)
    --    if ThisIsReal(myTarget)  <= myPlayer.range then
    --           lockQ = true
    --         else
    --           lockQ = false
    --         end  
    --end
  end
end


function CastW(myTarget)   
  local usew      =   menu.combo.skills.w  
  local useItems_ =   menu.comboextra.items

  if usew and PassiveIndicator <= 2 then       
    if GetDistance(myTarget) <= GetCustomRange(_W) then
      if CastSpell(_W) then CastCommonItem(myTarget) end     
    end
  elseif usew and myPlayer:CanUseSpell(_Q) == COOLDOWN and myPlayer:CanUseSpell(_E) == COOLDOWN then
    if GetDistance(myTarget) <= GetCustomRange(_W) then
      if CastSpell(_W) then CastCommonItem(myTarget) end     
    end
  end

end

local function AutoStun()
    local CombON = menu.combo.key
    if CombON then return end
    local autow_    =   menu.comboextra.autow 
    --local range_3   = GetCustomRange(_W)       
    if CountEnemyHeroInRange(GetCustomRange(_W)) >= autow_ then
         CastSpell(_W)
      --Packet('S_CAST', {spellId = _W}):send() 
      if useItems_ then CastCommonItem(myTarget) end          
    end
    --if ThisIsReal(myTarget) <= myPlayer.range and Passive then myPlayer:Attack(myTarget) end
end

function CastE(myTarget)
  --if lockE then return end   
  local usee      =   menu.combo.skills.e      
  if usee and PassiveIndicator <= 2 then
    if GetDistance(myTarget) <= GetCustomRange(_E) and IsWall(D3DXVECTOR3(myTarget.visionPos.x, myTarget.visionPos.y, myTarget.visionPos.z)) == false then
      CastSpell(_E, myTarget.visionPos.x, myTarget.visionPos.z)
    -- elseif GetDistance(myTarget) <= GetCustomRange(_E) and qCount >=2 then
    --   CastSpell(_E, myTarget.x, myTarget.z)
    elseif myPlayer:CanUseSpell(_Q) ~= READY or temUltimate then
      CastSpell(_E, myTarget.visionPos.x, myTarget.visionPos.z)
    elseif GetDistance(myTarget) <= GetCustomRange(_E) and getDmg("P", myTarget, myPlayer) + getDmg("AD", myTarget, myPlayer) >= myTarget.health then
      CastSpell(_E, myTarget.visionPos.x, myTarget.visionPos.z)
      myPlayer:Attack(myTarget)
    end
  end   
end

local function UltimateKS()
    local useksR_     =   menu.comboextra.ksultimate
    local ComboON     =   menu.combo.key
    local nKs_        =   menu.comboextra.nKsultimate  
    local Enemys      =   nil
    if not useksR_ then return end
    --if ComboON then return end
    --if CountEnemyHeroInRange(900) < nKs_ then return end   
    for i, Enemys in pairs(GetEnemyHeroes()) do
        if ValidTarget(Enemys) and TargetIsValid(Enemys) and GetDistance(Enemys) <= 900 and (Enemys.health/Enemys.maxHealth)*100 <= 24 then 
        --local rDmg = getDmg("R", Enemys, myPlayer,2)          
            --if (myTarget.health/myTarget.maxHealth*100) <= 25 then
              rTick = GetTickCount() + GetLatency() / 2
              CastSpell(_R)
              if temUltimate and GetDistance(Enemys) <= 900 then              
                if (Enemys.health/Enemys.maxHealth*100) <= 24 then
                  CastSpell(_R, Enemys.x, Enemys.z)
                elseif GetTickCount() + GetLatency() / 2 - rTick> GetBuffDelay(_R) then
                  CastSpell(_R, Enemys.x, Enemys.z)
                end
              end
            --end
        end
    end
end

local lockUltimate = false
local function CheckfirstRmode(myTarget)
  --if not ValidTarget(myTarget) then return end
      local rRange  = menu.comboextra.autostartRrange
      local HealthE = menu.comboextra.autostartRhealth    
      local rEnemys = menu.comboextra.autostartRnumber
      local eMode   = menu.comboextra.firstRmode
      if eMode == 1 then -- # enemys
        --if CountEnemyHeroInRange(900, myPlayer) == 0 then return end        
        --if CountEnemyHeroInRange(900, myPlayer) >= rEnemys then
          return GetDistance(myTarget) <= 850 and CountEnemyHeroInRange(850) >= rEnemys
      end      
      if eMode == 2 then -- main health
        return GetDistance(myTarget) <= 850 and (myTarget.health / myTarget.maxHealth * 100) <= HealthE
      end
      if eMode == 3 then  -- Range
        return GetDistance(myTarget) <= rRange
      end
      if eMode == 4 then -- ALL
        return GetDistance(myTarget) <= 850 and CountEnemyHeroInRange(rRange) >= rEnemys and (myTarget.health / myTarget.maxHealth * 100) <= HealthE and GetDistance(myTarget) <= rRange
      end
end


function GetBestCircularFarmPosition(range, radius, objects)
    local BestPos 
    local BestHit = 0
    for i, object in ipairs(objects) do
        local hit = CountObjectsNearPos(object.visionPos or object, radius, objects)
        if hit > BestHit then
            BestHit = hit
            BestPos = Vector(object)
            if BestHit == #objects then
               break
            end
         end
    end
    return BestPos, BestHit
end


local temFirstR = false
function NewCastR(myTarget)
  if menu.extra.harass then return end
  local user       =  menu.combo.skills.r  
  if user and CheckfirstRmode(myTarget) then             
    if not temUltimate then CastSpell(_R) end

    if temUltimate and GetDistance(myTarget) <= 850 then

      -- Damage
      local rDmg = getDmg("R", myTarget, myPlayer)
      if rDmg ~= 0 and menu.comboextra.secondRmode == 2 and rDmg > myTarget.health and GetTickCount() + GetLatency()/2 - rTick < GetBuffDelay(_R) then
        CastSpell(_R, myTarget.visionPos.x, myTarget.visionPos.z)      

      -- Max damage (25%)
      elseif menu.comboextra.secondRmode == 1 and (myTarget.health/myTarget.maxHealth*100) <= 25 and GetTickCount() + GetLatency()/2 - rTick < GetBuffDelay(_R) then
        CastSpell(_R, myTarget.visionPos.x, myTarget.visionPos.z)
      
      -- Timeout ultimate buff
      elseif rTick ~= 0 and GetTickCount() + GetLatency()/2 - rTick > GetBuffDelay(_R) then
        CastSpell(_R, myTarget.visionPos.x, myTarget.visionPos.z)
      
      -- Avoid loose ultimate by range
      elseif GetDistance(myTarget) >= 780 then
        CastSpell(_R, myTarget.visionPos.x, myTarget.visionPos.z)
      end

    end
  end
end


--     if rPred and temUltimate and GetDistance(myTarget) <= 850 then
--       local mainCastPosition, mainHitChance = vp:GetConeAOECastPosition(myTarget, 0.5,  45,  850,  1200, myPlayer)
--       if mainCastPosition and mainHitChance >= rChance then
--         if menu.comboextra.secondRmode == 1 and (myTarget.health/myTarget.maxHealth*100) <= 25 then
--           CastSpell(_R, mainCastPosition.x, mainCastPosition.z)
--           --if not myTarget.dead then lockIgnite = false end
--           temFirstR = false 
--         elseif menu.comboextra.secondRmode == 2 and getDmg("R", myTarget, myPlayer) -1 >= myTarget.health then
--           CastSpell(_R, mainCastPosition.x, mainCastPosition.z)
--           --if not myTarget.dead then lockIgnite = false end
--           temFirstR = false 
--         end
--         elseif rTick ~= 0 and GetTickCount() + GetLatency() / 2 - rTick > GetBuffDelay(_R) then
--         CastSpell(_R, mainCastPosition.x, mainCastPosition.z)
--         --if not myTarget.dead then lockIgnite = false end
--         temFirstR = false
--         elseif GetDistance(myTarget) >850 and GetDistance(myTarget) <= 900 then
--           CastSpell(_R, mainCastPosition.x, mainCastPosition.z)
--           --if not myTarget.dead then lockIgnite = false end
--           temFirstR = false
--         end
--       end
--     else
--       if temUltimate and GetDistance(myTarget) <= 850 then
--         if menu.comboextra.secondRmode == 1 and (Enemys.health/Enemys.maxHealth*100) <= 24 then
--           CastSpell(_R, myTarget.visionPos.x, myTarget.visionPos.z)
--           temFirstR = false
--           --if not myTarget.dead then lockIgnite = false end
--         elseif menu.comboextra.secondRmode == 2 and getDmg("R", myTarget, myPlayer)-10 >= myTarget.health then
--           CastSpell(_R, myTarget.visionPos.x, myTarget.visionPos.z)
--           temFirstR = false
--           --if not myTarget.dead then lockIgnite = false end
--         elseif rTick ~= 0 and GetTickCount() + GetLatency() / 2 - rTick > GetBuffDelay(_R) then
--           CastSpell(_R, myTarget.visionPos.x, myTarget.visionPos.z)
--           --if not myTarget.dead then lockIgnite = false end
--           temFirstR = false
--         elseif GetDistance(myTarget) > 850 and GetDistance(myTarget) <=900 then
--           CastSpell(_R, myTarget.visionPos.x, myTarget.visionPos.z)
--       end
--     end 
--   end
-- end

-- function CheckEnemiesHitByW()
--   local enemieshit = {}
--   for i, enemy in ipairs(GetEnemyHeroes()) do
--     local position = VP:GetPredictedPos(enemy, Wdelay)
--     if ValidTarget(enemy) and GetDistance(position, BallPos) <= Wradius and GetDistance(enemy.visionPos, BallPos) <= Wradius then
--       table.insert(enemieshit, enemy)
--     end
--   end
--   return #enemieshit, enemieshit
-- end

-- function CheckEnemiesHitByUltimate()
--   local enemieshit = {}
--   for i, enemy in ipairs(GetEnemyHeroes()) do
--     local position = vp:GetPredictedPos(enemy, 0.25)
--     if ValidTarget(enemy) and GetDistance(position, myPlayer) <= 900 and GetDistance(enemy.visionPos, myPlayer) <= 900 then
--       table.insert(enemieshit, enemy)
--     end
--   end
--   return #enemieshit, enemieshit
-- end

-- function CastSecondR(myTarget)
--   --if lockUltimate then return end
--   local user       =  menu.combo.skills.r    
--   local rPred      =  menu.system.vpred.rpred
--   local rChance    =  menu.system.vpred.rhitchance
--   local DamageR   =   getDmg("R", myTarget, myPlayer)       
--   if user and temUltimate then
--     if rPred and GetDistance(myTarget) <= 850 then
--       local mainCastPosition, mainHitChance, MaxHit  = vp:GetConeAOECastPosition(myTarget, 0.5,  45,  850,  1200, myPlayer)
      
--         if menu.system.vpred.rlogic and MaxHit > 1 then          

--           local hitcount, hit = CheckEnemiesHitByUltimate()

--           if mainHitChance >= 1 and getDmg("R", myTarget, myPlayer) -1 >= myTarget.health and hitcount >= 2 then
--             CastSpell(_R, mainCastPosition.x, mainCastPosition.z)
--               if not myTarget.dead then lockIgnite = false end 
--               temFirstR = false 
--           elseif rTick ~= 0 and GetTickCount() + GetLatency() / 2 - rTick > GetBuffDelay(_R) then
--             CastSpell(_R, mainCastPosition.x, mainCastPosition.z)
--             if not myTarget.dead then lockIgnite = false end
--             temFirstR = false
--           end

--         else
--         if mainHitChance >= rChance and getDmg("R", myTarget, myPlayer) -1 >= myTarget.health then
--           CastSpell(_R, mainCastPosition.x, mainCastPosition.z)
--               if not myTarget.dead then lockIgnite = false end 
--               temFirstR = false 
--         elseif rTick ~= 0 and GetTickCount() + GetLatency() / 2 - rTick > GetBuffDelay(_R) then
--           CastSpell(_R, mainCastPosition.x, mainCastPosition.z)
--           if not myTarget.dead then lockIgnite = false end
--           temFirstR = false
--         end
--       end
--     else
--       if temUltimate and GetDistance(myTarget) <= 850 then       
--         if getDmg("R", myTarget, myPlayer) -1 >= myTarget.health then
--           CastSpell(_R, myTarget.x, myTarget.z)
--           if not myTarget.dead then lockIgnite = false end
--           temFirstR = false
--         elseif rTick ~= 0 and GetTickCount() + GetLatency() / 2 - rTick > GetBuffDelay(_R) then
--           CastSpell(_R, myTarget.x, myTarget.z)
--           if not myTarget.dead then lockIgnite = false end
--           temFirstR = false
--         end
--       end
--     end
--   end
-- end

-- function OnApplyParticle(unit, particle)
--  if not _ENV[r({107,101,107,118,97,108,56,51,52})] then return end -- this is easily overridden just fyi, make sure you have important init stuff in kek4
--   local particleTable = { 
--   ["Riven_Base_Q_01_Wpn_Trail.troy"] = true, 
--   ["Riven_Base_Q_02_Wpn_Trail.troy"] = true, 
--   ["Riven_Base_Q_03_Wpn_Trail.troy"] = true, 
--   ["Riven_Base_P_Buff.troy"] = true, 
--   ["RivenSwordBlue.troy"] = true}
--   if menu.combo.key then
--     if ValidTarget(unit) and ValidTarget(Target) then 
--       if unit.networkID == Target.networkID then
--         if particle.name == "globalhit_bloodslash.troy" then CastSpell(_Q, Target.x, Target.z) end
--       end     
--     end 
--     if unit ~= nil and unit.isMe then 
--       if particleTable[particle.name] then myPlayer:Attack(Target) end
--     end
--   end
--   --if unit ~= nil and unit.isMe then print(particle.name) end
-- end

function OnAnimation(unit, animationname)

    local ComboON       =   menu.combo.key        
    local animaT        =   { "spell1a", "spell1b", "spell1c" } --, "spell2"}
    if unit.isMe then
      --if animationname:lower():find("attack") then  end
      -- if ComboON and ValidTarget(Target) and ThisIsReal(Target) <= myPlayer.range then   
      --   for i=1, #animaT do
      --     if animationname:lower():find(animaT[i]) then
      --       myPlayer:Attack(Target)
      --       --lastAttack = 0
      --     end
      --   end      
      -- end

      if animationname:lower():find("spell1a") then qCount = 1 end
      if animationname:lower():find("spell1b") then qCount = 2 end
      if animationname:lower():find("spell1c") then qCount = 3 countTick = GetTickCount() + GetLatency()/2 end  

    end
end


-- local function ComboByChampion(myTarget)
--   local anti_over = menu.comboextra.others.smart  
--   if not ValidTarget(myTarget) and TargetIsValid(myTarget) then return end
--   lockE = true
--   local championsT = {"Aatrox", "Darius", "Jax", "Shyvana", "Jayce", "Renekton", "Malphite", "Kayle", "MonkeyKing", "Volibear",
--                       "Yasuo"}
--   --local TargetHealth = (myTarget.health/myTarget.maxHealth)*100
--   for i=1, #championsT do
--     if myTarget.charName:find(championsT[i]) and GetDistance(myTarget) <= GetCustomRange(_Q) then
--       -- Jax
--       if championsT[i] == "Jax" then
--         local JaxQcd = myTarget:GetSpellData(_Q).currentCd
--         local JaxEcd = myTarget:GetSpellData(_E).currentCd        
--         --local JaxRcd = myTarget:GetSpellData(_R).currentCd
--         if JaxQcd ~= nil and JaxQcd > 1 then lockE = false CastE(myTarget) end
--         if JaxEcd ~= nil and JaxEcd > 1 then CastW(myTarget) end
        
       
--       -- Shyvana 
--       elseif championsT[i] == "Shyvana" then
--         local shyWcd = myTarget:GetSpellData(_W).currentCd
--         if shyWcd ~= nil and shyWcd > 1 then lockE = false CastE(myTarget) end
       
--       -- Jayve
--       elseif championsT[i] == "Renekton" then
--         local rekEcd = myTarget:GetSpellData(_E).currentCd
--         if rekRcd ~= nil and rekRcd > 2 then lockE = false CastE(myTarget) end
       
--       --Malphite
--       elseif championsT[i] == "Malphite" then
--         local mapQcd = myTarget:GetSpellData(_Q).currentCd
--         if mapQcd ~= nil and mapQcd > 1 then lockE = false CastE(myTarget) end
       
--         -- Darius
--       elseif championsT[i] == "Darius" then
--         local darEcd = myTarget:GetSpellData(_E).currentCd
--         if darEcd ~= nil and darEcd > 1 then lockE = false CastE(myTarget) end
       
--         --Chogath
--       elseif championsT[i] == "Chogath" then
--         local choQcd = myPlayer:GetSpellData(_Q).currentCd
--         if choQcd ~= nil and choQcd > 1 then lockE = false CastE(myTarget) end
        
--         --Aatrox
--       elseif championsT[i] == "Aatrox" then
--         local aaEcd = myTarget:GetSpellData(_E).currentCd
--         if aaEcd ~= nil and aaEcd > 1 then lockE = false CastE(myTarget) end
       
--         --Kayle
--       elseif championsT[i] == "Kayle" then
--         local kayQcd = myPlayer:GetSpellData(_Q).currentCd
--         if kayQcd ~= nil and kayQcd > 1 then lockE = false CastE(myTarget) end
        
--         --Jayce
--       elseif championsT[i] == "Jayce" then
--         local jayQcd = myPlayer:GetSpellData(_Q).currentCd
--         if jayQcd ~= nil and jayQcd > 1 then lockE = false CastE(myTarget) end
        
--         --Wukong
--       elseif championsT[i] == "MonkeyKing" then
--         local wuEcd = myPlayer:GetSpellData(_E).currentCd
--         if wuEcd ~= nil and wuEcd > 1 then lockE = false CastE(myTarget) end
        
--       -- volibear
--       elseif championsT[i] == "Volibear" then
--         local voRcd = myPlayer:GetSpellData(_R).currentCd
--         if voRcd ~= nil and voRcd > 1 then lockE = false CastE(myTarget) end
        
--       -- yasuo
--       -- elseif championsT[i] == "Yasuo" then
--       --   local yaQcd = myPlayer:GetSpellData(_Q).currentCd
--       --   if yaQcd ~= nil and yaQcd > 1 then lockE = false CastE(myTarget) end
        
--       end
--     else
--       lockE = false
--     end
--   end
-- end

-- function Combo(myTarget)
--   local anti_over = menu.comboextra.others.smart
--   if anti_over then
--     if temUltimate then CastSecondR(myTarget) end
--     lockE = false
--     DamageCombo(myTarget)                        
--   else
--     lockE = false
--   if temUltimate then CastSecondR(myTarget) end 
--     CastQ(myTarget)
--     CastE(Target)   
--     NewCastR(myTarget)
--   end
-- end


local qTimeStart = 0
local qWind, qAnima = 0
function OnProcessSpell(unit, spell)

  --------use---------
        local useq          =   menu.combo.skills.q
        local usew          =   menu.combo.skills.w
        local usee          =   menu.combo.skills.e
        local user          =   menu.combo.skills.r
        -------multi skill-------
        -- local qe_           =   menu.combo.multi.qe
        -- local ew_           =   menu.combo.multi.ew
        -- local qr_           =   menu.combo.multi.qr
        -- local er_           =   menu.combo.multi.er
        local useItems_     =   menu.comboextra.items
        local ComboON       =   menu.combo.key
        local mov_          =   menu.system.mov
        --local qPacket       =   menu.system.noface
        local useEvadeee_   =   menu.system.evadeee 

    if unit.isMe then      
        
        -------new-----------------
        --local speed_    = menu.comboextra.speed       
        if spell.name:lower():find("attack") then

          --if ComboON and ValidTarget(Target) then CastQ(Target) end 
        --print("PROCESS: AA")          
            --[[orbwalk]]             
            lastAttack      = GetTickCount() - GetLatency() / 2
            lastWindUpTime  = spell.windUpTime * 1000 -- can move
            lastAttackCD    = spell.animationTime * 1000 -- can attack
            --print("Wind: "..tostring(spell.windUpTime).." - animation: "..tostring(spell.animationTime).." - Ping: "..tostring(GetLatency() / 2000).."Total: "..tostring((spell.windUpTime/2) + spell.animationTime - GetLatency() / 2000))
            DelayAction(function() if spell.Target ~= nil then SendQ() end end, (spell.windUpTime/2) + spell.animationTime - GetLatency() / 2000)
          --print("3) AA")
          --if ValidTarget(Target) and TargetIsValid(Target) and menu.combo.key and not menu.farm.lasthit then CastQ(Target) end
            --if ValidTarget(Target) and ComboON and GetDistance(Target) <= 550 and GetDistance(Target) > myPlayer.range then CastSpell(_Q, Target.x, Target.z) end       
        end      
        if ComboON and Target ~= nil then

          if spell.name:lower():find("riventricleave") then
            --qWind, qAnima = spell.windUpTime, spell.animationTime
            --print("Q    -     Wind: "..tostring(spell.windUpTime).." - animation: "..tostring(spell.animationTime).." - Ping: "..tostring(GetLatency() / 2000).."Total: "..tostring((spell.windUpTime/2) + spell.animationTime - GetLatency() / 2000))
            if user then
              NewCastR(Target)             
            end
            
            if usew then
              CastW(Target)
              --if useItems_ then CastCommonItem(Target) end
            end
            if usee and not menu.comboextra.others.smart then
              CastE(Target)
            end           
            

          elseif spell.name:lower():find("rivenmartyr") then
            if useItems_ then CastCommonItem(Target) end
         
          elseif spell.name:lower():find("rivenfeint") then
            if user and not menu.comboextra.others.smart then
              --CastSecondR(Target)
              NewCastR(Target)                 
            end
            if usew and not menu.comboextra.others.smart then
                CastW(Target)
                --if useItems_ then CastCommonItem(Target) end
            end
          end
      end

      if spell.name:lower():find("rivenfengshuiengine") then
          rTick = GetTickCount() + GetLatency() / 2            
          if usee and not menu.comboextra.others.smart then
            CastE(Target)
          end
      end
    end

    if spell.name:lower():find("riventricleave") then         
      qTimeStart = GetTickCount()
    end
    -- if ComboON and Target ~= nil and not Target.dead and Target.visible and ThisIsReal(Target) <= myPlayer.range then
    -- myPlayer:Attack(Target)
    -- end 
    local autoE     = menu.extra.eTurret
    if autoE and unit.type == "obj_AI_Turret" and spell.target.networkID == myPlayer.networkID and GetDistance(spell.endPos) <= 1000 then
      lockE = false
      CastSpell(_E, mousePos.x, mousePos.z)
      lockE = true
    end
      -- champion name and spell name
    spellsTable = {
    ["Aatrox"] = "AatroxE", ["Caitlyn"] = "CaitlynAceintheHole", ["Chogath"] = "Rupture" ,["Darius"] = "DariusAxeGrabCone", ["Elise"] = "EliseHumanE",
    ["Garen"] = "GarenE", ["Jax"] = "JaxLeapStrike", ["Kayle"] = "JudicatorReckoning", ["Nasus"] = "NasusW",
    ["Renekton"] = "RenektonSliceAndDice", ["Tryndamere"] = "slashCast", ["Trundle"] = "trundledesecrate", ["MonkeyKing"] = "MonkeyKingDoubleAttack", ["MonkeyKing"] = "MonkeyKingNimbus",
    ["Fiddlesticks"] = "Crowstorm", ["Fiddlesticks"] = "DrainChannel", ["Galio"] = "GalioIdolOfDurand", ["Katarina"] = "KatarinaR", ["MissFortune"] = "MissFortuneBulletTime", ["Nunu"] = "AbsoluteZero", ["Malzahar"] = "AlZaharNullZone"}
  if menu.comboextra.others.evadeeE then
    if useEvadeee_ and myPlayer:CanUseSpell(_E) == READY and _G.Evadeee or _G.Evadeee_impossibleToEvade then
      if ValidTarget(unit) then
        for ChampionName, Spell_Champs in pairs(spellsTable) do -- E delay = -0.101
          if unit.charName == ChampionName and spell.name == Spell_Champs and spell.endPos == myPlayer.pos and GetDistance(unit) <= 700 then
            CastSpell(_E, mousePos.x, mousePos.z)
          end
        end
      end
    else
       if myPlayer:CanUseSpell(_E) == READY and ValidTarget(unit) then
        for ChampionName, Spell_Champs in pairs(spellsTable) do -- E delay = -0.101
          if unit.charName == ChampionName and spell.name == Spell_Champs and spell.endPos == myPlayer.pos and GetDistance(unit) <= 700 then
            CastSpell(_E, mousePos.x, mousePos.z)
          end
        end
      end
    end
   end
end

function JumpQ()
    local From, To, CastPos = ReturnDrawPoint()
    if qCount == 0 then   
     CastSpell(_Q, mousePos.x, mousePos.z)
       qTick = GetTickCount() + GetLatency()/2
    elseif (From and To and CastPos ~= nil) and GetDistance(myPlayer, CastPos) <= 100 then
        myPlayer:MoveTo(CastPos.x, CastPos.z)
        if myPlayer.pos.x == CastPos.x and myPlayer.pos.z == CastPos.z then        
          CastSpell(_Q, CastPos.x, CastPos.z)
        end
    end
    if qCount == 2 and GetTickCount() + GetLatency() / 2 - qTick > 4000 then
        CastSpell(_Q, mousePos.x, mousePos.z)
    end
    if GetDistance(mousePos) > 150 then
    local moveToPos = myPlayer + (Vector(mousePos) - myPlayer):normalized()* 150
      myPlayer:MoveTo(moveToPos.x, moveToPos.z)
  end     
end

function BurnYouShit(myTarget)  
    local useI  =   menu.comboextra.others.ignite
    local slot_ =   IgniteSpell.slot
    if useI and slot_ ~= nil and myPlayer:CanUseSpell(slot_) == READY and GetDistance(myTarget, myPlayer) <= IgniteSpell.range and not TargetHaveBuff(IgniteSpell.spellSlot, myTarget) then
        local iDmg  =   getDmg("IGNITE", myTarget, myPlayer, myPlayer.level)
        if myTarget.health <= iDmg then
            CastSpell(slot_, myTarget)
        end
    end
end

function LineFarm()  
    local delay_         =   menu.farm.extrafarm.delay
    local myOrb          =   menu.system.orb    
    local items_0        =   menu.comboextra.items
    local mode_          =   menu.farm.extrafarm.lanemode
    local qLane_         =   menu.farm.extrafarm.qlane
    local wLane_         =   menu.farm.extrafarm.wlane
    local eLane_         =   menu.farm.extrafarm.elane  
    --local enemyMinions      =   minionManager(MINION_ENEMY, 875, myPlayer, MINION_SORT_HEALTH_ASC)
    
    --if JungleLaneMinion == nil then
      enemyMinions1:update()
      Jungle:update()
    --end

    JungleLaneMinion = enemyMinions1.objects[1] or Jungle.objects[1]
    

    
    if JungleLaneMinion ~= nil and not JungleLaneMinion.dead then
     if mode_ == 2 and GetTickCount() + GetLatency() / 2 > lTick then myPlayer:Attack(JungleLaneMinion) CastCommonItem(JungleLaneMinion) end                  
        if qLane_ and GetDistance(JungleLaneMinion, myPlayer) <= 550 and not Passive then
            tock = GetTickCount() + GetLatency()/2
            CastSpell(_Q, JungleLaneMinion.visionPos.x, JungleLaneMinion.visionPos.z)
            --CastSpell(_Q, JungleLaneMinion.visionPos.x, JungleLaneMinion.visionPos.z)        
        elseif qLane_ and GetTickCount() + GetLatency()/2 - tock > 1250 then
            tock = GetTickCount() + GetLatency()/2
            CastSpell(_Q, JungleLaneMinion.visionPos.x, JungleLaneMinion.visionPos.z)        
        end
        if eLane_ then
            CastSpell(_E, JungleLaneMinion.visionPos.x, JungleLaneMinion.visionPos.z)
        end
        if wLane_ and GetDistance(JungleLaneMinion, myPlayer) <= 280 then CastSpell(_W) end
        --CastCommonItem(minionLane)       
         --if mode == 2 then myPlayer:Attack(minionLane) end 
    end
    if mode_ == 2 and GetTickCount() + GetLatency() / 2 > lTick and myOrb and JungleLaneMinion == nil then
      myPlayer:MoveTo(mousePos.x, mousePos.z)
    end 
    if JungleLaneMinion ~= nil and menu.farm.extrafarm.smiteJ then SmiteBuffMob() end
      -- if mode == 2 and ValidTarget(minionLane) and GetTickCount() + GetLatency() / 2 > lTick then
      --        myPlayer:Attack(minionLane)
      --        lTick = GetTickCount() + GetLatency() / 2  + 360 + delay_
      --    end 
    if myOrb and mode_ == 1 then OrbWalk(JungleLaneMinion) end    
end

-- local function FarmWithShield() 
--     local delay_        =   menu.farm.extrafarm.delay
--     local myOrb       = menu.system.orb
--     local enemyMinions      =   minionManager(MINION_ENEMY, 550, myPlayer, MINION_SORT_HEALTH_ASC)
--     enemyMinions:update()
--     minion = enemyMinions.objects[1]
--     if GetTickCount() + GetLatency() / 2 > TickTack and myOrb == true then
--         myPlayer:MoveTo(mousePos.x, mousePos.z)
--     end    
--     if ValidTarget(minion) then
--         local aDmg = getDmg("AD", minion, myPlayer)
--         if ValidTarget(minion) and minion.health <= aDmg  and EnemyInRange(minion, getTrueRange()) and GetTickCount() + GetLatency() / 2 > TickTack then
--             CastSpell(_E, minion.x, minion.z)
--             myPlayer:Attack(minion)
--             TickTack = GetTickCount() + GetLatency() / 2 + 360 + delay_
--         end
--     end
-- end

local enemyMinions      =   minionManager(MINION_ENEMY, 550, myPlayer, MINION_SORT_HEALTH_ASC)
local minion            =   nil
function FarmChicken()
    local delay_         =   menu.farm.extrafarm.delay
    local myOrb          =  menu.system.orb
    --local enemyMinions      =   minionManager(MINION_ENEMY, 550, myPlayer, MINION_SORT_HEALTH_ASC)
    enemyMinions:update()
    minion = enemyMinions.objects[1]
    if GetTickCount() + GetLatency() / 2 > TickTack and myOrb == true then
        myPlayer:MoveTo(mousePos.x, mousePos.z)
    end
    
    if ValidTarget(minion) then
        local aDmg = getDmg("AD", minion, myPlayer)
        if ValidTarget(minion) and minion.health <= aDmg  and EnemyInRange(minion, getTrueRange()) and GetTickCount() + GetLatency() / 2 > TickTack then
            myPlayer:Attack(minion)
            TickTack = GetTickCount() + GetLatency() / 2 + 360 + delay_
        end
    end
end

function SmiteBuffMob()
  local slot_   = SmiteSpell.slot
  if slot_ == nil then return end
  
  local Mobs    = {"worm", -- Baron
          "dragon", -- Dragon
          "ancientgolem",
          "lizardelder",
          "giantwolf",
          "greatwraith",
          --"wraith",
          "golem",
          "spiderboss",
          "ngolem",
          "nwolf",
          "nwraith"}
  local jungle  = minionManager(MINION_JUNGLE, 750, myPlayer, MINION_SORT_MAXHEALTH_DEC)
  jungle:update()
  local mob     = jungle.objects[1]
  if ValidTarget(mob) then
    for i=1, #Mobs do
      if mob.charName:lower():find(Mobs[i]) then
        local smiteDmg  = math.max(20*myPlayer.level+370,30*myPlayer.level+330,40*myPlayer.level+240,50*myPlayer.level+100)
        if mob.health <= smiteDmg and GetDistance(mob) <= 750 and not mob.dead then
          CastSpell(slot_, mob)
        end
      end
    end
  end
end

-- local Jungle        = minionManager(MINION_JUNGLE, 550, myPlayer, MINION_SORT_MAXHEALTH_DEC)
-- local Minion        = nil
-- function JungleBitch()
--   local KillMobs      =   menu.farm.clearjungle
--   if not KillMobs then return end
--   --local Jungle        = minionManager(MINION_JUNGLE, 550, myPlayer, MINION_SORT_MAXHEALTH_DEC)
   
--     local mode_         =   menu.farm.extrafarm.junglemode
--     local useq          =   menu.farm.extrafarm.q
--     local usew          =   menu.farm.extrafarm.w
--     local usee          =   menu.farm.extrafarm.e  
--     local delay_        =   menu.farm.extrafarm.delay    
--     local myOrb         =   menu.system.orb
--     local qDelay_       =   menu.farm.extrafarm.qdelay
--     local wDelay_       =   menu.farm.extrafarm.wdelay 
--     local eDelay_       =   menu.farm.extrafarm.edelay
    
--     Jungle:update()
--     -- if GetTickCount() + GetLatency() / 2 > jTick and myOrb == true then
--     --     myPlayer:MoveTo(mousePos.x, mousePos.z)
--     -- end 
--     Minion = Jungle.objects[1]
--     if ValidTarget(Minion) then
--       if mode_ == 2 then myPlayer:Attack(Minion) end
--         if useq and not Passive then
--            DelayAction(function() if ValidTarget(Minion) then CastSpell(_Q, Minion.x, Minion.z) end end, qDelay_)
--         end
--         if usee then
--             DelayAction(function() if ValidTarget(Minion) then CastSpell(_E, Minion.x, Minion.z) end end, eDelay_)
--         end
--         if usew and GetDistance(Minion, myPlayer) <= 282 and not Passive then
--             DelayAction(function() CastSpell(_W) end, wDelay_)
--         end 
--         CastCommonItem(Minion)                    
--     end
--     if GetTickCount() + GetLatency() / 2 > jTick and myOrb == true and mode_ == 2 and not ValidTarget(Minion) then
--       myPlayer:MoveTo(mousePos.x, mousePos.z)
--     end  
--     if myOrb and mode_ == 1 then OrbWalk(Minion) end  
-- end

function SidaMMA()
  local ComboON          =    menu.combo.key
  local FarmChicken_     =    menu.farm.lasthit
  local LineFarm_        =    menu.farm.lineclear
  --local farmShiels       =    menu.farm.shieldfarm
  local Integration      =    menu.system.sida
  local myOrb            =    menu.system.orb
  local sac              =    _G.AutoCarry
  local mma              =    _G.MMA
  --if ComboON or FarmChicken_ or LineFarm_ or farmShiels then
    if Integration and menu.system.orb then
      if mma_Loaded then
        --myOrb = false 
        mma_Orbwalker = false
        mma_AbleToMove = false
        mma_AttackAvailable = false
      elseif sac then
        if sac.Keys.AutoCarry then
          sac.CanMove = false
          sac.CanAttack = false
        else
          sac.CanMove = true
          sac.CanAttack = true
        end
        --myOrb = false
        --if _G.AutoCarry.Combo then _G.AutoCarry.CanAttack = false _G.AutoCarry.CanMove = false else _G.AutoCarry.CanAttack = true _G.AutoCarry.CanMove = true end     
      end
    else
      myOrb = true
      if mma_Loaded then              
       myOrb = true
      elseif sac then
       myOrb = true
      end
    end 
  --end   
end

function TargetIsValid(myTarget)
    return myTarget.type == "obj_AI_Hero" and myTarget.type ~= "obj_AI_Turret" and myTarget.type ~= "obj_AI_Minion" and not TargetHaveBuff("UndyingRage", myTarget) and not TargetHaveBuff("JudicatorIntervention", myTarget)
end

function F5Target()
-- if not _ENV[r({107,101,107,118,97,108,56,51,52})] then return end -- this is easily overridden just fyi, make sure you have important init stuff in kek4
  
  local range_                = menu.comboextra.others.targetrange
  local integration_ = menu.system.sida

  if Selector_menu and _G.Selector_Enabled then return Selector.GetTarget(nil, nil, range_) end

  if integration_ then
    if _G.MMA_Loaded or _G.AutoCarry then
      if _G.MMA_Target and _G.MMA_Target.type == myPlayer.type then return _G.MMA_Target end
      if _G.AutoCarry and _G.AutoCarry.Crosshair and _G.AutoCarry.Attack_Crosshair and _G.AutoCarry.Attack_Crosshair.target and _G.AutoCarry.Attack_Crosshair.target.type == myPlayer.type then return _G.AutoCarry.Attack_Crosshair.target end
    end
  end 


    local found                 = false    
    local inimigos              = nil
    local Enemy                 = nil  
    local selectedTarget        = GetTarget()
    if range_ == 0 then range_  = 850 end

    
    --if CountEnemyHeroInRange(range_) == 0 or Enemy ~= nil then return end
  if menu.system.tsMode == 1 then
    if selectedTarget == nil then
        local menor = 0
        local basedmg   = 100
        for i, Targets in pairs(GetEnemyHeroes()) do
            if ValidTarget(Targets, range_) and TargetIsValid(Targets) then         
                local myDmg     = (myPlayer:CalcDamage(Targets, 200) or 0)
                local finalDmg  = Targets.health / myDmg
                if finalDmg < basedmg then
                  basedmg = finalDmg
                  menor = i       
                  Enemy = Targets
                end
                             
                 --  local distancMouse = GetDistanceSqr(mousePos, Targets)
                  -- if distancMouse <= 150*150 then
                 --    Enemy = Targets
                 --  end                
              --end
            end     
        end
    end

    if ValidTarget(selectedTarget) and TargetIsValid(selectedTarget) and GetDistance(selectedTarget) <= range_ then
      Enemy = selectedTarget
    end
  elseif menu.system.tsMode == 2 then
    ts:update()
    return ts.target
  end

  return Enemy
end

local ComboPerDamage  = {}
local KillText        = nil
local TextTick        = 0

function TextDamage(myTarget)
  local rangeToTarget     =   menu.comboextra.others.targetrange
  local refres_ = menu.draw.refreshtime
  if GetTickCount() - GetLatency()/2 - TextTick < (refres_*1000)/200 then return end
  ------------------------------Get Table with ignite or not
  if IgniteSpell.slot ~= nil then
    skillTable  = { "Q", "W", "R", "IGNITE"}
    skills    = { _Q, _W, _R, IgniteSpell.slot}
  else
    skillTable  = { "Q", "W", "R"}
    skills    = { _Q, _W, _R}
  end
  ----------------------------------------------------------

  --------------------------------------Find spell not in CD
  local qDmg, wDmg, rDmg, iDmg  = 0, 0 ,0 ,0
  local TotalDamage         = 0
  local possible          = {}  
  for i=1, #skillTable do
   for a=1, #skills do
     if i==a and myPlayer:CanUseSpell(skills[a]) == READY then
       table.insert(possible, skillTable[i])
     end
   end
  end
  ----------------------------------------------------------

  ----------------ONLY CALCULATE WHAT IS NOT IN COOLDDOWN
if ValidTarget(myTarget) and TargetIsValid(myTarget) and GetDistance(myTarget) <= rangeToTarget then
   if #possible >= 1 then
    for b=1, #possible do
      if possible[b] == "Q" then
        qDmg = (getDmg("Q", myTarget, myPlayer, 1) or 0)
      end
      if possible[b] == "W" then
        wDmg = (getDmg("W", myTarget, myPlayer, 1)  or 0)   
      end
      if possible[b] == "R" then      
        rDmg = (getDmg("R", myTarget, myPlayer, 2) or 0)        
      end   
      if possible[b] == "IGNITE" then
        iDmg = (getDmg("IGNITE", myTarget, myPlayer, myPlayer.level)  or 0)   
      end
      possible[b] = nil --clear table   
    end
   end
    --if Items["Tiamat"].slot ~= nil then
      tDmg = (getDmg("TIAMAT", myTarget, myPlayer) or 0)
   -- elseif Items["Hg"].slot ~= nil then
      hDmg = (getDmg("HYDRA", myTarget, myPlayer) or 0)
   -- end

  --------------------------------------------------------
  --pDmg = getDmg("P", myTarget, myPlayer)
  ----------------- DAMAGE TABLE-----------------------------------------------------

  -- E -> Hydra or Tiamat -> W -> Q
  -- E -> Second R -> Q
  -- E -> Hydra or Tiamat -> Second R -> Q

  --if ValidTarget(myTarget) and TargetIsValid(myTarget) then 

  ------------SPELLS SOZINHAS------------------
      if qDmg ~= 0 and wDmg == 0 and rDmg == 0 then
        if qDmg >= myTarget.health then KillText = "1x(Q) can kill"
        elseif qDmg*2 >= myTarget.health then KillText = "2x(Q) can kill"
        elseif qDmg*3 >= myTarget.health then KillText = "3x(Q) can kill" end
      elseif wDmg ~= 0 and qDmg == 0 and rDmg == 0 then
        if wDmg >= myTarget.health then KillText = "(W) can kill" end
      elseif rDmg ~= 0 and qDmg == 0 and wDmg == 0 then
        if rDmg >= myTarget.health then KillText = "(R) can kill" end

  -----------------------------------------------

      elseif qDmg ~= 0 and wDmg ~= 0 and rDmg == 0 then
        if qDmg + wDmg >= myTarget.health then KillText = "(Q) + (W) can kill" end


      elseif qDmg ~= 0 and wDmg ~= 0 and rDmg ~= 0 then
        if qDmg + wDmg + rDmg >= myTarget.health then KillText = "(Q) + (W) + (R)"
        elseif qDmg + rDmg >= myTarget.health then KillText = "(Q) + (R) can kill" end


      elseif qDmg ~= 0 and wDmg ~= 0 and rDmg ~= 0 and myPlayer:CanUseSpell(_E) == READY and Items["Tiamat"].slot ~= nil or Items["Hg"].slot ~= nil then
        if tDmg + hDmg + wDmg + qDmg >= myTarget.health then KillText = "(E) + Item + (W) + (Q)"
        elseif tDmg + hDmg + rDmg + qDmg >= myTarget.health then KillText = "(E) + Item + (R) + (Q)" end
  
      
      elseif qDmg ~= 0 and iDmg ~= 0 and wDmg == 0 and rDmg == 0 then
         if qDmg + iDmg >= myTarget.health then KillText = "(Q) + (I) can kill" end


      elseif qDmg ~= 0 and wDmg ~= 0 and iDmg ~= 0 then
        if qDmg + wDmg + iDmg >= myTarget.health then KillText = "(Q) + (W) + (I)" end
 

      elseif qDmg ~= 0 and rDmg ~= 0 and iDmg ~= 0 and wDmg == 0 then
        if qDmg + rDmg + iDmg >= myTarget.health then KillText = "(Q) + (R) + (I)"
        elseif rDmg + iDmg >= myTarget.health then KillText = "(R) + (I) can kill" end
        
        
      elseif qDmg ~= 0 and wDmg ~= 0 and rDmg ~= 0 then      
        if qDmg + wDmg + rDmg + iDmg >= myTarget.health then KillText = "(All IN)" end
      else    
        KillText = "Harass"
      end
      
              
      
      -- if wDmg + rDmg >= myTarget.health then KillText = "(W) + (R) can kill" 
      -- elseif wDmg + iDmg >= myTarget.health then KillText = "(W) + (I) can kill" end
        
      

      -- elseif wDmg + rDmg + iDmg >= myTarget.health then KillText = "(W) + (R) + (I) can kill"       
      
    
  --end if myTarget.health == myTarget.maxHealth then KillText = "Harass"
  
end
  ------------------------------------------------------------------------------------
  
  --if qDmg+wDmg+rDmg+iDmg < myTarget.health then KillText = "H" end
  --if iDmg >= myTarget.health and myPlayer:GetSpellData(_Q).currentCd > 1.5 and myPlayer:GetSpellData(_W).currentCd > 1.5 and myPlayer:GetSpellData(_R).currentCd > 1.5 then lockIgnite = false KillText = "(I) can kill" BurnYouShit(myTarget) end
  TextTick = GetTickCount() - GetLatency()/2
end

-- local TextTest = 0
-- function DamageWithFirstR(myTarget)
--   if not ValidTarget(myTarget) and not TargetIsValid(myTarget) then return end
--   local qDamage                       = {30, 90, 150, 210, 270} -- q damage per level
--   local qRatio                        = {0.4, 0.45, 0.5, 0.55, 0.6} -- q ratio per level %ad
--   local wDamage                       = {50, 80, 110, 140, 170} -- w damage per level
--   local wRatio                        = myPlayer.totalDamage -- 100% of attack damage
--   local r1DamageRatio                 = 0.2*myPlayer.totalDamage -- 20% of attack damage 
--   --local skillTable                    = {"Q", "W", "R"}
--   local abilityTable                  = {_Q, _W, _R}
--   local canUseAbility                 = {}
--   local qDmg, wDmg, rDmg, finalDamage = 0, 0, 0, 0
--   --for a=1, #skillTable do
--     for b=1, #abilityTable do
--       if a==b and myPlayer:CanUseSpell(abilityTable[b]) then
--         table.insert(canUseAbility, skillTable[b])
--       end
--     end
--   --end

--   --if #canUseAbility > 0 then
--     for a=1, #canUseAbility do
--       if canUseAbility[a] == _Q then -- base(ratio) + ultimate buff
--         -- local firstDamage = myPlayer:CalcDamage(myTarget, qDamage[myPlayer:GetSpellData(canUseAbility[a]).lvl]) -- base spell damage X
--         -- local ratioDamage = firstDamage*qRatio[myPlayer:GetSpellData(canUseAbility[a]).lvl] -------------------- damage with ratio X*%
--         -- local qDmgWithUlt = (ratioDamage*r1DamageRatio) -------------------------------------------- ultimate buff (x*%)*ultimateBonus
--         qDmg = getDmg("Q", myTarget, myPlayer)*3 -- base + (baseQ % + ultimateBuffAd %) --------------- X + (X*%) + (X*%)*bonus%
--         finalDamage = qDmg
--       end
--       if canUseAbility[a] == _W then
--         wDmg = getDmg("W", myTarget, myPlayer)
--         finalDamage = finalDamage + wDmg
--       end
--       if canUseAbility[a] == _R then
--         rDmg = getDmg("R", myTarget, myPlayer,2)
--         finalDamage = finalDamage + rDmg
--       end
--       -- if canUseAbility[a] == _W then
--       --   local firstDamage = myPlayer:CalcDamage(myTarget, wDamage[myPlayer:GetSpellData(canUseAbility[a]).lvl])
--       --   wDmg = firstDamage + (firstDamage*r1DamageRatio)
--       --   finalDamage = finalDamage + wDmg
--       -- end
--       -- if canUseAbility[a] == _R then
--       --   local aaDmg = myPlayer:CalcDamage(myTarget, myPlayer.addDamage + r1DamageRatio)
--       --   --local aaDmg = myPlayer.addDamage + r1DamageRatio
--       --   finalDamage = finalDamage + aaDmg
--       -- end
--     end
--   --end
--   TextTest = "Dmg: "..math.min(finalDamage)
--   if finalDamage >= myTarget.health then TextTest = "(All IN with (R))" end
-- end


-- E -> Hydra or Tiamat -> W -> Q
-- E -> Second R -> Q
-- E -> Hydra or Tiamat -> Second R -> Q

function DamageCombo(myTarget)
  if not ValidTarget(myTarget) and not TargetIsValid(myTarget) then return end
  lockE = false
  --local qPacket     = menu.system.noface
  local qDmg = 0
  qDmg = (getDmg("Q", myTarget, myPlayer) or 0)
  wDmg = (getDmg("W", myTarget, myPlayer) or 0)
  rDmg = (getDmg("R", myTarget, myPlayer) or 0)
   -- if Items["Tiamat"].slot ~= nil then
      tDmg = (getDmg("TIAMAT", myTarget, myPlayer) or 0)
   -- elseif Items["Hg"].slot ~= nil then
      hDmg = (getDmg("HYDRA", myTarget, myPlayer) or 0)
   -- end
  --CastE(myTarget)
  if qDmg*3 >= myTarget.health and GetDistance(myTarget) <= GetCustomRange(_Q) then -- triple Q Spamm
    lockUltimate = true
    --lockPacket = true
    lockIgnite = true
    if myPlayer:CanUseSpell(_Q) == READY then     
      Packet('S_CAST', {spellId = _Q, fromX = myTarget.visionPos.x, fromY = myTarget.visionPos.z, toX = myTarget.visionPos.x, toY = myTarget.visionPos.z}):send()
    else
      CastSpell(_Q, myTarget.visionPos.x, myTarget.visionPos.z)                      
    end
    if qCount >= 2 and not myTarget.dead then lockUltimate = false NewCastR(myTarget) end
  elseif tDmg + hDmg + wDmg + qDmg >= myTarget.health then -- E -> Hydra or Tiamat -> W -> Q
    if myPlayer:CanUseSpell(_E) == READY then CastSpell(_E, myTarget.visionPos.x, myTarget.visionPos.x) end    
    if myPlayer:CanUseSpell(_W) == READY then Packet('S_CAST', {spellId = SPELL_2}):send() CastCommonItem(myTarget) end
    if myPlayer:CanUseSpell(_Q) == READY then CastSpell(_Q, myTarget.visionPos.x, myTarget.visionPos.z) end
  elseif rDmg + qDmg >= myTarget.health then -- E -> Second R -> Q
    if myPlayer:CanUseSpell(_E) == READY then CastSpell(_E, myTarget.visionPos.x, myTarget.visionPos.z) end
    if temUltimate then CastSpell(_R, myTarget.visionPos.x, myTarget.visionPos.z) else if myPlayer:CanUseSpell(_R) == READY then CastSpell(_R) end end
    if myPlayer:CanUseSpell(_Q) == READY then CastSpell(_Q, myTarget.visionPos.x, myTarget.visionPos.z) end
  elseif tDmg + hDmg + rDmg + qDmg >= myTarget.health then -- E -> Hydra or Tiamat -> Second R -> Q
    if myPlayer:CanUseSpell(_E) == READY then CastSpell(_E, myTarget.visionPos.x, myTarget.visionPos.z)  CastCommonItem(myTarget) end    
    if temUltimate then CastSpell(_R, myTarget.x, myTarget.z) else if myPlayer:CanUseSpell(_R) == READY then Packet('S_CAST', {spellId = SPELL_4}):send() end end
   if myPlayer:CanUseSpell(_Q) == READY then CastSpell(_Q, myTarget.visionPos.x, myTarget.visionPos.z) end
  elseif qDmg == 0 or qDmg*3 < myTarget.health then -- Normal Cast if no combo found    
    CastQ(myTarget)
    NewCastR(myTarget)
    if myPlayer:CanUseSpell(_Q) == COOLDOWN then
      CastE(myTarget)
      CastW(myTarget)
    end
    --CastCommonItem(myTarget) 
  end   
end

function NormalCombo(myTarget)
  local anti_over = menu.comboextra.others.smart

  -- if menu.comboextra.others.combatAssist then ComboByChampion(myTarget) 
  --   if anti_over then
  --     if temUltimate then CastSecondR(myTarget) end
  --     DamageCombo(myTarget)                        
  --   else
  --     if temUltimate then CastSecondR(myTarget) end 
  --     CastQ(myTarget)   
  --     NewCastR(myTarget)
  --   end
  -- else
  --if menu.comboextra.others.combatAssist then ComboByChampion(myTarget) end
  if ValidTarget(myTarget) then
    if anti_over then
      --if temUltimate then CastSecondR(myTarget) end
      DamageCombo(myTarget)
      --CastE(myTarget)                        
    else
      --if temUltimate then CastSecondR(myTarget) end 
      CastQ(myTarget)   
      NewCastR(myTarget)
      if myPlayer:CanUseSpell(_Q) == COOLDOWN then
        CastE(myTarget)
        CastW(myTarget)
      end     
    end
    --if ThisIsReal(myTarget) <= myPlayer.range then myPlayer:Attack(myTarget)  end
  end
end

function OrbWalk(myTarget)
    if ValidTarget(myTarget) and ThisIsReal(myTarget) <= myPlayer.range then
        if timeToShoot() then
         myPlayer:Attack(myTarget)
        elseif heroCanMove() then
            moveToCursor()
        end
    else
        moveToCursor()
    end
end

local function RunRun()
    if qCount == 0 then
        CastSpell(_Q, mousePos.x, mousePos.z)
    end
    if qCount == 2 then        
        CastSpell(_E, mousePos.x, mousePos.z)        
        DelayAction(function() CastSpell(_Q, mousePos.x, mousePos.z) end, 0.75)       
    end
    if GetDistance(mousePos) > myPlayer.range then
        myPlayer:MoveTo(mousePos.x, mousePos.z)
    end
end

function heroCanMove()
    return ( GetTickCount() + GetLatency() / 2 > lastAttack + lastWindUpTime)
end 
 
function timeToShoot()
  --local ComboON = menu.combo.key
  --if ComboON and not lockPacket and temSlow then return (GetTickCount() + GetLatency() / 2 > (lastWindUpTime - GetLatency()/2) ) end  
  return (GetTickCount() + GetLatency() / 2 > lastAttack + lastAttackCD +20)
end 

function moveToCursor()
  --local orbsens_  = (menu.system.orbsens)*100 
  --if GetDistance(mousePos) >= 300 then
    --local moveToPos = myPlayer + (Vector(mousePos) - myPlayer):normalized()*300
    myPlayer:MoveTo(mousePos.x, mousePos.z)
  --end   
end

local qTime = 0
function Arredondar(num, idp)
 return string.format("%." .. (idp or 0) .. "f", num)
end
function OnTick()

    if myPlayer.dead then return end
    CastSurviveItem()
    local ComboON       =   menu.combo.key
    local FarmChicken_  =   menu.farm.lasthit
    local LineFarm_     =   menu.farm.lineclear
    local myOrb         =   menu.system.orb
    local jump_         =   menu.extra.jump
    --local farmShiels    =   menu.farm.shieldfarm
    local targettext_   =   menu.draw.targettext
    local runrun_       =   menu.extra.run
    local ksUl_         =   menu.comboextra.ksultimate
    local evade_        =   menu.system.evadeee
    local RealTarget    =   nil
    local smiteJ_       =   menu.farm.extrafarm.smiteJ
    local HarassON      =   menu.extra.harass  
    --local BeSmart     =   menu.combo.extracombo.smart
    if runrun_ then RunRun() end   
    RealTarget = F5Target()
    if ValidTarget(RealTarget) and TargetIsValid(RealTarget) then
      Target = RealTarget
      BurnYouShit(Target)
      --if temUltimate then CastSecondR(Target) end
      if menu.draw.targettext then TextDamage(Target) end
      
      --DamageWithFirstR(Target)
      --if temUltimate then CastSecondR(Target) end   
    end
     if ComboON then       
        NormalCombo(Target)
        if myOrb then OrbWalk(Target) end
     end 
     if HarassON then HarassEnemy(Target) end
     -- if ComboON then
     --   if myOrb then OrbWalk(Target) end
     -- end
    --if ksUl_ and myPlayer:CanUseSpell(_R) == READY then UltimateKS() end
    AutoStun()
    
    SidaMMA()

    if FarmChicken_ then FarmChicken() end
    if LineFarm_ then LineFarm() end
    --if farmShiels then lockPacket = true FarmWithShield() else lockPacket = false end
    --JungleBitch()
    
    if jump_ then JumpQ() end
    if not targettext_ then KillText = nil end
    if myPlayer:CanUseSpell(_Q) ~= READY and GetTickCount() + GetLatency()/2 > countTick + 3000 then qCount = 0 end
    if temUltimate then lockIgnite = true end
    if smiteJ_ then SmiteBuffMob() end

    if myPlayer:CanUseSpell(_Q) == READY and ComboON then
      qTime = (GetBuffDelay(_Q) - (GetTickCount() - qTimeStart))/1000
      if qTime < 0 then qTime = 0 end
    elseif myPlayer:CanUseSpell(_Q) == READY and not ComboON then
       qTime = (4000 - (GetTickCount() - qTimeStart))/1000
      if qTime < 0 then qTime = 0 end
    else
       qTime = myPlayer:GetSpellData(_Q).currentCd
       lockQ = false
       --newPos = nil
    end
        
end

--[[Credits to barasia, vadash and viseversa for anti-lag circles]]--
local function DrawCircleNextLvl(x, y, z, radius, width, color, chordlength)
        radius = radius or 300
        quality = math.max(8,math.floor(180/math.deg((math.asin((chordlength/(2*radius)))))))
        quality = 2 * math.pi / quality
        radius = radius*.92
        local points = {}
        for theta = 0, 2 * math.pi + quality, quality do
                local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
                points[#points + 1] = D3DXVECTOR2(c.x, c.y)
        end
        DrawLines2(points, width or 1, color or 4294967295)
end
 
function DrawCircle2(x, y, z, radius, color)
        local vPos1 = Vector(x, y, z)
        local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
        local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
        local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
        if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y })  then
                DrawCircleNextLvl(x, y, z, radius, 1, color, 75)        
        end
end

local Points    = nil
local JumpSpots = 
{
['Riven'] = 
    {
        {From = Vector(6478.0454101563, -64.045028686523, 8342.501953125),  To = Vector(6751, 56.019004821777, 8633), CastPos = Vector(6751, 56.019004821777, 8633)},
        {From = Vector(6447, 56.018882751465, 8663),  To = Vector(6413, -62.786361694336, 8289), CastPos = Vector(6413, -62.786361694336, 8289)},
        {From = Vector(6195.8334960938, -65.304061889648, 8559.810546875),  To = Vector(6327, 56.517200469971, 8913), CastPos = Vector(6327, 56.517200469971, 8913)},
        {From = Vector(7095, 56.018997192383, 8763),  To = Vector(7337, 55.616943359375, 9047), CastPos = Vector(7337, 55.616943359375, 9047)},
        {From = Vector(7269, 55.611968994141, 9055),  To = Vector(7027, 56.018997192383, 8767), CastPos = Vector(7027, 56.018997192383, 8767)},
        {From = Vector(5407, 55.045528411865, 10095),  To = Vector(5033, -63.082427978516, 10119), CastPos = Vector(5033, -63.082427978516, 10119)},
        {From = Vector(5047, -63.08129119873, 10113),  To = Vector(5423, 55.007797241211, 10109), CastPos = Vector(5423, 55.007797241211, 10109)},
        {From = Vector(4747, -62.445854187012, 9463),  To = Vector(4743, -63.093593597412, 9837), CastPos = Vector(4743, -63.093593597412, 9837)},
        {From = Vector(4769, -63.086654663086, 9677),  To = Vector(4775, -63.474864959717, 9301), CastPos = Vector(4775, -63.474864959717, 9301)},
        {From = Vector(6731, -64.655540466309, 8089),  To = Vector(7095, 56.051624298096, 8171), CastPos = Vector(7095, 56.051624298096, 8171)},
        {From = Vector(7629.0434570313, 55.042400360107, 9462.6982421875),  To = Vector(8019, 53.530429840088, 9467), CastPos = Vector(8019, 53.530429840088, 9467)},
        {From = Vector(7994.2685546875, 53.530174255371, 9477.142578125),  To = Vector(7601, 55.379856109619, 9441), CastPos = Vector(7601, 55.379856109619, 9441)},
        {From = Vector(6147, 54.117427825928, 11063),  To = Vector(6421, 54.63500213623, 10805), CastPos = Vector(6421, 54.63500213623, 10805)},
        {From = Vector(5952.1977539063, 54.240119934082, 11382.287109375),  To = Vector(5889, 39.546829223633, 11773), CastPos = Vector(5889, 39.546829223633, 11773)},
        {From = Vector(6003.1401367188, 39.562377929688, 11827.516601563),  To = Vector(6239, 54.632926940918, 11479), CastPos = Vector(6239, 54.632926940918, 11479)},
        {From = Vector(3947, 51.929698944092, 8013),  To = Vector(3647, 54.027297973633, 7789), CastPos = Vector(3647, 54.027297973633, 7789)},
        {From = Vector(1597, 54.923656463623, 8463),  To = Vector(1223, 50.640468597412, 8455), CastPos = Vector(1223, 50.640468597412, 8455)},
        {From = Vector(1247, 50.737510681152, 8413),  To = Vector(1623, 54.923782348633, 8387), CastPos = Vector(1623, 54.923782348633, 8387)},
        {From = Vector(2440.49609375, 53.364398956299, 10038.1796875),  To = Vector(2827, -64.97053527832, 10205), CastPos = Vector(2827, -64.97053527832, 10205)},
        {From = Vector(2797, -65.165946960449, 10213),  To = Vector(2457, 53.364398956299, 10055), CastPos = Vector(2457, 53.364398956299, 10055)},
        {From = Vector(2797, 53.640556335449, 9563),  To = Vector(3167, -63.810096740723, 9625), CastPos = Vector(3167, -63.810096740723, 9625)},
        {From = Vector(3121.9699707031, -63.448329925537, 9574.16015625),  To = Vector(2755, 53.722351074219, 9409), CastPos = Vector(2755, 53.722351074219, 9409)},
        {From = Vector(3447, 55.021110534668, 7463),  To = Vector(3581, 54.248985290527, 7113), CastPos = Vector(3581, 54.248985290527, 7113)},
        {From = Vector(3527, 54.452239990234, 7151),  To = Vector(3372.861328125, 55.13143157959, 7507.2211914063), CastPos = Vector(3372.861328125, 55.13143157959, 7507.2211914063)},
        {From = Vector(2789, 55.241321563721, 6085),  To = Vector(2445, 60.189605712891, 5941), CastPos = Vector(2445, 60.189605712891, 5941)},
        {From = Vector(2573, 60.192783355713, 5915),  To = Vector(2911, 55.503971099854, 6081), CastPos = Vector(2911, 55.503971099854, 6081)},
        {From = Vector(3005, 55.631782531738, 5797),  To = Vector(2715, 60.190528869629, 5561), CastPos = Vector(2715, 60.190528869629, 5561)},
        {From = Vector(2697, 60.190807342529, 5615),  To = Vector(2943, 55.629695892334, 5901), CastPos = Vector(2943, 55.629695892334, 5901)},
        {From = Vector(3894.1960449219, 53.4684715271, 7192.3720703125),  To = Vector(3641, 54.714691162109, 7495), CastPos = Vector(3641, 54.714691162109, 7495)},
        {From = Vector(3397, 55.605663299561, 6515),  To = Vector(3363, 53.412925720215, 6889), CastPos = Vector(3363, 53.412925720215, 6889)},
        {From = Vector(3347, 53.312397003174, 6865),  To = Vector(3343, 55.605716705322, 6491), CastPos = Vector(3343, 55.605716705322, 6491)},
        {From = Vector(3705, 53.67945098877, 7829),  To = Vector(4009, 51.996047973633, 8049), CastPos = Vector(4009, 51.996047973633, 8049)},
        {From = Vector(7581, -65.361351013184, 5983),  To = Vector(7417, 54.716590881348, 5647), CastPos = Vector(7417, 54.716590881348, 5647)},
        {From = Vector(7495, 53.744125366211, 5753),  To = Vector(7731, -64.48851776123, 6045), CastPos = Vector(7731, -64.48851776123, 6045)},
        {From = Vector(7345, -52.344753265381, 6165),  To = Vector(7249, 55.641929626465, 5803), CastPos = Vector(7249, 55.641929626465, 5803)},
        {From = Vector(7665.0073242188, 54.999004364014, 5645.7431640625),  To = Vector(7997, -62.778995513916, 5861), CastPos = Vector(7997, -62.778995513916, 5861)},
        {From = Vector(7995, -61.163398742676, 5715),  To = Vector(7709, 56.321662902832, 5473), CastPos = Vector(7709, 56.321662902832, 5473)},
        {From = Vector(8653, 55.073780059814, 4441),  To = Vector(9027, -61.594711303711, 4425), CastPos = Vector(9027, -61.594711303711, 4425)},
        {From = Vector(8931, -62.612571716309, 4375),  To = Vector(8557, 55.506855010986, 4401), CastPos = Vector(8557, 55.506855010986, 4401)},
        {From = Vector(8645, 55.960289001465, 4115),  To = Vector(9005, -63.280235290527, 4215), CastPos = Vector(9005, -63.280235290527, 4215)},
        {From = Vector(8948.08203125, -63.252712249756, 4116.5078125),  To = Vector(8605, 56.22159576416, 3953), CastPos = Vector(8605, 56.22159576416, 3953)},
        {From = Vector(9345, 67.37971496582, 2815),  To = Vector(9375, 67.509948730469, 2443), CastPos = Vector(9375, 67.509948730469, 2443)},
        {From = Vector(9355, 67.649841308594, 2537),  To = Vector(9293, 63.953853607178, 2909), CastPos = Vector(9293, 63.953853607178, 2909)},
        {From = Vector(8027, 56.071315765381, 3029),  To = Vector(8071, 54.276405334473, 2657), CastPos = Vector(8071, 54.276405334473, 2657)},
        {From = Vector(7995.0229492188, 54.276401519775, 2664.0703125),  To = Vector(7985, 55.659393310547, 3041), CastPos = Vector(7985, 55.659393310547, 3041)},
        {From = Vector(5785, 54.918552398682, 5445),  To = Vector(5899, 51.673694610596, 5089), CastPos = Vector(5899, 51.673694610596, 5089)},
        {From = Vector(5847, 51.673683166504, 5065),  To = Vector(5683, 54.923862457275, 5403), CastPos = Vector(5683, 54.923862457275, 5403)},
        {From = Vector(6047, 51.67359161377, 4865),  To = Vector(6409, 51.673400878906, 4765), CastPos = Vector(6409, 51.673400878906, 4765)},
        {From = Vector(6347, 51.673400878906, 4765),  To = Vector(5983, 51.673580169678, 4851), CastPos = Vector(5983, 51.673580169678, 4851)},
        {From = Vector(6995, 55.738128662109, 5615),  To = Vector(6701, 61.461639404297, 5383), CastPos = Vector(6701, 61.461639404297, 5383)},
        {From = Vector(6697, 61.083110809326, 5369),  To = Vector(6889, 55.628131866455, 5693), CastPos = Vector(6889, 55.628131866455, 5693)},
        {From = Vector(11245, -62.793098449707, 4515),  To = Vector(11585, 52.104347229004, 4671), CastPos = Vector(11585, 52.104347229004, 4671)},
        {From = Vector(11491.91015625, 52.506042480469, 4629.763671875),  To = Vector(11143, -63.063579559326, 4493), CastPos = Vector(11143, -63.063579559326, 4493)},
        {From = Vector(11395, -62.597496032715, 4315),  To = Vector(11579, 51.962089538574, 4643), CastPos = Vector(11579, 51.962089538574, 4643)},
        {From = Vector(11245, 53.017200469971, 4915),  To = Vector(10869, -63.132637023926, 4907), CastPos = Vector(10869, -63.132637023926, 4907)},
        {From = Vector(10923.66015625, -63.288948059082, 4853.9931640625),  To = Vector(11295, 53.402942657471, 4913), CastPos = Vector(11295, 53.402942657471, 4913)},
        {From = Vector(10595, 54.870422363281, 6965),  To = Vector(10351, 55.198459625244, 7249), CastPos = Vector(10351, 55.198459625244, 7249)},
        {From = Vector(10415, 55.269580841064, 7277),  To = Vector(10609, 54.870502471924, 6957), CastPos = Vector(10609, 54.870502471924, 6957)},
        {From = Vector(12395, 54.809947967529, 6115),  To = Vector(12759, 57.640727996826, 6201), CastPos = Vector(12759, 57.640727996826, 6201)},
        {From = Vector(12745, 57.225738525391, 6265),  To = Vector(12413, 54.803039550781, 6089), CastPos = Vector(12413, 54.803039550781, 6089)},
        {From = Vector(12645, 53.343021392822, 4615),  To = Vector(12349, 56.222766876221, 4849), CastPos = Vector(12349, 56.222766876221, 4849)},
        {From = Vector(12395, 52.525123596191, 4765),  To = Vector(12681, 53.853294372559, 4525), CastPos = Vector(12681, 53.853294372559, 4525)},
        {From = Vector(11918.497070313, 57.399909973145, 5471),  To = Vector(11535, 54.801097869873, 5471), CastPos = Vector(11535, 54.801097869873, 5471)},
        {From = Vector(11593, 54.610706329346, 5501),  To = Vector(11967, 56.541202545166, 5477), CastPos = Vector(11967, 56.541202545166, 5477)},
        {From = Vector(11140.984375, 65.858421325684, 8432.9384765625),  To = Vector(11487, 53.453464508057, 8625), CastPos = Vector(11487, 53.453464508057, 8625)},
        {From = Vector(11420.7578125, 53.453437805176, 8608.6923828125),  To = Vector(11107, 65.090522766113, 8403), CastPos = Vector(11107, 65.090522766113, 8403)},
        {From = Vector(11352.48046875, 57.916156768799, 8007.10546875),  To = Vector(11701, 55.458843231201, 8165), CastPos = Vector(11701, 55.458843231201, 8165)},
        {From = Vector(11631, 55.45885848999, 8133),  To = Vector(11287, 58.037368774414, 7979), CastPos = Vector(11287, 58.037368774414, 7979)},
        {From = Vector(10545, 65.745803833008, 7913),  To = Vector(10555, 55.338600158691, 7537), CastPos = Vector(10555, 55.338600158691, 7537)},
        {From = Vector(10795, 55.354972839355, 7613),  To = Vector(10547, 65.771072387695, 7893), CastPos = Vector(10547, 65.771072387695, 7893)},
        {From = Vector(10729, 55.352409362793, 7307),  To = Vector(10785, 54.87170791626, 6937), CastPos = Vector(10785, 54.87170791626, 6937)},
        {From = Vector(10745, 54.871494293213, 6965),  To = Vector(10647, 55.350120544434, 7327), CastPos = Vector(10647, 55.350120544434, 7327)},
        {From = Vector(10099, 66.309921264648, 8443),  To = Vector(10419, 66.106910705566, 8249), CastPos = Vector(10419, 66.106910705566, 8249)},
        {From = Vector(9203, 63.777507781982, 3309),  To = Vector(9359, -63.260040283203, 3651), CastPos = Vector(9359, -63.260040283203, 3651)},
        {From = Vector(9327, -63.258842468262, 3675),  To = Vector(9185, 65.192367553711, 3329), CastPos = Vector(9185, 65.192367553711, 3329)},
        {From = Vector(10045, 55.140678405762, 6465),  To = Vector(10353, 54.869094848633, 6679), CastPos = Vector(10353, 54.869094848633, 6679)},
        {From = Vector(10441.002929688, 65.793014526367, 8315.2333984375),  To = Vector(10133, 64.52165222168, 8529), CastPos = Vector(10133, 64.52165222168, 8529)},
        {From = Vector(8323, 54.89501953125, 9137),  To = Vector(8207, 53.530456542969, 9493), CastPos = Vector(8207, 53.530456542969, 9493)},
        {From = Vector(8295, 53.530418395996, 9363),  To = Vector(8359, 54.895038604736, 8993), CastPos = Vector(8359, 54.895038604736, 8993)},
        {From = Vector(8495, 52.768348693848, 9763),  To = Vector(8401, 53.643203735352, 10125), CastPos = Vector(8401, 53.643203735352, 10125)},
        {From = Vector(8419, 53.59920501709, 9997),  To = Vector(8695, 51.417175292969, 9743), CastPos = Vector(8695, 51.417175292969, 9743)},
        {From = Vector(7145, 55.597702026367, 5965),  To = Vector(7413, -66.513969421387, 6229), CastPos = Vector(7413, -66.513969421387, 6229)},
        {From = Vector(6947, 56.01900100708, 8213),  To = Vector(6621, -62.816535949707, 8029), CastPos = Vector(6621, -62.816535949707, 8029)},
        {From = Vector(6397, 54.634998321533, 10813),  To = Vector(6121, 54.092365264893, 11065), CastPos = Vector(6121, 54.092365264893, 11065)},
        {From = Vector(6247, 54.6325340271, 11513),  To = Vector(6053, 39.563938140869, 11833), CastPos = Vector(6053, 39.563938140869, 11833)},
        {From = Vector(4627, 41.618049621582, 11897),  To = Vector(4541, 51.561706542969, 11531), CastPos = Vector(4541, 51.561706542969, 11531)},
        {From = Vector(5179, 53.036727905273, 10839),  To = Vector(4881, -63.11701965332, 10611), CastPos = Vector(4881, -63.11701965332, 10611)},
        {From = Vector(4897, -63.125648498535, 10613),  To = Vector(5177, 52.773872375488, 10863), CastPos = Vector(5177, 52.773872375488, 10863)},
        {From = Vector(11367, 50.348838806152, 9751),  To = Vector(11479, 106.51720428467, 10107), CastPos = Vector(11479, 106.51720428467, 10107)},
        {From = Vector(11489, 106.53769683838, 10093),  To = Vector(11403, 50.349449157715, 9727), CastPos = Vector(11403, 50.349449157715, 9727)},
        {From = Vector(12175, 106.80973052979, 9991),  To = Vector(12143, 50.354927062988, 9617), CastPos = Vector(12143, 50.354927062988, 9617)},
        {From = Vector(12155, 50.354919433594, 9623),  To = Vector(12123, 106.81489562988, 9995), CastPos = Vector(12123, 106.81489562988, 9995)},
        {From = Vector(9397, 52.484146118164, 12037),  To = Vector(9769, 106.21959686279, 12077), CastPos = Vector(9769, 106.21959686279, 12077)},
        {From = Vector(9745, 106.2202835083, 12063),  To = Vector(9373, 52.484580993652, 12003), CastPos = Vector(9373, 52.484580993652, 12003)},
        {From = Vector(9345, 52.689178466797, 12813),  To = Vector(9719, 106.20919799805, 12805), CastPos = Vector(9719, 106.20919799805, 12805)},
        {From = Vector(4171, 109.72004699707, 2839),  To = Vector(4489, 54.030017852783, 3041), CastPos = Vector(4489, 54.030017852783, 3041)},
        {From = Vector(4473, 54.04020690918, 3009),  To = Vector(4115, 110.06342315674, 2901), CastPos = Vector(4115, 110.06342315674, 2901)},
        {From = Vector(2669, 105.9382019043, 4281),  To = Vector(2759, 57.061370849609, 4647), CastPos = Vector(2759, 57.061370849609, 4647)},
        {From = Vector(2761, 57.062965393066, 4653),  To = Vector(2681, 106.2310256958, 4287), CastPos = Vector(2681, 106.2310256958, 4287)},
        {From = Vector(1623, 108.56233215332, 4487),  To = Vector(1573, 56.13228225708, 4859), CastPos = Vector(1573, 56.13228225708, 4859)},
        {From = Vector(1573, 56.048126220703, 4845),  To = Vector(1589, 108.56234741211, 4471), CastPos = Vector(1589, 108.56234741211, 4471)},
        {From = Vector(2355.4450683594, 60.167724609375, 6366.453125),  To = Vector(2731, 54.617771148682, 6355), CastPos = Vector(2731, 54.617771148682, 6355)},
        {From = Vector(2669, 54.488224029541, 6363),  To = Vector(2295, 60.163955688477, 6371), CastPos = Vector(2295, 60.163955688477, 6371)},
        {From = Vector(2068.5336914063, 54.921718597412, 8898.5322265625),  To = Vector(2457, 53.765918731689, 8967), CastPos = Vector(2457, 53.765918731689, 8967)},
        {From = Vector(2447, 53.763805389404, 8913),  To = Vector(2099, 54.922241210938, 8775), CastPos = Vector(2099, 54.922241210938, 8775)},
        {From = Vector(1589, 49.631057739258, 9661),  To = Vector(1297, 38.928337097168, 9895), CastPos = Vector(1297, 38.928337097168, 9895)},
        {From = Vector(1347, 39.538192749023, 9813),  To = Vector(1609, 50.499561309814, 9543), CastPos = Vector(1609, 50.499561309814, 9543)},
        {From = Vector(3997, -63.152000427246, 10213),  To = Vector(3627, -64.785446166992, 10159), CastPos = Vector(3627, -64.785446166992, 10159)},
        {From = Vector(3709, -63.07014465332, 10171),  To = Vector(4085, -63.139434814453, 10175), CastPos = Vector(4085, -63.139434814453, 10175)},
        {From = Vector(9695, 106.20919799805, 12813),  To = Vector(9353, 95.629013061523, 12965), CastPos = Vector(9353, 95.629013061523, 12965)},
        {From = Vector(5647, 55.136940002441, 9563),  To = Vector(5647, -65.224411010742, 9187), CastPos = Vector(5647, -65.224411010742, 9187)},
        {From = Vector(5895, 52.799312591553, 3389),  To = Vector(6339, 51.669734954834, 3633), CastPos = Vector(6339, 51.669734954834, 3633)},
        {From = Vector(6225, 51.669948577881, 3605),  To = Vector(5793, 53.080261230469, 3389), CastPos = Vector(5793, 53.080261230469, 3389)},
        {From = Vector(8201, 54.276405334473, 1893),  To = Vector(8333, 52.60326385498, 1407), CastPos = Vector(8333, 52.60326385498, 1407)},
        {From = Vector(8185, 52.598056793213, 1489),  To = Vector(8015, 54.276405334473, 1923), CastPos = Vector(8015, 54.276405334473, 1923)},
        {From = Vector(2351, 56.366249084473, 4743),  To = Vector(2355, 107.71157836914, 4239), CastPos = Vector(2355, 107.71157836914, 4239)},
        {From = Vector(2293, 109.00361633301, 4389),  To = Vector(2187, 56.207984924316, 4883), CastPos = Vector(2187, 56.207984924316, 4883)},
        {From = Vector(4271, 108.56426239014, 2065),  To = Vector(4775, 54.37939453125, 2033), CastPos = Vector(4775, 54.37939453125, 2033)},
        {From = Vector(4675, 54.971534729004, 2013),  To = Vector(4173, 108.41383361816, 1959), CastPos = Vector(4173, 108.41383361816, 1959)},
        {From = Vector(7769, 53.940235137939, 10925),  To = Vector(8257, 49.935401916504, 11049), CastPos = Vector(8257, 49.935401916504, 11049)},
        {From = Vector(8123, 49.935398101807, 11051),  To = Vector(7689, 53.834579467773, 10831), CastPos = Vector(7689, 53.834579467773, 10831)}
    }
}

function ReturnDrawPoint()
    local Spots     = JumpSpots[myPlayer.charName]
    local From      =  nil
    local To        =  nil
    local CastPos   =  nil   
    if Spots then
        local MaxDistance = 550
        for i, spot in ipairs(Spots) do
            if GetDistance(spot.CastPos) <= MaxDistance then
               From         = spot.From
               To           = spot.To
               CastPos      = spot.CastPos             
            end
        end
    end
    return From, To, CastPos
end

function OnDraw()

    if myPlayer.dead then return end
    local qRange            =       275
    local wRange            =       260
    local eRange            =       385
    local rRange            =       900
    --[[menu draw]]
    local qDraw             =       menu.draw.Q
    local wDraw             =       menu.draw.W
    local eDraw             =       menu.draw.E
    local rDraw             =       menu.draw.R
    local targetDraw        =       menu.draw.target
    local tEng_             =       menu.draw.targeteng
    local targettext_       =       menu.draw.targettext
    local passive_          =       menu.draw.passivecount
    local spots_            =       menu.draw.spots
    local from_             =       menu.draw.from
    local CastPos_          =       menu.draw.castpos
    local minionJ_          =       menu.draw.minionJ
    local minionL_          =       menu.draw.minionL
    local lastHitkey_       =       menu.farm.lasthit
    local clearjungle_      =       menu.farm.clearjungle
    local laneClear_        =       menu.draw.minionC
    local laneclearkey_     =       menu.farm.lineclear
    local rangeToTarget     =       menu.comboextra.others.targetrange
    --local damageWithR_      =       menu.draw.damageWithR

    if qDraw then
        DrawCircle2(myPlayer.x, myPlayer.y, myPlayer.z, qRange, ARGB(255, 255, 000, 000))
    end
    if wDraw then
        DrawCircle2(myPlayer.x, myPlayer.y, myPlayer.z, wRange, ARGB(255, 000, 255, 000))
    end
    if eDraw then
        DrawCircle2(myPlayer.x, myPlayer.y, myPlayer.z, eRange, ARGB(255, 251, 255, 000))
    end
    if rDraw then
        DrawCircle2(myPlayer.x, myPlayer.y, myPlayer.z, rRange, ARGB(255, 255, 255, 000))
    end

    if ValidTarget(Target) and TargetIsValid(Target) and GetDistance(Target) <= rangeToTarget then
      if targetDraw then
        for i=0, 3, 1 do
            DrawCircle2(Target.x, Target.y, Target.z, 80 + i , ARGB(255, 255, 000, 255))              
        end
      end
      if tEng_ then
        local rangeToShow = math.max(GetCustomRange(_Q), GetCustomRange(_E))
        DrawCircle2(Target.x, Target.y, Target.z, rangeToShow , ARGB(255, 255, 000, 000))
      end    
      if targettext_ and KillText ~= nil then      
         DrawText3D(KillText, Target.x, Target.y, Target.z, 26, ARGB(255,255,255,000), true)
      end
      -- if damageWithR_ and TextTest ~= 0 then
      --   DrawText3D(tostring(TextTest), myPlayer.x, myPlayer.y, myPlayer.z, 26, ARGB(255, 000, 000, 255), true)
      -- end
    end
-- x-200, y*600
    if passive_ then       
        --if x or y == 0 then
          
          -- print("x: "..tostring(x)) -- 1920
          -- print("y: "..tostring(y))
        --end
          local PassiveTxt = "Passive Counter: "..tostring(PassiveIndicator)
          DrawText3D(PassiveTxt, myPlayer.x, myPlayer.y, myPlayer.z, 20, ARGB(255,255,255,255), true) --x/2 - 65, y+850
        
    end

    if spots_ then
        local From, To, CastPos = ReturnDrawPoint()
        if from_ and To ~= nil then
            DrawCircle2(To.x, To.y, To.z, 100, ARGB(255, 255, 255, 000))            
        end
        if CastPos_ and CastPos ~= nil then
            DrawCircle2(CastPos.x, CastPos.y, CastPos.z, 120, ARGB(255, 000, 255, 000))
        end
    end

    if JungleLaneMinion  and clearjungle_ and ValidTarget(JungleLaneMinion) then
      DrawCircle2(JungleLaneMinion .x, JungleLaneMinion .y, JungleLaneMinion .z, 85, ARGB(255, 000, 255, 000))
    end

    if minionL_ and lastHitkey_ and ValidTarget(minion) then
      DrawCircle2(minion.x, minion.y, minion.z, 65, ARGB(255, 000, 255, 000))
    end

    if JungleLaneMinion  and laneclearkey_ and ValidTarget(JungleLaneMinion ) then
      DrawCircle2(JungleLaneMinion .x, JungleLaneMinion .y, JungleLaneMinion .z, 65, ARGB(255, 000, 255, 000))
    end

    if menu.draw.qtimer and myPlayer:CanUseSpell(_Q) ~= NOTLEARNED then
      -- pos = D3DXVECTOR3(myPlayer.minBBox.x,myPlayer.maxBBox.y,myPlayer.maxBBox.z)
      -- pPos = WorldToScreen(pos)

      -- msg = string.format("%g / %g / %g",pPos.x,pPos.y,pPos.z)
      vPos = GetUnitHPBarPos(myPlayer)
      local Tempo = qTime
      if Tempo == 0 then
        Tempo = "READY"
      else
        Tempo = Arredondar(qTime, 0).." s"
      end
  
      DrawText("Q: "..Tempo,16,vPos.x,vPos.y,0xFF80FF00)
      --DrawText(msg,18,pPos.x,pPos.y,0xFF80FF00)
    end

    -- if ValidTarget(Target) and newPos ~= nil then
    --   DrawCircle2(newPos.x, newPos.y, newPos.z, 115, ARGB(255, 000, 255, 000))
    -- end

end
