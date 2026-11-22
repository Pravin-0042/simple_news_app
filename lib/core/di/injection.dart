import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../features/news/data/repositories/news_repository_impl.dart';
import '../../features/news/domain/repositories/news_repository.dart';
import '../network/api_client.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  if (getIt.isRegistered<Dio>()) {
    return;
  }
  getIt.registerLazySingleton<Dio>(ApiClient.createDio);
  getIt.registerLazySingleton<ApiClient>(() => ApiClient(getIt<Dio>()));
  getIt.registerLazySingleton<NewsRepositoryImpl>(
    () => NewsRepositoryImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<NewsRepository>(
    () => getIt<NewsRepositoryImpl>(),
  );
}
