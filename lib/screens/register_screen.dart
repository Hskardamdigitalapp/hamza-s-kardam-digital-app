import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _navy = Color(0xFF061B49);
const _navy2 = Color(0xFF0A2C68);
const _gold = Color(0xFFC89B3C);

class RegisterScreen extends StatefulWidget { const RegisterScreen({super.key}); @override State<RegisterScreen> createState() => _RegisterScreenState(); }
class _RegisterScreenState extends State<RegisterScreen> {
  final nameController=TextEditingController(), phoneController=TextEditingController(), emailController=TextEditingController(), passwordController=TextEditingController();
  bool loading=false, obscurePassword=true;
  Future<void> register() async {
    final name=nameController.text.trim(), phone=phoneController.text.trim(), email=emailController.text.trim(), password=passwordController.text;
    if(name.isEmpty||phone.isEmpty||email.isEmpty||password.isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Please fill all fields.')));return;}
    if(password.length<6){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Password must be at least 6 characters.')));return;}
    setState(()=>loading=true);
    try{
      final response=await Supabase.instance.client.auth.signUp(email:email,password:password,data:{'full_name':name,'phone':phone});
      if(!mounted)return;
      if(response.session!=null){Navigator.pushReplacementNamed(context,'/home');}else{ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Registration successful. Please check your email to verify your account.')));}
    }on AuthException catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e.message)));}
    catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Registration failed: $e')));}
    finally{if(mounted)setState(()=>loading=false);}
  }
  @override void dispose(){nameController.dispose();phoneController.dispose();emailController.dispose();passwordController.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>Scaffold(
    backgroundColor:const Color(0xFFF5F7FB),
    appBar:AppBar(title:const Text('Create Account'),backgroundColor:_navy,foregroundColor:Colors.white),
    body:SafeArea(child:SingleChildScrollView(padding:const EdgeInsets.all(24),child:Column(children:[
      const SizedBox(height:18),
      Container(width:78,height:78,decoration:BoxDecoration(gradient:const LinearGradient(colors:[_navy2,_navy]),borderRadius:BorderRadius.circular(21),border:Border.all(color:_gold)),child:const Center(child:Text('HK',style:TextStyle(color:_gold,fontSize:22,fontWeight:FontWeight.w900)))),
      const SizedBox(height:16),const Text('HAMZA S. KARDAM DIGITAL APP',textAlign:TextAlign.center,style:TextStyle(color:_navy,fontSize:21,fontWeight:FontWeight.w900)),const SizedBox(height:28),
      _field(nameController,'Full Name',Icons.person_outline),const SizedBox(height:16),_field(phoneController,'Phone Number',Icons.phone_outlined,type:TextInputType.phone),const SizedBox(height:16),_field(emailController,'Email',Icons.email_outlined,type:TextInputType.emailAddress),const SizedBox(height:16),
      TextField(controller:passwordController,obscureText:obscurePassword,decoration:_dec('Password',Icons.lock_outline,suffix:IconButton(onPressed:()=>setState(()=>obscurePassword=!obscurePassword),icon:Icon(obscurePassword?Icons.visibility_outlined:Icons.visibility_off_outlined)))),
      const SizedBox(height:24),SizedBox(width:double.infinity,height:54,child:ElevatedButton(onPressed:loading?null:register,style:ElevatedButton.styleFrom(backgroundColor:_navy,foregroundColor:Colors.white,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(14))),child:loading?const SizedBox(width:24,height:24,child:CircularProgressIndicator(strokeWidth:2,color:_gold)):const Text('CREATE ACCOUNT',style:TextStyle(fontWeight:FontWeight.w900)))),
      const SizedBox(height:12),TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Already have an account? Login',style:TextStyle(color:_gold,fontWeight:FontWeight.w900))),
    ]))),
  );
  Widget _field(TextEditingController c,String label,IconData icon,{TextInputType? type})=>TextField(controller:c,keyboardType:type,decoration:_dec(label,icon));
  InputDecoration _dec(String label,IconData icon,{Widget? suffix})=>InputDecoration(labelText:label,prefixIcon:Icon(icon,color:_navy),suffixIcon:suffix,filled:true,fillColor:Colors.white,border:OutlineInputBorder(borderRadius:BorderRadius.circular(14),borderSide:BorderSide.none),focusedBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(14),borderSide:const BorderSide(color:_gold,width:1.5)));
}
