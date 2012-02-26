#
#  documentation.makefile
#
#  Copyright (C) 2002 Stefan Urbanek
#
#  Date: 2002 Nov 15
#

DOC_MAKE_TEMPLATE := documentation.make.template

#
# Make list of: subproj = ../Documentation/subproj/subproj.igsdoc
#

LIST := $(addprefix '@1@', $(DOCUMENTATION_SUBPROJECTS))
PROJS := $(join $(DOCUMENTATION_SUBPROJECTS), $(LIST))
LIST := $(addprefix /, $(DOCUMENTATION_SUBPROJECTS))
PROJS := $(join $(PROJS), $(LIST))
PROJS := $(addsuffix .igsdoc"; , $(PROJS))
PROJS := $(subst '@1@', = "../Documentation/, $(PROJS))

DOC_PROJECTS := '{ $(PROJS) }'
############################################################################
# Documentation

#        -Projects $(DOC_PROJECTS) \

AgentFarms_AGSDOC_FLAGS := \
        -DocumentationDirectory Documentation \

AgentFarms_AGSDOC_FILES = \
        AgentFarms.gsdoc

############################################################################
# Documentation makefiles in subprojects

documentation-makefiles:
	@(\
	    for subproj in $(DOCUMENTATION_SUBPROJECTS); do \
	        echo "Creating documentation.make for $$subproj"; \
	        cat $(DOC_MAKE_TEMPLATE) | \
	            sed "s/@@SUBPROJECT@@/$$subproj/g" > \
	                $$subproj/documentation.make; \
	    done; \
	)
