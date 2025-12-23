import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/language_service.dart';
import '../l10n/app_localizations.dart';
import 'recommendation_screen.dart';

class ProfileInputScreen extends StatefulWidget {
  const ProfileInputScreen({Key? key}) : super(key: key);

  @override
  State<ProfileInputScreen> createState() => _ProfileInputScreenState();
}

class _ProfileInputScreenState extends State<ProfileInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  
  // Form values
  String? _selectedEducation;
  String? _selectedSector;
  String? _selectedLocation;
  List<String> _selectedSkills = [];
  
  bool _isLoading = false;

  // Education mapping
  final Map<String, String> _educationMapping = {
    '10th_pass': '10th Pass',
    '12th_pass': '12th Pass',
    'diploma': 'Diploma',
    'bachelors': "Bachelor's Degree",
    'masters': "Master's Degree",
  };

  // Sector mapping
  final Map<String, String> _sectorMapping = {
    'it_software': 'IT & Software',
    'manufacturing': 'Manufacturing',
    'marketing_sales': 'Marketing & Sales',
    'finance_banking': 'Finance & Banking',
    'healthcare': 'Healthcare',
    'education_sector': 'Education',
    'agriculture': 'Agriculture',
    'retail': 'Retail',
    'hospitality': 'Hospitality',
    'government': 'Government',
  };

  // Location mapping
  final Map<String, String> _locationMapping = {
    'delhi': 'Delhi',
    'mumbai': 'Mumbai',
    'bangalore': 'Bangalore',
    'hyderabad': 'Hyderabad',
    'chennai': 'Chennai',
    'kolkata': 'Kolkata',
    'pune': 'Pune',
    'goa': 'Goa',
    'madhya_pradesh': 'Madhya Pradesh',
    'remote': 'Remote',
  };

  // Skills mapping
  final Map<String, String> _skillsMapping = {
    'communication': 'Communication',
    'ms_office': 'MS Office',
    'english': 'English',
    'hindi': 'Hindi',
    'python': 'Python',
    'java': 'Java',
    'sales': 'Sales',
    'customer_service': 'Customer Service',
    'data_entry': 'Data Entry',
    'social_media': 'Social Media',
    'accounting': 'Accounting',
    'teaching': 'Teaching',
    'manual_work': 'Manual Work',
  };

  void _toggleSkill(String skill) {
    setState(() {
      if (_selectedSkills.contains(skill)) {
        _selectedSkills.remove(skill);
      } else {
        _selectedSkills.add(skill);
      }
    });
  }

  Future<void> _getRecommendations() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;

    if (_selectedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.selectAtLeastOneSkill),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final recommendations = await _apiService.getRecommendations(
        education: _selectedEducation!,
        skills: _selectedSkills,
        sector: _selectedSector!,
        location: _selectedLocation!,
      );

      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecommendationScreen(
            recommendations: recommendations,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showLanguageDialog() {
    final languageService = Provider.of<LanguageService>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.changeLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('English'),
              trailing: languageService.currentLocale.languageCode == 'en'
                  ? const Icon(Icons.check, color: Colors.orange)
                  : null,
              onTap: () {
                languageService.changeLanguage('en');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('हिंदी'),
              trailing: languageService.currentLocale.languageCode == 'hi'
                  ? const Icon(Icons.check, color: Colors.orange)
                  : null,
              onTap: () {
                languageService.changeLanguage('hi');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text('🇮🇳 ${l10n.appTitle}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: l10n.changeLanguage,
            onPressed: _showLanguageDialog,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.orange),
                  const SizedBox(height: 16),
                  Text(l10n.searchingRecommendations),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      l10n.fillDetails,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Education
                    _buildSectionTitle('${l10n.educationIcon} ${l10n.education}'),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: _selectedEducation,
                      items: _educationMapping,
                      hint: l10n.selectEducation,
                      icon: Icons.school,
                      onChanged: (value) {
                        setState(() {
                          _selectedEducation = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Sector
                    _buildSectionTitle('${l10n.sectorIcon} ${l10n.sector}'),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: _selectedSector,
                      items: _sectorMapping,
                      hint: l10n.selectSector,
                      icon: Icons.work,
                      onChanged: (value) {
                        setState(() {
                          _selectedSector = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Location
                    _buildSectionTitle('${l10n.locationIcon} ${l10n.location}'),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: _selectedLocation,
                      items: _locationMapping,
                      hint: l10n.selectLocation,
                      icon: Icons.location_on,
                      onChanged: (value) {
                        setState(() {
                          _selectedLocation = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Skills
                    _buildSectionTitle('${l10n.skillsIcon} ${l10n.skills} (${l10n.selectSkills})'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _skillsMapping.entries.map((entry) {
                        final skillValue = entry.value;
                        final isSelected = _selectedSkills.contains(skillValue);
                        return FilterChip(
                          label: Text(l10n.translate(entry.key)),
                          selected: isSelected,
                          onSelected: (_) => _toggleSkill(skillValue),
                          backgroundColor: Colors.white,
                          selectedColor: Colors.orange[100],
                          checkmarkColor: Colors.orange,
                          side: BorderSide(
                            color: isSelected ? Colors.orange : Colors.grey[300]!,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _getRecommendations,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        child: Text(
                          l10n.findInternships,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required Map<String, String> items,
    required String hint,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: Colors.orange),
        ),
        hint: Text(hint),
        items: items.entries.map((entry) {
          return DropdownMenuItem(
            value: entry.value,
            child: Text(l10n.translate(entry.key)),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) {
          if (value == null) {
            return l10n.pleaseSelectOption;
          }
          return null;
        },
      ),
    );
  }
}