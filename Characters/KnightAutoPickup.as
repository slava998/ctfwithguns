#define SERVER_ONLY
#include "GunCommon.as";
#include "CratePickupCommon.as"

void onInit(CBlob@ this)
{
	this.getCurrentScript().removeIfTag = "dead";
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null || blob.getShape().vellen > 1.0f)
	{
		return;
	}

	string blobName = blob.getName();

	if (blobName == "mat_bombs" || (blobName == "satchel" && !blob.hasTag("exploding")) || blobName == "mat_waterbombs")
	{
		if (this.server_PutInInventory(blob))
		{
			return;
		}
	}
	bool add = true;
	if (blob.hasTag("ammo")) //only add ammo if we have something that can use it, or if same ammo exists in inventory.
	{
		add = false;
		CBlob@[] items;
		if (this.getCarriedBlob() != null)
		{
			items.push_back(this.getCarriedBlob());
		}
		CInventory@ inv = this.getInventory();
		for (int i = 0; i < inv.getItemsCount(); i++)
		{
			CBlob@ item = inv.getItem(i);
			items.push_back(item);
		}
		for (int i = 0; i < items.size(); i++)
		{
			CBlob@ item = items[i];

			GunSettings@ settings;
			item.get("gun_settings", @settings);

			if (settings !is null && settings.AMMO_BLOB == blob.getName() || item.getName() == blob.getName())
			{
				add = true;
				break;
			}
		}
		if (!add){return;}
		if (!this.server_PutInInventory(blob))
		{
			// we couldn't fit it in
		}
	}

	CBlob@ carryblob = this.getCarriedBlob();
	if (carryblob !is null && carryblob.getName() == "crate")
	{
		if (crateTake(carryblob, blob))
		{
			return;
		}
	}
}
