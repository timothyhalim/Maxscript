/********************************************************
:Author:	Timothy Halim
:Site:		http://timo.ink
:Email:		mail@timo.ink
:Created:	12 Des 2015
:Update:	23 May 2016
********************************************************/
/*
	Notes:
	Feel free to edit the script for personal use.
	Please don't distribute or commercialize it without my permission.
	Please notify me and put my name on credits if you use part of this script.
*/

try destroydialog sel_tool catch ()
rollout sel_tool ".timo Selection Tool v1.2" width:200 height:455
	(
		groupbox grp_name "Select by Name" pos:[-1,3] width:202 height:40
			dotNetControl txt_pattern "System.Windows.Forms.TextBox" pos:[2,17] width:133 height:20
			button btn_srchname "Search!" pos:[138,17] 
		groupbox grp_obj  "Select by Object" pos:[-1,40] width:202 height:197
			pickbutton pc_Obj "Pick Object" pos:[5,55] width:190 height:30 tooltip:"Pick object"
			radiobuttons rd_For  "Search for:" pos:[10,88] labels:#("Objects","Modifier") columns:1 default:1 tooltip:"Search for"
			radiobuttons rd_Obj  "Search type:" pos:[100,88] labels:#("Instanced","Same Class", "Same Material") columns:1 tooltip:"Search type"
			dropdownlist ddl_modifier "" pos:[5,155] width:190 height:4 items:#("Select modifier") enabled:false tooltip:"Modifier List"
			button btn_srchobj "Search!" pos:[5,180] width:90 height:25 tooltip:"Search and select found object"
			button btn_del "Delete Modifer" pos:[105,180] width:90 height:25 tooltip:"Delete Modifier from selection"
		groupbox grp_mat "Select by Material" pos:[-1,210] width:181 height:20
			groupbox grp_rfr "" pos:[179,202] width:17 height:23
			button btn_refresh "refresh" pos:[180,210] width:15 height:15 tooltip:"Refresh Material List" border:false
			dotNetControl MatList "DataGridView" pos:[0,225]
		HyperLink hl_email "Mail" across:3 align:#center offset:[0,198] color:(color 200 200 200) hovercolor:(color 255 255 255) visitedcolor:(color 200 200 200) address:"mailto://mail@timo.ink"
		HyperLink hl_web "Website" align:#center offset:[0,198] color:(color 200 200 200) hovercolor:(color 255 255 255) visitedcolor:(color 200 200 200) address:"http://timo.ink"
		HyperLink hl_donate "Donate" align:#center offset:[0,198] color:(color 200 200 200) hovercolor:(color 255 255 255) visitedcolor:(color 200 200 200) address:"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=NS2NFUHX7NCUQ&lc=ID&item_name=Timothy%20Halim&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donate_SM%2egif%3aNonHosted"
		
		Global obj_pick
		Global sel_tool
		
		local InputKey = dotNetClass "system.windows.forms.control"
		local size = if ((maxVersion())[1] / 1000)-2 < 16 then size = sysInfo.DesktopSize else size = sysInfo.DesktopSizeUnscaled
		local info = dotNetClass "System.Windows.Forms.SystemInformation"
		local desktopsize = (size.x/info.MonitorCount) 
		local multiplier = if desktopsize == 1920 then multiplier = desktopsize/1920 else multiplier = desktopsize/1540
		
	function fn_updateRO=
		(
			if obj_pick == undefined then 
			(
				rd_For.enabled = false
				rd_Obj.enabled = false
				btn_srchobj.enabled = false
				ddl_modifier.enabled = false
				ddl_modifier.items = #("Select Modifier")
				btn_del.enabled = false
				rd_For.state = 1
				rd_Obj.state = 1
			)
			else
			(
				rd_For.enabled = true
				rd_Obj.enabled = true
				btn_srchobj.enabled = true
			)
		)

	function fn_Checkmodifier =
		(
			modifier_list = #()
			for x in obj_pick.modifiers do	(append modifier_list x.name)
			if modifier_list.count >= 1 then sel_tool.ddl_modifier.items = modifier_list
			else sel_tool.ddl_modifier.items = #("No Modifier")
		)

	function Fn_disablerd =
		(
			source  = "using System;\n"
			source += "using System.Runtime.InteropServices;\n"
			source += "class User32\n"
			source += "{\n"
			source += "	[DllImport(\"user32.dll\")] [return: MarshalAs(UnmanagedType.Bool)]\n"
			source += "	public static extern bool EnableWindow(Int32 hWnd, bool bEnable);\n"
			source += "}\n"

			csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
			compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"

			compilerParams.GenerateInMemory = on
			compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(source)
			compilerResults.CompiledAssembly.CreateInstance "User32"
		)

	function fn_selbyinstance =
		(
			obj_array = #(obj_pick)
			obj_sel = #()
			exclude = #(0)
			for i=1 to obj_array.count do 
			(
				if findItem exclude i != 0 do continue
				InstanceMgr.GetInstances obj_array[i] &instances
				for j in instances do 
				(
					k = findItem obj_array j
					if k != 0 do 
					(
						appendIfUnique exclude k
						continue
					)
					if findItem obj_sel j != 0 do continue
					if j.isHiddenInVpt==false do 
					( 
						obj_sel = obj_sel + j
					)
				)
			)
			append obj_sel obj_pick
			select obj_sel
		)

	function fn_selbytype =
		(
			obj_sel = obj_pick
			typeList = #()
			selList = #()
			for objSel in obj_sel do
			(append typeList (classOf(classof objSel)))

			for type in typeList do
				for obj in objects where not obj.isHidden do
				(
					if classOf(classof obj) == type do
					(append selList obj)
				)
			select selList
		)

	function fn_selbymaterial =
		(
			obj_sel =#()
			for obj in objects where not obj.isHidden do
			(
			if obj.material == obj_pick.material do   -- if object's material is the same of father's one
			append obj_sel obj -- add to selection list
			)
			select obj_sel -- select array
		)

	function fn_selbymodifier =
		(
			obj_sel =#()
			for obj in objects where obj.modifiers.count > 0 and not obj.isHidden collect 
			(
				for j in obj.modifiers where (classof j == classof obj_pick.modifiers[sel_tool.ddl_modifier.selection]) do append obj_sel obj 
			)
			select obj_sel
		)

	function fn_selInsModifier =
		(
			obj_sel =#()
			for obj in objects where obj.modifiers.count > 0 and not obj.isHidden collect 
			(
				for j in obj.modifiers where (j == obj_pick.modifiers[sel_tool.ddl_modifier.selection]) do append obj_sel obj 
			)
			select obj_sel
		)

	function fn_delinsmodifier =
		(
			for obj in selection where not obj.isHidden do 
			(

				for m in obj.modifiers where ( m == obj_pick.modifiers[sel_tool.ddl_modifier.selection]) do 
					if obj != obj_pick do deleteModifier obj m
			)
			deleteModifier obj_pick obj_pick.modifiers[sel_tool.ddl_modifier.selection]
		)

	function fn_delsamemodifier =
		(
			for obj in selection where not obj.isHidden do 
			(
				for m in obj.modifiers where (classof m == classof obj_pick.modifiers[sel_tool.ddl_modifier.selection]) do 
					if obj != obj_pick do deleteModifier obj m
			)
			deleteModifier obj_pick obj_pick.modifiers[sel_tool.ddl_modifier.selection]
		)
	
		function Fn_GenerateColumns columns:#() =
		(
			local dnColumns = #()

			for n in columns do
			(
				local newColumn
				(
					newColumn = dotNetObject "DataGridViewTextBoxColumn"
					newColumn.DefaultCellStyle.Alignment = newColumn.DefaultCellStyle.Alignment.MiddleLeft
					newColumn.Resizable = newColumn.Resizable.false
					newColumn.width = n[2]
				)
				newColumn.HeaderText = n[1]
				newColumn.ReadOnly = true
				newColumn.tag = dotNetMXSValue n[1] -- store property name
				append dnColumns newColumn
			)
			dnColumns
		)
	
	function fn_createcol =
		(		
			local colArr = #()
			if scenematerials.count > 7 then 
			(
				append colArr #("Material Name", (sel_tool.width*0.6*multiplier)) -- node name
				append colArr #("Type", (sel_tool.width*0.4*multiplier)-20) -- node's class name
			)
			else 
			(
				append colArr #("Material Name", (sel_tool.width*0.65*multiplier)-1) -- node name
				append colArr #("Type", (sel_tool.width*0.35*multiplier)-1) -- node's class name
			)
			local dnColumns = Fn_GenerateColumns columns:colArr
			
			MatList.Columns.AddRange dnColumns
			MatList.MultiSelect = false
			MatList.AutoResizeColumnHeadersHeight()
			MatList.AllowUserToAddRows = false
			MatList.AllowUserToDeleteRows = false
			MatList.AllowUserToResizeRows = false
			MatList.AllowUserToResizeColumns = false
			MatList.AllowUserToOrderColumns = false
			MatList.ShowEditingIcon = false
			MatList.RowHeadersVisible = false
			MatList.ColumnHeadersBorderStyle = MatList.ColumnHeadersBorderStyle.None
			MatList.ColumnHeadersHeightSizeMode = MatList.ColumnHeadersHeightSizeMode.DisableResizing
			MatList.SelectionMode = MatList.SelectionMode.FullRowSelect
			MatList.ColumnHeadersVisible = true
			MatList.BorderStyle = MatList.BorderStyle.FixedSingle
			

			/* Colors and font */
			MatList.ForeColor = MatList.ForeColor.FromARGB 220 220 220
			MatList.BackColor = MatList.ForeColor.FromARGB 50 50 50
			MatList.GridColor = MatList.ForeColor.FromARGB 50 50 50
			MatList.BackgroundColor = MatList.ForeColor.FromARGB 50 50 50
			MatList.DefaultCellStyle.BackColor = MatList.ForeColor.FromARGB 50 50 50
			MatList.AlternatingRowsDefaultCellStyle.BackColor = MatList.AlternatingRowsDefaultCellStyle.BackColor.FromARGB 45 45 45
			MatList.Font = dotNetObject "System.Drawing.Font" "Arial" 8 MatList.font.style.Regular
			MatList.AdvancedCellBorderStyle.Left = MatList.AdvancedCellBorderStyle.Left.None
			MatList.AdvancedCellBorderStyle.Right = MatList.AdvancedCellBorderStyle.Right.None
		)
	
	function fn_createrow =
		(
			for s in scenematerials do 
			(
				newRow = dotNetObject "DataGridViewRow"
				newRow.height = (MatList.height/8*multiplier)
				newRow.tag = dotNetMXSValue s
				MatList.rows.add newRow
				newRow.cells.item[0].value = s.name
				newRow.cells.item[1].value = (classof s) as string
			)
		)
		
		on sel_tool open do
		(
			txt_pattern.text = "Text"
			obj_pick = undefined
			MatList.width = sel_tool.width
			MatList.height = (sel_tool.height * 0.48)-1
			fn_createcol()
			fn_createrow()
			btn_refresh.images = #("bip_copy1paste_i.bmp",undefined,10,9,9,9,9,false,true)
			fn_updateRO()
		)
		on txt_pattern keyUp e do
		( 	
			if e.KeyCode == e.KeyCode.Enter do 
			(
				pattern = "*"+txt_pattern.text+"*"
				find = for o in objects  where (matchpattern o.name pattern:pattern) collect o
				select find
			)
		)
		on btn_srchname pressed do 
		(
			pattern = "*"+txt_pattern.text+"*"
			find = for o in objects  where (matchpattern o.name pattern:pattern) collect o
			select find
		)
		on rd_For changed state  do
		(
			fn_updateRO()
			_user32 = Fn_disablerd()
			if rd_For.state == 1 do 
			(
				_user32.enablewindow sel_tool.rd_Obj.hwnd[3] on
				ddl_modifier.enabled = false
				btn_del.enabled = false
			)
			if rd_For.state == 2 do 
			(	
				if rd_Obj.state == 3 do rd_Obj.state = 1
				_user32.enablewindow sel_tool.rd_Obj.hwnd[3] off
				ddl_modifier.enabled = true
				btn_del.enabled = true
			)
			if obj_pick != undefined do
			(
				fn_Checkmodifier()	
			)
		)
		
		on pc_obj picked obj do
		(
			obj_pick = obj
			obj_class = superclassof obj as string
			pc_Obj.text = (obj.name +" : " +obj_class)
			txt_pattern.text = obj.name
			fn_Checkmodifier()
			fn_updateRO()
			if superclassof obj == geometryclass do
			(
				mtl = obj.material
				if mtl != undefined then 
				(
					if MatList.rows.count >= 1 do 
					(
					for i = 0 to MatList.rows.count do 
						(	
							
							if MatList.rows.item[i].tag.value == mtl do	
							(
								MatList.ClearSelection()
								MatList.select()
								MatList.Rows.item[i].cells.item[0].Selected = True
								MatList.FirstDisplayedScrollingRowIndex = i
								MatList.Focus()
								exit 
							)
						)
					)
				)
				else MatList.ClearSelection()
			)
		)
		on pc_obj rightClick do
		(
			obj_pick = undefined
			obj_class = undefined
			pc_Obj.text = "Pick Object"
			fn_updateRO()
		)
		on btn_srchobj pressed do
		(
			if obj_pick != undefined then 
			(
				if not isdeleted obj_pick then
				undo "Search" on
				(
					clearselection()
					if rd_For.state == 1 do 
					(
						if rd_Obj.state == 1 do fn_selbyinstance()
						if rd_Obj.state == 2 do fn_selbytype()
						if rd_Obj.state == 3 do fn_selbymaterial()
					)
					if rd_For.state == 2 do
					(
						if rd_Obj.state == 1 do fn_selInsModifier()
						if rd_Obj.state == 2 do fn_selbymodifier()
					)
					fn_Checkmodifier()
				)
				else Messagebox "Source object not exist" title:"Error"
			)
			else Messagebox "Please pick object first" title:"Error"
		)
		on btn_del pressed do
		(
			if obj_pick != undefined then 
			(
				if not isdeleted obj_pick then
				undo "Delete Modifier" on
				(
					if ddl_modifier.items.count > 0 and ddl_modifier.items[ddl_modifier.selection] != "No Modifier" do 
					(	
						if rd_For.state == 2 do
							(
								if rd_Obj.state == 1 do fn_delinsmodifier()
								if rd_Obj.state == 2 do fn_delsamemodifier()
							)
						fn_Checkmodifier()
						ddl_modifier.selection = 1
					)
				)
				else Messagebox "Source object not exist" title:"Error"
			)
			else Messagebox "Please pick object first" title:"Error"
		)
		
		on MatList CellClick s e do
		(
			if e.RowIndex >= 0 do
			(
				local tagValue = MatList.rows.item[e.RowIndex].tag.value
				mtl = tagValue
				sel = #()
				for obj in objects where obj.material == mtl do append sel obj
				if sel.count > 0 do ( 
					if InputKey.ModifierKeys == InputKey.ModifierKeys.Control then selectmore sel
					else if InputKey.ModifierKeys == InputKey.ModifierKeys.Alt then deselect sel
					else select sel
				)
			)
		)
		
		on MatList CellDoubleClick s e do
		(
			if e.RowIndex >= 0 do
			(
				local tagValue = MatList.rows.item[e.RowIndex].tag.value
				
				SME.Open() 
				sme.DeleteView (sme.GetViewByName "QuickEdit") false
				sme.CreateView "QuickEdit"

				mtl = tagValue
				--needed because pos parameter is in/out (a reference)
				NodePos = [0,0] + [0,0]
				-- get the current view
				SelView = sme.GetView sme.ActiveView
				--Assuming you have an object selected and you want that object's material in the editor
				NewNode = SelView.CreateNode mtl &NodePos
				try(
					SelView.SetSelectedNodes mtl
					sme.SetMtlInParamEditor mtl
					SelView.ZoomExtents type:#all
				)catch() --only max 2014 and up
			)
		)
		
		on btn_refresh pressed do
		(
			MatList.columns.Clear()
			fn_createcol()
			fn_createrow()
		)
	)
createdialog sel_tool
	
