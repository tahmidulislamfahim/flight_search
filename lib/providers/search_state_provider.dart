import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flight_search/model/airport.dart';

class SearchState {
  final Airport? from;
  final Airport? to;
  final DateTime? departureDate;
  final int passengers;

  const SearchState({
    this.from,
    this.to,
    this.departureDate,
    this.passengers = 1,
  });

  SearchState copyWith({
    Airport? from,
    Airport? to,
    DateTime? departureDate,
    int? passengers,
  }) {
    return SearchState(
      from: from ?? this.from,
      to: to ?? this.to,
      departureDate: departureDate ?? this.departureDate,
      passengers: passengers ?? this.passengers,
    );
  }
}

class SearchStateNotifier extends StateNotifier<SearchState> {
  SearchStateNotifier() : super(const SearchState());

  void setFrom(Airport? a) => state = state.copyWith(from: a);
  void setTo(Airport? a) => state = state.copyWith(to: a);
  void swap() => state = state.copyWith(from: state.to, to: state.from);
  void setDate(DateTime? d) => state = state.copyWith(departureDate: d);
  void setPassengers(int p) => state = state.copyWith(passengers: p);
}

final searchStateProvider =
    StateNotifierProvider<SearchStateNotifier, SearchState>((ref) {
      return SearchStateNotifier();
    });
