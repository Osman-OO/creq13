import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'success_screen.dart';
import '../widgets/animated_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _selectedAvatar;
  double _progress = 0.0;
  String _progressMessage = '';
  int _passwordStrength = 0;
  int _currentFieldIndex = 0;

  final List<String> _avatars = ['😀', '🚀', '🎮', '🎨', '⚡'];
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _dobController.dispose();
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _updateProgress() {
    int filledFields = 0;
    if (_nameController.text.isNotEmpty) filledFields++;
    if (_emailController.text.isNotEmpty) filledFields++;
    if (_passwordController.text.isNotEmpty) filledFields++;
    if (_dobController.text.isNotEmpty) filledFields++;
    if (_selectedAvatar != null) filledFields++;

    double newProgress = filledFields / 5;
    setState(() {
      _progress = newProgress;
      if (_progress >= 1.0) {
        _progressMessage = 'Ready for adventure! 🎉';
      } else if (_progress >= 0.75) {
        _progressMessage = 'Almost done! 💪';
      } else if (_progress >= 0.5) {
        _progressMessage = 'Halfway there! 🔥';
      } else if (_progress >= 0.25) {
        _progressMessage = 'Great start! ⭐';
      } else {
        _progressMessage = '';
      }
    });
  }

  void _calculatePasswordStrength(String password) {
    int strength = 0;
    if (password.length >= 6) strength++;
    if (password.length >= 10) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    setState(() {
      _passwordStrength = strength;
    });
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
        _updateProgress();
      });
    }
  }

  List<String> _getAchievements() {
    List<String> badges = [];
    if (_passwordStrength >= 4) badges.add('Strong Password Master');
    if (_progress >= 1.0) badges.add('Profile Completer');
    if (DateTime.now().hour < 12) badges.add('The Early Bird Special');
    return badges;
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedAvatar == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pick your adventure avatar!')),
        );
        return;
      }
      setState(() {
        _isLoading = true;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessScreen(
              userName: _nameController.text,
              avatar: _selectedAvatar!,
              achievements: _getAchievements(),
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Your Account ✅'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.tips_and_updates,
                        color: Colors.deepPurple[800],
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Complete your adventure profile!',
                          style: TextStyle(
                            color: Colors.deepPurple[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _progress >= 0.75
                        ? Colors.green
                        : _progress >= 0.5
                        ? Colors.orange
                        : Colors.deepPurple,
                  ),
                  minHeight: 8,
                ),
                const SizedBox(height: 8),
                if (_progressMessage.isNotEmpty)
                  Text(
                    _progressMessage,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                const SizedBox(height: 20),
                const Text(
                  'Choose Your Avatar',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _avatars.map((avatar) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAvatar = avatar;
                          _updateProgress();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _selectedAvatar == avatar
                              ? Colors.deepPurple
                              : Colors.grey[200],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedAvatar == avatar
                                ? Colors.deepPurple
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: Text(
                          avatar,
                          style: const TextStyle(fontSize: 30),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 30),
                AnimatedTextField(
                  controller: _nameController,
                  label: 'Adventure Name',
                  icon: Icons.person,
                  onChanged: (value) {
                    _updateProgress();
                    if (value.isNotEmpty && _nameController.text.length >= 2) {
                      _focusNodes[1].requestFocus();
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'What should we call you on this adventure?';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                AnimatedTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  icon: Icons.email,
                  onChanged: (value) {
                    _updateProgress();
                    if (value.contains('@') && value.contains('.')) {
                      _focusNodes[2].requestFocus();
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'We need your email for adventure updates!';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Oops! That doesn\'t look like a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _dobController,
                  readOnly: true,
                  onTap: _selectDate,
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    prefixIcon: const Icon(
                      Icons.calendar_today,
                      color: Colors.deepPurple,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.date_range),
                      onPressed: _selectDate,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'When did your adventure begin?';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      onChanged: (value) {
                        _calculatePasswordStrength(value);
                        _updateProgress();
                      },
                      decoration: InputDecoration(
                        labelText: 'Secret Password',
                        prefixIcon: const Icon(
                          Icons.lock,
                          color: Colors.deepPurple,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.deepPurple,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Every adventurer needs a secret password!';
                        }
                        if (value.length < 6) {
                          return 'Make it stronger! At least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text('Strength: '),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: _passwordStrength / 5,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _passwordStrength >= 4
                                  ? Colors.green
                                  : _passwordStrength >= 2
                                  ? Colors.orange
                                  : Colors.red,
                            ),
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _passwordStrength >= 4
                              ? 'Strong'
                              : _passwordStrength >= 2
                              ? 'Medium'
                              : 'Weak',
                          style: TextStyle(
                            color: _passwordStrength >= 4
                                ? Colors.green
                                : _passwordStrength >= 2
                                ? Colors.orange
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _isLoading ? 60 : double.infinity,
                  height: 60,
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.deepPurple,
                            ),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 5,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Start My Adventure',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 10),
                              Icon(Icons.rocket_launch, color: Colors.white),
                            ],
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
}
