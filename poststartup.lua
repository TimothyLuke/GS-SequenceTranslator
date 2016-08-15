local GNOME, language = ...

local function TableConcat(t1,t2)
    local returntab = t1
    for k,v in pairs(t2) do
      --print ("k " .. k)
      --print ("v " .. v)

        for j, x in pairs(v) do
          --print ("j " .. j)
          --print ("x " .. x)
          returntab[k][j] = x
        end
    end
    return returntab
end

--TempLanguage = language

--GSAvailableLanguages = TableConcat(GSAvailableLanguages, language)
GSAdditionalLanguagesAvailable = true

if GSCore then
  GSPrintDebugMessage("Translator Initialised and Global GSTranslatorAvailable marked as True", GNOME)
end
