import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:news_c20_online/modules/layout/data/data_source/local_data_source.dart';
import 'package:news_c20_online/modules/layout/data/data_source/remote_data_source.dart';

import '../models/news_response.dart';
import '../models/sources_response.dart';

abstract class Repo {
  Future<List<Articles>> getNews(String sourceId);

  Future<List<Sources>> getSources(String categoryId);

  Future<List<Articles>> searchNews(String query);
}

@Injectable(as: Repo)
class RepoImp implements Repo {
  RemoteDataSource remoteDataSource;
  LocalDataSource localDataSource;

  RepoImp(this.localDataSource, this.remoteDataSource);

  @override
  Future<List<Articles>> getNews(String sourceId) async {
    final bool isConnected = await InternetConnection().hasInternetAccess;
    try {
      if (isConnected) {
        var response = await remoteDataSource.getNews(sourceId);
        if (response.statusCode == 200) {
          await localDataSource.saveNews(response.data);
          var data = NewsResponse.fromJson(response.data);
          return data.articles ?? [];
        } else {
          throw response.data["message"];
        }
      } else {
        var response = await localDataSource.getNews();
        var data = NewsResponse.fromJson(response);
        return data.articles ?? [];
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Sources>> getSources(String categoryId) async {
    try {
      var response = await remoteDataSource.getSources(categoryId);
      if (response.statusCode == 200) {
        var data = SourcesResponse.fromJson(response.data);
        return data.sources ?? [];
      } else {
        throw response.data["message"];
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Articles>> searchNews(String query) async {
    final bool isConnected = await InternetConnection().hasInternetAccess;
    if (!isConnected) {
      throw "No internet connection. Please check your network and try again.";
    }
    try {
      var response = await remoteDataSource.searchNews(query);
      if (response.statusCode == 200) {
        var data = NewsResponse.fromJson(response.data);
        // NewsAPI بيرجع مقالات محذوفة اسمها [Removed] فبنشيلها
        return (data.articles ?? [])
            .where((a) => a.title != null && a.title != "[Removed]")
            .toList();
      } else {
        throw response.data["message"];
      }
    } catch (e) {
      rethrow;
    }
  }
}
