// A script by TFlippy

void onInit(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	sprite.SetZ(50);
	
	// CSprite@ sprite = this.getSprite();
	// for (int i = 0; i < records.length; i++)
	// {
		// Animation@ anim = sprite.addAnimation("disc_" + i, 8, true);
		// anim.AddFrame(1);
		// anim.AddFrame(i);
	// }
	
	sprite.RewindEmitSound();
	sprite.SetEmitSound("Preusens-Gloria-march");
	sprite.SetEmitSoundVolume(2.0f);
	sprite.SetEmitSoundPaused(false);
					
	sprite.SetAnimation("playing");
}

void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	if (inventoryBlob is null) return;

	CInventory@ inv = inventoryBlob.getInventory();

	if (inv is null) return;

	this.doTickScripts = true;
	inv.doTickScripts = true;
}

void onDie(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSoundPaused(true);
}