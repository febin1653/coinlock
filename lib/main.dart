import 'package:flutter/material.dart';
import 'models/transaction.dart';
import 'screens/add_transaction_form.dart';
import 'screens/dashboard.dart';
import 'screens/historyview.dart';
import 'screens/personaldetailview.dart';
import 'services/expense_storage_service.dart';

void main() {
  runApp(const CoinLockApp());
}

class CoinLockApp extends StatelessWidget {
  const CoinLockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CoinLock',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Inter', // Ensure you add this to pubspec if desired
      ),
      home: const MainAppController(),
    );
  }
}

// Enum to manage views, equivalent to your type View = 'dashboard' | ...
enum AppView { dashboard, history, personDetail }

class MainAppController extends StatefulWidget {
  const MainAppController({super.key});

  @override
  State<MainAppController> createState() => _MainAppControllerState();
}

class _MainAppControllerState extends State<MainAppController> {
  // --- State Variables ---
  AppView _currentView = AppView.dashboard;
  String _selectedPerson = '';
  String _dashboardSelectedPerson = '';
  
  // Filter States
  dynamic _filterType = 'all'; 
  dynamic _filterCategory = 'all';
  String _filterPerson = '';

  // No default transactions for a clean start
  List<Transaction> _transactions = [];
  final ExpenseStorageService _storageService = ExpenseStorageService();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final loadedTransactions = await _storageService.loadTransactions();
    setState(() {
      _transactions = loadedTransactions;
    });
  }

  // --- Logic / Handlers ---

  void _handleAddTransaction(TransactionType type, Category category, double amount, String description, String person, DateTime date) {
    final newTx = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      category: category,
      amount: amount,
      description: description,
      person: person,
      date: date,
    );

    setState(() {
      _transactions.insert(0, newTx);
    });
    _storageService.saveTransactions(_transactions);
  }

  void _handleDeleteTransaction(String id) {
    setState(() {
      _transactions.removeWhere((t) => t.id == id);
    });
    _storageService.saveTransactions(_transactions);
  }

  void _handleUpdateTransaction(Transaction updatedTx) {
    setState(() {
      final index = _transactions.indexWhere((t) => t.id == updatedTx.id);
      if (index != -1) {
        _transactions[index] = updatedTx;
      }
    });
    _storageService.saveTransactions(_transactions);
  }

  void _handlePersonClick(String person) {
    if (_currentView == AppView.dashboard) {
      setState(() {
        _dashboardSelectedPerson = person;
      });
    } else {
      setState(() {
        _selectedPerson = person;
        _currentView = AppView.personDetail;
      });
    }
  }

  // Memoized equivalent in Dart (Getter)
  List<Transaction> get _filteredTransactions {
    return _transactions.where((t) {
      final typeMatch = _filterType == 'all' || t.type == _filterType;
      final categoryMatch = _filterCategory == 'all' || t.category == _filterCategory;
      final personMatch = _filterPerson.isEmpty || _normalizeName(t.person) == _normalizeName(_filterPerson);
      return typeMatch && categoryMatch && personMatch;
    }).toList();
  }

  List<String> get _uniquePeople {
    final people = _transactions.map((t) => _normalizeName(t.person)).toSet().toList();
    people.sort();
    return people;
  }

  String _normalizeName(String name) {
    name = name.trim();
    if (name.isEmpty) return name;
    return name.split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  // --- Rendering ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Persistent Header like your React code
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.5),
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 32,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.account_balance_wallet, color: Color(0xFF00FFFF), size: 32),
            ),
            const SizedBox(width: 8),
            const Text("CoinLock", 
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: -1)),
          ],
        ),
      ),
      body: _buildCurrentView(),
    );
  }

  Widget _buildCurrentView() {
    switch (_currentView) {
      case AppView.dashboard:
        return Dashboard(
          transactions: _transactions,
          onAddTransaction: _handleAddTransaction,
          onUpdateTransaction: _handleUpdateTransaction, // New
          onViewAllHistory: () => setState(() => _currentView = AppView.history),
          onPersonClick: _handlePersonClick,
          onDeleteTransaction: _handleDeleteTransaction,
          selectedPerson: _dashboardSelectedPerson,
        );
      case AppView.personDetail:
        return PersonDetailView(
          person: _selectedPerson,
          transactions: _transactions,
          onBack: () => setState(() => _currentView = AppView.history),
          onDeleteTransaction: _handleDeleteTransaction,
          onUpdateTransaction: _handleUpdateTransaction,
        );
      case AppView.history:
        return HistoryView(
          transactions: _transactions,
          filteredTransactions: _filteredTransactions,
          filterType: _filterType,
          filterCategory: _filterCategory,
          filterPerson: _filterPerson,
          uniquePeople: _uniquePeople,
          onTypeChange: (val) => setState(() => _filterType = val),
          onCategoryChange: (val) => setState(() => _filterCategory = val),
          onPersonChange: (val) => setState(() => _filterPerson = val),
          onDeleteTransaction: _handleDeleteTransaction,
          onUpdateTransaction: _handleUpdateTransaction, // New
          onBack: () {
            setState(() {
              _currentView = AppView.dashboard;
              _filterPerson = '';
              _filterType = 'all';
              _filterCategory = 'all';
            });
          },
          onPersonClick: _handlePersonClick,
        );
    }
  }
}