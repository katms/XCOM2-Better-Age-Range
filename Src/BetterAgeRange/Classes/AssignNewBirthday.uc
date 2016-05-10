// FILE: AssignNewBirthday.uc
// 
// Handles overwriting the old bio

class AssignNewBirthday extends Object
	config(Birthdays);


struct BackgroundAllowedAges
{
	// the index of the generic background
	var int BackgroundIndex;

	// minimum possible age for this background
	// ...with some room for error since we're only comparing against the (starting) year
	var int Min;

	// maximum possible age
	var int Max;
};


var config int MIN_AGE;
var config int MAX_AGE;

// assume male and female backgrounds are the same but with the pronouns changed
var config array<BackgroundAllowedAges> SoldierAges;
var config array<BackgroundAllowedAges> EngineerAges;
var config array<BackgroundAllowedAges> ScientistAges;

// return the configured array for this character
static function array<BackgroundAllowedAges> GetConfiguredAges(XComGameState_Unit Unit)
{
	local array<BackgroundAllowedAges> EmptyArray;
	if(Unit.IsASoldier())
	{
		return default.SoldierAges;
	}
	else if(Unit.IsAnEngineer())
	{
		return default.EngineerAges;
	}
	else if(Unit.IsAScientist())
	{
		return default.ScientistAges;
	}
	else
	{
		EmptyArray.Length = 0;
		return EmptyArray;
	}
}

// assign new birthday for the first n units in UnitRefs
// if n = -1, do it for the whole array
static function GenerateDoBForNumUnits(array<StateObjectReference> UnitRefs, optional int n = -1)
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
			CheckUnit(Unit);
		}
	}
}


// checks if the Unit should be given a new birthdate
static function CheckUnit(XComGameState_Unit Unit)
{
	local int BackgroundIndex;
	if(class'BioParser'.static.HasRandomBio(Unit, BackgroundIndex))
	{
		`log(Unit.GetFullName());
		`log(Unit.GetBackground());
		class'AssignNewBirthday'.static.GiveNewDoB(Unit, -1, -1);
	}
}

static function GiveNewDoB(XComGameState_Unit Unit, int MinAge, int MaxAge)
{
	local string CountryOfOrigin, Backstory, OldBackground, NewDoB, NewBackground;

	OldBackground = Unit.GetBackground();
	CountryOfOrigin = class'BioParser'.static.GetCountryOfOrigin(OldBackground);
	Backstory = class'BioParser'.static.GetBackstory(OldBackground);

	NewDoB = GenerateDateOfBirth(MinAge, MaxAge);

	// reassemble the whole thing, based on Unit.GenerateBackground()
	NewBackground = CountryOfOrigin$"\n"$NewDoB$"\n\n"$Backstory;
	`log(NewBackground);
	Unit.SetBackground(NewBackground);
}

// copied from XComGameState_Unit::GenerateBackground() with some numbers changed
static function string GenerateDateOfBirth(int MinAge, int MaxAge)
{
	local XGParamTag LocTag;
	local TDateTime NewBirthday;
	local string DateOfBirth;

	// fallback
	if(-1 == MinAge)
	{
		MinAge = default.MIN_AGE;
	}
	if(-1 == MaxAge)
	{
		MaxAge = default.MAX_AGE;
	}

	LocTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));	

	NewBirthday.m_iMonth = Rand(12) + 1;
	NewBirthday.m_iDay = (NewBirthday.m_iMonth == 2 ? Rand(MinAge) : Rand(MaxAge)) + 1;

	// 16-20 has no overlap with the default 25-35 age range, so I can make sure it works
	NewBirthday.m_iYear = class'X2StrategyGameRulesetDataStructures'.default.START_YEAR - int(RandRange(16, 20));
	LocTag.StrValue0 = class'X2StrategyGameRulesetDataStructures'.static.GetDateString(NewBirthday);

	DateOfBirth = `XEXPAND.ExpandString(class'XLocalizedData'.default.DateOfBirthBackground);

	return DateOfBirth;
}