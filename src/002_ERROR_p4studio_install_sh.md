# bf-sde-9.13, Error
  ## 実行内容
    - bf-sde-9.13.2# bash install.sh

  ## エラーの内容
  
    ```bash
    Executing: tar xf /tmp/dependencies-v2tymh1u/download/source/boost/boost_1_67_0.tar.bz2 --strip-components 1 -C /tmp/dependencies-v2tymh1u/source/boost
    bzip2: (stdin) is not a bzip2 file.
    tar: Child returned status 2
    tar: Error is not recoverable: exiting now
      - boost: Cmd 'tar xf /tmp/dependencies-v2tymh1u/download/source/boost/boost_1_67_0.tar.bz2 --strip-components 1 -C /tmp/dependencies-v2tymh1u/source/boost' took: 0:00:00.005739, status: 2
      - boost: error
    Error: SDE dependencies not installed.
    
    ```
    
  ## 解決策
    1. `p4studio/dependencies/dependencies.yaml`内の`boost:`のURLを以下のように変更
    
    ```bash
    # attributes: {flags: --with-thread --with-test --with-filesystem --with-system install --with-graph --with-iostreams, url: 'https://boostorg.jfrog.io/artifactory/main/release/1.67.0/source/boost_1_67_0.tar.bz2', version: 1.67.0}
    ↓
    attributes: {flags: --with-thread --with-test --with-filesystem --with-system install --with-graph --with-iostreams, url: 'https://sourceforge.net/projects/boost/files/boost/1.67.0/boost_1_67_0.tar.bz2', version: 1.67.0}
    ```
    
    2. `p4studio/dependencies/source/install_boost.py`の冒頭にある`_BOOST_FILE`を以下のうように変更
    
    ```bash
    #_BOOST_FILE = 'boost.tar.bz2'
    ↓
    _BOOST_FILE = 'boost_1_67_0.tar.bz2'
    ```
