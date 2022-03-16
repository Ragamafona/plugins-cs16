
new const PluginVersion[] = "1.0.0";

#include <amxmodx>
#include <fakemeta>
#include <reapi>

new const g_szEntityModel[] = "models/player/vip/vip.mdl";

new const g_szRenderFx[][] = {

	"kRenderFxNone",
	"kRenderFxPulseSlow",
	"kRenderFxPulseFast",
	"kRenderFxPulseSlowWide",
	"kRenderFxPulseFastWide",
	"kRenderFxFadeSlow",
	"kRenderFxFadeFast",
	"kRenderFxSolidSlow",
	"kRenderFxSolidFast",
	"kRenderFxStrobeSlow",
	"kRenderFxStrobeFast",
	"kRenderFxStrobeFaster",
	"kRenderFxFlickerSlow",
	"kRenderFxFlickerFast",
	"kRenderFxNoDissipation",
	"kRenderFxDistort",           /* Distort/scale/translate flicker */
	"kRenderFxHologram",          /* kRenderFxDistort + distance fade */
	"kRenderFxDeadPlayer",        /* kRenderAmt is the player index */
	"kRenderFxExplode",           /* Scale up really big! */
	"kRenderFxGlowShell",         /* Glowing Shell */
	"kRenderFxClampMinScale"     /* Keep this sprite from getting very small (SPRITES only!) */
};

new const g_szRenderMode[][] = {

	"kRenderNormal",		/* src */
	"kRenderTransColor",	/* c*a+dest*(1-a) */
	"kRenderTransTexture",	/* src*a+dest*(1-a) */
	"kRenderGlow",			/* src*a+dest -- No Z buffer checks */
	"kRenderTransAlpha",	/* src*srca+dest*(1-srca) */
	"kRenderTransAdd"		/* src*a+dest */
};

enum _: eData_Player {

	epl_iMenuType,
	epl_iInput,

	epl_iFxMode[2],
	Float: epl_flColor[4]
};

new g_aPlayerData[MAX_PLAYERS + 1][eData_Player];

new g_pEntity;

public plugin_precache() {

	precache_model(g_szEntityModel);
}

public plugin_init() {

	register_plugin("[TEST] Rendering", PluginVersion, "Ragamafona");

	register_clcmd("say /render", "@ClientCommand_Render");
	register_clcmd("rs_input", "@ClientCommand_Input");
}

public client_putinserver(pPlayer) {

	g_aPlayerData[pPlayer][epl_flColor][3] = 150.0;
}

@ClientCommand_Render(const pPlayer) {

	Open_MenuMain(pPlayer, g_aPlayerData[pPlayer][epl_iMenuType] = 0);
}

@ClientCommand_Input(const pPlayer) {

	new iInputNum = g_aPlayerData[pPlayer][epl_iInput];

	if(!iInputNum)
		return;

	new szMessage[MAX_NAME_LENGTH];

	read_argv(1, szMessage, MAX_NAME_LENGTH - 1);
	remove_quotes(szMessage);
	trim(szMessage);

	if(szMessage[0] == EOS)
		return;

	g_aPlayerData[pPlayer][epl_flColor][iInputNum - 1] = str_to_float(szMessage);
	Open_MenuMain(pPlayer, g_aPlayerData[pPlayer][epl_iMenuType] = 0);
}

Open_MenuMain(const pPlayer, const iType) {

	new pMenuId = menu_create("\rTest rendering", "@Handle_MenuMain");

	switch(iType)
	{
		case 0:
		{
			menu_additem(pMenuId, fmt("%s entity", is_nullent(g_pEntity) ? "Create" : "Remove"));
			menu_additem(pMenuId, fmt("Fx: \r%s", g_szRenderFx[g_aPlayerData[pPlayer][epl_iFxMode][0]]));
			menu_additem(pMenuId, fmt("Mode: \r%s", g_szRenderMode[g_aPlayerData[pPlayer][epl_iFxMode][1]]));
			menu_additem(pMenuId, fmt("R: \r%.0f", g_aPlayerData[pPlayer][epl_flColor][0]));
			menu_additem(pMenuId, fmt("G: \r%.0f", g_aPlayerData[pPlayer][epl_flColor][1]));
			menu_additem(pMenuId, fmt("B: \r%.0f", g_aPlayerData[pPlayer][epl_flColor][2]));
			menu_additem(pMenuId, fmt("Amt: \r%.0f", g_aPlayerData[pPlayer][epl_flColor][3]));

			Func_UpdateEntityRender(pPlayer);
		}
		case 1:
		{
			for(new a; a < sizeof(g_szRenderFx); a++)
			{
				menu_additem(pMenuId, g_szRenderFx[a]);
			}
		}
		case 2:
		{
			for(new a; a < sizeof(g_szRenderMode); a++)
			{
				menu_additem(pMenuId, g_szRenderMode[a]);
			}
		}
	}
	
	menu_display(pPlayer, pMenuId, 0);
}

@Handle_MenuMain(const pPlayer, const pMenuId, const pItem) {

	if(pItem == MENU_EXIT)
	{
		menu_destroy(pMenuId);
		return PLUGIN_HANDLED;
	}

	new iMenuType = g_aPlayerData[pPlayer][epl_iMenuType];

	switch(iMenuType)
	{
		case 0:
		{
			switch(pItem)
			{
				case 0:
				{
					new pEntity = g_pEntity;

					if(is_nullent(pEntity))
					{
						pEntity = rg_create_entity("info_target");

						new Float: flOrigin[3];

						set_entvar(pEntity, var_movetype, MOVETYPE_NOCLIP);
						set_entvar(pEntity, var_solid, SOLID_NOT);

						get_entvar(pPlayer, var_origin, flOrigin);
						set_entvar(pEntity, var_origin, flOrigin);

						get_entvar(pPlayer, var_v_angle, flOrigin);
						set_entvar(pEntity, var_angles, flOrigin);

						engfunc(EngFunc_SetModel, pEntity, g_szEntityModel);
						//set_entvar(pEntity, var_body, 1);
					}
					else
					{
						set_entvar(pEntity, var_flags, FL_KILLME);
						pEntity = 0;
					}

					g_pEntity = pEntity;
					Func_UpdateEntityRender(pPlayer);

					Open_MenuMain(pPlayer, g_aPlayerData[pPlayer][epl_iMenuType] = 0);
				}
				case 1, 2:
				{
					Open_MenuMain(pPlayer, g_aPlayerData[pPlayer][epl_iMenuType] = pItem);
				}
				//case 3, 4, 5, 6:
				case 3..6:
				{
					g_aPlayerData[pPlayer][epl_iInput] = pItem - 2;
					client_cmd(pPlayer, "messagemode ^"rs_input^"");
				}
			}
		}
		case 1, 2:
		{
			g_aPlayerData[pPlayer][epl_iFxMode][iMenuType - 1] = pItem;
			Open_MenuMain(pPlayer, g_aPlayerData[pPlayer][epl_iMenuType] = 0);
		}
	}

	menu_destroy(pMenuId);
	return PLUGIN_HANDLED;
}

Func_UpdateEntityRender(const pPlayer) {

	if(is_nullent(g_pEntity))
		return;

	new Float: flColor[3];

	flColor[0] = g_aPlayerData[pPlayer][epl_flColor][0];
	flColor[1] = g_aPlayerData[pPlayer][epl_flColor][1];
	flColor[2] = g_aPlayerData[pPlayer][epl_flColor][2];

	UTIL_SetRendering(g_pEntity, 
		g_aPlayerData[pPlayer][epl_iFxMode][0],
		flColor,
		g_aPlayerData[pPlayer][epl_iFxMode][1],
		g_aPlayerData[pPlayer][epl_flColor][3]
	);
}

//

stock UTIL_SetRendering(const pEntity, const iFx, const Float: flColors[3], const iMode, const Float: flAmmount) {
	
	set_entvar(pEntity, var_renderfx, iFx);
	set_entvar(pEntity, var_rendercolor, flColors);
	set_entvar(pEntity, var_rendermode, iMode);
	set_entvar(pEntity, var_renderamt, flAmmount);
}