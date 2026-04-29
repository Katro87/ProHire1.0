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
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No favorites yet. Browse talent and tap the heart to save them here!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
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