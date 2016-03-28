/* ToxD Copyright (C) 2016 Ogromny
 * Copyright (C) 2013-2015 Tox project All Rights Reserved.
 *
 * This file is part of Tox.
 *
 * Tox is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Tox is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Tox. If not, see <http://www.gnu.org/licenses/>.
 *
 */

module toxav;

/** \page av Public audio/video API for Tox clients.
 *
 * This API can handle multiple calls. Each call has its state, in very rare
 * occasions the library can change the state of the call without apps knowledge.
 *
 */
/** \subsection events Events and callbacks
 *
 * As in Core API, events are handled by callbacks. One callback can be
 * registered per event. All events have a callback function type named
 * `toxav_{event}_cb` and a function to register it named `toxav_callback_{event}`.
 * Passing a NULL callback will result in no callback being registered for that
 * event. Only one callback per event can be registered, so if a client needs
 * multiple event listeners, it needs to implement the dispatch functionality
 * itself. Unlike Core API, lack of some event handlers will cause the the
 * library to drop calls before they are started. Hanging up call from a
 * callback causes undefined behaviour.
 *
 */
/** \subsection threading Threading implications
 *
 * Unlike the Core API, this API is fully thread-safe. The library will ensure
 * the proper synchronization of parallel calls.
 *
 * A common way to run ToxAV (multiple or single instance) is to have a thread,
 * separate from tox instance thread, running a simple toxav_iterate loop,
 * sleeping for toxav_iteration_interval * milliseconds on each iteration.
 *
 * An important thing to note is that events are triggered from both tox and
 * toxav thread (see above). Audio and video receive frame events are triggered
 * from toxav thread while all the other events are triggered from tox thread.
 *
 * Tox thread has priority with mutex mechanisms. Any api function can
 * fail if mutexes are held by tox thread in which case they will set SYNC
 * error code.
 */

extern (C)
{
  enum TOXAV_ERR_NEW
  {
    /**
     * The function returned successfully.
     */
    TOXAV_ERR_NEW_OK = 0,
    /**
     * One of the arguments to the function was NULL when it was not expected.
     */
    TOXAV_ERR_NEW_NULL = 1,
    /**
     * Memory allocation failure while trying to allocate structures required for
     * the A/V session.
     */
    TOXAV_ERR_NEW_MALLOC = 2,
    /**
     * Attempted to create a second session for the same Tox instance.
     */
    TOXAV_ERR_NEW_MULTIPLE = 3
  }

  enum TOXAV_ERR_CALL
  {
    /**
     * The function returned successfully.
     */
    TOXAV_ERR_CALL_OK = 0,
    /**
     * A resource allocation error occurred while trying to create the structures
     * required for the call.
     */
    TOXAV_ERR_CALL_MALLOC = 1,
    /**
     * Synchronization error occurred.
     */
    TOXAV_ERR_CALL_SYNC = 2,
    /**
     * The friend number did not designate a valid friend.
     */
    TOXAV_ERR_CALL_FRIEND_NOT_FOUND = 3,
    /**
     * The friend was valid, but not currently connected.
     */
    TOXAV_ERR_CALL_FRIEND_NOT_CONNECTED = 4,
    /**
     * Attempted to call a friend while already in an audio or video call with
     * them.
     */
    TOXAV_ERR_CALL_FRIEND_ALREADY_IN_CALL = 5,
    /**
     * Audio or video bit rate is invalid.
     */
    TOXAV_ERR_CALL_INVALID_BIT_RATE = 6
  }

  enum TOXAV_ERR_ANSWER
  {
    /**
     * The function returned successfully.
     */
    TOXAV_ERR_ANSWER_OK = 0,
    /**
     * Synchronization error occurred.
     */
    TOXAV_ERR_ANSWER_SYNC = 1,
    /**
     * Failed to initialize codecs for call session. Note that codec initiation
     * will fail if there is no receive callback registered for either audio or
     * video.
     */
    TOXAV_ERR_ANSWER_CODEC_INITIALIZATION = 2,
    /**
     * The friend number did not designate a valid friend.
     */
    TOXAV_ERR_ANSWER_FRIEND_NOT_FOUND = 3,
    /**
     * The friend was valid, but they are not currently trying to initiate a call.
     * This is also returned if this client is already in a call with the friend.
     */
    TOXAV_ERR_ANSWER_FRIEND_NOT_CALLING = 4,
    /**
     * Audio or video bit rate is invalid.
     */
    TOXAV_ERR_ANSWER_INVALID_BIT_RATE = 5
  }

  enum TOXAV_FRIEND_CALL_STATE
  {
    /**
     * Set by the AV core if an error occurred on the remote end or if friend
     * timed out. This is the final state after which no more state
     * transitions can occur for the call. This call state will never be triggered
     * in combination with other call states.
     */
    TOXAV_FRIEND_CALL_STATE_ERROR = 1,
    /**
     * The call has finished. This is the final state after which no more state
     * transitions can occur for the call. This call state will never be
     * triggered in combination with other call states.
     */
    TOXAV_FRIEND_CALL_STATE_FINISHED = 2,
    /**
     * The flag that marks that friend is sending audio.
     */
    TOXAV_FRIEND_CALL_STATE_SENDING_A = 4,
    /**
     * The flag that marks that friend is sending video.
     */
    TOXAV_FRIEND_CALL_STATE_SENDING_V = 8,
    /**
     * The flag that marks that friend is receiving audio.
     */
    TOXAV_FRIEND_CALL_STATE_ACCEPTING_A = 16,
    /**
     * The flag that marks that friend is receiving video.
     */
    TOXAV_FRIEND_CALL_STATE_ACCEPTING_V = 32
  }

  enum TOXAV_CALL_CONTROL
  {
    /**
     * Resume a previously paused call. Only valid if the pause was caused by this
     * client, if not, this control is ignored. Not valid before the call is accepted.
     */
    TOXAV_CALL_CONTROL_RESUME = 0,
    /**
     * Put a call on hold. Not valid before the call is accepted.
     */
    TOXAV_CALL_CONTROL_PAUSE = 1,
    /**
     * Reject a call if it was not answered, yet. Cancel a call after it was
     * answered.
     */
    TOXAV_CALL_CONTROL_CANCEL = 2,
    /**
     * Request that the friend stops sending audio. Regardless of the friend's
     * compliance, this will cause the audio_receive_frame event to stop being
     * triggered on receiving an audio frame from the friend.
     */
    TOXAV_CALL_CONTROL_MUTE_AUDIO = 3,
    /**
     * Calling this control will notify client to start sending audio again.
     */
    TOXAV_CALL_CONTROL_UNMUTE_AUDIO = 4,
    /**
     * Request that the friend stops sending video. Regardless of the friend's
     * compliance, this will cause the video_receive_frame event to stop being
     * triggered on receiving a video frame from the friend.
     */
    TOXAV_CALL_CONTROL_HIDE_VIDEO = 5,
    /**
     * Calling this control will notify client to start sending video again.
     */
    TOXAV_CALL_CONTROL_SHOW_VIDEO = 6
  }

  enum TOXAV_ERR_CALL_CONTROL
  {
    /**
     * The function returned successfully.
     */
    TOXAV_ERR_CALL_CONTROL_OK = 0,
    /**
     * Synchronization error occurred.
     */
    TOXAV_ERR_CALL_CONTROL_SYNC = 1,
    /**
     * The friend_number passed did not designate a valid friend.
     */
    TOXAV_ERR_CALL_CONTROL_FRIEND_NOT_FOUND = 2,
    /**
     * This client is currently not in a call with the friend. Before the call is
     * answered, only CANCEL is a valid control.
     */
    TOXAV_ERR_CALL_CONTROL_FRIEND_NOT_IN_CALL = 3,
    /**
     * Happens if user tried to pause an already paused call or if trying to
     * resume a call that is not paused.
     */
    TOXAV_ERR_CALL_CONTROL_INVALID_TRANSITION = 4
  }

  enum TOXAV_ERR_BIT_RATE_SET
  {
    /**
     * The function returned successfully.
     */
    TOXAV_ERR_BIT_RATE_SET_OK = 0,
    /**
     * Synchronization error occurred.
     */
    TOXAV_ERR_BIT_RATE_SET_SYNC = 1,
    /**
     * The audio bit rate passed was not one of the supported values.
     */
    TOXAV_ERR_BIT_RATE_SET_INVALID_AUDIO_BIT_RATE = 2,
    /**
     * The video bit rate passed was not one of the supported values.
     */
    TOXAV_ERR_BIT_RATE_SET_INVALID_VIDEO_BIT_RATE = 3,
    /**
     * The friend_number passed did not designate a valid friend.
     */
    TOXAV_ERR_BIT_RATE_SET_FRIEND_NOT_FOUND = 4,
    /**
     * This client is currently not in a call with the friend.
     */
    TOXAV_ERR_BIT_RATE_SET_FRIEND_NOT_IN_CALL = 5
  }

  enum TOXAV_ERR_SEND_FRAME
  {
    /**
     * The function returned successfully.
     */
    TOXAV_ERR_SEND_FRAME_OK = 0,
    /**
     * In case of video, one of Y, U, or V was NULL. In case of audio, the samples
     * data pointer was NULL.
     */
    TOXAV_ERR_SEND_FRAME_NULL = 1,
    /**
     * The friend_number passed did not designate a valid friend.
     */
    TOXAV_ERR_SEND_FRAME_FRIEND_NOT_FOUND = 2,
    /**
     * This client is currently not in a call with the friend.
     */
    TOXAV_ERR_SEND_FRAME_FRIEND_NOT_IN_CALL = 3,
    /**
     * Synchronization error occurred.
     */
    TOXAV_ERR_SEND_FRAME_SYNC = 4,
    /**
     * One of the frame parameters was invalid. E.g. the resolution may be too
     * small or too large, or the audio sampling rate may be unsupported.
     */
    TOXAV_ERR_SEND_FRAME_INVALID = 5,
    /**
     * Either friend turned off audio or video receiving or we turned off sending
     * for the said payload.
     */
    TOXAV_ERR_SEND_FRAME_PAYLOAD_TYPE_DISABLED = 6,
    /**
     * Failed to push frame through rtp interface.
     */
    TOXAV_ERR_SEND_FRAME_RTP_FAILED = 7
  }

  struct Tox;


  struct ToxAV;


  // uint toxav_version_major ();

  // uint toxav_version_minor ();

  // uint toxav_version_patch ();

  // bool toxav_version_is_compatible (uint major, uint minor, uint patch);

  /**
   * Start new A/V session. There can only be only one session per Tox instance.
   */
  ToxAV* toxav_new (Tox* tox, TOXAV_ERR_NEW* error);

  /**
   * Releases all resources associated with the A/V session.
   *
   * If any calls were ongoing, these will be forcibly terminated without
   * notifying peers. After calling this function, no other functions may be
   * called and the av pointer becomes invalid.
   */
  void toxav_kill (ToxAV* toxAV);

  /**
   * Returns the Tox instance the A/V object was created for.
   */
  Tox* toxav_get_tox (const(ToxAV)* toxAV);

  /**
   * Returns the interval in milliseconds when the next toxav_iterate call should
   * be. If no call is active at the moment, this function returns 200.
   */
  uint toxav_iteration_interval (const(ToxAV)* toxAV);

  /**
   * Main loop for the session. This function needs to be called in intervals of
   * toxav_iteration_interval() milliseconds. It is best called in the separate
   * thread from tox_iterate.
   */
  void toxav_iterate (ToxAV* toxAV);

  /**
   * Call a friend. This will start ringing the friend.
   *
   * It is the client's responsibility to stop ringing after a certain timeout,
   * if such behaviour is desired. If the client does not stop ringing, the
   * library will not stop until the friend is disconnected. Audio and video
   * receiving are both enabled by default.
   *
   * @param friend_number The friend number of the friend that should be called.
   * @param audio_bit_rate Audio bit rate in Kb/sec. Set this to 0 to disable
   * audio sending.
   * @param video_bit_rate Video bit rate in Kb/sec. Set this to 0 to disable
   * video sending.
   */
  bool toxav_call (ToxAV* toxAV, uint friend_number, uint audio_bit_rate, uint video_bit_rate, TOXAV_ERR_CALL* error);

  /**
   * Set the callback for the `call` event. Pass NULL to unset.
   */
  void toxav_callback_call (ToxAV* toxAV, void function (ToxAV*, uint, bool, bool, void*) callback, void* user_data);

  /**
   * Accept an incoming call.
   *
   * If answering fails for any reason, the call will still be pending and it is
   * possible to try and answer it later. Audio and video receiving are both
   * enabled by default.
   *
   * @param friend_number The friend number of the friend that is calling.
   * @param audio_bit_rate Audio bit rate in Kb/sec. Set this to 0 to disable
   * audio sending.
   * @param video_bit_rate Video bit rate in Kb/sec. Set this to 0 to disable
   * video sending.
   */
  bool toxav_answer (ToxAV* toxAV, uint friend_number, uint audio_bit_rate, uint video_bit_rate, TOXAV_ERR_ANSWER* error);


  /**
   * Set the callback for the `call_state` event. Pass NULL to unset.
   */
  void toxav_callback_call_state (ToxAV* toxAV, void function (ToxAV*, uint, uint, void*) callback, void* user_data);

  /**
   * Sends a call control command to a friend.
   *
   * @param friend_number The friend number of the friend this client is in a call
   * with.
   * @param control The control command to send.
   *
   * @return true on success.
   */
  bool toxav_call_control (ToxAV* toxAV, uint friend_number, TOXAV_CALL_CONTROL control, TOXAV_ERR_CALL_CONTROL* error);

  /**
   * Set the bit rate to be used in subsequent audio/video frames.
   *
   * @param friend_number The friend number of the friend for which to set the
   * bit rate.
   * @param audio_bit_rate The new audio bit rate in Kb/sec. Set to 0 to disable
   * audio sending. Set to -1 to leave unchanged.
   * @param video_bit_rate The new video bit rate in Kb/sec. Set to 0 to disable
   * video sending. Set to -1 to leave unchanged.
   *
   */
  bool toxav_bit_rate_set (ToxAV* toxAV, uint friend_number, int audio_bit_rate, int video_bit_rate, TOXAV_ERR_BIT_RATE_SET* error);

  /**
   * Set the callback for the `bit_rate_status` event. Pass NULL to unset.
   */
  void toxav_callback_bit_rate_status (ToxAV* toxAV, void function (ToxAV*, uint, uint, uint, void*) callback, void* user_data);

  /**
   * Send an audio frame to a friend.
   *
   * The expected format of the PCM data is: [s1c1][s1c2][...][s2c1][s2c2][...]...
   * Meaning: sample 1 for channel 1, sample 1 for channel 2, ...
   * For mono audio, this has no meaning, every sample is subsequent. For stereo,
   * this means the expected format is LRLRLR... with samples for left and right
   * alternating.
   *
   * @param friend_number The friend number of the friend to which to send an
   * audio frame.
   * @param pcm An array of audio samples. The size of this array must be
   * sample_count * channels.
   * @param sample_count Number of samples in this frame. Valid numbers here are
   * ((sample rate) * (audio length) / 1000), where audio length can be
   * 2.5, 5, 10, 20, 40 or 60 millseconds.
   * @param channels Number of audio channels. Supported values are 1 and 2.
   * @param sampling_rate Audio sampling rate used in this frame. Valid sampling
   * rates are 8000, 12000, 16000, 24000, or 48000.
   */
  bool toxav_audio_send_frame (ToxAV* toxAV, uint friend_number, const(short)* pcm, size_t sample_count, ubyte channels, uint sampling_rate, TOXAV_ERR_SEND_FRAME* error);

  /**
   * Send a video frame to a friend.
   *
   * Y - plane should be of size: height * width
   * U - plane should be of size: (height/2) * (width/2)
   * V - plane should be of size: (height/2) * (width/2)
   *
   * @param friend_number The friend number of the friend to which to send a video
   * frame.
   * @param width Width of the frame in pixels.
   * @param height Height of the frame in pixels.
   * @param y Y (Luminance) plane data.
   * @param u U (Chroma) plane data.
   * @param v V (Chroma) plane data.
   */
  bool toxav_video_send_frame (ToxAV* toxAV, uint friend_number, ushort width, ushort height, const(ubyte)* y, const(ubyte)* u, const(ubyte)* v, TOXAV_ERR_SEND_FRAME* error);

  /**
   * Set the callback for the `audio_receive_frame` event. Pass NULL to unset.
   */
  void toxav_callback_audio_receive_frame (ToxAV* toxAV, void function (ToxAV*, uint, const(short)*, size_t, ubyte, uint, void*) callback, void* user_data);

  /**
   * Set the callback for the `video_receive_frame` event. Pass NULL to unset.
   */
  void toxav_callback_video_receive_frame (ToxAV* toxAV, void function (ToxAV*, uint, ushort, ushort, const(ubyte)*, const(ubyte)*, const(ubyte)*, int, int, int, void*) callback, void* user_data);

  /* Create a new toxav group.
   *
   * return group number on success.
   * return -1 on failure.
   *
   * Audio data callback format:
   *   audio_callback(Tox *tox, int groupnumber, int peernumber, const int16_t *pcm, unsigned int samples, uint8_t channels, unsigned int sample_rate, void *userdata)
   *
   * Note that total size of pcm in bytes is equal to (samples * channels * sizeof(int16_t)).
   */
  int toxav_add_av_groupchat (Tox* tox, void function (void*, int, int, const(short)*, uint, ubyte, uint, void*) audio_callback, void* userdata);

  /* Join a AV group (you need to have been invited first.)
   *
   * returns group number on success
   * returns -1 on failure.
   *
   * Audio data callback format (same as the one for toxav_add_av_groupchat()):
   *   audio_callback(Tox *tox, int groupnumber, int peernumber, const int16_t *pcm, unsigned int samples, uint8_t channels, unsigned int sample_rate, void *userdata)
   *
   * Note that total size of pcm in bytes is equal to (samples * channels * sizeof(int16_t)).
   */
  int toxav_join_av_groupchat (Tox* tox, int friendnumber, const(ubyte)* data, ushort length, void function (void*, int, int, const(short)*, uint, ubyte, uint, void*) audio_callback, void* userdata);

  /* Send audio to the group chat.
   *
   * return 0 on success.
   * return -1 on failure.
   *
   * Note that total size of pcm in bytes is equal to (samples * channels * sizeof(int16_t)).
   *
   * Valid number of samples are ((sample rate) * (audio length (Valid ones are: 2.5, 5, 10, 20, 40 or 60 ms)) / 1000)
   * Valid number of channels are 1 or 2.
   * Valid sample rates are 8000, 12000, 16000, 24000, or 48000.
   *
   * Recommended values are: samples = 960, channels = 1, sample_rate = 48000
   */
  int toxav_group_send_audio (Tox* tox, int groupnumber, const(short)* pcm, uint samples, ubyte channels, uint sample_rate);
}
