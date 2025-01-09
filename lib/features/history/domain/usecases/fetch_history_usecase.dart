import 'package:noticus/features/history/domain/repositories/histroy_repository.dart';

import '../entities/history_entity.dart';

class FetchHistoryUseCase {
  final HistoryRepository repository;

  FetchHistoryUseCase(this.repository);

  Future<List<HistoryEntity>> call(String userId) {
    return repository.fetchHistory(userId);
  }
}
