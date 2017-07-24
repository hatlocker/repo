#!/bin/sh -x
export WORKDIR="`mktemp -d`"
function cleanup {
    echo "Removing workdir"
    rm  -rf $WORKDIR
}
trap cleanup EXIT

echo "Workdir: $WORKDIR"

mkdir -p $WORKDIR/build
mkdir -p $WORKDIR/sources
mkdir -p $WORKDIR/repo

# Build dracut-verity
(
    cd $WORKDIR/sources
    git clone https://github.com/hatlocker/dracut-verity.git
    cd dracut-verity
    tito build --rpm --output $WORKDIR/build --dist .hl1
)

# Sign RPMs
(
    cd $WORKDIR/build/x86_64
    rpm --addsign *.rpm
)

# Move back here
(
    mv $WORKDIR/build/x86_64/*.rpm ./repo
    createrepo_c --database --xz repo
    git add --all repo
    git commit -S -sm "Repository updated"
)
