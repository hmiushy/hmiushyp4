# p4code and bfrt related memo
# In test
```C++
control SwitchIngress (...) {
    ...
    action xxx() {
        ...
    }
    table ipv4_lpm {
        key = {
            hdr.ipv4Addr : lpm
        }
        action = {
            xxx()
        }
    }
    ...
}
```
```bash
bfrt.test.pipe.SwitchIngress.ipv4_lpm.add_with
```

