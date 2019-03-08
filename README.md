## DNS-Over-TLS Proxy (ruby daemon version)

`docker build -t dot .`

`docker run -it --rm -p 127.0.0.1:53:8053/tcp -p 127.0.0.1:53:8053/udp dot ruby bin/dot.rb run`