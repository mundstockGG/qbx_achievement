# Achievements Handler Resource

This resource integrates achievements (trophies) into your FiveM server using the **ictrophies** system. It handles multiple events (such as first drive, first kill of a specific ped, and first drink of a specific item) and persists achievement data in a database.

## Folder Structure

qbx_achievements/
├── fxmanifest.lua
├── README.md
├── sql
│   └── players_achievements.sql
├── client
│   └── main.lua
└── server
    └── main.lua


## How It Works

- **Database Persistence:**  
  When a player spawns, the client requests their achievement data from the server, which retrieves the data from a database table (`user_achievements`). If a record doesn't exist, it is created with default values.

- **Event Detection:**  
  The resource monitors events:
  - **First Travel (Driving):** Detects when a player drives for the first time.
  - **First Kill of a Specific Ped:** Detects when a specific ped is killed for the first time.
  - **First Drink of a Specific Item:** Detects when a player drinks a designated item.
  
  When an event occurs for the first time, the trophy is awarded via the **ictrophies** export, and the achievement status is updated in the database.

## Adding More Achievements

### Server-Side
- **Database Changes:**  
  - Add a new column to your `user_achievements` table (e.g., `isNewAchievement TINYINT(1) DEFAULT 0`).
  - Modify the SQL queries in `server/main.lua` to fetch and update the new field.

- **Update the Server Event:**  
  - In `server/main.lua`, extend the `qbx_achievements:updateAchievement` event by adding another `elseif` branch for your new achievement key.

### Client-Side
- **Local Flag:**  
  - Add a new field in the `eventStatus` table in `client/main.lua` (for example, `newAchievement = false`).

- **Event Detection:**  
  - Create a new detection thread or event listener that triggers when the new achievement condition is met.
  - When the event is detected (and if it has not already been earned), call:
    ```lua
    exports["ictrophies"]:NewTrophy("newAchievement")
    TriggerServerEvent('qbx_achievements:updateAchievement', "newAchievement", true)
    ```
- **Config Updates:**  
  - Make sure to update the trophy configuration (typically in the **ictrophies** config file) with a new entry for `"newAchievement"`.

## Custom Events

You can trigger achievements using custom events. For example, if your inventory system fires an event when a player drinks an item, you can handle it like this in **client/main.lua**:

```lua
RegisterNetEvent('playerDrankItem', function(itemName)
    if itemName == "special_drink" and not eventStatus.drinkItem then
        eventStatus.drinkItem = true
        exports["ictrophies"]:NewTrophy("drinkItem")
        TriggerServerEvent('qbx_achievements:updateAchievement', "drinkItem", true)
    end
end)
