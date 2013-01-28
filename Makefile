# jgsys
# (c) 2013 Justin Gottula
# The source code of this project is distributed under the terms of the
# simplified BSD license. See the LICENSE file for details.

TIMESTAMP=$(shell date +'%Y%m%d-%H%M')


.PHONY: all clean backup boot kern

# default rule
all: boot kern

boot:
	$(MAKE) -C boot all
kern:
	$(MAKE) -C kern all

clean:
	$(MAKE) -C boot clean
	$(MAKE) -C kern clean

backup:
	cd .. && tar -acvf backup/jgsys-$(TIMESTAMP).tar.xz jgsys/
