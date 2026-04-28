import 'package:flutter/material.dart';
import 'package:mini_fiverr/screens/chat/chat_room_screen.dart';
import 'package:mini_fiverr/utils/error_handler.dart';
import 'package:mini_fiverr/utils/theme.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<int> _acceptedIndices = {};
  final Set<int> _declinedIndices = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Lab'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildJobsList('pending'),
          _buildJobsList('active'),
          _buildJobsList('completed'),
        ],
      ),
    );
  }

  Widget _buildJobsList(String status) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: status == 'pending' ? 3 : (status == 'active' ? 1 : 2),
      itemBuilder: (context, index) {
        return _buildJobCard(status, index);
      },
    );
  }

  Future<void> _acceptJob(int index) async {
    try {
      setState(() {
        _acceptedIndices.add(index);
        _declinedIndices.remove(index);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorHandler.getSuccessMessage('jobAccepted')),
          backgroundColor: Colors.green,
        ),
      );

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ChatRoomScreen(
            userName: 'Alice Johnson',
            userPic: 'https://i.pravatar.cc/100?u=0',
            receiverId: 'demo_client_0',
            chatId: 'job_chat_0',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorHandler.getHumanReadableError(e)),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  void _declineJob(int index) {
    setState(() {
      _declinedIndices.add(index);
      _acceptedIndices.remove(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ErrorHandler.getSuccessMessage('jobDeclined')),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Widget _buildJobCard(String status, int index) {
    Color statusColor = status == 'pending' ? AppColors.accent : (status == 'active' ? AppColors.success : AppColors.secondary);
    final isAccepted = _acceptedIndices.contains(index);
    final isDeclined = _declinedIndices.contains(index);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const CircleAvatar(radius: 12, backgroundImage: NetworkImage('https://i.pravatar.cc/50')),
                    const SizedBox(width: 8),
                    const Text('Alice Johnson', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Modern Dashboard UI Design', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 4),
            const Text('Design a 10-page responsive dashboard for a crypto trading platform.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('\$550.00', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                if (status == 'pending' && !isAccepted && !isDeclined) 
                  Row(
                    children: [
                      TextButton(onPressed: () => _declineJob(index), child: const Text('Decline', style: TextStyle(color: AppColors.error))),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _acceptJob(index), 
                        style: ElevatedButton.styleFrom(minimumSize: const Size(80, 36), padding: const EdgeInsets.symmetric(horizontal: 16)),
                        child: const Text('Accept'),
                      ),
                    ],
                  )
                else if (status == 'active' || isAccepted)
                  ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatRoomScreen(userName: 'Alice Johnson', userPic: 'https://i.pravatar.cc/100?u=0', receiverId: 'demo_client_0', chatId: 'job_chat_0'))),
                    style: ElevatedButton.styleFrom(minimumSize: const Size(120, 36), backgroundColor: AppColors.secondary),
                    child: const Text('Go to Chat'),
                  )
                else
                  Text(isDeclined ? 'Declined' : '2 days ago', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
