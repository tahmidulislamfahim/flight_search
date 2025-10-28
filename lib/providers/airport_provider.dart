import 'dart:convert';

import 'package:flight_search/model/airport.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

const _airportUrl =
    'https://enterpise.s3.ap-southeast-1.amazonaws.com/resources/airport.json';

final airportsProvider = FutureProvider<List<Airport>>((ref) async {
  final resp = await http.get(Uri.parse(_airportUrl));
  if (resp.statusCode != 200) throw Exception('HTTP ${resp.statusCode}');
  final data = json.decode(resp.body);
  List list = [];
  if (data is List) {
    list = data;
  } else if (data is Map) {
    if (data.values.any((v) => v is List)) {
      list = data.values.firstWhere((v) => v is List) as List;
    } else {
      list = data.entries.map((e) => e.value).whereType<Map>().toList();
    }
  }
  final airports = list
      .whereType<Map<String, dynamic>>()
      .map((m) => Airport.fromJson(m))
      .toList();
  return airports;
});
