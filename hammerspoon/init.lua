hs.hotkey.bind({"ctrl", "command"}, "1", function()
  local arc = hs.application.find('Arc')
  if arc:isFrontmost() then
    hs.eventtap.keyStroke("cmd", "h")
  else
    hs.application.launchOrFocus("/Applications/Arc.app")
  end
end)

hs.hotkey.bind({"ctrl", "command"}, "2", function()
  local alacritty = hs.application.find('alacritty')
  if alacritty:isFrontmost() then
    alacritty:hide()
  else
    hs.application.launchOrFocus("/Applications/Alacritty.app")
  end
end)

hs.hotkey.bind({"ctrl", "command"}, "3", function()
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
