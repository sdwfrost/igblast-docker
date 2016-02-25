# Use phusion/baseimage as base image. To make your builds
# reproducible, make sure you lock down to a specific version, not
# to `latest`! See
# https://github.com/phusion/baseimage-docker/blob/master/Changelog.md
# for a list of version numbers.
FROM phusion/baseimage:0.9.18

# Set environment variables the phusion way
RUN echo en_US.UTF-8 > /etc/container_environment/LANGUAGE
RUN echo en_US.UTF-8 > /etc/container_environment/LANG
RUN echo en_US.UTF-8 > /etc/container_environment/LC_ALL
RUN echo UTF-8 > /etc/container_environment/PYTHONIOENCODING
RUN echo 3.2.2 > /etc/container_environment/R_BASE_VERSION

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

MAINTAINER Simon Frost <sdwfrost@gmail.com>

## Set a default user. Available via runtime flag `--user docker`
RUN useradd docker \
	&& mkdir /home/docker \
	&& chown docker:docker /home/docker \
	&& addgroup docker staff

RUN sh -c 'echo "deb http://cran.rstudio.com/bin/linux/ubuntu trusty/" >> /etc/apt/sources.list'
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9

RUN apt-get update -qq && \
	apt-get install wget && \
	apt-get install tar

# Download IgBLAST from NCBI

RUN cd /home/docker && \
	wget ftp://ftp.ncbi.nih.gov/blast/executables/igblast/release/1.4.0/ncbi-igblast-1.4.0-x64-linux.tar.gz && \
	tar -zxvf ncbi-igblast-1.4.0-x64-linux.tar.gz && \
  	cd ncbi-igblast-1.4.0/bin && \
  	cp * /usr/local/bin/

# Now download databases and install to /usr/local/bin

RUN cd /usr/local/bin && \
	wget -r -nH --cut-dirs=4 --no-parent ftp://ftp.ncbi.nih.gov/blast/executables/igblast/release/internal_data && \
	wget -r -nH --cut-dirs=4 --no-parent ftp://ftp.ncbi.nih.gov/blast/executables/igblast/release/optional_file

# Clean up APT and downloads when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && rm -rf /home/docker/ncbi-igblast-1.4.0*

VOLUME ["/home/docker"]
