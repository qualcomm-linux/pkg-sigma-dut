inherit autotools-brokensep pkgconfig

DESCRIPTION = "WFA certification testing tool for QCA devices"

LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/${LICENSE};md5=550794465ba0ec5312d6919e203a55f9"

PV = "1.0"

DEPENDS = "libnl"

PACKAGE_ARCH ?= "${MACHINE_ARCH}"

FILESPATH =+ "${WORKSPACE}:"


SRC_URI = "file://wlan/utils/sigma-dut/ "

S = "${WORKDIR}/wlan/utils/sigma-dut"

CFLAGS += "-DLINUX_EMBEDDED"
CFLAGS += "-I ${STAGING_INCDIR}/libnl3"

do_configure[noexec] = "1"

do_install() {
    make install DESTDIR=${D} BINDIR=${sbindir}/
}
