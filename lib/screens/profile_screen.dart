import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/wallet_service.dart';
import 'appearance_screen.dart';
import 'change_password_screen.dart';
import 'customer_care_screen.dart';

const _bg = Color(0xFFF5F7FB);
const _navy = Color(0xFF061B49);
const _navy2 = Color(0xFF0A2C68);
const _gold = Color(0xFFB8860B);
const _goldLight = Color(0xFFF4E8C6);
const _muted = Color(0xFF667085);
const _card = Colors.white;
const _danger = Color(0xFFD32F2F);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>?> _profileFuture;
  late Future<bool> _adminFuture;
  late Future<Map<String, dynamic>> _kycFuture;
  bool _uploading = false;

  @override
  void initState() { super.initState(); _load(); }
  void _load() { _profileFuture = WalletService.getProfile(); _adminFuture = WalletService.isAdmin(); _kycFuture = WalletService.getMyKycStatus(); }
  void _snack(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Future<void> _chooseProfileImage() async {
    final choice = await showModalBottomSheet<String>(context: context, backgroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))), builder: (ctx) => SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 20), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 42, height: 4, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(5))),
      const SizedBox(height: 18), const Text('Profile Picture', style: TextStyle(color: _navy, fontSize: 20, fontWeight: FontWeight.w900)),
      const SizedBox(height: 12),
      ListTile(leading: const CircleAvatar(backgroundColor: _goldLight, child: Icon(Icons.person, color: _navy)), title: const Text('Use Avatar', style: TextStyle(fontWeight: FontWeight.w800)), subtitle: const Text('Use your account avatar instead of a real photo'), onTap: () => Navigator.pop(ctx, 'avatar')),
      ListTile(leading: const CircleAvatar(backgroundColor: _goldLight, child: Icon(Icons.photo_camera_outlined, color: _navy)), title: const Text('Use Real Picture', style: TextStyle(fontWeight: FontWeight.w800)), subtitle: const Text('Choose your own picture from the gallery'), onTap: () => Navigator.pop(ctx, 'photo')),
    ]))));
    if (choice == 'avatar') { try { await WalletService.useDefaultAvatar(); if (mounted) setState(_load); } catch (e) { if (mounted) _snack(e.toString().replaceFirst('Exception: ', '')); } return; }
    if (choice != 'photo') return;
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 82, maxWidth: 800, maxHeight: 800);
    if (picked == null) return;
    setState(() => _uploading = true);
    try { await WalletService.uploadAvatar(await picked.readAsBytes()); if (mounted) setState(_load); }
    catch (e) { if (mounted) _snack('Upload failed: $e'); }
    finally { if (mounted) setState(() => _uploading = false); }
  }

  Future<void> _verify(int tier) async {
    String method = 'NIN'; final ref = TextEditingController();
    final result = await showDialog<bool>(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setDialog) => AlertDialog(
      backgroundColor: Colors.white,
      title: Text('Verify for Tier $tier', style: const TextStyle(color: _navy, fontWeight: FontWeight.w900)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Enter your NIN or BVN. The number stays visible while typing so you can check and correct mistakes before submitting.'),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(value: method, decoration: const InputDecoration(labelText: 'Verification method'), items: const [DropdownMenuItem(value: 'NIN', child: Text('NIN')), DropdownMenuItem(value: 'BVN', child: Text('BVN'))], onChanged: (v) => setDialog(() => method = v!)),
        const SizedBox(height: 12),
        TextField(controller: ref, keyboardType: TextInputType.number, maxLength: 11, autofocus: true, autocorrect: false, enableSuggestions: false, decoration: InputDecoration(labelText: '$method number', prefixIcon: const Icon(Icons.verified_user_outlined, color: _navy), suffixIcon: IconButton(icon: const Icon(Icons.clear), onPressed: () => setDialog(ref.clear)), counterText: '', helperText: '11 digits • Visible while entering')),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('Cancel')), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: _navy, foregroundColor: Colors.white), onPressed: () => Navigator.pop(ctx, RegExp(r'^\d{11}$').hasMatch(ref.text.trim())), child: const Text('Submit'))],
    )));
    if (result != true) { ref.dispose(); if (result == false && mounted) _snack('Enter a valid 11-digit $method number.'); return; }
    try { await WalletService.requestKycUpgrade(method: method, reference: ref.text.trim(), targetTier: tier); if (mounted) { setState(_load); _snack('Identity verification submitted securely.'); } }
    catch (e) { if (mounted) _snack(e.toString().replaceFirst('Exception: ', '')); }
    ref.dispose();
  }

  Future<void> _confirmDelete() async {
    double balance = 0;
    try { balance = await WalletService.getBalance(); } catch (_) { if (mounted) _snack('Unable to check wallet balance. Try again.'); return; }
    if (balance > 0) {
      if (!mounted) return;
      await showDialog<void>(context: context, builder: (c) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Row(children: [Icon(Icons.warning_amber_rounded, color: _danger), SizedBox(width: 8), Expanded(child: Text('Account Cannot Be Deleted'))]),
        content: Text('You still have ₦${balance.toStringAsFixed(2)} in your wallet. Before deleting your account, please withdraw or spend the remaining money until your wallet balance is ₦0.00.'),
        actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Close')), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: _navy, foregroundColor: Colors.white), onPressed: () { Navigator.pop(c); Navigator.pushNamed(context, '/wallet'); }, child: const Text('Go to Wallet'))],
      ));
      return;
    }
    if (!mounted) return;
    final confirmed = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      backgroundColor: Colors.white,
      title: const Row(children: [Icon(Icons.warning_amber_rounded, color: _danger), SizedBox(width: 8), Expanded(child: Text('Delete Account?'))]),
      content: const Text('Your wallet is ₦0.00. Deleting your account is permanent and your account data will be removed.'),
      actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: _danger, foregroundColor: Colors.white), onPressed: () => Navigator.pop(c, true), child: const Text('Delete Account'))],
    ));
    if (confirmed != true) return;
    try { await WalletService.deleteAccount(); if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false); }
    catch (e) { if (mounted) _snack(e.toString().replaceFirst('Exception: ', '')); }
  }

  void _open(Widget screen) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final user = WalletService.currentUser; final avatar = WalletService.avatarUrl;
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _navy, foregroundColor: Colors.white, elevation: 0,
        title: FutureBuilder<Map<String, dynamic>?>(future: _profileFuture, builder: (context, snap) {
          final p = snap.data ?? {}; final name = (p['full_name']?.toString().trim().isNotEmpty == true) ? p['full_name'].toString().trim() : 'Customer';
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${_greeting()}, $name', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), const Text('Profile', style: TextStyle(fontSize: 12, color: Colors.white70))]);
        }),
        actions: [IconButton(tooltip: 'Notifications', onPressed: () => _snack('No new notifications.'), icon: const Icon(Icons.notifications_none_rounded, color: _goldLight))],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(future: _profileFuture, builder: (context, ps) {
        final p = ps.data ?? {}; final name = (p['full_name']?.toString().trim().isNotEmpty == true) ? p['full_name'].toString().trim() : 'Customer'; final email = p['email']?.toString().trim().isNotEmpty == true ? p['email'].toString().trim() : (user?.email ?? '');
        return FutureBuilder<Map<String, dynamic>>(future: _kycFuture, builder: (context, ks) {
          final k = ks.data ?? {}; final tier = int.tryParse('${k['tier'] ?? 1}') ?? 1; final status = '${k['status'] ?? 'unverified'}';
          return RefreshIndicator(color: _gold, onRefresh: () async { setState(_load); await _kycFuture; }, child: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 110), children: [
            _profileHero(name, email, avatar),
            const SizedBox(height: 14), _limitsCard(tier), const SizedBox(height: 14), _tierUpgradeCard(tier, status), const SizedBox(height: 14),
            _item(Icons.receipt_long_outlined, 'Transaction History', 'Review your past transactions', () => Navigator.pushNamed(context, '/transactions')),
            _item(Icons.dialpad_outlined, 'Transaction PIN', 'Change your transaction PIN', () => _snack('Transaction PIN will be secured before wallet payments are enabled.')),
            _item(Icons.fingerprint, 'Biometrics', 'Use fingerprint / face ID for secure actions', () => _snack('Device biometric authentication is available for supported secure actions.')),
            _item(Icons.lock_reset, 'Change Password', 'Update your login password', () => _open(const ChangePasswordScreen())),
            _item(Icons.card_giftcard, 'Refer & Earn', 'Invite friends and earn rewards', () => _snack('Referral rewards will activate with the rewards backend.')),
            _item(Icons.palette_outlined, 'Appearance', 'Choose System default, Light or Dark', () => _open(const AppearanceScreen())),
            _item(Icons.headset_mic_outlined, 'Customer Care', 'AI Assistant or talk to a real person', () => _open(const CustomerCareScreen())),
            FutureBuilder<bool>(future: _adminFuture, builder: (context, a) => a.data == true ? _item(Icons.admin_panel_settings_outlined, 'Admin Dashboard', 'Manage users, KYC and service activity', () => Navigator.pushNamed(context, '/admin')) : const SizedBox.shrink()),
            _item(Icons.delete_forever_outlined, 'Delete Account', 'Permanently remove your account', _confirmDelete, danger: true),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, height: 52, child: ElevatedButton.icon(onPressed: () async { await WalletService.logout(); if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false); }, icon: const Icon(Icons.logout), label: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w900)), style: ElevatedButton.styleFrom(backgroundColor: _danger, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)))),
          ]));
        });
      }),
      bottomNavigationBar: NavigationBar(backgroundColor: Colors.white, indicatorColor: _goldLight, selectedIndex: 4, onDestinationSelected: (i) { if (i == 0) Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false); if (i == 1) Navigator.pushNamed(context, '/orders'); if (i == 2) Navigator.pushNamed(context, '/transactions'); if (i == 3) Navigator.pushNamed(context, '/wallet'); }, destinations: const [NavigationDestination(icon: Icon(Icons.home_outlined, color: _navy), selectedIcon: Icon(Icons.home, color: _navy), label: 'Home'), NavigationDestination(icon: Icon(Icons.receipt_long_outlined, color: _navy), label: 'Orders'), NavigationDestination(icon: Icon(Icons.swap_horiz, color: _navy), label: 'Transactions'), NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined, color: _navy), label: 'Wallet'), NavigationDestination(icon: Icon(Icons.person_outline, color: _gold), selectedIcon: Icon(Icons.person, color: _navy), label: 'Profile')]),
    );
  }

  Widget _profileHero(String name, String email, String? avatar) => Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: const LinearGradient(colors: [_navy, _navy2], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(26), boxShadow: [BoxShadow(color: _navy.withOpacity(.18), blurRadius: 18, offset: const Offset(0, 8))]), child: Column(children: [Stack(children: [Container(padding: const EdgeInsets.all(3), decoration: const BoxDecoration(color: _gold, shape: BoxShape.circle), child: CircleAvatar(radius: 45, backgroundColor: Colors.white, backgroundImage: avatar?.isNotEmpty == true ? NetworkImage(avatar!) : null, child: avatar?.isNotEmpty == true ? null : const Icon(Icons.person, size: 48, color: _navy))), Positioned(right: 0, bottom: 0, child: Material(color: _gold, shape: const CircleBorder(), child: InkWell(onTap: _uploading ? null : _chooseProfileImage, customBorder: const CircleBorder(), child: Padding(padding: const EdgeInsets.all(9), child: Icon(_uploading ? Icons.hourglass_top : Icons.camera_alt, size: 18, color: _navy)))))]), const SizedBox(height: 12), Text(name, style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text(email, style: TextStyle(color: Colors.white.withOpacity(.72), fontSize: 14)), const SizedBox(height: 12), Container(padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7), decoration: BoxDecoration(color: _gold.withOpacity(.18), borderRadius: BorderRadius.circular(20), border: Border.all(color: _gold.withOpacity(.55))), child: const Text('HAMZA S. KARDAM DIGITAL APP', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: .8)))]));
  Widget _limitsCard(int tier) { final wallet = tier >= 3 ? '₦5,000,000' : tier >= 2 ? '₦500,000' : '₦50,000'; final today = tier >= 3 ? '₦3,000,000' : tier >= 2 ? '₦100,000' : '₦20,000'; return Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(22), border: Border.all(color: _gold.withOpacity(.18))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Icon(Icons.account_balance_wallet, color: _gold), const SizedBox(width: 10), const Text('Wallet & Limits', style: TextStyle(color: _navy, fontSize: 18, fontWeight: FontWeight.w900)), const Spacer(), _badge('Tier $tier')]), const SizedBox(height: 16), _limit('Wallet limit', wallet), _limit('Today limit', today)])); }
  Widget _tierUpgradeCard(int tier, String status) { final next = tier >= 3 ? 3 : tier + 1; final pending = status == 'pending'; return Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: _navy, borderRadius: BorderRadius.circular(24)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Icon(Icons.workspace_premium, color: _gold), const SizedBox(width: 10), const Text('TIER UPGRADE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.4)), const Spacer(), _badge(tier >= 3 ? 'Tier 3' : 'Tier $next')]), const SizedBox(height: 16), Text(tier >= 3 ? 'You are on Tier 3' : 'Unlock Tier $next', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)), const SizedBox(height: 6), Text(tier >= 3 ? 'Maximum available tier.' : 'Verify your identity to raise your limits and unlock more services.', style: TextStyle(color: Colors.white.withOpacity(.72), fontSize: 14)), if (tier < 3) ...[const SizedBox(height: 16), _benefit(Icons.account_balance_wallet, tier == 1 ? 'Wallet cap raised to ₦500,000' : 'Wallet cap raised to ₦5,000,000'), _benefit(Icons.bolt, tier == 1 ? 'Unlock Airtime to Cash after Tier 2 verification' : 'Higher transaction limits'), _benefit(Icons.shield_outlined, 'Stronger account security and service access'), const SizedBox(height: 7), SizedBox(width: double.infinity, height: 50, child: ElevatedButton.icon(onPressed: pending ? null : () => _verify(next), icon: Icon(pending ? Icons.hourglass_top : Icons.arrow_forward), label: Text(pending ? 'Verification Pending' : 'Start verification'), style: ElevatedButton.styleFrom(backgroundColor: _gold, foregroundColor: _navy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)))))] else const Padding(padding: EdgeInsets.only(top: 14), child: Text('✓ Identity verified', style: TextStyle(color: _gold, fontWeight: FontWeight.bold)))])); }
  Widget _benefit(IconData icon, String text) => Padding(padding: const EdgeInsets.only(bottom: 9), child: Row(children: [Icon(icon, color: _gold, size: 21), const SizedBox(width: 11), Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)))]));
  Widget _limit(String label, String value) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [Text(label, style: const TextStyle(color: _muted)), const Spacer(), Text(value, style: const TextStyle(color: _navy, fontWeight: FontWeight.w900))]));
  Widget _badge(String text) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), decoration: BoxDecoration(color: _gold, borderRadius: BorderRadius.circular(18)), child: Text(text, style: const TextStyle(color: _navy, fontWeight: FontWeight.w900)));
  Widget _item(IconData icon, String title, String sub, VoidCallback tap, {bool danger = false}) => Container(margin: const EdgeInsets.only(bottom: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: danger ? _danger.withOpacity(.35) : const Color(0xFFE6EAF0))), child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5), leading: Container(width: 50, height: 50, decoration: BoxDecoration(color: danger ? _danger.withOpacity(.10) : _goldLight, shape: BoxShape.circle), child: Icon(icon, color: danger ? _danger : _navy)), title: Text(title, style: TextStyle(color: danger ? _danger : _navy, fontSize: 16, fontWeight: FontWeight.w800)), subtitle: Text(sub, style: const TextStyle(color: _muted)), trailing: Icon(Icons.chevron_right, color: danger ? _danger : _gold), onTap: tap));
}
