// FILE: BioParser.uc
// 
// Helper methods for parsing a soldier's biography.

class BioParser extends Object;

// returns true if Background matches the format of a randomly-generated bio
static function bool HasRandomBio(XComGameState_Unit Unit)
{
	/*
		All randomly-generated backgrounds follow the same format:
		(in English)
		-
		Country of Origin: [Country]
		Date of Birth: [Date]

		[Character Bio]
		-
		check for the first three lines
		if they don't exist, or don't match the expected format, this is a custom bio
		check if the rest of the bio matches a random background for this character
	*/
	local string CountryOfOrigin, DateOfBirth, EmptyString, RemainingBackground;
	local int i; // index of the next newline

	RemainingBackground = Unit.GetBackground();

	QuoteLog("Background", RemainingBackground);

	

	// get first line
	i = InStr(RemainingBackground, "\n");
	if(INDEX_NONE == i)
	{
		return false;
	}

	CountryOfOrigin = Left(RemainingBackground, i);
	QuoteLog("Country",CountryOfOrigin);

	// drop up to the \n
	RemainingBackground = Split(RemainingBackground, "\n", true);
	
	i = InStr(RemainingBackground, "\n");
	
	// no second line
	if(INDEX_NONE == i)
	{
		return false;
	}

	DateOfBirth = Left(RemainingBackground, i);
	QuoteLog("DoB",DateOfBirth);

	RemainingBackground = Split(RemainingBackground, "\n", true);

	i = InStr(RemainingBackground, "\n");

	// no third line
	if(INDEX_NONE == i)
	{
		return false;
	}

	EmptyString = Left(RemainingBackground, i);
	QuoteLog("Newline",EmptyString);

	RemainingBackground = Split(RemainingBackground, "\n", true);
	QuoteLog("Bio", RemainingBackground);

	// check that each line actually matched the expected format for each of them
	// mainly by checking if they contain the localized labels

	return 
			("" == EmptyString) // fastest check

				// since the expected country of origin is known we could check further but I don't see the point
			&& (INDEX_NONE != InStr(CountryOfOrigin, GetLabel(class'XLocalizedData'.default.CountryBackground)))

				// I have no idea how GetDateString() works
				// I want to support all localizations if possible
				// so this doesn't get parsed any further either
			&& (INDEX_NONE != InStr(DateOfBirth, GetLabel(class'XLocalizedData'.default.DateOfBirthBackground)))

				// if the bio matches a random background
			&& IsRandomBackground(Unit, RemainingBackground);
}

static function QuoteLog(const string tag, const string output)
{
	`log(tag@"'"$output$"'");
}

// strips <XGParam:StrValue0... etc> from localized strings
// I assume none of the localizations I'm using are intended to display <
static function string GetLabel(const string XGParamLoc)
{
	local int i;
	i = InStr(XGParamLoc, "<XGParam:");
	return (INDEX_NONE != i) ? Left(XGParamLoc, i) : XGParamLoc;
}

// grab the first line without much validation
static function string GetCountryOfOrigin(const string background)
{
	local int newline;
	
	newline = InStr(background, "\n");
	if(INDEX_NONE != newline)
	{
		return Left(background, newline);
	}
	else
	{
		return "";
	}
}

// grab the backstory sans header
static function string GetBackstory(const string background)
{
	local string Backstory;
	Backstory = background;
	Backstory = Split(Backstory, "\n", true);
	Backstory = Split(Backstory, "\n", true);
	Backstory = Split(Backstory, "\n", true);

	return Backstory;
}

// returns the array of all backgrounds for the unit's gender and career
static function array<string> GetAllBackgroundsForCharacter(XComGameState_Unit Unit)
{
	local X2CharacterTemplate CharTemplate;

	CharTemplate = Unit.GetMyTemplate(); // soldier, engineer, or scientist

	if(Unit.kAppearance.iGender == eGender_Male)
	{
		return CharTemplate.strCharacterBackgroundMale;
	}
	else
	{
		return CharTemplate.strCharacterBackgroundFemale;
	}
}


/**
	compares background against the possible random backgrounds
	why did I have to make custom characters that matched the rest of the format...

	* @param Unit			needed to get CountryName and first name
	* @param Background		Unit.GetBackground() minus the header, since we've already isolated that part
*/
static function bool IsRandomBackground(XComGameState_Unit Unit, string Background)
{
	local string CountryName, FirstName, GenericBackground;
	local array<string> AllBackgrounds;
	local int idx;
	
	// reverse-engineer the generic localized background (replace first name and country name)
	FirstName = Unit.GetFirstName();
	CountryName = Unit.GetCountryTemplate().DisplayNameWithArticleLower;

	GenericBackground = Repl(Background, CountryName, "<XGParam:StrValue0/!CountryName/>");
	GenericBackground = Repl(GenericBackground, FirstName, "<XGParam:StrValue1/!FirstName/>");

	QuoteLog("Generic background:", GenericBackground);

	// check against all possible backgrounds for this unit
	AllBackgrounds = GetAllBackgroundsForCharacter(Unit);

	idx = AllBackgrounds.find(GenericBackground);

	return idx != INDEX_NONE;
}