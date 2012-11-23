rm -f ~/.vimrc
ln -s "`pwd`/vim/vimrc" ~/.vimrc
rm -f ~/.bashrc
ln -s "`pwd`/bash/bashrc" ~/.bashrc
rm -f ~/.bash_profile
ln -s "`pwd`/bash/bash_profile" ~/.bash_profile
rm -f ~/.tmux.conf
ln -s "`pwd`/tmux/tmux.conf" ~/.tmux.conf

