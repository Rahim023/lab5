# Pokémon Battle App (Flutter Web)

This project is part of Lab 5 – Mobile Applications (Flutter).  
Previously, in Lab 4, I worked with a different Pokémon API which sometimes stopped responding or delayed the results to show project on web-page.  
That caused the app to load slowly or not load cards at all, therefore i changed the codes and Api of the App. So, i made some changes.  

## In this Lab 5, I improved the app by:
- Using a more stable API endpoint (Pokémon TCG API)
- Fetching only usable card data (only cards with HP)     //HP - High Power
- Improving UI layout to prevent overflow issues.
- Adding one-click battle, show cards mode, and a cleaner battle screen.

This version is much faster, smoother, and works consistently.

---

## App Features.

| Feature | Description |
|--------|-------------|
| **Random Battle** | Press **FIGHT!** to pick 2 random Pokémon and compare HP |
| **Show Cards Grid** | Displays a responsive gallery with all fetched Pokémon cards |
| **Battle Screen** | Two Pokémon shown side-by-side with HP comparison & winner |
| **HP-Based Winner** | The Pokémon with higher HP is declared the winner |
| **Responsive UI** | Works on web, desktop browser & mobile-sized windows |


---

## How It Works

1. When the app starts, it fetches cards once from the API.
2. All cards are stored in a **local list (`pool`)**.
3. Pressing **FIGHT!**:
   - Selects **two different random cards**.
   - Extracts their **HP**.
   - Declares a winner.
4. Pressing **Show Cards** switches the screen to a **grid gallery**.
5. Pressing **Battle** returns back to the **battle screen**.

---

## UI Structure Overview

AppBar: "Pokémon Battle"
|
|--- Top: Status text (winner result)
|
|--- Center: Fight Button
|
|--- Main Area:
| Battle Mode: 2 Cards Side-by-Side
| Cards Mode: Gallery Grid of All Cards
|
|--- Bottom Bar:
[ Show Cards ] [ Battle ]


## Examples:

## Incorrect code (Causes Same Pokémon Appearing Twice):

// This selects two random indexes, but they might be the same.
final i = Random().nextInt(pool.length);
final j = Random().nextInt(pool.length);

left = pool[i];
right = pool[j]; // Sometimes left and right become the SAME Pokémon


 // Issues:

Sometimes both Pokémon are identical, which makes the battle pointless.
No logic ensures the second index is different.
Visually looks broken because the user sees the same card twice.

## Correct code (Your Working Code):

final r = Random();
var i = r.nextInt(pool.length);
var j = r.nextInt(pool.length);
while (j == i) {
  j = r.nextInt(pool.length); // ensures cards are different
}
left = pool[i] as Map<String, dynamic>;
right = pool[j] as Map<String, dynamic>;


Why this is better:

The while (j == i) loop ensures the second Pokémon is always different.
This makes every fight visually meaningful and prevents duplicates.
It improves gameplay experience while still using simple logic.


Example 2 — Comparing HP Safely + Displaying Proper Winner Name:

## Incorrect code (Crashes + Wrong Text)
// If 'hp' is missing or stored as a string, this throws an error.
if (left!['hp'] > right!['hp']) {
  status = 'Left wins';
} else {
  status = 'Right wins';
}


// Problems:
hp is often a string, not a number → crash.
No handling of Draw / Equal HP situation.
Winner text is not meaningful ("Left" and "Right" are not Pokémon names).

## Correct code (Your Final Working Logic):
final lh = int.tryParse((left!['hp']).toString()) ?? 0;
final rh = int.tryParse((right!['hp']).toString()) ?? 0;

if (lh > rh) {
  status = '${left!['name']} wins!';
} else if (rh > lh) {
  status = '${right!['name']} wins!';
} else {
  status = 'Draw! Same HP';
}


// Why this is better:

int.tryParse(...) ?? 0 prevents runtime crashes.
Displays Pokémon names → clear, user-friendly result.
Handles Draw case fairly.
Makes the output feel like a real Pokémon battle.

Example 3 — Switching Screens (Battle View ↔ Card Grid);

## Incorrect code (UI Does NOT Refresh)
// Changes the mode but does not update the UI
mode = ViewMode.cards;
mode = ViewMode.battle;


// Issues:

UI stays frozen, because Flutter does not know the state changed.

Buttons appear to do nothing → user confusion.

This is a common mistake when managing UI state manually.

## Correct code (Your Final Code Using setState):
Future<void> _showCards() async {
  await _ensurePool();              // Ensure data is loaded
  setState(() => mode = ViewMode.cards);
}

void _showBattleView() {
  setState(() => mode = ViewMode.battle);
}


// Why this works:

setState() tells Flutter to rebuild the UI with the new mode.
Switching between screens becomes instant and smooth.
_ensurePool() ensures data loads only once → faster performance.
Gives the app a clean and controlled screen change experience.

## Dependencies Used
Package	Purpose
http	Fetching Pokémon data from API
cached_network_image	Smooth image loading with caching
material3 theme	Modern UI styling

## API Used: 
Pokémon TCG API
https://api.pokemontcg.io/v2/cards

Request Header:

makefile
Copy code
X-Api-Key: YOUR_KEY

## How To Run:

flutter pub get  //to get dependencies
flutter run -d chrome    //to run the app


## GitHub Pages Deployment
Live URL:
https://saultjashan0001.github.io/lab5_mob_applications
