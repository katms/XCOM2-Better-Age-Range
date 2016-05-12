// FILE: Birthdate_NewSoldierFromPOIListener.uc
//
// Listener for completing points of interest that award 1+ soldiers

class Birthdate_NewSoldierFromPOIListener extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local UIAlert Alert;
	local XComGameStateHistory History;
	local XComGameState_PointOfInterest POIState;

	local XComGameState_Reward RewardState;

	Alert = UIAlert(Screen);

	if(none == Alert)
	{
		return;
	}

	// it doesn't like an equality comparison here?
	switch(Alert.eAlert)
	{
		case eAlert_ScanComplete:
			`log("Complete POI");
			History = `XCOMHISTORY;
			POIState = XComGameState_PointOfInterest(History.GetGameStateForObjectID(Alert.POIRef.ObjectID));
			`log(POIState.RewardRefs.length);
			if(POIState.RewardRefs.length > 0)
			{
				RewardState = XComGameState_Reward(History.GetGameStateForObjectID(POIState.RewardRefs[0].ObjectID));
				`log(RewardState);
			}
			// rewardrefs only gets cleared out when refilled I think
			// but what about the rewards they refer to
			// template.rewardtypes()
			// 
			break;
		default:
			`log(Alert.eAlert);
	}
}


defaultproperties
{
	ScreenClass = UIAlert;
}