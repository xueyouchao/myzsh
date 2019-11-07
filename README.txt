// docker container based on Arch linux, zsh & oh-my-zsh, compiled YouCompleteMe(c/c++, golang support turned on)
1. docker build -t myzsh .
2. docker run -ti --rm --name myzshcontainer -v ~/workspace:/home/zsher/workspace myzsh:latest
3. inside container, launch vim and run :PlugInstall
4. for cpp project, suggest to see cpptest example README.txt (note if attach storage workspace, cpp folder will not be copied by default)
5. enjoy

Reference:
user setup took from:
https://github.com/JAremko/docker-emacs/blob/master/asEnvUser

vim env uses:
https://github.com/skywind3000/vim-init

.zshrc config:
https://wdxtub.com/2016/02/18/oh-my-zsh/
