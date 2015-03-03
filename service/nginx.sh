#!/bin/sh

mkdir -p /job/nginx/log
nginx -c /job/nginx/conf/nginx.conf -g "daemon off;"