/********************************************************
:Author:	Timothy Halim
:Site:		http://timo.ink
:Email:	mail@timo.ink
:Date:		17 Jan 2016
:Update:	24 Des 2016
********************************************************/

/*
	Notes:
	Feel free to edit the script.
	Please don't distribute or commercialize it without my permission.
	Please notifyme and put my name on credits if you use part of this script.
*/

try (
	cui.UnRegisterDialogBar ToggleMaterial 
	destroyDialog ToggleMaterial
) catch ()

Rollout ToggleMaterial "Switch" width:95 height:95
(
	Button Texture_On "On" pos:[5,5] width:40 height:40 tooltip:"Show Material."
	Button Texture_Off "Off" pos:[50,5] width:40 height:40 tooltip:"Hide Material."
	checkbox Scene_Texture "Scene Mat." pos:[5,48] tooltip:"Apply to All Scene Material." 
	checkbox Realistic_texture "Realistic Mat." pos:[5,65] tooltip:"Realistic Material View."
	progressbar prg_bar pos:[5,85] width:85 height:5 color:green
	
	function fn_progress i all = (
		if i == 0 do i = 1
		if i > all do i = all
		if all == 0 then (precents = 0 as float) else (precents = i*100.00/all as float)
		if precents >= 100 do precents = 100 as float
		
		windows.processPostedMessages()
		prg_bar.value = precents
	)
	function fn_process m state= (
		if Realistic_texture.checked then (
			showTextureMap m state
			enableHardwareMaterial m state
			showHWTextureMap m state
		) else (
			enableHardwareMaterial m false
			showTextureMap m state
		)
	)
	function fn_switchtexture state= (
		if Scene_Texture.checked then (
			matprg = 0
			for m in scenematerials do (
				matprg += 1
-- 				format "% : %" m.name (classof m)
				try (
					fn_process m state
-- 					format " - Done"
				)
				catch (
-- 					format " - not available"
				)
-- 				format "\n"
				fn_progress matprg scenematerials.count
			)
		) else (
			if selection.count > 0 do (
				for i=1 to selection.count do (
					if selection[i].material != undefined do (
						m = selection[i].material
-- 						format "% : %" m.name (classof m)
						try (
							fn_process m state
-- 							format " - Done"
						)
						catch (
-- 							format " - not available"
						)
-- 						format "\n"
					)
					fn_progress i selection.count
				)
			)
		)
	)
	
	on Texture_On pressed do fn_switchtexture On
	on Texture_Off pressed do fn_switchtexture Off
)
CreateDialog ToggleMaterial

/* Add this to automatically dock the dialog
cui.RegisterDialogBar ToggleMaterial minsize:[105,105] minsize:[105,105] style:#(#cui_dock_all, #cui_floatable, #cui_handles  )
cui.DockDialogBar ToggleMaterial #cui_dock_bottom
*/
