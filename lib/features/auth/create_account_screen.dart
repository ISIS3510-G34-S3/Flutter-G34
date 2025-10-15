import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter/services.dart' as services;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import 'app_regex.dart';

/// Create account screen with user type selection and form fields
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedUserType = 'Traveler';
  bool _isLoading = false;
  bool _passwordFieldFocused = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Create Account',
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.oliveGold,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User type selection
                _buildUserTypeSelection(),

                const SizedBox(height: 32),

                // Full Name field
                _buildFullNameField(),

                const SizedBox(height: 16),

                // Email field
                _buildEmailField(),

                const SizedBox(height: 16),

                // Password field
                _buildPasswordField(),

                const SizedBox(height: 16),

                // Confirm Password field
                _buildConfirmPasswordField(),

                const SizedBox(height: 32),

                // Create Account button
                _buildCreateAccountButton(),

                const SizedBox(height: 24),

                // Or sign up with Google
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _handleGoogleSignUp,
                    icon: const Icon(Icons.login),
                    label: Text(
                      'Sign up with Google',
                      style: AppTypography.buttonMedium,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'I am a:',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildUserTypeCard(
                userType: 'Traveler',
                icon: Icons.person,
                isSelected: _selectedUserType == 'Traveler',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildUserTypeCard(
                userType: 'Host',
                icon: Icons.home,
                isSelected: _selectedUserType == 'Host',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserTypeCard({
    required String userType,
    required IconData icon,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedUserType = userType;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.oliveGold.withValues(alpha: 0.1)
              : AppColors.background,
          border: Border.all(
            color: isSelected ? AppColors.oliveGold : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.oliveGold
                    : AppColors.textSecondary.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              userType,
              style: AppTypography.bodyMedium.copyWith(
                color:
                    isSelected ? AppColors.oliveGold : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Full Name',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _fullNameController,
          inputFormatters: [
            // Allow only letters (unicode), spaces and apostrophe
            services.FilteringTextInputFormatter.allow(
              RegExp(r"[\p{L} ']+", unicode: true),
            ),
          ],
          decoration: InputDecoration(
            hintText: 'Enter your full name',
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.oliveGold),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.lava),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style:
              AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your full name';
            }
            if (value.trim().length < 2) {
              return 'Name must be at least 2 characters';
            }
            // Only letters (unicode), spaces, and apostrophe allowed
            final name = value.trim();
            final validName = AppRegex.nameRegex.hasMatch(name);
            if (!validName) {
              return "Only letters, spaces, and ' are allowed";
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          inputFormatters: [
            services.FilteringTextInputFormatter.allow(
              RegExp(r"[A-Za-z0-9@._-]"),
            ),
          ],
          decoration: InputDecoration(
            hintText: 'Enter your email',
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.oliveGold),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.lava),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style:
              AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your email';
            }
            final email = value.trim();
            // Allowed: letters, digits, @, ., _, -
            // Disallow: non-ASCII, spaces, other specials, consecutive dots, leading/trailing dots
            if (!AppRegex.emailRegex.hasMatch(email))
              return 'Please enter a valid email address';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: true,
          onChanged: (value) {
            // Trigger rebuild to update requirements indicator
            setState(() {});
          },
          onTap: () {
            setState(() {
              _passwordFieldFocused = true;
            });
          },
          decoration: InputDecoration(
            hintText: 'Create a password',
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.oliveGold),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.lava),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style:
              AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a password';
            }

            if (value.length < 8) {
              return 'Password must be at least 8 characters';
            }
            // Check if password matches the main password regex
            if (!AppRegex.passwordRegex.hasMatch(value)) {
              // Password is invalid, now check for specific issues

              // Check for spaces
              if (AppRegex.passwordHasSpace.hasMatch(value)) {
                return 'Password cannot contain spaces';
              }

              // Check for emojis
              if (AppRegex.passwordHasEmoji.hasMatch(value)) {
                return 'Password cannot contain emojis';
              }

              // Check for invalid characters
              if (AppRegex.passwordHasInvalidChar.hasMatch(value)) {
                return 'Password can only contain letters, digits, and @\$#!%?&_*';
              }
              
              // Check for missing requirements
              if (!AppRegex.passwordHasLowercase.hasMatch(value)) {
                return 'Password must contain at least one lowercase letter';
              }
              
              if (!AppRegex.passwordHasUppercase.hasMatch(value)) {
                return 'Password must contain at least one uppercase letter';
              }
              
              if (!AppRegex.passwordHasDigit.hasMatch(value)) {
                return 'Password must contain at least one digit';
              }
              
              // Generic fallback
              return 'Password does not meet requirements';
            }

            return null;
          },
        ),
        if (_passwordFieldFocused || _passwordController.text.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildPasswordRequirements(),
        ],
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confirm Password',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Confirm your password',
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.oliveGold),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.lava),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style:
              AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm your password';
            }
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordRequirements() {
    final password = _passwordController.text;
    final hasMinLength = password.length >= 8;
    final hasLowercase = AppRegex.passwordHasLowercase.hasMatch(password);
    final hasUppercase = AppRegex.passwordHasUppercase.hasMatch(password);
    final hasDigit = AppRegex.passwordHasDigit.hasMatch(password);
    final hasSpecialChar = AppRegex.passwordHasSpecialChar.hasMatch(password);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.oliveGold.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password must contain:',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _buildRequirementItem('At least 8 characters', hasMinLength),
          _buildRequirementItem('One lowercase letter (a-z)', hasLowercase),
          _buildRequirementItem('One uppercase letter (A-Z)', hasUppercase),
          _buildRequirementItem('One number (0-9)', hasDigit),
          _buildRequirementItem(
              'One special character (@\$#!%?&_)', hasSpecialChar),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: isMet ? AppColors.forestGreen : AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall.copyWith(
                color: isMet ? AppColors.forestGreen : AppColors.textSecondary,
                fontWeight: isMet ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateAccountButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleCreateAccount,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.oliveGold,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              )
            : Text(
                'Create Account',
                style: AppTypography.buttonMedium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  void _handleCreateAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      final name = _fullNameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // Create user with Firebase Auth
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = credential.user;
      if (user != null) {
        // Optionally update display name
        await user.updateDisplayName(name);

        // Create user doc in Firestore using email as ID
        await FirebaseFirestore.instance
            .collection('users')
            .doc(email.toLowerCase())
            .set({
          'uid': user.uid,
          'email': email,
          'displayName': name,
          'userType': _selectedUserType,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account created! Welcome, $name'),
            backgroundColor: AppColors.forestGreen,
          ),
        );
        context.go('/discover');
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final String message = e.code == 'email-already-in-use'
          ? 'Email already in use. If you signed up with Google, use Google Sign-In or reset your password.'
          : (e.message ?? 'Failed to create account');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.lava,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unexpected error creating account'),
          backgroundColor: AppColors.lava,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignUp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignIn googleSignIn = kIsWeb
          ? GoogleSignIn(
              clientId:
                  '994400477277-ropltmpc3ec8ovelbgac7feice2d5qct.apps.googleusercontent.com',
              scopes: <String>['email'],
            )
          : GoogleSignIn(
              serverClientId:
                  '994400477277-ropltmpc3ec8ovelbgac7feice2d5qct.apps.googleusercontent.com',
              scopes: <String>['email'],
            );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return; // cancelled
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCred =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCred.user;
      if (user != null) {
        final emailId = (user.email ?? '').toLowerCase();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(emailId.isNotEmpty ? emailId : user.uid)
            .set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'userType': _selectedUserType,
          'provider': 'google',
          'createdAt': FieldValue.serverTimestamp(),
          'lastSignInAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Signed in as ${user.displayName ?? user.email ?? 'Google user'}'),
            backgroundColor: AppColors.forestGreen,
          ),
        );
        context.go('/discover');
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '[FirebaseAuth:${e.code}] ${e.message ?? 'Google sign-in failed'}'),
          backgroundColor: AppColors.lava,
        ),
      );
    } on PlatformException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '[Platform:${e.code}] ${e.message ?? 'Platform error during Google sign-in'}'),
          backgroundColor: AppColors.lava,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unexpected error during Google sign-in: $e'),
          backgroundColor: AppColors.lava,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
