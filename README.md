# Image-build

docker build -t pa4se .
docker save -o pa4se.tar pa4se
docker run -it pa4se /bin/bash

# New Section

To build and run the Docker container, follow these steps:
1. Build the Docker image: `docker build -t pa4se .`
2. Save the Docker image: `docker save -o pa4se.tar pa4se`
3. Run the Docker container: `docker run -it pa4se /bin/bash`
