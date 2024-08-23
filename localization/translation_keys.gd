class_name TranslationKeys
	
static var NoTranslationKey := "GENERAL_NO";
static var YesTranslationKey := "GENERAL_YES";

static var AudioTabTranslationKey := "AUDIO_TAB";
static var ScreenTabTranslationKey := "SCREEN_TAB";
static var GraphicsTabTranslationKey := "GRAPHICS_TAB";
static var GeneralTabTranslationKey:= "GENERAL_TAB";
static var ControlsTabTranslationKey := "CONTROLS_TAB";

static var DeuteranopiaTranslationKey := "DALTONISM_DEUTERANOPIA";
static var ProtanopiaTranslationKey := "DALTONISM_PROTANOPIA";
static var TritanopiaTranslationKey := "DALTONISM_TRITANOPIA";
static var AchromatopsiaTranslationKey := "DALTONISM_ACHROMATOPSIA";
static var DaltonismKeys: Dictionary = {
	ViewportHelper.DaltonismTypes.No: NoTranslationKey,
	ViewportHelper.DaltonismTypes.Protanopia: ProtanopiaTranslationKey,
	ViewportHelper.DaltonismTypes.Deuteranopia: DeuteranopiaTranslationKey,
	ViewportHelper.DaltonismTypes.Tritanopia: TritanopiaTranslationKey,
	ViewportHelper.DaltonismTypes.Achromatopsia: AchromatopsiaTranslationKey,
	
}


static var GraphicsQualityTranslationKey := "GRAPHICS_QUALITY";

static var QualityLowTranslationKey := "QUALITY_LOW";
static var QualityMediumTranslationKey := "QUALITY_MEDIUM";
static var QualityHighTranslationKey := "QUALITY_HIGH";
static var QualityUltraTranslationKey := "QUALITY_ULTRA";
static var QualityPresetKeys: Dictionary = {
	HardwareDetector.QualityPreset.Low: QualityLowTranslationKey,
	HardwareDetector.QualityPreset.Medium: QualityMediumTranslationKey,
	HardwareDetector.QualityPreset.High: QualityHighTranslationKey,
	HardwareDetector.QualityPreset.Ultra: QualityUltraTranslationKey,
}
