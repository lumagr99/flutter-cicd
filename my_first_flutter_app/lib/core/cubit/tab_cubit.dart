import 'package:flutter_bloc/flutter_bloc.dart';

/// Controls the current and previous selected tab index
class TabCubit extends Cubit<int> {
  int _previousIndex = 1; // Stores previously active tab index

  // Initializes with tab index 1
  TabCubit() : super(1);

  /// Sets a new tab index and stores the previous one
  void setIndex(int index) {
    _previousIndex = state;
    emit(index);
  }

  /// Returns the current tab index
  int get currentIndex => state;

  /// Switches back to the previous tab index
  void goBack() {
    if (state != _previousIndex) {
      final temp = state;
      emit(_previousIndex);
      _previousIndex = temp; // optional: allows toggle-back functionality
    }
  }

  /// Returns the previous tab index
  int get previousIndex => _previousIndex;
}
