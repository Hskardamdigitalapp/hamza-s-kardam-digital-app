import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/wallet_service.dart';

const _navy = Color(0xFF061B49);
const _gold = Color(0xFFC89B3C);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>?> _profileFuture;
  late Future<bool> _adminFuture;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _profileFuture = WalletService.getProfile();
    _adminFuture = WalletService.isAdmin();
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 82, maxWidth: 800, maxHeight: 800);
    if (picked == null) return;
    setState(() => _uploading = true);
    try {
      final bytes = await picked.readAsBytes();
      await WalletService.uploadAvatar(bytes);
      if (mounted) setState(() {});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile picture updated successfully.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally { if (mounted) setState(() => _uploading = false); }
  }

  Future<void> _logout() async {
    await WalletService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = WalletService.currentUser;
    final avatar = WalletService.avatarUrl;
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile'), backgroundColor: _navy, foregroundColor: Colors.white),
      body: FutureBuilder<Map<String, dynamic>?>(future: _profileFuture, builder: (context, snapshot) {
        final profile = snapshot.data ?? {};
        final name = profile['full_name']?.toString().trim();
        final phone = profile['phone']?.toString().trim();
        final email = profile['email']?.toString().trim() ?? user?.email ?? '';
        return ListView(padding: const EdgeInsets.all(20), children: [
          Center(child: Stack(children: [
            CircleAvatar(radius: 54, backgroundColor: _gold.withOpacity(.25), backgroundImage: avatar?.isNotEmpty == true ? NetworkImage(avatar!) : null, child: avatar?.isNotEmpty == true ? null : const Icon(Icons.person, size: 55, color: _navy)),
            Positioned(right: 0, bottom: 0, child: Material(color: _gold, shape: const CircleBorder(), child: InkWell(onTap: _uploading ? null : _pickPhoto, customBorder: const CircleBorder(), child: Padding(padding: const EdgeInsets.all(10), child: _uploading ? const SizedBox(width: 17, height: 17, child: CircularProgressIndicator(strokeWidth: 2, color: _navy)) : const Icon(Icons.camera_alt, color: _navy, size: 19))))),
          ])),
          const SizedBox(height: 10),
          Center(child: Text(name?.isNotEmpty == true ? name! : 'Customer', style: const TextStyle(color: _navy, fontSize: 22, fontWeight: FontWeight.w900))),
          Center(child: Text(_uploading ? 'Uploading photo...' : 'Tap the camera to change your picture', style: const TextStyle(color: Colors.black54, fontSize: 12))),
          const SizedBox(height: 24),
          Card(child: Column(children: [ListTile(leading: const Icon(Icons.person_outline, color: _navy), title: const Text('Full name'), subtitle: Text(name?.isNotEmpty == true ? name! : 'Not available')), ListTile(leading: const Icon(Icons.phone_outlined, color: _navy), title: const Text('Phone'), subtitle: Text(phone?.isNotEmpty == true ? phone! : 'Not available')), ListTile(leading: const Icon(Icons.email_outlined, color: _navy), title: const Text('Email'), subtitle: Text(email.isNotEmpty ? email : 'Not available'))])),
          const SizedBox(height: 14),
          Card(child: Column(children: [ListTile(leading: const Icon(Icons.account_balance_wallet_outlined, color: _navy), title: const Text('Wallet'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.pushNamed(context, '/wallet')), ListTile(leading: const Icon(Icons.receipt_long_outlined, color: _navy), title: const Text('Transactions'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.pushNamed(context, '/transactions'))])),
          FutureBuilder<bool>(future: _adminFuture, builder: (context, adminSnapshot) => adminSnapshot.data == true ? Padding(padding: const EdgeInsets.only(top: 14), child: Card(child: ListTile(leading: const Icon(Icons.admin_panel_settings_outlined, color: _gold), title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)), subtitle: const Text('Manage users, wallets and service activity'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.pushNamed(context, '/admin')))) : const SizedBox.shrink()),
          const SizedBox(height: 20),
          OutlinedButton.icon(onPressed: _logout, icon: const Icon(Icons.logout), label: const Text('Logout'), style: OutlinedButton.styleFrom(foregroundColor: _navy, side: const BorderSide(color: _gold))),
        ]);
      }),
    );
  }
}
