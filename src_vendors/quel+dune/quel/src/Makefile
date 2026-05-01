# OCaml library for query programming
# A part of the library, code generator, requires MetaOCaml.
OCAMLBIN:=$(shell dirname `which ocaml`)
OCAMLC=$(OCAMLBIN)/ocamlc
# If metaocamlc you have not here, rewrite the following.
#MOCAMLC=$(OCAMLBIN)/metaocamlc
OCAMLLIB:=$(shell $(OCAMLC) -where)
LIB=quel.cma
SCHEMALIB=schema1.cma schema_tlinq.cma

# DB_LIBS = postgresql
# LIBS = unix,threads,bigarray,$(DB_LIBS)
# FLAGS = -linkpkg -thread -package $(LIBS)

OBJS=quel_sym.cmi quel_r.cmi quel_r.cmo \
	quel_p.cmi quel_p.cmo \
	quel_sql.cmi quel_sql.cmo \
	quel_o.cmi quel_o.cmo \
	quel_norm.cmi quel_norm.cmo \
	quel_fix.cmi quel_fix.cmo

.SUFFIXES: .ml .mli .cmi .cmo .cmx .cmxa .dvi .pdf .ps .tex .eps .jpg .png .bbl

%.cmi: %.mli
	$(OCAMLC) -c -I $(OCAMLLIB) $<

%.cmi: %.ml
	$(OCAMLC) -c -I $(OCAMLLIB) $<

%.cmo: %.ml %.cmi
	$(OCAMLC) -c -I $(OCAMLLIB) $<

#.PHONY: all lib schemalib dblib
# all: lib schemalib dblib
.PHONY: all
all: lib schemalib

lib: $(LIB)
schemalib: $(SCHEMALIB)

# Should not use metaocamlc compiler
# to build a library with objects that have been compiled by metaocamlc.
quel.cma: $(OBJS)
	$(OCAMLC) -a -o $@ $(filter-out %.cmi,$^)

quel_r.cmo, quel_r.cmi : quel_sym.cmi
quel_p.cmo, quel_p.cmi : quel_sym.cmi
quel_sql.cmo, quel_sql.cmi : quel_sym.cmi
quel_o.cmo, quel_o.cmi : quel_sym.cmi
quel_norm.cmo, quel_norm.cmi : quel_o.cmo, quel_o.cmi
quel_fix.cmo, quel_fix.cmi : quel_norm.cmo, quel_sql.cmo, quel_sql.cmi

schema1.cma: schema1.cmo
	$(OCAMLC) -a -o $@ $<

schema1.cmo, schema1.cmi : quel.cma

schema_tlinq.cma: schema_tlinq.cmo
	$(OCAMLC) -a -o $@ $<

schema_tlinq.cmo, schema_tlinq.cmi : quel.cma


# dblib: db.cma
# db.cma: database.cmo
# 	$(OCAMLC) -a -o $@ $(FLAGS) $<

clean::
	$(RM) *.cm[ioxa] *.[oa] *~ *.aux *.vrb
