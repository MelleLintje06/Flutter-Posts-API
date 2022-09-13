import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:async/async.dart';

void main() {
  runApp(const MyApp());
}

List postList = [];
List userList = [];
int _index = 0;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // Hide the debug banner
      debugShowCheckedModeBanner: false,
      title: 'Post API',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> _fetchData() async {
    const baseURL = 'https://jsonplaceholder.typicode.com';
    const posts = '/posts';
    const users = '/users';

    HttpClient client = HttpClient();
    client.autoUncompress = true;

    // Posts
    final HttpClientRequest postRequest =
        await client.getUrl(Uri.parse(baseURL + posts));
    postRequest.headers
        .set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
    final HttpClientResponse postResponse = await postRequest.close();

    final String postContent =
        await postResponse.transform(utf8.decoder).join();
    final List postData = json.decode(postContent);

    // Users
    final HttpClientRequest userRequest =
        await client.getUrl(Uri.parse(baseURL + users));
    userRequest.headers
        .set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
    final HttpClientResponse userResponse = await userRequest.close();

    final String userContent =
        await userResponse.transform(utf8.decoder).join();
    final List userData = json.decode(userContent);

    setState(() {
      postList = postData;
      userList = userData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Flutter Posts | Tutorial',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: SafeArea(
        child: postList.isEmpty
            ? Center(
                child: ElevatedButton(
                  onPressed: _fetchData,
                  child: const Text('Load Posts'),
                ),
              )
            : ListView.builder(
                itemCount: postList.length,
                itemBuilder: (BuildContext ctx, index) {
                  return ListTile(
                    onTap: () {
                      _index = index;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PostDetails()),
                      );
                    },
                    isThreeLine: true,
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const <Widget>[
                        Icon(
                          Icons.article,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                    title: Text(
                      "${postList[index]['title']}",
                      style: const TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Hero(
                          tag: 'message-${postList[index]['id']}',
                          child: Material(
                            child: Text(
                              '${postList[index]["body"]}',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          '➜ Written by: ${userList[postList[index]['userId'] - 1]['name']}',
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        color: Colors.black,
                        width: .75,
                      ),
                      borderRadius: BorderRadius.circular(1),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class PostDetails extends StatelessWidget {
  const PostDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Text(
            '${postList[_index]['title']}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
          child: Column(
        children: <Widget>[
          // ignore: prefer_const_constructors
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              child: Center(
                child: Hero(
                  tag: 'message-${postList[_index]['id']}',
                  child: Material(
                    child: Text(
                      '${postList[_index]["body"]}',
                      style: const TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Written by: ${userList[postList[_index]['userId'] - 1]['name']}',
                  textAlign: TextAlign.left,
                ),
                Text(
                  'Message Nr: ${postList[_index]['id']}',
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ],
      )),
    );
  }
}
