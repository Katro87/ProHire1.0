import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_fiverr/models/professional_model.dart';
import 'package:mini_fiverr/providers/data_provider.dart';
import 'package:mini_fiverr/utils/avatar_utils.dart';
import 'package:mini_fiverr/utils/theme.dart';
import 'package:mini_fiverr/screens/client/send_hire_request_screen.dart';
import 'package:mini_fiverr/screens/shared/chat_screen.dart';
import 'package:mini_fiverr/widgets/toast_notification.dart';

class ProfessionalProfileScreen extends StatelessWidget {
  const ProfessionalProfileScreen({super.key, required this.professional});

  final ProfessionalModel professional;

  @override
  Widget build(BuildContext context) {
    final DataProvider data = context.watch<DataProvider>();
    final bool favorite = data.currentUser?.favoriteProfessionalIds.contains(professional.id) ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Professional Profile'),
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              await data.toggleFavorite(professional.id);
              ToastService.showInfo(favorite ? 'Removed from favorites' : 'Added to favorites');
            },
            icon: Icon(favorite ? Icons.favorite : Icons.favorite_border),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: glassCardDecoration(accent: AppColors.primary),
            child: Column(
              children: <Widget>[
                AvatarUtils.buildAvatar(name: professional.name, imageUrl: professional.photoUrl, radius: 54),
                const SizedBox(height: 14),
                Text(professional.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 4),
                Text(professional.title, style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                    Text(' ${professional.rating}  •  ', style: const TextStyle(color: Colors.white)),
                    Text('\$${professional.hourlyRate.toStringAsFixed(0)}/hr', style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _section('About', professional.bio),
          const SizedBox(height: 14),
          _section(
            'Skills',
            '',
            children: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: professional.skills.map((String s) => Chip(label: Text(s))).toList(),
            ),
          ),
          const SizedBox(height: 14),
          _section('Experience', '${professional.experience}  •  ${professional.previousCompany}'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => SendHireRequestScreen(professional: professional)),
            ),
            child: const Text('Hire Me'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {
              final convo = data.openConversationWith(
                otherUserId: professional.id,
                otherUserName: professional.name,
                otherAvatar: professional.photoUrl,
              );
              Navigator.push(context, MaterialPageRoute<void>(builder: (_) => ChatScreen(conversationId: convo.id)));
            },
            child: const Text('Message'),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, String body, {Widget? children}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.elevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (children != null) children else Text(body, style: const TextStyle(color: AppColors.textSecondary, height: 1.5)),
        ],
      ),
    );
  }
}
