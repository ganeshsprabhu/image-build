# image-build

docker build -t pa4se .
docker save -o pa4se.tar pa4se
docker run -it pa4se /bin/bash
