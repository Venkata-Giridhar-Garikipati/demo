import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
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
  bool _isParsingResume = false;

  // Education mapping - EXTENDED
  final Map<String, String> _educationMapping = {
    '10th_pass': '10th Pass',
    '12th_pass': '12th Pass',
    'diploma': 'Diploma',
    'bachelors': "Bachelor's Degree",
    'masters': "Master's Degree",
  };

  // Sector mapping - EXTENDED (21 sectors)
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
    'media_entertainment': 'Media & Entertainment',
    'food_beverage': 'Food & Beverage',
    'logistics': 'Logistics & Supply Chain',
    'renewable_energy': 'Renewable Energy',
    'ecommerce': 'E-commerce',
    'textiles': 'Textiles & Apparel',
    'tourism': 'Tourism & Travel',
    'construction': 'Construction & Infrastructure',
    'social_work': 'Social Work & NGO',
    'automobile': 'Automobile & Automotive',
    'legal': 'Legal Services',
  };

  // Location mapping - EXTENDED (13 locations)
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
    'bihar': 'Bihar',
    'gujarat': 'Gujarat',
    'rajasthan': 'Rajasthan',
    'remote': 'Remote',
  };

  // Skills mapping - EXTENDED (27+ skills)
  final Map<String, String> _skillsMapping = {
    'communication': 'Communication',
    'ms_office': 'MS Office',
    'english': 'English',
    'hindi': 'Hindi',
    'tamil': 'Tamil',
    'telugu': 'Telugu',
    'bengali': 'Bengali',
    'marathi': 'Marathi',
    'python': 'Python',
    'java': 'Java',
    'sales': 'Sales',
    'customer_service': 'Customer Service',
    'data_entry': 'Data Entry',
    'social_media': 'Social Media',
    'accounting': 'Accounting',
    'teaching': 'Teaching',
    'manual_work': 'Manual Work',
    'networking': 'Networking',
    'problem_solving': 'Problem Solving',
    'writing': 'Writing',
    'research': 'Research',
    'photoshop': 'Photoshop',
    'creativity': 'Creativity',
    'video_editing': 'Video Editing',
    'autocad': 'AutoCAD',
    'engineering': 'Engineering',
    'data_analysis': 'Data Analysis',
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

  // NEW: Resume upload functionality
  Future<void> _uploadResume() async {
    final l10n = AppLocalizations.of(context)!;

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'txt'],
        withData: true, // Important for web - loads file bytes
      );

      if (result != null) {
        setState(() {
          _isParsingResume = true;
        });

        // Get file bytes (works on both web and mobile)
        final fileBytes = result.files.single.bytes;
        final fileName = result.files.single.name;
        
        if (fileBytes == null) {
          throw Exception('Could not read file data');
        }
        
        // Call API to parse resume
        final parsedData = await _apiService.uploadResume(fileBytes, fileName);

        setState(() {
          _isParsingResume = false;
        });

        if (parsedData['success'] == true) {
          final data = parsedData['data'];
          
          // Auto-fill form with extracted data
          setState(() {
            // Set education if detected
            if (data['education'] != null) {
              _selectedEducation = data['education'];
            }
            
            // Set skills if detected
            if (data['skills'] != null && data['skills'].isNotEmpty) {
              _selectedSkills = List<String>.from(data['skills']);
            }
          });

          // Show success message
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${l10n.resumeParsed} ${data['skills']?.length ?? 0} ${l10n.skillsFound}'
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isParsingResume = false;
      });

      if (!mounted) return;
      
      // Extract the actual error message
      String errorMessage = e.toString();
      // Remove "Exception: " prefix if present
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange[700]!, Colors.orange[500]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            const Text('🇮🇳', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.appTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.language, color: Colors.white),
              tooltip: l10n.changeLanguage,
              onPressed: _showLanguageDialog,
            ),
          ),
        ],
      ),
      body: _isLoading || _isParsingResume
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const CircularProgressIndicator(
                      color: Colors.orange,
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _isParsingResume 
                        ? l10n.parsingResume
                        : l10n.searchingRecommendations,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            )
          : Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 900),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    // Welcome Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange[100]!, Colors.orange[50]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.orange[200]!, width: 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.work_outline,
                              color: Colors.orange,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.fillDetails,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Find your perfect internship match',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Resume Upload Section
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange[50]!, Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        border: Border.all(color: Colors.orange[100]!, width: 2),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.2),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.cloud_upload_outlined,
                              size: 48,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.uploadResumeOptional,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Auto-fill your details instantly',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _uploadResume,
                            icon: const Icon(Icons.upload_file, size: 20),
                            label: Text(
                              l10n.uploadResume,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                              shadowColor: Colors.orange.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, size: 16, color: Colors.green[600]),
                              const SizedBox(width: 6),
                              Text(
                                'PDF',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(Icons.check_circle, size: 16, color: Colors.green[600]),
                              const SizedBox(width: 6),
                              Text(
                                'DOCX',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(Icons.check_circle, size: 16, color: Colors.green[600]),
                              const SizedBox(width: 6),
                              Text(
                                'TXT',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // OR Divider
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.transparent, Colors.grey[300]!],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Text(
                            l10n.or,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.grey[300]!, Colors.transparent],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Responsive Grid Layout for Form Fields
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Use grid layout for web (width > 600px), single column for mobile
                        final isWeb = constraints.maxWidth > 600;
                        
                        if (isWeb) {
                          // Web/Desktop: 2-column grid
                          return Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left Column - Education
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
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
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  // Right Column - Sector
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
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
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // Location (full width)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                                ],
                              ),
                            ],
                          );
                        } else {
                          // Mobile: Single column
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                            ],
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    // Skills
                    _buildSectionTitle('${l10n.skillsIcon} ${l10n.skills} (${l10n.selectSkills})'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _skillsMapping.entries.map((entry) {
                          final skillValue = entry.value;
                          final isSelected = _selectedSkills.contains(skillValue);
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            child: FilterChip(
                              label: Text(
                                l10n.translate(entry.key),
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (_) => _toggleSkill(skillValue),
                              backgroundColor: Colors.grey[50],
                              selectedColor: Colors.orange[100],
                              checkmarkColor: Colors.orange[700],
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              side: BorderSide(
                                color: isSelected ? Colors.orange[600]! : Colors.grey[300]!,
                                width: isSelected ? 2 : 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: isSelected ? 2 : 0,
                              shadowColor: Colors.orange.withOpacity(0.3),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange[600]!, Colors.orange[500]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _getRecommendations,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              l10n.findInternships,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          letterSpacing: 0.3,
        ),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.orange[700], size: 20),
          ),
        ),
        hint: Text(
          hint,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 15,
          ),
        ),
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        dropdownColor: Colors.white,
        icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
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