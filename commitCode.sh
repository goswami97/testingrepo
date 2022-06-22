#!/bin/bash

# git commit #

githubAccessToken=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

echo "$(date)" > testfile
git add .
git commit -m "Changes done"
git push https://goswami97:$githubAccessToken@github.com/goswami97/testingrepo.git
