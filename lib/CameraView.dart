import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'insta_home.dart';

class CameraView extends StatefulWidget {
  CameraView({Key key, this.controller}) : super(key: key);

  final PageController controller;
  final double iconHeight = 30;
  final PageController bottomPageController =
      PageController(viewportFraction: .2);
  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView>
    with AutomaticKeepAliveClientMixin {
  CameraController _controller;
  Future<void> _controllerInizializer;
  double cameraHorizontalPosition = 0;
  int selectedCameraIndex;
  List cameras;
  bool _isRecording = false;
  bool _isRecordingMode = false;
  var videoPath;
//  final _timerKey = GlobalKey<VideoTimerState>();

  Future<CameraDescription> getCamera() async {
    final c = await availableCameras();
    return c.first;
  }

  @override
  void initState() {
    super.initState();
    availableCameras().then((availableCameras) {
      cameras = availableCameras;

      if (cameras.length > 0) {
        setState(() {
          selectedCameraIndex = 0;
        });
//        _initCameraController(cameras[selectedCameraIndex]).then((void v) {});
      } else {
        //  print('No camera available');
      }
    });

    getCamera().then((camera) {
      if (camera == null) return;
      setState(() {
        _controller = CameraController(
          camera,
          ResolutionPreset.high,
        );
        _controllerInizializer = _controller.initialize();
        _controllerInizializer.whenComplete(() {
          setState(() {
            //  cameraHorizontalPosition = -(MediaQuery.of(context).size.width*_controller.value.aspectRatio)/2;
          });
        });
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      extendBody: true,
      //    bottomNavigationBar: _buildBottomNavigationBar(),
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned.fill(
            /* trying to preserve aspect ratio */
            left: cameraHorizontalPosition,
            right: cameraHorizontalPosition,
            child: FutureBuilder(
              future: _controllerInizializer,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_controller);
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
          Positioned.fill(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                leading: Icon(
                  Icons.settings,
                  size: 30,
                ),
                actions: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => InstaHome()),
                      );
                    },
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          Icons.close,
                          size: 30,
                        )),
                  ),
                ],
              ),
              body: Container(
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Positioned(
                      bottom: 50,
                      right: 40,
                      left: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
//                        Container(
//                          height: 10,
//                          decoration: BoxDecoration(
//                            border: Border.all(
//                              color: Colors.white,
//                            ),
//                            borderRadius: BorderRadius.all(
//                              Radius.circular(5),
//                            ),
//                          ),
//                          child: ClipRRect(
//                            child: Image.network(""
//                             Utils.image(),
//                            ),
//                            borderRadius: BorderRadius.all(
//                              Radius.circular(5),
//                            ),
//                          ),
//                        ),
                          Container(
                            height: 20,
                            child: Icon(
                              Icons.flash_on,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          Container(
                            child: Container(
                              child: GestureDetector(
                                onLongPress: () async {
                                  print("TEjas");

                                  if (!_isRecording) {
                                    setState(() {
                                      _isRecordingMode = true;
                                    });
                                    await startVideoRecording().then((value) {
                                      setState(() {
                                        videoPath = value;
                                      });
                                    });
                                  }
                                },
                                onLongPressEnd: (value) {
                                  if (!(videoPath == null)) if (_isRecording) {
                                    var path = videoPath;
                                    setState(() {
                                      videoPath = null;
                                      _isRecordingMode = false;
                                    });
                                    stopVideoRecording().then((value) {
                                      print("Stop Recording");
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //       builder: (context) => PreviewScreen(
                                      //             videoPath: path,
                                      //             type: 'Video',
                                      //           )),
                                      // );
                                    });
                                  }
                                },
                                onTap: () {
                                  _onCapturePressed(context);
                                },
                              ),
                              decoration: BoxDecoration(
                                color: _isRecordingMode
                                    ? Colors.redAccent
                                    : Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(30),
                                ),
                              ),
                            ),
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(40),
                              ),
                              border: Border.all(
                                width: 10,
                                color: _isRecordingMode
                                    ? Colors.red.withOpacity(.4)
                                    : Colors.white.withOpacity(.5),
                              ),
                            ),
                          ),
                          Container(
                            //  padding: const EdgeInsets.all(10),
                            height: 30,
                            child: GestureDetector(
                              onTap: () {
                                _onSwitchCamera();
                              },
                              child: Icon(
                                Icons.cached,
                                size: 40,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 0,
                      left: 0,
                      bottom: 10,
                      height: 20,
                      child: PageView.builder(
                        controller: widget.bottomPageController,
                        itemBuilder: (context, index) {
                          return Text(
                            "Item $index",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          );
                        },
                        itemCount: 20,
                      ),
                    ),
                    Positioned(
                      bottom: 5,
                      width: 10,
                      height: 10,
                      child: Icon(
                        Icons.arrow_drop_up,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future _initCameraController(CameraDescription cameraDescription) async {
    if (_controller != null) {
      await _controller.dispose();
    }
    _controller = CameraController(cameraDescription, ResolutionPreset.high);

    _controller.addListener(() {
      if (mounted) {
        setState(() {});
      }

      if (_controller.value.hasError) {
        //  print('Camera error ${_controller.value.errorDescription}');
      }
    });

    try {
      await _controller.initialize();
    } on CameraException catch (e) {
      //  _showCameraException(e);
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _onSwitchCamera() {
    selectedCameraIndex =
        selectedCameraIndex < cameras.length - 1 ? selectedCameraIndex + 1 : 0;
    CameraDescription selectedCamera = cameras[selectedCameraIndex];
    _initCameraController(selectedCamera);
  }

  void _onCapturePressed(context) async {
    try {
      final path =
          join((await getTemporaryDirectory()).path, '${DateTime.now()}.png');
      await _controller.takePicture(path);

      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //       builder: (context) => PreviewScreen(
      //             imgPath: path,
      //             type: 'Image',
      //           )),
      // );
    } catch (e) {
      // _showCameraException(e);
    }
  }

  Future<String> startVideoRecording() async {
    print('startVideoRecording');
    if (!_controller.value.isInitialized) {
      return null;
    }
    setState(() {
      _isRecording = true;
    });
    // _timerKey.currentState.startTimer();

    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/media';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${DateTime.now()}.mp4';

    if (_controller.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return null;
    }

    try {
      await _controller.startVideoRecording(filePath);
    } on CameraException catch (e) {
      print(e);
      return null;
    }
    return filePath;
  }

  Future<void> stopVideoRecording() async {
    if (!_controller.value.isRecordingVideo) {
      return null;
    }
    // _timerKey.currentState.stopTimer();
    setState(() {
      _isRecording = false;
    });

    try {
      await _controller.stopVideoRecording();
    } on CameraException catch (e) {
      print(e);
      return null;
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
