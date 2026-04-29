import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_fiverr/models/job_model.dart';
import 'package:mini_fiverr/providers/data_provider.dart';
import 'package:mini_fiverr/widgets/hire_request_tile.dart';

class ClientHomeScreen extends StatelessWidget {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<HireRequestModel> requests = context.watch<DataProvider>().clientRequests;

    final List<HireRequestModel> active = requests.where((HireRequestModel r) => r.status == HireRequestStatus.accepted || r.status == HireRequestStatus.active).toList();
    final List<HireRequestModel> sent = requests.where((HireRequestModel r) => r.status == HireRequestStatus.pending || r.status == HireRequestStatus.declined).toList();
    final List<HireRequestModel> completed = requests.where((HireRequestModel r) => r.status == HireRequestStatus.completed).toList();

    return DefaultTabController(
      length: 3,
      child: Column(
        children: <Widget>[
          const TabBar(tabs: <Widget>[Tab(text: 'Active Hires'), Tab(text: 'Sent Requests'), Tab(text: 'Completed')]),
          Expanded(
            child: TabBarView(
              children: <Widget>[
                _list(active, 'No active hires yet.'),
                _list(sent, 'No requests sent yet.'),
                _list(completed, 'No completed hires yet.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _list(List<HireRequestModel> items, String emptyText) {
    if (items.isEmpty) {
      return Center(child: Text(emptyText));
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (_, int i) => HireRequestTile(request: items[i]),
    );
  }
}
