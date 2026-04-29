import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_fiverr/providers/data_provider.dart';
import 'package:mini_fiverr/widgets/hire_request_tile.dart';

class HireRequestsScreen extends StatelessWidget {
  const HireRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final requests = context.watch<DataProvider>().clientRequests;
    return ListView.builder(
      itemCount: requests.length,
      itemBuilder: (_, int i) => HireRequestTile(request: requests[i]),
    );
  }
}
