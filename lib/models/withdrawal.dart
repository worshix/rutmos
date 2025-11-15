import 'dart:convert';
import 'package:flutter/material.dart';

// Define the Withdrawal Model
class Withdrawal {
  final String withdrawalId; // Unique ID for the withdrawal record
  final String depositRefNumber; // Links back to the original deposit
  final DateTime withdrawalDate;
  final String clerkId; // ID of the clerk processing the withdrawal (for tracking)

  Withdrawal({
    required this.withdrawalId,
    required this.depositRefNumber,
    required this.withdrawalDate,
    required this.clerkId,
  });

  // Convert a Withdrawal object to a JSON map
  Map<String, dynamic> toJson() => {
        'id': withdrawalId,
        'ref': depositRefNumber,
        'date': withdrawalDate.toIso8601String(),
        'clerk': clerkId,
      };

  // Create a Withdrawal object from a JSON map
  factory Withdrawal.fromJson(Map<String, dynamic> json) {
    return Withdrawal(
      withdrawalId: json['id'] as String,
      depositRefNumber: json['ref'] as String,
      withdrawalDate: DateTime.parse(json['date'] as String),
      clerkId: json['clerk'] as String,
    );
  }
}