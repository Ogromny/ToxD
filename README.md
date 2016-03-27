# ToxD
D Binding for Tox

### exemple
```d
#!/usr/bin/dmd -L-ltoxcore
import tox;

void main()
{
  Tox* client = tox_new(null, null);
}
```
