/*
*	           active
*
*						
*			  	  
*/

#include <amxmodx>
#include <amxmisc>
#include <xs>
#include <fakemeta>

#define PLUGIN "Silah Olusumu"
#define VERSION "0.5"
#define AUTHOR "GordonFreeman"

new const wpnames[][]={
	"nothing",
	"weapon_crowbar",
	"weapon_9mmhandgun",
	"weapon_357",
	"weapon_9mmAR",
	"weapon_shotgun",
	"weapon_crossbow",
	"weapon_rpg",
	"weapon_gauss",
	"weapon_egon",
	"weapon_hornetgun",
	"weapon_handgrenade",
	"weapon_satchel",
	"weapon_tripmine",
	"weapon_snark"
}

new const ammoclip[][]={
	"nothing",
	"ammo_9mmAR",
	"ammo_357",
	"ammo_buckshot",
	"ammo_crossbow",
	"ammo_rpgclip",
	"ammo_gaussclip",
	"item_healthkit",
	"item_battery",
	"item_longjump"
}

new fwd,crent,move,idedit

// Custome Entity Storage
new Array:g_wpnames
new Array:g_origins
new Array:g_angles

// Modifed Entity Storage
new Array:g_move
new Array:g_mclass

// Deleted Entity Storage
new Array:g_del
new Array:g_dclass

new path[256],bool:b,bool:f,bool:m//,bool:s

public plugin_precache(){
	precache_model("models/w_medkit.mdl")
	precache_sound("items/smallmedkit1.wav")
}

public plugin_init() {
	register_plugin("Silah Olusumu","0.4","[CSD]")
	
	register_clcmd("wp_spawn","start_edit",ADMIN_CFG," - start entity editor")
}

new Float:strmv[3]

public plugin_cfg(){
	g_wpnames = ArrayCreate(32)
	g_origins = ArrayCreate(3)
	g_angles = ArrayCreate(3)
	
	g_move = ArrayCreate(10)
	g_mclass = ArrayCreate(32)
	
	g_del = ArrayCreate(3)
	g_dclass = ArrayCreate(32)
	
	get_localinfo("amxx_configsdir",path,255)
	formatex(path,255,"%s/silah_olusumu/",path)
	
	if(!dir_exists(path))
		mkdir(path)
	
	
	new map[96]
	get_mapname(map,31)
	
	formatex(path,255,"%s%s.ini",path,map)
	
	new file = fopen(path,"rt")
	
	new classname[32],sorig[20],sanlge[20]
	new Float:origin[3],Float:angle[3]
	
	new i,z,su
	
	if(file){
		while(!feof(file)){
			fgets(file,map,95)
			trim(map)
			
			if (map[0]&&!equali(map,";",1)){
				if(equali(map,"[eklendi]")){
					su=1
					continue
				}else if(equali(map,"[tasindi]")){
					su=2
					continue
				}else if(equali(map,"[silindi]")){
					su=3
					continue
				}
				
				if(su==1){
					parse(map,classname,31,sorig,19,sanlge,19)
					
					ParseVec(sorig,19,origin)
					ParseVec(sanlge,19,angle)
					
					ArrayPushString(g_wpnames,classname)
					ArrayPushArray(g_origins,origin)
					ArrayPushArray(g_angles,angle)
					
					new ent = engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,classname))
					
					if(!ent){
						log_error(AMX_ERR_GENERAL,"adli %s oge olusturulamadi. Lutfen dogru bir sekilde tekrar deneyin.",classname)
						
						return
					}
					
					dllfunc(DLLFunc_Spawn,ent)
					
					set_pev(ent,pev_origin,origin)
					set_pev(ent,pev_angles,angle)
					set_pev(ent,pev_iuser3,1)
					set_pev(ent,pev_iuser4,i)
					
					i++
				}else if(su==2){
					new sorg[20],Float:endorg[3],Float:allorg[9]
					
					parse(map,classname,31,sorig,19,sorg,19,sanlge,19)
					
					ParseVec(sorig,19,origin)
					ParseVec(sorg,19,endorg)
					ParseVec(sanlge,19,angle)
					
					allorg[0] = origin[0]
					allorg[1] = origin[1]
					allorg[2] = origin[2]
					allorg[3] = endorg[0]
					allorg[4] = endorg[1]
					allorg[5] = endorg[2]
					allorg[6] = angle[0]
					allorg[7] = angle[1]
					allorg[8] = angle[2]
					
					ArrayPushArray(g_move,allorg)
					ArrayPushString(g_mclass,classname)
					
					new ent = find_ent_at_origin(classname,origin)
					
					if(!ent){
						log_error(AMX_ERR_NOTFOUND,"bulunamadi %s yaninda %.0f %.0f %.0f",classname,origin[0],origin[1],origin[2])
						
						return
					}
					
					
					set_pev(ent,pev_origin,endorg)
					set_pev(ent,pev_angles,angle)
					set_pev(ent,pev_iuser3,2)
					set_pev(ent,pev_iuser4,z)
					
					z++
				}else if(su==3){
					parse(map,classname,31,sorig,19)
					
					ParseVec(sorig,19,origin)
					
					ArrayPushArray(g_del,origin)
					ArrayPushString(g_dclass,classname)
					
					new ent = find_ent_at_origin(classname,origin)
					
					if(!ent){
						log_error(AMX_ERR_NOTFOUND,"bulunamadi %s yaninda %.0f %.0f %.0f",classname,origin[0],origin[1],origin[2])
						
						return
					}
					
					engfunc(EngFunc_RemoveEntity,ent)
				}
			}
		}
		
		fclose(file)
	}
}

public plugin_end(){	
	new classname[32],Float:origin[3],Float:angle[3],Float:sorg[9]
	
	new map[32]
	get_mapname(map,31)
	
	new file = fopen(path,"w+")
	if(!file) return
	
	if(f){
		fclose(file)
		delete_file(path)
		
		return
	}
	
	if(!ArraySize(g_wpnames)&&!ArraySize(g_move)&&!ArraySize(g_del)){
		fclose(file)
		delete_file(path)
		
		return
	}
	
	fprintf(file,"; Silah Olusumu^n")
	fprintf(file,"; %s - harita config dosyasi n",map)
	fprintf(file,"^n")
	
	if(ArraySize(g_wpnames)){
		fprintf(file,"^n;Item        origin (xyz)        angles (pyr)^n")
		fprintf(file,"[addent]^n^n")
		for(new i;i<ArraySize(g_wpnames);++i){
			ArrayGetString(g_wpnames,i,classname,31)
			
			if(equal(classname,"yandex"))
				continue
				
			fprintf(file,"%s ",classname)
			
			ArrayGetArray(g_origins,i,origin)
			ArrayGetArray(g_angles,i,angle)
			
			fprintf(file,"^"%.0f %.0f %.0f^" ^"%.0f %.0f %.0f^"^n",origin[0],origin[1],origin[2],angle[0],angle[1],angle[2])
		}
		
		fprintf(file,"^n")
		
		ArrayDestroy(g_wpnames)
		ArrayDestroy(g_origins)
		ArrayDestroy(g_angles)
	}
	
	if(ArraySize(g_move)){
		fprintf(file,"^n;Item        moved from (xyz)        moved to (xyz)        Angles (pyr)^n")
		fprintf(file,"[tasindi]^n^n")
		
		for(new i;i<ArraySize(g_move);++i){
			ArrayGetString(g_mclass,i,classname,31)
			
			if(equal(classname,"yandex"))
				continue
				
			fprintf(file,"%s ",classname)
			
			ArrayGetArray(g_move,i,sorg)
			
			fprintf(file,"^"%.0f %.0f %.0f^" ^"%.0f %.0f %.0f^" ^"%.0f %.0f %.0f^"^n",sorg[0],sorg[1],sorg[2],sorg[3],sorg[4],sorg[5],sorg[6],sorg[7],sorg[8])
		}
		
		fprintf(file,"^n")
		
		ArrayDestroy(g_move)
		ArrayDestroy(g_mclass)
	}
	
	if(ArraySize(g_del)){
		if(!b){
			fprintf(file,"^n;Item        deleted from (xyz)^n")
			fprintf(file,"[silindi]^n^n")
		
			for(new i;i<ArraySize(g_del);++i){
				ArrayGetString(g_dclass,i,classname,31)
				
				if(equal(classname,"yandex"))
					continue
					
				fprintf(file,"%s ",classname)
			
				ArrayGetArray(g_del,i,origin)
			
				fprintf(file,"^"%.0f %.0f %.0f^"^n",origin[0],origin[1],origin[2])
			}
		
			fprintf(file,"^n")
		}
		
		ArrayDestroy(g_del)
		ArrayDestroy(g_dclass)
	}
	
	fprintf(file,"^n")
	fprintf(file,";^n")
	fprintf(file,"; www.csduragi.com")
	
	fclose(file)
	
	return
}

public start_edit(id,level,cid){
	if(!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED
		
	if(idedit){
		new name[32]
		get_user_name(idedit,name,31)
		
		set_hudmessage(255, 127, 0, -1.0, 0.60, 0, 6.0, 5.0)
		show_hudmessage(id, "Limitleme is %s^ndaha fazlasina izin vermiyor",name)
		
		return PLUGIN_HANDLED
	}
	
	idedit=id
	start_menu(id)
	
	return PLUGIN_HANDLED	
}

public start_menu(id){
	new menu = menu_create("Silah Olusumu","fw_MenuHandler")
	
	menu_additem(menu,"Silah spawnla","s1",0)
	menu_additem(menu,"Esya spawnla^n","s2",0)
	menu_additem(menu,"Entity duzenle^n","s3",0)
	//menu_additem(menu,"Spawn duzenlemesi^n","s6",0)
	menu_additem(menu,"silinen herseyi geri getir","s4",0)
	menu_additem(menu,"Tamamen RESETLE","s5")
	
	m=false
	
	new data[1]
	data[0] = id
	
	set_task(0.1,"reshow",31337,data,1,"b",1)
	
	menu_display(id,menu)
}

public weapon_menu(id){
	new menu = menu_create("Silah spawnla","fw_MenuHandler")
	
	menu_additem(menu,"Crowbar^n","w1",0)
	menu_additem(menu,"Glock","w2",0)
	menu_additem(menu,"Colth .357^n","w3",0)
	menu_additem(menu,"Mp5","w4",0)
	menu_additem(menu,"Shotgun","w5",0)
	menu_additem(menu,"Crossbow^n","w6",0)
	menu_additem(menu,"RPG","w7",0)
	menu_additem(menu,"Tau Cannon","w8",0)
	menu_additem(menu,"Glueon Gun","w9",0)
	menu_additem(menu,"Hornet Gun^n","w10",0)
	menu_additem(menu,"Grenade","w11",0)
	menu_additem(menu,"Satchel","w12",0)
	menu_additem(menu,"Tripmine","w13",0)
	menu_additem(menu,"Snark^n","w14",0)
	
	m=true
	
	menu_display(id,menu)
}

public ammo_menu(id){
	new menu = menu_create("Esya spawnla","fw_MenuHandler")
	
	menu_additem(menu,"9mmclip","a1",0)
	menu_additem(menu,".357","a2",0)
	menu_additem(menu,"Shotgun","a3",0)
	menu_additem(menu,"Crossbow^n","a4",0)
	menu_additem(menu,"RPG Rocket","a5",0)
	menu_additem(menu,"Uranium^n","a6",0)
	menu_additem(menu,"Healthkit","a7",0)
	menu_additem(menu,"Battery","a8",0)
	menu_additem(menu,"LongJump^n","a9",0)
	
	m=true
	
	menu_display(id,menu)
}

public edit_menu(id){
	if(!fwd)
		fwd = register_forward(FM_PlayerPreThink,"fw_EditPreThink")
	else{
		unregister_forward(FM_PlayerPreThink,fwd)
		fwd = register_forward(FM_PlayerPreThink,"fw_EditPreThink")
	}
	
	new menu = menu_create("Duzenleyici 0.1","fw_MenuHandler")
	menu_additem(menu,"Origins/Angles^n","x1")
	menu_additem(menu,"Esya sil","x2")
	
	m=true
	
	menu_display(id, menu, 0)
}

public fw_MenuHandler(id,menu,item){
	if(item==MENU_EXIT){
		if(task_exists(31337))
			remove_task(31337)
	
		if(m)
			start_menu(id)
		else{
			menu_destroy(menu)
		
			idedit=0
		}
		
		if(fwd)
			unregister_forward(FM_PlayerPreThink,fwd)
			
		fwd = 0
		
		if(move){
			set_pev(move,pev_origin,strmv)
			res_ren(move)
			move = 0
		}
		
		if(crent>0){
			engfunc(EngFunc_RemoveEntity,crent)
			crent = 0
		}
		
		return PLUGIN_HANDLED
	}
	
	new data[6],name[64]
	new access,callback
	menu_item_getinfo(menu,item,access,data,5,name,63,callback)
	
	new key = str_to_num(data[1])
	
	switch(data[0]){
		case 's':{
			switch(key){
				case 1:	weapon_menu(id)
				case 2: ammo_menu(id)
				case 3: edit_menu(id)
				case 4:{
					ArrayClear(g_del)
					ArrayClear(g_dclass)
					b=true
					
					set_hudmessage(255, 85, 0, -1.0, -1.0, 0, 6.0, 12.0)
					show_hudmessage(id, "Geri alindi!")
					
					start_menu(id)
				}
				case 5:{
					ArrayClear(g_wpnames)
					ArrayClear(g_origins)
					ArrayClear(g_angles)
					ArrayClear(g_move)
					ArrayClear(g_mclass)
					ArrayClear(g_del)
					ArrayClear(g_dclass)
					
					f=true
					
					set_hudmessage(255, 85, 0, -1.0, -1.0, 0, 6.0, 12.0)
					show_hudmessage(id, "RESETLENDI!^nLutfen sunucuyu yeniden baslatin")
					
					start_menu(id)
				}
				/*case 6:{
					spawn_editor(id)
				}*/
			}
		}
		case 'w': addent(id,key,1)
			case 'a': addent(id,key,2)
			case 'z':{
			switch(key){
				case 1: spawnit(id)
				case 2:{
					angles(id)
					addentmenu(id)
				}
				case 3:{
					engfunc(EngFunc_RemoveEntity,crent)
					crent = 0
					
					if(fwd)
						unregister_forward(FM_PlayerPreThink,fwd)
					
					weapon_menu(id)
				}
			}
		}
		case 'x':{
			switch(key){
				case 1:{
					if(!move){
						move = get_aiment(id)
						if(move){
							pev(move,pev_origin,strmv)
							
							set_task(0.2,"render",move)
							
							set_pev(move,pev_movetype,MOVETYPE_FLY)
							set_pev(move,pev_nextthink,0.0)
							set_pev(move,pev_solid,SOLID_NOT)
							
							move_menu(id)
						}else{
							set_hudmessage(255, 0, 0, -1.0, -1.0, 0, 6.0, 12.0)
							show_hudmessage(id, "hicbir sey kurulmadi")
							
							edit_menu(id)
						}
					}else{
						new classname[32],Float:temp[3],Float:endmv[3]
						pev(move,pev_angles,temp)
						
						pev(move,pev_origin,endmv)
						pev(move,pev_classname,classname,31)
							
						set_pev(move,pev_renderfx,kRenderFxDistort)
						set_pev(move,pev_rendermode,kRenderTransAdd)
						set_pev(move,pev_renderamt,128.0)
							
						switch(pev(move,pev_iuser3)){
							case 0:{
								new Float:org[9]
						
								org[0] = strmv[0]
								org[1] = strmv[1]
								org[2] = strmv[2]
								org[3] = endmv[0]
								org[4] = endmv[1]
								org[5] = endmv[2]
								org[6] = temp[0]
								org[7] = temp[1]
								org[8] = temp[2]
							
								ArrayPushString(g_mclass,classname)
								ArrayPushArray(g_move,org)
							}
							case 1:{
								ArraySetArray(g_origins,pev(move,pev_iuser4),endmv)
								ArraySetArray(g_angles,pev(move,pev_iuser4),temp)
							}case 2:{
								new Float:org[9]
								ArrayGetArray(g_move,pev(move,pev_iuser4),org)
								
								org[3] = endmv[0]
								org[4] = endmv[1]
								org[5] = endmv[2]
								org[6] = temp[0]
								org[7] = temp[1]
								org[8] = temp[2]
	
								
								ArraySetArray(g_move,pev(move,pev_iuser4),org)
							}
						}
							
						move = 0
						edit_menu(id)
					}
				}
				case 2:{
					new delent = get_aiment(id)
					
					if(delent){
						new Float:org[3],classname[32]
						
						pev(delent,pev_classname,classname,31)
						pev(delent,pev_origin,org)
						
						switch(pev(delent,pev_iuser3)){
							case 0:{
								ArrayPushString(g_dclass,classname)
								ArrayPushArray(g_del,org)
							}
							case 1:{
								ArraySetString(g_wpnames,pev(delent,pev_iuser4),"yandex")
							}
							case 2:{
								new Float:lola[9]
								ArrayGetArray(g_move,pev(delent,pev_iuser4),lola)
								
								org[0]=lola[0]
								org[1]=lola[1]
								org[2]=lola[2]
								
								ArraySetString(g_mclass,pev(delent,pev_iuser4),"yandex")
								
								pev(delent,pev_classname,classname,31)
								
								ArrayPushString(g_dclass,classname)
								ArrayPushArray(g_del,org)
							}
						}
						
						engfunc(EngFunc_RemoveEntity,delent)
						
						set_hudmessage(255, 170, 0, -1.0, 0.60, 0, 6.0, 12.0)
						show_hudmessage(id, "%s haritadan silindi",classname)
						
						edit_menu(id)
					}else{
						set_hudmessage(255, 0, 0, -1.0, -1.0, 0, 6.0, 12.0)
						show_hudmessage(id, "Birsey kurulmadi")
						
						edit_menu(id)
					}
				}
				case 3:{
					start_menu(id)
				}
			}
		}
		case 'm':{
			switch(key){
				case 1:{
					if(move){
						new Float:angle[3]
						pev(move,pev_angles,angle)
	
						angle[1]+=15.0
		
						if(angle[1]>=360.0)
							angle[1]=0.0
	
						set_pev(move,pev_angles,angle)
					
						move_menu(id)
					}else{
						set_hudmessage(255, 0, 0, -1.0, 0.60, 0, 6.0, 12.0)
						show_hudmessage(id, "Hareketli oge kurulmadi")
						edit_menu(id)
					}

				}
				case 2:{
					if(move){					
						set_pev(move,pev_origin,strmv)
						set_pev(move,pev_movetype,MOVETYPE_NONE)
						set_pev(move,pev_nextthink,1.0)
						set_pev(move,pev_solid,SOLID_TRIGGER)
						set_pev(move,pev_renderfx,kRenderFxNone)
						set_pev(move,pev_rendermode,kRenderNormal)
						set_pev(move,pev_renderamt,0.0)
						move = 0
						
						edit_menu(id)
					}else{
						set_hudmessage(255, 0, 0, -1.0, 0.60, 0, 6.0, 12.0)
						show_hudmessage(id, "Hareketli oge kurulmadi")
						edit_menu(id)
					}
				}
			}
		}
	}
	
	return PLUGIN_CONTINUE
}

public move_menu(id){
	new menu  =menu_create("Origins/Angles Menu","fw_MenuHandler")
	
	menu_additem(menu,"Buraya tasi","x1",0)
	menu_additem(menu,"Angles","m1",0)
	menu_additem(menu,"Cancel","m2",0)
	
	menu_display(id,menu)
}

public addent(id,entid,type){
	if(fwd||crent){
		engfunc(EngFunc_RemoveEntity,crent)
		crent = 0
		unregister_forward(FM_PlayerPreThink,fwd)
	}
	
	if(type==1)
		crent = engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,wpnames[entid]))
	else if(type==2)
		crent = engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,ammoclip[entid]))
	
	set_pev(crent,pev_renderfx,kRenderFxDistort)
	set_pev(crent,pev_rendermode,kRenderTransAdd)
	set_pev(crent,pev_renderamt,128.0)
	
	dllfunc(DLLFunc_Spawn,crent)
	
	set_pev(crent,pev_movetype,MOVETYPE_FLY)
	set_pev(crent,pev_nextthink,0.0)
	set_pev(crent,pev_solid,SOLID_NOT)
	set_pev(crent,pev_iuser1,entid)
	set_pev(crent,pev_iuser2,type)
	set_pev(crent,pev_iuser3,1)
	
	fwd = register_forward(FM_PlayerPreThink,"fw_PlayerPreThink")
	
	addentmenu(id)
}

public addentmenu(id){
	new title[32]
	pev(crent,pev_classname,title,31)
	
	replace_all(title,32,"weapon_","")
	replace_all(title,32,"ammo_","")
	replace_all(title,32,"item_","")
	ucfirst(title)
	
	format(title,31,"Spawn %s",title)
	new menu = menu_create(title,"fw_MenuHandler")
	
	menu_additem(menu,"Spawnla","z1")
	menu_additem(menu,"Angle degistir^n","z2")
	menu_additem(menu,"Ekleneni iptal et","z3")
	
	menu_display(id,menu)
}

public angles(id){
	if(!crent){
		set_hudmessage(255, 0, 0, -1.0, 0.60, 0, 6.0, 12.0)
		show_hudmessage(id, "Change degistirmesi basarisiz oldu, varlik secilmedi")
		
		if(fwd)
			unregister_forward(FM_PlayerPreThink,fwd)
		
		return
	}
	
	new Float:angle[3]
	pev(crent,pev_angles,angle)
	
	angle[1]+=15.0
	
	if(angle[1]>=360.0)
		angle[1]=0.0
	
	set_pev(crent,pev_angles,angle)
}

public spawnit(id){
	if(!crent){
		set_hudmessage(255, 0, 0, -1.0, 0.60, 0, 6.0, 12.0)
		show_hudmessage(id, "Ekleme basarisiz oldu, varlik secilmedi")
		
		if(fwd)
			unregister_forward(FM_PlayerPreThink,fwd)
		
		return
	}
	
	
	new Float:origin[3],Float:angle[3],classname[32]
	pev(crent,pev_origin,origin)
	pev(crent,pev_classname,classname,31)
	pev(crent,pev_angles,angle)
	
	set_hudmessage(255, 170, 0, -1.0, 0.60, 0, 6.0, 12.0)
	show_hudmessage(id, "Spawn pozisyonu eklendi^n[%.2f %.2f %.2f]",origin[0],origin[1],origin[2])
	
	new type = pev(crent,pev_iuser2)
	
	new tp = engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,classname))
	
	set_pev(tp,pev_renderfx,kRenderFxDistort)
	set_pev(tp,pev_rendermode,kRenderTransAdd)
	set_pev(tp,pev_renderamt,128.0)
	
	dllfunc(DLLFunc_Spawn,tp)
	
	set_pev(tp,pev_movetype,MOVETYPE_FLY)
	set_pev(tp,pev_nextthink,0.0)
	set_pev(tp,pev_solid,SOLID_NOT)
	
	origin[2]+=5.0
	
	set_pev(tp,pev_origin,origin)
	set_pev(tp,pev_angles,angle)
	
	set_pev(tp,pev_iuser3,1)
	
	engfunc(EngFunc_RemoveEntity,crent)
	crent = 0
	
	ArrayPushString(g_wpnames,classname)
	ArrayPushArray(g_origins,origin)
	ArrayPushArray(g_angles,angle)
	
	if(fwd)
		unregister_forward(FM_PlayerPreThink,fwd)
	
	if(type==1)
		weapon_menu(id)
	else if(type==2)
		ammo_menu(id)
}

/*public spawn_editor(id){
	server_print("[C] Spawn duzenleyici arandi %d",id)
	
	new ent,Float:origin[3]
	
	while((ent = engfunc(EngFunc_FindEntityByString,ent,"classname","info_player_deathmatch"))){
		pev(ent,pev_origin,origin)
		
		server_print("[%d] -> Su koordinatta kurulu %.0f %.0f %.0f",ent,origin[0],origin[1],origin[2])
		
		new temp = engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,"info_target"))
		
		set_pev(temp,pev_classname,"spawnpoint_avatar")
		set_pev(temp,pev_origin,origin)
	
		pev(ent,pev_angles,origin)
		set_pev(temp,pev_angles,origin)
		
		set_pev(temp,pev_solid,SOLID_BBOX)
		engfunc(EngFunc_SetSize, temp, Float:{-20.0, -20.0, -20.0} , Float:{20.0, 20.0, 20.0})
		
		engfunc(EngFunc_SetModel,temp,"models/player.mdl")
	}
}*/


public fw_PlayerPreThink(id){
	if(!crent){
		unregister_forward(FM_PlayerPreThink,fwd)
		return FMRES_HANDLED
	}
	
	if(idedit!=id)
		return FMRES_HANDLED
	
	new orig[3],Float:origin[3]
	get_user_origin(id,orig,3)
	
	origin[0] = float(orig[0])
	origin[1] = float(orig[1])
	origin[2] = float(orig[2])
	
	set_pev(crent,pev_origin,origin)
	
	return FMRES_IGNORED
}

public fw_EditPreThink(id){
	if(idedit!=id)
		return FMRES_IGNORED
	
	if(move){
		new orig[3],Float:origin[3]
		get_user_origin(id,orig,3)
		
		origin[0] = float(orig[0])
		origin[1] = float(orig[1])
		origin[2] = float(orig[2])
		
		set_pev(move,pev_origin,origin)
		
		set_hudmessage(255, 255, 0, 0.01, 0.14, 0, 6.0, 0.1,_,_,1)
		show_hudmessage(id,"Varlik hareketi devam ediyor^nSuanki Origins: [%.1f] [%.1f] [%.1f]",origin[0],origin[1],origin[2])
		
		return FMRES_IGNORED
	}
	
	new target = get_aiment(id)
	
	new classname[32],Float:origin[3],Float:angle[3]
	
	pev(target,pev_classname,classname,31)
	pev(target,pev_origin,origin)
	pev(target,pev_angles,angle)
	
	set_hudmessage(128, 255, 0, 0.01, 0.14, 0, 6.0, 0.1,_,_,1)
	show_hudmessage(id, "Varklik Duzenleyicisi^nID: %d [%s]^nOrigin: [%.1f] [%.1f] [%.1f]^nAngles: [%.1f] [%.1f] [%.1f]",target,classname,origin[0],origin[1],origin[2],angle[0],angle[1],angle[2])
	
	if(pev(target,pev_iuser3)){
		new olo[20]
		switch(pev(target,pev_iuser3)){
			case 1:formatex(olo,19,"Custome Entity")
			case 2:formatex(olo,19,"Moved Entity")
		}
		set_hudmessage(128, 255, 0, 0.01, 0.22, 0, 6.0, 0.1, _, _, 2)
		show_hudmessage(id, "FrameWork Varligi. ID: %d^n%s",pev(target,pev_iuser4),olo)
	}
	
	set_ren(target)
	
	return FMRES_IGNORED
}

public render(ent){
	set_pev(ent,pev_renderfx,kRenderFxGlowShell)
	set_pev(ent,pev_rendermode,kRenderNormal)
	set_pev(ent,pev_rendercolor,{255.0,255.0,0.0})
	set_pev(ent,pev_renderamt,64.0)
}

public set_ren(ent){
	if(!pev_valid(ent))
		return PLUGIN_HANDLED
	set_pev(ent,pev_renderfx,kRenderFxGlowShell)
	set_pev(ent,pev_rendermode,kRenderNormal)
	set_pev(ent,pev_rendercolor,{128.0,255.0,0.0})
	set_pev(ent,pev_renderamt,64.0)
	
	set_task(0.01,"res_ren",ent)
	
	return PLUGIN_CONTINUE
}

public res_ren(ent){
	if(!pev_valid(ent))
		return PLUGIN_HANDLED
		
	set_pev(ent,pev_renderfx,kRenderFxNone)
	set_pev(ent,pev_rendermode,kRenderNormal)
	set_pev(ent,pev_rendercolor,{0.0,0.0,0.0})
	set_pev(ent,pev_renderamt,0.0)
	
	return PLUGIN_CONTINUE
}

public reshow(data[1]){
	new id = data[0]
	new jaja,jaja2,page
	
	player_menu_info(id,jaja,jaja2,page)
	
	if(jaja2<0){
		if(task_exists(31337))
			remove_task(31337)
		
		if(fwd)
			unregister_forward(FM_PlayerPreThink,fwd)
			
		idedit = 0
		
		if(crent){
			engfunc(EngFunc_RemoveEntity,crent)
			crent = 0
		}
		
		if(move){
			set_pev(move,pev_origin,strmv)
			res_ren(move)
			move = 0
		}
	}
}

// Parse Vector Function by KORD_12.7
ParseVec(szString[], iStringLen, Float: Vector[3]){
	new i;
	new szTemp[32];
	
	arrayset(_:Vector, 0, 3);
	
	while (szString[0] != 0 && strtok(szString, szTemp, charsmax(szTemp), szString, iStringLen, ' ', 1))
	{
		Vector[i++] = str_to_float(szTemp);
	}
}

stock traceline( const Float:vStart[3], const Float:vEnd[3], const pIgnore, Float:vHitPos[3] ){
	engfunc( EngFunc_TraceLine, vStart, vEnd, 0, pIgnore, 0 )
	get_tr2( 0, TR_vecEndPos, vHitPos )
	return get_tr2( 0, TR_pHit )
}

stock get_view_pos( const id, Float:vViewPos[3] ){
	new Float:vOfs[3]
	pev( id, pev_origin, vViewPos )
	pev( id, pev_view_ofs, vOfs )		
	
	vViewPos[0] += vOfs[0]
	vViewPos[1] += vOfs[1]
	vViewPos[2] += vOfs[2]
}

stock Float:vel_by_aim( id, speed = 1 ){
	new Float:v1[3], Float:vBlah[3]
	pev( id, pev_v_angle, v1 )
	engfunc( EngFunc_AngleVectors, v1, v1, vBlah, vBlah )
	
	v1[0] *= speed
	v1[1] *= speed
	v1[2] *= speed
	
	return v1
}

stock get_aiment(id){
	new target
	new Float:orig[3], Float:ret[3]
	get_view_pos( id, orig )
	ret = vel_by_aim( id, 9999 )
	
	ret[0] += orig[0]
	ret[1] += orig[1]
	ret[2] += orig[2]
	
	target = traceline( orig, ret, id, ret )
	
	new movetype
	if( target && pev_valid( target ) )
	{
		movetype = pev( target, pev_movetype )
		if( !( movetype == MOVETYPE_WALK || movetype == MOVETYPE_STEP || movetype == MOVETYPE_TOSS ) )
			return 0
	}
	else
	{
		target = 0
		new ent = engfunc( EngFunc_FindEntityInSphere, -1, ret, 10.0 )
		while( !target && ent > 0 )
		{
			movetype = pev( ent, pev_movetype )
			if( ( movetype == MOVETYPE_WALK || movetype == MOVETYPE_STEP || movetype == MOVETYPE_TOSS )
			&& ent != id  )
			target = ent
			ent = engfunc( EngFunc_FindEntityInSphere, ent, ret, 10.0 )
		}
	}

	if(0<target<=get_maxplayers())
		return 0
	
	new classname[32]
	pev(target,pev_classname,classname,31)
	
	if(equal(classname,"weaponbox"))
		return 0
	
	return target
}

stock find_ent_at_origin(classname[],Float:origin[3]){
	new ent = engfunc(EngFunc_FindEntityByString,ent,"classname",classname)
	
	new Float:corg[3]
	pev(ent,pev_origin,corg)
	
	while(origin[0]!=corg[0]||origin[1]!=corg[1]&&ent){
		ent = engfunc(EngFunc_FindEntityByString,ent,"classname",classname)
		pev(ent,pev_origin,corg)
	}
	
	return ent
}
