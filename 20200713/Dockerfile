# python 3.6.9

FROM tensorflow/tensorflow:2.2.0-gpu

ENV DEBIAN_FRONTEND noninteractive

ENV AIMASTER_HOME /home/aimaster

# 타임존 변경
RUN ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

RUN apt-get -y update \
    && apt-get install -y sudo net-tools fcitx-hangul fonts-nanum* vim wget curl ssh \
    && pip3 install jupyter \
    && pip3 install gym

RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - \ 
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update && apt-get install -y google-chrome-stable

RUN printf "LANG=\"ko_KR.UTF-8\"\nLANG=\"ko_KR.EUC-KR\"\nLANGUAGE=\"ko_KR:ko:en_GB:en\"\n" >> /etc/environment \
    && source /etc/environment && fc-cache -r

RUN cat /etc/environment

RUN apt-get install -y xfce4 xfce4-goodies xorg dbus-x11 x11-xserver-utils \
    && echo "6\n69\58\1" | apt-get install xrdp -y 

RUN useradd -s /bin/bash -d /home/aimaster -m -G sudo aimaster \
    && echo 'aimaster ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers 

CMD service xrdp start
USER aimaster

WORKDIR /home/aimaster
RUN wget https://repo.anaconda.com/archive/Anaconda3-2020.02-Linux-x86_64.sh \
    && bash Anaconda3-2020.02-Linux-x86_64.sh -b \
    && rm Anaconda3-2020.02-Linux-x86_64.sh

ENV PATH /home/aimaster/anaconda3/bin:$PATH
RUN echo "export PATH="/home/aimaster/anaconda3/bin:$PATH >> /home/aimaster/.bashrc && source /home/aimaster/.bashrc \
    && sudo chown 1000:1000 /home/aimaster/ && sudo chown -R 1000:1000 /home/aimaster/.conda \
    && conda update conda && conda update anaconda && conda update --all

RUN mkdir /home/aimaster/notebooks
RUN jupyter notebook --generate-config --allow-root
RUN echo "c.NotebookApp.password = u''" >> /home/aimaster/.jupyter/jupyter_notebook_config.py

RUN echo "aimaster:Ardp#^(!" | sudo chpasswd
RUN echo "2" | sudo update-alternatives --config x-terminal-emulator

RUN conda create -n aienv python=3.7 \
    && source activate aienv \
    && conda install tensorflow-gpu=2.2.0 \
    && conda install nb_conda \ 
    && conda install -c conda-forge keras=2.3.1 \
    && conda install scipy=1.5.0 \ 
    && conda install numpy=1.18.5 \
    && conda install matplotlib=3.2.2 \
    && conda install pandas=1.0.5

COPY init.sh /home/aimaster/
RUN sudo chown root:root /home/aimaster/init.sh
RUN sudo chmod 777 /home/aimaster/init.sh

USER root

RUN sudo sed -i '/aimaster ALL=(ALL) NOPASSWD:ALL/c\aimaster ALL=(ALL:ALL) NOPASSWD:/home/aimaster/init.sh' /etc/sudoers 
# ROOT 로그인 비 활성화

ENTRYPOINT service xrdp start & tail -F /home/aimaster/init.sh
#ENTRYPOINT ["sh", "/home/aimaster/init.sh"]
#CMD ["jupyter", "notebook", "--allow-root", "--ip=0.0.0.0", "--port=8080"]
