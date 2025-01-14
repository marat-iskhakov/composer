################################################################################
#
# faceter-camera
#
################################################################################

FACETER_CAMERA_VERSION = 1.2.1
FACETER_CAMERA_SOURCE = faceter-camera.tar.gz
FACETER_CAMERA_SITE = $(TOPDIR)/../../../..
FACETER_CAMERA_SITE_METHOD = file

FACETER_CAMERA_DEPENDENCIES = \
	host-pkgconf \
	json-c libcurl-openipc libyaml

$(eval $(cmake-package))