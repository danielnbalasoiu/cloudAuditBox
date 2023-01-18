FROM kalilinux/kali-rolling

COPY ./arsenal/xtra-tools.txt /tmp/

# If you want to install other tools, add them in the tools/xtra-tools.txt file
RUN useradd -ms /bin/bash auditor													&& \
		echo "auditbox" > /etc/hostname												&& \
		apt update																						&& \
		apt autoremove																				&& \
		apt install -y $(cat /tmp/xtra-tools.txt | xargs)			&& \
		pip install pipenv

# 		apt upgrade -y																				&& \

WORKDIR /home/auditor

USER auditor

ENV HOSTNAME=auditbox
ENV TZ=Europe/Bucharest

ENV HOME=/home/auditor
ENV PATH="$HOME/.local/bin:$PATH"

COPY --chown=auditor:auditor ./arsenal/python-tools.txt /tmp/
COPY --chown=auditor:auditor ./arsenal/build-tools.sh /tmp/
RUN bash /tmp/build-tools.sh

# Workaround to keep the container running
CMD sleep infinity & wait