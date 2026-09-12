import 'package:flutter/material.dart';

const _bg = Color(0xFF061B49);
const _panel = Color(0xFF0A2C68);
const _gold = Color(0xFFB8860B);

class CableTvScreen extends StatefulWidget { const CableTvScreen({super.key}); @override State<CableTvScreen> createState() => _CableTvScreenState(); }
class _CableTvScreenState extends State<CableTvScreen> {
  final _smartCard = TextEditingController();
  String _provider = 'DStv';
  bool _save = false;
  @override void dispose(){ _smartCard.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: _bg,
    appBar: AppBar(backgroundColor: _bg, foregroundColor: Colors.white, elevation: 0, leading: IconButton(onPressed: ()=>Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new)), title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Cable TV', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)), Text('DSTV, GOtv, Startimes & Showmax', style: TextStyle(color: Colors.white60, fontSize: 14))]), actions: [TextButton.icon(onPressed: (){}, icon: const Icon(Icons.history, color: _gold), label: const Text('History', style: TextStyle(color: _gold))) ]),
    body: ListView(padding: const EdgeInsets.all(22), children: [
      _hero(), const SizedBox(height: 20), _input(), const SizedBox(height: 25), const Text('SELECT PROVIDER', style: TextStyle(color: Colors.white60, fontWeight: FontWeight.w900, letterSpacing: 1.2)), const SizedBox(height: 12),
      Row(children: [_providerCard('DStv','https://www.dstv.com/favicon.ico'), const SizedBox(width: 10), _providerCard('GOtv','https://www.gotvafrica.com/favicon.ico'), const SizedBox(width: 10), _providerCard('Startimes','https://www.startimestv.com/favicon.ico')]), const SizedBox(height: 18),
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(20)), child: Row(children: [const Icon(Icons.bookmark, color: _gold), const SizedBox(width: 12), const Expanded(child: Text('Save as Beneficiary', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800))), Switch(value: _save, activeColor: _gold, onChanged: (v)=>setState(()=>_save=v))])),
    ]),
  );
  Widget _hero()=>Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(gradient: const LinearGradient(colors: [_panel,_bg]), borderRadius: BorderRadius.circular(25), border: Border.all(color: _gold)), child: Row(children: [const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Cable TV', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)), SizedBox(height: 7), Text('Renew or top up your subscription in seconds.', style: TextStyle(color: Colors.white70, fontSize: 16))])), Container(width: 75,height:75,decoration: const BoxDecoration(color:_gold,shape:BoxShape.circle),child:const Icon(Icons.live_tv,color:_bg,size:40))]));
  Widget _input()=>Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:_panel,borderRadius:BorderRadius.circular(22)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[const Expanded(child:Text('Smart Card / IUC Number',style:TextStyle(color:Colors.white,fontWeight:FontWeight.w900,fontSize:16))),TextButton(onPressed:(){},child:const Text('Beneficiaries',style:TextStyle(color:_gold)))]),TextField(controller:_smartCard,keyboardType:TextInputType.number,style:const TextStyle(color:Colors.white),decoration:InputDecoration(hintText:'Enter Smart Card / IUC Number',hintStyle:const TextStyle(color:Colors.white38),filled:true,fillColor:_bg,border:OutlineInputBorder(borderSide:BorderSide.none,borderRadius:BorderRadius.all(Radius.circular(16)))))]));
  Widget _providerCard(String name,String logo){final selected=_provider==name;return Expanded(child:InkWell(onTap:()=>setState(()=>_provider=name),borderRadius:BorderRadius.circular(18),child:Container(height:125,padding:const EdgeInsets.all(10),decoration:BoxDecoration(color:_panel,borderRadius:BorderRadius.circular(18),border:Border.all(color:selected?_gold:Colors.white10,width:selected?2:1)),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Container(width:42,height:42,color:Colors.white,child:Image.network(logo,fit:BoxFit.contain,errorBuilder:(_,__,___)=>Center(child:Text(name[0],style:const TextStyle(color:_bg,fontWeight:FontWeight.w900))))),const SizedBox(height:9),Text(name,style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w800))]))));}
}
