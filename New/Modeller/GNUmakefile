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

APP_NAME     = Modeller
PACKAGE_NAME = Modeller

Modeller_APPLICATION_ICON =
Modeller_MAIN_MODEL_FILE  = Main.gorm

#
# Additional libraries
#

# BUILD_FRAMEWORK_DIR = ../Framework/AgentFarms.framework/Versions/Current

############################################################################
# ObjC files

Modeller_OBJC_FILES= \
        AFObject.m \
        AFObjectPresenter.m \
        Controller.m  \
        main.m

############################################################################
# Resource files

Modeller_LOCALIZED_RESOURCE_FILES= \
        Main.gorm
        
Modeller_RESOURCE_FILES= 
        
ADDITIONAL_OBJCFLAGS =  

ADDITIONAL_GUI_LIBS +=  -lFarmsModel -lFarmsFarmer -lFarmsData -lXY
ADDITIONAL_INCLUDE_DIRS += -I../../Frameworks/
ADDITIONAL_LIB_DIRS += -L../../Frameworks/FarmsFarmer/FarmsFarmer.framework/Versions/Current/$(GNUSTEP_TARGET_LDIR)
ADDITIONAL_LIB_DIRS += -L../../Frameworks/FarmsModel/FarmsModel.framework/Versions/Current/$(GNUSTEP_TARGET_LDIR)
ADDITIONAL_LIB_DIRS += -L../../Frameworks/FarmsData/FarmsData.framework/Versions/Current/$(GNUSTEP_TARGET_LDIR)
ADDITIONAL_LIB_DIRS += -L../../Frameworks/XY/XY.framework/Versions/Current/$(GNUSTEP_TARGET_LDIR)

ADDITIONAL_OBJCFLAGS = -Wall -Wno-import

ifeq ($(check),yes)
    ADDITIONAL_OBJCFLAGS += -Werror
endif

############################################################################

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/application.make
-include GNUmakefile.postamble
