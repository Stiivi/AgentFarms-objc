#
#  GNUmakefile
#
#  Copyright (C) 2003 Stefan Urbanek
#
#  Date: 2003 May 10
#
#  This file is part of the FarmsViews framework
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

FRAMEWORK_NAME = FarmingKit

############################################################################
# FarmsViews

FarmingKit_OBJC_FILES =     \
    AFButtonRow.m \
    AFColorMap.m \
    AFFarmStore.m \
    AFGeometry.m \
    AFGraph.m \
    AFGraphElement.m \
    AFGraphView.m \
    AFGraphWindow.m \
    AFLatticeView.m \
    AFSequenceGraphElement.m
        
        
FarmingKit_HEADER_FILES =   \
    AFButtonRow.h \
    AFColorMap.h \
    AFFarmStore.h \
    AFGeometry.h \
    AFGraph.h \
    AFGraphElement.h \
    AFGraphView.h \
    AFGraphWindow.h \
    AFLatticeView.h \
    AFSequenceGraphElement.h
  
FarmingKit_RESOURCE_FILES = ScriptingInfo.plist  

ADDITIONAL_INCLUDE_DIRS += -I../../Frameworks/

ifeq ($(check),yes)
    ADDITIONAL_OBJCFLAGS += -Werror
endif

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/framework.make
ifeq ($(doc),yes)
    include documentation.make
endif
-include GNUmakefile.postamble
