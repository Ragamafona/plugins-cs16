/* ---------------------------------------------------------------------------- */

/*
	My contacts:

	VK: vk.com/felhalas
	VK Group: vk.com/ragashop
	Discord: Ragamafona#7101
*/

new const PluginVersion[] = "1.0.0";

/* ---------------------------------------------------------------------------- */

#include <amxmodx>
#include <hamsandwich>

/* ---------------------------------------------------------------------------- */

public plugin_init() {

	register_plugin("Button lock through walls", PluginVersion, "Ragamafona");
	register_cvar("jb_buttonlock_version", PluginVersion, (FCVAR_SERVER|FCVAR_SPONLY));

	RegisterHam(Ham_Use, "func_button", "@HamUse_Object_Pre", .Post = false);
}

/* ---------------------------------------------------------------------------- */

@HamUse_Object_Pre(const iEntity, const pPlayer) {

	if(iEntity <= 0 || !ExecuteHam(Ham_IsInWorld, iEntity) || !is_user_alive(pPlayer))
		return HAM_IGNORED;

	new iTarget;

	get_user_aiming(pPlayer, iTarget);

	if(iTarget == iEntity)
		return HAM_IGNORED;

	return HAM_SUPERCEDE;
}

/*
	My contacts:

	VK: vk.com/felhalas
	VK Group: vk.com/ragashop
	Discord: Ragamafona#7101
*/

/* ---------------------------------------------------------------------------- */