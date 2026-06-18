-- hs.hotkey.bind({"ctrl", "command"}, "1", function()
--   local arc = hs.application.find('Arc')
--   if arc:isFrontmost() then
--     hs.eventtap.keyStroke("cmd", "h")
--   else
--     hs.application.launchOrFocus("/Applications/Arc.app")
--   end
-- end)

-- hs.hotkey.bind({"ctrl", "command"}, "2", function()
--   local alacritty = hs.application.find('alacritty')
--   if alacritty:isFrontmost() then
--     alacritty:hide()
--   else
--     hs.application.launchOrFocus("/Applications/Alacritty.app")
--   end
-- end)

hs.hotkey.bind({"ctrl", "command"}, "8", function()
  local slack = hs.application.find('slack')
  if slack:isFrontmost() then
    slack:hide()
  else
    hs.application.launchOrFocus("/Applications/Slack.app")
  end
end)

hs.hotkey.bind({"ctrl", "command"}, "4", function()
  local spark = hs.application.find('Spark Desktop')
  if spark:isFrontmost() then
    spark:hide()
  else
    hs.application.launchOrFocus("/Applications/Spark Desktop.app")
  end
end)

hs.hotkey.bind({"ctrl", "command"}, "5", function()
  local finder = hs.application.find('Finder')
  if finder:isFrontmost() then
    finder:hide()
  else
    hs.application.launchOrFocus("/System/Library/CoreServices/Finder.app")
  end
end)

-- Arc の複数ウィンドウを「タイトル」でグループ分けし、
-- 各グループを 1つのホットキーで focus + cycle する設定。
-- （1回目=グループ先頭へ / 2回目以降=次へ。末尾で先頭に戻る）
 
local APP = "Arc" -- 対象アプリ（"Google Chrome" 等に変更可）
 
----------------------------------------------------------------------
-- 内部処理（基本いじらない）
----------------------------------------------------------------------
 
-- タイトルが list のいずれかを含むか（プレーン検索）
local function titleHasAny(title, list)
  for _, m in ipairs(list) do
    if title:find(m, 1, true) then return true end
  end
  return false
end
 
-- 背面アプリの特定ウィンドウは1回のfocusで前面化しきれないことがあるため、
-- 背面から呼ばれた時だけ「少し待って再度上げる」を行う（前面時は連打でも乱れない）。
local function raiseWindow(w)
  if not w then return end
  local app = w:application()
  local wasFront = app and app:isFrontmost()
  if app then app:activate() end
  w:focus()
  if not wasFront then
    hs.timer.doAfter(0.05, function() if w then w:focus() end end)
  end
end
 
-- Arc の通常ウィンドウ一覧を取得
local function arcWindows()
  local app = hs.application.find(APP)
  if not app then return nil, nil end
  local wins = {}
  for _, w in ipairs(app:allWindows()) do
    -- if w:isStandard() then wins[#wins + 1] = w end -- パネル等を除外
    wins[#wins + 1] = w -- パネル等を除外
  end
  return wins, app
end
 
-- filterFn(title)->bool で対象ウィンドウ群を作り、その中を focus + cycle する共通エンジン
local function cycleGroup(filterFn)
  local wins, app = arcWindows()
  if not wins then hs.application.launchOrFocus(APP); return end
  local group = {}
  for _, w in ipairs(wins) do
    if filterFn(w:title()) then group[#group + 1] = w end
  end
  table.sort(group, function(a, b) return a:id() < b:id() end) -- 毎回同じ順序
  if #group == 0 then if app then app:activate() end; return end
  local focused = hs.window.focusedWindow()
  local idx = 0
  for i, w in ipairs(group) do
    if focused and w:id() == focused:id() then idx = i; break end
  end
  raiseWindow(group[(idx % #group) + 1])
end
 
-- 指定タイトル（文字列 または OR条件のリスト）を含むウィンドウ群を巡回
local function cycleService(names)
  if type(names) == "string" then names = { names } end -- 単一文字列もOK
  return function()
    cycleGroup(function(title) return titleHasAny(title, names) end)
  end
end
 
-- 指定したどの名前も含まない「その他」ウィンドウ群を巡回
local function cycleOther(excludes)
  return function()
    cycleGroup(function(title) return not titleHasAny(title, excludes) end)
  end
end

----------------------------------------------------------------------
-- ★キー割り当て（ここだけ編集すればOK。1行=1ホットキー。自由に入れ替え可）
--   修飾キー・数字キー・サービス名を、それぞれ手動で対応づける。
----------------------------------------------------------------------
hs.hotkey.bind({ "cmd", "ctrl" }, "1", cycleOther({ "日報", "- Claude" })) -- その他
hs.hotkey.bind({ "cmd", "ctrl" }, "2", cycleService("日報"))
hs.hotkey.bind({ "cmd", "ctrl" }, "c", cycleService({"- Claude", "Claude Code"}))
