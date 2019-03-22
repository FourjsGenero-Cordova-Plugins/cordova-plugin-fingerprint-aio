# Property of Four Js*
# (c) Copyright Four Js 2019, 2019. All Rights Reserved.
# * Trademark of Four Js Development Tools Europe Ltd
#   in the United States and elsewhere
# 
# Four Js and its suppliers do not warrant or guarantee that these
# samples are accurate and suitable for your purposes. Their inclusion is
# purely for information purposes only.

# use "make IDENTITY=<your_ios_certificate> PROVISIONING_PROFILE=<your_ios_profile> gmi.install" to install on a IOS device attached via USB
# use "make openGSTGMI" to open the Genero Studio Project on Mac for GMI
# use "make openGSTGMA" to open the Genero Studio Project on Mac for GMA:
# note that GMADIR must not have spaces in the name for installing 
# use a GMADIR physically outside GSTDIR and configure GST for that GMADIR



BUNDLE_IDENTIFIER   = com.4js.cdvauth
BUNDLE_IDENTIFIER_GMA = com.fourjs.cdvauth
APPNAME             = Finger/FaceId
DEVICE              = phone
MODE                = debug
IDENTITY='(59W7RY75ZU)'
PROVISIONING_PROFILE=$(HOME)/Library/MobileDevice/Provisioning\ Profiles/4js_wildcard
INSTALL=yes

PLUGIN=cordova-plugin-fingerprint-aio
FGL_WRAPPER=fglcdvAuthBio.42m
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
  $(echo ABSPATH=$(ABSPATH),DEMODIR=$(DEMODIR),PLUGINDIR=$(PLUGINDIR),GMAPLUGIN=$(GMAPLUGIN))
endif

_MODULES  = $(patsubst %.4gl, %.42m, $(wildcard *.4gl))
ifdef IN_REPOSITORY
MODULES = $(FGLLDPATH)/$(FGL_WRAPPER) $(FGL_WRAPPER) $(_MODULES)
else
MODULES = $(_MODULES)
endif
FORMS    = $(patsubst %.per, %.42f, $(wildcard *.per))

%.42m: %.4gl
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
$(FGLLDPATH)/$(FGL_WRAPPER): $(FGLLDPATH)/fglcdvAuthBio.4gl
	make -C $(FGLLDPATH)
endif

$(FGL_WRAPPER): $(FGLLDPATH)/$(FGL_WRAPPER)
	cp $(FGLLDPATH)/$(FGL_WRAPPER) $@

gma.build: all 
ifdef IN_REPOSITORY
#build the plugin out of this repository
	cd ../../.. && gmabuildtool scaffold --install-plugins $(GMAPLUGIN) && cd -
endif
#note this fails if GMADIR has a space in the name (if insidse GST)
#you need to create a symbolic link
	gmabuildtool build --build-quietly --build-cordova $(GMAPLUGIN) --build-app-package-name $(BUNDLE_IDENTIFIER_GMA) 

#make GMA_USB=-d gma.install   to install via USB
gma.install: gma.build
	$$ANDROID_SDK_ROOT/platform-tools/adb $(GMA_USB) install -r `find . -name app-unsigned.apk`

openGSTGMI: all
	open Auth.4pw

#we need to install the plugin before
#take care that the GMADIR used here and the one used in Studio actually match
openGSTGMA: gma.build
#	cat Auth.4pw | sed -e 's/<DynamicProperty name="gma-cordova" value=".*$$/<DynamicProperty name="gma-cordova" value="$(subst /,\/,$(PLUGINDIR))"\/\>/' > Auth1.4pw
	open Auth.4pw

clean::
	rm -rf build bin distbin gma
	rm -f *.42* gmi/*.a gmi/link_flags.sh *.4pwvs *.4pwdb *.4pwcfg cordovamap.txt

distclean: clean
ifdef IN_REPOSITORY
	make -C $(FGLLDPATH) clean
endif

