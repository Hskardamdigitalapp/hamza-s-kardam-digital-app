import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'services/wallet_service.dart';

const _bg = Color(0xFF061B49);
const _panel = Color(0xFF0A2C68);
const _panel2 = Color(0xFF102A56);
const _navy = Color(0xFF061B49);
const _navy2 = Color(0xFF0A2C68);
const _gold = Color(0xFFB8860B);
const _goldSoft = Color(0xFF2A2110);
const _muted = Color(0xFFB7C2D6);
const _shopAddress = 'Shop No. 32, Gidan Late Mallam Shitu, Opposite Hamidu Mosque, Shanta, Unguwar Hardo Shagari Road, Bauchi, Bauchi State, Nigeria';
const _whatsapp = '2349044444921';
const _call = '07077777636';

class HomeScreen extends StatefulWidget { const HomeScreen({super.key}); @override State<HomeScreen> createState() => _HomeScreenState(); }

class _HomeScreenState extends State<HomeScreen> {
  late Future<double> _balance;
  bool _hide = false;
  @override void initState(){ super.initState(); _balance = WalletService.getBalance(); }
  Future<void> _refresh() async { setState(() => _balance = WalletService.getBalance()); await _balance; }
  Future<void> _openWhatsApp([String message='Hello H.salah Communication, I need help with your digital services.']) async { await launchUrl(Uri.parse('https://wa.me/$_whatsapp?text=${Uri.encodeComponent(message)}'), mode: LaunchMode.externalApplication); }
  Future<void> _openCall() async { await launchUrl(Uri.parse('tel:$_call'), mode: LaunchMode.externalApplication); }

  @override Widget build(BuildContext context){
    final user=WalletService.currentUser; final name=user?.userMetadata?['full_name']?.toString().trim(); final avatar=WalletService.avatarUrl;
    return Scaffold(backgroundColor:_bg, body:RefreshIndicator(color:_gold,onRefresh:_refresh,child:ListView(padding:const EdgeInsets.only(bottom:110),children:[_top(name,avatar),_wallet(),_services(),_shop()])),bottomNavigationBar:_bottom());
  }

  Widget _top(String? name,String? avatar)=>Container(padding:const EdgeInsets.fromLTRB(20,52,20,24),decoration:const BoxDecoration(gradient:LinearGradient(colors:[_navy2,_navy]),borderRadius:BorderRadius.vertical(bottom:Radius.circular(30))),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Row(children:[_BrandMark(),SizedBox(width:10),Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('HAMZA S. KARDAM',style:TextStyle(color:Colors.white,fontWeight:FontWeight.w900,fontSize:15)),Text('DIGITAL APP',style:TextStyle(color:_gold,fontWeight:FontWeight.w900,fontSize:11))])]),const SizedBox(height:22),Text(_greeting(name),style:const TextStyle(color:Colors.white,fontSize:24,fontWeight:FontWeight.w900)),const SizedBox(height:3),const Text('Fast • Reliable • Secure',style:TextStyle(color:Colors.white70,fontSize:14))]),),Column(children:[GestureDetector(onTap:()=>Navigator.pushNamed(context,'/profile'),child:CircleAvatar(radius:29,backgroundColor:_gold,backgroundImage:avatar?.isNotEmpty==true?NetworkImage(avatar!):null,child:avatar?.isNotEmpty==true?null:const Icon(Icons.person,color:_navy,size:34))),const SizedBox(height:8),IconButton(onPressed:()=>ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Notifications will appear here.'))),icon:const Icon(Icons.notifications_none,color:Colors.white,size:27))])]);

  String _greeting(String? name){final h=DateTime.now().hour;final g=h<12?'Good Morning':h<17?'Good Afternoon':'Good Evening';return '$g, ${name?.isNotEmpty==true?name:'Welcome'} 👋';}

  Widget _wallet()=>Padding(padding:const EdgeInsets.fromLTRB(18,16,18,10),child:Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(gradient:const LinearGradient(colors:[_navy2,_navy]),borderRadius:BorderRadius.circular(24),border:Border.all(color:_gold.withValues(alpha:.75))),child:FutureBuilder<double>(future:_balance,builder:(c,s){final b=s.data??0;return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[const Icon(Icons.account_balance_wallet_outlined,color:_gold),const SizedBox(width:8),const Text('Wallet Balance',style:TextStyle(color:Colors.white,fontWeight:FontWeight.w800)),const Spacer(),IconButton(onPressed:()=>setState(()=>_hide=!_hide),icon:Icon(_hide?Icons.visibility_off:Icons.visibility,color:Colors.white70))]),Text(_hide?'₦ ••••••':'₦${b.toStringAsFixed(2)}',style:const TextStyle(color:Colors.white,fontSize:30,fontWeight:FontWeight.w900)),const SizedBox(height:14),Row(children:[Expanded(child:ElevatedButton.icon(onPressed:()=>Navigator.pushNamed(context,'/wallet'),icon:const Icon(Icons.add),label:const Text('Fund Wallet'))),const SizedBox(width:10),Expanded(child:OutlinedButton.icon(onPressed:()=>Navigator.pushNamed(context,'/transactions'),icon:const Icon(Icons.history),label:const Text('History')))])]);}))); 

  Widget _services()=>Padding(padding:const EdgeInsets.fromLTRB(18,8,18,12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Padding(padding:EdgeInsets.only(bottom:12),child:Text('Our Services',style:TextStyle(color:Colors.white,fontSize:22,fontWeight:FontWeight.w900))),GridView.count(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),crossAxisCount:4,mainAxisSpacing:14,crossAxisSpacing:10,childAspectRatio:.78,children:[
    _tile(Icons.wifi,'Buy Data',()=>Navigator.pushNamed(context,'/data')),
    _tile(Icons.phone_android,'Buy Airtime',()=>Navigator.pushNamed(context,'/airtime')),
    _tile(Icons.currency_exchange,'Airtime to Cash',()=>Navigator.pushNamed(context,'/airtime-to-cash'),hot:true),
    _tile(Icons.sim_card,'Buy SIMs',_simDialog),
    _tile(Icons.swap_horiz,'SIM Swap',_simDialog),
    _tile(Icons.live_tv,'Cable TV',()=>Navigator.pushNamed(context,'/cable-tv')),
    _tile(Icons.school,'Education',()=>Navigator.pushNamed(context,'/education')),
    _tile(Icons.app_registration,'Registration',()=>Navigator.pushNamed(context,'/registration')),
    _tile(Icons.bolt,'Electricity',()=>_soon('Electricity')),
    _tile(Icons.home_work_outlined,'Home Service',()=>_openWhatsApp('Hello H.salah Communication, I need home service.')),
    _tile(Icons.account_balance,'Withdraw',()=>_soon('Withdraw')),
    _tile(Icons.person_add_alt_1,'Send to User',()=>_soon('Send to User')),
    _tile(Icons.savings,'Earn',()=>_soon('Earn')),
    _tile(Icons.currency_bitcoin,'Crypto',()=>Navigator.pushNamed(context,'/fund-crypto')),
    _tile(Icons.flight,'Flight',()=>_soon('Flight')),
    _tile(Icons.card_giftcard,'Gift Card',()=>_soon('Gift Card')),
  ])]));

  Widget _tile(IconData icon,String label,VoidCallback tap,{bool hot=false})=>InkWell(onTap:tap,borderRadius:BorderRadius.circular(18),child:Stack(children:[Column(children:[Container(width:58,height:58,decoration:BoxDecoration(color:_panel2,borderRadius:BorderRadius.circular(17),border:Border.all(color:Colors.white10)),child:Icon(icon,color:_gold,size:30)),const SizedBox(height:7),Expanded(child:Text(label,textAlign:TextAlign.center,style:const TextStyle(color:Colors.white,fontSize:12,fontWeight:FontWeight.w700,height:1.1))) ]),if(hot)Positioned(top:-2,right:0,child:Container(padding:const EdgeInsets.symmetric(horizontal:5,vertical:2),decoration:BoxDecoration(color:_gold,borderRadius:BorderRadius.circular(7)),child:const Text('HOT',style:TextStyle(color:_navy,fontSize:8,fontWeight:FontWeight.w900))))]));

  Widget _shop()=>Padding(padding:const EdgeInsets.fromLTRB(18,8,18,0),child:Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:_panel,borderRadius:BorderRadius.circular(20),border:Border.all(color:_gold.withValues(alpha:.3))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Row(children:[Icon(Icons.storefront_outlined,color:_gold),SizedBox(width:9),Text('H.salah Communication',style:TextStyle(color:Colors.white,fontSize:17,fontWeight:FontWeight.w900))]),const SizedBox(height:8),const Text(_shopAddress,style:TextStyle(color:Colors.white70,fontSize:13,height:1.35)),const SizedBox(height:12),Row(children:[Expanded(child:OutlinedButton.icon(onPressed:_openCall,icon:const Icon(Icons.call),label:const Text('0707 777 7636'))),const SizedBox(width:10),Expanded(child:OutlinedButton.icon(onPressed:()=>_openWhatsApp(),icon:const Icon(Icons.chat),label:const Text('09044444921')))])]));

  Widget _bottom()=>NavigationBar(backgroundColor:_navy2,indicatorColor:_gold.withValues(alpha:.16),selectedIndex:0,onDestinationSelected:(i){if(i==1)Navigator.pushNamed(context,'/orders');if(i==2)Navigator.pushNamed(context,'/transactions');if(i==3)Navigator.pushNamed(context,'/wallet');if(i==4)Navigator.pushNamed(context,'/profile');},destinations:const[NavigationDestination(icon:Icon(Icons.home_outlined,color:Colors.white60),selectedIcon:Icon(Icons.home,color:_gold),label:'Home'),NavigationDestination(icon:Icon(Icons.receipt_long_outlined,color:Colors.white60),label:'Orders'),NavigationDestination(icon:Icon(Icons.swap_horiz,color:Colors.white60),label:'Transactions'),NavigationDestination(icon:Icon(Icons.account_balance_wallet_outlined,color:Colors.white60),label:'Wallet'),NavigationDestination(icon:Icon(Icons.person_outline,color:Colors.white60),label:'Profile')]);

  void _soon(String name)=>ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('$name is not connected yet.')));
  void _simDialog()=>showDialog<void>(context:context,builder:(_)=>AlertDialog(title:const Text('SIM Services'),content:const Text('MTN, Airtel, Glo and T2 SIM sales and supported SIM-swap assistance are available through H.salah Communication.'),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Close')),ElevatedButton.icon(onPressed:(){Navigator.pop(context);_openWhatsApp('Hello H.salah Communication, I want to buy a SIM or request SIM swap.');},icon:const Icon(Icons.chat),label:const Text('WhatsApp'))]));
}

class _BrandMark extends StatelessWidget{const _BrandMark();@override Widget build(BuildContext context)=>Container(width:42,height:42,decoration:BoxDecoration(color:_gold,borderRadius:BorderRadius.circular(12)),child:const Center(child:Text('HK',style:TextStyle(color:_navy,fontWeight:FontWeight.w900,fontSize:17))));}
