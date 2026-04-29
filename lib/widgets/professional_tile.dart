import 'package:flutter/material.dart';
import 'package:mini_fiverr/models/professional_model.dart';
import 'package:mini_fiverr/utils/theme.dart';
import 'package:mini_fiverr/widgets/toast_notification.dart';

class ProfessionalTile extends StatelessWidget {
  const ProfessionalTile({
    super.key,
    required this.professional,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
    required this.onHire,
  });

  final ProfessionalModel professional;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback onHire;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: glassCardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary,
                  child: Text(_initials(professional.name), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(professional.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      Text(professional.title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    onToggleFavorite();
                    ToastService.showInfo(isFavorite ? 'Removed from saved talent' : 'Saved to favorites');
                  },
                  icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? AppColors.error : AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '${professional.rating} (${professional.reviewCount} reviews)  |  \$${professional.hourlyRate.toStringAsFixed(0)}/hr',
              style: const TextStyle(color: AppColors.secondary),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: professional.skills.take(3).map((String s) {
                return Chip(
                  label: Text(s),
                  backgroundColor: AppColors.elevated,
                  side: const BorderSide(color: AppColors.border),
                  labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(onPressed: onTap, child: const Text('View Profile')),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(onPressed: onHire, child: const Text('Hire Me')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final List<String> parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'.toUpperCase();
  }
}
