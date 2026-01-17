import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 16),
          _buildFAQItem(
            'How do I post a product?',
            'Go to the "My Products" tab and click "Add New". Fill in the details and upload a photo.',
          ),
          _buildFAQItem(
            'How do I contact a seller?',
            'Currently, you can place an order directly. Communication features are coming soon!',
          ),
          _buildFAQItem(
            'Are payments secure?',
            'All payments are handled through our secure partner gateways.',
          ),
          const SizedBox(height: 32),
          const Text(
            'Contact Us',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 16),
          const ListTile(
            leading: Icon(Icons.email_outlined, color: Colors.green),
            title: Text('Email Support'),
            subtitle: Text('support@farmlink.com'),
          ),
          const ListTile(
            leading: Icon(Icons.phone_outlined, color: Colors.green),
            title: Text('Call Us'),
            subtitle: Text('+1 (800) FARM-LINK'),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontWeight: FontWeight.bold)),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(answer),
        ),
      ],
    );
  }
}
