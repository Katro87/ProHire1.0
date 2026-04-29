import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mini_fiverr/models/professional_model.dart';
import 'package:mini_fiverr/providers/data_provider.dart';
import 'package:mini_fiverr/widgets/toast_notification.dart';

class SendHireRequestScreen extends StatefulWidget {
  const SendHireRequestScreen({super.key, required this.professional});

  final ProfessionalModel professional;

  @override
  State<SendHireRequestScreen> createState() => _SendHireRequestScreenState();
}

class _SendHireRequestScreenState extends State<SendHireRequestScreen> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _budget = TextEditingController();
  DateTime _deadline = DateTime.now().add(const Duration(days: 7));

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _budget.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Hire Request')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            TextField(controller: _title, decoration: const InputDecoration(labelText: 'Project Title')),
            const SizedBox(height: 10),
            TextField(controller: _description, minLines: 3, maxLines: 6, decoration: const InputDecoration(labelText: 'Project Description')),
            const SizedBox(height: 10),
            TextField(
              controller: _budget,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Budget', prefixText: '\$ '),
            ),
            const SizedBox(height: 10),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Deadline'),
              subtitle: Text(DateFormat.yMMMd().format(_deadline)),
              trailing: const Icon(Icons.calendar_today_rounded),
              onTap: () async {
                final DateTime? date = await showDatePicker(
                  context: context,
                  initialDate: _deadline,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 500)),
                );
                if (date != null) {
                  setState(() => _deadline = date);
                }
              },
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final double budget = double.tryParse(_budget.text.trim()) ?? 0;
                  if (_title.text.trim().isEmpty || _description.text.trim().isEmpty || budget <= 0) {
                    ToastService.showWarning('Please complete all fields');
                    return;
                  }
                  context.read<DataProvider>().sendHireRequest(
                        pro: widget.professional,
                        projectTitle: _title.text.trim(),
                        description: _description.text.trim(),
                        budget: budget,
                        deadline: _deadline,
                      );
                  ToastService.showSuccess('Hire request sent');
                  Navigator.pop(context);
                },
                child: const Text('Send Request'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
