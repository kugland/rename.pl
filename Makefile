ifeq ($(PREFIX),)
PREFIX=/usr/local
endif

help:
	@echo "Usage:"
	@echo ""
	@echo "    make install PREFIX=/usr/local      Install rename.pl to \`/usr/local'."
	@echo "    make uninstall PREFIX=/usr/local    Uninstall rename.pl from \`/usr/local'."
	@echo "    make docs                           Make \`README.md' and man page."
	@echo "    make clean-docs                     Remove \`README.md' and man page."
	@echo "    make distclean                      Remove anything listed in \`.gitignore.'"

install: rename.pl rename.pl.1.gz README.md LICENSE
	install -Dm755 -o0 -g0 rename.pl $(PREFIX)/bin/rename.pl
	install -Dm644 -o0 -g0 rename.pl.1.gz $(PREFIX)/share/man/man1/rename.pl.1.gz
	install -Dm644 -o0 -g0 README.md $(PREFIX)/share/doc/rename-pl/README.md
	install -Dm644 -o0 -g0 LICENSE $(PREFIX)/share/doc/rename-pl/LICENSE

uninstall:
	-rm $(PREFIX)/bin/rename.pl
	-rm $(PREFIX)/share/man/man1/rename.pl.1.gz
	-rm $(PREFIX)/share/doc/rename-pl/README.md
	-rm $(PREFIX)/share/doc/rename-pl/LICENSE

docs: rename.pl.1 README.md

clean-docs:
	-rm rename.pl.1
	-rm rename.pl.1.gz
	-rm README.md

distclean:
	-rm -rv src
	-rm -rv pkg
	-rm -rv renamepl*.pkg.tar*
	-rm -rv rename.pl.1.gz

rename.pl.1: rename.pl.1.ronn
	ronn --pipe -r rename.pl.1.ronn >rename.pl.1

README.md: rename.pl.1.ronn
	ronn --pipe --markdown rename.pl.1.ronn >README.md

rename.pl.1.gz: rename.pl.1
	cat $< | gzip > $@
