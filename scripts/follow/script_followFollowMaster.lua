script_followFollowMaster = {

}

function script_followFollowMaster:run()

-- Follow our master
		if (not script_follow.skipLooting) and (script_follow.lootObj == nil) then
			if (script_follow.lootObj == nil or IsInCombat()) then
				if (script_follow:GetPartyLeaderObject() ~= 0) then
					if(script_follow:GetPartyLeaderObject():GetDistance() > script_follow.followLeaderDistance and not script_follow:GetPartyLeaderObject():IsDead()) and (not localObj:IsDead()) then
						local x, y, z = script_follow:GetPartyLeaderObject():GetPosition();
						if (Move(x, y, z)) then
							script_follow.message = "Following Party Leader...";
							script_follow.timer = GetTimeEX() + 300;
							return true;
						end
					end
				end
			end
		elseif (script_follow.skipLooting) then
			if (script_follow:GetPartyLeaderObject() ~= 0) then
				if(script_follow:GetPartyLeaderObject():GetDistance() > script_follow.followLeaderDistance and not script_follow:GetPartyLeaderObject():IsDead()) and (not localObj:IsDead()) then
					local x, y, z = script_follow:GetPartyLeaderObject():GetPosition();
					if (Move(x, y, z)) then
						script_follow.message = "Following Party Leader...";
						script_follow.timer = GetTimeEX() + 300;
						return true;
					end
				end
			end
		end
return false;
end