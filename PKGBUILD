# Maintainer: Ag Ibragimov <agzam.ibragimov@gmail.com>

pkgname=mxp-git
pkgver=0.4.0
pkgrel=1
pkgdesc="Pipe content between terminal and Emacs buffers"
arch=('any')
url="https://github.com/agzam/emacs-piper"
license=('MIT')
depends=('emacs' 'bash')
makedepends=('git')
provides=('mxp')
conflicts=('mxp')
source=("git+https://github.com/agzam/emacs-piper.git")
sha256sums=('SKIP')

package() {
    cd "${srcdir}/emacs-piper"
    
    # Install the main script
    install -Dm755 mxp "${pkgdir}/usr/bin/mxp"
    
    # Install documentation
    install -Dm644 README.org "${pkgdir}/usr/share/doc/mxp/README.org"
    install -Dm644 LICENSE "${pkgdir}/usr/share/licenses/mxp/LICENSE"
    install -Dm644 changelog.org "${pkgdir}/usr/share/doc/mxp/changelog.org"
}
