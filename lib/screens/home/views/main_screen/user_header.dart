import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expense_repository/expense_repository.dart';

class UserHeader extends StatelessWidget {
  final User? userGoogle;
  final Future<UserModel?>? futureUserModel;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const UserHeader({
    required this.userGoogle,
    required this.futureUserModel,
    required this.scaffoldKey,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => scaffoldKey.currentState?.openDrawer(),
              child: userGoogle?.photoURL != null
                  ? CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(userGoogle!.photoURL!),
                    )
                  : Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.yellow[700],
                      ),
                      child: Icon(
                        CupertinoIcons.person_fill,
                        color: Colors.yellow[800],
                      ),
                    ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<UserModel?>(
                  future: futureUserModel,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(strokeWidth: 2);
                    } else if (snapshot.hasData && snapshot.data != null) {
                      final user = snapshot.data!;
                      return Text(
                        user.name.split(' ').take(2).join(' '),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      );
                    } else {
                      return const Text("Usuário");
                    }
                  },
                )
              ],
            ),
          ],
        ),
      ],
    );
  }
}
