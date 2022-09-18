script_paranoia = {

    stopOnLevel = true,		-- stop bot on level up on/off
	exitBot = false,
	targetedLevel = GetLocalPlayer():GetLevel() + 1,	-- target level to stop bot when we level up.
	deathCounterLogout = 3,
	deathCounterExit = true,
    sitParanoid = true,	
    paranoidOn = true,
	paranoidOnTargeted = true,
	useCampfire = true,

}


function script_paranoia:checkParanoia()
    -- Check: Paranoid feature

    localObj = GetLocalPlayer();
    		
	-- logout if death counter reached
	if (script_grindEX.deathCounter >= 1) and (script_grindEX.deathCounter >= script_paranoia.deathCounterLogout) then
		StopBot();
		script_grindEX.deathCounter = 0;
		if (script_paranoia.deathCounterExit) then
			Exit();
		end
	end

	-- logout if level reached
	if (script_paranoia.stopOnLevel) then
			selfLevel = GetLocalPlayer():GetLevel();
		if (selfLevel >= self.targetedLevel) then
			StopBot();
			self.targetedLevel = self.targetedLevel + 1;
			if (self.exitBot) then
				Exit();
			end
		end
	end

    -- don't allow sitting when paranoia range is too low
    if (script_grind.paranoidRange <= 149) then
        self.sitParanoid = false;
    elseif (script_grind.paranoidRange >= 150) then
        self.sitParanoid = true;
    end

        -- if targeted by player
        if (not localObj:IsDead() and self.paranoidOn and not IsInCombat()) then 
            if (self.paranoidOnTargeted and script_grind:playersTargetingUs() > 0) then
                script_grind.message = "Player(s) targeting us, pausing...";
                self.waitTimer = GetTimeEX() + 12236;
                ClearTarget();
                if IsMoving() then
                    self.waitTimer = GetTimeEX() + 11234;
                    StopMoving();
                end
            return;
            end
        end

        -- if players in range then
        if (script_grind:playersWithinRange(script_grind.paranoidRange)) then
            script_grind.message = "Player(s) within paranoid range, pausing...";
            self.waitTimer = GetTimeEX() + 4123;
            ClearTarget();
            if IsMoving() then
                StopMoving();
                self.waitTimer = GetTimeEX() + 8523
            end

            -- twow bright campfire
            if (HasSpell("Bright Campfire")) and (not IsInCombat()) and (self.useCampfire) then
                if (GetXPExhaustion() == nil) and (not IsInCombat()) and (not localObj:HasBuff("Stealth")) and (not localObj:HasBuff("Bear Form")) and (not localObj:HasBuff("Cat Form")) then
                    if (HasSpell("Bright Campfire")) and (HasItem("Simple Wood")) and (HasItem("Flint and Tinder")) and (not IsSpellOnCD("Bright Campfire")) then
                        if (not IsStanding()) then
                            JumpOrAscendStart();
                        end
                        if (not IsSpellOnCD("Bright Campfire")) then
                            CastSpellByName("Bright Campfire");
                            if (IsStanding()) and (self.sitParanoid) then
                                SitOrStand();
                            end
                            -- wait 2+ mins
                            self.waitTimer = GetTimeEX() + 123241;
                            return 0;
                        end
                    end
                end
            end

            -- night elf shadowmeld
            if (HasSpell("Shadowmeld")) and (not HasSpell("Stealth")) then
                if (not IsSpellOnCD("Shadowmeld")) and (not localObj:HasBuff("Shadowmeld")) and (not localObj:HasBuff("Bear Form")) and
                    (not localObj:HasBuff("Dire Bear Form")) and (not localObj:HasBuff("Cat Form")) then
                    if (CastSpellByName("Shadowmeld")) then
                        return 0;
                    end
                elseif (localObj:HasBuff("Bear Form")) then
                    if (CastSpellByName("Bear Form")) then
                        return 0;
                    end
                    if (CastSpellByName("Shadowmeld")) then
                        return 0;
                    end
                end
            end

            -- rogue stealth while paranoid
            if (HasSpell("Stealth")) and (not IsSpellOnCD("Stealth")) and (not localObj:HasBuff("Stealth")) then
                if (CastSpellByName("Stealth")) then
                    return 0;
                end
            end

            -- druid stealth while paranoid
            if (localObj:HasBuff("Cat Form")) and (HasSpell("Prowl")) and (not IsSpellOnCD("Prowl")) and (not localObj:HasBuff("Prowl")) then
                if (CastSpellByName("Prowl")) then
                    return 0;
                end
            end

            -- wait and sit when paranoid if enabled
            self.waitTimer = GetTimeEX() + 10000;
            if (self.sitParanoid) then
                if (IsStanding()) and (not IsInCombat())then
                        SitOrStand();
                end
            end
        return true;
        end
end

function script_paranoia:menu()

    if (CollapsingHeader("Talents, Paranoia & Misc Options")) then
		wasClicked, script_grind.jump = Checkbox("Jump On/Off", script_grind.jump);

		if (script_grind.jump) then
			SameLine();
			Text("- Jump Rate 100 = No Jumping!");
			script_grind.jumpRandomFloat = SliderInt("Jump Rate", 86, 100, script_grind.jumpRandomFloat);
		end

		--wasClicked, script_grind.useMount = Checkbox("Use Mount", script_grind.useMount); Text('Dismount range');
		--script_grind.disMountRange = SliderInt("DR (yd)", 1, 100, script_grind.disMountRange); Separator();
		
        wasClicked, script_grind.autoTalent = Checkbox("Spend Talent Points  ", script_grind.autoTalent);
		
        SameLine();
		
        Text("Change Talents In script_talent.lua");
		if (script_grind.autoTalent) then
			Text("Spending Next Talent Point In: " .. (script_talent:getNextTalentName() or " "));
			Separator();
		end

		wasClicked, script_paranoia.paranoidOn = Checkbox("Enable Paranoia", script_paranoia.paranoidOn);
		SameLine();
		
        if (script_grind.paranoidRange > 149) then
			wasClicked, script_paranoia.sitParanoid = Checkbox("Sit When Paranoid", script_paranoia.sitParanoid);
		end

		wasClicked, script_paranoia.paranoidOnTargeted = Checkbox("Paranoid When Targeted By Player", script_paranoia.paranoidOnTargeted);
	 		
		if (HasSpell("Bright Campfire")) and (HasItem("Simple Wood")) then
			wasClicked, script_paranoia.useCampfire = Checkbox("Use Bright Campfire When Paranoid", script_paranoia.useCampfire);
		end

		wasClicked, script_paranoia.stopOnLevel = Checkbox("Stop Bot When Next Level Reached", script_paranoia.stopOnLevel);
		
		if (script_paranoia.stopOnLevel) then
			SameLine();
			wasClicked, script_paranoia.exitBot = Checkbox("Exit Bot On Level Up", script_paranoia.exitBot);
		end
		
		Text("Stop Bot On "..script_paranoia.deathCounterLogout.. " Deaths    "); 
		SameLine(); 
		wasClicked, script_paranoia.deathCounterExit = Checkbox("Exit Bot On "..script_paranoia.deathCounterLogout.." Deaths", script_paranoia.deathCounterExit);
		script_paranoia.deathCounterLogout = SliderInt("Deaths", 1, 5, script_paranoia.deathCounterLogout);
		
        Text('Paranoia Range'); script_grind.paranoidRange = SliderInt("P (yd)", 50, 300, script_grind.paranoidRange);
		
		Separator();

		Text("Script Tick Rate - How Fast The Scripts Run"); script_grind.tickRate = SliderFloat("TR (ms)", 0, 2000, script_grind.tickRate);		
	end
end