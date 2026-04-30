import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_fiverr/providers/data_provider.dart';
import 'package:mini_fiverr/screens/client/professional_profile_screen.dart';
import 'package:mini_fiverr/utils/theme.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final favorites = data.favoriteProfessionals;

    if (favorites.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 360),
            padding: const EdgeInsets.all(24),
            decoration: glassCardDecoration(accent: AppColors.primary),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.favorite_border_rounded, size: 54, color: AppColors.secondary),
                SizedBox(height: 14),
                Text('No favorites yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                SizedBox(height: 8),
                Text(
                  'Browse professionals and tap the heart on the ones you want to save for later.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, height: 1.4),
                ),
              ],
            ),
          ),
        ),
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
