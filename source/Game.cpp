#include "Game.h"
// Q4 - Assume all method calls work fine. Fix the memory leak issue in below method
// We assume every function call works, in other cases we should
// add assertion checks, works faster than exceptions
void Game::addItemToPlayer(const std::string& recipient, uint16_t itemId)
{
	Player* player = g_game.getPlayerByName(recipient);
	if (!player) {
		player = new Player(nullptr); // Here we create a new player object allocating memory 
		if (!IOLoginData::loadPlayerByName(player, recipient)) {
			delete player; // if the player is not found release the memory
			return; 
		}
	}

	Item* item = Item::CreateItem(itemId); // This looks like a factory pattern 
	if (!item) {
		if(player)
			delete player; // if the item creation fails release the memory
		return;
	}

	g_game.internalAddItem(player->getInbox(), item, INDEX_WHEREEVER, FLAG_NOLIMIT); 

	if (player->isOffline()) {
		IOLoginData::savePlayer(player); 
		delete player; // if the player is offline release the memory
	}
}