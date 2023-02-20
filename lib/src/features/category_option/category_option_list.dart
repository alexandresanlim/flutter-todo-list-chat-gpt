import 'package:flutter/material.dart';
import 'package:todo_list_chat_gpt/src/features/category_option/category_option.dart';
import '../../settings/settings_view.dart';
import '../category_items/category_item_history.dart';

class CategorieListView extends StatelessWidget {
  const CategorieListView({
    super.key,
    this.items = const [
      CategoryOption(
          1,
          'Receitas',
          'Minhas receitas',
          'Crie uma lista de afazeres para suas receitas favoritas',
          'Escreva uma receita para',
          'Bolo de cenoura'),
      CategoryOption(
          2,
          'Planos de estudo',
          'Meus planos de estudo',
          'Crie uma lista de afazeres para estudar um determinado tema',
          'Quais os pontos eu deveria saber para estudar',
          'Império romano'),
      CategoryOption(
          3,
          'Tarefas',
          'Minhas tarefas',
          'Crie uma lista de afazeres para tarefas do seu cotidiano',
          'Crie uma lista de tarefas para',
          'Limpar a casa')
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
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  item.description,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                leading: const CircleAvatar(
                  foregroundImage: AssetImage('assets/images/flutter_logo.png'),
                ),
                onTap: () {
                  final String categoryId = item.id.toString();
                  Navigator.restorablePushNamed(
                    context,
                    CategoryItemListPage.routeName,
                    arguments: {
                      'categoryId': categoryId,
                      'titlePage': item.titlePage,
                      'startPrompt': item.startPrompt,
                      'placeHolder': item.placeHolder
                    },
                  );
                }),
          );
        },
      ),
    );
  }
}
