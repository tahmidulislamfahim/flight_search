import 'dart:convert';

import 'package:flight_search/model/airport.dart';
import 'package:flight_search/widget/airport_picker.dart';
import 'package:flight_search/widget/location_field.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const _airportUrl =
      'https://enterpise.s3.ap-southeast-1.amazonaws.com/resources/airport.json';

  List<Airport> _airports = [];
  bool _loading = false;
  String _loadingError = '';

  Airport? _from;
  Airport? _to;
  DateTime? _departureDate;
  int _passengers = 1;

  @override
  void initState() {
    super.initState();
    _fetchAirports();
  }

  Future<void> _fetchAirports() async {
    setState(() {
      _loading = true;
      _loadingError = '';
    });
    try {
      final resp = await http.get(Uri.parse(_airportUrl));
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        List list = [];
        if (data is List) {
          list = data;
        } else if (data is Map) {
          // find the first List inside the map or values
          if (data.values.any((v) => v is List)) {
            list = data.values.firstWhere((v) => v is List) as List;
          } else {
            // Try to use entries
            list = data.entries.map((e) => e.value).whereType<Map>().toList();
          }
        }
        final airports = list
            .whereType<Map<String, dynamic>>()
            .map((m) => Airport.fromJson(m))
            .toList();
        setState(() {
          _airports = airports;
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
          _loadingError = 'HTTP ${resp.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _loadingError = e.toString();
      });
    }
  }

  Future<Airport?> _openAirportPicker() async {
    if (_loading) {
      return null;
    }
    if (_airports.isEmpty) {
      // try refetch
      await _fetchAirports();
      if (_airports.isEmpty) {
        return null;
      }
    }
    if (!mounted) {
      return null;
    }
    return showModalBottomSheet<Airport>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return AirportPicker(airports: _airports);
      },
    );
  }

  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _departureDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() {
        _departureDate = picked;
      });
    }
  }

  void _showPassengersSelector() async {
    final result = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        int temp = _passengers;
        return Padding(
          padding: MediaQuery.of(context).viewInsets + const EdgeInsets.all(16),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Passengers',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (temp > 1) {
                            setModalState(() {
                              temp--;
                            });
                          }
                        },
                        icon: const Icon(Icons.remove),
                      ),
                      Text('$temp', style: const TextStyle(fontSize: 20)),
                      IconButton(
                        onPressed: () {
                          setModalState(() {
                            temp++;
                          });
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(temp),
                    child: const Text('Done'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
    if (result != null) {
      setState(() {
        _passengers = result;
      });
    }
  }

  void _swap() {
    setState(() {
      final t = _from;
      _from = _to;
      _to = t;
    });
  }

  void _onSearch() {
    final from = _from?.displayString() ?? '—';
    final to = _to?.displayString() ?? '—';
    final date = _departureDate != null
        ? '${_departureDate!.year}-${_departureDate!.month.toString().padLeft(2, '0')}-${_departureDate!.day.toString().padLeft(2, '0')}'
        : '—';
    final passengers = _passengers;
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Search parameters'),
        content: Text(
          'From: $from\nTo: $to\nDate: $date\nPassengers: $passengers',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Text('Where', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: LocationField(
                  label: 'From',
                  value: _from?.displayString() ?? 'Select origin',
                  onTap: () async {
                    final sel = await _openAirportPicker();
                    if (sel != null) setState(() => _from = sel);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  IconButton(
                    onPressed: _swap,
                    icon: const Icon(Icons.swap_vert),
                    tooltip: 'Swap',
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LocationField(
                  label: 'To',
                  value: _to?.displayString() ?? 'Select destination',
                  onTap: () async {
                    final sel = await _openAirportPicker();
                    if (sel != null) setState(() => _to = sel);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text('Departure', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today),
            label: Text(
              _departureDate == null
                  ? 'Pick date'
                  : '${_departureDate!.year}-${_departureDate!.month.toString().padLeft(2, '0')}-${_departureDate!.day.toString().padLeft(2, '0')}',
            ),
          ),
          const SizedBox(height: 18),
          Text('Passengers', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _showPassengersSelector,
            icon: const Icon(Icons.person),
            label: Text('$_passengers'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _onSearch,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Search'),
            ),
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(),
              ),
            ),
          if (_loadingError.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                children: [
                  Text('Error loading airports: $_loadingError'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _fetchAirports,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
