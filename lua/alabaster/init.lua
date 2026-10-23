local M = {}

local color = require("alabaster.color")

local function clear()
    vim.cmd("hi clear")
    if vim.fn.exists("syntax_on") == 1 then
        vim.cmd("syntax reset")
    end
end

local function apply(colors_name, theme)
    vim.g.colors_name = colors_name
    for group, hl in pairs(theme) do
        vim.api.nvim_set_hl(0, group, hl)
    end
end

local warned_background = false

-- Reads g:alabaster_background, returning a normalized "#RRGGBB" or nil.
local function custom_background()
    local raw = vim.g.alabaster_background
    if raw == nil or raw == "" then
        return nil
    end
    local bg = color.normalize(raw)
    if not bg then
        if not warned_background then
            warned_background = true
            vim.notify(
                "alabaster: invalid g:alabaster_background " .. vim.inspect(raw) .. " (expected #RRGGBB), using the default",
                vim.log.levels.WARN
            )
        end
        return nil
    end
    return bg
end

-- Blend toward black on light backgrounds, toward white on dark ones.
local function blend(bg, dark, dark_amount, light_amount)
    if dark then
        return color.tint(bg, dark_amount)
    end
    return color.shade(bg, light_amount)
end

local function paint(theme, groups, attrs)
    for _, group in ipairs(groups) do
        local hl = theme[group] or {}
        for key, value in pairs(attrs) do
            hl[key] = value
        end
        theme[group] = hl
    end
end

-- Re-derives the neutral UI surfaces from a custom background.
local function retint(theme, bg, dark)
    local subtle = blend(bg, dark, 0.06, 0.04)
    local statusline = blend(bg, dark, 0.09, 0.08)
    local visual = blend(bg, dark, 0.14, 0.12)
    local selection = blend(bg, dark, 0.18, 0.16)
    local border = blend(bg, dark, 0.22, 0.20)
    local scrollbar = blend(bg, dark, 0.12, 0.28)
    local thumb = blend(bg, dark, 0.40, 0.62)
    local nontext = blend(bg, dark, 0.45, 0.55)
    local linenr = blend(bg, dark, 0.40, 0.48)
    local overlay = blend(bg, dark, 0.05, 0.03)

    local fg = (theme.Normal or {}).fg or (dark and "#cecece" or "#000000")

    theme.Normal = { bg = bg, fg = fg }
    theme.NormalFloat = { bg = subtle }
    theme.FloatBorder = vim.g.alabaster_floatborder and { bg = bg, fg = border }
        or {
            bg = subtle,
            fg = subtle,
        }
    theme.WinBar = { bg = bg, fg = (theme.WinBar or {}).fg, bold = true }
    theme.WinBarNC = { bg = bg, fg = (theme.WinBarNC or {}).fg }
    theme.TermCursorNC = { fg = bg, bg = fg }
    theme.healthSuccess = { fg = (theme.healthSuccess or {}).fg, bg = bg }
    theme.ISwapSnipe = { bg = (theme.ISwapSnipe or {}).bg, fg = bg }

    paint(theme, { "ColorColumn", "CursorColumn", "CursorLine", "QuickFixLine", "Pmenu" }, { bg = subtle })
    paint(
        theme,
        {
            "StatusLine",
            "StatusLineNC",
            "TabLine",
            "TabLineFill",
            "TabLineSel",
            "StatuslineAdd",
            "StatuslineErr",
            "StatuslineHint",
            "StatuslineInfo",
            "StatuslineWarn",
            "StatuslineBlue",
            "StatuslineRed",
            "StatuslineGreen",
            "StatuslineCyan",
            "StatuslineMagenta",
        },
        { bg = statusline }
    )
    paint(theme, { "Visual", "VisualNOS" }, { bg = visual })
    paint(theme, { "PmenuSel", "WildMenu" }, { bg = selection })
    paint(theme, { "PmenuSbar" }, { bg = scrollbar })
    paint(theme, { "PmenuThumb" }, { bg = thumb })
    paint(theme, { "VertSplit", "EndOfBuffer", "TelescopeBorder", "FzfLuaBorder" }, { fg = border })
    paint(theme, { "NonText" }, { fg = nontext })
    paint(theme, { "LineNr" }, { fg = linenr })
    paint(theme, { "Folded" }, { bg = statusline })
    paint(theme, { "LspReferenceText", "LspReferenceRead", "LspReferenceWrite", "@text.note" }, { bg = overlay })

    if dark then
        paint(theme, { "Search" }, { bg = selection })
        paint(
            theme,
            { "SpecialComment", "TSStringRegex", "TSStringEscape", "@string.regex", "@string.escape", "debugPc" },
            { bg = overlay }
        )
    end
end


-- Terminal colors shared by the light variants (bg/mono) and the light base.
local function light_terminal_colors()
    vim.g.terminal_color_0 = "#000000"
    vim.g.terminal_color_1 = "#aa3731"
    vim.g.terminal_color_2 = "#448c27"
    vim.g.terminal_color_3 = "#cb9000"
    vim.g.terminal_color_4 = "#325cc0"
    vim.g.terminal_color_5 = "#7a3e9d"
    vim.g.terminal_color_6 = "#0083b2"
    vim.g.terminal_color_7 = "#f7f7f7"
    vim.g.terminal_color_8 = "#777777"
    vim.g.terminal_color_9 = "#f05050"
    vim.g.terminal_color_10 = "#60cb00"
    vim.g.terminal_color_11 = "#ffbc5d"
    vim.g.terminal_color_12 = "#007acc"
    vim.g.terminal_color_13 = "#e64ce6"
    vim.g.terminal_color_14 = "#00aacb"
    vim.g.terminal_color_15 = "#f7f7f7"
end

local function alabaster()
    clear()
    local custom = custom_background()
    local dark
    if custom then
        dark = color.is_dark(custom)
        vim.o.background = dark and "dark" or "light"
    else
        dark = vim.o.background == "dark"
    end
    if dark then
        -- terminal colors
        vim.g.terminal_color_0 = "#000000"
        vim.g.terminal_color_1 = "#d2322d"
        vim.g.terminal_color_2 = "#6abf40"
        vim.g.terminal_color_3 = "#cd974b"
        vim.g.terminal_color_4 = "#217EBC"
        vim.g.terminal_color_5 = "#9B3596"
        vim.g.terminal_color_6 = "#178F79"
        vim.g.terminal_color_7 = "#cecece"
        vim.g.terminal_color_8 = "#333333"
        vim.g.terminal_color_9 = "#c33c33"
        vim.g.terminal_color_10 = "#95cb82"
        vim.g.terminal_color_11 = "#dfdf8e"
        vim.g.terminal_color_12 = "#71aed7"
        vim.g.terminal_color_13 = "#cc8bc9"
        vim.g.terminal_color_14 = "#47BEA9"
        vim.g.terminal_color_15 = "#ffffff"

        -- colors
        local bg = custom or "#0e1415"
        local fg = "#cecece"
        local punct_fg = "#708b8d"
        local def_fg = "#71ade7"
        local const_fg = "#cc8bc9"
        local active = "#cd974b"
        local string_fg = "#95cb82"
        local darker_fg = "#7d7d7d"
        local diffadd = "#6abf40"
        local diffdelete = "#d2322d"
        local diffchange = "#ec8013"
        local statusline = "#162022"
        local comment = "#dfdf8e"
        local dim_comment = "#696969"
        local mistake = {
            fg = "#c33c33",
            bg = "#2b1d1e",
        }
        local error = "#d13e23"
        local warn = "#f4b371"
        local hint = "#8ebeec"
        local info = "#88cc66"
        local ansi = {
            black = "#333333",
            blue = "#71aed7",
            brightyellow = "#dfdf8e",
            cyan = "#47bea9",
            green = "#95cb82",
            magenta = "#cc8bc9",
            red = "#c33c33",
            white = "#cecece",
            yellow = "#cd974b",
        }
        local comment_fg = vim.g.alabaster_dim_comments and dim_comment or comment
        local pmenu_bg = "#182325"
        local float_bg = vim.g.alabaster_floatborder and bg or pmenu_bg
        local floatborder = vim.g.alabaster_floatborder and { bg = bg, fg = "#333333" }
            or {
                bg = float_bg,
                fg = float_bg,
            }
        local theme = {
            Comment = { fg = comment_fg },
            ColorColumn = { bg = "#182325" },
            Conceal = { fg = "#b0b0b0" },
            Cursor = { bg = active, fg = "#000000" },
            CursorColumn = { bg = "#182325" },
            CursorLine = { bg = "#182325" },
            Directory = { fg = ansi.blue },
            DiffAdd = { bg = "#244032", fg = "#56d364" },
            DiffDelete = { bg = "#462c32", fg = "#f85149" },
            DiffText = { fg = "#341a00", bg = "#fff987" },
            DiffChange = { bg = "#341a00", fg = "#e3b341" },
            EndOfBuffer = { fg = "#354c50" },
            TermCursorNC = { fg = bg, bg = fg },
            ErrorMsg = { fg = error, bg = mistake.bg },
            VertSplit = { fg = "#2b3d40" },
            Folded = { bg = "#182325", fg = "#7d7d7d" },
            FoldColumn = { bg = bg, fg = "#4d4d4d" },
            SignColumn = {},
            IncSearch = { bg = ansi.yellow, fg = bg },
            LineNr = { fg = "#5c5c5c" },
            CursorLineNr = { fg = ansi.blue, bold = 1 },
            MatchParen = { underline = 1, sp = active },
            MoreMsg = { fg = ansi.green, bold = 1 },
            NonText = { fg = "#696969" },
            Normal = { bg = bg, fg = fg },
            NormalFloat = { bg = float_bg },
            FloatBorder = floatborder,
            Pmenu = { bg = pmenu_bg },
            PmenuSel = { bg = "#354c50" },
            PmenuSbar = { bg = "#212f31" },
            PmenuThumb = { bg = "#47666b" },
            Question = { fg = diffadd },
            QuickFixLine = { bg = "#182325" },
            Search = { bg = "#354c50" },
            SpecialKey = { fg = ansi.cyan },
            SpellBad = { undercurl = 1, sp = ansi.red },
            SpellCap = { undercurl = 1, sp = ansi.blue },
            SpellLocal = { undercurl = 1, sp = ansi.cyan },
            SpellRare = { undercurl = 1, sp = ansi.magenta },
            StatusLine = { bg = statusline, fg = fg },
            StatusLineNC = { bg = statusline, fg = "#9f9f9f" },
            TabLine = { bg = statusline, fg = "#7d7d7d" },
            TabLineFill = { bg = statusline },
            TabLineSel = { bg = statusline, fg = ansi.blue },
            Title = { fg = const_fg },
            Visual = { bg = "#293334" },
            VisualNOS = { bg = "#293334" },
            WarningMsg = { fg = "#e1ad4c" },
            WildMenu = { bg = "#354c50" },
            WinBar = { bg = bg, fg = ansi.white, bold = true },
            WinBarNC = { bg = bg, fg = "#7d7d7d" },

            --- SYNTAX I: TS groups link to these
            Constant = { fg = const_fg },
            String = { fg = string_fg },
            Character = { fg = const_fg },
            Number = { fg = const_fg },
            Boolean = { fg = const_fg },
            Float = { fg = const_fg },
            Operator = { fg = punct_fg },

            --- SYNTAX II: TS groups have their own definition, the below are defined to have somewhat working hl w/o treesitter
            Identifier = { fg = ansi.white },
            Function = { fg = def_fg },
            Statement = { fg = ansi.white },
            Conditional = { fg = ansi.white },
            Repeat = { fg = ansi.white },
            Label = { fg = def_fg },
            Keyword = { fg = ansi.white },
            Exception = { fg = ansi.white },
            PreProc = { fg = ansi.white },
            Include = { fg = ansi.white },
            Define = { fg = ansi.white },
            Macro = { fg = ansi.white },
            PreCondit = { fg = ansi.white },
            Type = { fg = ansi.white },
            StorageClass = { fg = ansi.white },
            Structure = { fg = def_fg },
            Typedef = { fg = def_fg },

            Special = { fg = ansi.yellow },
            SpecialComment = { bg = "#1d292b", fg = ansi.blue },
            debugPc = { bg = "#0f2534" },
            debugBreakpoint = { bg = "#b33229" },
            helpHyperTextJump = { fg = ansi.magenta },
            helpSectionDelim = { fg = ansi.magenta },
            helpExample = { fg = ansi.cyan },
            helpCommand = { fg = ansi.cyan },
            helpHeadline = { fg = ansi.blue },
            helpHeader = { fg = ansi.magenta },

            Underlined = { underline = 1 },
            Italic = { italic = 1 },

            Error = { bg = mistake.bg, fg = mistake.fg },

            Todo = { bg = "#d0d058", fg = bg },

            --- Diagnostic
            LspReferenceText = { bg = "#253437" },
            LspReferenceRead = { bg = "#253437" },
            LspReferenceWrite = { bg = "#253437", underline = 1, sp = active },
            LspCodeLens = { fg = "#5c5c5c" },
            LspCodeLensSeparator = { fg = "#5c5c5c" },

            --- Diagnostic
            DiagnosticError = { fg = error },
            DiagnosticWarn = { fg = warn },
            DiagnosticHint = { fg = hint },
            DiagnosticInfo = { fg = info },
            DiagnosticVirtualTextError = { bg = "#350B0B", fg = "#D1503A" },
            DiagnosticVirtualTextWarn = { bg = "#3F240A", fg = "#C8935D" },
            DiagnosticVirtualTextHint = { bg = "#1D2B37", fg = "#7E9CB9" },
            DiagnosticVirtualTextInfo = { bg = "#162C0B", fg = "#7BAC62" },

            --- Treesitter
            TSAttribute = {},
            TSConstructor = { fg = ansi.white },
            TSConditional = { fg = ansi.white },
            TSConstBuiltin = { fg = const_fg },
            TSConstMacro = { fg = ansi.white },
            TSError = { bg = mistake.bg, fg = mistake.fg },
            TSException = { fg = ansi.white },
            TSField = { fg = ansi.white },
            TSFunction = { fg = ansi.white },
            TSFuncBuiltin = { fg = ansi.white },
            TSFuncMacro = { fg = ansi.white },
            TSKeyword = { fg = ansi.white },
            TSKeywordFunction = { fg = ansi.white },
            TSLabel = { fg = ansi.white },
            TSMethod = { fg = ansi.white },
            TSNamespace = { fg = ansi.white },
            TSNone = { fg = const_fg },
            TSParameter = { fg = ansi.white },
            TSParameterReference = { fg = ansi.white },
            TSProperty = { fg = ansi.white },
            TSPunctDelimiter = { fg = punct_fg },
            TSPunctBracket = { fg = "#bababa" },
            TSPunctSpecial = { fg = punct_fg },
            TSRepeat = { fg = ansi.white },
            TSString = { fg = string_fg },
            TSStringRegex = { bg = "#1d292b", fg = const_fg },
            TSStringEscape = { bg = "#1d292b", fg = const_fg },
            TSSymbol = {},
            TSType = { fg = ansi.white },
            TSTypeBuiltin = { fg = ansi.white },
            TSVariable = { fg = ansi.white },
            TSVariableBuiltin = { fg = ansi.white },
            TSTag = { fg = ansi.white },
            TSTagDelimiter = { fg = punct_fg },
            TSText = { fg = ansi.white },
            ["@attribute"] = {},
            ["@constructor"] = { fg = ansi.white },
            ["@conditional"] = { fg = ansi.white },
            ["@constant.builtin"] = { fg = const_fg },
            ["@constant.macro"] = { fg = ansi.white },
            ["@error"] = { bg = mistake.bg, fg = mistake.fg },
            ["@exception"] = { fg = ansi.white },
            ["@field"] = { fg = ansi.white },
            ["@function"] = { fg = ansi.white },
            ["@function.builtin"] = { fg = ansi.white },
            ["@function.macro"] = { fg = ansi.white },
            ["@keyword"] = { fg = ansi.white },
            ["@keyword.function"] = { fg = ansi.white },
            ["@keyword.operator"] = { fg = punct_fg },
            ["@label"] = { fg = ansi.white },
            ["@method"] = { fg = ansi.white },
            ["@module"] = { fg = ansi.white },
            ["@namespace"] = { fg = ansi.white },
            ["@none"] = { fg = const_fg },
            ["@parameter"] = { fg = ansi.white },
            ["@parameter.reference"] = { fg = ansi.white },
            ["@property"] = { fg = ansi.white },
            ["@punctuation.delimiter"] = { fg = punct_fg },
            ["@punctuation.bracket"] = { fg = "#bababa" },
            ["@punctuation.special"] = { fg = punct_fg },
            ["@repeat"] = { fg = ansi.white },
            ["@string"] = { fg = string_fg },
            ["@string.regex"] = { bg = "#1d292b", fg = const_fg },
            ["@string.escape"] = { bg = "#1d292b", fg = const_fg },
            ["@symbol"] = {},
            ["@type"] = { fg = ansi.white },
            ["@type.builtin"] = { fg = ansi.white },
            ["@variable"] = { fg = ansi.white },
            ["@variable.builtin"] = { fg = ansi.white },
            ["@tag"] = { fg = ansi.white },
            ["@tag.delimiter"] = { fg = punct_fg },
            ["@text"] = { fg = ansi.white },
            ["@text.note"] = { bg = "#1d292b", fg = ansi.blue },
            ["@text.warning"] = { bg = "#d0d058", fg = bg },

            --- Theme specific
            ["@AlabasterBase"] = { fg = ansi.white },
            ["@AlabasterConstant"] = { fg = const_fg },
            ["@AlabasterDefinition"] = { fg = def_fg },
            ["@AlabasterPunct"] = { fg = punct_fg },
            ["@AlabasterString"] = { fg = string_fg },
            ["@AlabasterHashbang"] = { fg = dim_comment },
            --- Gitsigns
            GitSignsAdd = { fg = diffadd },
            GitSignsChange = { fg = diffchange },
            GitSignsDelete = { fg = diffdelete },
            --- Telescope
            TelescopeBorder = { fg = "#2b3d40" },
            TelescopeMatching = { fg = "#f09942" },
            TelescopeMultiSelection = { fg = ansi.magenta },
            TelescopePromptPrefix = { fg = ansi.blue },
            TelescopeSelectionCaret = { fg = mistake.fg },
            TelescopeTitle = { fg = ansi.brightyellow },
            TelescopeResultsTitle = { fg = ansi.yellow },
            --- fzf-lua
            FzfLuaBorder = { fg = "#2b3d40" },
            --- mini.nvim
            MiniPickMatchCurrent  = { fg = "#f09942" },
            --- Neogit
            NeogitPopupActionDisabled = { fg = darker_fg },
            NeogitPopupActionKey = { fg = ansi.magenta },
            NeogitPopupOptionDisabled = { fg = darker_fg },
            NeogitPopupOptionKey = { fg = ansi.blue },
            NeogitPopupSwitchDisabled = { fg = darker_fg },
            NeogitPopupSwitchEnabled = { fg = ansi.cyan },
            NeogitPopupSwitchKey = { fg = ansi.magenta },
            --- Fugitive
            diffAdded = { link = "DiffAdd" },
            diffRemoved = { link = "DiffDelete" },
            --- Startify
            StartifyBracket = { fg = darker_fg },
            StartifyFile = { fg = ansi.white },
            StartifySection = { fg = ansi.green },
            StartifySlash = { fg = "#4e6e75" },
            StartifyPath = { fg = "#4e6e75" },
            --- Statusline
            StatuslineAdd = { fg = diffadd, bg = statusline },
            StatuslineErr = { fg = error, bg = statusline },
            StatuslineHint = { fg = hint, bg = statusline },
            StatuslineInfo = { fg = info, bg = statusline },
            StatuslineWarn = { fg = warn, bg = statusline },
            StatuslineBlue = { fg = ansi.blue, bg = statusline },
            StatuslineRed = { fg = ansi.red, bg = statusline },
            StatuslineGreen = { fg = ansi.green, bg = statusline },
            StatuslineCyan = { fg = ansi.cyan, bg = statusline },
            StatuslineMagenta = { fg = ansi.magenta, bg = statusline },
            --- ALE
            ALEWarningSign = { fg = warn },
            --- vim-matchup
            MatchupVirtualText = { fg = ansi.yellow },
            --- For `highlight link`
            AlabasterBlack = { fg = ansi.black },
            AlabasterBlue = { fg = ansi.blue },
            AlabasterBrightYellow = { fg = ansi.brightyellow },
            AlabasterCyan = { fg = ansi.cyan },
            AlabasterGreen = { fg = ansi.green },
            AlabasterDarkGreen = { fg = "#6abf40" },
            AlabasterMagenta = { fg = ansi.magenta },
            AlabasterRed = { fg = ansi.red },
            AlabasterWhite = { fg = ansi.white },
            AlabasterYellow = { fg = ansi.yellow },
            --- Hop
            HopNextKey = { fg = ansi.brightyellow },
            HopNextKey1 = { fg = ansi.cyan },
            HopNextKey2 = { fg = "#297567" },
            HopUnmatched = { fg = "#3d3d3d" },
            --- Lightspeed
            LightspeedGreyWash = { fg = "#3d3d3d" },
            --- checkhealth
            healthSuccess = { fg = ansi.green, bg = bg },
            --- cmp
            CmpItemMenuDefault = { fg = ansi.magenta },
            --- nvim-ts-rainbow
            rainbowcol1 = { fg = ansi.yellow },
            rainbowcol2 = { fg = ansi.magenta },
            rainbowcol3 = { fg = ansi.blue },
            rainbowcol4 = { fg = ansi.green },
            rainbowcol5 = { fg = ansi.brightyellow },
            rainbowcol6 = { fg = ansi.red },
            rainbowcol7 = { fg = ansi.cyan },
            --- Iswap
            ISwapSnipe = { bg = ansi.yellow, fg = bg },
            ISwapGrey = { fg = "#3d3d3d" },
            --- vim-dadbod-ui
            dbui_help = { fg = dim_comment },
            dbui_connection_source = { fg = dim_comment },
            --- nvim-dap-virtual-text
            NvimDapVirtualText = { bg = "#1d292b", fg = ansi.cyan },
            --- Noice
            NoiceCmdlineIcon = { link = "AlabasterDarkGreen" },
            NoiceCmdlinePopupBorder = { link = "AlabasterDarkGreen" },
            NoiceConfirmBorder = { link = "AlabasterDarkGreen" },
            NoiceCmdlinePopupBorderCmdline = { link = "AlabasterDarkGreen" },
            NoiceCmdlineIconCmdline = { link = "AlabasterDarkGreen" },
            NoiceCmdlinePopupBorderFilter = { link = "AlabasterDarkGreen" },
            NoiceCmdlineIconFilter = { link = "AlabasterDarkGreen" },
            NoiceCmdlinePopupBorderLua = { link = "AlabasterDarkGreen" },
            NoiceCmdlineIconLua = { link = "AlabasterDarkGreen" },
            NoiceCmdlinePopupBorderSearch = { link = "AlabasterYellow" },
            NoiceCmdlineIconSearch = { link = "AlabasterYellow" },
            -- Languages
            --- asm
            asmDirective = { fg = dim_comment },
            nasmLabel = { link = "@AlabasterDefinition" },

            ["@lsp.mod.declaration"] = { fg = fg },
            ["@lsp.type.enumMember"] = { fg = fg },
            ["@lsp.type.function"] = { fg = fg },
            ["@lsp.type.method"] = { fg = fg },
            ["@lsp.type.selfKeyword"] = { fg = fg },
            ["@lsp.typemod.class.declaration"] = { fg = def_fg },
            ["@lsp.typemod.class.definition"] = { fg = def_fg },
            ["@lsp.typemod.enum.declaration"] = { fg = def_fg },
            ["@lsp.typemod.enumMember.defaultLibrary"] = { fg = fg },
            ["@lsp.typemod.function.declaration"] = { fg = def_fg },
            ["@lsp.typemod.function.definition"] = { fg = def_fg },
            ["@lsp.typemod.macro.declaration"] = { fg = def_fg },
            ["@lsp.typemod.method.declaration"] = { fg = def_fg },
            ["@lsp.typemod.selfKeyword"] = { fg = fg },
            ["@lsp.typemod.struct.declaration"] = { fg = def_fg },
            ["@lsp.typemod.type.declaration"] = { fg = def_fg },
        }
        if custom then
            retint(theme, custom, true)
        end
        apply("alabaster", theme)
    else
        light_terminal_colors()

        -- colors
        local bg = custom or "#f7f7f7"
        local fg = "#000000"
        local punct_fg = "#777777"
        local def_fg = "#325cc0"
        local const_fg = "#7a3e9d"
        local active = "#ffbc5d"
        local active_blue = "#007acc"
        local string_fg = "#448c27"
        local darker_fg = "#7d7d7d"
        local diffadd = "#284918"
        local diffdelete = "#B40600"
        local diffchange = "#ec8013"
        local statusline = "#c9c9c9"
        local comment = "#aa3731"
        local dim_comment = "#696969"
        local mistake = {
            fg = "#c33c33",
            bg = "#f8b28f",
        }
        local ansi = {
            black = "#000000",
            blue = "#325cc0",
            brightyellow = "#ffbc5d",
            cyan = "#0083b2",
            green = "#448c27",
            magenta = "#7a3e9d",
            red = "#aa3731",
            white = "#f7f7f7",
            yellow = "#cb9000",
        }
        local error = "#d13e23"
        local warn = "#BC7500"
        local hint = ansi.blue
        local info = "#278C00"
        local comment_fg = vim.g.alabaster_dim_comments and dim_comment or comment
        local pmenu_bg = "#e7e7e7"
        local float_bg = vim.g.alabaster_floatborder and bg or pmenu_bg
        local floatborder = vim.g.alabaster_floatborder and { bg = bg, fg = "#999999" }
            or {
                bg = float_bg,
                fg = float_bg,
            }
        local theme = {
            Comment = { fg = comment_fg },
            ColorColumn = { bg = "#E2EEEE" },
            Conceal = { fg = "#b0b0b0" },
            Cursor = { bg = "#007acc", fg = "#bfdbfe" },
            CursorColumn = { bg = "#E2EEEE" },
            CursorLine = { bg = "#E2EEEE" },
            Directory = { fg = ansi.blue },
            DiffAdd = { bg = "#ADFFB7", fg = "#0A7816" },
            DiffDelete = { bg = "#F8B28F", fg = "#872C28" },
            DiffText = { fg = "#fff987", bg = "#876004" },
            DiffChange = { bg = "#fff987", fg = "#341a00" },
            EndOfBuffer = { fg = "#b6b6b6" },
            TermCursorNC = { fg = bg, bg = fg },
            ErrorMsg = { fg = error, bg = mistake.bg },
            VertSplit = { fg = "#abbdc0" },
            Folded = { bg = "#dddddd", fg = "#7d7d7d" },
            FoldColumn = { bg = bg, fg = "#4d4d4d" },
            SignColumn = {},
            IncSearch = { bg = active, fg = fg },
            LineNr = { fg = "#7d7c7c" },
            CursorLineNr = { fg = ansi.blue, bold = 1 },
            MatchParen = { underline = 1, sp = active },
            MoreMsg = { fg = ansi.green, bold = 1 },
            NonText = { fg = "#696969" },
            Normal = { bg = bg, fg = fg },
            NormalFloat = { bg = float_bg },
            FloatBorder = floatborder,
            Pmenu = { bg = pmenu_bg },
            PmenuSel = { bg = "#c7c7c7" },
            PmenuSbar = { bg = "#777777" },
            PmenuThumb = { bg = "#333333" },
            Question = { fg = ansi.green },
            QuickFixLine = { bg = "#E2EEEE" },
            Search = { bg = "#fae9b7", fg = fg },
            SpecialKey = { fg = ansi.cyan },
            SpellBad = { undercurl = 1, sp = ansi.red },
            SpellCap = { undercurl = 1, sp = ansi.blue },
            SpellLocal = { undercurl = 1, sp = ansi.cyan },
            SpellRare = { undercurl = 1, sp = ansi.magenta },
            StatusLine = { bg = statusline, fg = fg },
            StatusLineNC = { bg = statusline, fg = "#9f9f9f" },
            TabLine = { bg = statusline, fg = "#7d7d7d" },
            TabLineFill = { bg = statusline },
            TabLineSel = { bg = statusline, fg = ansi.blue },
            Title = { fg = const_fg },
            Visual = { bg = "#bfdbfe" },
            VisualNOS = { bg = "#bfdbfe" },
            WarningMsg = { fg = "#e1ad4c" },
            WildMenu = { bg = "#999999" },
            WinBar = { bg = bg, fg = ansi.black, bold = true },
            WinBarNC = { bg = bg, fg = "#7d7d7d" },

            --- SYNTAX I: TS groups link to these
            Constant = { fg = const_fg },
            String = { fg = string_fg },
            Character = { fg = const_fg },
            Number = { fg = const_fg },
            Boolean = { fg = const_fg },
            Float = { fg = const_fg },
            Operator = { fg = punct_fg },

            --- SYNTAX II: TS groups have their own definition, the below are defined to have somewhat working hl w/o treesitter
            Identifier = { fg = ansi.black },
            Function = { fg = def_fg },
            Statement = { fg = ansi.black },
            Conditional = { fg = ansi.black },
            Repeat = { fg = ansi.black },
            Label = { fg = def_fg },
            Keyword = { fg = ansi.black },
            Exception = { fg = ansi.black },
            PreProc = { fg = ansi.black },
            Include = { fg = ansi.black },
            Define = { fg = ansi.black },
            Macro = { fg = ansi.black },
            PreCondit = { fg = ansi.black },
            Type = { fg = ansi.black },
            StorageClass = { fg = ansi.black },
            Structure = { fg = def_fg },
            Typedef = { fg = def_fg },

            Special = { fg = ansi.yellow },
            SpecialComment = { bg = "#FFDEAA", fg = ansi.blue },
            debugPc = { bg = "#C7C7EE" },
            debugBreakpoint = { bg = "#F8B28F" },
            helpHyperTextJump = { fg = ansi.magenta },
            helpSectionDelim = { fg = ansi.magenta },
            helpExample = { fg = ansi.cyan },
            helpCommand = { fg = ansi.cyan },
            helpHeadline = { fg = ansi.blue },
            helpHeader = { fg = ansi.magenta },

            Underlined = { underline = 1 },
            Italic = { italic = 1 },

            Error = { bg = mistake.bg, fg = mistake.fg },

            Todo = { bg = "#FFDEAA", fg = ansi.blue },

            --- Diagnostic
            LspReferenceText = { bg = "#dadada" },
            LspReferenceRdad = { bg = "#dadada" },
            LspReferenceWrite = { bg = "#dadada", underline = 1, sp = active_blue },
            LspCodeLens = { fg = "#999999" },
            LspCodeLensSeparator = { fg = "#999999" },

            --- Diagnostic
            DiagnosticError = { fg = error },
            DiagnosticWarn = { fg = warn },
            DiagnosticHint = { fg = hint },
            DiagnosticInfo = { fg = info },
            DiagnosticVirtualTextError = { bg = "#F8B28F", fg = "#411414" },
            DiagnosticVirtualTextWarn = { bg = "#fff987", fg = fg },
            DiagnosticVirtualTextHint = { fg = "#0F171D", bg = "#C3D0DA" },
            DiagnosticVirtualTextInfo = { bg = "#ADFFB7", fg = "#042F09" },

            --- Treesitter
            TSAttribute = {},
            TSConstructor = { fg = ansi.black },
            TSConditional = { fg = ansi.black },
            TSConstBuiltin = { fg = const_fg },
            TSConstMacro = { fg = ansi.black },
            TSError = { bg = mistake.bg, fg = mistake.fg },
            TSException = { fg = ansi.black },
            TSField = { fg = ansi.black },
            TSFunction = { fg = ansi.black },
            TSFuncBuiltin = { fg = ansi.black },
            TSFuncMacro = { fg = ansi.black },
            TSKeyword = { fg = ansi.black },
            TSKeywordFunction = { fg = ansi.black },
            TSLabel = { fg = ansi.black },
            TSMethod = { fg = ansi.black },
            TSNamespace = { fg = ansi.black },
            TSNone = { fg = const_fg },
            TSParameter = { fg = ansi.black },
            TSParameterReference = { fg = ansi.black },
            TSProperty = { fg = ansi.black },
            TSPunctDelimiter = { fg = punct_fg },
            TSPunctBracket = { fg = punct_fg },
            TSPunctSpecial = { fg = punct_fg },
            TSRepeat = { fg = ansi.black },
            TSString = { fg = string_fg },
            TSStringRegex = { bg = bg, fg = "#777777" },
            TSStringEscape = { bg = bg, fg = "#777777" },
            TSSymbol = {},
            TSType = { fg = ansi.black },
            TSTypeBuiltin = { fg = ansi.black },
            TSVariable = { fg = ansi.black },
            TSVariableBuiltin = { fg = ansi.black },
            TSTag = { fg = ansi.black },
            TSTagDelimiter = { fg = punct_fg },
            TSText = { fg = ansi.black },

            ["@attribute"] = {},
            ["@constructor"] = { fg = ansi.black },
            ["@conditional"] = { fg = ansi.black },
            ["@constant.builtin"] = { fg = const_fg },
            ["@constant.macro"] = { fg = ansi.black },
            ["@error"] = { bg = mistake.bg, fg = mistake.fg },
            ["@exception"] = { fg = ansi.black },
            ["@field"] = { fg = ansi.black },
            ["@function"] = { fg = ansi.black },
            ["@function.builtin"] = { fg = ansi.black },
            ["@function.macro"] = { fg = ansi.black },
            ["@keyword"] = { fg = ansi.black },
            ["@keyword.function"] = { fg = ansi.black },
            ["@label"] = { fg = ansi.black },
            ["@method"] = { fg = ansi.black },
            ["@module"] = { fg = ansi.black },
            ["@namespace"] = { fg = ansi.black },
            ["@none"] = { fg = const_fg },
            ["@parameter"] = { fg = ansi.black },
            ["@parameter.reference"] = { fg = ansi.black },
            ["@property"] = { fg = ansi.black },
            ["@punctuation.delimiter"] = { fg = punct_fg },
            ["@punctuation.bracket"] = { fg = punct_fg },
            ["@punctuation.special"] = { fg = punct_fg },
            ["@repeat"] = { fg = ansi.black },
            ["@string"] = { fg = string_fg },
            ["@string.regex"] = { bg = bg, fg = "#777777" },
            ["@string.escape"] = { bg = bg, fg = "#777777" },
            ["@symbol"] = {},
            ["@type"] = { fg = ansi.black },
            ["@type.builtin"] = { fg = ansi.black },
            ["@variable"] = { fg = ansi.black },
            ["@variable.builtin"] = { fg = ansi.black },
            ["@tag"] = { fg = ansi.black },
            ["@tag.delimiter"] = { fg = punct_fg },
            ["@text"] = { fg = ansi.black },
            ["@text.note"] = { bg = "#dddddd", fg = ansi.blue },
            ["@text.warning"] = { bg = "#FFDEAA", fg = ansi.blue },

            --- Theme specific
            ["@AlabasterConstant"] = { fg = const_fg },
            ["@AlabasterDefinition"] = { fg = def_fg },
            ["@AlabasterPunct"] = { fg = punct_fg },
            ["@AlabasterString"] = { fg = string_fg },
            ["@AlabasterHashbang"] = { fg = dim_comment },
            --- Gitsigns
            GitSignsAdd = { fg = "#6abf40" },
            GitSignsChange = { fg = diffchange },
            GitSignsDelete = { fg = diffdelete },
            --- Telescope
            TelescopeBorder = { fg = "#abbdc0" },
            TelescopeMatching = { fg = "#CC6F14" },
            TelescopeMultiSelection = { fg = ansi.magenta },
            TelescopePromptPrefix = { fg = ansi.blue },
            TelescopeSelectionCaret = { fg = mistake.fg },
            TelescopeTitle = { fg = ansi.yellow },
            TelescopeResultsTitle = { fg = ansi.yellow },
            --- fzf-lua
            FzfLuaBorder = { fg = "#abbdc0" },
            --- Neogit
            NeogitPopupActionDisabled = { fg = darker_fg },
            NeogitPopupActionKey = { fg = ansi.magenta },
            NeogitPopupOptionDisabled = { fg = darker_fg },
            NeogitPopupOptionKey = { fg = ansi.blue },
            NeogitPopupSwitchDisabled = { fg = darker_fg },
            NeogitPopupSwitchEnabled = { fg = ansi.cyan },
            NeogitPopupSwitchKey = { fg = ansi.magenta },
            --- Fugitive
            diffAdded = { link = "DiffAdd" },
            diffRemoved = { link = "DiffDelete" },
            --- Startify
            StartifyBracket = { fg = darker_fg },
            StartifyFile = { fg = ansi.black },
            StartifySection = { fg = ansi.green },
            StartifySlash = { fg = "#4e6e75" },
            StartifyPath = { fg = "#4e6e75" },
            --- Statusline
            StatuslineAdd = { fg = diffadd, bg = statusline },
            StatuslineErr = { fg = "#8E1410", bg = statusline },
            StatuslineHint = { fg = hint, bg = statusline },
            StatuslineInfo = { fg = info, bg = statusline },
            StatuslineWarn = { fg = warn, bg = statusline },
            StatuslineBlue = { fg = ansi.blue, bg = statusline },
            StatuslineRed = { fg = ansi.red, bg = statusline },
            StatuslineGreen = { fg = ansi.green, bg = statusline },
            StatuslineCyan = { fg = ansi.cyan, bg = statusline },
            StatuslineMagenta = { fg = ansi.magenta, bg = statusline },
            --- ALE
            ALEWarningSign = { fg = warn },
            --- vim-matchup
            MatchupVirtualText = { fg = ansi.yellow },
            --- For `highlight link`
            AlabasterBlack = { fg = ansi.black },
            AlabasterBlue = { fg = ansi.blue },
            AlabasterBrightYellow = { fg = ansi.brightyellow },
            AlabasterCyan = { fg = ansi.cyan },
            AlabasterGreen = { fg = ansi.green },
            AlabasterBrightGreen = { fg = "#60cb00" },
            AlabasterMagenta = { fg = ansi.magenta },
            AlabasterRed = { fg = ansi.red },
            AlabasterWhite = { fg = ansi.black },
            AlabasterYellow = { fg = ansi.yellow },
            --- Hop
            HopNextKey = { fg = ansi.yellow },
            HopNextKey1 = { fg = ansi.blue },
            HopNextKey2 = { fg = "#17A2D6" },
            HopUnmatched = { fg = "#bfbfbf" },
            --- Lightspeed
            LightspeedGreyWash = { fg = "#bfbfbf" },
            --- checkhealth
            healthSuccess = { fg = ansi.green, bg = bg },
            --- cmp
            CmpItemMenuDefault = { fg = ansi.magenta },
            --- nvim-ts-rainbow
            rainbowcol1 = { fg = ansi.yellow },
            rainbowcol2 = { fg = ansi.magenta },
            rainbowcol3 = { fg = ansi.blue },
            rainbowcol4 = { fg = ansi.green },
            rainbowcol5 = { fg = ansi.brightyellow },
            rainbowcol6 = { fg = ansi.red },
            rainbowcol7 = { fg = ansi.cyan },
            --- Iswap
            ISwapSnipe = { bg = ansi.yellow, fg = bg },
            ISwapGrey = { fg = "#bfbfbf" },
            --- vim-dadbod-ui
            dbui_help = { fg = dim_comment },
            dbui_connection_source = { fg = dim_comment },
            --- nvim-dap-virtual-text
            NvimDapVirtualText = { bg = "#78D2C9", fg = fg },
            --- Noice
            NoiceCmdlineIcon = { link = "AlabasterBrightGreen" },
            NoiceCmdlinePopupBorder = { link = "AlabasterBrightGreen" },
            NoiceConfirmBorder = { link = "AlabasterBrightGreen" },
            NoiceCmdlinePopupBorderCmdline = { link = "AlabasterBrightGreen" },
            NoiceCmdlineIconCmdline = { link = "AlabasterBrightGreen" },
            NoiceCmdlinePopupBorderFilter = { link = "AlabasterBrightGreen" },
            NoiceCmdlineIconFilter = { link = "AlabasterBrightGreen" },
            NoiceCmdlinePopupBorderLua = { link = "AlabasterBrightGreen" },
            NoiceCmdlineIconLua = { link = "AlabasterBrightGreen" },
            NoiceCmdlinePopupBorderSearch = { link = "AlabasterYellow" },
            NoiceCmdlineIconSearch = { link = "AlabasterYellow" },
            -- Languages
            --- asm
            asmDirective = { fg = dim_comment },
            nasmLabel = { link = "@AlabasterDefinition" },
            ["@lsp.mod.declaration"] = { fg = fg },
            ["@lsp.type.enumMember"] = { fg = fg },
            ["@lsp.type.function"] = { fg = fg },
            ["@lsp.type.method"] = { fg = fg },
            ["@lsp.type.selfKeyword"] = { fg = fg },
            ["@lsp.typemod.class.declaration"] = { fg = def_fg },
            ["@lsp.typemod.class.definition"] = { fg = def_fg },
            ["@lsp.typemod.enum.declaration"] = { fg = def_fg },
            ["@lsp.typemod.enumMember.defaultLibrary"] = { fg = fg },
            ["@lsp.typemod.function.declaration"] = { fg = def_fg },
            ["@lsp.typemod.function.definition"] = { fg = def_fg },
            ["@lsp.typemod.macro.declaration"] = { fg = def_fg },
            ["@lsp.typemod.method.declaration"] = { fg = def_fg },
            ["@lsp.typemod.selfKeyword"] = { fg = fg },
            ["@lsp.typemod.struct.declaration"] = { fg = def_fg },
            ["@lsp.typemod.type.declaration"] = { fg = def_fg },
        }
        if custom then
            retint(theme, custom, false)
        end
        apply("alabaster", theme)
    end
end

-- alabaster-bg: light theme, all text black, color conveyed via backgrounds.
local function alabaster_bg()
    clear()
    local custom = custom_background()
    local dark = custom and color.is_dark(custom) or false
    vim.o.background = dark and "dark" or "light"
    light_terminal_colors()

    local bg_main = custom or "#fafafa"
    local bg_subtle = custom and blend(bg_main, dark, 0.06, 0.04) or "#f0f0f0"
    local bg_dark = custom and blend(bg_main, dark, 0.09, 0.08) or "#ebebeb"
    local bg_string = "#f1fadf"
    local bg_string_esc = "#dbecb6"
    local bg_comment = "#fffabc"
    local bg_definition = "#dbf1ff"
    local bg_error = "#ffe0e0"
    local bg_blue_menu = "#b4d8fd"
    local bg_yellow = "#ffbc5d"
    local black = dark and "#F7F7F7" or "#000000"
    local on_color = "#000000"
    local grey_dark = "#707070"
    local grey_light = "#8a8a8a"
    local purple = "#7a3e9d"
    local blue_bright = "#007acc"

    local theme = {
        ColorColumn = { bg = bg_dark },
        Conceal = { fg = black, bg = bg_main },
        Cursor = { bg = blue_bright, fg = on_color },
        CursorColumn = { bg = bg_subtle },
        CursorLine = { bg = bg_subtle },
        Directory = { fg = blue_bright },
        DiffAdd = { fg = on_color, bg = bg_string },
        DiffChange = { fg = on_color, bg = bg_blue_menu },
        DiffDelete = { fg = on_color, bg = bg_error },
        DiffText = { fg = on_color, bg = bg_definition },
        EndOfBuffer = { fg = grey_dark },
        ErrorMsg = { fg = on_color, bg = bg_error },
        VertSplit = { fg = grey_dark, bg = bg_main },
        Folded = { fg = black, bg = bg_dark },
        FoldColumn = { fg = black, bg = bg_dark },
        SignColumn = { fg = black, bg = bg_main },
        IncSearch = { fg = on_color, bg = bg_yellow },
        LineNr = { fg = grey_dark, bg = bg_main },
        CursorLineNr = { fg = black },
        MatchParen = { fg = on_color, bg = bg_definition },
        MoreMsg = { fg = on_color, bg = bg_blue_menu },
        NonText = { fg = grey_dark, bg = bg_main },
        Normal = { bg = bg_main, fg = black },
        NormalFloat = { bg = bg_subtle },
        FloatBorder = { fg = grey_dark, bg = bg_subtle },
        Pmenu = { fg = on_color, bg = bg_blue_menu },
        PmenuSel = { fg = black, bg = bg_dark },
        PmenuSbar = { fg = on_color, bg = bg_blue_menu },
        PmenuThumb = { fg = black, bg = bg_dark },
        Question = { fg = on_color, bg = bg_blue_menu },
        QuickFixLine = { fg = black, bg = bg_dark },
        Search = { fg = on_color, bg = bg_yellow },
        SpecialKey = { fg = blue_bright },
        SpellBad = { fg = on_color, bg = bg_error },
        SpellCap = { fg = on_color, bg = bg_error },
        SpellLocal = { fg = on_color, bg = bg_string },
        SpellRare = { fg = on_color, bg = bg_comment },
        StatusLine = { fg = on_color, bg = bg_blue_menu },
        StatusLineNC = { fg = black, bg = bg_dark },
        TabLine = { fg = on_color, bg = bg_blue_menu },
        TabLineFill = { fg = on_color, bg = bg_blue_menu },
        TabLineSel = { fg = black, bg = bg_main },
        Title = { fg = on_color, bg = bg_definition },
        Visual = { bg = bg_blue_menu },
        VisualNOS = { fg = black, bg = bg_dark },
        WarningMsg = { fg = on_color, bg = bg_blue_menu },
        WildMenu = { fg = black, bg = bg_main },
        WinBar = { bg = bg_main, fg = black, bold = true },
        WinBarNC = { bg = bg_main, fg = grey_dark },

        Comment = { fg = on_color, bg = bg_comment },
        Constant = { fg = purple },
        String = { fg = on_color, bg = bg_string },
        Character = { fg = on_color, bg = bg_string },
        Number = { fg = purple },
        Boolean = { fg = purple },
        Float = { fg = purple },
        Identifier = { fg = black },
        Function = { fg = on_color, bg = bg_definition },
        Statement = { fg = black },
        Conditional = { fg = black },
        Repeat = { fg = black },
        Label = { fg = on_color, bg = bg_definition },
        Keyword = { fg = black },
        Exception = { fg = black },
        PreProc = { fg = black },
        Include = { fg = black },
        Define = { fg = on_color, bg = bg_definition },
        Macro = { fg = black },
        PreCondit = { fg = black },
        Type = { fg = black },
        StorageClass = { fg = black },
        Structure = { fg = on_color, bg = bg_definition },
        Typedef = { fg = on_color, bg = bg_definition },
        Special = { fg = black },
        SpecialComment = { fg = on_color, bg = bg_comment },
        Error = { fg = on_color, bg = bg_error },
        Todo = { fg = on_color, bg = bg_comment },
        Operator = { fg = grey_dark },

        --- Alabaster query capture targets: force bg so treesitter queries pop
        ["@AlabasterBase"] = { fg = black },
        ["@AlabasterConstant"] = { fg = purple },
        ["@AlabasterDefinition"] = { fg = on_color, bg = bg_definition },
        ["@AlabasterPunct"] = { fg = grey_dark },
        ["@AlabasterString"] = { fg = on_color, bg = bg_string },
        ["@AlabasterComment"] = { fg = on_color, bg = bg_comment },
        ["@AlabasterHashbang"] = { fg = grey_light },
        ["@AlabasterPunctuation"] = { fg = grey_dark },
    }
    if dark then
        theme.Visual = { fg = on_color, bg = bg_blue_menu }
    end
    apply("alabaster-bg", theme)
end

-- alabaster-mono: light monochrome, only the cursor is colored.
local function alabaster_mono()
    clear()
    local custom = custom_background()
    local dark = custom and color.is_dark(custom) or false
    vim.o.background = dark and "dark" or "light"
    light_terminal_colors()

    local bg_main = custom or "#ffffff"
    local bg_highlight = custom and blend(bg_main, dark, 0.08, 0.07) or "#eeeeee"
    local bg_light_grey = custom and blend(bg_main, dark, 0.16, 0.15) or "#d9d9d9"
    local bg_subtle = custom and blend(bg_main, dark, 0.03, 0.02) or "#fafafa"
    local fg = dark and "#F7F7F7" or "#000000"
    local black = "#000000"
    local grey = "#999999"
    local cyan = "#16bdec"

    local theme = {
        ColorColumn = { bg = bg_highlight },
        Conceal = { fg = fg, bg = bg_main },
        Cursor = { bg = cyan, fg = black },
        CursorColumn = { bg = bg_subtle },
        CursorLine = { bg = bg_subtle },
        Directory = { fg = fg, bg = bg_highlight },
        DiffAdd = { fg = fg, bg = bg_highlight },
        DiffChange = { fg = fg, bg = bg_light_grey },
        DiffDelete = { fg = grey, bg = bg_main },
        DiffText = { fg = fg, bg = bg_highlight },
        EndOfBuffer = { fg = grey },
        ErrorMsg = { fg = fg, bg = bg_light_grey },
        VertSplit = { fg = grey, bg = bg_main },
        Folded = { fg = grey, bg = bg_main },
        FoldColumn = { fg = grey, bg = bg_main },
        SignColumn = { fg = grey, bg = bg_main },
        IncSearch = { fg = black, bg = cyan },
        LineNr = { fg = grey, bg = bg_main },
        CursorLineNr = { fg = fg },
        MatchParen = { fg = fg, bg = bg_highlight },
        MoreMsg = { fg = fg, bg = bg_main },
        NonText = { fg = grey, bg = bg_main },
        Normal = { bg = bg_main, fg = fg },
        NormalFloat = { bg = bg_light_grey },
        FloatBorder = { fg = grey, bg = bg_light_grey },
        Pmenu = { fg = fg, bg = bg_light_grey },
        PmenuSel = { fg = fg, bg = bg_highlight },
        PmenuSbar = { fg = fg, bg = bg_light_grey },
        PmenuThumb = { fg = fg, bg = bg_highlight },
        Question = { fg = fg, bg = bg_main },
        QuickFixLine = { fg = fg, bg = bg_highlight },
        Search = { fg = fg, bg = bg_highlight },
        SpecialKey = { fg = grey },
        SpellBad = { fg = fg, bg = bg_light_grey },
        SpellCap = { fg = grey, bg = bg_light_grey },
        SpellLocal = { fg = fg, bg = bg_highlight },
        SpellRare = { fg = grey, bg = bg_highlight },
        StatusLine = { fg = fg, bg = bg_light_grey },
        StatusLineNC = { fg = grey, bg = bg_light_grey },
        TabLine = { fg = fg, bg = bg_light_grey },
        TabLineFill = { fg = grey, bg = bg_light_grey },
        TabLineSel = { fg = fg, bg = bg_main },
        Title = { fg = fg, bg = bg_highlight },
        Visual = { bg = bg_light_grey },
        VisualNOS = { fg = grey, bg = bg_main },
        WarningMsg = { fg = fg, bg = bg_light_grey },
        WildMenu = { fg = fg, bg = bg_main },
        WinBar = { bg = bg_main, fg = fg, bold = true },
        WinBarNC = { bg = bg_main, fg = grey },

        Comment = { fg = grey },
        Constant = { fg = fg, bg = bg_highlight },
        String = { fg = fg, bg = bg_highlight },
        Character = { fg = fg, bg = bg_highlight },
        Number = { fg = fg, bg = bg_highlight },
        Boolean = { fg = fg, bg = bg_highlight },
        Float = { fg = fg, bg = bg_highlight },
        Identifier = { fg = fg, bg = bg_highlight },
        Function = { fg = fg, bg = bg_highlight },
        Statement = { fg = fg },
        Conditional = { fg = fg },
        Repeat = { fg = fg },
        Label = { fg = fg },
        Keyword = { fg = fg },
        Exception = { fg = fg },
        PreProc = { fg = fg },
        Include = { fg = fg },
        Define = { fg = fg, bg = bg_highlight },
        Macro = { fg = fg },
        PreCondit = { fg = fg },
        Type = { fg = fg },
        StorageClass = { fg = fg },
        Structure = { fg = fg },
        Typedef = { fg = fg },
        Special = { fg = fg },
        SpecialComment = { fg = grey },
        Error = { fg = fg, bg = bg_light_grey },
        Todo = { fg = fg, bg = bg_highlight },
        Operator = { fg = fg },

        --- Alabaster query capture targets
        ["@AlabasterBase"] = { fg = fg },
        ["@AlabasterConstant"] = { fg = fg, bg = bg_highlight },
        ["@AlabasterDefinition"] = { fg = fg, bg = bg_highlight },
        ["@AlabasterPunct"] = { fg = grey },
        ["@AlabasterString"] = { fg = fg, bg = bg_highlight },
        ["@AlabasterComment"] = { fg = grey },
        ["@AlabasterHashbang"] = { fg = grey },
        ["@AlabasterPunctuation"] = { fg = grey },
    }
    apply("alabaster-mono", theme)
end

function M.load(name)
    if name == "alabaster" then
        alabaster()
    elseif name == "alabaster-bg" then
        alabaster_bg()
    elseif name == "alabaster-mono" then
        alabaster_mono()
    else
        error("Unknown alabaster variant: " .. name, 2)
    end
end

return M
