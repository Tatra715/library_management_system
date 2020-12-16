import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:library_management_system/Screens/admin_screen.dart';
import 'package:library_management_system/Screens/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';

// The Login Page is the Main Gateway To The App.
// It takes the already Registered user to the home screen or the admin screen depending upon isAdmin.
class Login extends StatefulWidget {
  static String id = 'login';
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String emailAddress;
  String password;
  bool isAdmin = true;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  bool ignore = false;

  // This Function Checks whether the current user is admin or not.
  // It accesses the admin collection in firestore and checks if their is any entry with the current emailAddress.
  // It returns false and then uses setState to change isAdmin to new value, if the user has no entry in admin collection means the user is not an admin.
  Future adminCheck() async {
    try{
      final userData =
      await _firestore.collection('admin').doc(emailAddress).get();
      if (userData.data() == null) {
        setState(() {
          isAdmin = false;
        });
      }
    }catch(e){
      setState(() {
        ignore = false;
      });
      Fluttertoast.showToast(msg: e.toString(),);
    }
  }

  void checkVerified() async {
    if(isAdmin){
      Navigator.pushNamed(
          context, AdminScreen.id);
      setState(() {
        ignore = false;
      });
    }
    else{
      final user = _auth.currentUser;
      if(!user.emailVerified){
        Fluttertoast.showToast(msg: 'Email Not Verified');
        setState(() {
          ignore = false;
        });
      }
      else{
        Navigator.pushNamed(
            context, HomeScreen.id);
      }
    }
  }

  void resetPassword() async {
    if(emailAddress == null){
      Fluttertoast.showToast(msg: 'Enter A Valid Email');
    }
    else{
      try{
        _auth.sendPasswordResetEmail(email: emailAddress);
        Fluttertoast.showToast(msg: 'Password reset link send to $emailAddress',timeInSecForIosWeb: 2);
      }catch(e){
        Fluttertoast.showToast(msg: e.toString());
      }
    }
  }

  void sendVerification() async {
    if(emailAddress == null || password == null){
      Fluttertoast.showToast(msg: 'Enter Email And Password',timeInSecForIosWeb: 2);
    }
    else{
      try{
        final newUser = await _auth.signInWithEmailAndPassword(
            email: emailAddress, password: password);
        if (newUser != null) {
          final user = _auth.currentUser;
          await user.sendEmailVerification();
          Fluttertoast.showToast(msg: 'Verification email Send');
        }
      }catch(e){
        Fluttertoast.showToast(msg: e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage('images/Login.jpg'),fit: BoxFit.scaleDown,alignment: Alignment.lerp(Alignment.bottomCenter, Alignment.center, 0.35)),
          color: Colors.white,
          ),
        child: ListView(
          children: [
            Container(
              margin: EdgeInsets.only(left: 60,right:60,top: 100),
              child: TextFormField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email,size: 18.0,color: Color(0Xff6B63FF),),
                  labelText: "Enter Email",
                  labelStyle: GoogleFonts.montserrat(
                    color: Colors.black,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                validator: (val) {
                  if(val.length==0) {
                    return "Email cannot be empty";
                  }else{
                    return null;
                  }
                },
                keyboardType: TextInputType.emailAddress,
                style: GoogleFonts.montserrat(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
                onChanged: (value) {
                  emailAddress = value == '' ? null : value;
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 60,right:60,top: 25),
              child: TextFormField(
                obscureText: true,
                decoration: new InputDecoration(
                  prefixIcon: Icon(Icons.vpn_key,size: 18.0,color: Color(0Xff6B63FF),),
                  labelText: "Enter Password",
                  labelStyle: GoogleFonts.montserrat(
                    color: Colors.black,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                validator: (val) {
                  if(val.length==0) {
                    Fluttertoast.showToast(msg: 'Password cannot be empty',);
                    return "Password cannot be empty";
                  }else{
                    return null;
                  }
                },
                style: GoogleFonts.montserrat(
                  color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
                onChanged: (value) {
                  password = value == '' ? null : value;
                },
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10.0,horizontal: 75.0),
              decoration: BoxDecoration(
                color: Colors.deepPurpleAccent.withOpacity(0.6),
                borderRadius: BorderRadius.circular(25.0),
                border: Border.all(color: Colors.deepPurple.shade800,width: 4.0),
              ),
              child: IgnorePointer(
                ignoring: ignore,
                child: FlatButton(
                  child: Text('Login',
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: 'Cubano',
                      color: Colors.deepPurple.shade800,
                    ),
                  ),
                  onPressed: () async {
                    // The Function here logs users in with the help of Firebase Authorization.
                    // )n the basis of isAdmin user is sent to the admin screen or the home screen using ternary statement.
                    try {
                      setState(() {
                        ignore = true;
                      });
                      final newUser = await _auth.signInWithEmailAndPassword(
                          email: emailAddress, password: password);
                      if (newUser != null) {
                        // print('Login Successful');
                        await adminCheck();
                        checkVerified();
                      }
                    } catch (e) {
                      Fluttertoast.showToast(msg: e.toString(),);
                      setState(() {
                        ignore = false;
                      });
                    }
                  },
                ),
              ),
            ),
            FlatButton(
              child: Text('Didn\'t get a verification email'),
              onPressed: sendVerification,
            ),
            FlatButton(
              child: Text('Forgot Password'),
              onPressed: (){
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Enter email Address'),
                    content: TextFormField(
                      onChanged: (value){
                        emailAddress = value == '' ? null : value;
                      },
                    ),
                    actions: [
                      FlatButton(
                        onPressed: () {
                          resetPassword();
                          Navigator.pop(context);
                        },
                        child: Text('Send'),
                      ),
                      FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Cancel'),
                      ),
                    ],
                    elevation: 20.0,
                  ),
                  barrierDismissible: true,
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
