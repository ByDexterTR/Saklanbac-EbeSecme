#include <sourcemod>
#include <sdktools>

#pragma semicolon 1
#pragma newdecls required

bool block = false;

public Plugin myinfo = 
{
	name = "Saklanbaç Sonakalan Ebe Seçme", 
	author = "ByDexter", 
	description = "", 
	version = "1.1", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

public void OnPluginStart()
{
	HookEvent("round_start", RoundStart);
	
	HookEvent("player_death", OnClientDead);
	
	AddCommandListener(FilterCommand_DisableChangeTeam, "jointeam");
	AddCommandListener(FilterCommand_DisableChangeTeam, "teammenu");
}

public Action FilterCommand_DisableChangeTeam(int client, const char[] command, int argc)
{
	PrintToChat(client, "[SM] Takım değiştirme şu an \x07kapalı.");
	return Plugin_Handled;
}

public void OnClientPostAdminCheck(int client)
{
	ChangeClientTeam(client, 3);
}

public Action RoundStart(Event event, const char[] name, bool dB)
{
	block = false;
	int CT = 0;
	for (int i = 1; i <= MaxClients; i++)if (IsValidClient(i) && GetClientTeam(i) == 3)
	{
		CT++;
	}
	if (CT <= 1)
	{
		block = true;
	}
}

public Action OnClientDead(Event event, const char[] name, bool dB)
{
	if (!block)
	{
		int CT = 0;
		for (int i = 1; i <= MaxClients; i++)if (IsValidClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == 3)
		{
			CT++;
		}
		if (CT <= 1)
		{
			for (int i = 1; i <= MaxClients; i++)if (IsValidClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == 3)
			{
				EbeSor().Display(i, 15);
			}
		}
	}
	else
	{
		int CT = 0;
		for (int i = 1; i <= MaxClients; i++)if (IsValidClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == 3)
		{
			CT++;
		}
		if (CT <= 0)
		{
			for (int i = 1; i <= MaxClients; i++)if (IsValidClient(i))
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

Menu EbeSor()
{
	Menu menu = new Menu(Menu_Callback);
	char name[128], userid[32];
	menu.SetTitle("★ Ebe Seç ★\n ");
	menu.AddItem(" ", " ", ITEMDRAW_NOTEXT);
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && GetClientTeam(i) == 3)
		{
			GetClientName(i, name, 128);
			FormatEx(userid, 32, "%d", GetClientUserId(i));
			menu.AddItem(userid, name);
		}
	}
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
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && GetClientTeam(i) == 2)
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
	return client >= 1 && client <= MaxClients && IsValidClient(client) && !IsClientSourceTV(client) && IsClientConnected(client) && (nobots && !IsFakeClient(client));
} 