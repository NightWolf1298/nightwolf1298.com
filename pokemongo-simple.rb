require 'json'
require 'csv'

caught = Hash.new(0)
if (File.exist?('_data/simple-pokedex.csv'))
  CSV.foreach('_data/simple-pokedex.csv', headers: true) do |row|
    caught[row[1]] = row[0]
  end
end

rows = Array.new
json = JSON.parse(File.read('_data/pokedex.json'))
json.each do |type_name,type| # normal/shiny
  type.each do |region_name,region| # kanto/johto/hoenn/sinnoh/unova/kalos/alola/unknown
    region.each do |icon_file,pokemon| # icon filename
      # caught has either the old value from the existing csv, or 0 for new keys
      if (icon_file.start_with?('-'))
        # workaround for '-636-larvesta-shiny.svg' file in latest icon version
        icon_file = icon_file.delete_prefix('-')
      end
      rows.push([caught[icon_file],icon_file])
    end
  end
end

# sort by number - normal (no form), shiny, other forms, alola, alola-shiny
rows = rows.sort_by { |k| k[1].delete_suffix('.svg').gsub('-alola', '~alola') }

csv = CSV.open('_data/simple-pokedex.csv', 'wb', headers: ['Caught','IconFile'], write_headers: true) do |csv|
  rows.each do |row|
    csv << row
  end
end