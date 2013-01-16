# ODS SRU Interface

[![Build Status](https://secure.travis-ci.org/uq-eresearch/ods-sru-interface.png)
](http://travis-ci.org/uq-eresearch/ods-sru-interface)
[![Code Climate](https://codeclimate.com/badge.png)
](https://codeclimate.com/github/uq-eresearch/ods-sru-interface)

## Overview

The [UQ][uq] Operational Data Store (ODS) is the source of most of UQ's staff and grant data. Unfortunately, 
the provided connection to a Oracle database is not a particularly portable method for exposing the data.

This ([Sinatra][sinatra]) app provides a [SRU][sru]/[RIF-CS][rifcs] interface over a database connection. While the table formats will be unlikely to match your own situation, the overall struction may be easy to modify for other university databases.

At UQ, this is queried by [Miletus][miletus], which acts as our institutional metadata store.

## Usage

The ODS database connection is provided by the `ODS_DATABASE_URL` environment variable.

Take advantage of [Foreman][foreman]'s `.env` file:

    echo "STAFF_ID_SALT=verysecretstringtocreatestaffrefs" >> .env
    echo "ODS_DATABASE_URL=oracle://<path_to_ods_db>" >> .env

To run Rake tasks adhoc:

    foreman run rake jobs:work

Or to run the whole lot:

    foreman start
    
You also export a [bluepill][bluepill] script and run it as a system service.

```shell
# Export Bluepill script
foreman export bluepill -a odssru -u odssru -p 9000 -t ./foreman /tmp
# Become root
su
mkdir -p /etc/bluepill
mv /tmp/odssru.pill /etc/bluepill/
# Copy the init script into /etc/init.d
cp ~odssru/code/foreman/odssru-bluepill.init /etc/init.d/odssru
# Start the service
service odssru start
```    

## Dependencies

### Ruby 1.9

ODS SRU Interface only runs on Ruby 1.9 or above. RHEL 6 clones only ship with 1.8.7, in which case
using [RVM][rvm] is advisable.

### Redis

The ODS interface uses Redis to store generated anonymous IDs. When using Foreman, it runs its own server, so installing locally to as your application user will work fine.

    cd ~odssru
    wget http://redis.googlecode.com/files/redis-2.6.8.tar.gz
    tar xzvf redis-2.6.8.tar.gz
    cd redis-2.6.8
    make
    make PREFIX=~odssru install
    cd ..
    rm -rf redis-2.6.8{,.tar.gz}

### Oracle Instant Client

_Warning: if you haven't learnt to hate Oracle installation, you will soon._

Download the Oracle RPMs the following RPMs from the [Oracle website][oracleinstantclient].

 * `oracle-instantclient11.2-basic-11.2.0.3.0-1.x86_64.rpm`
 * `oracle-instantclient11.2-sqlplus-11.2.0.3.0-1.x86_64.rpm`
 * `oracle-instantclient11.2-devel-11.2.0.3.0-1.x86_64.rpm`

_No, you can't do it with elinks - the site requires JS and account signup, so you'll have to download them from a web browser and SCP them to the host._

    yum localinstall -y oracle-instantclient11.2-*

Oracle, in their wisdom, have decided to resolve the multi-driver install issue by not putting any of the libs in the default location. As a result, you'll need to add their location to `LD_LIBRARY_PATH` when installing the Ruby OCI8 bindings with `bundle install`.

    export LD_LIBRARY_PATH=/usr/lib/oracle/11.2/client64/lib

### IdZebra

[IndexData Zebra][idzebra] is a Z39.50/SRU server written in C. Writing a good SRU server is a difficult (and expensive) job, so instead the ODS SRU interface just dumps the RIF-CS data into IdZebra and relays all requests to it.

There are no good packages for recent versions of RHEL, so most likely you'll have to install from source. You'll first need YAZ (a Z39.50/SRW/SRU toolkit) to install Zebra.

    cd ~odssru
    wget http://ftp.indexdata.dk/pub/yaz/yaz-4.2.48.tar.gz
    cd yaz-4.2.48
    ./configure --prefix=`readlink -f ~odssru`
    make && make install
    cd ..
    rm -rf yaz-4.2.48{,.tar.gz}

Now install Zebra:

    cd ~odssru
    wget http://ftp.indexdata.dk/pub/zebra/idzebra-2.0.53.tar.gz
    cd idzebra-2.0.53
    ./configure --prefix=`readlink -f ~odssru`
    make && make install
    cd ..
    rm -rf idzebra-2.0.53{,.tar.gz}

You should now be able to run `zebraidx -V`.

### Nginx

Unicorn is best run behind a general-purposed web-server to protect it from inconsiderate or malicious clients.

`/etc/nginx/conf.d/odssru.conf`:

    server {
      listen 80;
      listen 443 ssl;
      server_name your.server.name.test;

      gzip on;
      gzip_http_version 1.0;
      gzip_static on;
      gzip_proxied any;
      gzip_types application/xml text/xml;
      gzip_vary on;

      root /opt/odssru/code/public;

      location / {
        try_files $uri @unicorn;
      }

      location @unicorn {
        proxy_set_header "Host" $host;
        proxy_pass http://localhost:9000;
      }

    }

## Licence

This software is licensed under the Simplified (2-clause) BSD license. See `COPYING` for details.

## Acknowledgements

This app was produced as a result of an [ANDS-funded](http://www.ands.org.au/) project.

[bluepill]: https://github.com/arya/bluepill
[foreman]: http://ddollar.github.com/foreman/
[idzebra]: https://www.indexdata.com/zebra
[miletus]: https://github.com/uq-eresearch/miletus
[oracleinstantclient]: http://www.oracle.com/technetwork/topics/linuxx86-64soft-092277.html
[redis]: http://redis.io/
[rifcs]: http://services.ands.org.au/documentation/rifcs/guidelines/rif-cs.html
[rvm]: http://rvm.io/
[sinatra]: http://www.sinatrarb.com/
[sru]: http://www.loc.gov/standards/sru/
[uq]: http://uq.edu.au/
