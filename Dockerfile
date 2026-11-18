# MeTube 2026.11.14 — self-hosted video downloader, web UI for yt-dlp
# (alexta69/metube, AGPL-3.0).
#
# Upstream image pinned by manifest-list digest, WITHOUT a tag: Railpack
# 0.43.0 fails to detect a Dockerfile whose FROM carries both a tag and a
# digest, so redeploys die in the plan phase while the first deploy succeeds.
# The digest-only form builds under both builders. Version lives here in the
# comment: alexta69/metube:2026.11.14, manifest list
# sha256:55ce41ab9a78069dc42bd808b20a96aeef4199560a02698a2205ea8a2bc4fef1
# (amd64 sha256:1667a89f8670462abd380478a1b5c34844d4e229d3ba2266448cf8b6e40d62f7).
FROM alexta69/metube@sha256:55ce41ab9a78069dc42bd808b20a96aeef4199560a02698a2205ea8a2bc4fef1

# The stock image carries no USER directive (it runs as root) — state it
# explicitly. The stock entrypoint needs a root start: it chowns the
# download/state/temp directories to PUID:PGID (1000:1000 by default) and
# then drops privileges with gosu. That chown is what makes the stock image
# survive Railway's root-owned volumes without any wrapper fix — the
# 0%-health marketplace leader (metube-1, 39 deploys) is the template that
# never got the port/volume handling right.
USER root

# Baked defaults. These literals never appear on the one-click deploy form:
# downloads, state (queue/history/subscriptions/cookies) and temp files all
# live under /downloads, which is the Railway volume mount. The image's own
# defaults already point there; these ENV lines document the contract and
# survive any upstream default change.
ENV DOWNLOAD_DIR=/downloads \
    STATE_DIR=/downloads/.metube \
    TEMP_DIR=/downloads \
    AUDIO_DOWNLOAD_DIR=/downloads

# No VOLUME instruction — Railway's builder rejects it ("docker VOLUME ...
# is not supported, use Railway Volumes"). The volume is declared in
# railway.json and attached by the template instead.
#
# No CMD and no ENTRYPOINT override: the stock entrypoint (tini +
# docker-entrypoint.sh) starts the bgutil POT provider, then runs the
# aiohttp server. The server reads PORT from the environment on every boot
# (app/main.py: Config validates PORT, web.run_app binds it), so Railway's
# injected PORT is honored with no remap — the stock image's own 8081
# default only applies when PORT is unset.
EXPOSE 8080

LABEL org.opencontainers.image.source="https://github.com/INAPP-Mobile/metube"
