import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/bloc/settings/settings_cubit.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/widgets/picker/option_picker_list.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/widgets/picker/option_picker_scaffold.dart';

/// Picks the category the Home feed opens with.
class DefaultCategoryScreen extends StatelessWidget {
  const DefaultCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OptionPickerScaffold(
      title: 'Default category',
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return OptionPickerList<NewsCategory>(
            options: [
              for (final category in NewsCategory.values)
                PickerOption(value: category, label: category.label),
            ],
            selected: state.settings.defaultCategory,
            onSelected: (category) {
              context.read<SettingsCubit>().setDefaultCategory(category);
              Navigator.of(context).pop();
            },
          );
        },
      ),
    );
  }
}
