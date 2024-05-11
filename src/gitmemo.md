# Git memo
## How to omit entering a password when running `git push`
Run the code below:
```bash
git config credential.helper store
```
and then, run `git push` as usual.