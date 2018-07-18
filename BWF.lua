--[[
	Benefits with Friends
	A World of Warcraft AddOn by Alex Schumaker (Anorian-Windrunner)
]]--

BWF = LibStub("AceAddon-3.0"):NewAddon("Benefits with Friends", "AceConsole-3.0", "AceEvent-3.0")

local grouproster = {}
local guildroster = {}
local groupleader
local wasingroup
local autoaccepted
local db

local _

function BWF:OnInitialize()
	local defaults = {
		global = {
			autoacceptinv_enabled = true,
			allowpasslead = true,
			allowfriendinv = true,
			allowFriendFollowing = true,

			guildmembersarefriends = false,
			realID = true,
			character = true,
			btag = true,

			queuesafe = true,
			BWFad = true,

			wqshare = true,
			autosetmarkers = false,
			markerdata = {}
		}
	}

	self.db = LibStub("AceDB-3.0"):New("BWFdb", defaults, true)
	db = self.db.global

	
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Benefits with Friends", self.BWFOptions)
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Benefits with Friends", "BenefitsWithFriends")
	
	C_ChatInfo.RegisterAddonMessagePrefix("BWFmsg");

	BWF:Print("Benefits with Friends loaded!")
	BWF:RegisterEvent("GROUP_ROSTER_UPDATE")
	BWF:RegisterEvent("PLAYER_ENTERING_WORLD")
	BWF:RegisterEvent("PARTY_INVITE_REQUEST")
	BWF:RegisterEvent("FRIENDLIST_UPDATE")
	BWF:RegisterEvent("CHAT_MSG_ADDON")
	BWF:RegisterEvent("CHAT_MSG_PARTY")
	BWF:RegisterEvent("CHAT_MSG_WHISPER")
	BWF:RegisterEvent("CHAT_MSG_BN_WHISPER")
	BWF:RegisterEvent("SUPER_TRACKED_QUEST_CHANGED")
	BWF:RegisterEvent("RAID_TARGET_UPDATE")

	-- BWF:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
end

BWF.BWFOptions = {
	type = "group",
	name = "Benefits with Friends",
	get = function(key) return db[key.arg] end,
	set = function(key, val) db[key.arg] = val end,
	args = {
		autoacceptinv_enabled = {
			name = "Auto-Accept Invites",
			desc = "Auto-Accepts group invitations from friends.",
			type = "toggle",
			order = 2,
			arg = "autoacceptinv_enabled"
		},
		guildmembersarefriends = {
			name = "Guildies are Friends",
			desc = "Will treat all guild members as friends.",
			type = "toggle",
			order = 3,
			arg = "guildmembersarefriends"
		},
		allowpasslead = {
			name = "Allow PassLead",
			desc = "Allows friends in your party take lead from you using by typing '/bwf passlead' or 'bwf passlead' into party chat.",
			type = "toggle",
			order = 3,
			arg = "allowpasslead"
		},
		allowFriendFollowing = {
			name = "Allow Friend Following",
			desc = "Allows friends to use the \"/bwf f\" command to force you to follow them! Great for staying together when someone needs to afk!",
			type = "toggle",
			order = 3,
			arg = "allowFriendFollowing"
		},
		allowfriendinv = {
			name = "Allow Friend Group Invites",
			desc = "Allows friends to invite themselves to your group via whisper.",
			type = "toggle",
			order = 4,
			arg = "allowfriendinv"
		},
		realID = {
			name = "Real ID",
			desc = "Gives benefits to Real ID friends.",
			type = "toggle",
			arg = "realID"
		},
		character = {
			name = "Character",
			desc = "Gives benefits to normal, non-Battle.net friends.",
			type = "toggle",
			arg = "character"
		},
		btag = {
			name = "Battle Tag",
			desc = "Gives benefits to BattleTag friends.",
			type = "toggle",
			arg = "btag"	
		},
		queuesafe = {
			name = "Queue Safety",
			desc = "If checked, you will not auto-accept invites while in a queue that would cancel upon group roster change.",
			type = "toggle",
			arg = "queuesafe"
		},
		BWFad = {
			name = "BWF Announcements",
			desc = "Toggles the announcements promoting BWF when if performs one of its functions!",
			type = "toggle",
			arg = "BWFad"
		},
		wqshare = {
			name = "World Quest Share",
			desc = "If your group leader is using BWF, automatically targets the same world quest that they are!",
			type = "toggle",
			arg = "wqshare"
		},
		autosetmarkers = {
			name = "Auto Set Markers",
			desc = "BWF will attempt to remember which marker was given to someone last time they were in your group and automatically set it for you.",
			type = "toggle",
			arg = "autosetmarkers"
		}
	}	
}

function BWF:BWFtestfunc()
	--local name,_,_,_,_,_,zone,_,_,_,_ = GetRaidRosterInfo(2)
	--BWF:Print(name .. " is in " .. zone)
	
	--_,_,name,_,zone = BNGetFriendInfo(1)
	--BWF:Print(name .. " is on " .. zone)
	
	--for k,v in pairs(BWFdb) do BWF:Print(tostring(k) .. ", " .. tostring(v)) end
	--BWF:Print(guildroster[1])

	--BWF:Print(BWF:GroupFriendMakeup("party", (GetNumGroupMembers() - 1)))
	
	--BWF:BNPrintFriends();
	
	-- self.db:ResetDB("Default")
	-- local prof1, prof2 = GetProfessions()
	-- print(prof1.." "..prof2)
	-- local guid, name = UnitGUID("target"), UnitName("target")
	-- local type, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-",guid);\

	-- print(GetSuperTrackedQuestID())
	-- BWF:CHAT_MSG_ADDON(self, "BWFmsg", "TrackWQ+43328", "idk", "Moonorian")
	-- local ls = {"one", "two", "three"}
	-- for i, item in pairs(ls) do print(item) end 

	-- for i, val in pairs(grouproster) do print(val) end
	for person, marker in pairs(db.markerdata) do print(person.." - "..marker) end

	BWF:Print("Test Complete.")
end

function BWF:testfunction(questID)
	print(IsWorldQuestHardWatched(questID))
end


function BWF:PLAYER_ENTERING_WORLD()
	--Assemble the group roster list and internal friends list.

	for i = 1, GetNumGroupMembers(), 1 do
		local name = GetRaidRosterInfo(i)
		table.insert(grouproster, name)
	end
end

function BWF:FRIENDLIST_UPDATE()
	
end

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
--++++++++++++++++ Chat Message Commands +++++++++++++++++--
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++--

function BWF:CHAT_MSG_ADDON(self, ...)
	local prefix, msg, type, sender = ...
	if prefix == "BWFmsg" then
		local inFunc, inputArgs = strsplit("+", msg)
		BWF[inFunc](self, inputArgs, sender)
	end
end

function BWF:CHAT_MSG_PARTY(self, msg, sender)
	msg = string.lower(msg)
	if msg == "bwf passlead" then
		BWF:PassLead(sender)
	end
end

function BWF:CHAT_MSG_WHISPER(self, msg, sender)
	msg = string.lower(msg)
	if msg == "bwf inv" then
		BWF:FriendInvite(sender)
	end
end

function BWF:CHAT_MSG_BN_WHISPER(self, msg, sender,_,_,_,_,_,_,_,_,_,_,bnetIDAccount)
	msg = string.lower(msg)
	bnetIDGameAccount = select(6, BNGetFriendInfoByID(bnetIDAccount))
	if msg == "bwf inv" and not (BWF:IsQueued() and db.queuesafe) then
		local _,name,game,realm = BNGetGameAccountInfo(bnetIDGameAccount)
		if game == "WoW" then
			BWF:FriendInvite(name .. "-" .. realm)
		end
	end
end

function BWF:SUPER_TRACKED_QUEST_CHANGED(self, questID)
	if UnitIsGroupLeader("player") then
		C_ChatInfo.SendAddonMessage("BWFmsg", "TrackWQ+"..questID, "RAID")
	end
end

function BWF:Follow(inputArgs, sender)
	if db.allowFriendFollowing then
		local target = strsplit("+", inputArgs)
		sender = BWF:SplitNameAndServer(sender)[1]
		if target == UnitName("player") and BWF:IsAFriend(sender) then
			FollowUnit(sender)
			SendChatMessage("Following " .. sender .. "!", "SAY", nil)
		end
	end
end

function BWF:PassLead(inputArgs, sender)
	if db.allowpasslead and UnitIsGroupLeader("player") and BWF:IsAFriend(sender) then
		local name = Ambiguate(sender, "none")
		PromoteToLeader(name)
		if db.BWFad then
			SendChatMessage("Benefits With Friends: Passing lead to " .. name .. "!", "PARTY", nil)
		end
	end
end

function BWF:FriendInvite(name)
	if db.allowfriendinv and (UnitIsGroupLeader("player") or not UnitInParty("player")) and BWF:IsAFriend(name) then
		realname = Ambiguate(name, "none")
		InviteUnit(realname)
		if db.BWFad then
			SendChatMessage("Benefits With Friends: Inviting " .. realname .. " by request!", "PARTY", nil)
		end
	end
end

function BWF:TrackWQ(inputArgs, sender)
	local name = UnitName("player")
	sender = BWF:SplitNameAndServer(sender)[1]
	if db.wqshare and sender ~= name then
		local questID = tonumber(inputArgs)
		BonusObjectiveTracker_TrackWorldQuest(questID)
		SetSuperTrackedQuestID(questID)
	end
end

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
--++++++++++++++++++ Group Action Code +++++++++++++++++++--
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
function BWF:GROUP_ROSTER_UPDATE()
	--If someone has entered or left the party, then we want to reevaluate.
	if IsInGroup() and #grouproster ~= GetNumGroupMembers() then
		local questID = GetSuperTrackedQuestID()
		BWF:UpdateInternalGroupRoster()
		BWF:SUPER_TRACKED_QUEST_CHANGED(self, questID)
		-- if UnitIsGroupLeader("player") and not BWF:NPCGroupCheck() then
		-- 	local type, count = BWF:GetGroupTypeAndCount()
		-- 	local fulloffriends = BWF:GroupFriendMakeup(type)
		-- 	if type == "party" then
		-- 		if fulloffriends and select(1, GetLootMethod()) ~= db.autosetloot_method then
		-- 			SetLootMethod(db.autosetloot_method, "player")
		-- 		elseif not fulloffriends and select(1, GetLootMethod()) ~= "group" then
		-- 			SetLootMethod("group")
		-- 		end
		-- 		--put marks up based on preferred options
		-- 	end
		if not wasingroup and autoaccepted and db.BWFad then
			SendChatMessage("Benefits With Friends: Auto-Accepted Invite!", "PARTY", nil)
			autoaccepted = false	
	end
		if db.autosetmarkers then
			BWF:SetMarkers()
		end
	end

	local newleader = BWF:GetPartyLeader()
	if groupleader ~= newleader then --leader has changed
		groupleader = newleader

		-- Everyone tracks the new leader's objective
		local questID = GetSuperTrackedQuestID()
		BWF:SUPER_TRACKED_QUEST_CHANGED(self, questID)
	end
	
	--You left a group.
	if not IsInGroup() and wasingroup then
		BWF:UpdateInternalGroupRoster()
	end

	--Just entered a group, close popup.
	if IsInGroup() and not wasingroup and not UnitIsGroupLeader("player") then 
		BWF:ClosePopup()
		BWF:UpdateInternalGroupRoster()
		if db.autosetmarkers then
			BWF:SetMarkers()
		end 
	end	

	wasingroup = IsInGroup()
end

function BWF:PARTY_INVITE_REQUEST(info, sender)
	if not (BWF:IsQueued() and db.queuesafe) and db.autoacceptinv_enabled and BWF:IsAFriend(sender) then
		AcceptGroup()
		autoaccepted = true
	elseif BWF:IsQueued() and db.queuesafe then
		BWF:Print("Queue Safety prevented auto-accept.")
	end
end

function BWF:ClosePopup()
	StaticPopup_Hide("PARTY_INVITE")
	StaticPopup_Hide("PARTY_INVITE_XREALM")
end

function BWF:UpdateInternalGroupRoster() 
	grouproster = {}
	for i = 1, GetNumGroupMembers() do
		name = GetRaidRosterInfo(i)
		table.insert(grouproster, name)
	end
end

--+++ Marker Code +++--
function BWF:RAID_TARGET_UPDATE()
	if IsInGroup() then 
		local marker
		for i, member in pairs(grouproster) do 
			marker = GetRaidTargetIndex(member)
			if marker then
				db.markerdata[member] = marker
			end
		end
	end
end

function BWF:SetMarkers()
	if db.autosetmarkers and IsInRaid() == false then
		for i, member in pairs(grouproster) do
			if db.markerdata[member] then 
				--print("Debug: " .. member .. " " .. db.markerdata[member])
				SetRaidTarget(member, db.markerdata[member])
			end
		end
	end
end
--++++++++++++++++++--

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
--++++++++++++++++++   Slash Commands   ++++++++++++++++++--
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++--

BWF.Command = function(msg)
	if msg == "" then
		InterfaceOptionsFrame_OpenToCategory(BWF.optionsFrame)
		InterfaceOptionsFrame_OpenToCategory(BWF.optionsFrame)
	elseif BWF.Commands[msg] then
		BWF.Commands[msg].func()
	else
		return;
	end
end

BWF.Commands = {}

BWF.Commands["follow"] = {}
BWF.Commands["f"] = {}
BWF.Commands["follow"].func = 
	function()
		if UnitName("target") then
			C_ChatInfo.SendAddonMessage("BWFmsg", "Follow+" .. UnitName("target"), "RAID")
		else
			BWF:Print("You must target the person you want to follow you!")
		end
	end

BWF.Commands["f"].func = BWF.Commands["follow"].func

BWF.Commands["passlead"] = {}
BWF.Commands["passlead"].func = 
	function()
		if IsInGroup() then
			C_ChatInfo.SendAddonMessage("BWFmsg", "PassLead+", "RAID")
		end
	end
		

BWF:RegisterChatCommand("bwftest", "BWFtestfunc")
SlashCmdList["benefitswithfriends"] = BWF.Command
SLASH_benefitswithfriends1 = "/benefitswithfriends"
SLASH_benefitswithfriends2 = "/bwf"

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
--++++++++++++++     Support Functions     +++++++++++++++--
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++--

--Gets the group's type and the number of people in it.
function BWF:GetGroupTypeAndCount()
	local type
	local count = GetNumGroupMembers()
	if IsInRaid() then 
		type = "raid"
	else
		type = "party"
	end
	count = count - 1
	return type, count
end 


--Checks to see if your group is made up of your friends!
function BWF:GroupFriendMakeup(type)
	local friendsinparty = 0

	if type == "party" then
		for i = 1, #grouproster, 1 do
			local partyname = grouproster[i]
			
			local guid, name = UnitGUID("party"..i), UnitName("party"..i)
			local type, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-",guid);

			if BWF:IsAFriend(partyname) or type ~= "Player" then
				friendsinparty = friendsinparty + 1
			end	
		end
	end

	--print("Friends in party: " .. friendsinparty .. "/" .. #grouproster)
	if friendsinparty == #grouproster then
		return true
	else
		return false	
	end
end

--Check to see if you are in one of the new Legion npc parties that break the loot rules.
function BWF:NPCGroupCheck()
	for i = 1, #grouproster do
		local guid = UnitGUID("party"..i)
		local type, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-",guid)
		if type == "Player" then 
			return false
		end
	end
	return true
end

function BWF:GetNumFriends()
	local total = 0
	local _,BNonlinefriends = BNGetNumFriends()
	for i = 1, BNonlinefriends do
		if select(7, BNGetFriendInfo(i)) == "WoW" then
			total = total + 1
		end
	end

	local _,onlinefriends = GetNumFriends()
	total = total + onlinefriends

	return total
end

function BWF:IsQueued()
	local lfdqueue = GetLFGQueueStats(LE_LFG_CATEGORY_LFD)
	local rfqueue = GetLFGQueueStats(LE_LFG_CATEGORY_RF)
	return (lfdqueue or rfqueue)
end

function BWF:BNPrintFriends()
	local _,onlinefriends = BNGetNumFriends()
	j = 1
	while j <= onlinefriends do 
		local _,_,_,_,name = BNGetFriendInfo(j)
		print(j .. ":  " .. name)
		j = j + 1			
	end		
end

--Checks to see if the given person is a friend or not!
local friendslist = {}
local guildroster = {}
function BWF:IsAFriend(name)
	name = BWF:SplitNameAndServer(name)[1]
	local value = false
	local _,BNonlinefriends = BNGetNumFriends()
 	local _,onlinefriends = GetNumFriends()

 	if db.realID or db.btag then
	 	for i = 1, BNonlinefriends do
			local _,_,_,_,friend,_,game,_,_,_,_,_,RID = BNGetFriendInfo(i)
			if not friendslist[friend] and game == "WoW" then
				if (RID and db.realID) or (not RID and db.btag) then
					friendslist[friend] = i
				end
			end
		end	
 	end

	
 	if db.character then
	 	for j = 1, onlinefriends do
			local friend = BWF:SplitNameAndServer(GetFriendInfo(j))[1]
			if not friendslist[friend] then friendslist[friend] = j end
		end
 	end

 	if select(1,GetGuildInfo("player")) and db.guildmembersarefriends then
 		_,onlineGuildMembers = GetNumGuildMembers()
		if onlineGuildMembers ~= #guildroster then
			for i = 1, onlineGuildMembers do 
				guildie = BWF:SplitNameAndServer(GetGuildRosterInfo(i))[1]
				if not guildroster[guildie] then guildroster[guildie] = i end
			end
		end
	else
		guildroster = {}
 	end

 	return (friendslist[name] or (db.guildmembersarefriends and guildroster[name]))
end

function BWF:PrintListConents(list)
	for j, item in pairs(list) do
		print(item)
	end
end

function BWF:GetPartyLeader()
	for i, member in pairs(grouproster) do 
		if UnitIsGroupLeader(member) then 
			return member
		end
	end
end

function BWF:SplitNameAndServer(str)
	local result
	local dash = string.find(str, "-")

	if dash then
		result = {str:sub(1,dash-1), str:sub(dash+1,#str)}
	else 
		result = {str, "Server"}
	end

	return result
end









