#£/bin/sh

clear
_timestamp="$(date +%F-%s)"
_origin="https://github.com/"
_suffix="xhyve.git"

# git config --global core.mergeoptions --no-edit

printf "Cleaning old src dir…"
rm -rf src

set -e
printf "\nCloning main xHyve repository\n"
git clone -q "${_origin}mist64/${_suffix}" src
cd src

for _repo_pr in dborca dwoz pr1ntf zchee bonifaido; do
    printf "\n\nFetching changes from: ${_origin}${_repo_pr}/${_suffix}\n"

    set -e
    git pull --no-verify --force --squash --strategy recursive "${_origin}${_repo_pr}/${_suffix}"

    set +e
    git add --all .
    echo "Commited changeset from repository: ${_repo_pr} @ ${_timestamp}" > /tmp/cmtmsg1
    git commit --all --no-verify --file /tmp/cmtmsg1

    set +e
    git status 2>/dev/null | egrep '^nothing to commit, working tree clean' >/dev/null 2>&1
    if [ "0" != "${?}" ]; then
        set -e
        git add --all .
        echo "New changes from repository: ${_repo_pr} @ ${_timestamp}" > /tmp/cmtmsg2
        git commit --all --file /tmp/cmtmsg2
        git merge -a -s recursive
    fi
done

echo "Building xHyve…"
make all

echo "Installing xHyve…"
install -v build/xhyve ../bin/xhyve
cd ../
set +e
