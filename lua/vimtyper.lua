
 local long_text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec et tellus vel nunc porta ornare. Maecenas congue bibendum ligula non consectetur. Ut scelerisque dui libero, et laoreet dui fringilla et. Aenean dignissim ligula tempus, lobortis ante eget, ornare neque. Morbi urna urna, suscipit vitae molestie id, dignissim vel lacus. Fusce in ante et lorem fermentum pretium. Nulla placerat tortor blandit turpis viverra, et imperdiet dui lobortis. Duis non commodo ipsum. Mauris pretium sapien lectus, non condimentum odio egestas eget. Sed ullamcorper lacus nisi. Nam quam nibh, facilisis sit amet pulvinar vitae, fermentum ac velit. Etiam vitae odio et ligula cursus interdum. "

 -- specify the amount of char to show on screen at a time
 local text = string.sub(long_text, 0, 100)


local win_width = vim.api.nvim_win_get_width(0)
local win_height = vim.api.nvim_win_get_height(0)



-- Disable space globally in normal mode
vim.api.nvim_del_keymap('n', '<Space>') -- Remove existing Space mapping
vim.api.nvim_del_keymap('n', '<CR>')

local centered_text_details = {
    sentence = string.rep(" ", math.floor((win_width - #text) / 2)) .. text,
    position = math.floor(win_height / 2),
    starting_col = math.floor((win_width - #text) / 2)
}


local create_buffer =  function()
  local buf = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_buf_set_name(buf, "vimtyper")
  vim.api.nvim_set_option_value("filetype", "lua", { buf = buf })
	-- vim.bo[buf].modifiable = false
  return buf
end



local insert_blank_lines_buf = function(buf)
	for _ = 0 ,win_height, 1 do
		vim.api.nvim_buf_set_lines(buf,0,0,true,{" "})
	end
end

local center_text = function(buf, text)
	insert_blank_lines_buf(buf)
  vim.api.nvim_buf_set_lines(buf, centered_text_details.position, centered_text_details.position + 3, true, { centered_text_details.sentence})
end


local resize_handler = function(buffer, text)
    -- local welcome_text = "Welcome to VimTyper! This is a test typing game made for Neovim."
    center_text(buffer, text)
end

local get_char_under_cursor = function()
    local row = vim.fn.line('.')  
    local col = vim.fn.col('.')  
    local line = vim.fn.getline(row) 
    local char = line:sub(col, col) 
    return char
end


local handle_keypress = function(key)
    local current_char = get_char_under_cursor()
    if key == current_char then
        vim.cmd("normal! l")  -- Move to next character
				print(key)
    end
end




local listen_keypress = function()
    -- Map every printable key to the handle_keypress function
    for i = 32, 126 do -- ASCII range for printable characters
        local key = string.char(i)
        vim.api.nvim_buf_set_keymap(0, 'n', key, '', {
            noremap = true,
            silent = true,
            callback = function() handle_keypress(key) end,
        })
    end

    -- You can also map additional keys like backspace, enter, etc.
    vim.api.nvim_buf_set_keymap(0, 'n', '<BS>', '', {
        noremap = true,
        silent = true,
        callback = function() handle_keypress('<BS>') end,
    })
end

local VimTyper = function()
  local buf = create_buffer()

	insert_blank_lines_buf(buf)
	center_text(buf, text)

  vim.api.nvim_win_set_buf(0, buf)


	vim.bo[buf].modifiable = false

	vim.cmd("redraw!")

  vim.api.nvim_win_set_cursor(0, { centered_text_details.position + 1, centered_text_details.starting_col })

	listen_keypress()
end


local setup = function()
  local augroup = vim.api.nvim_create_augroup("vimtyper", { clear = true })

  vim.api.nvim_create_autocmd("VimEnter", {
    group = augroup,
    desc = "Typing test plugin for neovim",
    once = true,
    callback = function()
		vim.keymap.set('n', '<Esc>', "<Nop>", { buffer = true })  -- Disable Escape
		vim.keymap.set('n', 'i', "<Nop>", { buffer = true })  -- Disable insert mode

		vim.api.nvim_set_keymap('n', '<leader>t', '', {
			noremap = true,
			silent = true,
			callback = VimTyper

		})
		end,
  })
	vim.api.nvim_create_autocmd("VimResized", {
					group = augroup,
					desc = "Update centered text on window resize",
					callback = function()
							local buffer = vim.api.nvim_get_current_buf()  -- Get the current buffer
							resize_handler(buffer, text)  -- Call the resize handler to center text
					end,
			})
end

return { setup = setup }



