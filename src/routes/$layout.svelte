<script>
	import '../app.css';
	import { page } from '$app/stores';
	import {
		Nav,
		NavLink,
		Navbar,
		NavbarBrand,
	} from 'sveltestrap';

	$: path = $page.path;

	const links = [
		{
			href: '/about',
			label: 'About',
		},
		{
			href: '/tutorial',
			label: 'Tutorial',
		},
		{
			href: '/requirements',
			label: 'System Requirements',
		},
		{
			href: '/docs/index.html',
			label: 'Documentation',
		},
		{
			href: 'https://discord.gg/BTm6jnf',
			label: 'Discord Server',
		},
		{
			href: 'https://www.reddit.com/r/MCEdit',
			label: 'Reddit',
		},
		{
			href: 'https://github.com/Podshot/MCEdit-Unified',
			label: 'Github',
		},
	]
</script>

<Navbar color="dark" dark expand="md">
	<div class="container">
		<NavbarBrand href="/">MCEdit Unified</NavbarBrand>
		<!-- <Collapse {isOpen} navbar expand="md" on:update={handleUpdate}> -->
		<div>
			<Nav navbar>
				{#each links as link}
					<NavLink active={path === link.href} href={link.href}>{link.label}</NavLink>
				{/each}
			</Nav>
		</div>
		<!-- </Collapse> -->
	</div>
</Navbar>

<div class="container mb-1" id="primary-container">
	<slot />
</div>

<hr />
<div id="footer" class="text-center text-small">
	© 2010-2014 David Rio Vierra (<a href="https://twitter.com/codewarrior0">Codewarrior0</a>).
	© 2014-2015 <a href="/contributors">Khroki and all of the contributers</a>.
	All Rights Reserved to their respective ownership.
</div>

<style>
#primary-container {
	padding-top: 1rem;
}

#footer {
	font-size: small;
}
</style>