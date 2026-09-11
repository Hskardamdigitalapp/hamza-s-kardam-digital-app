import 'package:flutter/material.dart';
import '../services/wallet_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>?> _profileFuture;
  late Future<bool> _adminFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = WalletService.getProfile();
    _adminFuture = WalletService.isAdmin();
  }

  Future<void> _logout() async {
    await WalletService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = WalletService.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile'), backgroundColor: Colors.green, foregroundColor: Colors.white),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _profileFuture,
        builder: (context, snapshot) {
          final profile = snapshot.data ?? {};
          final name = profile['full_name']?.toString().trim();
          final phone = profile['phone']?.toString().trim();
          final email = profile['email']?.toString().trim() ?? user?.email ?? '';
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const CircleAvatar(radius: 42, child: Icon(Icons.person, size: 46)),
              const SizedBox(height: 16),
              Center(child: Text(name?.isNotEmpty == true ? name! : 'Customer', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
              const SizedBox(height: 24),
              Card(child: Column(children: [
                ListTile(leading: const Icon(Icons.person_outline), title: const Text('Full name'), subtitle: Text(name?.isNotEmpty == true ? name! : 'Not available')),
                ListTile(leading: const Icon(Icons.phone_outlined), title: const Text('Phone'), subtitle: Text(phone?.isNotEmpty == true ? phone! : 'Not available')),
                ListTile(leading: const Icon(Icons.email_outlined), title: const Text('Email'), subtitle: Text(email.isNotEmpty ? email : 'Not available')),
              ])),
              const SizedBox(height: 16),
              Card(child: Column(children: [
                ListTile(leading: const Icon(Icons.account_balance_wallet_outlined), title: const Text('Wallet'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.pushNamed(context, '/wallet')),
                ListTile(leading: const Icon(Icons.receipt_long_outlined), title: const Text('Transactions'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.pushNamed(context, '/transactions')),
              ])),
              FutureBuilder<bool>(
                future: _adminFuture,
                builder: (context, adminSnapshot) {
                  if (adminSnapshot.data != true) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Card(
                      child: ListTile(
                        leading: const Icon(Icons.admin_panel_settings_outlined, color: Colors.green),
                        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Manage users, wallets and service activity'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.pushNamed(context, '/admin'),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(onPressed: _logout, icon: const Icon(Icons.logout), label: const Text('Logout')),
            ],
          );
        },
      ),
    );
  }
}
