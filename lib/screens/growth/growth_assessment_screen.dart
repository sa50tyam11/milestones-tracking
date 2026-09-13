import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/enums.dart';
import '../../models/growth_assessment.dart';
import '../../providers/child_provider.dart';
import '../../services/growth_assessment_service.dart';
import '../../services/local_storage_service.dart';

class GrowthAssessmentScreen extends StatefulWidget {
  const GrowthAssessmentScreen({super.key});

  @override
  State<GrowthAssessmentScreen> createState() => _GrowthAssessmentScreenState();
}

class _GrowthAssessmentScreenState extends State<GrowthAssessmentScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _weightController = TextEditingController();
  final _lengthOrHeightController = TextEditingController();
  final _headCircController = TextEditingController();
  
  MeasurementType? _measurementType;

  @override
  void dispose() {
    _weightController.dispose();
    _lengthOrHeightController.dispose();
    _headCircController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final childProvider = context.read<ChildProvider>();
    final activeChild = childProvider.currentChild;
    
    if (activeChild == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active child selected.')),
      );
      return;
    }

    final double? weightKg = double.tryParse(_weightController.text);
    final double? lengthOrHeightCm = double.tryParse(_lengthOrHeightController.text);
    final double? headCircCm = double.tryParse(_headCircController.text);

    if (lengthOrHeightCm != null && _measurementType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select whether you measured Length or Height.')),
      );
      return;
    }

    if (weightKg == null && lengthOrHeightCm == null && headCircCm == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least one measurement.')),
      );
      return;
    }

    final assessment = GrowthAssessment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      childId: activeChild.id,
      dateOfBirth: activeChild.dateOfBirth,
      measuredAt: DateTime.now(),
      gender: activeChild.gender,
      weightKg: weightKg,
      lengthOrHeightCm: lengthOrHeightCm,
      measurementType: _measurementType,
      headCircumferenceCm: headCircCm,
    );

    if (!assessment.isValidTechnical) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('One or more measurements are out of valid technical range.')),
      );
      return;
    }

    // Process and Save
    try {
      final storage = context.read<LocalStorageService>();
      final service = GrowthAssessmentService();
      
      // Save raw data
      await storage.saveGrowthAssessment(assessment);
      
      // Generate ModuleResult (will be pending due to WHO data stub)
      final result = service.assess(assessment);
      
      // Save for dashboard integration
      await storage.saveModuleResult(result);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Growth assessment saved successfully (clinical calculation pending).')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving assessment: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Growth Monitoring')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Enter anthropometric measurements. Technical sanity checks apply. '
                  'Clinical calculations will be pending WHO data integration.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 24),
                
                TextFormField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Weight (kg)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return null; // Optional
                    final d = double.tryParse(val);
                    if (d == null) return 'Must be a number';
                    if (d <= 0 || d >= 100) return 'Must be between 0 and 100 kg';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _lengthOrHeightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Length / Height (cm)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return null; // Optional
                    final d = double.tryParse(val);
                    if (d == null) return 'Must be a number';
                    if (d <= 0 || d >= 250) return 'Must be between 0 and 250 cm';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                
                DropdownButtonFormField<MeasurementType>(
                  initialValue: _measurementType,
                  decoration: const InputDecoration(
                    labelText: 'Measurement Type',
                    border: OutlineInputBorder(),
                  ),
                  items: MeasurementType.values.map((t) {
                    return DropdownMenuItem(
                      value: t,
                      child: Text(t.label),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _measurementType = val;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _headCircController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Head Circumference (cm)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return null; // Optional
                    final d = double.tryParse(val);
                    if (d == null) return 'Must be a number';
                    if (d <= 0 || d >= 100) return 'Must be between 0 and 100 cm';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Save Assessment'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
