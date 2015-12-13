script "autoVolcano.ash"

string[location] outfits;		// Leave this alone
string[location] fam;			// Leave this alone
string[location] autoattack;	// Leave this alone
string[location] mood;			// Leave this alone
/*******************************************************
*			USER DEFINED VARIABLES START
/*******************************************************/
/*******************************************************
*	Quest priority order. Rearrange to your preference.
*	Leave "Saturday Night thermometer" last, as there is
*	no functionality to retrieve it nor will any be added.
/*******************************************************/
boolean[string] adventureQuests = $strings[fused fuse, glass ceiling fragments, Mr. Cheeng's 'stache, Lavalos core, Mr. Choch's bone, half-melted hula girl, Pener's crisps, signed deuce, the tongue of Smimmons, Raul's guitar pick, The One Mood Ring, Saturday Night thermometer];
/*******************************************************
*		Toggle Variables
*
*	- maxExpenditure: The script will avoid spending 
*	meat above this level or turning in items worth
*	above this level.
*
*	- dontAdventure: When set to TRUE, the script will not
*	adventure in order to acquire items if no mall-able
*	quests are available. Change to FALSE to allow the 
*	script to adventure.
*
*	- getDiscoCoin: When set to TRUE the script will 
*	attempt to equip six smooth velvet items and get
*	a volcoino from the disco tower.
/*******************************************************/
int maxExpenditure = 15000;
boolean dontAdventure = TRUE;
boolean getDiscoCoin = FALSE;
/*******************************************************
*			Outfit, familiar, and autoattacks
*	Enter the names of your outfits auto attacks,
*	and familiars.
*
*	- Outfit: the name of the outfit to use for that quest.
*	If left blank, only necessary equipment will be equipped.
*	
*	- AutoAttack: for user created combat macros. 
*	If left blank, it will default to mafia's standard behavior.
*
*	- Familiar: the proper/official name of the familiar to use.
*	If left blank, your familiar will not be changed.
*
*	- Mood: the name of the mood you want to use.
*	If left blank, your mood will not be changed.
/*******************************************************/
outfits[$location[LavaCo&trade; Lamp Factory]]		= "";
outfits[$location[The Velvet / Gold Mine]]			= "";
outfits[$location[The SMOOCH Army HQ]]				= "";
outfits[$location[The Bubblin' Caldera]]			= "";

fam[$location[LavaCo&trade; Lamp Factory]]			= "";
fam[$location[The Velvet / Gold Mine]]				= "";
fam[$location[The SMOOCH Army HQ]]					= "";
fam[$location[The Bubblin' Caldera]]				= "";

autoattack[$location[LavaCo&trade; Lamp Factory]]	= "";
autoattack[$location[The Velvet / Gold Mine]]		= "";
autoattack[$location[The SMOOCH Army HQ]]			= "";
autoattack[$location[The Bubblin' Caldera]]			= "";

mood[$location[LavaCo&trade; Lamp Factory]]			= "";
mood[$location[The Velvet / Gold Mine]]				= "";
mood[$location[The SMOOCH Army HQ]]					= "";
mood[$location[The Bubblin' Caldera]]				= "";

/*******************************************************
*			USER DEFINED VARIABLES END
*		PLEASE DO NOT MODIFY VARIABLES BELOW
/*******************************************************/
boolean[string] noAdventures = $strings[New Age healing crystal, superduperheated metal, gooey lava globs, SMOOCH bracers, SMOOCH bottlecap, smooth velvet bra]; // Order doesn't matter

string bunker = "place.php?whichplace=airport_hot&action=airport4_questhub";
string first; string second; string third; // Order of quests at bunker
item[slot] equipment;	// For tower coin

/*******************************************************
*					saveSetup()
*	Saves your equipment to restore later.
/*******************************************************/
void saveSetup()
{
	foreach s in $slots[]
		equipment[s] = equipped_item(s);
}

/*******************************************************
*					restoreState()
*	Restores your equipment to what it was earlier.
/*******************************************************/
void restoreState()
{
	foreach s in $slots[]
	{
		if (equipped_item(s) != equipment[s])
			equip(s,equipment[s]);
	}
}

/*******************************************************
*					restoreState()
*	Equips smooth velvet items then grabs a Volcoino.
/*******************************************************/
void getTowerCoin()
{
	saveSetup();
	foreach it in $items[smooth velvet pocket square, smooth velvet socks, smooth velvet hat, smooth velvet shirt, smooth velvet hanky, smooth velvet pants]
	{
		if (item_amount(it) == 0)
		{
			print("You're missing a required item to get a volcoino from the tower.","red");
			restoreState();
			return;
		}
		// Need them all in different slots
		if (it == $item[smooth velvet hanky])
			equip($slot[acc1],it);
		else if (it == $item[smooth velvet socks])
			equip($slot[acc2],it);
		else if (it == $item[smooth velvet pocket square])
			equip($slot[acc3],it);
		else
			equip(it);
	}
	visit_url("place.php?whichplace=airport_hot&action=airport4_zone1");
	run_choice(7);
	restoreState();
}

/*******************************************************
*					changeSetup()
*	Changes familiar, outfit, mood and autoattack for
*	quest, based on user defined variables.
/*******************************************************/
void changeSetup(location loc)
{
	if (outfits[loc] != "")
		cli_execute("outfit " + outfits[loc]);
	if (fam[loc] != "")
		cli_execute("familiar " + fam[loc]);
	if (autoattack[loc] != "")
		cli_execute("autoattack " + autoattack[loc]);
	if (mood[loc] != "")
		cli_execute("mood " + mood[loc]);
}

/*******************************************************
*					getLocation()
*	Returns the location needed to adventure in to 
*	finish the Volcano quest.
/*******************************************************/
location getLocation(string goal)
{
	location loc;
	if (goal == "Mr. Cheeng's 'stache" || goal == "glass ceiling fragments" || goal == "fused fuse")
		loc = $location[LavaCo&trade; Lamp Factory];
	if (goal == "Mr. Choch's bone" || goal == "half-melted hula girl")
		loc = $location[The Velvet / Gold Mine];
	if (goal == "Pener's crisps" || goal == "signed deuce" || goal == "the tongue of Smimmons" || goal == "Raul's guitar pick")
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

/*******************************************************
*					setNC()
*	Changes Mafia's Non-Combat choice for the correct
*	quest so as to ensure successful operation.
/*******************************************************/
void setNC(item quest)
{
	switch (quest)
	{
		case $item[fused fuse]:
			cli_execute("set choiceAdventure1091 = 7");
			break;
		case $item[glass ceiling fragments]:
			cli_execute("set choiceAdventure1096 = 2");
			break;
		case $item[Mr. Cheeng's 'stache]:
			cli_execute("set choiceAdventure1096 = 1");
			break;
		case $item[Lavalos core]:
			cli_execute("set choiceAdventure1097 = 2");
			break;
		case $item[Mr. Choch's bone]:
			cli_execute("set choiceAdventure1095 = 1");
			break;
		case $item[half-melted hula girl]:
			cli_execute("set choiceAdventure1095 = 2");
			break;
		case $item[Pener's crisps]:
			cli_execute("set choiceAdventure1094 = 3");
			break;
		case $item[signed deuce]:
			cli_execute("set choiceAdventure1094 = 4");
			break;
		case $item[the tongue of Smimmons]:
			cli_execute("set choiceAdventure1094 = 1");
			break;
		case $item[Raul's guitar pick]:
			cli_execute("set choiceAdventure1094 = 2");
			break;
		case $item[The One Mood Ring]:
			cli_execute("set choiceAdventure1097 = 1");
			break;
		default:
			print("Something might have gone wrong.");
			break;
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

/*******************************************************
*					getItem()
*	Acquires the requisite quantity of an item needed
*	for the Volcano quest.
/*******************************************************/
void getItem(item it)
{
	if (adventureQuests contains it.to_string() && !dontAdventure)
	{
		setNC(it);
		changeSetup(getLocation(it.to_string()));
		if (getLocation(it.to_string()) == $location[LavaCo&trade; Lamp Factory])
		{
			if (get_property("choiceAdventure1091") == "0")	// Safety check to avoid failure
				cli_execute("set choiceAdventure1091 = 7");
		}
		while (item_amount(it) < 1)
			adventure(1,getLocation(it.to_string()));
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

void main()
{
	if (getDiscoCoin)
		getTowerCoin();
	string quest = pickQuest();
	if (adventureQuests contains quest && dontAdventure)
	{
		print("No zero-adventure quests available today.","red");
		exit;
	}
	else if (cost(quest) > maxExpenditure)
	{
		print("The cost of today's quest exceeds your max expenditure setting.","red");
		exit;
	}
	getItem(quest.to_item());
	visit_url(bunker);
	run_choice(getChoice(quest));
}