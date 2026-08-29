import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../models/child.dart';
import '../../providers/child_provider.dart';

/// Parent & Child Registration screen.
///
/// This screen uses a [StatefulWidget] to hold temporary form state.
/// It uses [TextEditingController]s for text fields, and manages
/// selected date and gender locally.
///
/// Once validated, it generates a temporary local child ID, creates
/// a [Child] object, saves it to the [ChildProvider], and navigates
/// to the Home screen.
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _childNameController = TextEditingController();
  final _parentNameController = TextEditingController();
  final _phoneController = TextEditingController();

  DateTime? _selectedDob;
  Gender? _selectedGender;

  @override
  void dispose() {
    _childNameController.dispose();
    _parentNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Create temporary local child ID
      // This is sufficient for the current offline/in-memory MVP
      // It will be replaced by a backend/database-generated identifier in future phases.
      final tempChildId = DateTime.now().millisecondsSinceEpoch.toString();

      final newChild = Child(
        id: tempChildId,
        name: _childNameController.text.trim(),
        dateOfBirth: _selectedDob!,
        gender: _selectedGender!,
        parentName: _parentNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        registeredAt: DateTime.now(),
        // vaccinationStatus uses default unknown from the model
      );

      // Save to provider (Single source of truth for active child)
      context.read<ChildProvider>().setChild(newChild);

      // Navigate to home
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  Future<void> _selectDate(BuildContext context, FormFieldState<DateTime> state) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? now,
      firstDate: DateTime(now.year - 10), // Reasonably far back
      lastDate: now, // Prevent future dates
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDob = pickedDate;
      });
      state.didChange(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.registrationTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppStrings.registrationTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.registrationSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 32),
                
                // --- Caregiver Details ---
                Text(
                  'Caregiver Details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _parentNameController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.labelCaregiverName,
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppStrings.valRequiredField;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.labelPhoneNumber,
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppStrings.valRequiredField;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // --- Child Details ---
                Text(
                  'Child Details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _childNameController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.labelChildName,
                    prefixIcon: Icon(Icons.child_care),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppStrings.valRequiredField;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                FormField<DateTime>(
                  validator: (value) {
                    if (_selectedDob == null) {
                      return AppStrings.valRequiredField;
                    }
                    if (_selectedDob!.isAfter(DateTime.now())) {
                      return AppStrings.valFutureDate;
                    }
                    return null;
                  },
                  builder: (FormFieldState<DateTime> state) {
                    return InkWell(
                      onTap: () => _selectDate(context, state),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: AppStrings.labelDateOfBirth,
                          prefixIcon: const Icon(Icons.calendar_today_outlined),
                          errorText: state.errorText,
                        ),
                        child: Text(
                          _selectedDob != null
                              ? '${_selectedDob!.day.toString().padLeft(2, '0')}/${_selectedDob!.month.toString().padLeft(2, '0')}/${_selectedDob!.year}'
                              : 'Select date',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: _selectedDob == null ? AppColors.textDisabled : AppColors.textPrimary,
                              ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<Gender>(
                  initialValue: _selectedGender,
                  decoration: const InputDecoration(
                    labelText: AppStrings.labelGender,
                    prefixIcon: Icon(Icons.people_outline),
                  ),
                  items: Gender.values.map((Gender gender) {
                    return DropdownMenuItem<Gender>(
                      value: gender,
                      child: Text(gender.label),
                    );
                  }).toList(),
                  onChanged: (Gender? newValue) {
                    setState(() {
                      _selectedGender = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return AppStrings.valRequiredField;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 48),

                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text(AppStrings.buttonSubmit),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
