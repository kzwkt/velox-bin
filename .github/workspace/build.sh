name: Install

on: [push]

jobs:
  debian:
    runs-on: ubuntu-latest
    container: debian:stable
    steps:
      - uses: actions/checkout@v2
      - name: Setup
        run: |
            apt update
            apt install devscripts debhelper build-essential fakeroot git -y
            apt install libwayland-dev libxkbcommon-dev libpixman-1-dev libxcb1-dev libxcb-util-dev libxcb-ewmh-dev libxcb-keysyms1-dev libinput-dev libegl1-mesa-dev -y
            git clone --depth=1 https://github.com/michaelforney/wld
            git clone --depth=1 https://github.com/michaelforney/swc
            git clone --depth=1 https://github.com/michaelforney/velox
            cd wld
            make
            make DESTDIR=/tmp/pkgs install
            make install
            cd ..
            cd swc
            make 
            make install
            make DESTDIR=/tmp/pkgs install
            cd ..
            cd velox
            make 
            make DESTDIR=/tmp/pkgs install
            zip -r velox.zip /tmp/pkgs
            upload=$(realpath velox.zip)
            echo "FILES=${upload}" >> $GITHUB_ENV            
            
      - name: Set dynamic tag version
        run: |
          # Generate a dynamic tag using commit SHA or other unique identifier
          VERSION="v$(date +'%Y%m%d%H%M%S')"  # Format: vYYYYMMDDHHMMSS
          echo "VERSION=${VERSION}" >> $GITHUB_ENV

      - uses: softprops/action-gh-release@v2
        with:
          tag_name: ${{ env.VERSION }}
          name: "Release ${{ env.VERSION }}"
          body: "This release includes the latest build for velox ."
          files: |
            ${{ env.FILES }}
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
             
            
