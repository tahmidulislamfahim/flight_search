import 'package:flight_search/model/airport.dart';
import 'package:flight_search/widget/airport_picker.dart';
import 'package:flight_search/widget/location_field.dart';
import 'package:flight_search/widget/search_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flight_search/providers/airport_provider.dart';
import 'package:flight_search/providers/search_state_provider.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  Future<Airport?> _openAirportPicker(
    BuildContext context,
    List<Airport> airports,
  ) async {
    return showModalBottomSheet<Airport>(
      context: context,
      isScrollControlled: true,
      builder: (context) => AirportPicker(airports: airports),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final airportsAsync = ref.watch(airportsProvider);
    final searchState = ref.watch(searchStateProvider);
    final searchNotifier = ref.read(searchStateProvider.notifier);

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
                  value: searchState.from?.displayString() ?? 'Select origin',
                  onTap: () async {
                    final list = await airportsAsync.when(
                      data: (d) => Future.value(d),
                      loading: () => Future.value(<Airport>[]),
                      error: (_, __) => Future.value(<Airport>[]),
                    );
                    if (list.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Airports not loaded yet'),
                        ),
                      );
                      return;
                    }
                    final sel = await _openAirportPicker(context, list);
                    if (sel != null) searchNotifier.setFrom(sel);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  IconButton(
                    onPressed: () => searchNotifier.swap(),
                    icon: const Icon(Icons.swap_vert),
                    tooltip: 'Swap',
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LocationField(
                  label: 'To',
                  value:
                      searchState.to?.displayString() ?? 'Select destination',
                  onTap: () async {
                    final list = await airportsAsync.when(
                      data: (d) => Future.value(d),
                      loading: () => Future.value(<Airport>[]),
                      error: (_, __) => Future.value(<Airport>[]),
                    );
                    if (list.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Airports not loaded yet'),
                        ),
                      );
                      return;
                    }
                    final sel = await _openAirportPicker(context, list);
                    if (sel != null) searchNotifier.setTo(sel);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text('Departure', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: searchState.departureDate ?? now,
                firstDate: now,
                lastDate: DateTime(now.year + 2),
              );
              if (picked != null) searchNotifier.setDate(picked);
            },
            icon: const Icon(Icons.calendar_today),
            label: Text(
              searchState.departureDate == null
                  ? 'Pick date'
                  : '${searchState.departureDate!.year}-${searchState.departureDate!.month.toString().padLeft(2, '0')}-${searchState.departureDate!.day.toString().padLeft(2, '0')}',
            ),
          ),
          const SizedBox(height: 18),
          Text('Passengers', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await showModalBottomSheet<int>(
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  int temp = searchState.passengers;
                  return Padding(
                    padding:
                        MediaQuery.of(context).viewInsets +
                        const EdgeInsets.all(16),
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
                                    if (temp > 1) setModalState(() => temp--);
                                  },
                                  icon: const Icon(Icons.remove),
                                ),
                                Text(
                                  '$temp',
                                  style: const TextStyle(fontSize: 20),
                                ),
                                IconButton(
                                  onPressed: () => setModalState(() => temp++),
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
              if (result != null) searchNotifier.setPassengers(result);
            },
            icon: const Icon(Icons.person),
            label: Text('${searchState.passengers}'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              searchResult(searchState, context);
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Search'),
            ),
          ),
          const SizedBox(height: 16),
          airportsAsync.when(
            data: (_) => const SizedBox.shrink(),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (err, stk) => Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                children: [
                  Text('Error loading airports: $err'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => ref.refresh(airportsProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
