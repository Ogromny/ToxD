/* ToxD Copyright (C) 2016 Ogromny */

module toxencryptsave;

extern (C)
{
  enum
  {
    TOX_PASS_SALT_LENGTH = 32,
    TOX_PASS_KEY_LENGTH = 32,
    TOX_PASS_ENCRYPTION_EXTRA_LENGTH = 80
  }
  enum TOX_ERR_KEY_DERIVATION
  {
      TOX_ERR_KEY_DERIVATION_OK = 0,
      TOX_ERR_KEY_DERIVATION_NULL = 1,
      TOX_ERR_KEY_DERIVATION_FAILED = 2
  }

  enum TOX_ERR_ENCRYPTION
  {
      TOX_ERR_ENCRYPTION_OK = 0,
      TOX_ERR_ENCRYPTION_NULL = 1,
      TOX_ERR_ENCRYPTION_KEY_DERIVATION_FAILED = 2,
      TOX_ERR_ENCRYPTION_FAILED = 3
  }

  enum TOX_ERR_DECRYPTION
  {
      TOX_ERR_DECRYPTION_OK = 0,
      TOX_ERR_DECRYPTION_NULL = 1,
      TOX_ERR_DECRYPTION_INVALID_LENGTH = 2,
      TOX_ERR_DECRYPTION_BAD_FORMAT = 3,
      TOX_ERR_DECRYPTION_KEY_DERIVATION_FAILED = 4,
      TOX_ERR_DECRYPTION_FAILED = 5
  }

  struct TOX_PASS_KEY
  {
      ubyte[32] salt;
      ubyte[32] key;
  }

  struct Tox;


  struct Tox_Options;


  // uint toxes_version_major ();
  // uint toxes_version_minor ();
  // uint toxes_version_patch ();
  // bool toxes_version_is_compatible (uint major, uint minor, uint patch);
  bool tox_pass_encrypt (const(ubyte)* data, size_t data_len, const(ubyte)* passphrase, size_t pplength, ubyte* out_, TOX_ERR_ENCRYPTION* error);
  bool tox_pass_decrypt (const(ubyte)* data, size_t length, const(ubyte)* passphrase, size_t pplength, ubyte* out_, TOX_ERR_DECRYPTION* error);
  bool tox_derive_key_from_pass (const(ubyte)* passphrase, size_t pplength, TOX_PASS_KEY* out_key, TOX_ERR_KEY_DERIVATION* error);
  bool tox_derive_key_with_salt (const(ubyte)* passphrase, size_t pplength, const(ubyte)* salt, TOX_PASS_KEY* out_key, TOX_ERR_KEY_DERIVATION* error);
  bool tox_get_salt (const(ubyte)* data, ubyte* salt);
  bool tox_pass_key_encrypt (const(ubyte)* data, size_t data_len, const(TOX_PASS_KEY)* key, ubyte* out_, TOX_ERR_ENCRYPTION* error);
  bool tox_pass_key_decrypt (const(ubyte)* data, size_t length, const(TOX_PASS_KEY)* key, ubyte* out_, TOX_ERR_DECRYPTION* error);
  bool tox_is_data_encrypted (const(ubyte)* data);
}
