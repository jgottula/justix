# justix: hub makefile
# (c) 2013 Justin Gottula
# The source code of this project is distributed under the terms of the
# simplified BSD license. See the LICENSE file for details.

TIMESTAMP=$(shell date +'%Y%m%d-%H%M')


.PHONY: all clean backup boot kern script

# default rule
all: boot kern script

boot:
	$(MAKE) -C boot all
kern:
	$(MAKE) -C kern all
script:
	$(MAKE) -C script all

clean:
	$(MAKE) -C boot clean
	$(MAKE) -C kern clean
	$(MAKE) -C script clean

backup:
	cd .. && tar -acvf backup/justix-$(TIMESTAMP).tar.xz justix/
