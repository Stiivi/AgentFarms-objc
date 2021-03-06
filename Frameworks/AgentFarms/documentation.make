#
#  documentation.makefile
#
#  Copyright (C) 2001 Stefan Urbanek
#
#  Note: this file is generated by invoking 'make' in the framework top level
#        directory:
#        > make documentation-makefiles
#

DOC_DIR :=  ../Documentation

DOCUMENT_NAME := AgentFarms
############################################################################
# Documentation

# AgentFarms_AGSDOC_FLAGS = \
#        -DocumentationDirectory $(DOC_DIR)/AgentFarms \
#        -Up AgentFarms


#AgentFarms_AGSDOC_FILES = \
#        $(AgentFarms_HEADER_FILES) \
#        $(DOC_DIR)/AgentFarms.gsdoc



DOCUMENT_NAME			= ${FRAMEWORK_NAME}

AgentFarms_DOC_INSTALL_DIR= /AgentFarmsSuite

AgentFarms_AGSDOC_FILES	= \
				AgentFarms.gsdoc            \
				$(AgentFarms_HEADER_FILES)  \

AgentFarms_AGSDOC_FLAGS	= \
				-Clean NO				\
				-ConstantsTemplate Constants		\
				-Declared AgentFarms		\
				-DocumentAllInstanceVariables NO	\
				-FunctionsTemplate Functions		\
				-GenerateHtml YES			\
				-IgnoreDependencies NO			\
				-MacrosTemplate Macros			\
				-Project AgentFarms		\
				-ShowDependencies NO			\
				-Standards NO				\
				-TypedefsTemplate Types			\
				-Up AgentFarms			\
				-VariablesTemplate Variables		\
				-Verbose NO				\
				-Warn NO				\
                                -DocumentationDirectory $(DOC_DIR)/AgentFarms

include $(GNUSTEP_MAKEFILES)/documentation.make
