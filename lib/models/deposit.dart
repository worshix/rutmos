import 'dart:convert';
import 'package:flutter/material.dart';

// Define the available statuses for a deposit
enum DepositStatus {
  pending,
  collected,
  expired,
}

// Helper function to calculate the status
DepositStatus calculateStatus(DateTime depositDate, bool isCollected) {
  if (isCollected) {
    return DepositStatus.collected;
  }
  
  // Deposit expires 30 days after creation
  final DateTime expiryDate = depositDate.add(const Duration(days: 30));
  if (DateTime.now().isAfter(expiryDate)) {
    return DepositStatus.expired;
  }
  
  return DepositStatus.pending;
}

// Define the Deposit Model
class Deposit {
  final String referenceNumber;
  final String depositorName;
  final String depositorSurname;
  final String depositorCell;
  final String receiverName;
  final String receiverSurname;
  final String receiverCell;
  final String receiverIdNumber;
  final String receiverCountry;
  final DateTime depositDate;
  bool isCollected; // Tracks if the withdrawal has been made

  Deposit({
    required this.referenceNumber,
    required this.depositorName,
    required this.depositorSurname,
    required this.depositorCell,
    required this.receiverName,
    required this.receiverSurname,
    required this.receiverCell,
    required this.receiverIdNumber,
    required this.receiverCountry,
    required this.depositDate,
    this.isCollected = false,
  });

  // Get the current status based on date and collection status
  DepositStatus get status => calculateStatus(depositDate, isCollected);

  // Remaining days for PENDING status
  int get remainingDays {
    if (status != DepositStatus.pending) return 0;
    
    final DateTime expiryDate = depositDate.add(const Duration(days: 30));
    final Duration difference = expiryDate.difference(DateTime.now());
    return difference.inDays + 1; // +1 to round up to the full day
  }

  // Convert a Deposit object to a JSON map
  Map<String, dynamic> toJson() => {
        'ref': referenceNumber,
        'dName': depositorName,
        'dSName': depositorSurname,
        'dCell': depositorCell,
        'rName': receiverName,
        'rSName': receiverSurname,
        'rCell': receiverCell,
        'rId': receiverIdNumber,
        'rCountry': receiverCountry,
        'date': depositDate.toIso8601String(),
        'collected': isCollected,
      };

  // Create a Deposit object from a JSON map
  factory Deposit.fromJson(Map<String, dynamic> json) {
    return Deposit(
      referenceNumber: json['ref'] as String,
      depositorName: json['dName'] as String,
      depositorSurname: json['dSName'] as String,
      depositorCell: json['dCell'] as String,
      receiverName: json['rName'] as String,
      receiverSurname: json['rSName'] as String,
      receiverCell: json['rCell'] as String,
      receiverIdNumber: json['rId'] as String,
      receiverCountry: json['rCountry'] as String,
      depositDate: DateTime.parse(json['date'] as String),
      isCollected: json['collected'] as bool,
    );
  }
}