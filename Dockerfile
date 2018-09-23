FROM finalduty/archlinux
MAINTAINER youchao.xue <xueyouchao@gmail.com>

COPY asEnvUser /usr/local/sbin/
#fix windows line ending issue
RUN sed -i -e 's/\r$//' /usr/local/sbin/asEnvUser

# popupate mirrorlist to enable full upgrade 
#RUN curl -o /etc/pacman.d/mirrorlist "http://www.archlinux.org/mirrorlist/?country=US&protocol=http&ip_version=6&use_mirror_status=on" &&   sed -i 's/^#//' /etc/pacman.d/mirrorlist
#RUN curl -o /etc/pacman.d/mirrorlist "http://www.archlinux.org/mirrorlist/?country=all&protocol=http&ip_version=6&use_mirror_status=on" &&   sed -i 's/^#//' /etc/pacman.d/mirrorlist
#RUN cat /etc/pacman.d/mirrorlist

# update to latest available build 
RUN pacman -Syu --noconfirm
RUN pacman -S --noconfirm wget vim git make sudo  python3 cmake go zsh zsh-autosuggestions zsh-syntax-highlighting the_silver_searcher clang

RUN	 git clone https://github.com/ncopa/su-exec.git /tmp/su-exec \
		&& cd /tmp/su-exec \
		&& make \
		&& chmod 770 su-exec \
		&& mv ./su-exec /usr/local/sbin/ \
		&& chown root /usr/local/sbin/asEnvUser \
		&& chmod 700 /usr/local/sbin/asEnvUser 

#RUN pacman-key --refresh--keys && gpg --keyserver pgp.mit.edu --recv-keys C52048C0C0748FEE227D47A2702353E0F7E48EDB \
#RUN pacman -S --noconfirm ncurses5-compat-libs
#libtinfo-5

ENV UNAME="zsher" \
	GNAME="zsh" \
	UHOME="/home/zhser" \
	UID="1000" \
	GID="1000" \
	WORKSPACE="/mnt/workspace" \
	SHELL="/bin/zsh" \
	GOPATH="/go" \
	PATH="/go/bin:/user/local/go/bin:$PATH"

WORKDIR "${WORKSPACE}"
RUN asEnvUser

#overwrite default .zshrc
COPY .zshrc ${UHOME}
RUN sed -i -e 's/\r$//' ${UHOME}/.zshrc
USER zsher

#makepkg can't be run as root, create a user to do it , below is for libtinfo5 library missing issue
#RUN wget https://aur.archlinux.org/cgit/aur.git/snapshot/ncurses5-compat-libs.tar.gz && tar -xvzf ncurses5-compat-libs.tar.gz && ls -al && rm -rf *gz && ls -al \
#		&& cd ncurses5-compat-libs \
#		&& makepkg -s --skippgpcheck \
#		&& sudo pacman -U  --noconfirm *xz 

#oh-my-zsh install
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" 

#Youcompleteme install
RUN git clone --recursive https://github.com/Valloric/YouCompleteMe.git ~/.vim/bundles/YouCompleteMe \
		&& cd ~/.vim/bundles/YouCompleteMe && sudo python3 ./install.py --clang-completer --system-libclang --gocode-completer 

#	&& cd ~/.vim/bundles/YouCompleteMe \
#	&&	git submodule update --init --recursive \
#	&& mkdir ~/.ycm_build && cd ~/.ycm_build \
#	&& cmake -G "Unix Makefiles" -DUSE_PYTHON2=OFF -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
#		-DPYTHON_INCLUDE_DIR=$(python3 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())")  \
#		-DPYTHON_LIBRARY=$(python3 -c "import distutils.sysconfig as sysconfig; print(sysconfig.get_config_var('LIBDIR'))") \
#		-DUSE_SYSTEM_BOOST=OFF -DUSE_SYSTEM_LIBCLANG=ON . ~/.vim/bundles/YouCompleteMe/third_party/ycmd/cpp \
#	&& cmake --build . --target ycm_core --config Release

#setup awesome vim 
RUN git clone https://github.com/skywind3000/vim-init.git ${UHOME}/.vim/vim-init
COPY init-plugins.vim ${UHOME}/.vim/vim-init/init
#fix windows line ending issue
RUN sed -i -e 's/\r$//' ${UHOME}/.vim/vim-init/init/init-plugins.vim 
RUN	 echo -e "let g:ycm_global_ycm_extra_conf='~/.vim/.ycm_extra_conf.py'\nsource ${UHOME}/.vim/vim-init/init.vim" >> ~/.vimrc 

COPY cpptest ./cpptest/
CMD ["zsh"]
