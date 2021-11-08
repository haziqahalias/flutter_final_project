import 'package:final_project/cubit/cubit_createpost.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:final_project/home_page.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class CreatePost extends StatelessWidget {
  CreatePost({Key? key, required this.createChannel}) : super(key: key);

  WebSocketChannel createChannel;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: BlocProvider(
        create: (_) => CreatePostCubit(),
        child: CreatePostPage(createChannel: createChannel),
      ),
    );
  }
}

class CreatePostPage extends StatefulWidget {
  CreatePostPage({Key? key, required this.createChannel}) : super(key: key);
  
  WebSocketChannel createChannel;

  @override
  CreatePostPageState createState() => CreatePostPageState();
}

class CreatePostPageState extends State<CreatePostPage> {

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageURLController = TextEditingController();

  String _title = "";
  String _description = "";
  String _ImageURL = "";

  postCreated() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Your post has been sent out into the wild! (ﾉ◕ヮ◕)ﾉ*:･ﾟ✧	',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Post'),
      ),
      body: SafeArea(
        child: Center(
          child: BlocBuilder<CreatePostCubit, String>(
            bloc: BlocProvider.of<CreatePostCubit>(context),
            builder: (context, state) {
              return Container(
                margin: const EdgeInsets.only(top: 30),
                width: 350,
                child: Form(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: TextFormField(
                          controller: _titleController,
                          onChanged: (String value) => _title = value,
                          decoration: const InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                            labelText: 'Title',
                            fillColor: Color(0xFFFCE4EC),
                            filled: true,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: TextFormField(
                          controller: _descriptionController,
                          onChanged: (String value) => _description = value,
                          decoration: const InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                            labelText: 'Description',
                            fillColor: Color(0xFFFCE4EC),
                            filled: true,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: TextFormField(
                          controller: _imageURLController,
                          onChanged: (String value) => _ImageURL = value,
                          decoration: const InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                            labelText: 'Image URL',
                            fillColor: Color(0xFFFCE4EC),
                            filled: true,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(350, 40),
                            primary: Colors.pink[800],
                          ),
                          onPressed: _createPost,
                          child: const Text(
                            'Create Post',
                            style: TextStyle(fontSize: 16),
                          )
                        ),
                      ),
                    ],
                  )
                ),
              );
            }
          )
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toHomePage,
        child: const Icon(Icons.arrow_back_rounded, color: Colors.white,),
        backgroundColor: Colors.pink[800],
      )
    );
  }

  void _toHomePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage(channel: widget.createChannel)),
    );
  }

  void _createPost() {
    if (_titleController.text.isNotEmpty && _descriptionController.text.isNotEmpty && _imageURLController.text.isNotEmpty ) {
      widget.createChannel.sink.add('{"type": "create_post","data": {"title": "${_titleController.text}", "description": "${_descriptionController.text}", "image": "${_imageURLController.text}"}}');
      print('New post created!');
      _titleController.clear();
      _descriptionController.clear();
      _imageURLController.clear();
      postCreated();
    }
  }

  @override
  void dispose() {
    widget.createChannel.sink.close();
    super.dispose();
  }
}