import 'package:flutter/material.dart';
import 'mpesa_service.dart';

class BillsScreen extends StatefulWidget {
  @override
  _BillsScreenState createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _payKPLC() {
    final amountController = TextEditingController();
    final accountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.electric_bolt, color: Colors.orange),
            SizedBox(width: 8),
            Text('Pay KPLC Bill'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'M-Pesa Phone',
                hintText: '0712345678',
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: accountController,
              decoration: InputDecoration(
                labelText: 'Account Number',
                hintText: 'Your KPLC account',
                prefixIcon: Icon(Icons.account_circle),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount (KES)',
                prefixText: 'KES ',
                prefixIcon: Icon(Icons.money),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final phone = _phoneController.text.trim();
              final account = accountController.text.trim();
              final amount = double.tryParse(amountController.text);

              if (phone.isNotEmpty && account.isNotEmpty && amount != null && amount > 0) {
                Navigator.pop(context);

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => Center(child: CircularProgressIndicator()),
                );

                final result = await MpesaService.payBill(
                  phoneNumber: phone,
                  amount: amount,
                  paybillNumber: '888880', // KPLC Paybill
                  accountNumber: account,
                  transactionDesc: 'KPLC Bill Payment',
                );

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['message']),
                    backgroundColor: result['success'] ? Colors.green : Colors.red,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please fill all fields!'), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text('Pay Bill'),
          ),
        ],
      ),
    );
  }

  void _payWater() {
    final amountController = TextEditingController();
    final accountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.water_drop, color: Colors.blue),
            SizedBox(width: 8),
            Text('Pay Water Bill'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'M-Pesa Phone',
                hintText: '0712345678',
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: accountController,
              decoration: InputDecoration(
                labelText: 'Account Number',
                hintText: 'Your water account',
                prefixIcon: Icon(Icons.account_circle),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount (KES)',
                prefixText: 'KES ',
                prefixIcon: Icon(Icons.money),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final phone = _phoneController.text.trim();
              final account = accountController.text.trim();
              final amount = double.tryParse(amountController.text);

              if (phone.isNotEmpty && account.isNotEmpty && amount != null && amount > 0) {
                Navigator.pop(context);

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => Center(child: CircularProgressIndicator()),
                );

                final result = await MpesaService.payBill(
                  phoneNumber: phone,
                  amount: amount,
                  paybillNumber: '123456', // Example water paybill
                  accountNumber: account,
                  transactionDesc: 'Water Bill Payment',
                );

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['message']),
                    backgroundColor: result['success'] ? Colors.green : Colors.red,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please fill all fields!'), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: Text('Pay Bill'),
          ),
        ],
      ),
    );
  }

  void _buyAirtime() {
    final amountController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.phone_android, color: Colors.green),
            SizedBox(width: 8),
            Text('Buy Airtime'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: '0712345678',
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount (KES)',
                prefixText: 'KES ',
                prefixIcon: Icon(Icons.money),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final phone = phoneController.text.trim();
              final amount = double.tryParse(amountController.text);

              if (phone.isNotEmpty && amount != null && amount > 0) {
                Navigator.pop(context);

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => Center(child: CircularProgressIndicator()),
                );

                final result = await MpesaService.buyAirtime(
                  phoneNumber: phone,
                  amount: amount,
                );

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['message']),
                    backgroundColor: result['success'] ? Colors.green : Colors.red,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please fill all fields!'), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Buy Airtime'),
          ),
        ],
      ),
    );
  }

  void _payCustomBill() {
    final amountController = TextEditingController();
    final paybillController = TextEditingController();
    final accountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.payment, color: Colors.purple),
            SizedBox(width: 8),
            Text('Pay Any Bill'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Your M-Pesa Phone',
                  hintText: '0712345678',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: paybillController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Paybill/Till Number',
                  hintText: '123456',
                  prefixIcon: Icon(Icons.store),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: accountController,
                decoration: InputDecoration(
                  labelText: 'Account Number',
                  hintText: 'Account or reference',
                  prefixIcon: Icon(Icons.account_circle),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount (KES)',
                  prefixText: 'KES ',
                  prefixIcon: Icon(Icons.money),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final phone = _phoneController.text.trim();
              final paybill = paybillController.text.trim();
              final account = accountController.text.trim();
              final amount = double.tryParse(amountController.text);

              if (phone.isNotEmpty && paybill.isNotEmpty && amount != null && amount > 0) {
                Navigator.pop(context);

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => Center(child: CircularProgressIndicator()),
                );

                final result = await MpesaService.payBill(
                  phoneNumber: phone,
                  amount: amount,
                  paybillNumber: paybill,
                  accountNumber: account.isEmpty ? 'Payment' : account,
                  transactionDesc: 'Bill Payment',
                );

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['message']),
                    backgroundColor: result['success'] ? Colors.green : Colors.red,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please fill required fields!'), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: Text('Pay Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pay Bills'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade50, Colors.indigo.shade50],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Payments',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Pay your bills instantly with M-Pesa',
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildBillCard(
                      icon: Icons.electric_bolt,
                      title: 'KPLC',
                      subtitle: 'Electricity',
                      color: Colors.orange,
                      onTap: _payKPLC,
                    ),
                    _buildBillCard(
                      icon: Icons.water_drop,
                      title: 'Water',
                      subtitle: 'Water Bills',
                      color: Colors.blue,
                      onTap: _payWater,
                    ),
                    _buildBillCard(
                      icon: Icons.phone_android,
                      title: 'Airtime',
                      subtitle: 'Buy airtime',
                      color: Colors.green,
                      onTap: _buyAirtime,
                    ),
                    _buildBillCard(
                      icon: Icons.payment,
                      title: 'Other Bills',
                      subtitle: 'Any paybill',
                      color: Colors.purple,
                      onTap: _payCustomBill,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBillCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: color),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}