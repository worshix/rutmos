import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; // We'll use a unique ID generator
import '../main.dart'; // For kPrimaryColor
import '../models/deposit.dart';
import '../services/storage_service.dart';

// NOTE: You must add 'uuid: ^4.3.1' to your pubspec.yaml and run 'flutter pub get'
// dependencies:
//   ...
//   uuid: ^4.3.1

class NewDepositPage extends StatefulWidget {
  final VoidCallback onDepositCreated;
  const NewDepositPage({super.key, required this.onDepositCreated});

  @override
  State<NewDepositPage> createState() => _NewDepositPageState();
}

class _NewDepositPageState extends State<NewDepositPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dName = TextEditingController();
  final TextEditingController _dSName = TextEditingController();
  final TextEditingController _dCell = TextEditingController();
  final TextEditingController _rName = TextEditingController();
  final TextEditingController _rSName = TextEditingController();
  final TextEditingController _rCell = TextEditingController();
  final TextEditingController _rId = TextEditingController();
  String _rCountry = 'ZIMBABWE'; // Default country

  // List of countries (for demonstration)
  final List<String> _countries = [
    'ZIMBABWE', 
    'SOUTH AFRICA', 
    'ZAMBIA', 
    'BOTSWANA', 
    'MOZAMBIQUE'
  ];

  @override
  void dispose() {
    _dName.dispose();
    _dSName.dispose();
    _dCell.dispose();
    _rName.dispose();
    _rSName.dispose();
    _rCell.dispose();
    _rId.dispose();
    super.dispose();
  }

  Future<void> _saveDeposit() async {
    if (_formKey.currentState!.validate()) {
      // 1. Generate a unique 8-character reference number (UUID shortened)
      const uuid = Uuid();
      final String refNumber = uuid.v4().substring(0, 8).toUpperCase();

      // 2. Create the Deposit object
      final newDeposit = Deposit(
        referenceNumber: refNumber,
        depositorName: _dName.text.trim(),
        depositorSurname: _dSName.text.trim(),
        depositorCell: _dCell.text.trim(),
        receiverName: _rName.text.trim(),
        receiverSurname: _rSName.text.trim(),
        receiverCell: _rCell.text.trim(),
        receiverIdNumber: _rId.text.trim(),
        receiverCountry: _rCountry,
        depositDate: DateTime.now(),
        isCollected: false,
      );

      // 3. Save to local storage
      await StorageService.saveDeposit(newDeposit);

      // 4. Notify parent widget and navigate back
      widget.onDepositCreated();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deposit $refNumber created successfully!')),
      );
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter the $label';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Deposit'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text('Depositor Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              _buildTextField(_dName, 'Depositor Name', 'e.g., Jane'),
              _buildTextField(_dSName, 'Depositor Surname', 'e.g., Smith'),
              _buildTextField(_dCell, 'Depositor Cell Number', 'e.g., +26377xxxxxxx', type: TextInputType.phone),

              const SizedBox(height: 20),

              const Text('Receiver Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              _buildTextField(_rName, 'Receiver Name', 'e.g., John'),
              _buildTextField(_rSName, 'Receiver Surname', 'e.g., Doe'),
              _buildTextField(_rCell, 'Receiver Cell Number', 'e.g., +2783xxxxxxx', type: TextInputType.phone),
              _buildTextField(_rId, 'Receiver ID Number', 'e.g., 9010123456789'),
              
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: DropdownButtonFormField<String>(
                  value: _rCountry,
                  decoration: const InputDecoration(
                    labelText: 'Receiver Country',
                    border: OutlineInputBorder(),
                  ),
                  items: _countries.map((String country) {
                    return DropdownMenuItem<String>(
                      value: country,
                      child: Text(country),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _rCountry = newValue!;
                    });
                  },
                  validator: (value) => value == null ? 'Please select a country' : null,
                ),
              ),

              const SizedBox(height: 30),
              
              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Complete Deposit', style: TextStyle(fontSize: 18)),
                onPressed: _saveDeposit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}