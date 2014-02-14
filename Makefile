all: .vim/autoload/pathogen.vim \
		.vim/bundle \
		.vim/vimundo

.vim/autoload/pathogen.vim:
	mkdir -p .vim/autoload
	curl -Ss0 ~/.vim/autoload/pathogen.vim https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim

.vim/bundle: .vim/autoload/pathogen.vim
	mkdir -p .vim/bundle
	cd .vim/bundle && grep '"url:' ~/.vimrc | awk '{print $$2}' | xargs -n1 git clone

.vim/vimundo:
	mkdir -p .vim/vimundo
