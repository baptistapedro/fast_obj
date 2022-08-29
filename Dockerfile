FROM fuzzers/afl:2.52

RUN apt-get update
RUN apt install -y build-essential wget git clang cmake  automake autotools-dev  libtool zlib1g zlib1g-dev libexif-dev \libjpeg-dev 
RUN git clone  https://github.com/thisistherk/fast_obj.git
WORKDIR /fast_obj
RUN ./autogen.sh
RUN CC=afl-clang ./configure
RUN cmake -DCMAKE_C_COMPILER=afl-gcc -DCMAKE_CXX_COMPILER=afl-g++ .
RUN make
RUN afl-g++ -I. ./test/test.cpp -o /fuzz libfast_obj_lib.a
RUN mkdir /fastObjCorpus
RUN wget https://people.sc.fsu.edu/~jburkardt/data/obj/airboat.obj
RUN wget https://groups.csail.mit.edu/graphics/classes/6.837/F03/models/teapot.obj
RUN wget https://groups.csail.mit.edu/graphics/classes/6.837/F03/models/cow-nonormals.obj
RUN wget https://groups.csail.mit.edu/graphics/classes/6.837/F03/models/pumpkin_tall_10k.obj
RUN wget https://groups.csail.mit.edu/graphics/classes/6.837/F03/models/teddy.obj

ENTRYPOINT ["afl-fuzz", "-i", /fastObjCorpus", "-o", "/fastObjOut"]
CMD ["/fuzz", "@@"]
