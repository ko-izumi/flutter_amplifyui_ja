import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

import 'amplifyconfiguration.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  void _configureAmplify() async {
    try {
      await Amplify.addPlugins([AmplifyAuthCognito()]);
      await Amplify.configure(amplifyconfig);
      debugPrint('Successfully configured');
    } on Exception catch (e) {
      debugPrint('Error configuring Amplify: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Authenticator(
      /// ↓✨✨stringResolverオプションを追加
      stringResolver: stringResolver,
      child: MaterialApp(
        builder: Authenticator.builder(),
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  Future<void> _incrementCounter() async {
    try {
      await Amplify.Auth.signOut();
    } on AuthException catch (e) {
      debugPrint(e.message);
    }
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class CustomButtonResolver extends ButtonResolver {
  const CustomButtonResolver();

  @override

  /// ✨✨ あまりにひどいのが公式がミスしているので注意。
  /// signinとあるが公式通り実装しても反映されないので注意。
  String signIn(BuildContext context) {
    //the text of the signin button can be customized
    return 'ログイン';
  }

  @override
  String signUp(BuildContext context) {
    return 'アカウント作成';
  }

  @override
  String forgotPassword(BuildContext context) {
    return "パスワードを忘れましたか？";
  }

  @override
  String submit(BuildContext context) {
    return "送信";
  }

  @override
  String backTo(BuildContext context, AuthenticatorStep previousStep) {
    return "サインイン画面に戻る";
  }
}

/// Instantiate an InputResolver
class CustomInputResolver extends InputResolver {
  const CustomInputResolver();

  /// Override the title function
  /// Since this function handles the title for numerous fields,
  /// we recommend using a switch statement so that `super` can be called
  /// in the default case.
  @override
  String title(BuildContext context, InputField field) {
    switch (field) {
      case InputField.username:
        return 'ユーザー名';
      case InputField.email:
        return 'メールアドレス';
      case InputField.password:
        return 'パスワード';
      case InputField.passwordConfirmation:
        return 'パスワード再入力';
      default:
        return super.title(context, field);
    }
  }

  @override
  String hint(BuildContext context, InputField field) {
    final fieldName = title(context, field);
    return '$fieldNameを入力してください';
  }

  @override
  String confirmHint(BuildContext context, InputField field) {
    final fieldName = title(context, field);
    return '$fieldNameしてください';
  }

  @override
  String empty(BuildContext context, InputField field) {
    return 'パスワードを空にしたまま登録できません';
  }

  @override
  String resolve(BuildContext context, InputResolverKey key) {
    switch (key.type) {
      case InputResolverKeyType.title:
        return title(context, key.field);
      case InputResolverKeyType.hint:
        return hint(context, key.field);
      case InputResolverKeyType.confirmHint:
        return confirmHint(context, key.field);
      case InputResolverKeyType.empty:
        return empty(context, key.field);
      case InputResolverKeyType.passwordRequirements:
        return passwordRequires(context, key.unmetPasswordRequirements!);

      /// 本当はpasswordRequiresの中身相当の実装が必要だが、簡単のため以下のように記載。
      // return "パスワードは最低8文字以上必要です";
      case InputResolverKeyType.mismatch:

        /// こちらは関数化されていなかったので、直接resolveメソッドを変更
        // return AuthenticatorLocalizations.inputsOf(context).passwordsDoNotMatch;
        return "パスワードが一致しませんでした";
      case InputResolverKeyType.format:
        return format(context, key.field);
    }
  }
}

class CustomTitleResolver extends TitleResolver {
  const CustomTitleResolver();

  /// Override the title function
  /// Since this function handles the title for numerous fields,
  /// we recommend using a switch statement so that `super` can be called
  /// in the default case.
  @override
  String signIn(BuildContext context) {
    return "サインイン";
  }

  @override
  String signUp(BuildContext context) {
    return "アカウント作成";
  }

  @override
  String resetPassword(BuildContext context) {
    return "コード送信";
  }
}

class CustomMessageResolver extends MessageResolver {
  const CustomMessageResolver();

  @override
  String codeSent(BuildContext context, String destination) {
    // ↓✨✨スナックバーの文言を変更
    return "登録用コードを次のメールアドレスに送信しました。$destination";
  }
}

/// Instantiate an AuthStringResolver with your two custom resolvers
const stringResolver = AuthStringResolver(
  buttons: CustomButtonResolver(),
  inputs: CustomInputResolver(),
  titles: CustomTitleResolver(),
  messages: CustomMessageResolver(),
);
