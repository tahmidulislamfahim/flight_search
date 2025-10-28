import 'package:flight_search/providers/search_state_provider.dart';
import 'package:flutter/material.dart';

void searchResult(SearchState searchState, BuildContext context) {
  final from = searchState.from?.displayString() ?? '—';
  final to = searchState.to?.displayString() ?? '—';
  final date = searchState.departureDate != null
      ? '${searchState.departureDate!.year}-${searchState.departureDate!.month.toString().padLeft(2, '0')}-${searchState.departureDate!.day.toString().padLeft(2, '0')}'
      : '—';
  final passengers = searchState.passengers;
  showDialog(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('Search parameters'),
      content: Text(
        'From: $from\\nTo: $to\\nDate: $date\\nPassengers: $passengers',
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
