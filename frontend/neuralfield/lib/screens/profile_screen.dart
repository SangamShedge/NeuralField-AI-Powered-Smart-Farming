// lib/screens/profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../l10n/app_localizations.dart';
import '../api/api_service.dart';
import '../api/api_response.dart';
import '../api/api_url.dart';
import '../widgets/app_header.dart';
import '../widgets/settings_menu.dart';
import '../services/cache_manager.dart';
import '../services/logout_service.dart';   // ✅ import logout service

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  final ImagePicker _imagePicker = ImagePicker();
  final CacheManager _cache = CacheManager();

  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isUploadingImage = false;
  ProfileDataWrapper? _profileWrapper;
  ProfileData? get _profile => _profileWrapper?.profile;

  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _stateController = TextEditingController();
  final _districtController = TextEditingController();
  final _talukaController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileNumberController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    _talukaController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _addressController.dispose();
    _profileService.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    try {
      if (_cache.cachedProfileWrapper != null) {
        _profileWrapper = _cache.cachedProfileWrapper;
        _updateControllers();
      }

      final response = await _profileService.getProfileDetail();
      if (!mounted) return;

      if (response.isSuccess && response.data != null) {
        setState(() {
          _profileWrapper = response.data;
          _cache.cachedProfileWrapper = response.data;
        });
        _updateControllers();
      }
    } catch (e) {
      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${localizations.errorPrefix} $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _updateControllers() {
    if (_profile != null) {
      _fullNameController.text = _profile!.fullName;
      _mobileNumberController.text = _profile!.mobileNumber;
      _stateController.text = _profile!.state;
      _districtController.text = _profile!.district;
      _talukaController.text = _profile!.taluka;
      _cityController.text = _profile!.city;
      _pincodeController.text = _profile!.pincode;
      _addressController.text = _profile!.address;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final response = await _profileService.updateProfile(
        fullName: _fullNameController.text.trim().isEmpty ? null : _fullNameController.text.trim(),
        mobileNumber: _mobileNumberController.text.trim().isEmpty ? null : _mobileNumberController.text.trim(),
        state: _stateController.text.trim().isEmpty ? null : _stateController.text.trim(),
        district: _districtController.text.trim().isEmpty ? null : _districtController.text.trim(),
        taluka: _talukaController.text.trim().isEmpty ? null : _talukaController.text.trim(),
        city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
        pincode: _pincodeController.text.trim().isEmpty ? null : _pincodeController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      );

      if (!mounted) return;

      if (response.isSuccess && response.data != null) {
        setState(() {
          _profileWrapper = response.data;
          _cache.cachedProfileWrapper = response.data;
          _isEditing = false;
        });
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.profileUpdated), backgroundColor: Colors.green),
        );
      } else {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.profileUpdateFailed), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      final localizations = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${localizations.errorPrefix} $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _changeProfilePicture() async {
    final localizations = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF4CAF50)),
              title: Text(localizations.chooseFromGallery),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF4CAF50)),
              title: Text(localizations.takePhoto),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() => _isUploadingImage = true);

        final response = await _profileService.updateProfilePicture(File(pickedFile.path));

        if (mounted) {
          setState(() => _isUploadingImage = false);

          if (response.isSuccess && response.data != null) {
            setState(() {
              _profileWrapper = response.data;
              _cache.cachedProfileWrapper = response.data;
            });
            final localizations = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(localizations.profilePictureUpdated), backgroundColor: Colors.green),
            );
          } else {
            final localizations = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(localizations.profilePictureUpdateFailed), backgroundColor: Colors.red),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingImage = false);
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${localizations.errorPrefix} $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showSettingsMenu() {
    SettingsMenu.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F3),
      appBar: AppHeader(
        onMenuPressed: _showSettingsMenu,
        showMenuButton: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)))
          : _profileWrapper == null
          ? _buildErrorView()
          : Stack(
        children: [
          Column(
            children: [
              _buildUserProfileSection(),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: _isEditing ? _buildEditForm() : _buildProfileInfo(),
                ),
              ),
            ],
          ),
          if (_isUploadingImage)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Color(0xFF4CAF50)),
                    const SizedBox(height: 16),
                    Text(
                      localizations.uploadingProfilePicture,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserProfileSection() {
    final localizations = AppLocalizations.of(context)!;
    return Container(
      color: const Color(0xFFF5F7F3),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Row(
          children: [
            GestureDetector(
              onTap: _isEditing ? _changeProfilePicture : null,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(child: _buildAvatar()),
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, size: 12, color: Colors.white),
                      ),
                    ),
                  if (!_isEditing)
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _getRoleColor(),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: _getRoleIcon(),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _profileWrapper!.username,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2C3E2B),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _profileWrapper!.email,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (_profile?.displayLocation != null && _profile!.displayLocation.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 12, color: Color(0xFF4CAF50)),
                        const SizedBox(width: 4),
                        Text(
                          _profile!.displayLocation,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    final localizations = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(localizations.failedToLoadProfile, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey.shade700)),
          const SizedBox(height: 8),
          Text(localizations.checkConnection, style: TextStyle(color: Colors.grey.shade500)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(localizations.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    final localizations = AppLocalizations.of(context)!;
    final notSet = localizations.notSet;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => setState(() => _isEditing = true),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: Text(localizations.editProfile),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildInfoTile(
                icon: Icons.person_outline,
                label: localizations.fullNameLabel,
                value: _profile?.fullName.isNotEmpty == true ? _profile!.fullName : notSet,
              ),
              _buildDivider(),
              _buildInfoTile(
                icon: Icons.phone_outlined,
                label: localizations.mobileNumberLabel,
                value: _profile?.mobileNumber.isNotEmpty == true ? _profile!.mobileNumber : notSet,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildInfoTile(
                icon: Icons.location_on_outlined,
                label: localizations.addressLabel,
                value: _profile?.address.isNotEmpty == true ? _profile!.address : notSet,
              ),
              _buildDivider(),
              _buildInfoTile(
                icon: Icons.location_city,
                label: localizations.cityLabel,
                value: _profile?.city.isNotEmpty == true ? _profile!.city : notSet,
              ),
              _buildDivider(),
              _buildInfoTile(
                icon: Icons.map_outlined,
                label: localizations.talukaLabel,
                value: _profile?.taluka.isNotEmpty == true ? _profile!.taluka : notSet,
              ),
              _buildDivider(),
              _buildInfoTile(
                icon: Icons.map_outlined,
                label: localizations.districtLabel,
                value: _profile?.district.isNotEmpty == true ? _profile!.district : notSet,
              ),
              _buildDivider(),
              _buildInfoTile(
                icon: Icons.map_outlined,
                label: localizations.stateLabel,
                value: _profile?.state.isNotEmpty == true ? _profile!.state : notSet,
              ),
              _buildDivider(),
              _buildInfoTile(
                icon: Icons.pin_drop_outlined,
                label: localizations.pincodeLabel,
                value: _profile?.pincode.isNotEmpty == true ? _profile!.pincode : notSet,
                showDivider: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => LogoutService.logout(context),   // ✅ changed to use LogoutService
            icon: const Icon(Icons.logout, size: 18),
            label: Text(localizations.logout),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildEditForm() {
    final localizations = AppLocalizations.of(context)!;
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildSectionCard(
            title: localizations.personalInformationTitle,
            icon: Icons.person_outline,
            children: [
              _buildTextField(
                controller: _fullNameController,
                label: localizations.fullNameLabel,
                icon: Icons.person_outline,
                validator: (v) => v == null || v.isEmpty ? localizations.enterFullName : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _mobileNumberController,
                label: localizations.mobileNumberLabel,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.isEmpty) return localizations.enterMobileNumber;
                  if (v.length < 10) return localizations.invalidMobileNumber;
                  return null;
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            title: localizations.addressDetailsTitle,
            icon: Icons.location_on_outlined,
            children: [
              _buildTextField(
                controller: _addressController,
                label: localizations.streetAddressLabel,
                icon: Icons.home_outlined,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _cityController,
                      label: localizations.cityLabel,
                      icon: Icons.location_city,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _pincodeController,
                      label: localizations.pincodeLabel,
                      icon: Icons.pin_drop_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _talukaController,
                      label: localizations.talukaLabel,
                      icon: Icons.map_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _districtController,
                      label: localizations.districtLabel,
                      icon: Icons.map_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _stateController,
                label: localizations.stateLabel,
                icon: Icons.map_outlined,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _updateControllers();
                    setState(() => _isEditing = false);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(localizations.cancel),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : Text(localizations.saveChanges),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: const Color(0xFF4CAF50)),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E2B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: const Color(0xFF4CAF50)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2C3E2B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider) _buildDivider(),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, color: Color(0xFF2C3E2B)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        prefixIcon: Icon(icon, size: 18, color: const Color(0xFF4CAF50)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 1.5),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: validator,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 20,
      endIndent: 20,
      color: Colors.grey.shade200,
    );
  }

  Widget _buildAvatar() {
    final profilePicPath = _profile?.profilePicture;

    if (profilePicPath != null && profilePicPath.isNotEmpty) {
      final imageUrl = Urls.getMediaUrl(profilePicPath);
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildAvatarPlaceholder(),
        errorWidget: (context, url, error) => _buildAvatarPlaceholder(),
      );
    }
    return _buildAvatarPlaceholder();
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      color: const Color(0xFFE8F5E9),
      child: Center(
        child: Text(
          _profileWrapper!.username.substring(0, 1).toUpperCase(),
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Color(0xFF4CAF50)),
        ),
      ),
    );
  }

  Color _getRoleColor() {
    switch (_profileWrapper?.role.toLowerCase()) {
      case 'admin':
        return const Color(0xFFF59E0B);
      case 'farmer':
        return const Color(0xFF4CAF50);
      case 'trader':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFF4CAF50);
    }
  }

  Widget _getRoleIcon() {
    switch (_profileWrapper?.role.toLowerCase()) {
      case 'admin':
        return const Icon(Icons.settings, size: 12, color: Colors.white);
      case 'farmer':
        return const Icon(Icons.grass, size: 12, color: Colors.white);
      case 'trader':
        return const Icon(Icons.trending_up, size: 12, color: Colors.white);
      default:
        return const Icon(Icons.person, size: 12, color: Colors.white);
    }
  }

  void _showAboutDialog() {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(localizations.aboutTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.agriculture, size: 48, color: Color(0xFF4CAF50)),
            const SizedBox(height: 16),
            Text(
              localizations.appName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              localizations.smartFarmingPlatform,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              '${localizations.version} 1.0.0',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.close),
          ),
        ],
      ),
    );
  }
}