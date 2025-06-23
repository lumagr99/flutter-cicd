import 'package:flutter/material.dart';

/// Widget for displaying a weather metric with icon and label
class WeatherBlock extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const WeatherBlock({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 40, color: Colors.blueGrey),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
