#!/bin/sh

sitefolder=websito

export NODE_ENV=production

# First check that the websito has been mounted
if [ -d ${sitefolder} ]
then
    cd ${sitefolder}

    # Check whether we don't already have node-modules
    if [ ! -d node_modules ]
    then
        npm i
    fi

    # Now, run the site
    ./bin/www
fi
