
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


import '../theme.dart';

//Displays all the review that a mentor has received along with an average rating
class ViewReviewPage extends StatefulWidget {
  final String mentorID;
  final num average;
  final num numRatings;

  const ViewReviewPage({
    required this.mentorID,
    required this.average,
    required this.numRatings,
    Key? key,
  }) : super(key: key);


  @override
  State<ViewReviewPage> createState() => _ViewReviewPageState();
}

class _ViewReviewPageState extends State<ViewReviewPage> {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("All Reviews")
      ),
        body: Column(
          children: [
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Text(
                "Overall rating: ${widget.average.toStringAsFixed(1)}",
                style: const TextStyle(
                  fontSize: 16
                ),
              ),
            ),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                    "Number of ratings: ${widget.numRatings.round()}",
                    style: const TextStyle(
                        fontSize: 16
                    ),
                )
            ),
            SizedBox(height: 10),
            Flexible(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection("users")
                      .doc(widget.mentorID)
                      .collection('reviews').orderBy("time", descending: true)
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
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Text(
                                "Rating: ${data['rating']} / 5",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              subtitle: Text(
                                data['review'],
                                maxLines: 100,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: GradTalkColors.fadedText
                                ),
                              ),
                              minVerticalPadding: 5,
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