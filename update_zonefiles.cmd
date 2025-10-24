docker build -t zonefile-updater .
docker run --rm -v %cd%:/workdir -w /workdir --entrypoint /bin/bash zonefile-updater /workdir/generate.sh
