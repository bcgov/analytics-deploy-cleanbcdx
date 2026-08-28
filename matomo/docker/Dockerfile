FROM matomo:5-fpm-alpine

# OpenShift's restricted SCC runs containers as an arbitrary UID in the root (0) group,
# so php-fpm's master process must not try to setuid to www-data on startup, and every
# directory it writes to (or that nginx, in the sibling container, needs to read) must
# be group-writable by root.
RUN sed -i \
      -e '/^user = /s/^/;/' \
      -e '/^group = /s/^/;/' \
      /usr/local/etc/php-fpm.d/www.conf \
    && chgrp -R 0 /var/www/html && chmod -R g=u /var/www/html

EXPOSE 9000
USER 1001

CMD ["php-fpm"]
