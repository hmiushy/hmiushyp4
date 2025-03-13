# SDE-9.7.0セットアップ
  - Ubuntu20.04中にDockerをインストール
    ```bash
    sudo apt install docker.io
    ```
  - 現在のユーザがDockerを管理者権限なしで使用できるように設定
    ```bash
    sudo groupadd docker
    sudo gpasswd -a ${USER} docker
    sudo systemctl restart docker
    sudo chmod a+rw /var/run/docker.sock
    ```
## angel eye プラットフォームのためのbarefoot-sde-9.7.0とSONiCイメージを構築
(angel eye プラットフォームは何かわからない)
  1. ファイルを解凍
     ```bash
     sudo tar -xzvf barefoot-sde-9.7.0.tgz
     ```
  2. Dockerイメージ作成
     ```bash
     cd barefoot-sde-9.7.0/ 
     cd build-docker
     docker build -t debian:build-docker-new .
     cd ..
     ```
     ※Dockerfile内の`FROM debian:10`が`FROM debian/snapshot:buster-20210208`に変更されていることを確認
  3. コンテナ作成
     ```bash
     source .env
     docker run --cap-add=NET_ADMIN -it -v ${PROJECT_DIR}:/home/build/src --name my970 debian:build-docker-new
     sudo -s
     # User/Password: build/build
     source .env
     ```
     ※--nameのあとは好きな名前でOK<br>
     ※次からは以下のコマンドで，すでに立ち上がっているコンテナに入る
     ```bash
     docker exec -ti my970 bash
     ```
　4. profileとdebイメージを作成（profileは何に使うかわからない）
     ```bash
     ./build.sh -p angel_eye -u switch
     ```
     実行後，`$SDE/tools/sonic/`内にdebイメージがある．<br>
     これをハードウェアに持って行って色々する
