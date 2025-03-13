# bf-sde-9.7.0, Error
```
Using LD_LIBRARY_PATH /usr/local/lib:/home/hide/001_p4/barefoot-sde-9.7.0/bf-sde-9.7.0/install/lib:
tofino-model: error while loading shared libraries: libcli.so.1.10: cannot open shared object file: No such file or directory
```

# Solution
  - Check location of `libcli`
    ```
    find ./ -name "libcli"
    ***/libcli/...
    ```
  - Add the path of the location of `libcli`
    GET_POS=`find ./ -name "libcli"`
    ```
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$GET_POS
    ```
    
