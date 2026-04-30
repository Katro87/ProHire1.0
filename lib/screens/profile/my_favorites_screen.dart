import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_fiverr/models/user_model.dart';
import 'package:mini_fiverr/providers/user_provider.dart';
import 'package:mini_fiverr/screens/professionals/professional_detail_screen.dart';
import 'package:mini_fiverr/services/firestore_service.dart';
import 'package:mini_fiverr/widgets/professional_card.dart';
import 'package:mini_fiverr/utils/theme.dart';

class MyFavoritesScreen extends StatelessWidget {
  const MyFavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<UserProvider>().userModel;
    final favoriteIds = currentUser?.favoriteProfessionalIds ?? const [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Favorites')),
      body: favoriteIds.isEmpty
                ? Center(
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
                              'Browse talent and tap the heart to save professionals here.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textSecondary, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
          : StreamBuilder<List<UserModel>>(
              stream: FirestoreService().getProfessionals(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final favorites = snapshot.data!.where((pro) => favoriteIds.contains(pro.uid)).toList();
                if (favorites.isEmpty) {
                  return const Center(child: Text('No favorites yet.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final professional = favorites[index];
                    return ProfessionalCard(
                      professional: professional,
                      isFavorite: true,
                      onFavoriteTap: () async {
                        final updated = [...favoriteIds]..remove(professional.uid);
                        await context.read<UserProvider>().updateUser(currentUser!.uid, {'favoriteProfessionalIds': updated});
                      },
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfessionalDetailScreen(professional: professional))),
                    );
                  },
                );
              },
            ),
    );
  }
}