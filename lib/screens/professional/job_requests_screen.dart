import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_fiverr/models/job_model.dart';
import 'package:mini_fiverr/providers/data_provider.dart';
import 'package:mini_fiverr/widgets/hire_request_tile.dart';

class JobRequestsScreen extends StatelessWidget {
  const JobRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final requests = data.professionalRequests.where((HireRequestModel r) => r.status == HireRequestStatus.pending).toList();

    if (requests.isEmpty) {
      return const Center(child: Text('No incoming requests yet.'));
    }

    return ListView.builder(
      itemCount: requests.length,
      itemBuilder: (_, int i) {
        final req = requests[i];
        return HireRequestTile(
          request: req,
          onDecline: () => _confirm(context, false, req.id),
          onAccept: () => _confirm(context, true, req.id),
        );
      },
    );
  }

  Future<void> _confirm(BuildContext context, bool accept, String id) async {
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(accept ? 'Accept this project?' : 'Decline this project?'),
        content: Text(accept ? 'This will move the request into your active jobs.' : 'This request will be marked as declined.'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<DataProvider>().updateRequestStatus(id, accept ? HireRequestStatus.accepted : HireRequestStatus.declined);
              Navigator.pop(context);
            },
            child: Text(accept ? 'Accept' : 'Decline'),
          ),
        ],
      ),
    );
  }
}
