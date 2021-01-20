# Maintainer: kugland <kugland at gmail dot com>

pkgname=renamepl-dev
pkgver=2.0.0
pkgrel=1
pkgdesc='Rename files using perl expressions'
arch=('any')
url='https://github.com/kugland/rename.pl'
license=('mit')
depends=('gcc-libs' 'perl>=5.3.0' 'perl-try-tiny')
optdepends=('perl-text-unidecode: unidecode support')
source=('rename.pl' 'rename.pl.1' 'README.md' 'LICENSE')
sha256sums=(
  SKIP
  SKIP
  SKIP
  "5c4cae9d67a1772b756b3b3327d20e46f14e681cfa8acc001d0b6627da86a693"
)

pkgver() {
  printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
}

package() {
  install -Dm755 rename.pl ${pkgdir}/usr/bin/rename.pl
  install -Dm644 rename.pl.1 ${pkgdir}/usr/share/man/man1/rename.pl.1
  install -Dm644 README.md ${pkgdir}/usr/share/doc/rename-pl/README.md
  install -Dm644 LICENSE ${pkgdir}/usr/share/doc/rename-pl/LICENSE
}
