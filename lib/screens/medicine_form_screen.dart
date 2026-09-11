import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/medicine.dart';
import '../services/storage_service.dart';
import 'qr_display_screen.dart';

class MedicineFormScreen extends StatefulWidget {
  const MedicineFormScreen({super.key});

  @override
  State<MedicineFormScreen> createState() => _MedicineFormScreenState();
}

class _MedicineFormScreenState extends State<MedicineFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _genericNameCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  final _manufacturerCtrl = TextEditingController();
  final _batchNoCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  DateTime? _mfgDate;
  DateTime? _expDate;

  final _dateFmt = DateFormat('dd MMM yyyy');

  @override
  void dispose() {
    _nameCtrl.dispose();
    _genericNameCtrl.dispose();
    _dosageCtrl.dispose();
    _manufacturerCtrl.dispose();
    _batchNoCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isMfg}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isMfg ? now : now.add(const Duration(days: 365)),
      firstDate: DateTime(2000),
      lastDate: DateTime(2040),
    );
    if (picked != null) {
      setState(() {
        if (isMfg) {
          _mfgDate = picked;
        } else {
          _expDate = picked;
        }
      });
    }
  }

  Future<void> _onGenerate() async {
    if (!_formKey.currentState!.validate()) return;

    if (_mfgDate == null || _expDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both Manufacturing and Expiry dates.'),
        ),
      );
      return;
    }

    if (_expDate!.isBefore(_mfgDate!) || _expDate!.isAtSameMomentAs(_mfgDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expiry date must be after Manufacturing date.'),
        ),
      );
      return;
    }

    final medicine = Medicine(
      name: _nameCtrl.text.trim(),
      genericName: _genericNameCtrl.text.trim(),
      dosage: _dosageCtrl.text.trim(),
      manufacturer: _manufacturerCtrl.text.trim(),
      batchNo: _batchNoCtrl.text.trim(),
      mfgDate: _mfgDate!,
      expDate: _expDate!,
      description: _descriptionCtrl.text.trim(),
    );

    // Save to local storage for history (awaited)
    await StorageService.saveMedicine(medicine);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QrDisplayScreen(medicine: medicine),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Medicine Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildField(
                controller: _nameCtrl,
                label: 'Medicine Name',
                hint: 'e.g. Paracetamol',
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _genericNameCtrl,
                label: 'Generic Name',
                hint: 'e.g. Acetaminophen',
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _dosageCtrl,
                label: 'Dosage',
                hint: 'e.g. 500 mg',
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _manufacturerCtrl,
                label: 'Manufacturer',
                hint: 'e.g. Cipla Ltd',
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _batchNoCtrl,
                label: 'Batch Number',
                hint: 'e.g. B20260815',
              ),
              const SizedBox(height: 14),

              // Date pickers
              Row(
                children: [
                  Expanded(
                    child: _buildDateTile(
                      label: 'Mfg. Date',
                      date: _mfgDate,
                      onTap: () => _pickDate(isMfg: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDateTile(
                      label: 'Exp. Date',
                      date: _expDate,
                      onTap: () => _pickDate(isMfg: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Description
              TextFormField(
                controller: _descriptionCtrl,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'e.g. Used for fever & pain relief',
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 28),

              ElevatedButton(
                onPressed: _onGenerate,
                child: const Text('Generate QR Code'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
    );
  }

  Widget _buildDateTile({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFDDDDDD)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 16, color: Color(0xFF1565C0)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date != null ? _dateFmt.format(date) : 'Select',
                    style: TextStyle(
                      fontSize: 14,
                      color: date != null
                          ? const Color(0xFF111111)
                          : const Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
