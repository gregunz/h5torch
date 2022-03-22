.PHONY: default test install uninstall reinstall clean realclean

#################################################################################
# GLOBALS                                                                       #
#################################################################################
SHELL=/bin/bash
PLATFORM = $(shell uname)

# MacOS or Linux (both x86_64 processors)
CONDA_LINUX_INSTALLER = miniconda_linux-x86_64.sh
CONDA_MACOS_INSTALLER = miniconda_macosx-x86_64.sh

ifeq ($(PLATFORM), Darwin)
  CONDA_INSTALLER = $(CONDA_MACOS_INSTALLER)
else
  CONDA_INSTALLER = $(CONDA_LINUX_INSTALLER)
endif

CONDA_REQUIREMENTS ?= environment.dev.yml

CONDA_HOME = $(HOME)/miniconda3
CONDA_BIN_DIR = $(CONDA_HOME)/bin
CONDA = $(CONDA_BIN_DIR)/conda

ENV_NAME = h5torch
ENV_DIR = $(CONDA_HOME)/envs/$(ENV_NAME)
ENV_BIN_DIR = $(ENV_DIR)/bin
ENV_LIB_DIR = $(ENV_DIR)/lib
ENV_PYTHON = $(ENV_BIN_DIR)/python

CONDA_SOURCE_ACTIVATE = source $(CONDA_BIN_DIR)/activate
CONDA_ENV_ACTIVATE = conda activate $(ENV_NAME)
CONDA_ACTIVATE = $(CONDA_SOURCE_ACTIVATE) && $(CONDA_ENV_ACTIVATE)

#################################################################################
# COMMANDS                                                                      #
#################################################################################


default:
	@echo 'Script to build the environment named "$(ENV_NAME)"'
	@echo
	@echo 'usage: make <target>'
	@echo
	@echo 'Few information:'
	@echo '$$ conda installer: $(CONDA_INSTALLER)'
	@echo '$$ conda requirements: $(CONDA_REQUIREMENTS)'
	@echo '$$ conda command: $(CONDA)'
	@echo '$$ python command: $(ENV_PYTHON)'
	@echo
	@echo 'To activate the environment:'
	@echo '$$ $(CONDA_SOURCE_ACTIVATE)'
	@echo '$$ $(CONDA_ENV_ACTIVATE)'
	@echo


conda_download:
	@echo 'downloading latest version of conda binaries'
	@echo
	wget https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh -O $(CONDA_MACOS_INSTALLER)
	wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O $(CONDA_LINUX_INSTALLER)


conda_install:
	@echo 'installing the conda package manager'
	@echo
	bash $(CONDA_INSTALLER) -b -p $(CONDA_HOME)
	$(CONDA) install --yes conda-build
	$(CONDA) install --yes argcomplete
	@echo


conda_uninstall:
	@echo 'uninstalling conda package manager'
	@echo
	rm -rf $(CONDA_HOME)
	@echo


conda_env_create:
	@echo 'creating the '$(ENV_NAME)' environment'
	@echo
	$(CONDA) env create --file $(CONDA_REQUIREMENTS)
	@echo
	@echo 'adding project sources to '$(ENV_NAME)' environment'
	@echo
	$(CONDA_ACTIVATE) && pip install -e .
	@echo
	@echo 'adding pyright (this assumes npm in $(CONDA_REQUIREMENTS))'
	@echo
	$(CONDA_ACTIVATE) && npm install -g pyright@1.1.226
	@echo

conda_env_remove:
	@echo 'uninstalling the '$(ENV_NAME)' environment'
	@echo
	$(CONDA) remove --yes --name $(ENV_NAME) --all
	@echo



install: conda_env_create


uninstall: conda_env_remove


reinstall: uninstall install


full_install: conda_install conda_env_create


full_uninstall: conda_env_remove conda_uninstall


full_reinstall: full_uninstall full_install


clean:
	@echo 'cleaning up temporary files'
	find . -name '*.pyc' -type f -exec rm {} ';'
	find . -name '__pycache__' -type d -print | xargs rm -rf
	@echo 'NOTE: you should clean up the following occasionally (by hand)'
	git clean -fdn


realclean: clean reinstall


format:
	black .
	isort **/*.py


lint:
	black . --check
	isort **/*.py --check
	flake8 .


type_check:
	pyright .


check: lint type_check


test:
	rm -f `python -c "import site; print(site.getsitepackages()[0])"`/tests/__init__.py
	coverage run --source=h5torch tests/test_all.py
	coverage report


ln_io:
	ln -s /io io
