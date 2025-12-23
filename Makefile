.PHONY: install uninstall homebrew

install:
	stow */

uninstall:
	stow -D */

homebrew:
	brew install $(shell cat homebrew.txt)
