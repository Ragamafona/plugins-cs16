
new const PluginVersion[] = "1.0.1";

#include <amxmodx>
#include <hamsandwich>

public plugin_init() {

	register_plugin("Button lock through walls", PluginVersion, "Ragamafona");
	register_cvar("buttonlock_version", PluginVersion, (FCVAR_SERVER|FCVAR_SPONLY));

	RegisterHam(Ham_Use, "func_button", "@Button_Use_Pre", .Post = false);
	RegisterHam(Ham_Use, "func_rot_button", "@Button_Use_Pre", .Post = false);
	RegisterHam(Ham_Use, "button_target", "@Button_Use_Pre", .Post = false);
}

@Button_Use_Pre(const pEntity, const pPlayer) {

	if(pEntity <= 0 || !ExecuteHam(Ham_IsInWorld, pEntity) || !is_user_alive(pPlayer))
		return HAM_IGNORED;

	new pTarget;

	get_user_aiming(pPlayer, pTarget);

	if(pTarget == pEntity)
		return HAM_IGNORED;

	return HAM_SUPERCEDE;
}
