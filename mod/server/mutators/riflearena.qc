//FEATURE: Rifle Arena, a classic mode a bit like instagib, with the fabled sniper rifle and limited health

AUTOCVAR(g_riflearena, bool, false, "Enable rifle arena mutator");
void ra_SetCvars();
REGISTER_MUTATOR(ra, autocvar_g_riflearena && !autocvar_g_instagib && !cvar("g_overkill") && !g_nexball)
{
	MUTATOR_ONADD
	{
		ra_SetCvars();

		Weapon w;
		w = WEP_BLASTER; w.wr_init(w);
		w = WEP_RIFLE; w.wr_init(w);
	}
}

AUTOCVAR(g_riflearena_withlaser, bool, false, "Enable blaster in the rifle arena mutator");
AUTOCVAR(g_riflearena_rifle_secondary_spread, string, "0", "");
AUTOCVAR(g_riflearena_rifle_secondary_shots, string, "1", "");
AUTOCVAR(g_riflearena_rifle_secondary_animtime, string, "0.15", "");
AUTOCVAR(g_riflearena_rifle_secondary_refire, string, "0.15", "");
AUTOCVAR(g_riflearena_rifle_secondary_damage, string, "40", "");

void ra_SetCvars()
{
	cvar_settemp("g_balance_rifle_secondary_spread", autocvar_g_riflearena_rifle_secondary_spread);
	cvar_settemp("g_balance_rifle_secondary_shots", autocvar_g_riflearena_rifle_secondary_shots);
	cvar_settemp("g_balance_rifle_secondary_animtime", autocvar_g_riflearena_rifle_secondary_animtime);
	cvar_settemp("g_balance_rifle_secondary_refire", autocvar_g_riflearena_rifle_secondary_refire);
	cvar_settemp("g_balance_rifle_secondary_damage", autocvar_g_riflearena_rifle_secondary_damage);
}

MUTATOR_HOOKFUNCTION(ra, Damage_Calculate)
{
	entity frag_attacker = M_ARGV(1, entity);
	entity frag_target = M_ARGV(2, entity);
	float frag_deathtype = M_ARGV(3, float);

	if(IS_PLAYER(frag_attacker))
	if(IS_PLAYER(frag_target))
	{
		if (DEATH_ISWEAPON(frag_deathtype, WEP_BLASTER))
		{
			if(frag_attacker == frag_target)
				M_ARGV(4, float) = 5; // damage
			else
				M_ARGV(4, float) = 0; // damage
			M_ARGV(5, float) = 0; // mirror damage
			if (frag_target != frag_attacker)
			{
				M_ARGV(6, vector) = '0 0 0'; // the force is not strong with this one
			}
		}
	}
}

MUTATOR_HOOKFUNCTION(ra, FilterItemDefinition)
{
	entity definition = M_ARGV(0, entity);

	switch (definition)
	{
		case ITEM_HealthSmall:
		case ITEM_ArmorSmall:
			return false;
	}

	return true;
}

MUTATOR_HOOKFUNCTION(ra, SetStartItems, CBC_ORDER_LAST)
{
	start_items |= IT_UNLIMITED_AMMO;
	start_ammo_nails = warmup_start_ammo_nails = 100;
	warmup_start_weapons = start_weapons = WEPSET(RIFLE);
	
	if(autocvar_g_riflearena_withlaser)
	{
		start_weapons |= WEPSET(BLASTER);
		warmup_start_weapons |= WEPSET(BLASTER);
	}
}

MUTATOR_HOOKFUNCTION(ra, SetWeaponArena)
{
	// turn weapon arena off
	M_ARGV(0, string) = "off";
}

MUTATOR_HOOKFUNCTION(ra, ForbidThrowCurrentWeapon)
{
	return true;
}

MUTATOR_HOOKFUNCTION(ra, ForbidRandomStartWeapons)
{
	return true;
}

MUTATOR_HOOKFUNCTION(ra, BuildMutatorsString)
{
	M_ARGV(0, string) = strcat(M_ARGV(0, string), ":RA");
}

MUTATOR_HOOKFUNCTION(ra, BuildMutatorsPrettyString)
{
	M_ARGV(0, string) = strcat(M_ARGV(0, string), ", Rifle Arena");
}

MUTATOR_HOOKFUNCTION(ra, SetModname)
{
	M_ARGV(0, string) = "Rifle Arena";
	return true;
}
