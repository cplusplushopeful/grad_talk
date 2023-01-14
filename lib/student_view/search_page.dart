import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grad_talk/database_services.dart';
import 'package:grad_talk/student_view/pages.dart';
import 'package:grad_talk/student_view/student_widgets/student_widgets.dart';

import '../theme.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    Key? key,
  }) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  /*
  This is the structure:
  Search bar, next to search bar there will be a dropdown where the user can choose to search major
  or a specific college. Then, accordingly the stream builder will change.
   */
  String keyword = "";
  String selectedItem = "major";
  List<DropdownMenuItem<String>> get searchDropdown{
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(value: "major", child: Text("major")),
      const DropdownMenuItem(value: "college", child: Text("college")),
    ];
    return menuItems;
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      drawer: StudentNavBar(),
      appBar: AppBar(
        title: Text("Find new mentors")
      ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search), hintText: 'Search a major or university'),
                onChanged: (value) {
                  setState(() {
                    keyword = value;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: DropdownButtonFormField<String>(
                value: selectedItem,
                onChanged: (String? newValue){
                  setState((){
                    selectedItem = newValue!;
                  });
                },
                items: searchDropdown,
              ),
            ),
            Flexible(
              child: StreamBuilder<QuerySnapshot>(
                stream: (keyword != "")
                    ? FirebaseFirestore.instance.collection('users')
                    .where('role', isEqualTo: "Mentor")
                    .where('currentlyConnected', isEqualTo: false)
                    .where('muted', isEqualTo: false)
                    .where('${selectedItem}Combination', arrayContains: keyword.toLowerCase())
                    .snapshots()
                    : FirebaseFirestore.instance.collection("users")
                      .where('role', isEqualTo: "Mentor")
                      .where('currentlyConnected', isEqualTo: false)
                      .snapshots(),
                builder: (context, snapshots){
                  return (snapshots.connectionState == ConnectionState.waiting)
                      ? const Center(child: CircularProgressIndicator())
                      :ListView.builder(
                      itemCount: snapshots.data?.docs.length,
                      itemBuilder: (context, index) {
                        var data = snapshots.data!.docs[index].data() as Map<
                            String,
                            dynamic>;
                          return ListTile(
                            leading: FloatingActionButton(
                              child: const Text("View"),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => SearchProfile(mentorID: data['uid'], career: data['career'],
                                        college: data['college'], description: data['description'],
                                        extracurriculars: data['extracurriculars'], major: data['major'],
                                        name: data['name'], scores: data['scores'], transcript: data['transcript'],
                                        year: data['year'])
                                ));
                              },
                            ),
                            title: Text(
                              data['name'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                            trailing: Text(
                              data['college'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                            subtitle: Text(
                              data['major'],
                              maxLines: 7,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textFaded
                              ),
                            ),
                          );
                      }
                  );
                },

              ),
            ),
          ],
        )


    );
  }



}


/*  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: StudentNavBar(),
        appBar: AppBar(
          title: Card(
            child: TextField(
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search), hintText: 'Search a major or university'),
                onChanged: (val) {
                  setState((){
                    name = val;
                  });
                }
              ),
            ),
          ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users')
              .where('role', isEqualTo: 'Mentor').snapshots(),
          builder: (context, snapshots){
            return (snapshots.connectionState == ConnectionState.waiting)
                ?Center(child: CircularProgressIndicator())
                :ListView.builder(
                itemBuilder: (context, index){
                  var data = snapshots.data!.docs[index].data() as Map<String, dynamic>;
                  if(name.isEmpty){
                    return ListTile(
                      leading: FloatingActionButton(
                        child: Text("Add"),
                        onPressed: () {
                          DatabaseService().createGroup(data['uid'], FirebaseAuth.instance.currentUser!.uid);

                        },
                      ),
                      title: Text(
                        data['name'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      trailing: Text(
                        data['college'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      subtitle: Text(
                        data['description'],
                        maxLines: 7,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textFaded
                        ),
                      ),
                    );
                  }
                  else if(data['major'].toString().startsWith(name.toLowerCase())){
                    return ListTile(
                      leading: FloatingActionButton(
                        child: Text("Add"),
                        onPressed: () {
                          DatabaseService().createGroup(data['uid'], FirebaseAuth.instance.currentUser!.uid);

                        },
                      ),
                      title: Text(
                        data['name'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      trailing: Text(
                        data['college'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      subtitle: Text(
                        data['description'],
                        maxLines: 7,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                            color: AppColors.textFaded

                        ),
                      ),

                    );
                  }
                  else if(data['college'].toString().startsWith(name.toLowerCase())){
                    return ListTile(
                      leading: FloatingActionButton(
                        child: Text("Add"),
                        onPressed: () {
                          DatabaseService().createGroup(data['uid'], FirebaseAuth.instance.currentUser!.uid);

                        },
                      ),
                      title: Text(
                        data['name'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      trailing: Text(
                        data['college'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      subtitle: Text(
                        data['major'],
                        maxLines: 7,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textFaded

                        ),
                      ),

                    );
                  }
                  else if(data['name'].toString().startsWith(name.toLowerCase())){
                    return ListTile(
                      leading: FloatingActionButton(
                        child: Text("Add"),
                        onPressed: () {
                          DatabaseService().createGroup(data['uid'], FirebaseAuth.instance.currentUser!.uid);

                        },
                      ),
                      title: Text(
                        data['name'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      trailing: Text(
                        data['college'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      subtitle: Text(
                        data['description'],
                        maxLines: 7,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textFaded

                        ),
                      ),

                    );
                  }
                  return Text("No search results");
                }
            );
          },

      )


    );
*/