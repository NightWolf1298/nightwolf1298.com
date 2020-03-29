require 'json'
require 'csv'

caught = Hash.new
if (File.exist?('_data/simple-pokedex.csv'))
  CSV.foreach('_data/simple-pokedex.csv', headers: true) do |row|
    c = row['Caught']
    m = row['CaughtM']
    f = row['CaughtF']
    caught[row['IconFile']] = [c.nil? ? 0 : c.to_i, m.nil? ? 0 : m.to_i, f.nil? ? 0 : f.to_i]
  end
end

rows = Array.new
json = JSON.parse(File.read('_data/pokedex.json'))
json.each do |type_name,type| # normal/shiny
  type.each do |region_name,region| # kanto/johto/hoenn/sinnoh/unova/kalos/alola/unknown
    region.each do |icon_file,pokemon| # icon filename
      # caught has either the old value from the existing csv, or 0 for new keys
      data = caught[icon_file]
      data = data.nil? ? [0, 0, 0] : data
      rows.push([data[1] + data[2] > 0 ? 1 : data[0], data[1], data[2], icon_file])
    end
  end
end

# sort by number - normal (no form), shiny, other forms, alola, alola-shiny
rows = rows.sort_by { |k| k[3].delete_suffix('.svg').gsub('-alola', '~alola') }

csv = CSV.open('_data/simple-pokedex.csv', 'wb', headers: ['Caught','CaughtM','CaughtF','IconFile'], write_headers: true) do |csv|
  rows.each do |row|
    csv << row
  end
end