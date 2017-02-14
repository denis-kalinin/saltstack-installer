### ![win_logo] Run Ansible on Windows
Follow [instructions for Windows to install Ansible]&mdash;in short you need install Cygwin and
from there install and run Ansible.

To confirm successful installation&mdash;run in Cygwin terminal: 
```
ansbible --version
```
Also if you want to manage Windows hosts `pywinrm` should be installed. To archive that open Cygwin
and ensure that python in Cygwin is pointing to posix path:
```sh
$ which python
/usr/bin/python
```
then, install `pip`:
```sh
$ /usr/bin/python -m ensurepip
```
Now you need to install `pywinrm`:
```sh
/usr/bin/pip install pywinrm
```

[instructions for Windows to install Ansible]: http://www.jeffgeerling.com/blog/running-ansible-within-windows
[win_logo]: images/Windows_XP-48.png "Windows logo"
