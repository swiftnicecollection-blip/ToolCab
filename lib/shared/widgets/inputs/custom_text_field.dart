import 'package:flutter/material.dart';

/// Custom text field with premium styling and validation support.
class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.icon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.autofocus = false,
    this.readOnly = false,
    this.textCapitalization = TextCapitalization.none,
  });

  /// Text editing controller.
  final TextEditingController controller;

  /// Label text.
  final String? label;

  /// Hint text.
  final String? hint;

  /// Leading icon.
  final IconData? icon;

  /// Trailing icon.
  final Widget? suffixIcon;

  /// Whether the text is obscured (password).
  final bool obscureText;

  /// Keyboard type.
  final TextInputType? keyboardType;

  /// Text input action.
  final TextInputAction? textInputAction;

  /// Validation callback.
  final String? Function(String?)? validator;

  /// Change callback.
  final ValueChanged<String>? onChanged;

  /// Submit callback.
  final ValueChanged<String>? onSubmitted;

  /// Maximum lines.
  final int maxLines;

  /// Maximum length.
  final int? maxLength;

  /// Whether the field is enabled.
  final bool enabled;

  /// Whether to autofocus.
  final bool autofocus;

  /// Whether the field is read-only.
  final bool readOnly;

  /// Text capitalization.
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: enabled,
      autofocus: autofocus,
      readOnly: readOnly,
      textCapitalization: textCapitalization,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        suffixIcon: suffixIcon,
        counterText: maxLength != null ? '' : null,
      ),
    );
  }
}
