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

DOCUMENT_NAME := FarmingKit
############################################################################
# Documentation

# FarmingKit_AGSDOC_FLAGS = \
#        -DocumentationDirectory $(DOC_DIR)/FarmingKit \
#        -Up AgentFarms


#FarmingKit_AGSDOC_FILES = \
#        $(FarmingKit_HEADER_FILES) \
#        $(DOC_DIR)/FarmingKit.gsdoc



DOCUMENT_NAME			= ${FRAMEWORK_NAME}

FarmingKit_DOC_INSTALL_DIR= /AgentFarmsSuite

FarmingKit_AGSDOC_FILES	= \
				FarmingKit.gsdoc            \
				$(FarmingKit_HEADER_FILES)  \

FarmingKit_AGSDOC_FLAGS	= \
				-Clean NO				\
				-ConstantsTemplate Constants		\
				-Declared FarmingKit		\
				-DocumentAllInstanceVariables NO	\
				-FunctionsTemplate Functions		\
				-GenerateHtml YES			\
				-IgnoreDependencies NO			\
				-MacrosTemplate Macros			\
				-Project FarmingKit		\
				-ShowDependencies NO			\
				-Standards NO				\
				-TypedefsTemplate Types			\
				-Up FarmingKit			\
				-VariablesTemplate Variables		\
				-Verbose NO				\
				-Warn NO				\
                                -DocumentationDirectory $(DOC_DIR)/FarmingKit

include $(GNUSTEP_MAKEFILES)/documentation.make