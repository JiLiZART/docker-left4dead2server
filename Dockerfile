FROM cm2network/steamcmd

# Default configurations

ENV SV_HOSTNAME "L4D2 Server"
ENV SV_RCON_PASSWORD "rconpassword"

EXPOSE 27015
EXPOSE 27015/udp

RUN /bin/bash -c ' \
      set -o pipefail \
      && echo "steamcmd steam/question select I AGREE" \
      | debconf-set-selections \
    ' \
  && dpkg --add-architecture i386 \
  && echo "deb http://mirrors.linode.com/debian stretch main non-free" >> /etc/apt/sources.list.d/linode.list \
  && echo "deb-src http://mirrors.linode.com/debian stretch main non-free" >> /etc/apt/sources.list.d/linode.list \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    gettext \
    steamcmd \
  && apt-get clean \
  && rm -rf /var/lib/apt/list/* \
  && groupadd -g 61000 appuser \
  && useradd -g 61000 -l -m -s /bin/false -u 61000 appuser


USER appuser

RUN /usr/games/steamcmd +login anonymous +quit \
  && mkdir -p /home/appuser/.steam/sdk32 \
  && ln -s /home/appuser/.steam/steamcmd/linux32/steamclient.so /home/appuser/.steam/sdk32/steamclient.so \
  && /usr/games/steamcmd +login anonymous +force_install_dir /home/appuser/l4d2server +app_update 222860 validate +quit


# Install Competitive Rework

COPY --chown=appuser:appuser ./L4D2-Competitive-Rework/addons /home/appuser/l4d2server/left4dead2/
COPY --chown=appuser:appuser ./L4D2-Competitive-Rework/cfg /home/appuser/l4d2server/left4dead2/
COPY --chown=appuser:appuser ./L4D2-Competitive-Rework/scripts /home/appuser/l4d2server/left4dead2/
COPY --chown=appuser:appuser ./L4D2-Competitive-Rework/host.txt /home/appuser/l4d2server/left4dead2/
COPY --chown=appuser:appuser ./L4D2-Competitive-Rework/motd.txt /home/appuser/l4d2server/left4dead2/
COPY --chown=appuser:appuser ./L4D2-Competitive-Rework/myhost.txt /home/appuser/l4d2server/left4dead2/
COPY --chown=appuser:appuser ./L4D2-Competitive-Rework/mymotd.txt /home/appuser/l4d2server/left4dead2/

COPY --chown=appuser:appuser admins_simple.ini /home/appuser/l4d2server/left4dead2/addons/sourcemod/configs/
COPY --chown=appuser:appuser ./left4dead2 /home/appuser/l4d2server/left4dead2
COPY --chown=appuser:appuser server.cfg.tpl /home/appuser/server.cfg.tpl
COPY --chown=appuser:appuser entrypoint.sh /home/appuser/entrypoint.sh


ENTRYPOINT ["/bin/bash", "/home/appuser/entrypoint.sh"]
