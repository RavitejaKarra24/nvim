# AI Integration Setup

This Neovim configuration includes GitHub Copilot integration with a custom chat interface that allows you to ask questions about your code.

## Prerequisites

1. **GitHub Copilot Subscription**: You need an active GitHub Copilot subscription
2. **Neovim 0.9.5+**: Compatible with current Neovim version

## Setup Instructions

### 1. GitHub Copilot Setup

1. Install the plugins (they will be auto-installed by lazy.nvim)
2. Authenticate with GitHub Copilot:
   ```
   :Copilot auth
   ```
3. Follow the authentication flow in your browser

### 2. Optional: Future AI Model Integration

The interface includes placeholder support for additional AI models including the latest versions like Gemini 2.5 Pro, Claude 4, and Grok 4, as well as thinking models like o1-preview and o1-mini. To enable these:
1. Get API keys for your preferred AI service
2. Set up environment variables as needed
3. Extend the model switching functionality in the plugin configuration

## Usage

### Visual Mode AI Chat
1. Select code in visual mode (highlight the text)
2. Press `ai` to open a chat window with the selected code
3. The chat window will open in a horizontal split with your code included
4. Type your question and use Copilot's suggestions to get help

### Chat Window Management
- `<leader>ao` - Open chat window
- `<leader>ac` - Close chat window  
- `<leader>at` - Toggle chat window
- `<leader>ai` - Open empty chat window

### AI Model Selection
- `<leader>am` - Open model selector (currently shows UI for future models)

### AI Autocomplete Toggle
- `<leader>aa` - Toggle AI autocomplete on/off

### Predefined Prompts
These open the chat window with pre-filled prompts:
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

## Chat Window Features

The chat window is implemented as:
- Horizontal split taking 40% of screen height
- Markdown formatting for better readability
- Automatic code block formatting for selected code
- Header with instructions

## How It Works

1. **Visual Selection**: When you select code and press `ai`, the selected code is automatically formatted and added to the chat window
2. **Chat Interface**: The chat window is a simple markdown buffer where you can type questions
3. **Copilot Integration**: Use Copilot's autocomplete in the chat window to get AI-powered responses
4. **Code Context**: Selected code is automatically included with proper syntax highlighting

## Model Support

Currently supports:
- **GitHub Copilot** (fully functional)
- **Future Models** (UI placeholder):
  - gemini-2.5-pro
  - claude-4
  - grok-4
  - gpt-4o
  - o1-preview (thinking model)
  - o1-mini (thinking model)
  - claude-3.5-sonnet

## Workflow Example

1. Open a code file
2. Select a function or code block in visual mode
3. Press `ai` 
4. Chat window opens with your code included
5. Type: "What does this function do?"
6. Use Copilot suggestions to get detailed explanations
7. Ask follow-up questions in the same chat window

## Troubleshooting

1. **Copilot not working**: Run `:Copilot status` to check authentication
2. **No suggestions**: Make sure autocomplete is enabled with `<leader>aa`
3. **Chat window issues**: Use `<leader>at` to toggle or `<leader>ac` to close and reopen

## Files Added/Modified

- `lua/plugins/copilot-chat.lua` - Main GitHub Copilot and chat integration
- `lua/vim-options.lua` - Updated with AI keymap documentation
- `AI_SETUP.md` - This documentation file