/* ToxD Copyright (C) 2016 Ogromny */

module toxdns;

extern (C)
{
  enum
  {
    TOXDNS_MAX_RECOMMENDED_NAME_LENGTH = 32
  }

  void* tox_dns3_new (ubyte* server_public_key);
  void tox_dns3_kill (void* dns3_object);
  int tox_generate_dns3_string (void* dns3_object, ubyte* string, ushort string_max_len, uint* request_id, ubyte* name, ubyte name_len);
  int tox_decrypt_dns3_TXT (void* dns3_object, ubyte* tox_id, ubyte* id_record, uint id_record_len, uint request_id);
}
