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


enum Languages {
	English,
	Czech,
	Danish,
	Dutch,
	German,
	Greek,
	Esperanto,
	Spanish,
	French,
	Indonesian,
	Italian,
	Latvian,
	Polish,
	PortugueseBrazilian,
	Portuguese,
	Russian,
	ChineseSimplified,
	ChineseTraditional,
	NorwegianBokmal,
	Hungarian,
	Romanian,
	Korean,
	Turkish,
	Japanese,
	Ukrainian
}

static var available_languages: Dictionary = {
	Languages.English: Language.new("en", "en_US", "English", "English"),
	Languages.French: Language.new("fr", "fr_FR", "Français", "French"),
	Languages.Czech: Language.new("cs", "cs_CZ", "Czech", "Czech"),
	Languages.Danish: Language.new("da", "da_DK", "Dansk", "Danish"),
	Languages.Dutch: Language.new("nl", "nl_NL", "Nederlands", "Dutch"),
	Languages.German: Language.new("de", "de_DE", "Deutsch", "German"),
	Languages.Greek: Language.new("el", "el_GR", "Ελληνικά", "Greek"),
	Languages.Esperanto: Language.new("eo", "eo_UY", "Esperanto", "Esperanto"),
	Languages.Spanish: Language.new("es", "es_ES", "Español", "Spanish"),
	Languages.Indonesian: Language.new("id", "id_ID", "Indonesian", "Indonesian"),
	Languages.Italian: Language.new("it", "it_IT", "Italiano", "Italian"),
	Languages.Latvian: Language.new("lv", "lv_LV", "Latvian", "Latvian"),
	Languages.Polish: Language.new("pl", "pl_PL", "Polski", "Polish"),
	Languages.PortugueseBrazilian: Language.new("pt_BR", "pt_BR", "Português Brasileiro", "Brazilian Portuguese"),
	Languages.Portuguese: Language.new("pt", "pt_PT", "Português", "Portuguese"),
	Languages.Russian: Language.new("ru", "ru_RU", "Русский", "Russian"),
	Languages.ChineseSimplified: Language.new("zh_CN", "zh_CN", "简体中文", "Chinese Simplified"),
	Languages.ChineseTraditional: Language.new("zh_TW", "zh_TW", "繁體中文", "Chinese Traditional"),
	Languages.NorwegianBokmal: Language.new("nb", "nb_NO", "Norsk Bokmål", "Norwegian Bokmål"),
	Languages.Hungarian: Language.new("hu", "hu_HU", "Magyar", "Hungarian"),
	Languages.Romanian: Language.new("ro", "ro_RO", "Română", "Romanian"),
	Languages.Korean: Language.new("ko", "ko_KR", "한국어", "Korean"),
	Languages.Turkish: Language.new("tr", "tr_TR", "Türkçe", "Turkish"),
	Languages.Japanese: Language.new("ja", "ja_JP", "日本語", "Japanese"),
	Languages.Ukrainian: Language.new("uk", "uk_UA", "Українська", "Ukrainian"),
} 

#region Language shorcuts
static func english() -> Language:
	return available_languages[Languages.English]
	
static func french() -> Language:
	return available_languages[Languages.French]
	
static func czech() -> Language:
	return available_languages[Languages.Czech]
	
static func danish() -> Language:
	return available_languages[Languages.Danish]
	
static func dutch() -> Language:
	return available_languages[Languages.Dutch]
	
static func german() -> Language:
	return available_languages[Languages.German]
	
static func greek() -> Language:
	return available_languages[Languages.Greek]
	
static func esperanto() -> Language:
	return available_languages[Languages.Esperanto]
	
static func spanish() -> Language:
	return available_languages[Languages.Spanish]
	
static func indonesian() -> Language:
	return available_languages[Languages.Indonesian]
	
static func italian() -> Language:
	return available_languages[Languages.Italian]
	
static func latvian() -> Language:
	return available_languages[Languages.Latvian]
	
static func polish() -> Language:
	return available_languages[Languages.Polish]
	
static func portuguese_brazilian() -> Language:
	return available_languages[Languages.PortugueseBrazilian]

static func portuguese() -> Language:
	return available_languages[Languages.Portuguese]
	
static func russian() -> Language:
	return available_languages[Languages.Russian]
	
static func chinese_simplified() -> Language:
	return available_languages[Languages.ChineseSimplified]
	
static func chinese_traditional() -> Language:
	return available_languages[Languages.ChineseTraditional]
	
static func norwegian_bokmal() -> Language:
	return available_languages[Languages.NorwegianBokmal]
	
static func hungarian() -> Language:
	return available_languages[Languages.Hungarian]
	
static func romanian() -> Language:
	return available_languages[Languages.Romanian]
	
static func korean() -> Language:
	return available_languages[Languages.Korean]
	
static func turkish() -> Language:
	return available_languages[Languages.Turkish]
	
static func japanese() -> Language:
	return available_languages[Languages.Japanese]
	
static func ukrainian() -> Language:
	return available_languages[Languages.Ukrainian]

#endregion
