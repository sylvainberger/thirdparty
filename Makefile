#########################################################################
#
# This is the master makefile.
# Here we put all the top-level make targets, platform-independent
# rules, etc.
#
# Run 'make help' to list helpful targets.
#
#########################################################################


.PHONY: all debug clean realclean nuke

base_dir     =${working_dir}
working_dir	:= ${shell pwd}


$(info Thirdparty:)

# Figure out which architecture we're on
include ${working_dir}/src/make/detectplatform.mk

# Presence of make variables DEBUG and PROFILE cause us to make special
# builds, which we put in their own areas.
ifdef DEBUG
    variant +=.debug
endif

MY_MAKE_FLAGS ?=
MY_CMAKE_FLAGS ?=

# Set up variables holding the names of platform-dependent directories --
# set these after evaluating site-specific instructions
top_build_dir := build
build_dir     := ${top_build_dir}/${platform}${variant}
top_dist_dir  := dist
dist_dir      := ${top_dist_dir}/${platform}${variant}

$(info -- base_dir = ${base_dir})
$(info -- build_dir = ${build_dir})
$(info -- dist_dir = ${dist_dir})


VERBOSE := ${SHOWCOMMANDS}
ifneq (${verbose},)
MY_CMAKE_FLAGS += -DCMAKE_VERBOSE_MAKEFILE:BOOL=${verbose}
endif

ifneq (${build_libs},)
MY_CMAKE_FLAGS += -Dbuild_libs:BOOL=${build_libs}
endif

ifneq (${build_viewers},)
MY_CMAKE_FLAGS += -Dbuild_viewers:BOOL=${build_viewers}
endif

ifneq (${build_tests},)
MY_CMAKE_FLAGS += -Dbuild_tests:BOOL=${build_tests}
endif

ifneq (${build_media},)
MY_CMAKE_FLAGS += -Dbuild_media:BOOL=${build_media}
endif

ifneq (${build_static},)
MY_CMAKE_FLAGS += -DCMAKE_SHARED_LIBS:BOOL=OFF
endif

ifdef DEBUG
MY_CMAKE_FLAGS += -DCMAKE_BUILD_TYPE:STRING=Debug
endif

#########################################################################




#########################################################################
# Top-level documented targets

all: dist

# 'make debug' is implemented via recursive make setting DEBUG
debug:
	${MAKE} DEBUG=1 --no-print-directory

# 'make cmakesetup' constructs the build directory and runs 'cmake' there,
# generating makefiles to build the project.  For speed, it only does this when
# ${build_dir}/Makefile doesn't already exist, in which case we rely on the
# cmake generated makefiles to regenerate themselves when necessary.
cmakesetup:   
	@ (if [ ! -e ${build_dir}/Makefile ] ; then \
		cmake -E make_directory ${build_dir} ; \
		cd ${build_dir} ; \
		cmake -DCMAKE_INSTALL_PREFIX=${base_dir}/${dist_dir} \
			${MY_CMAKE_FLAGS} \
			../../ ; \
	 fi)

# 'make cmake' does a basic build (after first setting it up)
cmake: cmakesetup
	( cd ${build_dir} ; ${MAKE} ${MY_MAKE_FLAGS} )

# 'make cmakeinstall' builds everthing and installs it in 'dist'.
# Suppress pointless output from docs installation.
cmakeinstall: cmake
	( cd ${build_dir} ; ${MAKE} ${MY_MAKE_FLAGS} install | grep -v '^-- \(Installing\|Up-to-date\).*doc/html' )

# 'make dist' is just a synonym for 'make cmakeinstall'
dist : cmakeinstall

# 'make test' does a full build and then runs all tests
test: cmake
	( cd ${build_dir} ; ${MAKE} ${MY_MAKE_FLAGS} test )

# 'make package' builds everything and then makes an installable package 
# (platform dependent -- may be .tar.gz, .sh, .dmg, .rpm, .deb. .exe)
package: cmakeinstall
	( cd ${build_dir} ; ${MAKE} ${MY_MAKE_FLAGS} package )

# 'make package_source' makes an installable source package 
# (platform dependent -- may be .tar.gz, .sh, .dmg, .rpm, .deb. .exe)
package_source: cmakeinstall
	( cd ${build_dir} ; ${MAKE} ${MY_MAKE_FLAGS} package_source )

# 'make clean' clears out the build directory for this platform
clean:
	cmake -E remove_directory ${build_dir}

# 'make realclean' clears out both build and dist directories for this platform
realclean: clean
	cmake -E remove_directory ${dist_dir}

# 'make nuke' blows away the build and dist areas for all platforms
nuke:
	cmake -E remove_directory ${top_build_dir}
	cmake -E remove_directory ${top_dist_dir}

doxygen:
	doxygen src/doc/Doxyfile

#########################################################################



# 'make help' prints important make targets
help:
	@echo "Targets:"
	@echo "  make                        Build all projects for development and test in ${build_dir},"
	@echo "                              install distribution libraries in '${dist_dir}'."
	@echo "  make debug                  Build all projects with debugging symbols when possible."
	@echo "  make clean                  Get rid of all the development and test files."
	@echo "  make realclean              Get rid of both '${build_dir}/platform' and '${dist_dir}/platform'."
	@echo "  make nuke                   Get rid of all 'build' and 'dist' and all platforms"
	@echo "  make help                   Print all the make options"
	@echo ""
	@echo "Helpful modifiers:"
	@echo "  make verbose=1 ...          Show all compilation commands."
	@echo "  make build_libs=1 ...       Build libraries."
	@echo "  make build_viewers=1 ...    Build viewers."
	@echo "  make build_tests=1 ...      Build tests."
	@echo "  make build_media=1 ...      Build media."
	@echo "  make build_static=1 ...     Build static library instead of shared."
	@echo ""

