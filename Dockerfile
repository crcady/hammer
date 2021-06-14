FROM klee/llvm:90_O_D_A_ubuntu_bionic-20200807 as builder
RUN apt update && apt install -y scons build-essential
COPY . /tmp/hammer
WORKDIR /tmp/hammer
ENV PATH="$PATH:/tmp/llvm-90-install_O_D_A/bin"
RUN CC=clang scons --llvm

FROM klee/klee:latest as runner
COPY --from=builder /tmp/hammer/build/opt/src/libhammer_ir.a /home/klee/libhammer_ir.a
COPY src/*.h /home/klee/hammer/
COPY symbolics/hello-world.c /home/klee/hello-world.c
RUN clang -c -emit-llvm hello-world.c -o hello-world.bc
CMD klee --posix-runtime --link-llvm-lib=libhammer_ir.a hello-world.bc