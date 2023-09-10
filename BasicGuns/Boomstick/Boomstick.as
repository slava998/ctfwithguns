#include "GunCommon.as";

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (this.isAttached()) return 0;
	return damage;
}

void onInit(CBlob@ this)
{
	GunSettings settings = GunSettings();

	//General
	//settings.CLIP = 0; //Amount of ammunition in the gun at creation
	settings.TOTAL = 2; //Max amount of ammo that can be in a clip
	settings.FIRE_INTERVAL = 10; //Time in between shots
	settings.RELOAD_TIME = 20; //Time it takes to reload (in ticks)
	settings.AMMO_BLOB = "mat_shotgunammo"; //Ammunition the gun takes

	//Bullet
	settings.B_PER_SHOT = 5; //Shots per bullet | CHANGE B_SPREAD, otherwise both bullets will come out together
	settings.B_SPREAD = 4; //the higher the value, the more 'uncontrollable' bullets get
	settings.B_GRAV = Vec2f(0, 0.01); //Bullet gravity drop
	settings.B_SPEED = 85; //Bullet speed, STRONGLY AFFECTED/EFFECTS B_GRAV
	settings.B_TTL = 5; //TTL = 'Time To Live' which determines the time the bullet lasts before despawning
	settings.B_DAMAGE = 0.6f; //1 is 1 heart
	settings.B_TYPE = HittersTC::shotgun; //Type of bullet the gun shoots | hitter

	//Recoil
	settings.G_RECOIL = -18; //0 is default, adds recoil aiming up
	//settings.G_RANDOMX = true; //Should we randomly move x
	//settings.G_RANDOMY = false; //Should we randomly move y, it ignores g_recoil
	settings.G_RECOILT = 5; //How long should recoil last, 10 is default, 30 = 1 second (like ticks)
	settings.G_BACK_T = 0; //Should we recoil the arm back time? (aim goes up, then back down with this, if > 0, how long should it last)

	//Sound
	settings.FIRE_SOUND = "BoomstickFire.ogg"; //Sound when shooting
	settings.RELOAD_SOUND = "BoomstickReload.ogg"; //Sound when reloading

	//Offset
	settings.MUZZLE_OFFSET = Vec2f(-19, -3); //Where the muzzle flash appears

	this.set("gun_settings", @settings);

	//Custom
	this.Tag("CustomSemiAuto");
	this.set_u32("CustomCoinFlesh", 1);
}