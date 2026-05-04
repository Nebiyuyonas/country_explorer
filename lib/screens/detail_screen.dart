import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../models/country.dart';
import '../services/favorites_service.dart';

class DetailScreen extends StatefulWidget {
  final Country country;

  const DetailScreen({super.key, required this.country});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  bool _isFavorite = false;
  bool _loadingFav = true;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final result = await _favoritesService.isFavorite(widget.country.name);
    setState(() {
      _isFavorite = result;
      _loadingFav = false;
    });
  }

  Future<void> _toggleFavorite() async {
    await _favoritesService.toggleFavorite(widget.country);
    setState(() => _isFavorite = !_isFavorite);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite
              ? '${widget.country.name} added to favourites'
              : '${widget.country.name} removed from favourites',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareCountry() {
    final c = widget.country;

    // Format population: show as e.g. "331.4M" or "4.9K"
    String formatPop(int pop) {
      if (pop >= 1000000000) {
        return '${(pop / 1000000000).toStringAsFixed(1)}B';
      } else if (pop >= 1000000) {
        return '${(pop / 1000000).toStringAsFixed(1)}M';
      } else if (pop >= 1000) {
        return '${(pop / 1000).toStringAsFixed(1)}K';
      }
      return pop.toString();
    }

    final text =
        '''
${c.flagEmoji} ${c.name}
Official name: ${c.officialName}
Capital: ${c.capital}
Region: ${c.region}${c.subregion.isNotEmpty ? ' › ${c.subregion}' : ''}
Population: ${formatPop(c.population)}
Area: ${c.area.toStringAsFixed(0)} km²
Currencies: ${c.currencies.join(', ')}
Languages: ${c.languages.join(', ')}
Timezones: ${c.timezones.join(', ')}

Shared from Country Explorer 🌍
'''
            .trim();

    Share.share(text, subject: '${c.flagEmoji} ${c.name} — Country Info');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final country = widget.country;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Country Details'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        actions: [
          // Share button
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share country info',
            onPressed: _shareCountry,
          ),
          // Favourite button
          _loadingFav
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.redAccent[100] : Colors.white,
                  ),
                  tooltip: _isFavorite
                      ? 'Remove from favourites'
                      : 'Add to favourites',
                  onPressed: _toggleFavorite,
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 6,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(country.flagEmoji, style: const TextStyle(fontSize: 72)),
                const SizedBox(height: 10),
                Text(
                  country.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  country.officialName,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 12),
                _DetailRow(label: 'Capital', value: country.capital),
                _DetailRow(
                  label: 'Region',
                  value: country.subregion.isNotEmpty
                      ? '${country.region} › ${country.subregion}'
                      : country.region,
                ),
                _DetailRow(
                  label: 'Population',
                  value: _formatNumber(country.population),
                ),
                _DetailRow(
                  label: 'Area',
                  value: '${_formatNumber(country.area.toInt())} km²',
                ),
                _DetailRow(
                  label: 'Currencies',
                  value: country.currencies.join(', '),
                ),
                _DetailRow(
                  label: 'Languages',
                  value: country.languages.join(', '),
                ),
                _DetailRow(
                  label: 'Timezones',
                  value: country.timezones.join(', '),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    final str = number.toString();
    final buffer = StringBuffer();
    final offset = str.length % 3;
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (i - offset) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}

// ---------- Two-column detail row ----------

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontSize: 13,
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
