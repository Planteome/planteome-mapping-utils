TO = ../plant-trait-ontology/plant-trait-ontology.obo
MAPPED_SPNS = wheat maize
SPNS = $(MAPPED_SPNS) cassava rice soy

TODO = banana sweetpotato potato groundnut

all: all_map all_blip

all_map: $(patsubst %,%-map.obo,$(MAPPED_SPNS)) $(patsubst %,%-map-flip.tsv,$(MAPPED_SPNS)) $(patsubst %,%-map-diff.tsv,$(MAPPED_SPNS))
all_blip: $(patsubst %,%-blip.obo,$(SPNS)) $(patsubst %,%-blip-flip.tsv,$(SPNS)) $(patsubst %,%-blip-diff.tsv,$(SPNS))

m1-%.obo:  ../ibp-%-traits/mappings/
	./maprdf2obo.pl $<*rdf > $@

%-map.obo: m1-%.obo  $(TO) ../ibp-%-traits/
	obo-add-comments.pl -t id -t xref  $(TO) ../ibp-$*-traits/*-trait-ontology.obo $< > $@

soy-blip.tsv: 
	blip-findall -debug index   -r obol_av -i $(TO) -i ../soybase-ontology/Soy9.6.obo -u metadata_nlp  -goal index_entity_pair_label_match "entity_pair_label_reciprocal_best_intermatch(X,Y),class(X),class(Y),\\+disjoint_from(X,Y),\\+disjoint_from(Y,X)" -select "m(X,Y)" -use_tabs -label -no_pred > $@.tmp && mv $@.tmp $@

%-blip.tsv: ../ibp-%-traits/
	blip-findall -debug index   -r obol_av -i $(TO) -r ibp/$* -u metadata_nlp  -goal index_entity_pair_label_match "entity_pair_label_reciprocal_best_intermatch(X,Y),class(X),class(Y),\\+disjoint_from(X,Y),\\+disjoint_from(Y,X)" -select "m(X,Y)" -use_tabs -label -no_pred > $@.tmp && mv $@.tmp $@



%-blip.obo: %-blip.tsv
	cut -f1-4 $< | sort -u | tbl2obolinks.pl --rel xref > $@

%-blip-flip.tsv: %-blip.obo
	blip-findall -i $< -i $(TO) -r ibp/$* class_quad_flip/4 -label -no_pred > $@.tmp && mv $@.tmp $@
%-map-flip.tsv: %-map.obo
	blip-findall -i $< -i $(TO) -r ibp/$* class_quad_flip/4 -label -no_pred > $@.tmp && mv $@.tmp $@

%-blip-diff.tsv: %-blip.obo
	blip-findall -i $< -i $(TO) -r ibp/$* class_quad_diff/4 -label -no_pred > $@.tmp && mv $@.tmp $@
%-map-diff.tsv: %-map.obo
	blip-findall -i $< -i $(TO) -r ibp/$* class_quad_diff/4 -label -no_pred > $@.tmp && mv $@.tmp $@
