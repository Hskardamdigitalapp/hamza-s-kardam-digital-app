import 'package:flutter/material.dart';
import '../services/wallet_service.dart';

class DataScreen extends StatefulWidget {
  const DataScreen({super.key});
  @override State<DataScreen> createState()=>_DataScreenState();
}

class _DataScreenState extends State<DataScreen>{
  final _formKey=GlobalKey<FormState>(); final _phone=TextEditingController();
  String _network='MTN'; bool _loadingPlans=true; bool _buying=false; List<Map<String,dynamic>> _plans=[]; Map<String,dynamic>? _selected;
  @override void initState(){super.initState();_loadPlans();}
  @override void dispose(){_phone.dispose();super.dispose();}
  Future<void> _loadPlans() async {setState(()=>_loadingPlans=true);try{final plans=await WalletService.getDataPlans(_network);if(!mounted)return;setState((){_plans=plans;_selected=plans.isEmpty?null:plans.first;});}catch(e){if(!mounted)return;setState((){_plans=[];_selected=null;});ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Unable to load data plans: $e')));}finally{if(mounted)setState(()=>_loadingPlans=false);}}
  Future<void> _submit() async {
    if(!_formKey.currentState!.validate()||_selected==null)return;setState(()=>_buying=true);
    try{final result=await WalletService.buyData(network:_network,phone:_phone.text.trim(),plan:_selected!['name'].toString(),variationCode:_selected!['code'].toString(),amount:double.parse(_selected!['amount'].toString()));if(!mounted)return;final status=result['status']?.toString()??'processing';ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(status=='delivered'?'Data delivered successfully.':status=='processing'?'Data order is processing. Check Transactions for updates.':'Data order failed.')));if(status=='delivered'||status=='processing')_phone.clear();}catch(e){if(!mounted)return;ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Unable to buy data: $e')));}finally{if(mounted)setState(()=>_buying=false);}
  }
  @override Widget build(BuildContext context){return Scaffold(appBar:AppBar(title:const Text('Buy Data'),backgroundColor:const Color(0xFF061B49),foregroundColor:Colors.white),body:Form(key:_formKey,child:ListView(padding:const EdgeInsets.all(20),children:[
    const Text('Choose network',style:TextStyle(fontWeight:FontWeight.bold)),const SizedBox(height:8),DropdownButtonFormField<String>(value:_network,items:['MTN','Airtel','Glo','9mobile'].map((n)=>DropdownMenuItem(value:n,child:Text(n))).toList(),onChanged:(v){setState(()=>_network=v??'MTN');_loadPlans();},decoration:const InputDecoration(border:OutlineInputBorder(),prefixIcon:Icon(Icons.network_cell))),
    const SizedBox(height:16),TextFormField(controller:_phone,keyboardType:TextInputType.phone,decoration:const InputDecoration(labelText:'Phone number',border:OutlineInputBorder(),prefixIcon:Icon(Icons.phone)),validator:(v)=>(v==null||v.trim().length<10)?'Enter a valid phone number':null),
    const SizedBox(height:16),const Text('Data plan',style:TextStyle(fontWeight:FontWeight.bold)),const SizedBox(height:8),
    if(_loadingPlans)const Center(child:Padding(padding:EdgeInsets.all(12),child:CircularProgressIndicator())) else if(_plans.isEmpty)const Text('No plans available. Check provider configuration.',style:TextStyle(color:Colors.red)) else DropdownButtonFormField<Map<String,dynamic>>(value:_selected,items:_plans.map((p)=>DropdownMenuItem(value:p,child:Text('${p['name']} — ₦${p['amount']}'))).toList(),onChanged:(v)=>setState(()=>_selected=v),decoration:const InputDecoration(border:OutlineInputBorder(),prefixIcon:Icon(Icons.data_usage)),validator:(v)=>v==null?'Choose a data plan':null),
    const SizedBox(height:22),SizedBox(height:52,child:FilledButton.icon(onPressed:_buying||_loadingPlans||_selected==null?null:_submit,icon:const Icon(Icons.shopping_cart_checkout),label:Text(_buying?'Processing...':'Buy Data'))),
    const SizedBox(height:14),const Text('Plans and prices come from the connected VTU provider. Failed provider transactions are automatically refunded.',style:TextStyle(color:Colors.black54)),
  ])));}
}
