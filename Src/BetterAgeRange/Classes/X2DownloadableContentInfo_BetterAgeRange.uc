//---------------------------------------------------------------------------------------
//  FILE:   XComDownloadableContentInfo_BetterAgeRange.uc                                    
//           
//	Use the X2DownloadableContentInfo class to specify unique mod behavior when the 
//  player creates a new campaign or loads a saved game.
//  
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_BetterAgeRange extends X2DownloadableContentInfo;

/// <summary>
/// This method is run if the player loads a saved game that was created prior to this DLC / Mod being installed, and allows the 
/// DLC / Mod to perform custom processing in response. This will only be called once the first time a player loads a save that was
/// create without the content installed. Subsequent saves will record that the content was installed.
/// </summary>
static event OnLoadedSavedGame()
{}

/// <summary>
/// Called when the player starts a new campaign while this DLC / Mod is installed
/// </summary>
static event InstallNewCampaign(XComGameState StartState)
{

	// check backgrounds of every crewmember and recruit at the start of a campaign
	local XComGameState_HeadquartersXCom XHQ;
	local XComGameState_HeadquartersResistance ResHQ;

	// really? I can't call find() on a return value?
	local array<string> DLCNames;

	XHQ = `XCOMHQ;
	ResHQ = class'UIUtilities_Strategy'.static.GetResistanceHQ();

	// in theory we only need to do this for soldiers
	// since everyone else's background is only ever visible from Resistance HQ before they're bought
	// but the game doesn't start with any non-soldier crew
	class'AssignNewBirthday'.static.GenerateDoBForNumUnits(XHQ.Crew);

	class'AssignNewBirthday'.static.GenerateDoBForNumUnits(ResHQ.Recruits);
	

	// special handling for Resistance Warrior veteran

	// check the DLC is installed
	DLCNames = class'Helpers'.static.GetInstalledDLCNames();
	if(INDEX_NONE != DLCNames.find("XCom_DLC_Day0"))
	{
		HandleOldWarVeteran();
	}
}

// since I can't check against the localized bio, find the first extra solider wearing the DLC armor and assume it's them
static function HandleOldWarVeteran()
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom XHQ;

	local XComGameState_Unit Unit;
	local XComGameState_Item Armor;
	local int i;

	local BackgroundAllowedAges Range;

	History = `XCOMHISTORY;
	XHQ = class'UIUtilities_Strategy'.static.GetXComHQ();

	// start at NUM_STARTING_SOLDIERS+
	// since the veteran is added after those are created
	for(i = class'XGTacticalGameCore'.default.NUM_STARTING_SOLDIERS; i < XHQ.Crew.Length; ++i)
	{
		Unit = XComGameState_Unit(History.GetGameStateForObjectID(XHQ.Crew[i].ObjectID));
		if(none == Unit || !Unit.IsSoldier())
		{
			continue;
		}

		// check for DLC armor
		Armor = Unit.GetItemInSlot(eInvSlot_Armor);
		if(none != Armor && 'KevlarArmor_DLC_Day0' == Armor.GetMyTemplate().DataName)
		{
			Range = class'AssignNewBirthday'.default.OldWarVeteran;
			class'AssignNewBirthday'.static.GiveNewDoB(Unit, Range.Min, Range.Max);
			return;
		}
	}
}