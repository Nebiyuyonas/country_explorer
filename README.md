# Country Explorer

**Name:** Nebiyu Yonas  
**Student ID:** ATE/7602/15  
**Track:** A – Country Explorer (RestCountries API)

## Description
A Flutter app that displays all countries of the world, allows searching by name (with debouncing), shows detailed country information, and includes **bonus features**:  
- **Random Country button** (Floating Action Button) – instantly opens a random country’s details.  
- **Favorites** – save countries to a persistent list using `shared_preferences`. Favorites survive app restarts and are accessible from a dedicated screen.

## How to run locally
1. Ensure Flutter is installed.
2. Clone the repository:  
   `git clone https://github.com/Nebiyuyonas/country_explorer.git`
3. Navigate to the project folder and run `flutter pub get`.
4. Run the app: `flutter run -d chrome` (or on an Android emulator).

## API Endpoints used
- `GET /all?fields=name,flags,region,capital,population,currencies,languages,area,timezones,cca3`
- `GET /name/{name}` (search)
- `GET /alpha/{code}` (detail screen)

## Bonus features implemented
-  **Search debouncing** (400ms delay) 
-  **Random Country button**  
-  **Favorites with local persistence** 

## Known limitations / bugs
- No internet connection triggers error message with Retry button (works as expected).
- Some country flags fallback to 🏳️ if the API does not provide an emoji.