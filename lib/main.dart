import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

// List of all posts.
List postList = [];
// List of all writers.
List userList = [];
// List of all comments of post
List commentList = [];
// Selected index for details page.
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
  var baseURL = 'https://jsonplaceholder.typicode.com';
  HttpClient client = HttpClient();

  Future<void> _fetchData() async {
    const posts = '/posts';
    const users = '/users';

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

  Future<void> _fetchComments(int id) async {
    var comments = "/comments?postId=${id.toString()}";
    debugPrint(comments);
    final HttpClientRequest commentRequest =
        await client.getUrl(Uri.parse(baseURL + comments));
    commentRequest.headers
        .set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
    final HttpClientResponse commentsResponse = await commentRequest.close();

    final String commentsContent =
        await commentsResponse.transform(utf8.decoder).join();
    final List commentsData = json.decode(commentsContent);
    setState(() {
      commentList = [];
      commentList = commentsData;
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
                      // Get comments of the post
                      _fetchComments(postList[_index]['id']);
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
                        // Put a max height on the 'body' of the object
                        LimitedBox(
                          // Makes an animation on the 'body' of the object when you press it
                          child: Hero(
                            tag: 'post-${postList[index]['id']}',
                            child: Material(
                              child: Text(
                                '${postList[index]["body"]}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          '➜ Written by ${userList[postList[index]['userId'] - 1]['name']}',
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
              alignment: Alignment.center,
              margin: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Hero(
                      tag: 'post-${postList[_index]['id']}',
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
                  Container(
                    alignment: Alignment.center,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(children: <InlineSpan>[
                        const TextSpan(
                          text: '\nReactions:\n',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                        for (var comment in commentList)
                          TextSpan(
                            text: "${comment['name']}:\n${comment['body']}\n\n",
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 11,
                            ),
                          ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  //  Because postList[_index]['userId'] and the order of the API is ordered by ID it created with - 1 so the order of the objects from the users is good
                  'Written by ${userList[postList[_index]['userId'] - 1]['name']}',
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
