FROM scalingo/${SCALINGO_STACK:-scalingo-20} as build

WORKDIR /app

RUN mkdir -p /buildpack /build /cache /env
COPY package*.json Procfile .buildpacks nginx.conf .slugignore /build/
COPY ./src /build/src

RUN chown appsdeck. -R /buildpack /build /cache /env
RUN cat <<'EOF' | su - appsdeck
for buildpack in $(cat /build/.buildpacks); do
tmpdir=$(mktemp -u -p /buildpack buildpackXXXX)
rm -rf $tmpdir
git clone $buildpack $tmpdir
chmod -f +x $tmpdir/bin/{compile,release,detect}
cd $tmpdir
$tmpdir/bin/detect  /build
$tmpdir/bin/compile /build /cache /env/.env
$tmpdir/bin/release /build
done
EOF

# .slugignore
RUN if [ -f "/build/.slugignore" ]; then \
      for f in $(cat /build/.slugignore) ; do \
          rm -rf /build/$f ;\
      done ;\
    fi

# mimic Procfile start script
RUN rm -rf /app /buildpack /cache && \
    mv /build /app && \
    > /start && chmod +x /start && \
    cat <<'EOF' >> /start
#!/bin/bash
# mimic Procfile start script
shift
[ -d ".profile.d" ] && for f in .profile.d/*; do . $f; done || true
[ -f "${HOME}/.profile" ] && source "${HOME}/.profile" || true
eval "umask 0077; $@ </dev/null"
EOF

FROM scalingo/${SCALINGO_STACK:-scalingo-20}
COPY --from=build /app /app
COPY --from=build /start /start

# All Scalingo apps define a listening port
ENV PORT=${PORT:-3000}

# The default Scalingo app Docker image directory is /app
WORKDIR /app

# Scalingo Docker image defines a user `appsdeck` that is used during execution
RUN chown -R appsdeck: /app
USER appsdeck

EXPOSE 3000

CMD ["/start", "web", "bin/run"]
