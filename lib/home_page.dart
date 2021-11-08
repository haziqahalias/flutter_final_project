import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'createpost.dart';

class HomePage extends StatefulWidget {
  HomePage({required this.channel, Key? key}) : super(key: key);

  WebSocketChannel channel;

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int pageNum = 1;
  bool isPageLoading = false;
  late StreamSubscription _myStream;
  dynamic decodedResults;
  List _posts = [];
  List _lists = [];
  List _favPost = [];

  @override
  initState() {
    super.initState();
    _myStream = widget.channel.stream.listen((results) {
      decodedResults = jsonDecode(results);
      if (decodedResults['type'] == 'all_posts') {
        _lists = decodedResults['data']['posts'];
        _posts = _lists.reversed.toList();
      }
      setState(() {});
    });
    _getPosts();
  }

  void onUnfavourite(id) {
    setState(() {
      _favPost = _favPost.where((i) => i != id).toList();
    });
  }

  void onFavorite(id) {
    setState(() {
      _favPost.add(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NotStagram'),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      bool isFavorited =
                          _favPost.contains(_posts[index]['_id']);
                      return Card(
                        child: InkWell(
                          hoverColor: Colors.pink[800],
                          child: Row(
                            children: <Widget>[
                              //For Image
                              Container(
                                margin:
                                  const EdgeInsets.fromLTRB(10, 10, 20, 10),
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      image: const DecorationImage(
                                        image: NetworkImage(
                                          "https://dummyimage.com/400x400/f8bbd0/fff&text=NotStagram"),
                                        fit: BoxFit.cover),
                                      borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          "${_posts[index]["image"]}",
                                            errorBuilder: (_1, _2, _3) {
                                              return const SizedBox.shrink();
                                                },
                                            fit: BoxFit.fill),
                                        )
                                  ),
                              Expanded(
                                child: Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 10),
                                        child: Text(
                                          _posts[index]["title"],
                                          style: const TextStyle(
                                              fontSize: 20,
                                              color: Color(0xFF880E4F)),
                                        ),
                                      ),
                                      SizedBox(
                                          height: 85,
                                          child: Text(
                                            _posts[index]["description"],
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF880E4F)),
                                          )),
                                      Container(
                                        margin: const EdgeInsets.only(top: 10),
                                        child: Text(
                                          "Written by ${_posts[index]["author"]}",
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF880E4F)),
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(top: 10),
                                        child: Text(
                                          "${_posts[index]["date"]}",
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontStyle: FontStyle.italic,
                                              color: Color(0xFF880E4F)),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              // For favorite & delete post
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  // to delete
                                  IconButton(
                                      onPressed: () {
                                        widget.channel.sink.add(
                                            '{"type": "delete_post", "data": {"postId": "${_posts[index]['_id']}"}}');
                                        print(
                                            'ID: ${_posts[index]['_id']} is deleted ');
                                        setState(() {
                                          _posts.indexOf(_posts[index]);
                                          _posts.removeAt(index);
                                        });
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                        color:Color(0xFF880E4F)
                                      )
                                    ),

                                  // to favorite & unfavorite
                                  IconButton(
                                      onPressed: () {
                                        setState(() {
                                          if (isFavorited) {
                                            _favPost
                                                .remove(_posts[index]['_id']);
                                          } else {
                                            _favPost.add(_posts[index]['_id']);
                                          }
                                        }
                                      );
                                    },
                                    icon: Icon(
                                     isFavorited
                                       ? Icons.favorite
                                      : Icons.favorite_border,
                                    color: isFavorited
                                      ? Colors.pink[800]
                                      : null,
                                  )
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _toCreatePost,
        tooltip: 'Create a post',
        icon: const Icon(Icons.add),
        label: const Text('Create Post'),
        backgroundColor: Colors.pink[800],
      ),
    );
  }

  void _getPosts() {
    widget.channel.sink.add('{"type": "get_posts"}');
  }

  void _toCreatePost() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CreatePost(createChannel: widget.channel)));
  }

  @override
  void dispose() {
    _myStream.cancel();
    super.dispose();
  }
}
