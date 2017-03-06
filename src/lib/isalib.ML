use "isalib/log.ML";
(*use "isalib/testing.ML"*)
use "isalib/raw_source.ML";
use "isalib/json.ML";
use "isalib/json_io.ML";
use "isalib/file_io.ML";
use "isalib/text_socket.ML";

(* Generic Tools for namers, fresh names tables, and collections *)
(* for creating fresh names, has name suc and pred operation, 
   also nameset with ability to make fresh names. *)

use "isalib/names/namer.ML";
use "isalib/names/namers.ML"; (* instances of namer, StrName, etc *)

use "isalib/names/basic_nameset.ML"; (* basic sets of names *)  
use "isalib/names/basic_nametab.ML"; (* name tables which provide fresh names *)
use "isalib/names/basic_renaming.ML"; (* renaming, based on tables and sets *)

(* generic Name structure provies nametables, namesets and collections *)
use "isalib/names/basic_name.ML";
use "isalib/names/compound_renaming.ML"; (* renaming within datatypes *)
use "isalib/names/renaming.ML" (* renamings which can be renamed *)

(* as above, but with renaming *)
use "isalib/names/nameset.ML";
use "isalib/names/nametab.ML";

(* names + renaming for them, their tables, sets, and renamings *)
use "isalib/names/names.ML";

(* Binary Relations of finite name sets: good for dependencies *)
use "isalib/names/name_map.ML"; (* functions/mappings on names *)
use "isalib/names/name_inj.ML"; (* name iso-morphisms *)
use "isalib/names/name_injendo.ML"; (* name auto-morphisms (name iso where dom = cod) *)
use "isalib/names/name_binrel.ML"; (* bin relations on names *)

(* Defines SStrName, StrName, StrIntName and common maps. *)
use "isalib/names/names_common.ML"; 

(* testing *)
(*PolyML.Project.use_root "test/ROOT.ML";*)

use "isalib/maps/abstract_map.ML";
use "isalib/maps/name_table.ML";
use "isalib/maps/name_relation.ML";
use "isalib/maps/name_function.ML";
use "isalib/maps/name_injection.ML";
use "isalib/maps/name_substitution.ML";

