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

APP_NAME     = Farmer
PACKAGE_NAME = Farmer

Farmer_APPLICATION_ICON =
Farmer_MAIN_MODEL_FILE  = Farmer.gorm

#
# Additional libraries
#

# BUILD_FRAMEWORK_DIR = ../Framework/AgentFarms.framework/Versions/Current

############################################################################
# ObjC files

Farmer_OBJC_FILES= \
        FarmsController.m \
        AFFarm.m \
        AFFarmerModule.m \
        ModelPanel.m \
        ModulesView.m \
        WindowController.m \
        FarmLog.m \
        PrototypesBrowser.m \
        ProbesBrowser.m \
        ViewBrowser.m \
        ObjectBrowser.m \
        DescriptionWindowController.m \
        NSObject+NibLoading.m \
        NSTableView+additions.m \
        main.m 

############################################################################
# Resource files

Farmer_LOCALIZED_RESOURCE_FILES= \
        Farm.gorm \
        Farmer.gorm \
        PrototypesBrowser.gorm \
        ObjectBrowser.gorm \
        ProbesBrowser.gorm \
        LatticeBrowser.gorm \
        LogWindow.gorm \
        DescriptionWindow.gorm \
        ModelPanel.gorm
        
Farmer_RESOURCE_FILES= \
        Images/afarm.tiff \
        Images/afmodel.tiff \
        Images/run.tiff \
        Images/runDisabled.tiff \
        Images/stop.tiff \
        Images/watch.tiff \
        Images/launch.tiff \
        Images/restart.tiff \
        Images/restartDisabled.tiff \
        Images/Description.tiff \
        Images/Graphs.tiff \
        Images/Log.tiff  \
        Images/Objects.tiff \
        Images/Lattice.tiff \
        Images/Probes.tiff \
        Images/Connect.tiff \
        Images/View.tiff \
        Images/Prototypes.tiff \
        StandardModules.plist
        
ADDITIONAL_OBJCFLAGS =  

ADDITIONAL_GUI_LIBS +=  -lAgentFarms -lFarmingKit

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
