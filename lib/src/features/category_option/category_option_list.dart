import 'package:flutter/material.dart';
import 'package:todo_list_chat_gpt/src/features/category_option/category_option.dart';
import '../../settings/settings_view.dart';
import '../category_items/category_item_history.dart';

class CategorieListView extends StatelessWidget {
  const CategorieListView({
    super.key,
    this.items = const [
      CategoryOption(1, 'Receita', 'Crie uma lista de a fazer para receitas',
          CategoryOptionType.recipe),
      CategoryOption(
          2,
          'Plano de estudo',
          'Crie uma lista de a fazer estudar um determinado tema',
          CategoryOptionType.studyPlan)
    ],
  });

  static const routeName = '/';

  final List<CategoryOption> items;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escolha uma opção'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),
      body: ListView.builder(
        restorationId: 'categorieListView',
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = items[index];

          return Card(
            child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                title: Text(
                  '${item.id}. ${item.title}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(item.description),
                trailing: const Icon(Icons.chevron_right),
                leading: const CircleAvatar(
                  foregroundImage: AssetImage('assets/images/flutter_logo.png'),
                ),
                onTap: () {
                  final String categoryId = item.id.toString();
                  Navigator.restorablePushNamed(
                    context,
                    CategoryItemListPage.routeName,
                    arguments: {'categoryId': categoryId},
                  );
                }),
          );
        },
      ),
    );
  }
}
