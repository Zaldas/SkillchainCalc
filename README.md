<img align="right" src="https://github.com/user-attachments/assets/a52fafe4-e73e-45f6-b9c7-40ec614a3ffe">  
Skillchain Calculator  
  
Display skillchains possible given an opening weapon type and closing weapon type.  

Usage:  
/scc <weapon1> <weapon2> [level]  
&ensp;WeaponTypes: h2h, dagger, sword, gs, axe,  
&ensp;&ensp;ga, scythe, polearm, katana, gkt, club,  
&ensp;&ensp;staff, archery, mm, smn  
&ensp;[level] is optional value that filters skillchain tier  
&ensp;i.e. 2 only shows tier 2 and 3 skillchains.  
&ensp;1 or empty is default all.  
  
Example: -- Results of Picture  
&ensp;/scc katana h2h  
  
Commands:  
&ensp;/scc help -- to see all commands  
&ensp;/scc setx # -- set x anchor  
&ensp;/scc sety # -- set y anchor  
&ensp;/scc clear -- clear out window  
&ensp;/scc debug -- enable debugging  
  
Files:  
&ensp;skillchaincalc.lua -- main addon  
&ensp;skills.lua -- weaponskill data and colors  
  
This is adjusted for HorizonXI.  
No plans to support for retail.  

