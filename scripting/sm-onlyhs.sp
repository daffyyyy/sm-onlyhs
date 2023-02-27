#include <sdkhooks>
#include <cstrike>
#include <multicolors>

#pragma semicolon 1
#pragma newdecls required

int				 g_iEnabled[MAXPLAYERS + 1];

public Plugin myinfo =
{
	name		= "(DF) OnlyHS",
	author		= "daffyy",
	description = "Enable only hs for player",
	version		= "1.0",
	url			= "https://utopiafps.pl"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_onlyhs", CMD_OnlyHs);

	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsClientSourceTV(i))
		{
			g_iEnabled[i] = false;
			SDKHook(i, SDKHook_OnTakeDamage, OnTakeDamage);
		}
	}

	LoadTranslations("sm-onlyhs");
	CSetPrefix("%t", "TAG");
}

public void OnClientPostAdminCheck(int client)
{
	g_iEnabled[client] = false;
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action CMD_OnlyHs(int client, int args)
{
	g_iEnabled[client] = !g_iEnabled[client];
	CPrintToChat(client, "%t %t", g_iEnabled[client] ? "Enabled" : "Disabled", "CMDInfo");
	return Plugin_Handled;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if (IsValidEdict(weapon) && IsClientInGame(attacker) && IsClientInGame(victim) && g_iEnabled[attacker] && GetClientTeam(attacker) != GetClientTeam(victim))
	{
		if (damagetype & CS_DMG_HEADSHOT)
		{
			return Plugin_Continue;
		}

		damage = 0.0;
		return Plugin_Changed;
	}

	return Plugin_Continue;
}