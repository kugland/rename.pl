# Maintainer: kugland <kugland at gmail dot com>

pkgname=renamepl-dev
pkgver=r2.435740b
pkgrel=1
pkgdesc='Rename files using perl expressions'
arch=('any')
url='https://github.com/kugland/rename.pl'
license=('mit')
depends=('perl>=5.3.0' 'perl-try-tiny')
optdepends=('perl-text-unidecode: unidecode support')
source=('rename.pl' 'rename.pl.1' 'README.md' 'LICENSE')
sha256sums=(
  SKIP
  SKIP
  SKIP
  SKIP
)

pkgver() {
  printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
}

package() {
  cat rename.pl.1 | gzip >rename.pl.1.gz
  install -Dm755 rename.pl ${pkgdir}/usr/bin/rename.pl
  install -Dm644 rename.pl.1.gz ${pkgdir}/usr/share/man/man1/rename.pl.1.gz
  install -Dm644 README.md ${pkgdir}/usr/share/doc/rename-pl/README.md
  install -Dm644 LICENSE ${pkgdir}/usr/share/doc/rename-pl/LICENSE
}
