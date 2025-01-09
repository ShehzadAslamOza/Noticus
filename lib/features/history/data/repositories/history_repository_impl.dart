import 'package:noticus/features/history/domain/repositories/histroy_repository.dart';

import '../../domain/entities/history_entity.dart';
import '../sources/history_remote_data_source.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryRemoteDataSource remoteDataSource;

  HistoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<HistoryEntity>> fetchHistory(String userId) {
    return remoteDataSource.fetchHistory(userId);
  }
}
