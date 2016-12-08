local GSE = GSE
local Statics = GSE.Static

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
GSE.AdditionalLanguagesAvailable = true
