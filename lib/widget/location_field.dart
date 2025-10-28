import 'package:flutter/material.dart';

class LocationField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const LocationField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Text(value, maxLines: 2),
      ),
    );
  }
}
