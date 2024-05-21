## Error 
```bash
[...]
WARNING: Running pip as root will break packages and permissions. You should install packages reliably by using venv: https://pip.pypa.io/warnings/venv
debug: /bin/sh: 1: /home/build/src/bf-sde-9.7.0/install/bin/pip3.8: not found
debug: make[2]: *** [pkgsrc/bf-utils/third-party/CMakeFiles/libpython3.8.dir/build.make:75: pkgsrc/bf-utils/third-party/libpython3.8/src/libpython3.8-stamp/libpython3.8-install] Error 127
debug: make[1]: *** [CMakeFiles/Makefile2:672: pkgsrc/bf-utils/third-party/CMakeFiles/libpython3.8.dir/all] Error 2
[...]
```
I ran:
```bash
$ pip3.8
bash: /home/build/src/bf-sde-9.7.0/install/bin/pip3.8: /home/cnsrl/bf-sde-9.7.0.10210-cpr/install/bin/python3.8: bad interpreter: No such file or directory
```
This is because I copied the original code.
You have to revise the path of the pip3.8. Just see the pip3.8 in the path, and change the first line to your env path.