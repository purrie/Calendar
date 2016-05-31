#include "Defines.lsl"

default
{
	touch_end(integer num_detected)
	{
		key k = llDetectedKey(0);
		if(k != llGetOwner())
			return;
		llDialog(k, "Use your calendar HUD to customize frame texture", [], CLDR_CHANNEL);
		state ApplySkin;
	}
	
}
state ApplySkin
{
	state_entry()
	{
		llListen(CLDR_CHANNEL, "", NULL_KEY, "");
		llSetTimerEvent(60);
	}
	state_exit()
	{
		llSetTimerEvent(0);
	}
	listen(integer channel, string name, key id, string message)
	{
		list commands = llParseStringKeepNulls(message, [CMD_SEPARATOR], []);
		switch(llList2String(commands, 0))
		{
			case CMD_DONE:
				llDialog(llGetOwner(), "Texture set", [], CLDR_CHANNEL);
				state default;
				break;
			case CMD_TEXTURE:
				string texture = llList2String(commands, 1);
				vector repeats = (vector)llList2String(commands, 2);
				vector offsets = (vector)llList2String(commands, 3);
				float rotation_in_radians = (float)llList2String(commands, 4);
				llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_TEXTURE, ALL_SIDES, texture, repeats, offsets, rotation_in_radians]);
				llSetTimerEvent(60);
				break;
			default:
				break;
		}
	}
	timer()
	{
		llDialog(llGetOwner(), "Texture applier expired, click on calendar frame again to customize the texture", [], CLDR_CHANNEL);
		state default;
	}
}