import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../models/withdrawal.dart';
import '../services/storage_service.dart';
import 'new_withdrawal_page.dart';

class WithdrawalsPage extends StatefulWidget {
  const WithdrawalsPage({super.key});

  @override
  State<WithdrawalsPage> createState() => _WithdrawalsPageState();
}

class _WithdrawalsPageState extends State<WithdrawalsPage> {
  List<Withdrawal> _allWithdrawals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWithdrawals();
  }

  // Load withdrawals from local storage
  Future<void> _loadWithdrawals() async {
    setState(() {
      _isLoading = true;
    });
    final withdrawals = await StorageService.getWithdrawals();
    // Sort by most recent withdrawal date
    withdrawals.sort((a, b) => b.withdrawalDate.compareTo(a.withdrawalDate));

    setState(() {
      _allWithdrawals = withdrawals;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdrawals Log'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWithdrawals, // Manual refresh
          ),
        ],
      ),
      
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Informational note
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Below is a list of successful withdrawals processed by all clerks (or the current clerk for a real app).',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
          
          // Withdrawal List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _allWithdrawals.isEmpty
                    ? const Center(child: Text('No withdrawals have been processed yet.'))
                    : ListView.builder(
                        itemCount: _allWithdrawals.length,
                        itemBuilder: (context, index) {
                          final withdrawal = _allWithdrawals[index];
                          return WithdrawalCard(withdrawal: withdrawal);
                        },
                      ),
          ),
        ],
      ),
      
      // "New Withdrawal" Floating Action Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewWithdrawalPage(onWithdrawalCreated: _loadWithdrawals),
            ),
          );
        },
        label: const Text('New Withdrawal'),
        icon: const Icon(Icons.money_off),
        backgroundColor: Colors.blue, // Differentiate from deposits
        foregroundColor: Colors.white,
      ),
    );
  }
}

// Widget for displaying a single withdrawal
class WithdrawalCard extends StatelessWidget {
  final Withdrawal withdrawal;
  const WithdrawalCard({super.key, required this.withdrawal});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Colors.blue.withOpacity(0.05),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12.0),
        leading: const Icon(
          Icons.done_all,
          color: Colors.blue,
          size: 30,
        ),
        title: Text(
          'Ref: ${withdrawal.depositRefNumber}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Withdrawal ID: ${withdrawal.withdrawalId.substring(0, 8)}...'),
            Text('Date: ${DateFormat('dd MMM yy - HH:mm').format(withdrawal.withdrawalDate)}'),
            Text('Processed by: ${withdrawal.clerkId}'),
          ],
        ),
        trailing: const Chip(
          label: Text('COLLECTED'),
          backgroundColor: Colors.blue,
          labelStyle: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}