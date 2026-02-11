local chat = require('chat');

local SkillchainChat = {};

function SkillchainChat.msg(text)
    print(chat.header(addon.name):append(chat.message(text)));
end

function SkillchainChat.err(text)
    print(chat.header(addon.name):append(chat.error(text)));
end

return SkillchainChat;
