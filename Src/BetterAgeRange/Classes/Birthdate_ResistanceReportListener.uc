// FILE: Birthdate_ResistanceReportListener.uc
//
// Hooks into UIResistanceReport to grab all the personnel generated on supply drops

class Birthdate_ResistanceReportListener extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local UIResistanceReport ReportScreen;
	local XComGameState_HeadquartersResistance ResHQ;
	
	// recruit pool
	// the array of refs comes pre-made
	local int numNewRecruits;

	// HQ personnel
	local XComGameStateHistory History;
	local int idx, j;
	local XComGameState_Reward RewardState; // for both HQ and Black Market
	local array<StateObjectReference> HQPersonnel, Rewards;

	// Black Market personnel
	local XComGameState_BlackMarket BlackMarket;
	local array<StateObjectReference> BlackMarketGoods;

	ReportScreen = UIResistanceReport(Screen);

	if(none == ReportScreen)
	{
		return;
	}

	ResHQ = ReportScreen.RESHQ();
	numNewRecruits = ResHQ.GetRefillNumRecruits();

	// get the recruits added to the pool for this supply drop
	class'AssignNewBirthday'.static.GenerateDoBForNumUnits(ResHQ.Recruits, numNewRecruits);

	/** 
	get HQ personnel

	Personnel goods is limited to the subset that is new personnel,
	but they're still references to rewards instead of units
	So we need to get the reward game state to get the unit
	*/
	History = `XCOMHISTORY;
	Rewards = ResHQ.PersonnelGoods;
	for(idx = 0; idx < Rewards.length; ++idx)
	{
		RewardState = XComGameState_Reward(History.GetGameStateForObjectID(Rewards[idx].ObjectID));
		if(none != RewardState)
		{
			HQPersonnel.AddItem(RewardState.RewardObjectReference);
		}
	}
	class'AssignNewBirthday'.static.GenerateDoBForNumUnits(HQPersonnel);

	// refresh UI descriptions
	RefreshHQCommodityDescriptions();

	// get black market personnel
	BlackMarket = class'UIUtilities_Strategy'.static.GetBlackMarket();

	// not all ForSaleItems/RewardStates represent new personnel
	// but the easiest way to filter them is to forward everything
	// and let GenerateDoB() check like it already does
	for(j = 0; j < BlackMarket.ForSaleItems.length; ++j)
	{
		RewardState = XComGameState_Reward(History.GetGameStateForObjectID(
							BlackMarket.ForSaleItems[j].RewardRef.ObjectID));
		if(none != RewardState)
		{
			BlackMarketGoods.AddItem(RewardState.RewardObjectReference);
		}
	}

	class'AssignNewBirthday'.static.GenerateDoBForNumUnits(BlackMarketGoods);
	// don't update the description for these commodities
	// since the black market doesn't use personnel background for that
}

// find all HQ commodities that award a unit and refresh and description
function RefreshHQCommodityDescriptions()
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersResistance ResHQ;

	local array<Commodity> Commodities;
	local Commodity Item;
	local XComGameState_Reward RewardState;

	local XComGameState_Unit Unit;
	local int i;

	History = `XCOMHISTORY;

	ResHQ = class'UIUtilities_Strategy'.static.GetResistanceHQ();
	Commodities = ResHQ.ResistanceGoods;
	
	// can't use find() so iterate by index so I have it when I need it
	for(i = 0; i < Commodities.length; ++i)
	{
		Item = Commodities[i];
		RewardState = XComGameState_Reward(History.GetGameStateForObjectID(Item.RewardRef.ObjectID));
		if(none != RewardState)
		{
			// check if the reward is a unit
			Unit = XComGameState_Unit(History.GetGameStateForObjectID(RewardState.RewardObjectReference.ObjectID));
			if(none != Unit)
			{
				// write to Resistance HQ, not a copy
				ResHQ.ResistanceGoods[i].Desc = Unit.GetBackground();
			}
		}
	}
}

defaultproperties
{
	// probably not famous enough that I have to worry about overrides yet
	ScreenClass = UIResistanceReport;
}