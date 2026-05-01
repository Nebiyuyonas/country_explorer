class Country {
  final String name;
  final String officialName;
  final String flagEmoji;
  final String region;
  final String subregion;
  final String capital;
  final int population;
  final double area;
  final List<String> currencies;
  final List<String> languages;
  final List<String> timezones;

  const Country({
    required this.name,
    required this.officialName,
    required this.flagEmoji,
    required this.region,
    required this.subregion,
    required this.capital,
    required this.population,
    required this.area,
    required this.currencies,
    required this.languages,
    required this.timezones,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    // Name
    final nameObj = json['name'] as Map<String, dynamic>? ?? {};
    final commonName = nameObj['common'] as String? ?? 'Unknown';
    final officialName = nameObj['official'] as String? ?? commonName;

    // Flag emoji
    final flagEmoji = json['flag'] as String? ?? '🏳';

    // Region / subregion
    final region = json['region'] as String? ?? 'Unknown';
    final subregion = json['subregion'] as String? ?? '';

    // Capital
    final capitalList = json['capital'];
    final capital = (capitalList is List && capitalList.isNotEmpty)
        ? capitalList.first as String
        : 'N/A';

    // Population & area
    final population = (json['population'] as num?)?.toInt() ?? 0;
    final area = (json['area'] as num?)?.toDouble() ?? 0.0;

    // Currencies
    final currenciesMap = json['currencies'] as Map<String, dynamic>?;
    final currencies = currenciesMap != null
        ? currenciesMap.values.map((c) {
            final curr = c as Map<String, dynamic>;
            final cName = curr['name'] as String? ?? '';
            final symbol = curr['symbol'] as String? ?? '';
            return symbol.isNotEmpty ? '$cName ($symbol)' : cName;
          }).toList()
        : <String>['N/A'];

    // Languages
    final languagesMap = json['languages'] as Map<String, dynamic>?;
    final languages = languagesMap != null
        ? languagesMap.values.map((l) => l as String).toList()
        : <String>['N/A'];

    // Timezones
    final timezonesList = json['timezones'] as List<dynamic>?;
    final timezones = timezonesList != null
        ? timezonesList.map((t) => t as String).toList()
        : <String>['N/A'];

    return Country(
      name: commonName,
      officialName: officialName,
      flagEmoji: flagEmoji,
      region: region,
      subregion: subregion,
      capital: capital,
      population: population,
      area: area,
      currencies: currencies,
      languages: languages,
      timezones: timezones,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': {'common': name, 'official': officialName},
      'flag': flagEmoji,
      'region': region,
      'subregion': subregion,
      'capital': [capital],
      'population': population,
      'area': area,
      'currencies': {for (var c in currencies) c: {}},
      'languages': {for (var l in languages) l: l},
      'timezones': timezones,
    };
  }

  Country copyWith({
    String? name,
    String? officialName,
    String? flagEmoji,
    String? region,
    String? subregion,
    String? capital,
    int? population,
    double? area,
    List<String>? currencies,
    List<String>? languages,
    List<String>? timezones,
  }) {
    return Country(
      name: name ?? this.name,
      officialName: officialName ?? this.officialName,
      flagEmoji: flagEmoji ?? this.flagEmoji,
      region: region ?? this.region,
      subregion: subregion ?? this.subregion,
      capital: capital ?? this.capital,
      population: population ?? this.population,
      area: area ?? this.area,
      currencies: currencies ?? this.currencies,
      languages: languages ?? this.languages,
      timezones: timezones ?? this.timezones,
    );
  }
}
