#Install the container's OS.
FROM ubuntu:latest as HUGOINSTALL

# Install Hugo.
RUN apt-get update
RUN apt-get -y install apt-utils
RUN apt-get -y install curl
RUN apt-get -y install wget
RUN apt-get -y install dpkg
RUN curl -s https://api.github.com/repos/gohugoio/hugo/releases/latest \
 | grep  browser_download_url \
 | grep Linux-64bit.deb \
 | grep -v extended \
 | cut -d '"' -f 4 \
 | wget -i -
RUN dpkg -i hugo*_Linux-64bit.deb




# Copy the contents of the current working directory to the hugo-site
# directory. The directory will be created if it doesn't exist.
COPY . /hugo-site

# Use Hugo to build the static site files.
 RUN hugo -v --source=/hugo-site --destination=/hugo-site/public

# Install NGINX and deactivate NGINX's default index.html file.
# Move the static site files to NGINX's html directory.
# This directory is where the static site files will be served from by NGINX.
 FROM nginx:stable-alpine
 RUN mv /usr/share/nginx/html/index.html /usr/share/nginx/html/old-index.html
 COPY --from=HUGOINSTALL /hugo-site/public/ /usr/share/nginx/html/

# The container will listen on port 80 using the TCP protocol.
 EXPOSE 80
