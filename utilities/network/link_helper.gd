class_name LinkHelper


static func is_valid_url(url: String) -> bool:
	var regex = RegEx.new()
	var url_pattern = "/(https:\\/\\/www\\.|http:\\/\\/www\\.|https:\\/\\/|http:\\/\\/)?[a-zA-Z]{2,}(\\.[a-zA-Z]{2,})(\\.[a-zA-Z]{2,})?\\/[a-zA-Z0-9]{2,}|((https:\\/\\/www\\.|http:\\/\\/www\\.|https:\\/\\/|http:\\/\\/)?[a-zA-Z]{2,}(\\.[a-zA-Z]{2,})(\\.[a-zA-Z]{2,})?)|(https:\\/\\/www\\.|http:\\/\\/www\\.|https:\\/\\/|http:\\/\\/)?[a-zA-Z0-9]{2,}\\.[a-zA-Z0-9]{2,}\\.[a-zA-Z0-9]{2,}(\\.[a-zA-Z0-9]{2,})?/g"
	regex.compile(url_pattern)
	
	return regex.search(url) != null

	
func open_external_link(url: String) -> void:
	if LinkHelper.is_valid_url(url) and OS.has_method("shell_open"):
		if OS.get_name() == "Web":
			url = url.uri_encode()
			
		OS.shell_open(url)
