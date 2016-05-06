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
		For now check if the first three lines exist, if they don't this is a custom bio
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
			&& IsRandomBackground(RemainingBackground);
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

// compares background against the possible random backgrounds
// why did I have to make custom characters that matched the rest of the format...
static function bool IsRandomBackground(string Background)
{
	return true;
}