script "autoVolcano.ash"

/*******************************************************
*			USER DEFINED VARIABLES START
/*******************************************************/
location[string] adventureQuests = $strings[glass ceiling fragments, Mr. Cheeng's 'stache, Lavalos core, Mr. Choch's bone, fused fuse, half-melted hula girl, Pener's crisps, signed deuce, the tongue of Smimmons, Raul's guitar pick, The One Mood Ring, Saturday Night thermometer];
int maxExpenditure = 15000; // The most amount of meat you want spent
/*******************************************************
*			USER DEFINED VARIABLES END
*		PLEASE DO NOT MODIFY VARIABLES BELOW
/*******************************************************/
location[string] noAdventures = $strings[New Age healing crystal, superduperheated metal, gooey lava globs, SMOOCH bracers, SMOOCH bottlecap, smooth velvet bra]; // Order doesn't matter

string bunker = "place.php?whichplace=airport_hot&action=airport4_questhub";
string first; string second; string third; // Order of quests at bunker

// Assign locations to quests
foreach quest in $strings[Mr. Cheeng's 'stache, Glass ceiling fragments, Fused fuse]
	adventureQuests[quest] = $location[LavaCo™ Lamp Factory];
foreach quest in $strings[Mr. Choch's bone, Half-melted hula girl]
	adventureQuests[quest] = $location[The Velvet / Gold Mine];
foreach quest in $strings[Pener's crisps, Signed deuce, The tongue of Smimmons, Raul's guitar pick]
	adventureQuests[quest] = $location[The SMOOCH Army HQ];
foreach quest in $strings[Lavalos core, The One Mood Ring]
	adventureQuests[quest] = $location[The Bubblin' Caldera];

/*******************************************************
*					cost()
*	Returns the cost of the specified item.
/*******************************************************/
int cost(string it)
{
	int qty = 1;
	if (it == $string[smooth velvet bra])
		qty = 3;
	if (it == $string[New Age healing crystal] || it == $string[gooey lava globs])
		qty = 5;
	if (it == $string[SMOOCH bracers])
	{
		it = $string[Superheated metal];
		qty = 15;
	}
	return (mall_price(it.to_item()) * qty);
}

/*******************************************************
*					cost()
*	Returns the choice number of the specified quest.
/*******************************************************/
int getChoice(string quest)
{
	if (quest == first)
		return 1;
	if (quest == second)
		return 2;
	if (quest == third)
		return 3;
	else
		return 0;
}

void getItem(item it)
{
	// Figure out how many we need
	int qty = 1;
	if (it == $item[smooth velvet bra])
		qty = 3;
	if (it == $item[New Age healing crystal] || it == $item[gooey lava globs])
		qty = 5;
	if (it == $item[SMOOCH bracers])		// Special case
	{
		qty = 15 - (item_amount(it) * 5);
		it = $item[Superheated metal];
	}
	int qtyNeeded = qty - item_amount(it);
	// Get item
	if (noAdventures contains it.to_string() && qtyNeeded > 0 && cost(it) < maxExpenditure)
		cli_execute("buy " + qty + " " + it);
	if (it == $item[Superheated metal])
		cli_execute("make " + qtyNeeded/5 + " SMOOCH bracers");
}

/*******************************************************
*					pickQuest()
*	Returns the name of the best quest to do, with a
*	preference to quests that can be completed from 
*	the mall.
/*******************************************************/
string pickQuest()
{
	string best;  // For quest processing
	// Figure out what the quests are
	matcher mission = create_matcher("\\b(New Age healing crystal|superduperheated metal|gooey lava globs|SMOOCH bracers|SMOOCH bottlecap|smooth velvet bra|glass ceiling fragments|Mr. Cheeng's 'stache|Lavalos core|Saturday Night thermometer|Mr. Choch's bone|fused fuse|half-melted hula girl|Pener's crisps|signed deuce|the tongue of Smimmons|Raul's guitar pick|The One Mood Ring)(?=\">)",visit_url(bunker));
	while (find(mission))
	{
		if (first == "")
			first = (group(mission));
		else if (second == "")
			second = (group(mission));
		else if (third == "")
			third = (group(mission));
	}
	// Figure out which quest we want
	foreach q in noAdventures
	{
		if ((first == q || second == q || third == q) && best == "")
			best = q;
		else if ((first == q || second == q || third == q) && (cost(best) > cost(q)))
			best = q;
	}
	foreach q in adventureQuests
	{
		if ((first == q || second == q || third == q) && best == "")
			best = q;
	}
	return best;
}

void main()
{
	string quest = pickQuest();
	getItem(quest.to_item());
	run_choice(getChoice(quest));
}