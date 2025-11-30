<img align="right" src="https://github.com/user-attachments/assets/cd05ba75-dd09-444a-a0ea-aaf4b4eecd20">  
  
Skillchain Calculator
  
Display skillchains possible given an opening weapon type and closing weapon type.  

Usage:  
/scc token1 token2 [level] [both] [sc:element]  
Tokens can be one of the following:  

Weapon Types:  
&ensp;h2h, dagger, sword, gs, axe, ga, scythe,  
&ensp;polearm, katana, gkt, club, staff, archery, mm, smn  
&ensp;Weapons Alias as well: e.g. ga or greataxe work, full list in skills.lua

Jobs:  
&ensp;WAR, MNK, WHM, BLM, RDM, THF, PLD, DRK, BST, BRD,  
&ensp;RNG, SAM, NIN, DRG, SMN, BLU, COR, DNC, SCH  

Job + Weapon Filters:  
&ensp;Use the syntax `job:weapon` or `job:weapon1,weapon2` to limit WS by weapon type  
&ensp;e.g. `/scc thf:sword war:ga,polearm`  

Primary Weapon Auto-Limit:  
&ensp;If a plain job token is used (e.g. `thf`), the job’s `primaryWeapons` list defined in Jobs.lua is used.  
&ensp;Example: `/scc thf war` is internally treated as `/scc thf:dagger war:ga,axe`  

[level]  
&ensp;Optional value that filters skillchain tier  
&ensp;2 only shows tier 2 and 3 skillchains  
&ensp;1 or empty shows all  

[both]  
&ensp;Optional keyword to calculate skillchains in both directions  

[sc:element]  
&ensp;Optional filter that limits results to skillchains whose burst table contains the given element  
&ensp;e.g. `/scc thf war sc:ice` will show only SCs with Ice as a burst element  
&ensp;Case-insensitive (`sc:ice`, `sc:Ice`, `SC:ICE` etc.)  

Examples:  
&ensp;/scc katana h2h both 2  
&ensp;/scc thf war  
&ensp;/scc thf:sword war:ga  
&ensp;/scc thf war sc:ice  
&ensp;/scc nin:katana drk:scythe 2 both  

Commands:  
&ensp;/scc help -- show all commands  
&ensp;/scc setx # -- set x anchor  
&ensp;/scc sety # -- set y anchor  
&ensp;/scc setlevel # -- set default level filter (1–3)  
&ensp;/scc setboth true|false -- set default for 'both' param  
&ensp;/scc status -- show default filter status  
&ensp;/scc clear -- clear out window  
&ensp;/scc debug -- enable debugging  

Files:  
&ensp;skillchaincalc.lua -- main addon  
&ensp;skills.lua -- weaponskill data and colors  
&ensp;jobs.lua -- job skill caps + primaryWeapons  
&ensp;SkillchainCore.lua -- filtering and routing logic  

Notes:  
&ensp;This is adjusted for HorizonXI. No plans to support retail.  
&ensp;Superscript 1/2 denote quested/relic weaponskills  
&ensp;Default title font is Times New Roman  
&ensp;Output is limited to 150 lines; excess results are trimmed with a notice asking to use filters  
