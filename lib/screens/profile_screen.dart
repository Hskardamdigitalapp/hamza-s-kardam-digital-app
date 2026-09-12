import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/wallet_service.dart';
import 'appearance_screen.dart';
import 'change_password_screen.dart';
import 'customer_care_screen.dart';

const _navy = Color(0xFF061B49);
const _navy2 = Color(0xFF0A2C68);
const _gold = Color(0xFFC89B3C);
const _goldLight = Color(0xFFE7C66A);
const _muted = Color(0xFF667085);
const _danger = Color(0xFFF44336);
const _card = Colors.white;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _kycFuture;
  late Future<bool> _adminFuture;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _kycFuture = WalletService.getProfileKyc();
    _adminFuture = WalletService.isAdmin();
  }

  void _snack(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _open(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Future<void> _chooseProfileImage() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(leading: const Icon(Icons.person), title: const Text('Use Avatar'), onTap: () => Navigator.pop(context, 'avatar')),
          ListTile(leading: const Icon(Icons.photo_camera), title: const Text('Use Real Picture'), onTap: () => Navigator.pop(context, 'photo')),
        ]),
      ),
    );
    if (choice == null || !mounted) return;
    if (choice == 'avatar') {
      _snack('Avatar selected.');
      return;
    }
    setState(() => _uploading = true);
    try {
      final ok = await WalletService.pickAndUploadAvatar();
      if (mounted) _snack(ok ? 'Profile picture updated.' : 'No picture was selected.');
    } catch (_) {
      if (mounted) _snack('Unable to update profile picture.');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _confirmDelete() async {
    final balance = await WalletService.getBalance();
    if (!mounted) return;
    if (balance > 0.0) {
      await showDialog<void>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Cannot delete account'),
          content: Text('Your wallet still has ₦${balance.toStringAsFixed(2)}. Withdraw or spend the remaining balance until it is exactly ₦0.00 before deleting the account.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
            ElevatedButton(onPressed: () { Navigator.pop(c); Navigator.pushNamed(context, '/wallet'); }, child: const Text('Go to Wallet')),
          ],
        ),
      );
      return;
    }
    final yes = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text('This permanently deletes your account and stored data. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(c, true), style: ElevatedButton.styleFrom(backgroundColor: _danger, foregroundColor: Colors.white), child: const Text('Delete Account')),
        ],
      ),
    );
    if (yes != true || !mounted) return;
    final result = await WalletService.deleteAccount();
    if (!mounted) return;
    if (result == true) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    } else {
      _snack('Account deletion failed. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final name = (user?.userMetadata?['full_name']?.toString().trim().isNotEmpty ?? false) ? user!.userMetadata!['full_name'].toString().trim() : 'User';
    final email = user?.email ?? '';
    final avatar = WalletService.avatarUrl;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('${_greeting()}, $name', style: const TextStyle(fontWeight: FontWeight.w900)),
        actions: [IconButton(onPressed: () => _snack('Notifications will appear here.'), icon: const Icon(Icons.notifications_none))],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _kycFuture,
        builder: (context, ks) {
          final k = ks.data ?? {};
          final tier = int.tryParse('${k['tier'] ?? 1}') ?? 1;
          final status = '${k['status'] ?? 'unverified'}';
          return RefreshIndicator(
            color: _gold,
            onRefresh: () async { setState(_load); await _kycFuture; },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
              children: [
                _profileHero(name, email, avatar),
                const SizedBox(height: 14),
                _limitsCard(tier),
                const SizedBox(height: 14),
                _tierUpgradeCard(tier, status),
                const SizedBox(height: 14),
                _item(Icons.receipt_long_outlined, 'Transaction History', 'Review your past transactions', () => Navigator.pushNamed(context, '/transactions')),
                _item(Icons.dialpad_outlined, 'Transaction PIN', 'Change your transaction PIN', () => _snack('Transaction PIN will be secured before wallet payments are enabled.')),
                _item(Icons.fingerprint, 'Biometrics', 'Use fingerprint / face ID for secure actions', () => _snack('Device biometric authentication is available for supported secure actions.')),
                _item(Icons.lock_reset, 'Change Password', 'Update your login password', () => _open(const ChangePasswordScreen())),
                _item(Icons.card_giftcard, 'Refer & Earn', 'Invite friends and earn rewards', () => _snack('Referral rewards will activate with the rewards backend.')),
                _item(Icons.palette_outlined, 'Appearance', 'Choose System default, Light or Dark', () => _open(const AppearanceScreen())),
                _item(Icons.headset_mic_outlined, 'Customer Care', 'AI Assistant or talk to a real person', () => _open(const CustomerCareScreen())),
                FutureBuilder<bool>(future: _adminFuture, builder: (context, a) => a.data == true ? _item(Icons.admin_panel_settings_outlined, 'Admin Dashboard', 'Manage users, KYC and service activity', () => Navigator.pushNamed(context, '/admin')) : const SizedBox.shrink()),
                const SizedBox(height: 12),
                _item(Icons.delete_forever_outlined, 'Delete Account', 'Permanently remove your account', _confirmDelete, danger: true),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await WalletService.logout();
                      if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w900)),
                    style: ElevatedButton.styleFrom(backgroundColor: _danger, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Theme.of(context).cardColor,
        selectedIndex: 4,
        onDestinationSelected: (i) {
          if (i == 0) Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
          if (i == 1) Navigator.pushNamed(context, '/orders');
          if (i == 2) Navigator.pushNamed(context, '/transactions');
          if (i == 3) Navigator.pushNamed(context, '/wallet');
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.swap_horiz), label: 'Transactions'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Wallet'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _profileHero(String name, String email, String? avatar) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(gradient: const LinearGradient(colors: [_navy, _navy2], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(26)),
    child: Column(
      children: [
        Stack(children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(color: _gold, shape: BoxShape.circle),
            child: CircleAvatar(radius: 45, backgroundColor: Colors.white, backgroundImage: avatar?.isNotEmpty == true ? NetworkImage(avatar!) : null, child: avatar?.isNotEmpty == true ? null : const Icon(Icons.person, size: 48, color: _navy)),
          ),
          Positioned(right: 0, bottom: 0, child: Material(color: _gold, shape: const CircleBorder(), child: InkWell(onTap: _uploading ? null : _chooseProfileImage, customBorder: const CircleBorder(), child: Padding(padding: const EdgeInsets.all(9), child: Icon(_uploading ? Icons.hourglass_top : Icons.camera_alt, size: 18, color: _navy))))),
        ]),
        const SizedBox(height: 12),
        Text(name, style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(email, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 12),
        const Text('HAMZA S. KARDAM DIGITAL APP', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: .8)),
      ],
    ),
  );

  Widget _limitsCard(int tier) => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(22), border: Border.all(color: _gold.withOpacity(.18))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Icon(Icons.account_balance_wallet, color: _gold), const SizedBox(width: 10), const Text('Wallet & Limits', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), const Spacer(), _badge('Tier $tier')]), const SizedBox(height: 16), _limit('Wallet limit', tier >= 3 ? '₦5,000,000' : tier >= 2 ? '₦500,000' : '₦50,000'), _limit('Today limit', tier >= 3 ? '₦3,000,000' : tier >= 2 ? '₦100,000' : '₦20,000')]);

  Widget _tierUpgradeCard(int tier, String status) => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: _navy, borderRadius: BorderRadius.circular(24)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Icon(Icons.workspace_premium, color: _gold), const SizedBox(width: 10), const Text('TIER UPGRADE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.4)), const Spacer(), _badge(tier >= 3 ? 'Tier 3' : 'Tier ${tier + 1}')]), const SizedBox(height: 16), Text(tier >= 3 ? 'You are on Tier 3' : 'Unlock Tier ${tier + 1}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)), const SizedBox(height: 6), Text(tier >= 3 ? 'Maximum available tier.' : 'Verify your identity to raise your limits and unlock more services.', style: const TextStyle(color: Colors.white70, fontSize: 14)), if (tier < 3) ...[const SizedBox(height: 16), _benefit(Icons.account_balance_wallet, tier == 1 ? 'Wallet cap raised to ₦500,000' : 'Wallet cap raised to ₦5,000,000'), _benefit(Icons.bolt, tier == 1 ? 'Unlock Airtime to Cash after Tier 2 verification' : 'Higher transaction limits'), _benefit(Icons.shield_outlined, 'Stronger account security and service access'), const SizedBox(height: 7), SizedBox(width: double.infinity, height: 50, child: ElevatedButton.icon(onPressed: status == 'pending' ? null : () => _snack('Verification flow is ready for KYC review.'), icon: Icon(status == 'pending' ? Icons.hourglass_top : Icons.arrow_forward), label: Text(status == 'pending' ? 'Verification Pending' : 'Start verification'), style: ElevatedButton.styleFrom(backgroundColor: _gold, foregroundColor: _navy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)))))] else const Padding(padding: EdgeInsets.only(top: 14), child: Text('✓ Identity verified', style: TextStyle(color: _gold, fontWeight: FontWeight.bold))]));

  Widget _benefit(IconData icon, String text) => Padding(padding: const EdgeInsets.only(bottom: 9), child: Row(children: [Icon(icon, color: _gold, size: 21), const SizedBox(width: 11), Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)))]));
  Widget _limit(String label, String value) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [Text(label, style: const TextStyle(color: _muted)), const Spacer(), Text(value, style: const TextStyle(fontWeight: FontWeight.w900))]));
  Widget _badge(String text) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), decoration: BoxDecoration(color: _gold, borderRadius: BorderRadius.circular(18)), child: Text(text, style: const TextStyle(color: _navy, fontWeight: FontWeight.w900)));
  Widget _item(IconData icon, String title, String sub, VoidCallback tap, {bool danger = false}) => Container(margin: const EdgeInsets.only(bottom: 10), decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: danger ? _danger.withOpacity(.35) : Theme.of(context).dividerColor)), child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5), leading: Container(width: 50, height: 50, decoration: BoxDecoration(color: danger ? _danger.withOpacity(.10) : _goldLight, shape: BoxShape.circle), child: Icon(icon, color: danger ? _danger : _navy)), title: Text(title, style: TextStyle(color: danger ? _danger : Theme.of(context).textTheme.titleMedium?.color, fontSize: 16, fontWeight: FontWeight.w800)), subtitle: Text(sub, style: const TextStyle(color: _muted)), trailing: Icon(Icons.chevron_right, color: danger ? _danger : _gold), onTap: tap));
}
