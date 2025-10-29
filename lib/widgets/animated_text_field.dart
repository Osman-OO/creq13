import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AnimatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?) validator;
  final Function(String)? onChanged;
  final bool obscureText;
  final Widget? suffixIcon;

  const AnimatedTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    this.onChanged,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  State<AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<AnimatedTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _shakeAnimation;
  late Animation<double> _bounceAnimation;
  bool _isValid = false;
  bool _hasInteracted = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticIn,
      ),
    );

    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.bounceOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _validateInput(String value) {
    final validationResult = widget.validator(value);
    setState(() {
      _hasInteracted = true;
      _isValid = validationResult == null && value.isNotEmpty;
    });

    if (_isValid) {
      HapticFeedback.lightImpact();
      _animationController.forward().then((_) => _animationController.reverse());
    } else if (_hasInteracted && value.isNotEmpty) {
      HapticFeedback.mediumImpact();
      _animationController.forward().then((_) => _animationController.reverse());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: _isValid
              ? Offset.zero
              : Offset(_shakeAnimation.value * (1 - _animationController.value), 0),
          child: Transform.scale(
            scale: _isValid ? _bounceAnimation.value : 1.0,
            child: TextFormField(
              controller: widget.controller,
              obscureText: widget.obscureText,
              onChanged: (value) {
                _validateInput(value);
                widget.onChanged?.call(value);
              },
              decoration: InputDecoration(
                labelText: widget.label,
                prefixIcon: Icon(widget.icon, color: Colors.deepPurple),
                suffixIcon: _hasInteracted
                    ? (_isValid
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : widget.suffixIcon)
                    : widget.suffixIcon,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _isValid ? Colors.green : Colors.grey,
                    width: _isValid ? 2 : 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _isValid ? Colors.green : Colors.grey.shade300,
                    width: _isValid ? 2 : 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _isValid ? Colors.green : Colors.deepPurple,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: _isValid ? Colors.green.shade50 : Colors.grey[50],
              ),
              validator: widget.validator,
            ),
          ),
        );
      },
    );
  }
}

