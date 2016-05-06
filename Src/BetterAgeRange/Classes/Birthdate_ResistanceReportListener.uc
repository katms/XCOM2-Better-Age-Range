// FILE: Birthdate_ResistanceReportListener.uc
//
// Hooks into UIResistanceReport to grab all the personnel generated on supply drops

class Birthdate_ResistanceReportListener extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local UIResistanceReport ReportScreen;
	
	ReportScreen = UIResistanceReport(Screen);

	if(none == ReportScreen)
	{
		return;
	}
	GenerateDoBForNewRecruits(ReportScreen.RESHQ());

}

function GenerateDoBForNewRecruits(XComGameState_HeadquartersResistance ResHQ)
{
	local XComGameStateHistory History;
	local array<StateObjectReference> RecruitPool;
	local XComGameState_Unit Unit;
	local int numNewRecruits, i;

	History = `XCOMHISTORY;
	RecruitPool = ResHQ.Recruits;
	numNewRecruits = ResHQ.GetRefillNumRecruits();

	// get the recruits added to the pool for this supply drop
	for(i = 0; i < numNewRecruits; ++i)
	{
		Unit = XComGameState_Unit(History.GetGameStateForObjectID(RecruitPool[i].ObjectID));
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