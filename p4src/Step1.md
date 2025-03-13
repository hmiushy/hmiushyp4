# SDE-9.7.0
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
