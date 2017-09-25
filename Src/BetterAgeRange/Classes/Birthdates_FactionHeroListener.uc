class Birthdates_FactionHeroListener extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local Object this;
	this = self;
	// faction recruit events don't give info on who was recruited, so use this instead
	`XEVENTMGR.RegisterForEvent(this, 'NewCrewNotification', OnFactionHeroRecruited, ELD_OnStateSubmitted);
}


function EventListenerReturn OnFactionHeroRecruited(Object EventData, Object EventSource, XComGameState GameState, name EventID, Object CallbackData)
{
	local XComGameState_Unit Hero;
	Hero = XComGameState_Unit(EventData);

	// we only want new crew that are faction heroes
	// and are not rejoining the crew after being captured and rescued

	// this doesn't catch LnA!Mox but he doesn't have a backstory anyway
	if(!Hero.IsResistanceHero() || Hero.bCaptured)
	{
		return ELR_NoInterrupt;
	}

	class'AssignNewBirthday'.static.CheckUnit(Hero);
	return ELR_NoInterrupt;
}

event OnRemoved(UIScreen Screen)
{
	local Object this;
	this = self;
	`XEVENTMGR.UnregisterFromAllEvents(this);	
}


defaultproperties
{
	ScreenClass=UIStrategyMap;
}