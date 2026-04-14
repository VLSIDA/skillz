SHELL := /bin/bash
YAML = groups.yaml
GROUPS = $(shell grep '^\s*name:' $(YAML) | sed 's/.*name:\s*//')

REVIEWS_MD  = $(foreach g,$(GROUPS),design-review-$(g).md)
REVIEWS_HTML = $(foreach g,$(GROUPS),design-review-$(g).html)
DATE = $(shell date +%Y-%m-%d)
SINCE = $(shell date -d '2 weeks ago' +%Y-%m-%d)
CONTRIBUTIONS_MD = $(foreach g,$(GROUPS),contributions-$(g)-$(DATE).md)
CONTRIBUTIONS_HTML = $(foreach g,$(GROUPS),contributions-$(g)-$(DATE).html)
UPDATES_MD = $(foreach g,$(GROUPS),updates-$(g)-$(DATE).md)
UPDATES_HTML = $(foreach g,$(GROUPS),updates-$(g)-$(DATE).html)
AUDIT_MD = $(foreach g,$(GROUPS),prompt-injection-audit-$(g).md)
AUDIT_HTML = $(foreach g,$(GROUPS),prompt-injection-audit-$(g).html)

.PHONY: all clean clone contributions updates design-review audit FORCE
FORCE:

all: $(REVIEWS_HTML)

design-review-%.md: % FORCE
	truncate -s 0 $@
	claude -p --verbose --permission-mode acceptEdits "/design-review $<"

%.html: %.md
	sed 's/^- /\n- /' $< | pandoc -f markdown -o $@ -s --metadata title=" " -H <(echo '<style>body { max-width: 72em; } li { margin-bottom: 0.5em; }</style>')

define contributions_rule
contributions-$(1)-$$(DATE).md: $(1) FORCE
	truncate -s 0 contributions-$(1).md
	claude -p --verbose --permission-mode acceptEdits "/contributions $(1) $$(SINCE)"
	mv contributions-$(1).md $$@
endef
$(foreach g,$(GROUPS),$(eval $(call contributions_rule,$(g))))

define updates_rule
updates-$(1)-$$(DATE).md: $(1) FORCE
	truncate -s 0 updates-$(1).md
	claude -p --verbose --permission-mode acceptEdits "/updates $(1) $$(SINCE)"
	mv updates-$(1).md $$@
endef
$(foreach g,$(GROUPS),$(eval $(call updates_rule,$(g))))

prompt-injection-audit-%.md: % FORCE
	truncate -s 0 $@
	claude -p --verbose --permission-mode acceptEdits "/prompt-injection-audit $<"

ifdef GROUP
design-review: design-review-$(GROUP).md design-review-$(GROUP).html
contributions: contributions-$(GROUP)-$(DATE).md contributions-$(GROUP)-$(DATE).html
updates: updates-$(GROUP)-$(DATE).md updates-$(GROUP)-$(DATE).html
audit: prompt-injection-audit-$(GROUP).md prompt-injection-audit-$(GROUP).html
else
design-review: $(REVIEWS_MD) $(REVIEWS_HTML)
contributions: $(CONTRIBUTIONS_MD) $(CONTRIBUTIONS_HTML)
updates: $(UPDATES_MD) $(UPDATES_HTML)
audit: $(AUDIT_MD) $(AUDIT_HTML)
endif

clone:
	./clone-repos.sh $(YAML)

clean:
	rm -f $(REVIEWS_MD) $(REVIEWS_HTML) contributions-*.md contributions-*.html updates-*.md updates-*.html prompt-injection-audit-*.md prompt-injection-audit-*.html
