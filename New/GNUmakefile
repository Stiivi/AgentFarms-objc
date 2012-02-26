#
#  Top Makefile for the AgentFarms
#  
#  Copyright (C) 2002 Stefan Urbanek
#
#  Written by:	Stefan Urbanek
#
#  This file is part of the AgentFarms
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
#  Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA
#

include $(GNUSTEP_MAKEFILES)/common.make

TOOL_NAME = afdescribe

afdescribe_OBJC_FILES = \
    afdescribe.m

ADDITIONAL_TOOL_LIBS = -lFarmsModel -lFarmsData -lDevelKit
ADDITIONAL_INCLUDE_DIRS += -I../Frameworks/

ADDITIONAL_LIB_DIRS += -L../Frameworks/FarmsModel/FarmsModel.framework/Versions/Current/$(GNUSTEP_TARGET_LDIR)
ADDITIONAL_LIB_DIRS += -L../Frameworks/FarmsData/FarmsData.framework/Versions/Current/$(GNUSTEP_TARGET_LDIR)

ADDITIONAL_OBJCFLAGS = -Wall -Wno-import

-include GNUMakefile.preamble
include $(GNUSTEP_MAKEFILES)/tool.make
-include GNUMakefile.postamble

