BUILDING   = require('../dictionary/building.json')
CASUSBELLI = require('../dictionary/casus_belli.json')
CONDITION  = require('../dictionary/condition.json')
CULTURE    = require('../dictionary/culture.json')
DECISION   = require('../dictionary/decision.json')
GENERAL    = require('../dictionary/general.json')
GOVERNMENT = require('../dictionary/government.json')
MODIFIER   = require('../dictionary/modifier.json')
OBJECTIVE  = require('../dictionary/objective.json')
RELIGION   = require('../dictionary/religion.json')
SCOPE      = require('../dictionary/scope.json')
TRAIT      = require('../dictionary/trait.json')
WIKIURL    = 'https://ck2.paradoxwikis.com/'


# mode
# 0...keywords
# 1...locations
# 2...descriptions
# 3...descriptions (locations)
#
# block
# 0...simple
# 1...followed an equal
# 2...followed branckets


module.exports =

  selector: '.source.eu4'
  disableForSelector: '.source.eu4 .comment'


  getSuggestions: ({editor, bufferPosition, scopeDescriptor, prefix}) ->

    completions = []
    completions = @searchText(0, prefix, completions, GENERAL   , ''           , '')
    completions = @searchText(0, prefix, completions, BUILDING  , 'building'   , 'Building_modding')
    completions = @searchText(0, prefix, completions, CASUSBELLI, 'casus belli', 'Casus_Belli_modding')
    completions = @searchText(0, prefix, completions, CONDITION , 'condition'  , 'Conditions')
    completions = @searchText(0, prefix, completions, CULTURE   , 'culture'    , 'Culture_modding')
    completions = @searchText(0, prefix, completions, DECISION  , 'decision'   , 'Decision_modding#Targeted_decisions')
    completions = @searchText(0, prefix, completions, GOVERNMENT, 'government' , 'Government_modding')
    completions = @searchText(0, prefix, completions, MODIFIER  , 'modifier'   , 'Modifiers')
    completions = @searchText(0, prefix, completions, OBJECTIVE , 'objective'  , 'Objective_modding')
    completions = @searchText(0, prefix, completions, RELIGION  , 'religion'   , 'Religion_modding')
    completions = @searchText(0, prefix, completions, SCOPE     , 'scope'      , 'Scopes')
    completions = @searchText(0, prefix, completions, TRAIT     , 'trait'      , 'Trait_modding')

#   if atom.config.get('autocomplete-eu4.includeloc') < 2
#     Proper names such as locations will be here.

    if atom.config.get('autocomplete-eu4.includedesc')

      completions = @searchText(2, prefix, completions, GENERAL   , ''           , '')
      completions = @searchText(2, prefix, completions, BUILDING  , 'building'   , 'Building_modding')
      completions = @searchText(2, prefix, completions, CASUSBELLI, 'casus belli', 'Casus_Belli_modding')
      completions = @searchText(2, prefix, completions, CONDITION , 'condition'  , 'Conditions')
      completions = @searchText(2, prefix, completions, CULTURE   , 'culture'    , 'Culture_modding')
      completions = @searchText(2, prefix, completions, DECISION  , 'decision'   , 'Decision_modding#Targeted_decisions')
      completions = @searchText(2, prefix, completions, GOVERNMENT, 'government' , 'Government_modding')
      completions = @searchText(2, prefix, completions, MODIFIER  , 'modifier'   , 'Modifiers')
      completions = @searchText(2, prefix, completions, OBJECTIVE , 'objective'  , 'Objective_modding')
      completions = @searchText(2, prefix, completions, RELIGION  , 'religion'   , 'Religion_modding')
      completions = @searchText(2, prefix, completions, SCOPE     , 'scope'      , 'Scopes')
      completions = @searchText(2, prefix, completions, TRAIT     , 'trait'      , 'Trait_modding')

#     if atom.config.get('autocomplete-eu4.includeloc') < 2
#       Proper names such as locations will be here.

    completions.sort(@compareCompletions)

    completions


  searchText: (mode, prefix, completions, dictionary, label, url) ->

    if prefix
      completions = @searchBlock(mode, 0, prefix, completions, dictionary.simple, label, url)
      completions = @searchBlock(mode, 1, prefix, completions, dictionary.equal , label, url)
      if mode == 1 or mode == 3
        if atom.config.get('autocomplete-eu4.includeloc') == 0
          completions = @searchBlock(mode, 2, prefix, completions, dictionary.simple, label, url)
      else
        completions = @searchBlock(mode, 2, prefix, completions, dictionary.bracket, label, url)

    completions


  searchBlock: (mode, block, prefix, completions, dictionary, label, url) ->

    bracket = atom.config.get('autocomplete-eu4.bracket')
    needle  = prefix.toLowerCase().replace('_', '').replace(' ', '')
    regex   = new RegExp(needle)

    for index, entry of dictionary

      if (not entry.displayText) or (mode >= 2 and not entry.description)
        continue

      if mode < 2
        haystack = entry.displayText
      else
        haystack = entry.description

      haystack = haystack.toLowerCase().replace('_', '').replace(' ', '')

      if regex.test(haystack)

        repeat = false
        if mode >= 2
          for index2, entry2 of completions when (entry.displayText is entry2.displayText) and (block == entry2.block)
            repeat = true
            break
        if repeat
          continue

        disp    = entry.displayText
        desc    = entry.description
        descurl = WIKIURL + url
        right   = label
        pos     = haystack.indexOf(needle)

        switch mode

          when 0
            type = 'snippet'
            icon = 'icon-move-right'

          when 1
            type = 'function'
            icon = 'icon-location'

          when 2
            type = 'class'
            icon = 'icon-search'

          when 3
            type = 'function'
            icon = 'icon-search'

        switch block

          when 0
            snippet = entry.text

          when 1
            snippet = entry.text + ' = '

          when 2
            switch bracket

              when 0
                snippet = entry.text + ' = { $1 }$2'
                left = 'single'
                completions = @createCompletion(mode, block, completions, snippet, disp, type, left, right, icon, desc, descurl, pos)
                snippet = entry.text + ' = {\n\t$1\n}'
                left = 'multi'

              when 1
                snippet = entry.text + ' = { $1 }$2'
                if mode == 1 or mode == 3
                  left = 'clause'

              when 2
                snippet = entry.text + ' = {\n\t$1\n}'
                if mode == 1 or mode == 3
                  left = 'clause'

        completions = @createCompletion(mode, block, completions, snippet, disp, type, left, right, icon, desc, descurl, pos)

    completions


  createCompletion: (mode, block, completions, snippet, disp, type, left, right, icon, desc, descurl, pos) ->

    completion =
      snippet: snippet
      displayText: disp
      type: type
      leftLabel: left
      rightLabel: right
      iconHTML: '<i class=\"' + icon + '\"></i>'
      description: desc
      descriptionMoreURL: descurl
      mode: mode
      block: block
      pos: pos
    completions.push(completion)

    completions


  compareCompletions: (a, b) ->
    comp = a.mode - b.mode
    if comp == 0 and a.mode < 2
      comp = a.pos - b.pos
    if comp == 0
      texta = a.displayText
      textb = b.displayText
      if ( texta > textb )
        comp =  1
      else if ( texta < textb )
        comp = -1
      else
        if not a.leftLabel
          labela = ''
        else
          labela = a.leftLabel
        if not b.leftLabel
          labelb = ''
        else
          labelb = b.leftLabel
        if ( labela > labelb )
          comp =  1
        else if ( labela < labelb )
          comp = -1
        else
          comp = 0
    comp
