#include <sourcemod>
#include <sdktools_functions>

#pragma semicolon 1
#pragma newdecls required

bool block = false;

#define LoopClientsValid(%1) for (int %1 = 1; %1 <= MaxClients; %1++) if (IsValidClient(%1))

public Plugin myinfo = 
{
	name = "Saklanbaç Sonakalan Ebe Seçme", 
	author = "ByDexter", 
	description = "", 
	version = "1.0", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

public void OnPluginStart()
{
	HookEvent("round_start", RoundStart);
	
	HookEvent("player_death", OnClientDead);
}

public Action RoundStart(Event event, const char[] name, bool dB)
{
	if (GetTeamClientCount(3) <= 1)
	{
		block = true;
	}
}

public Action OnClientDead(Event event, const char[] name, bool dB)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (IsValidClient(client) && GetClientTeam(client) == 3)
	{
		if (!block)
		{
			if (GetTeamClientCount(3) == 1)
			{
				LoopClientsValid(i)
				{
					if (IsPlayerAlive(i) && GetClientTeam(i) == 3)
					{
						EbeSor().Display(i, 0);
					}
				}
			}
		}
		else
		{
			if (GetTeamClientCount(3) == 0)
			{
				LoopClientsValid(i)
				{
					if (GetClientTeam(i) == 3)
					{
						ForcePlayerSuicide(i);
						ChangeClientTeam(i, 2);
					}
					else if (GetClientTeam(i) == 2)
					{
						ForcePlayerSuicide(i);
						ChangeClientTeam(i, 3);
					}
				}
			}
		}
	}
}

Menu EbeSor()
{
	Menu menu = new Menu(Menu_Callback);
	char name[128], userid[32];
	menu.SetTitle("★ Ebe Seç ★\n ");
	LoopClientsValid(i)
	{
		if (GetClientTeam(i) == 3)
		{
			GetClientName(i, name, 128);
			FormatEx(userid, 32, "%d", GetClientUserId(i));
			menu.AddItem(userid, name);
		}
	}
	menu.AddItem(" ", " ", ITEMDRAW_NOTEXT);
	return menu;
}

public int Menu_Callback(Menu menu, MenuAction action, int client, int position)
{
	if (action == MenuAction_Select)
	{
		char item[32];
		menu.GetItem(position, item, 32);
		int target = GetClientOfUserId(StringToInt(item));
		PrintToChatAll("[SM] \x10%N\x01, \x10%N \x01tarafından Ebe seçildi", target, client);
		LoopClientsValid(i)
		{
			if (GetClientTeam(i) == 2)
			{
				ChangeClientTeam(i, 3);
				ForcePlayerSuicide(i);
			}
		}
		ChangeClientTeam(target, 2);
		ForcePlayerSuicide(target);
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}

bool IsValidClient(int client, bool nobots = true)
{
	return client >= 1 && client <= MaxClients && IsClientInGame(client) && !IsClientSourceTV(client) && IsClientConnected(client) && (nobots && !IsFakeClient(client));
} 