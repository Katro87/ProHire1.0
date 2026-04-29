import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_fiverr/models/professional_model.dart';
import 'package:mini_fiverr/providers/data_provider.dart';
import 'package:mini_fiverr/screens/client/send_hire_request_screen.dart';
import 'package:mini_fiverr/screens/shared/chat_screen.dart';

class ProfessionalProfileScreen extends StatelessWidget {
  const ProfessionalProfileScreen({super.key, required this.professional});

  final ProfessionalModel professional;

  @override
  Widget build(BuildContext context) {
    final DataProvider data = context.watch<DataProvider>();
    final bool favorite = data.currentUser?.favoriteProfessionalIds.contains(professional.id) ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Professional Profile'),
        actions: <Widget>[
          IconButton(
            onPressed: () => data.toggleFavorite(professional.id),
            icon: Icon(favorite ? Icons.favorite : Icons.favorite_border),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          CircleAvatar(radius: 42, child: Text(_initials(professional.name))),
          const SizedBox(height: 12),
          Text(professional.name, style: Theme.of(context).textTheme.headlineMedium),
          Text('${professional.title}  |  \$${professional.hourlyRate.toStringAsFixed(0)}/hr'),
          const SizedBox(height: 8),
          Text('Rating ${professional.rating} (${professional.reviewCount} reviews)'),
          const SizedBox(height: 12),
          Text(professional.bio),
          const SizedBox(height: 12),
          Wrap(spacing: 8, children: professional.skills.map((String s) => Chip(label: Text(s))).toList()),
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

  String _initials(String name) {
    final List<String> p = name.split(' ');
    return '${p.first[0]}${p.last[0]}'.toUpperCase();
  }
}
