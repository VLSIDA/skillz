YAML = groups.yaml
GROUPS = $(shell grep '^\s*repo:' $(YAML) | sed 's|.*/||')

REVIEWS_MD  = $(foreach g,$(GROUPS),design-review-$(g).md)
REVIEWS_PDF = $(foreach g,$(GROUPS),design-review-$(g).pdf)
DATE = $(shell date +%Y-%m-%d)
SINCE = $(shell date -d '2 weeks ago' +%Y-%m-%d)
CONTRIBUTIONS_MD = $(foreach g,$(GROUPS),contributions-$(g)-$(DATE).md)
WEEKLY_MD = $(foreach g,$(GROUPS),weekly-$(g)-$(DATE).md)

.PHONY: all clean clone contributions weekly design-review

all: $(REVIEWS_PDF)

design-review-%.md: %
	claude -p --verbose "/design-review $<"

design-review-%.pdf: design-review-%.md
	pandoc $< -o $@ --pdf-engine=xelatex -V geometry:margin=1in

define contributions_rule
contributions-$(1)-$$(DATE).md: $(1)
	claude -p --verbose "/contributions $(1) $$(SINCE)"
	mv contributions-$(1).md $$@
endef
$(foreach g,$(GROUPS),$(eval $(call contributions_rule,$(g))))

define weekly_rule
weekly-$(1)-$$(DATE).md: $(1)
	claude -p --verbose "/weekly $(1) $$(SINCE)"
	mv weekly-$(1).md $$@
endef
$(foreach g,$(GROUPS),$(eval $(call weekly_rule,$(g))))

ifdef GROUP
design-review: design-review-$(GROUP).md design-review-$(GROUP).pdf
contributions: contributions-$(GROUP)-$(DATE).md
weekly: weekly-$(GROUP)-$(DATE).md
else
design-review: $(REVIEWS_MD) $(REVIEWS_PDF)
contributions: $(CONTRIBUTIONS_MD)
weekly: $(WEEKLY_MD)
endif

clone:
	./clone-repos.sh $(YAML)

clean:
	rm -f $(REVIEWS_MD) $(REVIEWS_PDF) contributions-*.md weekly-*.md
