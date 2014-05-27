EMACS=emacs

EMACS_CLEAN=-Q
EMACS_BATCH=$(EMACS_CLEAN) --batch
TESTS=

CURL=curl --silent -L
WORK_DIR=$(shell pwd)
PACKAGE_NAME=$(shell basename $(WORK_DIR))
TRAVIS_FILE=.travis.yml
TEST_DIR=tests

ORG_URL=http://orgmode.org/org-latest.tar.gz
ORG_TAR=org-latest.tar.gz
XML_RPC_URL=https://launchpad.net/xml-rpc-el/trunk/1.6.8/+download/xml-rpc.el
XML_RPC=xml-rpc
METAWEBLOG_URL=https://raw.githubusercontent.com/punchagan/metaweblog/master/metaweblog.el
METAWEBLOG=metaweblog
ERT_URL=http://git.savannah.gnu.org/cgit/emacs.git/plain/lisp/emacs-lisp/ert.el?h=emacs-24
ERT=ert
CL_URL=https://raw.githubusercontent.com/emacsmirror/cl-lib/master/cl-lib.el
CL=cl-lib

build :
	$(EMACS) $(EMACS_BATCH) --eval             \
	    "(progn                                \
	      (setq byte-compile-error-on-warn t)  \
	      (batch-byte-compile))" *.el

download-org :
	$(CURL) '$(ORG_URL)' > '$(WORK_DIR)/$(ORG_TAR)'
	tar xzf $(WORK_DIR)/$(ORG_TAR)
	rm $(WORK_DIR)/$(ORG_TAR)

download-xml-rpc :
	$(CURL) '$(XML_RPC_URL)' > '$(WORK_DIR)/$(XML_RPC).el'

download-metaweblog :
	$(CURL) '$(METAWEBLOG_URL)' > '$(WORK_DIR)/$(METAWEBLOG).el'

download-ert:
	$(CURL) '$(ERT_URL)' > '$(WORK_DIR)/$(ERT).el'

download-cl:
	$(CURL) '$(CL_URL)' > '$(WORK_DIR)/$(CL).el'

download-deps : download-xml-rpc download-metaweblog download-org download-ert download-cl

test:
	@cd $(TEST_DIR)                                   && \
	(for test_lib in *-tests.org; do                       \
	    $(EMACS) $(EMACS_BATCH) -L . -L .. -L ../org-mode/lisp  \
	    -l $(XML_RPC) -l cl-lib -l cl -l $(ERT) -l $(METAWEBLOG) --eval \
	    "(progn                                          \
              (org-babel-do-load-languages 'org-babel-load-languages  '((emacs-lisp . t) (python . t))) \
              (setq org-confirm-babel-evaluate nil)          \
	      (org-babel-load-file \"$$test_lib\")           \
	      (fset 'ert--print-backtrace 'ignore)           \
	      (ert-run-tests-batch-and-exit '(and \"$(TESTS)\" (not (tag :interactive)))))" || exit 1; \
	done)