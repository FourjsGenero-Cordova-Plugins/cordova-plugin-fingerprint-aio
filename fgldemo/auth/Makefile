# Property of Four Js*
# (c) Copyright Four Js 2019, 2019. All Rights Reserved.
# * Trademark of Four Js Development Tools Europe Ltd
#   in the United States and elsewhere
# 
# Four Js and its suppliers do not warrant or guarantee that these
# samples are accurate and suitable for your purposes. Their inclusion is
# purely for information purposes only.

# calling make without parameters simply creates an GMI executable for the simulator
# use "make gmi.install" to install on the simulator or device depending on the TARGET

BUNDLE_IDENTIFIER   = com.4js.cdvauth
BUNDLE_IDENTIFIER_GMA = com.fourjs.cdvauth
APPNAME             = Finger/FaceId
DEVICE              = phone
MODE                = debug
IDENTITY='(59W7RY75ZU)'
PROVISIONING_PROFILE=$(HOME)/Library/MobileDevice/Provisioning\ Profiles/4js_wildcard
INSTALL=yes

PLUGIN=cordova-plugin-fingerprint-aio
AUTH_MODULE=fglcdvAuthBio.42m
GMAPLUGIN=$(PLUGIN)
# in case you build the demo when having the plugin checked out
# then we use the fglcvdAuthBio.42m in the fgl dir of the plugin
ifneq ($(wildcard ../../fgldemo),)
  PLUGIN=../..
  FGLLDPATH=../../fgl
  IN_REPOSITORY=true
# figure out the directory name of the plugin because 
# gmabuildtool can't handle a plugin name like ../..
# in the scaffold --install-plugin option
  ABSPATH=$(abspath .)
  DEMODIR=$(shell  dirname $(ABSPATH))
  PLUGINDIR=$(shell dirname $(DEMODIR))
  GMAPLUGIN=$(notdir $(PLUGINDIR))
# $(warning ABSPATH=$(ABSPATH),DEMODIR=$(DEMODIR),PLUGINDIR=$(PLUGINDIR),GMAPLUGIN=$(GMAPLUGIN))
endif

_MODULES  = $(patsubst %.4gl, %.42m, $(wildcard *.4gl))
ifdef IN_REPOSITORY
MODULES = $(FGLLDPATH)/$(AUTH_MODULE) $(AUTH_MODULE) ../../$(AUTHMODULE) $(_MODULES)
else
MODULES = $(_MODULES)
endif
FORMS    = $(patsubst %.per, %.42f, $(wildcard *.per))

%.42m: %.4gl
ifdef IN_REPOSITORY
	rm -f $(AUTH_MODULE)
endif
	FGLLDPATH=$(FGLLDPATH) fglcomp -M $*

%.42f: %.per
	fglform -M $*

all:: $(MODULES) $(FORMS)


run: main.42m
	FGLLDPATH=$(FGLLDPATH) fglrun main

gmi.build: all 
	gmibuildtool --app-name=$(APPNAME) --bundle-id=$(BUNDLE_IDENTIFIER) --provisioning=$(PROVISIONING_PROFILE) --certificate=$(IDENTITY) --device=$(DEVICE) --install=no --mode=$(MODE) --build-cordova=$(PLUGIN)

gmi.install: all
	gmibuildtool --app-name=$(APPNAME) --bundle-id=$(BUNDLE_IDENTIFIER) --provisioning=$(PROVISIONING_PROFILE) --certificate=$(IDENTITY) --device=$(DEVICE) --install=$(INSTALL) --mode=$(MODE) --build-cordova=$(PLUGIN)

ifdef IN_REPOSITORY
$(FGLLDPATH)/$(AUTH_MODULE): $(FGLLDPATH)/fglcdvAuthBio.4gl
	make -C $(FGLLDPATH)
endif

$(AUTH_MODULE):
	cp $(FGLLDPATH)/$(AUTH_MODULE) $@

gma.build: all 
ifdef IN_REPOSITORY
#build the plugin out of this repository and do not use the bundled one
	cd ../../.. && gmabuildtool scaffold --install-plugins $(GMAPLUGIN) && cd -
endif
	gmabuildtool build --build-quietly --build-cordova $(GMAPLUGIN) --build-app-package-name $(BUNDLE_IDENTIFIER_GMA) 

gma.installsim: gma.build
	$$ANDROID_SDK_ROOT/platform-tools/adb install -r ./gma/project/app/build/app/outputs/apk/app-unsigned.apk

clean::
	rm -rf build bin distbin gma
	rm -f *.42* gmi/*.a gmi/link_flags.sh *.4pwvs *.4pwdb cordovamap.txt
