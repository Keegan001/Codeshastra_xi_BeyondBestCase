import 'dart:math';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyNumber {
  final String country;
  final String number;
  final String description;

  EmergencyNumber({
    required this.country,
    required this.number,
    required this.description,
  });
}

class SOSButton extends StatelessWidget {
  final double size;
  final Color color;

  const SOSButton({
    super.key,
    this.size = 56.0,
    this.color = Colors.red,
  });

  // List of emergency numbers from different countries
  static final List<EmergencyNumber> _emergencyNumbers = [
    EmergencyNumber(
      country: "USA",
      number: "911",
      description: "Emergency Services",
    ),
    EmergencyNumber(
      country: "UK",
      number: "999",
      description: "Emergency Services",
    ),
    EmergencyNumber(
      country: "EU",
      number: "112",
      description: "European Emergency Number",
    ),
    EmergencyNumber(
      country: "Australia",
      number: "000",
      description: "Triple Zero",
    ),
    EmergencyNumber(
      country: "India",
      number: "112",
      description: "Emergency Services",
    ),
    EmergencyNumber(
      country: "China",
      number: "110",
      description: "Police",
    ),
    EmergencyNumber(
      country: "Japan",
      number: "110",
      description: "Police",
    ),
    EmergencyNumber(
      country: "Canada",
      number: "911",
      description: "Emergency Services",
    ),
  ];

  Future<void> _showEmergencyDialog(BuildContext context) async {
    final random = Random();
    final randomNumbers = List<EmergencyNumber>.from(_emergencyNumbers)
      ..shuffle(random);
    final selectedNumbers = randomNumbers.take(4).toList();

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24),
              SizedBox(width: 8),
              Text('Emergency SOS'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select an emergency number to call:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                ...selectedNumbers.map((emergencyNumber) => 
                  _buildEmergencyNumberTile(context, emergencyNumber)
                ),
                SizedBox(height: 12),
                Text(
                  'Note: Emergency numbers may vary by location. If you\'re traveling, try to learn the local emergency number.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmergencyNumberTile(BuildContext context, EmergencyNumber emergencyNumber) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(Icons.phone, color: Colors.red),
          ),
        ),
        title: Text(
          '${emergencyNumber.country} - ${emergencyNumber.number}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(emergencyNumber.description),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.of(context).pop();
          _callEmergencyNumber(emergencyNumber.number);
        },
      ),
    );
  }

  Future<void> _callEmergencyNumber(String number) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showEmergencyDialog(context),
        customBorder: const CircleBorder(),
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 2,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.sos,
                  color: Colors.white,
                  size: size * 0.4,
                ),
                Text(
                  'SOS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size * 0.2,
                    fontWeight: FontWeight.bold,
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