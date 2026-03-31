YAML = groups.yaml
GROUPS = $(shell grep '^\s*repo:' $(YAML) | sed 's|.*/||')

REVIEWS_MD  = $(foreach g,$(GROUPS),design-review-$(g).md)
REVIEWS_PDF = $(foreach g,$(GROUPS),design-review-$(g).pdf)
DATE = $(shell date +%Y-%m-%d)
SINCE = $(shell date -d '2 weeks ago' +%Y-%m-%d)
CONTRIBUTIONS_MD = $(foreach g,$(GROUPS),contributions-$(g)-$(DATE).md)
CONTRIBUTIONS_PDF = $(foreach g,$(GROUPS),contributions-$(g)-$(DATE).pdf)
WEEKLY_MD = $(foreach g,$(GROUPS),weekly-$(g)-$(DATE).md)
WEEKLY_PDF = $(foreach g,$(GROUPS),weekly-$(g)-$(DATE).pdf)
AUDIT_MD = $(foreach g,$(GROUPS),prompt-injection-audit-$(g).md)
AUDIT_PDF = $(foreach g,$(GROUPS),prompt-injection-audit-$(g).pdf)

.PHONY: all clean clone contributions weekly design-review audit

all: $(REVIEWS_PDF)

design-review-%.md: %
	claude -p --verbose --permission-mode acceptEdits --allowedTools "Read,Glob,Grep,Bash(git:*),Write(*design-review-*.md)" -- "/design-review $<"

%.pdf: %.md
	sed 's/^- /\n- /' $< | pandoc -f markdown -o $@ --pdf-engine=xelatex -V geometry:margin=1in

define contributions_rule
contributions-$(1)-$$(DATE).md: $(1)
	claude -p --verbose --permission-mode acceptEdits --allowedTools "Read,Glob,Grep,Bash(git:*),Write(*contributions-*.md)" -- "/contributions $(1) $$(SINCE)"
	mv contributions-$(1).md $$@
endef
$(foreach g,$(GROUPS),$(eval $(call contributions_rule,$(g))))

define weekly_rule
weekly-$(1)-$$(DATE).md: $(1)
	claude -p --verbose --permission-mode acceptEdits --allowedTools "Read,Glob,Grep,Bash(git:*),Write(*weekly-*.md)" -- "/weekly $(1) $$(SINCE)"
	mv weekly-$(1).md $$@
endef
$(foreach g,$(GROUPS),$(eval $(call weekly_rule,$(g))))

prompt-injection-audit-%.md: %
	claude -p --verbose --permission-mode acceptEdits --allowedTools "Read,Glob,Grep,Bash(git:*),Write(*prompt-injection-audit-*.md)" -- "/prompt-injection-audit $<"

ifdef GROUP
design-review: design-review-$(GROUP).md design-review-$(GROUP).pdf
contributions: contributions-$(GROUP)-$(DATE).md contributions-$(GROUP)-$(DATE).pdf
weekly: weekly-$(GROUP)-$(DATE).md weekly-$(GROUP)-$(DATE).pdf
audit: prompt-injection-audit-$(GROUP).md prompt-injection-audit-$(GROUP).pdf
else
design-review: $(REVIEWS_MD) $(REVIEWS_PDF)
contributions: $(CONTRIBUTIONS_MD) $(CONTRIBUTIONS_PDF)
weekly: $(WEEKLY_MD) $(WEEKLY_PDF)
audit: $(AUDIT_MD) $(AUDIT_PDF)
endif

clone:
	./clone-repos.sh $(YAML)

clean:
	rm -f $(REVIEWS_MD) $(REVIEWS_PDF) contributions-*.md contributions-*.pdf weekly-*.md weekly-*.pdf prompt-injection-audit-*.md prompt-injection-audit-*.pdf
