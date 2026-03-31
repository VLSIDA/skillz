YAML = groups.yaml
GROUPS = $(shell grep '^\s*repo:' $(YAML) | sed 's|.*/||')

REVIEWS_MD  = $(foreach g,$(GROUPS),design-review-$(g).md)
REVIEWS_PDF = $(foreach g,$(GROUPS),design-review-$(g).pdf)
DATE = $(shell date +%Y-%m-%d)
SINCE = $(shell date -d '2 weeks ago' +%Y-%m-%d)
CONTRIBUTIONS_MD = $(foreach g,$(GROUPS),contributions-$(g)-$(DATE).md)
CONTRIBUTIONS_PDF = $(foreach g,$(GROUPS),contributions-$(g)-$(DATE).pdf)
UPDATES_MD = $(foreach g,$(GROUPS),updates-$(g)-$(DATE).md)
UPDATES_PDF = $(foreach g,$(GROUPS),updates-$(g)-$(DATE).pdf)
AUDIT_MD = $(foreach g,$(GROUPS),prompt-injection-audit-$(g).md)
AUDIT_PDF = $(foreach g,$(GROUPS),prompt-injection-audit-$(g).pdf)

.PHONY: all clean clone contributions updates design-review audit

all: $(REVIEWS_PDF)

design-review-%.md: %
	truncate -s 0 $@
	claude -p --verbose --permission-mode acceptEdits "/design-review $<"

%.pdf: %.md
	sed 's/^- /\n- /' $< | pandoc -f markdown -o $@ --pdf-engine=xelatex -V geometry:margin=1in

define contributions_rule
contributions-$(1)-$$(DATE).md: $(1)
	truncate -s 0 contributions-$(1).md
	claude -p --verbose --permission-mode acceptEdits "/contributions $(1) $$(SINCE)"
	mv contributions-$(1).md $$@
endef
$(foreach g,$(GROUPS),$(eval $(call contributions_rule,$(g))))

define updates_rule
updates-$(1)-$$(DATE).md: $(1)
	truncate -s 0 updates-$(1).md
	claude -p --verbose --permission-mode acceptEdits "/updates $(1) $$(SINCE)"
	mv updates-$(1).md $$@
endef
$(foreach g,$(GROUPS),$(eval $(call updates_rule,$(g))))

prompt-injection-audit-%.md: %
	truncate -s 0 $@
	claude -p --verbose --permission-mode acceptEdits "/prompt-injection-audit $<"

ifdef GROUP
design-review: design-review-$(GROUP).md design-review-$(GROUP).pdf
contributions: contributions-$(GROUP)-$(DATE).md contributions-$(GROUP)-$(DATE).pdf
updates: updates-$(GROUP)-$(DATE).md updates-$(GROUP)-$(DATE).pdf
audit: prompt-injection-audit-$(GROUP).md prompt-injection-audit-$(GROUP).pdf
else
design-review: $(REVIEWS_MD) $(REVIEWS_PDF)
contributions: $(CONTRIBUTIONS_MD) $(CONTRIBUTIONS_PDF)
updates: $(UPDATES_MD) $(UPDATES_PDF)
audit: $(AUDIT_MD) $(AUDIT_PDF)
endif

clone:
	./clone-repos.sh $(YAML)

clean:
	rm -f $(REVIEWS_MD) $(REVIEWS_PDF) contributions-*.md contributions-*.pdf updates-*.md updates-*.pdf prompt-injection-audit-*.md prompt-injection-audit-*.pdf
