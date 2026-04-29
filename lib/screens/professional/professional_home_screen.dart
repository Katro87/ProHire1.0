import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_fiverr/models/job_model.dart';
import 'package:mini_fiverr/providers/data_provider.dart';
import 'package:mini_fiverr/widgets/hire_request_tile.dart';

class ProfessionalHomeScreen extends StatelessWidget {
  const ProfessionalHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final requests = context.watch<DataProvider>().professionalRequests;
    final active = requests.where((HireRequestModel r) => r.status == HireRequestStatus.accepted || r.status == HireRequestStatus.active).toList();
    final pending = requests.where((HireRequestModel r) => r.status == HireRequestStatus.pending).toList();
    final completed = requests.where((HireRequestModel r) => r.status == HireRequestStatus.completed).toList();

    return DefaultTabController(
      length: 3,
      child: Column(
        children: <Widget>[
          const TabBar(tabs: <Widget>[Tab(text: 'Active Jobs'), Tab(text: 'Pending'), Tab(text: 'Completed')]),
          Expanded(
            child: TabBarView(
              children: <Widget>[
                _list(active),
                _list(pending),
                _list(completed),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _list(List<HireRequestModel> list) {
    if (list.isEmpty) {
      return const Center(child: Text('No jobs in this section yet.'));
    }
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (_, int i) => HireRequestTile(request: list[i]),
    );
  }
}
