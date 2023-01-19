FROM kalilinux/kali-rolling

ARG DEBIAN_FRONTEND=noninteractive

COPY ./arsenal/xtra-tools.txt /tmp/

# If you want to install other tools, add them in the tools/xtra-tools.txt file
RUN useradd -ms /bin/bash auditor												&& \
		apt update																					&& \
		apt upgrade -y																			&& \
		apt autoremove																			&& \
		echo "auditbox" > /etc/hostname											&& \
		apt install -y $(cat /tmp/xtra-tools.txt | xargs)		&& \
		pip install pipenv

WORKDIR /home/auditor

USER auditor

ENV DOCKER_HOSTNAME=${DOCKER_HOSTNAME:-auditbox}
ENV TZ=Europe/Bucharest
ENV HOME=/home/auditor
ENV PATH="$HOME/.local/bin:$PATH"

COPY --chown=auditor:auditor ./arsenal/python-tools.txt /tmp/
COPY --chown=auditor:auditor ./arsenal/build-tools.sh /tmp/

RUN	bash /tmp/build-tools.sh

# Workaround to keep the container running
CMD sleep infinity & wait
