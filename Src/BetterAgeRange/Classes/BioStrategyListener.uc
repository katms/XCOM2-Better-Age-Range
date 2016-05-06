// temporary screen listener for testing/log statements

class BioStrategyListener extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local array<XComGameState_Unit> Soldiers;
	local XComGameState_Unit Unit;
	local XComGameState_HeadquartersXCom XHQ;
	local bool result;

	XHQ = `XCOMHQ;
	Soldiers = XHQ.GetSoldiers();
	`log("----BioParser calls----");
	foreach Soldiers(Unit)
	{
		result = class'BioParser'.static.HasRandomBio(Unit);
		`log(Unit.GetFullName()@result);
	}
}


defaultproperties
{
	ScreenClass = UIAvengerHUD;
}