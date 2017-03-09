#£/bin/sh


_origin="https://github.com/"
_arch="x86_64"
_suffix="xhyve.git"
_userboot="userboot.so"
_timestamp="$(date +%F-%s)"

reset

printf "Cleaning old src…\n"
rm -vf bin/xhyve lib/${_userboot}
rm -rf src
mkdir -p lib sbin

set -e
printf "\n\nCloning main xhyve repository\n"
git clone -q "${_origin}mist64/${_suffix}" src
cd src

for _repo_pr in dborca; do # pr1ntf bonifaido zchee dwoz
    set -e
    git pull --no-verify --force --squash --strategy recursive "${_origin}${_repo_pr}/${_suffix}" && \
      printf "\nPulled changes from repository: ${_origin}${_repo_pr}/${_suffix}\n"

    set +e
    git add --all src/*
    echo "Commited changeset from repository: ${_repo_pr} @ ${_timestamp}" > /tmp/cmtmsg1
    git commit --all --no-verify --file /tmp/cmtmsg1

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
sed -i '' -e "s|-g|\$(CFLAGS_SECURITY)|; s|-Os|-O3|g" config.mk

set -e
printf "\nCFLAGS_SECURITY := --param ssp-buffer-size=4 \\
-fsanitize=safe-stack \\
-D_FORTIFY_SOURCE=2 \\
-fstack-protector \\
-fstrict-aliasing \\
-fno-strict-overflow \\
-Wformat \\
-Wformat-security \\
-ftrapv \\
" >> config.mk
set +e
sed -i '' -e 's|en_US.US-ASCII|en_GB.UTF-8|;' config.mk
set -e

printf "\n\nBuilding xhyve…\n"
V=1 make all

printf "\n\nInstalling ${_userboot}…\n"
install -v test/${_userboot} ../lib/

printf "\n\nInstalling xhyve…\n"
install -v build/xhyve ../bin/xhyve

test -x ../sbin/xhyve.${_arch} || \
  install -v build/xhyve ../sbin/xhyve.${_arch}

cd ../
set +e
