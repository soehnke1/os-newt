PORTNAME=	pangolin-newt
DISTVERSIONPREFIX=	v
DISTVERSION=	1.18.1
CATEGORIES=	net security net-vpn

MAINTAINER=	mail@soehnke.de
COMMENT=	Userspace WireGuard site connector for Pangolin
WWW=		https://github.com/fosrl/newt

LICENSE=	AGPLv3
LICENSE_FILE=	${WRKSRC}/LICENSE

RUN_DEPENDS=	ca_root_nss>0:security/ca_root_nss

USES=		go:1.26+,modules
USE_RC_SUBR=	newt

GO_MODULE=	github.com/fosrl/newt
GO_TARGET=	.:newt
GO_LDFLAGS=	-X main.newtVersion=${DISTVERSION} \
		-X main.newtPlatform=freebsd_${ARCH}

CGO_ENABLED=	0

ETCDIR=		${PREFIX}/etc/newt

post-install:
	@${MKDIR} ${STAGEDIR}${ETCDIR}
	${INSTALL_DATA} ${FILESDIR}/config.json.sample \
		${STAGEDIR}${ETCDIR}/config.json.sample

.include <bsd.port.mk>
