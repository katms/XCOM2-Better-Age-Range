// FILE: BioParser.uc
// 
// Helper methods for parsing a soldier's biography.

class BioParser extends Object;

// returns true if Background matches the format of a randomly-generated bio
static function bool IsRandomBio(const string Background)
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

	QuoteLog("Background", Background);

	RemainingBackground = Background;

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

	return true;
}

static function QuoteLog(const string tag, const string output)
{
	`log(tag@"'"$output$"'");
}