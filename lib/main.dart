import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initSendbird();
  runApp(const MyChatApp());
}

void initSendbird() async {
  SendbirdSdk(appId: 'BC823AD1-FBEA-4F08-8F41-CF0D9D280FBF');
}

class MyChatApp extends StatelessWidget {
  const MyChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        applyElevationOverlayColor: true,
        dialogTheme: const DialogTheme(backgroundColor: Colors.white),
        primaryColor: Colors.white,
        tabBarTheme: const TabBarTheme(indicatorColor: Color(0xff1D1D1B)),
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: false,
      ),
      title: 'Sendbird Chat',
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  List<BaseMessage> _messages = [];
  bool activateSendButton = false;
  OpenChannel openChannel = OpenChannel(
    participantCount: 1,
    operators: [],
    channelUrl: "",
  );
  TextEditingController messageController = TextEditingController();
  String channelUrl =
      "sendbird_open_channel_14092_bf4075fbb8f12dc0df3ccc5c653f027186ac9211";

  @override
  void initState() {
    super.initState();
    joinOpenChannel();
  }

  Future<void> joinOpenChannel() async {
    try {
      openChannel = await OpenChannel.getChannel(channelUrl);
      await openChannel.enter();

      // Handle incoming messages (refer to Sendbird documentation for accurate method)
      final messages = await openChannel.getMessagesByTimestamp(
          DateTime.now().millisecondsSinceEpoch * 1000, MessageListParams());
      setState(() {
        _messages = messages;
      });
    } catch (error) {
      print('Error joining open channel: $error');
    }
  }

  Future<void> sendMessage(String messageText) async {
    try {
      final message = openChannel.sendUserMessage(
        UserMessageParams(message: messageText),
      );
      setState(() {
        _messages.add(message);
        print("This is message: ${message.message.toString()}");
      });
    } catch (error) {
      print('Error sending message: $error');
    }
  }

  void manageSebdButton() {
    if (messageController.text.isNotEmpty) {
      setState(() {
        activateSendButton = true;
      });
    } else {
      setState(() {
        activateSendButton = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0E0D0D),
      appBar: AppBar(
        elevation: 0,
        foregroundColor: const Color(0xff0E0D0D),
        leading: Padding(
          padding: const EdgeInsets.all(4.0),
          child: SvgPicture.asset(
            'assets/icons/btcon_40.svg',
            height: 44,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: SvgPicture.asset(
              'assets/icons/hamburger_icon.svg',
              height: 44,
            ),
          ),
        ],
        centerTitle: true,
        backgroundColor: const Color(0xff0E0D0D),
        title: const Text(
          '강남스팟',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 15,
            letterSpacing: -.1,
            fontWeight: FontWeight.w400,
            height: 1.2,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18.0, 12.0, 18.0, 12.0),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                // _messages = ;
                final message = _messages.reversed.toList()[index];
                return MessageWidget(message: message);
              },
            ),
          ),
          Row(
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(18.0, 8.0, 18.0, 48.0),
                  color: const Color(0xff131313),
                  child: TextField(
                    controller: messageController,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (_) => manageSebdButton(),
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      letterSpacing: -.1,
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                      color: Color(0xffFCFCFC),
                    ),
                    decoration: InputDecoration(
                      fillColor: const Color(0xff1A1A1A),
                      filled: true,
                      hintText: 'Type your message...',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(48),
                        borderSide: const BorderSide(
                          color: Color(0xff323232),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(48),
                        borderSide: const BorderSide(
                          color: Color(0xff323232),
                        ),
                      ),
                      contentPadding:
                          const EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 18.0),
                      hintStyle: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        letterSpacing: -.1,
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                        color: Color(0xff666666),
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: IconButton(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          icon: CircleAvatar(
                              backgroundColor: activateSendButton == true
                                  ? const Color(0xffFF006A)
                                  : const Color(0xff3A3A3A),
                              radius: 16,
                              child: SvgPicture.asset(
                                  "assets/icons/arrow_upward.svg")),
                          onPressed: () {
                            final messageText = messageController.text;
                            sendMessage(messageText);
                            messageController.clear();
                            manageSebdButton();
                          },
                        ),
                      ),
                    ),
                    onSubmitted: (_) {
                      final messageText = messageController.text;
                      sendMessage(messageText);
                      messageController.clear();
                      manageSebdButton();
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MessageWidget extends StatelessWidget {
  final BaseMessage message;

  const MessageWidget({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          // message.sender != null
          message.message == "Hi"
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
      children: [
        message.message == "Hi"
            // message.sender != null
            ? Container(
                width: message.message.length < 40
                    ? null
                    : MediaQuery.of(context).size.width * .75,
                padding: const EdgeInsets.fromLTRB(15, 14, 16, 14),
                margin: const EdgeInsets.fromLTRB(0, 4.0, 0, 4.0),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(22.0),
                    topRight: Radius.circular(6.0),
                    bottomLeft: Radius.circular(22.0),
                    bottomRight: Radius.circular(18.0),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xffFF006B),
                      Color(0xffFF4593),
                    ],
                  ),
                ),
                child: Text(
                  message.message,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 15,
                    letterSpacing: -.1,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.right,
                ),
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 4.0),
                    child: CircleAvatar(
                      radius: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: message.message.length < 32
                            ? null
                            : MediaQuery.of(context).size.width * .62,
                        padding: const EdgeInsets.fromLTRB(15, 14, 16, 14),
                        margin: const EdgeInsets.fromLTRB(0, 4.0, 0, 4.0),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(22.0),
                            topRight: Radius.circular(6.0),
                            bottomLeft: Radius.circular(22.0),
                            bottomRight: Radius.circular(18.0),
                          ),
                          color: Color(0xff1A1A1A),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "nickname",
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 14,
                                    letterSpacing: -.1,
                                    fontWeight: FontWeight.w400,
                                    height: 1.2,
                                    color: Color(0xffADADAD),
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(width: 10),
                                Padding(
                                  padding: EdgeInsets.only(top: 4.0),
                                  child: CircleAvatar(
                                    radius: 3,
                                    backgroundColor: Color(0xff46F9F5),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              message.message,
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 15,
                                letterSpacing: -.1,
                                fontWeight: FontWeight.w400,
                                height: 1.4,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '1분 전',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 12,
                          letterSpacing: -.1,
                          fontWeight: FontWeight.w400,
                          height: 3,
                          color: Color(0xff9C9CA3),
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ],
              ),
      ],
    );
  }
}
