class Airport {
  final String name;
  final String iata;
  final String city;
  final String country;

  Airport({
    required this.name,
    required this.iata,
    this.city = '',
    this.country = '',
  });

  factory Airport.fromJson(Map<String, dynamic> j) {
    String name =
        (j['name'] ??
                j['airport_name'] ??
                j['airport'] ??
                j['airport_name_en'] ??
                '')
            .toString();
    String iata = (j['iata'] ?? j['iata_code'] ?? j['code'] ?? '').toString();
    String city = (j['city'] ?? j['city_name'] ?? '').toString();
    String country = (j['country'] ?? j['country_name'] ?? '').toString();
    // Fallback: if name empty but there's a combined field
    if (name.isEmpty) {
      if (j.containsKey('name_en')) {
        name = j['name_en'].toString();
      } else if (j.containsKey('airportName')) {
        name = j['airportName'].toString();
      }
    }
    return Airport(name: name, iata: iata, city: city, country: country);
  }

  String displayString() {
    if (iata.isNotEmpty) return '$name ($iata)';
    return name;
  }
}
