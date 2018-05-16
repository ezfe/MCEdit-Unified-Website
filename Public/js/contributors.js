function startEditing(username) {
	const descriptionField = `.description-field[contrib-id=${username}]`;
	const descriptionEditField = `.description-edit-field[contrib-id=${username}]`;

	const descriptionEditStart = `.description-edit-start[contrib-id=${username}]`;
	const descriptionEditEnd = `.description-edit-end[contrib-id=${username}]`;
	const descriptionEditSave = `.description-edit-save[contrib-id=${username}]`;

	$(descriptionField).hide();
	$(descriptionEditField).show();

	$(descriptionEditStart).hide();
	$(descriptionEditEnd).show();
	$(descriptionEditSave).show();
}

function cancelEditing(username) {
	const descriptionField = `.description-field[contrib-id=${username}]`;
	const descriptionEditField = `.description-edit-field[contrib-id=${username}]`;

	const descriptionEditStart = `.description-edit-start[contrib-id=${username}]`;
	const descriptionEditEnd = `.description-edit-end[contrib-id=${username}]`;
	const descriptionEditSave = `.description-edit-save[contrib-id=${username}]`;

	$(descriptionField).show();
	$(descriptionEditField).hide();

	$(descriptionEditStart).show();
	$(descriptionEditEnd).hide();
	$(descriptionEditSave).hide();
}