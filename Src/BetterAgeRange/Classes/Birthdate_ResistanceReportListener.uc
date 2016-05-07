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
	local int idx;
	local XComGameState_Reward RewardState;
	local array<StateObjectReference> HQPersonnel, Rewards;

	ReportScreen = UIResistanceReport(Screen);

	if(none == ReportScreen)
	{
		return;
	}

	ResHQ = ReportScreen.RESHQ();
	numNewRecruits = ResHQ.GetRefillNumRecruits();

	// get the recruits added to the pool for this supply drop
	GenerateDoBForNumUnits(ResHQ.Recruits, numNewRecruits);

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
	GenerateDoBForNumUnits(HQPersonnel);
	// todo: refresh the Commodity descriptions at HQ so the updated backstory is shown
}

// assign new birthday for the first n units in UnitRefs
// if n = -1, do it for the whole array
function GenerateDoBForNumUnits(array<StateObjectReference> UnitRefs, optional int n = -1)
{
	local XComGameStateHistory History;
	local XComGameState_Unit Unit;
	local int idx;

	if(-1 == n)
	{
		n = UnitRefs.length;
	}

	History = `XCOMHISTORY;

	for(idx = 0; idx < n; ++idx)
	{
		Unit = XComGameState_Unit(History.GetGameStateForObjectID(UnitRefs[idx].ObjectID));
		if(none != Unit)
		{
			class'AssignNewBirthday'.static.CheckUnit(Unit);
		}
	}
}

defaultproperties
{
	// probably not famous enough that I have to worry about overrides yet
	ScreenClass = UIResistanceReport;
}