#
# Ubuntu Dockerfile
#
# https://github.com/dockerfile/ubuntu
#

# Pull base image.
#FROM ubuntu:14.04
##FROM centos:7

# Install.
##RUN yum -y update 
#RUN yum install -y build-essential
##RUN yum groupinstall -y "Development Tools"
##RUN yum install -y curl git man unzip vim wget
  

# Add files.
#ADD .bashrc /root/.bashrc
#ADD .gitconfig /root/.gitconfig
#ADD .scripts /root/.scripts

# Set environment variables.
#ENV HOME /root

# Define working directory.
#WORKDIR /root

# Define default command.
#CMD ["bash"]

##RUN yum install -y tar openssh-server 
##RUN yum install -y libpng libpng-devel freetype freetype-devel
##RUN yum install -y easy_install-2.7 ipython pyzmq pip curl bzip2

##RUN curl https://bootstrap.pypa.io/ez_setup.py -o - | python2.7
##RUN yum install -y protobuf-compiler  python-dev
##RUN wget  https://github.com/google/protobuf/archive/v2.5.0.tar.gz
##RUN tar xzvf v2.5.0.tar.gz
##RUN rm -rf v2.5.0.tar.gz
##RUN cd ./protobuf-2.5.0
#RUN ls
#RUN pwd
##RUN ./autogen.sh
##RUN ./configure --prefix=/usr
##RUN make
##RUN make install

##RUN yum -y install scl-utils
##RUN yum -y install python3
##RUN easy_install pip


##RUN pip install matplotlib 


# Automatic login
##RUN ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa
##RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys

##RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

#COPY config /root/.ssh/
#COPY start.sh /root/
#COPY sync-hosts.sh /root/
FROM ubuntu:14.04

# Install.
RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y build-essential && \
  apt-get install -y software-properties-common && \
  apt-get install -y byobu curl git htop man unzip vim wget && \
  rm -rf /var/lib/apt/lists/*

# Add files.
ADD .bashrc /root/.bashrc
#ADD root/.gitconfig /root/.gitconfig
#ADD root/.scripts /root/.scripts

# Install Java 8
#RUN mkdir /opt
RUN cd opt && wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u72-b15/jdk-8u72-linux-x64.tar.gz" &&\
   tar xzf jdk-8u72-linux-x64.tar.gz && rm -rf jdk-8u72-linux-x64.tar.gz

ENV JAVA_HOME /opt/jdk1.8.0_72
ENV PATH $PATH:/opt/jdk1.8.0_72/bin:/opt/jdk1.8.0_72/jre/bin:/etc/alternatives:/var/lib/dpkg/alternatives

RUN echo 'export JAVA_HOME="/opt/jdk1.8.0_72"' >> ~/.bashrc && \
    echo 'export PATH="$PATH:/opt/jdk1.8.0_72/bin:/opt/jdk1.8.0_72/jre/bin"' >> ~/.bashrc && \
    bash ~/.bashrc && cd /opt/jdk1.8.0_72/ && update-alternatives --install /usr/bin/java java /opt/jdk1.8.0_72/bin/java 1
   
#RUN find / -name alternatives
#RUN ls -lha /etc/alternatives
#RUN ls -lha /var/lib/dpkg/alternatives

#RUN cd /opt/jdk1.8.0_72/ && alternatives --install /usr/bin/java java /opt/jdk1.8.0_72/bin/java 2 && \
#    alternatives --config java

#RUN touch ~/.bashrc



# Install Hadoop 2.7.1
RUN cd /opt && wget https://www.apache.org/dist/hadoop/core/hadoop-2.7.1/hadoop-2.7.1.tar.gz && \
    tar xzvf hadoop-2.7.1.tar.gz && rm ./hadoop-2.7.1.tar.gz &&  mv hadoop-2.7.1/ hadoop

ENV HADOOP_HOME /opt/hadoop

# Install Spark 1.6.0
RUN cd /opt
RUN wget http://apache.javapipe.com/spark/spark-1.6.0/spark-1.6.0-bin-hadoop2.6.tgz 
RUN tar xzvf spark-1.6.0-bin-hadoop2.6.tgz
RUN rm  spark-1.6.0-bin-hadoop2.6.tgz

# Scala Spark kernel (build and cleanup)
RUN cd /tmp && \
    echo deb http://dl.bintray.com/sbt/debian / > /etc/apt/sources.list.d/sbt.list && \
    git clone https://github.com/ibm-et/spark-kernel.git && \
    yum install -y  sbt && \
    cd spark-kernel && \
    git checkout 3905e47815 && \
    make dist SHELL=/bin/bash && \
    mv dist/spark-kernel /opt/spark-kernel && \
    chmod +x /opt/spark-kernel && \
    rm -rf ~/.ivy2 && \
    rm -rf ~/.sbt && \
    rm -rf /tmp/spark-kernel && \
    yum remove remove -y sbt && \
    yum clean packages
    
# Spark and Mesos pointers
ENV SPARK_HOME /opt/spark-1.6.0-bin-hadoop2.6
ENV R_LIBS_USER $SPARK_HOME/R/lib
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.8.2.1-src.zip
#ENV MESOS_NATIVE_LIBRARY /usr/local/lib/libmesos.so
ENV SPARK_OPTS --driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info

# R pre-requisites
RUN yum install -y  \
    fonts-dejavu \
    gfortran \
    gcc && yum clean packages

#USER jovyan

# Install Python 3 packages
RUN conda install --yes \
    'ipywidgets=4.0*' \
    'pandas=0.17*' \
    'matplotlib=1.4*' \
    'scipy=0.16*' \
    'seaborn=0.6*' \
    'scikit-learn=0.16*' \
    && conda clean -yt

# Install Python 2 packages
RUN conda create -p $CONDA_DIR/envs/python2 python=2.7 \
    'ipython=4.0*' \
    'ipywidgets=4.0*' \
    'pandas=0.17*' \
    'matplotlib=1.4*' \
    'scipy=0.16*' \
    'seaborn=0.6*' \
    'scikit-learn=0.16*' \
    pyzmq \
    && conda clean -yt

# R packages
RUN conda config --add channels r
RUN conda install --yes \
    'r-base=3.2*' \
    'r-irkernel=0.5*' \
    'r-ggplot2=1.0*' \
    'r-rcurl=1.95*' && conda clean -yt

# Scala Spark kernel spec
RUN mkdir -p /root/opt/conda/share/jupyter/kernels/scala
COPY kernel.json /root/opt/conda/share/jupyter/kernels/scala/

#USER root

# Install Python 2 kernel spec globally to avoid permission problems when NB_UID
# switching at runtime.
RUN $CONDA_DIR/envs/python2/bin/python \
    $CONDA_DIR/envs/python2/bin/ipython \
    kernelspec install-self

#USER jovyan


EXPOSE 22 7077 8020 8030 8031 8032 8033 8040 8042 8080 8088 8888 9200 9300 10000 50010 50020 50060 50070 50075 50090
