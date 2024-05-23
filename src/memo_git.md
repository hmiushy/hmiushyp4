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

## Check the all branch
# error message
```
$ git merge origin/main
error: Merging is not possible because you have unmerged files.
hint: Fix them up in the work tree, and then use 'git add/rm <file>'
hint: as appropriate to mark resolution and make a commit.
fatal: Exiting because of an unresolved conflict.
```
[ref](https://qiita.com/yyy752/items/414d890c8d0cc96c6ede)
`git log --oneline --graph -- all`
