script "autoVolcano.ash"

/*******************************************************
*			USER DEFINED VARIABLES START
/*******************************************************/
boolean[string] adventureQuests = $strings[glass ceiling fragments, Mr. Cheeng's 'stache, Lavalos core, Mr. Choch's bone, fused fuse, half-melted hula girl, Pener's crisps, signed deuce, the tongue of Smimmons, Raul's guitar pick, The One Mood Ring, Saturday Night thermometer];
int maxExpenditure = 15000; // The most amount of meat you want spent
boolean useNoAdv = TRUE; // Change this if you're silly
/*******************************************************
*			USER DEFINED VARIABLES END
*		PLEASE DO NOT MODIFY VARIABLES BELOW
/*******************************************************/
boolean[string] noAdventures = $strings[New Age healing crystal, superduperheated metal, gooey lava globs, SMOOCH bracers, SMOOCH bottlecap, smooth velvet bra]; // Order doesn't matter

string bunker = "place.php?whichplace=airport_hot&action=airport4_questhub";
string first; string second; string third; // Order of quests at bunker

/*******************************************************
*					getLocation()
*	Returns the location needed to adventure in to 
*	finish the Volcano quest.
/*******************************************************/
location getLocation(string goal)
{
	location loc;
	if (goal == "Mr. Cheeng's 'stache" || goal == "Glass ceiling fragments" || goal == "Fused fuse")
		loc = $location[LavaCo&trade; Lamp Factory];
	if (goal == "Mr. Choch's bone" || goal == "Half-melted hula girl")
		loc = $location[The Velvet / Gold Mine];
	if (goal == "Pener's crisps" || goal == "Signed deuce" || goal == "The tongue of Smimmons" || goal == "Raul's guitar pick")
		loc = $location[The SMOOCH Army HQ];
	if (goal == "Lavalos core" || goal == "The One Mood Ring")
		loc = $location[The Bubblin' Caldera];
	return loc;
}

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
*					getChoice()
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

void setNC(string quest)
{
	switch (quest)
	{
		case "fused fuse":
			cli_execute("set choiceAdventure1091 = 7");
			break;
		case "glass ceiling fragments":
			cli_execute("set choiceAdventure1096 = 2");
			break;
		case "Mr. Cheeng's 'stache":
			cli_execute("set choiceAdventure1096 = 1");
			break;
		case "Lavalos core":
			cli_execute("set choiceAdventure1097 = 2");
			break;
		case "Mr. Choch's bone":
			cli_execute("set choiceAdventure1095 = 1");
			break;
		case "half-melted hula girl":
			cli_execute("set choiceAdventure1095 = 2");
			break;
		case "Pener's crisps":
			cli_execute("set choiceAdventure1094 = 3");
			break;
		case "signed deuce":
			cli_execute("set choiceAdventure1094 = 4");
			break;
		case "the tongue of Smimmons":
			cli_execute("set choiceAdventure1094 = 1");
			break;
		case "Raul's guitar pick":
			cli_execute("set choiceAdventure1094 = 2");
			break;
		case "The One Mood Ring":
			cli_execute("set choiceAdventure1097 = 1");
			break;
		default:
			print("Something might have gone wrong.");
			break;
	}
}

/*******************************************************
*					getItem()
*	Acquires the requisite quantity of an item needed
*	for the Volcano quest.
/*******************************************************/
void getItem(item it)
{
	if (adventureQuests contains it.to_string() && !useNoAdv)
	{
		while (item_amount(it) < 1)
			adventure(1,getLocation(it.to_string());
	}
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
	if (noAdventures contains it.to_string() && qtyNeeded > 0 && cost(it.to_string()) < maxExpenditure)
	{
		cli_execute("buy " + qty + " " + it);
		if (it == $item[Superheated metal])
			cli_execute("make " + qtyNeeded/5 + " SMOOCH bracers");
	}
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
	if (adventureQuests contains quest && useNoAdv)
	{
		print("No zero-adventure quests available today.");
		exit;
	}
	else if (cost(quest) > maxExpenditure)
	{
		print("The cost of today's quest exceeds your max expenditure setting.");
		exit;
	}
	getItem(quest.to_item());
	visit_url(bunker);
	run_choice(getChoice(quest));
}