import 'package:logi_neko/core/exception/exceptions.dart';
import 'package:logi_neko/features/home/api/api.dart';
import 'package:logi_neko/features/home/dto/user.dart';

abstract class HomeRepository {
  Future<User> getUserInfo();
}

class HomeRepositoryImpl implements HomeRepository {
  @override
  Future<User> getUserInfo() async {
    final response = await HomeApi.getUserInfo();

    if (response.isSuccess && response.hasData) {
      return response.data!;
    }

    throw BackendException(
      message: response.message ?? 'Failed to fetch videos',
      statusCode: response.status,
      errorCode: response.code ?? 'FETCH_VIDEOS_ERROR',
    );
  }
}