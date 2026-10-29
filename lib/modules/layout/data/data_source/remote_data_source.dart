import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/services/api_service.dart';

abstract class RemoteDataSource {
  Future<Response> getNews(String sourceId);

  Future<Response> getSources(String categoryId);

  Future<Response> searchNews(String query);
}

@Injectable(as: RemoteDataSource)
class RemoteDataSourceImp extends RemoteDataSource {
  ApiService apiService;
  RemoteDataSourceImp(this.apiService);

  @override
  Future<Response<dynamic>> getNews(String sourceId) {
    return apiService.dio.get("everything?sources=$sourceId");
  }

  @override
  Future<Response<dynamic>> getSources(String categoryId) {
    return apiService.dio.get(
      "top-headlines/sources",
      queryParameters: {"category": categoryId},
    );
  }

  /// بيستخدم الـ q parameter بتاع NewsAPI عشان يبعت كلمة البحث
  @override
  Future<Response<dynamic>> searchNews(String query) {
    return apiService.dio.get(
      "everything",
      queryParameters: {
        "q": query,
        "sortBy": "publishedAt",
        "language": "en",
      },
    );
  }
}
