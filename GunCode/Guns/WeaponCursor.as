#include "GunCommon.as";
//#include "DeityCommon.as";

void onRender(CSprite@ this)
{
	CHUD@ hud = getHUD();
	hud.ShowCursor();
	
	CBlob@ blob = this.getBlob();
	if (blob !is null && blob.isMyPlayer())
	{
		CBlob@ gun = blob.getCarriedBlob();
		if (gun !is null)
		{
			if (gun.hasTag("weapon"))
			{

				if(!hud.hasMenus())hud.HideCursor();

				GunSettings@ settings;
				gun.get("gun_settings", @settings);
				
				Vec2f CursorPos = gun.get_Vec2f("aim");
				Vec2f AimPos = blob.getAimPos()-gun.getInterpolatedPosition();
				CursorPos.Normalize();
				CursorPos = CursorPos*AimPos.Length();
				
				Vec2f mouse_pos = getControls().getInterpMouseScreenPos();
				Vec2f virtual_pos = getDriver().getScreenPosFromWorldPos(gun.getInterpolatedPosition()+CursorPos);
				if((mouse_pos-virtual_pos).Length() < 8.0f)virtual_pos = mouse_pos;
				
				SColor Col = SColor(255,255,255,255);

				Render::SetTransformScreenspace();
				
				u8 DefaultAimSpace = 10;
				int AimSpace = DefaultAimSpace;
				if (settings !is null){	
					if (settings.TOTAL > 15) {
						AimSpace = Maths::Max(settings.TOTAL-15, DefaultAimSpace);
						
						if (settings.TOTAL > 50)
							AimSpace = 35;
					}else{
						AimSpace = DefaultAimSpace;
					}
				}
				Vertex[] cross_height_vertex;
				for( int i = 0; i < 4; i += 1){
					
					float angle = i*90;
					
					Vec2f Dimensions = Vec2f(7,7);
					
					Vec2f TopLeft = Vec2f(-Dimensions.x/2,-Dimensions.y/2)*2;
					Vec2f TopRight = Vec2f(Dimensions.x/2,-Dimensions.y/2)*2;
					Vec2f BotLeft = Vec2f(-Dimensions.x/2,Dimensions.y/2)*2;
					Vec2f BotRight = Vec2f(Dimensions.x/2,Dimensions.y/2)*2;
					TopLeft.RotateByDegrees(angle);
					TopRight.RotateByDegrees(angle);
					BotLeft.RotateByDegrees(angle);
					BotRight.RotateByDegrees(angle);
					
					Vec2f DrawPos = Vec2f(AimSpace,0);
					DrawPos.RotateByDegrees(angle);
					
					DrawPos = mouse_pos+DrawPos;
				
					cross_height_vertex.push_back(Vertex(DrawPos.x+TopLeft.x, DrawPos.y+TopLeft.y, 1, 0, 1, Col)); //top left
					cross_height_vertex.push_back(Vertex(DrawPos.x+TopRight.x, DrawPos.y+TopRight.y, 1, 0.5, 1, Col)); //top right
					cross_height_vertex.push_back(Vertex(DrawPos.x+BotRight.x, DrawPos.y+BotRight.y,1, 0.5, 0, Col)); //bot right
					cross_height_vertex.push_back(Vertex(DrawPos.x+BotLeft.x, DrawPos.y+BotLeft.y,1, 0, 0, Col)); //bot left
				}
				Render::RawQuads("GunCrossHair.png",cross_height_vertex);
				
				/*
				CBlob@ force_target = getBlobByNetworkID(gun.get_netid("force_aim"));
				
				if(force_target is null){
					GUI::DrawIcon("WeaponVirtualCursor.png", 0, Vec2f(32,32), virtual_pos+Vec2f(-31, -31));
				} else {
					GUI::DrawIcon("WeaponVirtualCursor.png", 1, Vec2f(64,32), getDriver().getScreenPosFromWorldPos(force_target.getInterpolatedPosition()+Vec2f(0,-2))+Vec2f(-31, -31));
				}*/
				
				cross_height_vertex.clear();
				for( int i = 0; i < 4; i += 1){
					
					float angle = i*90;
					
					Vec2f Dimensions = Vec2f(7,7);
					
					Vec2f TopLeft = Vec2f(-Dimensions.x/2,-Dimensions.y/2)*2;
					Vec2f TopRight = Vec2f(Dimensions.x/2,-Dimensions.y/2)*2;
					Vec2f BotLeft = Vec2f(-Dimensions.x/2,Dimensions.y/2)*2;
					Vec2f BotRight = Vec2f(Dimensions.x/2,Dimensions.y/2)*2;
					TopLeft.RotateByDegrees(angle);
					TopRight.RotateByDegrees(angle);
					BotLeft.RotateByDegrees(angle);
					BotRight.RotateByDegrees(angle);
					
					Vec2f DrawPos = Vec2f(AimSpace,0);
					DrawPos.RotateByDegrees(angle);
					
					DrawPos = mouse_pos+DrawPos;
					
					cross_height_vertex.push_back(Vertex(DrawPos.x+TopLeft.x, DrawPos.y+TopLeft.y, 1, 0.5, 1, Col)); //top left
					cross_height_vertex.push_back(Vertex(DrawPos.x+TopRight.x, DrawPos.y+TopRight.y, 1, 1, 1, Col)); //top right
					cross_height_vertex.push_back(Vertex(DrawPos.x+BotRight.x, DrawPos.y+BotRight.y,1, 1, 0, Col)); //bot right
					cross_height_vertex.push_back(Vertex(DrawPos.x+BotLeft.x, DrawPos.y+BotLeft.y,1, 0.5, 0, Col)); //bot left
				}
				Render::RawQuads("GunCrossHair.png",cross_height_vertex);
				
				int Skip = 1;
				bool angled = false;
				int ammo = gun.get_u8("clip");
				int maxammo = ammo;
				
				if (settings !is null)
				{
					if(settings.TOTAL >= 50) {
						Skip = Maths::Floor(settings.TOTAL/50);
						angled = true;
					}
				
					maxammo = settings.TOTAL;

					if (gun.get_bool("doReload") && !gun.hasTag("CustomShotgunReload"))
					{
						f32 mod = 0;
						f32 reload_time = settings.RELOAD_TIME;
						/*if (blob.get_u8("deity_id") == Deity::tflippy)
						{
							f32 power = 0;
							
							CBlob@ altar = getBlobByName("altar_tflippy");
							if (altar !is null)
							{
								power = altar.get_f32("deity_power");
								mod = Maths::Min(power * 0.00003f, 0.35f);
							}

							reload_time = reload_time-(reload_time*mod);
						}*/

						//Reloading sequence
						u32 endTime = reload_time;
						u32 reloadTime = gun.get_u8("actionInterval");
						u32 startTime = endTime - reloadTime;
						ammo = f32(maxammo)*f32(startTime) / f32(endTime);
						
						//if(maxammo < 3){
						//	maxammo = 8;
						//	ammo = f32(8)*f32(startTime) / f32(endTime);
						//}
					}
				}
				
				Vertex[] bullet_vertex;
				for( int i = 0; i < ammo; i += Skip){
					
					float angle = i*360/maxammo-90.0f;
					
					Vec2f Dimensions = Vec2f(5,5);
					
					Vec2f TopLeft = Vec2f(-Dimensions.x/2,-Dimensions.y/2)*2;
					Vec2f TopRight = Vec2f(Dimensions.x/2,-Dimensions.y/2)*2;
					Vec2f BotLeft = Vec2f(-Dimensions.x/2,Dimensions.y/2)*2;
					Vec2f BotRight = Vec2f(Dimensions.x/2,Dimensions.y/2)*2;
					if(angled){
						TopLeft.RotateByDegrees(angle);
						TopRight.RotateByDegrees(angle);
						BotLeft.RotateByDegrees(angle);
						BotRight.RotateByDegrees(angle);
					}
					
					Vec2f DrawPos = Vec2f(AimSpace+10,0);
					DrawPos.RotateByDegrees(angle);
					
					DrawPos = mouse_pos+DrawPos;
				
					bullet_vertex.push_back(Vertex(DrawPos.x+TopLeft.x, DrawPos.y+TopLeft.y, 1, 0, 1, Col)); //top left
					bullet_vertex.push_back(Vertex(DrawPos.x+TopRight.x, DrawPos.y+TopRight.y, 1, 1, 1, Col)); //top right
					bullet_vertex.push_back(Vertex(DrawPos.x+BotRight.x, DrawPos.y+BotRight.y,1, 1, 0, Col)); //bot right
					bullet_vertex.push_back(Vertex(DrawPos.x+BotLeft.x, DrawPos.y+BotLeft.y,1, 0, 0, Col)); //bot left
				}
				Render::RawQuads("GunAmmoPip.png",bullet_vertex);
			}
		}
	}
}
