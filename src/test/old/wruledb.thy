theory wruledb
imports Main IsaP
begin 

lemmas wruleset[wrule] = List.rev.simps List.rev.simps

-- "See the wave-rules saved in the context"
ML {* WRulesGCtxt.print @{context}; *}

end;