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

# Install OCaml 4.05.0
RUN opam init -y --disable-sandboxing && \
    opam update -y && \
    opam switch create 4.05.0 --repositories=default && \
    eval $(opam env) && \
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

# Final installation of ocamlyices using OCaml 4.05.0
RUN eval $(opam env) && opam install -y ocamlyices

# Clone the cil-template repository
RUN git clone https://github.com/ganeshsprabhu/cil-template.git /workspace/cil-template

# Change to the cil-template directory and prepare build
WORKDIR /workspace/cil-template
RUN mkdir build

# Remove CMakeCache.txt and update CMake files
RUN rm /workspace/cil-template/CMakeCache.txt && \
    grep -rl "/home/iiitb" /workspace/cil-template/ && \
    grep -rl "/home/iiitb" /workspace/cil-template/ | grep "\.cmake$" | xargs rm

# Install missing OCaml packages
RUN eval $(opam env) && \
    opam install -y ocamlfind

# Install camlp4 using OCaml 4.05.0
RUN opam install -y camlp4

# Set execute permissions for the maybe_link script
RUN chmod +x /workspace/cil-template/CMakeModules/scripts/maybe_link

# Set CMAKE_PREFIX_PATH
ENV CMAKE_PREFIX_PATH=/home/opam/.opam/4.05.0

# Reapply OPAM environment variables for OCaml 4.05.0
RUN eval $(opam env) && \
    opam switch 4.05.0 && \
    eval $(opam env)  # Reapply OPAM environment after setting the switch

# Set the correct OCaml environment path
ENV PATH=/root/.opam/4.05.0/bin:$PATH
ENV CMAKE_PREFIX_PATH=/root/.opam/4.05.0
RUN eval $(opam env)

# Build the project with cmake
WORKDIR /workspace/cil-template/build
RUN rm -rf *
RUN sed -i 's|/home/iiitb/.opam/4.05.0|/root/.opam/4.05.0|' /workspace/cil-template/CMakeLists.txt
RUN cmake ..   # This prepares the build system
RUN make VERBOSE=1      # This compiles the project
RUN make install # This installs the compiled project
