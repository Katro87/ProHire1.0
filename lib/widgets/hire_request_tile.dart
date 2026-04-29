import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mini_fiverr/models/job_model.dart';
import 'package:mini_fiverr/utils/theme.dart';

class HireRequestTile extends StatelessWidget {
  const HireRequestTile({
    super.key,
    required this.request,
    this.onAccept,
    this.onDecline,
    this.onReleasePayment,
  });

  final HireRequestModel request;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onReleasePayment;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: glassCardDecoration(accent: _statusColor(request.status)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(request.projectTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Budget: \$${request.budget.toStringAsFixed(0)}  |  Deadline: ${DateFormat.yMMMd().format(request.deadline)}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: <Widget>[
              _badge(request.status.name.toUpperCase(), _statusColor(request.status)),
              if (request.status == HireRequestStatus.completed && !request.amountReleased)
                _badge('Awaiting Payment Release', AppColors.warning),
            ],
          ),
          if (onAccept != null || onDecline != null || onReleasePayment != null) ...<Widget>[
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                if (onDecline != null)
                  Expanded(
                    child: OutlinedButton(onPressed: onDecline, child: const Text('Decline')),
                  ),
                if (onDecline != null) const SizedBox(width: 8),
                if (onAccept != null)
                  Expanded(
                    child: ElevatedButton(onPressed: onAccept, child: const Text('Accept')),
                  ),
                if (onReleasePayment != null)
                  Expanded(
                    child: ElevatedButton(onPressed: onReleasePayment, child: const Text('Release Payment')),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 11)),
    );
  }

  Color _statusColor(HireRequestStatus status) {
    switch (status) {
      case HireRequestStatus.pending:
        return AppColors.warning;
      case HireRequestStatus.accepted:
      case HireRequestStatus.active:
        return AppColors.success;
      case HireRequestStatus.declined:
        return AppColors.error;
      case HireRequestStatus.completed:
        return AppColors.secondary;
    }
  }
}
