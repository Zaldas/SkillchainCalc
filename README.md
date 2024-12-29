<img align="right" src="https://github.com/user-attachments/assets/f3affcca-f1fc-4ee7-a6f4-fd09d9fadc05">

Display skillchains possible given an opening weapon type and closing weapon type.  

Usage:  
/scc <weapon1> <weapon2> [level]  
&ensp;WeaponTypes: h2h, dagger, sword, gs, axe, ga, scythe, polearm, katana, gkt, club, staff, archery, mm, smn  
&ensp;[level] is optional value that filters skillchain tier  
&ensp;i.e. 2 only shows tier 2 and 3 skillchains. 1 or empty is default all.  
  
Example: -- Results of Picture  
&ensp;/scc katana h2h 2
  
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

