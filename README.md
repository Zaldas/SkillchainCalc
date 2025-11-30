<img align="right" src="https://github.com/user-attachments/assets/cd05ba75-dd09-444a-a0ea-aaf4b4eecd20">  
  
Skillchain Calculator
  
Display skillchains possible given an opening weapon type and closing weapon type.  

Usage:
/scc weapon1|job1 weapon2|job2 [level] [both]
&ensp;Weapon Types: h2h, dagger, sword, gs, axe, ga, scythe,
&ensp;&ensp;polearm, katana, gkt, club, staff, archery, mm, smn
&ensp;Jobs: defined in jobs.lua (e.g., drk -> scythe, gs)
&ensp;&ensp;Set optional max_tier per weapon in jobs.lua to filter out weapon skills a job cannot use.
&ensp;[level] is optional value that filters skillchain tier
&ensp;&ensp;i.e. 2 only shows tier 2 and 3 skillchains.
&ensp;&ensp;1 or empty is default all.
&ensp;[both] is optional keyword to calculate skillchains in both directions  
&ensp;Optional arguments have no order  
&ensp;Optional arguments will use default values if not explicitly stated    
  
Example: -- Results of Picture  
&ensp;/scc katana h2h both 2  
  
Commands:  
&ensp;/scc help -- to see all commands  
&ensp;/scc setx # -- set x anchor  
&ensp;/scc sety # -- set y anchor  
&ensp;/scc setlevel # -- set default level filter; 1, 2, or 3  
&ensp;/scc setboth bool -- set default for 'both' param; true or false  
&ensp;/scc clear -- clear out window  
&ensp;/scc debug -- enable debugging  
&ensp;/scc status -- show default filter status  
  
Files:
&ensp;skillchaincalc.lua -- main addon
&ensp;skills.lua -- weaponskill data and colors
&ensp;jobs.lua -- job -> weapon mapping configuration
  
Notes:  
&ensp;This is adjusted for HorizonXI. No plans to support for retail.  
&ensp;Superscript 1/2 denote quested/relic weaponskills  
&ensp;Image uses font Jupiter Pro for Skillchain title  
&ensp;Default title font is Times New Roman  

