#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#undef REQUIRE_PLUGIN
#include <adminmenu>

#define DISCORD_URL "discord.l4d.dev"

#include <karma/database.sp>
#include <karma/bans.sp>

public Plugin myinfo =  {
	name = "Karma System", 
	author = "Aleexxx", 
	description = "", 
	version = SOURCEMOD_VERSION, 
	url = "https://l4d.dev/about/karma-ban-system"
};

public void OnPluginStart()
{
	vStartSQL();
	RegConsoleCmd("sm_register", CommandRegister);
}

public void OnDatabaseConnected() {
	vBansRegister();
}

public Action CommandRegister(int client, int args) {
	if (!client)return;
	char steam_id[32];
	GetClientAuthId(client, AuthId_Steam2, steam_id, sizeof(steam_id));
	char sql_command[128];
	Format(sql_command, sizeof(sql_command), "SELECT `discord_password` FROM `players` WHERE `steamid` = '%s' LIMIT 1;", steam_id);
	g_database.Query(onPlayerRegister, sql_command, client);
}

public void onPlayerRegister(Database db, DBResultSet results, const char[] error, int client)
{
	char steam_id[32];
	GetClientAuthId(client, AuthId_Steam2, steam_id, sizeof(steam_id));
	if (results != null) {
		LogError("[KARMA-SYSTEM(CommandRegister)] Failed to query (error: %s)", error);
		ReplyToCommand(client, "\x04[\x05DISCORD\x04]\x01 Something it's wrong, please report to Aleexxx :'v");
		return;
	} else if (results.RowCount == 0) {
		ReplyToCommand(client, "\x04[\x05DISCORD\x04]\x01 The player with the steam id %s does not exist", steam_id);
		return;
	}
	do {
		while (results.FetchRow()) {
			// Extrayendo datos
			if (results.FetchRow()) {
				char password[12];
				results.FetchString(0, password, 12);
				PrintToChat(client, "\x04[\x05DISCORD\x04]\x01 Please don\'t shared this!\nCopy and paste this in \x05#bot-spam\x01 of discord:\n\x04!\x05register \"%s\" \"%s\"", steam_id, password);
			} else {
				ReplyToCommand(client, "\x04[\x05DISCORD\x04]\x01 The player with the steam id %s does not exist", steam_id);
			}
		}
	} while (results.FetchMoreResults());
} 