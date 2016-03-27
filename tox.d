/* ToxD Copyright (C) 2016 Ogromny */

module tox;

extern (C)
{
  enum
  {
    TOX_PUBLIC_KEY_SIZE = 32,
    TOX_SECRET_KEY_SIZE = 32,
    TOX_ADDRESS_SIZE = (TOX_PUBLIC_KEY_SIZE + uint.sizeof * 2), // not exactly but work
    TOX_MAX_NAME_LENGTH = 128,
    TOX_MAX_STATUS_MESSAGE_LENGTH = 1007,
    TOX_MAX_FRIEND_REQUEST_LENGTH = 1016,
    TOX_MAX_MESSAGE_LENGTH = 1372,
    TOX_MAX_CUSTOM_PACKET_SIZE = 1373,
    TOX_HASH_LENGTH = 32,
    TOX_FILE_ID_LENGTH = 32,
    TOX_MAX_FILENAME_LENGTH = 255,
    // FROM tox_old.h
    TOX_GROUPCHAT_TYPE_TEXT = 0,
    TOX_GROUPCHAT_TYPE_AV = 1,
    TOX_CHAT_CHANGE_PEER_ADD = 0,
    TOX_CHAT_CHANGE_PEER_DEL = 1,
    TOX_CHAT_CHANGE_PEER_NAME = 2,
  }

  enum TOX_USER_STATUS
  {
      TOX_USER_STATUS_NONE = 0,
      TOX_USER_STATUS_AWAY = 1,
      TOX_USER_STATUS_BUSY = 2
  }

  enum TOX_MESSAGE_TYPE
  {
      TOX_MESSAGE_TYPE_NORMAL = 0,
      TOX_MESSAGE_TYPE_ACTION = 1
  }

  enum TOX_PROXY_TYPE
  {
      TOX_PROXY_TYPE_NONE = 0,
      TOX_PROXY_TYPE_HTTP = 1,
      TOX_PROXY_TYPE_SOCKS5 = 2
  }

  enum TOX_SAVEDATA_TYPE
  {
      TOX_SAVEDATA_TYPE_NONE = 0,
      TOX_SAVEDATA_TYPE_TOX_SAVE = 1,
      TOX_SAVEDATA_TYPE_SECRET_KEY = 2
  }

  enum TOX_ERR_OPTIONS_NEW
  {
      TOX_ERR_OPTIONS_NEW_OK = 0,
      TOX_ERR_OPTIONS_NEW_MALLOC = 1
  }

  enum TOX_ERR_NEW
  {
      TOX_ERR_NEW_OK = 0,
      TOX_ERR_NEW_NULL = 1,
      TOX_ERR_NEW_MALLOC = 2,
      TOX_ERR_NEW_PORT_ALLOC = 3,
      TOX_ERR_NEW_PROXY_BAD_TYPE = 4,
      TOX_ERR_NEW_PROXY_BAD_HOST = 5,
      TOX_ERR_NEW_PROXY_BAD_PORT = 6,
      TOX_ERR_NEW_PROXY_NOT_FOUND = 7,
      TOX_ERR_NEW_LOAD_ENCRYPTED = 8,
      TOX_ERR_NEW_LOAD_BAD_FORMAT = 9
  }

  enum TOX_ERR_BOOTSTRAP
  {
      TOX_ERR_BOOTSTRAP_OK = 0,
      TOX_ERR_BOOTSTRAP_NULL = 1,
      TOX_ERR_BOOTSTRAP_BAD_HOST = 2,
      TOX_ERR_BOOTSTRAP_BAD_PORT = 3
  }

  enum TOX_CONNECTION
  {
      TOX_CONNECTION_NONE = 0,
      TOX_CONNECTION_TCP = 1,
      TOX_CONNECTION_UDP = 2
  }

  enum TOX_ERR_SET_INFO
  {
      TOX_ERR_SET_INFO_OK = 0,
      TOX_ERR_SET_INFO_NULL = 1,
      TOX_ERR_SET_INFO_TOO_LONG = 2
  }

  enum TOX_ERR_FRIEND_ADD
  {
      TOX_ERR_FRIEND_ADD_OK = 0,
      TOX_ERR_FRIEND_ADD_NULL = 1,
      TOX_ERR_FRIEND_ADD_TOO_LONG = 2,
      TOX_ERR_FRIEND_ADD_NO_MESSAGE = 3,
      TOX_ERR_FRIEND_ADD_OWN_KEY = 4,
      TOX_ERR_FRIEND_ADD_ALREADY_SENT = 5,
      TOX_ERR_FRIEND_ADD_BAD_CHECKSUM = 6,
      TOX_ERR_FRIEND_ADD_SET_NEW_NOSPAM = 7,
      TOX_ERR_FRIEND_ADD_MALLOC = 8
  }

  enum TOX_ERR_FRIEND_DELETE
  {
      TOX_ERR_FRIEND_DELETE_OK = 0,
      TOX_ERR_FRIEND_DELETE_FRIEND_NOT_FOUND = 1
  }

  enum TOX_ERR_FRIEND_BY_PUBLIC_KEY
  {
      TOX_ERR_FRIEND_BY_PUBLIC_KEY_OK = 0,
      TOX_ERR_FRIEND_BY_PUBLIC_KEY_NULL = 1,
      TOX_ERR_FRIEND_BY_PUBLIC_KEY_NOT_FOUND = 2
  }

  enum TOX_ERR_FRIEND_GET_PUBLIC_KEY
  {
      TOX_ERR_FRIEND_GET_PUBLIC_KEY_OK = 0,
      TOX_ERR_FRIEND_GET_PUBLIC_KEY_FRIEND_NOT_FOUND = 1
  }

  enum TOX_ERR_FRIEND_GET_LAST_ONLINE
  {
      TOX_ERR_FRIEND_GET_LAST_ONLINE_OK = 0,
      TOX_ERR_FRIEND_GET_LAST_ONLINE_FRIEND_NOT_FOUND = 1
  }

  enum TOX_ERR_FRIEND_QUERY
  {
      TOX_ERR_FRIEND_QUERY_OK = 0,
      TOX_ERR_FRIEND_QUERY_NULL = 1,
      TOX_ERR_FRIEND_QUERY_FRIEND_NOT_FOUND = 2
  }

  enum TOX_ERR_SET_TYPING
  {
      TOX_ERR_SET_TYPING_OK = 0,
      TOX_ERR_SET_TYPING_FRIEND_NOT_FOUND = 1
  }

  enum TOX_ERR_FRIEND_SEND_MESSAGE
  {
      TOX_ERR_FRIEND_SEND_MESSAGE_OK = 0,
      TOX_ERR_FRIEND_SEND_MESSAGE_NULL = 1,
      TOX_ERR_FRIEND_SEND_MESSAGE_FRIEND_NOT_FOUND = 2,
      TOX_ERR_FRIEND_SEND_MESSAGE_FRIEND_NOT_CONNECTED = 3,
      TOX_ERR_FRIEND_SEND_MESSAGE_SENDQ = 4,
      TOX_ERR_FRIEND_SEND_MESSAGE_TOO_LONG = 5,
      TOX_ERR_FRIEND_SEND_MESSAGE_EMPTY = 6
  }

  enum TOX_FILE_KIND
  {
      TOX_FILE_KIND_DATA = 0,
      TOX_FILE_KIND_AVATAR = 1
  }

  enum TOX_FILE_CONTROL
  {
      TOX_FILE_CONTROL_RESUME = 0,
      TOX_FILE_CONTROL_PAUSE = 1,
      TOX_FILE_CONTROL_CANCEL = 2
  }

  enum TOX_ERR_FILE_CONTROL
  {
      TOX_ERR_FILE_CONTROL_OK = 0,
      TOX_ERR_FILE_CONTROL_FRIEND_NOT_FOUND = 1,
      TOX_ERR_FILE_CONTROL_FRIEND_NOT_CONNECTED = 2,
      TOX_ERR_FILE_CONTROL_NOT_FOUND = 3,
      TOX_ERR_FILE_CONTROL_NOT_PAUSED = 4,
      TOX_ERR_FILE_CONTROL_DENIED = 5,
      TOX_ERR_FILE_CONTROL_ALREADY_PAUSED = 6,
      TOX_ERR_FILE_CONTROL_SENDQ = 7
  }

  enum TOX_ERR_FILE_SEEK
  {
      TOX_ERR_FILE_SEEK_OK = 0,
      TOX_ERR_FILE_SEEK_FRIEND_NOT_FOUND = 1,
      TOX_ERR_FILE_SEEK_FRIEND_NOT_CONNECTED = 2,
      TOX_ERR_FILE_SEEK_NOT_FOUND = 3,
      TOX_ERR_FILE_SEEK_DENIED = 4,
      TOX_ERR_FILE_SEEK_INVALID_POSITION = 5,
      TOX_ERR_FILE_SEEK_SENDQ = 6
  }

  enum TOX_ERR_FILE_GET
  {
      TOX_ERR_FILE_GET_OK = 0,
      TOX_ERR_FILE_GET_NULL = 1,
      TOX_ERR_FILE_GET_FRIEND_NOT_FOUND = 2,
      TOX_ERR_FILE_GET_NOT_FOUND = 3
  }

  enum TOX_ERR_FILE_SEND
  {
      TOX_ERR_FILE_SEND_OK = 0,
      TOX_ERR_FILE_SEND_NULL = 1,
      TOX_ERR_FILE_SEND_FRIEND_NOT_FOUND = 2,
      TOX_ERR_FILE_SEND_FRIEND_NOT_CONNECTED = 3,
      TOX_ERR_FILE_SEND_NAME_TOO_LONG = 4,
      TOX_ERR_FILE_SEND_TOO_MANY = 5
  }

  enum TOX_ERR_FILE_SEND_CHUNK
  {
      TOX_ERR_FILE_SEND_CHUNK_OK = 0,
      TOX_ERR_FILE_SEND_CHUNK_NULL = 1,
      TOX_ERR_FILE_SEND_CHUNK_FRIEND_NOT_FOUND = 2,
      TOX_ERR_FILE_SEND_CHUNK_FRIEND_NOT_CONNECTED = 3,
      TOX_ERR_FILE_SEND_CHUNK_NOT_FOUND = 4,
      TOX_ERR_FILE_SEND_CHUNK_NOT_TRANSFERRING = 5,
      TOX_ERR_FILE_SEND_CHUNK_INVALID_LENGTH = 6,
      TOX_ERR_FILE_SEND_CHUNK_SENDQ = 7,
      TOX_ERR_FILE_SEND_CHUNK_WRONG_POSITION = 8
  }

  enum TOX_ERR_FRIEND_CUSTOM_PACKET
  {
      TOX_ERR_FRIEND_CUSTOM_PACKET_OK = 0,
      TOX_ERR_FRIEND_CUSTOM_PACKET_NULL = 1,
      TOX_ERR_FRIEND_CUSTOM_PACKET_FRIEND_NOT_FOUND = 2,
      TOX_ERR_FRIEND_CUSTOM_PACKET_FRIEND_NOT_CONNECTED = 3,
      TOX_ERR_FRIEND_CUSTOM_PACKET_INVALID = 4,
      TOX_ERR_FRIEND_CUSTOM_PACKET_EMPTY = 5,
      TOX_ERR_FRIEND_CUSTOM_PACKET_TOO_LONG = 6,
      TOX_ERR_FRIEND_CUSTOM_PACKET_SENDQ = 7
  }

  enum TOX_ERR_GET_PORT
  {
      TOX_ERR_GET_PORT_OK = 0,
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
