# Skillchain Calculator   
   
<img align="right" alt="image" width="500" height="1575" alt="skillchaincalcaddon" src="https://github.com/user-attachments/assets/d37da06e-5aff-409b-84dd-dd5a2d0ca008" />  
   
Display skillchains possible given jobs and optional weapons, level, skillchain, or element!!  
Now with ImGui interface to input parameters!!!   
  
### GUI Interface  
&ensp;Three Tabs:  
&ensp;&ensp;Calculate - Has the Jobs and Weapons  
&ensp;&ensp;&ensp;Character Level - Optional custom level filter (when enabled in Filters)  
&ensp;&ensp;Filters - Filters to help narrow and adjust calculation  
&ensp;&ensp;&ensp;Skillchain Element - element that you want to focus on for resulting skllchain  
&ensp;&ensp;&ensp;Skillchain Level - level of skillchain to include  
&ensp;&ensp;&ensp;Advanced Filters:  
&ensp;&ensp;&ensp;&ensp;Custom Character Level - Filters weapon skills by character level and skill caps  
&ensp;&ensp;&ensp;&ensp;Both Directions - Calculates skillchains in both directions of jobs selected  
&ensp;&ensp;&ensp;&ensp;SubJob - Enables the use of Subjobs to define skillchain options  
&ensp;&ensp;Settings - Has the position of results window, and default filter settings  
  
#### Usage:  
&ensp;`/scc` -- opens the GUI interface  
&ensp;`/scc token1 token2 [level] [both] [sc:element] [lvl:#]`  
&ensp;`/scc clear` -- closes addon  
  
### <ins>Tokens can be one of the following:</ins>   
  
#### Weapon Types:  
&ensp;h2h, dagger, sword, gs, axe, ga, scythe,  
&ensp;polearm, katana, gkt, club, staff, archery, mm, smn  
&ensp;Weapons Alias as well: e.g. ga or greataxe work, full list in Skills.lua  
  
#### Jobs:  
&ensp;WAR, MNK, WHM, BLM, RDM, THF, PLD, DRK, BST, BRD,  
&ensp;RNG, SAM, NIN, DRG, SMN  
  
#### Job + Weapon Filters:  
&ensp;Use the syntax `job:weapon` or `job:weapon1,weapon2` to limit WS by weapon type  
&ensp;Can also define subjob: `main/sub:weapon` to include subjob accessible weaponskills  
&ensp;e.g. `/scc thf:sword war:ga,polearm`  
&ensp;e.g. `/scc nin/rng:mm,katana drk/sam`  
  
#### Primary Weapon Auto-Limit:  
&ensp;If a plain job token is used (e.g. `thf`), the job’s `primaryWeapons` list defined in Jobs.lua is used.  
&ensp;Example: `/scc thf war` is internally treated as `/scc thf:dagger war:ga,axe`  
  
*[#]*  
&ensp;Optional number value that filters skillchain tier  
&ensp;2 only shows tier 2 and 3 skillchains  
&ensp;1 or empty shows all  
  
*[both]*  
&ensp;Optional keyword to calculate skillchains in both directions  
  
*[sc:element]*  
&ensp;Optional filter that limits results to skillchains whose burst table contains the given element  
&ensp;e.g. `/scc thf war sc:ice` will show only SCs with Ice as a burst element  
&ensp;Case-insensitive (`sc:ice`, `sc:Ice`, `SC:ICE` etc.)  
  
*[lvl:#]* or *[level:#]*  
&ensp;Optional character level (1-75) for skill-based weapon skill filtering  
&ensp;Filters out weapon skills that require more skill than achievable at the specified level  
&ensp;e.g. `/scc nin sam lvl:50` will exclude weapon skills requiring >153 katana skill for NIN  
&ensp;Aliases: Both `lvl:` and `level:` are supported  
  
#### Examples:  
&ensp;/scc katana h2h both 2  
&ensp;/scc thf war  
&ensp;/scc thf:sword war:ga  
&ensp;/scc thf war sc:ice  
&ensp;/scc nin sam lvl:50  
&ensp;/scc nin/rng:mm,katana drk:ga 2 both  
&ensp;/scc drk pld lvl:60 sc:light both  
  
#### Commands:  
&ensp;/scc -- opens GUI window  
&ensp;/scc help -- show all commands  
&ensp;/scc setx # -- set x anchor  
&ensp;/scc sety # -- set y anchor  
&ensp;/scc setlevel # -- set default level filter (1–3)  
&ensp;/scc setboth true|false -- set default for 'both' param  
&ensp;/scc setsubjob true|false -- set default for enabling subjob in GUI  
&ensp;/scc status -- show default filter status  
&ensp;/scc clear -- clear out windows; close addon  
&ensp;/scc debug -- enable debugging  
  
#### Files:  
&ensp;SkillchainCalc.lua -- main addon  
&ensp;Skills.lua -- weaponskill data and colors  
&ensp;Jobs.lua -- job skill caps + primaryWeapons  
&ensp;SkillRanks.lua -- skill rank progression tables (A+, A-, B+, etc.)  
&ensp;SkillchainCore.lua -- filtering and routing logic  
&ensp;SkillchainGui.lua -- ImGui interface  
&ensp;SkillchainRenderer.lua -- Results window renderer
&ensp;imgui_compat.lua -- ImGui compatability layer <[credit XIUI team](https://github.com/tirem/XIUI)>  
  
#### Notes:  
&ensp;This is adjusted for HorizonXI. No plans to support retail.  
&ensp;Superscript 1/2 denote quested/relic weaponskills  
&ensp;Default title font is Times New Roman  
&ensp;Output is limited to 150 lines; excess results are trimmed with a notice asking to use filters  
  
