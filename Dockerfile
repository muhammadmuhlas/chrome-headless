FROM debian:buster-slim
LABEL name="chrome-headless" \
        maintainer="Muhammad Muhlas <muhammadmuhlas3@gmail.com>" \
        version="1.0"

RUN apt-get update && apt-get install -y \
	apt-transport-https \
	ca-certificates \
	curl \
	gnupg \
	--no-install-recommends \
	&& curl -sSL https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
	&& echo "deb https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
	&& apt-get update && apt-get install -y \
	google-chrome-stable \
	fontconfig \
	fonts-ipafont-gothic \
	fonts-wqy-zenhei \
	fonts-thai-tlwg \
	fonts-kacst \
	fonts-symbola \
	fonts-noto \
	fonts-freefont-ttf \
	--no-install-recommends \
	&& apt-get purge --auto-remove -y curl gnupg \
	&& rm -rf /var/lib/apt/lists/*

RUN groupadd -r chrome && useradd -r -g chrome -G audio,video chrome \
    && mkdir -p /home/chrome && chown -R chrome:chrome /home/chrome \
		&& mkdir -p /opt/google/chrome && chown -R chrome:chrome /opt/google/chrome

ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
USER chrome

EXPOSE 9222

ENTRYPOINT ["/tini", "--", "google-chrome"]
CMD ["--headless", "--no-sandbox", "--disable-setuid-sandbox", \
                "--disable-dev-shm-usage", "--disable-gpu", "--remote-debugging-address=0.0.0.0", \
                "--remote-debugging-port=9222" , "--disable-remote-fonts", "--user-data-dir=/tmp"]
