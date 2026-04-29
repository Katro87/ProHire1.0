import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_fiverr/providers/data_provider.dart';
import 'package:mini_fiverr/screens/shared/edit_profile_screen.dart';

class ProfessionalProfileViewScreen extends StatelessWidget {
  const ProfessionalProfileViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<DataProvider>().currentUser;
    if (user == null) {
      return const SizedBox.shrink();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        CircleAvatar(radius: 44, child: Text(user.fullName.substring(0, 1).toUpperCase())),
        const SizedBox(height: 12),
        Text(user.fullName, style: Theme.of(context).textTheme.headlineMedium),
        Text(user.title.isEmpty ? 'Professional' : user.title),
        const SizedBox(height: 12),
        Text('Earnings: \$${user.earnings.toStringAsFixed(0)}'),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const EditProfileScreen())),
          child: const Text('Edit Profile'),
        ),
      ],
    );
  }
}
