# Pokémon Flutter App

A Flutter-based Pokémon card app that allows users to browse Pokémon cards, view details, and battle Pokémon interactively.

---

## 🌟 Features

- **Pokémon Card List:** Browse hundreds of Pokémon cards fetched from the Pokémon TCG API.  
- **Card Details:** View detailed stats, images, and attacks for each Pokémon.  
- **Battle Mode:** Select two Pokémon to simulate a battle using HP, Attack, and Type attributes.  
- **Cached Images:** Smooth image loading with caching for better performance.  
- **User-Friendly UI:** Intuitive interface designed using Flutter widgets.  

---

## 🥊 Battle Feature

The **Battle Mode** brings an exciting interactive experience for users:

- Select two Pokémon from the list.  
- The app retrieves their stats (HP, Attack, Type) from the backend API.  
- A comparison algorithm determines the winner dynamically.  
- Visual animations and feedback enhance the battle experience.

**Future Improvements:**  
- Multiplayer online battles.  
- Special moves and type advantages.  
- Enhanced UI animations for battle effects.

---

## ⚙️ Installation

1. **Clone the repository**  
```bash
git clone https://github.com/yourusername/pokemon-flutter-app.git
Navigate to the project directory

bash
Copy code
cd pokemon-flutter-app
Install dependencies

bash
Copy code
flutter pub get
Run the app

bash
Copy code
flutter run
🛠 Tech Stack
Frontend: Flutter (Dart)

Backend: Node.js + Express (Pokémon API integration)

API: Pokémon TCG API

Image Loading: cached_network_image

State Management: setState / Provider

📚 Credits
Rahim – Conceptualized and developed the app, implemented core features including the card list, battle system, and UI design.

ChatGPT (GPT-5) – Assisted with code suggestions, battle logic, API integration guidance, and documentation.

Pokémon TCG API – Provided Pokémon card data and images.

Flutter & Dart – Framework and language used to build the mobile application.

Open Source Libraries – Packages like cached_network_image for smooth image loading.