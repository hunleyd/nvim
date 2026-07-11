-- minimal_init.lua for tests
local root = vim.fn.getcwd()

-- Add project lua folder to package.path
package.path = package.path .. ';' .. root .. '/lua/?.lua;' .. root .. '/lua/?/init.lua'

-- Add plugin paths to runtimepath
-- In isolated test children, stdpath('data') is a temporary directory. Point directly
-- to the user's standard package path to prevent cloning plugins from GitHub on every test run.
local real_site = vim.fn.expand('~/.local/share/nvim/site')
local data_path = (vim.fn.isdirectory(real_site) == 1 and real_site) or (vim.fn.stdpath('data') .. '/site')
vim.opt.packpath:prepend(data_path)

-- Bootstrap config
vim.g.testing = true

-- Clean up any yankbank database and lock files to prevent stale lock errors on child restart
local db_dir = vim.fn.stdpath('data')
os.remove(db_dir .. '/yankbank.db')
os.remove(db_dir .. '/yankbank.db-wal')
os.remove(db_dir .. '/yankbank.db-shm')

dofile('init.lua')
