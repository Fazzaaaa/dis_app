import 'package:flutter/material.dart';
import 'package:dis_app/utils/constants/colors.dart';
import 'package:dis_app/utils/constants/row.dart';
import 'package:dis_app/utils/constants/success.dart';
import 'package:dis_app/utils/constants/failed.dart';

class ConfirmTransactionScreen extends StatelessWidget {
  final String amount;
  final Map<String, dynamic> bankDetails;

  ConfirmTransactionScreen({
    required this.amount,
    required this.bankDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Transaction'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Total Amount To Withdraw',
                      style: TextStyle(
                        color: DisColors.black,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'IDR $amount',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: DisColors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: DisColors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DisBuildRow(label: 'Withdraw Amount', value: 'IDR $amount'),
                  const SizedBox(height: 8),
                  DisBuildRow(label: 'Withdraw To', value: bankDetails['name']),
                  const SizedBox(height: 8),
                  DisBuildRow(label: 'Bank Name', value: bankDetails['bank']),
                  const SizedBox(height: 8),
                  DisBuildRow(
                    label: 'Account Number',
                    value: bankDetails['accountNumber'],
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final int withdrawAmount = int.tryParse(amount) ?? 0;
                  final int availableBalance = bankDetails['balance'] ?? 0;

                  if (withdrawAmount < 10000) {
                    showDialog(
                      context: context,
                      builder: (context) => DisFailed(
                        message: "Minimum withdrawal amount is IDR 10,000.",
                        onRetry: () => Navigator.pop(context),
                      ),
                    );
                    return;
                  }

                  if (withdrawAmount > availableBalance) {
                    showDialog(
                      context: context,
                      builder: (context) => DisFailed(
                        message:
                            "Insufficient balance. Please check your account.",
                        onRetry: () => Navigator.pop(context),
                      ),
                    );
                    return;
                  }

                  final bool success = await _simulateTransaction();

                  if (success) {
                    showDialog(
                      context: context,
                      builder: (context) => DisSuccess(
                        onClose: () => Navigator.pop(context),
                      ),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => DisFailed(
                        message: "Transaction failed. Please try again.",
                        onRetry: () => Navigator.pop(context),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: DisColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: const Text(
                  'Withdraw Now',
                  style: TextStyle(
                    fontSize: 16,
                    color: DisColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _simulateTransaction() async {
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }
}