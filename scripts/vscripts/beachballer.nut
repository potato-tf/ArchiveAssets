function DemoBalls(){
	EntFire("tf_projectile_pipe","RunScriptCode","if (NetProps.GetPropInt(self,`m_nSkin`) == 1){NetProps.SetPropInt(self,`m_nSkin`,0);local a = SpawnEntityFromTable(`prop_dynamic`,{targetname = `ball`, model = `models/props_gameplay/ball001.mdl`}); a.SetOrigin(a.GetOrigin()+Vector(0,-13,0)); NetProps.SetPropEntity(a, `moveparent`, self); NetProps.SetPropInt(a, `m_iParentAttachment`, 1)}")
	EntFire("ball","RunScriptCode","NetProps.SetPropFloat(self,`m_flModelScale`,1.25); if(NetProps.GetPropEntity(self,`moveparent`)==null){self.Kill()}")
	return -1
}