import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/country.dart';

class FavoritesService {
  static const String _key = 'favorite_countries';

  Future<List<Country>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];
    return jsonList.map((s) => Country.fromJson(jsonDecode(s))).toList();
  }

  Future<void> saveFavorites(List<Country> countries) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = countries.map((c) => jsonEncode(c.toJson())).toList();
    await prefs.setStringList(_key, jsonList);
  }

  Future<bool> isFavorite(String countryName) async {
    final favorites = await loadFavorites();
    return favorites.any((c) => c.name == countryName);
  }

  Future<List<Country>> toggleFavorite(Country country) async {
    final favorites = await loadFavorites();
    final exists = favorites.any((c) => c.name == country.name);
    if (exists) {
      favorites.removeWhere((c) => c.name == country.name);
    } else {
      favorites.add(country);
    }
    await saveFavorites(favorites);
    return favorites;
  }
}
