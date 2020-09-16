FROM ubuntu:18.04 AS compiler

WORKDIR /uwsgi

RUN apt-get update && apt-get install -yq \
	build-essential wget python3-dev && \
	update-alternatives --install /usr/bin/python python /usr/bin/python3.6 2 && \
	update-alternatives --config python && \
	update-alternatives --set python /usr/bin/python3.6 && \
	apt-get clean && \
    rm -rf /var/apt/cache/* /var/lib/apt/lists/* && \
	wget https://projects.unbit.it/downloads/uwsgi-2.0.19.1.tar.gz && \
	tar zxvf uwsgi-2.0.19.1.tar.gz && make -C uwsgi-2.0.19.1/ && \
	mv uwsgi-2.0.19.1/uwsgi . && \
	apt-get purge build-essential wget -y && \
	apt-get autoremove -y


FROM ubuntu:18.04

WORKDIR /app
COPY ./requirements.txt /app

RUN apt-get update && apt-get install -yq \
	python3-pip && \
    pip3 install --no-cache-dir -r requirements.txt && \
    apt-get purge python3-pip -y && \
    apt-get autoremove -y && apt-get clean

COPY . /app
COPY --from=compiler /uwsgi/uwsgi /app

ENV UWSGI_THREADS=2
ENV UWSGI_PROCESSES=4

EXPOSE 5000

ENTRYPOINT ["./uwsgi", "--ini", "hello.ini"]
