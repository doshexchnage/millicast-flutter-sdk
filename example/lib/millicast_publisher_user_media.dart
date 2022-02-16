import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:millicast_flutter_sdk/millicast_flutter_sdk.dart';

var _logger = getLogger('MillicastPublishUserMedia');

const connectOptions = {
  'bandwidth': 0,
  'disableVideo': false,
  'disableAudio': false,
};

class MillicastPublishUserMedia extends Publish {
  MillicastMedia? mediaManager;

  MillicastPublishUserMedia(options, tokenGenerator, autoReconnect)
      : super(
            streamName: options['streamName'],
            tokenGenerator: tokenGenerator,
            autoReconnect: autoReconnect) {
    mediaManager = MillicastMedia(options);
  }

  static build(options, tokenGenerator, autoReconnect) async {
    MillicastPublishUserMedia instance =
        MillicastPublishUserMedia(options, tokenGenerator, autoReconnect);

    await instance.getMediaStream();
    return instance;
  }

  getMediaStream() async {
    try {
      return await mediaManager?.getMedia();
    } catch (e) {
      rethrow;
    }
  }

  muteMedia(type, boo) {
    if (type == 'audio') {
      mediaManager?.muteAudio(boolean: boo);
    } else if (type == 'video') {
      mediaManager?.muteVideo(boolean: boo);
    }
  }

  @override
  connect({Map<String, dynamic> options = connectOptions}) async {
    await super.connect(
      options: {...options, 'mediaStream': mediaManager?.mediaStream},
    );
  }
}

class MillicastMedia {
  MediaStream? mediaStream;
  late Map<String, dynamic> constraints;
  MillicastMedia(Map<String, dynamic>? options) {
    constraints = {
      'audio': {
        'echoCancellation': false,
        'channelCount': {'ideal': 2},
      },
      'video': {
        'height': 1080,
        'width': 1920,
      },
    };

    if (options != null && options['constraints'] != null) {
      constraints.addAll(options['constraints']);
    }
  }

  getMedia() async {
    /// gets user cam and mic

    try {
      mediaStream = await navigator.mediaDevices.getUserMedia(constraints);
      return mediaStream;
    } catch (e) {
      throw Error();
    }
  }

  ///
  /// bool] boolean - true if you want to mute the audio, false for mute it.
  /// Returns [bool] - returns true if it was changed, otherwise returns false.
  ///

  bool muteAudio({boolean = true}) {
    var changed = false;
    if (mediaStream != null) {
      mediaStream?.getAudioTracks()[0].enabled = !boolean;
      changed = true;
    } else {
      _logger.e("There is no media stream object.");
    }
    return changed;
  }

  bool switchCamera({boolean = true}) {
    var changed = false;
    if (mediaStream != null) {
      MediaStreamTrack? mediaStreamTrack = mediaStream?.getVideoTracks()[0];
      Helper.switchCamera(mediaStreamTrack!);
      changed = true;
    } else {
      _logger.e("There is no media stream object.");
    }
    return changed;
  }

  ///
  /// [bool] boolean - true if you want to mute the video, false for mute it.
  /// Returns [bool] - returns true if it was changed, otherwise returns false.
  ///
  bool muteVideo({boolean = true}) {
    var changed = false;
    if (mediaStream != null) {
      mediaStream?.getVideoTracks()[0].enabled = !boolean;
      changed = true;
    } else {
      _logger.e("There is no media stream object.");
    }
    return changed;
  }
}