# CLI params wrapper

class VK::IRB::Params < Struct.new(:docopt)
  DOCOPT = <<-DOCOPT
vk interactive ruby shell #{ VK::VERSION }

Usage:
  vk list [options]
  vk add <name> [<token>]
  vk update <name> [<token>]
  vk remove <name>
  vk <name> [options]

Options:
  --eval=<code>    evaluate ruby code
  --execute=<file> execute ruby file
  --config=<file>  config file, default ./.vk.yml or ~/.vk.yml

Arguments:
  <name>  user name
  <token> vk api access token
  <code>  ruby code
  <file>  path to file 
DOCOPT

  DEFAULT_CONFIG_FILE = "#{ ENV['HOME'] }/.vk.yml".freeze

  def list?
    docopt['list']
  end

  def add?
    docopt['add']
  end

  def remove?
    docopt['remove']
  end

  def update?
    docopt['update']
  end

  def eval?
    docopt['--eval'] or docopt['-e']
  end

  alias evaluated_code eval?

  def execute?
    docopt['--execute'] or docopt['-ex']
  end

  alias executed_file execute?

  def user_name
    docopt['<name>']
  end

  def token
    docopt['<token>']
  end

  def config_file
    @config_file ||= [
      docopt['--config'],
      "#{ ENV['PWD'] }/.vk.yml"
    ].compact.detect {|f| File.exists?(f) } || DEFAULT_CONFIG_FILE
  end
  
end