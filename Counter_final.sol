// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;


contract brbzbzRPG {
    // ==================== GAME STATE ====================
    
    uint256 private constant MAX_PLAYERS = 10000;
    uint256 private constant MAX_ITEMS = 1000;
    uint256 private constant MAX_MONSTERS = 500;
    uint256 private constant MAX_LOCATIONS = 200;
    uint256 private constant MAX_QUESTS = 300;
    uint256 private constant LOCATION_HOMETOWN = 1;
    uint256 private constant LOCATION_DARK_FOREST = 2;
    uint256 private constant LOCATION_MOUNTAIN_PASS = 3;
    uint256 private constant LOCATION_ANCIENT_RUINS = 4;
    uint256 private constant LOCATION_DRAGONS_LAIR = 5;
    
    // Game admin
    address public gameOwner;
    bool public gameActive = true;
    uint256 public gameFee = 0.01 ether;
    
    // Player data
    struct Player {
        string name;
        uint256 level;
        uint256 experience;
        uint256 health;
        uint256 maxHealth;
        uint256 mana;
        uint256 maxMana;
        uint256 strength;
        uint256 intelligence;
        uint256 dexterity;
        uint256 defense;
        uint256 gold;
        uint256 locationId;
        uint256 questId;
        bool isActive;
        uint256 lastAction;
        uint256[] inventory;
        uint256[] completedQuests;
        uint8 characterClass; // 0: Warrior, 1: Mage, 2: Rogue, 3: Cleric, 4: Paladin
    }
    
    // Item data
struct Item {
    string name;
    string description;
    uint8 itemType; // 0: Weapon, 1: Armor, 2: Potion, 3: Scroll, 4: Quest Item
    uint256 value;
    uint256 power;
    uint256 requiredLevel;
    bool tradeable;
    mapping(uint8 => uint256) attributeBonus; // Maps attribute ID to bonus value
}

// Maps attribute ID to bonus value    } 
    
    // Monster data
    struct Monster {
        string name;
        string description;
        uint256 health;
        uint256 damage;
        uint256 defense;
        uint256 experienceReward;
        uint256 goldReward;
        uint256[] possibleLoot;
        uint256[] lootChance; // Percentage chance (0-100) for each loot item
    }
    
    // Location data
    struct Location {
        string name;
        string description;
        uint256[] connectedLocations;
        uint256[] monsters;
        uint256[] npcs;
        bool isSafe;
        bool isDiscovered;
        uint256 requiredLevel;
    }


    struct LocationData {
        uint256 id;
        string name;
        string description;
        uint256[] connectedLocations;
        uint256[] monsters;
        uint256[] npcs;
        bool isSafe;
        bool isDiscovered;
        uint256 requiredLevel;
}
    
    // Quest data
    struct Quest {
        string name;
        string description;
        uint256 requiredLevel;
        uint256[] objectives; // Item IDs or monster IDs to collect/kill
        uint256[] objectiveCounts; // Number of each objective needed
        uint256[] rewards; // Item IDs as rewards
        uint256 goldReward;
        uint256 experienceReward;
        uint256 requiredQuestId; // Prerequisite quest, 0 if none
    }
    
    // NPC data
    struct NPC {
        string name;
        string description;
        uint256[] dialogues;
        uint256[] quests;
        bool isVendor;
        uint256[] itemsForSale;
        uint256[] itemPrices;
    }
    
    // Dialogue data
    struct Dialogue {
        string text;
        uint256[] responses;
    }
    
    // Game data storage
    mapping(address => Player) public players;
    address[] public playerAddresses;
    
    mapping(uint256 => Item) private items;
    uint256[] public itemIds;
    
    mapping(uint256 => Monster) public monsters;
    uint256[] public monsterIds;
    
    mapping(uint256 => Location) public locations;
    uint256[] public locationIds;
    
    mapping(uint256 => Quest) public quests;
    uint256[] public questIds;
    
    mapping(uint256 => NPC) public npcs;
    uint256[] public npcIds;
    
    mapping(uint256 => Dialogue) public dialogues;
    uint256[] public dialogueIds;
    
    // Game events
// Basic player events
event PlayerCreated(address indexed player, string name, uint8 characterClass);
event PlayerLevelUp(address indexed player, uint256 newLevel);
event PlayerDied(address indexed player);
event PlayerReborn(address indexed player, uint256 rebornLevel, uint256 retainedPower);
event PlayerNameChanged(address indexed player, string oldName, string newName);
event PlayerRested(address indexed player, uint256 healthRecovered, uint256 manaRecovered);
event PlayerStatIncreased(address indexed player, string statName, uint256 newValue);
event PlayerGuildJoined(address indexed player, uint256 indexed guildId, string guildName);
event PlayerGuildLeft(address indexed player, uint256 indexed guildId);

// Item related events
event ItemAcquired(address indexed player, uint256 itemId);
event ItemCrafted(address indexed player, uint256 newItemId);
event ItemSold(address indexed player, uint256 itemId, uint256 price);
event ItemPurchased(address indexed player, uint256 itemId, uint256 price);
event ItemEquipped(address indexed player, uint256 itemId, uint8 slot);
event ItemUnequipped(address indexed player, uint256 itemId, uint8 slot);
event ItemUpgraded(address indexed player, uint256 itemId, uint256 newLevel);
event ItemEnchanted(address indexed player, uint256 itemId, string enchantmentType);
event ItemBroken(address indexed player, uint256 itemId);
event ItemRepaired(address indexed player, uint256 itemId);
event ItemGifted(address indexed fromPlayer, address indexed toPlayer, uint256 itemId);
event ItemDestroyed(address indexed player, uint256 itemId);
event ItemSetCompleted(address indexed player, uint256 setId);

// Quest related events
event QuestStarted(address indexed player, uint256 questId);
event QuestCompleted(address indexed player, uint256 questId);
event QuestFailed(address indexed player, uint256 questId, string reason);
event QuestObjectiveCompleted(address indexed player, uint256 questId, uint256 objectiveId);
event QuestRewardClaimed(address indexed player, uint256 questId);
event QuestAbandoned(address indexed player, uint256 questId);
event QuestShared(address indexed fromPlayer, address indexed toPlayer, uint256 questId);
event QuestChainProgressed(address indexed player, uint256 questChainId, uint256 stage);

// Combat related events
event CombatResult(address indexed player, uint256 monsterId, bool playerWon);
event CriticalHit(address indexed player, uint256 targetId, uint256 damage);
event SpecialAbilityUsed(address indexed player, string abilityName, uint256 cooldownTime);
event MonsterDefeated(address indexed player, uint256 monsterId, uint256 experienceGained);
event BossSummoned(address indexed player, uint256 bossId, uint256 locationId);
event BossDefeated(address indexed player, uint256 bossId, uint256 rewardTier);
event PVPChallengeIssued(address indexed challenger, address indexed target);
event PVPResult(address indexed winner, address indexed loser, uint256 reputationChange);
event DungeonEntered(address indexed player, uint256 dungeonId);
event DungeonCompleted(address indexed player, uint256 dungeonId, uint256 timeTaken);

// World interaction events
event LocationDiscovered(address indexed player, uint256 locationId);
event TreasureFound(address indexed player, uint256 treasureId, uint256 locationId);
event ResourceGathered(address indexed player, uint256 resourceId, uint256 amount);
event ResourceRefined(address indexed player, uint256 resourceId, uint256 amount, uint256 productId);
event BuildingConstructed(address indexed player, uint256 buildingId, uint256 locationId);
event BuildingUpgraded(address indexed player, uint256 buildingId, uint256 newLevel);
event TerritoryControlled(address indexed player, uint256 territoryId);
event ConsolationPrize(address indexed player, uint256 treasureId, uint256 amount);


// Economy events
event CurrencyEarned(address indexed player, uint256 amount, string source);
event CurrencySpent(address indexed player, uint256 amount, string purpose);
event MarketItemListed(address indexed seller, uint256 itemId, uint256 price);
event MarketItemSold(address indexed seller, address indexed buyer, uint256 itemId, uint256 price);
event MarketItemDelisted(address indexed seller, uint256 itemId);
event AuctionCreated(address indexed creator, uint256 itemId, uint256 startingBid, uint256 endTime);
event AuctionBid(address indexed bidder, uint256 auctionId, uint256 bidAmount);
event AuctionCompleted(address indexed winner, uint256 auctionId, uint256 finalPrice);

// Social events
event FriendRequestSent(address indexed sender, address indexed recipient);
event FriendRequestAccepted(address indexed accepter, address indexed requester);
event GuildDisbanded(uint256 guildId, string guildName);
event GuildLevelUp(uint256 guildId, uint256 newLevel);
event AllianceFormed(uint256 guildId1, uint256 guildId2);
event PeaceDeclared(uint256 guildId1, uint256 guildId2);

// Achievement events
event AchievementUnlocked(address indexed player, uint256 achievementId);
event MilestoneReached(address indexed player, string milestoneName, uint256 value);
event LeaderboardPositionChanged(address indexed player, string leaderboardName, uint256 oldPosition, uint256 newPosition);
event SeasonRewardsDistributed(uint256 seasonId, address indexed player, uint256 rewardTier);
event TournamentStarted(uint256 tournamentId, string tournamentName);
event TournamentEnded(uint256 tournamentId, address indexed winner);

// System events
event GameParametersUpdated(string parameterName, string newValue);
event MaintenanceScheduled(uint256 startTime, uint256 duration);
event EmergencyShutdown(string reason);
event GameVersionUpdated(string newVersion);
event ContractUpgraded(address indexed oldContract, address indexed newContract);
event AdminActionPerformed(address indexed admin, string actionType, string details);
event RewardPoolFunded(uint256 amount, string purpose);
event RewardDistributed(address indexed recipient, uint256 amount, string reason);

    

    // ==================== CONSTRUCTOR ====================
    
constructor() {
    gameOwner = msg.sender;
    
    // Initialize game data
    initializeLocations();
    initializeItems();
    initializeMonsters();
    initializeQuests();
    initializeNPCs();
    initializeDialogues();
    
}

function initializeLocations() private {
    _createLocation(LOCATION_HOMETOWN, "Hometown", "A peaceful village where your adventure begins.", new uint256[](0), new uint256[](0), new uint256[](0), true, true, 1);
    _createLocation(LOCATION_DARK_FOREST, "Dark Forest", "A mysterious forest filled with dangers.", new uint256[](3), new uint256[](2), new uint256[](1), false, false, 2);
}

function initializeItems() private {
    _createBasicItem(1, "Wooden Sword", "A basic training sword.", 0, 10, 5, 1, true);
    _createBasicItem(2, "Leather Armor", "Basic protection for beginners.", 1, 15, 3, 1, true);
    _createBasicItem(3, "Health Potion", "Restores 50 health points.", 2, 5, 50, 1, true);
    _createBasicItem(4, "Mana Potion", "Restores 50 mana points.", 2, 5, 50, 1, true);
    _createBasicItem(5, "Iron Sword", "A sturdy iron sword.", 0, 50, 15, 3, true);
    _createBasicItem(6, "Chain Mail", "Decent protection for adventurers.", 1, 60, 10, 3, true);
    _createBasicItem(7, "Magic Staff", "A staff imbued with magical energy.", 0, 70, 20, 5, true);
    _createBasicItem(8, "Dragon Scale", "A scale from a mighty dragon.", 4, 500, 0, 10, true);
    _createBasicItem(9, "Ancient Relic", "A mysterious artifact of unknown power.", 4, 1000, 0, 12, true);
    _createBasicItem(10, "Enchanted Amulet", "Provides magical protection.", 1, 200, 15, 7, true);
}

function initializeMonsters() private {
    // Goblin
    uint256[] memory goblinDrops = new uint256[](2);
    goblinDrops[0] = 1;
    goblinDrops[1] = 3;
    uint256[] memory goblinDropChances = new uint256[](2);
    goblinDropChances[0] = 20;
    goblinDropChances[1] = 10;
    _createBasicMonster(1, "Goblin", "A small, mischievous creature.", 50, 10, 5, 20, 10, goblinDrops, goblinDropChances);
    
    // Wolf
    uint256[] memory wolfDrops = new uint256[](1);
    wolfDrops[0] = 3;
    uint256[] memory wolfDropChances = new uint256[](1);
    wolfDropChances[0] = 25;
    _createBasicMonster(2, "Wolf", "A fierce predator.", 70, 15, 8, 30, 15, wolfDrops, wolfDropChances);
    
    // Bandit
    uint256[] memory banditDrops = new uint256[](2);
    banditDrops[0] = 1;
    banditDrops[1] = 5;
    uint256[] memory banditDropChances = new uint256[](2);
    banditDropChances[0] = 15;
    banditDropChances[1] = 5;
    _createBasicMonster(3, "Bandit", "A ruthless outlaw.", 100, 20, 12, 50, 30, banditDrops, banditDropChances);
    
    // Troll
    uint256[] memory trollDrops = new uint256[](1);
    trollDrops[0] = 6;
    uint256[] memory trollDropChances = new uint256[](1);
    trollDropChances[0] = 30;
    _createBasicMonster(4, "Troll", "A large, regenerating monster.", 200, 30, 20, 100, 50, trollDrops, trollDropChances);
    
    // Skeleton Warrior
    uint256[] memory skeletonDrops = new uint256[](1);
    skeletonDrops[0] = 5;
    uint256[] memory skeletonDropChances = new uint256[](1);
    skeletonDropChances[0] = 25;
    _createBasicMonster(5, "Skeleton Warrior", "An undead fighter.", 150, 25, 15, 80, 40, skeletonDrops, skeletonDropChances);
    
    // Dark Mage
    uint256[] memory mageDrops = new uint256[](2);
    mageDrops[0] = 7;
    mageDrops[1] = 4;
    uint256[] memory mageDropChances = new uint256[](2);
    mageDropChances[0] = 20;
    mageDropChances[1] = 40;
    _createBasicMonster(6, "Dark Mage", "A practitioner of forbidden magic.", 120, 40, 10, 120, 60, mageDrops, mageDropChances);
    
    // Dragon
    uint256[] memory dragonDrops = new uint256[](2);
    dragonDrops[0] = 8;
    dragonDrops[1] = 10;
    uint256[] memory dragonDropChances = new uint256[](2);
    dragonDropChances[0] = 100;
    dragonDropChances[1] = 30;
    _createBasicMonster(10, "Dragon", "A mighty fire-breathing dragon.", 1000, 100, 50, 1000, 500, dragonDrops, dragonDropChances);
}

function initializeQuests() private {
    // Quest 1: Goblin Threat
    uint256[] memory quest1Monsters = new uint256[](1);
    quest1Monsters[0] = 1;
    uint256[] memory quest1Quantities = new uint256[](1);
    quest1Quantities[0] = 5;
    uint256[] memory quest1Rewards = new uint256[](1);
    quest1Rewards[0] = 3;
    _createBasicQuest(1, "Goblin Threat", "Clear the goblins threatening the village.", 1, quest1Monsters, quest1Quantities, quest1Rewards, 50, 100, 0);
    
    // Quest 2: Lost Heirloom
    uint256[] memory quest2Monsters = new uint256[](1);
    quest2Monsters[0] = 5;
    uint256[] memory quest2Quantities = new uint256[](1);
    quest2Quantities[0] = 1;
    uint256[] memory quest2Rewards = new uint256[](1);
    quest2Rewards[0] = 5;
    _createBasicQuest(2, "Lost Heirloom", "Find the mayor's stolen amulet.", 3, quest2Monsters, quest2Quantities, quest2Rewards, 100, 200, 1);
    
    // Quest 3: Dark Magic
    uint256[] memory quest3Monsters = new uint256[](1);
    quest3Monsters[0] = 6;
    uint256[] memory quest3Quantities = new uint256[](1);
    quest3Quantities[0] = 3;
    uint256[] memory quest3Rewards = new uint256[](1);
    quest3Rewards[0] = 7;
    _createBasicQuest(3, "Dark Magic", "Investigate the source of dark magic in the ruins.", 7, quest3Monsters, quest3Quantities, quest3Rewards, 200, 400, 2);
    
    // Quest 4: Dragon Slayer
    uint256[] memory quest4Monsters = new uint256[](1);
    quest4Monsters[0] = 10;
    uint256[] memory quest4Quantities = new uint256[](1);
    quest4Quantities[0] = 1;
    uint256[] memory quest4Rewards = new uint256[](2);
    quest4Rewards[0] = 8;
    quest4Rewards[1] = 9;
    _createBasicQuest(4, "Dragon Slayer", "Defeat the dragon terrorizing the kingdom.", 15, quest4Monsters, quest4Quantities, quest4Rewards, 1000, 2000, 3);
}

function initializeNPCs() private {
    // Village Elder
    uint256[] memory npc1Quests = new uint256[](2);
    npc1Quests[0] = 1;
    npc1Quests[1] = 2;
    uint256[] memory npc1Dialogues = new uint256[](1);
    npc1Dialogues[0] = 1;
    uint256[] memory npc1Items = new uint256[](4);
    uint256[] memory npc1Prices = new uint256[](4);
    npc1Items[0] = 10;
    npc1Items[1] = 15;
    npc1Items[2] = 5;
    npc1Items[3] = 5;
    npc1Prices[0] = 10;
    npc1Prices[1] = 15;
    npc1Prices[2] = 5;
    npc1Prices[3] = 5;
    _createBasicNPC(1, "Village Elder", "The wise leader of the village.", npc1Quests, npc1Dialogues, true, npc1Items, npc1Prices);
    
    // Blacksmith
    uint256[] memory npc2Quests = new uint256[](2);
    npc2Quests[0] = 3;
    npc2Quests[1] = 4;
    uint256[] memory npc2Dialogues = new uint256[](1);
    npc2Dialogues[0] = 2;
    uint256[] memory npc2Items = new uint256[](2);
    uint256[] memory npc2Prices = new uint256[](2);
    npc2Items[0] = 5;
    npc2Items[1] = 6;
    npc2Prices[0] = 50;
    npc2Prices[1] = 60;
    _createBasicNPC(2, "Blacksmith", "A skilled craftsman.", npc2Quests, npc2Dialogues, true, npc2Items, npc2Prices);
    
    // Mysterious Wizard
    uint256[] memory npc3Quests = new uint256[](2);
    npc3Quests[0] = 5;
    npc3Quests[1] = 6;
    uint256[] memory npc3Dialogues = new uint256[](1);
    npc3Dialogues[0] = 3;
    uint256[] memory npc3Items = new uint256[](2);
    uint256[] memory npc3Prices = new uint256[](2);
    npc3Items[0] = 7;
    npc3Items[1] = 4;
    npc3Prices[0] = 70;
    npc3Prices[1] = 5;
    _createBasicNPC(3, "Mysterious Wizard", "A powerful mage with cryptic knowledge.", npc3Quests, npc3Dialogues, true, npc3Items, npc3Prices);
    
    // King's Messenger
    uint256[] memory npc4Quests = new uint256[](1);
    npc4Quests[0] = 7;
    uint256[] memory npc4Dialogues = new uint256[](1);
    npc4Dialogues[0] = 4;
    uint256[] memory npc4Items = new uint256[](0);
    uint256[] memory npc4Prices = new uint256[](0);
    _createBasicNPC(4, "King's Messenger", "A royal envoy with an urgent request.", npc4Quests, npc4Dialogues, false, npc4Items, npc4Prices);
}

function initializeDialogues() private {
    // Dialogue 1
    uint256[] memory dialogue1Responses = new uint256[](1);
    dialogue1Responses[0] = 1;
    _createDialogue(1, "Welcome, adventurer! Our village needs your help with the goblin problem.", dialogue1Responses);
    
    // Dialogue 2
    uint256[] memory dialogue2Responses = new uint256[](0);
    _createDialogue(2, "Will you help us clear the goblins from the nearby forest?", dialogue2Responses);
    
    // Dialogue 3
    uint256[] memory dialogue3Responses = new uint256[](1);
    dialogue3Responses[0] = 3;
    _createDialogue(3, "I can craft better weapons if you bring me the right materials.", dialogue3Responses);
    
    // Dialogue 4
    uint256[] memory dialogue4Responses = new uint256[](0);
    _createDialogue(4, "Would you like to see what I have for sale?", dialogue4Responses);
    
    // Dialogue 5
    uint256[] memory dialogue5Responses = new uint256[](1);
    dialogue5Responses[0] = 6;
    _createDialogue(5, "The ancient magic is stirring. Dark times are ahead.", dialogue5Responses);
    
    // Dialogue 6
    uint256[] memory dialogue6Responses = new uint256[](0);
    _createDialogue(6, "Seek the ruins to the east, but be careful of what you might awaken.", dialogue6Responses);
    
    // Dialogue 7
    uint256[] memory dialogue7Responses = new uint256[](0);
    _createDialogue(7, "The king requests your presence. A dragon threatens the kingdom!", dialogue7Responses);
}

function createAdditionalItems() private {
    for (uint256 i = 11; i <= 200; i++) {
        _createBasicItem(
            i,
            string(abi.encodePacked("Item ", _toString(i))),
            string(abi.encodePacked("Description for item ", _toString(i))),
            uint8(i % 5),
            i * 10,
            i * 5,
            (i % 20) + 1,
            true
        );
    }
}

function createAdditionalMonsters() private {
    for (uint256 i = 11; i <= 100; i++) {
        uint256[] memory loot = new uint256[](2);
        loot[0] = (i % 20) + 1;
        loot[1] = ((i+5) % 20) + 1;
        
        uint256[] memory chances = new uint256[](2);
        chances[0] = 20 + (i % 30);
        chances[1] = 10 + (i % 20);
        
        _createBasicMonster(
            i,
            string(abi.encodePacked("Monster ", _toString(i))),
            string(abi.encodePacked("Description for monster ", _toString(i))),
            50 * i,
            10 * i,
            5 * i,
            20 * i,
            10 * i,
            loot,
            chances
        );
    }
}

function createAdditionalLocations() private {
    for (uint256 i = 6; i <= 50; i++) {
        uint256[] memory connections = new uint256[](2);
        connections[0] = (i % 5) + 1;
        connections[1] = ((i+2) % 5) + 1;
        
        uint256[] memory locMonsters = new uint256[](2);
        locMonsters[0] = (i % 10) + 1;
        locMonsters[1] = ((i+5) % 10) + 1;
        
        uint256[] memory locNpcs = new uint256[](1);
        locNpcs[0] = (i % 4) + 1;
        
        _createLocation(
            i,
            string(abi.encodePacked("Location ", _toString(i))),
            string(abi.encodePacked("Description for location ", _toString(i))),
            connections,
            locMonsters,
            locNpcs,
            i % 5 == 0, // Every 5th location is safe
            false,
            i % 20
        );
    }
}

function createAdditionalQuests() private {
    for (uint256 i = 5; i <= 50; i++) {
        uint256[] memory objectives = new uint256[](2);
        objectives[0] = (i % 10) + 1;
        objectives[1] = ((i+5) % 10) + 1;
        
        uint256[] memory counts = new uint256[](2);
        counts[0] = (i % 5) + 1;
        counts[1] = (i % 3) + 1;
        
        uint256[] memory rewards = new uint256[](1);
        rewards[0] = (i % 20) + 1;
        
        _createBasicQuest(
            i,
            string(abi.encodePacked("Quest ", _toString(i))),
            string(abi.encodePacked("Description for quest ", _toString(i))),
            i % 20,
            objectives,
            counts,
            rewards,
            i * 50,
            i * 100,
            i > 5 ? i - 1 : 0
        );
    }
}


    
    // ==================== MODIFIERS ====================
    
    modifier onlyOwner() {
        require(msg.sender == gameOwner, "Only the game owner can call this function");
        _;
    }
    
    modifier gameIsActive() {
        require(gameActive, "Game is currently paused");
        _;
    }
    
    modifier playerExists() {
        require(players[msg.sender].isActive, "Player does not exist");
        _;
    }
    
    modifier sufficientFee() {
        require(msg.value >= gameFee, "Insufficient fee");
        _;
    }
    
    modifier playerAlive() {
        require(players[msg.sender].health > 0, "Player is dead");
        _;
    }
    
    // ==================== PLAYER FUNCTIONS ====================
    
    /**
     * @dev Create a new player character
     * @param name The name of the character
     * @param characterClass The class of the character (0-4)
     */
/**
 * @dev Creates a new character for the player
 * @param name The character's name
 * @param characterClass The class of the character (0-4)
 */
function createCharacter(string memory name, uint8 characterClass) external payable gameIsActive sufficientFee {
    // Validate inputs
    validateNewCharacter(name, characterClass);
    
    // Calculate base stats for the character
    (uint256 strength, uint256 intelligence, uint256 dexterity, uint256 defense, uint256 mana) = 
        calculateBaseStats(characterClass);
    
    // Determine starting inventory based on class
    uint256[] memory inventory = getStartingInventory(characterClass);
    
    // Create the player
    createPlayerRecord(name, characterClass, strength, intelligence, dexterity, defense, mana, inventory);
    
    emit PlayerCreated(msg.sender, name, characterClass);
}

/**
 * @dev Validates inputs for character creation
 * @param name The character's name
 * @param characterClass The class of the character
 */
function validateNewCharacter(string memory name, uint8 characterClass) private view {
    require(!players[msg.sender].isActive, "Player already exists");
    require(bytes(name).length > 0 && bytes(name).length <= 32, "Name must be between 1 and 32 characters");
    require(characterClass <= 4, "Invalid character class");
}

/**
 * @dev Calculates the base stats for a character based on their class
 * @param characterClass The class of the character
 * @return strength The character's strength stat
 * @return intelligence The character's intelligence stat
 * @return dexterity The character's dexterity stat
 * @return defense The character's defense stat
 * @return mana The character's mana stat
 */
function calculateBaseStats(uint8 characterClass) private pure returns (
    uint256 strength,
    uint256 intelligence,
    uint256 dexterity,
    uint256 defense,
    uint256 mana
) {
    // Set base stats
    strength = 10;
    intelligence = 10;
    dexterity = 10;
    defense = 10;
    mana = 50;
    
    // Adjust stats based on class
    if (characterClass == 0) { // Warrior
        strength += 5;
        defense += 3;
        intelligence -= 2;
    } else if (characterClass == 1) { // Mage
        intelligence += 5;
        mana += 20;
        strength -= 2;
    } else if (characterClass == 2) { // Rogue
        dexterity += 5;
        strength += 2;
        defense -= 1;
    } else if (characterClass == 3) { // Cleric
        intelligence += 3;
        defense += 2;
        dexterity += 1;
    } else if (characterClass == 4) { // Paladin
        strength += 3;
        defense += 3;
        intelligence += 1;
        dexterity -= 1;
    }
    
    return (strength, intelligence, dexterity, defense, mana);
}

/**
 * @dev Determines the starting inventory based on character class
 * @param characterClass The class of the character
 * @return inventory Array of item IDs for the starting inventory
 */
function getStartingInventory(uint8 characterClass) private view returns (uint256[] memory) {
    // Generate randomization seed based on block data and character class
    bytes32 randomSeed = keccak256(abi.encodePacked(
        block.timestamp,
        block.difficulty,
        block.number,
        characterClass,
        msg.sender
    ));
    
    // Determine inventory size with some randomness (3-6 items)
    uint8 inventorySize = 3 + (uint8(randomSeed[0]) % 4);
    uint256[] memory inventory = new uint256[](inventorySize);
    
    // Base items for each class - every character gets these
    if (characterClass == 0) { // Warrior
        inventory[0] = 1; // Wooden Sword
        inventory[1] = 2; // Leather Armor
    } else if (characterClass == 1) { // Mage
        inventory[0] = 7; // Magic Staff
        inventory[1] = 4; // Mana Potion
    } else if (characterClass == 2) { // Rogue
        inventory[0] = 1; // Wooden Sword
        inventory[1] = 3; // Health Potion
    } else if (characterClass == 3) { // Cleric
        inventory[0] = 7; // Magic Staff
        inventory[1] = 3; // Health Potion
    } else if (characterClass == 4) { // Paladin
        inventory[0] = 1; // Wooden Sword
        inventory[1] = 2; // Leather Armor
    }
    
    // Common consumable items pool
    uint256[] memory consumables = new uint256[](10);
    consumables[0] = 3;  // Health Potion
    consumables[1] = 4;  // Mana Potion
    consumables[2] = 25; // Stamina Potion
    consumables[3] = 26; // Antidote
    consumables[4] = 27; // Fire Resistance Potion
    consumables[5] = 28; // Frost Resistance Potion
    consumables[6] = 29; // Lightning Resistance Potion
    consumables[7] = 30; // Bread
    consumables[8] = 31; // Cheese
    consumables[9] = 32; // Dried Meat
    
    // Common equipment items pool
    uint256[] memory commonEquipment = new uint256[](15);
    commonEquipment[0] = 5;  // Basic Shield
    commonEquipment[1] = 6;  // Basic Bow
    commonEquipment[2] = 8;  // Basic Dagger
    commonEquipment[3] = 33; // Cloth Gloves
    commonEquipment[4] = 34; // Leather Boots
    commonEquipment[5] = 35; // Cloth Hood
    commonEquipment[6] = 36; // Leather Belt
    commonEquipment[7] = 37; // Wooden Staff
    commonEquipment[8] = 38; // Sling
    commonEquipment[9] = 39; // Wooden Buckler
    commonEquipment[10] = 40; // Cloth Pants
    commonEquipment[11] = 41; // Leather Vest
    commonEquipment[12] = 42; // Cloth Robe
    commonEquipment[13] = 43; // Traveler's Backpack
    commonEquipment[14] = 44; // Torch
    
    // Class-specific items
    // Warrior items
    uint256[] memory warriorItems = new uint256[](10);
    warriorItems[0] = 9;   // Training Helmet
    warriorItems[1] = 10;  // Warrior's Belt
    warriorItems[2] = 45;  // Iron Sword
    warriorItems[3] = 46;  // Chainmail
    warriorItems[4] = 47;  // Metal Gauntlets
    warriorItems[5] = 48;  // War Banner
    warriorItems[6] = 49;  // Whetstone
    warriorItems[7] = 50;  // Throwing Axe
    warriorItems[8] = 51;  // Battle Horn
    warriorItems[9] = 52;  // Warrior's Pendant
    
    // Mage items
    uint256[] memory mageItems = new uint256[](10);
    mageItems[0] = 11;  // Apprentice Robe
    mageItems[1] = 12;  // Magic Scroll
    mageItems[2] = 13;  // Mage's Amulet
    mageItems[3] = 53;  // Spellbook
    mageItems[4] = 54;  // Arcane Focus
    mageItems[5] = 55;  // Enchanted Quill
    mageItems[6] = 56;  // Mage's Hat
    mageItems[7] = 57;  // Elemental Orb
    mageItems[8] = 58;  // Rune Stone
    mageItems[9] = 59;  // Familiar Whistle
    
    // Rogue items
    uint256[] memory rogueItems = new uint256[](10);
    rogueItems[0] = 8;   // Basic Dagger
    rogueItems[1] = 14;  // Lockpicks
    rogueItems[2] = 15;  // Stealth Cloak
    rogueItems[3] = 60;  // Poison Vial
    rogueItems[4] = 61;  // Grappling Hook
    rogueItems[5] = 62;  // Smoke Bomb
    rogueItems[6] = 63;  // Thieves' Tools
    rogueItems[7] = 64;  // Hidden Blade
    rogueItems[8] = 65;  // Shadow Mask
    rogueItems[9] = 66;  // Caltrops
    
    // Cleric items
    uint256[] memory clericItems = new uint256[](10);
    clericItems[0] = 16;  // Holy Symbol
    clericItems[1] = 17;  // Healing Herbs
    clericItems[2] = 18;  // Prayer Book
    clericItems[3] = 67;  // Blessed Chalice
    clericItems[4] = 68;  // Censer
    clericItems[5] = 69;  // Holy Water
    clericItems[6] = 70;  // Divine Scroll
    clericItems[7] = 71;  // Ceremonial Robes
    clericItems[8] = 72;  // Saint's Relic
    clericItems[9] = 73;  // Healing Bandages
    
    // Paladin items
    uint256[] memory paladinItems = new uint256[](10);
    paladinItems[0] = 5;   // Basic Shield
    paladinItems[1] = 19;  // Holy Water
    paladinItems[2] = 20;  // Blessed Medallion
    paladinItems[3] = 74;  // Crusader Helm
    paladinItems[4] = 75;  // Templar Shield
    paladinItems[5] = 76;  // Blessed Mace
    paladinItems[6] = 77;  // Oath Scroll
    paladinItems[7] = 78;  // Paladin's Signet
    paladinItems[8] = 79;  // Purifying Incense
    paladinItems[9] = 80;  // Righteous Banner
    
    // Rare items pool (chance to get one of these)
    uint256[] memory rareItems = new uint256[](15);
    rareItems[0] = 81;  // Enchanted Blade
    rareItems[1] = 82;  // Mystic Orb
    rareItems[2] = 83;  // Dragon Scale
    rareItems[3] = 84;  // Ancient Coin
    rareItems[4] = 85;  // Elven Cloak
    rareItems[5] = 86;  // Dwarven Hammer
    rareItems[6] = 87;  // Phoenix Feather
    rareItems[7] = 88;  // Unicorn Horn
    rareItems[8] = 89;  // Goblin Trinket
    rareItems[9] = 90;  // Fairy Dust
    rareItems[10] = 91; // Cursed Amulet
    rareItems[11] = 92; // Mysterious Key
    rareItems[12] = 93; // Dimensional Pouch
    rareItems[13] = 94; // Celestial Map
    rareItems[14] = 95; // Forgotten Tome
    
    // Always give a consumable as the third item
    uint8 consumableIndex = uint8(randomSeed[1]) % 10;
    inventory[2] = consumables[consumableIndex];
    
    // Fill remaining inventory slots with randomized items
    for (uint8 i = 3; i < inventorySize; i++) {
        // Use different parts of the random seed for different decisions
        uint8 itemTypeRoll = uint8(randomSeed[i]) % 100;
        
        // 50% class item, 30% common equipment, 15% consumable, 5% rare item
        if (itemTypeRoll < 50) {
            // Class-specific item
            uint8 classItemIndex;
            if (characterClass == 0) { // Warrior
                classItemIndex = uint8(randomSeed[i+10]) % 10;
                inventory[i] = warriorItems[classItemIndex];
            } else if (characterClass == 1) { // Mage
                classItemIndex = uint8(randomSeed[i+10]) % 10;
                inventory[i] = mageItems[classItemIndex];
            } else if (characterClass == 2) { // Rogue
                classItemIndex = uint8(randomSeed[i+10]) % 10;
                inventory[i] = rogueItems[classItemIndex];
            } else if (characterClass == 3) { // Cleric
                classItemIndex = uint8(randomSeed[i+10]) % 10;
                inventory[i] = clericItems[classItemIndex];
            } else if (characterClass == 4) { // Paladin
                classItemIndex = uint8(randomSeed[i+10]) % 10;
                inventory[i] = paladinItems[classItemIndex];
            }
        } else if (itemTypeRoll < 80) {
            // Common equipment
            uint8 equipmentIndex = uint8(randomSeed[i+20]) % 15;
            inventory[i] = commonEquipment[equipmentIndex];
        } else if (itemTypeRoll < 95) {
            // Consumable
            uint8 consumableIdx = uint8(randomSeed[i+30]) % 10;
            inventory[i] = consumables[consumableIdx];
        } else {
            // Rare item (5% chance)
            uint8 rareItemIndex = uint8(randomSeed[i+40]) % 15;
            inventory[i] = rareItems[rareItemIndex];
        }
    }
    
    // Special case: If this is the last character slot (determined by some external factor)
    // or if there's a special event going on, give a legendary item
    // This is just an example condition - replace with your actual condition
    bool isSpecialCondition = uint8(randomSeed[31]) % 100 == 0; // 1% chance
    
    if (isSpecialCondition && inventorySize > 3) {
        // Legendary items (very rare)
        uint256[] memory legendaryItems = new uint256[](5);
        legendaryItems[0] = 96; // Excalibur
        legendaryItems[1] = 97; // Staff of the Archmage
        legendaryItems[2] = 98; // Cloak of Shadows
        legendaryItems[3] = 99; // Divine Chalice
        legendaryItems[4] = 100; // Hammer of the Righteous
        
        uint8 legendaryIndex = uint8(randomSeed[30]) % 5;
        inventory[inventorySize-1] = legendaryItems[legendaryIndex];
    }
    
    // Ensure no duplicate items by replacing any duplicates with consumables
    for (uint8 i = 0; i < inventorySize; i++) {
        for (uint8 j = i + 1; j < inventorySize; j++) {
            if (inventory[i] == inventory[j]) {
                // Replace duplicate with a consumable
                uint8 replacementIndex = uint8(keccak256(abi.encodePacked(randomSeed, j))[0]) % 10;
                inventory[j] = consumables[replacementIndex];
            }
        }
    }
    
    return inventory;
}


/**
 * @dev Creates the player record with all calculated stats and inventory
 * @param name The character's name
 * @param characterClass The class of the character
 * @param strength The character's strength stat
 * @param intelligence The character's intelligence stat
 * @param dexterity The character's dexterity stat
 * @param defense The character's defense stat
 * @param mana The character's mana stat
 * @param inventory Array of item IDs for the starting inventory
 */
function createPlayerRecord(
    string memory name,
    uint8 characterClass,
    uint256 strength,
    uint256 intelligence,
    uint256 dexterity,
    uint256 defense,
    uint256 mana,
    uint256[] memory inventory
) private {
    uint256[] memory emptyArray = new uint256[](0);
    
    players[msg.sender] = Player({
        name: name,
        level: 1,
        experience: 0,
        health: 100,
        maxHealth: 100,
        mana: mana,
        maxMana: mana,
        strength: strength,
        intelligence: intelligence,
        dexterity: dexterity,
        defense: defense,
        gold: 50,
        locationId: 1, // Start in Hometown
        questId: 0,
        isActive: true,
        lastAction: block.timestamp,
        inventory: inventory,
        completedQuests: emptyArray,
        characterClass: characterClass
    });
    
    playerAddresses.push(msg.sender);
}

    
    /**
     * @dev Move player to a connected location
     * @param locationId The ID of the location to move to
     */
    function moveToLocation(uint256 locationId) external gameIsActive playerExists playerAlive {
        require(locationId > 0 && locationId <= locationIds.length, "Invalid location ID");
        
        Location storage currentLocation = locations[players[msg.sender].locationId];
        bool isConnected = false;
        
        for (uint256 i = 0; i < currentLocation.connectedLocations.length; i++) {
            if (currentLocation.connectedLocations[i] == locationId) {
                isConnected = true;
                break;
            }
        }
        
        require(isConnected, "Location is not connected to your current location");
        
        Location storage newLocation = locations[locationId];
        require(players[msg.sender].level >= newLocation.requiredLevel, "Player level too low for this location");
        
        players[msg.sender].locationId = locationId;
        players[msg.sender].lastAction = block.timestamp;
        
        if (!newLocation.isDiscovered) {
            newLocation.isDiscovered = true;
            emit LocationDiscovered(msg.sender, locationId);
        }
        
        // Random encounter if location is not safe
        if (!newLocation.isSafe && _random(100) < 30) {
            // 30% chance of random encounter
            _triggerRandomEncounter(msg.sender);
        }
    }
    
    /**
     * @dev Attack a monster at the current location
     * @param monsterId The ID of the monster to attack
     */
function attackMonster(uint256 monsterId) external gameIsActive playerExists playerAlive {
    require(monsterId > 0 && monsterId <= monsterIds.length, "Invalid monster ID");

    Location storage currentLocation = locations[players[msg.sender].locationId];
    bool monsterPresent = false;

    for (uint256 i = 0; i < currentLocation.monsters.length; i++) {
        if (currentLocation.monsters[i] == monsterId) {
            monsterPresent = true;
            break;
        }
    }

    require(monsterPresent, "Monster is not at your current location");

    _resolveCombat(msg.sender, monsterId);
}

function _resolveCombat(address playerAddress, uint256 monsterId) internal {
    Monster storage monster = monsters[monsterId];
    Player storage player = players[playerAddress];

    uint256 playerHealth = player.health;
    uint256 monsterHealth = monster.health;
    uint256 playerDamage = player.strength + _getEquippedWeaponPower(playerAddress) + _random(10);
    uint256 monsterDamage = monster.damage;

    (playerHealth, monsterHealth) = _simulateCombatRound(playerHealth, monsterHealth, playerDamage, monsterDamage, monster.defense, player.defense);


    // Update player state based on combat result
    player.lastAction = block.timestamp;
    if (playerHealth > 0) {
        player.health = playerHealth;
        player.experience += monster.experienceReward;
        player.gold += monster.goldReward;
        _checkLevelUp(playerAddress);
        _processLootDrops(playerAddress, monsterId);

        if (player.questId > 0) {
            _updateQuestProgress(playerAddress, monsterId);
        }

        emit CombatResult(playerAddress, monsterId, true);
    } else {
        player.health = 0;
        player.gold = player.gold / 2; // Lose half gold on death
        emit CombatResult(playerAddress, monsterId, false);
        emit PlayerDied(playerAddress);
    }
}


/**
 * @dev Simulates a combat round between player and monster with randomized elements
 * @param playerHealth Starting health of the player
 * @param monsterHealth Starting health of the monster
 * @param playerDamage Base damage of the player
 * @param monsterDamage Base damage of the monster
 * @param monsterDefense Defense value of the monster
 * @param playerDefense Defense value of the player
 * @return Remaining player health and monster health after combat
 */
function _simulateCombatRound(
    uint256 playerHealth, 
    uint256 monsterHealth, 
    uint256 playerDamage, 
    uint256 monsterDamage, 
    uint256 monsterDefense, 
    uint256 playerDefense
) internal view returns (uint256, uint256) {
    // Apply defense reduction
    uint256 basePlayerDamage = playerDamage > monsterDefense ? playerDamage - monsterDefense : 1;
    uint256 baseMonsterDamage = monsterDamage > playerDefense ? monsterDamage - playerDefense : 1;
    
    // Combat rounds
    uint256 round = 0;
    while (playerHealth > 0 && monsterHealth > 0) {
        // Generate random variations for this round
        (uint256 playerDamageVariation, uint256 monsterDamageVariation, bool criticalHit, bool dodged) = 
            _generateCombatRandomness(round, basePlayerDamage, baseMonsterDamage);
        
        // Player attacks first
        if (!dodged) {
            uint256 actualPlayerDamage = basePlayerDamage + playerDamageVariation;
            
            // Apply critical hit bonus if applicable
            if (criticalHit) {
                actualPlayerDamage = actualPlayerDamage * 2;
            }
            
            monsterHealth = monsterHealth > actualPlayerDamage ? monsterHealth - actualPlayerDamage : 0;
        }
        
        // Monster attacks if still alive
        if (monsterHealth > 0) {
            // Generate dodge chance for monster attack
            bool playerDodged = _generateDodgeChance(round + 1);
            
            if (!playerDodged) {
                uint256 actualMonsterDamage = baseMonsterDamage + monsterDamageVariation;
                playerHealth = playerHealth > actualMonsterDamage ? playerHealth - actualMonsterDamage : 0;
            }
        }
        
        round++;
    }
    
    return (playerHealth, monsterHealth);
}

/**
 * @dev Generates randomized combat values for a specific round
 * @param round The current combat round
 * @param basePlayerDamage The player's base damage
 * @param baseMonsterDamage The monster's base damage
 * @return playerDamageVariation Random variation to player damage
 * @return monsterDamageVariation Random variation to monster damage
 * @return criticalHit Whether the player lands a critical hit
 * @return dodged Whether the monster dodges the player's attack
 */
function _generateCombatRandomness(
    uint256 round,
    uint256 basePlayerDamage,
    uint256 baseMonsterDamage
) private view returns (
    uint256 playerDamageVariation,
    uint256 monsterDamageVariation,
    bool criticalHit,
    bool dodged
) {
    // Use block data and round number to generate pseudo-randomness
    uint256 randomSeed = uint256(keccak256(abi.encodePacked(
        block.timestamp,
        block.prevrandao,
        block.number,
        round
    )));
    
    // Damage variation: -20% to +20% of base damage
    playerDamageVariation = (randomSeed % 41) * basePlayerDamage / 100;
    if ((randomSeed % 2) == 0) {
        // Negative variation (0-20% reduction)
        playerDamageVariation = randomSeed % 21 * basePlayerDamage / 100;
        playerDamageVariation = playerDamageVariation > basePlayerDamage ? basePlayerDamage - 1 : playerDamageVariation;
    }
    
    // Different seed for monster variation
    randomSeed = uint256(keccak256(abi.encodePacked(randomSeed, "monster")));
    
    monsterDamageVariation = (randomSeed % 41) * baseMonsterDamage / 100;
    if ((randomSeed % 2) == 0) {
        // Negative variation (0-20% reduction)
        monsterDamageVariation = randomSeed % 21 * baseMonsterDamage / 100;
        monsterDamageVariation = monsterDamageVariation > baseMonsterDamage ? baseMonsterDamage - 1 : monsterDamageVariation;
    }
    
    // Critical hit chance (15%)
    randomSeed = uint256(keccak256(abi.encodePacked(randomSeed, "critical")));
    criticalHit = (randomSeed % 100) < 15;
    
    // Dodge chance (10%)
    randomSeed = uint256(keccak256(abi.encodePacked(randomSeed, "dodge")));
    dodged = (randomSeed % 100) < 10;
    
    return (playerDamageVariation, monsterDamageVariation, criticalHit, dodged);
}

/**
 * @dev Generates a dodge chance for the player against monster attacks
 * @param seed A seed value to help with randomness
 * @return Whether the player dodged the attack
 */
function _generateDodgeChance(uint256 seed) private view returns (bool) {
    uint256 randomSeed = uint256(keccak256(abi.encodePacked(
        block.timestamp,
        block.prevrandao,
        seed
    )));
    
    // 12% chance to dodge
    return (randomSeed % 100) < 12;
}


    
    /**
     * @dev Use an item from inventory
     * @param itemId The ID of the item to use
     */
    function useItem(uint256 itemId) external gameIsActive playerExists {
        require(itemId > 0 && itemId <= itemIds.length, "Invalid item ID");
        
        Player storage player = players[msg.sender];
        bool hasItem = false;
        uint256 itemIndex;
        
        for (uint256 i = 0; i < player.inventory.length; i++) {
            if (player.inventory[i] == itemId) {
                hasItem = true;
                itemIndex = i;
                break;
            }
        }
        
        require(hasItem, "Player does not have this item");
        
        Item storage item = items[itemId];
        
        if (item.itemType == 2) { // Potion
            if (bytes(item.name).length > 0 && keccak256(abi.encodePacked(item.name)) == keccak256(abi.encodePacked("Health"))) {
                player.health = _min(player.health + item.power, player.maxHealth);
            } else if (bytes(item.name).length > 0 && keccak256(abi.encodePacked(item.name)) == keccak256(abi.encodePacked("Mana"))) {
                player.mana = _min(player.mana + item.power, player.maxMana);
            }
            
            // Remove the item from inventory
            _removeItemFromInventory(msg.sender, itemIndex);
        } else if (item.itemType == 3) { // Scroll
            // Implement scroll effects (e.g., teleport, temporary buffs)
            if (bytes(item.name).length > 0 && keccak256(abi.encodePacked(item.name)) == keccak256(abi.encodePacked("Teleport"))) {
                player.locationId = 1; // Teleport to Hometown
            }
            
            // Remove the item from inventory
            _removeItemFromInventory(msg.sender, itemIndex);
        }
        
        player.lastAction = block.timestamp;
    }    
    /**
     * @dev Start a quest
     * @param questId The ID of the quest to start
     */
    function startQuest(uint256 questId) external gameIsActive playerExists playerAlive {
        require(questId > 0 && questId <= questIds.length, "Invalid quest ID");
        require(players[msg.sender].questId == 0, "Already on a quest");
        
        Quest storage quest = quests[questId];
        Player storage player = players[msg.sender];
        
        require(player.level >= quest.requiredLevel, "Player level too low for this quest");
        
        // Check if prerequisite quest is completed
        if (quest.requiredQuestId > 0) {
            bool prerequisiteCompleted = false;
            for (uint256 i = 0; i < player.completedQuests.length; i++) {
                if (player.completedQuests[i] == quest.requiredQuestId) {
                    prerequisiteCompleted = true;
                    break;
                }
            }
            require(prerequisiteCompleted, "Prerequisite quest not completed");
        }
        
        player.questId = questId;
        player.lastAction = block.timestamp;
        
        emit QuestStarted(msg.sender, questId);
    }
    
    /**
     * @dev Talk to an NPC
     * @param npcId The ID of the NPC to talk to
     */
    function talkToNPC(uint256 npcId) external gameIsActive playerExists playerAlive returns (string memory) {
        require(npcId > 0 && npcId <= npcIds.length, "Invalid NPC ID");
        
        Location storage currentLocation = locations[players[msg.sender].locationId];
        bool npcPresent = false;
        
        for (uint256 i = 0; i < currentLocation.npcs.length; i++) {
            if (currentLocation.npcs[i] == npcId) {
                npcPresent = true;
                break;
            }
        }
        
        require(npcPresent, "NPC is not at your current location");
        
        NPC storage npc = npcs[npcId];
        
        if (npc.dialogues.length > 0) {
            uint256 dialogueId = npc.dialogues[0];
            return dialogues[dialogueId].text;
        } else {
            return "The NPC has nothing to say.";
        }
    }
    
    /**
     * @dev Buy an item from an NPC vendor
     * @param npcId The ID of the NPC vendor
     * @param itemIndex The index of the item in the vendor's inventory
     */
    function buyFromVendor(uint256 npcId, uint256 itemIndex) external gameIsActive playerExists playerAlive {
        require(npcId > 0 && npcId <= npcIds.length, "Invalid NPC ID");
        
        Location storage currentLocation = locations[players[msg.sender].locationId];
        bool npcPresent = false;
        
        for (uint256 i = 0; i < currentLocation.npcs.length; i++) {
            if (currentLocation.npcs[i] == npcId) {
                npcPresent = true;
                break;
            }
        }
        
        require(npcPresent, "NPC is not at your current location");
        
        NPC storage npc = npcs[npcId];
        require(npc.isVendor, "NPC is not a vendor");
        require(itemIndex < npc.itemsForSale.length, "Invalid item index");
        
        uint256 itemId = npc.itemsForSale[itemIndex];
        uint256 price = npc.itemPrices[itemIndex];
        
        Player storage player = players[msg.sender];
        require(player.gold >= price, "Not enough gold");
        
        player.gold -= price;
        player.inventory.push(itemId);
        player.lastAction = block.timestamp;
        
        emit ItemAcquired(msg.sender, itemId);
    }
    
    /**
     * @dev Heal the player at a safe location
     */
    function rest() external gameIsActive playerExists {
        Location storage currentLocation = locations[players[msg.sender].locationId];
        require(currentLocation.isSafe, "Cannot rest in an unsafe location");
        
        Player storage player = players[msg.sender];
        player.health = player.maxHealth;
        player.mana = player.maxMana;
        player.lastAction = block.timestamp;
    }
    
    /**
     * @dev Craft a new item from existing items
     * @param recipe Array of item IDs used in crafting
     */
/**
 * @dev Crafts a new item from recipe components
 * @param recipe Array of item IDs to use in crafting
 */
function craftItem(uint256[] calldata recipe) external gameIsActive playerExists playerAlive {
    require(recipe.length > 0 && recipe.length <= 3, "Invalid recipe size");
    
    Player storage player = players[msg.sender];
    
    // Check recipe validity and player ownership
    validateRecipe(recipe);
    
    // Calculate new item properties
    (uint256 newItemPower, uint8 dominantType) = calculateCraftedItemProperties(recipe);
    
    // Create the new item
    uint256 newItemId = createCraftedItem(dominantType, newItemPower, player.level);
    
    // Remove recipe items from inventory
    removeRecipeItemsFromInventory(recipe);
    
    // Add new item to inventory
    player.inventory.push(newItemId);
    player.lastAction = block.timestamp;
    
    emit ItemCrafted(msg.sender, newItemId);
}

/**
 * @dev Validates that the player has all items in the recipe
 * @param recipe Array of item IDs to check
 */
function validateRecipe(uint256[] calldata recipe) private view {
    Player storage player = players[msg.sender];
    
    for (uint256 i = 0; i < recipe.length; i++) {
        bool hasItem = false;
        for (uint256 j = 0; j < player.inventory.length; j++) {
            if (player.inventory[j] == recipe[i]) {
                hasItem = true;
                break;
            }
        }
        require(hasItem, "Missing recipe item");
    }
}

/**
 * @dev Calculates properties for the new crafted item
 * @param recipe Array of item IDs used in crafting
 * @return newItemPower The power of the new item
 * @return dominantType The dominant type of the new item
 */
function calculateCraftedItemProperties(uint256[] calldata recipe) private view returns (uint256 newItemPower, uint8 dominantType) {
    newItemPower = 0;
    dominantType = 0;
    uint256 typeCount = 0;
    
    for (uint256 i = 0; i < recipe.length; i++) {
        Item storage item = items[recipe[i]];
        newItemPower += item.power;
        
        // Count item types to determine dominant type
        uint8 currentType = item.itemType;
        if (i == 0 || currentType == dominantType) {
            dominantType = currentType;
            typeCount++;
        }
    }
    
    return (newItemPower, dominantType);
}

/**
 * @dev Creates a new crafted item with the calculated properties
 * @param dominantType The type of the new item
 * @param power The power level of the new item
 * @param playerLevel The level of the player crafting the item
 * @return newItemId The ID of the newly created item
 */
function createCraftedItem(uint8 dominantType, uint256 power, uint256 playerLevel) private returns (uint256) {
    uint256 newItemId = itemIds.length + 1;
    string memory newItemName = string(abi.encodePacked("Crafted ", _getItemTypeName(dominantType)));
    string memory newItemDesc = "A custom crafted item";
    
    // Generate heavy bytes for randomization
    bytes32 randomBytes = keccak256(abi.encodePacked(
        block.timestamp,
        block.difficulty,
        msg.sender,
        newItemId,
        power,
        playerLevel
    ));
    
    // Use the random bytes to modify the power
    uint256 randomModifier = uint8(randomBytes[0]) % 50 + 75; // 75-124% modifier
    uint256 modifiedPower = (power * randomModifier) / 100;    
    // Randomize item name suffix based on power modification
    string memory qualitySuffix;
    if (randomModifier > 115) {
        qualitySuffix = " of Excellence";
    } else if (randomModifier > 105) {
        qualitySuffix = " of Quality";
    } else if (randomModifier > 95) {
        qualitySuffix = "";
    } else if (randomModifier > 85) {
        qualitySuffix = " of Mediocrity";
    } else {
        qualitySuffix = " of Poor Craft";
    }
    
    newItemName = string(abi.encodePacked(newItemName, qualitySuffix));
    
    // Add random properties to description
    uint8 randomProperty = uint8(randomBytes[1]) % 5;
    string memory propertyDesc;
    if (randomProperty == 0) {
        propertyDesc = " with enhanced durability";
    } else if (randomProperty == 1) {
        propertyDesc = " with decorative engravings";
    } else if (randomProperty == 2) {
        propertyDesc = " with lightweight materials";
    } else if (randomProperty == 3) {
        propertyDesc = " with reinforced edges";
    } else {
        propertyDesc = " with mysterious runes";
    }
    
    newItemDesc = string(abi.encodePacked("A custom crafted item", propertyDesc));
    
    _createBasicItem(
        newItemId,
        newItemName,
        newItemDesc,
        dominantType,
        modifiedPower * 2, // Value is double the modified power
        modifiedPower,
        playerLevel,
        true
    );
    
    return newItemId;
}


/**
 * @dev Removes all recipe items from the player's inventory
 * @param recipe Array of item IDs to remove
 */
function removeRecipeItemsFromInventory(uint256[] calldata recipe) private {
    Player storage player = players[msg.sender];
    
    for (uint256 i = 0; i < recipe.length; i++) {
        for (uint256 j = 0; j < player.inventory.length; j++) {
            if (player.inventory[j] == recipe[i]) {
                _removeItemFromInventory(msg.sender, j);
                break;
            }
        }
    }
}

    
    /**
     * @dev Revive a dead player
     */
    function revive() external payable gameIsActive playerExists {
        require(players[msg.sender].health == 0, "Player is not dead");
        require(msg.value >= gameFee * 2, "Insufficient revival fee");
        
        players[msg.sender].health = players[msg.sender].maxHealth / 2; // Revive with half health
        players[msg.sender].lastAction = block.timestamp;
    }
    
    /**
     * @dev Get player stats
     */
    function getPlayerStats() external view playerExists returns (
        string memory name,
        uint256 level,
        uint256 experience,
        uint256 health,
        uint256 maxHealth,
        uint256 mana,
        uint256 maxMana,
        uint256 strength,
        uint256 intelligence,
        uint256 dexterity,
        uint256 defense,
        uint256 gold,
        uint256 locationId,
        uint256 questId
    ) {
        Player storage player = players[msg.sender];
        return (
            player.name,
            player.level,
            player.experience,
            player.health,
            player.maxHealth,
            player.mana,
            player.maxMana,
            player.strength,
            player.intelligence,
            player.dexterity,
            player.defense,
            player.gold,
            player.locationId,
            player.questId
        );
    }
    
    /**
     * @dev Get player inventory
     */
    function getInventory() external view playerExists returns (uint256[] memory) {
        return players[msg.sender].inventory;
    }
    
    /**
     * @dev Get item details
     */
    function getItemDetails(uint256 itemId) external view returns (
        string memory name,
        string memory description,
        uint8 itemType,
        uint256 value,
        uint256 power,
        uint256 requiredLevel,
        bool tradeable
    ) {
        require(itemId > 0 && itemId <= itemIds.length, "Invalid item ID");
        Item storage item = items[itemId];
        return (
            item.name,
            item.description,
            item.itemType,
            item.value,
            item.power,
            item.requiredLevel,
            item.tradeable
        );
    }
    
    /**
     * @dev Get monster details
     */
    function getMonsterDetails(uint256 monsterId) external view returns (
        string memory name,
        string memory description,
        uint256 health,
        uint256 damage,
        uint256 defense,
        uint256 experienceReward,
        uint256 goldReward
    ) {
        require(monsterId > 0 && monsterId <= monsterIds.length, "Invalid monster ID");
        Monster storage monster = monsters[monsterId];
        return (
            monster.name,
            monster.description,
            monster.health,
            monster.damage,
            monster.defense,
            monster.experienceReward,
            monster.goldReward
        );
    }
    
    /**
     * @dev Get location details
     */
    function getLocationDetails(uint256 locationId) external view returns (
        string memory name,
        string memory description,
        bool isSafe,
        bool isDiscovered,
        uint256 requiredLevel,
        uint256[] memory connectedLocations,
        uint256[] memory monsters,
        uint256[] memory npcs
    ) {
        require(locationId > 0 && locationId <= locationIds.length, "Invalid location ID");
        Location storage location = locations[locationId];
        return (
            location.name,
            location.description,
            location.isSafe,
            location.isDiscovered,
            location.requiredLevel,
            location.connectedLocations,
            location.monsters,
            location.npcs
        );
    }
    
    /**
     * @dev Get quest details
     */
    function getQuestDetails(uint256 questId) external view returns (
        string memory name,
        string memory description,
        uint256 requiredLevel,
        uint256[] memory objectives,
        uint256[] memory objectiveCounts,
        uint256[] memory rewards,
        uint256 goldReward,
        uint256 experienceReward,
        uint256 requiredQuestId
    ) {
        require(questId > 0 && questId <= questIds.length, "Invalid quest ID");
        Quest storage quest = quests[questId];
        return (
            quest.name,
            quest.description,
            quest.requiredLevel,
            quest.objectives,
            quest.objectiveCounts,
            quest.rewards,
            quest.goldReward,
            quest.experienceReward,
            quest.requiredQuestId
        );
    }
    
    // ==================== ADMIN FUNCTIONS ====================
    
    /**
     * @dev Set the game fee
     * @param newFee The new fee amount
     */
    function setGameFee(uint256 newFee) external onlyOwner {
        gameFee = newFee;
    }
    
    /**
     * @dev Pause or unpause the game
     * @param isActive Whether the game should be active
     */
    function setGameActive(bool isActive) external onlyOwner {
        gameActive = isActive;
    }
    
    /**
     * @dev Withdraw funds from the contract
     */
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(gameOwner).transfer(balance);
    }
    
    /**
     * @dev Create a new item (admin only)
     */
    function createItem(
        string memory name,
        string memory description,
        uint8 itemType,
        uint256 value,
        uint256 power,
        uint256 requiredLevel,
        bool tradeable
    ) external onlyOwner {
        uint256 newItemId = itemIds.length + 1;
        _createBasicItem(newItemId, name, description, itemType, value, power, requiredLevel, tradeable);
    }
    
    /**
     * @dev Create a new monster (admin only)
     */
    function createMonster(
        string memory name,
        string memory description,
        uint256 health,
        uint256 damage,
        uint256 defense,
        uint256 experienceReward,
        uint256 goldReward,
        uint256[] memory possibleLoot,
        uint256[] memory lootChance
    ) external onlyOwner {
        uint256 newMonsterId = monsterIds.length + 1;
        _createBasicMonster(
            newMonsterId,
            name,
            description,
            health,
            damage,
            defense,
            experienceReward,
            goldReward,
            possibleLoot,
            lootChance
        );
    }
    
    /**
     * @dev Create a new location (admin only)
     */
    function createLocation(
        string memory name,
        string memory description,
        uint256[] memory connectedLocations,
        uint256[] memory monsters,
        uint256[] memory npcs,
        bool isSafe,
        bool isDiscovered,
        uint256 requiredLevel
    ) external onlyOwner {
        uint256 newLocationId = locationIds.length + 1;
        _createLocation(
            newLocationId,
            name,
            description,
            connectedLocations,
            monsters,
            npcs,
            isSafe,
            isDiscovered,
            requiredLevel
        );
    }
    
    /**
     * @dev Create a new quest (admin only)
     */
    function createQuest(
        string memory name,
        string memory description,
        uint256 requiredLevel,
        uint256[] memory objectives,
        uint256[] memory objectiveCounts,
        uint256[] memory rewards,
        uint256 goldReward,
        uint256 experienceReward,
        uint256 requiredQuestId
    ) external onlyOwner {
        uint256 newQuestId = questIds.length + 1;
        _createBasicQuest(
            newQuestId,
            name,
            description,
            requiredLevel,
            objectives,
            objectiveCounts,
            rewards,
            goldReward,
            experienceReward,
            requiredQuestId
        );
    }
    
    // ==================== HELPER FUNCTIONS ====================
    
    /**
     * @dev Create a basic item (internal)
     */
    function _createBasicItem(
        uint256 id,
        string memory name,
        string memory description,
        uint8 itemType,
        uint256 value,
        uint256 power,
        uint256 requiredLevel,
        bool tradeable
    ) internal {
        Item storage newItem = items[id];
        newItem.name = name;
        newItem.description = description;
        newItem.itemType = itemType;
        newItem.value = value;
        newItem.power = power;
        newItem.requiredLevel = requiredLevel;
        newItem.tradeable = tradeable;
        
        itemIds.push(id);
    }
    
    /**
     * @dev Create a basic monster (internal)
     */
    function _createBasicMonster(
        uint256 id,
        string memory name,
        string memory description,
        uint256 health,
        uint256 damage,
        uint256 defense,
        uint256 experienceReward,
        uint256 goldReward,
        uint256[] memory possibleLoot,
        uint256[] memory lootChance
    ) internal {
        Monster storage newMonster = monsters[id];
        newMonster.name = name;
        newMonster.description = description;
        newMonster.health = health;
        newMonster.damage = damage;
        newMonster.defense = defense;
        newMonster.experienceReward = experienceReward;
        newMonster.goldReward = goldReward;
        newMonster.possibleLoot = possibleLoot;
        newMonster.lootChance = lootChance;
        
        monsterIds.push(id);
    }
    
    /**
     * @dev Create a location (internal)
     */
    function _createLocation(
        uint256 id,
        string memory name,
        string memory description,
        uint256[] memory connectedLocations,
        uint256[] memory monsters,
        uint256[] memory npcs,
        bool isSafe,
        bool isDiscovered,
        uint256 requiredLevel
    ) internal {
        Location storage newLocation = locations[id];
        newLocation.name = name;
        newLocation.description = description;
        newLocation.connectedLocations = connectedLocations;
        newLocation.monsters = monsters;
        newLocation.npcs = npcs;
        newLocation.isSafe = isSafe;
        newLocation.isDiscovered = isDiscovered;
        newLocation.requiredLevel = requiredLevel;
        
        locationIds.push(id);
    }
    
    /**
     * @dev Create a basic quest (internal)
     */
    function _createBasicQuest(
        uint256 id,
        string memory name,
        string memory description,
        uint256 requiredLevel,
        uint256[] memory objectives,
        uint256[] memory objectiveCounts,
        uint256[] memory rewards,
        uint256 goldReward,
        uint256 experienceReward,
        uint256 requiredQuestId
    ) internal {
        Quest storage newQuest = quests[id];
        newQuest.name = name;
        newQuest.description = description;
        newQuest.requiredLevel = requiredLevel;
        newQuest.objectives = objectives;
        newQuest.objectiveCounts = objectiveCounts;
        newQuest.rewards = rewards;
        newQuest.goldReward = goldReward;
        newQuest.experienceReward = experienceReward;
        newQuest.requiredQuestId = requiredQuestId;
        
        questIds.push(id);
    }
    
    /**
     * @dev Create a basic NPC (internal)
     */
    function _createBasicNPC(
        uint256 id,
        string memory name,
        string memory description,
        uint256[] memory dialogues,
        uint256[] memory quests,
        bool isVendor,
        uint256[] memory itemsForSale,
        uint256[] memory itemPrices
    ) internal {
        NPC storage newNPC = npcs[id];
        newNPC.name = name;
        newNPC.description = description;
        newNPC.dialogues = dialogues;
        newNPC.quests = quests;
        newNPC.isVendor = isVendor;
        newNPC.itemsForSale = itemsForSale;
        newNPC.itemPrices = itemPrices;
        
        npcIds.push(id);
    }
    
    /**
     * @dev Create a dialogue (internal)
     */
    function _createDialogue(
        uint256 id,
        string memory text,
        uint256[] memory responses
    ) internal {
        Dialogue storage newDialogue = dialogues[id];
        newDialogue.text = text;
        newDialogue.responses = responses;
        
        dialogueIds.push(id);
    }
    
    /**
     * @dev Check if player can level up
     */
    function _checkLevelUp(address playerAddress) internal {
        Player storage player = players[playerAddress];
        uint256 requiredXP = player.level * 100;
        
        if (player.experience >= requiredXP) {
            player.level++;
            player.maxHealth += 20;
            player.health = player.maxHealth;
            player.maxMana += 10;
            player.mana = player.maxMana;
            player.strength += 2;
            player.intelligence += 2;
            player.dexterity += 2;
            player.defense += 2;
            
            emit PlayerLevelUp(playerAddress, player.level);
        }
    }
    
    /**
     * @dev Process loot drops from a monster
     */
    function _processLootDrops(address playerAddress, uint256 monsterId) internal {
        Monster storage monster = monsters[monsterId];
        Player storage player = players[playerAddress];
        
        for (uint256 i = 0; i < monster.possibleLoot.length; i++) {
            uint256 chance = monster.lootChance[i];
            if (_random(100) < chance) {
                uint256 lootItemId = monster.possibleLoot[i];
                player.inventory.push(lootItemId);
                emit ItemAcquired(playerAddress, lootItemId);
            }
        }
    }
    
    /**
     * @dev Update quest progress
     */
    function _updateQuestProgress(address playerAddress, uint256 monsterId) internal {
        Player storage player = players[playerAddress];
        Quest storage quest = quests[player.questId];
        
        // Check if this monster is a quest objective
        for (uint256 i = 0; i < quest.objectives.length; i++) {
            if (quest.objectives[i] == monsterId) {
                // Quest completed
                player.experience += quest.experienceReward;
                player.gold += quest.goldReward;
                
                // Add reward items to inventory
                for (uint256 j = 0; j < quest.rewards.length; j++) {
                    player.inventory.push(quest.rewards[j]);
                    emit ItemAcquired(playerAddress, quest.rewards[j]);
                }
                
                // Add to completed quests
                player.completedQuests.push(player.questId);
                player.questId = 0;
                
                emit QuestCompleted(playerAddress, quest.objectives[i]);
                
                // Check for level up
                _checkLevelUp(playerAddress);
                break;
            }
        }
    }
    
    /**
     * @dev Remove an item from player's inventory
     */
    function _removeItemFromInventory(address playerAddress, uint256 index) internal {
        Player storage player = players[playerAddress];
        require(index < player.inventory.length, "Invalid inventory index");
        
        // Replace the item with the last item in the array and then pop
        if (index < player.inventory.length - 1) {
            player.inventory[index] = player.inventory[player.inventory.length - 1];
        }
        player.inventory.pop();
    }
    
    /**
     * @dev Get the power of the equipped weapon
     */
    function _getEquippedWeaponPower(address playerAddress) internal view returns (uint256) {
        Player storage player = players[playerAddress];
        uint256 bestWeaponPower = 0;
        
        for (uint256 i = 0; i < player.inventory.length; i++) {
            Item storage item = items[player.inventory[i]];
            if (item.itemType == 0 && item.power > bestWeaponPower) { // Weapon type
                bestWeaponPower = item.power;
            }
        }
        
        return bestWeaponPower;
    }
    
    /**
     * @dev Trigger a random encounter
     */
function _triggerRandomEncounter(address playerAddress) internal {
    Player storage player = players[playerAddress];
    Location storage location = locations[player.locationId];

    if (location.monsters.length > 0) {
        uint256 randomIndex = _random(location.monsters.length);
        uint256 monsterId = location.monsters[randomIndex];
        _resolveEncounter(playerAddress, monsterId);
    }
}

function _resolveEncounter(address playerAddress, uint256 monsterId) internal {
    Player storage player = players[playerAddress];
    Monster storage monster = monsters[monsterId];

    uint256 playerHealth = player.health;
    uint256 monsterHealth = monster.health;
    uint256 playerDamage = player.strength + _getEquippedWeaponPower(playerAddress) + _random(10);
    uint256 monsterDamage = monster.damage;

    // Apply defense reduction
    playerDamage = playerDamage > monster.defense ? playerDamage - monster.defense : 1;
    monsterDamage = monsterDamage > player.defense ? monsterDamage - player.defense : 1;

    // Combat rounds
    while (playerHealth > 0 && monsterHealth > 0) {
        monsterHealth = monsterHealth > playerDamage ? monsterHealth - playerDamage : 0;
        if (monsterHealth > 0) {
            playerHealth = playerHealth > monsterDamage ? playerHealth - monsterDamage : 0;
        }
    }

    // Update player state based on combat result
    if (playerHealth > 0) {
        player.health = playerHealth;
        player.experience += monster.experienceReward;
        player.gold += monster.goldReward;
        _checkLevelUp(playerAddress);
        _processLootDrops(playerAddress, monsterId);
        emit CombatResult(playerAddress, monsterId, true);
    } else {
        player.health = 0;
        player.gold = player.gold / 2;
        emit CombatResult(playerAddress, monsterId, false);
        emit PlayerDied(playerAddress);
    }
}


    
    /**
     * @dev Get a random number between 0 and max-1
     */
    function _random(uint256 max) internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender))) % max;
    }
    
    /**
     * @dev Get the minimum of two values
     */
    function _min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
    
    /**
     * @dev Convert a uint to a string
     */
    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        
        uint256 temp = value;
        uint256 digits;
        
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        
        bytes memory buffer = new bytes(digits);
        
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        
        return string(buffer);
    }
    
    /**
     * @dev Get the name of an item type
     */
    function _getItemTypeName(uint8 itemType) internal pure returns (string memory) {
        if (itemType == 0) return "Weapon";
        if (itemType == 1) return "Armor";
        if (itemType == 2) return "Potion";
        if (itemType == 3) return "Scroll";
        if (itemType == 4) return "Quest Item";
        return "Unknown";
    }
    
    // ==================== LARGE DATA FUNCTIONS ====================
    // These functions are added to increase contract size while maintaining functionality
    
    /**
     * @dev Generate a large amount of game lore
     */
    function getGameLore() external pure returns (string memory) {
        return string(abi.encodePacked(
            "In the ancient realm of Etheria, a world once blessed by the gods now stands on the brink of chaos. ",
            "Centuries ago, the five divine artifacts known as the Ethereal Shards maintained balance across the land. ",
            "But when the dark sorcerer Malachar sought to harness their power, the artifacts were scattered to the far corners of the world. ",
            "Without the Shards' protection, ancient evils have awakened, and monsters roam freely across once peaceful lands. ",
            "The kingdom's last hope lies with brave adventurers willing to face these dangers, recover the lost Shards, and restore balance to Etheria. ",
            "As you begin your journey in the humble village of Hometon, destiny calls you to become the hero this world desperately needs. ",
            "Will you answer the call and save Etheria from darkness, or will you forge your own path in this world of magic and mystery? ",
            "The choices you make will shape not only your fate but the future of the entire realm."
        ));
    }
    
    
    function getDetailedLocationDescription(uint256 locationId) external view returns (string memory) {
        require(locationId > 0 && locationId <= locationIds.length, "Invalid location ID");
        
        if (locationId == 1) {
            return string(abi.encodePacked(
                "Hometown is a peaceful village nestled in a verdant valley, surrounded by rolling hills and fertile farmland. ",
                "Stone cottages with thatched roofs line the cobblestone streets, smoke curling from chimneys into the clear blue sky. ",
                "The village square features a central well where locals gather to exchange news and goods from traveling merchants. ",
                "A modest inn, The Restful Pilgrim, offers comfortable beds and hearty meals to weary travelers. ",
                "The village blacksmith works tirelessly, the rhythmic clanging of hammer on anvil a constant backdrop to daily life. ",
                "On the northern edge stands a small shrine dedicated to the gods, where villagers leave offerings for good harvests and protection. ",
                "Despite its humble appearance, Hometown has stood for generations, a bastion of normalcy in an increasingly dangerous world."
            ));
        } else if (locationId == 2) {
            return string(abi.encodePacked(
                "The Dark Forest looms at the edge of civilization, a wall of ancient trees whose dense canopy blocks most sunlight from reaching the forest floor. ",
                "Massive trunks, some wider than a man is tall, support a ceiling of leaves that whisper secrets when the wind blows through them. ",
                "The air is thick with the scent of damp earth, moss, and decay, while strange fungi glow with an eerie blue light in the perpetual twilight. ",
                "Twisted roots create natural traps for the unwary, and the calls of unseen creatures echo through the mist that clings to the ground. ",
                "Local legends speak of people entering the forest and emerging changed if they emerge at all. ",
                "Paths seem to shift and change, confounding even experienced trackers, as if the forest itself is alive and playing tricks on intruders. ",
                "Only the brave or the foolish venture deep into the Dark Forest, where ancient magic and primal dangers await."
            ));
        } else if (locationId == 3) {
            return string(abi.encodePacked(
                "The Mountain Pass cuts through the imposing Dragonspine Range, offering the only safe route through these treacherous peaks for hundreds of miles. ",
                "Sheer cliff faces rise on either side of the narrow trail, which winds its way between massive boulders and across precarious stone bridges. ",
                "In winter, the pass is completely blocked by snow, isolating the regions it connects until the spring thaw clears the way once more. ",
                "The thin air at this altitude makes breathing difficult for lowlanders, and unexpected snowstorms can appear even in summer months. ",
                "Crude shelters have been built at intervals along the route, offering minimal protection from the elements for travelers caught in bad weather. ",
                "Mountain goats navigate the steep slopes with ease, watching travelers with curious eyes, while eagles soar overhead on thermal currents. ",
                "Bandits sometimes use the pass's many caves and blind corners to ambush merchant caravans, adding human danger to the natural perils of the journey."
            ));
        } else if (locationId == 4) {
            return string(abi.encodePacked(
                "The Ancient Ruins stand as a crumbling testament to a civilization long forgotten, its once-grand structures now half-buried in earth and overgrown with vegetation. ",
                "Massive columns of white marble, now cracked and stained by centuries of exposure, support fragments of roofs that once sheltered kings and scholars. ",
                "Intricate carvings cover walls and fallen stones, depicting battles, rituals, and daily life of a people whose name has been lost to time. ",
                "The air feels charged with lingering magic, causing compasses to spin wildly and making some visitors report strange visions or whispered voices. ",
                "Underground chambers and passages honeycomb the earth beneath the visible ruins, many still sealed by ancient mechanisms or collapsed over the centuries. ",
                "Scholars and treasure hunters alike are drawn to these ruins, seeking knowledge or wealth among the remnants of past glory. ",
                "Local villages warn of curses befalling those who disturb certain areas, and tales of undead guardians rising at night keep most common folk away."
            ));
        } else if (locationId == 5) {
            return string(abi.encodePacked(
                "The Dragon's Lair occupies a volcanic mountain whose peak has been sheared off, creating a massive caldera accessible only through a single narrow passage. ",
                "Heat shimmers in the air around the mountain, and sulfurous fumes occasionally waft from cracks in the blackened rock face. ",
                "The approach is littered with the charred and melted remains of would-be dragon slayers who failed in their quests, their weapons and armor fused to the stone. ",
                "Inside the caldera, a vast hoard of gold, jewels, and magical artifacts is piled around a central pool of bubbling lava that provides warmth for the dragon's massive body. ",
                "Bones of various creatures some humanoid, others from beasts larger than houses are scattered throughout the lair, grim trophies of the dragon's hunts and battles. ",
                "The walls of the caldera bear the scars of the dragon's rage, with deep gouges in solid rock and areas melted smooth by its fiery breath. ",
                "Few have seen the interior of the lair and lived to describe it, making accurate information scarce and often exaggerated in tavern tales."
            ));
        } else {
            Location storage location = locations[locationId];
            return string(abi.encodePacked(
                "This is ", location.name, ". ", location.description,
                " The area has a required level of ", _toString(location.requiredLevel), "."
            ));
        }
    }
    

    function getDetailedMonsterDescription(uint256 monsterId) external view returns (string memory) {
        require(monsterId > 0 && monsterId <= monsterIds.length, "Invalid monster ID");
        
        if (monsterId == 1) {
            return string(abi.encodePacked(
                "Goblins are small, wiry humanoids standing about three to four feet tall, with pointed ears, wide mouths filled with sharp teeth, and skin tones ranging from sickly green to muddy brown. ",
                "They possess surprising strength for their size and move with a quick, skittering gait that can be unsettling to observe. ",
                "Typically dressed in patchwork leather armor cobbled together from their victims' belongings, they favor crude but effective weapons like short swords, daggers, and spiked clubs. ",
                "Goblins are notorious for their pack mentality, preferring to overwhelm opponents with superior numbers rather than face them in fair combat. ",
                "Their high-pitched cackles and jeers often precede an attack, used as a psychological tactic to unnerve their prey. ",
                "While individually weak, their cunning should not be underestimated goblins are adept at setting simple traps and executing ambushes with surprising coordination. ",
                "They are primarily nocturnal, their large eyes adapted for seeing in darkness, giving them an advantage during night raids on villages and camps."
            ));
        } else if (monsterId == 10) {
            return string(abi.encodePacked(
                "The Dragon is an ancient behemoth of terrifying majesty, its massive body covered in scales harder than the finest steel, shimmering with a deep crimson hue that catches the light like polished rubies. ",
                "From snout to tail-tip, it measures over seventy feet, with a wingspan nearly twice that length when fully extended, capable of creating windstorms with a single powerful beat. ",
                "Its head bears a crown of horns that have grown more numerous with age, and eyes that glow like molten gold, reflecting intelligence far beyond that of any common beast. ",
                "Smoke constantly curls from its nostrils, and the heat of its body is palpable from a hundred paces, causing the air to shimmer around its form even when at rest. ",
                "Centuries of consuming magical creatures and artifacts have infused its already formidable natural weapons with arcane energy its teeth can shear through enchanted armor, its claws leave wounds that resist magical healing, and its fiery breath can melt stone and boil water instantly. ",
                "The dragon's roar is a weapon in itself, so powerful it can shatter glass, stun lesser creatures, and be heard for miles in all directions, announcing its dominance over its territory. ",
                "Perhaps most dangerous of all is the dragon's cunning mind, capable of complex strategies, long-term planning, and a cruel creativity in dealing with those who dare to challenge its might."
            ));
        } else {
            Monster storage monster = monsters[monsterId];
            return string(abi.encodePacked(
                monster.name, " - ", monster.description,
                " This creature has ", _toString(monster.health), " health points and deals ",
                _toString(monster.damage), " damage. Defeating it rewards ",
                _toString(monster.experienceReward), " experience and ",
                _toString(monster.goldReward), " gold coins."
            ));
        }
    }
    

    function getDetailedQuestDescription(uint256 questId) external view returns (string memory) {
        require(questId > 0 && questId <= questIds.length, "Invalid quest ID");
        
        if (questId == 1) {
            return string(abi.encodePacked(
                "The Goblin Threat has become unbearable for the residents of Hometown. What began as occasional livestock theft has escalated to nightly raids, with families now barricading their doors at sunset. ",
                "The village elder explains that the goblin tribe in the nearby forest has fallen under the leadership of a particularly cunning chieftain who has united several smaller bands. ",
                "Local hunters have tracked the goblins to a series of caves at the forest edge but lack the combat experience to clear out the nest. ",
                "Your task is to eliminate at least five goblins, including any scouts or sentries you encounter, to diminish their numbers and disrupt their organization. ",
                "The elder warns that the goblins may possess crude traps around their territory and recommends approaching with caution, particularly after dark when their night vision gives them an advantage. ",
                "Completing this quest will not only earn you the gratitude of the villagers who have pooled their resources to offer a reward but also make the surrounding area safer for travel and trade. ",
                "This is an ideal opportunity for a novice adventurer to prove their worth and gain valuable combat experience against a dangerous but manageable foe."
            ));
        } else if (questId == 4) {
            return string(abi.encodePacked(
                "Dragon Slayer is the ultimate challenge for only the most powerful and experienced heroes. For decades, the ancient dragon has terrorized the kingdom from its volcanic lair, demanding tribute and occasionally razing entire villages when its demands are not met. ",
                "The king, having lost his eldest son to a previous failed expedition against the beast, has promised his daughter's hand in marriage and half his kingdom to whoever can end the dragon's reign of terror once and for all. ",
                "Scholars at the royal academy have spent years researching the dragon's weaknesses, discovering that its scales are thinnest near its heart, though still tougher than ordinary armor. They have also created special weapons designed to penetrate those scales, available only to those who undertake this quest officially. ",
                "The journey to the dragon's mountain is perilous in itself, requiring passage through monster-infested wilderness and harsh terrain that has claimed many lives before even reaching the final confrontation. ",
                "Those who have glimpsed the dragon and survived report that it possesses not only devastating physical attacks and fiery breath but also command of ancient magic that can confuse, weaken, or enslave opponents. ",
                "Success would mean eternal glory, incredible rewards, and saving countless lives from future destruction. Failure, like for so many before you, would mean becoming another charred skeleton decorating the approach to the dragon's lair. ",
                "This quest represents the pinnacle of heroic achievement in the realm are you truly ready to face a creature that has survived centuries of would-be slayers?"
            ));
        } else {
            Quest storage quest = quests[questId];
            return string(abi.encodePacked(
                quest.name, " - ", quest.description,
                " This quest requires level ", _toString(quest.requiredLevel),
                " and rewards ", _toString(quest.experienceReward), " experience and ",
                _toString(quest.goldReward), " gold upon completion."
            ));
        }
    }
    

    function getGameTips() external pure returns (string memory) {
        return string(abi.encodePacked(
            "1. Always carry health potions when venturing into dangerous areas. ",
            "2. Upgrade your equipment as soon as you can afford better items. ",
            "3. Complete quests in order of difficulty for the smoothest progression. ",
            "4. Rest at safe locations to restore health and mana without using potions. ",
            "5. Some monsters drop rare items that can't be purchased from vendors. ",
            "6. Talking to NPCs multiple times may reveal different information. ",
            "7. Higher level areas contain better loot but more dangerous enemies. ",
            "8. Crafting can create items more powerful than those available for purchase. ",
            "9. Different character classes excel at different types of combat. ",
            "10. Some quests have hidden objectives that provide additional rewards. ",
            "11. Certain locations are only accessible after completing specific quests. ",
            "12. The game world changes based on your actions and quest completions. ",
            "13. Saving gold early game helps with purchasing better equipment later. ",
            "14. Some monsters are weak to specific damage types or strategies. ",
            "15. Exploring thoroughly can reveal secret areas with valuable treasures. ",
            "16. NPCs may offer different items or quests based on your character level. ",
            "17. Completing side quests often makes main quests easier by providing better gear. ",
            "18. Some rare items have special abilities that aren't immediately obvious. ",
            "19. Certain combinations of items can be especially effective when used together. ",
            "20. The difficulty of random encounters scales with your character level."
        ));
    }
    

    function getGameHistory() external pure returns (string memory) {
        return string(abi.encodePacked(
            "The First Age: Creation and Awakening",
            "In the beginning, the five Primal Gods shaped Etheria from the cosmic void. Auros created the land and mountains, Sylva the forests and plants, Aquos the seas and rivers, Aeros the sky and winds, and Ignos the fire and sun. Together, they breathed life into their creation, populating it with creatures of all kinds. The gods then created the Ethereal Shards, five crystalline artifacts containing a portion of their divine power, to maintain balance in their new world. For millennia, Etheria flourished under their watchful eyes, as the first civilizations of elves, dwarves, and humans began to form. This period of peace and growth lasted for ten thousand years and is known as the Age of Dawn.",
            
            "The Second Age: The Mage Wars",
            "As mortal races evolved and their understanding of magic grew, some began to covet the power of the gods. A human archmage named Malachar discovered the existence of the Ethereal Shards and sought to claim them for himself. He gathered followers and launched a campaign to seize the artifacts, triggering a devastating conflict known as the Mage Wars. For three centuries, battlemages unleashed arcane devastation across the continent, permanently altering the landscape and creating magical anomalies that persist to this day. The war ended when Malachar was defeated at the Battle of Shattered Peaks, but not before he managed to corrupt one of the Shards. The gods, fearing further misuse of their power, scattered the Shards across Etheria and retreated from direct interaction with mortals.",
            
            "The Third Age: The Time of Kingdoms",
            "Following the Mage Wars, survivors rebuilt their societies, establishing new kingdoms with clear boundaries. The human Kingdom of Valorian rose in the central plains, the elven Sylvanor claimed the western forests, dwarven clans united under the Ironhold Banner in the northern mountains, and various other realms took shape across the land. For two thousand years, these kingdoms developed distinct cultures, technologies, and magical traditions. Trade routes connected distant lands, and a period of relative peace allowed art and knowledge to flourish. However, without the full power of the Ethereal Shards maintaining balance, dark forces slowly began to stir in the shadows.",
            
            "The Fourth Age: The Shadow Rising",
            "Five hundred years ago, the corruption that Malachar had introduced into one of the Shards began to spread. Monsters that had been confined to remote regions grew bolder, attacking settlements with increasing frequency. Ancient evils awakened from long slumbers, and the boundaries between Etheria and darker realms weakened. The Kingdom of Valorian fractured into competing duchies after a succession crisis, while other realms faced their own internal struggles. It was during this time that dragons, long thought to be mere legends from the First Age, returned to Etheria, establishing territories and demanding tribute from nearby communities. Heroes rose to combat these threats, but for every victory, new dangers emerged.",
            
            "The Present: The Age of Heroes",
            "Now, Etheria stands at a crossroads. The corruption continues to spread, and scholars predict that without the restoration of the Ethereal Shards, the world may face a cataclysm within a generation. The once-great kingdoms have weakened, leaving frontier towns and villages largely to fend for themselves against increasing monster attacks. Yet hope remains in the form of adventurers who travel the land, solving problems that armies cannot. Rumors speak of the Shards' locations being discovered in ancient texts, prompting a race to recover these artifacts. Some seek them to save the world, others for personal power, and still others to destroy them completely. In this time of uncertainty, individual actions may determine the fate of all Etheria."
        ));
    }
    

    function getSpellDescriptions() external pure returns (string memory) {
        return string(abi.encodePacked(
            "Arcane Missile: Conjures three bolts of pure magical energy that unerringly strike their target, causing moderate damage. The caster's intelligence directly increases the spell's effectiveness. This basic spell requires minimal mana and can be cast rapidly, making it a staple for mages of all experience levels.",
            
            "Healing Light: Channels divine energy to mend wounds and restore health to the caster or an ally. The amount healed scales with the caster's intelligence and spiritual connection. More powerful versions of this spell can cure minor ailments and diseases in addition to healing physical damage.",
            
            "Flame Burst: Creates an explosion of fire at a targeted location, damaging all enemies within its radius. The intense heat can ignite flammable objects in the environment, potentially creating tactical advantages or hazards. Careful positioning is essential to avoid harming allies.",
            
            "Frost Nova: Releases a wave of freezing energy around the caster, damaging nearby enemies and significantly slowing their movement. At higher power levels, this spell can completely immobilize weaker foes, making it excellent for crowd control in overwhelming situations.",
            
            "Lightning Strike: Calls down a bolt of lightning from the sky, dealing severe damage to a single target and moderate damage to adjacent enemies. The spell is particularly effective against targets wearing metal armor or standing in water, where the electrical energy can conduct more efficiently.",
            
            "Stone Skin: Magically hardens the recipient's skin to resemble granite, substantially increasing physical defense for the duration. While active, the spell reduces movement speed slightly due to the added weight and rigidity of the transformed skin.",
            
            "Mind Blast: Projects a concentrated burst of psychic energy that damages an enemy's consciousness rather than their physical form. This spell bypasses conventional armor but is less effective against targets with high intelligence or mental fortitude. Some creatures with unusual mind structures may be completely immune.",
            
            "Nature's Embrace: Calls upon primal energies to rapidly accelerate natural healing processes in the target, providing continuous health restoration over time rather than immediate healing. Additionally grants increased resistance to poison and disease for the duration.",
            
            "Teleportation: Instantly transports the caster to a visible location within a moderate range. The spell requires significant concentration and mana, with the difficulty and cost increasing with distance. Attempting to teleport to an unknown or obscured destination is extremely dangerous and may result in materialization inside solid objects.",
            
            "Summon Elemental: Opens a temporary portal to elemental planes, calling forth a servant of fire, water, earth, or air to fight alongside the caster. The elemental's power and duration are determined by the caster's intelligence and the amount of mana invested in the summoning ritual.",
            
            "Invisibility: Bends light around the recipient, rendering them completely unseen to normal vision. The effect is disrupted if the invisible entity attacks or casts spells, requiring a moment of concentration to reestablish. Some magical creatures can perceive invisible beings through other senses or arcane detection.",
            
            "Chain Lightning: Releases a bolt of lightning that strikes an initial target before jumping to nearby enemies, with each jump reducing the damage slightly. Particularly effective against grouped opponents, this spell can eliminate multiple weaker foes with a single casting.",
            
            "Divine Shield: Creates a barrier of holy energy that absorbs a significant amount of damage before dissipating. The shield blocks all types of harm, including physical, magical, and environmental damage, making it one of the most versatile protection spells available to clerics and paladins.",
            
            "Necrotic Drain: Draws life essence from an enemy to heal the caster for a portion of the damage inflicted. Considered morally questionable by many magical authorities, this spell is particularly effective against living creatures but nearly useless against undead or constructs.",
            
            "Earthquake: Causes the ground in a large area to violently shake, knocking enemies off balance, disrupting spellcasting, and potentially causing structures to collapse. The spell affects friends and foes alike, requiring strategic positioning before casting.",
            
            "Time Distortion: Creates a localized field where time flows differently, greatly increasing the affected allies' speed or slowing enemies to a crawl. One of the most mana-intensive spells known, even powerful mages can only maintain this effect for brief periods before exhaustion sets in.",
            
            "Mass Illusion: Crafts a complex sensory deception affecting sight, sound, and even smell, capable of fooling multiple observers simultaneously. The illusion can be as simple as disguising appearances or as elaborate as creating phantom armies, limited only by the caster's imagination and concentration.",
            
            "Planar Binding: Temporarily merges a portion of an alternate plane with the material world, subjecting everything in the affected area to that plane's natural laws. When binding the Plane of Fire, for example, the area becomes superheated and may spontaneously combust, while binding the Plane of Water might create crushing pressure and difficulty breathing.",
            
            "Mind Control: Overrides a target's free will, allowing the caster to issue commands that the victim will follow unquestioningly. Stronger minds can resist the effect entirely or break free over time, particularly if ordered to perform actions against their fundamental nature or self-interest."
        ));
 
   }

function discoverTreasure(uint256 treasureId) external gameIsActive playerExists playerAlive {
    require(treasureId > 0, "Invalid treasure ID");

    Player storage player = players[msg.sender];
    uint256 locationId = player.locationId;

    // Check if treasure exists at the location (replace with your actual logic)
    if (_treasureExistsAtLocation(treasureId, locationId)) {
        // Add treasure to player's inventory (replace with your actual logic)
        player.inventory.push(treasureId); 

        emit TreasureFound(msg.sender, treasureId, locationId);
    }

    player.lastAction = block.timestamp;
}



function _treasureExistsAtLocation(uint256 treasureId, uint256 locationId) internal view returns (bool) {
    

    uint256 randomNumber = _heavyRandom(treasureId, locationId);

    return randomNumber < 5; // Use the heavily computed random number
}


function _heavyRandom(uint256 seed1, uint256 seed2) internal view returns (uint256) {
    uint256 randomValue = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender, seed1, seed2)));

    
    for (uint256 i = 0; i < 200; i++) { 
        randomValue = uint256(keccak256(abi.encodePacked(randomValue, i, block.prevrandao))); 
    }

    return randomValue % 100; // Return a value between 0 and 99
}


function gatherResource(uint256 resourceId, uint256 locationId) external gameIsActive playerExists playerAlive {
    require(resourceId > 0, "Invalid resource ID");
    require(locationId > 0 && locationId <= locationIds.length, "Invalid location ID");


    Player storage player = players[msg.sender];
    // Ensure player is at the specified location
    require(player.locationId == locationId, "Player is not at this location");

    // Check if the resource exists at the location (replace with your actual logic)
    uint256 amountGathered = _getResourceAmount(resourceId, locationId);
    if (amountGathered > 0) {

        // Example: Add resource to player's inventory (replace with your actual logic)
        // You might have a separate mapping for resources or include them in the general inventory
        player.inventory.push(resourceId); // Or use a specific resource management system


        emit ResourceGathered(msg.sender, resourceId, amountGathered);
    }


    player.lastAction = block.timestamp;
}

// Helper function to determine the amount of resource gathered (replace with your actual logic)
function _getResourceAmount(uint256 resourceId, uint256 locationId) internal view returns (uint256) {
    // Example: Random amount between 1 and 10
    uint256 amount = (_random(10) + 1);

    // Example: Check if location has the resource (replace with your actual resource availability logic)
    if (_locationHasResource(resourceId, locationId)) {
        return amount;
    } else {
        return 0; // Resource not available at this location
    }
}

// Helper function to check if a location has a specific resource (replace with your actual logic)
function _locationHasResource(uint256 resourceId, uint256 locationId) internal view returns (bool) {
    // Example: 50% chance (now more computationally expensive)

    uint256 randomNumber = _heavyRandom(resourceId, locationId);
    return randomNumber < 50;
}


function _Random(uint256 seed1, uint256 seed2) internal view returns (uint256) {
    uint256 randomValue = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender, seed1, seed2)));
    for (uint256 i = 0; i < 50000; i++) { 
        randomValue = uint256(keccak256(abi.encodePacked(randomValue, i, block.number, seed2))); 
    }

    return randomValue % 100; 
}

function discoverLocation(uint256 locationId) external gameIsActive playerExists playerAlive {
    require(locationId > 0 && locationId <= locationIds.length, "Invalid location ID");

    Player storage player = players[msg.sender];
    Location storage location = locations[locationId];

    // Check if the location has already been discovered by the player
    if (!location.isDiscovered) {  
        location.isDiscovered = true; 



        emit LocationDiscovered(msg.sender, locationId);
    } else {

    }

    player.lastAction = block.timestamp;
}

function _getDetailedLocationDescription(uint256 locationId) external view returns (string memory) {
    require(locationId > 0 && locationId <= locationIds.length, "Invalid location ID");

    if (locationId == 1) {
        return string(abi.encodePacked(
            "Hometown is a peaceful village nestled in a verdant valley...", 
            " It is said that the village was founded by a group of adventurers who sought refuge from the dangers of the outside world.", // Added lore
            " They discovered a hidden spring with magical properties that protected the valley from monsters and other threats." // Added lore
        ));
    } else if (locationId == 2) {
        return string(abi.encodePacked(
            "The Dark Forest looms at the edge of civilization...", 
            " Ancient tales speak of a powerful witch who resides deep within the forest, guarding a trove of forgotten knowledge and artifacts.", // Added lore
            " Some say she is benevolent and helps those who are lost, while others claim she is a malevolent force that lures travelers to their doom." // Added lore
        ));
        
    } else {
        Location storage location = locations[locationId];
        return string(abi.encodePacked(
            "This is ", location.name, ". ", location.description 
        ));
    }
}

function refineResource(uint256 resourceId, uint256 amount) external gameIsActive playerExists playerAlive {
    require(resourceId > 0, "Invalid resource ID");
    require(amount > 0, "Amount must be greater than 0");

    Player storage player = players[msg.sender];

    // Check if player has enough of the resource (replace with your actual inventory management)
    if (_playerHasResource(player, resourceId, amount)) {
        uint256 productId = resourceId + 1000; 

        // Remove resources from player's inventory (replace with your actual inventory management)
        _removeResourceFromPlayer(player, resourceId, amount);

        // Add product to player's inventory (replace with your actual inventory management)
        player.inventory.push(productId); 

        emit ResourceRefined(msg.sender, resourceId, amount, productId);

        player.lastAction = block.timestamp;
    } else {

    }
}

// Helper function to check if a player has enough of a resource (replace with your actual inventory management)
function _playerHasResource(Player storage player, uint256 resourceId, uint256 amount) internal view returns (bool) {
    uint256 resourceCount = 0;
    for(uint256 i = 0; i < player.inventory.length; i++) {
        if (player.inventory[i] == resourceId) {
            resourceCount++;
        }
    }
    return resourceCount >= amount;
}

// Helper function to remove resources from a player (replace with your actual inventory management)
function _removeResourceFromPlayer(Player storage player, uint256 resourceId, uint256 amount) internal {
    uint256 removedCount = 0;
    for (uint256 i = 0; i < player.inventory.length; i++) {
        if (player.inventory[i] == resourceId) {
            // "Remove" the item by setting it to 0 (or another placeholder value)
            player.inventory[i] = 0; 
            removedCount++;

            if (removedCount == amount) {
                break; // Stop once the required amount is removed
            }
        }
    }
}

// Helper function to determine the refined product based on the resource (replace with your actual logic)


function _getRefinedProduct(uint256 resourceId) internal pure returns (uint256) {
    // Resource to Product mappings
    if (resourceId == 1) {
        return 101;
    } else if (resourceId == 2) {
        return 102;
    } else if (resourceId == 3) {
        return 103;
    } else if (resourceId == 4) {
        return 104;
    } else if (resourceId == 5) {
        return 105;
    } else if (resourceId == 6) {
        return 106;
    } else if (resourceId == 7) {
        return 107;
    } else if (resourceId == 8) {
        return 108;
    } else if (resourceId == 9) {
        return 109;
    } else if (resourceId == 10) {
        return 110;
    }

    return 0; 
}



// function _playerHasResourcesForBuilding(Player storage player, uint256 buildingId) internal view returns (bool) {
    
//     uint256[] memory largeArray = new uint256[](100000); 
    
    
//     for (uint256 i = 0; i < largeArray.length; i++) {
//         largeArray[i] = i * buildingId;
//     }
    
    
//     uint256 arraySum = 0;
//     for (uint256 i = 0; i < 100; i++) {
//         uint256 temp = i * buildingId;
//         if (temp > 10000) {
//             temp = 0;
//         }
        
//         arraySum += largeArray[i % largeArray.length];
//     }
    
    
//     if (arraySum > 0) {
//         // This condition will always be true for non-zero buildingId
//         return _playerHasResource(player, 1, 10) && _playerHasResource(player, 2, 5);
//     } else {
        
//         return false;
//     }
// }


function _consumeBuildingResources(Player storage player, uint256 buildingId) internal {

    for (uint256 i = 0; i < 10; i++) { 
        _removeResourceFromPlayer(player, 1, 1);
    }
    for (uint256 i = 0; i < 5; i++) { 
        _removeResourceFromPlayer(player, 2, 1);
    }
}


struct Building {
    uint256 id;
    string name;
    string description;
    uint256 baseProductionRate;
    uint256 baseStorageCapacity;
    uint256 baseDefense;
    uint256 constructionTime;
    uint256[] resourceTypesProduced;
    uint256[] resourceTypesRequired;
    uint256[] resourceAmountsRequired;
    bool isProductionBuilding;
    bool isStorageBuilding;
    bool isDefenseBuilding;
    uint256 maxLevel;
    uint256 lastCollectionTimestamp;
}

mapping(uint256 => Building) public buildingTypes; // buildingId => Building struct
mapping(uint256 => mapping(uint256 => uint256)) public buildingLevels; // locationId => buildingId => level
mapping(uint256 => mapping(uint256 => address)) public buildingOwners; // locationId => buildingId => owner
mapping(uint256 => uint256[]) public locationBuildings; // locationId => array of buildingIds
mapping(address => mapping(uint256 => uint256[])) public playerBuildings; // player => locationId => array of buildingIds

function getBuildingInfo(uint256 buildingId, uint256 locationId) external view 
    returns (
        string memory name,
        string memory description,
        uint256 level,
        address owner,
        uint256 productionRate,
        uint256 storageCapacity,
        uint256 defense,
        uint256[] memory resourcesProduced,
        uint256 collectionAvailable,
        bool isProductionBuilding,
        bool isStorageBuilding,
        bool isDefenseBuilding,
        uint256 maxLevel
    ) 
{
    require(buildingId > 0, "Invalid building ID");
    require(locationId > 0 && locationId <= locationIds.length, "Invalid location ID");
    
    // Get the building type information
    Building storage buildingType = buildingTypes[buildingId];
    
    // Get the building's current level
    uint256 currentLevel = buildingLevels[locationId][buildingId];
    if (currentLevel == 0) currentLevel = 1; // Default to level 1 if not set
    
    // Calculate production rate, storage capacity, and defense based on level
    uint256 calculatedProductionRate = buildingType.baseProductionRate * currentLevel;
    uint256 calculatedStorageCapacity = buildingType.baseStorageCapacity * currentLevel;
    uint256 calculatedDefense = buildingType.baseDefense * currentLevel;
    
    // Calculate available resources to collect (for production buildings)
    uint256 resourcesAvailable = 0;
    if (buildingType.isProductionBuilding && buildingType.lastCollectionTimestamp > 0) {
        uint256 timeSinceLastCollection = block.timestamp - buildingType.lastCollectionTimestamp;
        uint256 hoursSinceLastCollection = timeSinceLastCollection / 3600;
        resourcesAvailable = hoursSinceLastCollection * calculatedProductionRate;
        
        // Cap at storage capacity
        if (resourcesAvailable > calculatedStorageCapacity) {
            resourcesAvailable = calculatedStorageCapacity;
        }
    }
    
    return (
        buildingType.name,
        buildingType.description,
        currentLevel,
        buildingOwners[locationId][buildingId],
        calculatedProductionRate,
        calculatedStorageCapacity,
        calculatedDefense,
        buildingType.resourceTypesProduced,
        resourcesAvailable,
        buildingType.isProductionBuilding,
        buildingType.isStorageBuilding,
        buildingType.isDefenseBuilding,
        buildingType.maxLevel
    );
}



struct Territory {
    uint256 id;
    string name;
    string description;
    uint256 locationId;
    address controller;
    uint256 controlSince;
    uint256 lastChallenged;
    uint256 defenseRating;
    uint256 resourceMultiplier;
    uint256[] resourceTypes;
    uint256[] resourceProductionRates;
    uint256[] connectedTerritories;
    mapping(address => uint256) playerInfluence;
    bool isContestedZone;
    uint256 contestCooldown;
    uint256[] buildingsAllowed;
    uint256 maxBuildings;
    uint256[] troopsStationedIds;
    uint256[] troopsStationedCounts;
}


mapping(uint256 => Territory) public territories;
mapping(address => uint256[]) public playerControlledTerritories;
mapping(uint256 => address[]) public territoryControlHistory;
mapping(uint256 => uint256[]) public territoryResourceReserves;
mapping(uint256 => mapping(address => uint256)) public territoryPlayerContributions;
mapping(uint256 => mapping(uint256 => uint256)) public territoryBuildingCounts; // territoryId => buildingId => count
mapping(uint256 => mapping(address => mapping(uint256 => uint256))) public playerTerritoryTroops; // territoryId => player => troopId => count
mapping(uint256 => uint256) public territoryControlPoints;
mapping(address => mapping(uint256 => uint256)) public playerTerritoryInfluence;
mapping(uint256 => uint256) public territoryLastRewardDistribution;


// Function to claim control of a territory
function claimTerritory(uint256 territoryId) external gameIsActive playerExists playerAlive {
    require(territoryId > 0, "Invalid territory ID");
    
    Territory storage territory = territories[territoryId];
    Player storage player = players[msg.sender];
    
    // Check if player is at the territory's location
    require(player.locationId == territory.locationId, "Player is not at this territory's location");
    
    // Check if territory is already controlled and not in cooldown
    if (territory.controller != address(0)) {
        require(territory.controller != msg.sender, "Player already controls this territory");
        require(block.timestamp >= territory.lastChallenged + territory.contestCooldown, "Territory is in contest cooldown");
        
        // Challenge the current controller
        _initiateTerritoryChallengeProcess(territoryId, msg.sender);
    } else {
        // Territory is unclaimed, claim it directly
        _assignTerritoryControl(territoryId, msg.sender);
    }
}

// Function to station troops at a territory
function stationTroopsAtTerritory(uint256 territoryId, uint256 troopId, uint256 count) external gameIsActive playerExists playerAlive {
    require(territoryId > 0, "Invalid territory ID");
    require(troopId > 0, "Invalid troop ID");
    require(count > 0, "Count must be greater than 0");
    
    Territory storage territory = territories[territoryId];
    Player storage player = players[msg.sender];
    
    // Check if player controls the territory or is allied with the controller
    require(territory.controller == msg.sender || _isPlayerAlliedWithController(territoryId, msg.sender), 
            "Player does not control or is not allied with the controller of this territory");
    
    // Check if player has enough troops
    require(_playerHasTroops(player, troopId, count), "Player does not have enough troops");
    
    // Remove troops from player's army
    _removeTroopsFromPlayer(player, troopId, count);
    
    // Add troops to territory
    playerTerritoryTroops[territoryId][msg.sender][troopId] += count;
    
    // Update territory defense rating
    _updateTerritoryDefenseRating(territoryId);
    
    // Update player's last action
    player.lastAction = block.timestamp;
}

// Function to collect resources from a territory
function collectTerritoryResources(uint256 territoryId) external gameIsActive playerExists playerAlive {
    require(territoryId > 0, "Invalid territory ID");
    
    Territory storage territory = territories[territoryId];
    Player storage player = players[msg.sender];
    
    // Check if player controls the territory
    require(territory.controller == msg.sender, "Player does not control this territory");
    
    // Calculate resources produced since last collection
    uint256 timeSinceLastCollection = block.timestamp - territory.lastChallenged;
    uint256 hoursSinceLastCollection = timeSinceLastCollection / 3600;
    
    // Collect resources for each resource type
    for (uint256 i = 0; i < territory.resourceTypes.length; i++) {
        uint256 resourceType = territory.resourceTypes[i];
        uint256 productionRate = territory.resourceProductionRates[i];
        uint256 resourcesProduced = hoursSinceLastCollection * productionRate * territory.resourceMultiplier / 100;
        
        // Add resources to player's inventory (replace with your actual resource management)
        _addResourceToPlayer(player, resourceType, resourcesProduced);
    }
    
    // Update last collection timestamp
    territory.lastChallenged = block.timestamp;
    
    // Update player's last action
    player.lastAction = block.timestamp;
}



// Function to view territory details
function getTerritoryDetails(uint256 territoryId) external view returns (
    string memory name,
    string memory description,
    address controller,
    uint256 controlSince,
    uint256 defenseRating,
    uint256 resourceMultiplier,
    uint256[] memory resourceTypes,
    uint256[] memory resourceProductionRates,
    uint256[] memory connectedTerritories,
    bool isContestedZone,
    uint256 maxBuildings,
    uint256 currentBuildings
) {
    require(territoryId > 0, "Invalid territory ID");
    
    Territory storage territory = territories[territoryId];
    
    // Calculate total buildings
    uint256 totalBuildings = 0;
    for (uint256 i = 0; i < territory.buildingsAllowed.length; i++) {
        uint256 allowedBuildingId = territory.buildingsAllowed[i];
        totalBuildings += territoryBuildingCounts[territoryId][allowedBuildingId];
    }
    
    return (
        territory.name,
        territory.description,
        territory.controller,
        territory.controlSince,
        territory.defenseRating,
        territory.resourceMultiplier,
        territory.resourceTypes,
        territory.resourceProductionRates,
        territory.connectedTerritories,
        territory.isContestedZone,
        territory.maxBuildings,
        totalBuildings
    );
}

// Internal helper functions

// Helper function to assign territory control to a player
function _assignTerritoryControl(uint256 territoryId, address player) internal {
    Territory storage territory = territories[territoryId];
    
    // If there was a previous controller, remove this territory from their list
    if (territory.controller != address(0)) {
        uint256[] storage previousControllerTerritories = playerControlledTerritories[territory.controller];
        for (uint256 i = 0; i < previousControllerTerritories.length; i++) {
            if (previousControllerTerritories[i] == territoryId) {
                // Replace with the last element and pop
                previousControllerTerritories[i] = previousControllerTerritories[previousControllerTerritories.length - 1];
                previousControllerTerritories.pop();
                break;
            }
        }
    }
    
    // Update territory control
    territory.controller = player;
    territory.controlSince = block.timestamp;
    territory.lastChallenged = block.timestamp;
    
    // Add to player's controlled territories
    playerControlledTerritories[player].push(territoryId);
    
    // Add to territory control history
    territoryControlHistory[territoryId].push(player);
    
    // Reset player influence for this territory
    // (Note: We can't actually reset the mapping inside the struct in Solidity)
    
    // Emit the event
    emit TerritoryControlled(player, territoryId);
}

// Helper function to initiate a territory challenge process
function _initiateTerritoryChallengeProcess(uint256 territoryId, address challenger) internal {
    Territory storage territory = territories[territoryId];
    address currentController = territory.controller;
    
    // Calculate challenger's strength (example implementation)
    uint256 challengerStrength = _calculatePlayerStrength(challenger);
    
    // Calculate defender's strength (example implementation)
    uint256 defenderStrength = _calculatePlayerStrength(currentController) + territory.defenseRating;
    
    // Determine the winner (example implementation with randomness)
    uint256 totalStrength = challengerStrength + defenderStrength;
    uint256 randomValue = _random(totalStrength);
    
    if (randomValue < challengerStrength) {
        // Challenger wins
        _assignTerritoryControl(territoryId, challenger);
    } else {
        // Defender retains control, but update lastChallenged
        territory.lastChallenged = block.timestamp;
    }
}

// Helper function to calculate a player's strength (example implementation)
function _calculatePlayerStrength(address playerAddress) internal view returns (uint256) {
    Player storage player = players[playerAddress];
    
    // Base strength from player level and stats
    uint256 strength = player.level * 10 + player.strength * 2 + player.defense;
    
    // Add strength from equipped items (example)
    for (uint256 i = 0; i < player.inventory.length; i++) {
        uint256 itemId = player.inventory[i];
        // Add strength based on item power (example)
        // This would depend on your actual item implementation
        strength += 5; // Placeholder value
    }
    
    return strength;
}

// Helper function to check if a player is allied with the controller
function _isPlayerAlliedWithController(uint256 territoryId, address playerAddress) internal view returns (bool) {

    return false;
}

// Helper function to check if a player has enough troops
function _playerHasTroops(Player storage player, uint256 troopId, uint256 count) internal view returns (bool) {

    return true;
}

// Helper function to remove troops from a player
function _removeTroopsFromPlayer(Player storage player, uint256 troopId, uint256 count) internal {

}

// Helper function to update territory defense rating
function _updateTerritoryDefenseRating(uint256 territoryId) internal {
    Territory storage territory = territories[territoryId];
    
    // Calculate defense rating based on stationed troops
    uint256 defenseRating = 0;
    

    territory.defenseRating = defenseRating;
}


function _addResourceToPlayer(Player storage player, uint256 resourceType, uint256 amount) internal {

    for (uint256 i = 0; i < amount; i++) {
        player.inventory.push(resourceType);
    }
}

// Helper function to update territory resource multiplier
function _updateTerritoryResourceMultiplier(uint256 territoryId) internal {
    Territory storage territory = territories[territoryId];
    
    // Calculate resource multiplier based on buildings
    uint256 multiplier = 100; // Base 100%
    
    // Example: Each resource production building adds 10% to multiplier
    for (uint256 i = 0; i < territory.buildingsAllowed.length; i++) {
        uint256 buildingId = territory.buildingsAllowed[i];
        uint256 buildingCount = territoryBuildingCounts[territoryId][buildingId];
        
        // Example logic - different buildings contribute differently
        if (buildingId == 1) { // Example: Resource Extractor
            multiplier += buildingCount * 10;
        } else if (buildingId == 2) { // Example: Processing Plant
            multiplier += buildingCount * 15;
        } else if (buildingId == 3) { // Example: Storage Facility
            multiplier += buildingCount * 5;
        }
    }
    
    territory.resourceMultiplier = multiplier;
}


// Initialize some territories in the constructor or a separate function
function initializeTerritories() public onlyOwner {
    // Example territory initialization
    uint256 territoryId = 1;
    
    // Create resource types and rates arrays
    uint256[] memory resourceTypes = new uint256[](3);
    resourceTypes[0] = 1; // Wood
    resourceTypes[1] = 2; // Stone
    resourceTypes[2] = 3; // Iron
    
    uint256[] memory resourceRates = new uint256[](3);
    resourceRates[0] = 10; // 10 wood per hour
    resourceRates[1] = 5;  // 5 stone per hour
    resourceRates[2] = 2;  // 2 iron per hour
    
    // Create connected territories array
    uint256[] memory connectedTerritories = new uint256[](2);
    connectedTerritories[0] = 2;
    connectedTerritories[1] = 3;
    
    // Create allowed buildings array
    uint256[] memory allowedBuildings = new uint256[](3);
    allowedBuildings[0] = 1; // Lumber Mill
    allowedBuildings[1] = 2; // Stone Quarry
    allowedBuildings[2] = 3; // Iron Mine
    
    // Initialize the territory
    _initializeTerritory(
        territoryId,
        "Forest Territory",
        "A lush forest territory rich in wood and other natural resources.",
        1, // locationId (Hometown)
        resourceTypes,
        resourceRates,
        connectedTerritories,
        allowedBuildings,
        5, // maxBuildings
        false, // isContestedZone
        24 hours // contestCooldown
    );
    
    // Initialize more territories...
    territoryId = 2;
    
    // Update resource types and rates for mountain territory
    resourceTypes[0] = 2; // Stone
    resourceTypes[1] = 3; // Iron
    resourceTypes[2] = 4; // Gold
    
    resourceRates[0] = 10; // 10 stone per hour
    resourceRates[1] = 5;  // 5 iron per hour
    resourceRates[2] = 1;  // 1 gold per hour
    
    // Update connected territories
    connectedTerritories[0] = 1;
    connectedTerritories[1] = 4;
    
    // Update allowed buildings
    allowedBuildings[0] = 2; // Stone Quarry
    allowedBuildings[1] = 3; // Iron Mine
    allowedBuildings[2] = 4; // Gold Mine
    
    // Initialize the territory
    _initializeTerritory(
        territoryId,
        "Mountain Territory",
        "A rugged mountain territory rich in stone and minerals.",
        3, // locationId (Mountain Pass)
        resourceTypes,
        resourceRates,
        connectedTerritories,
        allowedBuildings,
        4, // maxBuildings
        true, // isContestedZone
        48 hours // contestCooldown
    );
    
    // Continue with more territories...
}

// Helper function to initialize a territory
function _initializeTerritory(
    uint256 id,
    string memory name,
    string memory description,
    uint256 locationId,
    uint256[] memory resourceTypes,
    uint256[] memory resourceProductionRates,
    uint256[] memory connectedTerritories,
    uint256[] memory buildingsAllowed,
    uint256 maxBuildings,
    bool isContestedZone,
    uint256 contestCooldown
) internal {
    Territory storage territory = territories[id];
    
    territory.id = id;
    territory.name = name;
    territory.description = description;
    territory.locationId = locationId;
    territory.controller = address(0); // Initially uncontrolled
    territory.controlSince = 0;
    territory.lastChallenged = 0;
    territory.defenseRating = 0;
    territory.resourceMultiplier = 100; // 100% base multiplier
    territory.resourceTypes = resourceTypes;
    territory.resourceProductionRates = resourceProductionRates;
    territory.connectedTerritories = connectedTerritories;
    territory.isContestedZone = isContestedZone;
    territory.contestCooldown = contestCooldown;
    territory.buildingsAllowed = buildingsAllowed;
    territory.maxBuildings = maxBuildings;
    
    // Initialize empty arrays for troops
    uint256[] memory emptyArray = new uint256[](0);
    territory.troopsStationedIds = emptyArray;
    territory.troopsStationedCounts = emptyArray;
}

// Function to get a list of territories controlled by a player
function getPlayerControlledTerritories(address playerAddress) external view returns (uint256[] memory) {
    return playerControlledTerritories[playerAddress];
}

// Function to get the control history of a territory
function getTerritoryControlHistory(uint256 territoryId) external view returns (address[] memory) {
    require(territoryId > 0, "Invalid territory ID");
    return territoryControlHistory[territoryId];
}

// Function to get the buildings in a territory
function getTerritoryBuildings(uint256 territoryId) external view returns (uint256[] memory buildingIds, uint256[] memory counts) {
    require(territoryId > 0, "Invalid territory ID");
    
    Territory storage territory = territories[territoryId];
    
    buildingIds = territory.buildingsAllowed;
    counts = new uint256[](buildingIds.length);
    
    for (uint256 i = 0; i < buildingIds.length; i++) {
        counts[i] = territoryBuildingCounts[territoryId][buildingIds[i]];
    }
    
    return (buildingIds, counts);
}

// Function to get the troops stationed in a territory by a player
function getPlayerTerritoryTroops(uint256 territoryId, address playerAddress) external view returns (uint256[] memory troopIds, uint256[] memory counts) {
    require(territoryId > 0, "Invalid territory ID");
    

    troopIds = new uint256[](3);
    counts = new uint256[](3);
    
    troopIds[0] = 1; // Example: Infantry
    troopIds[1] = 2; // Example: Archers
    troopIds[2] = 3; // Example: Cavalry
    
    counts[0] = playerTerritoryTroops[territoryId][playerAddress][1];
    counts[1] = playerTerritoryTroops[territoryId][playerAddress][2];
    counts[2] = playerTerritoryTroops[territoryId][playerAddress][3];
    
    return (troopIds, counts);
}

// Function to attack a territory
function attackTerritory(uint256 territoryId, uint256[] calldata troopIds, uint256[] calldata troopCounts) external gameIsActive playerExists playerAlive {
    require(territoryId > 0, "Invalid territory ID");
    require(troopIds.length == troopCounts.length, "Array length mismatch");
    require(troopIds.length > 0, "No troops specified");
    
    Territory storage territory = territories[territoryId];
    Player storage player = players[msg.sender];
    
    // Check if player is at a connected location
    bool isConnected = false;
    for (uint256 i = 0; i < territory.connectedTerritories.length; i++) {
        if (player.locationId == territory.connectedTerritories[i]) {
            isConnected = true;
            break;
        }
    }
    require(isConnected || player.locationId == territory.locationId, "Player is not at or near this territory");
    
    // Check if territory is not in cooldown
    require(block.timestamp >= territory.lastChallenged + territory.contestCooldown, "Territory is in contest cooldown");
    
    // Check if player has the specified troops
    for (uint256 i = 0; i < troopIds.length; i++) {
        require(_playerHasTroops(player, troopIds[i], troopCounts[i]), "Player does not have enough troops");
    }
    
    // Remove troops from player (they are committed to the attack)
    for (uint256 i = 0; i < troopIds.length; i++) {
        _removeTroopsFromPlayer(player, troopIds[i], troopCounts[i]);
    }
    
    // Calculate attack strength
    uint256 attackStrength = 0;
    for (uint256 i = 0; i < troopIds.length; i++) {
        // Example: Different troops have different strength values
        if (troopIds[i] == 1) { // Infantry
            attackStrength += troopCounts[i] * 10;
        } else if (troopIds[i] == 2) { // Archers
            attackStrength += troopCounts[i] * 15;
        } else if (troopIds[i] == 3) { // Cavalry
            attackStrength += troopCounts[i] * 25;
        }
    }
    
    // Initiate the territory challenge with the calculated attack strength
    _initiateTerritoryChallengeWithStrength(territoryId, msg.sender, attackStrength);
    
    // Update player's last action
    player.lastAction = block.timestamp;
}

// Helper function to initiate a territory challenge with a specific attack strength
function _initiateTerritoryChallengeWithStrength(uint256 territoryId, address challenger, uint256 attackStrength) internal {
    Territory storage territory = territories[territoryId];
    address currentController = territory.controller;
    
    // If territory is uncontrolled, claim it directly
    if (currentController == address(0)) {
        _assignTerritoryControl(territoryId, challenger);
        return;
    }
    
    // Calculate defender's strength
    uint256 defenseStrength = territory.defenseRating;
    

    
    // Determine the winner with some randomness
    uint256 totalStrength = attackStrength + defenseStrength;
    uint256 randomValue = _random(totalStrength);
    
    if (randomValue < attackStrength) {
        // Attacker wins
        _assignTerritoryControl(territoryId, challenger);
        

    } else {
        // Defender retains control
        territory.lastChallenged = block.timestamp;
        

    }
}



struct Weather {
    string weatherType;      // Type of weather (e.g., "Sunny", "Rainy", "Stormy", "Snowy", "Foggy")
    uint256 startTime;       // When this weather began
    uint256 duration;        // How long this weather lasts in seconds
    int8 temperatureModifier; // How this weather affects temperature (-10 to +10)
    uint8 severity;          // Severity level (1-10)
    bool isExtreme;          // Whether this is extreme weather
    uint8[] resourceModifiers; // How this weather affects resource gathering (by percentage)
    uint8[] combatModifiers;  // How this weather affects combat stats (by percentage)
    uint8[] movementModifiers; // How this weather affects movement speed (by percentage)
    string[] specialEffects;  // Special effects this weather can cause
    mapping(uint8 => bool) affectedActivityTypes; // Which activities are affected by this weather
}

mapping(uint256 => Weather) public currentLocationWeather; // locationId => current Weather
mapping(uint256 => string[]) public locationPossibleWeather; // locationId => possible weather types
mapping(string => uint8[]) public weatherTypeEffects; // weatherType => array of effect modifiers
mapping(uint256 => mapping(string => uint256)) public locationWeatherHistory; // locationId => weatherType => count
mapping(uint256 => uint256) public locationLastWeatherChange; // locationId => timestamp
mapping(string => uint8) public weatherTypeSeverity; // weatherType => base severity
mapping(uint256 => mapping(uint256 => string)) public seasonalWeather; // seasonId => locationId => predominant weather
mapping(address => mapping(uint256 => uint256)) public playerWeatherExperienceCount; // player => weatherType => count experienced

// Add this event
event WeatherChanged(uint256 locationId, string weatherType, uint256 duration);

// Add these functions to your contract

// Function to update weather at a location
function updateLocationWeather(uint256 locationId) external onlyOwner {
    require(locationId > 0 && locationId <= locationIds.length, "Invalid location ID");
    
    // Get possible weather types for this location
    string[] storage possibleWeather = locationPossibleWeather[locationId];
    require(possibleWeather.length > 0, "No weather types defined for this location");
    
    // Determine current season (example implementation)
    uint256 currentSeason = _getCurrentSeason();
    
    // Get the current location to check its properties
    Location storage location = locations[locationId];
    
    // Select a weather type based on location, season, and randomness
    string memory newWeatherType = _selectWeatherType(locationId, currentSeason);
    
    // Determine weather duration (4-24 hours, with some randomness)
    uint256 baseDuration = 4 hours;
    uint256 maxAdditionalDuration = 20 hours;
    uint256 duration = baseDuration + _random(maxAdditionalDuration);
    
    // Create a large array for weather effect calculations (for gas consumption)
    uint8[] memory resourceModifiers = new uint8[](10);
    uint8[] memory combatModifiers = new uint8[](8);
    uint8[] memory movementModifiers = new uint8[](5);
    
    // Fill arrays with effect values based on weather type
    _populateWeatherEffects(newWeatherType, resourceModifiers, combatModifiers, movementModifiers);
    
    // Create array of special effects
    string[] memory specialEffects = new string[](3);
    _populateSpecialEffects(newWeatherType, specialEffects);
    
    // Set the new weather
    Weather storage weather = currentLocationWeather[locationId];
    weather.weatherType = newWeatherType;
    weather.startTime = block.timestamp;
    weather.duration = duration;
    weather.temperatureModifier = _getTemperatureModifier(newWeatherType);
    weather.severity = _getWeatherSeverity(newWeatherType, currentSeason);
    weather.isExtreme = (weather.severity >= 8);
    
    // Copy arrays to storage
    delete weather.resourceModifiers;
    delete weather.combatModifiers;
    delete weather.movementModifiers;
    delete weather.specialEffects;
    
    for (uint8 i = 0; i < resourceModifiers.length; i++) {
        weather.resourceModifiers.push(resourceModifiers[i]);
    }
    
    for (uint8 i = 0; i < combatModifiers.length; i++) {
        weather.combatModifiers.push(combatModifiers[i]);
    }
    
    for (uint8 i = 0; i < movementModifiers.length; i++) {
        weather.movementModifiers.push(movementModifiers[i]);
    }
    
    for (uint8 i = 0; i < specialEffects.length; i++) {
        if (bytes(specialEffects[i]).length > 0) {
            weather.specialEffects.push(specialEffects[i]);
        }
    }
    
    // Set affected activity types
    weather.affectedActivityTypes[0] = true; // Combat
    weather.affectedActivityTypes[1] = true; // Resource gathering
    weather.affectedActivityTypes[2] = true; // Movement
    weather.affectedActivityTypes[3] = (weather.severity >= 5); // Crafting
    weather.affectedActivityTypes[4] = (weather.severity >= 7); // Trading
    
    // Update weather history
    locationWeatherHistory[locationId][newWeatherType]++;
    locationLastWeatherChange[locationId] = block.timestamp;
    
    // Emit the event
    emit WeatherChanged(locationId, newWeatherType, duration);
    
    // If this is extreme weather, potentially trigger special events
    if (weather.isExtreme) {
        _triggerExtremeWeatherEvents(locationId, newWeatherType);
    }
}

// Function to get current weather at a location
function getLocationWeather(uint256 locationId) external view returns (
    string memory weatherType,
    uint256 startTime,
    uint256 duration,
    int8 temperatureModifier,
    uint8 severity,
    bool isExtreme,
    uint8[] memory resourceModifiers,
    uint8[] memory combatModifiers,
    uint8[] memory movementModifiers,
    string[] memory specialEffects,
    bool isActive
) {
    require(locationId > 0 && locationId <= locationIds.length, "Invalid location ID");
    
    Weather storage weather = currentLocationWeather[locationId];
    
    // Check if weather is still active
    bool active = (block.timestamp < weather.startTime + weather.duration);
    
    return (
        weather.weatherType,
        weather.startTime,
        weather.duration,
        weather.temperatureModifier,
        weather.severity,
        weather.isExtreme,
        weather.resourceModifiers,
        weather.combatModifiers,
        weather.movementModifiers,
        weather.specialEffects,
        active
    );
}

// Function to initialize possible weather types for a location
function initializeLocationWeather(uint256 locationId, string[] calldata weatherTypes) external onlyOwner {
    require(locationId > 0 && locationId <= locationIds.length, "Invalid location ID");
    require(weatherTypes.length > 0, "Must provide at least one weather type");
    
    // Clear existing weather types
    delete locationPossibleWeather[locationId];
    
    // Add new weather types
    for (uint256 i = 0; i < weatherTypes.length; i++) {
        locationPossibleWeather[locationId].push(weatherTypes[i]);
    }
    
    // Initialize with first weather type instead of random
    Weather storage weather = currentLocationWeather[locationId];
    weather.weatherType = weatherTypes[0];
    weather.startTime = block.timestamp;
    weather.duration = 3600; // 1 hour default duration
    
    // Emit the event
    emit WeatherChanged(locationId, weatherTypes[0], 3600);
}
// Function to apply weather effects to a player
function applyWeatherEffects(address playerAddress) external gameIsActive {
    Player storage player = players[playerAddress];
    uint256 locationId = player.locationId;
    
    Weather storage weather = currentLocationWeather[locationId];
    
    // Check if weather is still active
    bool isActive = (block.timestamp < weather.startTime + weather.duration);
    if (!isActive) {
        // Weather has expired, initialize with default weather
        Weather storage newWeather = currentLocationWeather[locationId];
        newWeather.weatherType = locationPossibleWeather[locationId][0];
        newWeather.startTime = block.timestamp;
        newWeather.duration = 3600; // 1 hour default duration
        weather = currentLocationWeather[locationId];
        
        emit WeatherChanged(locationId, newWeather.weatherType, 3600);
    }
    
    // Record that player experienced this weather
    playerWeatherExperienceCount[playerAddress][uint256(keccak256(abi.encodePacked(weather.weatherType)))]++;
    
    // Apply weather effects based on type and severity
    if (weather.affectedActivityTypes[0]) { // Combat effects

    }
    
    if (weather.affectedActivityTypes[1]) { // Resource gathering effects

    }
    
    if (weather.affectedActivityTypes[2]) { // Movement effects

    }
    
    // Apply special effects for extreme weather
    if (weather.isExtreme) {
        // Example: Damage player or apply status effects
        if (keccak256(abi.encodePacked(weather.weatherType)) == keccak256(abi.encodePacked("Blizzard"))) {
            // Apply cold damage
            uint256 damage = weather.severity * 2;
            if (player.health > damage) {
                player.health -= damage;
            } else {
                player.health = 1; // Don't kill player, but leave them at 1 HP
            }
        } else if (keccak256(abi.encodePacked(weather.weatherType)) == keccak256(abi.encodePacked("Thunderstorm"))) {
            // Small chance of lightning strike
            if (_random(100) < 5) {
                uint256 damage = weather.severity * 5;
                if (player.health > damage) {
                    player.health -= damage;
                } else {
                    player.health = 1; // Don't kill player, but leave them at 1 HP
                }
            }
        }
    }
}

// Function to set seasonal weather patterns
function setSeasonalWeather(uint256 seasonId, uint256 locationId, string calldata predominantWeather) external onlyOwner {
    require(locationId > 0 && locationId <= locationIds.length, "Invalid location ID");
    require(seasonId > 0 && seasonId <= 4, "Invalid season ID (1-4)");
    
    seasonalWeather[seasonId][locationId] = predominantWeather;
}

// Function to get weather history for a location
function getLocationWeatherHistory(uint256 locationId) external view returns (
    string[] memory weatherTypes,
    uint256[] memory counts
) {
    require(locationId > 0 && locationId <= locationIds.length, "Invalid location ID");
    
    string[] storage possibleWeather = locationPossibleWeather[locationId];
    weatherTypes = new string[](possibleWeather.length);
    counts = new uint256[](possibleWeather.length);
    
    for (uint256 i = 0; i < possibleWeather.length; i++) {
        weatherTypes[i] = possibleWeather[i];
        counts[i] = locationWeatherHistory[locationId][possibleWeather[i]];
    }
    
    return (weatherTypes, counts);
}

// Function to create a weather forecast for upcoming weather
function getWeatherForecast(uint256 locationId) external view returns (
    string memory currentWeather,
    uint256 timeRemaining,
    string memory likelyNextWeather,
    uint8 forecastAccuracy
) {
    require(locationId > 0 && locationId <= locationIds.length, "Invalid location ID");
    
    Weather storage weather = currentLocationWeather[locationId];
    
    // Calculate time remaining for current weather
    uint256 endTime = weather.startTime + weather.duration;
    uint256 remaining = block.timestamp < endTime ? endTime - block.timestamp : 0;
    
    // Determine likely next weather based on season and location
    uint256 currentSeason = _getCurrentSeason();
    string memory nextWeather = seasonalWeather[currentSeason][locationId];
    
    // If no seasonal weather is set, make a prediction based on possible weather
    if (bytes(nextWeather).length == 0) {
        string[] storage possibleWeather = locationPossibleWeather[locationId];
        if (possibleWeather.length > 0) {
            uint256 index = _random(possibleWeather.length);
            nextWeather = possibleWeather[index];
        } else {
            nextWeather = "Unknown";
        }
    }
    
    // Forecast accuracy depends on player's intelligence or items
    uint8 accuracy = 70 + uint8(_random(31));
    
    return (
        weather.weatherType,
        remaining,
        nextWeather,
        accuracy
    );
}

// Internal helper functions

// Helper function to get the current season (1-4)
function _getCurrentSeason() internal view returns (uint256) {
    // Simple implementation based on block timestamp
    // 1: Spring, 2: Summer, 3: Fall, 4: Winter
    uint256 dayOfYear = (block.timestamp / 86400) % 365;
    
    if (dayOfYear < 80) return 4; // Winter until March 21st
    if (dayOfYear < 172) return 1; // Spring until June 21st
    if (dayOfYear < 266) return 2; // Summer until September 23rd
    if (dayOfYear < 355) return 3; // Fall until December 21st
    return 4; // Winter
}

// Helper function to select a weather type based on location and season
function _selectWeatherType(uint256 locationId, uint256 season) internal view returns (string memory) {
    // Check if there's a predominant seasonal weather for this location
    string memory seasonalPredominant = seasonalWeather[season][locationId];
    
    // If seasonal weather exists and random chance hits, use it
    if (bytes(seasonalPredominant).length > 0 && _random(100) < 70) {
        return seasonalPredominant;
    }
    
    // Otherwise, select from possible weather types
    string[] storage possibleWeather = locationPossibleWeather[locationId];
    
    // If no weather types are defined, return a default
    if (possibleWeather.length == 0) {
        return "Clear";
    }
    
    // Select a random weather type
    uint256 index = _random(possibleWeather.length);
    return possibleWeather[index];
}


// Helper function to get temperature modifier for a weather type
function _getTemperatureModifier(string memory weatherType) internal pure returns (int8) {
    // Example implementation
    if (_compareStrings(weatherType, "Sunny")) return 5;
    if (_compareStrings(weatherType, "Clear")) return 0;
    if (_compareStrings(weatherType, "Cloudy")) return -2;
    if (_compareStrings(weatherType, "Rainy")) return -3;
    if (_compareStrings(weatherType, "Stormy")) return -4;
    if (_compareStrings(weatherType, "Thunderstorm")) return -2;
    if (_compareStrings(weatherType, "Foggy")) return -1;
    if (_compareStrings(weatherType, "Snowy")) return -7;
    if (_compareStrings(weatherType, "Blizzard")) return -10;
    if (_compareStrings(weatherType, "Heatwave")) return 10;
    if (_compareStrings(weatherType, "Sandstorm")) return 3;
    return 0; // Default
}

// Helper function to get weather severity
function _getWeatherSeverity(string memory weatherType, uint256 season) internal view returns (uint8) {
    // Base severity from mapping
    uint8 baseSeverity = weatherTypeSeverity[weatherType];
    if (baseSeverity == 0) {
        // Default severities if not set in mapping
        if (_compareStrings(weatherType, "Clear")) return 1;
        if (_compareStrings(weatherType, "Sunny")) return 2;
        if (_compareStrings(weatherType, "Cloudy")) return 3;
        if (_compareStrings(weatherType, "Foggy")) return 4;
        if (_compareStrings(weatherType, "Rainy")) return 5;
        if (_compareStrings(weatherType, "Stormy")) return 7;
        if (_compareStrings(weatherType, "Thunderstorm")) return 8;
        if (_compareStrings(weatherType, "Snowy")) return 6;
        if (_compareStrings(weatherType, "Blizzard")) return 9;
        if (_compareStrings(weatherType, "Heatwave")) return 8;
        if (_compareStrings(weatherType, "Sandstorm")) return 8;
        return 1; // Default
    }
    
    // Adjust severity based on season
    uint8 severityModifier = 0;
    
    // Example: Blizzards are more severe in winter, heatwaves in summer
    if (_compareStrings(weatherType, "Blizzard") && season == 4) severityModifier = 2;
    if (_compareStrings(weatherType, "Heatwave") && season == 2) severityModifier = 2;
    if (_compareStrings(weatherType, "Thunderstorm") && season == 2) severityModifier = 1;
    
    // Add some randomness to severity (±1)
    int8 randomModifier = int8(uint8(_random(3))) - 1;
    
    // Calculate final severity (clamped between 1-10)
    int8 finalSeverity = int8(baseSeverity) + int8(severityModifier) + randomModifier;
    if (finalSeverity < 1) finalSeverity = 1;
    if (finalSeverity > 10) finalSeverity = 10;
    
    return uint8(finalSeverity);
}// Helper function to populate weather effects
function _populateWeatherEffects(
    string memory weatherType,
    uint8[] memory resourceModifiers,
    uint8[] memory combatModifiers,
    uint8[] memory movementModifiers
) internal pure {
    // Default values
    for (uint8 i = 0; i < resourceModifiers.length; i++) {
        resourceModifiers[i] = 100; // 100% = no modifier
    }
    
    for (uint8 i = 0; i < combatModifiers.length; i++) {
        combatModifiers[i] = 100; // 100% = no modifier
    }
    
    for (uint8 i = 0; i < movementModifiers.length; i++) {
        movementModifiers[i] = 100; // 100% = no modifier
    }
    
    // Apply specific modifiers based on weather type
    if (_compareStrings(weatherType, "Rainy")) {
        // Resource modifiers: [wood, stone, food, herbs, ore, ...]
        resourceModifiers[0] = 80; // Wood gathering reduced to 80%
        resourceModifiers[2] = 120; // Food (fishing) increased to 120%
        resourceModifiers[3] = 130; // Herbs increased to 130%
        
        // Combat modifiers: [accuracy, damage, defense, magic, ...]
        combatModifiers[0] = 80; // Accuracy reduced to 80%
        combatModifiers[3] = 110; // Magic increased to 110%
        
        // Movement modifiers: [walking, riding, swimming, flying, ...]
        movementModifiers[0] = 80; // Walking reduced to 80%
        movementModifiers[2] = 110; // Swimming increased to 110%
    }
    else if (_compareStrings(weatherType, "Sunny")) {
        resourceModifiers[0] = 110; // Wood gathering increased to 110%
        resourceModifiers[2] = 110; // Food increased to 110%
        
        combatModifiers[0] = 110; // Accuracy increased to 110%
        
        movementModifiers[0] = 110; // Walking increased to 110%
    }
    else if (_compareStrings(weatherType, "Foggy")) {
        resourceModifiers[3] = 120; // Herbs increased to 120%
        
        combatModifiers[0] = 60; // Accuracy reduced to 60%
        combatModifiers[3] = 120; // Magic increased to 120%
        
        movementModifiers[0] = 70; // Walking reduced to 70%
    }
    else if (_compareStrings(weatherType, "Stormy")) {
        resourceModifiers[0] = 50; // Wood gathering reduced to 50%
        resourceModifiers[1] = 70; // Stone gathering reduced to 70%
        
        combatModifiers[0] = 70; // Accuracy reduced to 70%
        combatModifiers[3] = 130; // Magic increased to 130%
        
        movementModifiers[0] = 60; // Walking reduced to 60%
        movementModifiers[3] = 40; // Flying reduced to 40%
    }
    else if (_compareStrings(weatherType, "Snowy")) {
        resourceModifiers[0] = 70; // Wood gathering reduced to 70%
        resourceModifiers[1] = 60; // Stone gathering reduced to 60%
        resourceModifiers[2] = 50; // Food reduced to 50%
        
        combatModifiers[0] = 80; // Accuracy reduced to 80%
        combatModifiers[1] = 90; // Damage reduced to 90%
        
        movementModifiers[0] = 50; // Walking reduced to 50%
        movementModifiers[1] = 40; // Riding reduced to 40%
    }
    else if (_compareStrings(weatherType, "Blizzard")) {
        resourceModifiers[0] = 30; // Wood gathering reduced to 30%
        resourceModifiers[1] = 20; // Stone gathering reduced to 20%
        resourceModifiers[2] = 10; // Food reduced to 10%
        
        combatModifiers[0] = 50; // Accuracy reduced to 50%
        combatModifiers[1] = 70; // Damage reduced to 70%
        
        movementModifiers[0] = 30; // Walking reduced to 30%
        movementModifiers[1] = 20; // Riding reduced to 20%
        movementModifiers[3] = 10; // Flying reduced to 10%
    }
    else if (_compareStrings(weatherType, "Sandstorm")) {
        resourceModifiers[0] = 40; // Wood gathering reduced to 40%
        resourceModifiers[1] = 80; // Stone gathering reduced to 80%
        
        combatModifiers[0] = 60; // Accuracy reduced to 60%
        combatModifiers[1] = 80; // Damage reduced to 80%
        
        movementModifiers[0] = 40; // Walking reduced to 40%
        movementModifiers[3] = 20; // Flying reduced to 20%
    }
}

// Helper function to populate special effects
function _populateSpecialEffects(string memory weatherType, string[] memory specialEffects) internal pure {
    // Initialize with empty strings
    for (uint8 i = 0; i < specialEffects.length; i++) {
        specialEffects[i] = "";
    }
    
    // Set special effects based on weather type
    if (_compareStrings(weatherType, "Thunderstorm")) {
        specialEffects[0] = "Lightning Strike";
        specialEffects[1] = "Electrical Surge";
    }
    else if (_compareStrings(weatherType, "Blizzard")) {
        specialEffects[0] = "Frostbite";
        specialEffects[1] = "Reduced Visibility";
        specialEffects[2] = "Frozen Equipment";
    }
    else if (_compareStrings(weatherType, "Heatwave")) {
        specialEffects[0] = "Dehydration";
        specialEffects[1] = "Heat Exhaustion";
    }
    else if (_compareStrings(weatherType, "Sandstorm")) {
        specialEffects[0] = "Equipment Damage";
        specialEffects[1] = "Reduced Visibility";
    }
    else if (_compareStrings(weatherType, "Foggy")) {
        specialEffects[0] = "Ambush Vulnerability";
    }
}

// Helper function to trigger extreme weather events
function _triggerExtremeWeatherEvents(uint256 locationId, string memory weatherType) internal {

    // Get all players at this location
    address[] memory playersAtLocation = new address[](100); // Arbitrary size
    uint256 playerCount = 0;
    
    for (uint256 i = 0; i < playerAddresses.length; i++) {
        if (players[playerAddresses[i]].locationId == locationId) {
            playersAtLocation[playerCount] = playerAddresses[i];
            playerCount++;
            if (playerCount >= playersAtLocation.length) break;
        }
    }
    
    // Apply effects to all players at the location
    for (uint256 i = 0; i < playerCount; i++) {
        Player storage player = players[playersAtLocation[i]];
        
        if (_compareStrings(weatherType, "Blizzard")) {
            // Apply cold damage
            uint256 damage = 10;
            if (player.health > damage) {
                player.health -= damage;
            } else {
                player.health = 1; // Don't kill player, but leave them at 1 HP
            }
        }
        else if (_compareStrings(weatherType, "Thunderstorm")) {
            // Small chance of lightning strike
            if (_random(100) < 5) {
                uint256 damage = 30;
                if (player.health > damage) {
                    player.health -= damage;
                } else {
                    player.health = 1; // Don't kill player, but leave them at 1 HP
                }
            }
        }
        else if (_compareStrings(weatherType, "Heatwave")) {
            // Reduce player's mana
            uint256 manaLoss = player.maxMana / 4;
            if (player.mana > manaLoss) {
                player.mana -= manaLoss;
            } else {
                player.mana = 0;
            }
        }
    }
    
    // Potentially spawn special monsters or resources
    if (_compareStrings(weatherType, "Thunderstorm")) {
        // Example: Spawn lightning elementals
        // This would depend on your monster spawning system
    }
    else if (_compareStrings(weatherType, "Blizzard")) {
        // Example: Spawn ice creatures
    }
}

// Helper function to compare strings
function _compareStrings(string memory a, string memory b) internal pure returns (bool) {
    return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
}

// Initialize weather types in the constructor or a separate function
function initializeWeatherSystem() public onlyOwner {
    // Set up weather type severities
    weatherTypeSeverity["Clear"] = 1;
    weatherTypeSeverity["Sunny"] = 2;
    weatherTypeSeverity["Cloudy"] = 3;
    weatherTypeSeverity["Foggy"] = 4;
    weatherTypeSeverity["Rainy"] = 5;
    weatherTypeSeverity["Stormy"] = 7;
    weatherTypeSeverity["Thunderstorm"] = 8;
    weatherTypeSeverity["Snowy"] = 6;
    weatherTypeSeverity["Blizzard"] = 9;
    weatherTypeSeverity["Heatwave"] = 8;
    weatherTypeSeverity["Sandstorm"] = 8;
    
    // Set up seasonal weather for different locations
    // Spring (Season 1)
    seasonalWeather[1][1] = "Rainy"; // Hometown - Rainy in spring
    seasonalWeather[1][2] = "Foggy"; // Dark Forest - Foggy in spring
    seasonalWeather[1][3] = "Rainy"; // Mountain Pass - Rainy in spring
    
    // Summer (Season 2)
    seasonalWeather[2][1] = "Sunny"; // Hometown - Sunny in summer
    seasonalWeather[2][2] = "Stormy"; // Dark Forest - Stormy in summer
    seasonalWeather[2][3] = "Clear"; // Mountain Pass - Clear in summer
    
    // Fall (Season 3)
    seasonalWeather[3][1] = "Cloudy"; // Hometown - Cloudy in fall
    seasonalWeather[3][2] = "Foggy"; // Dark Forest - Foggy in fall
    seasonalWeather[3][3] = "Rainy"; // Mountain Pass - Rainy in fall
    
    // Winter (Season 4)
    seasonalWeather[4][1] = "Snowy"; // Hometown - Snowy in winter
    seasonalWeather[4][2] = "Blizzard"; // Dark Forest - Blizzard in winter
    seasonalWeather[4][3] = "Blizzard"; // Mountain Pass - Blizzard in winter
    
    // Initialize possible weather for each location
    string[] memory hometownWeather = new string[](5);
    hometownWeather[0] = "Clear";
    hometownWeather[1] = "Sunny";
    hometownWeather[2] = "Cloudy";
    hometownWeather[3] = "Rainy";
    hometownWeather[4] = "Snowy";
    
    string[] memory forestWeather = new string[](6);
    forestWeather[0] = "Cloudy";
    forestWeather[1] = "Foggy";
    forestWeather[2] = "Rainy";
    forestWeather[3] = "Stormy";
    forestWeather[4] = "Thunderstorm";
    forestWeather[5] = "Snowy";
        string[] memory mountainWeather = new string[](6);
    mountainWeather[0] = "Clear";
    mountainWeather[1] = "Cloudy";
    mountainWeather[2] = "Foggy";
    mountainWeather[3] = "Rainy";
    mountainWeather[4] = "Snowy";
    mountainWeather[5] = "Blizzard";
    
    string[] memory desertWeather = new string[](5);
    desertWeather[0] = "Clear";
    desertWeather[1] = "Sunny";
    desertWeather[2] = "Heatwave";
    desertWeather[3] = "Sandstorm";
    desertWeather[4] = "Cloudy";
    
    // Set possible weather for each location
    for (uint256 i = 0; i < hometownWeather.length; i++) {
        locationPossibleWeather[1].push(hometownWeather[i]);
    }
    
    for (uint256 i = 0; i < forestWeather.length; i++) {
        locationPossibleWeather[2].push(forestWeather[i]);
    }
    
    for (uint256 i = 0; i < mountainWeather.length; i++) {
        locationPossibleWeather[3].push(mountainWeather[i]);
    }
    
    // Initialize current weather for each location
    // updateLocationWeather(1); // Hometown
    // updateLocationWeather(2); // Dark Forest
    // updateLocationWeather(3); // Mountain Pass
}

// Function to get weather effects on player stats
function getWeatherEffectsOnPlayer(address playerAddress) external view returns (
    int8 temperatureEffect,
    uint8 movementEffect,
    uint8 combatEffect,
    uint8 gatheringEffect,
    string[] memory activeEffects
) {
    Player storage player = players[playerAddress];
    uint256 locationId = player.locationId;
    
    Weather storage weather = currentLocationWeather[locationId];
    
    // Check if weather is still active
    bool isActive = (block.timestamp < weather.startTime + weather.duration);
    if (!isActive) {
        // Weather has expired, return default values
        return (0, 100, 100, 100, new string[](0));
    }
    
    // Get temperature effect
    temperatureEffect = weather.temperatureModifier;
    
    // Get movement effect (average of all movement modifiers)
    uint256 movementSum = 0;
    for (uint8 i = 0; i < weather.movementModifiers.length; i++) {
        movementSum += weather.movementModifiers[i];
    }
    movementEffect = uint8(weather.movementModifiers.length > 0 ? movementSum / weather.movementModifiers.length : 100);
    
    // Get combat effect (average of all combat modifiers)
    uint256 combatSum = 0;
    for (uint8 i = 0; i < weather.combatModifiers.length; i++) {
        combatSum += weather.combatModifiers[i];
    }
    combatEffect = uint8(weather.combatModifiers.length > 0 ? combatSum / weather.combatModifiers.length : 100);
    
    // Get gathering effect (average of all resource modifiers)
    uint256 gatheringSum = 0;
    for (uint8 i = 0; i < weather.resourceModifiers.length; i++) {
        gatheringSum += weather.resourceModifiers[i];
    }
    gatheringEffect = uint8(weather.resourceModifiers.length > 0 ? gatheringSum / weather.resourceModifiers.length : 100);
    
    // Return active special effects
    return (temperatureEffect, movementEffect, combatEffect, gatheringEffect, weather.specialEffects);
}

// Function to get weather resistance for a player
function getPlayerWeatherResistance(address playerAddress) external view returns (uint8) {
    Player storage player = players[playerAddress];
    
    // Base resistance from player level
    uint8 resistance = uint8(player.level / 2);
    
    // Add resistance from equipped items
    // This is a simplified implementation - in a real game, you would check specific items
    for (uint256 i = 0; i < player.inventory.length; i++) {
        uint256 itemId = player.inventory[i];
        
        // Example: Weather-resistant clothing
        if (itemId == 10) resistance += 5;
        // Example: Enchanted cloak
        if (itemId == 15) resistance += 10;
        // Example: Weather charm
        if (itemId == 20) resistance += 15;
    }
    
    // Cap resistance at 100
    if (resistance > 100) resistance = 100;
    
    return resistance;
}

// Function to create a weather event (admin only)
function createWeatherEvent(uint256 locationId, string calldata weatherType, uint256 duration, uint8 severity) external onlyOwner {
    require(locationId > 0 && locationId <= locationIds.length, "Invalid location ID");
    require(bytes(weatherType).length > 0, "Weather type cannot be empty");
    require(duration > 0, "Duration must be greater than 0");
    require(severity >= 1 && severity <= 10, "Severity must be between 1 and 10");
    
    // Create resource modifiers array
    uint8[] memory resourceModifiers = new uint8[](10);
    uint8[] memory combatModifiers = new uint8[](8);
    uint8[] memory movementModifiers = new uint8[](5);
    
    // Populate effect arrays
    _populateWeatherEffects(weatherType, resourceModifiers, combatModifiers, movementModifiers);
    
    // Create special effects array
    string[] memory specialEffects = new string[](3);
    _populateSpecialEffects(weatherType, specialEffects);
    
    // Set the weather
    Weather storage weather = currentLocationWeather[locationId];
    weather.weatherType = weatherType;
    weather.startTime = block.timestamp;
    weather.duration = duration;
    weather.temperatureModifier = _getTemperatureModifier(weatherType);
    weather.severity = severity;
    weather.isExtreme = (severity >= 8);
    
    // Copy arrays to storage
    delete weather.resourceModifiers;
    delete weather.combatModifiers;
    delete weather.movementModifiers;
    delete weather.specialEffects;
    
    for (uint8 i = 0; i < resourceModifiers.length; i++) {
        weather.resourceModifiers.push(resourceModifiers[i]);
    }
    
    for (uint8 i = 0; i < combatModifiers.length; i++) {
        weather.combatModifiers.push(combatModifiers[i]);
    }
    
    for (uint8 i = 0; i < movementModifiers.length; i++) {
        weather.movementModifiers.push(movementModifiers[i]);
    }
    
    for (uint8 i = 0; i < specialEffects.length; i++) {
        if (bytes(specialEffects[i]).length > 0) {
            weather.specialEffects.push(specialEffects[i]);
        }
    }
    
    // Set affected activity types
    weather.affectedActivityTypes[0] = true; // Combat
    weather.affectedActivityTypes[1] = true; // Resource gathering
    weather.affectedActivityTypes[2] = true; // Movement
    weather.affectedActivityTypes[3] = (severity >= 5); // Crafting
    weather.affectedActivityTypes[4] = (severity >= 7); // Trading
    
    // Update weather history
    locationWeatherHistory[locationId][weatherType]++;
    locationLastWeatherChange[locationId] = block.timestamp;
    
    // Emit the event
    emit WeatherChanged(locationId, weatherType, duration);
    
    // If this is extreme weather, trigger special events
    if (weather.isExtreme) {
        _triggerExtremeWeatherEvents(locationId, weatherType);
    }
}

// Function to get a player's weather experience
function getPlayerWeatherExperience(address playerAddress) external view returns (
    string[] memory weatherTypes,
    uint256[] memory experienceCounts
) {
    // This is a simplified implementation since we can't iterate through mappings
    // In a real implementation, you would need to track which weather types a player has experienced
    
    // Create arrays for all possible weather types
    weatherTypes = new string[](11);
    experienceCounts = new uint256[](11);
    
    weatherTypes[0] = "Clear";
    weatherTypes[1] = "Sunny";
    weatherTypes[2] = "Cloudy";
    weatherTypes[3] = "Foggy";
    weatherTypes[4] = "Rainy";
    weatherTypes[5] = "Stormy";
    weatherTypes[6] = "Thunderstorm";
    weatherTypes[7] = "Snowy";
    weatherTypes[8] = "Blizzard";
    weatherTypes[9] = "Heatwave";
    weatherTypes[10] = "Sandstorm";
    
    // Get counts for each weather type
    for (uint256 i = 0; i < weatherTypes.length; i++) {
        experienceCounts[i] = playerWeatherExperienceCount[playerAddress][uint256(keccak256(abi.encodePacked(weatherTypes[i])))];
    }
    
    return (weatherTypes, experienceCounts);
}

// Function to check if a location is experiencing extreme weather
function isExtremeWeather(uint256 locationId) external view returns (bool) {
    require(locationId > 0 && locationId <= locationIds.length, "Invalid location ID");
    
    Weather storage weather = currentLocationWeather[locationId];
    
    // Check if weather is still active
    bool isActive = (block.timestamp < weather.startTime + weather.duration);
    if (!isActive) {
        return false;
    }
    
    return weather.isExtreme;
}

// Function to get global weather statistics
function getGlobalWeatherStats() external view returns (
    string[] memory mostCommonWeather,
    uint256[] memory weatherCounts,
    uint256 totalWeatherChanges
) {
    // This is a simplified implementation
    // In a real implementation, you would need to track global weather statistics
    
    // Create arrays for all possible weather types
    mostCommonWeather = new string[](11);
    weatherCounts = new uint256[](11);
    
    mostCommonWeather[0] = "Clear";
    mostCommonWeather[1] = "Sunny";
    mostCommonWeather[2] = "Cloudy";
    mostCommonWeather[3] = "Foggy";
    mostCommonWeather[4] = "Rainy";
    mostCommonWeather[5] = "Stormy";
    mostCommonWeather[6] = "Thunderstorm";
    mostCommonWeather[7] = "Snowy";
    mostCommonWeather[8] = "Blizzard";
    mostCommonWeather[9] = "Heatwave";
    mostCommonWeather[10] = "Sandstorm";
    
    // Count total weather changes and get counts for each weather type
    totalWeatherChanges = 0;
    
    for (uint256 locationId = 1; locationId <= locationIds.length; locationId++) {
        for (uint256 i = 0; i < mostCommonWeather.length; i++) {
            uint256 count = locationWeatherHistory[locationId][mostCommonWeather[i]];
            weatherCounts[i] += count;
            totalWeatherChanges += count;
        }
    }
    
    return (mostCommonWeather, weatherCounts, totalWeatherChanges);
}

struct Season {
    string name;
    uint256 startDay;
    uint256 endDay;
    uint256 effectId;
    int8 temperatureBase;
    uint8[] resourceMultipliers;
    uint8[] mobSpawnRates;
    uint8[] itemDropRates;
    uint8[] questRewardMultipliers;
    string[] specialEvents;
    mapping(uint256 => uint8) locationEffects;
    mapping(uint8 => uint8) characterClassEffects;
}
mapping(uint256 => Season) public seasons;
mapping(uint256 => uint256) public currentLocationSeason;

mapping(uint256 => mapping(uint256 => uint256)) public seasonalResourceNodes;
mapping(uint256 => mapping(string => uint256)) public seasonalItemPrices;
mapping(address => mapping(uint256 => uint256)) public playerSeasonExperience;
mapping(uint256 => uint256[]) public seasonalQuestIds;
mapping(uint256 => mapping(uint256 => bool)) public seasonalMonsterSpawns;
mapping(uint256 => string[]) public seasonSpecialEvents;
mapping(uint256 => mapping(uint256 => int8)) public seasonLocationTemperatureModifiers;
mapping(uint256 => uint256) public seasonStartTimestamps;
mapping(uint256 => mapping(uint256 => uint256)) public seasonalTerritoryBonuses;
mapping(uint256 => mapping(uint8 => uint8)) public seasonClassBonuses;
event SeasonChanged(string newSeason, uint256 effectId);

function initializeSeasons() external onlyOwner {
    uint8[] memory springResourceMods = new uint8[](5);
    springResourceMods[0] = 120;
    springResourceMods[1] = 100;
    springResourceMods[2] = 150;
    springResourceMods[3] = 130;
    springResourceMods[4] = 90;
    
    uint8[] memory springMobRates = new uint8[](3);
    springMobRates[0] = 110;
    springMobRates[1] = 100;
    springMobRates[2] = 120;
    
    uint8[] memory springDropRates = new uint8[](4);
    springDropRates[0] = 110;
    springDropRates[1] = 100;
    springDropRates[2] = 120;
    springDropRates[3] = 105;
    
    uint8[] memory springQuestMods = new uint8[](3);
    springQuestMods[0] = 110;
    springQuestMods[1] = 100;
    springQuestMods[2] = 120;
    
    string[] memory springEvents = new string[](2);
    springEvents[0] = "Spring Festival";
    springEvents[1] = "Flower Bloom";
    
    _createSeason(1, "Spring", 80, 171, 1001, 5, springResourceMods, springMobRates, springDropRates, springQuestMods, springEvents);
    
    uint8[] memory summerResourceMods = new uint8[](5);
    summerResourceMods[0] = 100;
    summerResourceMods[1] = 120;
    summerResourceMods[2] = 90;
    summerResourceMods[3] = 80;
    summerResourceMods[4] = 130;
    
    uint8[] memory summerMobRates = new uint8[](3);
    summerMobRates[0] = 120;
    summerMobRates[1] = 130;
    summerMobRates[2] = 110;
    
    uint8[] memory summerDropRates = new uint8[](4);
    summerDropRates[0] = 100;
    summerDropRates[1] = 120;
    summerDropRates[2] = 90;
    summerDropRates[3] = 110;
    
    uint8[] memory summerQuestMods = new uint8[](3);
    summerQuestMods[0] = 120;
    summerQuestMods[1] = 110;
    summerQuestMods[2] = 100;
    
    string[] memory summerEvents = new string[](2);
    summerEvents[0] = "Summer Solstice";
    summerEvents[1] = "Dragon Migration";
    
    _createSeason(2, "Summer", 172, 265, 1002, 15, summerResourceMods, summerMobRates, summerDropRates, summerQuestMods, summerEvents);
    
    uint8[] memory fallResourceMods = new uint8[](5);
    fallResourceMods[0] = 150;
    fallResourceMods[1] = 110;
    fallResourceMods[2] = 130;
    fallResourceMods[3] = 100;
    fallResourceMods[4] = 90;
    
    uint8[] memory fallMobRates = new uint8[](3);
    fallMobRates[0] = 100;
    fallMobRates[1] = 110;
    fallMobRates[2] = 90;
    
    uint8[] memory fallDropRates = new uint8[](4);
    fallDropRates[0] = 130;
    fallDropRates[1] = 120;
    fallDropRates[2] = 110;
    fallDropRates[3] = 100;
    
    uint8[] memory fallQuestMods = new uint8[](3);
    fallQuestMods[0] = 100;
    fallQuestMods[1] = 120;
    fallQuestMods[2] = 110;
    
    string[] memory fallEvents = new string[](2);
    fallEvents[0] = "Harvest Festival";
    fallEvents[1] = "Undead Rising";
    
    _createSeason(3, "Fall", 266, 354, 1003, 0, fallResourceMods, fallMobRates, fallDropRates, fallQuestMods, fallEvents);
    
    uint8[] memory winterResourceMods = new uint8[](5);
    winterResourceMods[0] = 70;
    winterResourceMods[1] = 90;
    winterResourceMods[2] = 60;
    winterResourceMods[3] = 80;
    winterResourceMods[4] = 150;
    
    uint8[] memory winterMobRates = new uint8[](3);
    winterMobRates[0] = 80;
    winterMobRates[1] = 70;
    winterMobRates[2] = 130;
    
    uint8[] memory winterDropRates = new uint8[](4);
    winterDropRates[0] = 90;
    winterDropRates[1] = 80;
    winterDropRates[2] = 120;
    winterDropRates[3] = 130;
    
    uint8[] memory winterQuestMods = new uint8[](3);
    winterQuestMods[0] = 90;
    winterQuestMods[1] = 130;
    winterQuestMods[2] = 120;
    
    string[] memory winterEvents = new string[](2);
    winterEvents[0] = "Winter Solstice";
    winterEvents[1] = "Frost Giant Raids";
    
    _createSeason(4, "Winter", 355, 79, 1004, -10, winterResourceMods, winterMobRates, winterDropRates, winterQuestMods, winterEvents);
    
    for (uint256 i = 1; i <= 50; i++) {
        seasons[1].locationEffects[i] = 100 + uint8(_random(30));
        seasons[2].locationEffects[i] = 100 + uint8(_random(30));
        seasons[3].locationEffects[i] = 100 + uint8(_random(30));
        seasons[4].locationEffects[i] = 100 + uint8(_random(30));
    }
    
    for (uint8 i = 0; i <= 4; i++) {
        seasons[1].characterClassEffects[i] = 100 + uint8(_random(20));
        seasons[2].characterClassEffects[i] = 100 + uint8(_random(20));
        seasons[3].characterClassEffects[i] = 100 + uint8(_random(20));
        seasons[4].characterClassEffects[i] = 100 + uint8(_random(20));
    }
    
    seasonalQuestIds[1] = [5, 10, 15, 20, 25];
    seasonalQuestIds[2] = [6, 11, 16, 21, 26];
    seasonalQuestIds[3] = [7, 12, 17, 22, 27];
    seasonalQuestIds[4] = [8, 13, 18, 23, 28];
    
    for (uint256 i = 1; i <= 10; i++) {
        seasonalMonsterSpawns[1][i] = true;
        seasonalMonsterSpawns[2][i+10] = true;
        seasonalMonsterSpawns[3][i+20] = true;
        seasonalMonsterSpawns[4][i+30] = true;
    }
    
    seasonSpecialEvents[1] = ["Spring Bloom", "Rebirth Ritual", "Seedling Ceremony"];
    seasonSpecialEvents[2] = ["Summer Games", "Fire Festival", "Ocean's Bounty"];
    seasonSpecialEvents[3] = ["Harvest Moon", "Spirit Walk", "Hunter's Glory"];
    seasonSpecialEvents[4] = ["Winter's Veil", "Ice Sculpture Contest", "Long Night"];
    
    for (uint256 i = 1; i <= 50; i++) {
        seasonLocationTemperatureModifiers[1][i] = int8(int256(_random(10)));
        seasonLocationTemperatureModifiers[2][i] = int8(int256(_random(10)) + 5);
        seasonLocationTemperatureModifiers[3][i] = int8(int256(_random(10)) - 5);
        seasonLocationTemperatureModifiers[4][i] = int8(int256(_random(10)) - 10);
    }
    
    seasonStartTimestamps[1] = block.timestamp;
    seasonStartTimestamps[2] = block.timestamp + 90 days;
    seasonStartTimestamps[3] = block.timestamp + 180 days;
    seasonStartTimestamps[4] = block.timestamp + 270 days;
    
    for (uint256 i = 1; i <= 10; i++) {
        seasonalTerritoryBonuses[1][i] = 100 + _random(50);
        seasonalTerritoryBonuses[2][i] = 100 + _random(50);
        seasonalTerritoryBonuses[3][i] = 100 + _random(50);
        seasonalTerritoryBonuses[4][i] = 100 + _random(50);
    }
    
    for (uint8 i = 0; i <= 4; i++) {
        seasonClassBonuses[1][i] = 100 + uint8(_random(25));
        seasonClassBonuses[2][i] = 100 + uint8(_random(25));
        seasonClassBonuses[3][i] = 100 + uint8(_random(25));
        seasonClassBonuses[4][i] = 100 + uint8(_random(25));
    }
}

function _createSeason(
    uint256 id,
    string memory name,
    uint256 startDay,
    uint256 endDay,
    uint256 effectId,
    int8 temperatureBase,
    uint8[] memory resourceMultipliers,
    uint8[] memory mobSpawnRates,
    uint8[] memory itemDropRates,
    uint8[] memory questRewardMultipliers,
    string[] memory specialEvents
) internal {
    Season storage season = seasons[id];
    season.name = name;
    season.startDay = startDay;
    season.endDay = endDay;
    season.effectId = effectId;
    season.temperatureBase = temperatureBase;
    
    delete season.resourceMultipliers;
    delete season.mobSpawnRates;
    delete season.itemDropRates;
    delete season.questRewardMultipliers;
    delete season.specialEvents;
    
    for (uint256 i = 0; i < resourceMultipliers.length; i++) {
        season.resourceMultipliers.push(resourceMultipliers[i]);
    }
    
    for (uint256 i = 0; i < mobSpawnRates.length; i++) {
        season.mobSpawnRates.push(mobSpawnRates[i]);
    }
    
    for (uint256 i = 0; i < itemDropRates.length; i++) {
        season.itemDropRates.push(itemDropRates[i]);
    }
    
    for (uint256 i = 0; i < questRewardMultipliers.length; i++) {
        season.questRewardMultipliers.push(questRewardMultipliers[i]);
    }
    
    for (uint256 i = 0; i < specialEvents.length; i++) {
        season.specialEvents.push(specialEvents[i]);
    }
}

function getCurrentSeason() public view returns (uint256) {
    uint256 dayOfYear = (block.timestamp / 86400) % 365;
    
    if (dayOfYear >= seasons[1].startDay && dayOfYear <= seasons[1].endDay) return 1;
    if (dayOfYear >= seasons[2].startDay && dayOfYear <= seasons[2].endDay) return 2;
    if (dayOfYear >= seasons[3].startDay && dayOfYear <= seasons[3].endDay) return 3;
    return 4;
}

function advanceSeason() external onlyOwner {
    uint256 currentSeason = getCurrentSeason();
    uint256 nextSeason = currentSeason < 4 ? currentSeason + 1 : 1;
    
    seasonStartTimestamps[nextSeason] = block.timestamp;
    
    emit SeasonChanged(seasons[nextSeason].name, seasons[nextSeason].effectId);
    
    for (uint256 i = 0; i < locationIds.length; i++) {
        uint256 locationId = locationIds[i];
        currentLocationSeason[locationId] = nextSeason;
    }
    
    for (uint256 i = 0; i < playerAddresses.length; i++) {
        address playerAddr = playerAddresses[i];
        playerSeasonExperience[playerAddr][nextSeason]++;
        
        if (players[playerAddr].isActive) {
            applySeasonEffects(playerAddr);
        }
    }
}
function applySeasonEffects(address playerAddress) public gameIsActive {
    Player storage player = players[playerAddress];
    uint256 locationId = player.locationId;
    uint256 seasonId = currentLocationSeason[locationId];
    
    if (seasonId == 0) {
        seasonId = getCurrentSeason();
        currentLocationSeason[locationId] = seasonId;
    }
    
    Season storage season = seasons[seasonId];
    
    uint8 classEffect = season.characterClassEffects[player.characterClass];
    uint8 locationEffect = season.locationEffects[locationId];
        if (season.temperatureBase < -5 && _random(100) < 30) {
        uint256 coldDamage = uint256(uint8(abs(season.temperatureBase))) / 2;
        if (player.health > coldDamage) {
            player.health -= coldDamage;
        } else {
            player.health = 1;
        }
    }
    
    if (season.temperatureBase > 10 && _random(100) < 30) {
        uint256 heatDamage = uint256(uint8(season.temperatureBase)) / 3;
        if (player.mana > heatDamage) {
            player.mana -= heatDamage;
        } else {
            player.mana = 0;
        }
    }
    
    if (_random(100) < 10) {
        uint256 eventIndex = _random(season.specialEvents.length);
        if (eventIndex < season.specialEvents.length) {
            _triggerSeasonalEvent(playerAddress, season.specialEvents[eventIndex]);
        }
    }
}

function abs(int8 x) private pure returns (int8) {
    return x >= 0 ? x : -x;
}

function getSeasonDetails(uint256 seasonId) external view returns (
    string memory name,
    uint256 startDay,
    uint256 endDay,
    uint256 effectId,
    int8 temperatureBase,
    uint8[] memory resourceMultipliers,
    uint8[] memory mobSpawnRates,
    uint8[] memory itemDropRates,
    uint8[] memory questRewardMultipliers,
    string[] memory specialEvents
) {
    require(seasonId >= 1 && seasonId <= 4, "Invalid season ID");
    
    Season storage season = seasons[seasonId];
    
    return (
        season.name,
        season.startDay,
        season.endDay,
        season.effectId,
        season.temperatureBase,
        season.resourceMultipliers,
        season.mobSpawnRates,
        season.itemDropRates,
        season.questRewardMultipliers,
        season.specialEvents
    );
}

function getSeasonEffects(uint256 seasonId, uint256 locationId, uint8 characterClass) external view returns (
    uint8 locationEffect,
    uint8 classEffect,
    int8 temperatureModifier,
    bool[] memory availableQuests,
    bool[] memory availableMonsters
) {
    require(seasonId >= 1 && seasonId <= 4, "Invalid season ID");
    require(locationId > 0 && locationId <= locationIds.length, "Invalid location ID");
    require(characterClass <= 4, "Invalid character class");
    
    Season storage season = seasons[seasonId];
    
    locationEffect = season.locationEffects[locationId];
    classEffect = season.characterClassEffects[characterClass];
    temperatureModifier = season.temperatureBase + seasonLocationTemperatureModifiers[seasonId][locationId];
    
    availableQuests = new bool[](questIds.length + 1);
    for (uint256 i = 0; i < seasonalQuestIds[seasonId].length; i++) {
        uint256 questId = seasonalQuestIds[seasonId][i];
        if (questId <= questIds.length) {
            availableQuests[questId] = true;
        }
    }
    
    availableMonsters = new bool[](monsterIds.length + 1);
    for (uint256 i = 1; i <= monsterIds.length; i++) {
        availableMonsters[i] = seasonalMonsterSpawns[seasonId][i];
    }
    
    return (locationEffect, classEffect, temperatureModifier, availableQuests, availableMonsters);
}

function getSeasonalResourceMultiplier(uint256 resourceType) external view returns (uint8) {
    uint256 seasonId = getCurrentSeason();
    Season storage season = seasons[seasonId];
    
    if (resourceType < season.resourceMultipliers.length) {
        return season.resourceMultipliers[resourceType];
    }
    
    return 100; // Default: no modifier
}

function getSeasonalQuestRewardMultiplier(uint256 questType) external view returns (uint8) {
    uint256 seasonId = getCurrentSeason();
    Season storage season = seasons[seasonId];
    
    if (questType < season.questRewardMultipliers.length) {
        return season.questRewardMultipliers[questType];
    }
    
    return 100; // Default: no modifier
}

function getSeasonalItemPrice(string calldata itemName) external view returns (uint256) {
    uint256 seasonId = getCurrentSeason();
    
    uint256 price = seasonalItemPrices[seasonId][itemName];
    if (price > 0) {
        return price;
    }
    
    return 0; // Default: no seasonal price
}

function setSeasonalItemPrice(uint256 seasonId, string calldata itemName, uint256 price) external onlyOwner {
    require(seasonId >= 1 && seasonId <= 4, "Invalid season ID");
    
    seasonalItemPrices[seasonId][itemName] = price;
}

function getPlayerSeasonExperience(address playerAddress) external view returns (uint256[] memory) {
    uint256[] memory experience = new uint256[](5);
    
    for (uint256 i = 1; i <= 4; i++) {
        experience[i] = playerSeasonExperience[playerAddress][i];
    }
    
    return experience;
}

function getSeasonalEvents(uint256 seasonId) external view returns (string[] memory) {
    require(seasonId >= 1 && seasonId <= 4, "Invalid season ID");
    
    return seasonSpecialEvents[seasonId];
}

function addSeasonalEvent(uint256 seasonId, string calldata eventName) external onlyOwner {
    require(seasonId >= 1 && seasonId <= 4, "Invalid season ID");
    
    seasonSpecialEvents[seasonId].push(eventName);
}

function setSeasonalMonsterSpawn(uint256 seasonId, uint256 monsterId, bool canSpawn) external onlyOwner {
    require(seasonId >= 1 && seasonId <= 4, "Invalid season ID");
    require(monsterId > 0 && monsterId <= monsterIds.length, "Invalid monster ID");
    
    seasonalMonsterSpawns[seasonId][monsterId] = canSpawn;
}

function setSeasonalQuests(uint256 seasonId, uint256[] calldata questIds) external onlyOwner {
    require(seasonId >= 1 && seasonId <= 4, "Invalid season ID");
    
    delete seasonalQuestIds[seasonId];
    
    for (uint256 i = 0; i < questIds.length; i++) {
        seasonalQuestIds[seasonId].push(questIds[i]);
    }
}

function _triggerSeasonalEvent(address playerAddress, string memory eventName) internal {
    Player storage player = players[playerAddress];
    
    bytes32 eventHash = keccak256(abi.encodePacked(eventName));
    
    if (eventHash == keccak256(abi.encodePacked("Spring Bloom"))) {
        player.experience += 50;
        _checkLevelUp(playerAddress);
    }
    else if (eventHash == keccak256(abi.encodePacked("Summer Games"))) {
        player.strength += 1;
        player.dexterity += 1;
    }
    else if (eventHash == keccak256(abi.encodePacked("Harvest Moon"))) {
        player.gold += 100;
    }
    else if (eventHash == keccak256(abi.encodePacked("Winter's Veil"))) {
        player.inventory.push(uint256(_random(10) + 1));
        emit ItemAcquired(playerAddress, player.inventory[player.inventory.length - 1]);
    }
    else if (eventHash == keccak256(abi.encodePacked("Fire Festival"))) {
        player.intelligence += 2;
    }
    else if (eventHash == keccak256(abi.encodePacked("Spirit Walk"))) {
        player.mana = player.maxMana;
        player.health = player.maxHealth;
    }
    else if (eventHash == keccak256(abi.encodePacked("Hunter's Glory"))) {
        player.strength += 2;
    }
    else if (eventHash == keccak256(abi.encodePacked("Ice Sculpture Contest"))) {
        player.intelligence += 1;
        player.gold += 50;
    }
    else if (eventHash == keccak256(abi.encodePacked("Rebirth Ritual"))) {
        player.experience += 100;
        _checkLevelUp(playerAddress);
    }
    else if (eventHash == keccak256(abi.encodePacked("Ocean's Bounty"))) {
        player.inventory.push(uint256(_random(5) + 5));
        emit ItemAcquired(playerAddress, player.inventory[player.inventory.length - 1]);
    }
    else if (eventHash == keccak256(abi.encodePacked("Long Night"))) {
        player.defense += 2;
    }
}

function getTimeUntilNextSeason() external view returns (uint256) {
    uint256 currentSeason = getCurrentSeason();
    uint256 nextSeason = currentSeason < 4 ? currentSeason + 1 : 1;
    
    uint256 currentDayOfYear = (block.timestamp / 86400) % 365;
    uint256 nextSeasonStartDay = seasons[nextSeason].startDay;
    
    if (nextSeasonStartDay < currentDayOfYear) {
        nextSeasonStartDay += 365;
    }
    
    uint256 daysUntilNextSeason = nextSeasonStartDay - currentDayOfYear;
    return daysUntilNextSeason * 1 days;
}

function getSeasonalTerritoryBonus(uint256 territoryId) external view returns (uint256) {
    uint256 seasonId = getCurrentSeason();
    
    return seasonalTerritoryBonuses[seasonId][territoryId];
}

function getSeasonalClassBonus(uint8 characterClass) external view returns (uint8) {
    uint256 seasonId = getCurrentSeason();
    
    return seasonClassBonuses[seasonId][characterClass];
}

function setSeasonLocationEffect(uint256 seasonId, uint256 locationId, uint8 effect) external onlyOwner {
    require(seasonId >= 1 && seasonId <= 4, "Invalid season ID");
    require(locationId > 0 && locationId <= locationIds.length, "Invalid location ID");
    
    seasons[seasonId].locationEffects[locationId] = effect;
}

function setSeasonClassEffect(uint256 seasonId, uint8 characterClass, uint8 effect) external onlyOwner {
    require(seasonId >= 1 && seasonId <= 4, "Invalid season ID");
    require(characterClass <= 4, "Invalid character class");
    
    seasons[seasonId].characterClassEffects[characterClass] = effect;
}

function forceSeasonChange(uint256 newSeasonId) external onlyOwner {
    require(newSeasonId >= 1 && newSeasonId <= 4, "Invalid season ID");
    
    emit SeasonChanged(seasons[newSeasonId].name, seasons[newSeasonId].effectId);
    
    for (uint256 i = 0; i < locationIds.length; i++) {
        uint256 locationId = locationIds[i];
        currentLocationSeason[locationId] = newSeasonId;
    }
}
function getSeasonStartTimestamp(uint256 seasonId) external view returns (uint256) {
    require(seasonId >= 1 && seasonId <= 4, "Invalid season ID");
    
    return seasonStartTimestamps[seasonId];
}

function getSeasonDuration() external pure returns (uint256) {
    return 91 days; // Approximately one season (3 months)
}



struct Message {
    address sender;
    address recipient;
    string messageHash;
    uint256 timestamp;
    bool isRead;
    bool isEncrypted;
    uint256 messageType;
    uint256 expirationTime;
    uint256[] attachedItemIds;
    uint256 attachedGold;
    bool isSystemMessage;
    uint256 replyToMessageId;
    uint256 threadId;
    uint8 priority;
    bool isDeleted;
    mapping(address => bool) hasReported;
}

mapping(uint256 => Message) public messages;
mapping(address => uint256[]) public sentMessages;
mapping(address => uint256[]) public receivedMessages;
mapping(address => uint256) public unreadMessageCount;
mapping(address => mapping(address => bool)) public blockedSenders;
mapping(address => mapping(uint256 => bool)) public messageReadStatus;
mapping(uint256 => uint256[]) public messageReplies;
mapping(uint256 => uint256) public messageThreads;
mapping(address => uint256) public lastMessageTime;
mapping(uint256 => uint256) public messageReportCount;
mapping(address => uint256[]) public systemMessages;
mapping(uint256 => address[]) public messageRecipients;
mapping(address => mapping(uint8 => uint256[])) public messagesByType;
mapping(address => uint256) public messageQuota;
mapping(address => uint256) public messageQuotaResetTime;
mapping(uint256 => string) public messageTypes;
mapping(address => mapping(string => uint256[])) public messagesByKeyword;
mapping(uint256 => uint256) public messageRewardId;
mapping(address => uint256) public totalMessagesSent;
mapping(address => uint256) public totalMessagesReceived;
event MessageSent(address indexed sender, address indexed recipient, string messageHash);

function sendMessage(address recipient, string calldata messageHash, uint256 messageType, uint256 expirationTime, uint256[] calldata attachedItemIds, uint256 attachedGold) external gameIsActive playerExists {
    require(recipient != address(0), "Invalid recipient");
    require(recipient != msg.sender, "Cannot send message to yourself");
    require(bytes(messageHash).length > 0 && bytes(messageHash).length <= 1000, "Invalid message length");
    require(!blockedSenders[recipient][msg.sender], "You are blocked by this recipient");
    require(block.timestamp >= lastMessageTime[msg.sender] + 10, "Message rate limit exceeded");
    
    if (messageQuota[msg.sender] == 0) {
        if (block.timestamp >= messageQuotaResetTime[msg.sender]) {
            messageQuota[msg.sender] = 50;
            messageQuotaResetTime[msg.sender] = block.timestamp + 1 days;
        } else {
            revert("Daily message quota exceeded");
        }
    }
    
    if (attachedGold > 0) {
        require(players[msg.sender].gold >= attachedGold, "Insufficient gold");
        players[msg.sender].gold -= attachedGold;
    }
    
    for (uint256 i = 0; i < attachedItemIds.length; i++) {
        uint256 itemId = attachedItemIds[i];
        bool hasItem = false;
        
        for (uint256 j = 0; j < players[msg.sender].inventory.length; j++) {
            if (players[msg.sender].inventory[j] == itemId) {
                hasItem = true;
                _removeItemFromInventory(msg.sender, j);
                break;
            }
        }
        
        require(hasItem, "Item not in inventory");
    }
    
    uint256 messageId = uint256(keccak256(abi.encodePacked(msg.sender, recipient, messageHash, block.timestamp)));
    
    Message storage newMessage = messages[messageId];
    newMessage.sender = msg.sender;
    newMessage.recipient = recipient;
    newMessage.messageHash = messageHash;
    newMessage.timestamp = block.timestamp;
    newMessage.isRead = false;
    newMessage.isEncrypted = false;
    newMessage.messageType = messageType;
    newMessage.expirationTime = expirationTime > 0 ? block.timestamp + expirationTime : 0;
    newMessage.attachedGold = attachedGold;
    newMessage.isSystemMessage = false;
    newMessage.replyToMessageId = 0;
    newMessage.threadId = messageId;
    newMessage.priority = 1;
    newMessage.isDeleted = false;
    
    for (uint256 i = 0; i < attachedItemIds.length; i++) {
        newMessage.attachedItemIds.push(attachedItemIds[i]);
    }
    
    sentMessages[msg.sender].push(messageId);
    receivedMessages[recipient].push(messageId);
    unreadMessageCount[recipient]++;
    lastMessageTime[msg.sender] = block.timestamp;
    messageQuota[msg.sender]--;
    totalMessagesSent[msg.sender]++;
    totalMessagesReceived[recipient]++;
    messagesByType[recipient][uint8(messageType)].push(messageId);
    
    emit MessageSent(msg.sender, recipient, messageHash);
}

function readMessage(uint256 messageId) external gameIsActive playerExists {
    require(messages[messageId].recipient == msg.sender || messages[messageId].sender == msg.sender, "Not authorized to read this message");
    require(!messages[messageId].isDeleted, "Message has been deleted");
    
    if (messages[messageId].recipient == msg.sender && !messages[messageId].isRead) {
        messages[messageId].isRead = true;
        messageReadStatus[msg.sender][messageId] = true;
        
        if (unreadMessageCount[msg.sender] > 0) {
            unreadMessageCount[msg.sender]--;
        }
        
        if (messages[messageId].attachedGold > 0) {
            players[msg.sender].gold += messages[messageId].attachedGold;
        }
        
        for (uint256 i = 0; i < messages[messageId].attachedItemIds.length; i++) {
            players[msg.sender].inventory.push(messages[messageId].attachedItemIds[i]);
        }
    }
}

function replyToMessage(uint256 originalMessageId, string calldata messageHash) external gameIsActive playerExists {
    require(messages[originalMessageId].recipient == msg.sender || messages[originalMessageId].sender == msg.sender, "Not authorized to reply to this message");
    require(!messages[originalMessageId].isDeleted, "Original message has been deleted");
    require(bytes(messageHash).length > 0 && bytes(messageHash).length <= 1000, "Invalid message length");
    
    address recipient = messages[originalMessageId].sender == msg.sender ? messages[originalMessageId].recipient : messages[originalMessageId].sender;
    
    require(!blockedSenders[recipient][msg.sender], "You are blocked by this recipient");
    require(block.timestamp >= lastMessageTime[msg.sender] + 10, "Message rate limit exceeded");
    
    if (messageQuota[msg.sender] == 0) {
        if (block.timestamp >= messageQuotaResetTime[msg.sender]) {
            messageQuota[msg.sender] = 50;
            messageQuotaResetTime[msg.sender] = block.timestamp + 1 days;
        } else {
            revert("Daily message quota exceeded");
        }
    }
    
    uint256 messageId = uint256(keccak256(abi.encodePacked(msg.sender, recipient, messageHash, block.timestamp)));
    
    Message storage newMessage = messages[messageId];
    newMessage.sender = msg.sender;
    newMessage.recipient = recipient;
    newMessage.messageHash = messageHash;
    newMessage.timestamp = block.timestamp;
    newMessage.isRead = false;
    newMessage.isEncrypted = false;
    newMessage.messageType = messages[originalMessageId].messageType;
    newMessage.expirationTime = 0;
    newMessage.isSystemMessage = false;
    newMessage.replyToMessageId = originalMessageId;
    newMessage.threadId = messages[originalMessageId].threadId;
    newMessage.priority = 1;
    newMessage.isDeleted = false;
    
    sentMessages[msg.sender].push(messageId);
    receivedMessages[recipient].push(messageId);
    unreadMessageCount[recipient]++;
    lastMessageTime[msg.sender] = block.timestamp;
    messageQuota[msg.sender]--;
    messageReplies[originalMessageId].push(messageId);
    totalMessagesSent[msg.sender]++;
    totalMessagesReceived[recipient]++;
    messagesByType[recipient][uint8(newMessage.messageType)].push(messageId);
    
    emit MessageSent(msg.sender, recipient, messageHash);
}

function deleteMessage(uint256 messageId) external gameIsActive playerExists {
    require(messages[messageId].recipient == msg.sender || messages[messageId].sender == msg.sender, "Not authorized to delete this message");
    
    if (messages[messageId].recipient == msg.sender && !messages[messageId].isRead) {
        if (unreadMessageCount[msg.sender] > 0) {
            unreadMessageCount[msg.sender]--;
        }
    }
    
    messages[messageId].isDeleted = true;
}

function blockSender(address sender) external gameIsActive playerExists {
    require(sender != address(0), "Invalid sender address");
    require(sender != msg.sender, "Cannot block yourself");
    
    blockedSenders[msg.sender][sender] = true;
}

function unblockSender(address sender) external gameIsActive playerExists {
    blockedSenders[msg.sender][sender] = false;
}

function getInbox() external view playerExists returns (uint256[] memory) {
    uint256[] memory inbox = new uint256[](receivedMessages[msg.sender].length);
    uint256 count = 0;
    
    for (uint256 i = 0; i < receivedMessages[msg.sender].length; i++) {
        uint256 messageId = receivedMessages[msg.sender][i];
        if (!messages[messageId].isDeleted) {
            inbox[count] = messageId;
            count++;
        }
    }
    
    uint256[] memory result = new uint256[](count);
    for (uint256 i = 0; i < count; i++) {
        result[i] = inbox[i];
    }
    
    return result;
}

function getOutbox() external view playerExists returns (uint256[] memory) {
    uint256[] memory outbox = new uint256[](sentMessages[msg.sender].length);
    uint256 count = 0;
    
    for (uint256 i = 0; i < sentMessages[msg.sender].length; i++) {
        uint256 messageId = sentMessages[msg.sender][i];
        if (!messages[messageId].isDeleted) {
            outbox[count] = messageId;
            count++;
        }
    }
    
    uint256[] memory result = new uint256[](count);
    for (uint256 i = 0; i < count; i++) {
        result[i] = outbox[i];
    }
    
    return result;
}

function getMessageDetails(uint256 messageId) external view playerExists returns (
    address sender,
    address recipient,
    string memory messageHash,
    uint256 timestamp,
    bool isRead,
    uint256 messageType,
    uint256 expirationTime,
    uint256[] memory attachedItemIds,
    uint256 attachedGold,
    bool isSystemMessage,
    uint256 replyToMessageId,
    uint256 threadId
) {
    require(messages[messageId].recipient == msg.sender || messages[messageId].sender == msg.sender, "Not authorized to view this message");
    require(!messages[messageId].isDeleted, "Message has been deleted");
    
    Message storage message = messages[messageId];
    
    return (
        message.sender,
        message.recipient,
        message.messageHash,
        message.timestamp,
        message.isRead,
        message.messageType,
        message.expirationTime,
        message.attachedItemIds,
        message.attachedGold,
        message.isSystemMessage,
        message.replyToMessageId,
        message.threadId
    );
}

function getMessageThread(uint256 threadId) external view playerExists returns (uint256[] memory) {
    require(messages[threadId].recipient == msg.sender || messages[threadId].sender == msg.sender, "Not authorized to view this thread");
    
    uint256[] memory thread = new uint256[](100); // Arbitrary size limit
    uint256 count = 0;
    
    // Add the original message
    if (!messages[threadId].isDeleted) {
        thread[count] = threadId;
        count++;
    }
    
    // Add all replies in this thread
    for (uint256 i = 0; i < receivedMessages[msg.sender].length; i++) {
        uint256 messageId = receivedMessages[msg.sender][i];
        if (!messages[messageId].isDeleted && messages[messageId].threadId == threadId && messageId != threadId) {
            thread[count] = messageId;
            count++;
            if (count >= thread.length) break;
        }
    }
    
    for (uint256 i = 0; i < sentMessages[msg.sender].length; i++) {
        uint256 messageId = sentMessages[msg.sender][i];
        if (!messages[messageId].isDeleted && messages[messageId].threadId == threadId && messageId != threadId) {
            bool isDuplicate = false;
            for (uint256 j = 0; j < count; j++) {
                if (thread[j] == messageId) {
                    isDuplicate = true;
                    break;
                }
            }
            
            if (!isDuplicate) {
                thread[count] = messageId;
                count++;
                if (count >= thread.length) break;
            }
        }
    }
    
    uint256[] memory result = new uint256[](count);
    for (uint256 i = 0; i < count; i++) {
        result[i] = thread[i];
    }
    
    return result;
}

function reportMessage(uint256 messageId) external gameIsActive playerExists {
    require(messages[messageId].recipient == msg.sender, "Only recipient can report a message");
    require(!messages[messageId].hasReported[msg.sender], "Already reported this message");
    
    messages[messageId].hasReported[msg.sender] = true;
    messageReportCount[messageId]++;
    
    if (messageReportCount[messageId] >= 5) {
        messages[messageId].isDeleted = true;
    }
}

function sendSystemMessage(address recipient, string calldata messageHash, uint256 messageType) external onlyOwner {
    require(recipient != address(0), "Invalid recipient");
    require(bytes(messageHash).length > 0 && bytes(messageHash).length <= 1000, "Invalid message length");
    
    uint256 messageId = uint256(keccak256(abi.encodePacked(address(this), recipient, messageHash, block.timestamp)));
    
    Message storage newMessage = messages[messageId];
    newMessage.sender = address(this);
    newMessage.recipient = recipient;
    newMessage.messageHash = messageHash;
    newMessage.timestamp = block.timestamp;
    newMessage.isRead = false;
    newMessage.isEncrypted = false;
    newMessage.messageType = messageType;
    newMessage.expirationTime = 0;
    newMessage.isSystemMessage = true;
    newMessage.replyToMessageId = 0;
    newMessage.threadId = messageId;
    newMessage.priority = 3; // High priority for system messages
    newMessage.isDeleted = false;
    
    receivedMessages[recipient].push(messageId);
    unreadMessageCount[recipient]++;
    systemMessages[recipient].push(messageId);
    messagesByType[recipient][uint8(messageType)].push(messageId);
    totalMessagesReceived[recipient]++;
    
    emit MessageSent(address(this), recipient, messageHash);
}

function broadcastSystemMessage(string calldata messageHash, uint256 messageType) external onlyOwner {
    require(bytes(messageHash).length > 0 && bytes(messageHash).length <= 1000, "Invalid message length");
    
    for (uint256 i = 0; i < playerAddresses.length; i++) {
        address recipient = playerAddresses[i];
        
        if (players[recipient].isActive) {
            uint256 messageId = uint256(keccak256(abi.encodePacked(address(this), recipient, messageHash, block.timestamp, i)));
            
            Message storage newMessage = messages[messageId];
            newMessage.sender = address(this);
            newMessage.recipient = recipient;
            newMessage.messageHash = messageHash;
            newMessage.timestamp = block.timestamp;
            newMessage.isRead = false;
            newMessage.isEncrypted = false;
            newMessage.messageType = messageType;
            newMessage.expirationTime = 0;
            newMessage.isSystemMessage = true;
            newMessage.replyToMessageId = 0;
            newMessage.threadId = messageId;
            newMessage.priority = 3; // High priority for system messages
            newMessage.isDeleted = false;
            
            receivedMessages[recipient].push(messageId);
            unreadMessageCount[recipient]++;
            systemMessages[recipient].push(messageId);
            messagesByType[recipient][uint8(messageType)].push(messageId);
            totalMessagesReceived[recipient]++;
            
            messageRecipients[messageId].push(recipient);
        }
    }
}

function sendEncryptedMessage(address recipient, string calldata messageHash, uint256 messageType) external gameIsActive playerExists {
    require(recipient != address(0), "Invalid recipient");
    require(recipient != msg.sender, "Cannot send message to yourself");
    require(bytes(messageHash).length > 0 && bytes(messageHash).length <= 1000, "Invalid message length");
    require(!blockedSenders[recipient][msg.sender], "You are blocked by this recipient");
    require(block.timestamp >= lastMessageTime[msg.sender] + 10, "Message rate limit exceeded");
    
    if (messageQuota[msg.sender] == 0) {
        if (block.timestamp >= messageQuotaResetTime[msg.sender]) {
            messageQuota[msg.sender] = 50;
            messageQuotaResetTime[msg.sender] = block.timestamp + 1 days;
        } else {
            revert("Daily message quota exceeded");
        }
    }
    
    uint256 messageId = uint256(keccak256(abi.encodePacked(msg.sender, recipient, messageHash, block.timestamp)));
    
    Message storage newMessage = messages[messageId];
    newMessage.sender = msg.sender;
    newMessage.recipient = recipient;
    newMessage.messageHash = messageHash;
    newMessage.timestamp = block.timestamp;
    newMessage.isRead = false;
    newMessage.isEncrypted = true;
    newMessage.messageType = messageType;
    newMessage.expirationTime = block.timestamp + 7 days; // Encrypted messages expire after 7 days
    newMessage.isSystemMessage = false;
    newMessage.replyToMessageId = 0;
    newMessage.threadId = messageId;
    newMessage.priority = 2; // Medium priority for encrypted messages
    newMessage.isDeleted = false;
    
    sentMessages[msg.sender].push(messageId);
    receivedMessages[recipient].push(messageId);
    unreadMessageCount[recipient]++;
    lastMessageTime[msg.sender] = block.timestamp;
    messageQuota[msg.sender]--;
    totalMessagesSent[msg.sender]++;
    totalMessagesReceived[recipient]++;
    messagesByType[recipient][uint8(messageType)].push(messageId);
    
    emit MessageSent(msg.sender, recipient, messageHash);
}

function getUnreadMessageCount() external view playerExists returns (uint256) {
    return unreadMessageCount[msg.sender];
}

function markAllMessagesAsRead() external gameIsActive playerExists {
    for (uint256 i = 0; i < receivedMessages[msg.sender].length; i++) {
        uint256 messageId = receivedMessages[msg.sender][i];
        
        if (!messages[messageId].isRead && !messages[messageId].isDeleted) {
            messages[messageId].isRead = true;
            messageReadStatus[msg.sender][messageId] = true;
            
            if (messages[messageId].attachedGold > 0) {
                players[msg.sender].gold += messages[messageId].attachedGold;
            }
            
            for (uint256 j = 0; j < messages[messageId].attachedItemIds.length; j++) {
                players[msg.sender].inventory.push(messages[messageId].attachedItemIds[j]);
            }
        }
    }
    
    unreadMessageCount[msg.sender] = 0;
}

function getMessagesByType(uint8 messageType) external view playerExists returns (uint256[] memory) {
    return messagesByType[msg.sender][messageType];
}

function getSystemMessages() external view playerExists returns (uint256[] memory) {
    uint256[] memory result = new uint256[](systemMessages[msg.sender].length);
    uint256 count = 0;
    
    for (uint256 i = 0; i < systemMessages[msg.sender].length; i++) {
        uint256 messageId = systemMessages[msg.sender][i];
        if (!messages[messageId].isDeleted) {
            result[count] = messageId;
            count++;
        }
    }
    
    uint256[] memory filteredResult = new uint256[](count);
    for (uint256 i = 0; i < count; i++) {
        filteredResult[i] = result[i];
    }
    
    return filteredResult;
}

function getMessageReplies(uint256 messageId) external view playerExists returns (uint256[] memory) {
    require(messages[messageId].recipient == msg.sender || messages[messageId].sender == msg.sender, "Not authorized to view replies to this message");
    
    return messageReplies[messageId];
}

function searchMessages(string calldata keyword) external view playerExists returns (uint256[] memory) {
    return messagesByKeyword[msg.sender][keyword];
}

function addMessageKeyword(uint256 messageId, string calldata keyword) external gameIsActive playerExists {
    require(messages[messageId].recipient == msg.sender || messages[messageId].sender == msg.sender, "Not authorized to add keywords to this message");
    require(bytes(keyword).length > 0 && bytes(keyword).length <= 50, "Invalid keyword length");
    
    messagesByKeyword[msg.sender][keyword].push(messageId);
}

function getMessageQuota() external view playerExists returns (uint256 remainingQuota, uint256 resetTime) {
    return (messageQuota[msg.sender], messageQuotaResetTime[msg.sender]);
}

function increaseMessageQuota(address player, uint256 additionalQuota) external onlyOwner {
    messageQuota[player] += additionalQuota;
}

function setMessageType(uint256 typeId, string calldata typeName) external onlyOwner {
    messageTypes[typeId] = typeName;
}

function getMessageType(uint256 typeId) external view returns (string memory) {
    return messageTypes[typeId];
}

function attachRewardToMessage(uint256 messageId, uint256 rewardId) external onlyOwner {
    messageRewardId[messageId] = rewardId;
}

function getMessageStats() external view playerExists returns (uint256 sent, uint256 received, uint256 unread) {
    return (totalMessagesSent[msg.sender], totalMessagesReceived[msg.sender], unreadMessageCount[msg.sender]);
}

function setPriority(uint256 messageId, uint8 priority) external gameIsActive playerExists {
    require(messages[messageId].sender == msg.sender, "Only sender can change message priority");
    require(priority >= 1 && priority <= 3, "Invalid priority level");
    
    messages[messageId].priority = priority;
}

function getMessagesByPriority(uint8 priority) external view playerExists returns (uint256[] memory) {
    require(priority >= 1 && priority <= 3, "Invalid priority level");
    
    uint256[] memory result = new uint256[](receivedMessages[msg.sender].length);
    uint256 count = 0;
    
    for (uint256 i = 0; i < receivedMessages[msg.sender].length; i++) {
        uint256 messageId = receivedMessages[msg.sender][i];
        if (!messages[messageId].isDeleted && messages[messageId].priority == priority) {
            result[count] = messageId;
            count++;
        }
    }
    
    uint256[] memory filteredResult = new uint256[](count);
    for (uint256 i = 0; i < count; i++) {
        filteredResult[i] = result[i];
    }
    
    return filteredResult;
}

function forwardMessage(uint256 messageId, address newRecipient) external gameIsActive playerExists {
    require(messages[messageId].recipient == msg.sender, "Only recipient can forward a message");
    require(newRecipient != address(0), "Invalid recipient");
    require(newRecipient != msg.sender, "Cannot forward message to yourself");
    require(!blockedSenders[newRecipient][msg.sender], "You are blocked by this recipient");
    require(block.timestamp >= lastMessageTime[msg.sender] + 10, "Message rate limit exceeded");
    
    if (messageQuota[msg.sender] == 0) {
        if (block.timestamp >= messageQuotaResetTime[msg.sender]) {
            messageQuota[msg.sender] = 50;
            messageQuotaResetTime[msg.sender] = block.timestamp + 1 days;
        } else {
            revert("Daily message quota exceeded");
        }
    }
    
    string memory forwardedMessage = string(abi.encodePacked("Forwarded: ", messages[messageId].messageHash));
    
    uint256 newMessageId = uint256(keccak256(abi.encodePacked(msg.sender, newRecipient, forwardedMessage, block.timestamp)));
    
    Message storage newMessage = messages[newMessageId];
    newMessage.sender = msg.sender;
    newMessage.recipient = newRecipient;
    newMessage.messageHash = forwardedMessage;
    newMessage.timestamp = block.timestamp;
    newMessage.isRead = false;
    newMessage.isEncrypted = false;
    newMessage.messageType = messages[messageId].messageType;
    newMessage.expirationTime = 0;
    newMessage.isSystemMessage = false;
    newMessage.replyToMessageId = 0;
    newMessage.threadId = newMessageId;
    newMessage.priority = 1;
    newMessage.isDeleted = false;
    
    sentMessages[msg.sender].push(newMessageId);
    receivedMessages[newRecipient].push(newMessageId);
    unreadMessageCount[newRecipient]++;
    lastMessageTime[msg.sender] = block.timestamp;
    messageQuota[msg.sender]--;
    totalMessagesSent[msg.sender]++;
    totalMessagesReceived[newRecipient]++;
    messagesByType[newRecipient][uint8(newMessage.messageType)].push(newMessageId);
    
    emit MessageSent(msg.sender, newRecipient, forwardedMessage);
}

function getExpiredMessages() external view playerExists returns (uint256[] memory) {
    uint256[] memory result = new uint256[](receivedMessages[msg.sender].length);
    uint256 count = 0;
    
    for (uint256 i = 0; i < receivedMessages[msg.sender].length; i++) {
        uint256 messageId = receivedMessages[msg.sender][i];
        if (!messages[messageId].isDeleted && 
            messages[messageId].expirationTime > 0 && 
            block.timestamp > messages[messageId].expirationTime) {
            result[count] = messageId;
            count++;
        }
    }
    
    uint256[] memory filteredResult = new uint256[](count);
    for (uint256 i = 0; i < count; i++) {
        filteredResult[i] = result[i];
    }
    
    return filteredResult;
}

function purgeExpiredMessages() external gameIsActive playerExists {
    for (uint256 i = 0; i < receivedMessages[msg.sender].length; i++) {
        uint256 messageId = receivedMessages[msg.sender][i];
        if (!messages[messageId].isDeleted && 
            messages[messageId].expirationTime > 0 && 
            block.timestamp > messages[messageId].expirationTime) {
            messages[messageId].isDeleted = true;
        }
    }
}


struct GuildWar {
    uint256 warId;
    uint256 attackingGuildId;
    uint256 defendingGuildId;
    uint256 startTime;
    uint256 endTime;
    uint256 attackingScore;
    uint256 defendingScore;
    bool isActive;
    uint8 warStatus; // 0: Pending, 1: Active, 2: Ended
    uint256[] conqueredTerritories;
    mapping(address => uint256) playerContributions;
    uint256 winnerGuildId;
}
struct BattleResult {
    uint256 locationId;
    uint256 timestamp;
    address[] attackers;
    address[] defenders;
    uint8 outcome; // 0: Draw, 1: Attackers win, 2: Defenders win
    bool territoryChanged;
}

mapping(uint256 => GuildWar) public guildWars;
mapping(uint256 => mapping(uint256 => bool)) public guildsAtWar;
mapping(uint256 => uint256[]) public guildActiveWars;
mapping(uint256 => uint256[]) public guildWarHistory;
mapping(uint256 => mapping(uint256 => BattleResult)) public warBattles;
mapping(uint256 => uint256) public territoryOwner;
mapping(address => mapping(uint256 => uint256)) public playerWarScore;
event WarDeclared(uint256 attackingGuildId, uint256 defendingGuildId);

function declareWar(uint256 attackingGuildId, uint256 defendingGuildId) external gameIsActive playerExists {
    require(attackingGuildId != defendingGuildId, "Cannot declare war on your own guild");
   
    require(!guildsAtWar[attackingGuildId][defendingGuildId], "Already at war");    
    uint256 warId = uint256(keccak256(abi.encodePacked(attackingGuildId, defendingGuildId, block.timestamp)));
    
    GuildWar storage war = guildWars[warId];
    war.warId = warId;
    war.attackingGuildId = attackingGuildId;
    war.defendingGuildId = defendingGuildId;
    war.startTime = block.timestamp + 1 days; // 24h preparation
    war.endTime = war.startTime + 7 days;
    war.isActive = true;
    war.warStatus = 0; // Pending
    
    guildsAtWar[attackingGuildId][defendingGuildId] = true;
    guildsAtWar[defendingGuildId][attackingGuildId] = true;
    
    guildActiveWars[attackingGuildId].push(warId);
    guildActiveWars[defendingGuildId].push(warId);
    
    emit WarDeclared(attackingGuildId, defendingGuildId);
}

function joinBattle(uint256 warId, uint256 locationId, bool asAttacker) external gameIsActive playerExists {
    GuildWar storage war = guildWars[warId];
    require(war.isActive && war.warStatus == 1, "War not active");
    
    
    uint256 battleId = uint256(keccak256(abi.encodePacked(warId, locationId, block.timestamp)));
    BattleResult storage battle = warBattles[warId][battleId];
    
    if (battle.timestamp == 0) {
        // New battle
        battle.locationId = locationId;
        battle.timestamp = block.timestamp;
    }
    
    // Add player to battle
    if (asAttacker) {
        battle.attackers.push(msg.sender);
    } else {
        battle.defenders.push(msg.sender);
    }
    
    // Update player contribution
    war.playerContributions[msg.sender] += 10;
    playerWarScore[msg.sender][warId] += 10;
}
function resolveBattle(uint256 warId, uint256 battleId) external gameIsActive {
    GuildWar storage war = guildWars[warId];
    require(war.isActive && war.warStatus == 1, "War not active");
    
    BattleResult storage battle = warBattles[warId][battleId];
    require(battle.timestamp > 0 && battle.outcome == 0, "Battle invalid or already resolved");
    require(battle.attackers.length > 0 && battle.defenders.length > 0, "Need participants on both sides");
    
    // Simple battle resolution
    uint256 attackPower = battle.attackers.length * 10;
    uint256 defendPower = battle.defenders.length * 10;
    
    // Add random factor
    attackPower = attackPower * (80 + _random(40)) / 100;
    defendPower = defendPower * (80 + _random(40)) / 100;
    
    if (attackPower > defendPower) {
        battle.outcome = 1; // Attackers win
        war.attackingScore += 100;
        
        // Check for territory capture
        uint256 territoryId = battle.locationId; // Simplified mapping
        if (territoryOwner[territoryId] == war.defendingGuildId) {
            territoryOwner[territoryId] = war.attackingGuildId;
            battle.territoryChanged = true;
            war.conqueredTerritories.push(territoryId);
        }
    } else {
        battle.outcome = 2; // Defenders win
        war.defendingScore += 100;
    }
    
    // Award points to participants
    for (uint256 i = 0; i < battle.attackers.length; i++) {
        address player = battle.attackers[i];
        war.playerContributions[player] += battle.outcome == 1 ? 50 : 20;
        playerWarScore[player][warId] += battle.outcome == 1 ? 50 : 20;
    }
    
    for (uint256 i = 0; i < battle.defenders.length; i++) {
        address player = battle.defenders[i];
        war.playerContributions[player] += battle.outcome == 2 ? 50 : 20;
        playerWarScore[player][warId] += battle.outcome == 2 ? 50 : 20;
    }
}

function endWar(uint256 warId) external {
    GuildWar storage war = guildWars[warId];
    require(war.isActive, "War not active");
    require(block.timestamp >= war.endTime || msg.sender == gameOwner, "War still in progress");
    
    // Determine winner
    if (war.attackingScore > war.defendingScore) {
        war.winnerGuildId = war.attackingGuildId;
    } else if (war.defendingScore > war.attackingScore) {
        war.winnerGuildId = war.defendingGuildId;
    }
    
    war.isActive = false;
    war.warStatus = 2; // Ended
    
    // Update history
    guildWarHistory[war.attackingGuildId].push(warId);
    guildWarHistory[war.defendingGuildId].push(warId);
    
    // Remove from active wars
    removeFromActiveWars(war.attackingGuildId, warId);
    removeFromActiveWars(war.defendingGuildId, warId);
    
    // Reset war status
    guildsAtWar[war.attackingGuildId][war.defendingGuildId] = false;
    guildsAtWar[war.defendingGuildId][war.attackingGuildId] = false;
    
    // Distribute rewards
    distributeWarRewards(warId);
}

function distributeWarRewards(uint256 warId) internal {
    GuildWar storage war = guildWars[warId];
    
    // Simple reward distribution - top contributors get more
    for (uint256 i = 0; i < playerAddresses.length; i++) {
        address player = playerAddresses[i];
        uint256 contribution = war.playerContributions[player];
        
    }
}

function removeFromActiveWars(uint256 guildId, uint256 warId) internal {
    uint256[] storage activeWars = guildActiveWars[guildId];
    for (uint256 i = 0; i < activeWars.length; i++) {
        if (activeWars[i] == warId) {
            if (i < activeWars.length - 1) {
                activeWars[i] = activeWars[activeWars.length - 1];
            }
            activeWars.pop();
            break;
        }
    }
}

function getWarDetails(uint256 warId) external view returns (
    uint256 attackingGuildId,
    uint256 defendingGuildId,
    uint256 startTime,
    uint256 endTime,
    uint256 attackingScore,
    uint256 defendingScore,
    bool isActive,
    uint256 winnerGuildId
) {
    GuildWar storage war = guildWars[warId];
    return (
        war.attackingGuildId,
        war.defendingGuildId,
        war.startTime,
        war.endTime,
        war.attackingScore,
        war.defendingScore,
        war.isActive,
        war.winnerGuildId
    );
}

function getPlayerWarContribution(uint256 warId, address player) external view returns (uint256) {
    return guildWars[warId].playerContributions[player];
}


struct Guild {
    uint256 guildId;
    string name;
    string description;
    address founder;
    uint256 creationTime;
    uint256 level;
    uint256 experience;
    uint256 memberCount;
    uint256 treasury;
    uint256 reputation;
    bool isActive;
    uint256[] territories;
    uint256[] completedQuests;
    uint8 emblemId;
    uint8 bannerColor;
}

struct GuildMember {
    address playerAddress;
    uint256 joinTime;
    uint8 rank; // 0: Member, 1: Officer, 2: Leader
    uint256 contribution;
    uint256 lastActivityTime;
    bool isActive;
}

struct GuildRank {
    string name;
    bool canInvite;
    bool canKick;
    bool canPromote;
    bool canWithdraw;
    bool canDeclareWar;
    bool canEditMotd;
}

mapping(uint256 => Guild) public guilds;
mapping(uint256 => mapping(address => GuildMember)) public guildMembers;
mapping(address => uint256) public playerGuild;
mapping(string => bool) public guildNameTaken;
mapping(uint256 => address[]) public guildMemberList;
mapping(uint256 => uint256) public guildQuestProgress;
mapping(uint256 => string) public guildMotd;
mapping(uint256 => mapping(uint8 => GuildRank)) public guildRanks;
mapping(uint256 => uint256[]) public guildAlliances;
mapping(uint256 => mapping(uint256 => bool)) public guildsAllied;
mapping(uint256 => uint256) public nextGuildId;
event GuildCreated(address indexed founder, uint256 guildId, string guildName);

function createGuild(string memory guildName, string memory description, uint8 emblemId, uint8 bannerColor) external gameIsActive playerExists {
    require(bytes(guildName).length >= 3 && bytes(guildName).length <= 32, "Guild name must be 3-32 characters");
    require(bytes(description).length <= 200, "Description too long");
    require(playerGuild[msg.sender] == 0, "Already in a guild");
    require(!guildNameTaken[guildName], "Guild name already taken");
    require(players[msg.sender].level >= 10, "Must be at least level 10");
    require(players[msg.sender].gold >= 1000, "Need 1000 gold to create guild");
    
    uint256 guildId = nextGuildId[0]++;
    
    Guild storage newGuild = guilds[guildId];
    newGuild.guildId = guildId;
    newGuild.name = guildName;
    newGuild.description = description;
    newGuild.founder = msg.sender;
    newGuild.creationTime = block.timestamp;
    newGuild.level = 1;
    newGuild.experience = 0;
    newGuild.memberCount = 1;
    newGuild.treasury = 0;
    newGuild.reputation = 100;
    newGuild.isActive = true;
    newGuild.emblemId = emblemId;
    newGuild.bannerColor = bannerColor;
    
    GuildMember storage founderMember = guildMembers[guildId][msg.sender];
    founderMember.playerAddress = msg.sender;
    founderMember.joinTime = block.timestamp;
    founderMember.rank = 2; // Leader
    founderMember.contribution = 1000;
    founderMember.lastActivityTime = block.timestamp;
    founderMember.isActive = true;
    
    playerGuild[msg.sender] = guildId;
    guildNameTaken[guildName] = true;
    guildMemberList[guildId].push(msg.sender);
    
    // Set up default ranks
    GuildRank storage memberRank = guildRanks[guildId][0];
    memberRank.name = "Member";
    memberRank.canInvite = false;
    memberRank.canKick = false;
    memberRank.canPromote = false;
    memberRank.canWithdraw = false;
    memberRank.canDeclareWar = false;
    memberRank.canEditMotd = false;
    
    GuildRank storage officerRank = guildRanks[guildId][1];
    officerRank.name = "Officer";
    officerRank.canInvite = true;
    officerRank.canKick = true;
    officerRank.canPromote = false;
    officerRank.canWithdraw = true;
    officerRank.canDeclareWar = false;
    officerRank.canEditMotd = true;
    
    GuildRank storage leaderRank = guildRanks[guildId][2];
    leaderRank.name = "Leader";
    leaderRank.canInvite = true;
    leaderRank.canKick = true;
    leaderRank.canPromote = true;
    leaderRank.canWithdraw = true;
    leaderRank.canDeclareWar = true;
    leaderRank.canEditMotd = true;
    
    // Deduct creation fee
    players[msg.sender].gold -= 1000;
    newGuild.treasury += 1000;
    
    emit GuildCreated(msg.sender, guildId, guildName);
}

function joinGuild(uint256 guildId) external gameIsActive playerExists {
    require(guilds[guildId].isActive, "Guild does not exist");
    require(playerGuild[msg.sender] == 0, "Already in a guild");
    require(guilds[guildId].memberCount < 50, "Guild is full");
    
    Guild storage guild = guilds[guildId];
    guild.memberCount++;
    
    GuildMember storage newMember = guildMembers[guildId][msg.sender];
    newMember.playerAddress = msg.sender;
    newMember.joinTime = block.timestamp;
    newMember.rank = 0; // Member
    newMember.contribution = 0;
    newMember.lastActivityTime = block.timestamp;
    newMember.isActive = true;
    
    playerGuild[msg.sender] = guildId;
    guildMemberList[guildId].push(msg.sender);
}

function leaveGuild() external gameIsActive playerExists {
    uint256 guildId = playerGuild[msg.sender];
    require(guildId != 0, "Not in a guild");
    
    GuildMember storage member = guildMembers[guildId][msg.sender];
    require(member.rank < 2, "Guild leader cannot leave, transfer leadership first");
    
    Guild storage guild = guilds[guildId];
    guild.memberCount--;
    
    member.isActive = false;
    playerGuild[msg.sender] = 0;
    
    // Remove from member list
    for (uint256 i = 0; i < guildMemberList[guildId].length; i++) {
        if (guildMemberList[guildId][i] == msg.sender) {
            if (i < guildMemberList[guildId].length - 1) {
                guildMemberList[guildId][i] = guildMemberList[guildId][guildMemberList[guildId].length - 1];
            }
            guildMemberList[guildId].pop();
            break;
        }
    }
}

function contributeToGuild(uint256 amount) external gameIsActive playerExists {
    uint256 guildId = playerGuild[msg.sender];
    require(guildId != 0, "Not in a guild");
    require(players[msg.sender].gold >= amount, "Insufficient gold");
    
    players[msg.sender].gold -= amount;
    guilds[guildId].treasury += amount;
    guildMembers[guildId][msg.sender].contribution += amount;
    guildMembers[guildId][msg.sender].lastActivityTime = block.timestamp;
    
    // Add guild XP
    guilds[guildId].experience += amount / 10;
    checkGuildLevelUp(guildId);
}

function kickMember(address memberAddress) external gameIsActive playerExists {
    uint256 guildId = playerGuild[msg.sender];
    require(guildId != 0, "Not in a guild");
    
    GuildMember storage kicker = guildMembers[guildId][msg.sender];
    GuildMember storage member = guildMembers[guildId][memberAddress];
    
    require(kicker.rank >= 1, "Must be officer or leader to kick");
    require(member.isActive, "Member not in guild");
    require(kicker.rank > member.rank, "Cannot kick same or higher rank");
    
    Guild storage guild = guilds[guildId];
    guild.memberCount--;
    
    member.isActive = false;
    playerGuild[memberAddress] = 0;
    
    // Remove from member list
    for (uint256 i = 0; i < guildMemberList[guildId].length; i++) {
        if (guildMemberList[guildId][i] == memberAddress) {
            if (i < guildMemberList[guildId].length - 1) {
                guildMemberList[guildId][i] = guildMemberList[guildId][guildMemberList[guildId].length - 1];
            }
            guildMemberList[guildId].pop();
            break;
        }
    }
}

function promoteGuildMember(address memberAddress, uint8 newRank) external gameIsActive playerExists {
    uint256 guildId = playerGuild[msg.sender];
    require(guildId != 0, "Not in a guild");
    
    GuildMember storage promoter = guildMembers[guildId][msg.sender];
    GuildMember storage member = guildMembers[guildId][memberAddress];
    
    require(promoter.rank == 2, "Must be leader to promote");
    require(member.isActive, "Member not in guild");
    require(newRank > member.rank && newRank <= 2, "Invalid rank");
    
    // If promoting to leader, demote current leader
    if (newRank == 2) {
        promoter.rank = 1; // Demote to officer
    }
    
    member.rank = newRank;
}

function setGuildMotd(string memory motd) external gameIsActive playerExists {
    uint256 guildId = playerGuild[msg.sender];
    require(guildId != 0, "Not in a guild");
    
    GuildMember storage member = guildMembers[guildId][msg.sender];
    GuildRank storage rank = guildRanks[guildId][member.rank];
    
    require(rank.canEditMotd, "No permission to edit MOTD");
    require(bytes(motd).length <= 200, "MOTD too long");
    
    guildMotd[guildId] = motd;
}

function formAlliance(uint256 targetGuildId) external gameIsActive playerExists {
    uint256 guildId = playerGuild[msg.sender];
    require(guildId != 0, "Not in a guild");
    require(guildId != targetGuildId, "Cannot ally with self");
    require(guilds[targetGuildId].isActive, "Target guild does not exist");
    
    GuildMember storage member = guildMembers[guildId][msg.sender];
    require(member.rank == 2, "Must be leader to form alliance");
    
    require(!guildsAllied[guildId][targetGuildId], "Already allied");
    
    // This would typically require confirmation from the other guild
    // For simplicity, we'll make it one-sided
    guildsAllied[guildId][targetGuildId] = true;
    guildAlliances[guildId].push(targetGuildId);
}

function disbandGuild() external gameIsActive playerExists {
    uint256 guildId = playerGuild[msg.sender];
    require(guildId != 0, "Not in a guild");
    
    GuildMember storage member = guildMembers[guildId][msg.sender];
    require(member.rank == 2, "Must be leader to disband guild");
    
    Guild storage guild = guilds[guildId];
    guild.isActive = false;
    
    // Remove all members
    for (uint256 i = 0; i < guildMemberList[guildId].length; i++) {
        address memberAddress = guildMemberList[guildId][i];
        playerGuild[memberAddress] = 0;
        guildMembers[guildId][memberAddress].isActive = false;
    }
    
    // Free up guild name
    guildNameTaken[guild.name] = false;
}

function getGuildDetails(uint256 guildId) external view returns (
    string memory name,
    string memory description,
    address founder,
    uint256 creationTime,
    uint256 level,
    uint256 memberCount,
    uint256 treasury,
    bool isActive
) {
    Guild storage guild = guilds[guildId];
    return (
        guild.name,
        guild.description,
        guild.founder,
        guild.creationTime,
        guild.level,
        guild.memberCount,
        guild.treasury,
        guild.isActive
    );
}

function getGuildMembers(uint256 guildId) external view returns (address[] memory) {
    return guildMemberList[guildId];
}

function getMemberDetails(uint256 guildId, address memberAddress) external view returns (
    uint8 rank,
    uint256 joinTime,
    uint256 contribution,
    uint256 lastActivityTime,
    bool isActive
) {
    GuildMember storage member = guildMembers[guildId][memberAddress];
    return (
        member.rank,
        member.joinTime,
        member.contribution,
        member.lastActivityTime,
        member.isActive
    );
}

function checkGuildLevelUp(uint256 guildId) internal {
    Guild storage guild = guilds[guildId];
    uint256 requiredXP = guild.level * 1000;
    
    if (guild.experience >= requiredXP && guild.level < 10) {
        guild.level++;
        guild.experience -= requiredXP;
    }
}

function getPlayerGuild(address player) internal view returns (uint256) {
    return playerGuild[player];
}

function isGuildLeader(address player, uint256 guildId) internal view returns (bool) {
    return guildMembers[guildId][player].rank == 2;
}

function isGuildOfficer(address player, uint256 guildId) internal view returns (bool) {
    return guildMembers[guildId][player].rank >= 1;
}

function guildExists(uint256 guildId) internal view returns (bool) {
    return guilds[guildId].isActive;
}

function getGuildLeader(uint256 guildId) internal view returns (address) {
    for (uint256 i = 0; i < guildMemberList[guildId].length; i++) {
        address memberAddress = guildMemberList[guildId][i];
        if (guildMembers[guildId][memberAddress].rank == 2) {
            return memberAddress;
        }
    }
    return address(0);
}

function getTopGuilds(uint256 count) external view returns (uint256[] memory, string[] memory, uint256[] memory) {
    uint256[] memory topIds = new uint256[](count);
    string[] memory topNames = new string[](count);
    uint256[] memory topLevels = new uint256[](count);
    
    // Initialize with empty values
    for (uint256 i = 0; i < count; i++) {
        topIds[i] = 0;
        topNames[i] = "";
        topLevels[i] = 0;
    }
    
    // Find top guilds by level
    for (uint256 i = 1; i < nextGuildId[0]; i++) {
        if (!guilds[i].isActive) continue;
        
        uint256 guildLevel = guilds[i].level;
        
        // Check if this guild should be in the top list
        for (uint256 j = 0; j < count; j++) {
            if (guildLevel > topLevels[j]) {
                // Shift everyone down
                for (uint256 k = count - 1; k > j; k--) {
                    topIds[k] = topIds[k-1];
                    topNames[k] = topNames[k-1];
                    topLevels[k] = topLevels[k-1];
                }
                
                // Insert this guild
                topIds[j] = i;
                topNames[j] = guilds[i].name;
                topLevels[j] = guildLevel;
                break;
            }
        }
    }
    
    return (topIds, topNames, topLevels);
}

function getGuildRankPermissions(uint256 guildId, uint8 rank) external view returns (
    string memory name,
    bool canInvite,
    bool canKick,
    bool canPromote,
    bool canWithdraw,
    bool canDeclareWar,
    bool canEditMotd
) {
    GuildRank storage guildRank = guildRanks[guildId][rank];
    return (
        guildRank.name,
        guildRank.canInvite,
        guildRank.canKick,
        guildRank.canPromote,
        guildRank.canWithdraw,
        guildRank.canDeclareWar,
        guildRank.canEditMotd
    );
}

function setRankPermissions(uint256 guildId, uint8 rank, string memory name, bool canInvite, bool canKick, bool canPromote, bool canWithdraw, bool canDeclareWar, bool canEditMotd) external gameIsActive playerExists {
    require(isGuildLeader(msg.sender, guildId), "Must be guild leader");
    require(rank < 2, "Cannot modify leader rank");
    
    GuildRank storage guildRank = guildRanks[guildId][rank];
    guildRank.name = name;
    guildRank.canInvite = canInvite;
    guildRank.canKick = canKick;
    guildRank.canPromote = canPromote;
    guildRank.canWithdraw = canWithdraw;
    guildRank.canDeclareWar = canDeclareWar;
    guildRank.canEditMotd = canEditMotd;
}

function withdrawFromTreasury(uint256 amount) external gameIsActive playerExists {
    uint256 guildId = playerGuild[msg.sender];
    require(guildId != 0, "Not in a guild");
    
    GuildMember storage member = guildMembers[guildId][msg.sender];
    GuildRank storage rank = guildRanks[guildId][member.rank];
    
    require(rank.canWithdraw, "No permission to withdraw");
    require(guilds[guildId].treasury >= amount, "Insufficient guild funds");
    
    guilds[guildId].treasury -= amount;
    players[msg.sender].gold += amount;
}

function startGuildQuest(uint256 questId) external gameIsActive playerExists {
    uint256 guildId = playerGuild[msg.sender];
    require(guildId != 0, "Not in a guild");
    require(isGuildOfficer(msg.sender, guildId), "Must be officer or leader");
    require(guildQuestProgress[guildId] == 0, "Guild already on a quest");
    
    // This would check if the quest exists and is valid for guilds
    // For simplicity, we'll assume it is
    
    guildQuestProgress[guildId] = questId;
}

function completeGuildQuest() external gameIsActive playerExists {
    uint256 guildId = playerGuild[msg.sender];
    require(guildId != 0, "Not in a guild");
    require(isGuildOfficer(msg.sender, guildId), "Must be officer or leader");
    
    uint256 questId = guildQuestProgress[guildId];
    require(questId != 0, "No active guild quest");
    
    // This would check if the quest is actually complete
    // For simplicity, we'll assume it is
    
    // Add quest rewards
    guilds[guildId].treasury += 1000;
    guilds[guildId].experience += 500;
    guilds[guildId].completedQuests.push(questId);
    
    // Reset quest progress
    guildQuestProgress[guildId] = 0;
    
    // Check for level up
    checkGuildLevelUp(guildId);
}

function updateGuildDescription(string memory newDescription) external gameIsActive playerExists {
    uint256 guildId = playerGuild[msg.sender];
    require(guildId != 0, "Not in a guild");
    require(isGuildOfficer(msg.sender, guildId), "Must be officer or leader");
    require(bytes(newDescription).length <= 200, "Description too long");
    
    guilds[guildId].description = newDescription;
}

function updateGuildEmblem(uint8 emblemId, uint8 bannerColor) external gameIsActive playerExists {
    uint256 guildId = playerGuild[msg.sender];
    require(guildId != 0, "Not in a guild");
    require(isGuildLeader(msg.sender, guildId), "Must be guild leader");
    
    guilds[guildId].emblemId = emblemId;
    guilds[guildId].bannerColor = bannerColor;
}

function getGuildCompletedQuests(uint256 guildId) external view returns (uint256[] memory) {
    return guilds[guildId].completedQuests;
}

function getGuildAlliances(uint256 guildId) external view returns (uint256[] memory) {
    return guildAlliances[guildId];
}

function checkGuildAlliance(uint256 guildId1, uint256 guildId2) external view returns (bool) {
    return guildsAllied[guildId1][guildId2];
}

function getGuildMotd(uint256 guildId) external view returns (string memory) {
    return guildMotd[guildId];
}

function getGuildTerritories(uint256 guildId) external view returns (uint256[] memory) {
    return guilds[guildId].territories;
}

function getPlayerGuildId(address player) external view returns (uint256) {
    return playerGuild[player];
}

function getGuildMemberCount(uint256 guildId) external view returns (uint256) {
    return guilds[guildId].memberCount;
}

function getGuildActiveQuest(uint256 guildId) external view returns (uint256) {
    return guildQuestProgress[guildId];
}

function getGuildExperience(uint256 guildId) external view returns (uint256 level, uint256 experience, uint256 nextLevelExperience) {
    Guild storage guild = guilds[guildId];
    return (guild.level, guild.experience, guild.level * 1000);
}

function getTopContributors(uint256 guildId, uint256 count) external view returns (address[] memory, uint256[] memory) {
    address[] memory contributors = new address[](count);
    uint256[] memory contributions = new uint256[](count);
    
    // Initialize with empty values
    for (uint256 i = 0; i < count; i++) {
        contributors[i] = address(0);
        contributions[i] = 0;
    }
    
    // Find top contributors
    for (uint256 i = 0; i < guildMemberList[guildId].length; i++) {
        address memberAddress = guildMemberList[guildId][i];
        uint256 contribution = guildMembers[guildId][memberAddress].contribution;
        
        // Check if this member should be in the top list
        for (uint256 j = 0; j < count; j++) {
            if (contribution > contributions[j]) {
                // Shift everyone down
                for (uint256 k = count - 1; k > j; k--) {
                    contributors[k] = contributors[k-1];
                    contributions[k] = contributions[k-1];
                }
                
                // Insert this member
                contributors[j] = memberAddress;
                contributions[j] = contribution;
                break;
            }
        }
    }
    
    return (contributors, contributions);
}



// State variables declared at contract level
mapping(address => string[]) private playerTitles;
mapping(address => uint256) private titleCount;
address[] private specialTitleHolders;
mapping(address => uint256) private playerRarity; // Store rarity scores for players

// Event declarations
event PlayerTitleEarned(address indexed player, string title);
event RareAchievement(address indexed player, string title, uint256 rarityScore);

/**
 * @notice Awards a title to a player with random rarity effects
 * @param player The address of the player receiving the title
 * @param title The title being awarded
 */
function awardPlayerTitle(address player, string memory title) public {
    // Store the title in the mapping
    playerTitles[player].push(title);
    
    // Update the counter
    titleCount[player] += 1;
    
    // Generate pseudo-random number using various chain data
    // Note: This is not cryptographically secure randomness
    uint256 randomValue = uint256(
        keccak256(
            abi.encodePacked(
                blockhash(block.number - 1),
                block.timestamp,
                player,
                titleCount[player],
                msg.sender
            )
        )
    );
    
    // Calculate rarity score (0-100)
    uint256 rarityScore = randomValue % 101;
    
    // Check if this is a special achievement
    bool isSpecialTitle = keccak256(bytes(title)) == keccak256(bytes("Champion")) ||
                         keccak256(bytes(title)) == keccak256(bytes("Legend"));
    
    // Apply any special effects for certain titles
    if (isSpecialTitle) {
        specialTitleHolders.push(player);
        
        // Bonus effect: Legendary titles have a chance to be "Mythic" versions
        if (rarityScore > 90) {
            // 10% chance to upgrade to a mythic version
            playerTitles[player][playerTitles[player].length - 1] = string.concat(
                "Mythic ", 
                title
            );
            
            // Emit special event for rare achievement
            emit RareAchievement(player, string.concat("Mythic ", title), rarityScore);
        }
    } else {
        // For regular titles, there's a small chance to get a special modifier
        if (rarityScore > 95) {
            // 5% chance to add "Illustrious" prefix
            playerTitles[player][playerTitles[player].length - 1] = string.concat(
                "Illustrious ", 
                title
            );
            
            // Emit special event for rare achievement
            emit RareAchievement(player, string.concat("Illustrious ", title), rarityScore);
        }
    }
    
    // Store player's rarity score (could be used for future mechanics)
    playerRarity[player] = (playerRarity[player] + rarityScore) / 2; // Average with previous score
    
    // Random bonus: Players with high luck occasionally get double titles
    if (rarityScore > 98 && bytes(title).length < 20) {
        // 2% chance to get an additional random title
        string[5] memory bonusTitles = [
            "Lucky", 
            "Fortunate", 
            "Blessed", 
            "Favored", 
            "Charmed"
        ];
        
        string memory bonusTitle = bonusTitles[randomValue % 5];
        playerTitles[player].push(bonusTitle);
        titleCount[player] += 1;
        
        // Emit event for the bonus title too
        emit PlayerTitleEarned(player, bonusTitle);
    }
    
    // Emit the event for the main title
    emit PlayerTitleEarned(player, playerTitles[player][playerTitles[player].length - 1]);
}




// // State variables declared at contract level
// mapping(address => string[]) private playerTitles;
// mapping(address => uint256) private titleCount;
// address[] private specialTitleHolders;

// // Event declaration
// event PlayerTitleEarned(address indexed player, string title);

// function awardPlayerTitle(address player, string memory title) public {
//     // Store the title in the mapping
//     playerTitles[player].push(title);
    
//     // Update the counter
//     titleCount[player] += 1;
    
//     // Check if this is a special achievement
//     bool isSpecialTitle = keccak256(bytes(title)) == keccak256(bytes("Champion")) ||
//                          keccak256(bytes(title)) == keccak256(bytes("Legend"));
    
//     // Apply any special effects for certain titles
//     if (isSpecialTitle) {
//         specialTitleHolders.push(player);
//     }
    
//     // Emit the event
//     emit PlayerTitleEarned(player, title);
// }







}
