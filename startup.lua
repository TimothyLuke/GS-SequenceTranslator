local GNOME, language = ...
GSAdditionalLanguagesAvailable = true
GSTRStaticKey = "KEY"
GSTRStaticHash = "HASH"
GSTRStaticShadow = "SHADOW"
GSTRUnfoundSpells = {}

if GSCore then
  GSPrintDebugMessage("Translator Initialised and Global GSTranslatorAvailable marked as True", GNOME)
end

language[GSTRStaticKey] = {}
language[GSTRStaticHash] = {}
language[GSTRStaticShadow] = {}
