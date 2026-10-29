import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_c20_online/modules/layout/view/cubit/cubit.dart';
import 'package:news_c20_online/modules/layout/view/cubit/states.dart';

import '../../../../core/theme/app_colors.dart';
import '../widegts/article_item.dart';

class ArticlesScreen extends StatelessWidget {
  const ArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<LayoutCubit, LayoutState>(
          buildWhen: (previous, current) {
            return current is GetSourceErrorState ||
                current is GetSourceLoadingState ||
                current is GetSourceSuccessState;
          },
          builder: (context, state) {
            var cubit = BlocProvider.of<LayoutCubit>(context);
            if (state is GetSourceSuccessState) {
              return DefaultTabController(
                length: cubit.sources.length,
                child: TabBar(
                  onTap: (value) {
                    cubit.onChangeSource(cubit.sources[value]);
                  },
                  dividerColor: Colors.transparent,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorColor: AppColors.white,
                  labelColor: AppColors.white,
                  unselectedLabelColor: AppColors.white,
                  tabs: cubit.sources.map((e) {
                    return Tab(text: e.name ?? "");
                  }).toList(),
                ),
              );
            } else if (state is GetSourceLoadingState) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is GetSourceErrorState) {
              return Center(
                child: Text(state.error,
                    style: const TextStyle(color: Colors.white)),
              );
            } else {
              return const SizedBox();
            }
          },
        ),

        BlocBuilder<LayoutCubit, LayoutState>(
          buildWhen: (previous, current) {
            return current is GetNewsSuccessState ||
                current is GetNewsLoadingState ||
                current is GetNewsErrorState;
          },
          builder: (context, state) {
            var cubit = BlocProvider.of<LayoutCubit>(context);
            if (state is GetNewsSuccessState) {
              return Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    return ArticleItem(article: cubit.articles[index]);
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemCount: cubit.articles.length,
                ),
              );
            } else if (state is GetNewsLoadingState) {
              return const Expanded(
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (state is GetNewsErrorState) {
              return Expanded(
                child: Center(
                  child: Text(state.error,
                      style: const TextStyle(color: Colors.white)),
                ),
              );
            } else {
              return const SizedBox();
            }
          },
        ),
      ],
    );
  }
}
