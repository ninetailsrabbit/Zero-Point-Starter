## https://docs.godotengine.org/en/stable/tutorials/i18n/locales.html
class_name Localization

class Language:
	var code:  String
	var iso_code: String
	var native_name: String
	var english_name: String
	
	func _init(_code: String, _iso_code: String, _native_name: String, _english_name: String) -> void:
		code = _code
		iso_code = _iso_code
		native_name = _native_name
		english_name = _english_name


enum LANGUAGES {
	ENGLISH,
	CZECH,
	DANISH,
	DUTCH,
	GERMAN,
	GREEK,
	ESPERANTO,
	SPANISH,
	FRENCH,
	INDONESIAN,
	ITALIAN,
	LATVIAN,
	POLISH,
	PORTUGUESE_BRAZILIAN,
	PORTUGUESE,
	RUSSIAN,
	CHINESE_SIMPLIFIED,
	CHINESE_TRADITIONAL,
	NORWEGIAN_BOKMAL,
	HUNGARIAN,
	ROMANIAN,
	KOREAN,
	TURKISH,
	JAPANESE,
	UKRAINIAN
}

static var available_languages: Dictionary = {
	LANGUAGES.ENGLISH: Language.new("en", "en_US", "English", "English"),
	LANGUAGES.FRENCH: Language.new("fr", "fr_FR", "Français", "French"),
	LANGUAGES.CZECH: Language.new("cs", "cs_CZ", "Czech", "Czech"),
	LANGUAGES.DANISH: Language.new("da", "da_DK", "Dansk", "Danish"),
	LANGUAGES.DUTCH: Language.new("nl", "nl_NL", "Nederlands", "Dutch"),
	LANGUAGES.GERMAN: Language.new("de", "de_DE", "Deutsch", "German"),
	LANGUAGES.GREEK: Language.new("el", "el_GR", "Ελληνικά", "Greek"),
	LANGUAGES.ESPERANTO: Language.new("eo", "eo_UY", "Esperanto", "Esperanto"),
	LANGUAGES.SPANISH: Language.new("es", "es_ES", "Español", "Spanish"),
	LANGUAGES.INDONESIAN: Language.new("id", "id_ID", "Indonesian", "Indonesian"),
	LANGUAGES.ITALIAN: Language.new("it", "it_IT", "Italiano", "Italian"),
	LANGUAGES.LATVIAN: Language.new("lv", "lv_LV", "Latvian", "Latvian"),
	LANGUAGES.POLISH: Language.new("pl", "pl_PL", "Polski", "Polish"),
	LANGUAGES.PORTUGUESE_BRAZILIAN: Language.new("pt_BR", "pt_BR", "Português Brasileiro", "Brazilian Portuguese"),
	LANGUAGES.PORTUGUESE: Language.new("pt", "pt_PT", "Português", "Portuguese"),
	LANGUAGES.RUSSIAN: Language.new("ru", "ru_RU", "Русский", "Russian"),
	LANGUAGES.CHINESE_SIMPLIFIED: Language.new("zh_CN", "zh_CN", "简体中文", "Chinese Simplified"),
	LANGUAGES.CHINESE_TRADITIONAL: Language.new("zh_TW", "zh_TW", "繁體中文", "Chinese Traditional"),
	LANGUAGES.NORWEGIAN_BOKMAL: Language.new("nb", "nb_NO", "Norsk Bokmål", "Norwegian Bokmål"),
	LANGUAGES.HUNGARIAN: Language.new("hu", "hu_HU", "Magyar", "Hungarian"),
	LANGUAGES.ROMANIAN: Language.new("ro", "ro_RO", "Română", "Romanian"),
	LANGUAGES.KOREAN: Language.new("ko", "ko_KR", "한국어", "Korean"),
	LANGUAGES.TURKISH: Language.new("tr", "tr_TR", "Türkçe", "Turkish"),
	LANGUAGES.JAPANESE: Language.new("ja", "ja_JP", "日本語", "Japanese"),
	LANGUAGES.UKRAINIAN: Language.new("uk", "uk_UA", "Українська", "Ukrainian"),
} 

#region Language shorcuts
static func english() -> Language:
	return available_languages[LANGUAGES.ENGLISH]
	
static func french() -> Language:
	return available_languages[LANGUAGES.FRENCH]
	
static func czech() -> Language:
	return available_languages[LANGUAGES.CZECH]
	
static func danish() -> Language:
	return available_languages[LANGUAGES.DANISH]
	
static func dutch() -> Language:
	return available_languages[LANGUAGES.DUTCH]
	
static func german() -> Language:
	return available_languages[LANGUAGES.GERMAN]
	
static func greek() -> Language:
	return available_languages[LANGUAGES.GREEK]
	
static func esperanto() -> Language:
	return available_languages[LANGUAGES.ESPERANTO]
	
static func spanish() -> Language:
	return available_languages[LANGUAGES.SPANISH]
	
static func indonesian() -> Language:
	return available_languages[LANGUAGES.INDONESIAN]
	
static func italian() -> Language:
	return available_languages[LANGUAGES.ITALIAN]
	
static func latvian() -> Language:
	return available_languages[LANGUAGES.LATVIAN]
	
static func polish() -> Language:
	return available_languages[LANGUAGES.POLISH]
	
static func portugueseBrazilian() -> Language:
	return available_languages[LANGUAGES.PORTUGUESE_BRAZILIAN]
	
static func russian() -> Language:
	return available_languages[LANGUAGES.RUSSIAN]
	
static func chineseSimplified() -> Language:
	return available_languages[LANGUAGES.CHINESE_SIMPLIFIED]
	
static func chineseTraditional() -> Language:
	return available_languages[LANGUAGES.CHINESE_TRADITIONAL]
	
static func norwegianBokmal() -> Language:
	return available_languages[LANGUAGES.NORWEGIAN_BOKMAL]
	
static func hungarian() -> Language:
	return available_languages[LANGUAGES.HUNGARIAN]
	
static func romanian() -> Language:
	return available_languages[LANGUAGES.ROMANIAN]
	
static func korean() -> Language:
	return available_languages[LANGUAGES.KOREAN]
	
static func turkish() -> Language:
	return available_languages[LANGUAGES.TURKISH]
	
static func kapanese() -> Language:
	return available_languages[LANGUAGES.JAPANESE]
	
static func ukrainian() -> Language:
	return available_languages[LANGUAGES.UKRAINIAN]

#endregion
