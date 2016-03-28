/* ToxD Copyright (C) 2016 Ogromny */

/** \page core Public core API for Tox clients.
 *
 * Every function that can fail takes a function-specific error code pointer
 * that can be used to diagnose problems with the Tox state or the function
 * arguments. The error code pointer can be NULL, which does not influence the
 * function's behaviour, but can be done if the reason for failure is irrelevant
 * to the client.
 *
 * The exception to this rule are simple allocation functions whose only failure
 * mode is allocation failure. They return NULL in that case, and do not set an
 * error code.
 *
 * Every error code type has an OK value to which functions will set their error
 * code value on success. Clients can keep their error code uninitialised before
 * passing it to a function. The library guarantees that after returning, the
 * value pointed to by the error code pointer has been initialised.
 *
 * Functions with pointer parameters often have a NULL error code, meaning they
 * could not perform any operation, because one of the required parameters was
 * NULL. Some functions operate correctly or are defined as effectless on NULL.
 *
 * Some functions additionally return a value outside their
 * return type domain, or a bool containing true on success and false on
 * failure.
 *
 * All functions that take a Tox instance pointer will cause undefined behaviour
 * when passed a NULL Tox pointer.
 *
 * All integer values are expected in host byte order.
 *
 * Functions with parameters with enum types cause unspecified behaviour if the
 * enumeration value is outside the valid range of the type. If possible, the
 * function will try to use a sane default, but there will be no error code,
 * and one possible action for the function to take is to have no effect.
 */
/** \subsection events Events and callbacks
 *
 * Events are handled by callbacks. One callback can be registered per event.
 * All events have a callback function type named `tox_{event}_cb` and a
 * function to register it named `tox_callback_{event}`. Passing a NULL
 * callback will result in no callback being registered for that event. Only
 * one callback per event can be registered, so if a client needs multiple
 * event listeners, it needs to implement the dispatch functionality itself.
 */
/** \subsection threading Threading implications
 *
 * It is possible to run multiple concurrent threads with a Tox instance for
 * each thread. It is also possible to run all Tox instances in the same thread.
 * A common way to run Tox (multiple or single instance) is to have one thread
 * running a simple tox_iterate loop, sleeping for tox_iteration_interval
 * milliseconds on each iteration.
 *
 * If you want to access a single Tox instance from multiple threads, access
 * to the instance must be synchronised. While multiple threads can concurrently
 * access multiple different Tox instances, no more than one API function can
 * operate on a single instance at any given time.
 *
 * Functions that write to variable length byte arrays will always have a size
 * function associated with them. The result of this size function is only valid
 * until another mutating function (one that takes a pointer to non-const Tox)
 * is called. Thus, clients must ensure that no other thread calls a mutating
 * function between the call to the size function and the call to the retrieval
 * function.
 *
 * E.g. to get the current nickname, one would write
 *
 * \code
 * size_t length = tox_self_get_name_size(tox);
 * uint8_t *name = malloc(length);
 * if (!name) abort();
 * tox_self_get_name(tox, name);
 * \endcode
 *
 * If any other thread calls tox_self_set_name while this thread is allocating
 * memory, the length may have become invalid, and the call to
 * tox_self_get_name may cause undefined behaviour.
 */
/**
 * The Tox instance type. All the state associated with a connection is held
 * within the instance. Multiple instances can exist and operate concurrently.
 * The maximum number of Tox instances that can exist on a single network
 * device is limited. Note that this is not just a per-process limit, since the
 * limiting factor is the number of usable ports on a device.
 */
module tox;

extern (C)
{
  enum
  {
    /**
     * The size of a Tox Public Key in bytes.
     */
    TOX_PUBLIC_KEY_SIZE = 32,

    /**
     * The size of a Tox Secret Key in bytes.
     */
    TOX_SECRET_KEY_SIZE = 32,

    /**
     * The size of a Tox address in bytes. Tox addresses are in the format
     * [Public Key (TOX_PUBLIC_KEY_SIZE bytes)][nospam (4 bytes)][checksum (2 bytes)].
     *
     * The checksum is computed over the Public Key and the nospam value. The first
     * byte is an XOR of all the even bytes (0, 2, 4, ...), the second byte is an
     * XOR of all the odd bytes (1, 3, 5, ...) of the Public Key and nospam.
     */
    TOX_ADDRESS_SIZE = (TOX_PUBLIC_KEY_SIZE + uint.sizeof * 2), // not exactly but work

    /**
     * Maximum length of a nickname in bytes.
     */
    TOX_MAX_NAME_LENGTH = 128,

    /**
     * Maximum length of a status message in bytes.
     */
    TOX_MAX_STATUS_MESSAGE_LENGTH = 1007,

    /**
     * Maximum length of a friend request message in bytes.
     */
    TOX_MAX_FRIEND_REQUEST_LENGTH = 1016,

    /**
     * Maximum length of a single message after which it should be split.
     */
    TOX_MAX_MESSAGE_LENGTH = 1372,

    /**
     * Maximum size of custom packets. TODO: should be LENGTH?
     */
    TOX_MAX_CUSTOM_PACKET_SIZE = 1373,

    /**
     * The number of bytes in a hash generated by tox_hash.
     */
    TOX_HASH_LENGTH = 32,

    /**
     * The number of bytes in a file id.
     */
    TOX_FILE_ID_LENGTH = 32,

    /**
     * Maximum file name length for file transfers.
     */
    TOX_MAX_FILENAME_LENGTH = 255,

    /**
    * FROM tox_old.h
    **/

    /**
     * Group chat types for tox_callback_group_invite function.
     *
     * TOX_GROUPCHAT_TYPE_TEXT groupchats must be accepted with the tox_join_groupchat() function.
     * The function to accept TOX_GROUPCHAT_TYPE_AV is in toxav.
     */
    TOX_GROUPCHAT_TYPE_TEXT = 0,
    TOX_GROUPCHAT_TYPE_AV = 1,

    TOX_CHAT_CHANGE_PEER_ADD = 0,
    TOX_CHAT_CHANGE_PEER_DEL = 1,
    TOX_CHAT_CHANGE_PEER_NAME = 2,
  }

  /**
   * Represents the possible statuses a client can have.
   */
  enum TOX_USER_STATUS
  {
      /**
       * User is online and available.
       */
      TOX_USER_STATUS_NONE = 0,

      /**
       * User is away. Clients can set this e.g. after a user defined
       * inactivity time.
       */
      TOX_USER_STATUS_AWAY = 1,

      /**
       * User is busy. Signals to other clients that this client does not
       * currently wish to communicate.
       */
      TOX_USER_STATUS_BUSY = 2
  }

  /**
   * Represents message types for tox_friend_send_message and group chat
   * messages.
   */
  enum TOX_MESSAGE_TYPE
  {
      /**
       * Normal text message. Similar to PRIVMSG on IRC.
       */
      TOX_MESSAGE_TYPE_NORMAL = 0,

      /**
       * A message describing an user action. This is similar to /me (CTCP ACTION)
       * on IRC.
       */
      TOX_MESSAGE_TYPE_ACTION = 1
  }

  /**
   * Type of proxy used to connect to TCP relays.
   */
  enum TOX_PROXY_TYPE
  {
      /**
       * Don't use a proxy.
       */
      TOX_PROXY_TYPE_NONE = 0,

      /**
       * HTTP proxy using CONNECT.
       */
      TOX_PROXY_TYPE_HTTP = 1,

      /**
       * SOCKS proxy for simple socket pipes.
       */
      TOX_PROXY_TYPE_SOCKS5 = 2
  }

  /**
   * Type of savedata to create the Tox instance from.
   */
  enum TOX_SAVEDATA_TYPE
  {
      /**
       * No savedata.
       */
      TOX_SAVEDATA_TYPE_NONE = 0,

      /**
       * Savedata is one that was obtained from tox_get_savedata
       */
      TOX_SAVEDATA_TYPE_TOX_SAVE = 1,

      /**
       * Savedata is a secret key of length TOX_SECRET_KEY_SIZE
       */
      TOX_SAVEDATA_TYPE_SECRET_KEY = 2
  }

  enum TOX_ERR_OPTIONS_NEW
  {
      /**
       * The function returned successfully.
       */
      TOX_ERR_OPTIONS_NEW_OK = 0,

      /**
       * The function failed to allocate enough memory for the options struct.
       */
      TOX_ERR_OPTIONS_NEW_MALLOC = 1
  }

  enum TOX_ERR_NEW
  {
      /**
       * The function returned successfully.
       */
      TOX_ERR_NEW_OK = 0,

      /**
       * One of the arguments to the function was NULL when it was not expected.
       */
      TOX_ERR_NEW_NULL = 1,

      /**
       * The function was unable to allocate enough memory to store the internal
       * structures for the Tox object.
       */
      TOX_ERR_NEW_MALLOC = 2,

      /**
       * The function was unable to bind to a port. This may mean that all ports
       * have already been bound, e.g. by other Tox instances, or it may mean
       * a permission error. You may be able to gather more information from errno.
       */
      TOX_ERR_NEW_PORT_ALLOC = 3,

      /**
       * proxy_type was invalid.
       */
      TOX_ERR_NEW_PROXY_BAD_TYPE = 4,

      /**
       * proxy_type was valid but the proxy_host passed had an invalid format
       * or was NULL.
       */
      TOX_ERR_NEW_PROXY_BAD_HOST = 5,

      /**
       * proxy_type was valid, but the proxy_port was invalid.
       */
      TOX_ERR_NEW_PROXY_BAD_PORT = 6,

      /**
       * The proxy address passed could not be resolved.
       */
      TOX_ERR_NEW_PROXY_NOT_FOUND = 7,

      /**
       * The byte array to be loaded contained an encrypted save.
       */
      TOX_ERR_NEW_LOAD_ENCRYPTED = 8,

      /**
       * The data format was invalid. This can happen when loading data that was
       * saved by an older version of Tox, or when the data has been corrupted.
       * When loading from badly formatted data, some data may have been loaded,
       * and the rest is discarded. Passing an invalid length parameter also
       * causes this error.
       */
      TOX_ERR_NEW_LOAD_BAD_FORMAT = 9
  }

  enum TOX_ERR_BOOTSTRAP
  {
      /**
       * The function returned successfully.
       */
      TOX_ERR_BOOTSTRAP_OK = 0,

      /**
       * One of the arguments to the function was NULL when it was not expected.
       */
      TOX_ERR_BOOTSTRAP_NULL = 1,

      /**
       * The address could not be resolved to an IP address, or the IP address
       * passed was invalid.
       */
      TOX_ERR_BOOTSTRAP_BAD_HOST = 2,

      /**
       * The port passed was invalid. The valid port range is (1, 65535).
       */
      TOX_ERR_BOOTSTRAP_BAD_PORT = 3
  }

  /**
   * Protocols that can be used to connect to the network or friends.
   */
  enum TOX_CONNECTION
  {
      /**
       * There is no connection. This instance, or the friend the state change is
       * about, is now offline.
       */
      TOX_CONNECTION_NONE = 0,

      /**
       * A TCP connection has been established. For the own instance, this means it
       * is connected through a TCP relay, only. For a friend, this means that the
       * connection to that particular friend goes through a TCP relay.
       */
      TOX_CONNECTION_TCP = 1,

      /**
       * A UDP connection has been established. For the own instance, this means it
       * is able to send UDP packets to DHT nodes, but may still be connected to
       * a TCP relay. For a friend, this means that the connection to that
       * particular friend was built using direct UDP packets.
       */
      TOX_CONNECTION_UDP = 2
  }

  /**
   * Common error codes for all functions that set a piece of user-visible
   * client information.
   */
  enum TOX_ERR_SET_INFO
  {
      /**
       * The function returned successfully.
       */
      TOX_ERR_SET_INFO_OK = 0,

      /**
       * One of the arguments to the function was NULL when it was not expected.
       */
      TOX_ERR_SET_INFO_NULL = 1,

      /**
       * Information length exceeded maximum permissible size.
       */
      TOX_ERR_SET_INFO_TOO_LONG = 2
  }

  enum TOX_ERR_FRIEND_ADD
  {
      /**
       * The function returned successfully.
       */
      TOX_ERR_FRIEND_ADD_OK = 0,

      /**
       * One of the arguments to the function was NULL when it was not expected.
       */
      TOX_ERR_FRIEND_ADD_NULL = 1,

      /**
       * The length of the friend request message exceeded
       * TOX_MAX_FRIEND_REQUEST_LENGTH.
       */
      TOX_ERR_FRIEND_ADD_TOO_LONG = 2,

      /**
       * The friend request message was empty. This, and the TOO_LONG code will
       * never be returned from tox_friend_add_norequest.
       */
      TOX_ERR_FRIEND_ADD_NO_MESSAGE = 3,

      /**
       * The friend address belongs to the sending client.
       */
      TOX_ERR_FRIEND_ADD_OWN_KEY = 4,

      /**
       * A friend request has already been sent, or the address belongs to a friend
       * that is already on the friend list.
       */
      TOX_ERR_FRIEND_ADD_ALREADY_SENT = 5,

      /**
       * The friend address checksum failed.
       */
      TOX_ERR_FRIEND_ADD_BAD_CHECKSUM = 6,

      /**
       * The friend was already there, but the nospam value was different.
       */
      TOX_ERR_FRIEND_ADD_SET_NEW_NOSPAM = 7,

      /**
       * A memory allocation failed when trying to increase the friend list size.
       */
      TOX_ERR_FRIEND_ADD_MALLOC = 8
  }

  enum TOX_ERR_FRIEND_DELETE
  {
      /**
       * The function returned successfully.
       */
      TOX_ERR_FRIEND_DELETE_OK = 0,

      /**
       * There was no friend with the given friend number. No friends were deleted.
       */
      TOX_ERR_FRIEND_DELETE_FRIEND_NOT_FOUND = 1
  }

  enum TOX_ERR_FRIEND_BY_PUBLIC_KEY
  {
      /**
       * The function returned successfully.
       */
      TOX_ERR_FRIEND_BY_PUBLIC_KEY_OK = 0,

      /**
       * One of the arguments to the function was NULL when it was not expected.
       */
      TOX_ERR_FRIEND_BY_PUBLIC_KEY_NULL = 1,

      /**
       * No friend with the given Public Key exists on the friend list.
       */
      TOX_ERR_FRIEND_BY_PUBLIC_KEY_NOT_FOUND = 2
  }

  enum TOX_ERR_FRIEND_GET_PUBLIC_KEY
  {
      /**
       * The function returned successfully.
       */
      TOX_ERR_FRIEND_GET_PUBLIC_KEY_OK = 0,

      /**
       * No friend with the given number exists on the friend list.
       */
      TOX_ERR_FRIEND_GET_PUBLIC_KEY_FRIEND_NOT_FOUND = 1
  }

  enum TOX_ERR_FRIEND_GET_LAST_ONLINE
  {
      /**
       * The function returned successfully.
       */
      TOX_ERR_FRIEND_GET_LAST_ONLINE_OK = 0,

      /**
       * No friend with the given number exists on the friend list.
       */
      TOX_ERR_FRIEND_GET_LAST_ONLINE_FRIEND_NOT_FOUND = 1
  }

  /**
   * Common error codes for friend state query functions.
   */
  enum TOX_ERR_FRIEND_QUERY
  {
      /**
       * The function returned successfully.
       */
      TOX_ERR_FRIEND_QUERY_OK = 0,

      /**
       * The pointer parameter for storing the query result (name, message) was
       * NULL. Unlike the `_self_` variants of these functions, which have no effect
       * when a parameter is NULL, these functions return an error in that case.
       */
      TOX_ERR_FRIEND_QUERY_NULL = 1,

      /**
       * The friend_number did not designate a valid friend.
       */
      TOX_ERR_FRIEND_QUERY_FRIEND_NOT_FOUND = 2
  }

  enum TOX_ERR_SET_TYPING
  {
      /**
       * The function returned successfully.
       */
      TOX_ERR_SET_TYPING_OK = 0,

      /**
       * The friend number did not designate a valid friend.
       */
      TOX_ERR_SET_TYPING_FRIEND_NOT_FOUND = 1
  }

  enum TOX_ERR_FRIEND_SEND_MESSAGE
  {
      /**
       * The function returned successfully.
       */
      TOX_ERR_FRIEND_SEND_MESSAGE_OK = 0,

      /**
       * One of the arguments to the function was NULL when it was not expected.
       */
      TOX_ERR_FRIEND_SEND_MESSAGE_NULL = 1,

      /**
       * The friend number did not designate a valid friend.
       */
      TOX_ERR_FRIEND_SEND_MESSAGE_FRIEND_NOT_FOUND = 2,

      /**
       * This client is currently not connected to the friend.
       */
      TOX_ERR_FRIEND_SEND_MESSAGE_FRIEND_NOT_CONNECTED = 3,

      /**
       * An allocation error occurred while increasing the send queue size.
       */
      TOX_ERR_FRIEND_SEND_MESSAGE_SENDQ = 4,

      /**
       * Message length exceeded TOX_MAX_MESSAGE_LENGTH.
       */
      TOX_ERR_FRIEND_SEND_MESSAGE_TOO_LONG = 5,

      /**
       * Attempted to send a zero-length message.
       */
      TOX_ERR_FRIEND_SEND_MESSAGE_EMPTY = 6
  }

  enum TOX_FILE_KIND
  {
      /**
       * Arbitrary file data. Clients can choose to handle it based on the file name
       * or magic or any other way they choose.
       */
      TOX_FILE_KIND_DATA = 0,

      /**
       * Avatar file_id. This consists of tox_hash(image).
       * Avatar data. This consists of the image data.
       *
       * Avatars can be sent at any time the client wishes. Generally, a client will
       * send the avatar to a friend when that friend comes online, and to all
       * friends when the avatar changed. A client can save some traffic by
       * remembering which friend received the updated avatar already and only send
       * it if the friend has an out of date avatar.
       *
       * Clients who receive avatar send requests can reject it (by sending
       * TOX_FILE_CONTROL_CANCEL before any other controls), or accept it (by
       * sending TOX_FILE_CONTROL_RESUME). The file_id of length TOX_HASH_LENGTH bytes
       * (same length as TOX_FILE_ID_LENGTH) will contain the hash. A client can compare
       * this hash with a saved hash and send TOX_FILE_CONTROL_CANCEL to terminate the avatar
       * transfer if it matches.
       *
       * When file_size is set to 0 in the transfer request it means that the client
       * has no avatar.
       */
      TOX_FILE_KIND_AVATAR = 1
  }

  enum TOX_FILE_CONTROL
  {
      /**
       * Sent by the receiving side to accept a file send request. Also sent after a
       * TOX_FILE_CONTROL_PAUSE command to continue sending or receiving.
       */
      TOX_FILE_CONTROL_RESUME = 0,

      /**
       * Sent by clients to pause the file transfer. The initial state of a file
       * transfer is always paused on the receiving side and running on the sending
       * side. If both the sending and receiving side pause the transfer, then both
       * need to send TOX_FILE_CONTROL_RESUME for the transfer to resume.
       */
      TOX_FILE_CONTROL_PAUSE = 1,

      /**
       * Sent by the receiving side to reject a file send request before any other
       * commands are sent. Also sent by either side to terminate a file transfer.
       */
      TOX_FILE_CONTROL_CANCEL = 2
  }

  enum TOX_ERR_FILE_CONTROL
  {
      /**
       * The function returned successfully.
       */
      TOX_ERR_FILE_CONTROL_OK = 0,

      /**
       * The friend_number passed did not designate a valid friend.
       */
      TOX_ERR_FILE_CONTROL_FRIEND_NOT_FOUND = 1,

      /**
       * This client is currently not connected to the friend.
       */
      TOX_ERR_FILE_CONTROL_FRIEND_NOT_CONNECTED = 2,

      /**
       * No file transfer with the given file number was found for the given friend.
       */
      TOX_ERR_FILE_CONTROL_NOT_FOUND = 3,

      /**
       * A RESUME control was sent, but the file transfer is running normally.
       */
      TOX_ERR_FILE_CONTROL_NOT_PAUSED = 4,

      /**
       * A RESUME control was sent, but the file transfer was paused by the other
       * party. Only the party that paused the transfer can resume it.
       */
      TOX_ERR_FILE_CONTROL_DENIED = 5,

      /**
       * A PAUSE control was sent, but the file transfer was already paused.
       */
      TOX_ERR_FILE_CONTROL_ALREADY_PAUSED = 6,

      /**
       * Packet queue is full.
       */
      TOX_ERR_FILE_CONTROL_SENDQ = 7
  }

  enum TOX_ERR_FILE_SEEK
  {
      /**
       * The function returned successfully.
       */
      TOX_ERR_FILE_SEEK_OK = 0,

      /**
       * The friend_number passed did not designate a valid friend.
       */
      TOX_ERR_FILE_SEEK_FRIEND_NOT_FOUND = 1,

      /**
       * This client is currently not connected to the friend.
       */
      TOX_ERR_FILE_SEEK_FRIEND_NOT_CONNECTED = 2,

      /**
       * No file transfer with the given file number was found for the given friend.
       */
      TOX_ERR_FILE_SEEK_NOT_FOUND = 3,

      /**
       * File was not in a state where it could be seeked.
       */
      TOX_ERR_FILE_SEEK_DENIED = 4,

      /**
       * Seek position was invalid
       */
      TOX_ERR_FILE_SEEK_INVALID_POSITION = 5,

      /**
       * Packet queue is full.
       */
      TOX_ERR_FILE_SEEK_SENDQ = 6
  }

  enum TOX_ERR_FILE_GET
  {
      /**
       * The function returned successfully.
       */
      TOX_ERR_FILE_GET_OK = 0,

      /**
       * One of the arguments to the function was NULL when it was not expected.
       */
      TOX_ERR_FILE_GET_NULL = 1,

      /**
       * The friend_number passed did not designate a valid friend.
       */
      TOX_ERR_FILE_GET_FRIEND_NOT_FOUND = 2,

      /**
       * No file transfer with the given file number was found for the given friend.
       */
      TOX_ERR_FILE_GET_NOT_FOUND = 3
  }

  enum TOX_ERR_FILE_SEND
  {
      /**
       * The function returned successfully.
       */
      TOX_ERR_FILE_SEND_OK = 0,

      /**
       * One of the arguments to the function was NULL when it was not expected.
       */
      TOX_ERR_FILE_SEND_NULL = 1,

      /**
       * The friend_number passed did not designate a valid friend.
       */
      TOX_ERR_FILE_SEND_FRIEND_NOT_FOUND = 2,

      /**
       * This client is currently not connected to the friend.
       */
      TOX_ERR_FILE_SEND_FRIEND_NOT_CONNECTED = 3,

      /**
       * Filename length exceeded TOX_MAX_FILENAME_LENGTH bytes.
       */
      TOX_ERR_FILE_SEND_NAME_TOO_LONG = 4,

      /**
       * Too many ongoing transfers. The maximum number of concurrent file transfers
       * is 256 per friend per direction (sending and receiving).
       */
      TOX_ERR_FILE_SEND_TOO_MANY = 5
  }

  enum TOX_ERR_FILE_SEND_CHUNK
  {
      /**
       * The function returned successfully.
       */
      TOX_ERR_FILE_SEND_CHUNK_OK = 0,

      /**
       * The length parameter was non-zero, but data was NULL.
       */
      TOX_ERR_FILE_SEND_CHUNK_NULL = 1,

      /**
       * The friend_number passed did not designate a valid friend.
       */
      TOX_ERR_FILE_SEND_CHUNK_FRIEND_NOT_FOUND = 2,

      /**
       * This client is currently not connected to the friend.
       */
      TOX_ERR_FILE_SEND_CHUNK_FRIEND_NOT_CONNECTED = 3,

      /**
       * No file transfer with the given file number was found for the given friend.
       */
      TOX_ERR_FILE_SEND_CHUNK_NOT_FOUND = 4,

      /**
       * File transfer was found but isn't in a transferring state: (paused, done,
       * broken, etc...) (happens only when not called from the request chunk callback).
       */
      TOX_ERR_FILE_SEND_CHUNK_NOT_TRANSFERRING = 5,

      /**
       * Attempted to send more or less data than requested. The requested data size is
       * adjusted according to maximum transmission unit and the expected end of
       * the file. Trying to send less or more than requested will return this error.
       */
      TOX_ERR_FILE_SEND_CHUNK_INVALID_LENGTH = 6,

      /**
       * Packet queue is full.
       */
      TOX_ERR_FILE_SEND_CHUNK_SENDQ = 7,

      /**
       * Position parameter was wrong.
       */
      TOX_ERR_FILE_SEND_CHUNK_WRONG_POSITION = 8
  }

  enum TOX_ERR_FRIEND_CUSTOM_PACKET
  {
      /**
       * The function returned successfully.
       */
      TOX_ERR_FRIEND_CUSTOM_PACKET_OK = 0,

      /**
       * One of the arguments to the function was NULL when it was not expected.
       */
      TOX_ERR_FRIEND_CUSTOM_PACKET_NULL = 1,

      /**
       * The friend number did not designate a valid friend.
       */
      TOX_ERR_FRIEND_CUSTOM_PACKET_FRIEND_NOT_FOUND = 2,

      /**
       * This client is currently not connected to the friend.
       */
      TOX_ERR_FRIEND_CUSTOM_PACKET_FRIEND_NOT_CONNECTED = 3,

      /**
       * The first byte of data was not in the specified range for the packet type.
       * This range is 200-254 for lossy, and 160-191 for lossless packets.
       */
      TOX_ERR_FRIEND_CUSTOM_PACKET_INVALID = 4,

      /**
       * Attempted to send an empty packet.
       */
      TOX_ERR_FRIEND_CUSTOM_PACKET_EMPTY = 5,

      /**
       * Packet data length exceeded TOX_MAX_CUSTOM_PACKET_SIZE.
       */
      TOX_ERR_FRIEND_CUSTOM_PACKET_TOO_LONG = 6,

      /**
       * Packet queue is full.
       */
      TOX_ERR_FRIEND_CUSTOM_PACKET_SENDQ = 7
  }

  enum TOX_ERR_GET_PORT
  {
      /**
       * The function returned successfully.
       */
      TOX_ERR_GET_PORT_OK = 0,

      /**
       * The instance was not bound to any port.
       */
      TOX_ERR_GET_PORT_NOT_BOUND = 1
  }

  struct Tox_Options
  {
      bool ipv6_enabled;
      bool udp_enabled;
      TOX_PROXY_TYPE proxy_type;
      const(char)* proxy_host;
      ushort proxy_port;
      ushort start_port;
      ushort end_port;
      ushort tcp_port;
      TOX_SAVEDATA_TYPE savedata_type;
      const(ubyte)* savedata_data;
      size_t savedata_length;
  }

  struct Tox;


  // uint tox_version_major ();
  // uint tox_version_minor ();
  // uint tox_version_patch ();
  // bool tox_version_is_compatible (uint major, uint minor, uint patch);

  void tox_options_default (Tox_Options* options);
  Tox_Options* tox_options_new (TOX_ERR_OPTIONS_NEW* error);
  void tox_options_free (Tox_Options* options);
  Tox* tox_new (const(Tox_Options)* options, TOX_ERR_NEW* error);
  void tox_kill (Tox* tox);
  size_t tox_get_savedata_size (const(Tox)* tox);
  void tox_get_savedata (const(Tox)* tox, ubyte* savedata);
  bool tox_bootstrap (Tox* tox, const(char)* address, ushort port, const(ubyte)* public_key, TOX_ERR_BOOTSTRAP* error);
  bool tox_add_tcp_relay (Tox* tox, const(char)* address, ushort port, const(ubyte)* public_key, TOX_ERR_BOOTSTRAP* error);
  TOX_CONNECTION tox_self_get_connection_status (const(Tox)* tox);
  void tox_callback_self_connection_status (Tox* tox, void function (Tox*, TOX_CONNECTION, void*) callback, void* user_data);
  uint tox_iteration_interval (const(Tox)* tox);
  void tox_iterate (Tox* tox);
  void tox_self_get_address (const(Tox)* tox, ubyte* address);
  void tox_self_set_nospam (Tox* tox, uint nospam);
  uint tox_self_get_nospam (const(Tox)* tox);
  void tox_self_get_public_key (const(Tox)* tox, ubyte* public_key);
  void tox_self_get_secret_key (const(Tox)* tox, ubyte* secret_key);
  bool tox_self_set_name (Tox* tox, const(ubyte)* name, size_t length, TOX_ERR_SET_INFO* error);
  size_t tox_self_get_name_size (const(Tox)* tox);
  void tox_self_get_name (const(Tox)* tox, ubyte* name);
  bool tox_self_set_status_message (Tox* tox, const(ubyte)* status_message, size_t length, TOX_ERR_SET_INFO* error);
  size_t tox_self_get_status_message_size (const(Tox)* tox);
  void tox_self_get_status_message (const(Tox)* tox, ubyte* status_message);
  void tox_self_set_status (Tox* tox, TOX_USER_STATUS status);
  TOX_USER_STATUS tox_self_get_status (const(Tox)* tox);
  uint tox_friend_add (Tox* tox, const(ubyte)* address, const(ubyte)* message, size_t length, TOX_ERR_FRIEND_ADD* error);
  uint tox_friend_add_norequest (Tox* tox, const(ubyte)* public_key, TOX_ERR_FRIEND_ADD* error);
  bool tox_friend_delete (Tox* tox, uint friend_number, TOX_ERR_FRIEND_DELETE* error);
  uint tox_friend_by_public_key (const(Tox)* tox, const(ubyte)* public_key, TOX_ERR_FRIEND_BY_PUBLIC_KEY* error);
  bool tox_friend_exists (const(Tox)* tox, uint friend_number);
  size_t tox_self_get_friend_list_size (const(Tox)* tox);
  void tox_self_get_friend_list (const(Tox)* tox, uint* friend_list);
  bool tox_friend_get_public_key (const(Tox)* tox, uint friend_number, ubyte* public_key, TOX_ERR_FRIEND_GET_PUBLIC_KEY* error);
  ulong tox_friend_get_last_online (const(Tox)* tox, uint friend_number, TOX_ERR_FRIEND_GET_LAST_ONLINE* error);
  size_t tox_friend_get_name_size (const(Tox)* tox, uint friend_number, TOX_ERR_FRIEND_QUERY* error);
  bool tox_friend_get_name (const(Tox)* tox, uint friend_number, ubyte* name, TOX_ERR_FRIEND_QUERY* error);
  void tox_callback_friend_name (Tox* tox, void function (Tox*, uint, const(ubyte)*, size_t, void*) callback, void* user_data);
  size_t tox_friend_get_status_message_size (const(Tox)* tox, uint friend_number, TOX_ERR_FRIEND_QUERY* error);
  bool tox_friend_get_status_message (const(Tox)* tox, uint friend_number, ubyte* status_message, TOX_ERR_FRIEND_QUERY* error);
  void tox_callback_friend_status_message (Tox* tox, void function (Tox*, uint, const(ubyte)*, size_t, void*) callback, void* user_data);
  TOX_USER_STATUS tox_friend_get_status (const(Tox)* tox, uint friend_number, TOX_ERR_FRIEND_QUERY* error);
  void tox_callback_friend_status (Tox* tox, void function (Tox*, uint, TOX_USER_STATUS, void*) callback, void* user_data);
  TOX_CONNECTION tox_friend_get_connection_status (const(Tox)* tox, uint friend_number, TOX_ERR_FRIEND_QUERY* error);
  void tox_callback_friend_connection_status (Tox* tox, void function (Tox*, uint, TOX_CONNECTION, void*) callback, void* user_data);
  bool tox_friend_get_typing (const(Tox)* tox, uint friend_number, TOX_ERR_FRIEND_QUERY* error);
  void tox_callback_friend_typing (Tox* tox, void function (Tox*, uint, bool, void*) callback, void* user_data);
  bool tox_self_set_typing (Tox* tox, uint friend_number, bool typing, TOX_ERR_SET_TYPING* error);
  uint tox_friend_send_message (Tox* tox, uint friend_number, TOX_MESSAGE_TYPE type, const(ubyte)* message, size_t length, TOX_ERR_FRIEND_SEND_MESSAGE* error);
  void tox_callback_friend_read_receipt (Tox* tox, void function (Tox*, uint, uint, void*) callback, void* user_data);
  void tox_callback_friend_request (Tox* tox, void function (Tox*, const(ubyte)*, const(ubyte)*, size_t, void*) callback, void* user_data);
  void tox_callback_friend_message (Tox* tox, void function (Tox*, uint, TOX_MESSAGE_TYPE, const(ubyte)*, size_t, void*) callback, void* user_data);
  bool tox_hash (ubyte* hash, const(ubyte)* data, size_t length);
  bool tox_file_control (Tox* tox, uint friend_number, uint file_number, TOX_FILE_CONTROL control, TOX_ERR_FILE_CONTROL* error);
  void tox_callback_file_recv_control (Tox* tox, void function (Tox*, uint, uint, TOX_FILE_CONTROL, void*) callback, void* user_data);
  bool tox_file_seek (Tox* tox, uint friend_number, uint file_number, ulong position, TOX_ERR_FILE_SEEK* error);
  bool tox_file_get_file_id (const(Tox)* tox, uint friend_number, uint file_number, ubyte* file_id, TOX_ERR_FILE_GET* error);
  uint tox_file_send (Tox* tox, uint friend_number, uint kind, ulong file_size, const(ubyte)* file_id, const(ubyte)* filename, size_t filename_length, TOX_ERR_FILE_SEND* error);
  bool tox_file_send_chunk (Tox* tox, uint friend_number, uint file_number, ulong position, const(ubyte)* data, size_t length, TOX_ERR_FILE_SEND_CHUNK* error);
  void tox_callback_file_chunk_request (Tox* tox, void function (Tox*, uint, uint, ulong, size_t, void*) callback, void* user_data);
  void tox_callback_file_recv (Tox* tox, void function (Tox*, uint, uint, uint, ulong, const(ubyte)*, size_t, void*) callback, void* user_data);
  void tox_callback_file_recv_chunk (Tox* tox, void function (Tox*, uint, uint, ulong, const(ubyte)*, size_t, void*) callback, void* user_data);
  bool tox_friend_send_lossy_packet (Tox* tox, uint friend_number, const(ubyte)* data, size_t length, TOX_ERR_FRIEND_CUSTOM_PACKET* error);
  bool tox_friend_send_lossless_packet (Tox* tox, uint friend_number, const(ubyte)* data, size_t length, TOX_ERR_FRIEND_CUSTOM_PACKET* error);
  void tox_callback_friend_lossy_packet (Tox* tox, void function (Tox*, uint, const(ubyte)*, size_t, void*) callback, void* user_data);
  void tox_callback_friend_lossless_packet (Tox* tox, void function (Tox*, uint, const(ubyte)*, size_t, void*) callback, void* user_data);
  void tox_self_get_dht_id (const(Tox)* tox, ubyte* dht_id);
  ushort tox_self_get_udp_port (const(Tox)* tox, TOX_ERR_GET_PORT* error);
  ushort tox_self_get_tcp_port (const(Tox)* tox, TOX_ERR_GET_PORT* error);
  void tox_callback_group_invite (Tox* tox, void function (Tox*, int, ubyte, const(ubyte)*, ushort, void*) function_, void* userdata);
  void tox_callback_group_message (Tox* tox, void function (Tox*, int, int, const(ubyte)*, ushort, void*) function_, void* userdata);
  void tox_callback_group_action (Tox* tox, void function (Tox*, int, int, const(ubyte)*, ushort, void*) function_, void* userdata);
  void tox_callback_group_title (Tox* tox, void function (Tox*, int, int, const(ubyte)*, ubyte, void*) function_, void* userdata);
  void tox_callback_group_namelist_change (Tox* tox, void function (Tox*, int, int, ubyte, void*) function_, void* userdata);
  int tox_add_groupchat (Tox* tox);
  int tox_del_groupchat (Tox* tox, int groupnumber);
  int tox_group_peername (const(Tox)* tox, int groupnumber, int peernumber, ubyte* name);
  int tox_group_peer_pubkey (const(Tox)* tox, int groupnumber, int peernumber, ubyte* public_key);
  int tox_invite_friend (Tox* tox, int friendnumber, int groupnumber);
  int tox_join_groupchat (Tox* tox, int friendnumber, const(ubyte)* data, ushort length);
  int tox_group_message_send (Tox* tox, int groupnumber, const(ubyte)* message, ushort length);
  int tox_group_action_send (Tox* tox, int groupnumber, const(ubyte)* action, ushort length);
  int tox_group_set_title (Tox* tox, int groupnumber, const(ubyte)* title, ubyte length);
  int tox_group_get_title (Tox* tox, int groupnumber, ubyte* title, uint max_length);
  uint tox_group_peernumber_is_ours (const(Tox)* tox, int groupnumber, int peernumber);
  int tox_group_number_peers (const(Tox)* tox, int groupnumber);
  int tox_group_get_names (const(Tox)* tox, int groupnumber, uint[] names, uint[] lengths, ushort length);
  uint tox_count_chatlist (const(Tox)* tox);
  uint tox_get_chatlist (const(Tox)* tox, int* out_list, uint list_size);
  int tox_group_get_type (const(Tox)* tox, int groupnumber);
}
