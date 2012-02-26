#
#  GNUmakefile
#
#  Copyright (C) 2001 Stefan Urbanek
#
#  Date: 2002 Oct 10
#
#  This file is part of the Agents
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

include $(GNUSTEP_MAKEFILES)/common.make

FRAMEWORK_NAME = AgentFarms

############################################################################
# Agents

AgentFarms_OBJC_FILES = \
        AFAgentAction.m \
        AFAttributeDescription.m \
        AFClassDescription.m \
        AFCollectionDescription.m \
        AFDistantSimulator.m \
        AFEnvironment.m \
        AFGraphInfo.m \
        AFGrid.m \
        AFLattice.m \
        AFModel.m \
        AFModelBundle.m \
        AFNetwork.m \
        AFNetworkLink.m \
        AFNumberCollection.m \
        AFObjectConnection.m \
        AFObjectDescription.m \
        AFObjectPrototype.m \
        AFProbe.m \
        AFProbeSpecification.m \
        AFProperty.m \
        AFPropertyList.m \
        AFRelationshipDescription.m \
        AFSimulation.m \
        AFSimulator.m \
        NSArray+additions.m \
        NSArray+iterations.m \
        NSDictionary+convenience.m \
        NSEnumerator+additions.m \
        NSObject+Environment.m \
        NSObject+Prototypes.m \
        AFResourceManager.m

AgentFarms_HEADER_FILES = \
        AFAgentAction.h \
        AFAttributeDescription.h \
        AFClassDescription.h \
        AFCollectionDescription.h \
        AFDistantSimulator.h \
        AFEnvironment.h \
        AFGraphInfo.h \
        AFGrid.h \
        AFLattice.h \
        AFModel.h \
        AFModelBundle.h \
        AFNetwork.h \
        AFNetworkLink.h \
        AFNumberCollection.h \
        AFObjectConnection.h \
        AFObjectDescription.h \
        AFObjectPrototype.h \
        AFProbe.h \
        AFProbeSpecification.h \
        AFProperty.h \
        AFPropertyList.h \
        AFRelationshipDescription.h \
        AFResourceManager.h \
        AFSimulation.h \
        AFSimulator.h \
        NSArray+additions.h \
        NSArray+iterations.h \
        NSDictionary+convenience.h \
        NSEnumerator+additions.h \
        NSObject+Environment.h \
        NSObject+Prototypes.h \
        AgentFarms.h

AgentFarms_RESOURCE_FILES = \
        ScriptingInfo.plist

ADDITIONAL_INCLUDE_DIRS += -I..
ADDITIONAL_OBJCFLAGS += -Wall -Wno-import 

ifeq ($(check),yes)
    ADDITIONAL_OBJCFLAGS += -Werror
endif

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/framework.make
ifeq ($(doc),yes)
    include documentation.make
endif
-include GNUmakefile.postamble
