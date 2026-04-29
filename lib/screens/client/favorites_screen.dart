import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_fiverr/providers/data_provider.dart';
import 'package:mini_fiverr/screens/client/professional_profile_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final favorites = data.favoriteProfessionals;

    if (favorites.isEmpty) {
      return const Center(
        child: Text('No favorites yet. Explore talent and tap the heart!'),
      );
    }

    return ListView.builder(
      itemCount: favorites.length,
      itemBuilder: (_, int i) {
        final p = favorites[i];
        return ListTile(
          leading: CircleAvatar(child: Text(p.name.substring(0, 1))),
          title: Text(p.name),
          subtitle: Text(p.title),
          trailing: IconButton(
            icon: const Icon(Icons.favorite, color: Colors.red),
            onPressed: () => data.toggleFavorite(p.id),
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => ProfessionalProfileScreen(professional: p)),
          ),
        );
      },
    );
  }
}
