<script>
	import Fa from 'svelte-fa';
	import { faStar, faHistory, faWind, faCloudDownloadAlt, faCode } from '@fortawesome/free-solid-svg-icons';
	import { faApple, faLinux, faWindows } from '@fortawesome/free-brands-svg-icons';
import { Button } from 'sveltestrap';

	let showAllVersions = false;

	function clickShowAll() {
		showAllVersions = true;
	}
</script>

<h3 class="text-center">
	MCEdit Unified for Java 1.12 and Bedrock
</h3>

<div class="mb-4 bg-light rounded-3">
	<div class="row p-4">
		<div class="col platform-col">
			<Fa icon={faApple} style="height: 5em;"/>
			<div style="font-size: 1.4em;">
				macOS
			</div>
			<a class="btn btn-primary" href="https://github.com/Podshot/MCEdit-Unified/releases/download/1.5.6.0/MCEdit.v1.5.6.0.OSX.64bit.zip">
				<Fa icon={faCloudDownloadAlt} />
				Version 1.5.6.0
			</a>
		</div>
		<div class="col platform-col">
			<Fa icon={faWindows} style="height: 5em;"/>
			<div style="font-size: 1.4em;">
				Windows
			</div>
			<a class="btn btn-primary" href="https://github.com/Podshot/MCEdit-Unified/releases/download/1.5.6.0/MCEdit.v1.5.6.0.Win.32bit.exe">
				<Fa icon={faCloudDownloadAlt} />
				Version 1.5.6.0 32bit
			</a>
			<a class="btn btn-primary" href="https://github.com/Podshot/MCEdit-Unified/releases/download/1.5.6.0/MCEdit.v1.5.6.0.Win.64bit.exe">
				<Fa icon={faCloudDownloadAlt} />
				Version 1.5.6.0 64bit
			</a>
		</div>
		<div class="col platform-col">
			<Fa icon={faLinux} style="height: 5em;"/>
			<div style="font-size: 1.4em;">
				Linux Beta
			</div>
			<a class="btn btn-primary" href="https://github.com/Podshot/MCEdit-Unified/releases/download/1.5.6.0/MCEdit.v1.5.6.0.Lin.Universal.run">
				<Fa icon={faCloudDownloadAlt} />
				Version 1.5.6.0
			</a>
			<a class="btn btn-primary" href="https://github.com/Podshot/MCEdit-Unified/releases">
				<Fa icon={faCode} />
				Run From Source
			</a>
		</div>
	</div>
	<div class="d-flex justify-content-between pb-2 px-2">
		<span>
			{#if showAllVersions}
				<Fa icon={faStar} />
				Click <a href="https://github.com/Podshot/MCEdit-Unified-Preview/releases">here</a>
				for test releases (Windows)
			{/if}
		</span>
		<span>
			{#if showAllVersions}
				<Fa icon={faHistory} />
				Pre-Anvil versions can be found at
				<a href="https://github.com/Khroki/mcedit-old/releases?after=0.1.6build315">this page</a>.
			{:else}
				<Fa icon={faStar} />
				<!-- svelte-ignore a11y-invalid-attribute -->
				Click <a href="#" on:click={clickShowAll}>here</a>
				to view all versions.
			{/if}
		</span>
	</div>
</div>

<style>
	.pb-x-05 {
		padding-bottom: 0.5rem !important;
	}

	.platform-col {
		display: flex;
		flex-direction: column;
		align-items: center;
		gap: 1em;
	}
</style>