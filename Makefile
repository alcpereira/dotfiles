.PHONY: install uninstall homebrew macos

install:
	stow */

uninstall:
	stow -D */

homebrew:
	brew install $(shell cat homebrew.txt)

macos:
	./macos.sh
