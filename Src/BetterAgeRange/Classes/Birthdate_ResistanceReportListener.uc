// FILE: Birthdate_ResistanceReportListener.uc
//
// Hooks into UIResistanceReport to grab all the personnel generated on supply drops

class Birthdate_ResistanceReportListener extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local UIResistanceReport ReportScreen;
	local XComGameState_HeadquartersResistance ResHQ;
	local int numNewRecruits;

	ReportScreen = UIResistanceReport(Screen);

	if(none == ReportScreen)
	{
		return;
	}

	ResHQ = ReportScreen.RESHQ();
	numNewRecruits = ResHQ.GetRefillNumRecruits();

	// get the recruits added to the pool for this supply drop
	GenerateDoBForNumUnits(ResHQ.Recruits, numNewRecruits);
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