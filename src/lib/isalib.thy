theory isalib
imports Pure
begin

ML_file "isalib/log.ML"
(*ML_file "isalib/testing.ML"*)
ML_file "isalib/raw_source.ML"
ML_file "isalib/json.ML"
ML_file "isalib/json_io.ML"
ML_file "isalib/file_io.ML"
ML_file "isalib/text_socket.ML"

(* Generic Tools for namers, fresh names tables, and collections *)
(* for creating fresh names, has name suc and pred operation, 
   also nameset with ability to make fresh names. *)

ML_file "isalib/names/namer.ML"
ML_file "isalib/names/namers.ML" (* instances of namer, StrName, etc *)

ML_file "isalib/names/basic_nameset.ML" (* basic sets of names *)  
ML_file "isalib/names/basic_nametab.ML" (* name tables which provide fresh names *)
ML_file "isalib/names/basic_renaming.ML" (* renaming, based on tables and sets *)

(* generic Name structure provies nametables, namesets and collections *)
ML_file "isalib/names/basic_name.ML"
ML_file "isalib/names/compound_renaming.ML" (* renaming within datatypes *)
ML_file "isalib/names/renaming.ML" (* renamings which can be renamed *)

(* as above, but with renaming *)
ML_file "isalib/names/nameset.ML"
ML_file "isalib/names/nametab.ML" 

(* names + renaming for them, their tables, sets, and renamings *)
ML_file "isalib/names/names.ML"

(* Binary Relations of finite name sets: good for dependencies *)
ML_file "isalib/names/name_map.ML" (* functions/mappings on names *)
ML_file "isalib/names/name_inj.ML" (* name iso-morphisms *)
ML_file "isalib/names/name_injendo.ML" (* name auto-morphisms (name iso where dom = cod) *)
ML_file "isalib/names/name_binrel.ML" (* bin relations on names *)

(* Defines SStrName, StrName, StrIntName and common maps. *)
ML_file "isalib/names/names_common.ML" 

(* testing *)
(*PolyML.Project.use_root "test/ROOT.ML";*)

ML_file "isalib/maps/abstract_map.ML"
ML_file "isalib/maps/name_table.ML"
ML_file "isalib/maps/name_relation.ML"
ML_file "isalib/maps/name_function.ML"
ML_file "isalib/maps/name_injection.ML"
ML_file "isalib/maps/name_substitution.ML"

end
