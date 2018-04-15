/********************************************************
:Author:	Timothy Halim
:Site:		http://timo.ink
:Email:		mail@timo.ink
:Date:		15 Feb 2016
:Update:	19 May 2016
:notes:		Original idea by Rob Swinburn http://www.scriptspot.com/3ds-max/scripts/object-rename-0
********************************************************/
/*
	Notes:
	Feel free to edit the script.
	Please don't distribute or commercialize it without my permission.
	Please notifyme and put my name on credits if you use part of this script.
*/

RenamerVersion ="16.05.19"

try destroydialog renamer catch()
try destroydialog renamer_help catch()
rollout renamer "Renamer"
(
	groupbox grp_rename "Renamer" pos:[5,5] width:(renamer.width as float -10)
	label lbl_rename "Rename"
	dropdownlist ddl_rename "" width:100 items:#("Object", "Material")
	button btn_help "?" border:off tooltip:"Help"
	button btn_name "Name" width:50 border:off tooltip:"Clear name field"
	dotNetControl txt_name "System.Windows.Forms.TextBox" width:160
	label lbl_result "Result"
	button btn_rename "Rename" width:210 tooltip:"Rename selected Object"
	
	groupbox grp_findreplace "Find and Replace" width:(renamer.width as float -10) 
	button btn_find "Find" width:50 border:off tooltip:"Clear find text field"
	dotNetControl txt_find "System.Windows.Forms.TextBox" width:160 
	button btn_with "Replace" width:50 border:off tooltip:"Clear replace text field"
	dotNetControl txt_with "System.Windows.Forms.TextBox" width:160
	button btn_replace "Replace" width:210 tooltip:"Execute Find and Replace on Selection"
	
	groupbox grp_remove "Remove Character" width:(renamer.width as float -10)
	button btn_rmStart "Remove From Begining" width:150 tooltip:"Remove characters from begining"
	spinner spn_start "" range:[0,1000,0] type:#integer fieldwidth:40 tooltip:"Start Character"
	button btn_rmEnd "Remove From End" width:150 tooltip:"Remove characters from End"
	spinner spn_end "" range:[0,1000,0] type:#integer fieldwidth:40 tooltip:"End Character"
	
	HyperLink hl_email "Mail" across:3 align:#center offset:[0,0] color:(color 200 200 200) hovercolor:(color 255 255 255) visitedcolor:(color 200 200 200) address:"mailto://mail@timo.ink"
	HyperLink hl_web "Website" align:#center offset:[0,0] color:(color 200 200 200) hovercolor:(color 255 255 255) visitedcolor:(color 200 200 200) address:"http://timo.ink"
	HyperLink hl_donate "Donate" align:#center offset:[0,0] color:(color 200 200 200) hovercolor:(color 255 255 255) visitedcolor:(color 200 200 200) address:"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=NS2NFUHX7NCUQ&lc=ID&item_name=Timothy%20Halim&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donate_SM%2egif%3aNonHosted"
	
	local RnDest
	local oname
	
	function fn_init =
	(
		textlist = #(txt_name,txt_find,txt_with)
		for i=1 to textlist.count do (textlist[i].MultiLine = false; textlist[i].text = "")
		lbl_rename.pos = [grp_rename.pos.x+10,grp_rename.pos.y+17]
		ddl_rename.pos = [lbl_rename.pos.x+45,lbl_rename.pos.y-3]
		btn_help.pos = [renamer.width-30,grp_rename.pos.y +13]
		btn_name.pos = [grp_rename.pos.x+5,lbl_rename.pos.y +20] 
		txt_name.pos = [btn_name.pos.x+50,btn_name.pos.y+2]
		lbl_result.pos = [lbl_result.pos.x,btn_name.pos.y+25]
		btn_rename.pos =[grp_rename.pos.x+5,btn_name.pos.y+45]
		grp_rename.height = (btn_rename.pos.y+25)
		
		grp_findreplace.pos = [grp_rename.pos.x,grp_rename.pos.y+grp_rename.height]
		btn_find.pos = [grp_findreplace.pos.x+5, grp_findreplace.pos.y+15]
		txt_find.pos = [btn_find.pos.x+50,btn_find.pos.y+2]
		btn_with.pos = [btn_find.pos.x,btn_find.pos.y+25]
		txt_with.pos = [btn_find.pos.x+50,btn_find.pos.y+27]
		btn_replace.pos = [grp_findreplace.pos.x+5,btn_with.pos.y+25]
		grp_findreplace.height = (btn_replace.pos.y+25-grp_rename.height)
		
		grp_remove.pos = [grp_findreplace.pos.x,grp_findreplace.pos.y+grp_findreplace.height]
		btn_rmStart.pos = [grp_remove.pos.x+5, grp_remove.pos.y+15]
		spn_start.pos = [btn_rmStart.pos.x+195, btn_rmStart.pos.y+3]
		btn_rmEnd.pos = [btn_rmStart.pos.x, btn_rmStart.pos.y+25]
		spn_end.pos = [spn_start.pos.x, spn_start.pos.y+25]
		grp_remove.height = (btn_rmEnd.pos.y+30- grp_findreplace.pos.y-grp_findreplace.height)
		renamer.height = grp_rename.height + grp_findreplace.height + grp_remove.height +20
		
		hl_email.pos = [hl_email.pos.x, (renamer.height-14)]
		hl_web.pos = [hl_web.pos.x, (renamer.height-14)]
		hl_donate.pos = [hl_donate.pos.x, (renamer.height-14)]
	)
	function fn_checkstate =
	(
		if txt_find.text != "" then btn_replace.enabled = true else btn_replace.enabled = false
	)
	function fn_searchtext sourcetext findtext replacetext =
	(	
		num = #()
		dig = #()
		digit = 0
		for i=0 to sourcetext.count where sourcetext[i] == findtext do (
			digit +=1
			if sourcetext[i-1] != findtext do (
				append num i
			)
			if sourcetext[i+1] != findtext do
			(	append dig digit
				digit = 0)
		)
		if num.count == dig.count do 
			for i=1 to num.count do 
			(
				if classof replacetext == Integer do replacetext = (formattedPrint replacetext format: (dig[i] as string +"."+dig[i] as string +"d"))
				
				sourcetext = (replace sourcetext num[i] dig[i] replacetext)	
			)
		sourcetext
	)
	function fn_rename =
	(
		undo "Rename" on
			(
				obj = selection as array
				for i=1 to obj.count do 
				(
					oname= txt_name.text
					for j=1 to oname.count do
					(
						oname = fn_searchtext oname "#" i
						oname = fn_searchtext oname "$" obj[i].name
						if obj[i].material != undefined then	oname = fn_searchtext oname "@" obj[i].material.name
						else oname = fn_searchtext oname "@" "No Material"
					)
					if ddl_rename.selection == 1 do obj[i].name = oname
					if ddl_rename.selection == 2 and obj[i].material != undefined do obj[i].material.name = oname
				)
			)
	)
	function fn_updateResult =
	(
		oname = txt_name.text
		if oname == "" then oname = "Result"
		else (
			oname = fn_searchtext oname "#" 1
			oname = fn_searchtext oname "$" "ObjectName"
			oname = fn_searchtext oname "@" "MaterialName"
		)
		lbl_result.text = oname
	)
	function fn_replace =
	(
		undo "Rename" on
		(
			obj = selection as array
			for i=1 to obj.count do 
			(
				findtext = txt_find.text
				if ddl_rename.selection == 1 do
				(
					num = findString obj[i].name findtext
					if num != undefined do obj[i].name = replace obj[i].name num findtext.count txt_with.text
				)
				if ddl_rename.selection == 2 and obj[i].material != undefined do
				(
					num = findString obj[i].material.name findtext
					if num != undefined do obj[i].material.name = replace obj[i].material.name num findtext.count txt_with.text
				)
			)
		)
	)
	on renamer open do
	(
		fn_init()
		renamer.title = ".timo - Renamer v." +RenamerVersion
		fn_checkstate()
	)
	on renamer moved pos do
	(
		if renamer_help != undefined and renamer_help.isdisplayed do
		(
			renamerpos = GetDialogPos renamer
			setdialogpos renamer_help [renamerpos.x+renamer.width+10,renamerpos.y+30]
		)
	)
	on btn_help pressed do
	(
		rollout renamer_help "Help" width:100
		(
			label Help "----- Help -----"
			button btn_ObjName "$ - Objectname" width:90 align:#center tooltip:"Insert Current Object name"
			button btn_MatName "@ - Materialname" width:90 align:#center tooltip:"Insert Current Material name"
			button btn_Number "# - Number" width:90 align:#center tooltip:"Insert Number to Name"
			button btn_close "Close" width:90 align:#center tooltip:"Close Help"
			
			on btn_objname pressed do (renamer.txt_name.text = renamer.txt_name.text+"$"; fn_updateresult())
			on btn_MatName pressed do (renamer.txt_name.text = renamer.txt_name.text+"@"; fn_updateresult())
			on btn_Number pressed do (renamer.txt_name.text = renamer.txt_name.text+"#"; fn_updateresult())

			on btn_close pressed do destroydialog renamer_help
		)
		createdialog renamer_help style:#()
		renamerpos = GetDialogPos renamer
		setdialogpos renamer_help [renamerpos.x+renamer.width+10,renamerpos.y+30]
	)
	on txt_Name keyUp e do
	( 	if e.KeyCode != e.KeyCode.Enter do fn_updateResult()
		if e.KeyCode == e.KeyCode.Enter do 
			if txt_Name.text != "" do fn_rename()
	)
	on btn_name pressed do txt_name.text = ""
	on btn_rename pressed do if txt_name.text != "" do fn_rename()
	
	on btn_find pressed do (txt_find.text = ""; fn_checkstate	())
	on btn_with pressed do txt_with.text = ""

	on txt_find keyUp e do
	( 	
		if e.KeyCode != e.KeyCode.Enter do fn_checkstate ()
		if e.KeyCode == e.KeyCode.Enter do if txt_find.text != "" do setFocus txt_with
	)
	on txt_with keyUp e do
	( 	
		if e.KeyCode == e.KeyCode.Enter and txt_find.text != "" do fn_replace()
	)
	
	on btn_replace pressed do if txt_find.text != "" do fn_replace()
	on btn_rmStart pressed do
	(
		undo "Rename" on
		(
			obj = selection as array
			for i=1 to obj.count do 
			(
				if ddl_rename.selection == 1 do obj[i].name = substring obj[i].name (spn_start.value+1) (obj[i].name.count)
				if ddl_rename.selection == 2 and obj[i].material != undefined do obj[i].material.name = substring  obj[i].material.name (spn_start.value+1) (obj[i].material.name.count)
			)
		)
	)
	on btn_rmEnd Pressed do
	(
		undo "Rename" on
		(
			obj = selection as array
			for i=1 to obj.count do 
			(
				if ddl_rename.selection == 1 do obj[i].name = substring obj[i].name (1) (obj[i].name.count-spn_end.value)
				if ddl_rename.selection == 2 and obj[i].material != undefined do obj[i].material.name = substring obj[i].material.name (1) (obj[i].material.name.count-spn_end.value)
			)
		)
	)
	on renamer close do
	(
		try destroydialog renamer_help catch()
	)
)
createdialog renamer width:230
