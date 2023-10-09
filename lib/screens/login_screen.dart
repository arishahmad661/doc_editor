import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs/colors.dart';
import 'package:google_docs/repository/auth_repository.dart';
import 'package:google_docs/screens/home_screen.dart';
import 'package:routemaster/routemaster.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  void signInWithGoogle(WidgetRef ref, BuildContext context)async{
    //do not use build context across asu.comync apps
    //to avoid that we use this
    final sMessenger = ScaffoldMessenger.of(context);
    final navigator = Routemaster.of(context);
    final errorModel = await ref.read(authRepositoryProvider).signInwithGoogle();
    if(errorModel.error == null){
      ref.read(userProvider.notifier).update((state) => errorModel.data);
      navigator.replace('/');
    }else{
      sMessenger.showSnackBar(
          SnackBar(content: Text(errorModel.error!))
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
            onPressed: (){signInWithGoogle(ref, context);},
            icon: Image.asset("images/g-logo-2.png", height: 20,),
            label: const Text(
                "Sign in with Google",
              style: TextStyle(color: kBlackColor),
            ),
          style: ElevatedButton.styleFrom(
            backgroundColor: kWhiteColor,
            maximumSize: const Size(200,50)
          ),
        ),
      ),
    );
  }
}
