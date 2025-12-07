import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models/category_model.dart';
import '../../data/models/transaction_input.dart';
import '../../state/auth_notifier.dart';
import 'login_screen.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  static const routeName = '/transaction/new';

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _transactionType = 'income';
  bool _isSubmitting = false;

  List<CategoryModel> _categories = const [];
  CategoryModel? _selectedCategory;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCategories());
  }

  Future<void> _loadCategories() async {
    final auth = context.read<AuthNotifier>();
    final session = auth.session;
    if (session == null) {
      if (mounted) Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
      return;
    }
    try {
      final categories = await auth.api.fetchCategories(token: session.token, accountId: session.accountId);
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _loading = false;
        final filtered = _filteredCategories;
        if (filtered.isNotEmpty) {
          _selectedCategory = filtered.first;
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  List<CategoryModel> get _filteredCategories =>
      _categories.where((c) => c.type == _transactionType).toList(growable: false);

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthNotifier>();
    final session = auth.session;
    if (session == null) return;

    setState(() => _isSubmitting = true);
    try {
      final input = TransactionInput(
        categoryId: _selectedCategory!.id,
        amount: double.parse(_amountController.text.replaceAll(',', '.')),
        transactionType: _transactionType,
        transactionDate: _selectedDate,
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      );
      await auth.api.createTransaction(token: session.token, accountId: session.accountId, input: input);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaksi tersimpan')));
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString().replaceAll('Exception: ', ''))));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _pickDate() async {
    final result = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _selectedDate,
    );
    if (result != null) {
      setState(() => _selectedDate = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Catat transaksi')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Jenis transaksi', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          children: [
                            ChoiceChip(
                              label: const Text('Pemasukan'),
                              selected: _transactionType == 'income',
                              onSelected: (value) {
                                if (value) {
                                  setState(() {
                                    _transactionType = 'income';
                                    final filtered = _filteredCategories;
                                    _selectedCategory = filtered.isNotEmpty ? filtered.first : null;
                                  });
                                }
                              },
                            ),
                            ChoiceChip(
                              label: const Text('Pengeluaran'),
                              selected: _transactionType == 'expense',
                              onSelected: (value) {
                                if (value) {
                                  setState(() {
                                    _transactionType = 'expense';
                                    final filtered = _filteredCategories;
                                    _selectedCategory = filtered.isNotEmpty ? filtered.first : null;
                                  });
                                }
                              },
                            )
                          ],
                        ),
                        const SizedBox(height: 24),
                        DropdownButtonFormField<CategoryModel>(
                          initialValue: _selectedCategory,
                          items: _filteredCategories
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) => setState(() => _selectedCategory = value),
                          decoration: const InputDecoration(labelText: 'Kategori'),
                          validator: (value) => value == null ? 'Pilih kategori' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Nominal (Rp)'),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Nominal wajib diisi';
                            final parsed = double.tryParse(value.replaceAll(',', '.'));
                            if (parsed == null || parsed <= 0) return 'Nominal tidak valid';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: _pickDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Tanggal transaksi',
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(DateFormat('d MMM yyyy').format(_selectedDate)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 3,
                          decoration: const InputDecoration(labelText: 'Catatan (opsional)'),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submit,
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Simpan transaksi'),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
    );
  }
}
