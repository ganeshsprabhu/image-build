# Dockerfile
FROM ubuntu:22.04

# Run commands in non-interactive mode
ENV DEBIAN_FRONTEND=noninteractive

# Update and install required dependencies
RUN apt-get update && \
    apt-get install -y git opam ocaml-dune autoconf graphviz libcairo2-dev \
                       libexpat1-dev libgmp-dev libgtk-3-dev \
                       libgtksourceview-3.0-dev pkg-config zlib1g-dev \
                       bubblewrap cmake cmake-data alt-ergo m4 perl build-essential \
                       libmpfr-dev libmpfr-doc && \
    apt-get clean

# Initialize OPAM and install packages
RUN opam init -y --disable-sandboxing && \
    opam update -y && \
    opam upgrade -y && \
    eval $(opam env --switch=default) && \
    opam install -y frama-c cil why3 yices2

# Set OPAM environment and suppress warnings
ENV OPAMYES=1
ENV OPAMROOTISOK=1

# Set the working directory
WORKDIR /workspace

# Copy the Yices tar file into /workspace in the image
COPY yices-1.0.40-x86_64-unknown-linux-gnu.tar.gz /workspace/

# Extract Yices and move the binaries, libraries, and includes to appropriate directories
RUN tar -xzf /workspace/yices-1.0.40-x86_64-unknown-linux-gnu.tar.gz -C /workspace && \
    rm /workspace/yices-1.0.40-x86_64-unknown-linux-gnu.tar.gz && \
    cp /workspace/yices-1.0.40/bin/* /usr/local/bin/ && \
    cp -r /workspace/yices-1.0.40/include/* /usr/local/include/ && \
    cp -r /workspace/yices-1.0.40/lib/* /usr/local/lib/ && \
    if [ -d /workspace/yices-1.0.40/share ]; then cp -r /workspace/yices-1.0.40/share/* /usr/local/share/; fi

# Final installation of ocamlyices
RUN eval $(opam env) && opam install -y ocamlyices
