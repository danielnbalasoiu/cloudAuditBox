FROM kalilinux/kali-rolling

ENV HOSTNAME=${DOCKER_HOSTNAME:-auditbox}
ENV TZ=Europe/Bucharest

# We are running everything in a single RUN
# to avoid creating multiple layers which increase the size of the final image

COPY ./arsenal/xtra-tools.txt /tmp/

# If you want to install other tools, add them in the tools/xtra-tools.txt file
RUN useradd -ms /bin/bash auditor													&& \
		apt update																						&& \
		apt upgrade -y																				&& \
		apt autoremove																				&& \
		apt install -y $(cat /tmp/xtra-tools.txt | xargs) 			&& \
		pip install pipenv

WORKDIR /home/auditor

USER auditor

COPY --chown=auditor:auditor ./arsenal/python-tools.txt /tmp/
COPY --chown=auditor:auditor ./arsenal/build-tools.sh /tmp/
RUN bash /tmp/build-tools.sh

# Workaround to keep the container running
CMD sleep infinity & wait