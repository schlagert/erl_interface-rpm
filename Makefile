# A makefile to create a RPM package containing the erlang C native interface
# parts of the currently installed erlang release. Please note that you one must
# have installed Erlang.

export SHELL := /bin/bash

LIB_DIR := /usr/lib
ERL_INTERFACE_ROOT := $(shell find $(LIB_DIR) -name 'erl_interface-*' -type d | tail -1)
ERL_INTERFACE_BASE := $(shell basename $(ERL_INTERFACE_ROOT))
VERSION := $(shell echo $(ERL_INTERFACE_BASE) | cut -d'-' -f2)

# set rpmbuild related variables
ifneq ($(strip $(shell $(CC) -v 2>&1 | grep "linux")),)
  RPMBUILD_BASE_PREFIX := "/tmp/rpm_bb_"
  ifeq ($(origin RPMBUILD_BASE), undefined)
    export ORIGIN := $(abspath $(shell pwd))
    export RPMBUILD_BASE := $(abspath $(shell mktemp -d $(RPMBUILD_BASE_PREFIX)XXXX))
    export RPMBUILD_DIRS := $(addprefix $(RPMBUILD_BASE)/,SOURCES SPECS BUILD RPMS SRPMS)
  endif
endif

# define rpm spec file
ifneq ($(strip $(shell $(CC) -v 2>&1 | grep "linux")),)
  define SPEC_FILE
%global _enable_debug_package 0
%global debug_package %{nil}
%global __os_install_post /usr/lib/rpm/brp-compress %{nil}

Name:           erl_interface
Version:        $(VERSION)
Release:        1%{?dist}
Summary:        Headers and libraries to integrate C programs with Erlang.
License:        GPL
Source:         $(ERL_INTERFACE_BASE).tar.gz
Url:            http://erlang.org/doc/apps/erl_interface/

%description
Headers and libraries needed to integrate C programs with Erlang. For more
information, documentation and examples visit
http://erlang.org/doc/apps/erl_interface/.

%prep
%setup -q

%build

%install
install -d %{buildroot}/%{_libdir}
install -d %{buildroot}/%{_includedir}
install lib/* %{buildroot}/%{_libdir}
install include/*.h %{buildroot}/%{_includedir}

%files
%{_libdir}/*
%{_includedir}/*
  endef
endif

export SPEC_FILE

.PHONY: default

default:
ifneq ($(strip $(shell $(CC) -v 2>&1 | grep "linux")),)
 ifneq ($(strip $(shell rpmbuild -? 2>&1 | grep "Build options")),)
	mkdir -p $(RPMBUILD_DIRS)
	$(MAKE) rpm
	$(MAKE) clean
 else
	echo "Cannot build RPM without 'rpmbuild' tool."
 endif
else
	@echo "Cannot build RPM on non-linux systems."
endif

.PHONY: rpm

rpm: /tmp/$(ERL_INTERFACE_BASE).tar.gz erl_interface.spec
	mv /tmp/$(ERL_INTERFACE_BASE).tar.gz $(RPMBUILD_BASE)/SOURCES/
	mv erl_interface.spec $(RPMBUILD_BASE)/SPECS/
	rpmbuild --define "_topdir $(RPMBUILD_BASE)" -bb $(RPMBUILD_BASE)/SPECS/erl_interface.spec
	find $(RPMBUILD_BASE)/RPMS -name *.rpm -exec mv '{}' $(ORIGIN)/ ';'

/tmp/$(ERL_INTERFACE_BASE).tar.gz:
	-rm -f /tmp/$(ERL_INTERFACE_BASE).tar.gz
	cd $(dir $(ERL_INTERFACE_ROOT)) ; tar czf /tmp/$(ERL_INTERFACE_BASE).tar.gz $(ERL_INTERFACE_BASE)

erl_interface.spec:
	echo "$$SPEC_FILE" > $@

.PHONY: clean

clean:
	-rm -rf $(RPMBUILD_BASE_PREFIX)*
	-rm -f *.spec
	-rm -f /tmp/erl_interface*.tar.gz

.PHONY: distclean

distclean: clean
	-rm -f *.rpm
