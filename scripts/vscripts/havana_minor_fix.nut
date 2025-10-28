// Flip sentry gun hints 180 deg to fix backward sentries.
for (local hint; hint = Entities.FindByClassname(hint, "bot_hint_sentrygun");) {
	local orientation = hint.GetAbsAngles()
	orientation.y += 180.0
	hint.SetAbsAngles(orientation)
}

// Fix bad tags and inconsistent team set on a func_nav_avoid.
// Was "team" "-2" and "tags" "common, bomb_carrier".
for (local avoid; avoid = Entities.FindByClassname(avoid, "func_nav_avoid");) {
	if (NetProps.GetPropInt( avoid, "m_iHammerID" ) != 864100) continue

	avoid.KeyValueFromString("tags", "common bomb_carrier")
	avoid.SetTeam(Constants.ETFTeam.TF_TEAM_BLUE)
	avoid.DispatchSpawn()
	break
}
