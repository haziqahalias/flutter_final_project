import 'package:flutter/material.dart';
import 'package:final_project/home_page.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:final_project/cubit/cubit_signin.dart';
import 'package:flutter/foundation.dart';



void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //Material A
      title: "NotStagram",
      theme: ThemeData(
        primarySwatch: Colors.pink),
      home: BlocProvider(
        create: (_) => SignInCubit(),
        child: const SignIn()),
    );
  }
}

class SignIn extends StatefulWidget {
  const SignIn({
    Key? key}) : super(key: key);


  @override
  SignInState createState() => SignInState();
}

class SignInState extends State<SignIn> {

  final channel = WebSocketChannel.connect(
    Uri.parse('ws://besquare-demo.herokuapp.com'),
  );

  final TextEditingController _controller = TextEditingController();

  String _name = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NotStagram'),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.pink[200],
        child: Stack(
          children: <Widget>[
            const Align(
              alignment: Alignment.bottomRight,
              heightFactor: 0.5,
              widthFactor: 0.5,
              child: Material(
                borderRadius: BorderRadius.all(Radius.circular(200.0)),
                color: Color(0xFFB2EBF2),
                child: SizedBox(
                  width: 400,
                  height: 400,
                ),
              ),
            ),
            const Align(
              alignment: Alignment.bottomRight,
              heightFactor: 0.5,
              widthFactor: 0.5,
              child: Material(
                borderRadius: BorderRadius.all(Radius.circular(200.0)),
                color: Color(0xFFAD1457),
                child: SizedBox(
                  width: 200,
                  height: 200,
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: BlocBuilder<SignInCubit, String>(
                bloc: context.read<SignInCubit>(),
                builder: (context, state) {
                  return Center(
                    child: SizedBox(
                    width: 400,
                    height: 400,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                    Image.asset(
                            "assets/icon.png",
                            width: 100,
                            height: 100,
                          ),
                      Form(
                        child: TextFormField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                            hintText: 'Username please!',
                            fillColor: Color(0xFFFCE4EC),
                            filled: true,
                          ),
                          onChanged: (String value) => _name = value,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 15),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(150, 50),
                            primary: Colors.pink[800],
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),),
                            onPressed: _signIn,
                            child: const Text(
                              'Sign In',
                              style: TextStyle(fontSize: 16),
                              )
                            ),
                          ),
                        ]
                      ),
                    ),
                  );
                }
              ) 
            ),
          ),
        ]
      )
    )
  );
}

  void _toHomePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage(channel: channel)),
    );
  }

  void _signIn() {
    if (_controller.text.isNotEmpty) {
      channel.sink.add('{"type": "sign_in","data": {"name": "${_controller.text}"}}');
      print('${_controller.text} sign in success');
      _controller.clear();
      _toHomePage();
    }
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }
}

