FROM archlinux/base
MAINTAINER youchao.xue <xueyouchao@gmail.com>

COPY asEnvUser /usr/local/sbin/
#fix windows line ending issue
RUN sed -i -e 's/\r$//' /usr/local/sbin/asEnvUser

# update to latest available build 
RUN pacman -Syy && pacman -Syu --noconfirm
RUN pacman -S --noconfirm wget patch vim git make fakeroot sudo  python3 cmake go zsh zsh-autosuggestions zsh-syntax-highlighting the_silver_searcher clang jq 

# add a new user and setup GOPATH, GOROOT
RUN	 git clone https://github.com/ncopa/su-exec.git /tmp/su-exec \
		&& cd /tmp/su-exec \
		&& make \
		&& chmod 770 su-exec \
		&& mv ./su-exec /usr/local/sbin/ \
		&& chown root /usr/local/sbin/asEnvUser \
		&& chmod 700 /usr/local/sbin/asEnvUser 

ENV UNAME="zsher" \
	GNAME="zsh" \
	UHOME="/home/zsher" \
	UID="1000" \
	GID="1000" \
	WORKSPACE="/home/zsher/workspace" \
	SHELL="/bin/zsh" \
	GOPATH="/home/zsher/go" \
	PATH="/home/zsher/go/bin:$PATH" \
	GOROOT="/usr/lib/go"

WORKDIR "${WORKSPACE}"
RUN asEnvUser

#overwrite default .zshrc
COPY .zshrc ${UHOME}
RUN sed -i -e 's/\r$//' ${UHOME}/.zshrc
USER zsher

#install yay for aur packages
RUN git clone https://aur.archlinux.org/yay.git ${WORKSPACE}/yay && pwd && ls -al && cd yay && makepkg --noconfirm --skippgpcheck -si  \
	&& yay -S --noconfirm direnv oh-my-zsh-git autojump \
	&& rm -rf yay

#Youcompleteme install
RUN git clone --recursive https://github.com/Valloric/YouCompleteMe.git ~/.vim/bundles/YouCompleteMe \
		&& cd ~/.vim/bundles/YouCompleteMe && git submodule update --init --recursive \
#fix YCM golang support temporary broken
		&& cd ~/.vim/bundles/YouCompleteMe/third_party/ycmd && git checkout master && git submodule update --init --recursive \
		&& cd ~/.vim/bundles/YouCompleteMe && sudo python3 ./install.py --go-completer --system-libclang --clang-completer \
	&& cp ~/.vim/bundles/YouCompleteMe/third_party/ycmd/.ycm_extra_conf.py ~/.vim

#	cmake way to build YouCompleteMe
#	&& cd ~/.vim/bundles/YouCompleteMe \
#	&&	git submodule update --init --recursive \
#	&& mkdir ~/.ycm_build && cd ~/.ycm_build \
#	&& cmake -G "Unix Makefiles" -DUSE_PYTHON2=OFF -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
#		-DPYTHON_INCLUDE_DIR=$(python3 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())")  \
#		-DPYTHON_LIBRARY=$(python3 -c "import distutils.sysconfig as sysconfig; print(sysconfig.get_config_var('LIBDIR'))") \
#		-DUSE_SYSTEM_BOOST=OFF -DUSE_SYSTEM_LIBCLANG=ON . ~/.vim/bundles/YouCompleteMe/third_party/ycmd/cpp \
#	&& cmake --build . --target ycm_core --config Release

RUN cd ~/ && mkdir go && cd go && mkdir bin && mkdir src

#setup awesome vim 
RUN git clone https://github.com/skywind3000/vim-init.git ${UHOME}/.vim/vim-init
COPY init-plugins.vim ${UHOME}/.vim/vim-init/init	
#fix windows line ending issue	
RUN sed -i -e 's/\r$//' ${UHOME}/.vim/vim-init/init/init-plugins.vim 
RUN	 echo -e "let g:ycm_global_ycm_extra_conf='~/.vim/.ycm_extra_conf.py'\nsource ${UHOME}/.vim/vim-init/init.vim" >> ~/.vimrc 

COPY cpptest ./cpptest/

#java section
#RUN sudo pacman -Sy --noconfirm jdk10-openjdk gradle 
#ENV JAVA_HOME="/usr/lib/jvm/java-10-openjdk"

#delete cache files
RUN sudo pacman -Scc --noconfirm
CMD ["zsh"]
