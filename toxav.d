/* ToxD Copyright (C) 2016 Ogromny */

module toxav;

extern (C)
{
  enum TOXAV_ERR_NEW
  {
      TOXAV_ERR_NEW_OK = 0,
      TOXAV_ERR_NEW_NULL = 1,
      TOXAV_ERR_NEW_MALLOC = 2,
      TOXAV_ERR_NEW_MULTIPLE = 3
  }

  enum TOXAV_ERR_CALL
  {
      TOXAV_ERR_CALL_OK = 0,
      TOXAV_ERR_CALL_MALLOC = 1,
      TOXAV_ERR_CALL_SYNC = 2,
      TOXAV_ERR_CALL_FRIEND_NOT_FOUND = 3,
      TOXAV_ERR_CALL_FRIEND_NOT_CONNECTED = 4,
      TOXAV_ERR_CALL_FRIEND_ALREADY_IN_CALL = 5,
      TOXAV_ERR_CALL_INVALID_BIT_RATE = 6
  }

  enum TOXAV_ERR_ANSWER
  {
      TOXAV_ERR_ANSWER_OK = 0,
      TOXAV_ERR_ANSWER_SYNC = 1,
      TOXAV_ERR_ANSWER_CODEC_INITIALIZATION = 2,
      TOXAV_ERR_ANSWER_FRIEND_NOT_FOUND = 3,
      TOXAV_ERR_ANSWER_FRIEND_NOT_CALLING = 4,
      TOXAV_ERR_ANSWER_INVALID_BIT_RATE = 5
  }

  enum TOXAV_FRIEND_CALL_STATE
  {
      TOXAV_FRIEND_CALL_STATE_ERROR = 1,
      TOXAV_FRIEND_CALL_STATE_FINISHED = 2,
      TOXAV_FRIEND_CALL_STATE_SENDING_A = 4,
      TOXAV_FRIEND_CALL_STATE_SENDING_V = 8,
      TOXAV_FRIEND_CALL_STATE_ACCEPTING_A = 16,
      TOXAV_FRIEND_CALL_STATE_ACCEPTING_V = 32
  }

  enum TOXAV_CALL_CONTROL
  {
      TOXAV_CALL_CONTROL_RESUME = 0,
      TOXAV_CALL_CONTROL_PAUSE = 1,
      TOXAV_CALL_CONTROL_CANCEL = 2,
      TOXAV_CALL_CONTROL_MUTE_AUDIO = 3,
      TOXAV_CALL_CONTROL_UNMUTE_AUDIO = 4,
      TOXAV_CALL_CONTROL_HIDE_VIDEO = 5,
      TOXAV_CALL_CONTROL_SHOW_VIDEO = 6
  }

  enum TOXAV_ERR_CALL_CONTROL
  {
      TOXAV_ERR_CALL_CONTROL_OK = 0,
      TOXAV_ERR_CALL_CONTROL_SYNC = 1,
      TOXAV_ERR_CALL_CONTROL_FRIEND_NOT_FOUND = 2,
      TOXAV_ERR_CALL_CONTROL_FRIEND_NOT_IN_CALL = 3,
      TOXAV_ERR_CALL_CONTROL_INVALID_TRANSITION = 4
  }

  enum TOXAV_ERR_BIT_RATE_SET
  {
      TOXAV_ERR_BIT_RATE_SET_OK = 0,
      TOXAV_ERR_BIT_RATE_SET_SYNC = 1,
      TOXAV_ERR_BIT_RATE_SET_INVALID_AUDIO_BIT_RATE = 2,
      TOXAV_ERR_BIT_RATE_SET_INVALID_VIDEO_BIT_RATE = 3,
      TOXAV_ERR_BIT_RATE_SET_FRIEND_NOT_FOUND = 4,
      TOXAV_ERR_BIT_RATE_SET_FRIEND_NOT_IN_CALL = 5
  }

  enum TOXAV_ERR_SEND_FRAME
  {
      TOXAV_ERR_SEND_FRAME_OK = 0,
      TOXAV_ERR_SEND_FRAME_NULL = 1,
      TOXAV_ERR_SEND_FRAME_FRIEND_NOT_FOUND = 2,
      TOXAV_ERR_SEND_FRAME_FRIEND_NOT_IN_CALL = 3,
      TOXAV_ERR_SEND_FRAME_SYNC = 4,
      TOXAV_ERR_SEND_FRAME_INVALID = 5,
      TOXAV_ERR_SEND_FRAME_PAYLOAD_TYPE_DISABLED = 6,
      TOXAV_ERR_SEND_FRAME_RTP_FAILED = 7
  }

  struct Tox;


  struct ToxAV;


  // uint toxav_version_major ();
  // uint toxav_version_minor ();
  // uint toxav_version_patch ();
  // bool toxav_version_is_compatible (uint major, uint minor, uint patch);
  ToxAV* toxav_new (Tox* tox, TOXAV_ERR_NEW* error);
  void toxav_kill (ToxAV* toxAV);
  Tox* toxav_get_tox (const(ToxAV)* toxAV);
  uint toxav_iteration_interval (const(ToxAV)* toxAV);
  void toxav_iterate (ToxAV* toxAV);
  bool toxav_call (ToxAV* toxAV, uint friend_number, uint audio_bit_rate, uint video_bit_rate, TOXAV_ERR_CALL* error);
  void toxav_callback_call (ToxAV* toxAV, void function (ToxAV*, uint, bool, bool, void*) callback, void* user_data);
  bool toxav_answer (ToxAV* toxAV, uint friend_number, uint audio_bit_rate, uint video_bit_rate, TOXAV_ERR_ANSWER* error);
  void toxav_callback_call_state (ToxAV* toxAV, void function (ToxAV*, uint, uint, void*) callback, void* user_data);
  bool toxav_call_control (ToxAV* toxAV, uint friend_number, TOXAV_CALL_CONTROL control, TOXAV_ERR_CALL_CONTROL* error);
  bool toxav_bit_rate_set (ToxAV* toxAV, uint friend_number, int audio_bit_rate, int video_bit_rate, TOXAV_ERR_BIT_RATE_SET* error);
  void toxav_callback_bit_rate_status (ToxAV* toxAV, void function (ToxAV*, uint, uint, uint, void*) callback, void* user_data);
  bool toxav_audio_send_frame (ToxAV* toxAV, uint friend_number, const(short)* pcm, size_t sample_count, ubyte channels, uint sampling_rate, TOXAV_ERR_SEND_FRAME* error);
  bool toxav_video_send_frame (ToxAV* toxAV, uint friend_number, ushort width, ushort height, const(ubyte)* y, const(ubyte)* u, const(ubyte)* v, TOXAV_ERR_SEND_FRAME* error);
  void toxav_callback_audio_receive_frame (ToxAV* toxAV, void function (ToxAV*, uint, const(short)*, size_t, ubyte, uint, void*) callback, void* user_data);
  void toxav_callback_video_receive_frame (ToxAV* toxAV, void function (ToxAV*, uint, ushort, ushort, const(ubyte)*, const(ubyte)*, const(ubyte)*, int, int, int, void*) callback, void* user_data);
  int toxav_add_av_groupchat (Tox* tox, void function (void*, int, int, const(short)*, uint, ubyte, uint, void*) audio_callback, void* userdata);
  int toxav_join_av_groupchat (Tox* tox, int friendnumber, const(ubyte)* data, ushort length, void function (void*, int, int, const(short)*, uint, ubyte, uint, void*) audio_callback, void* userdata);
  int toxav_group_send_audio (Tox* tox, int groupnumber, const(short)* pcm, uint samples, ubyte channels, uint sample_rate);
}
