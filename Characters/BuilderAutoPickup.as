#define SERVER_ONLY
#include "GunCommon.as";
#include "CratePickupCommon.as"

void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 12;
	this.getCurrentScript().removeIfTag = "dead";
}

void Take(CBlob@ this, CBlob@ blob)
{
	const string blobName = blob.getName();

	if (
		blobName == "mat_gold" && pickupCriteria(this, blob, 50) ||
		blobName == "mat_stone" ||
		blobName == "mat_wood"
	) {
		if ((blob.getDamageOwnerPlayer() !is this.getPlayer()) || getGameTime() > blob.get_u32("autopick time"))
		{
			if (this.server_PutInInventory(blob))
			{
				return;
			}
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

bool pickupCriteria(CBlob@ this, CBlob@ blob, uint16 quantity)
{
	return blob.getQuantity() >= quantity || this.hasBlob(blob.getName(), 1);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null || blob.getShape().vellen > 1.0f)
	{
		return;
	}

	Take(this, blob);
}

void onTick(CBlob@ this)
{
	CBlob@[] overlapping;

	if (this.getOverlapping(@overlapping))
	{
		for (uint i = 0; i < overlapping.length; i++)
		{
			CBlob@ blob = overlapping[i];
			{
				if (blob.getShape().vellen > 1.0f)
				{
					continue;
				}

				Take(this, blob);
			}
		}
	}
}

// make ignore collision time a lot longer for auto-pickup stuff
void IgnoreCollisionLonger(CBlob@ this, CBlob@ blob)
{
	if (this.hasTag("dead"))
	{
		return;
	}

	const string blobName = blob.getName();

	if (blobName == "mat_gold" || blobName == "mat_stone" ||
	        blobName == "mat_wood" || blobName == "grain")
	{
		blob.set_u32("autopick time", getGameTime() +  getTicksASecond() * 7);
		blob.SetDamageOwnerPlayer(this.getPlayer());
	}
}


void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	IgnoreCollisionLonger(this, detached);
}

void onRemoveFromInventory(CBlob@ this, CBlob@ blob)
{
	IgnoreCollisionLonger(this, blob);
}
