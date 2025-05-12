import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/models/flowmodoro_model.dart';
import 'package:spiceease/data/services/flowmodoro_service.dart';

class FlowmodoroStateNotifier extends StateNotifier<List<FlowmodoroModel>> {
  final FlowmodoroService _flowmodoroService;
  final DateTime _date;
  bool _isLoading = false;
  String? _error;

  FlowmodoroStateNotifier(this._flowmodoroService, this._date) : super([]) {
    fetchFlowmodoros();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchFlowmodoros() async {
    if (!mounted) return;
    _setLoading(true);
    try {
      final flowmodoros = await _flowmodoroService.getFlowmodorosForDate(_date);
      print('Fetched ${flowmodoros.length} flowmodoros for date: $_date');
      if (!mounted) return;
      state = flowmodoros;
      _setLoading(false);
    } catch (e) {
      if (!mounted) return;
      _setLoading(false);
      _setError(e.toString());
    }
  }

  void _setLoading(bool loading) => _isLoading = loading;
  void _setError(String error) => _error = error;
}
