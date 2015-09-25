MAINCLASS:=vertx.elasticsearch.core
TESTCLASS:=test
NAME=vertx-elastic-search
DOCTARGET=$(NAME).pdf
VERSION=1.0.0

BUILDDIR=/dev/shm/${NAME}-build
SRCDIR=$(BUILDDIR)/src
CLASSDIR=$(BUILDDIR)/classes
SOURCE=$(BUILDDIR)/$(NAME).org
CORESRC=$(SRCDIR)/vertx/elasticsearch/core.clj
COREOBJ=$(CLASSDIR)/vertx/elasticsearch/core.class
TARGET:=$(BUILDDIR)/$(NAME)-$(VERSION).jar

PNGS=$(patsubst %.aa,%.png,$(shell find . -name "*.aa"))
PNGS+=$(patsubst %.uml,%.png,$(shell find . -name "*.uml"))

vpath %.clj $(SRCDIR)
vpath %.java $(SRCDIR)
vpath %.class $(CLASSDIR)

CLASSPATHCONFIG:=classpath

ifeq ($(CLASSPATHCONFIG), $(wildcard $(CLASSPATHCONFIG)))
CLASSPATH:=$(shell cat $(CLASSPATHCONFIG))
endif

all: $(COREOBJ)

doc: $(DOCTARGET)

jar: $(TARGET)

$(DOCTARGET): $(SOURCE) $(HOME)/templates/style.sty $(HOME)/templates/pandoc-template.tex $(PNGS)
	pandoc -H $(HOME)/templates/style.sty --latex-engine=xelatex --template=$(HOME)/templates/pandoc-template.tex -f org -o $@ $(SOURCE)

$(TARGET): $(COREOBJ)
	jar cf $(TARGET) -C $(BUILDDIR)/classes/ .

$(SOURCE): preface.org code.org
	@cat preface.org > $(SOURCE)
	@cat code.org >> $(SOURCE)

$(CORESRC): code.org | prebuild
	emacs $< --batch -f org-babel-tangle --kill

$(COREOBJ): $(CORESRC)
	java -cp $(CLASSPATH):$(SRCDIR) -Dclojure.compile.path=$(CLASSDIR) clojure.lang.Compile $(MAINCLASS)

prebuild:
ifeq "$(wildcard $(BUILDDIR))" ""
	@mkdir -p $(BUILDDIR)
	@mkdir -p $(CLASSDIR)
endif

%.png: %.uml
	java -jar /opt/plantuml.jar -tpng -nbthread auto $<

%.png: %.aa
	java -jar /opt/ditaa0_9.jar -e utf-8 -s 2.5 $< $@

clean:
	rm -rf $(BUILDDIR)

.PHONY: all clean doc jar prebuild
