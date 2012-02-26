#
#  Makefile for AgentFarms model
#
#  Copyright (C) 2002 Stefan Urbanek
#
#  Date: 2002 Jul 9
#
#  This file is part of the AgentFarms
#
#  Variables:
#     MODEL_NAME        - name of the simulation
#     SIMULATION_CLASS  - optional name of simulation class, if not specified
#                          $(MODEL_NAME)Simulation will be used
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Library General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the GNU
#  Library General Public License for more details.
#
#  You should have received a copy of the GNU Library General Public
#  License along with this library; if not, write to the Free
#  Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.


BUNDLE_NAME        := $(MODEL_NAME)
BUNDLE_EXTENSION   := .afmodel
BUNDLE_INSTALL_DIR :=$(GNUSTEP_INSTALLATION_DIR)/Library/AgentFarms/Models

ifneq ($(SIMULATION_CLASS),)
    $(MODEL_NAME)_PRINCIPAL_CLASS = $(SIMULATION_CLASS)
else
    $(MODEL_NAME)_PRINCIPAL_CLASS = $(MODEL_NAME)Simulation
endif

$(MODEL_NAME)_RESOURCE_FILES = Model.plist

$(BUNDLE_NAME)_BUNDLE_LIBS += -lAgentFarms

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/bundle.make
-include GNUmakefile.postamble

test: all
	openapp Farmer -NSOpen $(BUNDLE_NAME)$(BUNDLE_EXTENSION)
