<script>
import { faExclamationCircle } from "@fortawesome/free-solid-svg-icons";
import Fa from "svelte-fa";
import { Alert } from "sveltestrap";
</script>

<Alert color="danger">
	<Fa icon={faExclamationCircle} />
	Notice: This page will undergo many changes please be aware of those changes whenever possible.
	<hr />
	Report any issues to the <a class="alert-link" href="https://github.com/Podshot/MCEdit-Unified/issues/new">GitHub Issues</a> page.
</Alert>
<div class="alert alert-warning" role="alert">
	<p>
		<Fa icon={faExclamationCircle} />
		The tutorial page is currently under construction, please wait until its done or you can:
	</p>
	<ul>
		<li>Make a <a class="alert-link" href="https://github.com/Podshot/MCEdit-Unified/pulls">pull request</a> and can speed up the process.</li>
		<li>Create/Find a good MCEdit tutorial video on youtube.
			<ul>
				<li>The age is fine as long as shows the basics. Ex: <a class="alert-link" href="https://www.youtube.com/watch?v=B6di0TCI8LU">www.youtube.com/watch?v=B6di0TCI8LU</a> can be used as well.</li>
				<li>Explanation on different uses of filters, schematics, macros, etc.</li>
				<li>How to import/export worlds on the PC version and the Pocket Edition (once an update comes).</li>
			</ul>
		</li>
	</ul>
</div>

<h3>Default Controls</h3>
<h4>Camera</h4>
<table class="table">
	<tr>
		<td>WASD</td><td>Move Camera</td>
	</tr>
	<tr>
		<td>IJKL</td><td>Pan Camera</td>
	</tr>
	<tr>
		<td>Shift / Space</td><td>Altitude</td>
	</tr>
	<tr>
		<td>C</td><td>Stop/Slow Movement</td>
	</tr>
	<tr>
		<td>Tab</td><td>Toggle Chunk View</td>
	</tr>
	<tr>
		<td>Right-Click</td><td>Toggle Look-Mode</td>
	</tr>
	<tr>
		<td>Right-Click and Drag</td><td>Quick Look</td>
	</tr>
</table>
<h4>Basic UI</h4>
<table class="table">
	<tr>
		<td>Left-Click</td><td>Use Tool</td>
	</tr>
	<tr>
		<td>1-9<td>Select Tool</td>
	</tr>
	<tr>
		<td>Mousewheel</td><td>Change Tool Distance</td>
	</tr>
	<tr>
		<td>ESCAPE</td><td>Cancel Action/Return to Select/Menu</td>
	</tr>
</table>
<h4>General Tools</h4>
<table class="table">
	<tr>
		<td>Control-Z</td><td>Undo</td>
	</tr>
	<tr>
		<td>Control-Y</td><td>Redo</td>
	</tr>
	<tr>
		<td>Option</td><td>Show block info</td>
	</tr>
</table>
<h4>Select</h4>
<table class="table">
	<tr>
		<td>Delete</td><td>Remove Selected Blocks</td>
	</tr>
	<tr>
		<td>Scroll Up</td><td>Increase Reach</td>
	</tr>
	<tr>
		<td>Scroll Down</td><td>Decrease Reach</td>
	</tr>
	<tr>
		<td>Middle Mouse</td><td>Reset Reach</td>
	</tr>
	<tr>
		<td>Option+Z</td><td>Long-Distance Mode</td>
	</tr>
	<tr>
		<td>Option (Hold)</td><td>Blocks-Only Modifier</td>
	</tr>
</table>
<h4>Brush</h4>
<table class="table">
	<tr>
		<td>E</td><td>Rotate Brush</td>
	</tr>
	<tr>
		<td>G</td><td>Roll Brush</td>
	</tr>
	<tr>
		<td>R</td><td>Increase Brush Size</td>
	</tr>
	<tr>
		<td>F</td><td>Decrease Brush Size</td>
	</tr>
	<tr>
		<td>Z</td><td>Line Tool</td>
	</tr>
	<tr>
		<td>Option-E</td><td>Rotate Block</td>
	</tr>
	<tr>
		<td>Option-G</td><td>Roll Block</td>
	</tr>
	<tr>
		<td>Option-Click</td><td>Pick Block</td>
	</tr>
</table>
<h4>Clone</h4>
<table class="table">
	<tr>
		<td>E</td><td>Rotate Selection</td>
	</tr>
	<tr>
		<td>R</td><td>Roll Selection</td>
	</tr>
	<tr>
		<td>F</td><td>Flip Selection</td>
	</tr>
	<tr>
		<td>G</td><td>Mirror Selection</td>
	</tr>
	<tr>
		<td>Control</td><td>Snap Clone to Axis</td>
	</tr>
</table>
<h4>Fill and Replace</h4>
<table class="table">
	<tr>
		<td>R</td><td>Replace</td>
	</tr>
	<tr>
		<td>X</td><td>Swap</td>
	</tr>
</table>
<h4>Chunk Control</h4>
<table class="table">
	<tr>
		<td>Z (Hold)</td><td>Select Chunks</td>
	</tr>
	<tr>
		<td>Option (Hold)</td><td>Deselect Chunks</td>
	</tr>
</table>
<h4>Function</h4>
<table class="table">
	<tr>
		<td>F1-F5</td><td>Open World1-World5</td>
	</tr>
	<tr>
		<td>O</td><td>Open from File</td>
	</tr>
	<tr>
		<td>N</td><td>Create New World</td>
	</tr>
	<tr>
		<td>Control-S</td><td>Save World</td>
	</tr>
	<tr>
		<td>Control-W</td><td>Close World</td>
	</tr>
	<tr>
		<td>Control-A</td><td>Select All</td>
	</tr>
	<tr>
		<td>Control-D</td><td>Deselect</td>
	</tr>
	<tr>
		<td>Control-G</td><td>Teleport to Coordinates</td>
	</tr>
	<tr>
		<td>Control-F</td><td>Change view distance</td>
	</tr>
	<tr>
		<td>Control-M</td><td>Disable Renderer (Debug)</td>
	</tr>
	<tr>
		<td>Option-F4</td><td>Close MCEdit</td>
	</tr>
</table>
<p>
	Here's a quick overview of a few of the different tools we have:
</p>
<ul>
	<li>
		<a href="#Selection">Selection</a>: Make a selection by marking its corners. Press again to switch
		corners.<br>
	</li>
	<li>
		<a href="#Brush">Brush</a>: "Paints" the landscape using a selection of brushes. Use Alt to pick block.<br>
	</li>
	<li>
		<a href="#Clone">Clone</a>: Copies the selected blocks. Click to set the copy down, then press "Clone"
		to clone.
		<span style="font-weight: bold">E R F G
		</span> to transform blocks.<br>
	</li>
	<li>
		<a href="#Fill">Fill</a>: Fills the selection with a chosen block type, optionally replacing another type.
		<span style="font-weight: bold">R
		</span> to start replacing,
		<span style="font-weight: bold">E
		</span> to swap materials.
	</li>
	<li>
		<a href="#Filter">Filter</a>: External scripts for advanced functionality.
	</li>
	<li>
		<a href="#Crane">Import</a>: Import a <i>Schematic</i> file or an entire level into the current world.
	</li>
	<li>
		<a href="#Player">Player</a>: Modifies, deletes, and adds players in the world.
	</li>
	<li>
		<a href="#Spawn">Spawn</a>: Click to move the player's spawn. Press twice to teleport.
	</li>
	<li>
		<a href="#Chunk">Chunk</a>: Create, delete, and light chunks. Prune away all of the chunks outside the
		selection.
	</li>
	<li>
		<a href="#NBT">NBT Edit</a>: Edit the raw NBT data for the loaded world. Use with caution.
	</li>
</ul>
<p>
	There are a few <span style="font-weight: bold">Nudge</span> buttons scattered around. To use them, click and hold down on one. While holding the mouse button, use the
	movement keys (defaults: <span style="font-weight: bold">WASDShiftSpace</span>) to move the related item around. Hold Right Click to nudge further.
</p>
<p>
	If you have a powerful computer, press
	Control-F to see farther.
</p>

<!-- Selection -->
<h2 id="Selection">Selection Tool</h2>
<p>
	Mark a selection using blue and yellow cubes
</p>
<figure class="figure">
	<img src="images/Selection0.png" class="figure-img img-fluid rounded" alt="A selection in progress. The selection is indicated by a highlighted cuboid, with the opposing corner blocks highlighted in blue and yellow, acting as drag points.">
	<figcaption class="figure-caption">A selection in progress</figcaption>
</figure>
<figure class="figure">
	<img src="images/Selection1.png" class="figure-img img-fluid rounded" alt="A completed selection">
	<figcaption class="figure-caption">A completed selection</figcaption>
</figure>
<p>
	The selection tool can also be used to export schematics and do other basic tasks. Some tools cannot be used without a selection.
</p>

<!-- Brush -->
<h2 id="Brush">Brush Tool</h2>
<p>
	The brush tool allows you to "Paint" the world using preset shapes, you can use RFEG to Increase size, Decrease size, rotate and roll this tool. The varied version will randomly distribute the blocks you select based on selected weightings.
</p>
<figure class="figure">
	<img src="images/brush0.png" class="figure-img img-fluid rounded" alt="The brush tool is being used to paint the world with a diamond shape formed from coal ore">
	<figcaption class="figure-caption">Painting a diamond of coal ore</figcaption>
</figure>

<h3>Line Brush</h3>
<p>
	Hold Z after placing a brush and click a second point to create a solid line of that brush. Line spacing adjusts how close together brushes are.
</p>
<figure class="figure">
	<img src="images/brush1.png" class="figure-img img-fluid rounded" alt="The brush tool is being used to paint a line of diamonds of coal ore">
	<figcaption class="figure-caption">Painting a line of diamonds of coal ore</figcaption>
</figure>
<p>
	The line tool works from the last brushed point, so you can continue from the end of your last line.
</p>
<h4>Erode</h4>
<p>
	You can also erode the terrain, making it more natural. To use this tool set the size and strength you want and click and drag over the area you wish to erode.
</p>
<div style="display: flex;">
	<figure class="figure" style="margin-right: 10px;">
		<img src="images/brush2.png" class="figure-img img-fluid rounded" alt="The erode tool is being used to shape the side of a solid cuboid of blocks">
		<figcaption class="figure-caption">Before using the erode tool</figcaption>
	</figure>
	<figure class="figure" style="margin-left: 10px;">
		<img src="images/brush3.png" class="figure-img img-fluid rounded" alt="The erode tool is being used to shape the side of a solid cuboid of blocks">
		<figcaption class="figure-caption">After using the erode tool</figcaption>
	</figure>
</div>
<p>
	It is recommended to make multiple lower intensity passes for best results. If the brush is still too strong at strength 1, turn up Minimum Spacing.
</p>
<h3>Flood Fill</h3>
<p>
	This brush will systematically replace all blocks of the same type touching the block you click on. This will go on until you either cancel the operation or it finishes.
</p>
<figure class="figure">
	<img src="images/brush4.png" class="figure-img img-fluid rounded" alt="The flood fill tool is being used to replace a solid cuboid of a block with a different type of block">
	<figcaption class="figure-caption">An interrupted flood fill operation</figcaption>
</figure>
<h3>Paste</h3>
<p>
	The paste brush simply brushes an imported schematic.
</p>
<figure class="figure">
	<img src="images/brush5.png" class="figure-img img-fluid rounded" alt="The paste tool is being used to paint a schematic">
</figure>
<h3>Replace and Varied Replace</h3>
<p>
	The replace and varied replace tools replace the block selected in the first slot with the block(s) selected in the lower slot(s).
</p>
<div style="display: flex;">
	<figure class="figure" style="margin-right: 10px;">
		<img src="images/brush6.png" class="figure-img img-fluid rounded">
		<figcaption class="figure-caption">Before using the replace tools</figcaption>
	</figure>
	<figure class="figure" style="margin-left: 10px;">
		<img src="images/brush7.png" class="figure-img img-fluid rounded">
		<figcaption class="figure-caption">After using the replace tools</figcaption>
	</figure>
</div>
<figure class="figure">
	<img src="images/brush8.png" class="figure-img img-fluid rounded">
	<figcaption class="figure-caption">After using the varied replace tool</figcaption>
</figure>
<h3>Topsoil</h3>
<p>
	Topsoil works by replacing the top layer of wherever you brush with the selected block. Depth is selectable.
</p>
<figure class="figure">
	<img src="images/brush9.png" class="figure-img img-fluid rounded" alt="The top layer of some netherrack is replaced with podzol">
</figure>

<h2 id="Clone">Clone Tool:</h2>
<p>
	Quickly copy blocks within the same level. The selected blocks are cloned into the green box and will
	follow your cursor around until you click. Click the green selection again to pick it back up.
	<br>
	<img src="images/clone0.png" class="simg" alt="Image">
</p>
<p>
	Use the keys <span style="font-weight: bold">E R F G</span> to rotate, roll, flip, and mirror a cloned structure.
	<br>
	<img src="images/clone2.png" class="simg" alt="Image">
</p>
<p>
	Once you are happy with the clone's location, click <span style="font-weight: bold">Clone</span> or press <span style="font-weight: bold">Enter</span> to apply, a selection will appear over the cloned area when complete.
	<br>
	<img src="images/clone1.png" class="simg" alt="Image">
</p>
<h2 id="Fill">Fill Tool:</h2>
<p>
	Pretty self-explanatory, fills the selected area with the chosen block. Can also replace certain blocks.
	<br>
	<img src="images/replace.png" class="simg" alt="Image">
</p>
<h2 id="Filter">Filter Tool:</h2>
<p>
	The filter tool allows the use of external plugins called filters for advanced functions not covered by other tools. The filters folder can be found by clicking the <span style="font-style: italic">Config Files</span> button on the main menu.
	To use the filter tool; first select the area you wish to modify then select the filter you wish to use. After you've finished configuring the filter click <span style="font-weight: bold">Filter</span> to apply.
	<br>
	<img src="images/Filter0.png" class="simg" alt="Image">
	<br>
	The forester filter in action. *Note, forester requires selection to include ground.
	<br>
	<img src="images/Filter1.png" class="simg" alt="Image">
</p>
<h2 id="Crane">Import tool:</h2>
<p>
	The import tool lets you import blocks from different sources: It can place blocks previously saved using the select tool to a schematic.
	It can also import an entire level into another level. It will ask you to choose a level or schematic. After you've chosen,
	the level or schematic will appear in the green box. Although it may take a few seconds to display the
	contents of the import, it is fully loaded and can be placed without waiting for everything to render.
	<br>
	<img src="images/crane0.jpg" class="simg" alt="Image">
</p>
<p>
	As before, you can click to pick the blocks up, and use <span style="font-weight: bold">E R F </span> to rotate, roll, and flip them.
	<br>
	<img src="images/crane1.jpg" class="simg" alt="Image">
</p>
<p>
	Press ENTER or click <span style="font-weight: bold">Import</span> to construct. Constructions of up to 64 million blocks should take less than a minute. The copy is done once you regain control. You should press Control-S to save your level now. The lighting recalculation for this city took about 3 minutes on a Core i5.
	<br>
	<img src="images/crane2.jpg" class="simg" alt="Image">
</p>
<h2 id="Player">Player Tool:</h2>
<p>
	Tool used to add/delete/move players in your world. Mostly self-explanatory. <span style="font-weight: bold">Align to Camera</span> moves the selected player to your current location.
	<br>
	<img src="images/player0.png" class="simg" alt="Image">
	<br><br>
	<span style="font-weight: bold">EditNBT</span> allows you to modify a player's NBT data, use at own risk. See NBT section for more details.
	<br>
	<img src="images/player1.png" class="simg" alt="Image">
</p>
<h2 id="Spawn">Spawn Tool:</h2>
<p>
	Used to move or view the world's spawn. Click to apply a new spawn point.
	<br>
	<img src="images/spawn.png" class="simg" alt="Image">
	<br>
</p>
<h2 id="Chunk">Chunk tool:</h2>
<p>
	<img src="images/chunk.png" alt="Image">
	<br>
	When you pick the Chunk tool, the visible selection is
	automatically expanded to cover all of the chunks it touches. Press <span style="font-style: italic">Create</span> to create all missing chunks in the selection, ignoring any chunks already present.
	Press <span style="font-style: italic">Destroy</span> to remove any chunks within the selection. Use <span style="font-style: italic">Prune</span> to keep all of the chunks in the selection, and delete the ones outside.
	Use <span style="font-style: italic">Repop</span> to mark chunks for repopulation of ores and structures next time minecraft loads the chunk.
	All of these will ask you for confirmation because there's no way to undo them. Use <span style="font-weight: bold">TAB</span> to get a better view for chunk pruning.
</p>
<p>
	Finally, you can press <span style="font-style: italic">Relight</span> to fix any bad lighting within the selected chunks. If other programs leave your level full of black spots, you can fix it with this.
</p>
<h2 id="NBT">NBT Editor:</h2>
<p>
	Used to modify the raw NBT data of the world. Use at own risk. To modify a more specific area or object use the NBT editor filter.
	<br>
	<img src="images/NBT.png" class="simg" alt="Image">
	<br>
</p>