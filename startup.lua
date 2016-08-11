local GNOME, language = ...
GSTranslatorAvailable = true

GSTRStaticKey = "KEY"
GSTRStaticHash = "HASH"
GSTRStaticShadow = "SHADOW"
GSTRUnfoundSpells = {}

if not GSAvailableLanguages then
  GSAvailableLanguages = {}
  GSAvailableLanguages[GSTRStaticKey] = {}
  GSAvailableLanguages[GSTRStaticHash] = {}
  GSAvailableLanguages[GSTRStaticShadow] = {}
end

if GSCore then
  GSPrintDebugMessage("Translator Initialised and Global GSTranslatorAvailable marked as True", GNOME)
end

language[GSTRStaticKey] = {}
language[GSTRStaticHash] = {}
language[GSTRStaticShadow] = {}
