# Debian Trixie (glibc 2.41), NOT Bookworm (glibc 2.36): headroom-ai's prebuilt `rtk` binary
# requires GLIBC_2.39, so it fails to load on Bookworm. Trixie clears that floor with margin.
# NOTE: if this tag ever fails to pull, fall back to Ubuntu 24.04 (mcr.microsoft.com/
# devcontainers/base:ubuntu-24.04, glibc 2.39) + an apt python3.12 install.
FROM mcr.microsoft.com/devcontainers/python:3.12-trixie

# The base image ships a Yarn apt source (dl.yarnpkg.com) whose GPG signing key
# (NO_PUBKEY 62D54FD4003F6525) was rotated upstream. That makes `apt-get update`
# fail for the WHOLE container, which in turn aborts the docker-in-docker feature
# install. Yarn isn't used in this sandbox, so strip the stale source before any
# feature runs apt-get. (Robust against the entry living in any .list/.sources file.)
RUN find /etc/apt -type f \( -name '*.list' -o -name '*.sources' \) \
      -exec sed -i -e '\#dl.yarnpkg.com#d' {} + ; \
    rm -f /etc/apt/sources.list.d/yarn.list; \
    apt-get update
