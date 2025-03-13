# SDE-9.7.0 セットアップ
### 事前準備
   1. Docker のインストール（Ubuntu 20.04）
    以下のコマンドを実行して Docker をインストールする．
	   ```bash
	  sudo apt install docker.io
	  ```
   2. ユーザーの Docker 権限設定
  管理者権限なしで Docker を使えるようにする．
	   ```bash
	  sudo groupadd docker
	  sudo gpasswd -a ${USER} docker
	  sudo systemctl restart docker
	  sudo chmod a+rw /var/run/docker.sock
	  ```

---
### angel eye プラットフォーム向けの barefoot-sde-9.7.0 と SONiC イメージの構築
> **Note:** `angel eye` プラットフォームが何かは不明

   1. ファイルの解凍
	  ```bash
	  sudo tar -xzvf barefoot-sde-9.7.0.tgz
	  ```

   2. Docker イメージの作成
	  ```bash
	  cd barefoot-sde-9.7.0/
	  cd build-docker
	  docker build -t debian:build-docker-new .
	  cd ..
	  ```
	  > **注意:** `Dockerfile` 内の `FROM debian:10` が `FROM debian/snapshot:buster-20210208` に変更されていることを確認

   3. コンテナの作成
	  ```bash
	  source .env
	  docker run --cap-add=NET_ADMIN -it -v ${PROJECT_DIR}:/home/build/src --name my970 debian:build-docker-new
	  sudo -s
	  # User/Password: build/build
	  source .env
	  ```
	  > **補足:**
	  > - `--name` の後は好きな名前をつけてOK
	  > - 既存のコンテナに入るときは以下のコマンドを実行
	  ```bash
	  docker exec -ti my970 bash
	  ```

   4. profile と deb イメージの作成
	  ```bash
	  ./build.sh -p angel_eye -u switch
	  ```
	  > **補足:** `profile` が何に使われるかは不明
  
	  実行後，`$SDE/tools/sonic/` 内に `deb` イメージができる．<br>
	  これをハードウェアに移動して，いろいろ作業する．<br>
	  これでセットアップ完了．
