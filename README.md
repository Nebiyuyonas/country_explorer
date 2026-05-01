# Country Explorer

**Name:** Nebiyu Yonas  
**Student ID:** ATE/7602/15  
**Track:** A – Country Explorer (RestCountries API)

## Description
A Flutter app that displays all countries of the world, allows searching by name (with debouncing), and shows detailed information for each country (capital, population, currencies, languages, area, timezones).

## How to run locally
1. Ensure Flutter is installed (see [flutter.dev](https://flutter.dev)).
2. Clone the repository:  
   `git clone https://github.com/Nebiyuyonas/country_explorer.git`
3. Navigate to the project folder: `cd country_explorer`
4. Run `flutter pub get` to install dependencies.
5. Run the app: `flutter run -d chrome` (or on an Android emulator).

## API Endpoints used
- `GET /all?fields=name,flags,region,capital,population,currencies,languages,area,timezones,cca3` – fetch all countries
- `GET /name/{name}` – search by country name
- `GET /alpha/{code}` – fetch single country details

## Known limitations / bugs
- No internet connection triggers an error message with a Retry button (behaves as required).
- Some country flags fallback to 🏳️ if the API does not provide a flag emoji.
- Search debouncing works as a bonus feature (calls API only after 400ms of no typing).

## Bonus features
- Search debouncing (400ms delay, +5 marks)