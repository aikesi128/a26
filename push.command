# /usr/bin/bash

cd `dirname $0`

git status

git add .

git commit -m "update file"

git pull

git push
 
git status

sleep 3

killall Terminal