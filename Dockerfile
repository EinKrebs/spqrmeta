FROM ubuntu:jammy

WORKDIR /root

RUN \
  apt update -o Acquire::AllowInsecureRepositories=true &&\
  apt install gnupg2 -y --allow-unauthenticated &&\
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 7FCD11186050CD1A &&\
  apt-get update && apt-get install -y --no-install-recommends \
    wget vim git build-essential lsb-release libssl-dev gnupg openssl \
    libssl-dev debhelper debootstrap devscripts \
    make equivs ca-certificates python3-docutils curl &&\
  wget --no-check-certificate --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - &&\
  echo "deb http://apt.postgresql.org/pub/repos/apt/ jammy-pgdg main" | tee  /etc/apt/sources.list.d/pgdg.list &&\
  apt-get update && apt-get install -y --no-install-recommends postgresql-server-dev-all postgresql-server-dev-16 postgresql-common

COPY . /root

RUN \
  pg_buildext updatecontrol && \
  mk-build-deps --build-dep --install --tool='apt-get -o Debug::pkgProblemResolver=yes --no-install-recommends --yes' debian/control