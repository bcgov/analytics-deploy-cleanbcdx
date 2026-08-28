# nginx-unprivileged already listens on 8080 as a non-root UID with group-writable
# permissions, so it works under OpenShift's arbitrary-UID restricted SCC unmodified.
FROM nginxinc/nginx-unprivileged:1.27-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080
