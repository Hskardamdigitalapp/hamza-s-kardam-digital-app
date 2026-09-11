import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/wallet_service.dart';

const _bg = Color(0xFF101010);
const _card = Color(0xFF1B1B1D);
const _gold = Color(0xFFFFC83D);
const _muted = Color(0xFF9B9BA6);
const _navy = Color(0xFF061B49);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>?> _profileFuture;
  late Future<bool> _adminFuture;
  late Future<Map<String, dynamic>> _kycFuture;
  bool _uploading = false;
  @override void initState(){super.initState();_load();}
  void _load(){_profileFuture=WalletService.getProfile();_adminFuture=WalletService.isAdmin();_kycFuture=WalletService.getMyKycStatus();}
  void _snack(String s)=>ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(s)));
  Future<void> _pickPhoto() async {final picked=await ImagePicker().pickImage(source:ImageSource.gallery,imageQuality:82,maxWidth:800,maxHeight:800);if(picked==null)return;setState(()=>_uploading=true);try{await WalletService.uploadAvatar(await picked.readAsBytes());if(mounted)setState(_load);}catch(e){if(mounted)_snack('Upload failed: $e');}finally{if(mounted)setState(()=>_uploading=false);}}

  Future<void> _verify(int tier) async {
    String method='NIN'; final ref=TextEditingController();
    final result=await showDialog<bool>(context:context,builder:(ctx)=>StatefulBuilder(builder:(ctx,setDialog)=>AlertDialog(
      title:Text('Verify for Tier $tier'),
      content:Column(mainAxisSize:MainAxisSize.min,children:[const Text('Choose NIN or BVN. Your details are submitted for secure review and are not automatically approved.'),const SizedBox(height:14),DropdownButtonFormField<String>(value:method,decoration:const InputDecoration(labelText:'Verification method'),items:const [DropdownMenuItem(value:'NIN',child:Text('NIN')),DropdownMenuItem(value:'BVN',child:Text('BVN'))],onChanged:(v)=>setDialog(()=>method=v!)),const SizedBox(height:12),TextField(controller:ref,keyboardType:TextInputType.number,obscureText:true,maxLength:11,decoration:InputDecoration(labelText:'$method number',prefixIcon:const Icon(Icons.verified_user_outlined),counterText:'',helperText:'11 digits required. Never share it in chat.'))]),
      actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Cancel')),ElevatedButton(onPressed:()=>Navigator.pop(ctx,RegExp(r'^\d{11}$').hasMatch(ref.text.trim())),child:const Text('Submit'))],
    )));
    if(result!=true){ref.dispose();if(result==false&&mounted)_snack('Enter a valid 11-digit $method number.');return;}
    try{await WalletService.requestKycUpgrade(method:method,reference:ref.text.trim(),targetTier:tier);if(mounted){setState(_load);_snack('Verification submitted. Your status is pending review.');}}catch(e){if(mounted)_snack(e.toString().replaceFirst('Exception: ',''));}ref.dispose();
  }

  @override Widget build(BuildContext context){
    final user=WalletService.currentUser; final avatar=WalletService.avatarUrl;
    return Scaffold(backgroundColor:_bg,appBar:AppBar(title:const Text('Profile'),backgroundColor:_bg,foregroundColor:Colors.white,elevation:0),
      body:FutureBuilder<Map<String,dynamic>?>(future:_profileFuture,builder:(context,ps){
        final p=ps.data??{};final name=(p['full_name']?.toString().trim().isNotEmpty==true)?p['full_name'].toString():'Customer';final phone=p['phone']?.toString()??'';final email=p['email']?.toString()??user?.email??'';
        return FutureBuilder<Map<String,dynamic>>(future:_kycFuture,builder:(context,ks){
          final k=ks.data??{};final tier=int.tryParse('${k['tier']??1}')??1;final status='${k['status']??'unverified'}';
          return RefreshIndicator(color:_gold,onRefresh:() async{setState(_load);await _kycFuture;},child:ListView(padding:const EdgeInsets.fromLTRB(18,8,18,110),children:[
            Center(child:Stack(children:[CircleAvatar(radius:48,backgroundColor:_gold,backgroundImage:avatar?.isNotEmpty==true?NetworkImage(avatar!):null,child:avatar?.isNotEmpty==true?null:const Icon(Icons.person,size:50,color:Colors.black)),Positioned(right:0,bottom:0,child:Material(color:_gold,shape:const CircleBorder(),child:InkWell(onTap:_uploading?null:_pickPhoto,customBorder:const CircleBorder(),child:Padding(padding:const EdgeInsets.all(9),child:Icon(_uploading?Icons.hourglass_top:Icons.camera_alt,color:Colors.black,size:18)))))])),
            const SizedBox(height:10),Center(child:Text(name,style:const TextStyle(color:Colors.white,fontSize:22,fontWeight:FontWeight.w900))),Center(child:Text(phone.isNotEmpty?phone:email,style:const TextStyle(color:_muted))),const SizedBox(height:22),
            _limitsCard(tier),const SizedBox(height:14),_tierUpgradeCard(tier,status),const SizedBox(height:14),
            _item(Icons.receipt_long_outlined,'Transaction History','Review your past transactions',()=>Navigator.pushNamed(context,'/transactions')),
            _item(Icons.dialpad_outlined,'Transaction PIN','Change your transaction PIN',()=>_snack('Transaction PIN will be secured before it is enabled for wallet payments.')),
            _item(Icons.fingerprint,'Biometrics','Register your fingerprint / face ID',()=>_snack('Device biometric authentication will be used for supported secure actions.')),
            _item(Icons.lock_reset,'Change Password','Update your login password',()=>_snack('Password reset is available from the login screen.')),
            _item(Icons.card_giftcard,'Refer & Earn','Invite friends and earn rewards',()=>_snack('Referral rewards will activate with the rewards backend.')),
            _item(Icons.dark_mode_outlined,'Appearance','Choose how the app looks',()=>_snack('Dark mode is currently active.')),
            _item(Icons.headset_mic_outlined,'Customer Support','Access help and support',()=>_snack('Customer support is available through the app support channel.')),
            _item(Icons.delete_outline,'Delete Account','Permanently remove your account',_confirmDelete),
            FutureBuilder<bool>(future:_adminFuture,builder:(context,a)=>a.data==true?_item(Icons.admin_panel_settings_outlined,'Admin Dashboard','Manage users, KYC and service activity',()=>Navigator.pushNamed(context,'/admin')):const SizedBox.shrink()),
            const SizedBox(height:12),OutlinedButton.icon(onPressed:() async{await WalletService.logout();if(mounted)Navigator.pushNamedAndRemoveUntil(context,'/login',(_)=>false);},icon:const Icon(Icons.logout),label:const Text('Logout'),style:OutlinedButton.styleFrom(foregroundColor:_gold,side:const BorderSide(color:_gold))),
          ]));
        });
      }),
      bottomNavigationBar:NavigationBar(backgroundColor:_card,indicatorColor:_gold.withOpacity(.25),selectedIndex:4,onDestinationSelected:(i){if(i==0)Navigator.pushNamedAndRemoveUntil(context,'/home',(_)=>false);if(i==1)Navigator.pushNamed(context,'/orders');if(i==2)Navigator.pushNamed(context,'/transactions');if(i==3)Navigator.pushNamed(context,'/wallet');},destinations:const [NavigationDestination(icon:Icon(Icons.home_outlined),selectedIcon:Icon(Icons.home,color:_gold),label:'Home'),NavigationDestination(icon:Icon(Icons.receipt_long_outlined),label:'Orders'),NavigationDestination(icon:Icon(Icons.swap_horiz),label:'Transactions'),NavigationDestination(icon:Icon(Icons.account_balance_wallet_outlined),label:'Wallet'),NavigationDestination(icon:Icon(Icons.person_outline),selectedIcon:Icon(Icons.person,color:_gold),label:'Profile')]),
      floatingActionButton:FloatingActionButton(onPressed:()=>_snack('Customer support: please use our WhatsApp support channel.'),backgroundColor:_gold,foregroundColor:Colors.black,child:const Icon(Icons.support_agent)),
    );
  }

  Widget _limitsCard(int tier)=>Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:_card,borderRadius:BorderRadius.circular(22)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[const Icon(Icons.account_balance_wallet,color:_gold),const SizedBox(width:10),const Text('Wallet & Limits',style:TextStyle(color:Colors.white,fontSize:18,fontWeight:FontWeight.w800)),const Spacer(),_badge('Tier $tier')]),const SizedBox(height:16),_limit('Wallet',tier>=3?'₦5,000,000':tier>=2?'₦500,000':'₦50,000'),_limit('Today',tier>=3?'₦3,000,000':tier>=2?'₦100,000':'₦20,000')]);

  Widget _tierUpgradeCard(int tier,String status){final next=tier>=3?3:tier+1;return Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(borderRadius:BorderRadius.circular(24),border:Border.all(color:_gold.withOpacity(.65)),gradient:const LinearGradient(colors:[Color(0xFF202022),Color(0xFF151516)])),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[const Icon(Icons.workspace_premium,color:_gold),const SizedBox(width:10),const Text('TIER UPGRADE',style:TextStyle(color:Colors.white,fontWeight:FontWeight.w900,letterSpacing:1.5)),const Spacer(),_badge(tier>=3?'Tier 3':'Tier $next')]),const SizedBox(height:18),Text(tier>=3?'You are on Tier 3':'Unlock Tier $next',style:const TextStyle(color:Colors.white,fontSize:25,fontWeight:FontWeight.w900)),const SizedBox(height:6),Text(tier>=3?'Maximum available tier.':'Verify your identity to raise your limits and unlock more services.',style:const TextStyle(color:_muted,fontSize:15)),const SizedBox(height:16),if(tier<3)...[_benefit(Icons.account_balance_wallet,tier==1?'Wallet cap raised to ₦500,000':'Wallet cap raised to ₦5,000,000'),_benefit(Icons.bolt,tier==1?'Unlock Airtime to Cash after Tier 2 verification':'Higher transaction limits'),_benefit(Icons.shield_outlined,'Stronger account security and service access')],const SizedBox(height:16),if(tier<3)SizedBox(width:double.infinity,height:52,child:ElevatedButton.icon(onPressed:status=='pending'?null:()=>_verify(next),icon:Icon(status=='pending'?Icons.hourglass_top:Icons.arrow_forward),label:Text(status=='pending'?'Verification Pending':'Start verification'),style:ElevatedButton.styleFrom(backgroundColor:_gold,foregroundColor:Colors.black,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(15)))) else const Text('✓ Identity verified',style:TextStyle(color:_gold,fontWeight:FontWeight.bold))]);}
  Widget _benefit(IconData icon,String text)=>Padding(padding:const EdgeInsets.only(bottom:10),child:Row(children:[Icon(icon,color:_gold,size:22),const SizedBox(width:12),Expanded(child:Text(text,style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w600)))]));
  Widget _limit(String a,String b)=>Padding(padding:const EdgeInsets.only(bottom:10),child:Row(children:[Text(a,style:const TextStyle(color:_muted)),const Spacer(),Text(b,style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w800))]));
  Widget _badge(String text)=>Container(padding:const EdgeInsets.symmetric(horizontal:12,vertical:7),decoration:BoxDecoration(color:_gold,borderRadius:BorderRadius.circular(18)),child:Text(text,style:const TextStyle(color:Colors.black,fontWeight:FontWeight.w900)));
  Widget _item(IconData icon,String title,String sub,VoidCallback tap)=>Container(margin:const EdgeInsets.only(bottom:10),decoration:BoxDecoration(color:_card,borderRadius:BorderRadius.circular(20)),child:ListTile(contentPadding:const EdgeInsets.symmetric(horizontal:14,vertical:6),leading:Container(width:52,height:52,decoration:const BoxDecoration(color:_gold,shape:BoxShape.circle),child:Icon(icon,color:Colors.black)),title:Text(title,style:const TextStyle(color:Colors.white,fontSize:17,fontWeight:FontWeight.w800)),subtitle:Text(sub,style:const TextStyle(color:_muted)),trailing:const Icon(Icons.chevron_right,color:_muted),onTap:tap));
  Future<void> _confirmDelete() async{final ok=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(title:const Text('Delete Account?'),content:const Text('Account deletion will be enabled only after the secure deletion workflow is configured.'),actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Cancel')),TextButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Continue'))]));if(ok==true&&mounted)_snack('Your account remains safe because deletion is not enabled yet.');}
}
