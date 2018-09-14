FROM golang:alpine 
MAINTAINER youchao.xue <xueyouchao@gmail.com>

COPY asEnvUser /usr/local/sbin/

RUN apk add --no-cache sudo vim tar wget curl git build-base \
		zsh zsh-autosuggestions zsh-syntax-highlighting \
	&& git clone https://github.com/ncopa/su-exec.git /tmp/su-exec \
		&& cd /tmp/su-exec \
		&& make \
		&& chmod 770 su-exec \
		&& mv ./su-exec /usr/local/sbin/ \
		&& chown root /usr/local/sbin/asEnvUser \
		&& chmod 700 /usr/local/sbin/asEnvUser 

ENV UNAME="zsher" \
	GNAME="zsh" \
	UHOME="/home/zhser" \
	UID="1000" \
	GID="1000" \
	WORKSPACE="/mnt/workspace" \
	SHELL="/bin/zsh"

WORKDIR "${WORKSPACE}"
RUN asEnvUser

#oh-my-zsh install
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" 

#overwrite default .zshrc
COPY .zshrc ${UHOME}

#setup awesome vim 
RUN git clone https://github.com/skywind3000/vim-init.git ${UHOME}/.vim/vim-init \
		&& echo "source ${UHOME}/.vim/vim-init/init.vim" >> ~/.vimrc 
CMD ["zsh"]
