# Git memo
## How to omit entering a password when running `git push`
Run the code below:
```bash
git config credential.helper store
```
and then, run `git push` as usual.

## gitignore practicing
If gitignore is not reflected...
```bash
git rm -r --cached . //ファイル全体キャッシュ削除
git rm -r --cached [ファイル名]  //ファイル指定してキャッシュ削除
```