web: bundle exec unicorn -p $PORT
clock: bundle exec rake clock
# Check by forwarding with "socat TCP-LISTEN:9999,fork unix:tmp/zebra.sock"
zebra: zebrasrv -f config/zebra/yazserver.xml
