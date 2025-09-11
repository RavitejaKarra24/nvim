# AI Integration Setup

This Neovim configuration includes GitHub Copilot and CopilotChat integration with support for multiple AI models including Gemini.

## Prerequisites

1. **GitHub Copilot Subscription**: You need an active GitHub Copilot subscription
2. **API Keys**: For Gemini AI integration, you need to set up API keys

## Setup Instructions

### 1. GitHub Copilot Setup

1. Install the plugins (they will be auto-installed by lazy.nvim)
2. Authenticate with GitHub Copilot:
   ```
   :Copilot auth
   ```
3. Follow the authentication flow in your browser

### 2. Gemini API Setup (Optional)

1. Get a Gemini API key from Google AI Studio
2. Set the environment variable:
   ```bash
   export GEMINI_API_KEY="your-api-key-here"
   ```
3. Add this to your shell profile (~/.bashrc, ~/.zshrc, etc.)

## Usage

### Visual Mode AI Chat
1. Select code in visual mode
2. Press `ai` to open a quick chat with the selected code
3. Type your question and press Enter

### Chat Window
- `<leader>ao` - Open chat window
- `<leader>ac` - Close chat window  
- `<leader>at` - Toggle chat window

### AI Model Selection
- `<leader>am` - Open model selector to switch between AI models

### AI Autocomplete Toggle
- `<leader>aa` - Toggle AI autocomplete on/off

### Predefined Prompts
- `<leader>ae` - Explain code/selection
- `<leader>ar` - Review code/selection
- `<leader>af` - Fix code/selection
- `<leader>ap` - Optimize code/selection
- `<leader>ad` - Generate documentation
- `<leader>as` - Generate tests

### Copilot Suggestions (Insert Mode)
- `<C-J>` - Accept suggestion
- `<C-K>` - Previous suggestion
- `<C-L>` - Next suggestion

## Chat Window Configuration

The chat window is configured as a floating window rather than a sidebar, with:
- 50% width and height of the editor
- Centered position
- Single border
- "Copilot Chat" title

## Model Support

The integration supports multiple AI models:
- gemini-pro (default)
- gpt-4
- gpt-3.5-turbo
- claude-3-opus
- claude-3-sonnet

Note: Model switching is implemented in the UI but may require additional backend configuration for full support.

## Troubleshooting

1. If Copilot isn't working, run `:Copilot status` to check authentication
2. For chat issues, check if the API key is properly set
3. Use `:CopilotChatDebug` for debugging chat functionality

## Files Modified

- `lua/plugins/copilot.lua` - GitHub Copilot configuration
- `lua/plugins/copilot-chat.lua` - CopilotChat with Gemini integration
- `lua/vim-options.lua` - Updated with AI keymap documentation