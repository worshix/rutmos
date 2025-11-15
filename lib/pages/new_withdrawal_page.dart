import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../main.dart';
import '../models/deposit.dart';
import '../models/withdrawal.dart';
import '../services/storage_service.dart';
import 'package:intl/intl.dart';

class NewWithdrawalPage extends StatefulWidget {
  final VoidCallback onWithdrawalCreated;
  const NewWithdrawalPage({super.key, required this.onWithdrawalCreated});

  @override
  State<NewWithdrawalPage> createState() => _NewWithdrawalPageState();
}

class _NewWithdrawalPageState extends State<NewWithdrawalPage> {
  final TextEditingController _refController = TextEditingController();
  Deposit? _foundDeposit;
  bool _isLoading = false;
  String _message = 'Enter a Deposit Reference Number to start a withdrawal.';

  Future<void> _searchDeposit() async {
    final refNumber = _refController.text.trim().toUpperCase();
    if (refNumber.isEmpty) {
      setState(() {
        _message = 'Please enter a reference number.';
        _foundDeposit = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _foundDeposit = null;
      _message = 'Searching...';
    });

    // 1. Fetch all deposits
    final allDeposits = await StorageService.getDeposits();
    
    // 2. Find the deposit
    final found = allDeposits.firstWhereOrNull(
        (d) => d.referenceNumber == refNumber); // Helper needed for .firstWhereOrNull

    if (found != null) {
      setState(() {
        _foundDeposit = found;
        _isLoading = false;
        if (found.status == DepositStatus.collected) {
          _message = 'This deposit has already been collected.';
        } else if (found.status == DepositStatus.expired) {
          _message = 'This deposit has expired and cannot be collected.';
        } else {
          _message = 'Deposit found. Verify details and complete withdrawal.';
        }
      });
    } else {
      setState(() {
        _foundDeposit = null;
        _isLoading = false;
        _message = 'Deposit reference number not found.';
      });
    }
  }

  Future<void> _processWithdrawal() async {
    if (_foundDeposit == null || _foundDeposit!.status != DepositStatus.pending) return;

    setState(() {
      _isLoading = true;
    });

    // 1. Update Deposit status to collected
    _foundDeposit!.isCollected = true;
    await StorageService.updateDeposit(_foundDeposit!);

    // 2. Create Withdrawal record
    const uuid = Uuid();
    final newWithdrawal = Withdrawal(
      withdrawalId: uuid.v4(),
      depositRefNumber: _foundDeposit!.referenceNumber,
      withdrawalDate: DateTime.now(),
      clerkId: 'CLERK_ID_123', // Placeholder for the logged-in clerk
    );

    // 3. Save Withdrawal record
    await StorageService.saveWithdrawal(newWithdrawal);

    // 4. Notify parent and navigate back
    widget.onWithdrawalCreated();
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Withdrawal successfully processed!')),
    );
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Withdrawal'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Search Field
            TextField(
              controller: _refController,
              decoration: InputDecoration(
                labelText: 'Reference Number',
                hintText: 'Enter 8-digit Ref No.',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchDeposit,
                ),
                border: const OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
              onSubmitted: (_) => _searchDeposit(),
            ),
            const SizedBox(height: 20),
            
            // Status and Message
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _message,
                      style: TextStyle(
                        color: _foundDeposit == null 
                            ? Colors.black 
                            : _foundDeposit!.status == DepositStatus.pending
                                ? Colors.green
                                : Colors.red,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),

            const SizedBox(height: 30),

            // Found Deposit Details Card
            if (_foundDeposit != null)
              DepositDetailCard(deposit: _foundDeposit!),
              
            const SizedBox(height: 30),

            // Process Button (Only visible for PENDING deposits)
            if (_foundDeposit != null && _foundDeposit!.status == DepositStatus.pending)
              ElevatedButton.icon(
                icon: const Icon(Icons.money_off),
                label: const Text('Process Withdrawal', style: TextStyle(fontSize: 18)),
                onPressed: _processWithdrawal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Use a different color for emphasis
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Helper Card to display found deposit details
class DepositDetailCard extends StatelessWidget {
  final Deposit deposit;
  const DepositDetailCard({super.key, required this.deposit});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Receiver Details (To be Verified)', 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kPrimaryColor)
            ),
            const Divider(),
            _buildDetailRow('Reference:', deposit.referenceNumber),
            _buildDetailRow('Receiver Name:', '${deposit.receiverName} ${deposit.receiverSurname}'),
            _buildDetailRow('ID Number:', deposit.receiverIdNumber),
            _buildDetailRow('Country:', deposit.receiverCountry),
            _buildDetailRow('Deposit Date:', DateFormat('dd MMM yyyy').format(deposit.depositDate)),
            _buildDetailRow(
              'Status:', 
              deposit.status.name.toUpperCase(), 
              color: deposit.status == DepositStatus.pending ? Colors.green : Colors.red
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color color = Colors.black87}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(child: Text(value, style: TextStyle(color: color))),
        ],
      ),
    );
  }
}
// Extension to add firstWhereOrNull functionality (needed for search)
extension ListExtensions<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    try {
      return firstWhere(test);
    } catch (e) {
      return null;
    }
  }
}