import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/di.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../layout/view/widegts/article_item.dart';
import '../cubit/search_cubit.dart';
import '../cubit/search_states.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SearchCubit>(),
      child: Builder(
        builder: (context) {
          final cubit = BlocProvider.of<SearchCubit>(context);
          return Scaffold(
            backgroundColor: AppColors.black,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: controller,
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      style: TextStyle(color: AppColors.white),
                      cursorColor: AppColors.white,
                      onSubmitted: cubit.search,
                      decoration: InputDecoration(
                        hintText: "Search",
                        hintStyle: TextStyle(color: AppColors.white),
                        prefixIcon: Icon(Icons.search, color: AppColors.white),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.close, color: AppColors.white),
                          onPressed: () {
                            // لو فيه كلام امسحه، لو فاضي ارجع
                            if (controller.text.isEmpty) {
                              Navigator.pop(context);
                            } else {
                              controller.clear();
                              cubit.clear();
                            }
                          },
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: AppColors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: AppColors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: BlocBuilder<SearchCubit, SearchState>(
                        builder: (context, state) {
                          switch (state) {
                            case SearchLoadingState():
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            case SearchSuccessState():
                              return ListView.separated(
                                itemCount: cubit.articles.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 16),
                                itemBuilder: (context, index) =>
                                    ArticleItem(article: cubit.articles[index]),
                              );
                            case SearchEmptyState():
                              return _Message(
                                icon: Icons.search_off,
                                text:
                                    "No articles found for \"${cubit.lastQuery}\"",
                              );
                            case SearchErrorState():
                              return _Message(
                                icon: Icons.wifi_off,
                                text: state.error,
                                onRetry: () => cubit.search(controller.text),
                              );
                            case SearchInitState():
                              return const _Message(
                                icon: Icons.newspaper,
                                text: "Search for any news topic",
                              );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onRetry;
  const _Message({required this.icon, required this.text, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.grey, size: 64),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text("Try again")),
          ],
        ],
      ),
    );
  }
}
