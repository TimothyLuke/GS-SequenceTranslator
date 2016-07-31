local GNOME, language = ...
local locale = GetLocale();


function GSTRisempty(s)
  return s == nil or s == ''
end

function GSTRListCachedLanguages()
  t = {}
  i = 1
  for name, _ in pairs(language[GSTRStaticKey]) do
    t[i] = name
    GSPrintDebugMessage("found " .. name, GNOME)
    i = i + 1
  end
  return t
end

function GSTranslateSequence(sequence)

  if not GSTRisempty(sequence) then
    if (GSTRisempty(sequence.lang) and "enUS" or sequence.lang) ~= locale then
      --GSPrintDebugMessage((GSTRisempty(sequence.lang) and "enUS" or sequence.lang) .. " ~=" .. locale, GNOME)
      return GSTranslateSequenceFromTo(sequence, (GSTRisempty(sequence.lang) and "enUS" or sequence.lang), locale)
    else
      GSPrintDebugMessage((GSTRisempty(sequence.lang) and "enUS" or sequence.lang) .. " ==" .. locale, GNOME)
      return sequence
    end
  end
end

function GSTranslateSequenceFromTo(sequence, fromLocale, toLocale)
  GSPrintDebugMessage("GSTranslateSequenceFromTo  From: " .. fromLocale .. " To: " .. toLocale, GNOME)
  local lines = table.concat(sequence,"\n")
  GSPrintDebugMessage("lines: " .. lines, GNOME)

  lines = GSTranslateString(lines, fromLocale, toLocale)
  if not GSTRisempty(sequence.PostMacro) then
    -- Translate PostMacro
    sequence.PostMacro = GSTranslateString(sequence.PostMacro, fromLocale, toLocale)
  end
  if not GSTRisempty(sequence.PreMacro) then
    -- Translate PostMacro
    sequence.PreMacro = GSTranslateString(sequence.PreMacro, fromLocale, toLocale)
  end
  for i, v in ipairs(sequence) do sequence[i] = nil end
  GSTRlines(sequence, lines)
  -- check for blanks
  for i, v in ipairs(sequence) do
    if v == "" then
      sequence[i] = nil
    end
  end
  sequence.lang = toLocale
  return sequence
end

function GSTranslateString(instring, fromLocale, toLocale)
  GSPrintDebugMessage("Entering GSTranslateString with : \n" .. instring .. "\n " .. fromLocale .. " " .. toLocale, GNOME)

  local output = ""
  local stringlines = GSTRSplitMeIntolines(instring)
  for _,v in ipairs(stringlines) do
    if not GSTRisempty(v) then
      for cmd, etc in gmatch(v or '', '/(%w+)%s+([^\n]+)') do
        GSPrintDebugMessage("cmd : \n" .. cmd .. " etc: " .. etc, GNOME)
        output = output .. "/" .. cmd .. " "
        if GSStaticCastCmds[strlower(cmd)] then
          etc = string.match(etc, "^%s*(.-)%s*$")
          if string.sub(etc, 1, 1) == "!" then
            etc = string.sub(etc, 2)
          end
          local foundspell, returnval = GSTRTranslateSpell(etc, fromLocale, toLocale)
          if foundspell then
            output = output  .. returnval .. "\n"
          else
            GSPrintDebugMessage("Did not find : " .. etc .. " in " .. fromLocale, GNOME)
            output = output  .. etc .. "\n"
          end
        -- check for cast Sequences
        elseif strlower(cmd) == "castsequence" then
          for _, w in ipairs(GSTRsplit(etc,",")) do
            w = string.match(w, "^%s*(.-)%s*$")
            if string.sub(w, 1, 1) == "!" then
              w = string.sub(w, 2)
            end
            local foundspell, returnval = GSTRTranslateSpell(w, fromLocale, toLocale)
            output = output ..  returnval
          end
          output = output .. "\n"
        else
          -- pass it through
          output = output  .. etc .. "\n"
        end
      end
    end
  end
  GSPrintDebugMessage("Exiting GSTranslateString with : \n" .. output, GNOME)
  return output
end

function GSTRTranslateSpell(str, fromLocale, toLocale)
  local output = ""
  local found = false
  -- check for cases like /cast [talent:7/1] Bladestorm;[talent:7/3] Dragon Roar
  if string.match(str, ";") then
    for _, w in ipairs(GSTRsplit(str,";")) do
      found, returnval = GSTRTranslateSpell(string.match(w, "^%s*(.-)%s*$"), fromLocale, toLocale)
      output = output .. returnval .. ";"
    end
  else
    local conditionals, mods, etc = GSTRGetConditionalsFromString(str)
    if conditionals then
      output = output .. mods .. " "
    end
    GSPrintDebugMessage("output: " .. output .. " mods: " .. mods .. " etc: " .. etc, GNOME)
    local foundspell = language[GSTRStaticHash][fromLocale][string.match(etc, "^%s*(.-)%s*$")]
    if foundspell then
      GSPrintDebugMessage("Translating Spell ID : " .. foundspell .. " to " .. language[GSTRStaticKey][toLocale][foundspell], GNOME)
      output = output  .. language[GSTRStaticKey][toLocale][foundspell]
      found = true
    else
      GSPrintDebugMessage("Did not find : " .. etc .. " in " .. fromLocale, GNOME)
      output = output  .. etc
    end
  end
  return found, output
end

function GSTRSplitMeIntolines(str)
  GSPrintDebugMessage("Entering GSTRSplitMeIntolines with : \n" .. str, GNOME)
  local t = {}
  local function helper(line)
    table.insert(t, line)
    GSPrintDebugMessage("Line : " .. line, GNOME)
    return ""
  end
  helper((str:gsub("(.-)\r?\n", helper)))
  return t
end

function GSTRGetConditionalsFromString(str)
  GSPrintDebugMessage("Entering GSTRGetConditionalsFromString with : " .. str, GNOME)
  local found = false
  local mods = ""
  local leftstr
  local rightstr
  local leftfound = false
  for i = 1, #str do
    local c = str:sub(i,i)
    if c == "[" and not leftfound then
      leftfound = true
      leftstr = i
    end
    if c == "]" then
      rightstr = i
    end
  end
  GSPrintDebugMessage("checking left : " .. (leftstr and leftstr or "nope"), GNOME)
  GSPrintDebugMessage("checking right : " .. (rightstr and rightstr or "nope"), GNOME)
  if rightstr and leftstr then
     found = true
     GSPrintDebugMessage("We have left and right stuff", GNOME)
     mods = string.sub(str, leftstr, rightstr)
     GSPrintDebugMessage("mods changed to: " .. mods, GNOME)
     str = string.sub(str, rightstr + 1)
     GSPrintDebugMessage("str changed to: " .. str, GNOME)
  end
  return found, mods, str
end

function GSTranslateGetLocaleSpellNameTable()
  local spelltable = {}
  local hashtable = {}
  for k,v in pairs(language[GSTRStaticKey]["enUS"]) do
      --print(k)
      local spellname = GetSpellInfo(k)
      spelltable[k] = spellname
      hashtable[spellname] = k
  end
  return spelltable, hashtable
end

function GSTRlines(tab, str)
  local function helper(line) table.insert(tab, line) return "" end
  helper((str:gsub("(.-)\r?\n", helper)))
end


if GSTRisempty(GSTRListCachedLanguages()[locale]) then
  -- Load the current locale into the language SetAttribute
  if GSCore then
    GSPrintDebugMessage("Loading Spells for language " .. locale, GNOME)
  end
  language[GSTRStaticKey][locale], language[GSTRStaticHash][locale] = GSTranslateGetLocaleSpellNameTable()
end

function GSTRsplit(source, delimiters)
  local elements = {}
  local pattern = '([^'..delimiters..']+)'
  string.gsub(source, pattern, function(value) elements[#elements + 1] =     value;  end);
  return elements
end
