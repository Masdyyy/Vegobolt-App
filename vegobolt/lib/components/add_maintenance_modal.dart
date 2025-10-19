import 'package:flutter/material.dart';
import '../utils/colors.dart';

class AddMaintenanceModal extends StatefulWidget {
  final Function(Map<String, dynamic>) onAdd;
  final Map<String, dynamic>? initialData;
  final bool isEdit;

  const AddMaintenanceModal({
    super.key,
    required this.onAdd,
    this.initialData,
    this.isEdit = false,
  });

  @override
  State<AddMaintenanceModal> createState() => _AddMaintenanceModalState();
}

class _AddMaintenanceModalState extends State<AddMaintenanceModal> {
  final _formKey = GlobalKey<FormState>();

  String? _maintenanceType;
  String? _machine = 'VB-0001';
  String? _priority;
  DateTime? _scheduledDate;

  final List<String> _maintenanceTypes = [
    'Tank Inspection',
    'Filter Replacement',
    'Battery Replacement',
    'General Inspection',
  ];

  final List<String> _machines = ['VB-0001'];
  final List<String> _priorities = ['High', 'Medium', 'Low'];

  @override
  void initState() {
    super.initState();
    // If editing, populate fields with initial data
    if (widget.isEdit && widget.initialData != null) {
      _maintenanceType = widget.initialData!['title'];
      _machine = widget.initialData!['machineId'];
      _priority = widget.initialData!['priority'];
      _scheduledDate = widget.initialData!['scheduledDate'];
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryGreen,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() => _scheduledDate = picked);
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Check if date is selected
      if (_scheduledDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a scheduled date'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      final priorityColor = switch (_priority) {
        'High' => Colors.red,
        'Low' => AppColors.darkGreen,
        _ => const Color(0xFFFFD700),
      };

      widget.onAdd({
        'title': _maintenanceType!,
        'machineId': _machine!,
        'location': 'Barangay 171',
        'priority': _priority ?? 'Medium',
        'priorityColor': priorityColor,
        'scheduledDate': _scheduledDate,
      });

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: 400,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildDropdownField(
                  label: 'Maintenance Type',
                  value: _maintenanceType,
                  hint: 'Select maintenance type',
                  items: _maintenanceTypes,
                  onChanged: (v) => setState(() => _maintenanceType = v),
                ),
                const SizedBox(height: 16),
                _buildDropdownField(
                  label: 'Machine',
                  value: _machine,
                  hint: 'Select machine',
                  items: _machines,
                  onChanged: (v) => setState(() => _machine = v),
                ),
                const SizedBox(height: 16),
                _buildDatePickerField(
                  label: 'Scheduled Date',
                  date: _scheduledDate,
                  onTap: _pickDate,
                ),
                const SizedBox(height: 16),
                _buildDropdownField(
                  label: 'Priority',
                  value: _priority,
                  hint: 'Select priority',
                  items: _priorities,
                  onChanged: (v) => setState(() => _priority = v),
                ),
                const SizedBox(height: 24),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      widget.isEdit ? 'Edit Maintenance' : 'Schedule New Maintenance',
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF333333),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Color(0xFF333333),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required String hint,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          onChanged: onChanged,
          validator: (v) => v == null ? 'Required' : null,
          decoration: _inputDecoration(hint),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF666666)),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e,
                    style: const TextStyle(color: Color(0xFF333333)),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildDatePickerField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildLabel(label),
            const Text(
              ' *',
              style: TextStyle(
                color: Colors.red,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null
                      ? '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}'
                      : 'mm/dd/yyyy',
                  style: TextStyle(
                    color: date != null
                        ? const Color(0xFF333333)
                        : const Color(0xFFAAAAAA),
                    fontSize: 14,
                  ),
                ),
                Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: Colors.grey[300]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF666666), fontSize: 15),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFF5A6B47), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }
}
