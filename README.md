<img align="right" src="https://github.com/user-attachments/assets/9e77ac04-f4b2-45cb-ae6d-ef319ed87ef4">  
  
Skillchain Calculator v1.10  
  
Display skillchains possible given an opening weapon type and closing weapon type.  

Usage:  
/scc weapon1 weapon2 [level] [both]  
&ensp;Weapon Types: h2h, dagger, sword, gs, axe, ga, scythe,  
&ensp;&ensp;polearm, katana, gkt, club, staff, archery, mm, smn  
&ensp;[level] is optional value that filters skillchain tier  
&ensp;&ensp;i.e. 2 only shows tier 2 and 3 skillchains.  
&ensp;&ensp;1 or empty is default all.  
&ensp;[both] is optional keyword to calculate skillchains in both directions  
&ensp;Optional arguments have no order
  
Example: -- Results of Picture  
&ensp;/scc katana h2h both 2  
  
Commands:  
&ensp;/scc help -- to see all commands  
&ensp;/scc setx # -- set x anchor  
&ensp;/scc sety # -- set y anchor  
&ensp;/scc clear -- clear out window  
&ensp;/scc debug -- enable debugging  
  
Files:  
&ensp;skillchaincalc.lua -- main addon  
&ensp;skills.lua -- weaponskill data and colors  
  
Notes:  
&ensp;This is adjusted for HorizonXI. No plans to support for retail.  
&ensp;Superscript 1/2 denote quested/relic weaponskills  
&ensp;Image uses font Jupiter Pro for Skillchain title  
&ensp;Default title font is Times New Roman  

