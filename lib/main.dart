import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'mpesa_service.dart';
import 'bills_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(BudgetManagerApp());
}

class BudgetManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: HomeScreen(),
    );
  }
}

class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  double allocated;
  double spent;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.allocated,
    required this.spent,
  });

  double get remaining => allocated - spent;
  double get percentUsed => allocated > 0 ? (spent / allocated) * 100 : 0;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'iconCode': icon.codePoint,
    'colorValue': color.value,
    'allocated': allocated,
    'spent': spent,
  };

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'],
    name: json['name'],
    icon: IconData(json['iconCode'], fontFamily: 'MaterialIcons'),
    color: Color(json['colorValue']),
    allocated: json['allocated'].toDouble(),
    spent: json['spent'].toDouble(),
  );
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double walletBalance = 0;
  List<Category> categories = [];
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadAd();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      walletBalance = prefs.getDouble('walletBalance') ?? 0;
      
      final categoriesJson = prefs.getString('categories');
      if (categoriesJson != null) {
        final List<dynamic> decoded = json.decode(categoriesJson);
        categories = decoded.map((json) => Category.fromJson(json)).toList();
      } else {
        categories = [
          Category(id: '1', name: 'Food', icon: Icons.restaurant, color: Colors.green, allocated: 0, spent: 0),
          Category(id: '2', name: 'Bills', icon: Icons.receipt, color: Colors.orange, allocated: 0, spent: 0),
          Category(id: '3', name: 'Transport', icon: Icons.directions_car, color: Colors.blue, allocated: 0, spent: 0),
          Category(id: '4', name: 'Rent', icon: Icons.home, color: Colors.purple, allocated: 0, spent: 0),
          Category(id: '5', name: 'Utilities', icon: Icons.water_drop, color: Colors.cyan, allocated: 0, spent: 0),
          Category(id: '6', name: 'Entertainment', icon: Icons.movie, color: Colors.pink, allocated: 0, spent: 0),
        ];
      }
    });
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-5859605644313067/5532736116',
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('walletBalance', walletBalance);
    final categoriesJson = json.encode(categories.map((c) => c.toJson()).toList());
    await prefs.setString('categories', categoriesJson);
  }

  void _addFunds() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Funds to Wallet'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Amount (KES)',
            prefixText: 'KES ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                setState(() {
                  walletBalance += amount;
                });
                _saveData();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('KES ${amount.toStringAsFixed(2)} added!'), backgroundColor: Colors.green),
                );
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _allocateBudget(Category category) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Allocate: ${category.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Wallet: KES ${walletBalance.toStringAsFixed(2)}'),
            SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount (KES)',
                prefixText: 'KES ',
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
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                if (amount <= walletBalance) {
                  setState(() {
                    category.allocated += amount;
                    walletBalance -= amount;
                  });
                  _saveData();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('KES ${amount.toStringAsFixed(2)} allocated!'), backgroundColor: Colors.green),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Insufficient wallet balance!'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: Text('Allocate'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalAllocated = categories.fold(0.0, (sum, c) => sum + c.allocated);
    final totalSpent = categories.fold(0.0, (sum, c) => sum + c.spent);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade50, Colors.indigo.shade50],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 80,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text('Budget Manager', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                  centerTitle: false,
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.receipt_long, color: Colors.black87),
                    tooltip: 'Pay Bills',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BillsScreen()),
                      );
                    },
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Wallet Card
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Colors.blue, Colors.indigo]),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Wallet Balance', style: TextStyle(color: Colors.white70)),
                                    Text('KES ${walletBalance.toStringAsFixed(2)}', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                ElevatedButton.icon(
                                  onPressed: _addFunds,
                                  icon: Icon(Icons.add),
                                  label: Text('Add Funds'),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.blue),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text('Allocated', style: TextStyle(color: Colors.white70)),
                                      Text('KES ${totalAllocated.toStringAsFixed(2)}', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text('Spent', style: TextStyle(color: Colors.white70)),
                                      Text('KES ${totalSpent.toStringAsFixed(2)}', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),
                      // Categories
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Budget Categories', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CategoryScreen(
                                    category: category,
                                    onUpdate: () {
                                      setState(() {});
                                      _saveData();
                                    },
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                              ),
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: category.color,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(category.icon, color: Colors.white),
                                      ),
                                      TextButton(
                                        onPressed: () => _allocateBudget(category),
                                        child: Text('+ Allocate', style: TextStyle(fontSize: 12)),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(category.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  SizedBox(height: 4),
                                  Text('Allocated: KES ${category.allocated.toStringAsFixed(2)}', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  Text('Spent: KES ${category.spent.toStringAsFixed(2)}', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  Text('Remaining: KES ${category.remaining.toStringAsFixed(2)}', style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
                                  SizedBox(height: 8),
                                  if (category.allocated > 0)
                                    LinearProgressIndicator(
                                      value: category.percentUsed / 100,
                                      backgroundColor: Colors.grey.shade200,
                                      color: category.percentUsed > 100 ? Colors.red : Colors.green,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _isAdLoaded && _bannerAd != null
          ? Container(
              height: 60,
              child: AdWidget(ad: _bannerAd!),
            )
          : null,
    );
  }
}

class CategoryScreen extends StatefulWidget {
  final Category category;
  final VoidCallback onUpdate;

  CategoryScreen({required this.category, required this.onUpdate});

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  void _makePayment() {
    final amountController = TextEditingController();
    final descController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Make M-Pesa Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'M-Pesa Phone Number',
                hintText: '0712345678',
                prefixText: '+254 ',
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Amount (KES)', prefixText: 'KES '),
            ),
            SizedBox(height: 8),
            TextField(
              controller: descController,
              decoration: InputDecoration(labelText: 'Description'),
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
              final amount = double.tryParse(amountController.text);
              final phone = phoneController.text.trim();
              
              if (amount != null && amount > 0 && phone.isNotEmpty) {
                if (amount <= widget.category.remaining) {
                  Navigator.pop(context);
                  
                  // Show loading
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => Center(child: CircularProgressIndicator()),
                  );
                  
                  // Call M-Pesa STK Push
                  final result = await MpesaService.stkPush(
                    phoneNumber: phone,
                    amount: amount,
                    accountReference: widget.category.name,
                    transactionDesc: descController.text.isEmpty ? 'Payment' : descController.text,
                  );
                  
                  Navigator.pop(context); // Close loading
                  
                  if (result['success']) {
                    // Payment initiated successfully
                    setState(() {
                      widget.category.spent += amount;
                    });
                    widget.onUpdate();
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result['message']),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 5),
                      ),
                    );
                  } else {
                    // Payment failed
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result['message']),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 5),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Insufficient budget!'), backgroundColor: Colors.red),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please fill all fields!'), backgroundColor: Colors.red),
                );
              }
            },
            child: Text('Pay with M-Pesa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        backgroundColor: widget.category.color,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(widget.category.icon, size: 50, color: widget.category.color),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('Allocated', style: TextStyle(color: Colors.grey)),
                          Text('KES ${widget.category.allocated.toStringAsFixed(2)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        children: [
                          Text('Spent', style: TextStyle(color: Colors.grey)),
                          Text('KES ${widget.category.spent.toStringAsFixed(2)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        children: [
                          Text('Remaining', style: TextStyle(color: Colors.grey)),
                          Text('KES ${widget.category.remaining.toStringAsFixed(2)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _makePayment,
                icon: Icon(Icons.payment),
                label: Text('Make Payment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.all(16),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}