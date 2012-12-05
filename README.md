# ODS SRU Interface

[![Build Status](https://secure.travis-ci.org/uq-eresearch/ods-sru-interface.png)
](http://travis-ci.org/uq-eresearch/ods-sru-interface)
[![Code Climate](https://codeclimate.com/badge.png)
](https://codeclimate.com/github/uq-eresearch/ods-sru-interface)

## Overview

_More to come later..._


## Usage

The database connection is provided by the `DATABASE_URL` environment variable.

Take advantage of Foreman's `.env` file:

    echo "STAFF_ID_SALT=verysecretstringtocreatestaffrefs" >> .env
    echo "DATABASE_URL=postgres:///my_db" > .env
    echo "ODS_DATABASE_URL=oracle://<path_to_ods_db>" >> .env

To run Rake tasks adhoc:

    foreman run rake jobs:work

Or to run the whole lot:

    foreman start


## Acknowledgements

This app was produced as a result of an [ANDS-funded](http://www.ands.org.au/) project.
