// FILE: Birthdate_MissionRewardsListener.uc
//
// Hook for personnel that are generated as mission rewards

class Birthdate_MissionRewardsListener extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local UIRewardsRecap RewardScreen;
	local XComGameStateHistory History;
	local XComGameState_MissionSite Mission;
	local XComGameState_Reward RewardState;
	local array<StateObjectReference> Rewards;
	local int i;
	//local X2RewardTemplate RewardTemplate;
	local XComGameState_Unit Unit;

	RewardScreen = UIRewardsRecap(Screen);
	if(none == RewardScreen)
	{
		return;
	}
	History = `XCOMHISTORY;
	Mission = RewardScreen.GetMission();
	Rewards = Mission.Rewards;

	`log("logging mission rewards:"@Rewards.length);
	for(i = 0; i < Rewards.Length; ++i)
	{
		RewardState = XComGameState_Reward(History.GetGameStateForObjectID(Rewards[i].ObjectID));
		if(none != RewardState)
		{
			`log(RewardState.GetMyTemplateName());
			Unit = XComGameState_Unit(History.GetGameStateForObjectID(RewardState.RewardObjectReference.ObjectID));
			if(none != Unit)
			{
				`log("Awarded unit"@Unit.GetFullName());
			}
			if('Reward_SoldierCouncil' != RewardState.GetMyTemplateName())
			{
				`log("Not a council soldier");
			}
		}
		else
		{
			`log("Not a reward state");
		}
	}
}


defaultproperties
{
	ScreenClass = UIRewardsRecap;
}