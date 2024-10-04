import 'package:bloc/bloc.dart';
import 'package:flutter_application_1/helpers/date_helpers.dart';
import 'package:flutter_application_1/src/repositories/farm_repo.dart';

class FarmState {
  final bool isLoading;
  final bool isUpdating;
  final String lastFed;
  final String lastWatered;
  final String? message; 
  final String? error; 

  const FarmState({
    this.isLoading = false,
    this.isUpdating = false,
    this.lastFed = '',
    this.lastWatered = '',
    this.message,
    this.error,
  });

  FarmState copyWith({
    bool? isLoading,
    bool? isUpdating,
    String? lastFed,
    String? lastWatered,
    String? message,
    String? error,
  }) {
    return FarmState(
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      lastFed: lastFed ?? this.lastFed,
      lastWatered: lastWatered ?? this.lastWatered,
      message: message ?? this.message,
      error: error ?? this.error,
    );
  }
}

// Cubit
class FarmCubit extends Cubit<FarmState> {
  final ApiRepository apiRepository;

  FarmCubit(this.apiRepository)
      : super(FarmState(isLoading: true)); 

  Future<void> loadFarmData() async {
    try {
      emit(state.copyWith(
          isLoading: true, error: null));
      final data = await apiRepository.getData();
      emit(state.copyWith(
        isLoading: false,
        lastWatered: formatDate(data['last_watered']),
        lastFed: formatDate(data['last_fed']),
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> feedOrWater(String actionType) async {
    try {
      emit(state.copyWith(
          isUpdating: true,
          message: null,
          error: null)); 

      final response = await apiRepository
          .feedOrWater(actionType); 

      final updatedData = await apiRepository.getData();

      emit(state.copyWith(
        isUpdating: false,
        lastWatered: formatDate(updatedData['last_watered']),
        lastFed: formatDate(updatedData['last_fed']),
        message: response['message'] ?? 'Action successful',
        error: null, 
      ));
    } catch (e) {
      print('Error in feedOrWater: $e');
      emit(state.copyWith(isUpdating: false, error: e.toString()));
    }
  }
}
