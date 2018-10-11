SUBDIRS := $(wildcard */.)

all: makefiles compile rename

makefiles:
	for dir in $(SUBDIRS); do \
	cd $$dir; \
	ln -s ../../src-makefiles/* .; \
	cd ..; \
	done

compile:
	-for dir in $(SUBDIRS); do \
	$(MAKE) -C $$dir; \
	done

rename:
	for dir in $(SUBDIRS); do \
	$(MAKE) -C $$dir rename; \
	done

clean:
	for dir in $(SUBDIRS); do \
	$(MAKE) -C $$dir clean; \
	done



