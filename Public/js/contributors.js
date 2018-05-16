function startEditButton(username) {
	return $(`.description-edit-start[contrib-id=${username}]`);
}

function saveEditButton(username) {
	return $(`.description-edit-save[contrib-id=${username}]`);
}

function cancelEditButton(username) {
	return $(`.description-edit-end[contrib-id=${username}]`);
}

function descriptionField(username) {
	return $(`.description-field[contrib-id=${username}]`)
}

function descriptionEdit(username) {
	return $(`.description-edit[contrib-id=${username}]`)
}

function twitterButton(username) {
	return $(`.twitter-button[contrib-id=${username}]`)
}

function twitterEdit(username) {
	return $(`.twitter-edit[contrib-id=${username}]`)
}

function youtubeButton(username) {
	return $(`.youtube-button[contrib-id=${username}]`)
}

function youtubeEdit(username) {
	return $(`.youtube-edit[contrib-id=${username}]`)
}

function redditButton(username) {
	return $(`.reddit-button[contrib-id=${username}]`)
}

function redditEdit(username) {
	return $(`.reddit-edit[contrib-id=${username}]`)
}


function startEditing(username) {
	descriptionField(username).hide();
	descriptionEdit(username).show();

	startEditButton(username).hide();
	cancelEditButton(username).show();
	saveEditButton(username).show();

	twitterButton(username).hide();
	twitterEdit(username).show();

	youtubeButton(username).hide();
	youtubeEdit(username).show();

	redditButton(username).hide();
	redditEdit(username).show();
}

function cancelEditing(username) {
	descriptionField(username).show();
	descriptionEdit(username).hide();

	startEditButton(username).show();
	cancelEditButton(username).hide();
	saveEditButton(username).hide();

	twitterButton(username).show();
	twitterEdit(username).hide();

	youtubeButton(username).show();
	youtubeEdit(username).hide();

	redditButton(username).show();
	redditEdit(username).hide();
}