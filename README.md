# Country Explorer

**Student:** Nebiyu Yonas  
**ID:** ATE/7602/15  
**Track:** A – Country Explorer (RestCountries API)  
**Instructor:** Abel Tadesse  

## 📌 Overview
This Flutter app shows all countries of the world. You can search (with a 400ms delay to avoid spamming the API), tap a country to see detailed info (capital, population, currency, languages, area, timezones), and I added several bonus features to make it more useful.

## ✨ Bonus features (all working)
- **Random country button** – one tap opens a random country’s details.
- **Favourites** – heart any country; they are saved even after closing the app (using `shared_preferences`). There’s a separate Favourites screen.
- **Dark / Light mode** – toggle in the app bar; your preference is remembered.
- **Share country info** – on the detail screen, a share button lets you send a country summary via any app (WhatsApp, email, etc.) using `share_plus`.
- **Search debouncing** (already included as required bonus).

## 🎥 Demo video
Watch the full screen recording (shows all features, including error handling and retry):  
👉 [Country Explorer Demo on Google Drive](https://drive.google.com/file/d/1C6YQA3sNLY2p547ruvirjxPDqw4feYxe/view?usp=sharing)

## 🚀 How to run
1. Clone the repo:  
   `git clone https://github.com/Nebiyuyonas/country_explorer.git`
2. Enter the folder: `cd country_explorer`
3. Install dependencies: `flutter pub get`
4. Run the app: `flutter run` (use `-d chrome` for web or an emulator)

## 🌐 API and packages used
- **RestCountries API** – free, no API key (`https://restcountries.com/v3.1`)
- `http` – for API calls
- `shared_preferences` – store theme preference and favourites
- `share_plus` – share country info

## ⚠️ Known small issues
- If you turn off Wi‑Fi, the app shows an error and a Retry button – that’s the required behaviour.
- Some flags are missing from the API and show a default emoji (`🏳️`).
- The app works on Chrome and Android emulator; I tested both.

## 📁 Project structure (simplified)