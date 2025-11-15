// lib/services/storage_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/deposit.dart';
import '../models/withdrawal.dart'; // <-- Import the new model

class StorageService {
  static const String _depositKey = 'deposits_list';
  static const String _withdrawalKey = 'withdrawals_list'; // <-- New key

  // --- Deposit Functions (Existing) ---
  
  // Saves a single new deposit and updates the full list
  static Future<void> saveDeposit(Deposit deposit) async {
    // ... (existing code for saving deposit)
    final prefs = await SharedPreferences.getInstance();
    List<Deposit> currentDeposits = await getDeposits();
    currentDeposits.add(deposit);

    final List<String> encodedList = currentDeposits
        .map((d) => jsonEncode(d.toJson()))
        .toList();

    await prefs.setStringList(_depositKey, encodedList);
  }

  // Retrieves all deposits from local storage
  static Future<List<Deposit>> getDeposits() async {
    // ... (existing code for getting deposits)
    final prefs = await SharedPreferences.getInstance();
    final List<String>? encodedList = prefs.getStringList(_depositKey);

    if (encodedList == null) {
      return [];
    }

    return encodedList
        .map((e) => Deposit.fromJson(jsonDecode(e)))
        .toList();
  }

  // Updates a deposit (e.g., when it is collected/withdrawn)
  static Future<void> updateDeposit(Deposit updatedDeposit) async {
    // ... (existing code for updating deposit)
    final prefs = await SharedPreferences.getInstance();
    List<Deposit> currentDeposits = await getDeposits();

    // Find and replace the old deposit with the updated one
    final index = currentDeposits.indexWhere(
        (d) => d.referenceNumber == updatedDeposit.referenceNumber);

    if (index != -1) {
      currentDeposits[index] = updatedDeposit;
      final List<String> encodedList = currentDeposits
          .map((d) => jsonEncode(d.toJson()))
          .toList();

      await prefs.setStringList(_depositKey, encodedList);
    }
  }
  
  // --- Withdrawal Functions (New) ---

  // Saves a new withdrawal record
  static Future<void> saveWithdrawal(Withdrawal withdrawal) async {
    final prefs = await SharedPreferences.getInstance();
    List<Withdrawal> currentWithdrawals = await getWithdrawals();
    currentWithdrawals.add(withdrawal);

    final List<String> encodedList = currentWithdrawals
        .map((w) => jsonEncode(w.toJson()))
        .toList();

    await prefs.setStringList(_withdrawalKey, encodedList);
  }

  // Retrieves all withdrawals from local storage
  static Future<List<Withdrawal>> getWithdrawals() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? encodedList = prefs.getStringList(_withdrawalKey);

    if (encodedList == null) {
      return [];
    }

    return encodedList
        .map((e) => Withdrawal.fromJson(jsonDecode(e)))
        .toList();
  }

  // Clears all deposits (useful for testing/resetting)
  static Future<void> clearAllDeposits() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_depositKey);
    // You might want to add clearAllWithdrawals here as well
  }
}
  // Clears all withdrawals (useful for testing/resetting)
  // static Future<void> clearAllWithdrawals() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.remove(_withdrawalKey);
  // }