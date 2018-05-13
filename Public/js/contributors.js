function startEditing(username) {
	const descriptionField = `.contributor[contrib-id=${username}] > .thumbnail > .caption > h3 > small > .description-field`;
	const descriptionEditField = `.contributor[contrib-id=${username}] > .thumbnail > .caption > h3 > small > form > .description-edit-field`;

	const descriptionEditStart = `.contributor[contrib-id=${username}] > .thumbnail > .caption > h3 > small > .description-edit-start`;
	const descriptionEditEnd = `.contributor[contrib-id=${username}] > .thumbnail > .caption > h3 > small > .description-edit-end`;
	const descriptionEditSave = `.contributor[contrib-id=${username}] > .thumbnail > .caption > h3 > small > form > .description-edit-save`;

	document.querySelector(descriptionField).style.display = 'none';
	document.querySelector(descriptionEditField).style.display = 'initial';

	document.querySelector(descriptionEditStart).style.display = 'none';
	document.querySelector(descriptionEditEnd).style.display = 'initial';
	document.querySelector(descriptionEditSave).style.display = 'initial';
}

function cancelEditing(username) {
	const descriptionField = `.contributor[contrib-id=${username}] > .thumbnail > .caption > h3 > small > .description-field`;
	const descriptionEditField = `.contributor[contrib-id=${username}] > .thumbnail > .caption > h3 > small > form > .description-edit-field`;

	const descriptionEditStart = `.contributor[contrib-id=${username}] > .thumbnail > .caption > h3 > small > .description-edit-start`;
	const descriptionEditEnd = `.contributor[contrib-id=${username}] > .thumbnail > .caption > h3 > small > .description-edit-end`;
	const descriptionEditSave = `.contributor[contrib-id=${username}] > .thumbnail > .caption > h3 > small > form > .description-edit-save`;

	document.querySelector(descriptionField).style.display = 'initial';
	document.querySelector(descriptionEditField).style.display = 'none';

	document.querySelector(descriptionEditStart).style.display = 'initial';
	document.querySelector(descriptionEditEnd).style.display = 'none';
	document.querySelector(descriptionEditSave).style.display = 'none';
}