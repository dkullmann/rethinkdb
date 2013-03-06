# Copyright 2010-2013 RethinkDB, all rights reserved.

# There are three ways to override the default settings:
#  - custom.mk
#  - mk/way/$(WAY).mk
#  - config.mk (generated by ./configure)

# This file is included by both Makefile and by mk/main.mk

##### Settings local to this repository

CUSTOM ?= $(TOP)/custom.mk
$(eval $(value check-env-start))
  -include $(CUSTOM)
$(eval $(value check-env-check))

##### Pre-configured ways to build

WAY ?= default
$(eval $(value check-env-start))
  include $(TOP)/mk/way/$(WAY).mk
$(eval $(value check-env-check))

##### Detect configuration

# Include the config.mk file generated by ./configure
CONFIG ?= $(TOP)/config.mk
MAKECMDGOALS ?=
ifeq (,$(filter config distclean,$(MAKECMDGOALS)))
  -include $(CONFIG)

  # the configure scripts sets CONFIGURE_STATUS := success when it completes
  CONFIGURE_STATUS ?= pending

  ifneq (1,$(NO_CONFIGURE))
    ifneq (,$(filter started failed,$(CONFIGURE_STATUS)))
      $(warning CONFIGURE ERROR: $(CONFIGURE_ERROR))
      $(error run ./configure again or edit $(CONFIG))
    else ifeq (success,$(CONFIGURE_STATUS))
      MISSING_CONFIGURE_FLAGS := $(filter-out $(CONFIGURE_COMMAND_LINE),$(CONFIGURE_FLAGS))
      ifneq (,$(MISSING_CONFIGURE_FLAGS))
        $(warning Current settings may require re-running ./configure with the following arguments: $(CONFIGURE_FLAGS))
      endif
    endif
  endif
endif

# Call ./configure to generate the config file
ifneq (1,$(NO_CONFIGURE))
  $(CONFIG):
	./$(TOP)/configure --config=$@ $(CONFIGURE_FLAGS)
endif

# Force running ./configure again
.PHONY: reconfig
reconfig:
	rm $(CONFIG) 2>/dev/null || :
	$(MAKE) $(CONFIG)

.PHONY: config
config: $(CONFIG)

.PHONY: $(TOP)/distclean
$(TOP)/distclean:
	rm -rf $(CONFIG)

##### Default values for target-independant settings

include $(TOP)/mk/way/default.mk