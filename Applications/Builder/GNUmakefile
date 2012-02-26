#  Farmer Makefile
#
#  Copyright (C) 2002 Stefan Urbanek
#
#  Written by:	Stefan Urbanek
#  Date: 2002 May 18
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

APP_NAME     = FarmBuilder
PACKAGE_NAME = FarmBuilder

FarmBuilder_APPLICATION_ICON =
FarmBuilder_MAIN_MODEL_FILE  = Main.gorm

#
# Additional libraries
#

# BUILD_FRAMEWORK_DIR = ../Framework/AgentFarms.framework/Versions/Current

############################################################################
# ObjC files

# NOTE: all AF* files are likely to be put in some framework later for 
#       reusability

FarmBuilder_OBJC_FILES= \
        BehaviourBrowserController.m\
        FarmBuilder.m \
        FarmProjectController.m \
        StructureEditor.m \
        AFFarmProject.m \
        NSObject+NibLoading.m \
        AFClass.m \
        AFObjectWell.m \
        main.m 

############################################################################
# Resource files

FarmBuilder_RESOURCE_FILES= \
        BehaviourBrowserWindow.gorm \
        StructureEditor.gorm \
        FarmProjectWindow.gorm \
        Main.gorm 

FarmBuilder_RESOURCE_FILES += \
        Images/Behaviour.tiff \
        Images/Description.tiff \
        Images/Log.tiff \
        Images/Structure.tiff
                
ADDITIONAL_OBJCFLAGS =  

ADDITIONAL_GUI_LIBS +=  -lAgentFarms -lFarmingKit -lDevelKit

ADDITIONAL_INCLUDE_DIRS += -I../../Frameworks/

ADDITIONAL_LIB_DIRS += -L../../Frameworks/AgentFarms/AgentFarms.framework/Versions/Current/$(GNUSTEP_TARGET_LDIR)
ADDITIONAL_LIB_DIRS += -L../../Frameworks/FarmingKit/FarmingKit.framework/Versions/Current/$(GNUSTEP_TARGET_LDIR)

ADDITIONAL_OBJCFLAGS = -Wall -Wno-import

ifeq ($(check),yes)
    ADDITIONAL_OBJCFLAGS += -Werror
endif

############################################################################

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/aggregate.make
include $(GNUSTEP_MAKEFILES)/application.make
-include GNUmakefile.postamble
