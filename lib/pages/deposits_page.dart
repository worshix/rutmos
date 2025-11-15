import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // NOTE: Add 'intl: ^0.18.1' to pubspec.yaml
import '../main.dart';
import '../models/deposit.dart';
import '../services/storage_service.dart';
import 'new_deposit_page.dart';

// NOTE: You must add 'intl: ^0.18.1' to your pubspec.yaml and run 'flutter pub get'
// dependencies:
//   ...
//   intl: ^0.18.1

class DepositsPage extends StatefulWidget {
  const DepositsPage({super.key});

  @override
  State<DepositsPage> createState() => _DepositsPageState();
}

class _DepositsPageState extends State<DepositsPage> {
  List<Deposit> _allDeposits = [];
  bool _showAllTime = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeposits();
  }

  // Load deposits from local storage
  Future<void> _loadDeposits() async {
    setState(() {
      _isLoading = true;
    });
    final deposits = await StorageService.getDeposits();
    // Sort by most recent deposit date
    deposits.sort((a, b) => b.depositDate.compareTo(a.depositDate));

    setState(() {
      _allDeposits = deposits;
      _isLoading = false;
    });
  }

  // Filter deposits to show only today's
  List<Deposit> get _filteredDeposits {
    if (_showAllTime) {
      return _allDeposits;
    }
    
    // Filter for today's deposits
    final now = DateTime.now();
    return _allDeposits.where((d) {
      return d.depositDate.year == now.year &&
             d.depositDate.month == now.month &&
             d.depositDate.day == now.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showAllTime ? 'All Deposits' : 'Today\'s Deposits'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDeposits, // Manual refresh
          ),
        ],
      ),
      
      body: Column(
        children: [
          // "View Past Deposits" Toggle Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showAllTime = !_showAllTime;
                    });
                  },
                  icon: Icon(_showAllTime ? Icons.calendar_today : Icons.history),
                  label: Text(_showAllTime ? 'View Today\'s' : 'View Past Deposits'),
                  style: TextButton.styleFrom(foregroundColor: kPrimaryColor),
                ),
              ],
            ),
          ),

          // Deposit List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredDeposits.isEmpty
                    ? Center(child: Text(_showAllTime ? 'No deposits found.' : 'No deposits made today.'))
                    : ListView.builder(
                        itemCount: _filteredDeposits.length,
                        itemBuilder: (context, index) {
                          final deposit = _filteredDeposits[index];
                          return DepositCard(deposit: deposit);
                        },
                      ),
          ),
        ],
      ),
      
      // "New Deposit" Floating Action Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewDepositPage(onDepositCreated: _loadDeposits),
            ),
          );
        },
        label: const Text('New Deposit'),
        icon: const Icon(Icons.add),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}

// Widget for displaying a single deposit
class DepositCard extends StatelessWidget {
  final Deposit deposit;
  const DepositCard({super.key, required this.deposit});

  Color _getStatusColor(DepositStatus status) {
    switch (status) {
      case DepositStatus.collected:
        return Colors.blue;
      case DepositStatus.expired:
        return Colors.red;
      case DepositStatus.pending:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12.0),
        leading: Icon(
          Icons.account_balance_wallet,
          color: _getStatusColor(deposit.status),
          size: 30,
        ),
        title: Text(
          'Ref: ${deposit.referenceNumber}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('To: ${deposit.receiverName} ${deposit.receiverSurname} (${deposit.receiverCountry})'),
            Text('From: ${deposit.depositorName} ${deposit.depositorSurname}'),
            Text('Date: ${DateFormat('dd MMM yy - HH:mm').format(deposit.depositDate)}'),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(deposit.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: _getStatusColor(deposit.status)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                deposit.status.name.toUpperCase(),
                style: TextStyle(
                  color: _getStatusColor(deposit.status),
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
              if (deposit.status == DepositStatus.pending)
                Text(
                  '${deposit.remainingDays} days left',
                  style: TextStyle(
                    color: _getStatusColor(deposit.status),
                    fontSize: 9,
                  ),
                ),
            ],
          ),
        ),
        onTap: () {
          // Future functionality to view full deposit details
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Viewing details for ${deposit.referenceNumber}')),
          );
        },
      ),
    );
  }
}