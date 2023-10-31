import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:voice_ai_app/feature_box.dart';
import 'package:voice_ai_app/openai_service.dart';
import 'package:voice_ai_app/pallete.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final speechTotext = SpeechToText();
  final flutterTts = FlutterTts();
  String lastwords ='';
  String? generatedContent;
  String? generatedImage;
  int start = 200;
  int delay = 200;
  final OpenAIService openAIService = OpenAIService();
  @override
  void initState(){
    super.initState();
    initSpeechtoText();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }
  Future<void> startListening() async {
    await speechTotext.listen(onResult: onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  Future<void> stopListening() async {
    await speechTotext.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastwords = result.recognizedWords;
    });
  }

  Future<void>initSpeechtoText() async{
    speechTotext.initialize();
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }
  @override
  void dispose(){
    super.dispose();
    speechTotext.stop();
    flutterTts.stop();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:BounceInDown(child: const Text('Voice Assistant')) ,
        leading: const Icon(Icons.menu),
        centerTitle: true,
      ),
      body:SingleChildScrollView(
        child: Column(
          children: [
            //virtual assistant profile
            ZoomIn(
              child: Stack(
                children:[
                  Center(
                  child: Container(
                    height: 120,
                      width: 120,
                      decoration:const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Palletee.assistantCircleColor,
                      ),
                      margin: const EdgeInsets.only(top:4),

                  ),
                ),
                  Container(
                    height: 123,
                    decoration:const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage(
                            'assets/images/virtualAssistant.png'
                        ),
                      )
                    ),
                  )
               ],
              ),
            ),
            //chat bubble
            FadeInRight(
              child: Visibility(
                visible: generatedImage == null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 40).copyWith(top: 30),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Palletee.borderColor,
                    ),
                    borderRadius: BorderRadius.circular(20).copyWith(
                      topLeft: Radius.zero,
                    )
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                     generatedContent==null ?   'Good Morning,what task should i do for you ?'
                    :  generatedContent!,
                    style: TextStyle(
                      fontFamily: 'Cera Pro',
                      color: Palletee.mainFontColor,
                      fontSize: generatedContent == null ? 25: 18,
                    ),
                    ),
                  ),
                ),
              ),
            ),
            if(generatedImage!=null) Padding(
              padding: const EdgeInsets.all(10.0),
              child: ClipRect(
                  //r : BorderRadius.all(10.0),
                  child: Image.network(generatedImage!)),
            ),
            SlideInLeft(
              child: Visibility(
                visible: generatedContent==null && generatedImage == null,
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(10.0),
                  margin: const  EdgeInsets.only(top: 10,left: 25),
                  child: const Text(
                    'Here are few features ',
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: 'Cera Pro',
                      color: Palletee.mainFontColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            // feature List
            Visibility(
              visible: generatedContent==null && generatedImage == null,
              child:  Column(
                children:  [
                SlideInLeft(
                  delay : Duration(milliseconds: start),
                  child: const FeatureBox(color: Palletee.firstSuggestionBoxColor,
                  headerText: 'Chat Gpt',
                  descptxt: 'A smarter way to stay organized and infrormed with ChatGPT',),
                ),
                SlideInLeft(
                  delay: Duration(milliseconds: start + delay),
                  child: const FeatureBox(color: Palletee.secondSuggestionBoxColor,
                    headerText: 'Dalle-E',
                    descptxt: 'Get inspired and stay creative with your personal assistant powered by Dall-E',),
                ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start + delay + delay),
                    child:const FeatureBox(color: Palletee.thirdSuggestionBoxColor,
                      headerText: 'Smart Voice Assistant',
                      descptxt: 'Get the best of both worlds with a voice assistant powered by Dall-E and ChatGPT',),
                  ),
                ],
              ),
            ),
          ],
        ),
      ) ,
      floatingActionButton: ZoomIn(
        delay: Duration(milliseconds: start + delay + delay + delay),
        child: FloatingActionButton(
          backgroundColor: Palletee.firstSuggestionBoxColor,
            onPressed: ()async {
            if(await speechTotext.hasPermission && speechTotext.isNotListening){
             await startListening();
            }else if(speechTotext.isListening){
             final speech = await openAIService.isArtPromptAPI(lastwords);
             if(speech.contains('https')){
               generatedImage = speech;
               generatedContent = null;
               setState(() {});
             }else{
               generatedImage = null;
               generatedContent = speech;
               setState(() {});
               await systemSpeak(speech);
             }
             await systemSpeak(speech);
             await stopListening();
            }else{
              initSpeechtoText();
            }
            },
                child:  Icon(speechTotext.isListening ?Icons.stop :Icons.mic),
        ),
      ),
    );
  }
}
