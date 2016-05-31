#include "Defines.lsl"

integer pageSize = 0;
integer pageOffset = 0;
list pageItems = [];
list blanks = [];
list textures = [];
integer nextButton = 0;
integer prevButton = 0;
integer picker = 0;

Setup()
{
	integer prims = llGetNumberOfPrims();
	
	while(prims > 0)
	{
		string dsc = llList2String(llGetLinkPrimitiveParams(prims, [PRIM_NAME]), 0);
		dsc = llToLower(dsc);
		switch(dsc)
		{
			case "next":
				nextButton = prims;
				break;
			case "previous":
				prevButton = prims;
				break;
			case "display":
				pageItems += prims;
				pageSize ++;
				break;
			case "picker":
				picker = prims;
				break;
			default:
				blanks += prims;
				break;
		}
		prims--;
	}
}
SetupTextures()
{
	pageOffset = 0;
	integer count = llGetInventoryNumber(INVENTORY_TEXTURE);
	while(count --> 0)
	{
		string name = llGetInventoryName(INVENTORY_TEXTURE, count);
		name = (string)llGetInventoryKey(name);
		if(Contains(textures, name) == FALSE)
			textures += name;
	}
	RefreshTextures();
}
RefreshTextures()
{
	integer start = pageSize * pageOffset;
	integer tcount = llGetListLength(textures);
	integer i = 0;
	for(; i < pageSize; ++i)
	{
		string tex = (string)NULL_KEY;
		if((start + i) < tcount)
			tex = llList2String(textures, start + i);
		llSetLinkPrimitiveParamsFast(llList2Integer(pageItems, i), [ PRIM_TEXTURE, ALL_SIDES, tex, <1,1,1>, ZERO_VECTOR, 0, PRIM_DESC, tex]);
	}
	
	// cleanup from accidents
	llSetLinkPrimitiveParamsFast(nextButton, [ PRIM_TEXTURE, ALL_SIDES, NULL_KEY, <1,1,1>, ZERO_VECTOR, 0]);
	llSetLinkPrimitiveParamsFast(prevButton, [ PRIM_TEXTURE, ALL_SIDES, NULL_KEY, <1,1,1>, ZERO_VECTOR, 0]);
	i = llGetListLength(blanks);
	while(i --> 0)
		llSetLinkPrimitiveParamsFast(llList2Integer(blanks, i), [ PRIM_TEXTURE, ALL_SIDES, NULL_KEY, <1,1,1>, ZERO_VECTOR, 0]);
}
integer Contains(list l, string str)
{
	integer i = llGetListLength(l);
	while(i --> 0)
	{
		if(llList2String(l, i) == str)
			return TRUE;
	}
	return FALSE;
}
PickTexture()
{
	list params = llGetLinkPrimitiveParams(picker, [PRIM_TEXTURE, 4]);
	string texture = llList2String(params, 0);
	if(((key)texture) == NULL_KEY)
		return;
	if(Contains(textures, texture) == FALSE)
	{
		textures += texture;
		params = llDeleteSubList(params, 0, 0);
		params = llListInsertList(params, [PRIM_TEXTURE, 4, (string)NULL_KEY], 0);
		llSetLinkPrimitiveParamsFast(picker, params);
		llOwnerSay("Received a texture");
	}
}
default
{
	state_entry()
	{
		Setup();
		SetupTextures();
	}
	touch_start(integer num)
	{
		integer button = llDetectedLinkNumber(0);
		integer lastPage = llGetListLength(textures);
		integer part = lastPage % pageSize;
		lastPage = (lastPage / pageSize);
		if(part)
			lastPage++;
		if(button == nextButton)
		{
			pageOffset ++;
			if(pageOffset >= lastPage)
				pageOffset = 0;
			RefreshTextures();
		}
		else if(button == prevButton)
		{
			pageOffset --;
			if(pageOffset < 0)
				pageOffset = lastPage - 1;
			
			RefreshTextures();
		}
		else
		{
			integer i = 0;
			for(; i < pageSize; ++i)
			{
				integer txtr = llList2Integer(pageItems, i);
				if(txtr == button)
				{
					string uuid = llList2String(llGetLinkPrimitiveParams(txtr, [PRIM_DESC]), 0);
					string command = CMD_TEXTURE + CMD_SEPARATOR + uuid + CMD_SEPARATOR;
					command += (string)<1,1,1> + CMD_SEPARATOR + (string)ZERO_VECTOR + CMD_SEPARATOR + (string)0.0;
					llWhisper(CLDR_CHANNEL, command);
				}
			}
		}
	}
	attach(key id)
	{
		if(id)
		{
		}
		else
		{
			llWhisper(CLDR_CHANNEL, CMD_DONE);
		}
	}
	changed(integer change)
	{
		if(change & CHANGED_INVENTORY)
		{
			SetupTextures();
		}
		else if(change & CHANGED_TEXTURE)
		{
			PickTexture();
			RefreshTextures();
		}
	}
}