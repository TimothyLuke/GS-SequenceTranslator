local GNOME, language = ...

local function TableConcat(t1,t2)
    for k,v in ipairs(t2) do
        for j, x in ipairs(v) do
          t1[k][j] = x
        end
    end
    return t1
end

GSAvailableLanguages = TableConcat(GSAvailableLanguages, language)
