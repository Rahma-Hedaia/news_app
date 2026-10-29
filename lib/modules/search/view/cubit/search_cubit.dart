import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../layout/data/models/news_response.dart';
import '../../../layout/data/repo/repo.dart';
import 'search_states.dart';

@injectable
class SearchCubit extends Cubit<SearchState> {
  SearchCubit(this.repo) : super(SearchInitState());

  Repo repo;
  List<Articles> articles = [];
  String lastQuery = "";

  Future<void> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      clear();
      return;
    }
    lastQuery = q;
    emit(SearchLoadingState());
    try {
      final result = await repo.searchNews(q);
      // لو اليوزر كتب كلمة جديدة قبل ما الرد يرجع، نتجاهل الرد القديم
      if (q != lastQuery) return;
      articles = result;
      if (articles.isEmpty) {
        emit(SearchEmptyState());
      } else {
        emit(SearchSuccessState());
      }
    } catch (e) {
      if (q != lastQuery) return;
      emit(SearchErrorState(e.toString()));
    }
  }

  void clear() {
    lastQuery = "";
    articles = [];
    emit(SearchInitState());
  }
}
