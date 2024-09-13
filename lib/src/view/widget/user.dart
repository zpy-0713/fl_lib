import 'package:fl_lib/fl_lib.dart';
import 'package:fl_lib/src/res/l10n.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

final class UserCard extends StatefulWidget {
  const UserCard({super.key});

  @override
  State<UserCard> createState() => _UserCardState();
}

final class _UserCardState extends State<UserCard> {
  static const noUserHeight = 67.0;
  static const userHeight = 87.0;

  final showTokenPaste = false.vn;

  @override
  Widget build(BuildContext context) {
    return Apis.user.listenVal(_buildInner).cardx;
  }

  Widget _buildInner(User? user) {
    final child = user == null ? _buildLogin() : _buildUserInfo(user);
    final inkwell = InkWell(
      onTap: () {
        if (user != null) {
          UserPage.route.go(context);
        }
      },
      child: child,
    );
    return AnimatedContainer(
      duration: Durations.medium1,
      curve: Curves.fastEaseInToSlowEaseOut,
      height: user == null ? noUserHeight : userHeight,
      child: inkwell,
    );
  }

  Widget _buildLogin() {
    return ListTile(
      leading: const Icon(MingCute.user_1_fill),
      title: Text(l10n.login),
      subtitle: Text(l10n.loginTip, style: UIs.textGrey),
      trailing: showTokenPaste.listenVal((isLoading) {
        if (isLoading) return _buildPasteToken();
        return ElevatedButton(
          onPressed: () async {
            await Apis.login();
            showTokenPaste.value = true;
            Future.delayed(const Duration(seconds: 30), () {
              showTokenPaste.value = false;
            });
          },
          child: const Icon(MingCute.github_line),
        );
      }),
    );
  }

  Widget _buildPasteToken() {
    return ElevatedButton(
      onPressed: () async {
        final token = await Pfs.paste();
        if (token == null || token.isEmpty) return;
        showTokenPaste.value = false;
        Apis.tokenProp.set(token);
        context.showLoadingDialog(fn: Apis.userRefresh);
      },
      child: Text('${l10n.paste} Token'),
    );
  }

  Widget _buildUserInfo(User user) {
    return Row(
      children: [
        const Padding(
          padding: EdgeInsets.all(13),
          child: Hero(tag: 'userAvatar', child: UserAvatar()),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(user.name, style: UIs.text15Bold),
            Text(user.id, style: UIs.textGrey),
          ],
        ),
      ],
    );
  }
}

final class UserAvatar extends StatelessWidget {
  final void Function(ImagePageRet ret)? onRet;
  final bool? showLarge;

  const UserAvatar({super.key, this.onRet, this.showLarge = false});

  @override
  Widget build(BuildContext context) {
    final avatar = Apis.user.value?.avatar;
    final showLarge = this.showLarge ?? avatar != null && onRet != null;
    return ImageCard(
      imageUrl: avatar ?? 'https://cdn.lpkt.cn/img/anon_avatar.jpg',
      showLarge: showLarge,
      heroTag: 'avatar',
      onRet: onRet,
    );
  }
}
