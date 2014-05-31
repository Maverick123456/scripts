if myHero.charName ~= "Malzahar" or not VIP_USER then return end

require "VPrediction"

--[[AUTO UPDATE]]--

local version = "0.9"

local AUTOUPDATE = true
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/Jusbol/scripts/master/SimpleMalzaharRelease.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH.."SimpleMalzaharRelease.lua"
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH
 
function _AutoupdaterMsg(msg) print("<font color=\"#6699ff\"><b>Malzahar, A Void Call:</b></font> <font color=\"#FFFFFF\">"..msg..".</font>") end
if AUTOUPDATE then
        local ServerData = GetWebResult(UPDATE_HOST, "/Jusbol/scripts/master/VersionFiles/Malzahar.version")
        if ServerData then
                ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil
                if ServerVersion then
                        if tonumber(version) < ServerVersion then
                                _AutoupdaterMsg("New version available"..ServerVersion)
                                _AutoupdaterMsg("Updating, please don't press F9")
                                DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () _AutoupdaterMsg("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 3)
                        else
                                _AutoupdaterMsg("You have got the latest version ("..ServerVersion..")")
                        end
                end
        else
                _AutoupdaterMsg("Error downloading version info")
        end
end
--[[honda update function]]

--[[SKILLS]]--
local AlZaharCalloftheVoid = {ready = nil, spellSlot = _Q, range = 900, width = 110, speed = math.huge, delay = .8}
local AlZaharNullZone = {ready = nil, spellSlot = _W, range = 800, width = 250, speed = math.huge, delay = .5}
local AlZaharMaleficVision = {ready = nil, spellSlot = _E, range = 650, width = 0, speed = math.huge, delay = .5}
local AlZaharNetherGrasp = {ready = nil, spellSlot = _R, range = 700, width = 0, speed = math.huge, delay = .5}
--[[SPELLS]]--
local IgniteSpell = {spellSlot = "SummonerDot", iSlot = nil, ready = false, range = 600}
local BarreiraSpell = {spellSlot = "SummonerBarrier", bSlot = nil, ready = false, range = 0}
local FlashSpell = {spellSlot = "SummonerFlash", fSlot = nil, ready = false, range = 400}
--[[ITEMS]]--
local DFG = {id = 3128, ready = false, range = 750, slot = nil}
local ZHONIA = {id = 3157, ready = false, range = 0, slot = nil}
local Seraph = {id = 3040, ready = false, range = 0, slot = nil}
local Hppotion = {id = 2003, ready = false, slot = nil}
local Manapotion = {id = 2004 , ready = false, slot = nil}
--[[ORBWALK]]--
local lastAttack, lastWindUpTime, lastAttackCD = 0, 0, 0
local myTrueRange = 0
--[[MISC]]--
local UsandoR = false
local MeuAlvo = nil
local MeuAlvoSelecionado = false
local EsteAlvo = nil
local UsandoHP = false
local UsandoMana = false
local RecebeuCC = false
local UsandoRecall =  false
local TemVoid = false
local AtualizarDanoInimigo = 0
local SequenciaHabilidades1 = {1,3,3,2,3,4,3,2,3,2,4,2,2,1,1,4,1,1} 
local Invulneraveis = { "PoppyDiplomaticImmunity", "UndyingRage", "JudicatorIntervention", "VladimirSanguinePool"}
local DanoQ = { 80 , 135 , 190 , 245 , 300 }
local DanoW = { 4 , 5 , 6 , 7 , 8 }
local DanoE = { 80 , 140 , 200 , 260 , 320 }
local DanoR = {	250 , 400 , 550 }			
local DanoTotal, QDano, WDano, EDano, RDano, DFGDano = 0, 0, 0, 0, 0
local StealJungle = {
Vilemaw = {obj = nil, name = "TT_Spiderboss7.1.1"},
Baron = {obj = nil, name = "Worm12.1.1"},
Dragon = {obj = nil, name = "Dragon6.1.1"},
Golem1 = {obj = nil, name = "AncientGolem1.1.1"},
Golem2 = {obj = nil, name = "AncientGolem7.1.1"},
}
--[[Others]]

function OnLoad()
Menu = scriptConfig(myHero.charName.." by Jus", "SimpleMalzahar")
Menu:addParam("LigarScript", "Global ON/OFF", SCRIPT_PARAM_ONOFF, true)
Menu:addParam("VersaoInfo", "Malzahar Version", SCRIPT_PARAM_INFO, version)
	--[[COMBO]]--
	Menu:addSubMenu("Combo System", "Combo")
		Menu.Combo:addParam("ComboSystem", "Use Combo System", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Combo:addParam("", "", SCRIPT_PARAM_INFO, "")
		Menu.Combo:addParam("UseQ", "Use "..myHero:GetSpellData(_Q).name.." (Q)", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Combo:addParam("UseW", "Use "..myHero:GetSpellData(_W).name.." (W)", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Combo:addParam("UseE", "Use "..myHero:GetSpellData(_E).name.." (E)", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Combo:addParam("UseR", "Use "..myHero:GetSpellData(_R).name.." (R)", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Combo:addParam("", "", SCRIPT_PARAM_INFO, "")
		Menu.Combo:addParam("UseIgnite", "Start with Ignite", SCRIPT_PARAM_ONOFF, true)
		Menu.Combo:addParam("ComboLogic", "Use Combo Helper", SCRIPT_PARAM_ONOFF, true)
		Menu.Combo:addSubMenu("Team Fight Settings", "Ultimate")
			Menu.Combo.Ultimate:addParam("SuportSilence", "Always Try Silence Support", SCRIPT_PARAM_ONOFF, true)
			Menu.Combo.Ultimate:addParam("Qss", "Never Ultimate enemy with Qss", SCRIPT_PARAM_ONOFF, true)
			Menu.Combo.Ultimate:addParam("Untargetable", "Don't R to Invulnerability", SCRIPT_PARAM_ONOFF, true)

		--Menu.Combo:addParam("CheckInsideW", "Only Cast R above W", SCRIPT_PARAM_ONOFF, false)
		--Menu.Combo:addParam("CheckifE", "Only Cast R if target have E", SCRIPT_PARAM_ONOFF, false)	
		Menu.Combo:addParam("ComboKey", "Team Fight Key", SCRIPT_PARAM_ONKEYDOWN, false, 32) --OK
	--[[HARASS]]--	
	Menu:addSubMenu("Auto Harass System", "Harass")
		Menu.Harass:addParam("HarassSystem", "Use Auto Harass System", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Harass:addParam("", "", SCRIPT_PARAM_INFO, "")
		Menu.Harass:addParam("AutoHarass", "Automatic Harass", SCRIPT_PARAM_ONOFF, true)
		Menu.Harass:addParam("UseQ", "Use "..myHero:GetSpellData(_Q).name.." (Q)", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Harass:addParam("UseW", "Use "..myHero:GetSpellData(_W).name.." (W)", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Harass:addParam("UseE", "Use "..myHero:GetSpellData(_E).name.." (E)", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Harass:addParam("", "", SCRIPT_PARAM_INFO, "")		
		Menu.Harass:addParam("ParaComManaBaixa", "Stop Cast if mana below %", SCRIPT_PARAM_SLICE, 40, 10, 80, 0) --OK
		Menu.Harass:addParam("StopTurret", "Do not harass under turret", SCRIPT_PARAM_ONOFF, true)
		Menu.Harass:addParam("HarassKey", "Manual Harass Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
				--Menu.Harass:addParam("KSWithQ", "Try KS with Q", SCRIPT_PARAM_ONOFF, true)
	--[[FARM]]--
	
	Menu:addSubMenu("Farm Helper System", "Farmerr")
		Menu.Farmerr:addParam("FarmerrSystem", "Use Farm System", SCRIPT_PARAM_ONOFF, true)
		Menu.Farmerr:addParam("", "", SCRIPT_PARAM_INFO, "")
		--Menu.Farmerr:addParam("FarmESkill", "Auto E to Farm", SCRIPT_PARAM_ONOFF, true)
		Menu.Farmerr:addParam("LastHit", "Last Hit Key (experimental)", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
		Menu.Farmerr:addParam("LastHitDelay", "Last Hit Delay", SCRIPT_PARAM_SLICE, 1000, -500, 3000, 1)
		Menu.Farmerr:addParam("", "", SCRIPT_PARAM_INFO, "")
		Menu.Farmerr:addParam("JungleKey", "Jungle Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
		Menu.Farmerr:addParam("", "", SCRIPT_PARAM_INFO, "")
		Menu.Farmerr:addParam("LaneClearKey", "Lane Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
		
		Menu.Farmerr:addSubMenu("More Farm Settings", "FarmSettings")
			Menu.Farmerr.FarmSettings:addParam("Gota", "Use Tear of The Goddess mode", SCRIPT_PARAM_ONOFF, true)
			Menu.Farmerr.FarmSettings:addParam("", "", SCRIPT_PARAM_INFO, "")
			Menu.Farmerr.FarmSettings:addParam("ArcaneON", "Use Arcana Blade Mastery", SCRIPT_PARAM_ONOFF, true)
			Menu.Farmerr.FarmSettings:addParam("ButcherON", "Use Butcher Mastery", SCRIPT_PARAM_ONOFF, true)
			Menu.Farmerr.FarmSettings:addParam("", "", SCRIPT_PARAM_INFO, "")
			Menu.Farmerr.FarmSettings:addParam("Steal", "Auto Jungle Steal with Q", SCRIPT_PARAM_ONOFF, true)
	--[[ITEMS]]--	
	Menu:addSubMenu("Items Helper System", "Items")
		Menu.Items:addParam("ItemsSystem", "Use Items Helper System", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Items:addParam("", "", SCRIPT_PARAM_INFO, "")
		Menu.Items:addParam("UseDfg", "Auto Deathfire Grasp with Combo", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Items:addParam("UseDfgR", "Deathfire Grasp only if R is ready", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Items:addParam("UseDfgRrange", "Deathfire Grasp only in R range", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Items:addParam("UseZhonia", "Auto Zhonias", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Items:addParam("ZhoniaPorcentagem", "Zhonias Missing Health %", SCRIPT_PARAM_SLICE, 20, 10, 80, -1) --OK
		Menu.Items:addParam("UseSeraph", "Auto Seraph's Embrace", SCRIPT_PARAM_ONOFF, true)
		Menu.Items:addParam("SeraphPorcentagem", "Seraph's Embrace Missing Health %", SCRIPT_PARAM_SLICE, 20, 10, 80, -1)
		--Menu.Items:addParam("ZhoniaCC", "Use Zhonias if Hard CC", SCRIPT_PARAM_ONOFF, true) 
		Menu.Items:addParam("", "", SCRIPT_PARAM_INFO, "")
		Menu.Items:addParam("UseBarreira", "Auto Barrier", SCRIPT_PARAM_ONOFF, true) 
		Menu.Items:addParam("BarreiraPorcentagem", "Barrier Missing Health %", SCRIPT_PARAM_SLICE, 30, 10, 80, -1) 
		Menu.Items:addParam("AntiDoubleIgnite", "Anti Double Ignite", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Items:addParam("", "", SCRIPT_PARAM_INFO, "")
		Menu.Items:addParam("AutoHP", "Auto HP Potion", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Items:addParam("AutoHPPorcentagem", "Use HP Potion if health %", SCRIPT_PARAM_SLICE, 60, 20, 80, -1) --OK
		Menu.Items:addParam("AutoMANA", "Auto Mana Potion", SCRIPT_PARAM_ONOFF, true)
		Menu.Items:addParam("AutoMANAPorcentagem", "Use MANA Potion if mana %", SCRIPT_PARAM_SLICE, 30, 10, 80, -1)
	--[[DRAW]]--	
	Menu:addSubMenu("Draw System", "Paint")
		Menu.Paint:addParam("DrawSystem", "Use Draw System", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Paint:addParam("", "", SCRIPT_PARAM_INFO, "")
		Menu.Paint:addParam("PaintQ", "Draw "..myHero:GetSpellData(_Q).name.." (Q) Range", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Paint:addParam("PaintW", "Draw "..myHero:GetSpellData(_W).name.." (W) Range", SCRIPT_PARAM_ONOFF, false) --OK
		Menu.Paint:addParam("PaintE", "Draw "..myHero:GetSpellData(_E).name.." (E) Range", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Paint:addParam("PaintR", "Draw "..myHero:GetSpellData(_R).name.." (R) Range", SCRIPT_PARAM_ONOFF, false) --OK
		Menu.Paint:addParam("", "", SCRIPT_PARAM_INFO, "")		
		Menu.Paint:addParam("PaintAA", "Draw Auto Attack Range", SCRIPT_PARAM_ONOFF, false) --OK
		Menu.Paint:addParam("PaintMinion", "Minion Last Hit Indicator", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Paint:addParam("PaintTurrent", "Turret Last Hit Indicator", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Paint:addParam("PaintTurrentRange", "Enemy Turret Range", SCRIPT_PARAM_ONOFF, false) --OK
		Menu.Paint:addParam("PaintMana", "Low Mana Indicator (Blue Circle)", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Paint:addParam("ManaCheck", "Draw Mana Advice Combo", SCRIPT_PARAM_ONOFF, true)
		Menu.Paint:addParam("PaintPassive", "Passive Indicator (White Circle)", SCRIPT_PARAM_ONOFF, true) --OK	
		Menu.Paint:addParam("", "", SCRIPT_PARAM_INFO, "")
		Menu.Paint:addParam("PredInimigo", "Enemy Moviment Prediction", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Paint:addParam("PaintTarget", "Target Circle Indicator", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Paint:addParam("EnemyDamage", "Current Damage to Target", SCRIPT_PARAM_ONOFF, true) --OK
		
	--[[MISC]]--	
	Menu:addSubMenu("General System", "General")		
		Menu.General:addParam("LevelSkill", "Auto Level Skills R-E-W-Q", SCRIPT_PARAM_ONOFF, true) --OK	
		Menu.General:addParam("UseOrb", "Use Orbwalking", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.General:addParam("MoveToMouse", "Only Move to Mouse Position", SCRIPT_PARAM_ONOFF, false) --OK
		Menu.General:addParam("", "", SCRIPT_PARAM_INFO, "")
		Menu.General:addParam("UsePacket", "Use Packet to Cast", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.General:addParam("UseVPred", "Use VPredicion to Cast", SCRIPT_PARAM_ONOFF, true) --OK
		--Menu.General:addParam("SelecionarAlvo", "Target Mode", SCRIPT_PARAM_SLICE, 1, 1, 2, 0) 
		Menu.General:addParam("AutoUpdate", "Auto Update Script On Start", SCRIPT_PARAM_ONOFF, true) --OK
	Menu:permaShow("VersaoInfo")
	Menu.Combo:permaShow("ComboKey")
	Menu.Harass:permaShow("HarassKey")
	Menu.Farmerr:permaShow("JungleKey")
	Menu.Farmerr:permaShow("LaneClearKey")
	Menu.Farmerr:permaShow("LastHit")
	
	--[[SPELL SLOT CHECK]]--
		if myHero:GetSpellData(SUMMONER_1).name:find(IgniteSpell.spellSlot) then IgniteSpell.iSlot = SUMMONER_1
			elseif myHero:GetSpellData(SUMMONER_2).name:find(IgniteSpell.spellSlot) then IgniteSpell.iSlot = SUMMONER_2 end	
		if myHero:GetSpellData(SUMMONER_1).name:find(BarreiraSpell.spellSlot) then BarreiraSpell.bSlot = SUMMONER_1
			elseif myHero:GetSpellData(SUMMONER_2).name:find(BarreiraSpell.spellSlot) then BarreiraSpell.bSlot = SUMMONER_2 end	
	--[[MMA/SAC Disable orbwalk]]--
	if UsandoR then
			if _G.MMA_Loaded then
				myHero:HoldPosition()
			_G.MMA_Orbwalker = false		
			--_G.MMA_HybridMode = false
			--_G.MMA_LaneClear = false
			_G.MMA_AbleToMove = false
			_G.MMA_AttackAvailable = false
			end
			if _G.AutoCarry then
				myHero:HoldPosition()
			--_G.AutoCarry.Orbwalker = false
				_G.AutoCarry.CanMove = false
				_G.AutoCarry.CanAttack = false
			end
		else
			if _G.MMA_Loaded then
				_G.AutoCarry.CanMove = true
				_G.AutoCarry.CanAttack = true
			end
			if _G.AutoCarry then
				_G.AutoCarry.CanMove = true
				_G.AutoCarry.CanAttack = true
			end
		end


	--[[OTHERS]]--		
	Alvo = TargetSelector(TARGET_LESS_CAST_PRIORITY, AlZaharCalloftheVoid.range, DAMAGE_MAGIC, true)
	Alvo.name = "Malzahar"
	Menu:addTS(Alvo)
	
	enemyHeroes = GetEnemyHeroes()
	MinionsInimigos = minionManager(MINION_ENEMY, 1200, myHero, MINION_SORT_HEALTH_ASC)
	JungleMinions = minionManager(MINION_JUNGLE, 900, myHero, MINION_SORT_MAXHEALTH_DEC)
	wayPointManager = WayPointManager()
	if heroManager.iCount < 10 then -- borrowed from Sidas Auto Carry, modified to 3v3
	   	PrintChat(" >> Too few champions to arrange priority")
	elseif heroManager.iCount == 6 and TTMAP then
		ArrangeTTPriorities()
	else
		ArrangePriorities()
	end
	myTrueRange = myHero.range + GetDistance(myHero.minBBox)
	VP = VPrediction()
	PrintChat("-[ <font color='#000FFF'> -- Malzahar by Jus loaded !Good Luck! -- </font> ]-")
end
--[[SKILLS]]--
function CastQ()	
	if EncontrarAlvoQ() ~= nil and not UsandoR and GetDistance(EncontrarAlvoQ()) <= AlZaharCalloftheVoid.range then
		if myHero:CanUseSpell(AlZaharCalloftheVoid.spellSlot) == READY then
			if Menu.General.UseVPred then
			local CastPosition, HitChance, Position = VP:GetCircularCastPosition(EncontrarAlvoQ(), (AlZaharCalloftheVoid.delay + 200)/1600, AlZaharCalloftheVoid.width, AlZaharCalloftheVoid.range, math.huge, myHero, false)   
			
			--local CastPoint = Vector(CastPosition) + (200*(Vector(CastPosition) - Vector(myHero))/1600):normalized()			
				if HitChance >= 2 then
					--PrintChat("Vector:"..tostring(CastPoint))
					--PrintChat("VPrediction:"..tostring(CastPosition))
					CastSpell(AlZaharCalloftheVoid.spellSlot, CastPosition.x, CastPosition.z)
				end 				
			elseif not Menu.General.UsePacket and not Menu.General.UseVPred then
				CastSpell(AlZaharCalloftheVoid.spellSlot, EncontrarAlvoQ().x, EncontrarAlvoQ().z)
			end			
		end
	end
end

function CastQTear()
	if GetInventorySlotItem(3070) ~= nil then		
	for i, Minion in pairs(MinionsInimigos.objects) do
		if Minion ~= nil and not Minion.dead and ValidTarget(Minion, AlZaharCalloftheVoid.range) and myHero:CanUseSpell(AlZaharCalloftheVoid.spellSlot) == READY then
			CastSpell(AlZaharCalloftheVoid.spellSlot, Minion.x, Minion.z)
		end
	end
end
end

function CastW()	
	if MeuAlvo ~= nil and not UsandoR and GetDistance(MeuAlvo) <= AlZaharNullZone.range then
		if myHero:CanUseSpell(AlZaharNullZone.spellSlot) == READY then
			if Menu.General.UseVPred then
				local AOECastPosition, MainTargetHitChance, nTargets = VP:GetCircularAOECastPosition(MeuAlvo, AlZaharNullZone.delay, AlZaharNullZone.width, AlZaharNullZone.range, math.huge, myHero) 
					if CountEnemyHeroInRange(AlZaharNullZone.range, myHero) >= 3 then
						if MainTargetHitChance >= 1 then
							CastSpell(AlZaharNullZone.spellSlot, AOECastPosition.x , AOECastPosition.z)
						end
					end
					if CountEnemyHeroInRange(AlZaharNullZone.range, myHero) < 3 then
						if MainTargetHitChance >= 2 then
							CastSpell(AlZaharNullZone.spellSlot, AOECastPosition.x , AOECastPosition.z)
						end
					end
			else CastSpell(AlZaharNullZone.spellSlot, MeuAlvo.x, MeuAlvo.z)
			end				
		end
	end
end

function CastWTear()
	if GetInventorySlotItem(3070) ~= nil then		
	for i, Minion in pairs(MinionsInimigos.objects) do
		if Minion ~= nil and not Minion.dead and ValidTarget(Minion, AlZaharNullZone.range) and myHero:CanUseSpell(AlZaharNullZone.spellSlot) == READY then
			CastSpell(AlZaharNullZone.spellSlot, Minion.x, Minion.z)
		end
	end
end
end

function CastE()
	
	if MeuAlvo ~= nil and not UsandoR and GetDistance(MeuAlvo) <= AlZaharMaleficVision.range then
		if myHero:CanUseSpell(AlZaharMaleficVision.spellSlot) == READY then
			if Menu.General.UsePacket then
				Packet('S_CAST', { spellId = AlZaharMaleficVision.spellSlot, targetNetworkId = MeuAlvo.networkID }):send()				
			else
				CastSpell(AlZaharMaleficVision.spellSlot, MeuAlvo)				
			end
		end
	end
end

function CastR()	
	if TemImunidade(MeuAlvo) or TemQss() then return end	
	if MeuAlvo ~= nil and GetDistance(MeuAlvo) <= AlZaharNetherGrasp.range then
		if myHero:CanUseSpell(AlZaharNetherGrasp.spellSlot) == READY then
			if Menu.General.UsePacket then
				Packet('S_CAST', { spellId = AlZaharNetherGrasp.spellSlot, targetNetworkId = MeuAlvo.networkID }):send()
			else
				CastSpell(AlZaharMaleficVision.spellSlot, MeuAlvo)
			end		
		end
	end
end


function JungleFarm()
	JungleMinions:update()	
		if Menu.Farmerr.JungleKey then
			for i, MinionJ in pairs(JungleMinions.objects) do
				if MinionJ ~= nil then
					if CountEnemyHeroInRange(AlZaharCalloftheVoid.range, myHero) == 0 then
						_OrbWalk(MinionJ)
						if myHero:CanUseSpell(AlZaharCalloftheVoid.spellSlot) == READY then
							CastSpell(AlZaharCalloftheVoid.spellSlot, MinionJ.x, MinionJ.z)
						end
						if myHero:CanUseSpell(AlZaharNullZone.spellSlot) == READY then
							CastSpell(AlZaharNullZone.spellSlot, MinionJ.x, MinionJ.z)
						end
						if myHero:CanUseSpell(AlZaharMaleficVision.spellSlot) == READY then
							CastSpell(AlZaharMaleficVision.spellSlot, MinionJ)
						end
					end
				end
			end
		end
end

function LaneClear()
	MinionsInimigos:update()
	if Menu.Farmerr.LaneClearKey then
		for i, MinionJ in pairs(MinionsInimigos.objects) do
			if MinionJ ~= nil then
				_OrbWalk(MinionJ.target)
				if myHero:CanUseSpell(AlZaharCalloftheVoid.spellSlot) == READY then
					CastSpell(AlZaharCalloftheVoid.spellSlot, MinionJ.x, MinionJ.z)
				end
				if myHero:CanUseSpell(AlZaharNullZone.spellSlot) == READY then
					CastSpell(AlZaharNullZone.spellSlot, MinionJ.x, MinionJ.z)
				end
				if myHero:CanUseSpell(AlZaharMaleficVision.spellSlot) == READY then
					CastSpell(AlZaharMaleficVision.spellSlot, MinionJ)
				end
			end
		end
	end
end

function CastCombo()
	if Menu.Combo.ComboKey then	
		if Menu.General.UseOrb then _OrbWalk(MeuAlvo) end		
		if Menu.Items.ItemsSystem then			
			if Menu.Combo.UseIgnite and not UsandoR then CastIgnite() end		
			if Menu.Items.UseDfg then CastDFG() end
		end
		if Menu.Combo.ComboLogic and not GetBestCombo() then
		--PrintChat("Normal Combo")	
		
		if Menu.Combo.UseQ then CastQ() end
		if Menu.Combo.UseW then CastW() end
		if Menu.Combo.UseE then CastE() end			
		if Menu.Combo.UseR then
			if Menu.Combo.UseQ and Menu.Combo.UseW and Menu.Combo.UseE then			 
				if not myHero:CanUseSpell(AlZaharCalloftheVoid.spellSlot) ~= READY and 
					myHero:CanUseSpell(AlZaharNullZone.spellSlot) ~= READY and 
					myHero:CanUseSpell(AlZaharMaleficVision.spellSlot) ~= READY then
					CastR()
				end
			end
			if Menu.Combo.UseW and Menu.Combo.UseE and not Menu.Combo.UseQ then
				if myHero:CanUseSpell(AlZaharNullZone.spellSlot) ~= READY and myHero:CanUseSpell(AlZaharMaleficVision.spellSlot) ~= READY then
					CastR()
				end
			end
			if Menu.Combo.UseW and not Menu.Combo.UseQ and not Menu.Combo.UseE then
				if myHero:CanUseSpell(AlZaharNullZone.spellSlot) ~= READY then CastR()	end
			end
			if Menu.Combo.UseE and not Menu.Combo.UseQ and not Menu.Combo.UseW then
				if myHero:CanUseSpell(AlZaharMaleficVision.spellSlot) ~= READY then	CastR()	end
			end
			if Menu.Combo.UseQ and not Menu.Combo.UseW and not Menu.Combo.UseE then
				if myHero:CanUseSpell(AlZaharCalloftheVoid.spellSlot) ~= READY then myHero:HoldPosition() CastR() end
			end
		end
		end	
	end
end

function GetBestCombo()
	local spelllist ={ }
	if MeuAlvo ~= nil then		
		if myHero:CanUseSpell(AlZaharCalloftheVoid.spellSlot) == READY then table.insert(spelllist, "Q") end
		if myHero:CanUseSpell(AlZaharNullZone.spellSlot) == READY then table.insert(spelllist, "W") end
		if myHero:CanUseSpell(AlZaharMaleficVision.spellSlot) == READY then table.insert(spelllist, "E") end
		if myHero:CanUseSpell(AlZaharNetherGrasp.spellSlot) == READY then table.insert(spelllist, "R") end		
		local TotalDamage = 0		
		for a, ListSpell in pairs(spelllist) do							
			TotalDamage = TotalDamage + getDmg(ListSpell, MeuAlvo, myHero)				
		end			
		if MeuAlvo.health <= TotalDamage then		 			
			for b, ListCombo in pairs(spelllist) do						
				if ListCombo == "Q" then
					CastQ()
				end
				if ListCombo == "W" then
					CastW()
				end
				if ListCombo == "E" then
					CastE()
				end
				if ListCombo == "R" then
					myHero:HoldPosition()
					CastR()
				end
			end	
		else 
			return false
		end
	end
end

function GetBestComboText()
	local spelllist ={ }
	if MeuAlvo ~= nil then		
		if myHero:CanUseSpell(AlZaharCalloftheVoid.spellSlot) == READY then table.insert(spelllist, "Q") end
		if myHero:CanUseSpell(AlZaharNullZone.spellSlot) == READY then table.insert(spelllist, "W") end
		if myHero:CanUseSpell(AlZaharMaleficVision.spellSlot) == READY then table.insert(spelllist, "E") end
		if myHero:CanUseSpell(AlZaharNetherGrasp.spellSlot) == READY then table.insert(spelllist, "R") end		
		local TotalDamage = 0		
		for a, ListSpell in pairs(spelllist) do							
			TotalDamage = TotalDamage + getDmg(ListSpell, MeuAlvo, myHero)				
		end			
		if MeuAlvo.health >= TotalDamage then		 			
			--table.concat(spelllist, "+")
			
			return "Not killable"
		else
			return "Killable"
		end
	end
end

function CastHarass()	
		if usandoR then return end
		if Menu.Harass.StopTurret and UnderTurret(myHero, true) then return end
		if Menu.Harass.UseQ then CastQ() end
		if Menu.Harass.UseW then CastW() end
		if Menu.Harass.UseE then CastE() end	
end
--[[SKILLS END]]--

--[[SPELLS]]--
function CastIgnite()	
	if IgniteSpell.iSlot ~= nil and myHero:CanUseSpell(IgniteSpell.iSlot) == READY and MeuAlvo ~= nil and GetDistance(MeuAlvo) < IgniteSpell.range then	
		if Menu.Items.AntiDoubleIgnite and TargetHaveBuff("SummonerDot", MeuAlvo) then return end
		if Menu.Items.AntiDoubleIgnite and not TargetHaveBuff("SummonerDot", MeuAlvo) then
			if Menu.General.UsePacket then
				Packet('S_CAST', { spellId = IgniteSpell.iSlot, targetNetworkId = MeuAlvo.networkID }):send()
			else
				CastSpell(IgniteSpell.iSlot, MeuAlvo)
			end
		else
			if Menu.General.UsePacket then
				Packet('S_CAST', { spellId = IgniteSpell.iSlot, targetNetworkId = MeuAlvo.networkID }):send()
			else
				CastSpell(IgniteSpell.iSlot, MeuAlvo)
			end
		end
	end
end 

function CastDFG()	
		if Menu.Items.UseDfgR and not myHero:CanUseSpell(AlZaharNetherGrasp.spellSlot) == READY then return end
		--if Alvo.target ~= nil and Menu.Items.UseDfgRrange and not GetDistance(Alvo.target) <= AlZaharNetherGrasp.range then return end
		if MeuAlvo ~= nil then	
			if Menu.Items.UseDfgRrange and GetDistance(MeuAlvo) > AlZaharNetherGrasp.range then return end	
			if DFG.slot ~= nil and myHero:CanUseSpell(DFG.slot) == READY and not UsandoR then
				if Menu.General.UsePacket then
					Packet('S_CAST', { spellId = DFG.slot, targetNetworkId = MeuAlvo.networkID }):send()
				else
					CastSpell(DFG.slot, MeuAlvo)
				end			
			end
		end
end

function CastZhonia()
	local VidaParaUsarZhonia = myHero.maxHealth * (Menu.Items.ZhoniaPorcentagem / 100)
	if myHero.health <= VidaParaUsarZhonia and ZHONIA.slot ~= nil and myHero:CanUseSpell(ZHONIA.slot) == READY and not UsandoR then
		if Menu.General.UsePacket then
			Packet('S_CAST', { spellId = ZHONIA.slot, targetNetworkId = myHero.networkID }):send()
		else
			CastSpell(ZHONIA.slot)
		end
		--[[
	else
		if Menu.Items.ZhoniaCC and RecebeuCC then
			if Menu.General.UsePacket then
				Packet('S_CAST', { spellId = ZHONIA.slot, targetNetworkId = myHero.networkID }):send()
			else
				CastSpell(ZHONIA.slot)
			end
		end
		]]--
	end
end	

function CastBarreira()	
	local VidaParaUsarBarreira = (myHero.maxHealth * (Menu.Items.BarreiraPorcentagem / 100))
	if BarreiraSpell.bSlot ~= nil and myHero:CanUseSpell(BarreiraSpell.bSlot) == READY and not InFountain() then	
		if myHero.health <= VidaParaUsarBarreira then
			CastSpell(BarreiraSpell.bSlot)			
		end
	end
end	

function CastHPPotion()
	local VidaParaUsarPotionHP = (myHero.maxHealth * ( Menu.Items.AutoHPPorcentagem / 100))
	if Hppotion.slot ~= nil and myHero:CanUseSpell(Hppotion.slot) == READY and not UsandoHP and not InFountain() then
		if myHero.health <= VidaParaUsarPotionHP then
			CastSpell(Hppotion.slot)		
		end
	end
end

function CastManaPotion()
	local ManaParaUsarPotion = (myHero.maxMana * ( Menu.Items.AutoMANAPorcentagem / 100))
	if Manapotion.slot ~= nil and myHero:CanUseSpell(Manapotion.slot) == READY and not UsandoMana and not InFountain() then
		if myHero.mana <= ManaParaUsarPotion then
			CastSpell(Manapotion.slot)
		end
	end
end

function CastSeraph()
	local VidaParaUsarSeraph = (myHero.maxHealth * ( Menu.Items.SeraphPorcentagem / 100))
	if Seraph.slot ~= nil and myHero:CanUseSpell(Seraph.slot) == READY and not InFountain() then
		if myHero.health <= VidaParaUsarSeraph then
			CastSpell(Seraph.slot)
		end
	end
end

--[[END]]--

--[[OTHER]]--
function AutoSkillLevel()
	if myHero:GetSpellData(_Q).level + myHero:GetSpellData(_W).level + myHero:GetSpellData(_E).level + myHero:GetSpellData(_R).level < myHero.level then
	local spellSlot = { SPELL_1, SPELL_2, SPELL_3, SPELL_4, }
	local level = { 0, 0, 0, 0 }
		for i = 1, myHero.level, 1 do
			level[SequenciaHabilidades1[i]] = level[SequenciaHabilidades1[i]] + 1
		end
			for i, v in ipairs({ myHero:GetSpellData(_Q).level, myHero:GetSpellData(_W).level, myHero:GetSpellData(_E).level, myHero:GetSpellData(_R).level }) do
				if v < level[i] then LevelSpell(spellSlot[i]) end
			end
	end
end 
--[[END]]--

function AtualizaItems()
--[[ITEMS]]--
	DFG.slot = GetInventorySlotItem(DFG.id)	
	ZHONIA.slot = GetInventorySlotItem(ZHONIA.id)
	Seraph.slot = GetInventorySlotItem(Seraph.id)
	Hppotion.slot = GetInventorySlotItem(Hppotion.id)
	Manapotion.slot = GetInventorySlotItem(Manapotion.id)	
	MinionsInimigos:update()
		
	--if MeuAlvoSelecionado == false then MeuAlvo = Alvo.target else MeuAlvo = EsteAlvo end	
	MeuAlvo = GetCustomTarget()
		if UsandoR then
			if _G.MMA_Loaded then
				myHero:HoldPosition()
			--_G.MMA_Orbwalker = false		
			--_G.MMA_HybridMode = false
			--_G.MMA_LaneClear = false
			_G.MMA_AbleToMove = false
			_G.MMA_AttackAvailable = false
			end
			if _G.AutoCarry then
				myHero:HoldPosition()
			--_G.AutoCarry.Orbwalker = false
				_G.AutoCarry.CanMove = false
				_G.AutoCarry.CanAttack = false
			end
		else
			if _G.MMA_Loaded then
				_G.AutoCarry.CanMove = true
				_G.AutoCarry.CanAttack = true
			end
			if _G.AutoCarry then
				_G.AutoCarry.CanMove = true
				_G.AutoCarry.CanAttack = true
			end
		end

end

function GetCustomTarget()
  Alvo:update()
    if _G.MMA_Target and _G.MMA_Target.type == myHero.type then return _G.MMA_Target end
    if _G.AutoCarry and _G.AutoCarry.Crosshair and _G.AutoCarry.Attack_Crosshair and _G.AutoCarry.Attack_Crosshair.target and _G.AutoCarry.Attack_Crosshair.target.type == myHero.type then return _G.AutoCarry.Attack_Crosshair.target end
    return Alvo.target
end
--End Credit Trees


--[[SPELLS END]]--
function OnTick()
	if Menu.LigarScript and not myHero.dead then				
		AtualizaItems()	
		Alvo:update()
		MeuAlvo = GetCustomTarget()
		--if Menu.General.UseOrb then	Menu.General.MoveToMouse = false end
		--if Menu.General.MoveToMouse then Menu.General.UseOrb = false end
		--if Menu.Paint.EnemyDamage then MeuDano() end			
		if Menu.Combo.ComboSystem then
			CastCombo()		
		end
		if Menu.Harass.HarassSystem then
			if Menu.Harass.AutoHarass and ((myHero.mana / myHero.maxMana * 100)) >= Menu.Harass.ParaComManaBaixa and not UsandoR and not UsandoRecall and not Menu.Harass.HarassKey then
				CastHarass()		
			else
				if Menu.Harass.HarassKey and ((myHero.mana / myHero.maxMana * 100)) >= Menu.Harass.ParaComManaBaixa and not Menu.Harass.AutoHarass and not UsandoR and not UsandoRecall then
					CastHarass()
				end	
			end
		end
		if Menu.Items.ItemsSystem then
			if Menu.Items.UseBarreira then CastBarreira() end
			if Menu.Items.AutoHP then CastHPPotion() end
			if Menu.Items.AutoMANA then CastManaPotion() end
			if Menu.Items.UseZhonia then CastZhonia() end			
			if Menu.Items.UseSeraph then CastSeraph() end
		end
		if Menu.Farmerr.FarmerrSystem and not UsandoR then
			if Menu.Farmerr.LastHit then
				LastHitLikeBoss()
			end
			if Menu.Farmerr.FarmSettings.Gota then
				CastQTear()
				CastWTear()
			end
			if Menu.Farmerr.JungleKey then
				JungleFarm()
			end
			if Menu.Farmerr.FarmSettings.Steal then
				RoubarJungle()
			end
			if Menu.Farmerr.LaneClearKey then
				LaneClear()
			end
		end
		if Menu.General.LevelSkill then
			AutoSkillLevel()
		end
	end
		if UsandoR then
			if _G.MMA_Loaded then
				myHero:HoldPosition()
			_G.MMA_Orbwalker = false		
			--_G.MMA_HybridMode = false
			--_G.MMA_LaneClear = false
			_G.MMA_AbleToMove = false
			_G.MMA_AttackAvailable = false
			end
			if _G.AutoCarry then
				myHero:HoldPosition()
			--_G.AutoCarry.Orbwalker = false
				_G.AutoCarry.CanMove = false
				_G.AutoCarry.CanAttack = false
			end
		else
			if _G.MMA_Loaded then
				_G.AutoCarry.CanMove = true
				_G.AutoCarry.CanAttack = true
			end
			if _G.AutoCarry then
				_G.AutoCarry.CanMove = true
				_G.AutoCarry.CanAttack = true
			end
		end
end

function OnSendPacket(packet)
	if UsandoR then
		local myPacket = Packet(p)
		if myPacket:get('S_CAST') or myPacket:get('S_MOVE') then
			myPacket:Block()
		end
	end
end
--  if UsandoR then
--   if packet.header == 113 then
--    local aux = packet.DecodeF(packet)
--    local type = packet.Decode1(packet)
--    if type == 5 or type == 2 or type == 3 or type == 7 and TargetHaveBuff("alzaharnethergraspsound", MeuAlvo) or TargetHaveBuff("AlzaharNetherGrasp", MeuAlvo) then
--     --if (not (SpellData.Q.ready and SpellData.E.ready and SpellData.R.ready)) then
--      packet:Block()
--    -- end
--    end
--   end
--  end
-- end


--[[target]]
--[[
function OnWndMsg(Msg, Key)
	if Msg == WM_LBUTTONDOWN then		
		Alvo:update()
		for i, Alvos_ in ipairs(GetEnemyHeroes()) do
			if ValidTarget(Alvos_) and GetDistance(Alvos_) <= AlZaharCalloftheVoid.range + 200 then
				EsteAlvo = Alvos_
				PrintChat("<font color=\"#FF0000\">Target selected:"..EsteAlvo.charName.."</font>")
				MeuAlvoSelecionado = true
				
			end
		end
	else
		if EsteAlvo == nil then
			EsteAlvo = Alvo.target	
			MeuAlvoSelecionado = false	
				
		end
	end
end
]]


--[[ULTIMATE/BUFFS CONTROL]]--
function OnGainBuff(unit, buff)
	if unit.isMe then
		--rintChat(tostring(buff.name))
		if buff.name:lower():find("alzaharnethergraspsound") then
			UsandoR = true
			--PrintChat("GAIN BUFF: Usando Ultimate")
		end
		if buff.name:lower():find("regenerationpotion") then 
			UsandoHP = true
		end	
		if buff.name:lower():find("flaskofcrystalwater") then
			UsandoMana = true
		end		
		if buff.name:lower():find("alzaharsummonvoidling") then
			TemVoid = true
		end		
		if buff.name:lower():find("recall") then
			UsandoRecall = true
		end
	end	
end

function OnLoseBuff(unit, buff)
	if unit.isMe then
		--PrintChat(tostring(buff.name))
		if buff.name:lower():find("alzaharnethergraspsound") then
			UsandoR = false
			--PrintChat("LOSE BUFF: NAO Usando Ultimate")
		end
		if buff.name:lower():find("regenerationpotion") then 
			UsandoHP = false
		end
		if buff.name:lower():find("flaskofcrystalwater") then
			UsandoMana = false
		end
		--if buff.type == 5 or 7 or 19 or 21 or 24 then
		-- RecebeuCC = false
		--end
		if buff.name:lower():find("alzaharsummonvoidling") then
			TemVoid = false
		end	
		if buff.name:lower():find("recall") then
			UsandoRecall = false
		end	
	end	
end
--[[
function OnCreateObj(obj)	
	if obj.name == "AlzaharNetherGrasp_tar.troy" then
		UsandoR = true
	end
end

function OnDeleteObj(obj)
	if obj.name == "AlzaharNetherGrasp_tar.troy" then
		UsandoR = false
	end
end
]]

--[[END]]--

--[[MY TARGET SELECTOR]]--
--[[
function MelhorAlvo(Range) --ADICIONAR DELAY	
	local DanoParaMatar = 100
	local Alvo = nil
	if Menu.General.SelecionarAlvo == 1 then --less_cast
	for i, enemy in ipairs(GetEnemyHeroes()) do
		if ValidTarget(enemy, Range) then
			local DanoNoInimigo = myHero:CalcMagicDamage(enemy, 200)
			local ParaMatar = enemy.health / DanoNoInimigo
				if ParaMatar < DanoParaMatar then
					Alvo = enemy
				end
		end
	end
	end	
	
	if Menu.General.SelecionarAlvo == 2 then --low_HP
	for i, enemy in ipairs(GetEnemyHeroes()) do
		if ValidTarget(enemy, Range) then
			local DanoNoInimigo = myHero:CalcMagicDamage(enemy, 200)
			local ParaMatar = enemy.health / enemy.health - DanoNoInimigo
				if ParaMatar < DanoParaMatar then
					Alvo = enemy
				end
		end
	end
	end	
	return Alvo
end
]]

--[[ORBWALK]]--
function OnProcessSpell(object, spell)
	if object == myHero then
		if spell.name:lower():find("attack") then
			lastAttack = GetTickCount() - GetLatency() / 2
			lastWindUpTime = spell.windUpTime * 1000
			lastAttackCD = spell.animationTime * 1000
		end 
		
		-- if spell.name:find("AlZaharNetherGrasp") then
		-- 	UsandoR = true
		-- 	--PrintChat("PROCESS SPEL: Usando Ultimate = true")
		-- end
		
	end
	
end

function _OrbWalk(MeuAlvo)	
	if UsandoR then return end
	if MeuAlvo ~= nil and GetDistance(MeuAlvo) <= myTrueRange then		
		if timeToShoot() then
			myHero:Attack(MeuAlvo)
		elseif heroCanMove()  then
			moveToCursor()
		end
	else		
		moveToCursor() 
	end
end

function heroCanMove()
	return ( GetTickCount() + GetLatency() / 2 > lastAttack + lastWindUpTime + 20 )
end 
 
function timeToShoot()
	return ( GetTickCount() + GetLatency() / 2 > lastAttack + lastAttackCD )
end 
 
function moveToCursor()
	if GetDistance(mousePos) > 1 or lastAnimation == "Idle1" then
		local moveToPos = myHero + (Vector(mousePos) - myHero):normalized() * 260
		myHero:MoveTo(moveToPos.x, moveToPos.z)
	end 
end
--[[ORBWALK END]]--

--[[Credits to barasia, vadash and viseversa for anti-lag circles]]--
function DrawCircleNextLvl(x, y, z, radius, width, color, chordlength)
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
--[[END]]--
--[[DRAW]]--
function OnDraw()

	if myHero.dead or not Menu.Paint.DrawSystem then return end
	
	if Menu.Paint.PaintQ then
		DrawCircle2(myHero.x, myHero.y, myHero.z, AlZaharCalloftheVoid.range,  ARGB(255, 255, 000, 000))
	end 
	if Menu.Paint.PaintW then
		DrawCircle2(myHero.x, myHero.y, myHero.z, AlZaharNullZone.range,  ARGB(255, 000, 000, 255))
	end 
	if Menu.Paint.PaintE then
		DrawCircle2(myHero.x, myHero.y, myHero.z, AlZaharMaleficVision.range,  ARGB(255, 000, 255, 000))
	end 
	if Menu.Paint.PaintR then
		DrawCircle2(myHero.x, myHero.y, myHero.z, AlZaharNetherGrasp.range,  ARGB(255, 255, 255, 000))
	end 
	if Menu.Paint.PaintFlash then
		DrawCircle2(myHero.x, myHero.y, myHero.z, IgniteSpell.range, ARGB(255, 000, 000, 255))
	end 
	if Menu.Paint.PaintAA then
		DrawCircle2(myHero.x, myHero.y, myHero.z, 550, ARGB(255,255,255,255))
	end
	
	if Menu.Paint.EnemyDamage then			
		if MeuAlvo ~= nil then			
			DrawText3D(tostring(GetBestComboText()), MeuAlvo.x, MeuAlvo.y, MeuAlvo.z, 16, ARGB(255,255,255,000), true)
			DrawText3D(MeuDano(), myHero.x, myHero.y + 100, myHero.z, 16, ARGB(255,255,000,000), true)
		end
	end
	
	if Menu.Paint.PaintMinion then
		MinionsInimigos:update()
		if MinionsInimigos ~= nil then
		local DamageArcane1 = myHero.ap * 0.05
		local DamageButcher1 = 2
		local MasteryDamage1 = 0
			if Menu.Farmerr.FarmSettings.ArcaneON then
				MasteryDamage1 = MasteryDamage1 + DamageArcane1
			end
			if Menu.Farmerr.FarmSettings.ButcherON then
				MasteryDamage1 = MasteryDamage1 + DamageButcher1
			end
			for i, Minion in pairs(MinionsInimigos.objects) do
				if Minion ~= nil and not Minion.dead then
					if ValidTarget(Minion, 1200) and Minion.health <= getDmg("AD", Minion, myHero) + MasteryDamage1 then
						DrawCircle2(Minion.pos.x, Minion.pos.y, Minion.pos.z, 85, ARGB(255, 255, 255, 000))
					end
				end
			end
		end    
	end
	
	if Menu.Paint.PaintTurrent then
		local turrets = GetTurrets();
		local targetTurret = nil;
		local hitsToTurret = 0;
			for i, turret in pairs(turrets) do
				if turret ~= nil and turret.team ~= myHero.team then
					targetTurret = turret.object
					hitsToTurret = Arredondar(turret.object.health / getDmg("AD", targetTurret, myHero))
						if hitsToTurret ~= 0 then
							local pos= WorldToScreen(D3DXVECTOR3(targetTurret.x, targetTurret.y, targetTurret.z))
							local posX = pos.x - 35
							local posY = pos.y - 50							
								DrawText("AA Hits: "..hitsToTurret + 1,15,posX ,posY  ,ARGB(255,0,255,0))
								if Menu.Paint.PaintTurrentRange then
									DrawCircle2(targetTurret.x, targetTurret.y, targetTurret.z, 930, ARGB(255,0,255,0))
								end
						end
				end
			end
	end
	
	if Menu.Paint.PaintTarget then
		
		if MeuAlvo  ~= nil then			 	 
			--for i=0, 4 do -- 60 + i*1.5
				 DrawCircle2(MeuAlvo.x, MeuAlvo.y, MeuAlvo.z, VP:GetHitBox(MeuAlvo), ARGB(255, 255, 000, 255))	
			--end
		end 
	end
	
	if Menu.Paint.PaintPassive then
		if TemVoid then			
			DrawCircle2(myHero.x, myHero.y, myHero.z, 65, ARGB(255,255,255,255))
		end
	end

	if Menu.Paint.PaintMana and myHero.mana < myHero.maxMana * (Menu.Harass.ParaComManaBaixa / 100) then		
		DrawCircle2(myHero.x, myHero.y, myHero.z, 35, ARGB(255, 000, 000, 255))	
	end	
	
	if Menu.Paint.PredInimigo then
		
		if MeuAlvo ~= nil then
			wayPointManager:DrawWayPoints(MeuAlvo)
		end
	end
	
	if Menu.Paint.ManaCheck then				
		DrawText3D(ManaParaCombo(), myHero.x + 20, myHero.y + 50, myHero.z, 16, ARGB(255, 000, 255, 255))
	end
	
end
--[[MISC]]--

function TemImunidade(enemy)
	if not enemy ~= nil then return end
	if Menu.Combo.Ultimate.Untargetable then
		for i, Imunidades in ipairs(Invulneraveis) do
		if TargetHaveBuff(Imunidades, enemy) then
			return true
		else
			return false
		end
		end
	end
end
--[[

function CalcularDanoInimigo()	
	if Alvo.target ~= nil then	
		local spellList = {}
		if getDmg("AD", myHero, Alvo.target) ~= 0 then table.insert(spellList, getDmg("AD", myHero, Alvo.target)) end
		if getDmg("Q", myHero, Alvo.target) ~= 0 then table.insert(spellList, getDmg("Q", myHero, Alvo.target)) end
		if getDmg("W", myHero, Alvo.target) ~= 0 then table.insert(spellList, getDmg("W", myHero, Alvo.target)) end
		if getDmg("E", myHero, Alvo.target) ~= 0 then table.insert(spellList, getDmg("E", myHero, Alvo.target)) end
		if getDmg("R", myHero, Alvo.target) ~= 0 then table.insert(spellList, getDmg("R", myHero, Alvo.target)) end
		--[[
		adDmgE = (getDmg("AD", myHero, Alvo.target) or 0)		
		qDmgE = (getDmg("Q", myHero, Alvo.target) or 0)
		wDmgE =  (getDmg("W", myHero, Alvo.target) or 0)
		eDmgE = (getDmg("E", myHero, Alvo.target) or 0)
		rDmgE = (getDmg("R", myHero, Alvo.target) or 0)
		
		local DanoInimigo = 0		
		for a, ListSpellDamage in ipairs(spellList) do
		 DanoInimigo = DanoInimigo + ListSpellDamage
		end		
		if DanoInimigo ~= 0 then		
			local PorcentagemQueVouFicar = (((myHero.maxHealth - DanoInimigo)/myHero.maxHealth)*100)	
			return "Total Enemy Damage:"..Arredondar(DanoInimigo).." / Stay: "..Arredondar(PorcentagemQueVouFicar).."%:My HP:"..Arredondar(myHero.health).."/"..Arredondar(myHero.maxHealth)
		end
	end
end	
]]	
-- 0.03 from mastery Havoc
function MeuDano()
		--if not ((os.clock() - AtualizarDanoInimigo) > 1) then return end
		
		if MeuAlvo ~= nil then			
				if myHero:GetSpellData(_Q).level ~= 0 then
					QDano = myHero:CalcMagicDamage(MeuAlvo, (DanoQ[myHero:GetSpellData(_Q).level] + myHero.ap * 0.8) + ((DanoQ[myHero:GetSpellData(_Q).level] + myHero.ap * 0.8)* 0.03))
				end
				if myHero:GetSpellData(_W).level ~= 0 then
					WDano = myHero:CalcMagicDamage(MeuAlvo, ((((DanoW[myHero:GetSpellData(_W).level] + myHero.ap * 0.01) / 100) * MeuAlvo.maxHealth) + (((DanoW[myHero:GetSpellData(_W).level] + myHero.ap * 0.01) / 100) * MeuAlvo.maxHealth)* 0.03) * 5)
				end
				if myHero:GetSpellData(_E).level ~= 0 then
					EDano = myHero:CalcMagicDamage(MeuAlvo, (DanoE[myHero:GetSpellData(_E).level] + myHero.ap * 0.8) + (DanoE[myHero:GetSpellData(_E).level] + myHero.ap * 0.8) * 0.03)
				end
				if myHero:GetSpellData(_R).level ~= 0 then
					RDano = myHero:CalcMagicDamage(MeuAlvo, (DanoR[myHero:GetSpellData(_R).level] + myHero.ap * 0.52) + (DanoR[myHero:GetSpellData(_R).level] + myHero.ap * 0.52) * 0.03)
				end				
				DanoTotal = QDano + WDano + EDano + RDano				
				DanoTotal = DanoTotal
				PorcentagemQueVouFicar = ((MeuAlvo.maxHealth - DanoTotal)/MeuAlvo.maxHealth*100)
				--AtualizarDanoInimigo = os.clock()
				return "Damage to Enemy: "..Arredondar(DanoTotal, 1).." : Stay("..Arredondar(PorcentagemQueVouFicar).."%)"
		end			
end	

function Arredondar(num, idp)
 return string.format("%." .. (idp or 0) .. "f", num)
end

function ManaParaCombo()	
	local qMana = myHero:GetSpellData(_Q).mana or 0
	local wMana = myHero:GetSpellData(_W).mana or 0
	local eMana = myHero:GetSpellData(_E).mana or 0
	local rMana = myHero:GetSpellData(_R).mana or 0
	local ManaTotal = 0
		if Menu.Combo.UseQ then ManaTotal = ManaTotal + qMana end
		if Menu.Combo.UseW then ManaTotal = ManaTotal + wMana end
		if Menu.Combo.UseE then ManaTotal = ManaTotal + eMana end
		if Menu.Combo.UseR then ManaTotal = ManaTotal + rMana end
			if myHero.mana < ManaTotal then
				return "Not Enought Mana to Combo."
			end
end

function LastHitLikeBoss()	
	local tick = os.clock()
	local nexttick = 0
	local TimeToTheFirstDamageTick  = 1.5
	local ProjectileSpeed = myHero.attackSpeed --AA speed
	local delay = -0.02926 + TimeToTheFirstDamageTick -- AA delay	
	local DamageArcane1 = myHero.ap * 0.05
	local DamageButcher1 = 2
	local MasteryDamage1 = 0
		if Menu.Farmerr.ArcaneON then
			MasteryDamage1 = MasteryDamage1 + DamageArcane1
		end
		if Menu.Farmerr.ButcherON then
			MasteryDamage1 = MasteryDamage1 + DamageButcher1
		end		
		if MinionsInimigos ~= nil then
			for i, Minion in pairs(MinionsInimigos.objects) do
				if Minion ~= nil and not Minion.dead then
					local Healthh = VP:GetPredictedHealth(Minion, delay + GetDistance(Minion, myHero) / ProjectileSpeed)
					if Healthh ~= nil and ValidTarget(Minion, 550) and Healthh <= getDmg("AD", Minion, myHero) + MasteryDamage1 and os.clock() > nexttick then						
						myHero:Attack(Minion)
						nexttick = os.clock() + GetLatency() / 2 + Menu.Farmerr.LastHitDelay
						break
					end
				end
			end
		end
		if os.clock() > nexttick then
			myHero:MoveTo(mousePos.x, mousePos.z)
		end
end

function EncontrarAlvoQ()
	local FirstTarget = MeuAlvo
	if Menu.Combo.Ultimate.SuportSilence and FirstTarget ~= nil then
		if CountEnemyHeroInRange(AlZaharCalloftheVoid.range, myHero) > 3 then		
			for i, Suporte in pairs(priorityTable.Support) do
				if MeuAlvo.charName == Suporte and Suporte ~= FirstTarget then
					for i, Inimigo in pairs(GetEnemyHeroes()) do
						if ValidTarget(Inimigo) and Inimigo.charName == Suporte and GetDistance(Inimigo) <= AlZaharCalloftheVoid.range then					
							return Inimigo
						else
							return FirstTarget
						end
					end			
				end
			end
		else
			return FirstTarget
		end
	else
		return FirstTarget
	end
end

function TemQss()
	if Menu.Combo.Ultimate.TemQss then
		if MeuAlvo ~= nil then
			if GetInventoryItemIsCastable(3139, MeuAlvo) == true or GetInventoryItemIsCastable(3140, MeuAlvo) == true then
				return true
			else
				return false
			end
		end
	else
		return false
	end
end

function RoubarJungle()	
    for i, MinionJ in pairs(StealJungle) do
        if not UsandoR and MinionJ.obj ~= nil and MinionJ.obj.valid and not MinionJ.obj.dead and GetDistance(MinionJ.obj) <= AlZaharCalloftheVoid.range and myHero:CanUseSpell(AlZaharCalloftheVoid.spellSlot) == READY and MinionJ.obj.health < getDmg("Q",MinionJ.obj,myHero) then
            CastSpell(_Q, MinionJ.obj.x, MinionJ.obj.z)
        end
    end
end

--[[SIDA Revamped]]--

priorityTable = {
			AP = {
				"Annie", "Ahri", "Akali", "Anivia", "Annie", "Brand", "Cassiopeia", "Diana", "Evelynn", "FiddleSticks", "Fizz", "Gragas", "Heimerdinger", "Karthus",
				"Kassadin", "Katarina", "Kayle", "Kennen", "Leblanc", "Lissandra", "Lux", "Malzahar", "Mordekaiser", "Morgana", "Nidalee", "Orianna",
				"Ryze", "Sion", "Swain", "Syndra", "Teemo", "TwistedFate", "Veigar", "Vel'koz", "Viktor", "Vladimir", "Xerath", "Ziggs", "Zyra",
			},
			Support = {
				"Alistar", "Blitzcrank", "Janna", "Karma", "Leona", "Lulu", "Nami", "Nunu", "Sona", "Soraka", "Taric", "Thresh", "Zilean",
			},
			Tank = {
				"Amumu", "Chogath", "DrMundo", "Galio", "Hecarim", "Malphite", "Maokai", "Nasus", "Rammus", "Sejuani", "Nautilus", "Shen", "Singed", "Skarner", "Volibear",
				"Warwick", "Yorick", "Zac",
			},
			AD_Carry = {
				"Ashe", "Caitlyn", "Corki", "Draven", "Ezreal", "Graves", "Jayce", "Jinx", "KogMaw", "Lucian", "MasterYi", "MissFortune", "Pantheon", "Quinn", "Shaco", "Sivir",
				"Talon","Tryndamere", "Tristana", "Twitch", "Urgot", "Varus", "Vayne", "Yasuo","Zed", 
			},
			Bruiser = {
				"Aatrox", "Darius", "Elise", "Fiora", "Gangplank", "Garen", "Irelia", "JarvanIV", "Jax", "Khazix", "LeeSin", "Nocturne", "Olaf", "Poppy",
				"Renekton", "Rengar", "Riven", "Rumble", "Shyvana", "Trundle", "Udyr", "Vi", "MonkeyKing", "XinZhao",
			},
		}

		--- Arrange Priorities 5v5 ---
--->
	function ArrangePriorities()
		for i, enemy in pairs(enemyHeroes) do
			SetPriority(priorityTable.AD_Carry, enemy, 1)
			SetPriority(priorityTable.AP, enemy, 2)
			SetPriority(priorityTable.Support, enemy, 3)
			SetPriority(priorityTable.Bruiser, enemy, 4)
			SetPriority(priorityTable.Tank, enemy, 5)
		end
	end
---<
--- Arrange Priorities 5v5 ---
--- Arrange Priorities 3v3 ---
--->
	function ArrangeTTPriorities()
		for i, enemy in pairs(enemyHeroes) do
			SetPriority(priorityTable.AD_Carry, enemy, 1)
			SetPriority(priorityTable.AP, enemy, 1)
			SetPriority(priorityTable.Support, enemy, 2)
			SetPriority(priorityTable.Bruiser, enemy, 2)
			SetPriority(priorityTable.Tank, enemy, 3)
		end
	end
---<
--- Arrange Priorities 3v3 ---
--- Set Priorities ---
--->
	function SetPriority(table, hero, priority)
		for i = 1, #table, 1 do
			if hero.charName:find(table[i]) ~= nil then
				TS_SetHeroPriority(priority, hero.charName)
			end
		end
	end
