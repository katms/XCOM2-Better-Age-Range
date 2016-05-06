// FILE: AssignNewBirthday.uc
// 
// Handles overwriting the old bio

class AssignNewBirthday extends Object;

// checks if the Unit should be given a new birthdate
static function CheckUnit(XComGameState_Unit Unit)
{
	if(class'BioParser'.static.HasRandomBio(Unit))
	{
		`log(Unit.GetFullName());
		`log(Unit.GetBackground());
		class'AssignNewBirthday'.static.GiveNewDoB(Unit);
	}
}

static function GiveNewDoB(XComGameState_Unit Unit)
{
	local string CountryOfOrigin, Backstory, OldBackground, NewDoB, NewBackground;

	OldBackground = Unit.GetBackground();
	CountryOfOrigin = class'BioParser'.static.GetCountryOfOrigin(OldBackground);
	Backstory = class'BioParser'.static.GetBackstory(OldBackground);

	NewDoB = GenerateDateOfBirth();

	// reassemble the whole thing, based on Unit.GenerateBackground()
	NewBackground = CountryOfOrigin$"\n"$NewDoB$"\n\n"$Backstory;
	`log(NewBackground);
	Unit.SetBackground(NewBackground);
}

// copied from XComGameState_Unit::GenerateBackground() with some numbers changed
static function string GenerateDateOfBirth()
{
	local XGParamTag LocTag;
	local TDateTime NewBirthday;
	local string DateOfBirth;

	LocTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));	

	NewBirthday.m_iMonth = Rand(12) + 1;
	NewBirthday.m_iDay = (NewBirthday.m_iMonth == 2 ? Rand(27) : Rand(30)) + 1;

	// 16-20 has no overlap with the default 25-35 age range, so I can make sure it works
	NewBirthday.m_iYear = class'X2StrategyGameRulesetDataStructures'.default.START_YEAR - int(RandRange(16, 20));
	LocTag.StrValue0 = class'X2StrategyGameRulesetDataStructures'.static.GetDateString(NewBirthday);

	DateOfBirth = `XEXPAND.ExpandString(class'XLocalizedData'.default.DateOfBirthBackground);

	return DateOfBirth;
}