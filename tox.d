/* ToxD Copyright (C) 2016 Ogromny
 * The Tox public API.
 *
 *  Copyright (C) 2013 Tox project All Rights Reserved.
 *
 *  This file is part of Tox.
 *
 *  Tox is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  Tox is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Tox.  If not, see <http://www.gnu.org/licenses/>.
 *
 */
module tox;

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
    TOX_ADDRESS_SIZE = (TOX_PUBLIC_KEY_SIZE + uint.sizeof + ushort.sizeof), // not exactly but work
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
    /* Group chat types for tox_callback_group_invite function.
     *
     * TOX_GROUPCHAT_TYPE_TEXT groupchats must be accepted with the tox_join_groupchat() function.
     * The function to accept TOX_GROUPCHAT_TYPE_AV is in toxav.
     */
    TOX_GROUPCHAT_TYPE_TEXT = 0,
    TOX_GROUPCHAT_TYPE_AV = 1,
  }

  enum TOX_CHAT_CHANGE
  {
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

  /**
   * This struct contains all the startup options for Tox. You can either allocate
   * this object yourself, and pass it to tox_options_default, or call
   * tox_options_new to get a new default options object.
   */
  struct Tox_Options
  {
    /**
     * The type of socket to create.
     *
     * If this is set to false, an IPv4 socket is created, which subsequently
     * only allows IPv4 communication.
     * If it is set to true, an IPv6 socket is created, allowing both IPv4 and
     * IPv6 communication.
     */
    bool ipv6_enabled;
    /**
     * Enable the use of UDP communication when available.
     *
     * Setting this to false will force Tox to use TCP only. Communications will
     * need to be relayed through a TCP relay node, potentially slowing them down.
     * Disabling UDP support is necessary when using anonymous proxies or Tor.
     */
    bool udp_enabled;
    /**
     * Pass communications through a proxy.
     */
    TOX_PROXY_TYPE proxy_type;
    /**
     * The IP address or DNS name of the proxy to be used.
     *
     * If used, this must be non-NULL and be a valid DNS name. The name must not
     * exceed 255 characters, and be in a NUL-terminated C string format
     * (255 chars + 1 NUL byte).
     *
     * This member is ignored (it can be NULL) if proxy_type is TOX_PROXY_TYPE_NONE.
     */
    const(char)* proxy_host;
    /**
     * The port to use to connect to the proxy server.
     *
     * Ports must be in the range (1, 65535). The value is ignored if
     * proxy_type is TOX_PROXY_TYPE_NONE.
     */
    ushort proxy_port;
    /**
     * The start port of the inclusive port range to attempt to use.
     *
     * If both start_port and end_port are 0, the default port range will be
     * used: [33445, 33545].
     *
     * If either start_port or end_port is 0 while the other is non-zero, the
     * non-zero port will be the only port in the range.
     *
     * Having start_port > end_port will yield the same behavior as if start_port
     * and end_port were swapped.
     */
    ushort start_port;
    /**
     * The end port of the inclusive port range to attempt to use.
     */
    ushort end_port;
    /**
     * The port to use for the TCP server (relay). If 0, the TCP server is
     * disabled.
     *
     * Enabling it is not required for Tox to function properly.
     *
     * When enabled, your Tox instance can act as a TCP relay for other Tox
     * instance. This leads to increased traffic, thus when writing a client
     * it is recommended to enable TCP server only if the user has an option
     * to disable it.
     */
    ushort tcp_port;
    /**
     * The type of savedata to load from.
     */
    TOX_SAVEDATA_TYPE savedata_type;
    /**
     * The savedata.
     */
    const(ubyte)* savedata_data;
    /**
     * The length of the savedata.
     */
    size_t savedata_length;
  }

  struct Tox;


  // uint tox_version_major ();

  // uint tox_version_minor ();

  // uint tox_version_patch ();

  // bool tox_version_is_compatible (uint major, uint minor, uint patch);

  /**
   * Initialises a Tox_Options object with the default options.
   *
   * The result of this function is independent of the original options. All
   * values will be overwritten, no values will be read (so it is permissible
   * to pass an uninitialised object).
   *
   * If options is NULL, this function has no effect.
   *
   * @param options An options object to be filled with default options.
   */
  void tox_options_default (Tox_Options* options);

  /**
   * Allocates a new Tox_Options object and initialises it with the default
   * options. This function can be used to preserve long term ABI compatibility by
   * giving the responsibility of allocation and deallocation to the Tox library.
   *
   * Objects returned from this function must be freed using the tox_options_free
   * function.
   *
   * @return A new Tox_Options object with default options or NULL on failure.
   */
  Tox_Options* tox_options_new (TOX_ERR_OPTIONS_NEW* error);

  /**
   * Releases all resources associated with an options objects.
   *
   * Passing a pointer that was not returned by tox_options_new results in
   * undefined behaviour.
   */
  void tox_options_free (Tox_Options* options);

  /**
   * @brief Creates and initialises a new Tox instance with the options passed.
   *
   * This function will bring the instance into a valid state. Running the event
   * loop with a new instance will operate correctly.
   *
   * If loading failed or succeeded only partially, the new or partially loaded
   * instance is returned and an error code is set.
   *
   * @param options An options object as described above. If this parameter is
   *   NULL, the default options are used.
   *
   * @see tox_iterate for the event loop.
   *
   * @return A new Tox instance pointer on success or NULL on failure.
   */
  Tox* tox_new (const(Tox_Options)* options, TOX_ERR_NEW* error);

  /**
   * Releases all resources associated with the Tox instance and disconnects from
   * the network.
   *
   * After calling this function, the Tox pointer becomes invalid. No other
   * functions can be called, and the pointer value can no longer be read.
   */
  void tox_kill (Tox* tox);

  /**
   * Calculates the number of bytes required to store the tox instance with
   * tox_get_savedata. This function cannot fail. The result is always greater than 0.
   *
   * @see threading for concurrency implications.
   */
  size_t tox_get_savedata_size (const(Tox)* tox);

  /**
   * Store all information associated with the tox instance to a byte array.
   *
   * @param data A memory region large enough to store the tox instance data.
   *   Call tox_get_savedata_size to find the number of bytes required. If this parameter
   *   is NULL, this function has no effect.
   */
  void tox_get_savedata (const(Tox)* tox, ubyte* savedata);

  /**
   * Sends a "get nodes" request to the given bootstrap node with IP, port, and
   * public key to setup connections.
   *
   * This function will attempt to connect to the node using UDP. You must use
   * this function even if Tox_Options.udp_enabled was set to false.
   *
   * @param address The hostname or IP address (IPv4 or IPv6) of the node.
   * @param port The port on the host on which the bootstrap Tox instance is
   *   listening.
   * @param public_key The long term public key of the bootstrap node
   *   (TOX_PUBLIC_KEY_SIZE bytes).
   * @return true on success.
   */
  bool tox_bootstrap (Tox* tox, const(char)* address, ushort port, const(ubyte)* public_key, TOX_ERR_BOOTSTRAP* error);

  /**
   * Adds additional host:port pair as TCP relay.
   *
   * This function can be used to initiate TCP connections to different ports on
   * the same bootstrap node, or to add TCP relays without using them as
   * bootstrap nodes.
   *
   * @param address The hostname or IP address (IPv4 or IPv6) of the TCP relay.
   * @param port The port on the host on which the TCP relay is listening.
   * @param public_key The long term public key of the TCP relay
   *   (TOX_PUBLIC_KEY_SIZE bytes).
   * @return true on success.
   */
  bool tox_add_tcp_relay (Tox* tox, const(char)* address, ushort port, const(ubyte)* public_key, TOX_ERR_BOOTSTRAP* error);

  /**
   * Return whether we are connected to the DHT. The return value is equal to the
   * last value received through the `self_connection_status` callback.
   */
  TOX_CONNECTION tox_self_get_connection_status (const(Tox)* tox);

  /**
   * Set the callback for the `self_connection_status` event. Pass NULL to unset.
   *
   * This event is triggered whenever there is a change in the DHT connection
   * state. When disconnected, a client may choose to call tox_bootstrap again, to
   * reconnect to the DHT. Note that this state may frequently change for short
   * amounts of time. Clients should therefore not immediately bootstrap on
   * receiving a disconnect.
   *
   * TODO: how long should a client wait before bootstrapping again?
   */
  void tox_callback_self_connection_status (Tox* tox, void function (Tox*, TOX_CONNECTION, void*) callback, void* user_data);

  /**
   * Return the time in milliseconds before tox_iterate() should be called again
   * for optimal performance.
   */
  uint tox_iteration_interval (const(Tox)* tox);

  /**
   * The main loop that needs to be run in intervals of tox_iteration_interval()
   * milliseconds.
   */
  void tox_iterate (Tox* tox);

  /**
   * Writes the Tox friend address of the client to a byte array. The address is
   * not in human-readable format. If a client wants to display the address,
   * formatting is required.
   *
   * @param address A memory region of at least TOX_ADDRESS_SIZE bytes. If this
   *   parameter is NULL, this function has no effect.
   * @see TOX_ADDRESS_SIZE for the address format.
   */
  void tox_self_get_address (const(Tox)* tox, ubyte* address);

  /**
   * Set the 4-byte nospam part of the address.
   *
   * @param nospam Any 32 bit unsigned integer.
   */
  void tox_self_set_nospam (Tox* tox, uint nospam);

  /**
   * Get the 4-byte nospam part of the address.
   */
  uint tox_self_get_nospam (const(Tox)* tox);

  /**
   * Copy the Tox Public Key (long term) from the Tox object.
   *
   * @param public_key A memory region of at least TOX_PUBLIC_KEY_SIZE bytes. If
   *   this parameter is NULL, this function has no effect.
   */
  void tox_self_get_public_key (const(Tox)* tox, ubyte* public_key);

  /**
   * Copy the Tox Secret Key from the Tox object.
   *
   * @param secret_key A memory region of at least TOX_SECRET_KEY_SIZE bytes. If
   *   this parameter is NULL, this function has no effect.
   */
  void tox_self_get_secret_key (const(Tox)* tox, ubyte* secret_key);

  /**
   * Set the nickname for the Tox client.
   *
   * Nickname length cannot exceed TOX_MAX_NAME_LENGTH. If length is 0, the name
   * parameter is ignored (it can be NULL), and the nickname is set back to empty.
   *
   * @param name A byte array containing the new nickname.
   * @param length The size of the name byte array.
   *
   * @return true on success.
   */
  bool tox_self_set_name (Tox* tox, const(ubyte)* name, size_t length, TOX_ERR_SET_INFO* error);

  /**
   * Return the length of the current nickname as passed to tox_self_set_name.
   *
   * If no nickname was set before calling this function, the name is empty,
   * and this function returns 0.
   *
   * @see threading for concurrency implications.
   */
  size_t tox_self_get_name_size (const(Tox)* tox);

  /**
   * Write the nickname set by tox_self_set_name to a byte array.
   *
   * If no nickname was set before calling this function, the name is empty,
   * and this function has no effect.
   *
   * Call tox_self_get_name_size to find out how much memory to allocate for
   * the result.
   *
   * @param name A valid memory location large enough to hold the nickname.
   *   If this parameter is NULL, the function has no effect.
   */
  void tox_self_get_name (const(Tox)* tox, ubyte* name);

  /**
   * Set the client's status message.
   *
   * Status message length cannot exceed TOX_MAX_STATUS_MESSAGE_LENGTH. If
   * length is 0, the status parameter is ignored (it can be NULL), and the
   * user status is set back to empty.
   */
  bool tox_self_set_status_message (Tox* tox, const(ubyte)* status_message, size_t length, TOX_ERR_SET_INFO* error);

  /**
   * Return the length of the current status message as passed to tox_self_set_status_message.
   *
   * If no status message was set before calling this function, the status
   * is empty, and this function returns 0.
   *
   * @see threading for concurrency implications.
   */
  size_t tox_self_get_status_message_size (const(Tox)* tox);

  /**
   * Write the status message set by tox_self_set_status_message to a byte array.
   *
   * If no status message was set before calling this function, the status is
   * empty, and this function has no effect.
   *
   * Call tox_self_get_status_message_size to find out how much memory to allocate for
   * the result.
   *
   * @param status A valid memory location large enough to hold the status message.
   *   If this parameter is NULL, the function has no effect.
   */
  void tox_self_get_status_message (const(Tox)* tox, ubyte* status_message);

  /**
   * Set the client's user status.
   *
   * @param user_status One of the user statuses listed in the enumeration above.
   */
  void tox_self_set_status (Tox* tox, TOX_USER_STATUS status);

  /**
   * Returns the client's user status.
   */
  TOX_USER_STATUS tox_self_get_status (const(Tox)* tox);

  /**
   * Add a friend to the friend list and send a friend request.
   *
   * A friend request message must be at least 1 byte long and at most
   * TOX_MAX_FRIEND_REQUEST_LENGTH.
   *
   * Friend numbers are unique identifiers used in all functions that operate on
   * friends. Once added, a friend number is stable for the lifetime of the Tox
   * object. After saving the state and reloading it, the friend numbers may not
   * be the same as before. Deleting a friend creates a gap in the friend number
   * set, which is filled by the next adding of a friend. Any pattern in friend
   * numbers should not be relied on.
   *
   * If more than INT32_MAX friends are added, this function causes undefined
   * behaviour.
   *
   * @param address The address of the friend (returned by tox_self_get_address of
   *   the friend you wish to add) it must be TOX_ADDRESS_SIZE bytes.
   * @param message The message that will be sent along with the friend request.
   * @param length The length of the data byte array.
   *
   * @return the friend number on success, UINT32_MAX on failure.
   */
  uint tox_friend_add (Tox* tox, const(ubyte)* address, const(ubyte)* message, size_t length, TOX_ERR_FRIEND_ADD* error);

  /**
   * Add a friend without sending a friend request.
   *
   * This function is used to add a friend in response to a friend request. If the
   * client receives a friend request, it can be reasonably sure that the other
   * client added this client as a friend, eliminating the need for a friend
   * request.
   *
   * This function is also useful in a situation where both instances are
   * controlled by the same entity, so that this entity can perform the mutual
   * friend adding. In this case, there is no need for a friend request, either.
   *
   * @param public_key A byte array of length TOX_PUBLIC_KEY_SIZE containing the
   *   Public Key (not the Address) of the friend to add.
   *
   * @return the friend number on success, UINT32_MAX on failure.
   * @see tox_friend_add for a more detailed description of friend numbers.
   */
  uint tox_friend_add_norequest (Tox* tox, const(ubyte)* public_key, TOX_ERR_FRIEND_ADD* error);

  /**
   * Remove a friend from the friend list.
   *
   * This does not notify the friend of their deletion. After calling this
   * function, this client will appear offline to the friend and no communication
   * can occur between the two.
   *
   * @param friend_number Friend number for the friend to be deleted.
   *
   * @return true on success.
   */
  bool tox_friend_delete (Tox* tox, uint friend_number, TOX_ERR_FRIEND_DELETE* error);

  /**
   * Return the friend number associated with that Public Key.
   *
   * @return the friend number on success, UINT32_MAX on failure.
   * @param public_key A byte array containing the Public Key.
   */
  uint tox_friend_by_public_key (const(Tox)* tox, const(ubyte)* public_key, TOX_ERR_FRIEND_BY_PUBLIC_KEY* error);

  /**
   * Checks if a friend with the given friend number exists and returns true if
   * it does.
   */
  bool tox_friend_exists (const(Tox)* tox, uint friend_number);

  /**
   * Return the number of friends on the friend list.
   *
   * This function can be used to determine how much memory to allocate for
   * tox_self_get_friend_list.
   */
  size_t tox_self_get_friend_list_size (const(Tox)* tox);

  /**
   * Copy a list of valid friend numbers into an array.
   *
   * Call tox_self_get_friend_list_size to determine the number of elements to allocate.
   *
   * @param list A memory region with enough space to hold the friend list. If
   *   this parameter is NULL, this function has no effect.
   */
  void tox_self_get_friend_list (const(Tox)* tox, uint* friend_list);

  /**
   * Copies the Public Key associated with a given friend number to a byte array.
   *
   * @param friend_number The friend number you want the Public Key of.
   * @param public_key A memory region of at least TOX_PUBLIC_KEY_SIZE bytes. If
   *   this parameter is NULL, this function has no effect.
   *
   * @return true on success.
   */
  bool tox_friend_get_public_key (const(Tox)* tox, uint friend_number, ubyte* public_key, TOX_ERR_FRIEND_GET_PUBLIC_KEY* error);

  /**
   * Return a unix-time timestamp of the last time the friend associated with a given
   * friend number was seen online. This function will return UINT64_MAX on error.
   *
   * @param friend_number The friend number you want to query.
   */
  ulong tox_friend_get_last_online (const(Tox)* tox, uint friend_number, TOX_ERR_FRIEND_GET_LAST_ONLINE* error);

  /**
   * Return the length of the friend's name. If the friend number is invalid, the
   * return value is unspecified.
   *
   * The return value is equal to the `length` argument received by the last
   * `friend_name` callback.
   */
  size_t tox_friend_get_name_size (const(Tox)* tox, uint friend_number, TOX_ERR_FRIEND_QUERY* error);

  /**
   * Write the name of the friend designated by the given friend number to a byte
   * array.
   *
   * Call tox_friend_get_name_size to determine the allocation size for the `name`
   * parameter.
   *
   * The data written to `name` is equal to the data received by the last
   * `friend_name` callback.
   *
   * @param name A valid memory region large enough to store the friend's name.
   *
   * @return true on success.
   */
  bool tox_friend_get_name (const(Tox)* tox, uint friend_number, ubyte* name, TOX_ERR_FRIEND_QUERY* error);

  /**
   * Set the callback for the `friend_name` event. Pass NULL to unset.
   *
   * This event is triggered when a friend changes their name.
   */
  void tox_callback_friend_name (Tox* tox, void function (Tox*, uint, const(ubyte)*, size_t, void*) callback, void* user_data);

  /**
   * Return the length of the friend's status message. If the friend number is
   * invalid, the return value is SIZE_MAX.
   */
  size_t tox_friend_get_status_message_size (const(Tox)* tox, uint friend_number, TOX_ERR_FRIEND_QUERY* error);

  /**
   * Write the status message of the friend designated by the given friend number to a byte
   * array.
   *
   * Call tox_friend_get_status_message_size to determine the allocation size for the `status_name`
   * parameter.
   *
   * The data written to `status_message` is equal to the data received by the last
   * `friend_status_message` callback.
   *
   * @param status_message A valid memory region large enough to store the friend's status message.
   */
  bool tox_friend_get_status_message (const(Tox)* tox, uint friend_number, ubyte* status_message, TOX_ERR_FRIEND_QUERY* error);

  /**
   * Set the callback for the `friend_status_message` event. Pass NULL to unset.
   *
   * This event is triggered when a friend changes their status message.
   */
  void tox_callback_friend_status_message (Tox* tox, void function (Tox*, uint, const(ubyte)*, size_t, void*) callback, void* user_data);

  /**
   * Return the friend's user status (away/busy/...). If the friend number is
   * invalid, the return value is unspecified.
   *
   * The status returned is equal to the last status received through the
   * `friend_status` callback.
   */
  TOX_USER_STATUS tox_friend_get_status (const(Tox)* tox, uint friend_number, TOX_ERR_FRIEND_QUERY* error);

  /**
   * Set the callback for the `friend_status` event. Pass NULL to unset.
   *
   * This event is triggered when a friend changes their user status.
   */
  void tox_callback_friend_status (Tox* tox, void function (Tox*, uint, TOX_USER_STATUS, void*) callback, void* user_data);

  /**
   * Check whether a friend is currently connected to this client.
   *
   * The result of this function is equal to the last value received by the
   * `friend_connection_status` callback.
   *
   * @param friend_number The friend number for which to query the connection
   *   status.
   *
   * @return the friend's connection status as it was received through the
   *   `friend_connection_status` event.
   */
  TOX_CONNECTION tox_friend_get_connection_status (const(Tox)* tox, uint friend_number, TOX_ERR_FRIEND_QUERY* error);

  /**
   * Set the callback for the `friend_connection_status` event. Pass NULL to unset.
   *
   * This event is triggered when a friend goes offline after having been online,
   * or when a friend goes online.
   *
   * This callback is not called when adding friends. It is assumed that when
   * adding friends, their connection status is initially offline.
   */
  void tox_callback_friend_connection_status (Tox* tox, void function (Tox*, uint, TOX_CONNECTION, void*) callback, void* user_data);

  /**
   * Check whether a friend is currently typing a message.
   *
   * @param friend_number The friend number for which to query the typing status.
   *
   * @return true if the friend is typing.
   * @return false if the friend is not typing, or the friend number was
   *   invalid. Inspect the error code to determine which case it is.
   */
  bool tox_friend_get_typing (const(Tox)* tox, uint friend_number, TOX_ERR_FRIEND_QUERY* error);

  /**
   * Set the callback for the `friend_typing` event. Pass NULL to unset.
   *
   * This event is triggered when a friend starts or stops typing.
   */
  void tox_callback_friend_typing (Tox* tox, void function (Tox*, uint, bool, void*) callback, void* user_data);

  /**
   * Set the client's typing status for a friend.
   *
   * The client is responsible for turning it on or off.
   *
   * @param friend_number The friend to which the client is typing a message.
   * @param typing The typing status. True means the client is typing.
   *
   * @return true on success.
   */
  bool tox_self_set_typing (Tox* tox, uint friend_number, bool typing, TOX_ERR_SET_TYPING* error);

  /**
   * Send a text chat message to an online friend.
   *
   * This function creates a chat message packet and pushes it into the send
   * queue.
   *
   * The message length may not exceed TOX_MAX_MESSAGE_LENGTH. Larger messages
   * must be split by the client and sent as separate messages. Other clients can
   * then reassemble the fragments. Messages may not be empty.
   *
   * The return value of this function is the message ID. If a read receipt is
   * received, the triggered `friend_read_receipt` event will be passed this message ID.
   *
   * Message IDs are unique per friend. The first message ID is 0. Message IDs are
   * incremented by 1 each time a message is sent. If UINT32_MAX messages were
   * sent, the next message ID is 0.
   *
   * @param type Message type (normal, action, ...).
   * @param friend_number The friend number of the friend to send the message to.
   * @param message A non-NULL pointer to the first element of a byte array
   *   containing the message text.
   * @param length Length of the message to be sent.
   */
  uint tox_friend_send_message (Tox* tox, uint friend_number, TOX_MESSAGE_TYPE type, const(ubyte)* message, size_t length, TOX_ERR_FRIEND_SEND_MESSAGE* error);

  /**
   * Set the callback for the `friend_read_receipt` event. Pass NULL to unset.
   *
   * This event is triggered when the friend receives the message sent with
   * tox_friend_send_message with the corresponding message ID.
   */
  void tox_callback_friend_read_receipt (Tox* tox, void function (Tox*, uint, uint, void*) callback, void* user_data);

  /**
   * Set the callback for the `friend_request` event. Pass NULL to unset.
   *
   * This event is triggered when a friend request is received.
   */
  void tox_callback_friend_request (Tox* tox, void function (Tox*, const(ubyte)*, const(ubyte)*, size_t, void*) callback, void* user_data);

  /**
   * Set the callback for the `friend_message` event. Pass NULL to unset.
   *
   * This event is triggered when a message from a friend is received.
   */
  void tox_callback_friend_message (Tox* tox, void function (Tox*, uint, TOX_MESSAGE_TYPE, const(ubyte)*, size_t, void*) callback, void* user_data);

  /**
   * Generates a cryptographic hash of the given data.
   *
   * This function may be used by clients for any purpose, but is provided
   * primarily for validating cached avatars. This use is highly recommended to
   * avoid unnecessary avatar updates.
   *
   * If hash is NULL or data is NULL while length is not 0 the function returns false,
   * otherwise it returns true.
   *
   * This function is a wrapper to internal message-digest functions.
   *
   * @param hash A valid memory location the hash data. It must be at least
   *   TOX_HASH_LENGTH bytes in size.
   * @param data Data to be hashed or NULL.
   * @param length Size of the data array or 0.
   *
   * @return true if hash was not NULL.
   */
  bool tox_hash (ubyte* hash, const(ubyte)* data, size_t length);

  /**
   * Sends a file control command to a friend for a given file transfer.
   *
   * @param friend_number The friend number of the friend the file is being
   *   transferred to or received from.
   * @param file_number The friend-specific identifier for the file transfer.
   * @param control The control command to send.
   *
   * @return true on success.
   */
  bool tox_file_control (Tox* tox, uint friend_number, uint file_number, TOX_FILE_CONTROL control, TOX_ERR_FILE_CONTROL* error);

  /**
   * Set the callback for the `file_recv_control` event. Pass NULL to unset.
   *
   * This event is triggered when a file control command is received from a
   * friend.
   */
  void tox_callback_file_recv_control (Tox* tox, void function (Tox*, uint, uint, TOX_FILE_CONTROL, void*) callback, void* user_data);

  /**
   * Sends a file seek control command to a friend for a given file transfer.
   *
   * This function can only be called to resume a file transfer right before
   * TOX_FILE_CONTROL_RESUME is sent.
   *
   * @param friend_number The friend number of the friend the file is being
   *   received from.
   * @param file_number The friend-specific identifier for the file transfer.
   * @param position The position that the file should be seeked to.
   */
  bool tox_file_seek (Tox* tox, uint friend_number, uint file_number, ulong position, TOX_ERR_FILE_SEEK* error);

  /**
   * Copy the file id associated to the file transfer to a byte array.
   *
   * @param friend_number The friend number of the friend the file is being
   *   transferred to or received from.
   * @param file_number The friend-specific identifier for the file transfer.
   * @param file_id A memory region of at least TOX_FILE_ID_LENGTH bytes. If
   *   this parameter is NULL, this function has no effect.
   *
   * @return true on success.
   */
  bool tox_file_get_file_id (const(Tox)* tox, uint friend_number, uint file_number, ubyte* file_id, TOX_ERR_FILE_GET* error);

  /**
   * Send a file transmission request.
   *
   * Maximum filename length is TOX_MAX_FILENAME_LENGTH bytes. The filename
   * should generally just be a file name, not a path with directory names.
   *
   * If a non-UINT64_MAX file size is provided, it can be used by both sides to
   * determine the sending progress. File size can be set to UINT64_MAX for streaming
   * data of unknown size.
   *
   * File transmission occurs in chunks, which are requested through the
   * `file_chunk_request` event.
   *
   * When a friend goes offline, all file transfers associated with the friend are
   * purged from core.
   *
   * If the file contents change during a transfer, the behaviour is unspecified
   * in general. What will actually happen depends on the mode in which the file
   * was modified and how the client determines the file size.
   *
   * - If the file size was increased
   *   - and sending mode was streaming (file_size = UINT64_MAX), the behaviour
   *     will be as expected.
   *   - and sending mode was file (file_size != UINT64_MAX), the
   *     file_chunk_request callback will receive length = 0 when Core thinks
   *     the file transfer has finished. If the client remembers the file size as
   *     it was when sending the request, it will terminate the transfer normally.
   *     If the client re-reads the size, it will think the friend cancelled the
   *     transfer.
   * - If the file size was decreased
   *   - and sending mode was streaming, the behaviour is as expected.
   *   - and sending mode was file, the callback will return 0 at the new
   *     (earlier) end-of-file, signalling to the friend that the transfer was
   *     cancelled.
   * - If the file contents were modified
   *   - at a position before the current read, the two files (local and remote)
   *     will differ after the transfer terminates.
   *   - at a position after the current read, the file transfer will succeed as
   *     expected.
   *   - In either case, both sides will regard the transfer as complete and
   *     successful.
   *
   * @param friend_number The friend number of the friend the file send request
   *   should be sent to.
   * @param kind The meaning of the file to be sent.
   * @param file_size Size in bytes of the file the client wants to send, UINT64_MAX if
   *   unknown or streaming.
   * @param file_id A file identifier of length TOX_FILE_ID_LENGTH that can be used to
   *   uniquely identify file transfers across core restarts. If NULL, a random one will
   *   be generated by core. It can then be obtained by using tox_file_get_file_id().
   * @param filename Name of the file. Does not need to be the actual name. This
   *   name will be sent along with the file send request.
   * @param filename_length Size in bytes of the filename.
   *
   * @return A file number used as an identifier in subsequent callbacks. This
   *   number is per friend. File numbers are reused after a transfer terminates.
   *   On failure, this function returns UINT32_MAX. Any pattern in file numbers
   *   should not be relied on.
   */
  uint tox_file_send (Tox* tox, uint friend_number, uint kind, ulong file_size, const(ubyte)* file_id, const(ubyte)* filename, size_t filename_length, TOX_ERR_FILE_SEND* error);

  /**
   * Send a chunk of file data to a friend.
   *
   * This function is called in response to the `file_chunk_request` callback. The
   * length parameter should be equal to the one received though the callback.
   * If it is zero, the transfer is assumed complete. For files with known size,
   * Core will know that the transfer is complete after the last byte has been
   * received, so it is not necessary (though not harmful) to send a zero-length
   * chunk to terminate. For streams, core will know that the transfer is finished
   * if a chunk with length less than the length requested in the callback is sent.
   *
   * @param friend_number The friend number of the receiving friend for this file.
   * @param file_number The file transfer identifier returned by tox_file_send.
   * @param position The file or stream position from which to continue reading.
   * @return true on success.
   */
  bool tox_file_send_chunk (Tox* tox, uint friend_number, uint file_number, ulong position, const(ubyte)* data, size_t length, TOX_ERR_FILE_SEND_CHUNK* error);

  /**
   * Set the callback for the `file_chunk_request` event. Pass NULL to unset.
   *
   * This event is triggered when Core is ready to send more file data.
   */
  void tox_callback_file_chunk_request (Tox* tox, void function (Tox*, uint, uint, ulong, size_t, void*) callback, void* user_data);

  /**
   * Set the callback for the `file_recv` event. Pass NULL to unset.
   *
   * This event is triggered when a file transfer request is received.
   */
  void tox_callback_file_recv (Tox* tox, void function (Tox*, uint, uint, uint, ulong, const(ubyte)*, size_t, void*) callback, void* user_data);

  /**
   * Set the callback for the `file_recv_chunk` event. Pass NULL to unset.
   *
   * This event is first triggered when a file transfer request is received, and
   * subsequently when a chunk of file data for an accepted request was received.
   */
  void tox_callback_file_recv_chunk (Tox* tox, void function (Tox*, uint, uint, ulong, const(ubyte)*, size_t, void*) callback, void* user_data);

  /**
   * Send a custom lossy packet to a friend.
   *
   * The first byte of data must be in the range 200-254. Maximum length of a
   * custom packet is TOX_MAX_CUSTOM_PACKET_SIZE.
   *
   * Lossy packets behave like UDP packets, meaning they might never reach the
   * other side or might arrive more than once (if someone is messing with the
   * connection) or might arrive in the wrong order.
   *
   * Unless latency is an issue, it is recommended that you use lossless custom
   * packets instead.
   *
   * @param friend_number The friend number of the friend this lossy packet
   *   should be sent to.
   * @param data A byte array containing the packet data.
   * @param length The length of the packet data byte array.
   *
   * @return true on success.
   */
  bool tox_friend_send_lossy_packet (Tox* tox, uint friend_number, const(ubyte)* data, size_t length, TOX_ERR_FRIEND_CUSTOM_PACKET* error);

  /**
   * Send a custom lossless packet to a friend.
   *
   * The first byte of data must be in the range 160-191. Maximum length of a
   * custom packet is TOX_MAX_CUSTOM_PACKET_SIZE.
   *
   * Lossless packet behaviour is comparable to TCP (reliability, arrive in order)
   * but with packets instead of a stream.
   *
   * @param friend_number The friend number of the friend this lossless packet
   *   should be sent to.
   * @param data A byte array containing the packet data.
   * @param length The length of the packet data byte array.
   *
   * @return true on success.
   */
  bool tox_friend_send_lossless_packet (Tox* tox, uint friend_number, const(ubyte)* data, size_t length, TOX_ERR_FRIEND_CUSTOM_PACKET* error);

  /**
   * Set the callback for the `friend_lossy_packet` event. Pass NULL to unset.
   *
   */
  void tox_callback_friend_lossy_packet (Tox* tox, void function (Tox*, uint, const(ubyte)*, size_t, void*) callback, void* user_data);

  /**
   * Set the callback for the `friend_lossless_packet` event. Pass NULL to unset.
   *
   */
  void tox_callback_friend_lossless_packet (Tox* tox, void function (Tox*, uint, const(ubyte)*, size_t, void*) callback, void* user_data);

  /**
   * Writes the temporary DHT public key of this instance to a byte array.
   *
   * This can be used in combination with an externally accessible IP address and
   * the bound port (from tox_self_get_udp_port) to run a temporary bootstrap node.
   *
   * Be aware that every time a new instance is created, the DHT public key
   * changes, meaning this cannot be used to run a permanent bootstrap node.
   *
   * @param dht_id A memory region of at least TOX_PUBLIC_KEY_SIZE bytes. If this
   *   parameter is NULL, this function has no effect.
   */
  void tox_self_get_dht_id (const(Tox)* tox, ubyte* dht_id);

  /**
   * Return the UDP port this Tox instance is bound to.
   */
  ushort tox_self_get_udp_port (const(Tox)* tox, TOX_ERR_GET_PORT* error);

  /**
   * Return the TCP port this Tox instance is bound to. This is only relevant if
   * the instance is acting as a TCP relay.
   */
  ushort tox_self_get_tcp_port (const(Tox)* tox, TOX_ERR_GET_PORT* error);

  /* Set the callback for group invites.
   *
   *  Function(Tox *tox, int32_t friendnumber, uint8_t type, const uint8_t *data, uint16_t length, void *userdata)
   *
   * data of length is what needs to be passed to join_groupchat().
   *
   * for what type means see the enum right above this comment.
   */
  void tox_callback_group_invite (Tox* tox, void function (Tox*, int, ubyte, const(ubyte)*, ushort, void*) function_, void* userdata);

  /* Set the callback for group messages.
   *
   *  Function(Tox *tox, int groupnumber, int peernumber, const uint8_t * message, uint16_t length, void *userdata)
   */
  void tox_callback_group_message (Tox* tox, void function (Tox*, int, int, const(ubyte)*, ushort, void*) function_, void* userdata);

  /* Set the callback for group actions.
   *
   *  Function(Tox *tox, int groupnumber, int peernumber, const uint8_t * action, uint16_t length, void *userdata)
   */
  void tox_callback_group_action (Tox* tox, void function (Tox*, int, int, const(ubyte)*, ushort, void*) function_, void* userdata);

  /* Set callback function for title changes.
   *
   * Function(Tox *tox, int groupnumber, int peernumber, uint8_t * title, uint8_t length, void *userdata)
   * if peernumber == -1, then author is unknown (e.g. initial joining the group)
   */
  void tox_callback_group_title (Tox* tox, void function (Tox*, int, int, const(ubyte)*, ubyte, void*) function_, void* userdata);

  /* Set callback function for peer name list changes.
   *
   * It gets called every time the name list changes(new peer/name, deleted peer)
   *  Function(Tox *tox, int groupnumber, int peernumber, TOX_CHAT_CHANGE change, void *userdata)
   */
  void tox_callback_group_namelist_change (Tox* tox, void function (Tox*, int, int, ubyte, void*) function_, void* userdata);

  /* Creates a new groupchat and puts it in the chats array.
   *
   * return group number on success.
   * return -1 on failure.
   */
  int tox_add_groupchat (Tox* tox);

  /* Delete a groupchat from the chats array.
   *
   * return 0 on success.
   * return -1 if failure.
   */
  int tox_del_groupchat (Tox* tox, int groupnumber);

  /* Copy the name of peernumber who is in groupnumber to name.
   * name must be at least TOX_MAX_NAME_LENGTH long.
   *
   * return length of name if success
   * return -1 if failure
   */
  int tox_group_peername (const(Tox)* tox, int groupnumber, int peernumber, ubyte* name);

  /* Copy the public key of peernumber who is in groupnumber to public_key.
   * public_key must be TOX_PUBLIC_KEY_SIZE long.
   *
   * returns 0 on success
   * returns -1 on failure
   */
  int tox_group_peer_pubkey (const(Tox)* tox, int groupnumber, int peernumber, ubyte* public_key);

  /* invite friendnumber to groupnumber
   * return 0 on success
   * return -1 on failure
   */
  int tox_invite_friend (Tox* tox, int friendnumber, int groupnumber);

  /* Join a group (you need to have been invited first.) using data of length obtained
   * in the group invite callback.
   *
   * returns group number on success
   * returns -1 on failure.
   */
  int tox_join_groupchat (Tox* tox, int friendnumber, const(ubyte)* data, ushort length);

  /* send a group message
   * return 0 on success
   * return -1 on failure
   */
  int tox_group_message_send (Tox* tox, int groupnumber, const(ubyte)* message, ushort length);

  /* send a group action
   * return 0 on success
   * return -1 on failure
   */
  int tox_group_action_send (Tox* tox, int groupnumber, const(ubyte)* action, ushort length);

  /* set the group's title, limited to MAX_NAME_LENGTH
   * return 0 on success
   * return -1 on failure
   */
  int tox_group_set_title (Tox* tox, int groupnumber, const(ubyte)* title, ubyte length);

  /* Get group title from groupnumber and put it in title.
   * title needs to be a valid memory location with a max_length size of at least MAX_NAME_LENGTH (128) bytes.
   *
   *  return length of copied title if success.
   *  return -1 if failure.
   */
  int tox_group_get_title (Tox* tox, int groupnumber, ubyte* title, uint max_length);

  /* Check if the current peernumber corresponds to ours.
   *
   * return 1 if the peernumber corresponds to ours.
   * return 0 on failure.
   */
  uint tox_group_peernumber_is_ours (const(Tox)* tox, int groupnumber, int peernumber);

  /* Return the number of peers in the group chat on success.
   * return -1 on failure
   */
  int tox_group_number_peers (const(Tox)* tox, int groupnumber);

  /* List all the peers in the group chat.
   *
   * Copies the names of the peers to the name[length][TOX_MAX_NAME_LENGTH] array.
   *
   * Copies the lengths of the names to lengths[length]
   *
   * returns the number of peers on success.
   *
   * return -1 on failure.
   */
  int tox_group_get_names (const(Tox)* tox, int groupnumber, uint[] names, uint[] lengths, ushort length);

  /* Return the number of chats in the instance m.
   * You should use this to determine how much memory to allocate
   * for copy_chatlist. */
  uint tox_count_chatlist (const(Tox)* tox);

  /* Copy a list of valid chat IDs into the array out_list.
   * If out_list is NULL, returns 0.
   * Otherwise, returns the number of elements copied.
   * If the array was too small, the contents
   * of out_list will be truncated to list_size. */
  uint tox_get_chatlist (const(Tox)* tox, int* out_list, uint list_size);

  /* return the type of groupchat (TOX_GROUPCHAT_TYPE_) that groupnumber is.
   *
   * return -1 on failure.
   * return type on success.
   */
  int tox_group_get_type (const(Tox)* tox, int groupnumber);
}
