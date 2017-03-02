#£/bin/sh

reset
clear
_timestamp="$(date +%F-%s)"
_origin="https://github.com/"
_suffix="xhyve.git"

printf "Cleaning old src…\n"
rm -vf bin/xhyve lib/userboot.so
rm -rf src
mkdir -p lib

set -e
printf "\n\nCloning main xhyve repository\n"
git clone -q "${_origin}mist64/${_suffix}" src
cd src

for _repo_pr in dborca pr1ntf zchee dwoz bonifaido; do
    printf "\n\nFetching changes from: ${_origin}${_repo_pr}/${_suffix}\n"
    set -e
    git pull --no-verify --force --squash --strategy recursive "${_origin}${_repo_pr}/${_suffix}"

    set +e
    git add --all src/*
    echo "Commited changeset from repository: ${_repo_pr} @ ${_timestamp}" > /tmp/cmtmsg1
    git commit --all --no-verify --file /tmp/cmtmsg1

    set +e
    git status 2>/dev/null | egrep '^nothing to commit, working tree clean' >/dev/null 2>&1
    if [ "0" != "${?}" ]; then
        set -e
        git add --all src/*
        echo "New changes from repository: ${_repo_pr} @ ${_timestamp}" > /tmp/cmtmsg2
        git commit --all --file /tmp/cmtmsg2
        git merge -a -s recursive
    fi
done


printf "\n\nConfiguring hardened compiler options for xhyve…\n"
# sed -i '' -e "s|-g|\$(CFLAGS_SECURITY)|; s|-Os|-O3|;" config.mk

# set -e
# printf "\nCFLAGS_SECURITY := \\
#   -ftrapv \\
#   -fstack-protector \\
#   -fstack-protector-strong \\
#   -fstack-protector-all \\
#   --param ssp-buffer-size=4 \\
#   -fno-strict-overflow \\
#   -D_FORTIFY_SOURCE=2 \\
#   -Wformat \\
#   -Wformat-security \\
#   -fPIC \\
#   -g \
# " >> config.mk
set +e
sed -i '' -e 's|en_US.US-ASCII|en_GB.UTF-8|;' config.mk
set -e

printf "\n\nBuilding xhyve…\n"
V=1 make all

printf "\n\nBuilding userboot.so…\n"
cd build

cp -vfr ../test/* ../../lib/

# clang -arch x86_64 \
#     -dead_strip \
#     -shared \
#     -fno-common \
#     -fvisibility=hidden \
#     -fstrict-aliasing \
#     -framework vmnet \
#     -framework Hypervisor \
#     -o ../../lib/userboot.so \
#     vmm/*.o vmm/io/*.o vdsk/*.o vmm/intel/*.o firmware/*.o xhyve.lto.o

# clang -o \
#     ../../lib/userboot.so \
#     -flto \
#     -target x86_64-apple-darwin14 \
#     -mmacosx-version-min=10.11 \
#     -arch x86_64 \
#     -dead_strip \
#     -fstrict-aliasing \
#     -shared \
#     -std=c11 \
#     -fno-common \
#     -fvisibility=hidden \
#     -framework vmnet \
#     -framework Hypervisor \
#     -framework System \
#     -Xlinker \
#     -object_path_lto \
#     vmm/*.o vmm/io/*.o vdsk/*.o vmm/intel/*.o firmware/*.o xhyve.lto.o
cd ../

printf "\n\nInstalling xhyve…\n"
install -v build/xhyve ../bin/xhyve

cd ../
set +e
