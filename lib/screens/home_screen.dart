import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import '../models/country.dart';
import '../services/country_api_service.dart';
import '../services/favorites_service.dart';
import '../services/theme_service.dart';
import 'detail_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  final ThemeService themeService;

  const HomeScreen({super.key, required this.themeService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CountryApiService _service = CountryApiService();
  final FavoritesService _favoritesService = FavoritesService();
  final TextEditingController _searchController = TextEditingController();

  late Future<List<Country>> _countriesFuture;
  Set<String> _favoriteNames = {};
  Timer? _debounce;
  List<Country> _loadedCountries = [];

  @override
  void initState() {
    super.initState();
    _countriesFuture = _fetchAndCache();
    _loadFavoriteNames();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Country>> _fetchAndCache() async {
    final result = await _service.fetchAllCountries();
    _loadedCountries = result;
    return result;
  }

  Future<void> _loadFavoriteNames() async {
    final favs = await _favoritesService.loadFavorites();
    setState(() => _favoriteNames = favs.map((c) => c.name).toSet());
  }

  Future<void> _toggleFavorite(Country country) async {
    final updated = await _favoritesService.toggleFavorite(country);
    setState(() => _favoriteNames = updated.map((c) => c.name).toSet());
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      setState(() {
        if (query.trim().isEmpty) {
          _countriesFuture = _fetchAndCache();
        } else {
          _countriesFuture = _service.searchCountries(query);
        }
      });
    });
  }

  void _retry() {
    setState(() {
      if (_searchController.text.trim().isEmpty) {
        _countriesFuture = _fetchAndCache();
      } else {
        _countriesFuture = _service.searchCountries(_searchController.text);
      }
    });
  }

  void _goToRandomCountry() {
    if (_loadedCountries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Countries are still loading, please wait…'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final random = Random();
    final country = _loadedCountries[random.nextInt(_loadedCountries.length)];
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailScreen(country: country)),
    ).then((_) => _loadFavoriteNames());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Countries',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        actions: [
          // Dark/Light theme toggle button
          IconButton(
            icon: Icon(
              widget.themeService.isDark ? Icons.light_mode : Icons.dark_mode,
            ),
            tooltip: 'Toggle theme',
            onPressed: () => widget.themeService.toggleTheme(),
          ),
          // Favourites screen button
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Favourites',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              );
              _loadFavoriteNames();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search countries…',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.2),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToRandomCountry,
        icon: const Icon(Icons.shuffle),
        label: const Text('Random'),
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
      ),
      body: FutureBuilder<List<Country>>(
        future: _countriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _buildError(snapshot.error.toString());
          }
          final countries = snapshot.data ?? [];
          if (countries.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No countries found.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: countries.length,
            itemBuilder: (context, index) {
              final country = countries[index];
              final isFav = _favoriteNames.contains(country.name);
              return _CountryCard(
                country: country,
                isFavorite: isFav,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailScreen(country: country),
                    ),
                  );
                  _loadFavoriteNames();
                },
                onToggleFavorite: () => _toggleFavorite(country),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _retry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountryCard extends StatelessWidget {
  final Country country;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const _CountryCard({
    required this.country,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 3,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Text(country.flagEmoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      country.name,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      country.region,
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.redAccent : Colors.grey,
                ),
                onPressed: onToggleFavorite,
                tooltip: isFavorite
                    ? 'Remove from favourites'
                    : 'Add to favourites',
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
