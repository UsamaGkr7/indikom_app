import 'package:get_it/get_it.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/hive_service.dart';
import '../../core/network/network_info.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfo());

  // Storage
  sl.registerLazySingleton<HiveService>(() => HiveService());
  await sl<HiveService>().init();

  // Network
  sl.registerLazySingleton<DioClient>(() => DioClient());
  // Init Dio with flavor baseUrl later

  // Features - register repositories, blocs etc.
}
