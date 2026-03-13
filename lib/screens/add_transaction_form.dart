import 'package:flutter/material.dart';
import '../models/transaction.dart';

class AddTransactionForm extends StatefulWidget {
  final Function(TransactionType, Category, double, String, String, DateTime) onAddTransaction;
  final Function(Transaction)? onUpdateTransaction;
  final Transaction? initialTransaction;

  const AddTransactionForm({
    super.key, 
    required this.onAddTransaction,
    this.onUpdateTransaction,
    this.initialTransaction,
  });

  @override
  State<AddTransactionForm> createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends State<AddTransactionForm> {
  // 2. State Variables
  TransactionType _type = TransactionType.expense;
  Category _category = Category.personal;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _personController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.initialTransaction != null) {
      _type = widget.initialTransaction!.type;
      _category = widget.initialTransaction!.category;
      _amountController.text = widget.initialTransaction!.amount.toString();
      _descriptionController.text = widget.initialTransaction!.description;
      _personController.text = widget.initialTransaction!.person;
      _selectedDate = widget.initialTransaction!.date;
    }
  }

  // Premium Colors from your palette
  final Color cyanAccent = const Color(0xFF00FFFF);
  final Color blackBg = const Color(0xFF000000);
  final Color darkGrey = const Color(0xFF1A1A1A);

  void _handleSubmit() {
    final String amountStr = _amountController.text;
    final String description = _descriptionController.text;
    final String personInput = _personController.text;

    if (amountStr.isEmpty || description.isEmpty || (_type == TransactionType.expense && personInput.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    // For income, use description as the person name if requested
    String actualPerson = _type == TransactionType.income ? description : personInput;
    
    // Normalize Name: Trim and Capitalize First Letter of each word
    actualPerson = actualPerson.trim();
    if (actualPerson.isNotEmpty) {
      actualPerson = actualPerson.split(' ')
          .where((word) => word.isNotEmpty)
          .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
          .join(' ');
    }

    if (widget.initialTransaction != null && widget.onUpdateTransaction != null) {
      widget.onUpdateTransaction!(Transaction(
        id: widget.initialTransaction!.id,
        type: _type,
        category: _category,
        amount: double.parse(amountStr),
        description: description,
        person: actualPerson,
        date: _selectedDate,
      ));
    } else {
      widget.onAddTransaction(
        _type,
        _category,
        double.parse(amountStr),
        description,
        actualPerson,
        _selectedDate,
      );
    }

    // Reset Form
    _amountController.clear();
    _descriptionController.clear();
    _personController.clear();
    setState(() {
      _selectedDate = DateTime.now();
    });
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: cyanAccent,
              onPrimary: Colors.black,
              surface: darkGrey,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.dark(
                primary: cyanAccent,
                onPrimary: Colors.black,
                surface: darkGrey,
                onSurface: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isIncome = _type == TransactionType.income;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: blackBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.initialTransaction != null ? "Edit Transaction" : "Add Transaction",
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          const SizedBox(height: 24),

          // Type & Category Row
          Row(
            children: [
              Expanded(child: _buildLabel("TYPE")),
              if (!isIncome) ...[
                const SizedBox(width: 16),
                Expanded(child: _buildLabel("CATEGORY")),
              ],
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _buildDropdown<TransactionType>(
                  value: _type,
                  items: TransactionType.values,
                  onChanged: (val) => setState(() => _type = val!),
                ),
              ),
              if (!isIncome) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdown<Category>(
                    value: _category,
                    items: Category.values,
                    onChanged: (val) => setState(() => _category = val!),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),

          // Amount & Person Row
          Row(
            children: [
              Expanded(child: _buildLabel("AMOUNT")),
              if (!isIncome) ...[
                const SizedBox(width: 16),
                Expanded(child: _buildLabel("PERSON")),
              ],
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _buildTextField(_amountController, "0.00", isNumber: true),
              ),
              if (!isIncome) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(_personController, "Enter name"),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),

          // Description
          _buildLabel("DESCRIPTION"),
          _buildTextField(_descriptionController, "Enter description"),
          const SizedBox(height: 20),

          // Date & Time Picker
          _buildLabel("DATE & TIME"),
          InkWell(
            onTap: _selectDateTime,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} ${_selectedDate.hour.toString().padLeft(2, '0')}:${_selectedDate.minute.toString().padLeft(2, '0')}",
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  Icon(Icons.calendar_today, color: cyanAccent, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: _handleSubmit,
              icon: Icon(
                widget.initialTransaction != null ? Icons.save_outlined : Icons.add_circle_outline, 
                color: Colors.white
              ),
              label: Text(
                widget.initialTransaction != null ? "Save Changes" : "Add Transaction", 
                style: const TextStyle(color: Colors.white, fontSize: 16)
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: cyanAccent.withOpacity(0.8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI Helper Widgets ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10, letterSpacing: 1.5)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: cyanAccent),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>(
      {required T value, required List<T> items, required ValueChanged<T?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          dropdownColor: blackBg,
          iconEnabledColor: cyanAccent,
          isExpanded: true,
          items: items.map((T val) {
            return DropdownMenuItem<T>(
              value: val,
              child: Text(
                val.toString().split('.').last.toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}