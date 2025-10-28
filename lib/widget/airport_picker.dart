import 'package:flight_search/model/airport.dart';
import 'package:flutter/material.dart';

class AirportPicker extends StatefulWidget {
  final List<Airport> airports;
  const AirportPicker({super.key, required this.airports});

  @override
  State<AirportPicker> createState() => _AirportPickerState();
}

class _AirportPickerState extends State<AirportPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = _query.isEmpty
        ? widget.airports
        : widget.airports
              .where(
                (a) =>
                    a.name.toLowerCase().contains(_query.toLowerCase()) ||
                    a.iata.toLowerCase().contains(_query.toLowerCase()),
              )
              .toList();
    // Make the picker take most of the screen and be keyboard-aware so
    // the search field and list are not obscured by the on-screen keyboard.
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final height = MediaQuery.of(context).size.height * 0.85;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(12.0, 24.0, 12.0, 12.0 + bottomInset),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  autofocus: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search by name or IATA',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('No results'))
                    : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final a = filtered[index];
                          return ListTile(
                            title: Text(a.name),
                            subtitle: a.iata.isNotEmpty ? Text(a.iata) : null,
                            trailing: a.iata.isNotEmpty
                                ? Text(
                                    a.iata,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                            onTap: () => Navigator.of(context).pop(a),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
