FROM ubuntu:bionic

RUN useradd docker \
	&& mkdir /home/docker \
	&& chown docker:docker /home/docker \
	&& addgroup docker staff

## Install some useful tools and dependencies for MRO
RUN apt update \
	&& apt install -y --no-install-recommends \
	apt-utils \
	ca-certificates \
	curl \
        wget \
	&& rm -rf /var/lib/apt/lists/*

# system libraries of general use
RUN apt update && apt install -y \
    sudo \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev \
    libssl1.0.0 \
    libxml2-dev \
    gdebi \
    libssl-dev

# system library dependency for the euler app
RUN apt update && apt install -y \
    libmpfr-dev \
    gfortran \
    aptitude \
    libgdal-dev \
    libproj-dev \
    g++ \
    libicu-dev \
    libpcre3-dev\
    libbz2-dev \
    liblzma-dev \
    libnlopt-dev \
    build-essential
    
WORKDIR /home/docker
RUN sudo wget https://mirrors.kernel.org/ubuntu/pool/main/libp/libpng/libpng12-0_1.2.54-1ubuntu1_amd64.deb
RUN sudo dpkg -i libpng12-0_1.2.54-1ubuntu1_amd64.deb 
# Download, valiate, and unpack and install Micrisift R open
RUN wget https://www.dropbox.com/s/uz4e4d0frk21cvn/microsoft-r-open-3.5.1.tar.gz?dl=1 -O microsoft-r-open-3.5.1.tar.gz \
&& echo "9791AAFB94844544930A1D896F2BF1404205DBF2EC059C51AE75EBB3A31B3792 microsoft-r-open-3.5.1.tar.gz" > checksum.txt \
	&& sha256sum -c --strict checksum.txt \
	&& tar -xf microsoft-r-open-3.5.1.tar.gz \
	&& cd /home/docker/microsoft-r-open \
	&& ./install.sh -a -u \
	&& ls logs && cat logs/*


# Clean up
WORKDIR /home/docker
RUN rm microsoft-r-open-3.5.1.tar.gz \
	&& rm checksum.txt \
&& rm -r microsoft-r-open


#COPY Makeconf /usr/lib64/microsoft-r/3.3/lib64/R/etc/Makeconf

RUN apt install -y software-properties-common
RUN add-apt-repository -y ppa:ubuntugis/ubuntugis-unstable
RUN apt update
RUN apt install -y libudunits2-dev libgdal-dev libgeos-dev 


RUN sudo apt-add-repository -y ppa:webupd8team/java \
&& apt update && echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections && apt-get install -y oracle-java8-installer \
&& R -e "Sys.setenv(JAVA_HOME = '/usr/lib/jvm/java-8-oracle/jre')"
RUN sudo java -version

# basic shiny functionality
RUN sudo R -e "install.packages('rmarkdown', repos='http://cran.rstudio.com/')" \
&& R -e "install.packages(c('shiny'), repos='http://cran.rstudio.com/')" \
&& R -e "install.packages('devtools', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('remotes', repos='https://cran.r-project.org/')" \
&& R -e "install.packages(c('dplyr'), repos='http://cran.rstudio.com/')" \
&& R -e "install.packages(c('data.table'), repos='http://cran.rstudio.com/')" \
&& R -e "install.packages(c('pool'), repos='http://cran.rstudio.com/')" \
&& R -e "install.packages(c('RPostgres'), repos='http://cran.rstudio.com/')" \
&& R -e "install.packages(c('DBI'), repos='http://cran.rstudio.com/')" \
&& R -e "install.packages('grDevices', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('stringi', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('rjson', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('uuid', repos='https://cran.r-project.org/')" \
&& R -e "install.packages(c('DBI'), repos='http://cran.rstudio.com/')" \
&& R -e "install.packages('configr', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('fst', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('extrafont', repos='https://cran.r-project.org/')" \
&& sudo su - -c "R -e \"options(unzip = 'internal'); remotes::install_github('kuzmenkov111/shinycustomloader')\"" \
&& sudo su - -c "R -e \"options(unzip = 'internal'); devtools::install_github('kuzmenkov111/wired')\"" \
&& sudo su - -c "R -e \"options(unzip = 'internal'); devtools::install_github('kuzmenkov111/kandinsky')\"" \
&& R -e "download.file('http://simonsoftware.se/other/xkcd.ttf', dest='xkcd.ttf', mode='wb'); system('mkdir ~/.fonts'); system('cp xkcd.ttf ~/.fonts'); extrafont::font_import(pattern = '[X/x]kcd', prompt=FALSE)"


EXPOSE 3838
RUN mkdir /home/docker/app

VOLUME /home/docker/app

EXPOSE 3838

CMD ["R", "-e shiny::runApp('/home/docker/app',port=3838,host='0.0.0.0')"]
